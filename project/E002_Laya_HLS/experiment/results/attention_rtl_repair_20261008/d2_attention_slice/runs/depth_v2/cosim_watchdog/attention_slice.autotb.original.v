// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
`timescale 1ns/1ps


`define AUTOTB_DUT      attention_slice
`define AUTOTB_DUT_INST AESL_inst_attention_slice
`define AUTOTB_TOP      apatb_attention_slice_top
`define AUTOTB_LAT_RESULT_FILE "attention_slice.result.lat.rb"
`define AUTOTB_PER_RESULT_TRANS_FILE "attention_slice.performance.result.transaction.xml"
`define AUTOTB_TOP_INST AESL_inst_apatb_attention_slice_top
`define AUTOTB_MAX_ALLOW_LATENCY  15000000
`define AUTOTB_CLOCK_PERIOD_DIV2 3.33

`define AESL_DEPTH_fixture 1
`define AESL_DEPTH_io 1
`define AESL_DEPTH_aux 1
`define AESL_DEPTH_qkv0 1
`define AESL_DEPTH_qkv1 1
`define AESL_DEPTH_att_out 1
`define AESL_DEPTH_observed 1
`define AESL_DEPTH_fixture_r 1
`define AESL_DEPTH_io_r 1
`define AESL_DEPTH_aux_r 1
`define AESL_DEPTH_qkv0_r 1
`define AESL_DEPTH_qkv1_r 1
`define AESL_DEPTH_att_out_r 1
`define AESL_DEPTH_observed_r 1
`define AUTOTB_TVIN_fixture  "../tv/cdatafile/c.attention_slice.autotvin_fixture.dat"
`define AUTOTB_TVIN_io  "../tv/cdatafile/c.attention_slice.autotvin_io.dat"
`define AUTOTB_TVIN_aux  "../tv/cdatafile/c.attention_slice.autotvin_aux.dat"
`define AUTOTB_TVIN_qkv0  "../tv/cdatafile/c.attention_slice.autotvin_qkv0.dat"
`define AUTOTB_TVIN_qkv1  "../tv/cdatafile/c.attention_slice.autotvin_qkv1.dat"
`define AUTOTB_TVIN_att_out  "../tv/cdatafile/c.attention_slice.autotvin_att_out.dat"
`define AUTOTB_TVIN_fixture_r  "../tv/cdatafile/c.attention_slice.autotvin_fixture_r.dat"
`define AUTOTB_TVIN_io_r  "../tv/cdatafile/c.attention_slice.autotvin_io_r.dat"
`define AUTOTB_TVIN_aux_r  "../tv/cdatafile/c.attention_slice.autotvin_aux_r.dat"
`define AUTOTB_TVIN_qkv0_r  "../tv/cdatafile/c.attention_slice.autotvin_qkv0_r.dat"
`define AUTOTB_TVIN_qkv1_r  "../tv/cdatafile/c.attention_slice.autotvin_qkv1_r.dat"
`define AUTOTB_TVIN_att_out_r  "../tv/cdatafile/c.attention_slice.autotvin_att_out_r.dat"
`define AUTOTB_TVIN_observed_r  "../tv/cdatafile/c.attention_slice.autotvin_observed_r.dat"
`define AUTOTB_TVIN_fixture_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_fixture.dat"
`define AUTOTB_TVIN_io_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_io.dat"
`define AUTOTB_TVIN_aux_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_aux.dat"
`define AUTOTB_TVIN_qkv0_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_qkv0.dat"
`define AUTOTB_TVIN_qkv1_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_qkv1.dat"
`define AUTOTB_TVIN_att_out_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_att_out.dat"
`define AUTOTB_TVIN_fixture_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_fixture_r.dat"
`define AUTOTB_TVIN_io_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_io_r.dat"
`define AUTOTB_TVIN_aux_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_aux_r.dat"
`define AUTOTB_TVIN_qkv0_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_qkv0_r.dat"
`define AUTOTB_TVIN_qkv1_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_qkv1_r.dat"
`define AUTOTB_TVIN_att_out_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_att_out_r.dat"
`define AUTOTB_TVIN_observed_r_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvin_observed_r.dat"
`define AUTOTB_TVOUT_io  "../tv/cdatafile/c.attention_slice.autotvout_io.dat"
`define AUTOTB_TVOUT_qkv0  "../tv/cdatafile/c.attention_slice.autotvout_qkv0.dat"
`define AUTOTB_TVOUT_qkv1  "../tv/cdatafile/c.attention_slice.autotvout_qkv1.dat"
`define AUTOTB_TVOUT_att_out  "../tv/cdatafile/c.attention_slice.autotvout_att_out.dat"
`define AUTOTB_TVOUT_observed  "../tv/cdatafile/c.attention_slice.autotvout_observed.dat"
`define AUTOTB_TVOUT_io_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvout_io.dat"
`define AUTOTB_TVOUT_qkv0_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvout_qkv0.dat"
`define AUTOTB_TVOUT_qkv1_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvout_qkv1.dat"
`define AUTOTB_TVOUT_att_out_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvout_att_out.dat"
`define AUTOTB_TVOUT_observed_out_wrapc  "../tv/rtldatafile/rtl.attention_slice.autotvout_observed.dat"
module `AUTOTB_TOP;

parameter AUTOTB_TRANSACTION_NUM = 1;
parameter PROGRESS_TIMEOUT = 10000000;
parameter LATENCY_ESTIMATION = -1;
parameter LENGTH_att_out = 8388608;
parameter LENGTH_att_out_r = 1;
parameter LENGTH_aux = 1671872;
parameter LENGTH_aux_r = 1;
parameter LENGTH_fixture = 786432;
parameter LENGTH_fixture_r = 1;
parameter LENGTH_io = 32768;
parameter LENGTH_io_r = 1;
parameter LENGTH_observed = 256;
parameter LENGTH_observed_r = 1;
parameter LENGTH_qkv0 = 12582912;
parameter LENGTH_qkv0_r = 1;
parameter LENGTH_qkv1 = 12582912;
parameter LENGTH_qkv1_r = 1;

