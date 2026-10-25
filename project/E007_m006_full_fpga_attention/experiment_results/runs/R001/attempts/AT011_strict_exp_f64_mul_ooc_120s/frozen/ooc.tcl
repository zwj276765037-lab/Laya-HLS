if {[llength $argv]!=2} {error "usage ATTEMPT WORK"}
lassign $argv at work
set at [file normalize $at]
set work [file normalize $work]
cd $work
set_param general.maxThreads 4
create_project f64_mul_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e -force
add_files -norecurse [lsort [glob [file join $at frozen *.v]]]
set_property top attention_exp_leaf_attention_f64_mul [get_filesets sources_1]
update_compile_order -fileset sources_1
read_xdc [file join $at frozen attention_exp_ooc.xdc]
synth_design -top attention_exp_leaf_attention_f64_mul -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes != 0} {error "F64_MUL_BLACKBOX $blackboxes"}
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work f64_mul_synth.dcp]
puts "F64_MUL_OOC_PASS blackboxes=0"
exit
