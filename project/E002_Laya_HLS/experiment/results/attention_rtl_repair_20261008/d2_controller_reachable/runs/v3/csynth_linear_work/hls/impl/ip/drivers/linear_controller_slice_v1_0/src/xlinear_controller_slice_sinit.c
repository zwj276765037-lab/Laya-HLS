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
#include "xlinear_controller_slice.h"

extern XLinear_controller_slice_Config XLinear_controller_slice_ConfigTable[];

#ifdef SDT
XLinear_controller_slice_Config *XLinear_controller_slice_LookupConfig(UINTPTR BaseAddress) {
	XLinear_controller_slice_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XLinear_controller_slice_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XLinear_controller_slice_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XLinear_controller_slice_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLinear_controller_slice_Initialize(XLinear_controller_slice *InstancePtr, UINTPTR BaseAddress) {
	XLinear_controller_slice_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLinear_controller_slice_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLinear_controller_slice_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XLinear_controller_slice_Config *XLinear_controller_slice_LookupConfig(u16 DeviceId) {
	XLinear_controller_slice_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XLINEAR_CONTROLLER_SLICE_NUM_INSTANCES; Index++) {
		if (XLinear_controller_slice_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XLinear_controller_slice_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLinear_controller_slice_Initialize(XLinear_controller_slice *InstancePtr, u16 DeviceId) {
	XLinear_controller_slice_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLinear_controller_slice_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLinear_controller_slice_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

