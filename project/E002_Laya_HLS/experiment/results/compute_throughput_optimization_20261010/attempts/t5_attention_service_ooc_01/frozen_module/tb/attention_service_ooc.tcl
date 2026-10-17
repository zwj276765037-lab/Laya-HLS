if {[llength $argv]!=2} {error "usage: attention_service_ooc.tcl FRESH_WORK HLS"}
lassign $argv work hls
set work [file normalize $work]
set hls [file normalize $hls]
cd $work
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
# Each K/V memory has 65536 x 32 bits; permit those declared arrays without
# changing the external process RSS, wall-time, or semantic progress guards.
set_param synth.elaboration.rodinMoreOptions {rt::set_parameter var_size_limit 4194304}
create_project attention_service_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set rtl [file join $hls hls_project solution1 syn verilog]
add_files -norecurse [lsort [glob [file join $rtl *.v]]]
foreach file [lsort [glob [file join $rtl *_ip.tcl]]] {source $file}
foreach file [glob [file join $rtl *.dat]] {file copy -force $file $work}
set_property top laya_attention_service [get_filesets sources_1]
update_compile_order -fileset sources_1
read_xdc [file join $module tb attention_service_clock.xdc]
synth_design -top laya_attention_service -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized
set count [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$count!=0} {error "Attention OOC blackboxes=$count"}
report_utilization -file utilization.rpt
report_utilization -hierarchical -file utilization_hierarchical.rpt
report_timing_summary -max_paths 10 -file timing_summary.rpt
write_checkpoint attention_service_synth.dcp
puts "ATTENTION_SERVICE_OOC_PASS blackboxes=0"
exit
