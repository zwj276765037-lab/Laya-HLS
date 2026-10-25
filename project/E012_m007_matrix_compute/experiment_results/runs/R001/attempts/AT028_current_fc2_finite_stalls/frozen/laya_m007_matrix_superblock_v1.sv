`timescale 1ns/1ps
// Autonomous single M128xN64. A/W remain the one real public slot services.
// The only physical256mul/add and PS/G/context set are instantiated below.
module laya_m007_matrix_superblock_v1(
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
 output logic [6:0] arithmetic_debt,output logic [7:0] peak_return_reservations
);
 localparam int IDLE=0,BIND=1,RUN=2,OUTPUT=3,RELEASE=4;
 localparam int EMPTY=0,WAITDOT=1,MULREADY=2,MULWAIT=3,TERMREADY=4,PSWAIT=5,ADDREADY=6,ADDWAIT=7,SUMREADY=8,WRITEWAIT=9;
 logic [2:0] state;logic [63:0] request_id,model;logic [31:0] generation,epoch,tensor;
 logic [15:0] k,n,s;logic a_slot,w_slot,ctx,bias;
 logic [63:0][31:0] bias_data;logic [7:0] groups;logic [31:0] tick;
 logic [1:0] am_valid,wm_valid;logic [1:0][15:0] am_k,wm_k,wm_n,wm_s;
 logic [1:0][63:0] am_request,wm_request,wm_model;logic [1:0][31:0] am_generation,am_epoch,wm_generation,wm_tensor;
 logic descriptor_ok;logic aborting;logic [22:0] error_key;
 logic cycle_numeric,cycle_protocol;logic [22:0] cycle_numeric_key;integer cycle_r,cycle_c,cycle_g;
 logic [12:0] a_next,issue_count,mul_next,ps_next,add_next,write_next,commit_count;
 logic [8:0] output_next,output_count;logic output_started;logic [6:0] bias_debt;
 logic [63:0][3:0] pool_state;logic [63:0][12:0] pool_seq;
 logic [63:0][255:0][31:0] op0,op1;
 logic [63:0][31:0] issue_time,ps_time;
 logic [1:0] holding_valid;logic [1:0][8:0] holding_record;logic [1:0][4351:0] holding_data;
 logic current_h,request_h,have_current,have_requested,free_h,have_free;
 logic [1:0] w_state;logic w_target;logic [9:0] fetch_record;logic [63:0] pending_w_tag;
 logic fp_lease_active,fp_draining,fp_lease_ready,fp_release_ready,fp_fault,storage_bind_ready,storage_idle;
 logic bind_fire,release_a_done,release_w_done,release_fp_done;
 logic dot_ready,dot_valid;logic [95:0] dot_tag;logic [255:0][20:0] dots;
 logic format_valid;logic [95:0] format_tag;logic [255:0][31:0] converted,products;logic [255:0] format_errors;
 logic mul_req_valid,mul_req_ready,mul_rsp_valid,mul_rsp_ready;logic [95:0] mul_req_tag,mul_rsp_tag;logic [255:0][31:0] mul_a,mul_b,mul_rsp_data;
 logic [6:0] mul_pending;logic [6:0][6:0] add_pending;
 logic [6:0] add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;
 logic [6:0][2:0] add_req_phase;logic [6:0][31:0] add_req_epoch;logic [6:0][95:0] add_req_tag,add_rsp_tag;
 logic [255:0][31:0] add_a,add_b,add_rsp_data;
 logic ps_wr_valid,ps_wr_ready,ps_wr_rsp_valid,ps_rd_valid,ps_rd_ready,ps_rd_rsp_valid,ps_rd_rsp_ready;
 logic [1023:0] ps_wr_mask,ps_rd_mask,ps_rd_rsp_mask;
 logic [1023:0][3:0] ps_wr_addr,ps_rd_addr;
 logic [1023:0][31:0] ps_wr_data,ps_rd_rsp_data;
 logic [95:0] ps_wr_tag,ps_wr_rsp_tag,ps_rd_tag,ps_rd_rsp_tag;
 logic output_read_fire,normal_write_ack;
 integer i,lane,bank_index,local_col,row_index;
 function automatic [95:0] tag(input logic kind,input logic [12:0] seq);
  return {epoch,generation,kind,18'b0,seq};
 endfunction
 function automatic [15:0] global_column(input integer local_n);
  if(n==5248)return 32*s+(local_n%32)+((local_n>=32)?2624:0);
  return 64*s+local_n;
 endfunction
 task automatic numeric_candidate(input integer r,c,g);
  logic [22:0] candidate;
  begin
   candidate=(r*64+c)*256+g;
   if(!cycle_numeric||candidate<cycle_numeric_key)begin cycle_numeric=1;cycle_numeric_key=candidate;cycle_r=r;cycle_c=c;cycle_g=g;end
  end
 endtask
 always_comb begin
  descriptor_ok=((cmd_k==1024&&(cmd_n==1024||cmd_n==3072||cmd_n==5248||cmd_n==4096))||(cmd_n==1024&&(cmd_k==2624||cmd_k==4096)))&&cmd_s<((cmd_n==5248)?82:(cmd_n>>6));
  if(cmd_k==4096&&!cmd_bias)descriptor_ok=0;
  descriptor_ok=descriptor_ok&&am_valid[cmd_a_slot]&&am_k[cmd_a_slot]==cmd_k&&am_request[cmd_a_slot]==cmd_request&&am_generation[cmd_a_slot]==cmd_generation&&am_epoch[cmd_a_slot]==cmd_epoch;
  descriptor_ok=descriptor_ok&&wm_valid[cmd_w_slot]&&wm_k[cmd_w_slot]==cmd_k&&wm_n[cmd_w_slot]==cmd_n&&wm_s[cmd_w_slot]==cmd_s&&wm_request[cmd_w_slot]==cmd_request&&wm_generation[cmd_w_slot]==cmd_generation&&wm_model[cmd_w_slot]==cmd_model&&wm_tensor[cmd_w_slot]==cmd_tensor;
  cmd_ready=state==IDLE&&!done_valid;
  have_current=0;current_h=0;have_requested=0;request_h=0;have_free=0;free_h=0;
  for(integer h=0;h<2;h++)begin
   if(holding_valid[h]&&holding_record[h]==a_rsp_tag[11:3])begin have_current=1;current_h=h;end
   if(holding_valid[h]&&holding_record[h]==a_next[11:3])begin have_requested=1;request_h=h;end
   if(!holding_valid[h])begin have_free=1;free_h=h;end
  end
  bind_fire=state==BIND&&a_lease_ready&&w_lease_ready&&fp_lease_ready&&storage_bind_ready;
  a_lease_valid=bind_fire;a_lease_slot=a_slot;a_lease_request=request_id;a_lease_generation=generation;a_lease_epoch=epoch;
  w_lease_valid=bind_fire;w_lease_slot=w_slot;w_lease_request=request_id;w_lease_generation=generation;w_lease_model=model;w_lease_tensor=tensor;
  a_rd_valid=state==RUN&&!aborting&&run_enable&&a_next<k&&arithmetic_debt<64&&have_requested;
  a_rd_slot=a_slot;a_rd_m=a_next[2:0];a_rd_group=a_next[11:5];a_rd_tag=tag(0,a_next);a_rd_request=request_id;a_rd_generation=generation;a_rd_epoch=epoch;
  a_rsp_ready=state==RUN&&have_current&&(!a_ret_valid||a_ret_ready)&&dot_ready;
  a_ret_slot=a_slot;a_ret_request=request_id;a_ret_generation=generation;a_ret_epoch=epoch;
  w_rd_valid=state==RUN&&!aborting&&w_state==0&&have_free&&fetch_record<4*groups;
  w_rd_slot=w_slot;w_rd_addr=fetch_record[8:0];w_rd_tag={epoch,22'b0,fetch_record};w_rd_request=request_id;w_rd_generation=generation;w_rd_model=model;w_rd_tensor=tensor;
  w_rsp_ready=w_state==1;w_ret_valid=w_state==2;w_ret_slot=w_slot;w_ret_tag=pending_w_tag;w_ret_request=request_id;w_ret_generation=generation;
  a_release_valid=state==RELEASE&&!release_a_done;a_release_slot=a_slot;a_release_request=request_id;a_release_generation=generation;a_release_epoch=epoch;
  w_release_valid=state==RELEASE&&!release_w_done;w_release_slot=w_slot;w_release_request=request_id;w_release_generation=generation;
  trace_issue=a_rsp_valid&&a_rsp_ready;trace_issue_seq=a_rsp_tag[12:0];trace_a_q=a_rsp_data[4095:0];trace_a_scale=a_rsp_data[4351:4096];trace_w_q=holding_data[current_h][4095:0];trace_w_scale=holding_data[current_h][4351:4096];
  trace_dot=dot_valid;trace_dot_seq=dot_tag[12:0];trace_dot_data=dots;
  trace_format=format_valid;trace_format_seq=format_tag[12:0];trace_scale_product=products;trace_converted=converted;
  mul_req_valid=state==RUN&&mul_next<issue_count&&pool_state[mul_next[5:0]]==MULREADY;
  mul_req_tag=tag(0,mul_next);mul_a=op0[mul_next[5:0]];mul_b=op1[mul_next[5:0]];mul_rsp_ready=1;
  trace_term=mul_rsp_valid&&mul_rsp_ready;trace_term_seq=mul_rsp_tag[12:0];trace_term_data=mul_rsp_data;
  ps_rd_valid=0;ps_rd_mask=0;ps_rd_addr=0;ps_rd_tag=0;
  if(state==RUN&&ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next>=32)begin
   ps_rd_valid=1;ps_rd_tag=tag(0,ps_next);
   for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin
    bank_index=512*ctx+32*a+16*ps_next[3]+c;ps_rd_mask[bank_index]=1;ps_rd_addr[bank_index]=2*ps_next[2:0]+ps_next[4];
   end
  end else if(state==OUTPUT&&output_next<256&&(!bias||bias_debt<64))begin
   ps_rd_valid=1;ps_rd_tag=tag(1,{4'b0,output_next});
   for(integer c=0;c<32;c++)begin bank_index=512*ctx+32*output_next[4:1]+c;ps_rd_mask[bank_index]=1;ps_rd_addr[bank_index]=2*output_next[7:5]+output_next[0];end
  end
  add_req_valid=0;add_req_is_root=0;add_req_phase='{default:3'd1};add_req_epoch='{default:epoch};add_req_tag=0;add_a=0;add_b=0;
  if(state==RUN&&add_next<issue_count&&pool_state[add_next[5:0]]==ADDREADY)begin
   add_req_valid[0]=1;add_req_tag[0]=tag(0,add_next);add_a=op0[add_next[5:0]];add_b=op1[add_next[5:0]];
  end else if(state==OUTPUT&&bias&&ps_rd_rsp_valid)begin
   add_req_valid[0]=1;add_req_is_root[0]=1;add_req_tag[0]=ps_rd_rsp_tag;
   for(integer c=0;c<32;c++)begin bank_index=512*ctx+32*ps_rd_rsp_tag[4:1]+c;add_a[c]=ps_rd_rsp_data[bank_index];add_b[c]=bias_data[32*ps_rd_rsp_tag[0]+c];end
  end
  ps_rd_rsp_ready=(state==OUTPUT)?(bias?add_req_ready[0]:out_ready):1'b1;
  add_rsp_ready=7'b0000001;if(state==OUTPUT&&bias)add_rsp_ready[0]=out_ready;
  ps_wr_valid=state==RUN&&write_next<issue_count&&pool_state[write_next[5:0]]==SUMREADY;
  ps_wr_tag=tag(0,write_next);ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;
  for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)begin
   bank_index=512*ctx+32*a+16*write_next[3]+c;ps_wr_mask[bank_index]=1;ps_wr_addr[bank_index]=2*write_next[2:0]+write_next[4];ps_wr_data[bank_index]=op0[write_next[5:0]][16*a+c];
  end
  out_valid=state==OUTPUT&&(bias?add_rsp_valid[0]:ps_rd_rsp_valid);
  out_row=bias?add_rsp_tag[0][7:1]:ps_rd_rsp_tag[7:1];out_half=bias?add_rsp_tag[0][0]:ps_rd_rsp_tag[0];out_data=0;
  for(integer c=0;c<32;c++)begin bank_index=512*ctx+32*out_row[3:0]+c;out_data[c]=bias?add_rsp_data[c]:ps_rd_rsp_data[bank_index];end
  output_read_fire=state==OUTPUT&&ps_rd_valid&&ps_rd_ready;
  normal_write_ack=state==RUN&&ps_wr_rsp_valid;
  trace_commit=normal_write_ack;trace_commit_seq=ps_wr_rsp_tag[12:0];trace_commit_data=op0[ps_wr_rsp_tag[5:0]];
 end
 laya_m007_matrix_dot_v1 dot_array(.clk,.rst_n,.req_valid(trace_issue),.req_ready(dot_ready),.req_tag(a_rsp_tag),.a(trace_a_q),.w(trace_w_q),.rsp_valid(dot_valid),.rsp_tag(dot_tag),.dot(dots));
 laya_m007_matrix_format_v1 format(.clk,.rst_n,.issue_valid(trace_issue),.issue_tag(a_rsp_tag),.a_scale(trace_a_scale),.w_scale(trace_w_scale),.dot_valid,.dot_tag,.dot(dots),.rsp_valid(format_valid),.rsp_tag(format_tag),.converted,.scale_product(products),.domain_error(format_errors));
 laya_shared_fp256_v2 fp(
  .clk,.rst_n,.lease_valid(bind_fire),.lease_ready(fp_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_head(4'b0),.lease_phase(3'd1),
  .release_valid(state==RELEASE&&!release_fp_done),.release_ready(fp_release_ready),.release_phase(3'd1),.release_epoch(epoch),.phase_debt_clear(arithmetic_debt==0&&storage_idle&&!a_ret_valid&&w_state==0),.lease_active(fp_lease_active),.draining(fp_draining),
  .rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .mul_req_valid,.mul_req_ready,.mul_req_phase(3'd1),.mul_req_epoch(epoch),.mul_req_tag,.mul_a,.mul_b,.mul_rsp_valid,.mul_rsp_ready,.mul_rsp_tag,.mul_rsp_data,
  .add_req_valid,.add_req_is_root,.add_req_ready,.add_req_phase,.add_req_epoch,.add_req_tag,.add_a,.add_b,.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data,.mul_pending,.add_pending,.protocol_fault(fp_fault));
 laya_attention_storage_v1 storage(
  .clk,.rst_n,.bind_valid(bind_fire),.bind_ready(storage_bind_ready),.bind_request_id(request_id),.bind_generation(generation),.bind_epoch(epoch),.bind_head(4'b0),.bind_phase(3'd1),.op_request_id(request_id),.op_generation(generation),.op_epoch(epoch),.op_phase(3'd1),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
  .ps_wr_valid,.ps_wr_ready,.ps_wr_mask,.ps_wr_addr,.ps_wr_data,.ps_wr_tag,.ps_wr_rsp_valid,.ps_wr_rsp_ready(1'b1),.ps_wr_rsp_tag,.ps_rd_valid,.ps_rd_ready,.ps_rd_mask,.ps_rd_addr,.ps_rd_tag,.ps_rd_rsp_valid,.ps_rd_rsp_ready,.ps_rd_rsp_data,.ps_rd_rsp_mask,.ps_rd_rsp_tag,
  .g_wr_valid(1'b0),.g_wr_ready(),.g_wr_mask(256'b0),.g_wr_addr('0),.g_wr_data('0),.g_wr_tag(96'b0),.g_wr_rsp_valid(),.g_wr_rsp_ready(1'b1),.g_wr_rsp_tag(),.g_rd_valid(1'b0),.g_rd_ready(),.g_rd_mask(256'b0),.g_rd_addr('0),.g_rd_tag(96'b0),.g_rd_rsp_valid(),.g_rd_rsp_ready(1'b1),.g_rd_rsp_data(),.g_rd_rsp_mask(),.g_rd_rsp_tag(),
  .context_wr_valid(1'b0),.context_wr_ready(),.context_wr_mask(64'b0),.context_wr_addr('0),.context_wr_data('0),.context_wr_tag(96'b0),.context_wr_rsp_valid(),.context_wr_rsp_ready(1'b1),.context_wr_rsp_tag(),.context_rd_valid(1'b0),.context_rd_ready(),.context_rd_mask(64'b0),.context_rd_addr('0),.context_rd_tag(96'b0),.context_rd_rsp_valid(),.context_rd_rsp_ready(1'b1),.context_rd_rsp_data(),.context_rd_rsp_mask(),.context_rd_rsp_tag(),.idle(storage_idle));
 always_ff @(posedge clk)begin
  if(!rst_n)begin
   state<=IDLE;done_valid<=0;status<=0;request_id<=0;model<=0;generation<=0;epoch<=0;tensor<=0;k<=0;n<=0;s<=0;a_slot<=0;w_slot<=0;ctx<=0;bias<=0;groups<=0;tick<=0;
   am_valid<=0;wm_valid<=0;am_k<=0;wm_k<=0;wm_n<=0;wm_s<=0;am_request<=0;wm_request<=0;wm_model<=0;am_generation<=0;am_epoch<=0;wm_generation<=0;wm_tensor<=0;
   a_next<=0;issue_count<=0;mul_next<=0;ps_next<=0;add_next<=0;write_next<=0;commit_count<=0;output_next<=0;output_count<=0;output_started<=0;output_bubbles<=0;bias_debt<=0;arithmetic_debt<=0;peak_return_reservations<=0;
   holding_valid<=0;w_state<=0;fetch_record<=0;w_target<=0;pending_w_tag<=0;a_ret_valid<=0;a_ret_tag<=0;aborting<=0;error_key<='1;error_row<=0;error_col<=0;error_group<=0;
   release_a_done<=0;release_w_done<=0;release_fp_done<=0;done_request<=0;done_generation<=0;elapsed_cycles<=0;first_issue_cycle<=0;last_issue_cycle<=0;last_output_cycle<=0;max_issue_commit<=0;max_ps_feedback<=0;
   for(i=0;i<64;i++)begin pool_state[i]<=EMPTY;pool_seq[i]<=0;end
  end else begin
   cycle_numeric=0;cycle_protocol=0;cycle_numeric_key='1;cycle_r=0;cycle_c=0;cycle_g=0;
   if(done_valid&&done_ready)done_valid<=0;
   if(a_complete)begin am_valid[a_complete_slot]<=a_complete_status==0;am_k[a_complete_slot]<=a_complete_k;am_request[a_complete_slot]<=a_complete_request;am_generation[a_complete_slot]<=a_complete_generation;am_epoch[a_complete_slot]<=a_complete_epoch;end
   if(w_complete)begin wm_valid[w_complete_slot]<=w_complete_status==0;wm_k[w_complete_slot]<=w_complete_k;wm_n[w_complete_slot]<=w_complete_n;wm_s[w_complete_slot]<=w_complete_s;wm_request[w_complete_slot]<=w_complete_request;wm_generation[w_complete_slot]<=w_complete_generation;wm_model[w_complete_slot]<=w_complete_model;wm_tensor[w_complete_slot]<=w_complete_tensor;end
   if(state!=IDLE)tick<=tick+1;
   if(cmd_valid&&cmd_ready)begin
    request_id<=cmd_request;model<=cmd_model;generation<=cmd_generation;epoch<=cmd_epoch;tensor<=cmd_tensor;k<=cmd_k;n<=cmd_n;s<=cmd_s;a_slot<=cmd_a_slot;w_slot<=cmd_w_slot;ctx<=cmd_ctx;bias<=cmd_bias;bias_data<=cmd_bias_data;groups<=cmd_k>>5;
    done_request<=cmd_request;done_generation<=cmd_generation;status<=0;aborting<=0;error_key<='1;error_row<=0;error_col<=0;error_group<=0;tick<=0;elapsed_cycles<=0;first_issue_cycle<=0;last_issue_cycle<=0;last_output_cycle<=0;max_issue_commit<=0;max_ps_feedback<=0;output_bubbles<=0;
    if(!descriptor_ok)begin done_valid<=1;status<=1;end
    else begin
     state<=BIND;a_next<=0;issue_count<=0;mul_next<=0;ps_next<=0;add_next<=0;write_next<=0;commit_count<=0;output_next<=0;output_count<=0;output_started<=0;bias_debt<=0;arithmetic_debt<=0;peak_return_reservations<=0;holding_valid<=0;w_state<=0;fetch_record<=0;a_ret_valid<=0;release_a_done<=0;release_w_done<=0;release_fp_done<=0;
     for(i=0;i<64;i++)pool_state[i]<=EMPTY;
    end
   end
   if(state==BIND)begin
    if(!a_lease_ready||!w_lease_ready)begin state<=IDLE;done_valid<=1;status<=1;end
    else if(bind_fire)state<=RUN;
   end
   if(a_ret_valid&&a_ret_ready)a_ret_valid<=0;
   // Retire the actual accepted request identity only after response copy; untrusted echoes never replace this ledger.
   if(w_rd_valid&&w_rd_ready)begin w_state<=1;w_target<=free_h;fetch_record<=fetch_record+1;pending_w_tag<=w_rd_tag;end
   if(w_rsp_valid&&w_rsp_ready)begin
    holding_data[w_target]<=w_rsp_data;holding_record[w_target]<=w_rsp_tag[8:0];holding_valid[w_target]<=1;w_state<=2;
    if(w_rsp_slot!=w_slot||w_rsp_tag!=pending_w_tag)begin cycle_protocol=1;end
    for(i=0;i<16;i++)if(w_rsp_data[4096+16*i+10+:5]==31||(w_rsp_data[4096+16*i+15]&&w_rsp_data[4096+16*i+:15]!=0))numeric_candidate(0,16*w_rsp_tag[1:0]+i,w_rsp_tag[8:2]);
   end
   if(w_ret_valid&&w_ret_ready)w_state<=0;
   if(state==RUN)begin
    if(a_rd_valid&&a_rd_ready)begin
     a_next<=a_next+1;pool_state[a_next[5:0]]<=WAITDOT;pool_seq[a_next[5:0]]<=a_next;
    end
    if(trace_issue)begin
     if(trace_issue_seq!=issue_count||a_rsp_slot!=a_slot||a_rsp_tag[95:64]!=epoch||a_rsp_tag[63:32]!=generation)begin cycle_protocol=1;end
     issue_time[trace_issue_seq[5:0]]<=tick;issue_count<=issue_count+1;a_ret_valid<=1;a_ret_tag<=a_rsp_tag;
     if(issue_count==0)first_issue_cycle<=tick;last_issue_cycle<=tick;
     if(trace_issue_seq[2:0]==7)holding_valid[current_h]<=0;
    end
    case({a_rd_valid&&a_rd_ready,normal_write_ack})2'b10:arithmetic_debt<=arithmetic_debt+1;2'b01:arithmetic_debt<=arithmetic_debt-1;default:;endcase
    if(arithmetic_debt+mul_pending+add_pending[0]>peak_return_reservations)peak_return_reservations<=arithmetic_debt+mul_pending+add_pending[0];
    if(format_valid)begin
     if(pool_state[format_tag[5:0]]!=WAITDOT||pool_seq[format_tag[5:0]]!=format_tag[12:0])begin cycle_protocol=1;end
     op0[format_tag[5:0]]<=converted;op1[format_tag[5:0]]<=products;pool_state[format_tag[5:0]]<=MULREADY;
     for(i=0;i<256;i++)if(format_errors[i])numeric_candidate(16*format_tag[2:0]+i/16,16*format_tag[4:3]+i%16,format_tag[11:5]);
    end
    if(mul_req_valid&&mul_req_ready)begin pool_state[mul_next[5:0]]<=MULWAIT;mul_next<=mul_next+1;end
    if(mul_rsp_valid&&mul_rsp_ready)begin
     if(pool_state[mul_rsp_tag[5:0]]!=MULWAIT)begin cycle_protocol=1;end
     op0[mul_rsp_tag[5:0]]<=mul_rsp_data;pool_state[mul_rsp_tag[5:0]]<=TERMREADY;
     for(i=0;i<256;i++)if(mul_rsp_data[i][30:23]==255)numeric_candidate(16*mul_rsp_tag[2:0]+i/16,16*mul_rsp_tag[4:3]+i%16,mul_rsp_tag[11:5]);
    end
    if(ps_next<issue_count&&pool_state[ps_next[5:0]]==TERMREADY&&ps_next<32)begin op1[ps_next[5:0]]<='0;pool_state[ps_next[5:0]]<=ADDREADY;ps_time[ps_next[5:0]]<=tick;ps_next<=ps_next+1;end
    if(ps_rd_valid&&ps_rd_ready)begin pool_state[ps_next[5:0]]<=PSWAIT;ps_time[ps_next[5:0]]<=tick;ps_next<=ps_next+1;end
    if(ps_rd_rsp_valid&&ps_rd_rsp_ready)begin
     for(integer a=0;a<16;a++)for(integer c=0;c<16;c++)op1[ps_rd_rsp_tag[5:0]][16*a+c]<=ps_rd_rsp_data[512*ctx+32*a+16*ps_rd_rsp_tag[3]+c];
     pool_state[ps_rd_rsp_tag[5:0]]<=ADDREADY;
    end
    if(add_req_valid[0]&&add_req_ready[0])begin pool_state[add_next[5:0]]<=ADDWAIT;add_next<=add_next+1;end
    if(add_rsp_valid[0]&&add_rsp_ready[0])begin
     if(pool_state[add_rsp_tag[0][5:0]]!=ADDWAIT)begin cycle_protocol=1;end
     op0[add_rsp_tag[0][5:0]]<=add_rsp_data;pool_state[add_rsp_tag[0][5:0]]<=SUMREADY;
     for(i=0;i<256;i++)if(add_rsp_data[i][30:23]==255)numeric_candidate(16*add_rsp_tag[0][2:0]+i/16,16*add_rsp_tag[0][4:3]+i%16,add_rsp_tag[0][11:5]);
    end
    if(ps_wr_valid&&ps_wr_ready)begin pool_state[write_next[5:0]]<=WRITEWAIT;write_next<=write_next+1;end
    if(normal_write_ack)begin
     if(pool_state[ps_wr_rsp_tag[5:0]]!=WRITEWAIT||ps_wr_rsp_tag[12:0]!=commit_count)begin cycle_protocol=1;end
     pool_state[ps_wr_rsp_tag[5:0]]<=EMPTY;commit_count<=commit_count+1;
     if(tick-issue_time[ps_wr_rsp_tag[5:0]]>max_issue_commit)max_issue_commit<=tick-issue_time[ps_wr_rsp_tag[5:0]];
     if(tick-ps_time[ps_wr_rsp_tag[5:0]]>max_ps_feedback)max_ps_feedback<=tick-ps_time[ps_wr_rsp_tag[5:0]];
    end
    if(fp_fault)begin cycle_protocol=1;end
    if(arithmetic_debt==0&&!a_ret_valid&&w_state==0&&((!aborting&&commit_count==k)||(aborting&&!a_rsp_valid)))begin
     holding_valid<=0;
     if(aborting)state<=RELEASE;else state<=OUTPUT;
    end
   end
   if(state==OUTPUT)begin
    if(output_read_fire)output_next<=output_next+1;
    case({output_read_fire,out_valid&&out_ready})2'b10:bias_debt<=bias_debt+1;2'b01:bias_debt<=bias_debt-1;default:;endcase
    if(out_valid&&out_ready)begin
     output_count<=output_count+1;output_started<=1;last_output_cycle<=tick;
     for(i=0;i<32;i++)if(out_data[i][30:23]==255)numeric_candidate(out_row,32*out_half+i,groups);
    end
    if(output_started&&output_count<256&&!out_valid)output_bubbles<=output_bubbles+1;
    if(output_count==256&&bias_debt==0&&storage_idle&&mul_pending==0&&add_pending=='0)state<=RELEASE;
   end
   if(state==RELEASE)begin
    if(a_release_valid&&a_release_ready)release_a_done<=1;
    if(w_release_valid&&w_release_ready)release_w_done<=1;
    if(!release_fp_done&&fp_release_ready)release_fp_done<=1;
    if(release_a_done&&release_w_done&&release_fp_done&&storage_idle)begin state<=IDLE;done_valid<=1;elapsed_cycles<=tick;end
   end
   if(cycle_numeric)begin
    aborting<=1;
    if(status!=3)status<=2;
    if(cycle_numeric_key<error_key)begin error_key<=cycle_numeric_key;error_row<=cycle_r;error_col<=global_column(cycle_c);error_group<=cycle_g;end
   end
   if(cycle_protocol)begin status<=3;aborting<=1;end
  end
 end
endmodule
