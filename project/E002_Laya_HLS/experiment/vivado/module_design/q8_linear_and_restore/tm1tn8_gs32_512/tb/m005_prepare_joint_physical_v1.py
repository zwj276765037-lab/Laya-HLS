#!/usr/bin/env python3
"""Prepare exact M005 synthesis source and IP lists from the validated top."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re

EXCLUDE = {
    "m005_ffn_top_tb_v1.sv",
    "laya_ffn0_source_stage_host_v1.sv",
    "ffn1_progress_observer_v1.sv",
    "glbl.v",
}
REQUIRED = {
    "laya_ffn_representative_top_v1.sv",
    "laya_quant_axi_debt_monitor_v1.sv",
    "geglu_gate_quant_bridge_v1.sv",
    "laya_layernorm_producer_portal_shell_v1.sv",
    "tm4tn8_matrix_resident_v2.sv",
    "laya_wi_axi_reader_v1.sv",
    "t4_dual_w_cache_v1.sv",
    "laya_ffn0_down_residual_admission_v1.sv",
    "laya_ffn0_residual_four_row_v1.sv",
}


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(block)
    return {"path": str(path), "bytes": path.stat().st_size,
            "sha256": h.hexdigest()}


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--simulation-attempt", type=Path, required=True)
    p.add_argument("--down-frozen", type=Path, required=True)
    p.add_argument("--ln-engine", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    args = p.parse_args()
    sim = args.simulation_attempt.resolve(strict=True)
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    prj = sim / "work/top_tb_vlog.prj"
    old_manifest = json.loads((sim / "input_manifest.json").read_text())
    identity = {item["path"]: item for item in old_manifest["files"]}
    sources = []
    for token in re.findall(r'"([^"]+)"', prj.read_text()):
        path = Path(token)
        if path.suffix not in (".v", ".sv") or path.name in EXCLUDE:
            continue
        path = path.resolve(strict=True)
        if str(path) not in identity or digest(path) != identity[str(path)]:
            raise ValueError(f"simulation RTL identity changed: {path}")
        if path not in sources:
            sources.append(path)
    if not REQUIRED <= {path.name for path in sources} or len(sources) < 100:
        raise ValueError("incomplete representative hardware closure")
    scripts = [args.down_frozen / "vivado/module_design/q8_linear_and_restore/"
               "tm1tn8_gs32_512/tb/create_fp_ip.tcl"]
    scripts += sorted((args.down_frozen / "ip").glob(
        "laya_quant16_functional_*_ip.tcl"))
    scripts += sorted(args.ln_engine.glob(
        "laya_layernorm_producer_engine_*_ip.tcl"))
    if len(scripts) != 8 or any(not path.is_file() for path in scripts):
        raise ValueError("expected 8 exact FP IP scripts")
    roms = sorted((sim / "work").glob("*ROM_AUTO_1R.dat"))
    if len(roms) != 7 or any(
            str(path) not in identity or digest(path) != identity[str(path)]
            for path in roms):
        raise ValueError("LN ROM closure changed")
    (out / "rtl_sources.txt").write_text(
        "\n".join(str(path) for path in sources) + "\n")
    (out / "ip_scripts.txt").write_text(
        "\n".join(str(path.resolve()) for path in scripts) + "\n")
    result = {
        "schema": "m005-joint-physical-preparation-v1",
        "at": datetime.now(timezone.utc).isoformat(),
        "simulation_attempt": str(sim),
        "simulation_manifest_sha256": digest(sim / "input_manifest.json")["sha256"],
        "rtl_count": len(sources), "ip_script_count": len(scripts),
        "rom_count": len(roms),
        "files": [digest(path) for path in [*sources, *scripts, *roms]],
    }
    (out / "input_manifest.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"M005_PHYSICAL_PREPARED rtl={len(sources)} ip=8 rom=7")


if __name__ == "__main__":
    main()
