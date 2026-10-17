if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT CONTROL"}
lassign $argv work root control
set_param general.maxThreads 4
create_project model_binding [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_model_identity_13bo_generated_v1 laya_13bo_abi_v1 laya_13bo_base_mirror_v1 laya_13bo_model_binding_v1 laya_13bo_request_gate_v1} {
  add_files -norecurse [file join $module rtl ${name}.sv]
}
add_files -norecurse $control
add_files -fileset sim_1 [file join $module tb laya_13bo_model_binding_tb_v1.sv]
set_property top laya_13bo_request_gate_v1 [get_filesets sources_1]
set_property top laya_13bo_model_binding_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado model_binding.sim sim_1 behav xsim simulate.log]
set stream [open $log r];set content [read $stream];close $stream
if {[string first FULL_CURRENT_13BO_MODEL_BINDING_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "13BO model binding assertion failed: $log"
}
puts FULL_CURRENT_13BO_MODEL_BINDING_SCRIPT_PASS
close_project