reg AESL_clock;
reg rst;
reg dut_rst;
reg start;
reg ce;
reg tb_continue;
wire AESL_start;
wire AESL_reset;
wire AESL_ce;
wire AESL_ready;
wire AESL_idle;
wire AESL_continue;
wire AESL_done;
reg AESL_done_delay = 0;
reg AESL_done_delay2 = 0;
reg AESL_ready_delay = 0;
wire ready;
wire ready_wire;
wire [3 : 0] control_AWADDR;
wire  control_AWVALID;
wire  control_AWREADY;
wire  control_WVALID;
wire  control_WREADY;
wire [31 : 0] control_WDATA;
wire [3 : 0] control_WSTRB;
wire [3 : 0] control_ARADDR;
wire  control_ARVALID;
wire  control_ARREADY;
wire  control_RVALID;
wire  control_RREADY;
wire [31 : 0] control_RDATA;
wire [1 : 0] control_RRESP;
wire  control_BVALID;
wire  control_BREADY;
wire [1 : 0] control_BRESP;
wire  control_INTERRUPT;
wire [6 : 0] control_r_AWADDR;
wire  control_r_AWVALID;
wire  control_r_AWREADY;
wire  control_r_WVALID;
wire  control_r_WREADY;
wire [31 : 0] control_r_WDATA;
wire [3 : 0] control_r_WSTRB;
wire [6 : 0] control_r_ARADDR;
wire  control_r_ARVALID;
wire  control_r_ARREADY;
wire  control_r_RVALID;
wire  control_r_RREADY;
wire [31 : 0] control_r_RDATA;
wire [1 : 0] control_r_RRESP;
wire  control_r_BVALID;
wire  control_r_BREADY;
wire [1 : 0] control_r_BRESP;
wire  fixture_AWVALID;
wire  fixture_AWREADY;
wire [63 : 0] fixture_AWADDR;
wire [0 : 0] fixture_AWID;
wire [7 : 0] fixture_AWLEN;
wire [2 : 0] fixture_AWSIZE;
wire [1 : 0] fixture_AWBURST;
wire [1 : 0] fixture_AWLOCK;
wire [3 : 0] fixture_AWCACHE;
wire [2 : 0] fixture_AWPROT;
wire [3 : 0] fixture_AWQOS;
wire [3 : 0] fixture_AWREGION;
wire [0 : 0] fixture_AWUSER;
wire  fixture_WVALID;
wire  fixture_WREADY;
wire [31 : 0] fixture_WDATA;
wire [3 : 0] fixture_WSTRB;
wire  fixture_WLAST;
wire [0 : 0] fixture_WID;
wire [0 : 0] fixture_WUSER;
wire  fixture_ARVALID;
wire  fixture_ARREADY;
wire [63 : 0] fixture_ARADDR;
wire [0 : 0] fixture_ARID;
wire [7 : 0] fixture_ARLEN;
wire [2 : 0] fixture_ARSIZE;
wire [1 : 0] fixture_ARBURST;
wire [1 : 0] fixture_ARLOCK;
wire [3 : 0] fixture_ARCACHE;
wire [2 : 0] fixture_ARPROT;
wire [3 : 0] fixture_ARQOS;
wire [3 : 0] fixture_ARREGION;
wire [0 : 0] fixture_ARUSER;
wire  fixture_RVALID;
wire  fixture_RREADY;
wire [31 : 0] fixture_RDATA;
wire  fixture_RLAST;
wire [0 : 0] fixture_RID;
wire [0 : 0] fixture_RUSER;
wire [1 : 0] fixture_RRESP;
wire  fixture_BVALID;
wire  fixture_BREADY;
wire [1 : 0] fixture_BRESP;
wire [0 : 0] fixture_BID;
wire [0 : 0] fixture_BUSER;
wire  io_AWVALID;
wire  io_AWREADY;
wire [63 : 0] io_AWADDR;
wire [0 : 0] io_AWID;
wire [7 : 0] io_AWLEN;
wire [2 : 0] io_AWSIZE;
wire [1 : 0] io_AWBURST;
wire [1 : 0] io_AWLOCK;
wire [3 : 0] io_AWCACHE;
wire [2 : 0] io_AWPROT;
wire [3 : 0] io_AWQOS;
wire [3 : 0] io_AWREGION;
wire [0 : 0] io_AWUSER;
wire  io_WVALID;
wire  io_WREADY;
wire [31 : 0] io_WDATA;
wire [3 : 0] io_WSTRB;
wire  io_WLAST;
wire [0 : 0] io_WID;
wire [0 : 0] io_WUSER;
wire  io_ARVALID;
wire  io_ARREADY;
wire [63 : 0] io_ARADDR;
wire [0 : 0] io_ARID;
wire [7 : 0] io_ARLEN;
wire [2 : 0] io_ARSIZE;
wire [1 : 0] io_ARBURST;
wire [1 : 0] io_ARLOCK;
wire [3 : 0] io_ARCACHE;
wire [2 : 0] io_ARPROT;
wire [3 : 0] io_ARQOS;
wire [3 : 0] io_ARREGION;
wire [0 : 0] io_ARUSER;
wire  io_RVALID;
wire  io_RREADY;
wire [31 : 0] io_RDATA;
wire  io_RLAST;
wire [0 : 0] io_RID;
wire [0 : 0] io_RUSER;
wire [1 : 0] io_RRESP;
wire  io_BVALID;
wire  io_BREADY;
wire [1 : 0] io_BRESP;
wire [0 : 0] io_BID;
wire [0 : 0] io_BUSER;
wire  aux_AWVALID;
wire  aux_AWREADY;
wire [63 : 0] aux_AWADDR;
wire [0 : 0] aux_AWID;
wire [7 : 0] aux_AWLEN;
wire [2 : 0] aux_AWSIZE;
wire [1 : 0] aux_AWBURST;
wire [1 : 0] aux_AWLOCK;
wire [3 : 0] aux_AWCACHE;
wire [2 : 0] aux_AWPROT;
wire [3 : 0] aux_AWQOS;
wire [3 : 0] aux_AWREGION;
wire [0 : 0] aux_AWUSER;
wire  aux_WVALID;
wire  aux_WREADY;
wire [31 : 0] aux_WDATA;
wire [3 : 0] aux_WSTRB;
wire  aux_WLAST;
wire [0 : 0] aux_WID;
wire [0 : 0] aux_WUSER;
wire  aux_ARVALID;
wire  aux_ARREADY;
wire [63 : 0] aux_ARADDR;
wire [0 : 0] aux_ARID;
wire [7 : 0] aux_ARLEN;
wire [2 : 0] aux_ARSIZE;
wire [1 : 0] aux_ARBURST;
wire [1 : 0] aux_ARLOCK;
wire [3 : 0] aux_ARCACHE;
wire [2 : 0] aux_ARPROT;
wire [3 : 0] aux_ARQOS;
wire [3 : 0] aux_ARREGION;
wire [0 : 0] aux_ARUSER;
wire  aux_RVALID;
wire  aux_RREADY;
wire [31 : 0] aux_RDATA;
wire  aux_RLAST;
wire [0 : 0] aux_RID;
wire [0 : 0] aux_RUSER;
wire [1 : 0] aux_RRESP;
wire  aux_BVALID;
wire  aux_BREADY;
wire [1 : 0] aux_BRESP;
wire [0 : 0] aux_BID;
wire [0 : 0] aux_BUSER;
wire  qkv0_AWVALID;
wire  qkv0_AWREADY;
wire [63 : 0] qkv0_AWADDR;
wire [0 : 0] qkv0_AWID;
wire [7 : 0] qkv0_AWLEN;
wire [2 : 0] qkv0_AWSIZE;
wire [1 : 0] qkv0_AWBURST;
wire [1 : 0] qkv0_AWLOCK;
wire [3 : 0] qkv0_AWCACHE;
wire [2 : 0] qkv0_AWPROT;
wire [3 : 0] qkv0_AWQOS;
wire [3 : 0] qkv0_AWREGION;
wire [0 : 0] qkv0_AWUSER;
wire  qkv0_WVALID;
wire  qkv0_WREADY;
wire [31 : 0] qkv0_WDATA;
wire [3 : 0] qkv0_WSTRB;
wire  qkv0_WLAST;
wire [0 : 0] qkv0_WID;
wire [0 : 0] qkv0_WUSER;
wire  qkv0_ARVALID;
wire  qkv0_ARREADY;
wire [63 : 0] qkv0_ARADDR;
wire [0 : 0] qkv0_ARID;
wire [7 : 0] qkv0_ARLEN;
wire [2 : 0] qkv0_ARSIZE;
wire [1 : 0] qkv0_ARBURST;
wire [1 : 0] qkv0_ARLOCK;
wire [3 : 0] qkv0_ARCACHE;
wire [2 : 0] qkv0_ARPROT;
wire [3 : 0] qkv0_ARQOS;
wire [3 : 0] qkv0_ARREGION;
wire [0 : 0] qkv0_ARUSER;
wire  qkv0_RVALID;
wire  qkv0_RREADY;
wire [31 : 0] qkv0_RDATA;
wire  qkv0_RLAST;
wire [0 : 0] qkv0_RID;
wire [0 : 0] qkv0_RUSER;
wire [1 : 0] qkv0_RRESP;
wire  qkv0_BVALID;
wire  qkv0_BREADY;
wire [1 : 0] qkv0_BRESP;
wire [0 : 0] qkv0_BID;
wire [0 : 0] qkv0_BUSER;
wire  qkv1_AWVALID;
wire  qkv1_AWREADY;
wire [63 : 0] qkv1_AWADDR;
wire [0 : 0] qkv1_AWID;
wire [7 : 0] qkv1_AWLEN;
wire [2 : 0] qkv1_AWSIZE;
wire [1 : 0] qkv1_AWBURST;
wire [1 : 0] qkv1_AWLOCK;
wire [3 : 0] qkv1_AWCACHE;
wire [2 : 0] qkv1_AWPROT;
wire [3 : 0] qkv1_AWQOS;
wire [3 : 0] qkv1_AWREGION;
wire [0 : 0] qkv1_AWUSER;
wire  qkv1_WVALID;
wire  qkv1_WREADY;
wire [31 : 0] qkv1_WDATA;
wire [3 : 0] qkv1_WSTRB;
wire  qkv1_WLAST;
wire [0 : 0] qkv1_WID;
wire [0 : 0] qkv1_WUSER;
wire  qkv1_ARVALID;
wire  qkv1_ARREADY;
wire [63 : 0] qkv1_ARADDR;
wire [0 : 0] qkv1_ARID;
wire [7 : 0] qkv1_ARLEN;
wire [2 : 0] qkv1_ARSIZE;
wire [1 : 0] qkv1_ARBURST;
wire [1 : 0] qkv1_ARLOCK;
wire [3 : 0] qkv1_ARCACHE;
wire [2 : 0] qkv1_ARPROT;
wire [3 : 0] qkv1_ARQOS;
wire [3 : 0] qkv1_ARREGION;
wire [0 : 0] qkv1_ARUSER;
wire  qkv1_RVALID;
wire  qkv1_RREADY;
wire [31 : 0] qkv1_RDATA;
wire  qkv1_RLAST;
wire [0 : 0] qkv1_RID;
wire [0 : 0] qkv1_RUSER;
wire [1 : 0] qkv1_RRESP;
wire  qkv1_BVALID;
wire  qkv1_BREADY;
wire [1 : 0] qkv1_BRESP;
wire [0 : 0] qkv1_BID;
wire [0 : 0] qkv1_BUSER;
wire  att_out_AWVALID;
wire  att_out_AWREADY;
wire [63 : 0] att_out_AWADDR;
wire [0 : 0] att_out_AWID;
wire [7 : 0] att_out_AWLEN;
wire [2 : 0] att_out_AWSIZE;
wire [1 : 0] att_out_AWBURST;
wire [1 : 0] att_out_AWLOCK;
wire [3 : 0] att_out_AWCACHE;
wire [2 : 0] att_out_AWPROT;
wire [3 : 0] att_out_AWQOS;
wire [3 : 0] att_out_AWREGION;
wire [0 : 0] att_out_AWUSER;
wire  att_out_WVALID;
wire  att_out_WREADY;
wire [31 : 0] att_out_WDATA;
wire [3 : 0] att_out_WSTRB;
wire  att_out_WLAST;
wire [0 : 0] att_out_WID;
wire [0 : 0] att_out_WUSER;
wire  att_out_ARVALID;
wire  att_out_ARREADY;
wire [63 : 0] att_out_ARADDR;
wire [0 : 0] att_out_ARID;
wire [7 : 0] att_out_ARLEN;
wire [2 : 0] att_out_ARSIZE;
wire [1 : 0] att_out_ARBURST;
wire [1 : 0] att_out_ARLOCK;
wire [3 : 0] att_out_ARCACHE;
wire [2 : 0] att_out_ARPROT;
wire [3 : 0] att_out_ARQOS;
wire [3 : 0] att_out_ARREGION;
wire [0 : 0] att_out_ARUSER;
wire  att_out_RVALID;
wire  att_out_RREADY;
wire [31 : 0] att_out_RDATA;
wire  att_out_RLAST;
wire [0 : 0] att_out_RID;
wire [0 : 0] att_out_RUSER;
wire [1 : 0] att_out_RRESP;
wire  att_out_BVALID;
wire  att_out_BREADY;
wire [1 : 0] att_out_BRESP;
wire [0 : 0] att_out_BID;
wire [0 : 0] att_out_BUSER;
wire  observed_AWVALID;
wire  observed_AWREADY;
wire [63 : 0] observed_AWADDR;
wire [0 : 0] observed_AWID;
wire [7 : 0] observed_AWLEN;
wire [2 : 0] observed_AWSIZE;
wire [1 : 0] observed_AWBURST;
wire [1 : 0] observed_AWLOCK;
wire [3 : 0] observed_AWCACHE;
wire [2 : 0] observed_AWPROT;
wire [3 : 0] observed_AWQOS;
wire [3 : 0] observed_AWREGION;
wire [0 : 0] observed_AWUSER;
wire  observed_WVALID;
wire  observed_WREADY;
wire [31 : 0] observed_WDATA;
wire [3 : 0] observed_WSTRB;
wire  observed_WLAST;
wire [0 : 0] observed_WID;
wire [0 : 0] observed_WUSER;
wire  observed_ARVALID;
wire  observed_ARREADY;
wire [63 : 0] observed_ARADDR;
wire [0 : 0] observed_ARID;
wire [7 : 0] observed_ARLEN;
wire [2 : 0] observed_ARSIZE;
wire [1 : 0] observed_ARBURST;
wire [1 : 0] observed_ARLOCK;
wire [3 : 0] observed_ARCACHE;
wire [2 : 0] observed_ARPROT;
wire [3 : 0] observed_ARQOS;
wire [3 : 0] observed_ARREGION;
wire [0 : 0] observed_ARUSER;
wire  observed_RVALID;
wire  observed_RREADY;
wire [31 : 0] observed_RDATA;
wire  observed_RLAST;
wire [0 : 0] observed_RID;
wire [0 : 0] observed_RUSER;
wire [1 : 0] observed_RRESP;
wire  observed_BVALID;
wire  observed_BREADY;
wire [1 : 0] observed_BRESP;
wire [0 : 0] observed_BID;
wire [0 : 0] observed_BUSER;
integer done_cnt = 0;
integer AESL_ready_cnt = 0;
integer ready_cnt = 0;
reg ready_initial;
reg ready_initial_n;
reg ready_last_n;
reg ready_delay_last_n;
reg done_delay_last_n;
reg interface_done = 0;
wire control_r_write_data_finish;
wire AESL_slave_start;
reg AESL_slave_start_lock = 0;
wire AESL_slave_write_start_in;
wire AESL_slave_write_start_finish;
reg AESL_slave_ready;
wire AESL_slave_output_done;
wire AESL_slave_done;
reg ready_rise = 0;
reg start_rise = 0;
reg slave_start_status = 0;
reg slave_done_status = 0;
reg ap_done_lock = 0;


