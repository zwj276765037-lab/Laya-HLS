#!/usr/bin/env python3
"""Write the source-complete five-port HLS configuration and input closure."""

import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path("/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline")


def sha(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    package = args.package.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    source_lines = (ROOT / "config/full_sources.cmake").read_text().splitlines()
    sources = [ROOT / match.group(1) for line in source_lines
               if (match := re.fullmatch(r"\s*(hls/\S+\.cpp)\s*", line))]
    sources.append(ROOT / "hls/platform/full_frontend_wrapper.cpp")
    if len(sources) < 26 or not all(path.is_file() for path in sources):
        raise ValueError("incomplete production source closure")
    headers = sorted((ROOT / "include").glob("*.h"))
    header = package / "laya_model_layout_generated.h"
    if not header.is_file():
        raise ValueError("model header missing")
    lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
             "flow_target=vivado", "syn.top=laya_cpu_embedding_ln_chain",
             "syn.compile.pipeline_loops=0",
             "syn.array_partition.throughput_driven=off",
             "syn.array_partition.complete_threshold=0"]
    lines += [f"syn.file={source}" for source in sources]
    lines += [f"syn.cflags=-I{ROOT}/include -I{ROOT}/hls -I{ROOT}/hls/platform "
              f"-I{package} -std=c++17 -fno-fast-math -ffp-contract=off",
              f"tb.file={ROOT}/results/cpu_embedding_q8_validation_20261010/tools/cpu_front_csim_tb.cpp",
              f"tb.cflags=-I{ROOT}/include -I{ROOT}/hls -I{package} "
              "-std=c++17 -O2 -fno-fast-math -ffp-contract=off"]
    config = out / "cpu_front.cfg"
    config.write_text("\n".join(lines) + "\n")
    inputs = [ROOT / "config/full_sources.cmake", config, header,
              package / "manifest.json", ROOT / "host/cpu_embedding_raw.cpp",
              ROOT / "results/cpu_embedding_q8_validation_20261010/tools/cpu_front_csim_tb.cpp",
              *sources, *headers]
    (out / "source_input_manifest.json").write_text(json.dumps({
        "top": "laya_cpu_embedding_ln_chain", "model_package": str(package),
        "source_count": len(sources), "inputs": [
            {"path": str(path), "sha256": sha(path)} for path in inputs]},
        indent=2) + "\n")
    print("CPU_FRONT_HLS_CONFIG_PASS", len(sources), config)


if __name__ == "__main__":
    main()
