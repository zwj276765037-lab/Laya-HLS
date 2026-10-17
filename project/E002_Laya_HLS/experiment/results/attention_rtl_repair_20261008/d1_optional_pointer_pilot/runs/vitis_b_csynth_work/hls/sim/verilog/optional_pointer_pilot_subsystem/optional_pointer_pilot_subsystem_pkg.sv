//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`timescale 1ns/1ps 

`ifndef OPTIONAL_POINTER_PILOT_SUBSYSTEM_PKG__SV          
    `define OPTIONAL_POINTER_PILOT_SUBSYSTEM_PKG__SV      
                                                     
    package optional_pointer_pilot_subsystem_pkg;               
                                                     
        import uvm_pkg::*;                           
        import file_agent_pkg::*;                    
        import axi_pkg::*;
                                                     
        `include "uvm_macros.svh"                  
                                                     
        `include "optional_pointer_pilot_config.sv"           
        `include "optional_pointer_pilot_reference_model.sv"  
        `include "optional_pointer_pilot_scoreboard.sv"       
        `include "optional_pointer_pilot_subsystem_monitor.sv"
        `include "optional_pointer_pilot_virtual_sequencer.sv"
        `include "optional_pointer_pilot_pkg_sequence_lib.sv" 
        `include "optional_pointer_pilot_env.sv"              
                                                     
    endpackage                                       
                                                     
`endif                                               
