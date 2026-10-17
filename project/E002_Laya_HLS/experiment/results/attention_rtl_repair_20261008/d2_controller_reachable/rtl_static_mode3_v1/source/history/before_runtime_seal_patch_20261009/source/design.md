# D2-I vector mode3 static RTL pilot design

State on 2026-10-09: source preparation only. The DUT is the unchanged generated `vector_controller_slice` from the accepted D2-I v3 local synthesis. No fixture materialization, compiler, XSim, OOC or board work is released by this document.

## Authorities and checked locations

| Source | Scope |
| --- | --- |
| [Repair contract §7.6](../../../repair_contract.md) | Production Controller reachability and proof-layer boundaries. |
| [Mode3 source-preparation release](../../../reviewer_d2_i_vector_mode3_static_source_preparation_release.json) | One cold B1/S64 APPLY_CAND_MASK, complete 14-page physical map, exact output and staged source-only gate. |
| [D2-I synthesis/IR acceptance](../../../reviewer_d2_i_v3_synthesis_ir_review.json) | The frozen production wrapper, generated RTL and reachable producer/controller/task path. |
| [Bounded static endpoint acceptance](../../../reviewer_axi_bounded_static_v1_final_unit_review.json) | Finite AXI endpoint, adapter and protocol checker reused by exact source/hash. |
| [Original vector fixture report](../../tb/fixture_v2/fixture_report.json) | Frozen 832-byte request, 16-F32 candidate input and independent 16-F32 gold. |
| [Static schedule/port prediction](../../../d2_i_vector_mode3_static_schedule_ports_budget_precheck.json) and [mandatory IO erratum](../../../d2_i_vector_mode3_static_schedule_ports_budget_precheck_io_scope_erratum.json) | Finite source worksheet and physical AXI predictions; DUT IO unique offsets are 0–831, while TB maps/checks all 32768 IO bytes. |
| [Independent prediction review](../../../reviewer_d2_i_mode3_static_precheck_independent_review.json) | Validates the 102 binding origins, terminal response identities and first-done accounting as source predictions only. |

The later materializer will copy the exact request into a zero-filled 32768-byte IO image and patch only request ID at byte offset 24 from its frozen value to 305. It will map `src0_input` first 64 bytes to the frozen candidate, `aux` first 128 bytes to the original model header, and all other mapped source bytes to `A5`. The one mapped `state1` page is located at logical offset 16916480; raw and masked ranges within it are 16918976–16919040 and 16918592–16918656. `src1_input` and `state0` remain sentinel-only. `observed` is a 4 KiB page with all 32 final words checked and `A5` tail. Seven distinct high-32-bit physical bases and four other IO pages preserve the exact legal parser range without allocating the full logical state BO.

The source-only top will connect all seven actual 32-bit AXI bundles and both AXI-Lite banks from the generated port list. It will read back cold pointer/mode reset values, program mode 3 and all 64-bit pointers, then issue one AP start without auto-restart. The accepted bounded endpoint and passive two-sided monitors enforce INCR bursts, size/lane/strobe/ID/LAST/response, exact address windows and finite backpressure. First sampled `ap_done` and CSR done/idle must see all seven port and adapter queues drained. The numeric checker will compare all 16 masked F32 bit patterns, including signed zero, to frozen independent gold; raw 64 bytes must equal the input, all other state bytes remain `A5`, and all 32 observed words match the release. Source-only preparation does not produce these runtime results.

The first pilot excludes residual, ADD_TYPE, missing source recovery, full I-L/full graph, warm-reset metadata claims and physical timing. Later stages need separate source/bytes review and one-time execution gate.

## Prepared source mapping (no runtime claim)

`tb/generate_top.py` regenerates `tb/vector_mode3_top.sv` from the frozen 352-pin generated top. It checks the release and generated top SHA-256 before writing. Its `io` monitor allows physical reads only within the 832-byte frame; the endpoint still maps eight distinct 4 KiB IO pages. `tb/vector_mode3_control.svh` owns cold reset, both Lite readbacks, seven full 64-bit pointer writes/readbacks, mode3, one AP start, coherent `ap_start && state1` acceptance, first sampled terminal done, exact terminal raw R and masked B response holds, and all 14-page output/sentinel checks. It writes full state1/observed raw pages before first-done and later output assertions. The accepted external AXI endpoint and passive two-sided monitors remain bound by original source hashes; no testbench forces internal DUT state.

`tb/check_cpu_gold.py` independently reapplies the frozen 16-element FP32 candidate-mask rule to the immutable input and mask, checking the existing CPU gold bit for bit. `tb/check_runtime_mode3.py` independently checks those 16 result bits, raw payload, all 32 observed words, mapped page tails, port/adapter totals and first-done log against the frozen sources. Both are source only here. `tb/build_static.sh`, `tb/run_mode3.sh`, `tb/seal_snapshot.py`, `tb/verify_binding.py` and `tb/make_source_packet.py` prepare exact future stage identities. The packet's static build, snapshot, prepared and runtime paths are separate authoritative fields; every executable shell entrance uses `/usr/bin/bash` explicitly.

The static worksheet predicts 636 AR, 639 R, 132 AW, 179 W and 132 B; 3272 physical bus bytes and 1420 cumulative logical useful bytes. The TB reports actual per-side transfers for later comparison. The 131072-cycle DUT watchdog, 120 s/4 GiB runtime envelope and 64-cycle adapter work-unit allowance remain advice awaiting an exact source/snapshot and runtime gate. A PASS in one source checker alone cannot establish numerical RTL acceptance.
