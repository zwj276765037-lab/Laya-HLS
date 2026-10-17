`timescale 1ns/1ps
// Control-plane portion of the production shell.  The pointer register bundle
// is passed to the generated controller and mirrored only on its real AXI-Lite
// handshakes.  The ap_ctrl_hs bundle is proxied through the start gate so a
// request cannot reach the controller until persistent model binding accepts.
module laya_13bo_control_plane_v1(
  input logic clk,rst_n,soft_cancel,cold_rebind,domain_drained,
  input logic [3:0] s_control_awaddr,
  input logic s_control_awvalid,
  output logic s_control_awready,
  input logic [31:0] s_control_wdata,
  input logic [3:0] s_control_wstrb,
  input logic s_control_wvalid,
  output logic s_control_wready,
  output logic [1:0] s_control_bresp,
  output logic s_control_bvalid,
  input logic s_control_bready,
  input logic [3:0] s_control_araddr,
  input logic s_control_arvalid,
  output logic s_control_arready,
  output logic [31:0] s_control_rdata,
  output logic [1:0] s_control_rresp,
  output logic s_control_rvalid,
  input logic s_control_rready,
  output logic [3:0] m_control_awaddr,
  output logic m_control_awvalid,
  input logic m_control_awready,
  output logic [31:0] m_control_wdata,
  output logic [3:0] m_control_wstrb,
  output logic m_control_wvalid,
  input logic m_control_wready,
  input logic [1:0] m_control_bresp,
  input logic m_control_bvalid,
  output logic m_control_bready,
  output logic [3:0] m_control_araddr,
  output logic m_control_arvalid,
  input logic m_control_arready,
  input logic [31:0] m_control_rdata,
  input logic [1:0] m_control_rresp,
  input logic m_control_rvalid,
  output logic m_control_rready,
  input logic [7:0] s_control_r_awaddr,
  input logic s_control_r_awvalid,
  output logic s_control_r_awready,
  input logic [31:0] s_control_r_wdata,
  input logic [3:0] s_control_r_wstrb,
  input logic s_control_r_wvalid,
  output logic s_control_r_wready,
  output logic [1:0] s_control_r_bresp,
  output logic s_control_r_bvalid,
  input logic s_control_r_bready,
  input logic [7:0] s_control_r_araddr,
  input logic s_control_r_arvalid,
  output logic s_control_r_arready,
  output logic [31:0] s_control_r_rdata,
  output logic [1:0] s_control_r_rresp,
  output logic s_control_r_rvalid,
  input logic s_control_r_rready,
  output logic [7:0] m_control_r_awaddr,
  output logic m_control_r_awvalid,
  input logic m_control_r_awready,
  output logic [31:0] m_control_r_wdata,
  output logic [3:0] m_control_r_wstrb,
  output logic m_control_r_wvalid,
  input logic m_control_r_wready,
  input logic [1:0] m_control_r_bresp,
  input logic m_control_r_bvalid,
  output logic m_control_r_bready,
  output logic [7:0] m_control_r_araddr,
  output logic m_control_r_arvalid,
  input logic m_control_r_arready,
  input logic [31:0] m_control_r_rdata,
  input logic [1:0] m_control_r_rresp,
  input logic m_control_r_rvalid,
  output logic m_control_r_rready,
  output logic core_start_admitted,start_ready,start_rejected,
  output logic [12:0][63:0] programmed_bo_base,latched_bo_base,
  output logic binding_valid,
  output logic [4:0][63:0] bound_model_base,
  output logic candidate_valid,candidate_matches,
  output logic binding_conflict,cold_rebind_rejected,
  output logic [31:0] accepted_requests,rejected_requests,
  output logic mirror_protocol_error,control_write_idle,control_read_idle,
  output logic [31:0] forwarded_control_writes,rejected_control_starts
);
  logic host_start_valid,start_accepted;

  assign m_control_r_awaddr=s_control_r_awaddr;
  assign m_control_r_awvalid=s_control_r_awvalid;
  assign s_control_r_awready=m_control_r_awready;
  assign m_control_r_wdata=s_control_r_wdata;
  assign m_control_r_wstrb=s_control_r_wstrb;
  assign m_control_r_wvalid=s_control_r_wvalid;
  assign s_control_r_wready=m_control_r_wready;
  assign s_control_r_bresp=m_control_r_bresp;
  assign s_control_r_bvalid=m_control_r_bvalid;
  assign m_control_r_bready=s_control_r_bready;
  assign m_control_r_araddr=s_control_r_araddr;
  assign m_control_r_arvalid=s_control_r_arvalid;
  assign s_control_r_arready=m_control_r_arready;
  assign s_control_r_rdata=m_control_r_rdata;
  assign s_control_r_rresp=m_control_r_rresp;
  assign s_control_r_rvalid=m_control_r_rvalid;
  assign m_control_r_rready=s_control_r_rready;

  laya_control_start_gate_v1 start_gate(
    .clk,.rst_n,
    .s_awaddr(s_control_awaddr),.s_awvalid(s_control_awvalid),.s_awready(s_control_awready),
    .s_wdata(s_control_wdata),.s_wstrb(s_control_wstrb),.s_wvalid(s_control_wvalid),.s_wready(s_control_wready),
    .s_bresp(s_control_bresp),.s_bvalid(s_control_bvalid),.s_bready(s_control_bready),
    .s_araddr(s_control_araddr),.s_arvalid(s_control_arvalid),.s_arready(s_control_arready),
    .s_rdata(s_control_rdata),.s_rresp(s_control_rresp),.s_rvalid(s_control_rvalid),.s_rready(s_control_rready),
    .m_awaddr(m_control_awaddr),.m_awvalid(m_control_awvalid),.m_awready(m_control_awready),
    .m_wdata(m_control_wdata),.m_wstrb(m_control_wstrb),.m_wvalid(m_control_wvalid),.m_wready(m_control_wready),
    .m_bresp(m_control_bresp),.m_bvalid(m_control_bvalid),.m_bready(m_control_bready),
    .m_araddr(m_control_araddr),.m_arvalid(m_control_arvalid),.m_arready(m_control_arready),
    .m_rdata(m_control_rdata),.m_rresp(m_control_rresp),.m_rvalid(m_control_rvalid),.m_rready(m_control_rready),
    .host_start_valid,.host_start_ready(start_ready),.start_accepted,
    .start_rejected,.write_idle(control_write_idle),.read_idle(control_read_idle),
    .forwarded_writes(forwarded_control_writes),.rejected_starts(rejected_control_starts));

  laya_13bo_request_gate_v1 request_gate(
    .clk,.rst_n,
    .awaddr(m_control_r_awaddr),.awvalid(m_control_r_awvalid),.awready(m_control_r_awready),
    .wdata(m_control_r_wdata),.wstrb(m_control_r_wstrb),.wvalid(m_control_r_wvalid),.wready(m_control_r_wready),
    .host_ap_start(host_start_valid),.soft_cancel,.cold_rebind,.domain_drained,
    .core_ap_start(core_start_admitted),.start_ready,
    .programmed_bo_base,.latched_bo_base,.binding_valid,.bound_model_base,
    .candidate_valid,.candidate_matches,.binding_conflict,.cold_rebind_rejected,
    .accepted_requests,.rejected_requests,.mirror_protocol_error);

`ifndef SYNTHESIS
  always_ff @(posedge clk)if(rst_n)begin
    assert(core_start_admitted==start_accepted)
      else $fatal(1,"control and binding start decisions diverged");
  end
`endif
endmodule
