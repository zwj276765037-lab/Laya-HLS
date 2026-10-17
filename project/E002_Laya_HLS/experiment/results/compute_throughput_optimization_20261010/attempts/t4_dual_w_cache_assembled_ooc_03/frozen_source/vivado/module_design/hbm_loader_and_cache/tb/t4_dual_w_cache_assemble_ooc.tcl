if {[llength $argv] != 2 && [llength $argv] != 3} {error "usage: t4_dual_w_cache_assemble_ooc.tcl FRESH_WORK FULL_BANK_DCP"}
lassign $argv work bank_dcp parent_dcp
set work [file normalize $work]
set bank_dcp [file normalize $bank_dcp]
set module [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 4
if {$parent_dcp ne ""} {
  open_checkpoint [file normalize $parent_dcp]
} else {
  foreach f {t4_w_reader_port_v1 t4_three_port_reader_v1 t4_aux_bias_reader_v1 t4_w_cache_bank_stub_v1 t4_dual_w_cache_v1} {
    read_verilog -sv [file join $module rtl ${f}.sv]
  }
  synth_design -top t4_dual_w_cache_v1 -part xcu55c-fsvh2892-2L-e -mode out_of_context -flatten_hierarchy none
  write_checkpoint [file join $work parent_stub_synth.dcp]
  close_design
  close_project -quiet
  open_checkpoint [file join $work parent_stub_synth.dcp]
}
set banks [get_property NAME [get_cells -hierarchical -filter {REF_NAME == t4_w_cache_bank_v1}]]
if {[llength $banks] != 32} {error "T4_CACHE_BANK_INSTANCE_COUNT [llength $banks]"}
set mapping [open [file join $work bank_cell_mapping.txt] w]
foreach cell [lsort $banks] {
  puts $mapping "$cell <- $bank_dcp"
  read_checkpoint -cell $cell $bank_dcp
  set boundary [get_cells -hierarchical -filter [format {NAME == "%s"} $cell]]
  if {[llength $boundary] != 1 || [get_property IS_BLACKBOX $boundary]} {error "T4_CACHE_UNRESOLVED_BANK $cell"}
  set_property DONT_TOUCH true $boundary
  puts "T4_CACHE_BANK_IMPORTED cell=$cell"
}
close $mapping
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
set urams [llength [get_cells -hierarchical -filter {REF_NAME =~ URAM288*}]]
set bram36 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB36E2}]]
set bram18 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB18E2}]]
if {$blackboxes != 0 || $urams != 384 || $bram36 < 192 || $bram18 < 64} {
  error "T4_CACHE_ASSEMBLY_FAIL BB=$blackboxes URAM=$urams RAMB36=$bram36 RAMB18=$bram18"
}
set xdc [open [file join $work clock.xdc] w]
puts $xdc "create_clock -name clk -period 6.667 \[get_ports clk\]"
close $xdc
read_xdc [file join $work clock.xdc]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work cache_synth.dcp]
write_verilog -mode funcsim [file join $work cache_synth.v]
puts "T4_DUAL_W_CACHE_ASSEMBLED_OOC_PASS banks=32 URAM=$urams RAMB36=$bram36 RAMB18=$bram18 blackboxes=0 full_payload_bits=91693056"
close_project
