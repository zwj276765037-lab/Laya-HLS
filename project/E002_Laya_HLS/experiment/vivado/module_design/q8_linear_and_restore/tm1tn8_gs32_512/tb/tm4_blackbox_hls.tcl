if {![info exists ::env(LAYA_BLACKBOX_WORK)] || ![info exists ::env(LAYA_BLACKBOX_PHASE)]} {error "LAYA_BLACKBOX_WORK and LAYA_BLACKBOX_PHASE required"}
set work [file normalize $::env(LAYA_BLACKBOX_WORK)]
set phase $::env(LAYA_BLACKBOX_PHASE)
if {$phase ni {csim synth}} {error "phase must be csim or synth"}
set module [file normalize [file join [file dirname [info script]] ..]]
set root [file normalize [file join $module .. .. .. ..]]
set bb [file join $module source blackbox]
if {$phase == "synth"} {
  open_project [file join $work hls_project]
  open_solution solution1
  csynth_design
  puts "ACT_TM4_BLACKBOX_SYNTHESIS_COMPLETE"
  exit
}
open_project -reset [file join $work hls_project]
set_top laya_tm4_blackbox_smoke
add_files -blackbox [file join $bb laya_tm4_group_service.json]
# Re-register the sole JSON C model after blackbox registration; Vitis2025.2
# otherwise rewrites existing design paths relative to the wrong project base.
add_files [file join $bb laya_tm4_group_service.cpp] -cflags "-I[file join $root include] -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"
add_files [file join $bb laya_tm4_blackbox_smoke.cpp] -cflags "-I$bb -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"
add_files [file join $root hls common laya_numeric.cpp] -cflags "-I[file join $root include] -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"
add_files -tb [file join $module tb tm4_blackbox_csim_tb.cpp] -cflags "-I[file join $root include] -std=c++17 -fno-fast-math -fno-associative-math -ffp-contract=off"
open_solution solution1 -flow_target vivado
set_part xcu55c-fsvh2892-2L-e
create_clock -period 6.667 -name default
config_compile -pipeline_loops 0
config_interface -clock_enable
csim_design -O
puts "ACT_TM4_BLACKBOX_CSIM_PASS"
exit
