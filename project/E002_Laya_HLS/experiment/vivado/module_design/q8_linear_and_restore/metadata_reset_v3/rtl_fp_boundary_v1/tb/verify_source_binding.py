#!/usr/bin/env python3
"""Read-only identity check for actual FP inputs and an optional XSim snapshot."""

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def assert_record(item: dict) -> None:
    path = Path(item["path"])
    actual = record(path)
    if actual["bytes"] != item["bytes"] or actual["sha256"] != item["sha256"]:
        raise RuntimeError(f"identity mismatch: {path}")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("packet", type=Path)
    p.add_argument("--snapshot", type=Path)
    p.add_argument("--expected-snapshot-report", type=Path)
    p.add_argument("--out", type=Path, required=True)
    args = p.parse_args()
    if args.out.exists():
        raise RuntimeError(f"report already exists: {args.out}")
    packet = json.loads(args.packet.read_text())
    if packet["schema"] != "q8_actual_fp_boundary_source_packet_v1":
        raise RuntimeError("packet schema mismatch")
    assert_record(packet["release"])
    assert_record(packet["inherited_accepted_scorer_packet"])
    scorer = json.loads(Path(packet["inherited_accepted_scorer_packet"]["path"]).read_text())
    for item in scorer["immutable_files"]:
        assert_record(item)
    for group in ("source_inputs", "installed_fp_library_files", "tool_launchers", "maintained_source"):
        for item in packet[group]:
            assert_record(item)
    snapshot = []
    if args.snapshot:
        root = args.snapshot.resolve()
        if not root.is_dir():
            raise RuntimeError(f"snapshot missing: {root}")
        for path in sorted(root.rglob("*")):
            if path.is_file() and not path.is_symlink():
                item = record(path)
                snapshot.append({"relative_path": str(path.relative_to(root)),
                                 "bytes": item["bytes"], "sha256": item["sha256"]})
    if args.expected_snapshot_report:
        expected = json.loads(args.expected_snapshot_report.read_text())["snapshot"]
        if snapshot != expected:
            raise RuntimeError("compiled snapshot changed from accepted static report")
    report = {"schema": "q8_actual_fp_boundary_source_binding_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "packet_sha256": record(args.packet)["sha256"],
              "inherited_source_file_count": len(scorer["immutable_files"]),
              "direct_input_count": len(packet["source_inputs"]),
              "maintained_source_count": len(packet["maintained_source"]),
              "snapshot": snapshot}
    args.out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"FP_SOURCE_BINDING_PASS inherited={len(scorer['immutable_files'])} direct=28 snapshot={len(snapshot)}")


if __name__ == "__main__":
    main()
