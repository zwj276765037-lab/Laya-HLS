`timescale 1ns/1ps

module laya_graph_program_shell_v1 (
  input logic ap_clk, ap_rst, cancel,
  input logic [511:0] accepted_command_dout,
  input logic accepted_command_empty_n,
  output logic accepted_command_read,
  output logic [511:0] request_result_din,
  input logic request_result_full_n,
  output logic request_result_write,
  input logic request_result_consumer_read,
  input logic request_result_consumer_empty_n,
  output logic [511:0] action_request_din,
  input logic action_request_full_n,
  output logic action_request_write,
  input logic [511:0] action_completion_dout,
  input logic action_completion_empty_n,
  output logic action_completion_read
);
  logic program_command_empty_n, program_command_read;
  logic result_consumed;

  laya_control_consumption_gate_v1 #(
    .REQUEST_BEATS(4), .COMPLETION_BEATS(4)
  ) result_boundary (
    .clk(ap_clk), .rst(ap_rst),
    .request_empty_n(accepted_command_empty_n),
    .request_consumer_read(program_command_read),
    .gated_request_empty_n(program_command_empty_n),
    .gated_request_read(accepted_command_read),
    .completion_consumer_empty_n(request_result_consumer_empty_n),
    .completion_consumer_read(request_result_consumer_read),
    .completion_consumed_pending(result_consumed)
  );

  laya_graph_program_sequencer program_sequencer (
    .ap_clk, .ap_rst, .cancel, .result_consumed,
    .accepted_command_dout,
    .accepted_command_empty_n(program_command_empty_n),
    .accepted_command_read(program_command_read),
    .request_result_din, .request_result_full_n, .request_result_write,
    .action_request_din, .action_request_full_n, .action_request_write,
    .action_completion_dout, .action_completion_empty_n,
    .action_completion_read
  );
endmodule
