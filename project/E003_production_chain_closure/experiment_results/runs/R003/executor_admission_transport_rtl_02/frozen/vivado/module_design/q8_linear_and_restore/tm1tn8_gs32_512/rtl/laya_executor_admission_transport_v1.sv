`timescale 1ns/1ps
// FIRST-only LAD1 transport for the exclusive actual executor A producer lane.
// The wrapper must route the real admission_owner ap_fifo producer here. That
// producer emits A only after real LYRQ/LYMP admission; the first actual write
// owns this one frame. first_started is a transport ownership fact, not proof
// of validation. No receipt-dependent admission_valid or unkeyed validation
// bool is introduced. Only the real portal's full-record accepted handshake
// authorizes the original packet echo. Reset is session initialization only;
// this module has no replacement, CLOSED, or REARM authority.
module laya_executor_admission_transport_v1 (
  input logic clk,rst_n,cancel,
  input logic [511:0] admission_owner_din,
  input logic admission_owner_write,
  output logic admission_owner_full_n,
  output logic [511:0] admission_owner_receipt_dout,
  output logic admission_owner_receipt_empty_n,
  input logic admission_owner_receipt_read,
  output logic lpv_admission_valid,
  input logic lpv_admission_ready,lpv_admission_accepted,
  output logic [8191:0] lpv_admission_record,
  output logic first_started,record_complete,isolated,receipt_done,
  output logic cancel_seen,protocol_error,
  output logic [31:0] admission_writes,admission_reads,
  output logic [31:0] portal_handshakes,portal_accepts,
  output logic [31:0] receipt_writes,receipt_reads,
  output logic [1:0] admission_occupancy,receipt_occupancy,
  output logic [2:0] phase,
  output logic [4:0] ingress_beats,collect_beats,echo_beats,echo_read_beats
);
  typedef enum logic [2:0] {
    COLLECT,WAIT_PORTAL,ECHO,WAIT_ECHO_DRAIN,DONE,ISOLATED
  } state_t;
  state_t state;
  logic [8191:0] record;
  logic ingress_ready,ingress_valid,ingress_pop,ingress_fire;
  logic [511:0] ingress_data;
  logic echo_ready,echo_valid,echo_push,echo_pop;
  logic [511:0] echo_data;
  logic portal_fire,portal_accept_fire;

  assign phase=state;
  assign record_complete=collect_beats==16;
  assign isolated=state==ISOLATED;
  assign receipt_done=state==DONE;
  // Cancellation before the first write prevents a new frame. Once the first
  // real write owns A, all remaining old beats keep their original route.
  assign admission_owner_full_n=rst_n && state==COLLECT &&
      ingress_beats<16 && ingress_ready && (first_started || !cancel);
  assign ingress_fire=admission_owner_write && admission_owner_full_n;
  assign ingress_pop=state==COLLECT && collect_beats<16;
  laya_private_fifo2_v1 admission_fifo(.clk,.rst_n,
      .in_valid(ingress_fire),.in_ready(ingress_ready),.in_data(admission_owner_din),
      .out_valid(ingress_valid),.out_ready(ingress_pop),.out_data(ingress_data),
      .occupancy(admission_occupancy));

  // A is immutable once complete, including rejection and cancellation. The
  // existing full portal validator/install remains the sole decision owner.
  assign lpv_admission_valid=rst_n && state==WAIT_PORTAL && !cancel && !cancel_seen;
  assign lpv_admission_record=record;
  assign portal_fire=lpv_admission_valid && lpv_admission_ready;
  assign portal_accept_fire=portal_fire && lpv_admission_accepted;
  // Cancel/live-input changes never gate an already accepted original echo.
  assign echo_push=state==ECHO && echo_beats<16;
  assign echo_data=record[echo_beats[3:0]*512+:512];
  assign admission_owner_receipt_empty_n=echo_valid;
  assign echo_pop=echo_valid && admission_owner_receipt_read;
  laya_private_fifo2_v1 receipt_fifo(.clk,.rst_n,
      .in_valid(echo_push),.in_ready(echo_ready),.in_data(echo_data),
      .out_valid(echo_valid),.out_ready(admission_owner_receipt_read),
      .out_data(admission_owner_receipt_dout),.occupancy(receipt_occupancy));

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=COLLECT;record<=0;first_started<=0;
      cancel_seen<=0;protocol_error<=0;
      ingress_beats<=0;collect_beats<=0;echo_beats<=0;echo_read_beats<=0;
      admission_writes<=0;admission_reads<=0;
      portal_handshakes<=0;portal_accepts<=0;receipt_writes<=0;receipt_reads<=0;
    end else begin
      // A cancellation while no frame exists does not create a revoked A.
      if(first_started && cancel)cancel_seen<=1;
      if(lpv_admission_accepted && !portal_fire)protocol_error<=1;
      if(ingress_fire)begin
        first_started<=1;ingress_beats<=ingress_beats+1;
        admission_writes<=admission_writes+1;
      end
      if(ingress_valid && ingress_pop)begin
        record[collect_beats[3:0]*512+:512]<=ingress_data;
        collect_beats<=collect_beats+1;admission_reads<=admission_reads+1;
        if(collect_beats==15)begin
          if(cancel || cancel_seen)state<=ISOLATED;
          else state<=WAIT_PORTAL;
        end
      end
      if(state==WAIT_PORTAL)begin
        if(cancel || cancel_seen)state<=ISOLATED;
        else if(portal_fire)begin
          portal_handshakes<=portal_handshakes+1;
          if(portal_accept_fire)begin
            portal_accepts<=portal_accepts+1;state<=ECHO;
          end else state<=ISOLATED;
        end
      end
      if(echo_push && echo_ready)begin
        echo_beats<=echo_beats+1;receipt_writes<=receipt_writes+1;
        if(echo_beats==15)state<=WAIT_ECHO_DRAIN;
      end
      if(echo_pop)begin
        echo_read_beats<=echo_read_beats+1;receipt_reads<=receipt_reads+1;
      end
      if(state==WAIT_ECHO_DRAIN && echo_read_beats==16 && receipt_occupancy==0)
        state<=DONE;
    end
  end
endmodule
