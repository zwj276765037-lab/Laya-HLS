`timescale 1ns/1ps
// Dormant actual-wrapper streaming probe. Uses the unchanged seven generated
// v3 outer wrappers. Internal r_tvalid is diagnostic, not semantic valid.
module fp_streaming_probe;
  logic clk=1'b0, reset=1'b0, ce=1'b1;
  logic [31:0] din0=0, din1=0;
  logic [4:0] opcode=5'd1;
  wire [31:0] out_div,out_mul2,out_mul3,out_add,out_sitofp;
  wire out_cmp1,out_cmp2;
  logic [31:0] vector_a[0:6][0:34],vector_b[0:6][0:34];
  logic [31:0] vector_expected[0:6][0:34];
  logic [4:0] vector_opcode[0:6][0:34];
  int vector_count[0:6];
  longint unsigned clock_index=0;
  int raw_fd;

  q8_joint_tm4tn8_fdiv_32ns_32ns_32_8_no_dsp_1 dut_div
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.din1(din1),.dout(out_div));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_2_max_dsp_1 dut_mul2
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.din1(din1),.dout(out_mul2));
  q8_joint_tm4tn8_fmul_32ns_32ns_32_3_max_dsp_1 dut_mul3
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.din1(din1),.dout(out_mul3));
  q8_joint_tm4tn8_fadd_32ns_32ns_32_4_full_dsp_1 dut_add
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.din1(din1),.dout(out_add));
  q8_joint_tm4tn8_sitofp_32ns_32_2_no_dsp_1 dut_sitofp
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.dout(out_sitofp));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_1_no_dsp_1 dut_cmp1
    (.din0(din0),.din1(din1),.opcode(opcode),.dout(out_cmp1));
  q8_joint_tm4tn8_fcmp_32ns_32ns_1_2_no_dsp_1 dut_cmp2
    (.clk(clk),.reset(reset),.ce(ce),.din0(din0),.din1(din1),
     .opcode(opcode),.dout(out_cmp2));

  always #5ns clk=~clk;
  always @(posedge clk) begin
    clock_index<=clock_index+1;
    if (clock_index>65536) $fatal(1,"C1_FP_STREAM_WATCHDOG");
  end
  function automatic logic [31:0] selected_output(input int w);
    case(w)
      0: return out_div;
      1: return out_mul2;
      2: return out_mul3;
      3: return out_add;
      4: return out_sitofp;
      5: return {31'b0,out_cmp1};
      6: return {31'b0,out_cmp2};
      default: return 32'hxxxxxxxx;
    endcase
  endfunction
  function automatic logic selected_tvalid(input int w);
    case(w)
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
  task automatic probe_run(input int w,input int phase);
    int cursor, chosen, enabled_ordinal;
    bit accept;
    logic [15:0] tag;
    logic [31:0] expected;
    // These are the actual wrapper reset pins, including the combinational
    // comparator's lack of reset. Each run drains 48 clocks before reset.
    @(negedge clk);
    reset=1'b1; ce=1'b1; din0=0; din1=0; opcode=5'd1;
    repeat(4) @(posedge clk);
    @(negedge clk);
    reset=1'b0;
    cursor=0; enabled_ordinal=0;
    for (int step=0;step<vector_count[w]+64;++step) begin
      @(negedge clk);
      ce=(phase!=1 || w==5 || step%4!=2);
      accept=ce && cursor<vector_count[w];
      tag=16'hffff;
      expected=32'hxxxxxxxx;
      if (accept) begin
        chosen=phase==2 ? vector_count[w]-1-cursor : cursor;
        din0=vector_a[w][chosen];
        din1=vector_b[w][chosen];
        opcode=vector_opcode[w][chosen];
        expected=vector_expected[w][chosen];
        tag=(w<<12)|(phase<<8)|cursor;
      end else begin
        // Change inputs even across bubbles; CE, not operand stability,
        // determines acceptance for the registered wrappers.
        din0=32'h3f000000 ^ (32'(step)<<7);
        din1=32'h40000000 ^ 32'(step);
        opcode=5'(1+(step%6));
      end
      @(posedge clk);
      #1ps;
      if (ce) enabled_ordinal++;
      $fdisplay(raw_fd,
        "FP_STREAM|wrapper=%0d|phase=%0d|clock=%0d|enabled=%0d|ce=%0d|accept=%0d|tag=%04x|a=%08x|b=%08x|opcode=%0d|expected=%08x|actual=%08x|r_tvalid=%b",
        w,phase,clock_index,enabled_ordinal,ce,accept,tag,
        din0,din1,opcode,expected,selected_output(w),selected_tvalid(w));
      $fflush(raw_fd);
      if (accept) cursor++;
    end
    if (cursor!=vector_count[w]) $fatal(1,"C1_FP_STREAM_INCOMPLETE");
  endtask
  initial begin
    `include "fp_streaming_vectors.svh"
    raw_fd=$fopen("c1_fp_stream_raw.log","w");
    if (!raw_fd) $fatal(1,"C1_FP_STREAM_RAW_OPEN");
    for (int w=0;w<7;++w)
      for (int phase=0;phase<3;++phase)
        probe_run(w,phase);
    $fdisplay(raw_fd,"FP_STREAM_SOURCE_COMPLETE");
    $fflush(raw_fd);
    $fclose(raw_fd);
    $display("FP_STREAM_SOURCE_COMPLETE");
    $finish;
  end
endmodule
