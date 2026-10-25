# G-COMPACT-14 bounded engineering handoff — 2026-10-22

execution_state: completed (bounded G compact-control and functional-cycle stage)

verdict: G_ONLY_CONTROL_TARGET_AND_FUNCTIONAL_CYCLE_PASS; JOINT/PARENT/PHYSICAL_OPEN

A008 `/root/m007_host_tail_engineering` completed the authorized SM011
`D-M007-SM011-G-COMPACT-14` continuation in the original E015/R001. Desired
model/effort remain gpt-6.1-sol/xhigh; actual model/effort are unverified. No new
budget, parent storage credit, shared interface change, or new OOC was used.

## Capacity and version boundary

| Account | Before | Current |
| --- | ---: | ---: |
| G-only declaration control | 46938 bit / 5867.25 B (AT071) | 15709 bit / 1963.625 B (AT106) |
| Repeated stored tag width | 394 × 96 bit | 394 × 16 bit |
| Added context/valid/order | — | 291 bit, fully charged |
| Net control saving | — | 31229 bit / 3903.625 B |
| Mask/debt/coverage/unread-tail bits removed | — | 0 |

The G-only ≤2048 B target is met. Bounded numeric payload remains 25600 B and
fixed numeric alignment 736 B. Existing SFU queue/lease/tag-mask and numeric
leaf pipeline storage remain unchanged separate accounts. **Joint 4 KiB fit
remains OPEN.** No future physical reuse is credited.

Only `laya_m007_g_math_v1.sv` and `laya_m007_g_vector_pool_v1.sv` changed.
Math328 + G pre-credit32 + pool34 stored tags retain the full sequence16.
Public tags remain `{generation32,epoch32,16'b0,seq16}`, where
`seq=s*512+row*4+chunk`, range 0..41983. High64 identity, reserved16 and fullseq16
are checked before real returns retire; low8 only indexes the ring. Context
persists across empty intervals, held outputs and lifecycle fences. Math adds
context64/valid1/next-input16=81 bit; pool adds context64/valid1/fault1/nine
next-seq16=210 bit. Shared credit source, engine/pairs, TANH8, numeric leaves and
native storage retain precompact SHA. The G pre-credit instance alone selects
TAG_WIDTH16. [Exact source delta](g_compact14_source_delta_v2.json) and
[field census](attempts/AT106_g_compact16_explicit_context_state_census/work/report.json).

Current accepted builds are AT090 pool and AT101/102/103/104/105
math/production/tag-probe/numeric/peer. Final audit found no current selected
source differences for those builds. Earlier compact and precompact builds
retain their original snapshots; no historical PASS is upgraded.

## Functional and cycle evidence

AT095 pool inputs passed 8 cases, 9 actual accepts/returns and 7 rejects.
AT107 math inputs passed 7 cases, 7 actual vectors / 56 original scalars /
560 FP9+H checks and 6 rejects. Mixed first acceptance, generation/epoch,
reserved16, fullseq alias, held17/empty17 and repeated seq0 after explicit
clear were checked. Context never rebinds merely because the stream empties.

AT108/111/112/113/114 inject, respectively, seq256 while real SFU seq512 is owed
(same ring low8), old generation, wrong epoch, nonzero reserved16 and an extra
FP return. The genuine accepted request and return are preserved; invalid
records retire no debt, and the genuine correct return subsequently arrives.
All original FP9/H/output comparisons remain. Partial done8, held17, explicit
discard, real lease release and newgen12288 original prefix pass. AT115 also
rechecks the original matching FP status8 fault/discard/recovery case. These
are protocol counterexamples, not fabricated normal numerical errors.

AT109/110 normal three-block and held-final17 pass. AT116/117 final same-build
32768-scalar pilots take 17.76166324602673 / 17.755463239969686 seconds.

[AT118 complete normal](attempts/AT118_g_compact16_complete_original_normal/work/report.json)
passes 335872 exact outputs and 3358720 FP9+H comparisons, 20992 real native
writes and ACKs, 41984 reads, 82 releases and zero accepted debt. First actual
consume is 185 cycles; natural eligible to real done is 42171; max block697;
read/output gaps1. Actual overlap20735 and independent release with the other
slot math/SFU live81. All data/timing fields match old AT072. Wall
128.6858779839822 seconds; 328 semantic events.

