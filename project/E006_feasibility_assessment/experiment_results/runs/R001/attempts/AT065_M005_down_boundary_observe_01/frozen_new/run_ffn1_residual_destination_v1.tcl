if {[llength $argv]!=5} {
  error "usage: WORK LN_FROZEN NEW_FROZEN FFN_FROZEN FADD_LEAF"
}
lassign $argv work ln_frozen new_frozen ffn_frozen fadd_leaf
set_param general.maxThreads 4
create_project ffn1_residual_destination_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set ln_rtl [file join $ln_frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512 rtl]
add_files -norecurse [file join $ln_rtl laya_model_identity_13bo_generated_v1.sv]
add_files -norecurse $fadd_leaf
add_files -norecurse [file join $ffn_frozen laya_ffn_fadd_slot_v1.sv]
add_files -norecurse [file join $ffn_frozen laya_ffn0_residual_four_row_v1.sv]
add_files -fileset sim_1 [file join $new_frozen ffn1_residual_destination_tb_v1.sv]
set_property top ffn1_residual_destination_tb_v1 [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FFN1_WRAPPER_DST_STATIC_PASS
launch_simulation -mode behavioral -step simulate
puts FFN1_WRAPPER_DST_SIM_FINISHED
close_project
