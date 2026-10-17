#!/usr/bin/env python3
"""Bind a bounded full-top RTL front chain to all 13 real AXI ports."""

import re
from pathlib import Path

stage = Path(__file__).resolve().parents[1]
top = stage / "attempts/full_hls_01/work/hls/syn/verilog/laya_typed_q8_forward.v"
source = top.read_text()
header = source.split("module laya_typed_q8_forward (", 1)[1].split(");", 1)[0]
ports = [x.strip().rstrip(",") for x in header.splitlines() if x.strip()]
parameters = re.findall(r"^parameter\s+[^;]+;", source, re.M)
declarations = re.findall(r"^(input|output)\s+(?:(?:wire|reg)\s+)?(\[[^\]]+\]\s+)?(\w+);", source, re.M)
by_name = {name: (direction, width) for direction, width, name in declarations}
assert len(ports) == len(set(ports)) == len(by_name)
assert set(ports) == set(by_name)
bo_names = ("embedding", "io", "w_q0", "w_q1", "w_scale", "aux", "state0",
            "state1", "qkv0", "qkv1", "ff0", "ff1", "att_out")
for bo in bo_names:
    assert all(f"m_axi_{bo}_{channel}" in by_name for channel in
               ("AWVALID", "AWREADY", "AWADDR", "WVALID", "WREADY",
                "WDATA", "WSTRB", "WLAST", "ARVALID", "ARREADY",
                "ARADDR", "RVALID", "RREADY", "RDATA", "RLAST",
                "BVALID", "BREADY"))

lines = ["`timescale 1ns/1ps", "module front_chain_top;",
    'import "DPI-C" function int front_mem_init();',
    'import "DPI-C" function int front_mem_seen();',
    'import "DPI-C" function int front_mem_progress();',
    'import "DPI-C" function int front_mem_consumed();',
    'import "DPI-C" function int front_mem_errors();',
    'import "DPI-C" function int front_mem_result_status();',
    'import "DPI-C" function int front_mem_check();',
    *[x.replace("parameter", "localparam", 1) for x in parameters],
    *[f"logic {by_name[name][1]}{name};" for name in ports],
    "logic launch = 0, aw_sent = 0, w_sent = 0;",
    "integer cycles = 0;",
    "initial ap_clk = 0;", "always #3.333 ap_clk = ~ap_clk;",
    "initial begin",
    "  ap_rst_n = 0;",
    "  if (!front_mem_init()) $fatal(1, \"front memory setup\");",
    "  repeat (20) @(negedge ap_clk);",
    "  ap_rst_n = 1;",
    "  repeat (5) @(negedge ap_clk);",
    "  launch = 1;",
    "end",
    "always @(posedge ap_clk) begin",
    "  if (ap_rst_n) begin",
    "    if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent <= 1;",
    "    if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent <= 1;",
    "    cycles <= cycles + 1;",
    "    if ((cycles % 8192) == 0 && cycles != 0)",
    '      $display("FRONT_PROGRESS cycles=%0d norm_bytes=%0d accepted=%0d", cycles, front_mem_seen(), front_mem_progress());',
    "    if ((cycles % 1024) == 0) begin",
    "      if (front_mem_errors() != 0) $fatal(1, \"AXI memory error\");",
    "      if (front_mem_result_status() >= 0)",
    "        $fatal(1, \"full top committed before front chain completed\");",
    "      if (front_mem_consumed()) begin",
    "        if (!front_mem_check()) $fatal(1, \"embedding_norm oracle mismatch\");",
    '        $display("FRONT_CHAIN_RTL_PASS cycles=%0d", cycles);',
    "        $finish;",
    "      end",
    "    end",
    "    if (cycles >= 40000000) $fatal(1, \"40M cycle cap\");",
    "  end",
    "end",
    "assign s_axi_control_AWVALID = launch && !aw_sent;",
    "assign s_axi_control_AWADDR = 0;",
    "assign s_axi_control_WVALID = launch && !w_sent;",
    "assign s_axi_control_WDATA = 32'h1;",
    "assign s_axi_control_WSTRB = 4'hf;",
    "assign s_axi_control_BREADY = 1;",
    "assign s_axi_control_ARVALID = 0;",
    "assign s_axi_control_ARADDR = 0;",
    "assign s_axi_control_RREADY = 1;",
    "assign s_axi_control_r_AWVALID = 0;",
    "assign s_axi_control_r_AWADDR = 0;",
    "assign s_axi_control_r_WVALID = 0;",
    "assign s_axi_control_r_WDATA = 0;",
    "assign s_axi_control_r_WSTRB = 0;",
    "assign s_axi_control_r_BREADY = 1;",
    "assign s_axi_control_r_ARVALID = 0;",
    "assign s_axi_control_r_ARADDR = 0;",
    "assign s_axi_control_r_RREADY = 1;",
    "laya_typed_q8_forward dut(",
    ",\n".join(f"  .{name}({name})" for name in ports),
    ");"]

