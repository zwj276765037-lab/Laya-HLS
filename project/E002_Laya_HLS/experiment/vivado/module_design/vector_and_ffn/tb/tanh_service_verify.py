#!/usr/bin/env python3
"""Verify and list the exact generated tanh compile closure."""

import argparse
import hashlib
import json
from pathlib import Path


def verify(item):
    path = Path(item["path"])
    if path.stat().st_size != item["bytes"] or \
            hashlib.sha256(path.read_bytes()).hexdigest() != item["sha256"]:
        raise RuntimeError(f"frozen tanh input changed: {path}")
    return str(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--list", choices=("verilog", "vhdl", "rom"))
    args = parser.parse_args()
    data = json.loads(args.manifest.read_text())
    if data.get("schema") != "laya-tanh-service-source-closure-v1":
        raise RuntimeError("wrong tanh closure schema")
    paths = {"verilog": [], "vhdl": [], "rom": []}
    for item in data["verilog"]:
        paths["verilog"].append(verify(item))
    for item in data["rom"]:
        paths["rom"].append(verify(item))
    for entries in data["ip"].values():
        for item in entries:
            path = verify(item)
            if path.endswith(".vhd"):
                paths["vhdl"].append(path)
    verify(data["closure_script"])
    if args.list:
        print("\n".join(paths[args.list]))
    else:
        print("TANH_SOURCE_VERIFY_PASS verilog=%d rom=%d ip=%d" %
              (len(paths["verilog"]),len(paths["rom"]),len(paths["vhdl"])))


if __name__ == "__main__":
    main()
