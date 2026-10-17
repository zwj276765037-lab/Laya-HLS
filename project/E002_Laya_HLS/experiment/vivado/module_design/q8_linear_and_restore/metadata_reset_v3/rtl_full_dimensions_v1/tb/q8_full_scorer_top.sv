`timescale 1ns/1ps
// Generated literal binding from the frozen q8_joint_tm4tn8.v port list.
module q8_full_scorer_top;
  logic clk=0;
  always #3.333 clk=~clk;
  logic resetn=0;
  logic m_axi_gmem_descriptor_AWVALID;
  logic m_axi_gmem_descriptor_AWREADY;
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
  logic m_axi_gmem_descriptor_WVALID;
  logic m_axi_gmem_descriptor_WREADY;
  logic [31:0] m_axi_gmem_descriptor_WDATA;
  logic [3:0] m_axi_gmem_descriptor_WSTRB;
  logic m_axi_gmem_descriptor_WLAST;
  logic [0:0] m_axi_gmem_descriptor_WID;
  logic [0:0] m_axi_gmem_descriptor_WUSER;
  logic m_axi_gmem_descriptor_ARVALID;
  logic m_axi_gmem_descriptor_ARREADY;
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
  logic m_axi_gmem_descriptor_RVALID;
  logic m_axi_gmem_descriptor_RREADY;
  logic [31:0] m_axi_gmem_descriptor_RDATA;
  logic m_axi_gmem_descriptor_RLAST;
  logic [0:0] m_axi_gmem_descriptor_RID;
  logic [0:0] m_axi_gmem_descriptor_RUSER;
  logic [1:0] m_axi_gmem_descriptor_RRESP;
  logic m_axi_gmem_descriptor_BVALID;
  logic m_axi_gmem_descriptor_BREADY;
  logic [1:0] m_axi_gmem_descriptor_BRESP;
  logic [0:0] m_axi_gmem_descriptor_BID;
  logic [0:0] m_axi_gmem_descriptor_BUSER;
  logic m_axi_gmem_w_q0_AWVALID;
  logic m_axi_gmem_w_q0_AWREADY;
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
  logic m_axi_gmem_w_q0_WVALID;
  logic m_axi_gmem_w_q0_WREADY;
  logic [511:0] m_axi_gmem_w_q0_WDATA;
  logic [63:0] m_axi_gmem_w_q0_WSTRB;
  logic m_axi_gmem_w_q0_WLAST;
  logic [0:0] m_axi_gmem_w_q0_WID;
  logic [0:0] m_axi_gmem_w_q0_WUSER;
  logic m_axi_gmem_w_q0_ARVALID;
  logic m_axi_gmem_w_q0_ARREADY;
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
  logic m_axi_gmem_w_q0_RVALID;
  logic m_axi_gmem_w_q0_RREADY;
  logic [511:0] m_axi_gmem_w_q0_RDATA;
  logic m_axi_gmem_w_q0_RLAST;
  logic [0:0] m_axi_gmem_w_q0_RID;
  logic [0:0] m_axi_gmem_w_q0_RUSER;
  logic [1:0] m_axi_gmem_w_q0_RRESP;
  logic m_axi_gmem_w_q0_BVALID;
  logic m_axi_gmem_w_q0_BREADY;
  logic [1:0] m_axi_gmem_w_q0_BRESP;
  logic [0:0] m_axi_gmem_w_q0_BID;
  logic [0:0] m_axi_gmem_w_q0_BUSER;
  logic m_axi_gmem_w_q1_AWVALID;
  logic m_axi_gmem_w_q1_AWREADY;
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
  logic m_axi_gmem_w_q1_WVALID;
  logic m_axi_gmem_w_q1_WREADY;
  logic [511:0] m_axi_gmem_w_q1_WDATA;
  logic [63:0] m_axi_gmem_w_q1_WSTRB;
  logic m_axi_gmem_w_q1_WLAST;
  logic [0:0] m_axi_gmem_w_q1_WID;
  logic [0:0] m_axi_gmem_w_q1_WUSER;
  logic m_axi_gmem_w_q1_ARVALID;
  logic m_axi_gmem_w_q1_ARREADY;
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
  logic m_axi_gmem_w_q1_RVALID;
  logic m_axi_gmem_w_q1_RREADY;
  logic [511:0] m_axi_gmem_w_q1_RDATA;
  logic m_axi_gmem_w_q1_RLAST;
  logic [0:0] m_axi_gmem_w_q1_RID;
  logic [0:0] m_axi_gmem_w_q1_RUSER;
  logic [1:0] m_axi_gmem_w_q1_RRESP;
  logic m_axi_gmem_w_q1_BVALID;
  logic m_axi_gmem_w_q1_BREADY;
  logic [1:0] m_axi_gmem_w_q1_BRESP;
  logic [0:0] m_axi_gmem_w_q1_BID;
  logic [0:0] m_axi_gmem_w_q1_BUSER;
  logic m_axi_gmem_w_scale_AWVALID;
  logic m_axi_gmem_w_scale_AWREADY;
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
  logic m_axi_gmem_w_scale_WVALID;
  logic m_axi_gmem_w_scale_WREADY;
  logic [511:0] m_axi_gmem_w_scale_WDATA;
  logic [63:0] m_axi_gmem_w_scale_WSTRB;
  logic m_axi_gmem_w_scale_WLAST;
  logic [0:0] m_axi_gmem_w_scale_WID;
  logic [0:0] m_axi_gmem_w_scale_WUSER;
  logic m_axi_gmem_w_scale_ARVALID;
  logic m_axi_gmem_w_scale_ARREADY;
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
  logic m_axi_gmem_w_scale_RVALID;
  logic m_axi_gmem_w_scale_RREADY;
  logic [511:0] m_axi_gmem_w_scale_RDATA;
  logic m_axi_gmem_w_scale_RLAST;
  logic [0:0] m_axi_gmem_w_scale_RID;
  logic [0:0] m_axi_gmem_w_scale_RUSER;
  logic [1:0] m_axi_gmem_w_scale_RRESP;
  logic m_axi_gmem_w_scale_BVALID;
  logic m_axi_gmem_w_scale_BREADY;
  logic [1:0] m_axi_gmem_w_scale_BRESP;
  logic [0:0] m_axi_gmem_w_scale_BID;
  logic [0:0] m_axi_gmem_w_scale_BUSER;
  logic m_axi_gmem_aux_AWVALID;
  logic m_axi_gmem_aux_AWREADY;
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
  logic m_axi_gmem_aux_WVALID;
  logic m_axi_gmem_aux_WREADY;
  logic [31:0] m_axi_gmem_aux_WDATA;
  logic [3:0] m_axi_gmem_aux_WSTRB;
  logic m_axi_gmem_aux_WLAST;
  logic [0:0] m_axi_gmem_aux_WID;
  logic [0:0] m_axi_gmem_aux_WUSER;
  logic m_axi_gmem_aux_ARVALID;
  logic m_axi_gmem_aux_ARREADY;
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
  logic m_axi_gmem_aux_RVALID;
  logic m_axi_gmem_aux_RREADY;
  logic [31:0] m_axi_gmem_aux_RDATA;
  logic m_axi_gmem_aux_RLAST;
  logic [0:0] m_axi_gmem_aux_RID;
  logic [0:0] m_axi_gmem_aux_RUSER;
  logic [1:0] m_axi_gmem_aux_RRESP;
  logic m_axi_gmem_aux_BVALID;
  logic m_axi_gmem_aux_BREADY;
  logic [1:0] m_axi_gmem_aux_BRESP;
  logic [0:0] m_axi_gmem_aux_BID;
  logic [0:0] m_axi_gmem_aux_BUSER;
  logic m_axi_gmem_activation_AWVALID;
  logic m_axi_gmem_activation_AWREADY;
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
  logic m_axi_gmem_activation_WVALID;
  logic m_axi_gmem_activation_WREADY;
  logic [511:0] m_axi_gmem_activation_WDATA;
  logic [63:0] m_axi_gmem_activation_WSTRB;
  logic m_axi_gmem_activation_WLAST;
  logic [0:0] m_axi_gmem_activation_WID;
  logic [0:0] m_axi_gmem_activation_WUSER;
  logic m_axi_gmem_activation_ARVALID;
  logic m_axi_gmem_activation_ARREADY;
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
  logic m_axi_gmem_activation_RVALID;
  logic m_axi_gmem_activation_RREADY;
  logic [511:0] m_axi_gmem_activation_RDATA;
  logic m_axi_gmem_activation_RLAST;
  logic [0:0] m_axi_gmem_activation_RID;
  logic [0:0] m_axi_gmem_activation_RUSER;
  logic [1:0] m_axi_gmem_activation_RRESP;
  logic m_axi_gmem_activation_BVALID;
  logic m_axi_gmem_activation_BREADY;
  logic [1:0] m_axi_gmem_activation_BRESP;
  logic [0:0] m_axi_gmem_activation_BID;
  logic [0:0] m_axi_gmem_activation_BUSER;
  logic m_axi_gmem_out0_AWVALID;
  logic m_axi_gmem_out0_AWREADY;
  logic [63:0] m_axi_gmem_out0_AWADDR;
  logic [0:0] m_axi_gmem_out0_AWID;
  logic [7:0] m_axi_gmem_out0_AWLEN;
  logic [2:0] m_axi_gmem_out0_AWSIZE;
  logic [1:0] m_axi_gmem_out0_AWBURST;
  logic [1:0] m_axi_gmem_out0_AWLOCK;
  logic [3:0] m_axi_gmem_out0_AWCACHE;
  logic [2:0] m_axi_gmem_out0_AWPROT;
  logic [3:0] m_axi_gmem_out0_AWQOS;
  logic [3:0] m_axi_gmem_out0_AWREGION;
  logic [0:0] m_axi_gmem_out0_AWUSER;
  logic m_axi_gmem_out0_WVALID;
  logic m_axi_gmem_out0_WREADY;
  logic [31:0] m_axi_gmem_out0_WDATA;
  logic [3:0] m_axi_gmem_out0_WSTRB;
  logic m_axi_gmem_out0_WLAST;
  logic [0:0] m_axi_gmem_out0_WID;
  logic [0:0] m_axi_gmem_out0_WUSER;
  logic m_axi_gmem_out0_ARVALID;
  logic m_axi_gmem_out0_ARREADY;
  logic [63:0] m_axi_gmem_out0_ARADDR;
  logic [0:0] m_axi_gmem_out0_ARID;
  logic [7:0] m_axi_gmem_out0_ARLEN;
  logic [2:0] m_axi_gmem_out0_ARSIZE;
  logic [1:0] m_axi_gmem_out0_ARBURST;
  logic [1:0] m_axi_gmem_out0_ARLOCK;
  logic [3:0] m_axi_gmem_out0_ARCACHE;
  logic [2:0] m_axi_gmem_out0_ARPROT;
  logic [3:0] m_axi_gmem_out0_ARQOS;
  logic [3:0] m_axi_gmem_out0_ARREGION;
  logic [0:0] m_axi_gmem_out0_ARUSER;
  logic m_axi_gmem_out0_RVALID;
  logic m_axi_gmem_out0_RREADY;
  logic [31:0] m_axi_gmem_out0_RDATA;
  logic m_axi_gmem_out0_RLAST;
  logic [0:0] m_axi_gmem_out0_RID;
  logic [0:0] m_axi_gmem_out0_RUSER;
  logic [1:0] m_axi_gmem_out0_RRESP;
  logic m_axi_gmem_out0_BVALID;
  logic m_axi_gmem_out0_BREADY;
  logic [1:0] m_axi_gmem_out0_BRESP;
  logic [0:0] m_axi_gmem_out0_BID;
  logic [0:0] m_axi_gmem_out0_BUSER;
  logic m_axi_gmem_out1_AWVALID;
  logic m_axi_gmem_out1_AWREADY;
  logic [63:0] m_axi_gmem_out1_AWADDR;
  logic [0:0] m_axi_gmem_out1_AWID;
  logic [7:0] m_axi_gmem_out1_AWLEN;
  logic [2:0] m_axi_gmem_out1_AWSIZE;
  logic [1:0] m_axi_gmem_out1_AWBURST;
  logic [1:0] m_axi_gmem_out1_AWLOCK;
  logic [3:0] m_axi_gmem_out1_AWCACHE;
  logic [2:0] m_axi_gmem_out1_AWPROT;
  logic [3:0] m_axi_gmem_out1_AWQOS;
  logic [3:0] m_axi_gmem_out1_AWREGION;
  logic [0:0] m_axi_gmem_out1_AWUSER;
  logic m_axi_gmem_out1_WVALID;
  logic m_axi_gmem_out1_WREADY;
  logic [31:0] m_axi_gmem_out1_WDATA;
  logic [3:0] m_axi_gmem_out1_WSTRB;
  logic m_axi_gmem_out1_WLAST;
  logic [0:0] m_axi_gmem_out1_WID;
  logic [0:0] m_axi_gmem_out1_WUSER;
  logic m_axi_gmem_out1_ARVALID;
  logic m_axi_gmem_out1_ARREADY;
  logic [63:0] m_axi_gmem_out1_ARADDR;
  logic [0:0] m_axi_gmem_out1_ARID;
  logic [7:0] m_axi_gmem_out1_ARLEN;
  logic [2:0] m_axi_gmem_out1_ARSIZE;
  logic [1:0] m_axi_gmem_out1_ARBURST;
  logic [1:0] m_axi_gmem_out1_ARLOCK;
  logic [3:0] m_axi_gmem_out1_ARCACHE;
  logic [2:0] m_axi_gmem_out1_ARPROT;
  logic [3:0] m_axi_gmem_out1_ARQOS;
  logic [3:0] m_axi_gmem_out1_ARREGION;
  logic [0:0] m_axi_gmem_out1_ARUSER;
  logic m_axi_gmem_out1_RVALID;
  logic m_axi_gmem_out1_RREADY;
  logic [31:0] m_axi_gmem_out1_RDATA;
  logic m_axi_gmem_out1_RLAST;
  logic [0:0] m_axi_gmem_out1_RID;
  logic [0:0] m_axi_gmem_out1_RUSER;
  logic [1:0] m_axi_gmem_out1_RRESP;
  logic m_axi_gmem_out1_BVALID;
  logic m_axi_gmem_out1_BREADY;
  logic [1:0] m_axi_gmem_out1_BRESP;
  logic [0:0] m_axi_gmem_out1_BID;
  logic [0:0] m_axi_gmem_out1_BUSER;
  logic m_axi_gmem_observed_AWVALID;
  logic m_axi_gmem_observed_AWREADY;
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
  logic m_axi_gmem_observed_WVALID;
  logic m_axi_gmem_observed_WREADY;
  logic [31:0] m_axi_gmem_observed_WDATA;
  logic [3:0] m_axi_gmem_observed_WSTRB;
  logic m_axi_gmem_observed_WLAST;
  logic [0:0] m_axi_gmem_observed_WID;
  logic [0:0] m_axi_gmem_observed_WUSER;
  logic m_axi_gmem_observed_ARVALID;
  logic m_axi_gmem_observed_ARREADY;
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
  logic m_axi_gmem_observed_RVALID;
  logic m_axi_gmem_observed_RREADY;
  logic [31:0] m_axi_gmem_observed_RDATA;
  logic m_axi_gmem_observed_RLAST;
  logic [0:0] m_axi_gmem_observed_RID;
  logic [0:0] m_axi_gmem_observed_RUSER;
  logic [1:0] m_axi_gmem_observed_RRESP;
  logic m_axi_gmem_observed_BVALID;
  logic m_axi_gmem_observed_BREADY;
  logic [1:0] m_axi_gmem_observed_BRESP;
  logic [0:0] m_axi_gmem_observed_BID;
  logic [0:0] m_axi_gmem_observed_BUSER;
  logic s_axi_control_AWVALID;
  logic s_axi_control_AWREADY;
  logic [3:0] s_axi_control_AWADDR;
  logic s_axi_control_WVALID;
  logic s_axi_control_WREADY;
  logic [31:0] s_axi_control_WDATA;
  logic [3:0] s_axi_control_WSTRB;
  logic s_axi_control_ARVALID;
  logic s_axi_control_ARREADY;
  logic [3:0] s_axi_control_ARADDR;
  logic s_axi_control_RVALID;
  logic s_axi_control_RREADY;
  logic [31:0] s_axi_control_RDATA;
  logic [1:0] s_axi_control_RRESP;
  logic s_axi_control_BVALID;
  logic s_axi_control_BREADY;
  logic [1:0] s_axi_control_BRESP;
  logic interrupt;
  logic s_axi_control_r_AWVALID;
  logic s_axi_control_r_AWREADY;
  logic [6:0] s_axi_control_r_AWADDR;
  logic s_axi_control_r_WVALID;
  logic s_axi_control_r_WREADY;
  logic [31:0] s_axi_control_r_WDATA;
  logic [3:0] s_axi_control_r_WSTRB;
  logic s_axi_control_r_ARVALID;
  logic s_axi_control_r_ARREADY;
  logic [6:0] s_axi_control_r_ARADDR;
  logic s_axi_control_r_RVALID;
  logic s_axi_control_r_RREADY;
  logic [31:0] s_axi_control_r_RDATA;
  logic [1:0] s_axi_control_r_RRESP;
  logic s_axi_control_r_BVALID;
  logic s_axi_control_r_BREADY;
  logic [1:0] s_axi_control_r_BRESP;
  q8_joint_tm4tn8 dut (
    .ap_clk(clk),
    .ap_rst_n(resetn),
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
    .m_axi_gmem_out0_AWVALID(m_axi_gmem_out0_AWVALID),
    .m_axi_gmem_out0_AWREADY(m_axi_gmem_out0_AWREADY),
    .m_axi_gmem_out0_AWADDR(m_axi_gmem_out0_AWADDR),
    .m_axi_gmem_out0_AWID(m_axi_gmem_out0_AWID),
    .m_axi_gmem_out0_AWLEN(m_axi_gmem_out0_AWLEN),
    .m_axi_gmem_out0_AWSIZE(m_axi_gmem_out0_AWSIZE),
    .m_axi_gmem_out0_AWBURST(m_axi_gmem_out0_AWBURST),
    .m_axi_gmem_out0_AWLOCK(m_axi_gmem_out0_AWLOCK),
    .m_axi_gmem_out0_AWCACHE(m_axi_gmem_out0_AWCACHE),
    .m_axi_gmem_out0_AWPROT(m_axi_gmem_out0_AWPROT),
    .m_axi_gmem_out0_AWQOS(m_axi_gmem_out0_AWQOS),
    .m_axi_gmem_out0_AWREGION(m_axi_gmem_out0_AWREGION),
    .m_axi_gmem_out0_AWUSER(m_axi_gmem_out0_AWUSER),
    .m_axi_gmem_out0_WVALID(m_axi_gmem_out0_WVALID),
    .m_axi_gmem_out0_WREADY(m_axi_gmem_out0_WREADY),
    .m_axi_gmem_out0_WDATA(m_axi_gmem_out0_WDATA),
    .m_axi_gmem_out0_WSTRB(m_axi_gmem_out0_WSTRB),
    .m_axi_gmem_out0_WLAST(m_axi_gmem_out0_WLAST),
    .m_axi_gmem_out0_WID(m_axi_gmem_out0_WID),
    .m_axi_gmem_out0_WUSER(m_axi_gmem_out0_WUSER),
    .m_axi_gmem_out0_ARVALID(m_axi_gmem_out0_ARVALID),
    .m_axi_gmem_out0_ARREADY(m_axi_gmem_out0_ARREADY),
    .m_axi_gmem_out0_ARADDR(m_axi_gmem_out0_ARADDR),
    .m_axi_gmem_out0_ARID(m_axi_gmem_out0_ARID),
    .m_axi_gmem_out0_ARLEN(m_axi_gmem_out0_ARLEN),
    .m_axi_gmem_out0_ARSIZE(m_axi_gmem_out0_ARSIZE),
    .m_axi_gmem_out0_ARBURST(m_axi_gmem_out0_ARBURST),
    .m_axi_gmem_out0_ARLOCK(m_axi_gmem_out0_ARLOCK),
    .m_axi_gmem_out0_ARCACHE(m_axi_gmem_out0_ARCACHE),
    .m_axi_gmem_out0_ARPROT(m_axi_gmem_out0_ARPROT),
    .m_axi_gmem_out0_ARQOS(m_axi_gmem_out0_ARQOS),
    .m_axi_gmem_out0_ARREGION(m_axi_gmem_out0_ARREGION),
    .m_axi_gmem_out0_ARUSER(m_axi_gmem_out0_ARUSER),
    .m_axi_gmem_out0_RVALID(m_axi_gmem_out0_RVALID),
    .m_axi_gmem_out0_RREADY(m_axi_gmem_out0_RREADY),
    .m_axi_gmem_out0_RDATA(m_axi_gmem_out0_RDATA),
    .m_axi_gmem_out0_RLAST(m_axi_gmem_out0_RLAST),
    .m_axi_gmem_out0_RID(m_axi_gmem_out0_RID),
    .m_axi_gmem_out0_RUSER(m_axi_gmem_out0_RUSER),
    .m_axi_gmem_out0_RRESP(m_axi_gmem_out0_RRESP),
    .m_axi_gmem_out0_BVALID(m_axi_gmem_out0_BVALID),
    .m_axi_gmem_out0_BREADY(m_axi_gmem_out0_BREADY),
    .m_axi_gmem_out0_BRESP(m_axi_gmem_out0_BRESP),
    .m_axi_gmem_out0_BID(m_axi_gmem_out0_BID),
    .m_axi_gmem_out0_BUSER(m_axi_gmem_out0_BUSER),
    .m_axi_gmem_out1_AWVALID(m_axi_gmem_out1_AWVALID),
    .m_axi_gmem_out1_AWREADY(m_axi_gmem_out1_AWREADY),
    .m_axi_gmem_out1_AWADDR(m_axi_gmem_out1_AWADDR),
    .m_axi_gmem_out1_AWID(m_axi_gmem_out1_AWID),
    .m_axi_gmem_out1_AWLEN(m_axi_gmem_out1_AWLEN),
    .m_axi_gmem_out1_AWSIZE(m_axi_gmem_out1_AWSIZE),
    .m_axi_gmem_out1_AWBURST(m_axi_gmem_out1_AWBURST),
    .m_axi_gmem_out1_AWLOCK(m_axi_gmem_out1_AWLOCK),
    .m_axi_gmem_out1_AWCACHE(m_axi_gmem_out1_AWCACHE),
    .m_axi_gmem_out1_AWPROT(m_axi_gmem_out1_AWPROT),
    .m_axi_gmem_out1_AWQOS(m_axi_gmem_out1_AWQOS),
    .m_axi_gmem_out1_AWREGION(m_axi_gmem_out1_AWREGION),
    .m_axi_gmem_out1_AWUSER(m_axi_gmem_out1_AWUSER),
    .m_axi_gmem_out1_WVALID(m_axi_gmem_out1_WVALID),
    .m_axi_gmem_out1_WREADY(m_axi_gmem_out1_WREADY),
    .m_axi_gmem_out1_WDATA(m_axi_gmem_out1_WDATA),
    .m_axi_gmem_out1_WSTRB(m_axi_gmem_out1_WSTRB),
    .m_axi_gmem_out1_WLAST(m_axi_gmem_out1_WLAST),
    .m_axi_gmem_out1_WID(m_axi_gmem_out1_WID),
    .m_axi_gmem_out1_WUSER(m_axi_gmem_out1_WUSER),
    .m_axi_gmem_out1_ARVALID(m_axi_gmem_out1_ARVALID),
    .m_axi_gmem_out1_ARREADY(m_axi_gmem_out1_ARREADY),
    .m_axi_gmem_out1_ARADDR(m_axi_gmem_out1_ARADDR),
    .m_axi_gmem_out1_ARID(m_axi_gmem_out1_ARID),
    .m_axi_gmem_out1_ARLEN(m_axi_gmem_out1_ARLEN),
    .m_axi_gmem_out1_ARSIZE(m_axi_gmem_out1_ARSIZE),
    .m_axi_gmem_out1_ARBURST(m_axi_gmem_out1_ARBURST),
    .m_axi_gmem_out1_ARLOCK(m_axi_gmem_out1_ARLOCK),
    .m_axi_gmem_out1_ARCACHE(m_axi_gmem_out1_ARCACHE),
    .m_axi_gmem_out1_ARPROT(m_axi_gmem_out1_ARPROT),
    .m_axi_gmem_out1_ARQOS(m_axi_gmem_out1_ARQOS),
    .m_axi_gmem_out1_ARREGION(m_axi_gmem_out1_ARREGION),
    .m_axi_gmem_out1_ARUSER(m_axi_gmem_out1_ARUSER),
    .m_axi_gmem_out1_RVALID(m_axi_gmem_out1_RVALID),
    .m_axi_gmem_out1_RREADY(m_axi_gmem_out1_RREADY),
    .m_axi_gmem_out1_RDATA(m_axi_gmem_out1_RDATA),
    .m_axi_gmem_out1_RLAST(m_axi_gmem_out1_RLAST),
    .m_axi_gmem_out1_RID(m_axi_gmem_out1_RID),
    .m_axi_gmem_out1_RUSER(m_axi_gmem_out1_RUSER),
    .m_axi_gmem_out1_RRESP(m_axi_gmem_out1_RRESP),
    .m_axi_gmem_out1_BVALID(m_axi_gmem_out1_BVALID),
    .m_axi_gmem_out1_BREADY(m_axi_gmem_out1_BREADY),
    .m_axi_gmem_out1_BRESP(m_axi_gmem_out1_BRESP),
    .m_axi_gmem_out1_BID(m_axi_gmem_out1_BID),
    .m_axi_gmem_out1_BUSER(m_axi_gmem_out1_BUSER),
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
  logic [31:0] dut_aw_count [0:8];
  logic [31:0] dut_w_count [0:8];
  logic [31:0] dut_b_count [0:8];
  logic [31:0] dut_ar_count [0:8];
  logic [31:0] dut_r_count [0:8];
  logic [31:0] dut_rlast_count [0:8];
  logic [63:0] dut_read_bus_bytes [0:8];
  logic [63:0] dut_write_bus_bytes [0:8];
  logic [63:0] dut_write_useful_bytes [0:8];
  logic dut_write_pending [0:8];
  logic dut_read_pending [0:8];
  logic [31:0] ram_aw_count [0:8];
  logic [31:0] ram_w_count [0:8];
  logic [31:0] ram_b_count [0:8];
  logic [31:0] ram_ar_count [0:8];
  logic [31:0] ram_r_count [0:8];
  logic [31:0] ram_rlast_count [0:8];
  logic [63:0] ram_read_bus_bytes [0:8];
  logic [63:0] ram_write_bus_bytes [0:8];
  logic [63:0] ram_write_useful_bytes [0:8];
  logic ram_write_pending [0:8];
  logic ram_read_pending [0:8];
  logic [31:0] accepted [0:8][0:4], delivered [0:8][0:4];
  logic r_hold_applied [0:8], b_hold_applied [0:8];
  logic [31:0] r_special_wait_cycles [0:8], b_special_wait_cycles [0:8];
  logic hold_final_r [0:8], hold_final_b [0:8];
  logic [1:0][63:0] read_lo [0:8], read_hi [0:8];
  logic [3:0][63:0] write_lo [0:8], write_hi [0:8];
  q8_axi_port #(.DATA_BITS(32),.PORT(0),.PAGE_COUNT(1),
                .PAGE_BASES({64'h0000001000000000})) u_port_descriptor (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[0]),.read_hi(read_hi[0]),
    .write_lo(write_lo[0]),.write_hi(write_hi[0]),
    .hold_final_r(hold_final_r[0]),.hold_final_b(hold_final_b[0]),
    .r_hold_applied(r_hold_applied[0]),.b_hold_applied(b_hold_applied[0]),
    .r_special_wait_cycles(r_special_wait_cycles[0]),
    .b_special_wait_cycles(b_special_wait_cycles[0]),
    .awvalid(m_axi_gmem_descriptor_AWVALID),
    .awready(m_axi_gmem_descriptor_AWREADY),
    .awaddr(m_axi_gmem_descriptor_AWADDR),
    .awid(m_axi_gmem_descriptor_AWID),
    .awlen(m_axi_gmem_descriptor_AWLEN),
    .awsize(m_axi_gmem_descriptor_AWSIZE),
    .awburst(m_axi_gmem_descriptor_AWBURST),
    .awlock(m_axi_gmem_descriptor_AWLOCK),
    .awcache(m_axi_gmem_descriptor_AWCACHE),
    .awprot(m_axi_gmem_descriptor_AWPROT),
    .awqos(m_axi_gmem_descriptor_AWQOS),
    .awregion(m_axi_gmem_descriptor_AWREGION),
    .awuser(m_axi_gmem_descriptor_AWUSER),
    .wvalid(m_axi_gmem_descriptor_WVALID),
    .wready(m_axi_gmem_descriptor_WREADY),
    .wdata(m_axi_gmem_descriptor_WDATA),
    .wstrb(m_axi_gmem_descriptor_WSTRB),
    .wlast(m_axi_gmem_descriptor_WLAST),
    .wid(m_axi_gmem_descriptor_WID),
    .wuser(m_axi_gmem_descriptor_WUSER),
    .arvalid(m_axi_gmem_descriptor_ARVALID),
    .arready(m_axi_gmem_descriptor_ARREADY),
    .araddr(m_axi_gmem_descriptor_ARADDR),
    .arid(m_axi_gmem_descriptor_ARID),
    .arlen(m_axi_gmem_descriptor_ARLEN),
    .arsize(m_axi_gmem_descriptor_ARSIZE),
    .arburst(m_axi_gmem_descriptor_ARBURST),
    .arlock(m_axi_gmem_descriptor_ARLOCK),
    .arcache(m_axi_gmem_descriptor_ARCACHE),
    .arprot(m_axi_gmem_descriptor_ARPROT),
    .arqos(m_axi_gmem_descriptor_ARQOS),
    .arregion(m_axi_gmem_descriptor_ARREGION),
    .aruser(m_axi_gmem_descriptor_ARUSER),
    .rvalid(m_axi_gmem_descriptor_RVALID),
    .rready(m_axi_gmem_descriptor_RREADY),
    .rdata(m_axi_gmem_descriptor_RDATA),
    .rlast(m_axi_gmem_descriptor_RLAST),
    .rid(m_axi_gmem_descriptor_RID),
    .ruser(m_axi_gmem_descriptor_RUSER),
    .rresp(m_axi_gmem_descriptor_RRESP),
    .bvalid(m_axi_gmem_descriptor_BVALID),
    .bready(m_axi_gmem_descriptor_BREADY),
    .bresp(m_axi_gmem_descriptor_BRESP),
    .bid(m_axi_gmem_descriptor_BID),
    .buser(m_axi_gmem_descriptor_BUSER),
    .dut_aw_count(dut_aw_count[0]),
    .dut_w_count(dut_w_count[0]),
    .dut_b_count(dut_b_count[0]),
    .dut_ar_count(dut_ar_count[0]),
    .dut_r_count(dut_r_count[0]),
    .dut_rlast_count(dut_rlast_count[0]),
    .dut_read_bus_bytes(dut_read_bus_bytes[0]),
    .dut_write_bus_bytes(dut_write_bus_bytes[0]),
    .dut_write_useful_bytes(dut_write_useful_bytes[0]),
    .dut_write_pending(dut_write_pending[0]),
    .dut_read_pending(dut_read_pending[0]),
    .ram_aw_count(ram_aw_count[0]),
    .ram_w_count(ram_w_count[0]),
    .ram_b_count(ram_b_count[0]),
    .ram_ar_count(ram_ar_count[0]),
    .ram_r_count(ram_r_count[0]),
    .ram_rlast_count(ram_rlast_count[0]),
    .ram_read_bus_bytes(ram_read_bus_bytes[0]),
    .ram_write_bus_bytes(ram_write_bus_bytes[0]),
    .ram_write_useful_bytes(ram_write_useful_bytes[0]),
    .ram_write_pending(ram_write_pending[0]),
    .ram_read_pending(ram_read_pending[0]),
    .accepted(accepted[0]),.delivered(delivered[0])
  );
  q8_axi_port #(.DATA_BITS(512),.PORT(1),.PAGE_COUNT(128),
                .PAGE_BASES({64'h000000110b01f000,64'h000000110b01e000,64'h000000110b01d000,64'h000000110b01c000,64'h000000110b01b000,64'h000000110b01a000,64'h000000110b019000,64'h000000110b018000,64'h000000110b017000,64'h000000110b016000,64'h000000110b015000,64'h000000110b014000,64'h000000110b013000,64'h000000110b012000,64'h000000110b011000,64'h000000110b010000,64'h000000110b00f000,64'h000000110b00e000,64'h000000110b00d000,64'h000000110b00c000,64'h000000110b00b000,64'h000000110b00a000,64'h000000110b009000,64'h000000110b008000,64'h000000110b007000,64'h000000110b006000,64'h000000110b005000,64'h000000110b004000,64'h000000110b003000,64'h000000110b002000,64'h000000110b001000,64'h000000110b000000,64'h000000110afff000,64'h000000110affe000,64'h000000110affd000,64'h000000110affc000,64'h000000110affb000,64'h000000110affa000,64'h000000110aff9000,64'h000000110aff8000,64'h000000110aff7000,64'h000000110aff6000,64'h000000110aff5000,64'h000000110aff4000,64'h000000110aff3000,64'h000000110aff2000,64'h000000110aff1000,64'h000000110aff0000,64'h000000110afef000,64'h000000110afee000,64'h000000110afed000,64'h000000110afec000,64'h000000110afeb000,64'h000000110afea000,64'h000000110afe9000,64'h000000110afe8000,64'h000000110afe7000,64'h000000110afe6000,64'h000000110afe5000,64'h000000110afe4000,64'h000000110afe3000,64'h000000110afe2000,64'h000000110afe1000,64'h000000110afe0000,64'h000000110afdf000,64'h000000110afde000,64'h000000110afdd000,64'h000000110afdc000,64'h000000110afdb000,64'h000000110afda000,64'h000000110afd9000,64'h000000110afd8000,64'h000000110afd7000,64'h000000110afd6000,64'h000000110afd5000,64'h000000110afd4000,64'h000000110afd3000,64'h000000110afd2000,64'h000000110afd1000,64'h000000110afd0000,64'h000000110afcf000,64'h000000110afce000,64'h000000110afcd000,64'h000000110afcc000,64'h000000110afcb000,64'h000000110afca000,64'h000000110afc9000,64'h000000110afc8000,64'h000000110afc7000,64'h000000110afc6000,64'h000000110afc5000,64'h000000110afc4000,64'h000000110afc3000,64'h000000110afc2000,64'h000000110afc1000,64'h000000110afc0000,64'h000000110afbf000,64'h000000110afbe000,64'h000000110afbd000,64'h000000110afbc000,64'h000000110afbb000,64'h000000110afba000,64'h000000110afb9000,64'h000000110afb8000,64'h000000110afb7000,64'h000000110afb6000,64'h000000110afb5000,64'h000000110afb4000,64'h000000110afb3000,64'h000000110afb2000,64'h000000110afb1000,64'h000000110afb0000,64'h000000110afaf000,64'h000000110afae000,64'h000000110afad000,64'h000000110afac000,64'h000000110afab000,64'h000000110afaa000,64'h000000110afa9000,64'h000000110afa8000,64'h000000110afa7000,64'h000000110afa6000,64'h000000110afa5000,64'h000000110afa4000,64'h000000110afa3000,64'h000000110afa2000,64'h000000110afa1000,64'h000000110afa0000})) u_port_w_q0 (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[1]),.read_hi(read_hi[1]),
    .write_lo(write_lo[1]),.write_hi(write_hi[1]),
    .hold_final_r(hold_final_r[1]),.hold_final_b(hold_final_b[1]),
    .r_hold_applied(r_hold_applied[1]),.b_hold_applied(b_hold_applied[1]),
    .r_special_wait_cycles(r_special_wait_cycles[1]),
    .b_special_wait_cycles(b_special_wait_cycles[1]),
    .awvalid(m_axi_gmem_w_q0_AWVALID),
    .awready(m_axi_gmem_w_q0_AWREADY),
    .awaddr(m_axi_gmem_w_q0_AWADDR),
    .awid(m_axi_gmem_w_q0_AWID),
    .awlen(m_axi_gmem_w_q0_AWLEN),
    .awsize(m_axi_gmem_w_q0_AWSIZE),
    .awburst(m_axi_gmem_w_q0_AWBURST),
    .awlock(m_axi_gmem_w_q0_AWLOCK),
    .awcache(m_axi_gmem_w_q0_AWCACHE),
    .awprot(m_axi_gmem_w_q0_AWPROT),
    .awqos(m_axi_gmem_w_q0_AWQOS),
    .awregion(m_axi_gmem_w_q0_AWREGION),
    .awuser(m_axi_gmem_w_q0_AWUSER),
    .wvalid(m_axi_gmem_w_q0_WVALID),
    .wready(m_axi_gmem_w_q0_WREADY),
    .wdata(m_axi_gmem_w_q0_WDATA),
    .wstrb(m_axi_gmem_w_q0_WSTRB),
    .wlast(m_axi_gmem_w_q0_WLAST),
    .wid(m_axi_gmem_w_q0_WID),
    .wuser(m_axi_gmem_w_q0_WUSER),
    .arvalid(m_axi_gmem_w_q0_ARVALID),
    .arready(m_axi_gmem_w_q0_ARREADY),
    .araddr(m_axi_gmem_w_q0_ARADDR),
    .arid(m_axi_gmem_w_q0_ARID),
    .arlen(m_axi_gmem_w_q0_ARLEN),
    .arsize(m_axi_gmem_w_q0_ARSIZE),
    .arburst(m_axi_gmem_w_q0_ARBURST),
    .arlock(m_axi_gmem_w_q0_ARLOCK),
    .arcache(m_axi_gmem_w_q0_ARCACHE),
    .arprot(m_axi_gmem_w_q0_ARPROT),
    .arqos(m_axi_gmem_w_q0_ARQOS),
    .arregion(m_axi_gmem_w_q0_ARREGION),
    .aruser(m_axi_gmem_w_q0_ARUSER),
    .rvalid(m_axi_gmem_w_q0_RVALID),
    .rready(m_axi_gmem_w_q0_RREADY),
    .rdata(m_axi_gmem_w_q0_RDATA),
    .rlast(m_axi_gmem_w_q0_RLAST),
    .rid(m_axi_gmem_w_q0_RID),
    .ruser(m_axi_gmem_w_q0_RUSER),
    .rresp(m_axi_gmem_w_q0_RRESP),
    .bvalid(m_axi_gmem_w_q0_BVALID),
    .bready(m_axi_gmem_w_q0_BREADY),
    .bresp(m_axi_gmem_w_q0_BRESP),
    .bid(m_axi_gmem_w_q0_BID),
    .buser(m_axi_gmem_w_q0_BUSER),
    .dut_aw_count(dut_aw_count[1]),
    .dut_w_count(dut_w_count[1]),
    .dut_b_count(dut_b_count[1]),
    .dut_ar_count(dut_ar_count[1]),
    .dut_r_count(dut_r_count[1]),
    .dut_rlast_count(dut_rlast_count[1]),
    .dut_read_bus_bytes(dut_read_bus_bytes[1]),
    .dut_write_bus_bytes(dut_write_bus_bytes[1]),
    .dut_write_useful_bytes(dut_write_useful_bytes[1]),
    .dut_write_pending(dut_write_pending[1]),
    .dut_read_pending(dut_read_pending[1]),
    .ram_aw_count(ram_aw_count[1]),
    .ram_w_count(ram_w_count[1]),
    .ram_b_count(ram_b_count[1]),
    .ram_ar_count(ram_ar_count[1]),
    .ram_r_count(ram_r_count[1]),
    .ram_rlast_count(ram_rlast_count[1]),
    .ram_read_bus_bytes(ram_read_bus_bytes[1]),
    .ram_write_bus_bytes(ram_write_bus_bytes[1]),
    .ram_write_useful_bytes(ram_write_useful_bytes[1]),
    .ram_write_pending(ram_write_pending[1]),
    .ram_read_pending(ram_read_pending[1]),
    .accepted(accepted[1]),.delivered(delivered[1])
  );
  q8_axi_port #(.DATA_BITS(512),.PORT(2),.PAGE_COUNT(128),
                .PAGE_BASES({64'h000000120b01f000,64'h000000120b01e000,64'h000000120b01d000,64'h000000120b01c000,64'h000000120b01b000,64'h000000120b01a000,64'h000000120b019000,64'h000000120b018000,64'h000000120b017000,64'h000000120b016000,64'h000000120b015000,64'h000000120b014000,64'h000000120b013000,64'h000000120b012000,64'h000000120b011000,64'h000000120b010000,64'h000000120b00f000,64'h000000120b00e000,64'h000000120b00d000,64'h000000120b00c000,64'h000000120b00b000,64'h000000120b00a000,64'h000000120b009000,64'h000000120b008000,64'h000000120b007000,64'h000000120b006000,64'h000000120b005000,64'h000000120b004000,64'h000000120b003000,64'h000000120b002000,64'h000000120b001000,64'h000000120b000000,64'h000000120afff000,64'h000000120affe000,64'h000000120affd000,64'h000000120affc000,64'h000000120affb000,64'h000000120affa000,64'h000000120aff9000,64'h000000120aff8000,64'h000000120aff7000,64'h000000120aff6000,64'h000000120aff5000,64'h000000120aff4000,64'h000000120aff3000,64'h000000120aff2000,64'h000000120aff1000,64'h000000120aff0000,64'h000000120afef000,64'h000000120afee000,64'h000000120afed000,64'h000000120afec000,64'h000000120afeb000,64'h000000120afea000,64'h000000120afe9000,64'h000000120afe8000,64'h000000120afe7000,64'h000000120afe6000,64'h000000120afe5000,64'h000000120afe4000,64'h000000120afe3000,64'h000000120afe2000,64'h000000120afe1000,64'h000000120afe0000,64'h000000120afdf000,64'h000000120afde000,64'h000000120afdd000,64'h000000120afdc000,64'h000000120afdb000,64'h000000120afda000,64'h000000120afd9000,64'h000000120afd8000,64'h000000120afd7000,64'h000000120afd6000,64'h000000120afd5000,64'h000000120afd4000,64'h000000120afd3000,64'h000000120afd2000,64'h000000120afd1000,64'h000000120afd0000,64'h000000120afcf000,64'h000000120afce000,64'h000000120afcd000,64'h000000120afcc000,64'h000000120afcb000,64'h000000120afca000,64'h000000120afc9000,64'h000000120afc8000,64'h000000120afc7000,64'h000000120afc6000,64'h000000120afc5000,64'h000000120afc4000,64'h000000120afc3000,64'h000000120afc2000,64'h000000120afc1000,64'h000000120afc0000,64'h000000120afbf000,64'h000000120afbe000,64'h000000120afbd000,64'h000000120afbc000,64'h000000120afbb000,64'h000000120afba000,64'h000000120afb9000,64'h000000120afb8000,64'h000000120afb7000,64'h000000120afb6000,64'h000000120afb5000,64'h000000120afb4000,64'h000000120afb3000,64'h000000120afb2000,64'h000000120afb1000,64'h000000120afb0000,64'h000000120afaf000,64'h000000120afae000,64'h000000120afad000,64'h000000120afac000,64'h000000120afab000,64'h000000120afaa000,64'h000000120afa9000,64'h000000120afa8000,64'h000000120afa7000,64'h000000120afa6000,64'h000000120afa5000,64'h000000120afa4000,64'h000000120afa3000,64'h000000120afa2000,64'h000000120afa1000,64'h000000120afa0000})) u_port_w_q1 (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[2]),.read_hi(read_hi[2]),
    .write_lo(write_lo[2]),.write_hi(write_hi[2]),
    .hold_final_r(hold_final_r[2]),.hold_final_b(hold_final_b[2]),
    .r_hold_applied(r_hold_applied[2]),.b_hold_applied(b_hold_applied[2]),
    .r_special_wait_cycles(r_special_wait_cycles[2]),
    .b_special_wait_cycles(b_special_wait_cycles[2]),
    .awvalid(m_axi_gmem_w_q1_AWVALID),
    .awready(m_axi_gmem_w_q1_AWREADY),
    .awaddr(m_axi_gmem_w_q1_AWADDR),
    .awid(m_axi_gmem_w_q1_AWID),
    .awlen(m_axi_gmem_w_q1_AWLEN),
    .awsize(m_axi_gmem_w_q1_AWSIZE),
    .awburst(m_axi_gmem_w_q1_AWBURST),
    .awlock(m_axi_gmem_w_q1_AWLOCK),
    .awcache(m_axi_gmem_w_q1_AWCACHE),
    .awprot(m_axi_gmem_w_q1_AWPROT),
    .awqos(m_axi_gmem_w_q1_AWQOS),
    .awregion(m_axi_gmem_w_q1_AWREGION),
    .awuser(m_axi_gmem_w_q1_AWUSER),
    .wvalid(m_axi_gmem_w_q1_WVALID),
    .wready(m_axi_gmem_w_q1_WREADY),
    .wdata(m_axi_gmem_w_q1_WDATA),
    .wstrb(m_axi_gmem_w_q1_WSTRB),
    .wlast(m_axi_gmem_w_q1_WLAST),
    .wid(m_axi_gmem_w_q1_WID),
    .wuser(m_axi_gmem_w_q1_WUSER),
    .arvalid(m_axi_gmem_w_q1_ARVALID),
    .arready(m_axi_gmem_w_q1_ARREADY),
    .araddr(m_axi_gmem_w_q1_ARADDR),
    .arid(m_axi_gmem_w_q1_ARID),
    .arlen(m_axi_gmem_w_q1_ARLEN),
    .arsize(m_axi_gmem_w_q1_ARSIZE),
    .arburst(m_axi_gmem_w_q1_ARBURST),
    .arlock(m_axi_gmem_w_q1_ARLOCK),
    .arcache(m_axi_gmem_w_q1_ARCACHE),
    .arprot(m_axi_gmem_w_q1_ARPROT),
    .arqos(m_axi_gmem_w_q1_ARQOS),
    .arregion(m_axi_gmem_w_q1_ARREGION),
    .aruser(m_axi_gmem_w_q1_ARUSER),
    .rvalid(m_axi_gmem_w_q1_RVALID),
    .rready(m_axi_gmem_w_q1_RREADY),
    .rdata(m_axi_gmem_w_q1_RDATA),
    .rlast(m_axi_gmem_w_q1_RLAST),
    .rid(m_axi_gmem_w_q1_RID),
    .ruser(m_axi_gmem_w_q1_RUSER),
    .rresp(m_axi_gmem_w_q1_RRESP),
    .bvalid(m_axi_gmem_w_q1_BVALID),
    .bready(m_axi_gmem_w_q1_BREADY),
    .bresp(m_axi_gmem_w_q1_BRESP),
    .bid(m_axi_gmem_w_q1_BID),
    .buser(m_axi_gmem_w_q1_BUSER),
    .dut_aw_count(dut_aw_count[2]),
    .dut_w_count(dut_w_count[2]),
    .dut_b_count(dut_b_count[2]),
    .dut_ar_count(dut_ar_count[2]),
    .dut_r_count(dut_r_count[2]),
    .dut_rlast_count(dut_rlast_count[2]),
    .dut_read_bus_bytes(dut_read_bus_bytes[2]),
    .dut_write_bus_bytes(dut_write_bus_bytes[2]),
    .dut_write_useful_bytes(dut_write_useful_bytes[2]),
    .dut_write_pending(dut_write_pending[2]),
    .dut_read_pending(dut_read_pending[2]),
    .ram_aw_count(ram_aw_count[2]),
    .ram_w_count(ram_w_count[2]),
    .ram_b_count(ram_b_count[2]),
    .ram_ar_count(ram_ar_count[2]),
    .ram_r_count(ram_r_count[2]),
    .ram_rlast_count(ram_rlast_count[2]),
    .ram_read_bus_bytes(ram_read_bus_bytes[2]),
    .ram_write_bus_bytes(ram_write_bus_bytes[2]),
    .ram_write_useful_bytes(ram_write_useful_bytes[2]),
    .ram_write_pending(ram_write_pending[2]),
    .ram_read_pending(ram_read_pending[2]),
    .accepted(accepted[2]),.delivered(delivered[2])
  );
  q8_axi_port #(.DATA_BITS(512),.PORT(3),.PAGE_COUNT(16),
                .PAGE_BASES({64'h0000001301603000,64'h0000001301602000,64'h0000001301601000,64'h0000001301600000,64'h00000013015ff000,64'h00000013015fe000,64'h00000013015fd000,64'h00000013015fc000,64'h00000013015fb000,64'h00000013015fa000,64'h00000013015f9000,64'h00000013015f8000,64'h00000013015f7000,64'h00000013015f6000,64'h00000013015f5000,64'h00000013015f4000})) u_port_w_scale (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[3]),.read_hi(read_hi[3]),
    .write_lo(write_lo[3]),.write_hi(write_hi[3]),
    .hold_final_r(hold_final_r[3]),.hold_final_b(hold_final_b[3]),
    .r_hold_applied(r_hold_applied[3]),.b_hold_applied(b_hold_applied[3]),
    .r_special_wait_cycles(r_special_wait_cycles[3]),
    .b_special_wait_cycles(b_special_wait_cycles[3]),
    .awvalid(m_axi_gmem_w_scale_AWVALID),
    .awready(m_axi_gmem_w_scale_AWREADY),
    .awaddr(m_axi_gmem_w_scale_AWADDR),
    .awid(m_axi_gmem_w_scale_AWID),
    .awlen(m_axi_gmem_w_scale_AWLEN),
    .awsize(m_axi_gmem_w_scale_AWSIZE),
    .awburst(m_axi_gmem_w_scale_AWBURST),
    .awlock(m_axi_gmem_w_scale_AWLOCK),
    .awcache(m_axi_gmem_w_scale_AWCACHE),
    .awprot(m_axi_gmem_w_scale_AWPROT),
    .awqos(m_axi_gmem_w_scale_AWQOS),
    .awregion(m_axi_gmem_w_scale_AWREGION),
    .awuser(m_axi_gmem_w_scale_AWUSER),
    .wvalid(m_axi_gmem_w_scale_WVALID),
    .wready(m_axi_gmem_w_scale_WREADY),
    .wdata(m_axi_gmem_w_scale_WDATA),
    .wstrb(m_axi_gmem_w_scale_WSTRB),
    .wlast(m_axi_gmem_w_scale_WLAST),
    .wid(m_axi_gmem_w_scale_WID),
    .wuser(m_axi_gmem_w_scale_WUSER),
    .arvalid(m_axi_gmem_w_scale_ARVALID),
    .arready(m_axi_gmem_w_scale_ARREADY),
    .araddr(m_axi_gmem_w_scale_ARADDR),
    .arid(m_axi_gmem_w_scale_ARID),
    .arlen(m_axi_gmem_w_scale_ARLEN),
    .arsize(m_axi_gmem_w_scale_ARSIZE),
    .arburst(m_axi_gmem_w_scale_ARBURST),
    .arlock(m_axi_gmem_w_scale_ARLOCK),
    .arcache(m_axi_gmem_w_scale_ARCACHE),
    .arprot(m_axi_gmem_w_scale_ARPROT),
    .arqos(m_axi_gmem_w_scale_ARQOS),
    .arregion(m_axi_gmem_w_scale_ARREGION),
    .aruser(m_axi_gmem_w_scale_ARUSER),
    .rvalid(m_axi_gmem_w_scale_RVALID),
    .rready(m_axi_gmem_w_scale_RREADY),
    .rdata(m_axi_gmem_w_scale_RDATA),
    .rlast(m_axi_gmem_w_scale_RLAST),
    .rid(m_axi_gmem_w_scale_RID),
    .ruser(m_axi_gmem_w_scale_RUSER),
    .rresp(m_axi_gmem_w_scale_RRESP),
    .bvalid(m_axi_gmem_w_scale_BVALID),
    .bready(m_axi_gmem_w_scale_BREADY),
    .bresp(m_axi_gmem_w_scale_BRESP),
    .bid(m_axi_gmem_w_scale_BID),
    .buser(m_axi_gmem_w_scale_BUSER),
    .dut_aw_count(dut_aw_count[3]),
    .dut_w_count(dut_w_count[3]),
    .dut_b_count(dut_b_count[3]),
    .dut_ar_count(dut_ar_count[3]),
    .dut_r_count(dut_r_count[3]),
    .dut_rlast_count(dut_rlast_count[3]),
    .dut_read_bus_bytes(dut_read_bus_bytes[3]),
    .dut_write_bus_bytes(dut_write_bus_bytes[3]),
    .dut_write_useful_bytes(dut_write_useful_bytes[3]),
    .dut_write_pending(dut_write_pending[3]),
    .dut_read_pending(dut_read_pending[3]),
    .ram_aw_count(ram_aw_count[3]),
    .ram_w_count(ram_w_count[3]),
    .ram_b_count(ram_b_count[3]),
    .ram_ar_count(ram_ar_count[3]),
    .ram_r_count(ram_r_count[3]),
    .ram_rlast_count(ram_rlast_count[3]),
    .ram_read_bus_bytes(ram_read_bus_bytes[3]),
    .ram_write_bus_bytes(ram_write_bus_bytes[3]),
    .ram_write_useful_bytes(ram_write_useful_bytes[3]),
    .ram_write_pending(ram_write_pending[3]),
    .ram_read_pending(ram_read_pending[3]),
    .accepted(accepted[3]),.delivered(delivered[3])
  );
  q8_axi_port #(.DATA_BITS(32),.PORT(4),.PAGE_COUNT(3),
                .PAGE_BASES({64'h0000001400198000,64'h0000001400197000,64'h0000001400000000})) u_port_aux (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[4]),.read_hi(read_hi[4]),
    .write_lo(write_lo[4]),.write_hi(write_hi[4]),
    .hold_final_r(hold_final_r[4]),.hold_final_b(hold_final_b[4]),
    .r_hold_applied(r_hold_applied[4]),.b_hold_applied(b_hold_applied[4]),
    .r_special_wait_cycles(r_special_wait_cycles[4]),
    .b_special_wait_cycles(b_special_wait_cycles[4]),
    .awvalid(m_axi_gmem_aux_AWVALID),
    .awready(m_axi_gmem_aux_AWREADY),
    .awaddr(m_axi_gmem_aux_AWADDR),
    .awid(m_axi_gmem_aux_AWID),
    .awlen(m_axi_gmem_aux_AWLEN),
    .awsize(m_axi_gmem_aux_AWSIZE),
    .awburst(m_axi_gmem_aux_AWBURST),
    .awlock(m_axi_gmem_aux_AWLOCK),
    .awcache(m_axi_gmem_aux_AWCACHE),
    .awprot(m_axi_gmem_aux_AWPROT),
    .awqos(m_axi_gmem_aux_AWQOS),
    .awregion(m_axi_gmem_aux_AWREGION),
    .awuser(m_axi_gmem_aux_AWUSER),
    .wvalid(m_axi_gmem_aux_WVALID),
    .wready(m_axi_gmem_aux_WREADY),
    .wdata(m_axi_gmem_aux_WDATA),
    .wstrb(m_axi_gmem_aux_WSTRB),
    .wlast(m_axi_gmem_aux_WLAST),
    .wid(m_axi_gmem_aux_WID),
    .wuser(m_axi_gmem_aux_WUSER),
    .arvalid(m_axi_gmem_aux_ARVALID),
    .arready(m_axi_gmem_aux_ARREADY),
    .araddr(m_axi_gmem_aux_ARADDR),
    .arid(m_axi_gmem_aux_ARID),
    .arlen(m_axi_gmem_aux_ARLEN),
    .arsize(m_axi_gmem_aux_ARSIZE),
    .arburst(m_axi_gmem_aux_ARBURST),
    .arlock(m_axi_gmem_aux_ARLOCK),
    .arcache(m_axi_gmem_aux_ARCACHE),
    .arprot(m_axi_gmem_aux_ARPROT),
    .arqos(m_axi_gmem_aux_ARQOS),
    .arregion(m_axi_gmem_aux_ARREGION),
    .aruser(m_axi_gmem_aux_ARUSER),
    .rvalid(m_axi_gmem_aux_RVALID),
    .rready(m_axi_gmem_aux_RREADY),
    .rdata(m_axi_gmem_aux_RDATA),
    .rlast(m_axi_gmem_aux_RLAST),
    .rid(m_axi_gmem_aux_RID),
    .ruser(m_axi_gmem_aux_RUSER),
    .rresp(m_axi_gmem_aux_RRESP),
    .bvalid(m_axi_gmem_aux_BVALID),
    .bready(m_axi_gmem_aux_BREADY),
    .bresp(m_axi_gmem_aux_BRESP),
    .bid(m_axi_gmem_aux_BID),
    .buser(m_axi_gmem_aux_BUSER),
    .dut_aw_count(dut_aw_count[4]),
    .dut_w_count(dut_w_count[4]),
    .dut_b_count(dut_b_count[4]),
    .dut_ar_count(dut_ar_count[4]),
    .dut_r_count(dut_r_count[4]),
    .dut_rlast_count(dut_rlast_count[4]),
    .dut_read_bus_bytes(dut_read_bus_bytes[4]),
    .dut_write_bus_bytes(dut_write_bus_bytes[4]),
    .dut_write_useful_bytes(dut_write_useful_bytes[4]),
    .dut_write_pending(dut_write_pending[4]),
    .dut_read_pending(dut_read_pending[4]),
    .ram_aw_count(ram_aw_count[4]),
    .ram_w_count(ram_w_count[4]),
    .ram_b_count(ram_b_count[4]),
    .ram_ar_count(ram_ar_count[4]),
    .ram_r_count(ram_r_count[4]),
    .ram_rlast_count(ram_rlast_count[4]),
    .ram_read_bus_bytes(ram_read_bus_bytes[4]),
    .ram_write_bus_bytes(ram_write_bus_bytes[4]),
    .ram_write_useful_bytes(ram_write_useful_bytes[4]),
    .ram_write_pending(ram_write_pending[4]),
    .ram_read_pending(ram_read_pending[4]),
    .accepted(accepted[4]),.delivered(delivered[4])
  );
  q8_axi_port #(.DATA_BITS(512),.PORT(5),.PAGE_COUNT(16),
                .PAGE_BASES({64'h000000150000f000,64'h000000150000e000,64'h000000150000d000,64'h000000150000c000,64'h000000150000b000,64'h000000150000a000,64'h0000001500009000,64'h0000001500008000,64'h0000001500007000,64'h0000001500006000,64'h0000001500005000,64'h0000001500004000,64'h0000001500003000,64'h0000001500002000,64'h0000001500001000,64'h0000001500000000})) u_port_activation (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[5]),.read_hi(read_hi[5]),
    .write_lo(write_lo[5]),.write_hi(write_hi[5]),
    .hold_final_r(hold_final_r[5]),.hold_final_b(hold_final_b[5]),
    .r_hold_applied(r_hold_applied[5]),.b_hold_applied(b_hold_applied[5]),
    .r_special_wait_cycles(r_special_wait_cycles[5]),
    .b_special_wait_cycles(b_special_wait_cycles[5]),
    .awvalid(m_axi_gmem_activation_AWVALID),
    .awready(m_axi_gmem_activation_AWREADY),
    .awaddr(m_axi_gmem_activation_AWADDR),
    .awid(m_axi_gmem_activation_AWID),
    .awlen(m_axi_gmem_activation_AWLEN),
    .awsize(m_axi_gmem_activation_AWSIZE),
    .awburst(m_axi_gmem_activation_AWBURST),
    .awlock(m_axi_gmem_activation_AWLOCK),
    .awcache(m_axi_gmem_activation_AWCACHE),
    .awprot(m_axi_gmem_activation_AWPROT),
    .awqos(m_axi_gmem_activation_AWQOS),
    .awregion(m_axi_gmem_activation_AWREGION),
    .awuser(m_axi_gmem_activation_AWUSER),
    .wvalid(m_axi_gmem_activation_WVALID),
    .wready(m_axi_gmem_activation_WREADY),
    .wdata(m_axi_gmem_activation_WDATA),
    .wstrb(m_axi_gmem_activation_WSTRB),
    .wlast(m_axi_gmem_activation_WLAST),
    .wid(m_axi_gmem_activation_WID),
    .wuser(m_axi_gmem_activation_WUSER),
    .arvalid(m_axi_gmem_activation_ARVALID),
    .arready(m_axi_gmem_activation_ARREADY),
    .araddr(m_axi_gmem_activation_ARADDR),
    .arid(m_axi_gmem_activation_ARID),
    .arlen(m_axi_gmem_activation_ARLEN),
    .arsize(m_axi_gmem_activation_ARSIZE),
    .arburst(m_axi_gmem_activation_ARBURST),
    .arlock(m_axi_gmem_activation_ARLOCK),
    .arcache(m_axi_gmem_activation_ARCACHE),
    .arprot(m_axi_gmem_activation_ARPROT),
    .arqos(m_axi_gmem_activation_ARQOS),
    .arregion(m_axi_gmem_activation_ARREGION),
    .aruser(m_axi_gmem_activation_ARUSER),
    .rvalid(m_axi_gmem_activation_RVALID),
    .rready(m_axi_gmem_activation_RREADY),
    .rdata(m_axi_gmem_activation_RDATA),
    .rlast(m_axi_gmem_activation_RLAST),
    .rid(m_axi_gmem_activation_RID),
    .ruser(m_axi_gmem_activation_RUSER),
    .rresp(m_axi_gmem_activation_RRESP),
    .bvalid(m_axi_gmem_activation_BVALID),
    .bready(m_axi_gmem_activation_BREADY),
    .bresp(m_axi_gmem_activation_BRESP),
    .bid(m_axi_gmem_activation_BID),
    .buser(m_axi_gmem_activation_BUSER),
    .dut_aw_count(dut_aw_count[5]),
    .dut_w_count(dut_w_count[5]),
    .dut_b_count(dut_b_count[5]),
    .dut_ar_count(dut_ar_count[5]),
    .dut_r_count(dut_r_count[5]),
    .dut_rlast_count(dut_rlast_count[5]),
    .dut_read_bus_bytes(dut_read_bus_bytes[5]),
    .dut_write_bus_bytes(dut_write_bus_bytes[5]),
    .dut_write_useful_bytes(dut_write_useful_bytes[5]),
    .dut_write_pending(dut_write_pending[5]),
    .dut_read_pending(dut_read_pending[5]),
    .ram_aw_count(ram_aw_count[5]),
    .ram_w_count(ram_w_count[5]),
    .ram_b_count(ram_b_count[5]),
    .ram_ar_count(ram_ar_count[5]),
    .ram_r_count(ram_r_count[5]),
    .ram_rlast_count(ram_rlast_count[5]),
    .ram_read_bus_bytes(ram_read_bus_bytes[5]),
    .ram_write_bus_bytes(ram_write_bus_bytes[5]),
    .ram_write_useful_bytes(ram_write_useful_bytes[5]),
    .ram_write_pending(ram_write_pending[5]),
    .ram_read_pending(ram_read_pending[5]),
    .accepted(accepted[5]),.delivered(delivered[5])
  );
  q8_axi_port #(.DATA_BITS(32),.PORT(6),.PAGE_COUNT(16),
                .PAGE_BASES({64'h000000160000f000,64'h000000160000e000,64'h000000160000d000,64'h000000160000c000,64'h000000160000b000,64'h000000160000a000,64'h0000001600009000,64'h0000001600008000,64'h0000001600007000,64'h0000001600006000,64'h0000001600005000,64'h0000001600004000,64'h0000001600003000,64'h0000001600002000,64'h0000001600001000,64'h0000001600000000})) u_port_out0 (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[6]),.read_hi(read_hi[6]),
    .write_lo(write_lo[6]),.write_hi(write_hi[6]),
    .hold_final_r(hold_final_r[6]),.hold_final_b(hold_final_b[6]),
    .r_hold_applied(r_hold_applied[6]),.b_hold_applied(b_hold_applied[6]),
    .r_special_wait_cycles(r_special_wait_cycles[6]),
    .b_special_wait_cycles(b_special_wait_cycles[6]),
    .awvalid(m_axi_gmem_out0_AWVALID),
    .awready(m_axi_gmem_out0_AWREADY),
    .awaddr(m_axi_gmem_out0_AWADDR),
    .awid(m_axi_gmem_out0_AWID),
    .awlen(m_axi_gmem_out0_AWLEN),
    .awsize(m_axi_gmem_out0_AWSIZE),
    .awburst(m_axi_gmem_out0_AWBURST),
    .awlock(m_axi_gmem_out0_AWLOCK),
    .awcache(m_axi_gmem_out0_AWCACHE),
    .awprot(m_axi_gmem_out0_AWPROT),
    .awqos(m_axi_gmem_out0_AWQOS),
    .awregion(m_axi_gmem_out0_AWREGION),
    .awuser(m_axi_gmem_out0_AWUSER),
    .wvalid(m_axi_gmem_out0_WVALID),
    .wready(m_axi_gmem_out0_WREADY),
    .wdata(m_axi_gmem_out0_WDATA),
    .wstrb(m_axi_gmem_out0_WSTRB),
    .wlast(m_axi_gmem_out0_WLAST),
    .wid(m_axi_gmem_out0_WID),
    .wuser(m_axi_gmem_out0_WUSER),
    .arvalid(m_axi_gmem_out0_ARVALID),
    .arready(m_axi_gmem_out0_ARREADY),
    .araddr(m_axi_gmem_out0_ARADDR),
    .arid(m_axi_gmem_out0_ARID),
    .arlen(m_axi_gmem_out0_ARLEN),
    .arsize(m_axi_gmem_out0_ARSIZE),
    .arburst(m_axi_gmem_out0_ARBURST),
    .arlock(m_axi_gmem_out0_ARLOCK),
    .arcache(m_axi_gmem_out0_ARCACHE),
    .arprot(m_axi_gmem_out0_ARPROT),
    .arqos(m_axi_gmem_out0_ARQOS),
    .arregion(m_axi_gmem_out0_ARREGION),
    .aruser(m_axi_gmem_out0_ARUSER),
    .rvalid(m_axi_gmem_out0_RVALID),
    .rready(m_axi_gmem_out0_RREADY),
    .rdata(m_axi_gmem_out0_RDATA),
    .rlast(m_axi_gmem_out0_RLAST),
    .rid(m_axi_gmem_out0_RID),
    .ruser(m_axi_gmem_out0_RUSER),
    .rresp(m_axi_gmem_out0_RRESP),
    .bvalid(m_axi_gmem_out0_BVALID),
    .bready(m_axi_gmem_out0_BREADY),
    .bresp(m_axi_gmem_out0_BRESP),
    .bid(m_axi_gmem_out0_BID),
    .buser(m_axi_gmem_out0_BUSER),
    .dut_aw_count(dut_aw_count[6]),
    .dut_w_count(dut_w_count[6]),
    .dut_b_count(dut_b_count[6]),
    .dut_ar_count(dut_ar_count[6]),
    .dut_r_count(dut_r_count[6]),
    .dut_rlast_count(dut_rlast_count[6]),
    .dut_read_bus_bytes(dut_read_bus_bytes[6]),
    .dut_write_bus_bytes(dut_write_bus_bytes[6]),
    .dut_write_useful_bytes(dut_write_useful_bytes[6]),
    .dut_write_pending(dut_write_pending[6]),
    .dut_read_pending(dut_read_pending[6]),
    .ram_aw_count(ram_aw_count[6]),
    .ram_w_count(ram_w_count[6]),
    .ram_b_count(ram_b_count[6]),
    .ram_ar_count(ram_ar_count[6]),
    .ram_r_count(ram_r_count[6]),
    .ram_rlast_count(ram_rlast_count[6]),
    .ram_read_bus_bytes(ram_read_bus_bytes[6]),
    .ram_write_bus_bytes(ram_write_bus_bytes[6]),
    .ram_write_useful_bytes(ram_write_useful_bytes[6]),
    .ram_write_pending(ram_write_pending[6]),
    .ram_read_pending(ram_read_pending[6]),
    .accepted(accepted[6]),.delivered(delivered[6])
  );
  q8_axi_port #(.DATA_BITS(32),.PORT(7),.PAGE_COUNT(1),
                .PAGE_BASES({64'h0000001700000000})) u_port_out1 (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[7]),.read_hi(read_hi[7]),
    .write_lo(write_lo[7]),.write_hi(write_hi[7]),
    .hold_final_r(hold_final_r[7]),.hold_final_b(hold_final_b[7]),
    .r_hold_applied(r_hold_applied[7]),.b_hold_applied(b_hold_applied[7]),
    .r_special_wait_cycles(r_special_wait_cycles[7]),
    .b_special_wait_cycles(b_special_wait_cycles[7]),
    .awvalid(m_axi_gmem_out1_AWVALID),
    .awready(m_axi_gmem_out1_AWREADY),
    .awaddr(m_axi_gmem_out1_AWADDR),
    .awid(m_axi_gmem_out1_AWID),
    .awlen(m_axi_gmem_out1_AWLEN),
    .awsize(m_axi_gmem_out1_AWSIZE),
    .awburst(m_axi_gmem_out1_AWBURST),
    .awlock(m_axi_gmem_out1_AWLOCK),
    .awcache(m_axi_gmem_out1_AWCACHE),
    .awprot(m_axi_gmem_out1_AWPROT),
    .awqos(m_axi_gmem_out1_AWQOS),
    .awregion(m_axi_gmem_out1_AWREGION),
    .awuser(m_axi_gmem_out1_AWUSER),
    .wvalid(m_axi_gmem_out1_WVALID),
    .wready(m_axi_gmem_out1_WREADY),
    .wdata(m_axi_gmem_out1_WDATA),
    .wstrb(m_axi_gmem_out1_WSTRB),
    .wlast(m_axi_gmem_out1_WLAST),
    .wid(m_axi_gmem_out1_WID),
    .wuser(m_axi_gmem_out1_WUSER),
    .arvalid(m_axi_gmem_out1_ARVALID),
    .arready(m_axi_gmem_out1_ARREADY),
    .araddr(m_axi_gmem_out1_ARADDR),
    .arid(m_axi_gmem_out1_ARID),
    .arlen(m_axi_gmem_out1_ARLEN),
    .arsize(m_axi_gmem_out1_ARSIZE),
    .arburst(m_axi_gmem_out1_ARBURST),
    .arlock(m_axi_gmem_out1_ARLOCK),
    .arcache(m_axi_gmem_out1_ARCACHE),
    .arprot(m_axi_gmem_out1_ARPROT),
    .arqos(m_axi_gmem_out1_ARQOS),
    .arregion(m_axi_gmem_out1_ARREGION),
    .aruser(m_axi_gmem_out1_ARUSER),
    .rvalid(m_axi_gmem_out1_RVALID),
    .rready(m_axi_gmem_out1_RREADY),
    .rdata(m_axi_gmem_out1_RDATA),
    .rlast(m_axi_gmem_out1_RLAST),
    .rid(m_axi_gmem_out1_RID),
    .ruser(m_axi_gmem_out1_RUSER),
    .rresp(m_axi_gmem_out1_RRESP),
    .bvalid(m_axi_gmem_out1_BVALID),
    .bready(m_axi_gmem_out1_BREADY),
    .bresp(m_axi_gmem_out1_BRESP),
    .bid(m_axi_gmem_out1_BID),
    .buser(m_axi_gmem_out1_BUSER),
    .dut_aw_count(dut_aw_count[7]),
    .dut_w_count(dut_w_count[7]),
    .dut_b_count(dut_b_count[7]),
    .dut_ar_count(dut_ar_count[7]),
    .dut_r_count(dut_r_count[7]),
    .dut_rlast_count(dut_rlast_count[7]),
    .dut_read_bus_bytes(dut_read_bus_bytes[7]),
    .dut_write_bus_bytes(dut_write_bus_bytes[7]),
    .dut_write_useful_bytes(dut_write_useful_bytes[7]),
    .dut_write_pending(dut_write_pending[7]),
    .dut_read_pending(dut_read_pending[7]),
    .ram_aw_count(ram_aw_count[7]),
    .ram_w_count(ram_w_count[7]),
    .ram_b_count(ram_b_count[7]),
    .ram_ar_count(ram_ar_count[7]),
    .ram_r_count(ram_r_count[7]),
    .ram_rlast_count(ram_rlast_count[7]),
    .ram_read_bus_bytes(ram_read_bus_bytes[7]),
    .ram_write_bus_bytes(ram_write_bus_bytes[7]),
    .ram_write_useful_bytes(ram_write_useful_bytes[7]),
    .ram_write_pending(ram_write_pending[7]),
    .ram_read_pending(ram_read_pending[7]),
    .accepted(accepted[7]),.delivered(delivered[7])
  );
  q8_axi_port #(.DATA_BITS(32),.PORT(8),.PAGE_COUNT(32),
                .PAGE_BASES({64'h000000180001f000,64'h000000180001e000,64'h000000180001d000,64'h000000180001c000,64'h000000180001b000,64'h000000180001a000,64'h0000001800019000,64'h0000001800018000,64'h0000001800017000,64'h0000001800016000,64'h0000001800015000,64'h0000001800014000,64'h0000001800013000,64'h0000001800012000,64'h0000001800011000,64'h0000001800010000,64'h000000180000f000,64'h000000180000e000,64'h000000180000d000,64'h000000180000c000,64'h000000180000b000,64'h000000180000a000,64'h0000001800009000,64'h0000001800008000,64'h0000001800007000,64'h0000001800006000,64'h0000001800005000,64'h0000001800004000,64'h0000001800003000,64'h0000001800002000,64'h0000001800001000,64'h0000001800000000})) u_port_observed (
    .clk(clk),.resetn(resetn),
    .read_lo(read_lo[8]),.read_hi(read_hi[8]),
    .write_lo(write_lo[8]),.write_hi(write_hi[8]),
    .hold_final_r(hold_final_r[8]),.hold_final_b(hold_final_b[8]),
    .r_hold_applied(r_hold_applied[8]),.b_hold_applied(b_hold_applied[8]),
    .r_special_wait_cycles(r_special_wait_cycles[8]),
    .b_special_wait_cycles(b_special_wait_cycles[8]),
    .awvalid(m_axi_gmem_observed_AWVALID),
    .awready(m_axi_gmem_observed_AWREADY),
    .awaddr(m_axi_gmem_observed_AWADDR),
    .awid(m_axi_gmem_observed_AWID),
    .awlen(m_axi_gmem_observed_AWLEN),
    .awsize(m_axi_gmem_observed_AWSIZE),
    .awburst(m_axi_gmem_observed_AWBURST),
    .awlock(m_axi_gmem_observed_AWLOCK),
    .awcache(m_axi_gmem_observed_AWCACHE),
    .awprot(m_axi_gmem_observed_AWPROT),
    .awqos(m_axi_gmem_observed_AWQOS),
    .awregion(m_axi_gmem_observed_AWREGION),
    .awuser(m_axi_gmem_observed_AWUSER),
    .wvalid(m_axi_gmem_observed_WVALID),
    .wready(m_axi_gmem_observed_WREADY),
    .wdata(m_axi_gmem_observed_WDATA),
    .wstrb(m_axi_gmem_observed_WSTRB),
    .wlast(m_axi_gmem_observed_WLAST),
    .wid(m_axi_gmem_observed_WID),
    .wuser(m_axi_gmem_observed_WUSER),
    .arvalid(m_axi_gmem_observed_ARVALID),
    .arready(m_axi_gmem_observed_ARREADY),
    .araddr(m_axi_gmem_observed_ARADDR),
    .arid(m_axi_gmem_observed_ARID),
    .arlen(m_axi_gmem_observed_ARLEN),
    .arsize(m_axi_gmem_observed_ARSIZE),
    .arburst(m_axi_gmem_observed_ARBURST),
    .arlock(m_axi_gmem_observed_ARLOCK),
    .arcache(m_axi_gmem_observed_ARCACHE),
    .arprot(m_axi_gmem_observed_ARPROT),
    .arqos(m_axi_gmem_observed_ARQOS),
    .arregion(m_axi_gmem_observed_ARREGION),
    .aruser(m_axi_gmem_observed_ARUSER),
    .rvalid(m_axi_gmem_observed_RVALID),
    .rready(m_axi_gmem_observed_RREADY),
    .rdata(m_axi_gmem_observed_RDATA),
    .rlast(m_axi_gmem_observed_RLAST),
    .rid(m_axi_gmem_observed_RID),
    .ruser(m_axi_gmem_observed_RUSER),
    .rresp(m_axi_gmem_observed_RRESP),
    .bvalid(m_axi_gmem_observed_BVALID),
    .bready(m_axi_gmem_observed_BREADY),
    .bresp(m_axi_gmem_observed_BRESP),
    .bid(m_axi_gmem_observed_BID),
    .buser(m_axi_gmem_observed_BUSER),
    .dut_aw_count(dut_aw_count[8]),
    .dut_w_count(dut_w_count[8]),
    .dut_b_count(dut_b_count[8]),
    .dut_ar_count(dut_ar_count[8]),
    .dut_r_count(dut_r_count[8]),
    .dut_rlast_count(dut_rlast_count[8]),
    .dut_read_bus_bytes(dut_read_bus_bytes[8]),
    .dut_write_bus_bytes(dut_write_bus_bytes[8]),
    .dut_write_useful_bytes(dut_write_useful_bytes[8]),
    .dut_write_pending(dut_write_pending[8]),
    .dut_read_pending(dut_read_pending[8]),
    .ram_aw_count(ram_aw_count[8]),
    .ram_w_count(ram_w_count[8]),
    .ram_b_count(ram_b_count[8]),
    .ram_ar_count(ram_ar_count[8]),
    .ram_r_count(ram_r_count[8]),
    .ram_rlast_count(ram_rlast_count[8]),
    .ram_read_bus_bytes(ram_read_bus_bytes[8]),
    .ram_write_bus_bytes(ram_write_bus_bytes[8]),
    .ram_write_useful_bytes(ram_write_useful_bytes[8]),
    .ram_write_pending(ram_write_pending[8]),
    .ram_read_pending(ram_read_pending[8]),
    .accepted(accepted[8]),.delivered(delivered[8])
  );
  logic lite_cmd_valid_0,lite_cmd_ready_0,lite_cmd_write_0,lite_cmd_done_0;
  logic [3:0] lite_cmd_addr_0;
  logic [31:0] lite_cmd_wdata_0,lite_cmd_rdata_0;
  q8_axi_lite_master #(.ADDR_BITS(4),.BANK(0)) lite_0 (
    .clk(clk),.resetn(resetn),.cmd_valid(lite_cmd_valid_0),
    .cmd_ready(lite_cmd_ready_0),.cmd_write(lite_cmd_write_0),
    .cmd_addr(lite_cmd_addr_0),.cmd_wdata(lite_cmd_wdata_0),
    .cmd_done(lite_cmd_done_0),.cmd_rdata(lite_cmd_rdata_0),
    .awvalid(s_axi_control_AWVALID),
    .awready(s_axi_control_AWREADY),
    .awaddr(s_axi_control_AWADDR),
    .wvalid(s_axi_control_WVALID),
    .wready(s_axi_control_WREADY),
    .wdata(s_axi_control_WDATA),
    .wstrb(s_axi_control_WSTRB),
    .bvalid(s_axi_control_BVALID),
    .bready(s_axi_control_BREADY),
    .bresp(s_axi_control_BRESP),
    .arvalid(s_axi_control_ARVALID),
    .arready(s_axi_control_ARREADY),
    .araddr(s_axi_control_ARADDR),
    .rvalid(s_axi_control_RVALID),
    .rready(s_axi_control_RREADY),
    .rdata(s_axi_control_RDATA),
    .rresp(s_axi_control_RRESP)
  );
  logic lite_cmd_valid_1,lite_cmd_ready_1,lite_cmd_write_1,lite_cmd_done_1;
  logic [6:0] lite_cmd_addr_1;
  logic [31:0] lite_cmd_wdata_1,lite_cmd_rdata_1;
  q8_axi_lite_master #(.ADDR_BITS(7),.BANK(1)) lite_1 (
    .clk(clk),.resetn(resetn),.cmd_valid(lite_cmd_valid_1),
    .cmd_ready(lite_cmd_ready_1),.cmd_write(lite_cmd_write_1),
    .cmd_addr(lite_cmd_addr_1),.cmd_wdata(lite_cmd_wdata_1),
    .cmd_done(lite_cmd_done_1),.cmd_rdata(lite_cmd_rdata_1),
    .awvalid(s_axi_control_r_AWVALID),
    .awready(s_axi_control_r_AWREADY),
    .awaddr(s_axi_control_r_AWADDR),
    .wvalid(s_axi_control_r_WVALID),
    .wready(s_axi_control_r_WREADY),
    .wdata(s_axi_control_r_WDATA),
    .wstrb(s_axi_control_r_WSTRB),
    .bvalid(s_axi_control_r_BVALID),
    .bready(s_axi_control_r_BREADY),
    .bresp(s_axi_control_r_BRESP),
    .arvalid(s_axi_control_r_ARVALID),
    .arready(s_axi_control_r_ARREADY),
    .araddr(s_axi_control_r_ARADDR),
    .rvalid(s_axi_control_r_RVALID),
    .rready(s_axi_control_r_RREADY),
    .rdata(s_axi_control_r_RDATA),
    .rresp(s_axi_control_r_RRESP)
  );
  `include "q8_full_scorer_control.svh"
  `include "q8_full_scorer_observer.svh"
endmodule
