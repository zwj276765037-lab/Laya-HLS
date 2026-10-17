# This produces simulation/synthesis sources only; it launches no OOC run.
# Reset is cold fabric reset. Active cancellation must drain the real SI/MI
# transactions and must never reset this converter.
proc create_laya_axi_dwidth {name si_width mi_width} {
  if {$si_width ni {128 512} || $mi_width ni {32 64 128 256 512}} {
    error "unsupported current native service width"
  }
  create_ip -name axi_dwidth_converter -version 2.1 -vendor xilinx.com -library ip -module_name $name
  set_property -dict [list CONFIG.PROTOCOL {AXI4} CONFIG.READ_WRITE_MODE {READ_WRITE} \
    CONFIG.ADDR_WIDTH {64} CONFIG.SI_DATA_WIDTH $si_width CONFIG.MI_DATA_WIDTH $mi_width \
    CONFIG.SI_ID_WIDTH {0} CONFIG.FIFO_MODE {0} CONFIG.ACLK_ASYNC {0}] [get_ips $name]
  generate_target simulation [get_ips $name]
}
