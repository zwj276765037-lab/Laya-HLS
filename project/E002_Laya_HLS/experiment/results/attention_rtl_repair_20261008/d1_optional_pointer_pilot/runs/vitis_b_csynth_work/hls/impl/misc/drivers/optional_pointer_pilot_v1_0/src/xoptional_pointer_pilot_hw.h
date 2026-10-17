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
// 0x10 : Data signal of mode
//        bit 7~0 - mode[7:0] (Read/Write)
//        others  - reserved
// 0x14 : reserved
// 0x18 : Data signal of layer
//        bit 7~0 - layer[7:0] (Read/Write)
//        others  - reserved
// 0x1c : reserved
// 0x20 : Data signal of src_bank
//        bit 7~0 - src_bank[7:0] (Read/Write)
//        others  - reserved
// 0x24 : reserved
// 0x28 : Data signal of epoch
//        bit 31~0 - epoch[31:0] (Read/Write)
// 0x2c : reserved
// 0x30 : Data signal of second_id
//        bit 7~0 - second_id[7:0] (Read/Write)
//        others  - reserved
// 0x34 : reserved
// 0x38 : Data signal of second_bank
//        bit 7~0 - second_bank[7:0] (Read/Write)
//        others  - reserved
// 0x3c : reserved
// 0x40 : Data signal of second_epoch
//        bit 31~0 - second_epoch[31:0] (Read/Write)
// 0x44 : reserved
// 0x48 : Data signal of second_region
//        bit 7~0 - second_region[7:0] (Read/Write)
//        others  - reserved
// 0x4c : reserved
// 0x50 : Data signal of load_ok
//        bit 7~0 - load_ok[7:0] (Read/Write)
//        others  - reserved
// 0x54 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL            0x00
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_GIE                0x04
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER                0x08
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_ISR                0x0c
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_MODE_DATA          0x10
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_MODE_DATA          8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LAYER_DATA         0x18
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_LAYER_DATA         8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SRC_BANK_DATA      0x20
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_SRC_BANK_DATA      8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_EPOCH_DATA         0x28
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_EPOCH_DATA         32
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_ID_DATA     0x30
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_SECOND_ID_DATA     8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_BANK_DATA   0x38
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_SECOND_BANK_DATA   8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_EPOCH_DATA  0x40
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_SECOND_EPOCH_DATA  32
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_REGION_DATA 0x48
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_SECOND_REGION_DATA 8
#define XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LOAD_OK_DATA       0x50
#define XOPTIONAL_POINTER_PILOT_CONTROL_BITS_LOAD_OK_DATA       8

// control_r
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of out_r
//        bit 31~0 - out_r[31:0] (Read/Write)
// 0x14 : Data signal of out_r
//        bit 31~0 - out_r[63:32] (Read/Write)
// 0x18 : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XOPTIONAL_POINTER_PILOT_CONTROL_R_ADDR_OUT_R_DATA 0x10
#define XOPTIONAL_POINTER_PILOT_CONTROL_R_BITS_OUT_R_DATA 64

