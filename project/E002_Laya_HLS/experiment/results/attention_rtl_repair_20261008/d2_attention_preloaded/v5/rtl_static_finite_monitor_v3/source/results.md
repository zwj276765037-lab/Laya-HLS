# Head15 explicit record monitor: evidence status

2026-10-09. Source preparation under the accepted [monitor-v3 design](design.md) and source-only release. The prior monitor-v2 runtime stopped at command 2 on `ATT_FINITE_R_ACCEPT_ASSOCIATION`; no numerical result for that command was accepted. The new record path is a diagnostic candidate, not a proven fix.

| Stage | Actual status | Evidence or condition |
| --- | --- | --- |
| Preimage preservation | 30 exact v2 maintained source/runner and packet files archived | `v2_preimage_archive.json` records each original byte count and SHA-256. |
| Source checks | One guarded source-only pass; independent review pending | `source_static_audit.json` checks the 119-bit map, two named monitor outputs per port, seven named top bindings, the single record owner and the exact 11-file diff. `frozen_rehash.json` matched 573 unique frozen files (2,287,223,087 streamed bytes). |
| Static build | Not run | A separate reviewed static release and root heavy-slot assignment are required. Proposed 16 GiB/300 s is not an accepted budget. |
| RTL runtime | Not run | A separately reviewed finite runtime release is required after accepted static evidence. Proposed 8 GiB/600 s is not an accepted budget. |
| Numerical output | Not established for command 2 or command 3 | Prior failed-run partial bytes are preserved, not promoted to a pass. |
| Synthesis, implementation, timing, board | Not run for this candidate | Frozen upstream HLS/DUT remain bound by the inherited source packet. |

The reset and first-R diagnostic lines are bounded to one per observation boundary and reset episode. They can localize a future failure to monitor generation, port forwarding or top selection only after an authorized run produces raw logs.

The single source-seal child exited 0 with no guard trigger. The outer guard sampled owned RSS 53 times; peak owned RSS was 22,764 KiB, minimum MemAvailable was 448,077,084 KiB, and no launched process remained in its recorded group/session after completion. This is source identity evidence only.
