create_clock -name core -period 3.333333 [get_ports ap_clk]
set_clock_uncertainty 0.100 [get_clocks core]
set_input_delay -clock core 0.500 [get_ports -filter {DIRECTION == IN && NAME != ap_clk}]
set_output_delay -clock core 0.500 [all_outputs]
