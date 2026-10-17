#!/usr/bin/env python3
"""Verify a frozen LNQ xsim runtime package immediately before launch."""

import argparse
import datetime as dt
import hashlib
import json
from pathlib import Path
import subprocess
import sys


FIXTURE_ROLES = {"downstream_fixtures", "LN_fixture", "bound_identity"}
REQUIRED_PLUSARGS = {
    "GFIXTURE", "AFIXTURE", "WFIXTURE", "STREAMS", "WI_AFIXTURE",
    "WI_WFIXTURE", "WI_STREAMS", "LN_FIXTURE", "FIXTURE", "BOUND_FIXTURE",
}


def digest(path):
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            value.update(block)
    return value.hexdigest()


def check_file(path, expected):
    path = Path(path).resolve(strict=True)
    if not path.is_file():
        raise ValueError(f"not a file: {path}")
    size = path.stat().st_size
    sha = digest(path)
    if size != expected["bytes"] or sha != expected["sha256"]:
        raise ValueError(f"bytes/SHA mismatch: {path}")
    return {"path": str(path), "bytes": size, "sha256": sha}


def launch_parts(command):
    if command.count("--") != 1:
        raise ValueError("launch must contain one guard/child separator")
    split = command.index("--")
    guard, child = command[:split], command[split + 1:]
    if guard.count("--cwd") != 1 or not child or Path(child[0]).name != "xsim":
        raise ValueError("launch does not identify guard cwd and xsim")
    cwd = guard[guard.index("--cwd") + 1]
    plusargs = {}
    for index, token in enumerate(child[:-1]):
        if token == "-testplusarg":
            key, sep, value = child[index + 1].partition("=")
            if not sep or key in plusargs:
                raise ValueError("missing or repeated xsim plusarg")
            plusargs[key] = value
    if set(plusargs) != REQUIRED_PLUSARGS:
        raise ValueError(f"xsim plusargs differ: {sorted(set(plusargs) ^ REQUIRED_PLUSARGS)}")
    return cwd, plusargs, guard, child


def verify(manifest_path, launch_path, requested_cwd):
    manifest = json.loads(manifest_path.read_text())
    launch = json.loads(launch_path.read_text())
    command = launch["command"]
    guard_cwd, plusargs, guard, child = launch_parts(command)
    cwd = requested_cwd.resolve(strict=True)
    if cwd != Path(guard_cwd).resolve(strict=True):
        raise ValueError("requested cwd differs from guarded xsim cwd")
    if child.count("-xsimdir") > 1:
        raise ValueError("repeated xsimdir option")
    if "-xsimdir" in child:
        xsim_arg = Path(child[child.index("-xsimdir") + 1])
        xsimdir = (xsim_arg if xsim_arg.is_absolute() else cwd / xsim_arg).resolve(strict=True)
    else:
        xsimdir = (cwd / "xsim.dir").resolve(strict=True)
    if not xsimdir.is_dir():
        raise ValueError("xsim.dir is absent")
    guard_entries = [item for item in manifest["files"] if item["role"] == "guard"]
    if len(guard_entries) != 1 or len(guard) < 2 or Path(guard[1]).resolve() != Path(guard_entries[0]["path"]).resolve():
        raise ValueError("guard script differs from frozen manifest")
    guard_file = check_file(guard[1], guard_entries[0])
    xsim_file = Path(child[0]).resolve(strict=True)
    if not xsim_file.is_file():
        raise ValueError("xsim executable is absent")
    if Path(plusargs["LN_FIXTURE"]).resolve() != Path(plusargs["FIXTURE"]).resolve():
        raise ValueError("LN_FIXTURE and FIXTURE must identify one frozen source")
    roots = {key: Path(value).resolve(strict=True) for key, value in plusargs.items()}
    for key, path in roots.items():
        if not path.is_dir():
            raise ValueError(f"plusarg directory is absent: {key}")
    distinct_roots = {str(path) for key, path in roots.items() if key != "FIXTURE"}
    if len(distinct_roots) != len(REQUIRED_PLUSARGS) - 1:
        raise ValueError("unexpected plusarg directory alias")

    files = manifest["files"]
    roms = {Path(item["path"]).name: item for item in files
            if item["role"] == "LN_frozen" and
            Path(item["path"]).name.endswith("ROM_AUTO_1R.dat")}
    if len(roms) != 7:
        raise ValueError(f"expected seven frozen LN ROMs, found {len(roms)}")
    checked_roms = []
    for name, item in sorted(roms.items()):
        source = check_file(item["path"], item)
        target = check_file(cwd / name, item)
        checked_roms.append({"name": name, "source": source, "target": target})

    fixture_items = [item for item in files if item["role"] in FIXTURE_ROLES]
    checked_fixtures = [check_file(item["path"], item) for item in fixture_items]
    expected_paths = {Path(item["path"]).resolve() for item in fixture_items}
    for key, directory in roots.items():
        actual = {path.resolve() for path in directory.iterdir() if path.is_file()}
        expected = {path for path in expected_paths if directory in path.parents}
        if not expected or actual != expected:
            raise ValueError(f"fixture set differs for {key}: expected={len(expected)} actual={len(actual)}")
    return {
        "status": "ACCEPT", "cwd": str(cwd), "xsimdir": str(xsimdir),
        "manifest": {"path": str(manifest_path), "sha256": digest(manifest_path)},
        "launch": {"path": str(launch_path), "sha256": digest(launch_path)},
        "guard_file": guard_file,
        "xsim": {"path": str(xsim_file), "bytes": xsim_file.stat().st_size,
                 "sha256": digest(xsim_file)},
        "plusargs": {key: str(path) for key, path in roots.items()},
        "roms": checked_roms, "fixtures": checked_fixtures,
    }, command


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    temporary.replace(path)


def run(argv=None, spawn=subprocess.run):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--launch", type=Path, required=True)
    parser.add_argument("--cwd", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--execute", action="store_true")
    args = parser.parse_args(argv)
    snapshot = {"schema": "lnq2-runtime-preflight-v1",
                "checked_at": dt.datetime.now(dt.timezone.utc).isoformat(),
                "status": "REJECT", "spawned": False}
    try:
        evidence, command = verify(args.manifest, args.launch, args.cwd)
        snapshot.update(evidence)
        write_json(args.out, snapshot)
        if args.execute:
            snapshot["spawned"] = True
            write_json(args.out, snapshot)
            completed = spawn(command, check=False)
            snapshot["child_exit_code"] = completed.returncode
            write_json(args.out, snapshot)
            return completed.returncode
        return 0
    except (OSError, ValueError, KeyError, TypeError) as error:
        snapshot["reason"] = str(error)
        write_json(args.out, snapshot)
        print(f"LNQ2_RUNTIME_PREFLIGHT_REJECT: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(run())
