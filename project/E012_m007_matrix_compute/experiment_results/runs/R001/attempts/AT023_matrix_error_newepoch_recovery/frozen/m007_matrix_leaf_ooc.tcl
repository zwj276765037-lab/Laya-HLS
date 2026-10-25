set at [file normalize [lindex $argv 0]]
set src [file join $at frozen]
foreach top {laya_m007_a_bank_v1} {
 create_project -in_memory -part xcu55c-fsvh2892-2L-e
 set_param general.maxThreads 4
 read_verilog -sv [glob [file join $src *.sv]]
 set xdc [file join $at work ${top}.xdc]
 set fh [open $xdc w]
 puts $fh {create_clock -name core -period 3.333 [get_ports clk]}
 close $fh
 read_xdc $xdc
 synth_design -top $top -mode out_of_context -no_timing_driven -part xcu55c-fsvh2892-2L-e
 report_utilization -hierarchical -file [file join $at ${top}_utilization.rpt]
 report_ram_utilization -file [file join $at ${top}_ram.rpt]
 set bb [get_cells -hier -filter {IS_BLACKBOX == 1}]
 if {[llength $bb] != 0} {error "Blackboxes: $bb"}
 set dsp [llength [get_cells -hier -filter {REF_NAME =~ DSP48*}]]
 set uram [llength [get_cells -hier -filter {REF_NAME =~ URAM*}]]
 set bram36 [llength [get_cells -hier -filter {REF_NAME =~ RAMB36*}]]
 set bram18 [llength [get_cells -hier -filter {REF_NAME =~ RAMB18*}]]
 set fh [open [file join $at ${top}_result.json] w]
 puts $fh "{\"top\":\"$top\",\"blackboxes\":0,\"DSP\":$dsp,\"URAM\":$uram,\"BRAM36\":$bram36,\"BRAM18\":$bram18,\"scope\":\"SMALL_OOC_CAPACITY_ONLY\"}"
 close $fh
 write_checkpoint -force [file join $at work ${top}.dcp]
 puts "M007_MATRIX_SMALL_OOC_PASS top=$top DSP=$dsp URAM=$uram BRAM36=$bram36 BRAM18=$bram18"
 close_project
}
puts M007_MATRIX_OOC_PASS
