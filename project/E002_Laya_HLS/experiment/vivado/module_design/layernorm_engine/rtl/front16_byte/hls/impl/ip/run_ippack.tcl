# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
# Tool Version Limit: 2025.11
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 
# ==============================================================
source -notrace "/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/common/scripts/ipxhls.tcl"
set ip_out_dir "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/layernorm_engine/rtl/front16_byte/hls/impl/ip"
set data_file "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/layernorm_engine/rtl/front16_byte/hls/hls_data.json"
set src_dir [file dir $data_file]
set ip_types {vitis sysgen}
set ippack_opts_dict {}
if { [catch {::ipx::utils::package_hls_ip $ip_out_dir $data_file $ip_types $src_dir $ippack_opts_dict} res] } {
  puts "Caught error:\n$::errorInfo"
  error $res
}
