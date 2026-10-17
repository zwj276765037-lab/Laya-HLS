if {[llength $argv]!=1} {error "usage: WORK"}
set work [lindex $argv 0]
set_param general.maxThreads 4
open_project [file join $work vivado tm4_sync_ps_v2.xpr]
launch_simulation -mode behavioral -step simulate
close_sim
set log [file join $work vivado tm4_sync_ps_v2.sim sim_1 behav xsim simulate.log]
set h [open $log r];set s [read $h];close $h
if {[string first TM4TN8_SYNC_PS_PILOT_PASS $s]<0 ||
    [string first TM4_SYNC_BANKS_PASS $s]<0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $s]} {error "sync PS RTL failed: $log"}
puts TM4_SYNC_PS_RTL_PASS
close_project
