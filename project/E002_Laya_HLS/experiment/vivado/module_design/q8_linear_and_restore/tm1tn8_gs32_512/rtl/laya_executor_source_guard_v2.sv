`timescale 1ns/1ps
// Internal exclusion and old-transaction drain, with one immutable old K/B.
// Wire shell_hold_fire/record to the actual complete HOLD consumer, shell K
// and locks to the unique handoff shell, and grant_receipt_fire/record to the
// transport's actual accepted whole-record write. No LBR1 or proof Boolean.
// This cache is not a READY/lease/publication table and releases no shell K.
module laya_executor_source_guard_v2 (
  input logic clk,rst_n,cancel,
  input logic shell_hold_fire,shell_hold_active,shell_locks_owned,
  input logic [8191:0] shell_hold_record,shell_pending_key,
  input logic shell_authority_valid,shell_revoked,
  input logic grant_receipt_fire,
  input logic [8191:0] grant_receipt_record,
  input logic source_still_matches,live_base_valid,
  input logic [63:0] live_base_epoch,live_base_address,live_base_capacity,
  input logic physical_safe,
  output logic guard_active,grant_valid,guard_revoked,
  output logic [8191:0] guard_key,
  output logic base_change_ready,source_change_ready,
  input logic action_valid,
  input logic [4095:0] action_request,
  output logic action_ready,
  input logic producer_valid,
  input logic [8191:0] producer_request,
  output logic producer_ready,
  // The eight actual caller pops AFTER complete F9 LPC1 validation, including
  // its physical final pop. These ports do not accept raw engine-done.
  input logic producer_completion_empty_n,producer_completion_read,
  input logic [511:0] action_completion_dout,
  input logic action_completion_empty_n,action_completion_read,
  input logic [63:0] source_araddr,
  input logic [7:0] source_arlen,
  input logic [2:0] source_arsize,
  input logic [1:0] source_arburst,
  input logic source_arvalid,source_arready,
  output logic source_ar_allowed,
  input logic source_rvalid,source_rready,source_rlast,
  input logic [1:0] source_rresp,
  output logic [31:0] read_debt,
  output logic ar_offer_owned,
  // All physical STATE0 write ingress must use this interval gate. The route
  // tag comes from the unique actual accepted NORM producer, never Host data.
  // Existing old NORM stores can finish under revoke, within their old window.
  // This gate applies to new AW only. Accepted old W/B must drain separately
  // without this gate; physical_safe is the real combined write/read fence.
  input logic state0_write_is_norm_target,
  input logic [63:0] state0_awaddr,
  input logic [7:0] state0_awlen,
  input logic [2:0] state0_awsize,
  input logic [1:0] state0_awburst,
  output logic state0_write_allowed,norm_target_write_allowed,
  output logic producer_active,action_active,protocol_error,
  output logic [31:0] grants_accepted,grants_rejected,
  output logic [31:0] actions_accepted,producers_accepted,source_ar_pops,source_r_pops,
  output logic [31:0] producer_completion_pops,action_completion_pops
);
  import laya_executor_handoff_layout_v1::*;
  logic action_safe_consumed,grant_seen;
  logic [4095:0] accepted_action;
  logic [2047:0] completion_packet,candidate_completion;
  logic [1:0] completion_beat;
  logic [2:0] producer_completion_beat;
  logic [63:0] read_first,read_after,write_first,write_after;
  logic [63:0] offered_addr;
  logic [7:0] offered_len;
  logic [2:0] offered_size;
  logic [1:0] offered_burst;
  logic [8191:0] exclusion_key;
  logic exclusion_active,write_in_base,write_overlaps_source,write_overlaps_target;
  logic [63:0] write_bytes,write_end,source_first,source_after,target_first,target_after;
  wire live_base_matches=live_base_valid &&
    guard_key[40*8+:64]==live_base_epoch && guard_key[48*8+:64]==live_base_address &&
    guard_key[56*8+:64]==live_base_capacity;
  wire old_shell_matches=shell_hold_active && shell_pending_key==guard_key;
  wire start_authority=guard_active && grant_valid && shell_locks_owned &&
    shell_authority_valid && old_shell_matches && source_still_matches &&
    live_base_matches && !shell_revoked && !guard_revoked && !cancel && !protocol_error;
  wire ar_offer_matches=source_arvalid && source_araddr==offered_addr &&
    source_arlen==offered_len && source_arsize==offered_size && source_arburst==offered_burst;
  wire ar_candidate_allowed=start_authority && producer_active && !action_safe_consumed &&
    !safe_completion_pop && read_debt==0 && source_arsize==6 && source_arburst==1 && source_araddr[5:0]==0 &&
    source_araddr>=read_first && source_araddr<=64'hffffffffffffffff-(64'(source_arlen)+1)*64 &&
    source_araddr+(64'(source_arlen)+1)*64<=read_after;
  wire ar_pop=source_arvalid && source_arready && source_ar_allowed;
  wire r_pop=source_rvalid && source_rready;
  wire safe_completion_pop=action_active && action_completion_empty_n &&
    action_completion_read && completion_beat==3 && safe_completion(candidate_completion);

  function automatic logic control_binding_ok(input logic [8191:0] p);
    logic [63:0] extent;
    extent=(64'(p[80*8+:16])-1)*4194304+64'(p[82*8+:16])*4096;
    return p[0+:32]==CONTROL_MAGIC && p[4*8+:16]==CONTROL_VERSION && p[6*8+:16]==16 &&
      p[9*8+:8]==0 && p[12*8+:32]==0 && p[28*8+:32]==0 &&
      p[16*8+:64]!=0 && p[40*8+:64]!=0 && p[48*8+:64]!=0 && p[48*8+:6]==0 &&
      p[56*8+:64]!=0 && p[56*8+:64]<=64'hffffffffffffffff-p[48*8+:64] &&
      laya_generated_provenance_layout_v1::identity_ok(p[64*8+:672]) && p[148*8+:96]==0 &&
      laya_model_identity_13bo_generated_v1::l13m_canonical_ok(p[160*8+:3328]) &&
      laya_model_identity_13bo_generated_v1::l13m_numeric_tags_ok(p[160*8+:3328],p[64*8+:672]) &&
      laya_compute_portal_layout_v1::ref_ok(p[576*8+:64]) &&
      p[580*8+:32]==32'd1 && p[584*8+:64]==0 &&
      p[592*8+:32]==32'h00ff0002 && p[596*8+:16]==0 &&
      p[598*8+:16]==p[82*8+:16] && p[600*8+:16]==1024 &&
      p[602*8+:8]==1 && p[603*8+:8]==0 && p[604*8+:8]==6 && p[605*8+:24]==0 &&
      p[608*8+:64]==p[56*8+:64] && p[616*8+:64]==0 &&
      p[624*8+:64]==4096 && p[632*8+:64]==4194304 && p[640*8+:64]==extent &&
      p[648*8+:192]==0 && p[672*8+:16]==1 && p[674*8+:32]==32'h06000002 &&
      p[678*8+:16]==0 && p[680*8+:64]!=0 &&
      p[688*8+:192]==p[40*8+:192] && p[712*8+:64]==8388608 &&
      p[720*8+:64]==extent && p[728*8+:64]==4096 && p[736*8+:64]==4194304 &&
      p[56*8+:64]>=8388608 && extent<=p[56*8+:64]-8388608 &&
      p[744*8+:256]==0 && p[776*8+:64]!=0 && p[784*8+:64]!=0 &&
      p[793*8+:1848]==0;
  endfunction
  function automatic logic old_key_ok(input logic [8191:0] p);
    // The shell retained HOLD has its allocated H but still has commit=0.
    return control_binding_ok(p) && p[8*8+:8]==HOLD && p[10*8+:16]==0 &&
      p[24*8+:32]==0 && p[32*8+:64]==64'hffffffffffffffff && p[792*8+:8]==0;
  endfunction
  function automatic logic granted_bound(input logic [8191:0] p);
    logic [8191:0] expected;
    expected=guard_key;expected[8*8+:8]=GRANTED;expected[792*8+:8]=1;
    return control_binding_ok(p) && p[8*8+:8]==GRANTED && p[10*8+:16]==0 &&
      p[24*8+:32]==0 && p[32*8+:64]==64'hffffffffffffffff && p[792*8+:8]==1 &&
      old_key_ok(guard_key) && p==expected;
  endfunction
  function automatic logic action_bound(input logic [4095:0] p);
    return p[0+:32]==32'h3158414c && p[4*8+:16]==1 && p[6*8+:16]==8 &&
      p[8*8+:8]==2 && p[10*8+:24]==24'h010211 &&
      p[13*8+:24]==0 && p[20*8+:32]==0 && p[32*8+:256]==0 &&
      p[24*8+:64]!=0 && p[16*8+:32]==0 && p[148*8+:96]==0 &&
      p[160*8+:8]<22 && p[161*8+:56]==0 &&
      p[224*8+:8]<22 && p[225*8+:24]==guard_key[674*8+:24] && p[228*8+:32]==0 &&
      p[232*8+:64]!=0 && p[240*8+:128]==0 &&
      p[256*8+:8]==0 && p[257*8+:8]==255 && p[258*8+:254*8]==0 &&
      p[64*8+:672]==guard_key[64*8+:672] &&
      p[168*8+:64]==64'(guard_key[576*8+:32]) &&
      p[176*8+:64]==guard_key[576*8+:64] &&
      p[184*8+:32]==guard_key[592*8+:32] &&
      p[188*8+:56]==guard_key[596*8+:56] && p[195*8+:29*8]==0;
  endfunction
  function automatic logic producer_bound(input logic [8191:0] p);
    logic [15:0] row,rows;
    logic [63:0] offset_value;
    row=p[157*8+:16];rows={8'd0,p[159*8+:8]};
    offset_value=64'(p[155*8+:8])*guard_key[632*8+:64]+64'(row)*4096;
    return p[0+:32]==32'h3145504c && p[4*8+:16]==1 && p[6*8+:16]==16 &&
      p[8*8+:16]==1 && p[10*8+:16]==0 && p[12*8+:16]==8 && p[14*8+:16]==0 &&
      p[16*8+:64]!=0 && p[24*8+:64]!=0 && p[32*8+:256]==0 &&
      p[64*8+:672]==guard_key[64*8+:672] && p[160*8+:3328]==guard_key[160*8+:3328] &&
      p[148*8+:32]!=0 && p[148*8+:32]!=32'hffffffff &&
      p[152*8+:24]==accepted_action[10*8+:24] && p[155*8+:8]<guard_key[80*8+:16] &&
      p[156*8+:8]==0 && rows>=1 && rows<=16 && 32'(row)+32'(rows)<=guard_key[82*8+:16] &&
      p[576*8+:64]==guard_key[576*8+:64] &&
      laya_compute_portal_layout_v1::ref_ok(p[584*8+:64]) &&
      p[588*8+:24]==guard_key[674*8+:24] && p[591*8+:8]==0 &&
      p[592*8+:16]==1024 && p[594*8+:24]==0 &&
      p[597*8+:8]==guard_key[604*8+:8] && p[598*8+:8]==guard_key[677*8+:8] &&
      p[599*8+:8]==0 && p[600*8+:32]==32'h3727c5ac && p[604*8+:32]==4096 &&
      p[608*8+:64]==offset_value && p[616*8+:64]==guard_key[712*8+:64]+offset_value &&
      p[624*8+:64]==4096 && p[632*8+:64]==4096 &&
      p[640*8+:64]==guard_key[56*8+:64] && p[648*8+:64]==guard_key[704*8+:64] &&
      p[656*8+:32]==32'(rows)*1024 && p[660*8+:8]==1 && p[661*8+:363*8]==0;
  endfunction
  function automatic logic safe_completion(input logic [2047:0] p);
    logic [31:0] flags;
    flags=p[16*8+:32];
    return p[0+:32]==32'h3143414c && p[4*8+:16]==1 && p[6*8+:16]==4 &&
      p[8*8+:40]==accepted_action[8*8+:40] && p[13*8+:24]==0 &&
      p[20*8+:32]==0 && p[24*8+:64]==accepted_action[24*8+:64] &&
      p[32*8+:256]==0 && p[64*8+:672]==accepted_action[64*8+:672] &&
      p[148*8+:16]<=8 && p[150*8+:16]==0 && p[174*8+:16]==0 &&
      p[177*8+:56]==0 && p[199*8+:8]==0 && p[211*8+:45*8]==0 && (flags & 32'hffffff80)==0 &&
      (flags & 15)==15 && !(p[148*8+:16]==0 && flags[6]) &&
      (p[148*8+:16]==0 ?
        (flags[4] && flags[5] && p[176*8+:8]==accepted_action[224*8+:8] &&
         p[184*8+:64]==accepted_action[232*8+:64] &&
         p[192*8+:32]!=0 && p[196*8+:24]==accepted_action[225*8+:24] &&
         p[199*8+:8]==0 && p[200*8+:16]==accepted_action[11*8+:16] &&
         p[202*8+:8]==255 && p[203*8+:8]==0 && p[204*8+:16]==0 &&
         p[206*8+:16]==guard_key[82*8+:16] && p[208*8+:16]==1024 &&
         p[210*8+:8]==1 && p[211*8+:45*8]==0 &&
         p[164*8+:32]!=0 && p[168*8+:32]>=p[164*8+:32] &&
         p[168*8+:32]-p[164*8+:32]+1==p[172*8+:16] && p[172*8+:16]==
          guard_key[80*8+:16]*((guard_key[82*8+:16]+15)/16)) :
        (!flags[4] && (flags[5] ?
          (p[164*8+:32]!=0 && p[168*8+:32]>=p[164*8+:32] &&
           p[168*8+:32]-p[164*8+:32]+1==p[172*8+:16] && p[172*8+:16]!=0 &&
           p[172*8+:16]<=guard_key[80*8+:16]*((guard_key[82*8+:16]+15)/16)) :
          (p[164*8+:80]==0))));
  endfunction

  always_comb begin
    candidate_completion=completion_packet;
    candidate_completion[completion_beat*512+:512]=action_completion_dout;
    exclusion_active=guard_active || shell_hold_active || shell_hold_fire;
    exclusion_key=guard_active?guard_key:(shell_hold_active?shell_pending_key:shell_hold_record);
    write_bytes=(64'(state0_awlen)+1)*64;
    write_end=state0_awaddr+write_bytes;
    source_first=exclusion_key[48*8+:64]+exclusion_key[616*8+:64];
    source_after=source_first+exclusion_key[640*8+:64];
    target_first=exclusion_key[696*8+:64]+exclusion_key[712*8+:64];
    target_after=target_first+exclusion_key[720*8+:64];
    write_in_base=state0_awsize==6 && state0_awburst==1 && state0_awaddr[5:0]==0 &&
      state0_awaddr<=64'hffffffffffffffff-write_bytes &&
      (exclusion_active ?
        (state0_awaddr>=exclusion_key[48*8+:64] &&
         write_end-exclusion_key[48*8+:64]<=exclusion_key[56*8+:64]) :
        (live_base_valid && state0_awaddr>=live_base_address &&
         write_end-live_base_address<=live_base_capacity));
    write_overlaps_source=state0_awaddr<source_after && write_end>source_first;
    write_overlaps_target=state0_awaddr<target_after && write_end>target_first;
    norm_target_write_allowed=guard_active && producer_active && state0_write_is_norm_target &&
      write_in_base && state0_awaddr>=write_first && write_end<=write_after &&
      !write_overlaps_source;
    state0_write_allowed=state0_write_is_norm_target?norm_target_write_allowed:
      (write_in_base && (!exclusion_active || (control_binding_ok(exclusion_key) &&
       !write_overlaps_source && !write_overlaps_target)));
  end
  assign base_change_ready=!shell_hold_fire && !shell_hold_active && !guard_active &&
    physical_safe && !producer_active && !ar_offer_owned && read_debt==0;
  assign source_change_ready=base_change_ready;
  assign action_ready=start_authority && !action_active && !producer_active &&
    !ar_offer_owned && read_debt==0 && action_bound(action_request);
  assign producer_ready=start_authority && action_active && !producer_active &&
    !ar_offer_owned && read_debt==0 && !action_safe_consumed && !safe_completion_pop &&
    producer_bound(producer_request);
  // A legal VALID presented before revocation already belongs to the old K.
  // Keep its exact offer until actual handshake, even under persistent cancel.
  assign source_ar_allowed=ar_offer_owned?ar_offer_matches:ar_candidate_allowed;

  always_ff @(posedge clk)begin : state
    logic [2047:0] complete;
    logic [31:0] owed;
    if(!rst_n)begin
      guard_active<=0;grant_valid<=0;guard_revoked<=0;guard_key<=0;grant_seen<=0;
      producer_active<=0;action_active<=0;protocol_error<=0;read_debt<=0;
      ar_offer_owned<=0;offered_addr<=0;offered_len<=0;offered_size<=0;offered_burst<=0;
      accepted_action<=0;completion_packet<=0;completion_beat<=0;
      producer_completion_beat<=0;action_safe_consumed<=0;
      read_first<=0;read_after<=0;write_first<=0;write_after<=0;
      grants_accepted<=0;grants_rejected<=0;actions_accepted<=0;producers_accepted<=0;
      source_ar_pops<=0;source_r_pops<=0;producer_completion_pops<=0;action_completion_pops<=0;
    end else begin
      if(shell_hold_active && !guard_active && !grant_seen)begin
        guard_key<=shell_pending_key;guard_active<=1;
        if(!old_key_ok(shell_pending_key))begin protocol_error<=1;guard_revoked<=1;end
      end
      if(guard_active && (cancel || shell_revoked || !old_shell_matches ||
          !source_still_matches || !live_base_matches))guard_revoked<=1;
      if(grant_receipt_fire && grant_receipt_record[8*8+:8]==GRANTED)begin
        grant_seen<=1;
        if(guard_active && !grant_valid && shell_locks_owned && old_shell_matches &&
            source_still_matches && live_base_matches && !cancel && !shell_revoked &&
            !guard_revoked && !protocol_error && granted_bound(grant_receipt_record))begin
          grant_valid<=1;grants_accepted<=grants_accepted+1'b1;
        end else begin
          grants_rejected<=grants_rejected+1'b1;guard_revoked<=1;
          // Actual old accepted receipt continues through the transport; only
          // this guard's new-start authority is isolated on a bad binding.
          if(!granted_bound(grant_receipt_record))protocol_error<=1;
        end
      end
      if(action_valid && action_ready)begin
        accepted_action<=action_request;action_active<=1;action_safe_consumed<=0;
        completion_beat<=0;actions_accepted<=actions_accepted+1'b1;
      end
      if(producer_valid && producer_ready)begin
        producer_active<=1;producer_completion_beat<=0;producers_accepted<=producers_accepted+1'b1;
        read_first<=guard_key[48*8+:64]+producer_request[608*8+:64];
        read_after<=guard_key[48*8+:64]+producer_request[608*8+:64]+64'(producer_request[159*8+:8])*4096;
        write_first<=guard_key[696*8+:64]+producer_request[616*8+:64];
        write_after<=guard_key[696*8+:64]+producer_request[616*8+:64]+64'(producer_request[159*8+:8])*4096;
      end
      if(source_arvalid && ar_candidate_allowed && !source_arready && !ar_offer_owned)begin
        ar_offer_owned<=1;offered_addr<=source_araddr;offered_len<=source_arlen;
        offered_size<=source_arsize;offered_burst<=source_arburst;
      end
      if(ar_offer_owned && !ar_offer_matches)begin protocol_error<=1;guard_revoked<=1;end
      if(ar_pop)begin ar_offer_owned<=0;source_ar_pops<=source_ar_pops+1'b1;end
      if(producer_completion_empty_n && producer_completion_read)begin
        producer_completion_pops<=producer_completion_pops+1'b1;
        if(!producer_active)begin protocol_error<=1;guard_revoked<=1;end
        else if(producer_completion_beat==7)begin producer_completion_beat<=0;producer_active<=0;end
        else producer_completion_beat<=producer_completion_beat+1'b1;
      end
      if(action_completion_empty_n && action_completion_read)begin
        action_completion_pops<=action_completion_pops+1'b1;
        complete=completion_packet;complete[completion_beat*512+:512]=action_completion_dout;
        completion_packet<=complete;
        if(!action_active)begin protocol_error<=1;guard_revoked<=1;end
        else if(completion_beat==3)begin
          completion_beat<=0;
          if(safe_completion(complete))action_safe_consumed<=1;
        end else completion_beat<=completion_beat+1'b1;
      end
      owed=read_debt+(ar_pop?32'(source_arlen)+1:0);
      if(r_pop)begin
        source_r_pops<=source_r_pops+1'b1;
        if(owed==0 || source_rlast!=(owed==1) || source_rresp!=0)begin
          protocol_error<=1;guard_revoked<=1;
        end
      end
      case({ar_pop,r_pop})
        2'b10:read_debt<=32'(source_arlen)+1;
        2'b01:if(read_debt!=0)read_debt<=read_debt-1'b1;
        2'b11:read_debt<=read_debt+32'(source_arlen);
        default:;
      endcase
      if(guard_active && action_safe_consumed && physical_safe && !producer_active &&
          !(producer_valid && producer_ready) && !ar_offer_owned && read_debt==0 &&
          !source_arvalid && !protocol_error)begin
        // Local exclusion can end; retained K/grant/revoke and shell request
        // locks remain. This is not CLOSED, owner release or rearm.
        guard_active<=0;grant_valid<=0;action_active<=0;action_safe_consumed<=0;
      end
    end
  end
endmodule
