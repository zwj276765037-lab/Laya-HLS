set b [file normalize $::env(LAYA_GEGLU_BANK_ATTEMPT)]
set_param general.maxThreads 4
source [file join $b frozen_source bank_boundaries.tcl]
set part xcu55c-fsvh2892-2L-e
set work [file join $b ooc parent]
file mkdir $work
set ed [file join $b ooc edif]
file mkdir $ed
cd $work
create_project -in_memory -part $part
read_verilog [file join $b frozen_source geglu_core_stub.v]
read_verilog -sv [file join $b frozen_source geglu_row_bank_v1.sv]
read_verilog -sv [file join $b frozen_source geglu_canonical_row_adapter.sv]
read_xdc [file join $b frozen_source clock.xdc]
synth_design -top geglu_canonical_row_adapter -part $part -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set boxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $boxes]!=1 || [get_property REF_NAME [get_cells arithmetic]]!="geglu_canonical_core"} {error "GEGLU_BANK_PARENT_BOUNDARY"}
foreach cell {u_bank g_bank gate_bank} {
 if {[llength [get_cells -quiet $cell]]!=1 || [get_property REF_NAME [get_cells $cell]]!="geglu_row_bank_v1"} {error "GEGLU_BANK_PARENT_STORAGE $cell"}
 set_property KEEP_HIERARCHY true [get_cells $cell]
}
set_property KEEP_HIERARCHY true [get_cells arithmetic]
write_checkpoint parent_stub_only.dcp
report_utilization -hierarchical -file parent_stub_only_utilization.rpt
write_edif [file join $ed geglu_canonical_row_adapter.edf]
puts "TANH_LIBM_GEGLU_BANK_PARENT_EXPORTED arithmetic_stub=1 banks=3 row_data_bits=251904"
close_project
read_edif [file join $b ooc core_export geglu_canonical_core.edf]
read_edif [file join $ed geglu_canonical_row_adapter.edf]
link_design -top geglu_canonical_row_adapter -part $part -mode out_of_context
read_xdc [file join $b frozen_source clock.xdc]
if {[llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]!=0} {error "GEGLU_BANK_FINAL_BLACKBOX"}
if {[llength [get_cells -quiet -hierarchical -filter {REF_NAME =~ IBUF* || REF_NAME =~ OBUF* || REF_NAME =~ IOBUF*}]]!=0} {error "GEGLU_BANK_OOC_IO_PADS"}
set f [open final_boundary_map.txt w]
foreach cell $boundary_cells {
 set target [get_cells -quiet $cell]
 if {[llength $target]!=1} {error "GEGLU_BANK_FINAL_BOUNDARY_PATH $cell"}
 set actual [get_property REF_NAME $target]
 set normalized [regsub {(_HDI_[0-9]+)+$} $actual {}]
 if {$normalized!=$boundary_module($cell)} {error "GEGLU_BANK_FINAL_BOUNDARY_REF $cell actual=$actual normalized=$normalized"}
 puts $f "$cell $normalized $actual [get_property IS_BLACKBOX $target]"
}
close $f
write_checkpoint geglu_row_bank_assembled.dcp
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
set f [open bank_primitive_map.txt w]
foreach cell {u_bank g_bank gate_bank} {
 set ram [get_cells -quiet -hierarchical -filter "NAME =~ $cell/* && (REF_NAME =~ RAMB* || REF_NAME =~ URAM*)"]
 if {[llength $ram]==0} {error "GEGLU_BANK_PHYSICAL_RAM_ABSENT $cell"}
 foreach r $ram {puts $f "$cell $r [get_property REF_NAME $r]"}
}
close $f
puts "TANH_LIBM_GEGLU_BANK_RESOURCES_COMPLETE boundaries=51 blackboxes=0 io_pads=0 banks=3 row_data_bits=251904"
report_timing_summary -delay_type max -max_paths 10 -file timing_summary.rpt
check_timing -verbose -file check_timing.rpt
puts "TANH_LIBM_GEGLU_BANK_OOC_COMPLETE boundaries=51 blackboxes=0 io_pads=0 banks=3 row_data_bits=251904"
close_design
catch {close_project}
exit
