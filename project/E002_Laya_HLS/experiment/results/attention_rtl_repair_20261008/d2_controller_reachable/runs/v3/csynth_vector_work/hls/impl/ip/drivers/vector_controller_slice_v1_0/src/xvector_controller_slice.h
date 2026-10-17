// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XVECTOR_CONTROLLER_SLICE_H
#define XVECTOR_CONTROLLER_SLICE_H

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
#include "xvector_controller_slice_hw.h"

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
    u64 Control_r_BaseAddress;
} XVector_controller_slice_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u64 Control_r_BaseAddress;
    u32 IsReady;
} XVector_controller_slice;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XVector_controller_slice_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XVector_controller_slice_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XVector_controller_slice_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XVector_controller_slice_ReadReg(BaseAddress, RegOffset) \
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
int XVector_controller_slice_Initialize(XVector_controller_slice *InstancePtr, UINTPTR BaseAddress);
XVector_controller_slice_Config* XVector_controller_slice_LookupConfig(UINTPTR BaseAddress);
#else
int XVector_controller_slice_Initialize(XVector_controller_slice *InstancePtr, u16 DeviceId);
XVector_controller_slice_Config* XVector_controller_slice_LookupConfig(u16 DeviceId);
#endif
int XVector_controller_slice_CfgInitialize(XVector_controller_slice *InstancePtr, XVector_controller_slice_Config *ConfigPtr);
#else
int XVector_controller_slice_Initialize(XVector_controller_slice *InstancePtr, const char* InstanceName);
int XVector_controller_slice_Release(XVector_controller_slice *InstancePtr);
#endif

void XVector_controller_slice_Start(XVector_controller_slice *InstancePtr);
u32 XVector_controller_slice_IsDone(XVector_controller_slice *InstancePtr);
u32 XVector_controller_slice_IsIdle(XVector_controller_slice *InstancePtr);
u32 XVector_controller_slice_IsReady(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_EnableAutoRestart(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_DisableAutoRestart(XVector_controller_slice *InstancePtr);

void XVector_controller_slice_Set_mode(XVector_controller_slice *InstancePtr, u32 Data);
u32 XVector_controller_slice_Get_mode(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_src0_input_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_src0_input_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_src1_input_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_src1_input_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_io_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_io_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_aux_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_aux_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_state0_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_state0_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_state1_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_state1_r(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_Set_observed_r(XVector_controller_slice *InstancePtr, u64 Data);
u64 XVector_controller_slice_Get_observed_r(XVector_controller_slice *InstancePtr);

void XVector_controller_slice_InterruptGlobalEnable(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_InterruptGlobalDisable(XVector_controller_slice *InstancePtr);
void XVector_controller_slice_InterruptEnable(XVector_controller_slice *InstancePtr, u32 Mask);
void XVector_controller_slice_InterruptDisable(XVector_controller_slice *InstancePtr, u32 Mask);
void XVector_controller_slice_InterruptClear(XVector_controller_slice *InstancePtr, u32 Mask);
u32 XVector_controller_slice_InterruptGetEnabled(XVector_controller_slice *InstancePtr);
u32 XVector_controller_slice_InterruptGetStatus(XVector_controller_slice *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
