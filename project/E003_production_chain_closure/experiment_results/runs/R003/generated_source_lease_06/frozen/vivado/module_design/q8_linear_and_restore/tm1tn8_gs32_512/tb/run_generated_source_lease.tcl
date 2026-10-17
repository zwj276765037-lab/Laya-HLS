if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project generated_source_lease [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_generated_source_lease_tb_v1.sv]
set_property top laya_generated_provenance_portal_v1 [get_filesets sources_1]
set_property top laya_generated_source_lease_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado generated_source_lease.sim sim_1 behav xsim simulate.log]
set stream [open $log r]
set content [read $stream]
close $stream
if {[string first FULL_CURRENT_GENERATED_SOURCE_LEASE_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "generated source lease assertion failed: $log"
}
puts FULL_CURRENT_GENERATED_SOURCE_LEASE_SCRIPT_PASS
close_project
