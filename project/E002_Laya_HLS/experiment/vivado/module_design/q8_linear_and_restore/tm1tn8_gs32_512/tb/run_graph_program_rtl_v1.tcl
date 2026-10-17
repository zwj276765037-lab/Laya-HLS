if {[llength $argv]!=3} {error "usage WORK FROZEN FIXTURE"}
lassign $argv work frozen fixture
set_param general.maxThreads 4
create_project graph_program_rtl [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external program_rtl *.v]]]
foreach name {laya_private_fifo2_v1.sv laya_control_consumption_gate_v1.sv laya_graph_program_shell_v1.sv} {
  add_files -norecurse [file join $module rtl $name]
}
add_files -fileset sim_1 [file join $module tb laya_graph_program_tb_v1.sv]
set_property top laya_graph_program_shell_v1 [get_filesets sources_1]
set_property top laya_graph_program_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_GRAPH_PROGRAM_RTL_STATIC_PASS
close_project
