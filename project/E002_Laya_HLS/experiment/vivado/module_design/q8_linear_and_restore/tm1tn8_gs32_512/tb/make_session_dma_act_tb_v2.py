#!/usr/bin/env python3
"""Bind the Q8S2 ACT testbench to actual generated wrapper ports."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
BODY = HERE / "tm1tn8_session_dma_act_body_v2.svh"
SLAVE = HERE / "tm1tn8_axi_memory_slave.sv"
MEMORIES = (("descriptor", "m_axi_gmem_descriptor", 32, True),
            ("w_q0", "m_axi_gmem_w_q0", 512, True),
            ("w_q1", "m_axi_gmem_w_q1", 512, True),
            ("w_scale", "m_axi_gmem_w_scale", 512, True),
            ("aux", "m_axi_gmem_aux", 32, True),
            ("activation", "m_axi_gmem_activation", 512, True),
            ("observed", "m_axi_gmem_observed", 32, True),
            ("out0", "m_axi_out0", 512, False),
            ("out1", "m_axi_out1", 512, False),
            ("trace", "m_axi_observed_trace", 32, False))


def require(ok: bool, why: str) -> None:
    if not ok:
        raise AssertionError(why)


def digest(path: Path) -> dict:
    raw = path.read_bytes()
    return {"path": str(path.resolve()), "bytes": len(raw),
            "sha256": hashlib.sha256(raw).hexdigest()}


def parse_wrapper(path: Path) -> tuple[list[str], dict[str, tuple[str, str]]]:
    source = path.read_text()
    match = re.search(r"\bmodule\s+q8_tm1tn8_gs32_512_session_v2\s*\((.*?)\);",
                      source, re.S)
    require(match is not None, "joint generated wrapper module")
    ports = [p.strip() for p in match[1].split(",") if p.strip()]
    decls = {name: (direction, width or "") for direction, width, name in
             re.findall(r"^(input|output)\s+wire\s+(\[[^\n;]+\])?\s*([A-Za-z_]\w*)\s*;",
                        source, re.M) if name in ports}
    require(set(ports) == set(decls) and len(ports) == len(set(ports)),
            "joint wrapper port declarations")
    require("ap_clk" in decls and "ap_rst_n" in decls,
            "wrapper clock/reset")
    for _, prefix, width, reader in MEMORIES:
        for signal in ("AWADDR", "AWLEN", "AWSIZE", "AWVALID", "AWREADY",
                       "WDATA", "WSTRB", "WLAST", "WVALID", "WREADY",
                       "BRESP", "BVALID", "BREADY"):
            require(prefix + "_" + signal in decls,
                    f"missing {prefix}_{signal}")
        require(decls[prefix+"_WDATA"][1] == f"[{width-1}:0]",
                f"{prefix} data width")
        if reader:
            for signal in ("ARADDR", "ARLEN", "ARSIZE", "ARVALID",
                           "ARREADY", "RDATA", "RRESP", "RLAST",
                           "RVALID", "RREADY"):
                require(prefix+"_"+signal in decls,
                        f"missing {prefix}_{signal}")
    return ports, decls


def slave(short: str, prefix: str, width: int, reader: bool) -> str:
    def p(signal: str) -> str:
        return f"{prefix}_{signal}"
    rd = (f".araddr({p('ARADDR')}), .arlen({p('ARLEN')}), "
          f".arsize({p('ARSIZE')}), .arvalid({p('ARVALID')}), "
          f".arready({p('ARREADY')}), .rdata({p('RDATA')}), "
          f".rresp({p('RRESP')}), .rlast({p('RLAST')}), "
          f".rvalid({p('RVALID')}), .rready({p('RREADY')})"
          if reader else
          ".araddr(64'd0), .arlen(8'd0), .arsize(3'd0), "
          ".arvalid(1'b0), .arready(), .rdata(), .rresp(), "
          ".rlast(), .rvalid(), .rready(1'b0)")
    wr = (f".awaddr({p('AWADDR')}), .awlen({p('AWLEN')}), "
          f".awsize({p('AWSIZE')}), .awvalid({p('AWVALID')}), "
          f".awready({p('AWREADY')}), .wdata({p('WDATA')}), "
          f".wstrb({p('WSTRB')}), .wlast({p('WLAST')}), "
          f".wvalid({p('WVALID')}), .wready({p('WREADY')}), "
          f".bresp({p('BRESP')}), .bvalid({p('BVALID')}), "
          f".bready({p('BREADY')})")
    return (f"tm1tn8_axi_memory_slave #(.DATA_W({width}), "
            f".B_HOLD({12 if short == 'trace' else 9}), "
            f".R_HOLD({7 if short in ('w_q0', 'w_scale', 'aux') else 0})) "
            f"{short}_memory (\n"
            f"  .clk(ap_clk), .rst_n(ap_rst_n), {rd},\n"
            f"  .read_address({short}_read_address), "
            f".read_contents({short}_read_contents),\n"
            f"  {wr},\n"
            f"  .write_address({short}_write_address), "
            f".debt_zero({short}_debt_zero),\n"
            f"  .ar_count({short}_ar_count), .r_count({short}_r_count), "
            f".aw_count({short}_aw_count), .w_count({short}_w_count), "
            f".b_count({short}_b_count));")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("wrapper", type=Path)
    ap.add_argument("inputs", type=Path)
    ap.add_argument("vectors", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--trace-off", action="store_true")
    args = ap.parse_args()
    wrapper, inputs, vectors, output = (x.resolve() for x in
                                        (args.wrapper, args.inputs,
                                         args.vectors, args.output))
    require(not output.exists(), "fresh generated ACT TB directory")
    wm = json.loads((wrapper / "manifest.json").read_text())
    im = json.loads((inputs / "manifest.json").read_text())
    vm = json.loads((vectors / "manifest.json").read_text())
    require(wm["schema"] == "tm1tn8_session_dma_wrapper_v2" and
            im["schema"] == "tm1tn8_session_dma_act_inputs_v2" and
            vm["schema"] == "tm1tn8_arithmetic_vectors_v1" and
            vm["case"] == "act" and vm["rows"] == 1,
            "generated wrapper and actual ACT inputs")
    ports, decls = parse_wrapper(wrapper / "q8_tm1tn8_gs32_512_session_v2.sv")
    body = BODY
    record = im["model_record"]
    lines = ["`timescale 1ns/1ps", "module tm1tn8_session_dma_act_tb;"]
    for port in ports:
        _, width = decls[port]
        lines.append(f"  logic {width} {port};")
    lines.append("  q8_tm1tn8_gs32_512_session_v2 dut ("+
                 ", ".join(f".{port}({port})" for port in ports)+");")
    for short, prefix, width, _ in MEMORIES:
        lines += [f"  logic [{width-1}:0] {short}_read_contents;",
                  f"  logic [63:0] {short}_read_address, {short}_write_address;",
                  f"  logic {short}_debt_zero;",
                  f"  logic [31:0] {short}_ar_count, {short}_r_count, "
                  f"{short}_aw_count, {short}_w_count, {short}_b_count;"]
    for short, prefix, width, reader in MEMORIES:
        lines.append("  " + slave(short, prefix, width, reader))
    for port in ports:
        direction, _ = decls[port]
        if direction == "input" and re.search(r"m_axi_gmem_\w+_(RID|RUSER|BID|BUSER)$",port):
            lines.append(f"  assign {port} = '0;")
    lines += [f"  localparam logic [63:0] Q0_OFFSET=64'd{record['q0_offset']};",
              f"  localparam logic [63:0] SCALE_OFFSET=64'd{record['scale_offset']};",
              f"  localparam logic [63:0] BIAS_OFFSET=64'd{record['bias_offset']};",
              f"  localparam bit TRACE_ON={0 if args.trace_off else 1};",
              body.read_text()]
    output.mkdir(parents=True)
    sv = output / "tm1tn8_session_dma_act_tb.sv"
    sv.write_text("\n".join(lines)+"\n")
    manifest = {"schema": "tm1tn8_session_dma_act_tb_v2",
                "trace_on": not args.trace_off,
                "runs": 2,
                "inputs": [digest(wrapper / "q8_tm1tn8_gs32_512_session_v2.sv"),
                           digest(wrapper / "manifest.json"),
                           digest(inputs / "manifest.json"),
                           digest(vectors / "manifest.json"),
                           digest(body), digest(SLAVE), digest(Path(__file__))],
                "generated_testbench": digest(sv),
                "wrapper_ports": len(ports)}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2,
                                                    sort_keys=True)+"\n")
    print("TM1TN8_SESSION_DMA_ACT_TB_V2_PASS ports="+str(len(ports)))


if __name__ == "__main__":
    main()
