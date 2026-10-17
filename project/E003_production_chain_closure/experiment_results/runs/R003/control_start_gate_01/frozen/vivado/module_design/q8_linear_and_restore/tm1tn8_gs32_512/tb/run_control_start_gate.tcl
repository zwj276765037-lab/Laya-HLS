set root [file normalize [file join [file dirname [info script]] ../../../../..]]
set out [lindex $argv 0]
read_verilog -sv [file join $root vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_control_start_gate_v1.sv]
read_verilog -sv [file join $root vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_control_start_gate_tb_v1.sv]
set_property top laya_control_start_gate_tb_v1 [current_fileset]
launch_simulation -simset sim_1 -mode behavioral
run all
quit
