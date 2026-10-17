#!/usr/bin/env python3
"""Generate the five-port first-ap_done AXI checker from actual HLS RTL ports."""

import re
import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: make_cpu_front_top.py TOP_VERILOG OUTPUT_SV")
top = Path(sys.argv[1]).resolve()
out = Path(sys.argv[2]).resolve()
source = top.read_text()
module = "laya_cpu_embedding_ln_chain"
header = source.split(f"module {module} (", 1)[1].split(");", 1)[0]
ports = [line.strip().rstrip(",") for line in header.splitlines() if line.strip()]
params = re.findall(r"^parameter\s+[^;]+;", source, re.M)
declarations = re.findall(
    r"^(input|output)\s+(?:(?:wire|reg)\s+)?(\[[^\]]+\]\s+)?(\w+);",
    source, re.M)
by_name = {name: (direction, width) for direction, width, name in declarations}
assert len(ports) == len(set(ports)) == len(by_name)
assert set(ports) == set(by_name)
bo_names = ("io", "aux", "state0", "state1", "observed")
channels = ("AWVALID", "AWREADY", "AWADDR", "AWID", "AWLEN", "AWSIZE",
            "AWBURST", "WVALID", "WREADY", "WDATA", "WSTRB", "WLAST",
            "ARVALID", "ARREADY", "ARADDR", "ARID", "ARLEN", "ARSIZE",
            "ARBURST", "RVALID", "RREADY", "RDATA", "RLAST", "RID",
            "RRESP", "BVALID", "BREADY", "BRESP", "BID")
for bo in bo_names:
    assert re.search(rf"parameter\s+C_M_AXI_{bo.upper()}_DATA_WIDTH\s*=\s*32\s*;",
                     source)
    if bo in ("io", "aux", "state0", "state1"):
        assert all(f"m_axi_{bo}_{channel}" in by_name for channel in
                   ("ARVALID", "ARREADY", "ARADDR", "RVALID", "RREADY", "RDATA"))
    if bo in ("state1", "observed"):
        assert all(f"m_axi_{bo}_{channel}" in by_name for channel in
                   ("AWVALID", "AWREADY", "WVALID", "WREADY", "BVALID", "BREADY"))
for name in ("ap_clk", "ap_rst_n", "s_axi_control_AWVALID"):
    assert name in by_name
assert re.search(r"^(?:reg|wire)\s+ap_done;", source, re.M)

# Read-only probes of the generated production LN loop.  These distinguish
# arithmetic progress from long intervals without external AXI traffic.
ln_wrapper = ("dut.grp_full_execute_cpu_frontend_fu_400."
              "grp_p_anonymous_namespace_frontend_from_hidden_fu_1064."
              "grp_p_anonymous_namespace_norm_fu_742."
              "grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913."
              "grp_full_run_task_5_fu_334."
              "grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104")
ln_arith = ln_wrapper + ".grp_layernorm_row_arithmetic_fu_101"

