if {[llength $argv]!=2} {error "usage: WORK NEW_FROZEN"}
lassign $argv work new_frozen
set_param general.maxThreads 4
create_project ffn1_observer_micro_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -fileset sim_1 [file join $new_frozen ffn1_progress_observer_v1.sv]
add_files -fileset sim_1 [file join $new_frozen ffn1_progress_observer_micro_tb_v1.sv]
set_property top ffn1_progress_observer_micro_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FFN1_OBSERVER_MICRO_STATIC_PASS
launch_simulation -mode behavioral -step simulate
puts FFN1_OBSERVER_MICRO_SIM_FINISHED
close_project
