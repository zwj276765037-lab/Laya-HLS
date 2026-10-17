`recover_reports_from_dcp.tcl` is a dormant, source-only checkpoint report
candidate. It opens the SHA-bound synthesis DCP directly in non-project mode,
then generates resource, clock, timing-diagnostic and full Ws inventory reports
in one fresh sibling directory. The old failed report directory and clone stay
untouched. The installed Vivado 2025.2 manual documents
`report_timing_summary -report_unconstrained`; the failed
`report_timing -unconstrained` command is absent. A separate Astra execution
gate and finite owned-process guard are required before using this Tcl.
