`timescale 1ns/1ps

// This gate observes both ends of the same physical FIFO pair.  Admission
// remains closed after the complete request until the final completion beat
// is consumed.  The notification persists across multi-cycle HLS scheduling
// and is cleared only by the first actual read of the following request.
module laya_control_consumption_gate_v1 #(
  parameter integer REQUEST_BEATS = 8,
  parameter integer COMPLETION_BEATS = 4
) (
  input  logic clk, rst,
  input  logic request_empty_n,
  input  logic request_consumer_read,
  output logic gated_request_empty_n,
  output logic gated_request_read,
  input  logic completion_consumer_empty_n,
  input  logic completion_consumer_read,
  output logic completion_consumed_pending
);
  localparam integer REQUEST_COUNT_BITS = $clog2(REQUEST_BEATS + 1);
  localparam integer COMPLETION_COUNT_BITS = $clog2(COMPLETION_BEATS + 1);
  logic [REQUEST_COUNT_BITS-1:0] request_count;
  logic [COMPLETION_COUNT_BITS-1:0] completion_count;
  logic awaiting_completion;
  wire request_pop = gated_request_read && request_empty_n;
  wire completion_pop = completion_consumer_read &&
                        completion_consumer_empty_n;

  assign gated_request_empty_n = !rst && !awaiting_completion &&
                                 request_empty_n;
  assign gated_request_read = !rst && !awaiting_completion &&
                              request_consumer_read;

  always_ff @(posedge clk) begin
    if (rst) begin
      request_count <= '0;
      completion_count <= '0;
      awaiting_completion <= 1'b0;
      completion_consumed_pending <= 1'b0;
    end else if (!awaiting_completion) begin
      if (request_pop) begin
        if (request_count == 0)
          completion_consumed_pending <= 1'b0;
        if (request_count == REQUEST_BEATS - 1) begin
          request_count <= '0;
          completion_count <= '0;
          awaiting_completion <= 1'b1;
        end else begin
          request_count <= request_count + 1'b1;
        end
      end
    end else if (completion_pop) begin
      if (completion_count == COMPLETION_BEATS - 1) begin
        completion_count <= '0;
        completion_consumed_pending <= 1'b1;
        awaiting_completion <= 1'b0;
      end else begin
        completion_count <= completion_count + 1'b1;
      end
    end
  end
endmodule
