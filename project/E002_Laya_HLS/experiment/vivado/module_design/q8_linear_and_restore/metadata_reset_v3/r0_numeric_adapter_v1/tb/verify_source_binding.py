#!/usr/bin/env python3
"""Read-only binding of R0 sources and an optional exact XSim snapshot."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def record(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def check(item: dict) -> None:
    actual = record(Path(item["path"]))
    if any(actual[key] != item[key] for key in ("bytes", "sha256")):
        raise RuntimeError(f"source identity mismatch: {item['path']}")


def check_preimages(packet: dict) -> None:
    for key in ("preimage_archive_manifest", "preserved_v1_source_packet",
                "preserved_v1_source_check", "astra_original_design_prefix",
                "astra_design_prefix_check"):
        check(packet[key])
    archive_root = ROOT / "source/preimages/v1"
    if packet["preimage_archive_manifest"]["path"] != str(archive_root / "archive_manifest.json"):
        raise RuntimeError("v1 archive location drift")
    archive = json.loads(Path(packet["preimage_archive_manifest"]["path"]).read_text())
    if (archive["schema"] != "q8_r0_source_v1_preimage_archive_v1" or
            packet["preimage_archive_file_count"] != len(archive["files"]) or
            len(archive["files"]) != 18 or
            archive["source_packet_sha256"] !=
            packet["preserved_v1_source_packet"]["sha256"]):
        raise RuntimeError("v1 archive structure drift")
    paths = set()
    for row in archive["files"]:
        relative = Path(row["relative_path"])
        if (relative.is_absolute() or ".." in relative.parts or
                row["archive_path"] != str(archive_root / relative) or
                row["original_path"] != str(ROOT / relative) or
                str(relative) in paths):
            raise RuntimeError("v1 archive path drift")
        paths.add(str(relative))
        check({"path": row["archive_path"], "bytes": row["bytes"],
               "sha256": row["sha256"]})
    if (packet["preserved_v1_source_packet"]["path"] !=
            str(archive_root / "source/source_packet.json") or
            packet["preserved_v1_source_check"]["path"] !=
            str(archive_root / "source/source_check.json") or
            json.loads((archive_root / "source/source_packet.json").read_text())["schema"] !=
            "q8_r0_finite_domain_source_packet_v1"):
        raise RuntimeError("preserved v1 packet/check drift")
    design = Path(packet["astra_original_design_prefix"]["path"]).read_bytes()
    prefix = json.loads(Path(packet["astra_design_prefix_check"]["path"]).read_text())
    if (packet["astra_original_design_prefix"]["path"] !=
            str(ROOT / "source/preimages/astra_original_design.md") or
            packet["astra_design_prefix_check"]["path"] !=
            str(ROOT / "source/preimages/astra_design_prefix_check.json") or
            len(design) != 13914 or
            hashlib.sha256(design).hexdigest() !=
            "321080d93185336aba66048af759cd982be143fe524f669f3de0c06c7729077b" or
            not (ROOT / "source/design.md").read_bytes().startswith(design) or
            prefix["preimage_path"] != str(ROOT / "source/preimages/astra_original_design.md") or
            prefix["bytes"] != len(design) or
            prefix["sha256"] != hashlib.sha256(design).hexdigest() or
            prefix["current_prefix_exact"] is not True):
        raise RuntimeError("Astra original design prefix drift")


def snapshot(root: Path) -> list[dict]:
    if not root.is_dir():
        raise RuntimeError(f"compiled snapshot missing: {root}")
    rows = []
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise RuntimeError(f"snapshot symlink: {path}")
        if path.is_file():
            item = record(path)
            rows.append({"relative_path": str(path.relative_to(root)),
                         "bytes": item["bytes"], "sha256": item["sha256"]})
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packet", type=Path)
    parser.add_argument("--snapshot", type=Path)
    parser.add_argument("--expected-snapshot-report", type=Path)
    parser.add_argument("--allow-runtime-mutables", action="store_true")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise RuntimeError(f"fresh report path required: {args.out}")
    packet = json.loads(args.packet.read_text())
    if packet.get("schema") != "q8_r0_finite_domain_source_packet_v2":
        raise RuntimeError("R0 packet schema mismatch")
    check_preimages(packet)
    for key in ("inherited_actual_fp_packet", "inherited_accepted_scorer_packet",
                "accepted_fp_119_evidence", "accepted_fp_pre_runtime_snapshot_report"):
        check(packet[key])
    fp = json.loads(Path(packet["inherited_actual_fp_packet"]["path"]).read_text())
    scorer = json.loads(Path(packet["inherited_accepted_scorer_packet"]["path"]).read_text())
    if (packet["source_inputs"] != fp["source_inputs"] or
            packet["installed_fp_library_files"] != fp["installed_fp_library_files"] or
            packet["tool_launchers"] != fp["tool_launchers"] or
            packet["xsim_link_libraries"] != fp["xsim_link_libraries"]):
        raise RuntimeError("seven-wrapper or library lineage drift")
    for group in ("source_inputs", "installed_fp_library_files", "tool_launchers",
                  "maintained_source"):
        for item in packet[group]:
            check(item)
    for item in scorer["immutable_files"]:
        check(item)
    actual_snapshot = snapshot(args.snapshot.resolve()) if args.snapshot else []
    mutable_changes = []
    if args.expected_snapshot_report:
        if not args.snapshot:
            raise RuntimeError("expected snapshot requires --snapshot")
        expected = json.loads(args.expected_snapshot_report.read_text())["snapshot"]
        old = {row["relative_path"]: row for row in expected}
        new = {row["relative_path"]: row for row in actual_snapshot}
        if len(old) != len(expected) or len(new) != len(actual_snapshot):
            raise RuntimeError("duplicate snapshot path")
        allow = (set(packet["snapshot_runtime_mutable_allowlist"])
                 if args.allow_runtime_mutables else set())
        for name in sorted(old.keys() | new.keys()):
            if old.get(name) != new.get(name):
                if name not in allow:
                    raise RuntimeError(f"compiled snapshot changed: {name}")
                mutable_changes.append({"relative_path": name,
                                        "before": old.get(name), "after": new.get(name)})
    report = {"schema": "q8_r0_finite_domain_source_binding_v2",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "packet_sha256": record(args.packet)["sha256"],
              "preserved_v1_archive_files": packet["preimage_archive_file_count"],
              "inherited_scorer_files": len(scorer["immutable_files"]),
              "direct_input_count": len(packet["source_inputs"]),
              "maintained_source_count": len(packet["maintained_source"]),
              "snapshot": actual_snapshot, "allowlisted_mutable_changes": mutable_changes}
    args.out.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"R0_SOURCE_BINDING_PASS direct={len(packet['source_inputs'])} "
          f"snapshot={len(actual_snapshot)} mutable={len(mutable_changes)}")


if __name__ == "__main__":
    main()
