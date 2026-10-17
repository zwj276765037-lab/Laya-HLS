if {[llength $argv]!=3} {error "usage WORK FROZEN FIXTURE"}
lassign $argv work frozen fixture
set_param general.maxThreads 4
create_project layernorm_ffn_quant_source [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_layernorm_producer_portal_shell_v1 laya_gate_quant_portal_decode_v1 laya_wi_axi_reader_v1 laya_gate_quant_portal_binding_v1 laya_layernorm_quant_source_shell_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
set q [file join $frozen vivado module_design activation_quantizer]
set vector [file join $frozen vivado module_design vector_and_ffn rtl]
add_files -norecurse [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2} {
  add_files -norecurse [file join $q rtl ${f}.sv]
}
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
  add_files -norecurse [file join $vector ${f}.sv]
}
add_files -norecurse [lsort [glob [file join $frozen external canonical_rtl *.v]]]
set engine [file join $frozen external layernorm_producer_rtl]
add_files -norecurse [lsort [glob [file join $engine *.v]]]
foreach script [lsort [glob [file join $engine *_ip.tcl]]] {source $script}
add_files -fileset sim_1 [file join $module tb laya_layernorm_ffn_quant_source_tb_v1.sv]
source [file join $frozen external quant_ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $frozen external quant_ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top laya_layernorm_quant_source_shell_v1 [get_filesets sources_1]
set_property top laya_layernorm_ffn_quant_source_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_LAYERNORM_QUANT_SOURCE_STATIC_PASS
close_project
