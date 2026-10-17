`timescale 1ns/1ps
module cpu_front_top;
import "DPI-C" function int thin_mem_init();
import "DPI-C" function int thin_mem_progress();
import "DPI-C" function int thin_mem_raw_bytes();
import "DPI-C" function int thin_mem_norm_bytes();
import "DPI-C" function int thin_mem_obs_bytes();
import "DPI-C" function int thin_mem_state0_import_words();
import "DPI-C" function int thin_mem_state0_ln_read_words();
import "DPI-C" function int thin_mem_gamma_read_words();
import "DPI-C" function int thin_mem_errors();
import "DPI-C" function int thin_mem_capture_first_done();
import "DPI-C" function int thin_mem_check();
localparam    ap_ST_fsm_state1 = 5'd1;
localparam    ap_ST_fsm_state2 = 5'd2;
localparam    ap_ST_fsm_state3 = 5'd4;
localparam    ap_ST_fsm_state4 = 5'd8;
localparam    ap_ST_fsm_state5 = 5'd16;
localparam    C_S_AXI_CONTROL_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_ADDR_WIDTH = 4;
localparam    C_S_AXI_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_ADDR_WIDTH = 7;
localparam    C_M_AXI_AUX_ID_WIDTH = 1;
localparam    C_M_AXI_AUX_ADDR_WIDTH = 64;
localparam    C_M_AXI_AUX_DATA_WIDTH = 32;
localparam    C_M_AXI_AUX_AWUSER_WIDTH = 1;
localparam    C_M_AXI_AUX_ARUSER_WIDTH = 1;
localparam    C_M_AXI_AUX_WUSER_WIDTH = 1;
localparam    C_M_AXI_AUX_RUSER_WIDTH = 1;
localparam    C_M_AXI_AUX_BUSER_WIDTH = 1;
localparam    C_M_AXI_AUX_USER_VALUE = 0;
localparam    C_M_AXI_AUX_PROT_VALUE = 0;
localparam    C_M_AXI_AUX_CACHE_VALUE = 3;
localparam    C_M_AXI_DATA_WIDTH = 32;
localparam    C_M_AXI_IO_ID_WIDTH = 1;
localparam    C_M_AXI_IO_ADDR_WIDTH = 64;
localparam    C_M_AXI_IO_DATA_WIDTH = 32;
localparam    C_M_AXI_IO_AWUSER_WIDTH = 1;
localparam    C_M_AXI_IO_ARUSER_WIDTH = 1;
localparam    C_M_AXI_IO_WUSER_WIDTH = 1;
localparam    C_M_AXI_IO_RUSER_WIDTH = 1;
localparam    C_M_AXI_IO_BUSER_WIDTH = 1;
localparam    C_M_AXI_IO_USER_VALUE = 0;
localparam    C_M_AXI_IO_PROT_VALUE = 0;
localparam    C_M_AXI_IO_CACHE_VALUE = 3;
localparam    C_M_AXI_OBSERVED_ID_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_ADDR_WIDTH = 64;
localparam    C_M_AXI_OBSERVED_DATA_WIDTH = 32;
localparam    C_M_AXI_OBSERVED_AWUSER_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_ARUSER_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_WUSER_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_RUSER_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_BUSER_WIDTH = 1;
localparam    C_M_AXI_OBSERVED_USER_VALUE = 0;
localparam    C_M_AXI_OBSERVED_PROT_VALUE = 0;
localparam    C_M_AXI_OBSERVED_CACHE_VALUE = 3;
localparam    C_M_AXI_STATE0_ID_WIDTH = 1;
localparam    C_M_AXI_STATE0_ADDR_WIDTH = 64;
localparam    C_M_AXI_STATE0_DATA_WIDTH = 32;
localparam    C_M_AXI_STATE0_AWUSER_WIDTH = 1;
localparam    C_M_AXI_STATE0_ARUSER_WIDTH = 1;
localparam    C_M_AXI_STATE0_WUSER_WIDTH = 1;
localparam    C_M_AXI_STATE0_RUSER_WIDTH = 1;
localparam    C_M_AXI_STATE0_BUSER_WIDTH = 1;
localparam    C_M_AXI_STATE0_USER_VALUE = 0;
localparam    C_M_AXI_STATE0_PROT_VALUE = 0;
localparam    C_M_AXI_STATE0_CACHE_VALUE = 3;
localparam    C_M_AXI_STATE1_ID_WIDTH = 1;
localparam    C_M_AXI_STATE1_ADDR_WIDTH = 64;
localparam    C_M_AXI_STATE1_DATA_WIDTH = 32;
localparam    C_M_AXI_STATE1_AWUSER_WIDTH = 1;
localparam    C_M_AXI_STATE1_ARUSER_WIDTH = 1;
localparam    C_M_AXI_STATE1_WUSER_WIDTH = 1;
localparam    C_M_AXI_STATE1_RUSER_WIDTH = 1;
localparam    C_M_AXI_STATE1_BUSER_WIDTH = 1;
localparam    C_M_AXI_STATE1_USER_VALUE = 0;
localparam    C_M_AXI_STATE1_PROT_VALUE = 0;
localparam    C_M_AXI_STATE1_CACHE_VALUE = 3;
localparam C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_CONTROL_R_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_AUX_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_IO_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_OBSERVED_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_STATE0_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_STATE1_WSTRB_WIDTH = (32 / 8);
logic ap_clk;
logic ap_rst_n;
logic m_axi_io_AWVALID;
logic m_axi_io_AWREADY;
logic [C_M_AXI_IO_ADDR_WIDTH - 1:0] m_axi_io_AWADDR;
logic [C_M_AXI_IO_ID_WIDTH - 1:0] m_axi_io_AWID;
logic [7:0] m_axi_io_AWLEN;
logic [2:0] m_axi_io_AWSIZE;
logic [1:0] m_axi_io_AWBURST;
logic [1:0] m_axi_io_AWLOCK;
logic [3:0] m_axi_io_AWCACHE;
logic [2:0] m_axi_io_AWPROT;
logic [3:0] m_axi_io_AWQOS;
logic [3:0] m_axi_io_AWREGION;
logic [C_M_AXI_IO_AWUSER_WIDTH - 1:0] m_axi_io_AWUSER;
logic m_axi_io_WVALID;
logic m_axi_io_WREADY;
logic [C_M_AXI_IO_DATA_WIDTH - 1:0] m_axi_io_WDATA;
logic [C_M_AXI_IO_WSTRB_WIDTH - 1:0] m_axi_io_WSTRB;
logic m_axi_io_WLAST;
logic [C_M_AXI_IO_ID_WIDTH - 1:0] m_axi_io_WID;
logic [C_M_AXI_IO_WUSER_WIDTH - 1:0] m_axi_io_WUSER;
logic m_axi_io_ARVALID;
logic m_axi_io_ARREADY;
logic [C_M_AXI_IO_ADDR_WIDTH - 1:0] m_axi_io_ARADDR;
logic [C_M_AXI_IO_ID_WIDTH - 1:0] m_axi_io_ARID;
logic [7:0] m_axi_io_ARLEN;
logic [2:0] m_axi_io_ARSIZE;
logic [1:0] m_axi_io_ARBURST;
logic [1:0] m_axi_io_ARLOCK;
logic [3:0] m_axi_io_ARCACHE;
logic [2:0] m_axi_io_ARPROT;
logic [3:0] m_axi_io_ARQOS;
logic [3:0] m_axi_io_ARREGION;
logic [C_M_AXI_IO_ARUSER_WIDTH - 1:0] m_axi_io_ARUSER;
logic m_axi_io_RVALID;
logic m_axi_io_RREADY;
logic [C_M_AXI_IO_DATA_WIDTH - 1:0] m_axi_io_RDATA;
logic m_axi_io_RLAST;
logic [C_M_AXI_IO_ID_WIDTH - 1:0] m_axi_io_RID;
logic [C_M_AXI_IO_RUSER_WIDTH - 1:0] m_axi_io_RUSER;
logic [1:0] m_axi_io_RRESP;
logic m_axi_io_BVALID;
logic m_axi_io_BREADY;
logic [1:0] m_axi_io_BRESP;
logic [C_M_AXI_IO_ID_WIDTH - 1:0] m_axi_io_BID;
logic [C_M_AXI_IO_BUSER_WIDTH - 1:0] m_axi_io_BUSER;
logic m_axi_aux_AWVALID;
logic m_axi_aux_AWREADY;
logic [C_M_AXI_AUX_ADDR_WIDTH - 1:0] m_axi_aux_AWADDR;
logic [C_M_AXI_AUX_ID_WIDTH - 1:0] m_axi_aux_AWID;
logic [7:0] m_axi_aux_AWLEN;
logic [2:0] m_axi_aux_AWSIZE;
logic [1:0] m_axi_aux_AWBURST;
logic [1:0] m_axi_aux_AWLOCK;
logic [3:0] m_axi_aux_AWCACHE;
logic [2:0] m_axi_aux_AWPROT;
logic [3:0] m_axi_aux_AWQOS;
logic [3:0] m_axi_aux_AWREGION;
logic [C_M_AXI_AUX_AWUSER_WIDTH - 1:0] m_axi_aux_AWUSER;
logic m_axi_aux_WVALID;
logic m_axi_aux_WREADY;
logic [C_M_AXI_AUX_DATA_WIDTH - 1:0] m_axi_aux_WDATA;
logic [C_M_AXI_AUX_WSTRB_WIDTH - 1:0] m_axi_aux_WSTRB;
logic m_axi_aux_WLAST;
logic [C_M_AXI_AUX_ID_WIDTH - 1:0] m_axi_aux_WID;
logic [C_M_AXI_AUX_WUSER_WIDTH - 1:0] m_axi_aux_WUSER;
logic m_axi_aux_ARVALID;
logic m_axi_aux_ARREADY;
logic [C_M_AXI_AUX_ADDR_WIDTH - 1:0] m_axi_aux_ARADDR;
logic [C_M_AXI_AUX_ID_WIDTH - 1:0] m_axi_aux_ARID;
logic [7:0] m_axi_aux_ARLEN;
logic [2:0] m_axi_aux_ARSIZE;
logic [1:0] m_axi_aux_ARBURST;
logic [1:0] m_axi_aux_ARLOCK;
logic [3:0] m_axi_aux_ARCACHE;
logic [2:0] m_axi_aux_ARPROT;
logic [3:0] m_axi_aux_ARQOS;
logic [3:0] m_axi_aux_ARREGION;
logic [C_M_AXI_AUX_ARUSER_WIDTH - 1:0] m_axi_aux_ARUSER;
logic m_axi_aux_RVALID;
logic m_axi_aux_RREADY;
logic [C_M_AXI_AUX_DATA_WIDTH - 1:0] m_axi_aux_RDATA;
logic m_axi_aux_RLAST;
logic [C_M_AXI_AUX_ID_WIDTH - 1:0] m_axi_aux_RID;
logic [C_M_AXI_AUX_RUSER_WIDTH - 1:0] m_axi_aux_RUSER;
logic [1:0] m_axi_aux_RRESP;
logic m_axi_aux_BVALID;
logic m_axi_aux_BREADY;
logic [1:0] m_axi_aux_BRESP;
logic [C_M_AXI_AUX_ID_WIDTH - 1:0] m_axi_aux_BID;
logic [C_M_AXI_AUX_BUSER_WIDTH - 1:0] m_axi_aux_BUSER;
logic m_axi_state0_AWVALID;
logic m_axi_state0_AWREADY;
logic [C_M_AXI_STATE0_ADDR_WIDTH - 1:0] m_axi_state0_AWADDR;
logic [C_M_AXI_STATE0_ID_WIDTH - 1:0] m_axi_state0_AWID;
logic [7:0] m_axi_state0_AWLEN;
logic [2:0] m_axi_state0_AWSIZE;
logic [1:0] m_axi_state0_AWBURST;
logic [1:0] m_axi_state0_AWLOCK;
logic [3:0] m_axi_state0_AWCACHE;
logic [2:0] m_axi_state0_AWPROT;
logic [3:0] m_axi_state0_AWQOS;
logic [3:0] m_axi_state0_AWREGION;
logic [C_M_AXI_STATE0_AWUSER_WIDTH - 1:0] m_axi_state0_AWUSER;
logic m_axi_state0_WVALID;
logic m_axi_state0_WREADY;
logic [C_M_AXI_STATE0_DATA_WIDTH - 1:0] m_axi_state0_WDATA;
logic [C_M_AXI_STATE0_WSTRB_WIDTH - 1:0] m_axi_state0_WSTRB;
logic m_axi_state0_WLAST;
logic [C_M_AXI_STATE0_ID_WIDTH - 1:0] m_axi_state0_WID;
logic [C_M_AXI_STATE0_WUSER_WIDTH - 1:0] m_axi_state0_WUSER;
logic m_axi_state0_ARVALID;
logic m_axi_state0_ARREADY;
logic [C_M_AXI_STATE0_ADDR_WIDTH - 1:0] m_axi_state0_ARADDR;
logic [C_M_AXI_STATE0_ID_WIDTH - 1:0] m_axi_state0_ARID;
logic [7:0] m_axi_state0_ARLEN;
logic [2:0] m_axi_state0_ARSIZE;
logic [1:0] m_axi_state0_ARBURST;
logic [1:0] m_axi_state0_ARLOCK;
logic [3:0] m_axi_state0_ARCACHE;
logic [2:0] m_axi_state0_ARPROT;
logic [3:0] m_axi_state0_ARQOS;
logic [3:0] m_axi_state0_ARREGION;
logic [C_M_AXI_STATE0_ARUSER_WIDTH - 1:0] m_axi_state0_ARUSER;
logic m_axi_state0_RVALID;
logic m_axi_state0_RREADY;
logic [C_M_AXI_STATE0_DATA_WIDTH - 1:0] m_axi_state0_RDATA;
logic m_axi_state0_RLAST;
logic [C_M_AXI_STATE0_ID_WIDTH - 1:0] m_axi_state0_RID;
logic [C_M_AXI_STATE0_RUSER_WIDTH - 1:0] m_axi_state0_RUSER;
logic [1:0] m_axi_state0_RRESP;
logic m_axi_state0_BVALID;
logic m_axi_state0_BREADY;
logic [1:0] m_axi_state0_BRESP;
logic [C_M_AXI_STATE0_ID_WIDTH - 1:0] m_axi_state0_BID;
logic [C_M_AXI_STATE0_BUSER_WIDTH - 1:0] m_axi_state0_BUSER;
logic m_axi_state1_AWVALID;
logic m_axi_state1_AWREADY;
logic [C_M_AXI_STATE1_ADDR_WIDTH - 1:0] m_axi_state1_AWADDR;
logic [C_M_AXI_STATE1_ID_WIDTH - 1:0] m_axi_state1_AWID;
logic [7:0] m_axi_state1_AWLEN;
logic [2:0] m_axi_state1_AWSIZE;
logic [1:0] m_axi_state1_AWBURST;
logic [1:0] m_axi_state1_AWLOCK;
logic [3:0] m_axi_state1_AWCACHE;
logic [2:0] m_axi_state1_AWPROT;
logic [3:0] m_axi_state1_AWQOS;
logic [3:0] m_axi_state1_AWREGION;
logic [C_M_AXI_STATE1_AWUSER_WIDTH - 1:0] m_axi_state1_AWUSER;
logic m_axi_state1_WVALID;
logic m_axi_state1_WREADY;
logic [C_M_AXI_STATE1_DATA_WIDTH - 1:0] m_axi_state1_WDATA;
logic [C_M_AXI_STATE1_WSTRB_WIDTH - 1:0] m_axi_state1_WSTRB;
logic m_axi_state1_WLAST;
logic [C_M_AXI_STATE1_ID_WIDTH - 1:0] m_axi_state1_WID;
logic [C_M_AXI_STATE1_WUSER_WIDTH - 1:0] m_axi_state1_WUSER;
logic m_axi_state1_ARVALID;
logic m_axi_state1_ARREADY;
logic [C_M_AXI_STATE1_ADDR_WIDTH - 1:0] m_axi_state1_ARADDR;
logic [C_M_AXI_STATE1_ID_WIDTH - 1:0] m_axi_state1_ARID;
logic [7:0] m_axi_state1_ARLEN;
logic [2:0] m_axi_state1_ARSIZE;
logic [1:0] m_axi_state1_ARBURST;
logic [1:0] m_axi_state1_ARLOCK;
logic [3:0] m_axi_state1_ARCACHE;
logic [2:0] m_axi_state1_ARPROT;
logic [3:0] m_axi_state1_ARQOS;
logic [3:0] m_axi_state1_ARREGION;
logic [C_M_AXI_STATE1_ARUSER_WIDTH - 1:0] m_axi_state1_ARUSER;
logic m_axi_state1_RVALID;
logic m_axi_state1_RREADY;
logic [C_M_AXI_STATE1_DATA_WIDTH - 1:0] m_axi_state1_RDATA;
logic m_axi_state1_RLAST;
logic [C_M_AXI_STATE1_ID_WIDTH - 1:0] m_axi_state1_RID;
logic [C_M_AXI_STATE1_RUSER_WIDTH - 1:0] m_axi_state1_RUSER;
logic [1:0] m_axi_state1_RRESP;
logic m_axi_state1_BVALID;
logic m_axi_state1_BREADY;
logic [1:0] m_axi_state1_BRESP;
logic [C_M_AXI_STATE1_ID_WIDTH - 1:0] m_axi_state1_BID;
logic [C_M_AXI_STATE1_BUSER_WIDTH - 1:0] m_axi_state1_BUSER;
logic m_axi_observed_AWVALID;
logic m_axi_observed_AWREADY;
logic [C_M_AXI_OBSERVED_ADDR_WIDTH - 1:0] m_axi_observed_AWADDR;
logic [C_M_AXI_OBSERVED_ID_WIDTH - 1:0] m_axi_observed_AWID;
logic [7:0] m_axi_observed_AWLEN;
logic [2:0] m_axi_observed_AWSIZE;
logic [1:0] m_axi_observed_AWBURST;
logic [1:0] m_axi_observed_AWLOCK;
logic [3:0] m_axi_observed_AWCACHE;
logic [2:0] m_axi_observed_AWPROT;
logic [3:0] m_axi_observed_AWQOS;
logic [3:0] m_axi_observed_AWREGION;
logic [C_M_AXI_OBSERVED_AWUSER_WIDTH - 1:0] m_axi_observed_AWUSER;
logic m_axi_observed_WVALID;
logic m_axi_observed_WREADY;
logic [C_M_AXI_OBSERVED_DATA_WIDTH - 1:0] m_axi_observed_WDATA;
logic [C_M_AXI_OBSERVED_WSTRB_WIDTH - 1:0] m_axi_observed_WSTRB;
logic m_axi_observed_WLAST;
logic [C_M_AXI_OBSERVED_ID_WIDTH - 1:0] m_axi_observed_WID;
logic [C_M_AXI_OBSERVED_WUSER_WIDTH - 1:0] m_axi_observed_WUSER;
logic m_axi_observed_ARVALID;
logic m_axi_observed_ARREADY;
logic [C_M_AXI_OBSERVED_ADDR_WIDTH - 1:0] m_axi_observed_ARADDR;
logic [C_M_AXI_OBSERVED_ID_WIDTH - 1:0] m_axi_observed_ARID;
logic [7:0] m_axi_observed_ARLEN;
logic [2:0] m_axi_observed_ARSIZE;
logic [1:0] m_axi_observed_ARBURST;
logic [1:0] m_axi_observed_ARLOCK;
logic [3:0] m_axi_observed_ARCACHE;
logic [2:0] m_axi_observed_ARPROT;
logic [3:0] m_axi_observed_ARQOS;
logic [3:0] m_axi_observed_ARREGION;
logic [C_M_AXI_OBSERVED_ARUSER_WIDTH - 1:0] m_axi_observed_ARUSER;
logic m_axi_observed_RVALID;
logic m_axi_observed_RREADY;
logic [C_M_AXI_OBSERVED_DATA_WIDTH - 1:0] m_axi_observed_RDATA;
logic m_axi_observed_RLAST;
logic [C_M_AXI_OBSERVED_ID_WIDTH - 1:0] m_axi_observed_RID;
logic [C_M_AXI_OBSERVED_RUSER_WIDTH - 1:0] m_axi_observed_RUSER;
logic [1:0] m_axi_observed_RRESP;
logic m_axi_observed_BVALID;
logic m_axi_observed_BREADY;
logic [1:0] m_axi_observed_BRESP;
logic [C_M_AXI_OBSERVED_ID_WIDTH - 1:0] m_axi_observed_BID;
logic [C_M_AXI_OBSERVED_BUSER_WIDTH - 1:0] m_axi_observed_BUSER;
logic s_axi_control_AWVALID;
logic s_axi_control_AWREADY;
logic [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_AWADDR;
logic s_axi_control_WVALID;
logic s_axi_control_WREADY;
logic [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_WDATA;
logic [C_S_AXI_CONTROL_WSTRB_WIDTH - 1:0] s_axi_control_WSTRB;
logic s_axi_control_ARVALID;
logic s_axi_control_ARREADY;
logic [C_S_AXI_CONTROL_ADDR_WIDTH - 1:0] s_axi_control_ARADDR;
logic s_axi_control_RVALID;
logic s_axi_control_RREADY;
logic [C_S_AXI_CONTROL_DATA_WIDTH - 1:0] s_axi_control_RDATA;
logic [1:0] s_axi_control_RRESP;
logic s_axi_control_BVALID;
logic s_axi_control_BREADY;
logic [1:0] s_axi_control_BRESP;
logic interrupt;
logic s_axi_control_r_AWVALID;
logic s_axi_control_r_AWREADY;
logic [C_S_AXI_CONTROL_R_ADDR_WIDTH - 1:0] s_axi_control_r_AWADDR;
logic s_axi_control_r_WVALID;
logic s_axi_control_r_WREADY;
logic [C_S_AXI_CONTROL_R_DATA_WIDTH - 1:0] s_axi_control_r_WDATA;
logic [C_S_AXI_CONTROL_R_WSTRB_WIDTH - 1:0] s_axi_control_r_WSTRB;
logic s_axi_control_r_ARVALID;
logic s_axi_control_r_ARREADY;
logic [C_S_AXI_CONTROL_R_ADDR_WIDTH - 1:0] s_axi_control_r_ARADDR;
logic s_axi_control_r_RVALID;
logic s_axi_control_r_RREADY;
logic [C_S_AXI_CONTROL_R_DATA_WIDTH - 1:0] s_axi_control_r_RDATA;
logic [1:0] s_axi_control_r_RRESP;
logic s_axi_control_r_BVALID;
logic s_axi_control_r_BREADY;
logic [1:0] s_axi_control_r_BRESP;
wire ap_done = dut.ap_done;
logic launch = 0, aw_sent = 0, w_sent = 0;
logic [4:0] debt_zero, r_hold_hit, b_hold_hit;
wire [4:0] adapter_zero;
logic [4:0] first_done_debt, first_done_adapter;
logic first_done_r_hold, first_done_b_hold;
logic first_done_numeric_ok;
logic first_done_capture_ok, first_done_snapshot_ok;
integer first_done_snapshot_fd;
integer cycles = 0;
integer ln_rows_done = 0, ln_local_writes = 0;
integer ln_mean_steps = 0, ln_mean_levels = 0;
integer ln_variance_steps = 0, ln_variance_levels = 0;
logic ln_row_active = 0;
wire ln_row_start = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_CS_fsm_state1 &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_start;
wire ln_row_done = ln_row_active && dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_ready &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_done;
wire ln_local_write = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.output_r_we0;
wire [3:0] ln_row_index = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.trunc_ln162_reg_243;
wire [10:0] ln_mean_width = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.width_fu_120;
wire [9:0] ln_mean_i = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.i_1_reg_286;
wire [10:0] ln_variance_width = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.width_2_fu_128;
wire [9:0] ln_variance_i = dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.i_3_reg_298;
wire ln_mean_step = ln_row_active && dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_CS_fsm_state58 &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.icmp_ln8_2_fu_700_p2 === 1'b0;
wire ln_mean_level = ln_row_active && dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_CS_fsm_state52 &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.icmp_ln75_fu_630_p2 === 1'b0;
wire ln_variance_step = ln_row_active && dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_CS_fsm_state84 &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.icmp_ln8_8_fu_956_p2 === 1'b0;
wire ln_variance_level = ln_row_active && dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.ap_CS_fsm_state78 &&
  dut.grp_full_execute_cpu_frontend_fu_400.grp_p_anonymous_namespace_frontend_from_hidden_fu_1064.grp_p_anonymous_namespace_norm_fu_742.grp_p_anonymous_namespace_issue_LayerNormTask_s_fu_913.grp_full_run_task_5_fu_334.grp_full_run_task_5_Outline_VITIS_LOOP_162_1_fu_1104.grp_layernorm_row_arithmetic_fu_101.icmp_ln91_fu_886_p2 === 1'b0;
initial ap_clk = 0; always #3.333 ap_clk = ~ap_clk;
initial begin
  ap_rst_n = 0;
  if (!thin_mem_init()) $fatal(1, "memory setup");
  repeat (20) @(negedge ap_clk);
  ap_rst_n = 1;
  repeat (5) @(negedge ap_clk);
  launch = 1;
end
assign s_axi_control_AWVALID = launch && !aw_sent;
assign s_axi_control_AWADDR = 0;
assign s_axi_control_WVALID = launch && !w_sent;
assign s_axi_control_WDATA = 32'h1;
assign s_axi_control_WSTRB = 4'hf;
assign s_axi_control_BREADY = 1;
assign s_axi_control_ARVALID = 0;
assign s_axi_control_ARADDR = 0;
assign s_axi_control_RREADY = 1;
always @(posedge ap_clk) if (ap_rst_n) begin
  if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent <= 1;
  if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent <= 1;
  if ((m_axi_io_AWVALID || m_axi_io_WVALID ||
       m_axi_aux_AWVALID || m_axi_aux_WVALID ||
       m_axi_state0_AWVALID || m_axi_state0_WVALID) !== 1'b0)
    $fatal(1, "read-only production port wrote");
  if (m_axi_observed_ARVALID !== 1'b0)
    $fatal(1, "observed port read");
  cycles <= cycles + 1;
  if (ln_row_start) ln_row_active <= 1;
  if (ln_row_done) begin
    ln_rows_done <= ln_rows_done + 1;
    ln_row_active <= 0;
  end
  if (ln_row_active && ln_local_write) ln_local_writes <= ln_local_writes + 1;
  if (ln_mean_step) ln_mean_steps <= ln_mean_steps + 1;
  if (ln_mean_level) ln_mean_levels <= ln_mean_levels + 1;
  if (ln_variance_step) ln_variance_steps <= ln_variance_steps + 1;
  if (ln_variance_level) ln_variance_levels <= ln_variance_levels + 1;
  if (cycles != 0 && cycles % 8192 == 0)
    $display("CPU_FRONT_PROGRESS cycles=%0d raw=%0d norm=%0d observed=%0d import_words=%0d ln_words=%0d gamma_words=%0d accepted=%0d ln_rows=%0d ln_local=%0d ln_mean_steps=%0d ln_mean_levels=%0d ln_variance_steps=%0d ln_variance_levels=%0d ln_row=%0d ln_mean_width=%0d ln_mean_i=%0d ln_variance_width=%0d ln_variance_i=%0d",
      cycles, thin_mem_raw_bytes(), thin_mem_norm_bytes(),
      thin_mem_obs_bytes(), thin_mem_state0_import_words(),
      thin_mem_state0_ln_read_words(), thin_mem_gamma_read_words(),
      thin_mem_progress(), ln_rows_done, ln_local_writes,
      ln_mean_steps, ln_mean_levels, ln_variance_steps,
      ln_variance_levels, ln_row_index, ln_mean_width, ln_mean_i,
      ln_variance_width, ln_variance_i);
  if (thin_mem_errors()) $fatal(1, "AXI memory error");
  if (ap_done) begin
    first_done_debt = debt_zero;
    first_done_adapter = adapter_zero;
    first_done_r_hold = r_hold_hit[2];
    first_done_b_hold = b_hold_hit[3];
    $display("CPU_FRONT_FIRST_DONE debt=%b adapter=%b observed_BVALID=%b observed_BREADY=%b observed_response_count=%0d observed_bytes=%0d",
      first_done_debt, first_done_adapter,
      dut.observed_0_BVALID, dut.observed_0_BREADY,
      dut.observed_m_axi_U.store_unit_0.user_resp.if_num_data_valid,
      thin_mem_obs_bytes());
    first_done_capture_ok = thin_mem_capture_first_done();
    first_done_numeric_ok = thin_mem_check();
    first_done_snapshot_fd = $fopen("first_done_snapshot.txt", "w");
    first_done_snapshot_ok = first_done_snapshot_fd != 0;
    if (first_done_snapshot_ok) begin
      $fdisplay(first_done_snapshot_fd, "cycles=%0d debt=%b adapter=%b observed_BVALID=%b observed_BREADY=%b observed_response_count=%0d norm_bytes=%0d observed_bytes=%0d import_words=%0d ln_read_words=%0d gamma_read_words=%0d r_hold=%b b_hold=%b numeric_ok=%b capture_ok=%b",
        cycles, first_done_debt, first_done_adapter,
        dut.observed_0_BVALID, dut.observed_0_BREADY,
        dut.observed_m_axi_U.store_unit_0.user_resp.if_num_data_valid,
        thin_mem_norm_bytes(), thin_mem_obs_bytes(),
        thin_mem_state0_import_words(), thin_mem_state0_ln_read_words(),
        thin_mem_gamma_read_words(), first_done_r_hold, first_done_b_hold,
        first_done_numeric_ok, first_done_capture_ok);
      $fclose(first_done_snapshot_fd);
    end
    if (first_done_debt !== 5'b11111) $fatal(1, "debt at first ap_done: %b", first_done_debt);
    if (first_done_adapter !== 5'b11111) $fatal(1, "adapter debt at first ap_done: %b", first_done_adapter);
    if (!first_done_r_hold || !first_done_b_hold) $fatal(1, "required holds not exercised");
    if (!first_done_numeric_ok) $fatal(1, "front chain comparison");
    if (!first_done_capture_ok || !first_done_snapshot_ok) $fatal(1, "first-done capture");
    $display("CPU_FRONT_RTL_PASS cycles=%0d", cycles);
    $finish;
  end
  if (cycles >= 40000000) $fatal(1, "40M cycle cap");
end
assign s_axi_control_r_AWVALID = 0;
assign s_axi_control_r_AWADDR = 0;
assign s_axi_control_r_WVALID = 0;
assign s_axi_control_r_WDATA = 0;
assign s_axi_control_r_WSTRB = 0;
assign s_axi_control_r_BREADY = 1;
assign s_axi_control_r_ARVALID = 0;
assign s_axi_control_r_ARADDR = 0;
assign s_axi_control_r_RREADY = 1;
laya_cpu_embedding_ln_chain dut(
  .ap_clk(ap_clk),
  .ap_rst_n(ap_rst_n),
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
assign adapter_zero[0] = (dut.io_m_axi_U.load_unit_0.rreq_valid === '0) && (dut.io_m_axi_U.load_unit_0.local_AXI_RVALID === '0) && (dut.io_m_axi_U.load_unit_0.out_HLS_RVALID === '0) && (dut.io_m_axi_U.bus_read.ost_ctrl_empty_n === '0) && (dut.io_m_axi_U.bus_read.ost_burst_empty_n === '0) && (dut.io_m_axi_U.bus_read.beat_valid === '0) && (dut.io_m_axi_U.store_unit_0.wreq_valid === '0) && (dut.io_m_axi_U.store_unit_0.wrsp_valid === '0) && (dut.io_m_axi_U.store_unit_0.out_AXI_WVALID === '0) && (dut.io_m_axi_U.bus_write.ost_resp_valid === '0) && (dut.io_m_axi_U.bus_write.resp_valid === '0) && (dut.io_m_axi_U.bus_write.out_BUS_AWVALID === '0) && (dut.io_m_axi_U.bus_write.out_BUS_WVALID === '0) && (dut.io_m_axi_U.store_unit_0.out_HLS_BVALID === '0);
assign adapter_zero[1] = (dut.aux_m_axi_U.load_unit_0.rreq_valid === '0) && (dut.aux_m_axi_U.load_unit_0.local_AXI_RVALID === '0) && (dut.aux_m_axi_U.load_unit_0.out_HLS_RVALID === '0) && (dut.aux_m_axi_U.bus_read.ost_ctrl_empty_n === '0) && (dut.aux_m_axi_U.bus_read.ost_burst_empty_n === '0) && (dut.aux_m_axi_U.bus_read.beat_valid === '0);
assign adapter_zero[2] = (dut.state0_m_axi_U.load_unit_0.rreq_valid === '0) && (dut.state0_m_axi_U.load_unit_0.local_AXI_RVALID === '0) && (dut.state0_m_axi_U.load_unit_0.out_HLS_RVALID === '0) && (dut.state0_m_axi_U.bus_read.ost_ctrl_empty_n === '0) && (dut.state0_m_axi_U.bus_read.ost_burst_empty_n === '0) && (dut.state0_m_axi_U.bus_read.beat_valid === '0) && (dut.state0_m_axi_U.store_unit_0.wreq_valid === '0) && (dut.state0_m_axi_U.store_unit_0.wrsp_valid === '0) && (dut.state0_m_axi_U.store_unit_0.out_AXI_WVALID === '0) && (dut.state0_m_axi_U.bus_write.ost_resp_valid === '0) && (dut.state0_m_axi_U.bus_write.resp_valid === '0) && (dut.state0_m_axi_U.bus_write.out_BUS_AWVALID === '0) && (dut.state0_m_axi_U.bus_write.out_BUS_WVALID === '0) && (dut.state0_m_axi_U.store_unit_0.out_HLS_BVALID === '0);
assign adapter_zero[3] = (dut.state1_m_axi_U.load_unit_0.rreq_valid === '0) && (dut.state1_m_axi_U.load_unit_0.local_AXI_RVALID === '0) && (dut.state1_m_axi_U.load_unit_0.out_HLS_RVALID === '0) && (dut.state1_m_axi_U.bus_read.ost_ctrl_empty_n === '0) && (dut.state1_m_axi_U.bus_read.ost_burst_empty_n === '0) && (dut.state1_m_axi_U.bus_read.beat_valid === '0) && (dut.state1_m_axi_U.store_unit_0.wreq_valid === '0) && (dut.state1_m_axi_U.store_unit_0.wrsp_valid === '0) && (dut.state1_m_axi_U.store_unit_0.out_AXI_WVALID === '0) && (dut.state1_m_axi_U.bus_write.ost_resp_valid === '0) && (dut.state1_m_axi_U.bus_write.resp_valid === '0) && (dut.state1_m_axi_U.bus_write.out_BUS_AWVALID === '0) && (dut.state1_m_axi_U.bus_write.out_BUS_WVALID === '0) && (dut.state1_m_axi_U.store_unit_0.out_HLS_BVALID === '0);
assign adapter_zero[4] = (dut.observed_m_axi_U.store_unit_0.wreq_valid === '0) && (dut.observed_m_axi_U.store_unit_0.wrsp_valid === '0) && (dut.observed_m_axi_U.store_unit_0.out_AXI_WVALID === '0) && (dut.observed_m_axi_U.bus_write.ost_resp_valid === '0) && (dut.observed_m_axi_U.bus_write.resp_valid === '0) && (dut.observed_m_axi_U.bus_write.out_BUS_AWVALID === '0) && (dut.observed_m_axi_U.bus_write.out_BUS_WVALID === '0) && (dut.observed_0_BVALID === 1'b1) && (dut.observed_0_BREADY === 1'b1) && (dut.observed_m_axi_U.store_unit_0.user_resp.if_num_data_valid === 1);
thin_axi_memory #(.PORT_INDEX(0)) mem_io(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_io_AWVALID),
  .AWREADY(m_axi_io_AWREADY),
  .AWADDR(m_axi_io_AWADDR),
  .AWID(m_axi_io_AWID),
  .AWLEN(m_axi_io_AWLEN),
  .AWSIZE(m_axi_io_AWSIZE),
  .AWBURST(m_axi_io_AWBURST),
  .WVALID(m_axi_io_WVALID),
  .WREADY(m_axi_io_WREADY),
  .WDATA(m_axi_io_WDATA),
  .WSTRB(m_axi_io_WSTRB),
  .WLAST(m_axi_io_WLAST),
  .ARVALID(m_axi_io_ARVALID),
  .ARREADY(m_axi_io_ARREADY),
  .ARADDR(m_axi_io_ARADDR),
  .ARID(m_axi_io_ARID),
  .ARLEN(m_axi_io_ARLEN),
  .ARSIZE(m_axi_io_ARSIZE),
  .ARBURST(m_axi_io_ARBURST),
  .RVALID(m_axi_io_RVALID),
  .RREADY(m_axi_io_RREADY),
  .RDATA(m_axi_io_RDATA),
  .RLAST(m_axi_io_RLAST),
  .RID(m_axi_io_RID),
  .RRESP(m_axi_io_RRESP),
  .BVALID(m_axi_io_BVALID),
  .BREADY(m_axi_io_BREADY),
  .BRESP(m_axi_io_BRESP),
  .BID(m_axi_io_BID),
  .debt_zero(debt_zero[0]),
  .r_hold_hit(r_hold_hit[0]),
  .b_hold_hit(b_hold_hit[0])
);
assign m_axi_io_RUSER = '0;
assign m_axi_io_BUSER = '0;
thin_axi_memory #(.PORT_INDEX(1)) mem_aux(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_aux_AWVALID),
  .AWREADY(m_axi_aux_AWREADY),
  .AWADDR(m_axi_aux_AWADDR),
  .AWID(m_axi_aux_AWID),
  .AWLEN(m_axi_aux_AWLEN),
  .AWSIZE(m_axi_aux_AWSIZE),
  .AWBURST(m_axi_aux_AWBURST),
  .WVALID(m_axi_aux_WVALID),
  .WREADY(m_axi_aux_WREADY),
  .WDATA(m_axi_aux_WDATA),
  .WSTRB(m_axi_aux_WSTRB),
  .WLAST(m_axi_aux_WLAST),
  .ARVALID(m_axi_aux_ARVALID),
  .ARREADY(m_axi_aux_ARREADY),
  .ARADDR(m_axi_aux_ARADDR),
  .ARID(m_axi_aux_ARID),
  .ARLEN(m_axi_aux_ARLEN),
  .ARSIZE(m_axi_aux_ARSIZE),
  .ARBURST(m_axi_aux_ARBURST),
  .RVALID(m_axi_aux_RVALID),
  .RREADY(m_axi_aux_RREADY),
  .RDATA(m_axi_aux_RDATA),
  .RLAST(m_axi_aux_RLAST),
  .RID(m_axi_aux_RID),
  .RRESP(m_axi_aux_RRESP),
  .BVALID(m_axi_aux_BVALID),
  .BREADY(m_axi_aux_BREADY),
  .BRESP(m_axi_aux_BRESP),
  .BID(m_axi_aux_BID),
  .debt_zero(debt_zero[1]),
  .r_hold_hit(r_hold_hit[1]),
  .b_hold_hit(b_hold_hit[1])
);
assign m_axi_aux_RUSER = '0;
assign m_axi_aux_BUSER = '0;
thin_axi_memory #(.PORT_INDEX(2)) mem_state0(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_state0_AWVALID),
  .AWREADY(m_axi_state0_AWREADY),
  .AWADDR(m_axi_state0_AWADDR),
  .AWID(m_axi_state0_AWID),
  .AWLEN(m_axi_state0_AWLEN),
  .AWSIZE(m_axi_state0_AWSIZE),
  .AWBURST(m_axi_state0_AWBURST),
  .WVALID(m_axi_state0_WVALID),
  .WREADY(m_axi_state0_WREADY),
  .WDATA(m_axi_state0_WDATA),
  .WSTRB(m_axi_state0_WSTRB),
  .WLAST(m_axi_state0_WLAST),
  .ARVALID(m_axi_state0_ARVALID),
  .ARREADY(m_axi_state0_ARREADY),
  .ARADDR(m_axi_state0_ARADDR),
  .ARID(m_axi_state0_ARID),
  .ARLEN(m_axi_state0_ARLEN),
  .ARSIZE(m_axi_state0_ARSIZE),
  .ARBURST(m_axi_state0_ARBURST),
  .RVALID(m_axi_state0_RVALID),
  .RREADY(m_axi_state0_RREADY),
  .RDATA(m_axi_state0_RDATA),
  .RLAST(m_axi_state0_RLAST),
  .RID(m_axi_state0_RID),
  .RRESP(m_axi_state0_RRESP),
  .BVALID(m_axi_state0_BVALID),
  .BREADY(m_axi_state0_BREADY),
  .BRESP(m_axi_state0_BRESP),
  .BID(m_axi_state0_BID),
  .debt_zero(debt_zero[2]),
  .r_hold_hit(r_hold_hit[2]),
  .b_hold_hit(b_hold_hit[2])
);
assign m_axi_state0_RUSER = '0;
assign m_axi_state0_BUSER = '0;
thin_axi_memory #(.PORT_INDEX(3)) mem_state1(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_state1_AWVALID),
  .AWREADY(m_axi_state1_AWREADY),
  .AWADDR(m_axi_state1_AWADDR),
  .AWID(m_axi_state1_AWID),
  .AWLEN(m_axi_state1_AWLEN),
  .AWSIZE(m_axi_state1_AWSIZE),
  .AWBURST(m_axi_state1_AWBURST),
  .WVALID(m_axi_state1_WVALID),
  .WREADY(m_axi_state1_WREADY),
  .WDATA(m_axi_state1_WDATA),
  .WSTRB(m_axi_state1_WSTRB),
  .WLAST(m_axi_state1_WLAST),
  .ARVALID(m_axi_state1_ARVALID),
  .ARREADY(m_axi_state1_ARREADY),
  .ARADDR(m_axi_state1_ARADDR),
  .ARID(m_axi_state1_ARID),
  .ARLEN(m_axi_state1_ARLEN),
  .ARSIZE(m_axi_state1_ARSIZE),
  .ARBURST(m_axi_state1_ARBURST),
  .RVALID(m_axi_state1_RVALID),
  .RREADY(m_axi_state1_RREADY),
  .RDATA(m_axi_state1_RDATA),
  .RLAST(m_axi_state1_RLAST),
  .RID(m_axi_state1_RID),
  .RRESP(m_axi_state1_RRESP),
  .BVALID(m_axi_state1_BVALID),
  .BREADY(m_axi_state1_BREADY),
  .BRESP(m_axi_state1_BRESP),
  .BID(m_axi_state1_BID),
  .debt_zero(debt_zero[3]),
  .r_hold_hit(r_hold_hit[3]),
  .b_hold_hit(b_hold_hit[3])
);
assign m_axi_state1_RUSER = '0;
assign m_axi_state1_BUSER = '0;
thin_axi_memory #(.PORT_INDEX(4)) mem_observed(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_observed_AWVALID),
  .AWREADY(m_axi_observed_AWREADY),
  .AWADDR(m_axi_observed_AWADDR),
  .AWID(m_axi_observed_AWID),
  .AWLEN(m_axi_observed_AWLEN),
  .AWSIZE(m_axi_observed_AWSIZE),
  .AWBURST(m_axi_observed_AWBURST),
  .WVALID(m_axi_observed_WVALID),
  .WREADY(m_axi_observed_WREADY),
  .WDATA(m_axi_observed_WDATA),
  .WSTRB(m_axi_observed_WSTRB),
  .WLAST(m_axi_observed_WLAST),
  .ARVALID(m_axi_observed_ARVALID),
  .ARREADY(m_axi_observed_ARREADY),
  .ARADDR(m_axi_observed_ARADDR),
  .ARID(m_axi_observed_ARID),
  .ARLEN(m_axi_observed_ARLEN),
  .ARSIZE(m_axi_observed_ARSIZE),
  .ARBURST(m_axi_observed_ARBURST),
  .RVALID(m_axi_observed_RVALID),
  .RREADY(m_axi_observed_RREADY),
  .RDATA(m_axi_observed_RDATA),
  .RLAST(m_axi_observed_RLAST),
  .RID(m_axi_observed_RID),
  .RRESP(m_axi_observed_RRESP),
  .BVALID(m_axi_observed_BVALID),
  .BREADY(m_axi_observed_BREADY),
  .BRESP(m_axi_observed_BRESP),
  .BID(m_axi_observed_BID),
  .debt_zero(debt_zero[4]),
  .r_hold_hit(r_hold_hit[4]),
  .b_hold_hit(b_hold_hit[4])
);
assign m_axi_observed_RUSER = '0;
assign m_axi_observed_BUSER = '0;
endmodule
module thin_axi_memory #(parameter integer PORT_INDEX = 0)(
  input logic clk, rst_n,
  input logic AWVALID, output logic AWREADY, input logic [63:0] AWADDR,
  input logic AWID, input logic [7:0] AWLEN, input logic [2:0] AWSIZE,
  input logic [1:0] AWBURST,
  input logic WVALID, output logic WREADY, input logic [31:0] WDATA,
  input logic [3:0] WSTRB, input logic WLAST,
  input logic ARVALID, output logic ARREADY, input logic [63:0] ARADDR,
  input logic ARID, input logic [7:0] ARLEN, input logic [2:0] ARSIZE,
  input logic [1:0] ARBURST,
  output logic RVALID, input logic RREADY, output logic [31:0] RDATA,
  output logic RLAST, output logic RID, output logic [1:0] RRESP,
  output logic BVALID, input logic BREADY, output logic [1:0] BRESP,
  output logic BID, output logic debt_zero,
  output logic r_hold_hit, output logic b_hold_hit
);
import "DPI-C" function int thin_mem_read(input int port,
                                           input longint unsigned address);
import "DPI-C" function void thin_mem_read_accept(input int port,
                                                  input longint unsigned address);
import "DPI-C" function void thin_mem_write(input int port,
    input longint unsigned address, input int word, input byte unsigned strobe);
import "DPI-C" function int thin_mem_raw_bytes();
import "DPI-C" function int thin_mem_gamma_read_words();
logic rd_active = 0, wr_active = 0, b_valid = 0;
logic [63:0] rd_address = 0, wr_address = 0;
logic [8:0] rd_remaining = 0, wr_remaining = 0;
logic [2:0] rd_size = 0, wr_size = 0;
logic rd_id = 0, wr_id = 0;
logic last_state1_write = 0;
logic r_hold_done = 0, b_hold_done = 0;
logic [2:0] r_hold_count = 0, b_hold_count = 0;
logic [9:0] r_debt = 0, w_debt = 0;
assign ARREADY = !rd_active;
assign RVALID = rd_active &&
    !(PORT_INDEX == 2 && rd_address == 524284 &&
      thin_mem_gamma_read_words() == 1024 && !r_hold_done) &&
    (r_hold_count == 0);
assign RLAST = rd_active && rd_remaining == 1;
assign RID = rd_id;
assign RRESP = 0;
assign RDATA = rd_active ? thin_mem_read(PORT_INDEX, rd_address) : 0;
assign AWREADY = !wr_active && !b_valid;
assign WREADY = wr_active;
assign BVALID = b_valid &&
    !(PORT_INDEX == 3 && last_state1_write && !b_hold_done) &&
    (b_hold_count == 0);
assign BID = wr_id;
assign BRESP = 0;
assign debt_zero = !rd_active && !wr_active && !b_valid &&
    r_debt == 0 && w_debt == 0;
always @(posedge clk) begin
  if (!rst_n) begin
    rd_active <= 0; wr_active <= 0; b_valid <= 0;
    rd_remaining <= 0; wr_remaining <= 0;
    r_debt <= 0; w_debt <= 0;
    r_hold_done <= 0; b_hold_done <= 0;
    r_hold_count <= 0; b_hold_count <= 0;
    r_hold_hit <= 0; b_hold_hit <= 0;
    last_state1_write <= 0;
  end else begin
    if (ARVALID && ARREADY) begin
      if (ARSIZE > 2 || (ARADDR & ((64'b1 << ARSIZE) - 1)) != 0 ||
          (ARBURST != 2'b01 && ARLEN != 0))
        $fatal(1, "AXI read address/size/burst invalid");
      if (PORT_INDEX == 2 && thin_mem_gamma_read_words() == 1024 &&
          thin_mem_raw_bytes() != 524288)
        $fatal(1, "LN AR before complete import scan");
      rd_active <= 1;
      rd_address <= ARADDR;
      rd_remaining <= {1'b0, ARLEN} + 1;
      rd_size <= ARSIZE;
      rd_id <= ARID;
      r_debt <= r_debt + {2'b0, ARLEN} + 1;
    end
    if (PORT_INDEX == 2 && rd_active && rd_address == 524284 &&
        thin_mem_gamma_read_words() == 1024 && !r_hold_done) begin
      r_hold_done <= 1;
      r_hold_hit <= 1;
      r_hold_count <= 4;
    end else if (r_hold_count != 0) r_hold_count <= r_hold_count - 1;
    if (RVALID && RREADY) begin
      if (PORT_INDEX == 2 && thin_mem_gamma_read_words() == 1024 &&
          thin_mem_raw_bytes() != 524288)
        $fatal(1, "LN R before complete import scan");
      thin_mem_read_accept(PORT_INDEX, rd_address);
      if (r_debt == 0) $fatal(1, "R without AR debt");
      r_debt <= r_debt - 1;
      if (rd_remaining == 1) rd_active <= 0;
      else begin
        rd_address <= rd_address + (64'b1 << rd_size);
        rd_remaining <= rd_remaining - 1;
      end
    end
    if (AWVALID && AWREADY) begin
      if (AWSIZE > 2 || (AWADDR & ((64'b1 << AWSIZE) - 1)) != 0 ||
          (AWBURST != 2'b01 && AWLEN != 0))
        $fatal(1, "AXI write address/size/burst invalid");
      wr_active <= 1;
      wr_address <= AWADDR;
      wr_remaining <= {1'b0, AWLEN} + 1;
      wr_size <= AWSIZE;
      wr_id <= AWID;
      w_debt <= w_debt + {2'b0, AWLEN} + 1;
    end
    if (WVALID && WREADY) begin
      if (w_debt == 0 || WLAST != (wr_remaining == 1))
        $fatal(1, "W debt/LAST mismatch");
      thin_mem_write(PORT_INDEX, wr_address, WDATA, {4'b0, WSTRB});
      w_debt <= w_debt - 1;
      if (PORT_INDEX == 3 && wr_address == 524284)
        last_state1_write <= 1;
      if (wr_remaining == 1) begin wr_active <= 0; b_valid <= 1; end
      else begin
        wr_address <= wr_address + (64'b1 << wr_size);
        wr_remaining <= wr_remaining - 1;
      end
    end
    if (PORT_INDEX == 3 && b_valid && last_state1_write &&
        !b_hold_done) begin
      b_hold_done <= 1;
      b_hold_hit <= 1;
      b_hold_count <= 4;
    end else if (b_hold_count != 0) b_hold_count <= b_hold_count - 1;
    if (BVALID && BREADY) begin
      if (w_debt != 0) $fatal(1, "B before all W responses");
      b_valid <= 0;
      last_state1_write <= 0;
    end
  end
end
endmodule
