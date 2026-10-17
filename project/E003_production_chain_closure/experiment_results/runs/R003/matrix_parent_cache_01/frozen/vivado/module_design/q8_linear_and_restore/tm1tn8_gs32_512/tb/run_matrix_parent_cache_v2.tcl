if {[llength $argv]!=6} {error "usage: WORK FROZEN {static|pilot|full} A_FIXTURE W_FIXTURE STREAMS"}
lassign $argv work frozen mode afixture wfixture streams
set_param general.maxThreads 4
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
if {$mode eq "static"} {
  create_project matrix_parent_cache_v2 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
  foreach f {laya_compute_portal_layout_v1 tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2 laya_parent_a_lease_v2 laya_parent_w_lease_v2 laya_matrix_portal_binding_v1} {
    add_files -norecurse [file join $module rtl ${f}.sv]
  }
  set q [file join $frozen vivado module_design activation_quantizer]
  foreach f {quant_a_row_bank_v1 quant_dual_a_v1} {add_files -norecurse [file join $q rtl ${f}.sv]}
  set c [file join $frozen vivado module_design hbm_loader_and_cache]
  foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {add_files -norecurse [file join $c rtl ${f}.sv]}
  add_files -fileset sim_1 [file join $module tb laya_matrix_parent_cache_tb_v2.sv]
  source [file join $module tb create_fp_ip.tcl]
  set_property top laya_matrix_portal_binding_v1 [get_filesets sources_1]
  set_property top laya_matrix_parent_cache_tb_v2 [get_filesets sim_1]
  set_property xsim.simulate.runtime all [get_filesets sim_1]
  set_property -name xsim.simulate.xsim.more_options -value "-testplusarg AFIXTURE=$afixture -testplusarg WFIXTURE=$wfixture -testplusarg STREAMS=$streams" -objects [get_filesets sim_1]
  launch_simulation -mode behavioral -step compile
  launch_simulation -mode behavioral -step elaborate
  puts L0_PARENT_CACHE_STATIC_PASS
} elseif {$mode eq "pilot" || $mode eq "full"} {
  open_project [file join $work vivado matrix_parent_cache_v2.xpr]
  set options [get_property xsim.simulate.xsim.more_options [get_filesets sim_1]]
  regsub -all { -testplusarg PILOT} $options {} options
  if {$mode eq "pilot"} {append options " -testplusarg PILOT"}
  set_property -name xsim.simulate.xsim.more_options -value $options -objects [get_filesets sim_1]
  launch_simulation -mode behavioral -step simulate
  close_sim
  set log [file join $work vivado matrix_parent_cache_v2.sim sim_1 behav xsim simulate.log]
  set f [open $log r];set content [read $f];close $f
  set marker [expr {$mode eq "pilot" ? "L0_PARENT_CACHE_PILOT_PASS" : "L0_PARENT_CACHE_FULL_PASS"}]
  if {[string first $marker $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {error "matrix parent-cache $mode failed: $log"}
  puts L0_PARENT_CACHE_SCRIPT_PASS
} else {error "bad mode"}
close_project
