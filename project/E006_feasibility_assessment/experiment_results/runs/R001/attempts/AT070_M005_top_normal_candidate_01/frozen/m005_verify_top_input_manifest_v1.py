#!/usr/bin/env python3
"""Verify a frozen M005 top simulation input closure before each xsim spawn."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import sys


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = {"schema": "m005-top-preflight-v1",
              "at": datetime.now(timezone.utc).isoformat(),
              "status": "REJECT", "spawned": False}
    try:
        manifest = json.loads(args.manifest.read_text())
        entries = manifest["files"]
        if manifest["schema"] != "m005-top-inputs-v1" or not entries:
            raise ValueError("invalid manifest schema or empty file set")
        seen = set()
        for entry in entries:
            path = Path(entry["path"])
            if path in seen or not path.is_file():
                raise ValueError(f"duplicate or missing input: {path}")
            seen.add(path)
            if (path.stat().st_size != entry["bytes"] or
                    sha256(path) != entry["sha256"]):
                raise ValueError(f"input identity mismatch: {path}")
        result.update(status="ACCEPT", files=len(entries),
                      manifest_sha256=sha256(args.manifest))
        code = 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        result["reason"] = str(exc)
        code = 2
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"M005_TOP_PREFLIGHT_{result['status']}")
    return code


if __name__ == "__main__":
    sys.exit(main())
