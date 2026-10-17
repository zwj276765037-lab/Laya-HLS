if {[llength $argv]!=3} {error "usage: static WORK GENERATED_RTL FIXTURE"}
lassign $argv work generated fixture
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
create_project tm4_generated [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set service_files [lsort [glob [file join $generated *.sv]]]
add_files -norecurse $service_files
set_property file_type SystemVerilog [get_files $service_files]
add_files -norecurse [file join $generated laya_tm4_blackbox_smoke.v]
add_files -fileset sim_1 [file join $module tb tm4_generated_controller_tb_v1.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top laya_tm4_blackbox_smoke [get_filesets sources_1]
set_property top tm4_generated_controller_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts TM4_GENERATED_CONTROLLER_STATIC_PASS
close_project
