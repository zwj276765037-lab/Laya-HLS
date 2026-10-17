//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef ATTENTION_SLICE_REFERENCE_MODEL_SV
`define ATTENTION_SLICE_REFERENCE_MODEL_SV
typedef class attention_slice_reference_model;
class memaccess_axi_state_cbs extends axi_pkg::axi_state_cbs;
    attention_slice_reference_model refm;
    string memid;
    //function new(string name="memaccess_axi_state_cbs");
    //    super.new(name);
    //endfunction
    virtual function void memmodel_read_fromar(ref logic[7:0] data[$], input longint addr, input longint len);
        if(memid=="fixture") refm.mem_blk_pages_fixture.read_elems_pipepage(data, addr, len);
        if(memid=="io") refm.mem_blk_pages_io.read_elems_pipepage(data, addr, len);
        if(memid=="aux") refm.mem_blk_pages_aux.read_elems_pipepage(data, addr, len);
        if(memid=="qkv0") refm.mem_blk_pages_qkv0.read_elems_pipepage(data, addr, len);
        if(memid=="qkv1") refm.mem_blk_pages_qkv1.read_elems_pipepage(data, addr, len);
        if(memid=="att_out") refm.mem_blk_pages_att_out.read_elems_pipepage(data, addr, len);
        if(memid=="observed") refm.mem_blk_pages_observed.read_elems_pipepage(data, addr, len);
    endfunction
endclass

class attention_slice_reference_model extends uvm_component;
`define TV_IN_fixture "../tv/cdatafile/c.attention_slice.autotvin_fixture.dat"
`define TV_OUT_fixture "../tv/rtldatafile/rtl.attention_slice.autotvout_fixture.dat"
`define TV_IN_OFFSET_fixture_r "../tv/cdatafile/c.attention_slice.autotvin_fixture_r.dat"
`define TV_IN_io "../tv/cdatafile/c.attention_slice.autotvin_io.dat"
`define TV_OUT_io "../tv/rtldatafile/rtl.attention_slice.autotvout_io.dat"
`define TV_IN_OFFSET_io_r "../tv/cdatafile/c.attention_slice.autotvin_io_r.dat"
`define TV_IN_aux "../tv/cdatafile/c.attention_slice.autotvin_aux.dat"
`define TV_OUT_aux "../tv/rtldatafile/rtl.attention_slice.autotvout_aux.dat"
`define TV_IN_OFFSET_aux_r "../tv/cdatafile/c.attention_slice.autotvin_aux_r.dat"
`define TV_IN_qkv0 "../tv/cdatafile/c.attention_slice.autotvin_qkv0.dat"
`define TV_OUT_qkv0 "../tv/rtldatafile/rtl.attention_slice.autotvout_qkv0.dat"
`define TV_IN_OFFSET_qkv0_r "../tv/cdatafile/c.attention_slice.autotvin_qkv0_r.dat"
`define TV_IN_qkv1 "../tv/cdatafile/c.attention_slice.autotvin_qkv1.dat"
`define TV_OUT_qkv1 "../tv/rtldatafile/rtl.attention_slice.autotvout_qkv1.dat"
`define TV_IN_OFFSET_qkv1_r "../tv/cdatafile/c.attention_slice.autotvin_qkv1_r.dat"
`define TV_IN_att_out "../tv/cdatafile/c.attention_slice.autotvin_att_out.dat"
`define TV_OUT_att_out "../tv/rtldatafile/rtl.attention_slice.autotvout_att_out.dat"
`define TV_IN_OFFSET_att_out_r "../tv/cdatafile/c.attention_slice.autotvin_att_out_r.dat"
`define TV_IN_observed "../tv/cdatafile/c.attention_slice.autotvin_observed.dat"
`define TV_OUT_observed "../tv/rtldatafile/rtl.attention_slice.autotvout_observed.dat"
`define TV_IN_OFFSET_observed_r "../tv/cdatafile/c.attention_slice.autotvin_observed_r.dat"
`define TV_IN_fixture_r "../tv/cdatafile/c.attention_slice.autotvin_fixture_r.dat"
`define TV_OUT_fixture_r ""
`define TV_IN_io_r "../tv/cdatafile/c.attention_slice.autotvin_io_r.dat"
`define TV_OUT_io_r ""
`define TV_IN_aux_r "../tv/cdatafile/c.attention_slice.autotvin_aux_r.dat"
`define TV_OUT_aux_r ""
`define TV_IN_qkv0_r "../tv/cdatafile/c.attention_slice.autotvin_qkv0_r.dat"
`define TV_OUT_qkv0_r ""
`define TV_IN_qkv1_r "../tv/cdatafile/c.attention_slice.autotvin_qkv1_r.dat"
`define TV_OUT_qkv1_r ""
`define TV_IN_att_out_r "../tv/cdatafile/c.attention_slice.autotvin_att_out_r.dat"
`define TV_OUT_att_out_r ""
`define TV_IN_observed_r "../tv/cdatafile/c.attention_slice.autotvin_observed_r.dat"
`define TV_OUT_observed_r ""
    bit  write_data_finish_control_r;
    event allaxilite_write_data_finish;
    event allaxilite_write_one_transaction_finish;
    event write_start_finish;
    int trans_num_total = 1;
    int trans_num_idx;
    int ap_done_cnt=1;
    event dut2tb_ap_ready;
    event dut2tb_ap_done;
    event ap_ready_for_nexttrans;
    event ap_done_for_nexttrans;
    event finish;
    attention_slice_config attention_slice_cfg;
    virtual interface misc_interface misc_if;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_fixture;
    int blk_id_fixture = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_fixture;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_io;
    int blk_id_io = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_io;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_aux;
    int blk_id_aux = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_aux;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_qkv0;
    int blk_id_qkv0 = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_qkv0;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_qkv1;
    int blk_id_qkv1 = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_qkv1;

    mem_model_pages_with_diffofst#(8,8) mem_blk_pages_att_out;
    int blk_id_att_out = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_att_out;

    mem_model_pages_with_diffofst#(32,8) mem_blk_pages_observed;
    int blk_id_observed = 0;
    memaccess_axi_state_cbs axi_memaccess_cb_observed;

    
    `uvm_component_utils_begin(attention_slice_reference_model)
        `uvm_field_int (trans_num_idx, UVM_DEFAULT)
    `uvm_component_utils_end

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual misc_interface)::get(this, "", "misc_if", misc_if))
            `uvm_fatal(this.get_full_name(), "No misc_if from high level")
        axi_memaccess_cb_fixture = new;
        axi_memaccess_cb_fixture.refm = this;
        axi_memaccess_cb_fixture.memid = "fixture";
        axi_memaccess_cb_io = new;
        axi_memaccess_cb_io.refm = this;
        axi_memaccess_cb_io.memid = "io";
        axi_memaccess_cb_aux = new;
        axi_memaccess_cb_aux.refm = this;
        axi_memaccess_cb_aux.memid = "aux";
        axi_memaccess_cb_qkv0 = new;
        axi_memaccess_cb_qkv0.refm = this;
        axi_memaccess_cb_qkv0.memid = "qkv0";
        axi_memaccess_cb_qkv1 = new;
        axi_memaccess_cb_qkv1.refm = this;
        axi_memaccess_cb_qkv1.memid = "qkv1";
        axi_memaccess_cb_att_out = new;
        axi_memaccess_cb_att_out.refm = this;
        axi_memaccess_cb_att_out.memid = "att_out";
        axi_memaccess_cb_observed = new;
        axi_memaccess_cb_observed.refm = this;
        axi_memaccess_cb_observed.memid = "observed";
    endfunction

    function new (string name = "", uvm_component parent = null);
        super.new (name, parent);
        trans_num_idx= 0;
    endfunction

    virtual task run_phase(uvm_phase phase);
        string fpath[$];
