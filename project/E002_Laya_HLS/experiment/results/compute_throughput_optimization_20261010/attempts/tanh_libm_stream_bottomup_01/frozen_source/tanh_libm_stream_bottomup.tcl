set attempt [file normalize $::env(LAYA_TANH_BOTTOMUP_ATTEMPT)]
set mode [lindex $argv 0]
set_param general.maxThreads 4
source [file join $attempt frozen_source boundaries.tcl]
set part xcu55c-fsvh2892-2L-e
proc child_build {node} {
 global attempt node_sources part
 set work [file join $attempt nodes $node]
 file mkdir $work
 cd $work
 create_project -in_memory -part $part
 read_verilog $node_sources($node)
 read_xdc [file join $attempt frozen_source child_clock.xdc]
 synth_design -top $node -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
 set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
 if {$blackboxes != 0} {error "CHILD_BLACKBOX $node $blackboxes"}
 report_utilization -file utilization.rpt
 report_utilization -hierarchical -file utilization_hierarchical.rpt
 report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
 check_timing -verbose -file check_timing.rpt
 set portlog [open ports.txt w]
 foreach p [lsort [get_ports]] {puts $portlog "$p [get_property DIRECTION $p]"}
 close $portlog
 write_checkpoint child_synth.dcp
 puts "TANH_LIBM_BOTTOMUP_CHILD_COMPLETE node=$node blackboxes=0"
 close_project
}
proc parent_build {} {
 global attempt node_order node_cell parent_sources part
 set work [file join $attempt parent]
 cd $work
 create_project -in_memory -part $part
 foreach p $parent_sources {
  if {[file extension $p] == ".sv"} {read_verilog -sv $p} else {read_verilog $p}
 }
 read_xdc [file join $attempt frozen_source tanh_libm_clock.xdc]
 synth_design -top tanh_libm_stream_wrapper -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
 set boxes [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]
 if {[llength $boxes] != 42} {error "PARENT_STUB_COUNT [llength $boxes]"}
 foreach node $node_order {
  set cell [get_cells -quiet $node_cell($node)]
  if {[llength $cell] != 1 || [get_property REF_NAME $cell] != $node || ![get_property IS_BLACKBOX $cell]} {error "PARENT_BOUNDARY $node"}
  set_property KEEP_HIERARCHY true $cell
 }
 report_utilization -hierarchical -file parent_stub_only_utilization.rpt
 write_checkpoint parent_stub_only.dcp
 foreach node $node_order {
  set dcp [file join $attempt nodes $node child_synth.dcp]
  if {![file exists $dcp]} {error "MISSING_CHILD_DCP $node"}
  read_checkpoint -cell $node_cell($node) $dcp
  set cell [get_cells -quiet $node_cell($node)]
  if {[llength $cell] != 1 || [get_property IS_BLACKBOX $cell]} {error "UNRESOLVED_CHILD $node"}
  set_property KEEP_HIERARCHY true $cell
  puts "TANH_LIBM_BOTTOMUP_CHILD_IMPORTED node=$node cell=$node_cell($node)"
 }
 set boxes [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]
 if {[llength $boxes] != 0} {error "ASSEMBLY_BLACKBOX [llength $boxes]"}
 set maplog [open final_boundary_map.txt w]
 foreach node $node_order {
  set cell [get_cells -quiet $node_cell($node)]
  if {[llength $cell] != 1 || [get_property REF_NAME $cell] != $node} {error "ASSEMBLY_BOUNDARY $node"}
  puts $maplog "$node $node_cell($node) [get_property REF_NAME $cell] [get_property IS_BLACKBOX $cell]"
 }
 close $maplog
 report_utilization -file utilization.rpt
 report_utilization -hierarchical -file utilization_hierarchical.rpt
 report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
 report_clock_networks -file clock_networks.rpt
 check_timing -verbose -file check_timing.rpt
 write_checkpoint tanh_libm_stream_wrapper_assembled.dcp
 write_verilog -mode funcsim tanh_libm_stream_wrapper_assembled_sim.v
 puts "TANH_LIBM_BOTTOMUP_ASSEMBLY_COMPLETE boundaries=42 blackboxes=0"
 close_project
}
if {$mode == "child"} {
 set node [lindex $argv 1]
 if {[lsearch -exact $node_order $node] < 0} {error "UNKNOWN_NODE $node"}
 child_build $node
} elseif {$mode == "remaining"} {
 foreach node $node_order {
  if {![file exists [file join $attempt nodes $node child_synth.dcp]]} {child_build $node}
 }
 parent_build
} elseif {$mode == "parent"} {
 parent_build
} else {error "UNKNOWN_MODE $mode"}
exit

