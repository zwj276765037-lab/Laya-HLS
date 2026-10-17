#!/usr/bin/env python3
"""Static hashes, literal bindings and source packet; no model/DUT execution."""
from __future__ import annotations

import ast
import hashlib
import json
from pathlib import Path


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
REVIEW = ROOT / "results/attention_rtl_repair_20261008"
GATE = REVIEW / "reviewer_d2_type_producer_binary_source_preparation_release.json"
GATE_SHA = "d50e1f2c346bf8d1ed0c86ef661582a75f47b6301bec5401877a749ae3d0509c"
PACKET = MODULE / "source/source_packet.json"
PAGE = 4096


def sha(raw: bytes) -> str:
    return hashlib.sha256(raw).hexdigest()


def record(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha(path.read_bytes())}


def bound(entry: dict) -> bytes:
    path = Path(entry["path"])
    raw = path.read_bytes()
    if (len(raw), sha(raw)) != (entry["bytes"], entry["sha256"]):
        raise ValueError(f"bound file differs: {path}")
    return raw


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def main() -> int:
    if PACKET.exists():
        raise FileExistsError(PACKET)
    gate_raw = GATE.read_bytes()
    require(sha(gate_raw) == GATE_SHA, "signed source gate hash")
    gate = json.loads(gate_raw)
    require(gate["root"] == str(MODULE), "gate module root")
    bound(gate["design"])
    bound(gate["accepted_unary"])
    for entry in gate["source_refs"]:
        bound(entry)
    manifest = json.loads(bound(gate["model_manifest"]))
    tensor = next(item for item in manifest["tensors"]
                  if item["name"] == "type_emb.weight")
    require(tensor == gate["type_weight_tensor"], "exact type descriptor")
    generated_header = Path(gate["model_manifest"]["path"]).parent / manifest["generated_header"]
    header_text = generated_header.read_text()
    require('"type_emb.weight", 8' in header_text and
            "54800384, 3264" in header_text,
            "compiled descriptor table type weight binding")
    embedding = bound(gate["embedding_bo"])
    weight = embedding[tensor["base"]:tensor["base"] + tensor["span"]]
    require(len(weight) == 3264 and sha(weight) == tensor["source_sha256"],
            "complete packaged type tensor")
    fixture = json.loads(bound(gate["fixture_report"]))
    hidden = bound(gate["hidden_ingress"])
    bound(gate["baseline_gold"])
    require(len(hidden) == 64 * 1024 * 4 and fixture["qtype"] == 2,
            "frozen HIDDEN and qtype2")
    original = fixture["checked_reference_files"]
    gguf_key = next(key for key in original
                    if key.endswith(".gguf::type_emb.weight"))
    gguf_entry = original[gguf_key]
    gguf_path = Path(gguf_key.split("::", 1)[0])
    with gguf_path.open("rb") as source:
        source.seek(tensor["source_offset"])
        raw = source.read(tensor["source_bytes"])
    require(raw == weight and sha(raw) == gguf_entry["sha256"],
            "exact GGUF/package type tensor bytes")
    capture_key = next(key for key in original
                       if key.endswith("/native/forward_0/ir_1410.bin"))
    capture = Path(capture_key)
    require(record(capture)["sha256"] == original[capture_key]["sha256"],
            "native HIDDEN capture identity")
    require(record(ROOT / "tests/full_reference.py")["sha256"] ==
            fixture["reference_sha256"], "independent oracle source")
    request = Path(fixture["files"]["request"]["path"]).read_bytes()
    require(len(request) == 832 and sha(request) ==
            fixture["files"]["request"]["sha256"] and
            int.from_bytes(request[132 + 4 * 32:136 + 4 * 32], "little") == 768 and
            int.from_bytes(request[768:772], "little", signed=True) == 2,
            "frozen request qtype offset")
    rows_entry = fixture["files"]["type_rows"]
    require(record(Path(rows_entry["path"]))["sha256"] == rows_entry["sha256"],
            "reference-only type rows")

    top = MODULE / "source/type_producer_binary_slice.cpp"
    top_text = top.read_text()
    for literal in ("#include \"control/full_forward_controller.cpp\"",
                    "controller.type_add(hidden)",
                    "full_parse_request(rt, memory)",
                    "full_f32_address(rt, memory",
                    "full_write(memory, address.bo",
                    "memory.embedding = embedding",
                    "full_cover_owner(rt, owner, 0, 0, 64)",
                    "full_publish_owner(rt, owner)"):
        require(literal in top_text, f"top path literal: {literal}")
    for forbidden in ("produce_f32", "src1_input", "type_rows.f32.bin",
                      "rt.owners.type_valid[0] =", "rt.owners.type_valid[1] =",
                      "rt.owners.type_valid[2] ="):
        require(forbidden not in top_text, f"forbidden top injection: {forbidden}")

    config = MODULE / "source/config_type_producer_binary.cfg"
    lines = config.read_text().splitlines()
    syn_files = [Path(line.removeprefix("syn.file=")) for line in lines
                 if line.startswith("syn.file=")]
    require("syn.top=type_producer_binary_slice" in lines and
            top in syn_files and
            ROOT / "hls/control/full_forward_controller.cpp" not in syn_files,
            "candidate HLS top and single Controller inclusion")
    require(all(path.is_file() for path in syn_files), "candidate source closure")
    require(f"tb.file={MODULE / 'tb/test_type_producer_binary_slice.cpp'}" in lines,
            "candidate TB source")
    mapping = json.loads((MODULE / "tb/static_mapping.json").read_text())
    ports = mapping["top_ports"]
    require([p["name"] for p in ports] ==
            ["hidden_input", "embedding", "io", "aux", "state0", "state1",
             "observed"], "exact top port order")
    spans = []
    mapped = 0
    for port in ports:
        base = int(port["base_hex"], 16)
        cap = port["capacity_bytes"]
        require(base != 0 and base % PAGE == 0 and cap > 0,
                "nonzero page-aligned physical base and capacity")
        spans.append((base, base + cap))
        for offset, count in port["mapped_page_runs"]:
            require(offset >= 0 and offset % PAGE == 0 and count > 0 and
                    offset < cap and offset + count * PAGE <=
                    ((cap + PAGE - 1) // PAGE) * PAGE,
                    "bounded sparse physical pages")
            mapped += count
    ordered = sorted(spans)
    require(all(a[1] <= b[0] for a, b in zip(ordered, ordered[1:])),
            "disjoint 64-bit physical ports")
    require(mapped == mapping["mapped_page_total"] == 206,
            "exact sparse mapped page total")
    for case in mapping["qtype_cases"]:
        qtype = case["qtype"]
        require(case["type_q8_row_byte_offset"] == 54800384 + qtype * 1088 and
                case["type_q8_row_bytes"] == 1088 and
                case["type_f32_row_byte_offset"] == 16908288 + qtype * 4096 and
                case["type_f32_row_bytes"] == 4096,
                "literal Q8/F32 row addresses")
    for script in (Path(__file__), MODULE / "tb/materialize_qtype1.py"):
        ast.parse(script.read_text(), filename=str(script))
    oracle_source = (MODULE / "tb/materialize_qtype1.py").read_text()
    for literal in ("import full_reference as reference",
                    "reference.embedding_row(", "reference.add(",
                    "source.seek(tensor[\"source_offset\"])",
                    "embedding = checked(embedding_path"):
        require(literal in oracle_source,
                f"independent original-R0 qtype1 oracle literal: {literal}")

    local_files = sorted(path for sub in ("source", "rtl", "tb")
                         for path in (MODULE / sub).rglob("*")
                         if path.is_file() and path != PACKET and
                         "__pycache__" not in path.parts)
    packet = {
        "schema": "d2_type_producer_binary_source_packet_v1",
        "status": "STATIC_SOURCE_CHECKED_NO_MODEL_OR_DUT_EXECUTION",
        "signed_gate": record(GATE),
        "immutable_design": gate["design"],
        "production_source_refs": gate["source_refs"],
        "model_manifest": gate["model_manifest"],
        "generated_model_header": record(generated_header),
        "embedding_bo": gate["embedding_bo"],
        "type_weight_tensor": tensor,
        "original_gguf_type_tensor_sha256": sha(raw),
        "native_hidden_capture": {"path": str(capture),
                                  "sha256": original[capture_key]["sha256"]},
        "frozen_fixture_report": gate["fixture_report"],
        "hidden_ingress": gate["hidden_ingress"],
        "baseline_gold": gate["baseline_gold"],
        "independent_reference_source": record(ROOT / "tests/full_reference.py"),
        "candidate_hls_source_files": [record(path) for path in syn_files],
        "local_files": [record(path) for path in local_files],
        "static_checks": {
            "gate_and_design_hash": "PASS", "production_closure_hash": "PASS",
            "package_and_exact_gguf_tensor": "PASS",
            "native_hidden_and_independent_reference": "PASS",
            "actual_controller_call_and_no_type_prefill_literals": "PASS",
            "nonzero_disjoint_ports_and_206_pages": "PASS",
            "qtype1_python_syntax_and_reference_source": "PASS"
        },
        "not_run": ["qtype1 materialization", "CPU compile or run", "CSim",
                    "HLS", "RTL simulation", "synthesis", "OOC", "board"],
    }
    with PACKET.open("x") as out:
        json.dump(packet, out, indent=2, sort_keys=True)
        out.write("\n")
    print(f"D2_TYPE_SOURCE_PACKET_READY local_files={len(local_files)} "
          f"candidate_sources={len(syn_files)} pages={mapped}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
