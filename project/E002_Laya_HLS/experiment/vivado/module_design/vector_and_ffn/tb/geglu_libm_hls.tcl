set attempt [file normalize $::env(LAYA_GEGLU_ATTEMPT)]
cd $attempt
open_project [file join $attempt hls_project]
set_top geglu_libm_leaf
foreach name {tanh_libm_bits.cpp gelu_libm_bits.cpp} {
 add_files [file join $attempt frozen_source $name] -cflags "-I[file join $attempt frozen_source] -std=c++17 -fno-fast-math -ffp-contract=off"
}
open_solution solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.666666667 -name default
config_compile -pipeline_loops 0
csynth_design
exit
