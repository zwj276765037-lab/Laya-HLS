if {[llength $argv]!=3} {error "usage: t4_dual_w_cache_link_edif_existing_ooc.tcl WORK EXACT_PARENT_EDF EXACT_BANK_EDF"}
lassign $argv work parent_edf bank_edf
set work [file normalize $work]
set_param general.maxThreads 4
file copy [file normalize $parent_edf] [file join $work t4_dual_w_cache_v1.edf]
file copy [file normalize $bank_edf] [file join $work t4_w_cache_bank_v1.edf]
read_edif [file join $work t4_w_cache_bank_v1.edf]
read_edif [file join $work t4_dual_w_cache_v1.edf]
link_design -top t4_dual_w_cache_v1 -part xcu55c-fsvh2892-2L-e
set banks [get_cells -hierarchical -filter {REF_NAME == t4_w_cache_bank_v1 || ORIG_REF_NAME == t4_w_cache_bank_v1}]
set blackboxes [llength [get_cells -hierarchical -filter {IS_BLACKBOX == 1}]]
set urams [llength [get_cells -hierarchical -filter {REF_NAME =~ URAM288*}]]
set bram36 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB36E2}]]
set bram18 [llength [get_cells -hierarchical -filter {REF_NAME == RAMB18E2}]]
if {[llength $banks]!=32 || $blackboxes!=0 || $urams!=384 || $bram36<192 || $bram18<64} {error "T4_CACHE_EDIF_LINK_FAIL banks=[llength $banks] BB=$blackboxes URAM=$urams RAMB36=$bram36 RAMB18=$bram18"}
set f [open [file join $work bank_cell_mapping.txt] w]
foreach bank [lsort [get_property NAME $banks]] {puts $f "$bank <- exact bankDCP via t4_w_cache_bank_v1.edf"}
close $f
create_clock -name clk -period 6.667 [get_ports clk]
report_utilization -file [file join $work utilization.rpt]
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
report_timing_summary -max_paths 10 -file [file join $work timing_summary.rpt]
write_checkpoint [file join $work cache_synth.dcp]
write_verilog -mode funcsim [file join $work cache_synth.v]
puts "T4_DUAL_W_CACHE_ASSEMBLED_OOC_PASS banks=32 URAM=$urams RAMB36=$bram36 RAMB18=$bram18 blackboxes=0 full_payload_bits=91693056 structural_link=1"
close_design
catch {close_project}
