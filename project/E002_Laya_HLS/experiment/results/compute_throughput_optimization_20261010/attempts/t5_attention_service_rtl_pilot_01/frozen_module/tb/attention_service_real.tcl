if {[llength $argv] != 4} {error "usage: attention_service_real.tcl WORK HLS FIXTURE ROWS"}
lassign $argv work hls fixture rows
set work [file normalize $work]
set hls [file normalize $hls]
set fixture [file normalize $fixture]
set module [file normalize [file join [file dirname [info script]] ..]]
create_project attention_service_real [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
set rtl [file join $hls hls_project solution1 syn verilog]
add_files -norecurse [lsort [glob [file join $rtl *.v]]]
add_files -norecurse -fileset sim_1 [file join $module tb attention_service_tb.sv]
add_files -norecurse -fileset sim_1 [file join $module tb attention_fp_monitor.sv]
exec python3 [file join $module tb attention_generate_monitors.py] $rtl [file join $work attention_fp_monitors.svh]
set_property include_dirs $work [get_filesets sim_1]
foreach file [lsort [glob [file join $rtl *_ip.tcl]]] {source $file}
set_property top laya_attention_service [get_filesets sources_1]
set_property top attention_service_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property xsim.elaborate.xelab.more_options {-mt off} [get_filesets sim_1]
set_property xsim.simulate.xsim.more_options "-testplusarg FIXTURE=$fixture -testplusarg ROWS=$rows" [get_filesets sim_1]
update_compile_order -fileset sim_1
# HLS memories read these files relative to the simulator working directory.
set simdir [file join $work vivado attention_service_real.sim sim_1 behav xsim]
file mkdir $simdir
foreach file [glob [file join $rtl *.dat]] {file copy -force $file $simdir}
puts "ATTENTION_SERVICE_RTL_BEGIN rows=$rows"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set log [file join $simdir simulate.log]
set fp [open $log r];set data [read $fp];close $fp
if {[string first "ATTENTION_SERVICE_RTL_PASS rows=$rows keys128 D64" $data]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $data]} {
 error "Attention RTL failed; see $log"
}
puts "ATTENTION_SERVICE_RTL_END rows=$rows"
close_project
