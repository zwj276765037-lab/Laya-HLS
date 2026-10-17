#!/usr/bin/env python3
"""Bind generated joint HLS, physical writers, and one observed controller.

This generator intentionally needs the actual HLS top and argument-register
module. Missing 64-bit pointer halves, stream ports or 512-bit read buses are
fatal rather than guessed from a pragma.
"""
from __future__ import annotations

import argparse
import ast
import hashlib
import json
from pathlib import Path
import re

TOP = "q8_tm1tn8_joint_dma"
STREAMS = {
    "writer_config": 256, "compute_config": 256, "bias_tiles": 288,
    "group_issues": 2816, "finish_r": 8, "writer_completion": 512,
}
POINTERS = ("descriptor", "w_q0", "w_q1", "w_scale", "aux",
            "activation", "observed")
AXIL = ("AWADDR", "AWVALID", "AWREADY", "WDATA", "WSTRB", "WVALID",
        "WREADY", "BRESP", "BVALID", "BREADY", "ARADDR", "ARVALID",
        "ARREADY", "RDATA", "RRESP", "RVALID", "RREADY")
AXI = ("AWADDR", "AWLEN", "AWSIZE", "AWBURST", "AWVALID", "AWREADY",
       "WDATA", "WSTRB", "WLAST", "WVALID", "WREADY", "BRESP",
       "BVALID", "BREADY")


def require(value: bool, why: str) -> None:
    if not value:
        raise AssertionError(why)


def digest(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def resolve_width(width: str, params: dict[str, str]) -> str:
    """Freeze a generated HLS port width in the wrapper's own scope."""
    if not width:
        return ""
    require(width.startswith("[") and width.endswith("]") and ":" in width,
            f"unrecognized HLS port width {width!r}")
    resolved: dict[str, int] = {}
    visiting: set[str] = set()

    def evaluate(expression: str) -> int:
        def node_value(node: ast.AST) -> int:
            if isinstance(node, ast.Constant) and type(node.value) is int:
                return node.value
            if isinstance(node, ast.Name):
                name = node.id
                require(name in params, f"unknown HLS width parameter {name}")
                if name not in resolved:
                    require(name not in visiting, f"cyclic HLS width parameter {name}")
                    visiting.add(name)
                    resolved[name] = evaluate(params[name])
                    visiting.remove(name)
                return resolved[name]
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
                return -node_value(node.operand)
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.UAdd):
                return node_value(node.operand)
            if isinstance(node, ast.BinOp):
                left, right = node_value(node.left), node_value(node.right)
                if isinstance(node.op, ast.Add):
                    return left + right
                if isinstance(node.op, ast.Sub):
                    return left - right
                if isinstance(node.op, (ast.Div, ast.FloorDiv)):
                    require(right != 0 and left % right == 0,
                            f"nonintegral HLS width expression {expression!r}")
                    return left // right
                if isinstance(node.op, ast.Mult):
                    return left * right
            raise AssertionError(f"unsupported HLS width expression {expression!r}")

        return node_value(ast.parse(expression.strip(), mode="eval").body)

    high, low = width[1:-1].split(":", 1)
    hi, lo = evaluate(high), evaluate(low)
    require(hi >= lo >= 0, f"invalid HLS port width {width!r}")
    return f"[{hi}:{lo}]"


