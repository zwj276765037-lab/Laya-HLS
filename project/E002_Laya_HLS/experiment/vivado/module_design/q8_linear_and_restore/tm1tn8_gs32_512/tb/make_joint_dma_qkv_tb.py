#!/usr/bin/env python3
"""Bind real HLS joint-wrapper ports to the full QKV BO testbench."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import re

from make_joint_dma_act_tb import (MEMORIES, digest, parse_wrapper, require,
                                   slave)

HERE = Path(__file__).resolve().parent
BODY = HERE / "tm1tn8_joint_dma_qkv_body.svh"
PERF_BODY = HERE / "tm1tn8_joint_dma_qkv_perf_body.svh"
SLAVE = HERE / "tm1tn8_axi_memory_slave.sv"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("wrapper", type=Path)
    ap.add_argument("inputs", type=Path)
    ap.add_argument("vectors", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--trace-off", action="store_true")
    ap.add_argument("--perf", action="store_true")
    ap.add_argument("--runs", type=int, choices=(1, 2), default=1)
    args = ap.parse_args()
    require(args.runs == 1 or args.perf, "continuous QKV requires performance body")
    wrapper, inputs, vectors, output = (x.resolve() for x in
                                        (args.wrapper, args.inputs,
                                         args.vectors, args.output))
    require(not output.exists(), "fresh QKV TB directory")
    wm = json.loads((wrapper / "manifest.json").read_text())
    im = json.loads((inputs / "manifest.json").read_text())
    vm = json.loads((vectors / "manifest.json").read_text())
    require(wm["schema"] == "tm1tn8_joint_dma_wrapper_v1" and
            im["schema"] == "tm1tn8_joint_dma_qkv_axi_inputs_v1" and
            vm["schema"] == "tm1tn8_arithmetic_vectors_v1" and
            im["case"] == vm["case"] and im["rows"] == vm["rows"] and
            im["rows"] in (1, 4), "QKV wrapper/input/gold identity")
    ports, decls = parse_wrapper(wrapper / "q8_tm1tn8_gs32_512.sv")
    body = PERF_BODY if args.perf else BODY
    record = im["model_record"]
    lines = ["`timescale 1ns/1ps", "module tm1tn8_joint_dma_qkv_tb;"]
    for port in ports:
        _, width = decls[port]
        lines.append(f"  logic {width} {port};")
    lines.append("  q8_tm1tn8_gs32_512 dut ("+
                 ", ".join(f".{port}({port})" for port in ports)+");")
    for short, _, width, _ in MEMORIES:
        lines += [f"  logic [{width-1}:0] {short}_read_contents;",
                  f"  logic [63:0] {short}_read_address, {short}_write_address;",
                  f"  logic {short}_debt_zero;",
                  f"  logic [31:0] {short}_ar_count, {short}_r_count, "
                  f"{short}_aw_count, {short}_w_count, {short}_b_count;"]
    for short, prefix, width, reader in MEMORIES:
        lines.append("  " + slave(short, prefix, width, reader))
    for port in ports:
        direction, _ = decls[port]
        if direction == "input" and re.search(
                r"m_axi_gmem_\w+_(RID|RUSER|BID|BUSER)$", port):
            lines.append(f"  assign {port} = '0;")
    lines += [f"  localparam int ROWS={im['rows']};",
              f"  localparam bit TRACE_ON={0 if args.trace_off else 1};",
              f"  localparam int RUN_COUNT={args.runs};",
              f"  localparam logic [63:0] Q0_OFFSET=64'd{record['q0_offset']};",
              f"  localparam logic [63:0] Q1_OFFSET=64'd{record['q1_offset']};",
              f"  localparam logic [63:0] SCALE_OFFSET=64'd{record['scale_offset']};",
              body.read_text()]
    output.mkdir(parents=True)
    sv = output / "tm1tn8_joint_dma_qkv_tb.sv"
    sv.write_text("\n".join(lines)+"\n")
    manifest = {"schema": "tm1tn8_joint_dma_qkv_tb_v1",
                "case": im["case"], "rows": im["rows"],
                "trace_on": not args.trace_off,
                "runs": args.runs,
                "inputs": [digest(wrapper/"q8_tm1tn8_gs32_512.sv"),
                           digest(wrapper/"manifest.json"),
                           digest(inputs/"manifest.json"),
                           digest(vectors/"manifest.json"),
                           digest(body), digest(SLAVE),
                           digest(Path(__file__))],
                "generated_testbench": digest(sv),
                "wrapper_ports": len(ports)}
    (output/"manifest.json").write_text(json.dumps(manifest, indent=2,
                                                   sort_keys=True)+"\n")
    print(f"TM1TN8_JOINT_DMA_QKV_TB_PASS rows={im['rows']} ports={len(ports)}")


if __name__ == "__main__":
    main()
