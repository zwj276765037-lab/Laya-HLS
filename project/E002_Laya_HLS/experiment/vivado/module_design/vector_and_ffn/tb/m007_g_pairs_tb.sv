`timescale 1ns/1ps
module m007_g_pairs_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic bv=0,br,sbr,bound;logic [63:0] rid=64'h8877665544332211,held_rid;
 logic [31:0] gen=5,ep=7,held_gen,held_ep;
 logic fv=0,fr,fs=0,fh=0,frej;logic [1:0] fcode;logic [6:0] fg=0,frow=0;logic [31:0][31:0] fd=0;
 logic rv=0,rr,rs=0,rrej,rov,ror=1,ros;logic [6:0] rg=0,row=0,rog,rorow;logic [1:0] chunk=0,rochunk;
 logic [7:0][31:0] rx,rga;logic [95:0] rtag;
 logic lv=0,lr,ls=0,lrej,client_clear=1;logic [6:0] lg=0;logic [9:0] consumed=0;logic [31:0] release_gen;
 logic dv=0,dr,drej,discard_clear=1;logic [31:0] discard_gen;
 logic [1:0] active,pair_ready;logic [1:0][6:0] groups;logic [1:0][9:0] issued,returned;logic wp,fault;
 logic wv,wr,war, wav,allow_ack=1;logic [255:0] wm;logic [255:0][5:0] wa;logic [255:0][31:0] wd;logic [95:0] wt,wat;
 logic qv,qr,qov,qor;logic [255:0] qm,qom;logic [255:0][5:0] qa;logic [255:0][31:0] qdata;logic [95:0] qt,qot;
 logic storage_idle;int cycles=0,writes=0,read_vectors=0,read_checks=0,overlap=0,read_count[0:81];
 laya_m007_g_pairs_v1 dut(.clk,.rst_n,.bind_valid(bv),.bind_ready(br),.bind_request_id(rid),.bind_generation(gen),.bind_epoch(ep),
  .bound,.request_id(held_rid),.generation(held_gen),.epoch(held_ep),
  .fill_valid(fv),.fill_ready(fr),.fill_request_id(rid),.fill_generation(gen),.fill_epoch(ep),.fill_slot(fs),.fill_half(fh),.fill_s(fg),.fill_row(frow),.fill_data(fd),.fill_reject_valid(frej),.fill_reject_code(fcode),
  .rd_valid(rv),.rd_ready(rr),.rd_request_id(rid),.rd_generation(gen),.rd_epoch(ep),.rd_slot(rs),.rd_s(rg),.rd_row(row),.rd_chunk(chunk),.rd_reject_valid(rrej),
  .rd_rsp_valid(rov),.rd_rsp_ready(ror),.rd_rsp_slot(ros),.rd_rsp_s(rog),.rd_rsp_row(rorow),.rd_rsp_chunk(rochunk),.rd_rsp_x(rx),.rd_rsp_gate(rga),.rd_rsp_tag(rtag),
  .release_valid(lv),.release_ready(lr),.release_request_id(rid),.release_generation(release_gen),.release_epoch(ep),.release_slot(ls),.release_s(lg),.release_consumed_vectors(consumed),.release_client_debt_clear(client_clear),.release_reject_valid(lrej),
  .discard_valid(dv),.discard_ready(dr),.discard_request_id(rid),.discard_generation(discard_gen),.discard_epoch(ep),.discard_client_debt_clear(discard_clear),.discard_reject_valid(drej),
  .slot_active(active),.slot_ready(pair_ready),.slot_s(groups),.issued_vectors(issued),.returned_vectors(returned),.write_pending(wp),.protocol_fault(fault),
  .g_wr_valid(wv),.g_wr_ready(wr),.g_wr_mask(wm),.g_wr_addr(wa),.g_wr_data(wd),.g_wr_tag(wt),.g_wr_rsp_valid(wav&&allow_ack),.g_wr_rsp_ready(war),.g_wr_rsp_tag(wat),
  .g_rd_valid(qv),.g_rd_ready(qr),.g_rd_mask(qm),.g_rd_addr(qa),.g_rd_tag(qt),.g_rd_rsp_valid(qov),.g_rd_rsp_ready(qor),.g_rd_rsp_data(qdata),.g_rd_rsp_mask(qom),.g_rd_rsp_tag(qot));
 // Exactly one full existing storage instance; unused PS/context ports disabled.
 laya_attention_storage_v1 storage(.clk,.rst_n,.bind_valid(bv),.bind_ready(sbr),.bind_request_id(rid),.bind_generation(gen),.bind_epoch(ep),.bind_head(4'd0),.bind_phase(3'd1),
  .op_request_id(rid),.op_generation(gen),.op_epoch(ep),.op_phase(3'd1),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .ps_wr_valid(1'b0),.ps_wr_ready(),.ps_wr_mask('0),.ps_wr_addr('0),.ps_wr_data('0),.ps_wr_tag('0),.ps_wr_rsp_valid(),.ps_wr_rsp_ready(1'b0),.ps_wr_rsp_tag(),
  .ps_rd_valid(1'b0),.ps_rd_ready(),.ps_rd_mask('0),.ps_rd_addr('0),.ps_rd_tag('0),.ps_rd_rsp_valid(),.ps_rd_rsp_ready(1'b0),.ps_rd_rsp_data(),.ps_rd_rsp_mask(),.ps_rd_rsp_tag(),
  .g_wr_valid(wv),.g_wr_ready(wr),.g_wr_mask(wm),.g_wr_addr(wa),.g_wr_data(wd),.g_wr_tag(wt),.g_wr_rsp_valid(wav),.g_wr_rsp_ready(war&&allow_ack),.g_wr_rsp_tag(wat),
  .g_rd_valid(qv),.g_rd_ready(qr),.g_rd_mask(qm),.g_rd_addr(qa),.g_rd_tag(qt),.g_rd_rsp_valid(qov),.g_rd_rsp_ready(qor),.g_rd_rsp_data(qdata),.g_rd_rsp_mask(qom),.g_rd_rsp_tag(qot),
  .context_wr_valid(1'b0),.context_wr_ready(),.context_wr_mask('0),.context_wr_addr('0),.context_wr_data('0),.context_wr_tag('0),.context_wr_rsp_valid(),.context_wr_rsp_ready(1'b0),.context_wr_rsp_tag(),
  .context_rd_valid(1'b0),.context_rd_ready(),.context_rd_mask('0),.context_rd_addr('0),.context_rd_tag('0),.context_rd_rsp_valid(),.context_rd_rsp_ready(1'b0),.context_rd_rsp_data(),.context_rd_rsp_mask(),.context_rd_rsp_tag(),.idle(storage_idle));
 function automatic [31:0] pattern(input int group_no,row_no,column,half_no);
  return 32'h30000000^(gen<<24)^32'(group_no<<17)^32'(row_no<<10)^32'(half_no<<9)^32'(column);
 endfunction
 task automatic bind_all;
  @(negedge clk);bv=1;#0.001;while(!(br&&sbr))begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);bv=0;release_gen=gen;discard_gen=gen;
  if(!bound||held_gen!=gen||held_rid!=rid||held_ep!=ep)$fatal(1,"BIND");
 endtask
 task automatic set_fill(input int group_no,row_no,half_no);
  fg=7'(group_no);fs=group_no%2;frow=7'(row_no);fh=1'(half_no);
  for(int c=0;c<32;c++)fd[c]=pattern(group_no,row_no,c,half_no);
 endtask
 task automatic send_fill(input int group_no,row_no,half_no);
  @(negedge clk);set_fill(group_no,row_no,half_no);fv=1;#0.001;
  while(!fr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);fv=0;
 endtask
 task automatic fill_group(input int group_no,input bit hold_last);
  for(int h=0;h<2;h++)for(int r=0;r<128;r++)begin
   if(hold_last&&h==1&&r==127)begin wait(!wp);@(negedge clk);allow_ack=0;end
   send_fill(group_no,r,h);
  end
  if(hold_last)begin
   repeat(17)begin @(negedge clk);if(pair_ready[group_no%2]||!wp||!wav)$fatal(1,"LAST_ACK_PREMATURE_READY");end
   allow_ack=1;
  end
  wait(pair_ready[group_no%2]);@(negedge clk);
 endtask
 task automatic read_group(input int group_no);
  for(int i=0;i<512;i++)begin
   @(negedge clk);rs=group_no%2;rg=7'(group_no);row=7'(i/4);chunk=2'(i%4);rv=1;#0.001;
   while(!rr)begin @(negedge clk);#0.001;end
   @(posedge clk);@(negedge clk);rv=0;
   if(i==63)begin ror=0;repeat(17)@(negedge clk);ror=1;end
  end
  wait(read_count[group_no]==512);@(negedge clk);
 endtask
 task automatic release_group(input int group_no,input bit exercise_barrier);
  @(negedge clk);lv=1;ls=group_no%2;lg=7'(group_no);release_gen=gen+1;consumed=512;client_clear=1;#0.001;
  if(lr||!lrej)$fatal(1,"WRONG_RELEASE_ID");
  @(negedge clk);release_gen=gen;
  if(exercise_barrier)begin
   consumed=511;client_clear=0;
   repeat(17)begin @(negedge clk);if(lr||!active[group_no%2])$fatal(1,"CLIENT_RELEASE_BARRIER");end
   consumed=512;client_clear=1;
  end
  #0.001;while(!lr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);lv=0;if(active[group_no%2])$fatal(1,"RELEASE_NOT_RETIRED");
 endtask
 initial begin
  foreach(read_count[i])read_count[i]=0;
  repeat(5)@(negedge clk);rst_n=1;bind_all();fill_group(0,1);
  @(negedge clk);set_fill(0,0,0);fv=1;#0.001;if(fr||!frej||fcode!=3)$fatal(1,"DUP_FILL");@(negedge clk);fv=0;
  fork fill_group(1,0);read_group(0);join
  @(negedge clk);set_fill(2,0,0);fv=1;
  repeat(17)begin @(negedge clk);if(fr||frej||groups[0]!=0||!active[0])$fatal(1,"THIRD_SLOT_OVERWRITE");end
  fv=0;release_group(0,1);
  fork fill_group(2,0);read_group(1);join
  release_group(1,0);read_group(2);release_group(2,0);
  if(!overlap||writes!=768||read_vectors!=1536||read_checks!=24576)$fatal(1,"NORMAL_COUNTS w=%0d r=%0d c=%0d overlap=%0d",writes,read_vectors,read_checks,overlap);
  gen=gen+1;ep=ep+1;bind_all();allow_ack=0;send_fill(0,0,0);
  @(negedge clk);dv=1;discard_gen=gen+1;#0.001;if(dr||!drej)$fatal(1,"DISCARD_ID");
  discard_gen=gen;repeat(17)begin @(negedge clk);if(dr||!wp)$fatal(1,"DISCARD_REAL_WRITE_DEBT");end
  allow_ack=1;#0.001;while(!dr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);dv=0;if(bound||active||wp)$fatal(1,"DISCARD_NOT_CLEAR");
  gen=gen+1;ep=ep+1;bind_all();if(pair_ready)$fatal(1,"OLD_COVERAGE_NEWGEN");
  fill_group(0,0);read_count[0]=0;
  @(negedge clk);rs=0;rg=0;row=0;chunk=0;rv=1;#0.001;while(!rr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);rv=0;wait(read_count[0]==1);
  @(negedge clk);dv=1;#0.001;while(!dr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);dv=0;
  if(bound||active||fault||wp||!storage_idle)$fatal(1,"FINAL_DEBT");
  $display("HARDWARE_AGENT_SIM_PASS G_PAIRS writes=%0d read_vectors=%0d f32_checks=%0d real_overlap=%0d slot0_1_0=1 last_ack_hold17=1 sync_return_hold17=1 third_block17=1 client_barrier17=1 real_write_discard=1 newgen_reload_partial_discard=1",writes,read_vectors,read_checks,overlap);$finish;
 end
 logic holding=0;logic [607:0] held;
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>30000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(fault||rrej)$fatal(1,"PROTOCOL_FAULT");
   if(holding&&(!rov||{rx,rga,rtag}!==held))$fatal(1,"SYNC_READ_HOLD");
   holding=rov&&!ror;if(holding)held={rx,rga,rtag};
   if(wv&&wr)begin if($countones(wm)!=32)$fatal(1,"WRITE_WIDTH");writes=writes+1;end
   if(wv&&wr&&qv&&qr)overlap=overlap+1;
   if(rov&&ror)begin
    for(int lane=0;lane<8;lane++)begin
     if(rx[lane]!==pattern(rog,rorow,int'(rochunk)*8+lane,0)||rga[lane]!==pattern(rog,rorow,int'(rochunk)*8+lane,1))$fatal(1,"DATA_MAP s=%0d row=%0d chunk=%0d lane=%0d",rog,rorow,rochunk,lane);
     read_checks=read_checks+2;
    end
    read_count[rog]=read_count[rog]+1;read_vectors=read_vectors+1;
   end
  end
 end
endmodule
