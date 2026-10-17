# M005 representative core implementation from the exact synthesis checkpoint.
if {[llength $argv] != 2} {error "usage: WORK SYNTH_DCP"}
lassign $argv work checkpoint
if {![file isfile $checkpoint]} {error "missing synthesis checkpoint"}
file mkdir $work
cd $work
set_param general.maxThreads 4
open_checkpoint $checkpoint
set clocks [get_clocks core_clk]
if {[llength $clocks] != 1} {error "missing or duplicate 6.667ns core clock"}
opt_design
place_design
report_utilization -file [file join $work utilization_placed.rpt]
report_timing_summary -report_unconstrained \
  -file [file join $work timing_placed.rpt]
route_design
write_checkpoint -force [file join $work representative_routed.dcp]
report_utilization -file [file join $work utilization_routed.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchy_routed.rpt]
report_timing_summary -report_unconstrained \
  -file [file join $work timing_routed.rpt]
report_timing -max_paths 20 -sort_by group \
  -file [file join $work critical_paths_routed.rpt]
report_design_analysis -timing -file [file join $work design_analysis_routed.rpt]
report_drc -file [file join $work drc_routed.rpt]
puts M005_ROUTE_COMPLETE
