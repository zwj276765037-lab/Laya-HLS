# sampled_wait_v4 source identity

This isolated source tree copies the corrected `wait_trace_v3` closure. Only
five hierarchical AW/W/B/AR/R count waits in `tb/axi_allocation_diag_top.sv`
are replaced by exact-true polling after each positive clock edge plus 1 ps.
`tb/build_static.sh` selects the new `axi_sampled_wait` snapshot. The VIP,
stable monitor, latency, response assertions, 1024-pair traffic and all seven
memory comparisons remain the copied v3 bytes.

The current design and results are the parent module's `source/design.md` and
`source/results.md`. This variant's exact diff and source packet are here.
Source preparation alone is released; static elaboration and runtime require
their separate review gates.
