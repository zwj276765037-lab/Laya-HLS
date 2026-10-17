if {[llength $argv] != 4} {error "usage: COPIED_XPR OLD_TB PILOT_TB BANK_TB"}
lassign $argv project old_tb pilot_tb bank_tb
set_param general.maxThreads 4
open_project $project
remove_files [get_files -quiet $old_tb]
foreach existing_tb [get_files -quiet *laya_lnq_wi_row_v1_tb.sv] {
  remove_files $existing_tb
}
add_files -fileset sim_1 $pilot_tb
add_files -fileset sim_1 $bank_tb
set_property top tm4tn8_sync_ps_pilot_tb_v2 [get_filesets sim_1]
set_property target_simulator XSim [current_project]
update_compile_order -fileset sim_1
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts TM4_ABORT_EDGES_ELAB_PASS
close_project
