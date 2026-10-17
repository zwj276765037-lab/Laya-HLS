`timescale 1ns/1ps

// One AXI4 read port. A full upcoming burst is reserved in the 64-beat FIFO
// before AR; a returned beat never depends on downstream ready. SCALE_MODE
// commits each 512-bit return as four ordered 128-bit half-word groups.
module t4_w_reader_port_v1 #(
  parameter bit SCALE_MODE = 0
) (
  input  logic clk,
  input  logic rst_n,
  input  logic load_valid,
  output logic load_ready,
  input  logic [63:0] load_base,
  input  logic [31:0] load_bytes,
  input  logic [31:0] load_epoch,
  output logic load_done,
  output logic load_error,
  output logic [31:0] committed_bytes,
  output logic [63:0] araddr,
  output logic [7:0] arlen,
  output logic [2:0] arsize,
  output logic [1:0] arburst,
  output logic arvalid,
  input  logic arready,
  input  logic [511:0] rdata,
  input  logic [1:0] rresp,
  input  logic rlast,
  input  logic rvalid,
  output logic rready,
  output logic [511:0] out_data,
  output logic [31:0] out_offset,
  output logic [31:0] out_epoch,
  output logic [6:0] out_bytes,
  output logic out_last,
  output logic out_valid,
  input  logic out_ready
);
  typedef enum logic [1:0] {IDLE, ISSUE, RECV, FINISH} state_t;
  state_t state;
  logic [63:0] base;
  logic [31:0] total, issued, received, epoch;
  logic [6:0] burst_beats, r_index, fifo_count;
  logic [5:0] write_ptr, read_ptr;
  logic [1:0] chunk;
  logic [511:0] fifo_data [0:63];
  logic [31:0] fifo_offset [0:63];
  logic [6:0] next_beats, page_beats;
  logic [31:0] remaining_beats;
  logic [63:0] next_address;
  logic push, pop, output_handshake;

  always_comb begin
    next_address = base + issued;
    remaining_beats = (total - issued) >> 6;
    page_beats = (64 - next_address[11:6]);
    next_beats = remaining_beats >= 64 ? 7'd64 : remaining_beats[6:0];
    if (next_beats > page_beats) next_beats = page_beats;
  end
  assign load_ready = state == IDLE;
  assign araddr = next_address;
  assign arlen = next_beats - 1'b1;
  assign arsize = 3'd6;
  assign arburst = 2'b01;
  assign arvalid = state == ISSUE && issued < total &&
                   next_beats != 0 && (7'd64 - fifo_count) >= next_beats;
  assign rready = state == RECV; // complete-burst reservation prevents overflow
  assign push = rvalid && rready && r_index < burst_beats;
  assign out_valid = fifo_count != 0;
  assign out_epoch = epoch;
  assign out_bytes = SCALE_MODE ? 7'd16 : 7'd64;
  assign out_offset = fifo_offset[read_ptr] +
                      (SCALE_MODE ? {26'd0, chunk, 4'b0000} : 32'd0);
  assign out_data = SCALE_MODE ?
      (fifo_data[read_ptr] >> (chunk * 128)) : fifo_data[read_ptr];
  assign out_last = out_valid && out_offset + out_bytes == total;
  assign output_handshake = out_valid && out_ready;
  assign pop = output_handshake && (!SCALE_MODE || chunk == 2'd3);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      base <= 0; total <= 0; issued <= 0; received <= 0; epoch <= 0;
      burst_beats <= 0; r_index <= 0; fifo_count <= 0;
      write_ptr <= 0; read_ptr <= 0; chunk <= 0;
      committed_bytes <= 0; load_done <= 0; load_error <= 0;
    end else begin
      load_done <= 0;
      case ({push, pop})
        2'b10: fifo_count <= fifo_count + 1'b1;
        2'b01: fifo_count <= fifo_count - 1'b1;
        default: ;
      endcase
      if (push) begin
        fifo_data[write_ptr] <= rdata;
        fifo_offset[write_ptr] <= received;
        write_ptr <= write_ptr + 1'b1;
        received <= received + 32'd64;
      end
      if (output_handshake) begin
        committed_bytes <= committed_bytes + (SCALE_MODE ? 32'd16 : 32'd64);
        if (SCALE_MODE) chunk <= chunk + 1'b1;
        if (pop) read_ptr <= read_ptr + 1'b1;
      end
      case (state)
        IDLE: if (load_valid && load_ready) begin
          base <= load_base; total <= load_bytes; issued <= 0;
          received <= 0; committed_bytes <= 0; epoch <= load_epoch;
          write_ptr <= 0; read_ptr <= 0; chunk <= 0; fifo_count <= 0;
          load_error <= 0;
          if (load_base[5:0] != 0 || load_bytes[5:0] != 0 ||
              load_base > 64'hffff_ffff_ffff_ffff - load_bytes) begin
            load_error <= 1;
            load_done <= 1;
          end else state <= ISSUE;
        end
        ISSUE: begin
          if (issued == total && fifo_count == 0) begin
            if (received != total || committed_bytes != total)
              load_error <= 1;
            load_done <= 1;
            state <= IDLE;
          end else if (arvalid && arready) begin
            burst_beats <= next_beats;
            r_index <= 0;
            issued <= issued + {next_beats, 6'b000000};
            state <= RECV;
          end
        end
        RECV: if (rvalid && rready) begin
          if (rresp != 0 || rlast != (r_index == burst_beats - 1'b1))
            load_error <= 1;
          if (r_index < burst_beats) r_index <= r_index + 1'b1;
          if (rlast) begin
            if (load_error || rresp != 0 ||
                r_index != burst_beats - 1'b1) state <= FINISH;
            else state <= ISSUE;
          end
        end
        FINISH: if (fifo_count == 0) begin
          load_done <= 1;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
