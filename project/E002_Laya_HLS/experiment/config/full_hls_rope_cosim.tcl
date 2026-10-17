set root [file normalize [file join [file dirname [info script]] ..]]
set project [file normalize $::env(LAYA_FULL_HLS_PROBE_PROJECT)]
open_project -reset $project
set_top full_rope_cosim_top
set cflags "-I$root/include -std=c++17 -fno-fast-math -ffp-contract=off"
add_files [file join $root hls common laya_numeric.cpp] -cflags $cflags
add_files [file join $root hls operators rope_full_compute.cpp] -cflags $cflags
add_files [file join $root hls operators full_rope_cosim_wrapper.cpp] -cflags $cflags
add_files -tb [file join $root vivado module_design rope_and_mask tb full_rope_cosim_tb.cpp] -cflags $cflags
open_solution -reset solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.667 -name default
csynth_design
cosim_design -rtl verilog -tool xsim
exit
