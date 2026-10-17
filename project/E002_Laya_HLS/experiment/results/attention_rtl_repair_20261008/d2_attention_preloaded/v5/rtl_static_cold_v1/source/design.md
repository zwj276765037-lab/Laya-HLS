# Attention v5 cold-start static RTL source design

State: source prepared under the [Astra xhigh release](../../../../reviewer_attention_v5_cold_static_source_preparation_release.json) of 2026-10-08. Attention RTL compilation and runtime require a later release. This module is a verification harness around the unchanged V5 generated top; it does not alter production, HLS, generated RTL, IP, arithmetic, oracle or tolerance.

## Source and contract locations

| Authority, checked 2026-10-09 | Relevant section and applied rule |
| --- | --- |
| [Memory layout specification §4](../../../../../../vivado/design_source/04_model_package_and_memory_map.md) | QKV plane, batch, head-shard, row and feature layout; 12 MiB logical shard. |
| [Attention/FP specification §2](../../../../../../vivado/design_source/11_attention_and_fp_engine.md) | QK fixed score, complete-row softmax, AV key-ascending F32 multiply then add without FMA. |
| [Integration specification §§11, 12, 14](../../../../../../vivado/design_source/15_integration_interfaces_and_pipeline.md) | QKV pair FILL→READY publication, epoch/coverage and TaskDone retirement. |
| [D2 repair contract §§7.3–7.5, 7.11](../../../../repair_contract.md) | Real external QKV producer boundary, selected B1/S64 Decision head0/query0 and split numeric judgments. |
| [V5 accepted design](../../../source/design.md), [frozen ABI](../../source/attention_preloaded_abi.h), [V5 testbench](../../tb/test_attention_preloaded.cpp) | BEGIN/RUN receipt, phase/status/owner fields and first frozen 160-word descriptors. |
| [Cold source preparation release](../../../../reviewer_attention_v5_cold_static_source_preparation_release.json) | Seven physical AXI ports, 267 mapped pages, double Lite, cold-only sequence, no internal preload or reset between calls. |

The present file documents the exact mapping of that released design to the new harness. The source preparation gate is the controlling scope where an older generic D2-R budget or generated cosim setup differs.

## Binding and memory

`tb/generate_top.py` derives `tb/att_cold_top.sv` from the exact generated `attention_preloaded_slice.v` pin declarations. All 352 declared pins, including clock/reset, seven AXI4 bundles and both AXI-Lite banks, are connected. The [unchanged bounded endpoint](../../../../d2_axi_allocation_diagnostic/bounded_static_v1/rtl/axi_static_memory.sv) is instantiated seven times through `tb/att_axi_port.sv`; only the harness adapters/monitors were copied and renamed from the accepted Q8 static approach. All ports use AXI 64-bit addresses, 1-bit IDs, 32-bit data and four byte strobes. AXI-Lite control has a 5-bit address; control_r has a 7-bit address.

| Port | Physical base | 4 KiB pages | Allowed direction and range |
| --- | ---: | ---: | --- |
| descriptor | 0x2000000000 | 1 | read first 640 B |
| io | 0x2100000000 | 8 | read complete 32 KiB request area |
| aux | 0x2200000000 | 1 | read first 128 B package header |
| qkv0 | 0x2300000000 | 96 | read only Q `[base,base+256)`, K `[base+0x400000,base+0x404000)`, V `[base+0x800000,base+0x804000)` for head0/query0 |
| qkv1 | 0x2400000000 | 96 | no transactions in this head0/query0 call; pages still materialized and scanned |
| att_out | 0x2500000000 | 64 | write and read the selected first 256 B; scan the full B1/S64 256 KiB mapped output region |
| observed | 0x2600000000 | 1 | write first 1024 B; rest sentinel |

The 267 physical page bases come from the gate, including the sparse QKV offsets. The endpoint rejects an unmapped address and a burst crossing a page. Both DUT and endpoint sides are monitored for legal metadata, address ranges, beat/response debt and equal accepted counts. Each of five AXI channels has a one-entry valid-hold adapter with deterministic 0–3 cycle exposure delay; AW/W can advance separately. One terminal R beat of an actual QKV0 burst and the 64th/final ATT_OUT B response get an additional 16-cycle hold in RUN. `tb/att_cold_control.svh` latches the selected beat/address and wait duration; final B must correspond to `base+252`. The generated ATT_OUT AXI instance sets `CH0_NUM_WRITE_OUTSTANDING=1` and `NUM_WRITE_OUTSTANDING=1` ([generated top](../../runs/local_csynth_v1/work/hls/syn/verilog/attention_preloaded_slice.v), ATT_OUT instance parameters around line 12001). No force/deposit, internal cache preload or FSM steering occurs.

