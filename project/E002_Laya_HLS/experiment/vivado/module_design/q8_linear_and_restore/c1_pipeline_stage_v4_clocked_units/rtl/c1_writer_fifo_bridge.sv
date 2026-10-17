`timescale 1ns/1ps
// Three independent, depth-one command/ACK FIFO pairs. Port 2 arbitrates
// observed auxiliary commands with the Q64/D4 shell's GROUP_TRACE source.
// hls_* is a logical valid/ready interface; generated ap_fifo pin binding
// remains pending an actual HLS interface manifest.
module c1_writer_fifo_bridge (
  input  logic clk, rst_n,
  input  logic [2:0] source_command_valid,
  output logic [2:0] source_command_ready,
  input  logic [2:0][617:0] source_command,
  output logic [2:0][31:0] source_command_seq,
  output logic [2:0] source_ack_valid,
  input  logic [2:0] source_ack_ready,
  output logic [2:0][36:0] source_ack,
  input  logic trace_send_valid,
  output logic trace_send_ready,
  input  logic [1:0] trace_send_slot,
  input  logic [16:0] trace_send_seq,
  input  logic [255:0] trace_send_payload,
  input  logic [63:0] trace_word_offset,
  output logic [31:0] trace_command_seq,
  output logic trace_ack_valid,
  output logic [2:0] trace_ack_kind,
  output logic [1:0] trace_ack_slot,
  output logic [31:0] trace_ack_seq,
  output logic [2:0] hls_command_valid,
  input  logic [2:0] hls_command_ready,
  output logic [2:0][617:0] hls_command,
  input  logic [2:0] hls_ack_valid,
  output logic [2:0] hls_ack_ready,
  input  logic [2:0][36:0] hls_ack,
  output logic [2:0] debt_active,
  output logic report_acked,
  output logic all_done,
  output logic protocol_error
);
  localparam logic [2:0] QUANT_Q=3'd0, QUANT_SCALE=3'd1,
                         GROUP_TRACE=3'd2, FINAL_OUTPUT=3'd3,
                         REPORT=3'd4, EOS=3'd7;
  logic [617:0] command_fifo [0:2];
  logic [36:0] ack_fifo [0:2];
  logic [2:0] command_full, ack_full, debt, stopped, eos_acked;
  logic [36:0] expected_ack [0:2];
  logic [31:0] next_sequence [0:2];
  logic [2:0] source_fire, command_pop, ack_input_fire, ack_output_pop;
  logic trace_fire, all_drained, protocol_violation;

  function automatic logic valid_source(input logic [617:0] word,
                                         input logic observed_port);
    logic [4:0] count;
    logic [2:0] kind;
    logic [1:0] slot;
    count=word[68:64]; kind=word[71:69]; slot=word[73:72];
    if (kind==EOS) return count==0 && slot==0;
    if (count==0 || count>5'd16) return 1'b0;
    if (!observed_port)
      return kind==FINAL_OUTPUT && slot==0 && count==5'd1;
    return slot==0 && (kind==QUANT_Q || kind==QUANT_SCALE || kind==REPORT);
  endfunction

  function automatic logic [617:0] with_sequence(input logic [617:0] word,
                                                   input logic [31:0] seq);
    logic [617:0] packed;
    packed=word;
    packed[105:74]=seq;
    return packed;
  endfunction

  always_comb begin
    all_drained=1'b1;
    for (int p=0;p<3;p++)
      if (debt[p] || command_full[p] || ack_full[p]) all_drained=1'b0;
    for (int p=0;p<3;p++) begin
      source_command_seq[p]=next_sequence[p];
      source_command_ready[p]=rst_n && !protocol_error && !stopped[p] &&
          !debt[p] && !command_full[p] && !ack_full[p] &&
          next_sequence[p]!=32'hffff_ffff;
      if (source_command_valid[p]) begin
        source_command_ready[p]=source_command_ready[p] &&
            valid_source(source_command[p],p==2);
        if (source_command[p][71:69]==EOS)
          source_command_ready[p]=source_command_ready[p] &&
              report_acked && all_drained;
        else
          source_command_ready[p]=source_command_ready[p] && !report_acked;
        if (p==2) begin
          source_command_ready[p]=source_command_ready[p] && !trace_send_valid;
          if (source_command[p][71:69]==REPORT)
            source_command_ready[p]=source_command_ready[p] && all_drained &&
                !source_command_valid[0] && !source_command_valid[1];
        end
      end
      source_fire[p]=source_command_valid[p] && source_command_ready[p];
      hls_command_valid[p]=command_full[p] && !protocol_error;
      hls_command[p]=command_fifo[p];
      command_pop[p]=hls_command_valid[p] && hls_command_ready[p];
      hls_ack_ready[p]=!ack_full[p] && !protocol_error;
      ack_input_fire[p]=hls_ack_valid[p] && hls_ack_ready[p];
      source_ack_valid[p]=ack_full[p] && !protocol_error &&
          (p!=2 || expected_ack[p][2:0]!=GROUP_TRACE);
      source_ack[p]=ack_fifo[p];
      ack_output_pop[p]=source_ack_valid[p] && source_ack_ready[p];
    end
    trace_send_ready=rst_n && !protocol_error && !stopped[2] &&
        !report_acked && !debt[2] && !command_full[2] && !ack_full[2] &&
        next_sequence[2]!=32'hffff_ffff;
    trace_fire=trace_send_valid && trace_send_ready;
    trace_command_seq=next_sequence[2];
    trace_ack_valid=ack_full[2] && !protocol_error &&
        expected_ack[2][2:0]==GROUP_TRACE;
    trace_ack_kind=ack_fifo[2][2:0];
    trace_ack_slot=ack_fifo[2][4:3];
    trace_ack_seq=ack_fifo[2][36:5];
    if (trace_ack_valid) ack_output_pop[2]=1'b1;
    debt_active=debt;
    all_done=&eos_acked;

    protocol_violation=1'b0;
    for (int p=0;p<3;p++) begin
      if (source_command_valid[p] &&
          (!valid_source(source_command[p],p==2) || stopped[p] ||
           (report_acked && source_command[p][71:69]!=EOS) ||
           (source_command[p][71:69]==EOS && !report_acked)))
        protocol_violation=1'b1;
      if (ack_input_fire[p] &&
          (!debt[p] || (command_full[p] && !command_pop[p]) ||
           hls_ack[p]!==expected_ack[p]))
        protocol_violation=1'b1;
    end
    if (trace_send_valid &&
        (report_acked || stopped[2] || trace_word_offset>64'hffff_ffff_ffff_fff7))
      protocol_violation=1'b1;
  end

  // A command claims its port's single debt at the source edge. The debt is
  // released only when its matching post-response ACK leaves the ACK FIFO.
  // Same-edge ACK retirement never creates source credit.
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      command_full<=3'b0;
      ack_full<=3'b0;
      debt<=3'b0;
      stopped<=3'b0;
      eos_acked<=3'b0;
      report_acked<=1'b0;
      protocol_error<=1'b0;
      for (int p=0;p<3;p++) next_sequence[p]<=32'b0;
    end else begin
      if (protocol_violation) protocol_error<=1'b1;
`ifndef SYNTHESIS
      if (protocol_violation) $fatal(1,"C1_WRITER_BRIDGE_PROTOCOL_ERROR");
      if (trace_fire && $isunknown({trace_send_seq,trace_send_payload}))
        $fatal(1,"C1_WRITER_TRACE_UNKNOWN");
