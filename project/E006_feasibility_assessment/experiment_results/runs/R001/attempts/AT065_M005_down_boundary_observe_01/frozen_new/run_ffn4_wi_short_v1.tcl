if {[llength $argv]!=4} {error "usage WORK DOWN_FROZEN NEW_FROZEN G_FIXTURE"}
lassign $argv work down_frozen new_frozen gfixture
set_param general.maxThreads 4
create_project ffn4_wi_short_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $down_frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
add_files -norecurse [file join $module rtl laya_wi_axi_reader_v1.sv]
add_files -fileset sim_1 [file join $new_frozen ffn4_wi_descriptor_short_tb_v1.sv]
set_property top ffn4_wi_descriptor_short_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg GFIXTURE=$gfixture" -objects [get_filesets sim_1]
launch_simulation -mode behavioral
close_sim
set log [file join $work vivado ffn4_wi_short_v1.sim sim_1 behav xsim simulate.log]
set f [open $log r];set body [read $f];close $f
if {[string first FFN4_OLD_MISMATCH_REJECT $body]<0 ||
    [string first FFN4_WI_READER_SHORT_PASS $body]<0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $body]} {
  error "FFN4 Wi short assertion failed: $log"
}
puts FFN4_WI_SHORT_SCRIPT_PASS
close_project
