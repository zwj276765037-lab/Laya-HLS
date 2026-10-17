# ==============================================================
# Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
# Tool Version Limit: 2025.11
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 
# ==============================================================
CSIM_DESIGN = 1

__SIM_FPO__ = 1

__SIM_MATHHLS__ = 1

__SIM_MATHSTD__ = 1

__SIM_FFT__ = 1

__SIM_FIR__ = 1

__SIM_DDS__ = 1

__USE_CLANG__ = 1

__USE_VCXX_CLANG__ = 1

ObjDir = obj

HLS_SOURCES = ../../../../../../hls/platform/full_kernel_csim_tb.cpp ../../../../../../hls/platform/full_kernel_wrapper.cpp ../../../../../../hls/platform/full_cache_storage.cpp ../../../../../../hls/laya_forward_full.cpp ../../../../../../hls/control/full_forward_controller.cpp ../../../../../../hls/control/full_result.cpp ../../../../../../hls/operators/full_tasks_vector.cpp ../../../../../../hls/operators/full_tasks_tail.cpp ../../../../../../hls/operators/full_tasks_attention.cpp ../../../../../../hls/operators/full_tasks_front.cpp ../../../../../../hls/operators/full_tasks.cpp ../../../../../../hls/operators/decision_full_compute.cpp ../../../../../../hls/operators/vector_full_compute.cpp ../../../../../../hls/operators/attention_full_compute.cpp ../../../../../../hls/operators/rope_full_compute.cpp ../../../../../../hls/operators/embedding_full_compute.cpp ../../../../../../hls/operators/q8_linear_compute.cpp ../../../../../../hls/operators/layernorm_compute.cpp ../../../../../../hls/operators/activation_quantizer_compute.cpp ../../../../../../hls/memory/full_loader.cpp ../../../../../../hls/common/laya_full_owner.cpp ../../../../../../hls/common/laya_full_memory.cpp ../../../../../../hls/common/laya_full_io.cpp ../../../../../../hls/common/laya_memory_map.cpp ../../../../../../hls/common/laya_tasks.cpp ../../../../../../hls/common/laya_numeric.cpp

override TARGET := csim.exe

AUTOPILOT_ROOT := /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis
AUTOPILOT_MACH := lnx64
ifdef AP_GCC_M32
  AUTOPILOT_MACH := Linux_x86
  IFLAG += -m32
endif
IFLAG += -fPIC
ifndef AP_GCC_PATH
  AP_GCC_PATH := /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0/bin
endif
AUTOPILOT_TOOL := ${AUTOPILOT_ROOT}/${AUTOPILOT_MACH}/tools
AP_CLANG_PATH := ${AUTOPILOT_ROOT}/lnx64/tools/clang-16/bin
AUTOPILOT_TECH := ${AUTOPILOT_ROOT}/common/technology


IFLAG += -I "${AUTOPILOT_ROOT}/include"
IFLAG += -I "${AUTOPILOT_ROOT}/include/ap_sysc"
IFLAG += -I "${AUTOPILOT_TECH}/generic/SystemC"
IFLAG += -I "${AUTOPILOT_TECH}/generic/SystemC/AESL_FP_comp"
IFLAG += -I "${AUTOPILOT_TECH}/generic/SystemC/AESL_comp"
IFLAG += -I "${AUTOPILOT_TOOL}/auto_cc/include"
IFLAG += -I "/usr/include/x86_64-linux-gnu"
IFLAG += -D__HLS_COSIM__

IFLAG += -D__HLS_CSIM__

IFLAG += -D__VITIS_HLS__

IFLAG += -D__SIM_FPO__

IFLAG += -D__SIM_FFT__

IFLAG += -D__SIM_FIR__

IFLAG += -D__SIM_DDS__

IFLAG += -D__DSP48E2__
IFLAG += -g
DFLAG += -D__xilinx_ip_top= -DAESL_TB
CCFLAG += -Werror=return-type
CCFLAG += -Wno-abi
CCFLAG += -fdebug-default-version=4
CCFLAG += --gcc-toolchain=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0
CCFLAG += -Werror=uninitialized
CCFLAG += -Wno-c++11-narrowing
CCFLAG += -Wno-error=sometimes-uninitialized
LFLAG += --gcc-toolchain=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/tps/lnx64/gcc-8.3.0
LFLAG += -lstdc++fs



include ./Makefile.rules

all: $(TARGET)



