// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#ifdef SDT
#include "xparameters.h"
#endif
#include "xattention_slice.h"

extern XAttention_slice_Config XAttention_slice_ConfigTable[];

#ifdef SDT
XAttention_slice_Config *XAttention_slice_LookupConfig(UINTPTR BaseAddress) {
	XAttention_slice_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XAttention_slice_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XAttention_slice_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XAttention_slice_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XAttention_slice_Initialize(XAttention_slice *InstancePtr, UINTPTR BaseAddress) {
	XAttention_slice_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XAttention_slice_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XAttention_slice_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XAttention_slice_Config *XAttention_slice_LookupConfig(u16 DeviceId) {
	XAttention_slice_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XATTENTION_SLICE_NUM_INSTANCES; Index++) {
		if (XAttention_slice_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XAttention_slice_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XAttention_slice_Initialize(XAttention_slice *InstancePtr, u16 DeviceId) {
	XAttention_slice_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XAttention_slice_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XAttention_slice_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

