if {[llength $argv]!=1} {error "usage attention_tile_build.tcl ATTEMPT"}
set attempt [file normalize [lindex $argv 0]]
set_param general.maxThreads 4
create_project attention_tile [file join $attempt build vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse [lsort [glob [file join $attempt rtl *.v]]]
add_files -norecurse [file join $attempt frozen_source attention_tile_service_v1.sv]
add_files -norecurse -fileset sim_1 [file join $attempt frozen_source attention_tile_tb.sv]
foreach file [lsort [glob [file join $attempt rtl *_ip.tcl]]] {source $file}
set_property top attention_tile_service_v1 [get_filesets sources_1]
set_property top attention_tile_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.elaborate.mt_level off [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -scripts_only
close_project
puts "ATTENTION_SERVICE_TILE_SCRIPTS_PASS"
exit
