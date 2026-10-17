`timescale 1ns/1ps

// One original F32 divide IP. Every semantic request also occupies one IP
// transaction: tiny SCALE uses safe 0/127 while its exact helper runs. The
// 32-entry ring retains tokens until both physical paths have returned and
// semantic results retire in issue order.
module quant16_divider_service (
    input  logic         clk,
    input  logic         rst,
    input  logic         req_valid,
    output logic         req_ready,
    input  logic [31:0]  req_numerator,
    input  logic [31:0]  req_denominator,
    input  logic [31:0]  req_tiny_amax,
    input  logic [1:0]   req_route, // 0 normal, 1 tiny SCALE, 2 subnormal RECIP
    input  logic [101:0] req_tag,
    output logic         resp_valid,
    output logic [31:0]  resp_bits,
    output logic [101:0] resp_tag,
    output logic [5:0]   pending,
    output logic         protocol_fault
);
  import r0_fp_bits_pkg::*;
  logic [101:0] tags [0:31];
  logic [1:0] routes [0:31];
  logic [31:0] fp_bits [0:31], helper_bits [0:31];
  logic fp_ready [0:31], helper_ready [0:31];
  logic [4:0] head, issue_tail, fp_return_ptr;
  logic [3:0] quarantine;
  logic [5:0] fp_pending, helper_pending;
  logic [31:0] fp_issues, fp_returns, fp_dummy_issues;
  logic [31:0] helper_issues, helper_returns, semantic_returns;
  logic [5:0] pending_peak;

  wire req_fire = req_valid && req_ready;
  wire result_valid;
  wire [31:0] result_bits;
  wire helper_valid;
  wire [31:0] helper_result;
  wire [4:0] helper_index;
  wire [101:0] helper_tag;
  wire fp_return = result_valid && quarantine == 0 &&
                   fp_pending != 0 && !rst;
  wire helper_return = helper_valid && quarantine == 0 && !rst;
  wire retire = resp_valid;

  assign req_ready = !rst && quarantine == 0 && pending < 32;
  assign resp_valid = !rst && quarantine == 0 && pending != 0 &&
                      fp_ready[head] && helper_ready[head];
  assign resp_tag = tags[head];
  assign resp_bits = routes[head] == 2'd1 ? helper_bits[head] :
                     routes[head] == 2'd2 ?
                         positive_normal_up24_or_inf(fp_bits[head]) :
                         fp_bits[head];

  laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip u_div (
      .aclk(clk), .aclken(1'b1),
      .s_axis_a_tvalid(req_fire), .s_axis_a_tdata(req_numerator),
      .s_axis_b_tvalid(req_fire), .s_axis_b_tdata(req_denominator),
      .m_axis_result_tvalid(result_valid),
      .m_axis_result_tdata(result_bits)
  );
  quant16_tiny_div127 tiny (
      .clk(clk), .rst(rst),
      .req_valid(req_fire && req_route == 2'd1),
      .req_amax_bits(req_tiny_amax), .req_index(issue_tail),
      .req_tag(req_tag),
      .resp_valid(helper_valid), .resp_bits(helper_result),
      .resp_index(helper_index), .resp_tag(helper_tag)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      head <= 0;
      issue_tail <= 0;
      fp_return_ptr <= 0;
      pending <= 0;
      fp_pending <= 0;
      helper_pending <= 0;
      protocol_fault <= 0;
      // The original FP IP has no reset; keep its clock enabled and discard
      // its old outputs before a new token may enter this ring.
      quarantine <= 4'd12;
      fp_issues <= 0; fp_returns <= 0; fp_dummy_issues <= 0;
      helper_issues <= 0; helper_returns <= 0;
      semantic_returns <= 0; pending_peak <= 0;
      for (int i=0;i<32;i++) begin
        fp_ready[i] <= 0;
        helper_ready[i] <= 0;
      end
    end else begin
      if (quarantine != 0) quarantine <= quarantine - 1'b1;
      if (result_valid && quarantine == 0 && fp_pending == 0)
        protocol_fault <= 1;
      if (helper_return && (helper_pending == 0 ||
                            routes[helper_index] != 2'd1 ||
                            helper_tag != tags[helper_index]))
        protocol_fault <= 1;
      if (req_fire && (req_route == 2'd3 ||
          (req_route == 2'd1 && (req_tag[0] || req_tiny_amax > R0_TINY_MAX)) ||
          (req_route == 2'd2 && !req_tag[0])))
        protocol_fault <= 1;
      if (req_fire) begin
        tags[issue_tail] <= req_tag;
        routes[issue_tail] <= req_route;
        fp_ready[issue_tail] <= 0;
        helper_ready[issue_tail] <= req_route != 2'd1;
        issue_tail <= issue_tail + 1'b1;
        fp_issues <= fp_issues + 1'b1;
        if (req_route == 2'd1) begin
          fp_dummy_issues <= fp_dummy_issues + 1'b1;
          helper_issues <= helper_issues + 1'b1;
        end
      end
      if (fp_return) begin
        fp_bits[fp_return_ptr] <= result_bits;
        fp_ready[fp_return_ptr] <= 1;
        fp_return_ptr <= fp_return_ptr + 1'b1;
        fp_returns <= fp_returns + 1'b1;
      end
      if (helper_return) begin
        helper_bits[helper_index] <= helper_result;
        helper_ready[helper_index] <= 1;
        helper_returns <= helper_returns + 1'b1;
      end
      if (retire) begin
        head <= head + 1'b1;
        semantic_returns <= semantic_returns + 1'b1;
      end
      case ({req_fire,retire})
        2'b10: pending <= pending + 1'b1;
        2'b01: pending <= pending - 1'b1;
        default:;
      endcase
      if (req_fire && !retire && pending >= pending_peak)
        pending_peak <= pending + 1'b1;
      case ({req_fire,fp_return})
        2'b10: fp_pending <= fp_pending + 1'b1;
        2'b01: fp_pending <= fp_pending - 1'b1;
        default:;
      endcase
      case ({req_fire && req_route == 2'd1,helper_return})
        2'b10: helper_pending <= helper_pending + 1'b1;
        2'b01: helper_pending <= helper_pending - 1'b1;
        default:;
      endcase
    end
  end
endmodule
