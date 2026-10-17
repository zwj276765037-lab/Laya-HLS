`timescale 1ns/1ps

// One original F32 divide IP with a bounded transaction-token reservation.
// This is the divider service used by the 16-lane quantizer candidate, not
// the blocking functional top's ce-only arithmetic wrapper.
module quant16_divider_service (
    input  logic         clk,
    input  logic         rst,
    input  logic         req_valid,
    output logic         req_ready,
    input  logic [31:0]  req_numerator,
    input  logic [31:0]  req_denominator,
    input  logic [101:0] req_tag,
    output logic         resp_valid,
    output logic [31:0]  resp_bits,
    output logic [101:0] resp_tag,
    output logic [5:0]   pending,
    output logic         protocol_fault
);
  logic [101:0] tags [0:31];
  logic [4:0] head, tail;
  logic [3:0] quarantine;
  wire req_fire = req_valid && req_ready;
  wire result_valid;
  wire [31:0] result_bits;
  wire pop = result_valid && quarantine == 0 && pending != 0 && !rst;

  assign req_ready = !rst && quarantine == 0 && pending < 32;
  assign resp_valid = pop;
  assign resp_bits = result_bits;
  assign resp_tag = tags[head];

  laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip u_div (
      .aclk(clk),
      .aclken(1'b1),
      .s_axis_a_tvalid(req_fire),
      .s_axis_a_tdata(req_numerator),
      .s_axis_b_tvalid(req_fire),
      .s_axis_b_tdata(req_denominator),
      .m_axis_result_tvalid(result_valid),
      .m_axis_result_tdata(result_bits)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      head <= '0;
      tail <= '0;
      pending <= '0;
      protocol_fault <= 1'b0;
      // IP has no reset. Keep its clock running and discard the old pipeline.
      quarantine <= 4'd12;
    end else begin
      if (quarantine != 0) quarantine <= quarantine - 1'b1;
      if (result_valid && quarantine == 0 && pending == 0)
        protocol_fault <= 1'b1;
      if (req_fire) begin
        tags[tail] <= req_tag;
        tail <= tail + 1'b1;
      end
      if (pop) head <= head + 1'b1;
      case ({req_fire,pop})
        2'b10: pending <= pending + 1'b1;
        2'b01: pending <= pending - 1'b1;
        default: pending <= pending;
      endcase
    end
  end
endmodule
