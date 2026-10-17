set root [file normalize [file join [file dirname [info script]] ../../../../..]]
set out [lindex $argv 0]
set_param general.maxThreads 4
create_project control_start_gate [file join $out vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl laya_control_start_gate_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_control_start_gate_tb_v1.sv]
set_property top laya_control_start_gate_v1 [get_filesets sources_1]
set_property top laya_control_start_gate_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $out vivado control_start_gate.sim sim_1 behav xsim simulate.log]
set f [open $log r];set body [read $f];close $f
if {[string first FULL_CURRENT_CONTROL_START_GATE_PASS $body]<0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "control start gate assertion failed: $log"
}
puts FULL_CURRENT_CONTROL_START_GATE_SCRIPT_PASS
close_project
