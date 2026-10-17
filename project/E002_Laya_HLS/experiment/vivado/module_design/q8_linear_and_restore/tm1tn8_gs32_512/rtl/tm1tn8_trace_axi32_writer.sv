`timescale 1ns/1ps

// Eight actual 32-bit observed writes per selected group. D4 trace credit
// returns only after the eighth physical B response. One beat/outstanding
// per trace writer; all addresses are 4-byte aligned and cannot cross 4 KiB.
module tm1tn8_trace_axi32_writer (
  input  logic          clk,
  input  logic          rst_n,
  input  logic          command_start,
  input  logic          command_done,
  input  logic [63:0]   observed_base,
  input  logic [63:0]   observed_span,
  input  logic [5:0]    group_limit,
  input  logic [415:0]  trace_tdata,
  input  logic          trace_tvalid,
  output logic          trace_tready,
  output logic          trace_ack_valid,
  output logic [1:0]    trace_ack_slot,
  output logic [159:0]  trace_ack_tag,
  output logic          trace_ack_ok,
  output logic          debt_zero,
  output logic          fault,
  output logic [31:0]   aw_count,
  output logic [31:0]   w_count,
  output logic [31:0]   b_count,
  output logic [63:0]   m_axi_awaddr,
  output logic [7:0]    m_axi_awlen,
  output logic [2:0]    m_axi_awsize,
  output logic [1:0]    m_axi_awburst,
  output logic          m_axi_awvalid,
  input  logic          m_axi_awready,
  output logic [31:0]   m_axi_wdata,
  output logic [3:0]    m_axi_wstrb,
  output logic          m_axi_wlast,
  output logic          m_axi_wvalid,
  input  logic          m_axi_wready,
  input  logic [1:0]    m_axi_bresp,
  input  logic          m_axi_bvalid,
  output logic          m_axi_bready
);
  localparam logic [2:0] IDLE=0, AW=1, W=2, B=3;
  localparam logic [31:0] TRACE_GROUP_WORD=32'd17664;
  logic [2:0] state;
  logic configured;
  logic [63:0] base, span;
  logic [159:0] held_tag;
  logic [255:0] held_payload;
  logic [5:0] active_group_limit;
  logic b_error;
  logic [2:0] word_index;
  logic [63:0] relative_byte, address;
  logic valid_address;
  always_comb begin
    relative_byte = (TRACE_GROUP_WORD +
                     {26'd0,held_tag[16:11],3'd0} +
                     {29'd0,word_index}) * 4;
    address = base + relative_byte;
    valid_address = base[1:0] == 0 &&
                    base <= 64'hffff_ffff_ffff_ffff - relative_byte &&
                    relative_byte <= span &&
                    span - relative_byte >= 4;
  end
  assign trace_tready = configured && state == IDLE;
  assign debt_zero = state == IDLE && !trace_ack_valid;
  assign m_axi_awaddr = address;
  assign m_axi_awlen = 0;
  assign m_axi_awsize = 3'd2;
  assign m_axi_awburst = 2'b01;
  assign m_axi_awvalid = state == AW;
  assign m_axi_wdata = held_payload[word_index*32 +: 32];
  assign m_axi_wstrb = 4'hf;
  assign m_axi_wlast = 1;
  assign m_axi_wvalid = state == W;
  assign m_axi_bready = state == B;
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      configured <= 0;
      base <= 0;
      span <= 0;
      held_tag <= 0;
      held_payload <= 0;
      active_group_limit <= 0;
      b_error <= 0;
      word_index <= 0;
      trace_ack_valid <= 0;
      trace_ack_slot <= 0;
      trace_ack_tag <= 0;
      trace_ack_ok <= 0;
      fault <= 0;
      aw_count <= 0;
      w_count <= 0;
      b_count <= 0;
    end else begin
      trace_ack_valid <= 0;
      if (command_start) begin
        configured <= 1;
        base <= observed_base;
        span <= observed_span;
        active_group_limit <= group_limit;
        fault <= 0;
        if (state != IDLE || observed_base[1:0] != 0 ||
            observed_base > 64'hffff_ffff_ffff_ffff - observed_span)
          fault <= 1;
      end
      if (command_done) begin
        if (state != IDLE || aw_count != w_count || w_count != b_count)
          fault <= 1;
        configured <= 0;
      end
      case (state)
        IDLE: if (trace_tvalid && trace_tready) begin
          held_tag <= trace_tdata[415:256];
          held_payload <= trace_tdata[255:0];
          word_index <= 0;
          b_error <= 0;
          if (!trace_tdata[256+7] ||
              trace_tdata[256+16:256+11] >= active_group_limit ||
              base[1:0] != 0 ||
              base > 64'hffff_ffff_ffff_ffff -
                  ((TRACE_GROUP_WORD +
                    {26'd0,trace_tdata[256+16:256+11],3'd0} + 7)*4) ||
              span < ((TRACE_GROUP_WORD +
                       {26'd0,trace_tdata[256+16:256+11],3'd0} + 8)*4)) begin
            fault <= 1;
          end else state <= AW;
        end
        AW: if (m_axi_awready) begin
          if (!valid_address) fault <= 1;
          aw_count <= aw_count + 1;
          state <= W;
        end
        W: if (m_axi_wready) begin
          w_count <= w_count + 1;
          state <= B;
        end
        B: if (m_axi_bvalid) begin
          b_count <= b_count + 1;
          if (m_axi_bresp != 0) fault <= 1;
          if (m_axi_bresp != 0) b_error <= 1;
          if (word_index == 7) begin
            trace_ack_valid <= 1;
            trace_ack_slot <= held_tag[6:5];
            trace_ack_tag <= held_tag;
            trace_ack_ok <= !b_error && m_axi_bresp == 0;
            state <= IDLE;
          end else begin
            word_index <= word_index + 1'b1;
            state <= AW;
          end
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
