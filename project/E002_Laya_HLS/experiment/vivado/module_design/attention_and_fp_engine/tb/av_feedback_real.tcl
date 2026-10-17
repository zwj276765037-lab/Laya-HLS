if {[llength $argv] != 3} {
    error "usage: av_feedback_real.tcl FRESH_WORK GOLD_DIR {3|4}"
}
lassign $argv work gold mode
set work [file normalize $work]
set gold [file normalize $gold]
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $gold manifest.json]] ||
    !($mode == 3 || $mode == 4)} {
    error "fresh work, independent gold and mode 3|4 required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set q8 [file normalize [file join $module .. q8_linear_and_restore tm1tn8_gs32_512]]
create_project av_feedback_real [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 \
    [file join $module rtl av_feedback_bank_v1.sv]
add_files -norecurse -fileset sim_1 \
    [file join $module tb av_feedback_real_tb.sv]
add_files -norecurse -fileset sim_1 \
    [file join $module tb av_feedback_short_tb.sv]
source [file join $q8 tb create_fp_ip.tcl]
set_property top av_feedback_bank_v1 [get_filesets sources_1]
set_property top av_feedback_short_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "AV_FEEDBACK_SHORT_BEGIN"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set shortlog [file join $work vivado av_feedback_real.sim sim_1 behav xsim simulate.log]
if {![file isfile $shortlog]} { error "AV short simulator log missing" }
set handle [open $shortlog r]
set output [read $handle]
close $handle
if {[string first "AV_FEEDBACK_SHORT_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "AV short simulation did not pass; see $shortlog"
}
file copy -force $shortlog [file join $work av_feedback_short_simulate.log]
puts "AV_FEEDBACK_SHORT_END"
set_property top av_feedback_real_tb [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg GOLD_DIR=$gold -testplusarg MODE=$mode" \
    -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "AV_FEEDBACK_REAL_BEGIN mode=C$mode"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado av_feedback_real.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "AV real simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "AV_FEEDBACK_REAL_PASS mode=C$mode contributions=4096" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "AV real simulation did not pass; see $simlog"
}
puts "AV_FEEDBACK_REAL_END mode=C$mode"
close_project