`tb/materialize_cold_pages.py` independently reconstructs both complete 12 MiB host shards from the frozen 786432-byte QKV tensor, applies the forward layout, checks every host byte using the inverse layout and validates full-host plus 10240064-byte-prefix SHA256 against the frozen manifest. Only the listed pages are emitted for XSim. The simulated host backs 96 pages per shard, not every byte of the 12 MiB logical shard; no unmapped-region scan is claimed. BEGIN sees A5 on both QKV port pages. After accepted BEGIN and rejected pending BEGIN, and only while all channels are drained, the host testbench replaces the external QKV page contents and submits the independently frozen RUN receipt. The DUT instance and its static state persist across all four invocations.

The frozen original request supplies the first 832 bytes of a zero-filled 32 KiB IO region, with request 301 and generation 1 bound at byte offsets 24 and 32. AUX takes the first 128 bytes of the frozen package header. Descriptor BEGIN/RUN use the two frozen 640-byte files with A5 tails. Observed starts with 256 `deadbeef` words plus A5 page tail, and ATT_OUT is A5 across all 64 pages. Input pages are scanned byte-for-byte after each command. ATT_OUT is scanned across all 256 KiB; the only allowed changed bytes are the first 256. Observed numerical and reserved tails are checked in every invocation.

## Control and numeric checks

The single cold-start instance first reads reset command in control bank 0 at `0x10` and all 14 pointer-register halves in control_r bank 1, then programs and reads back all seven nonzero high-address pointers. Before each invocation it writes BEGIN=0 or RUN=1 to bank 0 `0x10` and reads it back; AP start uses bank 0 `0x00`. The sequence is BEGIN, second BEGIN while pending, RUN with real external QKV pages/receipt, replay RUN. At first actual `ap_done` and again at CSR done/idle, all AXI request/response debt and timing-adapter accepted/delivered counts must be zero; no wait is inserted to hide early completion. Each command compares all 30 status words in observed `[0..15]` and `[224..237]` with exact independent constants, including zeros after the replay `report(...,has_pair=false)`, RUN six owner claims and cleanup status/detail. Every fixed 100,000 clocks the testbench prints command, state, an explicitly inferred phase hint, DUT/endpoint AR/R/AW/B counts for all seven ports and a read-only in-process RSS sample. Fatal errors stop the single attempt and remain in the guarded raw log.

The generated V5 top calls production `full_read` after AV to copy the 256 selected ATT_OUT bytes into observed AV. RUN therefore requires real ATT_OUT reads. The monitor admits reads and writes only in the first 256 B and checks exactly 64 AR/R, 64 AW/W/B, 256 read and write bus bytes and 256 useful written bytes. QKV0 requires exactly 8256 AR/R and 33,024 bus bytes; QKV1 requires zero transactions. The testbench dumps actual observed pages for all four calls and complete ATT_OUT pages after RUN/replay. `tb/seal_runtime.py` hashes the XSim log and six dumps. `tb/check_runtime_numeric.py` consumes those sealed bytes plus the frozen score/probability/AV files and frozen QKV source. It requires 64 exact score words; 64 finite probabilities under the original `1e-4 + 1e-4*abs(gold)` F32 tolerance; and 64 exact AV words from **actual observed probabilities** and frozen V, rounding separately to F32 after every multiply and add in ascending key order. It separately applies the same tolerance against frozen end-to-end AV. Actual ATT_OUT first 256 bytes must equal observed AV; every other output byte remains A5, and replay output is identical. This checker does not generate a new gold fixture or run CSim.

## Entrypoints and limits

`tb/build_static.sh` and `tb/run_mode.sh` are authored but unexecuted Attention EDA entrypoints. `tb/verify_binding.py` checks immutable source, prepared inputs and the compiled snapshot, excluding only four named XSim runtime artifacts while archiving their exact post-run bytes. The source packet provides ordered command arguments and fresh output paths for later release. `tb/audit_source.py` is a read-only pin/page audit. Hardware warm reset, head15/query63, changed QKV, missing coverage and negative follow-through remain separate later RTL gates. No 150 MHz closure, physical resource result or board result is inferred here.