misc_if.dut2tb_ap_done = 0;
        fpath.push_back(`TV_IN_fixture);
        mem_blk_pages_fixture = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_fixture");
        mem_blk_pages_fixture.whole_page_size=786448;
        mem_blk_pages_fixture.maxi_bundlevar_fpath["fixture_r"]=`TV_IN_OFFSET_fixture_r;
        mem_blk_pages_fixture.set_binary(1);
        mem_blk_pages_fixture.tvinload_pagechk_atinit(fpath, 786432*((8+7)/8), 0, 0);
        fpath.delete();

        fpath.push_back(`TV_IN_io);
        mem_blk_pages_io = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_io");
        mem_blk_pages_io.whole_page_size=32784;
        mem_blk_pages_io.maxi_bundlevar_fpath["io_r"]=`TV_IN_OFFSET_io_r;
        mem_blk_pages_io.set_binary(1);
        mem_blk_pages_io.tvinload_pagechk_atinit(fpath, 32768*((8+7)/8), 0, 0);
        mem_blk_pages_io.tvoutdump_atinit(`TV_OUT_io);
        fpath.delete();

        fpath.push_back(`TV_IN_aux);
        mem_blk_pages_aux = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_aux");
        mem_blk_pages_aux.whole_page_size=1671888;
        mem_blk_pages_aux.maxi_bundlevar_fpath["aux_r"]=`TV_IN_OFFSET_aux_r;
        mem_blk_pages_aux.set_binary(1);
        mem_blk_pages_aux.tvinload_pagechk_atinit(fpath, 1671872*((8+7)/8), 0, 0);
        fpath.delete();

        fpath.push_back(`TV_IN_qkv0);
        mem_blk_pages_qkv0 = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_qkv0");
        mem_blk_pages_qkv0.whole_page_size=12582928;
        mem_blk_pages_qkv0.maxi_bundlevar_fpath["qkv0_r"]=`TV_IN_OFFSET_qkv0_r;
        mem_blk_pages_qkv0.set_binary(1);
        mem_blk_pages_qkv0.tvinload_pagechk_atinit(fpath, 12582912*((8+7)/8), 0, 0);
        mem_blk_pages_qkv0.tvoutdump_atinit(`TV_OUT_qkv0);
        fpath.delete();

        fpath.push_back(`TV_IN_qkv1);
        mem_blk_pages_qkv1 = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_qkv1");
        mem_blk_pages_qkv1.whole_page_size=12582928;
        mem_blk_pages_qkv1.maxi_bundlevar_fpath["qkv1_r"]=`TV_IN_OFFSET_qkv1_r;
        mem_blk_pages_qkv1.set_binary(1);
        mem_blk_pages_qkv1.tvinload_pagechk_atinit(fpath, 12582912*((8+7)/8), 0, 0);
        mem_blk_pages_qkv1.tvoutdump_atinit(`TV_OUT_qkv1);
        fpath.delete();

        fpath.push_back(`TV_IN_att_out);
        mem_blk_pages_att_out = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_att_out");
        mem_blk_pages_att_out.whole_page_size=8388624;
        mem_blk_pages_att_out.maxi_bundlevar_fpath["att_out_r"]=`TV_IN_OFFSET_att_out_r;
        mem_blk_pages_att_out.set_binary(1);
        mem_blk_pages_att_out.tvinload_pagechk_atinit(fpath, 8388608*((8+7)/8), 0, 0);
        mem_blk_pages_att_out.tvoutdump_atinit(`TV_OUT_att_out);
        fpath.delete();

        fpath.push_back(`TV_IN_observed);
        mem_blk_pages_observed = mem_model_pages_with_diffofst#(32,8)::type_id::create("mem_blk_pages_observed");
        mem_blk_pages_observed.whole_page_size=1088;
        mem_blk_pages_observed.maxi_bundlevar_fpath["observed_r"]=`TV_IN_OFFSET_observed_r;
        mem_blk_pages_observed.set_binary(1);
        mem_blk_pages_observed.tvinload_pagechk_atinit(fpath, 256*((32+7)/8), 0, 0);
        mem_blk_pages_observed.tvoutdump_atinit(`TV_OUT_observed);
        fpath.delete();

        fork
            forever begin
                wait(write_data_finish_control_r);
                `uvm_info("", "trigger_allaxilite_data_write_finish", UVM_LOW)
                @(posedge misc_if.clock);
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

            for(int i=1; i<1; i++) begin
                @dut2tb_ap_ready;
                mem_blk_pages_fixture.incr_rd_page_idx() ;
                mem_blk_pages_io.incr_rd_page_idx() ;
                mem_blk_pages_aux.incr_rd_page_idx() ;
                mem_blk_pages_qkv0.incr_rd_page_idx() ;
                mem_blk_pages_qkv1.incr_rd_page_idx() ;
                mem_blk_pages_att_out.incr_rd_page_idx() ;
                mem_blk_pages_observed.incr_rd_page_idx() ;
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

    virtual function void write_axi_wtr_fixture(axi_pkg::axi_transfer tr);
        mem_blk_pages_fixture.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_fixture(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_io(axi_pkg::axi_transfer tr);
        mem_blk_pages_io.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_io(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_aux(axi_pkg::axi_transfer tr);
        mem_blk_pages_aux.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_aux(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_qkv0(axi_pkg::axi_transfer tr);
        mem_blk_pages_qkv0.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_qkv0(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_qkv1(axi_pkg::axi_transfer tr);
        mem_blk_pages_qkv1.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_qkv1(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_att_out(axi_pkg::axi_transfer tr);
        mem_blk_pages_att_out.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_att_out(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_observed(axi_pkg::axi_transfer tr);
        mem_blk_pages_observed.write_elems_pipepage(tr.data,tr.byte_addr);
    endfunction

    virtual function void write_axi_rtr_observed(axi_pkg::axi_transfer tr);
    endfunction

    virtual function void write_axi_wtr_control_r(axi_pkg::axi_transfer tr);
    endfunction
    virtual function void write_axi_rtr_control_r(axi_pkg::axi_transfer tr);
            `uvm_info("receive axi read data", tr.sprint(), UVM_HIGH)
        if(0) begin //no block ctrl register processing
        end else begin
        end
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
endclass
`endif
