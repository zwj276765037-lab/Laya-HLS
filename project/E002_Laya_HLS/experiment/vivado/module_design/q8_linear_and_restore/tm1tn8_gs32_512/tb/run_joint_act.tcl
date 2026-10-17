if {[llength $argv] != 2} {
    error "usage: run_joint_act.tcl FRESH_WORK ACT_VECTORS"
}
lassign $argv work vectors
set work [file normalize $work]
set vectors [file normalize $vectors]
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $vectors manifest.json]]} {
    error "fresh work and materialized ACT vectors required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_joint_act [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl tm1tn8_integer_tree.sv] \
    [file join $module rtl tm1tn8_fp_restore.sv] \
    [file join $module rtl tm1tn8_reserved_store.sv] \
    [file join $module rtl tm1tn8_arithmetic_pipeline.sv] \
    [file join $module rtl tm1tn8_ps_controller.sv] \
    [file join $module rtl tm1tn8_bias_output.sv] \
    [file join $module rtl tm1tn8_axi512_writer.sv] \
    [file join $module rtl tm1tn8_writer_bridge.sv] \
    [file join $module rtl tm1tn8_trace_axi32_writer.sv] \
    [file join $module rtl tm1tn8_joint_bridge.sv]]
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm1tn8_joint_act_tb.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top tm1tn8_joint_bridge [get_filesets sources_1]
set_property top tm1tn8_joint_act_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg VEC_DIR=$vectors" -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM1TN8_JOINT_ACT_SIM_BEGIN"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_joint_act.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "joint ACT simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_JOINT_ACT_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "joint ACT simulation did not pass; see $simlog"
}
puts "TM1TN8_JOINT_ACT_SIM_END"
close_project