wire all_finish;
wire ap_clk;
wire ap_rst_n;
wire ap_rst_n_n;

`AUTOTB_DUT `AUTOTB_DUT_INST(
    .s_axi_control_AWADDR(control_AWADDR),
    .s_axi_control_AWVALID(control_AWVALID),
    .s_axi_control_AWREADY(control_AWREADY),
    .s_axi_control_WVALID(control_WVALID),
    .s_axi_control_WREADY(control_WREADY),
    .s_axi_control_WDATA(control_WDATA),
    .s_axi_control_WSTRB(control_WSTRB),
    .s_axi_control_ARADDR(control_ARADDR),
    .s_axi_control_ARVALID(control_ARVALID),
    .s_axi_control_ARREADY(control_ARREADY),
    .s_axi_control_RVALID(control_RVALID),
    .s_axi_control_RREADY(control_RREADY),
    .s_axi_control_RDATA(control_RDATA),
    .s_axi_control_RRESP(control_RRESP),
    .s_axi_control_BVALID(control_BVALID),
    .s_axi_control_BREADY(control_BREADY),
    .s_axi_control_BRESP(control_BRESP),
    .interrupt(control_INTERRUPT),
    .s_axi_control_r_AWADDR(control_r_AWADDR),
    .s_axi_control_r_AWVALID(control_r_AWVALID),
    .s_axi_control_r_AWREADY(control_r_AWREADY),
    .s_axi_control_r_WVALID(control_r_WVALID),
    .s_axi_control_r_WREADY(control_r_WREADY),
    .s_axi_control_r_WDATA(control_r_WDATA),
    .s_axi_control_r_WSTRB(control_r_WSTRB),
    .s_axi_control_r_ARADDR(control_r_ARADDR),
    .s_axi_control_r_ARVALID(control_r_ARVALID),
    .s_axi_control_r_ARREADY(control_r_ARREADY),
    .s_axi_control_r_RVALID(control_r_RVALID),
    .s_axi_control_r_RREADY(control_r_RREADY),
    .s_axi_control_r_RDATA(control_r_RDATA),
    .s_axi_control_r_RRESP(control_r_RRESP),
    .s_axi_control_r_BVALID(control_r_BVALID),
    .s_axi_control_r_BREADY(control_r_BREADY),
    .s_axi_control_r_BRESP(control_r_BRESP),
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .m_axi_fixture_AWVALID(fixture_AWVALID),
    .m_axi_fixture_AWREADY(fixture_AWREADY),
    .m_axi_fixture_AWADDR(fixture_AWADDR),
    .m_axi_fixture_AWID(fixture_AWID),
    .m_axi_fixture_AWLEN(fixture_AWLEN),
    .m_axi_fixture_AWSIZE(fixture_AWSIZE),
    .m_axi_fixture_AWBURST(fixture_AWBURST),
    .m_axi_fixture_AWLOCK(fixture_AWLOCK),
    .m_axi_fixture_AWCACHE(fixture_AWCACHE),
    .m_axi_fixture_AWPROT(fixture_AWPROT),
    .m_axi_fixture_AWQOS(fixture_AWQOS),
    .m_axi_fixture_AWREGION(fixture_AWREGION),
    .m_axi_fixture_AWUSER(fixture_AWUSER),
    .m_axi_fixture_WVALID(fixture_WVALID),
    .m_axi_fixture_WREADY(fixture_WREADY),
    .m_axi_fixture_WDATA(fixture_WDATA),
    .m_axi_fixture_WSTRB(fixture_WSTRB),
    .m_axi_fixture_WLAST(fixture_WLAST),
    .m_axi_fixture_WID(fixture_WID),
    .m_axi_fixture_WUSER(fixture_WUSER),
    .m_axi_fixture_ARVALID(fixture_ARVALID),
    .m_axi_fixture_ARREADY(fixture_ARREADY),
    .m_axi_fixture_ARADDR(fixture_ARADDR),
    .m_axi_fixture_ARID(fixture_ARID),
    .m_axi_fixture_ARLEN(fixture_ARLEN),
    .m_axi_fixture_ARSIZE(fixture_ARSIZE),
    .m_axi_fixture_ARBURST(fixture_ARBURST),
    .m_axi_fixture_ARLOCK(fixture_ARLOCK),
    .m_axi_fixture_ARCACHE(fixture_ARCACHE),
    .m_axi_fixture_ARPROT(fixture_ARPROT),
    .m_axi_fixture_ARQOS(fixture_ARQOS),
    .m_axi_fixture_ARREGION(fixture_ARREGION),
    .m_axi_fixture_ARUSER(fixture_ARUSER),
    .m_axi_fixture_RVALID(fixture_RVALID),
    .m_axi_fixture_RREADY(fixture_RREADY),
    .m_axi_fixture_RDATA(fixture_RDATA),
    .m_axi_fixture_RLAST(fixture_RLAST),
    .m_axi_fixture_RID(fixture_RID),
    .m_axi_fixture_RUSER(fixture_RUSER),
    .m_axi_fixture_RRESP(fixture_RRESP),
    .m_axi_fixture_BVALID(fixture_BVALID),
    .m_axi_fixture_BREADY(fixture_BREADY),
    .m_axi_fixture_BRESP(fixture_BRESP),
    .m_axi_fixture_BID(fixture_BID),
    .m_axi_fixture_BUSER(fixture_BUSER),
    .m_axi_io_AWVALID(io_AWVALID),
    .m_axi_io_AWREADY(io_AWREADY),
    .m_axi_io_AWADDR(io_AWADDR),
    .m_axi_io_AWID(io_AWID),
    .m_axi_io_AWLEN(io_AWLEN),
    .m_axi_io_AWSIZE(io_AWSIZE),
    .m_axi_io_AWBURST(io_AWBURST),
    .m_axi_io_AWLOCK(io_AWLOCK),
    .m_axi_io_AWCACHE(io_AWCACHE),
    .m_axi_io_AWPROT(io_AWPROT),
    .m_axi_io_AWQOS(io_AWQOS),
    .m_axi_io_AWREGION(io_AWREGION),
    .m_axi_io_AWUSER(io_AWUSER),
    .m_axi_io_WVALID(io_WVALID),
    .m_axi_io_WREADY(io_WREADY),
    .m_axi_io_WDATA(io_WDATA),
    .m_axi_io_WSTRB(io_WSTRB),
    .m_axi_io_WLAST(io_WLAST),
    .m_axi_io_WID(io_WID),
    .m_axi_io_WUSER(io_WUSER),
    .m_axi_io_ARVALID(io_ARVALID),
    .m_axi_io_ARREADY(io_ARREADY),
    .m_axi_io_ARADDR(io_ARADDR),
    .m_axi_io_ARID(io_ARID),
    .m_axi_io_ARLEN(io_ARLEN),
    .m_axi_io_ARSIZE(io_ARSIZE),
    .m_axi_io_ARBURST(io_ARBURST),
    .m_axi_io_ARLOCK(io_ARLOCK),
    .m_axi_io_ARCACHE(io_ARCACHE),
    .m_axi_io_ARPROT(io_ARPROT),
    .m_axi_io_ARQOS(io_ARQOS),
    .m_axi_io_ARREGION(io_ARREGION),
    .m_axi_io_ARUSER(io_ARUSER),
    .m_axi_io_RVALID(io_RVALID),
    .m_axi_io_RREADY(io_RREADY),
    .m_axi_io_RDATA(io_RDATA),
    .m_axi_io_RLAST(io_RLAST),
    .m_axi_io_RID(io_RID),
    .m_axi_io_RUSER(io_RUSER),
    .m_axi_io_RRESP(io_RRESP),
    .m_axi_io_BVALID(io_BVALID),
    .m_axi_io_BREADY(io_BREADY),
    .m_axi_io_BRESP(io_BRESP),
    .m_axi_io_BID(io_BID),
    .m_axi_io_BUSER(io_BUSER),
    .m_axi_aux_AWVALID(aux_AWVALID),
    .m_axi_aux_AWREADY(aux_AWREADY),
    .m_axi_aux_AWADDR(aux_AWADDR),
    .m_axi_aux_AWID(aux_AWID),
    .m_axi_aux_AWLEN(aux_AWLEN),
    .m_axi_aux_AWSIZE(aux_AWSIZE),
    .m_axi_aux_AWBURST(aux_AWBURST),
    .m_axi_aux_AWLOCK(aux_AWLOCK),
    .m_axi_aux_AWCACHE(aux_AWCACHE),
    .m_axi_aux_AWPROT(aux_AWPROT),
    .m_axi_aux_AWQOS(aux_AWQOS),
    .m_axi_aux_AWREGION(aux_AWREGION),
    .m_axi_aux_AWUSER(aux_AWUSER),
    .m_axi_aux_WVALID(aux_WVALID),
    .m_axi_aux_WREADY(aux_WREADY),
    .m_axi_aux_WDATA(aux_WDATA),
    .m_axi_aux_WSTRB(aux_WSTRB),
    .m_axi_aux_WLAST(aux_WLAST),
    .m_axi_aux_WID(aux_WID),
    .m_axi_aux_WUSER(aux_WUSER),
    .m_axi_aux_ARVALID(aux_ARVALID),
    .m_axi_aux_ARREADY(aux_ARREADY),
    .m_axi_aux_ARADDR(aux_ARADDR),
    .m_axi_aux_ARID(aux_ARID),
    .m_axi_aux_ARLEN(aux_ARLEN),
    .m_axi_aux_ARSIZE(aux_ARSIZE),
    .m_axi_aux_ARBURST(aux_ARBURST),
    .m_axi_aux_ARLOCK(aux_ARLOCK),
    .m_axi_aux_ARCACHE(aux_ARCACHE),
    .m_axi_aux_ARPROT(aux_ARPROT),
    .m_axi_aux_ARQOS(aux_ARQOS),
    .m_axi_aux_ARREGION(aux_ARREGION),
    .m_axi_aux_ARUSER(aux_ARUSER),
    .m_axi_aux_RVALID(aux_RVALID),
    .m_axi_aux_RREADY(aux_RREADY),
    .m_axi_aux_RDATA(aux_RDATA),
    .m_axi_aux_RLAST(aux_RLAST),
    .m_axi_aux_RID(aux_RID),
    .m_axi_aux_RUSER(aux_RUSER),
    .m_axi_aux_RRESP(aux_RRESP),
    .m_axi_aux_BVALID(aux_BVALID),
    .m_axi_aux_BREADY(aux_BREADY),
    .m_axi_aux_BRESP(aux_BRESP),
    .m_axi_aux_BID(aux_BID),
    .m_axi_aux_BUSER(aux_BUSER),
    .m_axi_qkv0_AWVALID(qkv0_AWVALID),
    .m_axi_qkv0_AWREADY(qkv0_AWREADY),
    .m_axi_qkv0_AWADDR(qkv0_AWADDR),
    .m_axi_qkv0_AWID(qkv0_AWID),
    .m_axi_qkv0_AWLEN(qkv0_AWLEN),
    .m_axi_qkv0_AWSIZE(qkv0_AWSIZE),
    .m_axi_qkv0_AWBURST(qkv0_AWBURST),
    .m_axi_qkv0_AWLOCK(qkv0_AWLOCK),
    .m_axi_qkv0_AWCACHE(qkv0_AWCACHE),
    .m_axi_qkv0_AWPROT(qkv0_AWPROT),
    .m_axi_qkv0_AWQOS(qkv0_AWQOS),
    .m_axi_qkv0_AWREGION(qkv0_AWREGION),
    .m_axi_qkv0_AWUSER(qkv0_AWUSER),
    .m_axi_qkv0_WVALID(qkv0_WVALID),
    .m_axi_qkv0_WREADY(qkv0_WREADY),
    .m_axi_qkv0_WDATA(qkv0_WDATA),
    .m_axi_qkv0_WSTRB(qkv0_WSTRB),
    .m_axi_qkv0_WLAST(qkv0_WLAST),
    .m_axi_qkv0_WID(qkv0_WID),
    .m_axi_qkv0_WUSER(qkv0_WUSER),
    .m_axi_qkv0_ARVALID(qkv0_ARVALID),
    .m_axi_qkv0_ARREADY(qkv0_ARREADY),
    .m_axi_qkv0_ARADDR(qkv0_ARADDR),
    .m_axi_qkv0_ARID(qkv0_ARID),
    .m_axi_qkv0_ARLEN(qkv0_ARLEN),
    .m_axi_qkv0_ARSIZE(qkv0_ARSIZE),
    .m_axi_qkv0_ARBURST(qkv0_ARBURST),
    .m_axi_qkv0_ARLOCK(qkv0_ARLOCK),
    .m_axi_qkv0_ARCACHE(qkv0_ARCACHE),
    .m_axi_qkv0_ARPROT(qkv0_ARPROT),
    .m_axi_qkv0_ARQOS(qkv0_ARQOS),
    .m_axi_qkv0_ARREGION(qkv0_ARREGION),
    .m_axi_qkv0_ARUSER(qkv0_ARUSER),
    .m_axi_qkv0_RVALID(qkv0_RVALID),
    .m_axi_qkv0_RREADY(qkv0_RREADY),
    .m_axi_qkv0_RDATA(qkv0_RDATA),
    .m_axi_qkv0_RLAST(qkv0_RLAST),
    .m_axi_qkv0_RID(qkv0_RID),
    .m_axi_qkv0_RUSER(qkv0_RUSER),
    .m_axi_qkv0_RRESP(qkv0_RRESP),
    .m_axi_qkv0_BVALID(qkv0_BVALID),
    .m_axi_qkv0_BREADY(qkv0_BREADY),
    .m_axi_qkv0_BRESP(qkv0_BRESP),
    .m_axi_qkv0_BID(qkv0_BID),
    .m_axi_qkv0_BUSER(qkv0_BUSER),
    .m_axi_qkv1_AWVALID(qkv1_AWVALID),
    .m_axi_qkv1_AWREADY(qkv1_AWREADY),
    .m_axi_qkv1_AWADDR(qkv1_AWADDR),
    .m_axi_qkv1_AWID(qkv1_AWID),
    .m_axi_qkv1_AWLEN(qkv1_AWLEN),
    .m_axi_qkv1_AWSIZE(qkv1_AWSIZE),
    .m_axi_qkv1_AWBURST(qkv1_AWBURST),
    .m_axi_qkv1_AWLOCK(qkv1_AWLOCK),
    .m_axi_qkv1_AWCACHE(qkv1_AWCACHE),
    .m_axi_qkv1_AWPROT(qkv1_AWPROT),
    .m_axi_qkv1_AWQOS(qkv1_AWQOS),
    .m_axi_qkv1_AWREGION(qkv1_AWREGION),
    .m_axi_qkv1_AWUSER(qkv1_AWUSER),
    .m_axi_qkv1_WVALID(qkv1_WVALID),
    .m_axi_qkv1_WREADY(qkv1_WREADY),
    .m_axi_qkv1_WDATA(qkv1_WDATA),
    .m_axi_qkv1_WSTRB(qkv1_WSTRB),
    .m_axi_qkv1_WLAST(qkv1_WLAST),
    .m_axi_qkv1_WID(qkv1_WID),
    .m_axi_qkv1_WUSER(qkv1_WUSER),
    .m_axi_qkv1_ARVALID(qkv1_ARVALID),
    .m_axi_qkv1_ARREADY(qkv1_ARREADY),
    .m_axi_qkv1_ARADDR(qkv1_ARADDR),
    .m_axi_qkv1_ARID(qkv1_ARID),
    .m_axi_qkv1_ARLEN(qkv1_ARLEN),
    .m_axi_qkv1_ARSIZE(qkv1_ARSIZE),
    .m_axi_qkv1_ARBURST(qkv1_ARBURST),
    .m_axi_qkv1_ARLOCK(qkv1_ARLOCK),
    .m_axi_qkv1_ARCACHE(qkv1_ARCACHE),
    .m_axi_qkv1_ARPROT(qkv1_ARPROT),
    .m_axi_qkv1_ARQOS(qkv1_ARQOS),
    .m_axi_qkv1_ARREGION(qkv1_ARREGION),
    .m_axi_qkv1_ARUSER(qkv1_ARUSER),
    .m_axi_qkv1_RVALID(qkv1_RVALID),
    .m_axi_qkv1_RREADY(qkv1_RREADY),
    .m_axi_qkv1_RDATA(qkv1_RDATA),
    .m_axi_qkv1_RLAST(qkv1_RLAST),
    .m_axi_qkv1_RID(qkv1_RID),
    .m_axi_qkv1_RUSER(qkv1_RUSER),
    .m_axi_qkv1_RRESP(qkv1_RRESP),
    .m_axi_qkv1_BVALID(qkv1_BVALID),
    .m_axi_qkv1_BREADY(qkv1_BREADY),
    .m_axi_qkv1_BRESP(qkv1_BRESP),
    .m_axi_qkv1_BID(qkv1_BID),
    .m_axi_qkv1_BUSER(qkv1_BUSER),
    .m_axi_att_out_AWVALID(att_out_AWVALID),
    .m_axi_att_out_AWREADY(att_out_AWREADY),
    .m_axi_att_out_AWADDR(att_out_AWADDR),
    .m_axi_att_out_AWID(att_out_AWID),
    .m_axi_att_out_AWLEN(att_out_AWLEN),
    .m_axi_att_out_AWSIZE(att_out_AWSIZE),
    .m_axi_att_out_AWBURST(att_out_AWBURST),
    .m_axi_att_out_AWLOCK(att_out_AWLOCK),
    .m_axi_att_out_AWCACHE(att_out_AWCACHE),
    .m_axi_att_out_AWPROT(att_out_AWPROT),
    .m_axi_att_out_AWQOS(att_out_AWQOS),
    .m_axi_att_out_AWREGION(att_out_AWREGION),
    .m_axi_att_out_AWUSER(att_out_AWUSER),
    .m_axi_att_out_WVALID(att_out_WVALID),
    .m_axi_att_out_WREADY(att_out_WREADY),
    .m_axi_att_out_WDATA(att_out_WDATA),
    .m_axi_att_out_WSTRB(att_out_WSTRB),
    .m_axi_att_out_WLAST(att_out_WLAST),
    .m_axi_att_out_WID(att_out_WID),
    .m_axi_att_out_WUSER(att_out_WUSER),
    .m_axi_att_out_ARVALID(att_out_ARVALID),
    .m_axi_att_out_ARREADY(att_out_ARREADY),
    .m_axi_att_out_ARADDR(att_out_ARADDR),
    .m_axi_att_out_ARID(att_out_ARID),
    .m_axi_att_out_ARLEN(att_out_ARLEN),
    .m_axi_att_out_ARSIZE(att_out_ARSIZE),
    .m_axi_att_out_ARBURST(att_out_ARBURST),
    .m_axi_att_out_ARLOCK(att_out_ARLOCK),
    .m_axi_att_out_ARCACHE(att_out_ARCACHE),
    .m_axi_att_out_ARPROT(att_out_ARPROT),
    .m_axi_att_out_ARQOS(att_out_ARQOS),
    .m_axi_att_out_ARREGION(att_out_ARREGION),
    .m_axi_att_out_ARUSER(att_out_ARUSER),
    .m_axi_att_out_RVALID(att_out_RVALID),
    .m_axi_att_out_RREADY(att_out_RREADY),
    .m_axi_att_out_RDATA(att_out_RDATA),
    .m_axi_att_out_RLAST(att_out_RLAST),
    .m_axi_att_out_RID(att_out_RID),
    .m_axi_att_out_RUSER(att_out_RUSER),
    .m_axi_att_out_RRESP(att_out_RRESP),
    .m_axi_att_out_BVALID(att_out_BVALID),
    .m_axi_att_out_BREADY(att_out_BREADY),
    .m_axi_att_out_BRESP(att_out_BRESP),
    .m_axi_att_out_BID(att_out_BID),
    .m_axi_att_out_BUSER(att_out_BUSER),
    .m_axi_observed_AWVALID(observed_AWVALID),
    .m_axi_observed_AWREADY(observed_AWREADY),
    .m_axi_observed_AWADDR(observed_AWADDR),
    .m_axi_observed_AWID(observed_AWID),
    .m_axi_observed_AWLEN(observed_AWLEN),
    .m_axi_observed_AWSIZE(observed_AWSIZE),
    .m_axi_observed_AWBURST(observed_AWBURST),
    .m_axi_observed_AWLOCK(observed_AWLOCK),
    .m_axi_observed_AWCACHE(observed_AWCACHE),
    .m_axi_observed_AWPROT(observed_AWPROT),
    .m_axi_observed_AWQOS(observed_AWQOS),
    .m_axi_observed_AWREGION(observed_AWREGION),
    .m_axi_observed_AWUSER(observed_AWUSER),
    .m_axi_observed_WVALID(observed_WVALID),
    .m_axi_observed_WREADY(observed_WREADY),
    .m_axi_observed_WDATA(observed_WDATA),
    .m_axi_observed_WSTRB(observed_WSTRB),
    .m_axi_observed_WLAST(observed_WLAST),
    .m_axi_observed_WID(observed_WID),
    .m_axi_observed_WUSER(observed_WUSER),
    .m_axi_observed_ARVALID(observed_ARVALID),
    .m_axi_observed_ARREADY(observed_ARREADY),
    .m_axi_observed_ARADDR(observed_ARADDR),
    .m_axi_observed_ARID(observed_ARID),
    .m_axi_observed_ARLEN(observed_ARLEN),
    .m_axi_observed_ARSIZE(observed_ARSIZE),
    .m_axi_observed_ARBURST(observed_ARBURST),
    .m_axi_observed_ARLOCK(observed_ARLOCK),
    .m_axi_observed_ARCACHE(observed_ARCACHE),
    .m_axi_observed_ARPROT(observed_ARPROT),
    .m_axi_observed_ARQOS(observed_ARQOS),
    .m_axi_observed_ARREGION(observed_ARREGION),
    .m_axi_observed_ARUSER(observed_ARUSER),
    .m_axi_observed_RVALID(observed_RVALID),
    .m_axi_observed_RREADY(observed_RREADY),
    .m_axi_observed_RDATA(observed_RDATA),
    .m_axi_observed_RLAST(observed_RLAST),
    .m_axi_observed_RID(observed_RID),
    .m_axi_observed_RUSER(observed_RUSER),
    .m_axi_observed_RRESP(observed_RRESP),
    .m_axi_observed_BVALID(observed_BVALID),
    .m_axi_observed_BREADY(observed_BREADY),
    .m_axi_observed_BRESP(observed_BRESP),
    .m_axi_observed_BID(observed_BID),
    .m_axi_observed_BUSER(observed_BUSER));
