if {[llength $argv]!=2} {error "usage WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project wi_reader [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl laya_wi_axi_reader_v1.sv]
add_files -fileset sim_1 [file join $module tb laya_wi_axi_reader_tb_v1.sv]
set_property top laya_wi_axi_reader_v1 [get_filesets sources_1]
set_property top laya_wi_axi_reader_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado wi_reader.sim sim_1 behav xsim simulate.log]
set f [open $log r];set body [read $f];close $f
if {[string first FULL_CURRENT_WI_AXI_READER_PASS $body]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {error "WI reader assertion failed: $log"}
puts FULL_CURRENT_WI_AXI_READER_SCRIPT_PASS
close_project
