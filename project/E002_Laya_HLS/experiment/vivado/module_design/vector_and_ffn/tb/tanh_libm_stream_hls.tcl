set attempt [file normalize $::env(LAYA_TANH_STREAM_ATTEMPT)]
cd $attempt
open_project [file join $attempt hls_project]
set_top tanh_libm_stream_leaf
add_files [file join $attempt frozen_source tanh_libm_stream_bits.cpp] -cflags "-I[file join $attempt frozen_source] -std=c++17 -fno-fast-math -ffp-contract=off"
open_solution solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.666666667 -name default
config_compile -pipeline_loops 0
csynth_design
exit
