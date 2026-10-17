if {[llength $argv] != 4} {error "usage: run_quant_generated_controller.tcl WORK GENERATED_RTL FROZEN_ROOT FIXTURE"}
lassign $argv work generated frozen fixture
set work [file normalize $work]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
create_project quant_generated [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set files [list [file join $generated r0_fp_bits_pkg.sv]]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row laya_quant_group_service} {
  lappend files [file join $generated ${f}.sv]
}
lappend files [file join $generated laya_quant_blackbox_smoke.v]
add_files -norecurse $files
add_files -fileset sim_1 [file join $module tb quant_generated_controller_tb.sv]
set ipdir [file join $frozen results compute_throughput_optimization_20261010 attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
source [file join $ipdir laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $ipdir laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top laya_quant_blackbox_smoke [get_filesets sources_1]
set_property top quant_generated_controller_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property xsim.simulate.xsim.more_options "-testplusarg FIXTURE=$fixture" [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado quant_generated.sim sim_1 behav xsim simulate.log]
set fh [open $log r];set s [read $fh];close $fh
if {[string first QUANT_GENERATED_CONTROLLER_PASS $s]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $s]} {error "quant generated controller failure: $log"}
puts QUANT_GENERATED_CONTROLLER_SCRIPT_PASS
close_project