def parse_top(path: Path) -> tuple[list[str], dict[str, tuple[str, str]], dict[str, str]]:
    content = path.read_text()
    match = re.search(r"\bmodule\s+" + TOP + r"\s*\((.*?)\);", content, re.S)
    require(match is not None, "generated joint HLS top declaration")
    ports = [x.strip() for x in match[1].split(",") if x.strip()]
    require(len(ports) == len(set(ports)), "duplicate HLS top port")
    decls = {name: (direction, width or "") for direction, width, name in
             re.findall(r"^(input|output)\s+(\[[^\n;]+\])?\s*([A-Za-z_]\w*)\s*;",
                        content, re.M) if name in ports}
    require(set(ports) == set(decls), "unparsed HLS top port declarations")
    params = dict(re.findall(r"^parameter\s+(C_[A-Z0-9_]+)\s*=\s*([^;]+);",
                             content, re.M))
    decls = {name: (direction, resolve_width(width, params))
             for name, (direction, width) in decls.items()}
    for name in POINTERS:
        for signal in ("ARVALID", "ARREADY", "RLAST", "RVALID", "RREADY",
                       "AWADDR", "AWVALID", "AWREADY", "WVALID", "WREADY",
                       "BVALID", "BREADY"):
            require(f"m_axi_gmem_{name}_{signal}" in decls,
                    f"missing physical {name} AXI {signal}")
    for name in ("w_q0", "w_q1", "w_scale", "activation"):
        require(params.get(f"C_M_AXI_GMEM_{name.upper()}_DATA_WIDTH") == "512",
                f"{name} generated AXI data width is not 512")
        require(decls.get(f"m_axi_gmem_{name}_RDATA", (None, None)) ==
                ("input", "[511:0]"),
                f"{name} physical read bus is not 512 bits")
    require(decls.get("m_axi_gmem_observed_WDATA", (None, None)) ==
            ("output", "[31:0]"),
            "HLS observed write bus is not 32 bits")
    for name, width in STREAMS.items():
        for suffix in ("TDATA", "TVALID", "TREADY"):
            require(f"{name}_{suffix}" in decls, f"missing {name}_{suffix}")
        require(decls[f"{name}_TDATA"][1] == f"[{width-1}:0]",
                f"{name} stream width drift")
    for bundle in ("s_axi_control", "s_axi_control_r"):
        for suffix in AXIL:
            require(f"{bundle}_{suffix}" in decls,
                    f"missing generated {bundle}_{suffix}")
    require(params.get("C_S_AXI_CONTROL_ADDR_WIDTH") == "4",
            "unexpected HLS control AXI-Lite width")
    return ports, decls, params


def parse_arg_registers(path: Path, width: int) -> dict[str, tuple[int, int]]:
    content = path.read_text()
    values = {name: int(value, 16) for name, value in re.findall(
        r"\b(ADDR_[A-Z0-9_]+)\s*=\s*\d+'h([0-9a-fA-F]+)", content)}
    offsets = {}
    for pointer in POINTERS:
        name = pointer.upper()
        keys = [(f"ADDR_{name}_R_DATA_0", f"ADDR_{name}_R_DATA_1"),
                (f"ADDR_{name}_DATA_0", f"ADDR_{name}_DATA_1")]
        found = [pair for pair in keys if all(x in values for x in pair)]
        require(len(found) == 1, f"missing/ambiguous 64-bit {pointer} offsets")
        lo, hi = (values[x] for x in found[0])
        require(hi == lo+4 and hi < (1 << width),
                f"nonadjacent/out-of-range {pointer} high word")
        offsets[pointer] = (lo, hi)
    return offsets


def sideband(prefix: str) -> list[str]:
    return [f"assign {prefix}AWID = 1'b0;",
            f"assign {prefix}AWLOCK = 2'b00;",
            f"assign {prefix}AWCACHE = 4'b0011;",
            f"assign {prefix}AWPROT = 3'b000;",
            f"assign {prefix}AWQOS = 4'b0000;",
            f"assign {prefix}AWREGION = 4'b0000;",
            f"assign {prefix}AWUSER = 1'b0;",
            f"assign {prefix}WID = 1'b0;",
            f"assign {prefix}WUSER = 1'b0;"]


def extra_axi(prefix: str, data_width: int) -> list[tuple[str, str, str]]:
    addr = {"AWADDR": "[63:0]", "AWLEN": "[7:0]", "AWSIZE": "[2:0]",
            "AWBURST": "[1:0]", "WDATA": f"[{data_width-1}:0]",
            "WSTRB": f"[{data_width//8-1}:0]", "BRESP": "[1:0]"}
    outputs = {"AWADDR", "AWLEN", "AWSIZE", "AWBURST", "AWVALID",
               "WDATA", "WSTRB", "WLAST", "WVALID", "BREADY"}
    result = [("output" if s in outputs else "input", addr.get(s, ""), prefix+s)
              for s in AXI]
    result += [("output", "[0:0]", prefix+s) for s in ("AWID", "AWUSER", "WID", "WUSER")]
    result += [("output", "[1:0]", prefix+"AWLOCK"),
               ("output", "[3:0]", prefix+"AWCACHE"),
               ("output", "[2:0]", prefix+"AWPROT"),
               ("output", "[3:0]", prefix+"AWQOS"),
               ("output", "[3:0]", prefix+"AWREGION")]
    return result


