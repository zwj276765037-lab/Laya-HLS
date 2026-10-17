// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xvector_controller_slice.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XVector_controller_slice_CfgInitialize(XVector_controller_slice *InstancePtr, XVector_controller_slice_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->Control_r_BaseAddress = ConfigPtr->Control_r_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XVector_controller_slice_Start(XVector_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XVector_controller_slice_IsDone(XVector_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XVector_controller_slice_IsIdle(XVector_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XVector_controller_slice_IsReady(XVector_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XVector_controller_slice_EnableAutoRestart(XVector_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XVector_controller_slice_DisableAutoRestart(XVector_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_AP_CTRL, 0);
}

void XVector_controller_slice_Set_mode(XVector_controller_slice *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_MODE_DATA, Data);
}

u32 XVector_controller_slice_Get_mode(XVector_controller_slice *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_MODE_DATA);
    return Data;
}

void XVector_controller_slice_Set_src0_input_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC0_INPUT_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC0_INPUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_src0_input_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC0_INPUT_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC0_INPUT_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_src1_input_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC1_INPUT_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC1_INPUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_src1_input_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC1_INPUT_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_SRC1_INPUT_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_io_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_io_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_IO_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_aux_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_aux_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_AUX_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_state0_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_state0_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE0_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_state1_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE1_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE1_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_state1_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE1_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_STATE1_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_Set_observed_r(XVector_controller_slice *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA, (u32)(Data));
    XVector_controller_slice_WriteReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4, (u32)(Data >> 32));
}

u64 XVector_controller_slice_Get_observed_r(XVector_controller_slice *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA);
    Data += (u64)XVector_controller_slice_ReadReg(InstancePtr->Control_r_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_R_ADDR_OBSERVED_R_DATA + 4) << 32;
    return Data;
}

void XVector_controller_slice_InterruptGlobalEnable(XVector_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_GIE, 1);
}

void XVector_controller_slice_InterruptGlobalDisable(XVector_controller_slice *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_GIE, 0);
}

void XVector_controller_slice_InterruptEnable(XVector_controller_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_IER, Register | Mask);
}

void XVector_controller_slice_InterruptDisable(XVector_controller_slice *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XVector_controller_slice_InterruptClear(XVector_controller_slice *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XVector_controller_slice_WriteReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_ISR, Mask);
}

u32 XVector_controller_slice_InterruptGetEnabled(XVector_controller_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_IER);
}

u32 XVector_controller_slice_InterruptGetStatus(XVector_controller_slice *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XVector_controller_slice_ReadReg(InstancePtr->Control_BaseAddress, XVECTOR_CONTROLLER_SLICE_CONTROL_ADDR_ISR);
}

