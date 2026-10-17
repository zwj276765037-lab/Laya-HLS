if {[llength $argv] != 5} {
    error "usage: run_arithmetic_real.tcl FRESH_WORK VECTORS ROWS G T"
}
lassign $argv work vectors rows groups tiles
set work [file normalize $work]
set vectors [file normalize $vectors]
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $vectors manifest.json]]} {
    error "fresh work and materialized vector directory required"
}
if {!(($rows == 1 && $groups == 8 && $tiles == 1) ||
       (($rows == 1 || $rows == 4) && $groups == 32 && $tiles == 384))} {
    error "unsupported real arithmetic shape"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_arithmetic_real [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl tm1tn8_integer_tree.sv] \
    [file join $module rtl tm1tn8_fp_restore.sv] \
    [file join $module rtl tm1tn8_reserved_store.sv] \
    [file join $module rtl tm1tn8_arithmetic_pipeline.sv]]
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm1tn8_arithmetic_real_tb.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top tm1tn8_arithmetic_pipeline [get_filesets sources_1]
set_property top tm1tn8_arithmetic_real_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg VEC_DIR=$vectors -testplusarg ROWS=$rows -testplusarg G=$groups -testplusarg T=$tiles" \
    -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM1TN8_ARITHMETIC_REAL_SIM_BEGIN rows=$rows G=$groups T=$tiles"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_arithmetic_real.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "real arithmetic simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_ARITHMETIC_REAL_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "real arithmetic simulation did not pass; see $simlog"
}
puts "TM1TN8_ARITHMETIC_REAL_SIM_END"
close_project
