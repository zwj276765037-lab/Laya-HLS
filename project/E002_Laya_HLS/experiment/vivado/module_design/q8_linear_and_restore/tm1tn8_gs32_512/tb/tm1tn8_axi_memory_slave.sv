`timescale 1ns/1ps

// One-outstanding physical AXI endpoint for generated-wrapper tests. The
// caller supplies independent contents at read_address and observes each
// accepted write at write_address. B is deliberately held after the last W.
module tm1tn8_axi_memory_slave #(
  parameter int DATA_W=32,
  parameter int B_HOLD=9,
  parameter int R_HOLD=0
) (
  input  logic clk, rst_n,
  input  logic [63:0] araddr,
  input  logic [7:0] arlen,
  input  logic [2:0] arsize,
  input  logic arvalid,
  output logic arready,
  output logic [DATA_W-1:0] rdata,
  output logic [1:0] rresp,
  output logic rlast, rvalid,
  input  logic rready,
  output logic [63:0] read_address,
  input  logic [DATA_W-1:0] read_contents,
  input  logic [63:0] awaddr,
  input  logic [7:0] awlen,
  input  logic [2:0] awsize,
  input  logic awvalid,
  output logic awready,
  input  logic [DATA_W-1:0] wdata,
  input  logic [DATA_W/8-1:0] wstrb,
  input  logic wlast, wvalid,
  output logic wready,
  output logic [63:0] write_address,
  output logic [1:0] bresp,
  output logic bvalid,
  input  logic bready,
  output logic debt_zero,
  output logic [31:0] ar_count, r_count, aw_count, w_count, b_count
);
  logic reading, writing;
  logic [63:0] read_base, write_base;
  logic [7:0] read_len, write_len, read_beat, write_beat;
  logic [2:0] read_size, write_size;
  int b_delay, r_delay;
  assign arready = !reading;
  assign rvalid = reading && r_delay == 0;
  assign rresp = 2'b00;
  assign rlast = reading && read_beat == read_len;
  assign read_address = read_base + (64'(read_beat) << read_size);
  assign rdata = read_contents;
  assign awready = !writing && !bvalid && b_delay == 0;
  assign wready = writing && !bvalid;
  assign write_address = write_base + (64'(write_beat) << write_size);
  assign bresp = 2'b00;
  assign debt_zero = !reading && !writing && !bvalid && b_delay == 0;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      reading <= 0; writing <= 0; bvalid <= 0;
      read_base <= 0; write_base <= 0;
      read_len <= 0; write_len <= 0;
      read_beat <= 0; write_beat <= 0;
      read_size <= 0; write_size <= 0;
      b_delay <= 0;
      r_delay <= 0;
      ar_count <= 0; r_count <= 0;
      aw_count <= 0; w_count <= 0; b_count <= 0;
    end else begin
      if (arvalid && arready) begin
        if (arlen > 15 || arsize > $clog2(DATA_W/8) ||
            {1'b0,araddr[11:0]} + ((13'(arlen)+1)<<arsize) > 4096)
          $fatal(1,"AXI read burst shape/crossing addr=%h len=%0d size=%0d",
                 araddr,arlen,arsize);
        reading <= 1;
        read_base <= araddr;
        read_len <= arlen;
        read_size <= arsize;
        read_beat <= 0;
        r_delay <= arlen == 0 ? R_HOLD : 0;
        ar_count <= ar_count+1;
      end
      if (r_delay != 0) r_delay <= r_delay-1;
      if (rvalid && rready) begin
        r_count <= r_count+1;
        if (rlast) reading <= 0;
        else begin
          read_beat <= read_beat+1;
          if (read_beat+1 == read_len) r_delay <= R_HOLD;
        end
      end
      if (awvalid && awready) begin
        if (awlen > 15 || awsize > $clog2(DATA_W/8) ||
            {1'b0,awaddr[11:0]} + ((13'(awlen)+1)<<awsize) > 4096)
          $fatal(1,"AXI write burst shape/crossing addr=%h len=%0d size=%0d",
                 awaddr,awlen,awsize);
        writing <= 1;
        write_base <= awaddr;
        write_len <= awlen;
        write_size <= awsize;
        write_beat <= 0;
        aw_count <= aw_count+1;
      end
      if (wvalid && wready) begin
        if (wlast !== (write_beat == write_len))
          $fatal(1,"AXI WLAST beat=%0d len=%0d",write_beat,write_len);
        w_count <= w_count+1;
        if (wlast) begin
          writing <= 0;
          b_delay <= B_HOLD;
        end else write_beat <= write_beat+1;
      end
      if (b_delay != 0) begin
        b_delay <= b_delay-1;
        if (b_delay == 1) bvalid <= 1;
      end
      if (bvalid && bready) begin
        bvalid <= 0;
        b_count <= b_count+1;
      end
    end
  end
endmodule
