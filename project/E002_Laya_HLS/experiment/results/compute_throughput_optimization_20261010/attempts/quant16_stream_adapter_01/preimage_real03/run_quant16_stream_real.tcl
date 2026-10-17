if {[llength $argv] != 2} {
    error "usage: run_quant16_stream_real.tcl FRESH_WORK FIXTURE_DIR"
}
lassign $argv work fixture
set work [file normalize $work]
set fixture [file normalize $fixture]
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $fixture manifest.json]]} {
    error "fresh work directory and independent fixture required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set root [file normalize [file join $module .. .. ..]]
set ipdir [file join $root results compute_throughput_optimization_20261010 \
    attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
set divtcl [file join $ipdir \
    laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
set multcl [file join $ipdir \
    laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
if {![file isfile $divtcl] || ![file isfile $multcl]} {
    error "frozen syn03 FP IP Tcl missing"
}
create_project quant16_stream_real [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl quant16_slot_banks.sv] \
    [file join $module rtl quant16_amax16.sv] \
    [file join $module rtl quant16_half_rne.sv] \
    [file join $module rtl quant16_divider_service.sv] \
    [file join $module rtl quant16_stream_row.sv]]
add_files -norecurse -fileset sim_1 \
    [file join $module tb quant16_stream_row_tb.sv]
source $divtcl
source $multcl
set divip [get_ips laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip]
set mulip [get_ips laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip]
if {[llength $divip] != 1 || [get_property CONFIG.C_LATENCY $divip] != 6 ||
    [get_property CONFIG.C_RATE $divip] != 1 ||
    [get_property CONFIG.HAS_ARESETN $divip] != false ||
    [llength $mulip] != 1 || [get_property CONFIG.C_LATENCY $mulip] != 1 ||
    [get_property CONFIG.C_RATE $mulip] != 1 ||
    [get_property CONFIG.HAS_ARESETN $mulip] != false} {
    error "frozen FP IP configuration drift"
}
set_property top quant16_stream_row [get_filesets sources_1]
set_property top quant16_stream_row_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado quant16_stream_real.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "stream simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "QUANT16_STREAM_REAL_ROWS_PASS groups=114 q_bytes=3648 edges=2 protocol=1 numerical=5 reset=2" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "stream real-row simulation failed; see $simlog"
}
puts "QUANT16_STREAM_REAL_SIM_END"
close_project
