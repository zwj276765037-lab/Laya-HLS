# A008 G functional/cycle stage handoff — 2026-10-22

execution_state: completed (bounded functional/cycle stage)
verdict: FUNCTIONAL_CYCLE_PASS / CONTROL_CAPACITY_NONCOMPLIANT
review: A001 pending final audit

Current scope is SM011 D-M007-SM011-TANH-G8-08, E015/R001. User resumed M007 on2026-10-22. Frozen AT055 TANH8 is reused without rerun. No compact-metadata change or shared-interface change is authorized by this handoff; controller will define the next stage. Desired gpt-6.1-sol/xhigh, actual model/effort unverified. Runtime identity /root/m007_host_tail_engineering.

## Actual normal production G

[AT072 report](attempts/AT072_g_engine_full_original_335872/work/report.json) and [receipt](attempts/AT072_g_engine_full_original_335872/receipt.json):335872 original128-row G outputs and3358720 FP9/H comparisons bit-exact;20992 actual32F32 writes+matching ACKs,41984 actual synchronous16-bank reads,82 actual slot releases. First consume185 from natural s0 eligible; full real done42171<=42240, largest block service697<=768. Read/output gaps1 across s.20735 real read/write overlap edges,81 releases while the other slot has actual math+SFU debt. Pending peak183, held normal done17 and actual SFU lease release passed. Child129.274490395037s/RSS864370688B;328 actual semantic events. No parent Wi/G/Down/FFN proof is inferred.

