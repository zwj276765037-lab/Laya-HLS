`timescale 1ns/1ps
module m007_g_compact_math_domain_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0,clear=0,idle,pool_reset_n;
 logic iv=0,ir,ov,ready=1;logic [95:0] tag=0,ot;logic [7:0][31:0] x=0,gate=0,y,status;
 logic [8:0] fqv,fqr,fpv;logic [8:0][95:0] fqt,fpt;logic [8:0][7:0][31:0] fa,fb,fy,fs;
 logic pool_fault,sv,sr,sov,sor;logic [95:0] st,sot;logic [7:0] sm,som;logic [7:0][31:0] sx,sy,ss;
 logic [8:0] pending;logic [1:0][8:0] slot_pending,sfu_debt;logic [1:0][7:0] fp_debt;
 logic [7:0][18:0] covered,evaluated;logic err;logic [2:0] erank;logic [6:0] erow;logic [11:0] ecol;logic fault;
 logic lv=0,lr,active,draining,release_valid=0,release_ready,reject,sfu_fault;logic [1:0] reject_code;
 logic [63:0] rid=64'h123456789abcdef0;logic [31:0] gen=7,epoch=9;logic [8:0] sfu_pending,sfu_flight;
 logic [383:0] vectors[0:335871];string vf;
 int cycles=0,issued=0,consumed=0,rejected=0,node_checks=0,cases=0,held=0;
 laya_m007_g_math_v1 dut(.clk,.rst_n,.clear,.idle,.pool_reset_n,.in_valid(iv),.in_ready(ir),.in_tag(tag),.in_x(x),.in_gate(gate),
  .out_valid(ov),.out_ready(ready),.out_tag(ot),.out_data(y),.out_status(status),
  .fp_req_valid(fqv),.fp_req_ready(fqr),.fp_req_tag(fqt),.fp_req_a(fa),.fp_req_b(fb),.fp_rsp_valid(fpv),.fp_rsp_tag(fpt),.fp_rsp_data(fy),.fp_rsp_status(fs),.fp_pool_fault(pool_fault),
  .sfu_req_valid(sv),.sfu_req_ready(sr),.sfu_req_tag(st),.sfu_req_mask(sm),.sfu_req_x(sx),.sfu_rsp_valid(sov),.sfu_rsp_ready(sor),.sfu_rsp_tag(sot),.sfu_rsp_data(sy),.sfu_rsp_status(ss),
  .pending,.slot_pending,.slot_sfu_debt(sfu_debt),.slot_fp_debt(fp_debt),.covered,.evaluated,.first_error_valid(err),.first_error_rank(erank),.first_error_row(erow),.first_error_column(ecol),.protocol_fault(fault));
 laya_m007_g_vector_pool_v1 pool(.clk,.rst_n(pool_reset_n),.req_valid(fqv),.req_ready(fqr),.req_tag(fqt),.req_a(fa),.req_b(fb),.rsp_valid(fpv),.rsp_tag(fpt),.rsp_data(fy),.rsp_status(fs),.protocol_fault(pool_fault));
 laya_m007_tanh8_v1 tanh(.clk,.rst_n,.lease_valid(lv),.lease_ready(lr),.lease_request_id(rid),.lease_generation(gen),.lease_epoch(epoch),.lease_phase(3'd1),
  .release_valid,.release_ready,.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(idle),.lease_active(active),.draining,
  .rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_phase(),.req_valid(sv),.req_ready(sr),.req_mode(2'd1),.req_request_id(rid),.req_generation(gen),.req_epoch(epoch),.req_phase(3'd1),.req_tag(st),.req_mask(sm),.req_x(sx),
  .reject_valid(reject),.reject_code,.rsp_valid(sov),.rsp_ready(sor),.rsp_tag(sot),.rsp_mask(som),.rsp_data(sy),.rsp_status(ss),.pending_vectors(sfu_pending),.in_flight_vectors(sfu_flight),.protocol_fault(sfu_fault));

 task automatic clear_private;
  if(!idle||pending||sfu_pending||sfu_flight||slot_pending||sfu_debt||fp_debt)$fatal(1,"CLEAR_REQUIRES_REAL_IDLE");
  @(negedge clk);clear=1;@(posedge clk);@(negedge clk);clear=0;#0.001;
  if(dut.context_valid||dut.next_input_seq||fault)$fatal(1,"EXPLICIT_CONTEXT_CLEAR");
 endtask
 task automatic input_vector(input int seq);
  @(negedge clk);tag={gen,epoch,16'b0,16'(seq)};
  for(int l=0;l<8;l++)begin x[l]=vectors[seq*8+l][383:352];gate[l]=vectors[seq*8+l][351:320];end
  iv=1;#0.001;while(!ir)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);iv=0;
 endtask
 task automatic actual_idle;
  while(!idle||pending||sfu_pending||sfu_flight||slot_pending||sfu_debt||fp_debt)@(negedge clk);
  repeat(3)@(negedge clk);
 endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",vf))$fatal(1,"ARGS");$readmemh(vf,vectors);
  repeat(5)@(negedge clk);rst_n=1;lv=1;#0.001;while(!lr)begin @(negedge clk);#0.001;end
  @(posedge clk);@(negedge clk);lv=0;
  for(int mode=0;mode<5;mode++)begin
   clear_private();ready=mode==4?0:1;input_vector(0);
   if(mode==4)begin wait(ov);@(negedge clk);end else actual_idle();
   if(!dut.context_valid||dut.tag_context!={gen,epoch}||dut.next_input_seq!=1)$fatal(1,"FIRST_REAL_ACCEPT_CONTEXT");
   @(negedge clk);tag={gen,epoch,16'b0,16'd1};
   case(mode)0,4:tag[95:64]=gen-1;1:tag[63:32]=epoch+1;2:tag[16]=1;3:tag[15:0]=257;endcase
   iv=1;#0.001;if(ir)$fatal(1,"BAD_INPUT_ACCEPTED");
   @(posedge clk);@(negedge clk);iv=0;
   if(!fault||!dut.context_valid||dut.tag_context!={gen,epoch}||dut.next_input_seq!=1)$fatal(1,"BAD_INPUT_REBOUND_CONTEXT");
   if(mode==4)begin
    logic [607:0] record;record={y,status,ot};
    repeat(17)begin @(negedge clk);held=held+1;if(!ov||{y,status,ot}!==record||ot!={gen,epoch,16'b0,16'd0})$fatal(1,"HELD_CONTEXT_CHANGED");end
    ready=1;
   end
   actual_idle();cases=cases+1;
  end
  clear_private();input_vector(0);actual_idle();
  repeat(17)begin @(negedge clk);if(!dut.context_valid||dut.tag_context!={gen,epoch}||dut.next_input_seq!=1||fault)$fatal(1,"EMPTY_NOT_REBIND");end
  input_vector(1);actual_idle();if(dut.next_input_seq!=2||fault)$fatal(1,"CONTINUE_SAME_CONTEXT");cases=cases+1;
  clear_private();@(negedge clk);tag={gen,epoch,16'h0001,16'd0};iv=1;#0.001;if(ir)$fatal(1,"INVALID_FIRST_INPUT");
  @(posedge clk);@(negedge clk);iv=0;if(!fault||dut.context_valid||dut.next_input_seq)$fatal(1,"BAD_FIRST_BOUND");actual_idle();cases=cases+1;
  if(issued!=7||consumed!=7||rejected!=6||node_checks!=560||held!=17||cases!=7)$fatal(1,"EXACT_DOMAIN_COUNTS issued=%0d consumed=%0d rejected=%0d nodes=%0d held=%0d cases=%0d",issued,consumed,rejected,node_checks,held,cases);
  clear_private();release_valid=1;wait(!active);@(negedge clk);release_valid=0;
  $display("HARDWARE_AGENT_SIM_PASS G_COMPACT_MATH_DOMAIN cases=%0d actual_inputs=%0d actual_outputs=%0d checked=%0d node_checks=%0d rejected_inputs=%0d held17=%0d empty_hold17=1 no_fake_accept=1 context_clear_only_explicit=1 real_debt_zero=1",cases,issued,consumed,consumed*8,node_checks,rejected,held);$finish;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>5000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(pool_fault||sfu_fault||reject||err)$fatal(1,"UNEXPECTED_RESOURCE_OR_NUMERIC_FAULT");
   if(iv&&ir)issued=issued+1;if(iv&&!ir)rejected=rejected+1;
   for(int n=0;n<9;n++)if(fpv[n])begin
    int seq,word_no;logic [31:0] expected;seq=int'(fpt[n][15:0]);word_no=n==0?2:n==1?3:n==2?4:n==3?5:n==4?6:n==5?8:n==6?9:n==7?10:11;
    if(fpt[n][95:32]!={gen,epoch}||fpt[n][31:16]!=0||seq>1)$fatal(1,"FP_FULL_TAG");
    for(int l=0;l<8;l++)begin expected=vectors[seq*8+l][383-word_no*32-:32];if(fy[n][l]!==expected||fs[n][l]!==0)$fatal(1,"FP_NODE");node_checks=node_checks+1;end
   end
   if(sov&&sor)begin
    int seq;logic [31:0] expected;seq=int'(sot[15:0]);if(sot[95:32]!={gen,epoch}||sot[31:16]!=0||seq>1||som!==8'hff||ss!==0)$fatal(1,"SFU_FULL_TAG got=%h expected_context=%h seq=%0d mask=%h status=%h request_tag=%h math_context=%h context_valid=%0d",sot,{gen,epoch},seq,som,ss,st,dut.tag_context,dut.context_valid);
    for(int l=0;l<8;l++)begin expected=vectors[seq*8+l][159:128];if(sy[l]!==expected)$fatal(1,"H_NODE");node_checks=node_checks+1;end
   end
   if(ov&&ready)begin
    int seq;logic [7:0][31:0] expected;seq=int'(ot[15:0]);if(ot[95:32]!={gen,epoch}||ot[31:16]!=0||seq>1)$fatal(1,"OUTPUT_FULL_TAG");
    for(int l=0;l<8;l++)expected[l]=vectors[seq*8+l][31:0];
    if(y!==expected||status!==0)$fatal(1,"OUTPUT_BITS");consumed=consumed+1;
   end
  end
 end
endmodule
