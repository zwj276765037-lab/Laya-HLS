#!/usr/bin/env python3
"""Emit the first Scorer pilot's literal nine-AXI/two-Lite binding.

Source generation only: no fixture computation or EDA invocation.
"""
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
RTL = HERE.parents[1] / "runs/csynth_local_v1/work/hls/syn/verilog/q8_joint_tm4tn8.v"
OUT = HERE / "q8_full_scorer_top.sv"

PORTS = [
    ("descriptor", 32, [0x1000000000]),
    ("w_q0", 512, [0x1100000000+184156160+i*4096 for i in range(128)]),
    ("w_q1", 512, [0x1200000000+184156160+i*4096 for i in range(128)]),
    ("w_scale", 512, [0x1300000000+23019520+i*4096 for i in range(16)]),
    ("aux", 32, [0x1400000000, 0x1400000000+1667072,
                 0x1400000000+1671168]),
    ("activation", 512, [0x1500000000+i*4096 for i in range(16)]),
    ("out0", 32, [0x1600000000+i*4096 for i in range(16)]),
    ("out1", 32, [0x1700000000]),
    ("observed", 32, [0x1800000000 + i*4096 for i in range(32)]),
]
AXI_FIELDS = ["AWVALID", "AWREADY", "AWADDR", "AWID", "AWLEN", "AWSIZE",
              "AWBURST", "AWLOCK", "AWCACHE", "AWPROT", "AWQOS", "AWREGION",
              "AWUSER", "WVALID", "WREADY", "WDATA", "WSTRB", "WLAST", "WID",
              "WUSER", "ARVALID", "ARREADY", "ARADDR", "ARID", "ARLEN",
              "ARSIZE", "ARBURST", "ARLOCK", "ARCACHE", "ARPROT", "ARQOS",
              "ARREGION", "ARUSER", "RVALID", "RREADY", "RDATA", "RLAST",
              "RID", "RUSER", "RRESP", "BVALID", "BREADY", "BRESP", "BID",
              "BUSER"]
COUNTS = ["aw_count", "w_count", "b_count", "ar_count", "r_count",
          "rlast_count", "read_bus_bytes", "write_bus_bytes",
          "write_useful_bytes", "write_pending", "read_pending"]

text = RTL.read_text()
params = {}
for name, value in re.findall(r"^parameter\s+(C_\w+)\s*=\s*([^;]+);", text, re.M):
    value = value.strip()
    if re.fullmatch(r"\d+", value):
        params[name] = int(value)
    elif re.fullmatch(r"\(\d+ / \d+\)", value):
        a, b = map(int, re.findall(r"\d+", value))
        params[name] = a//b
    else:
        raise ValueError((name,value))
decls = []
for direction, width, name in re.findall(
    r"^\s*(input|output)\s+(\[[^\]]+\])?\s*(\w+)\s*;", text, re.M):
    if name == "ap_clk" or name == "ap_rst_n":
        continue
    if width:
        m = re.fullmatch(r"\[(C_\w+) - 1:0\]", width)
        if m:
            width = f"[{params[m.group(1)]-1}:0]"
    decls.append((direction, width, name))
assert len(decls) == 9*len(AXI_FIELDS)+35, len(decls)
names = {name for _, _, name in decls}
for port, _, _ in PORTS:
    assert all(f"m_axi_gmem_{port}_{field}" in names for field in AXI_FIELDS)

lines = ["`timescale 1ns/1ps", "// Generated literal binding from the frozen q8_joint_tm4tn8.v port list.",
         "module q8_full_scorer_top;", "  logic clk=0;", "  always #3.333 clk=~clk;",
         "  logic resetn=0;"]
for _, width, name in decls:
    lines.append(f"  logic {width} {name};" if width else f"  logic {name};")
lines += ["  q8_joint_tm4tn8 dut (", "    .ap_clk(clk),", "    .ap_rst_n(resetn),"]
for index, (_, _, name) in enumerate(decls):
    lines.append(f"    .{name}({name}){',' if index<len(decls)-1 else ''}")
