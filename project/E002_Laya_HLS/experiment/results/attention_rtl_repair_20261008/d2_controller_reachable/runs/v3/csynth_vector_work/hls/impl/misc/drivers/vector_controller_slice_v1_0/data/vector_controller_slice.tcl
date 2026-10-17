# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
# Tool Version Limit: 2025.11
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 
# ==============================================================
proc generate {drv_handle} {
    xdefine_include_file $drv_handle "xparameters.h" "XVector_controller_slice" \
        "NUM_INSTANCES" \
        "DEVICE_ID" \
        "C_S_AXI_CONTROL_BASEADDR" \
        "C_S_AXI_CONTROL_HIGHADDR" \
        "C_S_AXI_CONTROL_R_BASEADDR" \
        "C_S_AXI_CONTROL_R_HIGHADDR"

    xdefine_config_file $drv_handle "xvector_controller_slice_g.c" "XVector_controller_slice" \
        "DEVICE_ID" \
        "C_S_AXI_CONTROL_BASEADDR" \
        "C_S_AXI_CONTROL_R_BASEADDR"

    xdefine_canonical_xpars $drv_handle "xparameters.h" "XVector_controller_slice" \
        "DEVICE_ID" \
        "C_S_AXI_CONTROL_BASEADDR" \
        "C_S_AXI_CONTROL_HIGHADDR" \
        "C_S_AXI_CONTROL_R_BASEADDR" \
        "C_S_AXI_CONTROL_R_HIGHADDR"
}

