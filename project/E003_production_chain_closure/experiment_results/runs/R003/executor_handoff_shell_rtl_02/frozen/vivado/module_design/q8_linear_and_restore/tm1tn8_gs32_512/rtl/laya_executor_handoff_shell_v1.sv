`timescale 1ns/1ps
// Single pending control transaction. Ownership and start authority are
// separate: revocation never removes the old owner's cleanup route.
module laya_executor_handoff_shell_v1 (
  input logic clk,rst_n,cancel,
  input logic [63:0] current_session,current_request,
  input logic [767:0] current_identity,
  input logic base_valid,
  input logic [63:0] base_epoch,base_address,base_capacity,
  input logic control_valid,
  output logic control_ready,
  input logic [8191:0] control,
  output logic response_valid,
  input logic response_ready,
  output logic [8191:0] response,
  output logic stop_predecessor,locks_owned,
  output logic [8191:0] pending_key,
  input logic predecessor_done_valid,
  output logic predecessor_done_ready,
  input logic [8191:0] predecessor_done_key,
  input logic old_channels_drained,physical_safe,protection_valid,
  input logic query_accepted,
  input logic [8191:0] query_request,
  input logic query_response_pop,
  input logic [511:0] query_response_word,
  output logic query_permit,import_pending,
  output logic executor_owns_dispatch,authority_valid,revoked,local_committed,
  output logic [63:0] sequence_high_water,handoff_high_water,
  output logic [31:0] control_rejections,grants,closed_aborts,
  output logic [3:0] phase
);
  import laya_executor_handoff_layout_v1::*;
  typedef enum logic [3:0] {IDLE,DRAIN,HELD_REPLY,HELD_READY,QUERY,
      IMPORT_PENDING,GRANT_REPLY,ACTIVE,ABORT_WAIT,ABORT_REPLY,ISOLATED} state_t;
  state_t state;
  logic predecessor_done,proof_success;
  logic [4:0] response_beats;
  logic [8191:0] captured_response,abort_message;
  logic immutable_live;
  logic [8191:0] assembled;

  // Remove only fields that the control header owns. Full B/S/H and request
  // ownership remain in this exact 8192-bit key, without a short hash.
  function automatic logic [8191:0] key(input logic [8191:0] p);
    logic [8191:0] v;
    begin
      v=p;v[0+:64]=0;v[8*8+:64]=0;v[24*8+:128]=0;
      v[COMMITTED_OFFSET*8+:8]=0;key=v;
    end
  endfunction
  function automatic logic control_header_ok(input logic [8191:0] p);
    begin
      control_header_ok=p[0+:32]==CONTROL_MAGIC && p[4*8+:16]==CONTROL_VERSION &&
        p[6*8+:16]==16 && p[9*8+:8]==0 && p[12*8+:32]==0 &&
        p[28*8+:32]==0 && p[664*8+:64]==0 && p[678*8+:16]==0 &&
        p[744*8+:192]==0 && p[768*8+:64]==0 &&
        p[793*8+:1848]==0 && p[COMMITTED_OFFSET*8+:8]<=1 &&
        p[SESSION_OFFSET*8+:64]!=0 && p[ACCEPTED_REQUEST_OFFSET*8+:64]!=0 &&
        p[SEQUENCE_OFFSET*8+:64]!=0;
    end
  endfunction
  function automatic logic [8191:0] reply(input logic [8191:0] p,
      input logic [7:0] kind,input logic [15:0] status,input logic committed);
    logic [8191:0] v;
    begin
      v=p;v[KIND_OFFSET*8+:8]=kind;v[STATUS_OFFSET*8+:16]=status;
      v[24*8+:32]=status==0?0:p[24*8+:32];
      v[32*8+:64]=status==0?64'hffffffffffffffff:p[32*8+:64];
      v[COMMITTED_OFFSET*8+:8]={7'b0,committed};reply=v;
    end
  endfunction
  function automatic logic [8191:0] query_key(input logic [8191:0] p);
    logic [8191:0] v;
    begin
      v=p;v[0+:64]=0;v[8*8+:64]=0;v[24*8+:128]=0;
      v[678*8+:8]=0;v[744*8+:192]=0;v[768*8+:64]=0;
      // Query wire has no control ownership fields; only the shell's pending
      // transaction can supply them after its full B/S/H comparison.
      v[776*8+:64]=pending_key[776*8+:64];
      v[784*8+:64]=pending_key[784*8+:64];query_key=v;
    end
  endfunction
  assign phase=state;
  assign immutable_live=base_valid && current_session==pending_key[776*8+:64] &&
    current_request==pending_key[784*8+:64] && current_identity==pending_key[64*8+:768] &&
    base_epoch==pending_key[40*8+:64] && base_address==pending_key[48*8+:64] &&
    base_capacity==pending_key[56*8+:64];
  assign control_ready=!response_valid;
  assign predecessor_done_ready=state==DRAIN && !predecessor_done;
  assign stop_predecessor=state!=IDLE;
  assign query_permit=state==HELD_READY && !revoked && !cancel && immutable_live && protection_valid;
  assign import_pending=state==IMPORT_PENDING;
  // Physical quiescence is checked at grant only. Normal active work creates
  // debt; authority then depends on its immutable binding and held protection.
  assign authority_valid=state==ACTIVE && executor_owns_dispatch && !revoked &&
    !cancel && immutable_live && protection_valid;
  always_comb begin
    assembled=captured_response;
    assembled[response_beats[3:0]*512+:512]=query_response_word;
  end

  always_ff @(posedge clk)begin
    if(!rst_n)begin
      state<=IDLE;response_valid<=0;response<=0;pending_key<=0;
      predecessor_done<=0;locks_owned<=0;revoked<=0;local_committed<=0;
      executor_owns_dispatch<=0;sequence_high_water<=0;handoff_high_water<=0;
      control_rejections<=0;grants<=0;closed_aborts<=0;response_beats<=0;
      captured_response<=0;proof_success<=0;abort_message<=0;
    end else begin
      if(state!=IDLE && (cancel || !immutable_live))revoked<=1;
      if(response_valid && response_ready)begin
        response_valid<=0;
        case(state)
          HELD_REPLY:state<=HELD_READY;
          GRANT_REPLY:begin
            // The response remains stable even if revoked while stalled.
            // Its actual consumption is necessary, but cannot override revoke.
            executor_owns_dispatch<=1;state<=ACTIVE;
            if(!revoked && !cancel && immutable_live && protection_valid)grants<=grants+1'b1;
          end
          ABORT_REPLY:begin
            closed_aborts<=closed_aborts+1'b1;
            if(!revoked && !cancel && immutable_live)begin
              locks_owned<=0;state<=IDLE;pending_key<=0;predecessor_done<=0;
            end else state<=ISOLATED;
          end
          default:begin end
        endcase
      end
      if(predecessor_done_valid && predecessor_done_ready)begin
        if(control_header_ok(predecessor_done_key) && key(predecessor_done_key)==key(pending_key))
          predecessor_done<=1;
        else control_rejections<=control_rejections+1'b1;
      end
      if(state==DRAIN && predecessor_done && old_channels_drained && physical_safe &&
          !revoked && !cancel && immutable_live)begin
        locks_owned<=1;response<=reply(pending_key,HELD,0,0);
        response_valid<=1;state<=HELD_REPLY;
      end
      if(query_accepted)begin
        if(query_permit && query_request[0+:32]==32'h3253424c &&
            query_request[4*8+:16]==2 && query_request[6*8+:16]==16 &&
            query_request[8*8+:16]==1 && query_request[10*8+:48]==0 &&
            query_request[24*8+:128]==0 && query_request[776*8+:1984]==0 &&
            query_key(query_request)==key(pending_key))begin
          state<=QUERY;response_beats<=0;captured_response<=0;proof_success<=0;
        end else control_rejections<=control_rejections+1'b1;
      end
      if(query_response_pop)begin
        if(state==QUERY && response_beats<16)begin
          captured_response<=assembled;response_beats<=response_beats+1'b1;
          if(response_beats==15)begin
            state<=IMPORT_PENDING;
            proof_success<=assembled[0+:32]==32'h3252424c &&
              assembled[4*8+:16]==2 && assembled[6*8+:16]==16 &&
              assembled[10*8+:16]==0 && assembled[12*8+:32]==255 &&
              assembled[744*8+:32]==15 && assembled[748*8+:32]==15 &&
              assembled[776*8+:1984]==0 && query_key(assembled)==key(pending_key);
          end
        end else control_rejections<=control_rejections+1'b1;
      end
      if(control_valid && control_ready)begin
        if(!control_header_ok(control))control_rejections<=control_rejections+1'b1;
        else if(state==IDLE && control[8*8+:8]==HOLD && control[10*8+:16]==0 &&
            control[24*8+:32]==0 && control[32*8+:64]==64'hffffffffffffffff &&
            control[680*8+:64]==0 && !control[792*8+:8] &&
            control[16*8+:64]>sequence_high_water && handoff_high_water!=64'hffffffffffffffff &&
            control[776*8+:64]==current_session && control[784*8+:64]==current_request &&
            control[64*8+:768]==current_identity && base_valid && !cancel &&
            control[40*8+:64]==base_epoch && control[48*8+:64]==base_address &&
            control[56*8+:64]==base_capacity)begin
          pending_key<=control;pending_key[680*8+:64]<=handoff_high_water+1'b1;
          handoff_high_water<=handoff_high_water+1'b1;sequence_high_water<=control[16*8+:64];
          state<=DRAIN;predecessor_done<=0;local_committed<=0;revoked<=0;
          response_beats<=0;proof_success<=0;
        end else if(key(control)!=key(pending_key))control_rejections<=control_rejections+1'b1;
        else if(state==IMPORT_PENDING && control[8*8+:8]==IMPORT_OK &&
            control[10*8+:16]==0 && control[24*8+:32]==0 &&
            control[32*8+:64]==64'hffffffffffffffff && control[792*8+:8]==1)begin
          // Commit is a retained fact even when the same edge revokes grant.
          local_committed<=1;
          if(proof_success && !revoked && !cancel && immutable_live &&
              protection_valid && physical_safe && old_channels_drained)begin
            response<=reply(pending_key,GRANTED,0,1);response_valid<=1;state<=GRANT_REPLY;
          end else revoked<=1;
        end else if(control[8*8+:8]==ABORT && control[10*8+:16]!=0 &&
            control[10*8+:16]<=8 && (state==DRAIN || state==HELD_READY || state==IMPORT_PENDING ||
                                    state==ACTIVE) && (!local_committed || control[792*8+:8]==1))begin
          abort_message<=control;
          if(local_committed || control[792*8+:8]==1 || executor_owns_dispatch)begin
            local_committed<=local_committed || control[792*8+:8]==1;
            revoked<=1;state<=ISOLATED;
          end else state<=ABORT_WAIT;
        end else control_rejections<=control_rejections+1'b1;
      end
      if(state==ABORT_WAIT && old_channels_drained && physical_safe)begin
        response<=reply(abort_message,ABORT_CLOSED,abort_message[10*8+:16],0);
        response_valid<=1;state<=ABORT_REPLY;
      end
    end
  end
endmodule
