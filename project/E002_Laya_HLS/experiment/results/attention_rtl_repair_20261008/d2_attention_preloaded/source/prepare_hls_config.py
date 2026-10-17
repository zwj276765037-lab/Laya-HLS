#!/usr/bin/env python3
"""Prepare the reviewed CPU identity for a separately gated Vitis HLS run."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import subprocess


MODULE = Path(__file__).resolve().parents[1]
ROOT = MODULE.parents[2]
PACKAGE = ROOT / "build/model-attention-rtl-repair-20261008"
OLD = ROOT / "results/attention_rtl_repair_20261008/d2_attention_slice/tb/fixture_b1_s64_decision"
NEW = MODULE / "tb/fixture_preloaded"
PACKET = MODULE / "source/final_cpu_binding_packet.json"
PACKET_SHA256 = "be014f2d42f094fa7dad685047ace8a8f37e878caa62bb20c4da498aab42a952"
VITIS_RUN = Path("/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin/vitis-run")


def sha256(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1 << 20), b""):
            value.update(block)
    return value.hexdigest()


def main() -> None:
    if sha256(PACKET) != PACKET_SHA256:
        raise RuntimeError("review candidate CPU packet changed")
    packet = json.loads(PACKET.read_text())
    for name, record in packet["cpu_inputs"].items():
        path = Path(name)
        if sha256(path) != record["sha256"] or path.stat().st_size != record["bytes"]:
            raise RuntimeError(f"review candidate CPU input changed: {name}")
    source_list = ROOT / "config/full_sources.cmake"
    names = re.findall(r"^  (hls/\S+\.cpp)$", source_list.read_text(), re.MULTILINE)
    if len(names) != 25 or len(set(names)) != 25 or (
        names.count("hls/control/full_forward_controller.cpp") != 1):
        raise RuntimeError("official source closure changed")
    linked = [ROOT / name for name in names
              if name != "hls/control/full_forward_controller.cpp"]
    wrapper = MODULE / "source/attention_preloaded_slice.cpp"
    tb = MODULE / "tb/test_attention_preloaded.cpp"
    include = [ROOT / "include", ROOT / "hls", ROOT / "hls/platform",
               PACKAGE, MODULE / "source"]
    cflags = " ".join([*("-I" + str(path) for path in include),
                       "-std=c++17", "-O2", "-fno-fast-math",
                       "-ffp-contract=off"])
    tb_cflags = cflags + " -I" + str(MODULE / "tb")
    lines = ["part=xcu55c-fsvh2892-2L-e", "freqhz=150000000",
             "[hls]", "flow_target=vivado", "syn.top=attention_preloaded_slice",
             "syn.compile.pipeline_loops=0",
             "syn.array_partition.throughput_driven=off",
             "syn.array_partition.complete_threshold=0"]
    lines.extend("syn.file=" + str(path) for path in [wrapper, *linked])
    lines.extend(["syn.cflags=" + cflags, "csim.stdmath=true",
                  "sim.ldflags=-lm", "tb.file=" + str(tb),
                  "tb.cflags=" + tb_cflags,
                  "csim.argv=" + " ".join(map(str, (PACKAGE, OLD, NEW)))])
    config = MODULE / "config.cfg"
    config.write_text("\n".join(lines) + "\n")
    version = subprocess.run([str(VITIS_RUN), "--version"], cwd=ROOT,
                             check=True, text=True, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT).stdout.splitlines()
    result = {
        "schema": "d2_attention_preloaded_hls_config_preparation_v1",
        "released_for_execution": False,
        "cpu_packet": {"path": str(PACKET), "sha256": PACKET_SHA256},
        "config": {"path": str(config), "sha256": sha256(config)},
        "official_source_list": {"path": str(source_list), "sha256": sha256(source_list)},
        "included_controller": str(ROOT / "hls/control/full_forward_controller.cpp"),
        "syn_file_count": len(linked) + 1,
        "linked_production_tu_count": len(linked),
        "target_part": "xcu55c-fsvh2892-2L-e",
        "requested_freqhz": 150000000,
        "math": "csim.stdmath=true, sim.ldflags=-lm",
        "csim_arguments": [str(PACKAGE), str(OLD), str(NEW)],
        "vitis_run": str(VITIS_RUN),
        "vitis_version_lines": version[:7],
        "planned_csim_guard": {
            "max_owned_rss_gib": 16, "max_wall_seconds": 600,
            "cpu_count": 4, "nice": 19, "ionice_class": 3,
            "minimum_mem_available_gib": 192, "sample_seconds": 0.2},
    }
    (MODULE / "source/hls_config_preparation.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print("D2_PRELOADED_HLS_CONFIG_PREPARED", result["config"]["sha256"],
          len(linked))


if __name__ == "__main__":
    main()
