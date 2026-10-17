if {[llength $argv] != 2} { error "usage: synth_ooc.tcl PREPARED_RUN_DIR FRESH_REPORT_DIR" }
lassign $argv run_dir report_dir
set run_dir [file normalize $run_dir]
set report_dir [file normalize $report_dir]
if {[file exists $report_dir]} { error "fresh report directory required: $report_dir" }
set run_parts [file split $run_dir]
set report_parts [file split $report_dir]
if {[llength $report_parts] >= [llength $run_parts] &&
    [lrange $report_parts 0 [expr {[llength $run_parts] - 1}]] eq $run_parts} {
    error "report directory must be outside the byte-exact project clone"
}
file mkdir $report_dir
set overlay_dir [file dirname [info script]]
set clone_checker [file join $overlay_dir verify_clone.py]
puts [exec /usr/bin/env -u PYTHONHOME -u PYTHONPATH /usr/bin/python3 \
    $clone_checker --clone $run_dir --out [file join $report_dir clone_preopen.json]]
set_param general.maxThreads 4
open_project [file join $run_dir vivado q8_same_source_ooc.xpr]
if {[get_property PART [current_project]] ne "xcu55c-fsvh2892-2L-e"} { error "part mismatch" }
if {[get_property TOP [get_filesets sources_1]] ne "q8_joint_tm4tn8"} { error "top mismatch" }
if {[llength [get_ips -quiet]] != 7} { error "seven bound FP IP objects are required" }
set hook [file join $run_dir stage scripts prepare_dat.tcl]
if {[file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]] ne $hook} { error "DAT hook missing" }
if {[get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]] ne "-mode out_of_context"} { error "OOC synthesis mode missing" }
if {[string tolower [get_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY [get_runs synth_1]]] ne "none"} {
    error "flatten-hierarchy setting changed"
}
set rtl_dir [file join $run_dir stage rtl]
set staged_verilog [lsort [glob -nocomplain -directory $rtl_dir *.v]]
set staged_dat [lsort [glob -nocomplain -directory $rtl_dir *.dat]]
set staged_ip_tcl [lsort [glob -nocomplain -directory $rtl_dir *_ip.tcl]]
set staged_xci [lsort [glob -nocomplain -directory [file join $run_dir stage ip] *.xci]]
if {[llength $staged_verilog] != 230 || [llength $staged_dat] != 108 ||
    [llength $staged_ip_tcl] != 7 || [llength $staged_xci] != 7} {
    error "clone staged input counts changed"
}
foreach path $staged_dat {
    set files [get_files -quiet $path]
    if {[llength $files] != 1 || [get_property FILE_TYPE $files] ne "Data Files"} {
        error "DAT project membership or type changed: $path"
    }
}
set xdc [file join $run_dir stage constraints q8_joint_tm4tn8_ooc.xdc]
if {[llength [get_files -quiet $xdc]] != 1} { error "OOC clock XDC missing" }
set clock_fd [open $xdc r]
set clock_text [read $clock_fd]
close $clock_fd
if {![regexp {create_clock\s+-name\s+ap_clk\s+-period\s+6\.667\s+\[get_ports\s+ap_clk\]} $clock_text]} {
    error "6.667ns ap_clk source constraint changed"
}
set map_path [file join $report_dir active_ip_import_paths.tsv]
set map [open $map_path w]
puts $map "ip\tstaged_xci\timported_xci\toutput_dir\tis_locked"
foreach staged $staged_xci {
    set name [file rootname [file tail $staged]]
    set ip [get_ips -quiet $name]
    if {[llength $ip] != 1} { error "bound imported IP missing: $name" }
    set locked [get_property IS_LOCKED $ip]
    if {$locked} { error "imported IP locked after relocation: $name" }
    set imported [file normalize [get_property IP_FILE $ip]]
    set expected_imported [file normalize [file join $run_dir vivado q8_same_source_ooc.srcs sources_1 ip $name ${name}.xci]]
    if {$imported ne $expected_imported || ![file isfile $imported]} {
        error "imported XCI is not project-local after relocation: $name"
    }
    set output [file normalize [get_property IP_OUTPUT_DIR $ip]]
    set expected_output [file normalize [file join $run_dir vivado q8_same_source_ooc.gen sources_1 ip $name]]
    if {$output ne $expected_output} { error "IP output path is not clone-local: $name" }
    set obj [get_files -quiet $imported]
    if {[llength $obj] != 1 || [get_property GENERATE_SYNTH_CHECKPOINT $obj] != 0} {
        error "imported XCI property changed: $name"
    }
    puts $map "$name\t$staged\t$imported\t$output\t$locked"
}
close $map
set ip_checker [file join $overlay_dir .. .. source candidates project_local_ip_import_v2 verify_imported_xci.py]
puts [exec /usr/bin/env -u PYTHONHOME -u PYTHONPATH /usr/bin/python3 \
    $ip_checker --check $run_dir $map_path]
update_compile_order -fileset sources_1
set compiled [get_files -compile_order sources -used_in synthesis]
if {[llength $compiled] != 243} { error "actual compile closure changed from 243 files" }
set compile_tsv [file join $report_dir compile_order_libraries_prelaunch.tsv]
set out [open $compile_tsv w]
puts $out "library\tfile_type\tpath"
foreach f $compiled {
    puts $out "[get_property LIBRARY $f]\t[get_property FILE_TYPE $f]\t[file normalize [get_property NAME $f]]"
}
close $out
set compile_checker [file join $overlay_dir verify_actual_compile.py]
puts [exec /usr/bin/env -u PYTHONHOME -u PYTHONPATH /usr/bin/python3 \
    $compile_checker $run_dir $compile_tsv --out [file join $report_dir compile_prelaunch.json]]
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
