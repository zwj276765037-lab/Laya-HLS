if {[llength $argv]!=2} {error "usage WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project gate_quant_decode [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl laya_compute_portal_layout_v1.sv]
add_files -norecurse [file join $module rtl laya_gate_quant_portal_decode_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_gate_quant_portal_decode_tb_v1.sv]
set_property top laya_gate_quant_portal_decode_v1 [get_filesets sources_1]
set_property top laya_gate_quant_portal_decode_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado gate_quant_decode.sim sim_1 behav xsim simulate.log]
set f [open $log r];set body [read $f];close $f
if {[string first FULL_CURRENT_GATE_QUANT_PORTAL_DECODE_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {error "G/Q decoder assertion failed: $log"}
puts FULL_CURRENT_GATE_QUANT_PORTAL_DECODE_SCRIPT_PASS
close_project
