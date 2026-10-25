if {[llength $argv]!=3} {error "usage: m007_quant_amax_retime.tcl FROZEN OUTPUT DCP"}
set frozen [file normalize [lindex $argv 0]]
set output [file normalize [lindex $argv 1]]
set dcp [file normalize [lindex $argv 2]]
cd $output
set_param general.maxThreads 4
open_checkpoint $dcp
read_xdc [file join $frozen vivado module_design activation_quantizer tb m007_quant_amax_clock.xdc]
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes!=0} {error "AMAX blackboxes=$blackboxes"}
report_utilization -file utilization.rpt
report_timing_summary -max_paths 10 -file timing_summary.rpt
report_timing -max_paths 10 -path_type full -file critical_paths.rpt
check_timing -verbose -file check_timing.rpt
write_checkpoint quant_amax_synth.dcp
set path [get_timing_paths -delay_type max -max_paths 1]
if {[llength $path]!=1} {error "No actual AMAX timing path"}
puts "M007_QUANT_AMAX_OOC_COMPLETE blackboxes=0 clock_ns=[get_property PERIOD [get_clocks q_clk]] wns_ns=[get_property SLACK $path]"
exit
