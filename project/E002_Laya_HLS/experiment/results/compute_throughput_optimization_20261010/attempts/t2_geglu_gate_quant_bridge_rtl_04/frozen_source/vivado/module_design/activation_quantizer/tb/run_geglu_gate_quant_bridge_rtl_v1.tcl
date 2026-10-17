if {[llength $argv]!=1} {error "usage: RTL WORK"}
lassign $argv work
set_param general.maxThreads 4
open_project [file join $work vivado gate_quant_bridge.xpr]
launch_simulation -mode behavioral -step simulate
close_sim
set log [file join $work vivado gate_quant_bridge.sim sim_1 behav xsim simulate.log]
set f [open $log r]
set s [read $f]
close $f
if {[string first GEGLU_GATE_QUANT_BRIDGE_PASS $s]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $s]} {error "actual gate-quant bridge RTL failed: $log"}
puts GEGLU_GATE_QUANT_BRIDGE_SCRIPT_PASS
close_project
