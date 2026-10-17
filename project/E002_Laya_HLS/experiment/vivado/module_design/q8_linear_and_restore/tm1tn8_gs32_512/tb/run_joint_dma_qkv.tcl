if {[llength $argv] != 6} {
    error "usage: run_joint_dma_qkv.tcl HLS_VERILOG_DIR WRAPPER_DIR GENERATED_TB_DIR INPUT_DIR VECTOR_DIR FRESH_WORK"
}
lassign $argv hls wrapper generated inputs vectors work
set hls [file normalize $hls]
set wrapper [file normalize $wrapper]
set generated [file normalize $generated]
set inputs [file normalize $inputs]
set vectors [file normalize $vectors]
set work [file normalize $work]
if {![file isdirectory $hls] || ![file isdirectory $work] ||
    [file exists [file join $work vivado]] ||
    ![file isfile [file join $hls q8_tm1tn8_joint_dma.v]] ||
    ![file isfile [file join $wrapper q8_tm1tn8_gs32_512.sv]] ||
    ![file isfile [file join $generated tm1tn8_joint_dma_qkv_tb.sv]] ||
    ![file isfile [file join $inputs manifest.json]] ||
    ![file isfile [file join $vectors manifest.json]]} {
    error "actual joint HLS/wrapper/QKV TB/inputs/gold and fresh work required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm1tn8_joint_dma_qkv [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
set hls_verilog [glob -nocomplain -directory $hls *.v]
if {[llength $hls_verilog] < 2} { error "incomplete joint HLS RTL" }
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
add_files -norecurse -fileset sim_1 [list \
    [file join $module tb tm1tn8_axi_memory_slave.sv] \
    [file join $generated tm1tn8_joint_dma_qkv_tb.sv]]
source [file join $module tb create_fp_ip.tcl]
set_property top q8_tm1tn8_gs32_512 [get_filesets sources_1]
set_property top tm1tn8_joint_dma_qkv_tb [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg INPUT_DIR=$inputs -testplusarg VEC_DIR=$vectors" \
    -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM1TN8_JOINT_DMA_QKV_SIM_BEGIN"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm1tn8_joint_dma_qkv.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "joint DMA QKV simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
if {[string first "TM1TN8_JOINT_DMA_QKV_PASS" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "joint DMA QKV simulation did not pass; see $simlog"
}
puts "TM1TN8_JOINT_DMA_QKV_SIM_END"
close_project
