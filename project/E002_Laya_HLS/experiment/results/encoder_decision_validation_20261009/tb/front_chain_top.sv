`timescale 1ns/1ps
module front_chain_top;
import "DPI-C" function int front_mem_init();
import "DPI-C" function int front_mem_seen();
import "DPI-C" function int front_mem_progress();
import "DPI-C" function int front_mem_consumed();
import "DPI-C" function int front_mem_errors();
import "DPI-C" function int front_mem_result_status();
import "DPI-C" function int front_mem_check();
localparam    ap_ST_fsm_state1 = 3'd1;
localparam    ap_ST_fsm_state2 = 3'd2;
localparam    ap_ST_fsm_state3 = 3'd4;
localparam    C_S_AXI_CONTROL_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_ADDR_WIDTH = 4;
localparam    C_S_AXI_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_DATA_WIDTH = 32;
localparam    C_S_AXI_CONTROL_R_ADDR_WIDTH = 8;
localparam    C_M_AXI_ATT_OUT_ID_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_ADDR_WIDTH = 64;
localparam    C_M_AXI_ATT_OUT_DATA_WIDTH = 32;
localparam    C_M_AXI_ATT_OUT_AWUSER_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_ARUSER_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_WUSER_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_RUSER_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_BUSER_WIDTH = 1;
localparam    C_M_AXI_ATT_OUT_USER_VALUE = 0;
localparam    C_M_AXI_ATT_OUT_PROT_VALUE = 0;
localparam    C_M_AXI_ATT_OUT_CACHE_VALUE = 3;
localparam    C_M_AXI_DATA_WIDTH = 32;
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
localparam    C_M_AXI_EMBEDDING_ID_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_ADDR_WIDTH = 64;
localparam    C_M_AXI_EMBEDDING_DATA_WIDTH = 32;
localparam    C_M_AXI_EMBEDDING_AWUSER_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_ARUSER_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_WUSER_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_RUSER_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_BUSER_WIDTH = 1;
localparam    C_M_AXI_EMBEDDING_USER_VALUE = 0;
localparam    C_M_AXI_EMBEDDING_PROT_VALUE = 0;
localparam    C_M_AXI_EMBEDDING_CACHE_VALUE = 3;
localparam    C_M_AXI_FF0_ID_WIDTH = 1;
localparam    C_M_AXI_FF0_ADDR_WIDTH = 64;
localparam    C_M_AXI_FF0_DATA_WIDTH = 32;
localparam    C_M_AXI_FF0_AWUSER_WIDTH = 1;
localparam    C_M_AXI_FF0_ARUSER_WIDTH = 1;
localparam    C_M_AXI_FF0_WUSER_WIDTH = 1;
localparam    C_M_AXI_FF0_RUSER_WIDTH = 1;
localparam    C_M_AXI_FF0_BUSER_WIDTH = 1;
localparam    C_M_AXI_FF0_USER_VALUE = 0;
localparam    C_M_AXI_FF0_PROT_VALUE = 0;
localparam    C_M_AXI_FF0_CACHE_VALUE = 3;
localparam    C_M_AXI_FF1_ID_WIDTH = 1;
localparam    C_M_AXI_FF1_ADDR_WIDTH = 64;
localparam    C_M_AXI_FF1_DATA_WIDTH = 32;
localparam    C_M_AXI_FF1_AWUSER_WIDTH = 1;
localparam    C_M_AXI_FF1_ARUSER_WIDTH = 1;
localparam    C_M_AXI_FF1_WUSER_WIDTH = 1;
localparam    C_M_AXI_FF1_RUSER_WIDTH = 1;
localparam    C_M_AXI_FF1_BUSER_WIDTH = 1;
localparam    C_M_AXI_FF1_USER_VALUE = 0;
localparam    C_M_AXI_FF1_PROT_VALUE = 0;
localparam    C_M_AXI_FF1_CACHE_VALUE = 3;
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
localparam    C_M_AXI_QKV0_ID_WIDTH = 1;
localparam    C_M_AXI_QKV0_ADDR_WIDTH = 64;
localparam    C_M_AXI_QKV0_DATA_WIDTH = 32;
localparam    C_M_AXI_QKV0_AWUSER_WIDTH = 1;
localparam    C_M_AXI_QKV0_ARUSER_WIDTH = 1;
localparam    C_M_AXI_QKV0_WUSER_WIDTH = 1;
localparam    C_M_AXI_QKV0_RUSER_WIDTH = 1;
localparam    C_M_AXI_QKV0_BUSER_WIDTH = 1;
localparam    C_M_AXI_QKV0_USER_VALUE = 0;
localparam    C_M_AXI_QKV0_PROT_VALUE = 0;
localparam    C_M_AXI_QKV0_CACHE_VALUE = 3;
localparam    C_M_AXI_QKV1_ID_WIDTH = 1;
localparam    C_M_AXI_QKV1_ADDR_WIDTH = 64;
localparam    C_M_AXI_QKV1_DATA_WIDTH = 32;
localparam    C_M_AXI_QKV1_AWUSER_WIDTH = 1;
localparam    C_M_AXI_QKV1_ARUSER_WIDTH = 1;
localparam    C_M_AXI_QKV1_WUSER_WIDTH = 1;
localparam    C_M_AXI_QKV1_RUSER_WIDTH = 1;
localparam    C_M_AXI_QKV1_BUSER_WIDTH = 1;
localparam    C_M_AXI_QKV1_USER_VALUE = 0;
localparam    C_M_AXI_QKV1_PROT_VALUE = 0;
localparam    C_M_AXI_QKV1_CACHE_VALUE = 3;
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
localparam    C_M_AXI_W_Q0_ID_WIDTH = 1;
localparam    C_M_AXI_W_Q0_ADDR_WIDTH = 64;
localparam    C_M_AXI_W_Q0_DATA_WIDTH = 32;
localparam    C_M_AXI_W_Q0_AWUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q0_ARUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q0_WUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q0_RUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q0_BUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q0_USER_VALUE = 0;
localparam    C_M_AXI_W_Q0_PROT_VALUE = 0;
localparam    C_M_AXI_W_Q0_CACHE_VALUE = 3;
localparam    C_M_AXI_W_Q1_ID_WIDTH = 1;
localparam    C_M_AXI_W_Q1_ADDR_WIDTH = 64;
localparam    C_M_AXI_W_Q1_DATA_WIDTH = 32;
localparam    C_M_AXI_W_Q1_AWUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q1_ARUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q1_WUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q1_RUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q1_BUSER_WIDTH = 1;
localparam    C_M_AXI_W_Q1_USER_VALUE = 0;
localparam    C_M_AXI_W_Q1_PROT_VALUE = 0;
localparam    C_M_AXI_W_Q1_CACHE_VALUE = 3;
localparam    C_M_AXI_W_SCALE_ID_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_ADDR_WIDTH = 64;
localparam    C_M_AXI_W_SCALE_DATA_WIDTH = 32;
localparam    C_M_AXI_W_SCALE_AWUSER_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_ARUSER_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_WUSER_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_RUSER_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_BUSER_WIDTH = 1;
localparam    C_M_AXI_W_SCALE_USER_VALUE = 0;
localparam    C_M_AXI_W_SCALE_PROT_VALUE = 0;
localparam    C_M_AXI_W_SCALE_CACHE_VALUE = 3;
localparam C_M_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_W_SCALE_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_W_Q1_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_W_Q0_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_STATE1_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_STATE0_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_QKV1_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_QKV0_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_CONTROL_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_IO_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_FF1_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_FF0_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_EMBEDDING_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_AUX_WSTRB_WIDTH = (32 / 8);
localparam C_M_AXI_ATT_OUT_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_WSTRB_WIDTH = (32 / 8);
localparam C_S_AXI_CONTROL_R_WSTRB_WIDTH = (32 / 8);
logic ap_clk;
logic ap_rst_n;
logic m_axi_embedding_AWVALID;
logic m_axi_embedding_AWREADY;
logic [C_M_AXI_EMBEDDING_ADDR_WIDTH - 1:0] m_axi_embedding_AWADDR;
logic [C_M_AXI_EMBEDDING_ID_WIDTH - 1:0] m_axi_embedding_AWID;
logic [7:0] m_axi_embedding_AWLEN;
logic [2:0] m_axi_embedding_AWSIZE;
logic [1:0] m_axi_embedding_AWBURST;
logic [1:0] m_axi_embedding_AWLOCK;
logic [3:0] m_axi_embedding_AWCACHE;
logic [2:0] m_axi_embedding_AWPROT;
logic [3:0] m_axi_embedding_AWQOS;
logic [3:0] m_axi_embedding_AWREGION;
logic [C_M_AXI_EMBEDDING_AWUSER_WIDTH - 1:0] m_axi_embedding_AWUSER;
logic m_axi_embedding_WVALID;
logic m_axi_embedding_WREADY;
logic [C_M_AXI_EMBEDDING_DATA_WIDTH - 1:0] m_axi_embedding_WDATA;
logic [C_M_AXI_EMBEDDING_WSTRB_WIDTH - 1:0] m_axi_embedding_WSTRB;
logic m_axi_embedding_WLAST;
logic [C_M_AXI_EMBEDDING_ID_WIDTH - 1:0] m_axi_embedding_WID;
logic [C_M_AXI_EMBEDDING_WUSER_WIDTH - 1:0] m_axi_embedding_WUSER;
logic m_axi_embedding_ARVALID;
logic m_axi_embedding_ARREADY;
logic [C_M_AXI_EMBEDDING_ADDR_WIDTH - 1:0] m_axi_embedding_ARADDR;
logic [C_M_AXI_EMBEDDING_ID_WIDTH - 1:0] m_axi_embedding_ARID;
logic [7:0] m_axi_embedding_ARLEN;
logic [2:0] m_axi_embedding_ARSIZE;
logic [1:0] m_axi_embedding_ARBURST;
logic [1:0] m_axi_embedding_ARLOCK;
logic [3:0] m_axi_embedding_ARCACHE;
logic [2:0] m_axi_embedding_ARPROT;
logic [3:0] m_axi_embedding_ARQOS;
logic [3:0] m_axi_embedding_ARREGION;
logic [C_M_AXI_EMBEDDING_ARUSER_WIDTH - 1:0] m_axi_embedding_ARUSER;
logic m_axi_embedding_RVALID;
logic m_axi_embedding_RREADY;
logic [C_M_AXI_EMBEDDING_DATA_WIDTH - 1:0] m_axi_embedding_RDATA;
logic m_axi_embedding_RLAST;
logic [C_M_AXI_EMBEDDING_ID_WIDTH - 1:0] m_axi_embedding_RID;
logic [C_M_AXI_EMBEDDING_RUSER_WIDTH - 1:0] m_axi_embedding_RUSER;
logic [1:0] m_axi_embedding_RRESP;
logic m_axi_embedding_BVALID;
logic m_axi_embedding_BREADY;
logic [1:0] m_axi_embedding_BRESP;
logic [C_M_AXI_EMBEDDING_ID_WIDTH - 1:0] m_axi_embedding_BID;
logic [C_M_AXI_EMBEDDING_BUSER_WIDTH - 1:0] m_axi_embedding_BUSER;
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
logic m_axi_w_q0_AWVALID;
logic m_axi_w_q0_AWREADY;
logic [C_M_AXI_W_Q0_ADDR_WIDTH - 1:0] m_axi_w_q0_AWADDR;
logic [C_M_AXI_W_Q0_ID_WIDTH - 1:0] m_axi_w_q0_AWID;
logic [7:0] m_axi_w_q0_AWLEN;
logic [2:0] m_axi_w_q0_AWSIZE;
logic [1:0] m_axi_w_q0_AWBURST;
logic [1:0] m_axi_w_q0_AWLOCK;
logic [3:0] m_axi_w_q0_AWCACHE;
logic [2:0] m_axi_w_q0_AWPROT;
logic [3:0] m_axi_w_q0_AWQOS;
logic [3:0] m_axi_w_q0_AWREGION;
logic [C_M_AXI_W_Q0_AWUSER_WIDTH - 1:0] m_axi_w_q0_AWUSER;
logic m_axi_w_q0_WVALID;
logic m_axi_w_q0_WREADY;
logic [C_M_AXI_W_Q0_DATA_WIDTH - 1:0] m_axi_w_q0_WDATA;
logic [C_M_AXI_W_Q0_WSTRB_WIDTH - 1:0] m_axi_w_q0_WSTRB;
logic m_axi_w_q0_WLAST;
logic [C_M_AXI_W_Q0_ID_WIDTH - 1:0] m_axi_w_q0_WID;
logic [C_M_AXI_W_Q0_WUSER_WIDTH - 1:0] m_axi_w_q0_WUSER;
logic m_axi_w_q0_ARVALID;
logic m_axi_w_q0_ARREADY;
logic [C_M_AXI_W_Q0_ADDR_WIDTH - 1:0] m_axi_w_q0_ARADDR;
logic [C_M_AXI_W_Q0_ID_WIDTH - 1:0] m_axi_w_q0_ARID;
logic [7:0] m_axi_w_q0_ARLEN;
logic [2:0] m_axi_w_q0_ARSIZE;
logic [1:0] m_axi_w_q0_ARBURST;
logic [1:0] m_axi_w_q0_ARLOCK;
logic [3:0] m_axi_w_q0_ARCACHE;
logic [2:0] m_axi_w_q0_ARPROT;
logic [3:0] m_axi_w_q0_ARQOS;
logic [3:0] m_axi_w_q0_ARREGION;
logic [C_M_AXI_W_Q0_ARUSER_WIDTH - 1:0] m_axi_w_q0_ARUSER;
logic m_axi_w_q0_RVALID;
logic m_axi_w_q0_RREADY;
logic [C_M_AXI_W_Q0_DATA_WIDTH - 1:0] m_axi_w_q0_RDATA;
logic m_axi_w_q0_RLAST;
logic [C_M_AXI_W_Q0_ID_WIDTH - 1:0] m_axi_w_q0_RID;
logic [C_M_AXI_W_Q0_RUSER_WIDTH - 1:0] m_axi_w_q0_RUSER;
logic [1:0] m_axi_w_q0_RRESP;
logic m_axi_w_q0_BVALID;
logic m_axi_w_q0_BREADY;
logic [1:0] m_axi_w_q0_BRESP;
logic [C_M_AXI_W_Q0_ID_WIDTH - 1:0] m_axi_w_q0_BID;
logic [C_M_AXI_W_Q0_BUSER_WIDTH - 1:0] m_axi_w_q0_BUSER;
logic m_axi_w_q1_AWVALID;
logic m_axi_w_q1_AWREADY;
logic [C_M_AXI_W_Q1_ADDR_WIDTH - 1:0] m_axi_w_q1_AWADDR;
logic [C_M_AXI_W_Q1_ID_WIDTH - 1:0] m_axi_w_q1_AWID;
logic [7:0] m_axi_w_q1_AWLEN;
logic [2:0] m_axi_w_q1_AWSIZE;
logic [1:0] m_axi_w_q1_AWBURST;
logic [1:0] m_axi_w_q1_AWLOCK;
logic [3:0] m_axi_w_q1_AWCACHE;
logic [2:0] m_axi_w_q1_AWPROT;
logic [3:0] m_axi_w_q1_AWQOS;
logic [3:0] m_axi_w_q1_AWREGION;
logic [C_M_AXI_W_Q1_AWUSER_WIDTH - 1:0] m_axi_w_q1_AWUSER;
logic m_axi_w_q1_WVALID;
logic m_axi_w_q1_WREADY;
logic [C_M_AXI_W_Q1_DATA_WIDTH - 1:0] m_axi_w_q1_WDATA;
logic [C_M_AXI_W_Q1_WSTRB_WIDTH - 1:0] m_axi_w_q1_WSTRB;
logic m_axi_w_q1_WLAST;
logic [C_M_AXI_W_Q1_ID_WIDTH - 1:0] m_axi_w_q1_WID;
logic [C_M_AXI_W_Q1_WUSER_WIDTH - 1:0] m_axi_w_q1_WUSER;
logic m_axi_w_q1_ARVALID;
logic m_axi_w_q1_ARREADY;
logic [C_M_AXI_W_Q1_ADDR_WIDTH - 1:0] m_axi_w_q1_ARADDR;
logic [C_M_AXI_W_Q1_ID_WIDTH - 1:0] m_axi_w_q1_ARID;
logic [7:0] m_axi_w_q1_ARLEN;
logic [2:0] m_axi_w_q1_ARSIZE;
logic [1:0] m_axi_w_q1_ARBURST;
logic [1:0] m_axi_w_q1_ARLOCK;
logic [3:0] m_axi_w_q1_ARCACHE;
logic [2:0] m_axi_w_q1_ARPROT;
logic [3:0] m_axi_w_q1_ARQOS;
logic [3:0] m_axi_w_q1_ARREGION;
logic [C_M_AXI_W_Q1_ARUSER_WIDTH - 1:0] m_axi_w_q1_ARUSER;
logic m_axi_w_q1_RVALID;
logic m_axi_w_q1_RREADY;
logic [C_M_AXI_W_Q1_DATA_WIDTH - 1:0] m_axi_w_q1_RDATA;
logic m_axi_w_q1_RLAST;
logic [C_M_AXI_W_Q1_ID_WIDTH - 1:0] m_axi_w_q1_RID;
logic [C_M_AXI_W_Q1_RUSER_WIDTH - 1:0] m_axi_w_q1_RUSER;
logic [1:0] m_axi_w_q1_RRESP;
logic m_axi_w_q1_BVALID;
logic m_axi_w_q1_BREADY;
logic [1:0] m_axi_w_q1_BRESP;
logic [C_M_AXI_W_Q1_ID_WIDTH - 1:0] m_axi_w_q1_BID;
logic [C_M_AXI_W_Q1_BUSER_WIDTH - 1:0] m_axi_w_q1_BUSER;
logic m_axi_w_scale_AWVALID;
logic m_axi_w_scale_AWREADY;
logic [C_M_AXI_W_SCALE_ADDR_WIDTH - 1:0] m_axi_w_scale_AWADDR;
logic [C_M_AXI_W_SCALE_ID_WIDTH - 1:0] m_axi_w_scale_AWID;
logic [7:0] m_axi_w_scale_AWLEN;
logic [2:0] m_axi_w_scale_AWSIZE;
logic [1:0] m_axi_w_scale_AWBURST;
logic [1:0] m_axi_w_scale_AWLOCK;
logic [3:0] m_axi_w_scale_AWCACHE;
logic [2:0] m_axi_w_scale_AWPROT;
logic [3:0] m_axi_w_scale_AWQOS;
logic [3:0] m_axi_w_scale_AWREGION;
logic [C_M_AXI_W_SCALE_AWUSER_WIDTH - 1:0] m_axi_w_scale_AWUSER;
logic m_axi_w_scale_WVALID;
logic m_axi_w_scale_WREADY;
logic [C_M_AXI_W_SCALE_DATA_WIDTH - 1:0] m_axi_w_scale_WDATA;
logic [C_M_AXI_W_SCALE_WSTRB_WIDTH - 1:0] m_axi_w_scale_WSTRB;
logic m_axi_w_scale_WLAST;
logic [C_M_AXI_W_SCALE_ID_WIDTH - 1:0] m_axi_w_scale_WID;
logic [C_M_AXI_W_SCALE_WUSER_WIDTH - 1:0] m_axi_w_scale_WUSER;
logic m_axi_w_scale_ARVALID;
logic m_axi_w_scale_ARREADY;
logic [C_M_AXI_W_SCALE_ADDR_WIDTH - 1:0] m_axi_w_scale_ARADDR;
logic [C_M_AXI_W_SCALE_ID_WIDTH - 1:0] m_axi_w_scale_ARID;
logic [7:0] m_axi_w_scale_ARLEN;
logic [2:0] m_axi_w_scale_ARSIZE;
logic [1:0] m_axi_w_scale_ARBURST;
logic [1:0] m_axi_w_scale_ARLOCK;
logic [3:0] m_axi_w_scale_ARCACHE;
logic [2:0] m_axi_w_scale_ARPROT;
logic [3:0] m_axi_w_scale_ARQOS;
logic [3:0] m_axi_w_scale_ARREGION;
logic [C_M_AXI_W_SCALE_ARUSER_WIDTH - 1:0] m_axi_w_scale_ARUSER;
logic m_axi_w_scale_RVALID;
logic m_axi_w_scale_RREADY;
logic [C_M_AXI_W_SCALE_DATA_WIDTH - 1:0] m_axi_w_scale_RDATA;
logic m_axi_w_scale_RLAST;
logic [C_M_AXI_W_SCALE_ID_WIDTH - 1:0] m_axi_w_scale_RID;
logic [C_M_AXI_W_SCALE_RUSER_WIDTH - 1:0] m_axi_w_scale_RUSER;
logic [1:0] m_axi_w_scale_RRESP;
logic m_axi_w_scale_BVALID;
logic m_axi_w_scale_BREADY;
logic [1:0] m_axi_w_scale_BRESP;
logic [C_M_AXI_W_SCALE_ID_WIDTH - 1:0] m_axi_w_scale_BID;
logic [C_M_AXI_W_SCALE_BUSER_WIDTH - 1:0] m_axi_w_scale_BUSER;
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
logic m_axi_qkv0_AWVALID;
logic m_axi_qkv0_AWREADY;
logic [C_M_AXI_QKV0_ADDR_WIDTH - 1:0] m_axi_qkv0_AWADDR;
logic [C_M_AXI_QKV0_ID_WIDTH - 1:0] m_axi_qkv0_AWID;
logic [7:0] m_axi_qkv0_AWLEN;
logic [2:0] m_axi_qkv0_AWSIZE;
logic [1:0] m_axi_qkv0_AWBURST;
logic [1:0] m_axi_qkv0_AWLOCK;
logic [3:0] m_axi_qkv0_AWCACHE;
logic [2:0] m_axi_qkv0_AWPROT;
logic [3:0] m_axi_qkv0_AWQOS;
logic [3:0] m_axi_qkv0_AWREGION;
logic [C_M_AXI_QKV0_AWUSER_WIDTH - 1:0] m_axi_qkv0_AWUSER;
logic m_axi_qkv0_WVALID;
logic m_axi_qkv0_WREADY;
logic [C_M_AXI_QKV0_DATA_WIDTH - 1:0] m_axi_qkv0_WDATA;
logic [C_M_AXI_QKV0_WSTRB_WIDTH - 1:0] m_axi_qkv0_WSTRB;
logic m_axi_qkv0_WLAST;
logic [C_M_AXI_QKV0_ID_WIDTH - 1:0] m_axi_qkv0_WID;
logic [C_M_AXI_QKV0_WUSER_WIDTH - 1:0] m_axi_qkv0_WUSER;
logic m_axi_qkv0_ARVALID;
logic m_axi_qkv0_ARREADY;
logic [C_M_AXI_QKV0_ADDR_WIDTH - 1:0] m_axi_qkv0_ARADDR;
logic [C_M_AXI_QKV0_ID_WIDTH - 1:0] m_axi_qkv0_ARID;
logic [7:0] m_axi_qkv0_ARLEN;
logic [2:0] m_axi_qkv0_ARSIZE;
logic [1:0] m_axi_qkv0_ARBURST;
logic [1:0] m_axi_qkv0_ARLOCK;
logic [3:0] m_axi_qkv0_ARCACHE;
logic [2:0] m_axi_qkv0_ARPROT;
logic [3:0] m_axi_qkv0_ARQOS;
logic [3:0] m_axi_qkv0_ARREGION;
logic [C_M_AXI_QKV0_ARUSER_WIDTH - 1:0] m_axi_qkv0_ARUSER;
logic m_axi_qkv0_RVALID;
logic m_axi_qkv0_RREADY;
logic [C_M_AXI_QKV0_DATA_WIDTH - 1:0] m_axi_qkv0_RDATA;
logic m_axi_qkv0_RLAST;
logic [C_M_AXI_QKV0_ID_WIDTH - 1:0] m_axi_qkv0_RID;
logic [C_M_AXI_QKV0_RUSER_WIDTH - 1:0] m_axi_qkv0_RUSER;
logic [1:0] m_axi_qkv0_RRESP;
logic m_axi_qkv0_BVALID;
logic m_axi_qkv0_BREADY;
logic [1:0] m_axi_qkv0_BRESP;
logic [C_M_AXI_QKV0_ID_WIDTH - 1:0] m_axi_qkv0_BID;
logic [C_M_AXI_QKV0_BUSER_WIDTH - 1:0] m_axi_qkv0_BUSER;
logic m_axi_qkv1_AWVALID;
logic m_axi_qkv1_AWREADY;
logic [C_M_AXI_QKV1_ADDR_WIDTH - 1:0] m_axi_qkv1_AWADDR;
logic [C_M_AXI_QKV1_ID_WIDTH - 1:0] m_axi_qkv1_AWID;
logic [7:0] m_axi_qkv1_AWLEN;
logic [2:0] m_axi_qkv1_AWSIZE;
logic [1:0] m_axi_qkv1_AWBURST;
logic [1:0] m_axi_qkv1_AWLOCK;
logic [3:0] m_axi_qkv1_AWCACHE;
logic [2:0] m_axi_qkv1_AWPROT;
logic [3:0] m_axi_qkv1_AWQOS;
logic [3:0] m_axi_qkv1_AWREGION;
logic [C_M_AXI_QKV1_AWUSER_WIDTH - 1:0] m_axi_qkv1_AWUSER;
logic m_axi_qkv1_WVALID;
logic m_axi_qkv1_WREADY;
logic [C_M_AXI_QKV1_DATA_WIDTH - 1:0] m_axi_qkv1_WDATA;
logic [C_M_AXI_QKV1_WSTRB_WIDTH - 1:0] m_axi_qkv1_WSTRB;
logic m_axi_qkv1_WLAST;
logic [C_M_AXI_QKV1_ID_WIDTH - 1:0] m_axi_qkv1_WID;
logic [C_M_AXI_QKV1_WUSER_WIDTH - 1:0] m_axi_qkv1_WUSER;
logic m_axi_qkv1_ARVALID;
logic m_axi_qkv1_ARREADY;
logic [C_M_AXI_QKV1_ADDR_WIDTH - 1:0] m_axi_qkv1_ARADDR;
logic [C_M_AXI_QKV1_ID_WIDTH - 1:0] m_axi_qkv1_ARID;
logic [7:0] m_axi_qkv1_ARLEN;
logic [2:0] m_axi_qkv1_ARSIZE;
logic [1:0] m_axi_qkv1_ARBURST;
logic [1:0] m_axi_qkv1_ARLOCK;
logic [3:0] m_axi_qkv1_ARCACHE;
logic [2:0] m_axi_qkv1_ARPROT;
logic [3:0] m_axi_qkv1_ARQOS;
logic [3:0] m_axi_qkv1_ARREGION;
logic [C_M_AXI_QKV1_ARUSER_WIDTH - 1:0] m_axi_qkv1_ARUSER;
logic m_axi_qkv1_RVALID;
logic m_axi_qkv1_RREADY;
logic [C_M_AXI_QKV1_DATA_WIDTH - 1:0] m_axi_qkv1_RDATA;
logic m_axi_qkv1_RLAST;
logic [C_M_AXI_QKV1_ID_WIDTH - 1:0] m_axi_qkv1_RID;
logic [C_M_AXI_QKV1_RUSER_WIDTH - 1:0] m_axi_qkv1_RUSER;
logic [1:0] m_axi_qkv1_RRESP;
logic m_axi_qkv1_BVALID;
logic m_axi_qkv1_BREADY;
logic [1:0] m_axi_qkv1_BRESP;
logic [C_M_AXI_QKV1_ID_WIDTH - 1:0] m_axi_qkv1_BID;
logic [C_M_AXI_QKV1_BUSER_WIDTH - 1:0] m_axi_qkv1_BUSER;
logic m_axi_ff0_AWVALID;
logic m_axi_ff0_AWREADY;
logic [C_M_AXI_FF0_ADDR_WIDTH - 1:0] m_axi_ff0_AWADDR;
logic [C_M_AXI_FF0_ID_WIDTH - 1:0] m_axi_ff0_AWID;
logic [7:0] m_axi_ff0_AWLEN;
logic [2:0] m_axi_ff0_AWSIZE;
logic [1:0] m_axi_ff0_AWBURST;
logic [1:0] m_axi_ff0_AWLOCK;
logic [3:0] m_axi_ff0_AWCACHE;
logic [2:0] m_axi_ff0_AWPROT;
logic [3:0] m_axi_ff0_AWQOS;
logic [3:0] m_axi_ff0_AWREGION;
logic [C_M_AXI_FF0_AWUSER_WIDTH - 1:0] m_axi_ff0_AWUSER;
logic m_axi_ff0_WVALID;
logic m_axi_ff0_WREADY;
logic [C_M_AXI_FF0_DATA_WIDTH - 1:0] m_axi_ff0_WDATA;
logic [C_M_AXI_FF0_WSTRB_WIDTH - 1:0] m_axi_ff0_WSTRB;
logic m_axi_ff0_WLAST;
logic [C_M_AXI_FF0_ID_WIDTH - 1:0] m_axi_ff0_WID;
logic [C_M_AXI_FF0_WUSER_WIDTH - 1:0] m_axi_ff0_WUSER;
logic m_axi_ff0_ARVALID;
logic m_axi_ff0_ARREADY;
logic [C_M_AXI_FF0_ADDR_WIDTH - 1:0] m_axi_ff0_ARADDR;
logic [C_M_AXI_FF0_ID_WIDTH - 1:0] m_axi_ff0_ARID;
logic [7:0] m_axi_ff0_ARLEN;
logic [2:0] m_axi_ff0_ARSIZE;
logic [1:0] m_axi_ff0_ARBURST;
logic [1:0] m_axi_ff0_ARLOCK;
logic [3:0] m_axi_ff0_ARCACHE;
logic [2:0] m_axi_ff0_ARPROT;
logic [3:0] m_axi_ff0_ARQOS;
logic [3:0] m_axi_ff0_ARREGION;
logic [C_M_AXI_FF0_ARUSER_WIDTH - 1:0] m_axi_ff0_ARUSER;
logic m_axi_ff0_RVALID;
logic m_axi_ff0_RREADY;
logic [C_M_AXI_FF0_DATA_WIDTH - 1:0] m_axi_ff0_RDATA;
logic m_axi_ff0_RLAST;
logic [C_M_AXI_FF0_ID_WIDTH - 1:0] m_axi_ff0_RID;
logic [C_M_AXI_FF0_RUSER_WIDTH - 1:0] m_axi_ff0_RUSER;
logic [1:0] m_axi_ff0_RRESP;
logic m_axi_ff0_BVALID;
logic m_axi_ff0_BREADY;
logic [1:0] m_axi_ff0_BRESP;
logic [C_M_AXI_FF0_ID_WIDTH - 1:0] m_axi_ff0_BID;
logic [C_M_AXI_FF0_BUSER_WIDTH - 1:0] m_axi_ff0_BUSER;
logic m_axi_ff1_AWVALID;
logic m_axi_ff1_AWREADY;
logic [C_M_AXI_FF1_ADDR_WIDTH - 1:0] m_axi_ff1_AWADDR;
logic [C_M_AXI_FF1_ID_WIDTH - 1:0] m_axi_ff1_AWID;
logic [7:0] m_axi_ff1_AWLEN;
logic [2:0] m_axi_ff1_AWSIZE;
logic [1:0] m_axi_ff1_AWBURST;
logic [1:0] m_axi_ff1_AWLOCK;
logic [3:0] m_axi_ff1_AWCACHE;
logic [2:0] m_axi_ff1_AWPROT;
logic [3:0] m_axi_ff1_AWQOS;
logic [3:0] m_axi_ff1_AWREGION;
logic [C_M_AXI_FF1_AWUSER_WIDTH - 1:0] m_axi_ff1_AWUSER;
logic m_axi_ff1_WVALID;
logic m_axi_ff1_WREADY;
logic [C_M_AXI_FF1_DATA_WIDTH - 1:0] m_axi_ff1_WDATA;
logic [C_M_AXI_FF1_WSTRB_WIDTH - 1:0] m_axi_ff1_WSTRB;
logic m_axi_ff1_WLAST;
logic [C_M_AXI_FF1_ID_WIDTH - 1:0] m_axi_ff1_WID;
logic [C_M_AXI_FF1_WUSER_WIDTH - 1:0] m_axi_ff1_WUSER;
logic m_axi_ff1_ARVALID;
logic m_axi_ff1_ARREADY;
logic [C_M_AXI_FF1_ADDR_WIDTH - 1:0] m_axi_ff1_ARADDR;
logic [C_M_AXI_FF1_ID_WIDTH - 1:0] m_axi_ff1_ARID;
logic [7:0] m_axi_ff1_ARLEN;
logic [2:0] m_axi_ff1_ARSIZE;
logic [1:0] m_axi_ff1_ARBURST;
logic [1:0] m_axi_ff1_ARLOCK;
logic [3:0] m_axi_ff1_ARCACHE;
logic [2:0] m_axi_ff1_ARPROT;
logic [3:0] m_axi_ff1_ARQOS;
logic [3:0] m_axi_ff1_ARREGION;
logic [C_M_AXI_FF1_ARUSER_WIDTH - 1:0] m_axi_ff1_ARUSER;
logic m_axi_ff1_RVALID;
logic m_axi_ff1_RREADY;
logic [C_M_AXI_FF1_DATA_WIDTH - 1:0] m_axi_ff1_RDATA;
logic m_axi_ff1_RLAST;
logic [C_M_AXI_FF1_ID_WIDTH - 1:0] m_axi_ff1_RID;
logic [C_M_AXI_FF1_RUSER_WIDTH - 1:0] m_axi_ff1_RUSER;
logic [1:0] m_axi_ff1_RRESP;
logic m_axi_ff1_BVALID;
logic m_axi_ff1_BREADY;
logic [1:0] m_axi_ff1_BRESP;
logic [C_M_AXI_FF1_ID_WIDTH - 1:0] m_axi_ff1_BID;
logic [C_M_AXI_FF1_BUSER_WIDTH - 1:0] m_axi_ff1_BUSER;
logic m_axi_att_out_AWVALID;
logic m_axi_att_out_AWREADY;
logic [C_M_AXI_ATT_OUT_ADDR_WIDTH - 1:0] m_axi_att_out_AWADDR;
logic [C_M_AXI_ATT_OUT_ID_WIDTH - 1:0] m_axi_att_out_AWID;
logic [7:0] m_axi_att_out_AWLEN;
logic [2:0] m_axi_att_out_AWSIZE;
logic [1:0] m_axi_att_out_AWBURST;
logic [1:0] m_axi_att_out_AWLOCK;
logic [3:0] m_axi_att_out_AWCACHE;
logic [2:0] m_axi_att_out_AWPROT;
logic [3:0] m_axi_att_out_AWQOS;
logic [3:0] m_axi_att_out_AWREGION;
logic [C_M_AXI_ATT_OUT_AWUSER_WIDTH - 1:0] m_axi_att_out_AWUSER;
logic m_axi_att_out_WVALID;
logic m_axi_att_out_WREADY;
logic [C_M_AXI_ATT_OUT_DATA_WIDTH - 1:0] m_axi_att_out_WDATA;
logic [C_M_AXI_ATT_OUT_WSTRB_WIDTH - 1:0] m_axi_att_out_WSTRB;
logic m_axi_att_out_WLAST;
logic [C_M_AXI_ATT_OUT_ID_WIDTH - 1:0] m_axi_att_out_WID;
logic [C_M_AXI_ATT_OUT_WUSER_WIDTH - 1:0] m_axi_att_out_WUSER;
logic m_axi_att_out_ARVALID;
logic m_axi_att_out_ARREADY;
logic [C_M_AXI_ATT_OUT_ADDR_WIDTH - 1:0] m_axi_att_out_ARADDR;
logic [C_M_AXI_ATT_OUT_ID_WIDTH - 1:0] m_axi_att_out_ARID;
logic [7:0] m_axi_att_out_ARLEN;
logic [2:0] m_axi_att_out_ARSIZE;
logic [1:0] m_axi_att_out_ARBURST;
logic [1:0] m_axi_att_out_ARLOCK;
logic [3:0] m_axi_att_out_ARCACHE;
logic [2:0] m_axi_att_out_ARPROT;
logic [3:0] m_axi_att_out_ARQOS;
logic [3:0] m_axi_att_out_ARREGION;
logic [C_M_AXI_ATT_OUT_ARUSER_WIDTH - 1:0] m_axi_att_out_ARUSER;
logic m_axi_att_out_RVALID;
logic m_axi_att_out_RREADY;
logic [C_M_AXI_ATT_OUT_DATA_WIDTH - 1:0] m_axi_att_out_RDATA;
logic m_axi_att_out_RLAST;
logic [C_M_AXI_ATT_OUT_ID_WIDTH - 1:0] m_axi_att_out_RID;
logic [C_M_AXI_ATT_OUT_RUSER_WIDTH - 1:0] m_axi_att_out_RUSER;
logic [1:0] m_axi_att_out_RRESP;
logic m_axi_att_out_BVALID;
logic m_axi_att_out_BREADY;
logic [1:0] m_axi_att_out_BRESP;
logic [C_M_AXI_ATT_OUT_ID_WIDTH - 1:0] m_axi_att_out_BID;
logic [C_M_AXI_ATT_OUT_BUSER_WIDTH - 1:0] m_axi_att_out_BUSER;
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
logic launch = 0, aw_sent = 0, w_sent = 0;
integer cycles = 0;
initial ap_clk = 0;
always #3.333 ap_clk = ~ap_clk;
initial begin
  ap_rst_n = 0;
  if (!front_mem_init()) $fatal(1, "front memory setup");
  repeat (20) @(negedge ap_clk);
  ap_rst_n = 1;
  repeat (5) @(negedge ap_clk);
  launch = 1;
end
always @(posedge ap_clk) begin
  if (ap_rst_n) begin
    if (s_axi_control_AWVALID && s_axi_control_AWREADY) aw_sent <= 1;
    if (s_axi_control_WVALID && s_axi_control_WREADY) w_sent <= 1;
    cycles <= cycles + 1;
    if ((cycles % 8192) == 0 && cycles != 0)
      $display("FRONT_PROGRESS cycles=%0d norm_bytes=%0d accepted=%0d", cycles, front_mem_seen(), front_mem_progress());
    if ((cycles % 1024) == 0) begin
      if (front_mem_errors() != 0) $fatal(1, "AXI memory error");
      if (front_mem_result_status() >= 0)
        $fatal(1, "full top committed before front chain completed");
      if (front_mem_consumed()) begin
        if (!front_mem_check()) $fatal(1, "embedding_norm oracle mismatch");
        $display("FRONT_CHAIN_RTL_PASS cycles=%0d", cycles);
        $finish;
      end
    end
    if (cycles >= 40000000) $fatal(1, "40M cycle cap");
  end
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
assign s_axi_control_r_AWVALID = 0;
assign s_axi_control_r_AWADDR = 0;
assign s_axi_control_r_WVALID = 0;
assign s_axi_control_r_WDATA = 0;
assign s_axi_control_r_WSTRB = 0;
assign s_axi_control_r_BREADY = 1;
assign s_axi_control_r_ARVALID = 0;
assign s_axi_control_r_ARADDR = 0;
assign s_axi_control_r_RREADY = 1;
laya_typed_q8_forward dut(
  .ap_clk(ap_clk),
  .ap_rst_n(ap_rst_n),
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
  .m_axi_w_q0_AWVALID(m_axi_w_q0_AWVALID),
  .m_axi_w_q0_AWREADY(m_axi_w_q0_AWREADY),
  .m_axi_w_q0_AWADDR(m_axi_w_q0_AWADDR),
  .m_axi_w_q0_AWID(m_axi_w_q0_AWID),
  .m_axi_w_q0_AWLEN(m_axi_w_q0_AWLEN),
  .m_axi_w_q0_AWSIZE(m_axi_w_q0_AWSIZE),
  .m_axi_w_q0_AWBURST(m_axi_w_q0_AWBURST),
  .m_axi_w_q0_AWLOCK(m_axi_w_q0_AWLOCK),
  .m_axi_w_q0_AWCACHE(m_axi_w_q0_AWCACHE),
  .m_axi_w_q0_AWPROT(m_axi_w_q0_AWPROT),
  .m_axi_w_q0_AWQOS(m_axi_w_q0_AWQOS),
  .m_axi_w_q0_AWREGION(m_axi_w_q0_AWREGION),
  .m_axi_w_q0_AWUSER(m_axi_w_q0_AWUSER),
  .m_axi_w_q0_WVALID(m_axi_w_q0_WVALID),
  .m_axi_w_q0_WREADY(m_axi_w_q0_WREADY),
  .m_axi_w_q0_WDATA(m_axi_w_q0_WDATA),
  .m_axi_w_q0_WSTRB(m_axi_w_q0_WSTRB),
  .m_axi_w_q0_WLAST(m_axi_w_q0_WLAST),
  .m_axi_w_q0_WID(m_axi_w_q0_WID),
  .m_axi_w_q0_WUSER(m_axi_w_q0_WUSER),
  .m_axi_w_q0_ARVALID(m_axi_w_q0_ARVALID),
  .m_axi_w_q0_ARREADY(m_axi_w_q0_ARREADY),
  .m_axi_w_q0_ARADDR(m_axi_w_q0_ARADDR),
  .m_axi_w_q0_ARID(m_axi_w_q0_ARID),
  .m_axi_w_q0_ARLEN(m_axi_w_q0_ARLEN),
  .m_axi_w_q0_ARSIZE(m_axi_w_q0_ARSIZE),
  .m_axi_w_q0_ARBURST(m_axi_w_q0_ARBURST),
  .m_axi_w_q0_ARLOCK(m_axi_w_q0_ARLOCK),
  .m_axi_w_q0_ARCACHE(m_axi_w_q0_ARCACHE),
  .m_axi_w_q0_ARPROT(m_axi_w_q0_ARPROT),
  .m_axi_w_q0_ARQOS(m_axi_w_q0_ARQOS),
  .m_axi_w_q0_ARREGION(m_axi_w_q0_ARREGION),
  .m_axi_w_q0_ARUSER(m_axi_w_q0_ARUSER),
  .m_axi_w_q0_RVALID(m_axi_w_q0_RVALID),
  .m_axi_w_q0_RREADY(m_axi_w_q0_RREADY),
  .m_axi_w_q0_RDATA(m_axi_w_q0_RDATA),
  .m_axi_w_q0_RLAST(m_axi_w_q0_RLAST),
  .m_axi_w_q0_RID(m_axi_w_q0_RID),
  .m_axi_w_q0_RUSER(m_axi_w_q0_RUSER),
  .m_axi_w_q0_RRESP(m_axi_w_q0_RRESP),
  .m_axi_w_q0_BVALID(m_axi_w_q0_BVALID),
  .m_axi_w_q0_BREADY(m_axi_w_q0_BREADY),
  .m_axi_w_q0_BRESP(m_axi_w_q0_BRESP),
  .m_axi_w_q0_BID(m_axi_w_q0_BID),
  .m_axi_w_q0_BUSER(m_axi_w_q0_BUSER),
  .m_axi_w_q1_AWVALID(m_axi_w_q1_AWVALID),
  .m_axi_w_q1_AWREADY(m_axi_w_q1_AWREADY),
  .m_axi_w_q1_AWADDR(m_axi_w_q1_AWADDR),
  .m_axi_w_q1_AWID(m_axi_w_q1_AWID),
  .m_axi_w_q1_AWLEN(m_axi_w_q1_AWLEN),
  .m_axi_w_q1_AWSIZE(m_axi_w_q1_AWSIZE),
  .m_axi_w_q1_AWBURST(m_axi_w_q1_AWBURST),
  .m_axi_w_q1_AWLOCK(m_axi_w_q1_AWLOCK),
  .m_axi_w_q1_AWCACHE(m_axi_w_q1_AWCACHE),
  .m_axi_w_q1_AWPROT(m_axi_w_q1_AWPROT),
  .m_axi_w_q1_AWQOS(m_axi_w_q1_AWQOS),
  .m_axi_w_q1_AWREGION(m_axi_w_q1_AWREGION),
  .m_axi_w_q1_AWUSER(m_axi_w_q1_AWUSER),
  .m_axi_w_q1_WVALID(m_axi_w_q1_WVALID),
  .m_axi_w_q1_WREADY(m_axi_w_q1_WREADY),
  .m_axi_w_q1_WDATA(m_axi_w_q1_WDATA),
  .m_axi_w_q1_WSTRB(m_axi_w_q1_WSTRB),
  .m_axi_w_q1_WLAST(m_axi_w_q1_WLAST),
  .m_axi_w_q1_WID(m_axi_w_q1_WID),
  .m_axi_w_q1_WUSER(m_axi_w_q1_WUSER),
  .m_axi_w_q1_ARVALID(m_axi_w_q1_ARVALID),
  .m_axi_w_q1_ARREADY(m_axi_w_q1_ARREADY),
  .m_axi_w_q1_ARADDR(m_axi_w_q1_ARADDR),
  .m_axi_w_q1_ARID(m_axi_w_q1_ARID),
  .m_axi_w_q1_ARLEN(m_axi_w_q1_ARLEN),
  .m_axi_w_q1_ARSIZE(m_axi_w_q1_ARSIZE),
  .m_axi_w_q1_ARBURST(m_axi_w_q1_ARBURST),
  .m_axi_w_q1_ARLOCK(m_axi_w_q1_ARLOCK),
  .m_axi_w_q1_ARCACHE(m_axi_w_q1_ARCACHE),
  .m_axi_w_q1_ARPROT(m_axi_w_q1_ARPROT),
  .m_axi_w_q1_ARQOS(m_axi_w_q1_ARQOS),
  .m_axi_w_q1_ARREGION(m_axi_w_q1_ARREGION),
  .m_axi_w_q1_ARUSER(m_axi_w_q1_ARUSER),
  .m_axi_w_q1_RVALID(m_axi_w_q1_RVALID),
  .m_axi_w_q1_RREADY(m_axi_w_q1_RREADY),
  .m_axi_w_q1_RDATA(m_axi_w_q1_RDATA),
  .m_axi_w_q1_RLAST(m_axi_w_q1_RLAST),
  .m_axi_w_q1_RID(m_axi_w_q1_RID),
  .m_axi_w_q1_RUSER(m_axi_w_q1_RUSER),
  .m_axi_w_q1_RRESP(m_axi_w_q1_RRESP),
  .m_axi_w_q1_BVALID(m_axi_w_q1_BVALID),
  .m_axi_w_q1_BREADY(m_axi_w_q1_BREADY),
  .m_axi_w_q1_BRESP(m_axi_w_q1_BRESP),
  .m_axi_w_q1_BID(m_axi_w_q1_BID),
  .m_axi_w_q1_BUSER(m_axi_w_q1_BUSER),
  .m_axi_w_scale_AWVALID(m_axi_w_scale_AWVALID),
  .m_axi_w_scale_AWREADY(m_axi_w_scale_AWREADY),
  .m_axi_w_scale_AWADDR(m_axi_w_scale_AWADDR),
  .m_axi_w_scale_AWID(m_axi_w_scale_AWID),
  .m_axi_w_scale_AWLEN(m_axi_w_scale_AWLEN),
  .m_axi_w_scale_AWSIZE(m_axi_w_scale_AWSIZE),
  .m_axi_w_scale_AWBURST(m_axi_w_scale_AWBURST),
  .m_axi_w_scale_AWLOCK(m_axi_w_scale_AWLOCK),
  .m_axi_w_scale_AWCACHE(m_axi_w_scale_AWCACHE),
  .m_axi_w_scale_AWPROT(m_axi_w_scale_AWPROT),
  .m_axi_w_scale_AWQOS(m_axi_w_scale_AWQOS),
  .m_axi_w_scale_AWREGION(m_axi_w_scale_AWREGION),
  .m_axi_w_scale_AWUSER(m_axi_w_scale_AWUSER),
  .m_axi_w_scale_WVALID(m_axi_w_scale_WVALID),
  .m_axi_w_scale_WREADY(m_axi_w_scale_WREADY),
  .m_axi_w_scale_WDATA(m_axi_w_scale_WDATA),
  .m_axi_w_scale_WSTRB(m_axi_w_scale_WSTRB),
  .m_axi_w_scale_WLAST(m_axi_w_scale_WLAST),
  .m_axi_w_scale_WID(m_axi_w_scale_WID),
  .m_axi_w_scale_WUSER(m_axi_w_scale_WUSER),
  .m_axi_w_scale_ARVALID(m_axi_w_scale_ARVALID),
  .m_axi_w_scale_ARREADY(m_axi_w_scale_ARREADY),
  .m_axi_w_scale_ARADDR(m_axi_w_scale_ARADDR),
  .m_axi_w_scale_ARID(m_axi_w_scale_ARID),
  .m_axi_w_scale_ARLEN(m_axi_w_scale_ARLEN),
  .m_axi_w_scale_ARSIZE(m_axi_w_scale_ARSIZE),
  .m_axi_w_scale_ARBURST(m_axi_w_scale_ARBURST),
  .m_axi_w_scale_ARLOCK(m_axi_w_scale_ARLOCK),
  .m_axi_w_scale_ARCACHE(m_axi_w_scale_ARCACHE),
  .m_axi_w_scale_ARPROT(m_axi_w_scale_ARPROT),
  .m_axi_w_scale_ARQOS(m_axi_w_scale_ARQOS),
  .m_axi_w_scale_ARREGION(m_axi_w_scale_ARREGION),
  .m_axi_w_scale_ARUSER(m_axi_w_scale_ARUSER),
  .m_axi_w_scale_RVALID(m_axi_w_scale_RVALID),
  .m_axi_w_scale_RREADY(m_axi_w_scale_RREADY),
  .m_axi_w_scale_RDATA(m_axi_w_scale_RDATA),
  .m_axi_w_scale_RLAST(m_axi_w_scale_RLAST),
  .m_axi_w_scale_RID(m_axi_w_scale_RID),
  .m_axi_w_scale_RUSER(m_axi_w_scale_RUSER),
  .m_axi_w_scale_RRESP(m_axi_w_scale_RRESP),
  .m_axi_w_scale_BVALID(m_axi_w_scale_BVALID),
  .m_axi_w_scale_BREADY(m_axi_w_scale_BREADY),
  .m_axi_w_scale_BRESP(m_axi_w_scale_BRESP),
  .m_axi_w_scale_BID(m_axi_w_scale_BID),
  .m_axi_w_scale_BUSER(m_axi_w_scale_BUSER),
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
  .m_axi_qkv0_AWVALID(m_axi_qkv0_AWVALID),
  .m_axi_qkv0_AWREADY(m_axi_qkv0_AWREADY),
  .m_axi_qkv0_AWADDR(m_axi_qkv0_AWADDR),
  .m_axi_qkv0_AWID(m_axi_qkv0_AWID),
  .m_axi_qkv0_AWLEN(m_axi_qkv0_AWLEN),
  .m_axi_qkv0_AWSIZE(m_axi_qkv0_AWSIZE),
  .m_axi_qkv0_AWBURST(m_axi_qkv0_AWBURST),
  .m_axi_qkv0_AWLOCK(m_axi_qkv0_AWLOCK),
  .m_axi_qkv0_AWCACHE(m_axi_qkv0_AWCACHE),
  .m_axi_qkv0_AWPROT(m_axi_qkv0_AWPROT),
  .m_axi_qkv0_AWQOS(m_axi_qkv0_AWQOS),
  .m_axi_qkv0_AWREGION(m_axi_qkv0_AWREGION),
  .m_axi_qkv0_AWUSER(m_axi_qkv0_AWUSER),
  .m_axi_qkv0_WVALID(m_axi_qkv0_WVALID),
  .m_axi_qkv0_WREADY(m_axi_qkv0_WREADY),
  .m_axi_qkv0_WDATA(m_axi_qkv0_WDATA),
  .m_axi_qkv0_WSTRB(m_axi_qkv0_WSTRB),
  .m_axi_qkv0_WLAST(m_axi_qkv0_WLAST),
  .m_axi_qkv0_WID(m_axi_qkv0_WID),
  .m_axi_qkv0_WUSER(m_axi_qkv0_WUSER),
  .m_axi_qkv0_ARVALID(m_axi_qkv0_ARVALID),
  .m_axi_qkv0_ARREADY(m_axi_qkv0_ARREADY),
  .m_axi_qkv0_ARADDR(m_axi_qkv0_ARADDR),
  .m_axi_qkv0_ARID(m_axi_qkv0_ARID),
  .m_axi_qkv0_ARLEN(m_axi_qkv0_ARLEN),
  .m_axi_qkv0_ARSIZE(m_axi_qkv0_ARSIZE),
  .m_axi_qkv0_ARBURST(m_axi_qkv0_ARBURST),
  .m_axi_qkv0_ARLOCK(m_axi_qkv0_ARLOCK),
  .m_axi_qkv0_ARCACHE(m_axi_qkv0_ARCACHE),
  .m_axi_qkv0_ARPROT(m_axi_qkv0_ARPROT),
  .m_axi_qkv0_ARQOS(m_axi_qkv0_ARQOS),
  .m_axi_qkv0_ARREGION(m_axi_qkv0_ARREGION),
  .m_axi_qkv0_ARUSER(m_axi_qkv0_ARUSER),
  .m_axi_qkv0_RVALID(m_axi_qkv0_RVALID),
  .m_axi_qkv0_RREADY(m_axi_qkv0_RREADY),
  .m_axi_qkv0_RDATA(m_axi_qkv0_RDATA),
  .m_axi_qkv0_RLAST(m_axi_qkv0_RLAST),
  .m_axi_qkv0_RID(m_axi_qkv0_RID),
  .m_axi_qkv0_RUSER(m_axi_qkv0_RUSER),
  .m_axi_qkv0_RRESP(m_axi_qkv0_RRESP),
  .m_axi_qkv0_BVALID(m_axi_qkv0_BVALID),
  .m_axi_qkv0_BREADY(m_axi_qkv0_BREADY),
  .m_axi_qkv0_BRESP(m_axi_qkv0_BRESP),
  .m_axi_qkv0_BID(m_axi_qkv0_BID),
  .m_axi_qkv0_BUSER(m_axi_qkv0_BUSER),
  .m_axi_qkv1_AWVALID(m_axi_qkv1_AWVALID),
  .m_axi_qkv1_AWREADY(m_axi_qkv1_AWREADY),
  .m_axi_qkv1_AWADDR(m_axi_qkv1_AWADDR),
  .m_axi_qkv1_AWID(m_axi_qkv1_AWID),
  .m_axi_qkv1_AWLEN(m_axi_qkv1_AWLEN),
  .m_axi_qkv1_AWSIZE(m_axi_qkv1_AWSIZE),
  .m_axi_qkv1_AWBURST(m_axi_qkv1_AWBURST),
  .m_axi_qkv1_AWLOCK(m_axi_qkv1_AWLOCK),
  .m_axi_qkv1_AWCACHE(m_axi_qkv1_AWCACHE),
  .m_axi_qkv1_AWPROT(m_axi_qkv1_AWPROT),
  .m_axi_qkv1_AWQOS(m_axi_qkv1_AWQOS),
  .m_axi_qkv1_AWREGION(m_axi_qkv1_AWREGION),
  .m_axi_qkv1_AWUSER(m_axi_qkv1_AWUSER),
  .m_axi_qkv1_WVALID(m_axi_qkv1_WVALID),
  .m_axi_qkv1_WREADY(m_axi_qkv1_WREADY),
  .m_axi_qkv1_WDATA(m_axi_qkv1_WDATA),
  .m_axi_qkv1_WSTRB(m_axi_qkv1_WSTRB),
  .m_axi_qkv1_WLAST(m_axi_qkv1_WLAST),
  .m_axi_qkv1_WID(m_axi_qkv1_WID),
  .m_axi_qkv1_WUSER(m_axi_qkv1_WUSER),
  .m_axi_qkv1_ARVALID(m_axi_qkv1_ARVALID),
  .m_axi_qkv1_ARREADY(m_axi_qkv1_ARREADY),
  .m_axi_qkv1_ARADDR(m_axi_qkv1_ARADDR),
  .m_axi_qkv1_ARID(m_axi_qkv1_ARID),
  .m_axi_qkv1_ARLEN(m_axi_qkv1_ARLEN),
  .m_axi_qkv1_ARSIZE(m_axi_qkv1_ARSIZE),
  .m_axi_qkv1_ARBURST(m_axi_qkv1_ARBURST),
  .m_axi_qkv1_ARLOCK(m_axi_qkv1_ARLOCK),
  .m_axi_qkv1_ARCACHE(m_axi_qkv1_ARCACHE),
  .m_axi_qkv1_ARPROT(m_axi_qkv1_ARPROT),
  .m_axi_qkv1_ARQOS(m_axi_qkv1_ARQOS),
  .m_axi_qkv1_ARREGION(m_axi_qkv1_ARREGION),
  .m_axi_qkv1_ARUSER(m_axi_qkv1_ARUSER),
  .m_axi_qkv1_RVALID(m_axi_qkv1_RVALID),
  .m_axi_qkv1_RREADY(m_axi_qkv1_RREADY),
  .m_axi_qkv1_RDATA(m_axi_qkv1_RDATA),
  .m_axi_qkv1_RLAST(m_axi_qkv1_RLAST),
  .m_axi_qkv1_RID(m_axi_qkv1_RID),
  .m_axi_qkv1_RUSER(m_axi_qkv1_RUSER),
  .m_axi_qkv1_RRESP(m_axi_qkv1_RRESP),
  .m_axi_qkv1_BVALID(m_axi_qkv1_BVALID),
  .m_axi_qkv1_BREADY(m_axi_qkv1_BREADY),
  .m_axi_qkv1_BRESP(m_axi_qkv1_BRESP),
  .m_axi_qkv1_BID(m_axi_qkv1_BID),
  .m_axi_qkv1_BUSER(m_axi_qkv1_BUSER),
  .m_axi_ff0_AWVALID(m_axi_ff0_AWVALID),
  .m_axi_ff0_AWREADY(m_axi_ff0_AWREADY),
  .m_axi_ff0_AWADDR(m_axi_ff0_AWADDR),
  .m_axi_ff0_AWID(m_axi_ff0_AWID),
  .m_axi_ff0_AWLEN(m_axi_ff0_AWLEN),
  .m_axi_ff0_AWSIZE(m_axi_ff0_AWSIZE),
  .m_axi_ff0_AWBURST(m_axi_ff0_AWBURST),
  .m_axi_ff0_AWLOCK(m_axi_ff0_AWLOCK),
  .m_axi_ff0_AWCACHE(m_axi_ff0_AWCACHE),
  .m_axi_ff0_AWPROT(m_axi_ff0_AWPROT),
  .m_axi_ff0_AWQOS(m_axi_ff0_AWQOS),
  .m_axi_ff0_AWREGION(m_axi_ff0_AWREGION),
  .m_axi_ff0_AWUSER(m_axi_ff0_AWUSER),
  .m_axi_ff0_WVALID(m_axi_ff0_WVALID),
  .m_axi_ff0_WREADY(m_axi_ff0_WREADY),
  .m_axi_ff0_WDATA(m_axi_ff0_WDATA),
  .m_axi_ff0_WSTRB(m_axi_ff0_WSTRB),
  .m_axi_ff0_WLAST(m_axi_ff0_WLAST),
  .m_axi_ff0_WID(m_axi_ff0_WID),
  .m_axi_ff0_WUSER(m_axi_ff0_WUSER),
  .m_axi_ff0_ARVALID(m_axi_ff0_ARVALID),
  .m_axi_ff0_ARREADY(m_axi_ff0_ARREADY),
  .m_axi_ff0_ARADDR(m_axi_ff0_ARADDR),
  .m_axi_ff0_ARID(m_axi_ff0_ARID),
  .m_axi_ff0_ARLEN(m_axi_ff0_ARLEN),
  .m_axi_ff0_ARSIZE(m_axi_ff0_ARSIZE),
  .m_axi_ff0_ARBURST(m_axi_ff0_ARBURST),
  .m_axi_ff0_ARLOCK(m_axi_ff0_ARLOCK),
  .m_axi_ff0_ARCACHE(m_axi_ff0_ARCACHE),
  .m_axi_ff0_ARPROT(m_axi_ff0_ARPROT),
  .m_axi_ff0_ARQOS(m_axi_ff0_ARQOS),
  .m_axi_ff0_ARREGION(m_axi_ff0_ARREGION),
  .m_axi_ff0_ARUSER(m_axi_ff0_ARUSER),
  .m_axi_ff0_RVALID(m_axi_ff0_RVALID),
  .m_axi_ff0_RREADY(m_axi_ff0_RREADY),
  .m_axi_ff0_RDATA(m_axi_ff0_RDATA),
  .m_axi_ff0_RLAST(m_axi_ff0_RLAST),
  .m_axi_ff0_RID(m_axi_ff0_RID),
  .m_axi_ff0_RUSER(m_axi_ff0_RUSER),
  .m_axi_ff0_RRESP(m_axi_ff0_RRESP),
  .m_axi_ff0_BVALID(m_axi_ff0_BVALID),
  .m_axi_ff0_BREADY(m_axi_ff0_BREADY),
  .m_axi_ff0_BRESP(m_axi_ff0_BRESP),
  .m_axi_ff0_BID(m_axi_ff0_BID),
  .m_axi_ff0_BUSER(m_axi_ff0_BUSER),
  .m_axi_ff1_AWVALID(m_axi_ff1_AWVALID),
  .m_axi_ff1_AWREADY(m_axi_ff1_AWREADY),
  .m_axi_ff1_AWADDR(m_axi_ff1_AWADDR),
  .m_axi_ff1_AWID(m_axi_ff1_AWID),
  .m_axi_ff1_AWLEN(m_axi_ff1_AWLEN),
  .m_axi_ff1_AWSIZE(m_axi_ff1_AWSIZE),
  .m_axi_ff1_AWBURST(m_axi_ff1_AWBURST),
  .m_axi_ff1_AWLOCK(m_axi_ff1_AWLOCK),
  .m_axi_ff1_AWCACHE(m_axi_ff1_AWCACHE),
  .m_axi_ff1_AWPROT(m_axi_ff1_AWPROT),
  .m_axi_ff1_AWQOS(m_axi_ff1_AWQOS),
  .m_axi_ff1_AWREGION(m_axi_ff1_AWREGION),
  .m_axi_ff1_AWUSER(m_axi_ff1_AWUSER),
  .m_axi_ff1_WVALID(m_axi_ff1_WVALID),
  .m_axi_ff1_WREADY(m_axi_ff1_WREADY),
  .m_axi_ff1_WDATA(m_axi_ff1_WDATA),
  .m_axi_ff1_WSTRB(m_axi_ff1_WSTRB),
  .m_axi_ff1_WLAST(m_axi_ff1_WLAST),
  .m_axi_ff1_WID(m_axi_ff1_WID),
  .m_axi_ff1_WUSER(m_axi_ff1_WUSER),
  .m_axi_ff1_ARVALID(m_axi_ff1_ARVALID),
  .m_axi_ff1_ARREADY(m_axi_ff1_ARREADY),
  .m_axi_ff1_ARADDR(m_axi_ff1_ARADDR),
  .m_axi_ff1_ARID(m_axi_ff1_ARID),
  .m_axi_ff1_ARLEN(m_axi_ff1_ARLEN),
  .m_axi_ff1_ARSIZE(m_axi_ff1_ARSIZE),
  .m_axi_ff1_ARBURST(m_axi_ff1_ARBURST),
  .m_axi_ff1_ARLOCK(m_axi_ff1_ARLOCK),
  .m_axi_ff1_ARCACHE(m_axi_ff1_ARCACHE),
  .m_axi_ff1_ARPROT(m_axi_ff1_ARPROT),
  .m_axi_ff1_ARQOS(m_axi_ff1_ARQOS),
  .m_axi_ff1_ARREGION(m_axi_ff1_ARREGION),
  .m_axi_ff1_ARUSER(m_axi_ff1_ARUSER),
  .m_axi_ff1_RVALID(m_axi_ff1_RVALID),
  .m_axi_ff1_RREADY(m_axi_ff1_RREADY),
  .m_axi_ff1_RDATA(m_axi_ff1_RDATA),
  .m_axi_ff1_RLAST(m_axi_ff1_RLAST),
  .m_axi_ff1_RID(m_axi_ff1_RID),
  .m_axi_ff1_RUSER(m_axi_ff1_RUSER),
  .m_axi_ff1_RRESP(m_axi_ff1_RRESP),
  .m_axi_ff1_BVALID(m_axi_ff1_BVALID),
  .m_axi_ff1_BREADY(m_axi_ff1_BREADY),
  .m_axi_ff1_BRESP(m_axi_ff1_BRESP),
  .m_axi_ff1_BID(m_axi_ff1_BID),
  .m_axi_ff1_BUSER(m_axi_ff1_BUSER),
  .m_axi_att_out_AWVALID(m_axi_att_out_AWVALID),
  .m_axi_att_out_AWREADY(m_axi_att_out_AWREADY),
  .m_axi_att_out_AWADDR(m_axi_att_out_AWADDR),
  .m_axi_att_out_AWID(m_axi_att_out_AWID),
  .m_axi_att_out_AWLEN(m_axi_att_out_AWLEN),
  .m_axi_att_out_AWSIZE(m_axi_att_out_AWSIZE),
  .m_axi_att_out_AWBURST(m_axi_att_out_AWBURST),
  .m_axi_att_out_AWLOCK(m_axi_att_out_AWLOCK),
  .m_axi_att_out_AWCACHE(m_axi_att_out_AWCACHE),
  .m_axi_att_out_AWPROT(m_axi_att_out_AWPROT),
  .m_axi_att_out_AWQOS(m_axi_att_out_AWQOS),
  .m_axi_att_out_AWREGION(m_axi_att_out_AWREGION),
  .m_axi_att_out_AWUSER(m_axi_att_out_AWUSER),
  .m_axi_att_out_WVALID(m_axi_att_out_WVALID),
  .m_axi_att_out_WREADY(m_axi_att_out_WREADY),
  .m_axi_att_out_WDATA(m_axi_att_out_WDATA),
  .m_axi_att_out_WSTRB(m_axi_att_out_WSTRB),
  .m_axi_att_out_WLAST(m_axi_att_out_WLAST),
  .m_axi_att_out_WID(m_axi_att_out_WID),
  .m_axi_att_out_WUSER(m_axi_att_out_WUSER),
  .m_axi_att_out_ARVALID(m_axi_att_out_ARVALID),
  .m_axi_att_out_ARREADY(m_axi_att_out_ARREADY),
  .m_axi_att_out_ARADDR(m_axi_att_out_ARADDR),
  .m_axi_att_out_ARID(m_axi_att_out_ARID),
  .m_axi_att_out_ARLEN(m_axi_att_out_ARLEN),
  .m_axi_att_out_ARSIZE(m_axi_att_out_ARSIZE),
  .m_axi_att_out_ARBURST(m_axi_att_out_ARBURST),
  .m_axi_att_out_ARLOCK(m_axi_att_out_ARLOCK),
  .m_axi_att_out_ARCACHE(m_axi_att_out_ARCACHE),
  .m_axi_att_out_ARPROT(m_axi_att_out_ARPROT),
  .m_axi_att_out_ARQOS(m_axi_att_out_ARQOS),
  .m_axi_att_out_ARREGION(m_axi_att_out_ARREGION),
  .m_axi_att_out_ARUSER(m_axi_att_out_ARUSER),
  .m_axi_att_out_RVALID(m_axi_att_out_RVALID),
  .m_axi_att_out_RREADY(m_axi_att_out_RREADY),
  .m_axi_att_out_RDATA(m_axi_att_out_RDATA),
  .m_axi_att_out_RLAST(m_axi_att_out_RLAST),
  .m_axi_att_out_RID(m_axi_att_out_RID),
  .m_axi_att_out_RUSER(m_axi_att_out_RUSER),
  .m_axi_att_out_RRESP(m_axi_att_out_RRESP),
  .m_axi_att_out_BVALID(m_axi_att_out_BVALID),
  .m_axi_att_out_BREADY(m_axi_att_out_BREADY),
  .m_axi_att_out_BRESP(m_axi_att_out_BRESP),
  .m_axi_att_out_BID(m_axi_att_out_BID),
  .m_axi_att_out_BUSER(m_axi_att_out_BUSER),
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
front_axi_memory #(.PORT_INDEX(0)) mem_embedding(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_embedding_AWVALID),
  .AWREADY(m_axi_embedding_AWREADY),
  .AWADDR(m_axi_embedding_AWADDR),
  .AWID(m_axi_embedding_AWID),
  .AWLEN(m_axi_embedding_AWLEN),
  .AWSIZE(m_axi_embedding_AWSIZE),
  .AWBURST(m_axi_embedding_AWBURST),
  .WVALID(m_axi_embedding_WVALID),
  .WREADY(m_axi_embedding_WREADY),
  .WDATA(m_axi_embedding_WDATA),
  .WSTRB(m_axi_embedding_WSTRB),
  .WLAST(m_axi_embedding_WLAST),
  .ARVALID(m_axi_embedding_ARVALID),
  .ARREADY(m_axi_embedding_ARREADY),
  .ARADDR(m_axi_embedding_ARADDR),
  .ARID(m_axi_embedding_ARID),
  .ARLEN(m_axi_embedding_ARLEN),
  .ARSIZE(m_axi_embedding_ARSIZE),
  .ARBURST(m_axi_embedding_ARBURST),
  .RVALID(m_axi_embedding_RVALID),
  .RREADY(m_axi_embedding_RREADY),
  .RDATA(m_axi_embedding_RDATA),
  .RLAST(m_axi_embedding_RLAST),
  .RID(m_axi_embedding_RID),
  .RRESP(m_axi_embedding_RRESP),
  .BVALID(m_axi_embedding_BVALID),
  .BREADY(m_axi_embedding_BREADY),
  .BRESP(m_axi_embedding_BRESP),
  .BID(m_axi_embedding_BID)
);
assign m_axi_embedding_RUSER = 0;
assign m_axi_embedding_BUSER = 0;
front_axi_memory #(.PORT_INDEX(1)) mem_io(
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
  .BID(m_axi_io_BID)
);
assign m_axi_io_RUSER = 0;
assign m_axi_io_BUSER = 0;
front_axi_memory #(.PORT_INDEX(2)) mem_w_q0(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_w_q0_AWVALID),
  .AWREADY(m_axi_w_q0_AWREADY),
  .AWADDR(m_axi_w_q0_AWADDR),
  .AWID(m_axi_w_q0_AWID),
  .AWLEN(m_axi_w_q0_AWLEN),
  .AWSIZE(m_axi_w_q0_AWSIZE),
  .AWBURST(m_axi_w_q0_AWBURST),
  .WVALID(m_axi_w_q0_WVALID),
  .WREADY(m_axi_w_q0_WREADY),
  .WDATA(m_axi_w_q0_WDATA),
  .WSTRB(m_axi_w_q0_WSTRB),
  .WLAST(m_axi_w_q0_WLAST),
  .ARVALID(m_axi_w_q0_ARVALID),
  .ARREADY(m_axi_w_q0_ARREADY),
  .ARADDR(m_axi_w_q0_ARADDR),
  .ARID(m_axi_w_q0_ARID),
  .ARLEN(m_axi_w_q0_ARLEN),
  .ARSIZE(m_axi_w_q0_ARSIZE),
  .ARBURST(m_axi_w_q0_ARBURST),
  .RVALID(m_axi_w_q0_RVALID),
  .RREADY(m_axi_w_q0_RREADY),
  .RDATA(m_axi_w_q0_RDATA),
  .RLAST(m_axi_w_q0_RLAST),
  .RID(m_axi_w_q0_RID),
  .RRESP(m_axi_w_q0_RRESP),
  .BVALID(m_axi_w_q0_BVALID),
  .BREADY(m_axi_w_q0_BREADY),
  .BRESP(m_axi_w_q0_BRESP),
  .BID(m_axi_w_q0_BID)
);
assign m_axi_w_q0_RUSER = 0;
assign m_axi_w_q0_BUSER = 0;
front_axi_memory #(.PORT_INDEX(3)) mem_w_q1(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_w_q1_AWVALID),
  .AWREADY(m_axi_w_q1_AWREADY),
  .AWADDR(m_axi_w_q1_AWADDR),
  .AWID(m_axi_w_q1_AWID),
  .AWLEN(m_axi_w_q1_AWLEN),
  .AWSIZE(m_axi_w_q1_AWSIZE),
  .AWBURST(m_axi_w_q1_AWBURST),
  .WVALID(m_axi_w_q1_WVALID),
  .WREADY(m_axi_w_q1_WREADY),
  .WDATA(m_axi_w_q1_WDATA),
  .WSTRB(m_axi_w_q1_WSTRB),
  .WLAST(m_axi_w_q1_WLAST),
  .ARVALID(m_axi_w_q1_ARVALID),
  .ARREADY(m_axi_w_q1_ARREADY),
  .ARADDR(m_axi_w_q1_ARADDR),
  .ARID(m_axi_w_q1_ARID),
  .ARLEN(m_axi_w_q1_ARLEN),
  .ARSIZE(m_axi_w_q1_ARSIZE),
  .ARBURST(m_axi_w_q1_ARBURST),
  .RVALID(m_axi_w_q1_RVALID),
  .RREADY(m_axi_w_q1_RREADY),
  .RDATA(m_axi_w_q1_RDATA),
  .RLAST(m_axi_w_q1_RLAST),
  .RID(m_axi_w_q1_RID),
  .RRESP(m_axi_w_q1_RRESP),
  .BVALID(m_axi_w_q1_BVALID),
  .BREADY(m_axi_w_q1_BREADY),
  .BRESP(m_axi_w_q1_BRESP),
  .BID(m_axi_w_q1_BID)
);
assign m_axi_w_q1_RUSER = 0;
assign m_axi_w_q1_BUSER = 0;
front_axi_memory #(.PORT_INDEX(4)) mem_w_scale(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_w_scale_AWVALID),
  .AWREADY(m_axi_w_scale_AWREADY),
  .AWADDR(m_axi_w_scale_AWADDR),
  .AWID(m_axi_w_scale_AWID),
  .AWLEN(m_axi_w_scale_AWLEN),
  .AWSIZE(m_axi_w_scale_AWSIZE),
  .AWBURST(m_axi_w_scale_AWBURST),
  .WVALID(m_axi_w_scale_WVALID),
  .WREADY(m_axi_w_scale_WREADY),
  .WDATA(m_axi_w_scale_WDATA),
  .WSTRB(m_axi_w_scale_WSTRB),
  .WLAST(m_axi_w_scale_WLAST),
  .ARVALID(m_axi_w_scale_ARVALID),
  .ARREADY(m_axi_w_scale_ARREADY),
  .ARADDR(m_axi_w_scale_ARADDR),
  .ARID(m_axi_w_scale_ARID),
  .ARLEN(m_axi_w_scale_ARLEN),
  .ARSIZE(m_axi_w_scale_ARSIZE),
  .ARBURST(m_axi_w_scale_ARBURST),
  .RVALID(m_axi_w_scale_RVALID),
  .RREADY(m_axi_w_scale_RREADY),
  .RDATA(m_axi_w_scale_RDATA),
  .RLAST(m_axi_w_scale_RLAST),
  .RID(m_axi_w_scale_RID),
  .RRESP(m_axi_w_scale_RRESP),
  .BVALID(m_axi_w_scale_BVALID),
  .BREADY(m_axi_w_scale_BREADY),
  .BRESP(m_axi_w_scale_BRESP),
  .BID(m_axi_w_scale_BID)
);
assign m_axi_w_scale_RUSER = 0;
assign m_axi_w_scale_BUSER = 0;
front_axi_memory #(.PORT_INDEX(5)) mem_aux(
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
  .BID(m_axi_aux_BID)
);
assign m_axi_aux_RUSER = 0;
assign m_axi_aux_BUSER = 0;
front_axi_memory #(.PORT_INDEX(6)) mem_state0(
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
  .BID(m_axi_state0_BID)
);
assign m_axi_state0_RUSER = 0;
assign m_axi_state0_BUSER = 0;
front_axi_memory #(.PORT_INDEX(7)) mem_state1(
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
  .BID(m_axi_state1_BID)
);
assign m_axi_state1_RUSER = 0;
assign m_axi_state1_BUSER = 0;
front_axi_memory #(.PORT_INDEX(8)) mem_qkv0(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_qkv0_AWVALID),
  .AWREADY(m_axi_qkv0_AWREADY),
  .AWADDR(m_axi_qkv0_AWADDR),
  .AWID(m_axi_qkv0_AWID),
  .AWLEN(m_axi_qkv0_AWLEN),
  .AWSIZE(m_axi_qkv0_AWSIZE),
  .AWBURST(m_axi_qkv0_AWBURST),
  .WVALID(m_axi_qkv0_WVALID),
  .WREADY(m_axi_qkv0_WREADY),
  .WDATA(m_axi_qkv0_WDATA),
  .WSTRB(m_axi_qkv0_WSTRB),
  .WLAST(m_axi_qkv0_WLAST),
  .ARVALID(m_axi_qkv0_ARVALID),
  .ARREADY(m_axi_qkv0_ARREADY),
  .ARADDR(m_axi_qkv0_ARADDR),
  .ARID(m_axi_qkv0_ARID),
  .ARLEN(m_axi_qkv0_ARLEN),
  .ARSIZE(m_axi_qkv0_ARSIZE),
  .ARBURST(m_axi_qkv0_ARBURST),
  .RVALID(m_axi_qkv0_RVALID),
  .RREADY(m_axi_qkv0_RREADY),
  .RDATA(m_axi_qkv0_RDATA),
  .RLAST(m_axi_qkv0_RLAST),
  .RID(m_axi_qkv0_RID),
  .RRESP(m_axi_qkv0_RRESP),
  .BVALID(m_axi_qkv0_BVALID),
  .BREADY(m_axi_qkv0_BREADY),
  .BRESP(m_axi_qkv0_BRESP),
  .BID(m_axi_qkv0_BID)
);
assign m_axi_qkv0_RUSER = 0;
assign m_axi_qkv0_BUSER = 0;
front_axi_memory #(.PORT_INDEX(9)) mem_qkv1(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_qkv1_AWVALID),
  .AWREADY(m_axi_qkv1_AWREADY),
  .AWADDR(m_axi_qkv1_AWADDR),
  .AWID(m_axi_qkv1_AWID),
  .AWLEN(m_axi_qkv1_AWLEN),
  .AWSIZE(m_axi_qkv1_AWSIZE),
  .AWBURST(m_axi_qkv1_AWBURST),
  .WVALID(m_axi_qkv1_WVALID),
  .WREADY(m_axi_qkv1_WREADY),
  .WDATA(m_axi_qkv1_WDATA),
  .WSTRB(m_axi_qkv1_WSTRB),
  .WLAST(m_axi_qkv1_WLAST),
  .ARVALID(m_axi_qkv1_ARVALID),
  .ARREADY(m_axi_qkv1_ARREADY),
  .ARADDR(m_axi_qkv1_ARADDR),
  .ARID(m_axi_qkv1_ARID),
  .ARLEN(m_axi_qkv1_ARLEN),
  .ARSIZE(m_axi_qkv1_ARSIZE),
  .ARBURST(m_axi_qkv1_ARBURST),
  .RVALID(m_axi_qkv1_RVALID),
  .RREADY(m_axi_qkv1_RREADY),
  .RDATA(m_axi_qkv1_RDATA),
  .RLAST(m_axi_qkv1_RLAST),
  .RID(m_axi_qkv1_RID),
  .RRESP(m_axi_qkv1_RRESP),
  .BVALID(m_axi_qkv1_BVALID),
  .BREADY(m_axi_qkv1_BREADY),
  .BRESP(m_axi_qkv1_BRESP),
  .BID(m_axi_qkv1_BID)
);
assign m_axi_qkv1_RUSER = 0;
assign m_axi_qkv1_BUSER = 0;
front_axi_memory #(.PORT_INDEX(10)) mem_ff0(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_ff0_AWVALID),
  .AWREADY(m_axi_ff0_AWREADY),
  .AWADDR(m_axi_ff0_AWADDR),
  .AWID(m_axi_ff0_AWID),
  .AWLEN(m_axi_ff0_AWLEN),
  .AWSIZE(m_axi_ff0_AWSIZE),
  .AWBURST(m_axi_ff0_AWBURST),
  .WVALID(m_axi_ff0_WVALID),
  .WREADY(m_axi_ff0_WREADY),
  .WDATA(m_axi_ff0_WDATA),
  .WSTRB(m_axi_ff0_WSTRB),
  .WLAST(m_axi_ff0_WLAST),
  .ARVALID(m_axi_ff0_ARVALID),
  .ARREADY(m_axi_ff0_ARREADY),
  .ARADDR(m_axi_ff0_ARADDR),
  .ARID(m_axi_ff0_ARID),
  .ARLEN(m_axi_ff0_ARLEN),
  .ARSIZE(m_axi_ff0_ARSIZE),
  .ARBURST(m_axi_ff0_ARBURST),
  .RVALID(m_axi_ff0_RVALID),
  .RREADY(m_axi_ff0_RREADY),
  .RDATA(m_axi_ff0_RDATA),
  .RLAST(m_axi_ff0_RLAST),
  .RID(m_axi_ff0_RID),
  .RRESP(m_axi_ff0_RRESP),
  .BVALID(m_axi_ff0_BVALID),
  .BREADY(m_axi_ff0_BREADY),
  .BRESP(m_axi_ff0_BRESP),
  .BID(m_axi_ff0_BID)
);
assign m_axi_ff0_RUSER = 0;
assign m_axi_ff0_BUSER = 0;
front_axi_memory #(.PORT_INDEX(11)) mem_ff1(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_ff1_AWVALID),
  .AWREADY(m_axi_ff1_AWREADY),
  .AWADDR(m_axi_ff1_AWADDR),
  .AWID(m_axi_ff1_AWID),
  .AWLEN(m_axi_ff1_AWLEN),
  .AWSIZE(m_axi_ff1_AWSIZE),
  .AWBURST(m_axi_ff1_AWBURST),
  .WVALID(m_axi_ff1_WVALID),
  .WREADY(m_axi_ff1_WREADY),
  .WDATA(m_axi_ff1_WDATA),
  .WSTRB(m_axi_ff1_WSTRB),
  .WLAST(m_axi_ff1_WLAST),
  .ARVALID(m_axi_ff1_ARVALID),
  .ARREADY(m_axi_ff1_ARREADY),
  .ARADDR(m_axi_ff1_ARADDR),
  .ARID(m_axi_ff1_ARID),
  .ARLEN(m_axi_ff1_ARLEN),
  .ARSIZE(m_axi_ff1_ARSIZE),
  .ARBURST(m_axi_ff1_ARBURST),
  .RVALID(m_axi_ff1_RVALID),
  .RREADY(m_axi_ff1_RREADY),
  .RDATA(m_axi_ff1_RDATA),
  .RLAST(m_axi_ff1_RLAST),
  .RID(m_axi_ff1_RID),
  .RRESP(m_axi_ff1_RRESP),
  .BVALID(m_axi_ff1_BVALID),
  .BREADY(m_axi_ff1_BREADY),
  .BRESP(m_axi_ff1_BRESP),
  .BID(m_axi_ff1_BID)
);
assign m_axi_ff1_RUSER = 0;
assign m_axi_ff1_BUSER = 0;
front_axi_memory #(.PORT_INDEX(12)) mem_att_out(
  .clk(ap_clk), .rst_n(ap_rst_n),
  .AWVALID(m_axi_att_out_AWVALID),
  .AWREADY(m_axi_att_out_AWREADY),
  .AWADDR(m_axi_att_out_AWADDR),
  .AWID(m_axi_att_out_AWID),
  .AWLEN(m_axi_att_out_AWLEN),
  .AWSIZE(m_axi_att_out_AWSIZE),
  .AWBURST(m_axi_att_out_AWBURST),
  .WVALID(m_axi_att_out_WVALID),
  .WREADY(m_axi_att_out_WREADY),
  .WDATA(m_axi_att_out_WDATA),
  .WSTRB(m_axi_att_out_WSTRB),
  .WLAST(m_axi_att_out_WLAST),
  .ARVALID(m_axi_att_out_ARVALID),
  .ARREADY(m_axi_att_out_ARREADY),
  .ARADDR(m_axi_att_out_ARADDR),
  .ARID(m_axi_att_out_ARID),
  .ARLEN(m_axi_att_out_ARLEN),
  .ARSIZE(m_axi_att_out_ARSIZE),
  .ARBURST(m_axi_att_out_ARBURST),
  .RVALID(m_axi_att_out_RVALID),
  .RREADY(m_axi_att_out_RREADY),
  .RDATA(m_axi_att_out_RDATA),
  .RLAST(m_axi_att_out_RLAST),
  .RID(m_axi_att_out_RID),
  .RRESP(m_axi_att_out_RRESP),
  .BVALID(m_axi_att_out_BVALID),
  .BREADY(m_axi_att_out_BREADY),
  .BRESP(m_axi_att_out_BRESP),
  .BID(m_axi_att_out_BID)
);
assign m_axi_att_out_RUSER = 0;
assign m_axi_att_out_BUSER = 0;
endmodule
module front_axi_memory #(parameter integer PORT_INDEX = 0)(
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
  output logic BID
);
import "DPI-C" function int front_mem_read(input int port,
                                            input longint unsigned address);
import "DPI-C" function void front_mem_read_accept(input int port,
                                                   input longint unsigned address);
import "DPI-C" function void front_mem_write(input int port,
    input longint unsigned address, input int word, input byte unsigned strobe);
logic rd_active = 0, wr_active = 0, b_valid = 0;
logic [63:0] rd_address = 0, wr_address = 0;
logic [8:0] rd_remaining = 0, wr_remaining = 0;
logic [2:0] rd_size = 0, wr_size = 0;
logic rd_id = 0, wr_id = 0;
assign ARREADY = !rd_active;
assign RVALID = rd_active;
assign RLAST = rd_active && rd_remaining == 1;
assign RID = rd_id;
assign RRESP = 0;
assign RDATA = rd_active ? front_mem_read(PORT_INDEX, rd_address) : 0;
assign AWREADY = !wr_active && !b_valid;
assign WREADY = wr_active;
assign BVALID = b_valid;
assign BID = wr_id;
assign BRESP = 0;
always @(posedge clk) begin
  if (!rst_n) begin
    rd_active <= 0; wr_active <= 0; b_valid <= 0;
    rd_remaining <= 0; wr_remaining <= 0;
  end else begin
    if (ARVALID && ARREADY) begin
      if (ARBURST != 2'b01 && ARLEN != 0) $fatal(1, "unsupported AXI read burst");
      rd_active <= 1;
      rd_address <= ARADDR;
      rd_remaining <= {1'b0, ARLEN} + 1;
      rd_size <= ARSIZE;
      rd_id <= ARID;
    end
    if (RVALID && RREADY) begin
      front_mem_read_accept(PORT_INDEX, rd_address);
      if (rd_remaining == 1) rd_active <= 0;
      else begin
        rd_address <= rd_address + (64'b1 << rd_size);
        rd_remaining <= rd_remaining - 1;
      end
    end
    if (AWVALID && AWREADY) begin
      if (AWBURST != 2'b01 && AWLEN != 0) $fatal(1, "unsupported AXI write burst");
      wr_active <= 1;
      wr_address <= AWADDR;
      wr_remaining <= {1'b0, AWLEN} + 1;
      wr_size <= AWSIZE;
      wr_id <= AWID;
    end
    if (WVALID && WREADY) begin
      if (WLAST != (wr_remaining == 1)) $fatal(1, "AXI WLAST mismatch");
      front_mem_write(PORT_INDEX, wr_address, WDATA, {4'b0, WSTRB});
      if (wr_remaining == 1) begin wr_active <= 0; b_valid <= 1; end
      else begin
        wr_address <= wr_address + (64'b1 << wr_size);
        wr_remaining <= wr_remaining - 1;
      end
    end
    if (BVALID && BREADY) b_valid <= 0;
  end
end
endmodule
