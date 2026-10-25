`timescale 1ns/1ps
// Resource-free128-token x16-head RoPE. Q/K64 and coefficients join atomically.
// Phase7 lease_head is always0; actual head/token are in every accepted tag.
module laya_attention_rope_engine_v1(
 input logic clk,rst_n,
 input logic start_valid,output logic start_ready,input logic[63:0]start_request_id,input logic[31:0]start_generation,start_epoch,input logic start_family,input logic qkv_complete,coeff_complete,
 input logic abort_valid,output logic abort_ready,input logic read_grant,fp_grant,write_grant,
 output logic done_valid,input logic done_ready,output logic[7:0]done_status,output logic[31:0]done_cycles,first_commit_cycle,output logic[11:0]commits,
 output logic error_valid,output logic[63:0]error_rank,output logic[4:0]error_stage,output logic[31:0]error_element,
 output logic resource_debt_clear,output logic owner_valid,output logic[63:0]request_id,output logic[31:0]generation,epoch,
 output logic fp_lease_valid,input logic fp_lease_ready,output logic fp_release_valid,input logic fp_release_ready,input logic fp_fault,
 input logic[63:0]fp_rsp_request_id,input logic[31:0]fp_rsp_generation,fp_rsp_epoch,input logic[3:0]fp_rsp_head,input logic[2:0]fp_rsp_phase,
 input logic[6:0]fp_mul_pending,input logic[6:0][6:0]fp_add_pending,
 output logic[2:0]qkv_rd_valid,input logic[2:0]qkv_rd_ready,output logic[2:0][3:0]qkv_rd_head,output logic[2:0][6:0]qkv_rd_token,output logic[2:0][31:0]qkv_rd_tag,
 input logic[2:0]qkv_rsp_valid,output logic[2:0]qkv_rsp_ready,input logic[2:0][3:0]qkv_rsp_head,input logic[2:0][6:0]qkv_rsp_token,input logic[2:0][31:0]qkv_rsp_tag,input logic[2:0][63:0][31:0]qkv_rsp_data,
 output logic coeff_rd_valid,input logic coeff_rd_ready,output logic coeff_rd_family,output logic[6:0]coeff_rd_row,output logic[95:0]coeff_rd_tag,
 input logic coeff_rsp_valid,output logic coeff_rsp_ready,input logic coeff_rsp_family,input logic[6:0]coeff_rsp_row,input logic[95:0]coeff_rsp_tag,input logic[127:0][31:0]coeff_rsp_data,
 output logic mul_req_valid,input logic mul_req_ready,output logic[95:0]mul_req_tag,output logic[255:0][31:0]mul_a,mul_b,
 input logic mul_rsp_valid,output logic mul_rsp_ready,input logic[95:0]mul_rsp_tag,input logic[255:0][31:0]mul_rsp_data,
 output logic add_req_valid,input logic add_req_ready,output logic[95:0]add_req_tag,output logic[255:0][31:0]add_a,add_b,
 input logic add_rsp_valid,output logic add_rsp_ready,input logic[95:0]add_rsp_tag,input logic[255:0][31:0]add_rsp_data,
 output logic wr_valid,input logic wr_ready,output logic[3:0]wr_head,output logic[6:0]wr_token,output logic[95:0]wr_tag,output logic[63:0][31:0]wr_q,wr_k,
 input logic wr_commit_valid,input logic[95:0]wr_commit_tag
);
 localparam IDLE=0,CLAIM=1,RUN=2,DRAIN=3,RELEASE=4,DONE=5;
 logic[2:0]state;logic family,aborted,protocol_error;logic[11:0]issued,q_pending,k_pending,c_pending,m_pending,a_pending;logic[31:0]cycles;
 logic candidate_valid;logic[63:0]candidate_rank;logic[4:0]candidate_stage;logic[31:0]candidate_element;
 wire fp_identity=fp_rsp_request_id==request_id&&fp_rsp_generation==generation&&fp_rsp_epoch==epoch&&fp_rsp_head==0&&fp_rsp_phase==7;
 wire active_math=state==RUN&&!aborted&&!protocol_error;
 wire[3:0]next_head=issued[10:7];wire[6:0]next_token=issued[6:0];
 wire[95:0]next_tag={generation,epoch,21'b0,next_head,next_token};
 wire launch=active_math&&issued<2048&&read_grant&&(&qkv_rd_ready[1:0])&&coeff_rd_ready;
 wire join_valid=(&qkv_rsp_valid[1:0])&&coeff_rsp_valid;
 wire join_identity=qkv_rsp_head[0]==coeff_rsp_tag[10:7]&&qkv_rsp_head[1]==coeff_rsp_tag[10:7]&&qkv_rsp_token[0]==coeff_rsp_row&&qkv_rsp_token[1]==coeff_rsp_row&&qkv_rsp_tag[0]=={generation[20:0],coeff_rsp_tag[10:0]}&&qkv_rsp_tag[1]=={generation[20:0],coeff_rsp_tag[10:0]}&&coeff_rsp_tag[95:64]==generation&&coeff_rsp_tag[63:32]==epoch&&coeff_rsp_tag[6:0]==coeff_rsp_row&&coeff_rsp_family==family;
 wire mul_tag_ok=mul_rsp_tag[95:64]==generation&&mul_rsp_tag[63:32]==epoch;
 wire add_tag_ok=add_rsp_tag[95:64]==generation&&add_rsp_tag[63:32]==epoch;
 wire mul_fire=mul_req_valid&&mul_req_ready;wire mul_take=mul_rsp_valid&&mul_rsp_ready;wire add_fire=add_req_valid&&add_req_ready;wire add_take=add_rsp_valid&&add_rsp_ready;
 wire q_take=qkv_rsp_valid[0]&&qkv_rsp_ready[0];wire k_take=qkv_rsp_valid[1]&&qkv_rsp_ready[1];wire c_take=coeff_rsp_valid&&coeff_rsp_ready;wire write_fire=wr_valid&&wr_ready;
 wire drain=state==DRAIN||aborted||protocol_error;
 assign owner_valid=state>=CLAIM&&state<=RELEASE;
 assign start_ready=rst_n&&state==IDLE&&qkv_complete&&coeff_complete;
 assign abort_ready=rst_n&&(state==CLAIM||state==RUN||state==DRAIN);
 assign fp_lease_valid=state==CLAIM;
 assign resource_debt_clear=q_pending==0&&k_pending==0&&c_pending==0&&m_pending==0&&a_pending==0&&fp_mul_pending==0&&fp_add_pending==0&&qkv_rsp_valid[1:0]==0&&!coeff_rsp_valid&&!mul_rsp_valid&&!add_rsp_valid;
 assign fp_release_valid=state==RELEASE;
 assign done_valid=state==DONE;assign done_status=protocol_error?8'd3:aborted?8'd2:error_valid?8'd1:8'd0;
 assign qkv_rd_valid={1'b0,{2{launch}}};assign coeff_rd_valid=launch;assign coeff_rd_family=family;assign coeff_rd_row=next_token;assign coeff_rd_tag=next_tag;
 always_comb begin
  qkv_rd_head=0;qkv_rd_token=0;qkv_rd_tag=0;
  for(int p=0;p<2;p++)begin qkv_rd_head[p]=next_head;qkv_rd_token[p]=next_token;qkv_rd_tag[p]={generation[20:0],next_head,next_token};end
  mul_req_valid=active_math&&join_valid&&join_identity&&fp_grant&&fp_identity;mul_req_tag=coeff_rsp_tag;
  qkv_rsp_ready=0;coeff_rsp_ready=0;
  if(drain)begin qkv_rsp_ready[1:0]=2'b11;coeff_rsp_ready=1;end
  else if(active_math&&join_valid&&join_identity&&fp_grant&&fp_identity)begin qkv_rsp_ready[1:0]={2{mul_req_ready}};coeff_rsp_ready=mul_req_ready;end
  mul_a=0;mul_b=0;
  for(int p=0;p<2;p++)for(int j=0;j<32;j++)begin
   mul_a[(p*32+j)*4+0]=qkv_rsp_data[p][j];mul_b[(p*32+j)*4+0]=coeff_rsp_data[j];
   mul_a[(p*32+j)*4+1]=qkv_rsp_data[p][32+j];mul_b[(p*32+j)*4+1]=coeff_rsp_data[64+j];
   mul_a[(p*32+j)*4+2]=qkv_rsp_data[p][32+j];mul_b[(p*32+j)*4+2]=coeff_rsp_data[32+j];
   mul_a[(p*32+j)*4+3]=qkv_rsp_data[p][j];mul_b[(p*32+j)*4+3]=coeff_rsp_data[96+j];
  end
  add_req_valid=active_math&&mul_rsp_valid&&mul_tag_ok&&fp_identity&&fp_grant;add_req_tag=mul_rsp_tag;
  mul_rsp_ready=drain?1'b1:active_math&&mul_tag_ok&&fp_identity&&fp_grant&&add_req_ready;
  add_a=0;add_b=0;
  for(int n=0;n<64;n++)begin
   add_a[n]=mul_rsp_data[n*4];add_b[n]=mul_rsp_data[n*4+1]^32'h80000000;
   add_a[64+n]=mul_rsp_data[n*4+2];add_b[64+n]=mul_rsp_data[n*4+3];
  end
  wr_valid=active_math&&add_rsp_valid&&add_tag_ok&&fp_identity&&write_grant;wr_head=add_rsp_tag[10:7];wr_token=add_rsp_tag[6:0];wr_tag=add_rsp_tag;
  add_rsp_ready=drain?1'b1:active_math&&add_tag_ok&&fp_identity&&write_grant&&wr_ready;
  for(int j=0;j<32;j++)begin wr_q[j]=add_rsp_data[j];wr_q[32+j]=add_rsp_data[64+j];wr_k[j]=add_rsp_data[32+j];wr_k[32+j]=add_rsp_data[96+j];end
 end
 // The comparator follows original stages globally; physical return order is irrelevant.
 task automatic offer(input logic bad,input int st,el,inout logic valid,inout logic[63:0]rank,inout logic[4:0]stage,inout logic[31:0]element);
  logic[63:0]r;begin r={27'b0,5'(st),32'(el)};if(bad&&(!valid||r<rank))begin valid=1;rank=r;stage=5'(st);element=32'(el);end end
 endtask
 always_comb begin
  candidate_valid=0;candidate_rank=0;candidate_stage=0;candidate_element=0;
  if(mul_fire)for(int p=0;p<2;p++)for(int c=0;c<64;c++)offer(qkv_rsp_data[p][c][30:23]==8'hff,0,(int'(coeff_rsp_row)*3+p)*1024+int'(coeff_rsp_tag[10:7])*64+c,candidate_valid,candidate_rank,candidate_stage,candidate_element);
  if(mul_take&&!drain)for(int p=0;p<2;p++)for(int j=0;j<32;j++)for(int m=0;m<4;m++)offer(mul_rsp_data[(p*32+j)*4+m][30:23]==8'hff,p*5+m+1,int'(mul_rsp_tag[6:0])*512+int'(mul_rsp_tag[10:7])*32+j,candidate_valid,candidate_rank,candidate_stage,candidate_element);
  if(add_take&&!drain)for(int p=0;p<2;p++)for(int c=0;c<64;c++)offer((c<32?add_rsp_data[p*32+c][30:23]:add_rsp_data[64+p*32+c-32][30:23])==8'hff,p*5+5,int'(add_rsp_tag[6:0])*1024+int'(add_rsp_tag[10:7])*64+c,candidate_valid,candidate_rank,candidate_stage,candidate_element);
 end
 always_ff@(posedge clk)begin
  if(!rst_n)begin state<=IDLE;request_id<=0;generation<=0;epoch<=0;family<=0;issued<=0;commits<=0;q_pending<=0;k_pending<=0;c_pending<=0;m_pending<=0;a_pending<=0;cycles<=0;done_cycles<=0;first_commit_cycle<=0;aborted<=0;protocol_error<=0;error_valid<=0;error_rank<=0;error_stage<=0;error_element<=0;end
  else begin
   if(state!=IDLE&&state!=DONE)cycles<=cycles+1;
   if(start_valid&&start_ready)begin state<=CLAIM;request_id<=start_request_id;generation<=start_generation;epoch<=start_epoch;family<=start_family;issued<=0;commits<=0;q_pending<=0;k_pending<=0;c_pending<=0;m_pending<=0;a_pending<=0;cycles<=0;done_cycles<=0;first_commit_cycle<=0;aborted<=0;protocol_error<=0;error_valid<=0;error_rank<=0;error_stage<=0;error_element<=0;end
   if(state==CLAIM&&fp_lease_valid&&fp_lease_ready)state<=RUN;
   if(abort_valid&&abort_ready)begin aborted<=1;if(state==RUN)state<=DRAIN;end
   if(state==RUN&&(aborted||protocol_error))state<=DRAIN;
   if(state==RUN&&(fp_fault||!fp_identity||(join_valid&&!join_identity)||(mul_rsp_valid&&!mul_tag_ok)||(add_rsp_valid&&!add_tag_ok)||(write_fire!=wr_commit_valid)||(wr_commit_valid&&wr_commit_tag!=wr_tag)))begin protocol_error<=1;state<=DRAIN;end
   if(launch)issued<=issued+1;
   case({launch,q_take})2'b10:q_pending<=q_pending+1;2'b01:q_pending<=q_pending-1;default:;endcase
   case({launch,k_take})2'b10:k_pending<=k_pending+1;2'b01:k_pending<=k_pending-1;default:;endcase
   case({launch,c_take})2'b10:c_pending<=c_pending+1;2'b01:c_pending<=c_pending-1;default:;endcase
   case({mul_fire,mul_take})2'b10:m_pending<=m_pending+1;2'b01:m_pending<=m_pending-1;default:;endcase
   case({add_fire,add_take})2'b10:a_pending<=a_pending+1;2'b01:a_pending<=a_pending-1;default:;endcase
   if(write_fire)begin commits<=commits+1;if(commits==0)first_commit_cycle<=cycles+1;end
   if(candidate_valid&&(!error_valid||candidate_rank<error_rank))begin error_valid<=1;error_rank<=candidate_rank;error_stage<=candidate_stage;error_element<=candidate_element;end
   if(state==RUN&&issued==2048&&commits==2048&&resource_debt_clear)state<=RELEASE;
   if(state==DRAIN&&resource_debt_clear)state<=RELEASE;
   if(state==RELEASE&&fp_release_ready)begin state<=DONE;done_cycles<=cycles+1;end
   if(done_valid&&done_ready)state<=IDLE;
  end
 end
endmodule
