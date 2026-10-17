if {[llength $argv] != 1} {error "usage: run_fp_ip_probe.tcl FRESH_WORK"}
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing FP probe work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_fp_probe [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm1tn8_fp_ip_probe_tb.sv]
source [file join $module tb create_fp_ip.tcl]
foreach kind {sitofp fmul fadd} {
    set ip [get_ips tm1tn8_${kind}_ip]
    puts "TM1TN8_FP_CONFIG $kind latency=[get_property CONFIG.C_LATENCY $ip]"
}
set_property top tm1tn8_fp_ip_probe_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_fp_probe.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} {error "FP probe simulator log missing"}
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_FP_IP_PROBE_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "FP IP probe did not pass; see $simlog"
}
puts "TM1TN8_FP_IP_PROBE_END"
close_project
