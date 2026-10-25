create_clock -name q_clk -period 3.333 [get_ports clk]
set_input_delay 0.5 -clock q_clk [get_ports -filter {DIRECTION == IN && NAME != clk}]
set_output_delay 0.5 -clock q_clk [all_outputs]