channels = ("AWVALID", "AWREADY", "AWADDR", "AWID", "AWLEN", "AWSIZE",
            "AWBURST", "WVALID", "WREADY", "WDATA", "WSTRB", "WLAST",
            "ARVALID", "ARREADY", "ARADDR", "ARID", "ARLEN", "ARSIZE",
            "ARBURST", "RVALID", "RREADY", "RDATA", "RLAST", "RID",
            "RRESP", "BVALID", "BREADY", "BRESP", "BID")
for index, bo in enumerate(bo_names):
    lines.append(f"front_axi_memory #(.PORT_INDEX({index})) mem_{bo}(")
    lines.append("  .clk(ap_clk), .rst_n(ap_rst_n),")
    lines.append(",\n".join(f"  .{channel}(m_axi_{bo}_{channel})" for channel in channels))
    lines.append(");")
    # The production top has AXI USER responses, held at the documented zero.
    lines.append(f"assign m_axi_{bo}_RUSER = 0;")
    lines.append(f"assign m_axi_{bo}_BUSER = 0;")
lines.append("endmodule")

lines.append(r'''module front_axi_memory #(parameter integer PORT_INDEX = 0)(
  input logic clk, rst_n,
  input logic AWVALID, output logic AWREADY, input logic [63:0] AWADDR,
  input logic AWID, input logic [7:0] AWLEN, input logic [2:0] AWSIZE,
  input logic [1:0] AWBURST,
  input logic WVALID, output logic WREADY, input logic [31:0] WDATA,
  input logic [3:0] WSTRB, input logic WLAST,
  input logic ARVALID, output logic ARREADY, input logic [63:0] ARADDR,
  input logic ARID, input logic [7:0] ARLEN, input logic [2:0] ARSIZE,
  input logic [1:0] ARBURST,
  output logic RVALID, input logic RREADY, output logic [31:0] RDATA,
  output logic RLAST, output logic RID, output logic [1:0] RRESP,
  output logic BVALID, input logic BREADY, output logic [1:0] BRESP,
  output logic BID
);
import "DPI-C" function int front_mem_read(input int port,
                                            input longint unsigned address);
import "DPI-C" function void front_mem_read_accept(input int port,
                                                   input longint unsigned address);
import "DPI-C" function void front_mem_write(input int port,
    input longint unsigned address, input int word, input byte unsigned strobe);
logic rd_active = 0, wr_active = 0, b_valid = 0;
logic [63:0] rd_address = 0, wr_address = 0;
logic [8:0] rd_remaining = 0, wr_remaining = 0;
logic [2:0] rd_size = 0, wr_size = 0;
logic rd_id = 0, wr_id = 0;
assign ARREADY = !rd_active;
assign RVALID = rd_active;
assign RLAST = rd_active && rd_remaining == 1;
assign RID = rd_id;
assign RRESP = 0;
assign RDATA = rd_active ? front_mem_read(PORT_INDEX, rd_address) : 0;
assign AWREADY = !wr_active && !b_valid;
assign WREADY = wr_active;
assign BVALID = b_valid;
assign BID = wr_id;
assign BRESP = 0;
always @(posedge clk) begin
  if (!rst_n) begin
    rd_active <= 0; wr_active <= 0; b_valid <= 0;
    rd_remaining <= 0; wr_remaining <= 0;
  end else begin
    if (ARVALID && ARREADY) begin
      if (ARBURST != 2'b01 && ARLEN != 0) $fatal(1, "unsupported AXI read burst");
      rd_active <= 1;
      rd_address <= ARADDR;
      rd_remaining <= {1'b0, ARLEN} + 1;
      rd_size <= ARSIZE;
      rd_id <= ARID;
    end
    if (RVALID && RREADY) begin
      front_mem_read_accept(PORT_INDEX, rd_address);
      if (rd_remaining == 1) rd_active <= 0;
      else begin
        rd_address <= rd_address + (64'b1 << rd_size);
        rd_remaining <= rd_remaining - 1;
      end
    end
    if (AWVALID && AWREADY) begin
      if (AWBURST != 2'b01 && AWLEN != 0) $fatal(1, "unsupported AXI write burst");
      wr_active <= 1;
      wr_address <= AWADDR;
      wr_remaining <= {1'b0, AWLEN} + 1;
      wr_size <= AWSIZE;
      wr_id <= AWID;
    end
    if (WVALID && WREADY) begin
      if (WLAST != (wr_remaining == 1)) $fatal(1, "AXI WLAST mismatch");
      front_mem_write(PORT_INDEX, wr_address, WDATA, {4'b0, WSTRB});
      if (wr_remaining == 1) begin wr_active <= 0; b_valid <= 1; end
      else begin
        wr_address <= wr_address + (64'b1 << wr_size);
        wr_remaining <= wr_remaining - 1;
      end
    end
    if (BVALID && BREADY) b_valid <= 0;
  end
end
endmodule''')

out = stage / "tb/front_chain_top.sv"
out.write_text("\n".join(lines) + "\n")
print(f"{out} ports={len(ports)} axi_ports={len(bo_names)} bytes={out.stat().st_size}")
