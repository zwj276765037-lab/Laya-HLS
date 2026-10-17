if {[llength $argv] != 1} { error "usage: create_project.tcl FRESH_RUN_DIR" }
set run_dir [file normalize [lindex $argv 0]]
set rtl_dir [file join $run_dir stage rtl]
set ip_dir [file join $run_dir stage ip]
set xdc [file join $run_dir stage constraints q8_joint_tm4tn8_ooc.xdc]
set hook [file join $run_dir stage scripts prepare_dat.tcl]
set project_dir [file join $run_dir vivado]
if {[file exists $project_dir]} { error "project directory already exists: $project_dir" }
set verilog [lsort [glob -nocomplain -directory $rtl_dir *.v]]
set dat [lsort [glob -nocomplain -directory $rtl_dir *.dat]]
set ip_tcl [lsort [glob -nocomplain -directory $rtl_dir *_ip.tcl]]
set xci [lsort [glob -nocomplain -directory $ip_dir *.xci]]
if {[llength $verilog] != 230 || [llength $dat] != 108 || [llength $ip_tcl] != 7 || [llength $xci] != 7} {
    error "staged Q8 input count mismatch: V=[llength $verilog] DAT=[llength $dat] Tcl=[llength $ip_tcl] XCI=[llength $xci]"
}
if {![file isfile $xdc] || ![file isfile $hook]} { error "clock XDC or DAT hook is missing" }
set_param general.maxThreads 4
create_project q8_same_source_ooc $project_dir -part xcu55c-fsvh2892-2L-e
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
add_files -norecurse -fileset sources_1 $verilog
add_files -norecurse -fileset sources_1 $dat
add_files -norecurse -fileset sources_1 $xci
add_files -norecurse -fileset constrs_1 $xdc
add_files -norecurse -fileset utils_1 $hook
set_property top q8_joint_tm4tn8 [get_filesets sources_1]
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context} [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.TCL.PRE $hook [get_runs synth_1]
foreach file $xci {
    set obj [get_files -quiet $file]
    if {[llength $obj] != 1} { error "XCI not registered exactly once: $file" }
    set_property GENERATE_SYNTH_CHECKPOINT false $obj
    generate_target {synthesis simulation} $obj
}
update_compile_order -fileset sources_1
puts "Q8_OOC_PROJECT_PREPARED xpr=[file join $project_dir q8_same_source_ooc.xpr] V=230 DAT=108 Tcl=7 XCI=7"
close_project
