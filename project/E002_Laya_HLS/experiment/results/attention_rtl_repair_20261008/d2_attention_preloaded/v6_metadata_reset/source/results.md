# Attention V6 metadata reset: source preparation and evidence status

Source-preparation release: [Astra contract](../../../reviewer_attention_v6_metadata_reset_source_preparation_release.json). The design and field mapping are in [design.md](design.md) and [metadata checklist](metadata_field_checklist.md). Original V5 numerical/ABI behavior and previous cold acceptance are recorded in [D2 results](../../source/results.md); none is a V6 result.

| Stage | V6 status | Evidence / next gate |
| --- | --- | --- |
| Isolated source, copied ABI and production dependencies | Prepared; frozen input hashes to be sealed in `source_packet.json` | Static diff and hash audit |
| Field/default/loop-bound checklist | Prepared | Independent Astra review required |
| CPU build and 3-legal/17-negative plus warm scenarios | **Not run** | New single-use reviewed guard, then actual output audit |
| Native-libm CSim | **Not run** | Only after CPU acceptance; new single-use guard |
| HLS synthesis and schedule/resource/timing estimate | **Not run** | Only after CSim acceptance; inspect reset pragma, pointer closure, generated RTL |
| RTL static build and warm reset runtime | **Not run** | Separate reviewer authorization and same-instance pin-reset source/trace |
| OOC, physical timing, board | **Not run** | No current acceptance |

The requested target carried from V5 is xcu55c-fsvh2892-2L-e at 150 MHz; neither an achieved frequency nor a V6 latency/resource number exists. Source-level finite work includes at least 15,360 owner coverage u32 stores, 4,162 input mirror stores, 192 cache coverage stores, 256 operation count stores and 48 pending metadata stores, plus identity, descriptor, ref and control scalars. This is a source operation floor, **not** clock latency or BRAM/FF utilization. HLS must report actual schedule and storage mapping; generated reset review must show numeric payload RAM is not cleared.

Future execution proposal is serial CPU build → CPU run → CSim → HLS synthesis, followed by separately reviewed RTL static/runtime. One Laya heavy tool at a time; four CPUs, nice 19, idle I/O, 0.2 s owned RSS sampling, MemAvailable strictly above 192 GiB, fail-stop, first-failure archive, source hashes before/after. Proposed per-stage upper limits are CPU 8 GiB/120 s, CSim 16 GiB/600 s, HLS 16 GiB/1800 s. These are **planning values, not authorization to execute or measured usage**. Each stage requires a fresh single-use path and reviewed gate; no unchanged retry or budget-only increase follows a failure.

[The exact proposed stage paths and payload argv](execution_plan.json) are sealed with the source packet. Each command will need an owned-process guard and separately reviewed release before execution.

The future RTL static review must bind exact generated-source hashes, inspect every reset/store cone for metadata-only behavior, and verify first-command initialization dominance. Runtime review must verify actual pin-reset sequencing, CSR zero/readback/rebind, exact old RUN `NO_PENDING`, new BEGIN/RUN, retained passive payload samples, numerical observations, and final bus debt. Cold `.dat` initialization and CPU hook are separate from actual pin reset.
