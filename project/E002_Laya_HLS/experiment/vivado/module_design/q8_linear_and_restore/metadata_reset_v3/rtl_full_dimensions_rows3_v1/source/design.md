# Three-row full-dimension Scorer source mapping

State on 2026-10-09: isolated **source-only** successor to the accepted one-row Scorer run. This document records the implementation mapping for independent Astra review. No three-row fixture, numerical oracle, CPU leaf, Vivado compilation, or XSim run has been executed. The accepted `metadata_reset_v3` HLS C++, generated RTL/DAT, and seven FP wrappers are unchanged.

## Authorities and checked locations

| Source | Applied contract |
| --- | --- |
| [Q8 module source, “后继全 K/N、尾行与性能观察准备”](../../../source/design.md) | Existing Scorer shape and staged verification boundary; checked 2026-10-09. |
| [Full-dimension source-preparation release](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json) | `prepared_legal_windows/scorer_rows3`, source-only authority, complete real model and passive-observer requirements; checked 2026-10-09. |
| [Observer and numeric-boundary addendum](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_full_dimensions_observer_numeric_boundary_preparation_addendum.json) | Existing observer event interpretation and independent R0 arithmetic boundary; checked 2026-10-09. |
| [Accepted one-row Scorer source packet](../../rtl_full_dimensions_v1/source_binding_v6/source_packet.json) and [single-row results](../../rtl_full_dimensions_v1/source/results.md) | Inherited generated closure, physical 341-page map, accepted one-row behavior and cycle evidence; these are not three-row results. |
| [Read-only three-row static contract](static_contract.json) | Exact B2/S128 checkpoint slice, model spans, addresses and finite work counts; checked 2026-10-09. |

## Shape, sources and expected work

The legal RUN uses `scorer_fc1.weight` family 9/layer 255, K=N=1024, group size 32, tile size 128, batch 1 rows 13–15, and local trace row 2/column 8. The activation is bytes `[118784,131072)` of the frozen `marker_norm.f32.bin` B2/S128 checkpoint. Its oracle and DUT source slices match; the corresponding frozen `scorer_fc1_baked.f32.bin` slices also match. This establishes source identity only, not a new independent numerical result. The real weight uses both 524,288-byte Q shards, 65,536 scale bytes and the 4,096-byte baked bias at the original BO offsets.

The cold three-command sequence is LOAD_W, trace-on RUN, then same-input trace-off RUN with distinct legal task/epoch values. Each RUN quantizes 96 groups and 3,072 inputs, computes 3,145,728 valid integer MACs, issues and retires 4,096 tile groups, and writes 3,072 F32 outputs (12,288 bytes). TM4 has one tile with three valid lanes and one inactive tail lane. Trace-on carries 3,072 A8 bytes, 192 scale bytes and 1,024 group-trace bytes plus the 1,024-byte header: 5,312 valid observed bytes. Trace-off carries only the header. The source-only physical map remains 341 4-KiB pages, including 16 activation and 16 output pages so untouched neighbors can be checked.

## Implementation mapping awaiting execution review

`tb/materialize_scorer_rows3.py` is the dormant fixture builder. It checks current model manifest, original BO/GGUF Q8 group mapping, checkpoint identity, the independently calculated full-N R0 output against the frozen scorer node, and the selected row/column group trace before writing into a fresh fixture directory. It creates all three descriptors, full expected output and observed images, physical pages and useful-byte expectations. The final AUX page contains only 704 original BO bytes; the remaining 3,392 bytes are sentinel and must not be treated as original model data.

`tb/test_q8_scorer_rows3.cpp` is a separate CPU leaf for the unchanged HLS top. It maps original BOs read-only, checks fixture page correspondence and sentinels, executes the cold three-command sequence, and compares complete expected output/observed images. `tb/build_cpu_leaf.sh` and `tb/run_cpu_leaf.sh` define its later compilation and invocation.

`tb/q8_scorer_rows3_top.sv` retains the one-row generated-port binding, accepted nine AXI endpoints/adapters and dual Lite wiring. `tb/q8_scorer_rows3_control.svh` extends only the legal activation/output windows, trace useful-byte windows and full-output reset/comparison to three rows. The passive `tb/q8_scorer_rows3_observer.svh` is byte-identical to the accepted one-row observer; its hierarchy predicates and interpretation are listed in `source/observer_binding.json`. An observed issue/retire count of 4,096 still follows from one TM4 tile × 32 groups × 128 output tiles. The checker must not infer three-row numerical correctness from those event counts.

`tb/prepare_runtime.py` verifies the sealed fixture and creates byte-array XSim input files only after a separate gate. `tb/build_static.sh`, `tb/run_rows3.sh` and `tb/check_rows3.py` define the later static, runtime and full raw-memory audit stages. The generated RTL/IP and accepted endpoint are external immutable inputs. No source in this isolated root changes the DUT, arithmetic, wrapper mode, original gold or prior accepted run.

## Boundary

The source review must inspect the exact file identities, finite addresses and observer binding before any fixture materialization or tool run. A three-row pass would require independent R0/frozen-node bit equality, CPU leaf and complete RTL memory/traffic comparisons, measured command cycles and raw logs. Five-row and other windows, FP-wrapper R0 repair, OOC synthesis, routed timing, platform fit and board performance are separate gates.
