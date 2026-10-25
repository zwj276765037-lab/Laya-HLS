if {[llength $argv]!=1} {error "usage: m007_fmul_ooc.tcl ATTEMPT"}
set at [file normalize [lindex $argv 0]]
cd [file join $at work]
set_param general.maxThreads 4
create_project strict_fmul_ooc [file join $at work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [file join $at frozen laya_fmul_rne_v1.sv]
set_property top laya_fmul_rne_v1 [get_filesets sources_1]
read_xdc [file join $at frozen m007_fmul_clock.xdc]
synth_design -top laya_fmul_rne_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy rebuilt
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes!=0} {error "FMUL OOC blackboxes=$blackboxes"}
report_utilization -file utilization.rpt
report_timing_summary -max_paths 10 -file timing_summary.rpt
report_timing -max_paths 10 -path_type full -file critical_paths.rpt
report_methodology -file methodology.rpt
write_checkpoint fmul_rne_synth.dcp
puts "FMUL_RNE_OOC_PASS blackboxes=0 clock_period_ns=3.333"
exit
