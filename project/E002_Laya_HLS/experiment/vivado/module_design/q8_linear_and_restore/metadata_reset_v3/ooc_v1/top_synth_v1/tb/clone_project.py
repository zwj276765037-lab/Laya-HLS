#!/usr/bin/env python3
"""Clone the accepted a2 project into a fresh root and rebind only XPR Path."""

from __future__ import annotations

import argparse
import datetime as dt
import json
from pathlib import Path
import shutil

from project_identity import (SOURCE, XPR, check_clone, check_source,
                              rebound_xpr)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    destination = args.destination.absolute()
    if destination.exists() or args.out.exists() or not destination.parent.is_dir():
        raise RuntimeError("fresh destination, existing parent and fresh report required")
    if destination == SOURCE or destination.is_relative_to(SOURCE) or \
            SOURCE.is_relative_to(destination):
        raise RuntimeError("clone destination overlaps accepted a2 project")
    source_binding, source_rows = check_source()
    shutil.copytree(SOURCE, destination, symlinks=False, copy_function=shutil.copy2)
    (destination / XPR).write_bytes(rebound_xpr((SOURCE / XPR).read_bytes(),
                                                 destination))
    clone = check_clone(destination, source_rows)
    report = {"schema": "q8_top_ooc_clone_execution_evidence_v1",
              "created_utc": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "BYTE_EXACT_CLONE_WITH_XPR_PROJECT_PATH_ONLY",
              "accepted_source_root": str(SOURCE), "destination": str(destination),
              "source_binding": source_binding,
              "source_file_count": len(source_rows),
              "clone_file_count": clone["clone_file_count"],
              "compiled_file_count": len(clone["actual_compile_closure"]),
              "imported_ip_count": clone["imported_ip_count"],
              "xpr_change": "only Project Path attribute",
              "top_synthesis": "NOT_RUN"}
    args.out.write_text(json.dumps(report, indent=2) + "\n")
    print(f"Q8_TOP_OOC_CLONE_PASS files={clone['clone_file_count']} "
          f"compiled={len(clone['actual_compile_closure'])}")


if __name__ == "__main__":
    main()
