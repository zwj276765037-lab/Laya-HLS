if {[llength $argv]!=17} {
  error "usage: MODE WORK DOWN_FROZEN LN_FROZEN NEW_FROZEN FFN_FROZEN FADD_LEAF G_FIXTURE A_FIXTURE W_FIXTURE STREAMS WI_A WI_W WI_STREAMS LN_FIXTURE BOUND_FIXTURE FFN_FIXTURE"
}
lassign $argv mode work down_frozen ln_frozen new_frozen ffn_frozen fadd_leaf gfixture afixture wfixture streams wi_a wi_w wi_streams ln_fixture bound_fixture ffn_fixture
if {$mode ni {static pilot full}} {error "bad mode"}
set_param general.maxThreads 4
create_project ffn0_chain_tb_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set base [file join $down_frozen vivado module_design]
set down [file join $base q8_linear_and_restore tm1tn8_gs32_512]
foreach f {tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2 laya_wi_axi_reader_v1} {
  add_files -norecurse [file join $down rtl ${f}.sv]
}
set q [file join $base activation_quantizer]
add_files -norecurse [file join $base q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_writer_ledger_v1} {
  add_files -norecurse [file join $q rtl ${f}.sv]
}
add_files -norecurse [file join $new_frozen geglu_gate_quant_bridge_v1.sv]
foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
  add_files -norecurse [file join $base vector_and_ffn rtl ${f}.sv]
}
add_files -norecurse [lsort [glob [file join $down_frozen canonical_rtl *.v]]]
set cache [file join $base hbm_loader_and_cache]
foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {
  add_files -norecurse [file join $cache rtl ${f}.sv]
}
set ln_module [file join $ln_frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach f {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_layernorm_producer_portal_shell_v1} {
  add_files -norecurse [file join $ln_module rtl ${f}.sv]
}
set ln_engine [file join $ln_frozen external layernorm_producer_rtl]
add_files -norecurse [lsort [glob [file join $ln_engine *.v]]]
foreach script [lsort [glob [file join $ln_engine *_ip.tcl]]] {source $script}
foreach f {laya_lnq0_bound_identity_generated_v1 laya_lnq0_external_quant_admission_v1 laya_lnq0_w_binding_v1} {
  add_files -norecurse [file join $new_frozen ${f}.sv]
}
foreach f {laya_ffn0_source_stage_v1 ffn0_chain_tb_v1} {
  add_files -fileset sim_1 [file join $new_frozen ${f}.sv]
}
add_files -norecurse $fadd_leaf
foreach f {laya_ffn_fadd_slot_v1 laya_ffn0_residual_four_row_v1 laya_ffn0_down_residual_admission_v1} {
  add_files -norecurse [file join $ffn_frozen ${f}.sv]
}
source [file join $down tb create_fp_ip.tcl]
source [file join $down_frozen ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $down_frozen ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top ffn0_chain_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set plusargs "-testplusarg GFIXTURE=$gfixture -testplusarg AFIXTURE=$afixture -testplusarg WFIXTURE=$wfixture -testplusarg STREAMS=$streams -testplusarg WI_AFIXTURE=$wi_a -testplusarg WI_WFIXTURE=$wi_w -testplusarg WI_STREAMS=$wi_streams -testplusarg LN_FIXTURE=$ln_fixture -testplusarg FIXTURE=$ln_fixture -testplusarg BOUND_FIXTURE=$bound_fixture -testplusarg FFN_FIXTURE=$ffn_fixture"
if {$mode eq "pilot"} {append plusargs " -testplusarg PREFIX=1"}
set_property -name xsim.simulate.xsim.more_options -value $plusargs -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
source [file join [file dirname [info script]] stage_ln_roms_v1.tcl]
stage_ln_roms_v1 $ln_engine [file join $work vivado ffn0_chain_tb_v1.sim sim_1 behav xsim]
set runtime_cwd [file join $work vivado ffn0_chain_tb_v1.sim sim_1 behav xsim]
set preflight_cmd [list python3 [file join $new_frozen verify_ffn0_runtime_v1.py] \
  --manifest [file join [file dirname $new_frozen] source_manifest.json] \
  --cwd $runtime_cwd --out [file join $work runtime_preflight.json]]
foreach {key value} [list GFIXTURE $gfixture AFIXTURE $afixture \
  WFIXTURE $wfixture STREAMS $streams WI_AFIXTURE $wi_a \
  WI_WFIXTURE $wi_w WI_STREAMS $wi_streams LN_FIXTURE $ln_fixture \
  BOUND_FIXTURE $bound_fixture FFN_FIXTURE $ffn_fixture] {
  lappend preflight_cmd --root $key $value
}
exec {*}$preflight_cmd
puts FFN0_STATIC_PASS
if {$mode ne "static"} {
  launch_simulation -mode behavioral -step simulate
  puts FFN0_SIM_FINISHED
}
close_project
