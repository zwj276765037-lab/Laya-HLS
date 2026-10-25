`timescale 1ns/1ps

// One physical F32 multiply/add array, shared by matrix restore and the
// Attention phases. Each operation rounds independently; this is not an FMA.
// A phase may change only after all accepted responses have been consumed.
module laya_shared_fp256_v1 #(
  parameter int LANES = 256
) (
  input  logic clk, rst_n,
  input  logic lease_valid,
  output logic lease_ready,
  input  logic [2:0] lease_phase,
  input  logic [31:0] lease_epoch,
  input  logic release_valid,
  output logic release_ready,
  input  logic [2:0] release_phase,
  input  logic [31:0] release_epoch,
  input  logic issue_valid,
  output logic issue_ready,
  input  logic [2:0] issue_phase,
  input  logic [31:0] issue_epoch,
  input  logic [95:0] issue_tag,
  input  logic [LANES-1:0][31:0] mul_a, mul_b, add_a, add_b,
  output logic rsp_valid,
  input  logic rsp_ready,
  output logic [2:0] rsp_phase,
  output logic [31:0] rsp_epoch,
  output logic [95:0] rsp_tag,
  output logic [LANES-1:0][31:0] rsp_mul, rsp_add,
  output logic [6:0] pending,
  output logic protocol_fault
);
  localparam int DEPTH = 64;
  logic leased;
  logic [2:0] held_phase;
  logic [31:0] held_epoch;
  logic [5:0] issue_ptr, return_ptr, head_ptr;
  logic [6:0] in_flight;
  logic [DEPTH-1:0] slot_ready;
  logic [2:0] slot_phase [0:DEPTH-1];
  logic [31:0] slot_epoch [0:DEPTH-1];
  logic [95:0] slot_tag [0:DEPTH-1];
  logic [LANES-1:0][31:0] slot_mul [0:DEPTH-1];
  logic [LANES-1:0][31:0] slot_add [0:DEPTH-1];
  logic [LANES-1:0][31:0] mul_result, add_result;
  logic [LANES-1:0] mul_valid, add_valid;
  logic [LANES-1:0][31:0] mul_delay [0:4];
  logic [4:0] mul_delay_valid;

  wire issue_fire = issue_valid && issue_ready;
  wire return_fire = add_valid[0] && mul_delay_valid[4];
  wire retire_fire = rsp_valid && rsp_ready;
  assign lease_ready = rst_n && !leased && pending == 0 &&
                       in_flight == 0 && !protocol_fault;
  assign release_ready = rst_n && leased && pending == 0 &&
                         in_flight == 0 && !add_valid[0] &&
                         !mul_delay_valid[4] &&
                         release_phase == held_phase &&
                         release_epoch == held_epoch && !protocol_fault;
  assign issue_ready = rst_n && leased && !release_valid &&
                       issue_phase == held_phase &&
                       issue_epoch == held_epoch && pending < DEPTH &&
                       !protocol_fault;
  assign rsp_valid = rst_n && leased && pending != 0 &&
                     slot_ready[head_ptr] && !protocol_fault;
  assign rsp_phase = slot_phase[head_ptr];
  assign rsp_epoch = slot_epoch[head_ptr];
  assign rsp_tag = slot_tag[head_ptr];
  assign rsp_mul = slot_mul[head_ptr];
  assign rsp_add = slot_add[head_ptr];

  for (genvar lane = 0; lane < LANES; lane++) begin : fp_lane
    tm1tn8_fmul_ip u_mul (
      .aclk(clk), .aresetn(rst_n),
      .s_axis_a_tvalid(issue_fire), .s_axis_a_tdata(mul_a[lane]),
      .s_axis_b_tvalid(issue_fire), .s_axis_b_tdata(mul_b[lane]),
      .m_axis_result_tvalid(mul_valid[lane]),
      .m_axis_result_tdata(mul_result[lane])
    );
    tm1tn8_fadd_ip u_add (
      .aclk(clk), .aclken(1'b1), .aresetn(rst_n),
      .s_axis_a_tvalid(issue_fire), .s_axis_a_tdata(add_a[lane]),
      .s_axis_b_tvalid(issue_fire), .s_axis_b_tdata(add_b[lane]),
      .m_axis_result_tvalid(add_valid[lane]),
      .m_axis_result_tdata(add_result[lane])
    );
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      leased <= 0;
      held_phase <= 0;
      held_epoch <= 0;
      issue_ptr <= 0;
      return_ptr <= 0;
      head_ptr <= 0;
      pending <= 0;
      in_flight <= 0;
      slot_ready <= '0;
      mul_delay_valid <= '0;
      protocol_fault <= 0;
    end else begin
      mul_delay[0] <= mul_result;
      for (int i = 1; i < 5; i++) mul_delay[i] <= mul_delay[i-1];
      mul_delay_valid <= {mul_delay_valid[3:0], mul_valid[0]};

      if (lease_valid && lease_ready) begin
        leased <= 1;
        held_phase <= lease_phase;
        held_epoch <= lease_epoch;
      end
      if (release_valid && release_ready) leased <= 0;

      if (mul_valid != {LANES{mul_valid[0]}} ||
          add_valid != {LANES{add_valid[0]}} ||
          add_valid[0] != mul_delay_valid[4] ||
          (return_fire && in_flight == 0))
        protocol_fault <= 1;

      if (issue_fire) begin
        slot_ready[issue_ptr] <= 0;
        slot_phase[issue_ptr] <= issue_phase;
        slot_epoch[issue_ptr] <= issue_epoch;
        slot_tag[issue_ptr] <= issue_tag;
        issue_ptr <= issue_ptr + 1'b1;
      end
      if (return_fire) begin
        slot_mul[return_ptr] <= mul_delay[4];
        slot_add[return_ptr] <= add_result;
        slot_ready[return_ptr] <= 1;
        return_ptr <= return_ptr + 1'b1;
      end
      if (retire_fire) begin
        slot_ready[head_ptr] <= 0;
        head_ptr <= head_ptr + 1'b1;
      end
      case ({issue_fire, retire_fire})
        2'b10: pending <= pending + 1'b1;
        2'b01: pending <= pending - 1'b1;
        default:;
      endcase
      case ({issue_fire, return_fire})
        2'b10: in_flight <= in_flight + 1'b1;
        2'b01: in_flight <= in_flight - 1'b1;
        default:;
      endcase
    end
  end
endmodule
