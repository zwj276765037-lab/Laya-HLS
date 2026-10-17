#!/usr/bin/env python3
"""Seal the first released Attention v5 synthesis result without rerunning HLS."""

import datetime
import hashlib
import json
import pathlib
import re

RUN = pathlib.Path(__file__).resolve().parent
V5 = RUN.parent.parent
WORK = RUN / "work"
PACKET = V5 / "runs" / "source_config_binding_v1" / "source_config_binding_packet.json"
PRELAUNCH = V5 / "runs" / "local_csynth_prelaunch_v1.json"
MARKER = re.compile(rb'^#\s+\d+\s+"([^"]+)"', re.MULTILINE)


def digest(path):
    path = pathlib.Path(path)
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(4 * 1024 * 1024), b""):
            h.update(chunk)
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": h.hexdigest()}


def save(path, obj):
    path.write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")


def check_record(record):
    actual = digest(record["path"])
    if actual["bytes"] != record["bytes"] or actual["sha256"] != record["sha256"]:
        raise RuntimeError(f"frozen record changed: {record['path']}")
    return actual


def main():
    now = datetime.datetime.now(datetime.timezone.utc).isoformat()
    packet = json.loads(PACKET.read_text())
    prelaunch = json.loads(PRELAUNCH.read_text())
    if len(packet["frozen_records"]) != 127 or packet["frozen_unique_count"] != 127:
        raise RuntimeError("unexpected frozen record count")
    frozen = [check_record(r) for r in packet["frozen_records"]]
    candidates = [packet["source"], packet["config"]]
    for copy in packet["copies"]:
        candidates.extend((copy["from"], copy["to"]))
    candidate_checks = [check_record(r) for r in candidates]
    if prelaunch["source_packet_sha256"] != digest(PACKET)["sha256"]:
        raise RuntimeError("prelaunch packet mismatch")

    dirs, files, symlinks, other = [], [], [], []
    for p in sorted(WORK.rglob("*")):
        rel = str(p.relative_to(WORK))
        if p.is_symlink():
            symlinks.append({"relative_path": rel, "target": str(p.readlink())})
        elif p.is_dir():
            dirs.append(rel)
        elif p.is_file():
            d = digest(p)
            files.append({"relative_path": rel, "bytes": d["bytes"], "sha256": d["sha256"]})
        else:
            other.append(rel)
    if symlinks or other:
        raise RuntimeError(f"unexpected work-tree entries: symlink={len(symlinks)}, other={len(other)}")
    manifest = {
        "schema": "attention_v5_first_synthesis_complete_work_manifest_v1",
        "at_utc": now,
        "root": str(WORK),
        "directory_count": len(dirs),
        "directories": dirs,
        "regular_file_count": len(files),
        "total_file_bytes": sum(x["bytes"] for x in files),
        "files": files,
        "symlink_count": len(symlinks),
        "symlinks": symlinks,
        "other_entries": other,
    }
    manifest_path = RUN / "work_file_manifest.json"
    save(manifest_path, manifest)

    pp_files = sorted((WORK / "hls" / ".autopilot" / "db").glob("*.pp.*.cpp"))
    if len(pp_files) != 25:
        raise RuntimeError(f"unexpected preprocessed TU count: {len(pp_files)}")
    all_deps = set()
    virtual = set()
    per_tu = []
    for pp in pp_files:
        names = {m.decode("utf-8", "surrogateescape") for m in MARKER.findall(pp.read_bytes())}
        deps = []
        for name in sorted(names):
            if name.startswith("<") and name.endswith(">") or name == "directive":
                virtual.add(name)
                continue
            path = pathlib.Path(name)
            if not path.is_absolute() or not path.is_file():
                raise RuntimeError(f"unresolved real preprocessor dependency: {name}")
            deps.append(name)
            all_deps.add(name)
        per_tu.append({"preprocessed_file": digest(pp), "dependency_count": len(deps), "dependencies": deps})
    dep_records = [digest(path) for path in sorted(all_deps)]
    closure = {
        "schema": "attention_v5_actual_preprocessed_dependency_closure_v1",
        "at_utc": now,
        "source": "existing Vitis .pp.0.cpp line markers; no new compiler invocation",
        "work_root": str(WORK),
        "preprocessed_tu_count": len(per_tu),
        "per_translation_unit": per_tu,
        "unique_real_file_count": len(dep_records),
        "unique_real_files": dep_records,
        "synthetic_markers": sorted(virtual),
    }
    closure_path = RUN / "preprocessed_dependency_closure.json"
    save(closure_path, closure)

    guard = json.loads((RUN / "guard" / "guard_result.json").read_text())
    if guard["child_exit_code"] != 0 or guard["trigger"] is not None:
        raise RuntimeError("guard did not complete successfully")
    report = WORK / "hls" / "syn" / "report" / "attention_preloaded_slice_csynth.rpt"
    rtl = WORK / "hls" / "syn" / "verilog" / "attention_preloaded_slice.v"
    vhdl = WORK / "hls" / "syn" / "vhdl" / "attention_preloaded_slice.vhd"
    ipzip = WORK / "hls" / "impl" / "ip" / "xilinx_com_hls_attention_preloaded_slice_1_0.zip"
    for path in (report, rtl, vhdl, ipzip):
        if not path.is_file() or not path.stat().st_size:
            raise RuntimeError(f"missing generated artifact: {path}")
    report_text = report.read_text(errors="replace")
    resource = re.search(r"^\|Total\s*\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|\s*(\d+)\|", report_text, re.MULTILINE)
    if not resource:
        raise RuntimeError("missing HLS resource totals")
    clock = re.search(r"^\s*\|ap_clk\s*\|\s*([\d.]+) ns\|\s*([\d.]+) ns\|\s*([\d.]+) ns\|", report_text, re.MULTILINE)
    if not clock:
        raise RuntimeError("missing HLS clock estimate")
    out = {
        "schema": "attention_v5_first_released_local_synthesis_evidence_v1",
        "at_utc": now,
        "status": "GENERATED_RTL_AND_IP_INDEPENDENT_REVIEW_PENDING",
        "release": check_record(packet["release"]),
        "source_config_packet": digest(PACKET),
        "prelaunch": digest(PRELAUNCH),
        "frozen_records_rehashed": len(frozen),
        "candidate_records_rehashed": len(candidate_checks),
        "candidate_unique_paths_rehashed": len({r["path"] for r in candidate_checks}),
        "frozen_and_candidate_records_match": True,
        "guard": guard,
        "guard_artifacts": [digest(p) for p in sorted((RUN / "guard").iterdir()) if p.is_file()],
        "work_manifest": digest(manifest_path),
        "preprocessed_dependency_closure": digest(closure_path),
        "generated": {
            "top_report": digest(report),
            "top_verilog": digest(rtl),
            "top_vhdl": digest(vhdl),
            "ip_zip": digest(ipzip),
            "syn_verilog_file_count": len(list((WORK / "hls" / "syn" / "verilog").glob("*.v"))),
            "syn_vhdl_file_count": len(list((WORK / "hls" / "syn" / "vhdl").glob("*.vhd"))),
            "work_file_count": len(files),
            "work_directory_count": len(dirs),
            "work_bytes": manifest["total_file_bytes"],
        },
        "hls_report": {
            "target_clock_ns": float(clock.group(1)),
            "estimated_clock_ns": float(clock.group(2)),
            "uncertainty_ns": float(clock.group(3)),
            "resource_estimates": dict(zip(("BRAM_18K", "DSP", "FF", "LUT", "URAM"), map(int, resource.groups()))),
            "top_latency": "unknown in top report",
        },
        "interpretation": "The single released Attention v5 local HLS synthesis generated RTL and IP. Structural report data are estimates; no RTL functional, OOC, physical timing, platform, or board acceptance is implied.",
    }
    save(RUN / "synthesis_evidence.json", out)
    print(json.dumps({"status": out["status"], "frozen": len(frozen), "candidate": len(candidate_checks), "work_files": len(files), "pp_tus": len(pp_files), "dependencies": len(dep_records), "guard_exit": guard["child_exit_code"]}))


if __name__ == "__main__":
    main()
