// One exact binary32 ADD lane with 32 credits reserved from input acceptance
// through output consumption. The CE ADD is the existing Attention arithmetic
// leaf; it advances every clock, while valid and sequence tags follow its
// measured six-edge wrapper return timing.
module laya_vector_add_stream_v1 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        in_valid,
    output logic        in_ready,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic        out_valid,
    input  logic        out_ready,
    output logic [31:0] bits
);
  logic [31:0] leaf_a, leaf_b, leaf_bits;
  logic [5:0] valid_pipe;
  logic [31:0] tag_pipe [0:5];
  logic [31:0] result_data [0:31];
  logic [31:0] result_tag [0:31];
  logic [31:0] ready_mask;
  logic [4:0] alloc_ptr, return_ptr, consume_ptr;
  logic [5:0] occupancy;
  logic [31:0] accept_seq, return_seq, consume_seq;
  logic accept_pulse, returned_pulse, consume_pulse;

  assign in_ready = rst_n && occupancy < 6'd32;
  assign accept_pulse = in_valid && in_ready;
  assign leaf_a = accept_pulse ? a : 32'b0;
  assign leaf_b = accept_pulse ? b : 32'b0;
  assign returned_pulse = valid_pipe[5];
  assign out_valid = rst_n && (occupancy != 0) && ready_mask[consume_ptr];
  assign bits = result_data[consume_ptr];
  assign consume_pulse = out_valid && out_ready;

  attention_tile_ce_tanh_libm_stream_leaf_stream_add_node_0_s add (
    .ap_clk(clk), .ap_rst(!rst_n), .ap_ce(1'b1),
    .laya_global_ce(1'b1), .a(leaf_a), .b(leaf_b),
    .ap_return(leaf_bits)
  );

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      valid_pipe <= '0;
      for (integer k=0;k<6;k=k+1) tag_pipe[k] <= '0;
      ready_mask <= '0;
      alloc_ptr <= '0;
      return_ptr <= '0;
      consume_ptr <= '0;
      occupancy <= '0;
      accept_seq <= '0;
      return_seq <= '0;
      consume_seq <= '0;
    end else begin
      valid_pipe[0] <= accept_pulse;
      tag_pipe[0] <= accept_seq;
      for (integer k=1;k<6;k=k+1) begin
        valid_pipe[k] <= valid_pipe[k-1];
        tag_pipe[k] <= tag_pipe[k-1];
      end
      if (accept_pulse) begin
        alloc_ptr <= alloc_ptr + 1'b1;
        accept_seq <= accept_seq + 1'b1;
      end
      if (returned_pulse) begin
        result_data[return_ptr] <= leaf_bits;
        result_tag[return_ptr] <= tag_pipe[5];
        ready_mask[return_ptr] <= 1'b1;
        return_ptr <= return_ptr + 1'b1;
        return_seq <= return_seq + 1'b1;
      end
      if (consume_pulse) begin
        ready_mask[consume_ptr] <= 1'b0;
        consume_ptr <= consume_ptr + 1'b1;
        consume_seq <= consume_seq + 1'b1;
      end
      case ({accept_pulse, consume_pulse})
        2'b10: occupancy <= occupancy + 1'b1;
        2'b01: occupancy <= occupancy - 1'b1;
        default: ;
      endcase
    end
  end
endmodule
