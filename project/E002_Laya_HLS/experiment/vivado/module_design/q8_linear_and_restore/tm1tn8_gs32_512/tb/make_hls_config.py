#!/usr/bin/env python3
"""Emit a same-source HLS config and its static source/package identity."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> dict:
    h = hashlib.sha256()
    with path.open("rb") as f:
        while block := f.read(8 << 20):
            h.update(block)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": h.hexdigest()}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", type=Path)
    ap.add_argument("model_package", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--joint", action="store_true",
                    help="synthesize the HLS LOAD/quant/group-issue front")
    args = ap.parse_args()
    root, package, output = (args.root.resolve(), args.model_package.resolve(),
                             args.output.resolve())
    module = root / "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"
    stem = "q8_tm1tn8_joint_dma" if args.joint else "q8_tm1tn8_engine"
    source = module / f"source/{stem}.cpp"
    header = package / "laya_model_layout_generated.h"
    if output.exists() or not source.is_file() or not header.is_file():
        raise ValueError("fresh output and existing source/package required")
    output.mkdir(parents=True)
    cfg = ("part=xcu55c-fsvh2892-2L-e\n"
           "freqhz=150000000\n"
           "[hls]\n"
           "flow_target=vivado\n"
           f"syn.top={stem}\n"
           "syn.compile.pipeline_loops=0\n"
           "syn.array_partition.throughput_driven=off\n"
           "syn.array_partition.complete_threshold=0\n"
           f"syn.file={source}\n"
           f"syn.cflags=-I{root / 'include'} -I{package} -I{module / 'source'} "
           "-std=c++17 -O2 -fno-fast-math -ffp-contract=off\n")
    cfg_path = output / "tm1tn8.cfg"
    cfg_path.write_text(cfg)
    inputs = [source, module / f"source/{stem}.h",
              module / "source/q8_tm1tn8_abi.h", header,
              root / "include/laya_full_runtime.h",
              root / "include/laya_types.h", Path(__file__)]
    manifest = {"schema": "tm1tn8_hls_source_config_v1",
                "inputs": [sha(p) for p in inputs], "config": sha(cfg_path),
                "top": stem,
                "part": "xcu55c-fsvh2892-2L-e", "freqhz": 150000000,
                "fp_flags": ["-fno-fast-math", "-ffp-contract=off"]}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2,
                                                     sort_keys=True) + "\n")
    print("TM1TN8_HLS_CONFIG_PASS")


if __name__ == "__main__":
    main()
