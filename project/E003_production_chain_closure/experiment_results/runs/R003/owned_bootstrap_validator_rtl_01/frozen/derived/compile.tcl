if {[llength $argv] != 3} {error "usage WORK FROZEN MODULE"}
lassign $argv work frozen dut_module
set_param general.maxThreads 4
create_project owned_bootstrap_validator [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set tb [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512 tb]
add_files -norecurse [lsort [glob [file join $frozen external program_rtl *.v]]]
add_files -fileset sim_1 [file join $tb laya_owned_bootstrap_validator_tb_v1.sv]
set_property include_dirs [list [file join $frozen derived]] [get_filesets sim_1]
set_property top $dut_module [get_filesets sources_1]
set_property top laya_owned_bootstrap_validator_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_OWNED_BOOTSTRAP_VALIDATOR_STATIC_PASS
close_project
