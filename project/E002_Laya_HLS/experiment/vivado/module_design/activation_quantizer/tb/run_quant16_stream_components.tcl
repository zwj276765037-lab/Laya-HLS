if {[llength $argv] != 1} {
    error "usage: run_quant16_stream_components.tcl FRESH_WORK"
}
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project quant16_stream_components [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl quant16_slot_banks.sv] \
    [file join $module rtl quant16_amax16.sv]]
add_files -norecurse -fileset sim_1 [list \
    [file join $module tb quant16_slot_banks_tb.sv] \
    [file join $module tb quant16_amax16_tb.sv]]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
foreach {top marker} {
    quant16_slot_banks_tb QUANT16_SLOT_BANKS_PASS
    quant16_amax16_tb QUANT16_AMAX16_PASS
} {
    set_property top $top [get_filesets sim_1]
    update_compile_order -fileset sim_1
    launch_simulation -simset sim_1 -mode behavioral
    close_sim
    set simlog [file join $work vivado quant16_stream_components.sim sim_1 behav xsim simulate.log]
    if {![file isfile $simlog]} { error "$top simulator log missing" }
    set handle [open $simlog r]
    set output [read $handle]
    close $handle
    if {[string first $marker $output] < 0 ||
        [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
        error "$top simulation failed; see $simlog"
    }
    file copy -force $simlog [file join $work ${top}.simulate.log]
    puts "$top SHORT_PASS"
}
close_project
