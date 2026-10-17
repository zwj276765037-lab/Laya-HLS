//==============================================================
//Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2025.2 (64-bit)
//Tool Version Limit: 2025.11
//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//
//==============================================================

`ifndef ATTENTION_SLICE_SUBSYSTEM_MONITOR_SV
`define ATTENTION_SLICE_SUBSYSTEM_MONITOR_SV

`uvm_analysis_imp_decl(_axi_wtr_fixture)
`uvm_analysis_imp_decl(_axi_rtr_fixture)
`uvm_analysis_imp_decl(_axi_wtr_io)
`uvm_analysis_imp_decl(_axi_rtr_io)
`uvm_analysis_imp_decl(_axi_wtr_aux)
`uvm_analysis_imp_decl(_axi_rtr_aux)
`uvm_analysis_imp_decl(_axi_wtr_qkv0)
`uvm_analysis_imp_decl(_axi_rtr_qkv0)
`uvm_analysis_imp_decl(_axi_wtr_qkv1)
`uvm_analysis_imp_decl(_axi_rtr_qkv1)
`uvm_analysis_imp_decl(_axi_wtr_att_out)
`uvm_analysis_imp_decl(_axi_rtr_att_out)
`uvm_analysis_imp_decl(_axi_wtr_observed)
`uvm_analysis_imp_decl(_axi_rtr_observed)
`uvm_analysis_imp_decl(_axi_wtr_control_r)
`uvm_analysis_imp_decl(_axi_rtr_control_r)
`uvm_analysis_imp_decl(_axi_wtr_control)
`uvm_analysis_imp_decl(_axi_rtr_control)

