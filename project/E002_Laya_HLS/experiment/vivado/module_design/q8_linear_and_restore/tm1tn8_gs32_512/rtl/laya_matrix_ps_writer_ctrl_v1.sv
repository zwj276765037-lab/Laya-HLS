`timescale 1ns/1ps

// Fixed 16-row PS export controller. It uses the existing synchronous
// result bank and the sole source/norm AXI writer; neither is instantiated
// here. A tile is retired only after the last real B and debt-zero barrier.
module laya_matrix_ps_writer_ctrl_v1 (
  input logic clk,rst_n,
  input logic start_valid,active,discard,
  input logic [1:0][63:0] dest_base,dest_span,
  laya_lnq_bank_link_v1 bank_link,
  output logic result_read_accept,result_rsp_ready,
  output logic [9:0] bank_read_physical,bank_read_tag,
  output logic segment_begin,
  output logic [1:0] segment_route,
  output logic [64:0] segment_address,
  output logic writer_tile_valid,
  output logic [255:0] writer_tile_bits,
  output logic [11:0] writer_tile_n0,
  output logic writer_rearm_valid,writer_flush_req,
  input logic writer_rearm_ready,writer_tile_ready,
  input logic writer_flush_done,writer_debt_zero,writer_fault,
  input logic writer_awvalid,writer_wvalid,
  input logic [31:0] writer_aw_count,writer_w_count,writer_b_count,
  output logic [31:0] ok_b_count,retired_tiles
);
  typedef enum logic [3:0] {
    MP_IDLE,MP_REARM,MP_WAIT_TILE,MP_READ_REQ,MP_READ_RSP,
    MP_SEGMENT,MP_TILE,MP_FLUSH,MP_UNFLUSH,MP_ACK
  } state_t;
  state_t state;
  logic [3:0] row;
  logic error,flush_seen;
  wire [11:0] n0={bank_link.matrix_ps_tile,3'b000};
  wire [1:0] plane=n0/12'd1024;
  wire [3:0] head=(n0%12'd1024)/12'd64;
  wire [5:0] d=n0%12'd64;
  wire route=head[0];
  wire [63:0] offset=
      (((((64'(plane)*64'd2)*64'd8+
          64'(head[3:1]))*64'd1024+
          64'(row))*64'd64)+64'(d))*64'd4;
  wire [63:0] aligned_offset={offset[63:6],6'b0};
  wire [64:0] address=
      {1'b0,dest_base[route]}+{1'b0,aligned_offset};
  wire address_ok=!address[64] &&
      offset<=dest_span[route] &&
      64'd32<=dest_span[route]-offset;

  assign segment_route={1'b0,route};
  assign bank_read_physical=10'd544+10'(row);
  assign bank_read_tag=10'd896+10'(row);
  assign segment_address=address;
  assign segment_begin=active && state==MP_SEGMENT && address_ok &&
      writer_debt_zero && !writer_flush_req && !writer_tile_valid;
  assign result_read_accept=active && state==MP_READ_REQ &&
      !bank_link.result_pending && !bank_link.result_rsp_valid &&
      !bank_link.matrix_ps_store_valid;
  assign result_rsp_ready=active && bank_link.result_rsp_valid &&
      ((state==MP_TILE && writer_tile_ready &&
        bank_link.result_rsp_tile==10'd896+10'(row)) ||
       (state==MP_READ_RSP &&
        bank_link.result_rsp_tile!=10'd896+10'(row)) ||
       (state==MP_SEGMENT && !address_ok) ||
       (state==MP_FLUSH && writer_fault) || state==MP_ACK);
  assign bank_link.matrix_ps_retire_valid=active && state==MP_ACK &&
      writer_debt_zero && !bank_link.result_pending &&
      !bank_link.result_rsp_valid && !writer_awvalid && !writer_wvalid;
  assign bank_link.matrix_ps_retire_error=error;
  assign writer_tile_valid=active && state==MP_TILE &&
      bank_link.result_rsp_valid &&
      bank_link.result_rsp_tile==10'd896+10'(row) &&
      !error && !writer_fault;
  assign writer_tile_bits=bank_link.result_rsp_bits;
  assign writer_tile_n0={8'd0,n0[3:0]};
  assign writer_rearm_valid=active && state==MP_REARM;
  assign writer_flush_req=active && state==MP_FLUSH;
  always_ff @(posedge clk)begin
    if(!rst_n || discard)begin
      state<=MP_IDLE;row<=0;error<=0;flush_seen<=0;
      ok_b_count<=0;retired_tiles<=0;
    end else case(state)
      MP_IDLE:if(start_valid)begin
        row<=0;error<=0;flush_seen<=0;
        ok_b_count<=0;retired_tiles<=0;state<=MP_REARM;
      end
      MP_REARM:if(writer_rearm_ready)
        state<=row==4'd0 ? MP_WAIT_TILE : MP_READ_REQ;
      MP_WAIT_TILE:if(active && bank_link.matrix_ps_tile_valid)begin
        row<=0;error<=0;
        state<=bank_link.matrix_ps_tile_discard ? MP_ACK : MP_READ_REQ;
      end
      MP_READ_REQ:if(result_read_accept)state<=MP_READ_RSP;
      MP_READ_RSP:if(bank_link.result_rsp_valid)begin
        if(bank_link.result_rsp_tile!=10'd896+10'(row))begin
          error<=1;state<=MP_ACK;
        end else state<=MP_SEGMENT;
      end
      MP_SEGMENT:if(!address_ok)begin
        error<=1;state<=MP_ACK;
      end else if(segment_begin)state<=MP_TILE;
      MP_TILE:if(writer_fault)begin
        error<=1;state<=MP_FLUSH;
      end else if(result_rsp_ready)state<=MP_FLUSH;
      MP_FLUSH:begin
        if(writer_flush_done)flush_seen<=1;
        if(writer_debt_zero && (writer_flush_done || flush_seen ||
                                writer_fault))begin
          if(writer_fault || writer_aw_count!=32'd1 ||
             writer_w_count!=32'd1 || writer_b_count!=32'd1)
            error<=1;
          else ok_b_count<=ok_b_count+1'b1;
          state<=MP_UNFLUSH;
        end
      end
      MP_UNFLUSH:begin
        flush_seen<=0;
        if(error || row==4'd15)state<=MP_ACK;
        else begin row<=row+1'b1;state<=MP_REARM;end
      end
      MP_ACK:if(bank_link.matrix_ps_retire_ready)begin
        retired_tiles<=retired_tiles+1'b1;
        state<=MP_WAIT_TILE;
      end
      default:state<=MP_IDLE;
    endcase
  end
`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(!(result_read_accept && bank_link.matrix_result_accept))
      else $fatal(1,"matrix PS/result bank concurrent read");
    assert(!(segment_begin && !writer_debt_zero))
      else $fatal(1,"matrix PS writer route changed with debt");
  end
`endif
endmodule
