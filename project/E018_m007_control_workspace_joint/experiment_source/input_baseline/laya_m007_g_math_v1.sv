`timescale 1ns/1ps
// Pure original GEGLU dataflow. FP9 vector channels and TANH are external.
// Every admitted vector reserves one of256 bounded arithmetic/result slots.
// No complete G tensor, no TANH copy, and no matrix256 FP array.
module laya_m007_g_math_v1(
 input logic clk,rst_n,clear,output logic idle,output logic pool_reset_n,
 input logic in_valid,output logic in_ready,input logic [95:0] in_tag,
 input logic [7:0][31:0] in_x,in_gate,
 output logic out_valid,input logic out_ready,output logic [95:0] out_tag,
 output logic [7:0][31:0] out_data,out_status,
 output logic [8:0] fp_req_valid,input logic [8:0] fp_req_ready,
 output logic [8:0][95:0] fp_req_tag,output logic [8:0][7:0][31:0] fp_req_a,fp_req_b,
 input logic [8:0] fp_rsp_valid,input logic [8:0][95:0] fp_rsp_tag,
 input logic [8:0][7:0][31:0] fp_rsp_data,fp_rsp_status,input logic fp_pool_fault,
 output logic sfu_req_valid,input logic sfu_req_ready,output logic [95:0] sfu_req_tag,
 output logic [7:0] sfu_req_mask,output logic [7:0][31:0] sfu_req_x,
 input logic sfu_rsp_valid,output logic sfu_rsp_ready,input logic [95:0] sfu_rsp_tag,
 input logic [7:0][31:0] sfu_rsp_data,sfu_rsp_status,
 output logic [8:0] pending,output logic [1:0][8:0] slot_pending,slot_sfu_debt,
 output logic [1:0][7:0] slot_fp_debt,
 output logic [7:0][18:0] covered,evaluated,
 output logic first_error_valid,output logic [2:0] first_error_rank,
 output logic [6:0] first_error_row,output logic [11:0] first_error_column,
 output logic protocol_fault
);
 function automatic logic finite(input logic [31:0] a);return a[30:23]!=255;endfunction
 function automatic [7:0] finite8(input logic [7:0][31:0] a);
  for(int l=0;l<8;l++)finite8[l]=finite(a[l]);
 endfunction
 function automatic [7:0] status_ok(input logic [7:0][31:0] a);
  for(int l=0;l<8;l++)status_ok[l]=a[l]==0;
 endfunction
 (* ram_style="distributed" *)logic [7:0][31:0] x_mem[0:255],gate_mem[0:255],result_mem[0:255];
 // Fixed G domain: one immutable generation/epoch until explicit clear.
 // Ring address is the accepted sequence low8; stored high8 completes seq16.
 logic [63:0] tag_context;logic context_valid;logic [15:0] next_input_seq;
 logic input_tag_ok;logic [15:0] pre_credit_seq;
 function automatic [95:0] full_tag(input logic [63:0] fixed_context,input logic [15:0] seq);
  return {fixed_context,16'b0,seq};
 endfunction
 function automatic logic context_match(input logic valid_context,input logic [63:0] fixed_context,input logic [95:0] tag);
  return valid_context&&tag[95:32]==fixed_context&&tag[31:16]==0&&tag[15:0]<41984;
 endfunction
 function automatic [15:0] slot_seq(input logic [7:0] high_seq,input logic [7:0] slot_index);
  return {high_seq,slot_index};
 endfunction
 (* ram_style="distributed" *)logic [7:0] tag_mem_hi[0:255];
 logic [7:0] numeric_bad[0:255],peer_bad[0:255],z_good_mem[0:255];
 logic [255:0] live,available,sent,received;
 logic [7:0] reserve_ptr,head_ptr;
 logic [8:0][3:0] expected_valid;
 logic [15:0] expected_tag[0:8][0:3];
 logic [8:0] matched;logic [8:0][7:0] peer_event;
 logic [15:0] pre_tag[0:14];logic [7:0] x_good_pipe[0:14];
 logic [7:0][31:0] x_delay[0:3],t_delay[0:6];logic [15:0] t_tag[0:6];
 logic [6:0] t_valid;logic [7:0] ugood_delay[0:3],vgood_delay[0:2],tgood_delay[0:6],zeligible_delay[0:3];
 logic [7:0] u_ok,v_ok,w_ok,t_ok,z_eligible,z_ok,y_eligible,y_ok,g_eligible;
 logic [7:0][31:0] h0,x0,gate_delay[0:8],r_aligned;
 logic [15:0] post_tag[0:12],r_tag;
 logic [12:0] post_valid;logic r_valid;
 logic [7:0] post_good[0:12],yeligible_delay[0:3],geligible_delay[0:3];
 logic pre_capacity,pre_fault;logic [5:0] pre_pending,pre_flight;
 logic [7:0][31:0] safe_z;
 logic sfu_match;logic [7:0] sfu_peer_event;
 logic [7:0][7:0] error_event,event_eval;
 logic [7:0] event_valid;logic [7:0][95:0] event_tag;
 logic next_error_valid;logic [2:0] next_error_rank;logic [6:0] next_error_row;logic [11:0] next_error_column;
 wire accept=in_valid&&in_ready;wire consume=out_valid&&out_ready;
 wire sfu_fire=sfu_req_valid&&sfu_req_ready;wire sfu_return=sfu_rsp_valid&&sfu_rsp_ready&&sfu_match;
 assign pool_reset_n=rst_n&&!clear;
 assign out_valid=pool_reset_n&&pending!=0&&available[head_ptr];
 assign out_tag=full_tag(tag_context,slot_seq(tag_mem_hi[head_ptr],head_ptr));assign out_data=result_mem[head_ptr];
 for(genvar lane=0;lane<8;lane++)assign out_status[lane]=numeric_bad[head_ptr][lane]?32'd6:(peer_bad[head_ptr][lane]?32'd8:32'd0);
 assign input_tag_ok=in_tag[31:16]==0&&in_tag[15:0]<41984&&in_tag[15:0]==next_input_seq&&
  (!context_valid||in_tag[95:32]==tag_context);
 assign in_ready=pool_reset_n&&!protocol_fault&&input_tag_ok&&pre_capacity&&(pending<256||consume);
 assign idle=pending==0&&pre_pending==0&&slot_sfu_debt==0&&slot_fp_debt==0&&!out_valid;
 assign sfu_req_mask=8'hff;
 assign sfu_req_tag=full_tag(tag_context,pre_credit_seq);
 assign sfu_rsp_ready=pool_reset_n; // Invalid peer records never retire owed returns.
 laya_return_vector_credit_v1 #(.WIDTH(256),.TAG_WIDTH(16),.LATENCY(15),.DEPTH(32),.HEAD_BYPASS(0)) pre_credit(
  .clk,.rst_n(pool_reset_n),.req_valid(accept),.req_ready(pre_capacity),.req_tag(in_tag[15:0]),
  .result_valid(matched[4]),.result_data(safe_z),.rsp_valid(sfu_req_valid),.rsp_ready(sfu_req_ready),
  .rsp_tag(pre_credit_seq),.rsp_data(sfu_req_x),.pending(pre_pending),.in_flight(pre_flight),.fault(pre_fault));
 always_comb begin
  matched=0;peer_event=0;
  for(int n=0;n<9;n++)begin
   if(n==2||n==5)matched[n]=fp_rsp_valid[n]&&context_match(context_valid,tag_context,fp_rsp_tag[n])&&expected_valid[n][2]&&fp_rsp_tag[n][15:0]==expected_tag[n][2]&&live[fp_rsp_tag[n][7:0]]&&slot_seq(tag_mem_hi[fp_rsp_tag[n][7:0]],fp_rsp_tag[n][7:0])==fp_rsp_tag[n][15:0];
   else matched[n]=fp_rsp_valid[n]&&context_match(context_valid,tag_context,fp_rsp_tag[n])&&expected_valid[n][3]&&fp_rsp_tag[n][15:0]==expected_tag[n][3]&&live[fp_rsp_tag[n][7:0]]&&slot_seq(tag_mem_hi[fp_rsp_tag[n][7:0]],fp_rsp_tag[n][7:0])==fp_rsp_tag[n][15:0];
   peer_event[n]=matched[n]?~status_ok(fp_rsp_status[n]):8'b0;
  end
  u_ok=x_good_pipe[3]&finite8(fp_rsp_data[0])&status_ok(fp_rsp_status[0]);
  t_ok=x_good_pipe[3]&finite8(fp_rsp_data[3])&status_ok(fp_rsp_status[3]);
  v_ok=ugood_delay[3]&finite8(fp_rsp_data[1])&status_ok(fp_rsp_status[1]);
  w_ok=vgood_delay[2]&finite8(fp_rsp_data[2])&status_ok(fp_rsp_status[2]);
  z_eligible=w_ok&tgood_delay[6];
  z_ok=zeligible_delay[3]&finite8(fp_rsp_data[4])&status_ok(fp_rsp_status[4]);
  y_eligible=post_good[4]&finite8(r_aligned)&finite8(fp_rsp_data[6])&status_ok(fp_rsp_status[6]);
  y_ok=yeligible_delay[3]&finite8(fp_rsp_data[7])&status_ok(fp_rsp_status[7]);g_eligible=y_ok;
  for(int l=0;l<8;l++)safe_z[l]=z_ok[l]?fp_rsp_data[4][l]:32'b0;
  sfu_match=context_match(context_valid,tag_context,sfu_rsp_tag)&&live[sfu_rsp_tag[7:0]]&&sent[sfu_rsp_tag[7:0]]&&!received[sfu_rsp_tag[7:0]]&&slot_seq(tag_mem_hi[sfu_rsp_tag[7:0]],sfu_rsp_tag[7:0])==sfu_rsp_tag[15:0];
  sfu_peer_event=~status_ok(sfu_rsp_status)|~finite8(sfu_rsp_data);

  fp_req_valid=0;fp_req_tag=0;fp_req_a=0;fp_req_b=0;
  fp_req_valid[0]=accept;fp_req_valid[3]=accept;fp_req_tag[0]=in_tag;fp_req_tag[3]=in_tag;
  fp_req_valid[1]=matched[0];fp_req_tag[1]=fp_rsp_tag[0];
  fp_req_valid[2]=matched[1];fp_req_tag[2]=fp_rsp_tag[1];
  fp_req_valid[4]=matched[2]&&t_valid[6]&&t_tag[6]==fp_rsp_tag[2][15:0];fp_req_tag[4]=fp_rsp_tag[2];
  fp_req_valid[5]=post_valid[0];fp_req_valid[6]=post_valid[0];fp_req_tag[5]=full_tag(tag_context,post_tag[0]);fp_req_tag[6]=full_tag(tag_context,post_tag[0]);
  fp_req_valid[7]=matched[6]&&r_valid&&r_tag==fp_rsp_tag[6][15:0];fp_req_tag[7]=fp_rsp_tag[6];
  fp_req_valid[8]=matched[7]&&post_tag[8]==fp_rsp_tag[7][15:0];fp_req_tag[8]=fp_rsp_tag[7];
  for(int l=0;l<8;l++)begin
   fp_req_a[0][l]=32'h3d372713;fp_req_b[0][l]=finite(in_x[l])?in_x[l]:0;
   fp_req_a[3][l]=32'h3f4c422a;fp_req_b[3][l]=finite(in_x[l])?in_x[l]:0;
   fp_req_a[1][l]=u_ok[l]?fp_rsp_data[0][l]:0;fp_req_b[1][l]=u_ok[l]?x_delay[3][l]:0;
   fp_req_a[2][l]=32'h3f800000;fp_req_b[2][l]=v_ok[l]?fp_rsp_data[1][l]:0;
   fp_req_a[4][l]=z_eligible[l]?t_delay[6][l]:0;fp_req_b[4][l]=z_eligible[l]?fp_rsp_data[2][l]:0;
   fp_req_a[5][l]=32'h3f800000;fp_req_b[5][l]=post_good[0][l]?h0[l]:0;
   fp_req_a[6][l]=32'h3f000000;fp_req_b[6][l]=post_good[0][l]?x0[l]:0;
   fp_req_a[7][l]=y_eligible[l]?fp_rsp_data[6][l]:0;fp_req_b[7][l]=y_eligible[l]?r_aligned[l]:0;
   fp_req_a[8][l]=g_eligible[l]?fp_rsp_data[7][l]:0;fp_req_b[8][l]=g_eligible[l]?gate_delay[8][l]:0;
  end

  event_valid={matched[8],matched[7],matched[4],matched[3],matched[2],matched[1],matched[0],accept};
  event_tag[0]=in_tag;event_tag[1]=full_tag(tag_context,pre_tag[3]);event_tag[2]=full_tag(tag_context,pre_tag[7]);event_tag[3]=full_tag(tag_context,pre_tag[10]);event_tag[4]=full_tag(tag_context,pre_tag[3]);event_tag[5]=full_tag(tag_context,pre_tag[14]);event_tag[6]=fp_rsp_tag[7];event_tag[7]=fp_rsp_tag[8];
  event_eval[0]=8'hff;event_eval[1]=x_good_pipe[3]&status_ok(fp_rsp_status[0]);event_eval[2]=ugood_delay[3]&status_ok(fp_rsp_status[1]);
  event_eval[3]=vgood_delay[2]&status_ok(fp_rsp_status[2]);event_eval[4]=x_good_pipe[3]&status_ok(fp_rsp_status[3]);
  event_eval[5]=zeligible_delay[3]&status_ok(fp_rsp_status[4]);event_eval[6]=yeligible_delay[3]&status_ok(fp_rsp_status[7]);event_eval[7]=geligible_delay[3]&status_ok(fp_rsp_status[8]);
  error_event[0]=~finite8(in_x);error_event[1]=event_eval[1]&~finite8(fp_rsp_data[0]);error_event[2]=event_eval[2]&~finite8(fp_rsp_data[1]);
  error_event[3]=event_eval[3]&~finite8(fp_rsp_data[2]);error_event[4]=event_eval[4]&~finite8(fp_rsp_data[3]);
  error_event[5]=event_eval[5]&~finite8(fp_rsp_data[4]);error_event[6]=event_eval[6]&~finite8(fp_rsp_data[7]);error_event[7]=event_eval[7]&~finite8(fp_rsp_data[8]);
  for(int rank=0;rank<8;rank++)if(!event_valid[rank])error_event[rank]=0;
  next_error_valid=first_error_valid;next_error_rank=first_error_rank;next_error_row=first_error_row;next_error_column=first_error_column;
  for(int rank=0;rank<8;rank++)for(int l=0;l<8;l++)if(error_event[rank][l])begin
   if(!next_error_valid||rank<int'(next_error_rank)||(rank==int'(next_error_rank)&&
      (event_tag[rank][8:2]<next_error_row||(event_tag[rank][8:2]==next_error_row&&{event_tag[rank][15:9],event_tag[rank][1:0],3'(l)}<next_error_column))))begin
    next_error_valid=1;next_error_rank=3'(rank);next_error_row=event_tag[rank][8:2];next_error_column={event_tag[rank][15:9],event_tag[rank][1:0],3'(l)};
   end
  end
 end
 always_ff @(posedge clk)begin
  if(!pool_reset_n)begin
   live<=0;available<=0;sent<=0;received<=0;reserve_ptr<=0;head_ptr<=0;pending<=0;slot_pending<=0;slot_sfu_debt<=0;slot_fp_debt<=0;
   tag_context<=0;context_valid<=0;next_input_seq<=0;
   expected_valid<=0;t_valid<=0;post_valid<=0;r_valid<=0;covered<=0;evaluated<=0;protocol_fault<=0;
   first_error_valid<=0;first_error_rank<=0;first_error_row<=0;first_error_column<=0;
  end else begin
   if(fp_pool_fault||pre_fault||(in_valid&&!input_tag_ok))protocol_fault<=1;
   first_error_valid<=next_error_valid;first_error_rank<=next_error_rank;first_error_row<=next_error_row;first_error_column<=next_error_column;
   for(int n=0;n<9;n++)begin
    expected_valid[n]<={expected_valid[n][2:0],fp_req_valid[n]&&fp_req_ready[n]};
    expected_tag[n][0]<=fp_req_tag[n][15:0];for(int i=1;i<4;i++)expected_tag[n][i]<=expected_tag[n][i-1];
    if(fp_req_valid[n]&&!fp_req_ready[n])protocol_fault<=1;
    if(fp_rsp_valid[n]&&!matched[n])protocol_fault<=1;
    if(|peer_event[n])protocol_fault<=1;
   end
   for(int slot=0;slot<2;slot++)begin:debt_update
    integer fp_add,fp_sub;
    fp_add=0;fp_sub=0;
    for(int n=0;n<9;n++)begin
     if(fp_req_valid[n]&&fp_req_ready[n]&&fp_req_tag[n][9]==1'(slot))fp_add=fp_add+1;
     if(matched[n]&&fp_rsp_tag[n][9]==1'(slot))fp_sub=fp_sub+1;
    end
    slot_fp_debt[slot]<=8'(int'(slot_fp_debt[slot])+fp_add-fp_sub);
    case({sfu_fire&&sfu_req_tag[9]==1'(slot),sfu_return&&sfu_rsp_tag[9]==1'(slot)})
     2'b10:slot_sfu_debt[slot]<=slot_sfu_debt[slot]+1'b1;2'b01:slot_sfu_debt[slot]<=slot_sfu_debt[slot]-1'b1;default:;
    endcase
    case({accept&&in_tag[9]==1'(slot),consume&&out_tag[9]==1'(slot)})
     2'b10:slot_pending[slot]<=slot_pending[slot]+1'b1;2'b01:slot_pending[slot]<=slot_pending[slot]-1'b1;default:;
    endcase
   end
   case({accept,consume})2'b10:pending<=pending+1'b1;2'b01:pending<=pending-1'b1;default:;endcase
   if(consume)begin live[head_ptr]<=0;available[head_ptr]<=0;sent[head_ptr]<=0;received[head_ptr]<=0;head_ptr<=head_ptr+1'b1;end
   if(accept)begin
    if(!context_valid)begin tag_context<=in_tag[95:32];context_valid<=1;end
    next_input_seq<=next_input_seq+1'b1;
    if(in_tag[7:0]!=reserve_ptr)protocol_fault<=1;
    live[reserve_ptr]<=1;available[reserve_ptr]<=0;sent[reserve_ptr]<=0;received[reserve_ptr]<=0;
    tag_mem_hi[reserve_ptr]<=in_tag[15:8];x_mem[reserve_ptr]<=in_x;gate_mem[reserve_ptr]<=in_gate;
    numeric_bad[reserve_ptr]<=error_event[0];peer_bad[reserve_ptr]<=0;reserve_ptr<=reserve_ptr+1'b1;
   end
   pre_tag[0]<=in_tag[15:0];x_good_pipe[0]<=finite8(in_x);x_delay[0]<=in_x;
   for(int i=1;i<15;i++)begin pre_tag[i]<=pre_tag[i-1];x_good_pipe[i]<=x_good_pipe[i-1];end
   for(int i=1;i<4;i++)x_delay[i]<=x_delay[i-1];
   ugood_delay[0]<=u_ok;for(int i=1;i<4;i++)ugood_delay[i]<=ugood_delay[i-1];
   vgood_delay[0]<=v_ok;for(int i=1;i<3;i++)vgood_delay[i]<=vgood_delay[i-1];
   t_delay[0]<=fp_rsp_data[3];t_tag[0]<=fp_rsp_tag[3][15:0];tgood_delay[0]<=t_ok;t_valid<={t_valid[5:0],matched[3]};
   for(int i=1;i<7;i++)begin t_delay[i]<=t_delay[i-1];t_tag[i]<=t_tag[i-1];tgood_delay[i]<=tgood_delay[i-1];end
   zeligible_delay[0]<=z_eligible;for(int i=1;i<4;i++)zeligible_delay[i]<=zeligible_delay[i-1];
   if(matched[2]&&(!t_valid[6]||t_tag[6]!=fp_rsp_tag[2][15:0]))protocol_fault<=1;
   if(matched[4])z_good_mem[fp_rsp_tag[4][7:0]]<=z_ok;
   for(int rank=0;rank<8;rank++)if(event_valid[rank])begin covered[rank]<=covered[rank]+8;evaluated[rank]<=evaluated[rank]+19'($countones(event_eval[rank]));end
   // u/t share the same physical return edge and reservation, so OR together.
   if(|(error_event[1]|error_event[4]))numeric_bad[pre_tag[3][7:0]]<=numeric_bad[pre_tag[3][7:0]]|error_event[1]|error_event[4];
   for(int rank=2;rank<8;rank++)if(rank!=4&&|error_event[rank])numeric_bad[event_tag[rank][7:0]]<=numeric_bad[event_tag[rank][7:0]]|error_event[rank];
   if(|(peer_event[0]|peer_event[3]))peer_bad[pre_tag[3][7:0]]<=peer_bad[pre_tag[3][7:0]]|peer_event[0]|peer_event[3];
   for(int n=1;n<9;n++)if(n!=3&&|peer_event[n])peer_bad[fp_rsp_tag[n][7:0]]<=peer_bad[fp_rsp_tag[n][7:0]]|peer_event[n];
   if(sfu_fire)sent[sfu_req_tag[7:0]]<=1;
   if(sfu_rsp_valid&&!sfu_match)protocol_fault<=1;
   post_valid<={post_valid[11:0],sfu_return};post_tag[0]<=sfu_rsp_tag[15:0];
   post_good[0]<=z_good_mem[sfu_rsp_tag[7:0]]&~sfu_peer_event;
   if(sfu_return)begin
    received[sfu_rsp_tag[7:0]]<=1;h0<=sfu_rsp_data;x0<=x_mem[sfu_rsp_tag[7:0]];gate_delay[0]<=gate_mem[sfu_rsp_tag[7:0]];
    if(|sfu_peer_event)begin protocol_fault<=1;peer_bad[sfu_rsp_tag[7:0]]<=peer_bad[sfu_rsp_tag[7:0]]|sfu_peer_event;end
   end
   for(int i=1;i<13;i++)begin post_tag[i]<=post_tag[i-1];post_good[i]<=post_good[i-1];end
   for(int i=1;i<9;i++)gate_delay[i]<=gate_delay[i-1];
   r_valid<=matched[5];r_aligned<=fp_rsp_data[5];r_tag<=fp_rsp_tag[5][15:0];
   if(matched[5]&&|(post_good[3]&~finite8(fp_rsp_data[5])))protocol_fault<=1;
   if(matched[6]&&|(post_good[4]&~finite8(fp_rsp_data[6])))protocol_fault<=1;
   if(matched[6]&&(!r_valid||r_tag!=fp_rsp_tag[6][15:0]))protocol_fault<=1;
   yeligible_delay[0]<=y_eligible;geligible_delay[0]<=g_eligible;
   for(int i=1;i<4;i++)begin yeligible_delay[i]<=yeligible_delay[i-1];geligible_delay[i]<=geligible_delay[i-1];end
   if(matched[8])begin
    available[fp_rsp_tag[8][7:0]]<=1;
    for(int l=0;l<8;l++)result_mem[fp_rsp_tag[8][7:0]][l]<=geligible_delay[3][l]&&finite(fp_rsp_data[8][l])?fp_rsp_data[8][l]:0;
   end
  end
 end
endmodule
