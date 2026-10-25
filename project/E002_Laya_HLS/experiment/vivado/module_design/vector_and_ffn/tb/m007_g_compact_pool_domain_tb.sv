`timescale 1ns/1ps
module m007_g_compact_pool_domain_tb;
 logic clk=0;always #1.6665 clk=~clk;logic rst_n=0;
 logic [8:0] qv=0,qr,rv;logic [8:0][95:0] qt=0,rt;
 logic [8:0][7:0][31:0] a=0,b=0,y,status;logic fault;
 int cycles=0,accept_count=0,return_count=0,reject_count=0,f32_checks=0,binds=0,cases=0;
 int accepted[0:8],returned[0:8];logic [95:0] expected[0:8][0:7];
 laya_m007_g_vector_pool_v1 dut(.clk,.rst_n,.req_valid(qv),.req_ready(qr),.req_tag(qt),.req_a(a),.req_b(b),.rsp_valid(rv),.rsp_tag(rt),.rsp_data(y),.rsp_status(status),.protocol_fault(fault));
 task automatic reset_private_pool;
  for(int n=0;n<9;n++)if(accepted[n]!=returned[n])$fatal(1,"RESET_WOULD_CANCEL_REAL_DEBT");
  @(negedge clk);rst_n=0;qv=0;repeat(2)@(negedge clk);
  for(int n=0;n<9;n++)begin accepted[n]=0;returned[n]=0;end
  rst_n=1;#0.001;if(dut.context_valid||fault)$fatal(1,"PRIVATE_RESET");
 endtask
 task automatic set_request(input logic [8:0] mask,input int seq);
  qv=mask;for(int n=0;n<9;n++)begin qt[n]={32'd7,32'd9,16'b0,16'(seq)};for(int l=0;l<8;l++)begin a[n][l]=32'h3f800000;b[n][l]=32'h3f000000;end end
 endtask
 task automatic drain;
  while(rv||accepted[0]!=returned[0]||accepted[2]!=returned[2]||accepted[3]!=returned[3])@(negedge clk);
  repeat(2)@(negedge clk);
 endtask
 initial begin
  for(int n=0;n<9;n++)begin accepted[n]=0;returned[n]=0;end
  repeat(3)@(negedge clk);reset_private_pool();
  // Same-beat actual acceptance establishes one context for mul/add channels.
  @(negedge clk);set_request(9'h00d,0);#0.001;if((qr&9'h00d)!=9'h00d)$fatal(1,"VALID_MULTICHANNEL_BIND");
  @(posedge clk);@(negedge clk);qv=0;drain();
  repeat(17)begin @(negedge clk);if(!dut.context_valid||dut.tag_context!={32'd7,32'd9}||fault)$fatal(1,"EMPTY_IS_NOT_CONTEXT_RELEASE");end
  @(negedge clk);set_request(9'h001,1);#0.001;if(!qr[0])$fatal(1,"VALID_NEXT_COMPLETE_SEQUENCE");
  @(posedge clk);@(negedge clk);qv=0;drain();cases=cases+1;
  // Each invalid input is rejected without acceptance. Existing true returns
  // have already retired; immutable context and full next seq must remain.
  for(int mode=0;mode<4;mode++)begin
   reset_private_pool();@(negedge clk);set_request(9'h001,0);
   @(posedge clk);@(negedge clk);qv=0;drain();
   @(negedge clk);set_request(9'h001,1);
   case(mode)0:qt[0][95:64]=6;1:qt[0][63:32]=10;2:qt[0][16]=1;3:qt[0][15:0]=257;endcase
   #0.001;if(qr[0])$fatal(1,"INVALID_INPUT_ACCEPTED mode=%0d",mode);
   @(posedge clk);@(negedge clk);qv=0;
   if(!fault||!dut.context_valid||dut.tag_context!={32'd7,32'd9}||dut.next_seq[0]!=1||accepted[0]!=1)$fatal(1,"INVALID_INPUT_REBOUND_CONTEXT");
   drain();cases=cases+1;
  end
  // Mixed first beat cannot create two accepted generation domains.
  reset_private_pool();@(negedge clk);set_request(9'h009,0);qt[3][95:64]=8;#0.001;
  if(!qr[0]||qr[3])$fatal(1,"MIXED_FIRST_BEAT_READY");
  @(posedge clk);@(negedge clk);qv=0;drain();
  if(!fault||dut.tag_context!={32'd7,32'd9}||accepted[0]!=1||accepted[3]!=0||dut.next_seq[3]!=0)$fatal(1,"MIXED_FIRST_BEAT_CONTEXT");cases=cases+1;
  // Reserved/seq aliases are illegal even before any context is established.
  for(int mode=0;mode<2;mode++)begin
   reset_private_pool();@(negedge clk);set_request(9'h001,0);if(mode==0)qt[0][16]=1;else qt[0][15:0]=256;
   #0.001;if(qr[0])$fatal(1,"INVALID_FIRST_REQUEST_ACCEPTED");
   @(posedge clk);@(negedge clk);qv=0;drain();if(!fault||dut.context_valid||accepted[0])$fatal(1,"INVALID_FIRST_REQUEST_BOUND");cases=cases+1;
  end
  if(cases!=8||accept_count!=return_count||reject_count!=7)$fatal(1,"EXACT_COUNTS cases=%0d accepted=%0d returned=%0d rejects=%0d",cases,accept_count,return_count,reject_count);
  $display("HARDWARE_AGENT_SIM_PASS G_COMPACT_POOL_DOMAIN cases=%0d actual_accepts=%0d actual_returns=%0d f32_checks=%0d rejected_inputs=%0d context_binds=%0d empty_hold17=1 mixed_first_beat=1 full_seq_alias_rejected=1 all_actual_debt_zero=1",cases,accept_count,return_count,f32_checks,reject_count,binds);$finish;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>2000)$fatal(1,"TIMEOUT");
  if(rst_n)begin
   if(!dut.context_valid&&|(qv&qr))binds=binds+1;
   for(int n=0;n<9;n++)begin
    if(qv[n]&&qr[n])begin if(accepted[n]>=8)$fatal(1,"TB_QUEUE");expected[n][accepted[n]]=qt[n];accepted[n]=accepted[n]+1;accept_count=accept_count+1;end
    if(qv[n]&&!qr[n])reject_count=reject_count+1;
    if(rv[n])begin
     if(returned[n]>=accepted[n]||rt[n]!==expected[n][returned[n]]||status[n]!==0)$fatal(1,"ACTUAL_RETURN_IDENTITY");
     for(int l=0;l<8;l++)begin if(y[n][l]!==((n==2||n==5)?32'h3fc00000:32'h3f000000))$fatal(1,"EXACT_HALF_OR_ONE_POINT_FIVE");f32_checks=f32_checks+1;end
     returned[n]=returned[n]+1;return_count=return_count+1;
    end
   end
  end
 end
endmodule
