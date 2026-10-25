# E009 / SM009 / R001: Host and strict CPU handoff

Owner: A008. Current authority: M007 revision 1 and SM009, 2026-10-21.

Only implementation paths `E002/experiment/host/m007_deploy`,
`tests/m007_deploy`, and `tools/m007_deploy_identity.py` are owned here. Existing
Host, independent oracle, shared model, RTL and historical evidence are read-only.
The original E002 implementation remains the single implementation tree.

## Protocol

1. Inspect the two known reference manifests, strict reference source and the
   shared 455179648-byte GGUF. One bounded metadata read (<=4 MiB) binds graph,
   tokenizer and available recipe values. Hash the complete model once for the
   asset report; the CPU test model handle independently verifies its input once.
2. `host/m007_deploy/schema.json` is the sole field layout. Python codec reads it;
   generated C++ constants/SV package contain its SHA. The fixed 512-byte control
   frame is separate from H0=524288 bytes and compact tail=69632 bytes. XRT register
   mapping is explicitly NOT_BOUND. Buffer addresses are u64, overflow and overlap
   checked; real BO allocation bounds are supplied by the eventual XRT owner.
3. Run independent byte-frame construction tests, invalid inputs and stale/error
   completion checks. Exercise marker127, reject128, preserve duplicates/holes,
   canonicalize invalid slots explicitly, check masks/qtypes/candidate counts.
   Confirm raw CLS ownership independently of marker LN.
4. Run only the tail and initial Embedding/LN on bounded frozen inputs. Read an
   existing independently generated hidden/expected final18/checkpoints with the
   recorded hashes. Never run a new whole-model oracle or generate expected values
   from the adapter. Reuse hash-pinned strict math from tests/full_reference.py.
5. Compare every returned F32 bit against frozen checkpoints/final18. These are
   CPU contract/transport tests, not board, RTL, full-graph or timing acceptance.

## Resources and anomaly policy

Reference/unit <=600s, compile <=600s; each child <=120s, RSS <=16 GiB.
CPU0-3, nice19, idle I/O, MemAvailable >192 GiB. All real computation/compilation
holds `.research-agent/m007_heavy.lock` for guard plus child lifetime. Guard writes
fresh AT receipts and stdout/stderr, tracks cumulative time, kills only its owned
process group on limits, and retains failed attempts. No EDA, GPU, board, installs,
full-model gold or silent CPU Attention fallback.

Stage evidence and source identities are frozen per AT. A corrected source or
input uses a fresh AT; previous logs remain. Exit0 alone is not PASS: inspect full
logs and require each runner's self-check terminal marker. Device completion is
NOT_RUN until an actual device transport is bound.

## Reproduction

Run from `project/E002_Laya_HLS/experiment`. The guard's --attempt must name a
fresh directory, and every command below must use it. Set PYTHONPATH=host for
module entry points. Exact commands/tool/environment identities are in receipts.

```
python3 tests/m007_deploy/run_guarded.py --attempt ATxxx --phase reference_unit --seconds 120 -- python3 -m unittest discover -s tests/m007_deploy -p test_contract.py -v
python3 tests/m007_deploy/run_guarded.py --attempt ATxxx --phase reference_unit --seconds 120 -- python3 tools/m007_deploy_identity.py --hash-model --output <AT-directory>/assets.json
python3 tests/m007_deploy/run_guarded.py --attempt ATxxx --phase compile --seconds 120 -- env PYTHONPATH=host python3 -m m007_deploy.generate
```

Hardware/Host owners must agree a later production XRT mapping and build identity;
the schema package is not an already implemented device or final BEGIN ABI.

## FRONTEND-02 continuation (AT018 onward)

Authority: D-M007-SM009-FRONTEND-02, same R001 budget, no legacy budget transfer.
Original cap and first-slice costs remain in the retained release_evidence_v2.

Real JSON uses original serialize_state/question/render_options/BPE and special
token sanitation order. A new local assembler retains the entire sequence:
<=128 tokens is accepted and then padded; >128 returns LENGTH_ERROR. It does not
apply the original option48/head/state/total resize or discard markers. A long
option above48 tokens is accepted when the complete sequence still fits S128;
this intentional strict-policy difference is not compared to old truncated gold.