| Current full case | First original error | Main node checks | Actual child wall s |
| --- | --- | ---: | ---: |
| AT120 rank0 exact command | rank0 / row127 / col2623 | 3358710 | 135.0427505680127 |
| AT121 rank2 | rank2 / row127 / col2623 | 3358713 | 130.32625765696866 |
| AT122 rank5 | rank5 / row127 / col2623 | 3358715 | 130.87936729897046 |
| AT123 inverse row | rank7 / row0 / col32 | 3358720 | 131.77660471200943 |

Each passes 335872 main scalars, two numerical error records, done6 held17,
wrong-generation discard rejection17, matching explicit discard, actual lease
release, and **no reset** new generation12288 original scalars. Each totals
348160 scalars and340 actual semantic events. Original independent masks check
all covered/evaluated counters. Recovery waits for unprovided s3: it is a
three-block prefix, **not whole newgen command completion**. Frozen AT058
all128-row12-field fixture and AT070 primitive/libm sparse error reference are
unchanged. Frozen AT055 TANH8 and unchanged numerical suites are reused.

## Retained failures and audit

- AT092 semantic stall at120.09952738101128s was caused by a test-only
  combinational request probe; registered actual accepted-request probe AT099
  passed unchanged DUT, and final AT108/111–114 passed. It does not refute
  control compaction.
- AT096/100 exposed a real zero-high64 output tag after private clear and
  repeated seq0. Context read implicitly by a function did not update that
  continuous evaluation. Explicit context/valid arguments fix the boundary;
  AT107 retains all seven assertions and diagnostic. No state, arithmetic or
  interface changes were added by the fix.
- AT119 is COST_GATE_STOP/child0 because argv order differed from the exact
  cost plan. There was no child, source archive, work directory, CPU policy or
  cleanup record. AT120 copied planned argv exactly and passed. No fake run.
- AT124 static audit failed from module cwd because historical relative
  driver paths are rooted at the project. Child0.20950022799661383s and empty
  cleanup are retained. Fresh AT125 from project cwd passed in
  0.9255045960308053s; functional sources/tests were unchanged.

[AT125 release audit](attempts/AT125_g_compact16_final_release_audit_project_cwd/work/report.json)
verified AT082–123: 42 compact attempts,41 source archives,2254 archived files,
364 compiled snapshot files,169 selected source/input checks; actual reports,
raw semantic event identities and monotonicity, exact guard SHA/mode, CPU/RSS,
fixture identities, original normal timing equality and all four full cases.
The final ledger additionally preserves/debits AT124 and AT125. Historical
AT008–013 exact loaded guard SHA UNKNOWN, AT034 never-launched and all old
FAILs retain their boundaries.

The appended `experiment_source/protocol.md` Compact14 supplement is final
documentation. Earlier attempts froze the then-current generic G protocol;
Compact14 authority was the actual SM contract plus source/TB/driver snapshots.
Per-attempt protocol SHA and archives are immutable; prose is not a retroactive
protocol replacement.

## Original cumulative budget and remaining scope

[Final123-receipt ledger](g_compact14_final_budget_20261022.json), all seconds:

| Phase | Original cap | Actual used | Remaining |
| --- | ---: | ---: | ---: |
| reference | 900 | 6.22685811700648619 | 893.77314188299351381 |
| static | 1800 | 376.97450915820081496 | 1423.02549084179918504 |
| RTL | 3000 | 2274.667276495922106 | 725.332723504077894 |
| OOC | 1800 | 776.07547476305626 | 1023.92452523694374 |

No nonterminal receipt or live owned E015 guard remained at final accounting.
No balances reset/transferred; all failures/stall/gate records remain. The
≥120-second RTL short/archive reserve is retained. All actual compute used the
original shared heavy lock, CPU0–3/nice19/idle I/O, MemAvailable>192GiB and phase
RSS/semantic protections.

Controller review and centrally defined parent physical control reuse are the
next boundary. Joint4KiB/896DSP/SFU/resources, Wi/G/Down parent overlap,
FFN/Decision/deployment, OOC/P&R/physical300MHz remain OPEN. Functional cycle
results do not prove implementation timing. No further experiment or shared
interface change is launched by this handoff.
