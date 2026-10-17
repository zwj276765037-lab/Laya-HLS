`timescale 1ns/1ps
// One bounded AXI-Lite master. AW and W advance independently and retain
// their payloads until each actual handshake; every response is checked.
module att_axi_lite_master #(
    parameter int ADDR_BITS = 7,
    parameter int BANK = 0
) (
    input logic clk, resetn,
    input logic cmd_valid,
    output logic cmd_ready,
    input logic cmd_write,
    input logic [ADDR_BITS-1:0] cmd_addr,
    input logic [31:0] cmd_wdata,
    output logic cmd_done,
    output logic [31:0] cmd_rdata,
    output logic awvalid,
    input logic awready,
    output logic [ADDR_BITS-1:0] awaddr,
    output logic wvalid,
    input logic wready,
    output logic [31:0] wdata,
    output logic [3:0] wstrb,
    input logic bvalid,
    output logic bready,
    input logic [1:0] bresp,
    output logic arvalid,
    input logic arready,
    output logic [ADDR_BITS-1:0] araddr,
    input logic rvalid,
    output logic rready,
    input logic [31:0] rdata,
    input logic [1:0] rresp
);
  typedef enum logic [2:0] {IDLE, SEND_WRITE, WAIT_B, SEND_READ,
                            WAIT_R, COMPLETE} state_t;
  state_t state;
  logic aw_sent, w_sent;
  logic [ADDR_BITS-1:0] held_addr;
  logic [31:0] held_data;
  logic [31:0] age;
  logic sampled_aw, sampled_w, sampled_b, sampled_ar, sampled_r;
  logic [31:0] sampled_rdata;
  assign cmd_ready = state == IDLE;
  assign cmd_done = state == COMPLETE;
  assign awvalid = resetn && state == SEND_WRITE && !aw_sent;
  assign wvalid = resetn && state == SEND_WRITE && !w_sent;
  assign bready = resetn && state == WAIT_B;
  assign arvalid = resetn && state == SEND_READ;
  assign rready = resetn && state == WAIT_R;
  assign awaddr = held_addr;
  assign araddr = held_addr;
  assign wdata = held_data;
  assign wstrb = 4'hf;

  // Capture actual wire handshakes on the positive edge. State and the
  // resulting VALID/payload outputs change only on the negative edge.
  always @(posedge clk) begin
    if (!resetn) begin
      sampled_aw <= 0;
      sampled_w <= 0;
      sampled_b <= 0;
      sampled_ar <= 0;
      sampled_r <= 0;
      sampled_rdata <= 0;
    end else begin
      if ($isunknown({cmd_valid,awready,wready,bvalid,arready,rvalid}))
        $fatal(1,"ATT_LITE_CONTROL_UNKNOWN bank=%0d",BANK);
      sampled_aw <= awvalid && awready;
      sampled_w <= wvalid && wready;
      sampled_b <= bvalid && bready;
      sampled_ar <= arvalid && arready;
      sampled_r <= rvalid && rready;
      if (bvalid && bready && bresp !== 2'b00)
        $fatal(1,"ATT_LITE_BRESP bank=%0d resp=%b",BANK,bresp);
      if (rvalid && rready) begin
        if (rresp !== 2'b00 || $isunknown(rdata))
          $fatal(1,"ATT_LITE_RRESP bank=%0d resp=%b",BANK,rresp);
        sampled_rdata <= rdata;
      end
    end
  end

  always @(negedge clk) begin
    if (!resetn) begin
      state <= IDLE;
      aw_sent <= 0;
      w_sent <= 0;
      held_addr <= '0;
      held_data <= '0;
      cmd_rdata <= '0;
      age <= 0;
    end else begin
      if (state != IDLE && state != COMPLETE) age <= age+1;
      else age <= 0;
      if (age > 32'd256)
        $fatal(1,"ATT_LITE_TIMEOUT bank=%0d",BANK);
      case (state)
        IDLE: if (cmd_valid) begin
          if ($isunknown({cmd_write,cmd_addr,cmd_wdata}))
            $fatal(1,"ATT_LITE_COMMAND_UNKNOWN bank=%0d",BANK);
          held_addr <= cmd_addr;
          held_data <= cmd_wdata;
          aw_sent <= 0;
          w_sent <= 0;
          state <= cmd_write ? SEND_WRITE : SEND_READ;
        end
        SEND_WRITE: begin
          if (sampled_aw) aw_sent <= 1;
          if (sampled_w) w_sent <= 1;
          if ((aw_sent || sampled_aw) && (w_sent || sampled_w)) state <= WAIT_B;
        end
        WAIT_B: if (sampled_b) state <= COMPLETE;
        SEND_READ: if (sampled_ar) state <= WAIT_R;
        WAIT_R: if (sampled_r) begin
          cmd_rdata <= sampled_rdata;
          state <= COMPLETE;
        end
        COMPLETE: state <= IDLE;
        default: $fatal(1,"ATT_LITE_BAD_STATE bank=%0d",BANK);
      endcase
    end
  end
endmodule
