if {![info exists ws_report_dir]} { error "ws_report_dir must be set by synth_ooc.tcl" }
set banks {ws_U ws_8_U ws_9_U ws_10_U ws_11_U ws_12_U ws_13_U ws_14_U}
set memory_cells [concat \
    [get_cells -quiet -hierarchical -filter {REF_NAME =~ RAM*}] \
    [get_cells -quiet -hierarchical -filter {REF_NAME =~ URAM*}]]
set all_cells [get_cells -quiet -hierarchical]
set unique_memory [dict create]
foreach cell $memory_cells { dict set unique_memory [get_property NAME $cell] $cell }
set summary [open [file join $ws_report_dir ws_summary.tsv] w]
set cells_out [open [file join $ws_report_dir ws_cells.tsv] w]
set pins_out [open [file join $ws_report_dir ws_pin_nets.tsv] w]
set logic_out [open [file join $ws_report_dir ws_logical_address_pins.tsv] w]
set unmatched [open [file join $ws_report_dir ws_unmatched_memory_cells.tsv] w]
puts $summary "bank\thierarchy_cells\tmemory_primitives\tread_msb14_seen\twrite_msb14_seen\tstatus"
puts $cells_out "bank\tcell\tref\tprimitive_type\tread_width_a\tread_width_b\twrite_width_a\twrite_width_b\tinit_file\tcascade_order_a\tcascade_order_b"
puts $pins_out "bank\tcell\tref\tpin\tnet\tconnected_pins"
puts $logic_out "bank\tpin\tnet\tconnected_pins"
puts $unmatched "cell\tref"

proc q8_property {object key} {
    if {[lsearch -exact [list_property $object] $key] < 0} { return "NA" }
    set value [get_property $key $object]
    if {$value eq ""} { return "EMPTY" }
    return $value
}
proc q8_net_info {pin} {
    set nets [get_nets -quiet -of_objects $pin]
    if {[llength $nets] == 0} { return [list "UNCONNECTED" ""] }
    set names {}
    set peers {}
    foreach net $nets {
        lappend names [get_property NAME $net]
        foreach peer [get_pins -quiet -of_objects $net] { lappend peers [get_property NAME $peer] }
    }
    return [list [join [lsort -unique $names] ";"] [join [lsort -unique $peers] ";"]]
}
proc q8_bank_for_name {name banks} {
    foreach bank $banks {
        if {[regexp [format {(^|/)%s(/|$)} $bank] $name]} { return $bank }
    }
    return "UNMAPPED"
}

set totals [dict create]
foreach bank $banks { dict set totals $bank 0 }
foreach name [lsort [dict keys $unique_memory]] {
    set cell [dict get $unique_memory $name]
    set ref [get_property REF_NAME $cell]
    set bank [q8_bank_for_name $name $banks]
    if {$bank eq "UNMAPPED"} {
        puts $unmatched "$name\t$ref"
        continue
    }
    dict incr totals $bank
    puts $cells_out "$bank\t$name\t$ref\t[q8_property $cell PRIMITIVE_TYPE]\t[q8_property $cell READ_WIDTH_A]\t[q8_property $cell READ_WIDTH_B]\t[q8_property $cell WRITE_WIDTH_A]\t[q8_property $cell WRITE_WIDTH_B]\t[q8_property $cell INIT_FILE]\t[q8_property $cell CASCADE_ORDER_A]\t[q8_property $cell CASCADE_ORDER_B]"
    foreach pin [get_pins -quiet -of_objects $cell] {
        set pname [get_property NAME $pin]
        if {![regexp -nocase {ADDR|EN|WE|DI|DO|CASCADE} $pname]} { continue }
        lassign [q8_net_info $pin] net peers
        puts $pins_out "$bank\t$name\t$ref\t$pname\t$net\t$peers"
    }
}

set needs_review 0
foreach bank $banks {
    set hierarchy 0
    set read_msb 0
    set write_msb 0
    foreach cell $all_cells {
        set cname [get_property NAME $cell]
        if {[q8_bank_for_name $cname [list $bank]] ne $bank} { continue }
        incr hierarchy
        foreach pin [get_pins -quiet -of_objects $cell] {
            set pname [get_property NAME $pin]
            if {![regexp {address[01]} $pname]} { continue }
            lassign [q8_net_info $pin] net peers
            puts $logic_out "$bank\t$pname\t$net\t$peers"
            if {[string first {address0[14]} $pname] >= 0 && $net ne "UNCONNECTED"} { set read_msb 1 }
            if {[string first {address1[14]} $pname] >= 0 && $net ne "UNCONNECTED"} { set write_msb 1 }
        }
    }
    set count [dict get $totals $bank]
    set status "INVENTORY_ONLY_HIGH_ADDRESS_REVIEW_REQUIRED"
    if {$hierarchy == 0 || $count == 0} {
        set status "UNMAPPED_BANK_REVIEW_REQUIRED"
        set needs_review 1
    }
    puts $summary "$bank\t$hierarchy\t$count\t$read_msb\t$write_msb\t$status"
}
close $summary
close $cells_out
close $pins_out
close $logic_out
close $unmatched
puts "Q8_OOC_WS_INVENTORY banks=8 manual_high_address_connectivity_review_required=1 unmapped_bank=$needs_review"
if {$needs_review} { error "one or more logical Ws banks could not be mapped to physical memory cells" }
