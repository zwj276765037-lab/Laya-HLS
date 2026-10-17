`timescale 1ns/1ps
// Fixed single-inflight LHC1 transport. The accepted 8192-bit stream comes
// exclusively from the executor's complete codec/key consumer. Its actual
// write handshake is the shell acknowledgement, so early/foreign/replayed
// accepted attempts are blocked. Rejection is a separate consuming stream
// and never acknowledges a shell response or releases K.
module laya_executor_control_transport_v1 (
  input logic clk,rst_n,cancel,
  input logic [511:0] control_request_din,
  input logic control_request_write,
  output logic control_request_full_n,
  output logic [511:0] control_request_receipt_dout,
  output logic control_request_receipt_empty_n,
  input logic control_request_receipt_read,
  output logic [511:0] control_response_dout,
  output logic control_response_empty_n,
  input logic control_response_read,
  input logic [8191:0] control_response_receipt_din,
  input logic control_response_receipt_write,
  output logic control_response_receipt_full_n,
  input logic [8191:0] control_response_rejection_din,
  input logic control_response_rejection_write,
  output logic control_response_rejection_full_n,
  output logic shell_control_valid,
  input logic shell_control_ready,
  output logic [8191:0] shell_control,
  input logic shell_response_valid,
  output logic shell_response_ready,
  input logic [8191:0] shell_response,
  // Only the matching actual accepted CLOSED receipt accompanies the shell
  // response pop. Other response kinds never create a CLOSED-consumer fact.
  output logic shell_closed_consumer_valid,
  output logic [8191:0] shell_closed_consumer_record,
  output logic protocol_error,cancel_seen,
  output logic [31:0] control_request_writes,control_request_reads,
  output logic [31:0] shell_control_consumed,
  output logic [31:0] request_receipt_writes,request_receipt_reads,
  output logic [31:0] response_writes,response_reads,
  output logic [31:0] accepted_response_receipts,rejected_response_receipts,
  output logic [31:0] invalid_accepted_receipts,shell_response_pops,
  output logic [1:0] request_occupancy,request_receipt_occupancy,response_occupancy,
  output logic [2:0] request_phase,
  output logic response_active,
  output logic [4:0] response_send_beats,response_read_beats
);
  import laya_executor_handoff_layout_v1::*;
  typedef enum logic [2:0] {COLLECT,ISSUE,ECHO,WAIT_ECHO_DRAIN} request_state_t;
  request_state_t request_state;
  logic [4:0] request_ingress_beats,request_collect_beats;
  logic [4:0] request_echo_beats,request_echo_reads;
  logic [8191:0] request_record,response_record;
  logic request_fifo_ready,request_fifo_valid,request_fifo_pop;
  logic [511:0] request_fifo_data;
  logic echo_fifo_ready,echo_fifo_valid,echo_fifo_push,echo_fifo_pop;
  logic [511:0] echo_fifo_data;
  logic response_fifo_ready,response_fifo_valid,response_fifo_push,response_fifo_pop;
  logic [511:0] response_fifo_data;
  logic accepted_receipt_fire,rejection_fire,accepted_response_match;
  logic response_mutated;

  assign request_phase=request_state;
  // Cancellation only closes authority in the unique shell/executor. Old
  // partial control and cleanup ABORT/CLOSE packets continue through here.
  assign control_request_full_n=request_state==COLLECT &&
      request_ingress_beats<16 && request_fifo_ready;
  assign request_fifo_pop=request_state==COLLECT && request_collect_beats<16;
  laya_private_fifo2_v1 request_fifo(.clk,.rst_n,
      .in_valid(control_request_write && control_request_full_n),
      .in_ready(request_fifo_ready),.in_data(control_request_din),
      .out_valid(request_fifo_valid),.out_ready(request_fifo_pop),
      .out_data(request_fifo_data),.occupancy(request_occupancy));
  assign shell_control_valid=rst_n && request_state==ISSUE;
  assign shell_control=request_record;
  // An echo starts only after the shell's real whole-record consumer edge.
  assign echo_fifo_push=request_state==ECHO && request_echo_beats<16;
  assign echo_fifo_data=request_record[request_echo_beats[3:0]*512+:512];
  assign control_request_receipt_empty_n=echo_fifo_valid;
  assign echo_fifo_pop=echo_fifo_valid && control_request_receipt_read;
  laya_private_fifo2_v1 request_receipt_fifo(.clk,.rst_n,
      .in_valid(echo_fifo_push),.in_ready(echo_fifo_ready),.in_data(echo_fifo_data),
      .out_valid(echo_fifo_valid),.out_ready(control_request_receipt_read),
      .out_data(control_request_receipt_dout),.occupancy(request_receipt_occupancy));

  assign response_fifo_push=response_active && response_send_beats<16;
  assign response_fifo_data=response_record[response_send_beats[3:0]*512+:512];
  assign control_response_empty_n=response_fifo_valid;
  assign response_fifo_pop=response_fifo_valid && control_response_read;
  laya_private_fifo2_v1 response_fifo(.clk,.rst_n,
      .in_valid(response_fifo_push),.in_ready(response_fifo_ready),.in_data(response_fifo_data),
      .out_valid(response_fifo_valid),.out_ready(control_response_read),
      .out_data(control_response_dout),.occupancy(response_occupancy));
  // The executor treats an accepted-lane write_nb success as shell receipt.
  // Therefore full_n itself validates the complete old record and real FIFO
  // drain. Invalid accepted attempts never transact or increment a counter.
  // Only the rejection lane consumes bounded notifications unconditionally.
  assign control_response_receipt_full_n=rst_n && accepted_response_match;
  assign control_response_rejection_full_n=rst_n;
  assign accepted_receipt_fire=control_response_receipt_write && control_response_receipt_full_n;
  assign rejection_fire=control_response_rejection_write && control_response_rejection_full_n;
  assign accepted_response_match=response_active && !response_mutated &&
      shell_response_valid && shell_response==response_record &&
      response_send_beats==16 && response_read_beats==16 && response_occupancy==0 &&
      control_response_receipt_din==response_record;
  // Neither the last FIFO write nor its last pop acknowledges codec success.
  // Only this separate, complete matching accepted record can pop the shell.
  assign shell_response_ready=accepted_receipt_fire;
  assign shell_closed_consumer_valid=shell_response_ready &&
      response_record[KIND_OFFSET*8+:8]==CLOSED;
  assign shell_closed_consumer_record=response_record;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      request_state<=COLLECT;request_ingress_beats<=0;request_collect_beats<=0;
      request_echo_beats<=0;request_echo_reads<=0;request_record<=0;
      response_record<=0;response_active<=0;response_send_beats<=0;response_read_beats<=0;
      response_mutated<=0;protocol_error<=0;cancel_seen<=0;
      control_request_writes<=0;control_request_reads<=0;shell_control_consumed<=0;
      request_receipt_writes<=0;request_receipt_reads<=0;response_writes<=0;response_reads<=0;
      accepted_response_receipts<=0;rejected_response_receipts<=0;
      invalid_accepted_receipts<=0;shell_response_pops<=0;
    end else begin
      if(cancel)cancel_seen<=1;
      if(control_request_write && control_request_full_n)begin
        request_ingress_beats<=request_ingress_beats+1'b1;
        control_request_writes<=control_request_writes+1'b1;
      end
      if(request_fifo_valid && request_fifo_pop)begin
        request_record[request_collect_beats[3:0]*512+:512]<=request_fifo_data;
        request_collect_beats<=request_collect_beats+1'b1;
        control_request_reads<=control_request_reads+1'b1;
        if(request_collect_beats==15)request_state<=ISSUE;
      end
      if(shell_control_valid && shell_control_ready)begin
        shell_control_consumed<=shell_control_consumed+1'b1;
        request_echo_beats<=0;request_echo_reads<=0;request_state<=ECHO;
      end
      if(echo_fifo_push && echo_fifo_ready)begin
        request_echo_beats<=request_echo_beats+1'b1;
        request_receipt_writes<=request_receipt_writes+1'b1;
        if(request_echo_beats==15)request_state<=WAIT_ECHO_DRAIN;
      end
      if(echo_fifo_pop)begin
        request_echo_reads<=request_echo_reads+1'b1;
        request_receipt_reads<=request_receipt_reads+1'b1;
      end
      if(request_state==WAIT_ECHO_DRAIN && request_echo_reads==16 && request_receipt_occupancy==0)begin
        request_state<=COLLECT;request_ingress_beats<=0;request_collect_beats<=0;
        request_echo_beats<=0;request_echo_reads<=0;
      end

      if(!response_active && shell_response_valid)begin
        response_record<=shell_response;response_active<=1;
        response_send_beats<=0;response_read_beats<=0;response_mutated<=0;
      end
      if(response_active && (!shell_response_valid || shell_response!=response_record))begin
        // Keep old bytes and all transport state for diagnosis/old cleanup.
        // A source contract violation cannot pop a different presented frame.
        response_mutated<=1;protocol_error<=1;
      end
      if(response_fifo_push && response_fifo_ready)begin
        response_send_beats<=response_send_beats+1'b1;
        response_writes<=response_writes+1'b1;
      end
      if(response_fifo_pop)begin
        response_read_beats<=response_read_beats+1'b1;
        response_reads<=response_reads+1'b1;
      end
      if(rejection_fire)rejected_response_receipts<=rejected_response_receipts+1'b1;
      if(accepted_receipt_fire)begin
        accepted_response_receipts<=accepted_response_receipts+1'b1;
        shell_response_pops<=shell_response_pops+1'b1;response_active<=0;
      end
      // invalid_accepted_receipts remains zero: full_n forbids such a fire.
    end
  end
  // Rejection data is deliberately not interpreted as a shell handshake.
  // Its owning executor already classified this complete raw notification.
  wire unused_rejection_payload=^control_response_rejection_din;
endmodule
