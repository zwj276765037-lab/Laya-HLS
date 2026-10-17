// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XATTENTION_SLICE_H
#define XATTENTION_SLICE_H

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
#include "xattention_slice_hw.h"

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
} XAttention_slice_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u64 Control_r_BaseAddress;
    u32 IsReady;
} XAttention_slice;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XAttention_slice_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XAttention_slice_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XAttention_slice_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XAttention_slice_ReadReg(BaseAddress, RegOffset) \
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
int XAttention_slice_Initialize(XAttention_slice *InstancePtr, UINTPTR BaseAddress);
XAttention_slice_Config* XAttention_slice_LookupConfig(UINTPTR BaseAddress);
#else
int XAttention_slice_Initialize(XAttention_slice *InstancePtr, u16 DeviceId);
XAttention_slice_Config* XAttention_slice_LookupConfig(u16 DeviceId);
#endif
int XAttention_slice_CfgInitialize(XAttention_slice *InstancePtr, XAttention_slice_Config *ConfigPtr);
#else
int XAttention_slice_Initialize(XAttention_slice *InstancePtr, const char* InstanceName);
int XAttention_slice_Release(XAttention_slice *InstancePtr);
#endif

void XAttention_slice_Start(XAttention_slice *InstancePtr);
u32 XAttention_slice_IsDone(XAttention_slice *InstancePtr);
u32 XAttention_slice_IsIdle(XAttention_slice *InstancePtr);
u32 XAttention_slice_IsReady(XAttention_slice *InstancePtr);
void XAttention_slice_EnableAutoRestart(XAttention_slice *InstancePtr);
void XAttention_slice_DisableAutoRestart(XAttention_slice *InstancePtr);

void XAttention_slice_Set_fixture_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_fixture_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_io_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_io_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_aux_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_aux_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_qkv0_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_qkv0_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_qkv1_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_qkv1_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_att_out_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_att_out_r(XAttention_slice *InstancePtr);
void XAttention_slice_Set_observed_r(XAttention_slice *InstancePtr, u64 Data);
u64 XAttention_slice_Get_observed_r(XAttention_slice *InstancePtr);

void XAttention_slice_InterruptGlobalEnable(XAttention_slice *InstancePtr);
void XAttention_slice_InterruptGlobalDisable(XAttention_slice *InstancePtr);
void XAttention_slice_InterruptEnable(XAttention_slice *InstancePtr, u32 Mask);
void XAttention_slice_InterruptDisable(XAttention_slice *InstancePtr, u32 Mask);
void XAttention_slice_InterruptClear(XAttention_slice *InstancePtr, u32 Mask);
u32 XAttention_slice_InterruptGetEnabled(XAttention_slice *InstancePtr);
u32 XAttention_slice_InterruptGetStatus(XAttention_slice *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
