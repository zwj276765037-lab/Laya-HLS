if {[llength $argv]!=2} {error "usage ATTEMPT WORK"}
lassign $argv at work
set at [file normalize $at]
set work [file normalize $work]
cd $work
set_param general.maxThreads 4
create_project direct_divider_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e -force
read_vhdl [file join $at frozen laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.vhd]
read_xdc [file join $at frozen clock.xdc]
set top laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip
synth_design -top $top -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized
set blackboxes [llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes != 0} {error "DIRECT_DIVIDER_BLACKBOX $blackboxes"}
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work direct_divider_synth.dcp]
puts "DIRECT_DIVIDER_OOC_PASS blackboxes=0"
exit
