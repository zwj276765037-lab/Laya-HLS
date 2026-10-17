set root [file normalize [file join [file dirname [info script]] .. .. .. ..]]
set module [file join $root vivado module_design activation_quantizer]
set project [file normalize $::env(LAYA_QUANT16_HLS_SYNTH_PROJECT)]
open_project -reset $project
set_top laya_quant16_functional
set cflags "-I$root/include -I$module/source -std=c++17 -fno-fast-math -ffp-contract=off"
add_files [file join $module source quant16_hls_top.cpp] -cflags $cflags
add_files [file join $module source quant16.cpp] -cflags $cflags
add_files [file join $root hls common laya_numeric.cpp] -cflags $cflags
open_solution -reset solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.667 -name default
config_compile -pipeline_loops 0
config_array_partition -throughput_driven off -complete_threshold 0
csynth_design
exit
