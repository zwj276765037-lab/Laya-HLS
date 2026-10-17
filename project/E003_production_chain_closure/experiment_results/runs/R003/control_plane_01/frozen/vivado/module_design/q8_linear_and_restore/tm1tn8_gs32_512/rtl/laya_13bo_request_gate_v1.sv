`timescale 1ns/1ps
// Original control-r handshakes feed the mirror. host_ap_start is admitted to
// the generated core only when the persistent five-model-BO binding accepts
// the exact candidate snapshot.
module laya_13bo_request_gate_v1(
  input logic clk,rst_n,
  input logic [7:0] awaddr,
  input logic awvalid,awready,
  input logic [31:0] wdata,
  input logic [3:0] wstrb,
  input logic wvalid,wready,
  input logic host_ap_start,soft_cancel,cold_rebind,domain_drained,
  output logic core_ap_start,start_ready,
  output logic [12:0][63:0] programmed_bo_base,latched_bo_base,
  output logic binding_valid,
  output logic [4:0][63:0] bound_model_base,
  output logic candidate_valid,candidate_matches,
  output logic binding_conflict,cold_rebind_rejected,
  output logic [31:0] accepted_requests,rejected_requests,
  output logic mirror_protocol_error
);
  laya_13bo_base_mirror_v1 mirror(
    .clk,.rst_n,.awaddr,.awvalid,.awready,.wdata,.wstrb,.wvalid,.wready,
    .request_accept(core_ap_start),.programmed_bo_base,.latched_bo_base,
    .accepted_requests,.protocol_error(mirror_protocol_error));
  laya_13bo_model_binding_v1 binding(
    .clk,.rst_n,.start_valid(host_ap_start),.start_ready,.start_fire(core_ap_start),
    .candidate_bo_base(programmed_bo_base),.soft_cancel,.cold_rebind,.domain_drained,
    .binding_valid,.bound_model_base,.candidate_valid,.candidate_matches,
    .binding_conflict,.cold_rebind_rejected,
    .accepted_starts(),.rejected_starts(rejected_requests));
endmodule
