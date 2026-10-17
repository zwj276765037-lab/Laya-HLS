#!/usr/bin/env python3
"""Select bounded real ACT/QKV groups from independently generated vectors."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def digest(path: Path) -> dict:
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("act_vectors", type=Path)
    ap.add_argument("qkv_vectors", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    sources = (("act", args.act_vectors.resolve(), list(range(8))),
               ("qkv_row1", args.qkv_vectors.resolve(),
                list(range(64)) + list(range(12288 - 64, 12288))))
    selected = {name: [] for name in ("a", "w", "mask", "dot")}
    identity = []
    for case, directory, indices in sources:
        manifest_path = directory / "manifest.json"
        manifest = json.loads(manifest_path.read_text())
        if manifest["case"] != case or manifest["issues"] != (8 if case == "act" else 12288):
            raise AssertionError(f"source case/count {case}")
        source_files = {key: directory / f"{key}.hex" for key in selected}
        lines = {key: path.read_text().splitlines() for key, path in source_files.items()}
        if any(len(values) != manifest["issues"] for values in lines.values()):
            raise AssertionError(f"source line count {case}")
        for index in indices:
            for key in selected:
                selected[key].append(lines[key][index])
            identity.append({"case": case, "source_issue": index})
        identity.append({"case": case, "manifest": digest(manifest_path),
                         "source_files": {key: digest(path) for key, path in source_files.items()}})
    outputs = {}
    for key, lines in selected.items():
        path = output / f"{key}.hex"
        path.write_text("\n".join(lines) + "\n")
        outputs[key] = digest(path)
    report = {"schema": "tm1tn8_integer_real_replay_v1",
              "issues": len(selected["a"]), "act_issues": 8,
              "qkv_issues": 128, "source_identity": identity,
              "outputs": outputs, "generator": digest(Path(__file__))}
    (output / "manifest.json").write_text(json.dumps(report, indent=2) + "\n")
    print(f"TM1TN8_INTEGER_REPLAY_VECTORS_PASS issues={report['issues']}")


if __name__ == "__main__":
    main()
