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
#include "xoptional_pointer_pilot.h"

extern XOptional_pointer_pilot_Config XOptional_pointer_pilot_ConfigTable[];

#ifdef SDT
XOptional_pointer_pilot_Config *XOptional_pointer_pilot_LookupConfig(UINTPTR BaseAddress) {
	XOptional_pointer_pilot_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XOptional_pointer_pilot_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XOptional_pointer_pilot_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XOptional_pointer_pilot_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XOptional_pointer_pilot_Initialize(XOptional_pointer_pilot *InstancePtr, UINTPTR BaseAddress) {
	XOptional_pointer_pilot_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XOptional_pointer_pilot_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XOptional_pointer_pilot_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XOptional_pointer_pilot_Config *XOptional_pointer_pilot_LookupConfig(u16 DeviceId) {
	XOptional_pointer_pilot_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XOPTIONAL_POINTER_PILOT_NUM_INSTANCES; Index++) {
		if (XOptional_pointer_pilot_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XOptional_pointer_pilot_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XOptional_pointer_pilot_Initialize(XOptional_pointer_pilot *InstancePtr, u16 DeviceId) {
	XOptional_pointer_pilot_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XOptional_pointer_pilot_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XOptional_pointer_pilot_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

