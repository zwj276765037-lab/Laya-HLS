#!/usr/bin/env python3
"""Bind the four frozen token requests to the current CPU raw model package."""

import argparse
import hashlib
import json
from pathlib import Path
import struct

NAMES = ("B2_S128", "accepted_gamma_failure", "B1_from_b0_S128",
         "B1_from_b1_S128")
OLD_BUILD = bytes.fromhex("fe067c8aa0627ad770096f9721394645")


def sha(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument("--output-dir", type=Path, required=True)
    args = parser.parse_args()
    if args.output_dir.exists():
        raise SystemExit(f"output already exists: {args.output_dir}")
    manifest = json.loads((args.package / "manifest.json").read_text())
    tags = b"".join(bytes.fromhex(manifest["tags"][name])
                    for name in ("model", "numeric", "layout", "build"))
    aux = (args.package / "aux.bin").read_bytes()
    if len(tags) != 64 or aux[32:96] != tags or tags[48:64] == OLD_BUILD:
        raise ValueError("package header or new build identity invalid")
    args.output_dir.mkdir(parents=True)
    report = {"package_manifest": str(args.package / "manifest.json"),
              "package_manifest_sha256": sha((args.package / "manifest.json").read_bytes()),
              "tags": manifest["tags"], "requests": []}
    for index, name in enumerate(NAMES, 1):
        source = args.input_dir / f"{name}.request.bin"
        data = source.read_bytes()
        if (data[:4] != b"LYRQ" or data[88:104] != OLD_BUILD or
                struct.unpack_from("<I", data, 16)[0] != len(data) or
                struct.unpack_from("<QQ", data, 24) != (index, 1)):
            raise ValueError(f"frozen request mismatch: {source}")
        rebound = data[:40] + tags + data[104:]
        target = args.output_dir / source.name
        target.write_bytes(rebound)
        report["requests"].append({"name": name, "source": str(source),
                                   "target": str(target), "B": struct.unpack_from("<H", data, 20)[0],
                                   "S": struct.unpack_from("<H", data, 22)[0],
                                   "request_id": index, "generation": 1,
                                   "source_sha256": sha(data),
                                   "target_sha256": sha(rebound)})
    (args.output_dir / "identity_manifest.json").write_text(
        json.dumps(report, indent=2) + "\n")
    print("CPU_REQUEST_BIND_PASS", len(NAMES), manifest["tags"]["build"])


if __name__ == "__main__":
    main()
