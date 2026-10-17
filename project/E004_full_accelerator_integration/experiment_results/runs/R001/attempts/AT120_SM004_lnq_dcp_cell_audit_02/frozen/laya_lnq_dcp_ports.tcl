if {[llength $argv] != 1} {error "usage: DCP"}
open_checkpoint [lindex $argv 0]
foreach name {row_valid done_valid cmd_ready rsp_valid} {
  set port [get_ports $name]
  set nets [get_nets -of_objects $port]
  puts "LNQ_DCP_PORT name=$name port_count=[llength $port] net_count=[llength $nets] nets=$nets"
  foreach net $nets {
    puts "LNQ_DCP_NET name=$name net=$net pins=[get_pins -of_objects $net] cells=[get_cells -of_objects $net]"
  }
}
foreach cell_name {row_valid_INST_0 done_valid_INST_0 rd_ready_INST_0 row_release_ready_INST_0} {
  set cell [get_cells $cell_name]
  puts "LNQ_DCP_CELL name=$cell_name ref=[get_property REF_NAME $cell] init=[get_property INIT $cell]"
}
puts "LNQ_DCP_PORT_CHECK_DONE"
