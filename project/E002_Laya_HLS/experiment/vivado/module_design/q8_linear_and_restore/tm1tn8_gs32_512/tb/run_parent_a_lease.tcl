if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project parent_a_lease [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
set quant [file join $root vivado module_design activation_quantizer]
add_files -norecurse [file join $module rtl laya_compute_portal_layout_v1.sv]
foreach file {quant_a_row_bank_v1 quant_dual_a_v1} {
  add_files -norecurse [file join $quant rtl ${file}.sv]
}
add_files -norecurse [file join $module rtl laya_parent_a_lease_v2.sv]
add_files -fileset sim_1 [file join $module tb laya_parent_a_lease_tb_v2.sv]
set_property top laya_parent_a_lease_v2 [get_filesets sources_1]
set_property top laya_parent_a_lease_tb_v2 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado parent_a_lease.sim sim_1 behav xsim simulate.log]
set stream [open $log r];set content [read $stream];close $stream
if {[string first FULL_CURRENT_PARENT_A_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "parent A assertion failed: $log"
}
puts FULL_CURRENT_PARENT_A_SCRIPT_PASS
close_project
