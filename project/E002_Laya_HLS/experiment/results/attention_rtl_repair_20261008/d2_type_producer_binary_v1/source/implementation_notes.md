# Actual type producer to binary vector: source mapping

The signed [design](design.md) and [source release](../../reviewer_d2_type_producer_binary_source_preparation_release.json) remain byte-for-byte unchanged. This note records implementation mapping without changing the design SHA-256 bound by the release. Status is **source preparation only** as of 2026-10-09; no new input, oracle, CPU, CSim, HLS, RTL or OOC execution has occurred.

## Verified specification and code sources

| Source | Location used here |
| --- | --- |
| [Model/workspace map](../../../../vivado/design_source/04_model_package_and_memory_map.md) | §4 QKV and §7 HIDDEN/TYPE_ROWS, including 04§7.1 Q8 model binding |
| [Joint interfaces](../../../../vivado/design_source/15_integration_interfaces_and_pipeline.md) | §10 tasks, §11 owner states, §12 task shape and §15 full-controller barriers |
| [Controller](../../../../hls/control/full_forward_controller.cpp) | `type_add` at 424–451 and `vector_impl` at 164–200, unmodified |
| [Embedding task](../../../../hls/operators/full_tasks_front.cpp) | `embedding_table` at 14–29 and `EMB_TYPE` at 64–127, unmodified |
| [Vector task](../../../../hls/operators/full_tasks_vector.cpp) | `ADD_TYPE` shape and dual acquisition/read/add at 38–46, 161–182, 243–258, unmodified |
| [Owner rules](../../../../hls/common/laya_full_owner.cpp) | claim, partial type publish, required row coverage, and release at 197–207, 514–605, 608–622, unmodified |
| [Model package](../../../../build/model-attention-rtl-repair-20261008/manifest.json) | `type_emb.weight`: Q8_0 [1024,3], EMBEDDING base 54800384, span 3264 |

## Source and port mapping

The new [top](type_producer_binary_slice.cpp) includes the production `full_forward_controller.cpp` translation unit exactly once. Its only invoked controller method after the ingress is `Controller::type_add(hidden)`. The top binds seven pointers: `hidden_input` (262144 B), `embedding` (54803648 B), `io` (32768 B), `aux` (1671872 B), `state0` (16920576 B), `state1` (16919104 B), and `observed` (32 `uint32_t`, 128 B). The proposed nonzero, disjoint 64-bit bases and 206 sparse 4096-byte pages are in [static_mapping.json](../tb/static_mapping.json). The absent W/QKV/FF/attention pointers have no call from this top's reachable path: request parse reads IO/AUX; ingress reads `hidden_input` and writes HIDDEN state0; EMB_TYPE reads the named `embedding` BO and writes TYPE_ROWS state0; ADD_TYPE reads state0 twice and writes state1; report writes observed. No pointer is a placeholder for a model access.

The top parses the unchanged request and limits shape to B1/S64. It creates the stage3 TOKEN HIDDEN bank0 owner with `Controller::fresh`; for each row0…63 it gets the physical address through `full_f32_address` and writes the full 4096-byte frozen row through `full_write`. It then covers exactly 64 rows and publishes with the original owner API. This is the external native-model checkpoint ingress, not a claim that preceding Encoder layers ran. The top never writes TYPE_ROWS directly and never changes owner arrays, epochs, coverage or valid bits itself. On a failed ingress or `type_add` it invokes the original `invalidate_incomplete` cleanup and reports first status.

The original `type_add` claims TYPE_ROWS, issues one `EmbeddingTask` for qtype2, and invokes original `vector_impl` for four 16-row `ADD_TYPE` tasks. The task code checks the full 3264-byte descriptor span, reads the selected Q8 row at offset54802560, decodes it, writes selected TYPE_ROWS F32 bytes at STATE0+16916480, and publishes only that covered row. It binds/acquires HIDDEN and TYPE_ROWS for each binary task, reads both 1024-value operands, writes HIDDEN bank1, publishes all 64 output rows, and releases TYPE_ROWS and old HIDDEN. The qtype1 cold case selects offsets54801472 and STATE0+16912384. Unselected type rows must remain sentinel bytes; they are not required to become valid.

The passive 32-word report maps status/detail/phase to words0–2; task retirement/claims to3–5; output ref to6–8; cleanup to9; post-release type-valid bits to10; EMB_TYPE and ADD_TYPE calls to11–12; qtype/request identity to13–15; output snapshot/status/coverage to16–20; released type snapshot to21–24; and released ingress snapshot/ref to25–31. The [CPU test source](../tb/test_type_producer_binary_slice.cpp) expects five successful tasks, three claims, all64 output row bits, READY output, FREE type/ingress owners, and compares every byte of both STATE BOs. Its exact 65536 output words come from independent reference data. It runs each qtype as a separate cold process once a later gate releases execution.

## Independent inputs and future checks

The qtype2 request/HIDDEN/gold remain the frozen [fixture](../../d2_controller_reachable/tb/fixture_v2/fixture_report.json); decoded `type_rows.f32.bin` is read only as a test expectation. The [qtype1 materializer source](../tb/materialize_qtype1.py), which has **not run**, checks the signed gate, original native capture, package manifest, complete EMBEDDING BO, and byte equality to the GGUF `type_emb.weight` tensor. It patches only request identity and qtype, then calls independent `tests/full_reference.py` `embedding_row`/`add` to produce future qtype1 row and 65536-word gold. Neither row file is passed to the DUT. The candidate [HLS configuration](config_type_producer_binary.cfg) and [finite runner proposal](../tb/runner_proposal.md) are sources only; static source review, physical schedule and bounded runtime gate must precede any execution.

The expected RTL checker must keep qtype2 and qtype1 in separate cold runs, verify all 206 mapped pages, the selected Q8 read window, all TYPE_ROWS selected and unselected bytes, both HIDDEN banks, output/ref/counters, both AXI sides and all adapter debt at first sampled done, and real terminal R/B stalls. Boundary checks include rows0/15/16/63 and columns0/63/64/1023. A new cycle ceiling must cover ingress, EMB_TYPE and all four full-width ADD_TYPE tasks and must be justified by actual schedule. No Mode3 cycle ceiling or generated snapshot is reused.
