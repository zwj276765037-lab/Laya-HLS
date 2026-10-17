if {[llength $argv] != 1} { error "usage: run_rank_state.tcl FRESH_WORK" }
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh rank-state work required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_rank_state [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sim_1 [list \
    [file join $module rtl tm1tn8_ps_controller.sv] \
    [file join $module rtl tm1tn8_bias_output.sv] \
    [file join $module rtl tm1tn8_axi512_writer.sv] \
    [file join $module rtl tm1tn8_writer_bridge.sv] \
    [file join $module rtl tm1tn8_trace_axi32_writer.sv] \
    [file join $module rtl tm1tn8_joint_bridge.sv] \
    [file join $module tb tm1tn8_rank_state_tb.sv]]
set_property top tm1tn8_rank_state_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM1TN8_RANK_STATE_BEGIN"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_rank_state.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "rank-state simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_RANK_STATE_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "rank-state simulation did not pass; see $simlog"
}
puts "TM1TN8_RANK_STATE_END"
close_project
