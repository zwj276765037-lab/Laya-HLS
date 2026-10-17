set root [file normalize [file join [file dirname [info script]] ..]]
set project [file normalize $::env(LAYA_NUMERIC_HLS_SYNTH_PROJECT)]
open_project -reset $project
set_top activation_quantizer_compute
set cflags "-I$root/include -std=c++17 -fno-fast-math -ffp-contract=off"
add_files [file join $root hls common laya_numeric.cpp] -cflags $cflags
add_files [file join $root hls operators activation_quantizer_compute.cpp] -cflags $cflags
open_solution -reset solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.667 -name default
csynth_design
exit
