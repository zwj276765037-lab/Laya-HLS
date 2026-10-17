if {[llength $argv] != 1} { error "usage: run_quant16_slot_banks.tcl FRESH_WORK" }
set work [file normalize [lindex $argv 0]]
if {![file isdirectory $work] || [file exists [file join $work vivado]]} {
    error "fresh existing work directory required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project quant16_slot_banks [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [file join $module rtl quant16_slot_banks.sv]
add_files -norecurse -fileset sim_1 [file join $module tb quant16_slot_banks_tb.sv]
set_property top quant16_slot_banks [get_filesets sources_1]
set_property top quant16_slot_banks_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado quant16_slot_banks.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "slot bank simulation log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "QUANT16_SLOT_BANKS_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "slot bank simulation failed; see $simlog"
}
puts "QUANT16_SLOT_BANKS_SIM_END"
close_project
