if {[llength $argv]!=3} {error "usage WORK FROZEN FIXTURE"}
lassign $argv work frozen fixture
set_param general.maxThreads 4
create_project controller_adapter_rtl [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external adapter_rtl *.v]]]
add_files -norecurse [file join $module rtl laya_private_fifo2_v1.sv]
add_files -norecurse [file join $module rtl laya_controller_transaction_adapter_shell_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_controller_transaction_adapter_tb_v1.sv]
set_property top laya_command_provenance_adapter [get_filesets sources_1]
set_property top laya_controller_transaction_adapter_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_CONTROLLER_ADAPTER_RTL_STATIC_PASS
close_project
