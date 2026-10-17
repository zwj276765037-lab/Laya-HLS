if {[llength $argv]!=2} {error "usage: WORK FROZEN"}
lassign $argv work root
set_param general.maxThreads 4
create_project matrix_tensor_ledger [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl tm4tn8_matrix_owner_ledger_v2.sv]
add_files -fileset sim_1 [file join $module tb laya_matrix_tensor_ledger_tb_v2.sv]
set_property top tm4tn8_matrix_owner_ledger_v2 [get_filesets sources_1]
set_property top laya_matrix_tensor_ledger_tb_v2 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado matrix_tensor_ledger.sim sim_1 behav xsim simulate.log]
set stream [open $log r];set content [read $stream];close $stream
if {[string first FULL_CURRENT_MATRIX_TENSOR_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "tensor ledger assertion failed: $log"
}
puts FULL_CURRENT_MATRIX_TENSOR_SCRIPT_PASS
close_project
