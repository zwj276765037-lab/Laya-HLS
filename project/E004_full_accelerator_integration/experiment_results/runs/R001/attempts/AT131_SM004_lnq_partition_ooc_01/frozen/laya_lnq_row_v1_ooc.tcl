if {[llength $argv] != 2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
set part xcu55c-fsvh2892-2L-e
create_project lnq_row_ooc [file join $work lnq_row_ooc] -part $part
source [file join $frozen ln_sqrt_ip.tcl]
source [file join $frozen laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $frozen laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
foreach path [glob -nocomplain [file join $frozen attention*.v]] {
  read_verilog $path
}
foreach name {ln_mul.v ln_div.v ln_sqrt.v ln_add.v
              laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1.v
              laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1.v} {
  read_verilog [file join $frozen $name]
}
read_verilog -sv [file join $frozen r0_fp_bits_pkg.sv]
read_verilog -sv [file join $frozen ln_add_stream.sv]
foreach name {quant16_slot_banks.sv quant16_amax16.sv quant16_half_rne.sv
              quant16_tiny_div127.sv quant16_divider_service.sv
              quant16_stream_row.sv laya_ln_row_v1.sv laya_lnq_row_v1.sv} {
  read_verilog -sv [file join $frozen $name]
}
synth_design -top laya_lnq_row_v1 -part $part -mode out_of_context
create_clock -name clk -period 6.667 [get_ports clk]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -file [file join $work timing_summary.rpt]
report_timing -max_paths 10 -file [file join $work timing_paths.rpt]
set blackboxes [get_cells -hier -filter {IS_BLACKBOX == 1}]
set fd [open [file join $work blackboxes.txt] w]
puts $fd "count=[llength $blackboxes]"
foreach c $blackboxes {puts $fd $c}
close $fd
write_checkpoint -force [file join $work lnq_row_v1_synth.dcp]
puts LNQ_ROW_OOC_PASS
