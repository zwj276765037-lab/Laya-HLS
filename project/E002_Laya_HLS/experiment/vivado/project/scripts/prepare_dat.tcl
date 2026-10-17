set run_dir [file dirname [file normalize [info script]]]
set data_files [lsort [glob -nocomplain -directory [file join $run_dir stage rtl_verilog] *.dat]]
if {[llength $data_files] != 201} {
    error "expected 201 staged DAT files; got [llength $data_files]"
}
foreach f $data_files {
    set target [file join [pwd] [file tail $f]]
    file copy -force $f $target
    if {![file exists $target] || [file size $target] != [file size $f]} {
        error "DAT copy missing or wrong size: [file tail $f]"
    }
    set src_fd [open $f r]
    set dst_fd [open $target r]
    fconfigure $src_fd -translation binary
    fconfigure $dst_fd -translation binary
    set same [string equal [read $src_fd] [read $dst_fd]]
    close $src_fd
    close $dst_fd
    if {!$same} {
        error "DAT copy content mismatch: [file tail $f]"
    }
}
puts "LAYA_DAT_STAGED count=[llength $data_files] verified=[llength $data_files] cwd=[pwd]"
