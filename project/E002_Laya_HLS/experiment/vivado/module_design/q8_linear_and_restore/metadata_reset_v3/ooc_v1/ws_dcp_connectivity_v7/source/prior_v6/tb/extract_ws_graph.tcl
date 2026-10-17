# Ws v6 checkpoint-only graph and functional-export extraction. Source preparation only until a new
# execution gate is approved. Arbitrary names/values are hex UTF-8.
if {[llength $argv] != 2} { error "usage: extract_ws_graph.tcl SEALED_DCP FRESH_REPORT_DIR" }
lassign $argv dcp outdir
set dcp [file normalize $dcp]
set outdir [file normalize $outdir]
set expected_dcp "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
set expected_outdir "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v6/runs/export_graph_v1/reports"
set expected_sha c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce
if {$dcp ne $expected_dcp || $outdir ne $expected_outdir} { error "unreviewed DCP/output path" }
if {![file isfile $dcp] || ![catch {file lstat $outdir st}]} { error "missing DCP or report path not fresh" }
proc sha256_file {path} { return [lindex [split [string trim [exec /usr/bin/sha256sum -- $path]]] 0] }
if {[sha256_file $dcp] ne $expected_sha} { error "DCP input hash drift" }
set contract_tcl [file normalize [file join [file dirname [info script]] ../source/required_properties.tcl]]
if {[sha256_file $contract_tcl] ne "80ab316f1742c351e9f8e9676e535af5ba555b54c8ae6bece271e566e8d9136a"} { error "reviewed property contract Tcl drift" }
source $contract_tcl
if {$required_ref_count != 22 || $required_contract_count != 348} { error "reviewed property contract cardinality drift" }
file mkdir $outdir
set ledger [open [file join $outdir phase_ledger.tsv] w]
fconfigure $ledger -buffering line -translation lf -encoding utf-8
puts $ledger "timestamp_utc\tphase\tevent\tcount\tdetail_hex"
proc phase {name event count detail} {
    global ledger
    puts $ledger "[clock format [clock seconds] -gmt true -format {%Y-%m-%dT%H:%M:%SZ}]\t$name\t$event\t$count\t[binary encode hex [encoding convertto utf-8 $detail]]"
}
phase startup BEGIN 0 "DCP identity checked; report path fresh"
set_param general.maxThreads 4
open_checkpoint $dcp
phase checkpoint COMPLETE 1 "sealed checkpoint opened"

