if {[llength $argv]!=2} {error "usage: run_act_production.tcl FRESH_WORK FIXTURE"}
lassign $argv work fixture
set work [file normalize $work]
set fixture [file normalize $fixture]
set module [file normalize [file join [file dirname [info script]] ..]]
set root [file normalize [file join $module .. .. .. ..]]
if {[file exists [file join $work vivado]] || ![file isfile [file join $fixture manifest.json]]} {error "fresh work and independent fixture required"}
create_project laya_act_production [file join $work vivado] -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
set sources [list [file join $root vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]]
foreach f {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row} {
 lappend sources [file join $root vivado module_design activation_quantizer rtl ${f}.sv]
}
foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_v1 t4_dual_w_cache_v1} {
 lappend sources [file join $root vivado module_design hbm_loader_and_cache rtl ${f}.sv]
}
foreach f {tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_microbench_v1 tm1tn8_bias_output tm1tn8_axi512_writer laya_act_production_v1} {
 lappend sources [file join $module rtl ${f}.sv]
}
add_files -norecurse -fileset sources_1 $sources
add_files -norecurse -fileset sim_1 [file join $module tb laya_act_production_tb.sv]
source [file join $module tb create_fp_ip.tcl]
set ipdir [file join $root results compute_throughput_optimization_20261010 attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
source [file join $ipdir laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $ipdir laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
set_property top laya_act_production_v1 [get_filesets sources_1]
set_property top laya_act_production_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options -value "-testplusarg FIXTURE=$fixture" -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado laya_act_production.sim sim_1 behav xsim simulate.log]
set f [open $simlog r];set output [read $f];close $f
if {[string first "ACT_PRODUCTION_PASS real_rows=4 quant_error_recovery=1 active_reset_recovery=1 dual_a=1 warm_w=1" $output]<0 || [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {error "ACT production functional failure; see $simlog"}
puts "ACT_PRODUCTION_SCRIPT_PASS"
close_project
