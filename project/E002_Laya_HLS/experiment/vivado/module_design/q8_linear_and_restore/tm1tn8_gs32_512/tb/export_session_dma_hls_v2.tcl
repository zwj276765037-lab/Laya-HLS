if {![info exists ::env(LAYA_Q8S2_HLS_PROJECT)]} {
    error "LAYA_Q8S2_HLS_PROJECT required"
}
set project [file normalize $::env(LAYA_Q8S2_HLS_PROJECT)]
if {![file isfile [file join $project solution1 syn verilog q8_tm1tn8_session_dma_v2.v]]} {
    error "synthesized Q8S2 RTL required"
}
open_project $project
open_solution solution1
export_design -format ip_catalog
exit
