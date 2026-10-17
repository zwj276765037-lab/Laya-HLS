if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_control_transport [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_executor_handoff_layout_v1 laya_private_fifo2_v1 laya_executor_handoff_shell_v1 laya_executor_control_transport_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_control_transport_tb_v1.sv]
set_property top laya_executor_control_transport_v1 [get_filesets sources_1]
set_property top laya_executor_control_transport_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [open [file join $work vivado executor_control_transport.sim sim_1 behav xsim simulate.log] r]
set content [read $log];close $log
if {[string first FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_RTL_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "finite executor control transport assertions failed"
}
puts FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_SCRIPT_PASS
close_project
