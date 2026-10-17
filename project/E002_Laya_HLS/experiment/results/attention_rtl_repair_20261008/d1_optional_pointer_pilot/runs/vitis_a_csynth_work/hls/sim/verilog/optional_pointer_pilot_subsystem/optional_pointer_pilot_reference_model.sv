//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef OPTIONAL_POINTER_PILOT_REFERENCE_MODEL_SV
`define OPTIONAL_POINTER_PILOT_REFERENCE_MODEL_SV
typedef class optional_pointer_pilot_reference_model;
class memaccess_axi_state_cbs extends axi_pkg::axi_state_cbs;
    optional_pointer_pilot_reference_model refm;
    string memid;
    //function new(string name="memaccess_axi_state_cbs");
    //    super.new(name);
    //endfunction
    virtual function void memmodel_read_fromar(ref logic[7:0] data[$], input longint addr, input longint len);
        if(memid=="gmem") refm.mem_blk_pages_gmem.read_elems_pipepage(data, addr, len);
    endfunction
endclass

class optional_pointer_pilot_reference_model extends uvm_component;
`define TV_IN_gmem "../tv/cdatafile/c.optional_pointer_pilot.autotvin_gmem.dat"
`define TV_OUT_gmem "../tv/rtldatafile/rtl.optional_pointer_pilot.autotvout_gmem.dat"
`define TV_IN_OFFSET_out_r "../tv/cdatafile/c.optional_pointer_pilot.autotvin_out_r.dat"
`define TV_IN_mode "../tv/cdatafile/c.optional_pointer_pilot.autotvin_mode.dat"
`define TV_OUT_mode ""
`define TV_IN_layer "../tv/cdatafile/c.optional_pointer_pilot.autotvin_layer.dat"
`define TV_OUT_layer ""
`define TV_IN_src_bank "../tv/cdatafile/c.optional_pointer_pilot.autotvin_src_bank.dat"
`define TV_OUT_src_bank ""
`define TV_IN_epoch "../tv/cdatafile/c.optional_pointer_pilot.autotvin_epoch.dat"
`define TV_OUT_epoch ""
`define TV_IN_second_id "../tv/cdatafile/c.optional_pointer_pilot.autotvin_second_id.dat"
`define TV_OUT_second_id ""
`define TV_IN_second_bank "../tv/cdatafile/c.optional_pointer_pilot.autotvin_second_bank.dat"
`define TV_OUT_second_bank ""
`define TV_IN_second_epoch "../tv/cdatafile/c.optional_pointer_pilot.autotvin_second_epoch.dat"
`define TV_OUT_second_epoch ""
`define TV_IN_second_region "../tv/cdatafile/c.optional_pointer_pilot.autotvin_second_region.dat"
`define TV_OUT_second_region ""
`define TV_IN_load_ok "../tv/cdatafile/c.optional_pointer_pilot.autotvin_load_ok.dat"
`define TV_OUT_load_ok ""
`define TV_IN_out_r "../tv/cdatafile/c.optional_pointer_pilot.autotvin_out_r.dat"
`define TV_OUT_out_r ""
    bit  write_data_finish_control;
    bit  write_data_finish_control_r;
    event allaxilite_write_data_finish;
    event allaxilite_write_one_transaction_finish;
    event write_start_finish;
    int trans_num_total = 15;
    int trans_num_idx;
    int ap_done_cnt=1;
    event dut2tb_ap_ready;
    event dut2tb_ap_done;
    event ap_ready_for_nexttrans;
    event ap_done_for_nexttrans;
    event finish;
    optional_pointer_pilot_config optional_pointer_pilot_cfg;
    virtual interface misc_interface misc_if;

    mem_model_pages_with_diffofst#(32,8) mem_blk_pages_gmem;
    int blk_id_gmem = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_gmem;

    mem_model_pages#(8,8) mem_blk_pages_control_mode;
    mem_model_pages#(8,8) mem_blk_pages_control_layer;
    mem_model_pages#(8,8) mem_blk_pages_control_src_bank;
    mem_model_pages#(32,8) mem_blk_pages_control_epoch;
    mem_model_pages#(8,8) mem_blk_pages_control_second_id;
    mem_model_pages#(8,8) mem_blk_pages_control_second_bank;
    mem_model_pages#(32,8) mem_blk_pages_control_second_epoch;
    mem_model_pages#(8,8) mem_blk_pages_control_second_region;
    mem_model_pages#(8,8) mem_blk_pages_control_load_ok;
    
    `uvm_component_utils_begin(optional_pointer_pilot_reference_model)
        `uvm_field_int (trans_num_idx, UVM_DEFAULT)
    `uvm_component_utils_end

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual misc_interface)::get(this, "", "misc_if", misc_if))
            `uvm_fatal(this.get_full_name(), "No misc_if from high level")
        axi_memaccess_cb_gmem = new;
        axi_memaccess_cb_gmem.refm = this;
        axi_memaccess_cb_gmem.memid = "gmem";
    endfunction

    function new (string name = "", uvm_component parent = null);
        super.new (name, parent);
        trans_num_idx= 0;
    endfunction

    virtual task run_phase(uvm_phase phase);
        string fpath[$];