`endif
      for (int p=0;p<3;p++) begin
        if (source_fire[p]) begin
          command_fifo[p]<=with_sequence(source_command[p],next_sequence[p]);
          command_full[p]<=1'b1;
          debt[p]<=1'b1;
          expected_ack[p]<={next_sequence[p],source_command[p][73:69]};
          next_sequence[p]<=next_sequence[p]+32'd1;
          if (source_command[p][71:69]==EOS) stopped[p]<=1'b1;
        end else if (p==2 && trace_fire) begin
          command_fifo[p]<={256'b0,trace_send_payload,next_sequence[p],
                            trace_send_slot,GROUP_TRACE,5'd8,trace_word_offset};
          command_full[p]<=1'b1;
          debt[p]<=1'b1;
          expected_ack[p]<={next_sequence[p],trace_send_slot,GROUP_TRACE};
          next_sequence[p]<=next_sequence[p]+32'd1;
        end
        if (command_pop[p]) command_full[p]<=1'b0;
        if (ack_input_fire[p] && !protocol_violation) begin
          ack_fifo[p]<=hls_ack[p];
          ack_full[p]<=1'b1;
        end
        if (ack_output_pop[p]) begin
          ack_full[p]<=1'b0;
          debt[p]<=1'b0;
          if (expected_ack[p][2:0]==EOS) eos_acked[p]<=1'b1;
          if (p==2 && expected_ack[p][2:0]==REPORT) report_acked<=1'b1;
        end
      end
    end
  end
endmodule
