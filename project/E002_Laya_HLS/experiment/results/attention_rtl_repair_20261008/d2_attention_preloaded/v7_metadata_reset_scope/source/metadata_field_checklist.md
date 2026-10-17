# V6 persistent metadata reset checklist

Source defaults were read from `include/laya_full_runtime.h`, `include/laya_numeric_tasks.h`, and `include/laya_types.h` on 2026-10-09. Every entry below is assigned by `reset_metadata` or its named bounded helper in `attention_preloaded_slice.cpp`. `FullMemory`, CPU callbacks, and all numeric payload arrays are deliberately outside the reset set.

| Object / members | Exact cold default | Fixed bound or helper |
| --- | --- | --- |
| `FullInputs::identity` | request/generation/B/S 0; four 16-byte tags 0 | `reset_identity`, 16 |
| `FullInputs::{token_ids,attention_mask}` | all 0 | batch 2 × token 1024 |
| `FullInputs::{marker_positions,marker_mask}` | all 0 | batch 2 × marker 16 |
| `FullInputs::qtype` | 0 | batch 2 |
| `FullOwners::record` entire `FullOwnerRecord`: identity, ref, lease_old_ref, max_claimed_epoch, region, stage, layer, batch, row_space, row0, rows, width, content, state, readers, covered_rows, old_consumed_rows, valid | identity zero; refs `NONE/0/0`; epoch/region/stage/batch/row0/rows/width/readers 0; layer 255; `TOKEN`; `UNDEFINED`; `INVALID=6`; masks 0; false | record 32; two masks 64 words each |
| `FullOwners::qkv_plane_head_rows` | 0 | 2 × 3 × 16 × 2 × 32 = 6144 u32 |
| `FullOwners::qkv_rope_rows` | 0 | 2 × 2 × 16 × 2 × 32 = 4096 u32 |
| `FullOwners::att_head_rows` | 0 | 16 × 2 × 32 = 1024 u32 |
| `FullOwners::{scorer_old_consumed,scorer_new_written,type_valid}` | 0/false | 2, 2, 3 |
| `FullCache::activation_source_ledger` entire `F32TileMeta` | identity zero; ref `NONE/0/0`; region/batch/row0/rows/K/readers 0; `TOKEN`; `INVALID`; `UNDEFINED`; groups 0; false | `reset_f32_meta`, 16 × 4 groups |
| `FullCache::activation_meta` entire `A8TileMeta`, including nested `source` | identity and nested F32 default; ref `NONE/0/0`; producer_task_id/stage/batch/row0/rows/K/readers 0; layer 255; `TOKEN`; `INVALID`; `UNDEFINED`; groups 0; false | `reset_a8_meta`, own 16 × 4 groups plus nested 16 × 4 |
| `FullRuntime::current_weight` entire `FullWeightDescriptor` | name 48 bytes 0; key family 0/layer 255; K/N/dtype/bias_kind 0; q base/span 2 each 0; scale/aux/bias base/span 0; two SHA arrays 32 bytes each 0 | `reset_weight`, 48, 2, 32 |
| `current_weight_ref`, `loaded_gamma_ref[2]`, `final_qkv_ref[2]`, `loaded_kv_ref`, `loaded_rope_ref`, `score_ref`, `score_kv_ref`, `score_qkv_ref[2]` | every ref `NONE/0/0` | `reset_ref`; 11 refs total |
| score head/stage/layer/batch/rows/row0/valid | 255/0/255/255/0/0/false | scalar |
| `expected_quant_source`, `expected_task_source[4]` entire `FullOwnerSpec` | ref `NONE/0/0`; region/stage/row0/rows/width 0; layer/batch 255; `TOKEN`; `UNDEFINED` | `reset_spec`, 1 + 4 |
| `expected_task_source_count`, `expected_quant_source_valid` | 0, false | scalar |
| `loaded_rope_mode`, `loaded_kv_head` | 255, 255 | scalar |
| `last_task_id`, `tasks_retired`, `op_calls[256]`, `owner_claims`, `owner_leases`, `encoder_layers_completed`, `decision_layers_completed` | all 0 | scalars; 256 count loop |
| `session_generation`, `last_accepted_request_id` | 0 | scalar |
| `diagnostic_request_id`, `diagnostic_generation`, `diagnostic_B`, `diagnostic_S`, `diagnostic_identity_valid`, `diagnostic_shape_valid` | 0/false | scalar |
| `last_execution_error`, `last_cleanup_error`, `last_commit_error` | `Check{OK,0,UINT64_MAX}` | each of three fields individually |
| `request_valid`, `model_header_valid` | false | scalar |
| `ImportPending::valid`, `ticket`, `metadata[48]`, `pair[2]`, `ticket_counter` | false; 0; 48 zeros; two full `FullOwnerSpec` defaults; 0 | `reset_spec` × 2, 48 loop, scalars |

The owner coverage total is **15,360 u32 words**: 32×2×64 record words plus 6144 QKV-plane words plus 4096 RoPE words plus 1024 Attention words. The nested activation metadata contributes another 192 coverage words. No `FullRuntime{}`, `FullCache{}`, `memset`, `numeric_reset_*`, or `full_recycle_request` call appears in this reset path; those helpers do not restore the full cold defaults.

The single reset signal is `metadata_initialized=false`, with `#pragma HLS reset variable=metadata_initialized` in the top. Initialization occurs before local memory construction/binding, observed writes, command dispatch, report, parsing, owner operations, or numeric access. It sets true only after all stores. Hardware reset during the initializer must leave this scalar false and restart it at the next accepted command; this awaits RTL proof.

CPU-only `attention_preloaded_test_only_clear_metadata_initialized()` is compiled only when `D2_PRELOADED_RESET_TEST_HOOK` is defined and `__SYNTHESIS__` is absent. It assigns only that scalar. The production pin-reset path remains a separate RTL obligation. The host must treat reset as session invalidation; reset tickets/epochs restart at 1 and cannot prevent byte-identical cross-reset ABA if the host reuses the same request identity.
