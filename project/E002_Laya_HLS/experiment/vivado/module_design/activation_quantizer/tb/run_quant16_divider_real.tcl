if {[llength $argv] != 2} {
    error "usage: run_quant16_divider_real.tcl FRESH_WORK FIXTURE_DIR"
}
lassign $argv work fixture
set work [file normalize $work]
set fixture [file normalize $fixture]
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $fixture manifest.json]]} {
    error "fresh work directory and divider fixture required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set root [file normalize [file join $module .. .. ..]]
set iptcl [file join $root results compute_throughput_optimization_20261010 \
    attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog \
    laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
if {![file isfile $iptcl]} { error "frozen syn03 divider IP Tcl missing" }
create_project quant16_divider_real [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 \
    [file join $module rtl quant16_divider_service.sv]
add_files -norecurse -fileset sim_1 \
    [file join $module tb quant16_divider_tb.sv]
source $iptcl
set ip [get_ips laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip]
if {[llength $ip] != 1 || [get_property CONFIG.C_LATENCY $ip] != 6 ||
    [get_property CONFIG.C_RATE $ip] != 1 ||
    [get_property CONFIG.HAS_ARESETN $ip] != false} {
    error "divider IP configuration drift"
}
set_property top quant16_divider_service [get_filesets sources_1]
set_property top quant16_divider_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set args {}
foreach {key filename} {
    WI_AMAX wi_amax.mem WI_D wi_d_full.mem WI_RECIP wi_reciprocal.mem
    DOWN_AMAX down_amax.mem DOWN_D down_d_full.mem
    DOWN_RECIP down_reciprocal.mem
} {
    lappend args "-testplusarg $key=[file join $fixture $filename]"
}
set_property -name xsim.simulate.xsim.more_options \
    -value [join $args { }] -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado quant16_divider_real.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "divider simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "QUANT16_DIVIDER_RTL_PASS real_groups=114" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "divider real simulation failed; see $simlog"
}
puts "QUANT16_DIVIDER_REAL_SIM_END"
close_project
