if {[llength $argv] != 3} {error "usage: COPIED_XPR OLD_TB NEW_TB"}
lassign $argv project old_tb new_tb
set_param general.maxThreads 4
open_project $project
remove_files [get_files $old_tb]
add_files -fileset sim_1 $new_tb
set_property top laya_lnq_wi_row_v1_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
update_compile_order -fileset sim_1
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts LNQ_WI_TB_REFRESH_PASS
close_project
