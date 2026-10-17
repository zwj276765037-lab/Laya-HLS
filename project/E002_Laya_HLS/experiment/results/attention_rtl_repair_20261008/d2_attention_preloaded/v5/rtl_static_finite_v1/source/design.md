# Attention V5 finite head/source RTL harness

State: source preparation only. The generated V5 hardware, 216 Verilog modules, 35 DAT files, six FP wrappers, physical AXI endpoint and arithmetic are unchanged. No finite page materialization, CPU oracle, RTL compilation, simulation, synthesis or board run has occurred. This harness implements the [Astra finite source release](../../../../reviewer_attention_v5_head15_changed_finite_source_preparation_release.json); each execution stage needs a later bounded review.

## Authority and source locations

| Checked 2026-10-09 | Contract used here |
| --- | --- |
| [Memory map §4](../../../../../../vivado/design_source/04_model_package_and_memory_map.md) | 12 MiB QKV shard layout: plane, batch, local head, row, feature. |
| [Attention/FP §2](../../../../../../vivado/design_source/11_attention_and_fp_engine.md) | QK score, complete-row softmax, key-ascending AV multiply then add with F32 rounding and no FMA. |
| [Integration §§11, 12, 14](../../../../../../vivado/design_source/15_integration_interfaces_and_pipeline.md) | FILL→READY QKV pair, ticket/epoch/coverage and TaskDone retirement. |
| [D2 repair contract §§7.3–7.5, 7.11](../../../../repair_contract.md) | Real external QKV memory, B1/S64 Decision scope, independent numeric judgments. |
| [V5 design](../../../source/design.md), [ABI](../../source/attention_preloaded_abi.h), [V5 testbench](../../tb/test_attention_preloaded.cpp) | Frozen 160-word BEGIN/RUN descriptors, request, status and owner semantics. |
| [Accepted cold V2 numerical/protocol review](../../../../reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json) | Four-command cold sequence and 256 physical byte-write transactions. |
| [Finite source release](../../../../reviewer_attention_v5_head15_changed_finite_source_preparation_release.json) | Exact two modes, selected offsets, gold fixtures, source-only gate and dependency order. |

## Modes and physical boundaries

Every mode creates a fresh cold XSim process, instantiates all seven 32-bit AXI ports and both AXI-Lite banks, and uses the same 267 mapped 4 KiB physical pages. The physical pointer bases are descriptor `0x2000000000`, IO `0x2100000000`, AUX `0x2200000000`, QKV0 `0x2300000000`, QKV1 `0x2400000000`, ATT_OUT `0x2500000000` and observed `0x2600000000`. The respective page counts are 1, 8, 1, 96, 96, 64 and 1.

| Mode | Source and selected port | Q / K / V byte offsets on selected port | ATT_OUT read/write offset | Final aligned AW offset |
| --- | --- | --- | ---: | ---: |
| `base_h15_r63` | Frozen base tensor, head 15/query 63, QKV1 | [1851136, 1851392) / [6029312, 6045696) / [10223616, 10240000) | [261888, 262144) | 262140 |
| `changed_h0_r0` | Frozen changed tensor, head 0/query 0, QKV0 | [0, 256) / [4194304, 4210688) / [8388608, 8404992) | [0, 256) | 252 |

The opposite QKV port must have zero transactions on both monitored sides. Descriptor read allowance is 640 B, IO 32 KiB, AUX 128 B and observed write allowance 1024 B. The selected ATT_OUT 256 B window is the only readable/writable region; the testbench scans the full 256 KiB mapped output after each command. Head15 reaches the last mapped byte. The bounded endpoint rejects any unmapped page access, crossing burst or illegal metadata. Both QKV shards are materialized and scanned even though one is inactive in a numeric call.

The [producer](../tb/materialize_cold_pages.py) selects the exact frozen raw tensor, verifies both reconstructed 12 MiB host shards and 10,240,064 B prefixes, and emits only ten page files. It changes only descriptor words 44/45 for head/query. The [independent checker](../tb/check_prepared_pages.py) reconstructs each mapped QKV byte directly from the source tensor, checks all ten serialized files and does not import the producer. Neither script initializes DUT internal memory. The unchanged base request is derived to request 301/generation 1, with frozen AUX and BEGIN/RUN receipts. The first two invocations see A5 QKV pages; the host fills external pages before RUN only when all buses are drained.

## Sequence and assertions

The [generated top builder](../tb/generate_top.py) derives literal wiring for all 352 V5 pins and emits one top per mode. [Control](../tb/att_finite_control.svh) runs BEGIN, pending BEGIN rejection, RUN and replay RUN rejection on one DUT without reset between commands. It checks 30 exact status words, all seven DUT/endpoint channel counters and byte totals, accepted/delivered adapter debt, first sampled `ap_done` debt, CSR done/idle debt, source pages and full output pages. Every command dumps the full observed 4096 B page and ATT_OUT 262144 B area before result checks. Every 100000 clocks it prints phase hints, seven-port counters and a read-only RSS sample. The prior stop bounds remain RUN 2 million, other commands 200000 each and total 2.7 million clocks; these are proposed failure bounds, not measured latency.

RUN must read 8256 selected QKV words (33024 bus B), read 64 ATT_OUT words (256 bus B), and perform 256 one-beat ATT_OUT AW/W/B transfers (1024 bus B, 256 useful B). All AWLEN are 0, AWSIZE 2, AW addresses follow selected base plus `4*floor(i/4)`, WSTRB follows `1<<(i%4)`, and the final B corresponds to the 256th transfer at selected offset +252. The selected QKV terminal R and final ATT_OUT B each receive at least 16 extra hold cycles. Raw selected index/address/beat, first and last AW/W/B samples, and each four-state hold predicate are logged. The inactive QKV port is checked for zero AR/R/RLAST/AW/W/B traffic and zero bus bytes on both monitored sides.

The [offline checker](../tb/check_runtime_numeric.py) consumes a hash-sealed XSim log and eight full dumps. For each frozen mode it requires 64 exact QK score words, 64 finite probabilities within the original F32 `1e-4 + 1e-4*abs(gold)` tolerance, 64 exact key-ascending sequential F32 AV words computed from actual observed probabilities and that mode's selected V head, and an independent tolerance comparison against frozen end-to-end AV. The selected physical output must equal observed AV; every other output byte stays A5 and replay output is identical. Changed mode binds a distinct source and distinct frozen score/probability/AV fixtures. No gold file is regenerated.

## Staged entrypoints and limits

[Build](../tb/build_static.sh) and [runtime](../tb/run_mode.sh) require an explicit mode and fresh separate directories. [Packet generator](../tb/make_source_packet.py) binds source, fixture, IP, library, guard and exact command arguments; [binding check](../tb/verify_binding.py) compares immutable files and prepared/snapshot baselines, excluding only four named XSim runtime artifacts. [Attempt archive](../tb/archive_attempt.py) copies present raw logs and dumps after success or first failure and records missing entries. The finite packet will list stages as **not released**. A later review must accept head15 derived pages and source before its static/runtime stage; changed mode requires head15 actual results and its own gate. Fresh process evidence does not establish warm-reset cache invalidation. No producer Q8/RoPE integration, all-head sweep, complete graph, physical Fmax, OOC target or board conclusion is claimed.
