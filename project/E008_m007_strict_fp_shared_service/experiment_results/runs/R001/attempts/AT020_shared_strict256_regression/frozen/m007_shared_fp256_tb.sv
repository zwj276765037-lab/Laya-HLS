`timescale 1ns/1ps
module m007_shared_fp256_tb;
 localparam int LANES=256,GROUPS=7;
 logic clk=0;always #1.6665 clk=~clk;
 logic rst_n=0,lease_valid=0,lease_ready,release_valid=0,release_ready;
 logic [63:0] lease_request_id=64'h7000256,rsp_request_id;
 logic [31:0] lease_generation=1,lease_epoch=201,release_epoch=201;
 logic [31:0] rsp_generation,rsp_epoch;
 logic [3:0] lease_head=7,rsp_head;
 logic [2:0] lease_phase=2,release_phase=2,rsp_phase;
 logic phase_debt_clear=1,lease_active,draining;
 logic mul_req_valid=0,mul_req_ready,mul_rsp_valid,mul_rsp_ready=0;
 logic [2:0] mul_req_phase=2;
 logic [31:0] mul_req_epoch=201;
 logic [95:0] mul_req_tag,mul_rsp_tag;
 logic [LANES-1:0][31:0] mul_a,mul_b,mul_rsp_data;
 logic [GROUPS-1:0] add_req_valid=0,add_req_is_root=0,add_req_ready;
 logic [GROUPS-1:0][2:0] add_req_phase;
 logic [GROUPS-1:0][31:0] add_req_epoch;
 logic [GROUPS-1:0][95:0] add_req_tag,add_rsp_tag;
 logic [LANES-1:0][31:0] add_a,add_b,add_rsp_data;
 logic [GROUPS-1:0] add_rsp_valid,add_rsp_ready=0;
 logic [6:0] mul_pending;
 logic [GROUPS-1:0][6:0] add_pending;
 logic protocol_fault;
 logic [191:0] vectors [0:262143];
 int m_sent=0,m_got=0,a_sent[GROUPS],a_got[GROUPS];
 int cycle=0,step=0,checked=0,mode=0;
 int overlap[GROUPS],first_accept[GROUPS],last_accept[GROUPS],ii1_count[GROUPS];
 logic [GROUPS-1:0] held=0;
 logic [GROUPS-1:0][95:0] held_tag;
 logic [LANES-1:0][31:0] held_data;
 string vf;
 laya_shared_fp256_v2 #(.LANES(LANES),.ADD_GROUPS(GROUPS))dut(.*);
 function automatic int lo(input int g);case(g)0:lo=0;1:lo=128;2:lo=192;3:lo=224;4:lo=240;5:lo=248;default:lo=252;endcase endfunction
 function automatic int len(input int g);case(g)0:len=128;1:len=64;2:len=32;3:len=16;4:len=8;default:len=4;endcase endfunction
 task automatic values;
  mul_req_tag={64'h4d554c,32'(m_sent)};
  for(int lane=0;lane<LANES;lane++)begin
   mul_a[lane]=vectors[(mode==0?m_sent:900+m_sent)*256+lane][191:160];
   mul_b[lane]=vectors[(mode==0?m_sent:900+m_sent)*256+lane][159:128];
  end
  for(int g=0;g<GROUPS;g++)begin
   add_req_tag[g]=mode==0?{32'h414444,32'(g),32'(a_sent[g])}:{64'h414444,32'(a_sent[0])};
   for(int k=0;k<len(g);k++)begin
    add_a[lo(g)+k]=vectors[(mode==0?g*128+a_sent[g]:900+a_sent[0])*256+lo(g)+k][95:64];
    add_b[lo(g)+k]=vectors[(mode==0?g*128+a_sent[g]:900+a_sent[0])*256+lo(g)+k][63:32];
   end
  end
 endtask
 function automatic bit done_sent(input int n);
  bit d;d=m_sent>=n;for(int g=0;g<GROUPS;g++)d=d&&a_sent[g]>=n;return d;
 endfunction
 function automatic bit done_got(input int n);
  bit d;d=m_got==n;for(int g=0;g<GROUPS;g++)d=d&&a_got[g]==n;return d;
 endfunction
 task automatic take_lease;
  @(negedge clk);lease_valid=1;
  @(posedge clk);if(!lease_ready)$fatal(1,"FP256_LEASE");
  @(negedge clk);lease_valid=0;
 endtask
 initial begin
  for(int g=0;g<GROUPS;g++)begin a_sent[g]=0;a_got[g]=0;overlap[g]=0;first_accept[g]=-1;last_accept[g]=-1;ii1_count[g]=0;add_req_phase[g]=2;add_req_epoch[g]=201;end
  if(!$value$plusargs("VECTORS=%s",vf))$fatal(1,"FP256_FIXTURE_ARG");$readmemh(vf,vectors);
  repeat(5)@(negedge clk);rst_n=1;take_lease();
  while(!done_sent(64))begin
   @(negedge clk);values();mul_req_valid=m_sent<64;
   for(int g=0;g<GROUPS;g++)add_req_valid[g]=a_sent[g]<64;
  end
  @(negedge clk);values();mul_req_valid=1;add_req_valid='1;
  repeat(12)begin
   @(negedge clk);if(mul_pending!=64||mul_req_ready||add_req_ready!='0)$fatal(1,"FP256_FULL_CREDIT");
   for(int g=0;g<GROUPS;g++)if(add_pending[g]!=64)$fatal(1,"FP256_GROUP_CAPACITY g=%0d",g);
  end
  mul_req_valid=0;add_req_valid=0;mul_rsp_ready=1;add_rsp_ready='1;
  while(!done_got(64))@(negedge clk);@(negedge clk);step=0;
  while(!done_sent(128))begin
   @(negedge clk);values();mul_req_valid=m_sent<128&&step%3!=0;
   mul_rsp_ready=step%13>2;
   for(int g=0;g<GROUPS;g++)begin
    add_req_valid[g]=a_sent[g]<128&&step%(g+2)!=0;
    add_rsp_ready[g]=step%(g+9)>2;
   end
   step++;
  end
  @(negedge clk);mul_req_valid=0;add_req_valid=0;mul_rsp_ready=1;add_rsp_ready='1;
  while(!done_got(128))@(negedge clk);repeat(12)@(negedge clk);
  for(int g=0;g<GROUPS;g++)begin
   if(ii1_count[g]<63||overlap[g]==0)$fatal(1,"FP256_GROUP_NO_II_OR_OVERLAP g=%0d",g);
   $display("FP256_QK_GROUP_PASS g=%0d lanes=%0d accepted=128 returned=128 ii1_intervals=%0d overlap=%0d",g,len(g),ii1_count[g],overlap[g]);
  end
  release_valid=1;
  @(posedge clk);if(!release_ready)$fatal(1,"FP256_QK_RELEASE");
  @(negedge clk);release_valid=0;
  mode=1;m_sent=0;m_got=0;for(int g=0;g<GROUPS;g++)begin a_sent[g]=0;a_got[g]=0;end
  lease_phase=4;release_phase=4;mul_req_phase=4;lease_epoch=202;release_epoch=202;mul_req_epoch=202;
  for(int g=0;g<GROUPS;g++)begin add_req_phase[g]=4;add_req_epoch[g]=202;end
  take_lease();
  while(m_sent<32||a_sent[0]<32)begin
   @(negedge clk);values();mul_req_valid=m_sent<32;add_req_valid=0;add_req_valid[0]=a_sent[0]<32;
  end
  @(negedge clk);mul_req_valid=0;add_req_valid=0;
  wait(m_got==32&&a_got[0]==32);repeat(14)@(negedge clk);
  if(mul_pending||add_pending!='0||protocol_fault)$fatal(1,"FP256_AV_DRAIN");
  $display("HARDWARE_AGENT_SIM_PASS SHARED_FP256 checked_scalar_results=%0d qk_groups=7 qk_tokens_per_group=128 av_full_vectors=32",checked);$finish;
 end
 always @(posedge clk)begin
  cycle++;if(cycle>2000)$fatal(1,"FP256_TIMEOUT mode=%0d m_sent=%0d m_got=%0d a_sent=%p a_got=%p pending=%h",mode,m_sent,m_got,a_sent,a_got,add_pending);
  if(rst_n)begin
   if(protocol_fault)$fatal(1,"FP256_PROTOCOL_FAULT cycle=%0d",cycle);
   if(mul_req_valid&&mul_req_ready)m_sent++;
   if(mode==0)begin
    for(int g=0;g<GROUPS;g++)begin
     if(held[g])begin
      if(!add_rsp_valid[g]||add_rsp_tag[g]!==held_tag[g])$fatal(1,"FP256_HELD_TAG g=%0d",g);
      for(int k=0;k<len(g);k++)if(add_rsp_data[lo(g)+k]!==held_data[lo(g)+k])$fatal(1,"FP256_HELD_DATA");
     end
     held[g]=add_rsp_valid[g]&&!add_rsp_ready[g];held_tag[g]=add_rsp_tag[g];
     for(int k=0;k<len(g);k++)held_data[lo(g)+k]=add_rsp_data[lo(g)+k];
     if(add_req_valid[g]&&add_req_ready[g])begin
      if(last_accept[g]>=0&&cycle-last_accept[g]==1)ii1_count[g]++;
      last_accept[g]=cycle;a_sent[g]++;
     end
     if(add_rsp_valid[g]&&add_rsp_ready[g])begin
      if(add_rsp_tag[g]!=={32'h414444,32'(g),32'(a_got[g])})$fatal(1,"FP256_GROUP_TAG g=%0d",g);
      for(int k=0;k<len(g);k++)if(add_rsp_data[lo(g)+k]!==vectors[(g*128+a_got[g])*256+lo(g)+k][31:0])$fatal(1,"FP256_GROUP_NUMERIC g=%0d token=%0d lane=%0d",g,a_got[g],k);
      a_got[g]++;checked+=len(g);
      if(a_got[g]==64||a_got[g]==128)$display("FP256_PROGRESS g=%0d returned=%0d m_got=%0d",g,a_got[g],m_got);
      if(add_req_valid[g]&&add_req_ready[g])overlap[g]++;
     end
    end
   end else begin
    if(add_req_valid[0]&&add_req_ready[0])a_sent[0]++;
    if(add_rsp_valid[6:1]!='0)$fatal(1,"FP256_AV_GROUP_BYPASS");
    if(add_rsp_valid[0]&&add_rsp_ready[0])begin
     if(add_rsp_tag[0]!=={64'h414444,32'(a_got[0])})$fatal(1,"FP256_AV_TAG");
     for(int lane=0;lane<LANES;lane++)if(add_rsp_data[lane]!==vectors[(900+a_got[0])*256+lane][31:0])$fatal(1,"FP256_AV_NUMERIC");
     a_got[0]++;checked+=256;
    end
   end
   if(mul_rsp_valid&&mul_rsp_ready)begin
    if(mul_rsp_tag!=={64'h4d554c,32'(m_got)})$fatal(1,"FP256_MUL_TAG");
    for(int lane=0;lane<LANES;lane++)if(mul_rsp_data[lane]!==vectors[(mode==0?m_got:900+m_got)*256+lane][127:96])$fatal(1,"FP256_MUL_NUMERIC token=%0d lane=%0d",m_got,lane);
    m_got++;checked+=256;
   end
  end
 end
endmodule
