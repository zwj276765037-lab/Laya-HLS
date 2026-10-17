if {![info exists ::env(LAYA_Q8S2_HLS_PROJECT)] ||
    ![info exists ::env(LAYA_Q8S2_PACKAGE)]} {
    error "LAYA_Q8S2_HLS_PROJECT and LAYA_Q8S2_PACKAGE required"
}
set module [file normalize [file join [file dirname [info script]] ..]]
set root [file normalize [file join $module .. .. .. ..]]
set package [file normalize $::env(LAYA_Q8S2_PACKAGE)]
if {![file isfile [file join $package laya_model_layout_generated.h]]} {
    error "actual Q8S2 package header required"
}
open_project -reset [file normalize $::env(LAYA_Q8S2_HLS_PROJECT)]
set_top q8_tm1tn8_session_dma_v2
set cflags "-I$root/include -I$package -I$module/source -std=c++17 -O2 -fno-fast-math -ffp-contract=off"
add_files [file join $module source q8_tm1tn8_session_dma_v2.cpp] -cflags $cflags
open_solution -reset solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.667 -name default
config_compile -pipeline_loops 0
config_array_partition -throughput_driven off -complete_threshold 0
csynth_design
exit