lines.append("  );")
for side in ("dut", "ram"):
    for count in COUNTS:
        width = "[63:0] " if count.endswith("bytes") else "" if count.endswith("pending") else "[31:0] "
        lines.append(f"  logic {width}{side}_{count} [0:8];")
lines += ["  logic [31:0] accepted [0:8][0:4], delivered [0:8][0:4];",
          "  logic r_hold_applied [0:8], b_hold_applied [0:8];",
          "  logic [31:0] r_special_wait_cycles [0:8], b_special_wait_cycles [0:8];",
          "  logic hold_final_r [0:8], hold_final_b [0:8];",
          "  logic [1:0][63:0] read_lo [0:8], read_hi [0:8];",
          "  logic [3:0][63:0] write_lo [0:8], write_hi [0:8];"]
for idx, (port, bits, pages) in enumerate(PORTS):
    packed_bases = "{" + ",".join(f"64'h{x:016x}" for x in reversed(pages)) + "}"
    lines += [f"  q8_axi_port #(.DATA_BITS({bits}),.PORT({idx}),.PAGE_COUNT({len(pages)}),",
              f"                .PAGE_BASES({packed_bases})) u_port_{port} (",
              "    .clk(clk),.resetn(resetn),",
              f"    .read_lo(read_lo[{idx}]),.read_hi(read_hi[{idx}]),",
              f"    .write_lo(write_lo[{idx}]),.write_hi(write_hi[{idx}]),",
              f"    .hold_final_r(hold_final_r[{idx}]),.hold_final_b(hold_final_b[{idx}]),",
              f"    .r_hold_applied(r_hold_applied[{idx}]),.b_hold_applied(b_hold_applied[{idx}]),",
              f"    .r_special_wait_cycles(r_special_wait_cycles[{idx}]),",
              f"    .b_special_wait_cycles(b_special_wait_cycles[{idx}]),"]
    for field in AXI_FIELDS:
        lines.append(f"    .{field.lower()}(m_axi_gmem_{port}_{field}),")
    for side in ("dut", "ram"):
        for count in COUNTS:
            lines.append(f"    .{side}_{count}({side}_{count}[{idx}]),")
    lines += [f"    .accepted(accepted[{idx}]),.delivered(delivered[{idx}])", "  );"]
for bank, prefix, width in ((0,"s_axi_control",4),(1,"s_axi_control_r",7)):
    lines += [f"  logic lite_cmd_valid_{bank},lite_cmd_ready_{bank},lite_cmd_write_{bank},lite_cmd_done_{bank};",
              f"  logic [{width-1}:0] lite_cmd_addr_{bank};",
              f"  logic [31:0] lite_cmd_wdata_{bank},lite_cmd_rdata_{bank};",
              f"  q8_axi_lite_master #(.ADDR_BITS({width}),.BANK({bank})) lite_{bank} (",
              f"    .clk(clk),.resetn(resetn),.cmd_valid(lite_cmd_valid_{bank}),",
              f"    .cmd_ready(lite_cmd_ready_{bank}),.cmd_write(lite_cmd_write_{bank}),",
              f"    .cmd_addr(lite_cmd_addr_{bank}),.cmd_wdata(lite_cmd_wdata_{bank}),",
              f"    .cmd_done(lite_cmd_done_{bank}),.cmd_rdata(lite_cmd_rdata_{bank}),"]
    for field in ("AWVALID","AWREADY","AWADDR","WVALID","WREADY","WDATA",
                  "WSTRB","BVALID","BREADY","BRESP","ARVALID","ARREADY",
                  "ARADDR","RVALID","RREADY","RDATA","RRESP"):
        lines.append(f"    .{field.lower()}({prefix}_{field}){',' if field!='RRESP' else ''}")
    lines.append("  );")
lines += ['  `include "q8_full_scorer_control.svh"',
          '  `include "q8_full_scorer_observer.svh"', "endmodule"]
OUT.write_text("\n".join(lines)+"\n")
print(f"wrote {OUT} with {len(decls)} generated DUT ports")
