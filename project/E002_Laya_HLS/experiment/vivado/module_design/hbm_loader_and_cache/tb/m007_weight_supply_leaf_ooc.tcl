set at [file normalize [lindex $argv 0]]
set src [file join $at frozen]
foreach top {laya_m007_w_reader_v1} {
 create_project -in_memory -part xcu55c-fsvh2892-2L-e
 set_param general.maxThreads 4
 read_verilog -sv [file join $src ${top}.sv]
 set xdc [file join $at work ${top}.xdc]
 set fh [open $xdc w]
 puts $fh {create_clock -name core -period 3.333 [get_ports clk]}
 close $fh
 read_xdc $xdc
 synth_design -top $top -mode out_of_context -no_timing_driven -part xcu55c-fsvh2892-2L-e
 report_utilization -hierarchical -file [file join $at ${top}_utilization.rpt]
 # Capacity-only continuation: reader synthesis completed in AT013; timing
 # report generation consumed the remaining pilot. Physical timing is NOT_RUN.
 report_ram_utilization -file [file join $at ${top}_ram.rpt]
 set bb [get_cells -hier -filter {IS_BLACKBOX == 1}]
 if {[llength $bb] != 0} {error "Blackboxes: $bb"}
 set uram [llength [get_cells -hier -filter {REF_NAME =~ URAM*}]]
 set bram36 [llength [get_cells -hier -filter {REF_NAME =~ RAMB36*}]]
 set bram18 [llength [get_cells -hier -filter {REF_NAME =~ RAMB18*}]]
 set fh [open [file join $at ${top}_result.json] w]
 puts $fh "{\"top\":\"$top\",\"blackboxes\":0,\"URAM\":$uram,\"BRAM36\":$bram36,\"BRAM18\":$bram18,\"stage\":\"LEAF_OOC_SYNTHESIS_ONLY\"}"
 close $fh
 write_checkpoint -force [file join $at work ${top}.dcp]
 puts "M007_WEIGHT_LEAF_OOC_PASS top=$top URAM=$uram BRAM36=$bram36 BRAM18=$bram18"
 close_project
}
puts M007_WEIGHT_SUPPLY_OOC_PASS
