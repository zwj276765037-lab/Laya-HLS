if {[llength $argv] != 4} {
    error "usage: create_project.tcl RUN_DIR STAGED_RTL XDC THREADS"
}
lassign $argv run_dir rtl_dir xdc threads
set run_dir [file normalize $run_dir]
set rtl_dir [file normalize $rtl_dir]
set xdc [file normalize $xdc]
set_param general.maxThreads $threads

set project_dir [file join $run_dir vivado]
create_project laya_ooc $project_dir -part xcu55c-fsvh2892-2L-e -force
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

set verilog_files [lsort [glob -nocomplain -directory $rtl_dir *.v]]
set data_files [lsort [glob -nocomplain -directory $rtl_dir *.dat]]
set ip_scripts [lsort [glob -nocomplain -directory $rtl_dir *_ip.tcl]]
if {[llength $verilog_files] != 679 || [llength $data_files] != 201 || [llength $ip_scripts] != 13} {
    error "unexpected staged counts: Verilog=[llength $verilog_files] DAT=[llength $data_files] IP_TCL=[llength $ip_scripts]"
}

add_files -norecurse -fileset sources_1 $verilog_files
add_files -norecurse -fileset sources_1 $data_files
add_files -norecurse -fileset constrs_1 $xdc
add_files -norecurse -fileset utils_1 [file join $run_dir prepare_dat.tcl]
set_property top laya_typed_q8_forward [get_filesets sources_1]
set_property -dict [list {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context}] [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.TCL.PRE [file join $run_dir prepare_dat.tcl] [get_runs synth_1]

set index 0
foreach ip_script $ip_scripts {
    incr index
    set ip_name [file rootname [file tail $ip_script]]
    puts "LAYA_IP_BEGIN $index/13 $ip_name"
    flush stdout
    source $ip_script
    set ip [get_ips -quiet $ip_name]
    if {[llength $ip] != 1} {
        error "IP script did not create exactly one $ip_name"
    }
    set xci [get_files -quiet ${ip_name}.xci]
    if {[llength $xci] != 1} {
        error "missing XCI for $ip_name"
    }
    puts "LAYA_IP_DONE $index/13 $ip_name"
    flush stdout
}

update_compile_order -fileset sources_1
puts "LAYA_CREATE_DONE [file join $project_dir laya_ooc.xpr]"
close_project
