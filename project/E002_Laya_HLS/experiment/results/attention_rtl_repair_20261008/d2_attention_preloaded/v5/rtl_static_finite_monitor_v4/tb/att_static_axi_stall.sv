// One-entry, finite-delay AXI channel timing adapter.  A visible output VALID
// is never withdrawn or changed before its receiver handshake.
module att_static_axi_stall #(
    parameter int WIDTH = 32,
    parameter int SEED = 0,
    parameter int PORT = 0,
    parameter int CHANNEL = 0
) (
    input  logic             clk,
    input  logic             resetn,
    input  logic             source_valid,
    output logic             source_ready,
    input  logic [WIDTH-1:0] source_payload,
    output logic             sink_valid,
    input  logic             sink_ready,
    output logic [WIDTH-1:0] sink_payload,
    input  logic             add_final_hold,
    output logic             special_hold_applied,
    output logic [31:0]      special_wait_cycles,
    output logic [31:0]      accepted_count,
    output logic [31:0]      delivered_count
);
  logic full;
  logic [WIDTH-1:0] held_payload;
  logic [4:0] expose_delay;
  logic [1:0] next_delay;
  logic held_special;
  logic source_was_stalled, sink_was_stalled;
  logic [WIDTH-1:0] prior_source_payload, prior_sink_payload;

  assign next_delay = (accepted_count + SEED + PORT + CHANNEL) % 4;
  assign source_ready = resetn && !full;
  assign sink_valid = resetn && full && expose_delay == 0;
  assign sink_payload = held_payload;
  assign special_hold_applied = sink_valid && sink_ready && held_special;

  always_ff @(posedge clk) begin
    if (!resetn) begin
      full <= 0;
      held_payload <= '0;
      expose_delay <= 0;
      held_special <= 0;
      accepted_count <= 0;
      delivered_count <= 0;
      special_wait_cycles <= 0;
      source_was_stalled <= 0;
      sink_was_stalled <= 0;
      prior_source_payload <= '0;
      prior_sink_payload <= '0;
    end else begin
      if ($isunknown({source_valid, sink_ready, add_final_hold}))
        $fatal(1, "ATT_STALL_CONTROL_UNKNOWN port=%0d channel=%0d", PORT, CHANNEL);
      if (source_was_stalled &&
          (!source_valid || source_payload !== prior_source_payload))
        $fatal(1, "ATT_STALL_SOURCE_CHANGED port=%0d channel=%0d", PORT, CHANNEL);
      if (sink_was_stalled &&
          (!sink_valid || sink_payload !== prior_sink_payload))
        $fatal(1, "ATT_STALL_SINK_CHANGED port=%0d channel=%0d", PORT, CHANNEL);
      source_was_stalled <= source_valid && !source_ready;
      sink_was_stalled <= sink_valid && !sink_ready;
      prior_source_payload <= source_payload;
      prior_sink_payload <= sink_payload;
      if (full && expose_delay != 0)
        expose_delay <= expose_delay - 1'b1;
      if (full && held_special)
        special_wait_cycles <= special_wait_cycles + 1'b1;
      if (source_valid && source_ready) begin
        if ($isunknown(source_payload))
          $fatal(1, "ATT_STALL_PAYLOAD_UNKNOWN port=%0d channel=%0d", PORT, CHANNEL);
        full <= 1;
        held_payload <= source_payload;
        held_special <= add_final_hold;
        special_wait_cycles <= 0;
        expose_delay <= {3'b0, next_delay} + (add_final_hold ? 5'd16 : 5'd0);
        accepted_count <= accepted_count + 1'b1;
      end
      if (sink_valid && sink_ready) begin
        if (!full)
          $fatal(1, "ATT_STALL_UNOWNED_DELIVERY port=%0d channel=%0d", PORT, CHANNEL);
        full <= 0;
        delivered_count <= delivered_count + 1'b1;
      end
      if (delivered_count > accepted_count)
        $fatal(1, "ATT_STALL_COUNT_ORDER port=%0d channel=%0d", PORT, CHANNEL);
    end
  end
endmodule
