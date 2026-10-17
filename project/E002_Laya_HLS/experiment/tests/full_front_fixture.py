#!/usr/bin/env python3
"""Derive the three type-embedding rows from the frozen GGUF source."""

from __future__ import annotations

import json
import pathlib
import sys
import traceback

import numpy as np

from full_fixture_test import Evidence, sha
import full_reference as reference


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: full_front_fixture.py ROOT OUTPUT_DIR", file=sys.stderr)
        return 2
    root = pathlib.Path(sys.argv[1]).resolve()
    output = pathlib.Path(sys.argv[2]).resolve()
    output.mkdir(parents=True, exist_ok=True)
    report: dict = {"status": "GENERATING",
                    "role": "independent_GGUF_type_embedding_rows"}
    evidence = None
    try:
        evidence = Evidence(root, output)
        rows = np.stack([reference.embedding_row(
            evidence.q8_row("type_emb.weight", i)) for i in range(3)])
        data = np.asarray(rows, dtype="<f4").tobytes(order="C")
        path = output / "type_embedding.f32.bin"
        path.write_bytes(data)
        report["type_embedding"] = {"path": str(path),
                                    "shape": [3, 1024],
                                    "bytes": len(data),
                                    "sha256": sha(data)}
        report["status"] = "GENERATED_NO_DUT_COMPARISON"
        return 0
    except Exception as exc:
        report["status"] = "FAIL"
        report["error"] = f"{type(exc).__name__}: {exc}"
        report["traceback"] = traceback.format_exc()
        print(report["error"], file=sys.stderr)
        return 1
    finally:
        if evidence is not None:
            evidence.model.close()
            report["checked_reference_files"] = evidence.checked
        (output / "full_front_fixture_report.json").write_text(
            json.dumps(report, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())
