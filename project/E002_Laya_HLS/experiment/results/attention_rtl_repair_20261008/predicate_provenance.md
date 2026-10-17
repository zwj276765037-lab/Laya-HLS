# Attention task guard provenance (diagnostic, 2026-10-08)

This is a source/RTL audit of the captured synthesis. It does not assume the
generated task succeeds or that the CPU trace proves RTL behavior. The upstream
controller failure and adjacent captured IR stages are now identified in
`reviewer_root_cause_d0.json`; the exact internal pass within that interval
was not captured.

| QK shape guard (`full_tasks_attention.cpp:142-149`) | Controller construction / state writer | Source success condition at S=128 | Captured RTL observation |
|---|---|---|---|
| `t.ctx.op`, `stage`, `row_space` | `full_forward_controller.cpp:313-314` | `QK`, stage 2 or 4, `TOKEN` | Task `_33` exposes only stage and context fields; no op or row-space payload port. |
| `t.head < 16` | Controller `:298`, `:318` | Head loop 0–15. | No head payload port. |
| `t.S == rt.inputs.identity.S` | Controller `:320` | Same runtime S copied into task; physical S=128. | No task-S payload port. |
| `t.mask_mode == mode` | Controller `:319`; task `:141` | Both compute `(stage == 2 && layer % 3 != 0) ? 1 : 0`. | No mask-mode payload port. |
| `t.scale_bits == 0x3e000000` | `include/laya_tasks.h:13` default member initializer; controller leaves it unchanged. | Expected constant. | No scale-bits payload port. |
| `t.kv == rt.loaded_kv_ref`, `rt.loaded_kv_head == t.head` | Controller `:299-307`, `:316`, `:318`; LOAD_KV writes runtime fields in `full_loader.cpp:417-420` on success. | Same `load.dst` and head if LOAD_KV succeeds. | No loaded-KV state or task-KV/head input in task `_33`; loader task `_30` also has no loaded-KV state output. |
| `t.score.id == SCORE_PROB`, `bank == 0` | Controller `:317`; `fresh(Buffer::SCORE_PROB)` default bank 0 at `:35`. | Expected. | No score-reference payload port. |
| `t.qkv_ref[0/1] == rt.final_qkv_ref[0/1]` (later buffer guard) | Controller `:315`; QKV publish writes refs in `laya_full_owner.cpp:337-340` or RoPE commit `:466-467`. | Should match after successful QKV publication/rotation. | No final-QKV runtime ports in `_33`; generated top names only expose final-QKV storage under request recycle. |

| AV shape guard (`full_tasks_attention.cpp:310-324`) | Controller construction / state writer | Source success condition at S=128 | Captured RTL observation |
|---|---|---|---|
| `t.ctx.op`, `stage`, `row_space`, `S`, `head` | Controller `:338-343`. | `AV`, stage 2/4, `TOKEN`, S=128, head 0–15. | Task `_35` has only context/stage fields; no AV payload ports. |
| `t.prob.id == SCORE_PROB`, `t.partial.id == AV_PARTIAL`, `bank == 0`, `t.dst.id == ATT_OUT` | Controller `:323-329`, `:338-343`, `:293-294`. | All constructed from the specified buffers with default bank 0. | No operand/result reference payload ports. |
| `t.kv == rt.loaded_kv_ref`, `rt.loaded_kv_head == t.head` | Same LOAD_KV source as QK. | Should match if load succeeds. | No loaded-KV state/input. |
| `rt.score_valid`, score ref/KV/head/QKV/stage/layer/batch/row0/rows | QK success writes all in `full_tasks_attention.cpp:201-212`; Softmax success updates score ref in `:270`; AV task constructed at controller `:338-344`. | Should describe the just-computed score/prob tile if QK and Softmax succeed. | No score-valid/ref/runtime payload in `_35`; QK `_33` cannot set it in captured RTL. |
| `rt.final_qkv_ref[0/1]` comparisons | QKV publish/commit above. | Same published refs used by QK and AV. | No final-QKV runtime inputs. |

`include/laya_full_runtime.h:103-117,123-127,157-162` places large cache arrays,
host memory observer, and checkpoint callback behind `#ifndef __SYNTHESIS__`.
`include/laya_full_cache_storage.h:21-55` replaces the cache arrays with global
storage under synthesis. The guard-bearing scalar runtime fields at lines
`134-145` are present in both preprocess modes. This storage-layout change is
real but is not yet proven to cause the constant guard.

`full_run_task_33.v` and `_35.v` each have a context check, `finish_r`, no
numeric leaf/operand ports, and `elements(20'd0)` at line 246. On context OK
(comparison at line 745), their line 584 drives status `4'd3` (`E_SHAPE`),
with details `0x07500005` (QK) and `0x07520005` (AV) at line 570. Existing
task HLS reports give 3–5 cycles for this error path. The existing precheck
IR still contains the full task paths, per independent review. Independent D0
audit in `reviewer_root_cause_d0.json` found an earlier controller failure:
both encoder and decision `Controller::linear(LIN_QKV)` specializations return
`E_INTERNAL/detail=0x07000004` after successful `load_weight`, as if the
non-null local `qkv_pair` argument were absent. The original linked/gdce IR
retains the non-null branch and pair copy; LTO/reflow does not. This removes
QKV publication before RoPE and KV loading, which explains why the later QK/AV
guards see no valid producer state. The same audit found ADD_RESIDUAL and
ADD_TYPE vector specializations dropping their non-null second source and
second bind. See the audit for exact lines, hashes, and the distinction between
observed behavior and the unproven base-address mechanism.

RoPE has source issue calls at controller lines 281–287 but no standalone
`RopeTask`/`rope_head` RTL or report was found in the captured outputs. This
does not by itself prove which guard removed it. LayerNorm `_31` retains its
`layernorm_row_arithmetic` child and operand/result ports, so the same complete
datapath removal is not observed there. Neither observation proves functional
RTL correctness.
