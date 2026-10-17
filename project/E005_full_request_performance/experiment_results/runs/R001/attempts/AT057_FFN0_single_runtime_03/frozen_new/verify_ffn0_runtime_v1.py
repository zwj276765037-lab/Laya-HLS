#!/usr/bin/env python3
"""Reject a missing or changed FFN0 runtime package before xsim is spawned."""
import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import sys

ROOT_KEYS = ("GFIXTURE", "AFIXTURE", "WFIXTURE", "STREAMS", "WI_AFIXTURE",
             "WI_WFIXTURE", "WI_STREAMS", "LN_FIXTURE", "BOUND_FIXTURE",
             "FFN_FIXTURE")
FIXTURE_ROLES = {"downstream_fixtures", "LN_fixture", "bound_identity",
                 "ffn_fixture"}


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def check(entry, target=None):
    path = Path(target if target is not None else entry["path"]).resolve(strict=True)
    if not path.is_file() or path.stat().st_size != entry["bytes"] or \
            sha(path) != entry["sha256"]:
        raise ValueError(f"file bytes/SHA mismatch: {path}")
    return str(path)


def verify(manifest, cwd, roots):
    entries = manifest["files"]
    if not cwd.is_dir() or not (cwd / "xsim.dir").is_dir():
        raise ValueError("resolved xsim cwd/xsim.dir absent")
    roms = {Path(item["path"]).name: item for item in entries
            if item["role"] == "LN_frozen" and
            Path(item["path"]).name.endswith("ROM_AUTO_1R.dat")}
    if len(roms) != 7:
        raise ValueError(f"expected 7 frozen ROMs, found {len(roms)}")
    for name, item in roms.items():
        check(item)
        check(item, cwd / name)
    fixtures = [item for item in entries if item["role"] in FIXTURE_ROLES]
    for item in fixtures:
        check(item)
    expected = {Path(item["path"]).resolve() for item in fixtures}
    if set(roots) != set(ROOT_KEYS):
        raise ValueError("missing or extra plusarg fixture roots")
    if len({str(path) for path in roots.values()}) != len(ROOT_KEYS):
        raise ValueError("aliased plusarg fixture roots")
    for key, root in roots.items():
        if not root.is_dir():
            raise ValueError(f"missing {key} fixture directory")
        actual = {path.resolve() for path in root.iterdir() if path.is_file()}
        wanted = {path for path in expected if root in path.parents}
        if not wanted or actual != wanted:
            raise ValueError(f"{key} fixture set differs: {len(actual)}/{len(wanted)}")
    return {"roms": len(roms), "fixtures": len(fixtures),
            "roots": {key: str(root) for key, root in roots.items()}}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--cwd", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--root", action="append", nargs=2, metavar=("KEY", "DIR"),
                        required=True)
    args = parser.parse_args()
    result = {"schema": "ffn0-runtime-preflight-v1",
              "checked_at": dt.datetime.now(dt.timezone.utc).isoformat(),
              "status": "REJECT", "spawned": False,
              "cwd": str(args.cwd.resolve())}
    try:
        roots = {key: Path(value).resolve(strict=True) for key, value in args.root}
        if len(roots) != len(args.root):
            raise ValueError("duplicate fixture root key")
        manifest = json.loads(args.manifest.read_text())
        result.update(verify(manifest, args.cwd.resolve(strict=True), roots))
        result["status"] = "ACCEPT"
        result["manifest_sha256"] = sha(args.manifest)
        code = 0
    except (OSError, ValueError, KeyError, TypeError) as exc:
        result["reason"] = str(exc)
        code = 2
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    if code:
        print(f"FFN0_RUNTIME_PREFLIGHT_REJECT: {result['reason']}", file=sys.stderr)
    else:
        print("FFN0_RUNTIME_PREFLIGHT_ACCEPT")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
