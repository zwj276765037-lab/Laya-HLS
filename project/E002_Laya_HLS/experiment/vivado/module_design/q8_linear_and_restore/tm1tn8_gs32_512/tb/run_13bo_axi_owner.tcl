if {[llength $argv]!=2} {error "usage: WORK SOURCE_ROOT"}
lassign $argv work root
set_param general.maxThreads 4
create_project axi_13bo_owner [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
foreach name {laya_axi_owner_v1 laya_axi_13bo_owner_v1} {add_files -norecurse [file join $module rtl ${name}.sv]}
add_files -fileset sim_1 [file join $module tb laya_axi_13bo_owner_tb_v1.sv]
set_property top laya_axi_13bo_owner_v1 [get_filesets sources_1]
set_property top laya_axi_13bo_owner_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado axi_13bo_owner.sim sim_1 behav xsim simulate.log]
set f [open $log r];set text [read $f];close $f
if {[string first FULL_CURRENT_13BO_OWNER_PASS $text]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $text]} {error "13BO AXI owner test failed"}
puts FULL_CURRENT_13BO_OWNER_SCRIPT_PASS
close_project
