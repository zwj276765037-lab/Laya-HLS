// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xoptional_pointer_pilot.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XOptional_pointer_pilot_CfgInitialize(XOptional_pointer_pilot *InstancePtr, XOptional_pointer_pilot_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->Control_r_BaseAddress = ConfigPtr->Control_r_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XOptional_pointer_pilot_Start(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL) & 0x80;
    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XOptional_pointer_pilot_IsDone(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XOptional_pointer_pilot_IsIdle(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XOptional_pointer_pilot_IsReady(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XOptional_pointer_pilot_EnableAutoRestart(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XOptional_pointer_pilot_DisableAutoRestart(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_AP_CTRL, 0);
}

void XOptional_pointer_pilot_Set_mode(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_MODE_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_mode(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_MODE_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_layer(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LAYER_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_layer(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LAYER_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_src_bank(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SRC_BANK_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_src_bank(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SRC_BANK_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_epoch(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_EPOCH_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_epoch(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_EPOCH_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_second_id(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_ID_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_second_id(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_ID_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_second_bank(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_BANK_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_second_bank(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_BANK_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_second_epoch(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_EPOCH_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_second_epoch(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_EPOCH_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_second_region(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_REGION_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_second_region(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_SECOND_REGION_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_load_ok(XOptional_pointer_pilot *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LOAD_OK_DATA, Data);
}

u32 XOptional_pointer_pilot_Get_load_ok(XOptional_pointer_pilot *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_LOAD_OK_DATA);
    return Data;
}

void XOptional_pointer_pilot_Set_out_r(XOptional_pointer_pilot *InstancePtr, u64 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_r_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_R_ADDR_OUT_R_DATA, (u32)(Data));
    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_r_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_R_ADDR_OUT_R_DATA + 4, (u32)(Data >> 32));
}

u64 XOptional_pointer_pilot_Get_out_r(XOptional_pointer_pilot *InstancePtr) {
    u64 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XOptional_pointer_pilot_ReadReg(InstancePtr->Control_r_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_R_ADDR_OUT_R_DATA);
    Data += (u64)XOptional_pointer_pilot_ReadReg(InstancePtr->Control_r_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_R_ADDR_OUT_R_DATA + 4) << 32;
    return Data;
}

void XOptional_pointer_pilot_InterruptGlobalEnable(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_GIE, 1);
}

void XOptional_pointer_pilot_InterruptGlobalDisable(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_GIE, 0);
}

void XOptional_pointer_pilot_InterruptEnable(XOptional_pointer_pilot *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER);
    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER, Register | Mask);
}

void XOptional_pointer_pilot_InterruptDisable(XOptional_pointer_pilot *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER);
    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER, Register & (~Mask));
}

void XOptional_pointer_pilot_InterruptClear(XOptional_pointer_pilot *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XOptional_pointer_pilot_WriteReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_ISR, Mask);
}

u32 XOptional_pointer_pilot_InterruptGetEnabled(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_IER);
}

u32 XOptional_pointer_pilot_InterruptGetStatus(XOptional_pointer_pilot *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XOptional_pointer_pilot_ReadReg(InstancePtr->Control_BaseAddress, XOPTIONAL_POINTER_PILOT_CONTROL_ADDR_ISR);
}

