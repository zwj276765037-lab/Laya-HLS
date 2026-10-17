set pagination off
set confirm off
set debuginfod enabled off
set environment LAYA_FULL_HLS_PACKAGE /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/model-p2-prelim2
set environment LAYA_FULL_HLS_REQUEST /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/p2c-forward-dut-prelim/inputs/B2_S128.request.bin
set environment LAYA_FULL_HLS_ORACLE /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/p2c-forward-oracle-prelim/B2_S128
break /home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hls/platform/full_kernel_csim_tb.cpp:77
run
dump binary memory /tmp/laya_csim_encoder0_actual.bin actual._M_impl._M_start actual._M_impl._M_finish
print actual.size()
quit
