if {[llength $argv] != 2} {error "usage: EXISTING_XPR FROZEN"}
lassign $argv project frozen
open_project $project
set_param general.maxThreads 4
set_property top laya_lnq_wi_row_v1 [get_filesets sources_1]
set_property top laya_lnq_wi_row_v1 [get_filesets sim_1]
set_property target_simulator XSim [current_project]
update_compile_order -fileset sim_1
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts LNQ_WI_STATIC_ELAB_PASS
close_sim
close_project
