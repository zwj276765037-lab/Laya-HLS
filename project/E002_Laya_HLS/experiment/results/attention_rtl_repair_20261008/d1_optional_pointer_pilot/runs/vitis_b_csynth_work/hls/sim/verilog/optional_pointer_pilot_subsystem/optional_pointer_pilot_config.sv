//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef OPTIONAL_POINTER_PILOT_CONFIG__SV                        
    `define OPTIONAL_POINTER_PILOT_CONFIG__SV                    
                                                            
    class optional_pointer_pilot_config extends uvm_object;            
                                                            
        int check_ena;                                      
        int cover_ena;                                      
        axi_pkg::axi_cfg gmem_cfg;
        axi_pkg::axi_cfg control_cfg;
        axi_pkg::axi_cfg control_r_cfg;

        `uvm_object_utils_begin(optional_pointer_pilot_config)         
        `uvm_field_object(gmem_cfg, UVM_DEFAULT);
        `uvm_field_object(control_cfg, UVM_DEFAULT);
        `uvm_field_object(control_r_cfg, UVM_DEFAULT);
        `uvm_field_int   (check_ena , UVM_DEFAULT)          
        `uvm_field_int   (cover_ena , UVM_DEFAULT)          
        `uvm_object_utils_end                               

        function new (string name = "optional_pointer_pilot_config");
            super.new(name);                                
            gmem_cfg = new("gmem_cfg", 1);
            control_cfg = axi_pkg::axi_cfg::type_id::create("control_cfg");
            control_r_cfg = axi_pkg::axi_cfg::type_id::create("control_r_cfg");
        endfunction                                         
                                                            
    endclass                                                
                                                            
`endif                                                      