Native production helper directly compiles unchanged original tokenizer,
questions, recipe, sequence and language sources. It receives verified bounded
real GGUF metadata and has no ModelExecutor or forward function. Original
engine.cpp decode_answer arithmetic body is hash-bound and extracted verbatim;
only the local function signature binds recipe_/has_act_ as explicit arguments.
The independent test oracle loads GGUF with the original GGUF library, invokes
original BPE/build_sequence and preserves the original member body in a test-only
class. It imports no new production assembler, finite guards or decode wrapper.

Comparison: native nontruncating Choice/Noul/Score, Chinese/special tokens,
candidate order, exactly128/129, option>48 with legal whole length, excess options
and long state. Construct uncut expected sequences independently from original
oracle BPE for deliberate policy differences and exact bounds. Business decode
compares all raw F32 bits/labels and original rounded JSON against the independent
source-native member oracle on legal inputs. Tie/one-ULP/temperature bucket/ACT
cases remain native semantics. Nonfinite or overflowing intermediates are rejected
before calling original softmax_temp, so old uniform fallback is unreachable.

CLI must provide JSON -> tokens/masks/markers/request/H0 and 18-logits -> business
answer. These are CPU functional paths only; actual device, whole graph, native
request quality and CPU speed are not inferred from these synthetic/partial tests.

## NATIVE-CPU-03 / R002 independent protocol

Authority is the appended SM009 R002 contract. Guard requires explicit --run R002:
reference_unit600s, compile900s, cpu_profile180s, each<=120s; CPU0–3/nice19/idle,
MemAvailable>192GiB/RSS<=16GiB/shared heavy lock. R001 balances and receipts do
not transfer. Each AT records a recoverable owned source archive; final native
build additionally archives its complete native source/header/generated closure.

Production NativeSession loads/verifies model, inventory, recipe, metadata, source,
binary and actual glibc2.39 libm identity once. Prepare/finish arithmetic is native;
frozen Python reference is test-only. Scalar tanhf/expf/logf/sqrtf calls bind actual
/usr/lib/x86_64-linux-gnu/libm.so.6 SHA fce00b6f25f459cf4ae0b7fae4257909a1a8a86f9149e7c029a5d617baf1ccd0.
No fast-math, FMA, FTZ/DAZ or reassociated reductions. SIMD combines independent
outputs or independent adjacent pairs at one fixed tree level. Non-saturating
VNNI maps signed A to U8(A+128) and subtracts128*sum(W) in exact I32, tested
including-128. Caller locally pins CPU0; persistent workers pin1/2/3. FE/MXCSR/
affinity are restored on success and error; actual worker masks are recorded.

Default full cache holds only model-token -> initial-gamma-LN row,50368x1024 F32
=206307328B. Initialization fills every token, never selected fixtures. Lazy mode
is a separate same-source diagnostic proving true new-token miss/hit equality and
reload invalidation. No request H0, hidden, tail, logits or answer cache exists.
Full cache identity binds model/source/numeric/cache mode and per-Session epoch;
model reload creates fresh weights/cache and rejects old prepared objects.

Function gate uses both pre-existing frozen requests and all H0/tail checkpoints,
rawCLS/final18; independent original frontend/decode; true miss/new token; random
local tail reference; wrong identity/length/numeric/overflow and no-output-pollution
guards. Full/lazy modes each match frozen values; no new whole-graph gold.

After identical production-build function PASS, profile a short pilot and32–200
real calls. input_end_to_end_ns is the same measured interval as prepare_ns,
covering prepare(data) including JSON, original BPE/recipe, Request validation,
binding, H0 allocation/copy and synchronous native call. finish_ns covers native
tail plus metadata/frame validation, copying/synchronization and original business
decode. Auxiliary encode timing is diagnostic and must not be added again.
Report first requests, actual per-request miss count, warm and new-word cohorts,
median/P95/max and every over-limit count. In full mode new words are table hits;
true lazy-cache cold misses retain their own mode/cohort. Both input750000ns and
tail2250000ns are full-wrapper targets. Initialization includes complete verify,
weight/pool/cache setup and original tokenizer lazy static-regex construction.
Reference import/execution is blocked in the separate production profile process.
Frozen hidden frames paired with explicit JSON labels measure only local CPU
latency, never full-model answer quality, board/Attention timing or system QPS.
