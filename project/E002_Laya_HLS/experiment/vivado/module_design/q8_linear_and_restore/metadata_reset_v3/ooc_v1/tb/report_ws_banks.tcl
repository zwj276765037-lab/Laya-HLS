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

# The first pass is a legacy BRAM/URAM inventory.  Its missing-memory flag is
# provisional: a complete bank may use LUTRAM or FFs.  The final failure flag
# below is based on the full primitive/address-source audit instead.
set needs_review 0

# The full pass adds a complete primitive inventory.  A BRAM/URAM-only inventory misses
# distributed RAM, LUT and FF storage, and therefore cannot resolve the
# 20,992-word bank capacity question.  This report stays review-required;
# synthesis success alone is never treated as a full-depth proof.
proc q8_primitive_category {ref primitive_type} {
    set type [string toupper $primitive_type]
    if {[string match "*LUTRAM*" $type] || [regexp {^RAM(16|32|64|128)} $ref]} { return "LUTRAM" }
    if {[string match "URAM*" $ref]} { return "URAM" }
    if {[string match "RAM*" $ref]} { return "BRAM_OR_RAM" }
    if {[regexp {^(FD|LD)} $ref]} { return "FF_OR_LATCH" }
    if {[regexp {^(LUT|SRL)} $ref]} { return "LUT_OR_SRL" }
    return "OTHER_PRIMITIVE"
}
proc q8_is_primitive {cell} {
    set value [q8_property $cell IS_PRIMITIVE]
    return [expr {$value eq "1" || $value eq "true" || $value eq "TRUE"}]
}
proc q8_source_kind {pin_name} {
    if {[regexp -nocase {(^|/)address([01])\[([0-9]+)\]$} $pin_name -> prefix port bit]} {
        if {$bit <= 14} { return [list ADDRESS $port $bit] }
    }
    if {[regexp -nocase {(^|/)(we|ce|en)([01])(\[[0-9]+\])?$} $pin_name -> prefix control port index]} {
        return [list [string toupper $control] $port $index]
    }
    return {}
}
proc q8_driver_info {pin} {
    set drivers {}
    foreach net [get_nets -quiet -of_objects $pin] {
        foreach peer [get_pins -quiet -of_objects $net -filter {DIRECTION == OUT}] {
            set owner [get_cells -quiet -of_objects $peer]
            set ref "NO_CELL"
            if {[llength $owner] > 0} { set ref [get_property REF_NAME [lindex $owner 0]] }
            lappend drivers "[get_property NAME $peer]:$ref"
        }
        foreach port [get_ports -quiet -of_objects $net -filter {DIRECTION == IN}] {
            lappend drivers "[get_property NAME $port]:TOP_INPUT"
        }
    }
    if {[llength $drivers] == 0} { return "NO_DRIVER_REVIEW_REQUIRED" }
    return [join [lsort -unique $drivers] ";"]
}

set all_primitives [open [file join $ws_report_dir ws_all_primitives.tsv] w]
set ref_counts [open [file join $ws_report_dir ws_primitive_ref_counts.tsv] w]
set unmatched_primitives [open [file join $ws_report_dir ws_unmatched_primitives.tsv] w]
set reachability [open [file join $ws_report_dir ws_address_reachability.tsv] w]
set source_summary [open [file join $ws_report_dir ws_address_source_summary.tsv] w]
set full_summary [open [file join $ws_report_dir ws_full_primitive_summary.tsv] w]
puts $all_primitives "bank\tcell\tref\tprimitive_type\tcategory"
puts $ref_counts "bank\tref\tprimitive_type\tcategory\tcount"
puts $unmatched_primitives "cell\tref\tprimitive_type\tcategory"
puts $reachability "bank\tsource_kind\tport\tbit_or_index\tsource_pin\tsource_net\tendpoint_cell\tendpoint_ref\tendpoint_type\tendpoint_category\tendpoint_pin\tendpoint_net\tendpoint_net_driver\tstatus"
puts $source_summary "bank\tsource_kind\tport\tbit_or_index\tsource_pin\tprimitive_endpoints\tmemory_endpoints\tstatus"
puts $full_summary "bank\tall_primitives\tbram_or_ram\turam\tlutram\tff_or_latch\tlut_or_srl\tother\taddress_source_pins\tunresolved_sources\tstatus"

