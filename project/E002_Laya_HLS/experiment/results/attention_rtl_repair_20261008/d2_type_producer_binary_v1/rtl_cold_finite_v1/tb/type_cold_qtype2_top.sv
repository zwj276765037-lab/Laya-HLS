`timescale 1ns/1ps
// Literal generated Type pins; no warm-reset claim.
module type_cold_qtype2_top;
  logic clk=0;
  always #3.335 clk=~clk;
  logic resetn=0;
  localparam int TYPE_ID=2;
  localparam string CASE_NAME="qtype2";
  logic m_axi_hidden_input_AWVALID;
  logic m_axi_hidden_input_AWREADY;
  logic [63:0] m_axi_hidden_input_AWADDR;
  logic m_axi_hidden_input_AWID;
  logic [7:0] m_axi_hidden_input_AWLEN;
  logic [2:0] m_axi_hidden_input_AWSIZE;
  logic [1:0] m_axi_hidden_input_AWBURST;
  logic [1:0] m_axi_hidden_input_AWLOCK;
  logic [3:0] m_axi_hidden_input_AWCACHE;
  logic [2:0] m_axi_hidden_input_AWPROT;
  logic [3:0] m_axi_hidden_input_AWQOS;
  logic [3:0] m_axi_hidden_input_AWREGION;
  logic m_axi_hidden_input_AWUSER;
  logic m_axi_hidden_input_WVALID;
  logic m_axi_hidden_input_WREADY;
  logic [31:0] m_axi_hidden_input_WDATA;
  logic [3:0] m_axi_hidden_input_WSTRB;
  logic m_axi_hidden_input_WLAST;
  logic m_axi_hidden_input_WID;
  logic m_axi_hidden_input_WUSER;
  logic m_axi_hidden_input_ARVALID;
  logic m_axi_hidden_input_ARREADY;
  logic [63:0] m_axi_hidden_input_ARADDR;
  logic m_axi_hidden_input_ARID;
  logic [7:0] m_axi_hidden_input_ARLEN;
  logic [2:0] m_axi_hidden_input_ARSIZE;
  logic [1:0] m_axi_hidden_input_ARBURST;
  logic [1:0] m_axi_hidden_input_ARLOCK;
  logic [3:0] m_axi_hidden_input_ARCACHE;
  logic [2:0] m_axi_hidden_input_ARPROT;
  logic [3:0] m_axi_hidden_input_ARQOS;
  logic [3:0] m_axi_hidden_input_ARREGION;
  logic m_axi_hidden_input_ARUSER;
  logic m_axi_hidden_input_RVALID;
  logic m_axi_hidden_input_RREADY;
  logic [31:0] m_axi_hidden_input_RDATA;
  logic m_axi_hidden_input_RLAST;
  logic m_axi_hidden_input_RID;
  logic m_axi_hidden_input_RUSER;
  logic [1:0] m_axi_hidden_input_RRESP;
  logic m_axi_hidden_input_BVALID;
  logic m_axi_hidden_input_BREADY;
  logic [1:0] m_axi_hidden_input_BRESP;
  logic m_axi_hidden_input_BID;
  logic m_axi_hidden_input_BUSER;
  logic m_axi_embedding_AWVALID;
  logic m_axi_embedding_AWREADY;
  logic [63:0] m_axi_embedding_AWADDR;
  logic m_axi_embedding_AWID;
  logic [7:0] m_axi_embedding_AWLEN;
  logic [2:0] m_axi_embedding_AWSIZE;
  logic [1:0] m_axi_embedding_AWBURST;
  logic [1:0] m_axi_embedding_AWLOCK;
  logic [3:0] m_axi_embedding_AWCACHE;
  logic [2:0] m_axi_embedding_AWPROT;
  logic [3:0] m_axi_embedding_AWQOS;
  logic [3:0] m_axi_embedding_AWREGION;
  logic m_axi_embedding_AWUSER;
  logic m_axi_embedding_WVALID;
  logic m_axi_embedding_WREADY;
  logic [31:0] m_axi_embedding_WDATA;
  logic [3:0] m_axi_embedding_WSTRB;
  logic m_axi_embedding_WLAST;
  logic m_axi_embedding_WID;
  logic m_axi_embedding_WUSER;
  logic m_axi_embedding_ARVALID;
  logic m_axi_embedding_ARREADY;
  logic [63:0] m_axi_embedding_ARADDR;
  logic m_axi_embedding_ARID;
  logic [7:0] m_axi_embedding_ARLEN;
  logic [2:0] m_axi_embedding_ARSIZE;
  logic [1:0] m_axi_embedding_ARBURST;
  logic [1:0] m_axi_embedding_ARLOCK;
  logic [3:0] m_axi_embedding_ARCACHE;
  logic [2:0] m_axi_embedding_ARPROT;
  logic [3:0] m_axi_embedding_ARQOS;
  logic [3:0] m_axi_embedding_ARREGION;
  logic m_axi_embedding_ARUSER;
  logic m_axi_embedding_RVALID;
  logic m_axi_embedding_RREADY;
  logic [31:0] m_axi_embedding_RDATA;
  logic m_axi_embedding_RLAST;
  logic m_axi_embedding_RID;
  logic m_axi_embedding_RUSER;
  logic [1:0] m_axi_embedding_RRESP;
  logic m_axi_embedding_BVALID;
  logic m_axi_embedding_BREADY;
  logic [1:0] m_axi_embedding_BRESP;
  logic m_axi_embedding_BID;
  logic m_axi_embedding_BUSER;
  logic m_axi_io_AWVALID;
  logic m_axi_io_AWREADY;
  logic [63:0] m_axi_io_AWADDR;
  logic m_axi_io_AWID;
  logic [7:0] m_axi_io_AWLEN;
  logic [2:0] m_axi_io_AWSIZE;
  logic [1:0] m_axi_io_AWBURST;
  logic [1:0] m_axi_io_AWLOCK;
  logic [3:0] m_axi_io_AWCACHE;
  logic [2:0] m_axi_io_AWPROT;
  logic [3:0] m_axi_io_AWQOS;
  logic [3:0] m_axi_io_AWREGION;
  logic m_axi_io_AWUSER;
  logic m_axi_io_WVALID;
  logic m_axi_io_WREADY;
  logic [31:0] m_axi_io_WDATA;
  logic [3:0] m_axi_io_WSTRB;
  logic m_axi_io_WLAST;
  logic m_axi_io_WID;
  logic m_axi_io_WUSER;
  logic m_axi_io_ARVALID;
  logic m_axi_io_ARREADY;
  logic [63:0] m_axi_io_ARADDR;
  logic m_axi_io_ARID;
  logic [7:0] m_axi_io_ARLEN;
  logic [2:0] m_axi_io_ARSIZE;
  logic [1:0] m_axi_io_ARBURST;
  logic [1:0] m_axi_io_ARLOCK;
  logic [3:0] m_axi_io_ARCACHE;
  logic [2:0] m_axi_io_ARPROT;
  logic [3:0] m_axi_io_ARQOS;
  logic [3:0] m_axi_io_ARREGION;
  logic m_axi_io_ARUSER;
  logic m_axi_io_RVALID;
  logic m_axi_io_RREADY;
  logic [31:0] m_axi_io_RDATA;
  logic m_axi_io_RLAST;
  logic m_axi_io_RID;
  logic m_axi_io_RUSER;
  logic [1:0] m_axi_io_RRESP;
  logic m_axi_io_BVALID;
  logic m_axi_io_BREADY;
  logic [1:0] m_axi_io_BRESP;
  logic m_axi_io_BID;
  logic m_axi_io_BUSER;
  logic m_axi_aux_AWVALID;
  logic m_axi_aux_AWREADY;
  logic [63:0] m_axi_aux_AWADDR;
  logic m_axi_aux_AWID;
  logic [7:0] m_axi_aux_AWLEN;
  logic [2:0] m_axi_aux_AWSIZE;
  logic [1:0] m_axi_aux_AWBURST;
  logic [1:0] m_axi_aux_AWLOCK;
  logic [3:0] m_axi_aux_AWCACHE;
  logic [2:0] m_axi_aux_AWPROT;
  logic [3:0] m_axi_aux_AWQOS;
  logic [3:0] m_axi_aux_AWREGION;
  logic m_axi_aux_AWUSER;
  logic m_axi_aux_WVALID;
  logic m_axi_aux_WREADY;
  logic [31:0] m_axi_aux_WDATA;
  logic [3:0] m_axi_aux_WSTRB;
  logic m_axi_aux_WLAST;
  logic m_axi_aux_WID;
  logic m_axi_aux_WUSER;
  logic m_axi_aux_ARVALID;
  logic m_axi_aux_ARREADY;
  logic [63:0] m_axi_aux_ARADDR;
  logic m_axi_aux_ARID;
  logic [7:0] m_axi_aux_ARLEN;
  logic [2:0] m_axi_aux_ARSIZE;
  logic [1:0] m_axi_aux_ARBURST;
  logic [1:0] m_axi_aux_ARLOCK;
  logic [3:0] m_axi_aux_ARCACHE;
  logic [2:0] m_axi_aux_ARPROT;
  logic [3:0] m_axi_aux_ARQOS;
  logic [3:0] m_axi_aux_ARREGION;
  logic m_axi_aux_ARUSER;
  logic m_axi_aux_RVALID;
  logic m_axi_aux_RREADY;
  logic [31:0] m_axi_aux_RDATA;
  logic m_axi_aux_RLAST;
  logic m_axi_aux_RID;
  logic m_axi_aux_RUSER;
  logic [1:0] m_axi_aux_RRESP;
  logic m_axi_aux_BVALID;
  logic m_axi_aux_BREADY;
  logic [1:0] m_axi_aux_BRESP;
  logic m_axi_aux_BID;
  logic m_axi_aux_BUSER;
  logic m_axi_state0_AWVALID;
  logic m_axi_state0_AWREADY;
  logic [63:0] m_axi_state0_AWADDR;
  logic m_axi_state0_AWID;
  logic [7:0] m_axi_state0_AWLEN;
  logic [2:0] m_axi_state0_AWSIZE;
  logic [1:0] m_axi_state0_AWBURST;
  logic [1:0] m_axi_state0_AWLOCK;
  logic [3:0] m_axi_state0_AWCACHE;
  logic [2:0] m_axi_state0_AWPROT;
  logic [3:0] m_axi_state0_AWQOS;
  logic [3:0] m_axi_state0_AWREGION;
  logic m_axi_state0_AWUSER;
  logic m_axi_state0_WVALID;
  logic m_axi_state0_WREADY;
  logic [31:0] m_axi_state0_WDATA;
  logic [3:0] m_axi_state0_WSTRB;
  logic m_axi_state0_WLAST;
  logic m_axi_state0_WID;
  logic m_axi_state0_WUSER;
  logic m_axi_state0_ARVALID;
  logic m_axi_state0_ARREADY;
  logic [63:0] m_axi_state0_ARADDR;
  logic m_axi_state0_ARID;
  logic [7:0] m_axi_state0_ARLEN;
  logic [2:0] m_axi_state0_ARSIZE;
  logic [1:0] m_axi_state0_ARBURST;
  logic [1:0] m_axi_state0_ARLOCK;
  logic [3:0] m_axi_state0_ARCACHE;
  logic [2:0] m_axi_state0_ARPROT;
  logic [3:0] m_axi_state0_ARQOS;
  logic [3:0] m_axi_state0_ARREGION;
  logic m_axi_state0_ARUSER;
  logic m_axi_state0_RVALID;
  logic m_axi_state0_RREADY;
  logic [31:0] m_axi_state0_RDATA;
  logic m_axi_state0_RLAST;
  logic m_axi_state0_RID;
  logic m_axi_state0_RUSER;
  logic [1:0] m_axi_state0_RRESP;
  logic m_axi_state0_BVALID;
  logic m_axi_state0_BREADY;
  logic [1:0] m_axi_state0_BRESP;
  logic m_axi_state0_BID;
  logic m_axi_state0_BUSER;
  logic m_axi_state1_AWVALID;
  logic m_axi_state1_AWREADY;
  logic [63:0] m_axi_state1_AWADDR;
  logic m_axi_state1_AWID;
  logic [7:0] m_axi_state1_AWLEN;
  logic [2:0] m_axi_state1_AWSIZE;
  logic [1:0] m_axi_state1_AWBURST;
  logic [1:0] m_axi_state1_AWLOCK;
  logic [3:0] m_axi_state1_AWCACHE;
  logic [2:0] m_axi_state1_AWPROT;
  logic [3:0] m_axi_state1_AWQOS;
  logic [3:0] m_axi_state1_AWREGION;
  logic m_axi_state1_AWUSER;
  logic m_axi_state1_WVALID;
  logic m_axi_state1_WREADY;
  logic [31:0] m_axi_state1_WDATA;
  logic [3:0] m_axi_state1_WSTRB;
  logic m_axi_state1_WLAST;
  logic m_axi_state1_WID;
  logic m_axi_state1_WUSER;
  logic m_axi_state1_ARVALID;
  logic m_axi_state1_ARREADY;
  logic [63:0] m_axi_state1_ARADDR;
  logic m_axi_state1_ARID;
  logic [7:0] m_axi_state1_ARLEN;
  logic [2:0] m_axi_state1_ARSIZE;
  logic [1:0] m_axi_state1_ARBURST;
  logic [1:0] m_axi_state1_ARLOCK;
  logic [3:0] m_axi_state1_ARCACHE;
  logic [2:0] m_axi_state1_ARPROT;
  logic [3:0] m_axi_state1_ARQOS;
  logic [3:0] m_axi_state1_ARREGION;
  logic m_axi_state1_ARUSER;
  logic m_axi_state1_RVALID;
  logic m_axi_state1_RREADY;
  logic [31:0] m_axi_state1_RDATA;
  logic m_axi_state1_RLAST;
  logic m_axi_state1_RID;
  logic m_axi_state1_RUSER;
  logic [1:0] m_axi_state1_RRESP;
  logic m_axi_state1_BVALID;
  logic m_axi_state1_BREADY;
  logic [1:0] m_axi_state1_BRESP;
  logic m_axi_state1_BID;
  logic m_axi_state1_BUSER;
  logic m_axi_observed_AWVALID;
  logic m_axi_observed_AWREADY;
  logic [63:0] m_axi_observed_AWADDR;
  logic m_axi_observed_AWID;
  logic [7:0] m_axi_observed_AWLEN;
  logic [2:0] m_axi_observed_AWSIZE;
  logic [1:0] m_axi_observed_AWBURST;
  logic [1:0] m_axi_observed_AWLOCK;
  logic [3:0] m_axi_observed_AWCACHE;
  logic [2:0] m_axi_observed_AWPROT;
  logic [3:0] m_axi_observed_AWQOS;
  logic [3:0] m_axi_observed_AWREGION;
  logic m_axi_observed_AWUSER;
  logic m_axi_observed_WVALID;
  logic m_axi_observed_WREADY;
  logic [31:0] m_axi_observed_WDATA;
  logic [3:0] m_axi_observed_WSTRB;
  logic m_axi_observed_WLAST;
  logic m_axi_observed_WID;
  logic m_axi_observed_WUSER;
  logic m_axi_observed_ARVALID;
  logic m_axi_observed_ARREADY;
  logic [63:0] m_axi_observed_ARADDR;
  logic m_axi_observed_ARID;
  logic [7:0] m_axi_observed_ARLEN;
  logic [2:0] m_axi_observed_ARSIZE;
  logic [1:0] m_axi_observed_ARBURST;
  logic [1:0] m_axi_observed_ARLOCK;
  logic [3:0] m_axi_observed_ARCACHE;
  logic [2:0] m_axi_observed_ARPROT;
  logic [3:0] m_axi_observed_ARQOS;
  logic [3:0] m_axi_observed_ARREGION;
  logic m_axi_observed_ARUSER;
  logic m_axi_observed_RVALID;
  logic m_axi_observed_RREADY;
  logic [31:0] m_axi_observed_RDATA;
  logic m_axi_observed_RLAST;
  logic m_axi_observed_RID;
  logic m_axi_observed_RUSER;
  logic [1:0] m_axi_observed_RRESP;
  logic m_axi_observed_BVALID;
  logic m_axi_observed_BREADY;
  logic [1:0] m_axi_observed_BRESP;
  logic m_axi_observed_BID;
  logic m_axi_observed_BUSER;
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
  type_producer_binary_slice dut (
    .ap_clk(clk),
    .ap_rst_n(resetn),
    .m_axi_hidden_input_AWVALID(m_axi_hidden_input_AWVALID),
    .m_axi_hidden_input_AWREADY(m_axi_hidden_input_AWREADY),
    .m_axi_hidden_input_AWADDR(m_axi_hidden_input_AWADDR),
    .m_axi_hidden_input_AWID(m_axi_hidden_input_AWID),
    .m_axi_hidden_input_AWLEN(m_axi_hidden_input_AWLEN),
    .m_axi_hidden_input_AWSIZE(m_axi_hidden_input_AWSIZE),
    .m_axi_hidden_input_AWBURST(m_axi_hidden_input_AWBURST),
    .m_axi_hidden_input_AWLOCK(m_axi_hidden_input_AWLOCK),
    .m_axi_hidden_input_AWCACHE(m_axi_hidden_input_AWCACHE),
    .m_axi_hidden_input_AWPROT(m_axi_hidden_input_AWPROT),
    .m_axi_hidden_input_AWQOS(m_axi_hidden_input_AWQOS),
    .m_axi_hidden_input_AWREGION(m_axi_hidden_input_AWREGION),
    .m_axi_hidden_input_AWUSER(m_axi_hidden_input_AWUSER),
    .m_axi_hidden_input_WVALID(m_axi_hidden_input_WVALID),
    .m_axi_hidden_input_WREADY(m_axi_hidden_input_WREADY),
    .m_axi_hidden_input_WDATA(m_axi_hidden_input_WDATA),
    .m_axi_hidden_input_WSTRB(m_axi_hidden_input_WSTRB),
    .m_axi_hidden_input_WLAST(m_axi_hidden_input_WLAST),
    .m_axi_hidden_input_WID(m_axi_hidden_input_WID),
    .m_axi_hidden_input_WUSER(m_axi_hidden_input_WUSER),
    .m_axi_hidden_input_ARVALID(m_axi_hidden_input_ARVALID),
    .m_axi_hidden_input_ARREADY(m_axi_hidden_input_ARREADY),
    .m_axi_hidden_input_ARADDR(m_axi_hidden_input_ARADDR),
    .m_axi_hidden_input_ARID(m_axi_hidden_input_ARID),
    .m_axi_hidden_input_ARLEN(m_axi_hidden_input_ARLEN),
    .m_axi_hidden_input_ARSIZE(m_axi_hidden_input_ARSIZE),
    .m_axi_hidden_input_ARBURST(m_axi_hidden_input_ARBURST),
    .m_axi_hidden_input_ARLOCK(m_axi_hidden_input_ARLOCK),
    .m_axi_hidden_input_ARCACHE(m_axi_hidden_input_ARCACHE),
    .m_axi_hidden_input_ARPROT(m_axi_hidden_input_ARPROT),
    .m_axi_hidden_input_ARQOS(m_axi_hidden_input_ARQOS),
    .m_axi_hidden_input_ARREGION(m_axi_hidden_input_ARREGION),
    .m_axi_hidden_input_ARUSER(m_axi_hidden_input_ARUSER),
    .m_axi_hidden_input_RVALID(m_axi_hidden_input_RVALID),
    .m_axi_hidden_input_RREADY(m_axi_hidden_input_RREADY),
    .m_axi_hidden_input_RDATA(m_axi_hidden_input_RDATA),
    .m_axi_hidden_input_RLAST(m_axi_hidden_input_RLAST),
    .m_axi_hidden_input_RID(m_axi_hidden_input_RID),
    .m_axi_hidden_input_RUSER(m_axi_hidden_input_RUSER),
    .m_axi_hidden_input_RRESP(m_axi_hidden_input_RRESP),
    .m_axi_hidden_input_BVALID(m_axi_hidden_input_BVALID),
    .m_axi_hidden_input_BREADY(m_axi_hidden_input_BREADY),
    .m_axi_hidden_input_BRESP(m_axi_hidden_input_BRESP),
    .m_axi_hidden_input_BID(m_axi_hidden_input_BID),
    .m_axi_hidden_input_BUSER(m_axi_hidden_input_BUSER),
    .m_axi_embedding_AWVALID(m_axi_embedding_AWVALID),
    .m_axi_embedding_AWREADY(m_axi_embedding_AWREADY),
    .m_axi_embedding_AWADDR(m_axi_embedding_AWADDR),
    .m_axi_embedding_AWID(m_axi_embedding_AWID),
    .m_axi_embedding_AWLEN(m_axi_embedding_AWLEN),
    .m_axi_embedding_AWSIZE(m_axi_embedding_AWSIZE),
    .m_axi_embedding_AWBURST(m_axi_embedding_AWBURST),
    .m_axi_embedding_AWLOCK(m_axi_embedding_AWLOCK),
    .m_axi_embedding_AWCACHE(m_axi_embedding_AWCACHE),
    .m_axi_embedding_AWPROT(m_axi_embedding_AWPROT),
    .m_axi_embedding_AWQOS(m_axi_embedding_AWQOS),
    .m_axi_embedding_AWREGION(m_axi_embedding_AWREGION),
    .m_axi_embedding_AWUSER(m_axi_embedding_AWUSER),
    .m_axi_embedding_WVALID(m_axi_embedding_WVALID),
    .m_axi_embedding_WREADY(m_axi_embedding_WREADY),
    .m_axi_embedding_WDATA(m_axi_embedding_WDATA),
    .m_axi_embedding_WSTRB(m_axi_embedding_WSTRB),
    .m_axi_embedding_WLAST(m_axi_embedding_WLAST),
    .m_axi_embedding_WID(m_axi_embedding_WID),
    .m_axi_embedding_WUSER(m_axi_embedding_WUSER),
    .m_axi_embedding_ARVALID(m_axi_embedding_ARVALID),
    .m_axi_embedding_ARREADY(m_axi_embedding_ARREADY),
    .m_axi_embedding_ARADDR(m_axi_embedding_ARADDR),
    .m_axi_embedding_ARID(m_axi_embedding_ARID),
    .m_axi_embedding_ARLEN(m_axi_embedding_ARLEN),
    .m_axi_embedding_ARSIZE(m_axi_embedding_ARSIZE),
    .m_axi_embedding_ARBURST(m_axi_embedding_ARBURST),
    .m_axi_embedding_ARLOCK(m_axi_embedding_ARLOCK),
    .m_axi_embedding_ARCACHE(m_axi_embedding_ARCACHE),
    .m_axi_embedding_ARPROT(m_axi_embedding_ARPROT),
    .m_axi_embedding_ARQOS(m_axi_embedding_ARQOS),
    .m_axi_embedding_ARREGION(m_axi_embedding_ARREGION),
    .m_axi_embedding_ARUSER(m_axi_embedding_ARUSER),
    .m_axi_embedding_RVALID(m_axi_embedding_RVALID),
    .m_axi_embedding_RREADY(m_axi_embedding_RREADY),
    .m_axi_embedding_RDATA(m_axi_embedding_RDATA),
    .m_axi_embedding_RLAST(m_axi_embedding_RLAST),
    .m_axi_embedding_RID(m_axi_embedding_RID),
    .m_axi_embedding_RUSER(m_axi_embedding_RUSER),
    .m_axi_embedding_RRESP(m_axi_embedding_RRESP),
    .m_axi_embedding_BVALID(m_axi_embedding_BVALID),
    .m_axi_embedding_BREADY(m_axi_embedding_BREADY),
    .m_axi_embedding_BRESP(m_axi_embedding_BRESP),
    .m_axi_embedding_BID(m_axi_embedding_BID),
    .m_axi_embedding_BUSER(m_axi_embedding_BUSER),
    .m_axi_io_AWVALID(m_axi_io_AWVALID),
    .m_axi_io_AWREADY(m_axi_io_AWREADY),
    .m_axi_io_AWADDR(m_axi_io_AWADDR),
    .m_axi_io_AWID(m_axi_io_AWID),
    .m_axi_io_AWLEN(m_axi_io_AWLEN),
    .m_axi_io_AWSIZE(m_axi_io_AWSIZE),
    .m_axi_io_AWBURST(m_axi_io_AWBURST),
    .m_axi_io_AWLOCK(m_axi_io_AWLOCK),
    .m_axi_io_AWCACHE(m_axi_io_AWCACHE),
    .m_axi_io_AWPROT(m_axi_io_AWPROT),
    .m_axi_io_AWQOS(m_axi_io_AWQOS),
    .m_axi_io_AWREGION(m_axi_io_AWREGION),
    .m_axi_io_AWUSER(m_axi_io_AWUSER),
    .m_axi_io_WVALID(m_axi_io_WVALID),
    .m_axi_io_WREADY(m_axi_io_WREADY),
    .m_axi_io_WDATA(m_axi_io_WDATA),
    .m_axi_io_WSTRB(m_axi_io_WSTRB),
    .m_axi_io_WLAST(m_axi_io_WLAST),
    .m_axi_io_WID(m_axi_io_WID),
    .m_axi_io_WUSER(m_axi_io_WUSER),
    .m_axi_io_ARVALID(m_axi_io_ARVALID),
    .m_axi_io_ARREADY(m_axi_io_ARREADY),
    .m_axi_io_ARADDR(m_axi_io_ARADDR),
    .m_axi_io_ARID(m_axi_io_ARID),
    .m_axi_io_ARLEN(m_axi_io_ARLEN),
    .m_axi_io_ARSIZE(m_axi_io_ARSIZE),
    .m_axi_io_ARBURST(m_axi_io_ARBURST),
    .m_axi_io_ARLOCK(m_axi_io_ARLOCK),
    .m_axi_io_ARCACHE(m_axi_io_ARCACHE),
    .m_axi_io_ARPROT(m_axi_io_ARPROT),
    .m_axi_io_ARQOS(m_axi_io_ARQOS),
    .m_axi_io_ARREGION(m_axi_io_ARREGION),
    .m_axi_io_ARUSER(m_axi_io_ARUSER),
    .m_axi_io_RVALID(m_axi_io_RVALID),
    .m_axi_io_RREADY(m_axi_io_RREADY),
    .m_axi_io_RDATA(m_axi_io_RDATA),
    .m_axi_io_RLAST(m_axi_io_RLAST),
    .m_axi_io_RID(m_axi_io_RID),
    .m_axi_io_RUSER(m_axi_io_RUSER),
    .m_axi_io_RRESP(m_axi_io_RRESP),
    .m_axi_io_BVALID(m_axi_io_BVALID),
    .m_axi_io_BREADY(m_axi_io_BREADY),
    .m_axi_io_BRESP(m_axi_io_BRESP),
    .m_axi_io_BID(m_axi_io_BID),
    .m_axi_io_BUSER(m_axi_io_BUSER),
    .m_axi_aux_AWVALID(m_axi_aux_AWVALID),
    .m_axi_aux_AWREADY(m_axi_aux_AWREADY),
    .m_axi_aux_AWADDR(m_axi_aux_AWADDR),
    .m_axi_aux_AWID(m_axi_aux_AWID),
    .m_axi_aux_AWLEN(m_axi_aux_AWLEN),
    .m_axi_aux_AWSIZE(m_axi_aux_AWSIZE),
    .m_axi_aux_AWBURST(m_axi_aux_AWBURST),
    .m_axi_aux_AWLOCK(m_axi_aux_AWLOCK),
    .m_axi_aux_AWCACHE(m_axi_aux_AWCACHE),
    .m_axi_aux_AWPROT(m_axi_aux_AWPROT),
    .m_axi_aux_AWQOS(m_axi_aux_AWQOS),
    .m_axi_aux_AWREGION(m_axi_aux_AWREGION),
    .m_axi_aux_AWUSER(m_axi_aux_AWUSER),
    .m_axi_aux_WVALID(m_axi_aux_WVALID),
    .m_axi_aux_WREADY(m_axi_aux_WREADY),
    .m_axi_aux_WDATA(m_axi_aux_WDATA),
    .m_axi_aux_WSTRB(m_axi_aux_WSTRB),
    .m_axi_aux_WLAST(m_axi_aux_WLAST),
    .m_axi_aux_WID(m_axi_aux_WID),
    .m_axi_aux_WUSER(m_axi_aux_WUSER),
    .m_axi_aux_ARVALID(m_axi_aux_ARVALID),
    .m_axi_aux_ARREADY(m_axi_aux_ARREADY),
    .m_axi_aux_ARADDR(m_axi_aux_ARADDR),
    .m_axi_aux_ARID(m_axi_aux_ARID),
    .m_axi_aux_ARLEN(m_axi_aux_ARLEN),
    .m_axi_aux_ARSIZE(m_axi_aux_ARSIZE),
    .m_axi_aux_ARBURST(m_axi_aux_ARBURST),
    .m_axi_aux_ARLOCK(m_axi_aux_ARLOCK),
    .m_axi_aux_ARCACHE(m_axi_aux_ARCACHE),
    .m_axi_aux_ARPROT(m_axi_aux_ARPROT),
    .m_axi_aux_ARQOS(m_axi_aux_ARQOS),
    .m_axi_aux_ARREGION(m_axi_aux_ARREGION),
    .m_axi_aux_ARUSER(m_axi_aux_ARUSER),
    .m_axi_aux_RVALID(m_axi_aux_RVALID),
    .m_axi_aux_RREADY(m_axi_aux_RREADY),
    .m_axi_aux_RDATA(m_axi_aux_RDATA),
    .m_axi_aux_RLAST(m_axi_aux_RLAST),
    .m_axi_aux_RID(m_axi_aux_RID),
    .m_axi_aux_RUSER(m_axi_aux_RUSER),
    .m_axi_aux_RRESP(m_axi_aux_RRESP),
    .m_axi_aux_BVALID(m_axi_aux_BVALID),
    .m_axi_aux_BREADY(m_axi_aux_BREADY),
    .m_axi_aux_BRESP(m_axi_aux_BRESP),
    .m_axi_aux_BID(m_axi_aux_BID),
    .m_axi_aux_BUSER(m_axi_aux_BUSER),
    .m_axi_state0_AWVALID(m_axi_state0_AWVALID),
    .m_axi_state0_AWREADY(m_axi_state0_AWREADY),
    .m_axi_state0_AWADDR(m_axi_state0_AWADDR),
    .m_axi_state0_AWID(m_axi_state0_AWID),
    .m_axi_state0_AWLEN(m_axi_state0_AWLEN),
    .m_axi_state0_AWSIZE(m_axi_state0_AWSIZE),
    .m_axi_state0_AWBURST(m_axi_state0_AWBURST),
    .m_axi_state0_AWLOCK(m_axi_state0_AWLOCK),
    .m_axi_state0_AWCACHE(m_axi_state0_AWCACHE),
    .m_axi_state0_AWPROT(m_axi_state0_AWPROT),
    .m_axi_state0_AWQOS(m_axi_state0_AWQOS),
    .m_axi_state0_AWREGION(m_axi_state0_AWREGION),
    .m_axi_state0_AWUSER(m_axi_state0_AWUSER),
    .m_axi_state0_WVALID(m_axi_state0_WVALID),
    .m_axi_state0_WREADY(m_axi_state0_WREADY),
    .m_axi_state0_WDATA(m_axi_state0_WDATA),
    .m_axi_state0_WSTRB(m_axi_state0_WSTRB),
    .m_axi_state0_WLAST(m_axi_state0_WLAST),
    .m_axi_state0_WID(m_axi_state0_WID),
    .m_axi_state0_WUSER(m_axi_state0_WUSER),
    .m_axi_state0_ARVALID(m_axi_state0_ARVALID),
    .m_axi_state0_ARREADY(m_axi_state0_ARREADY),
    .m_axi_state0_ARADDR(m_axi_state0_ARADDR),
    .m_axi_state0_ARID(m_axi_state0_ARID),
    .m_axi_state0_ARLEN(m_axi_state0_ARLEN),
    .m_axi_state0_ARSIZE(m_axi_state0_ARSIZE),
    .m_axi_state0_ARBURST(m_axi_state0_ARBURST),
    .m_axi_state0_ARLOCK(m_axi_state0_ARLOCK),
    .m_axi_state0_ARCACHE(m_axi_state0_ARCACHE),
    .m_axi_state0_ARPROT(m_axi_state0_ARPROT),
    .m_axi_state0_ARQOS(m_axi_state0_ARQOS),
    .m_axi_state0_ARREGION(m_axi_state0_ARREGION),
    .m_axi_state0_ARUSER(m_axi_state0_ARUSER),
    .m_axi_state0_RVALID(m_axi_state0_RVALID),
    .m_axi_state0_RREADY(m_axi_state0_RREADY),
    .m_axi_state0_RDATA(m_axi_state0_RDATA),
    .m_axi_state0_RLAST(m_axi_state0_RLAST),
    .m_axi_state0_RID(m_axi_state0_RID),
    .m_axi_state0_RUSER(m_axi_state0_RUSER),
    .m_axi_state0_RRESP(m_axi_state0_RRESP),
    .m_axi_state0_BVALID(m_axi_state0_BVALID),
    .m_axi_state0_BREADY(m_axi_state0_BREADY),
    .m_axi_state0_BRESP(m_axi_state0_BRESP),
    .m_axi_state0_BID(m_axi_state0_BID),
    .m_axi_state0_BUSER(m_axi_state0_BUSER),
    .m_axi_state1_AWVALID(m_axi_state1_AWVALID),
    .m_axi_state1_AWREADY(m_axi_state1_AWREADY),
    .m_axi_state1_AWADDR(m_axi_state1_AWADDR),
    .m_axi_state1_AWID(m_axi_state1_AWID),
    .m_axi_state1_AWLEN(m_axi_state1_AWLEN),
    .m_axi_state1_AWSIZE(m_axi_state1_AWSIZE),
    .m_axi_state1_AWBURST(m_axi_state1_AWBURST),
    .m_axi_state1_AWLOCK(m_axi_state1_AWLOCK),
    .m_axi_state1_AWCACHE(m_axi_state1_AWCACHE),
    .m_axi_state1_AWPROT(m_axi_state1_AWPROT),
    .m_axi_state1_AWQOS(m_axi_state1_AWQOS),
    .m_axi_state1_AWREGION(m_axi_state1_AWREGION),
    .m_axi_state1_AWUSER(m_axi_state1_AWUSER),
    .m_axi_state1_WVALID(m_axi_state1_WVALID),
    .m_axi_state1_WREADY(m_axi_state1_WREADY),
    .m_axi_state1_WDATA(m_axi_state1_WDATA),
    .m_axi_state1_WSTRB(m_axi_state1_WSTRB),
    .m_axi_state1_WLAST(m_axi_state1_WLAST),
    .m_axi_state1_WID(m_axi_state1_WID),
    .m_axi_state1_WUSER(m_axi_state1_WUSER),
    .m_axi_state1_ARVALID(m_axi_state1_ARVALID),
    .m_axi_state1_ARREADY(m_axi_state1_ARREADY),
    .m_axi_state1_ARADDR(m_axi_state1_ARADDR),
    .m_axi_state1_ARID(m_axi_state1_ARID),
    .m_axi_state1_ARLEN(m_axi_state1_ARLEN),
    .m_axi_state1_ARSIZE(m_axi_state1_ARSIZE),
    .m_axi_state1_ARBURST(m_axi_state1_ARBURST),
    .m_axi_state1_ARLOCK(m_axi_state1_ARLOCK),
    .m_axi_state1_ARCACHE(m_axi_state1_ARCACHE),
    .m_axi_state1_ARPROT(m_axi_state1_ARPROT),
    .m_axi_state1_ARQOS(m_axi_state1_ARQOS),
    .m_axi_state1_ARREGION(m_axi_state1_ARREGION),
    .m_axi_state1_ARUSER(m_axi_state1_ARUSER),
    .m_axi_state1_RVALID(m_axi_state1_RVALID),
    .m_axi_state1_RREADY(m_axi_state1_RREADY),
    .m_axi_state1_RDATA(m_axi_state1_RDATA),
    .m_axi_state1_RLAST(m_axi_state1_RLAST),
    .m_axi_state1_RID(m_axi_state1_RID),
    .m_axi_state1_RUSER(m_axi_state1_RUSER),
    .m_axi_state1_RRESP(m_axi_state1_RRESP),
    .m_axi_state1_BVALID(m_axi_state1_BVALID),
    .m_axi_state1_BREADY(m_axi_state1_BREADY),
    .m_axi_state1_BRESP(m_axi_state1_BRESP),
    .m_axi_state1_BID(m_axi_state1_BID),
    .m_axi_state1_BUSER(m_axi_state1_BUSER),
    .m_axi_observed_AWVALID(m_axi_observed_AWVALID),
    .m_axi_observed_AWREADY(m_axi_observed_AWREADY),
    .m_axi_observed_AWADDR(m_axi_observed_AWADDR),
    .m_axi_observed_AWID(m_axi_observed_AWID),
    .m_axi_observed_AWLEN(m_axi_observed_AWLEN),
    .m_axi_observed_AWSIZE(m_axi_observed_AWSIZE),
    .m_axi_observed_AWBURST(m_axi_observed_AWBURST),
    .m_axi_observed_AWLOCK(m_axi_observed_AWLOCK),
    .m_axi_observed_AWCACHE(m_axi_observed_AWCACHE),
    .m_axi_observed_AWPROT(m_axi_observed_AWPROT),
    .m_axi_observed_AWQOS(m_axi_observed_AWQOS),
    .m_axi_observed_AWREGION(m_axi_observed_AWREGION),
    .m_axi_observed_AWUSER(m_axi_observed_AWUSER),
    .m_axi_observed_WVALID(m_axi_observed_WVALID),
    .m_axi_observed_WREADY(m_axi_observed_WREADY),
    .m_axi_observed_WDATA(m_axi_observed_WDATA),
    .m_axi_observed_WSTRB(m_axi_observed_WSTRB),
    .m_axi_observed_WLAST(m_axi_observed_WLAST),
    .m_axi_observed_WID(m_axi_observed_WID),
    .m_axi_observed_WUSER(m_axi_observed_WUSER),
    .m_axi_observed_ARVALID(m_axi_observed_ARVALID),
    .m_axi_observed_ARREADY(m_axi_observed_ARREADY),
    .m_axi_observed_ARADDR(m_axi_observed_ARADDR),
    .m_axi_observed_ARID(m_axi_observed_ARID),
    .m_axi_observed_ARLEN(m_axi_observed_ARLEN),
    .m_axi_observed_ARSIZE(m_axi_observed_ARSIZE),
    .m_axi_observed_ARBURST(m_axi_observed_ARBURST),
    .m_axi_observed_ARLOCK(m_axi_observed_ARLOCK),
    .m_axi_observed_ARCACHE(m_axi_observed_ARCACHE),
    .m_axi_observed_ARPROT(m_axi_observed_ARPROT),
    .m_axi_observed_ARQOS(m_axi_observed_ARQOS),
    .m_axi_observed_ARREGION(m_axi_observed_ARREGION),
    .m_axi_observed_ARUSER(m_axi_observed_ARUSER),
    .m_axi_observed_RVALID(m_axi_observed_RVALID),
    .m_axi_observed_RREADY(m_axi_observed_RREADY),
    .m_axi_observed_RDATA(m_axi_observed_RDATA),
    .m_axi_observed_RLAST(m_axi_observed_RLAST),
    .m_axi_observed_RID(m_axi_observed_RID),
    .m_axi_observed_RUSER(m_axi_observed_RUSER),
    .m_axi_observed_RRESP(m_axi_observed_RRESP),
    .m_axi_observed_BVALID(m_axi_observed_BVALID),
    .m_axi_observed_BREADY(m_axi_observed_BREADY),
    .m_axi_observed_BRESP(m_axi_observed_BRESP),
    .m_axi_observed_BID(m_axi_observed_BID),
    .m_axi_observed_BUSER(m_axi_observed_BUSER),
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
  logic [31:0] dut_aw_count [0:6];
  logic [31:0] dut_w_count [0:6];
  logic [31:0] dut_b_count [0:6];
  logic [31:0] dut_ar_count [0:6];
  logic [31:0] dut_r_count [0:6];
  logic [31:0] dut_rlast_count [0:6];
  logic [63:0] dut_read_bus_bytes [0:6];
  logic [63:0] dut_write_bus_bytes [0:6];
  logic [63:0] dut_write_useful_bytes [0:6];
  logic dut_write_pending [0:6];
  logic dut_read_pending [0:6];
  logic [31:0] ram_aw_count [0:6];
  logic [31:0] ram_w_count [0:6];
  logic [31:0] ram_b_count [0:6];
  logic [31:0] ram_ar_count [0:6];
  logic [31:0] ram_r_count [0:6];
  logic [31:0] ram_rlast_count [0:6];
  logic [63:0] ram_read_bus_bytes [0:6];
  logic [63:0] ram_write_bus_bytes [0:6];
  logic [63:0] ram_write_useful_bytes [0:6];
  logic ram_write_pending [0:6];
  logic ram_read_pending [0:6];
  logic [31:0] accepted [0:6][0:4], delivered [0:6][0:4];
  logic [118:0] ram_accepted_r_record [0:6];
  logic r_hold_applied [0:6], b_hold_applied [0:6];
  logic [31:0] r_special_wait_cycles [0:6], b_special_wait_cycles [0:6];
  logic hold_final_r [0:6], hold_final_b [0:6];
  att_axi_port #(.DATA_BITS(32),.PORT(0),.PAGE_COUNT(64),
                 .PAGE_BASES({64'h000000010003f000,64'h000000010003e000,64'h000000010003d000,64'h000000010003c000,64'h000000010003b000,64'h000000010003a000,64'h0000000100039000,64'h0000000100038000,64'h0000000100037000,64'h0000000100036000,64'h0000000100035000,64'h0000000100034000,64'h0000000100033000,64'h0000000100032000,64'h0000000100031000,64'h0000000100030000,64'h000000010002f000,64'h000000010002e000,64'h000000010002d000,64'h000000010002c000,64'h000000010002b000,64'h000000010002a000,64'h0000000100029000,64'h0000000100028000,64'h0000000100027000,64'h0000000100026000,64'h0000000100025000,64'h0000000100024000,64'h0000000100023000,64'h0000000100022000,64'h0000000100021000,64'h0000000100020000,64'h000000010001f000,64'h000000010001e000,64'h000000010001d000,64'h000000010001c000,64'h000000010001b000,64'h000000010001a000,64'h0000000100019000,64'h0000000100018000,64'h0000000100017000,64'h0000000100016000,64'h0000000100015000,64'h0000000100014000,64'h0000000100013000,64'h0000000100012000,64'h0000000100011000,64'h0000000100010000,64'h000000010000f000,64'h000000010000e000,64'h000000010000d000,64'h000000010000c000,64'h000000010000b000,64'h000000010000a000,64'h0000000100009000,64'h0000000100008000,64'h0000000100007000,64'h0000000100006000,64'h0000000100005000,64'h0000000100004000,64'h0000000100003000,64'h0000000100002000,64'h0000000100001000,64'h0000000100000000})) u_port_hidden_input (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000100000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000100040000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[0]),.hold_final_b(hold_final_b[0]),
    .r_hold_applied(r_hold_applied[0]),.b_hold_applied(b_hold_applied[0]),
    .r_special_wait_cycles(r_special_wait_cycles[0]),
    .b_special_wait_cycles(b_special_wait_cycles[0]),
    .awvalid(m_axi_hidden_input_AWVALID),
    .awready(m_axi_hidden_input_AWREADY),
    .awaddr(m_axi_hidden_input_AWADDR),
    .awid(m_axi_hidden_input_AWID),
    .awlen(m_axi_hidden_input_AWLEN),
    .awsize(m_axi_hidden_input_AWSIZE),
    .awburst(m_axi_hidden_input_AWBURST),
    .awlock(m_axi_hidden_input_AWLOCK),
    .awcache(m_axi_hidden_input_AWCACHE),
    .awprot(m_axi_hidden_input_AWPROT),
    .awqos(m_axi_hidden_input_AWQOS),
    .awregion(m_axi_hidden_input_AWREGION),
    .awuser(m_axi_hidden_input_AWUSER),
    .wvalid(m_axi_hidden_input_WVALID),
    .wready(m_axi_hidden_input_WREADY),
    .wdata(m_axi_hidden_input_WDATA),
    .wstrb(m_axi_hidden_input_WSTRB),
    .wlast(m_axi_hidden_input_WLAST),
    .wid(m_axi_hidden_input_WID),
    .wuser(m_axi_hidden_input_WUSER),
    .arvalid(m_axi_hidden_input_ARVALID),
    .arready(m_axi_hidden_input_ARREADY),
    .araddr(m_axi_hidden_input_ARADDR),
    .arid(m_axi_hidden_input_ARID),
    .arlen(m_axi_hidden_input_ARLEN),
    .arsize(m_axi_hidden_input_ARSIZE),
    .arburst(m_axi_hidden_input_ARBURST),
    .arlock(m_axi_hidden_input_ARLOCK),
    .arcache(m_axi_hidden_input_ARCACHE),
    .arprot(m_axi_hidden_input_ARPROT),
    .arqos(m_axi_hidden_input_ARQOS),
    .arregion(m_axi_hidden_input_ARREGION),
    .aruser(m_axi_hidden_input_ARUSER),
    .rvalid(m_axi_hidden_input_RVALID),
    .rready(m_axi_hidden_input_RREADY),
    .rdata(m_axi_hidden_input_RDATA),
    .rlast(m_axi_hidden_input_RLAST),
    .rid(m_axi_hidden_input_RID),
    .ruser(m_axi_hidden_input_RUSER),
    .rresp(m_axi_hidden_input_RRESP),
    .bvalid(m_axi_hidden_input_BVALID),
    .bready(m_axi_hidden_input_BREADY),
    .bresp(m_axi_hidden_input_BRESP),
    .bid(m_axi_hidden_input_BID),
    .buser(m_axi_hidden_input_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[0]),
    .accepted(accepted[0]),.delivered(delivered[0])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(1),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000000203443000})) u_port_embedding (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000203443880}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000203443cc0}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[1]),.hold_final_b(hold_final_b[1]),
    .r_hold_applied(r_hold_applied[1]),.b_hold_applied(b_hold_applied[1]),
    .r_special_wait_cycles(r_special_wait_cycles[1]),
    .b_special_wait_cycles(b_special_wait_cycles[1]),
    .awvalid(m_axi_embedding_AWVALID),
    .awready(m_axi_embedding_AWREADY),
    .awaddr(m_axi_embedding_AWADDR),
    .awid(m_axi_embedding_AWID),
    .awlen(m_axi_embedding_AWLEN),
    .awsize(m_axi_embedding_AWSIZE),
    .awburst(m_axi_embedding_AWBURST),
    .awlock(m_axi_embedding_AWLOCK),
    .awcache(m_axi_embedding_AWCACHE),
    .awprot(m_axi_embedding_AWPROT),
    .awqos(m_axi_embedding_AWQOS),
    .awregion(m_axi_embedding_AWREGION),
    .awuser(m_axi_embedding_AWUSER),
    .wvalid(m_axi_embedding_WVALID),
    .wready(m_axi_embedding_WREADY),
    .wdata(m_axi_embedding_WDATA),
    .wstrb(m_axi_embedding_WSTRB),
    .wlast(m_axi_embedding_WLAST),
    .wid(m_axi_embedding_WID),
    .wuser(m_axi_embedding_WUSER),
    .arvalid(m_axi_embedding_ARVALID),
    .arready(m_axi_embedding_ARREADY),
    .araddr(m_axi_embedding_ARADDR),
    .arid(m_axi_embedding_ARID),
    .arlen(m_axi_embedding_ARLEN),
    .arsize(m_axi_embedding_ARSIZE),
    .arburst(m_axi_embedding_ARBURST),
    .arlock(m_axi_embedding_ARLOCK),
    .arcache(m_axi_embedding_ARCACHE),
    .arprot(m_axi_embedding_ARPROT),
    .arqos(m_axi_embedding_ARQOS),
    .arregion(m_axi_embedding_ARREGION),
    .aruser(m_axi_embedding_ARUSER),
    .rvalid(m_axi_embedding_RVALID),
    .rready(m_axi_embedding_RREADY),
    .rdata(m_axi_embedding_RDATA),
    .rlast(m_axi_embedding_RLAST),
    .rid(m_axi_embedding_RID),
    .ruser(m_axi_embedding_RUSER),
    .rresp(m_axi_embedding_RRESP),
    .bvalid(m_axi_embedding_BVALID),
    .bready(m_axi_embedding_BREADY),
    .bresp(m_axi_embedding_BRESP),
    .bid(m_axi_embedding_BID),
    .buser(m_axi_embedding_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[1]),
    .accepted(accepted[1]),.delivered(delivered[1])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(2),.PAGE_COUNT(8),
                 .PAGE_BASES({64'h0000000300007000,64'h0000000300006000,64'h0000000300005000,64'h0000000300004000,64'h0000000300003000,64'h0000000300002000,64'h0000000300001000,64'h0000000300000000})) u_port_io (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000300000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000300000340}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[2]),.hold_final_b(hold_final_b[2]),
    .r_hold_applied(r_hold_applied[2]),.b_hold_applied(b_hold_applied[2]),
    .r_special_wait_cycles(r_special_wait_cycles[2]),
    .b_special_wait_cycles(b_special_wait_cycles[2]),
    .awvalid(m_axi_io_AWVALID),
    .awready(m_axi_io_AWREADY),
    .awaddr(m_axi_io_AWADDR),
    .awid(m_axi_io_AWID),
    .awlen(m_axi_io_AWLEN),
    .awsize(m_axi_io_AWSIZE),
    .awburst(m_axi_io_AWBURST),
    .awlock(m_axi_io_AWLOCK),
    .awcache(m_axi_io_AWCACHE),
    .awprot(m_axi_io_AWPROT),
    .awqos(m_axi_io_AWQOS),
    .awregion(m_axi_io_AWREGION),
    .awuser(m_axi_io_AWUSER),
    .wvalid(m_axi_io_WVALID),
    .wready(m_axi_io_WREADY),
    .wdata(m_axi_io_WDATA),
    .wstrb(m_axi_io_WSTRB),
    .wlast(m_axi_io_WLAST),
    .wid(m_axi_io_WID),
    .wuser(m_axi_io_WUSER),
    .arvalid(m_axi_io_ARVALID),
    .arready(m_axi_io_ARREADY),
    .araddr(m_axi_io_ARADDR),
    .arid(m_axi_io_ARID),
    .arlen(m_axi_io_ARLEN),
    .arsize(m_axi_io_ARSIZE),
    .arburst(m_axi_io_ARBURST),
    .arlock(m_axi_io_ARLOCK),
    .arcache(m_axi_io_ARCACHE),
    .arprot(m_axi_io_ARPROT),
    .arqos(m_axi_io_ARQOS),
    .arregion(m_axi_io_ARREGION),
    .aruser(m_axi_io_ARUSER),
    .rvalid(m_axi_io_RVALID),
    .rready(m_axi_io_RREADY),
    .rdata(m_axi_io_RDATA),
    .rlast(m_axi_io_RLAST),
    .rid(m_axi_io_RID),
    .ruser(m_axi_io_RUSER),
    .rresp(m_axi_io_RRESP),
    .bvalid(m_axi_io_BVALID),
    .bready(m_axi_io_BREADY),
    .bresp(m_axi_io_BRESP),
    .bid(m_axi_io_BID),
    .buser(m_axi_io_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[2]),
    .accepted(accepted[2]),.delivered(delivered[2])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(3),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000000400000000})) u_port_aux (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000400000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000400001000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[3]),.hold_final_b(hold_final_b[3]),
    .r_hold_applied(r_hold_applied[3]),.b_hold_applied(b_hold_applied[3]),
    .r_special_wait_cycles(r_special_wait_cycles[3]),
    .b_special_wait_cycles(b_special_wait_cycles[3]),
    .awvalid(m_axi_aux_AWVALID),
    .awready(m_axi_aux_AWREADY),
    .awaddr(m_axi_aux_AWADDR),
    .awid(m_axi_aux_AWID),
    .awlen(m_axi_aux_AWLEN),
    .awsize(m_axi_aux_AWSIZE),
    .awburst(m_axi_aux_AWBURST),
    .awlock(m_axi_aux_AWLOCK),
    .awcache(m_axi_aux_AWCACHE),
    .awprot(m_axi_aux_AWPROT),
    .awqos(m_axi_aux_AWQOS),
    .awregion(m_axi_aux_AWREGION),
    .awuser(m_axi_aux_AWUSER),
    .wvalid(m_axi_aux_WVALID),
    .wready(m_axi_aux_WREADY),
    .wdata(m_axi_aux_WDATA),
    .wstrb(m_axi_aux_WSTRB),
    .wlast(m_axi_aux_WLAST),
    .wid(m_axi_aux_WID),
    .wuser(m_axi_aux_WUSER),
    .arvalid(m_axi_aux_ARVALID),
    .arready(m_axi_aux_ARREADY),
    .araddr(m_axi_aux_ARADDR),
    .arid(m_axi_aux_ARID),
    .arlen(m_axi_aux_ARLEN),
    .arsize(m_axi_aux_ARSIZE),
    .arburst(m_axi_aux_ARBURST),
    .arlock(m_axi_aux_ARLOCK),
    .arcache(m_axi_aux_ARCACHE),
    .arprot(m_axi_aux_ARPROT),
    .arqos(m_axi_aux_ARQOS),
    .arregion(m_axi_aux_ARREGION),
    .aruser(m_axi_aux_ARUSER),
    .rvalid(m_axi_aux_RVALID),
    .rready(m_axi_aux_RREADY),
    .rdata(m_axi_aux_RDATA),
    .rlast(m_axi_aux_RLAST),
    .rid(m_axi_aux_RID),
    .ruser(m_axi_aux_RUSER),
    .rresp(m_axi_aux_RRESP),
    .bvalid(m_axi_aux_BVALID),
    .bready(m_axi_aux_BREADY),
    .bresp(m_axi_aux_BRESP),
    .bid(m_axi_aux_BID),
    .buser(m_axi_aux_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[3]),
    .accepted(accepted[3]),.delivered(delivered[3])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(4),.PAGE_COUNT(67),
                 .PAGE_BASES({64'h0000000501022000,64'h0000000501021000,64'h0000000501020000,64'h000000050003f000,64'h000000050003e000,64'h000000050003d000,64'h000000050003c000,64'h000000050003b000,64'h000000050003a000,64'h0000000500039000,64'h0000000500038000,64'h0000000500037000,64'h0000000500036000,64'h0000000500035000,64'h0000000500034000,64'h0000000500033000,64'h0000000500032000,64'h0000000500031000,64'h0000000500030000,64'h000000050002f000,64'h000000050002e000,64'h000000050002d000,64'h000000050002c000,64'h000000050002b000,64'h000000050002a000,64'h0000000500029000,64'h0000000500028000,64'h0000000500027000,64'h0000000500026000,64'h0000000500025000,64'h0000000500024000,64'h0000000500023000,64'h0000000500022000,64'h0000000500021000,64'h0000000500020000,64'h000000050001f000,64'h000000050001e000,64'h000000050001d000,64'h000000050001c000,64'h000000050001b000,64'h000000050001a000,64'h0000000500019000,64'h0000000500018000,64'h0000000500017000,64'h0000000500016000,64'h0000000500015000,64'h0000000500014000,64'h0000000500013000,64'h0000000500012000,64'h0000000500011000,64'h0000000500010000,64'h000000050000f000,64'h000000050000e000,64'h000000050000d000,64'h000000050000c000,64'h000000050000b000,64'h000000050000a000,64'h0000000500009000,64'h0000000500008000,64'h0000000500007000,64'h0000000500006000,64'h0000000500005000,64'h0000000500004000,64'h0000000500003000,64'h0000000500002000,64'h0000000500001000,64'h0000000500000000})) u_port_state0 (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000501022000,64'h0000000500000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000501023000,64'h0000000500040000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000501022000,64'h0000000500000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000501023000,64'h0000000500040000}),
    .hold_final_r(hold_final_r[4]),.hold_final_b(hold_final_b[4]),
    .r_hold_applied(r_hold_applied[4]),.b_hold_applied(b_hold_applied[4]),
    .r_special_wait_cycles(r_special_wait_cycles[4]),
    .b_special_wait_cycles(b_special_wait_cycles[4]),
    .awvalid(m_axi_state0_AWVALID),
    .awready(m_axi_state0_AWREADY),
    .awaddr(m_axi_state0_AWADDR),
    .awid(m_axi_state0_AWID),
    .awlen(m_axi_state0_AWLEN),
    .awsize(m_axi_state0_AWSIZE),
    .awburst(m_axi_state0_AWBURST),
    .awlock(m_axi_state0_AWLOCK),
    .awcache(m_axi_state0_AWCACHE),
    .awprot(m_axi_state0_AWPROT),
    .awqos(m_axi_state0_AWQOS),
    .awregion(m_axi_state0_AWREGION),
    .awuser(m_axi_state0_AWUSER),
    .wvalid(m_axi_state0_WVALID),
    .wready(m_axi_state0_WREADY),
    .wdata(m_axi_state0_WDATA),
    .wstrb(m_axi_state0_WSTRB),
    .wlast(m_axi_state0_WLAST),
    .wid(m_axi_state0_WID),
    .wuser(m_axi_state0_WUSER),
    .arvalid(m_axi_state0_ARVALID),
    .arready(m_axi_state0_ARREADY),
    .araddr(m_axi_state0_ARADDR),
    .arid(m_axi_state0_ARID),
    .arlen(m_axi_state0_ARLEN),
    .arsize(m_axi_state0_ARSIZE),
    .arburst(m_axi_state0_ARBURST),
    .arlock(m_axi_state0_ARLOCK),
    .arcache(m_axi_state0_ARCACHE),
    .arprot(m_axi_state0_ARPROT),
    .arqos(m_axi_state0_ARQOS),
    .arregion(m_axi_state0_ARREGION),
    .aruser(m_axi_state0_ARUSER),
    .rvalid(m_axi_state0_RVALID),
    .rready(m_axi_state0_RREADY),
    .rdata(m_axi_state0_RDATA),
    .rlast(m_axi_state0_RLAST),
    .rid(m_axi_state0_RID),
    .ruser(m_axi_state0_RUSER),
    .rresp(m_axi_state0_RRESP),
    .bvalid(m_axi_state0_BVALID),
    .bready(m_axi_state0_BREADY),
    .bresp(m_axi_state0_BRESP),
    .bid(m_axi_state0_BID),
    .buser(m_axi_state0_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[4]),
    .accepted(accepted[4]),.delivered(delivered[4])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(5),.PAGE_COUNT(64),
                 .PAGE_BASES({64'h000000060003f000,64'h000000060003e000,64'h000000060003d000,64'h000000060003c000,64'h000000060003b000,64'h000000060003a000,64'h0000000600039000,64'h0000000600038000,64'h0000000600037000,64'h0000000600036000,64'h0000000600035000,64'h0000000600034000,64'h0000000600033000,64'h0000000600032000,64'h0000000600031000,64'h0000000600030000,64'h000000060002f000,64'h000000060002e000,64'h000000060002d000,64'h000000060002c000,64'h000000060002b000,64'h000000060002a000,64'h0000000600029000,64'h0000000600028000,64'h0000000600027000,64'h0000000600026000,64'h0000000600025000,64'h0000000600024000,64'h0000000600023000,64'h0000000600022000,64'h0000000600021000,64'h0000000600020000,64'h000000060001f000,64'h000000060001e000,64'h000000060001d000,64'h000000060001c000,64'h000000060001b000,64'h000000060001a000,64'h0000000600019000,64'h0000000600018000,64'h0000000600017000,64'h0000000600016000,64'h0000000600015000,64'h0000000600014000,64'h0000000600013000,64'h0000000600012000,64'h0000000600011000,64'h0000000600010000,64'h000000060000f000,64'h000000060000e000,64'h000000060000d000,64'h000000060000c000,64'h000000060000b000,64'h000000060000a000,64'h0000000600009000,64'h0000000600008000,64'h0000000600007000,64'h0000000600006000,64'h0000000600005000,64'h0000000600004000,64'h0000000600003000,64'h0000000600002000,64'h0000000600001000,64'h0000000600000000})) u_port_state1 (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000600000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000600040000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000600000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000600040000}),
    .hold_final_r(hold_final_r[5]),.hold_final_b(hold_final_b[5]),
    .r_hold_applied(r_hold_applied[5]),.b_hold_applied(b_hold_applied[5]),
    .r_special_wait_cycles(r_special_wait_cycles[5]),
    .b_special_wait_cycles(b_special_wait_cycles[5]),
    .awvalid(m_axi_state1_AWVALID),
    .awready(m_axi_state1_AWREADY),
    .awaddr(m_axi_state1_AWADDR),
    .awid(m_axi_state1_AWID),
    .awlen(m_axi_state1_AWLEN),
    .awsize(m_axi_state1_AWSIZE),
    .awburst(m_axi_state1_AWBURST),
    .awlock(m_axi_state1_AWLOCK),
    .awcache(m_axi_state1_AWCACHE),
    .awprot(m_axi_state1_AWPROT),
    .awqos(m_axi_state1_AWQOS),
    .awregion(m_axi_state1_AWREGION),
    .awuser(m_axi_state1_AWUSER),
    .wvalid(m_axi_state1_WVALID),
    .wready(m_axi_state1_WREADY),
    .wdata(m_axi_state1_WDATA),
    .wstrb(m_axi_state1_WSTRB),
    .wlast(m_axi_state1_WLAST),
    .wid(m_axi_state1_WID),
    .wuser(m_axi_state1_WUSER),
    .arvalid(m_axi_state1_ARVALID),
    .arready(m_axi_state1_ARREADY),
    .araddr(m_axi_state1_ARADDR),
    .arid(m_axi_state1_ARID),
    .arlen(m_axi_state1_ARLEN),
    .arsize(m_axi_state1_ARSIZE),
    .arburst(m_axi_state1_ARBURST),
    .arlock(m_axi_state1_ARLOCK),
    .arcache(m_axi_state1_ARCACHE),
    .arprot(m_axi_state1_ARPROT),
    .arqos(m_axi_state1_ARQOS),
    .arregion(m_axi_state1_ARREGION),
    .aruser(m_axi_state1_ARUSER),
    .rvalid(m_axi_state1_RVALID),
    .rready(m_axi_state1_RREADY),
    .rdata(m_axi_state1_RDATA),
    .rlast(m_axi_state1_RLAST),
    .rid(m_axi_state1_RID),
    .ruser(m_axi_state1_RUSER),
    .rresp(m_axi_state1_RRESP),
    .bvalid(m_axi_state1_BVALID),
    .bready(m_axi_state1_BREADY),
    .bresp(m_axi_state1_BRESP),
    .bid(m_axi_state1_BID),
    .buser(m_axi_state1_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[5]),
    .accepted(accepted[5]),.delivered(delivered[5])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(6),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000000700000000})) u_port_observed (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000700000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000700000080}),
    .hold_final_r(hold_final_r[6]),.hold_final_b(hold_final_b[6]),
    .r_hold_applied(r_hold_applied[6]),.b_hold_applied(b_hold_applied[6]),
    .r_special_wait_cycles(r_special_wait_cycles[6]),
    .b_special_wait_cycles(b_special_wait_cycles[6]),
    .awvalid(m_axi_observed_AWVALID),
    .awready(m_axi_observed_AWREADY),
    .awaddr(m_axi_observed_AWADDR),
    .awid(m_axi_observed_AWID),
    .awlen(m_axi_observed_AWLEN),
    .awsize(m_axi_observed_AWSIZE),
    .awburst(m_axi_observed_AWBURST),
    .awlock(m_axi_observed_AWLOCK),
    .awcache(m_axi_observed_AWCACHE),
    .awprot(m_axi_observed_AWPROT),
    .awqos(m_axi_observed_AWQOS),
    .awregion(m_axi_observed_AWREGION),
    .awuser(m_axi_observed_AWUSER),
    .wvalid(m_axi_observed_WVALID),
    .wready(m_axi_observed_WREADY),
    .wdata(m_axi_observed_WDATA),
    .wstrb(m_axi_observed_WSTRB),
    .wlast(m_axi_observed_WLAST),
    .wid(m_axi_observed_WID),
    .wuser(m_axi_observed_WUSER),
    .arvalid(m_axi_observed_ARVALID),
    .arready(m_axi_observed_ARREADY),
    .araddr(m_axi_observed_ARADDR),
    .arid(m_axi_observed_ARID),
    .arlen(m_axi_observed_ARLEN),
    .arsize(m_axi_observed_ARSIZE),
    .arburst(m_axi_observed_ARBURST),
    .arlock(m_axi_observed_ARLOCK),
    .arcache(m_axi_observed_ARCACHE),
    .arprot(m_axi_observed_ARPROT),
    .arqos(m_axi_observed_ARQOS),
    .arregion(m_axi_observed_ARREGION),
    .aruser(m_axi_observed_ARUSER),
    .rvalid(m_axi_observed_RVALID),
    .rready(m_axi_observed_RREADY),
    .rdata(m_axi_observed_RDATA),
    .rlast(m_axi_observed_RLAST),
    .rid(m_axi_observed_RID),
    .ruser(m_axi_observed_RUSER),
    .rresp(m_axi_observed_RRESP),
    .bvalid(m_axi_observed_BVALID),
    .bready(m_axi_observed_BREADY),
    .bresp(m_axi_observed_BRESP),
    .bid(m_axi_observed_BID),
    .buser(m_axi_observed_BUSER),
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
    .ram_accepted_r_record(ram_accepted_r_record[6]),
    .accepted(accepted[6]),.delivered(delivered[6])
  );
  logic lite_cmd_valid_0,lite_cmd_ready_0,lite_cmd_write_0,lite_cmd_done_0;
  logic [3:0] lite_cmd_addr_0;
  logic [31:0] lite_cmd_wdata_0,lite_cmd_rdata_0;
  att_axi_lite_master #(.ADDR_BITS(4),.BANK(0)) lite_0 (
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
  att_axi_lite_master #(.ADDR_BITS(7),.BANK(1)) lite_1 (
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
  `include "type_cold_control.svh"
endmodule
