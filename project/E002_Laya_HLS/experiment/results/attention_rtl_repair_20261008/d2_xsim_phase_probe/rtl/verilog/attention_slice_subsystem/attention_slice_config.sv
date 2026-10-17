//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef ATTENTION_SLICE_CONFIG__SV                        
    `define ATTENTION_SLICE_CONFIG__SV                    
                                                            
    class attention_slice_config extends uvm_object;            
                                                            
        int check_ena;                                      
        int cover_ena;                                      
        axi_pkg::axi_cfg fixture_cfg;
        axi_pkg::axi_cfg io_cfg;
        axi_pkg::axi_cfg aux_cfg;
        axi_pkg::axi_cfg qkv0_cfg;
        axi_pkg::axi_cfg qkv1_cfg;
        axi_pkg::axi_cfg att_out_cfg;
        axi_pkg::axi_cfg observed_cfg;
        axi_pkg::axi_cfg control_r_cfg;
        axi_pkg::axi_cfg control_cfg;

        `uvm_object_utils_begin(attention_slice_config)         
        `uvm_field_object(fixture_cfg, UVM_DEFAULT);
        `uvm_field_object(io_cfg, UVM_DEFAULT);
        `uvm_field_object(aux_cfg, UVM_DEFAULT);
        `uvm_field_object(qkv0_cfg, UVM_DEFAULT);
        `uvm_field_object(qkv1_cfg, UVM_DEFAULT);
        `uvm_field_object(att_out_cfg, UVM_DEFAULT);
        `uvm_field_object(observed_cfg, UVM_DEFAULT);
        `uvm_field_object(control_r_cfg, UVM_DEFAULT);
        `uvm_field_object(control_cfg, UVM_DEFAULT);
        `uvm_field_int   (check_ena , UVM_DEFAULT)          
        `uvm_field_int   (cover_ena , UVM_DEFAULT)          
        `uvm_object_utils_end                               

        function new (string name = "attention_slice_config");
            super.new(name);                                
            fixture_cfg = new("fixture_cfg", 1);
            io_cfg = new("io_cfg", 1);
            aux_cfg = new("aux_cfg", 1);
            qkv0_cfg = new("qkv0_cfg", 1);
            qkv1_cfg = new("qkv1_cfg", 1);
            att_out_cfg = new("att_out_cfg", 1);
            observed_cfg = new("observed_cfg", 1);
            control_r_cfg = axi_pkg::axi_cfg::type_id::create("control_r_cfg");
            control_cfg = axi_pkg::axi_cfg::type_id::create("control_cfg");
        endfunction                                         
                                                            
    endclass                                                
                                                            
`endif                                                      
