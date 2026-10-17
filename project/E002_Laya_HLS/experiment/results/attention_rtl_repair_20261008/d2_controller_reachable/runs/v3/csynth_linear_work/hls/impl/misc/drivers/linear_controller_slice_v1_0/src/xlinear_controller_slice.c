// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xlinear_controller_slice.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XLinear_controller_slice_CfgInitialize(XLinear_controller_slice *InstancePtr, XLinear_controller_slice_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->Control_r_BaseAddress = ConfigPtr->Control_r_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XLinear_controller_slice_Start(XLinear_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XLinear_controller_slice_IsDone(XLinear_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XLinear_controller_slice_IsIdle(XLinear_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XLinear_controller_slice_IsReady(XLinear_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XLinear_controller_slice_EnableAutoRestart(XLinear_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XLinear_controller_slice_DisableAutoRestart(XLinear_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, 0);
}

void XLinear_controller_slice_Set_pair_present(XLinear_controller_slice *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_PAIR_PRESENT_DATA, Data);
}

u32 XLinear_controller_slice_Get_pair_present(XLinear_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_PAIR_PRESENT_DATA);
    return Data;
}

void XLinear_controller_slice_Set_norm_input_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_NORM_INPUT_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_NORM_INPUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_norm_input_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_NORM_INPUT_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_NORM_INPUT_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_io_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_io_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_w_q0_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q0_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q0_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_w_q0_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q0_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q0_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_w_q1_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q1_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q1_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_w_q1_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q1_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_Q1_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_w_scale_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_SCALE_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_SCALE_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_w_scale_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_SCALE_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_W_SCALE_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_aux_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_aux_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_state0_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_state0_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_qkv0_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV0_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV0_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_qkv0_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV0_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV0_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_qkv1_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV1_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV1_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_qkv1_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV1_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_QKV1_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_Set_observed_r(XLinear_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA, (u32)(Data));
    XLinear_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4, (u32)(Data >> 32));
}

u64 XLinear_controller_slice_Get_observed_r(XLinear_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA);
    Data += (u64)XLinear_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4) << 32;
    return Data;
}

void XLinear_controller_slice_InterruptGlobalEnable(XLinear_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_GIE, 1);
}

void XLinear_controller_slice_InterruptGlobalDisable(XLinear_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_GIE, 0);
}

void XLinear_controller_slice_InterruptEnable(XLinear_controller_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER, Register | Mask);
}

void XLinear_controller_slice_InterruptDisable(XLinear_controller_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XLinear_controller_slice_InterruptClear(XLinear_controller_slice *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLinear_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_ISR, Mask);
}

u32 XLinear_controller_slice_InterruptGetEnabled(XLinear_controller_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
}

u32 XLinear_controller_slice_InterruptGetStatus(XLinear_controller_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLinear_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XLINEAR_CONTROLLER_SLICE_CONTROL_ADDR_ISR);
}

