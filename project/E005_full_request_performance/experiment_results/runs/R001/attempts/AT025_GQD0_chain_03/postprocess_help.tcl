foreach c {open_wave_database get_waves get_wave_objects get_value write_vcd export_waveform} {
  puts "GQD_HELP_BEGIN $c"
  catch {help $c} msg
  puts $msg
}
exit
