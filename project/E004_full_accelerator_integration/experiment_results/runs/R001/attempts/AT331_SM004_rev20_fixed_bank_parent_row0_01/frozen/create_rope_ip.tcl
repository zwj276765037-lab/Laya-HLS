if {[llength $argv] != 2} {error "usage: WORK FROZEN"}
lassign $argv work frozen
set_param general.maxThreads 4
create_project rope_fp [file join $work rope_ip] -part xcu55c-fsvh2892-2L-e
source [file join $frozen rope_head_fmul_32ns_32ns_32_3_max_dsp_1_ip.tcl]
source [file join $frozen rope_head_faddfsub_32ns_32ns_32_4_full_dsp_1_ip.tcl]
puts ROPE_FP_IP_GENERATED
close_project
