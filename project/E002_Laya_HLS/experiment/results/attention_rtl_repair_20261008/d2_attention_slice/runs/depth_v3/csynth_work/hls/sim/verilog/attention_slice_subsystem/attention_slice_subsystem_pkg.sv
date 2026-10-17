//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`timescale 1ns/1ps 

`ifndef ATTENTION_SLICE_SUBSYSTEM_PKG__SV          
    `define ATTENTION_SLICE_SUBSYSTEM_PKG__SV      
                                                     
    package attention_slice_subsystem_pkg;               
                                                     
        import uvm_pkg::*;                           
        import file_agent_pkg::*;                    
        import axi_pkg::*;
                                                     
        `include "uvm_macros.svh"                  
                                                     
        `include "attention_slice_config.sv"           
        `include "attention_slice_reference_model.sv"  
        `include "attention_slice_scoreboard.sv"       
        `include "attention_slice_subsystem_monitor.sv"
        `include "attention_slice_virtual_sequencer.sv"
        `include "attention_slice_pkg_sequence_lib.sv" 
        `include "attention_slice_env.sv"              
                                                     
    endpackage                                       
                                                     
`endif                                               
