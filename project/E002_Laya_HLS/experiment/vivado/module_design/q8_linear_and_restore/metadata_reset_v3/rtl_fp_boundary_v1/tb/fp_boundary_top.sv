`timescale 1ns/1ps
module fp_boundary_top;
  localparam int PLANNED_CASES = 119;
  logic clk = 1'b0;
  logic reset = 1'b0;
  logic ce = 1'b1;
  logic [31:0] din0 = 32'h0, din1 = 32'h0;
  logic [4:0] opcode = 5'd1;
  wire [31:0] out_div, out_mul2, out_mul3, out_add, out_sitofp;
  wire out_cmp1, out_cmp2;
  longint unsigned cycle_count = 0;
  int raw_fd;
  int case_count = 0;
  int mismatch_count = 0;
  string first_failure = "";

  // The seven accepted generated outer wrappers are instantiated directly.
  q8_joint_tm4tn8_fdiv_32ns_32ns_32_8_no_dsp_1 dut_div
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_div));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_2_max_dsp_1 dut_mul2
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_mul2));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_3_max_dsp_1 dut_mul3
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_mul3));
  q8_joint_tm4tn8_fadd_32ns_32ns_32_4_full_dsp_1 dut_add
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1), .dout(out_add));
  q8_joint_tm4tn8_sitofp_32ns_32_2_no_dsp_1 dut_sitofp
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .dout(out_sitofp));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_1_no_dsp_1 dut_cmp1
    (.din0(din0), .din1(din1), .opcode(opcode), .dout(out_cmp1));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_2_no_dsp_1 dut_cmp2
    (.clk(clk), .reset(reset), .ce(ce), .din0(din0), .din1(din1),
     .opcode(opcode), .dout(out_cmp2));

  always #5ns clk = ~clk;
  always @(posedge clk) begin
    cycle_count <= cycle_count + 1;
    if (cycle_count >= 65536) $fatal(1, "FP_BOUNDARY_WATCHDOG");
  end

  function automatic logic [31:0] selected_output(input int wrapper_id);
    case (wrapper_id)
      0: return out_div;
      1: return out_mul2;
      2: return out_mul3;
      3: return out_add;
      4: return out_sitofp;
      5: return {31'b0, out_cmp1};
      6: return {31'b0, out_cmp2};
      default: return 32'hxxxxxxxx;
    endcase
  endfunction

  function automatic logic selected_valid(input int wrapper_id);
    case (wrapper_id)
      0: return dut_div.r_tvalid;
      1: return dut_mul2.r_tvalid;
      2: return dut_mul3.r_tvalid;
      3: return dut_add.r_tvalid;
      4: return dut_sitofp.r_tvalid;
      5: return dut_cmp1.r_tvalid;
      6: return dut_cmp2.r_tvalid;
      default: return 1'bx;
    endcase
  endfunction

  function automatic string wrapper_name(input int wrapper_id);
    case (wrapper_id)
      0: return "fdiv";
      1: return "fmul2";
      2: return "fmul3";
      3: return "fadd";
      4: return "sitofp";
      5: return "fcmp1";
      6: return "fcmp2";
      default: return "invalid";
    endcase
  endfunction

  task automatic run_case(input int wrapper_id, input string case_id,
                          input logic [31:0] a_bits, b_bits, expected_bits,
                          input logic [4:0] op);
    logic [31:0] sample_value [0:2];
    logic sample_valid [0:2];
    longint unsigned sample_cycle [0:2];
    bit mismatch;
    @(negedge clk);
    din0 = a_bits;
    din1 = b_bits;
    opcode = op;
    repeat (32) @(posedge clk);
    for (int i = 0; i < 3; i++) begin
      @(posedge clk);
      #1ps;
      sample_value[i] = selected_output(wrapper_id);
      sample_valid[i] = selected_valid(wrapper_id);
      sample_cycle[i] = cycle_count;
    end
    // Raw record is flushed before any conformance assertion or fatal.
    $fdisplay(raw_fd,
      "FP_RAW|wrapper=%s|case=%s|opcode=%0d|a=%08x|b=%08x|expected=%08x|actual0=%08x|actual1=%08x|actual2=%08x|valid0=%b|valid1=%b|valid2=%b|cycle0=%0d|cycle1=%0d|cycle2=%0d",
      wrapper_name(wrapper_id), case_id, op, a_bits, b_bits, expected_bits,
      sample_value[0], sample_value[1], sample_value[2],
      sample_valid[0], sample_valid[1], sample_valid[2],
      sample_cycle[0], sample_cycle[1], sample_cycle[2]);
    $fflush(raw_fd);
    case_count++;
    mismatch = $isunknown(sample_value[0]) || $isunknown(sample_value[1]) ||
               $isunknown(sample_value[2]) ||
               sample_value[0] !== sample_value[1] ||
               sample_value[1] !== sample_value[2] ||
               sample_value[2] !== expected_bits;
    if (mismatch) begin
      mismatch_count++;
      if (first_failure == "") first_failure = $sformatf("%s/%s", wrapper_name(wrapper_id), case_id);
    end
  endtask

  initial begin
    raw_fd = $fopen("fp_raw.log", "w");
    if (raw_fd == 0) $fatal(1, "FP_BOUNDARY_RAW_OPEN");
    repeat (32) @(posedge clk);
`include "frozen_cases.svh"
    $fdisplay(raw_fd, "FP_CHARACTERIZATION_COMPLETE|planned=%0d|observed=%0d|mismatches=%0d|first=%s",
              PLANNED_CASES, case_count, mismatch_count, first_failure);
    $fflush(raw_fd);
    $display("FP_CHARACTERIZATION_COMPLETE planned=%0d observed=%0d mismatches=%0d first=%s",
             PLANNED_CASES, case_count, mismatch_count, first_failure);
    $fclose(raw_fd);
    if (case_count != PLANNED_CASES) $fatal(1, "FP_BOUNDARY_CASE_COUNT");
    if (mismatch_count != 0) $fatal(1, "FP_CONFORMANCE_FAIL mismatches=%0d first=%s", mismatch_count, first_failure);
    $display("FP_CONFORMANCE_PASS cases=%0d wrappers=7", case_count);
    $finish;
  end
endmodule
