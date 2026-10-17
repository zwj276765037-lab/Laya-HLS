set attempt [file normalize $::env(LAYA_CANONICAL_ATTEMPT)]
set_param general.maxThreads 4
set work [file join $attempt ooc core_export]
file mkdir $work
open_checkpoint [file join $attempt ooc parent tanh_libm_canonical_assembled.dcp]
set target [get_cells -quiet core]
if {[llength $target]!=1 || [get_property REF_NAME $target] != "tanh_libm_canonical_core"} {error "CANONICAL_CORE_EXPORT_SOURCE"}
write_checkpoint -cell core [file join $work tanh_libm_canonical_core.dcp]
puts "TANH_LIBM_CANONICAL_CORE_DCP_EXPORTED exact_successful_subtree=1"
close_design
catch {close_project}
open_checkpoint [file join $work tanh_libm_canonical_core.dcp]
set ports [get_ports -quiet]
set names [lsort [get_property NAME $ports]]
if {$names != [lsort {clk reset in_valid in_data[0] in_data[1] in_data[2] in_data[3] in_data[4] in_data[5] in_data[6] in_data[7] in_data[8] in_data[9] in_data[10] in_data[11] in_data[12] in_data[13] in_data[14] in_data[15] in_data[16] in_data[17] in_data[18] in_data[19] in_data[20] in_data[21] in_data[22] in_data[23] in_data[24] in_data[25] in_data[26] in_data[27] in_data[28] in_data[29] in_data[30] in_data[31] commit_valid result[0] result[1] result[2] result[3] result[4] result[5] result[6] result[7] result[8] result[9] result[10] result[11] result[12] result[13] result[14] result[15] result[16] result[17] result[18] result[19] result[20] result[21] result[22] result[23] result[24] result[25] result[26] result[27] result[28] result[29] result[30] result[31] status[0] status[1] status[2] status[3] status[4] status[5] status[6] status[7] status[8] status[9] status[10] status[11] status[12] status[13] status[14] status[15] status[16] status[17] status[18] status[19] status[20] status[21] status[22] status[23] status[24] status[25] status[26] status[27] status[28] status[29] status[30] status[31]}]} {error "CANONICAL_CORE_EXPORT_PORTS $names"}
set fp [get_cells -quiet -hierarchical -filter {REF_NAME =~ tanh_libm_stream_leaf_stream_*_node_*_s}]
if {[llength $fp]!=42 || [llength [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]]!=0} {error "CANONICAL_CORE_EXPORT_BOUNDARIES [llength $fp]"}
write_edif [file join $work tanh_libm_canonical_core.edf]
set f [open [file join $work ports.txt] w]
foreach p [lsort $ports] {puts $f "$p [get_property DIRECTION $p]"}
close $f
report_utilization -hierarchical -file [file join $work utilization_hierarchical.rpt]
puts "TANH_LIBM_CANONICAL_CORE_EXPORT_PASS boundaries=42 blackboxes=0 exact_successful_subtree=1"
close_design
catch {close_project}
exit
