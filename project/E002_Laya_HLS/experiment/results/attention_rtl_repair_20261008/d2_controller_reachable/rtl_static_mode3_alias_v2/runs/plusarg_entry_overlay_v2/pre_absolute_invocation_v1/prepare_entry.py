#!/usr/bin/env python3
"""One guarded preparation for the reviewed Mode3 entry-only retry."""

from __future__ import annotations

import copy
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import subprocess


MODULE = Path(__file__).resolve().parents[2]
RUNS = MODULE / "runs"
OVERLAY = Path(__file__).resolve().parent
RESULTS = MODULE.parents[1]
FROZEN = MODULE / "source/source_packet.json"
PACKET = OVERLAY / "source_packet_entry_v2.json"
RUNNER = OVERLAY / "run_mode3_entry.sh"
RELEASE = RESULTS / "reviewer_d2_i_mode3_plusarg_entry_repair_finite_runtime_release.json"
FAILURE = RUNS / "runtime_first_failure_evidence_v1.json"
SNAPSHOT_MANIFEST = RUNS / "static_build_alias_v2_a1/snapshot_manifest.json"
ARCHIVE = RUNS / "pre_retry_mutable_archive"
RUNTIME = RUNS / "rtl_mode3_alias_v2_runtime_args_v2"
EXPECTED = {
    FROZEN: "f368dae3b61bba170703f07d986be0f85527b7390297c05b8f1dca3b95685ee4",
    RELEASE: "d8086092e99cfc42ed3157b2c92a38bfd06c7d06109ad4bf3e81f857a1681b09",
    FAILURE: "1505ccaa99ab771b344645fd830537d0e33d6c6c695295cc03065da2e2b66ae5",
    SNAPSHOT_MANIFEST: "a10d91ccb0f74a7bc46496f65b97fad7e5e7d167926334b81d9ff907af632240",
    RUNNER: "0b930af48d95ec51b7ad29ca105560768abf43e7a353e63933d6ad9c514f1581",
}


def digest(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            result.update(block)
    return result.hexdigest()


def record(path: Path) -> dict:
    return {"path": str(path), "bytes": path.stat().st_size, "sha256": digest(path)}


def write_json(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def check_record(info: dict, path: Path) -> None:
    assert path.is_file() and path.stat().st_size == info["bytes"]
    assert digest(path) == info["sha256"]


def main() -> None:
    assert not PACKET.exists() and not ARCHIVE.exists() and not RUNTIME.exists()
    for path, expected in EXPECTED.items():
        assert digest(path) == expected, f"frozen identity changed: {path}"

    frozen = json.loads(FROZEN.read_text())
    failure = json.loads(FAILURE.read_text())
    manifest = json.loads(SNAPSHOT_MANIFEST.read_text())
    root = Path(frozen["paths"]["snapshot_root"])
    assert root == RUNS / "static_build_alias_v2_a1/xsim.dir"
    assert frozen["paths"]["static_build_root"] == str(root.parent)
    assert frozen["paths"]["runtime_root"] == str(RUNS / "rtl_mode3_alias_v2_runtime_held")
    assert frozen["paths"]["source_packet"] == str(FROZEN)
    assert manifest["file_count"] == len(manifest["files"]) == 328
    assert manifest["snapshot_root"] == str(root)
    assert frozen["paths"]["snapshot_manifest"] == str(SNAPSHOT_MANIFEST)

    mutable = failure["mutable_archive"]
    assert len(mutable) == 4
    compiled = set(manifest["files"])
    assert not (compiled & set(mutable))
    present = {str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()}
    assert present == compiled | set(mutable), "unexpected static snapshot file set"
    for relative, info in manifest["files"].items():
        check_record(info, root / relative)
    for relative, info in mutable.items():
        source = root / relative
        previous = Path(info["archive_path"])
        check_record(info["archive"], previous)
        assert source.stat().st_size == previous.stat().st_size
        assert digest(source) == digest(previous), f"first failure mutable drift: {relative}"

    new_packet = copy.deepcopy(frozen)
    new_packet["paths"]["source_packet"] = str(PACKET)
    new_packet["paths"]["runtime_root"] = str(RUNTIME)
    new_packet["created_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()
    new_packet["entry_run_metadata"] = {
        "schema": "mode3_plusarg_entry_retry_v2",
        "scope": "one unary Mode3 APPLY_CAND_MASK, 16 candidates",
        "dut_cycle_limit": 131072,
        "total_cycle_limit": 140000,
        "maximum_runtime_invocations": 1,
    }
    new_packet["entry_runner"] = record(RUNNER)
    new_packet["entry_reviewer_release"] = record(RELEASE)
    new_packet["entry_previous_failure"] = record(FAILURE)
    restored = copy.deepcopy(new_packet)
    for key in ("entry_run_metadata", "entry_runner", "entry_reviewer_release", "entry_previous_failure"):
        restored.pop(key)
    restored["created_utc"] = frozen["created_utc"]
    restored["paths"]["source_packet"] = str(FROZEN)
    restored["paths"]["runtime_root"] = frozen["paths"]["runtime_root"]
    assert restored == frozen, "packet changed beyond released fields"
    write_json(PACKET, new_packet)

    ARCHIVE.mkdir()
    moved = {}
    for relative, info in sorted(mutable.items()):
        source = root / relative
        destination = ARCHIVE / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        os.replace(source, destination)
        check_record(info["archive"], destination)
        moved[relative] = {
            "new_archive": record(destination),
            "previous_archive": record(Path(info["archive_path"])),
        }
    write_json(ARCHIVE / "manifest.json", {
        "schema": "mode3_pre_retry_mutable_archive_v1",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "first_failure": record(FAILURE),
        "files": moved,
    })

    present = {str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()}
    assert present == compiled, "snapshot not restored to original 328 files"
    for relative, info in manifest["files"].items():
        check_record(info, root / relative)
    RUNTIME.mkdir()

    command = [
        "python3", str(MODULE / "tb/verify_binding.py"), str(PACKET),
        "--stage", "runtime",
        "--static-build-root", str(root.parent),
        "--runtime-root", str(RUNTIME),
        "--prepared-root", frozen["paths"]["prepared_root"],
        "--fresh-library-hashes",
    ]
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=False)
    (OVERLAY / "preflight_binding.log").write_text(result.stdout)
    assert result.returncode == 0, f"binding failed: {result.returncode}"
    assert "D2_MODE3_BINDING_PASS stage=runtime" in result.stdout
    write_json(OVERLAY / "preparation_manifest.json", {
        "schema": "mode3_plusarg_entry_guarded_preparation_v2",
        "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
        "packet": record(PACKET),
        "runner": record(RUNNER),
        "prepare_script": record(Path(__file__).resolve()),
        "reviewer_release": record(RELEASE),
        "first_failure": record(FAILURE),
        "snapshot_manifest": record(SNAPSHOT_MANIFEST),
        "snapshot_files_restored": len(compiled),
        "mutable_archive_manifest": record(ARCHIVE / "manifest.json"),
        "runtime_root": str(RUNTIME),
        "binding_log": record(OVERLAY / "preflight_binding.log"),
        "binding_exit_code": result.returncode,
    })
    print("D2_MODE3_ENTRY_PREPARATION_PASS compiled=328 mutable_archived=4")


if __name__ == "__main__":
    main()