$(ObjDir)/full_kernel_csim_tb.o: ../../../../../../hls/platform/full_kernel_csim_tb.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/platform/full_kernel_csim_tb.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off -Wno-unknown-pragmas -Wno-unknown-pragmas  $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_kernel_csim_tb.d

$(ObjDir)/full_kernel_wrapper.o: ../../../../../../hls/platform/full_kernel_wrapper.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/platform/full_kernel_wrapper.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_kernel_wrapper.d

$(ObjDir)/full_cache_storage.o: ../../../../../../hls/platform/full_cache_storage.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/platform/full_cache_storage.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_cache_storage.d

$(ObjDir)/laya_forward_full.o: ../../../../../../hls/laya_forward_full.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/laya_forward_full.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_forward_full.d

$(ObjDir)/full_forward_controller.o: ../../../../../../hls/control/full_forward_controller.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/control/full_forward_controller.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_forward_controller.d

$(ObjDir)/full_result.o: ../../../../../../hls/control/full_result.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/control/full_result.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_result.d

$(ObjDir)/full_tasks_vector.o: ../../../../../../hls/operators/full_tasks_vector.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/full_tasks_vector.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_tasks_vector.d

$(ObjDir)/full_tasks_tail.o: ../../../../../../hls/operators/full_tasks_tail.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/full_tasks_tail.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_tasks_tail.d

$(ObjDir)/full_tasks_attention.o: ../../../../../../hls/operators/full_tasks_attention.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/full_tasks_attention.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_tasks_attention.d

$(ObjDir)/full_tasks_front.o: ../../../../../../hls/operators/full_tasks_front.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/full_tasks_front.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_tasks_front.d

$(ObjDir)/full_tasks.o: ../../../../../../hls/operators/full_tasks.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/full_tasks.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_tasks.d

$(ObjDir)/decision_full_compute.o: ../../../../../../hls/operators/decision_full_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/decision_full_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/decision_full_compute.d

$(ObjDir)/vector_full_compute.o: ../../../../../../hls/operators/vector_full_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/vector_full_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/vector_full_compute.d

$(ObjDir)/attention_full_compute.o: ../../../../../../hls/operators/attention_full_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/attention_full_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/attention_full_compute.d

$(ObjDir)/rope_full_compute.o: ../../../../../../hls/operators/rope_full_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/rope_full_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/rope_full_compute.d

$(ObjDir)/embedding_full_compute.o: ../../../../../../hls/operators/embedding_full_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/embedding_full_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/embedding_full_compute.d

$(ObjDir)/q8_linear_compute.o: ../../../../../../hls/operators/q8_linear_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/q8_linear_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/q8_linear_compute.d

$(ObjDir)/layernorm_compute.o: ../../../../../../hls/operators/layernorm_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/layernorm_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/layernorm_compute.d

$(ObjDir)/activation_quantizer_compute.o: ../../../../../../hls/operators/activation_quantizer_compute.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/operators/activation_quantizer_compute.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/activation_quantizer_compute.d

$(ObjDir)/full_loader.o: ../../../../../../hls/memory/full_loader.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/memory/full_loader.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/full_loader.d

$(ObjDir)/laya_full_owner.o: ../../../../../../hls/common/laya_full_owner.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_full_owner.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_full_owner.d

$(ObjDir)/laya_full_memory.o: ../../../../../../hls/common/laya_full_memory.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_full_memory.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_full_memory.d

$(ObjDir)/laya_full_io.o: ../../../../../../hls/common/laya_full_io.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_full_io.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_full_io.d

$(ObjDir)/laya_memory_map.o: ../../../../../../hls/common/laya_memory_map.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_memory_map.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_memory_map.d

$(ObjDir)/laya_tasks.o: ../../../../../../hls/common/laya_tasks.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_tasks.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_tasks.d

$(ObjDir)/laya_numeric.o: ../../../../../../hls/common/laya_numeric.cpp $(ObjDir)/.dir csim.mk
	$(Echo) "   Compiling ../../../../../../hls/common/laya_numeric.cpp in $(BuildMode) mode" $(AVE_DIR_DLOG)
	$(Verb)  $(CXX) -std=gnu++17 ${CCFLAG} -c -MMD -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/include -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/hls/platform -I/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-repair-20261007/build/model-repair -std=c++17 -O2 -fno-fast-math -ffp-contract=off  -fhls-csim -fhlstoplevel=laya_typed_q8_forward $(IFLAG) $(DFLAG) $< -o $@ ; \

-include $(ObjDir)/laya_numeric.d