def emit(path: Path, ports: list[str], decls: dict[str, tuple[str, str]],
         params: dict[str, str], offsets: dict[str, tuple[int, int]]) -> None:
    hidden = tuple(f"{s}_" for s in STREAMS) + ("s_axi_control_", "s_axi_control_r_")
    internal = [p for p in ports if p.startswith(hidden) or p == "interrupt"]
    external = [p for p in ports if p not in internal]
    extras = [*extra_axi("m_axi_out0_", 512),
              *extra_axi("m_axi_out1_", 512),
              *extra_axi("m_axi_observed_trace_", 32)]
    scalar = [("input", "", "command_start"),
              ("output", "", "command_ready"),
              ("output", "", "command_done"),
              ("output", "", "command_fault"),
              *(("input", "[63:0]", name+"_base") for name in POINTERS),
              ("input", "[63:0]", "observed_span")]
    names = external+[x[2] for x in extras+scalar]
    require(len(names)==len(set(names)), "wrapper duplicate external name")
    lines = ["`timescale 1ns/1ps", "module q8_tm1tn8_gs32_512 (",
             "  " + ",\n  ".join(names), ");"]
    for p in external:
        d, w = decls[p]
        lines.append(f"{d} wire {w} {p};")
    for d, w, p in extras+scalar:
        lines.append(f"{d} wire {w} {p};")
    for p in internal:
        _, w = decls[p]
        lines.append(f"wire {w} {p};")
    lines += ["wire [63:0] active_observed_base, active_observed_span;",
              "wire trace_command_start, bridge_debt_zero, bridge_fault;",
              "wire control_fault, hls_axi_debt_zero;",
              "assign command_fault = control_fault || bridge_fault;"]
    for pointer in POINTERS:
        prefix = f"m_axi_gmem_{pointer}_"
        lines += [f"reg [15:0] {pointer}_read_pending, {pointer}_write_pending;",
                  f"wire {pointer}_debt_zero = {pointer}_read_pending == 0 &&",
                  f"  {pointer}_write_pending == 0 && !{prefix}ARVALID &&",
                  f"  !{prefix}RVALID && !{prefix}AWVALID &&",
                  f"  !{prefix}WVALID && !{prefix}BVALID;",
                  "always @(posedge ap_clk) begin",
                  f"  if (!ap_rst_n) begin {pointer}_read_pending <= 0;",
                  f"    {pointer}_write_pending <= 0; end",
                  f"  else begin {pointer}_read_pending <= {pointer}_read_pending +",
                  f"    16'({prefix}ARVALID && {prefix}ARREADY) -",
                  f"    16'({prefix}RVALID && {prefix}RREADY && {prefix}RLAST);",
                  f"    {pointer}_write_pending <= {pointer}_write_pending +",
                  f"    16'({prefix}AWVALID && {prefix}AWREADY) -",
                  f"    16'({prefix}BVALID && {prefix}BREADY); end",
                  "end"]
    lines.append("assign hls_axi_debt_zero = " +
                 " &&\n  ".join(f"{pointer}_debt_zero" for pointer in POINTERS) + ";")
    lines.append(f"{TOP} engine (\n"+",\n".join(
        f"  .{p}({p})" for p in ports)+"\n);")
    arg_width = int(params["C_S_AXI_CONTROL_R_ADDR_WIDTH"])
    ctrl_map = {
        "clk": "ap_clk", "rst_n": "ap_rst_n",
        "command_start": "command_start",
        "command_ready": "command_ready",
        "command_done": "command_done",
        "command_fault": "control_fault",
        "observed_span": "observed_span",
        "all_writer_debt_zero": "bridge_debt_zero",
        "hls_axi_debt_zero": "hls_axi_debt_zero",
    }
    for pointer in POINTERS:
        ctrl_map[pointer+"_base"] = pointer+"_base"
    ctrl_map["active_observed_base"]="active_observed_base"
    ctrl_map["active_observed_span"]="active_observed_span"
    ctrl_map["trace_command_start"]="trace_command_start"
    for bundle, signal in (("s_axi_control_r", "arg"),
                           ("s_axi_control", "ctrl")):
        for suffix in AXIL:
            ctrl_map[signal+"_"+suffix.lower()] = bundle+"_"+suffix
    params_text = [f".ARG_ADDR_W({arg_width})"]
    for pointer, (lo, hi) in offsets.items():
        name=pointer.upper()
        params_text.extend((f".ADDR_{name}_LO({arg_width}'h{lo:x})",
                            f".ADDR_{name}_HI({arg_width}'h{hi:x})"))
    lines.append("tm1tn8_hls_control #(\n  "+",\n  ".join(params_text)+
                 "\n) controller (\n"+",\n".join(
                     f"  .{key}({value})" for key,value in ctrl_map.items())+"\n);")
    bridge = {"clk":"ap_clk", "rst_n":"ap_rst_n",
              "cfg_tdata":"writer_config_TDATA", "cfg_tvalid":"writer_config_TVALID",
              "cfg_tready":"writer_config_TREADY",
              "compute_cfg_tdata":"compute_config_TDATA",
              "compute_cfg_tvalid":"compute_config_TVALID",
              "compute_cfg_tready":"compute_config_TREADY",
              "bias_tdata":"bias_tiles_TDATA", "bias_tvalid":"bias_tiles_TVALID",
              "bias_tready":"bias_tiles_TREADY",
              "group_tdata":"group_issues_TDATA", "group_tvalid":"group_issues_TVALID",
              "group_tready":"group_issues_TREADY",
              "finish_tvalid":"finish_r_TVALID", "finish_tready":"finish_r_TREADY",
              "completion_tdata":"writer_completion_TDATA",
              "completion_tvalid":"writer_completion_TVALID",
              "completion_tready":"writer_completion_TREADY",
              "observed_base":"active_observed_base",
              "observed_span":"active_observed_span",
              "trace_command_start":"trace_command_start",
              "all_writer_debt_zero":"bridge_debt_zero",
              "any_writer_fault":"bridge_fault"}
    for index in (0,1):
        for suffix in AXI:
            bridge[f"m{index}_{suffix.lower()}"] = f"m_axi_out{index}_{suffix}"
    for suffix in AXI:
        bridge[f"observed_{suffix.lower()}"] = f"m_axi_observed_trace_{suffix}"
    lines.append("tm1tn8_joint_bridge bridge (\n"+",\n".join(
        f"  .{key}({value})" for key,value in bridge.items())+"\n);")
    for prefix in ("m_axi_out0_", "m_axi_out1_", "m_axi_observed_trace_"):
        lines.extend(sideband(prefix))
    lines.append("endmodule")
    path.write_text("\n".join(lines)+"\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("hls_top", type=Path)
    ap.add_argument("hls_arg_control", type=Path)
    ap.add_argument("output", type=Path)
    args = ap.parse_args()
    top, arg, output = (x.resolve() for x in
                        (args.hls_top, args.hls_arg_control, args.output))
    require(not output.exists(), "fresh wrapper output required")
    ports, decls, params = parse_top(top)
    width = int(params["C_S_AXI_CONTROL_R_ADDR_WIDTH"])
    offsets = parse_arg_registers(arg, width)
    output.mkdir(parents=True)
    sv = output/"q8_tm1tn8_gs32_512.sv"
    emit(sv, ports, decls, params, offsets)
    xdc = output/"q8_tm1tn8_gs32_512.xdc"
    xdc.write_text("create_clock -name ap_clk -period 6.667 [get_ports ap_clk]\n"
                   "set_clock_uncertainty 0.035 [get_clocks ap_clk]\n")
    manifest={"schema":"tm1tn8_joint_dma_wrapper_v1",
              "inputs":[digest(top),digest(arg),digest(Path(__file__))],
              "outputs":[digest(sv),digest(xdc)],
              "pointer_offsets":offsets,
              "read_axi_data_widths":{x:512 for x in
                  ("w_q0","w_q1","w_scale","activation")}}
    (output/"manifest.json").write_text(json.dumps(manifest,indent=2,
                                                    sort_keys=True)+"\n")
    print("TM1TN8_JOINT_DMA_WRAPPER_PASS ports="+str(len(ports)))


if __name__ == "__main__":
    main()
