set attempt [file normalize $::env(LAYA_CANONICAL_ATTEMPT)]
set_param general.maxThreads 4
source [file join $attempt frozen_source canonical_boundaries.tcl]
set part xcu55c-fsvh2892-2L-e
proc build_class {module} {
 global attempt class_sources part
 set work [file join $attempt ooc $module]
 file mkdir $work
 cd $work
 create_project -in_memory -part $part
 read_verilog $class_sources($module)
 read_xdc [file join $attempt frozen_source child_clock.xdc]
 synth_design -top $module -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
 set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
 if {[llength $boxes] != 0} {error "CANONICAL_CHILD_BLACKBOX $module"}
 write_checkpoint child_synth.dcp
 report_utilization -file utilization.rpt
 report_utilization -hierarchical -file utilization_hierarchical.rpt
 set ports [open ports.txt w]
 foreach p [lsort [get_ports]] {puts $ports "$p [get_property DIRECTION $p]"}
 close $ports
 puts "TANH_LIBM_CANONICAL_CLASS_COMPLETE module=$module blackboxes=0"
 close_project
}
foreach module $new_classes {
 if {![file exists $class_dcp($module)]} {build_class $module}
}
set work [file join $attempt ooc parent]
file mkdir $work
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
foreach cell $boundary_cells {
 set module $boundary_module($cell)
 if {![file exists $class_dcp($module)]} {error "CANONICAL_MISSING_DCP $module"}
 read_checkpoint -cell $cell $class_dcp($module)
 set target [get_cells -quiet $cell]
 if {[llength $target] != 1 || [get_property IS_BLACKBOX $target]} {error "CANONICAL_UNRESOLVED_CELL $cell"}
 set_property KEEP_HIERARCHY true $target
 puts "TANH_LIBM_CANONICAL_IMPORTED cell=$cell module=$module"
}
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes] != 0} {error "CANONICAL_FINAL_BLACKBOX [llength $boxes]"}
set map [open final_boundary_map.txt w]
foreach cell $boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target] != 1 || [get_property REF_NAME $target] != $boundary_module($cell)} {error "CANONICAL_ASSEMBLED_BOUNDARY $cell"}
 puts $map "$cell [get_property REF_NAME $target] [get_property IS_BLACKBOX $target] $class_dcp($boundary_module($cell))"
}
close $map
write_checkpoint tanh_libm_canonical_assembled.dcp
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
write_verilog -mode funcsim tanh_libm_canonical_assembled_sim.v
puts "TANH_LIBM_CANONICAL_ASSEMBLY_RESOURCES_COMPLETE boundaries=42 blackboxes=0"
report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
report_clock_networks -file clock_networks.rpt
check_timing -verbose -file check_timing.rpt
puts "TANH_LIBM_CANONICAL_OOC_COMPLETE boundaries=42 add=23 mul=17 div=2 blackboxes=0"
close_project
exit
