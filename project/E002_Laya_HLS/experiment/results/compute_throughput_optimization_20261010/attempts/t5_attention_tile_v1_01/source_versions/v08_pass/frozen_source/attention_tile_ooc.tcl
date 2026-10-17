if {[llength $argv]!=2} {error "usage attention_tile_ooc.tcl ATTEMPT WORK"}
lassign $argv attempt work
set attempt [file normalize $attempt]
set work [file normalize $work]
cd $work
set_param general.maxThreads 4
set_param synth.elaboration.rodinMoreOptions {rt::set_parameter var_size_limit 4194304}
create_project attention_tile_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [lsort [glob [file join $attempt rtl *.v]]]
add_files -norecurse [file join $attempt frozen_source attention_tile_service_v1.sv]
foreach file [lsort [glob [file join $attempt rtl *_ip.tcl]]] {source $file}
foreach file [glob [file join $attempt rtl *.dat]] {file copy -force $file $work}
set_property top attention_tile_service_v1 [get_filesets sources_1]
update_compile_order -fileset sources_1
create_clock -name ap_clk -period 6.667 [get_ports ap_clk]
synth_design -top attention_tile_service_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set count [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$count!=0} {error "Attention tile OOC blackboxes=$count"}
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
write_checkpoint attention_tile_synth.dcp
report_timing_summary -max_paths 10 -file timing_summary.rpt
puts "ATTENTION_SERVICE_TILE_OOC_PASS blackboxes=0"
exit
