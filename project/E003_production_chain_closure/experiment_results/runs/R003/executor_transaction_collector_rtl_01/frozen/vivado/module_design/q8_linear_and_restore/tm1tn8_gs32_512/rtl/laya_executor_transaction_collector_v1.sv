`timescale 1ns/1ps
// One transport candidate from the sole real FSM's LTP1 output. The complete
// expected_action must come from the existing validated LAP consumer. This
// collector grants no external operation and generates no LTC/owner/retirement.
// The actual managed adapter retains its full LTX parser and the hub its final
// authority. Root integration must preserve the physical source and gate the
// F10 first pop with the sidecar's old-candidate start interlock.
module laya_executor_transaction_collector_v1 (
  input logic clk,rst_n,cancel,owner_revoked,
  input logic installed_owner_valid,
  input logic [8191:0] installed_owner,
  input logic old_has_hold,old_hold_key_valid,
  input logic [8191:0] old_hold_key,
  input logic old_route,physical_route,
  input logic expected_action_valid,
  input logic [4095:0] expected_action_packet,

  input logic [511:0] transaction_pending_dout,
  input logic transaction_pending_empty_n,
  output logic transaction_pending_read,
  input logic [511:0] source_transaction_request_dout,
  input logic source_transaction_request_empty_n,
  output logic source_transaction_request_read,
  output logic [511:0] transaction_request_dout,
  output logic transaction_request_empty_n,
  input logic transaction_request_read,
  // These are the original LTC FIFO's real downstream caller handshake.
  // Neither a last-write pulse nor a scalar completion notification belongs here.
  input logic transaction_completion_consumer_read,
  input logic transaction_completion_consumer_empty_n,

  output logic candidate_owned,candidate_verified,candidate_revoked,
  output logic candidate_route,
  output logic [8191:0] candidate_owner,
  output logic protocol_error,isolated,
  output logic metadata_first_pop,collector_first_pop,adapter_first_pop,
  output logic txn_start,txn_done,
  output logic [5:0] metadata_captured,
  output logic [4:0] ltx_captured,adapter_request_consumed,ltc_consumed,
  output logic [31:0] candidates_started,candidates_released,
  output logic [2:0] phase
);
  import laya_generated_provenance_layout_v1::*;
  typedef enum logic [2:0] {EMPTY,META,CHECK_META,COLLECT,CHECK_FULL,
      FORWARD,WAIT_RETURN,ISOLATED} state_t;
  state_t state;
  logic [16895:0] pending_record;
  logic [12287:0] collected_packet;
  logic [8191:0] retained_hold;
  logic [4095:0] retained_action;
  logic retained_has_hold,mismatch;
  logic initial_binding_ok,metadata_ok,meta_pop,source_pop,adapter_pop,ltc_pop;

  // This is not a new K validator/authority. old_hold_key_valid must certify
  // the existing shell's complete codec/full-key saved K. Check its full A
  // identity/model and referenced physical base as well as all four LTP words.
  function automatic logic hold_binding_ok(input logic has_hold,input logic valid,
      input logic [8191:0] hold_key,input logic [8191:0] owner);
    logic good;logic [7:0] role;
    begin
      // LHC1 preserves bootstrap owner at byte576: content+26,
      // layout+27, physical Bo role+28. This is wire, not Message ABI.
      role=hold_key[604*8+:8];
      good=!has_hold;
      if(has_hold)begin
        good=valid && hold_key[0+:32]==32'h3143484c &&
          hold_key[4*8+:16]==1 && hold_key[6*8+:16]==16 &&
          hold_key[16*8+:64]!=0 && hold_key[680*8+:64]!=0 &&
          hold_key[776*8+:64]==owner[16*8+:64] &&
          hold_key[784*8+:64]==owner[24*8+:64] &&
          hold_key[64*8+:672]==owner[64*8+:672] &&
          hold_key[160*8+:3328]==owner[160*8+:3328] && role<13;
        if(role<13)good=good && owner[12*8+role] &&
          hold_key[40*8+:64]==owner[(576+24*role)*8+:64] &&
          hold_key[48*8+:64]==owner[(576+24*role+8)*8+:64] &&
          hold_key[56*8+:64]==owner[(576+24*role+16)*8+:64];
      end
      return good;
    end
  endfunction

  always_comb begin
    initial_binding_ok=installed_owner_valid && admission_record_ok(installed_owner) &&
      expected_action_valid && old_route==physical_route &&
      hold_binding_ok(old_has_hold,old_hold_key_valid,old_hold_key,installed_owner) &&
      expected_action_packet[0+:32]==32'h3158414c &&
      expected_action_packet[4*8+:16]==1 && expected_action_packet[6*8+:16]==8 &&
      expected_action_packet[64*8+:672]==installed_owner[64*8+:672];
    metadata_ok=pending_record[0+:32]==32'h3150544c &&
      pending_record[4*8+:16]==1 && pending_record[6*8+:16]==33 &&
      pending_record[8*8+:8]=={7'b0,candidate_route} &&
      pending_record[9*8+:8]=={7'b0,retained_has_hold} &&
      pending_record[10*8+:48]==0 && pending_record[48*8+:128]==0 &&
      pending_record[16*8+:64]==candidate_owner[16*8+:64] &&
      pending_record[24*8+:64]==candidate_owner[24*8+:64] &&
      pending_record[64*8+:4096]==retained_action &&
      pending_record[(576+64)*8+:672]==candidate_owner[64*8+:672] &&
      pending_record[(576+160)*8+:3328]==candidate_owner[160*8+:3328];
    if(retained_has_hold)metadata_ok=metadata_ok &&
      pending_record[32*8+:64]==retained_hold[16*8+:64] &&
      pending_record[40*8+:64]==retained_hold[680*8+:64];
    else metadata_ok=metadata_ok && pending_record[32*8+:128]==0;
  end

  assign phase=state;
  assign isolated=state==ISOLATED;
  assign transaction_pending_read=rst_n && !protocol_error &&
    ((state==EMPTY && initial_binding_ok && !transaction_completion_consumer_empty_n) ||
      (state==META && metadata_captured<33 && physical_route==candidate_route));
  assign meta_pop=transaction_pending_read && transaction_pending_empty_n;
  assign source_transaction_request_read=rst_n && state==COLLECT &&
    ltx_captured<24 && physical_route==candidate_route;
  assign source_pop=source_transaction_request_read && source_transaction_request_empty_n;
  // Once complete, the original collected bytes remain presented regardless
  // of cancel/live fields. Only the actual consumer read advances the word.
  assign transaction_request_empty_n=rst_n && state==FORWARD && candidate_verified &&
    adapter_request_consumed<24;
  assign transaction_request_dout=adapter_request_consumed<24 ?
    collected_packet[adapter_request_consumed*512+:512] : collected_packet[23*512+:512];
  assign adapter_pop=transaction_request_empty_n && transaction_request_read;
  assign ltc_pop=transaction_completion_consumer_read && transaction_completion_consumer_empty_n;
  assign metadata_first_pop=meta_pop && state==EMPTY;
  assign collector_first_pop=source_pop && ltx_captured==0;
  assign adapter_first_pop=adapter_pop && adapter_request_consumed==0;
  assign txn_start=adapter_first_pop;
  assign txn_done=rst_n && state==WAIT_RETURN && ltc_pop && ltc_consumed==15;

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=EMPTY;pending_record<=0;collected_packet<=0;
      retained_hold<=0;retained_action<=0;retained_has_hold<=0;mismatch<=0;
      candidate_owned<=0;candidate_verified<=0;candidate_revoked<=0;
      candidate_route<=0;candidate_owner<=0;protocol_error<=0;
      metadata_captured<=0;ltx_captured<=0;adapter_request_consumed<=0;ltc_consumed<=0;
      candidates_started<=0;candidates_released<=0;
    end else begin
      if(candidate_owned && (cancel || owner_revoked || !installed_owner_valid ||
          installed_owner!=candidate_owner || old_route!=candidate_route ||
          old_has_hold!=retained_has_hold || !expected_action_valid ||
          expected_action_packet!=retained_action ||
          (retained_has_hold && (!old_hold_key_valid || old_hold_key!=retained_hold))))
        candidate_revoked<=1;
      if(ltc_pop && state!=WAIT_RETURN)begin
        protocol_error<=1;state<=ISOLATED;
      end else case(state)
        EMPTY:begin
          if(transaction_pending_empty_n &&
              (initial_binding_ok!==1'b1 || transaction_completion_consumer_empty_n))begin
            protocol_error<=1;state<=ISOLATED;
          end else if(meta_pop)begin
            candidate_owned<=1;candidate_verified<=0;
            // Revocation of this FIRST old-A domain survives txn_done and a
            // later matching pending, even when live cancel has recovered.
            candidate_revoked<=candidate_revoked || cancel || owner_revoked;
            candidate_owner<=installed_owner;candidate_route<=physical_route;
            retained_has_hold<=old_has_hold;retained_hold<=old_hold_key;
            retained_action<=expected_action_packet;
            pending_record[0+:512]<=transaction_pending_dout;
            metadata_captured<=1;ltx_captured<=0;adapter_request_consumed<=0;ltc_consumed<=0;
            mismatch<=0;candidates_started<=candidates_started+1'b1;state<=META;
          end
        end
        META:begin
          if(physical_route!=candidate_route)begin protocol_error<=1;state<=ISOLATED;end
          else if(meta_pop)begin
            pending_record[metadata_captured*512+:512]<=transaction_pending_dout;
            metadata_captured<=metadata_captured+1'b1;
            if(metadata_captured==32)state<=CHECK_META;
          end
        end
        CHECK_META:begin
          if(metadata_captured!=33 || metadata_ok!==1'b1)begin
            protocol_error<=1;state<=ISOLATED;
          end else state<=COLLECT;
        end
        COLLECT:begin
          if(physical_route!=candidate_route)begin protocol_error<=1;state<=ISOLATED;end
          else if(source_pop)begin
            collected_packet[ltx_captured*512+:512]<=source_transaction_request_dout;
            if(source_transaction_request_dout!==pending_record[(9+ltx_captured)*512+:512])
              mismatch<=1;
            ltx_captured<=ltx_captured+1'b1;
            if(ltx_captured==23)state<=CHECK_FULL;
          end
        end
        CHECK_FULL:begin
          if(ltx_captured!=24 || mismatch)begin protocol_error<=1;state<=ISOLATED;end
          else begin candidate_verified<=1;state<=FORWARD;end
        end
        FORWARD:if(adapter_pop)begin
          adapter_request_consumed<=adapter_request_consumed+1'b1;
          if(adapter_request_consumed==23)state<=WAIT_RETURN;
        end
        WAIT_RETURN:if(ltc_pop)begin
          ltc_consumed<=ltc_consumed+1'b1;
          if(ltc_consumed==15)begin
            candidate_owned<=0;candidate_verified<=0;
            candidates_released<=candidates_released+1'b1;state<=EMPTY;
            // Preserve old bytes/counts/revoke for diagnosis until next real
            // metadata start. No reset, FIFO clear, owner release or permission.
          end
        end
        ISOLATED:;
        default:begin protocol_error<=1;state<=ISOLATED;end
      endcase
    end
  end
endmodule
