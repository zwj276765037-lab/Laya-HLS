run 160 us
set top /laya_staged_ln128_pilot_tb/dut/row_engine
set service $top/source_norm_service
set writer $service/writer
foreach pair [list [list $top {writer_flush_req writer_flush_done writer_tile_ready writer_debt_zero}] [list $service {writer_flush_req writer_flush_done writer_tile_ready writer_debt_zero stage_store_state stage_store_error}] [list $writer {flush_req flush_done flushing flush_reported held_valid pack_valid tx_valid fault bad_held b_error}]] {
  lassign $pair base leaves
  foreach leaf $leaves {
    set path $base/$leaf
    if {[llength [get_objects -quiet $path]]} {puts "PROBE $path=[get_value -radix unsigned $path]"}
  }
}
puts "PROBE_TIME [current_time]"
exit
