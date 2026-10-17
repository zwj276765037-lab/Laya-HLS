if {[llength $argv] != 4} {error "usage: act_production_cache_assemble_ooc.tcl WORK ACT07_FROZEN_ROOT EXACT_CACHE_PARENT_EDF EXACT_BANK_EDF"}
lassign $argv work frozen cache_parent_edf bank_edf
set work [file normalize $work]
set frozen [file normalize $frozen]
set_param general.maxThreads 4
create_project -in_memory -part xcu55c-fsvh2892-2L-e
set module [file join $frozen vivado module_design q8_linear_and_restore tm1tn8_gs32_512]
read_verilog -sv [file join $frozen vivado module_design q8_linear_and_restore metadata_reset_v3 r0_numeric_adapter_v1 rtl r0_fp_bits_pkg.sv]
foreach name {quant16_slot_banks quant16_amax16 quant16_half_rne quant16_tiny_div127 quant16_divider_service quant16_stream_row} {
  read_verilog -sv [file join $frozen vivado module_design activation_quantizer rtl ${name}.sv]
}
read_verilog -sv [file join $frozen vivado module_design hbm_loader_and_cache rtl t4_dual_w_cache_stub_v1.sv]
foreach name {tm1tn8_integer_tree_lut tm1tn8_signed_pack_pair tm1tn8_integer_tree_packed tm4tn8_tag_v1 tm4tn8_reserved_store_v1 tm4tn8_fp_restore_v1 tm4tn8_row_pipeline_v1 tm4tn8_microbench_v1 tm1tn8_bias_output tm1tn8_axi512_writer laya_act_production_v1} {
  read_verilog -sv [file join $module rtl ${name}.sv]
}
source [file join $module tb create_fp_ip.tcl]
set ipdir [file join $frozen results compute_throughput_optimization_20261010 attempts quant16_hls_syn_03 work quant16_project solution1 syn verilog]
source [file join $ipdir laya_quant16_functional_fdiv_32ns_32ns_32_8_no_dsp_1_ip.tcl]
source [file join $ipdir laya_quant16_functional_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
synth_design -top laya_act_production_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none -directive RuntimeOptimized -resource_sharing off
set cache [get_cells -hierarchical -filter {NAME == "weight_cache"}]
if {[llength $cache]!=1 || ![get_property IS_BLACKBOX $cache] || [get_property REF_NAME $cache] ne "t4_dual_w_cache_v1"} {error "ACT_CACHE_STUB_BOUNDARY"}
write_checkpoint [file join $work act_parent_stub_synth.dcp]
# Export this actual OOC parent, then use the proven exact-bank structural flow.
write_edif [file join $work laya_act_production_v1.edf]
close_design
close_project
file copy [file normalize $cache_parent_edf] [file join $work t4_dual_w_cache_v1.edf]
file copy [file normalize $bank_edf] [file join $work t4_w_cache_bank_v1.edf]
read_edif [file join $work t4_w_cache_bank_v1.edf]
read_edif [file join $work t4_dual_w_cache_v1.edf]
read_edif [file join $work laya_act_production_v1.edf]
link_design -top laya_act_production_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context
set cache [get_cells -hierarchical -filter {NAME == "weight_cache"}]
if {[llength $cache]!=1 || [get_property IS_BLACKBOX $cache]} {error "ACT_CACHE_REAL_BOUNDARY"}
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
set banks [get_cells -hierarchical -filter {REF_NAME == t4_w_cache_bank_v1 || ORIG_REF_NAME == t4_w_cache_bank_v1}]
set urams [llength [get_cells -hierarchical -filter {REF_NAME =~ URAM288*}]]
set ram36 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB36E2}]]
set ram18 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB18E2}]]
if {$blackboxes!=0 || [llength $banks]!=32 || $urams!=384 || $ram36<192 || $ram18<64} {error "ACT_CACHE_ASSEMBLY_FAIL BB=$blackboxes BANKS=[llength $banks] URAM=$urams RAMB36=$ram36 RAMB18=$ram18"}
set f [open [file join $work bank_cell_mapping.txt] w]
foreach bank [lsort [get_property NAME $banks]] {puts $f "$bank <- exact bank DCP export"}
close $f
set xdc [open [file join $work clock.xdc] w]
puts $xdc "create_clock -name clk -period 6.667 \[get_ports clk\]"
close $xdc
read_xdc [file join $work clock.xdc]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -delay_type max -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work act_production_synth.dcp]
write_verilog -mode funcsim [file join $work act_production_synth.v]
puts "ACT_PRODUCTION_ASSEMBLED_OOC_PASS cache_full_banks=32 URAM=384 blackboxes=0 structural_edif=1"
close_project
