# NATIVE-CPU-03: persistent native CPU handoff

execution_state: completed
functional_verdict: PASS_SCOPED_NATIVE_CPU_SESSION
performance_verdict: FAIL_SAMPLED_LIMITS
mission: M007 / SM009 / E009 / R002; owner: A008

The persistent native implementation is complete for this experiment. CPU overall
performance remains open. A001 has reviewed the final156 functional checks and
the same-version full/lazy profiles; no Attention, XRT, board, whole-model quality
or CPU/GPU comparison is accepted by this delivery.

## Fixed version and entry

Implementation: E002 `host/m007_deploy/native_session.py` and `native_session.cpp`.
`NativeSession(library, model, assets)` initializes once; `prepare(real_json, id,
generation)` returns owned H0/immutable Request plus source/question association;
`finish(prepared, compact_tail, completion=optional_real_metadata)` validates and
retires the same request and returns18 F32 logits plus the original business answer.
Use a context manager or close() to release its native weights/cache/thread pool.
The existing reference CLI remains an explicitly separate reference backend.

Final binary [libm007_session.so](AT022_native_session_regex_init_build/build/libm007_session.so)
SHA256 `921b329faa0858ca3aa4e1ea52e709965b7a0042e364e39e8da717acc8593d72`.
[Build identity](AT022_native_session_regex_init_build/build/libm007_session.identity.json)
binds38 production source files, generated decoder body, compiler flags and actual
libm. [Native closure](AT022_native_session_regex_init_build/build/native_sources.tar.gz)
contains39 recoverable files, SHA256
`eb73424cb2283dd4b3e07b749738c40705f34b666e8868d0e5ac4126dd980c6c`.
Full provenance and completed ledger: [release_evidence_v4.json](release_evidence_v4.json).
The pre-R002 v3 archive and original R001 records remain unchanged.

The bound model SHA is6eb6ef58...a1f18, graphf33f7848...815f9,
reference numeric contractfe9678e4...e9784, schema c3d8d192...d24c.
The original shared Host, model, reference and HLS/RTL sources were read-only.
This build targets Xeon6248R x86_64 AVX512F/BW/VNNI and glibc2.39 libm SHA256
fce00b6f25f459cf4ae0b7fae4257909a1a8a86f9149e7c029a5d617baf1ccd0.
Native arithmetic has no FMA/fast-math/FTZ/DAZ. Original adjacent trees, K/group
orders, full-F32 quantization scale, half expansion and both scorer biases remain.

Default full cache stores all50368 model-token post-initial-gamma-LN rows only,
206307328B. Final measured full initialization1472907305ns includes135673406ns
row prefill plus model/inventory/source/binary/libm/metadata/recipe/weights/thread/
regex setup. No request hidden, tail, logit or answer memoization exists. Lazy mode
uses the same library and is retained to measure true row misses. Cache mode and
model/source identity are bound; a new Session rejects all old Prepared objects.

## Exact functionality and error behavior

[AT023](AT023_native_session_final_functional/checks/report.json):156 checks PASS.
The same lazy Session runs both original frozen requests; each compares all131072
H0 values,13 tail checkpoints,rawCLS and returned final18 with zero bit differences.
The full-table Session repeats both H0/tail cases and an arbitrary new token;
all values equal frozen/independent lazy-miss expectations. The test additionally
compares a seeded local random tail with the independent Python reference; no new
whole-graph gold is generated.

Original-native comparisons cover4 real JSON baselines and42 legal business-decode
vectors. Strict128/129, legal option>48, candidate17, duplicate markers, id/gen,
model/source/question binding, reload and stale completion are covered. VNNI
primitive23 groups x16 outputs equals independent I32 dots including signed-128,
cancellation and seeded random values. Nonfinite/finite-overflow errors leave
caller output sentinel unchanged. Native initialization failure recovers.
Caller fenv/control masks and affinity restore after normal and exceptional calls.

Production profiles independently block numerical-reference import/execution.
Caller native work locally pinsCPU0 and restores its original0–3 mask; actual
worker masks1/2/3 were observed. [AT027 assembly/source audit](AT027_native_cpu03_final_audit/audit/native_asm_audit.json)
found16 non-saturating VPDPBUSD instructions,0 saturated VPDPBUSDS and0 FMA in the
owned library. All38 current production source hashes match the recoverable archive.

## Actual final latency and remaining gap

Full input interval is one real prepare(data) call, including its internal JSON,
BPE/recipe, binding/validation, H0 allocation/copy and native synchronization.
Full tail interval includes frame validation/copy, native math and business decode.
Auxiliary encode is diagnostic and is not added again or excluded from prepare.

| Cohort | Input median/P95/max, ns | Tail median/P95/max, ns | Input/tail violations |
| --- | --- | --- | --- |
| [AT025 full warm200](AT025_native_session_final_profile200/profile/report.json) |498548/588732/666537 |1912645.5/2080202/2726395 |0/200,6/200 |
| AT025 new words32, all full-table hits |476758/494244/495972 |1901413.5/1925048/1933525 |0/32,0/32 |
| [AT026 true lazy misses32](AT026_native_session_final_lazy32/profile/report.json) |542792/594254/601589 |1862338/1900331/1901052 |0/32,0/32 |

AT025 first two full-cache inputs1141907ns/913050ns exceed750000ns even with0 new
rows. Their tail1904130ns/1362959ns meets2250000ns. AT026 first26/32-new-row inputs
1115594ns/914669ns exceed; first tail2263643ns exceeds. Full profile has234 complete
calls (2 first+200 warm+32 new-word); lazy has66 (2 first+32 warm+32 true misses).
These cohorts are not combined to conceal first-call or tail violations.

Final startup pilot AT024 also failed first inputs. Earlier pilot/200-sample failures
and infrastructure failures remain in their own AT directories. No same-binary200
run was repeated to seek PASS. Only two frozen hidden frames paired with explicit
business labels were used for local tail timing, so these samples imply no new
whole-model accuracy or system QPS result.

The next concrete CPU optimization boundary is a fused native JSON/request/H0
entry eliminating the large token/mask JSON roundtrip and duplicate language
binding overhead. Native scorer/synchronization tail outliers still need causal
profiling before further layout/scheduling claims. No larger rewrite is started
in this delivery; the controller can keep the main hardware path moving.

## Cost and successor

All27 R002 attempts, including every failure: reference/unit29.906244418991264s/600s,
compile173.74383348802803s/900s, local CPU profile15.288382256956538s/180s. Peak sampled
owned-tree RSS434528256B, maximum child<120s, CPU0–3/nice19/idle/shared heavy lock;
no R001 balance transfers. Exact commands, timestamps and policies are in receipts.
No owned process remains running. Desired model/effort are recorded separately
from unverified actual model/effort; actual fields remain null.

This closes the scoped native CPU experiment with a functional PASS and performance
FAIL. CPU deadlines stay open. The controller will issue the separate activation
quantizer hardware contract; no quantizer source or run has been started here.