set banks {ws_U ws_8_U ws_9_U ws_10_U ws_11_U ws_12_U ws_13_U ws_14_U}
set files [dict create]
proc make_table {key header} {
    global files outdir
    set f [open [file join $outdir "$key.tsv"] w]
    fconfigure $f -buffering line -translation lf -encoding utf-8
    puts $f $header
    dict set files $key $f
}
proc row {key args} {
    global files
    puts [dict get $files $key] [join $args "\t"]
}
proc hx {value} { return [binary encode hex [encoding convertto utf-8 $value]] }
proc issue {code bank object detail} {
    global issue_count structural_issue_count property_gap_count
    incr issue_count
    if {$code eq "REQUIRED_PROPERTY_GAP"} {
        incr property_gap_count
    } else {
        incr structural_issue_count
    }
    row issues $code [hx $bank] [hx $object] [hx $detail]
}
proc property_values {key objects scope {allow_fallback 0}} {
    set count [llength $objects]
    if {$count == 0} { return {} }
    # A one-object value may itself contain whitespace, so wrap it explicitly.
    if {$count == 1} {
        if {[catch {get_property $key [lindex $objects 0]} value]} {
            phase $scope GROUP_ERROR 1 "$key: $value"
            return [list [list ERROR $value]]
        }
        return [list [list OK $value]]
    }
    if {[catch {get_property $key $objects} values] || [llength $values] != $count} {
        if {!$allow_fallback} {
            phase $scope GROUP_ERROR $count "$key: $values"
            return [lrepeat $count [list ERROR $values]]
        }
        phase $scope GROUP_FALLBACK $count "$key: $values"
        set result [list]
        foreach object $objects {
            if {[catch {get_property $key $object} value]} {
                lappend result [list ERROR $value]
            } else { lappend result [list OK $value] }
        }
        return $result
    }
    set result [list]
    foreach value $values { lappend result [list OK $value] }
    return $result
}
proc scalar_property {object key scope} {
    lassign [lindex [property_values $key [list $object] $scope] 0] status value
    if {$status ne "OK"} { issue PROPERTY_READ_FAILED "" $scope "$key: $value"; return "" }
    return $value
}
proc vector_value_status {reference key value} {
    global vector_width_by_ref
    if {$value eq ""} { return MISSING }
    if {![dict exists $vector_width_by_ref $reference $key]} { return OK }
    set bits [dict get $vector_width_by_ref $reference $key]
    if {![regexp {^([0-9]+)'([hHbBdDoO])([0-9a-fA-F_xXzZ]+)$} $value -> declared radix digits]} {
        # A bare numeric scalar can be a valid non-init vector property.
        if {[string match "INIT*" $key]} { return TRUNCATED }
        return OK
    }
    if {$declared != $bits} { return TRUNCATED }
    if {[string tolower $radix] eq "h" && [string match "INIT*" $key] &&
        [string length [string map {_ ""} $digits]] < [expr {($bits + 3) / 4}]} { return TRUNCATED }
    return OK
}
proc bank_of {name} {
    global banks
    foreach bank $banks {
        if {$name eq $bank || [string first "$bank/" $name] == 0} { return $bank }
    }
    return ""
}

make_table cells "cell_id\tbank\tname_hex\tparent_hex\tref_hex\tprimitive_type_hex\tis_primitive"
make_table properties "cell_id\tproperty_hex\tvalue_hex\tread_status"
make_table pins "pin_id\tcell_id\tname_hex\tref_pin_hex\tdirection\tnet_id"
make_table boundaries "bank\tsignal\tbit\tpin_id\tnet_id\tstatus"
make_table nets "net_id\tcanonical_name_hex\tconstant\tsegments\tselected_pins\tactive_drivers\texternal_drivers"
make_table net_segments "net_id\tname_hex\ttype_hex"
make_table net_drivers "net_id\tkind\tname_hex\towner_hex\towner_ref_hex\tselected_bank"
make_table issues "code\tbank_hex\tobject_hex\tdetail_hex"
make_table coverage "bank\tcells\tprimitives\tpins\tboundaries\tstatus"
make_table global_dsp "name_hex\tparent_hex\tref_hex"
make_table clock_properties "clock_hex\tproperty_hex\tvalue_hex\tread_status"
set issue_count 0
set structural_issue_count 0
set property_gap_count 0

# The sole whole-design traversal is a batched cell-name read. All further
# per-cell property and pin work is restricted to the exact eight bank roots.
set all_cells [get_cells -quiet -hierarchical -include_replicated_objects *]
set all_names [get_property NAME $all_cells]
if {[llength $all_cells] != [llength $all_names]} { error "cell/name batch mismatch" }
set selected [dict create]
foreach cell $all_cells name $all_names {
    set bank [bank_of $name]
    if {$bank ne ""} {
        if {[dict exists $selected $name]} { error "duplicate selected cell NAME: $name" }
        dict set selected $name [list $bank $cell]
    }
}
unset all_cells
unset all_names
phase selection COMPLETE [dict size $selected] "exact-bank cells selected"
foreach bank $banks {
    if {![dict exists $selected $bank]} { issue MISSING_BANK $bank $bank "no exact hierarchy root" }
}

# Export exact bank roots from this single-open checkpoint in contract order.
# A separate gate is required to execute this dormant source route.
set export_dir [file join $outdir funcsim]
file mkdir $export_dir
set export_total_bytes 0
set export_cap_bytes 268435456
foreach bank $banks {
    if {![dict exists $selected $bank]} { error "missing exact bank root for export: $bank" }
    lassign [dict get $selected $bank] selected_bank exact_cell
    if {$selected_bank ne $bank || [get_property NAME $exact_cell] ne $bank} {
        error "ambiguous bank root for export: $bank"
    }
    set ref [get_property REF_NAME $exact_cell]
    if {$ref eq ""} { error "missing bank REF_NAME for export: $bank" }
    set export_file [file join $export_dir "${bank}.v"]
    if {[file exists $export_file]} { error "nonfresh export target: $export_file" }
    phase export BEGIN 1 "$bank NAME=$bank REF_NAME=$ref file=$export_file"
    write_verilog -mode funcsim -write_all_overrides true -keep_vcc_gnd -cell $exact_cell $export_file
    if {![file isfile $export_file]} { error "missing completed functional export: $bank" }
    set length [file size $export_file]
    if {$length <= 0} { error "empty functional export: $bank" }
    if {$length > 67108864} { error "functional export per-bank cap exceeded: $bank" }
    incr export_total_bytes $length
    if {$export_total_bytes > $export_cap_bytes} { error "functional export aggregate cap exceeded" }
    set digest [sha256_file $export_file]
    phase export COMPLETE 1 "$bank NAME=$bank REF_NAME=$ref bytes=$length sha256=$digest total_bytes=$export_total_bytes"
}

set alias_to_net [dict create]
set net_names [dict create]
set net_examples [dict create]
set net_selected_pins [dict create]
set next_net 0
proc net_for_pin {pin pin_name bank} {
    global alias_to_net net_names net_examples next_net
    set local [get_nets -quiet -of_objects $pin]
    if {[llength $local] == 0} { return UNCONNECTED }
    if {[llength $local] != 1} { issue MULTIPLE_PIN_NETS $bank $pin_name "pin has [llength $local] local nets" }
    set local_name [get_property NAME [lindex $local 0]]
    if {[dict exists $alias_to_net $local_name]} { return [dict get $alias_to_net $local_name] }
    # The installed get_nets manual documents -segments with a pin object.
    set segments [get_nets -quiet -segments -of_objects $pin]
    if {[llength $segments] == 0} {
        issue MISSING_NET_SEGMENTS $bank $pin_name $local_name
        return UNRESOLVED
    }
    set names [lsort -unique [get_property NAME $segments]]
    set id "n[incr next_net]"
    foreach name $names {
        if {[dict exists $alias_to_net $name]} {
            issue OVERLAPPING_NET_COMPONENT $bank $pin_name "$name already assigned to [dict get $alias_to_net $name]"
        }
        dict set alias_to_net $name $id
    }
    dict set net_names $id $names
    dict set net_examples $id $pin
    return $id
}

set cell_ids [dict create]
set selected_primitive [dict create]
set pin_ids [dict create]
set cell_counts [dict create]
set primitive_counts [dict create]
set pin_counts [dict create]
set boundary_counts [dict create]
foreach bank $banks {
    dict set cell_counts $bank 0
    dict set primitive_counts $bank 0
    dict set pin_counts $bank 0
    dict set boundary_counts $bank 0
}
set next_cell 0
set next_pin 0
set known_primitive_refs [dict keys $required_by_ref]
set selected_names [lsort [dict keys $selected]]
set selected_objects [list]
foreach name $selected_names { lappend selected_objects [lindex [dict get $selected $name] 1] }
set refs [property_values REF_NAME $selected_objects cell_metadata]
set primitive_flags [property_values IS_PRIMITIVE $selected_objects cell_metadata]
set primitive_types [property_values PRIMITIVE_TYPE $selected_objects cell_metadata]
set blackbox_flags [property_values IS_BLACKBOX $selected_objects cell_metadata]
set primitive_groups [dict create]
foreach name $selected_names ref_item $refs primitive_item $primitive_flags type_item $primitive_types blackbox_item $blackbox_flags {
    lassign [dict get $selected $name] bank cell
    set cid "c[incr next_cell]"
    dict set cell_ids $name $cid
    dict incr cell_counts $bank
    lassign $ref_item ref_status ref
    lassign $primitive_item primitive_status primitive_flag
    lassign $type_item type_status primitive_type
    lassign $blackbox_item blackbox_status blackbox_flag
    if {$ref_status ne "OK" || $ref eq ""} { issue MISSING_REF_NAME $bank $name "$ref_status: $ref" }
    if {$primitive_status ne "OK" || $primitive_flag eq ""} { issue MISSING_PRIMITIVE_FLAG $bank $name "$primitive_status: $primitive_flag" }
    if {$type_status ne "OK"} { issue PRIMITIVE_TYPE_READ_FAILED $bank $name $primitive_type }
    set primitive [expr {$primitive_flag eq "1" || [string equal -nocase $primitive_flag "true"]}]
    dict set selected_primitive $name $primitive
    if {$primitive} { dict incr primitive_counts $bank }
    set parent [string range $name 0 [expr {[string last / $name] - 1}]]
    row cells $cid $bank [hx $name] [hx $parent] [hx $ref] [hx $primitive_type] [expr {$primitive ? 1 : 0}]
    if {$primitive} {
        if {[lsearch -exact $known_primitive_refs $ref] < 0} {
            issue UNKNOWN_PRIMITIVE_SEMANTICS $bank $name $ref
        } else {
            dict lappend primitive_groups $ref [list $name $cid $bank $cell]
        }
        if {$blackbox_status ne "OK" || $blackbox_flag eq ""} { issue BLACKBOX_FLAG_MISSING $bank $name "$blackbox_status: $blackbox_flag" }
        if {$blackbox_flag in {1 true TRUE}} {
            issue BLACKBOX_IN_BANK $bank $name $ref
        }
    }
    set cell_pins [get_pins -quiet -of_objects $cell]
    set pin_names [property_values NAME $cell_pins pin_metadata]
    set pin_refs [property_values REF_PIN_NAME $cell_pins pin_metadata]
    set pin_directions [property_values DIRECTION $cell_pins pin_metadata]
    set by_name [dict create]
    foreach pin $cell_pins name_item $pin_names ref_item $pin_refs direction_item $pin_directions {
        lassign $name_item name_status pin_name
        if {$name_status ne "OK" || $pin_name eq ""} {
            issue PIN_NAME_READ_FAILED $bank $name "$name_status: $pin_name"
            continue
        }
        dict set by_name $pin_name [list $pin $ref_item $direction_item]
    }
    foreach pin_name [lsort [dict keys $by_name]] {
        lassign [dict get $by_name $pin_name] pin ref_item direction_item
        lassign $ref_item ref_status ref_pin
        lassign $direction_item direction_status direction
        if {$ref_status ne "OK" || $ref_pin eq ""} { issue PIN_REF_READ_FAILED $bank $pin_name "$ref_status: $ref_pin" }
        if {$direction_status ne "OK" || $direction ni {IN OUT INOUT}} { issue PIN_DIRECTION_READ_FAILED $bank $pin_name "$direction_status: $direction" }
        if {[dict exists $pin_ids $pin_name]} {
            issue DUPLICATE_PIN_OWNERSHIP $bank $pin_name "pin appeared under two selected cells"
            continue
        }
        set pid "p[incr next_pin]"
        set nid [net_for_pin $pin $pin_name $bank]
        dict set pin_ids $pin_name [list $pid $bank $nid]
        dict incr pin_counts $bank
        if {$nid ne "UNCONNECTED" && $nid ne "UNRESOLVED"} {
            dict lappend net_selected_pins $nid $pid
        }
        row pins $pid $cid [hx $pin_name] [hx $ref_pin] $direction $nid
    }
}
phase cells_pins COMPLETE $next_pin "cells=$next_cell primitives=[expr {[dict size $primitive_groups]}] reference groups"

# Query exactly the required semantic parameter set, once per exact REF_NAME
# group and property. The list_property exemplar is diagnostic only.
foreach ref [lsort [dict keys $primitive_groups]] {
    set group [dict get $primitive_groups $ref]
    set objects [list]
    foreach member $group { lappend objects [lindex $member 3] }
    set group_names [property_values NAME $objects property_group]
    foreach member $group item $group_names {
        lassign $member expected_name cid bank cell
        lassign $item name_status observed_name
        if {$name_status ne "OK" || $observed_name ne $expected_name} {
            issue PROPERTY_GROUP_NAME_MISMATCH $bank $expected_name "$name_status: $observed_name"
            error "property group NAME order mismatch for $ref"
        }
    }
    if {[catch {list_property [lindex $objects 0]} available]} {
        issue PROPERTY_METADATA_FAILED "" $ref $available
        phase properties METADATA_ERROR [llength $objects] "$ref: $available"
        set available [list]
    }
    phase properties REF_BEGIN [llength $objects] "$ref advertised=[llength $available] required=[llength [dict get $required_by_ref $ref]]"
    set ref_gaps 0
    foreach key [dict get $required_by_ref $ref] {
        set values [property_values $key $objects property_group 1]
        if {[llength $values] != [llength $group]} { error "internal property pairing mismatch $ref/$key" }
        foreach member $group item $values {
            lassign $member name cid bank cell
            lassign $item query_status value
            if {$query_status ne "OK"} {
                set status ERROR
            } else { set status [vector_value_status $ref $key $value] }
            row properties $cid [hx $key] [hx $value] $status
            if {$status ne "OK"} {
                incr ref_gaps
                issue REQUIRED_PROPERTY_GAP $bank $name "$ref/$key: $status: $value"
            }
        }
    }
    phase properties REF_COMPLETE [llength $objects] "$ref gaps=$ref_gaps"
}
phase properties COMPLETE [dict size $primitive_groups] "all encountered known reference groups flushed"

# Boundary membership is exact, not a regex over arbitrary hierarchy pins.
set boundary_input_nets [dict create]
foreach bank $banks {
    set expected [list]
    foreach signal {address0 address1} {
        for {set bit 0} {$bit <= 14} {incr bit} { lappend expected [list $signal $bit "$bank/$signal\[$bit\]"] }
    }
    foreach signal {d1 q0} {
        for {set bit 0} {$bit <= 15} {incr bit} { lappend expected [list $signal $bit "$bank/$signal\[$bit\]"] }
    }
    foreach signal {ce0 ce1 we1 reset clk} { lappend expected [list $signal -1 "$bank/$signal"] }
    foreach item $expected {
        lassign $item signal bit name
        if {![dict exists $pin_ids $name]} {
            row boundaries $bank $signal $bit MISSING MISSING MISSING_PIN
            issue MISSING_BOUNDARY_PIN $bank $name "required logical interface pin"
            continue
        }
        lassign [dict get $pin_ids $name] pid owner net_id
        if {$net_id in {UNCONNECTED UNRESOLVED}} { issue UNCONNECTED_BOUNDARY $bank $name $net_id }
        row boundaries $bank $signal $bit $pid $net_id PRESENT
        dict incr boundary_counts $bank
        if {$signal ne "q0" && $net_id ni {UNCONNECTED UNRESOLVED}} {
            dict set boundary_input_nets $net_id 1
        }
    }
}
set boundary_count 0
foreach bank $banks { incr boundary_count [dict get $boundary_counts $bank] }
phase boundaries COMPLETE $boundary_count "logical boundary table flushed"

# Classify each physical owner once. Hierarchy OUT pins are aliases, not
# additional active drivers. Missing/ambiguous flags are explicit gaps.
set owner_class [dict create]
proc classify_driver_owner {owner net_id} {
    global owner_class cell_ids selected_primitive
    set name [get_property NAME $owner]
    if {[dict exists $owner_class $name]} { return [dict get $owner_class $name] }
    set ref [get_property REF_NAME $owner]
    set primitive_flag [scalar_property $owner IS_PRIMITIVE $name]
    set blackbox_flag [scalar_property $owner IS_BLACKBOX $name]
    set kind UNKNOWN_OWNER
    if {$primitive_flag eq "" || $blackbox_flag eq ""} {
        issue UNKNOWN_OWNER_FLAG [bank_of $name] $name "IS_PRIMITIVE=$primitive_flag IS_BLACKBOX=$blackbox_flag"
    } elseif {$blackbox_flag in {1 true TRUE}} {
        issue BLACKBOX_DRIVER_OWNER [bank_of $name] $name $ref
    } elseif {$primitive_flag in {1 true TRUE}} {
        if {$ref eq "GND"} {
            set kind CONSTANT_ZERO
        } elseif {$ref eq "VCC"} {
            set kind CONSTANT_ONE
        } elseif {[dict exists $cell_ids $name]} {
            if {![dict get $selected_primitive $name]} {
                issue OWNER_PRIMITIVE_DISAGREEMENT [bank_of $name] $name $ref
            } else { set kind SELECTED_PRIMITIVE }
        } elseif {[bank_of $name] ne ""} {
            issue SELECTED_OWNER_MISSING [bank_of $name] $name $ref
        } else { set kind EXTERNAL_DRIVER }
    } elseif {$primitive_flag in {0 false FALSE}} {
        set kind HIERARCHY_ALIAS
    } else { issue UNKNOWN_OWNER_FLAG [bank_of $name] $name "unrecognized IS_PRIMITIVE=$primitive_flag" }
    set result [list $kind $name $ref [bank_of $name]]
    dict set owner_class $name $result
    return $result
}

# Each component is serialized once. Only driver pins/ports are queried from
# the whole component; selected-bank incident pins came from the pin table.
foreach nid [lsort -dictionary [dict keys $net_examples]] {
    set example [dict get $net_examples $nid]
    set segments [get_nets -quiet -segments -of_objects $example]
    set seen_driver [dict create]
    set constant UNKNOWN
    set active [dict create]
    set external [dict create]
    set segment_names [property_values NAME $segments net_metadata]
    set segment_types [property_values TYPE $segments net_metadata]
    foreach segment $segments name_item $segment_names type_item $segment_types {
        lassign $name_item name_status sname
        lassign $type_item type_status type
        if {$name_status ne "OK" || $sname eq ""} { issue NET_NAME_READ_FAILED "" $nid "$name_status: $sname" }
        if {$type_status ne "OK"} { issue NET_TYPE_READ_FAILED "" $nid "$type_status: $type" }
        row net_segments $nid [hx $sname] [hx $type]
    }
    foreach pin [get_pins -quiet -of_objects $segments -filter {DIRECTION == OUT}] {
            set pname [get_property NAME $pin]
            if {[dict exists $seen_driver $pname]} { continue }
            dict set seen_driver $pname 1
            set owners [get_cells -quiet -of_objects $pin]
            set owner ""
            set ref ""
            set owner_bank ""
            set kind UNKNOWN_OWNER
            if {[llength $owners] != 1} {
                issue DRIVER_OWNER_COUNT "" $pname "expected one owner; got [llength $owners]"
            } else {
                lassign [classify_driver_owner [lindex $owners 0] $nid] kind owner ref owner_bank
            }
            if {$kind eq "CONSTANT_ZERO"} { set constant 0 }
            if {$kind eq "CONSTANT_ONE"} { set constant 1 }
            row net_drivers $nid $kind [hx $pname] [hx $owner] [hx $ref] [hx $owner_bank]
            if {$kind in {SELECTED_PRIMITIVE EXTERNAL_DRIVER CONSTANT_ZERO CONSTANT_ONE}} { dict set active $pname 1 }
            if {$kind eq "EXTERNAL_DRIVER"} { dict set external $pname 1 }
    }
    foreach port [get_ports -quiet -of_objects $segments -filter {DIRECTION == IN}] {
            set pname [get_property NAME $port]
            if {[dict exists $seen_driver "PORT:$pname"]} { continue }
            dict set seen_driver "PORT:$pname" 1
            row net_drivers $nid TOP_INPUT [hx $pname] [hx ""] [hx ""] [hx ""]
            dict set active "PORT:$pname" 1
            dict set external "PORT:$pname" 1
    }
    if {$constant ne "UNKNOWN" && [dict size $active] != 1} { issue CONSTANT_MULTIDRIVER "" $nid "constant and other active driver(s)" }
    if {$constant eq "UNKNOWN" && [dict size $active] > 1} { issue MULTIPLE_ACTIVE_DRIVERS "" $nid "[dict size $active] active drivers" }
    if {$constant eq "UNKNOWN" && [dict size $active] == 0} { issue UNDRIVEN_COMPONENT "" $nid "no verified primitive or top-port driver" }
    if {$constant eq "UNKNOWN" && [dict size $external] > 0 && ![dict exists $boundary_input_nets $nid]} {
        issue EXTERNAL_CONE_NOT_CLOSED "" $nid "external driver is not a named logical input boundary"
    }
    row nets $nid [hx [lindex [dict get $net_names $nid] 0]] $constant [llength [dict get $net_names $nid]] [llength [dict get $net_selected_pins $nid]] [dict size $active] [dict size $external]
}
phase graph COMPLETE $next_net "net components and driver owners flushed"

# Global DSP and utilization diagnostics are bound from the earlier sealed
# report recovery. This v4 critical path retains their normalized headers.
set clocks [get_clocks -quiet ap_clk]
if {[llength $clocks] != 1} { issue CLOCK_COUNT "" ap_clk "expected exactly one ap_clk" }
phase diagnostics COMPLETE [llength $clocks] "ap_clk count checked; earlier sealed diagnostics bound separately"
foreach bank $banks {
    set status [expr {$structural_issue_count == 0 ? "EXTRACTED_PROPERTY_JOIN_REQUIRED" : "EXTRACTION_ISSUES_REVIEW_REQUIRED"}]
    row coverage $bank [dict get $cell_counts $bank] [dict get $primitive_counts $bank] [dict get $pin_counts $bank] [dict get $boundary_counts $bank] $status
}
foreach key [dict keys $files] { close [dict get $files $key] }
phase output FLUSHED 11 "all normalized graph tables closed"
if {[sha256_file $dcp] ne $expected_sha} { error "DCP post-run hash drift" }
phase checkpoint POSTCHECK 1 "sealed DCP hash unchanged"
if {$structural_issue_count != 0} {
    phase extraction HELD $structural_issue_count "structural issues in issues.tsv; mapping proof remains held"
    close $ledger
    error "Ws v6 extraction has $structural_issue_count structural issue(s); see issues.tsv"
}
phase extraction COMPLETE 8 "graph ready for structural audit; property gaps=$property_gap_count require explicit join; mapping proof held"
close $ledger
puts "Q8_WS_V6_GRAPH_AND_FUNCSIM_EXTRACTED banks=8 cells=$next_cell pins=$next_pin nets=$next_net proof=REVIEW_REQUIRED"
