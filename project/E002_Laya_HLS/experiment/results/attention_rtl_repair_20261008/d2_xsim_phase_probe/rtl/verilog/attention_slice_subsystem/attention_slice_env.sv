//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================
`ifndef ATTENTION_SLICE_ENV__SV                                                                                   
    `define ATTENTION_SLICE_ENV__SV                                                                               
                                                                                                                    
                                                                                                                    
    class attention_slice_env extends uvm_env;                                                                          
                                                                                                                    
        attention_slice_virtual_sequencer attention_slice_virtual_sqr;                                                      
        attention_slice_config attention_slice_cfg;                                                                         
                                                                                                                    
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_fixture;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_io;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_aux;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_qkv0;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_qkv1;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_att_out;
        axi_pkg::axi_env#(64,4,8,3,1) axi_master_observed;
        axi_pkg::axi_env#(7,4,4,3,1) axi_lite_control_r;
        axi_pkg::axi_env#(4,4,4,3,1) axi_lite_control;
                                                                                                                    
        attention_slice_reference_model   refm;                                                                         
                                                                                                                    
        attention_slice_subsystem_monitor subsys_mon;                                                                   
                                                                                                                    
        `uvm_component_utils_begin(attention_slice_env)                                                                 
        `uvm_field_object (refm, UVM_DEFAULT | UVM_REFERENCE)                                                       
        `uvm_field_object (attention_slice_virtual_sqr, UVM_DEFAULT | UVM_REFERENCE)                                    
        `uvm_field_object (attention_slice_cfg        , UVM_DEFAULT)                                                    
        `uvm_component_utils_end                                                                                    
                                                                                                                    
        function new (string name = "attention_slice_env", uvm_component parent = null);                              
            super.new(name, parent);                                                                                
        endfunction                                                                                                 
                                                                                                                    
        extern virtual function void build_phase(uvm_phase phase);                                                  
        extern virtual function void connect_phase(uvm_phase phase);                                                
        extern virtual task          run_phase(uvm_phase phase);                                                    
                                                                                                                    
    endclass                                                                                                        
                                                                                                                    
    function void attention_slice_env::build_phase(uvm_phase phase);                                                    
        super.build_phase(phase);                                                                                   
        attention_slice_cfg = attention_slice_config::type_id::create("attention_slice_cfg", this);                           
                                                                                                                    

        attention_slice_cfg.fixture_cfg.set_default();
        attention_slice_cfg.fixture_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.fixture_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.fixture_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.fixture_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_fixture*", "cfg", attention_slice_cfg.fixture_cfg);
        axi_master_fixture = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_fixture", this);

        attention_slice_cfg.io_cfg.set_default();
        attention_slice_cfg.io_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.io_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.io_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.io_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_io*", "cfg", attention_slice_cfg.io_cfg);
        axi_master_io = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_io", this);

        attention_slice_cfg.aux_cfg.set_default();
        attention_slice_cfg.aux_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.aux_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.aux_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.aux_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_aux*", "cfg", attention_slice_cfg.aux_cfg);
        axi_master_aux = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_aux", this);

        attention_slice_cfg.qkv0_cfg.set_default();
        attention_slice_cfg.qkv0_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.qkv0_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.qkv0_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.qkv0_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_qkv0*", "cfg", attention_slice_cfg.qkv0_cfg);
        axi_master_qkv0 = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_qkv0", this);

        attention_slice_cfg.qkv1_cfg.set_default();
        attention_slice_cfg.qkv1_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.qkv1_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.qkv1_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.qkv1_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_qkv1*", "cfg", attention_slice_cfg.qkv1_cfg);
        axi_master_qkv1 = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_qkv1", this);

        attention_slice_cfg.att_out_cfg.set_default();
        attention_slice_cfg.att_out_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.att_out_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.att_out_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.att_out_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_att_out*", "cfg", attention_slice_cfg.att_out_cfg);
        axi_master_att_out = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_att_out", this);

        attention_slice_cfg.observed_cfg.set_default();
        attention_slice_cfg.observed_cfg.drv_type = axi_pkg::SLAVE;
        attention_slice_cfg.observed_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        attention_slice_cfg.observed_cfg.write_latency_mode = TRANSACTION_FIRST;
        attention_slice_cfg.observed_cfg.read_latency_mode = TRANSACTION_FIRST;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_master_observed*", "cfg", attention_slice_cfg.observed_cfg);
        axi_master_observed = axi_pkg::axi_env#(64,4,8,3,1)::type_id::create("axi_master_observed", this);

        attention_slice_cfg.control_r_cfg.set_default();
        attention_slice_cfg.control_r_cfg.drv_type = axi_pkg::MASTER;
        attention_slice_cfg.control_r_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_lite_control_r*", "cfg", attention_slice_cfg.control_r_cfg);
        axi_lite_control_r = axi_pkg::axi_env#(7,4,4,3,1)::type_id::create("axi_lite_control_r", this);

        attention_slice_cfg.control_cfg.set_default();
        attention_slice_cfg.control_cfg.drv_type = axi_pkg::MASTER;
        attention_slice_cfg.control_cfg.reset_level = axi_pkg::RESET_LEVEL_LOW;
        uvm_config_db#(axi_pkg::axi_cfg)::set(this, "axi_lite_control*", "cfg", attention_slice_cfg.control_cfg);
        axi_lite_control = axi_pkg::axi_env#(4,4,4,3,1)::type_id::create("axi_lite_control", this);



        refm = attention_slice_reference_model::type_id::create("refm", this);


        uvm_config_db#(attention_slice_reference_model)::set(this, "*", "refm", refm);


        `uvm_info(this.get_full_name(), "set reference model by uvm_config_db", UVM_LOW)


        subsys_mon = attention_slice_subsystem_monitor::type_id::create("subsys_mon", this);


        attention_slice_virtual_sqr = attention_slice_virtual_sequencer::type_id::create("attention_slice_virtual_sqr", this);
        `uvm_info(this.get_full_name(), "build_phase done", UVM_LOW)
    endfunction


    function void attention_slice_env::connect_phase(uvm_phase phase);
        super.connect_phase(phase);


        if(attention_slice_cfg.fixture_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.fixture_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.fixture_sqr = axi_master_fixture.vsqr;
        axi_master_fixture.item_wtr_port.connect(subsys_mon.fixture_wtr_imp);
        axi_master_fixture.item_rtr_port.connect(subsys_mon.fixture_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_fixture.state, refm.axi_memaccess_cb_fixture);
        if(attention_slice_cfg.io_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.io_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.io_sqr = axi_master_io.vsqr;
        axi_master_io.item_wtr_port.connect(subsys_mon.io_wtr_imp);
        axi_master_io.item_rtr_port.connect(subsys_mon.io_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_io.state, refm.axi_memaccess_cb_io);
        if(attention_slice_cfg.aux_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.aux_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.aux_sqr = axi_master_aux.vsqr;
        axi_master_aux.item_wtr_port.connect(subsys_mon.aux_wtr_imp);
        axi_master_aux.item_rtr_port.connect(subsys_mon.aux_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_aux.state, refm.axi_memaccess_cb_aux);
        if(attention_slice_cfg.qkv0_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.qkv0_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.qkv0_sqr = axi_master_qkv0.vsqr;
        axi_master_qkv0.item_wtr_port.connect(subsys_mon.qkv0_wtr_imp);
        axi_master_qkv0.item_rtr_port.connect(subsys_mon.qkv0_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_qkv0.state, refm.axi_memaccess_cb_qkv0);
        if(attention_slice_cfg.qkv1_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.qkv1_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.qkv1_sqr = axi_master_qkv1.vsqr;
        axi_master_qkv1.item_wtr_port.connect(subsys_mon.qkv1_wtr_imp);
        axi_master_qkv1.item_rtr_port.connect(subsys_mon.qkv1_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_qkv1.state, refm.axi_memaccess_cb_qkv1);
        if(attention_slice_cfg.att_out_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.att_out_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.att_out_sqr = axi_master_att_out.vsqr;
        axi_master_att_out.item_wtr_port.connect(subsys_mon.att_out_wtr_imp);
        axi_master_att_out.item_rtr_port.connect(subsys_mon.att_out_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_att_out.state, refm.axi_memaccess_cb_att_out);
        if(attention_slice_cfg.observed_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.observed_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.observed_sqr = axi_master_observed.vsqr;
        axi_master_observed.item_wtr_port.connect(subsys_mon.observed_wtr_imp);
        axi_master_observed.item_rtr_port.connect(subsys_mon.observed_rtr_imp);
        uvm_callbacks#(axi_pkg::axi_state, axi_pkg::axi_state_cbs)::add(axi_master_observed.state, refm.axi_memaccess_cb_observed);
        if(attention_slice_cfg.control_r_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.control_r_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.control_r_sqr = axi_lite_control_r.vsqr;
        axi_lite_control_r.item_wtr_port.connect(subsys_mon.control_r_wtr_imp);
        axi_lite_control_r.item_rtr_port.connect(subsys_mon.control_r_rtr_imp);
        if(attention_slice_cfg.control_cfg.drv_type==axi_pkg::MASTER ||attention_slice_cfg.control_cfg.drv_type==axi_pkg::SLAVE)
            attention_slice_virtual_sqr.control_sqr = axi_lite_control.vsqr;
        axi_lite_control.item_wtr_port.connect(subsys_mon.control_wtr_imp);
        axi_lite_control.item_rtr_port.connect(subsys_mon.control_rtr_imp);
        refm.attention_slice_cfg = attention_slice_cfg;
        `uvm_info(this.get_full_name(), "connect phase done", UVM_LOW)
    endfunction


    task attention_slice_env::run_phase(uvm_phase phase);
        `uvm_info(this.get_full_name(), "attention_slice_env is running", UVM_LOW)
    endtask


`endif
