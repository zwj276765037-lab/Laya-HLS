if {[llength $argv]!=3} {error "usage: WORK ROOT FIXTURE"}
lassign $argv work root fixture
set_param general.maxThreads 4
create_project executor_adapter_lpv_owner [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_executor_adapter_lpv_owner_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_adapter_lpv_owner_tb_v1.sv]
set_property top laya_executor_adapter_lpv_owner_v1 [get_filesets sources_1]
set_property top laya_executor_adapter_lpv_owner_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set path [file join $work vivado executor_adapter_lpv_owner.sim sim_1 behav xsim simulate.log]
set f [open $path r]
set body [read $f]
close $f
if {[string first FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "adapter LPV sidecar assertion failed: $path"
}
puts FULL_CURRENT_EXECUTOR_ADAPTER_LPV_OWNER_SCRIPT_PASS
close_project
