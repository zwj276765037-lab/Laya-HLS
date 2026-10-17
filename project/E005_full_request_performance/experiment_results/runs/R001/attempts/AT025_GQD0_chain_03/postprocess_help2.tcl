load_features simulator
foreach c {open_wave_database get_waves get_value get_wave_value write_waveform export_waveform} {
  puts "GQD_HELP_BEGIN $c"
  catch {help $c} msg
  puts $msg
}
exit
