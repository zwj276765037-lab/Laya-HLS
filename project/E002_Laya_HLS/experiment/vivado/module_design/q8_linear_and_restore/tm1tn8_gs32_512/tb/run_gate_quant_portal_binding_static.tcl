if {[llength $argv]!=2} {error "usage WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project gate_quant_binding [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set matrix [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
set q [file join $frozen vivado module_design activation_quantizer]
set vector [file join $frozen vivado module_design vector_and_ffn rtl]
add_files -norecurse [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {laya_compute_portal_layout_v1 laya_gate_quant_portal_decode_v1 laya_wi_axi_reader_v1 laya_gate_quant_portal_binding_v1} {
  add_files -norecurse [file join $matrix rtl ${f}.sv]
}
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2} {
  add_files -norecurse [file join $q rtl ${f}.sv]
}
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
  add_files -norecurse [file join $vector ${f}.sv]
}
add_files -norecurse [lsort [glob [file join $frozen external canonical_rtl *.v]]]
source [file join $frozen external quant_ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $frozen external quant_ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
synth_design -rtl -top laya_gate_quant_portal_binding_v1 -part xcu55c-fsvh2892-2L-e
puts FULL_CURRENT_GATE_QUANT_PORTAL_BINDING_STATIC_PASS
close_project
