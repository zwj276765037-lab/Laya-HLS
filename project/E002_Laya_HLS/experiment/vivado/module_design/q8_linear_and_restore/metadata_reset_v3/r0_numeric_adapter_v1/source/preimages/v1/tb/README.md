This source-only suite uses the unchanged seven actual FP outer wrappers. The
independent `original_r0_reference.py` models original R0 with exact rationals;
`vector_manifest.json` supplies literal input words and three dot/half restore
extremes. `run_vectors.sh` would materialize a fresh `case_table.json` and
`generated_cases.svh` after a separate CPU execution release.

`build_static.sh` would compile the seven bound simulation VHDL files, seven
outer Verilog wrappers, `rtl/r0_fp_bits_pkg.sv`, and
`r0_adapter_probe_top.sv` into a fresh `r0_adapter_probe` XSim snapshot.
`run_adapter.sh` would run that snapshot in a separate fresh runtime directory,
check source/snapshot identity before and after, and preserve and audit every
raw comparison with `audit_raw.py`. Its 500,000-cycle bench watchdog and the
scripts' local timeouts are secondary to a separately reviewed owned-process
guard and aggregate stage budgets. No CPU reference, RTL compiler, simulator,
OOC synthesis, or C1 integration has run for this suite.
