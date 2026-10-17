`timescale 1ns/1ps

// Transaction-boundary interlock around the generated command/provenance
// adapter.  A successful write of the last completion word only places that
// word in the depth-2 FIFO; it does not mean that the sequencer consumed it.
// Hold the next request at the request FIFO output until the real consumer
// handshake retires all sixteen completion words.
module laya_controller_transaction_adapter_shell_v1 (
  input  logic         ap_clk,
  input  logic         ap_rst,
  input  logic         cancel,

  input  logic [511:0] transaction_request_dout,
  input  logic         transaction_request_empty_n,
  output logic         transaction_request_read,
  output logic [511:0] transaction_completion_din,
  input  logic         transaction_completion_full_n,
  output logic         transaction_completion_write,
  input  logic         transaction_completion_consumer_read,
  input  logic         transaction_completion_consumer_empty_n,

  output logic [511:0] compute_command_din,
  input  logic         compute_command_full_n,
  output logic         compute_command_write,
  input  logic [511:0] compute_response_dout,
  input  logic         compute_response_empty_n,
  output logic         compute_response_read,

  output logic [511:0] provenance_command_din,
  input  logic         provenance_command_full_n,
  output logic         provenance_command_write,
  input  logic [511:0] provenance_response_dout,
  input  logic         provenance_response_empty_n,
  output logic         provenance_response_read,

  output logic [511:0] producer_request_din,
  input  logic         producer_request_full_n,
  output logic         producer_request_write,
  input  logic [511:0] producer_completion_dout,
  input  logic         producer_completion_empty_n,
  output logic         producer_completion_read
);
  logic adapter_request_empty_n;
  logic adapter_request_read;
  logic awaiting_completion_consumption;
  logic [4:0] request_beats_consumed;
  logic [4:0] completion_beats_consumed;

  wire request_pop = transaction_request_read &&
                     transaction_request_empty_n;
  wire completion_pop = transaction_completion_consumer_read &&
                        transaction_completion_consumer_empty_n;

  assign adapter_request_empty_n = transaction_request_empty_n &&
                                   !awaiting_completion_consumption &&
                                   !ap_rst;
  assign transaction_request_read = adapter_request_read &&
                                    !awaiting_completion_consumption &&
                                    !ap_rst;

  always_ff @(posedge ap_clk) begin
    if (ap_rst) begin
      awaiting_completion_consumption <= 1'b0;
      request_beats_consumed <= 5'd0;
      completion_beats_consumed <= 5'd0;
    end else if (!awaiting_completion_consumption) begin
      if (request_pop) begin
        if (request_beats_consumed == 5'd23) begin
          request_beats_consumed <= 5'd0;
          completion_beats_consumed <= 5'd0;
          awaiting_completion_consumption <= 1'b1;
        end else begin
          request_beats_consumed <= request_beats_consumed + 1'b1;
        end
      end
    end else if (completion_pop) begin
      if (completion_beats_consumed == 5'd15) begin
        completion_beats_consumed <= 5'd0;
        awaiting_completion_consumption <= 1'b0;
      end else begin
        completion_beats_consumed <= completion_beats_consumed + 1'b1;
      end
    end
  end

  laya_command_provenance_adapter adapter (
    .ap_clk,
    .ap_rst,
    .cancel,
    .transaction_request_dout,
    .transaction_request_empty_n(adapter_request_empty_n),
    .transaction_request_read(adapter_request_read),
    .transaction_completion_din,
    .transaction_completion_full_n,
    .transaction_completion_write,
    .compute_command_din,
    .compute_command_full_n,
    .compute_command_write,
    .compute_response_dout,
    .compute_response_empty_n,
    .compute_response_read,
    .provenance_command_din,
    .provenance_command_full_n,
    .provenance_command_write,
    .provenance_response_dout,
    .provenance_response_empty_n,
    .provenance_response_read,
    .producer_request_din,
    .producer_request_full_n,
    .producer_request_write,
    .producer_completion_dout,
    .producer_completion_empty_n,
    .producer_completion_read
  );
endmodule
