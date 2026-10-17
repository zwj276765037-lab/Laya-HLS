#!/usr/bin/env python3
"""Bind all quoted/local C++ includes and exact future CPU build argv.

This is a source/hash inspection only. It never compiles or runs the DUT.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import re
import shlex


HERE = Path(__file__).resolve().parent
MODULE = HERE.parents[2]
BASE = MODULE.parents[2]
REVIEW = BASE / "results/attention_rtl_repair_20261008"
PACKET = MODULE / "source/source_packet.json"
GATE = REVIEW / "reviewer_d2_type_producer_binary_actual_source_and_qtype1_materialization_release.json"
SOURCE_GATE = REVIEW / "reviewer_d2_type_producer_binary_source_preparation_release.json"
CONFIG = MODULE / "source/config_type_producer_binary.cfg"
TB = MODULE / "tb/test_type_producer_binary_slice.cpp"
MANIFEST = HERE / "closure_manifest.json"
BUILDER = HERE / "build_cpu_future.py"
NOTE = HERE / "README.md"
OLD_CPU = REVIEW / "d2_controller_reachable/runs/cpu_vector_build/result.json"
INCLUDE = re.compile(r'^\s*#\s*include\s*(["<])([^">\n]+)[">]', re.M)
STRICT = ["-std=c++17", "-O2", "-fno-fast-math", "-ffp-contract=off"]
EXPECTED_PACKET = "1201554b4b8c18d376a4045cdb4b64d8a35c37c8b0a3d5b3e6b61ab14c0137f1"
EXPECTED_GATE = "d185ab57a40ba5d3ba265d96dd6ebd804204d6645699ce834c38d71efd8a65f5"


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def require(condition: bool, reason: str) -> None:
    if not condition:
        raise RuntimeError(reason)


def read_bound(entry: dict) -> None:
    actual = record(Path(entry["path"]))
    require(all(actual[key] == entry[key] for key in ("bytes", "sha256")),
            f"frozen input differs: {entry['path']}")


def parse_config(packet: dict) -> tuple[list[Path], list[Path]]:
    lines = CONFIG.read_text().splitlines()
    require("syn.top=type_producer_binary_slice" in lines, "candidate top")
    sources = [Path(line.removeprefix("syn.file=")) for line in lines
               if line.startswith("syn.file=")]
    require(len(sources) == len(set(sources)) == 25 and
            [str(path) for path in sources] ==
            [item["path"] for item in packet["candidate_hls_source_files"]],
            "exact 25-source order")
    require(f"tb.file={TB}" in lines, "exact CPU test source")
    cflags = shlex.split(next(line.removeprefix("syn.cflags=")
                              for line in lines if line.startswith("syn.cflags=")))
    require(cflags[-4:] == STRICT and len(cflags) == 8,
            "strict C++17 flags and four include paths")
    include_dirs = [Path(flag[2:]) for flag in cflags[:4]]
    require(all(flag.startswith("-I") for flag in cflags[:4]) and
            include_dirs == [BASE / "include", BASE / "hls",
                             BASE / "hls/platform",
                             BASE / "build/model-attention-rtl-repair-20261008"] and
            all(path.is_dir() for path in include_dirs),
            "exact local include search order")
    for path, item in zip(sources, packet["candidate_hls_source_files"]):
        read_bound(item)
        require(record(path)["path"] == item["path"], "source path identity")
    return sources, include_dirs


def closure(starts: list[Path], include_dirs: list[Path]) -> tuple[list[dict], list[dict], list[str]]:
    visited: set[Path] = set()
    dependencies: set[Path] = set()
    edges: list[dict] = []
    system: set[str] = set()
    pending = list(starts)
    while pending:
        path = pending.pop().resolve()
        if path in visited:
            continue
        visited.add(path)
        raw = path.read_text()
        for opening, token in INCLUDE.findall(raw):
            candidates = [path.parent / token] + [inc / token for inc in include_dirs]
            matches = [candidate.resolve() for candidate in candidates
                       if candidate.is_file()]
            if not matches:
                if opening == "<":
                    system.add(token)
                    continue
                raise RuntimeError(f"unresolved local include {path}: {token}")
            target = matches[0]
            require(target == BASE or BASE in target.parents,
                    f"local include escapes project: {target}")
            edges.append({"from": str(path), "syntax": opening,
                          "include": token, "resolved": str(target)})
            if target not in starts:
                dependencies.add(target)
            pending.append(target)
    records = [record(path) for path in sorted(dependencies)]
    edges.sort(key=lambda x: (x["from"], x["include"], x["resolved"]))
    return records, edges, sorted(system)


def construct(created_utc: str) -> dict:
    require(record(PACKET)["sha256"] == EXPECTED_PACKET, "frozen source packet")
    require(record(GATE)["sha256"] == EXPECTED_GATE, "independent source review gate")
    gate = json.loads(GATE.read_text())
    packet = json.loads(PACKET.read_text())
    require(gate["source_packet"]["sha256"] == EXPECTED_PACKET and
            gate["source_packet"]["path"] == str(PACKET),
            "reviewed packet identity")
    read_bound(gate["immutable_design"])
    require(record(SOURCE_GATE)["sha256"] == gate["source_gate"]["sha256"],
            "original source gate")
    for item in packet["local_files"]:
        read_bound(item)
    sources, include_dirs = parse_config(packet)
    starts = sources + [TB]
    dependencies, edges, system = closure(starts, include_dirs)
    require(len(dependencies) == 14 and len(edges) == 55 and
            any(item["path"] == str(BASE / "build/model-attention-rtl-repair-20261008/laya_model_layout_generated.h")
                for item in dependencies) and
            any(item["path"] == str(BASE / "hls/control/full_forward_controller.cpp")
                for item in dependencies),
            "complete observed local include closure")
    old = json.loads(OLD_CPU.read_text())
    old_sources = [Path(item) for item in old["argv"]
                   if item.endswith(".cpp")]
    require(old["exit_code"] == 0 and
            old["argv"][:5] == ["/usr/bin/g++"] + STRICT and
            old_sources[1:-1] == sources[1:],
            "previous accepted vector build's 24 shared C++ sources")
    out = MODULE / "runs/cpu_build_v1/type_producer_binary_cpu"
    argv = (["/usr/bin/g++"] + STRICT +
            [f"-I{path}" for path in include_dirs] +
            [str(path) for path in starts] + ["-lm", "-o", str(out)])
    argv_sha = hashlib.sha256(json.dumps(argv, separators=(",", ":")).encode()).hexdigest()
    return {
        "schema": "d2_type_producer_binary_cpu_closure_supplement_v1",
        "created_utc": created_utc,
        "status": "SOURCE_ONLY_NO_CPU_BUILD_OR_DUT_EXECUTION",
        "accepted_source_review": record(GATE),
        "frozen_source_packet": record(PACKET),
        "original_source_gate": record(SOURCE_GATE),
        "candidate_config": record(CONFIG),
        "independent_cpu_test": record(TB),
        "previous_vector_cpu_build_record": record(OLD_CPU),
        "translation_units": [record(path) for path in starts],
        "transitive_local_includes": dependencies,
        "include_edges": edges,
        "system_include_names_unbound_to_toolchain": system,
        "include_search_dirs": [str(path) for path in include_dirs],
        "source_count": len(sources),
        "translation_unit_count": len(starts),
        "local_include_count": len(dependencies),
        "include_edge_count": len(edges),
        "future_cpu_build_argv": argv,
        "future_cpu_build_argv_sha256": argv_sha,
        "future_output": str(out),
        "future_control_dir": str(MODULE / "runs/cpu_build_v1_control"),
        "future_driver": record(BUILDER),
        "closure_builder": record(Path(__file__)),
        "supplement_note": record(NOTE),
        "not_executed": ["qtype1 materialization", "CPU build/run", "CSim",
                         "HLS", "RTL", "OOC", "board"],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        previous = json.loads(MANIFEST.read_text())
        require(previous == construct(previous["created_utc"]),
                "header closure supplement drift")
        print(f"D2_TYPE_CPU_CLOSURE_PASS sha256={record(MANIFEST)['sha256']}")
        return
    require(not MANIFEST.exists(), "fresh supplement manifest required")
    packet = construct(dt.datetime.now(dt.timezone.utc).isoformat())
    MANIFEST.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    print(f"D2_TYPE_CPU_CLOSURE_READY units={packet['translation_unit_count']} "
          f"includes={packet['local_include_count']} "
          f"edges={packet['include_edge_count']} "
          f"sha256={record(MANIFEST)['sha256']}")


if __name__ == "__main__":
    main()
