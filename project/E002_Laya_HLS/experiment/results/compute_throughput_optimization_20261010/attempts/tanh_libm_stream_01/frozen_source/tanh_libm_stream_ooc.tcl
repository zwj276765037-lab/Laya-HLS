set attempt [file normalize $::env(LAYA_TANH_STREAM_ATTEMPT)]
set_param general.maxThreads 4
foreach source [lsort [glob [file join $attempt hls_project solution1 syn verilog *.v]]] {
 read_verilog $source
}
read_verilog -sv [file join $attempt static tanh_libm_stream_wrapper.sv]
read_xdc [file join $attempt frozen_source tanh_libm_clock.xdc]
synth_design -top tanh_libm_stream_wrapper -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
if {[llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]] != 0} { error "UNEXPECTED_BLACKBOX" }
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
report_clock_networks -file clock_networks.rpt
check_timing -verbose -file check_timing.rpt
write_checkpoint tanh_libm_stream_wrapper_synth.dcp
puts "TANH_LIBM_STREAM_VIVADO_OOC_PASS blackboxes=0"
exit
