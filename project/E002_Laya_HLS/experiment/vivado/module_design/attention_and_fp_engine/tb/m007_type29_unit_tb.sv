`timescale 1ns/1ps
module m007_type29_unit_tb;
 logic clk=0;always #2 clk=~clk;logic rst_n=0;
 logic owner_valid=1;logic[63:0]owner_request_id=64'h219abc;logic[31:0]owner_generation=23,owner_epoch=41;
 logic[63:0]access_request_id;logic[31:0]access_generation,access_epoch;logic wrong_identity=0;bit wrong_epoch=0;integer op_arg=1;logic type_model_committed=0;logic[1:0]type_qtype=2;
 assign access_request_id=owner_request_id;assign access_generation=owner_generation+32'(wrong_identity);assign access_epoch=owner_epoch;
 logic start_valid=0,start_ready,start_reject_valid,done_valid,done_ready=0,idle,control_retired;logic[1:0]start_op=0;
 logic[63:0]start_request_id;logic[31:0]start_generation,start_epoch;
 assign start_request_id=owner_request_id;assign start_generation=owner_generation+32'(wrong_identity);assign start_epoch=owner_epoch+32'(wrong_epoch);
 logic scratch_active;logic loaded=0,inputs_ready;assign inputs_ready=loaded&&scratch_active&&(op_arg!=1||(type_model_committed&&type_qtype<3));
 logic[31:0]done_status;logic[6:0]done_error_row;logic[9:0]done_error_column;logic[12:0]issued_vectors,retired_vectors;
 logic h_rd_valid,h_rd_ready,q_rd_valid,q_rd_ready,h_rsp_valid,h_rsp_ready,q_rsp_valid,q_rsp_ready,h_wr_valid,h_wr_ready,h_wr_commit;
 logic[11:0]h_rd_addr,q_rd_addr,h_rsp_addr,q_rsp_addr,h_wr_addr;logic[31:0][31:0]h_rsp_data,q_rsp_data,h_wr_data;
 logic fp_lease_valid,fp_lease_ready,fp_release_valid,fp_release_ready,fp_phase_debt_clear,fp_lease_active,fp_protocol_fault,fp_draining;
 logic[63:0]fp_lease_request_id,fp_rsp_request_id;logic[31:0]fp_lease_generation,fp_lease_epoch,fp_release_epoch,fp_rsp_generation,fp_rsp_epoch;
 logic[3:0]fp_lease_head,fp_rsp_head;logic[2:0]fp_lease_phase,fp_release_phase,fp_rsp_phase;
 logic[6:0]add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;logic[6:0][2:0]add_req_phase;logic[6:0][31:0]add_req_epoch;logic[6:0][95:0]add_req_tag,add_rsp_tag;logic[255:0][31:0]add_a,add_b,add_rsp_data;
 integer mode,cycles=0,start_cycle=-1,first_commit=-1,done_cycle=-1,commits=0,checked=0,scan_checked=0,lease_count=0,release_count=0,held_write_cycles=0;bit hold_started=0,hold_done=0;
 logic external_control_enable=1;logic[47:0]external_control_q=0,external_control_next;logic control_private_idle;
 logic type_rd_valid,type_rd_ready,type_rsp_valid,type_rsp_ready;logic[11:0]type_rd_addr,type_rsp_addr;logic[31:0][31:0]type_rsp_data;
 integer q_hold_cycles=0,type_hold_cycles=0,type_checked=0,op0_compared=0,first_status=0,first_issued=0,first_retired=0,q_reads=0,type_reads=0,h_reads=0;
 bit recovery=0,epoch_fault_done=0,compare_op0=0;
 logic type_setup_valid=0,type_setup_ready,type_setup_commit,type_idle,type_reject,bank_reset_n=1;
 logic[1:0]tb_type_qtype=0;logic[6:0]type_setup_index=0;logic[31:0][31:0]type_setup_data;
 logic tb_type_rd=0,tb_type_ready=0,raw_type_valid,raw_type_ready,raw_type_rd_ready,raw_q_rsp_valid;
 logic[11:0]tb_type_addr=0,raw_type_addr;logic[31:0][31:0]raw_type_data;logic[31:0]T[0:3071];string tf;
 wire q_response_gate=!(op_arg==1&&mode==3&&!recovery&&raw_q_rsp_valid&&q_rsp_addr==0&&q_hold_cycles<17);
 wire type_response_gate=!(op_arg==1&&mode==3&&!recovery&&raw_type_valid&&raw_type_addr==32&&type_hold_cycles<17);
 logic[31:0]raw_fp_rsp_epoch;
 wire epoch_fault=mode==6&&!recovery&&!epoch_fault_done&&add_rsp_valid[0];
 assign fp_rsp_epoch=raw_fp_rsp_epoch^32'(epoch_fault);
 always@(posedge clk)begin if(!rst_n)external_control_q<=0;else if(external_control_enable)external_control_q<=external_control_next;end
 laya_m007_resident_vector32_v3 #(.EXTERNAL_CONTROL(1)) provider(.*);
 logic mul_req_ready,mul_rsp_valid;logic[95:0]mul_rsp_tag;logic[255:0][31:0]mul_rsp_data;logic[6:0]mul_pending;logic[6:0][6:0]add_pending;
 laya_shared_fp256_v2 fp(.clk,.rst_n,.lease_valid(fp_lease_valid),.lease_ready(fp_lease_ready),.lease_request_id(fp_lease_request_id),.lease_generation(fp_lease_generation),.lease_epoch(fp_lease_epoch),.lease_head(fp_lease_head),.lease_phase(fp_lease_phase),
 .release_valid(fp_release_valid),.release_ready(fp_release_ready),.release_phase(fp_release_phase),.release_epoch(fp_release_epoch),.phase_debt_clear(fp_phase_debt_clear),.lease_active(fp_lease_active),.draining(fp_draining),.rsp_request_id(fp_rsp_request_id),.rsp_generation(fp_rsp_generation),.rsp_epoch(raw_fp_rsp_epoch),.rsp_head(fp_rsp_head),.rsp_phase(fp_rsp_phase),
 .mul_req_valid(1'b0),.mul_req_ready,.mul_req_phase(3'd7),.mul_req_epoch(owner_epoch),.mul_req_tag(96'b0),.mul_a(8192'b0),.mul_b(8192'b0),.mul_rsp_valid,.mul_rsp_ready(1'b1),.mul_rsp_tag,.mul_rsp_data,
 .add_req_valid,.add_req_is_root,.add_req_ready,.add_req_phase,.add_req_epoch,.add_req_tag,.add_a,.add_b,.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data,.mul_pending,.add_pending,.protocol_fault(fp_protocol_fault));
 logic run_provider=0,tb_wr_valid=0,tb_rd_valid=0,tb_rsp_ready=0;
 logic[11:0]tb_addr=0,tb_wr_addr=0;logic[31:0][31:0]tb_h_data,tb_q_data;
 logic raw_h_rd_ready,raw_h_wr_ready,raw_h_commit,h_idle,h_reject,raw_q_rd_ready,raw_q_wr_ready,raw_q_commit,q_reject;
 logic[11:0]bank_h_addr,bank_q_addr,bank_h_wr_addr;logic[31:0][31:0]bank_h_wr_data;
 logic bank_h_rd_valid,bank_q_rd_valid,bank_h_wr_valid,bank_h_rsp_ready,bank_q_rsp_ready;
 wire read_gate=mode!=1||h_rd_addr<512;
 wire write_gate=!(mode==3&&h_wr_addr==4095&&h_wr_valid&&!hold_done);
 assign bank_h_rd_valid=run_provider?(h_rd_valid&&read_gate):tb_rd_valid;
 assign bank_q_rd_valid=run_provider?(q_rd_valid&&read_gate):tb_rd_valid;
 assign h_rd_ready=raw_h_rd_ready&&read_gate;assign q_rd_ready=raw_q_rd_ready&&read_gate;
 assign bank_h_addr=run_provider?h_rd_addr:tb_addr;assign bank_q_addr=run_provider?q_rd_addr:tb_addr;
 assign bank_h_wr_valid=run_provider?(h_wr_valid&&write_gate):tb_wr_valid;
 assign bank_h_wr_addr=run_provider?h_wr_addr:tb_wr_addr;assign bank_h_wr_data=run_provider?h_wr_data:tb_h_data;
 assign h_wr_ready=raw_h_wr_ready&&write_gate;assign h_wr_commit=raw_h_commit&&run_provider;
 assign bank_h_rsp_ready=run_provider?h_rsp_ready:tb_rsp_ready;assign bank_q_rsp_ready=run_provider?(q_rsp_ready&&q_response_gate):tb_rsp_ready;
 laya_m007_hidden32_owner_v1 hidden(.clk,.rst_n,.owner_valid,.owner_request_id,.owner_generation,.owner_epoch,.access_request_id,.access_generation,.access_epoch,
 .wr_valid(bank_h_wr_valid),.wr_ready(raw_h_wr_ready),.wr_addr(bank_h_wr_addr),.wr_data(bank_h_wr_data),.wr_commit(raw_h_commit),.rd_valid(bank_h_rd_valid),.rd_ready(raw_h_rd_ready),.rd_addr(bank_h_addr),.rd_rsp_valid(h_rsp_valid),.rd_rsp_ready(bank_h_rsp_ready),.rd_rsp_addr(h_rsp_addr),.rd_rsp_data(h_rsp_data),.bank_idle(h_idle),.reject_valid(h_reject));
 logic scratch_lease_valid=0,scratch_lease_ready,scratch_release_valid=0,scratch_release_ready,normal_enable,scratch_retired;
 logic rope_owner_valid=0,q_wr_valid,q_wr_ready,q_wr_half,q_rd_valid_raw,q_rd_ready_raw,q_rsp_ready_raw;
 logic[1:0]q_wr_plane;logic[3:0]q_wr_head,q_rd_head;logic[6:0]q_wr_token,q_rd_token;logic[31:0]q_rd_tag;logic[31:0][31:0]q_wr_data;
 logic[2:0]qkv_rd_valid,qkv_rd_ready,qkv_rsp_valid,qkv_rsp_ready;logic[2:0][3:0]qkv_rd_head,qkv_rsp_head;logic[2:0][6:0]qkv_rd_token,qkv_rsp_token;logic[2:0][31:0]qkv_rd_tag,qkv_rsp_tag;logic[2:0][63:0][31:0]qkv_rsp_data;
 laya_m007_qscratch32_v1 scratch(.clk,.rst_n,.lease_valid(scratch_lease_valid),.lease_ready(scratch_lease_ready),.release_valid(scratch_release_valid),.release_ready(scratch_release_ready),
 .layer_retired(1'b1),.matrix_retired(1'b1),.quant_retired(1'b1),.normal_requests_present(1'b0),.rope_owner_valid,.qkv_rsp_valid,.owner_request_id,.owner_generation,.owner_epoch,.owner_active(scratch_active),.normal_enable,
 .access_request_id,.access_generation,.access_epoch,.wr_valid(tb_wr_valid&&!run_provider),.wr_ready(raw_q_wr_ready),.wr_addr(tb_wr_addr),.wr_data(tb_q_data),.wr_commit(raw_q_commit),
 .rd_valid(bank_q_rd_valid),.rd_ready(raw_q_rd_ready),.rd_addr(bank_q_addr),.rd_rsp_valid(raw_q_rsp_valid),.rd_rsp_ready(bank_q_rsp_ready),.rd_rsp_addr(q_rsp_addr),.rd_rsp_data(q_rsp_data),.reject_valid(q_reject),.retired(scratch_retired),
 .q_wr_valid,.q_wr_ready,.q_wr_plane,.q_wr_head,.q_wr_token,.q_wr_half,.q_wr_data,.q_rd_valid(q_rd_valid_raw),.q_rd_ready(q_rd_ready_raw),.q_rd_head,.q_rd_token,.q_rd_tag,.q_rsp_valid(qkv_rsp_valid[0]),.q_rsp_ready(q_rsp_ready_raw),.q_rsp_tag(qkv_rsp_tag[0]),.q_rsp_data(qkv_rsp_data[0]));
 always_comb begin
  qkv_rd_valid=0;qkv_rd_head=0;qkv_rd_token=0;qkv_rd_tag=0;qkv_rsp_ready=0;
  qkv_rd_valid[0]=q_rd_valid_raw;qkv_rd_head[0]=q_rd_head;qkv_rd_token[0]=q_rd_token;qkv_rd_tag[0]=q_rd_tag;qkv_rsp_ready[0]=q_rsp_ready_raw;
 end
 assign q_rd_ready_raw=qkv_rd_ready[0];
 logic rope_wr_ready,rope_commit,rope_reject;logic[95:0]rope_commit_tag;logic[2:0]rope_reject_code;
 laya_attention_qkv_bank_v2 sole_qkv(.clk,.rst_n,.wr_valid(q_wr_valid),.wr_ready(q_wr_ready),.wr_plane(q_wr_plane),.wr_head(q_wr_head),.wr_token(q_wr_token),.wr_half(q_wr_half),.wr_data(q_wr_data),
 .rd_valid(qkv_rd_valid),.rd_ready(qkv_rd_ready),.rd_head(qkv_rd_head),.rd_token(qkv_rd_token),.rd_tag(qkv_rd_tag),.rd_rsp_valid(qkv_rsp_valid),.rd_rsp_ready(qkv_rsp_ready),.rd_rsp_head(qkv_rsp_head),.rd_rsp_token(qkv_rsp_token),.rd_rsp_tag(qkv_rsp_tag),.rd_rsp_data(qkv_rsp_data),
 .rope_owner_valid,.rope_owner_request_id(owner_request_id),.rope_owner_generation(owner_generation),.rope_owner_epoch(owner_epoch),.rope_wr_valid(1'b0),.rope_wr_ready,.rope_wr_request_id(owner_request_id),.rope_wr_generation(owner_generation),.rope_wr_epoch(owner_epoch),.rope_wr_head(4'b0),.rope_wr_token(7'b0),.rope_wr_tag(96'b0),.rope_wr_q(2048'b0),.rope_wr_k(2048'b0),.rope_wr_commit_valid(rope_commit),.rope_wr_commit_tag(rope_commit_tag),.rope_reject_valid(rope_reject),.rope_reject_code);
 assign q_rsp_valid=raw_q_rsp_valid&&(!run_provider||q_response_gate);
 assign type_rd_ready=raw_type_rd_ready;
 assign type_rsp_valid=raw_type_valid&&(!run_provider||type_response_gate);
 assign type_rsp_addr=raw_type_addr^((mode==5&&!recovery&&run_provider&&raw_type_addr==3)?12'h020:12'b0);
 assign type_rsp_data=raw_type_data;
 assign raw_type_ready=run_provider?(type_rsp_ready&&type_response_gate):tb_type_ready;
 laya_m007_type32_v1 type_bank(.clk,.rst_n(rst_n&&bank_reset_n),.model_committed(type_model_committed),.inference_active(run_provider),
  .wr_valid(type_setup_valid),.wr_ready(type_setup_ready),.wr_index(type_setup_index),.wr_data(type_setup_data),.wr_commit(type_setup_commit),
  .rd_valid(run_provider?type_rd_valid:tb_type_rd),.rd_ready(raw_type_rd_ready),.rd_qtype(run_provider?type_qtype:tb_type_qtype),.rd_vector_addr(run_provider?type_rd_addr:tb_type_addr),
  .rsp_valid(raw_type_valid),.rsp_ready(raw_type_ready),.rsp_vector_addr(raw_type_addr),.rsp_data(raw_type_data),.bank_idle(type_idle),.reject_valid(type_reject));
 logic[31:0]H[0:131071],Q[0:131071],GOLD[0:131071];string hf,qf,gf,pf;integer progress_fd;
 logic[47:0]v2_next;logic v2_private_idle;
 logic  v2_start_ready;
 logic  v2_start_reject_valid;
 logic  v2_done_valid;
 logic [31:0] v2_done_status;
 logic [6:0] v2_done_error_row;
 logic [9:0] v2_done_error_column;
 logic  v2_idle;
 logic  v2_control_retired;
 logic [12:0] v2_issued_vectors;
 logic [12:0] v2_retired_vectors;
 logic  v2_h_rd_valid;
 logic [11:0] v2_h_rd_addr;
 logic  v2_h_rsp_ready;
 logic  v2_q_rd_valid;
 logic [11:0] v2_q_rd_addr;
 logic  v2_q_rsp_ready;
 logic  v2_h_wr_valid;
 logic [11:0] v2_h_wr_addr;
 logic [31:0][31:0] v2_h_wr_data;
 logic  v2_fp_lease_valid;
 logic [63:0] v2_fp_lease_request_id;
 logic [31:0] v2_fp_lease_generation;
 logic [31:0] v2_fp_lease_epoch;
 logic [3:0] v2_fp_lease_head;
 logic [2:0] v2_fp_lease_phase;
 logic  v2_fp_release_valid;
 logic [2:0] v2_fp_release_phase;
 logic [31:0] v2_fp_release_epoch;
 logic  v2_fp_phase_debt_clear;
 logic [6:0] v2_add_req_valid;
 logic [6:0] v2_add_req_is_root;
 logic [6:0][2:0] v2_add_req_phase;
 logic [6:0][31:0] v2_add_req_epoch;
 logic [6:0][95:0] v2_add_req_tag;
 logic [255:0][31:0] v2_add_a;
 logic [255:0][31:0] v2_add_b;
 logic [6:0] v2_add_rsp_ready;
 laya_m007_resident_vector32_v2 #(.EXTERNAL_CONTROL(0)) original_op0(
 .external_control_enable(1'b1),
 .external_control_q(48'b0),
 .external_control_next(v2_next),
 .control_private_idle(v2_private_idle),
 .clk(clk),
 .rst_n(rst_n),
 .owner_valid(owner_valid),
 .inputs_ready(inputs_ready),
 .owner_request_id(owner_request_id),
 .owner_generation(owner_generation),
 .owner_epoch(owner_epoch),
 .start_valid(start_valid),
 .start_ready(v2_start_ready),
 .start_op(start_op),
 .start_request_id(start_request_id),
 .start_generation(start_generation),
 .start_epoch(start_epoch),
 .start_reject_valid(v2_start_reject_valid),
 .done_valid(v2_done_valid),
 .done_ready(done_ready),
 .done_status(v2_done_status),
 .done_error_row(v2_done_error_row),
 .done_error_column(v2_done_error_column),
 .idle(v2_idle),
 .control_retired(v2_control_retired),
 .issued_vectors(v2_issued_vectors),
 .retired_vectors(v2_retired_vectors),
 .h_rd_valid(v2_h_rd_valid),
 .h_rd_ready(h_rd_ready),
 .h_rd_addr(v2_h_rd_addr),
 .h_rsp_valid(h_rsp_valid),
 .h_rsp_ready(v2_h_rsp_ready),
 .h_rsp_addr(h_rsp_addr),
 .h_rsp_data(h_rsp_data),
 .q_rd_valid(v2_q_rd_valid),
 .q_rd_ready(q_rd_ready),
 .q_rd_addr(v2_q_rd_addr),
 .q_rsp_valid(q_rsp_valid),
 .q_rsp_ready(v2_q_rsp_ready),
 .q_rsp_addr(q_rsp_addr),
 .q_rsp_data(q_rsp_data),
 .h_wr_valid(v2_h_wr_valid),
 .h_wr_ready(h_wr_ready),
 .h_wr_addr(v2_h_wr_addr),
 .h_wr_data(v2_h_wr_data),
 .h_wr_commit(h_wr_commit),
 .fp_lease_valid(v2_fp_lease_valid),
 .fp_lease_ready(fp_lease_ready),
 .fp_lease_request_id(v2_fp_lease_request_id),
 .fp_lease_generation(v2_fp_lease_generation),
 .fp_lease_epoch(v2_fp_lease_epoch),
 .fp_lease_head(v2_fp_lease_head),
 .fp_lease_phase(v2_fp_lease_phase),
 .fp_release_valid(v2_fp_release_valid),
 .fp_release_ready(fp_release_ready),
 .fp_release_phase(v2_fp_release_phase),
 .fp_release_epoch(v2_fp_release_epoch),
 .fp_phase_debt_clear(v2_fp_phase_debt_clear),
 .fp_lease_active(fp_lease_active),
 .fp_rsp_request_id(fp_rsp_request_id),
 .fp_rsp_generation(fp_rsp_generation),
 .fp_rsp_epoch(fp_rsp_epoch),
 .fp_rsp_head(fp_rsp_head),
 .fp_rsp_phase(fp_rsp_phase),
 .fp_protocol_fault(fp_protocol_fault),
 .add_req_valid(v2_add_req_valid),
 .add_req_is_root(v2_add_req_is_root),
 .add_req_ready(add_req_ready),
 .add_req_phase(v2_add_req_phase),
 .add_req_epoch(v2_add_req_epoch),
 .add_req_tag(v2_add_req_tag),
 .add_a(v2_add_a),
 .add_b(v2_add_b),
 .add_rsp_valid(add_rsp_valid),
 .add_rsp_ready(v2_add_rsp_ready),
 .add_rsp_tag(add_rsp_tag),
 .add_rsp_data(add_rsp_data)
 );
 always@(posedge clk)if(rst_n&&compare_op0)begin
  if(start_ready!==v2_start_ready)$fatal(1,"OP0_EQ_start_ready");
  if(start_reject_valid!==v2_start_reject_valid)$fatal(1,"OP0_EQ_start_reject_valid");
  if(done_valid!==v2_done_valid)$fatal(1,"OP0_EQ_done_valid");
  if(done_status!==v2_done_status)$fatal(1,"OP0_EQ_done_status");
  if(done_error_row!==v2_done_error_row)$fatal(1,"OP0_EQ_done_error_row");
  if(done_error_column!==v2_done_error_column)$fatal(1,"OP0_EQ_done_error_column");
  if(idle!==v2_idle)$fatal(1,"OP0_EQ_idle");
  if(control_retired!==v2_control_retired)$fatal(1,"OP0_EQ_control_retired");
  if(issued_vectors!==v2_issued_vectors)$fatal(1,"OP0_EQ_issued_vectors");
  if(retired_vectors!==v2_retired_vectors)$fatal(1,"OP0_EQ_retired_vectors");
  if(h_rd_valid!==v2_h_rd_valid)$fatal(1,"OP0_EQ_h_rd_valid");
  if(h_rd_addr!==v2_h_rd_addr)$fatal(1,"OP0_EQ_h_rd_addr");
  if(h_rsp_ready!==v2_h_rsp_ready)$fatal(1,"OP0_EQ_h_rsp_ready");
  if(q_rd_valid!==v2_q_rd_valid)$fatal(1,"OP0_EQ_q_rd_valid");
  if(q_rd_addr!==v2_q_rd_addr)$fatal(1,"OP0_EQ_q_rd_addr");
  if(q_rsp_ready!==v2_q_rsp_ready)$fatal(1,"OP0_EQ_q_rsp_ready");
  if(h_wr_valid!==v2_h_wr_valid)$fatal(1,"OP0_EQ_h_wr_valid");
  if(h_wr_addr!==v2_h_wr_addr)$fatal(1,"OP0_EQ_h_wr_addr");
  if(h_wr_data!==v2_h_wr_data)$fatal(1,"OP0_EQ_h_wr_data");
  if(fp_lease_valid!==v2_fp_lease_valid)$fatal(1,"OP0_EQ_fp_lease_valid");
  if(fp_lease_request_id!==v2_fp_lease_request_id)$fatal(1,"OP0_EQ_fp_lease_request_id");
  if(fp_lease_generation!==v2_fp_lease_generation)$fatal(1,"OP0_EQ_fp_lease_generation");
  if(fp_lease_epoch!==v2_fp_lease_epoch)$fatal(1,"OP0_EQ_fp_lease_epoch");
  if(fp_lease_head!==v2_fp_lease_head)$fatal(1,"OP0_EQ_fp_lease_head");
  if(fp_lease_phase!==v2_fp_lease_phase)$fatal(1,"OP0_EQ_fp_lease_phase");
  if(fp_release_valid!==v2_fp_release_valid)$fatal(1,"OP0_EQ_fp_release_valid");
  if(fp_release_phase!==v2_fp_release_phase)$fatal(1,"OP0_EQ_fp_release_phase");
  if(fp_release_epoch!==v2_fp_release_epoch)$fatal(1,"OP0_EQ_fp_release_epoch");
  if(fp_phase_debt_clear!==v2_fp_phase_debt_clear)$fatal(1,"OP0_EQ_fp_phase_debt_clear");
  if(add_req_valid!==v2_add_req_valid)$fatal(1,"OP0_EQ_add_req_valid");
  if(add_req_is_root!==v2_add_req_is_root)$fatal(1,"OP0_EQ_add_req_is_root");
  if(add_req_phase!==v2_add_req_phase)$fatal(1,"OP0_EQ_add_req_phase");
  if(add_req_epoch!==v2_add_req_epoch)$fatal(1,"OP0_EQ_add_req_epoch");
  if(add_req_tag!==v2_add_req_tag)$fatal(1,"OP0_EQ_add_req_tag");
  if(add_a!==v2_add_a)$fatal(1,"OP0_EQ_add_a");
  if(add_b!==v2_add_b)$fatal(1,"OP0_EQ_add_b");
  if(add_rsp_ready!==v2_add_rsp_ready)$fatal(1,"OP0_EQ_add_rsp_ready");
  if(external_control_next!==v2_next||control_private_idle!==v2_private_idle)$fatal(1,"OP0_Q_NEXT_EQ");op0_compared++;end
 task automatic step;@(posedge clk);#0.01;endtask
 task automatic pair_read(input integer addr,input bit check_gold);
  @(negedge clk);tb_addr=12'(addr);tb_rd_valid=1;tb_rsp_ready=0;#0.001;if(!raw_h_rd_ready||!raw_q_rd_ready)$fatal(1,"READ_NOT_READY");step();
  @(negedge clk);tb_rd_valid=0;if(!h_rsp_valid||!q_rsp_valid||h_rsp_addr!=addr||q_rsp_addr!=addr)$fatal(1,"SYNC_READ_ADDR");
  for(int l=0;l<32;l++)if(h_rsp_data[l]!== (check_gold?GOLD[addr*32+l]:H[addr*32+l])||q_rsp_data[l]!==Q[addr*32+l])$fatal(1,"BANK_SCAN addr=%0d lane=%0d",addr,l);
  scan_checked=scan_checked+32;tb_rsp_ready=1;step();@(negedge clk);tb_rsp_ready=0;
 endtask

 task automatic setup_type;
  type_model_committed=0;
  for(int a=0;a<96;a++)begin @(negedge clk);type_setup_valid=1;type_setup_index=7'(a);for(int l=0;l<32;l++)type_setup_data[l]=T[a*32+l];#0.001;if(!type_setup_ready||!type_setup_commit)$fatal(1,"TYPE_SETUP");step();end
  @(negedge clk);type_setup_valid=0;type_model_committed=1;
 endtask
 task automatic type_read_check(input int qt,addr,held);
  @(negedge clk);tb_type_qtype=2'(qt);tb_type_addr=12'(addr);tb_type_rd=1;tb_type_ready=0;#0.001;if(!raw_type_rd_ready)$fatal(1,"TYPE_RD_READY");step();@(negedge clk);tb_type_rd=0;
  if(!raw_type_valid||raw_type_addr!=addr)$fatal(1,"TYPE_SYNC_ADDR");
  repeat(held)begin step();if(!raw_type_valid||type_idle||raw_type_rd_ready||control_retired||control_private_idle||raw_type_addr!=addr)$fatal(1,"TYPE_HELD17_BARRIER");for(int l=0;l<32;l++)if(raw_type_data[l]!==T[qt*1024+(addr%32)*32+l])$fatal(1,"TYPE_HELD_PAYLOAD");end
  for(int l=0;l<32;l++)if(raw_type_data[l]!==T[qt*1024+(addr%32)*32+l])$fatal(1,"TYPE_ROUTE");type_checked+=32;checked+=32;
  $fdisplay(progress_fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":0,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",checked,cycles,type_checked);$fflush(progress_fd);
  @(negedge clk);tb_type_ready=1;step();@(negedge clk);tb_type_ready=0;
 endtask
 task automatic load_pair(input bit bad);
  for(int a=0;a<4096;a++)begin
   @(negedge clk);tb_wr_valid=1;tb_wr_addr=12'(a);for(int l=0;l<32;l++)begin tb_h_data[l]=H[a*32+l];tb_q_data[l]=(bad&&a==3&&l==5)?32'h7fc12345:Q[a*32+l];end
   #0.001;if(!raw_h_wr_ready||!raw_q_wr_ready||!raw_h_commit||!raw_q_commit)$fatal(1,"LOAD_COMMIT");step();
  end
  @(negedge clk);tb_wr_valid=0;loaded=1;
 endtask
 task automatic execute(input int expect_status);
  q_reads=0;type_reads=0;h_reads=0;@(negedge clk);run_provider=1;start_valid=1;#0.001;if(!start_ready)$fatal(1,"START_NOT_READY");step();@(negedge clk);start_valid=0;
  wait(done_valid);@(negedge clk);
  if(done_status!=expect_status||fp_lease_active||add_pending||mul_pending||h_rsp_valid||q_rsp_valid||type_rsp_valid||issued_vectors!=retired_vectors)$fatal(1,"DONE_REAL_DEBT status=%0d expected=%0d",done_status,expect_status);
  if(expect_status==0&&(commits!=4096||done_cycle-start_cycle-q_hold_cycles-type_hold_cycles-held_write_cycles>4160))$fatal(1,"FULL_BOUND");
  if(expect_status==6&&(done_error_row!=0||done_error_column!=101||issued_vectors>=4096))$fatal(1,"NAN_FIRST_ERROR");
  repeat(17)begin step();if(!done_valid||control_retired||start_ready)$fatal(1,"HELD_DONE");end
  if(expect_status==0&&done_cycle-start_cycle-q_hold_cycles-type_hold_cycles-held_write_cycles>4160)$fatal(1,"REAL_DONE_CYCLE_BOUND");
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;run_provider=0;if(!control_retired)$fatal(1,"POST_DONE_RETIRE");
 endtask
 initial begin
  if(!$value$plusargs("MODE=%d",mode)||!$value$plusargs("OP=%d",op_arg)||!$value$plusargs("TYPE=%s",tf)||!$value$plusargs("H=%s",hf)||!$value$plusargs("Q=%s",qf)||!$value$plusargs("GOLD=%s",gf)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  start_op=2'(op_arg);$readmemh(tf,T);$readmemh(hf,H);$readmemh(qf,Q);$readmemh(gf,GOLD);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;
  tb_type_rd=1;#0.001;if(raw_type_rd_ready||!type_reject)$fatal(1,"TYPE_UNCOMMITTED_READ");step();@(negedge clk);tb_type_rd=0;setup_type();
  type_setup_valid=1;#0.001;if(type_setup_ready||!type_reject)$fatal(1,"TYPE_COMMITTED_WRITE");step();@(negedge clk);type_setup_valid=0;
  for(int qt=0;qt<3;qt++)for(int c=0;c<32;c++)type_read_check(qt,((qt+3)*32)+c,qt==1&&c==17?17:0);
  @(negedge clk);tb_type_qtype=3;tb_type_rd=1;#0.001;if(raw_type_rd_ready||!type_reject)$fatal(1,"TYPE3_READ");step();@(negedge clk);tb_type_rd=0;tb_type_qtype=0;
  // Actual held response reset invalidation, followed by legal complete setup again.
  tb_type_addr=4095;tb_type_rd=1;step();@(negedge clk);tb_type_rd=0;bank_reset_n=0;type_model_committed=0;step();@(negedge clk);bank_reset_n=1;if(raw_type_valid)$fatal(1,"TYPE_RESET_RESPONSE");setup_type();type_read_check(2,4095,0);
  type_model_committed=0;type_setup_valid=1;type_setup_index=96;#0.001;if(type_setup_ready||!type_reject)$fatal(1,"TYPE_SETUP_INDEX");step();@(negedge clk);type_setup_valid=0;type_model_committed=1;
  compare_op0=op_arg==0;
  rope_owner_valid=1;scratch_lease_valid=1;#0.001;if(scratch_lease_ready)$fatal(1,"ROPE_ADMISSION");step();@(negedge clk);rope_owner_valid=0;#0.001;if(!scratch_lease_ready)$fatal(1,"SCRATCH_NOT_READY");step();@(negedge clk);scratch_lease_valid=0;
  wrong_identity=1;tb_wr_valid=1;tb_rd_valid=1;#0.001;if(raw_h_wr_ready||raw_h_rd_ready||raw_q_wr_ready||raw_q_rd_ready||!h_reject||!q_reject)$fatal(1,"OLD_IDENTITY_ACCEPT");step();@(negedge clk);tb_wr_valid=0;tb_rd_valid=0;wrong_identity=0;
  start_valid=1;#0.001;if(start_ready||!start_reject_valid)$fatal(1,"UNINITIALIZED_START");step();@(negedge clk);start_valid=0;
  load_pair(mode==4);
  wrong_epoch=1;start_valid=1;#0.001;if(start_ready||!start_reject_valid)$fatal(1,"OLD_START_EPOCH");step();@(negedge clk);start_valid=0;wrong_epoch=0;
  execute(mode>=5?8:mode==4?6:0);first_status=mode>=5?8:mode==4?6:0;first_issued=issued_vectors;first_retired=retired_vectors;
  if(mode>=4)begin
   @(negedge clk);scratch_release_valid=1;#0.001;if(!scratch_release_ready)$fatal(1,"ERROR_SCRATCH_RELEASE");step();@(negedge clk);scratch_release_valid=0;owner_generation++;owner_epoch++;scratch_lease_valid=1;step();@(negedge clk);scratch_lease_valid=0;
   recovery=1;loaded=0;commits=0;first_commit=-1;done_cycle=-1;load_pair(0);execute(0);
  end
  if(mode==3&&(q_hold_cycles!=17||type_hold_cycles!=17||held_write_cycles!=17))$fatal(1,"HELD_COVERAGE");
  for(int a=0;a<4096;a++)pair_read(a,1);
  @(negedge clk);scratch_release_valid=1;#0.001;if(!scratch_release_ready||!type_idle)$fatal(1,"FINAL_RELEASE");step();@(negedge clk);scratch_release_valid=0;
  if(op_arg==0&&op0_compared==0)$fatal(1,"OP0_EQ_NO_CYCLES");
  $display("HARDWARE_AGENT_SIM_PASS TYPE29_UNIT op=%0d mode=%0d commits=%0d checked=%0d scan_checked=%0d type_checked=%0d q_held=%0d type_held=%0d finalH_held=%0d first_status=%0d first_issued=%0d first_retired=%0d recovered=%0d lease_count=%0d release_count=%0d op0_compared=%0d q_reads=%0d type_reads=%0d h_reads=%0d external_bits=48 type_control_bits=13",op_arg,mode,commits,checked,scan_checked,type_checked,q_hold_cycles,type_hold_cycles,held_write_cycles,first_status,first_issued,first_retired,recovery,lease_count,release_count,op0_compared,q_reads,type_reads,h_reads);
  $fclose(progress_fd);compare_op0=0;@(negedge clk);external_control_enable=0;external_control_q='1;loaded=0;start_valid=1;repeat(3)begin step();if(type_rd_valid||type_rsp_ready||h_rd_valid||q_rd_valid||h_wr_valid||fp_lease_valid||fp_release_valid||done_valid||control_retired||idle||external_control_next!==external_control_q)$fatal(1,"INACTIVE_FOREIGN_Q");end
  $finish;
 end
 always @(negedge clk)if(rst_n&&mode==3&&h_wr_valid&&h_wr_addr==4095&&!hold_done)begin
  hold_started=1;if(held_write_cycles==17)hold_done=1;else held_write_cycles=held_write_cycles+1;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>40000000)$fatal(1,"CYCLE_LIMIT");
  if(rst_n)begin
   if(run_provider)begin if(q_rd_valid&&q_rd_ready)q_reads++;if(type_rd_valid&&type_rd_ready)type_reads++;if(h_rd_valid&&h_rd_ready)h_reads++;end
   if(epoch_fault&&add_rsp_valid[0]&&add_rsp_ready[0])epoch_fault_done<=1;
   if(!q_response_gate)begin q_hold_cycles<=q_hold_cycles+1;if(bank_q_rsp_ready||!raw_q_rsp_valid||q_rsp_addr!=0)$fatal(1,"Q_HELD_REAL");end
   if(!type_response_gate)begin type_hold_cycles<=type_hold_cycles+1;if(raw_type_ready||!raw_type_valid||raw_type_addr!=32)$fatal(1,"TYPE_HELD_REAL");end
   if(run_provider&&op_arg==1)begin
    if(h_rd_valid||bank_h_rd_valid||h_rsp_ready)$fatal(1,"TYPE_EXTRA_H_READ");
    if((q_rd_valid&&q_rd_ready)!=(type_rd_valid&&type_rd_ready))$fatal(1,"TYPE_ATOMIC_READ");
    if((q_rsp_valid&&q_rsp_ready)!=(type_rsp_valid&&type_rsp_ready))$fatal(1,"TYPE_ATOMIC_RESPONSE");
    if(type_rsp_valid&&q_rsp_valid&&type_rsp_addr!=q_rsp_addr&&add_req_valid[0])$fatal(1,"BAD_PAIR_FP_ACCEPT");
   end
   if(mode==3&&h_wr_valid&&h_wr_addr==4095&&!write_gate)begin if(h_wr_ready||raw_h_commit||done_valid||control_retired||fp_release_valid||!fp_lease_active||!add_rsp_valid[0]||add_rsp_ready[0])$fatal(1,"LAST_H_REAL_DEBT_BARRIER");end
   if(fp_protocol_fault)$fatal(1,"FP_PROTOCOL");
   if(fp_lease_valid&&fp_lease_ready)begin lease_count++;if(fp_lease_phase!=7||fp_lease_head!=0)$fatal(1,"PHASE7_LEASE");end
   if(fp_release_valid&&fp_release_ready)release_count++;
   if(start_valid&&start_ready)start_cycle=cycles;
   if(done_valid&&done_cycle<0)done_cycle=cycles;
   if(run_provider)begin
    if(op_arg==0&&(h_rd_valid&&h_rd_ready)!=(q_rd_valid&&q_rd_ready))$fatal(1,"ATOMIC_JOIN_ACCEPT");
    if((h_rd_valid&&h_rd_ready)!=(bank_h_rd_valid&&raw_h_rd_ready)||(q_rd_valid&&q_rd_ready)!=(bank_q_rd_valid&&raw_q_rd_ready))$fatal(1,"BRIDGE_READ_MISMATCH");
    if((h_wr_valid&&h_wr_ready)!=raw_h_commit)$fatal(1,"BRIDGE_WRITE_MISMATCH");
    if(add_req_valid[6:1]||mul_pending||mul_rsp_valid)$fatal(1,"EXTRA_ARITHMETIC");
    if(add_req_valid[0])begin
     if(!q_rsp_valid||(op_arg==0?(!h_rsp_valid||h_rsp_addr!=q_rsp_addr||add_a[31:0]!==h_rsp_data||add_b[31:0]!==q_rsp_data):(!type_rsp_valid||type_rsp_addr!=q_rsp_addr||add_a[31:0]!==q_rsp_data||add_b[31:0]!==type_rsp_data))||add_a[255:32]!==0||add_b[255:32]!==0)$fatal(1,"ADD_OPERANDS");
    end
    if(raw_h_commit)begin
     if(first_commit<0)first_commit=cycles;
     for(int l=0;l<32;l++)if(bank_h_wr_data[l]!==GOLD[int'(bank_h_wr_addr)*32+l])$fatal(1,"RESIDUAL_VALUE addr=%0d lane=%0d got=%h expected=%h",bank_h_wr_addr,l,bank_h_wr_data[l],GOLD[int'(bank_h_wr_addr)*32+l]);
     commits++;checked+=32;
     if(commits%128==0||mode>=4)begin $fdisplay(progress_fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",checked,checked,cycles,commits);$fflush(progress_fd);end
    end
   end
  end
 end
endmodule
