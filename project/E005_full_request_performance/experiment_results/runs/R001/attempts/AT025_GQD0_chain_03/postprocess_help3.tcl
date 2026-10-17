load_features simulator
foreach c {current_time set_property get_property get_objects report_values} {
  puts "GQD_HELP_BEGIN $c"
  catch {help $c} msg
  puts $msg
}
exit
