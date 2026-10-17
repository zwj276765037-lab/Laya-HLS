#!/usr/bin/env python3
"""Bind reused stream02 function evidence and actual bottom-up OOC scope."""
import argparse
import hashlib
import json
from pathlib import Path
import re


def identity(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {"path": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def resources(path, top):
    if not path.is_file():
        return None
    for line in path.read_text().splitlines():
        fields = [x.strip() for x in line.split("|")[1:-1]]
        if len(fields) == 11 and fields[0] == top:
            keys = ("lut", "logic_lut", "lutram", "srl", "ff",
                    "bram36", "bram18", "uram", "dsp")
            return dict(zip(keys, map(int, fields[2:])))
    raise RuntimeError(f"Missing actual top resource row: {path} {top}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("attempt", type=Path)
    parser.add_argument("--cost-stop", type=Path)
    args = parser.parse_args()
    attempt = args.attempt.resolve()
    manifest_path = attempt / "source_manifest_v02.json"
    manifest = json.loads(manifest_path.read_text())
    for item in manifest["files"]:
        assert identity(item["path"])["sha256"] == item["sha256"], item["path"]
    source_identity = manifest["reused_source_receipt"]
    assert identity(source_identity["path"]) == source_identity
    source = json.loads(Path(source_identity["path"]).read_text())
    assert source["numerical_pass"] and not source["actual_module_ooc_complete"]
    guards = {}
    for directory in sorted(attempt.glob("guard_*")):
        path = directory / "guard_result.json"
        if path.is_file():
            guards[directory.name] = {"result": json.loads(path.read_text()),
                                      "identity": identity(path)}
        elif (directory / "launch.json").is_file():
            raise RuntimeError(f"Active guard cannot be collected: {directory}")
    elapsed = sum(g["result"]["elapsed_seconds"] for g in guards.values())
    nodes = []
    for node in manifest["nodes"]:
        work = attempt / "nodes" / node["module"]
        dcp = work / "child_synth.dcp"
        timing = work / "timing_summary.rpt"
        nodes.append({"module": node["module"], "op": node["op"],
                      "parent_cell": node["parent_cell"],
                      "sources": node["dependencies"],
                      "dcp": identity(dcp) if dcp.is_file() else None,
                      "actual_local_resources": resources(
                          work / "utilization_hierarchical.rpt", node["module"]),
                      "timing_report": identity(timing) if timing.is_file() else None,
                      "port_report": identity(work / "ports.txt")
                      if (work / "ports.txt").is_file() else None})
    parent = attempt / "parent"
    dcp = parent / "tanh_libm_stream_wrapper_assembled.dcp"
    map_path = parent / "final_boundary_map.txt"
    successful_logs = []
    for name, guard in guards.items():
        if guard["result"]["child_exit_code"] == 0 and guard["result"]["trigger"] is None:
            successful_logs.append((attempt / name / "driver.log").read_text())
    logs = "\n".join(successful_logs)
    complete = any(line.strip() == "TANH_LIBM_BOTTOMUP_ASSEMBLY_COMPLETE boundaries=42 blackboxes=0"
                   for line in logs.splitlines())
    full_resources = None
    timing = None
    if complete:
        assert elapsed <= 3600, elapsed
        assert all(n["dcp"] for n in nodes) and dcp.is_file()
        actual = [line.split() for line in map_path.read_text().splitlines()]
        expected = {(n["module"], n["parent_cell"], n["module"], "0")
                    for n in manifest["nodes"]}
        assert len(actual) == 42 and set(map(tuple, actual)) == expected
        assert all((parent / name).is_file() for name in
                   ("utilization.rpt", "utilization_hierarchical.rpt",
                    "timing_summary.rpt", "check_timing.rpt", "clock_networks.rpt"))
        full_resources = resources(parent / "utilization_hierarchical.rpt",
                                   "tanh_libm_stream_wrapper")
        match = re.search(r"WNS\(ns\).*?\n\s*-.*?\n\s*([\d.-]+)\s+([\d.-]+)",
                          (parent / "timing_summary.rpt").read_text(), re.S)
        assert match
        timing = {"wns_ns": float(match[1]), "tns_ns": float(match[2]),
                  "scope": "Synthesis OOC only; no P&R or achieved Fmax"}
    cost = json.loads(args.cost_stop.read_text()) if args.cost_stop else None
    if not complete:
        assert cost is not None
    netlist_pass = any(line.startswith("TANH_LIBM_BOTTOMUP_NETLIST_PILOT_PASS")
                       for line in logs.splitlines())
    receipt = {
        "schema": "laya-stream02-bottomup-ooc-v1",
        "status": ("OOC_COMPLETE_NETLIST_PASS" if netlist_pass else
                   "OOC_COMPLETE_NETLIST_NOT_RUN") if complete else "OOC_COST_ABORTED",
        "numerical_pass": True,
        "numerical_evidence": {"status": "REUSED_UNCHANGED_STREAM02",
                               "receipt": source_identity,
                               "evidence_manifest": manifest["reused_evidence_manifest"]},
        "actual_module_ooc_complete": complete,
        "blackboxes": 0 if complete else None,
        "actual_full_resources": full_resources,
        "timing": timing,
        "assembled_dcp": identity(dcp) if complete else None,
        "final_boundary_map": identity(map_path) if complete else None,
        "assembled_netlist_check": "PASS" if netlist_pass else "NOT_RUN",
        "nodes": nodes,
        "cost": {"maximum_seconds": 3600, "actual_cumulative_seconds": elapsed,
                 "within_cumulative_budget": elapsed <= 3600,
                 "maximum_owned_rss_gib": 24, "semantic_stall_seconds": 120,
                 "projection_stop": cost},
        "guards": guards,
        "source_manifest": identity(manifest_path),
        "scope": "Exact stream02 RTL, 42 actual helper boundaries and parent wrapper; no full accelerator or board claim",
        "performance_scope": "Reused measured stream02 profiles only; independently drained row/task tail remains 375 cycles",
    }
    files = [p for p in attempt.rglob("*") if p.is_file()
             and p.suffix in (".json", ".tcl", ".v", ".sv", ".xdc", ".rpt", ".log", ".txt", ".dcp", ".csv", ".py")
             and p.name not in ("receipt.json", "evidence_manifest.json")]
    evidence = {"schema": "laya-bottomup-evidence-v1",
                "files": [identity(p) for p in sorted(files)]}
    evidence_path = attempt / "evidence_manifest.json"
    evidence_path.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n")
    receipt["evidence_manifest"] = identity(evidence_path)
    receipt_path = attempt / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"receipt": identity(receipt_path), "status": receipt["status"],
                      "completed_child_dcps": sum(bool(n["dcp"]) for n in nodes),
                      "actual_cumulative_seconds": elapsed}))


if __name__ == "__main__":
    main()
