set run_dir [file normalize [file join [file dirname [info script]] ../..]]
set inputs [lsort [glob -nocomplain -directory [file join $run_dir stage rtl] *.dat]]
if {[llength $inputs] != 108} { error "expected 108 DAT inputs, got [llength $inputs]" }
set cwd [file normalize [pwd]]
foreach source $inputs {
    set target [file join $cwd [file tail $source]]
    file copy -force $source $target
    if {![file isfile $target] || [file size $target] != [file size $source]} {
        error "DAT copy size mismatch: $source"
    }
    set a [open $source rb]
    set b [open $target rb]
    set identical [string equal [read $a] [read $b]]
    close $a
    close $b
    if {!$identical} { error "DAT copy content mismatch: $source" }
}
puts "Q8_OOC_DAT_STAGED count=108 verified=108 cwd=$cwd"
