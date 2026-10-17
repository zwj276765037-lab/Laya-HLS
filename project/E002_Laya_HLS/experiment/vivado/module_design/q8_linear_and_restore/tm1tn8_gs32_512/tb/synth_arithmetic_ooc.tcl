if {[llength $argv] != 1} {
    error "usage: synth_arithmetic_ooc.tcl FRESH_EXISTING_WORK_DIR"
}
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing arithmetic OOC work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set report [file join $work reports]
file mkdir $report
create_project tm1tn8_arithmetic_ooc [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl tm1tn8_integer_tree.sv] \
    [file join $module rtl tm1tn8_fp_restore.sv] \
    [file join $module rtl tm1tn8_reserved_store.sv] \
    [file join $module rtl tm1tn8_arithmetic_pipeline.sv]]
source [file join $module tb create_fp_ip.tcl]
set_property top tm1tn8_arithmetic_pipeline [get_filesets sources_1]
set xdc [file join $work arithmetic.xdc]
set fd [open $xdc w]
puts $fd {create_clock -name ap_clk -period 6.667 [get_ports clk]}
puts $fd {set_clock_uncertainty 0.035 [get_clocks ap_clk]}
close $fd
add_files -norecurse -fileset constrs_1 $xdc
update_compile_order -fileset sources_1
puts "TM1TN8_ARITHMETIC_OOC_BEGIN part=[get_property PART [current_project]]"
flush stdout
synth_design -top tm1tn8_arithmetic_pipeline \
    -part xcu55c-fsvh2892-2L-e -mode out_of_context \
    -flatten_hierarchy none
set blackboxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
set fd [open [file join $report blackboxes.tsv] w]
puts $fd "cell\tref"
foreach cell $blackboxes {
    puts $fd "[get_property NAME $cell]\t[get_property REF_NAME $cell]"
}
close $fd
if {[llength $blackboxes] != 0} {
    error "arithmetic OOC has [llength $blackboxes] blackboxes"
}
set fd [open [file join $report fp_instances.tsv] w]
puts $fd "cell\tref"
foreach cell [get_cells -quiet -hierarchical] {
    set ref [get_property REF_NAME $cell]
    if {[string match "*tm1tn8*ip*" $ref] ||
        [string match "*floating_point*" $ref]} {
        puts $fd "[get_property NAME $cell]\t$ref"
    }
}
close $fd
write_checkpoint -force [file join $report arithmetic_ooc.dcp]
report_utilization -file [file join $report utilization.rpt]
report_utilization -hierarchical -file [file join $report utilization_hierarchical.rpt]
report_timing_summary -file [file join $report timing_summary.rpt]
check_timing -verbose -file [file join $report check_timing.rpt]
report_timing -unconstrained -max_paths 100 \
    -file [file join $report unconstrained_paths.rpt]
puts "TM1TN8_ARITHMETIC_OOC_DONE blackboxes=0"
close_project
