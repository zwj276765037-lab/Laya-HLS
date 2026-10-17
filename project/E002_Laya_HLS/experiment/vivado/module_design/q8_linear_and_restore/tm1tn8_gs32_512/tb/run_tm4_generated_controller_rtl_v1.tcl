if {[llength $argv]!=1} {error "usage: RTL WORK"}
set work [file normalize [lindex $argv 0]]
set_param general.maxThreads 4
open_project [file join $work vivado tm4_generated.xpr]
launch_simulation -mode behavioral -step simulate
close_sim
set log [file join $work vivado tm4_generated.sim sim_1 behav xsim simulate.log]
set f [open $log r];set s [read $f];close $f
if {[string first TM4_GENERATED_CONTROLLER_PASS $s]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $s]} {error "actual generated TM4 controller failure: $log"}
puts TM4_GENERATED_CONTROLLER_SCRIPT_PASS
close_project
