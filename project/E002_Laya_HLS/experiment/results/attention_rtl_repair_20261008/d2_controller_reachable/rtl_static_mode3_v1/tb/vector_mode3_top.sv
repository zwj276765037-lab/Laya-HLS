`timescale 1ns/1ps
// Literal wiring derived from frozen vector_controller_slice.v.
module vector_mode3_top;
  logic clk=0;
  always #3.333 clk=~clk;
  logic resetn=0;
  logic m_axi_src0_input_AWVALID;
  logic m_axi_src0_input_AWREADY;
  logic [63:0] m_axi_src0_input_AWADDR;
  logic [0:0] m_axi_src0_input_AWID;
  logic [7:0] m_axi_src0_input_AWLEN;
  logic [2:0] m_axi_src0_input_AWSIZE;
  logic [1:0] m_axi_src0_input_AWBURST;
  logic [1:0] m_axi_src0_input_AWLOCK;
  logic [3:0] m_axi_src0_input_AWCACHE;
  logic [2:0] m_axi_src0_input_AWPROT;
  logic [3:0] m_axi_src0_input_AWQOS;
  logic [3:0] m_axi_src0_input_AWREGION;
  logic [0:0] m_axi_src0_input_AWUSER;
  logic m_axi_src0_input_WVALID;
  logic m_axi_src0_input_WREADY;
  logic [31:0] m_axi_src0_input_WDATA;
  logic [3:0] m_axi_src0_input_WSTRB;
  logic m_axi_src0_input_WLAST;
  logic [0:0] m_axi_src0_input_WID;
  logic [0:0] m_axi_src0_input_WUSER;
  logic m_axi_src0_input_ARVALID;
  logic m_axi_src0_input_ARREADY;
  logic [63:0] m_axi_src0_input_ARADDR;
  logic [0:0] m_axi_src0_input_ARID;
  logic [7:0] m_axi_src0_input_ARLEN;
  logic [2:0] m_axi_src0_input_ARSIZE;
  logic [1:0] m_axi_src0_input_ARBURST;
  logic [1:0] m_axi_src0_input_ARLOCK;
  logic [3:0] m_axi_src0_input_ARCACHE;
  logic [2:0] m_axi_src0_input_ARPROT;
  logic [3:0] m_axi_src0_input_ARQOS;
  logic [3:0] m_axi_src0_input_ARREGION;
  logic [0:0] m_axi_src0_input_ARUSER;
  logic m_axi_src0_input_RVALID;
  logic m_axi_src0_input_RREADY;
  logic [31:0] m_axi_src0_input_RDATA;
  logic m_axi_src0_input_RLAST;
  logic [0:0] m_axi_src0_input_RID;
  logic [0:0] m_axi_src0_input_RUSER;
  logic [1:0] m_axi_src0_input_RRESP;
  logic m_axi_src0_input_BVALID;
  logic m_axi_src0_input_BREADY;
  logic [1:0] m_axi_src0_input_BRESP;
  logic [0:0] m_axi_src0_input_BID;
  logic [0:0] m_axi_src0_input_BUSER;
  logic m_axi_src1_input_AWVALID;
  logic m_axi_src1_input_AWREADY;
  logic [63:0] m_axi_src1_input_AWADDR;
  logic [0:0] m_axi_src1_input_AWID;
  logic [7:0] m_axi_src1_input_AWLEN;
  logic [2:0] m_axi_src1_input_AWSIZE;
  logic [1:0] m_axi_src1_input_AWBURST;
  logic [1:0] m_axi_src1_input_AWLOCK;
  logic [3:0] m_axi_src1_input_AWCACHE;
  logic [2:0] m_axi_src1_input_AWPROT;
  logic [3:0] m_axi_src1_input_AWQOS;
  logic [3:0] m_axi_src1_input_AWREGION;
  logic [0:0] m_axi_src1_input_AWUSER;
  logic m_axi_src1_input_WVALID;
  logic m_axi_src1_input_WREADY;
  logic [31:0] m_axi_src1_input_WDATA;
  logic [3:0] m_axi_src1_input_WSTRB;
  logic m_axi_src1_input_WLAST;
  logic [0:0] m_axi_src1_input_WID;
  logic [0:0] m_axi_src1_input_WUSER;
  logic m_axi_src1_input_ARVALID;
  logic m_axi_src1_input_ARREADY;
  logic [63:0] m_axi_src1_input_ARADDR;
  logic [0:0] m_axi_src1_input_ARID;
  logic [7:0] m_axi_src1_input_ARLEN;
  logic [2:0] m_axi_src1_input_ARSIZE;
  logic [1:0] m_axi_src1_input_ARBURST;
  logic [1:0] m_axi_src1_input_ARLOCK;
  logic [3:0] m_axi_src1_input_ARCACHE;
  logic [2:0] m_axi_src1_input_ARPROT;
  logic [3:0] m_axi_src1_input_ARQOS;
  logic [3:0] m_axi_src1_input_ARREGION;
  logic [0:0] m_axi_src1_input_ARUSER;
  logic m_axi_src1_input_RVALID;
  logic m_axi_src1_input_RREADY;
  logic [31:0] m_axi_src1_input_RDATA;
  logic m_axi_src1_input_RLAST;
  logic [0:0] m_axi_src1_input_RID;
  logic [0:0] m_axi_src1_input_RUSER;
  logic [1:0] m_axi_src1_input_RRESP;
  logic m_axi_src1_input_BVALID;
  logic m_axi_src1_input_BREADY;
  logic [1:0] m_axi_src1_input_BRESP;
  logic [0:0] m_axi_src1_input_BID;
  logic [0:0] m_axi_src1_input_BUSER;
  logic m_axi_io_AWVALID;
  logic m_axi_io_AWREADY;
  logic [63:0] m_axi_io_AWADDR;
  logic [0:0] m_axi_io_AWID;
  logic [7:0] m_axi_io_AWLEN;
  logic [2:0] m_axi_io_AWSIZE;
  logic [1:0] m_axi_io_AWBURST;
  logic [1:0] m_axi_io_AWLOCK;
  logic [3:0] m_axi_io_AWCACHE;
  logic [2:0] m_axi_io_AWPROT;
  logic [3:0] m_axi_io_AWQOS;
  logic [3:0] m_axi_io_AWREGION;
  logic [0:0] m_axi_io_AWUSER;
  logic m_axi_io_WVALID;
  logic m_axi_io_WREADY;
  logic [31:0] m_axi_io_WDATA;
  logic [3:0] m_axi_io_WSTRB;
  logic m_axi_io_WLAST;
  logic [0:0] m_axi_io_WID;
  logic [0:0] m_axi_io_WUSER;
  logic m_axi_io_ARVALID;
  logic m_axi_io_ARREADY;
  logic [63:0] m_axi_io_ARADDR;
  logic [0:0] m_axi_io_ARID;
  logic [7:0] m_axi_io_ARLEN;
  logic [2:0] m_axi_io_ARSIZE;
  logic [1:0] m_axi_io_ARBURST;
  logic [1:0] m_axi_io_ARLOCK;
  logic [3:0] m_axi_io_ARCACHE;
  logic [2:0] m_axi_io_ARPROT;
  logic [3:0] m_axi_io_ARQOS;
  logic [3:0] m_axi_io_ARREGION;
  logic [0:0] m_axi_io_ARUSER;
  logic m_axi_io_RVALID;
  logic m_axi_io_RREADY;
  logic [31:0] m_axi_io_RDATA;
  logic m_axi_io_RLAST;
  logic [0:0] m_axi_io_RID;
  logic [0:0] m_axi_io_RUSER;
  logic [1:0] m_axi_io_RRESP;
  logic m_axi_io_BVALID;
  logic m_axi_io_BREADY;
  logic [1:0] m_axi_io_BRESP;
  logic [0:0] m_axi_io_BID;
  logic [0:0] m_axi_io_BUSER;
  logic m_axi_aux_AWVALID;
  logic m_axi_aux_AWREADY;
  logic [63:0] m_axi_aux_AWADDR;
  logic [0:0] m_axi_aux_AWID;
  logic [7:0] m_axi_aux_AWLEN;
  logic [2:0] m_axi_aux_AWSIZE;
  logic [1:0] m_axi_aux_AWBURST;
  logic [1:0] m_axi_aux_AWLOCK;
  logic [3:0] m_axi_aux_AWCACHE;
  logic [2:0] m_axi_aux_AWPROT;
  logic [3:0] m_axi_aux_AWQOS;
  logic [3:0] m_axi_aux_AWREGION;
  logic [0:0] m_axi_aux_AWUSER;
  logic m_axi_aux_WVALID;
  logic m_axi_aux_WREADY;
  logic [31:0] m_axi_aux_WDATA;
  logic [3:0] m_axi_aux_WSTRB;
  logic m_axi_aux_WLAST;
  logic [0:0] m_axi_aux_WID;
  logic [0:0] m_axi_aux_WUSER;
  logic m_axi_aux_ARVALID;
  logic m_axi_aux_ARREADY;
  logic [63:0] m_axi_aux_ARADDR;
  logic [0:0] m_axi_aux_ARID;
  logic [7:0] m_axi_aux_ARLEN;
  logic [2:0] m_axi_aux_ARSIZE;
  logic [1:0] m_axi_aux_ARBURST;
  logic [1:0] m_axi_aux_ARLOCK;
  logic [3:0] m_axi_aux_ARCACHE;
  logic [2:0] m_axi_aux_ARPROT;
  logic [3:0] m_axi_aux_ARQOS;
  logic [3:0] m_axi_aux_ARREGION;
  logic [0:0] m_axi_aux_ARUSER;
  logic m_axi_aux_RVALID;
  logic m_axi_aux_RREADY;
  logic [31:0] m_axi_aux_RDATA;
  logic m_axi_aux_RLAST;
  logic [0:0] m_axi_aux_RID;
  logic [0:0] m_axi_aux_RUSER;
  logic [1:0] m_axi_aux_RRESP;
  logic m_axi_aux_BVALID;
  logic m_axi_aux_BREADY;
  logic [1:0] m_axi_aux_BRESP;
  logic [0:0] m_axi_aux_BID;
  logic [0:0] m_axi_aux_BUSER;
  logic m_axi_state0_AWVALID;
  logic m_axi_state0_AWREADY;
  logic [63:0] m_axi_state0_AWADDR;
  logic [0:0] m_axi_state0_AWID;
  logic [7:0] m_axi_state0_AWLEN;
  logic [2:0] m_axi_state0_AWSIZE;
  logic [1:0] m_axi_state0_AWBURST;
  logic [1:0] m_axi_state0_AWLOCK;
  logic [3:0] m_axi_state0_AWCACHE;
  logic [2:0] m_axi_state0_AWPROT;
  logic [3:0] m_axi_state0_AWQOS;
  logic [3:0] m_axi_state0_AWREGION;
  logic [0:0] m_axi_state0_AWUSER;
  logic m_axi_state0_WVALID;
  logic m_axi_state0_WREADY;
  logic [31:0] m_axi_state0_WDATA;
  logic [3:0] m_axi_state0_WSTRB;
  logic m_axi_state0_WLAST;
  logic [0:0] m_axi_state0_WID;
  logic [0:0] m_axi_state0_WUSER;
  logic m_axi_state0_ARVALID;
  logic m_axi_state0_ARREADY;
  logic [63:0] m_axi_state0_ARADDR;
  logic [0:0] m_axi_state0_ARID;
  logic [7:0] m_axi_state0_ARLEN;
  logic [2:0] m_axi_state0_ARSIZE;
  logic [1:0] m_axi_state0_ARBURST;
  logic [1:0] m_axi_state0_ARLOCK;
  logic [3:0] m_axi_state0_ARCACHE;
  logic [2:0] m_axi_state0_ARPROT;
  logic [3:0] m_axi_state0_ARQOS;
  logic [3:0] m_axi_state0_ARREGION;
  logic [0:0] m_axi_state0_ARUSER;
  logic m_axi_state0_RVALID;
  logic m_axi_state0_RREADY;
  logic [31:0] m_axi_state0_RDATA;
  logic m_axi_state0_RLAST;
  logic [0:0] m_axi_state0_RID;
  logic [0:0] m_axi_state0_RUSER;
  logic [1:0] m_axi_state0_RRESP;
  logic m_axi_state0_BVALID;
  logic m_axi_state0_BREADY;
  logic [1:0] m_axi_state0_BRESP;
  logic [0:0] m_axi_state0_BID;
  logic [0:0] m_axi_state0_BUSER;
  logic m_axi_state1_AWVALID;
  logic m_axi_state1_AWREADY;
  logic [63:0] m_axi_state1_AWADDR;
  logic [0:0] m_axi_state1_AWID;
  logic [7:0] m_axi_state1_AWLEN;
  logic [2:0] m_axi_state1_AWSIZE;
  logic [1:0] m_axi_state1_AWBURST;
  logic [1:0] m_axi_state1_AWLOCK;
  logic [3:0] m_axi_state1_AWCACHE;
  logic [2:0] m_axi_state1_AWPROT;
  logic [3:0] m_axi_state1_AWQOS;
  logic [3:0] m_axi_state1_AWREGION;
  logic [0:0] m_axi_state1_AWUSER;
  logic m_axi_state1_WVALID;
  logic m_axi_state1_WREADY;
  logic [31:0] m_axi_state1_WDATA;
  logic [3:0] m_axi_state1_WSTRB;
  logic m_axi_state1_WLAST;
  logic [0:0] m_axi_state1_WID;
  logic [0:0] m_axi_state1_WUSER;
  logic m_axi_state1_ARVALID;
  logic m_axi_state1_ARREADY;
  logic [63:0] m_axi_state1_ARADDR;
  logic [0:0] m_axi_state1_ARID;
  logic [7:0] m_axi_state1_ARLEN;
  logic [2:0] m_axi_state1_ARSIZE;
  logic [1:0] m_axi_state1_ARBURST;
  logic [1:0] m_axi_state1_ARLOCK;
  logic [3:0] m_axi_state1_ARCACHE;
  logic [2:0] m_axi_state1_ARPROT;
  logic [3:0] m_axi_state1_ARQOS;
  logic [3:0] m_axi_state1_ARREGION;
  logic [0:0] m_axi_state1_ARUSER;
  logic m_axi_state1_RVALID;
  logic m_axi_state1_RREADY;
  logic [31:0] m_axi_state1_RDATA;
  logic m_axi_state1_RLAST;
  logic [0:0] m_axi_state1_RID;
  logic [0:0] m_axi_state1_RUSER;
  logic [1:0] m_axi_state1_RRESP;
  logic m_axi_state1_BVALID;
  logic m_axi_state1_BREADY;
  logic [1:0] m_axi_state1_BRESP;
  logic [0:0] m_axi_state1_BID;
  logic [0:0] m_axi_state1_BUSER;
  logic m_axi_observed_AWVALID;
  logic m_axi_observed_AWREADY;
  logic [63:0] m_axi_observed_AWADDR;
  logic [0:0] m_axi_observed_AWID;
  logic [7:0] m_axi_observed_AWLEN;
  logic [2:0] m_axi_observed_AWSIZE;
  logic [1:0] m_axi_observed_AWBURST;
  logic [1:0] m_axi_observed_AWLOCK;
  logic [3:0] m_axi_observed_AWCACHE;
  logic [2:0] m_axi_observed_AWPROT;
  logic [3:0] m_axi_observed_AWQOS;
  logic [3:0] m_axi_observed_AWREGION;
  logic [0:0] m_axi_observed_AWUSER;
  logic m_axi_observed_WVALID;
  logic m_axi_observed_WREADY;
  logic [31:0] m_axi_observed_WDATA;
  logic [3:0] m_axi_observed_WSTRB;
  logic m_axi_observed_WLAST;
  logic [0:0] m_axi_observed_WID;
  logic [0:0] m_axi_observed_WUSER;
  logic m_axi_observed_ARVALID;
  logic m_axi_observed_ARREADY;
  logic [63:0] m_axi_observed_ARADDR;
  logic [0:0] m_axi_observed_ARID;
  logic [7:0] m_axi_observed_ARLEN;
  logic [2:0] m_axi_observed_ARSIZE;
  logic [1:0] m_axi_observed_ARBURST;
  logic [1:0] m_axi_observed_ARLOCK;
  logic [3:0] m_axi_observed_ARCACHE;
  logic [2:0] m_axi_observed_ARPROT;
  logic [3:0] m_axi_observed_ARQOS;
  logic [3:0] m_axi_observed_ARREGION;
  logic [0:0] m_axi_observed_ARUSER;
  logic m_axi_observed_RVALID;
  logic m_axi_observed_RREADY;
  logic [31:0] m_axi_observed_RDATA;
  logic m_axi_observed_RLAST;
  logic [0:0] m_axi_observed_RID;
  logic [0:0] m_axi_observed_RUSER;
  logic [1:0] m_axi_observed_RRESP;
  logic m_axi_observed_BVALID;
  logic m_axi_observed_BREADY;
  logic [1:0] m_axi_observed_BRESP;
  logic [0:0] m_axi_observed_BID;
  logic [0:0] m_axi_observed_BUSER;
  logic s_axi_control_AWVALID;
  logic s_axi_control_AWREADY;
  logic [4:0] s_axi_control_AWADDR;
  logic s_axi_control_WVALID;
  logic s_axi_control_WREADY;
  logic [31:0] s_axi_control_WDATA;
  logic [3:0] s_axi_control_WSTRB;
  logic s_axi_control_ARVALID;
  logic s_axi_control_ARREADY;
  logic [4:0] s_axi_control_ARADDR;
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
  vector_controller_slice dut (
    .ap_clk(clk),
    .ap_rst_n(resetn),
    .m_axi_src0_input_AWVALID(m_axi_src0_input_AWVALID),
    .m_axi_src0_input_AWREADY(m_axi_src0_input_AWREADY),
    .m_axi_src0_input_AWADDR(m_axi_src0_input_AWADDR),
    .m_axi_src0_input_AWID(m_axi_src0_input_AWID),
    .m_axi_src0_input_AWLEN(m_axi_src0_input_AWLEN),
    .m_axi_src0_input_AWSIZE(m_axi_src0_input_AWSIZE),
    .m_axi_src0_input_AWBURST(m_axi_src0_input_AWBURST),
    .m_axi_src0_input_AWLOCK(m_axi_src0_input_AWLOCK),
    .m_axi_src0_input_AWCACHE(m_axi_src0_input_AWCACHE),
    .m_axi_src0_input_AWPROT(m_axi_src0_input_AWPROT),
    .m_axi_src0_input_AWQOS(m_axi_src0_input_AWQOS),
    .m_axi_src0_input_AWREGION(m_axi_src0_input_AWREGION),
    .m_axi_src0_input_AWUSER(m_axi_src0_input_AWUSER),
    .m_axi_src0_input_WVALID(m_axi_src0_input_WVALID),
    .m_axi_src0_input_WREADY(m_axi_src0_input_WREADY),
    .m_axi_src0_input_WDATA(m_axi_src0_input_WDATA),
    .m_axi_src0_input_WSTRB(m_axi_src0_input_WSTRB),
    .m_axi_src0_input_WLAST(m_axi_src0_input_WLAST),
    .m_axi_src0_input_WID(m_axi_src0_input_WID),
    .m_axi_src0_input_WUSER(m_axi_src0_input_WUSER),
    .m_axi_src0_input_ARVALID(m_axi_src0_input_ARVALID),
    .m_axi_src0_input_ARREADY(m_axi_src0_input_ARREADY),
    .m_axi_src0_input_ARADDR(m_axi_src0_input_ARADDR),
    .m_axi_src0_input_ARID(m_axi_src0_input_ARID),
    .m_axi_src0_input_ARLEN(m_axi_src0_input_ARLEN),
    .m_axi_src0_input_ARSIZE(m_axi_src0_input_ARSIZE),
    .m_axi_src0_input_ARBURST(m_axi_src0_input_ARBURST),
    .m_axi_src0_input_ARLOCK(m_axi_src0_input_ARLOCK),
    .m_axi_src0_input_ARCACHE(m_axi_src0_input_ARCACHE),
    .m_axi_src0_input_ARPROT(m_axi_src0_input_ARPROT),
    .m_axi_src0_input_ARQOS(m_axi_src0_input_ARQOS),
    .m_axi_src0_input_ARREGION(m_axi_src0_input_ARREGION),
    .m_axi_src0_input_ARUSER(m_axi_src0_input_ARUSER),
    .m_axi_src0_input_RVALID(m_axi_src0_input_RVALID),
    .m_axi_src0_input_RREADY(m_axi_src0_input_RREADY),
    .m_axi_src0_input_RDATA(m_axi_src0_input_RDATA),
    .m_axi_src0_input_RLAST(m_axi_src0_input_RLAST),
    .m_axi_src0_input_RID(m_axi_src0_input_RID),
    .m_axi_src0_input_RUSER(m_axi_src0_input_RUSER),
    .m_axi_src0_input_RRESP(m_axi_src0_input_RRESP),
    .m_axi_src0_input_BVALID(m_axi_src0_input_BVALID),
    .m_axi_src0_input_BREADY(m_axi_src0_input_BREADY),
    .m_axi_src0_input_BRESP(m_axi_src0_input_BRESP),
    .m_axi_src0_input_BID(m_axi_src0_input_BID),
    .m_axi_src0_input_BUSER(m_axi_src0_input_BUSER),
    .m_axi_src1_input_AWVALID(m_axi_src1_input_AWVALID),
    .m_axi_src1_input_AWREADY(m_axi_src1_input_AWREADY),
    .m_axi_src1_input_AWADDR(m_axi_src1_input_AWADDR),
    .m_axi_src1_input_AWID(m_axi_src1_input_AWID),
    .m_axi_src1_input_AWLEN(m_axi_src1_input_AWLEN),
    .m_axi_src1_input_AWSIZE(m_axi_src1_input_AWSIZE),
    .m_axi_src1_input_AWBURST(m_axi_src1_input_AWBURST),
    .m_axi_src1_input_AWLOCK(m_axi_src1_input_AWLOCK),
    .m_axi_src1_input_AWCACHE(m_axi_src1_input_AWCACHE),
    .m_axi_src1_input_AWPROT(m_axi_src1_input_AWPROT),
    .m_axi_src1_input_AWQOS(m_axi_src1_input_AWQOS),
    .m_axi_src1_input_AWREGION(m_axi_src1_input_AWREGION),
    .m_axi_src1_input_AWUSER(m_axi_src1_input_AWUSER),
    .m_axi_src1_input_WVALID(m_axi_src1_input_WVALID),
    .m_axi_src1_input_WREADY(m_axi_src1_input_WREADY),
    .m_axi_src1_input_WDATA(m_axi_src1_input_WDATA),
    .m_axi_src1_input_WSTRB(m_axi_src1_input_WSTRB),
    .m_axi_src1_input_WLAST(m_axi_src1_input_WLAST),
    .m_axi_src1_input_WID(m_axi_src1_input_WID),
    .m_axi_src1_input_WUSER(m_axi_src1_input_WUSER),
    .m_axi_src1_input_ARVALID(m_axi_src1_input_ARVALID),
    .m_axi_src1_input_ARREADY(m_axi_src1_input_ARREADY),
    .m_axi_src1_input_ARADDR(m_axi_src1_input_ARADDR),
    .m_axi_src1_input_ARID(m_axi_src1_input_ARID),
    .m_axi_src1_input_ARLEN(m_axi_src1_input_ARLEN),
    .m_axi_src1_input_ARSIZE(m_axi_src1_input_ARSIZE),
    .m_axi_src1_input_ARBURST(m_axi_src1_input_ARBURST),
    .m_axi_src1_input_ARLOCK(m_axi_src1_input_ARLOCK),
    .m_axi_src1_input_ARCACHE(m_axi_src1_input_ARCACHE),
    .m_axi_src1_input_ARPROT(m_axi_src1_input_ARPROT),
    .m_axi_src1_input_ARQOS(m_axi_src1_input_ARQOS),
    .m_axi_src1_input_ARREGION(m_axi_src1_input_ARREGION),
    .m_axi_src1_input_ARUSER(m_axi_src1_input_ARUSER),
    .m_axi_src1_input_RVALID(m_axi_src1_input_RVALID),
    .m_axi_src1_input_RREADY(m_axi_src1_input_RREADY),
    .m_axi_src1_input_RDATA(m_axi_src1_input_RDATA),
    .m_axi_src1_input_RLAST(m_axi_src1_input_RLAST),
    .m_axi_src1_input_RID(m_axi_src1_input_RID),
    .m_axi_src1_input_RUSER(m_axi_src1_input_RUSER),
    .m_axi_src1_input_RRESP(m_axi_src1_input_RRESP),
    .m_axi_src1_input_BVALID(m_axi_src1_input_BVALID),
    .m_axi_src1_input_BREADY(m_axi_src1_input_BREADY),
    .m_axi_src1_input_BRESP(m_axi_src1_input_BRESP),
    .m_axi_src1_input_BID(m_axi_src1_input_BID),
    .m_axi_src1_input_BUSER(m_axi_src1_input_BUSER),
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
  logic r_hold_applied [0:6], b_hold_applied [0:6];
  logic [31:0] r_special_wait_cycles [0:6], b_special_wait_cycles [0:6];
  logic hold_final_r [0:6], hold_final_b [0:6];
  att_axi_port #(.DATA_BITS(32),.PORT(0),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003000000000})) u_port_src0_input (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003000000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003000000040}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[0]),.hold_final_b(hold_final_b[0]),
    .r_hold_applied(r_hold_applied[0]),.b_hold_applied(b_hold_applied[0]),
    .r_special_wait_cycles(r_special_wait_cycles[0]),
    .b_special_wait_cycles(b_special_wait_cycles[0]),
    .awvalid(m_axi_src0_input_AWVALID),
    .awready(m_axi_src0_input_AWREADY),
    .awaddr(m_axi_src0_input_AWADDR),
    .awid(m_axi_src0_input_AWID),
    .awlen(m_axi_src0_input_AWLEN),
    .awsize(m_axi_src0_input_AWSIZE),
    .awburst(m_axi_src0_input_AWBURST),
    .awlock(m_axi_src0_input_AWLOCK),
    .awcache(m_axi_src0_input_AWCACHE),
    .awprot(m_axi_src0_input_AWPROT),
    .awqos(m_axi_src0_input_AWQOS),
    .awregion(m_axi_src0_input_AWREGION),
    .awuser(m_axi_src0_input_AWUSER),
    .wvalid(m_axi_src0_input_WVALID),
    .wready(m_axi_src0_input_WREADY),
    .wdata(m_axi_src0_input_WDATA),
    .wstrb(m_axi_src0_input_WSTRB),
    .wlast(m_axi_src0_input_WLAST),
    .wid(m_axi_src0_input_WID),
    .wuser(m_axi_src0_input_WUSER),
    .arvalid(m_axi_src0_input_ARVALID),
    .arready(m_axi_src0_input_ARREADY),
    .araddr(m_axi_src0_input_ARADDR),
    .arid(m_axi_src0_input_ARID),
    .arlen(m_axi_src0_input_ARLEN),
    .arsize(m_axi_src0_input_ARSIZE),
    .arburst(m_axi_src0_input_ARBURST),
    .arlock(m_axi_src0_input_ARLOCK),
    .arcache(m_axi_src0_input_ARCACHE),
    .arprot(m_axi_src0_input_ARPROT),
    .arqos(m_axi_src0_input_ARQOS),
    .arregion(m_axi_src0_input_ARREGION),
    .aruser(m_axi_src0_input_ARUSER),
    .rvalid(m_axi_src0_input_RVALID),
    .rready(m_axi_src0_input_RREADY),
    .rdata(m_axi_src0_input_RDATA),
    .rlast(m_axi_src0_input_RLAST),
    .rid(m_axi_src0_input_RID),
    .ruser(m_axi_src0_input_RUSER),
    .rresp(m_axi_src0_input_RRESP),
    .bvalid(m_axi_src0_input_BVALID),
    .bready(m_axi_src0_input_BREADY),
    .bresp(m_axi_src0_input_BRESP),
    .bid(m_axi_src0_input_BID),
    .buser(m_axi_src0_input_BUSER),
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
  att_axi_port #(.DATA_BITS(32),.PORT(1),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003100000000})) u_port_src1_input (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .hold_final_r(hold_final_r[1]),.hold_final_b(hold_final_b[1]),
    .r_hold_applied(r_hold_applied[1]),.b_hold_applied(b_hold_applied[1]),
    .r_special_wait_cycles(r_special_wait_cycles[1]),
    .b_special_wait_cycles(b_special_wait_cycles[1]),
    .awvalid(m_axi_src1_input_AWVALID),
    .awready(m_axi_src1_input_AWREADY),
    .awaddr(m_axi_src1_input_AWADDR),
    .awid(m_axi_src1_input_AWID),
    .awlen(m_axi_src1_input_AWLEN),
    .awsize(m_axi_src1_input_AWSIZE),
    .awburst(m_axi_src1_input_AWBURST),
    .awlock(m_axi_src1_input_AWLOCK),
    .awcache(m_axi_src1_input_AWCACHE),
    .awprot(m_axi_src1_input_AWPROT),
    .awqos(m_axi_src1_input_AWQOS),
    .awregion(m_axi_src1_input_AWREGION),
    .awuser(m_axi_src1_input_AWUSER),
    .wvalid(m_axi_src1_input_WVALID),
    .wready(m_axi_src1_input_WREADY),
    .wdata(m_axi_src1_input_WDATA),
    .wstrb(m_axi_src1_input_WSTRB),
    .wlast(m_axi_src1_input_WLAST),
    .wid(m_axi_src1_input_WID),
    .wuser(m_axi_src1_input_WUSER),
    .arvalid(m_axi_src1_input_ARVALID),
    .arready(m_axi_src1_input_ARREADY),
    .araddr(m_axi_src1_input_ARADDR),
    .arid(m_axi_src1_input_ARID),
    .arlen(m_axi_src1_input_ARLEN),
    .arsize(m_axi_src1_input_ARSIZE),
    .arburst(m_axi_src1_input_ARBURST),
    .arlock(m_axi_src1_input_ARLOCK),
    .arcache(m_axi_src1_input_ARCACHE),
    .arprot(m_axi_src1_input_ARPROT),
    .arqos(m_axi_src1_input_ARQOS),
    .arregion(m_axi_src1_input_ARREGION),
    .aruser(m_axi_src1_input_ARUSER),
    .rvalid(m_axi_src1_input_RVALID),
    .rready(m_axi_src1_input_RREADY),
    .rdata(m_axi_src1_input_RDATA),
    .rlast(m_axi_src1_input_RLAST),
    .rid(m_axi_src1_input_RID),
    .ruser(m_axi_src1_input_RUSER),
    .rresp(m_axi_src1_input_RRESP),
    .bvalid(m_axi_src1_input_BVALID),
    .bready(m_axi_src1_input_BREADY),
    .bresp(m_axi_src1_input_BRESP),
    .bid(m_axi_src1_input_BID),
    .buser(m_axi_src1_input_BUSER),
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
  att_axi_port #(.DATA_BITS(32),.PORT(2),.PAGE_COUNT(8),
                 .PAGE_BASES({64'h0000003200007000,64'h0000003200006000,64'h0000003200005000,64'h0000003200004000,64'h0000003200003000,64'h0000003200002000,64'h0000003200001000,64'h0000003200000000})) u_port_io (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003200000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003200000340}),
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
    .accepted(accepted[2]),.delivered(delivered[2])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(3),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003300000000})) u_port_aux (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003300000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003300000080}),
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
    .accepted(accepted[3]),.delivered(delivered[3])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(4),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003400000000})) u_port_state0 (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
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
    .accepted(accepted[4]),.delivered(delivered[4])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(5),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003501022000})) u_port_state1 (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h00000035010229c0}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003501022a00}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000003501022840,64'h00000035010229c0}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000003501022880,64'h0000003501022a00}),
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
    .accepted(accepted[5]),.delivered(delivered[5])
  );
  att_axi_port #(.DATA_BITS(32),.PORT(6),.PAGE_COUNT(1),
                 .PAGE_BASES({64'h0000003600000000})) u_port_observed (
    .clk(clk),.resetn(resetn),
    .read_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),.read_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000000000000000}),
    .write_lo({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003600000000}),.write_hi({64'h0000000000000000,64'h0000000000000000,64'h0000000000000000,64'h0000003600000080}),
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
    .accepted(accepted[6]),.delivered(delivered[6])
  );
  logic lite_cmd_valid_0,lite_cmd_ready_0,lite_cmd_write_0,lite_cmd_done_0;
  logic [4:0] lite_cmd_addr_0;
  logic [31:0] lite_cmd_wdata_0,lite_cmd_rdata_0;
  att_axi_lite_master #(.ADDR_BITS(5),.BANK(0)) lite_0 (
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
  `include "vector_mode3_control.svh"
endmodule
