// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XOPTIONAL_POINTER_PILOT_H
#define XOPTIONAL_POINTER_PILOT_H

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
#include "xoptional_pointer_pilot_hw.h"

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
} XOptional_pointer_pilot_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u64 Control_r_BaseAddress;
    u32 IsReady;
} XOptional_pointer_pilot;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XOptional_pointer_pilot_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XOptional_pointer_pilot_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XOptional_pointer_pilot_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XOptional_pointer_pilot_ReadReg(BaseAddress, RegOffset) \
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
int XOptional_pointer_pilot_Initialize(XOptional_pointer_pilot *InstancePtr, UINTPTR BaseAddress);
XOptional_pointer_pilot_Config* XOptional_pointer_pilot_LookupConfig(UINTPTR BaseAddress);
#else
int XOptional_pointer_pilot_Initialize(XOptional_pointer_pilot *InstancePtr, u16 DeviceId);
XOptional_pointer_pilot_Config* XOptional_pointer_pilot_LookupConfig(u16 DeviceId);
#endif
int XOptional_pointer_pilot_CfgInitialize(XOptional_pointer_pilot *InstancePtr, XOptional_pointer_pilot_Config *ConfigPtr);
#else
int XOptional_pointer_pilot_Initialize(XOptional_pointer_pilot *InstancePtr, const char* InstanceName);
int XOptional_pointer_pilot_Release(XOptional_pointer_pilot *InstancePtr);
#endif

void XOptional_pointer_pilot_Start(XOptional_pointer_pilot *InstancePtr);
u32 XOptional_pointer_pilot_IsDone(XOptional_pointer_pilot *InstancePtr);
u32 XOptional_pointer_pilot_IsIdle(XOptional_pointer_pilot *InstancePtr);
u32 XOptional_pointer_pilot_IsReady(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_EnableAutoRestart(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_DisableAutoRestart(XOptional_pointer_pilot *InstancePtr);

void XOptional_pointer_pilot_Set_mode(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_mode(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_layer(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_layer(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_src_bank(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_src_bank(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_epoch(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_epoch(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_second_id(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_second_id(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_second_bank(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_second_bank(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_second_epoch(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_second_epoch(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_second_region(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_second_region(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_load_ok(XOptional_pointer_pilot *InstancePtr, u32 Data);
u32 XOptional_pointer_pilot_Get_load_ok(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_Set_out_r(XOptional_pointer_pilot *InstancePtr, u64 Data);
u64 XOptional_pointer_pilot_Get_out_r(XOptional_pointer_pilot *InstancePtr);

void XOptional_pointer_pilot_InterruptGlobalEnable(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_InterruptGlobalDisable(XOptional_pointer_pilot *InstancePtr);
void XOptional_pointer_pilot_InterruptEnable(XOptional_pointer_pilot *InstancePtr, u32 Mask);
void XOptional_pointer_pilot_InterruptDisable(XOptional_pointer_pilot *InstancePtr, u32 Mask);
void XOptional_pointer_pilot_InterruptClear(XOptional_pointer_pilot *InstancePtr, u32 Mask);
u32 XOptional_pointer_pilot_InterruptGetEnabled(XOptional_pointer_pilot *InstancePtr);
u32 XOptional_pointer_pilot_InterruptGetStatus(XOptional_pointer_pilot *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
