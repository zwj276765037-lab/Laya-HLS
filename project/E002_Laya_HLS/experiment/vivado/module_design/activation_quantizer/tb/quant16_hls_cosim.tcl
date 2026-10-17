set root [file normalize [file join [file dirname [info script]] .. .. .. ..]]
set module [file join $root vivado module_design activation_quantizer]
set project [file normalize $::env(LAYA_QUANT16_HLS_COSIM_PROJECT)]
open_project $project
set cflags "-I$root/include -I$module/source -std=c++17 -fno-fast-math -ffp-contract=off"
add_files -tb [file join $module tb quant16_hls_tb.cpp] -cflags $cflags
open_solution solution1 -flow_target vivado
set fixture [file join $module rtl quant16_fixture_01]
set arguments [list \
  [file join $fixture wi_source_f32.bin] \
  [file join $fixture wi_q.bin] \
  [file join $fixture wi_scale.bin] \
  [file join $fixture wi_scalar_u32x3.bin] \
  [file join $fixture down_source_f32.bin] \
  [file join $fixture down_q.bin] \
  [file join $fixture down_scale.bin] \
  [file join $fixture down_scalar_u32x3.bin]]
cosim_design -rtl verilog -tool xsim -argv $arguments
exit
