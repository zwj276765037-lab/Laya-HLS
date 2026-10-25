`timescale 1ns/1ps
// Two complete A slots, 16 real synchronous banks each. Payload never resets.
// Read/return has64 bounded metadata reservations and supports one record/cycle.
module laya_m007_a_cache_v1(
 input logic clk,rst_n,
 input logic cfg_valid,output logic cfg_ready,input logic cfg_slot,input logic [15:0] cfg_k,
 input logic [63:0] cfg_request,input logic [31:0] cfg_generation,cfg_epoch,
 output logic cfg_rsp_valid,input logic cfg_rsp_ready,output logic [1:0] cfg_status,
 output logic cfg_rsp_slot,output logic [15:0] cfg_rsp_k,output logic [63:0] cfg_rsp_request,
 output logic [31:0] cfg_rsp_generation,cfg_rsp_epoch,output logic [6:0] error_row,error_group,
 input logic wr_valid,output logic wr_ready,input logic [6:0] wr_row,wr_group,input logic [271:0] wr_data,
 input logic [63:0] wr_request,input logic [31:0] wr_generation,wr_epoch,
 output logic wr_rsp_valid,input logic wr_rsp_ready,output logic [6:0] wr_rsp_row,wr_rsp_group,
 input logic lease_valid,output logic lease_ready,input logic lease_slot,input logic [63:0] lease_request,input logic [31:0] lease_generation,lease_epoch,
 input logic rd_valid,output logic rd_ready,input logic rd_slot,input logic [2:0] rd_m,input logic [6:0] rd_group,input logic [95:0] rd_tag,
 input logic [63:0] rd_request,input logic [31:0] rd_generation,rd_epoch,
 output logic rd_rsp_valid,input logic rd_rsp_ready,output logic rd_rsp_slot,output logic [95:0] rd_rsp_tag,output logic [4351:0] rd_rsp_data,
 input logic ret_valid,output logic ret_ready,input logic ret_slot,input logic [95:0] ret_tag,input logic [63:0] ret_request,input logic [31:0] ret_generation,ret_epoch,
 input logic release_valid,output logic release_ready,input logic release_slot,input logic [63:0] release_request,input logic [31:0] release_generation,release_epoch,
 output logic [1:0] slot_valid,slot_leased,output logic [6:0] read_debt
);
 logic filling;logic [7:0] groups;logic [14:0] fill_count,target_count;
 logic [16383:0] coverage;logic bad_numeric,bad_duplicate;logic [13:0] bad_index;
 logic [1:0][63:0] request_id;logic [1:0][31:0] generation,epoch;
 logic [1:0][7:0] slot_groups;logic [1:0][6:0] slot_debt;
 logic [1:0][4095:0] qout;logic [1:0][255:0] sout;
 logic [63:0][95:0] return_tags;logic [63:0] return_slots;
 logic [5:0] head,tail;logic [6:0] consumed_debt;
 wire [13:0] write_index={wr_row,wr_group};
 wire write_fire=wr_valid&&wr_ready;
 wire read_fire=rd_valid&&rd_ready;
 wire rsp_fire=rd_rsp_valid&&rd_rsp_ready;
 wire ret_fire=ret_valid&&ret_ready;
 wire illegal_scale=(wr_data[270:266]==31)||(wr_data[271]&&wr_data[270:256]!=0);
 assign cfg_ready=rst_n&&!filling&&!cfg_rsp_valid&&!wr_rsp_valid&&!slot_leased[cfg_slot]&&slot_debt[cfg_slot]==0&&!(lease_valid&&lease_slot==cfg_slot);
 assign wr_ready=rst_n&&filling&&fill_count<target_count&&(!wr_rsp_valid||wr_rsp_ready)&&wr_group<groups&&wr_request==cfg_rsp_request&&wr_generation==cfg_rsp_generation&&wr_epoch==cfg_rsp_epoch;
 assign lease_ready=rst_n&&slot_valid[lease_slot]&&!slot_leased[lease_slot]&&!(cfg_rsp_valid&&cfg_rsp_slot==lease_slot)&&lease_request==request_id[lease_slot]&&lease_generation==generation[lease_slot]&&lease_epoch==epoch[lease_slot];
 assign rd_ready=rst_n&&slot_valid[rd_slot]&&slot_leased[rd_slot]&&read_debt<64&&(!rd_rsp_valid||rd_rsp_ready)&&rd_group<slot_groups[rd_slot]&&rd_request==request_id[rd_slot]&&rd_generation==generation[rd_slot]&&rd_epoch==epoch[rd_slot];
 assign rd_rsp_data={sout[rd_rsp_slot],qout[rd_rsp_slot]};
 assign ret_ready=rst_n&&consumed_debt!=0&&return_slots[tail]==ret_slot&&return_tags[tail]==ret_tag&&ret_request==request_id[ret_slot]&&ret_generation==generation[ret_slot]&&ret_epoch==epoch[ret_slot];
 assign release_ready=rst_n&&slot_leased[release_slot]&&slot_debt[release_slot]==0&&!(read_fire&&rd_slot==release_slot)&&release_request==request_id[release_slot]&&release_generation==generation[release_slot]&&release_epoch==epoch[release_slot];
 generate for(genvar sl=0;sl<2;sl++)begin:slots
  for(genvar b=0;b<16;b++)begin:banks
   laya_m007_a_bank_v1 bank(.clk,.we(write_fire&&cfg_rsp_slot==sl&&wr_row[3:0]==b),.waddr({wr_row[6:4],wr_group}),.wq(wr_data[255:0]),.ws(wr_data[271:256]),.re(read_fire&&rd_slot==sl),.raddr({rd_m,rd_group}),.rq(qout[sl][256*b+:256]),.rs(sout[sl][16*b+:16]));
  end
 end endgenerate
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   filling<=0;groups<=0;fill_count<=0;target_count<=0;coverage<=0;bad_numeric<=0;bad_duplicate<=0;bad_index<=0;
   cfg_rsp_valid<=0;cfg_status<=0;cfg_rsp_slot<=0;cfg_rsp_k<=0;cfg_rsp_request<=0;cfg_rsp_generation<=0;cfg_rsp_epoch<=0;error_row<=0;error_group<=0;
   wr_rsp_valid<=0;wr_rsp_row<=0;wr_rsp_group<=0;slot_valid<=0;slot_leased<=0;request_id<=0;generation<=0;epoch<=0;slot_groups<=0;slot_debt<=0;
   rd_rsp_valid<=0;rd_rsp_slot<=0;rd_rsp_tag<=0;read_debt<=0;consumed_debt<=0;head<=0;tail<=0;
  end else begin
   if(cfg_rsp_valid&&cfg_rsp_ready)cfg_rsp_valid<=0;
   if(wr_rsp_valid&&wr_rsp_ready)wr_rsp_valid<=0;
   if(cfg_valid&&cfg_ready)begin
    cfg_rsp_slot<=cfg_slot;cfg_rsp_k<=cfg_k;cfg_rsp_request<=cfg_request;cfg_rsp_generation<=cfg_generation;cfg_rsp_epoch<=cfg_epoch;cfg_status<=0;
    slot_valid[cfg_slot]<=0;coverage<=0;fill_count<=0;bad_numeric<=0;bad_duplicate<=0;error_row<=0;error_group<=0;bad_index<=0;
    if(cfg_k!=1024&&cfg_k!=2624&&cfg_k!=4096)begin cfg_rsp_valid<=1;cfg_status<=1;end
    else begin filling<=1;groups<=cfg_k>>5;target_count<=128*(cfg_k>>5);request_id[cfg_slot]<=cfg_request;generation[cfg_slot]<=cfg_generation;epoch[cfg_slot]<=cfg_epoch;slot_groups[cfg_slot]<=cfg_k>>5;end
   end
   if(write_fire)begin
    wr_rsp_valid<=1;wr_rsp_row<=wr_row;wr_rsp_group<=wr_group;
    if(coverage[write_index])bad_duplicate<=1;
    else begin coverage[write_index]<=1;fill_count<=fill_count+1;end
    if(illegal_scale)begin
     bad_numeric<=1;
     if(!bad_numeric||write_index<bad_index)begin bad_index<=write_index;error_row<=wr_row;error_group<=wr_group;end
    end
   end
   if(filling&&fill_count==target_count&&!wr_rsp_valid)begin
    filling<=0;cfg_rsp_valid<=1;
    if(bad_duplicate)cfg_status<=3;
    else if(bad_numeric)cfg_status<=2;
    else begin cfg_status<=0;slot_valid[cfg_rsp_slot]<=1;end
   end
   if(lease_valid&&lease_ready)slot_leased[lease_slot]<=1;
   if(release_valid&&release_ready)slot_leased[release_slot]<=0;
   if(!rd_rsp_valid||rd_rsp_ready)begin
    rd_rsp_valid<=read_fire;
    if(read_fire)begin rd_rsp_slot<=rd_slot;rd_rsp_tag<=rd_tag;end
   end
   if(read_fire)begin return_tags[head]<=rd_tag;return_slots[head]<=rd_slot;head<=head+1;end
   if(ret_fire)tail<=tail+1;
   case({read_fire,ret_fire})2'b10:read_debt<=read_debt+1;2'b01:read_debt<=read_debt-1;default:;endcase
   case({rsp_fire,ret_fire})2'b10:consumed_debt<=consumed_debt+1;2'b01:consumed_debt<=consumed_debt-1;default:;endcase
   for(integer sl=0;sl<2;sl++)begin
    case({read_fire&&rd_slot==sl,ret_fire&&ret_slot==sl})2'b10:slot_debt[sl]<=slot_debt[sl]+1;2'b01:slot_debt[sl]<=slot_debt[sl]-1;default:;endcase
   end
  end
 end
endmodule
