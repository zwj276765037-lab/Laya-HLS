# Actual v3 FP boundary evidence and budget

State on 2026-10-09: source preparation only. The frozen case table contains 119 planned records across seven actual wrappers. The case include is generated and compared to that table; no Vivado/XSim or CPU numerical oracle has executed. Functional conformance, C1 integration, synthesis, implementation, timing, and board results are **unmeasured**.

| Item | Value and status |
| --- | --- |
| Source identity | `metadata_reset_v3` generated wrappers, exact release-linked hashes in `source/source_packet.json`; source-only evidence. |
| Tool/library | Planned Vivado/XSim 2025.2 launchers and accepted `floating_point_v7_1_21` library plus `unisims_ver`, `xpm`, `secureip`. Actual future command/version and library closure must be checked before execution. |
| Bench timing | 10 ns characterization clock, 32 warmup clocks, 32 hold clocks and three 1 ps delayed samples; target testbench behavior, not device Fmax. |
| Finite case limit | 119 cases × at most 36 driven/sample clock edges + 32 warmup, below the 65,536-clock fail-stop watchdog. This is a bound on bench activity, not IP latency. |
| Numeric requirement | Exact released R0 bits or one-bit comparator truth value for every case; no tolerance or gold regeneration. |
| Functional simulation | Not executed; raw log, independent checker report, source/snapshot bindings and guard records will be required. |
| OOC synthesis, place/route, board | Not executed and not claimed by this characterization. |

Proposed, **unreleased** finite execution budgets for separate review: static compile/elaboration at most 4 GiB owned RSS and 900 s; the seven-wrapper runtime at most 4 GiB and 600 s; one offline raw audit at most 4 GiB and 120 s. Each stage uses CPUs 0–3, nice 19, idle I/O, 0.2 s owned-RSS sampling, `MemAvailable` strictly above 192 GiB, and only one Laya heavy tool at a time. These small-closure estimates are not permission to invoke the tools; actual guard commands and budgets require a separate reviewed release. No prior Scorer 6000 s allowance is inherited.

The final acceptance review will distinguish each raw mismatch category and preserve all 119 raw records before reporting failure. Direct division, inverse and multiplication are evaluated independently. Existing Scorer, C1 and original R0 numerical evidence remain separate; this finite table does not prove full graph quality, C1 pipeline II, or physical timing.
