if {![info exists ::env(LAYA_PORTAL_FIFO_PROBE_WORK)] ||
    ![info exists ::env(LAYA_PORTAL_FIFO_PROBE_SOURCE)]} {
  error "LAYA_PORTAL_FIFO_PROBE_WORK and LAYA_PORTAL_FIFO_PROBE_SOURCE are required"
}
set work $::env(LAYA_PORTAL_FIFO_PROBE_WORK)
set source $::env(LAYA_PORTAL_FIFO_PROBE_SOURCE)
open_project -reset [file join $work hls]
set_top laya_compute_portal_fifo_probe
add_files $source
open_solution -reset solution1 -flow_target vivado
set_part {xcu55c-fsvh2892-2L-e}
create_clock -period 6.667 -name default
csynth_design
exit
