#!/usr/bin/env python3
"""Bounded host check of L13M LN and Q8S2 Wi/Down source compatibility.

This emits a diagnostic W-wire encoding for the existing canonical package.
It does not validate an RTL adapter, live BO binding, or a production request.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import struct
from pathlib import Path


ROLES = ("embedding", "w_q0", "w_q1", "w_scale", "aux")
ROLE_IDS = (0, 2, 3, 4, 5)
CASES = (("wi", "mlp_wi.0.weight", "wi_w", 1024, 5248),
         ("down", "mlp_wo.0.weight", "w", 2624, 1024))


def need(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def sha_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        while block := stream.read(8 << 20):
            h.update(block)
    return h.hexdigest()


def item(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha_file(path)}


def at(path: Path, offset: int, size: int) -> bytes:
    need(offset >= 0 and size >= 0 and offset + size <= path.stat().st_size,
         f"BO range {path}:{offset}+{size}")
    with path.open("rb") as stream:
        stream.seek(offset)
        raw = stream.read(size)
    need(len(raw) == size, f"short BO read {path}")
    return raw


def load_hex_words(path: Path, width: int) -> bytes:
    lines = path.read_text().splitlines()
    need(bool(lines), f"empty fixture {path}")
    out = bytearray()
    for i, line in enumerate(lines):
        need(len(line) == 2 * width, f"fixture word width {path}:{i}")
        out += bytes.fromhex(line)[::-1]
    return bytes(out)


def emit_hex_words(path: Path, raw: bytes, width: int) -> None:
    need(len(raw) % width == 0, f"new fixture alignment {path}")
    with path.open("w") as stream:
        for off in range(0, len(raw), width):
            stream.write(raw[off:off + width][::-1].hex() + "\n")


def sv_constant(path: Path, name: str, bits: int) -> bytes:
    text = path.read_text()
    match = re.search(rf"\b{name}\s*=\s*{bits}'h([0-9a-fA-F]+)", text)
    need(match is not None, f"missing generated {name}")
    return int(match.group(1), 16).to_bytes(bits // 8, "little")


def array16(header: str, name: str) -> bytes:
    match = re.search(rf"\b{name}\s*\[16\]\s*=\s*\{{([^}}]+)\}}", header)
    need(match is not None, f"missing {name}")
    values = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]+)", match.group(1)))
    need(len(values) == 16, f"bad {name}")
    return values


def header_record(header: str, name: str) -> dict:
    pat = (r'\{"' + re.escape(name) + r'", \{(\d+), (\d+)\}, '
           r'(\d+), (\d+), (\d+), (\d+), '
           r'\{(\d+), (\d+)\}, \{(\d+), (\d+)\}, '
           r'(\d+), (\d+), (\d+), (\d+), (\d+), (\d+)')
    match = re.search(pat, header)
    need(match is not None, f"missing generated weight {name}")
    fields = ("family", "layer", "K", "N", "dtype", "bias_kind",
              "q0_offset", "q1_offset", "q0_span", "q1_span",
              "scale_offset", "scale_span", "unused0", "unused1",
              "bias_offset", "bias_span")
    return dict(zip(fields, (int(x) for x in match.groups())))


def u32(raw: bytes, offset: int) -> int:
    return struct.unpack_from("<I", raw, offset)[0]


def u64(raw: bytes, offset: int) -> int:
    return struct.unpack_from("<Q", raw, offset)[0]


def put32(raw: bytearray, offset: int, value: int) -> None:
    struct.pack_into("<I", raw, offset, value)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--production", required=True, type=Path)
    ap.add_argument("--legacy-q8s2", required=True, type=Path)
    ap.add_argument("--at035-fixtures", required=True, type=Path)
    ap.add_argument("--generated-sv", required=True, type=Path)
    ap.add_argument("--output", required=True, type=Path)
    args = ap.parse_args()
    prod, old, fixtures, sv, out = (x.resolve() for x in
                                     (args.production, args.legacy_q8s2,
                                      args.at035_fixtures, args.generated_sv,
                                      args.output))
    need(not out.exists(), "output must be fresh")
    pm_path, om_path = prod / "manifest.json", old / "manifest.json"
    pm, om = json.loads(pm_path.read_text()), json.loads(om_path.read_text())
    need(pm["schema"] == om["schema"] == "laya-model-p2-v1", "package schema")
    need(om.get("candidate_schema") == "laya-q8-session-v2-package", "Q8S2 source schema")
    need(pm["source_model"]["sha256"] == om["source_model"]["sha256"], "GGUF declaration")
    need(pm["tags"]["model"] == om["tags"]["model"] and
         pm["tags"]["numeric"] == om["tags"]["numeric"], "model/numeric tags")
    need(len(pm["weights"]) == 124 and len(pm["tensors"]) == 153, "production inventory")
    need(sha_file(Path(pm["source_model"]["path"])) == pm["source_model"]["sha256"],
         "actual GGUF hash")
    inputs = [item(pm_path), item(om_path), item(sv), item(Path(pm["source_model"]["path"]))]
    package_bos = []
    for role in ROLES:
        p, q = prod / pm["bo"][role]["file"], old / om["bo"][role]["file"]
        a, b = item(p), item(q)
        need(a["bytes"] == pm["bo"][role]["size"] and
             a["sha256"] == pm["bo"][role]["sha256"], f"canonical {role} BO")
        need(b["bytes"] == om["bo"][role]["size"] and
             b["sha256"] == om["bo"][role]["sha256"], f"legacy {role} BO")
        need(a["bytes"] == b["bytes"], f"BO capacity {role}")
        if role != "aux":
            need(a["sha256"] == b["sha256"], f"payload BO bytes {role}")
        package_bos.append({"role": role, "canonical": a, "legacy": b,
                            "equal": a["sha256"] == b["sha256"]})
        inputs.extend((a, b))
    canon_aux, old_aux = prod / "aux.bin", old / "aux.bin"
    need(at(canon_aux, 128, canon_aux.stat().st_size - 128) ==
         at(old_aux, 128, old_aux.stat().st_size - 128), "AUX payload after header")
    l13m = sv_constant(sv, "L13M_CANONICAL", 3328)
    lymp = sv_constant(sv, "LYMP_CANONICAL", 1024)
    need(l13m[:64] == b"".join(bytes.fromhex(pm["tags"][k]) for k in
                                   ("model", "numeric", "layout", "build")), "L13M package tags")
    header = (prod / pm["generated_header"]).read_text()
    inputs.append(item(prod / pm["generated_header"]))
    need(l13m[:64] == b"".join(array16(header, k) for k in
                                   ("kFullModelTag", "kFullNumericTag",
                                    "kFullLayoutTag", "kFullBuildTag")), "generated C/SV tags")
    need(lymp == at(canon_aux, 0, 128), "canonical AUX/LYMP")
    need(u32(l13m, 64) == 0x4D33314C and len(l13m) == 416 and
         u32(l13m, 112) == 5 and u32(l13m, 116) == 16 and
         u32(l13m, 120) == 128, "L13M structure")
    for i, role in enumerate(ROLES):
        off = 128 + 16 * i
        need(u32(l13m, off) == ROLE_IDS[i] and u32(l13m, off + 4) == 1 and
             u64(l13m, off + 8) == pm["bo"][role]["size"], f"L13M BO {role}")
    old_id_path = fixtures / "wi_w/model_identity.hex"
    old_id = load_hex_words(old_id_path, 416)
    need(len(old_id) == 416 and old_id[:64] == b"".join(
         bytes.fromhex(om["tags"][k]) for k in ("model", "numeric", "layout", "build")),
         "AT035 Q8S2 package tags")
    need(load_hex_words(fixtures / "w/model_identity.hex", 416) == old_id,
         "AT035 Wi/Down model equality")
    need(u32(old_id, 64) in (0, 1) and u64(old_id, 72) != 0 and
         u32(old_id, 224) == 5 and u32(old_id, 228) == 32 and
         u32(old_id, 232) == 18, "Q8S2 binding structure")
    need(old_id[160:192] == bytes.fromhex(om["tag_preimages"]["build"]["sha256"]) and
         old_id[192:224] == bytes.fromhex(pm["source_model"]["sha256"]),
         "Q8S2 full digest fields")
    bo_bindings = []
    for i, role in enumerate(ROLES):
        off = 256 + 32 * i
        binding = {"role": role, "role_id": u32(old_id, off),
                   "flags": u32(old_id, off + 4), "base": u64(old_id, off + 8),
                   "bytes": u64(old_id, off + 16), "cookie": u64(old_id, off + 24)}
        need(binding["role_id"] == ROLE_IDS[i] and binding["flags"] == 1 and
             binding["bytes"] == pm["bo"][role]["size"] and
             binding["base"] != 0 and binding["cookie"] != 0,
             f"Q8S2 diagnostic binding {role}")
        bo_bindings.append(binding)
    inputs.append(item(old_id_path))
    weights = []
    fixture_payloads: dict[str, bytes] = {}
    for label, name, folder, K, N in CASES:
        w = next((x for x in pm["weights"] if x["name"] == name), None)
        z = next((x for x in om["weights"] if x["name"] == name), None)
        need(w is not None and z is not None and
             {k: w[k] for k in ("K", "N", "q_base", "q_span", "scale_base",
                                  "scale_span", "bias_span", "source_sha256")} ==
             {k: z[k] for k in ("K", "N", "q_base", "q_span", "scale_base",
                                  "scale_span", "bias_span", "source_sha256")},
             f"Wi/Down metadata {name}")
        need((w["K"], w["N"], w["dtype"], w["bias_span"]) == (K, N, 8, 0) and
             w["bias_name"] is None and w["aux_span"] == 0,
             f"bias0/shape {name}")
        rec = header_record(header, name)
        need((rec["K"], rec["N"], rec["dtype"], rec["bias_kind"],
              rec["q0_offset"], rec["q1_offset"], rec["q0_span"],
              rec["q1_span"], rec["scale_offset"], rec["scale_span"],
              rec["bias_span"]) ==
             (K, N, 8, 0, *w["q_base"], *w["q_span"], w["scale_base"],
              w["scale_span"], 0), f"generated header record {name}")
        G, T = K // 32, (N + 7) // 8
        need(w["q_span"] == [((T + 1) // 2) * G * 256, (T // 2) * G * 256] and
             w["scale_span"] == T * G * 16, f"physical shard formula {name}")
        tensor = next(x for x in pm["tensors"] if x["name"] == name)
        source_bytes = at(Path(pm["source_model"]["path"]), tensor["source_offset"],
                          tensor["source_bytes"])
        need(sha_bytes(source_bytes) == tensor["source_sha256"] == w["source_sha256"],
             f"GGUF tensor bytes {name}")
        views = []
        for role, bo, off, size in (("q0", "w_q0", w["q_base"][0], w["q_span"][0]),
                                    ("q1", "w_q1", w["q_base"][1], w["q_span"][1]),
                                    ("scale", "w_scale", w["scale_base"], w["scale_span"])):
            raw = at(prod / pm["bo"][bo]["file"], off, size)
            old_hex = fixtures / folder / f"{label}_{role}.hex"
            need(load_hex_words(old_hex, 64) == raw, f"AT035 physical payload {label}/{role}")
            fixture_payloads[f"{label}_{role}.hex"] = raw
            views.append({"role": role, "bo": bo, "offset": off, "bytes": size,
                          "sha256": sha_bytes(raw), "AT035_hex": item(old_hex),
                          "equal_AT035": True})
            inputs.append(item(old_hex))
        config = [K, N, w["family"] | (w["layer"] << 8), *w["q_base"],
                  w["scale_base"], *w["q_span"], w["scale_span"], 0, 0, G, T]
        old_config = fixtures / folder / f"{label}_config.hex"
        need([int(line, 16) for line in old_config.read_text().splitlines()] == config,
             f"AT035 strict W ranges/bias {label}")
        inputs.append(item(old_config))
        weights.append({"case": label, "tensor": name, "K": K, "N": N,
                        "groups": G, "tiles": T, "bias_kind": 0,
                        "GGUF_offset": tensor["source_offset"],
                        "GGUF_bytes": tensor["source_bytes"],
                        "GGUF_sha256": tensor["source_sha256"],
                        "configuration": config, "physical": views})
    canon_header = at(canon_aux, 0, 128)
    old_header = load_hex_words(fixtures / "wi_w/expected_aux_header.hex", 128)
    need(load_hex_words(fixtures / "w/expected_aux_header.hex", 128) == old_header,
         "AT035 Wi/Down AUX equality")
    need(canon_header[:64] == old_header[:64] and canon_header[96:] == old_header[96:] and
         canon_header[64:96] != old_header[64:96], "AUX difference only layout/build")
    # Q8S2 is a separate wire encoding. Build a diagnostic representation of
    # the verified canonical package, never by changing only the four tags.
    validation = {"schema": "lnqi0-host-package-validation-v1",
                  "canonical_manifest_sha256": sha_file(pm_path),
                  "canonical_BO": {x["role"]: x["canonical"]["sha256"] for x in package_bos},
                  "GGUF_sha256": pm["source_model"]["sha256"],
                  "Wi_Down": {x["case"]: {v["role"]: v["sha256"] for v in x["physical"]}
                              for x in weights}}
    validation_raw = json.dumps(validation, sort_keys=True, separators=(",", ":")).encode()
    diagnostic = bytearray(old_id)
    diagnostic[:64] = l13m[:64]
    put32(diagnostic, 64, 0)  # STRICT profile; do not claim static-model validation.
    diagnostic[96:128] = hashlib.sha256(validation_raw).digest()
    diagnostic[128:160] = bytes.fromhex(sha_file(pm_path))
    diagnostic[160:192] = bytes.fromhex(pm["tag_preimages"]["build"]["sha256"])
    diagnostic[192:224] = bytes.fromhex(pm["source_model"]["sha256"])
    need(diagnostic[48:64] == diagnostic[160:176] and
         u32(diagnostic, 64) == 0 and u64(diagnostic, 72) != 0 and
         diagnostic[:64] == l13m[:64], "diagnostic strict-W encoding")
    need(u32(l13m, 64) != 0, "raw L13M must remain distinct from W dialect")
    out.mkdir(parents=True)
    fixture_out = out / "fixtures"
    fixture_out.mkdir()
    for name, raw in fixture_payloads.items():
        emit_hex_words(fixture_out / name, raw, 64)
    for x in weights:
        (fixture_out / f"{x['case']}_config.hex").write_text(
            "".join(f"{v:016x}\n" for v in x["configuration"]))
    emit_hex_words(fixture_out / "model_identity_q8s2_diagnostic.hex", bytes(diagnostic), 416)
    emit_hex_words(fixture_out / "expected_aux_header.hex", canon_header, 128)
    emit_hex_words(fixture_out / "aux_header.hex", canon_header, 16)
    (out / "validation_record.json").write_bytes(validation_raw + b"\n")
    report = {
        "schema": "lnqi0-identity-preflight-v1", "status": "PASS_HOST_ONLY",
        "scope": "canonical package versus AT035 Wi/Down bytes and diagnostic W dialect; no RTL/live BO binding",
        "inputs": inputs, "production_tags": pm["tags"], "AT035_tags": om["tags"],
        "L13M_identity_sha256": sha_bytes(l13m), "AT035_identity_sha256": sha_bytes(old_id),
        "different_identity_bytes": sum(a != b for a, b in zip(l13m, old_id)),
        "identity_dialects": {
            "L13M": {"magic_offset": 64, "magic": "L13M", "version_offset": 68,
                     "source_sha_offset": 80, "bo_count_offset": 112,
                     "bo_records_offset": 128, "bo_entry_bytes": 16,
                     "full_identity_consumer": "generated provenance hub canonical equality"},
            "Q8S2_W": {"extraction": "descriptor words32:48 + words64:152",
                        "profile_offset": 64, "generation_offset": 72,
                        "validation_sha_offset": 96, "manifest_sha_offset": 128,
                        "build_sha_offset": 160, "GGUF_sha_offset": 192,
                        "bo_count_offset": 224, "bo_records_offset": 256,
                        "bo_entry_bytes": 32,
                        "strict_W_rule": "u32@64==0 and u64@72!=0; complete 416B held/echoed"}},
        "raw_L13M_strict_W_admissible": False,
        "diagnostic_W_identity_sha256": sha_bytes(diagnostic),
        "diagnostic_W_binding_source": "AT035 diagnostic bases/cookies; must rebind actual live BOs",
        "diagnostic_W_profile": "STRICT; host validation digest is not Q8S2 hardware validation",
        "bo_bindings": bo_bindings, "package_bos": package_bos,
        "AUX": {"canonical_header_sha256": sha_bytes(canon_header),
                "AT035_header_sha256": sha_bytes(old_header),
                "different_bytes": sum(a != b for a, b in zip(canon_header, old_header)),
                "payload_after_128_equal": True, "bias0": True},
        "weights": weights,
        "physical_layout": "tile=n//8; lane=n%8; shard=tile%2; local_tile=tile//2; q_offset=((local_tile*G+g)*8+lane)*32; scale_offset=((tile*G+g)*8+lane)*2",
        "outputs": {p.name: item(p) for p in sorted(fixture_out.iterdir())},
        "validation_record": item(out / "validation_record.json"),
        "not_verified": ["LN-to-QAR0 RTL", "actual live BO base/cookie binding",
                         "Q8S2 W alias adapter RTL", "full ordinary Q/L", "full request"]}
    (out / "report.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print("LNQI0_HOST_PASS weights=2 payload_views=6 GGUF=1 BO=5 identity_dialects=2")


if __name__ == "__main__":
    main()
