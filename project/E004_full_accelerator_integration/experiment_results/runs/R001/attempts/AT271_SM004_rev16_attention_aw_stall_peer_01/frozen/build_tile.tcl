if {[llength $argv]!=1} {error "usage build_tile.tcl ATTEMPT"}
set attempt [file normalize [lindex $argv 0]]
set_param general.maxThreads 4
create_project attention_final_tile [file join $attempt work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [lsort [glob [file join $attempt frozen rtl *.v]]]
foreach name {attention_tile_service_prefetch_v1.sv t4_w_reader_port_v1.sv tm1tn8_axi512_writer.sv laya_attention_final_tile_adapter_v1.sv} {
 add_files -norecurse [file join $attempt frozen $name]
}
add_files -norecurse -fileset sim_1 [file join $attempt frozen laya_attention_final_tile_tb.sv]
foreach file [lsort [glob [file join $attempt frozen rtl *_ip.tcl]]] {source $file}
set_property top laya_attention_final_tile_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.elaborate.mt_level off [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -scripts_only
close_project
puts "ATT_FINAL_TILE_SCRIPTS_PASS"
exit
