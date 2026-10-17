if {[llength $argv]!=3} {error "usage WORK FROZEN FIXTURE"}
lassign $argv work frozen fixture
set_param general.maxThreads 4
create_project layernorm_producer_portal [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_model_identity_13bo_generated_v1 laya_compute_portal_layout_v1 laya_generated_provenance_layout_v1 laya_private_fifo2_v1 laya_generated_provenance_v1 laya_generated_provenance_hub_v1 laya_generated_provenance_portal_v1 laya_generated_store_monitor_v1 laya_generated_provenance_axi_portal_v1 laya_layernorm_producer_portal_shell_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
set engine [file join $frozen external layernorm_producer_rtl]
add_files -norecurse [lsort [glob [file join $engine *.v]]]
foreach script [lsort [glob [file join $engine *_ip.tcl]]] {source $script}
add_files -fileset sim_1 [file join $module tb laya_layernorm_producer_portal_shell_tb_v1.sv]
set_property top laya_layernorm_producer_portal_shell_v1 [get_filesets sources_1]
set_property top laya_layernorm_producer_portal_shell_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FULL_CURRENT_LAYERNORM_PRODUCER_PORTAL_STATIC_PASS
close_project
