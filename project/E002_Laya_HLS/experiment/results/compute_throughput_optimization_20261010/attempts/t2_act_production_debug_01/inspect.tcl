run 1000 ns
foreach p {load_valid load_ready load_done load_error slot_state slot_coverage arvalid arready rvalid rready aux_arvalid aux_arready aux_rvalid aux_rready aux_idx aux_left} {
 puts "ACT_INSPECT $p = [get_value /laya_act_production_tb/$p]"
}
foreach p {fill_busy fill_error seen_done aux_all_done aux_pending aux_phase reader_ready aux_ready header_coverage reader_committed out_valid out_ready} {
 puts "ACT_INSPECT cache.$p = [get_value /laya_act_production_tb/dut/weight_cache/$p]"
}
quit
