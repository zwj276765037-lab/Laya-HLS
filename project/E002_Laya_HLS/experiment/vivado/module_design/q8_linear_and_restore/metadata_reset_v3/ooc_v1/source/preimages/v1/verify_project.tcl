if {[llength $argv] != 2} { error "usage: verify_project.tcl RUN_DIR REPORT_DIR" }
lassign $argv run_dir report_dir
set run_dir [file normalize $run_dir]
set report_dir [file normalize $report_dir]
file mkdir $report_dir
set xpr [file join $run_dir vivado q8_same_source_ooc.xpr]
set rtl_dir [file join $run_dir stage rtl]
set ip_dir [file join $run_dir stage ip]
set xdc [file join $run_dir stage constraints q8_joint_tm4tn8_ooc.xdc]
set hook [file join $run_dir stage scripts prepare_dat.tcl]
set_param general.maxThreads 4
open_project $xpr
if {[get_property PART [current_project]] ne "xcu55c-fsvh2892-2L-e"} { error "part mismatch" }
if {[get_property TOP [get_filesets sources_1]] ne "q8_joint_tm4tn8"} { error "top mismatch" }
if {[get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]] ne "-mode out_of_context"} { error "OOC mode missing" }
if {[file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]] ne $hook} { error "DAT pre-hook mismatch" }
set verilog [lsort [glob -nocomplain -directory $rtl_dir *.v]]
set dat [lsort [glob -nocomplain -directory $rtl_dir *.dat]]
set scripts [lsort [glob -nocomplain -directory $rtl_dir *_ip.tcl]]
set xci [lsort [glob -nocomplain -directory $ip_dir *.xci]]
if {[llength $verilog] != 230 || [llength $dat] != 108 || [llength $scripts] != 7 || [llength $xci] != 7} { error "input counts drifted" }
foreach path [concat $verilog $dat $xci [list $xdc $hook]] {
    if {[llength [get_files -quiet $path]] != 1} { error "missing project input: $path" }
}
foreach path $dat {
    if {[get_property FILE_TYPE [get_files $path]] ne "Data Files"} { error "DAT file type mismatch: $path" }
}
set fd [open $xdc r]
set xdc_text [read $fd]
close $fd
if {![regexp {create_clock\s+-name\s+ap_clk\s+-period\s+6\.667\s+\[get_ports\s+ap_clk\]} $xdc_text]} { error "ap_clk 6.667ns constraint mismatch" }
set ips [get_ips -quiet]
if {[llength $ips] != 7} { error "expected seven IP objects, got [llength $ips]" }
foreach path $xci {
    set name [file rootname [file tail $path]]
    set ip [get_ips -quiet $name]
    if {[llength $ip] != 1 || [get_property IS_LOCKED $ip] != 0} { error "IP missing or locked: $name" }
    if {[get_property GENERATE_SYNTH_CHECKPOINT [get_files $path]] != 0} { error "unexpected IP synthesis DCP: $name" }
}
update_compile_order -fileset sources_1
report_compile_order -fileset sources_1 -used_in synthesis -file [file join $report_dir compile_order.rpt]
report_ip_status -file [file join $report_dir ip_status.rpt]
set compiled [get_files -compile_order sources -used_in synthesis]
set names {}
set out [open [file join $report_dir compile_order_libraries.tsv] w]
puts $out "library\tfile_type\tpath"
foreach f $compiled {
    set name [file normalize [get_property NAME $f]]
    lappend names $name
    puts $out "[get_property LIBRARY $f]\t[get_property FILE_TYPE $f]\t$name"
}
close $out
foreach f $verilog {
    if {[lsearch -exact $names [file normalize $f]] < 0} { error "Verilog missing from actual compile order: $f" }
}
puts "Q8_OOC_PROJECT_VERIFIED verilog=230 dat=108 ip=7 actual_compile_files=[llength $compiled]"
close_project
