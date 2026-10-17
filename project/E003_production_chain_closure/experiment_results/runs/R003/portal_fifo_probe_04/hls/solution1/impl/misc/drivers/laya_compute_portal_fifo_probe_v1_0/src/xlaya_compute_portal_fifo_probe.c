// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
/***************************** Include Files *********************************/
#include "xlaya_compute_portal_fifo_probe.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XLaya_compute_portal_fifo_probe_CfgInitialize(XLaya_compute_portal_fifo_probe *InstancePtr, XLaya_compute_portal_fifo_probe_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XLaya_compute_portal_fifo_probe_Start(XLaya_compute_portal_fifo_probe *InstancePtr) {
    u32 Data;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL) & 0x80;
    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL, Data | 0x01);
}

u32 XLaya_compute_portal_fifo_probe_IsDone(XLaya_compute_portal_fifo_probe *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 1) & 0x1;
}

u32 XLaya_compute_portal_fifo_probe_IsIdle(XLaya_compute_portal_fifo_probe *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL);
    return (Data >> 2) & 0x1;
}

u32 XLaya_compute_portal_fifo_probe_IsReady(XLaya_compute_portal_fifo_probe *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL);
    // check ap_start to see if the pcore is ready for next input
    return !(Data & 0x1);
}

void XLaya_compute_portal_fifo_probe_EnableAutoRestart(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL, 0x80);
}

void XLaya_compute_portal_fifo_probe_DisableAutoRestart(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_CTRL, 0);
}

u32 XLaya_compute_portal_fifo_probe_Get_return(XLaya_compute_portal_fifo_probe *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_AP_RETURN);
    return Data;
}
void XLaya_compute_portal_fifo_probe_InterruptGlobalEnable(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_GIE, 1);
}

void XLaya_compute_portal_fifo_probe_InterruptGlobalDisable(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_GIE, 0);
}

void XLaya_compute_portal_fifo_probe_InterruptEnable(XLaya_compute_portal_fifo_probe *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_IER);
    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_IER, Register | Mask);
}

void XLaya_compute_portal_fifo_probe_InterruptDisable(XLaya_compute_portal_fifo_probe *InstancePtr, u32 Mask) {
    u32 Register;

    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Register =  XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_IER);
    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_IER, Register & (~Mask));
}

void XLaya_compute_portal_fifo_probe_InterruptClear(XLaya_compute_portal_fifo_probe *InstancePtr, u32 Mask) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XLaya_compute_portal_fifo_probe_WriteReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_ISR, Mask);
}

u32 XLaya_compute_portal_fifo_probe_InterruptGetEnabled(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_IER);
}

u32 XLaya_compute_portal_fifo_probe_InterruptGetStatus(XLaya_compute_portal_fifo_probe *InstancePtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    return XLaya_compute_portal_fifo_probe_ReadReg(InstancePtr->Control_BaseAddress, XLAYA_COMPUTE_PORTAL_FIFO_PROBE_CONTROL_ADDR_ISR);
}

