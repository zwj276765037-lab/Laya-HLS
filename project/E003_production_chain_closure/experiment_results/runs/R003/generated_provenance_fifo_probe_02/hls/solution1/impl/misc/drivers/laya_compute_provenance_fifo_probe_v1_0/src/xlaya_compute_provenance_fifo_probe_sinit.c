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
#include "xlaya_compute_provenance_fifo_probe.h"

extern XLaya_compute_provenance_fifo_probe_Config XLaya_compute_provenance_fifo_probe_ConfigTable[];

#ifdef SDT
XLaya_compute_provenance_fifo_probe_Config *XLaya_compute_provenance_fifo_probe_LookupConfig(UINTPTR BaseAddress) {
	XLaya_compute_provenance_fifo_probe_Config *ConfigPtr = NULL;

	int Index;

	for (Index = (u32)0x0; XLaya_compute_provenance_fifo_probe_ConfigTable[Index].Name != NULL; Index++) {
		if (!BaseAddress || XLaya_compute_provenance_fifo_probe_ConfigTable[Index].Control_BaseAddress == BaseAddress) {
			ConfigPtr = &XLaya_compute_provenance_fifo_probe_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLaya_compute_provenance_fifo_probe_Initialize(XLaya_compute_provenance_fifo_probe *InstancePtr, UINTPTR BaseAddress) {
	XLaya_compute_provenance_fifo_probe_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLaya_compute_provenance_fifo_probe_LookupConfig(BaseAddress);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLaya_compute_provenance_fifo_probe_CfgInitialize(InstancePtr, ConfigPtr);
}
#else
XLaya_compute_provenance_fifo_probe_Config *XLaya_compute_provenance_fifo_probe_LookupConfig(u16 DeviceId) {
	XLaya_compute_provenance_fifo_probe_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XLAYA_COMPUTE_PROVENANCE_FIFO_PROBE_NUM_INSTANCES; Index++) {
		if (XLaya_compute_provenance_fifo_probe_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XLaya_compute_provenance_fifo_probe_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XLaya_compute_provenance_fifo_probe_Initialize(XLaya_compute_provenance_fifo_probe *InstancePtr, u16 DeviceId) {
	XLaya_compute_provenance_fifo_probe_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XLaya_compute_provenance_fifo_probe_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XLaya_compute_provenance_fifo_probe_CfgInitialize(InstancePtr, ConfigPtr);
}
#endif

#endif

