//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef ATTENTION_SLICE_REFERENCE_MODEL_SV
`define ATTENTION_SLICE_REFERENCE_MODEL_SV
import "DPI-C" function void phase_probe_stage(input string label,
    input longint sim_ps, input longint clock_count,
    input longint value0, input longint value1);
import "DPI-C" function longint phase_probe_file_bytes(input string path);
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

    // Report only fixed scalar accounting from the actual generated TV loader.
    // The loader's queues and the memory pages retain their original behavior.
    function void phase_probe_memory(string port, string tv_path,
                                     string offset_path,
                                     longint unsigned fread_bytes,
                                     longint unsigned payload_bytes,
                                     longint unsigned elements,
                                     longint unsigned transactions,
                                     longint unsigned header_reads,
                                     longint unsigned trailer_reads,
                                     longint unsigned first_header_value,
                                     longint unsigned last_header_value,
                                     longint unsigned trailer_value,
                                     longint unsigned offset_fread_bytes,
                                     longint unsigned offset_elements,
                                     longint unsigned offset_transactions,
                                     longint unsigned copy_elements,
                                     longint unsigned pages_created,
                                     int whole_page_size, int actual_offset);
        longint offset_file_bytes;
        offset_file_bytes = phase_probe_file_bytes(offset_path);
        if (offset_file_bytes < 0)
            $fatal(1, "D2_PHASE_PROBE_INVALID unreadable ASCII offset TV port=%s path=%s",
                   port, offset_path);
        $display("D2_PHASE_INIT port=%s tv=%s offset_tv=%s fread_bytes=%0d payload_bytes=%0d elements=%0d transactions=%0d header_reads=%0d trailer_reads=%0d first_header=%0d last_header=%0d trailer_hex=%h offset_parse=ascii_fscanf offset_file_bytes=%0d offset_fread_bytes=%0d offset_elements=%0d offset_transactions=%0d copied_u8_elements=%0d pages_created=%0d whole_page_size=%0d actual_offset=%0d sim_ps=%0d",
                 port, tv_path, offset_path, fread_bytes, payload_bytes,
                 elements, transactions, header_reads, trailer_reads,
                 first_header_value, last_header_value, trailer_value,
                 offset_file_bytes, offset_fread_bytes, offset_elements, offset_transactions,
                 copy_elements, pages_created, whole_page_size, actual_offset,
                 longint'($realtime * 1000.0));
        phase_probe_stage({"memory_after_", port}, longint'($realtime * 1000.0),
                          -1, longint'(fread_bytes + offset_file_bytes),
                          longint'(copy_elements));
    endfunction

    virtual task run_phase(uvm_phase phase);
        string fpath[$];
misc_if.dut2tb_ap_done = 0;
        phase_probe_stage("memory_before_fixture", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_fixture);
        mem_blk_pages_fixture = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_fixture");
        mem_blk_pages_fixture.whole_page_size=786448;
        mem_blk_pages_fixture.maxi_bundlevar_fpath["fixture_r"]=`TV_IN_OFFSET_fixture_r;
        mem_blk_pages_fixture.set_binary(1);
        mem_blk_pages_fixture.tvinload_pagechk_atinit(fpath, 786432*((8+7)/8), 0, 0);
        phase_probe_memory("fixture", `TV_IN_fixture, `TV_IN_OFFSET_fixture_r,
            mem_blk_pages_fixture.phase_fread_bytes, mem_blk_pages_fixture.phase_payload_bytes,
            mem_blk_pages_fixture.phase_elements, mem_blk_pages_fixture.phase_transactions,
            mem_blk_pages_fixture.phase_header_reads, mem_blk_pages_fixture.phase_trailer_reads,
            mem_blk_pages_fixture.phase_first_header_value,
            mem_blk_pages_fixture.phase_last_header_value,
            mem_blk_pages_fixture.phase_trailer_value,
            mem_blk_pages_fixture.phase_offset_fread_bytes, mem_blk_pages_fixture.phase_offset_elements,
            mem_blk_pages_fixture.phase_offset_transactions, mem_blk_pages_fixture.phase_copy_elements,
            mem_blk_pages_fixture.phase_pages_created, mem_blk_pages_fixture.whole_page_size,
            mem_blk_pages_fixture.maxi_bundlevar_offset["fixture_r"]);
        fpath.delete();

        phase_probe_stage("memory_before_io", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_io);
        mem_blk_pages_io = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_io");
        mem_blk_pages_io.whole_page_size=32784;
        mem_blk_pages_io.maxi_bundlevar_fpath["io_r"]=`TV_IN_OFFSET_io_r;
        mem_blk_pages_io.set_binary(1);
        mem_blk_pages_io.tvinload_pagechk_atinit(fpath, 32768*((8+7)/8), 0, 0);
        phase_probe_memory("io", `TV_IN_io, `TV_IN_OFFSET_io_r,
            mem_blk_pages_io.phase_fread_bytes, mem_blk_pages_io.phase_payload_bytes,
            mem_blk_pages_io.phase_elements, mem_blk_pages_io.phase_transactions,
            mem_blk_pages_io.phase_header_reads, mem_blk_pages_io.phase_trailer_reads,
            mem_blk_pages_io.phase_first_header_value,
            mem_blk_pages_io.phase_last_header_value,
            mem_blk_pages_io.phase_trailer_value,
            mem_blk_pages_io.phase_offset_fread_bytes, mem_blk_pages_io.phase_offset_elements,
            mem_blk_pages_io.phase_offset_transactions, mem_blk_pages_io.phase_copy_elements,
            mem_blk_pages_io.phase_pages_created, mem_blk_pages_io.whole_page_size,
            mem_blk_pages_io.maxi_bundlevar_offset["io_r"]);
        mem_blk_pages_io.tvoutdump_atinit(`TV_OUT_io);
        phase_probe_stage("output_dump_io_ready", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.delete();

        phase_probe_stage("memory_before_aux", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_aux);
        mem_blk_pages_aux = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_aux");
        mem_blk_pages_aux.whole_page_size=144;
        mem_blk_pages_aux.maxi_bundlevar_fpath["aux_r"]=`TV_IN_OFFSET_aux_r;
        mem_blk_pages_aux.set_binary(1);
        mem_blk_pages_aux.tvinload_pagechk_atinit(fpath, 128*((8+7)/8), 0, 0);
        phase_probe_memory("aux", `TV_IN_aux, `TV_IN_OFFSET_aux_r,
            mem_blk_pages_aux.phase_fread_bytes, mem_blk_pages_aux.phase_payload_bytes,
            mem_blk_pages_aux.phase_elements, mem_blk_pages_aux.phase_transactions,
            mem_blk_pages_aux.phase_header_reads, mem_blk_pages_aux.phase_trailer_reads,
            mem_blk_pages_aux.phase_first_header_value,
            mem_blk_pages_aux.phase_last_header_value,
            mem_blk_pages_aux.phase_trailer_value,
            mem_blk_pages_aux.phase_offset_fread_bytes, mem_blk_pages_aux.phase_offset_elements,
            mem_blk_pages_aux.phase_offset_transactions, mem_blk_pages_aux.phase_copy_elements,
            mem_blk_pages_aux.phase_pages_created, mem_blk_pages_aux.whole_page_size,
            mem_blk_pages_aux.maxi_bundlevar_offset["aux_r"]);
        fpath.delete();

        phase_probe_stage("memory_before_qkv0", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_qkv0);
        mem_blk_pages_qkv0 = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_qkv0");
        mem_blk_pages_qkv0.whole_page_size=10240080;
        mem_blk_pages_qkv0.maxi_bundlevar_fpath["qkv0_r"]=`TV_IN_OFFSET_qkv0_r;
        mem_blk_pages_qkv0.set_binary(1);
        mem_blk_pages_qkv0.tvinload_pagechk_atinit(fpath, 10240064*((8+7)/8), 0, 0);
        phase_probe_memory("qkv0", `TV_IN_qkv0, `TV_IN_OFFSET_qkv0_r,
            mem_blk_pages_qkv0.phase_fread_bytes, mem_blk_pages_qkv0.phase_payload_bytes,
            mem_blk_pages_qkv0.phase_elements, mem_blk_pages_qkv0.phase_transactions,
            mem_blk_pages_qkv0.phase_header_reads, mem_blk_pages_qkv0.phase_trailer_reads,
            mem_blk_pages_qkv0.phase_first_header_value,
            mem_blk_pages_qkv0.phase_last_header_value,
            mem_blk_pages_qkv0.phase_trailer_value,
            mem_blk_pages_qkv0.phase_offset_fread_bytes, mem_blk_pages_qkv0.phase_offset_elements,
            mem_blk_pages_qkv0.phase_offset_transactions, mem_blk_pages_qkv0.phase_copy_elements,
            mem_blk_pages_qkv0.phase_pages_created, mem_blk_pages_qkv0.whole_page_size,
            mem_blk_pages_qkv0.maxi_bundlevar_offset["qkv0_r"]);
        mem_blk_pages_qkv0.tvoutdump_atinit(`TV_OUT_qkv0);
        phase_probe_stage("output_dump_qkv0_ready", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.delete();

        phase_probe_stage("memory_before_qkv1", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_qkv1);
        mem_blk_pages_qkv1 = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_qkv1");
        mem_blk_pages_qkv1.whole_page_size=10240080;
        mem_blk_pages_qkv1.maxi_bundlevar_fpath["qkv1_r"]=`TV_IN_OFFSET_qkv1_r;
        mem_blk_pages_qkv1.set_binary(1);
        mem_blk_pages_qkv1.tvinload_pagechk_atinit(fpath, 10240064*((8+7)/8), 0, 0);
        phase_probe_memory("qkv1", `TV_IN_qkv1, `TV_IN_OFFSET_qkv1_r,
            mem_blk_pages_qkv1.phase_fread_bytes, mem_blk_pages_qkv1.phase_payload_bytes,
            mem_blk_pages_qkv1.phase_elements, mem_blk_pages_qkv1.phase_transactions,
            mem_blk_pages_qkv1.phase_header_reads, mem_blk_pages_qkv1.phase_trailer_reads,
            mem_blk_pages_qkv1.phase_first_header_value,
            mem_blk_pages_qkv1.phase_last_header_value,
            mem_blk_pages_qkv1.phase_trailer_value,
            mem_blk_pages_qkv1.phase_offset_fread_bytes, mem_blk_pages_qkv1.phase_offset_elements,
            mem_blk_pages_qkv1.phase_offset_transactions, mem_blk_pages_qkv1.phase_copy_elements,
            mem_blk_pages_qkv1.phase_pages_created, mem_blk_pages_qkv1.whole_page_size,
            mem_blk_pages_qkv1.maxi_bundlevar_offset["qkv1_r"]);
        mem_blk_pages_qkv1.tvoutdump_atinit(`TV_OUT_qkv1);
        phase_probe_stage("output_dump_qkv1_ready", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.delete();

        phase_probe_stage("memory_before_att_out", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_att_out);
        mem_blk_pages_att_out = mem_model_pages_with_diffofst#(8,8)::type_id::create("mem_blk_pages_att_out");
        mem_blk_pages_att_out.whole_page_size=4116;
        mem_blk_pages_att_out.maxi_bundlevar_fpath["att_out_r"]=`TV_IN_OFFSET_att_out_r;
        mem_blk_pages_att_out.set_binary(1);
        mem_blk_pages_att_out.tvinload_pagechk_atinit(fpath, 4100*((8+7)/8), 0, 0);
        phase_probe_memory("att_out", `TV_IN_att_out, `TV_IN_OFFSET_att_out_r,
            mem_blk_pages_att_out.phase_fread_bytes, mem_blk_pages_att_out.phase_payload_bytes,
            mem_blk_pages_att_out.phase_elements, mem_blk_pages_att_out.phase_transactions,
            mem_blk_pages_att_out.phase_header_reads, mem_blk_pages_att_out.phase_trailer_reads,
            mem_blk_pages_att_out.phase_first_header_value,
            mem_blk_pages_att_out.phase_last_header_value,
            mem_blk_pages_att_out.phase_trailer_value,
            mem_blk_pages_att_out.phase_offset_fread_bytes, mem_blk_pages_att_out.phase_offset_elements,
            mem_blk_pages_att_out.phase_offset_transactions, mem_blk_pages_att_out.phase_copy_elements,
            mem_blk_pages_att_out.phase_pages_created, mem_blk_pages_att_out.whole_page_size,
            mem_blk_pages_att_out.maxi_bundlevar_offset["att_out_r"]);
        mem_blk_pages_att_out.tvoutdump_atinit(`TV_OUT_att_out);
        phase_probe_stage("output_dump_att_out_ready", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.delete();

        phase_probe_stage("memory_before_observed", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.push_back(`TV_IN_observed);
        mem_blk_pages_observed = mem_model_pages_with_diffofst#(32,8)::type_id::create("mem_blk_pages_observed");
        mem_blk_pages_observed.whole_page_size=1088;
        mem_blk_pages_observed.maxi_bundlevar_fpath["observed_r"]=`TV_IN_OFFSET_observed_r;
        mem_blk_pages_observed.set_binary(1);
        mem_blk_pages_observed.tvinload_pagechk_atinit(fpath, 256*((32+7)/8), 0, 0);
        phase_probe_memory("observed", `TV_IN_observed, `TV_IN_OFFSET_observed_r,
            mem_blk_pages_observed.phase_fread_bytes, mem_blk_pages_observed.phase_payload_bytes,
            mem_blk_pages_observed.phase_elements, mem_blk_pages_observed.phase_transactions,
            mem_blk_pages_observed.phase_header_reads, mem_blk_pages_observed.phase_trailer_reads,
            mem_blk_pages_observed.phase_first_header_value,
            mem_blk_pages_observed.phase_last_header_value,
            mem_blk_pages_observed.phase_trailer_value,
            mem_blk_pages_observed.phase_offset_fread_bytes, mem_blk_pages_observed.phase_offset_elements,
            mem_blk_pages_observed.phase_offset_transactions, mem_blk_pages_observed.phase_copy_elements,
            mem_blk_pages_observed.phase_pages_created, mem_blk_pages_observed.whole_page_size,
            mem_blk_pages_observed.maxi_bundlevar_offset["observed_r"]);
        mem_blk_pages_observed.tvoutdump_atinit(`TV_OUT_observed);
        phase_probe_stage("output_dump_observed_ready", longint'($realtime * 1000.0), -1, 0, 0);
        fpath.delete();
        phase_probe_stage("memory_ready", longint'($realtime * 1000.0), -1, 21304580, 7);

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
