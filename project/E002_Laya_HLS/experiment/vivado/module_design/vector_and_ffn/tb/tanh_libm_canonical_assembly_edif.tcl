# Structural link of EDIF exported from exact canonical child/parent DCPs.
set attempt [file normalize $::env(LAYA_CANONICAL_ATTEMPT)]
set_param general.maxThreads 4
source [file join $attempt frozen_source canonical_boundaries.tcl]
set part xcu55c-fsvh2892-2L-e
set work [file join $attempt ooc parent]
file mkdir $work
set ed [file join $attempt ooc edif]
file mkdir $ed
foreach module [array names class_dcp] {
 if {![file exists $class_dcp($module)]} {error "CANONICAL_MISSING_EXACT_DCP $module"}
 open_checkpoint $class_dcp($module)
 if {[get_property PART [current_design]] != $part} {error "CANONICAL_DCP_PART $module"}
 if {[llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]] != 0} {error "CANONICAL_CHILD_BLACKBOX $module"}
 write_edif [file join $ed ${module}.edf]
 puts "TANH_LIBM_CANONICAL_EXACT_DCP_EXPORTED module=$module source=$class_dcp($module)"
 close_design
 catch {close_project}
}
cd $work
create_project -in_memory -part $part
read_verilog [file join $attempt frozen_source canonical_stubs.v]
read_verilog -sv [file join $attempt frozen_source tanh_libm_canonical.sv]
read_xdc [file join $attempt frozen_source clock.xdc]
synth_design -top tanh_libm_canonical_wrapper -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes] != 42} {error "CANONICAL_PARENT_BOUNDARY_COUNT [llength $boxes]"}
foreach cell $boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target] != 1 || [get_property REF_NAME $target] != $boundary_module($cell) || ![get_property IS_BLACKBOX $target]} {error "CANONICAL_PARENT_BOUNDARY $cell"}
 set_property KEEP_HIERARCHY true $target
}
write_checkpoint parent_stub_only.dcp
report_utilization -hierarchical -file parent_stub_only_utilization.rpt
write_edif [file join $ed tanh_libm_canonical_wrapper.edf]
puts "TANH_LIBM_CANONICAL_PARENT_EXPORTED boundaries=42"
close_project
foreach module [array names class_dcp] {read_edif [file join $ed ${module}.edf]}
read_edif [file join $ed tanh_libm_canonical_wrapper.edf]
link_design -top tanh_libm_canonical_wrapper -part $part -mode out_of_context
read_xdc [file join $attempt frozen_source clock.xdc]
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes] != 0} {error "CANONICAL_FINAL_BLACKBOX [llength $boxes]"}
set io_pads [get_cells -quiet -hierarchical -filter {REF_NAME =~ IBUF* || REF_NAME =~ OBUF* || REF_NAME =~ IOBUF*}]
if {[llength $io_pads] != 0} {error "CANONICAL_OOC_IO_PADS [llength $io_pads]"}
set map [open final_boundary_map.txt w]
foreach cell $boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target] != 1 || [get_property REF_NAME $target] != $boundary_module($cell)} {error "CANONICAL_ASSEMBLED_BOUNDARY $cell"}
 set_property KEEP_HIERARCHY true $target
 puts $map "$cell [get_property REF_NAME $target] [get_property IS_BLACKBOX $target] $class_dcp($boundary_module($cell)) [file join $ed $boundary_module($cell).edf]"
}
close $map
write_checkpoint tanh_libm_canonical_assembled.dcp
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
write_verilog -mode funcsim tanh_libm_canonical_assembled_sim.v
puts "TANH_LIBM_CANONICAL_ASSEMBLY_RESOURCES_COMPLETE boundaries=42 blackboxes=0 io_pads=0"
report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
report_clock_networks -file clock_networks.rpt
check_timing -verbose -file check_timing.rpt
puts "TANH_LIBM_CANONICAL_OOC_COMPLETE boundaries=42 add=23 mul=17 div=2 blackboxes=0"
close_design
exit