Natural eligible is max(cmd acceptance,last real write ACK) for s0; for later s, max(this slot last real write ACK,previous s's512th actual read acceptance+1). Report retains first_ready/eligible/first_read/last_consume/release/queued_wait for all82 blocks. [AT068](attempts/AT068_g_engine_held_final_three_groups/work/report.json) separately proves held last s0 output17 prevents slot0 reuse, while slot1 continues genuine arithmetic; pending200.3-block prefixes retain the command waiting for unprovided s3, not full command success.

## Actual numerical order and recovery

[AT070 independent sparse reference](attempts/AT070_g_sparse_original_error_reference/work/report.json) changes only two original input scalars per case, recomputes them with SHA-bound original F32 primitives/libm and reuses unchanged original products. No DUT-derived expected values or new full-model gold. Original rank is input/u/v/w/t/z/y/gate then row/column.

| Case | First error rank/row/column | Eligible main FP9/H checks |
| --- | --- | ---: |
| AT075 gate_then_late_input | 0/127/2623 | 3358710 |
| AT076 gate_then_late_v | 2/127/2623 | 3358713 |
| AT077 gate_then_late_z | 5/127/2623 | 3358715 |
| AT078 gate_inverse_row | 7/0/32 | 3358720 |

Each case actually consumes335872 main outputs,2 numeric error records, then holds done6 for17cycles; wrong-generation discard is rejected for17cycles, matching public discard clears only after real debts zero, actual old lease release/rebind follows, and12288 new-generation original outputs pass without reset. Total348160 scalars per case;340 semantic events each. The new generation is a three-block prefix, not a whole new command completion. No finite-domain u/t overflow or unreachable numerical counterexample is fabricated. Dominated node exclusions are10/7/5/0, independently derived and counted; they are not fake evaluations. All8 covered/evaluated counters are checked against the original-domain masks.

## Actual protocol-only fault

[AT080](attempts/AT080_g_peer_status_partial_discard_newgen/work/report.json) uses a separate validation-only public return interposer: node-u vector64/lane0 actual matching FP valid/tag/data remain unchanged, status becomes8 once.69 accepted math vectors/69 output consumptions,70 actual bank reads/returns and327 actual writes/ACKs drain before partial done8. One real peer error record, held done17, explicit partial discard, actual lease release and no-reset newgen12288 original outputs passed. Total12840 scalars/128390 unaffected eligible checks. The one extra accepted bank response is actually drained after protocol stop without fabricated math admission. Numeric full-coverage success is explicitly rejected. Wrong/missing-tag G return injection was not run; frozen TANH protocol evidence has its own scope.

## Implementation and version boundary

Production engine instantiates only pure pair+math controllers. External resources in validation are exactly one existing laya_attention_storage_v1, one frozen TANH8 and56mul/16add G pool; PS/context ports disabled. Parent must retain phase1 for simultaneous Wi PS/G use; G never rebinds physical storage. Public tags96, request64/gen32/epoch32 remain. Prefix data are cancellable; Down arithmetic must wait for whole-request successful rank/coverage done. Future quant/A cancellation and parent physical resource sharing remain controller/A010/A007 work.

Current accepted source builds are AT056(pair),AT063(pure math),AT066(normal production),AT073(numeric recovery) andAT079(peer). [AT081 audit](attempts/AT081_g_stage_release_evidence_audit/work/report.json) verifies25 resumed attempts/25 source archives/1009 archived files/181 build snapshot files/90 selected source or input files. All currently accepted selected sources match current files. AT059 differs in old FIFO-width math+observer; AT061 differs only in old observer; those frozen historical identities remain intact. Actual storage SHA c36d0089cebaa6dd90cb8dbe11a4c33d65224ee69fdc24f454dcfd08d464ad0b is byte-identical to E016 AT013's same-named frozen source; this does not prove parent dynamic integration.

AT060/062/065 FAIL retained. AT060 printed equal scalar got/expected while its assertion fired; exact old observer mechanics remain unproved. AT062 packed diagnostic exposed repeated lane0 expected construction; direct frozen-fixture indexing in AT063/064 passed without relaxing bitwise/node coverage. AT065 declaration-order error was fixed by moving math_in_ready before use. AT051 and all older timing/cost boundaries remain immutable; AT034 was not launched, AT008–013 exact loaded guard self-SHA remains UNKNOWN under its historical narrow boundary.

Guard v3 SHA c6e61e709cab196edc9386fc3c0e64dcc61fd612bcd33fabd99a53e31453e294 remains frozen. G v4 SHA9e26368b7e8f241e0030d0856ea6c55f4223313941737de49f947dfdc7610020 binds normal original fixture and measured same-build32768 pilot; AT072 actual bound217.58084567542684<=240s. Error v5 SHA936b7b2a791f3cd61d9aefa943b6fcd0677b85a24149e122fd8db1a4766a40ad binds sparse original error fixtures and actual recovery count. AT074 actual same-v5 prefix pilot18.284891585004516s supports AT075 bound223.7046703997403<=240; full AT075132.03900283394614s supports AT076–078 bound155.24290311734077<=180. Original lock/CPU0–3/nice19/idle I/O/MemAvailable>192GiB, RSS caps,120s actual checked-consume stall and descendant cleanup remain; no fake heartbeats.

## Exact capacity boundary and next controller decision

[AT071 source census](attempts/AT071_g_exact_source_state_census/work/report.json): G control46938bit=5867.25B, exceeding4KiB. Bounded arithmetic payload25600B (x/gate/result plus1024B precredit) and fixed numerical alignment736B are separately counted. Fixed numerical leaf internals and existing TANH/SFU are separate, not deducted or counted twice. This is a source declaration census, not synthesized RAM/resource inference. No fit/whole8lane OOC/P&R/physical300MHz is claimed; prior small-leaf hold violations remain.

Identity4747B, lane masks822B, real credit186.125B, coverage102B, error10.125B compose current control.394 vector96bit tags (math328/precredit32/pool34) alone use4728B. Single-command gen/epoch/upper reserved bits and physical node channel permit a candidate16-bit monotonic vector key; theoretical3940B saving excludes newly needed context/validation and is NOT implemented or debited. Per-lane errors/domain masks and live/available/sent/received, slot math/SFU/FP debt are real state. Pair pending-write constant/coordinate duplication is listed as another proved-reconstruction candidate. Controller defines compact fields, true lifetimes and physical sharing before any implementation; public shared SFU interfaces unchanged.

## Final original ledger and actual stop

[Final79-receipt ledger](g_stage_final_budget_20261022.json): remaining seconds reference893.77314188299351381,static1623.30024662983487389,RTL1740.546679483988542,OOC1023.92452523694374. Original900/1800/3000/1800 caps retained, all failures/audit charged, no transfers/reset. All owned resumed descendants/groups cleaned; no A008 G guard remains. Production RTL stays at the tested identity pending controller's compact-metadata contract. Functional/cycle stage completion does not mark E015 capacity, whole M007, combined EXP/TANH/FFN, Decision or deployment complete.
