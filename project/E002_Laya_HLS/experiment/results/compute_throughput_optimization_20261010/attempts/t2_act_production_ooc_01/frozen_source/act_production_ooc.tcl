if {[llength $argv] != 2} {error "usage: act_production_ooc.tcl WORK ACT06_FROZEN_ROOT"}
lassign $argv work frozen
set work [file normalize $work]
set frozen [file normalize $frozen]
set_param general.maxThreads 4
create_project act_production_ooc [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
read_verilog -sv [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach name {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row} {
  read_verilog -sv [file join $frozen vivado module_design activation_quantizer rtl ${name}.sv]
}
foreach name {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_dual_w_cache_v1} {
  read_verilog -sv [file join $frozen vivado module_design hbm_loader_and_cache rtl ${name}.sv]
}
foreach name {tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_microbench_v1 tm1tn8_bias_output tm1tn8_axi512_writer laya_act_production_v1} {
  read_verilog -sv [file join $module rtl ${name}.sv]
}
source [file join $module tb create_fp_ip.tcl]
set ipdir [file join $frozen results compute_throughput_optimization_20261010 attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
source [file join $ipdir laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $ipdir laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set xdc [open [file join $work clock.xdc] w]
puts $xdc "create_clock -name ap_clk -period 6.667 \[get_ports clk\]"
close $xdc
read_xdc [file join $work clock.xdc]
synth_design -top laya_act_production_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
if {$blackboxes != 0} {error "ACT_OOC_UNEXPECTED_BLACKBOX count=$blackboxes"}
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -delay_type max -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work act_production_synth.dcp]
puts "ACT_PRODUCTION_OOC_PASS blackboxes=0"
close_project
exit
