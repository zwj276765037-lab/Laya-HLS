`timescale 1ns/1ps
// Eight reserved burst slots. All 8*16*64 payload bytes remain reserved until
// ordered parser consumption, not merely until the last R handshake.
module laya_m007_w_reader_v1(
 input logic clk,rst,start,
 input logic [63:0] start_addr,
 input logic [31:0] byte_count,
 output logic arvalid,input logic arready,output logic [63:0] araddr,
 output logic [2:0] arid,output logic [7:0] arlen,
 input logic rvalid,output logic rready,input logic [2:0] rid,
 input logic [511:0] rdata,input logic [1:0] rresp,input logic rlast,
 output logic out_valid,input logic out_ready,output logic [511:0] out_data,
 output logic done,output logic [1:0] errors,
 output logic [3:0] inflight,peak_inflight,
 output logic [31:0] accepted_ar,accepted_r
);
 (* ram_style="block" *) logic [511:0] payload[0:127];
 logic [7:0] busy,complete;
 logic [4:0] wanted[0:7],received[0:7];
 logic [2:0] issue_slot,drain_slot;
 logic [4:0] drain_beat;
 logic active,out_last;logic [2:0] out_slot;logic [63:0] next_addr;logic [31:0] remaining;
 logic [4:0] issue_beats;logic [6:0] page_beats;
 integer i;integer live;
 always_comb begin
  page_beats=(4096-{1'b0,next_addr[11:0]})>>6;
  issue_beats=16;
  if (remaining<1024)issue_beats=remaining>>6;
  if (page_beats<issue_beats)issue_beats=page_beats;
  arvalid=active && remaining!=0 && !busy[issue_slot];
  araddr=next_addr;arid=issue_slot;arlen=issue_beats-1;
  rready=active;
  live=0;for(integer j=0;j<8;j=j+1)if(busy[j]&&!complete[j])live=live+1;
  inflight=live;
 end
 always_ff @(posedge clk)begin
  if(rst)begin
   active<=0;busy<=0;complete<=0;issue_slot<=0;drain_slot<=0;drain_beat<=0;
   next_addr<=0;remaining<=0;done<=0;errors<=0;peak_inflight<=0;accepted_ar<=0;accepted_r<=0;out_valid<=0;out_last<=0;out_slot<=0;
   for(i=0;i<8;i=i+1)begin wanted[i]<=0;received[i]<=0;end
  end else begin
   done<=0;
   if(start)begin
    active<=1;busy<=0;complete<=0;issue_slot<=0;drain_slot<=0;drain_beat<=0;
    next_addr<=start_addr;remaining<=byte_count;errors<=0;peak_inflight<=0;accepted_ar<=0;accepted_r<=0;out_valid<=0;out_last<=0;out_slot<=0;
    for(i=0;i<8;i=i+1)begin wanted[i]<=0;received[i]<=0;end
   end else if(active)begin
    if(inflight>peak_inflight)peak_inflight<=inflight;
    if(arvalid&&arready)begin
     busy[issue_slot]<=1;complete[issue_slot]<=0;wanted[issue_slot]<=issue_beats;received[issue_slot]<=0;
     issue_slot<=issue_slot+1;next_addr<=next_addr+64*issue_beats;remaining<=remaining-64*issue_beats;accepted_ar<=accepted_ar+1;
    end
    if(rvalid&&rready)begin
     accepted_r<=accepted_r+1;
     if(rresp!=0)errors[0]<=1;
     if(!busy[rid]||complete[rid]||received[rid]>=wanted[rid])errors[1]<=1;
     else begin
      payload[{rid,4'b0}+received[rid]]<=rdata;
      received[rid]<=received[rid]+1;
      if(rlast!=(received[rid]+1==wanted[rid]))errors[1]<=1;
      if(received[rid]+1==wanted[rid])complete[rid]<=1;
     end
    end
    if(out_valid&&out_ready)begin
     out_valid<=0;
     if(out_last)begin busy[out_slot]<=0;complete[out_slot]<=0;end
    end
    // The synchronous read output is one extra 64B register; the source burst
    // reservation remains busy until its last registered word is consumed.
    if((!out_valid||out_ready)&&busy[drain_slot]&&complete[drain_slot])begin
     out_data<=payload[{drain_slot,4'b0}+drain_beat];out_valid<=1;
     out_slot<=drain_slot;out_last<=(drain_beat+1==wanted[drain_slot]);
     if(drain_beat+1==wanted[drain_slot])begin drain_slot<=drain_slot+1;drain_beat<=0;end
     else drain_beat<=drain_beat+1;
    end
    if(remaining==0 && busy==0 && !out_valid)begin active<=0;done<=1;end
   end
  end
 end
endmodule
