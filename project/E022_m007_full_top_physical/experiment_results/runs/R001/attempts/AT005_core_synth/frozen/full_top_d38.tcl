# Full, unchanged production kernel. Each stage can resume a source-bound DCP.
set stage [lindex $argv 0]
set at [file normalize [lindex $argv 1]]
set run [file normalize [lindex $argv 2]]
set part xcu55c-fsvh2892-2L-e
set top laya_m007_single_parent_v3
set cp [file join $run checkpoints]
file mkdir $cp
file mkdir [file join $at reports]
set_param general.maxThreads [expr {$stage in {synth core_synth facade_synth facade_link resident_synth parent_synth full_link} ? 1 : 4}]

proc save_text {path text} {
 set f [open $path w]; puts $f $text; close $f
}
proc required_report {name script} {
 global at
 puts "M007_D38_REPORT_BEGIN $name"
 if {[catch {uplevel 1 $script} result options]} {
  save_text [file join $at reports ${name}.error.txt] $result
  return -options $options $result
 }
 puts "M007_D38_REPORT_END $name"
}
proc optional_report {name script} {
 global at
 if {[catch {uplevel 1 $script} result]} {
  save_text [file join $at reports ${name}.unavailable.txt] $result
 }
}
proc full_reports {placed routed} {
 global at
 set out [file join $at reports]
 required_report utilization {report_utilization -file [file join $out utilization.rpt]}
 required_report hierarchical_utilization {report_utilization -hierarchical -file [file join $out utilization_hierarchical.rpt]}
 required_report ram {report_ram_utilization -file [file join $out ram_utilization.rpt]}
 required_report clocks {report_clocks -file [file join $out clocks.rpt]}
 required_report check_timing {check_timing -verbose -file [file join $out check_timing.rpt]}
 required_report timing_summary {report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $out timing_summary.rpt]}
 required_report setup_paths {report_timing -delay_type max -max_paths 50 -sort_by group -input_pins -nets -file [file join $out setup_paths.rpt]}
 required_report hold_paths {report_timing -delay_type min -max_paths 50 -sort_by group -input_pins -nets -file [file join $out hold_paths.rpt]}
 required_report drc {report_drc -file [file join $out drc.rpt]}
 optional_report methodology {report_methodology -file [file join $out methodology.rpt]}
 optional_report clock_utilization {report_clock_utilization -file [file join $out clock_utilization.rpt]}
 set bb [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
 set latches [get_cells -quiet -hierarchical -filter {REF_NAME =~ LD*}]
 set f [open [file join $out netlist_checks.tsv] w]
 puts $f "blackboxes\t[llength $bb]"
 puts $f "latches\t[llength $latches]"
 puts $f "ports\t[llength [get_ports]]"
 puts $f "clock_count\t[llength [get_clocks]]"
 puts $f "blackbox_cells\t$bb"
 puts $f "latch_cells\t$latches"
 close $f
 # Preserve explicit functional accounting, including zero/optimized-away groups.
 set f [open [file join $out functional_hierarchy.tsv] w]
 puts $f "cell\treference"
 foreach c [get_cells -hierarchical -filter {IS_PRIMITIVE == 0}] {
  puts $f "$c\t[get_property REF_NAME $c]"
 }
 close $f
 if {$placed} {optional_report congestion {report_design_analysis -congestion -file [file join $out congestion.rpt]}}
 if {$routed} {required_report route_status {report_route_status -file [file join $out route_status.rpt]}}
 if {[llength $bb]} {error "D38 real full top has black boxes: $bb"}
 if {[llength $latches]} {error "D38 full top inferred latches: $latches"}
}

