# One actual optimization of the complete, source-bound matrix core checkpoint.
set stage [lindex $argv 0]
set at [file normalize [lindex $argv 1]]
set run [file normalize [lindex $argv 2]]
set part xcu55c-fsvh2892-2L-e
set expected_top laya_m007_matrix_engine_v1
set cp [file join $run checkpoints]
set out [file join $at reports]
file mkdir $out
set_param general.maxThreads 4

proc save_text {path value} {
    set stream [open $path w]
    puts $stream $value
    close $stream
}

proc required_report {name script} {
    puts "M007_D38_REPORT_BEGIN $name"
    uplevel 1 $script
    puts "M007_D38_REPORT_END $name"
}

proc boundary_snapshot {label} {
    global out part expected_top
    # A checkpoint-only session has a checkpoint container NAME and an empty
    # fileset TOP. Verify the loaded netlist through its actual report header.
    set utilization_path [file join $out ${label}_utilization.rpt]
    required_report ${label}_utilization {report_utilization -file $utilization_path}
    set stream [open $utilization_path r]
    set utilization [read $stream]
    close $stream
    if {![regexp -line {^\|[ \t]*Design[ \t]*:[ \t]*([^ \t\r\n|]+)} $utilization unused actual_top]} {
        error "No Design identity in actual utilization report"
    }
    if {![regexp -line {^\|[ \t]*Device[ \t]*:[ \t]*([^ \t\r\n|]+)} $utilization unused actual_part]} {
        error "No Device identity in actual utilization report"
    }
    save_text [file join $out ${label}_design_identity.tsv] \
        "design_object_name\t[get_property NAME [current_design]]\nfileset_top\t[get_property TOP [current_fileset]]\nactual_report_design\t$actual_top\nactual_report_device\t$actual_part\nexpected_top\t$expected_top"
    if {$actual_top ne $expected_top} {error "Wrong core top: report Design=$actual_top expected=$expected_top"}
    if {$actual_part ne $part} {error "Wrong core part: report Device=$actual_part expected=$part"}
    if {[get_property PART [current_project]] ne $part} {error "Wrong core part"}
    set bb [get_cells -quiet -hierarchical -filter {IS_BLACKBOX == 1}]
    if {[llength $bb]} {error "Core blackboxes: $bb"}
    set ports {}
    set port_objects [get_ports -quiet]
    set port_names [get_property NAME $port_objects]
    set port_directions [get_property DIRECTION $port_objects]
    foreach name $port_names direction $port_directions {
        lappend ports [list $name $direction]
    }
    set clocks {}
    foreach clock [get_clocks -quiet] {
        lappend clocks [list [get_property NAME $clock] [get_property PERIOD $clock] \
            [get_property WAVEFORM $clock] [lsort [get_property SOURCE_PINS $clock]]]
    }
    # Vivado may expose clock periods on its 1 ps grid. The original XDC is
    # SHA-bound, and before/after signatures still require exact equality.
    if {[llength $clocks] != 1 || [lindex $clocks 0 0] ne "core" || \
        abs([lindex $clocks 0 1] - 3.333333333) > 0.001} {
        error "Core 300 MHz clock boundary changed: $clocks"
    }
    write_xdc -force [file join $out ${label}_constraints.xdc]
    set stream [open [file join $out ${label}_constraints.xdc] r]
    set constraints {}
    foreach line [split [read $stream] "\n"] {
        set line [string trim $line]
        if {$line ne "" && ![string match {#*} $line]} {lappend constraints $line}
    }
    close $stream
    set signature [list top $expected_top part $part blackboxes 0 \
        ports [lsort $ports] clocks [lsort $clocks] constraints [lsort $constraints]]
    save_text [file join $out ${label}_boundary.tcllist] $signature
    save_text [file join $out ${label}_ports.tsv] [join [lsort $ports] "\n"]
    save_text [file join $out ${label}_clocks.tcllist] [lsort $clocks]
    return $signature
}

proc direct_primitive_summary {label} {
    global out
    puts "M007_D38_DIRECT_PRIMITIVES_BEGIN $label"
    # Without -hierarchical, get_cells selects only current top-level cells.
    set cells [get_cells -quiet -filter {IS_PRIMITIVE == 1}]
    set refs [get_property REF_NAME $cells]
    set counts [dict create]
    set groups [dict create]
    set samples [dict create]
    set overflow 0
    foreach cell $cells ref $refs {
        dict incr counts $ref
        set name $cell
        # Bounded lexical grouping, deliberately not a claim about RTL causality.
        set group [lindex [split $name {[}] 0]
        regsub -all {[0-9]+} $group {#} group
        regsub {(_reg)?_i(_#)+$} $group {} group
        set key [list $ref $group]
        if {![dict exists $groups $key] && [dict size $groups] >= 4096} {
            set key [list $ref __OTHER_BOUNDED_GROUPS__]
            incr overflow
        }
        dict incr groups $key
        if {![dict exists $samples $key] || [llength [dict get $samples $key]] < 3} {
            dict lappend samples $key $cell
        }
    }
    set stream [open [file join $out ${label}_direct_primitive_counts.tsv] w]
    puts $stream "primitive\tcount"
    foreach ref [lsort [dict keys $counts]] {puts $stream "$ref\t[dict get $counts $ref]"}
    close $stream
    set rows {}
    dict for {key count} $groups {lappend rows [list $count $key]}
    set stream [open [file join $out ${label}_direct_name_groups.tsv] w]
    puts $stream "count\tprimitive\tnormalized_name\tup_to_3_actual_cell_names"
    set source_stream [open [file join $out ${label}_direct_source_samples.tsv] w]
    puts $source_stream "cell\tproperty\tvalue"
    set property_names {}
    if {[llength $cells]} {
        set property_names [list_property [lindex $cells 0]]
    }
    save_text [file join $out ${label}_available_cell_properties.txt] [join $property_names "\n"]
    set source_properties {}
    foreach property {ORIG_CELL_NAME ORIG_REF_NAME FILE_NAME LINE_NUMBER HDL_FILE HDL_LINE SOURCE_FILE SOURCE_LINE} {
        if {$property in $property_names} {lappend source_properties $property}
    }
    foreach row [lrange [lsort -integer -decreasing -index 0 $rows] 0 255] {
        lassign $row count key
        lassign $key ref group
        puts $stream "$count\t$ref\t$group\t[dict get $samples $key]"
        foreach cell [dict get $samples $key] {
            foreach property $source_properties {
                puts $source_stream "$cell\t$property\t[get_property $property $cell]"
            }
        }
    }
    close $stream
    close $source_stream
    save_text [file join $out ${label}_direct_scope.txt] \
        "scope=direct primitives of complete core top\ntotal=[llength $cells]\nnormalized_groups=[dict size $groups]\nmax_groups=4096 plus per-primitive OTHER buckets\nexported_top_groups=256\nmax_samples_per_group=3\noverflow_cells=$overflow\nlexical_grouping_is_not_RTL_causality=1\nsource_properties=$source_properties"
    puts "M007_D38_DIRECT_PRIMITIVES_END $label cells=[llength $cells]"
}

proc resource_reports {label} {
    global out
    # boundary_snapshot already emitted this actual utilization report.
    if {![file exists [file join $out ${label}_utilization.rpt]]} {
        required_report ${label}_utilization {report_utilization -file [file join $out ${label}_utilization.rpt]}
    }
    required_report ${label}_hierarchical_utilization {report_utilization -hierarchical -file [file join $out ${label}_utilization_hierarchical.rpt]}
    required_report ${label}_ram {report_ram_utilization -file [file join $out ${label}_ram_utilization.rpt]}
    required_report ${label}_clocks {report_clocks -file [file join $out ${label}_clocks.rpt]}
    direct_primitive_summary $label
}

proc timing_path_metadata {label paths} {
    global out
    set lines [list "path_count\t[llength $paths]"]
    if {[llength $paths]} {
        set path [lindex $paths 0]
        set properties [list_property $path]
        save_text [file join $out ${label}_available_path_properties.txt] [join $properties "\n"]
        foreach property {STARTPOINT_PIN ENDPOINT_PIN STARTPOINT_CLOCK ENDPOINT_CLOCK PATH_GROUP GROUP SLACK REQUIREMENT DATAPATH_DELAY LOGIC_LEVELS LOGIC_DELAY NET_DELAY DATAPATH_LOGIC_DELAY DATAPATH_NET_DELAY SKEW CORNER} {
            if {$property in $properties} {
                lappend lines "$property\t[get_property $property $path]"
            } else {
                lappend lines "$property\tPROPERTY_NOT_AVAILABLE"
            }
        }
    }
    save_text [file join $out ${label}_path_properties.tsv] [join $lines "\n"]
}

proc critical_path_reports {} {
    global out
    puts "M007_D38_OPTIMIZED_CRITICAL_PATHS_BEGIN"
    set worst [get_timing_paths -delay_type max -max_paths 1 -nworst 1]
    if {![llength $worst]} {error "No optimized global setup path is available"}
    timing_path_metadata optimized_worst_setup $worst
    required_report optimized_worst_setup {
        report_timing -of_objects $worst -input_pins -file [file join $out optimized_worst_setup.rpt]
    }
    # Cell selection is an exact NAME comparison, not a wildcard match on [1].
    set launch [get_cells -quiet -filter {NAME == "n_reg[1]"}]
    set capture [get_cells -quiet -filter {NAME == "error_col_reg[0]"}]
    set endpoint {}
    if {[llength $capture] == 1} {
        foreach pin [get_pins -quiet -of_objects $capture] {
            if {[file tail [get_property NAME $pin]] eq "CE"} {lappend endpoint $pin}
        }
    }
    set query [list {baseline_source=n_reg[1]/C} {baseline_destination=error_col_reg[0]/CE} \
        {baseline_logic_levels=6091} "launch_matches=[llength $launch]" \
        "capture_matches=[llength $capture]" "CE_matches=[llength $endpoint]" \
        {missing_or_merged_objects_are_not_zero_slack=1}]
    save_text [file join $out fixed_baseline_path_query.txt] [join $query "\n"]
    set fixed {}
    if {[llength $launch] == 1 && [llength $endpoint] == 1} {
        set fixed [get_timing_paths -from $launch -to $endpoint -delay_type max -max_paths 1 -nworst 1]
    }
    timing_path_metadata optimized_fixed_baseline_setup $fixed
    if {[llength $fixed]} {
        required_report optimized_fixed_baseline_setup {
            report_timing -of_objects $fixed -input_pins -file [file join $out optimized_fixed_baseline_setup.rpt]
        }
    } else {
        save_text [file join $out optimized_fixed_baseline_setup.unavailable.txt] \
            "Original fixed path not returned after optimization; inspect actual object-match counts and the new global worst path. This is not zero slack or timing acceptance."
    }
    puts "M007_D38_OPTIMIZED_CRITICAL_PATHS_END"
}

proc run_diagnostic {} {
    global stage at run cp part out
    puts "M007_D38_CORE_DIAGNOSTIC_BEGIN stage=$stage"
    puts "M007_D38_TOOL [version -short]"
    create_project -in_memory -part $part
    switch -- $stage {
        core_opt {
            open_checkpoint [file join $cp core_synth.dcp]
            set before [boundary_snapshot before]
            resource_reports before
            # The independent guard refuses every second invocation of this stage.
            save_text [file join $at opt_invoked.txt] "opt_design\ninvocations=1\nsource_checkpoint=core_synth.dcp"
            puts "M007_D38_CORE_OPT_DESIGN_BEGIN invocation=1"
            opt_design
            puts "M007_D38_CORE_OPT_DESIGN_END invocation=1"
            # Save immediately, so a later report failure never requires re-optimization.
            write_checkpoint [file join $cp core_opt.dcp]
            save_text [file join $at opt_checkpoint_written.txt] "candidate=core_opt.dcp\nfull_kernel_accepted=0"
            set after [boundary_snapshot after]
            if {$before ne $after} {error "Complete core port/clock/constraint boundary changed"}
            save_text [file join $at boundary_preserved.txt] "ports_clocks_constraints_equal=1\nblackboxes=0"
        }
        report_core_opt {
            open_checkpoint [file join $cp core_opt.dcp]
            boundary_snapshot optimized
            resource_reports optimized
            critical_path_reports
        }
        default {error "Unauthorized core diagnostic stage: $stage"}
    }
    save_text [file join $at stage_complete.txt] "stage=$stage\nfull_kernel_accepted=0\nno_RTL_or_tieoff_change=1"
    puts "M007_D38_STAGE_PASS stage=$stage full_kernel_accepted=0"
}

if {[catch {run_diagnostic} message options]} {
    save_text [file join $at stage_error.txt] "$message\n[dict get $options -errorinfo]"
    puts stderr "M007_D38_STAGE_FAIL stage=$stage error=$message"
    exit 1
}
exit 0
