#!/usr/bin/env python3
"""Bind the *actual generated* HLS AXI/AXIS ports to the two RTL writers.

Run after csynth. The script refuses missing streams, incorrect 512-bit read
ports, duplicate/unparsed declarations, or drift in generated port names.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

HLS_TOP = "q8_tm1tn8_engine"
INTERNAL_PREFIXES = ("writer_config_", "out0_tiles_", "out1_tiles_",
                     "finish_", "writer_completion_")
REQUIRED_STREAMS = {
    "writer_config": ("TDATA", "TVALID", "TREADY"),
    "out0_tiles": ("TDATA", "TVALID", "TREADY"),
    "out1_tiles": ("TDATA", "TVALID", "TREADY"),
    "finish": ("TDATA", "TVALID", "TREADY"),
    "writer_completion": ("TDATA", "TVALID", "TREADY"),
}


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def sha(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def parse_top(path: Path) -> tuple[list[str], list[str], dict[str, tuple[str, str]]]:
    content = path.read_text()
    m = re.search(r"\bmodule\s+" + HLS_TOP + r"\s*\((.*?)\);", content, re.S)
    require(m is not None, "generated HLS module declaration")
    ports = [x.strip() for x in m[1].split(",") if x.strip()]
    require(len(ports) == len(set(ports)), "duplicate generated port")
    params = re.findall(r"^parameter\s+(C_[A-Z0-9_]+)\s*=\s*([^;]+);",
                        content, re.M)
    param_lines = [f"localparam {key} = {value};" for key, value in params]
    declarations: dict[str, tuple[str, str]] = {}
    for direction, width, name in re.findall(
            r"^(input|output)\s+(\[[^\n;]+\])?\s*([A-Za-z_]\w*)\s*;",
            content, re.M):
        if name in ports:
            require(name not in declarations, "duplicate generated declaration")
            declarations[name] = (direction, width or "")
    require(set(declarations) == set(ports),
            "unparsed generated ports: " + str(sorted(set(ports) - set(declarations))[:8]))
    for prefix, suffixes in REQUIRED_STREAMS.items():
        for suffix in suffixes:
            require(prefix + "_" + suffix in declarations,
                    "missing generated stream " + prefix + "_" + suffix)
    for port in ("w_q0", "w_q1", "w_scale", "activation"):
        key = "C_M_AXI_GMEM_" + port.upper() + "_DATA_WIDTH"
        match = [value for name, value in params if name == key]
        require(match == ["512"], port + " is not actual 512-bit AXI")
    return ports, param_lines, declarations


def out_axi_ports(index: int) -> list[tuple[str, str, str]]:
    p = f"m_axi_out{index}_"
    return [("output", "[63:0]", p + "AWADDR"),
            ("output", "[0:0]", p + "AWID"),
            ("output", "[7:0]", p + "AWLEN"),
            ("output", "[2:0]", p + "AWSIZE"),
            ("output", "[1:0]", p + "AWBURST"),
            ("output", "[1:0]", p + "AWLOCK"),
            ("output", "[3:0]", p + "AWCACHE"),
            ("output", "[2:0]", p + "AWPROT"),
            ("output", "[3:0]", p + "AWQOS"),
            ("output", "[3:0]", p + "AWREGION"),
            ("output", "[0:0]", p + "AWUSER"),
            ("output", "", p + "AWVALID"),
            ("input", "", p + "AWREADY"),
            ("output", "[511:0]", p + "WDATA"),
            ("output", "[63:0]", p + "WSTRB"),
            ("output", "[0:0]", p + "WID"),
            ("output", "[0:0]", p + "WUSER"),
            ("output", "", p + "WLAST"),
            ("output", "", p + "WVALID"),
            ("input", "", p + "WREADY"),
            ("input", "[1:0]", p + "BRESP"),
            ("input", "[0:0]", p + "BID"),
            ("input", "", p + "BVALID"),
            ("output", "", p + "BREADY")]


def emit(path: Path, ports: list[str], params: list[str],
         decls: dict[str, tuple[str, str]]) -> None:
    internal = [p for p in ports if p.startswith(INTERNAL_PREFIXES)]
    external = [p for p in ports if p not in internal]
    extras = out_axi_ports(0) + out_axi_ports(1)
    lines = ["`timescale 1ns/1ps", "module q8_tm1tn8_gs32_512 (",
             "  " + ",\n  ".join(external + [x[2] for x in extras]) + "", ");"]
    lines.extend(params)
    for port in external:
        direction, width = decls[port]
        lines.append(f"{direction} wire {width} {port};")
    for direction, width, name in extras:
        lines.append(f"{direction} wire {width} {name};")
    for port in internal:
        _, width = decls[port]
        lines.append(f"wire {width} {port};")
    lines.append(f"{HLS_TOP} engine (\n" + ",\n".join(
        f"  .{port}({port})" for port in ports) + "\n);")
    mapping = {
        "clk": "ap_clk", "rst_n": "ap_rst_n",
        "cfg_tdata": "writer_config_TDATA", "cfg_tvalid": "writer_config_TVALID",
        "cfg_tready": "writer_config_TREADY",
        "tile0_tdata": "out0_tiles_TDATA", "tile0_tvalid": "out0_tiles_TVALID",
        "tile0_tready": "out0_tiles_TREADY",
        "tile1_tdata": "out1_tiles_TDATA", "tile1_tvalid": "out1_tiles_TVALID",
        "tile1_tready": "out1_tiles_TREADY",
        "finish_tvalid": "finish_TVALID", "finish_tready": "finish_TREADY",
        "completion_tdata": "writer_completion_TDATA",
        "completion_tvalid": "writer_completion_TVALID",
        "completion_tready": "writer_completion_TREADY",
    }
    for i in (0, 1):
        p = f"m_axi_out{i}_"
        for suffix in ("AWADDR", "AWLEN", "AWSIZE", "AWBURST", "AWVALID",
                       "AWREADY", "WDATA", "WSTRB", "WLAST", "WVALID",
                       "WREADY", "BRESP", "BVALID", "BREADY"):
            mapping[f"m{i}_{suffix.lower()}"] = p + suffix
        lines.extend((f"assign {p}AWID = 1'b0;",
                      f"assign {p}AWLOCK = 2'b00;",
                      f"assign {p}AWCACHE = 4'b0011;",
                      f"assign {p}AWPROT = 3'b000;",
                      f"assign {p}AWQOS = 4'b0000;",
                      f"assign {p}AWREGION = 4'b0000;",
                      f"assign {p}AWUSER = 1'b0;",
                      f"assign {p}WID = 1'b0;",
                      f"assign {p}WUSER = 1'b0;"))
    lines.append("tm1tn8_writer_bridge writers (\n" + ",\n".join(
        f"  .{key}({value})" for key, value in mapping.items()) + "\n);")
    # A retired B must match the only outstanding ID (zero); the testbench
    # independently checks all port debts at the first ap_done.
    lines.append("endmodule")
    path.write_text("\n".join(lines) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("hls_top", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    hls_top, output = args.hls_top.resolve(), args.output.resolve()
    require(not output.exists(), "wrapper output must be fresh")
    output.mkdir(parents=True)
    ports, params, decls = parse_top(hls_top)
    sv = output / "q8_tm1tn8_gs32_512.sv"
    emit(sv, ports, params, decls)
    xdc = output / "q8_tm1tn8_gs32_512.xdc"
    xdc.write_text("create_clock -name ap_clk -period 6.667 [get_ports ap_clk]\n"
                   "set_clock_uncertainty 0.035 [get_clocks ap_clk]\n")
    manifest = {"schema": "tm1tn8_generated_joint_wrapper_v1",
                "hls_top": sha(hls_top), "generator": sha(Path(__file__)),
                "wrapper": sha(sv), "xdc": sha(xdc),
                "mirrored_hls_ports": len(ports),
                "actual_read_data_widths": {p: 512 for p in
                    ("w_q0", "w_q1", "w_scale", "activation")},
                "actual_out_data_widths": {"out0": 512, "out1": 512}}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2,
                                                     sort_keys=True) + "\n")
    print("TM1TN8_JOINT_WRAPPER_PASS hls_ports=" + str(len(ports)))


if __name__ == "__main__":
    main()
