# Head15 v4 diagnostic results

Status: **source preparation only; unmeasured**. The v3 runtime stopped at `ATT_R_RECORD_TOP_RESET port=0` at 6666 ps, before any command. Its owner reset messages were zero, while wrapper and top raw values were not printed. This v4 source is a diagnostic candidate, not a correction or numerical acceptance.

| Stage | Evidence and status |
| --- | --- |
| Preimages | The v4 release gate's 24 required v3 files matched exact byte count and SHA-256 before copying. `v3_preimage_archive.json` records original/archive paths, modes, lengths, and hashes for 35 preserved files. |
| Source changes | The two generated top files were regenerated from the copied generator and remained byte-identical to v3. The active 119-bit owner module remained byte-identical. Wrapper reset checks were moved into a top-called task at the same settled negative edge; the top takes a complete seven-port raw snapshot first. The original predicates and all first-R, hold, debt, association, control, and numerical tail checks remain. |
| Isolated probe | A separate no-DUT, seven-port, four-phase source is prepared in `diagnostic/`. It has a five-negative-edge finite schedule and an eight-negative-edge failure watchdog. No probe compilation or run has occurred. |
| Source audit | Text, preimage, hash, diff, connection-map, and control-tail checks are recorded in `source_static_audit.json`; they do not establish syntax or simulator behavior. |
| Compiler/elaboration/simulation | **Not run.** Even the small no-DUT probe requires a separate independent execution gate. |
| HLS/synthesis/place-and-route/timing/board | **Not run for v4.** Existing frozen numerical RTL is only referenced. |
| Numerical comparison | **Not run for v4; no acceptance claim.** |

The probe's expected zero, known, reset-again, and injected-X phases are source predictions. They must not be presented as actual simulator observations. The v3 root and its sealed evidence are unchanged.
