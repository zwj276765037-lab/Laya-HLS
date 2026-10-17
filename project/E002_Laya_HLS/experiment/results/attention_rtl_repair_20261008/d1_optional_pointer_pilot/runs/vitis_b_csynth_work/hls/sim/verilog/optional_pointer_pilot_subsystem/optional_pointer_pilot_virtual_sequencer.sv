//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef OPTIONAL_POINTER_PILOT_VIRTUAL_SEQUENCER__SV                        
    `define OPTIONAL_POINTER_PILOT_VIRTUAL_SEQUENCER__SV                    
                                                                       
    class optional_pointer_pilot_virtual_sequencer extends uvm_sequencer;         
        axi_pkg::axi_virtual_sequencer gmem_sqr; 
        axi_pkg::axi_virtual_sequencer control_sqr; 
        axi_pkg::axi_virtual_sequencer control_r_sqr; 
 
        function new (string name, uvm_component parent);              
            super.new(name, parent);                                   
            //`uvm_info(this.get_full_name(), "new is called", UVM_LOW)
        endfunction                                                    
                                                                       
        `uvm_component_utils_begin(optional_pointer_pilot_virtual_sequencer)      
        `uvm_component_utils_end                                       
                                                                       
    endclass

`endif
