if {[llength $argv] != 5} {
    error "usage: verify_project.tcl RUN_DIR STAGED_RTL XDC REPORT_DIR THREADS"
}
lassign $argv run_dir rtl_dir xdc report_dir threads
set run_dir [file normalize $run_dir]
set rtl_dir [file normalize $rtl_dir]
set xdc [file normalize $xdc]
set report_dir [file normalize $report_dir]
set_param general.maxThreads $threads

set xpr [file join $run_dir vivado laya_ooc.xpr]
open_project $xpr
if {[get_property PART [current_project]] ne "xcu55c-fsvh2892-2L-e"} {
    error "project part mismatch"
}
if {[get_property TOP [get_filesets sources_1]] ne "laya_typed_q8_forward"} {
    error "project top mismatch"
}
if {[get_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} [get_runs synth_1]] ne "-mode out_of_context"} {
    error "synthesis run is not out_of_context"
}
if {[file normalize [get_property STEPS.SYNTH_DESIGN.TCL.PRE [get_runs synth_1]]] ne [file join $run_dir prepare_dat.tcl]} {
    error "synthesis DAT pre-hook is not bound to this run"
}
if {![file exists [file join $run_dir prepare_dat.tcl]]} {
    error "synthesis DAT pre-hook file is missing"
}
if {[llength [get_files -quiet [file join $run_dir prepare_dat.tcl]]] != 1} {
    error "synthesis DAT pre-hook is not managed by the project"
}

set v_files [lsort [glob -nocomplain -directory $rtl_dir *.v]]
set d_files [lsort [glob -nocomplain -directory $rtl_dir *.dat]]
set t_files [lsort [glob -nocomplain -directory $rtl_dir *_ip.tcl]]
if {[llength $v_files] != 679 || [llength $d_files] != 201 || [llength $t_files] != 13} {
    error "staged input count mismatch"
}
foreach f [concat $v_files $d_files] {
    if {[llength [get_files -quiet $f]] != 1} {
        error "missing project source $f"
    }
}
foreach f $d_files {
    if {[get_property FILE_TYPE [get_files $f]] ne "Data Files"} {
        error "DAT file type mismatch: $f"
    }
}
if {[llength [get_files -quiet $xdc]] != 1} {
    error "missing OOC clock XDC"
}
set xdc_text [read [set fd [open $xdc r]]]
close $fd
if {![regexp {create_clock\s+-name\s+ap_clk\s+-period\s+6\.667\s+\[get_ports\s+ap_clk\]} $xdc_text]} {
    error "ap_clk 6.667 ns constraint mismatch"
}

set ip_list [get_ips -quiet]
if {[llength $ip_list] != 13} {
    error "expected 13 IP, got [llength $ip_list]"
}
foreach script $t_files {
    set name [file rootname [file tail $script]]
    if {[llength [get_ips -quiet $name]] != 1} {
        error "missing IP $name"
    }
    set xci [get_files -quiet ${name}.xci]
    if {[llength $xci] != 1 || ![file exists [get_property NAME $xci]]} {
        error "missing generated XCI $name"
    }
    if {[get_property GENERATE_SYNTH_CHECKPOINT $xci] != 0} {
        error "IP $name would use a separate synthesis checkpoint"
    }
    if {[get_property IS_LOCKED [get_ips $name]] != 0} {
        error "IP $name is locked"
    }
    set ip_dir [file join $run_dir vivado laya_ooc.gen sources_1 ip $name]
    foreach target {synth sim} {
        if {![file exists [file join $ip_dir $target ${name}.vhd]]} {
            error "IP $name has no $target output product"
        }
    }
}

update_compile_order -fileset sources_1
report_compile_order -fileset sources_1 -used_in synthesis -file [file join $report_dir compile_order.rpt]
report_ip_status -file [file join $report_dir ip_status.rpt]
set compile_files [get_files -compile_order sources -used_in synthesis]
set compile_names {}
foreach f $compile_files { lappend compile_names [file normalize [get_property NAME $f]] }
foreach f $v_files {
    if {[lsearch -exact $compile_names [file normalize $f]] < 0} {
        error "Verilog missing from synthesis compile order: $f"
    }
}
foreach script $t_files {
    set name [file rootname [file tail $script]]
    set product [file normalize [file join $run_dir vivado laya_ooc.gen sources_1 ip $name synth ${name}.vhd]]
    if {[lsearch -exact $compile_names $product] < 0} {
        error "IP synthesis implementation missing from compile order: $name"
    }
}
foreach f $compile_names {
    if {![string match "${run_dir}/*" $f]} {
        error "compile order has a dependency outside this run: $f"
    }
}
puts "LAYA_VERIFY_DONE verilog=[llength $v_files] dat=[llength $d_files] ip=[llength $ip_list] compile=[llength $compile_files]"
close_project
