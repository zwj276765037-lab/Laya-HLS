// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XLAYA_FRONT16_BYTE_H
#define XLAYA_FRONT16_BYTE_H

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
#include "xlaya_front16_byte_hw.h"

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
} XLaya_front16_byte_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u64 Control_r_BaseAddress;
    u32 IsReady;
} XLaya_front16_byte;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XLaya_front16_byte_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XLaya_front16_byte_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XLaya_front16_byte_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XLaya_front16_byte_ReadReg(BaseAddress, RegOffset) \
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
int XLaya_front16_byte_Initialize(XLaya_front16_byte *InstancePtr, UINTPTR BaseAddress);
XLaya_front16_byte_Config* XLaya_front16_byte_LookupConfig(UINTPTR BaseAddress);
#else
int XLaya_front16_byte_Initialize(XLaya_front16_byte *InstancePtr, u16 DeviceId);
XLaya_front16_byte_Config* XLaya_front16_byte_LookupConfig(u16 DeviceId);
#endif
int XLaya_front16_byte_CfgInitialize(XLaya_front16_byte *InstancePtr, XLaya_front16_byte_Config *ConfigPtr);
#else
int XLaya_front16_byte_Initialize(XLaya_front16_byte *InstancePtr, const char* InstanceName);
int XLaya_front16_byte_Release(XLaya_front16_byte *InstancePtr);
#endif

void XLaya_front16_byte_Start(XLaya_front16_byte *InstancePtr);
u32 XLaya_front16_byte_IsDone(XLaya_front16_byte *InstancePtr);
u32 XLaya_front16_byte_IsIdle(XLaya_front16_byte *InstancePtr);
u32 XLaya_front16_byte_IsReady(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_EnableAutoRestart(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_DisableAutoRestart(XLaya_front16_byte *InstancePtr);

void XLaya_front16_byte_Set_state0(XLaya_front16_byte *InstancePtr, u64 Data);
u64 XLaya_front16_byte_Get_state0(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_Set_aux(XLaya_front16_byte *InstancePtr, u64 Data);
u64 XLaya_front16_byte_Get_aux(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_Set_state1(XLaya_front16_byte *InstancePtr, u64 Data);
u64 XLaya_front16_byte_Get_state1(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_Set_observed(XLaya_front16_byte *InstancePtr, u64 Data);
u64 XLaya_front16_byte_Get_observed(XLaya_front16_byte *InstancePtr);

void XLaya_front16_byte_InterruptGlobalEnable(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_InterruptGlobalDisable(XLaya_front16_byte *InstancePtr);
void XLaya_front16_byte_InterruptEnable(XLaya_front16_byte *InstancePtr, u32 Mask);
void XLaya_front16_byte_InterruptDisable(XLaya_front16_byte *InstancePtr, u32 Mask);
void XLaya_front16_byte_InterruptClear(XLaya_front16_byte *InstancePtr, u32 Mask);
u32 XLaya_front16_byte_InterruptGetEnabled(XLaya_front16_byte *InstancePtr);
u32 XLaya_front16_byte_InterruptGetStatus(XLaya_front16_byte *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
