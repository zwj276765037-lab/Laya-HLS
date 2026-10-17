run 160 us
set top /laya_staged_ln128_pilot_tb/dut/row_engine
set service $top/source_norm_service
foreach leaf {state core_row_valid core_done_valid core_release_valid core_release_ready writer_fault writer_flush_done writer_debt_zero writer_tile_ready writer_aw_count writer_w_count writer_b_count} {
  set path $top/$leaf
  if {[llength [get_objects -quiet $path]]} {puts "PROBE $leaf=[get_value -radix unsigned $path]"}
}
foreach leaf {stage_store_state stage_store_tile_count stage_store_ok_b stage_store_error stage_store_read_pending stage_store_rsp_valid stage_store_rsp_ready stage_store_release_valid stage_store_done_valid} {
  set path $service/$leaf
  if {[llength [get_objects -quiet $path]]} {puts "PROBE $leaf=[get_value -radix unsigned $path]"}
}
puts "PROBE_TIME [current_time]"
exit
