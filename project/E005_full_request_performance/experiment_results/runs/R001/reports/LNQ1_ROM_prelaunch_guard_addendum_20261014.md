# LN ROM prelaunch guard prepared after AT048

2026-10-14; M004/SM005/E005/R001; A002. This is a live runner preparation fix for any **future** frozen attempt. It does not modify AT048 or authorize another LNQ1 full.

The live `run_lnq0_chain_v1.tcl` now sources `stage_ln_roms_v1.tcl` immediately after elaboration and before `LNQ0_STATIC_PASS` or simulation. The helper requires the xsim directory, validates the seven exact generated LN ROM names and their SHA-256 against the frozen AT040 baseline, copies them into the xsim working directory, and rechecks the staged hashes. A missing helper, source, destination or mismatched hash makes the static entry fail before a full launch. A future attempt must freeze **both** Tcl files and record their identities; the generated LN RTL and ROM contents remain unchanged.

Live runner SHA-256: `2c7f28d45a8af296b8026073cd989a2b2ac80f666b10551121c51a6819e489b6`; helper SHA-256: `31d7e56d5e2b63cf1510d84129db542f35779704dfc051cf9f36f11286e17a85`. A host-only `tclsh` check staged all seven AT040 frozen ROMs into a temporary directory and verified every target digest against its source. Corrupting one temporary source was rejected before any target copy. This checks the helper's good and bad branches; a new Vivado compile/simulation has **not** been run and remains subject to a new stage contract and the original tool caps.

AT048 still has static PASS/full COST_STOP due to its absent runtime ROMs. Its frozen inputs, work directory, original logs and receipt were not changed. No END/PUBLISH or Q/Wi/G/Down result can be inferred from this preparation fix.
