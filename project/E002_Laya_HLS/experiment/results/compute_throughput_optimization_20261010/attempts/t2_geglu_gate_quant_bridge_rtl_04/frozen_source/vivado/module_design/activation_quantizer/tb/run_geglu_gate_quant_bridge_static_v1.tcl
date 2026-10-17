if {[llength $argv]!=5} {error "usage: static WORK FROZEN CANONICAL_RTL FROZEN_IP FIXTURE"}
lassign $argv work frozen canonical iproot fixture
set_param general.maxThreads 4
create_project gate_quant_bridge [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set q [file join $frozen vivado module_design activation_quantizer]
add_files -norecurse [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_writer_ledger_v1 geglu_gate_quant_bridge_v1} {add_files -norecurse [file join $q rtl ${f}.sv]}
add_files -norecurse [lsort [glob [file join $canonical *.v]]]
set vector [file join $frozen vivado module_design vector_and_ffn rtl]
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {add_files -norecurse [file join $vector ${f}.sv]}
add_files -fileset sim_1 [file join $q tb geglu_gate_quant_bridge_tb_v1.sv]
set ipdir [file join $iproot results compute_throughput_optimization_20261010 attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
source [file join $ipdir laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $ipdir laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top geglu_gate_quant_bridge_v1 [get_filesets sources_1]
set_property top geglu_gate_quant_bridge_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts GEGLU_GATE_QUANT_BRIDGE_STATIC_PASS
close_project
