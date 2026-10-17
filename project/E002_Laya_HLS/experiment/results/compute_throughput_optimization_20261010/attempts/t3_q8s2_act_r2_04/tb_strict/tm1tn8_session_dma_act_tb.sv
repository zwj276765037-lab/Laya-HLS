`timescale 1ns/1ps
module tm1tn8_session_dma_act_tb;
  logic  ap_clk;
  logic  ap_rst_n;
  logic  m_axi_gmem_descriptor_AWVALID;
  logic  m_axi_gmem_descriptor_AWREADY;
  logic [63:0] m_axi_gmem_descriptor_AWADDR;
  logic [0:0] m_axi_gmem_descriptor_AWID;
  logic [7:0] m_axi_gmem_descriptor_AWLEN;
  logic [2:0] m_axi_gmem_descriptor_AWSIZE;
  logic [1:0] m_axi_gmem_descriptor_AWBURST;
  logic [1:0] m_axi_gmem_descriptor_AWLOCK;
  logic [3:0] m_axi_gmem_descriptor_AWCACHE;
  logic [2:0] m_axi_gmem_descriptor_AWPROT;
  logic [3:0] m_axi_gmem_descriptor_AWQOS;
  logic [3:0] m_axi_gmem_descriptor_AWREGION;
  logic [0:0] m_axi_gmem_descriptor_AWUSER;
  logic  m_axi_gmem_descriptor_WVALID;
  logic  m_axi_gmem_descriptor_WREADY;
  logic [31:0] m_axi_gmem_descriptor_WDATA;
  logic [3:0] m_axi_gmem_descriptor_WSTRB;
  logic  m_axi_gmem_descriptor_WLAST;
  logic [0:0] m_axi_gmem_descriptor_WID;
  logic [0:0] m_axi_gmem_descriptor_WUSER;
  logic  m_axi_gmem_descriptor_ARVALID;
  logic  m_axi_gmem_descriptor_ARREADY;
  logic [63:0] m_axi_gmem_descriptor_ARADDR;
  logic [0:0] m_axi_gmem_descriptor_ARID;
  logic [7:0] m_axi_gmem_descriptor_ARLEN;
  logic [2:0] m_axi_gmem_descriptor_ARSIZE;
  logic [1:0] m_axi_gmem_descriptor_ARBURST;
  logic [1:0] m_axi_gmem_descriptor_ARLOCK;
  logic [3:0] m_axi_gmem_descriptor_ARCACHE;
  logic [2:0] m_axi_gmem_descriptor_ARPROT;
  logic [3:0] m_axi_gmem_descriptor_ARQOS;
  logic [3:0] m_axi_gmem_descriptor_ARREGION;
  logic [0:0] m_axi_gmem_descriptor_ARUSER;
  logic  m_axi_gmem_descriptor_RVALID;
  logic  m_axi_gmem_descriptor_RREADY;
  logic [31:0] m_axi_gmem_descriptor_RDATA;
  logic  m_axi_gmem_descriptor_RLAST;
  logic [0:0] m_axi_gmem_descriptor_RID;
  logic [0:0] m_axi_gmem_descriptor_RUSER;
  logic [1:0] m_axi_gmem_descriptor_RRESP;
  logic  m_axi_gmem_descriptor_BVALID;
  logic  m_axi_gmem_descriptor_BREADY;
  logic [1:0] m_axi_gmem_descriptor_BRESP;
  logic [0:0] m_axi_gmem_descriptor_BID;
  logic [0:0] m_axi_gmem_descriptor_BUSER;
  logic  m_axi_gmem_w_q0_AWVALID;
  logic  m_axi_gmem_w_q0_AWREADY;
  logic [63:0] m_axi_gmem_w_q0_AWADDR;
  logic [0:0] m_axi_gmem_w_q0_AWID;
  logic [7:0] m_axi_gmem_w_q0_AWLEN;
  logic [2:0] m_axi_gmem_w_q0_AWSIZE;
  logic [1:0] m_axi_gmem_w_q0_AWBURST;
  logic [1:0] m_axi_gmem_w_q0_AWLOCK;
  logic [3:0] m_axi_gmem_w_q0_AWCACHE;
  logic [2:0] m_axi_gmem_w_q0_AWPROT;
  logic [3:0] m_axi_gmem_w_q0_AWQOS;
  logic [3:0] m_axi_gmem_w_q0_AWREGION;
  logic [0:0] m_axi_gmem_w_q0_AWUSER;
  logic  m_axi_gmem_w_q0_WVALID;
  logic  m_axi_gmem_w_q0_WREADY;
  logic [511:0] m_axi_gmem_w_q0_WDATA;
  logic [63:0] m_axi_gmem_w_q0_WSTRB;
  logic  m_axi_gmem_w_q0_WLAST;
  logic [0:0] m_axi_gmem_w_q0_WID;
  logic [0:0] m_axi_gmem_w_q0_WUSER;
  logic  m_axi_gmem_w_q0_ARVALID;
  logic  m_axi_gmem_w_q0_ARREADY;
  logic [63:0] m_axi_gmem_w_q0_ARADDR;
  logic [0:0] m_axi_gmem_w_q0_ARID;
  logic [7:0] m_axi_gmem_w_q0_ARLEN;
  logic [2:0] m_axi_gmem_w_q0_ARSIZE;
  logic [1:0] m_axi_gmem_w_q0_ARBURST;
  logic [1:0] m_axi_gmem_w_q0_ARLOCK;
  logic [3:0] m_axi_gmem_w_q0_ARCACHE;
  logic [2:0] m_axi_gmem_w_q0_ARPROT;
  logic [3:0] m_axi_gmem_w_q0_ARQOS;
  logic [3:0] m_axi_gmem_w_q0_ARREGION;
  logic [0:0] m_axi_gmem_w_q0_ARUSER;
  logic  m_axi_gmem_w_q0_RVALID;
  logic  m_axi_gmem_w_q0_RREADY;
  logic [511:0] m_axi_gmem_w_q0_RDATA;
  logic  m_axi_gmem_w_q0_RLAST;
  logic [0:0] m_axi_gmem_w_q0_RID;
  logic [0:0] m_axi_gmem_w_q0_RUSER;
  logic [1:0] m_axi_gmem_w_q0_RRESP;
  logic  m_axi_gmem_w_q0_BVALID;
  logic  m_axi_gmem_w_q0_BREADY;
  logic [1:0] m_axi_gmem_w_q0_BRESP;
  logic [0:0] m_axi_gmem_w_q0_BID;
  logic [0:0] m_axi_gmem_w_q0_BUSER;
  logic  m_axi_gmem_w_q1_AWVALID;
  logic  m_axi_gmem_w_q1_AWREADY;
  logic [63:0] m_axi_gmem_w_q1_AWADDR;
  logic [0:0] m_axi_gmem_w_q1_AWID;
  logic [7:0] m_axi_gmem_w_q1_AWLEN;
  logic [2:0] m_axi_gmem_w_q1_AWSIZE;
  logic [1:0] m_axi_gmem_w_q1_AWBURST;
  logic [1:0] m_axi_gmem_w_q1_AWLOCK;
  logic [3:0] m_axi_gmem_w_q1_AWCACHE;
  logic [2:0] m_axi_gmem_w_q1_AWPROT;
  logic [3:0] m_axi_gmem_w_q1_AWQOS;
  logic [3:0] m_axi_gmem_w_q1_AWREGION;
  logic [0:0] m_axi_gmem_w_q1_AWUSER;
  logic  m_axi_gmem_w_q1_WVALID;
  logic  m_axi_gmem_w_q1_WREADY;
  logic [511:0] m_axi_gmem_w_q1_WDATA;
  logic [63:0] m_axi_gmem_w_q1_WSTRB;
  logic  m_axi_gmem_w_q1_WLAST;
  logic [0:0] m_axi_gmem_w_q1_WID;
  logic [0:0] m_axi_gmem_w_q1_WUSER;
  logic  m_axi_gmem_w_q1_ARVALID;
  logic  m_axi_gmem_w_q1_ARREADY;
  logic [63:0] m_axi_gmem_w_q1_ARADDR;
  logic [0:0] m_axi_gmem_w_q1_ARID;
  logic [7:0] m_axi_gmem_w_q1_ARLEN;
  logic [2:0] m_axi_gmem_w_q1_ARSIZE;
  logic [1:0] m_axi_gmem_w_q1_ARBURST;
  logic [1:0] m_axi_gmem_w_q1_ARLOCK;
  logic [3:0] m_axi_gmem_w_q1_ARCACHE;
  logic [2:0] m_axi_gmem_w_q1_ARPROT;
  logic [3:0] m_axi_gmem_w_q1_ARQOS;
  logic [3:0] m_axi_gmem_w_q1_ARREGION;
  logic [0:0] m_axi_gmem_w_q1_ARUSER;
  logic  m_axi_gmem_w_q1_RVALID;
  logic  m_axi_gmem_w_q1_RREADY;
  logic [511:0] m_axi_gmem_w_q1_RDATA;
  logic  m_axi_gmem_w_q1_RLAST;
  logic [0:0] m_axi_gmem_w_q1_RID;
  logic [0:0] m_axi_gmem_w_q1_RUSER;
  logic [1:0] m_axi_gmem_w_q1_RRESP;
  logic  m_axi_gmem_w_q1_BVALID;
  logic  m_axi_gmem_w_q1_BREADY;
  logic [1:0] m_axi_gmem_w_q1_BRESP;
  logic [0:0] m_axi_gmem_w_q1_BID;
  logic [0:0] m_axi_gmem_w_q1_BUSER;
  logic  m_axi_gmem_w_scale_AWVALID;
  logic  m_axi_gmem_w_scale_AWREADY;
  logic [63:0] m_axi_gmem_w_scale_AWADDR;
  logic [0:0] m_axi_gmem_w_scale_AWID;
  logic [7:0] m_axi_gmem_w_scale_AWLEN;
  logic [2:0] m_axi_gmem_w_scale_AWSIZE;
  logic [1:0] m_axi_gmem_w_scale_AWBURST;
  logic [1:0] m_axi_gmem_w_scale_AWLOCK;
  logic [3:0] m_axi_gmem_w_scale_AWCACHE;
  logic [2:0] m_axi_gmem_w_scale_AWPROT;
  logic [3:0] m_axi_gmem_w_scale_AWQOS;
  logic [3:0] m_axi_gmem_w_scale_AWREGION;
  logic [0:0] m_axi_gmem_w_scale_AWUSER;
  logic  m_axi_gmem_w_scale_WVALID;
  logic  m_axi_gmem_w_scale_WREADY;
  logic [511:0] m_axi_gmem_w_scale_WDATA;
  logic [63:0] m_axi_gmem_w_scale_WSTRB;
  logic  m_axi_gmem_w_scale_WLAST;
  logic [0:0] m_axi_gmem_w_scale_WID;
  logic [0:0] m_axi_gmem_w_scale_WUSER;
  logic  m_axi_gmem_w_scale_ARVALID;
  logic  m_axi_gmem_w_scale_ARREADY;
  logic [63:0] m_axi_gmem_w_scale_ARADDR;
  logic [0:0] m_axi_gmem_w_scale_ARID;
  logic [7:0] m_axi_gmem_w_scale_ARLEN;
  logic [2:0] m_axi_gmem_w_scale_ARSIZE;
  logic [1:0] m_axi_gmem_w_scale_ARBURST;
  logic [1:0] m_axi_gmem_w_scale_ARLOCK;
  logic [3:0] m_axi_gmem_w_scale_ARCACHE;
  logic [2:0] m_axi_gmem_w_scale_ARPROT;
  logic [3:0] m_axi_gmem_w_scale_ARQOS;
  logic [3:0] m_axi_gmem_w_scale_ARREGION;
  logic [0:0] m_axi_gmem_w_scale_ARUSER;
  logic  m_axi_gmem_w_scale_RVALID;
  logic  m_axi_gmem_w_scale_RREADY;
  logic [511:0] m_axi_gmem_w_scale_RDATA;
  logic  m_axi_gmem_w_scale_RLAST;
  logic [0:0] m_axi_gmem_w_scale_RID;
  logic [0:0] m_axi_gmem_w_scale_RUSER;
  logic [1:0] m_axi_gmem_w_scale_RRESP;
  logic  m_axi_gmem_w_scale_BVALID;
  logic  m_axi_gmem_w_scale_BREADY;
  logic [1:0] m_axi_gmem_w_scale_BRESP;
  logic [0:0] m_axi_gmem_w_scale_BID;
  logic [0:0] m_axi_gmem_w_scale_BUSER;
  logic  m_axi_gmem_aux_AWVALID;
  logic  m_axi_gmem_aux_AWREADY;
  logic [63:0] m_axi_gmem_aux_AWADDR;
  logic [0:0] m_axi_gmem_aux_AWID;
  logic [7:0] m_axi_gmem_aux_AWLEN;
  logic [2:0] m_axi_gmem_aux_AWSIZE;
  logic [1:0] m_axi_gmem_aux_AWBURST;
  logic [1:0] m_axi_gmem_aux_AWLOCK;
  logic [3:0] m_axi_gmem_aux_AWCACHE;
  logic [2:0] m_axi_gmem_aux_AWPROT;
  logic [3:0] m_axi_gmem_aux_AWQOS;
  logic [3:0] m_axi_gmem_aux_AWREGION;
  logic [0:0] m_axi_gmem_aux_AWUSER;
  logic  m_axi_gmem_aux_WVALID;
  logic  m_axi_gmem_aux_WREADY;
  logic [31:0] m_axi_gmem_aux_WDATA;
  logic [3:0] m_axi_gmem_aux_WSTRB;
  logic  m_axi_gmem_aux_WLAST;
  logic [0:0] m_axi_gmem_aux_WID;
  logic [0:0] m_axi_gmem_aux_WUSER;
  logic  m_axi_gmem_aux_ARVALID;
  logic  m_axi_gmem_aux_ARREADY;
  logic [63:0] m_axi_gmem_aux_ARADDR;
  logic [0:0] m_axi_gmem_aux_ARID;
  logic [7:0] m_axi_gmem_aux_ARLEN;
  logic [2:0] m_axi_gmem_aux_ARSIZE;
  logic [1:0] m_axi_gmem_aux_ARBURST;
  logic [1:0] m_axi_gmem_aux_ARLOCK;
  logic [3:0] m_axi_gmem_aux_ARCACHE;
  logic [2:0] m_axi_gmem_aux_ARPROT;
  logic [3:0] m_axi_gmem_aux_ARQOS;
  logic [3:0] m_axi_gmem_aux_ARREGION;
  logic [0:0] m_axi_gmem_aux_ARUSER;
  logic  m_axi_gmem_aux_RVALID;
  logic  m_axi_gmem_aux_RREADY;
  logic [31:0] m_axi_gmem_aux_RDATA;
  logic  m_axi_gmem_aux_RLAST;
  logic [0:0] m_axi_gmem_aux_RID;
  logic [0:0] m_axi_gmem_aux_RUSER;
  logic [1:0] m_axi_gmem_aux_RRESP;
  logic  m_axi_gmem_aux_BVALID;
  logic  m_axi_gmem_aux_BREADY;
  logic [1:0] m_axi_gmem_aux_BRESP;
  logic [0:0] m_axi_gmem_aux_BID;
  logic [0:0] m_axi_gmem_aux_BUSER;
  logic  m_axi_gmem_activation_AWVALID;
  logic  m_axi_gmem_activation_AWREADY;
  logic [63:0] m_axi_gmem_activation_AWADDR;
  logic [0:0] m_axi_gmem_activation_AWID;
  logic [7:0] m_axi_gmem_activation_AWLEN;
  logic [2:0] m_axi_gmem_activation_AWSIZE;
  logic [1:0] m_axi_gmem_activation_AWBURST;
  logic [1:0] m_axi_gmem_activation_AWLOCK;
  logic [3:0] m_axi_gmem_activation_AWCACHE;
  logic [2:0] m_axi_gmem_activation_AWPROT;
  logic [3:0] m_axi_gmem_activation_AWQOS;
  logic [3:0] m_axi_gmem_activation_AWREGION;
  logic [0:0] m_axi_gmem_activation_AWUSER;
  logic  m_axi_gmem_activation_WVALID;
  logic  m_axi_gmem_activation_WREADY;
  logic [511:0] m_axi_gmem_activation_WDATA;
  logic [63:0] m_axi_gmem_activation_WSTRB;
  logic  m_axi_gmem_activation_WLAST;
  logic [0:0] m_axi_gmem_activation_WID;
  logic [0:0] m_axi_gmem_activation_WUSER;
  logic  m_axi_gmem_activation_ARVALID;
  logic  m_axi_gmem_activation_ARREADY;
  logic [63:0] m_axi_gmem_activation_ARADDR;
  logic [0:0] m_axi_gmem_activation_ARID;
  logic [7:0] m_axi_gmem_activation_ARLEN;
  logic [2:0] m_axi_gmem_activation_ARSIZE;
  logic [1:0] m_axi_gmem_activation_ARBURST;
  logic [1:0] m_axi_gmem_activation_ARLOCK;
  logic [3:0] m_axi_gmem_activation_ARCACHE;
  logic [2:0] m_axi_gmem_activation_ARPROT;
  logic [3:0] m_axi_gmem_activation_ARQOS;
  logic [3:0] m_axi_gmem_activation_ARREGION;
  logic [0:0] m_axi_gmem_activation_ARUSER;
  logic  m_axi_gmem_activation_RVALID;
  logic  m_axi_gmem_activation_RREADY;
  logic [511:0] m_axi_gmem_activation_RDATA;
  logic  m_axi_gmem_activation_RLAST;
  logic [0:0] m_axi_gmem_activation_RID;
  logic [0:0] m_axi_gmem_activation_RUSER;
  logic [1:0] m_axi_gmem_activation_RRESP;
  logic  m_axi_gmem_activation_BVALID;
  logic  m_axi_gmem_activation_BREADY;
  logic [1:0] m_axi_gmem_activation_BRESP;
  logic [0:0] m_axi_gmem_activation_BID;
  logic [0:0] m_axi_gmem_activation_BUSER;
  logic  m_axi_gmem_observed_AWVALID;
  logic  m_axi_gmem_observed_AWREADY;
  logic [63:0] m_axi_gmem_observed_AWADDR;
  logic [0:0] m_axi_gmem_observed_AWID;
  logic [7:0] m_axi_gmem_observed_AWLEN;
  logic [2:0] m_axi_gmem_observed_AWSIZE;
  logic [1:0] m_axi_gmem_observed_AWBURST;
  logic [1:0] m_axi_gmem_observed_AWLOCK;
  logic [3:0] m_axi_gmem_observed_AWCACHE;
  logic [2:0] m_axi_gmem_observed_AWPROT;
  logic [3:0] m_axi_gmem_observed_AWQOS;
  logic [3:0] m_axi_gmem_observed_AWREGION;
  logic [0:0] m_axi_gmem_observed_AWUSER;
  logic  m_axi_gmem_observed_WVALID;
  logic  m_axi_gmem_observed_WREADY;
  logic [31:0] m_axi_gmem_observed_WDATA;
  logic [3:0] m_axi_gmem_observed_WSTRB;
  logic  m_axi_gmem_observed_WLAST;
  logic [0:0] m_axi_gmem_observed_WID;
  logic [0:0] m_axi_gmem_observed_WUSER;
  logic  m_axi_gmem_observed_ARVALID;
  logic  m_axi_gmem_observed_ARREADY;
  logic [63:0] m_axi_gmem_observed_ARADDR;
  logic [0:0] m_axi_gmem_observed_ARID;
  logic [7:0] m_axi_gmem_observed_ARLEN;
  logic [2:0] m_axi_gmem_observed_ARSIZE;
  logic [1:0] m_axi_gmem_observed_ARBURST;
  logic [1:0] m_axi_gmem_observed_ARLOCK;
  logic [3:0] m_axi_gmem_observed_ARCACHE;
  logic [2:0] m_axi_gmem_observed_ARPROT;
  logic [3:0] m_axi_gmem_observed_ARQOS;
  logic [3:0] m_axi_gmem_observed_ARREGION;
  logic [0:0] m_axi_gmem_observed_ARUSER;
  logic  m_axi_gmem_observed_RVALID;
  logic  m_axi_gmem_observed_RREADY;
  logic [31:0] m_axi_gmem_observed_RDATA;
  logic  m_axi_gmem_observed_RLAST;
  logic [0:0] m_axi_gmem_observed_RID;
  logic [0:0] m_axi_gmem_observed_RUSER;
  logic [1:0] m_axi_gmem_observed_RRESP;
  logic  m_axi_gmem_observed_BVALID;
  logic  m_axi_gmem_observed_BREADY;
  logic [1:0] m_axi_gmem_observed_BRESP;
  logic [0:0] m_axi_gmem_observed_BID;
  logic [0:0] m_axi_gmem_observed_BUSER;
  logic [63:0] m_axi_out0_AWADDR;
  logic [7:0] m_axi_out0_AWLEN;
  logic [2:0] m_axi_out0_AWSIZE;
  logic [1:0] m_axi_out0_AWBURST;
  logic  m_axi_out0_AWVALID;
  logic  m_axi_out0_AWREADY;
  logic [511:0] m_axi_out0_WDATA;
  logic [63:0] m_axi_out0_WSTRB;
  logic  m_axi_out0_WLAST;
  logic  m_axi_out0_WVALID;
  logic  m_axi_out0_WREADY;
  logic [1:0] m_axi_out0_BRESP;
  logic  m_axi_out0_BVALID;
  logic  m_axi_out0_BREADY;
  logic [0:0] m_axi_out0_AWID;
  logic [0:0] m_axi_out0_AWUSER;
  logic [0:0] m_axi_out0_WID;
  logic [0:0] m_axi_out0_WUSER;
  logic [1:0] m_axi_out0_AWLOCK;
  logic [3:0] m_axi_out0_AWCACHE;
  logic [2:0] m_axi_out0_AWPROT;
  logic [3:0] m_axi_out0_AWQOS;
  logic [3:0] m_axi_out0_AWREGION;
  logic [63:0] m_axi_out1_AWADDR;
  logic [7:0] m_axi_out1_AWLEN;
  logic [2:0] m_axi_out1_AWSIZE;
  logic [1:0] m_axi_out1_AWBURST;
  logic  m_axi_out1_AWVALID;
  logic  m_axi_out1_AWREADY;
  logic [511:0] m_axi_out1_WDATA;
  logic [63:0] m_axi_out1_WSTRB;
  logic  m_axi_out1_WLAST;
  logic  m_axi_out1_WVALID;
  logic  m_axi_out1_WREADY;
  logic [1:0] m_axi_out1_BRESP;
  logic  m_axi_out1_BVALID;
  logic  m_axi_out1_BREADY;
  logic [0:0] m_axi_out1_AWID;
  logic [0:0] m_axi_out1_AWUSER;
  logic [0:0] m_axi_out1_WID;
  logic [0:0] m_axi_out1_WUSER;
  logic [1:0] m_axi_out1_AWLOCK;
  logic [3:0] m_axi_out1_AWCACHE;
  logic [2:0] m_axi_out1_AWPROT;
  logic [3:0] m_axi_out1_AWQOS;
  logic [3:0] m_axi_out1_AWREGION;
  logic [63:0] m_axi_observed_trace_AWADDR;
  logic [7:0] m_axi_observed_trace_AWLEN;
  logic [2:0] m_axi_observed_trace_AWSIZE;
  logic [1:0] m_axi_observed_trace_AWBURST;
  logic  m_axi_observed_trace_AWVALID;
  logic  m_axi_observed_trace_AWREADY;
  logic [31:0] m_axi_observed_trace_WDATA;
  logic [3:0] m_axi_observed_trace_WSTRB;
  logic  m_axi_observed_trace_WLAST;
  logic  m_axi_observed_trace_WVALID;
  logic  m_axi_observed_trace_WREADY;
  logic [1:0] m_axi_observed_trace_BRESP;
  logic  m_axi_observed_trace_BVALID;
  logic  m_axi_observed_trace_BREADY;
  logic [0:0] m_axi_observed_trace_AWID;
  logic [0:0] m_axi_observed_trace_AWUSER;
  logic [0:0] m_axi_observed_trace_WID;
  logic [0:0] m_axi_observed_trace_WUSER;
  logic [1:0] m_axi_observed_trace_AWLOCK;
  logic [3:0] m_axi_observed_trace_AWCACHE;
  logic [2:0] m_axi_observed_trace_AWPROT;
  logic [3:0] m_axi_observed_trace_AWQOS;
  logic [3:0] m_axi_observed_trace_AWREGION;
  logic  command_start;
  logic  command_ready;
  logic  command_done;
  logic  command_fault;
  logic [63:0] descriptor_base;
  logic [63:0] w_q0_base;
  logic [63:0] w_q1_base;
  logic [63:0] w_scale_base;
  logic [63:0] aux_base;
  logic [63:0] activation_base;
  logic [63:0] observed_base;
  logic [63:0] observed_span;
  logic [127:0] context_cookie;
  logic [63:0] model_generation;
  logic [63:0] embedding_base;
  logic [319:0] model_bo_bytes;
  logic [319:0] model_bo_cookie;
  q8_tm1tn8_gs32_512_session_v2 dut (.ap_clk(ap_clk), .ap_rst_n(ap_rst_n), .m_axi_gmem_descriptor_AWVALID(m_axi_gmem_descriptor_AWVALID), .m_axi_gmem_descriptor_AWREADY(m_axi_gmem_descriptor_AWREADY), .m_axi_gmem_descriptor_AWADDR(m_axi_gmem_descriptor_AWADDR), .m_axi_gmem_descriptor_AWID(m_axi_gmem_descriptor_AWID), .m_axi_gmem_descriptor_AWLEN(m_axi_gmem_descriptor_AWLEN), .m_axi_gmem_descriptor_AWSIZE(m_axi_gmem_descriptor_AWSIZE), .m_axi_gmem_descriptor_AWBURST(m_axi_gmem_descriptor_AWBURST), .m_axi_gmem_descriptor_AWLOCK(m_axi_gmem_descriptor_AWLOCK), .m_axi_gmem_descriptor_AWCACHE(m_axi_gmem_descriptor_AWCACHE), .m_axi_gmem_descriptor_AWPROT(m_axi_gmem_descriptor_AWPROT), .m_axi_gmem_descriptor_AWQOS(m_axi_gmem_descriptor_AWQOS), .m_axi_gmem_descriptor_AWREGION(m_axi_gmem_descriptor_AWREGION), .m_axi_gmem_descriptor_AWUSER(m_axi_gmem_descriptor_AWUSER), .m_axi_gmem_descriptor_WVALID(m_axi_gmem_descriptor_WVALID), .m_axi_gmem_descriptor_WREADY(m_axi_gmem_descriptor_WREADY), .m_axi_gmem_descriptor_WDATA(m_axi_gmem_descriptor_WDATA), .m_axi_gmem_descriptor_WSTRB(m_axi_gmem_descriptor_WSTRB), .m_axi_gmem_descriptor_WLAST(m_axi_gmem_descriptor_WLAST), .m_axi_gmem_descriptor_WID(m_axi_gmem_descriptor_WID), .m_axi_gmem_descriptor_WUSER(m_axi_gmem_descriptor_WUSER), .m_axi_gmem_descriptor_ARVALID(m_axi_gmem_descriptor_ARVALID), .m_axi_gmem_descriptor_ARREADY(m_axi_gmem_descriptor_ARREADY), .m_axi_gmem_descriptor_ARADDR(m_axi_gmem_descriptor_ARADDR), .m_axi_gmem_descriptor_ARID(m_axi_gmem_descriptor_ARID), .m_axi_gmem_descriptor_ARLEN(m_axi_gmem_descriptor_ARLEN), .m_axi_gmem_descriptor_ARSIZE(m_axi_gmem_descriptor_ARSIZE), .m_axi_gmem_descriptor_ARBURST(m_axi_gmem_descriptor_ARBURST), .m_axi_gmem_descriptor_ARLOCK(m_axi_gmem_descriptor_ARLOCK), .m_axi_gmem_descriptor_ARCACHE(m_axi_gmem_descriptor_ARCACHE), .m_axi_gmem_descriptor_ARPROT(m_axi_gmem_descriptor_ARPROT), .m_axi_gmem_descriptor_ARQOS(m_axi_gmem_descriptor_ARQOS), .m_axi_gmem_descriptor_ARREGION(m_axi_gmem_descriptor_ARREGION), .m_axi_gmem_descriptor_ARUSER(m_axi_gmem_descriptor_ARUSER), .m_axi_gmem_descriptor_RVALID(m_axi_gmem_descriptor_RVALID), .m_axi_gmem_descriptor_RREADY(m_axi_gmem_descriptor_RREADY), .m_axi_gmem_descriptor_RDATA(m_axi_gmem_descriptor_RDATA), .m_axi_gmem_descriptor_RLAST(m_axi_gmem_descriptor_RLAST), .m_axi_gmem_descriptor_RID(m_axi_gmem_descriptor_RID), .m_axi_gmem_descriptor_RUSER(m_axi_gmem_descriptor_RUSER), .m_axi_gmem_descriptor_RRESP(m_axi_gmem_descriptor_RRESP), .m_axi_gmem_descriptor_BVALID(m_axi_gmem_descriptor_BVALID), .m_axi_gmem_descriptor_BREADY(m_axi_gmem_descriptor_BREADY), .m_axi_gmem_descriptor_BRESP(m_axi_gmem_descriptor_BRESP), .m_axi_gmem_descriptor_BID(m_axi_gmem_descriptor_BID), .m_axi_gmem_descriptor_BUSER(m_axi_gmem_descriptor_BUSER), .m_axi_gmem_w_q0_AWVALID(m_axi_gmem_w_q0_AWVALID), .m_axi_gmem_w_q0_AWREADY(m_axi_gmem_w_q0_AWREADY), .m_axi_gmem_w_q0_AWADDR(m_axi_gmem_w_q0_AWADDR), .m_axi_gmem_w_q0_AWID(m_axi_gmem_w_q0_AWID), .m_axi_gmem_w_q0_AWLEN(m_axi_gmem_w_q0_AWLEN), .m_axi_gmem_w_q0_AWSIZE(m_axi_gmem_w_q0_AWSIZE), .m_axi_gmem_w_q0_AWBURST(m_axi_gmem_w_q0_AWBURST), .m_axi_gmem_w_q0_AWLOCK(m_axi_gmem_w_q0_AWLOCK), .m_axi_gmem_w_q0_AWCACHE(m_axi_gmem_w_q0_AWCACHE), .m_axi_gmem_w_q0_AWPROT(m_axi_gmem_w_q0_AWPROT), .m_axi_gmem_w_q0_AWQOS(m_axi_gmem_w_q0_AWQOS), .m_axi_gmem_w_q0_AWREGION(m_axi_gmem_w_q0_AWREGION), .m_axi_gmem_w_q0_AWUSER(m_axi_gmem_w_q0_AWUSER), .m_axi_gmem_w_q0_WVALID(m_axi_gmem_w_q0_WVALID), .m_axi_gmem_w_q0_WREADY(m_axi_gmem_w_q0_WREADY), .m_axi_gmem_w_q0_WDATA(m_axi_gmem_w_q0_WDATA), .m_axi_gmem_w_q0_WSTRB(m_axi_gmem_w_q0_WSTRB), .m_axi_gmem_w_q0_WLAST(m_axi_gmem_w_q0_WLAST), .m_axi_gmem_w_q0_WID(m_axi_gmem_w_q0_WID), .m_axi_gmem_w_q0_WUSER(m_axi_gmem_w_q0_WUSER), .m_axi_gmem_w_q0_ARVALID(m_axi_gmem_w_q0_ARVALID), .m_axi_gmem_w_q0_ARREADY(m_axi_gmem_w_q0_ARREADY), .m_axi_gmem_w_q0_ARADDR(m_axi_gmem_w_q0_ARADDR), .m_axi_gmem_w_q0_ARID(m_axi_gmem_w_q0_ARID), .m_axi_gmem_w_q0_ARLEN(m_axi_gmem_w_q0_ARLEN), .m_axi_gmem_w_q0_ARSIZE(m_axi_gmem_w_q0_ARSIZE), .m_axi_gmem_w_q0_ARBURST(m_axi_gmem_w_q0_ARBURST), .m_axi_gmem_w_q0_ARLOCK(m_axi_gmem_w_q0_ARLOCK), .m_axi_gmem_w_q0_ARCACHE(m_axi_gmem_w_q0_ARCACHE), .m_axi_gmem_w_q0_ARPROT(m_axi_gmem_w_q0_ARPROT), .m_axi_gmem_w_q0_ARQOS(m_axi_gmem_w_q0_ARQOS), .m_axi_gmem_w_q0_ARREGION(m_axi_gmem_w_q0_ARREGION), .m_axi_gmem_w_q0_ARUSER(m_axi_gmem_w_q0_ARUSER), .m_axi_gmem_w_q0_RVALID(m_axi_gmem_w_q0_RVALID), .m_axi_gmem_w_q0_RREADY(m_axi_gmem_w_q0_RREADY), .m_axi_gmem_w_q0_RDATA(m_axi_gmem_w_q0_RDATA), .m_axi_gmem_w_q0_RLAST(m_axi_gmem_w_q0_RLAST), .m_axi_gmem_w_q0_RID(m_axi_gmem_w_q0_RID), .m_axi_gmem_w_q0_RUSER(m_axi_gmem_w_q0_RUSER), .m_axi_gmem_w_q0_RRESP(m_axi_gmem_w_q0_RRESP), .m_axi_gmem_w_q0_BVALID(m_axi_gmem_w_q0_BVALID), .m_axi_gmem_w_q0_BREADY(m_axi_gmem_w_q0_BREADY), .m_axi_gmem_w_q0_BRESP(m_axi_gmem_w_q0_BRESP), .m_axi_gmem_w_q0_BID(m_axi_gmem_w_q0_BID), .m_axi_gmem_w_q0_BUSER(m_axi_gmem_w_q0_BUSER), .m_axi_gmem_w_q1_AWVALID(m_axi_gmem_w_q1_AWVALID), .m_axi_gmem_w_q1_AWREADY(m_axi_gmem_w_q1_AWREADY), .m_axi_gmem_w_q1_AWADDR(m_axi_gmem_w_q1_AWADDR), .m_axi_gmem_w_q1_AWID(m_axi_gmem_w_q1_AWID), .m_axi_gmem_w_q1_AWLEN(m_axi_gmem_w_q1_AWLEN), .m_axi_gmem_w_q1_AWSIZE(m_axi_gmem_w_q1_AWSIZE), .m_axi_gmem_w_q1_AWBURST(m_axi_gmem_w_q1_AWBURST), .m_axi_gmem_w_q1_AWLOCK(m_axi_gmem_w_q1_AWLOCK), .m_axi_gmem_w_q1_AWCACHE(m_axi_gmem_w_q1_AWCACHE), .m_axi_gmem_w_q1_AWPROT(m_axi_gmem_w_q1_AWPROT), .m_axi_gmem_w_q1_AWQOS(m_axi_gmem_w_q1_AWQOS), .m_axi_gmem_w_q1_AWREGION(m_axi_gmem_w_q1_AWREGION), .m_axi_gmem_w_q1_AWUSER(m_axi_gmem_w_q1_AWUSER), .m_axi_gmem_w_q1_WVALID(m_axi_gmem_w_q1_WVALID), .m_axi_gmem_w_q1_WREADY(m_axi_gmem_w_q1_WREADY), .m_axi_gmem_w_q1_WDATA(m_axi_gmem_w_q1_WDATA), .m_axi_gmem_w_q1_WSTRB(m_axi_gmem_w_q1_WSTRB), .m_axi_gmem_w_q1_WLAST(m_axi_gmem_w_q1_WLAST), .m_axi_gmem_w_q1_WID(m_axi_gmem_w_q1_WID), .m_axi_gmem_w_q1_WUSER(m_axi_gmem_w_q1_WUSER), .m_axi_gmem_w_q1_ARVALID(m_axi_gmem_w_q1_ARVALID), .m_axi_gmem_w_q1_ARREADY(m_axi_gmem_w_q1_ARREADY), .m_axi_gmem_w_q1_ARADDR(m_axi_gmem_w_q1_ARADDR), .m_axi_gmem_w_q1_ARID(m_axi_gmem_w_q1_ARID), .m_axi_gmem_w_q1_ARLEN(m_axi_gmem_w_q1_ARLEN), .m_axi_gmem_w_q1_ARSIZE(m_axi_gmem_w_q1_ARSIZE), .m_axi_gmem_w_q1_ARBURST(m_axi_gmem_w_q1_ARBURST), .m_axi_gmem_w_q1_ARLOCK(m_axi_gmem_w_q1_ARLOCK), .m_axi_gmem_w_q1_ARCACHE(m_axi_gmem_w_q1_ARCACHE), .m_axi_gmem_w_q1_ARPROT(m_axi_gmem_w_q1_ARPROT), .m_axi_gmem_w_q1_ARQOS(m_axi_gmem_w_q1_ARQOS), .m_axi_gmem_w_q1_ARREGION(m_axi_gmem_w_q1_ARREGION), .m_axi_gmem_w_q1_ARUSER(m_axi_gmem_w_q1_ARUSER), .m_axi_gmem_w_q1_RVALID(m_axi_gmem_w_q1_RVALID), .m_axi_gmem_w_q1_RREADY(m_axi_gmem_w_q1_RREADY), .m_axi_gmem_w_q1_RDATA(m_axi_gmem_w_q1_RDATA), .m_axi_gmem_w_q1_RLAST(m_axi_gmem_w_q1_RLAST), .m_axi_gmem_w_q1_RID(m_axi_gmem_w_q1_RID), .m_axi_gmem_w_q1_RUSER(m_axi_gmem_w_q1_RUSER), .m_axi_gmem_w_q1_RRESP(m_axi_gmem_w_q1_RRESP), .m_axi_gmem_w_q1_BVALID(m_axi_gmem_w_q1_BVALID), .m_axi_gmem_w_q1_BREADY(m_axi_gmem_w_q1_BREADY), .m_axi_gmem_w_q1_BRESP(m_axi_gmem_w_q1_BRESP), .m_axi_gmem_w_q1_BID(m_axi_gmem_w_q1_BID), .m_axi_gmem_w_q1_BUSER(m_axi_gmem_w_q1_BUSER), .m_axi_gmem_w_scale_AWVALID(m_axi_gmem_w_scale_AWVALID), .m_axi_gmem_w_scale_AWREADY(m_axi_gmem_w_scale_AWREADY), .m_axi_gmem_w_scale_AWADDR(m_axi_gmem_w_scale_AWADDR), .m_axi_gmem_w_scale_AWID(m_axi_gmem_w_scale_AWID), .m_axi_gmem_w_scale_AWLEN(m_axi_gmem_w_scale_AWLEN), .m_axi_gmem_w_scale_AWSIZE(m_axi_gmem_w_scale_AWSIZE), .m_axi_gmem_w_scale_AWBURST(m_axi_gmem_w_scale_AWBURST), .m_axi_gmem_w_scale_AWLOCK(m_axi_gmem_w_scale_AWLOCK), .m_axi_gmem_w_scale_AWCACHE(m_axi_gmem_w_scale_AWCACHE), .m_axi_gmem_w_scale_AWPROT(m_axi_gmem_w_scale_AWPROT), .m_axi_gmem_w_scale_AWQOS(m_axi_gmem_w_scale_AWQOS), .m_axi_gmem_w_scale_AWREGION(m_axi_gmem_w_scale_AWREGION), .m_axi_gmem_w_scale_AWUSER(m_axi_gmem_w_scale_AWUSER), .m_axi_gmem_w_scale_WVALID(m_axi_gmem_w_scale_WVALID), .m_axi_gmem_w_scale_WREADY(m_axi_gmem_w_scale_WREADY), .m_axi_gmem_w_scale_WDATA(m_axi_gmem_w_scale_WDATA), .m_axi_gmem_w_scale_WSTRB(m_axi_gmem_w_scale_WSTRB), .m_axi_gmem_w_scale_WLAST(m_axi_gmem_w_scale_WLAST), .m_axi_gmem_w_scale_WID(m_axi_gmem_w_scale_WID), .m_axi_gmem_w_scale_WUSER(m_axi_gmem_w_scale_WUSER), .m_axi_gmem_w_scale_ARVALID(m_axi_gmem_w_scale_ARVALID), .m_axi_gmem_w_scale_ARREADY(m_axi_gmem_w_scale_ARREADY), .m_axi_gmem_w_scale_ARADDR(m_axi_gmem_w_scale_ARADDR), .m_axi_gmem_w_scale_ARID(m_axi_gmem_w_scale_ARID), .m_axi_gmem_w_scale_ARLEN(m_axi_gmem_w_scale_ARLEN), .m_axi_gmem_w_scale_ARSIZE(m_axi_gmem_w_scale_ARSIZE), .m_axi_gmem_w_scale_ARBURST(m_axi_gmem_w_scale_ARBURST), .m_axi_gmem_w_scale_ARLOCK(m_axi_gmem_w_scale_ARLOCK), .m_axi_gmem_w_scale_ARCACHE(m_axi_gmem_w_scale_ARCACHE), .m_axi_gmem_w_scale_ARPROT(m_axi_gmem_w_scale_ARPROT), .m_axi_gmem_w_scale_ARQOS(m_axi_gmem_w_scale_ARQOS), .m_axi_gmem_w_scale_ARREGION(m_axi_gmem_w_scale_ARREGION), .m_axi_gmem_w_scale_ARUSER(m_axi_gmem_w_scale_ARUSER), .m_axi_gmem_w_scale_RVALID(m_axi_gmem_w_scale_RVALID), .m_axi_gmem_w_scale_RREADY(m_axi_gmem_w_scale_RREADY), .m_axi_gmem_w_scale_RDATA(m_axi_gmem_w_scale_RDATA), .m_axi_gmem_w_scale_RLAST(m_axi_gmem_w_scale_RLAST), .m_axi_gmem_w_scale_RID(m_axi_gmem_w_scale_RID), .m_axi_gmem_w_scale_RUSER(m_axi_gmem_w_scale_RUSER), .m_axi_gmem_w_scale_RRESP(m_axi_gmem_w_scale_RRESP), .m_axi_gmem_w_scale_BVALID(m_axi_gmem_w_scale_BVALID), .m_axi_gmem_w_scale_BREADY(m_axi_gmem_w_scale_BREADY), .m_axi_gmem_w_scale_BRESP(m_axi_gmem_w_scale_BRESP), .m_axi_gmem_w_scale_BID(m_axi_gmem_w_scale_BID), .m_axi_gmem_w_scale_BUSER(m_axi_gmem_w_scale_BUSER), .m_axi_gmem_aux_AWVALID(m_axi_gmem_aux_AWVALID), .m_axi_gmem_aux_AWREADY(m_axi_gmem_aux_AWREADY), .m_axi_gmem_aux_AWADDR(m_axi_gmem_aux_AWADDR), .m_axi_gmem_aux_AWID(m_axi_gmem_aux_AWID), .m_axi_gmem_aux_AWLEN(m_axi_gmem_aux_AWLEN), .m_axi_gmem_aux_AWSIZE(m_axi_gmem_aux_AWSIZE), .m_axi_gmem_aux_AWBURST(m_axi_gmem_aux_AWBURST), .m_axi_gmem_aux_AWLOCK(m_axi_gmem_aux_AWLOCK), .m_axi_gmem_aux_AWCACHE(m_axi_gmem_aux_AWCACHE), .m_axi_gmem_aux_AWPROT(m_axi_gmem_aux_AWPROT), .m_axi_gmem_aux_AWQOS(m_axi_gmem_aux_AWQOS), .m_axi_gmem_aux_AWREGION(m_axi_gmem_aux_AWREGION), .m_axi_gmem_aux_AWUSER(m_axi_gmem_aux_AWUSER), .m_axi_gmem_aux_WVALID(m_axi_gmem_aux_WVALID), .m_axi_gmem_aux_WREADY(m_axi_gmem_aux_WREADY), .m_axi_gmem_aux_WDATA(m_axi_gmem_aux_WDATA), .m_axi_gmem_aux_WSTRB(m_axi_gmem_aux_WSTRB), .m_axi_gmem_aux_WLAST(m_axi_gmem_aux_WLAST), .m_axi_gmem_aux_WID(m_axi_gmem_aux_WID), .m_axi_gmem_aux_WUSER(m_axi_gmem_aux_WUSER), .m_axi_gmem_aux_ARVALID(m_axi_gmem_aux_ARVALID), .m_axi_gmem_aux_ARREADY(m_axi_gmem_aux_ARREADY), .m_axi_gmem_aux_ARADDR(m_axi_gmem_aux_ARADDR), .m_axi_gmem_aux_ARID(m_axi_gmem_aux_ARID), .m_axi_gmem_aux_ARLEN(m_axi_gmem_aux_ARLEN), .m_axi_gmem_aux_ARSIZE(m_axi_gmem_aux_ARSIZE), .m_axi_gmem_aux_ARBURST(m_axi_gmem_aux_ARBURST), .m_axi_gmem_aux_ARLOCK(m_axi_gmem_aux_ARLOCK), .m_axi_gmem_aux_ARCACHE(m_axi_gmem_aux_ARCACHE), .m_axi_gmem_aux_ARPROT(m_axi_gmem_aux_ARPROT), .m_axi_gmem_aux_ARQOS(m_axi_gmem_aux_ARQOS), .m_axi_gmem_aux_ARREGION(m_axi_gmem_aux_ARREGION), .m_axi_gmem_aux_ARUSER(m_axi_gmem_aux_ARUSER), .m_axi_gmem_aux_RVALID(m_axi_gmem_aux_RVALID), .m_axi_gmem_aux_RREADY(m_axi_gmem_aux_RREADY), .m_axi_gmem_aux_RDATA(m_axi_gmem_aux_RDATA), .m_axi_gmem_aux_RLAST(m_axi_gmem_aux_RLAST), .m_axi_gmem_aux_RID(m_axi_gmem_aux_RID), .m_axi_gmem_aux_RUSER(m_axi_gmem_aux_RUSER), .m_axi_gmem_aux_RRESP(m_axi_gmem_aux_RRESP), .m_axi_gmem_aux_BVALID(m_axi_gmem_aux_BVALID), .m_axi_gmem_aux_BREADY(m_axi_gmem_aux_BREADY), .m_axi_gmem_aux_BRESP(m_axi_gmem_aux_BRESP), .m_axi_gmem_aux_BID(m_axi_gmem_aux_BID), .m_axi_gmem_aux_BUSER(m_axi_gmem_aux_BUSER), .m_axi_gmem_activation_AWVALID(m_axi_gmem_activation_AWVALID), .m_axi_gmem_activation_AWREADY(m_axi_gmem_activation_AWREADY), .m_axi_gmem_activation_AWADDR(m_axi_gmem_activation_AWADDR), .m_axi_gmem_activation_AWID(m_axi_gmem_activation_AWID), .m_axi_gmem_activation_AWLEN(m_axi_gmem_activation_AWLEN), .m_axi_gmem_activation_AWSIZE(m_axi_gmem_activation_AWSIZE), .m_axi_gmem_activation_AWBURST(m_axi_gmem_activation_AWBURST), .m_axi_gmem_activation_AWLOCK(m_axi_gmem_activation_AWLOCK), .m_axi_gmem_activation_AWCACHE(m_axi_gmem_activation_AWCACHE), .m_axi_gmem_activation_AWPROT(m_axi_gmem_activation_AWPROT), .m_axi_gmem_activation_AWQOS(m_axi_gmem_activation_AWQOS), .m_axi_gmem_activation_AWREGION(m_axi_gmem_activation_AWREGION), .m_axi_gmem_activation_AWUSER(m_axi_gmem_activation_AWUSER), .m_axi_gmem_activation_WVALID(m_axi_gmem_activation_WVALID), .m_axi_gmem_activation_WREADY(m_axi_gmem_activation_WREADY), .m_axi_gmem_activation_WDATA(m_axi_gmem_activation_WDATA), .m_axi_gmem_activation_WSTRB(m_axi_gmem_activation_WSTRB), .m_axi_gmem_activation_WLAST(m_axi_gmem_activation_WLAST), .m_axi_gmem_activation_WID(m_axi_gmem_activation_WID), .m_axi_gmem_activation_WUSER(m_axi_gmem_activation_WUSER), .m_axi_gmem_activation_ARVALID(m_axi_gmem_activation_ARVALID), .m_axi_gmem_activation_ARREADY(m_axi_gmem_activation_ARREADY), .m_axi_gmem_activation_ARADDR(m_axi_gmem_activation_ARADDR), .m_axi_gmem_activation_ARID(m_axi_gmem_activation_ARID), .m_axi_gmem_activation_ARLEN(m_axi_gmem_activation_ARLEN), .m_axi_gmem_activation_ARSIZE(m_axi_gmem_activation_ARSIZE), .m_axi_gmem_activation_ARBURST(m_axi_gmem_activation_ARBURST), .m_axi_gmem_activation_ARLOCK(m_axi_gmem_activation_ARLOCK), .m_axi_gmem_activation_ARCACHE(m_axi_gmem_activation_ARCACHE), .m_axi_gmem_activation_ARPROT(m_axi_gmem_activation_ARPROT), .m_axi_gmem_activation_ARQOS(m_axi_gmem_activation_ARQOS), .m_axi_gmem_activation_ARREGION(m_axi_gmem_activation_ARREGION), .m_axi_gmem_activation_ARUSER(m_axi_gmem_activation_ARUSER), .m_axi_gmem_activation_RVALID(m_axi_gmem_activation_RVALID), .m_axi_gmem_activation_RREADY(m_axi_gmem_activation_RREADY), .m_axi_gmem_activation_RDATA(m_axi_gmem_activation_RDATA), .m_axi_gmem_activation_RLAST(m_axi_gmem_activation_RLAST), .m_axi_gmem_activation_RID(m_axi_gmem_activation_RID), .m_axi_gmem_activation_RUSER(m_axi_gmem_activation_RUSER), .m_axi_gmem_activation_RRESP(m_axi_gmem_activation_RRESP), .m_axi_gmem_activation_BVALID(m_axi_gmem_activation_BVALID), .m_axi_gmem_activation_BREADY(m_axi_gmem_activation_BREADY), .m_axi_gmem_activation_BRESP(m_axi_gmem_activation_BRESP), .m_axi_gmem_activation_BID(m_axi_gmem_activation_BID), .m_axi_gmem_activation_BUSER(m_axi_gmem_activation_BUSER), .m_axi_gmem_observed_AWVALID(m_axi_gmem_observed_AWVALID), .m_axi_gmem_observed_AWREADY(m_axi_gmem_observed_AWREADY), .m_axi_gmem_observed_AWADDR(m_axi_gmem_observed_AWADDR), .m_axi_gmem_observed_AWID(m_axi_gmem_observed_AWID), .m_axi_gmem_observed_AWLEN(m_axi_gmem_observed_AWLEN), .m_axi_gmem_observed_AWSIZE(m_axi_gmem_observed_AWSIZE), .m_axi_gmem_observed_AWBURST(m_axi_gmem_observed_AWBURST), .m_axi_gmem_observed_AWLOCK(m_axi_gmem_observed_AWLOCK), .m_axi_gmem_observed_AWCACHE(m_axi_gmem_observed_AWCACHE), .m_axi_gmem_observed_AWPROT(m_axi_gmem_observed_AWPROT), .m_axi_gmem_observed_AWQOS(m_axi_gmem_observed_AWQOS), .m_axi_gmem_observed_AWREGION(m_axi_gmem_observed_AWREGION), .m_axi_gmem_observed_AWUSER(m_axi_gmem_observed_AWUSER), .m_axi_gmem_observed_WVALID(m_axi_gmem_observed_WVALID), .m_axi_gmem_observed_WREADY(m_axi_gmem_observed_WREADY), .m_axi_gmem_observed_WDATA(m_axi_gmem_observed_WDATA), .m_axi_gmem_observed_WSTRB(m_axi_gmem_observed_WSTRB), .m_axi_gmem_observed_WLAST(m_axi_gmem_observed_WLAST), .m_axi_gmem_observed_WID(m_axi_gmem_observed_WID), .m_axi_gmem_observed_WUSER(m_axi_gmem_observed_WUSER), .m_axi_gmem_observed_ARVALID(m_axi_gmem_observed_ARVALID), .m_axi_gmem_observed_ARREADY(m_axi_gmem_observed_ARREADY), .m_axi_gmem_observed_ARADDR(m_axi_gmem_observed_ARADDR), .m_axi_gmem_observed_ARID(m_axi_gmem_observed_ARID), .m_axi_gmem_observed_ARLEN(m_axi_gmem_observed_ARLEN), .m_axi_gmem_observed_ARSIZE(m_axi_gmem_observed_ARSIZE), .m_axi_gmem_observed_ARBURST(m_axi_gmem_observed_ARBURST), .m_axi_gmem_observed_ARLOCK(m_axi_gmem_observed_ARLOCK), .m_axi_gmem_observed_ARCACHE(m_axi_gmem_observed_ARCACHE), .m_axi_gmem_observed_ARPROT(m_axi_gmem_observed_ARPROT), .m_axi_gmem_observed_ARQOS(m_axi_gmem_observed_ARQOS), .m_axi_gmem_observed_ARREGION(m_axi_gmem_observed_ARREGION), .m_axi_gmem_observed_ARUSER(m_axi_gmem_observed_ARUSER), .m_axi_gmem_observed_RVALID(m_axi_gmem_observed_RVALID), .m_axi_gmem_observed_RREADY(m_axi_gmem_observed_RREADY), .m_axi_gmem_observed_RDATA(m_axi_gmem_observed_RDATA), .m_axi_gmem_observed_RLAST(m_axi_gmem_observed_RLAST), .m_axi_gmem_observed_RID(m_axi_gmem_observed_RID), .m_axi_gmem_observed_RUSER(m_axi_gmem_observed_RUSER), .m_axi_gmem_observed_RRESP(m_axi_gmem_observed_RRESP), .m_axi_gmem_observed_BVALID(m_axi_gmem_observed_BVALID), .m_axi_gmem_observed_BREADY(m_axi_gmem_observed_BREADY), .m_axi_gmem_observed_BRESP(m_axi_gmem_observed_BRESP), .m_axi_gmem_observed_BID(m_axi_gmem_observed_BID), .m_axi_gmem_observed_BUSER(m_axi_gmem_observed_BUSER), .m_axi_out0_AWADDR(m_axi_out0_AWADDR), .m_axi_out0_AWLEN(m_axi_out0_AWLEN), .m_axi_out0_AWSIZE(m_axi_out0_AWSIZE), .m_axi_out0_AWBURST(m_axi_out0_AWBURST), .m_axi_out0_AWVALID(m_axi_out0_AWVALID), .m_axi_out0_AWREADY(m_axi_out0_AWREADY), .m_axi_out0_WDATA(m_axi_out0_WDATA), .m_axi_out0_WSTRB(m_axi_out0_WSTRB), .m_axi_out0_WLAST(m_axi_out0_WLAST), .m_axi_out0_WVALID(m_axi_out0_WVALID), .m_axi_out0_WREADY(m_axi_out0_WREADY), .m_axi_out0_BRESP(m_axi_out0_BRESP), .m_axi_out0_BVALID(m_axi_out0_BVALID), .m_axi_out0_BREADY(m_axi_out0_BREADY), .m_axi_out0_AWID(m_axi_out0_AWID), .m_axi_out0_AWUSER(m_axi_out0_AWUSER), .m_axi_out0_WID(m_axi_out0_WID), .m_axi_out0_WUSER(m_axi_out0_WUSER), .m_axi_out0_AWLOCK(m_axi_out0_AWLOCK), .m_axi_out0_AWCACHE(m_axi_out0_AWCACHE), .m_axi_out0_AWPROT(m_axi_out0_AWPROT), .m_axi_out0_AWQOS(m_axi_out0_AWQOS), .m_axi_out0_AWREGION(m_axi_out0_AWREGION), .m_axi_out1_AWADDR(m_axi_out1_AWADDR), .m_axi_out1_AWLEN(m_axi_out1_AWLEN), .m_axi_out1_AWSIZE(m_axi_out1_AWSIZE), .m_axi_out1_AWBURST(m_axi_out1_AWBURST), .m_axi_out1_AWVALID(m_axi_out1_AWVALID), .m_axi_out1_AWREADY(m_axi_out1_AWREADY), .m_axi_out1_WDATA(m_axi_out1_WDATA), .m_axi_out1_WSTRB(m_axi_out1_WSTRB), .m_axi_out1_WLAST(m_axi_out1_WLAST), .m_axi_out1_WVALID(m_axi_out1_WVALID), .m_axi_out1_WREADY(m_axi_out1_WREADY), .m_axi_out1_BRESP(m_axi_out1_BRESP), .m_axi_out1_BVALID(m_axi_out1_BVALID), .m_axi_out1_BREADY(m_axi_out1_BREADY), .m_axi_out1_AWID(m_axi_out1_AWID), .m_axi_out1_AWUSER(m_axi_out1_AWUSER), .m_axi_out1_WID(m_axi_out1_WID), .m_axi_out1_WUSER(m_axi_out1_WUSER), .m_axi_out1_AWLOCK(m_axi_out1_AWLOCK), .m_axi_out1_AWCACHE(m_axi_out1_AWCACHE), .m_axi_out1_AWPROT(m_axi_out1_AWPROT), .m_axi_out1_AWQOS(m_axi_out1_AWQOS), .m_axi_out1_AWREGION(m_axi_out1_AWREGION), .m_axi_observed_trace_AWADDR(m_axi_observed_trace_AWADDR), .m_axi_observed_trace_AWLEN(m_axi_observed_trace_AWLEN), .m_axi_observed_trace_AWSIZE(m_axi_observed_trace_AWSIZE), .m_axi_observed_trace_AWBURST(m_axi_observed_trace_AWBURST), .m_axi_observed_trace_AWVALID(m_axi_observed_trace_AWVALID), .m_axi_observed_trace_AWREADY(m_axi_observed_trace_AWREADY), .m_axi_observed_trace_WDATA(m_axi_observed_trace_WDATA), .m_axi_observed_trace_WSTRB(m_axi_observed_trace_WSTRB), .m_axi_observed_trace_WLAST(m_axi_observed_trace_WLAST), .m_axi_observed_trace_WVALID(m_axi_observed_trace_WVALID), .m_axi_observed_trace_WREADY(m_axi_observed_trace_WREADY), .m_axi_observed_trace_BRESP(m_axi_observed_trace_BRESP), .m_axi_observed_trace_BVALID(m_axi_observed_trace_BVALID), .m_axi_observed_trace_BREADY(m_axi_observed_trace_BREADY), .m_axi_observed_trace_AWID(m_axi_observed_trace_AWID), .m_axi_observed_trace_AWUSER(m_axi_observed_trace_AWUSER), .m_axi_observed_trace_WID(m_axi_observed_trace_WID), .m_axi_observed_trace_WUSER(m_axi_observed_trace_WUSER), .m_axi_observed_trace_AWLOCK(m_axi_observed_trace_AWLOCK), .m_axi_observed_trace_AWCACHE(m_axi_observed_trace_AWCACHE), .m_axi_observed_trace_AWPROT(m_axi_observed_trace_AWPROT), .m_axi_observed_trace_AWQOS(m_axi_observed_trace_AWQOS), .m_axi_observed_trace_AWREGION(m_axi_observed_trace_AWREGION), .command_start(command_start), .command_ready(command_ready), .command_done(command_done), .command_fault(command_fault), .descriptor_base(descriptor_base), .w_q0_base(w_q0_base), .w_q1_base(w_q1_base), .w_scale_base(w_scale_base), .aux_base(aux_base), .activation_base(activation_base), .observed_base(observed_base), .observed_span(observed_span), .context_cookie(context_cookie), .model_generation(model_generation), .embedding_base(embedding_base), .model_bo_bytes(model_bo_bytes), .model_bo_cookie(model_bo_cookie));
  logic [31:0] descriptor_read_contents;
  logic [63:0] descriptor_read_address, descriptor_write_address;
  logic descriptor_debt_zero;
  logic [31:0] descriptor_ar_count, descriptor_r_count, descriptor_aw_count, descriptor_w_count, descriptor_b_count;
  logic [511:0] w_q0_read_contents;
  logic [63:0] w_q0_read_address, w_q0_write_address;
  logic w_q0_debt_zero;
  logic [31:0] w_q0_ar_count, w_q0_r_count, w_q0_aw_count, w_q0_w_count, w_q0_b_count;
  logic [511:0] w_q1_read_contents;
  logic [63:0] w_q1_read_address, w_q1_write_address;
  logic w_q1_debt_zero;
  logic [31:0] w_q1_ar_count, w_q1_r_count, w_q1_aw_count, w_q1_w_count, w_q1_b_count;
  logic [511:0] w_scale_read_contents;
  logic [63:0] w_scale_read_address, w_scale_write_address;
  logic w_scale_debt_zero;
  logic [31:0] w_scale_ar_count, w_scale_r_count, w_scale_aw_count, w_scale_w_count, w_scale_b_count;
  logic [31:0] aux_read_contents;
  logic [63:0] aux_read_address, aux_write_address;
  logic aux_debt_zero;
  logic [31:0] aux_ar_count, aux_r_count, aux_aw_count, aux_w_count, aux_b_count;
  logic [511:0] activation_read_contents;
  logic [63:0] activation_read_address, activation_write_address;
  logic activation_debt_zero;
  logic [31:0] activation_ar_count, activation_r_count, activation_aw_count, activation_w_count, activation_b_count;
  logic [31:0] observed_read_contents;
  logic [63:0] observed_read_address, observed_write_address;
  logic observed_debt_zero;
  logic [31:0] observed_ar_count, observed_r_count, observed_aw_count, observed_w_count, observed_b_count;
  logic [511:0] out0_read_contents;
  logic [63:0] out0_read_address, out0_write_address;
  logic out0_debt_zero;
  logic [31:0] out0_ar_count, out0_r_count, out0_aw_count, out0_w_count, out0_b_count;
  logic [511:0] out1_read_contents;
  logic [63:0] out1_read_address, out1_write_address;
  logic out1_debt_zero;
  logic [31:0] out1_ar_count, out1_r_count, out1_aw_count, out1_w_count, out1_b_count;
  logic [31:0] trace_read_contents;
  logic [63:0] trace_read_address, trace_write_address;
  logic trace_debt_zero;
  logic [31:0] trace_ar_count, trace_r_count, trace_aw_count, trace_w_count, trace_b_count;
  tm1tn8_axi_memory_slave #(.DATA_W(32), .B_HOLD(9), .R_HOLD(0)) descriptor_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_descriptor_ARADDR), .arlen(m_axi_gmem_descriptor_ARLEN), .arsize(m_axi_gmem_descriptor_ARSIZE), .arvalid(m_axi_gmem_descriptor_ARVALID), .arready(m_axi_gmem_descriptor_ARREADY), .rdata(m_axi_gmem_descriptor_RDATA), .rresp(m_axi_gmem_descriptor_RRESP), .rlast(m_axi_gmem_descriptor_RLAST), .rvalid(m_axi_gmem_descriptor_RVALID), .rready(m_axi_gmem_descriptor_RREADY),
  .read_address(descriptor_read_address), .read_contents(descriptor_read_contents),
  .awaddr(m_axi_gmem_descriptor_AWADDR), .awlen(m_axi_gmem_descriptor_AWLEN), .awsize(m_axi_gmem_descriptor_AWSIZE), .awvalid(m_axi_gmem_descriptor_AWVALID), .awready(m_axi_gmem_descriptor_AWREADY), .wdata(m_axi_gmem_descriptor_WDATA), .wstrb(m_axi_gmem_descriptor_WSTRB), .wlast(m_axi_gmem_descriptor_WLAST), .wvalid(m_axi_gmem_descriptor_WVALID), .wready(m_axi_gmem_descriptor_WREADY), .bresp(m_axi_gmem_descriptor_BRESP), .bvalid(m_axi_gmem_descriptor_BVALID), .bready(m_axi_gmem_descriptor_BREADY),
  .write_address(descriptor_write_address), .debt_zero(descriptor_debt_zero),
  .ar_count(descriptor_ar_count), .r_count(descriptor_r_count), .aw_count(descriptor_aw_count), .w_count(descriptor_w_count), .b_count(descriptor_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(7)) w_q0_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_w_q0_ARADDR), .arlen(m_axi_gmem_w_q0_ARLEN), .arsize(m_axi_gmem_w_q0_ARSIZE), .arvalid(m_axi_gmem_w_q0_ARVALID), .arready(m_axi_gmem_w_q0_ARREADY), .rdata(m_axi_gmem_w_q0_RDATA), .rresp(m_axi_gmem_w_q0_RRESP), .rlast(m_axi_gmem_w_q0_RLAST), .rvalid(m_axi_gmem_w_q0_RVALID), .rready(m_axi_gmem_w_q0_RREADY),
  .read_address(w_q0_read_address), .read_contents(w_q0_read_contents),
  .awaddr(m_axi_gmem_w_q0_AWADDR), .awlen(m_axi_gmem_w_q0_AWLEN), .awsize(m_axi_gmem_w_q0_AWSIZE), .awvalid(m_axi_gmem_w_q0_AWVALID), .awready(m_axi_gmem_w_q0_AWREADY), .wdata(m_axi_gmem_w_q0_WDATA), .wstrb(m_axi_gmem_w_q0_WSTRB), .wlast(m_axi_gmem_w_q0_WLAST), .wvalid(m_axi_gmem_w_q0_WVALID), .wready(m_axi_gmem_w_q0_WREADY), .bresp(m_axi_gmem_w_q0_BRESP), .bvalid(m_axi_gmem_w_q0_BVALID), .bready(m_axi_gmem_w_q0_BREADY),
  .write_address(w_q0_write_address), .debt_zero(w_q0_debt_zero),
  .ar_count(w_q0_ar_count), .r_count(w_q0_r_count), .aw_count(w_q0_aw_count), .w_count(w_q0_w_count), .b_count(w_q0_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(0)) w_q1_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_w_q1_ARADDR), .arlen(m_axi_gmem_w_q1_ARLEN), .arsize(m_axi_gmem_w_q1_ARSIZE), .arvalid(m_axi_gmem_w_q1_ARVALID), .arready(m_axi_gmem_w_q1_ARREADY), .rdata(m_axi_gmem_w_q1_RDATA), .rresp(m_axi_gmem_w_q1_RRESP), .rlast(m_axi_gmem_w_q1_RLAST), .rvalid(m_axi_gmem_w_q1_RVALID), .rready(m_axi_gmem_w_q1_RREADY),
  .read_address(w_q1_read_address), .read_contents(w_q1_read_contents),
  .awaddr(m_axi_gmem_w_q1_AWADDR), .awlen(m_axi_gmem_w_q1_AWLEN), .awsize(m_axi_gmem_w_q1_AWSIZE), .awvalid(m_axi_gmem_w_q1_AWVALID), .awready(m_axi_gmem_w_q1_AWREADY), .wdata(m_axi_gmem_w_q1_WDATA), .wstrb(m_axi_gmem_w_q1_WSTRB), .wlast(m_axi_gmem_w_q1_WLAST), .wvalid(m_axi_gmem_w_q1_WVALID), .wready(m_axi_gmem_w_q1_WREADY), .bresp(m_axi_gmem_w_q1_BRESP), .bvalid(m_axi_gmem_w_q1_BVALID), .bready(m_axi_gmem_w_q1_BREADY),
  .write_address(w_q1_write_address), .debt_zero(w_q1_debt_zero),
  .ar_count(w_q1_ar_count), .r_count(w_q1_r_count), .aw_count(w_q1_aw_count), .w_count(w_q1_w_count), .b_count(w_q1_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(7)) w_scale_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_w_scale_ARADDR), .arlen(m_axi_gmem_w_scale_ARLEN), .arsize(m_axi_gmem_w_scale_ARSIZE), .arvalid(m_axi_gmem_w_scale_ARVALID), .arready(m_axi_gmem_w_scale_ARREADY), .rdata(m_axi_gmem_w_scale_RDATA), .rresp(m_axi_gmem_w_scale_RRESP), .rlast(m_axi_gmem_w_scale_RLAST), .rvalid(m_axi_gmem_w_scale_RVALID), .rready(m_axi_gmem_w_scale_RREADY),
  .read_address(w_scale_read_address), .read_contents(w_scale_read_contents),
  .awaddr(m_axi_gmem_w_scale_AWADDR), .awlen(m_axi_gmem_w_scale_AWLEN), .awsize(m_axi_gmem_w_scale_AWSIZE), .awvalid(m_axi_gmem_w_scale_AWVALID), .awready(m_axi_gmem_w_scale_AWREADY), .wdata(m_axi_gmem_w_scale_WDATA), .wstrb(m_axi_gmem_w_scale_WSTRB), .wlast(m_axi_gmem_w_scale_WLAST), .wvalid(m_axi_gmem_w_scale_WVALID), .wready(m_axi_gmem_w_scale_WREADY), .bresp(m_axi_gmem_w_scale_BRESP), .bvalid(m_axi_gmem_w_scale_BVALID), .bready(m_axi_gmem_w_scale_BREADY),
  .write_address(w_scale_write_address), .debt_zero(w_scale_debt_zero),
  .ar_count(w_scale_ar_count), .r_count(w_scale_r_count), .aw_count(w_scale_aw_count), .w_count(w_scale_w_count), .b_count(w_scale_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(32), .B_HOLD(9), .R_HOLD(7)) aux_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_aux_ARADDR), .arlen(m_axi_gmem_aux_ARLEN), .arsize(m_axi_gmem_aux_ARSIZE), .arvalid(m_axi_gmem_aux_ARVALID), .arready(m_axi_gmem_aux_ARREADY), .rdata(m_axi_gmem_aux_RDATA), .rresp(m_axi_gmem_aux_RRESP), .rlast(m_axi_gmem_aux_RLAST), .rvalid(m_axi_gmem_aux_RVALID), .rready(m_axi_gmem_aux_RREADY),
  .read_address(aux_read_address), .read_contents(aux_read_contents),
  .awaddr(m_axi_gmem_aux_AWADDR), .awlen(m_axi_gmem_aux_AWLEN), .awsize(m_axi_gmem_aux_AWSIZE), .awvalid(m_axi_gmem_aux_AWVALID), .awready(m_axi_gmem_aux_AWREADY), .wdata(m_axi_gmem_aux_WDATA), .wstrb(m_axi_gmem_aux_WSTRB), .wlast(m_axi_gmem_aux_WLAST), .wvalid(m_axi_gmem_aux_WVALID), .wready(m_axi_gmem_aux_WREADY), .bresp(m_axi_gmem_aux_BRESP), .bvalid(m_axi_gmem_aux_BVALID), .bready(m_axi_gmem_aux_BREADY),
  .write_address(aux_write_address), .debt_zero(aux_debt_zero),
  .ar_count(aux_ar_count), .r_count(aux_r_count), .aw_count(aux_aw_count), .w_count(aux_w_count), .b_count(aux_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(0)) activation_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_activation_ARADDR), .arlen(m_axi_gmem_activation_ARLEN), .arsize(m_axi_gmem_activation_ARSIZE), .arvalid(m_axi_gmem_activation_ARVALID), .arready(m_axi_gmem_activation_ARREADY), .rdata(m_axi_gmem_activation_RDATA), .rresp(m_axi_gmem_activation_RRESP), .rlast(m_axi_gmem_activation_RLAST), .rvalid(m_axi_gmem_activation_RVALID), .rready(m_axi_gmem_activation_RREADY),
  .read_address(activation_read_address), .read_contents(activation_read_contents),
  .awaddr(m_axi_gmem_activation_AWADDR), .awlen(m_axi_gmem_activation_AWLEN), .awsize(m_axi_gmem_activation_AWSIZE), .awvalid(m_axi_gmem_activation_AWVALID), .awready(m_axi_gmem_activation_AWREADY), .wdata(m_axi_gmem_activation_WDATA), .wstrb(m_axi_gmem_activation_WSTRB), .wlast(m_axi_gmem_activation_WLAST), .wvalid(m_axi_gmem_activation_WVALID), .wready(m_axi_gmem_activation_WREADY), .bresp(m_axi_gmem_activation_BRESP), .bvalid(m_axi_gmem_activation_BVALID), .bready(m_axi_gmem_activation_BREADY),
  .write_address(activation_write_address), .debt_zero(activation_debt_zero),
  .ar_count(activation_ar_count), .r_count(activation_r_count), .aw_count(activation_aw_count), .w_count(activation_w_count), .b_count(activation_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(32), .B_HOLD(9), .R_HOLD(0)) observed_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(m_axi_gmem_observed_ARADDR), .arlen(m_axi_gmem_observed_ARLEN), .arsize(m_axi_gmem_observed_ARSIZE), .arvalid(m_axi_gmem_observed_ARVALID), .arready(m_axi_gmem_observed_ARREADY), .rdata(m_axi_gmem_observed_RDATA), .rresp(m_axi_gmem_observed_RRESP), .rlast(m_axi_gmem_observed_RLAST), .rvalid(m_axi_gmem_observed_RVALID), .rready(m_axi_gmem_observed_RREADY),
  .read_address(observed_read_address), .read_contents(observed_read_contents),
  .awaddr(m_axi_gmem_observed_AWADDR), .awlen(m_axi_gmem_observed_AWLEN), .awsize(m_axi_gmem_observed_AWSIZE), .awvalid(m_axi_gmem_observed_AWVALID), .awready(m_axi_gmem_observed_AWREADY), .wdata(m_axi_gmem_observed_WDATA), .wstrb(m_axi_gmem_observed_WSTRB), .wlast(m_axi_gmem_observed_WLAST), .wvalid(m_axi_gmem_observed_WVALID), .wready(m_axi_gmem_observed_WREADY), .bresp(m_axi_gmem_observed_BRESP), .bvalid(m_axi_gmem_observed_BVALID), .bready(m_axi_gmem_observed_BREADY),
  .write_address(observed_write_address), .debt_zero(observed_debt_zero),
  .ar_count(observed_ar_count), .r_count(observed_r_count), .aw_count(observed_aw_count), .w_count(observed_w_count), .b_count(observed_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(0)) out0_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(64'd0), .arlen(8'd0), .arsize(3'd0), .arvalid(1'b0), .arready(), .rdata(), .rresp(), .rlast(), .rvalid(), .rready(1'b0),
  .read_address(out0_read_address), .read_contents(out0_read_contents),
  .awaddr(m_axi_out0_AWADDR), .awlen(m_axi_out0_AWLEN), .awsize(m_axi_out0_AWSIZE), .awvalid(m_axi_out0_AWVALID), .awready(m_axi_out0_AWREADY), .wdata(m_axi_out0_WDATA), .wstrb(m_axi_out0_WSTRB), .wlast(m_axi_out0_WLAST), .wvalid(m_axi_out0_WVALID), .wready(m_axi_out0_WREADY), .bresp(m_axi_out0_BRESP), .bvalid(m_axi_out0_BVALID), .bready(m_axi_out0_BREADY),
  .write_address(out0_write_address), .debt_zero(out0_debt_zero),
  .ar_count(out0_ar_count), .r_count(out0_r_count), .aw_count(out0_aw_count), .w_count(out0_w_count), .b_count(out0_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(512), .B_HOLD(9), .R_HOLD(0)) out1_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(64'd0), .arlen(8'd0), .arsize(3'd0), .arvalid(1'b0), .arready(), .rdata(), .rresp(), .rlast(), .rvalid(), .rready(1'b0),
  .read_address(out1_read_address), .read_contents(out1_read_contents),
  .awaddr(m_axi_out1_AWADDR), .awlen(m_axi_out1_AWLEN), .awsize(m_axi_out1_AWSIZE), .awvalid(m_axi_out1_AWVALID), .awready(m_axi_out1_AWREADY), .wdata(m_axi_out1_WDATA), .wstrb(m_axi_out1_WSTRB), .wlast(m_axi_out1_WLAST), .wvalid(m_axi_out1_WVALID), .wready(m_axi_out1_WREADY), .bresp(m_axi_out1_BRESP), .bvalid(m_axi_out1_BVALID), .bready(m_axi_out1_BREADY),
  .write_address(out1_write_address), .debt_zero(out1_debt_zero),
  .ar_count(out1_ar_count), .r_count(out1_r_count), .aw_count(out1_aw_count), .w_count(out1_w_count), .b_count(out1_b_count));
  tm1tn8_axi_memory_slave #(.DATA_W(32), .B_HOLD(12), .R_HOLD(0)) trace_memory (
  .clk(ap_clk), .rst_n(ap_rst_n), .araddr(64'd0), .arlen(8'd0), .arsize(3'd0), .arvalid(1'b0), .arready(), .rdata(), .rresp(), .rlast(), .rvalid(), .rready(1'b0),
  .read_address(trace_read_address), .read_contents(trace_read_contents),
  .awaddr(m_axi_observed_trace_AWADDR), .awlen(m_axi_observed_trace_AWLEN), .awsize(m_axi_observed_trace_AWSIZE), .awvalid(m_axi_observed_trace_AWVALID), .awready(m_axi_observed_trace_AWREADY), .wdata(m_axi_observed_trace_WDATA), .wstrb(m_axi_observed_trace_WSTRB), .wlast(m_axi_observed_trace_WLAST), .wvalid(m_axi_observed_trace_WVALID), .wready(m_axi_observed_trace_WREADY), .bresp(m_axi_observed_trace_BRESP), .bvalid(m_axi_observed_trace_BVALID), .bready(m_axi_observed_trace_BREADY),
  .write_address(trace_write_address), .debt_zero(trace_debt_zero),
  .ar_count(trace_ar_count), .r_count(trace_r_count), .aw_count(trace_aw_count), .w_count(trace_w_count), .b_count(trace_b_count));
  assign m_axi_gmem_descriptor_RID = '0;
  assign m_axi_gmem_descriptor_RUSER = '0;
  assign m_axi_gmem_descriptor_BID = '0;
  assign m_axi_gmem_descriptor_BUSER = '0;
  assign m_axi_gmem_w_q0_RID = '0;
  assign m_axi_gmem_w_q0_RUSER = '0;
  assign m_axi_gmem_w_q0_BID = '0;
  assign m_axi_gmem_w_q0_BUSER = '0;
  assign m_axi_gmem_w_q1_RID = '0;
  assign m_axi_gmem_w_q1_RUSER = '0;
  assign m_axi_gmem_w_q1_BID = '0;
  assign m_axi_gmem_w_q1_BUSER = '0;
  assign m_axi_gmem_w_scale_RID = '0;
  assign m_axi_gmem_w_scale_RUSER = '0;
  assign m_axi_gmem_w_scale_BID = '0;
  assign m_axi_gmem_w_scale_BUSER = '0;
  assign m_axi_gmem_aux_RID = '0;
  assign m_axi_gmem_aux_RUSER = '0;
  assign m_axi_gmem_aux_BID = '0;
  assign m_axi_gmem_aux_BUSER = '0;
  assign m_axi_gmem_activation_RID = '0;
  assign m_axi_gmem_activation_RUSER = '0;
  assign m_axi_gmem_activation_BID = '0;
  assign m_axi_gmem_activation_BUSER = '0;
  assign m_axi_gmem_observed_RID = '0;
  assign m_axi_gmem_observed_RUSER = '0;
  assign m_axi_gmem_observed_BID = '0;
  assign m_axi_gmem_observed_BUSER = '0;
  localparam logic [63:0] Q0_OFFSET=64'd184680448;
  localparam logic [63:0] SCALE_OFFSET=64'd23085056;
  localparam logic [63:0] BIAS_OFFSET=64'd617664;
  localparam bit TRACE_ON=1;
  localparam logic [63:0] DESC_BASE=64'h0000_0004_0000_0000;
  localparam logic [63:0] Q0_BASE=64'h0000_0005_0000_0000;
  localparam logic [63:0] Q1_BASE=64'h0000_0006_0000_0000;
  localparam logic [63:0] SCALE_BASE=64'h0000_0007_0000_0000;
  localparam logic [63:0] AUX_BASE=64'h0000_0008_0000_0000;
  localparam logic [63:0] ACT_BASE=64'h0000_0009_0000_0000;
  localparam logic [63:0] OBS_BASE=64'h0000_0001_0000_1000;
  localparam logic [63:0] OUT0_BASE=64'h0000_0002_0000_0000;
  localparam int REGISTER=0, LOAD1=1, RUN1=2, LOAD2=3, RUN2=4, REVOKE=5;
  int command_mode;
  logic run_mode;
  assign run_mode = command_mode == RUN1 || command_mode == RUN2;
  logic [31:0] register_desc[0:255], load1_desc[0:255],
               run1_desc[0:255], load2_desc[0:255],
               run2_desc[0:255], revoke_desc[0:255];
  logic [63:0] binding_words[0:17];
  logic [511:0] q0_words[0:31], scale_words[0:1], activation_words[0:15];
  logic [31:0] aux_header[0:31], bias_words[0:1];
  logic [31:0] a8q_gold[0:63], half_gold[0:3];
  logic [31:0] output_gold[0:1], trace_gold[0:63];
  logic [31:0] observed_words[0:32767];
  logic [255:0] vdot[0:7], vdotf[0:7], vproduct[0:7], vsw[0:7];
  logic [255:0] vterm[0:7], vps[0:7];
  logic [31:0] vsa[0:7];
  logic [7:0] vmask[0:7];
  int cycles, out_writes, trace_writes, observed_hls_writes;
  int dot_checked, term_checked, commits, quant_checked;
  int weight_bytes_checked, scale_values_checked, bias_values_checked;
  int model_last_r_hold_cycles;
  int binding_beats_checked;
  int load_segment_start, load_segment_end, run_segment_start;
  int first_issue_cycle, last_issue_cycle, last_commit_cycle;
  int last_output_b_cycle, issue_count;
  int source_empty_cycles, issue_stall_cycles, tile_busy_stall_cycles;
  int pipeline_stall_cycles, result_credit_stall_cycles;
  int trace_credit_stall_cycles, output_w_stall_cycles;
  int command_accept_cycle, command_done_cycle, prev_done_cycle;
  string input_dir, vec_dir;

  task automatic compare_lanes(input logic [255:0] actual,
                               input logic [255:0] expected,
                               input logic [7:0] mask,
                               input int seq, input string stage);
    for (int lane=0;lane<8;lane++)
      if (mask[lane] && actual[lane*32 +: 32] !== expected[lane*32 +: 32])
        $fatal(1,"ACT DMA %s mismatch issue=%0d lane=%0d got=%h exp=%h",
               stage,seq,lane,actual[lane*32 +: 32],
               expected[lane*32 +: 32]);
  endtask

  always #3.333 ap_clk=~ap_clk;
  always_comb begin
    descriptor_read_contents='x;
    if (descriptor_read_address>=DESC_BASE &&
        descriptor_read_address<DESC_BASE+1024 &&
        descriptor_read_address[1:0]==0) begin
      case (command_mode)
        REGISTER: descriptor_read_contents=register_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        LOAD1: descriptor_read_contents=load1_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        RUN1: descriptor_read_contents=run1_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        LOAD2: descriptor_read_contents=load2_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        RUN2: descriptor_read_contents=run2_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        REVOKE: descriptor_read_contents=revoke_desc[int'((descriptor_read_address-DESC_BASE)>>2)];
        default: descriptor_read_contents='x;
      endcase
    end
    w_q0_read_contents='x;
    if (w_q0_read_address>=Q0_BASE+Q0_OFFSET &&
        w_q0_read_address<Q0_BASE+Q0_OFFSET+2048 &&
        w_q0_read_address[5:0]==0)
      w_q0_read_contents=q0_words[int'((w_q0_read_address-Q0_BASE-Q0_OFFSET)>>6)];
    w_q1_read_contents='x;
    w_scale_read_contents='x;
    if (w_scale_read_address>=SCALE_BASE+SCALE_OFFSET &&
        w_scale_read_address<SCALE_BASE+SCALE_OFFSET+128 &&
        w_scale_read_address[5:0]==0)
      w_scale_read_contents=scale_words[int'((w_scale_read_address-SCALE_BASE-SCALE_OFFSET)>>6)];
    aux_read_contents='x;
    if (aux_read_address>=AUX_BASE && aux_read_address<AUX_BASE+128 &&
        aux_read_address[1:0]==0)
      aux_read_contents=aux_header[int'((aux_read_address-AUX_BASE)>>2)];
    else if (aux_read_address>=AUX_BASE+BIAS_OFFSET &&
             aux_read_address<AUX_BASE+BIAS_OFFSET+8 &&
             aux_read_address[1:0]==0)
      aux_read_contents=bias_words[int'((aux_read_address-AUX_BASE-BIAS_OFFSET)>>2)];
    activation_read_contents='x;
    if (activation_read_address>=ACT_BASE &&
        activation_read_address<ACT_BASE+1024 &&
        activation_read_address[5:0]==0)
      activation_read_contents=activation_words[int'((activation_read_address-ACT_BASE)>>6)];
    observed_read_contents='x;
    out0_read_contents='x;
    out1_read_contents='x;
    trace_read_contents='x;
  end

  always @(posedge ap_clk) if (ap_rst_n) begin
    int address_word, seq;
    cycles <= cycles+1;
    if (cycles>4000000) $fatal(1,"session v2 ACT cycle timeout");
    if (dut.binding_context_TVALID && dut.binding_context_TREADY)
      binding_beats_checked++;
    if ((w_q0_memory.reading && w_q0_memory.r_delay!=0) ||
        (w_scale_memory.reading && w_scale_memory.r_delay!=0) ||
        (aux_memory.reading && aux_memory.r_delay!=0))
      model_last_r_hold_cycles++;
    // Passive timing and independent quant checks do not change stimulus.
    if (run_mode) begin
      if (dut.bridge.bias_tvalid && dut.bridge.bias_tready) begin
        if (dut.bridge.bias_tdata[273] !== 1'b1 ||
            dut.bridge.bias_tdata[272:265] !== 8'h03 ||
            dut.bridge.bias_tdata[264:256] !== 9'd0 ||
            dut.bridge.bias_tdata[31:0] !== bias_words[0] ||
            dut.bridge.bias_tdata[63:32] !== bias_words[1])
          $fatal(1,"ACT cached bias packet differs from package");
        bias_values_checked+=2;
      end
      if (dut.bridge.group_tvalid && dut.bridge.group_tready) begin
        int qrow,qgroup,qtile,qseq;
        qrow=int'(dut.bridge.group_tdata[2608:2607]);
        qgroup=int'(dut.bridge.group_tdata[2606:2601]);
        qtile=int'(dut.bridge.group_tdata[2600:2592]);
        qseq=qgroup;
        if (qrow!=0 || qgroup>=8 || qtile!=0 ||
            qseq!=quant_checked)
          $fatal(1,"ACT trace-off quant group order row=%0d g=%0d tile=%0d expected=%0d",
                 qrow,qgroup,qtile,quant_checked);
        for (int qword=0;qword<8;qword++)
          if (dut.bridge.group_tdata[qword*32 +: 32] !==
              a8q_gold[qgroup*8+qword])
            $fatal(1,"ACT trace-off quant q mismatch g=%0d word=%0d",
                   qgroup,qword);
        if (dut.bridge.group_tdata[2335:2304] !== vsa[qseq])
          $fatal(1,"ACT trace-off quant scale mismatch g=%0d got=%h exp=%h",
                 qgroup,dut.bridge.group_tdata[2335:2304],vsa[qseq]);
        for (int lane=0;lane<8;lane++) begin
          logic [255:0] expected_q;
          expected_q=q0_words[4*qgroup+lane/2][(lane%2)*256 +: 256];
          if (dut.bridge.group_tdata[256+lane*256 +: 256] !== expected_q)
            $fatal(1,"ACT cached q differs from package group=%0d lane=%0d",
                   qgroup,lane);
          if (dut.bridge.group_tdata[2336+lane*32 +: 32] !==
              vsw[qgroup][lane*32 +: 32])
            $fatal(1,"ACT cached scale differs from independent gold group=%0d lane=%0d",
                   qgroup,lane);
        end
        weight_bytes_checked+=256;
        scale_values_checked+=8;
        quant_checked++;
        if (first_issue_cycle<0) first_issue_cycle=cycles;
        last_issue_cycle=cycles;
        issue_count++;
      end else if (issue_count>0 && issue_count<8) begin
        if (!dut.bridge.group_tvalid) source_empty_cycles++;
        else begin
          issue_stall_cycles++;
          if (dut.bridge.ps_controller.tile_busy[
                  dut.bridge.ps_controller.in_tile])
            tile_busy_stall_cycles++;
          else begin
            pipeline_stall_cycles++;
            if (dut.bridge.result_free==0) result_credit_stall_cycles++;
            if (dut.bridge.trace_free==0) trace_credit_stall_cycles++;
          end
        end
      end
      if (m_axi_out0_WVALID && !m_axi_out0_WREADY)
        output_w_stall_cycles++;
      if (m_axi_out0_BVALID && m_axi_out0_BREADY)
        last_output_b_cycle=cycles;
    end
    if (m_axi_gmem_descriptor_AWVALID || m_axi_gmem_w_q0_AWVALID ||
        m_axi_gmem_w_q1_AWVALID || m_axi_gmem_w_scale_AWVALID ||
        m_axi_gmem_aux_AWVALID || m_axi_gmem_activation_AWVALID ||
        m_axi_gmem_w_q1_ARVALID || m_axi_gmem_observed_ARVALID)
      $fatal(1,"unexpected source write or inactive AXI read");
    if (m_axi_gmem_descriptor_RVALID && m_axi_gmem_descriptor_RREADY &&
        (^descriptor_read_contents===1'bx))
      $fatal(1,"descriptor read outside valid BO");
    if (m_axi_gmem_w_q0_RVALID && m_axi_gmem_w_q0_RREADY &&
        (^w_q0_read_contents===1'bx))
      $fatal(1,"q0 read outside actual package window");
    if (m_axi_gmem_w_scale_RVALID && m_axi_gmem_w_scale_RREADY &&
        (^w_scale_read_contents===1'bx))
      $fatal(1,"scale read outside actual package window");
    if (m_axi_gmem_aux_RVALID && m_axi_gmem_aux_RREADY &&
        (^aux_read_contents===1'bx))
      $fatal(1,"aux read outside actual header/bias window");
    if (m_axi_gmem_activation_RVALID && m_axi_gmem_activation_RREADY &&
        (^activation_read_contents===1'bx))
      $fatal(1,"activation read outside independent source slice");
    if (run_mode && dut.bridge.ps_controller.arithmetic.commit_valid &&
        dut.bridge.ps_controller.arithmetic.commit_ready) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.commit_tag[62:36]);
      if (seq!=commits || seq>=8 ||
          dut.bridge.ps_controller.arithmetic.commit_bad_mask!==0 ||
          dut.bridge.ps_controller.arithmetic.commit_lane_mask!==8'h03)
        $fatal(1,"ACT DMA PS commit tag=%0d expected=%0d",seq,commits);
      compare_lanes(dut.bridge.ps_controller.arithmetic.commit_next_ps,
                    vps[seq],vmask[seq],seq,"PS");
      commits <= commits+1;
      last_commit_cycle=cycles;
    end
    if (m_axi_gmem_observed_WVALID && m_axi_gmem_observed_WREADY) begin
      if (observed_write_address<OBS_BASE ||
          observed_write_address>=OBS_BASE+131072 ||
          observed_write_address[1:0]!=0 ||
          m_axi_gmem_observed_WSTRB!==4'hf)
        $fatal(1,"HLS observed write bounds/strb");
      address_word=int'((observed_write_address-OBS_BASE)>>2);
      if (address_word>=256 &&
          !(run_mode &&
            ((address_word>=256 && address_word<320) ||
             (address_word>=16640 && address_word<16644))))
        $fatal(1,"HLS observed writer overlapped protected region word=%0d",
               address_word);
      observed_words[address_word] <= m_axi_gmem_observed_WDATA;
      observed_hls_writes <= observed_hls_writes+1;
    end
    if (m_axi_observed_trace_WVALID && m_axi_observed_trace_WREADY) begin
      if (!TRACE_ON || !run_mode || trace_writes>=64 ||
          trace_write_address !== OBS_BASE+70656+64'(trace_writes)*4 ||
          m_axi_observed_trace_WSTRB!==4'hf ||
          m_axi_observed_trace_WDATA!==trace_gold[trace_writes])
        $fatal(1,"physical ACT trace word=%0d addr=%h",trace_writes,
               trace_write_address);
      observed_words[17664+trace_writes] <= m_axi_observed_trace_WDATA;
      trace_writes <= trace_writes+1;
    end
    if (m_axi_out0_WVALID && m_axi_out0_WREADY) begin
      if (!run_mode || out_writes!=0 ||
          out0_write_address!==OUT0_BASE ||
          m_axi_out0_WSTRB!==64'h0000_0000_0000_00ff ||
          m_axi_out0_WDATA[31:0]!==output_gold[0] ||
          m_axi_out0_WDATA[63:32]!==output_gold[1])
        $fatal(1,"physical ACT 8-byte output/WSTRB");
      out_writes <= out_writes+1;
    end
    if (m_axi_out1_AWVALID || m_axi_out1_WVALID)
      $fatal(1,"ACT out1 touched");
    if (command_done && (!dut.hls_axi_debt_zero ||
                         !dut.bridge_debt_zero ||
                         !descriptor_debt_zero || !w_q0_debt_zero ||
                         !w_q1_debt_zero || !w_scale_debt_zero ||
                         !aux_debt_zero || !activation_debt_zero ||
                         !observed_debt_zero || !out0_debt_zero ||
                         !out1_debt_zero || !trace_debt_zero))
      $fatal(1,"first command_done before physical/adaptor debt zero");
  end

  always @(negedge ap_clk) if (ap_rst_n && run_mode) begin
    int seq;
    if (dut.bridge.ps_controller.arithmetic.fp_restore.valid_c) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.fp_restore.meta_c.tag[62:36]);
      if (seq<0 || seq>=8) $fatal(1,"ACT converted tag range");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.meta_c.dot,
                    vdot[seq],vmask[seq],seq,"dot");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.dot_float_c,
                    vdotf[seq],vmask[seq],seq,"dotf");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.scale_product_c,
                    vproduct[seq],vmask[seq],seq,"scale product");
      dot_checked++;
    end
    if (dut.bridge.ps_controller.arithmetic.fp_restore.valid_add) begin
      seq=int'(dut.bridge.ps_controller.arithmetic.fp_restore.tag_add[62:36]);
      if (seq<0 || seq>=8) $fatal(1,"ACT term tag range");
      compare_lanes(dut.bridge.ps_controller.arithmetic.fp_restore.term_add,
                    vterm[seq],vmask[seq],seq,"term");
      term_checked++;
    end
  end

  task automatic launch;
    wait(command_ready);
    @(negedge ap_clk);
    if (!command_ready) $fatal(1,"ACT command ready lost before launch");
    command_start=1;
    binding_beats_checked=0;
    command_accept_cycle=cycles+1;
    @(negedge ap_clk); command_start=0;
    wait(command_done);
    command_done_cycle=cycles;
    if (binding_beats_checked!=18)
      $fatal(1,"actual wrapper binding consumed %0d beats",binding_beats_checked);
    if (!dut.hls_axi_debt_zero || !dut.bridge_debt_zero ||
        !descriptor_debt_zero || !w_q0_debt_zero || !w_q1_debt_zero ||
        !w_scale_debt_zero || !aux_debt_zero || !activation_debt_zero ||
        !observed_debt_zero || !out0_debt_zero || !out1_debt_zero ||
        !trace_debt_zero)
      $fatal(1,"ACT first command_done before all physical/adaptor debt zero");
    @(negedge ap_clk);
    if (command_fault) $fatal(1,"joint DMA ACT command fault");
  endtask

  task automatic clear_observed;
    observed_hls_writes=0;
    for (int i=0;i<32768;i++) observed_words[i]=32'hd15ea5ed;
  endtask

  task automatic reset_session;
    command_mode=REGISTER;
    command_start=0;
    ap_rst_n=0;
    w_q0_base=Q0_BASE;
    model_bo_cookie[64 +: 64]=binding_words[8];
    context_cookie={binding_words[1],binding_words[0]};
    model_generation=binding_words[2];
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    clear_observed();
  endtask

  task automatic register_fresh;
    reset_session();
    command_mode=REGISTER;
    launch();
    check_header(2,1,1,0);
    if (aux_r_count!=32 || w_q0_r_count!=0 ||
        w_scale_r_count!=0 || activation_r_count!=0)
      $fatal(1,"negative setup REGISTER physical scope");
  endtask

  task automatic reject_without_task(input string label,
                                     input bit expected_binding_match);
    int descriptor_before, q_before, scale_before, aux_before;
    int activation_before, out_before, trace_before;
    descriptor_before=descriptor_r_count;
    q_before=w_q0_r_count;
    scale_before=w_scale_r_count;
    aux_before=aux_r_count;
    activation_before=activation_r_count;
    out_before=out0_w_count;
    trace_before=trace_w_count;
    clear_observed();
    launch();
    if (observed_hls_writes!=256 || observed_words[3]==0 ||
        observed_words[9]!=0 || observed_words[126]!=0 ||
        observed_words[127]!=32'(expected_binding_match) ||
        descriptor_r_count!=descriptor_before+256 ||
        w_q0_r_count!=q_before || w_scale_r_count!=scale_before ||
        aux_r_count!=aux_before || activation_r_count!=activation_before ||
        out0_w_count!=out_before || trace_w_count!=trace_before)
      $fatal(1,"negative %s rejection mismatch status=%0d task=%0d admission=%0d done=%0d observed_w=%0d desc_r=%0d/%0d q_r=%0d/%0d scale_r=%0d/%0d aux_r=%0d/%0d act_r=%0d/%0d out_w=%0d/%0d trace_w=%0d/%0d",
             label,observed_words[3],observed_words[9],observed_words[126],
             observed_words[127],observed_hls_writes,descriptor_r_count,
             descriptor_before+256,w_q0_r_count,q_before,w_scale_r_count,
             scale_before,aux_r_count,aux_before,activation_r_count,
             activation_before,out0_w_count,out_before,trace_w_count,trace_before);
    $display("TM1TN8_SESSION_DMA_V2_REJECT_PASS case=%s status=%0d session_reject=%0d",
             label,observed_words[3],observed_words[156]);
  endtask

  task automatic check_header(input int expected_command, input int expected_state,
                              input int expected_admission, input int expected_scale_checks);
    if (observed_hls_writes!=256+((run_mode && TRACE_ON) ? 68 : 0) ||
        observed_words[0]!==32'h324f3851 ||
        observed_words[1]!==2 || observed_words[2]!==32'(expected_command) ||
        observed_words[3]!==0 || observed_words[122]!==register_desc[64] ||
        observed_words[123]!==32'(expected_state) ||
        observed_words[126]!==32'(expected_admission) ||
        observed_words[127]!==1 ||
        observed_words[148]!==32'(expected_scale_checks) ||
        observed_words[149]!==0 || observed_words[157]!==1024 ||
        observed_words[158]!==18)
      $fatal(1,"v2 header command=%0d status=%h state=%h admission=%h checks=%h",
             expected_command,observed_words[3],observed_words[123],
             observed_words[126],observed_words[148]);
    for (int i=0;i<8;i++)
      if (observed_words[140+i]!==register_desc[88+i])
        $fatal(1,"compiled build SHA mismatch word=%0d",i);
  endtask

  initial begin : test
    if (!$value$plusargs("INPUT_DIR=%s",input_dir) ||
        !$value$plusargs("VEC_DIR=%s",vec_dir))
      $fatal(1,"INPUT_DIR/VEC_DIR plusargs required");
    $readmemh({input_dir,"/register.hex"},register_desc);
    $readmemh({input_dir,"/load1.hex"},load1_desc);
    $readmemh({input_dir,"/run1.hex"},run1_desc);
    $readmemh({input_dir,"/load2.hex"},load2_desc);
    $readmemh({input_dir,"/run2.hex"},run2_desc);
    $readmemh({input_dir,"/revoke.hex"},revoke_desc);
    $readmemh({input_dir,"/binding.hex"},binding_words);
    $readmemh({input_dir,"/q0.hex"},q0_words);
    $readmemh({input_dir,"/scale.hex"},scale_words);
    $readmemh({input_dir,"/aux_header.hex"},aux_header);
    $readmemh({input_dir,"/bias.hex"},bias_words);
    $readmemh({input_dir,"/activation.hex"},activation_words);
    $readmemh({input_dir,"/a8q.hex"},a8q_gold);
    $readmemh({input_dir,"/a8half.hex"},half_gold);
    $readmemh({input_dir,"/output.hex"},output_gold);
    $readmemh({input_dir,"/trace.hex"},trace_gold);
    $readmemh({vec_dir,"/mask.hex"},vmask);
    $readmemh({vec_dir,"/dot.hex"},vdot);
    $readmemh({vec_dir,"/dotf.hex"},vdotf);
    $readmemh({vec_dir,"/product.hex"},vproduct);
    $readmemh({vec_dir,"/term.hex"},vterm);
    $readmemh({vec_dir,"/ps.hex"},vps);
    $readmemh({vec_dir,"/sw.hex"},vsw);
    $readmemh({vec_dir,"/sa.hex"},vsa);
    ap_clk=0; ap_rst_n=0; command_mode=REGISTER;
    command_start=0; descriptor_base=DESC_BASE;
    w_q0_base=Q0_BASE; w_q1_base=Q1_BASE;
    w_scale_base=SCALE_BASE; aux_base=AUX_BASE;
    activation_base=ACT_BASE;
    observed_base=OBS_BASE; observed_span=131072;
    context_cookie={binding_words[1],binding_words[0]};
    model_generation=binding_words[2];
    embedding_base=binding_words[3];
    for (int i=0;i<5;i++) begin
      model_bo_bytes[i*64 +: 64]=binding_words[4+3*i];
      model_bo_cookie[i*64 +: 64]=binding_words[5+3*i];
    end
    if (binding_words[6]!==Q0_BASE || binding_words[9]!==Q1_BASE ||
        binding_words[12]!==SCALE_BASE || binding_words[15]!==AUX_BASE)
      $fatal(1,"binding source differs from actual latched model pointer");
    cycles=0; out_writes=0; trace_writes=0; observed_hls_writes=0;
    dot_checked=0; term_checked=0; commits=0; quant_checked=0;
    weight_bytes_checked=0;scale_values_checked=0;bias_values_checked=0;
    model_last_r_hold_cycles=0;
    binding_beats_checked=0;
    load_segment_start=0;load_segment_end=0;run_segment_start=0;
    first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
    last_output_b_cycle=-1;issue_count=0;
    source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
    pipeline_stall_cycles=0;result_credit_stall_cycles=0;
    trace_credit_stall_cycles=0;output_w_stall_cycles=0;
    command_accept_cycle=-1;command_done_cycle=-1;prev_done_cycle=-1;
    clear_observed();
    repeat(16) @(negedge ap_clk);
    ap_rst_n=1;
    launch();
    check_header(2,1,1,0);
    if (aux_r_count!=32 || w_q0_r_count!=0 || w_scale_r_count!=0 ||
        descriptor_r_count!=256 || observed_words[9]!=0)
      $fatal(1,"REGISTER physical scope/task");

    for (int load_idx=0;load_idx<2;load_idx++) begin
      command_mode=load_idx==0 ? LOAD1 : LOAD2;
      clear_observed();
      load_segment_start=cycles;
      model_last_r_hold_cycles=0;
      launch();
      load_segment_end=cycles;
      check_header(0,1,2,register_desc[64]==0 ? 64 : 0);
      if (descriptor_r_count!=32'(512+512*load_idx) ||
          w_q0_r_count!=32'(32*(load_idx+1)) ||
          w_scale_r_count!=32'(2*(load_idx+1)) ||
          aux_r_count!=32'(32+34*(load_idx+1)) ||
          activation_r_count!=32'(16*load_idx) ||
          observed_words[9]!=32'(1+3*load_idx) ||
          observed_words[40]!=2 || observed_words[152]!=model_generation[31:0] ||
          model_last_r_hold_cycles==0)
        $fatal(1,"LOAD%0d physical scope/status",load_idx+1);
      command_mode=load_idx==0 ? RUN1 : RUN2;
      out_writes=0;trace_writes=0;dot_checked=0;term_checked=0;
      commits=0;quant_checked=0;
      weight_bytes_checked=0;scale_values_checked=0;bias_values_checked=0;
      first_issue_cycle=-1;last_issue_cycle=-1;last_commit_cycle=-1;
      last_output_b_cycle=-1;issue_count=0;
      source_empty_cycles=0;issue_stall_cycles=0;tile_busy_stall_cycles=0;
      pipeline_stall_cycles=0;result_credit_stall_cycles=0;
      trace_credit_stall_cycles=0;output_w_stall_cycles=0;
      clear_observed();
      run_segment_start=cycles;
      launch();
      check_header(1,1,2,0);
      if (descriptor_r_count!=32'(768+512*load_idx) ||
          activation_r_count!=32'(16*(load_idx+1)) ||
          out0_b_count!=32'(load_idx+1) || out1_b_count!=0 ||
          trace_b_count!=32'((load_idx+1)*(TRACE_ON ? 64 : 0)) ||
          out_writes!=1 || trace_writes!=(TRACE_ON ? 64 : 0) ||
          dot_checked!=8 || term_checked!=8 || commits!=8 || quant_checked!=8 ||
          weight_bytes_checked!=2048 || scale_values_checked!=64 ||
          bias_values_checked!=2 ||
          observed_words[7]!=32'(3+3*load_idx) ||
          observed_words[9]!=32'(3+3*load_idx) ||
          observed_words[12]!=2 || observed_words[29]!=32'(1+load_idx) ||
          observed_words[31]!=32'(1+load_idx) ||
          observed_words[48]!=32'(1+load_idx) ||
          observed_words[49]!=0)
        $fatal(1,"RUN%0d physical/numeric/owner scope",load_idx+1);
      for (int i=256;i<32768;i++) begin
        logic [31:0] expected;
        expected=32'hd15ea5ed;
        if (TRACE_ON && i>=256 && i<320) expected=a8q_gold[i-256];
        else if (TRACE_ON && i>=16640 && i<16644)
          expected=half_gold[i-16640];
        else if (TRACE_ON && i>=17664 && i<17728)
          expected=trace_gold[i-17664];
        if (observed_words[i]!==expected)
          $fatal(1,"observed BO/sentinel mismatch word=%0d",i);
      end
      $display("TM1TN8_SESSION_DMA_V2_ACT_RUN_PASS profile=%0d run=%0d load_cycles=%0d run_cycles=%0d scale_checks=%0d q_bytes=%0d scale_values=%0d bias_values=%0d quant_groups=%0d dot_groups=%0d term_groups=%0d ps_groups=%0d out_writes=%0d trace_writes=%0d",
               register_desc[64],load_idx+1,load_segment_end-load_segment_start,
               cycles-run_segment_start,register_desc[64]==0 ? 64 : 0,
               weight_bytes_checked,scale_values_checked,bias_values_checked,
               quant_checked,dot_checked,term_checked,commits,out_writes,trace_writes);
    end
    command_mode=REVOKE;
    clear_observed();
    launch();
    check_header(3,0,1,0);
    if (descriptor_r_count!=1536 || observed_words[40]!=6 ||
        observed_words[124]!=0 || observed_words[125]!=0)
      $fatal(1,"REVOKE must clear W and ACTIVE generation");
    // A previously legal LOAD cannot consume an epoch or model bytes after REVOKE.
    command_mode=LOAD1;
    clear_observed();
    launch();
    if (observed_words[3]!=7 || observed_words[123]!=0 ||
        observed_words[126]!=0 || observed_words[156]!=1 ||
        w_q0_r_count!=64 || w_scale_r_count!=4 ||
        aux_r_count!=100 || activation_r_count!=32)
      $fatal(1,"post-REVOKE stale LOAD was not rejected before model DMA");
    command_mode=RUN1;
    reject_without_task("post_revoke_run",1);
    reset_session();
    command_mode=LOAD1;
    reject_without_task("post_reset_old_load",1);
    register_fresh();
    command_mode=REGISTER;
    reject_without_task("active_repeat_register",1);
    for (int case_id=0;case_id<10;case_id++) begin
      int old_value;
      register_fresh();
      command_mode=LOAD1;
      case (case_id)
        0: begin old_value=load1_desc[0]; load1_desc[0]=32'h31533851; end
        1: begin old_value=load1_desc[3]; load1_desc[3]=32'h2; end
        2: begin old_value=load1_desc[64]; load1_desc[64]=1-old_value; end
        3: begin old_value=load1_desc[66]; load1_desc[66]=old_value+1; end
        4: begin old_value=load1_desc[68]; load1_desc[68]=old_value^32'h1; end
        5: begin old_value=load1_desc[32]; load1_desc[32]=old_value^32'h1; end
        6: begin old_value=load1_desc[88]; load1_desc[88]=old_value^32'h1; end
        7: begin old_value=load1_desc[124]; load1_desc[124]=old_value-1; end
        8: begin old_value=0; w_q0_base=Q0_BASE+4096; end
        9: begin old_value=0; model_bo_cookie[64 +: 64]=binding_words[8]+1; end
      endcase
      case (case_id)
        0: reject_without_task("old_magic",1);
        1: reject_without_task("reserved_flags",1);
        2: reject_without_task("wrong_profile",1);
        3: reject_without_task("wrong_generation",0);
        4: reject_without_task("wrong_context",0);
        5: reject_without_task("wrong_tag",1);
        6: reject_without_task("wrong_build_digest",1);
        7: reject_without_task("wrong_bo_allocation_size",0);
        8: reject_without_task("actual_bo_base_changed",0);
        9: reject_without_task("actual_bo_cookie_changed",0);
      endcase
      case (case_id)
        0: load1_desc[0]=old_value;
        1: load1_desc[3]=old_value;
        2: load1_desc[64]=old_value;
        3: load1_desc[66]=old_value;
        4: load1_desc[68]=old_value;
        5: load1_desc[32]=old_value;
        6: load1_desc[88]=old_value;
        7: load1_desc[124]=old_value;
        8: w_q0_base=Q0_BASE;
        9: model_bo_cookie[64 +: 64]=binding_words[8];
      endcase
    end
    $display("TM1TN8_SESSION_DMA_V2_ACT_PASS profile=%0d register=1 loads=2 runs=2 revoke=1 reject=14",
             register_desc[64]);
    $finish;
  end
endmodule

