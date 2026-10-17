if {[llength $argv] != 2} {error "usage: t4_w_cache_bank_mapped_rtl.tcl FRESH_WORK BANK_DCP"}
lassign $argv work dcp
set work [file normalize $work]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
open_checkpoint $dcp
if {[llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]] != 0} {error "MAPPED_BANK_BLACKBOX"}
write_verilog -mode funcsim [file join $work bank_mapped.v]
close_design
close_project
create_project mapped_bank [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [file join $work bank_mapped.v]
add_files -fileset sim_1 [file join $module tb t4_w_cache_bank_tb_v1.sv]
set_property top t4_w_cache_bank_v1 [get_filesets sources_1]
set_property top t4_w_cache_bank_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado mapped_bank.sim sim_1 behav xsim simulate.log]
set f [open $log r];set output [read $f];close $f
if {[string first "T4_W_CACHE_BANK_PASS" $output]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {error "mapped bank functional failure: $log"}
puts "T4_W_CACHE_BANK_MAPPED_RTL_PASS"
close_project