misc_if.dut2tb_ap_done = 0;

        fpath.push_back(`TV_IN_mode);
        mem_blk_pages_control_mode = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_mode");
        mem_blk_pages_control_mode.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 16);
        fpath.delete;


        fpath.push_back(`TV_IN_layer);
        mem_blk_pages_control_layer = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_layer");
        mem_blk_pages_control_layer.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 24);
        fpath.delete;


        fpath.push_back(`TV_IN_src_bank);
        mem_blk_pages_control_src_bank = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_src_bank");
        mem_blk_pages_control_src_bank.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 32);
        fpath.delete;


        fpath.push_back(`TV_IN_epoch);
        mem_blk_pages_control_epoch = mem_model_pages#(32,8)::type_id::create("mem_blk_pages_control_epoch");
        mem_blk_pages_control_epoch.tvinload_pagechk_atinit(fpath, 1*((32+7)/8), 0, 40);
        fpath.delete;


        fpath.push_back(`TV_IN_second_id);
        mem_blk_pages_control_second_id = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_second_id");
        mem_blk_pages_control_second_id.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 48);
        fpath.delete;


        fpath.push_back(`TV_IN_second_bank);
        mem_blk_pages_control_second_bank = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_second_bank");
        mem_blk_pages_control_second_bank.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 56);
        fpath.delete;


        fpath.push_back(`TV_IN_second_epoch);
        mem_blk_pages_control_second_epoch = mem_model_pages#(32,8)::type_id::create("mem_blk_pages_control_second_epoch");
        mem_blk_pages_control_second_epoch.tvinload_pagechk_atinit(fpath, 1*((32+7)/8), 0, 64);
        fpath.delete;


        fpath.push_back(`TV_IN_second_region);
        mem_blk_pages_control_second_region = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_second_region");
        mem_blk_pages_control_second_region.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 72);
        fpath.delete;


        fpath.push_back(`TV_IN_load_ok);
        mem_blk_pages_control_load_ok = mem_model_pages#(8,8)::type_id::create("mem_blk_pages_control_load_ok");
        mem_blk_pages_control_load_ok.tvinload_pagechk_atinit(fpath, 1*((8+7)/8), 0, 80);
        fpath.delete;

        fpath.push_back(`TV_IN_gmem);
        mem_blk_pages_gmem = mem_model_pages_with_diffofst#(32,8)::type_id::create("mem_blk_pages_gmem");
        mem_blk_pages_gmem.whole_page_size=208;
        mem_blk_pages_gmem.maxi_bundlevar_fpath["out_r"]=`TV_IN_OFFSET_out_r;
        mem_blk_pages_gmem.set_binary(1);
        mem_blk_pages_gmem.tvinload_pagechk_atinit(fpath, 36*((32+7)/8), 0, 0);
        mem_blk_pages_gmem.tvoutdump_atinit(`TV_OUT_gmem);
        fpath.delete();

        fork
            forever begin
                wait(write_data_finish_control&&write_data_finish_control_r);
                `uvm_info("", "trigger_allaxilite_data_write_finish", UVM_LOW)
                @(posedge misc_if.clock);
                write_data_finish_control = 0;
                write_data_finish_control_r = 0;
                -> allaxilite_write_data_finish;
            end
            forever begin
                //this is non-pipeline case
                forever begin
                    @(negedge misc_if.clock);
                    if(misc_if.dut2tb_ap_done===1) break;
                end
                @(posedge misc_if.clock);
                @allaxilite_write_data_finish;
                @(posedge misc_if.clock);
                -> ap_ready_for_nexttrans;
                `uvm_info(this.get_full_name(), "trigger event ap_ready_for_nexttrans", UVM_LOW)
                fork
                    begin
                        misc_if.ap_ready_for_nexttrans = 1;
                        @(posedge misc_if.clock);
                        misc_if.ap_ready_for_nexttrans = 0;
                    end
                join_none
            end
            forever begin
                forever begin
                    @(negedge misc_if.clock);
                    if(misc_if.dut2tb_ap_done===1) break;
                end
                @(posedge misc_if.clock);
                fork
                    begin
                        @(negedge misc_if.clock);
                        -> misc_if.dut2tb_ap_done_evt;
                        #0;
                        -> misc_if.dut2tb_ap_ready_evt;
                    end
                join_none
                -> ap_done_for_nexttrans;
                `uvm_info(this.get_full_name(), "trigger event ap_done_for_nexttrans", UVM_LOW)
                fork
                    begin
                        misc_if.ap_done_for_nexttrans = 1;
                        @(posedge misc_if.clock);
                        misc_if.ap_done_for_nexttrans = 0;
                    end
                join_none
            end

            for(int i=1; i<15; i++) begin
                @dut2tb_ap_ready;
                mem_blk_pages_gmem.incr_rd_page_idx() ;
            end
            forever begin
                forever begin
                    @(negedge misc_if.clock);
                    if (misc_if.dut2tb_ap_ready === 1)   break;
                end
                @(posedge misc_if.clock);
                `uvm_info(this.get_full_name(), "trigger event DUT2TB_AP_READY", UVM_LOW)
                -> dut2tb_ap_ready;
                 misc_if.tb2dut_ap_start = 0;
            end
            forever begin
                forever begin
                    @(negedge misc_if.clock);
                    if (misc_if.dut2tb_ap_done_kernel === 1)   break;
                end
                @(posedge misc_if.clock);
                fork
                    begin
                        @(negedge misc_if.clock);
                        `uvm_info(this.get_full_name(), "trigger event dut2tb_ap_done_kernel_evt", UVM_LOW)
                        -> misc_if.dut2tb_ap_done_kernel_evt;
                    end
                join_none
            end
        join
    endtask

    virtual function void write_axi_wtr_gmem(axi_pkg::axi_transfer tr);
        mem_blk_pages_gmem.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_gmem(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_control(axi_pkg::axi_transfer tr);
        if(tr.addr == 0 && tr.len == 0 && tr.data[0][0]==1) begin //addr 0 and bit 0 are parameter
            -> write_start_finish;
            misc_if.tb2dut_ap_start = 1;
        end
    endfunction
    virtual function void write_axi_rtr_control(axi_pkg::axi_transfer tr);
            `uvm_info("receive axi read data", tr.sprint(), UVM_HIGH)
        if(tr.addr == 0 && tr.len == 0) begin
            if(tr.data[0][1]==1) begin  //bit 1 is parameter
                `uvm_info("status polling", "ap_done is polled", UVM_LOW);
                fork
                    begin
                        misc_if.dut2tb_ap_done = 1;
                        @(posedge misc_if.clock);
                        #0;
                        misc_if.dut2tb_ap_done = 0;
                        misc_if.tb2dut_ap_continue = 0;
                        -> dut2tb_ap_done;
                    end
                join_none
            end
            begin
                misc_if.dut2tb_ap_idle = tr.data[0][2];
            end
        end else begin
        end
    endfunction

    virtual function void write_axi_wtr_control_r(axi_pkg::axi_transfer tr);
    endfunction
    virtual function void write_axi_rtr_control_r(axi_pkg::axi_transfer tr);
            `uvm_info("receive axi read data", tr.sprint(), UVM_HIGH)
        if(0) begin //no block ctrl register processing
        end else begin
        end
    endfunction
endclass
`endif