lines = ["`timescale 1ns/1ps", "module cpu_front_top;",
         'import "DPI-C" function int thin_mem_init();',
         'import "DPI-C" function int thin_mem_progress();',
         'import "DPI-C" function int thin_mem_raw_bytes();',
         'import "DPI-C" function int thin_mem_norm_bytes();',
         'import "DPI-C" function int thin_mem_obs_bytes();',
         'import "DPI-C" function int thin_mem_state0_import_words();',
         'import "DPI-C" function int thin_mem_state0_ln_read_words();',
         'import "DPI-C" function int thin_mem_gamma_read_words();',
         'import "DPI-C" function int thin_mem_errors();',
         'import "DPI-C" function int thin_mem_capture_first_done();',
         'import "DPI-C" function int thin_mem_check();',
         *[item.replace("parameter", "localparam", 1) for item in params],
         *[f"logic {by_name[name][1]}{name};" for name in ports],
         "wire ap_done = dut.ap_done;",
         "logic launch = 0, aw_sent = 0, w_sent = 0;",
         "logic [4:0] debt_zero, r_hold_hit, b_hold_hit;",
         "wire [4:0] adapter_zero;",
         "logic [4:0] first_done_debt, first_done_adapter;",
         "logic first_done_r_hold, first_done_b_hold;",
         "logic first_done_numeric_ok;",
         "logic first_done_capture_ok, first_done_snapshot_ok;",
         "integer first_done_snapshot_fd;",
         "integer cycles = 0;",
         "integer ln_rows_done = 0, ln_local_writes = 0;",
         "integer ln_mean_steps = 0, ln_mean_levels = 0;",
         "integer ln_variance_steps = 0, ln_variance_levels = 0;",
         "logic ln_row_active = 0;",
         f"wire ln_row_start = {ln_arith}.ap_CS_fsm_state1 &&",
         f"  {ln_arith}.ap_start;",
         f"wire ln_row_done = ln_row_active && {ln_arith}.ap_ready &&",
         f"  {ln_arith}.ap_done;",
         f"wire ln_local_write = {ln_wrapper}.output_r_we0;",
         f"wire [3:0] ln_row_index = {ln_wrapper}.trunc_ln162_reg_243;",
         f"wire [10:0] ln_mean_width = {ln_arith}.width_fu_120;",
         f"wire [9:0] ln_mean_i = {ln_arith}.i_1_reg_286;",
         f"wire [10:0] ln_variance_width = {ln_arith}.width_2_fu_128;",
         f"wire [9:0] ln_variance_i = {ln_arith}.i_3_reg_298;",
         f"wire ln_mean_step = ln_row_active && {ln_arith}.ap_CS_fsm_state58 &&",
         f"  {ln_arith}.icmp_ln8_2_fu_700_p2 === 1'b0;",
         f"wire ln_mean_level = ln_row_active && {ln_arith}.ap_CS_fsm_state52 &&",
         f"  {ln_arith}.icmp_ln75_fu_630_p2 === 1'b0;",
         f"wire ln_variance_step = ln_row_active && {ln_arith}.ap_CS_fsm_state84 &&",
         f"  {ln_arith}.icmp_ln8_8_fu_956_p2 === 1'b0;",
         f"wire ln_variance_level = ln_row_active && {ln_arith}.ap_CS_fsm_state78 &&",
         f"  {ln_arith}.icmp_ln91_fu_886_p2 === 1'b0;",
         "initial ap_clk = 0; always #3.333 ap_clk = ~ap_clk;",
         "initial begin",
         "  ap_rst_n = 0;",
         '  if (!thin_mem_init()) $fatal(1, "memory setup");',
         "  repeat (20) @(negedge ap_clk);",
         "  ap_rst_n = 1;",
         "  repeat (5) @(negedge ap_clk);",
         "  launch = 1;",
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
         "always @(posedge ap_clk) if (ap_rst_n) begin",
         "  if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent <= 1;",
         "  if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent <= 1;",
         '  if ((m_axi_io_AWVALID || m_axi_io_WVALID ||',
         '       m_axi_aux_AWVALID || m_axi_aux_WVALID ||',
         '       m_axi_state0_AWVALID || m_axi_state0_WVALID) !== 1\'b0)',
         '    $fatal(1, "read-only production port wrote");',
         '  if (m_axi_observed_ARVALID !== 1\'b0)',
         '    $fatal(1, "observed port read");',
         "  cycles <= cycles + 1;",
         "  if (ln_row_start) ln_row_active <= 1;",
         "  if (ln_row_done) begin",
         "    ln_rows_done <= ln_rows_done + 1;",
         "    ln_row_active <= 0;",
         "  end",
         "  if (ln_row_active && ln_local_write) ln_local_writes <= ln_local_writes + 1;",
         "  if (ln_mean_step) ln_mean_steps <= ln_mean_steps + 1;",
         "  if (ln_mean_level) ln_mean_levels <= ln_mean_levels + 1;",
         "  if (ln_variance_step) ln_variance_steps <= ln_variance_steps + 1;",
         "  if (ln_variance_level) ln_variance_levels <= ln_variance_levels + 1;",
         "  if (cycles != 0 && cycles % 8192 == 0)",
         '    $display("CPU_FRONT_PROGRESS cycles=%0d raw=%0d norm=%0d observed=%0d import_words=%0d ln_words=%0d gamma_words=%0d accepted=%0d ln_rows=%0d ln_local=%0d ln_mean_steps=%0d ln_mean_levels=%0d ln_variance_steps=%0d ln_variance_levels=%0d ln_row=%0d ln_mean_width=%0d ln_mean_i=%0d ln_variance_width=%0d ln_variance_i=%0d",',
         "      cycles, thin_mem_raw_bytes(), thin_mem_norm_bytes(),",
         "      thin_mem_obs_bytes(), thin_mem_state0_import_words(),",
         "      thin_mem_state0_ln_read_words(), thin_mem_gamma_read_words(),",
         "      thin_mem_progress(), ln_rows_done, ln_local_writes,",
         "      ln_mean_steps, ln_mean_levels, ln_variance_steps,",
         "      ln_variance_levels, ln_row_index, ln_mean_width, ln_mean_i,",
         "      ln_variance_width, ln_variance_i);",
         '  if (thin_mem_errors()) $fatal(1, "AXI memory error");',
         "  if (ap_done) begin",
         "    first_done_debt = debt_zero;",
         "    first_done_adapter = adapter_zero;",
         "    first_done_r_hold = r_hold_hit[2];",
         "    first_done_b_hold = b_hold_hit[3];",
         '    $display("CPU_FRONT_FIRST_DONE debt=%b adapter=%b observed_BVALID=%b observed_BREADY=%b observed_response_count=%0d observed_bytes=%0d",',
         "      first_done_debt, first_done_adapter,",
         "      dut.observed_0_BVALID, dut.observed_0_BREADY,",
         "      dut.observed_m_axi_U.store_unit_0.user_resp.if_num_data_valid,",
         "      thin_mem_obs_bytes());",
         "    first_done_capture_ok = thin_mem_capture_first_done();",
         "    first_done_numeric_ok = thin_mem_check();",
         '    first_done_snapshot_fd = $fopen("first_done_snapshot.txt", "w");',
         "    first_done_snapshot_ok = first_done_snapshot_fd != 0;",
         "    if (first_done_snapshot_ok) begin",
         '      $fdisplay(first_done_snapshot_fd, "cycles=%0d debt=%b adapter=%b observed_BVALID=%b observed_BREADY=%b observed_response_count=%0d norm_bytes=%0d observed_bytes=%0d import_words=%0d ln_read_words=%0d gamma_read_words=%0d r_hold=%b b_hold=%b numeric_ok=%b capture_ok=%b",',
         "        cycles, first_done_debt, first_done_adapter,",
         "        dut.observed_0_BVALID, dut.observed_0_BREADY,",
         "        dut.observed_m_axi_U.store_unit_0.user_resp.if_num_data_valid,",
         "        thin_mem_norm_bytes(), thin_mem_obs_bytes(),",
         "        thin_mem_state0_import_words(), thin_mem_state0_ln_read_words(),",
         "        thin_mem_gamma_read_words(), first_done_r_hold, first_done_b_hold,",
         "        first_done_numeric_ok, first_done_capture_ok);",
         "      $fclose(first_done_snapshot_fd);",
         "    end",
         '    if (first_done_debt !== 5\'b11111) $fatal(1, "debt at first ap_done: %b", first_done_debt);',
         '    if (first_done_adapter !== 5\'b11111) $fatal(1, "adapter debt at first ap_done: %b", first_done_adapter);',
         '    if (!first_done_r_hold || !first_done_b_hold) $fatal(1, "required holds not exercised");',
         '    if (!first_done_numeric_ok) $fatal(1, "front chain comparison");',
         '    if (!first_done_capture_ok || !first_done_snapshot_ok) $fatal(1, "first-done capture");',
         '    $display("CPU_FRONT_RTL_PASS cycles=%0d", cycles);',
         "    $finish;",
         "  end",
         '  if (cycles >= 40000000) $fatal(1, "40M cycle cap");',
         "end",
         ]
