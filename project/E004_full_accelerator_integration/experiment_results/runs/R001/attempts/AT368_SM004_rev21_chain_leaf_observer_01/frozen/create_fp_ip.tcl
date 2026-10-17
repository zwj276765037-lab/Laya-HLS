# Source from a fresh xcu55c-fsvh2892-2L-e Vivado project. The three
# project-local core types instantiate 8 convert, 16 multiply and 8 add lanes
# in tm1tn8_fp_restore. Actual pins/resources require generation and OOC.
if {[get_property PART [current_project]] ne "xcu55c-fsvh2892-2L-e"} {
    error "TM1TN8 FP part mismatch"
}
foreach kind {sitofp fmul fadd} {
    set name tm1tn8_${kind}_ip
    if {[llength [get_ips -quiet $name]]} { error "FP IP already exists: $name" }
    create_ip -name floating_point -version 7.1 -vendor xilinx.com \
        -library ip -module_name $name
    set common [list CONFIG.c_rate 1 CONFIG.flow_control NonBlocking \
        CONFIG.c_optimization Speed_Optimized \
        CONFIG.c_result_exponent_width 8 CONFIG.c_result_fraction_width 24 \
        CONFIG.result_precision_type Single \
        CONFIG.has_a_tlast false CONFIG.has_a_tuser false \
        CONFIG.has_b_tlast false CONFIG.has_b_tuser false \
        CONFIG.has_result_tready false CONFIG.has_aresetn true \
        CONFIG.maximum_latency true]
    if {$kind eq "sitofp"} {
        set specific [list CONFIG.operation_type Fixed_to_Float \
            CONFIG.a_precision_type Custom \
            CONFIG.c_a_exponent_width 32 CONFIG.c_a_fraction_width 0 \
            CONFIG.c_mult_usage No_Usage \
            CONFIG.has_aclken false]
    } elseif {$kind eq "fmul"} {
        set specific [list CONFIG.operation_type Multiply \
            CONFIG.a_precision_type Single \
            CONFIG.c_a_exponent_width 8 CONFIG.c_a_fraction_width 24 \
            CONFIG.c_mult_usage Max_Usage \
            CONFIG.has_aclken false]
    } else {
        set specific [list CONFIG.operation_type Add_Subtract \
            CONFIG.add_sub_value Add CONFIG.a_precision_type Single \
            CONFIG.c_a_exponent_width 8 CONFIG.c_a_fraction_width 24 \
            CONFIG.c_mult_usage Full_Usage \
            CONFIG.has_aclken true]
    }
    set_property -dict [concat $common $specific] [get_ips $name]
    set expected_latency [expr {$kind eq "fadd" ? 11 : 6}]
    set actual_latency [get_property CONFIG.C_LATENCY [get_ips $name]]
    if {$actual_latency != $expected_latency} {
        error "FP IP latency changed: $name actual=$actual_latency expected=$expected_latency"
    }
    set xci [get_files -quiet ${name}.xci]
    if {[llength $xci] != 1} { error "FP XCI missing: $name" }
    set_property generate_synth_checkpoint false $xci
    generate_target {synthesis simulation} $xci
    puts "TM1TN8_FP_IP_READY $name [get_property IP_FILE [get_ips $name]]"
}
