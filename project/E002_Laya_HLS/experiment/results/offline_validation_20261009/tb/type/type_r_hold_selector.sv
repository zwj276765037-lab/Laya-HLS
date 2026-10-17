`timescale 1ns/1ps
// Endpoint AR/R shadow for the Type testbench's address-and-ordinal R hold.
// The independent AXI monitor remains responsible for protocol accounting.
module type_r_hold_selector #(
    parameter logic [63:0] TYPE_ROW_END = 64'h0
) (
    input logic clk, resetn,
    input logic [31:0] selected_r_ordinal,
    input logic arvalid, arready,
    input logic [63:0] araddr,
    input logic [7:0] arlen,
    input logic [2:0] arsize,
    input logic rvalid, rready, rlast,
    output logic hold_final_r,
    output logic row_pending_stable,
    output logic [63:0] row_beat_addr_stable
);
  localparam int Q=16;
  logic [63:0] address [0:Q-1];
  logic [7:0] length [0:Q-1], beat [0:Q-1];
  logic [2:0] size [0:Q-1];
  integer head=0, tail=0, used=0;
  logic [31:0] accepted_r_count_local=0;
  logic hold_target_stable=0;

  always @(posedge clk) begin
    if (!resetn) begin
      head=0;
      tail=0;
      used=0;
      accepted_r_count_local=0;
    end else begin
      if (arvalid && arready) begin
        if (used==Q || $isunknown({araddr,arlen,arsize}))
          $fatal(1,"TYPE_COLD_AR_SHADOW_PUSH");
        address[tail]=araddr;
        length[tail]=arlen;
        size[tail]=arsize;
        beat[tail]=0;
        tail=(tail+1)%Q;
        used++;
      end
      if (rvalid && rready) begin
        if (used==0 || rlast !== (beat[head]==length[head]))
          $fatal(1,"TYPE_COLD_AR_SHADOW_POP");
        if (rlast) begin
          head=(head+1)%Q;
          used--;
        end else beat[head]++;
        accepted_r_count_local++;
      end
    end
  end

  // The R delay adapter samples hold_final_r at the next positive edge.
  always @(negedge clk) begin
    if (!resetn || used==0) begin
      row_pending_stable=0;
      row_beat_addr_stable=0;
      hold_target_stable=0;
    end else begin
      row_beat_addr_stable=address[head]+({56'd0,beat[head]} << size[head]);
      if ($isunknown(row_beat_addr_stable))
        $fatal(1,"TYPE_COLD_ROW_R_ADDRESS_UNKNOWN");
      row_pending_stable=1;
      if ($isunknown({selected_r_ordinal,accepted_r_count_local}))
        $fatal(1,"TYPE_COLD_ROW_R_ORDINAL_UNKNOWN selected=%h accepted=%h",
               selected_r_ordinal,accepted_r_count_local);
      hold_target_stable=(selected_r_ordinal>0 &&
          row_beat_addr_stable==TYPE_ROW_END-64'd4 &&
          accepted_r_count_local+32'd1==selected_r_ordinal);
    end
  end

  assign hold_final_r = resetn && selected_r_ordinal>0 &&
      rvalid && rlast && hold_target_stable;
endmodule
