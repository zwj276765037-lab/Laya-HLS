if {[llength $argv]!=2} {error "usage ATTEMPT WORK"}
lassign $argv at work
set at [file normalize $at]
set work [file normalize $work]
cd $work
set_param general.maxThreads 4
create_project qkv_bank_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e -force
add_files -norecurse [file join $at frozen laya_attention_qkv_bank_v1.sv]
set_property top laya_attention_qkv_bank_v1 [get_filesets sources_1]
update_compile_order -fileset sources_1
read_xdc [file join $at frozen qkv_clock.xdc]
synth_design -top laya_attention_qkv_bank_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes != 0} {error "QKV_BANK_BLACKBOX $blackboxes"}
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work qkv_bank_synth.dcp]
puts "QKV_BANK_OOC_PASS blackboxes=0"
exit
