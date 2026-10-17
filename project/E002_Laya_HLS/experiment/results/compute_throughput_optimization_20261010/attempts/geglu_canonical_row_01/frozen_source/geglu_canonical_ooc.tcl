set attempt [file normalize $::env(LAYA_GEGLU_CANONICAL_ATTEMPT)]
set_param general.maxThreads 4
source [file join $attempt frozen_source geglu_canonical_boundaries.tcl]
set part xcu55c-fsvh2892-2L-e
set work [file join $attempt ooc parent]
file mkdir $work
set ed [file join $attempt ooc edif]
file mkdir $ed
cd $work
create_project -in_memory -part $part
read_verilog [file join $attempt frozen_source canonical_stubs.v]
read_verilog [file join $attempt frozen_source canonical_core_stub.v]
read_verilog -sv [file join $attempt frozen_source geglu_canonical_core.sv]
read_verilog -sv [file join $attempt frozen_source geglu_canonical_row_adapter.sv]
read_xdc [file join $attempt frozen_source clock.xdc]
synth_design -top geglu_canonical_row_adapter -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes] != 10} {error "GEGLU_CANONICAL_PARENT_BOUNDARY_COUNT [llength $boxes]"}
foreach cell $stub_boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target]!=1 || [get_property REF_NAME $target]!=$boundary_module($cell) || ![get_property IS_BLACKBOX $target]} {error "GEGLU_CANONICAL_PARENT_BOUNDARY $cell"}
 set_property KEEP_HIERARCHY true $target
}
write_checkpoint parent_stub_only.dcp
report_utilization -hierarchical -file parent_stub_only_utilization.rpt
write_edif [file join $ed geglu_canonical_row_adapter.edf]
puts "TANH_LIBM_GEGLU_CANONICAL_PARENT_EXPORTED stub_boundaries=10 final_fp_boundaries=51 row_data_bytes=31488"
close_project
foreach module [array names class_edif] {read_edif $class_edif($module)}
read_edif $canonical_core_edif
read_edif [file join $ed geglu_canonical_row_adapter.edf]
link_design -top geglu_canonical_row_adapter -part $part -mode out_of_context
read_xdc [file join $attempt frozen_source clock.xdc]
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes]!=0} {error "GEGLU_CANONICAL_FINAL_BLACKBOX [llength $boxes]"}
set io_pads [get_cells -quiet -hierarchical -filter {REF_NAME =~ IBUF* || REF_NAME =~ OBUF* || REF_NAME =~ IOBUF*}]
if {[llength $io_pads]!=0} {error "GEGLU_CANONICAL_OOC_IO_PADS [llength $io_pads]"}
set map [open final_boundary_map.txt w]
foreach cell $boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target]!=1 || [get_property REF_NAME $target]!=$boundary_module($cell)} {error "GEGLU_CANONICAL_ASSEMBLED_BOUNDARY $cell"}
 set_property KEEP_HIERARCHY true $target
 puts $map "$cell [get_property REF_NAME $target] [get_property IS_BLACKBOX $target] $class_edif($boundary_module($cell))"
}
close $map
write_checkpoint geglu_canonical_row_assembled.dcp
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
write_verilog -mode funcsim geglu_canonical_row_assembled_sim.v
puts "TANH_LIBM_GEGLU_CANONICAL_RESOURCES_COMPLETE boundaries=51 blackboxes=0 io_pads=0 row_data_bytes=31488"
report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
report_clock_networks -file clock_networks.rpt
check_timing -verbose -file check_timing.rpt
puts "TANH_LIBM_GEGLU_CANONICAL_OOC_COMPLETE boundaries=51 add=25 mul=24 div=2 blackboxes=0 io_pads=0"
close_design
catch {close_project}
exit
