if {[llength $argv] != 2} {error "usage: DCP WORK"}
lassign $argv dcp work
open_checkpoint $dcp
set out [open [file join $work targeted_endpoints.tsv] w]
puts $out "group\tcell_matches\tstorage_matches\tdata_pin_matches\tstorage_refs\treport"
proc target_group {group pattern work out} {
  set cells [get_cells -quiet -hier -filter "NAME =~ $pattern"]
  set storage {}
  set refs {}
  foreach c $cells {
    set ref [get_property REF_NAME $c]
    if {[regexp {^(FD|RAM|SRL)} $ref]} {
      lappend storage $c
      if {[lsearch -exact $refs $ref] < 0} {lappend refs $ref}
    }
  }
  set pins {}
  if {[llength $storage] > 0} {
    set pins [get_pins -quiet -of_objects $storage -filter {DIRECTION == IN && REF_PIN_NAME =~ D*}]
  }
  set path [file join $work ${group}.rpt]
  if {[llength $pins] > 0} {
    report_timing -delay_type max -max_paths 1 -nworst 1 -to $pins -file $path
  } else {
    set fd [open $path w]
    puts $fd "NO_MATCH: no actual FD/RAM/SRL data-input endpoint for $pattern"
    close $fd
  }
  puts $out "$group\t[llength $cells]\t[llength $storage]\t[llength $pins]\t[join $refs ,]\t$path"
  puts "TARGET_TIMING_GROUP group=$group cells=[llength $cells] storage=[llength $storage] data_pins=[llength $pins] refs=[join $refs ,]"
}
target_group first_error_key {*q/first_error_key_reg*} $work $out
target_group numerical_error {*q/numerical_error_reg*} $work $out
target_group done_status {*q/done_status_reg*} $work $out
target_group q0_write {*q/q0_reg*} $work $out
target_group q1_write {*q/q1_reg*} $work $out
target_group q0_bank_write {*q0_bank_reg*} $work $out
target_group q1_bank_write {*q1_bank_reg*} $work $out
close $out
puts TARGET_TIMING_QUERY_DONE
