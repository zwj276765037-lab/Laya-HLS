if {[llength $argv] != 1} {
    error "usage: run_tm4tn8_pilot_v1.tcl FRESH_WORK"
}
set work [lindex $argv 0]
set work [file normalize $work]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm4tn8_pilot_v1 [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl tm1tn8_integer_tree_lut.sv] \
    [file join $module rtl tm1tn8_signed_pack_pair.sv] \
    [file join $module rtl tm1tn8_integer_tree_packed.sv] \
    [file join $module rtl tm4tn8_tag_v1.sv] \
    [file join $module rtl tm4tn8_reserved_store_v1.sv] \
    [file join $module rtl tm4tn8_fp_restore_v1.sv] \
    [file join $module rtl tm4tn8_row_pipeline_v1.sv] \
    [file join $module rtl tm4tn8_microbench_v1.sv]]
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm4tn8_microbench_pilot_tb.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top tm4tn8_microbench_v1 [get_filesets sources_1]
set_property top tm4tn8_microbench_pilot_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM4TN8_PILOT_V1_BEGIN candidate=lut"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm4tn8_pilot_v1.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "TM4 pilot simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM4TN8_MICROBENCH_PILOT_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "TM4 pilot did not pass; see $simlog"
}
puts "TM4TN8_PILOT_V1_END"
close_project
