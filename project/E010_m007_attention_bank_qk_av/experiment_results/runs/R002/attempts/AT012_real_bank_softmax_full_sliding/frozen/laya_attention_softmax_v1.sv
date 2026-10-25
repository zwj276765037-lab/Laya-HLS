`timescale 1ns/1ps
// Standalone real-bank softmax bring-up. Only score/max are prep inputs.
// The engine owns no resources; this shell owns one PS/G/context, LNexp,
// FP256, EXP8 and DIV8. Full head later multiplexes these same interfaces.
module laya_attention_softmax_v1(
 input logic clk,rst_n,
 input logic prepare_valid,output logic prepare_ready,input logic[63:0]prepare_request_id,
 input logic[31:0]prepare_generation,prepare_epoch,input logic[3:0]prepare_head,input logic[127:0][31:0]prepare_maximum,
 input logic score_wr_valid,output logic score_wr_ready,input logic[31:0]score_wr_generation,
 input logic[6:0]score_wr_row,input logic[3:0]score_wr_chunk,input logic[7:0][31:0]score_wr_data,
 input logic start_valid,output logic start_ready,input logic[63:0]start_request_id,input logic[31:0]start_generation,
 input logic abort_valid,output logic abort_ready,
 input logic score_grant,fp_grant,sfu_grant,exp_grant,div_grant,prob_grant,
 output logic done_valid,input logic done_ready,output logic[7:0]done_status,
 output logic[31:0]done_cycles,first_row_cycle,max_sum_tail,max_row_launch_gap,
 output logic[7:0]rows_launched,rows_retired,output logic[11:0]probability_commits,
 output logic error_valid,output logic[63:0]error_rank,output logic[4:0]error_phase,output logic[6:0]error_row,error_node,output logic[31:0]error_element,
 input logic prob_rd_valid,output logic prob_rd_ready,input logic[31:0]prob_rd_generation,prob_rd_tag,input logic[6:0]prob_rd_row,input logic[3:0]prob_rd_chunk,
 output logic prob_rsp_valid,input logic prob_rsp_ready,output logic[31:0]prob_rsp_tag,output logic[7:0][31:0]prob_rsp_data
);
 localparam IDLE=0,PREP=1,CLAIM=2,RUN=3,RELEASE=4;
 logic[2:0]state;logic[63:0]request_id;logic[31:0]generation,epoch;logic[3:0]head;logic[127:0][31:0]maximum;logic[2047:0]loaded;
logic  eng_start_valid;
logic  eng_start_ready;
logic [63:0] eng_start_request_id;
logic [31:0] eng_start_generation;
logic [31:0] eng_start_epoch;
logic [3:0] eng_start_head;
logic [63:0] context_valid;
logic [63:0] context_row_hi;
logic  resource_debt_clear;
logic  resource_fault;
logic  score_rd_valid;
logic  score_rd_ready;
logic [10:0] score_rd_tag;
logic  score_rsp_valid;
logic  score_rsp_ready;
logic [10:0] score_rsp_tag;
logic [7:0][31:0] score_rsp_data;
logic  fp_req_valid;
logic  fp_req_ready;
logic [95:0] fp_req_tag;
logic [255:0][31:0] fp_a;
logic [255:0][31:0] fp_b;
logic  fp_rsp_valid;
logic  fp_rsp_ready;
logic [95:0] fp_rsp_tag;
logic [255:0][31:0] fp_rsp_data;
logic  sfu_req_valid;
logic  sfu_req_ready;
logic [10:0] sfu_req_tag;
logic [7:0][31:0] sfu_req_x;
logic  sfu_rsp_valid;
logic  sfu_rsp_ready;
logic [10:0] sfu_rsp_tag;
logic [7:0][31:0] sfu_rsp_data;
logic  exp_wr_valid;
logic  exp_wr_ready;
logic [10:0] exp_wr_tag;
logic [7:0][31:0] exp_wr_data;
logic  exp_wr_ack_valid;
logic  exp_wr_ack_ready;
logic [10:0] exp_wr_ack_tag;
logic  exp_rd_valid;
logic  exp_rd_ready;
logic [10:0] exp_rd_tag;
logic  exp_rsp_valid;
logic  exp_rsp_ready;
logic [10:0] exp_rsp_tag;
logic [7:0][31:0] exp_rsp_data;
logic  div_req_valid;
logic  div_req_ready;
logic [95:0] div_req_tag;
logic [7:0][31:0] div_a;
logic [7:0][31:0] div_b;
logic  div_rsp_valid;
logic  div_rsp_ready;
logic [95:0] div_rsp_tag;
logic [7:0][31:0] div_rsp_data;
logic [7:0] div_rsp_error;
logic  prob_wr_valid;
logic  prob_wr_ready;
logic [10:0] prob_wr_tag;
logic [7:0][31:0] prob_wr_data;
logic  prob_wr_ack_valid;
logic  prob_wr_ack_ready;
logic [10:0] prob_wr_ack_tag;
 logic storage_bind_ready,storage_idle,ln_bind_ready,ln_idle,fp_lease_ready,sfu_lease_ready,div_lease_ready,fp_owned,sfu_owned,div_owned;
 logic fp_release_ready,sfu_release_ready,div_release_ready,fp_fault,sfu_fault,div_fault,sfu_reject,div_reject;
 logic[6:0]fp_mul_pending;logic[6:0][6:0]fp_add_pending;logic[8:0]sfu_pending,sfu_inflight,div_scalars;logic[5:0]div_pending,div_inflight;
 logic[6:0]add_req_valid,add_ready,add_rsp_valid,add_rsp_ready;logic[6:0][2:0]add_phase;logic[6:0][31:0]add_epoch;logic[6:0][95:0]add_tag,add_rsp_tag;
 logic[255:0][31:0]fp_data;
 wire all_lease_ready=fp_lease_ready&&sfu_lease_ready&&div_lease_ready;
 wire bind_fire=prepare_valid&&prepare_ready;
 wire lease_fire=state==CLAIM&&all_lease_ready;
 wire local_debt_clear=storage_idle&&ln_idle;
 assign resource_debt_clear=local_debt_clear&&fp_mul_pending==0&&fp_add_pending==0&&sfu_pending==0&&div_pending==0;
 assign resource_fault=fp_fault||sfu_fault||div_fault||sfu_reject||div_reject;
 assign prepare_ready=state==IDLE&&storage_bind_ready&&ln_bind_ready&&all_lease_ready;
 assign start_ready=state==PREP&&start_request_id==request_id&&start_generation==generation&&(&loaded)&&storage_idle;
 assign eng_start_valid=state==RUN&&!engine_started;assign eng_start_request_id=request_id;assign eng_start_generation=generation;assign eng_start_epoch=epoch;assign eng_start_head=head;
 logic engine_started;
 always_ff @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;request_id<=0;generation<=0;epoch<=0;head<=0;loaded<=0;engine_started<=0;end
  else begin
   if(bind_fire)begin state<=PREP;request_id<=prepare_request_id;generation<=prepare_generation;epoch<=prepare_epoch;head<=prepare_head;maximum<=prepare_maximum;loaded<=0;engine_started<=0;end
   if(ps_wr_rsp_valid&&ps_wr_rsp_ready&&state==PREP)loaded[ps_wr_rsp_tag[10:0]]<=1;
   if(start_valid&&start_ready)state<=CLAIM;
   if(lease_fire)state<=RUN;
   if(eng_start_valid&&eng_start_ready)engine_started<=1;
   if(done_valid&&done_ready)state<=RELEASE;
   if(state==RELEASE&&!fp_owned&&!sfu_owned&&!div_owned&&local_debt_clear)state<=IDLE;
  end
 end
 laya_attention_softmax_engine_v1 engine(
  .clk(clk),
  .rst_n(rst_n),
  .start_valid(eng_start_valid),
  .start_ready(eng_start_ready),
  .start_request_id(eng_start_request_id),
  .start_generation(eng_start_generation),
  .start_epoch(eng_start_epoch),
  .start_head(eng_start_head),
  .maximum(maximum),
  .abort_valid(abort_valid),
  .abort_ready(abort_ready),
  .done_valid(done_valid),
  .done_ready(done_ready),
  .done_status(done_status),
  .done_cycles(done_cycles),
  .first_row_cycle(first_row_cycle),
  .max_sum_tail(max_sum_tail),
  .max_row_launch_gap(max_row_launch_gap),
  .rows_launched(rows_launched),
  .rows_retired(rows_retired),
  .probability_commits(probability_commits),
  .error_valid(error_valid),
  .error_rank(error_rank),
  .error_phase(error_phase),
  .error_row(error_row),
  .error_node(error_node),
  .error_element(error_element),
  .context_valid(context_valid),
  .context_row_hi(context_row_hi),
  .resource_debt_clear(resource_debt_clear),
  .resource_fault(resource_fault),
  .score_rd_valid(score_rd_valid),
  .score_rd_ready(score_rd_ready),
  .score_rd_tag(score_rd_tag),
  .score_rsp_valid(score_rsp_valid),
  .score_rsp_ready(score_rsp_ready),
  .score_rsp_tag(score_rsp_tag),
  .score_rsp_data(score_rsp_data),
  .fp_req_valid(fp_req_valid),
  .fp_req_ready(fp_req_ready),
  .fp_req_tag(fp_req_tag),
  .fp_a(fp_a),
  .fp_b(fp_b),
  .fp_rsp_valid(fp_rsp_valid),
  .fp_rsp_ready(fp_rsp_ready),
  .fp_rsp_tag(fp_rsp_tag),
  .fp_rsp_data(fp_rsp_data),
  .sfu_req_valid(sfu_req_valid),
  .sfu_req_ready(sfu_req_ready),
  .sfu_req_tag(sfu_req_tag),
  .sfu_req_x(sfu_req_x),
  .sfu_rsp_valid(sfu_rsp_valid),
  .sfu_rsp_ready(sfu_rsp_ready),
  .sfu_rsp_tag(sfu_rsp_tag),
  .sfu_rsp_data(sfu_rsp_data),
  .exp_wr_valid(exp_wr_valid),
  .exp_wr_ready(exp_wr_ready),
  .exp_wr_tag(exp_wr_tag),
  .exp_wr_data(exp_wr_data),
  .exp_wr_ack_valid(exp_wr_ack_valid),
  .exp_wr_ack_ready(exp_wr_ack_ready),
  .exp_wr_ack_tag(exp_wr_ack_tag),
  .exp_rd_valid(exp_rd_valid),
  .exp_rd_ready(exp_rd_ready),
  .exp_rd_tag(exp_rd_tag),
  .exp_rsp_valid(exp_rsp_valid),
  .exp_rsp_ready(exp_rsp_ready),
  .exp_rsp_tag(exp_rsp_tag),
  .exp_rsp_data(exp_rsp_data),
  .div_req_valid(div_req_valid),
  .div_req_ready(div_req_ready),
  .div_req_tag(div_req_tag),
  .div_a(div_a),
  .div_b(div_b),
  .div_rsp_valid(div_rsp_valid),
  .div_rsp_ready(div_rsp_ready),
  .div_rsp_tag(div_rsp_tag),
  .div_rsp_data(div_rsp_data),
  .div_rsp_error(div_rsp_error),
  .prob_wr_valid(prob_wr_valid),
  .prob_wr_ready(prob_wr_ready),
  .prob_wr_tag(prob_wr_tag),
  .prob_wr_data(prob_wr_data),
  .prob_wr_ack_valid(prob_wr_ack_valid),
  .prob_wr_ack_ready(prob_wr_ack_ready),
  .prob_wr_ack_tag(prob_wr_ack_tag)
 );
 logic  ps_wr_valid;
 logic  ps_wr_ready;
 logic [1023:0] ps_wr_mask;
 logic [1023:0][3:0] ps_wr_addr;
 logic [1023:0][31:0] ps_wr_data;
 logic [95:0] ps_wr_tag;
 logic  ps_wr_rsp_valid;
 logic  ps_wr_rsp_ready;
 logic [95:0] ps_wr_rsp_tag;
 logic  ps_rd_valid;
 logic  ps_rd_ready;
 logic [1023:0] ps_rd_mask;
 logic [1023:0][3:0] ps_rd_addr;
 logic [95:0] ps_rd_tag;
 logic  ps_rd_rsp_valid;
 logic  ps_rd_rsp_ready;
 logic [1023:0][31:0] ps_rd_rsp_data;
 logic [1023:0] ps_rd_rsp_mask;
 logic [95:0] ps_rd_rsp_tag;
 logic  g_wr_valid;
 logic  g_wr_ready;
 logic [255:0] g_wr_mask;
 logic [255:0][5:0] g_wr_addr;
 logic [255:0][31:0] g_wr_data;
 logic [95:0] g_wr_tag;
 logic  g_wr_rsp_valid;
 logic  g_wr_rsp_ready;
 logic [95:0] g_wr_rsp_tag;
 logic  g_rd_valid;
 logic  g_rd_ready;
 logic [255:0] g_rd_mask;
 logic [255:0][5:0] g_rd_addr;
 logic [95:0] g_rd_tag;
 logic  g_rd_rsp_valid;
 logic  g_rd_rsp_ready;
 logic [255:0][31:0] g_rd_rsp_data;
 logic [255:0] g_rd_rsp_mask;
 logic [95:0] g_rd_rsp_tag;
 logic  context_wr_valid;
 logic  context_wr_ready;
 logic [63:0] context_wr_mask;
 logic [63:0][10:0] context_wr_addr;
 logic [63:0][31:0] context_wr_data;
 logic [95:0] context_wr_tag;
 logic  context_wr_rsp_valid;
 logic  context_wr_rsp_ready;
 logic [95:0] context_wr_rsp_tag;
 logic  context_rd_valid;
 logic  context_rd_ready;
 logic [63:0] context_rd_mask;
 logic [63:0][10:0] context_rd_addr;
 logic [95:0] context_rd_tag;
 logic  context_rd_rsp_valid;
 logic  context_rd_rsp_ready;
 logic [63:0][31:0] context_rd_rsp_data;
 logic [63:0] context_rd_rsp_mask;
 logic [95:0] context_rd_rsp_tag;
 laya_attention_storage_v1 storage(.clk(clk),.rst_n(rst_n),.bind_valid(bind_fire),.bind_ready(storage_bind_ready),.bind_request_id(prepare_request_id),.bind_generation(prepare_generation),.bind_epoch(prepare_epoch),.bind_head(prepare_head),.bind_phase(3'd3),.op_request_id(request_id),.op_generation(generation),.op_epoch(epoch),.op_phase(3'd3),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),.ps_wr_valid(ps_wr_valid),.ps_wr_ready(ps_wr_ready),.ps_wr_mask(ps_wr_mask),.ps_wr_addr(ps_wr_addr),.ps_wr_data(ps_wr_data),.ps_wr_tag(ps_wr_tag),.ps_wr_rsp_valid(ps_wr_rsp_valid),.ps_wr_rsp_ready(ps_wr_rsp_ready),.ps_wr_rsp_tag(ps_wr_rsp_tag),.ps_rd_valid(ps_rd_valid),.ps_rd_ready(ps_rd_ready),.ps_rd_mask(ps_rd_mask),.ps_rd_addr(ps_rd_addr),.ps_rd_tag(ps_rd_tag),.ps_rd_rsp_valid(ps_rd_rsp_valid),.ps_rd_rsp_ready(ps_rd_rsp_ready),.ps_rd_rsp_data(ps_rd_rsp_data),.ps_rd_rsp_mask(ps_rd_rsp_mask),.ps_rd_rsp_tag(ps_rd_rsp_tag),.g_wr_valid(g_wr_valid),.g_wr_ready(g_wr_ready),.g_wr_mask(g_wr_mask),.g_wr_addr(g_wr_addr),.g_wr_data(g_wr_data),.g_wr_tag(g_wr_tag),.g_wr_rsp_valid(g_wr_rsp_valid),.g_wr_rsp_ready(g_wr_rsp_ready),.g_wr_rsp_tag(g_wr_rsp_tag),.g_rd_valid(g_rd_valid),.g_rd_ready(g_rd_ready),.g_rd_mask(g_rd_mask),.g_rd_addr(g_rd_addr),.g_rd_tag(g_rd_tag),.g_rd_rsp_valid(g_rd_rsp_valid),.g_rd_rsp_ready(g_rd_rsp_ready),.g_rd_rsp_data(g_rd_rsp_data),.g_rd_rsp_mask(g_rd_rsp_mask),.g_rd_rsp_tag(g_rd_rsp_tag),.context_wr_valid(context_wr_valid),.context_wr_ready(context_wr_ready),.context_wr_mask(context_wr_mask),.context_wr_addr(context_wr_addr),.context_wr_data(context_wr_data),.context_wr_tag(context_wr_tag),.context_wr_rsp_valid(context_wr_rsp_valid),.context_wr_rsp_ready(context_wr_rsp_ready),.context_wr_rsp_tag(context_wr_rsp_tag),.context_rd_valid(context_rd_valid),.context_rd_ready(context_rd_ready),.context_rd_mask(context_rd_mask),.context_rd_addr(context_rd_addr),.context_rd_tag(context_rd_tag),.context_rd_rsp_valid(context_rd_rsp_valid),.context_rd_rsp_ready(context_rd_rsp_ready),.context_rd_rsp_data(context_rd_rsp_data),.context_rd_rsp_mask(context_rd_rsp_mask),.context_rd_rsp_tag(context_rd_rsp_tag),.idle(storage_idle));
 logic  ln_wr_valid;
 logic  ln_wr_ready;
 logic [255:0] ln_wr_mask;
 logic [255:0][4:0] ln_wr_addr;
 logic [255:0][31:0] ln_wr_data;
 logic [95:0] ln_wr_tag;
 logic  ln_wr_rsp_valid;
 logic  ln_wr_rsp_ready;
 logic [95:0] ln_wr_rsp_tag;
 logic  ln_rd_valid;
 logic  ln_rd_ready;
 logic [255:0] ln_rd_mask;
 logic [255:0][4:0] ln_rd_addr;
 logic [95:0] ln_rd_tag;
 logic  ln_rd_rsp_valid;
 logic  ln_rd_rsp_ready;
 logic [255:0][31:0] ln_rd_rsp_data;
 logic [255:0] ln_rd_rsp_mask;
 logic [95:0] ln_rd_rsp_tag;
 laya_ln_exp_storage_v1 ln_exp(.clk(clk),.rst_n(rst_n),.bind_valid(bind_fire),.bind_ready(ln_bind_ready),.bind_request_id(prepare_request_id),.bind_generation(prepare_generation),.bind_epoch(prepare_epoch),.bind_head(prepare_head),.bind_phase(3'd3),.op_request_id(request_id),.op_generation(generation),.op_epoch(epoch),.op_phase(3'd3),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),.wr_valid(ln_wr_valid),.wr_ready(ln_wr_ready),.wr_mask(ln_wr_mask),.wr_addr(ln_wr_addr),.wr_data(ln_wr_data),.wr_tag(ln_wr_tag),.wr_rsp_valid(ln_wr_rsp_valid),.wr_rsp_ready(ln_wr_rsp_ready),.wr_rsp_tag(ln_wr_rsp_tag),.rd_valid(ln_rd_valid),.rd_ready(ln_rd_ready),.rd_mask(ln_rd_mask),.rd_addr(ln_rd_addr),.rd_tag(ln_rd_tag),.rd_rsp_valid(ln_rd_rsp_valid),.rd_rsp_ready(ln_rd_rsp_ready),.rd_rsp_data(ln_rd_rsp_data),.rd_rsp_mask(ln_rd_rsp_mask),.rd_rsp_tag(ln_rd_rsp_tag),.idle(ln_idle));

 always_comb begin
  add_req_valid=0;add_req_valid[0]=fp_req_valid&&fp_grant;add_rsp_ready=0;add_rsp_ready[0]=fp_rsp_ready&&fp_grant;add_tag=0;add_tag[0]=fp_req_tag;
  for(int i=0;i<7;i++)begin add_phase[i]=3;add_epoch[i]=epoch;end
 end
 assign fp_req_ready=add_ready[0]&&fp_grant;assign fp_rsp_valid=add_rsp_valid[0]&&fp_grant;assign fp_rsp_tag=add_rsp_tag[0];assign fp_rsp_data=fp_data;
 laya_shared_fp256_v2 fp(.clk,.rst_n,.lease_valid(lease_fire),.lease_ready(fp_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_head(head),.lease_phase(3'd3),
 .release_valid(state==RELEASE),.release_ready(fp_release_ready),.release_phase(3'd3),.release_epoch(epoch),.phase_debt_clear(local_debt_clear),.lease_active(fp_owned),.draining(),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
 .mul_req_valid(1'b0),.mul_req_ready(),.mul_req_phase(3'd3),.mul_req_epoch(epoch),.mul_req_tag(96'b0),.mul_a(8192'b0),.mul_b(8192'b0),.mul_rsp_valid(),.mul_rsp_ready(1'b1),.mul_rsp_tag(),.mul_rsp_data(),
 .add_req_valid,.add_req_is_root(7'b0),.add_req_ready(add_ready),.add_req_phase(add_phase),.add_req_epoch(add_epoch),.add_req_tag(add_tag),.add_a(fp_a),.add_b(fp_b),.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data(fp_data),.mul_pending(fp_mul_pending),.add_pending(fp_add_pending),.protocol_fault(fp_fault));
 logic sfu_ready_raw,sfu_valid_raw;logic[10:0]sfu_tag_raw;logic[7:0][31:0]sfu_data_raw;
 assign sfu_req_ready=sfu_ready_raw&&sfu_grant;assign sfu_rsp_valid=sfu_valid_raw;assign sfu_rsp_tag=sfu_tag_raw;assign sfu_rsp_data=sfu_data_raw;
 laya_sfu_exp8_v1 sfu(.clk,.rst_n,.lease_valid(lease_fire),.lease_ready(sfu_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_head(head),.lease_phase(3'd3),
 .release_valid(state==RELEASE),.release_ready(sfu_release_ready),.release_phase(3'd3),.release_epoch(epoch),.phase_debt_clear(local_debt_clear),.lease_active(sfu_owned),.draining(),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),.context_valid,.context_row_hi,
 .req_valid(sfu_req_valid&&sfu_grant),.req_ready(sfu_ready_raw),.req_mode(2'b0),.req_generation(generation),.req_epoch(epoch),.req_phase(3'd3),.req_tag(sfu_req_tag),.req_x(sfu_req_x),.reject_valid(sfu_reject),.reject_code(),.rsp_valid(sfu_valid_raw),.rsp_ready(sfu_rsp_ready),.rsp_tag(sfu_tag_raw),.rsp_data(sfu_data_raw),.pending_vectors(sfu_pending),.in_flight_vectors(sfu_inflight),.protocol_fault(sfu_fault));
 logic div_ready_raw;
 assign div_req_ready=div_ready_raw&&div_grant;
 laya_shared_div8_v1 div(.clk,.rst_n,.lease_valid(lease_fire),.lease_ready(div_lease_ready),.lease_request_id(request_id),.lease_generation(generation),.lease_epoch(epoch),.lease_head(head),.lease_phase(3'd3),
 .release_valid(state==RELEASE),.release_ready(div_release_ready),.release_phase(3'd3),.release_epoch(epoch),.phase_debt_clear(local_debt_clear),.lease_active(div_owned),.draining(),.rsp_request_id(),.rsp_generation(),.rsp_epoch(),.rsp_head(),.rsp_phase(),
 .req_valid(div_req_valid&&div_grant),.req_ready(div_ready_raw),.req_generation(generation),.req_epoch(epoch),.req_phase(3'd3),.req_lane_mask(8'hff),.req_tag(div_req_tag),.req_a(div_a),.req_b(div_b),.protocol_reject_valid(div_reject),.protocol_reject_code(),
 .rsp_valid(div_rsp_valid),.rsp_ready(div_rsp_ready),.rsp_tag(div_rsp_tag),.rsp_lane_mask(),.rsp_numeric_error(div_rsp_error),.rsp_data(div_rsp_data),.pending_vectors(div_pending),.in_flight_vectors(div_inflight),.in_flight_scalars(div_scalars),.protocol_fault(div_fault));
 function automatic int sb(input int r,k);return(k/64)*512+(r%16)*32+k%32;endfunction
 function automatic int sa(input int r,k);return(r/16)*2+(k%64)/32;endfunction
 function automatic int gb(input int r,k);return(r%8)*32+k%32;endfunction
 function automatic int ga(input int r,k);return(r/8)*4+k/32;endfunction
 function automatic int la(input int r,k);return((r%64)/8)*4+k/32;endfunction
 always_comb begin
  ps_wr_valid=0;ps_wr_mask=0;ps_wr_addr=0;ps_wr_data=0;ps_wr_tag={85'b0,score_wr_row,score_wr_chunk};ps_wr_rsp_ready=1;
  score_wr_ready=0;
  if(state==PREP&&score_wr_generation==generation)begin
   ps_wr_valid=score_wr_valid;
   for(int i=0;i<8;i++)begin int k,b;k=int'(score_wr_chunk)*8+i;b=sb(int'(score_wr_row),k);ps_wr_mask[b]=1;ps_wr_addr[b]=4'(sa(int'(score_wr_row),k));ps_wr_data[b]=score_wr_data[i];end
   score_wr_ready=ps_wr_ready;
  end
  ps_rd_valid=score_rd_valid&&score_grant;ps_rd_mask=0;ps_rd_addr=0;ps_rd_tag={85'b0,score_rd_tag};score_rd_ready=ps_rd_ready&&score_grant;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(score_rd_tag[10:4]);k=int'(score_rd_tag[3:0])*8+i;b=sb(r,k);ps_rd_mask[b]=1;ps_rd_addr[b]=4'(sa(r,k));end
  score_rsp_valid=ps_rd_rsp_valid;score_rsp_tag=ps_rd_rsp_tag[10:0];ps_rd_rsp_ready=score_rsp_ready;
  for(int i=0;i<8;i++)score_rsp_data[i]=ps_rd_rsp_data[sb(int'(ps_rd_rsp_tag[10:4]),int'(ps_rd_rsp_tag[3:0])*8+i)];
  ln_wr_valid=exp_wr_valid&&exp_grant;ln_wr_mask=0;ln_wr_addr=0;ln_wr_data=0;ln_wr_tag={85'b0,exp_wr_tag};exp_wr_ready=ln_wr_ready&&exp_grant;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(exp_wr_tag[10:4]);k=int'(exp_wr_tag[3:0])*8+i;b=gb(r,k);ln_wr_mask[b]=1;ln_wr_addr[b]=5'(la(r,k));ln_wr_data[b]=exp_wr_data[i];end
  exp_wr_ack_valid=ln_wr_rsp_valid;exp_wr_ack_tag=ln_wr_rsp_tag[10:0];ln_wr_rsp_ready=exp_wr_ack_ready;
  ln_rd_valid=exp_rd_valid&&exp_grant;ln_rd_mask=0;ln_rd_addr=0;ln_rd_tag={85'b0,exp_rd_tag};exp_rd_ready=ln_rd_ready&&exp_grant;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(exp_rd_tag[10:4]);k=int'(exp_rd_tag[3:0])*8+i;b=gb(r,k);ln_rd_mask[b]=1;ln_rd_addr[b]=5'(la(r,k));end
  exp_rsp_valid=ln_rd_rsp_valid;exp_rsp_tag=ln_rd_rsp_tag[10:0];ln_rd_rsp_ready=exp_rsp_ready;
  for(int i=0;i<8;i++)exp_rsp_data[i]=ln_rd_rsp_data[gb(int'(ln_rd_rsp_tag[10:4]),int'(ln_rd_rsp_tag[3:0])*8+i)];
  g_wr_valid=prob_wr_valid&&prob_grant;g_wr_mask=0;g_wr_addr=0;g_wr_data=0;g_wr_tag={85'b0,prob_wr_tag};prob_wr_ready=g_wr_ready&&prob_grant;
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(prob_wr_tag[10:4]);k=int'(prob_wr_tag[3:0])*8+i;b=gb(r,k);g_wr_mask[b]=1;g_wr_addr[b]=6'(ga(r,k));g_wr_data[b]=prob_wr_data[i];end
  prob_wr_ack_valid=g_wr_rsp_valid;prob_wr_ack_tag=g_wr_rsp_tag[10:0];g_wr_rsp_ready=prob_wr_ack_ready;
  g_rd_valid=prob_rd_valid&&state==RUN&&done_valid&&done_status==0&&prob_rd_generation==generation;prob_rd_ready=g_rd_ready&&state==RUN&&done_valid&&done_status==0&&prob_rd_generation==generation;
  g_rd_mask=0;g_rd_addr=0;g_rd_tag={53'b0,prob_rd_row,prob_rd_chunk,prob_rd_tag};
  for(int i=0;i<8;i++)begin int r,k,b;r=int'(prob_rd_row);k=int'(prob_rd_chunk)*8+i;b=gb(r,k);g_rd_mask[b]=1;g_rd_addr[b]=6'(ga(r,k));end
  prob_rsp_valid=g_rd_rsp_valid&&(state==RUN||state==RELEASE);prob_rsp_tag=g_rd_rsp_tag[31:0];g_rd_rsp_ready=prob_rsp_ready&&(state==RUN||state==RELEASE);
  for(int i=0;i<8;i++)prob_rsp_data[i]=g_rd_rsp_data[gb(int'(g_rd_rsp_tag[42:36]),int'(g_rd_rsp_tag[35:32])*8+i)];
  context_wr_valid=0;context_wr_mask=0;context_wr_addr=0;context_wr_data=0;context_wr_tag=0;context_wr_rsp_ready=1;
  context_rd_valid=0;context_rd_mask=0;context_rd_addr=0;context_rd_tag=0;context_rd_rsp_ready=1;
 end
endmodule
