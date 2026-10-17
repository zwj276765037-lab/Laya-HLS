// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xattention_slice.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XAttention_slice_CfgInitialize(XAttention_slice *InstancePtr, XAttention_slice_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->Control_r_BaseAddress = ConfigPtr->Control_r_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XAttention_slice_Start(XAttention_slice *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XAttention_slice_IsDone(XAttention_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XAttention_slice_IsIdle(XAttention_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XAttention_slice_IsReady(XAttention_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XAttention_slice_EnableAutoRestart(XAttention_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XAttention_slice_DisableAutoRestart(XAttention_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_AP_CTRL, 0);
}

void XAttention_slice_Set_fixture_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_FIXTURE_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_FIXTURE_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_fixture_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_FIXTURE_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_FIXTURE_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_io_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_IO_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_io_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_IO_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_aux_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_AUX_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_aux_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_AUX_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_qkv0_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV0_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV0_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_qkv0_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV0_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV0_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_qkv1_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV1_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV1_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_qkv1_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV1_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_QKV1_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_att_out_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_ATT_OUT_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_ATT_OUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_att_out_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_ATT_OUT_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_ATT_OUT_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_Set_observed_r(XAttention_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA, (u32)(Data));
    XAttention_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4, (u32)(Data >> 32));
}

u64 XAttention_slice_Get_observed_r(XAttention_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA);
    Data += (u64)XAttention_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XATTENTION_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4) << 32;
    return Data;
}

void XAttention_slice_InterruptGlobalEnable(XAttention_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_GIE, 1);
}

void XAttention_slice_InterruptGlobalDisable(XAttention_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_GIE, 0);
}

void XAttention_slice_InterruptEnable(XAttention_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_IER);
    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_IER, Register | Mask);
}

void XAttention_slice_InterruptDisable(XAttention_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_IER);
    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XAttention_slice_InterruptClear(XAttention_slice *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XAttention_slice_WriteReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_ISR, Mask);
}

u32 XAttention_slice_InterruptGetEnabled(XAttention_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_IER);
}

u32 XAttention_slice_InterruptGetStatus(XAttention_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XAttention_slice_ReadReg(InstancePtr->Control_BaseAddress, XATTENTION_SLICE_CONTROL_ADDR_ISR);
}

