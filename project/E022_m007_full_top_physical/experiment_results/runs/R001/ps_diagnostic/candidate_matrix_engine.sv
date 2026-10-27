`timescale 1ns/1ps
// Autonomous single M128xN64. A/W remain the one real public slot services.
// The only physical256mul/add and PS/G/context set are instantiated below.
module laya_m007_matrix_engine_v1 #(parameter bit PROFILE_ENABLE=0)(
 input logic clk,rst_n,
 input logic cmd_valid,output logic cmd_ready,
 input logic [63:0] cmd_request,cmd_model,input logic [31:0] cmd_generation,cmd_epoch,cmd_tensor,
 input logic [15:0] cmd_k,cmd_n,cmd_s,input logic cmd_a_slot,cmd_w_slot,cmd_ctx,cmd_bias,
 input logic [63:0][31:0] cmd_bias_data,input logic run_enable,
 output logic done_valid,input logic done_ready,output logic [2:0] status,
 output logic [63:0] done_request,output logic [31:0] done_generation,
 output logic [6:0] error_row,output logic [15:0] error_col,output logic [7:0] error_group,
 output logic [31:0] elapsed_cycles,output logic [31:0] first_issue_cycle,last_issue_cycle,last_output_cycle,max_issue_commit,max_ps_feedback,output_bubbles,
 output logic out_valid,input logic out_ready,output logic [31:0][31:0] out_data,
 output logic [6:0] out_row,output logic out_half,
 // Metadata taps are wired only to actual consumed completion handshakes.
 input logic a_complete,input logic a_complete_slot,input logic [1:0] a_complete_status,input logic [15:0] a_complete_k,
 input logic [63:0] a_complete_request,input logic [31:0] a_complete_generation,a_complete_epoch,
 input logic w_complete,input logic w_complete_slot,input logic [2:0] w_complete_status,input logic [15:0] w_complete_k,w_complete_n,w_complete_s,
 input logic [63:0] w_complete_request,w_complete_model,input logic [31:0] w_complete_generation,w_complete_tensor,
 // A synchronous II1 record service with separate bounded return debts.
 output logic a_lease_valid,input logic a_lease_ready,output logic a_lease_slot,
 output logic [63:0] a_lease_request,output logic [31:0] a_lease_generation,a_lease_epoch,
 output logic a_rd_valid,input logic a_rd_ready,output logic a_rd_slot,output logic [2:0] a_rd_m,output logic [6:0] a_rd_group,
 output logic [95:0] a_rd_tag,output logic [63:0] a_rd_request,output logic [31:0] a_rd_generation,a_rd_epoch,
 input logic a_rsp_valid,output logic a_rsp_ready,input logic [4351:0] a_rsp_data,input logic [95:0] a_rsp_tag,input logic a_rsp_slot,
 output logic a_ret_valid,input logic a_ret_ready,output logic a_ret_slot,output logic [95:0] a_ret_tag,
 output logic [63:0] a_ret_request,output logic [31:0] a_ret_generation,a_ret_epoch,
 output logic a_release_valid,input logic a_release_ready,output logic a_release_slot,
 output logic [63:0] a_release_request,output logic [31:0] a_release_generation,a_release_epoch,
 // W public read/copy/ret has the measured4cycle acceptance interval.
 output logic w_lease_valid,input logic w_lease_ready,output logic w_lease_slot,
 output logic [63:0] w_lease_request,w_lease_model,output logic [31:0] w_lease_generation,w_lease_tensor,
 output logic w_rd_valid,input logic w_rd_ready,output logic w_rd_slot,output logic [8:0] w_rd_addr,output logic [63:0] w_rd_tag,
 output logic [63:0] w_rd_request,w_rd_model,output logic [31:0] w_rd_generation,w_rd_tensor,
 input logic w_rsp_valid,output logic w_rsp_ready,input logic [4351:0] w_rsp_data,input logic [63:0] w_rsp_tag,input logic w_rsp_slot,
 output logic w_ret_valid,input logic w_ret_ready,output logic w_ret_slot,output logic [63:0] w_ret_tag,w_ret_request,output logic [31:0] w_ret_generation,
 output logic w_release_valid,input logic w_release_ready,output logic w_release_slot,
 output logic [63:0] w_release_request,output logic [31:0] w_release_generation,
 // Read-only verification taps; no fixture can commit storage through these.
 output logic trace_issue,output logic [12:0] trace_issue_seq,output logic [4095:0] trace_a_q,trace_w_q,output logic [255:0] trace_a_scale,trace_w_scale,
 output logic trace_dot,output logic [12:0] trace_dot_seq,output logic [255:0][20:0] trace_dot_data,
 output logic trace_format,output logic [12:0] trace_format_seq,output logic [255:0][31:0] trace_scale_product,trace_converted,
 output logic trace_term,output logic [12:0] trace_term_seq,output logic [255:0][31:0] trace_term_data,
 output logic trace_commit,output logic [12:0] trace_commit_seq,output logic [255:0][31:0] trace_commit_data,
 output logic [6:0] arithmetic_debt,output logic [7:0] peak_return_reservations,
 input logic cmd_first,cmd_last,
 input logic cancel_valid,input logic [2:0] cancel_status,input logic [6:0] cancel_row,input logic [15:0] cancel_col,input logic [7:0] cancel_group,input logic [3:0] cancel_stage,
 output logic block_done_valid,input logic block_done_ready,output logic block_done_ctx,output logic [15:0] block_done_s,
 output logic [15:0] trace_block_s,output logic trace_compute_ctx,
 output logic [15:0] out_block_s,out_col,
 output logic [31:0] ps_merged_reads,ps_response_holds,bias_add_conflicts,compute_output_overlap,
 output logic [1:0][6:0] ctx_bias_reads,ctx_bias_adds,ctx_bias_acks,
 output logic [1:0] ctx_busy_debug,output logic [6:0] peak_arithmetic_reservations,
 output logic [3:0] error_stage
,
 output logic profile_valid,
 output logic [63:0] fp_owner_request,
 output logic [31:0] fp_owner_generation,
 output logic [31:0] fp_owner_epoch,
 output logic bind_new_lease,
 output logic fp_release_valid,
 output logic fp_phase_debt_clear,
 input logic fp_lease_ready,
 input logic fp_release_ready,
 input logic fp_lease_active,
 input logic fp_draining,
 input logic fp_fault,
 input logic storage_bind_ready,
 input logic storage_idle,
 output logic mul_req_valid,
 output logic mul_rsp_ready,
 input logic mul_req_ready,
 input logic mul_rsp_valid,
 output logic [95:0] mul_req_tag,
 input logic [95:0] mul_rsp_tag,
 output logic [255:0][31:0] mul_a,
 output logic [255:0][31:0] mul_b,
 input logic [255:0][31:0] mul_rsp_data,
 input logic [6:0] mul_pending,
 output logic [6:0] add_req_valid,
 output logic [6:0] add_req_is_root,
 output logic [6:0] add_rsp_ready,
 input logic [6:0] add_req_ready,
 input logic [6:0] add_rsp_valid,
 output logic [6:0][2:0] add_req_phase,
 output logic [6:0][31:0] add_req_epoch,
 output logic [6:0][95:0] add_req_tag,
 input logic [6:0][95:0] add_rsp_tag,
 output logic [255:0][31:0] add_a,
 output logic [255:0][31:0] add_b,
 input logic [255:0][31:0] add_rsp_data,
 input logic [6:0][6:0] add_pending,
 output logic ps_wr_valid,
 output logic ps_wr_rsp_ready,
 output logic ps_rd_valid,
 output logic ps_rd_rsp_ready,
 input logic ps_wr_ready,
 input logic ps_wr_rsp_valid,
 input logic ps_rd_ready,
 input logic ps_rd_rsp_valid,
 output logic [1023:0] ps_wr_mask,
 output logic [1023:0] ps_rd_mask,
 input logic [1023:0] ps_rd_rsp_mask,
 output logic [1023:0][3:0] ps_wr_addr,
 output logic [1023:0][3:0] ps_rd_addr,
 output logic [1023:0][31:0] ps_wr_data,
 input logic [1023:0][31:0] ps_rd_rsp_data,
 output logic [95:0] ps_wr_tag,
 output logic [95:0] ps_rd_tag,
 input logic [95:0] ps_wr_rsp_tag,
 input logic [95:0] ps_rd_rsp_tag);
 localparam int IDLE=0,BIND=1,RUN=2,WRELEASE=3,FINALRELEASE=4;
 localparam int EMPTY=0,WAITDOT=1,MULREADY=2,MULWAIT=3,TERMREADY=4,PSWAIT=5,ADDREADY=6,ADDWAIT=7,SUMREADY=8,WRITEWAIT=9;
 logic [2:0]  state;logic matrix_active,last_requested;
 logic [63:0]  request_id,model;logic [31:0]  generation,epoch,tensor;
 logic [15:0]  k,n,s;logic a_slot,w_slot,ctx;logic [7:0]  groups;logic [31:0]  tick;
 logic [1:0]  am_valid,wm_valid;logic [1:0][15:0]  am_k,wm_k,wm_n,wm_s;
 logic [1:0][63:0]  am_request,wm_request,wm_model;logic [1:0][31:0]  am_generation,am_epoch,wm_generation,wm_tensor;
 logic descriptor_ok,aborting;logic [31:0]  error_key;
 logic cycle_numeric,cycle_protocol;logic [31:0]  cycle_numeric_key;integer cycle_r,cycle_c,cycle_g,cycle_stage;
 logic [12:0]  a_next,issue_count,mul_next,ps_next,add_next,write_next,commit_count;
 logic [63:0][3:0]  pool_state;logic [63:0][12:0]  pool_seq;
 logic [8191:0] op0[0:63],op1[0:63];
 logic [6:0]  math_debt,bias_debt;logic [2:0]  retire_debt;logic [9:0]  reserved_vectors;
 logic [1:0]  holding_valid;logic [1:0][8:0]  holding_record;logic [1:0][4351:0]  holding_data;
 logic current_h,request_h,have_current,have_requested,free_h,have_free;logic [1:0]  w_state;logic w_target;logic [9:0]  fetch_record;logic [63:0]  pending_w_tag;
 logic [1:0]  ctx_busy,ctx_math_done,ctx_bias,ctx_bias_started,ctx_bias_done;
 logic [1:0][15:0]  ctx_s;logic [1:0][12:0]  ctx_committed;logic [1:0][63:0][31:0]  ctx_bias_data;
 logic bias_active,bias_ctx;logic [5:0]  bias_next;
 logic retire_active,retire_ctx;logic [15:0]  retire_expected_s;logic [8:0]  retire_next,retire_count;
 logic out_hold_valid;logic [31:0][31:0]  out_hold_data,retire_read_data;logic [7:0]  out_hold_beat;logic out_hold_ctx;
 
 logic bind_fire,fast_cmd_bind,release_a_done,release_fp_done,w_release_done,a_w_guaranteed;
 logic dot_ready,dot_valid;logic [95:0]  dot_tag,issue_tag;logic [255:0][20:0]  dots;
 logic format_valid;logic [95:0]  format_tag;logic [255:0][31:0]  converted,products;logic [255:0]  format_errors;
 
 
 
 
 
 
 
 
 logic math_read_part,bias_read_part,retire_read_part,bias_read_fire,retire_read_fire,math_read_fire;
 logic normal_write_ack,bias_write_ack,bias_add_fire,math_add_fire,ps_rsp_bias,ps_rsp_retire,ps_rsp_math;
 integer i,bank_index,room;
 function automatic [95:0] tag(input logic kind,input logic which_ctx,input logic [12:0] seq);
  return {epoch,generation,which_ctx,kind,17'b0,seq};
 endfunction
 function automatic [15:0] global_column(input logic [15:0] block_s,input integer local_n);
  if(n==5248)return 32*block_s+(local_n%32)+((local_n>=32)?2624:0);
  return 64*block_s+local_n;
 endfunction
 task automatic numeric_candidate(input integer r,c,g,stage);
  logic [31:0] candidate;
  begin candidate=(r*8192+c)*256+g;
   if(!cycle_numeric||candidate<cycle_numeric_key)begin cycle_numeric=1;cycle_numeric_key=candidate;cycle_r=r;cycle_c=c;cycle_g=g;cycle_stage=stage;end
  end
 endtask
 assign arithmetic_debt=math_debt+bias_debt;
 assign reserved_vectors={3'b0,math_debt}+{3'b0,bias_debt}+{7'b0,retire_debt}+{3'b0,mul_pending}+{3'b0,add_pending[0]};
 assign ctx_busy_debug=ctx_busy;assign trace_block_s=s;assign trace_compute_ctx=ctx;
 // PS representation diagnostic: fixed bank b={context,row,half,column}.
 generate for(genvar bank=0;bank<1024;bank++)begin:g_ps_static_bank
  localparam int C=bank/512,A=(bank%512)/32,H=(bank%32)/16,J=bank%16;
  always_comb begin
   ps_rd_mask[bank]=0;ps_rd_addr[bank]=0;
   if(math_read_part&&ctx==C&&ps_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*ps_next[2:0]+ps_next[4];end
   if(bias_read_part&&bias_ctx==C&&bias_next[3]==H)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*bias_next[2:0]+bias_next[4];end
   if(retire_read_part&&retire_ctx==C&&retire_next[4:1]==A)begin ps_rd_mask[bank]=1;ps_rd_addr[bank]=2*retire_next[7:5]+retire_next[0];end
   ps_wr_mask[bank]=0;ps_wr_addr[bank]=0;ps_wr_data[bank]=0;
   if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin
    if(add_rsp_tag[0][31]==C&&add_rsp_tag[0][3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*add_rsp_tag[0][2:0]+add_rsp_tag[0][4];ps_wr_data[bank]=add_rsp_data[16*A+J];end
   end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin
    if(ctx==C&&write_next[3]==H)begin ps_wr_mask[bank]=1;ps_wr_addr[bank]=2*write_next[2:0]+write_next[4];ps_wr_data[bank]=op0[write_next[5:0]][32*(16*A+J)+:32];end
   end
  end
 end endgenerate
 always_comb begin
  descriptor_ok=((cmd_k==1024&&(cmd_n==1024||cmd_n==3072||cmd_n==5248||cmd_n==4096))||(cmd_n==1024&&(cmd_k==2624||cmd_k==4096)))&&cmd_s<((cmd_n==5248)?82:(cmd_n>>6));
  descriptor_ok=descriptor_ok&&am_valid[cmd_a_slot]&&am_k[cmd_a_slot]==cmd_k&&am_request[cmd_a_slot]==cmd_request&&am_generation[cmd_a_slot]==cmd_generation&&am_epoch[cmd_a_slot]==cmd_epoch;
  descriptor_ok=descriptor_ok&&wm_valid[cmd_w_slot]&&wm_k[cmd_w_slot]==cmd_k&&wm_n[cmd_w_slot]==cmd_n&&wm_s[cmd_w_slot]==cmd_s&&wm_request[cmd_w_slot]==cmd_request&&wm_generation[cmd_w_slot]==cmd_generation&&wm_model[cmd_w_slot]==cmd_model&&wm_tensor[cmd_w_slot]==cmd_tensor;
  if(matrix_active)descriptor_ok=descriptor_ok&&!cmd_first&&cmd_request==request_id&&cmd_generation==generation&&cmd_epoch==epoch&&cmd_model==model&&cmd_tensor==tensor&&cmd_k==k&&cmd_n==n&&cmd_a_slot==a_slot;
  else descriptor_ok=descriptor_ok&&cmd_first;
  cmd_ready=state==IDLE&&!done_valid&&(!block_done_valid||block_done_ready)&&!aborting&&!ctx_busy[cmd_ctx]&&(!matrix_active||(!last_requested&&w_lease_ready));
  fast_cmd_bind=cmd_valid&&cmd_ready&&descriptor_ok&&matrix_active;
  bind_fire=state==BIND&&w_lease_ready&&(matrix_active||(a_lease_ready&&fp_lease_ready&&storage_bind_ready));bind_new_lease=bind_fire&&!matrix_active;
  a_lease_valid=bind_new_lease;a_lease_slot=a_slot;a_lease_request=request_id;a_lease_generation=generation;a_lease_epoch=epoch;
  w_lease_valid=bind_fire||fast_cmd_bind;w_lease_slot=(state==IDLE&&matrix_active)?cmd_w_slot:w_slot;w_lease_request=request_id;w_lease_generation=generation;w_lease_model=model;w_lease_tensor=tensor;
  have_current=0;current_h=0;have_requested=0;request_h=0;have_free=0;free_h=0;
  for(integer h=0;h<2;h++)begin
   if(holding_valid[h]&&holding_record[h]==issue_count[11:3])begin have_current=1;current_h=h;end
   if(holding_valid[h]&&holding_record[h]==a_next[11:3])begin have_requested=1;request_h=h;end
   if(!holding_valid[h])begin have_free=1;free_h=h;end
  end
  normal_write_ack=ps_wr_rsp_valid&&!ps_wr_rsp_tag[30];bias_write_ack=ps_wr_rsp_valid&&ps_wr_rsp_tag[30];
  room=64-arithmetic_debt+normal_write_ack+bias_write_ack;
  a_rd_valid=0;
  a_rd_slot=a_slot;a_rd_m=a_next[2:0];a_rd_group=a_next[11:5];a_rd_tag=tag(0,ctx,a_next);a_rd_request=request_id;a_rd_generation=generation;a_rd_epoch=epoch;
  a_rsp_ready=state==RUN&&have_current&&(!a_ret_valid||a_ret_ready)&&dot_ready;
  a_ret_slot=a_slot;a_ret_request=request_id;a_ret_generation=generation;a_ret_epoch=epoch;
  w_rd_valid=state==RUN&&!aborting&&w_state==0&&have_free&&fetch_record<4*groups;
  w_rd_slot=w_slot;w_rd_addr=fetch_record[8:0];w_rd_tag={epoch,22'b0,fetch_record};w_rd_request=request_id;w_rd_generation=generation;w_rd_model=model;w_rd_tensor=tensor;
  w_rsp_ready=w_state==1;w_ret_valid=w_state==2;w_ret_slot=w_slot;w_ret_tag=pending_w_tag;w_ret_request=request_id;w_ret_generation=generation;
  a_release_valid=state==FINALRELEASE&&!release_a_done;a_release_slot=a_slot;a_release_request=request_id;a_release_generation=generation;a_release_epoch=epoch;
  w_release_valid=!w_release_done&&(state==WRELEASE||(state==RUN&&issue_count==k&&!a_ret_valid&&w_state==0));w_release_slot=w_slot;w_release_request=request_id;w_release_generation=generation;
  trace_issue=a_rsp_valid&&a_rsp_ready;trace_issue_seq=issue_count;issue_tag=tag(0,ctx,issue_count);trace_a_q=a_rsp_data[4095:0];trace_a_scale=a_rsp_data[4351:4096];trace_w_q=holding_data[current_h][4095:0];trace_w_scale=holding_data[current_h][4351:4096];
  trace_dot=dot_valid;trace_dot_seq=dot_tag[12:0];trace_dot_data=dots;trace_format=format_valid;trace_format_seq=format_tag[12:0];trace_scale_product=products;trace_converted=converted;
  mul_req_valid=state==RUN&&mul_next<issue_count&&pool_state[mul_next[5:0]]==MULREADY;mul_req_tag=tag(0,ctx,mul_next);mul_a=op0[mul_next[5:0]];mul_b=op1[mul_next[5:0]];mul_rsp_ready=1;
  trace_term=mul_rsp_valid&&mul_rsp_ready;trace_term_seq=mul_rsp_tag[12:0];trace_term_data=mul_rsp_data;
  // A single atomic PS read carries all selected, pre-reserved destinations.
  math_read_part=state==RUN&&ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next>=32&&commit_count>ps_next-32;
  bias_read_part=bias_active&&!aborting&&bias_next<32&&ctx_committed[bias_ctx]>k-32+bias_next&&room>0;
  retire_read_part=retire_active&&!aborting&&retire_next<256&&(!out_hold_valid||out_ready);
  if(math_read_part&&bias_read_part&&ctx==bias_ctx)math_read_part=0;
  if(retire_read_part&&((math_read_part&&ctx==retire_ctx)||(bias_read_part&&bias_ctx==retire_ctx)))retire_read_part=0;
  ps_rd_valid=math_read_part||bias_read_part||retire_read_part;
  ps_rd_tag={epoch,generation,math_read_part,bias_read_part,retire_read_part,ctx,bias_ctx,retire_ctx,ps_next,bias_next[4:0],retire_next[7:0]};
  math_read_fire=ps_rd_valid&&ps_rd_ready&&math_read_part;bias_read_fire=ps_rd_valid&&ps_rd_ready&&bias_read_part;retire_read_fire=ps_rd_valid&&ps_rd_ready&&retire_read_part;
  // Reserve A only when the matching W payload is held or its real read is already accepted/accepting.
  a_w_guaranteed=have_requested||(w_state==1&&pending_w_tag[8:0]==a_next[11:3])||(w_rd_valid&&w_rd_ready&&w_rd_addr==a_next[11:3]);
  a_rd_valid=state==RUN&&!aborting&&run_enable&&a_next<k&&room>(bias_read_fire?1:0)&&a_w_guaranteed;
  ps_rsp_math=ps_rd_rsp_tag[31];ps_rsp_bias=ps_rd_rsp_tag[30];ps_rsp_retire=ps_rd_rsp_tag[29];
  add_req_valid=0;add_req_is_root=0;add_req_phase='{default:3'd1};add_req_epoch='{default:epoch};add_req_tag=0;add_a=0;add_b=0;
  if(ps_rd_rsp_valid&&ps_rsp_bias&&(!ps_rsp_retire||!out_hold_valid||out_ready))begin
   add_req_valid[0]=1;add_req_tag[0]=tag(1,ps_rd_rsp_tag[27],{8'b0,ps_rd_rsp_tag[12:8]});
   for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin bank_index=512*ps_rd_rsp_tag[27]+32*a+16*ps_rd_rsp_tag[11]+c;add_a[16*a+c]=ps_rd_rsp_data[bank_index];add_b[16*a+c]=ctx_bias_data[ps_rd_rsp_tag[27]][16*ps_rd_rsp_tag[12:11]+c];end
  end else if(state==RUN&&add_next<issue_count&&pool_state[add_next[5:0]]==ADDREADY)begin
   add_req_valid[0]=1;add_req_tag[0]=tag(0,ctx,add_next);add_a=op0[add_next[5:0]];add_b=op1[add_next[5:0]];
  end
  ps_rd_rsp_ready=(!ps_rsp_retire||!out_hold_valid||out_ready)&&(!ps_rsp_bias||add_req_ready[0]);
  bias_add_fire=add_req_valid[0]&&add_req_ready[0]&&add_req_tag[0][30];math_add_fire=add_req_valid[0]&&add_req_ready[0]&&!add_req_tag[0][30];
  // Old-context bias writes get explicit priority; math writes remain in their reserved pool slots.
  ps_wr_valid=0;ps_wr_tag=0;
  if(add_rsp_valid[0]&&add_rsp_tag[0][30])begin
   ps_wr_valid=1;ps_wr_tag=add_rsp_tag[0];
  end else if(state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY)begin
   ps_wr_valid=1;ps_wr_tag=tag(0,ctx,write_next);
  end
  add_rsp_ready=7'b0000001;if(add_rsp_tag[0][30])add_rsp_ready[0]=ps_wr_ready;
  trace_commit=normal_write_ack;trace_commit_seq=ps_wr_rsp_tag[12:0];trace_commit_data=op0[ps_wr_rsp_tag[5:0]];
  retire_read_data=0;
  for(integer c=0;c<32;c++)begin bank_index=512*ps_rd_rsp_tag[26]+32*ps_rd_rsp_tag[4:1]+c;retire_read_data[c]=ps_rd_rsp_data[bank_index];end
  out_valid=out_hold_valid;out_data=out_hold_data;out_row=out_hold_beat[7:1];out_half=out_hold_beat[0];out_block_s=ctx_s[out_hold_ctx];out_col=global_column(ctx_s[out_hold_ctx],32*out_hold_beat[0]);
 end
 laya_m007_matrix_dot_v1 dot_array(.clk,.rst_n,.req_valid(trace_issue),.req_ready(dot_ready),.req_tag(issue_tag),.a(trace_a_q),.w(trace_w_q),.rsp_valid(dot_valid),.rsp_tag(dot_tag),.dot(dots));
 laya_m007_matrix_format_v1 format(.clk,.rst_n,.issue_valid(trace_issue),.issue_tag(issue_tag),.a_scale(trace_a_scale),.w_scale(trace_w_scale),.dot_valid,.dot_tag,.dot(dots),.rsp_valid(format_valid),.rsp_tag(format_tag),.converted,.scale_product(products),.domain_error(format_errors));

 assign fp_owner_request=request_id;assign fp_owner_generation=generation;assign fp_owner_epoch=epoch;
 assign fp_release_valid=state==FINALRELEASE&&!release_fp_done;
 assign fp_phase_debt_clear=arithmetic_debt==0&&retire_debt==0&&storage_idle&&!a_ret_valid&&w_state==0&&!out_hold_valid;
 assign ps_wr_rsp_ready=1'b1;
 assign profile_valid=PROFILE_ENABLE;
 generate if(PROFILE_ENABLE)begin:g_profile
  logic [63:0][31:0] issue_time,ps_time;
  always_ff @(posedge clk)begin
   if(!rst_n)begin max_issue_commit<=0;max_ps_feedback<=0;end
   else begin
    if(cmd_valid&&cmd_ready&&descriptor_ok&&!matrix_active)begin max_issue_commit<=0;max_ps_feedback<=0;end
    if(trace_issue)issue_time[issue_count[5:0]]<=tick;
    if(state==RUN&&ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32)ps_time[ps_next[5:0]]<=tick;
    if(math_read_fire)ps_time[ps_next[5:0]]<=tick;
    if(state==RUN&&normal_write_ack)begin
     if(tick-issue_time[ps_wr_rsp_tag[5:0]]>max_issue_commit)max_issue_commit<=tick-issue_time[ps_wr_rsp_tag[5:0]];
     if(tick-ps_time[ps_wr_rsp_tag[5:0]]>max_ps_feedback)max_ps_feedback<=tick-ps_time[ps_wr_rsp_tag[5:0]];
    end
   end
  end
 end else begin:g_no_profile
  assign max_issue_commit=32'b0;assign max_ps_feedback=32'b0;
 end endgenerate
 // D38: same asynchronous pools, static slot LHS and unchanged write priority.
 generate for(genvar slot=0;slot<64;slot++)begin:g_operand_slot
  always_ff @(posedge clk)begin
   if(!rst_n)begin
   end else begin
    if(state==RUN)begin
     if(format_valid&&format_tag[5:0]==slot)begin
      op0[slot]<=converted;op1[slot]<=products;
     end
     if(mul_rsp_valid&&mul_rsp_ready&&mul_rsp_tag[5:0]==slot)op0[slot]<=mul_rsp_data;
     if(ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32&&ps_next[5:0]==slot)op1[slot]<='0;
    end
    if(ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_math&&ps_rd_rsp_tag[18:13]==slot)begin
     for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)op1[slot][32*(16*a+c)+:32]<=ps_rd_rsp_data[512*ps_rd_rsp_tag[28]+32*a+16*ps_rd_rsp_tag[16]+c];
    end
    if(add_rsp_valid[0]&&add_rsp_ready[0]&&!add_rsp_tag[0][30]&&add_rsp_tag[0][5:0]==slot)op0[slot]<=add_rsp_data;
   end
  end
 end endgenerate
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;matrix_active<=0;last_requested<=0;done_valid<=0;status<=0;request_id<=0;model<=0;generation<=0;epoch<=0;tensor<=0;k<=0;n<=0;s<=0;a_slot<=0;w_slot<=0;ctx<=0;groups<=0;tick<=0;
   am_valid<=0;wm_valid<=0;am_k<=0;wm_k<=0;wm_n<=0;wm_s<=0;am_request<=0;wm_request<=0;wm_model<=0;am_generation<=0;am_epoch<=0;wm_generation<=0;wm_tensor<=0;
   a_next<=0;issue_count<=0;mul_next<=0;ps_next<=0;add_next<=0;write_next<=0;commit_count<=0;math_debt<=0;bias_debt<=0;retire_debt<=0;
   holding_valid<=0;w_state<=0;fetch_record<=0;w_target<=0;pending_w_tag<=0;a_ret_valid<=0;a_ret_tag<=0;aborting<=0;error_key<='1;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;
   ctx_busy<=0;ctx_math_done<=0;ctx_bias<=0;ctx_bias_started<=0;ctx_bias_done<=0;ctx_s<=0;ctx_committed<=0;ctx_bias_reads<=0;ctx_bias_adds<=0;ctx_bias_acks<=0;
   bias_active<=0;bias_ctx<=0;bias_next<=0;retire_active<=0;retire_ctx<=0;retire_expected_s<=0;retire_next<=0;retire_count<=0;out_hold_valid<=0;out_hold_data<=0;out_hold_beat<=0;out_hold_ctx<=0;
   release_a_done<=0;release_fp_done<=0;w_release_done<=0;done_request<=0;done_generation<=0;elapsed_cycles<=0;first_issue_cycle<=0;last_issue_cycle<=0;last_output_cycle<=0;output_bubbles<=0;peak_return_reservations<=0;peak_arithmetic_reservations<=0;
   block_done_valid<=0;block_done_ctx<=0;block_done_s<=0;ps_merged_reads<=0;ps_response_holds<=0;bias_add_conflicts<=0;compute_output_overlap<=0;
   for(i=0;i<64;i++)begin pool_state[i]<=EMPTY;pool_seq[i]<=0;end
  end else begin
   cycle_numeric=0;cycle_protocol=0;cycle_numeric_key='1;cycle_r=0;cycle_c=0;cycle_g=0;cycle_stage=0;
   if(done_valid&&done_ready)done_valid<=0;
   if(block_done_valid&&block_done_ready)block_done_valid<=0;
   if(a_complete)begin am_valid[a_complete_slot]<=a_complete_status==0;am_k[a_complete_slot]<=a_complete_k;am_request[a_complete_slot]<=a_complete_request;am_generation[a_complete_slot]<=a_complete_generation;am_epoch[a_complete_slot]<=a_complete_epoch;end
   if(w_complete)begin wm_valid[w_complete_slot]<=w_complete_status==0;wm_k[w_complete_slot]<=w_complete_k;wm_n[w_complete_slot]<=w_complete_n;wm_s[w_complete_slot]<=w_complete_s;wm_request[w_complete_slot]<=w_complete_request;wm_generation[w_complete_slot]<=w_complete_generation;wm_model[w_complete_slot]<=w_complete_model;wm_tensor[w_complete_slot]<=w_complete_tensor;end
   if(matrix_active||state==BIND)tick<=tick+1;
   if(reserved_vectors>peak_return_reservations)peak_return_reservations<=reserved_vectors;
   if(arithmetic_debt>peak_arithmetic_reservations)peak_arithmetic_reservations<=arithmetic_debt;
   if(ps_rd_valid&&ps_rd_ready&&({2'b0,math_read_part}+{2'b0,bias_read_part}+{2'b0,retire_read_part}>3'd1))ps_merged_reads<=ps_merged_reads+1;
   if(ps_rd_rsp_valid&&!ps_rd_rsp_ready)ps_response_holds<=ps_response_holds+1;
   if(ps_rd_rsp_valid&&ps_rsp_bias&&state==RUN&&add_next<issue_count&&pool_state[add_next[5:0]]==ADDREADY)bias_add_conflicts<=bias_add_conflicts+1;
   if(trace_issue&&out_valid&&out_ready)compute_output_overlap<=compute_output_overlap+1;
   if(cmd_valid&&cmd_ready)begin
    if(!descriptor_ok)begin
     if(matrix_active)begin cycle_protocol=1;end
     else begin done_valid<=1;done_request<=cmd_request;done_generation<=cmd_generation;status<=1;end
    end else begin
     request_id<=cmd_request;model<=cmd_model;generation<=cmd_generation;epoch<=cmd_epoch;tensor<=cmd_tensor;k<=cmd_k;n<=cmd_n;s<=cmd_s;a_slot<=cmd_a_slot;w_slot<=cmd_w_slot;ctx<=cmd_ctx;groups<=cmd_k>>5;last_requested<=cmd_last;
     if(!matrix_active)begin
      done_request<=cmd_request;done_generation<=cmd_generation;status<=0;aborting<=0;error_key<='1;error_row<=0;error_col<=0;error_group<=0;error_stage<=0;tick<=0;elapsed_cycles<=0;output_bubbles<=0;last_output_cycle<=0;peak_return_reservations<=0;peak_arithmetic_reservations<=0;
      ps_merged_reads<=0;ps_response_holds<=0;bias_add_conflicts<=0;compute_output_overlap<=0;retire_expected_s<=cmd_s;release_a_done<=0;release_fp_done<=0;
     end
     ctx_busy[cmd_ctx]<=1;ctx_math_done[cmd_ctx]<=0;ctx_bias[cmd_ctx]<=cmd_bias;ctx_bias_started[cmd_ctx]<=0;ctx_bias_done[cmd_ctx]<=!cmd_bias;ctx_s[cmd_ctx]<=cmd_s;ctx_committed[cmd_ctx]<=0;ctx_bias_data[cmd_ctx]<=cmd_bias_data;ctx_bias_reads[cmd_ctx]<=0;ctx_bias_adds[cmd_ctx]<=0;ctx_bias_acks[cmd_ctx]<=0;
     state<=matrix_active?RUN:BIND;w_release_done<=0;a_next<=0;issue_count<=0;mul_next<=0;ps_next<=0;add_next<=0;write_next<=0;commit_count<=0;math_debt<=0;holding_valid<=0;w_state<=0;fetch_record<=0;a_ret_valid<=0;first_issue_cycle<=0;last_issue_cycle<=0;
     for(i=0;i<64;i++)pool_state[i]<=EMPTY;
    end
   end
   if(state==BIND)begin
    if(!w_lease_ready||(!matrix_active&&!a_lease_ready))begin
     if(matrix_active)begin cycle_protocol=1;state<=IDLE;ctx_busy[ctx]<=0;end
     else begin state<=IDLE;ctx_busy[ctx]<=0;done_valid<=1;status<=1;end
    end else if(bind_fire)begin state<=RUN;matrix_active<=1;end
   end
   if(a_ret_valid&&a_ret_ready)a_ret_valid<=0;
   // Ret uses only the actual accepted read ledger after the real payload copy.
   if(w_rd_valid&&w_rd_ready)begin w_state<=1;w_target<=free_h;fetch_record<=fetch_record+1;pending_w_tag<=w_rd_tag;end
   if(w_rsp_valid&&w_rsp_ready)begin
    holding_data[w_target]<=w_rsp_data;holding_record[w_target]<=pending_w_tag[8:0];holding_valid[w_target]<=1;w_state<=2;
    if(w_rsp_slot!=w_slot||w_rsp_tag!=pending_w_tag)cycle_protocol=1;
    for(i=0;i<16;i++)if(w_rsp_data[4096+16*i+10+:5]==31||(w_rsp_data[4096+16*i+15]&&w_rsp_data[4096+16*i+:15]!=0))numeric_candidate(0,global_column(s,16*pending_w_tag[1:0]+i),pending_w_tag[8:2],1);
   end
   if(w_ret_valid&&w_ret_ready)w_state<=0;
   if(state==RUN)begin
    if(trace_issue)begin
     if(a_rsp_slot!=a_slot||a_rsp_tag!=issue_tag)cycle_protocol=1;
     issue_count<=issue_count+1;a_ret_valid<=1;a_ret_tag<=issue_tag;
     if(issue_count==0)first_issue_cycle<=tick;last_issue_cycle<=tick;
     if(issue_count[2:0]==7)holding_valid[current_h]<=0;
    end
    case({a_rd_valid&&a_rd_ready,normal_write_ack})2'b10:math_debt<=math_debt+1;2'b01:math_debt<=math_debt-1;default:;endcase
    if(format_valid)begin
     if(pool_state[format_tag[5:0]]!=WAITDOT||pool_seq[format_tag[5:0]]!=format_tag[12:0]||format_tag[31]!=ctx)cycle_protocol=1;
     pool_state[format_tag[5:0]]<=MULREADY;
     for(i=0;i<256;i++)if(format_errors[i])numeric_candidate(16*format_tag[2:0]+i/16,global_column(s,16*format_tag[4:3]+i%16),format_tag[11:5],2);
    end
    if(mul_req_valid&&mul_req_ready)begin pool_state[mul_next[5:0]]<=MULWAIT;mul_next<=mul_next+1;end
    if(mul_rsp_valid&&mul_rsp_ready)begin
     if(pool_state[mul_rsp_tag[5:0]]!=MULWAIT)cycle_protocol=1;
     pool_state[mul_rsp_tag[5:0]]<=TERMREADY;
     for(i=0;i<256;i++)if(mul_rsp_data[i][30:23]==255)numeric_candidate(16*mul_rsp_tag[2:0]+i/16,global_column(s,16*mul_rsp_tag[4:3]+i%16),mul_rsp_tag[11:5],3);
    end
    if(ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32)begin pool_state[ps_next[5:0]]<=ADDREADY;ps_next<=ps_next+1;end
    if(math_read_fire)begin pool_state[ps_next[5:0]]<=PSWAIT;ps_next<=ps_next+1;end
    if(math_add_fire)begin pool_state[add_next[5:0]]<=ADDWAIT;add_next<=add_next+1;end
    if(ps_wr_valid&&ps_wr_ready&&!ps_wr_tag[30])begin pool_state[write_next[5:0]]<=WRITEWAIT;write_next<=write_next+1;end
    if(normal_write_ack)begin
     if(pool_state[ps_wr_rsp_tag[5:0]]!=WRITEWAIT||ps_wr_rsp_tag[12:0]!=commit_count||ps_wr_rsp_tag[31]!=ctx)cycle_protocol=1;
     pool_state[ps_wr_rsp_tag[5:0]]<=EMPTY;commit_count<=commit_count+1;ctx_committed[ctx]<=ctx_committed[ctx]+1;
     if(commit_count+1==k)ctx_math_done[ctx]<=1;
    end
    // Same-edge commit/allocate reuses one real token without an II bubble.
    if(a_rd_valid&&a_rd_ready)begin a_next<=a_next+1;pool_state[a_next[5:0]]<=WAITDOT;pool_seq[a_next[5:0]]<=a_next;end
    if(!a_ret_valid&&w_state==0&&((!aborting&&((math_debt==0&&commit_count==k)||(normal_write_ack&&commit_count+1==k)))||(aborting&&math_debt==0&&!a_rsp_valid)))begin
     holding_valid<=0;
     if(w_release_done)begin state<=IDLE;block_done_valid<=1;block_done_ctx<=ctx;block_done_s<=s;end
     else state<=WRELEASE;
    end
   end
   if(ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_math)begin
    if(ps_rd_rsp_tag[28]!=ctx||pool_state[ps_rd_rsp_tag[18:13]]!=PSWAIT)cycle_protocol=1;
    
    pool_state[ps_rd_rsp_tag[18:13]]<=ADDREADY;
   end
   if(add_rsp_valid[0]&&add_rsp_ready[0]&&!add_rsp_tag[0][30])begin
    if(pool_state[add_rsp_tag[0][5:0]]!=ADDWAIT||add_rsp_tag[0][31]!=ctx)cycle_protocol=1;
    pool_state[add_rsp_tag[0][5:0]]<=SUMREADY;
    for(i=0;i<256;i++)if(add_rsp_data[i][30:23]==255)numeric_candidate(16*add_rsp_tag[0][2:0]+i/16,global_column(s,16*add_rsp_tag[0][4:3]+i%16),add_rsp_tag[0][11:5],4);
   end
   // In-place bias can start after all math adds are actually issued, while each read waits its real final-group commit.
   if(!bias_active&&!aborting&&state==RUN&&ctx_bias[ctx]&&!ctx_bias_started[ctx]&&add_next==k)begin bias_active<=1;bias_ctx<=ctx;bias_next<=0;ctx_bias_started[ctx]<=1;end
   if(bias_read_fire)begin bias_next<=bias_next+1;ctx_bias_reads[bias_ctx]<=ctx_bias_reads[bias_ctx]+1;end
   if(bias_add_fire)ctx_bias_adds[add_req_tag[0][31]]<=ctx_bias_adds[add_req_tag[0][31]]+1;
   case({bias_read_fire,bias_write_ack})2'b10:bias_debt<=bias_debt+1;2'b01:bias_debt<=bias_debt-1;default:;endcase
   if(bias_write_ack)begin
    if(ctx_bias_acks[ps_wr_rsp_tag[31]]!=ps_wr_rsp_tag[4:0])cycle_protocol=1;
    ctx_bias_acks[ps_wr_rsp_tag[31]]<=ctx_bias_acks[ps_wr_rsp_tag[31]]+1;
    if(ctx_bias_acks[ps_wr_rsp_tag[31]]==31)begin ctx_bias_done[ps_wr_rsp_tag[31]]<=1;bias_active<=0;end
   end
   if(add_rsp_valid[0]&&add_rsp_ready[0]&&add_rsp_tag[0][30])for(i=0;i<256;i++)if(add_rsp_data[i][30:23]==255)numeric_candidate(16*add_rsp_tag[0][2:0]+i/16,global_column(ctx_s[add_rsp_tag[0][31]],16*add_rsp_tag[0][4:3]+i%16),groups,5);
   if(!retire_active&&!aborting)for(integer h=0;h<2;h++)if(ctx_busy[h]&&ctx_math_done[h]&&ctx_bias_done[h]&&ctx_s[h]==retire_expected_s)begin retire_active<=1;retire_ctx<=h;retire_next<=0;retire_count<=0;end
   if(retire_read_fire)retire_next<=retire_next+1;
   case({retire_read_fire,out_valid&&out_ready})2'b10:retire_debt<=retire_debt+1;2'b01:retire_debt<=retire_debt-1;default:;endcase
   if(out_hold_valid&&out_ready)out_hold_valid<=0;
   if(ps_rd_rsp_valid&&ps_rd_rsp_ready&&ps_rsp_retire)begin
    out_hold_valid<=1;out_hold_ctx<=ps_rd_rsp_tag[26];out_hold_beat<=ps_rd_rsp_tag[7:0];
    out_hold_data<=retire_read_data;
   end
   if(out_valid&&out_ready)begin
    if(!retire_active||out_hold_ctx!=retire_ctx||out_hold_beat!=retire_count[7:0]||!ctx_math_done[retire_ctx]||!ctx_bias_done[retire_ctx])cycle_protocol=1;
    retire_count<=retire_count+1;last_output_cycle<=tick;
    for(i=0;i<32;i++)if(out_data[i][30:23]==255)numeric_candidate(out_row,global_column(ctx_s[out_hold_ctx],32*out_half+i),groups,6);
    if(retire_count==255)begin
     if(retire_debt!=1||retire_next!=256)cycle_protocol=1;
     ctx_busy[retire_ctx]<=0;retire_active<=0;retire_expected_s<=retire_expected_s+1;
    end
   end
   if(retire_active&&retire_count!=0&&retire_count<256&&!out_valid)output_bubbles<=output_bubbles+1;
   if(w_release_valid&&w_release_ready)w_release_done<=1;
   if(state==WRELEASE&&(w_release_done||(w_release_valid&&w_release_ready)))begin
    state<=IDLE;block_done_valid<=1;block_done_ctx<=ctx;block_done_s<=s;
   end
   if(matrix_active&&state==IDLE&&((last_requested&&ctx_busy==0)||(aborting&&math_debt==0&&bias_debt==0&&retire_debt==0&&!out_hold_valid&&w_state==0)))begin state<=FINALRELEASE;release_a_done<=0;release_fp_done<=0;end
   if(state==FINALRELEASE)begin
    if(a_release_valid&&a_release_ready)release_a_done<=1;
    if(!release_fp_done&&fp_release_ready)release_fp_done<=1;
    if(release_a_done&&release_fp_done&&storage_idle)begin state<=IDLE;matrix_active<=0;done_valid<=1;elapsed_cycles<=tick;aborting<=0;ctx_busy<=0;end
   end
   if(aborting)begin
    if(bias_debt==0)bias_active<=0;
    if(retire_debt==0&&!out_hold_valid)begin retire_active<=0;ctx_busy<=0;end
   end
   if(fp_fault)cycle_protocol=1;
   if(cancel_valid&&matrix_active)begin
    aborting<=1;
    if(cancel_status==3||status==3)begin status<=3;cycle_protocol=1;end
    else if(cancel_status==2)begin status<=2;numeric_candidate(cancel_row,cancel_col,cancel_group,cancel_stage);end
    else begin status<=cancel_status;end
   end
   if(cycle_numeric)begin aborting<=1;if(status!=3)status<=2;if(cycle_numeric_key<error_key)begin error_key<=cycle_numeric_key;error_row<=cycle_r;error_col<=cycle_c;error_group<=cycle_g;error_stage<=cycle_stage;end end
   if(cycle_protocol)begin status<=3;aborting<=1;error_stage<=7;end
   // A repeated parent cancel may still update the final error above. Once
   // actual A/FP release and PS idle already completed, the inactive request
   // must not retain a stale abort latch and block the next real identity.
   if(state==FINALRELEASE&&release_a_done&&release_fp_done&&storage_idle)aborting<=0;
  end
 end
endmodule
