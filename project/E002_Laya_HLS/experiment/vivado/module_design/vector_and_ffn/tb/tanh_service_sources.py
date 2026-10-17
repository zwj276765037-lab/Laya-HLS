#!/usr/bin/env python3
"""Bind the original generated tanh leaf to its RTL, ROM and FP IP inputs."""

import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[4]
BUILD = ROOT / "vivado/project/build/20261008T022231Z-2961016"
RTL = BUILD / "stage/rtl_verilog"
IP_GEN = BUILD / "vivado/laya_ooc.gen/sources_1/ip"
IP_XCI = BUILD / "vivado/laya_ooc.srcs/sources_1/ip"
LEAF = "laya_typed_q8_forward_generic_tanh_float_s"
OUT = ROOT / "vivado/module_design/vector_and_ffn/rtl/tanh_service_01"


def record(path):
    path = Path(path)
    return {"path": str(path.resolve()), "bytes": path.stat().st_size,
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    definitions = {}
    for path in RTL.glob("*.v"):
        for name in re.findall(r"(?m)^[ \t]*(?:\(\*.*?\*\)[ \t]*)?module[ \t]+([A-Za-z_]\w*)", path.read_text()):
            if name in definitions:
                raise RuntimeError(f"duplicate RTL module {name}")
            definitions[name] = path
    selected = set()
    pending = [LEAF]
    external = set()
    while pending:
        name = pending.pop()
        if name in selected:
            continue
        path = definitions.get(name)
        if path is None:
            external.add(name)
            continue
        selected.add(name)
        for line in path.read_text().splitlines():
            # HLS prefixes some module instances with inline Verilog attributes.
            # Remove only that prefix before resolving the generated module name.
            statement = re.sub(r"^\s*(?:\(\*.*?\*\)\s*)+", "", line)
            words = statement.strip().split(None, 1)
            if not words:
                continue
            token = words[0]
            if token in definitions and token != name:
                pending.append(token)
            elif token.startswith("laya_typed_q8_forward_") and token != name and \
                    len(words) > 1 and not token.endswith((";", ",")):
                pending.append(token)
    files = {definitions[name] for name in selected}
    roms = set()
    for path in files:
        for raw in re.findall(r'\$readmemh\("([^\"]+)"', path.read_text()):
            rom = RTL / Path(raw).name
            if not rom.is_file():
                raise RuntimeError(f"missing ROM {rom}")
            roms.add(rom)
    ips = {}
    for name in external:
        if not name.endswith("_ip"):
            raise RuntimeError(f"unresolved module {name}")
        sim = IP_GEN / name / "sim" / f"{name}.vhd"
        xci = IP_XCI / name / f"{name}.xci"
        tcl = RTL / f"{name}.tcl"
        if not all(p.is_file() for p in (sim, xci, tcl)):
            raise RuntimeError(f"missing generated IP source for {name}")
        ips[name] = [record(p) for p in (sim, xci, tcl)]
    leaf_text = definitions[LEAF].read_text()
    if not all(s in leaf_text for s in (
        "ap_ST_fsm_state43 : begin\n            ap_NS_fsm = ap_ST_fsm_state1;",
        "ap_NS_fsm = ap_ST_fsm_state2;",
        "ap_NS_fsm = ap_ST_fsm_state53;",
        "ap_NS_fsm = ap_ST_fsm_state59;",
        "if ((1'b1 == ap_CS_fsm_state43)) begin\n        ap_ready = 1'b1;",
        "((1'b1 == ap_CS_fsm_state1) & (ap_start == 1'b0))")):
        raise RuntimeError("tanh control structure changed")
    OUT.mkdir(parents=True, exist_ok=True)
    manifest = {
        "schema": "laya-tanh-service-source-closure-v1",
        "scope": "historical generated original tanh leaf; no v4 kernel identity or simulation result",
        "leaf": LEAF,
        "tool": "Vitis HLS 2025.2; Vivado floating_point_v7_1_21/unisims external sim libraries",
        "verilog": [record(p) for p in sorted(files)],
        "rom": [record(p) for p in sorted(roms)],
        "ip": {name: ips[name] for name in sorted(ips)},
        "closure_script": record(Path(__file__)),
        "structural_observation": {
            "ap_start_consumed_in_state1_only": True,
            "ap_ready_and_active_ap_done_in_state43": True,
            "idle_ap_done_also_high": True,
            "state43_always_returns_to_state1": True,
            "minimum_state1_accept_gap_cycles": 3,
            "scope": "This selected leaf's FSM only; does not establish numeric correctness or an upper service bound",
        },
    }
    (OUT / "source_manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    print(f"TANH_SOURCE_CLOSURE_PASS verilog={len(files)} rom={len(roms)} ip={len(ips)}")


if __name__ == "__main__":
    main()
