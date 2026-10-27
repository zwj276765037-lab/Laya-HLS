# D38 bare kernel: internal 300 MHz clock only; shell IO timing is unspecified.
# No false paths, reset exceptions, IO delays or invented uncertainty are added.
create_clock -name core -period 3.333333333 [get_ports clk]
