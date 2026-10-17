if {[llength $argv] != 2} {error "usage: FRESH_WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project lnq_wi_row [file join $work vivado] -part xcu55c-fsvh2892-2L-e
foreach ip {ln_sqrt_ip
  laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip
  laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip
  create_fp_ip} {
  source [file join $frozen ${ip}.tcl]
}
foreach path [glob -nocomplain [file join $frozen attention*.v]] {
  read_verilog $path
}
foreach name {ln_mul.v ln_div.v ln_sqrt.v ln_add.v
  laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1.v
  laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1.v} {
  read_verilog [file join $frozen $name]
}
read_verilog -sv [file join $frozen r0_fp_bits_pkg.sv]
foreach name {ln_add_stream.sv
  quant16_slot_banks.sv quant16_amax16.sv quant16_half_rne.sv
  quant16_tiny_div127.sv quant16_divider_service.sv
  quant16_stream_row.sv laya_ln_row_v1.sv laya_lnq_row_v1.sv
  t4_w_reader_port_v1.sv t4_three_port_reader_v1.sv
  t4_aux_bias_reader_v1.sv t4_w_cache_bank_v1.sv t4_dual_w_cache_v1.sv
  tm1tn8_integer_tree_lut.sv tm1tn8_signed_pack_pair.sv
  tm1tn8_integer_tree_packed.sv tm4tn8_tag_v1.sv
  tm4tn8_reserved_store_v1.sv tm4tn8_fp_restore_v1.sv
  tm4tn8_row_pipeline_v1.sv tm4tn8_sync_bank_v2.sv
  tm4tn8_sync_ps_front_v2.sv laya_lnq_wi_row_v1.sv} {
  read_verilog -sv [file join $frozen $name]
}
add_files -fileset sim_1 [file join $frozen laya_lnq_wi_row_v1_tb.sv]
set_property top laya_lnq_wi_row_v1 [get_filesets sources_1]
set_property top laya_lnq_wi_row_v1_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
update_compile_order -fileset sim_1
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts LNQ_WI_TB_ELAB_PASS
close_project
