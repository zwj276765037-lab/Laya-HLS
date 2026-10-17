if {[llength $argv]!=2} {error "usage: WORK {pilot|full}"}
lassign $argv work mode
if {$mode!="pilot" && $mode!="full"} {error "bad mode"}
set_param general.maxThreads 4
open_project [file join $work vivado gqd0_chain_tb_v1.xpr]
set options [get_property xsim.simulate.xsim.more_options [get_filesets sim_1]]
regsub -all { -testplusarg PILOT} $options {} options
if {$mode=="pilot"} {append options " -testplusarg PILOT"}
set_property -name xsim.simulate.xsim.more_options -value $options -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step simulate
close_sim
set log [file join $work vivado gqd0_chain_tb_v1.sim sim_1 behav xsim simulate.log]
set f [open $log r];set s [read $f];close $f
set marker [expr {$mode=="pilot" ? "TM4_MATRIX_RESIDENT_PILOT_PASS" : "GQD0_CHAIN_PASS"}]
if {[string first $marker $s]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $s]} {error "GQD0 $mode failed: $log"}
puts GQD0_SCRIPT_PASS
close_project
