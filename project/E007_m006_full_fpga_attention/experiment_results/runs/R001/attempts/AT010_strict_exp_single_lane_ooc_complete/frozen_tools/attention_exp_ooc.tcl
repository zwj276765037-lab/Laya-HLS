if {[llength $argv]!=2} {error "usage ATTEMPT WORK"}
lassign $argv at work
set at [file normalize $at]
set work [file normalize $work]
cd $work
set_param general.maxThreads 4
create_project attention_exp_leaf_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e -force
add_files -norecurse [lsort [glob [file join $at frozen_rtl *.v]]]
foreach data [glob [file join $at frozen_rtl *.dat]] {file copy -force $data $work}
set_property top attention_exp_leaf [get_filesets sources_1]
update_compile_order -fileset sources_1
read_xdc [file join $at frozen_tools attention_exp_ooc.xdc]
synth_design -top attention_exp_leaf -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set count [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$count!=0} {error "ATTENTION_EXP_BLACKBOX $count"}
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work attention_exp_synth.dcp]
puts "ATTENTION_EXP_SINGLE_LANE_OOC_PASS blackboxes=0"
exit
