# G-RING-TAG-15 bounded engineering handoff — 2026-10-22

execution_state: completed (bounded ring-tag control and affected functional-cycle stage)

verdict: G_ONLY_1707_625B_AND_CURRENT_REQUIRED_REGRESSIONS_PASS; JOINT/PARENT/PHYSICAL_OPEN

A008 `/root/m007_host_tail_engineering` completed SM011
`D-M007-SM011-G-RING-TAG-15` in the original E015/R001. Desired model/effort
remain gpt-6.1-sol/xhigh; actual model/effort remain unverified. No subagents,
new budget, OOC, parent storage credit or shared-interface change were used.

## Current implementation and exact accounting

Only production `rtl/laya_m007_g_math_v1.sv` differs from the accepted AT102
compact16 build. Its current SHA256 is
`849917c06995c4208d7b94b530c1071cdf6b4b76b6b0685dd1e17fc19531bb2e`.
The 256×16-bit `tag_mem` now stores 256×8-bit `tag_mem_hi`. Accepted sequence
low8 equals the real slot address, so explicit `slot_seq(high8,index8)` restores
the fullseq16 before public output or return matching. `full_tag`, `slot_seq`
and `context_match` receive every dependency as explicit arguments.

Independent expected tags and every other tag pipeline remain full16; public
tag stays `{generation32,epoch32,zero16,seq16}`, range0..41983. High64 identity,
reserved16, fullseq16, actual live/sent/received and independently accepted
expected tags remain checked. Context does not rebind on empty. No mask,
bitmap, actual debt, coverage/evaluated, first-error logic, payload or unread
tail was removed. Engine/pairs/pool/shared credit/storage/TANH8/numeric leaves
retain the AT102 selected SHA. Related TB changes preserve all old assertions.

| Source-declared account | Compact16 AT106 | Ring-high8 AT133 |
| --- | ---: | ---: |
| G-only control | 15709 bit / 1963.625 B | 13661 bit / 1707.625 B |
| Math-only control | 13391 bit | 11343 bit / 1417.875 B |
| Ring slot tags | 4096 bit | 2048 bit |
| Additional storage in this stage | — | 0 bit |
| Original Compact14 context/valid/order | 291 bit, charged | 291 bit, charged |
| Mask/debt/coverage/tail bits removed | 0 | 0 |

Exactly2048bit/256B saved this stage; relative to precompact5867.25B, net saving
is4159.625B. Numeric payload remains25600B and fixed numeric alignment736B.
SFU queue/lease/tag-mask and numeric leaf internals remain separate accounts.
**Joint4KiB, parent physical sharing and resource fit remain OPEN.** The proposed
physical overlay of math control is a controller architecture candidate, not an
implemented saving.

[Exact source delta and unchanged dependencies](g_ring15_source_delta_v1.json),
[AT133 field census](attempts/AT133_g_ring15_exact_state_census/work/report.json).
Current accepted builds: AT126 full-ring, AT127 domain, AT128 production,
AT130 tag-fault, AT131 numerical-error, AT132 matching-peer. Final audit
checks all selected current source identities and compiled snapshots.

## Required actual regressions

- **AT134 real full256 ring:**12288 original scalar outputs/122880 FP9+H
  checks,1280 simultaneous consume+accept replacements of the same slot,
  three held17 records (51 held cycles), actual seq255/256 and511/512
  boundaries. Old full96-bit record remains stable during holds; pre-edge
  old high8 and new seq difference256 are checked at each full replacement.
  Real math,56mul16add pool and TANH8 are used, with no forced state. First
  consume273 includes intentional full-queue output hold; it is not production
  no-stall latency.
- **AT135 domain/clear:**original7 cases,7 actual vectors/56 scalars/560 nodes,
  6 rejects, held17/empty17 and explicit clear followed by unchanged seq0 pass.
- **AT136/137 production short/held:**three original blocks, first185,
  maxblock697, actual two-slot overlap and final held17 pass.
- **AT138–142 public bad returns:**real SFU seq512 vs injected seq256 with
  same low8, old generation, wrong epoch, reserved16 and extra FP record. Bad
  records retire no actual debt; genuine correct returns are preserved and
  subsequently arrive. Original FP9/H/output checks, partial done8 held17,
  explicit discard, real lease release and no-reset newgen12288 pass.
- **AT143** original matching FP status8 fault and actual discard/newgen
  recovery pass.