assign ap_clk = AESL_clock;
assign ap_rst_n = AESL_reset;
assign ap_rst_n_n = ~AESL_reset;
assign AESL_reset = dut_rst;
assign AESL_start = svtb_top.misc_if.tb2dut_ap_start;
assign AESL_ready = svtb_top.misc_if.dut2tb_ap_ready;
assign AESL_done  = svtb_top.misc_if.dut2tb_ap_done;
assign all_finish = svtb_top.misc_if.finished;
initial begin : initial_process
    integer proc_rand;
    rst = 0;
    # 100;
    repeat(0+3) @ (posedge AESL_clock);
    # 0.1;
    rst = 1;
end
initial begin : initial_process_for_dut_rst
    integer proc_rand;
    dut_rst = 0;
    # 100;
    repeat(3) @ (posedge AESL_clock);
    # 0.1;
    dut_rst = 1;
end
initial begin
    AESL_clock = 0;
    forever #`AUTOTB_CLOCK_PERIOD_DIV2 AESL_clock = ~AESL_clock;
end

    sv_module_top svtb_top();

////////////////////////////////////////////
// progress and performance
////////////////////////////////////////////

task wait_start();
    while (~AESL_start) begin
        @ (posedge AESL_clock);
    end
endtask

reg [31:0] clk_cnt = 0;
reg AESL_ready_p1;
reg AESL_start_p1;

