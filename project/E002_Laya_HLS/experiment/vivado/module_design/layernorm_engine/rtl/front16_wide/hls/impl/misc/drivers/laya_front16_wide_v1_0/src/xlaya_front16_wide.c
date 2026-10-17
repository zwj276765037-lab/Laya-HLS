// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xlaya_front16_wide.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XLaya_front16_wide_CfgInitialize(XLaya_front16_wide *InstancePtr, XLaya_front16_wide_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->Control_r_BaseAddress = ConfigPtr->Control_r_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XLaya_front16_wide_Start(XLaya_front16_wide *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XLaya_front16_wide_IsDone(XLaya_front16_wide *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XLaya_front16_wide_IsIdle(XLaya_front16_wide *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XLaya_front16_wide_IsReady(XLaya_front16_wide *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XLaya_front16_wide_EnableAutoRestart(XLaya_front16_wide *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XLaya_front16_wide_DisableAutoRestart(XLaya_front16_wide *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_AP_CTRL, 0);
}

void XLaya_front16_wide_Set_state0(XLaya_front16_wide *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE0_DATA, (u32)(Data));
    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE0_DATA + 4, (u32)(Data >> 32));
}

u64 XLaya_front16_wide_Get_state0(XLaya_front16_wide *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE0_DATA);
    Data += (u64)XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE0_DATA + 4) << 32;
    return Data;
}

void XLaya_front16_wide_Set_aux(XLaya_front16_wide *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_AUX_DATA, (u32)(Data));
    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_AUX_DATA + 4, (u32)(Data >> 32));
}

u64 XLaya_front16_wide_Get_aux(XLaya_front16_wide *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_AUX_DATA);
    Data += (u64)XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_AUX_DATA + 4) << 32;
    return Data;
}

void XLaya_front16_wide_Set_state1(XLaya_front16_wide *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE1_DATA, (u32)(Data));
    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE1_DATA + 4, (u32)(Data >> 32));
}

u64 XLaya_front16_wide_Get_state1(XLaya_front16_wide *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE1_DATA);
    Data += (u64)XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_STATE1_DATA + 4) << 32;
    return Data;
}

void XLaya_front16_wide_Set_observed(XLaya_front16_wide *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_OBSERVED_DATA, (u32)(Data));
    XLaya_front16_wide_WriteReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_OBSERVED_DATA + 4, (u32)(Data >> 32));
}

u64 XLaya_front16_wide_Get_observed(XLaya_front16_wide *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_OBSERVED_DATA);
    Data += (u64)XLaya_front16_wide_ReadReg(InstancePtr->Control_r_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_R_ADDR_OBSERVED_DATA + 4) << 32;
    return Data;
}

void XLaya_front16_wide_InterruptGlobalEnable(XLaya_front16_wide *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_GIE, 1);
}

void XLaya_front16_wide_InterruptGlobalDisable(XLaya_front16_wide *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_GIE, 0);
}

void XLaya_front16_wide_InterruptEnable(XLaya_front16_wide *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_IER);
    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_IER, Register | Mask);
}

void XLaya_front16_wide_InterruptDisable(XLaya_front16_wide *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_IER);
    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XLaya_front16_wide_InterruptClear(XLaya_front16_wide *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_front16_wide_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_ISR, Mask);
}

u32 XLaya_front16_wide_InterruptGetEnabled(XLaya_front16_wide *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_IER);
}

u32 XLaya_front16_wide_InterruptGetStatus(XLaya_front16_wide *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLaya_front16_wide_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_FRONT16_WIDE_CONTROL_ADDR_ISR);
}