AT144/145 new same-build32768 normal/error pilots pass in
18.059037896979135 /17.855849508021493s. Exact frozen-v4/v5 cost plans bind
argv/build/driver/fixture/guard and real semantic progress. AT146 normal uses
measured bound213.61565228843975s/cap220; AT147 rank0 uses218.69024112500122s/
cap230. AT148 inverse-row uses actual complete AT147 as same-build measured
full-size basis155.11860185020487s/cap170, with142.213336546003138s worst-cap
RTL reserve before launch. No timeout or budget was enlarged.

| Current full case | Original output/node checks | Actual child wall s |
| --- | --- | ---: |
| AT146 normal | 335872 /3358720 | 131.26044220704352 |
| AT147 rank0 row127 col2623 | main335872 /3358710; total348160 /3481590 | 131.92600168200443 |
| AT148 rank7 row0 col32 | main335872 /3358720; total348160 /3481600 | 132.78237547597382 |

AT146 timing/data fields exactly match accepted AT118 and original AT072:
20992 real writes plus ACKs,41984 reads,82 releases; first185, natural eligible
to real done42171, maxblock697 cycles; read/output gap1; overlap20735 and81
independent releases with the other slot math/SFU live;328 semantic events.

AT147/148 each checks two numerical error records, done6 held17, wronggen
discard rejection17, matching explicit discard, actual lease release and
**no reset** new generation12288 original scalars,340 semantic events. Original
covered/evaluated masks remain independently checked. Recovery is three blocks
waiting for unprovided s3, not whole newgen command completion.

**Rank2/5 are not rerun under current SHA.** Original compact16 AT121/122 PASS
and original report/build identities are reused only for unchanged arithmetic
and lexicographic first-error logic, as explicitly authorized. Full current
rank0/inverse-row and all ring/tag/domain cases supply the affected storage
coverage. Frozen AT055 TANH8, AT058 original128-row12-field fixture and AT070
primitive/libm sparse error reference remain unchanged; no new gold.

## Audit, failure and immutable boundaries

AT129 elaboration FAIL is retained: the tag-fault TB still observed the old
array name. Its original fullseq512 precondition was preserved by observing
`{tag_mem_hi[0],8'd0}`, not by removing the assertion. Fresh AT130 builds and
AT138–142 all pass. The failure costs3.7697412100387737 static seconds; no RTL
failure is hidden and production RTL did not change during the stage.

[AT149 final audit](attempts/AT149_g_ring15_final_release_audit/work/report.json)
passes23 stage attempts/23 source archives/1383 archived files/170 compiled
snapshot files/91 selected source-input checks. It verifies guard identities,
CPU/priority/memory/RSS/cleanup, every archive, raw semantic identities and
monotonicity, current builds, census, all required full cases, exact unchanged
normal timing and explicitly old rank2/5 report identities.

All Compact14 failures/stall/zero-child cost stop and AT124 audit-cwd failure
retain their original SHA/receipts. Historical AT008–013 loaded guard SHA
UNKNOWN and AT034 never-launched boundaries remain. Protocol adds Ring15
launch rules before this stage's attempts; prior Compact14 post-run supplement
and per-attempt protocol SHA are not rewritten. Earlier handoffs remain history.

## Original cumulative budget and integration boundary

[Final147-receipt ledger](g_ring15_final_budget_20261022.json) verifies the
previous123 receipt byte identities unchanged, all24 new terminal receipts,
empty owned cleanup and no live E015 guard/nonterminal receipt.

| Phase | Original cap s | Actual used s | Remaining s |
| --- | ---: | ---: | ---: |
| reference | 900 | 6.22685811700648619 | 893.77314188299351381 |
| static | 1800 | 474.15852085137157652 | 1325.84147914862842348 |
| RTL | 3000 | 2820.569038929970682 | 179.430961070029318 |
| OOC | 1800 | 776.07547476305626 | 1023.92452523694374 |

All original caps, heavy lock, CPU0–3/nice19/idle I/O, MemAvailable>192GiB,
phase RSS and120-second actual checked-consume stall protections remain. No
reset/transfer, no new OOC. At least120s RTL archive/short reserve remains.

This is the engineering handoff for the next single-workspace integration.
A001 owns central review and any physical control sharing contract. Joint4KiB,
SFU/896DSP/resources, Wi/G/Down overlap, FFN/Decision/deployment, P&R/physical
300MHz remain OPEN. Functional-cycle PASS does not prove physical timing.
No further compute or shared-interface change is launched by this handoff.
