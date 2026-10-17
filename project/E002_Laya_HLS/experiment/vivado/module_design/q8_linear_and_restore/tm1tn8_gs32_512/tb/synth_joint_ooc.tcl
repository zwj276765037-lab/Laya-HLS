if {[llength $argv] != 3} {
    error "usage: synth_joint_ooc.tcl HLS_VERILOG_DIR WRAPPER_DIR FRESH_WORK"
}
lassign $argv hls wrapper work
set hls [file normalize $hls]
set wrapper [file normalize $wrapper]
set work [file normalize $work]
if {![file isdirectory $hls] || ![file isdirectory $work] ||
    ![file isfile [file join $hls q8_tm1tn8_joint_dma.v]] ||
    ![file isfile [file join $wrapper q8_tm1tn8_gs32_512.sv]] ||
    ![file isfile [file join $wrapper manifest.json]] ||
    [file exists [file join $work vivado]]} {
    error "HLS joint RTL, generated wrapper and fresh work required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set hls_verilog [glob -nocomplain -directory $hls *.v]
if {[llength $hls_verilog] < 2} { error "incomplete HLS Verilog directory" }
create_project tm1tn8_joint_ooc [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 $hls_verilog
set hls_ip_dir [file join [file dirname $hls] ip hdl ip]
set hls_xci [glob -nocomplain -directory $hls_ip_dir */*.xci]
if {[llength $hls_xci] != 4} { error "four generated HLS FP subcores required" }
add_files -norecurse -fileset sources_1 $hls_xci
foreach xci $hls_xci {
    set ip_file [get_files -quiet [file tail $xci]]
    if {[llength $ip_file] != 1} { error "HLS FP subcore import failed: $xci" }
    set_property generate_synth_checkpoint false $ip_file
    generate_target {synthesis simulation} $ip_file
}
add_files -norecurse -fileset sources_1 [list \
    [file join $wrapper q8_tm1tn8_gs32_512.sv] \
    [file join $module rtl tm1tn8_hls_control.sv] \
    [file join $module rtl tm1tn8_integer_tree.sv] \
    [file join $module rtl tm1tn8_fp_restore.sv] \
    [file join $module rtl tm1tn8_reserved_store.sv] \
    [file join $module rtl tm1tn8_arithmetic_pipeline.sv] \
    [file join $module rtl tm1tn8_ps_controller.sv] \
    [file join $module rtl tm1tn8_bias_output.sv] \
    [file join $module rtl tm1tn8_axi512_writer.sv] \
    [file join $module rtl tm1tn8_writer_bridge.sv] \
    [file join $module rtl tm1tn8_trace_axi32_writer.sv] \
    [file join $module rtl tm1tn8_joint_bridge.sv]]
set hls_data [glob -nocomplain -directory $hls *.dat *.mem]
if {[llength $hls_data]} {
    add_files -norecurse -fileset sources_1 $hls_data
}
source [file join $module tb create_fp_ip.tcl]
add_files -norecurse -fileset constrs_1 \
    [file join $wrapper q8_tm1tn8_gs32_512.xdc]
set_property top q8_tm1tn8_gs32_512 [get_filesets sources_1]
update_compile_order -fileset sources_1
puts "TM1TN8_JOINT_OOC_BEGIN"
synth_design -top q8_tm1tn8_gs32_512 \
    -part xcu55c-fsvh2892-2L-e -mode out_of_context \
    -flatten_hierarchy rebuilt
set blackboxes [get_cells -hier -quiet -filter {IS_BLACKBOX == 1}]
if {[llength $blackboxes]} {
    puts "TM1TN8_JOINT_BLACKBOX $blackboxes"
    error "joint OOC has blackboxes"
}
report_utilization -file [file join $work utilization.rpt]
report_timing_summary -file [file join $work timing_summary.rpt]
write_checkpoint -force [file join $work joint_ooc.dcp]
puts "TM1TN8_JOINT_OOC_PASS"
close_project
