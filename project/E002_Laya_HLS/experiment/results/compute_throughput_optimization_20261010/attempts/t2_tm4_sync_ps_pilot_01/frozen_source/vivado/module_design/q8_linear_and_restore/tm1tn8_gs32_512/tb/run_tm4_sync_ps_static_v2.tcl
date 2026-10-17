if {[llength $argv]!=2} {error "usage: WORK FROZEN_MODULE"}
lassign $argv work module
set_param general.maxThreads 4
create_project tm4_sync_ps_v2 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
foreach f {tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_sync_bank_v2 tm4tn8_sync_ps_front_v2} {
  add_files -norecurse [file join $module rtl ${f}.sv]
}
foreach f {tm4tn8_sync_banks_tb_v2 tm4tn8_sync_ps_pilot_tb_v2} {
  add_files -fileset sim_1 [file join $module tb ${f}.sv]
}
source [file join $module tb create_fp_ip.tcl]
set_property top tm4tn8_sync_ps_front_v2 [get_filesets sources_1]
set_property top tm4tn8_sync_ps_pilot_tb_v2 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts TM4_SYNC_PS_STATIC_PASS
close_project
