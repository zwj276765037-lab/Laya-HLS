if {[llength $argv]!=2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project executor_adapter_lpv_generated [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [lsort [glob [file join $frozen external adapter_rtl *.v]]]
foreach name {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_admission_owner_layout_v1 laya_controller_transaction_adapter_shell_v1 laya_executor_adapter_lpv_owner_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -fileset sim_1 [file join $module tb laya_executor_adapter_lpv_generated_tb_v1.sv]
set_property top laya_command_provenance_adapter [get_filesets sources_1]
set_property top laya_executor_adapter_lpv_generated_tb_v1 [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_EXECUTOR_ADAPTER_LPV_GENERATED_STATIC_PASS
close_project
