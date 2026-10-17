if {[llength $argv]!=3} {error "usage: WORK SOURCE_ROOT SI_WIDTH"}
lassign $argv work root width
set_param general.maxThreads 4
create_project axi_dwidth [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
source [file join $module rtl create_laya_axi_dwidth.tcl]
create_laya_axi_dwidth laya_axi_dwidth_native_v1 $width 32
add_files -fileset sim_1 [file join $module tb laya_axi_dwidth_tb_v1.sv]
set_property verilog_define LAYA_DWIDTH_SI=$width [get_filesets sim_1]
set_property top laya_axi_dwidth_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado axi_dwidth.sim sim_1 behav xsim simulate.log]
set f [open $log r];set text [read $f];close $f
if {[string first FULL_CURRENT_AXI_DWIDTH_PASS $text]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $text]} {error "width converter test failed"}
puts FULL_CURRENT_AXI_DWIDTH_SCRIPT_PASS
close_project
