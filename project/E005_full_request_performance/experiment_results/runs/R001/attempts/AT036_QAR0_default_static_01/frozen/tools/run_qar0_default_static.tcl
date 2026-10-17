if {[llength $argv]!=10} {error "usage: WORK FROZEN G_FIXTURE A_FIXTURE W_FIXTURE STREAMS WI_A WI_W WI_STREAMS SOURCE_HEX"}
lassign $argv work frozen gfixture afixture wfixture streams wi_a wi_w wi_streams source_hex
set_param general.maxThreads 4
create_project wigqd0_chain_tb_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set base [file join $frozen vivado module_design]
set down [file join $base q8_linear_and_restore tm1tn8_gs32_512]
foreach f {tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2} {
  add_files -norecurse [file join $down rtl ${f}.sv]
}
set q [file join $base activation_quantizer]
add_files -norecurse [file join $base q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_writer_ledger_v1 geglu_gate_quant_bridge_v1} {
  add_files -norecurse [file join $q rtl ${f}.sv]
}
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
  add_files -norecurse [file join $base vector_and_ffn rtl ${f}.sv]
}
add_files -norecurse [lsort [glob [file join $frozen canonical_rtl *.v]]]
set cache [file join $base hbm_loader_and_cache]
foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {
  add_files -norecurse [file join $cache rtl ${f}.sv]
}
add_files -norecurse [file join $down rtl laya_wi_axi_reader_v1.sv]
add_files -fileset sim_1 [file join $down tb wigqd0_chain_tb_v1.sv]
source [file join $down tb create_fp_ip.tcl]
source [file join $frozen ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $frozen ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top geglu_gate_quant_bridge_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg GFIXTURE=$gfixture -testplusarg AFIXTURE=$afixture -testplusarg WFIXTURE=$wfixture -testplusarg STREAMS=$streams -testplusarg WI_AFIXTURE=$wi_a -testplusarg WI_WFIXTURE=$wi_w -testplusarg WI_STREAMS=$wi_streams -testplusarg SOURCE_HEX=$source_hex" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts QAR0_DEFAULT_STATIC_PASS
close_project
