#!/bin/bash

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
# Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin:/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/ids_lite/ISE/bin/lin64:/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin
else
  PATH=/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vitis/bin:/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/ids_lite/ISE/bin/lin64:/home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_synth_v1_entry_a2/vivado/q8_same_source_ooc.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log q8_joint_tm4tn8.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source q8_joint_tm4tn8.tcl
