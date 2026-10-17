# Read-only bounded prefix: do not change the frozen TB or DUT clocks/stimulus.
run 70 us
set ar_path /lnq0_chain_tb_v1/ln_source/source_ar_count
set r_path /lnq0_chain_tb_v1/ln_source/source_r_count
if {[llength [get_objects -quiet $ar_path]] != 1 ||
    [llength [get_objects -quiet $r_path]] != 1} {
  error "LNQ2 prefix counters unavailable"
}
set ar_value [get_value -radix unsigned $ar_path]
set r_value [get_value -radix unsigned $r_path]
if {[scan $ar_value %d ar_count] != 1 ||
    [scan $r_value %d r_count] != 1 ||
    $ar_count < 1 || $r_count < 1} {
  error "LNQ2 prefix lacks real AR/R: AR=$ar_value R=$r_value"
}
puts "LNQ2_PREFIX_AR_R_PASS time=[current_time] source_AR=$ar_count source_R=$r_count"
exit
