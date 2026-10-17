#!/usr/bin/env python3
"""Seal a read-only a2 preflight or a byte-exact relocated project clone."""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path

from project_identity import check_clone, check_source, SOURCE


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--source-check", action="store_true")
    mode.add_argument("--clone", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise RuntimeError(f"fresh report path required: {args.out}")
    source_binding, source_rows = check_source()
    report = {"schema": "q8_top_ooc_isolated_clone_identity_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "SOURCE_PREFLIGHT_PASS" if args.source_check else "CLONE_PREFLIGHT_PASS",
              "accepted_source_root": str(SOURCE),
              "source_binding": source_binding,
              "source_file_count": len(source_rows),
              "source_files": source_rows}
    if args.clone:
        report.update(check_clone(args.clone, source_rows))
        report["clone_root"] = str(args.clone.resolve())
    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Q8_TOP_OOC_{report['status']} source={len(source_rows)} "
          f"clone={report.get('clone_file_count', 0)}")


if __name__ == "__main__":
    main()
