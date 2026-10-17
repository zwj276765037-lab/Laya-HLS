#!/usr/bin/env python3
"""Freeze reviewed-input closure for the corrected D2-I code draft."""

from __future__ import annotations

import difflib
import hashlib
import json
from pathlib import Path
import shutil


MODULE = Path(__file__).resolve().parent
ROOT = MODULE.parents[2]
FIXTURE = MODULE / "tb/fixture_v2"
V1 = MODULE / "draft_snapshots/v1_before_review_fixes"
V2 = MODULE / "draft_snapshots/v2_after_review_fixes"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def artifact(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": sha(path)}


def verify(path: Path, expected: str, length: int | None = None) -> None:
    if not path.is_file() or sha(path) != expected or (length is not None and path.stat().st_size != length):
        raise RuntimeError(f"input integrity mismatch: {path}")


def main() -> None:
    listing = json.loads((MODULE / "source_list_manifest.json").read_text())
    fixture_report = json.loads((FIXTURE / "fixture_report.json").read_text())
    if fixture_report["status"] != "GENERATED_NO_DUT_COMPARISON":
        raise RuntimeError("fixture report has unexpected status")
    for item in listing["linked_production_sources"]:
        verify(Path(item["path"]), item["sha256"])
    if len(listing["linked_production_sources"]) != 24:
        raise RuntimeError("not 24 official linked sources")
    verify(Path(listing["included_controller"]["path"]),
           "23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623")
    for item in listing["isolated_tops"].values():
        for key in ("wrapper", "tb", "config"):
            verify(Path(item[key]["path"]), item[key]["sha256"])
    for item in fixture_report["files"].values():
        verify(Path(item["path"]), item["sha256"], item["bytes"])
    checked = fixture_report["checked_reference_files"]
    if not any(name.endswith("/ir_1469.bin") and value["sha256"] ==
               "658668099f53516791f192f6641dc9819d36c0aad1ce8f6c624faaca1c8ca0f5"
               for name, value in checked.items()):
        raise RuntimeError("candidate_raw_logits alias source omitted")
    for name, item in checked.items():
        if "::" in name:
            model_name, _ = name.split("::", 1)
            model = Path(model_name)
            with model.open("rb") as stream:
                stream.seek(item["absolute_file_offset"])
                raw = stream.read(item["bytes"])
            if len(raw) != item["bytes"] or hashlib.sha256(raw).hexdigest() != item["sha256"]:
                raise RuntimeError(f"GGUF range mismatch: {name}")
        else:
            verify(Path(name), item["sha256"], item["bytes"])
    package = ROOT / "build/model-attention-rtl-repair-20261008"
    package_files = [package / name for name in
                     ("manifest.json", "w_q0.bin", "w_q1.bin", "w_scale.bin", "aux.bin")]
    package_files += [ROOT / "config/full_sources.cmake", ROOT / "tests/full_reference.py",
                      ROOT / "tests/full_fixture_test.py", ROOT / "tools/hls_guard_helpers.py"]
    files = [MODULE / "make_configs.py", MODULE / "source_list_manifest.json",
             MODULE / "tb/generate_fixture.py", MODULE / "freeze_v2.py"]
    files += [MODULE / f"config_{name}.cfg" for name in ("linear", "vector")]
    files += [MODULE / "source/linear_controller_slice.cpp",
              MODULE / "source/vector_controller_slice.cpp",
              MODULE / "tb/test_linear_controller_slice.cpp",
              MODULE / "tb/test_vector_controller_slice.cpp"]
    files += sorted(FIXTURE.iterdir())
    files += package_files
    files += [Path(listing["included_controller"]["path"])]
    files += [Path(item["path"]) for item in listing["linked_production_sources"]]
    files += [Path(name) for name in checked if "::" not in name]
    for directory in (MODULE / "fixture_guard_v2", MODULE / "syntax_guard_v2"):
        files += sorted(p for p in directory.iterdir() if p.is_file())
    V2.mkdir(parents=True, exist_ok=True)
    for relative in ("source/linear_controller_slice.cpp", "source/vector_controller_slice.cpp",
                     "tb/test_linear_controller_slice.cpp", "tb/test_vector_controller_slice.cpp",
                     "tb/generate_fixture.py", "config_linear.cfg", "config_vector.cfg",
                     "make_configs.py", "source_list_manifest.json"):
        dest = V2 / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(MODULE / relative, dest)
    diffs = []
    for relative in ("source/linear_controller_slice.cpp", "source/vector_controller_slice.cpp",
                     "tb/test_linear_controller_slice.cpp"):
        diffs.extend(difflib.unified_diff((V1 / relative).read_text().splitlines(keepends=True),
                                          (V2 / relative).read_text().splitlines(keepends=True),
                                          fromfile=f"v1/{relative}", tofile=f"v2/{relative}"))
    (V2 / "review_fixes.diff").write_text("".join(diffs))
    files += [V2 / "review_fixes.diff"]
    for file in V2.rglob("*"):
        if file.is_file() and file.name != "draft_v2_pre_review_packet.json":
            files.append(file)
    fixture_guard = json.loads((MODULE / "fixture_guard_v2/guard_result.json").read_text())
    syntax_guard = json.loads((MODULE / "syntax_guard_v2/guard_result.json").read_text())
    if any(result["child_exit_code"] != 0 or result["trigger"] is not None
           for result in (fixture_guard, syntax_guard)):
        raise RuntimeError("fixture/syntax pre-review guard failed")
    packet = {
        "status": "CORRECTED_DRAFT_FOR_ASTRA_PRE_REVIEW_NO_CPU_CSIM_CSYNTH",
        "replaces_v1_review": artifact(MODULE.parent / "reviewer_d2_i_draft_v1_pre_review.json"),
        "previous_v1_packet": artifact(V1 / "draft_v1_pre_review_packet.json"),
        "source_list_sha256": sha(MODULE / "source_list_manifest.json"),
        "controller_sha256": sha(Path(listing["included_controller"]["path"])),
        "official_linked_source_count": 24,
        "fixture_report": artifact(FIXTURE / "fixture_report.json"),
        "fixture_generated_but_not_compared_to_DUT": True,
        "checked_reference_ranges": checked,
        "guarded_fixture_job": fixture_guard,
        "guarded_syntax_only_job": syntax_guard,
        "review_fixes_diff": artifact(V2 / "review_fixes.diff"),
        "artifacts": {str(path.resolve()): artifact(path) for path in sorted(set(files))},
        "not_run": ["CPU functional", "Vitis HLS CSim", "csynth", "IR audit", "RTL simulation"]}
    output = MODULE / "draft_v2_pre_review_packet.json"
    output.write_text(json.dumps(packet, indent=2, sort_keys=True) + "\n")
    shutil.copyfile(output, V2 / output.name)
    print(output, sha(output), "artifacts", len(packet["artifacts"]))


if __name__ == "__main__":
    main()
