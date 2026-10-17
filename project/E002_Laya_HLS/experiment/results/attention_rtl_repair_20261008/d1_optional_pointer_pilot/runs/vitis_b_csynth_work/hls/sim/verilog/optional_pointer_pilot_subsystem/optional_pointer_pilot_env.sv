//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef OPTIONAL_POINTER_PILOT_ENV__SV                                                                                   
    `define OPTIONAL_POINTER_PILOT_ENV__SV                                                                               
                                                                                                                    
                                                                                                                    
    class optional_pointer_pilot_env extends uvm_env;                                                                          
                                                                                                                    
        optional_pointer_pilot_virtual_sequencer optional_pointer_pilot_virtual_sqr;                                                      
        optional_pointer_pilot_config optional_pointer_pilot_cfg;                                                                         
                                                                                                                    
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_gmem;
        axi_pkg::axi_env#(7,4,4,3,1) axi_lite_control;
        axi_pkg::axi_env#(5,4,4,3,1) axi_lite_control_r;
                                                                                                                    
        optional_pointer_pilot_reference_model   refm;                                                                         
                                                                                                                    
        optional_pointer_pilot_subsystem_monitor subsys_mon;                                                                   
                                                                                                                    
        `uvm_component_utils_begin(optional_pointer_pilot_env)                                                                 
        `uvm_field_object (refm, UVM_DEFAULT | UVM_REFERENCE)                                                       
        `uvm_field_object (optional_pointer_pilot_virtual_sqr, UVM_DEFAULT | UVM_REFERENCE)                                    
        `uvm_field_object (optional_pointer_pilot_cfg        , UVM_DEFAULT)                                                    
        `uvm_component_utils_end                                                                                    
                                                                                                                    
        function new (string name = "optional_pointer_pilot_env", uvm_component parent = null);                              
            super.new(name, parent);                                                                                
        endfunction                                                                                                 
                                                                                                                    
        extern virtual function void build_phase(uvm_phase phase);                                                  
        extern virtual function void connect_phase(uvm_phase phase);                                                
        extern virtual task          run_phase(uvm_phase phase);                                                    
                                                                                                                    
    endclass                                                                                                        
                                                                                                                    
    function void optional_pointer_pilot_env::build_phase(uvm_phase phase);                                                    
        super.build_phase(phase);                                                                                   
        optional_pointer_pilot_cfg = optional_pointer_pilot_config::type_id::create("optional_pointer_pilot_cfg", this);                           
                                                                                                                    

        optional_pointer_pilot_cfg.gmem_cfg.set_default();
        optional_pointer_pilot_cfg.gmem_cfg.drv_type = axi_pkg::SLAVE;
        optional_pointer_pilot_cfg.gmem_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        optional_pointer_pilot_cfg.gmem_cfg.write_latency_mode = TRANSACTION_FIRST;
        optional_pointer_pilot_cfg.gmem_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_gmem*", "cfg", optional_pointer_pilot_cfg.gmem_cfg);
        axi_master_gmem = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_gmem", this);

        optional_pointer_pilot_cfg.control_cfg.set_default();
        optional_pointer_pilot_cfg.control_cfg.drv_type = axi_pkg::MASTER;
        optional_pointer_pilot_cfg.control_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_lite_control*", "cfg", optional_pointer_pilot_cfg.control_cfg);
        axi_lite_control = axi_pkg::axi_env#(7,4,4,3,1)::type_id::create("axi_lite_control", this);

        optional_pointer_pilot_cfg.control_r_cfg.set_default();
        optional_pointer_pilot_cfg.control_r_cfg.drv_type = axi_pkg::MASTER;
        optional_pointer_pilot_cfg.control_r_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_lite_control_r*", "cfg", optional_pointer_pilot_cfg.control_r_cfg);
        axi_lite_control_r = axi_pkg::axi_env#(5,4,4,3,1)::type_id::create("axi_lite_control_r", this);



        refm = optional_pointer_pilot_reference_model::type_id::create("refm", this);


        uvm_config_db#(optional_pointer_pilot_reference_model)::set(this, "*", "refm", refm);


        `uvm_info(this.get_full_name(), "set reference model by uvm_config_db", UVM_LOW)


        subsys_mon = optional_pointer_pilot_subsystem_monitor::type_id::create("subsys_mon", this);


        optional_pointer_pilot_virtual_sqr = optional_pointer_pilot_virtual_sequencer::type_id::create("optional_pointer_pilot_virtual_sqr", this);
        `uvm_info(this.get_full_name(), "build_phase done", UVM_LOW)
    endfunction


    function void optional_pointer_pilot_env::connect_phase(uvm_phase phase);
        super.connect_phase(phase);


        if(optional_pointer_pilot_cfg.gmem_cfg.drv_type==axi_pkg::MASTER ||optional_pointer_pilot_cfg.gmem_cfg.drv_type==axi_pkg::SLAVE)
            optional_pointer_pilot_virtual_sqr.gmem_sqr = axi_master_gmem.vsqr;
        axi_master_gmem.item_wtr_port.connect(subsys_mon.gmem_wtr_imp);
        axi_master_gmem.item_rtr_port.connect(subsys_mon.gmem_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_gmem.state, refm.axi_memaccess_cb_gmem);
        if(optional_pointer_pilot_cfg.control_cfg.drv_type==axi_pkg::MASTER ||optional_pointer_pilot_cfg.control_cfg.drv_type==axi_pkg::SLAVE)
            optional_pointer_pilot_virtual_sqr.control_sqr = axi_lite_control.vsqr;
        axi_lite_control.item_wtr_port.connect(subsys_mon.control_wtr_imp);
        axi_lite_control.item_rtr_port.connect(subsys_mon.control_rtr_imp);
        if(optional_pointer_pilot_cfg.control_r_cfg.drv_type==axi_pkg::MASTER ||optional_pointer_pilot_cfg.control_r_cfg.drv_type==axi_pkg::SLAVE)
            optional_pointer_pilot_virtual_sqr.control_r_sqr = axi_lite_control_r.vsqr;
        axi_lite_control_r.item_wtr_port.connect(subsys_mon.control_r_wtr_imp);
        axi_lite_control_r.item_rtr_port.connect(subsys_mon.control_r_rtr_imp);
        refm.optional_pointer_pilot_cfg = optional_pointer_pilot_cfg;
        `uvm_info(this.get_full_name(), "connect phase done", UVM_LOW)
    endfunction


    task optional_pointer_pilot_env::run_phase(uvm_phase phase);
        `uvm_info(this.get_full_name(), "optional_pointer_pilot_env is running", UVM_LOW)
    endtask


`endif
