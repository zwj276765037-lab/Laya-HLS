if {[llength $argv]!=1} {error "usage: run_tm4_writer_seven_shapes.tcl FRESH_WORK"}
set work [file normalize [lindex $argv 0]]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
create_project writer_seven [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [file join $module rtl tm4tn8_axi512_writer_v1.sv]
add_files -fileset sim_1 [file join $module tb tm4_writer_seven_shapes_tb.sv]
set_property top tm4tn8_axi512_writer_v1 [get_filesets sources_1]
set_property top tm4_writer_seven_shapes_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado writer_seven.sim sim_1 behav xsim simulate.log]
set f [open $log r];set output [read $f];close $f
if {[string first TM4_WRITER_SEVEN_SHAPES_PASS $output]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {error "seven shape writer failure: $log"}
puts TM4_WRITER_SEVEN_SHAPES_SCRIPT_PASS
close_project
