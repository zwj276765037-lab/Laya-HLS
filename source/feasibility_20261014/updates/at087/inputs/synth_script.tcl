# M005 representative top synthesis. Inputs are an externally frozen source
# list and exact vendor IP Tcl list; this script never reads the simulation TB.
if {[llength $argv] != 4} {
  error "usage: WORK RTL_LIST IP_TCL_LIST ROM_DIR"
}
lassign $argv work rtl_list ip_tcl_list rom_dir
set part xcu55c-fsvh2892-2L-e
file mkdir $work
cd $work
set_param general.maxThreads 4
create_project m005_joint_top [file join $work vivado] -part $part
set_property target_language Verilog [current_project]

set stream [open $rtl_list r]
set rtl [split [read $stream] "\n"]
close $stream
set count 0
foreach path $rtl {
  if {$path eq ""} {continue}
  if {![file isfile $path]} {error "missing frozen RTL: $path"}
  add_files -norecurse $path
  incr count
}
if {$count < 100} {error "incomplete representative source closure: $count"}

set stream [open $ip_tcl_list r]
set scripts [split [read $stream] "\n"]
close $stream
set ip_count 0
foreach script $scripts {
  if {$script eq ""} {continue}
  if {![file isfile $script]} {error "missing frozen IP script: $script"}
  source $script
  incr ip_count
}
if {$ip_count != 8} {error "unexpected IP script count: $ip_count"}

set rom_count 0
foreach rom [lsort [glob -nocomplain [file join $rom_dir *ROM_AUTO_1R.dat]]] {
  file copy -force -- $rom [file join $work [file tail $rom]]
  incr rom_count
}
if {$rom_count != 7} {error "unexpected LN ROM count: $rom_count"}
puts "M005_SYNTH_INPUTS RTL=$count IP=$ip_count ROM=$rom_count"

set xdc [file join $work m005_clock.xdc]
set stream [open $xdc w]
puts $stream {create_clock -period 6.667 -name core_clk [get_ports clk]}
puts $stream {set_clock_uncertainty 0.300 [get_clocks core_clk]}
close $stream
add_files -fileset constrs_1 $xdc
update_compile_order -fileset sources_1
synth_design -top laya_ffn_representative_top_v1 -part $part \
  -mode out_of_context -flatten_hierarchy none
write_checkpoint -force [file join $work representative_synth.dcp]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchy.rpt]
report_timing_summary -report_unconstrained -file [file join $work timing_synth.rpt]
report_drc -file [file join $work drc_synth.rpt]
puts M005_SYNTH_COMPLETE
close_project
