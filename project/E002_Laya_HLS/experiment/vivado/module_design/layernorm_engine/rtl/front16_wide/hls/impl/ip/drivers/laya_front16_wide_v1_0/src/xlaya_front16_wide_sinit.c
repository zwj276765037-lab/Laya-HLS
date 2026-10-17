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
#include "xlaya_front16_wide.h"

extern XLaya_front16_wide_Config XLaya_front16_wide_ConfigTable[];

#ifdef SDT
XLaya_front16_wide_Config *XLaya_front16_wide_LookupConfig(UINTPTR BaseAddress) {
	XLaya_front16_wide_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XLaya_front16_wide_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XLaya_front16_wide_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XLaya_front16_wide_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLaya_front16_wide_Initialize(XLaya_front16_wide *InstancePtr, UINTPTR BaseAddress) {
	XLaya_front16_wide_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLaya_front16_wide_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLaya_front16_wide_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XLaya_front16_wide_Config *XLaya_front16_wide_LookupConfig(u16 DeviceId) {
	XLaya_front16_wide_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XLAYA_FRONT16_WIDE_NUM_INSTANCES; Index++) {
		if (XLaya_front16_wide_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XLaya_front16_wide_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLaya_front16_wide_Initialize(XLaya_front16_wide *InstancePtr, u16 DeviceId) {
	XLaya_front16_wide_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLaya_front16_wide_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLaya_front16_wide_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

