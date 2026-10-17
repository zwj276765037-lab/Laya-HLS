set b [file normalize $::env(LAYA_GEGLU_BANK_ATTEMPT)]
set g [file dirname $b]
set_param general.maxThreads 4
set work [file join $b ooc core_export]
file mkdir $work
if {![file exists [file join $work geglu_canonical_core.dcp]]} {
open_checkpoint [file join $g ooc parent geglu_canonical_row_assembled.dcp]
set target [get_cells -quiet arithmetic]
if {[llength $target]!=1 || [get_property REF_NAME $target]!="geglu_canonical_core"} {error "GEGLU_BANK_CORE_EXPORT_SOURCE"}
write_checkpoint -cell arithmetic [file join $work geglu_canonical_core.dcp]
puts "TANH_LIBM_GEGLU_BANK_CORE_DCP_EXPORTED exact_successful_subtree=1"
close_design
catch {close_project}
} else {
 puts "TANH_LIBM_GEGLU_BANK_CORE_DCP_REUSED first_export_saved_exact_source=1"
}
open_checkpoint [file join $work geglu_canonical_core.dcp]
set expected [list clk reset in_valid commit_valid]
foreach base {in_x in_g data status failed} {for {set i 0} {$i<32} {incr i} {lappend expected "$base\[$i\]"}}
if {[lsort [get_property NAME [get_ports]]] != [lsort $expected]} {error "GEGLU_BANK_CORE_EXPORT_PORTS"}
set f [open [file join $g ooc parent final_boundary_map.txt] r]
set count 0
while {[gets $f line]>=0} {
 set words [split $line]
 set cell [string range [lindex $words 0] 11 end]
 set module [lindex $words 1]
 set target [get_cells -quiet $cell]
 if {[llength $target]!=1} {error "GEGLU_BANK_CORE_EXPORT_BOUNDARY_PATH $cell found=$target"}
 set actual [get_property REF_NAME $target]
 set original [get_property ORIG_REF_NAME $target]
 puts "TANH_LIBM_GEGLU_BANK_CORE_BOUNDARY $cell expected=$module REF_NAME=$actual ORIG_REF_NAME=$original"
 if {$actual!=$module && $original!=$module} {error "GEGLU_BANK_CORE_EXPORT_BOUNDARY_REF $cell actual=$actual original=$original"}
 incr count
}
close $f
if {$count!=51 || [llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]!=0} {error "GEGLU_BANK_CORE_EXPORT_COUNT"}
write_edif [file join $work geglu_canonical_core.edf]
set f [open [file join $work ports.txt] w]
foreach p [lsort [get_ports]] {puts $f "$p [get_property DIRECTION $p]"}
close $f
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
puts "TANH_LIBM_GEGLU_BANK_CORE_EXPORT_PASS boundaries=51 ports=164 blackboxes=0 exact_successful_subtree=1"
close_design
catch {close_project}
exit
