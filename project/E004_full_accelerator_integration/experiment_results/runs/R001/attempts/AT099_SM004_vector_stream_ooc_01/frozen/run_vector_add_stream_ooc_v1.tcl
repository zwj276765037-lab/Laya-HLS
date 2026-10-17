if {[llength $argv] != 2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
set part xcu55c-fsvh2892-2L-e
read_verilog -sv [file join $frozen laya_vector_add_stream_v1.sv]
read_verilog [file join $frozen attention_ce_add.v]
synth_design -top laya_vector_add_stream_v1 -part $part -mode out_of_context
create_clock -name clk -period 6.667 [get_ports clk]
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -file [file join $work timing_summary.rpt]
report_timing -max_paths 10 -file [file join $work timing_paths.rpt]
write_checkpoint -force [file join $work vector_add_stream_v1_synth.dcp]
puts VECTOR_ADD_STREAM_OOC_PASS
