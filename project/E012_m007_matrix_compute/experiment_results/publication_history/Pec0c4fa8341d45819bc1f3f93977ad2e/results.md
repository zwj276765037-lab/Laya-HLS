# E012 / R001 MATRIX-02 final local results

execution_state: completed (R001 local segment)
verdict: supported for the frozen prequantized M128xN64 scope

The unique integer/format/A/W/sharedFP/PS path passes four original-source local superblocks. Final repaired DUT is frozen in AT020 and identically in AT027; AT022/023/024/025 re-run all four shapes after the W-tag repair. AT022/023 include their normal complete block after actual reset/error and new request/generation/epoch reload. AT021 QKV and AT028 FC2 add actual finite stalls. AT027 changes only the finite-stall TB completion watchdog/diagnostic, retaining all normal K+384 and independent numeric checks. Exact diff: runs/R001/finite_stall_watchdog_diff.txt.

| Shape | Final attempt | Continuous issue span | Last output / done | Cap K+384 | W service |
|---|---|---:|---:|---:|---:|
| QKV K1024 | AT022 |1024|1317 /1320|1408|735|
| Wi s81 K1024 | AT023 |1024|1317 /1320|1408|735|
| Down K2624 | AT024 |2624|2917 /2920|3008|1633|
| FC2 K4096, original64bias | AT025 |4096|4398 /4401|4480|2463|

Each normal run checks every actual A/W issue, all256 dots/scale-product/conversion/term/PS write-ack lanes and all8192 final F32 values bitwise. Max issue-to-real-PS-ack31cycles, max PS feedback13cycles,0 normal output bubbles; RUN token+shared-return peak50. OUTPUT bias reservation is separately bounded64 with shared pending<=64; no overlap-credit peak is claimed. QKV128 rows are original embedding_norm; Wi/Down/FC2 each contain16 exact original rows plus112 independently generated diagnostic rows. The16-row subsets match existing original local gold. QKV does not reuse the different old16-row fixture. Exact sources/row coordinates/hashes are in AT010/work/fixture/matrix_fixture_report.json.

AT021 QKV finite stalls:210 issue pauses,109 W-request stalls,62 W-response stalls,120 output-held cycles,8192 outputs exact. AT028 FC2 finite stalls:672/407/265/115 respectively; issue span4747,last output5167,done5170,8192 outputs and bias exact. Six wrong descriptor identities reject with zero arithmetic. AT022 reset was applied at80 issues/49 commits with32 arithmetic reservations and2 public A debts;12 post-reset clocks show no stale transaction validity, then actual new-generation slot1/ctx1 reload completes. AT023 negative W scales are admitted by the real loader, rejected by matrix entrance at observed original(row0,column5219,group1);44 real issues equal44 PS acks. Mixed response-epoch/numeric error prioritizes protocol and drains the accepted W request ledger. Illegal full W span emits no new AR; new request/gen2/epoch2 full Wi recovery passes.

Preserved failures: AT017 bad response identity polluted the old ret tag, leaving W debt; fixed by locking the actual accepted request tag and returning only after actual payload copy. AT026 newly added TB watchdog K+1024 omitted external pause allowance and stopped at5120 while FC2's actual finite-stall completion is5170. AT028 corrects only that functional watchdog to2*K+1024; original normal performance gate and120s tool cap remain. Both failed receipts remain charged.

Unchanged component identities reused: AT003 exact signed pair/half-product/I32 leaves, AT005 full256dot II1, AT007 real dual A cache/64 reservations. AT008 overall OOC COST_STOP120.238844s; pair and half-product substages each1DSP/0blackboxes. AT009 isolated A bank PASS62.305528s,7BRAM36+2BRAM18,0DSP/URAM/blackboxes. No full-array or300MHz implementation conclusion.

Final audit verifies6 final runs each25 frozen sources/77 fixture files/33 snapshot files, plus unchanged component closures and real CPU0-3/nice19/idle policies. Main evidence: [current_version_evidence.json](runs/R001/current_version_evidence.json), per-attempt source_manifest.json/fixture_identity.json/command_rtl.json/guard_rtl/{guard_plan.json,driver.log,policy_checks.json}/receipt_rtl.json. Independent charged totals: reference3.221533/static98.779428/RTL545.147572/localOOC182.544372seconds; limits900/1800/2400/900. Budget path: runs/R001/budget_ledger.json.

This verifies declared-peer functional simulation of a local prequantized block. F32 quantizer integration, complete N/all120 matrices, full graph/global first-error equivalence, real HBM/CDC, joint resources/300MHz P&R and board/model throughput remain open. Authorized FULLN-04 continues separately in R002 with independent budget.


---
Published: 2026-10-21T04:20:54.838259+00:00
Publication: P21f986470b784644939a124a08717fb2
