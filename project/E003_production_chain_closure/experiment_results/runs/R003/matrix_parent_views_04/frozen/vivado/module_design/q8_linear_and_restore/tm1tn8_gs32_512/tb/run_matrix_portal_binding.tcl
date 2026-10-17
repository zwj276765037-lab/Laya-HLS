if {[llength $argv]!=3} {error "usage: WORK FROZEN {static|pilot}"}
lassign $argv work frozen mode
set_param general.maxThreads 4
if {$mode eq "static"} {
  create_project matrix_portal_binding [file join $work vivado] -part xcu55c-fsvh2892-2L-e
  set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
  foreach f {laya_compute_portal_layout_v1 tm4tn8_bias_bits_v1 tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2 tm4tn8_final_ps_adapter_v1 tm4tn8_bias_output_v1 tm4tn8_axi512_writer_v1 tm4tn8_matrix_owner_ledger_v2 tm4tn8_matrix_resident_v2 laya_parent_a_lease_v2 laya_parent_w_lease_v2 laya_matrix_portal_binding_v1} {
    add_files -norecurse [file join $module rtl ${f}.sv]
  }
  add_files -fileset sim_1 [file join $module tb laya_matrix_portal_binding_tb_v1.sv]
  source [file join $module tb create_fp_ip.tcl]
  set_property top laya_matrix_portal_binding_v1 [get_filesets sources_1]
  set_property top laya_matrix_portal_binding_tb_v1 [get_filesets sim_1]
  set_property xsim.simulate.runtime all [get_filesets sim_1]
  launch_simulation -mode behavioral -step compile
  launch_simulation -mode behavioral -step elaborate
  puts FULL_CURRENT_MATRIX_BINDING_STATIC_PASS
} elseif {$mode eq "pilot"} {
  open_project [file join $work vivado matrix_portal_binding.xpr]
  launch_simulation -mode behavioral -step simulate
  close_sim
  set log [file join $work vivado matrix_portal_binding.sim sim_1 behav xsim simulate.log]
  set f [open $log r];set content [read $f];close $f
  if {[string first FULL_CURRENT_MATRIX_BINDING_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {error "matrix binding test failed: $log"}
  puts FULL_CURRENT_MATRIX_BINDING_SCRIPT_PASS
} else {error "bad mode"}
close_project
