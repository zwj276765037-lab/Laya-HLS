if {[llength $argv]!=2} {error "usage: WORK FROZEN"}
lassign $argv work root
set_param general.maxThreads 4
create_project gate_tensor_store [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design activation_quantizer]
foreach f {geglu_gate_tensor_ledger_v2 geglu_gate_window_writer_v2 geglu_gate_tensor_store_v2} {
  add_files -norecurse [file join $module rtl ${f}.sv]
}
add_files -fileset sim_1 [file join $module tb geglu_gate_tensor_store_tb_v2.sv]
set_property top geglu_gate_tensor_store_v2 [get_filesets sources_1]
set_property top geglu_gate_tensor_store_tb_v2 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado gate_tensor_store.sim sim_1 behav xsim simulate.log]
set f [open $log r];set content [read $f];close $f
if {[string first FULL_CURRENT_GATE_TENSOR_STORE_PASS $content]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $content]} {
  error "GATE tensor store assertion failed: $log"
}
puts FULL_CURRENT_GATE_TENSOR_STORE_SCRIPT_PASS
close_project
