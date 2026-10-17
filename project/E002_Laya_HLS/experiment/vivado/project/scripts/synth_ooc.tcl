if {[llength $argv] != 3} {
    error "usage: synth_ooc.tcl RUN_DIR REPORT_DIR THREADS"
}
lassign $argv run_dir report_dir threads
set run_dir [file normalize $run_dir]
set report_dir [file normalize $report_dir]
set_param general.maxThreads $threads

open_project [file join $run_dir vivado laya_ooc.xpr]
if {[llength [get_ips -quiet]] != 13} { error "missing floating-point IP" }
set_property -dict [list {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context}] [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
if {[file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]] ne [file join $run_dir prepare_dat.tcl]} {
    error "DAT preparation hook is absent"
}
foreach xci [get_files -quiet *.xci] {
    if {[get_property GENERATE_SYNTH_CHECKPOINT $xci] != 0} {
        error "separate IP synthesis checkpoint is enabled: $xci"
    }
}
update_compile_order -fileset sources_1

puts "LAYA_SYNTH_BEGIN"
flush stdout
launch_runs synth_1 -jobs 1
wait_on_run synth_1
set status [get_property STATUS [get_runs synth_1]]
if {![string match "*Complete*" $status]} {
    error "top synthesis failed: $status"
}
set run_directory [file normalize [get_property DIRECTORY [get_runs synth_1]]]
set run_log [file join $run_directory runme.log]
if {![file exists $run_log]} {
    error "synthesis run log is missing: $run_log"
}
set fd [open $run_log r]
set staged 0
set init_issue ""
while {[gets $fd line] >= 0} {
    if {[regexp {LAYA_DAT_STAGED count=201 verified=201 cwd=(\S+)} $line -> cwd]} {
        if {[file normalize $cwd] eq $run_directory} { set staged 1 }
    }
    if {[regexp -nocase {(readmemh|\.dat).*?(cannot|could not|failed|not found|unable|missing)|(cannot|could not|failed|not found|unable|missing).*?(readmemh|\.dat)} $line]} {
        set init_issue $line
    }
}
close $fd
if {!$staged} {
    error "201 DAT files were not verified in the actual synthesis run directory"
}
if {$init_issue ne ""} {
    error "synthesis reported an initialization-file problem: $init_issue"
}
open_run synth_1
set blackboxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
if {[llength $blackboxes] != 0} {
    error "blackbox cells detected: [llength $blackboxes]"
}
report_utilization -file [file join $report_dir utilization.rpt]
report_utilization -hierarchical -file [file join $report_dir utilization_hierarchical.rpt]
report_timing_summary -file [file join $report_dir timing_summary.rpt]
write_checkpoint -force [file join $report_dir laya_ooc_synth.dcp]
puts "LAYA_SYNTH_DONE status=$status blackboxes=0"
close_project
