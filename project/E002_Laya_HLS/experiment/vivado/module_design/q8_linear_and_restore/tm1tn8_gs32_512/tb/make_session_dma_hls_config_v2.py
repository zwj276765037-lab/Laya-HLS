#!/usr/bin/env python3
"""Freeze Q8S2 hardware sources, then emit HLS config for a built package.

The source-only mode is usable before the generated package header exists.
That header and the generated cfg are run inputs, never their own build preimage.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

TOP = "q8_tm1tn8_session_dma_v2"
PART = "xcu55c-fsvh2892-2L-e"
FREQ_HZ = 150000000
CFLAGS = "-std=c++17 -O2 -fno-fast-math -ffp-contract=off"
MODULE = "vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512"
HARDWARE_FILES = (
    "include/laya_full_runtime.h", "include/laya_types.h",
    f"{MODULE}/source/q8_tm1tn8_abi.h",
    f"{MODULE}/source/q8_tm1tn8_session_abi_v2.h",
    f"{MODULE}/source/q8_tm1tn8_session_dma_v2.h",
    f"{MODULE}/source/q8_tm1tn8_session_dma_v2.cpp",
    f"{MODULE}/rtl/tm1tn8_hls_control_v2.sv",
    f"{MODULE}/rtl/tm1tn8_integer_tree.sv",
    f"{MODULE}/rtl/tm1tn8_fp_restore.sv",
    f"{MODULE}/rtl/tm1tn8_reserved_store.sv",
    f"{MODULE}/rtl/tm1tn8_arithmetic_pipeline.sv",
    f"{MODULE}/rtl/tm1tn8_ps_controller.sv",
    f"{MODULE}/rtl/tm1tn8_bias_output.sv",
    f"{MODULE}/rtl/tm1tn8_axi512_writer.sv",
    f"{MODULE}/rtl/tm1tn8_writer_bridge.sv",
    f"{MODULE}/rtl/tm1tn8_trace_axi32_writer.sv",
    f"{MODULE}/rtl/tm1tn8_joint_bridge.sv",
    f"{MODULE}/tb/make_session_dma_wrapper_v2.py",
    f"{MODULE}/tb/create_fp_ip.tcl",
    f"{MODULE}/tb/make_session_dma_hls_config_v2.py",
)


def file_record(root: Path, relative: str) -> dict:
    path = root / relative
    if not path.is_file():
        raise FileNotFoundError(path)
    raw = path.read_bytes()
    return {"relative_path": relative, "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--package", type=Path,
                        help="built candidate with laya_model_layout_generated.h")
    args = parser.parse_args()
    root, output = args.root.resolve(), args.output.resolve()
    if output.exists():
        raise FileExistsError("fresh output directory required")
    records = [file_record(root, relative) for relative in HARDWARE_FILES]
    output.mkdir(parents=True)
    preimage_inputs = {
        "schema": "q8_session_v2_hardware_source_inputs_v1",
        "top": TOP, "part": PART, "freqhz": FREQ_HZ,
        "cflags": CFLAGS, "flow_target": "vivado",
        "syn_compile_pipeline_loops": 0,
        "syn_array_partition_throughput_driven": "off",
        "syn_array_partition_complete_threshold": 0,
        "files": records,
    }
    (output / "hardware_source_inputs.json").write_text(
        json.dumps(preimage_inputs, indent=2, sort_keys=True) + "\n")
    if args.package is not None:
        package = args.package.resolve()
        header = package / "laya_model_layout_generated.h"
        if not header.is_file():
            raise FileNotFoundError(header)
        source = root / MODULE / "source" / f"{TOP}.cpp"
        cfg = (f"part={PART}\n"
               f"freqhz={FREQ_HZ}\n"
               "[hls]\nflow_target=vivado\n"
               f"syn.top={TOP}\n"
               "syn.compile.pipeline_loops=0\n"
               "syn.array_partition.throughput_driven=off\n"
               "syn.array_partition.complete_threshold=0\n"
               f"syn.file={source}\n"
               f"syn.cflags=-I{root/'include'} -I{package} "
               f"-I{root/MODULE/'source'} {CFLAGS}\n")
        (output / "tm1tn8_session_v2.cfg").write_text(cfg)
        runtime = {"schema": "q8_session_v2_hls_config_v1",
                   "hardware_source_inputs_sha256": hashlib.sha256(
                       (output / "hardware_source_inputs.json").read_bytes()).hexdigest(),
                   "package_header": {"path": str(header),
                       "sha256": hashlib.sha256(header.read_bytes()).hexdigest()},
                   "generated_cfg_sha256": hashlib.sha256(cfg.encode()).hexdigest()}
        (output / "manifest.json").write_text(
            json.dumps(runtime, indent=2, sort_keys=True) + "\n")
    print(f"TM1TN8_SESSION_V2_HLS_CONFIG_PASS source_files={len(records)} "
          f"package_bound={int(args.package is not None)}")


if __name__ == "__main__":
    main()