set primitive_cells [dict create]
set primitive_counts [dict create]
set category_counts [dict create]
set primitive_by_ref [dict create]
set address_sources [dict create]
set missing_primitive_property 0
foreach bank $banks {
    dict set primitive_counts $bank 0
    dict set address_sources $bank [dict create]
    foreach category {BRAM_OR_RAM URAM LUTRAM FF_OR_LATCH LUT_OR_SRL OTHER_PRIMITIVE} {
        dict set category_counts $bank $category 0
    }
}
foreach cell $all_cells {
    set name [get_property NAME $cell]
    set bank [q8_bank_for_name $name $banks]
    set primitive_flag [q8_property $cell IS_PRIMITIVE]
    if {$primitive_flag eq "NA" && [q8_property $cell PRIMITIVE_TYPE] ne "NA"} {
        incr missing_primitive_property
    }
    if {[q8_is_primitive $cell]} {
        set ref [get_property REF_NAME $cell]
        set type [q8_property $cell PRIMITIVE_TYPE]
        set category [q8_primitive_category $ref $type]
        if {$bank eq "UNMAPPED"} {
            puts $unmatched_primitives "$name\t$ref\t$type\t$category"
        } else {
            dict set primitive_cells $name [list $bank $ref $type $category]
            dict incr primitive_counts $bank
            set bank_categories [dict get $category_counts $bank]
            dict incr bank_categories $category
            dict set category_counts $bank $bank_categories
            dict incr primitive_by_ref [list $bank $ref $type $category]
            puts $all_primitives "$bank\t$name\t$ref\t$type\t$category"
        }
    }
    if {$bank eq "UNMAPPED"} { continue }
    foreach pin [get_pins -quiet -of_objects $cell] {
        set pin_name [get_property NAME $pin]
        set kind [q8_source_kind $pin_name]
        if {[llength $kind] == 0} { continue }
        dict set address_sources $bank $pin_name [list $pin {*}$kind]
    }
}
if {[info exists primitive_by_ref]} {
    foreach key [lsort [dict keys $primitive_by_ref]] {
        lassign $key bank ref type category
        puts $ref_counts "$bank\t$ref\t$type\t$category\t[dict get $primitive_by_ref $key]"
    }
}

foreach bank $banks {
    set unresolved 0
    set sources [dict get $address_sources $bank]
    foreach source_name [lsort [dict keys $sources]] {
        lassign [dict get $sources $source_name] source kind port bit
        lassign [q8_net_info $source] source_net source_peers
        set primitive_endpoints 0
        set memory_endpoints 0
        set fanout_failed [catch {
            set endpoints [all_fanout -quiet -flat -from $source -endpoints_only]
        } fanout_result]
        if {$fanout_failed} {
            set endpoints {}
        }
        set seen_endpoint [dict create]
        foreach endpoint $endpoints {
            set endpoint_name [get_property NAME $endpoint]
            if {[dict exists $seen_endpoint $endpoint_name]} { continue }
            dict set seen_endpoint $endpoint_name 1
            set owners [get_cells -quiet -of_objects $endpoint]
            if {[llength $owners] == 0} { continue }
            set owner [lindex $owners 0]
            set cell_name [get_property NAME $owner]
            if {![dict exists $primitive_cells $cell_name]} { continue }
            lassign [dict get $primitive_cells $cell_name] endpoint_bank ref type category
            if {$endpoint_bank ne $bank} { continue }
            incr primitive_endpoints
            if {$category in {BRAM_OR_RAM URAM LUTRAM}} { incr memory_endpoints }
            lassign [q8_net_info $endpoint] endpoint_net endpoint_peers
            set driver [q8_driver_info $endpoint]
            puts $reachability "$bank\t$kind\t$port\t$bit\t$source_name\t$source_net\t$cell_name\t$ref\t$type\t$category\t$endpoint_name\t$endpoint_net\t$driver\tREACHABLE_ENDPOINT"
        }
        set status "REACHABILITY_REVIEW_REQUIRED"
        if {$fanout_failed || $primitive_endpoints == 0} {
            set status "NO_PRIMITIVE_ENDPOINT_REVIEW_REQUIRED"
            incr unresolved
            puts $reachability "$bank\t$kind\t$port\t$bit\t$source_name\t$source_net\tNA\tNA\tNA\tNA\tNA\tNA\tNA\t$status"
        }
        puts $source_summary "$bank\t$kind\t$port\t$bit\t$source_name\t$primitive_endpoints\t$memory_endpoints\t$status"
    }
    set status "FULL_PRIMITIVE_AND_DECODE_MANUAL_REVIEW_REQUIRED"
    if {[dict get $primitive_counts $bank] == 0 || [dict size $sources] == 0} {
        set status "UNMAPPED_OR_NO_ADDRESS_SOURCE_REVIEW_REQUIRED"
        set needs_review 1
    }
    puts $full_summary "$bank\t[dict get $primitive_counts $bank]\t[dict get $category_counts $bank BRAM_OR_RAM]\t[dict get $category_counts $bank URAM]\t[dict get $category_counts $bank LUTRAM]\t[dict get $category_counts $bank FF_OR_LATCH]\t[dict get $category_counts $bank LUT_OR_SRL]\t[dict get $category_counts $bank OTHER_PRIMITIVE]\t[dict size $sources]\t$unresolved\t$status"
}
close $all_primitives
close $ref_counts
close $unmatched_primitives
close $reachability
close $source_summary
close $full_summary
puts "Q8_OOC_WS_FULL_PRIMITIVE_INVENTORY banks=8 primitive_property_missing=$missing_primitive_property high_address_manual_review_required=1"
if {$missing_primitive_property > 0} { error "IS_PRIMITIVE property missing on cells; full primitive audit cannot be trusted" }
if {$needs_review} { error "one or more logical Ws banks could not be mapped to physical cells or address sources" }
