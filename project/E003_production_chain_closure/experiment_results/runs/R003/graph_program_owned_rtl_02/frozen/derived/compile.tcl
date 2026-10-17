if {[llength $argv]!=2} {error "usage WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project owned_program_rtl [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external program_rtl *.v]]]
add_files -norecurse [file join $module rtl laya_private_fifo2_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_graph_program_owned_tb_v1.sv]
set_property include_dirs [list [file join $frozen derived]] [get_filesets sim_1]
set_property top laya_graph_program_owned_sequencer [get_filesets sources_1]
set_property top laya_graph_program_owned_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_GRAPH_PROGRAM_OWNED_RTL_STATIC_PASS
close_project
