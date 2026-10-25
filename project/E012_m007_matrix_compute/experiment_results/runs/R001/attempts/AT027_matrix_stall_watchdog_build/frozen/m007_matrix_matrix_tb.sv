`timescale 1ns/1ps
module m007_matrix_matrix_tb;
 logic clk,rst_n;
 logic cmd_valid;
 logic cmd_ready;
 logic [63:0] cmd_request,cmd_model;
 logic [31:0] cmd_generation,cmd_epoch,cmd_tensor;
 logic [15:0] cmd_k,cmd_n,cmd_s;
 logic cmd_a_slot,cmd_w_slot,cmd_ctx,cmd_bias;
 logic [63:0][31:0] cmd_bias_data;
 logic run_enable;
 logic done_valid;
 logic done_ready;
 logic [2:0] status;
 logic [63:0] done_request;
 logic [31:0] done_generation;
 logic [6:0] error_row;
 logic [15:0] error_col;
 logic [7:0] error_group;
 logic [31:0] elapsed_cycles;
 logic [31:0] first_issue_cycle,last_issue_cycle,last_output_cycle,max_issue_commit,max_ps_feedback,output_bubbles;
 logic out_valid;
 logic out_ready;
 logic [31:0][31:0] out_data;
 logic [6:0] out_row;
 logic out_half;
 logic a_complete;
 logic a_complete_slot;
 logic [1:0] a_complete_status;
 logic [15:0] a_complete_k;
 logic [63:0] a_complete_request;
 logic [31:0] a_complete_generation,a_complete_epoch;
 logic w_complete;
 logic w_complete_slot;
 logic [2:0] w_complete_status;
 logic [15:0] w_complete_k,w_complete_n,w_complete_s;
 logic [63:0] w_complete_request,w_complete_model;
 logic [31:0] w_complete_generation,w_complete_tensor;
 logic a_lease_valid;
 logic a_lease_ready;
 logic a_lease_slot;
 logic [63:0] a_lease_request;
 logic [31:0] a_lease_generation,a_lease_epoch;
 logic a_rd_valid;
 logic a_rd_ready;
 logic a_rd_slot;
 logic [2:0] a_rd_m;
 logic [6:0] a_rd_group;
 logic [95:0] a_rd_tag;
 logic [63:0] a_rd_request;
 logic [31:0] a_rd_generation,a_rd_epoch;
 logic a_rsp_valid;
 logic a_rsp_ready;
 logic [4351:0] a_rsp_data;
 logic [95:0] a_rsp_tag;
 logic a_rsp_slot;
 logic a_ret_valid;
 logic a_ret_ready;
 logic a_ret_slot;
 logic [95:0] a_ret_tag;
 logic [63:0] a_ret_request;
 logic [31:0] a_ret_generation,a_ret_epoch;
 logic a_release_valid;
 logic a_release_ready;
 logic a_release_slot;
 logic [63:0] a_release_request;
 logic [31:0] a_release_generation,a_release_epoch;
 logic w_lease_valid;
 logic w_lease_ready;
 logic w_lease_slot;
 logic [63:0] w_lease_request,w_lease_model;
 logic [31:0] w_lease_generation,w_lease_tensor;
 logic w_rd_valid;
 logic w_rd_ready;
 logic w_rd_slot;
 logic [8:0] w_rd_addr;
 logic [63:0] w_rd_tag;
 logic [63:0] w_rd_request,w_rd_model;
 logic [31:0] w_rd_generation,w_rd_tensor;
 logic w_rsp_valid;
 logic w_rsp_ready;
 logic [4351:0] w_rsp_data;
 logic [63:0] w_rsp_tag;
 logic w_rsp_slot;
 logic w_ret_valid;
 logic w_ret_ready;
 logic w_ret_slot;
 logic [63:0] w_ret_tag,w_ret_request;
 logic [31:0] w_ret_generation;
 logic w_release_valid;
 logic w_release_ready;
 logic w_release_slot;
 logic [63:0] w_release_request;
 logic [31:0] w_release_generation;
 logic trace_issue;
 logic [12:0] trace_issue_seq;
 logic [4095:0] trace_a_q,trace_w_q;
 logic [255:0] trace_a_scale,trace_w_scale;
 logic trace_dot;
 logic [12:0] trace_dot_seq;
 logic [255:0][20:0] trace_dot_data;
 logic trace_format;
 logic [12:0] trace_format_seq;
 logic [255:0][31:0] trace_scale_product,trace_converted;
 logic trace_term;
 logic [12:0] trace_term_seq;
 logic [255:0][31:0] trace_term_data;
 logic trace_commit;
 logic [12:0] trace_commit_seq;
 logic [255:0][31:0] trace_commit_data;
 logic [6:0] arithmetic_debt;
 logic [7:0] peak_return_reservations;
 always #1 clk=~clk;
 laya_m007_matrix_superblock_v1 core(.*);
 logic acfg_valid=0,acfg_ready,acfg_slot=0,acfg_rsp_valid,acfg_rsp_ready=0,acfg_rsp_slot;
 logic [15:0] acfg_k,acfg_rsp_k;logic [63:0] acfg_request,acfg_rsp_request;logic [31:0] acfg_generation,acfg_epoch,acfg_rsp_generation,acfg_rsp_epoch;logic [1:0] acfg_status;logic [6:0] ae_r,ae_g;
 logic awr_valid=0,awr_ready,awr_rsp_valid,awr_rsp_ready=1;logic [6:0] awr_row,awr_group,awr_rsp_row,awr_rsp_group;logic [271:0] awr_data;
 logic [1:0] a_slot_valid,a_slot_leased;logic [6:0] a_read_debt;
 assign a_complete=acfg_rsp_valid&&acfg_rsp_ready;assign a_complete_slot=acfg_rsp_slot;assign a_complete_status=acfg_status;assign a_complete_k=acfg_rsp_k;assign a_complete_request=acfg_rsp_request;assign a_complete_generation=acfg_rsp_generation;assign a_complete_epoch=acfg_rsp_epoch;
 laya_m007_a_cache_v1 a_cache(.clk,.rst_n,.cfg_valid(acfg_valid),.cfg_ready(acfg_ready),.cfg_slot(acfg_slot),.cfg_k(acfg_k),.cfg_request(acfg_request),.cfg_generation(acfg_generation),.cfg_epoch(acfg_epoch),.cfg_rsp_valid(acfg_rsp_valid),.cfg_rsp_ready(acfg_rsp_ready),.cfg_status(acfg_status),.cfg_rsp_slot(acfg_rsp_slot),.cfg_rsp_k(acfg_rsp_k),.cfg_rsp_request(acfg_rsp_request),.cfg_rsp_generation(acfg_rsp_generation),.cfg_rsp_epoch(acfg_rsp_epoch),.error_row(ae_r),.error_group(ae_g),
 .wr_valid(awr_valid),.wr_ready(awr_ready),.wr_row(awr_row),.wr_group(awr_group),.wr_data(awr_data),.wr_request(acfg_request),.wr_generation(acfg_generation),.wr_epoch(acfg_epoch),.wr_rsp_valid(awr_rsp_valid),.wr_rsp_ready(awr_rsp_ready),.wr_rsp_row(awr_rsp_row),.wr_rsp_group(awr_rsp_group),
 .lease_valid(a_lease_valid),.lease_ready(a_lease_ready),.lease_slot(a_lease_slot),.lease_request(a_lease_request),.lease_generation(a_lease_generation),.lease_epoch(a_lease_epoch),.rd_valid(a_rd_valid),.rd_ready(a_rd_ready),.rd_slot(a_rd_slot),.rd_m(a_rd_m),.rd_group(a_rd_group),.rd_tag(a_rd_tag),.rd_request(a_rd_request),.rd_generation(a_rd_generation),.rd_epoch(a_rd_epoch),.rd_rsp_valid(a_rsp_valid),.rd_rsp_ready(a_rsp_ready),.rd_rsp_slot(a_rsp_slot),.rd_rsp_tag(a_rsp_tag),.rd_rsp_data(a_rsp_data),
 .ret_valid(a_ret_valid),.ret_ready(a_ret_ready),.ret_slot(a_ret_slot),.ret_tag(a_ret_tag),.ret_request(a_ret_request),.ret_generation(a_ret_generation),.ret_epoch(a_ret_epoch),.release_valid(a_release_valid),.release_ready(a_release_ready),.release_slot(a_release_slot),.release_request(a_release_request),.release_generation(a_release_generation),.release_epoch(a_release_epoch),.slot_valid(a_slot_valid),.slot_leased(a_slot_leased),.read_debt(a_read_debt));
 logic wl_valid=0,wl_ready,wl_slot=0,wl_rsp_valid,wl_rsp_ready=0,wl_rsp_slot;
 logic [15:0] wl_k,wl_n,wl_s,wl_rsp_k,wl_rsp_n,wl_rsp_s,we_n,we_g;
 logic [31:0] wl_version=1,wl_tensor,wl_generation,wl_rsp_version,wl_rsp_tensor,wl_rsp_generation,wl_cycles;
 logic [63:0] wl_model,wl_request,wl_rsp_model,wl_rsp_request;
 logic [3:0][63:0] wl_base,wl_span,wl_rsp_base,wl_rsp_span;logic [2:0] wl_status;
 logic [3:0] arvalid,arready,rvalid,rready,rlast;logic [3:0][63:0] araddr;logic [3:0][2:0] arid,rid;logic [3:0][7:0] arlen;logic [3:0][511:0] rdata;logic [3:0][1:0] rresp;
 logic [3:0][3:0] w_peak;logic [3:0][31:0] w_ar_count,w_r_count;logic [1:0] w_slot_valid,w_slot_leased;
 logic real_w_rd_ready,real_w_rsp_valid,real_w_rsp_ready,w_allow=1,w_rsp_allow=1,protocol_corrupt=0;logic [63:0] real_w_rsp_tag;
 assign w_rsp_tag=real_w_rsp_tag^((protocol_corrupt&&real_w_rsp_tag[8:0]==6)?64'h0000000100000000:64'b0);
 assign w_rd_ready=real_w_rd_ready&&w_allow;assign w_rsp_valid=real_w_rsp_valid&&w_rsp_allow;assign real_w_rsp_ready=w_rsp_ready&&w_rsp_allow;
 assign w_complete=wl_rsp_valid&&wl_rsp_ready;assign w_complete_slot=wl_rsp_slot;assign w_complete_status=wl_status;assign w_complete_k=wl_rsp_k;assign w_complete_n=wl_rsp_n;assign w_complete_s=wl_rsp_s;assign w_complete_request=wl_rsp_request;assign w_complete_generation=wl_rsp_generation;assign w_complete_model=wl_rsp_model;assign w_complete_tensor=wl_rsp_tensor;
 laya_m007_w_supply_v1 w_cache(.clk,.rst(!rst_n),.load_valid(wl_valid),.load_ready(wl_ready),.load_version(wl_version),.load_model(wl_model),.load_tensor(wl_tensor),.load_request(wl_request),.load_generation(wl_generation),.load_k(wl_k),.load_n(wl_n),.load_s(wl_s),.load_slot(wl_slot),.load_base(wl_base),.load_span(wl_span),.load_rsp_valid(wl_rsp_valid),.load_rsp_ready(wl_rsp_ready),.load_status(wl_status),.rsp_version(wl_rsp_version),.rsp_model(wl_rsp_model),.rsp_tensor(wl_rsp_tensor),.rsp_request(wl_rsp_request),.rsp_generation(wl_rsp_generation),.rsp_k(wl_rsp_k),.rsp_n(wl_rsp_n),.rsp_s(wl_rsp_s),.rsp_slot(wl_rsp_slot),.rsp_base(wl_rsp_base),.rsp_span(wl_rsp_span),.error_n(we_n),.error_g(we_g),.load_cycles(wl_cycles),.arvalid,.arready,.araddr,.arid,.arlen,.rvalid,.rready,.rid,.rdata,.rresp,.rlast,.peak_inflight(w_peak),.accepted_ar(w_ar_count),.accepted_r(w_r_count),
 .lease_valid(w_lease_valid),.lease_slot(w_lease_slot),.lease_ready(w_lease_ready),.lease_model(w_lease_model),.lease_request(w_lease_request),.lease_tensor(w_lease_tensor),.lease_generation(w_lease_generation),.rd_valid(w_rd_valid&&w_allow),.rd_ready(real_w_rd_ready),.rd_slot(w_rd_slot),.rd_addr(w_rd_addr),.rd_tag(w_rd_tag),.rd_model(w_rd_model),.rd_request(w_rd_request),.rd_tensor(w_rd_tensor),.rd_generation(w_rd_generation),.rd_rsp_valid(real_w_rsp_valid),.rd_rsp_ready(real_w_rsp_ready),.rd_rsp_data(w_rsp_data),.rd_rsp_tag(real_w_rsp_tag),.rd_rsp_slot(w_rsp_slot),.ret_valid(w_ret_valid),.ret_slot(w_ret_slot),.ret_tag(w_ret_tag),.ret_request(w_ret_request),.ret_generation(w_ret_generation),.ret_ready(w_ret_ready),.release_valid(w_release_valid),.release_slot(w_release_slot),.release_request(w_release_request),.release_generation(w_release_generation),.release_ready(w_release_ready),.slot_valid(w_slot_valid),.slot_leased(w_slot_leased));
 logic [511:0] mem0[0:1151],mem1[0:1151],mem2[0:1151],mem3[0:1151];
 logic [7:0] live[0:3];logic [63:0] baddr[0:3][0:7];integer bsize[0:3][0:7],bpos[0:3][0:7],eligible[0:3][0:7],rotate[0:3],pick[0:3];logic [3:0][63:0] memory_start;
 logic [271:0] a_words[0:16383];logic [4351:0] a_records[0:1023],w_records[0:511];
 logic [8191:0] dot_gold[0:4095],cv_gold[0:4095],prod_gold[0:4095],term_gold[0:4095],partial_gold[0:4095];
 logic [1023:0] out_gold[0:255];logic [31:0] bias_gold[0:63];
 integer cycle=0,which=0,stress=0,gcount=32,issues=0,dot_checks=0,format_checks=0,term_checks=0,commit_checks=0,outputs=0,last_issue=-1,first_out=-1,last_out=-1,load_start=0,run_id=0;
 integer scenario=0,issue_pauses=0,w_request_stalls=0,w_response_stalls=0,output_holds=0;
 logic checking=0,error_run=0,out_stalled=0;logic [1023:0] held_out;logic [7:0] held_index;
 string fixture,casepath;
 function automatic logic [511:0] word(input integer p,idx);
  case(p)0:return mem0[idx];1:return mem1[idx];2:return mem2[idx];default:return mem3[idx];endcase
 endfunction
 always_comb begin
  arready=15;rvalid=0;rid=0;rdata=0;rresp=0;rlast=0;
  for(integer p=0;p<4;p++)begin
   pick[p]=-1;
   for(integer q=7;q>=0;q--)if(live[p][(rotate[p]+q)%8]&&cycle>=eligible[p][(rotate[p]+q)%8])pick[p]=(rotate[p]+q)%8;
   if(pick[p]>=0&&cycle%2==0)begin rvalid[p]=1;rid[p]=pick[p];rdata[p]=word(p,((baddr[p][pick[p]]-memory_start[p])>>6)+bpos[p][pick[p]]);rlast[p]=bpos[p][pick[p]]+1==bsize[p][pick[p]];end
  end
 end
 always @(posedge clk)begin
  cycle<=cycle+1;
  if(!rst_n)for(integer p=0;p<4;p++)begin live[p]<=0;rotate[p]<=0;end
  else for(integer p=0;p<4;p++)begin
   if(arvalid[p]&&arready[p])begin
    if(live[p][arid[p]]||arlen[p]>15||araddr[p][5:0]!=0||{1'b0,araddr[p][11:0]}+64*(arlen[p]+1)>4096)$fatal(1,"matrix real AXI ID/len/page");
    live[p][arid[p]]<=1;baddr[p][arid[p]]<=araddr[p];bsize[p][arid[p]]<=arlen[p]+1;bpos[p][arid[p]]<=0;eligible[p][arid[p]]<=cycle+40+2*(7-arid[p]);
   end
   if(rvalid[p]&&rready[p])begin if(bpos[p][rid[p]]+1==bsize[p][rid[p]])live[p][rid[p]]<=0;else bpos[p][rid[p]]<=bpos[p][rid[p]]+1;rotate[p]<=(rid[p]+1)%8;end
  end
  if(rst_n&&!checking&&trace_issue)$fatal(1,"arithmetic issued outside active validated command");
  if(rst_n)begin
   if(!run_enable&&a_slot_leased!=0)issue_pauses=issue_pauses+1;
   if(w_rd_valid&&!w_rd_ready)w_request_stalls=w_request_stalls+1;
   if(real_w_rsp_valid&&!real_w_rsp_ready)w_response_stalls=w_response_stalls+1;
   if(out_valid&&!out_ready)output_holds=output_holds+1;
   if(arithmetic_debt>64||peak_return_reservations>128)$fatal(1,"matrix global arithmetic/return credit");
  end
  if(checking&&rst_n&&error_run)begin
   if(trace_issue)issues=issues+1;
   if(trace_commit)commit_checks=commit_checks+1;
   if(out_valid)$fatal(1,"matrix error published partial output");
  end
  if(checking&&rst_n&&!error_run)begin
   if(trace_issue)begin
    if(trace_issue_seq!=issues||{trace_a_scale,trace_a_q}!==a_records[8*(issues/32)+(issues%8)]||{trace_w_scale,trace_w_q}!==w_records[issues/8])$fatal(1,"actual A/W issue mapping seq=%0d expected=%0d",trace_issue_seq,issues);
    if(!stress&&last_issue>=0&&cycle-last_issue!=1)$fatal(1,"MATRIX issue gap seq=%0d gap=%0d",issues,cycle-last_issue);last_issue=cycle;issues=issues+1;
   end
   if(trace_dot)begin
    if(trace_dot_seq!=dot_checks)$fatal(1,"dot order");
    for(integer lane=0;lane<256;lane++)if($signed(trace_dot_data[lane])!==$signed(dot_gold[dot_checks][32*lane+:32]))$fatal(1,"matrix dot seq=%0d lane=%0d got=%0d gold=%0d",dot_checks,lane,$signed(trace_dot_data[lane]),$signed(dot_gold[dot_checks][32*lane+:32]));dot_checks=dot_checks+1;
   end
   if(trace_format)begin
    if(trace_format_seq!=format_checks||trace_scale_product!==prod_gold[format_checks]||trace_converted!==cv_gold[format_checks])$fatal(1,"matrix exact format seq=%0d expected=%0d product0=%h gold0=%h converted0=%h cvgold0=%h",trace_format_seq,format_checks,trace_scale_product[0],prod_gold[format_checks][31:0],trace_converted[0],cv_gold[format_checks][31:0]);format_checks=format_checks+1;
   end
   if(trace_term)begin if(trace_term_seq!=term_checks||trace_term_data!==term_gold[term_checks])$fatal(1,"matrix shared multiply term seq=%0d gold=%0d got0=%h gold0=%h",trace_term_seq,term_checks,trace_term_data[0],term_gold[term_checks][31:0]);term_checks=term_checks+1;end
   if(trace_commit)begin if(trace_commit_seq!=commit_checks||trace_commit_data!==partial_gold[commit_checks])$fatal(1,"matrix real PS ack seq=%0d gold=%0d got0=%h gold0=%h",trace_commit_seq,commit_checks,trace_commit_data[0],partial_gold[commit_checks][31:0]);commit_checks=commit_checks+1;end
   if(out_stalled&&(!out_valid||out_data!==held_out||{out_row,out_half}!=held_index))$fatal(1,"matrix output hold");
   out_stalled=out_valid&&!out_ready;held_out=out_data;held_index={out_row,out_half};
   if(out_valid&&out_ready)begin if({out_row,out_half}!=outputs||out_data!==out_gold[outputs])$fatal(1,"matrix final output index=%0d actual=%0d data0=%h gold0=%h",outputs,{out_row,out_half},out_data[0],out_gold[outputs][31:0]);if(first_out<0)first_out=cycle;last_out=cycle;outputs=outputs+1;end
   if(arithmetic_debt>64||peak_return_reservations>128)$fatal(1,"matrix global arithmetic/return credit");
  end
  if(cycle>500000)$fatal(1,"matrix bounded cycle watchdog");
 end
 always @(negedge clk)begin
  if(stress)begin run_enable<=cycle%23>2;out_ready<=cycle%19>5;w_allow<=cycle%13>3;w_rsp_allow<=cycle%29>4;end
  else begin run_enable<=1;out_ready<=1;w_allow<=1;w_rsp_allow<=1;end
 end
 task automatic prepare;
  begin
   case(which)
    0:begin casepath={fixture,"/qkv_0_weight"};cmd_k=1024;cmd_n=3072;cmd_s=0;end
    1:begin casepath={fixture,"/mlp_wi_0_weight"};cmd_k=1024;cmd_n=5248;cmd_s=81;end
    2:begin casepath={fixture,"/mlp_wo_0_weight"};cmd_k=2624;cmd_n=1024;cmd_s=0;end
    3:begin casepath={fixture,"/head_fc2_0_weight"};cmd_k=4096;cmd_n=1024;cmd_s=0;end
   endcase
   gcount=cmd_k/32;cmd_bias=which==3;cmd_tensor=which+1;cmd_bias_data=0;
   $readmemh({casepath,"/a_write.hex"},a_words,0,128*gcount-1);$readmemh({casepath,"/a_record.hex"},a_records,0,8*gcount-1);$readmemh({casepath,"/w_record.hex"},w_records,0,4*gcount-1);
   $readmemh({casepath,"/dot.hex"},dot_gold,0,cmd_k-1);$readmemh({casepath,"/converted.hex"},cv_gold,0,cmd_k-1);$readmemh({casepath,"/product.hex"},prod_gold,0,cmd_k-1);$readmemh({casepath,"/term.hex"},term_gold,0,cmd_k-1);$readmemh({casepath,"/partial.hex"},partial_gold,0,cmd_k-1);$readmemh({casepath,"/output.hex"},out_gold);$readmemh({casepath,"/bias.hex"},bias_gold);
   $readmemh({casepath,"/p0.hex"},mem0,0,9*gcount-1);$readmemh({casepath,"/p1.hex"},mem1,0,9*gcount-1);$readmemh({casepath,"/p2.hex"},mem2,0,9*gcount-1);$readmemh({casepath,"/p3.hex"},mem3,0,9*gcount-1);
   for(integer c=0;c<64;c++)cmd_bias_data[c]=bias_gold[c];
  end
 endtask
 task automatic fill_a;
  begin
   @(negedge clk);acfg_slot=cmd_a_slot;acfg_k=cmd_k;acfg_request=cmd_request;acfg_generation=cmd_generation;acfg_epoch=cmd_epoch;acfg_valid=1;
   do @(posedge clk);while(!acfg_ready);
   @(negedge clk);acfg_valid=0;
   for(integer r=0;r<128;r++)for(integer g=0;g<gcount;g++)begin
    @(negedge clk);awr_valid=1;awr_row=r;awr_group=g;awr_data=a_words[r*gcount+g];do @(posedge clk);while(!awr_ready);
   end
   @(negedge clk);awr_valid=0;wait(acfg_rsp_valid);@(negedge clk);if(acfg_status!=0)$fatal(1,"matrix real A preload status=%0d",acfg_status);acfg_rsp_ready=1;@(negedge clk);acfg_rsp_ready=0;
  end
 endtask
 task automatic fill_w(input integer expected_status=0,input logic bad_span=0);
  begin
   @(negedge clk);wl_slot=cmd_w_slot;wl_k=cmd_k;wl_n=cmd_n;wl_s=cmd_s;wl_model=cmd_model;wl_tensor=cmd_tensor;wl_request=cmd_request;wl_generation=cmd_generation;
   for(integer p=0;p<4;p++)begin wl_base[p]=64'h100000000+64'h10000000*p;wl_span[p]=576*gcount*((cmd_n==5248)?82:(cmd_n/64));memory_start[p]=wl_base[p]+576*gcount*cmd_s;end
   if(bad_span)wl_span[0]=0;
   wl_valid=1;do @(posedge clk);while(!wl_ready);load_start=cycle;
   @(negedge clk);wl_valid=0;wait(wl_rsp_valid);@(negedge clk);if(wl_status!=expected_status)$fatal(1,"matrix real W preload status=%0d expected=%0d",wl_status,expected_status);wl_rsp_ready=1;@(negedge clk);wl_rsp_ready=0;
  end
 endtask
 task automatic launch(input integer expected_status,check_data);
  logic [159:0] held;integer completion_limit;
  begin
   issues=0;dot_checks=0;format_checks=0;term_checks=0;commit_checks=0;outputs=0;last_issue=-1;first_out=-1;last_out=-1;out_stalled=0;checking=check_data||expected_status>=2;error_run=expected_status>=2;
   // Functional watchdog for the fixed external-pause pattern. Normal performance assertions below remain K+384.
   completion_limit=stress?(2*cmd_k+1024):(cmd_k+1024);
   @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
   for(integer timeout=0;!done_valid;timeout++)begin @(negedge clk);if(timeout>completion_limit)$fatal(1,"matrix real-debt completion timeout status=%0d expected=%0d issues=%0d commits=%0d outputs=%0d A_debt=%0d arithmetic=%0d first_issue=%0d last_issue=%0d output_holds=%0d",status,expected_status,issues,commit_checks,outputs,a_read_debt,arithmetic_debt,first_issue_cycle,last_issue_cycle,output_holds);end
   @(negedge clk);
   if(status!=expected_status||done_request!=cmd_request||done_generation!=cmd_generation)$fatal(1,"matrix done identity/status got=%0d gold=%0d",status,expected_status);
   if(check_data)begin
    if(issues!=cmd_k||dot_checks!=cmd_k||format_checks!=cmd_k||term_checks!=cmd_k||commit_checks!=cmd_k||outputs!=256)$fatal(1,"matrix complete real event coverage I=%0d D=%0d F=%0d T=%0d C=%0d O=%0d K=%0d",issues,dot_checks,format_checks,term_checks,commit_checks,outputs,cmd_k);
    if(max_issue_commit>64||max_ps_feedback>24)$fatal(1,"matrix commit/feedback cap %0d/%0d",max_issue_commit,max_ps_feedback);
    if(!stress&&(last_issue_cycle-first_issue_cycle+1!=cmd_k||last_output_cycle>cmd_k+384||elapsed_cycles>cmd_k+384||output_bubbles!=0))$fatal(1,"matrix service curve issue=%0d output=%0d done=%0d cap=%0d bubbles=%0d",last_issue_cycle-first_issue_cycle+1,last_output_cycle,elapsed_cycles,cmd_k+384,output_bubbles);
    if(a_slot_leased!=0||w_slot_leased!=0||a_read_debt!=0||arithmetic_debt!=0)$fatal(1,"matrix done before real leases/debt released");
    $display("M007_MATRIX_SUPERBLOCK_PASS case=%0d K=%0d s=%0d bias=%0d stress=%0d outputs=8192 issue_span=%0d warm_last_output=%0d done=%0d W_service=%0d cold_last_output=%0d max_dot_commit=%0d max_PS_feedback=%0d output_bubbles=%0d peak_reserved=%0d",which,cmd_k,cmd_s,cmd_bias,stress,last_issue_cycle-first_issue_cycle+1,last_output_cycle,elapsed_cycles,wl_cycles,last_out-load_start,max_issue_commit,max_ps_feedback,output_bubbles,peak_return_reservations);
   end else if(expected_status==1)begin
    if(issues!=0||outputs!=0||a_slot_leased!=0||w_slot_leased!=0||a_read_debt!=0||arithmetic_debt!=0)$fatal(1,"invalid descriptor issued arithmetic or retained leases");
   end else begin
    if(outputs!=0||a_slot_leased!=0||w_slot_leased!=0||a_read_debt!=0||arithmetic_debt!=0||issues!=commit_checks)$fatal(1,"matrix error done before real debt released issues=%0d commits=%0d",issues,commit_checks);
   end
   held={status,done_request,done_generation,error_row,error_col,error_group};repeat(5)begin @(negedge clk);if(!done_valid||held!={status,done_request,done_generation,error_row,error_col,error_group})$fatal(1,"matrix done response hold");end
   checking=0;error_run=0;done_ready=1;@(negedge clk);done_ready=0;
  end
 endtask
 initial begin
  clk=0;rst_n=0;cmd_valid=0;done_ready=0;out_ready=1;run_enable=1;cmd_request=64'h1200000001;cmd_generation=1;cmd_epoch=1;cmd_model=64'h6eb6ef58bc4f99bd;cmd_a_slot=0;cmd_w_slot=0;cmd_ctx=0;cmd_bias=0;cmd_bias_data=0;
  if(!$value$plusargs("FIXTURE=%s",fixture))$fatal(1,"FIXTURE required");
  if(!$value$plusargs("CASE=%d",which))which=0;
  if(!$value$plusargs("STRESS=%d",stress))stress=0;
  scenario=stress;stress=scenario==1;
  prepare;repeat(5)@(negedge clk);rst_n=1;fill_a;fill_w;
  if(scenario==2)begin
   // Reset with actual accepted A returns and arithmetic still outstanding.
   checking=1;issues=0;dot_checks=0;format_checks=0;term_checks=0;commit_checks=0;outputs=0;last_issue=-1;
   @(negedge clk);cmd_valid=1;do @(posedge clk);while(!cmd_ready);@(negedge clk);cmd_valid=0;
   wait(issues>=80&&arithmetic_debt>0&&a_read_debt>0);
   @(negedge clk);$display("M007_MATRIX_RESET_LIVE issues=%0d commits=%0d arithmetic=%0d A_debt=%0d",issues,commit_checks,arithmetic_debt,a_read_debt);rst_n=0;checking=0;
   repeat(5)@(negedge clk);rst_n=1;
   repeat(12)begin @(negedge clk);if(done_valid||out_valid||trace_issue||trace_dot||trace_format||trace_term||trace_commit||arithmetic_debt!=0||a_read_debt!=0||a_slot_valid!=0||w_slot_valid!=0)$fatal(1,"common reset leaked pre-reset transaction");end
   launch(1,0);
   @(negedge clk);cmd_request=cmd_request+1;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;cmd_a_slot=1;cmd_w_slot=1;cmd_ctx=1;
   fill_a;fill_w;launch(0,1);
   $display("M007_MATRIX_RESET_NEW_GENERATION_PASS request=%h generation=%0d epoch=%0d A_slot=%0d W_slot=%0d ctx=%0d",cmd_request,cmd_generation,cmd_epoch,cmd_a_slot,cmd_w_slot,cmd_ctx);
  end else if(scenario==3)begin
   // The loader admits finite negative scales. Mutations arrive through AXI.
   mem2[17][16*11+:16]=16'hbc00;mem2[17][16*3+:16]=16'hbc00;
   fill_w;launch(2,0);
   if(error_row!=0||error_col!=((cmd_n==5248)?32*cmd_s+2627:64*cmd_s+35)||error_group!=1)$fatal(1,"matrix negative scale minimum original coordinate r=%0d c=%0d g=%0d",error_row,error_col,error_group);
   $display("M007_MATRIX_NEGATIVE_W_SCALE_PASS row=%0d column=%0d group=%0d issues=%0d commits=%0d",error_row,error_col,error_group,issues,commit_checks);
   // Corrupt public response identity on that same numeric record; drain its actual accepted request tag and prioritize protocol.
   protocol_corrupt=1;launch(3,0);protocol_corrupt=0;
   $display("M007_MATRIX_MIXED_PROTOCOL_NUMERIC_PASS issues=%0d commits=%0d",issues,commit_checks);
   // A malformed real LOAD span emits no AR and cannot authorize arithmetic.
   begin logic [3:0][31:0] before_ar;before_ar=w_ar_count;fill_w(1,1);if(w_ar_count!==before_ar)$fatal(1,"illegal span emitted AXI AR");launch(1,0);end
   // Restore original peer bytes; no DUT payload is directly modified.
   @(negedge clk);cmd_request=cmd_request+1;cmd_generation=cmd_generation+1;cmd_epoch=cmd_epoch+1;cmd_a_slot=1;cmd_w_slot=1;cmd_ctx=1;
   prepare;fill_a;fill_w;launch(0,1);
   $display("M007_MATRIX_ERROR_RECOVERY_PASS request=%h generation=%0d epoch=%0d",cmd_request,cmd_generation,cmd_epoch);
  end else begin
   launch(0,1);
   @(negedge clk);cmd_generation=cmd_generation+1;launch(1,0);cmd_generation=cmd_generation-1;
   cmd_request=cmd_request+1;launch(1,0);cmd_request=cmd_request-1;
   cmd_epoch=cmd_epoch+1;launch(1,0);cmd_epoch=cmd_epoch-1;
   cmd_model=cmd_model^1;launch(1,0);cmd_model=cmd_model^1;
   cmd_tensor=cmd_tensor+1;launch(1,0);cmd_tensor=cmd_tensor-1;
   cmd_s=cmd_s+1;launch(1,0);cmd_s=cmd_s-1;
   if(stress&&(issue_pauses==0||w_request_stalls==0||w_response_stalls==0||output_holds==0))$fatal(1,"finite stall coverage missing");
   $display("M007_MATRIX_IDENTITY_STALL_PASS rejected=6 issue_pauses=%0d W_request_stalls=%0d W_response_stalls=%0d output_holds=%0d",issue_pauses,w_request_stalls,w_response_stalls,output_holds);
  end
  $display("HARDWARE_AGENT_SIM_PASS M007_MATRIX_MATRIX case=%0d stress=%0d scenario=%0d",which,stress,scenario);$finish;
 end
endmodule
