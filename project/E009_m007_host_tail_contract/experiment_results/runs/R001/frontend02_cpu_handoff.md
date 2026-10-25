# FRONTEND-02 → persistent native CPU handoff

This is a source/functional timing handoff for A001, not a new CPU benchmark.
Sources and numbers bind AT020–023 and release_evidence_v3.

## What is native now, and what still uses Python

| Path | Current execution | Minimum next seam |
| --- | --- | --- |
| state/questions rendering, compatibility recipe, BPE, strict S128 | original native sources plus local uncut assembler, persistent child within NativeFrontend | retain semantics, unify native lifecycle with H0/tail; count actual Python/native wrapper |
| H0 Embedding + gamma LN | cpu_contract.py → frozen Python embedding_row/layernorm_many | direct original C++ row functions, optional general model+token exact post-LN cache |
| marker LN, scorer Q8/GELU/FP scorer, candidate stats, ACT FP16/GELU/Q8 | entirely Python/NumPy full_reference calls, scalar libm ctypes where not batched | persistent native weights/scratch and unchanged strict row/window leaves; Python only independent oracle |
| final business decode | native original member body/temperature/confidence/ACT/rounding with strict entry guard | reuse directly in the same native session |
| per-CLI startup | full model/source verification + metadata + native helper; GGUFWeights separately verifies model | once per persistent session/model; reload must invalidate dependent caches |

## Existing functional execution timings

AT021 (CPU0–3/nice19/idle, single functional execution): native session init
1,228,093,803ns; GGUFWeights init1,061,489,729ns. H0 calls166,208,064ns and
21,032,300ns. The first includes tensor read/cache and first reference setup; the
second uses the same cached model handle. These are not warmed P50/P95 samples.
AT022 actual CLI repeats: native init1,212,822,460ns; model handle1,031,482,705ns;
H0 calls167,032,644ns and20,991,089ns.

AT021's 8 successful encode calls span270,798–1,054,973ns and45 successful decode
calls109,037–245,943ns. These include Python JSON/pipe/native round trips and use
different functional inputs. They are not a throughput test. No whole-tail or
whole-CPU performance benchmark ran, and neither750us nor2250us is accepted.

## Existing C++ reuse boundaries, actually host-compiled

AT023 compiled all9 source files to ordinary host objects with g++13.3,
C++17/O2/-fno-fast-math/-ffp-contract=off and only `-Iinclude`. No ap_int/HLS
header dependency blocked the default host configuration. Objects were not linked
or numerically exercised here; direct compilability is not speed/equivalence.

| Source/function | Lowest arithmetic adaptation boundary | Remaining care |
| --- | --- | --- |
| embedding_full_compute.cpp::embedding_row | raw1088B Q8 row →1024F32 plus Check | exact scale/Q domain; cache only row result keyed by model/token |
| layernorm_compute.cpp::layernorm_row_arithmetic | one1024 row and gamma_kind/gamma →same ordered tree output | preserve adjacent tree, sqrtf/division and separate rounding; initial gamma on, marker gamma off |
| attention_full_compute.cpp::fp_scorer_row/fp_act_row/softmax_row | ordered1024/1028 FP reductions and16-way softmax | preserve K/key order and F16 extension, no FMA |
| decision_full_compute.cpp::candidate_mask/candidate_stats/concat_act_row | fixed16 probabilities/stats + raw CLS | raw CLS must stay original; graph stats differ from business confidence recipe |
| q8_linear_compute.cpp::q8_linear_window_arithmetic | pure C functional row/group/column window with group-ascending restore | avoid owned RTL wrapper; keep group32 integer bounds, two separate F32 multiplies, ordered PS and final bias |
| activation_quantizer_compute.cpp + laya_quant_group_service.cpp | original group32 native float arithmetic can be factored locally | current full task packs owner echo/blackbox transport; use full F32 d before F16 scale, original roundf and error rules |
| vector_full_compute.cpp + vector_libm_bits.cpp | original GELU/scalar bit implementation | integer software FP/tanh implementation may dominate; direct same-system libm is a candidate only after proving exact frozen per-operation/function behavior |
| hls/common/laya_numeric.cpp | bit casts, half conversion and required status helpers | link a minimal closure and preserve error detail; object compilation alone is insufficient |

No shared source needs editing to begin a local native session adapter. A local
read-only source extraction/wrapper is possible when whole task metadata would
otherwise drag in unrelated transport. Record every original source/header and
generated body identity. Production must not call the Python numerical reference.

General post-gamma-LN token cache is semantically possible because both embedding
and initial LN are row-local. A full50368-token cache is196.75MiB F32; bounded
replacement is also possible. It must cover genuine miss/hit equality and model
reload invalidation and must never cache hidden/tail/logits or fixture answers.
RNE, FTZ/DAZ and actual libm identity need explicit native-session checks in R002;
compiler flags alone do not establish the runtime floating environment.
