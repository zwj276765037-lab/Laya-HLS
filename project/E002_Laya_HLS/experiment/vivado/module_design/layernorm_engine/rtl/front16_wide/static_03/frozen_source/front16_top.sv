`timescale 1ns/1ps
module front16_top;
import "DPI-C" function int front16_mem_init();
import "DPI-C" function int front16_mem_progress();
import "DPI-C" function int front16_mem_import_bytes();
import "DPI-C" function int front16_mem_ln_bytes();
import "DPI-C" function int front16_mem_gamma_bytes();
import "DPI-C" function int front16_mem_norm_bytes();
import "DPI-C" function int front16_mem_obs_bytes();
import "DPI-C" function int front16_mem_errors();
import "DPI-C" function int front16_mem_capture();
import "DPI-C" function int front16_mem_check();
localparam    ap_ST_fsm_state1 = 2'd1;
localparam    ap_ST_fsm_state2 = 2'd2;
localparam    C_S_AXI_CONTROL_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_ADDR_WIDTH = 4;
localparam    C_S_AXI_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_ADDR_WIDTH = 6;
localparam    C_M_AXI_GMEM_AUX_ID_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_ADDR_WIDTH = 64;
localparam    C_M_AXI_GMEM_AUX_DATA_WIDTH = 512;
localparam    C_M_AXI_GMEM_AUX_AWUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_ARUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_WUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_RUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_BUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_AUX_USER_VALUE = 0;
localparam    C_M_AXI_GMEM_AUX_PROT_VALUE = 0;
localparam    C_M_AXI_GMEM_AUX_CACHE_VALUE = 3;
localparam    C_M_AXI_DATA_WIDTH = 32;
localparam    C_M_AXI_GMEM_OBSERVED_ID_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_ADDR_WIDTH = 64;
localparam    C_M_AXI_GMEM_OBSERVED_DATA_WIDTH = 32;
localparam    C_M_AXI_GMEM_OBSERVED_AWUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_ARUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_WUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_RUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_BUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_OBSERVED_USER_VALUE = 0;
localparam    C_M_AXI_GMEM_OBSERVED_PROT_VALUE = 0;
localparam    C_M_AXI_GMEM_OBSERVED_CACHE_VALUE = 3;
localparam    C_M_AXI_GMEM_STATE0_ID_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_ADDR_WIDTH = 64;
localparam    C_M_AXI_GMEM_STATE0_DATA_WIDTH = 512;
localparam    C_M_AXI_GMEM_STATE0_AWUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_ARUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_WUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_RUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_BUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE0_USER_VALUE = 0;
localparam    C_M_AXI_GMEM_STATE0_PROT_VALUE = 0;
localparam    C_M_AXI_GMEM_STATE0_CACHE_VALUE = 3;
localparam    C_M_AXI_GMEM_STATE1_ID_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_ADDR_WIDTH = 64;
localparam    C_M_AXI_GMEM_STATE1_DATA_WIDTH = 512;
localparam    C_M_AXI_GMEM_STATE1_AWUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_ARUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_WUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_RUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_BUSER_WIDTH = 1;
localparam    C_M_AXI_GMEM_STATE1_USER_VALUE = 0;
localparam    C_M_AXI_GMEM_STATE1_PROT_VALUE = 0;
localparam    C_M_AXI_GMEM_STATE1_CACHE_VALUE = 3;
localparam C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_CONTROL_R_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_GMEM_AUX_WSTRB_WIDTH = (512 / 8);
localparam C_M_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_GMEM_OBSERVED_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_GMEM_STATE0_WSTRB_WIDTH = (512 / 8);
localparam C_M_AXI_GMEM_STATE1_WSTRB_WIDTH = (512 / 8);
logic ap_clk;
logic ap_rst_n;
logic m_axi_gmem_state0_AWVALID;
logic m_axi_gmem_state0_AWREADY;
logic [C_M_AXI_GMEM_STATE0_ADDR_WIDTH - 1:0] m_axi_gmem_state0_AWADDR;
logic [C_M_AXI_GMEM_STATE0_ID_WIDTH - 1:0] m_axi_gmem_state0_AWID;
logic [7:0] m_axi_gmem_state0_AWLEN;
logic [2:0] m_axi_gmem_state0_AWSIZE;
logic [1:0] m_axi_gmem_state0_AWBURST;
logic [1:0] m_axi_gmem_state0_AWLOCK;
logic [3:0] m_axi_gmem_state0_AWCACHE;
logic [2:0] m_axi_gmem_state0_AWPROT;
logic [3:0] m_axi_gmem_state0_AWQOS;
logic [3:0] m_axi_gmem_state0_AWREGION;
logic [C_M_AXI_GMEM_STATE0_AWUSER_WIDTH - 1:0] m_axi_gmem_state0_AWUSER;
logic m_axi_gmem_state0_WVALID;
logic m_axi_gmem_state0_WREADY;
logic [C_M_AXI_GMEM_STATE0_DATA_WIDTH - 1:0] m_axi_gmem_state0_WDATA;
logic [C_M_AXI_GMEM_STATE0_WSTRB_WIDTH - 1:0] m_axi_gmem_state0_WSTRB;
logic m_axi_gmem_state0_WLAST;
logic [C_M_AXI_GMEM_STATE0_ID_WIDTH - 1:0] m_axi_gmem_state0_WID;
logic [C_M_AXI_GMEM_STATE0_WUSER_WIDTH - 1:0] m_axi_gmem_state0_WUSER;
logic m_axi_gmem_state0_ARVALID;
logic m_axi_gmem_state0_ARREADY;
logic [C_M_AXI_GMEM_STATE0_ADDR_WIDTH - 1:0] m_axi_gmem_state0_ARADDR;
logic [C_M_AXI_GMEM_STATE0_ID_WIDTH - 1:0] m_axi_gmem_state0_ARID;
logic [7:0] m_axi_gmem_state0_ARLEN;
logic [2:0] m_axi_gmem_state0_ARSIZE;
logic [1:0] m_axi_gmem_state0_ARBURST;
logic [1:0] m_axi_gmem_state0_ARLOCK;
logic [3:0] m_axi_gmem_state0_ARCACHE;
logic [2:0] m_axi_gmem_state0_ARPROT;
logic [3:0] m_axi_gmem_state0_ARQOS;
logic [3:0] m_axi_gmem_state0_ARREGION;
logic [C_M_AXI_GMEM_STATE0_ARUSER_WIDTH - 1:0] m_axi_gmem_state0_ARUSER;
logic m_axi_gmem_state0_RVALID;
logic m_axi_gmem_state0_RREADY;
logic [C_M_AXI_GMEM_STATE0_DATA_WIDTH - 1:0] m_axi_gmem_state0_RDATA;
logic m_axi_gmem_state0_RLAST;
logic [C_M_AXI_GMEM_STATE0_ID_WIDTH - 1:0] m_axi_gmem_state0_RID;
logic [C_M_AXI_GMEM_STATE0_RUSER_WIDTH - 1:0] m_axi_gmem_state0_RUSER;
logic [1:0] m_axi_gmem_state0_RRESP;
logic m_axi_gmem_state0_BVALID;
logic m_axi_gmem_state0_BREADY;
logic [1:0] m_axi_gmem_state0_BRESP;
logic [C_M_AXI_GMEM_STATE0_ID_WIDTH - 1:0] m_axi_gmem_state0_BID;
logic [C_M_AXI_GMEM_STATE0_BUSER_WIDTH - 1:0] m_axi_gmem_state0_BUSER;
logic m_axi_gmem_aux_AWVALID;
logic m_axi_gmem_aux_AWREADY;
logic [C_M_AXI_GMEM_AUX_ADDR_WIDTH - 1:0] m_axi_gmem_aux_AWADDR;
logic [C_M_AXI_GMEM_AUX_ID_WIDTH - 1:0] m_axi_gmem_aux_AWID;
logic [7:0] m_axi_gmem_aux_AWLEN;
logic [2:0] m_axi_gmem_aux_AWSIZE;
logic [1:0] m_axi_gmem_aux_AWBURST;
logic [1:0] m_axi_gmem_aux_AWLOCK;
logic [3:0] m_axi_gmem_aux_AWCACHE;
logic [2:0] m_axi_gmem_aux_AWPROT;
logic [3:0] m_axi_gmem_aux_AWQOS;
logic [3:0] m_axi_gmem_aux_AWREGION;
logic [C_M_AXI_GMEM_AUX_AWUSER_WIDTH - 1:0] m_axi_gmem_aux_AWUSER;
logic m_axi_gmem_aux_WVALID;
logic m_axi_gmem_aux_WREADY;
logic [C_M_AXI_GMEM_AUX_DATA_WIDTH - 1:0] m_axi_gmem_aux_WDATA;
logic [C_M_AXI_GMEM_AUX_WSTRB_WIDTH - 1:0] m_axi_gmem_aux_WSTRB;
logic m_axi_gmem_aux_WLAST;
logic [C_M_AXI_GMEM_AUX_ID_WIDTH - 1:0] m_axi_gmem_aux_WID;
logic [C_M_AXI_GMEM_AUX_WUSER_WIDTH - 1:0] m_axi_gmem_aux_WUSER;
logic m_axi_gmem_aux_ARVALID;
logic m_axi_gmem_aux_ARREADY;
logic [C_M_AXI_GMEM_AUX_ADDR_WIDTH - 1:0] m_axi_gmem_aux_ARADDR;
logic [C_M_AXI_GMEM_AUX_ID_WIDTH - 1:0] m_axi_gmem_aux_ARID;
logic [7:0] m_axi_gmem_aux_ARLEN;
logic [2:0] m_axi_gmem_aux_ARSIZE;
logic [1:0] m_axi_gmem_aux_ARBURST;
logic [1:0] m_axi_gmem_aux_ARLOCK;
logic [3:0] m_axi_gmem_aux_ARCACHE;
logic [2:0] m_axi_gmem_aux_ARPROT;
logic [3:0] m_axi_gmem_aux_ARQOS;
logic [3:0] m_axi_gmem_aux_ARREGION;
logic [C_M_AXI_GMEM_AUX_ARUSER_WIDTH - 1:0] m_axi_gmem_aux_ARUSER;
logic m_axi_gmem_aux_RVALID;
logic m_axi_gmem_aux_RREADY;
logic [C_M_AXI_GMEM_AUX_DATA_WIDTH - 1:0] m_axi_gmem_aux_RDATA;
logic m_axi_gmem_aux_RLAST;
logic [C_M_AXI_GMEM_AUX_ID_WIDTH - 1:0] m_axi_gmem_aux_RID;
logic [C_M_AXI_GMEM_AUX_RUSER_WIDTH - 1:0] m_axi_gmem_aux_RUSER;
logic [1:0] m_axi_gmem_aux_RRESP;
logic m_axi_gmem_aux_BVALID;
logic m_axi_gmem_aux_BREADY;
logic [1:0] m_axi_gmem_aux_BRESP;
logic [C_M_AXI_GMEM_AUX_ID_WIDTH - 1:0] m_axi_gmem_aux_BID;
logic [C_M_AXI_GMEM_AUX_BUSER_WIDTH - 1:0] m_axi_gmem_aux_BUSER;
logic m_axi_gmem_state1_AWVALID;
logic m_axi_gmem_state1_AWREADY;
logic [C_M_AXI_GMEM_STATE1_ADDR_WIDTH - 1:0] m_axi_gmem_state1_AWADDR;
logic [C_M_AXI_GMEM_STATE1_ID_WIDTH - 1:0] m_axi_gmem_state1_AWID;
logic [7:0] m_axi_gmem_state1_AWLEN;
logic [2:0] m_axi_gmem_state1_AWSIZE;
logic [1:0] m_axi_gmem_state1_AWBURST;
logic [1:0] m_axi_gmem_state1_AWLOCK;
logic [3:0] m_axi_gmem_state1_AWCACHE;
logic [2:0] m_axi_gmem_state1_AWPROT;
logic [3:0] m_axi_gmem_state1_AWQOS;
logic [3:0] m_axi_gmem_state1_AWREGION;
logic [C_M_AXI_GMEM_STATE1_AWUSER_WIDTH - 1:0] m_axi_gmem_state1_AWUSER;
logic m_axi_gmem_state1_WVALID;
logic m_axi_gmem_state1_WREADY;
logic [C_M_AXI_GMEM_STATE1_DATA_WIDTH - 1:0] m_axi_gmem_state1_WDATA;
logic [C_M_AXI_GMEM_STATE1_WSTRB_WIDTH - 1:0] m_axi_gmem_state1_WSTRB;
logic m_axi_gmem_state1_WLAST;
logic [C_M_AXI_GMEM_STATE1_ID_WIDTH - 1:0] m_axi_gmem_state1_WID;
logic [C_M_AXI_GMEM_STATE1_WUSER_WIDTH - 1:0] m_axi_gmem_state1_WUSER;
logic m_axi_gmem_state1_ARVALID;
logic m_axi_gmem_state1_ARREADY;
logic [C_M_AXI_GMEM_STATE1_ADDR_WIDTH - 1:0] m_axi_gmem_state1_ARADDR;
logic [C_M_AXI_GMEM_STATE1_ID_WIDTH - 1:0] m_axi_gmem_state1_ARID;
logic [7:0] m_axi_gmem_state1_ARLEN;
logic [2:0] m_axi_gmem_state1_ARSIZE;
logic [1:0] m_axi_gmem_state1_ARBURST;
logic [1:0] m_axi_gmem_state1_ARLOCK;
logic [3:0] m_axi_gmem_state1_ARCACHE;
logic [2:0] m_axi_gmem_state1_ARPROT;
logic [3:0] m_axi_gmem_state1_ARQOS;
logic [3:0] m_axi_gmem_state1_ARREGION;
logic [C_M_AXI_GMEM_STATE1_ARUSER_WIDTH - 1:0] m_axi_gmem_state1_ARUSER;
logic m_axi_gmem_state1_RVALID;
logic m_axi_gmem_state1_RREADY;
logic [C_M_AXI_GMEM_STATE1_DATA_WIDTH - 1:0] m_axi_gmem_state1_RDATA;
logic m_axi_gmem_state1_RLAST;
logic [C_M_AXI_GMEM_STATE1_ID_WIDTH - 1:0] m_axi_gmem_state1_RID;
logic [C_M_AXI_GMEM_STATE1_RUSER_WIDTH - 1:0] m_axi_gmem_state1_RUSER;
logic [1:0] m_axi_gmem_state1_RRESP;
logic m_axi_gmem_state1_BVALID;
logic m_axi_gmem_state1_BREADY;
logic [1:0] m_axi_gmem_state1_BRESP;
logic [C_M_AXI_GMEM_STATE1_ID_WIDTH - 1:0] m_axi_gmem_state1_BID;
logic [C_M_AXI_GMEM_STATE1_BUSER_WIDTH - 1:0] m_axi_gmem_state1_BUSER;
logic m_axi_gmem_observed_AWVALID;
logic m_axi_gmem_observed_AWREADY;
logic [C_M_AXI_GMEM_OBSERVED_ADDR_WIDTH - 1:0] m_axi_gmem_observed_AWADDR;
logic [C_M_AXI_GMEM_OBSERVED_ID_WIDTH - 1:0] m_axi_gmem_observed_AWID;
logic [7:0] m_axi_gmem_observed_AWLEN;
logic [2:0] m_axi_gmem_observed_AWSIZE;
logic [1:0] m_axi_gmem_observed_AWBURST;
logic [1:0] m_axi_gmem_observed_AWLOCK;
logic [3:0] m_axi_gmem_observed_AWCACHE;
logic [2:0] m_axi_gmem_observed_AWPROT;
logic [3:0] m_axi_gmem_observed_AWQOS;
logic [3:0] m_axi_gmem_observed_AWREGION;
logic [C_M_AXI_GMEM_OBSERVED_AWUSER_WIDTH - 1:0] m_axi_gmem_observed_AWUSER;
logic m_axi_gmem_observed_WVALID;
logic m_axi_gmem_observed_WREADY;
logic [C_M_AXI_GMEM_OBSERVED_DATA_WIDTH - 1:0] m_axi_gmem_observed_WDATA;
logic [C_M_AXI_GMEM_OBSERVED_WSTRB_WIDTH - 1:0] m_axi_gmem_observed_WSTRB;
logic m_axi_gmem_observed_WLAST;
logic [C_M_AXI_GMEM_OBSERVED_ID_WIDTH - 1:0] m_axi_gmem_observed_WID;
logic [C_M_AXI_GMEM_OBSERVED_WUSER_WIDTH - 1:0] m_axi_gmem_observed_WUSER;
logic m_axi_gmem_observed_ARVALID;
logic m_axi_gmem_observed_ARREADY;
logic [C_M_AXI_GMEM_OBSERVED_ADDR_WIDTH - 1:0] m_axi_gmem_observed_ARADDR;
logic [C_M_AXI_GMEM_OBSERVED_ID_WIDTH - 1:0] m_axi_gmem_observed_ARID;
logic [7:0] m_axi_gmem_observed_ARLEN;
logic [2:0] m_axi_gmem_observed_ARSIZE;
logic [1:0] m_axi_gmem_observed_ARBURST;
logic [1:0] m_axi_gmem_observed_ARLOCK;
logic [3:0] m_axi_gmem_observed_ARCACHE;
logic [2:0] m_axi_gmem_observed_ARPROT;
logic [3:0] m_axi_gmem_observed_ARQOS;
logic [3:0] m_axi_gmem_observed_ARREGION;
logic [C_M_AXI_GMEM_OBSERVED_ARUSER_WIDTH - 1:0] m_axi_gmem_observed_ARUSER;
logic m_axi_gmem_observed_RVALID;
logic m_axi_gmem_observed_RREADY;
logic [C_M_AXI_GMEM_OBSERVED_DATA_WIDTH - 1:0] m_axi_gmem_observed_RDATA;
logic m_axi_gmem_observed_RLAST;
logic [C_M_AXI_GMEM_OBSERVED_ID_WIDTH - 1:0] m_axi_gmem_observed_RID;
logic [C_M_AXI_GMEM_OBSERVED_RUSER_WIDTH - 1:0] m_axi_gmem_observed_RUSER;
logic [1:0] m_axi_gmem_observed_RRESP;
logic m_axi_gmem_observed_BVALID;
logic m_axi_gmem_observed_BREADY;
logic [1:0] m_axi_gmem_observed_BRESP;
logic [C_M_AXI_GMEM_OBSERVED_ID_WIDTH - 1:0] m_axi_gmem_observed_BID;
logic [C_M_AXI_GMEM_OBSERVED_BUSER_WIDTH - 1:0] m_axi_gmem_observed_BUSER;
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
wire arith_start = dut.grp_p_anonymous_namespace_run_wide_fu_96.grp_layernorm_row_arithmetic_fu_884.ap_start;
wire arith_done = dut.grp_p_anonymous_namespace_run_wide_fu_96.grp_layernorm_row_arithmetic_fu_884.ap_done;
logic pressure=0, launch=0, aw_sent=0, w_sent=0;
logic [3:0] debt_zero;
logic [31:0] ar_count[4],r_count[4],aw_count[4],w_count[4],b_count[4];
logic [31:0] r_hold_hits[4],b_hold_hits[4],r_hold_cycles[4],b_hold_cycles[4];
integer cycles=0;
integer arith_start_edges=0, arith_done_edges=0;
integer arith_first_cycle=-1, arith_last_cycle=-1;
logic arith_start_prev=0, arith_done_prev=0;
wire [3:0] user_ar_fire,user_r_fire,user_aw_fire,user_w_fire,user_b_fire;
wire [3:0] user_ar_valid,user_r_valid,user_aw_valid,user_w_valid,user_b_valid;
wire [31:0] user_ar_len[4],user_aw_len[4],user_rfifonum[4];
integer user_ar_elements[4],user_r_elements[4],user_read_peak[4];
integer user_aw_requests[4],user_aw_elements[4],user_w_elements[4],user_b_responses[4];
integer read_debt_next, aw_requests_next, b_responses_next;
initial ap_clk=0; always #3.333 ap_clk=~ap_clk;
initial begin
  pressure=$test$plusargs("PRESSURE");
  ap_rst_n=0;
  if (!front16_mem_init()) $fatal(1,"front16 memory setup");
  repeat (20) @(negedge ap_clk);
  ap_rst_n=1;
  repeat (5) @(negedge ap_clk);
  launch=1;
end
assign s_axi_control_AWVALID=launch && !aw_sent;
assign s_axi_control_AWADDR=0;
assign s_axi_control_WVALID=launch && !w_sent;
assign s_axi_control_WDATA=32'h1;
assign s_axi_control_WSTRB=4'hf;
assign s_axi_control_BREADY=1;
assign s_axi_control_ARVALID=0;
assign s_axi_control_ARADDR=0;
assign s_axi_control_RREADY=1;
always @(posedge ap_clk) if (ap_rst_n) begin
  if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent<=1;
  if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent<=1;
  cycles<=cycles+1;
  if (arith_start && !arith_start_prev) begin
    arith_start_edges<=arith_start_edges+1;
    if (arith_first_cycle<0) arith_first_cycle<=cycles;
  end
  if (arith_done && !arith_done_prev) begin
    arith_done_edges<=arith_done_edges+1;
    arith_last_cycle<=cycles;
  end
  arith_start_prev<=arith_start;
  arith_done_prev<=arith_done;
  if (cycles!=0 && cycles%8192==0)
    $display("FRONT16_PROGRESS cycles=%0d import=%0d gamma=%0d ln=%0d norm=%0d observed=%0d",
      cycles,front16_mem_import_bytes(),front16_mem_gamma_bytes(),
      front16_mem_ln_bytes(),front16_mem_norm_bytes(),front16_mem_obs_bytes());
  if (front16_mem_errors()) $fatal(1,"front16 memory error");
  if (ap_done) begin
    $display("FRONT16_ARITH starts=%0d dones=%0d first_cycle=%0d last_cycle=%0d",
      arith_start_edges,arith_done_edges,arith_first_cycle,arith_last_cycle);
    for (int p=0;p<4;p++) begin
      $display("FRONT16_PORT port=%0d AR=%0d R=%0d AW=%0d W=%0d B=%0d lane_read_bytes=%0d transfer_read_bytes=%0d lane_write_bytes=%0d strobed_write_bytes=%0d",
        p,ar_count[p],r_count[p],aw_count[p],w_count[p],b_count[p],
        r_count[p]*(p==3?4:(p==0||p==1||p==2)?64:4),
        p==0?mem_state0.read_transfer_bytes:p==1?mem_aux.read_transfer_bytes:p==2?mem_state1.read_transfer_bytes:mem_observed.read_transfer_bytes,
        w_count[p]*(p==3?4:64),
        p==0?mem_state0.write_transfer_bytes:p==1?mem_aux.write_transfer_bytes:p==2?mem_state1.write_transfer_bytes:mem_observed.write_transfer_bytes);
    end
    if (!front16_mem_capture()) $fatal(1,"front16 first-done capture");
    if (!front16_mem_check()) $fatal(1,"front16 first-done numerical/coverage");
    if (debt_zero!==4'b1111) $fatal(1,"front16 physical debt at first done %b",debt_zero);
    #1ps; // Same first-done clock edge, after counter NBA and adapter outputs settle.
    for (int p=0;p<4;p++) begin
      if (p<2) begin
        if (user_ar_elements[p]-user_r_elements[p]!=0 || user_rfifonum[p]!=0 ||
            user_ar_valid[p] || user_r_valid[p])
          $fatal(1,"front16 adapter read debt at first done port=%0d AR_elems=%0d R_elems=%0d RFIFONUM=%0d",
            p,user_ar_elements[p],user_r_elements[p],user_rfifonum[p]);
      end else begin
        if (user_aw_requests[p]-user_b_responses[p]!=0 ||
            user_aw_elements[p]-user_w_elements[p]!=0 ||
            user_aw_valid[p] || user_w_valid[p] || user_b_valid[p])
          $fatal(1,"front16 adapter write debt at first done port=%0d AW=%0d B=%0d AW_elems=%0d W=%0d",
            p,user_aw_requests[p],user_b_responses[p],user_aw_elements[p],user_w_elements[p]);
      end
      $display("FRONT16_ADAPTER port=%0d AR_elems=%0d R_elems=%0d read_peak_elements=%0d RFIFONUM=%0d AW=%0d B=%0d AW_elems=%0d W=%0d pending_AR=%0d pending_R=%0d pending_AW=%0d pending_W=%0d pending_B=%0d",
        p,user_ar_elements[p],user_r_elements[p],user_read_peak[p],user_rfifonum[p],
        user_aw_requests[p],user_b_responses[p],user_aw_elements[p],user_w_elements[p],
        user_ar_valid[p],user_r_valid[p],user_aw_valid[p],user_w_valid[p],user_b_valid[p]);
    end
    if (pressure && (r_hold_hits[0]!=1 || b_hold_hits[2]!=1))
      $fatal(1,"front16 required hold count R=%0d B=%0d",r_hold_hits[0],b_hold_hits[2]);
    if (!pressure && (r_hold_hits[0]!=0 || b_hold_hits[2]!=0))
      $fatal(1,"front16 unexpected hold");
    $display("FRONT16_RTL_PASS mode=%s pressure=%0d cycles=%0d r_hold_cycles=%0d b_hold_cycles=%0d",
      "wide",pressure,cycles,r_hold_cycles[0],b_hold_cycles[2]);
    $display("FRONT16_STALL port=state0 AR=%0d AW=%0d W=%0d R=%0d B=%0d max_read_outstanding=1 max_write_outstanding=1",
      mem_state0.ar_stall_cycles,mem_state0.aw_stall_cycles,mem_state0.w_stall_cycles,mem_state0.r_stall_cycles,mem_state0.b_stall_cycles);
    for (int l=0;l<64;l++) begin
      if (mem_state0.ar_len_hist[l]) $display("FRONT16_ARLEN port=state0 len=%0d count=%0d",l,mem_state0.ar_len_hist[l]);
      if (mem_state0.aw_len_hist[l]) $display("FRONT16_AWLEN port=state0 len=%0d count=%0d",l,mem_state0.aw_len_hist[l]);
    end
    $display("FRONT16_STALL port=aux AR=%0d AW=%0d W=%0d R=%0d B=%0d max_read_outstanding=1 max_write_outstanding=1",
      mem_aux.ar_stall_cycles,mem_aux.aw_stall_cycles,mem_aux.w_stall_cycles,mem_aux.r_stall_cycles,mem_aux.b_stall_cycles);
    for (int l=0;l<64;l++) begin
      if (mem_aux.ar_len_hist[l]) $display("FRONT16_ARLEN port=aux len=%0d count=%0d",l,mem_aux.ar_len_hist[l]);
      if (mem_aux.aw_len_hist[l]) $display("FRONT16_AWLEN port=aux len=%0d count=%0d",l,mem_aux.aw_len_hist[l]);
    end
    $display("FRONT16_STALL port=state1 AR=%0d AW=%0d W=%0d R=%0d B=%0d max_read_outstanding=1 max_write_outstanding=1",
      mem_state1.ar_stall_cycles,mem_state1.aw_stall_cycles,mem_state1.w_stall_cycles,mem_state1.r_stall_cycles,mem_state1.b_stall_cycles);
    for (int l=0;l<64;l++) begin
      if (mem_state1.ar_len_hist[l]) $display("FRONT16_ARLEN port=state1 len=%0d count=%0d",l,mem_state1.ar_len_hist[l]);
      if (mem_state1.aw_len_hist[l]) $display("FRONT16_AWLEN port=state1 len=%0d count=%0d",l,mem_state1.aw_len_hist[l]);
    end
    $display("FRONT16_STALL port=observed AR=%0d AW=%0d W=%0d R=%0d B=%0d max_read_outstanding=1 max_write_outstanding=1",
      mem_observed.ar_stall_cycles,mem_observed.aw_stall_cycles,mem_observed.w_stall_cycles,mem_observed.r_stall_cycles,mem_observed.b_stall_cycles);
    for (int l=0;l<64;l++) begin
      if (mem_observed.ar_len_hist[l]) $display("FRONT16_ARLEN port=observed len=%0d count=%0d",l,mem_observed.ar_len_hist[l]);
      if (mem_observed.aw_len_hist[l]) $display("FRONT16_AWLEN port=observed len=%0d count=%0d",l,mem_observed.aw_len_hist[l]);
    end
    $finish;
  end
  if (cycles>=40000000) $fatal(1,"front16 40M cycle cap");
end
assign s_axi_control_r_AWVALID=0;
assign s_axi_control_r_AWADDR=0;
assign s_axi_control_r_WVALID=0;
assign s_axi_control_r_WDATA=0;
assign s_axi_control_r_WSTRB=0;
assign s_axi_control_r_BREADY=1;
assign s_axi_control_r_ARVALID=0;
assign s_axi_control_r_ARADDR=0;
assign s_axi_control_r_RREADY=1;
assign m_axi_gmem_state0_RUSER=0;
assign m_axi_gmem_state0_BUSER=0;
assign m_axi_gmem_aux_RUSER=0;
assign m_axi_gmem_aux_BUSER=0;
assign m_axi_gmem_state1_RUSER=0;
assign m_axi_gmem_state1_BUSER=0;
assign m_axi_gmem_observed_RUSER=0;
assign m_axi_gmem_observed_BUSER=0;
laya_front16_wide dut(
  .ap_clk(ap_clk),
  .ap_rst_n(ap_rst_n),
  .m_axi_gmem_state0_AWVALID(m_axi_gmem_state0_AWVALID),
  .m_axi_gmem_state0_AWREADY(m_axi_gmem_state0_AWREADY),
  .m_axi_gmem_state0_AWADDR(m_axi_gmem_state0_AWADDR),
  .m_axi_gmem_state0_AWID(m_axi_gmem_state0_AWID),
  .m_axi_gmem_state0_AWLEN(m_axi_gmem_state0_AWLEN),
  .m_axi_gmem_state0_AWSIZE(m_axi_gmem_state0_AWSIZE),
  .m_axi_gmem_state0_AWBURST(m_axi_gmem_state0_AWBURST),
  .m_axi_gmem_state0_AWLOCK(m_axi_gmem_state0_AWLOCK),
  .m_axi_gmem_state0_AWCACHE(m_axi_gmem_state0_AWCACHE),
  .m_axi_gmem_state0_AWPROT(m_axi_gmem_state0_AWPROT),
  .m_axi_gmem_state0_AWQOS(m_axi_gmem_state0_AWQOS),
  .m_axi_gmem_state0_AWREGION(m_axi_gmem_state0_AWREGION),
  .m_axi_gmem_state0_AWUSER(m_axi_gmem_state0_AWUSER),
  .m_axi_gmem_state0_WVALID(m_axi_gmem_state0_WVALID),
  .m_axi_gmem_state0_WREADY(m_axi_gmem_state0_WREADY),
  .m_axi_gmem_state0_WDATA(m_axi_gmem_state0_WDATA),
  .m_axi_gmem_state0_WSTRB(m_axi_gmem_state0_WSTRB),
  .m_axi_gmem_state0_WLAST(m_axi_gmem_state0_WLAST),
  .m_axi_gmem_state0_WID(m_axi_gmem_state0_WID),
  .m_axi_gmem_state0_WUSER(m_axi_gmem_state0_WUSER),
  .m_axi_gmem_state0_ARVALID(m_axi_gmem_state0_ARVALID),
  .m_axi_gmem_state0_ARREADY(m_axi_gmem_state0_ARREADY),
  .m_axi_gmem_state0_ARADDR(m_axi_gmem_state0_ARADDR),
  .m_axi_gmem_state0_ARID(m_axi_gmem_state0_ARID),
  .m_axi_gmem_state0_ARLEN(m_axi_gmem_state0_ARLEN),
  .m_axi_gmem_state0_ARSIZE(m_axi_gmem_state0_ARSIZE),
  .m_axi_gmem_state0_ARBURST(m_axi_gmem_state0_ARBURST),
  .m_axi_gmem_state0_ARLOCK(m_axi_gmem_state0_ARLOCK),
  .m_axi_gmem_state0_ARCACHE(m_axi_gmem_state0_ARCACHE),
  .m_axi_gmem_state0_ARPROT(m_axi_gmem_state0_ARPROT),
  .m_axi_gmem_state0_ARQOS(m_axi_gmem_state0_ARQOS),
  .m_axi_gmem_state0_ARREGION(m_axi_gmem_state0_ARREGION),
  .m_axi_gmem_state0_ARUSER(m_axi_gmem_state0_ARUSER),
  .m_axi_gmem_state0_RVALID(m_axi_gmem_state0_RVALID),
  .m_axi_gmem_state0_RREADY(m_axi_gmem_state0_RREADY),
  .m_axi_gmem_state0_RDATA(m_axi_gmem_state0_RDATA),
  .m_axi_gmem_state0_RLAST(m_axi_gmem_state0_RLAST),
  .m_axi_gmem_state0_RID(m_axi_gmem_state0_RID),
  .m_axi_gmem_state0_RUSER(m_axi_gmem_state0_RUSER),
  .m_axi_gmem_state0_RRESP(m_axi_gmem_state0_RRESP),
  .m_axi_gmem_state0_BVALID(m_axi_gmem_state0_BVALID),
  .m_axi_gmem_state0_BREADY(m_axi_gmem_state0_BREADY),
  .m_axi_gmem_state0_BRESP(m_axi_gmem_state0_BRESP),
  .m_axi_gmem_state0_BID(m_axi_gmem_state0_BID),
  .m_axi_gmem_state0_BUSER(m_axi_gmem_state0_BUSER),
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
  .m_axi_gmem_state1_AWVALID(m_axi_gmem_state1_AWVALID),
  .m_axi_gmem_state1_AWREADY(m_axi_gmem_state1_AWREADY),
  .m_axi_gmem_state1_AWADDR(m_axi_gmem_state1_AWADDR),
  .m_axi_gmem_state1_AWID(m_axi_gmem_state1_AWID),
  .m_axi_gmem_state1_AWLEN(m_axi_gmem_state1_AWLEN),
  .m_axi_gmem_state1_AWSIZE(m_axi_gmem_state1_AWSIZE),
  .m_axi_gmem_state1_AWBURST(m_axi_gmem_state1_AWBURST),
  .m_axi_gmem_state1_AWLOCK(m_axi_gmem_state1_AWLOCK),
  .m_axi_gmem_state1_AWCACHE(m_axi_gmem_state1_AWCACHE),
  .m_axi_gmem_state1_AWPROT(m_axi_gmem_state1_AWPROT),
  .m_axi_gmem_state1_AWQOS(m_axi_gmem_state1_AWQOS),
  .m_axi_gmem_state1_AWREGION(m_axi_gmem_state1_AWREGION),
  .m_axi_gmem_state1_AWUSER(m_axi_gmem_state1_AWUSER),
  .m_axi_gmem_state1_WVALID(m_axi_gmem_state1_WVALID),
  .m_axi_gmem_state1_WREADY(m_axi_gmem_state1_WREADY),
  .m_axi_gmem_state1_WDATA(m_axi_gmem_state1_WDATA),
  .m_axi_gmem_state1_WSTRB(m_axi_gmem_state1_WSTRB),
  .m_axi_gmem_state1_WLAST(m_axi_gmem_state1_WLAST),
  .m_axi_gmem_state1_WID(m_axi_gmem_state1_WID),
  .m_axi_gmem_state1_WUSER(m_axi_gmem_state1_WUSER),
  .m_axi_gmem_state1_ARVALID(m_axi_gmem_state1_ARVALID),
  .m_axi_gmem_state1_ARREADY(m_axi_gmem_state1_ARREADY),
  .m_axi_gmem_state1_ARADDR(m_axi_gmem_state1_ARADDR),
  .m_axi_gmem_state1_ARID(m_axi_gmem_state1_ARID),
  .m_axi_gmem_state1_ARLEN(m_axi_gmem_state1_ARLEN),
  .m_axi_gmem_state1_ARSIZE(m_axi_gmem_state1_ARSIZE),
  .m_axi_gmem_state1_ARBURST(m_axi_gmem_state1_ARBURST),
  .m_axi_gmem_state1_ARLOCK(m_axi_gmem_state1_ARLOCK),
  .m_axi_gmem_state1_ARCACHE(m_axi_gmem_state1_ARCACHE),
  .m_axi_gmem_state1_ARPROT(m_axi_gmem_state1_ARPROT),
  .m_axi_gmem_state1_ARQOS(m_axi_gmem_state1_ARQOS),
  .m_axi_gmem_state1_ARREGION(m_axi_gmem_state1_ARREGION),
  .m_axi_gmem_state1_ARUSER(m_axi_gmem_state1_ARUSER),
  .m_axi_gmem_state1_RVALID(m_axi_gmem_state1_RVALID),
  .m_axi_gmem_state1_RREADY(m_axi_gmem_state1_RREADY),
  .m_axi_gmem_state1_RDATA(m_axi_gmem_state1_RDATA),
  .m_axi_gmem_state1_RLAST(m_axi_gmem_state1_RLAST),
  .m_axi_gmem_state1_RID(m_axi_gmem_state1_RID),
  .m_axi_gmem_state1_RUSER(m_axi_gmem_state1_RUSER),
  .m_axi_gmem_state1_RRESP(m_axi_gmem_state1_RRESP),
  .m_axi_gmem_state1_BVALID(m_axi_gmem_state1_BVALID),
  .m_axi_gmem_state1_BREADY(m_axi_gmem_state1_BREADY),
  .m_axi_gmem_state1_BRESP(m_axi_gmem_state1_BRESP),
  .m_axi_gmem_state1_BID(m_axi_gmem_state1_BID),
  .m_axi_gmem_state1_BUSER(m_axi_gmem_state1_BUSER),
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
assign user_ar_valid[0]=dut.gmem_state0_m_axi_U.I_CH0_ARVALID;
assign user_ar_fire[0]=dut.gmem_state0_m_axi_U.I_CH0_ARVALID && dut.gmem_state0_m_axi_U.I_CH0_ARREADY;
assign user_r_valid[0]=dut.gmem_state0_m_axi_U.I_CH0_RVALID;
assign user_r_fire[0]=dut.gmem_state0_m_axi_U.I_CH0_RVALID && dut.gmem_state0_m_axi_U.I_CH0_RREADY;
assign user_aw_valid[0]=dut.gmem_state0_m_axi_U.I_CH0_AWVALID;
assign user_aw_fire[0]=dut.gmem_state0_m_axi_U.I_CH0_AWVALID && dut.gmem_state0_m_axi_U.I_CH0_AWREADY;
assign user_w_valid[0]=dut.gmem_state0_m_axi_U.I_CH0_WVALID;
assign user_w_fire[0]=dut.gmem_state0_m_axi_U.I_CH0_WVALID && dut.gmem_state0_m_axi_U.I_CH0_WREADY;
assign user_b_valid[0]=dut.gmem_state0_m_axi_U.I_CH0_BVALID;
assign user_b_fire[0]=dut.gmem_state0_m_axi_U.I_CH0_BVALID && dut.gmem_state0_m_axi_U.I_CH0_BREADY;
assign user_ar_len[0]=dut.gmem_state0_m_axi_U.I_CH0_ARLEN;
assign user_aw_len[0]=dut.gmem_state0_m_axi_U.I_CH0_AWLEN;
assign user_rfifonum[0]=dut.gmem_state0_m_axi_U.I_CH0_RFIFONUM;
front16_axi_memory #(.DATA_W(512),.PORT_INDEX(0)) mem_state0 (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .pressure(pressure),
  .AWVALID(m_axi_gmem_state0_AWVALID),
  .AWREADY(m_axi_gmem_state0_AWREADY),
  .AWADDR(m_axi_gmem_state0_AWADDR),
  .AWID(m_axi_gmem_state0_AWID),
  .AWLEN(m_axi_gmem_state0_AWLEN),
  .AWSIZE(m_axi_gmem_state0_AWSIZE),
  .AWBURST(m_axi_gmem_state0_AWBURST),
  .WVALID(m_axi_gmem_state0_WVALID),
  .WREADY(m_axi_gmem_state0_WREADY),
  .WDATA(m_axi_gmem_state0_WDATA),
  .WSTRB(m_axi_gmem_state0_WSTRB),
  .WLAST(m_axi_gmem_state0_WLAST),
  .ARVALID(m_axi_gmem_state0_ARVALID),
  .ARREADY(m_axi_gmem_state0_ARREADY),
  .ARADDR(m_axi_gmem_state0_ARADDR),
  .ARID(m_axi_gmem_state0_ARID),
  .ARLEN(m_axi_gmem_state0_ARLEN),
  .ARSIZE(m_axi_gmem_state0_ARSIZE),
  .ARBURST(m_axi_gmem_state0_ARBURST),
  .RVALID(m_axi_gmem_state0_RVALID),
  .RREADY(m_axi_gmem_state0_RREADY),
  .RDATA(m_axi_gmem_state0_RDATA),
  .RLAST(m_axi_gmem_state0_RLAST),
  .RID(m_axi_gmem_state0_RID),
  .RRESP(m_axi_gmem_state0_RRESP),
  .BVALID(m_axi_gmem_state0_BVALID),
  .BREADY(m_axi_gmem_state0_BREADY),
  .BRESP(m_axi_gmem_state0_BRESP),
  .BID(m_axi_gmem_state0_BID),
  .debt_zero(debt_zero[0]),
  .ar_count(ar_count[0]),
  .r_count(r_count[0]),
  .aw_count(aw_count[0]),
  .w_count(w_count[0]),
  .b_count(b_count[0]),
  .r_hold_hits(r_hold_hits[0]),
  .b_hold_hits(b_hold_hits[0]),
  .r_hold_cycles(r_hold_cycles[0]),
  .b_hold_cycles(b_hold_cycles[0])
);
wire state0_write_illegal = m_axi_gmem_state0_AWVALID || m_axi_gmem_state0_WVALID;
assign user_ar_valid[1]=dut.gmem_aux_m_axi_U.I_CH0_ARVALID;
assign user_ar_fire[1]=dut.gmem_aux_m_axi_U.I_CH0_ARVALID && dut.gmem_aux_m_axi_U.I_CH0_ARREADY;
assign user_r_valid[1]=dut.gmem_aux_m_axi_U.I_CH0_RVALID;
assign user_r_fire[1]=dut.gmem_aux_m_axi_U.I_CH0_RVALID && dut.gmem_aux_m_axi_U.I_CH0_RREADY;
assign user_aw_valid[1]=dut.gmem_aux_m_axi_U.I_CH0_AWVALID;
assign user_aw_fire[1]=dut.gmem_aux_m_axi_U.I_CH0_AWVALID && dut.gmem_aux_m_axi_U.I_CH0_AWREADY;
assign user_w_valid[1]=dut.gmem_aux_m_axi_U.I_CH0_WVALID;
assign user_w_fire[1]=dut.gmem_aux_m_axi_U.I_CH0_WVALID && dut.gmem_aux_m_axi_U.I_CH0_WREADY;
assign user_b_valid[1]=dut.gmem_aux_m_axi_U.I_CH0_BVALID;
assign user_b_fire[1]=dut.gmem_aux_m_axi_U.I_CH0_BVALID && dut.gmem_aux_m_axi_U.I_CH0_BREADY;
assign user_ar_len[1]=dut.gmem_aux_m_axi_U.I_CH0_ARLEN;
assign user_aw_len[1]=dut.gmem_aux_m_axi_U.I_CH0_AWLEN;
assign user_rfifonum[1]=dut.gmem_aux_m_axi_U.I_CH0_RFIFONUM;
front16_axi_memory #(.DATA_W(512),.PORT_INDEX(1)) mem_aux (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .pressure(pressure),
  .AWVALID(m_axi_gmem_aux_AWVALID),
  .AWREADY(m_axi_gmem_aux_AWREADY),
  .AWADDR(m_axi_gmem_aux_AWADDR),
  .AWID(m_axi_gmem_aux_AWID),
  .AWLEN(m_axi_gmem_aux_AWLEN),
  .AWSIZE(m_axi_gmem_aux_AWSIZE),
  .AWBURST(m_axi_gmem_aux_AWBURST),
  .WVALID(m_axi_gmem_aux_WVALID),
  .WREADY(m_axi_gmem_aux_WREADY),
  .WDATA(m_axi_gmem_aux_WDATA),
  .WSTRB(m_axi_gmem_aux_WSTRB),
  .WLAST(m_axi_gmem_aux_WLAST),
  .ARVALID(m_axi_gmem_aux_ARVALID),
  .ARREADY(m_axi_gmem_aux_ARREADY),
  .ARADDR(m_axi_gmem_aux_ARADDR),
  .ARID(m_axi_gmem_aux_ARID),
  .ARLEN(m_axi_gmem_aux_ARLEN),
  .ARSIZE(m_axi_gmem_aux_ARSIZE),
  .ARBURST(m_axi_gmem_aux_ARBURST),
  .RVALID(m_axi_gmem_aux_RVALID),
  .RREADY(m_axi_gmem_aux_RREADY),
  .RDATA(m_axi_gmem_aux_RDATA),
  .RLAST(m_axi_gmem_aux_RLAST),
  .RID(m_axi_gmem_aux_RID),
  .RRESP(m_axi_gmem_aux_RRESP),
  .BVALID(m_axi_gmem_aux_BVALID),
  .BREADY(m_axi_gmem_aux_BREADY),
  .BRESP(m_axi_gmem_aux_BRESP),
  .BID(m_axi_gmem_aux_BID),
  .debt_zero(debt_zero[1]),
  .ar_count(ar_count[1]),
  .r_count(r_count[1]),
  .aw_count(aw_count[1]),
  .w_count(w_count[1]),
  .b_count(b_count[1]),
  .r_hold_hits(r_hold_hits[1]),
  .b_hold_hits(b_hold_hits[1]),
  .r_hold_cycles(r_hold_cycles[1]),
  .b_hold_cycles(b_hold_cycles[1])
);
wire aux_write_illegal = m_axi_gmem_aux_AWVALID || m_axi_gmem_aux_WVALID;
assign user_ar_valid[2]=dut.gmem_state1_m_axi_U.I_CH0_ARVALID;
assign user_ar_fire[2]=dut.gmem_state1_m_axi_U.I_CH0_ARVALID && dut.gmem_state1_m_axi_U.I_CH0_ARREADY;
assign user_r_valid[2]=dut.gmem_state1_m_axi_U.I_CH0_RVALID;
assign user_r_fire[2]=dut.gmem_state1_m_axi_U.I_CH0_RVALID && dut.gmem_state1_m_axi_U.I_CH0_RREADY;
assign user_aw_valid[2]=dut.gmem_state1_m_axi_U.I_CH0_AWVALID;
assign user_aw_fire[2]=dut.gmem_state1_m_axi_U.I_CH0_AWVALID && dut.gmem_state1_m_axi_U.I_CH0_AWREADY;
assign user_w_valid[2]=dut.gmem_state1_m_axi_U.I_CH0_WVALID;
assign user_w_fire[2]=dut.gmem_state1_m_axi_U.I_CH0_WVALID && dut.gmem_state1_m_axi_U.I_CH0_WREADY;
assign user_b_valid[2]=dut.gmem_state1_m_axi_U.I_CH0_BVALID;
assign user_b_fire[2]=dut.gmem_state1_m_axi_U.I_CH0_BVALID && dut.gmem_state1_m_axi_U.I_CH0_BREADY;
assign user_ar_len[2]=dut.gmem_state1_m_axi_U.I_CH0_ARLEN;
assign user_aw_len[2]=dut.gmem_state1_m_axi_U.I_CH0_AWLEN;
assign user_rfifonum[2]=dut.gmem_state1_m_axi_U.I_CH0_RFIFONUM;
front16_axi_memory #(.DATA_W(512),.PORT_INDEX(2)) mem_state1 (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .pressure(pressure),
  .AWVALID(m_axi_gmem_state1_AWVALID),
  .AWREADY(m_axi_gmem_state1_AWREADY),
  .AWADDR(m_axi_gmem_state1_AWADDR),
  .AWID(m_axi_gmem_state1_AWID),
  .AWLEN(m_axi_gmem_state1_AWLEN),
  .AWSIZE(m_axi_gmem_state1_AWSIZE),
  .AWBURST(m_axi_gmem_state1_AWBURST),
  .WVALID(m_axi_gmem_state1_WVALID),
  .WREADY(m_axi_gmem_state1_WREADY),
  .WDATA(m_axi_gmem_state1_WDATA),
  .WSTRB(m_axi_gmem_state1_WSTRB),
  .WLAST(m_axi_gmem_state1_WLAST),
  .ARVALID(m_axi_gmem_state1_ARVALID),
  .ARREADY(m_axi_gmem_state1_ARREADY),
  .ARADDR(m_axi_gmem_state1_ARADDR),
  .ARID(m_axi_gmem_state1_ARID),
  .ARLEN(m_axi_gmem_state1_ARLEN),
  .ARSIZE(m_axi_gmem_state1_ARSIZE),
  .ARBURST(m_axi_gmem_state1_ARBURST),
  .RVALID(m_axi_gmem_state1_RVALID),
  .RREADY(m_axi_gmem_state1_RREADY),
  .RDATA(m_axi_gmem_state1_RDATA),
  .RLAST(m_axi_gmem_state1_RLAST),
  .RID(m_axi_gmem_state1_RID),
  .RRESP(m_axi_gmem_state1_RRESP),
  .BVALID(m_axi_gmem_state1_BVALID),
  .BREADY(m_axi_gmem_state1_BREADY),
  .BRESP(m_axi_gmem_state1_BRESP),
  .BID(m_axi_gmem_state1_BID),
  .debt_zero(debt_zero[2]),
  .ar_count(ar_count[2]),
  .r_count(r_count[2]),
  .aw_count(aw_count[2]),
  .w_count(w_count[2]),
  .b_count(b_count[2]),
  .r_hold_hits(r_hold_hits[2]),
  .b_hold_hits(b_hold_hits[2]),
  .r_hold_cycles(r_hold_cycles[2]),
  .b_hold_cycles(b_hold_cycles[2])
);
wire state1_read_illegal = m_axi_gmem_state1_ARVALID;
assign user_ar_valid[3]=dut.gmem_observed_m_axi_U.I_CH0_ARVALID;
assign user_ar_fire[3]=dut.gmem_observed_m_axi_U.I_CH0_ARVALID && dut.gmem_observed_m_axi_U.I_CH0_ARREADY;
assign user_r_valid[3]=dut.gmem_observed_m_axi_U.I_CH0_RVALID;
assign user_r_fire[3]=dut.gmem_observed_m_axi_U.I_CH0_RVALID && dut.gmem_observed_m_axi_U.I_CH0_RREADY;
assign user_aw_valid[3]=dut.gmem_observed_m_axi_U.I_CH0_AWVALID;
assign user_aw_fire[3]=dut.gmem_observed_m_axi_U.I_CH0_AWVALID && dut.gmem_observed_m_axi_U.I_CH0_AWREADY;
assign user_w_valid[3]=dut.gmem_observed_m_axi_U.I_CH0_WVALID;
assign user_w_fire[3]=dut.gmem_observed_m_axi_U.I_CH0_WVALID && dut.gmem_observed_m_axi_U.I_CH0_WREADY;
assign user_b_valid[3]=dut.gmem_observed_m_axi_U.I_CH0_BVALID;
assign user_b_fire[3]=dut.gmem_observed_m_axi_U.I_CH0_BVALID && dut.gmem_observed_m_axi_U.I_CH0_BREADY;
assign user_ar_len[3]=dut.gmem_observed_m_axi_U.I_CH0_ARLEN;
assign user_aw_len[3]=dut.gmem_observed_m_axi_U.I_CH0_AWLEN;
assign user_rfifonum[3]=dut.gmem_observed_m_axi_U.I_CH0_RFIFONUM;
front16_axi_memory #(.DATA_W(32),.PORT_INDEX(3)) mem_observed (
  .clk(ap_clk),
  .rst_n(ap_rst_n),
  .pressure(pressure),
  .AWVALID(m_axi_gmem_observed_AWVALID),
  .AWREADY(m_axi_gmem_observed_AWREADY),
  .AWADDR(m_axi_gmem_observed_AWADDR),
  .AWID(m_axi_gmem_observed_AWID),
  .AWLEN(m_axi_gmem_observed_AWLEN),
  .AWSIZE(m_axi_gmem_observed_AWSIZE),
  .AWBURST(m_axi_gmem_observed_AWBURST),
  .WVALID(m_axi_gmem_observed_WVALID),
  .WREADY(m_axi_gmem_observed_WREADY),
  .WDATA(m_axi_gmem_observed_WDATA),
  .WSTRB(m_axi_gmem_observed_WSTRB),
  .WLAST(m_axi_gmem_observed_WLAST),
  .ARVALID(m_axi_gmem_observed_ARVALID),
  .ARREADY(m_axi_gmem_observed_ARREADY),
  .ARADDR(m_axi_gmem_observed_ARADDR),
  .ARID(m_axi_gmem_observed_ARID),
  .ARLEN(m_axi_gmem_observed_ARLEN),
  .ARSIZE(m_axi_gmem_observed_ARSIZE),
  .ARBURST(m_axi_gmem_observed_ARBURST),
  .RVALID(m_axi_gmem_observed_RVALID),
  .RREADY(m_axi_gmem_observed_RREADY),
  .RDATA(m_axi_gmem_observed_RDATA),
  .RLAST(m_axi_gmem_observed_RLAST),
  .RID(m_axi_gmem_observed_RID),
  .RRESP(m_axi_gmem_observed_RRESP),
  .BVALID(m_axi_gmem_observed_BVALID),
  .BREADY(m_axi_gmem_observed_BREADY),
  .BRESP(m_axi_gmem_observed_BRESP),
  .BID(m_axi_gmem_observed_BID),
  .debt_zero(debt_zero[3]),
  .ar_count(ar_count[3]),
  .r_count(r_count[3]),
  .aw_count(aw_count[3]),
  .w_count(w_count[3]),
  .b_count(b_count[3]),
  .r_hold_hits(r_hold_hits[3]),
  .b_hold_hits(b_hold_hits[3]),
  .r_hold_cycles(r_hold_cycles[3]),
  .b_hold_cycles(b_hold_cycles[3])
);
wire observed_read_illegal = m_axi_gmem_observed_ARVALID;
always @(posedge ap_clk) if (ap_rst_n) begin
  if (state0_write_illegal || aux_write_illegal || state1_read_illegal || observed_read_illegal)
    $fatal(1,"front16 BO direction violation");
end
always @(posedge ap_clk) begin
  if (!ap_rst_n) begin
    for (int p=0;p<4;p++) begin
      user_ar_elements[p]<=0; user_r_elements[p]<=0; user_read_peak[p]<=0;
      user_aw_requests[p]<=0; user_aw_elements[p]<=0;
      user_w_elements[p]<=0; user_b_responses[p]<=0;
    end
  end else begin
    for (int p=0;p<4;p++) begin
      if (user_ar_fire[p] && (user_ar_len[p]==0 || user_ar_len[p]>65536))
        $fatal(1,"front16 invalid adapter ARLEN port=%0d len=%0d",p,user_ar_len[p]);
      if (user_aw_fire[p] && (user_aw_len[p]==0 || user_aw_len[p]>65536))
        $fatal(1,"front16 invalid adapter AWLEN port=%0d len=%0d",p,user_aw_len[p]);
      user_ar_elements[p]<=user_ar_elements[p]+(user_ar_fire[p]?user_ar_len[p]:0);
      user_r_elements[p]<=user_r_elements[p]+user_r_fire[p];
      read_debt_next=user_ar_elements[p]+(user_ar_fire[p]?user_ar_len[p]:0)
                    -user_r_elements[p]-user_r_fire[p];
      if (read_debt_next<0) $fatal(1,"front16 adapter read debt underflow port=%0d",p);
      if (read_debt_next>user_read_peak[p]) user_read_peak[p]<=read_debt_next;
      user_aw_requests[p]<=user_aw_requests[p]+user_aw_fire[p];
      user_aw_elements[p]<=user_aw_elements[p]+(user_aw_fire[p]?user_aw_len[p]:0);
      user_w_elements[p]<=user_w_elements[p]+user_w_fire[p];
      user_b_responses[p]<=user_b_responses[p]+user_b_fire[p];
      aw_requests_next=user_aw_requests[p]+user_aw_fire[p];
      b_responses_next=user_b_responses[p]+user_b_fire[p];
      if (b_responses_next>aw_requests_next)
        $fatal(1,"front16 adapter B without AW port=%0d",p);
    end
  end
end
endmodule
