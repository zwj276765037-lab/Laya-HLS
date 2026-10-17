// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
// control
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read/COR)
//        bit 7  - auto_restart (Read/Write)
//        bit 9  - interrupt (Read)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0 - enable ap_done interrupt (Read/Write)
//        bit 1 - enable ap_ready interrupt (Read/Write)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0 - ap_done (Read/TOW)
//        bit 1 - ap_ready (Read/TOW)
//        others - reserved
// 0x10 : Data signal of pair_present
//        bit 31~0 - pair_present[31:0] (Read/Write)
// 0x14 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL           0x00
#define XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_GIE               0x04
#define XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER               0x08
#define XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_ISR               0x0c
#define XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_PAIR_PRESENT_DATA 0x10
#define XLINEAR_CONTROLLER_SLICE_CONTROL_BITS_PAIR_PRESENT_DATA 32

// control_r
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of norm_input_r
//        bit 31~0 - norm_input_r[31:0] (Read/Write)
// 0x14 : Data signal of norm_input_r
//        bit 31~0 - norm_input_r[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of io_r
//        bit 31~0 - io_r[31:0] (Read/Write)
// 0x20 : Data signal of io_r
//        bit 31~0 - io_r[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of w_q0_r
//        bit 31~0 - w_q0_r[31:0] (Read/Write)
// 0x2c : Data signal of w_q0_r
//        bit 31~0 - w_q0_r[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of w_q1_r
//        bit 31~0 - w_q1_r[31:0] (Read/Write)
// 0x38 : Data signal of w_q1_r
//        bit 31~0 - w_q1_r[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of w_scale_r
//        bit 31~0 - w_scale_r[31:0] (Read/Write)
// 0x44 : Data signal of w_scale_r
//        bit 31~0 - w_scale_r[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of aux_r
//        bit 31~0 - aux_r[31:0] (Read/Write)
// 0x50 : Data signal of aux_r
//        bit 31~0 - aux_r[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of state0_r
//        bit 31~0 - state0_r[31:0] (Read/Write)
// 0x5c : Data signal of state0_r
//        bit 31~0 - state0_r[63:32] (Read/Write)
// 0x60 : reserved
// 0x64 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[31:0] (Read/Write)
// 0x68 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[63:32] (Read/Write)
// 0x6c : reserved
// 0x70 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[31:0] (Read/Write)
// 0x74 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[63:32] (Read/Write)
// 0x78 : reserved
// 0x7c : Data signal of observed_r
//        bit 31~0 - observed_r[31:0] (Read/Write)
// 0x80 : Data signal of observed_r
//        bit 31~0 - observed_r[63:32] (Read/Write)
// 0x84 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_NORM_INPUT_R_DATA 0x10
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_NORM_INPUT_R_DATA 64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA         0x1c
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_IO_R_DATA         64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q0_R_DATA       0x28
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_W_Q0_R_DATA       64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q1_R_DATA       0x34
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_W_Q1_R_DATA       64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_SCALE_R_DATA    0x40
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_W_SCALE_R_DATA    64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA        0x4c
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_AUX_R_DATA        64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA     0x58
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_STATE0_R_DATA     64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV0_R_DATA       0x64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_QKV0_R_DATA       64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV1_R_DATA       0x70
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_QKV1_R_DATA       64
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA   0x7c
#define XLINEAR_CONTROLLER_SLICE_CONTROL_R_BITS_OBSERVED_R_DATA   64

