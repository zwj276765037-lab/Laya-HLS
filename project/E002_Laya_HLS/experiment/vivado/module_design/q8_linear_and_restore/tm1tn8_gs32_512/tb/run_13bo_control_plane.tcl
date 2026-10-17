if {[llength $argv]!=4} {error "usage WORK FROZEN CONTROL CONTROL_R"}
lassign $argv work frozen control control_r
set_param general.maxThreads 4
create_project control_plane [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach file {laya_13bo_abi_v1 laya_model_identity_13bo_generated_v1 laya_13bo_base_mirror_v1 laya_13bo_model_binding_v1 laya_13bo_request_gate_v1 laya_control_start_gate_v1 laya_13bo_control_plane_v1} {
  add_files -norecurse [file join $module rtl ${file}.sv]
}
add_files -norecurse $control
add_files -norecurse $control_r
add_files -fileset sim_1 [file join $module tb laya_13bo_control_plane_tb_v1.sv]
set_property top laya_13bo_control_plane_v1 [get_filesets sources_1]
set_property top laya_13bo_control_plane_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado control_plane.sim sim_1 behav xsim simulate.log]
set f [open $log r];set body [read $f];close $f
if {[string first FULL_CURRENT_13BO_CONTROL_PLANE_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "13BO control plane assertion failed: $log"
}
puts FULL_CURRENT_13BO_CONTROL_PLANE_SCRIPT_PASS
close_project
