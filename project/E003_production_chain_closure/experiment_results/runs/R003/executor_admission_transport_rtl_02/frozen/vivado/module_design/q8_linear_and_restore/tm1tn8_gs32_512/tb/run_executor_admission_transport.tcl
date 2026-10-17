if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_admission_transport [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_admission_owner_layout_v1 laya_executor_admission_transport_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_admission_transport_tb_v1.sv]
set_property top laya_executor_admission_transport_v1 [get_filesets sources_1]
set_property top laya_executor_admission_transport_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado executor_admission_transport.sim sim_1 behav xsim simulate.log]
set stream [open $log r]
set content [read $stream]
close $stream
if {[regexp -all -line {^FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_RTL_PASS(?: |$)} $content]!=1 || [regexp -nocase {(^|\n)[ \t]*(Fatal:|ERROR:)} $content]} {
  error "executor admission transport assertion/marker failed: $log"
}
puts FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_SCRIPT_PASS
close_project
