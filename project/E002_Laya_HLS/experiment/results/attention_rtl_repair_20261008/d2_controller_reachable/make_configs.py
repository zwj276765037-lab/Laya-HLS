#!/usr/bin/env python3
"""Derive the two isolated D2-I HLS source lists from official full_sources.cmake."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re


MODULE = Path(__file__).resolve().parent
ROOT = MODULE.parents[2]
PACKAGE = ROOT / "build/model-attention-rtl-repair-20261008"
CONTROLLER = "hls/control/full_forward_controller.cpp"
FLAGS = (f"-I{ROOT / 'include'} -I{ROOT / 'hls'} "
         f"-I{ROOT / 'hls/platform'} -I{PACKAGE} "
         "-std=c++17 -O2 -fno-fast-math -ffp-contract=off")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    official = ROOT / "config/full_sources.cmake"
    sources = re.findall(r"^\s+(hls/\S+\.cpp)$", official.read_text(),
                         flags=re.MULTILINE)
    assert len(sources) == 25 and sources.count(CONTROLLER) == 1
    assert sha(ROOT / CONTROLLER) == (
        "23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623")
    production = [ROOT / source for source in sources if source != CONTROLLER]
    assert len(production) == 24 and all(path.is_file() for path in production)
    report = {"official_sources": str(official), "official_sources_sha256": sha(official),
              "included_controller": {"path": str(ROOT / CONTROLLER),
                                      "sha256": sha(ROOT / CONTROLLER)},
              "linked_production_sources": [
                  {"path": str(path), "sha256": sha(path)} for path in production],
              "isolated_tops": {}}
    for short, top in (("linear", "linear_controller_slice"),
                       ("vector", "vector_controller_slice")):
        wrapper = MODULE / "source" / f"{top}.cpp"
        tb = MODULE / "tb" / f"test_{top}.cpp"
        assert wrapper.is_file() and tb.is_file()
        lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
                 "flow_target=vivado", f"syn.top={top}",
                 "syn.compile.pipeline_loops=0",
                 "syn.array_partition.throughput_driven=off",
                 "syn.array_partition.complete_threshold=0",
                 f"syn.file={wrapper}"]
        lines += [f"syn.file={path}" for path in production]
        lines += [f"syn.cflags={FLAGS}", "csim.stdmath=true",
                  f"tb.file={tb}", f"tb.cflags={FLAGS}"]
        config = MODULE / f"config_{short}.cfg"
        config.write_text("\n".join(lines) + "\n")
        report["isolated_tops"][short] = {
            "top": top, "wrapper": {"path": str(wrapper), "sha256": sha(wrapper)},
            "tb": {"path": str(tb), "sha256": sha(tb)},
            "config": {"path": str(config), "sha256": sha(config)},
            "production_link_count": 24,
            "directly_included_controller_count": 1,
        }
    (MODULE / "source_list_manifest.json").write_text(
        json.dumps(report, indent=2) + "\n")
    print("D2_I_CONFIGS_GENERATED sources=24 wrappers=2")


if __name__ == "__main__":
    main()
