// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
// Tool Version Limit: 2025.11
// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// 
// ==============================================================
#ifndef XLINEAR_CONTROLLER_SLICE_H
#define XLINEAR_CONTROLLER_SLICE_H

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
#include "xlinear_controller_slice_hw.h"

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
} XLinear_controller_slice_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u64 Control_r_BaseAddress;
    u32 IsReady;
} XLinear_controller_slice;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XLinear_controller_slice_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XLinear_controller_slice_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XLinear_controller_slice_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XLinear_controller_slice_ReadReg(BaseAddress, RegOffset) \
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
int XLinear_controller_slice_Initialize(XLinear_controller_slice *InstancePtr, UINTPTR BaseAddress);
XLinear_controller_slice_Config* XLinear_controller_slice_LookupConfig(UINTPTR BaseAddress);
#else
int XLinear_controller_slice_Initialize(XLinear_controller_slice *InstancePtr, u16 DeviceId);
XLinear_controller_slice_Config* XLinear_controller_slice_LookupConfig(u16 DeviceId);
#endif
int XLinear_controller_slice_CfgInitialize(XLinear_controller_slice *InstancePtr, XLinear_controller_slice_Config *ConfigPtr);
#else
int XLinear_controller_slice_Initialize(XLinear_controller_slice *InstancePtr, const char* InstanceName);
int XLinear_controller_slice_Release(XLinear_controller_slice *InstancePtr);
#endif

void XLinear_controller_slice_Start(XLinear_controller_slice *InstancePtr);
u32 XLinear_controller_slice_IsDone(XLinear_controller_slice *InstancePtr);
u32 XLinear_controller_slice_IsIdle(XLinear_controller_slice *InstancePtr);
u32 XLinear_controller_slice_IsReady(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_EnableAutoRestart(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_DisableAutoRestart(XLinear_controller_slice *InstancePtr);

void XLinear_controller_slice_Set_pair_present(XLinear_controller_slice *InstancePtr, u32 Data);
u32 XLinear_controller_slice_Get_pair_present(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_norm_input_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_norm_input_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_io_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_io_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_w_q0_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_w_q0_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_w_q1_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_w_q1_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_w_scale_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_w_scale_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_aux_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_aux_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_state0_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_state0_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_qkv0_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_qkv0_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_qkv1_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_qkv1_r(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_Set_observed_r(XLinear_controller_slice *InstancePtr, u64 Data);
u64 XLinear_controller_slice_Get_observed_r(XLinear_controller_slice *InstancePtr);

void XLinear_controller_slice_InterruptGlobalEnable(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_InterruptGlobalDisable(XLinear_controller_slice *InstancePtr);
void XLinear_controller_slice_InterruptEnable(XLinear_controller_slice *InstancePtr, u32 Mask);
void XLinear_controller_slice_InterruptDisable(XLinear_controller_slice *InstancePtr, u32 Mask);
void XLinear_controller_slice_InterruptClear(XLinear_controller_slice *InstancePtr, u32 Mask);
u32 XLinear_controller_slice_InterruptGetEnabled(XLinear_controller_slice *InstancePtr);
u32 XLinear_controller_slice_InterruptGetStatus(XLinear_controller_slice *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
