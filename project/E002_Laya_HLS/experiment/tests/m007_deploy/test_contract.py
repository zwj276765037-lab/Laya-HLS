"""Independent frame construction, adversarial boundaries and raw CLS checks."""
from dataclasses import replace
import hashlib
from pathlib import Path
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "host"))
from m007_deploy.contract import (BufferRegion, ContractError, DeviceResultError,
    Identity, Request, OFFSETS, canonical_request, decode_request, encode_request,
    validate_tail_ready)
from m007_deploy.backend import BackendNotRun, XRTBackend


def identity():
    return Identity(**{key: hashlib.sha256(("synthetic-test-" + key).encode()).hexdigest()
                       for key in ("model", "graph", "numeric", "layout", "build")})


def request():
    return Request(0xFEDCBA9876543210, 0x87654321, identity(), 1,
                   (1,) * 128, (127, 3, 3) + (0,) * 13,
                   (1, 1, 1) + (0,) * 13, 3, 0x100000000, 0x200000000)


def independent_frame(req, kind=1, status=0, completed=0):
    """Expected wire bytes use explicit frozen offsets, not the DUT codec."""
    wire = bytearray(512)
    wire[0:8] = b"LAYAM7\0\0"
    struct.pack_into("<HHIQIIIIII", wire, 8, 1, 512, kind, req.request_id,
                     req.generation, req.qtype, req.candidate_count, status, completed, 0)
    struct.pack_into("<QQQQ", wire, 48, req.h0_address, req.h0_span,
                     req.tail_address, req.tail_span)
    for i, name in enumerate(("model", "graph", "numeric", "layout", "build")):
        wire[80 + i * 32:112 + i * 32] = bytes.fromhex(getattr(req.identity, name))
    wire[240:368] = bytes(req.attention_mask)
    struct.pack_into("<16i", wire, 368, *req.markers)
    wire[432:448] = bytes(req.marker_mask)
    return bytes(wire)


