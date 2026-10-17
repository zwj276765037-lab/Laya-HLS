if {[llength $argv] != 8} {
  error "usage: MODE WORK FROZEN LEAF SKIP DOWN GOLD ADD"
}
lassign $argv mode work frozen leaf skip_file down_file gold_file add_file
if {$mode ni {static error pilot full}} {error "bad FFR1 mode"}
set_param general.maxThreads 4
create_project ffr1_v1 [file join $work vivado] -part xcu55c-fsvh2892-2L-e
add_files -norecurse $leaf
add_files -norecurse [file join $frozen laya_ffn_fadd_slot_v1.sv]
add_files -norecurse [file join $frozen laya_ffn_residual_four_row_v1.sv]
add_files -fileset sim_1 [file join $frozen laya_ffn_fadd_slot_v1_tb.sv]
add_files -fileset sim_1 [file join $frozen laya_ffn_residual_four_row_ffr1_tb.sv]
set top laya_ffn_residual_four_row_ffr1_tb
set_property top $top [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
set plusargs "-testplusarg ADD_FILE=$add_file -testplusarg SKIP_FILE=$skip_file -testplusarg DOWN_FILE=$down_file -testplusarg GOLD_FILE=$gold_file"
if {$mode eq "pilot"} {append plusargs " -testplusarg PILOT=1"}
if {$mode eq "error"} {append plusargs " -testplusarg ERROR_ONLY=1"}
set_property -name xsim.simulate.xsim.more_options -value $plusargs -objects [get_filesets sim_1]
launch_simulation -mode behavioral -step compile
launch_simulation -mode behavioral -step elaborate
puts FFR1_STATIC_PASS
if {$mode ne "static"} {
  puts FFR1_SIM_START
  flush stdout
  launch_simulation -mode behavioral -step simulate
  puts FFR1_SIM_FINISHED
}
close_project
