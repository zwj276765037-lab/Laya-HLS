set at [file normalize [lindex $argv 0]]
set src [file join $at frozen]
create_project -in_memory -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
read_verilog -sv [glob [file join $src laya_m007_w*.sv]]
set xdc [file join $at work clock.xdc]
set fh [open $xdc w]
puts $fh {create_clock -name core -period 3.333 [get_ports clk]}
close $fh
read_xdc $xdc
synth_design -top laya_m007_w_supply_v1 -mode out_of_context -no_timing_driven -flatten_hierarchy none -part xcu55c-fsvh2892-2L-e
report_utilization -hierarchical -file [file join $at utilization.rpt]
report_timing_summary -file [file join $at timing.rpt]
report_ram_utilization -file [file join $at ram.rpt]
set bb [get_cells -hier -filter {IS_BLACKBOX == 1}]
if {[llength $bb] != 0} {error "Blackboxes: $bb"}
write_checkpoint -force [file join $at work m007_weight_supply.dcp]
set fh [open [file join $at synthesis_result.json] w]
puts $fh "{\"blackboxes\":0,\"part\":\"xcu55c-fsvh2892-2L-e\",\"clock_ns\":3.333,\"stage\":\"OOC_SYNTHESIS_ONLY\"}"
close $fh
puts M007_WEIGHT_SUPPLY_OOC_PASS