class ContractTests(unittest.TestCase):
    def test_independent_wire_and_u64_roundtrip(self):
        req = request()
        self.assertEqual(encode_request(req), independent_frame(req))
        self.assertEqual(decode_request(independent_frame(req), req.identity), req)
        self.assertEqual(OFFSETS["markers"], 368)
        self.assertEqual(len(encode_request(req)), 512)

    def test_duplicate_markers_and_slot_order(self):
        req = request()
        req.validate()
        self.assertEqual(decode_request(encode_request(req), req.identity).markers[:3],
                         (127, 3, 3))

    def test_constructor_owns_immutable_sequence_fields(self):
        original = request()
        mask = list(original.attention_mask)
        markers = list(original.markers)
        valid = list(original.marker_mask)
        req = replace(original, attention_mask=mask, markers=markers, marker_mask=valid)
        self.assertEqual(decode_request(encode_request(req), req.identity), req)
        mask[0], markers[0], valid[0] = 0, 128, 0
        self.assertEqual(req, original)
        ready = independent_frame(req, kind=2, completed=17408)
        self.assertEqual(validate_tail_ready(ready, bytes(69632), req), bytes(69632))

    def test_qtypes_and_candidate_counts(self):
        for qtype in (0, 1, 2):
            for count in ((2,) if qtype == 2 else (1, 16)):
                replace(request(), qtype=qtype, markers=(0,) * 16,
                        marker_mask=(1,) * count + (0,) * (16 - count),
                        candidate_count=count).validate()
        for change in ({"qtype": -1}, {"qtype": 3}, {"qtype": 256},
                       {"candidate_count": 0}, {"candidate_count": 17},
                       {"candidate_count": 2}):
            with self.subTest(change=change), self.assertRaises(ContractError):
                replace(request(), **change).validate()
        for count in (1, 3, 16):
            with self.assertRaises(ContractError):
                replace(request(), qtype=2, candidate_count=count,
                        markers=(0,) * 16, marker_mask=(1,) * count + (0,) * (16 - count)).validate()

    def test_no_candidate_or_marker_truncation(self):
        for markers, mask in (((0,) * 17, (1,) * 17), ((0,) * 15, (1,) * 15)):
            with self.assertRaises(ContractError):
                canonical_request(markers=markers, marker_mask=mask)

    def test_invalid_slot_explicit_canonicalization(self):
        req = request()
        values = vars(req).copy()
        values["markers"] = (127, 3, 3) + (2147483647,) * 13
        out = canonical_request(**values)
        self.assertEqual(out.markers, req.markers)
        with self.assertRaises(ContractError):
            replace(req, markers=values["markers"]).validate()

    def test_active_marker_boundaries(self):
        for pos in (-1, 128, 2147483647):
            with self.subTest(pos=pos), self.assertRaises(ContractError):
                replace(request(), markers=(pos, 3, 3) + (0,) * 13).validate()
        request().validate()  # 127 is accepted.

    def test_mask_rules_without_uint8_coercion(self):
        for mask in ((0,) * 128, (256,) + (1,) * 127,
                     (1.0,) + (1,) * 127, (1,) * 127):
            with self.subTest(mask=mask[:2]), self.assertRaises(ContractError):
                replace(request(), attention_mask=mask).validate()
        with self.assertRaises(ContractError):
            replace(request(), attention_mask=(1,) * 127 + (0,)).validate()
        for mask in ((0,) * 16, (256,) + (0,) * 15, (1,) * 17):
            with self.assertRaises(ContractError):
                replace(request(), marker_mask=mask).validate()

    def test_identity_each_field(self):
        for name in ("model", "graph", "numeric", "layout", "build"):
            expected = replace(identity(), **{name: "1" * 64})
            with self.subTest(name=name), self.assertRaises(ContractError):
                decode_request(independent_frame(request()), expected)
        for value in ("0" * 64, "x" * 64, "a" * 63, "A" * 64):
            with self.assertRaises(ContractError):
                replace(identity(), build=value).validate()

    def test_metadata_length_magic_version_reserved(self):
        good = independent_frame(request())
        for bad in (good[:-1], good + b"\0"):
            with self.assertRaises(ContractError):
                decode_request(bad, identity())
        for offset in (0, 8, 10, 44, 448, 511):
            bad = bytearray(good)
            bad[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ContractError):
                decode_request(bytes(bad), identity())

    def test_address_overflow_alignment_overlap_and_bo_bounds(self):
        bads = ({"h0_address": 1 << 64}, {"h0_address": (1 << 64) - 64},
                {"tail_address": -64}, {"tail_address": request().h0_address},
                {"tail_address": request().h0_address + 64},
                {"h0_address": 0}, {"h0_address": 65},
                {"h0_span": 524287}, {"tail_span": 69633},
                {"generation": 1 << 32}, {"request_id": -1})
        for bad in bads:
            with self.subTest(bad=bad), self.assertRaises(ContractError):
                replace(request(), **bad).validate()
        req = request()
        req.validate(BufferRegion(req.h0_address, req.h0_span),
                     BufferRegion(req.tail_address, req.tail_span))
        for region in (BufferRegion(req.h0_address, req.h0_span - 1),
                       BufferRegion(req.h0_address + 64, req.h0_span)):
            with self.assertRaises(ContractError):
                req.validate(h0_region=region)

    def test_tail_ready_identity_retirement_and_error(self):
        req, payload = request(), bytes(69632)
        ready = independent_frame(req, kind=2, completed=17408)
        self.assertEqual(validate_tail_ready(ready, payload, req), payload)
        for stale in (replace(req, request_id=req.request_id - 1),
                      replace(req, generation=req.generation - 1),
                      replace(req, qtype=0)):
            with self.assertRaises(ContractError):
                validate_tail_ready(ready, payload, stale)
        for status, count in ((1, 17408), (0, 17407), (0, 0)):
            with self.assertRaises(DeviceResultError):
                validate_tail_ready(independent_frame(req, 2, status, count), payload, req)
        for bad in (payload[:-1], payload + b"\0"):
            with self.assertRaises(ContractError):
                validate_tail_ready(ready, bad, req)
        with self.assertRaises(ContractError):
            validate_tail_ready(encode_request(req), payload, req)

    def test_device_never_succeeds_or_falls_back(self):
        with self.assertRaises(BackendNotRun) as caught:
            XRTBackend().execute(request(), bytes(524288))
        self.assertEqual(caught.exception.status, "NOT_RUN")

    def test_h0_token_validation_and_cpu_identity_binding(self):
        import numpy as np
        from m007_deploy.cpu_contract import (prepare_h0, finish_tail_cpu_contract,
            MODEL_SHA, GRAPH_SHA, REFERENCE_SHA)
        for ids in (np.zeros(127, dtype="<i4"), np.zeros(129, dtype="<i4"),
                    np.full(128, 50368, dtype="<i4"), np.full(128, -1, dtype="<i4"),
                    np.zeros(128, dtype="<f4"), np.full(128, 1 << 63, dtype="<u8")):
            with self.assertRaises(ContractError):
                prepare_h0(ids, lambda name: self.fail("invalid input read weight"))
        class Weights:
            model_sha256 = MODEL_SHA
            def __call__(self, name):
                raise AssertionError("should reject before weights")
        with self.assertRaises(ContractError):
            finish_tail_cpu_contract(bytes(69632), request(), Weights())

    def test_finite_input_overflow_is_error_not_probability_fallback(self):
        import numpy as np
        from m007_deploy.contract import SCHEMA_SHA256
        from m007_deploy.cpu_contract import (finish_tail_cpu_contract, MODEL_SHA,
                                              GRAPH_SHA, REFERENCE_SHA)
        bound = replace(request(), identity=Identity(MODEL_SHA, GRAPH_SHA,
                         REFERENCE_SHA, SCHEMA_SHA256, "1" * 64))
        class Weights:
            model_sha256 = MODEL_SHA
            def __call__(self, name):
                raise AssertionError("overflow should precede weight read")
        payload = np.full((17, 1024), np.finfo(np.float32).max, dtype="<f4").tobytes()
        with np.errstate(over="ignore"), self.assertRaises(ArithmeticError):
            finish_tail_cpu_contract(payload, bound, Weights())

    def test_independent_gather_and_raw_cls_ownership(self):
        import numpy as np
        from m007_deploy.cpu_contract import gather_tail_cpu_contract, parse_tail, strict_reference
        hidden = np.arange(128 * 1024, dtype="<f4").reshape(128, 1024) / np.float32(1024)
        expected = b"".join(hidden[row].tobytes() for row in (127, 3, 3) + (0,) * 14)
        actual = gather_tail_cpu_contract(hidden, request())
        self.assertEqual(actual, expected)
        tail = parse_tail(actual)
        before = tail[16].tobytes()
        norm = strict_reference().layernorm_many(tail[:16])
        self.assertNotEqual(norm[0].tobytes(), tail[0].tobytes())
        self.assertEqual(tail[16].tobytes(), before)
        tail[:16] = norm
        self.assertEqual(tail[16].tobytes(), before)
        for bad in (actual[:-1], actual + b"\0"):
            with self.assertRaises(ContractError):
                parse_tail(bad)
        corrupt = bytearray(actual)
        struct.pack_into("<I", corrupt, 0, 0x7f800000)
        with self.assertRaises(ArithmeticError):
            parse_tail(bytes(corrupt))


if __name__ == "__main__":
    unittest.main(verbosity=2)
