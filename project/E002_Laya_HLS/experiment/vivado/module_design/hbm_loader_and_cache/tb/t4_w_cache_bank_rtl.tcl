if {[llength $argv] != 1} {error "usage: t4_w_cache_bank_rtl.tcl FRESH_WORK"}
set work [file normalize [lindex $argv 0]]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
create_project t4_bank_rtl [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [file join $module rtl t4_w_cache_bank_v1.sv]
add_files -norecurse -fileset sim_1 [file join $module tb t4_w_cache_bank_tb_v1.sv]
set_property top t4_w_cache_bank_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado t4_bank_rtl.sim sim_1 behav xsim simulate.log]
set fd [open $simlog r];set output [read $fd];close $fd
if {[string first "T4_W_CACHE_BANK_PASS q_scale_addresses=10496 bias_addresses=328" $output]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {error "bank full-depth RTL failed: $simlog"}
puts "ACT_RTL_BANK_SCRIPT_PASS"
close_project