class attention_slice_subsystem_monitor extends uvm_component;

    attention_slice_reference_model refm;
    attention_slice_scoreboard scbd;

    `uvm_component_utils_begin(attention_slice_subsystem_monitor)
    `uvm_component_utils_end

    uvm_analysis_imp_axi_wtr_fixture#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) fixture_wtr_imp;
    uvm_analysis_imp_axi_rtr_fixture#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) fixture_rtr_imp;
    uvm_analysis_imp_axi_wtr_io#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) io_wtr_imp;
    uvm_analysis_imp_axi_rtr_io#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) io_rtr_imp;
    uvm_analysis_imp_axi_wtr_aux#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) aux_wtr_imp;
    uvm_analysis_imp_axi_rtr_aux#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) aux_rtr_imp;
    uvm_analysis_imp_axi_wtr_qkv0#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) qkv0_wtr_imp;
    uvm_analysis_imp_axi_rtr_qkv0#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) qkv0_rtr_imp;
    uvm_analysis_imp_axi_wtr_qkv1#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) qkv1_wtr_imp;
    uvm_analysis_imp_axi_rtr_qkv1#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) qkv1_rtr_imp;
    uvm_analysis_imp_axi_wtr_att_out#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) att_out_wtr_imp;
    uvm_analysis_imp_axi_rtr_att_out#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) att_out_rtr_imp;
    uvm_analysis_imp_axi_wtr_observed#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) observed_wtr_imp;
    uvm_analysis_imp_axi_rtr_observed#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) observed_rtr_imp;
    uvm_analysis_imp_axi_wtr_control_r#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) control_r_wtr_imp;
    uvm_analysis_imp_axi_rtr_control_r#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) control_r_rtr_imp;
    uvm_analysis_imp_axi_wtr_control#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) control_wtr_imp;
    uvm_analysis_imp_axi_rtr_control#(axi_pkg::axi_transfer, attention_slice_subsystem_monitor) control_rtr_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(attention_slice_reference_model)::get(this, "", "refm", refm))
            `uvm_fatal(this.get_full_name(), "No refm from high level")
        `uvm_info(this.get_full_name(), "get reference model by uvm_config_db", UVM_MEDIUM)
        scbd = attention_slice_scoreboard::type_id::create("scbd", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function new (string name = "", uvm_component parent = null);
        super.new(name, parent);
        fixture_wtr_imp = new("fixture_wtr_imp", this);
        fixture_rtr_imp = new("fixture_rtr_imp", this);
        io_wtr_imp = new("io_wtr_imp", this);
        io_rtr_imp = new("io_rtr_imp", this);
        aux_wtr_imp = new("aux_wtr_imp", this);
        aux_rtr_imp = new("aux_rtr_imp", this);
        qkv0_wtr_imp = new("qkv0_wtr_imp", this);
        qkv0_rtr_imp = new("qkv0_rtr_imp", this);
        qkv1_wtr_imp = new("qkv1_wtr_imp", this);
        qkv1_rtr_imp = new("qkv1_rtr_imp", this);
        att_out_wtr_imp = new("att_out_wtr_imp", this);
        att_out_rtr_imp = new("att_out_rtr_imp", this);
        observed_wtr_imp = new("observed_wtr_imp", this);
        observed_rtr_imp = new("observed_rtr_imp", this);
        control_r_wtr_imp = new("control_r_wtr_imp", this);
        control_r_rtr_imp = new("control_r_rtr_imp", this);
        control_wtr_imp = new("control_wtr_imp", this);
        control_rtr_imp = new("control_rtr_imp", this);
    endfunction

    virtual function void write_axi_wtr_fixture(axi_transfer tr);
        refm.write_axi_wtr_fixture(tr);
        scbd.write_axi_wtr_fixture(tr);
    endfunction

    virtual function void write_axi_rtr_fixture(axi_transfer tr);
        refm.write_axi_rtr_fixture(tr);
        scbd.write_axi_rtr_fixture(tr);
    endfunction

    virtual function void write_axi_wtr_io(axi_transfer tr);
        refm.write_axi_wtr_io(tr);
        scbd.write_axi_wtr_io(tr);
    endfunction

    virtual function void write_axi_rtr_io(axi_transfer tr);
        refm.write_axi_rtr_io(tr);
        scbd.write_axi_rtr_io(tr);
    endfunction

    virtual function void write_axi_wtr_aux(axi_transfer tr);
        refm.write_axi_wtr_aux(tr);
        scbd.write_axi_wtr_aux(tr);
    endfunction

    virtual function void write_axi_rtr_aux(axi_transfer tr);
        refm.write_axi_rtr_aux(tr);
        scbd.write_axi_rtr_aux(tr);
    endfunction

    virtual function void write_axi_wtr_qkv0(axi_transfer tr);
        refm.write_axi_wtr_qkv0(tr);
        scbd.write_axi_wtr_qkv0(tr);
    endfunction

    virtual function void write_axi_rtr_qkv0(axi_transfer tr);
        refm.write_axi_rtr_qkv0(tr);
        scbd.write_axi_rtr_qkv0(tr);
    endfunction

    virtual function void write_axi_wtr_qkv1(axi_transfer tr);
        refm.write_axi_wtr_qkv1(tr);
        scbd.write_axi_wtr_qkv1(tr);
    endfunction

    virtual function void write_axi_rtr_qkv1(axi_transfer tr);
        refm.write_axi_rtr_qkv1(tr);
        scbd.write_axi_rtr_qkv1(tr);
    endfunction

    virtual function void write_axi_wtr_att_out(axi_transfer tr);
        refm.write_axi_wtr_att_out(tr);
        scbd.write_axi_wtr_att_out(tr);
    endfunction

    virtual function void write_axi_rtr_att_out(axi_transfer tr);
        refm.write_axi_rtr_att_out(tr);
        scbd.write_axi_rtr_att_out(tr);
    endfunction

    virtual function void write_axi_wtr_observed(axi_transfer tr);
        refm.write_axi_wtr_observed(tr);
        scbd.write_axi_wtr_observed(tr);
    endfunction

    virtual function void write_axi_rtr_observed(axi_transfer tr);
        refm.write_axi_rtr_observed(tr);
        scbd.write_axi_rtr_observed(tr);
    endfunction

    virtual function void write_axi_wtr_control_r(axi_transfer tr);
        refm.write_axi_wtr_control_r(tr);
        scbd.write_axi_wtr_control_r(tr);
    endfunction

    virtual function void write_axi_rtr_control_r(axi_transfer tr);
        refm.write_axi_rtr_control_r(tr);
        scbd.write_axi_rtr_control_r(tr);
    endfunction

    virtual function void write_axi_wtr_control(axi_transfer tr);
        refm.write_axi_wtr_control(tr);
        scbd.write_axi_wtr_control(tr);
    endfunction

    virtual function void write_axi_rtr_control(axi_transfer tr);
        refm.write_axi_rtr_control(tr);
        scbd.write_axi_rtr_control(tr);
    endfunction
endclass
`endif
