# Compact, checkpoint-only Ws graph extraction. Source preparation only until
# a separate execution gate is approved. Arbitrary names/values are hex UTF-8.
if {[llength $argv] != 2} { error "usage: extract_ws_graph.tcl SEALED_DCP FRESH_REPORT_DIR" }
lassign $argv dcp outdir
set dcp [file normalize $dcp]
set outdir [file normalize $outdir]
set expected_dcp "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/top_synth_v1_entry_a2_reports/q8_joint_tm4tn8_ooc_synth.dcp"
set expected_outdir "/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/ws_dcp_connectivity_v1_reports"
set expected_sha c480c9334ed20d775c5a768e077b15fa9ad1932cb6535ae639d9b9524c11f1ce
if {$dcp ne $expected_dcp || $outdir ne $expected_outdir} { error "unreviewed DCP/output path" }
if {![file isfile $dcp] || ![catch {file lstat $outdir st}]} { error "missing DCP or report path not fresh" }
proc sha256_file {path} { return [lindex [split [string trim [exec /usr/bin/sha256sum -- $path]]] 0] }
if {[sha256_file $dcp] ne $expected_sha} { error "DCP input hash drift" }
file mkdir $outdir
set_param general.maxThreads 4
open_checkpoint $dcp

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
    global issue_count
    incr issue_count
    row issues $code [hx $bank] [hx $object] [hx $detail]
}
proc opt_prop {object key} {
    if {[lsearch -exact [list_property $object] $key] < 0} { return "" }
    return [get_property $key $object]
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

# The sole whole-design traversal is a batched cell-name read. All further
# per-cell property and pin work is restricted to the exact eight bank roots.
set all_cells [get_cells -quiet -hierarchical -include_replicated_objects *]
set all_names [get_property NAME $all_cells]
if {[llength $all_cells] != [llength $all_names]} { error "cell/name batch mismatch" }
set selected [dict create]
foreach cell $all_cells name $all_names {
    set bank [bank_of $name]
    if {$bank ne ""} { dict set selected $name [list $bank $cell] }
}
unset all_cells
unset all_names
foreach bank $banks {
    if {![dict exists $selected $bank]} { issue MISSING_BANK $bank $bank "no exact hierarchy root" }
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
    set segments [get_nets -quiet -segments -of_objects [lindex $local 0]]
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
foreach name [lsort [dict keys $selected]] {
    lassign [dict get $selected $name] bank cell
    set cid "c[incr next_cell]"
    dict set cell_ids $name $cid
    dict incr cell_counts $bank
    set ref [get_property REF_NAME $cell]
    set primitive_flag [opt_prop $cell IS_PRIMITIVE]
    if {$primitive_flag eq ""} { issue MISSING_PRIMITIVE_FLAG $bank $name "IS_PRIMITIVE unavailable" }
    set primitive [expr {$primitive_flag eq "1" || [string equal -nocase $primitive_flag "true"]}]
    if {$primitive} { dict incr primitive_counts $bank }
    set parent [string range $name 0 [expr {[string last / $name] - 1}]]
    row cells $cid $bank [hx $name] [hx $parent] [hx $ref] [hx [opt_prop $cell PRIMITIVE_TYPE]] [expr {$primitive ? 1 : 0}]
    if {$primitive} {
        foreach key [lsort -unique [list_property $cell]] {
            if {[catch {get_property $key $cell} value]} {
                row properties $cid [hx $key] [hx $value] ERROR
                issue PROPERTY_READ_FAILED $bank $name "$key: $value"
            } else {
                row properties $cid [hx $key] [hx $value] OK
            }
        }
        if {[string match LUT? $ref] && [lsearch -exact [list_property $cell] INIT] < 0} {
            issue MISSING_LUT_INIT $bank $name "LUT INIT unavailable"
        }
    }
    set cell_pins [get_pins -quiet -of_objects $cell]
    set by_name [dict create]
    foreach pin $cell_pins { dict set by_name [get_property NAME $pin] $pin }
    foreach pin_name [lsort [dict keys $by_name]] {
        set pin [dict get $by_name $pin_name]
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
        row pins $pid $cid [hx $pin_name] [hx [opt_prop $pin REF_PIN_NAME]] [get_property DIRECTION $pin] $nid
    }
}

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

# Each component is serialized once. Only driver pins/ports are queried from
# the whole component; selected-bank incident pins came from the pin table.
foreach nid [lsort -dictionary [dict keys $net_examples]] {
    set example [dict get $net_examples $nid]
    set segments [get_nets -quiet -segments -of_objects $example]
    set seen_driver [dict create]
    set constant UNKNOWN
    set active [dict create]
    set external [dict create]
    foreach segment $segments {
        set sname [get_property NAME $segment]
        row net_segments $nid [hx $sname] [hx [opt_prop $segment TYPE]]
        foreach pin [get_pins -quiet -of_objects $segment -filter {DIRECTION == OUT}] {
            set pname [get_property NAME $pin]
            if {[dict exists $seen_driver $pname]} { continue }
            dict set seen_driver $pname 1
            set owners [get_cells -quiet -of_objects $pin]
            set owner ""
            set ref ""
            if {[llength $owners] > 0} {
                set owner [get_property NAME [lindex $owners 0]]
                set ref [get_property REF_NAME [lindex $owners 0]]
            }
            set owner_bank [bank_of $owner]
            set kind HIERARCHY_ALIAS
            if {$ref eq "GND"} { set kind CONSTANT_ZERO; set constant 0 }
            if {$ref eq "VCC"} { set kind CONSTANT_ONE; set constant 1 }
            if {$kind eq "HIERARCHY_ALIAS" && $owner_bank ne "" && [dict exists $cell_ids $owner]} {
                lassign [dict get $selected $owner] obank ocell
                set flag [opt_prop $ocell IS_PRIMITIVE]
                if {$flag eq "1" || [string equal -nocase $flag true]} { set kind SELECTED_PRIMITIVE }
            } elseif {$kind eq "HIERARCHY_ALIAS" && $owner_bank eq ""} { set kind EXTERNAL_DRIVER }
            row net_drivers $nid $kind [hx $pname] [hx $owner] [hx $ref] [hx $owner_bank]
            if {$kind in {SELECTED_PRIMITIVE EXTERNAL_DRIVER CONSTANT_ZERO CONSTANT_ONE}} { dict set active $pname 1 }
            if {$kind eq "EXTERNAL_DRIVER"} { dict set external $pname 1 }
        }
        foreach port [get_ports -quiet -of_objects $segment -filter {DIRECTION == IN}] {
            set pname [get_property NAME $port]
            if {[dict exists $seen_driver "PORT:$pname"]} { continue }
            dict set seen_driver "PORT:$pname" 1
            row net_drivers $nid TOP_INPUT [hx $pname] [hx ""] [hx ""] [hx ""]
            dict set active "PORT:$pname" 1
            dict set external "PORT:$pname" 1
        }
    }
    if {$constant ne "UNKNOWN" && [dict size $active] != 1} { issue CONSTANT_MULTIDRIVER "" $nid "constant and other active driver(s)" }
    if {$constant eq "UNKNOWN" && [dict size $active] > 1} { issue MULTIPLE_ACTIVE_DRIVERS "" $nid "[dict size $active] active drivers" }
    if {$constant eq "UNKNOWN" && [dict size $external] > 0 && ![dict exists $boundary_input_nets $nid]} {
        issue EXTERNAL_CONE_NOT_CLOSED "" $nid "external driver is not a named logical input boundary"
    }
    row nets $nid [hx [lindex [dict get $net_names $nid] 0]] $constant [llength [dict get $net_names $nid]] [llength [dict get $net_selected_pins $nid]] [dict size $active] [dict size $external]
}

# One filtered DSP inventory is an auxiliary attribution aid, not the Ws graph.
foreach cell [get_cells -quiet -hierarchical -filter {REF_NAME =~ DSP*}] {
    set name [get_property NAME $cell]
    set parent [string range $name 0 [expr {[string last / $name] - 1}]]
    row global_dsp [hx $name] [hx $parent] [hx [get_property REF_NAME $cell]]
}
report_utilization -hierarchical -hierarchical_min_primitive_count 0 -file [file join $outdir utilization_all_hierarchies.rpt]
set clocks [get_clocks -quiet ap_clk]
if {[llength $clocks] != 1} { issue CLOCK_COUNT "" ap_clk "expected exactly one ap_clk" }
foreach clock $clocks {
    set cname [get_property NAME $clock]
    foreach key [lsort -unique [list_property $clock]] {
        if {[catch {get_property $key $clock} value]} {
            row clock_properties [hx $cname] [hx $key] [hx $value] ERROR
            issue CLOCK_PROPERTY_READ_FAILED "" $cname "$key: $value"
        } else { row clock_properties [hx $cname] [hx $key] [hx $value] OK }
    }
}
foreach bank $banks {
    set status [expr {$issue_count == 0 ? "EXTRACTED_REVIEW_REQUIRED" : "EXTRACTION_ISSUES_REVIEW_REQUIRED"}]
    row coverage $bank [dict get $cell_counts $bank] [dict get $primitive_counts $bank] [dict get $pin_counts $bank] [dict get $boundary_counts $bank] $status
}
foreach key [dict keys $files] { close [dict get $files $key] }
if {[sha256_file $dcp] ne $expected_sha} { error "DCP post-run hash drift" }
if {$issue_count != 0} { error "compact Ws extraction has $issue_count coverage issue(s); see issues.tsv" }
puts "Q8_WS_COMPACT_GRAPH_EXTRACTED banks=8 cells=$next_cell pins=$next_pin nets=$next_net proof=REVIEW_REQUIRED"
