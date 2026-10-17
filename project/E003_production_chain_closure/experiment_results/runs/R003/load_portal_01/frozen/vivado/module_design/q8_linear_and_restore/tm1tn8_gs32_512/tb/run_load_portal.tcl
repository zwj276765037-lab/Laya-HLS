if {[llength $argv]!=2} {error "usage: WORK SOURCE_ROOT"}
lassign $argv work root
set_param general.maxThreads 4
create_project load_portal [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $root vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
set cache [file join $root vivado module_design hbm_loader_and_cache]
foreach name {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {add_files -norecurse [file join $cache rtl ${name}.sv]}
foreach name {laya_compute_portal_layout_v1 laya_load_portal_binding_v1} {add_files -norecurse [file join $module rtl ${name}.sv]}
add_files -fileset sim_1 [file join $module tb laya_load_portal_tb_v1.sv]
set_property top laya_load_portal_binding_v1 [get_filesets sources_1]
set_property top laya_load_portal_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado load_portal.sim sim_1 behav xsim simulate.log]
set f [open $log r];set text [read $f];close $f
if {[string first FULL_CURRENT_LOAD_PORTAL_PASS $text]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $text]} {error "LOAD portal test failed"}
puts FULL_CURRENT_LOAD_PORTAL_SCRIPT_PASS
close_project
