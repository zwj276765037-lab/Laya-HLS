set attempt [file normalize $::env(LAYA_ATTENTION_ATTEMPT)]
cd $attempt
open_project [file join $attempt hls_project]
set_top attention_exp_leaf
add_files [file join $attempt frozen_source attention_exp_bits.cpp] -cflags "-I[file join $attempt frozen_source] -std=c++17 -fno-fast-math -ffp-contract=off"
open_solution solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 3.333333333 -name default
config_compile -pipeline_loops 0
csynth_design
exit
