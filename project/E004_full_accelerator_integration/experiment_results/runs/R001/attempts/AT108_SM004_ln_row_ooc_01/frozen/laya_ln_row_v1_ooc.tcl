if {[llength $argv] != 2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
set part xcu55c-fsvh2892-2L-e
create_project ln_row_ooc [file join $work ln_row_ooc] -part $part -force
source [file join $frozen ln_sqrt_ip.tcl]
foreach path [glob -nocomplain [file join $frozen attention*.v]] {
  read_verilog $path
}
read_verilog [file join $frozen ln_mul.v]
read_verilog [file join $frozen ln_div.v]
read_verilog [file join $frozen ln_sqrt.v]
read_verilog [file join $frozen ln_add.v]
read_verilog -sv [file join $frozen ln_add_stream.sv]
read_verilog -sv [file join $frozen laya_ln_row_v1.sv]
synth_design -top laya_ln_row_v1 -part $part -mode out_of_context
create_clock -name clk -period 6.667 [get_ports clk]
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -file [file join $work timing_summary.rpt]
report_timing -max_paths 10 -file [file join $work timing_paths.rpt]
set blackboxes [get_cells -hier -filter {IS_BLACKBOX == 1}]
set fd [open [file join $work blackboxes.txt] w]
puts $fd "count=[llength $blackboxes]"
foreach c $blackboxes {puts $fd $c}
close $fd
write_checkpoint -force [file join $work ln_row_v1_synth.dcp]
puts LN_ROW_OOC_PASS
