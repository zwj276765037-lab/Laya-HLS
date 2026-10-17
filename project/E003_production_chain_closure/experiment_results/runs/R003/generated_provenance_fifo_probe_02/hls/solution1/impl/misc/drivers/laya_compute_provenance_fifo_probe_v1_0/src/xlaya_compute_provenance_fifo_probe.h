// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XLAYA_COMPUTE_PROVENANCE_FIFO_PROBE_H
#define XLAYA_COMPUTE_PROVENANCE_FIFO_PROBE_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xlaya_compute_provenance_fifo_probe_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
#ifdef SDT
    char *Name;
#else
    u16 DeviceId;
#endif
    u64 Control_BaseAddress;
} XLaya_compute_provenance_fifo_probe_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XLaya_compute_provenance_fifo_probe;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XLaya_compute_provenance_fifo_probe_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XLaya_compute_provenance_fifo_probe_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XLaya_compute_provenance_fifo_probe_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XLaya_compute_provenance_fifo_probe_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
#ifdef SDT
int XLaya_compute_provenance_fifo_probe_Initialize(XLaya_compute_provenance_fifo_probe *InstancePtr, UINTPTR BaseAddress);
XLaya_compute_provenance_fifo_probe_Config* XLaya_compute_provenance_fifo_probe_LookupConfig(UINTPTR BaseAddress);
#else
int XLaya_compute_provenance_fifo_probe_Initialize(XLaya_compute_provenance_fifo_probe *InstancePtr, u16 DeviceId);
XLaya_compute_provenance_fifo_probe_Config* XLaya_compute_provenance_fifo_probe_LookupConfig(u16 DeviceId);
#endif
int XLaya_compute_provenance_fifo_probe_CfgInitialize(XLaya_compute_provenance_fifo_probe *InstancePtr, XLaya_compute_provenance_fifo_probe_Config *ConfigPtr);
#else
int XLaya_compute_provenance_fifo_probe_Initialize(XLaya_compute_provenance_fifo_probe *InstancePtr, const char* InstanceName);
int XLaya_compute_provenance_fifo_probe_Release(XLaya_compute_provenance_fifo_probe *InstancePtr);
#endif

void XLaya_compute_provenance_fifo_probe_Start(XLaya_compute_provenance_fifo_probe *InstancePtr);
u32 XLaya_compute_provenance_fifo_probe_IsDone(XLaya_compute_provenance_fifo_probe *InstancePtr);
u32 XLaya_compute_provenance_fifo_probe_IsIdle(XLaya_compute_provenance_fifo_probe *InstancePtr);
u32 XLaya_compute_provenance_fifo_probe_IsReady(XLaya_compute_provenance_fifo_probe *InstancePtr);
void XLaya_compute_provenance_fifo_probe_EnableAutoRestart(XLaya_compute_provenance_fifo_probe *InstancePtr);
void XLaya_compute_provenance_fifo_probe_DisableAutoRestart(XLaya_compute_provenance_fifo_probe *InstancePtr);
u32 XLaya_compute_provenance_fifo_probe_Get_return(XLaya_compute_provenance_fifo_probe *InstancePtr);


void XLaya_compute_provenance_fifo_probe_InterruptGlobalEnable(XLaya_compute_provenance_fifo_probe *InstancePtr);
void XLaya_compute_provenance_fifo_probe_InterruptGlobalDisable(XLaya_compute_provenance_fifo_probe *InstancePtr);
void XLaya_compute_provenance_fifo_probe_InterruptEnable(XLaya_compute_provenance_fifo_probe *InstancePtr, u32 Mask);
void XLaya_compute_provenance_fifo_probe_InterruptDisable(XLaya_compute_provenance_fifo_probe *InstancePtr, u32 Mask);
void XLaya_compute_provenance_fifo_probe_InterruptClear(XLaya_compute_provenance_fifo_probe *InstancePtr, u32 Mask);
u32 XLaya_compute_provenance_fifo_probe_InterruptGetEnabled(XLaya_compute_provenance_fifo_probe *InstancePtr);
u32 XLaya_compute_provenance_fifo_probe_InterruptGetStatus(XLaya_compute_provenance_fifo_probe *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
