//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef SV_MODULE_TOP_SV
`define SV_MODULE_TOP_SV


`timescale 1ns/1ps


`include "uvm_macros.svh"
import uvm_pkg::*;
import file_agent_pkg::*;
import attention_slice_subsystem_pkg::*;
`include "attention_slice_subsys_test_sequence_lib.sv"
`include "attention_slice_test_lib.sv"


module sv_module_top;


    misc_interface              misc_if ( .clock(apatb_attention_slice_top.AESL_clock), .reset(apatb_attention_slice_top.AESL_reset) );
    assign misc_if.dut2tb_ap_ready = apatb_attention_slice_top.AESL_inst_attention_slice.ap_ready;
    assign misc_if.dut2tb_ap_done_kernel = apatb_attention_slice_top.AESL_inst_attention_slice.ap_done;
    initial begin
        uvm_config_db #(virtual misc_interface)::set(null, "uvm_test_top.top_env.*", "misc_if", misc_if);
    end


    axi_if #(64,4,8,3,1)  axi_fixture_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_fixture_if.AWVALID = apatb_attention_slice_top.fixture_AWVALID;
    assign apatb_attention_slice_top.fixture_AWREADY = axi_fixture_if.AWREADY;
    assign axi_fixture_if.AWADDR = apatb_attention_slice_top.fixture_AWADDR;
    assign axi_fixture_if.AWID = apatb_attention_slice_top.fixture_AWID;
    assign axi_fixture_if.AWLEN = apatb_attention_slice_top.fixture_AWLEN;
    assign axi_fixture_if.AWSIZE = apatb_attention_slice_top.fixture_AWSIZE;
    assign axi_fixture_if.AWBURST = apatb_attention_slice_top.fixture_AWBURST;
    assign axi_fixture_if.AWLOCK = apatb_attention_slice_top.fixture_AWLOCK;
    assign axi_fixture_if.AWCACHE = apatb_attention_slice_top.fixture_AWCACHE;
    assign axi_fixture_if.AWPROT = apatb_attention_slice_top.fixture_AWPROT;
    assign axi_fixture_if.AWQOS = apatb_attention_slice_top.fixture_AWQOS;
    assign axi_fixture_if.AWREGION = apatb_attention_slice_top.fixture_AWREGION;
    assign axi_fixture_if.AWUSER = apatb_attention_slice_top.fixture_AWUSER;
    assign axi_fixture_if.WVALID = apatb_attention_slice_top.fixture_WVALID;
    assign apatb_attention_slice_top.fixture_WREADY = axi_fixture_if.WREADY;
    assign axi_fixture_if.WDATA = apatb_attention_slice_top.fixture_WDATA;
    assign axi_fixture_if.WSTRB = apatb_attention_slice_top.fixture_WSTRB;
    assign axi_fixture_if.WLAST = apatb_attention_slice_top.fixture_WLAST;
    assign axi_fixture_if.WID = apatb_attention_slice_top.fixture_WID;
    assign axi_fixture_if.WUSER = apatb_attention_slice_top.fixture_WUSER;
    assign axi_fixture_if.ARVALID = apatb_attention_slice_top.fixture_ARVALID;
    assign apatb_attention_slice_top.fixture_ARREADY = axi_fixture_if.ARREADY;
    assign axi_fixture_if.ARADDR = apatb_attention_slice_top.fixture_ARADDR;
    assign axi_fixture_if.ARID = apatb_attention_slice_top.fixture_ARID;
    assign axi_fixture_if.ARLEN = apatb_attention_slice_top.fixture_ARLEN;
    assign axi_fixture_if.ARSIZE = apatb_attention_slice_top.fixture_ARSIZE;
    assign axi_fixture_if.ARBURST = apatb_attention_slice_top.fixture_ARBURST;
    assign axi_fixture_if.ARLOCK = apatb_attention_slice_top.fixture_ARLOCK;
    assign axi_fixture_if.ARCACHE = apatb_attention_slice_top.fixture_ARCACHE;
    assign axi_fixture_if.ARPROT = apatb_attention_slice_top.fixture_ARPROT;
    assign axi_fixture_if.ARQOS = apatb_attention_slice_top.fixture_ARQOS;
    assign axi_fixture_if.ARREGION = apatb_attention_slice_top.fixture_ARREGION;
    assign axi_fixture_if.ARUSER = apatb_attention_slice_top.fixture_ARUSER;
    assign apatb_attention_slice_top.fixture_RVALID = axi_fixture_if.RVALID;
    assign axi_fixture_if.RREADY = apatb_attention_slice_top.fixture_RREADY;
    assign apatb_attention_slice_top.fixture_RDATA = axi_fixture_if.RDATA;
    assign apatb_attention_slice_top.fixture_RLAST = axi_fixture_if.RLAST;
    assign apatb_attention_slice_top.fixture_RID = axi_fixture_if.RID;
    assign apatb_attention_slice_top.fixture_RUSER = axi_fixture_if.RUSER;
    assign apatb_attention_slice_top.fixture_RRESP = axi_fixture_if.RRESP;
    assign apatb_attention_slice_top.fixture_BVALID = axi_fixture_if.BVALID;
    assign axi_fixture_if.BREADY = apatb_attention_slice_top.fixture_BREADY;
    assign apatb_attention_slice_top.fixture_BRESP = axi_fixture_if.BRESP;
    assign apatb_attention_slice_top.fixture_BID = axi_fixture_if.BID;
    assign apatb_attention_slice_top.fixture_BUSER = axi_fixture_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_fixture.*", "vif", axi_fixture_if);
    end


    axi_if #(64,4,8,3,1)  axi_io_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_io_if.AWVALID = apatb_attention_slice_top.io_AWVALID;
    assign apatb_attention_slice_top.io_AWREADY = axi_io_if.AWREADY;
    assign axi_io_if.AWADDR = apatb_attention_slice_top.io_AWADDR;
    assign axi_io_if.AWID = apatb_attention_slice_top.io_AWID;
    assign axi_io_if.AWLEN = apatb_attention_slice_top.io_AWLEN;
    assign axi_io_if.AWSIZE = apatb_attention_slice_top.io_AWSIZE;
    assign axi_io_if.AWBURST = apatb_attention_slice_top.io_AWBURST;
    assign axi_io_if.AWLOCK = apatb_attention_slice_top.io_AWLOCK;
    assign axi_io_if.AWCACHE = apatb_attention_slice_top.io_AWCACHE;
    assign axi_io_if.AWPROT = apatb_attention_slice_top.io_AWPROT;
    assign axi_io_if.AWQOS = apatb_attention_slice_top.io_AWQOS;
    assign axi_io_if.AWREGION = apatb_attention_slice_top.io_AWREGION;
    assign axi_io_if.AWUSER = apatb_attention_slice_top.io_AWUSER;
    assign axi_io_if.WVALID = apatb_attention_slice_top.io_WVALID;
    assign apatb_attention_slice_top.io_WREADY = axi_io_if.WREADY;
    assign axi_io_if.WDATA = apatb_attention_slice_top.io_WDATA;
    assign axi_io_if.WSTRB = apatb_attention_slice_top.io_WSTRB;
    assign axi_io_if.WLAST = apatb_attention_slice_top.io_WLAST;
    assign axi_io_if.WID = apatb_attention_slice_top.io_WID;
    assign axi_io_if.WUSER = apatb_attention_slice_top.io_WUSER;
    assign axi_io_if.ARVALID = apatb_attention_slice_top.io_ARVALID;
    assign apatb_attention_slice_top.io_ARREADY = axi_io_if.ARREADY;
    assign axi_io_if.ARADDR = apatb_attention_slice_top.io_ARADDR;
    assign axi_io_if.ARID = apatb_attention_slice_top.io_ARID;
    assign axi_io_if.ARLEN = apatb_attention_slice_top.io_ARLEN;
    assign axi_io_if.ARSIZE = apatb_attention_slice_top.io_ARSIZE;
    assign axi_io_if.ARBURST = apatb_attention_slice_top.io_ARBURST;
    assign axi_io_if.ARLOCK = apatb_attention_slice_top.io_ARLOCK;
    assign axi_io_if.ARCACHE = apatb_attention_slice_top.io_ARCACHE;
    assign axi_io_if.ARPROT = apatb_attention_slice_top.io_ARPROT;
    assign axi_io_if.ARQOS = apatb_attention_slice_top.io_ARQOS;
    assign axi_io_if.ARREGION = apatb_attention_slice_top.io_ARREGION;
    assign axi_io_if.ARUSER = apatb_attention_slice_top.io_ARUSER;
    assign apatb_attention_slice_top.io_RVALID = axi_io_if.RVALID;
    assign axi_io_if.RREADY = apatb_attention_slice_top.io_RREADY;
    assign apatb_attention_slice_top.io_RDATA = axi_io_if.RDATA;
    assign apatb_attention_slice_top.io_RLAST = axi_io_if.RLAST;
    assign apatb_attention_slice_top.io_RID = axi_io_if.RID;
    assign apatb_attention_slice_top.io_RUSER = axi_io_if.RUSER;
    assign apatb_attention_slice_top.io_RRESP = axi_io_if.RRESP;
    assign apatb_attention_slice_top.io_BVALID = axi_io_if.BVALID;
    assign axi_io_if.BREADY = apatb_attention_slice_top.io_BREADY;
    assign apatb_attention_slice_top.io_BRESP = axi_io_if.BRESP;
    assign apatb_attention_slice_top.io_BID = axi_io_if.BID;
    assign apatb_attention_slice_top.io_BUSER = axi_io_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_io.*", "vif", axi_io_if);
    end


    axi_if #(64,4,8,3,1)  axi_aux_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_aux_if.AWVALID = apatb_attention_slice_top.aux_AWVALID;
    assign apatb_attention_slice_top.aux_AWREADY = axi_aux_if.AWREADY;
    assign axi_aux_if.AWADDR = apatb_attention_slice_top.aux_AWADDR;
    assign axi_aux_if.AWID = apatb_attention_slice_top.aux_AWID;
    assign axi_aux_if.AWLEN = apatb_attention_slice_top.aux_AWLEN;
    assign axi_aux_if.AWSIZE = apatb_attention_slice_top.aux_AWSIZE;
    assign axi_aux_if.AWBURST = apatb_attention_slice_top.aux_AWBURST;
    assign axi_aux_if.AWLOCK = apatb_attention_slice_top.aux_AWLOCK;
    assign axi_aux_if.AWCACHE = apatb_attention_slice_top.aux_AWCACHE;
    assign axi_aux_if.AWPROT = apatb_attention_slice_top.aux_AWPROT;
    assign axi_aux_if.AWQOS = apatb_attention_slice_top.aux_AWQOS;
    assign axi_aux_if.AWREGION = apatb_attention_slice_top.aux_AWREGION;
    assign axi_aux_if.AWUSER = apatb_attention_slice_top.aux_AWUSER;
    assign axi_aux_if.WVALID = apatb_attention_slice_top.aux_WVALID;
    assign apatb_attention_slice_top.aux_WREADY = axi_aux_if.WREADY;
    assign axi_aux_if.WDATA = apatb_attention_slice_top.aux_WDATA;
    assign axi_aux_if.WSTRB = apatb_attention_slice_top.aux_WSTRB;
    assign axi_aux_if.WLAST = apatb_attention_slice_top.aux_WLAST;
    assign axi_aux_if.WID = apatb_attention_slice_top.aux_WID;
    assign axi_aux_if.WUSER = apatb_attention_slice_top.aux_WUSER;
    assign axi_aux_if.ARVALID = apatb_attention_slice_top.aux_ARVALID;
    assign apatb_attention_slice_top.aux_ARREADY = axi_aux_if.ARREADY;
    assign axi_aux_if.ARADDR = apatb_attention_slice_top.aux_ARADDR;
    assign axi_aux_if.ARID = apatb_attention_slice_top.aux_ARID;
    assign axi_aux_if.ARLEN = apatb_attention_slice_top.aux_ARLEN;
    assign axi_aux_if.ARSIZE = apatb_attention_slice_top.aux_ARSIZE;
    assign axi_aux_if.ARBURST = apatb_attention_slice_top.aux_ARBURST;
    assign axi_aux_if.ARLOCK = apatb_attention_slice_top.aux_ARLOCK;
    assign axi_aux_if.ARCACHE = apatb_attention_slice_top.aux_ARCACHE;
    assign axi_aux_if.ARPROT = apatb_attention_slice_top.aux_ARPROT;
    assign axi_aux_if.ARQOS = apatb_attention_slice_top.aux_ARQOS;
    assign axi_aux_if.ARREGION = apatb_attention_slice_top.aux_ARREGION;
    assign axi_aux_if.ARUSER = apatb_attention_slice_top.aux_ARUSER;
    assign apatb_attention_slice_top.aux_RVALID = axi_aux_if.RVALID;
    assign axi_aux_if.RREADY = apatb_attention_slice_top.aux_RREADY;
    assign apatb_attention_slice_top.aux_RDATA = axi_aux_if.RDATA;
    assign apatb_attention_slice_top.aux_RLAST = axi_aux_if.RLAST;
    assign apatb_attention_slice_top.aux_RID = axi_aux_if.RID;
    assign apatb_attention_slice_top.aux_RUSER = axi_aux_if.RUSER;
    assign apatb_attention_slice_top.aux_RRESP = axi_aux_if.RRESP;
    assign apatb_attention_slice_top.aux_BVALID = axi_aux_if.BVALID;
    assign axi_aux_if.BREADY = apatb_attention_slice_top.aux_BREADY;
    assign apatb_attention_slice_top.aux_BRESP = axi_aux_if.BRESP;
    assign apatb_attention_slice_top.aux_BID = axi_aux_if.BID;
    assign apatb_attention_slice_top.aux_BUSER = axi_aux_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_aux.*", "vif", axi_aux_if);
    end


    axi_if #(64,4,8,3,1)  axi_qkv0_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_qkv0_if.AWVALID = apatb_attention_slice_top.qkv0_AWVALID;
    assign apatb_attention_slice_top.qkv0_AWREADY = axi_qkv0_if.AWREADY;
    assign axi_qkv0_if.AWADDR = apatb_attention_slice_top.qkv0_AWADDR;
    assign axi_qkv0_if.AWID = apatb_attention_slice_top.qkv0_AWID;
    assign axi_qkv0_if.AWLEN = apatb_attention_slice_top.qkv0_AWLEN;
    assign axi_qkv0_if.AWSIZE = apatb_attention_slice_top.qkv0_AWSIZE;
    assign axi_qkv0_if.AWBURST = apatb_attention_slice_top.qkv0_AWBURST;
    assign axi_qkv0_if.AWLOCK = apatb_attention_slice_top.qkv0_AWLOCK;
    assign axi_qkv0_if.AWCACHE = apatb_attention_slice_top.qkv0_AWCACHE;
    assign axi_qkv0_if.AWPROT = apatb_attention_slice_top.qkv0_AWPROT;
    assign axi_qkv0_if.AWQOS = apatb_attention_slice_top.qkv0_AWQOS;
    assign axi_qkv0_if.AWREGION = apatb_attention_slice_top.qkv0_AWREGION;
    assign axi_qkv0_if.AWUSER = apatb_attention_slice_top.qkv0_AWUSER;
    assign axi_qkv0_if.WVALID = apatb_attention_slice_top.qkv0_WVALID;
    assign apatb_attention_slice_top.qkv0_WREADY = axi_qkv0_if.WREADY;
    assign axi_qkv0_if.WDATA = apatb_attention_slice_top.qkv0_WDATA;
    assign axi_qkv0_if.WSTRB = apatb_attention_slice_top.qkv0_WSTRB;
    assign axi_qkv0_if.WLAST = apatb_attention_slice_top.qkv0_WLAST;
    assign axi_qkv0_if.WID = apatb_attention_slice_top.qkv0_WID;
    assign axi_qkv0_if.WUSER = apatb_attention_slice_top.qkv0_WUSER;
    assign axi_qkv0_if.ARVALID = apatb_attention_slice_top.qkv0_ARVALID;
    assign apatb_attention_slice_top.qkv0_ARREADY = axi_qkv0_if.ARREADY;
    assign axi_qkv0_if.ARADDR = apatb_attention_slice_top.qkv0_ARADDR;
    assign axi_qkv0_if.ARID = apatb_attention_slice_top.qkv0_ARID;
    assign axi_qkv0_if.ARLEN = apatb_attention_slice_top.qkv0_ARLEN;
    assign axi_qkv0_if.ARSIZE = apatb_attention_slice_top.qkv0_ARSIZE;
    assign axi_qkv0_if.ARBURST = apatb_attention_slice_top.qkv0_ARBURST;
    assign axi_qkv0_if.ARLOCK = apatb_attention_slice_top.qkv0_ARLOCK;
    assign axi_qkv0_if.ARCACHE = apatb_attention_slice_top.qkv0_ARCACHE;
    assign axi_qkv0_if.ARPROT = apatb_attention_slice_top.qkv0_ARPROT;
    assign axi_qkv0_if.ARQOS = apatb_attention_slice_top.qkv0_ARQOS;
    assign axi_qkv0_if.ARREGION = apatb_attention_slice_top.qkv0_ARREGION;
    assign axi_qkv0_if.ARUSER = apatb_attention_slice_top.qkv0_ARUSER;
    assign apatb_attention_slice_top.qkv0_RVALID = axi_qkv0_if.RVALID;
    assign axi_qkv0_if.RREADY = apatb_attention_slice_top.qkv0_RREADY;
    assign apatb_attention_slice_top.qkv0_RDATA = axi_qkv0_if.RDATA;
    assign apatb_attention_slice_top.qkv0_RLAST = axi_qkv0_if.RLAST;
    assign apatb_attention_slice_top.qkv0_RID = axi_qkv0_if.RID;
    assign apatb_attention_slice_top.qkv0_RUSER = axi_qkv0_if.RUSER;
    assign apatb_attention_slice_top.qkv0_RRESP = axi_qkv0_if.RRESP;
    assign apatb_attention_slice_top.qkv0_BVALID = axi_qkv0_if.BVALID;
    assign axi_qkv0_if.BREADY = apatb_attention_slice_top.qkv0_BREADY;
    assign apatb_attention_slice_top.qkv0_BRESP = axi_qkv0_if.BRESP;
    assign apatb_attention_slice_top.qkv0_BID = axi_qkv0_if.BID;
    assign apatb_attention_slice_top.qkv0_BUSER = axi_qkv0_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_qkv0.*", "vif", axi_qkv0_if);
    end


    axi_if #(64,4,8,3,1)  axi_qkv1_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_qkv1_if.AWVALID = apatb_attention_slice_top.qkv1_AWVALID;
    assign apatb_attention_slice_top.qkv1_AWREADY = axi_qkv1_if.AWREADY;
    assign axi_qkv1_if.AWADDR = apatb_attention_slice_top.qkv1_AWADDR;
    assign axi_qkv1_if.AWID = apatb_attention_slice_top.qkv1_AWID;
    assign axi_qkv1_if.AWLEN = apatb_attention_slice_top.qkv1_AWLEN;
    assign axi_qkv1_if.AWSIZE = apatb_attention_slice_top.qkv1_AWSIZE;
    assign axi_qkv1_if.AWBURST = apatb_attention_slice_top.qkv1_AWBURST;
    assign axi_qkv1_if.AWLOCK = apatb_attention_slice_top.qkv1_AWLOCK;
    assign axi_qkv1_if.AWCACHE = apatb_attention_slice_top.qkv1_AWCACHE;
    assign axi_qkv1_if.AWPROT = apatb_attention_slice_top.qkv1_AWPROT;
    assign axi_qkv1_if.AWQOS = apatb_attention_slice_top.qkv1_AWQOS;
    assign axi_qkv1_if.AWREGION = apatb_attention_slice_top.qkv1_AWREGION;
    assign axi_qkv1_if.AWUSER = apatb_attention_slice_top.qkv1_AWUSER;
    assign axi_qkv1_if.WVALID = apatb_attention_slice_top.qkv1_WVALID;
    assign apatb_attention_slice_top.qkv1_WREADY = axi_qkv1_if.WREADY;
    assign axi_qkv1_if.WDATA = apatb_attention_slice_top.qkv1_WDATA;
    assign axi_qkv1_if.WSTRB = apatb_attention_slice_top.qkv1_WSTRB;
    assign axi_qkv1_if.WLAST = apatb_attention_slice_top.qkv1_WLAST;
    assign axi_qkv1_if.WID = apatb_attention_slice_top.qkv1_WID;
    assign axi_qkv1_if.WUSER = apatb_attention_slice_top.qkv1_WUSER;
    assign axi_qkv1_if.ARVALID = apatb_attention_slice_top.qkv1_ARVALID;
    assign apatb_attention_slice_top.qkv1_ARREADY = axi_qkv1_if.ARREADY;
    assign axi_qkv1_if.ARADDR = apatb_attention_slice_top.qkv1_ARADDR;
    assign axi_qkv1_if.ARID = apatb_attention_slice_top.qkv1_ARID;
    assign axi_qkv1_if.ARLEN = apatb_attention_slice_top.qkv1_ARLEN;
    assign axi_qkv1_if.ARSIZE = apatb_attention_slice_top.qkv1_ARSIZE;
    assign axi_qkv1_if.ARBURST = apatb_attention_slice_top.qkv1_ARBURST;
    assign axi_qkv1_if.ARLOCK = apatb_attention_slice_top.qkv1_ARLOCK;
    assign axi_qkv1_if.ARCACHE = apatb_attention_slice_top.qkv1_ARCACHE;
    assign axi_qkv1_if.ARPROT = apatb_attention_slice_top.qkv1_ARPROT;
    assign axi_qkv1_if.ARQOS = apatb_attention_slice_top.qkv1_ARQOS;
    assign axi_qkv1_if.ARREGION = apatb_attention_slice_top.qkv1_ARREGION;
    assign axi_qkv1_if.ARUSER = apatb_attention_slice_top.qkv1_ARUSER;
    assign apatb_attention_slice_top.qkv1_RVALID = axi_qkv1_if.RVALID;
    assign axi_qkv1_if.RREADY = apatb_attention_slice_top.qkv1_RREADY;
    assign apatb_attention_slice_top.qkv1_RDATA = axi_qkv1_if.RDATA;
    assign apatb_attention_slice_top.qkv1_RLAST = axi_qkv1_if.RLAST;
    assign apatb_attention_slice_top.qkv1_RID = axi_qkv1_if.RID;
    assign apatb_attention_slice_top.qkv1_RUSER = axi_qkv1_if.RUSER;
    assign apatb_attention_slice_top.qkv1_RRESP = axi_qkv1_if.RRESP;
    assign apatb_attention_slice_top.qkv1_BVALID = axi_qkv1_if.BVALID;
    assign axi_qkv1_if.BREADY = apatb_attention_slice_top.qkv1_BREADY;
    assign apatb_attention_slice_top.qkv1_BRESP = axi_qkv1_if.BRESP;
    assign apatb_attention_slice_top.qkv1_BID = axi_qkv1_if.BID;
    assign apatb_attention_slice_top.qkv1_BUSER = axi_qkv1_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_qkv1.*", "vif", axi_qkv1_if);
    end


    axi_if #(64,4,8,3,1)  axi_att_out_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_att_out_if.AWVALID = apatb_attention_slice_top.att_out_AWVALID;
    assign apatb_attention_slice_top.att_out_AWREADY = axi_att_out_if.AWREADY;
    assign axi_att_out_if.AWADDR = apatb_attention_slice_top.att_out_AWADDR;
    assign axi_att_out_if.AWID = apatb_attention_slice_top.att_out_AWID;
    assign axi_att_out_if.AWLEN = apatb_attention_slice_top.att_out_AWLEN;
    assign axi_att_out_if.AWSIZE = apatb_attention_slice_top.att_out_AWSIZE;
    assign axi_att_out_if.AWBURST = apatb_attention_slice_top.att_out_AWBURST;
    assign axi_att_out_if.AWLOCK = apatb_attention_slice_top.att_out_AWLOCK;
    assign axi_att_out_if.AWCACHE = apatb_attention_slice_top.att_out_AWCACHE;
    assign axi_att_out_if.AWPROT = apatb_attention_slice_top.att_out_AWPROT;
    assign axi_att_out_if.AWQOS = apatb_attention_slice_top.att_out_AWQOS;
    assign axi_att_out_if.AWREGION = apatb_attention_slice_top.att_out_AWREGION;
    assign axi_att_out_if.AWUSER = apatb_attention_slice_top.att_out_AWUSER;
    assign axi_att_out_if.WVALID = apatb_attention_slice_top.att_out_WVALID;
    assign apatb_attention_slice_top.att_out_WREADY = axi_att_out_if.WREADY;
    assign axi_att_out_if.WDATA = apatb_attention_slice_top.att_out_WDATA;
    assign axi_att_out_if.WSTRB = apatb_attention_slice_top.att_out_WSTRB;
    assign axi_att_out_if.WLAST = apatb_attention_slice_top.att_out_WLAST;
    assign axi_att_out_if.WID = apatb_attention_slice_top.att_out_WID;
    assign axi_att_out_if.WUSER = apatb_attention_slice_top.att_out_WUSER;
    assign axi_att_out_if.ARVALID = apatb_attention_slice_top.att_out_ARVALID;
    assign apatb_attention_slice_top.att_out_ARREADY = axi_att_out_if.ARREADY;
    assign axi_att_out_if.ARADDR = apatb_attention_slice_top.att_out_ARADDR;
    assign axi_att_out_if.ARID = apatb_attention_slice_top.att_out_ARID;
    assign axi_att_out_if.ARLEN = apatb_attention_slice_top.att_out_ARLEN;
    assign axi_att_out_if.ARSIZE = apatb_attention_slice_top.att_out_ARSIZE;
    assign axi_att_out_if.ARBURST = apatb_attention_slice_top.att_out_ARBURST;
    assign axi_att_out_if.ARLOCK = apatb_attention_slice_top.att_out_ARLOCK;
    assign axi_att_out_if.ARCACHE = apatb_attention_slice_top.att_out_ARCACHE;
    assign axi_att_out_if.ARPROT = apatb_attention_slice_top.att_out_ARPROT;
    assign axi_att_out_if.ARQOS = apatb_attention_slice_top.att_out_ARQOS;
    assign axi_att_out_if.ARREGION = apatb_attention_slice_top.att_out_ARREGION;
    assign axi_att_out_if.ARUSER = apatb_attention_slice_top.att_out_ARUSER;
    assign apatb_attention_slice_top.att_out_RVALID = axi_att_out_if.RVALID;
    assign axi_att_out_if.RREADY = apatb_attention_slice_top.att_out_RREADY;
    assign apatb_attention_slice_top.att_out_RDATA = axi_att_out_if.RDATA;
    assign apatb_attention_slice_top.att_out_RLAST = axi_att_out_if.RLAST;
    assign apatb_attention_slice_top.att_out_RID = axi_att_out_if.RID;
    assign apatb_attention_slice_top.att_out_RUSER = axi_att_out_if.RUSER;
    assign apatb_attention_slice_top.att_out_RRESP = axi_att_out_if.RRESP;
    assign apatb_attention_slice_top.att_out_BVALID = axi_att_out_if.BVALID;
    assign axi_att_out_if.BREADY = apatb_attention_slice_top.att_out_BREADY;
    assign apatb_attention_slice_top.att_out_BRESP = axi_att_out_if.BRESP;
    assign apatb_attention_slice_top.att_out_BID = axi_att_out_if.BID;
    assign apatb_attention_slice_top.att_out_BUSER = axi_att_out_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_att_out.*", "vif", axi_att_out_if);
    end


    axi_if #(64,4,8,3,1)  axi_observed_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign axi_observed_if.AWVALID = apatb_attention_slice_top.observed_AWVALID;
    assign apatb_attention_slice_top.observed_AWREADY = axi_observed_if.AWREADY;
    assign axi_observed_if.AWADDR = apatb_attention_slice_top.observed_AWADDR;
    assign axi_observed_if.AWID = apatb_attention_slice_top.observed_AWID;
    assign axi_observed_if.AWLEN = apatb_attention_slice_top.observed_AWLEN;
    assign axi_observed_if.AWSIZE = apatb_attention_slice_top.observed_AWSIZE;
    assign axi_observed_if.AWBURST = apatb_attention_slice_top.observed_AWBURST;
    assign axi_observed_if.AWLOCK = apatb_attention_slice_top.observed_AWLOCK;
    assign axi_observed_if.AWCACHE = apatb_attention_slice_top.observed_AWCACHE;
    assign axi_observed_if.AWPROT = apatb_attention_slice_top.observed_AWPROT;
    assign axi_observed_if.AWQOS = apatb_attention_slice_top.observed_AWQOS;
    assign axi_observed_if.AWREGION = apatb_attention_slice_top.observed_AWREGION;
    assign axi_observed_if.AWUSER = apatb_attention_slice_top.observed_AWUSER;
    assign axi_observed_if.WVALID = apatb_attention_slice_top.observed_WVALID;
    assign apatb_attention_slice_top.observed_WREADY = axi_observed_if.WREADY;
    assign axi_observed_if.WDATA = apatb_attention_slice_top.observed_WDATA;
    assign axi_observed_if.WSTRB = apatb_attention_slice_top.observed_WSTRB;
    assign axi_observed_if.WLAST = apatb_attention_slice_top.observed_WLAST;
    assign axi_observed_if.WID = apatb_attention_slice_top.observed_WID;
    assign axi_observed_if.WUSER = apatb_attention_slice_top.observed_WUSER;
    assign axi_observed_if.ARVALID = apatb_attention_slice_top.observed_ARVALID;
    assign apatb_attention_slice_top.observed_ARREADY = axi_observed_if.ARREADY;
    assign axi_observed_if.ARADDR = apatb_attention_slice_top.observed_ARADDR;
    assign axi_observed_if.ARID = apatb_attention_slice_top.observed_ARID;
    assign axi_observed_if.ARLEN = apatb_attention_slice_top.observed_ARLEN;
    assign axi_observed_if.ARSIZE = apatb_attention_slice_top.observed_ARSIZE;
    assign axi_observed_if.ARBURST = apatb_attention_slice_top.observed_ARBURST;
    assign axi_observed_if.ARLOCK = apatb_attention_slice_top.observed_ARLOCK;
    assign axi_observed_if.ARCACHE = apatb_attention_slice_top.observed_ARCACHE;
    assign axi_observed_if.ARPROT = apatb_attention_slice_top.observed_ARPROT;
    assign axi_observed_if.ARQOS = apatb_attention_slice_top.observed_ARQOS;
    assign axi_observed_if.ARREGION = apatb_attention_slice_top.observed_ARREGION;
    assign axi_observed_if.ARUSER = apatb_attention_slice_top.observed_ARUSER;
    assign apatb_attention_slice_top.observed_RVALID = axi_observed_if.RVALID;
    assign axi_observed_if.RREADY = apatb_attention_slice_top.observed_RREADY;
    assign apatb_attention_slice_top.observed_RDATA = axi_observed_if.RDATA;
    assign apatb_attention_slice_top.observed_RLAST = axi_observed_if.RLAST;
    assign apatb_attention_slice_top.observed_RID = axi_observed_if.RID;
    assign apatb_attention_slice_top.observed_RUSER = axi_observed_if.RUSER;
    assign apatb_attention_slice_top.observed_RRESP = axi_observed_if.RRESP;
    assign apatb_attention_slice_top.observed_BVALID = axi_observed_if.BVALID;
    assign axi_observed_if.BREADY = apatb_attention_slice_top.observed_BREADY;
    assign apatb_attention_slice_top.observed_BRESP = axi_observed_if.BRESP;
    assign apatb_attention_slice_top.observed_BID = axi_observed_if.BID;
    assign apatb_attention_slice_top.observed_BUSER = axi_observed_if.BUSER;
    initial begin
        uvm_config_db #( virtual axi_if#(64,4,8,3,1) )::set(null, "uvm_test_top.top_env.axi_master_observed.*", "vif", axi_observed_if);
    end


    axi_if #(7,4,4,3,1)  axi_control_r_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign apatb_attention_slice_top.control_r_AWADDR = axi_control_r_if.AWADDR;
    assign apatb_attention_slice_top.control_r_AWVALID = axi_control_r_if.AWVALID;
    assign axi_control_r_if.AWREADY = apatb_attention_slice_top.control_r_AWREADY;
    assign apatb_attention_slice_top.control_r_WVALID = axi_control_r_if.WVALID;
    assign axi_control_r_if.WREADY = apatb_attention_slice_top.control_r_WREADY;
    assign apatb_attention_slice_top.control_r_WDATA = axi_control_r_if.WDATA;
    assign apatb_attention_slice_top.control_r_WSTRB = axi_control_r_if.WSTRB;
    assign apatb_attention_slice_top.control_r_ARADDR = axi_control_r_if.ARADDR;
    assign apatb_attention_slice_top.control_r_ARVALID = axi_control_r_if.ARVALID;
    assign axi_control_r_if.ARREADY = apatb_attention_slice_top.control_r_ARREADY;
    assign axi_control_r_if.RVALID = apatb_attention_slice_top.control_r_RVALID;
    assign apatb_attention_slice_top.control_r_RREADY = axi_control_r_if.RREADY;
    assign axi_control_r_if.RDATA = apatb_attention_slice_top.control_r_RDATA;
    assign axi_control_r_if.RRESP = apatb_attention_slice_top.control_r_RRESP;
    assign axi_control_r_if.BVALID = apatb_attention_slice_top.control_r_BVALID;
    assign apatb_attention_slice_top.control_r_BREADY = axi_control_r_if.BREADY;
    assign axi_control_r_if.BRESP = apatb_attention_slice_top.control_r_BRESP;
    assign axi_control_r_if.BID = 0;
    assign axi_control_r_if.RID = 0;
    assign axi_control_r_if.RLAST = 1;
    initial begin
        uvm_config_db #( virtual axi_if#(7,4,4,3,1) )::set(null, "uvm_test_top.top_env.axi_lite_control_r.*", "vif", axi_control_r_if);
    end


    axi_if #(4,4,4,3,1)  axi_control_if (.clk  (apatb_attention_slice_top.AESL_clock), .rst(apatb_attention_slice_top.AESL_reset));
    assign apatb_attention_slice_top.control_AWADDR = axi_control_if.AWADDR;
    assign apatb_attention_slice_top.control_AWVALID = axi_control_if.AWVALID;
    assign axi_control_if.AWREADY = apatb_attention_slice_top.control_AWREADY;
    assign apatb_attention_slice_top.control_WVALID = axi_control_if.WVALID;
    assign axi_control_if.WREADY = apatb_attention_slice_top.control_WREADY;
    assign apatb_attention_slice_top.control_WDATA = axi_control_if.WDATA;
    assign apatb_attention_slice_top.control_WSTRB = axi_control_if.WSTRB;
    assign apatb_attention_slice_top.control_ARADDR = axi_control_if.ARADDR;
    assign apatb_attention_slice_top.control_ARVALID = axi_control_if.ARVALID;
    assign axi_control_if.ARREADY = apatb_attention_slice_top.control_ARREADY;
    assign axi_control_if.RVALID = apatb_attention_slice_top.control_RVALID;
    assign apatb_attention_slice_top.control_RREADY = axi_control_if.RREADY;
    assign axi_control_if.RDATA = apatb_attention_slice_top.control_RDATA;
    assign axi_control_if.RRESP = apatb_attention_slice_top.control_RRESP;
    assign axi_control_if.BVALID = apatb_attention_slice_top.control_BVALID;
    assign apatb_attention_slice_top.control_BREADY = axi_control_if.BREADY;
    assign axi_control_if.BRESP = apatb_attention_slice_top.control_BRESP;
    assign axi_control_if.BID = 0;
    assign axi_control_if.RID = 0;
    assign axi_control_if.RLAST = 1;
    initial begin
        uvm_config_db #( virtual axi_if#(4,4,4,3,1) )::set(null, "uvm_test_top.top_env.axi_lite_control.*", "vif", axi_control_if);
    end


    initial begin
        run_test();
    end
endmodule
`endif
