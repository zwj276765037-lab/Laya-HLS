if {[llength $argv] != 2} { error "usage: recover_reports_from_dcp.tcl SEALED_DCP FRESH_REPORT_DIR" }
lassign $argv dcp report_dir
set dcp [file normalize $dcp]
set report_dir [file normalize $report_dir]
set expected_dcp "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
set expected_report_dir "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_dcp_report_recovery_v1_reports"
set ws_tcl "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_synth_v1_entry_a2/stage/scripts/report_ws_banks.tcl"

proc require_sha256 {path expected} {
    if {![file isfile $path]} { error "bound input missing: $path" }
    set digest [lindex [split [string trim [exec /usr/bin/sha256sum -- $path]]] 0]
    if {$digest ne $expected} { error "bound input SHA256 drift: $path" }
}

if {$dcp ne $expected_dcp || $report_dir ne $expected_report_dir} {
    error "DCP or fresh reports path differs from the reviewed source candidate"
}
if {![catch {file lstat $report_dir statbuf}]} {
    error "fresh reports path already exists: $report_dir"
}
require_sha256 $dcp c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce
require_sha256 $ws_tcl f10f83514749cc3c39d07a83ccd7693dae59c21c42bbb6aabaf2c4e8c421dbd8
file mkdir $report_dir
set_param general.maxThreads 4
open_checkpoint $dcp

set blackboxes [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
set bb [open [file join $report_dir blackboxes.tsv] w]
puts $bb "cell\tref"
foreach cell $blackboxes { puts $bb "[get_property NAME $cell]\t[get_property REF_NAME $cell]" }
close $bb
if {[llength $blackboxes] != 0} { error "blackboxes remain: [llength $blackboxes]" }
if {[llength [get_clocks -quiet ap_clk]] != 1} { error "ap_clk not constrained exactly once" }

report_utilization -file [file join $report_dir utilization.rpt]
report_utilization -hierarchical -file [file join $report_dir utilization_hierarchical.rpt]
report_clocks -file [file join $report_dir clocks.rpt]
check_timing -verbose -file [file join $report_dir check_timing.rpt]
report_timing_summary -report_unconstrained -max_paths 100 -file [file join $report_dir timing_summary_including_unconstrained.rpt]
report_timing_summary -file [file join $report_dir timing_summary.rpt]

set ws_report_dir $report_dir
source $ws_tcl
puts "Q8_DCP_REPORT_RECOVERY_DONE blackboxes=0 ws_bank_audit=[file join $report_dir ws_summary.tsv]"
