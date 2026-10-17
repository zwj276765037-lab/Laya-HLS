if {[llength $argv] != 2} { error "usage: synth_ooc.tcl PREPARED_RUN_DIR FRESH_REPORT_DIR" }
lassign $argv run_dir report_dir
set run_dir [file normalize $run_dir]
set report_dir [file normalize $report_dir]
if {[file exists $report_dir]} { error "fresh report directory required: $report_dir" }
file mkdir $report_dir
set_param general.maxThreads 4
open_project [file join $run_dir vivado q8_same_source_ooc.xpr]
if {[get_property PART [current_project]] ne "xcu55c-fsvh2892-2L-e"} { error "part mismatch" }
if {[get_property TOP [get_filesets sources_1]] ne "q8_joint_tm4tn8"} { error "top mismatch" }
if {[llength [get_ips -quiet]] != 7} { error "seven bound FP IP objects are required" }
set hook [file join $run_dir stage scripts prepare_dat.tcl]
if {[file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]] ne $hook} { error "DAT hook missing" }
if {[get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]] ne "-mode out_of_context"} { error "OOC synthesis mode missing" }
update_compile_order -fileset sources_1
puts "Q8_OOC_SYNTH_BEGIN top=q8_joint_tm4tn8"
flush stdout
launch_runs synth_1 -jobs 1
wait_on_run synth_1
set status [get_property STATUS [get_runs synth_1]]
set run_cwd [file normalize [get_property DIRECTORY [get_runs synth_1]]]
set run_log [file join $run_cwd runme.log]
if {![file isfile $run_log]} { error "raw synthesis run log missing: $run_log" }
file copy $run_log [file join $report_dir runme.log]
set staged 0
set init_error ""
set raw [open $run_log r]
set filtered [open [file join $report_dir warnings_init_trim.log] w]
while {[gets $raw line] >= 0} {
    if {[string first "Q8_OOC_DAT_STAGED count=108 verified=108 cwd=$run_cwd" $line] >= 0} { set staged 1 }
    if {[regexp -nocase {warning|critical|error|fatal|readmemh|\.dat|trim|constant|blackbox|memory} $line]} { puts $filtered $line }
    if {[regexp -nocase {(readmemh|\.dat).*?(cannot|could not|failed|not found|unable|missing)|(cannot|could not|failed|not found|unable|missing).*?(readmemh|\.dat)} $line]} { set init_error $line }
}
close $raw
close $filtered
if {!$staged} { error "108 DAT files were not verified in the actual synthesis cwd $run_cwd" }
if {$init_error ne ""} { error "memory initialization error: $init_error" }
if {![string match "*Complete*" $status]} { error "synthesis did not complete: $status" }
open_run synth_1
set blackboxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
set bb [open [file join $report_dir blackboxes.tsv] w]
puts $bb "cell\tref"
foreach cell $blackboxes { puts $bb "[get_property NAME $cell]\t[get_property REF_NAME $cell]" }
close $bb
if {[llength $blackboxes] != 0} { error "blackboxes remain: [llength $blackboxes]" }
set clocks [get_clocks -quiet ap_clk]
if {[llength $clocks] != 1} { error "ap_clk not constrained exactly once" }
write_checkpoint -force [file join $report_dir q8_joint_tm4tn8_ooc_synth.dcp]
report_utilization -file [file join $report_dir utilization.rpt]
report_utilization -hierarchical -file [file join $report_dir utilization_hierarchical.rpt]
report_clocks -file [file join $report_dir clocks.rpt]
check_timing -verbose -file [file join $report_dir check_timing.rpt]
report_timing -unconstrained -max_paths 100 -file [file join $report_dir unconstrained_paths.rpt]
report_timing_summary -file [file join $report_dir timing_summary.rpt]
set ws_report_dir $report_dir
source [file join $run_dir stage scripts report_ws_banks.tcl]
puts "Q8_OOC_SYNTH_DONE blackboxes=0 dat=108 ws_bank_audit=[file join $report_dir ws_summary.tsv]"
close_project