proc run_stage {} {
 global stage at run cp part top
 puts "M007_D38_STAGE_BEGIN stage=$stage part=$part top=$top"
 puts "M007_D38_TOOL [version -short]"
 create_project -in_memory -part $part
 if {[llength [get_parts -quiet $part]] != 1} {error "Required part unavailable: $part"}
 if {$stage eq "parameters"} {
  puts "M007_D38_PARAMETER_QUERY_BEGIN"
  foreach p [list_param] {
   if {[regexp -nocase {parallel|thread|synth\.elaboration} $p]} {puts "$p=[get_param $p]"}
  }
  puts "M007_D38_PARAMETER_QUERY_END"
  save_text [file join $at stage_complete.txt] "stage=parameters\nquery_only=1"
  return
 }
 if {$stage in {core_synth facade_synth resident_synth parent_synth}} {
  source [file join $at frozen bottom_up_flow_v3.tcl]
  source [file join $run input sources.tcl]
  foreach src $production_sources {
   set name [file rootname [file tail $src]]
   if {$name ni $ooc_stubs($stage)} {read_verilog -sv $src}
  }
  foreach name $ooc_stubs($stage) {read_verilog -sv [file join $run input stubs ${name}.sv]}
  read_xdc [file join $at frozen full_top_d38.xdc]
  puts "M007_D38_BOTTOM_UP_SYNTH stage=$stage top=$ooc_top($stage) generic=$ooc_generics($stage)"
  if {[llength $ooc_generics($stage)]} {
   synth_design -top $ooc_top($stage) -part $part -mode out_of_context -flatten_hierarchy none -generic $ooc_generics($stage)
  } else {synth_design -top $ooc_top($stage) -part $part -mode out_of_context -flatten_hierarchy none}
  set bb [lsort [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]
  if {$bb ne [lsort $ooc_expected_bb($stage)]} {error "Unexpected intermediate blackboxes $bb, expected $ooc_expected_bb($stage)"}
  save_text [file join $at intermediate_scope.txt] "top=$ooc_top($stage)\nblackboxes=$bb\nfull_kernel_accepted=0"
  write_checkpoint [file join $cp ${stage}.dcp]
  save_text [file join $at stage_complete.txt] "stage=$stage\nsubtree_or_intermediate_only=1"
  puts "M007_D38_STAGE_PASS stage=$stage full_kernel_accepted=0"
  return
 }
 if {$stage in {facade_link full_link}} {
  if {$stage eq "facade_link"} {
   open_checkpoint [file join $cp facade_synth.dcp]
   read_checkpoint -strict -cell core [file join $cp core_synth.dcp]
  } else {
   open_checkpoint [file join $cp parent_synth.dcp]
   read_checkpoint -strict -cell matrix [file join $cp facade_link.dcp]
   read_checkpoint -strict -cell resident [file join $cp resident_synth.dcp]
  }
  set children [get_clocks -quiet]
  if {[llength $children]} {delete_clocks $children}
  read_xdc [file join $at frozen full_top_d38.xdc]
  set bb [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
  if {[llength $bb]} {error "Actual DCP integration left blackboxes $bb"}
  if {[llength [get_clocks -quiet]] != 1} {error "Expected exactly one final core clock"}
  write_checkpoint [file join $cp ${stage}.dcp]
  save_text [file join $at stage_complete.txt] "stage=$stage\nblackboxes=0\nclock_count=1\nfull_kernel_linked=[expr {$stage eq "full_link"}]"
  puts "M007_D38_STAGE_PASS stage=$stage blackboxes=0"
  return
 }
 if {$stage in {preflight synth}} {
  source [file join $run input sources.tcl]
  set_property include_dirs [list [file join $run input rtl]] [current_fileset]
  foreach src $production_sources {read_verilog -sv $src}
  if {$stage eq "preflight"} {
   save_text [file join $at reports part_properties.rpt] [report_property -all -return_string [get_parts $part]]
   save_text [file join $at reports tool_and_license_commands.txt] "version=[version]\nlicense_commands=[info commands *license*]\nlicense_checkout=not_proven_until_synth_design\nthreads=[get_param general.maxThreads]"
   puts "M007_D38_PREFLIGHT_PASS production_sources=[llength $production_sources]"
  } else {
   read_xdc [file join $at frozen full_top_d38.xdc]
   source [file join $at frozen physical_generics_v2.tcl]
   puts "M007_D38_ACTUAL_GENERICS $production_generics"
   synth_design -top $top -part $part -mode out_of_context -flatten_hierarchy rebuilt -generic $production_generics
   write_checkpoint [file join $cp synth.dcp]
  }
 } else {
  array set prior {report_synth synth report_full full_link opt full_link place opt report_place place phys_opt place route phys_opt report_route route}
  if {![info exists prior($stage)]} {error "Unknown stage: $stage"}
  open_checkpoint [file join $cp $prior($stage).dcp]
  switch $stage {
   report_synth {full_reports 0 0}
   report_full {full_reports 0 0}
   opt {opt_design;write_checkpoint [file join $cp opt.dcp]}
   place {place_design;write_checkpoint [file join $cp place.dcp]}
   report_place {full_reports 1 0}
   phys_opt {phys_opt_design;write_checkpoint [file join $cp phys_opt.dcp]}
   route {route_design;write_checkpoint [file join $cp route.dcp]}
   report_route {full_reports 1 1}
  }
 }
 save_text [file join $at stage_complete.txt] "stage=$stage\npart=$part\ntop=$top\nparameter_VERIFY_POST_ENCODER27_H=0"
 puts "M007_D38_STAGE_PASS stage=$stage"
}
if {[catch {run_stage} message options]} {
 save_text [file join $at stage_error.txt] "$message\n[dict get $options -errorinfo]"
 puts stderr "M007_D38_STAGE_FAIL stage=$stage error=$message"
 exit 1
}
exit 0
