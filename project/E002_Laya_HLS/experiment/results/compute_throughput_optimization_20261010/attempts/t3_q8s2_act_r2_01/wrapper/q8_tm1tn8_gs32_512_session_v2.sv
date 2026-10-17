`timescale 1ns/1ps
module q8_tm1tn8_gs32_512_session_v2 (
  ap_clk,
  ap_rst_n,
  m_axi_gmem_descriptor_AWVALID,
  m_axi_gmem_descriptor_AWREADY,
  m_axi_gmem_descriptor_AWADDR,
  m_axi_gmem_descriptor_AWID,
  m_axi_gmem_descriptor_AWLEN,
  m_axi_gmem_descriptor_AWSIZE,
  m_axi_gmem_descriptor_AWBURST,
  m_axi_gmem_descriptor_AWLOCK,
  m_axi_gmem_descriptor_AWCACHE,
  m_axi_gmem_descriptor_AWPROT,
  m_axi_gmem_descriptor_AWQOS,
  m_axi_gmem_descriptor_AWREGION,
  m_axi_gmem_descriptor_AWUSER,
  m_axi_gmem_descriptor_WVALID,
  m_axi_gmem_descriptor_WREADY,
  m_axi_gmem_descriptor_WDATA,
  m_axi_gmem_descriptor_WSTRB,
  m_axi_gmem_descriptor_WLAST,
  m_axi_gmem_descriptor_WID,
  m_axi_gmem_descriptor_WUSER,
  m_axi_gmem_descriptor_ARVALID,
  m_axi_gmem_descriptor_ARREADY,
  m_axi_gmem_descriptor_ARADDR,
  m_axi_gmem_descriptor_ARID,
  m_axi_gmem_descriptor_ARLEN,
  m_axi_gmem_descriptor_ARSIZE,
  m_axi_gmem_descriptor_ARBURST,
  m_axi_gmem_descriptor_ARLOCK,
  m_axi_gmem_descriptor_ARCACHE,
  m_axi_gmem_descriptor_ARPROT,
  m_axi_gmem_descriptor_ARQOS,
  m_axi_gmem_descriptor_ARREGION,
  m_axi_gmem_descriptor_ARUSER,
  m_axi_gmem_descriptor_RVALID,
  m_axi_gmem_descriptor_RREADY,
  m_axi_gmem_descriptor_RDATA,
  m_axi_gmem_descriptor_RLAST,
  m_axi_gmem_descriptor_RID,
  m_axi_gmem_descriptor_RUSER,
  m_axi_gmem_descriptor_RRESP,
  m_axi_gmem_descriptor_BVALID,
  m_axi_gmem_descriptor_BREADY,
  m_axi_gmem_descriptor_BRESP,
  m_axi_gmem_descriptor_BID,
  m_axi_gmem_descriptor_BUSER,
  m_axi_gmem_w_q0_AWVALID,
  m_axi_gmem_w_q0_AWREADY,
  m_axi_gmem_w_q0_AWADDR,
  m_axi_gmem_w_q0_AWID,
  m_axi_gmem_w_q0_AWLEN,
  m_axi_gmem_w_q0_AWSIZE,
  m_axi_gmem_w_q0_AWBURST,
  m_axi_gmem_w_q0_AWLOCK,
  m_axi_gmem_w_q0_AWCACHE,
  m_axi_gmem_w_q0_AWPROT,
  m_axi_gmem_w_q0_AWQOS,
  m_axi_gmem_w_q0_AWREGION,
  m_axi_gmem_w_q0_AWUSER,
  m_axi_gmem_w_q0_WVALID,
  m_axi_gmem_w_q0_WREADY,
  m_axi_gmem_w_q0_WDATA,
  m_axi_gmem_w_q0_WSTRB,
  m_axi_gmem_w_q0_WLAST,
  m_axi_gmem_w_q0_WID,
  m_axi_gmem_w_q0_WUSER,
  m_axi_gmem_w_q0_ARVALID,
  m_axi_gmem_w_q0_ARREADY,
  m_axi_gmem_w_q0_ARADDR,
  m_axi_gmem_w_q0_ARID,
  m_axi_gmem_w_q0_ARLEN,
  m_axi_gmem_w_q0_ARSIZE,
  m_axi_gmem_w_q0_ARBURST,
  m_axi_gmem_w_q0_ARLOCK,
  m_axi_gmem_w_q0_ARCACHE,
  m_axi_gmem_w_q0_ARPROT,
  m_axi_gmem_w_q0_ARQOS,
  m_axi_gmem_w_q0_ARREGION,
  m_axi_gmem_w_q0_ARUSER,
  m_axi_gmem_w_q0_RVALID,
  m_axi_gmem_w_q0_RREADY,
  m_axi_gmem_w_q0_RDATA,
  m_axi_gmem_w_q0_RLAST,
  m_axi_gmem_w_q0_RID,
  m_axi_gmem_w_q0_RUSER,
  m_axi_gmem_w_q0_RRESP,
  m_axi_gmem_w_q0_BVALID,
  m_axi_gmem_w_q0_BREADY,
  m_axi_gmem_w_q0_BRESP,
  m_axi_gmem_w_q0_BID,
  m_axi_gmem_w_q0_BUSER,
  m_axi_gmem_w_q1_AWVALID,
  m_axi_gmem_w_q1_AWREADY,
  m_axi_gmem_w_q1_AWADDR,
  m_axi_gmem_w_q1_AWID,
  m_axi_gmem_w_q1_AWLEN,
  m_axi_gmem_w_q1_AWSIZE,
  m_axi_gmem_w_q1_AWBURST,
  m_axi_gmem_w_q1_AWLOCK,
  m_axi_gmem_w_q1_AWCACHE,
  m_axi_gmem_w_q1_AWPROT,
  m_axi_gmem_w_q1_AWQOS,
  m_axi_gmem_w_q1_AWREGION,
  m_axi_gmem_w_q1_AWUSER,
  m_axi_gmem_w_q1_WVALID,
  m_axi_gmem_w_q1_WREADY,
  m_axi_gmem_w_q1_WDATA,
  m_axi_gmem_w_q1_WSTRB,
  m_axi_gmem_w_q1_WLAST,
  m_axi_gmem_w_q1_WID,
  m_axi_gmem_w_q1_WUSER,
  m_axi_gmem_w_q1_ARVALID,
  m_axi_gmem_w_q1_ARREADY,
  m_axi_gmem_w_q1_ARADDR,
  m_axi_gmem_w_q1_ARID,
  m_axi_gmem_w_q1_ARLEN,
  m_axi_gmem_w_q1_ARSIZE,
  m_axi_gmem_w_q1_ARBURST,
  m_axi_gmem_w_q1_ARLOCK,
  m_axi_gmem_w_q1_ARCACHE,
  m_axi_gmem_w_q1_ARPROT,
  m_axi_gmem_w_q1_ARQOS,
  m_axi_gmem_w_q1_ARREGION,
  m_axi_gmem_w_q1_ARUSER,
  m_axi_gmem_w_q1_RVALID,
  m_axi_gmem_w_q1_RREADY,
  m_axi_gmem_w_q1_RDATA,
  m_axi_gmem_w_q1_RLAST,
  m_axi_gmem_w_q1_RID,
  m_axi_gmem_w_q1_RUSER,
  m_axi_gmem_w_q1_RRESP,
  m_axi_gmem_w_q1_BVALID,
  m_axi_gmem_w_q1_BREADY,
  m_axi_gmem_w_q1_BRESP,
  m_axi_gmem_w_q1_BID,
  m_axi_gmem_w_q1_BUSER,
  m_axi_gmem_w_scale_AWVALID,
  m_axi_gmem_w_scale_AWREADY,
  m_axi_gmem_w_scale_AWADDR,
  m_axi_gmem_w_scale_AWID,
  m_axi_gmem_w_scale_AWLEN,
  m_axi_gmem_w_scale_AWSIZE,
  m_axi_gmem_w_scale_AWBURST,
  m_axi_gmem_w_scale_AWLOCK,
  m_axi_gmem_w_scale_AWCACHE,
  m_axi_gmem_w_scale_AWPROT,
  m_axi_gmem_w_scale_AWQOS,
  m_axi_gmem_w_scale_AWREGION,
  m_axi_gmem_w_scale_AWUSER,
  m_axi_gmem_w_scale_WVALID,
  m_axi_gmem_w_scale_WREADY,
  m_axi_gmem_w_scale_WDATA,
  m_axi_gmem_w_scale_WSTRB,
  m_axi_gmem_w_scale_WLAST,
  m_axi_gmem_w_scale_WID,
  m_axi_gmem_w_scale_WUSER,
  m_axi_gmem_w_scale_ARVALID,
  m_axi_gmem_w_scale_ARREADY,
  m_axi_gmem_w_scale_ARADDR,
  m_axi_gmem_w_scale_ARID,
  m_axi_gmem_w_scale_ARLEN,
  m_axi_gmem_w_scale_ARSIZE,
  m_axi_gmem_w_scale_ARBURST,
  m_axi_gmem_w_scale_ARLOCK,
  m_axi_gmem_w_scale_ARCACHE,
  m_axi_gmem_w_scale_ARPROT,
  m_axi_gmem_w_scale_ARQOS,
  m_axi_gmem_w_scale_ARREGION,
  m_axi_gmem_w_scale_ARUSER,
  m_axi_gmem_w_scale_RVALID,
  m_axi_gmem_w_scale_RREADY,
  m_axi_gmem_w_scale_RDATA,
  m_axi_gmem_w_scale_RLAST,
  m_axi_gmem_w_scale_RID,
  m_axi_gmem_w_scale_RUSER,
  m_axi_gmem_w_scale_RRESP,
  m_axi_gmem_w_scale_BVALID,
  m_axi_gmem_w_scale_BREADY,
  m_axi_gmem_w_scale_BRESP,
  m_axi_gmem_w_scale_BID,
  m_axi_gmem_w_scale_BUSER,
  m_axi_gmem_aux_AWVALID,
  m_axi_gmem_aux_AWREADY,
  m_axi_gmem_aux_AWADDR,
  m_axi_gmem_aux_AWID,
  m_axi_gmem_aux_AWLEN,
  m_axi_gmem_aux_AWSIZE,
  m_axi_gmem_aux_AWBURST,
  m_axi_gmem_aux_AWLOCK,
  m_axi_gmem_aux_AWCACHE,
  m_axi_gmem_aux_AWPROT,
  m_axi_gmem_aux_AWQOS,
  m_axi_gmem_aux_AWREGION,
  m_axi_gmem_aux_AWUSER,
  m_axi_gmem_aux_WVALID,
  m_axi_gmem_aux_WREADY,
  m_axi_gmem_aux_WDATA,
  m_axi_gmem_aux_WSTRB,
  m_axi_gmem_aux_WLAST,
  m_axi_gmem_aux_WID,
  m_axi_gmem_aux_WUSER,
  m_axi_gmem_aux_ARVALID,
  m_axi_gmem_aux_ARREADY,
  m_axi_gmem_aux_ARADDR,
  m_axi_gmem_aux_ARID,
  m_axi_gmem_aux_ARLEN,
  m_axi_gmem_aux_ARSIZE,
  m_axi_gmem_aux_ARBURST,
  m_axi_gmem_aux_ARLOCK,
  m_axi_gmem_aux_ARCACHE,
  m_axi_gmem_aux_ARPROT,
  m_axi_gmem_aux_ARQOS,
  m_axi_gmem_aux_ARREGION,
  m_axi_gmem_aux_ARUSER,
  m_axi_gmem_aux_RVALID,
  m_axi_gmem_aux_RREADY,
  m_axi_gmem_aux_RDATA,
  m_axi_gmem_aux_RLAST,
  m_axi_gmem_aux_RID,
  m_axi_gmem_aux_RUSER,
  m_axi_gmem_aux_RRESP,
  m_axi_gmem_aux_BVALID,
  m_axi_gmem_aux_BREADY,
  m_axi_gmem_aux_BRESP,
  m_axi_gmem_aux_BID,
  m_axi_gmem_aux_BUSER,
  m_axi_gmem_activation_AWVALID,
  m_axi_gmem_activation_AWREADY,
  m_axi_gmem_activation_AWADDR,
  m_axi_gmem_activation_AWID,
  m_axi_gmem_activation_AWLEN,
  m_axi_gmem_activation_AWSIZE,
  m_axi_gmem_activation_AWBURST,
  m_axi_gmem_activation_AWLOCK,
  m_axi_gmem_activation_AWCACHE,
  m_axi_gmem_activation_AWPROT,
  m_axi_gmem_activation_AWQOS,
  m_axi_gmem_activation_AWREGION,
  m_axi_gmem_activation_AWUSER,
  m_axi_gmem_activation_WVALID,
  m_axi_gmem_activation_WREADY,
  m_axi_gmem_activation_WDATA,
  m_axi_gmem_activation_WSTRB,
  m_axi_gmem_activation_WLAST,
  m_axi_gmem_activation_WID,
  m_axi_gmem_activation_WUSER,
  m_axi_gmem_activation_ARVALID,
  m_axi_gmem_activation_ARREADY,
  m_axi_gmem_activation_ARADDR,
  m_axi_gmem_activation_ARID,
  m_axi_gmem_activation_ARLEN,
  m_axi_gmem_activation_ARSIZE,
  m_axi_gmem_activation_ARBURST,
  m_axi_gmem_activation_ARLOCK,
  m_axi_gmem_activation_ARCACHE,
  m_axi_gmem_activation_ARPROT,
  m_axi_gmem_activation_ARQOS,
  m_axi_gmem_activation_ARREGION,
  m_axi_gmem_activation_ARUSER,
  m_axi_gmem_activation_RVALID,
  m_axi_gmem_activation_RREADY,
  m_axi_gmem_activation_RDATA,
  m_axi_gmem_activation_RLAST,
  m_axi_gmem_activation_RID,
  m_axi_gmem_activation_RUSER,
  m_axi_gmem_activation_RRESP,
  m_axi_gmem_activation_BVALID,
  m_axi_gmem_activation_BREADY,
  m_axi_gmem_activation_BRESP,
  m_axi_gmem_activation_BID,
  m_axi_gmem_activation_BUSER,
  m_axi_gmem_observed_AWVALID,
  m_axi_gmem_observed_AWREADY,
  m_axi_gmem_observed_AWADDR,
  m_axi_gmem_observed_AWID,
  m_axi_gmem_observed_AWLEN,
  m_axi_gmem_observed_AWSIZE,
  m_axi_gmem_observed_AWBURST,
  m_axi_gmem_observed_AWLOCK,
  m_axi_gmem_observed_AWCACHE,
  m_axi_gmem_observed_AWPROT,
  m_axi_gmem_observed_AWQOS,
  m_axi_gmem_observed_AWREGION,
  m_axi_gmem_observed_AWUSER,
  m_axi_gmem_observed_WVALID,
  m_axi_gmem_observed_WREADY,
  m_axi_gmem_observed_WDATA,
  m_axi_gmem_observed_WSTRB,
  m_axi_gmem_observed_WLAST,
  m_axi_gmem_observed_WID,
  m_axi_gmem_observed_WUSER,
  m_axi_gmem_observed_ARVALID,
  m_axi_gmem_observed_ARREADY,
  m_axi_gmem_observed_ARADDR,
  m_axi_gmem_observed_ARID,
  m_axi_gmem_observed_ARLEN,
  m_axi_gmem_observed_ARSIZE,
  m_axi_gmem_observed_ARBURST,
  m_axi_gmem_observed_ARLOCK,
  m_axi_gmem_observed_ARCACHE,
  m_axi_gmem_observed_ARPROT,
  m_axi_gmem_observed_ARQOS,
  m_axi_gmem_observed_ARREGION,
  m_axi_gmem_observed_ARUSER,
  m_axi_gmem_observed_RVALID,
  m_axi_gmem_observed_RREADY,
  m_axi_gmem_observed_RDATA,
  m_axi_gmem_observed_RLAST,
  m_axi_gmem_observed_RID,
  m_axi_gmem_observed_RUSER,
  m_axi_gmem_observed_RRESP,
  m_axi_gmem_observed_BVALID,
  m_axi_gmem_observed_BREADY,
  m_axi_gmem_observed_BRESP,
  m_axi_gmem_observed_BID,
  m_axi_gmem_observed_BUSER,
  m_axi_out0_AWADDR,
  m_axi_out0_AWLEN,
  m_axi_out0_AWSIZE,
  m_axi_out0_AWBURST,
  m_axi_out0_AWVALID,
  m_axi_out0_AWREADY,
  m_axi_out0_WDATA,
  m_axi_out0_WSTRB,
  m_axi_out0_WLAST,
  m_axi_out0_WVALID,
  m_axi_out0_WREADY,
  m_axi_out0_BRESP,
  m_axi_out0_BVALID,
  m_axi_out0_BREADY,
  m_axi_out0_AWID,
  m_axi_out0_AWUSER,
  m_axi_out0_WID,
  m_axi_out0_WUSER,
  m_axi_out0_AWLOCK,
  m_axi_out0_AWCACHE,
  m_axi_out0_AWPROT,
  m_axi_out0_AWQOS,
  m_axi_out0_AWREGION,
  m_axi_out1_AWADDR,
  m_axi_out1_AWLEN,
  m_axi_out1_AWSIZE,
  m_axi_out1_AWBURST,
  m_axi_out1_AWVALID,
  m_axi_out1_AWREADY,
  m_axi_out1_WDATA,
  m_axi_out1_WSTRB,
  m_axi_out1_WLAST,
  m_axi_out1_WVALID,
  m_axi_out1_WREADY,
  m_axi_out1_BRESP,
  m_axi_out1_BVALID,
  m_axi_out1_BREADY,
  m_axi_out1_AWID,
  m_axi_out1_AWUSER,
  m_axi_out1_WID,
  m_axi_out1_WUSER,
  m_axi_out1_AWLOCK,
  m_axi_out1_AWCACHE,
  m_axi_out1_AWPROT,
  m_axi_out1_AWQOS,
  m_axi_out1_AWREGION,
  m_axi_observed_trace_AWADDR,
  m_axi_observed_trace_AWLEN,
  m_axi_observed_trace_AWSIZE,
  m_axi_observed_trace_AWBURST,
  m_axi_observed_trace_AWVALID,
  m_axi_observed_trace_AWREADY,
  m_axi_observed_trace_WDATA,
  m_axi_observed_trace_WSTRB,
  m_axi_observed_trace_WLAST,
  m_axi_observed_trace_WVALID,
  m_axi_observed_trace_WREADY,
  m_axi_observed_trace_BRESP,
  m_axi_observed_trace_BVALID,
  m_axi_observed_trace_BREADY,
  m_axi_observed_trace_AWID,
  m_axi_observed_trace_AWUSER,
  m_axi_observed_trace_WID,
  m_axi_observed_trace_WUSER,
  m_axi_observed_trace_AWLOCK,
  m_axi_observed_trace_AWCACHE,
  m_axi_observed_trace_AWPROT,
  m_axi_observed_trace_AWQOS,
  m_axi_observed_trace_AWREGION,
  command_start,
  command_ready,
  command_done,
  command_fault,
  descriptor_base,
  w_q0_base,
  w_q1_base,
  w_scale_base,
  aux_base,
  activation_base,
  observed_base,
  observed_span,
  context_cookie,
  model_generation,
  embedding_base,
  model_bo_bytes,
  model_bo_cookie
);
input wire  ap_clk;
input wire  ap_rst_n;
output wire  m_axi_gmem_descriptor_AWVALID;
input wire  m_axi_gmem_descriptor_AWREADY;
output wire [63:0] m_axi_gmem_descriptor_AWADDR;
output wire [0:0] m_axi_gmem_descriptor_AWID;
output wire [7:0] m_axi_gmem_descriptor_AWLEN;
output wire [2:0] m_axi_gmem_descriptor_AWSIZE;
output wire [1:0] m_axi_gmem_descriptor_AWBURST;
output wire [1:0] m_axi_gmem_descriptor_AWLOCK;
output wire [3:0] m_axi_gmem_descriptor_AWCACHE;
output wire [2:0] m_axi_gmem_descriptor_AWPROT;
output wire [3:0] m_axi_gmem_descriptor_AWQOS;
output wire [3:0] m_axi_gmem_descriptor_AWREGION;
output wire [0:0] m_axi_gmem_descriptor_AWUSER;
output wire  m_axi_gmem_descriptor_WVALID;
input wire  m_axi_gmem_descriptor_WREADY;
output wire [31:0] m_axi_gmem_descriptor_WDATA;
output wire [3:0] m_axi_gmem_descriptor_WSTRB;
output wire  m_axi_gmem_descriptor_WLAST;
output wire [0:0] m_axi_gmem_descriptor_WID;
output wire [0:0] m_axi_gmem_descriptor_WUSER;
output wire  m_axi_gmem_descriptor_ARVALID;
input wire  m_axi_gmem_descriptor_ARREADY;
output wire [63:0] m_axi_gmem_descriptor_ARADDR;
output wire [0:0] m_axi_gmem_descriptor_ARID;
output wire [7:0] m_axi_gmem_descriptor_ARLEN;
output wire [2:0] m_axi_gmem_descriptor_ARSIZE;
output wire [1:0] m_axi_gmem_descriptor_ARBURST;
output wire [1:0] m_axi_gmem_descriptor_ARLOCK;
output wire [3:0] m_axi_gmem_descriptor_ARCACHE;
output wire [2:0] m_axi_gmem_descriptor_ARPROT;
output wire [3:0] m_axi_gmem_descriptor_ARQOS;
output wire [3:0] m_axi_gmem_descriptor_ARREGION;
output wire [0:0] m_axi_gmem_descriptor_ARUSER;
input wire  m_axi_gmem_descriptor_RVALID;
output wire  m_axi_gmem_descriptor_RREADY;
input wire [31:0] m_axi_gmem_descriptor_RDATA;
input wire  m_axi_gmem_descriptor_RLAST;
input wire [0:0] m_axi_gmem_descriptor_RID;
input wire [0:0] m_axi_gmem_descriptor_RUSER;
input wire [1:0] m_axi_gmem_descriptor_RRESP;
input wire  m_axi_gmem_descriptor_BVALID;
output wire  m_axi_gmem_descriptor_BREADY;
input wire [1:0] m_axi_gmem_descriptor_BRESP;
input wire [0:0] m_axi_gmem_descriptor_BID;
input wire [0:0] m_axi_gmem_descriptor_BUSER;
output wire  m_axi_gmem_w_q0_AWVALID;
input wire  m_axi_gmem_w_q0_AWREADY;
output wire [63:0] m_axi_gmem_w_q0_AWADDR;
output wire [0:0] m_axi_gmem_w_q0_AWID;
output wire [7:0] m_axi_gmem_w_q0_AWLEN;
output wire [2:0] m_axi_gmem_w_q0_AWSIZE;
output wire [1:0] m_axi_gmem_w_q0_AWBURST;
output wire [1:0] m_axi_gmem_w_q0_AWLOCK;
output wire [3:0] m_axi_gmem_w_q0_AWCACHE;
output wire [2:0] m_axi_gmem_w_q0_AWPROT;
output wire [3:0] m_axi_gmem_w_q0_AWQOS;
output wire [3:0] m_axi_gmem_w_q0_AWREGION;
output wire [0:0] m_axi_gmem_w_q0_AWUSER;
output wire  m_axi_gmem_w_q0_WVALID;
input wire  m_axi_gmem_w_q0_WREADY;
output wire [511:0] m_axi_gmem_w_q0_WDATA;
output wire [63:0] m_axi_gmem_w_q0_WSTRB;
output wire  m_axi_gmem_w_q0_WLAST;
output wire [0:0] m_axi_gmem_w_q0_WID;
output wire [0:0] m_axi_gmem_w_q0_WUSER;
output wire  m_axi_gmem_w_q0_ARVALID;
input wire  m_axi_gmem_w_q0_ARREADY;
output wire [63:0] m_axi_gmem_w_q0_ARADDR;
output wire [0:0] m_axi_gmem_w_q0_ARID;
output wire [7:0] m_axi_gmem_w_q0_ARLEN;
output wire [2:0] m_axi_gmem_w_q0_ARSIZE;
output wire [1:0] m_axi_gmem_w_q0_ARBURST;
output wire [1:0] m_axi_gmem_w_q0_ARLOCK;
output wire [3:0] m_axi_gmem_w_q0_ARCACHE;
output wire [2:0] m_axi_gmem_w_q0_ARPROT;
output wire [3:0] m_axi_gmem_w_q0_ARQOS;
output wire [3:0] m_axi_gmem_w_q0_ARREGION;
output wire [0:0] m_axi_gmem_w_q0_ARUSER;
input wire  m_axi_gmem_w_q0_RVALID;
output wire  m_axi_gmem_w_q0_RREADY;
input wire [511:0] m_axi_gmem_w_q0_RDATA;
input wire  m_axi_gmem_w_q0_RLAST;
input wire [0:0] m_axi_gmem_w_q0_RID;
input wire [0:0] m_axi_gmem_w_q0_RUSER;
input wire [1:0] m_axi_gmem_w_q0_RRESP;
input wire  m_axi_gmem_w_q0_BVALID;
output wire  m_axi_gmem_w_q0_BREADY;
input wire [1:0] m_axi_gmem_w_q0_BRESP;
input wire [0:0] m_axi_gmem_w_q0_BID;
input wire [0:0] m_axi_gmem_w_q0_BUSER;
output wire  m_axi_gmem_w_q1_AWVALID;
input wire  m_axi_gmem_w_q1_AWREADY;
output wire [63:0] m_axi_gmem_w_q1_AWADDR;
output wire [0:0] m_axi_gmem_w_q1_AWID;
output wire [7:0] m_axi_gmem_w_q1_AWLEN;
output wire [2:0] m_axi_gmem_w_q1_AWSIZE;
output wire [1:0] m_axi_gmem_w_q1_AWBURST;
output wire [1:0] m_axi_gmem_w_q1_AWLOCK;
output wire [3:0] m_axi_gmem_w_q1_AWCACHE;
output wire [2:0] m_axi_gmem_w_q1_AWPROT;
output wire [3:0] m_axi_gmem_w_q1_AWQOS;
output wire [3:0] m_axi_gmem_w_q1_AWREGION;
output wire [0:0] m_axi_gmem_w_q1_AWUSER;
output wire  m_axi_gmem_w_q1_WVALID;
input wire  m_axi_gmem_w_q1_WREADY;
output wire [511:0] m_axi_gmem_w_q1_WDATA;
output wire [63:0] m_axi_gmem_w_q1_WSTRB;
output wire  m_axi_gmem_w_q1_WLAST;
output wire [0:0] m_axi_gmem_w_q1_WID;
output wire [0:0] m_axi_gmem_w_q1_WUSER;
output wire  m_axi_gmem_w_q1_ARVALID;
input wire  m_axi_gmem_w_q1_ARREADY;
output wire [63:0] m_axi_gmem_w_q1_ARADDR;
output wire [0:0] m_axi_gmem_w_q1_ARID;
output wire [7:0] m_axi_gmem_w_q1_ARLEN;
output wire [2:0] m_axi_gmem_w_q1_ARSIZE;
output wire [1:0] m_axi_gmem_w_q1_ARBURST;
output wire [1:0] m_axi_gmem_w_q1_ARLOCK;
output wire [3:0] m_axi_gmem_w_q1_ARCACHE;
output wire [2:0] m_axi_gmem_w_q1_ARPROT;
output wire [3:0] m_axi_gmem_w_q1_ARQOS;
output wire [3:0] m_axi_gmem_w_q1_ARREGION;
output wire [0:0] m_axi_gmem_w_q1_ARUSER;
input wire  m_axi_gmem_w_q1_RVALID;
output wire  m_axi_gmem_w_q1_RREADY;
input wire [511:0] m_axi_gmem_w_q1_RDATA;
input wire  m_axi_gmem_w_q1_RLAST;
input wire [0:0] m_axi_gmem_w_q1_RID;
input wire [0:0] m_axi_gmem_w_q1_RUSER;
input wire [1:0] m_axi_gmem_w_q1_RRESP;
input wire  m_axi_gmem_w_q1_BVALID;
output wire  m_axi_gmem_w_q1_BREADY;
input wire [1:0] m_axi_gmem_w_q1_BRESP;
input wire [0:0] m_axi_gmem_w_q1_BID;
input wire [0:0] m_axi_gmem_w_q1_BUSER;
output wire  m_axi_gmem_w_scale_AWVALID;
input wire  m_axi_gmem_w_scale_AWREADY;
output wire [63:0] m_axi_gmem_w_scale_AWADDR;
output wire [0:0] m_axi_gmem_w_scale_AWID;
output wire [7:0] m_axi_gmem_w_scale_AWLEN;
output wire [2:0] m_axi_gmem_w_scale_AWSIZE;
output wire [1:0] m_axi_gmem_w_scale_AWBURST;
output wire [1:0] m_axi_gmem_w_scale_AWLOCK;
output wire [3:0] m_axi_gmem_w_scale_AWCACHE;
output wire [2:0] m_axi_gmem_w_scale_AWPROT;
output wire [3:0] m_axi_gmem_w_scale_AWQOS;
output wire [3:0] m_axi_gmem_w_scale_AWREGION;
output wire [0:0] m_axi_gmem_w_scale_AWUSER;
output wire  m_axi_gmem_w_scale_WVALID;
input wire  m_axi_gmem_w_scale_WREADY;
output wire [511:0] m_axi_gmem_w_scale_WDATA;
output wire [63:0] m_axi_gmem_w_scale_WSTRB;
output wire  m_axi_gmem_w_scale_WLAST;
output wire [0:0] m_axi_gmem_w_scale_WID;
output wire [0:0] m_axi_gmem_w_scale_WUSER;
output wire  m_axi_gmem_w_scale_ARVALID;
input wire  m_axi_gmem_w_scale_ARREADY;
output wire [63:0] m_axi_gmem_w_scale_ARADDR;
output wire [0:0] m_axi_gmem_w_scale_ARID;
output wire [7:0] m_axi_gmem_w_scale_ARLEN;
output wire [2:0] m_axi_gmem_w_scale_ARSIZE;
output wire [1:0] m_axi_gmem_w_scale_ARBURST;
output wire [1:0] m_axi_gmem_w_scale_ARLOCK;
output wire [3:0] m_axi_gmem_w_scale_ARCACHE;
output wire [2:0] m_axi_gmem_w_scale_ARPROT;
output wire [3:0] m_axi_gmem_w_scale_ARQOS;
output wire [3:0] m_axi_gmem_w_scale_ARREGION;
output wire [0:0] m_axi_gmem_w_scale_ARUSER;
input wire  m_axi_gmem_w_scale_RVALID;
output wire  m_axi_gmem_w_scale_RREADY;
input wire [511:0] m_axi_gmem_w_scale_RDATA;
input wire  m_axi_gmem_w_scale_RLAST;
input wire [0:0] m_axi_gmem_w_scale_RID;
input wire [0:0] m_axi_gmem_w_scale_RUSER;
input wire [1:0] m_axi_gmem_w_scale_RRESP;
input wire  m_axi_gmem_w_scale_BVALID;
output wire  m_axi_gmem_w_scale_BREADY;
input wire [1:0] m_axi_gmem_w_scale_BRESP;
input wire [0:0] m_axi_gmem_w_scale_BID;
input wire [0:0] m_axi_gmem_w_scale_BUSER;
output wire  m_axi_gmem_aux_AWVALID;
input wire  m_axi_gmem_aux_AWREADY;
output wire [63:0] m_axi_gmem_aux_AWADDR;
output wire [0:0] m_axi_gmem_aux_AWID;
output wire [7:0] m_axi_gmem_aux_AWLEN;
output wire [2:0] m_axi_gmem_aux_AWSIZE;
output wire [1:0] m_axi_gmem_aux_AWBURST;
output wire [1:0] m_axi_gmem_aux_AWLOCK;
output wire [3:0] m_axi_gmem_aux_AWCACHE;
output wire [2:0] m_axi_gmem_aux_AWPROT;
output wire [3:0] m_axi_gmem_aux_AWQOS;
output wire [3:0] m_axi_gmem_aux_AWREGION;
output wire [0:0] m_axi_gmem_aux_AWUSER;
output wire  m_axi_gmem_aux_WVALID;
input wire  m_axi_gmem_aux_WREADY;
output wire [31:0] m_axi_gmem_aux_WDATA;
output wire [3:0] m_axi_gmem_aux_WSTRB;
output wire  m_axi_gmem_aux_WLAST;
output wire [0:0] m_axi_gmem_aux_WID;
output wire [0:0] m_axi_gmem_aux_WUSER;
output wire  m_axi_gmem_aux_ARVALID;
input wire  m_axi_gmem_aux_ARREADY;
output wire [63:0] m_axi_gmem_aux_ARADDR;
output wire [0:0] m_axi_gmem_aux_ARID;
output wire [7:0] m_axi_gmem_aux_ARLEN;
output wire [2:0] m_axi_gmem_aux_ARSIZE;
output wire [1:0] m_axi_gmem_aux_ARBURST;
output wire [1:0] m_axi_gmem_aux_ARLOCK;
output wire [3:0] m_axi_gmem_aux_ARCACHE;
output wire [2:0] m_axi_gmem_aux_ARPROT;
output wire [3:0] m_axi_gmem_aux_ARQOS;
output wire [3:0] m_axi_gmem_aux_ARREGION;
output wire [0:0] m_axi_gmem_aux_ARUSER;
input wire  m_axi_gmem_aux_RVALID;
output wire  m_axi_gmem_aux_RREADY;
input wire [31:0] m_axi_gmem_aux_RDATA;
input wire  m_axi_gmem_aux_RLAST;
input wire [0:0] m_axi_gmem_aux_RID;
input wire [0:0] m_axi_gmem_aux_RUSER;
input wire [1:0] m_axi_gmem_aux_RRESP;
input wire  m_axi_gmem_aux_BVALID;
output wire  m_axi_gmem_aux_BREADY;
input wire [1:0] m_axi_gmem_aux_BRESP;
input wire [0:0] m_axi_gmem_aux_BID;
input wire [0:0] m_axi_gmem_aux_BUSER;
output wire  m_axi_gmem_activation_AWVALID;
input wire  m_axi_gmem_activation_AWREADY;
output wire [63:0] m_axi_gmem_activation_AWADDR;
output wire [0:0] m_axi_gmem_activation_AWID;
output wire [7:0] m_axi_gmem_activation_AWLEN;
output wire [2:0] m_axi_gmem_activation_AWSIZE;
output wire [1:0] m_axi_gmem_activation_AWBURST;
output wire [1:0] m_axi_gmem_activation_AWLOCK;
output wire [3:0] m_axi_gmem_activation_AWCACHE;
output wire [2:0] m_axi_gmem_activation_AWPROT;
output wire [3:0] m_axi_gmem_activation_AWQOS;
output wire [3:0] m_axi_gmem_activation_AWREGION;
output wire [0:0] m_axi_gmem_activation_AWUSER;
output wire  m_axi_gmem_activation_WVALID;
input wire  m_axi_gmem_activation_WREADY;
output wire [511:0] m_axi_gmem_activation_WDATA;
output wire [63:0] m_axi_gmem_activation_WSTRB;
output wire  m_axi_gmem_activation_WLAST;
output wire [0:0] m_axi_gmem_activation_WID;
output wire [0:0] m_axi_gmem_activation_WUSER;
output wire  m_axi_gmem_activation_ARVALID;
input wire  m_axi_gmem_activation_ARREADY;
output wire [63:0] m_axi_gmem_activation_ARADDR;
output wire [0:0] m_axi_gmem_activation_ARID;
output wire [7:0] m_axi_gmem_activation_ARLEN;
output wire [2:0] m_axi_gmem_activation_ARSIZE;
output wire [1:0] m_axi_gmem_activation_ARBURST;
output wire [1:0] m_axi_gmem_activation_ARLOCK;
output wire [3:0] m_axi_gmem_activation_ARCACHE;
output wire [2:0] m_axi_gmem_activation_ARPROT;
output wire [3:0] m_axi_gmem_activation_ARQOS;
output wire [3:0] m_axi_gmem_activation_ARREGION;
output wire [0:0] m_axi_gmem_activation_ARUSER;
input wire  m_axi_gmem_activation_RVALID;
output wire  m_axi_gmem_activation_RREADY;
input wire [511:0] m_axi_gmem_activation_RDATA;
input wire  m_axi_gmem_activation_RLAST;
input wire [0:0] m_axi_gmem_activation_RID;
input wire [0:0] m_axi_gmem_activation_RUSER;
input wire [1:0] m_axi_gmem_activation_RRESP;
input wire  m_axi_gmem_activation_BVALID;
output wire  m_axi_gmem_activation_BREADY;
input wire [1:0] m_axi_gmem_activation_BRESP;
input wire [0:0] m_axi_gmem_activation_BID;
input wire [0:0] m_axi_gmem_activation_BUSER;
output wire  m_axi_gmem_observed_AWVALID;
input wire  m_axi_gmem_observed_AWREADY;
output wire [63:0] m_axi_gmem_observed_AWADDR;
output wire [0:0] m_axi_gmem_observed_AWID;
output wire [7:0] m_axi_gmem_observed_AWLEN;
output wire [2:0] m_axi_gmem_observed_AWSIZE;
output wire [1:0] m_axi_gmem_observed_AWBURST;
output wire [1:0] m_axi_gmem_observed_AWLOCK;
output wire [3:0] m_axi_gmem_observed_AWCACHE;
output wire [2:0] m_axi_gmem_observed_AWPROT;
output wire [3:0] m_axi_gmem_observed_AWQOS;
output wire [3:0] m_axi_gmem_observed_AWREGION;
output wire [0:0] m_axi_gmem_observed_AWUSER;
output wire  m_axi_gmem_observed_WVALID;
input wire  m_axi_gmem_observed_WREADY;
output wire [31:0] m_axi_gmem_observed_WDATA;
output wire [3:0] m_axi_gmem_observed_WSTRB;
output wire  m_axi_gmem_observed_WLAST;
output wire [0:0] m_axi_gmem_observed_WID;
output wire [0:0] m_axi_gmem_observed_WUSER;
output wire  m_axi_gmem_observed_ARVALID;
input wire  m_axi_gmem_observed_ARREADY;
output wire [63:0] m_axi_gmem_observed_ARADDR;
output wire [0:0] m_axi_gmem_observed_ARID;
output wire [7:0] m_axi_gmem_observed_ARLEN;
output wire [2:0] m_axi_gmem_observed_ARSIZE;
output wire [1:0] m_axi_gmem_observed_ARBURST;
output wire [1:0] m_axi_gmem_observed_ARLOCK;
output wire [3:0] m_axi_gmem_observed_ARCACHE;
output wire [2:0] m_axi_gmem_observed_ARPROT;
output wire [3:0] m_axi_gmem_observed_ARQOS;
output wire [3:0] m_axi_gmem_observed_ARREGION;
output wire [0:0] m_axi_gmem_observed_ARUSER;
input wire  m_axi_gmem_observed_RVALID;
output wire  m_axi_gmem_observed_RREADY;
input wire [31:0] m_axi_gmem_observed_RDATA;
input wire  m_axi_gmem_observed_RLAST;
input wire [0:0] m_axi_gmem_observed_RID;
input wire [0:0] m_axi_gmem_observed_RUSER;
input wire [1:0] m_axi_gmem_observed_RRESP;
input wire  m_axi_gmem_observed_BVALID;
output wire  m_axi_gmem_observed_BREADY;
input wire [1:0] m_axi_gmem_observed_BRESP;
input wire [0:0] m_axi_gmem_observed_BID;
input wire [0:0] m_axi_gmem_observed_BUSER;
output wire [63:0] m_axi_out0_AWADDR;
output wire [7:0] m_axi_out0_AWLEN;
output wire [2:0] m_axi_out0_AWSIZE;
output wire [1:0] m_axi_out0_AWBURST;
output wire  m_axi_out0_AWVALID;
input wire  m_axi_out0_AWREADY;
output wire [511:0] m_axi_out0_WDATA;
output wire [63:0] m_axi_out0_WSTRB;
output wire  m_axi_out0_WLAST;
output wire  m_axi_out0_WVALID;
input wire  m_axi_out0_WREADY;
input wire [1:0] m_axi_out0_BRESP;
input wire  m_axi_out0_BVALID;
output wire  m_axi_out0_BREADY;
output wire [0:0] m_axi_out0_AWID;
output wire [0:0] m_axi_out0_AWUSER;
output wire [0:0] m_axi_out0_WID;
output wire [0:0] m_axi_out0_WUSER;
output wire [1:0] m_axi_out0_AWLOCK;
output wire [3:0] m_axi_out0_AWCACHE;
output wire [2:0] m_axi_out0_AWPROT;
output wire [3:0] m_axi_out0_AWQOS;
output wire [3:0] m_axi_out0_AWREGION;
output wire [63:0] m_axi_out1_AWADDR;
output wire [7:0] m_axi_out1_AWLEN;
output wire [2:0] m_axi_out1_AWSIZE;
output wire [1:0] m_axi_out1_AWBURST;
output wire  m_axi_out1_AWVALID;
input wire  m_axi_out1_AWREADY;
output wire [511:0] m_axi_out1_WDATA;
output wire [63:0] m_axi_out1_WSTRB;
output wire  m_axi_out1_WLAST;
output wire  m_axi_out1_WVALID;
input wire  m_axi_out1_WREADY;
input wire [1:0] m_axi_out1_BRESP;
input wire  m_axi_out1_BVALID;
output wire  m_axi_out1_BREADY;
output wire [0:0] m_axi_out1_AWID;
output wire [0:0] m_axi_out1_AWUSER;
output wire [0:0] m_axi_out1_WID;
output wire [0:0] m_axi_out1_WUSER;
output wire [1:0] m_axi_out1_AWLOCK;
output wire [3:0] m_axi_out1_AWCACHE;
output wire [2:0] m_axi_out1_AWPROT;
output wire [3:0] m_axi_out1_AWQOS;
output wire [3:0] m_axi_out1_AWREGION;
output wire [63:0] m_axi_observed_trace_AWADDR;
output wire [7:0] m_axi_observed_trace_AWLEN;
output wire [2:0] m_axi_observed_trace_AWSIZE;
output wire [1:0] m_axi_observed_trace_AWBURST;
output wire  m_axi_observed_trace_AWVALID;
input wire  m_axi_observed_trace_AWREADY;
output wire [31:0] m_axi_observed_trace_WDATA;
output wire [3:0] m_axi_observed_trace_WSTRB;
output wire  m_axi_observed_trace_WLAST;
output wire  m_axi_observed_trace_WVALID;
input wire  m_axi_observed_trace_WREADY;
input wire [1:0] m_axi_observed_trace_BRESP;
input wire  m_axi_observed_trace_BVALID;
output wire  m_axi_observed_trace_BREADY;
output wire [0:0] m_axi_observed_trace_AWID;
output wire [0:0] m_axi_observed_trace_AWUSER;
output wire [0:0] m_axi_observed_trace_WID;
output wire [0:0] m_axi_observed_trace_WUSER;
output wire [1:0] m_axi_observed_trace_AWLOCK;
output wire [3:0] m_axi_observed_trace_AWCACHE;
output wire [2:0] m_axi_observed_trace_AWPROT;
output wire [3:0] m_axi_observed_trace_AWQOS;
output wire [3:0] m_axi_observed_trace_AWREGION;
input wire  command_start;
output wire  command_ready;
output wire  command_done;
output wire  command_fault;
input wire [63:0] descriptor_base;
input wire [63:0] w_q0_base;
input wire [63:0] w_q1_base;
input wire [63:0] w_scale_base;
input wire [63:0] aux_base;
input wire [63:0] activation_base;
input wire [63:0] observed_base;
input wire [63:0] observed_span;
input wire [127:0] context_cookie;
input wire [63:0] model_generation;
input wire [63:0] embedding_base;
input wire [319:0] model_bo_bytes;
input wire [319:0] model_bo_cookie;
wire [63:0] binding_context_TDATA;
wire  binding_context_TVALID;
wire  binding_context_TREADY;
wire [255:0] writer_config_TDATA;
wire  writer_config_TVALID;
wire  writer_config_TREADY;
wire [255:0] compute_config_TDATA;
wire  compute_config_TVALID;
wire  compute_config_TREADY;
wire [287:0] bias_tiles_TDATA;
wire  bias_tiles_TVALID;
wire  bias_tiles_TREADY;
wire [2815:0] group_issues_TDATA;
wire  group_issues_TVALID;
wire  group_issues_TREADY;
wire [7:0] finish_r_TDATA;
wire  finish_r_TVALID;
wire  finish_r_TREADY;
wire [511:0] writer_completion_TDATA;
wire  writer_completion_TVALID;
wire  writer_completion_TREADY;
wire  s_axi_control_AWVALID;
wire  s_axi_control_AWREADY;
wire [3:0] s_axi_control_AWADDR;
wire  s_axi_control_WVALID;
wire  s_axi_control_WREADY;
wire [31:0] s_axi_control_WDATA;
wire [3:0] s_axi_control_WSTRB;
wire  s_axi_control_ARVALID;
wire  s_axi_control_ARREADY;
wire [3:0] s_axi_control_ARADDR;
wire  s_axi_control_RVALID;
wire  s_axi_control_RREADY;
wire [31:0] s_axi_control_RDATA;
wire [1:0] s_axi_control_RRESP;
wire  s_axi_control_BVALID;
wire  s_axi_control_BREADY;
wire [1:0] s_axi_control_BRESP;
wire  interrupt;
wire  s_axi_control_r_AWVALID;
wire  s_axi_control_r_AWREADY;
wire [6:0] s_axi_control_r_AWADDR;
wire  s_axi_control_r_WVALID;
wire  s_axi_control_r_WREADY;
wire [31:0] s_axi_control_r_WDATA;
wire [3:0] s_axi_control_r_WSTRB;
wire  s_axi_control_r_ARVALID;
wire  s_axi_control_r_ARREADY;
wire [6:0] s_axi_control_r_ARADDR;
wire  s_axi_control_r_RVALID;
wire  s_axi_control_r_RREADY;
wire [31:0] s_axi_control_r_RDATA;
wire [1:0] s_axi_control_r_RRESP;
wire  s_axi_control_r_BVALID;
wire  s_axi_control_r_BREADY;
wire [1:0] s_axi_control_r_BRESP;
wire [63:0] active_observed_base, active_observed_span;
wire trace_command_start, bridge_debt_zero, bridge_fault;
wire control_fault, hls_axi_debt_zero;
reg hls_axi_fault;
assign command_fault = control_fault || bridge_fault || hls_axi_fault;
reg [15:0] descriptor_read_pending, descriptor_write_pending;
wire descriptor_debt_zero = descriptor_read_pending == 0 &&
  descriptor_write_pending == 0 && !m_axi_gmem_descriptor_ARVALID &&
  !m_axi_gmem_descriptor_RVALID && !m_axi_gmem_descriptor_AWVALID &&
  !m_axi_gmem_descriptor_WVALID && !m_axi_gmem_descriptor_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin descriptor_read_pending <= 0;
    descriptor_write_pending <= 0; end
  else begin descriptor_read_pending <= descriptor_read_pending +
    16'(m_axi_gmem_descriptor_ARVALID && m_axi_gmem_descriptor_ARREADY) -
    16'(m_axi_gmem_descriptor_RVALID && m_axi_gmem_descriptor_RREADY && m_axi_gmem_descriptor_RLAST);
    descriptor_write_pending <= descriptor_write_pending +
    16'(m_axi_gmem_descriptor_AWVALID && m_axi_gmem_descriptor_AWREADY) -
    16'(m_axi_gmem_descriptor_BVALID && m_axi_gmem_descriptor_BREADY); end
end
reg [15:0] w_q0_read_pending, w_q0_write_pending;
wire w_q0_debt_zero = w_q0_read_pending == 0 &&
  w_q0_write_pending == 0 && !m_axi_gmem_w_q0_ARVALID &&
  !m_axi_gmem_w_q0_RVALID && !m_axi_gmem_w_q0_AWVALID &&
  !m_axi_gmem_w_q0_WVALID && !m_axi_gmem_w_q0_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin w_q0_read_pending <= 0;
    w_q0_write_pending <= 0; end
  else begin w_q0_read_pending <= w_q0_read_pending +
    16'(m_axi_gmem_w_q0_ARVALID && m_axi_gmem_w_q0_ARREADY) -
    16'(m_axi_gmem_w_q0_RVALID && m_axi_gmem_w_q0_RREADY && m_axi_gmem_w_q0_RLAST);
    w_q0_write_pending <= w_q0_write_pending +
    16'(m_axi_gmem_w_q0_AWVALID && m_axi_gmem_w_q0_AWREADY) -
    16'(m_axi_gmem_w_q0_BVALID && m_axi_gmem_w_q0_BREADY); end
end
reg [15:0] w_q1_read_pending, w_q1_write_pending;
wire w_q1_debt_zero = w_q1_read_pending == 0 &&
  w_q1_write_pending == 0 && !m_axi_gmem_w_q1_ARVALID &&
  !m_axi_gmem_w_q1_RVALID && !m_axi_gmem_w_q1_AWVALID &&
  !m_axi_gmem_w_q1_WVALID && !m_axi_gmem_w_q1_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin w_q1_read_pending <= 0;
    w_q1_write_pending <= 0; end
  else begin w_q1_read_pending <= w_q1_read_pending +
    16'(m_axi_gmem_w_q1_ARVALID && m_axi_gmem_w_q1_ARREADY) -
    16'(m_axi_gmem_w_q1_RVALID && m_axi_gmem_w_q1_RREADY && m_axi_gmem_w_q1_RLAST);
    w_q1_write_pending <= w_q1_write_pending +
    16'(m_axi_gmem_w_q1_AWVALID && m_axi_gmem_w_q1_AWREADY) -
    16'(m_axi_gmem_w_q1_BVALID && m_axi_gmem_w_q1_BREADY); end
end
reg [15:0] w_scale_read_pending, w_scale_write_pending;
wire w_scale_debt_zero = w_scale_read_pending == 0 &&
  w_scale_write_pending == 0 && !m_axi_gmem_w_scale_ARVALID &&
  !m_axi_gmem_w_scale_RVALID && !m_axi_gmem_w_scale_AWVALID &&
  !m_axi_gmem_w_scale_WVALID && !m_axi_gmem_w_scale_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin w_scale_read_pending <= 0;
    w_scale_write_pending <= 0; end
  else begin w_scale_read_pending <= w_scale_read_pending +
    16'(m_axi_gmem_w_scale_ARVALID && m_axi_gmem_w_scale_ARREADY) -
    16'(m_axi_gmem_w_scale_RVALID && m_axi_gmem_w_scale_RREADY && m_axi_gmem_w_scale_RLAST);
    w_scale_write_pending <= w_scale_write_pending +
    16'(m_axi_gmem_w_scale_AWVALID && m_axi_gmem_w_scale_AWREADY) -
    16'(m_axi_gmem_w_scale_BVALID && m_axi_gmem_w_scale_BREADY); end
end
reg [15:0] aux_read_pending, aux_write_pending;
wire aux_debt_zero = aux_read_pending == 0 &&
  aux_write_pending == 0 && !m_axi_gmem_aux_ARVALID &&
  !m_axi_gmem_aux_RVALID && !m_axi_gmem_aux_AWVALID &&
  !m_axi_gmem_aux_WVALID && !m_axi_gmem_aux_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin aux_read_pending <= 0;
    aux_write_pending <= 0; end
  else begin aux_read_pending <= aux_read_pending +
    16'(m_axi_gmem_aux_ARVALID && m_axi_gmem_aux_ARREADY) -
    16'(m_axi_gmem_aux_RVALID && m_axi_gmem_aux_RREADY && m_axi_gmem_aux_RLAST);
    aux_write_pending <= aux_write_pending +
    16'(m_axi_gmem_aux_AWVALID && m_axi_gmem_aux_AWREADY) -
    16'(m_axi_gmem_aux_BVALID && m_axi_gmem_aux_BREADY); end
end
reg [15:0] activation_read_pending, activation_write_pending;
wire activation_debt_zero = activation_read_pending == 0 &&
  activation_write_pending == 0 && !m_axi_gmem_activation_ARVALID &&
  !m_axi_gmem_activation_RVALID && !m_axi_gmem_activation_AWVALID &&
  !m_axi_gmem_activation_WVALID && !m_axi_gmem_activation_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin activation_read_pending <= 0;
    activation_write_pending <= 0; end
  else begin activation_read_pending <= activation_read_pending +
    16'(m_axi_gmem_activation_ARVALID && m_axi_gmem_activation_ARREADY) -
    16'(m_axi_gmem_activation_RVALID && m_axi_gmem_activation_RREADY && m_axi_gmem_activation_RLAST);
    activation_write_pending <= activation_write_pending +
    16'(m_axi_gmem_activation_AWVALID && m_axi_gmem_activation_AWREADY) -
    16'(m_axi_gmem_activation_BVALID && m_axi_gmem_activation_BREADY); end
end
reg [15:0] observed_read_pending, observed_write_pending;
wire observed_debt_zero = observed_read_pending == 0 &&
  observed_write_pending == 0 && !m_axi_gmem_observed_ARVALID &&
  !m_axi_gmem_observed_RVALID && !m_axi_gmem_observed_AWVALID &&
  !m_axi_gmem_observed_WVALID && !m_axi_gmem_observed_BVALID;
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin observed_read_pending <= 0;
    observed_write_pending <= 0; end
  else begin observed_read_pending <= observed_read_pending +
    16'(m_axi_gmem_observed_ARVALID && m_axi_gmem_observed_ARREADY) -
    16'(m_axi_gmem_observed_RVALID && m_axi_gmem_observed_RREADY && m_axi_gmem_observed_RLAST);
    observed_write_pending <= observed_write_pending +
    16'(m_axi_gmem_observed_AWVALID && m_axi_gmem_observed_AWREADY) -
    16'(m_axi_gmem_observed_BVALID && m_axi_gmem_observed_BREADY); end
end
assign hls_axi_debt_zero = descriptor_debt_zero &&
  w_q0_debt_zero &&
  w_q1_debt_zero &&
  w_scale_debt_zero &&
  aux_debt_zero &&
  activation_debt_zero &&
  observed_debt_zero;
always @(posedge ap_clk) begin
  if (!ap_rst_n) hls_axi_fault <= 1'b0;
  else if ((m_axi_gmem_descriptor_RVALID && m_axi_gmem_descriptor_RREADY && m_axi_gmem_descriptor_RRESP != 0) ||
           (m_axi_gmem_descriptor_BVALID && m_axi_gmem_descriptor_BREADY && m_axi_gmem_descriptor_BRESP != 0) ||
           (m_axi_gmem_w_q0_RVALID && m_axi_gmem_w_q0_RREADY && m_axi_gmem_w_q0_RRESP != 0) ||
           (m_axi_gmem_w_q0_BVALID && m_axi_gmem_w_q0_BREADY && m_axi_gmem_w_q0_BRESP != 0) ||
           (m_axi_gmem_w_q1_RVALID && m_axi_gmem_w_q1_RREADY && m_axi_gmem_w_q1_RRESP != 0) ||
           (m_axi_gmem_w_q1_BVALID && m_axi_gmem_w_q1_BREADY && m_axi_gmem_w_q1_BRESP != 0) ||
           (m_axi_gmem_w_scale_RVALID && m_axi_gmem_w_scale_RREADY && m_axi_gmem_w_scale_RRESP != 0) ||
           (m_axi_gmem_w_scale_BVALID && m_axi_gmem_w_scale_BREADY && m_axi_gmem_w_scale_BRESP != 0) ||
           (m_axi_gmem_aux_RVALID && m_axi_gmem_aux_RREADY && m_axi_gmem_aux_RRESP != 0) ||
           (m_axi_gmem_aux_BVALID && m_axi_gmem_aux_BREADY && m_axi_gmem_aux_BRESP != 0) ||
           (m_axi_gmem_activation_RVALID && m_axi_gmem_activation_RREADY && m_axi_gmem_activation_RRESP != 0) ||
           (m_axi_gmem_activation_BVALID && m_axi_gmem_activation_BREADY && m_axi_gmem_activation_BRESP != 0) ||
           (m_axi_gmem_observed_RVALID && m_axi_gmem_observed_RREADY && m_axi_gmem_observed_RRESP != 0) ||
           (m_axi_gmem_observed_BVALID && m_axi_gmem_observed_BREADY && m_axi_gmem_observed_BRESP != 0)) hls_axi_fault <= 1'b1;
end
q8_tm1tn8_session_dma_v2 engine (
  .ap_clk(ap_clk),
  .ap_rst_n(ap_rst_n),
  .m_axi_gmem_descriptor_AWVALID(m_axi_gmem_descriptor_AWVALID),
  .m_axi_gmem_descriptor_AWREADY(m_axi_gmem_descriptor_AWREADY),
  .m_axi_gmem_descriptor_AWADDR(m_axi_gmem_descriptor_AWADDR),
  .m_axi_gmem_descriptor_AWID(m_axi_gmem_descriptor_AWID),
  .m_axi_gmem_descriptor_AWLEN(m_axi_gmem_descriptor_AWLEN),
  .m_axi_gmem_descriptor_AWSIZE(m_axi_gmem_descriptor_AWSIZE),
  .m_axi_gmem_descriptor_AWBURST(m_axi_gmem_descriptor_AWBURST),
  .m_axi_gmem_descriptor_AWLOCK(m_axi_gmem_descriptor_AWLOCK),
  .m_axi_gmem_descriptor_AWCACHE(m_axi_gmem_descriptor_AWCACHE),
  .m_axi_gmem_descriptor_AWPROT(m_axi_gmem_descriptor_AWPROT),
  .m_axi_gmem_descriptor_AWQOS(m_axi_gmem_descriptor_AWQOS),
  .m_axi_gmem_descriptor_AWREGION(m_axi_gmem_descriptor_AWREGION),
  .m_axi_gmem_descriptor_AWUSER(m_axi_gmem_descriptor_AWUSER),
  .m_axi_gmem_descriptor_WVALID(m_axi_gmem_descriptor_WVALID),
  .m_axi_gmem_descriptor_WREADY(m_axi_gmem_descriptor_WREADY),
  .m_axi_gmem_descriptor_WDATA(m_axi_gmem_descriptor_WDATA),
  .m_axi_gmem_descriptor_WSTRB(m_axi_gmem_descriptor_WSTRB),
  .m_axi_gmem_descriptor_WLAST(m_axi_gmem_descriptor_WLAST),
  .m_axi_gmem_descriptor_WID(m_axi_gmem_descriptor_WID),
  .m_axi_gmem_descriptor_WUSER(m_axi_gmem_descriptor_WUSER),
  .m_axi_gmem_descriptor_ARVALID(m_axi_gmem_descriptor_ARVALID),
  .m_axi_gmem_descriptor_ARREADY(m_axi_gmem_descriptor_ARREADY),
  .m_axi_gmem_descriptor_ARADDR(m_axi_gmem_descriptor_ARADDR),
  .m_axi_gmem_descriptor_ARID(m_axi_gmem_descriptor_ARID),
  .m_axi_gmem_descriptor_ARLEN(m_axi_gmem_descriptor_ARLEN),
  .m_axi_gmem_descriptor_ARSIZE(m_axi_gmem_descriptor_ARSIZE),
  .m_axi_gmem_descriptor_ARBURST(m_axi_gmem_descriptor_ARBURST),
  .m_axi_gmem_descriptor_ARLOCK(m_axi_gmem_descriptor_ARLOCK),
  .m_axi_gmem_descriptor_ARCACHE(m_axi_gmem_descriptor_ARCACHE),
  .m_axi_gmem_descriptor_ARPROT(m_axi_gmem_descriptor_ARPROT),
  .m_axi_gmem_descriptor_ARQOS(m_axi_gmem_descriptor_ARQOS),
  .m_axi_gmem_descriptor_ARREGION(m_axi_gmem_descriptor_ARREGION),
  .m_axi_gmem_descriptor_ARUSER(m_axi_gmem_descriptor_ARUSER),
  .m_axi_gmem_descriptor_RVALID(m_axi_gmem_descriptor_RVALID),
  .m_axi_gmem_descriptor_RREADY(m_axi_gmem_descriptor_RREADY),
  .m_axi_gmem_descriptor_RDATA(m_axi_gmem_descriptor_RDATA),
  .m_axi_gmem_descriptor_RLAST(m_axi_gmem_descriptor_RLAST),
  .m_axi_gmem_descriptor_RID(m_axi_gmem_descriptor_RID),
  .m_axi_gmem_descriptor_RUSER(m_axi_gmem_descriptor_RUSER),
  .m_axi_gmem_descriptor_RRESP(m_axi_gmem_descriptor_RRESP),
  .m_axi_gmem_descriptor_BVALID(m_axi_gmem_descriptor_BVALID),
  .m_axi_gmem_descriptor_BREADY(m_axi_gmem_descriptor_BREADY),
  .m_axi_gmem_descriptor_BRESP(m_axi_gmem_descriptor_BRESP),
  .m_axi_gmem_descriptor_BID(m_axi_gmem_descriptor_BID),
  .m_axi_gmem_descriptor_BUSER(m_axi_gmem_descriptor_BUSER),
  .m_axi_gmem_w_q0_AWVALID(m_axi_gmem_w_q0_AWVALID),
  .m_axi_gmem_w_q0_AWREADY(m_axi_gmem_w_q0_AWREADY),
  .m_axi_gmem_w_q0_AWADDR(m_axi_gmem_w_q0_AWADDR),
  .m_axi_gmem_w_q0_AWID(m_axi_gmem_w_q0_AWID),
  .m_axi_gmem_w_q0_AWLEN(m_axi_gmem_w_q0_AWLEN),
  .m_axi_gmem_w_q0_AWSIZE(m_axi_gmem_w_q0_AWSIZE),
  .m_axi_gmem_w_q0_AWBURST(m_axi_gmem_w_q0_AWBURST),
  .m_axi_gmem_w_q0_AWLOCK(m_axi_gmem_w_q0_AWLOCK),
  .m_axi_gmem_w_q0_AWCACHE(m_axi_gmem_w_q0_AWCACHE),
  .m_axi_gmem_w_q0_AWPROT(m_axi_gmem_w_q0_AWPROT),
  .m_axi_gmem_w_q0_AWQOS(m_axi_gmem_w_q0_AWQOS),
  .m_axi_gmem_w_q0_AWREGION(m_axi_gmem_w_q0_AWREGION),
  .m_axi_gmem_w_q0_AWUSER(m_axi_gmem_w_q0_AWUSER),
  .m_axi_gmem_w_q0_WVALID(m_axi_gmem_w_q0_WVALID),
  .m_axi_gmem_w_q0_WREADY(m_axi_gmem_w_q0_WREADY),
  .m_axi_gmem_w_q0_WDATA(m_axi_gmem_w_q0_WDATA),
  .m_axi_gmem_w_q0_WSTRB(m_axi_gmem_w_q0_WSTRB),
  .m_axi_gmem_w_q0_WLAST(m_axi_gmem_w_q0_WLAST),
  .m_axi_gmem_w_q0_WID(m_axi_gmem_w_q0_WID),
  .m_axi_gmem_w_q0_WUSER(m_axi_gmem_w_q0_WUSER),
  .m_axi_gmem_w_q0_ARVALID(m_axi_gmem_w_q0_ARVALID),
  .m_axi_gmem_w_q0_ARREADY(m_axi_gmem_w_q0_ARREADY),
  .m_axi_gmem_w_q0_ARADDR(m_axi_gmem_w_q0_ARADDR),
  .m_axi_gmem_w_q0_ARID(m_axi_gmem_w_q0_ARID),
  .m_axi_gmem_w_q0_ARLEN(m_axi_gmem_w_q0_ARLEN),
  .m_axi_gmem_w_q0_ARSIZE(m_axi_gmem_w_q0_ARSIZE),
  .m_axi_gmem_w_q0_ARBURST(m_axi_gmem_w_q0_ARBURST),
  .m_axi_gmem_w_q0_ARLOCK(m_axi_gmem_w_q0_ARLOCK),
  .m_axi_gmem_w_q0_ARCACHE(m_axi_gmem_w_q0_ARCACHE),
  .m_axi_gmem_w_q0_ARPROT(m_axi_gmem_w_q0_ARPROT),
  .m_axi_gmem_w_q0_ARQOS(m_axi_gmem_w_q0_ARQOS),
  .m_axi_gmem_w_q0_ARREGION(m_axi_gmem_w_q0_ARREGION),
  .m_axi_gmem_w_q0_ARUSER(m_axi_gmem_w_q0_ARUSER),
  .m_axi_gmem_w_q0_RVALID(m_axi_gmem_w_q0_RVALID),
  .m_axi_gmem_w_q0_RREADY(m_axi_gmem_w_q0_RREADY),
  .m_axi_gmem_w_q0_RDATA(m_axi_gmem_w_q0_RDATA),
  .m_axi_gmem_w_q0_RLAST(m_axi_gmem_w_q0_RLAST),
  .m_axi_gmem_w_q0_RID(m_axi_gmem_w_q0_RID),
  .m_axi_gmem_w_q0_RUSER(m_axi_gmem_w_q0_RUSER),
  .m_axi_gmem_w_q0_RRESP(m_axi_gmem_w_q0_RRESP),
  .m_axi_gmem_w_q0_BVALID(m_axi_gmem_w_q0_BVALID),
  .m_axi_gmem_w_q0_BREADY(m_axi_gmem_w_q0_BREADY),
  .m_axi_gmem_w_q0_BRESP(m_axi_gmem_w_q0_BRESP),
  .m_axi_gmem_w_q0_BID(m_axi_gmem_w_q0_BID),
  .m_axi_gmem_w_q0_BUSER(m_axi_gmem_w_q0_BUSER),
  .m_axi_gmem_w_q1_AWVALID(m_axi_gmem_w_q1_AWVALID),
  .m_axi_gmem_w_q1_AWREADY(m_axi_gmem_w_q1_AWREADY),
  .m_axi_gmem_w_q1_AWADDR(m_axi_gmem_w_q1_AWADDR),
  .m_axi_gmem_w_q1_AWID(m_axi_gmem_w_q1_AWID),
  .m_axi_gmem_w_q1_AWLEN(m_axi_gmem_w_q1_AWLEN),
  .m_axi_gmem_w_q1_AWSIZE(m_axi_gmem_w_q1_AWSIZE),
  .m_axi_gmem_w_q1_AWBURST(m_axi_gmem_w_q1_AWBURST),
  .m_axi_gmem_w_q1_AWLOCK(m_axi_gmem_w_q1_AWLOCK),
  .m_axi_gmem_w_q1_AWCACHE(m_axi_gmem_w_q1_AWCACHE),
  .m_axi_gmem_w_q1_AWPROT(m_axi_gmem_w_q1_AWPROT),
  .m_axi_gmem_w_q1_AWQOS(m_axi_gmem_w_q1_AWQOS),
  .m_axi_gmem_w_q1_AWREGION(m_axi_gmem_w_q1_AWREGION),
  .m_axi_gmem_w_q1_AWUSER(m_axi_gmem_w_q1_AWUSER),
  .m_axi_gmem_w_q1_WVALID(m_axi_gmem_w_q1_WVALID),
  .m_axi_gmem_w_q1_WREADY(m_axi_gmem_w_q1_WREADY),
  .m_axi_gmem_w_q1_WDATA(m_axi_gmem_w_q1_WDATA),
  .m_axi_gmem_w_q1_WSTRB(m_axi_gmem_w_q1_WSTRB),
  .m_axi_gmem_w_q1_WLAST(m_axi_gmem_w_q1_WLAST),
  .m_axi_gmem_w_q1_WID(m_axi_gmem_w_q1_WID),
  .m_axi_gmem_w_q1_WUSER(m_axi_gmem_w_q1_WUSER),
  .m_axi_gmem_w_q1_ARVALID(m_axi_gmem_w_q1_ARVALID),
  .m_axi_gmem_w_q1_ARREADY(m_axi_gmem_w_q1_ARREADY),
  .m_axi_gmem_w_q1_ARADDR(m_axi_gmem_w_q1_ARADDR),
  .m_axi_gmem_w_q1_ARID(m_axi_gmem_w_q1_ARID),
  .m_axi_gmem_w_q1_ARLEN(m_axi_gmem_w_q1_ARLEN),
  .m_axi_gmem_w_q1_ARSIZE(m_axi_gmem_w_q1_ARSIZE),
  .m_axi_gmem_w_q1_ARBURST(m_axi_gmem_w_q1_ARBURST),
  .m_axi_gmem_w_q1_ARLOCK(m_axi_gmem_w_q1_ARLOCK),
  .m_axi_gmem_w_q1_ARCACHE(m_axi_gmem_w_q1_ARCACHE),
  .m_axi_gmem_w_q1_ARPROT(m_axi_gmem_w_q1_ARPROT),
  .m_axi_gmem_w_q1_ARQOS(m_axi_gmem_w_q1_ARQOS),
  .m_axi_gmem_w_q1_ARREGION(m_axi_gmem_w_q1_ARREGION),
  .m_axi_gmem_w_q1_ARUSER(m_axi_gmem_w_q1_ARUSER),
  .m_axi_gmem_w_q1_RVALID(m_axi_gmem_w_q1_RVALID),
  .m_axi_gmem_w_q1_RREADY(m_axi_gmem_w_q1_RREADY),
  .m_axi_gmem_w_q1_RDATA(m_axi_gmem_w_q1_RDATA),
  .m_axi_gmem_w_q1_RLAST(m_axi_gmem_w_q1_RLAST),
  .m_axi_gmem_w_q1_RID(m_axi_gmem_w_q1_RID),
  .m_axi_gmem_w_q1_RUSER(m_axi_gmem_w_q1_RUSER),
  .m_axi_gmem_w_q1_RRESP(m_axi_gmem_w_q1_RRESP),
  .m_axi_gmem_w_q1_BVALID(m_axi_gmem_w_q1_BVALID),
  .m_axi_gmem_w_q1_BREADY(m_axi_gmem_w_q1_BREADY),
  .m_axi_gmem_w_q1_BRESP(m_axi_gmem_w_q1_BRESP),
  .m_axi_gmem_w_q1_BID(m_axi_gmem_w_q1_BID),
  .m_axi_gmem_w_q1_BUSER(m_axi_gmem_w_q1_BUSER),
  .m_axi_gmem_w_scale_AWVALID(m_axi_gmem_w_scale_AWVALID),
  .m_axi_gmem_w_scale_AWREADY(m_axi_gmem_w_scale_AWREADY),
  .m_axi_gmem_w_scale_AWADDR(m_axi_gmem_w_scale_AWADDR),
  .m_axi_gmem_w_scale_AWID(m_axi_gmem_w_scale_AWID),
  .m_axi_gmem_w_scale_AWLEN(m_axi_gmem_w_scale_AWLEN),
  .m_axi_gmem_w_scale_AWSIZE(m_axi_gmem_w_scale_AWSIZE),
  .m_axi_gmem_w_scale_AWBURST(m_axi_gmem_w_scale_AWBURST),
  .m_axi_gmem_w_scale_AWLOCK(m_axi_gmem_w_scale_AWLOCK),
  .m_axi_gmem_w_scale_AWCACHE(m_axi_gmem_w_scale_AWCACHE),
  .m_axi_gmem_w_scale_AWPROT(m_axi_gmem_w_scale_AWPROT),
  .m_axi_gmem_w_scale_AWQOS(m_axi_gmem_w_scale_AWQOS),
  .m_axi_gmem_w_scale_AWREGION(m_axi_gmem_w_scale_AWREGION),
  .m_axi_gmem_w_scale_AWUSER(m_axi_gmem_w_scale_AWUSER),
  .m_axi_gmem_w_scale_WVALID(m_axi_gmem_w_scale_WVALID),
  .m_axi_gmem_w_scale_WREADY(m_axi_gmem_w_scale_WREADY),
  .m_axi_gmem_w_scale_WDATA(m_axi_gmem_w_scale_WDATA),
  .m_axi_gmem_w_scale_WSTRB(m_axi_gmem_w_scale_WSTRB),
  .m_axi_gmem_w_scale_WLAST(m_axi_gmem_w_scale_WLAST),
  .m_axi_gmem_w_scale_WID(m_axi_gmem_w_scale_WID),
  .m_axi_gmem_w_scale_WUSER(m_axi_gmem_w_scale_WUSER),
  .m_axi_gmem_w_scale_ARVALID(m_axi_gmem_w_scale_ARVALID),
  .m_axi_gmem_w_scale_ARREADY(m_axi_gmem_w_scale_ARREADY),
  .m_axi_gmem_w_scale_ARADDR(m_axi_gmem_w_scale_ARADDR),
  .m_axi_gmem_w_scale_ARID(m_axi_gmem_w_scale_ARID),
  .m_axi_gmem_w_scale_ARLEN(m_axi_gmem_w_scale_ARLEN),
  .m_axi_gmem_w_scale_ARSIZE(m_axi_gmem_w_scale_ARSIZE),
  .m_axi_gmem_w_scale_ARBURST(m_axi_gmem_w_scale_ARBURST),
  .m_axi_gmem_w_scale_ARLOCK(m_axi_gmem_w_scale_ARLOCK),
  .m_axi_gmem_w_scale_ARCACHE(m_axi_gmem_w_scale_ARCACHE),
  .m_axi_gmem_w_scale_ARPROT(m_axi_gmem_w_scale_ARPROT),
  .m_axi_gmem_w_scale_ARQOS(m_axi_gmem_w_scale_ARQOS),
  .m_axi_gmem_w_scale_ARREGION(m_axi_gmem_w_scale_ARREGION),
  .m_axi_gmem_w_scale_ARUSER(m_axi_gmem_w_scale_ARUSER),
  .m_axi_gmem_w_scale_RVALID(m_axi_gmem_w_scale_RVALID),
  .m_axi_gmem_w_scale_RREADY(m_axi_gmem_w_scale_RREADY),
  .m_axi_gmem_w_scale_RDATA(m_axi_gmem_w_scale_RDATA),
  .m_axi_gmem_w_scale_RLAST(m_axi_gmem_w_scale_RLAST),
  .m_axi_gmem_w_scale_RID(m_axi_gmem_w_scale_RID),
  .m_axi_gmem_w_scale_RUSER(m_axi_gmem_w_scale_RUSER),
  .m_axi_gmem_w_scale_RRESP(m_axi_gmem_w_scale_RRESP),
  .m_axi_gmem_w_scale_BVALID(m_axi_gmem_w_scale_BVALID),
  .m_axi_gmem_w_scale_BREADY(m_axi_gmem_w_scale_BREADY),
  .m_axi_gmem_w_scale_BRESP(m_axi_gmem_w_scale_BRESP),
  .m_axi_gmem_w_scale_BID(m_axi_gmem_w_scale_BID),
  .m_axi_gmem_w_scale_BUSER(m_axi_gmem_w_scale_BUSER),
  .m_axi_gmem_aux_AWVALID(m_axi_gmem_aux_AWVALID),
  .m_axi_gmem_aux_AWREADY(m_axi_gmem_aux_AWREADY),
  .m_axi_gmem_aux_AWADDR(m_axi_gmem_aux_AWADDR),
  .m_axi_gmem_aux_AWID(m_axi_gmem_aux_AWID),
  .m_axi_gmem_aux_AWLEN(m_axi_gmem_aux_AWLEN),
  .m_axi_gmem_aux_AWSIZE(m_axi_gmem_aux_AWSIZE),
  .m_axi_gmem_aux_AWBURST(m_axi_gmem_aux_AWBURST),
  .m_axi_gmem_aux_AWLOCK(m_axi_gmem_aux_AWLOCK),
  .m_axi_gmem_aux_AWCACHE(m_axi_gmem_aux_AWCACHE),
  .m_axi_gmem_aux_AWPROT(m_axi_gmem_aux_AWPROT),
  .m_axi_gmem_aux_AWQOS(m_axi_gmem_aux_AWQOS),
  .m_axi_gmem_aux_AWREGION(m_axi_gmem_aux_AWREGION),
  .m_axi_gmem_aux_AWUSER(m_axi_gmem_aux_AWUSER),
  .m_axi_gmem_aux_WVALID(m_axi_gmem_aux_WVALID),
  .m_axi_gmem_aux_WREADY(m_axi_gmem_aux_WREADY),
  .m_axi_gmem_aux_WDATA(m_axi_gmem_aux_WDATA),
  .m_axi_gmem_aux_WSTRB(m_axi_gmem_aux_WSTRB),
  .m_axi_gmem_aux_WLAST(m_axi_gmem_aux_WLAST),
  .m_axi_gmem_aux_WID(m_axi_gmem_aux_WID),
  .m_axi_gmem_aux_WUSER(m_axi_gmem_aux_WUSER),
  .m_axi_gmem_aux_ARVALID(m_axi_gmem_aux_ARVALID),
  .m_axi_gmem_aux_ARREADY(m_axi_gmem_aux_ARREADY),
  .m_axi_gmem_aux_ARADDR(m_axi_gmem_aux_ARADDR),
  .m_axi_gmem_aux_ARID(m_axi_gmem_aux_ARID),
  .m_axi_gmem_aux_ARLEN(m_axi_gmem_aux_ARLEN),
  .m_axi_gmem_aux_ARSIZE(m_axi_gmem_aux_ARSIZE),
  .m_axi_gmem_aux_ARBURST(m_axi_gmem_aux_ARBURST),
  .m_axi_gmem_aux_ARLOCK(m_axi_gmem_aux_ARLOCK),
  .m_axi_gmem_aux_ARCACHE(m_axi_gmem_aux_ARCACHE),
  .m_axi_gmem_aux_ARPROT(m_axi_gmem_aux_ARPROT),
  .m_axi_gmem_aux_ARQOS(m_axi_gmem_aux_ARQOS),
  .m_axi_gmem_aux_ARREGION(m_axi_gmem_aux_ARREGION),
  .m_axi_gmem_aux_ARUSER(m_axi_gmem_aux_ARUSER),
  .m_axi_gmem_aux_RVALID(m_axi_gmem_aux_RVALID),
  .m_axi_gmem_aux_RREADY(m_axi_gmem_aux_RREADY),
  .m_axi_gmem_aux_RDATA(m_axi_gmem_aux_RDATA),
  .m_axi_gmem_aux_RLAST(m_axi_gmem_aux_RLAST),
  .m_axi_gmem_aux_RID(m_axi_gmem_aux_RID),
  .m_axi_gmem_aux_RUSER(m_axi_gmem_aux_RUSER),
  .m_axi_gmem_aux_RRESP(m_axi_gmem_aux_RRESP),
  .m_axi_gmem_aux_BVALID(m_axi_gmem_aux_BVALID),
  .m_axi_gmem_aux_BREADY(m_axi_gmem_aux_BREADY),
  .m_axi_gmem_aux_BRESP(m_axi_gmem_aux_BRESP),
  .m_axi_gmem_aux_BID(m_axi_gmem_aux_BID),
  .m_axi_gmem_aux_BUSER(m_axi_gmem_aux_BUSER),
  .m_axi_gmem_activation_AWVALID(m_axi_gmem_activation_AWVALID),
  .m_axi_gmem_activation_AWREADY(m_axi_gmem_activation_AWREADY),
  .m_axi_gmem_activation_AWADDR(m_axi_gmem_activation_AWADDR),
  .m_axi_gmem_activation_AWID(m_axi_gmem_activation_AWID),
  .m_axi_gmem_activation_AWLEN(m_axi_gmem_activation_AWLEN),
  .m_axi_gmem_activation_AWSIZE(m_axi_gmem_activation_AWSIZE),
  .m_axi_gmem_activation_AWBURST(m_axi_gmem_activation_AWBURST),
  .m_axi_gmem_activation_AWLOCK(m_axi_gmem_activation_AWLOCK),
  .m_axi_gmem_activation_AWCACHE(m_axi_gmem_activation_AWCACHE),
  .m_axi_gmem_activation_AWPROT(m_axi_gmem_activation_AWPROT),
  .m_axi_gmem_activation_AWQOS(m_axi_gmem_activation_AWQOS),
  .m_axi_gmem_activation_AWREGION(m_axi_gmem_activation_AWREGION),
  .m_axi_gmem_activation_AWUSER(m_axi_gmem_activation_AWUSER),
  .m_axi_gmem_activation_WVALID(m_axi_gmem_activation_WVALID),
  .m_axi_gmem_activation_WREADY(m_axi_gmem_activation_WREADY),
  .m_axi_gmem_activation_WDATA(m_axi_gmem_activation_WDATA),
  .m_axi_gmem_activation_WSTRB(m_axi_gmem_activation_WSTRB),
  .m_axi_gmem_activation_WLAST(m_axi_gmem_activation_WLAST),
  .m_axi_gmem_activation_WID(m_axi_gmem_activation_WID),
  .m_axi_gmem_activation_WUSER(m_axi_gmem_activation_WUSER),
  .m_axi_gmem_activation_ARVALID(m_axi_gmem_activation_ARVALID),
  .m_axi_gmem_activation_ARREADY(m_axi_gmem_activation_ARREADY),
  .m_axi_gmem_activation_ARADDR(m_axi_gmem_activation_ARADDR),
  .m_axi_gmem_activation_ARID(m_axi_gmem_activation_ARID),
  .m_axi_gmem_activation_ARLEN(m_axi_gmem_activation_ARLEN),
  .m_axi_gmem_activation_ARSIZE(m_axi_gmem_activation_ARSIZE),
  .m_axi_gmem_activation_ARBURST(m_axi_gmem_activation_ARBURST),
  .m_axi_gmem_activation_ARLOCK(m_axi_gmem_activation_ARLOCK),
  .m_axi_gmem_activation_ARCACHE(m_axi_gmem_activation_ARCACHE),
  .m_axi_gmem_activation_ARPROT(m_axi_gmem_activation_ARPROT),
  .m_axi_gmem_activation_ARQOS(m_axi_gmem_activation_ARQOS),
  .m_axi_gmem_activation_ARREGION(m_axi_gmem_activation_ARREGION),
  .m_axi_gmem_activation_ARUSER(m_axi_gmem_activation_ARUSER),
  .m_axi_gmem_activation_RVALID(m_axi_gmem_activation_RVALID),
  .m_axi_gmem_activation_RREADY(m_axi_gmem_activation_RREADY),
  .m_axi_gmem_activation_RDATA(m_axi_gmem_activation_RDATA),
  .m_axi_gmem_activation_RLAST(m_axi_gmem_activation_RLAST),
  .m_axi_gmem_activation_RID(m_axi_gmem_activation_RID),
  .m_axi_gmem_activation_RUSER(m_axi_gmem_activation_RUSER),
  .m_axi_gmem_activation_RRESP(m_axi_gmem_activation_RRESP),
  .m_axi_gmem_activation_BVALID(m_axi_gmem_activation_BVALID),
  .m_axi_gmem_activation_BREADY(m_axi_gmem_activation_BREADY),
  .m_axi_gmem_activation_BRESP(m_axi_gmem_activation_BRESP),
  .m_axi_gmem_activation_BID(m_axi_gmem_activation_BID),
  .m_axi_gmem_activation_BUSER(m_axi_gmem_activation_BUSER),
  .m_axi_gmem_observed_AWVALID(m_axi_gmem_observed_AWVALID),
  .m_axi_gmem_observed_AWREADY(m_axi_gmem_observed_AWREADY),
  .m_axi_gmem_observed_AWADDR(m_axi_gmem_observed_AWADDR),
  .m_axi_gmem_observed_AWID(m_axi_gmem_observed_AWID),
  .m_axi_gmem_observed_AWLEN(m_axi_gmem_observed_AWLEN),
  .m_axi_gmem_observed_AWSIZE(m_axi_gmem_observed_AWSIZE),
  .m_axi_gmem_observed_AWBURST(m_axi_gmem_observed_AWBURST),
  .m_axi_gmem_observed_AWLOCK(m_axi_gmem_observed_AWLOCK),
  .m_axi_gmem_observed_AWCACHE(m_axi_gmem_observed_AWCACHE),
  .m_axi_gmem_observed_AWPROT(m_axi_gmem_observed_AWPROT),
  .m_axi_gmem_observed_AWQOS(m_axi_gmem_observed_AWQOS),
  .m_axi_gmem_observed_AWREGION(m_axi_gmem_observed_AWREGION),
  .m_axi_gmem_observed_AWUSER(m_axi_gmem_observed_AWUSER),
  .m_axi_gmem_observed_WVALID(m_axi_gmem_observed_WVALID),
  .m_axi_gmem_observed_WREADY(m_axi_gmem_observed_WREADY),
  .m_axi_gmem_observed_WDATA(m_axi_gmem_observed_WDATA),
  .m_axi_gmem_observed_WSTRB(m_axi_gmem_observed_WSTRB),
  .m_axi_gmem_observed_WLAST(m_axi_gmem_observed_WLAST),
  .m_axi_gmem_observed_WID(m_axi_gmem_observed_WID),
  .m_axi_gmem_observed_WUSER(m_axi_gmem_observed_WUSER),
  .m_axi_gmem_observed_ARVALID(m_axi_gmem_observed_ARVALID),
  .m_axi_gmem_observed_ARREADY(m_axi_gmem_observed_ARREADY),
  .m_axi_gmem_observed_ARADDR(m_axi_gmem_observed_ARADDR),
  .m_axi_gmem_observed_ARID(m_axi_gmem_observed_ARID),
  .m_axi_gmem_observed_ARLEN(m_axi_gmem_observed_ARLEN),
  .m_axi_gmem_observed_ARSIZE(m_axi_gmem_observed_ARSIZE),
  .m_axi_gmem_observed_ARBURST(m_axi_gmem_observed_ARBURST),
  .m_axi_gmem_observed_ARLOCK(m_axi_gmem_observed_ARLOCK),
  .m_axi_gmem_observed_ARCACHE(m_axi_gmem_observed_ARCACHE),
  .m_axi_gmem_observed_ARPROT(m_axi_gmem_observed_ARPROT),
  .m_axi_gmem_observed_ARQOS(m_axi_gmem_observed_ARQOS),
  .m_axi_gmem_observed_ARREGION(m_axi_gmem_observed_ARREGION),
  .m_axi_gmem_observed_ARUSER(m_axi_gmem_observed_ARUSER),
  .m_axi_gmem_observed_RVALID(m_axi_gmem_observed_RVALID),
  .m_axi_gmem_observed_RREADY(m_axi_gmem_observed_RREADY),
  .m_axi_gmem_observed_RDATA(m_axi_gmem_observed_RDATA),
  .m_axi_gmem_observed_RLAST(m_axi_gmem_observed_RLAST),
  .m_axi_gmem_observed_RID(m_axi_gmem_observed_RID),
  .m_axi_gmem_observed_RUSER(m_axi_gmem_observed_RUSER),
  .m_axi_gmem_observed_RRESP(m_axi_gmem_observed_RRESP),
  .m_axi_gmem_observed_BVALID(m_axi_gmem_observed_BVALID),
  .m_axi_gmem_observed_BREADY(m_axi_gmem_observed_BREADY),
  .m_axi_gmem_observed_BRESP(m_axi_gmem_observed_BRESP),
  .m_axi_gmem_observed_BID(m_axi_gmem_observed_BID),
  .m_axi_gmem_observed_BUSER(m_axi_gmem_observed_BUSER),
  .binding_context_TDATA(binding_context_TDATA),
  .binding_context_TVALID(binding_context_TVALID),
  .binding_context_TREADY(binding_context_TREADY),
  .writer_config_TDATA(writer_config_TDATA),
  .writer_config_TVALID(writer_config_TVALID),
  .writer_config_TREADY(writer_config_TREADY),
  .compute_config_TDATA(compute_config_TDATA),
  .compute_config_TVALID(compute_config_TVALID),
  .compute_config_TREADY(compute_config_TREADY),
  .bias_tiles_TDATA(bias_tiles_TDATA),
  .bias_tiles_TVALID(bias_tiles_TVALID),
  .bias_tiles_TREADY(bias_tiles_TREADY),
  .group_issues_TDATA(group_issues_TDATA),
  .group_issues_TVALID(group_issues_TVALID),
  .group_issues_TREADY(group_issues_TREADY),
  .finish_r_TDATA(finish_r_TDATA),
  .finish_r_TVALID(finish_r_TVALID),
  .finish_r_TREADY(finish_r_TREADY),
  .writer_completion_TDATA(writer_completion_TDATA),
  .writer_completion_TVALID(writer_completion_TVALID),
  .writer_completion_TREADY(writer_completion_TREADY),
  .s_axi_control_AWVALID(s_axi_control_AWVALID),
  .s_axi_control_AWREADY(s_axi_control_AWREADY),
  .s_axi_control_AWADDR(s_axi_control_AWADDR),
  .s_axi_control_WVALID(s_axi_control_WVALID),
  .s_axi_control_WREADY(s_axi_control_WREADY),
  .s_axi_control_WDATA(s_axi_control_WDATA),
  .s_axi_control_WSTRB(s_axi_control_WSTRB),
  .s_axi_control_ARVALID(s_axi_control_ARVALID),
  .s_axi_control_ARREADY(s_axi_control_ARREADY),
  .s_axi_control_ARADDR(s_axi_control_ARADDR),
  .s_axi_control_RVALID(s_axi_control_RVALID),
  .s_axi_control_RREADY(s_axi_control_RREADY),
  .s_axi_control_RDATA(s_axi_control_RDATA),
  .s_axi_control_RRESP(s_axi_control_RRESP),
  .s_axi_control_BVALID(s_axi_control_BVALID),
  .s_axi_control_BREADY(s_axi_control_BREADY),
  .s_axi_control_BRESP(s_axi_control_BRESP),
  .interrupt(interrupt),
  .s_axi_control_r_AWVALID(s_axi_control_r_AWVALID),
  .s_axi_control_r_AWREADY(s_axi_control_r_AWREADY),
  .s_axi_control_r_AWADDR(s_axi_control_r_AWADDR),
  .s_axi_control_r_WVALID(s_axi_control_r_WVALID),
  .s_axi_control_r_WREADY(s_axi_control_r_WREADY),
  .s_axi_control_r_WDATA(s_axi_control_r_WDATA),
  .s_axi_control_r_WSTRB(s_axi_control_r_WSTRB),
  .s_axi_control_r_ARVALID(s_axi_control_r_ARVALID),
  .s_axi_control_r_ARREADY(s_axi_control_r_ARREADY),
  .s_axi_control_r_ARADDR(s_axi_control_r_ARADDR),
  .s_axi_control_r_RVALID(s_axi_control_r_RVALID),
  .s_axi_control_r_RREADY(s_axi_control_r_RREADY),
  .s_axi_control_r_RDATA(s_axi_control_r_RDATA),
  .s_axi_control_r_RRESP(s_axi_control_r_RRESP),
  .s_axi_control_r_BVALID(s_axi_control_r_BVALID),
  .s_axi_control_r_BREADY(s_axi_control_r_BREADY),
  .s_axi_control_r_BRESP(s_axi_control_r_BRESP)
);
tm1tn8_hls_control_v2 #(
  .ARG_ADDR_W(7),
  .ADDR_DESCRIPTOR_LO(7'h10),
  .ADDR_DESCRIPTOR_HI(7'h14),
  .ADDR_W_Q0_LO(7'h1c),
  .ADDR_W_Q0_HI(7'h20),
  .ADDR_W_Q1_LO(7'h28),
  .ADDR_W_Q1_HI(7'h2c),
  .ADDR_W_SCALE_LO(7'h34),
  .ADDR_W_SCALE_HI(7'h38),
  .ADDR_AUX_LO(7'h40),
  .ADDR_AUX_HI(7'h44),
  .ADDR_ACTIVATION_LO(7'h4c),
  .ADDR_ACTIVATION_HI(7'h50),
  .ADDR_OBSERVED_LO(7'h58),
  .ADDR_OBSERVED_HI(7'h5c)
) controller (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .command_start(command_start),
  .command_ready(command_ready),
  .command_done(command_done),
  .command_fault(control_fault),
  .observed_span(observed_span),
  .all_writer_debt_zero(bridge_debt_zero),
  .hls_axi_debt_zero(hls_axi_debt_zero),
  .external_fault(bridge_fault || hls_axi_fault),
  .context_cookie(context_cookie),
  .model_generation(model_generation),
  .embedding_base(embedding_base),
  .model_bo_bytes(model_bo_bytes),
  .model_bo_cookie(model_bo_cookie),
  .binding_context_tdata(binding_context_TDATA),
  .binding_context_tvalid(binding_context_TVALID),
  .binding_context_tready(binding_context_TREADY),
  .descriptor_base(descriptor_base),
  .w_q0_base(w_q0_base),
  .w_q1_base(w_q1_base),
  .w_scale_base(w_scale_base),
  .aux_base(aux_base),
  .activation_base(activation_base),
  .observed_base(observed_base),
  .active_observed_base(active_observed_base),
  .active_observed_span(active_observed_span),
  .trace_command_start(trace_command_start),
  .arg_awaddr(s_axi_control_r_AWADDR),
  .arg_awvalid(s_axi_control_r_AWVALID),
  .arg_awready(s_axi_control_r_AWREADY),
  .arg_wdata(s_axi_control_r_WDATA),
  .arg_wstrb(s_axi_control_r_WSTRB),
  .arg_wvalid(s_axi_control_r_WVALID),
  .arg_wready(s_axi_control_r_WREADY),
  .arg_bresp(s_axi_control_r_BRESP),
  .arg_bvalid(s_axi_control_r_BVALID),
  .arg_bready(s_axi_control_r_BREADY),
  .arg_araddr(s_axi_control_r_ARADDR),
  .arg_arvalid(s_axi_control_r_ARVALID),
  .arg_arready(s_axi_control_r_ARREADY),
  .arg_rdata(s_axi_control_r_RDATA),
  .arg_rresp(s_axi_control_r_RRESP),
  .arg_rvalid(s_axi_control_r_RVALID),
  .arg_rready(s_axi_control_r_RREADY),
  .ctrl_awaddr(s_axi_control_AWADDR),
  .ctrl_awvalid(s_axi_control_AWVALID),
  .ctrl_awready(s_axi_control_AWREADY),
  .ctrl_wdata(s_axi_control_WDATA),
  .ctrl_wstrb(s_axi_control_WSTRB),
  .ctrl_wvalid(s_axi_control_WVALID),
  .ctrl_wready(s_axi_control_WREADY),
  .ctrl_bresp(s_axi_control_BRESP),
  .ctrl_bvalid(s_axi_control_BVALID),
  .ctrl_bready(s_axi_control_BREADY),
  .ctrl_araddr(s_axi_control_ARADDR),
  .ctrl_arvalid(s_axi_control_ARVALID),
  .ctrl_arready(s_axi_control_ARREADY),
  .ctrl_rdata(s_axi_control_RDATA),
  .ctrl_rresp(s_axi_control_RRESP),
  .ctrl_rvalid(s_axi_control_RVALID),
  .ctrl_rready(s_axi_control_RREADY)
);
tm1tn8_joint_bridge bridge (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .cfg_tdata(writer_config_TDATA),
  .cfg_tvalid(writer_config_TVALID),
  .cfg_tready(writer_config_TREADY),
  .compute_cfg_tdata(compute_config_TDATA),
  .compute_cfg_tvalid(compute_config_TVALID),
  .compute_cfg_tready(compute_config_TREADY),
  .bias_tdata(bias_tiles_TDATA),
  .bias_tvalid(bias_tiles_TVALID),
  .bias_tready(bias_tiles_TREADY),
  .group_tdata(group_issues_TDATA),
  .group_tvalid(group_issues_TVALID),
  .group_tready(group_issues_TREADY),
  .finish_tvalid(finish_r_TVALID),
  .finish_tready(finish_r_TREADY),
  .completion_tdata(writer_completion_TDATA),
  .completion_tvalid(writer_completion_TVALID),
  .completion_tready(writer_completion_TREADY),
  .observed_base(active_observed_base),
  .observed_span(active_observed_span),
  .trace_command_start(trace_command_start),
  .all_writer_debt_zero(bridge_debt_zero),
  .any_writer_fault(bridge_fault),
  .m0_awaddr(m_axi_out0_AWADDR),
  .m0_awlen(m_axi_out0_AWLEN),
  .m0_awsize(m_axi_out0_AWSIZE),
  .m0_awburst(m_axi_out0_AWBURST),
  .m0_awvalid(m_axi_out0_AWVALID),
  .m0_awready(m_axi_out0_AWREADY),
  .m0_wdata(m_axi_out0_WDATA),
  .m0_wstrb(m_axi_out0_WSTRB),
  .m0_wlast(m_axi_out0_WLAST),
  .m0_wvalid(m_axi_out0_WVALID),
  .m0_wready(m_axi_out0_WREADY),
  .m0_bresp(m_axi_out0_BRESP),
  .m0_bvalid(m_axi_out0_BVALID),
  .m0_bready(m_axi_out0_BREADY),
  .m1_awaddr(m_axi_out1_AWADDR),
  .m1_awlen(m_axi_out1_AWLEN),
  .m1_awsize(m_axi_out1_AWSIZE),
  .m1_awburst(m_axi_out1_AWBURST),
  .m1_awvalid(m_axi_out1_AWVALID),
  .m1_awready(m_axi_out1_AWREADY),
  .m1_wdata(m_axi_out1_WDATA),
  .m1_wstrb(m_axi_out1_WSTRB),
  .m1_wlast(m_axi_out1_WLAST),
  .m1_wvalid(m_axi_out1_WVALID),
  .m1_wready(m_axi_out1_WREADY),
  .m1_bresp(m_axi_out1_BRESP),
  .m1_bvalid(m_axi_out1_BVALID),
  .m1_bready(m_axi_out1_BREADY),
  .observed_awaddr(m_axi_observed_trace_AWADDR),
  .observed_awlen(m_axi_observed_trace_AWLEN),
  .observed_awsize(m_axi_observed_trace_AWSIZE),
  .observed_awburst(m_axi_observed_trace_AWBURST),
  .observed_awvalid(m_axi_observed_trace_AWVALID),
  .observed_awready(m_axi_observed_trace_AWREADY),
  .observed_wdata(m_axi_observed_trace_WDATA),
  .observed_wstrb(m_axi_observed_trace_WSTRB),
  .observed_wlast(m_axi_observed_trace_WLAST),
  .observed_wvalid(m_axi_observed_trace_WVALID),
  .observed_wready(m_axi_observed_trace_WREADY),
  .observed_bresp(m_axi_observed_trace_BRESP),
  .observed_bvalid(m_axi_observed_trace_BVALID),
  .observed_bready(m_axi_observed_trace_BREADY)
);
assign m_axi_out0_AWID = 1'b0;
assign m_axi_out0_AWLOCK = 2'b00;
assign m_axi_out0_AWCACHE = 4'b0011;
assign m_axi_out0_AWPROT = 3'b000;
assign m_axi_out0_AWQOS = 4'b0000;
assign m_axi_out0_AWREGION = 4'b0000;
assign m_axi_out0_AWUSER = 1'b0;
assign m_axi_out0_WID = 1'b0;
assign m_axi_out0_WUSER = 1'b0;
assign m_axi_out1_AWID = 1'b0;
assign m_axi_out1_AWLOCK = 2'b00;
assign m_axi_out1_AWCACHE = 4'b0011;
assign m_axi_out1_AWPROT = 3'b000;
assign m_axi_out1_AWQOS = 4'b0000;
assign m_axi_out1_AWREGION = 4'b0000;
assign m_axi_out1_AWUSER = 1'b0;
assign m_axi_out1_WID = 1'b0;
assign m_axi_out1_WUSER = 1'b0;
assign m_axi_observed_trace_AWID = 1'b0;
assign m_axi_observed_trace_AWLOCK = 2'b00;
assign m_axi_observed_trace_AWCACHE = 4'b0011;
assign m_axi_observed_trace_AWPROT = 3'b000;
assign m_axi_observed_trace_AWQOS = 4'b0000;
assign m_axi_observed_trace_AWREGION = 4'b0000;
assign m_axi_observed_trace_AWUSER = 1'b0;
assign m_axi_observed_trace_WID = 1'b0;
assign m_axi_observed_trace_WUSER = 1'b0;
endmodule