if "s_axi_control_r_AWVALID" in by_name:
    lines.extend([
         "assign s_axi_control_r_AWVALID = 0;",
         "assign s_axi_control_r_AWADDR = 0;",
         "assign s_axi_control_r_WVALID = 0;",
         "assign s_axi_control_r_WDATA = 0;",
         "assign s_axi_control_r_WSTRB = 0;",
         "assign s_axi_control_r_BREADY = 1;",
         "assign s_axi_control_r_ARVALID = 0;",
         "assign s_axi_control_r_ARADDR = 0;",
         "assign s_axi_control_r_RREADY = 1;",
    ])
lines.extend([
         f"{module} dut(",
         ",\n".join(f"  .{name}({name})" for name in ports),
         ");"])

for index, bo in enumerate(bo_names):
    adapter = top.parent / f"{module}_{bo}_m_axi.v"
    adapter_source = adapter.read_text()
    base = f"dut.{bo}_m_axi_U"
    probes = []
    if "load_unit_0 (" in adapter_source:
        read_names = ("load_unit_0.rreq_valid",
                      "load_unit_0.local_AXI_RVALID",
                      "load_unit_0.out_HLS_RVALID",
                      "bus_read.ost_ctrl_empty_n",
                      "bus_read.ost_burst_empty_n",
                      "bus_read.beat_valid")
        for name in read_names:
            assert name.rsplit(".", 1)[1] in adapter_source
        probes.extend(read_names)
    if "store_unit_0 (" in adapter_source:
        write_names = ("store_unit_0.wreq_valid",
                       "store_unit_0.wrsp_valid",
                       "store_unit_0.out_AXI_WVALID",
                       "bus_write.ost_resp_valid",
                       "bus_write.resp_valid",
                       "bus_write.out_BUS_AWVALID",
                       "bus_write.out_BUS_WVALID")
        for name in write_names:
            assert name.rsplit(".", 1)[1] in adapter_source
        probes.extend(write_names)
        if bo != "observed":
            probes.append("store_unit_0.out_HLS_BVALID")
    assert probes
    zero = " && ".join(f"({base}.{name} === '0)" for name in probes)
    if bo == "observed":
        # The generated write_observation raises ap_done on the final HLS B
        # valid cycle.  That response must handshake at this very edge, and
        # must be the only remaining adapter response; all other queues must
        # already be empty.  The first-done check is not delayed.
        assert "user_resp (" in adapter_source
        zero += (" && (dut.observed_0_BVALID === 1'b1)"
                 " && (dut.observed_0_BREADY === 1'b1)"
                 " && (dut.observed_m_axi_U.store_unit_0."
                 "user_resp.if_num_data_valid === 1)")
    lines.append(f"assign adapter_zero[{index}] = {zero};")
