if {[llength $argv] != 1} {error "usage: t4_w_cache_bank_ooc.tcl FRESH_WORK"}
set work [file normalize [lindex $argv 0]]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
set_param synth.elaboration.rodinMoreOptions {rt::set_parameter var_size_limit 100000000}
create_project t4_bank_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e
read_verilog -sv [file join $module rtl t4_w_cache_bank_v1.sv]
synth_design -top t4_w_cache_bank_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
set urams [get_cells -hierarchical -filter {REF_NAME =~ URAM288*}]
set brams [get_cells -hierarchical -filter {REF_NAME =~ RAMB*}]
if {$blackboxes != 0 || [llength $urams] == 0 || [llength $brams] == 0} {error "T4_BANK_RAM_MAPPING_FAIL BB=$blackboxes URAM=[llength $urams] BRAM=[llength $brams]"}
set clk [open [file join $work clock.xdc] w]
puts $clk "create_clock -name clk -period 6.667 \[get_ports clk\]"
close $clk
read_xdc [file join $work clock.xdc]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work bank_synth.dcp]
puts "T4_W_CACHE_BANK_OOC_PASS URAM=[llength $urams] BRAM=[llength $brams] blackboxes=0"
close_project
