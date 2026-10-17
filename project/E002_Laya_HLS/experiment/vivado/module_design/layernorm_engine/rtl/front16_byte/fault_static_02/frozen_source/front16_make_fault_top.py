#!/usr/bin/env python3
"""Build a short fault/reset top around the unchanged generated HLS RTL."""
from pathlib import Path
import subprocess
import sys
import tempfile

if len(sys.argv) != 3:
    raise SystemExit('usage: front16_make_fault_top.py GENERATED_TOP_VERILOG OUTPUT_SV')
source = Path(sys.argv[1]).resolve()
target = Path(sys.argv[2]).resolve()
module = source.stem
assert module in ('laya_front16_byte', 'laya_front16_wide')

with tempfile.TemporaryDirectory() as tmp:
    base = Path(tmp) / 'front16_top.sv'
    subprocess.run([sys.executable, str(Path(__file__).with_name('front16_make_top.py')),
                    str(source), str(base)], check=True)
    top = base.read_text()

original = 'import "DPI-C" function int front16_mem_check();'
assert top.count(original) == 1
top = top.replace(original, original + '\n'
                  'import "DPI-C" function int front16_fault_rearm();\n'
                  'import "DPI-C" function int front16_fault_check();')
original = 'integer cycles=0;'
assert top.count(original) == 1
top = top.replace(original, original + '\nlogic reset_case=0, reset_reissued=0;')

begin = top.index('initial begin\n  pressure=')
end = top.index('assign s_axi_control_AWVALID=', begin)
top = top[:begin] + '''initial begin
  pressure=0;
  reset_case=$test$plusargs("RESET");
  ap_rst_n=0;
  if (!front16_mem_init()) $fatal(1,"front16 fault memory setup");
  repeat (20) @(negedge ap_clk);
  ap_rst_n=1;
  repeat (5) @(negedge ap_clk);
  launch=1;
  if (reset_case) begin
    wait (front16_mem_import_bytes()>=64 && !debt_zero[0]);
    @(negedge ap_clk);
    if (ap_done || command_start_cycle<0)
      $fatal(1,"front16 reset was not inside first active command");
    $display("FRONT16_FAULT_RESET first_active=1 raw_physical=%0d debt=%b",
      front16_mem_import_bytes(),debt_zero);
    launch=0;
    ap_rst_n=0;
    if (!front16_fault_rearm()) $fatal(1,"front16 fault rearm");
    repeat (20) @(negedge ap_clk);
    ap_rst_n=1;
    repeat (5) @(negedge ap_clk);
    launch=1;
    reset_reissued=1;
  end
end
''' + top[end:]

begin = top.index('always @(posedge ap_clk) if (ap_rst_n) begin\n  if (s_axi_control_AWVALID')
end_marker = '  if (cycles>=40000000) $fatal(1,"front16 40M cycle cap");\nend\n'
end = top.index(end_marker, begin) + len(end_marker)
top = top[:begin] + '''always @(posedge ap_clk) begin
  if (!ap_rst_n) begin
    aw_sent<=0; w_sent<=0; command_start_cycle<=-1;
    arith_start_edges<=0; arith_done_edges<=0;
    arith_start_prev<=0; arith_done_prev<=0;
  end else begin
    if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent<=1;
    if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent<=1;
    cycles<=cycles+1;
    if (dut.ap_start && dut.ap_CS_fsm_state1 && command_start_cycle<0)
      command_start_cycle<=cycles;
    if (arith_start && !arith_start_prev) arith_start_edges<=arith_start_edges+1;
    if (arith_done && !arith_done_prev) arith_done_edges<=arith_done_edges+1;
    arith_start_prev<=arith_start;
    arith_done_prev<=arith_done;
    if (cycles!=0 && cycles%8192==0)
      $display("FRONT16_FAULT_PROGRESS cycles=%0d raw_R=%0d gamma_R=%0d observed_W=%0d",
        cycles,front16_mem_import_bytes(),front16_mem_gamma_bytes(),front16_mem_obs_bytes());
    if (front16_mem_errors()) $fatal(1,"front16 fault memory error");
    if (ap_done) begin
      if (command_start_cycle<0 || (reset_case && !reset_reissued))
        $fatal(1,"front16 stale or unlaunched done");
      if (!front16_fault_check()) $fatal(1,"front16 fault observed/coverage");
      $display("FRONT16_FAULT_ARITH starts=%0d dones=%0d raw_R=%0d gamma_R=%0d",
        arith_start_edges,arith_done_edges,front16_mem_import_bytes(),front16_mem_gamma_bytes());
      if (arith_start_edges!=0 || arith_done_edges!=0 || arith_start)
        $fatal(1,"front16 arithmetic started after bad input");
      if (debt_zero!==4'b1111)
        $fatal(1,"front16 physical debt at first done %b",debt_zero);
      #2ps;
      for (int p=0;p<4;p++) begin
        if (p<2) begin
          if (user_ar_elements[p]-user_r_elements[p]!=0 || user_rfifonum[p]!=0 ||
              user_ar_valid[p] || user_r_valid[p] || external_ar_valid[p])
            $fatal(1,"front16 fault adapter read debt port=%0d",p);
        end else begin
          if (user_aw_requests[p]-user_b_responses[p]!=0 ||
              user_aw_elements[p]-user_w_elements[p]!=0 ||
              user_aw_valid[p] || user_w_valid[p] || user_b_valid[p] ||
              external_aw_valid[p] || external_w_valid[p])
            $fatal(1,"front16 fault adapter write debt port=%0d",p);
        end
      end
      $display("FRONT16_FAULT_RTL_PASS mode=%s reset=%0d command_cycles=%0d",
        "''' + module.removeprefix('laya_front16_') + '''",reset_case,cycles-command_start_cycle);
      $finish;
    end
    if (cycles>=40000000) $fatal(1,"front16 40M cycle cap");
  end
end
''' + top[end:]

target.write_text(top)
print(f'FRONT16_FAULT_TOP_GENERATED mode={module} output={target}')
