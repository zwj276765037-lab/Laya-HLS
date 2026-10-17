if {[llength $argv] != 1} {
    error "usage: run_arithmetic_pipeline.tcl FRESH_EXISTING_WORK_DIR"
}
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing arithmetic work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_arithmetic_sim [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
set sources [list \
    [file join $module rtl tm1tn8_integer_tree.sv] \
    [file join $module rtl tm1tn8_fp_restore.sv] \
    [file join $module rtl tm1tn8_reserved_store.sv] \
    [file join $module rtl tm1tn8_arithmetic_pipeline.sv]]
add_files -norecurse -fileset sources_1 $sources
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm1tn8_arithmetic_pipeline_tb.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top tm1tn8_arithmetic_pipeline [get_filesets sources_1]
set_property top tm1tn8_arithmetic_pipeline_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM1TN8_ARITHMETIC_SIM_BEGIN project=[current_project]"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_arithmetic_sim.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "arithmetic simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_ARITHMETIC_PIPELINE_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "arithmetic simulation did not pass; see $simlog"
}
puts "TM1TN8_ARITHMETIC_SIM_END"
close_project
