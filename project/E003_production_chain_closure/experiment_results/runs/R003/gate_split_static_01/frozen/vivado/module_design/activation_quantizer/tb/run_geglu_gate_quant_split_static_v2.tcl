if {[llength $argv]!=2} {error "usage: WORK FROZEN"}
lassign $argv work root
set_param general.maxThreads 4
create_project gate_quant_split [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set q [file join $root vivado module_design activation_quantizer]
add_files -norecurse [file join $root vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2} {
  add_files -norecurse [file join $q rtl ${f}.sv]
}
add_files -norecurse [lsort [glob [file join $root external canonical_rtl *.v]]]
set vector [file join $root vivado module_design vector_and_ffn rtl]
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
  add_files -norecurse [file join $vector ${f}.sv]
}
add_files -fileset sim_1 [file join $q tb geglu_gate_quant_split_static_tb_v2.sv]
source [file join $root external quant_ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $root external quant_ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top geglu_gate_quant_split_v2 [get_filesets sources_1]
set_property top geglu_gate_quant_split_static_tb_v2 [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_GATE_QUANT_SPLIT_STATIC_PASS
close_project
