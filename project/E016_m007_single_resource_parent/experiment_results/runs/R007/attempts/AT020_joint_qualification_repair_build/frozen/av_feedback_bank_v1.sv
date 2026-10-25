`timescale 1ns/1ps

// One real FMUL/FADD AV projection. Numeric identity and BufferRefs live in
// the bound-address table; every short pipeline tag is checked against it.
// The 16xF32 partial array has synchronous 1R1W behavior, no data reset and
// no same-address write-through. Physical RAM mapping remains to be measured.
module av_feedback_bank_v1 (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         config_valid,
  output logic         config_ready,
  input  logic [15:0]  config_active_mask,
  input  logic         bind_valid,
  output logic         bind_ready,
  input  logic [3:0]   bind_addr,
  input  logic [7:0]   bind_slot,
  input  logic [31:0]  bind_slot_epoch,
  input  logic [31:0]  bind_task_id,
  input  logic [15:0]  bind_row,
  input  logic [671:0] bind_identity,
  input  logic [639:0] bind_refs,
  input  logic         start_valid,
  output logic         start_ready,
  input  logic         issue_valid,
  output logic         issue_ready,
  input  logic [7:0]   issue_slot,
  input  logic [31:0]  issue_slot_epoch,
  input  logic [31:0]  issue_task_id,
  input  logic [15:0]  issue_row,
  input  logic [15:0]  issue_key,
  input  logic [7:0]   issue_lane,
  input  logic [31:0]  issue_prob,
  input  logic [31:0]  issue_v,
  output logic         diagnostic_valid,
  input  logic         diagnostic_ready,
  output logic [115:0] diagnostic_tag,
  output logic [671:0] diagnostic_identity,
  output logic [639:0] diagnostic_refs,
  output logic [31:0]  diagnostic_product,
  output logic [31:0]  diagnostic_old_partial,
  output logic [31:0]  diagnostic_next_partial,
  output logic         mul_accept_event,
  output logic         mul_return_event,
  output logic         partial_read_accept_event,
  output logic         partial_read_return_event,
  output logic [3:0]   partial_read_addr_event,
  output logic         add_accept_event,
  output logic         add_return_event,
  output logic         partial_write_commit_event,
  output logic [3:0]   partial_write_addr_event,
  output logic         diagnostic_retire_event,
  output logic [5:0]   product_occupied,
  output logic [5:0]   commit_occupied,
  output logic [15:0]  busy_mask,
  output logic [15:0]  initialized_mask,
  output logic         done_valid,
  output logic         done_error,
  output logic         protocol_failure,
  output logic [12:0]  accepted_count
);
  typedef enum logic [2:0] {IDLE, BIND, RUN, DRAIN, FINISHED} state_t;
  typedef struct packed {
    logic [7:0] slot;
    logic [31:0] epoch;
    logic [31:0] task_id;
    logic [15:0] row;
    logic [15:0] key;
    logic [7:0] lane;
    logic [3:0] addr;
  } tag_t;
  state_t state;
  logic [15:0] active_mask, bound_mask;
  logic [12:0] expected_count;
  logic [671:0] table_identity [0:15];
  logic [639:0] table_refs [0:15];
  logic [7:0] table_slot [0:15];
  logic [31:0] table_epoch [0:15], table_task [0:15];
  logic [15:0] table_row [0:15], next_key [0:15];
  (* ram_style = "block" *) logic [31:0] partial [0:15];
  logic [31:0] partial_read_data;
  tag_t product_tag [0:31], commit_tag [0:31];
  logic [31:0] product_data [0:31];
  logic product_returned [0:31];
  logic [31:0] commit_product [0:31], commit_old [0:31];
  logic [31:0] commit_next [0:31];
  logic commit_returned [0:31];
  logic [4:0] product_issue_ptr, product_return_ptr, product_read_ptr;
  logic [4:0] commit_issue_ptr, commit_return_ptr, commit_retire_ptr;
  logic [5:0] mul_pending, add_pending;
  logic read_valid;
  logic [4:0] read_commit_slot;
  logic [31:0] read_product;
  logic [3:0] read_addr;
  logic [3:0] issue_addr;
  logic structural_valid, issue_fire, reject_fire, read_fire;
  logic bind_fire, config_fire, start_fire, diag_fire;
  logic mul_result_valid, add_result_valid;
  logic [31:0] mul_result_data, add_result_data;
  logic no_debt, all_complete;
  tag_t incoming_tag;

  function automatic logic finite_f32(input logic [31:0] bits);
    return bits[30:23] != 8'hff;
  endfunction
  function automatic logic [4:0] population(input logic [15:0] mask);
    logic [4:0] count;
    count=0;
    for (int i=0;i<16;i++) count+=mask[i];
    return count;
  endfunction

  assign issue_addr = {issue_slot[1:0],issue_row[3:2]};
  assign incoming_tag = {issue_slot,issue_slot_epoch,issue_task_id,
                         issue_row,issue_key,issue_lane,issue_addr};
  always_comb begin
    structural_valid = issue_slot < 4 && issue_lane == 0 &&
        issue_row[1:0] == 0 && issue_key < 128 &&
        active_mask[issue_addr] && bound_mask[issue_addr] &&
        table_slot[issue_addr] == issue_slot &&
        table_epoch[issue_addr] == issue_slot_epoch &&
        table_task[issue_addr] == issue_task_id &&
        table_row[issue_addr] == issue_row &&
        next_key[issue_addr] == issue_key &&
        finite_f32(issue_prob) && finite_f32(issue_v);
    no_debt = product_occupied == 0 && commit_occupied == 0 &&
        mul_pending == 0 && add_pending == 0 && !read_valid &&
        busy_mask == 0;
    all_complete = 1;
    for (int a=0;a<16;a++)
      if (active_mask[a] && next_key[a] != 16'd128) all_complete = 0;
  end
  assign config_ready = (state == IDLE || state == FINISHED) && no_debt;
  assign config_fire = config_valid && config_ready;
  assign bind_ready = state == BIND && active_mask[bind_addr] &&
      !bound_mask[bind_addr] && bind_slot < 4 && bind_row[1:0] == 0 &&
      bind_addr == {bind_slot[1:0],bind_row[3:2]};
  assign bind_fire = bind_valid && bind_ready;
  assign start_ready = state == BIND && bound_mask == active_mask &&
      active_mask != 0;
  assign start_fire = start_valid && start_ready;
  assign issue_ready = state == RUN &&
      (!structural_valid || (accepted_count < expected_count &&
       product_occupied < 32 && mul_pending < 32));
  assign issue_fire = issue_valid && issue_ready && structural_valid;
  assign reject_fire = issue_valid && issue_ready && !structural_valid;
  assign read_fire = state != IDLE && state != BIND &&
      product_occupied != 0 && product_returned[product_read_ptr] &&
      commit_occupied < 32 && !busy_mask[product_tag[product_read_ptr].addr];
  assign diagnostic_valid = commit_occupied != 0 &&
      commit_returned[commit_retire_ptr];
  assign diag_fire = diagnostic_valid && diagnostic_ready;
  assign diagnostic_tag = commit_tag[commit_retire_ptr];
  assign diagnostic_identity = table_identity[commit_tag[commit_retire_ptr].addr];
  assign diagnostic_refs = table_refs[commit_tag[commit_retire_ptr].addr];
  assign diagnostic_product = commit_product[commit_retire_ptr];
  assign diagnostic_old_partial = commit_old[commit_retire_ptr];
  assign diagnostic_next_partial = commit_next[commit_retire_ptr];
  assign mul_accept_event = issue_fire;
  assign mul_return_event = mul_result_valid;
  assign partial_read_accept_event = read_fire;
  assign partial_read_return_event = read_valid;
  assign partial_read_addr_event = read_fire ?
      product_tag[product_read_ptr].addr : read_addr;
  assign add_accept_event = read_valid;
  assign add_return_event = add_result_valid;
  assign partial_write_commit_event = add_result_valid && add_pending != 0;
  assign partial_write_addr_event = commit_tag[commit_return_ptr].addr;
  assign diagnostic_retire_event = diag_fire;
  assign done_valid = state == FINISHED;

  tm1tn8_fmul_ip mul_ip (
    .aclk(clk), .aresetn(rst_n),
    .s_axis_a_tvalid(issue_fire), .s_axis_a_tdata(issue_prob),
    .s_axis_b_tvalid(issue_fire), .s_axis_b_tdata(issue_v),
    .m_axis_result_tvalid(mul_result_valid),
    .m_axis_result_tdata(mul_result_data));
  tm1tn8_fadd_ip add_ip (
    .aclk(clk), .aclken(1'b1), .aresetn(rst_n),
    .s_axis_a_tvalid(read_valid), .s_axis_a_tdata(partial_read_data),
    .s_axis_b_tvalid(read_valid), .s_axis_b_tdata(read_product),
    .m_axis_result_tvalid(add_result_valid),
    .m_axis_result_tdata(add_result_data));

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      active_mask <= 0;
      bound_mask <= 0;
      initialized_mask <= 0;
      expected_count <= 0;
      accepted_count <= 0;
      product_occupied <= 0;
      commit_occupied <= 0;
      mul_pending <= 0;
      add_pending <= 0;
      product_issue_ptr <= 0;
      product_return_ptr <= 0;
      product_read_ptr <= 0;
      commit_issue_ptr <= 0;
      commit_return_ptr <= 0;
      commit_retire_ptr <= 0;
      busy_mask <= 0;
      read_valid <= 0;
      done_error <= 0;
      protocol_failure <= 0;
      for (int a=0;a<16;a++) next_key[a] <= 0;
      for (int s=0;s<32;s++) begin
        product_returned[s] <= 0;
        commit_returned[s] <= 0;
      end
    end else begin
      read_valid <= read_fire;
      if (config_fire) begin
        active_mask <= config_active_mask;
        bound_mask <= 0;
        initialized_mask <= 0;
        expected_count <= {population(config_active_mask),7'd0};
        accepted_count <= 0;
        done_error <= 0;
        protocol_failure <= 0;
        state <= BIND;
        for (int a=0;a<16;a++) next_key[a] <= 0;
      end
      if (bind_fire) begin
        table_identity[bind_addr] <= bind_identity;
        table_refs[bind_addr] <= bind_refs;
        table_slot[bind_addr] <= bind_slot;
        table_epoch[bind_addr] <= bind_slot_epoch;
        table_task[bind_addr] <= bind_task_id;
        table_row[bind_addr] <= bind_row;
        partial[bind_addr] <= 0;
        bound_mask[bind_addr] <= 1;
        initialized_mask[bind_addr] <= 1;
      end
      if (start_fire) state <= RUN;
      if (issue_fire) begin
        product_tag[product_issue_ptr] <= incoming_tag;
        product_returned[product_issue_ptr] <= 0;
        product_issue_ptr <= product_issue_ptr + 5'd1;
        next_key[issue_addr] <= next_key[issue_addr] + 16'd1;
        accepted_count <= accepted_count + 13'd1;
      end
      if (reject_fire) begin
        protocol_failure <= 1;
        done_error <= 1;
        state <= DRAIN;
      end
      if (mul_result_valid) begin
        if (mul_pending == 0 ||
            product_returned[product_return_ptr] ||
            !finite_f32(mul_result_data)) begin
          protocol_failure <= 1;
          done_error <= 1;
          state <= DRAIN;
        end else begin
          product_data[product_return_ptr] <= mul_result_data;
          product_returned[product_return_ptr] <= 1;
          product_return_ptr <= product_return_ptr + 5'd1;
        end
      end
      if (read_fire) begin
        partial_read_data <= partial[product_tag[product_read_ptr].addr];
        read_addr <= product_tag[product_read_ptr].addr;
        read_product <= product_data[product_read_ptr];
        read_commit_slot <= commit_issue_ptr;
        commit_tag[commit_issue_ptr] <= product_tag[product_read_ptr];
        commit_product[commit_issue_ptr] <= product_data[product_read_ptr];
        commit_returned[commit_issue_ptr] <= 0;
        busy_mask[product_tag[product_read_ptr].addr] <= 1;
        product_returned[product_read_ptr] <= 0;
        product_read_ptr <= product_read_ptr + 5'd1;
        commit_issue_ptr <= commit_issue_ptr + 5'd1;
      end
      if (read_valid) commit_old[read_commit_slot] <= partial_read_data;
      if (add_result_valid) begin
        if (add_pending == 0 || commit_returned[commit_return_ptr] ||
            !finite_f32(add_result_data) ||
            table_slot[commit_tag[commit_return_ptr].addr] !=
                commit_tag[commit_return_ptr].slot ||
            table_epoch[commit_tag[commit_return_ptr].addr] !=
                commit_tag[commit_return_ptr].epoch ||
            table_task[commit_tag[commit_return_ptr].addr] !=
                commit_tag[commit_return_ptr].task_id ||
            table_row[commit_tag[commit_return_ptr].addr] !=
                commit_tag[commit_return_ptr].row) begin
          protocol_failure <= 1;
          done_error <= 1;
          state <= DRAIN;
        end else begin
          partial[commit_tag[commit_return_ptr].addr] <= add_result_data;
          busy_mask[commit_tag[commit_return_ptr].addr] <= 0;
          commit_next[commit_return_ptr] <= add_result_data;
          commit_returned[commit_return_ptr] <= 1;
          commit_return_ptr <= commit_return_ptr + 5'd1;
        end
      end
      if (diag_fire) begin
        commit_returned[commit_retire_ptr] <= 0;
        commit_retire_ptr <= commit_retire_ptr + 5'd1;
      end
      product_occupied <= product_occupied +
          (issue_fire ? 6'd1 : 6'd0) - (read_fire ? 6'd1 : 6'd0);
      commit_occupied <= commit_occupied +
          (read_fire ? 6'd1 : 6'd0) - (diag_fire ? 6'd1 : 6'd0);
      mul_pending <= mul_pending +
          (issue_fire ? 6'd1 : 6'd0) - (mul_result_valid ? 6'd1 : 6'd0);
      add_pending <= add_pending +
          (read_valid ? 6'd1 : 6'd0) - (add_result_valid ? 6'd1 : 6'd0);
      if (state == RUN && accepted_count == expected_count) state <= DRAIN;
      if (state == DRAIN && no_debt &&
          (done_error || all_complete)) state <= FINISHED;
    end
  end
endmodule
