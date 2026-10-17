# Actual v3 FP wrapper boundary characterization

State: source prepared for independent review; no compiler, simulator, numerical oracle, or C1 integration has run in this workspace. This isolated bench measures the seven unmodified floating-point outer wrappers used by `metadata_reset_v3`. It does not change R0 expected bits, error tolerances, HLS source, or generated IP.

## Authorities and checked locations

| Source | Applied detail |
| --- | --- |
| [FP boundary source release](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_source_preparation_release.json) | Exact seven wrapper identities, finite vector table, sampling, failure behavior, and scope. Checked 2026-10-09. |
| [C1 arithmetic design review](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_c1_detailed_arithmetic_pipeline_design_review.json) and [implementation handoff](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/q8_c1_first_isolated_implementation_handoff_draft_20261009.md) | R0 arithmetic and integration dependency. |
| [Q8 design source, §2–§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | Q8 dot, scale restoration, partial sums, and validation context. |
| [Result verification, §10](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | Native capture and candidate R0 are separate references. |
| [Accepted v3 Scorer source and static review](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_source_static_acceptance.json) | Generated source and installed XSim library lineage reused without modification. |

## Module and interface

`tb/fp_boundary_top.sv` instantiates all seven actual generated outer Verilog wrappers. The bench shares raw 32-bit operand wires across instances but checks the selected instance for each frozen case. `fdiv`, both `fmul`, `fadd`, and `sitofp` have `clk`, inactive `reset=0`, and `ce=1`; the one-stage comparator has only operand/opcode inputs; the two-stage comparator also has clock/reset/CE. Binary arithmetic has two 32-bit operands and a 32-bit result, `sitofp` accepts signed 32-bit input bits and emits binary32 bits, and the comparator wrappers emit one result bit for actual HLS opcodes 1, 2, 3, 4, 5, 6, 8. The wrapper-internal `r_tvalid` is recorded as a diagnostic, not treated as an independent accepted transaction, because the outer generated logic ties inputs valid high.

The exact outer Verilog, seven generated simulation VHDL modules, seven IP Tcl files, and seven XCI are listed with byte hashes in `source/source_packet.json` after sealing. The active bench compiles the outer Verilog and simulation VHDL against the same installed `floating_point_v7_1_21`, `unisims_ver`, `xpm`, and `secureip` identities as the accepted Scorer build. Tcl/XCI are bound provenance, not regenerated or substituted during this characterization. There is one 10 ns free-running bench clock. This is a sampling clock, not a U55C frequency result or a new performance budget.

## Fixed numerical and timing contract

`tb/frozen_case_table.json` is a literal transcription of the released R0 table: 11 divide, 10 cases for each multiply wrapper, 10 add, 8 signed-integer conversion, and 35 opcode cases for each comparator wrapper, totaling 119 wrapper/case records. Raw hexadecimal inputs and expected bits are fixed before any simulator runs. `tb/generate_cases.py` renders the table to `tb/frozen_cases.svh` and checks that it remains identical. The direct division `037e0000 / 42fe0000`, inverse `1 / 00400000`, and multiplication `037e0000 * 7f000000` remain separate prerequisite tests; later inputs never inherit an earlier actual result as revised gold.

The bench warms every instance for 32 rising edges. For each vector it drives raw operands and opcode on a falling edge, holds them for 32 rising edges, then samples the selected result after 1 ps on each of three consecutive rising edges. It records wrapper, case, inputs, opcode, expected, three actual outputs, three valid levels, and three cycle stamps to a flushed raw log before evaluating the case. Unknown or unstable result, or a result differing from the frozen bits, increments the mismatch count. It continues through every planned case and ends with a fatal/nonzero result when any case fails; a conformance PASS is printed only for complete agreement. One 65,536-clock watchdog bounds the bench. `tb/independent_check.py` separately checks raw identity, coverage, stability, bit results, consecutive sample cycles, and the final marker.

The 32-cycle hold is a finite characterization allowance; it does not establish latency or initiation interval. A failure must be classified from raw bits and case type (input or output subnormal handling, rounding, signed zero, comparator) before any C1 integration decision. A single failing case cannot by itself prove a universal FTZ mode. The table does not cover NaN payloads or every binary32 value.

## Source and execution boundary

`tb/build_static.sh` and `tb/run_boundary.sh` are dormant execution sources. `tb/make_source_packet.py` and `tb/verify_source_binding.py` bind the direct files, tool launchers, installed FP library subset, and the full accepted Scorer immutable closure; the verifier can bind an exact compiled snapshot. Future static/runtime/offline audit attempts each need separate finite execution release, fresh directories, guard evidence, and before/after binding. No generated file or adjacent Scorer, mode3, Attention, or C1 source is edited here.
