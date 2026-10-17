#!/usr/bin/env python3
"""Prepare a frozen functional HLS/CSim configuration; do not run tools."""

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[4]
MODULE = ROOT / "vivado/module_design/activation_quantizer"
FIXTURE = MODULE / "rtl/quant16_fixture_01"
OUT = MODULE / "rtl/quant16_hls_preflight_01"
SOURCES = [MODULE / "source/quant16_hls_top.cpp",
           MODULE / "source/quant16.cpp", ROOT / "hls/common/laya_numeric.cpp"]
HEADERS = [MODULE / "source/quant16_hls_top.h",
           MODULE / "source/quant16.h", *sorted((ROOT / "include").glob("*.h"))]
TB = MODULE / "tb/quant16_hls_tb.cpp"


def record(path):
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = json.loads((FIXTURE / "manifest.json").read_text())
    fixture_files = [FIXTURE / "manifest.json"]
    for case in manifest["cases"].values():
        fixture_files.extend(Path(item["path"]) for item in case["products"].values())
    for case in manifest["cases"].values():
        for item in case["products"].values():
            if record(Path(item["path"]))["sha256"] != item["sha256"]:
                raise RuntimeError(f"fixture changed: {item['path']}")
    flags = f"-I{ROOT}/include -I{MODULE}/source -std=c++17 -fno-fast-math -ffp-contract=off"
    args = " ".join(str(p) for p in (
        FIXTURE / "wi_source_f32.bin", FIXTURE / "wi_q.bin",
        FIXTURE / "wi_scale.bin", FIXTURE / "wi_scalar_u32x3.bin",
        FIXTURE / "down_source_f32.bin", FIXTURE / "down_q.bin",
        FIXTURE / "down_scale.bin", FIXTURE / "down_scalar_u32x3.bin"))
    cfg = OUT / "quant16.cfg"
    cfg.write_text("\n".join([
        "part=xcu55c-fsvh2892-2L-e", "freqhz=150000000", "[hls]",
        "flow_target=vivado", "syn.top=laya_quant16_functional",
        "syn.compile.pipeline_loops=0",
        "syn.array_partition.throughput_driven=off",
        "syn.array_partition.complete_threshold=0",
        *(f"syn.file={path}" for path in SOURCES),
        f"syn.cflags={flags}", "csim.stdmath=true",
        f"tb.file={TB}", f"tb.cflags={flags}", f"csim.argv={args}", "",
    ]))
    paths = [*SOURCES, *HEADERS, TB, *fixture_files,
             MODULE / "tb/quant16_hls_config.py", cfg]
    (OUT / "source_manifest.json").write_text(json.dumps({
        "scope": "functional HLS/CSim input only; no HLS or RTL result",
        "top": "laya_quant16_functional",
        "part": "xcu55c-fsvh2892-2L-e", "frequency_hz": 150000000,
        "inputs": [record(p) for p in paths],
    }, indent=2, sort_keys=True) + "\n")
    print(cfg)


if __name__ == "__main__":
    main()
