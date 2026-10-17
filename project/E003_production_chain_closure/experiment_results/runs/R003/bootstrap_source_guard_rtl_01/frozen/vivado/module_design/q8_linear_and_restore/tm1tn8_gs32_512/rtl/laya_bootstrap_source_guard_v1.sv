`timescale 1ns/1ps
// One shell-owned exclusion interval. The immutable key is a cache of a hub
// query, never a second owner/publication table. All source-changing ingress
// and all reads in the finite shell must connect to the gates below.
module laya_bootstrap_source_guard_v1 (
  input logic clk,rst_n,cancel,
  input logic snapshot_accept,
  input logic [6143:0] snapshot_request,
  input logic snapshot_response_valid,snapshot_response_ready,
  input logic [6143:0] snapshot_response,
  input logic source_still_matches,
  input logic [63:0] live_base_epoch,live_base_address,live_base_capacity,
  input logic physical_safe,
  output logic guard_active,proof_valid,
  output logic [6143:0] guard_key,
  output logic base_change_ready,
  input logic action_valid,
  input logic [4095:0] action_request,
  output logic action_ready,
  input logic producer_valid,
  input logic [8191:0] producer_request,
  output logic producer_ready,
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
  output logic producer_active,action_active,protocol_error
);
  logic cancel_seen,action_safe_consumed,proof_rejected;
  logic [4095:0] accepted_action;
  logic [2047:0] completion_packet;
  logic [1:0] completion_beat;
  logic [2:0] producer_completion_beat;
  logic [63:0] read_first,read_after;
  wire live_base_matches=guard_key[40*8+:64]==live_base_epoch &&
    guard_key[48*8+:64]==live_base_address &&
    guard_key[56*8+:64]==live_base_capacity;
  wire proof_consumed=snapshot_response_valid && snapshot_response_ready;
  wire ar_pop=source_arvalid && source_arready && source_ar_allowed;
  wire r_pop=source_rvalid && source_rready;

  function automatic logic snapshot_bound(input logic [6143:0] p);
    return p[0+:32]==32'h3152424c && p[4*8+:16]==1 && p[6*8+:16]==12 &&
      p[8*8+:16]==guard_key[8*8+:16] && p[10*8+:16]==0 &&
      p[12*8+:32]==63 && p[16*8+:64]==guard_key[16*8+:64] &&
      p[24*8+:64]==0 && p[32*8+:64]==64'hffffffffffffffff &&
      p[40*8+:728*8]==guard_key[40*8+:728*8];
  endfunction
  function automatic logic action_bound(input logic [4095:0] p);
    return p[0+:32]==32'h3158414c && p[4*8+:16]==1 && p[6*8+:16]==8 &&
      p[8*8+:8]==2 && p[24*8+:64]!=0 && p[16*8+:32]==0 &&
      p[64*8+:672]==guard_key[64*8+:672] &&
      p[168*8+:64]==64'(guard_key[576*8+:32]) &&
      p[176*8+:64]==guard_key[576*8+:64] &&
      p[184*8+:32]==guard_key[592*8+:32] &&
      p[188*8+:56]==guard_key[596*8+:56] && p[195*8+:104]==0;
  endfunction
  function automatic logic producer_bound(input logic [8191:0] p);
    logic [15:0] row,rows;
    logic [63:0] offset_value;
    row=p[157*8+:16];rows={8'd0,p[159*8+:8]};
    offset_value=64'(p[155*8+:8])*guard_key[632*8+:64]+64'(row)*4096;
    return p[0+:32]==32'h3145504c && p[4*8+:16]==1 && p[6*8+:16]==16 &&
      p[8*8+:16]==1 && p[12*8+:16]==8 && p[16*8+:64]!=0 &&
      p[24*8+:64]!=0 && p[64*8+:672]==guard_key[64*8+:672] &&
      p[160*8+:3328]==guard_key[160*8+:3328] &&
      p[576*8+:64]==guard_key[576*8+:64] && p[595*8+:8]==0 &&
      p[597*8+:8]==guard_key[604*8+:8] && p[592*8+:16]==1024 &&
      p[152*8+:24]==accepted_action[10*8+:24] &&
      p[155*8+:8]<guard_key[80*8+:16] && p[156*8+:8]==0 &&
      rows>=1 && rows<=16 && 32'(row)+32'(rows)<=guard_key[82*8+:16] &&
      p[604*8+:32]==4096 && p[608*8+:64]==offset_value &&
      p[624*8+:64]==4096 && p[640*8+:64]==guard_key[56*8+:64] &&
      p[656*8+:32]==32'(rows)*1024;
  endfunction
  function automatic logic safe_completion(input logic [2047:0] p);
    logic [31:0] flags;
    flags=p[16*8+:32];
    return p[0+:32]==32'h3143414c && p[4*8+:16]==1 && p[6*8+:16]==4 &&
      p[8*8+:40]==accepted_action[8*8+:40] && p[13*8+:24]==0 &&
      p[20*8+:32]==0 && p[24*8+:64]==accepted_action[24*8+:64] &&
      p[32*8+:256]==0 && p[64*8+:672]==accepted_action[64*8+:672] &&
      p[148*8+:16]<=8 && p[150*8+:16]==0 && (flags & 32'hffffff80)==0 &&
      (flags & 15)==15 && !(p[148*8+:16]==0 && flags[6]) &&
      (p[148*8+:16]!=0 ||
        (flags[4] && flags[5] && p[176*8+:8]==accepted_action[224*8+:8] &&
         p[184*8+:64]==accepted_action[232*8+:64] &&
         p[192*8+:32]!=0 && p[196*8+:24]==accepted_action[225*8+:24] &&
         p[199*8+:8]==0 && p[200*8+:16]==accepted_action[11*8+:16] &&
         p[202*8+:8]==255 && p[203*8+:8]==0 && p[204*8+:16]==0 &&
         p[206*8+:16]==guard_key[82*8+:16] && p[208*8+:16]==1024 &&
         p[210*8+:8]==1 && p[211*8+:45*8]==0 &&
         p[164*8+:32]!=0 && p[168*8+:32]>=p[164*8+:32] &&
         p[168*8+:32]-p[164*8+:32]+1==p[172*8+:16] && p[172*8+:16]==
          guard_key[80*8+:16]*((guard_key[82*8+:16]+15)/16)));
  endfunction

  assign base_change_ready=!guard_active && physical_safe && !producer_active && read_debt==0;
  assign action_ready=guard_active && proof_valid && source_still_matches &&
    live_base_matches && !cancel && !cancel_seen && !action_active &&
    !protocol_error && action_bound(action_request);
  assign producer_ready=guard_active && proof_valid && action_active &&
    source_still_matches && live_base_matches && !cancel && !cancel_seen &&
    !producer_active && read_debt==0 && !protocol_error && producer_bound(producer_request);
  assign source_ar_allowed=guard_active && producer_active && source_still_matches &&
    live_base_matches && !protocol_error && read_debt==0 && source_arsize==6 &&
    source_arburst==1 && source_araddr[5:0]==0 && source_araddr>=read_first &&
    source_araddr<=64'hffffffffffffffff-(64'(source_arlen)+1)*64 &&
    source_araddr+(64'(source_arlen)+1)*64<=read_after;

  always_ff @(posedge clk)begin : state
    logic [2047:0] complete;
    if(!rst_n)begin
      guard_active<=0;proof_valid<=0;guard_key<=0;cancel_seen<=0;
      producer_active<=0;action_active<=0;protocol_error<=0;read_debt<=0;
      accepted_action<=0;completion_packet<=0;completion_beat<=0;
      producer_completion_beat<=0;action_safe_consumed<=0;proof_rejected<=0;read_first<=0;read_after<=0;
    end else begin
      if(snapshot_accept)begin
        if(guard_active || !physical_safe || read_debt!=0)protocol_error<=1;
        else begin
          guard_active<=1;guard_key<=snapshot_request;proof_valid<=0;
          cancel_seen<=0;action_safe_consumed<=0;proof_rejected<=0;
        end
      end
      if(cancel && guard_active)cancel_seen<=1;
      if(proof_consumed && guard_active && !proof_valid)begin
        if(snapshot_bound(snapshot_response) && source_still_matches && live_base_matches &&
           !cancel && !cancel_seen)proof_valid<=1;
        else proof_rejected<=1;
      end
      if(action_valid && action_ready)begin
        accepted_action<=action_request;action_active<=1;action_safe_consumed<=0;
        completion_beat<=0;
      end
      if(producer_valid && producer_ready)begin
        producer_active<=1;producer_completion_beat<=0;
        read_first<=live_base_address+producer_request[608*8+:64];
        read_after<=live_base_address+producer_request[608*8+:64]+
          64'(producer_request[159*8+:8])*4096;
      end
      if(producer_completion_empty_n && producer_completion_read)begin
        if(!producer_active)protocol_error<=1;
        else if(producer_completion_beat==7)begin
          producer_completion_beat<=0;producer_active<=0;
        end else producer_completion_beat<=producer_completion_beat+1'b1;
      end
      if(action_completion_empty_n && action_completion_read)begin
        complete=completion_packet;
        complete[completion_beat*512+:512]=action_completion_dout;
        completion_packet<=complete;
        if(!action_active)protocol_error<=1;
        else if(completion_beat==3)begin
          completion_beat<=0;
          if(safe_completion(complete))action_safe_consumed<=1;
          // A bound nonterminal or invalid completion gives no release proof.
        end else completion_beat<=completion_beat+1'b1;
      end
      if(r_pop && (read_debt==0 || source_rlast!=(read_debt==1) || source_rresp!=0))
        protocol_error<=1;
      case({ar_pop,r_pop})
        2'b10:read_debt<=32'(source_arlen)+1;
        2'b01:if(read_debt!=0)read_debt<=read_debt-1'b1;
        2'b11:read_debt<=read_debt+32'(source_arlen);
        default:;
      endcase
      if(guard_active && !action_active && !producer_active && read_debt==0 &&
         physical_safe && !snapshot_response_valid && (proof_rejected || cancel_seen))begin
        guard_active<=0;proof_valid<=0;proof_rejected<=0;
      end
      if(guard_active && proof_valid && action_safe_consumed && physical_safe &&
         !producer_active && read_debt==0 && !source_arvalid && !protocol_error)begin
        guard_active<=0;proof_valid<=0;action_active<=0;action_safe_consumed<=0;
      end
    end
  end
endmodule
