`timescale 1ns/1ps

// Independent AUX bias port. Full beats deliver 16 bytes; a final 8-byte
// beat uses a narrow AXI transfer. Each AR reserves its complete return in
// this 64-beat FIFO, so RREADY does not depend on the W-bank write side.
module t4_aux_bias_reader_v1 (
  input  logic clk, rst_n,
  input  logic cancel,
  input  logic load_valid,
  output logic load_ready,
  input  logic [63:0] load_base,
  input  logic [31:0] load_bytes, load_epoch,
  output logic load_done, load_error,
  output logic [31:0] committed_bytes,
  output logic [63:0] araddr,
  output logic [7:0] arlen,
  output logic [2:0] arsize,
  output logic [1:0] arburst,
  output logic arvalid,
  input  logic arready,
  input  logic [127:0] rdata,
  input  logic [1:0] rresp,
  input  logic rlast, rvalid,
  output logic rready,
  output logic [127:0] out_data,
  output logic [31:0] out_offset, out_epoch,
  output logic [4:0] out_bytes,
  output logic out_last, out_valid,
  input  logic out_ready
);
  typedef enum logic [1:0] {IDLE, ISSUE, RECV, FINISH} state_t;
  state_t state;
  logic [63:0] base;
  logic [31:0] total, issued, received, epoch;
  logic [6:0] fifo_count, next_beats, page_beats, burst_beats, r_index;
  logic [5:0] write_ptr, read_ptr;
  logic [2:0] burst_size;
  logic [127:0] fifo_data [0:63];
  logic [31:0] fifo_offset [0:63];
  logic [4:0] fifo_bytes [0:63];
  logic [31:0] remaining;
  logic [63:0] next_address;
  logic push, pop;
  logic ar_offered;

  always_comb begin
    next_address = base + issued;
    remaining = total - issued;
    arsize = remaining == 8 ? 3'd3 : 3'd4;
    page_beats = arsize == 3'd3 ? 7'd1 :
                 next_address[11:4] >= 8'd192 ?
                 7'(256 - {1'b0,next_address[11:4]}) : 7'd64;
    next_beats = remaining == 8 ? 7'd1 :
                 remaining >= 1024 ? 7'd64 : 7'(remaining >> 4);
    if (next_beats > page_beats) next_beats = page_beats;
  end
  assign load_ready = state == IDLE && !cancel;
  assign araddr = next_address;
  assign arlen = next_beats - 1'b1;
  assign arburst = 2'b01;
  assign arvalid = state == ISSUE && issued < total && next_beats != 0 &&
                   (7'd64 - fifo_count) >= next_beats &&
                   ((!cancel && !load_error) || ar_offered);
  assign rready = state == RECV;
  assign push = rvalid && rready && r_index < burst_beats;
  assign out_valid = fifo_count != 0;
  assign out_data = fifo_data[read_ptr];
  assign out_offset = fifo_offset[read_ptr];
  assign out_bytes = fifo_bytes[read_ptr];
  assign out_epoch = epoch;
  assign out_last = out_valid && out_offset + out_bytes == total;
  assign pop = out_valid && out_ready;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      base <= 0; total <= 0; issued <= 0; received <= 0; epoch <= 0;
      fifo_count <= 0; write_ptr <= 0; read_ptr <= 0;
      burst_beats <= 0; burst_size <= 0; r_index <= 0;
      committed_bytes <= 0; load_done <= 0; load_error <= 0;
      ar_offered <= 0;
    end else begin
      load_done <= 0;
      if(arvalid && !arready)ar_offered<=1;
      if(arvalid && arready)ar_offered<=0;
      if(cancel && state!=IDLE)load_error<=1;
      case ({push,pop})
        2'b10: fifo_count <= fifo_count + 1'b1;
        2'b01: fifo_count <= fifo_count - 1'b1;
        default: ;
      endcase
      if (push) begin
        fifo_data[write_ptr] <= rdata;
        fifo_offset[write_ptr] <= received;
        fifo_bytes[write_ptr] <= 5'(1 << burst_size);
        write_ptr <= write_ptr + 1'b1;
        received <= received + (32'd1 << burst_size);
      end
      if (pop) begin
        committed_bytes <= committed_bytes + out_bytes;
        read_ptr <= read_ptr + 1'b1;
      end
      case (state)
        IDLE: if (load_valid && load_ready) begin
          base <= load_base; total <= load_bytes; epoch <= load_epoch;
          issued <= 0; received <= 0; committed_bytes <= 0;
          write_ptr <= 0; read_ptr <= 0; fifo_count <= 0;
          load_error <= 0;
          ar_offered <= 0;
          if (load_base[3:0] != 0 || load_bytes[2:0] != 0 ||
              load_base > 64'hffff_ffff_ffff_ffff - load_bytes) begin
            load_error <= 1;
            load_done <= 1;
          end else state <= ISSUE;
        end
        ISSUE: begin
          if ((cancel || load_error) && !arvalid) state <= FINISH;
          else if (issued == total && fifo_count == 0) begin
            if (received != total || committed_bytes != total)
              load_error <= 1;
            load_done <= 1;
            state <= IDLE;
          end else if (arvalid && arready) begin
            burst_beats <= next_beats;
            burst_size <= arsize;
            r_index <= 0;
            issued <= issued + (32'(next_beats) << arsize);
            state <= RECV;
          end
        end
        RECV: if (rvalid && rready) begin
          if (rresp != 0 || rlast != (r_index == burst_beats - 1'b1))
            load_error <= 1;
          if (r_index < burst_beats) r_index <= r_index + 1'b1;
          if (rlast) begin
            if (cancel || load_error || rresp != 0 ||
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
