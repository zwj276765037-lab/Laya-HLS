if {[llength $argv]!=6} {
  error "usage: WORK LN_FROZEN NEW_FROZEN FFN_FROZEN LN_FIXTURE BOUND_FIXTURE"
}
lassign $argv work ln_frozen new_frozen ffn_frozen ln_fixture bound_fixture
set_param general.maxThreads 4
create_project ffn0_admission_short_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set ln_rtl [file join $ln_frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512 rtl]
add_files -norecurse [file join $ln_rtl laya_compute_portal_layout_v1.sv]
add_files -norecurse [file join $ln_rtl laya_model_identity_13bo_generated_v1.sv]
add_files -norecurse [file join $new_frozen laya_lnq0_bound_identity_generated_v1.sv]
add_files -norecurse [file join $ffn_frozen laya_ffn0_down_residual_admission_v1.sv]
add_files -fileset sim_1 [file join $new_frozen ffn0_admission_short_tb_v1.sv]
set_property top ffn0_admission_short_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value \
  "-testplusarg LN_FIXTURE=$ln_fixture -testplusarg BOUND_FIXTURE=$bound_fixture" \
  -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
foreach {name directory} [list LN_FIXTURE $ln_fixture BOUND_FIXTURE $bound_fixture] {
  if {![file isdirectory $directory]} {error "missing $name directory"}
}
puts FFN0_SHORT_STATIC_PASS
launch_simulation -mode behavioral -step simulate
puts FFN0_SHORT_SIM_FINISHED
close_project
