`timescale 1ns/1ps
module m007_vector23_equivalence_tb;
 logic clk=0;always #2 clk=~clk;logic rst_n=0;
 logic owner_valid=1;logic[63:0]owner_request_id=64'h219abc;logic[31:0]owner_generation=23,owner_epoch=41;
 logic[63:0]access_request_id;logic[31:0]access_generation,access_epoch;logic wrong_identity=0;
 assign access_request_id=owner_request_id;assign access_generation=owner_generation+32'(wrong_identity);assign access_epoch=owner_epoch;
 logic start_valid=0,start_ready,start_reject_valid,done_valid,done_ready=0,idle,control_retired;logic[1:0]start_op=0;
 logic[63:0]start_request_id;logic[31:0]start_generation,start_epoch;
 assign start_request_id=owner_request_id;assign start_generation=owner_generation+32'(wrong_identity);assign start_epoch=owner_epoch;
 logic scratch_active;logic loaded=0,inputs_ready;assign inputs_ready=loaded&&scratch_active;
 logic[31:0]done_status;logic[6:0]done_error_row;logic[9:0]done_error_column;logic[12:0]issued_vectors,retired_vectors;
 logic h_rd_valid,h_rd_ready,q_rd_valid,q_rd_ready,h_rsp_valid,h_rsp_ready,q_rsp_valid,q_rsp_ready,h_wr_valid,h_wr_ready,h_wr_commit;
 logic[11:0]h_rd_addr,q_rd_addr,h_rsp_addr,q_rsp_addr,h_wr_addr;logic[31:0][31:0]h_rsp_data,q_rsp_data,h_wr_data;
 logic fp_lease_valid,fp_lease_ready,fp_release_valid,fp_release_ready,fp_phase_debt_clear,fp_lease_active,fp_protocol_fault,fp_draining;
 logic[63:0]fp_lease_request_id,fp_rsp_request_id;logic[31:0]fp_lease_generation,fp_lease_epoch,fp_release_epoch,fp_rsp_generation,fp_rsp_epoch;
 logic[3:0]fp_lease_head,fp_rsp_head;logic[2:0]fp_lease_phase,fp_release_phase,fp_rsp_phase;
 logic[6:0]add_req_valid,add_req_is_root,add_req_ready,add_rsp_valid,add_rsp_ready;logic[6:0][2:0]add_req_phase;logic[6:0][31:0]add_req_epoch;logic[6:0][95:0]add_req_tag,add_rsp_tag;logic[255:0][31:0]add_a,add_b,add_rsp_data;
 laya_m007_resident_vector32_v1 provider(.*);
 logic external_enable=1;logic[47:0]external_q=0,external_next,local_next;logic local_private_idle,external_private_idle;integer compared_cycles=0,retired_guard_cycles=0;bit equivalence_active=1;
 logic  local_start_ready;
 logic  local_start_reject_valid;
 logic  local_done_valid;
 logic [31:0] local_done_status;
 logic [6:0] local_done_error_row;
 logic [9:0] local_done_error_column;
 logic  local_idle;
 logic  local_control_retired;
 logic [12:0] local_issued_vectors;
 logic [12:0] local_retired_vectors;
 logic  local_h_rd_valid;
 logic [11:0] local_h_rd_addr;
 logic  local_h_rsp_ready;
 logic  local_q_rd_valid;
 logic [11:0] local_q_rd_addr;
 logic  local_q_rsp_ready;
 logic  local_h_wr_valid;
 logic [11:0] local_h_wr_addr;
 logic [31:0][31:0] local_h_wr_data;
 logic  local_fp_lease_valid;
 logic [63:0] local_fp_lease_request_id;
 logic [31:0] local_fp_lease_generation;
 logic [31:0] local_fp_lease_epoch;
 logic [3:0] local_fp_lease_head;
 logic [2:0] local_fp_lease_phase;
 logic  local_fp_release_valid;
 logic [2:0] local_fp_release_phase;
 logic [31:0] local_fp_release_epoch;
 logic  local_fp_phase_debt_clear;
 logic [6:0] local_add_req_valid;
 logic [6:0] local_add_req_is_root;
 logic [6:0][2:0] local_add_req_phase;
 logic [6:0][31:0] local_add_req_epoch;
 logic [6:0][95:0] local_add_req_tag;
 logic [255:0][31:0] local_add_a;
 logic [255:0][31:0] local_add_b;
 logic [6:0] local_add_rsp_ready;
 laya_m007_resident_vector32_v2 #(.EXTERNAL_CONTROL(0)) local_provider(
 .external_control_enable(1'b1),
 .external_control_q(48'b0),
 .external_control_next(local_next),
 .control_private_idle(local_private_idle),
 .clk(clk),
 .rst_n(rst_n),
 .owner_valid(owner_valid),
 .inputs_ready(inputs_ready),
 .owner_request_id(owner_request_id),
 .owner_generation(owner_generation),
 .owner_epoch(owner_epoch),
 .start_valid(start_valid),
 .start_ready(local_start_ready),
 .start_op(start_op),
 .start_request_id(start_request_id),
 .start_generation(start_generation),
 .start_epoch(start_epoch),
 .start_reject_valid(local_start_reject_valid),
 .done_valid(local_done_valid),
 .done_ready(done_ready),
 .done_status(local_done_status),
 .done_error_row(local_done_error_row),
 .done_error_column(local_done_error_column),
 .idle(local_idle),
 .control_retired(local_control_retired),
 .issued_vectors(local_issued_vectors),
 .retired_vectors(local_retired_vectors),
 .h_rd_valid(local_h_rd_valid),
 .h_rd_ready(h_rd_ready),
 .h_rd_addr(local_h_rd_addr),
 .h_rsp_valid(h_rsp_valid),
 .h_rsp_ready(local_h_rsp_ready),
 .h_rsp_addr(h_rsp_addr),
 .h_rsp_data(h_rsp_data),
 .q_rd_valid(local_q_rd_valid),
 .q_rd_ready(q_rd_ready),
 .q_rd_addr(local_q_rd_addr),
 .q_rsp_valid(q_rsp_valid),
 .q_rsp_ready(local_q_rsp_ready),
 .q_rsp_addr(q_rsp_addr),
 .q_rsp_data(q_rsp_data),
 .h_wr_valid(local_h_wr_valid),
 .h_wr_ready(h_wr_ready),
 .h_wr_addr(local_h_wr_addr),
 .h_wr_data(local_h_wr_data),
 .h_wr_commit(h_wr_commit),
 .fp_lease_valid(local_fp_lease_valid),
 .fp_lease_ready(fp_lease_ready),
 .fp_lease_request_id(local_fp_lease_request_id),
 .fp_lease_generation(local_fp_lease_generation),
 .fp_lease_epoch(local_fp_lease_epoch),
 .fp_lease_head(local_fp_lease_head),
 .fp_lease_phase(local_fp_lease_phase),
 .fp_release_valid(local_fp_release_valid),
 .fp_release_ready(fp_release_ready),
 .fp_release_phase(local_fp_release_phase),
 .fp_release_epoch(local_fp_release_epoch),
 .fp_phase_debt_clear(local_fp_phase_debt_clear),
 .fp_lease_active(fp_lease_active),
 .fp_rsp_request_id(fp_rsp_request_id),
 .fp_rsp_generation(fp_rsp_generation),
 .fp_rsp_epoch(fp_rsp_epoch),
 .fp_rsp_head(fp_rsp_head),
 .fp_rsp_phase(fp_rsp_phase),
 .fp_protocol_fault(fp_protocol_fault),
 .add_req_valid(local_add_req_valid),
 .add_req_is_root(local_add_req_is_root),
 .add_req_ready(add_req_ready),
 .add_req_phase(local_add_req_phase),
 .add_req_epoch(local_add_req_epoch),
 .add_req_tag(local_add_req_tag),
 .add_a(local_add_a),
 .add_b(local_add_b),
 .add_rsp_valid(add_rsp_valid),
 .add_rsp_ready(local_add_rsp_ready),
 .add_rsp_tag(add_rsp_tag),
 .add_rsp_data(add_rsp_data)
 );
 logic  external_start_ready;
 logic  external_start_reject_valid;
 logic  external_done_valid;
 logic [31:0] external_done_status;
 logic [6:0] external_done_error_row;
 logic [9:0] external_done_error_column;
 logic  external_idle;
 logic  external_control_retired;
 logic [12:0] external_issued_vectors;
 logic [12:0] external_retired_vectors;
 logic  external_h_rd_valid;
 logic [11:0] external_h_rd_addr;
 logic  external_h_rsp_ready;
 logic  external_q_rd_valid;
 logic [11:0] external_q_rd_addr;
 logic  external_q_rsp_ready;
 logic  external_h_wr_valid;
 logic [11:0] external_h_wr_addr;
 logic [31:0][31:0] external_h_wr_data;
 logic  external_fp_lease_valid;
 logic [63:0] external_fp_lease_request_id;
 logic [31:0] external_fp_lease_generation;
 logic [31:0] external_fp_lease_epoch;
 logic [3:0] external_fp_lease_head;
 logic [2:0] external_fp_lease_phase;
 logic  external_fp_release_valid;
 logic [2:0] external_fp_release_phase;
 logic [31:0] external_fp_release_epoch;
 logic  external_fp_phase_debt_clear;
 logic [6:0] external_add_req_valid;
 logic [6:0] external_add_req_is_root;
 logic [6:0][2:0] external_add_req_phase;
 logic [6:0][31:0] external_add_req_epoch;
 logic [6:0][95:0] external_add_req_tag;
 logic [255:0][31:0] external_add_a;
 logic [255:0][31:0] external_add_b;
 logic [6:0] external_add_rsp_ready;
 laya_m007_resident_vector32_v2 #(.EXTERNAL_CONTROL(1)) external_provider(
 .external_control_enable(external_enable),
 .external_control_q(external_q),
 .external_control_next(external_next),
 .control_private_idle(external_private_idle),
 .clk(clk),
 .rst_n(rst_n),
 .owner_valid(owner_valid),
 .inputs_ready(inputs_ready),
 .owner_request_id(owner_request_id),
 .owner_generation(owner_generation),
 .owner_epoch(owner_epoch),
 .start_valid(start_valid),
 .start_ready(external_start_ready),
 .start_op(start_op),
 .start_request_id(start_request_id),
 .start_generation(start_generation),
 .start_epoch(start_epoch),
 .start_reject_valid(external_start_reject_valid),
 .done_valid(external_done_valid),
 .done_ready(done_ready),
 .done_status(external_done_status),
 .done_error_row(external_done_error_row),
 .done_error_column(external_done_error_column),
 .idle(external_idle),
 .control_retired(external_control_retired),
 .issued_vectors(external_issued_vectors),
 .retired_vectors(external_retired_vectors),
 .h_rd_valid(external_h_rd_valid),
 .h_rd_ready(h_rd_ready),
 .h_rd_addr(external_h_rd_addr),
 .h_rsp_valid(h_rsp_valid),
 .h_rsp_ready(external_h_rsp_ready),
 .h_rsp_addr(h_rsp_addr),
 .h_rsp_data(h_rsp_data),
 .q_rd_valid(external_q_rd_valid),
 .q_rd_ready(q_rd_ready),
 .q_rd_addr(external_q_rd_addr),
 .q_rsp_valid(q_rsp_valid),
 .q_rsp_ready(external_q_rsp_ready),
 .q_rsp_addr(q_rsp_addr),
 .q_rsp_data(q_rsp_data),
 .h_wr_valid(external_h_wr_valid),
 .h_wr_ready(h_wr_ready),
 .h_wr_addr(external_h_wr_addr),
 .h_wr_data(external_h_wr_data),
 .h_wr_commit(h_wr_commit),
 .fp_lease_valid(external_fp_lease_valid),
 .fp_lease_ready(fp_lease_ready),
 .fp_lease_request_id(external_fp_lease_request_id),
 .fp_lease_generation(external_fp_lease_generation),
 .fp_lease_epoch(external_fp_lease_epoch),
 .fp_lease_head(external_fp_lease_head),
 .fp_lease_phase(external_fp_lease_phase),
 .fp_release_valid(external_fp_release_valid),
 .fp_release_ready(fp_release_ready),
 .fp_release_phase(external_fp_release_phase),
 .fp_release_epoch(external_fp_release_epoch),
 .fp_phase_debt_clear(external_fp_phase_debt_clear),
 .fp_lease_active(fp_lease_active),
 .fp_rsp_request_id(fp_rsp_request_id),
 .fp_rsp_generation(fp_rsp_generation),
 .fp_rsp_epoch(fp_rsp_epoch),
 .fp_rsp_head(fp_rsp_head),
 .fp_rsp_phase(fp_rsp_phase),
 .fp_protocol_fault(fp_protocol_fault),
 .add_req_valid(external_add_req_valid),
 .add_req_is_root(external_add_req_is_root),
 .add_req_ready(add_req_ready),
 .add_req_phase(external_add_req_phase),
 .add_req_epoch(external_add_req_epoch),
 .add_req_tag(external_add_req_tag),
 .add_a(external_add_a),
 .add_b(external_add_b),
 .add_rsp_valid(add_rsp_valid),
 .add_rsp_ready(external_add_rsp_ready),
 .add_rsp_tag(add_rsp_tag),
 .add_rsp_data(add_rsp_data)
 );
 always@(posedge clk)begin if(!rst_n)external_q<=0;else if(external_enable)external_q<=external_next;end
 always@(posedge clk)begin if(rst_n&&equivalence_active)begin
  if(start_ready!==local_start_ready||start_ready!==external_start_ready)$fatal(1,"VECTOR_EQ_start_ready");
  if(start_reject_valid!==local_start_reject_valid||start_reject_valid!==external_start_reject_valid)$fatal(1,"VECTOR_EQ_start_reject_valid");
  if(done_valid!==local_done_valid||done_valid!==external_done_valid)$fatal(1,"VECTOR_EQ_done_valid");
  if(done_status!==local_done_status||done_status!==external_done_status)$fatal(1,"VECTOR_EQ_done_status");
  if(done_error_row!==local_done_error_row||done_error_row!==external_done_error_row)$fatal(1,"VECTOR_EQ_done_error_row");
  if(done_error_column!==local_done_error_column||done_error_column!==external_done_error_column)$fatal(1,"VECTOR_EQ_done_error_column");
  if(idle!==local_idle||idle!==external_idle)$fatal(1,"VECTOR_EQ_idle");
  if(local_control_retired!==(control_retired&&!(start_valid&&start_ready))||local_control_retired!==external_control_retired)$fatal(1,"VECTOR_QUALIFIED_RETIRE_GUARD");
  if(issued_vectors!==local_issued_vectors||issued_vectors!==external_issued_vectors)$fatal(1,"VECTOR_EQ_issued_vectors");
  if(retired_vectors!==local_retired_vectors||retired_vectors!==external_retired_vectors)$fatal(1,"VECTOR_EQ_retired_vectors");
  if(h_rd_valid!==local_h_rd_valid||h_rd_valid!==external_h_rd_valid)$fatal(1,"VECTOR_EQ_h_rd_valid");
  if(h_rd_addr!==local_h_rd_addr||h_rd_addr!==external_h_rd_addr)$fatal(1,"VECTOR_EQ_h_rd_addr");
  if(h_rsp_ready!==local_h_rsp_ready||h_rsp_ready!==external_h_rsp_ready)$fatal(1,"VECTOR_EQ_h_rsp_ready");
  if(q_rd_valid!==local_q_rd_valid||q_rd_valid!==external_q_rd_valid)$fatal(1,"VECTOR_EQ_q_rd_valid");
  if(q_rd_addr!==local_q_rd_addr||q_rd_addr!==external_q_rd_addr)$fatal(1,"VECTOR_EQ_q_rd_addr");
  if(q_rsp_ready!==local_q_rsp_ready||q_rsp_ready!==external_q_rsp_ready)$fatal(1,"VECTOR_EQ_q_rsp_ready");
  if(h_wr_valid!==local_h_wr_valid||h_wr_valid!==external_h_wr_valid)$fatal(1,"VECTOR_EQ_h_wr_valid");
  if(h_wr_addr!==local_h_wr_addr||h_wr_addr!==external_h_wr_addr)$fatal(1,"VECTOR_EQ_h_wr_addr");
  if(h_wr_data!==local_h_wr_data||h_wr_data!==external_h_wr_data)$fatal(1,"VECTOR_EQ_h_wr_data");
  if(fp_lease_valid!==local_fp_lease_valid||fp_lease_valid!==external_fp_lease_valid)$fatal(1,"VECTOR_EQ_fp_lease_valid");
  if(fp_lease_request_id!==local_fp_lease_request_id||fp_lease_request_id!==external_fp_lease_request_id)$fatal(1,"VECTOR_EQ_fp_lease_request_id");
  if(fp_lease_generation!==local_fp_lease_generation||fp_lease_generation!==external_fp_lease_generation)$fatal(1,"VECTOR_EQ_fp_lease_generation");
  if(fp_lease_epoch!==local_fp_lease_epoch||fp_lease_epoch!==external_fp_lease_epoch)$fatal(1,"VECTOR_EQ_fp_lease_epoch");
  if(fp_lease_head!==local_fp_lease_head||fp_lease_head!==external_fp_lease_head)$fatal(1,"VECTOR_EQ_fp_lease_head");
  if(fp_lease_phase!==local_fp_lease_phase||fp_lease_phase!==external_fp_lease_phase)$fatal(1,"VECTOR_EQ_fp_lease_phase");
  if(fp_release_valid!==local_fp_release_valid||fp_release_valid!==external_fp_release_valid)$fatal(1,"VECTOR_EQ_fp_release_valid");
  if(fp_release_phase!==local_fp_release_phase||fp_release_phase!==external_fp_release_phase)$fatal(1,"VECTOR_EQ_fp_release_phase");
  if(fp_release_epoch!==local_fp_release_epoch||fp_release_epoch!==external_fp_release_epoch)$fatal(1,"VECTOR_EQ_fp_release_epoch");
  if(fp_phase_debt_clear!==local_fp_phase_debt_clear||fp_phase_debt_clear!==external_fp_phase_debt_clear)$fatal(1,"VECTOR_EQ_fp_phase_debt_clear");
  if(add_req_valid!==local_add_req_valid||add_req_valid!==external_add_req_valid)$fatal(1,"VECTOR_EQ_add_req_valid");
  if(add_req_is_root!==local_add_req_is_root||add_req_is_root!==external_add_req_is_root)$fatal(1,"VECTOR_EQ_add_req_is_root");
  if(add_req_phase!==local_add_req_phase||add_req_phase!==external_add_req_phase)$fatal(1,"VECTOR_EQ_add_req_phase");
  if(add_req_epoch!==local_add_req_epoch||add_req_epoch!==external_add_req_epoch)$fatal(1,"VECTOR_EQ_add_req_epoch");
  if(add_req_tag!==local_add_req_tag||add_req_tag!==external_add_req_tag)$fatal(1,"VECTOR_EQ_add_req_tag");
  if(add_a!==local_add_a||add_a!==external_add_a)$fatal(1,"VECTOR_EQ_add_a");
  if(add_b!==local_add_b||add_b!==external_add_b)$fatal(1,"VECTOR_EQ_add_b");
  if(add_rsp_ready!==local_add_rsp_ready||add_rsp_ready!==external_add_rsp_ready)$fatal(1,"VECTOR_EQ_add_rsp_ready");
  if(start_valid&&start_ready&&control_retired&&!local_control_retired)retired_guard_cycles++;if(local_private_idle!==external_private_idle)$fatal(1,"VECTOR_PRIVATE_IDLE_EQ");if(local_next!==external_next)$fatal(1,"VECTOR_EQ_NEXT");compared_cycles++;end end
 task automatic inactive_foreign_q;
  if(retired_guard_cycles==0)$fatal(1,"RETIRE_GUARD_NO_ACCEPT_WITNESS");
  @(negedge clk);equivalence_active=0;external_enable=0;external_q='1;loaded=0;start_valid=1;
  repeat(3)begin step();if(external_start_ready||external_start_reject_valid||external_done_valid||external_idle||external_control_retired||external_h_rd_valid||external_q_rd_valid||external_h_wr_valid||external_fp_lease_valid||external_fp_release_valid||external_add_req_valid||external_add_rsp_ready||external_h_rsp_ready||external_q_rsp_ready||external_next!==external_q)$fatal(1,"VECTOR_INACTIVE_FOREIGN_Q");end
  $display("HARDWARE_AGENT_SIM_PASS VECTOR23_EQ compared_cycles=%0d retired_guard_cycles=%0d local_control_bits=48 external_shadow_bits=0 inactive_foreign_q=1",compared_cycles,retired_guard_cycles);
 endtask

 logic mul_req_ready,mul_rsp_valid;logic[95:0]mul_rsp_tag;logic[255:0][31:0]mul_rsp_data;logic[6:0]mul_pending;logic[6:0][6:0]add_pending;
 laya_shared_fp256_v2 fp(.clk,.rst_n,.lease_valid(fp_lease_valid),.lease_ready(fp_lease_ready),.lease_request_id(fp_lease_request_id),.lease_generation(fp_lease_generation),.lease_epoch(fp_lease_epoch),.lease_head(fp_lease_head),.lease_phase(fp_lease_phase),
 .release_valid(fp_release_valid),.release_ready(fp_release_ready),.release_phase(fp_release_phase),.release_epoch(fp_release_epoch),.phase_debt_clear(fp_phase_debt_clear),.lease_active(fp_lease_active),.draining(fp_draining),.rsp_request_id(fp_rsp_request_id),.rsp_generation(fp_rsp_generation),.rsp_epoch(fp_rsp_epoch),.rsp_head(fp_rsp_head),.rsp_phase(fp_rsp_phase),
 .mul_req_valid(1'b0),.mul_req_ready,.mul_req_phase(3'd7),.mul_req_epoch(owner_epoch),.mul_req_tag(96'b0),.mul_a(8192'b0),.mul_b(8192'b0),.mul_rsp_valid,.mul_rsp_ready(1'b1),.mul_rsp_tag,.mul_rsp_data,
 .add_req_valid,.add_req_is_root,.add_req_ready,.add_req_phase,.add_req_epoch,.add_req_tag,.add_a,.add_b,.add_rsp_valid,.add_rsp_ready,.add_rsp_tag,.add_rsp_data,.mul_pending,.add_pending,.protocol_fault(fp_protocol_fault));
 logic run_provider=0,tb_wr_valid=0,tb_rd_valid=0,tb_rsp_ready=0;
 logic[11:0]tb_addr=0,tb_wr_addr=0;logic[31:0][31:0]tb_h_data,tb_q_data;
 logic raw_h_rd_ready,raw_h_wr_ready,raw_h_commit,h_idle,h_reject,raw_q_rd_ready,raw_q_wr_ready,raw_q_commit,q_reject;
 logic[11:0]bank_h_addr,bank_q_addr,bank_h_wr_addr;logic[31:0][31:0]bank_h_wr_data;
 logic bank_h_rd_valid,bank_q_rd_valid,bank_h_wr_valid,bank_h_rsp_ready,bank_q_rsp_ready;
 integer mode,cycles=0,start_cycle=-1,first_commit=-1,done_cycle=-1,commits=0,checked=0,scan_checked=0,lease_count=0,release_count=0,held_write_cycles=0;bit hold_started=0,hold_done=0;integer final_hold_checked_cycles=0;
 wire read_gate=mode!=1||h_rd_addr<512;
 wire write_gate=!(mode==3&&h_wr_addr==4095&&h_wr_valid&&!hold_done);
 assign bank_h_rd_valid=run_provider?(h_rd_valid&&read_gate):tb_rd_valid;
 assign bank_q_rd_valid=run_provider?(q_rd_valid&&read_gate):tb_rd_valid;
 assign h_rd_ready=raw_h_rd_ready&&read_gate;assign q_rd_ready=raw_q_rd_ready&&read_gate;
 assign bank_h_addr=run_provider?h_rd_addr:tb_addr;assign bank_q_addr=run_provider?q_rd_addr:tb_addr;
 assign bank_h_wr_valid=run_provider?(h_wr_valid&&write_gate):tb_wr_valid;
 assign bank_h_wr_addr=run_provider?h_wr_addr:tb_wr_addr;assign bank_h_wr_data=run_provider?h_wr_data:tb_h_data;
 assign h_wr_ready=raw_h_wr_ready&&write_gate;assign h_wr_commit=raw_h_commit&&run_provider;
 assign bank_h_rsp_ready=run_provider?h_rsp_ready:tb_rsp_ready;assign bank_q_rsp_ready=run_provider?q_rsp_ready:tb_rsp_ready;
 laya_m007_hidden32_owner_v1 hidden(.clk,.rst_n,.owner_valid,.owner_request_id,.owner_generation,.owner_epoch,.access_request_id,.access_generation,.access_epoch,
 .wr_valid(bank_h_wr_valid),.wr_ready(raw_h_wr_ready),.wr_addr(bank_h_wr_addr),.wr_data(bank_h_wr_data),.wr_commit(raw_h_commit),.rd_valid(bank_h_rd_valid),.rd_ready(raw_h_rd_ready),.rd_addr(bank_h_addr),.rd_rsp_valid(h_rsp_valid),.rd_rsp_ready(bank_h_rsp_ready),.rd_rsp_addr(h_rsp_addr),.rd_rsp_data(h_rsp_data),.bank_idle(h_idle),.reject_valid(h_reject));
 logic scratch_lease_valid=0,scratch_lease_ready,scratch_release_valid=0,scratch_release_ready,normal_enable,scratch_retired;
 logic rope_owner_valid=0,q_wr_valid,q_wr_ready,q_wr_half,q_rd_valid_raw,q_rd_ready_raw,q_rsp_ready_raw;
 logic[1:0]q_wr_plane;logic[3:0]q_wr_head,q_rd_head;logic[6:0]q_wr_token,q_rd_token;logic[31:0]q_rd_tag;logic[31:0][31:0]q_wr_data;
 logic[2:0]qkv_rd_valid,qkv_rd_ready,qkv_rsp_valid,qkv_rsp_ready;logic[2:0][3:0]qkv_rd_head,qkv_rsp_head;logic[2:0][6:0]qkv_rd_token,qkv_rsp_token;logic[2:0][31:0]qkv_rd_tag,qkv_rsp_tag;logic[2:0][63:0][31:0]qkv_rsp_data;
 laya_m007_qscratch32_v1 scratch(.clk,.rst_n,.lease_valid(scratch_lease_valid),.lease_ready(scratch_lease_ready),.release_valid(scratch_release_valid),.release_ready(scratch_release_ready),
 .layer_retired(1'b1),.matrix_retired(1'b1),.quant_retired(1'b1),.normal_requests_present(1'b0),.rope_owner_valid,.qkv_rsp_valid,.owner_request_id,.owner_generation,.owner_epoch,.owner_active(scratch_active),.normal_enable,
 .access_request_id,.access_generation,.access_epoch,.wr_valid(tb_wr_valid&&!run_provider),.wr_ready(raw_q_wr_ready),.wr_addr(tb_wr_addr),.wr_data(tb_q_data),.wr_commit(raw_q_commit),
 .rd_valid(bank_q_rd_valid),.rd_ready(raw_q_rd_ready),.rd_addr(bank_q_addr),.rd_rsp_valid(q_rsp_valid),.rd_rsp_ready(bank_q_rsp_ready),.rd_rsp_addr(q_rsp_addr),.rd_rsp_data(q_rsp_data),.reject_valid(q_reject),.retired(scratch_retired),
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
 logic[31:0]H[0:131071],Q[0:131071],GOLD[0:131071];string hf,qf,gf,pf;integer progress_fd;
 task automatic step;@(posedge clk);#0.01;endtask
 task automatic pair_read(input integer addr,input bit check_gold);
  @(negedge clk);tb_addr=12'(addr);tb_rd_valid=1;tb_rsp_ready=0;#0.001;if(!raw_h_rd_ready||!raw_q_rd_ready)$fatal(1,"READ_NOT_READY");step();
  @(negedge clk);tb_rd_valid=0;if(!h_rsp_valid||!q_rsp_valid||h_rsp_addr!=addr||q_rsp_addr!=addr)$fatal(1,"SYNC_READ_ADDR");
  for(int l=0;l<32;l++)if(h_rsp_data[l]!== (check_gold?GOLD[addr*32+l]:H[addr*32+l])||q_rsp_data[l]!==Q[addr*32+l])$fatal(1,"BANK_SCAN addr=%0d lane=%0d",addr,l);
  scan_checked=scan_checked+32;tb_rsp_ready=1;step();@(negedge clk);tb_rsp_ready=0;
 endtask
 initial begin
  if(!$value$plusargs("MODE=%d",mode)||!$value$plusargs("H=%s",hf)||!$value$plusargs("Q=%s",qf)||!$value$plusargs("GOLD=%s",gf)||!$value$plusargs("PROGRESS_FILE=%s",pf))$fatal(1,"ARGS");
  $readmemh(hf,H);$readmemh(qf,Q);$readmemh(gf,GOLD);progress_fd=$fopen(pf,"w");if(!progress_fd)$fatal(1,"PROGRESS_OPEN");
  repeat(5)@(negedge clk);rst_n=1;
  // Actual raw QKV/RoPE ownership prevents scratch admission.
  rope_owner_valid=1;scratch_lease_valid=1;#0.01;if(scratch_lease_ready)$fatal(1,"ROPE_ADMISSION");step();@(negedge clk);rope_owner_valid=0;#0.01;if(!scratch_lease_ready)$fatal(1,"SCRATCH_NOT_READY");step();@(negedge clk);scratch_lease_valid=0;
  if(!scratch_active||normal_enable)$fatal(1,"SCRATCH_OWNERSHIP");
  wrong_identity=1;tb_wr_valid=1;tb_rd_valid=1;#0.01;if(raw_h_wr_ready||raw_h_rd_ready||raw_q_wr_ready||raw_q_rd_ready||!h_reject||!q_reject)$fatal(1,"OLD_IDENTITY_ACCEPT");step();@(negedge clk);tb_wr_valid=0;tb_rd_valid=0;wrong_identity=0;
  start_valid=1;#0.01;if(start_ready||!start_reject_valid)$fatal(1,"UNINITIALIZED_START");step();@(negedge clk);start_valid=0;
  for(int a=0;a<4096;a++)begin
   @(negedge clk);tb_wr_valid=1;tb_wr_addr=12'(a);for(int l=0;l<32;l++)begin tb_h_data[l]=(mode==4&&a==3&&l==5)?32'h7fc12345:H[a*32+l];tb_q_data[l]=Q[a*32+l];end
   #0.01;if(!raw_h_wr_ready||!raw_q_wr_ready||!raw_h_commit||!raw_q_commit)$fatal(1,"LOAD_COMMIT a=%0d",a);step();
  end
  @(negedge clk);tb_wr_valid=0;loaded=1;
  if(mode==0)begin
   // One held synchronous response; same-address read wins over write.
   tb_addr=0;tb_rd_valid=1;tb_wr_addr=0;tb_wr_valid=1;#0.01;if(raw_h_wr_ready||raw_q_wr_ready)$fatal(1,"SAME_ADDR_WRITE_ACCEPT");step();@(negedge clk);tb_rd_valid=0;tb_wr_valid=0;
   repeat(17)begin step();if(!h_rsp_valid||!q_rsp_valid||h_rsp_addr!=0||q_rsp_addr!=0||h_rsp_data[0]!==H[0]||q_rsp_data[0]!==Q[0])$fatal(1,"HELD17");end
   @(negedge clk);tb_rsp_ready=1;step();@(negedge clk);tb_rsp_ready=0;
   for(int a=0;a<4096;a++)pair_read(a,0);
   // Reset invalidates held credits, not payload. Then no-reset epoch reuse.
   @(negedge clk);tb_addr=4095;tb_rd_valid=1;step();@(negedge clk);tb_rd_valid=0;rst_n=0;step();@(negedge clk);rst_n=1;if(h_rsp_valid||q_rsp_valid)$fatal(1,"RESET_RESPONSE_VALID");
   owner_epoch=owner_epoch+1;scratch_lease_valid=1;step();@(negedge clk);scratch_lease_valid=0;pair_read(4095,0);
   $display("HARDWARE_AGENT_SIM_PASS RESIDENT21_BANK full_vectors=4096 lanes=32 scan_checked=%0d held17=17 wrong_identity_zero_accept=1 reset_invalidates_only=1",scan_checked);$fclose(progress_fd);inactive_foreign_q();$finish;
  end
  @(negedge clk);wrong_identity=1;start_valid=1;#0.01;if(start_ready||!start_reject_valid)$fatal(1,"OLD_START_IDENTITY");step();@(negedge clk);wrong_identity=0;
  run_provider=1;#0.01;if(!start_ready)$fatal(1,"START_NOT_READY");step();@(negedge clk);start_valid=0;
  if(mode==1)begin
   wait(retired_vectors==512&&issued_vectors==512&&add_pending==0&&!h_rsp_valid&&!q_rsp_valid);repeat(3)step();if(done_valid||idle||!fp_lease_active||commits!=512)$fatal(1,"PILOT_IS_PREFIX_ONLY");
   $display("HARDWARE_AGENT_SIM_PASS RESIDENT21_PREFIX vectors=512 checked=%0d start_to_last_commit=%0d first_commit=%0d no_done=1",checked,cycles-start_cycle,first_commit-start_cycle);$fclose(progress_fd);inactive_foreign_q();$finish;
  end
  wait(done_valid);@(negedge clk);
  if(mode==3&&(!hold_done||held_write_cycles!=17||final_hold_checked_cycles!=17))$fatal(1,"FINAL_WRITE_HOLD_COVERAGE");
  if(fp_lease_active||add_pending||mul_pending||h_rsp_valid||q_rsp_valid||issued_vectors!=retired_vectors||release_count!=1)$fatal(1,"DONE_REAL_DEBT");
  if(mode==4)begin if(done_status!=6||done_error_row!=0||done_error_column!=101||issued_vectors>=4096)$fatal(1,"NONFINITE_FIRST_ERROR status=%0d col=%0d",done_status,done_error_column);end
  else begin if(done_status||commits!=4096||checked!=131072||done_cycle-start_cycle>4160||first_commit-start_cycle>32)$fatal(1,"FULL_BOUND status=%0d commits=%0d cycles=%0d",done_status,commits,done_cycle-start_cycle);end
  repeat(17)begin step();if(!done_valid||start_ready||control_retired)$fatal(1,"HELD_DONE");end
  @(negedge clk);done_ready=1;step();@(negedge clk);done_ready=0;run_provider=0;if(!control_retired)$fatal(1,"POST_DONE_RETIRE");
  if(mode!=4)for(int a=0;a<4096;a++)pair_read(a,1);
  scratch_release_valid=1;#0.01;if(!scratch_release_ready)$fatal(1,"SCRATCH_RELEASE");step();@(negedge clk);scratch_release_valid=0;if(!normal_enable||!scratch_retired)$fatal(1,"SCRATCH_NOT_RETIRED");
  // Public no-reset new epoch claims the same physical banks; no hidden copy.
  owner_generation=owner_generation+1;owner_epoch=owner_epoch+1;scratch_lease_valid=1;step();@(negedge clk);scratch_lease_valid=0;
  if(mode!=4)pair_read(4095,1);
  $display("HARDWARE_AGENT_SIM_PASS RESIDENT21_FULL mode=%0d issued=%0d retired=%0d commits=%0d checked=%0d scan_checked=%0d first_commit=%0d done_cycles=%0d external_write_held=%0d done_held=17 status=%0d lease_count=%0d release_count=%0d",mode,issued_vectors,retired_vectors,commits,checked,scan_checked,first_commit-start_cycle,done_cycle-start_cycle,held_write_cycles,done_status,lease_count,release_count);$fclose(progress_fd);inactive_foreign_q();$finish;
 end
 always @(negedge clk)if(rst_n&&mode==3&&h_wr_valid&&h_wr_addr==4095&&!hold_done)begin
  hold_started=1;if(held_write_cycles==17)hold_done=1;else held_write_cycles=held_write_cycles+1;
 end
 always @(posedge clk)begin
  cycles=cycles+1;if(cycles>40000000)$fatal(1,"CYCLE_LIMIT");
  if(rst_n)begin
   if(fp_protocol_fault)$fatal(1,"FP_PROTOCOL");
   if(mode==3&&h_wr_valid&&h_wr_addr==4095&&!write_gate)begin
    final_hold_checked_cycles++;
    if(h_wr_ready||raw_h_commit||h_wr_commit||done_valid||fp_release_valid||control_retired||local_control_retired||external_control_retired||!fp_lease_active||!add_rsp_valid[0]||add_rsp_ready[0]||issued_vectors!=4096||retired_vectors!=4095)$fatal(1,"FINAL_WRITE_REAL_DEBT_BARRIER");
    for(int l=0;l<32;l++)if(h_wr_data[l]!==GOLD[4095*32+l])$fatal(1,"FINAL_WRITE_HELD_PAYLOAD");
   end
   if(fp_lease_valid&&fp_lease_ready)begin lease_count++;if(fp_lease_phase!=7||fp_lease_head!=0)$fatal(1,"PHASE7_LEASE");end
   if(fp_release_valid&&fp_release_ready)release_count++;
   if(start_valid&&start_ready)start_cycle=cycles;
   if(done_valid&&done_cycle<0)done_cycle=cycles;
   if(run_provider)begin
    if((h_rd_valid&&h_rd_ready)!=(q_rd_valid&&q_rd_ready))$fatal(1,"ATOMIC_JOIN_ACCEPT");
    if((h_rd_valid&&h_rd_ready)!=(bank_h_rd_valid&&raw_h_rd_ready)||(q_rd_valid&&q_rd_ready)!=(bank_q_rd_valid&&raw_q_rd_ready))$fatal(1,"BRIDGE_READ_MISMATCH");
    if((h_wr_valid&&h_wr_ready)!=raw_h_commit)$fatal(1,"BRIDGE_WRITE_MISMATCH");
    if(add_req_valid[6:1]||mul_pending||mul_rsp_valid)$fatal(1,"EXTRA_ARITHMETIC");
    if(add_req_valid[0])begin
     if(!h_rsp_valid||!q_rsp_valid||h_rsp_addr!=q_rsp_addr||add_a[31:0]!==h_rsp_data||add_b[31:0]!==q_rsp_data||add_a[255:32]!==0||add_b[255:32]!==0)$fatal(1,"ADD_OPERANDS");
    end
    if(raw_h_commit)begin
     if(first_commit<0)first_commit=cycles;
     for(int l=0;l<32;l++)if(bank_h_wr_data[l]!==GOLD[int'(bank_h_wr_addr)*32+l])$fatal(1,"RESIDUAL_VALUE addr=%0d lane=%0d got=%h expected=%h",bank_h_wr_addr,l,bank_h_wr_data[l],GOLD[int'(bank_h_wr_addr)*32+l]);
     commits++;checked+=32;
     if(commits%128==0||mode==4)begin $fdisplay(progress_fd,"{\"schema\":\"m007-resident-consumed-v1\",\"checked\":%0d,\"node_checks\":%0d,\"cycle\":%0d,\"phase\":1,\"returned\":%0d}",checked,checked,cycles,commits);$fflush(progress_fd);end
    end
   end
  end
 end
endmodule
