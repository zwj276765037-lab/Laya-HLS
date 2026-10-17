// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
// control
// 0x0 : Control signals
//       bit 0  - ap_start (Read/Write/COH)
//       bit 1  - ap_done (Read/COR)
//       bit 2  - ap_idle (Read)
//       bit 3  - ap_ready (Read/COR)
//       bit 7  - auto_restart (Read/Write)
//       bit 9  - interrupt (Read)
//       others - reserved
// 0x4 : Global Interrupt Enable Register
//       bit 0  - Global Interrupt Enable (Read/Write)
//       others - reserved
// 0x8 : IP Interrupt Enable Register (Read/Write)
//       bit 0 - enable ap_done interrupt (Read/Write)
//       bit 1 - enable ap_ready interrupt (Read/Write)
//       others - reserved
// 0xc : IP Interrupt Status Register (Read/TOW)
//       bit 0 - ap_done (Read/TOW)
//       bit 1 - ap_ready (Read/TOW)
//       others - reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL 0x0
#define XATTENTION_SLICE_CONTROL_ADDR_GIE     0x4
#define XATTENTION_SLICE_CONTROL_ADDR_IER     0x8
#define XATTENTION_SLICE_CONTROL_ADDR_ISR     0xc

// control_r
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of fixture_r
//        bit 31~0 - fixture_r[31:0] (Read/Write)
// 0x14 : Data signal of fixture_r
//        bit 31~0 - fixture_r[63:32] (Read/Write)
// 0x18 : reserved
// 0x1c : Data signal of io_r
//        bit 31~0 - io_r[31:0] (Read/Write)
// 0x20 : Data signal of io_r
//        bit 31~0 - io_r[63:32] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of aux_r
//        bit 31~0 - aux_r[31:0] (Read/Write)
// 0x2c : Data signal of aux_r
//        bit 31~0 - aux_r[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[31:0] (Read/Write)
// 0x38 : Data signal of qkv0_r
//        bit 31~0 - qkv0_r[63:32] (Read/Write)
// 0x3c : reserved
// 0x40 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[31:0] (Read/Write)
// 0x44 : Data signal of qkv1_r
//        bit 31~0 - qkv1_r[63:32] (Read/Write)
// 0x48 : reserved
// 0x4c : Data signal of att_out_r
//        bit 31~0 - att_out_r[31:0] (Read/Write)
// 0x50 : Data signal of att_out_r
//        bit 31~0 - att_out_r[63:32] (Read/Write)
// 0x54 : reserved
// 0x58 : Data signal of observed_r
//        bit 31~0 - observed_r[31:0] (Read/Write)
// 0x5c : Data signal of observed_r
//        bit 31~0 - observed_r[63:32] (Read/Write)
// 0x60 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XATTENTION_SLICE_CONTROL_R_ADDR_FIXTURE_R_DATA  0x10
#define XATTENTION_SLICE_CONTROL_R_BITS_FIXTURE_R_DATA  64
#define XATTENTION_SLICE_CONTROL_R_ADDR_IO_R_DATA       0x1c
#define XATTENTION_SLICE_CONTROL_R_BITS_IO_R_DATA       64
#define XATTENTION_SLICE_CONTROL_R_ADDR_AUX_R_DATA      0x28
#define XATTENTION_SLICE_CONTROL_R_BITS_AUX_R_DATA      64
#define XATTENTION_SLICE_CONTROL_R_ADDR_QKV0_R_DATA     0x34
#define XATTENTION_SLICE_CONTROL_R_BITS_QKV0_R_DATA     64
#define XATTENTION_SLICE_CONTROL_R_ADDR_QKV1_R_DATA     0x40
#define XATTENTION_SLICE_CONTROL_R_BITS_QKV1_R_DATA     64
#define XATTENTION_SLICE_CONTROL_R_ADDR_ATT_OUT_R_DATA  0x4c
#define XATTENTION_SLICE_CONTROL_R_BITS_ATT_OUT_R_DATA  64
#define XATTENTION_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA 0x58
#define XATTENTION_SLICE_CONTROL_R_BITS_OBSERVED_R_DATA 64

