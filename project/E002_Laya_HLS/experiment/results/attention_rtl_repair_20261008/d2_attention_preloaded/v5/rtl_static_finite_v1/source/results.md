# Attention V5 finite harness results and bounds

State on 2026-10-09: source preparation and light static checks only. No finite-mode materializer, CPU oracle, compiler, XSim, synthesis, implementation or board test has run. The [accepted cold V2 functional result](../../../../reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json) belongs to head0/query0 with the base source and is not a result for these two modes.

## Existing target and source facts

The unchanged V5 configuration requests xcu55c-fsvh2892-2L-e at 150 MHz under Vitis HLS 2025.2. The prior [V5 synthesis record](../../runs/local_csynth_v1/synthesis_evidence.json) contains 216 Verilog modules, 35 DAT files and six FP wrappers. Its HLS estimate is 79 BRAM18, 22 DSP, 56309 FF and 200525 LUT; the reported 5.390 ns synthesis estimate missed the 4.867 ns effective target after uncertainty. These are V5 HLS facts, not finite RTL simulation, mapped resource or achieved-frequency results.

The accepted cold V2 RUN measured the exact B1/S64 protocol: 8256 selected QKV AR/R, 33024 read bus B; 64 ATT_OUT AR/R, 256 read bus B; 256 ATT_OUT AW/W/B, 1024 write bus B and 256 useful B. This finite harness retains these counts and moves only the selected QKV/ATT_OUT physical addresses and frozen input/gold selection.

## Proposed bounded phases

The previous finite stop bounds are retained: RUN 2000000 clocks, each other command 200000 clocks and total 2700000 clocks. They are watchdogs, not a proof of latency. A source-derived numeric subtotal remains 8256 QKV reads ×27 = 222912 clocks, QK 44736, softmax 2294 and AV 45056, totaling 314998 before request, ownership, control and finite stalls. An intentionally serialized allowance of `2 × 8256 × 5 = 82560` edges covers selected AR/R adapter exposure, and 100000 clocks is allocated to other interfaces. The remainder, 1502442 clocks of the proposed RUN bound, covers finite descriptor validation, coverage/publish/report loops and generated control/arbitration. The exact loop bounds and caveats are recorded in the [cold V2 budget](../../rtl_static_cold_v2/source/results.md); no new measured throughput is inferred for head15 or changed data.

The staged guard proposal is one heavy Laya tool at a time, four CPUs, nice 19, idle I/O, owned RSS sampling at most every 0.2 s and MemAvailable strictly above 192 GiB. The source packet proposes the prior 16 GiB/300 s static compiler and 8 GiB/3600 s runtime guards for later review; materialization needs its own reviewed guard. A timeout or OOM preserves raw evidence and stops; no unchanged retry or budget-only increase is authorized by this source package.

## Current evidence

| Stage | Current finding |
| --- | --- |
| Source pin/map audit | Two generated literal tops each bind 352 pins and all 267 pages. Read-only audit resolves QKV1/head15 and QKV0/changed ranges and selected ATT_OUT output windows. |
| Static syntax | Python AST/bytecode syntax and Bash syntax checks passed for staged source. These do not establish SystemVerilog compiler acceptance. |
| Source binding | Both mode source-only binding scans passed over 556 immutable files, including original V5 hardware, testbench, frozen fixtures, installed simulation libraries and guards. No prepared page or snapshot exists. |
| Host materialization / independent serialization | Not run for either mode. |
| CPU numerical oracle | Not rerun; frozen gold fixtures reused by hash. |
| Finite static compile / RTL runtime | Not released, not run. Head15 precedes changed, with separate gates. |
| RTL resource/timing, place/route, board | Not run. |

The finite release explicitly excludes warm reset, Q8/RoPE producer integration, all heads/queries, full graph, physical 150 MHz closure and platform 50 ms latency. A fresh process per mode cannot establish persistent-cache invalidation across one DUT session.
