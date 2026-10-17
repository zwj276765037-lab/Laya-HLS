if {[llength $argv]!=7} {error "usage: WORK FROZEN {static|pilot|full} G_FIXTURE A_FIXTURE W_FIXTURE STREAMS"}
lassign $argv work frozen mode gfixture afixture wfixture streams
set_param general.maxThreads 4
set matrix [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
if {$mode eq "static"} {
  create_project gate_quant_matrix_parent_v2 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
  add_files -norecurse [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
  foreach f {laya_compute_portal_layout_v1 tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2 laya_parent_a_lease_v2 laya_parent_w_lease_v2 laya_matrix_portal_binding_v1} {
    add_files -norecurse [file join $matrix rtl ${f}.sv]
  }
  set q [file join $frozen vivado module_design activation_quantizer]
  foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row quant_a_row_bank_v1 quant_dual_a_v1 quant_f32_row_bank_v1 quant_f32_two_row_feeder_v1 quant_task_to_dual_a_v1 geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2 geglu_gate_quant_split_v2} {
    add_files -norecurse [file join $q rtl ${f}.sv]
  }
  add_files -norecurse [lsort [glob [file join $frozen external canonical_rtl *.v]]]
  set vector [file join $frozen vivado module_design vector_and_ffn rtl]
  foreach f {tanh_libm_canonical geglu_canonical_core geglu_row_bank_v1 geglu_canonical_row_adapter} {
    add_files -norecurse [file join $vector ${f}.sv]
  }
  set c [file join $frozen vivado module_design hbm_loader_and_cache]
  foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {
    add_files -norecurse [file join $c rtl ${f}.sv]
  }
  add_files -fileset sim_1 [file join $matrix tb laya_gate_quant_matrix_parent_tb_v2.sv]
  source [file join $frozen external quant_ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
  source [file join $frozen external quant_ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
  source [file join $matrix tb create_fp_ip.tcl]
  set_property top laya_matrix_portal_binding_v1 [get_filesets sources_1]
  set_property top laya_gate_quant_matrix_parent_tb_v2 [get_filesets sim_1]
  set_property xsim.simulate.runtime all [get_filesets sim_1]
  set_property -name xsim.simulate.xsim.more_options -value "-testplusarg GFIXTURE=$gfixture -testplusarg AFIXTURE=$afixture -testplusarg WFIXTURE=$wfixture -testplusarg STREAMS=$streams" -objects [get_filesets sim_1]
  launch_simulation -mode behavioral -step compile
  launch_simulation -mode behavioral -step elaborate
  puts L0_GATE_QUANT_MATRIX_PARENT_STATIC_PASS
} elseif {$mode eq "pilot" || $mode eq "full"} {
  open_project [file join $work vivado gate_quant_matrix_parent_v2.xpr]
  set options [get_property xsim.simulate.xsim.more_options [get_filesets sim_1]]
  regsub -all { -testplusarg PILOT} $options {} options
  if {$mode eq "pilot"} {append options " -testplusarg PILOT"}
  set_property -name xsim.simulate.xsim.more_options -value $options -objects [get_filesets sim_1]
  launch_simulation -mode behavioral -step simulate
  close_sim
  set log [file join $work vivado gate_quant_matrix_parent_v2.sim sim_1 behav xsim simulate.log]
  set f [open $log r];set content [read $f];close $f
  set marker [expr {$mode eq "pilot" ? "L0_GATE_QUANT_MATRIX_PARENT_PILOT_PASS" : "L0_GATE_QUANT_MATRIX_PARENT_FULL_PASS"}]
  if {[string first $marker $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
    error "gate/quant/matrix parent $mode failed: $log"
  }
  puts L0_GATE_QUANT_MATRIX_PARENT_SCRIPT_PASS
} else {error "bad mode"}
close_project
