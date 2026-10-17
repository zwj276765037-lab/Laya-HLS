if {[llength $argv] != 1} {error "usage: DCP"}
open_checkpoint [lindex $argv 0]
foreach name {row_valid done_valid cmd_ready rsp_valid rsp_q8 done_status} {
  set port [get_ports $name]
  set nets [get_nets -of_objects $port]
  puts "LNQ_DCP_PORT name=$name port_count=[llength $port] net_count=[llength $nets] nets=$nets"
  foreach net $nets {
    puts "LNQ_DCP_NET name=$name net=$net pins=[get_pins -of_objects $net] cells=[get_cells -of_objects $net]"
  }
}
puts "LNQ_DCP_PORT_CHECK_DONE"
