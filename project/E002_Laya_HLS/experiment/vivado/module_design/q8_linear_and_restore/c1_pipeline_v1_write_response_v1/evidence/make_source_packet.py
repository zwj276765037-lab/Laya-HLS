#!/usr/bin/env python3
"""Bind the unreviewed C1 source candidate and exact prior-file diff."""

import difflib
import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EVIDENCE = ROOT / "evidence"
PREIMAGES = EVIDENCE / "preimages"
MANIFEST = EVIDENCE / "preimage_manifest.json"
PACKET = ROOT / "source/source_packet.json"
DIFF = EVIDENCE / "source_candidate.diff"
GATE_SHA = "97c82f40f375ad8d3495ec57bd9f254442855cff2d5454f41386c2d54b29eb06"


def ident(path):
    path = Path(path)
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def require_same(record):
    current = ident(record["path"])
    if (current["bytes"], current["sha256"]) != (record["bytes"], record["sha256"]):
        raise RuntimeError(f"frozen identity changed: {record['path']}")
    return current


def main():
    manifest = json.loads(MANIFEST.read_text())
    if len(manifest["files"]) != 14 or manifest["gate"]["sha256"] != GATE_SHA:
        raise RuntimeError("prior preimage contract mismatch")
    gate = require_same(manifest["gate"])
    prior = []
    old_by_rel = {}
    for record in manifest["files"]:
        old = Path(record["archived_path"])
        if (old.stat().st_size, ident(old)["sha256"]) != (record["bytes"], record["sha256"]):
            raise RuntimeError(f"archived preimage changed: {old}")
        original = Path(record["original_path"])
        if ident(original)["sha256"] != record["sha256"]:
            raise RuntimeError(f"original candidate changed: {original}")
        rel = old.relative_to(PREIMAGES)
        old_by_rel[str(rel)] = old
        prior.append({"relative_path": str(rel), "archive": ident(old),
                      "original": ident(original)})

    files = []
    for directory in ("source", "tb", "config", "rtl"):
        for path in sorted((ROOT / directory).rglob("*")):
            if path.is_file() and path != PACKET:
                rec = ident(path)
                rec["relative_path"] = str(path.relative_to(ROOT))
                files.append(rec)
    if len(files) != 18:
        raise RuntimeError(f"unexpected candidate file count: {len(files)}")
    candidate_by_rel = {x["relative_path"]: Path(x["path"]) for x in files}
    if (ROOT / "source/q8_joint_abi.h").read_bytes() != \
            (PREIMAGES / "source/q8_joint_abi.h").read_bytes():
        raise RuntimeError("q8 ABI changed")

    diff_lines = []
    for rel in sorted(candidate_by_rel):
        old = old_by_rel.get(rel)
        before = old.read_text().splitlines(keepends=True) if old else []
        after = candidate_by_rel[rel].read_text().splitlines(keepends=True)
        diff_lines.extend(difflib.unified_diff(
            before, after, fromfile=f"a/{rel}" if old else "/dev/null",
            tofile=f"b/{rel}", n=3))
    DIFF.write_text("".join(diff_lines))

    tool_headers = [ident(Path(path)) for path in (
        "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/common/technology/autopilot/hls_burst_maxi.h",
        "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/include/hls_burst_maxi.h")]
    source = (ROOT / "source/q8_joint_tm4tn8.cpp").read_text()
    write = (ROOT / "source/c1_write_response.h").read_text()
    router = (ROOT / "source/c1_write_router.h").read_text()
    checks = {
        "three_burst_maxi_write_arguments": source.count("hls::burst_maxi<uint32_t> out") == 2 and
                                           "hls::burst_maxi<uint32_t> observed" in source,
        "three_writer_actors": all(f"write_{name}(" in source for name in ("out0", "out1", "observed")),
        "response_called_after_data_loop": write.index("port.write_response();") > write.index("for (unsigned i = 0; i < static_cast<unsigned>(c.count); ++i)"),
        "one_credit_per_port": all(token in router for token in ("Credit out0", "Credit out1", "Credit observed")),
        "live_full_result_delay_gap_present": "C1Flight flight[kC1FlightStages + 1]" in source and
                                             "flight[0] = evaluate_c1_return" in source,
        "result_trace_ring_present": all(token in source for token in ("ResultRing results", "TraceRing traces", "results.return_result", "traces.return_payload")),
    }
    if not all(checks.values()):
        raise RuntimeError(f"source topology changed: {checks}")
    packet = {
        "schema": "q8_c1_write_response_source_packet_v1",
        "created_utc": datetime.now(timezone.utc).isoformat(),
        "status": "SOURCE_ONLY_UNREVIEWED_FULL_RESULT_DELAY_REVIEW_BLOCKER",
        "root": str(ROOT), "additive_gate": gate,
        "preimage_manifest": ident(MANIFEST), "prior_files": prior,
        "candidate_file_count": len(files), "candidate_files": files,
        "source_diff": ident(DIFF), "installed_burst_maxi_headers": tool_headers,
        "read_only_source_checks": checks,
        "candidate_storage_bits": {
            "result_ring_payload_plus_state": 83264,
            "full_result_delay_18_times_1556": 28008,
            "three_writer_fifo_register_ack": 3819,
            "four_trace_payload_state_tag_minimum": 1104},
        "known_gap": "The live path computes a full result at issue and delays it in 18 full-vector stages. This is unbudgeted full-result storage and cannot establish the physical bank/FP stage schedule or fixed hardware return. Astra preliminary review requires stage-operand/tag pipeline redesign before execution.",
        "other_unmet_source_gates": [
            "actual-wrapper changing-tag streaming probe source and measurements",
            "full half-pattern/INT8-extreme and accepted R0 finite-table regression integration",
            "physical response aggregation, generated DATAFLOW/port/CSR parity",
            "independent C1 physical capacity and bank connectivity proof"],
        "execution": {"cpu": "NOT_RUN", "csim": "NOT_RUN", "hls": "NOT_RUN",
                      "rtl": "NOT_RUN", "vivado": "NOT_RUN"},
    }
    PACKET.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"packet": ident(PACKET), "candidate_files": len(files),
                      "prior_preimages": len(prior), "topology_checks": checks}, sort_keys=True))


if __name__ == "__main__":
    main()
