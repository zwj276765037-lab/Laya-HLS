`timescale 1ns/1ps
module laya_m007_w_supply_v2(
 input logic clk,rst,
 input logic load_valid,output logic load_ready,
 input logic [31:0] load_version,input logic [63:0] load_model,
 input logic [31:0] load_tensor,input logic [63:0] load_request,input logic [31:0] load_generation,
 input logic [15:0] load_k,load_n,load_s,input logic load_slot,
 input logic [3:0][63:0] load_base,load_span,
 output logic load_rsp_valid,input logic load_rsp_ready,output logic [2:0] load_status,
 output logic [31:0] rsp_version,output logic [63:0] rsp_model,
 output logic [31:0] rsp_tensor,output logic [63:0] rsp_request,output logic [31:0] rsp_generation,
 output logic [15:0] rsp_k,rsp_n,rsp_s,output logic rsp_slot,
 output logic [3:0][63:0] rsp_base,rsp_span,
 output logic [15:0] error_n,error_g,output logic [31:0] load_cycles,
 output logic [3:0] arvalid,input logic [3:0] arready,
 output logic [3:0][63:0] araddr,output logic [3:0][2:0] arid,output logic [3:0][7:0] arlen,
 input logic [3:0] rvalid,output logic [3:0] rready,input logic [3:0][2:0] rid,
 input logic [3:0][511:0] rdata,input logic [3:0][1:0] rresp,input logic [3:0] rlast,
 output logic [3:0][3:0] peak_inflight,
 output logic [3:0][31:0] accepted_ar,accepted_r,
 input logic lease_valid,input logic lease_slot,output logic lease_ready,
 input logic [63:0] lease_model,lease_request,input logic [31:0] lease_tensor,lease_generation,
 input logic rd_valid,output logic rd_ready,input logic rd_slot,input logic [8:0] rd_addr,input logic [63:0] rd_tag,
 input logic [63:0] rd_model,rd_request,input logic [31:0] rd_tensor,rd_generation,
 output logic rd_rsp_valid,input logic rd_rsp_ready,output logic [4351:0] rd_rsp_data,
 output logic [63:0] rd_rsp_tag,output logic rd_rsp_slot,
 input logic ret_valid,input logic ret_slot,input logic [63:0] ret_tag,ret_request,input logic [31:0] ret_generation,
 output logic ret_ready,
 input logic release_valid,input logic release_slot,input logic [63:0] release_request,input logic [31:0] release_generation,
 output logic release_ready,output logic [1:0] slot_valid,slot_leased,
 output logic transport_idle
);
 logic [3:0] reader_idle;
 logic loading,start_readers;logic [7:0] groups;
 logic [3:0][63:0] begin_addr;
 logic [31:0] stream_bytes;
 logic [3:0] stream_valid,stream_ready,reader_done,finished;
 logic [3:0][511:0] stream_data;
 logic [3:0][1:0] reader_errors;
 logic [3:0][3:0] inflight;
 logic [3:0][3:0] beat;
 logic [3:0][4095:0] qassembly;
 logic [3:0][7:0] group_index;
 logic [511:0] coverage;logic [9:0] covered;
 logic pad_error,numeric_error,coverage_error;
 logic [1:0] rr,selected;logic commit;
 logic [8:0] commit_addr;
 logic [1:0][63:0] slot_model,slot_request;logic [1:0][31:0] slot_tensor,slot_generation;
 logic [1:0][7:0] slot_groups;
 logic [1:0][4095:0] bank_q;logic [1:0][255:0] bank_s;
 logic read_pending,borrowed,pending_slot;logic [63:0] pending_tag;
 logic descriptor_ok;logic [63:0] offset_bytes,required_end,matrix_bytes;
 logic [64:0] wide_end;logic [1:0] aggregate_error;
 integer i,c,j;integer cand;integer col;
 assign transport_idle=!rst&&!loading&&!start_readers&&!load_rsp_valid&&(&reader_idle)&&!read_pending&&!rd_rsp_valid&&!borrowed&&slot_leased==0&&stream_valid==0&&arvalid==0;
 always_comb begin
  offset_bytes=64'(load_s)*64'(load_k>>5)*576;
  required_end=offset_bytes+64'(load_k>>5)*576;
  matrix_bytes=64'(load_k>>5)*576*((load_n==5248)?82:(load_n>>6));
  descriptor_ok=load_version==1 && ((load_k==1024&&(load_n==3072||load_n==1024||load_n==5248||load_n==4096))||(load_n==1024&&(load_k==2624||load_k==4096)));
  if(load_s>=((load_n==5248)?82:(load_n>>6)))descriptor_ok=0;
  for(integer p=0;p<4;p=p+1)begin
   wide_end={1'b0,load_base[p]}+{1'b0,load_span[p]};
   if(load_base[p][11:0]!=0||load_span[p]<required_end||load_span[p]<matrix_bytes||wide_end[64])descriptor_ok=0;
  end
  load_ready=!loading&&!load_rsp_valid&&!(lease_valid&&lease_slot==load_slot)&&!slot_leased[load_slot]&&!(read_pending&&pending_slot==load_slot)&&!(rd_rsp_valid&&rd_rsp_slot==load_slot)&&!(borrowed&&rd_rsp_slot==load_slot);
  commit=0;selected=rr;
  for(integer t=3;t>=0;t=t-1)begin
   cand=(rr+t)&3;
   if(stream_valid[cand]&&beat[cand]==8)begin commit=1;selected=cand;end
  end
  commit_addr={group_index[selected][6:0],selected};
  for(integer p=0;p<4;p=p+1)stream_ready[p]=loading&&((beat[p]!=8)||(commit&&selected==p));
  aggregate_error=0;for(integer p=0;p<4;p=p+1)aggregate_error=aggregate_error|reader_errors[p];
  lease_ready=slot_valid[lease_slot]&&!slot_leased[lease_slot]&&slot_model[lease_slot]==lease_model&&slot_tensor[lease_slot]==lease_tensor&&slot_request[lease_slot]==lease_request&&slot_generation[lease_slot]==lease_generation;
  rd_ready=slot_valid[rd_slot]&&slot_leased[rd_slot]&&!read_pending&&!rd_rsp_valid&&!borrowed&&rd_addr<({2'b0,slot_groups[rd_slot]}<<2)&&slot_model[rd_slot]==rd_model&&slot_tensor[rd_slot]==rd_tensor&&slot_request[rd_slot]==rd_request&&slot_generation[rd_slot]==rd_generation;
  ret_ready=borrowed&&ret_slot==rd_rsp_slot&&ret_tag==rd_rsp_tag&&ret_request==slot_request[ret_slot]&&ret_generation==slot_generation[ret_slot];
  release_ready=slot_leased[release_slot]&&release_request==slot_request[release_slot]&&release_generation==slot_generation[release_slot]&&!(rd_valid&&rd_ready&&rd_slot==release_slot)&&!(read_pending&&pending_slot==release_slot)&&!(rd_rsp_valid&&rd_rsp_slot==release_slot)&&!(borrowed&&rd_rsp_slot==release_slot);
 end
 generate for(genvar p=0;p<4;p=p+1)begin:ports
  laya_m007_w_reader_v2 reader(.transport_idle(reader_idle[p]),.clk,.rst,.start(start_readers),.start_addr(begin_addr[p]),.byte_count(stream_bytes),.arvalid(arvalid[p]),.arready(arready[p]),.araddr(araddr[p]),.arid(arid[p]),.arlen(arlen[p]),.rvalid(rvalid[p]),.rready(rready[p]),.rid(rid[p]),.rdata(rdata[p]),.rresp(rresp[p]),.rlast(rlast[p]),.out_valid(stream_valid[p]),.out_ready(stream_ready[p]),.out_data(stream_data[p]),.done(reader_done[p]),.errors(reader_errors[p]),.inflight(inflight[p]),.peak_inflight(peak_inflight[p]),.accepted_ar(accepted_ar[p]),.accepted_r(accepted_r[p]));
 end
 for(genvar sl=0;sl<2;sl=sl+1)begin:slots
  for(genvar b=0;b<16;b=b+1)begin:banks
   laya_m007_w_bank_v1 bank(.clk,.we(loading&&commit&&rsp_slot==sl),.waddr(commit_addr),.wq(qassembly[selected][256*b+:256]),.ws(stream_data[selected][16*b+:16]),.re(rd_valid&&rd_ready&&rd_slot==sl),.raddr(rd_addr),.rq(bank_q[sl][256*b+:256]),.rs(bank_s[sl][16*b+:16]));
  end
 end endgenerate
 always_ff @(posedge clk)begin
  if(rst)begin
   loading<=0;start_readers<=0;load_rsp_valid<=0;load_status<=0;slot_valid<=0;slot_leased<=0;
   rsp_version<=0;rsp_model<=0;rsp_tensor<=0;rsp_request<=0;rsp_generation<=0;rsp_k<=0;rsp_n<=0;rsp_s<=0;rsp_slot<=0;rsp_base<=0;rsp_span<=0;
   groups<=0;begin_addr<=0;stream_bytes<=0;beat<=0;group_index<=0;finished<=0;coverage<=0;covered<=0;rr<=0;pad_error<=0;numeric_error<=0;coverage_error<=0;error_n<=0;error_g<=0;load_cycles<=0;
   slot_model<=0;slot_tensor<=0;slot_request<=0;slot_generation<=0;slot_groups<=0;
   read_pending<=0;rd_rsp_valid<=0;borrowed<=0;pending_slot<=0;pending_tag<=0;rd_rsp_tag<=0;rd_rsp_slot<=0;
  end else begin
   start_readers<=0;
   if(load_rsp_valid&&load_rsp_ready)load_rsp_valid<=0;
   if(load_valid&&load_ready)begin
    rsp_version<=load_version;rsp_model<=load_model;rsp_tensor<=load_tensor;rsp_request<=load_request;rsp_generation<=load_generation;rsp_k<=load_k;rsp_n<=load_n;rsp_s<=load_s;rsp_slot<=load_slot;rsp_base<=load_base;rsp_span<=load_span;
    slot_valid[load_slot]<=0;load_cycles<=0;load_status<=0;error_n<=0;error_g<=0;
    if(!descriptor_ok)begin load_rsp_valid<=1;load_status<=1;end
    else begin
     loading<=1;start_readers<=1;groups<=load_k>>5;stream_bytes<=(load_k>>5)*576;
     for(i=0;i<4;i=i+1)begin begin_addr[i]<=load_base[i]+offset_bytes;end
     beat<=0;group_index<=0;finished<=0;coverage<=0;covered<=0;rr<=0;pad_error<=0;numeric_error<=0;coverage_error<=0;
     slot_model[load_slot]<=load_model;slot_tensor[load_slot]<=load_tensor;slot_request[load_slot]<=load_request;slot_generation[load_slot]<=load_generation;slot_groups[load_slot]<=load_k>>5;
    end
   end
   if(loading)begin
    load_cycles<=load_cycles+1;finished<=finished|reader_done;
    for(i=0;i<4;i=i+1)if(stream_valid[i]&&stream_ready[i])begin
     if(beat[i]<8)begin qassembly[i][512*beat[i]+:512]<=stream_data[i];beat[i]<=beat[i]+1;end
     else begin
      beat[i]<=0;group_index[i]<=group_index[i]+1;rr<=i+1;
      if(group_index[i]>=groups||coverage[commit_addr])coverage_error<=1;
      else begin coverage[commit_addr]<=1;covered<=covered+1;end
      if(stream_data[i][511:256]!=0)pad_error<=1;
      for(c=0;c<16;c=c+1)if(stream_data[i][16*c+10+:5]==5'b11111)begin
       if(!numeric_error)begin
        error_g<=group_index[i];
        if(rsp_n==5248)error_n<=32*rsp_s+16*(i%2)+c+((i>=2)?2624:0);
        else error_n<=64*rsp_s+16*i+c;
       end
       numeric_error<=1;
      end
     end
    end
    if(&(finished|reader_done))begin
     loading<=0;load_rsp_valid<=1;
     if(aggregate_error[0])load_status<=2;
     else if(aggregate_error[1]||pad_error||coverage_error||covered!=4*groups||beat!=0)load_status<=3;
     else if(numeric_error)load_status<=4;
     else begin load_status<=0;slot_valid[rsp_slot]<=1;end
    end
   end
   if(lease_valid&&lease_ready)slot_leased[lease_slot]<=1;
   if(release_valid&&release_ready)slot_leased[release_slot]<=0;
   if(rd_valid&&rd_ready)begin read_pending<=1;pending_slot<=rd_slot;pending_tag<=rd_tag;end
   if(read_pending)begin read_pending<=0;rd_rsp_valid<=1;rd_rsp_slot<=pending_slot;rd_rsp_tag<=pending_tag;rd_rsp_data<={bank_s[pending_slot],bank_q[pending_slot]};end
   if(rd_rsp_valid&&rd_rsp_ready)begin rd_rsp_valid<=0;borrowed<=1;end
   if(ret_valid&&ret_ready)borrowed<=0;
  end
 end
endmodule