memory_outputs = {"AWREADY", "WREADY", "ARREADY", "RVALID", "RDATA",
                  "RLAST", "RID", "RRESP", "BVALID", "BRESP", "BID"}
for index, bo in enumerate(bo_names):
    lines.append(f"thin_axi_memory #(.PORT_INDEX({index})) mem_{bo}(")
    lines.append("  .clk(ap_clk), .rst_n(ap_rst_n),")
    connections = []
    for channel in channels:
        signal = f"m_axi_{bo}_{channel}"
        connection = signal if signal in by_name else (
            "" if channel in memory_outputs else "'0")
        connections.append(f"  .{channel}({connection})")
    lines.append(",\n".join(
        connections +
        [f"  .debt_zero(debt_zero[{index}])",
         f"  .r_hold_hit(r_hold_hit[{index}])",
         f"  .b_hold_hit(b_hold_hit[{index}])"]))
    lines.append(");")
    for channel in ("RUSER", "BUSER"):
        if f"m_axi_{bo}_{channel}" in by_name:
            lines.append(f"assign m_axi_{bo}_{channel} = '0;")
lines.append("endmodule")

lines.append(r'''module thin_axi_memory #(parameter integer PORT_INDEX = 0)(
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
  output logic BID, output logic debt_zero,
  output logic r_hold_hit, output logic b_hold_hit
);
import "DPI-C" function int thin_mem_read(input int port,
                                           input longint unsigned address);
import "DPI-C" function void thin_mem_read_accept(input int port,
                                                  input longint unsigned address);
import "DPI-C" function void thin_mem_write(input int port,
    input longint unsigned address, input int word, input byte unsigned strobe);
import "DPI-C" function int thin_mem_raw_bytes();
import "DPI-C" function int thin_mem_gamma_read_words();
logic rd_active = 0, wr_active = 0, b_valid = 0;
logic [63:0] rd_address = 0, wr_address = 0;
logic [8:0] rd_remaining = 0, wr_remaining = 0;
logic [2:0] rd_size = 0, wr_size = 0;
logic rd_id = 0, wr_id = 0;
logic last_state1_write = 0;
logic r_hold_done = 0, b_hold_done = 0;
logic [2:0] r_hold_count = 0, b_hold_count = 0;
logic [9:0] r_debt = 0, w_debt = 0;
assign ARREADY = !rd_active;
assign RVALID = rd_active &&
    !(PORT_INDEX == 2 && rd_address == 524284 &&
      thin_mem_gamma_read_words() == 1024 && !r_hold_done) &&
    (r_hold_count == 0);
assign RLAST = rd_active && rd_remaining == 1;
assign RID = rd_id;
assign RRESP = 0;
assign RDATA = rd_active ? thin_mem_read(PORT_INDEX, rd_address) : 0;
assign AWREADY = !wr_active && !b_valid;
assign WREADY = wr_active;
assign BVALID = b_valid &&
    !(PORT_INDEX == 3 && last_state1_write && !b_hold_done) &&
    (b_hold_count == 0);
assign BID = wr_id;
assign BRESP = 0;
assign debt_zero = !rd_active && !wr_active && !b_valid &&
    r_debt == 0 && w_debt == 0;
always @(posedge clk) begin
  if (!rst_n) begin
    rd_active <= 0; wr_active <= 0; b_valid <= 0;
    rd_remaining <= 0; wr_remaining <= 0;
    r_debt <= 0; w_debt <= 0;
    r_hold_done <= 0; b_hold_done <= 0;
    r_hold_count <= 0; b_hold_count <= 0;
    r_hold_hit <= 0; b_hold_hit <= 0;
    last_state1_write <= 0;
  end else begin
    if (ARVALID && ARREADY) begin
      if (ARSIZE > 2 || (ARADDR & ((64'b1 << ARSIZE) - 1)) != 0 ||
          (ARBURST != 2'b01 && ARLEN != 0))
        $fatal(1, "AXI read address/size/burst invalid");
      if (PORT_INDEX == 2 && thin_mem_gamma_read_words() == 1024 &&
          thin_mem_raw_bytes() != 524288)
        $fatal(1, "LN AR before complete import scan");
      rd_active <= 1;
      rd_address <= ARADDR;
      rd_remaining <= {1'b0, ARLEN} + 1;
      rd_size <= ARSIZE;
      rd_id <= ARID;
      r_debt <= r_debt + {2'b0, ARLEN} + 1;
    end
    if (PORT_INDEX == 2 && rd_active && rd_address == 524284 &&
        thin_mem_gamma_read_words() == 1024 && !r_hold_done) begin
      r_hold_done <= 1;
      r_hold_hit <= 1;
      r_hold_count <= 4;
    end else if (r_hold_count != 0) r_hold_count <= r_hold_count - 1;
    if (RVALID && RREADY) begin
      if (PORT_INDEX == 2 && thin_mem_gamma_read_words() == 1024 &&
          thin_mem_raw_bytes() != 524288)
        $fatal(1, "LN R before complete import scan");
      thin_mem_read_accept(PORT_INDEX, rd_address);
      if (r_debt == 0) $fatal(1, "R without AR debt");
      r_debt <= r_debt - 1;
      if (rd_remaining == 1) rd_active <= 0;
      else begin
        rd_address <= rd_address + (64'b1 << rd_size);
        rd_remaining <= rd_remaining - 1;
      end
    end
    if (AWVALID && AWREADY) begin
      if (AWSIZE > 2 || (AWADDR & ((64'b1 << AWSIZE) - 1)) != 0 ||
          (AWBURST != 2'b01 && AWLEN != 0))
        $fatal(1, "AXI write address/size/burst invalid");
      wr_active <= 1;
      wr_address <= AWADDR;
      wr_remaining <= {1'b0, AWLEN} + 1;
      wr_size <= AWSIZE;
      wr_id <= AWID;
      w_debt <= w_debt + {2'b0, AWLEN} + 1;
    end
    if (WVALID && WREADY) begin
      if (w_debt == 0 || WLAST != (wr_remaining == 1))
        $fatal(1, "W debt/LAST mismatch");
      thin_mem_write(PORT_INDEX, wr_address, WDATA, {4'b0, WSTRB});
      w_debt <= w_debt - 1;
      if (PORT_INDEX == 3 && wr_address == 524284)
        last_state1_write <= 1;
      if (wr_remaining == 1) begin wr_active <= 0; b_valid <= 1; end
      else begin
        wr_address <= wr_address + (64'b1 << wr_size);
        wr_remaining <= wr_remaining - 1;
      end
    end
    if (PORT_INDEX == 3 && b_valid && last_state1_write &&
        !b_hold_done) begin
      b_hold_done <= 1;
      b_hold_hit <= 1;
      b_hold_count <= 4;
    end else if (b_hold_count != 0) b_hold_count <= b_hold_count - 1;
    if (BVALID && BREADY) begin
      if (w_debt != 0) $fatal(1, "B before all W responses");
      b_valid <= 0;
      last_state1_write <= 0;
    end
  end
end
endmodule''')
out.write_text("\n".join(lines) + "\n")
print(f"{out} ports={len(ports)} axi_ports={len(bo_names)} bytes={out.stat().st_size}")