always @ (posedge AESL_clock) begin
    if (AESL_reset == 0) begin
        clk_cnt <= 32'h0;
        AESL_ready_p1 <= 1'b0;
        AESL_start_p1 <= 1'b0;
    end
    else begin
        clk_cnt <= clk_cnt + 1;
        AESL_ready_p1 <= AESL_ready;
        AESL_start_p1 <= AESL_start;
    end
end

reg [31:0] start_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] start_cnt;
reg [31:0] ready_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] ap_ready_cnt;
reg [31:0] finish_timestamp [0:AUTOTB_TRANSACTION_NUM - 1];
reg [31:0] finish_cnt;
reg [31:0] lat_total;
event report_progress;

always @(posedge AESL_clock)
begin
    if (finish_cnt == AUTOTB_TRANSACTION_NUM - 1 && AESL_done == 1'b1)
        lat_total = clk_cnt - start_timestamp[0];
end

initial begin
    start_cnt = 0;
    finish_cnt = 0;
    ap_ready_cnt = 0;
    wait (AESL_reset == 1);
    wait_start();
    start_timestamp[start_cnt] = clk_cnt;
    start_cnt = start_cnt + 1;
    if (AESL_done) begin
        finish_timestamp[finish_cnt] = clk_cnt;
        finish_cnt = finish_cnt + 1;
    end
    -> report_progress;
    forever begin
        @ (posedge AESL_clock);
        if (start_cnt < AUTOTB_TRANSACTION_NUM) begin
            if ((AESL_start && AESL_ready_p1)||(AESL_start && ~AESL_start_p1)) begin
                start_timestamp[start_cnt] = clk_cnt;
                start_cnt = start_cnt + 1;
            end
        end
        if (ap_ready_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_start_p1 && AESL_ready_p1) begin
                ready_timestamp[ap_ready_cnt] = clk_cnt;
                ap_ready_cnt = ap_ready_cnt + 1;
            end
        end
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                finish_timestamp[finish_cnt] = clk_cnt;
                finish_cnt = finish_cnt + 1;
            end
        end
        -> report_progress;
    end
end

reg [31:0] progress_timeout;

initial begin : simulation_progress
    real intra_progress;
    wait (AESL_reset == 1);
    progress_timeout = PROGRESS_TIMEOUT;
    $display("////////////////////////////////////////////////////////////////////////////////////");
    $display("// Inter-Transaction Progress: Completed Transaction / Total Transaction");
    $display("// Intra-Transaction Progress: Measured Latency / Latency Estimation * 100%%");
    $display("//");
    $display("// RTL Simulation : \"Inter-Transaction Progress\" [\"Intra-Transaction Progress\"] @ \"Simulation Time\"");
    $display("////////////////////////////////////////////////////////////////////////////////////");
    print_progress();
    while (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
        @ (report_progress);
        if (finish_cnt < AUTOTB_TRANSACTION_NUM) begin
            if (AESL_done) begin
                print_progress();
                progress_timeout = PROGRESS_TIMEOUT;
            end else begin
                if (progress_timeout == 0) begin
                    print_progress();
                    progress_timeout = PROGRESS_TIMEOUT;
                end else begin
                    progress_timeout = progress_timeout - 1;
                end
            end
        end
    end
    print_progress();
    $display("////////////////////////////////////////////////////////////////////////////////////");
    calculate_performance();
end

task get_intra_progress(output real intra_progress);
    begin
        if (start_cnt > finish_cnt) begin
            intra_progress = clk_cnt - start_timestamp[finish_cnt];
        end else if(finish_cnt > 0) begin
            intra_progress = LATENCY_ESTIMATION;
        end else begin
            intra_progress = 0;
        end
        intra_progress = intra_progress / LATENCY_ESTIMATION;
    end
endtask

task print_progress();
    real intra_progress;
    begin
        if (LATENCY_ESTIMATION > 0) begin
            get_intra_progress(intra_progress);
            $display("// RTL Simulation : %0d / %0d [%2.2f%%] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, intra_progress * 100, $time);
        end else begin
            $display("// RTL Simulation : %0d / %0d [n/a] @ \"%0t\"", finish_cnt, AUTOTB_TRANSACTION_NUM, $time);
        end
    end
endtask

task calculate_performance();
    integer i;
    integer fp;
    reg [31:0] latency [0:AUTOTB_TRANSACTION_NUM - 1];
    reg [31:0] latency_min;
    reg [31:0] latency_max;
    reg [31:0] latency_total;
    reg [31:0] latency_average;
    reg [31:0] interval [0:AUTOTB_TRANSACTION_NUM - 2];
    reg [31:0] interval_min;
    reg [31:0] interval_max;
    reg [31:0] interval_total;
    reg [31:0] interval_average;
    reg [31:0] total_execute_time;
    begin
        latency_min = -1;
        latency_max = 0;
        latency_total = 0;
        interval_min = -1;
        interval_max = 0;
        interval_total = 0;
        total_execute_time = lat_total;

        for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
            // calculate latency
            latency[i] = finish_timestamp[i] - start_timestamp[i];
            if (latency[i] > latency_max) latency_max = latency[i];
            if (latency[i] < latency_min) latency_min = latency[i];
            latency_total = latency_total + latency[i];
            // calculate interval
            if (AUTOTB_TRANSACTION_NUM == 1) begin
                interval[i] = 0;
                interval_max = 0;
                interval_min = 0;
                interval_total = 0;
            end else if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                interval[i] = start_timestamp[i + 1] - start_timestamp[i];
                if (interval[i] > interval_max) interval_max = interval[i];
                if (interval[i] < interval_min) interval_min = interval[i];
                interval_total = interval_total + interval[i];
            end
        end

        latency_average = latency_total / AUTOTB_TRANSACTION_NUM;
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            interval_average = 0;
        end else begin
            interval_average = interval_total / (AUTOTB_TRANSACTION_NUM - 1);
        end

        fp = $fopen(`AUTOTB_LAT_RESULT_FILE, "w");

        $fdisplay(fp, "$MAX_LATENCY = \"%0d\"", latency_max);
        $fdisplay(fp, "$MIN_LATENCY = \"%0d\"", latency_min);
        $fdisplay(fp, "$AVER_LATENCY = \"%0d\"", latency_average);
        $fdisplay(fp, "$MAX_THROUGHPUT = \"%0d\"", interval_max);
        $fdisplay(fp, "$MIN_THROUGHPUT = \"%0d\"", interval_min);
        $fdisplay(fp, "$AVER_THROUGHPUT = \"%0d\"", interval_average);
        $fdisplay(fp, "$TOTAL_EXECUTE_TIME = \"%0d\"", total_execute_time);

        $fclose(fp);

        fp = $fopen(`AUTOTB_PER_RESULT_TRANS_FILE, "w");

        $fdisplay(fp, "%20s%16s%16s", "", "latency", "interval");
        if (AUTOTB_TRANSACTION_NUM == 1) begin
            i = 0;
            $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
        end else begin
            for (i = 0; i < AUTOTB_TRANSACTION_NUM; i = i + 1) begin
                if (i < AUTOTB_TRANSACTION_NUM - 1) begin
                    $fdisplay(fp, "transaction%8d:%16d%16d", i, latency[i], interval[i]);
                end else begin
                    $fdisplay(fp, "transaction%8d:%16d               x", i, latency[i]);
                end
            end
        end

        $fclose(fp);
    end
endtask


////////////////////////////////////////////
// Dependence Check
////////////////////////////////////////////

`ifndef POST_SYN

`endif
///////////////////////////////////////////////////////
// dataflow status monitor
///////////////////////////////////////////////////////
dataflow_monitor U_dataflow_monitor(
    .clock(AESL_clock),
    .reset(~rst),
    .finish(all_finish));

`include "fifo_para.vh"
endmodule
