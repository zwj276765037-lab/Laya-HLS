# Tcl control-flow check only. No Vivado commands or original project inputs.
set candidate [file join [file dirname [info script]] create_project.tcl]
set test_root [file normalize [file join /tmp q8_ooc_import_mock_[pid]]]
if {[file exists $test_root]} { error "mock fixture directory already exists" }
file mkdir $test_root
array set ::mock_imported {}
array set ::properties {}
set ::events {}
set ::lock_name ""

proc set_param {args} {}
proc create_project {name dir args} { set ::project_dir $dir; file mkdir $dir }
proc current_project {} { return project }
proc get_runs {name} { return $name }
proc get_filesets {name} { return $name }
proc add_files {args} {}
proc set_property {args} {
    if {[lindex $args 0] eq "-dict"} {
        foreach {key value} [lindex $args 1] { set ::properties($key) $value }
    } else {
        set ::properties([lindex $args 0]) [lindex $args 1]
    }
}
proc get_property {key object} {
    if {$key eq "IS_LOCKED"} { return [expr {$object eq $::lock_name ? 1 : 0}] }
    if {$key eq "IP_FILE"} { return $::mock_imported($object) }
    if {$key eq "IP_OUTPUT_DIR"} {
        return [file join $::project_dir q8_same_source_ooc.gen sources_1 ip $object]
    }
    if {[info exists ::properties($key)]} { return $::properties($key) }
    error "unmocked property $key"
}
proc get_ips {quiet name} {
    if {$quiet ne "-quiet"} { error "unexpected get_ips signature" }
    return [expr {[info exists ::mock_imported($name)] ? $name : ""}]
}
proc get_files {quiet path} {
    if {$quiet ne "-quiet"} { error "unexpected get_files signature" }
    return [expr {[file isfile $path] ? $path : ""}]
}
proc import_ip {srcset fileset path} {
    if {$srcset ne "-srcset" || $fileset ne "sources_1"} { error "unexpected import_ip signature" }
    set name [file rootname [file tail $path]]
    set dir [file join $::project_dir q8_same_source_ooc.srcs sources_1 ip $name]
    file mkdir $dir
    set ::mock_imported($name) [file join $dir ${name}.xci]
    file copy $path $::mock_imported($name)
    lappend ::events "import:$name"
}
proc generate_target {targets obj} { lappend ::events "generate:[file tail $obj]" }
proc update_compile_order {args} {}
proc close_project {} {}
rename exec ::real_exec
proc exec {args} {
    if {[lrange $args 0 5] ne [list /usr/bin/env -u PYTHONHOME -u PYTHONPATH /usr/bin/python3]} {
        error "preflight must use clean system Python environment"
    }
    lappend ::events python_preflight
    return "MOCK_IMPORT_PASS"
}

foreach scenario {pass locked} {
    array unset ::mock_imported
    array set ::mock_imported {}
    array unset ::properties
    array set ::properties {}
    set ::events {}
    set ::lock_name [expr {$scenario eq "locked" ? "ip3" : ""}]
    set run_dir [file join $test_root $scenario]
    foreach dir {stage/rtl stage/ip stage/constraints stage/scripts} { file mkdir [file join $run_dir $dir] }
    for {set i 0} {$i < 230} {incr i} { close [open [file join $run_dir stage rtl [format "v%03d.v" $i]] w] }
    for {set i 0} {$i < 108} {incr i} { close [open [file join $run_dir stage rtl [format "d%03d.dat" $i]] w] }
    for {set i 0} {$i < 7} {incr i} {
        close [open [file join $run_dir stage rtl ip${i}_ip.tcl] w]
        close [open [file join $run_dir stage ip ip${i}.xci] w]
    }
    close [open [file join $run_dir stage constraints q8_joint_tm4tn8_ooc.xdc] w]
    close [open [file join $run_dir stage scripts prepare_dat.tcl] w]
    set ::argv [list $run_dir]
    set failed [catch {source $candidate} message]
    set imports [llength [lsearch -all -glob $::events import:*]]
    set generates [llength [lsearch -all -glob $::events generate:*]]
    set preflight [lsearch -exact $::events python_preflight]
    if {$imports != 7 || $preflight != 7} { error "$scenario: imports/preflight ordering failed: $message events=$::events" }
    if {$scenario eq "pass"} {
        if {$failed || $generates != 7 || [lsearch -glob $::events generate:*] <= $preflight} {
            error "pass scenario failed: $message events=$::events"
        }
    } else {
        if {!$failed || $generates != 0 || ![string match *locked* $message]} {
            error "locked scenario reached generation or missed error: $message events=$::events"
        }
    }
}
file delete -force $test_root
puts "Q8_OOC_IMPORT_MOCK_CONTROL_PASS scenarios=2 imports=7 preflight_before_generation=1 locked_stops=1"
