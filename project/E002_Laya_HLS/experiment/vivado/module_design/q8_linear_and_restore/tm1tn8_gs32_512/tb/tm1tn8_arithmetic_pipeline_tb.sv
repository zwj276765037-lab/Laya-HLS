`timescale 1ns/1ps
module tm1tn8_arithmetic_pipeline_tb;
  logic clk=0;
  always #5 clk=~clk;
  logic rst_n, issue_valid, issue_ready, issue_trace;
  logic [159:0] issue_identity_tag, commit_tag, trace_tag, trace_ack_tag;
  logic [8:0] issue_tile, commit_tile;
  logic [7:0] issue_lane_mask, commit_lane_mask, commit_bad_mask;
  logic [2:0] issue_trace_lane;
  logic [5:0] issue_group;
  logic [1:0] issue_row;
  logic [255:0] issue_a8, issue_old_ps, issue_sw;
  logic [2047:0] issue_w8;
  logic [31:0] issue_sa;
  logic commit_valid, commit_ready, trace_valid, trace_ready;
  logic [23:0] commit_phase;
  logic [255:0] commit_next_ps, trace_payload;
  logic [1:0] trace_slot, trace_ack_slot;
  logic trace_ack_valid, trace_ack_ok;
  logic [5:0] result_free, result_reserved, result_returned;
  logic [2:0] trace_free;
  logic protocol_error;
  int commit_seen;
  tm1tn8_arithmetic_pipeline dut (.*);

  always @(negedge clk) if (rst_n && $time < 500 &&
      (dut.fp_restore.valid_a || dut.fp_restore.valid_c ||
       dut.fp_restore.valid_add || dut.fp_restore.pop))
    $display("FP_DIAG t=%0t a=%b p1=%b c=%b p2=%b addv=%b cv=%b sv=%b tv=%b dot=%h dotf=%h dotfc=%h scale=%h scalec=%h term=%h sa=%h sw=%h fifo=%0d head=%0d meta=%h pop=%b add=%h",
             $time,dut.fp_restore.valid_a,dut.fp_restore.valid_1,
             dut.fp_restore.valid_c,dut.fp_restore.valid_2,
             dut.fp_restore.valid_add,dut.fp_restore.convert_valid[0],
             dut.fp_restore.scale_valid[0],dut.fp_restore.term_valid[0],
             dut.fp_restore.dot_a[31:0],
             dut.fp_restore.dot_float_wire[31:0],
             dut.fp_restore.dot_float_c[31:0],
             dut.fp_restore.scale_product_wire[31:0],
             dut.fp_restore.scale_product_c[31:0],
             dut.fp_restore.term_wire[31:0],dut.fp_restore.sa_a,
             dut.fp_restore.sw_a[31:0],
             dut.fp_restore.fifo_count,dut.fp_restore.head_slot,
             dut.fp_restore.meta_phase[dut.fp_restore.head_slot],
             dut.fp_restore.pop,dut.fp_restore.add_wire[31:0]);

  function automatic int signed a_value(input int k);
    case (k%4)
      0: return -128;
      1: return -127;
      2: return 0;
      default: return 127;
    endcase
  endfunction
  function automatic int signed w_value(input int lane, k);
    case ((k+lane)%4)
      0: return 127;
      1: return -128;
      2: return -127;
      default: return 0;
    endcase
  endfunction
  function automatic logic [31:0] exact_f32(input int signed value);
    int unsigned magnitude, msb, fraction;
    logic sign;
    begin
      if (value == 0) return 0;
      sign = value < 0;
      magnitude = sign ? -value : value;
      msb=0;
      while ((magnitude >> (msb+1)) != 0) msb++;
      if (msb > 23) $fatal(1,"test exact-f32 range");
      fraction = (magnitude << (23-msb)) & 32'h7fffff;
      return {sign,8'(msb+127),fraction[22:0]};
    end
  endfunction
  function automatic int signed expected_dot(input int lane);
    int signed sum;
    begin
      sum=0;
      for (int k=0;k<32;k++)
        sum += a_value(k)*w_value(lane,k);
      return sum;
    end
  endfunction

  always @(posedge clk) begin
    if (rst_n && commit_valid && commit_ready) begin
      if (commit_tag[25:17] !== 9'(commit_seen) ||
          commit_tile !== 9'(commit_seen) ||
          commit_lane_mask !== 8'hff || commit_bad_mask !== 0 ||
          commit_phase !== {8{3'd4}})
        $fatal(1,"commit tag/mask/phase index=%0d tag=%h tile=%0d mask=%h bad=%h phase=%h protocol=%b",
               commit_seen,commit_tag,commit_tile,commit_lane_mask,
               commit_bad_mask,commit_phase,protocol_error);
      for (int lane=0;lane<8;lane++)
        if (commit_next_ps[lane*32 +: 32] !== exact_f32(expected_dot(lane)))
          $fatal(1,"FP lane mismatch issue=%0d lane=%0d got=%h exp=%h",
                 commit_seen,lane,commit_next_ps[lane*32 +: 32],
                 exact_f32(expected_dot(lane)));
      commit_seen++;
    end
  end

  initial begin : test
    int timeout;
    logic [1:0] saved_slot;
    rst_n=0; issue_valid=0; issue_identity_tag=0; issue_tile=0;
    issue_lane_mask=8'hff; issue_trace=0; issue_trace_lane=0;
    issue_group=0; issue_row=0; issue_a8=0; issue_w8=0;
    issue_old_ps=0; issue_sa=32'h3f800000;
    issue_sw={8{32'h3f800000}};
    commit_ready=1; trace_ready=0; trace_ack_valid=0;
    trace_ack_slot=0; trace_ack_tag=0; trace_ack_ok=1; commit_seen=0;
    for (int k=0;k<32;k++) begin
      issue_a8[k*8 +: 8] = 8'(a_value(k));
      for (int lane=0;lane<8;lane++)
        issue_w8[lane*256 + k*8 +: 8] = 8'(w_value(lane,k));
    end
    repeat (16) @(negedge clk);
    rst_n=1;
    for (int i=0;i<16;i++) begin
      @(negedge clk);
      issue_valid=1; issue_tile=9'(i);
      issue_group=6'(i%32); issue_trace=i<4;
      issue_identity_tag=160'(32'hcafe0000+i);
      #1ps;
      if (!issue_ready) $fatal(1,"II1 issue stall at %0d",i);
    end
    @(negedge clk); issue_valid=0;
    timeout=0;
    while (commit_seen<16) begin
      @(negedge clk);
      timeout++;
      if (timeout>100) $fatal(1,"FP pipeline drain timeout");
    end
    for (int i=0;i<4;i++) begin
      timeout=0;
      while (!trace_valid) begin
        @(negedge clk);
        timeout++;
        if (timeout>25) $fatal(1,"trace timeout");
      end
      if (trace_slot !== 2'(i) ||
          trace_payload[31:0] !== 32'(expected_dot(0)) ||
          trace_payload[63:32] !== 32'h3f800000 ||
          trace_payload[95:64] !== 32'h3f800000 ||
          trace_payload[127:96] !== 32'h3f800000 ||
          trace_payload[159:128] !== exact_f32(expected_dot(0)) ||
          trace_payload[191:160] !== exact_f32(expected_dot(0)) ||
          trace_payload[223:192] !== 32'(i) ||
          trace_payload[255:224] !== 1)
        $fatal(1,"FP trace mismatch index=%0d",i);
      saved_slot=trace_slot;
      @(negedge clk); trace_ready=1;
      @(negedge clk); trace_ready=0;
      trace_ack_valid=1; trace_ack_slot=saved_slot;
      trace_ack_tag=trace_tag;
      @(negedge clk); trace_ack_valid=0;
    end
    repeat (3) @(negedge clk);
    if (result_free!==32 || result_reserved!==0 ||
        result_returned!==0 || trace_free!==4 || protocol_error)
      $fatal(1,"FP terminal debt/protocol");
    $display("TM1TN8_ARITHMETIC_PIPELINE_PASS issues=16 lanes=128");
    $finish;
  end
endmodule
