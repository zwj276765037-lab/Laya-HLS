if {[llength $argv]!=4} {error "usage WORK FROZEN {static|pilot} FIXTURE"}
lassign $argv work frozen mode fixture
set_param general.maxThreads 4
set matrix [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
set q [file join $frozen vivado module_design activation_quantizer]
set vector [file join $frozen vivado module_design vector_and_ffn rtl]
if {$mode eq "static"} {
  create_project gate_quant_source_switch_marker [file join $work vivado] -part xcu55c-fsvh2892-2L-e
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
  add_files -fileset sim_1 [file join $matrix tb laya_gate_quant_source_switch_marker_tb_v1.sv]
  source [file join $frozen external quant_ip laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
  source [file join $frozen external quant_ip laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
  set_property top laya_gate_quant_portal_binding_v1 [get_filesets sources_1]
  set_property top laya_gate_quant_source_switch_marker_tb_v1 [get_filesets sim_1]
  set_property xsim.simulate.runtime all [get_filesets sim_1]
  launch_simulation -mode behavioral -step compile
  launch_simulation -mode behavioral -step elaborate
  puts FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_MARKER_RUNTIME_STATIC_PASS
} elseif {$mode eq "pilot"} {
  open_project [file join $work vivado gate_quant_source_switch_marker.xpr]
  set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
  launch_simulation -mode behavioral -step simulate
  close_sim
  set log [file join $work vivado gate_quant_source_switch_marker.sim sim_1 behav xsim simulate.log]
  set f [open $log r];set body [read $f];close $f
  if {[string first FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_MARKER_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
    error "G/Q source switch MARKER pilot failed: $log"
  }
  puts FULL_CURRENT_GATE_QUANT_SOURCE_SWITCH_RUNTIME_SCRIPT_PASS
} else {error "bad mode"}
close_project
