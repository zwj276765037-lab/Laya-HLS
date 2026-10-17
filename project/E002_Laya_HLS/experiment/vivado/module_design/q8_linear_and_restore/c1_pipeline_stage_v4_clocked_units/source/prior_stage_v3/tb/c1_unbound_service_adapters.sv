`timescale 1ns/1ps
// Deliberately unbound source-only adapters. Each probe has a full clocked
// driver/scoreboard, but execution is forbidden until a generated wrapper
// with these explicitly reviewed ports replaces the corresponding adapter.
// These modules are excluded from the live RTL shell source list.
module c1_unbound_integer_tree_adapter (
  input logic clk, rst_n, req_valid,
  output logic req_ready,
  input logic [16:0] req_seq,
  input logic [1023:0] req_a_rows,
  input logic [2047:0] req_w_columns,
  output logic ret_valid,
  output logic [16:0] ret_seq,
  output logic [671:0] ret_dot21
);
  initial $fatal(1,"UNBOUND_C1_INTEGER_TREE_WRAPPER");
endmodule

module c1_unbound_bank_adapter (
  input logic clk, rst_n, load_valid,
  input logic [2:0] load_kind,
  input logic [5:0] load_bank,
  input logic [14:0] load_address,
  input logic [255:0] load_data,
  input logic req_valid,
  output logic req_ready,
  input logic [16:0] req_seq,
  input logic [6:0] req_g,
  input logic [31:0] req_shape_mask,
  input logic [14:0] req_w_address,
  input logic [8:0] req_a_address,
  input logic [9:0] req_ps_address,
  input logic req_ps_read_enable,
  output logic ret_valid,
  output logic [16:0] ret_seq,
  output logic [31:0] ret_bad_mask,
  output logic [1023:0] ret_a_rows,
  output logic [2047:0] ret_w_columns,
  output logic [63:0] ret_sa_half,
  output logic [127:0] ret_sw_half,
  output logic [1023:0] ret_old_ps
);
  initial $fatal(1,"UNBOUND_C1_BANK_REQUEST_RETURN_WRAPPER");
endmodule

module c1_unbound_selected_route_adapter (
  input logic clk, rst_n, req_valid,
  output logic req_ready,
  input logic [16:0] req_seq,
  input logic [2:0] req_route,
  input logic [31:0] req_normal_bits, req_bypass_bits,
  output logic ret_valid,
  output logic [16:0] ret_seq,
  output logic [31:0] ret_selected_bits
);
  initial $fatal(1,"UNBOUND_C1_SELECTED_ROUTE_WRAPPER");
endmodule

module c1_unbound_writer_bridge (
  input logic clk, rst_n,
  input logic trace_send_valid,
  output logic trace_send_ready,
  input logic [1:0] trace_send_slot,
  input logic [16:0] trace_send_seq,
  input logic [255:0] trace_send_payload,
  output logic [31:0] trace_command_seq,
  output logic trace_ack_valid,
  output logic [2:0] trace_ack_kind,
  output logic [1:0] trace_ack_slot,
  output logic [31:0] trace_ack_seq,
  output logic [617:0] observed_command,
  input logic observed_command_ready,
  input logic [36:0] observed_ack,
  input logic observed_ack_valid
);
  initial $fatal(1,"UNBOUND_C1_WRITER_COMMAND_ACK_BRIDGE");
endmodule
