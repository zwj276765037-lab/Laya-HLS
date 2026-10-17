//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef ATTENTION_SLICE_VIRTUAL_SEQUENCER__SV                        
    `define ATTENTION_SLICE_VIRTUAL_SEQUENCER__SV                    
                                                                       
    class attention_slice_virtual_sequencer extends uvm_sequencer;         
        axi_pkg::axi_virtual_sequencer fixture_sqr; 
        axi_pkg::axi_virtual_sequencer io_sqr; 
        axi_pkg::axi_virtual_sequencer aux_sqr; 
        axi_pkg::axi_virtual_sequencer qkv0_sqr; 
        axi_pkg::axi_virtual_sequencer qkv1_sqr; 
        axi_pkg::axi_virtual_sequencer att_out_sqr; 
        axi_pkg::axi_virtual_sequencer observed_sqr; 
        axi_pkg::axi_virtual_sequencer control_r_sqr; 
        axi_pkg::axi_virtual_sequencer control_sqr; 
 
        function new (string name, uvm_component parent);              
            super.new(name, parent);                                   
            //`uvm_info(this.get_full_name(), "new is called", UVM_LOW)
        endfunction                                                    
                                                                       
        `uvm_component_utils_begin(attention_slice_virtual_sequencer)      
        `uvm_component_utils_end                                       
                                                                       
    endclass

`endif
