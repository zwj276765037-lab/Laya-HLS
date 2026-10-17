if {[llength $argv]!=3} {error "usage WORK FROZEN ORIGINAL_CONTROL"}
lassign $argv work frozen original
set_param general.maxThreads 4
create_project base_mirror [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl laya_13bo_abi_v1.sv]
add_files -norecurse [file join $module rtl laya_13bo_base_mirror_v1.sv]
add_files -norecurse $original
add_files -fileset sim_1 [file join $module tb laya_13bo_base_mirror_tb_v1.sv]
set_property top laya_13bo_base_mirror_v1 [get_filesets sources_1]
set_property top laya_13bo_base_mirror_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado base_mirror.sim sim_1 behav xsim simulate.log]
set f [open $log r];set text [read $f];close $f
if {[string first FULL_CURRENT_13BO_BASE_PASS $text]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $text]} {error "base mirror test failed"}
puts FULL_CURRENT_13BO_BASE_SCRIPT_PASS
close_project
