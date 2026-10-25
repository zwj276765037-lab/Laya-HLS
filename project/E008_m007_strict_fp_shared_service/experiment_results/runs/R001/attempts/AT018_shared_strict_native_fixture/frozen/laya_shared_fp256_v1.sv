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
  // Compatibility front-end only. The sole arithmetic implementation is v2.
  logic m_ready,m_valid,base_fault;
  logic [0:0] a_ready,a_valid,a_sink_ready;
  logic [0:0][95:0] a_tags;
  logic [95:0] m_tag;
  logic [6:0] m_pending;
  logic [0:0][6:0] a_pending;
  wire paired_fire=issue_valid&&issue_ready;
  assign issue_ready=rst_n&&!release_valid&&m_ready&&a_ready[0];
  assign rsp_valid=rst_n&&m_valid&&a_valid[0]&&!protocol_fault;
  assign rsp_tag=a_tags[0];
  assign pending=m_pending;
  assign a_sink_ready[0]=rsp_ready&&m_valid;
  assign protocol_fault=base_fault||(m_pending!=a_pending[0])||
                        (m_valid&&a_valid[0]&&m_tag!=a_tags[0]);
  laya_shared_fp256_v2 #(.LANES(LANES),.ADD_GROUPS(1)) array(
    .clk,.rst_n,.lease_valid,.lease_ready,
    .lease_request_id(64'd0),.lease_generation(lease_epoch),
    .lease_head(4'd0),.lease_phase,.lease_epoch,
    .release_valid,.release_ready,.release_phase,.release_epoch,
    .phase_debt_clear(1'b1),.lease_active(),.draining(),
    .rsp_request_id(),.rsp_generation(),.rsp_head(),.rsp_phase,.rsp_epoch,
    .mul_req_valid(paired_fire),.mul_req_ready(m_ready),
    .mul_req_phase(issue_phase),.mul_req_epoch(issue_epoch),.mul_req_tag(issue_tag),
    .mul_a,.mul_b,.mul_rsp_valid(m_valid),.mul_rsp_ready(rsp_ready&&a_valid[0]),
    .mul_rsp_tag(m_tag),.mul_rsp_data(rsp_mul),
    .add_req_valid(paired_fire),.add_req_is_root(1'b1),.add_req_ready(a_ready),
    .add_req_phase(issue_phase),.add_req_epoch(issue_epoch),.add_req_tag(issue_tag),
    .add_a,.add_b,.add_rsp_valid(a_valid),.add_rsp_ready(a_sink_ready),
    .add_rsp_tag(a_tags),.add_rsp_data(rsp_add),
    .mul_pending(m_pending),.add_pending(a_pending),.protocol_fault(base_fault));
endmodule
