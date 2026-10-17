if {[llength $argv] != 6} {
    error "usage: run_tm4tn8_real_matrix.tcl FRESH_WORK STREAMS ROWS K N {lut|packed}"
}
lassign $argv work streams rows K N candidate
set work [file normalize $work]
set streams [file normalize $streams]
if {$candidate ne "lut" && $candidate ne "packed"} {
    error "candidate must be lut or packed"
}
if {![file isdirectory $work] || [file exists [file join $work vivado]] ||
    ![file isfile [file join $streams manifest.json]]} {
    error "fresh work and independent streams required"
}
if {!((($rows == 1) && ($K == 256) && ($N == 2)) ||
      (($rows == 4) &&
       ((($K == 1024) && ($N == 3072 || $N == 5248)) ||
        (($K == 2624) && ($N == 1024)))))} {
    error "unsupported real TM4 shape"
}
set module [file normalize [file join [file dirname [info script]] ..]]
create_project tm4tn8_real_matrix [file join $work vivado] \
    -part xcu55c-fsvh2892-2L-e
set_param general.maxThreads 4
add_files -norecurse -fileset sources_1 [list \
    [file join $module rtl tm1tn8_integer_tree_lut.sv] \
    [file join $module rtl tm1tn8_signed_pack_pair.sv] \
    [file join $module rtl tm1tn8_integer_tree_packed.sv] \
    [file join $module rtl tm4tn8_tag_v1.sv] \
    [file join $module rtl tm4tn8_reserved_store_v1.sv] \
    [file join $module rtl tm4tn8_fp_restore_v1.sv] \
    [file join $module rtl tm4tn8_row_pipeline_v1.sv] \
    [file join $module rtl tm4tn8_sync_bank_v2.sv] \
    [file join $module rtl tm4tn8_sync_ps_front_v2.sv]]
add_files -norecurse -fileset sim_1 \
    [file join $module tb tm4tn8_sync_ps_real_matrix_tb_v2.sv]
source [file join $module tb create_fp_ip.tcl]
set_property top tm4tn8_sync_ps_front_v2 [get_filesets sources_1]
set top [expr {$candidate eq "packed" ?
                "tm4tn8_real_matrix_packed_tb" : "tm4tn8_sync_ps_real_matrix_tb_v2"}]
set_property top $top [get_filesets sim_1]
set_property target_simulator XSim [current_project]
set_property xsim.simulate.runtime {all} [get_filesets sim_1]
set_property -name xsim.simulate.xsim.more_options \
    -value "-testplusarg TM4_STREAM_DIR=$streams -testplusarg ROWS=$rows -testplusarg K=$K -testplusarg N=$N" \
    -objects [get_filesets sim_1]
update_compile_order -fileset sim_1
puts "TM4TN8_REAL_MATRIX_BEGIN rows=$rows K=$K N=$N candidate=$candidate"
launch_simulation -simset sim_1 -mode behavioral
close_sim
set simlog [file join $work vivado tm4tn8_real_matrix.sim sim_1 behav xsim simulate.log]
if {![file isfile $simlog]} { error "real TM4 simulator log missing" }
set handle [open $simlog r]
set output [read $handle]
close $handle
set candidate_bit [expr {$candidate eq "packed" ? 1 : 0}]
if {[string first "TM4TN8_SYNC_REAL_MATRIX_PASS rows=$rows K=$K N=$N" $output] < 0 ||
    [string first "candidate=$candidate_bit" $output] < 0 ||
    [regexp {(^|\n)Fatal:|(^|\n)ERROR:} $output]} {
    error "real TM4 simulation did not pass; see $simlog"
}
puts "TM4TN8_REAL_MATRIX_END"
close_project
