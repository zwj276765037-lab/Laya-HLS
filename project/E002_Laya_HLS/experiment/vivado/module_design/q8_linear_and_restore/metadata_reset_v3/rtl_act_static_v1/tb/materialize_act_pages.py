#!/usr/bin/env python3
"""Freeze ACT-only physical AXI pages from the existing model and gold files.

This program reads the complete original package but writes only under its new
fixtures directory.  It never derives expected numeric values from DUT output.
"""

import argparse
import hashlib
import json
import pathlib
import struct

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[5]
OUT = HERE.parent / "fixtures"
MODEL = ROOT / "build/model-attention-rtl-repair-20261008"
Q8 = ROOT / "vivado/module_design/q8_linear_and_restore"
FROZEN = Q8 / "runs/fixture_act_v1/fixture"
DESCRIPTORS = Q8 / "runs/descriptor_act_v1"
RELEASE = ROOT / "results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_dual_lite_design_preparation_release.json"
RELEASE_SHA = "ac099d5cc31f8a3c9c1144c6f30d56ff2f8bd741d9eede1228c30d39732b50d9"
PAGE = 4096
SENTINEL = 0xA5

MODEL_HASHES = {
    "manifest.json": "128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa",
    "laya_model_layout_generated.h": "c2fd1da7b00c7361d616ac15af431dea14c4979ac2aded6b37888fb1d633630a",
    "embedding.bin": "3922fc9f0394170269e49ef37e22ee21c72c3f2d1c510510239da159c3a6174b",
    "w_q0.bin": "be5ab09ff91d4a9dd56c3dbc9b84c138658b1a5ce3a274806b841a739f96970e",
    "w_q1.bin": "b067525e7766a9f07e505a1e593548d3057f4bb5f12d1f7578c8538e2ee1b6ca",
    "w_scale.bin": "ea159816b322f58b970d80cd0142ccd16cc7531de8ee5ed9108fc4edf2a2e898",
    "aux.bin": "66189c9c75216650eca75a08a4f9b6ede1ab315a49ad05f71a409d2eaaa4f6c0",
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def file_record(path):
    p = pathlib.Path(path)
    data = p.read_bytes()
    return {"path": str(p), "bytes": len(data), "sha256": sha(data)}


def verify(path, size=None, expected=None):
    data = pathlib.Path(path).read_bytes()
    if size is not None and len(data) != size:
        raise ValueError(f"size mismatch: {path}")
    if expected is not None and sha(data) != expected:
        raise ValueError(f"hash mismatch: {path}")
    return data


def put(relative, data):
    path = OUT / relative
    if path.exists():
        raise FileExistsError(f"fresh materialization required: {path}")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    return {"relative_path": str(path.relative_to(OUT)), "bytes": len(data), "sha256": sha(data)}


def page(payload=b"", offset=0):
    if offset < 0 or offset + len(payload) > PAGE:
        raise ValueError("page placement out of bounds")
    out = bytearray([SENTINEL] * PAGE)
    out[offset:offset + len(payload)] = payload
    return bytes(out)


def word(data, index):
    return struct.unpack_from("<I", data, index * 4)[0]


def setword(data, index, value):
    struct.pack_into("<I", data, index * 4, value)


def command(name, base, words=None, byte_xors=None, activation="b0",
            scale="normal", aux="normal", expected_status=None, spec=None):
    base_file = base if base.endswith(".bin") else f"{base}.bin"
    raw = bytearray(verify(DESCRIPTORS / base_file, 512))
    changes = []
    for k, v in (words or {}).items():
        i = int(k)
        prior = word(raw, i)
        setword(raw, i, int(v))
        changes.append({"space": "descriptor", "byte_offset": i * 4,
                        "before_le32": prior, "after_le32": int(v)})
    for offset, mask in (byte_xors or []):
        prior = raw[offset]
        raw[offset] ^= mask
        changes.append({"space": "descriptor", "byte_offset": offset,
                        "before": prior, "after": raw[offset], "xor": mask})
    desc = put(f"commands/{name}/descriptor_page.bin", page(raw))
    return {"case": name, "base": base, "descriptor_page": desc,
            "descriptor_payload_sha256": sha(raw), "mutations": changes,
            "activation_variant": activation, "scale_variant": scale,
            "aux_variant": aux, "expected_status": expected_status,
            "expected_state_spec": spec or {}}


class HeaderOracle:
    """Command-level contract model; all fields are fixed before RTL runs."""

    def __init__(self):
        self.reset()

    def reset(self):
        self.last = self.w_max = self.a8_max = self.ps_max = self.dst_max = 0
        self.w_epoch = self.ps_epoch = 0
        self.w_valid = False
        self.a_state = self.ps_state = self.dst_state = 6
        self.w_loads = self.w_uses = self.w_reuses = 0

    def expected(self, entry, gold):
        name = entry["case"]
        d = (OUT / entry["descriptor_page"]["relative_path"]).read_bytes()
        dw = [word(d, i) for i in range(128)]
        status = entry["expected_status"]
        detail = 0
        bad = 0xffffffffffffffff
        done = elements = unit = quant = quant_status = 0
        linear_started = load_started = phase = 0
        counts = {p: 0 for p in ("descriptor", "w_q0", "w_q1", "w_scale", "aux",
                                   "activation", "out0", "out1", "observed")}
        counts["descriptor"] = 512
        qgroups = qinputs = issues = retired = writes = macs = 0
        trace_bias = trace_enable = trace_final = trace_groups = trace_words = 0
        is_load = dw[2] == 0
        is_run = dw[2] == 1
        preflight = (name.startswith("legal_01_") or name.startswith("legal_02_") or
                     name.startswith("legal_05_") or name.startswith("identity_00_") or
                     name.startswith("identity_01_") or name.startswith("identity_02_") or
                     name.startswith("identity_03_") or name.startswith("identity_04_") or
                     name.startswith("identity_05_") or name.startswith("identity_06_") or
                     name.startswith("identity_07_") or name.startswith("identity_08_") or
                     name.startswith("identity_09_") or
                     name.startswith("identity_20_") or name.startswith("identity_21_"))
        if name.startswith("identity_21_"):
            self.reset()
        if preflight:
            if status == 1:
                detail = 0x00000004
            elif status == 2:
                detail = 0x04000004
            elif status == 3:
                detail = (7 << 24) | ((dw[9] & 255) << 16) | 5
            elif status == 7:
                detail = 0x07000004
            else:
                raise ValueError(f"unexpected preflight status {name}: {status}")
        elif is_load:
            self.last = dw[8]
            self.w_max = self.w_epoch = dw[29]
            self.w_valid = False
            self.w_uses = 0
            done = dw[8]
            load_started = 1
            phase = 1
            counts["aux"] = 128
            if status != 2:
                counts["w_q0"] = 2048
                counts["w_scale"] = 128
                counts["aux"] = 136
            if status == 0:
                self.w_valid = True
                self.w_loads += 1
                elements, unit, phase = 2176, 3, 0
            elif status == 2:
                detail = 0x04000004
            elif status == 6:
                detail = 0x0780000f
                bad = 1
            else:
                raise ValueError(f"unexpected claimed LOAD status {name}: {status}")
        elif is_run:
            self.a8_max += 1
            self.last = dw[31]
            quant = dw[31]
            phase = 2
            counts["activation"] = 1024
            if status == 6:
                self.a_state = 6
                done = dw[31]
                unit = 2
                detail = 0x0720000f
                bad = 2
                quant_status = 6
            elif status == 0:
                self.a_state = 2
                self.last = dw[8]
                self.ps_max = self.ps_epoch = dw[30]
                self.dst_max = dw[27]
                self.ps_state = self.dst_state = 2
                if self.w_uses:
                    self.w_reuses += 1
                self.w_uses += 1
                done = dw[8]
                elements, unit = 2, 1
                linear_started = 1
                counts["out0"] = 8
                qgroups, qinputs, issues, retired, writes, macs = 8, 256, 8, 8, 2, 512
                phase = 0
                if dw[3]:
                    batch = 1 if entry["activation_variant"] == "b1" else 0
                    final = gold[f"b{batch}"]["final_bits"][dw[61]]
                    bias = gold["bias_bits"][dw[61]]
                    trace_bias, trace_enable, trace_final, trace_groups = bias, 1, final, 8
                    trace_words = 64 + 4 + 64
            else:
                raise ValueError(f"unexpected claimed RUN status {name}: {status}")
        else:
            raise ValueError(f"command kind is neither LOAD nor RUN: {name}")
        counts["observed"] = (256 + trace_words) * 4
        h = [0] * 256
        h[0:14] = [0x51384f42, 1, dw[2], status, detail, bad & 0xffffffff,
                   bad >> 32, dw[8], self.last, done, status if done else 0,
                   1 if done else 0, elements, unit]
        h[14:29] = [dw[4], dw[5], dw[6], dw[7], dw[12], dw[13], dw[10],
                    dw[11], dw[14], dw[15], dw[16], dw[17], dw[18], dw[19], dw[20]]
        h[29:40] = [self.w_epoch, self.a8_max, self.ps_epoch,
                    dw[21], dw[22], dw[23], dw[24], dw[25], dw[26], dw[27], dw[28]]
        h[40:50] = [2 if self.w_valid else 6, self.a_state, self.ps_state, self.dst_state,
                    self.w_max, self.a8_max, self.ps_max, self.dst_max,
                    self.w_loads, self.w_reuses]
        h[50:58] = [qgroups, qinputs, issues, 0, retired, writes, macs, 0]
        h[58:64] = [dw[60] if dw[3] else 0, dw[61] if dw[3] else 0,
                    trace_bias, trace_enable, trace_final, trace_groups]
        for i, p in enumerate(counts):
            h[64 + 4*i] = counts[p]
            h[64 + 4*i + 2] = counts[p]
        h[100:116] = dw[32:48]
        h[116:122] = [quant, quant_status if quant else 0,
                      1 if quant else 0, linear_started, load_started, phase]
        if len(h) != 256 or any(not 0 <= x < (1 << 32) for x in h):
            raise ValueError("invalid 256-word expected header")
        return h


def main():
    argp = argparse.ArgumentParser()
    argp.add_argument("--check-only", action="store_true")
    args = argp.parse_args()
    release = verify(RELEASE, expected=RELEASE_SHA)
    design = json.loads(release)
    for rec in design["bound_baselines"]:
        verify(rec["path"], rec["bytes"], rec["sha256"])
    model_records = []
    for name, expected in MODEL_HASHES.items():
        data = verify(MODEL / name, expected=expected)
        model_records.append({"path": str(MODEL / name), "bytes": len(data), "sha256": expected})
    if args.check_only:
        print(json.dumps({"release": RELEASE_SHA, "bound_baselines": len(design["bound_baselines"]),
                          "complete_model_files": len(model_records), "ready_to_materialize": True}))
        return
    if OUT.exists():
        raise FileExistsError(f"new fixture output must be fresh: {OUT}")

    q0 = (MODEL / "w_q0.bin").read_bytes()
    scale = (MODEL / "w_scale.bin").read_bytes()
    aux = (MODEL / "aux.bin").read_bytes()
    q0_start, scale_start, bias_start = 184680448, 23085056, 617664
    q_payload = verify(FROZEN / "act_w_q0_2048.bin", 2048)
    scale_payload = verify(FROZEN / "act_w_scale_128.bin", 128)
    bias_payload = verify(FROZEN / "act_bias_8.bin", 8)
    if q0[q0_start:q0_start + 2048] != q_payload:
        raise ValueError("original q0 extent does not match frozen ACT block")
    if scale[scale_start:scale_start + 128] != scale_payload:
        raise ValueError("original scale extent does not match frozen ACT block")
    if aux[bias_start:bias_start + 8] != bias_payload:
        raise ValueError("original bias extent does not match frozen ACT block")
    if q0_start % PAGE or scale_start % PAGE:
        raise ValueError("weight offset must be page aligned")
    if bias_start // PAGE != 0x96000 // PAGE or bias_start % PAGE != 3264:
        raise ValueError("bias page/slot mismatch")

    ports = design["interfaces"]["ports"]
    if sum(p["page_capacity"] for p in ports) != 41:
        raise ValueError("expected exactly 41 physical pages")
    page_records = []
    source_extents = []
    payloads = {
        "descriptor": {0: page(verify(DESCRIPTORS / "load_w.bin", 512))},
        "w_q0": {0: page(q_payload)},
        "w_q1": {0: page()},
        "w_scale": {0: page(scale_payload)},
        "aux": {0: page(aux[:128]), 1: page(bias_payload, 3264)},
        "activation": {0: page(verify(FROZEN / "act_b0_input_1024.bin", 1024))},
        "out0": {0: page()}, "out1": {0: page()},
        "observed": {i: page() for i in range(32)},
    }
    source_extents.extend([
        {"file": "w_q0.bin", "offset": q0_start, "bytes": 2048, "port": "w_q0", "page": 0, "page_offset": 0},
        {"file": "w_scale.bin", "offset": scale_start, "bytes": 128, "port": "w_scale", "page": 0, "page_offset": 0},
        {"file": "aux.bin", "offset": 0, "bytes": 128, "port": "aux", "page": 0, "page_offset": 0},
        {"file": "aux.bin", "offset": bias_start, "bytes": 8, "port": "aux", "page": 1, "page_offset": 3264},
    ])
    for p in ports:
        name = p["name"]
        if len(payloads[name]) != p["page_capacity"]:
            raise ValueError(f"page capacity mismatch: {name}")
        for slot in range(p["page_capacity"]):
            data = payloads[name][slot]
            record = put(f"pages/{name}_{slot:02d}.bin", data)
            page_records.append({"port": name, "slot": slot,
                                 "physical_base": p["physical_page_bases"][slot],
                                 "logical_offset": p["logical_page_offsets"][slot],
                                 **record})

    variants = {}
    b0 = verify(FROZEN / "act_b0_input_1024.bin", 1024)
    b1 = verify(FROZEN / "act_b1_input_1024.bin", 1024)
    nan = bytearray(b0)
    for i in (2, 7):
        nan[4 * i:4 * i + 4] = bytes.fromhex("0000c07f")
    variants["activation_b0"] = put("variants/activation_b0.bin", page(b0))
    variants["activation_b1"] = put("variants/activation_b1.bin", page(b1))
    variants["activation_nan_i2_i7"] = put("variants/activation_nan_i2_i7.bin", page(nan))
    bad_scale = bytearray(payloads["w_scale"][0])
    for i in (2, 16):
        bad_scale[i:i + 2] = b"\x00\x7c"
    variants["scale_fault"] = put("variants/scale_fault.bin", bytes(bad_scale))
    bad_aux = bytearray(payloads["aux"][1])
    bad_aux[3264:3268] = b"\x00\x00\xc0\x7f"
    variants["aux_bias_fault"] = put("variants/aux_bias_fault.bin", bytes(bad_aux))

    legal = [
        command("legal_00_load", "load_w", expected_status=0),
        command("legal_01_high_src_id", "run_b0_trace_n0", words={21: 0x10A}, expected_status=3),
        command("legal_02_bad_model_tag", "run_b0_trace_n0", byte_xors=[(128, 1)], expected_status=2),
        command("legal_03_run_b0_n0", "run_b0_trace_n0", expected_status=0),
        command("legal_04_run_b1_n1", "run_b1_trace_n1", activation="b1", expected_status=0),
        command("legal_05_replay", "run_b1_trace_n1", activation="b1", expected_status=7),
        command("legal_06_trace_off", "run_b0_trace_off", expected_status=0),
        command("legal_07_quant_nan", "run_b0_trace_off", words={31: 8, 8: 9, 30: 4, 27: 4},
                activation="nan_i2_i7", expected_status=6),
        command("legal_08_recover", "run_b0_trace_off", words={31: 9, 8: 10, 30: 4, 27: 4},
                expected_status=0),
    ]
    fault = [
        command("fault_00_bad_load", "load_w", scale="fault", aux="bias_fault", expected_status=6),
        command("fault_01_recover_load", "load_w", words={8: 2, 29: 2, 27: 2}, expected_status=0),
        command("fault_02_run", "run_b0_trace_n0", words={31: 3, 8: 4, 29: 2}, expected_status=0),
    ]
    identity = []
    for i, spec in enumerate(design["suites"][2]["commands"]):
        words = dict(spec.get("descriptor_words", {}))
        xors = []
        for mutation in spec.get("mutations", []):
            if "word" in mutation:
                if "value" in mutation:
                    words[int(mutation["word"])] = int(mutation["value"])
                elif "xor" in mutation:
                    base = verify(DESCRIPTORS / spec["base"], 512)
                    words[int(mutation["word"])] = word(base, int(mutation["word"])) ^ int(mutation["xor"])
            else:
                xors.append((int(mutation["byte_offset"]), int(mutation["xor"])))
        name = f"identity_{i:02d}_{spec['case']}"
        aux_variant = "normal"
        if "aux_byte_xor" in spec:
            byte_xor = spec["aux_byte_xor"]
            modified = bytearray(payloads["aux"][0])
            modified[int(byte_xor["offset"])] ^= int(byte_xor["xor"])
            aux_variant = name
            variants[f"aux_{name}"] = put(f"variants/aux_{name}.bin", bytes(modified))
        identity.append(command(name, spec["base"], words=words, byte_xors=xors,
                                aux=aux_variant, expected_status=spec["status"], spec=spec))

    if (len(legal), len(fault), len(identity)) != (9, 3, 24):
        raise ValueError("command counts changed")
    all_commands = legal + fault + identity
    gold = {
        "b0": {"final_bits": struct.unpack("<2I", verify(FROZEN / "act_b0_expected_8.bin", 8)),
               "q": verify(FROZEN / "act_b0_a8_q_256.bin", 256),
               "scale": verify(FROZEN / "act_b0_a8_scale_16.bin", 16),
               "trace": verify(DESCRIPTORS / "act_b0_selected_trace_256.bin", 256)},
        "b1": {"final_bits": struct.unpack("<2I", verify(FROZEN / "act_b1_expected_8.bin", 8)),
               "q": verify(FROZEN / "act_b1_a8_q_256.bin", 256),
               "scale": verify(FROZEN / "act_b1_a8_scale_16.bin", 16),
               "trace": verify(DESCRIPTORS / "act_b1_selected_trace_256.bin", 256)},
        "bias_bits": struct.unpack("<2I", bias_payload),
    }
    expected_files = []
    for suite_name, entries in (("legal", legal), ("fault_load", fault), ("identity_reset", identity)):
        oracle = HeaderOracle()
        for entry in entries:
            header = oracle.expected(entry, gold)
            spec = entry["expected_state_spec"]
            if "last_task" in spec and header[8] != spec["last_task"]:
                raise ValueError(f"independent last_task mismatch: {entry['case']}")
            if "done_task" in spec and header[9] != spec["done_task"]:
                raise ValueError(f"independent done_task mismatch: {entry['case']}")
            if "detail" in spec and header[4] != int(spec["detail"], 16):
                raise ValueError(f"independent detail mismatch: {entry['case']}")
            if "w_max_and_epoch" in spec and (header[29] != spec["w_max_and_epoch"] or
                                               header[44] != spec["w_max_and_epoch"]):
                raise ValueError(f"independent W epoch mismatch: {entry['case']}")
            for key, offset in (("w_epoch", 29), ("w_max", 44), ("w_loads", 48),
                                ("w_state", 40)):
                if key in spec and header[offset] != spec[key]:
                    raise ValueError(f"independent {key} mismatch: {entry['case']}")
            if "a8_ps_dst_max" in spec and [header[i] for i in (45, 46, 47)] != spec["a8_ps_dst_max"]:
                raise ValueError(f"independent A8/PS/DST max mismatch: {entry['case']}")
            if spec.get("all_claims_loads_reuses_zero") and any(header[i] for i in (44, 45, 46, 47, 48, 49)):
                raise ValueError(f"claims/loads/reuses not reset: {entry['case']}")
            if "w_a8_ps_dst_states" in spec and [header[i] for i in (40, 41, 42, 43)] != spec["w_a8_ps_dst_states"]:
                raise ValueError(f"cache states not reset: {entry['case']}")
            header_bytes = struct.pack("<256I", *header)
            expected_observed = bytearray([SENTINEL] * (32 * PAGE))
            expected_observed[:1024] = header_bytes
            is_trace = header[63] == 8
            if is_trace:
                batch = "b1" if entry["activation_variant"] == "b1" else "b0"
                expected_observed[1024:1280] = gold[batch]["q"]
                expected_observed[66560:66576] = gold[batch]["scale"]
                expected_observed[70656:70912] = gold[batch]["trace"]
            expected_out0 = bytearray([SENTINEL] * PAGE)
            expected_out1 = bytearray([SENTINEL] * PAGE)
            is_successful_run = header[2] == 1 and header[3] == 0
            if is_successful_run:
                batch = "b1" if entry["activation_variant"] == "b1" else "b0"
                expected_out0[:8] = struct.pack("<2I", *gold[batch]["final_bits"])
            entry["expected_header"] = put(f"commands/{entry['case']}/header_256.bin", header_bytes)
            entry["expected_observed_32_pages"] = put(
                f"commands/{entry['case']}/observed_131072.bin", bytes(expected_observed))
            entry["expected_out0_page"] = put(
                f"commands/{entry['case']}/out0_4096.bin", bytes(expected_out0))
            entry["expected_out1_page"] = put(
                f"commands/{entry['case']}/out1_4096.bin", bytes(expected_out1))
            entry["expected_port_useful_bytes"] = {
                p: header[64 + 4*i] for i, p in enumerate(("descriptor", "w_q0", "w_q1", "w_scale",
                    "aux", "activation", "out0", "out1", "observed"))}
            entry["mode"] = suite_name
            expected_files.extend((entry["expected_header"], entry["expected_observed_32_pages"],
                                   entry["expected_out0_page"], entry["expected_out1_page"]))
    all_records = (page_records + list(variants.values()) +
                   [c["descriptor_page"] for c in all_commands] + expected_files)
    expected = {
        "b0": {k: file_record(FROZEN / name) for k, name in {
            "final": "act_b0_expected_8.bin", "a8_q": "act_b0_a8_q_256.bin",
            "a8_scale": "act_b0_a8_scale_16.bin"}.items()},
        "b1": {k: file_record(FROZEN / name) for k, name in {
            "final": "act_b1_expected_8.bin", "a8_q": "act_b1_a8_q_256.bin",
            "a8_scale": "act_b1_a8_scale_16.bin"}.items()},
        "selected_trace_b0": file_record(DESCRIPTORS / "act_b0_selected_trace_256.bin"),
        "selected_trace_b1": file_record(DESCRIPTORS / "act_b1_selected_trace_256.bin"),
    }
    manifest = {
        "schema": "q8_metadata_reset_v3_act_41_page_fixture_manifest_v1",
        "release": file_record(RELEASE),
        "original_model_files": model_records,
        "frozen_baselines_rehashed": len(design["bound_baselines"]),
        "page_count": len(page_records),
        "total_page_bytes": len(page_records) * PAGE,
        "pages": page_records,
        "original_source_extents": source_extents,
        "sentinel": SENTINEL,
        "variants": variants,
        "command_counts": {"legal": len(legal), "fault_load": len(fault), "identity_reset": len(identity)},
        "commands": {"legal": legal, "fault_load": fault, "identity_reset": identity},
        "independent_numeric_gold": expected,
        "generated_file_count_excluding_manifest": len(all_records),
        "generated_files_excluding_manifest": all_records,
        "expected_header_status": "ALL_36_COMMANDS_256_WORD_SPEC_TABLE_MATERIALIZED",
    }
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"pages": len(page_records), "commands": len(all_commands),
                      "generated_files": len(all_records), "output": str(OUT / 'manifest.json')}))


if __name__ == "__main__":
    main()
