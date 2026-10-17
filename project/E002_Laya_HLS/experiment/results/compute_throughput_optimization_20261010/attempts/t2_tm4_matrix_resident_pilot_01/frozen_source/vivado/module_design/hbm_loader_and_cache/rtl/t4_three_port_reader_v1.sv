`timescale 1ns/1ps

// q0/q1/scale are three independent outstanding-one read masters. This
// transfers bytes only; a W slot still needs AUX/bias, scale admission,
// identity, and lease checks before its owner may publish READY.
module t4_three_port_reader_v1 (
  input  logic clk,
  input  logic rst_n,
  input  logic load_valid,
  output logic load_ready,
  input  logic [2:0][63:0] load_base,
  input  logic [2:0][31:0] load_bytes,
  input  logic [31:0] load_epoch,
  output logic load_done,
  output logic load_error,
  output logic [2:0][31:0] committed_bytes,
  output logic [2:0][63:0] araddr,
  output logic [2:0][7:0] arlen,
  output logic [2:0][2:0] arsize,
  output logic [2:0][1:0] arburst,
  output logic [2:0] arvalid,
  input  logic [2:0] arready,
  input  logic [2:0][511:0] rdata,
  input  logic [2:0][1:0] rresp,
  input  logic [2:0] rlast,
  input  logic [2:0] rvalid,
  output logic [2:0] rready,
  output logic [2:0][511:0] out_data,
  output logic [2:0][31:0] out_offset,
  output logic [2:0][31:0] out_epoch,
  output logic [2:0][6:0] out_bytes,
  output logic [2:0] out_last,
  output logic [2:0] out_valid,
  input  logic [2:0] out_ready
);
  logic [2:0] port_ready, port_done, port_error, seen_done;
  logic busy, any_error;
  assign load_ready = !busy && (&port_ready);
  for (genvar p = 0; p < 3; p++) begin : ports
    t4_w_reader_port_v1 #(.SCALE_MODE(p == 2)) reader (
      .clk, .rst_n,
      .load_valid(load_valid && load_ready),
      .load_ready(port_ready[p]),
      .load_base(load_base[p]), .load_bytes(load_bytes[p]),
      .load_epoch, .load_done(port_done[p]),
      .load_error(port_error[p]), .committed_bytes(committed_bytes[p]),
      .araddr(araddr[p]), .arlen(arlen[p]), .arsize(arsize[p]),
      .arburst(arburst[p]), .arvalid(arvalid[p]), .arready(arready[p]),
      .rdata(rdata[p]), .rresp(rresp[p]), .rlast(rlast[p]),
      .rvalid(rvalid[p]), .rready(rready[p]),
      .out_data(out_data[p]), .out_offset(out_offset[p]),
      .out_epoch(out_epoch[p]), .out_bytes(out_bytes[p]),
      .out_last(out_last[p]), .out_valid(out_valid[p]),
      .out_ready(out_ready[p])
    );
  end
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      busy <= 0; seen_done <= 0; any_error <= 0;
      load_done <= 0; load_error <= 0;
    end else begin
      load_done <= 0;
      if (load_valid && load_ready) begin
        busy <= 1;
        seen_done <= 0;
        any_error <= 0;
        load_error <= 0;
      end else if (busy) begin
        seen_done <= seen_done | port_done;
        if (|(port_done & port_error)) any_error <= 1;
        if (&(seen_done | port_done)) begin
          busy <= 0;
          load_done <= 1;
          load_error <= any_error | (|(port_done & port_error));
        end
      end
    end
  end
endmodule
