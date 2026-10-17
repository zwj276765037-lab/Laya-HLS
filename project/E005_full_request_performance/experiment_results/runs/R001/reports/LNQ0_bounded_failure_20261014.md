# LNQ0 four-row union RTL: bounded failure at the LN publication check

M004/SM005/E005/R001; D-M004-LN-QAR-INTEGRATION-01; 2026-10-14. A002 engineering handoff to A001. Verdict: **AT047 full FAIL at a frozen testbench post-publication assertion**. The four-row LN prefix reached its real store and PUBLISH response; the shared Q, Wi, G, second Q and Down path was not entered. The one connection candidate and two reasoned correction rounds are exhausted under the current contract. No third correction or additional full was run.

## Reached boundary

AT047 static compiled/elaborated with `LNQ0_STATIC_PASS`. Its pilot used the correct fixture arguments and ran for the allowed 120 seconds, reaching the generated LN row-0 second arithmetic pass at cursor 896/cycle 24450 before the time guard stopped it. The pilot is a true LN prefix, not a combined-chain numerical test. The [pre-full cost decision](../attempts/AT047_LNQ0_chain_06/full_cost_decision.json) estimated 3464.200 seconds against the 3600-second limit using the measured prefix and a 2.5× allowance for unentered stages. Only one full was started.

The full raw log shows four real LN rows progress. Destination B for rows 0–3 occurred at cycles 45569, 86119, 126667 and 167215. The original generated completion packet finished at cycle 168789. The source stage then printed `LN_publish=1 last_B=4` at cycle 168898, immediately followed by:

```text
Fatal: LN publication missed real store/last B
File: .../AT047_LNQ0_chain_06/frozen_new/lnq0_chain_tb_v1.sv Line: 1721
```

Before setting `ln_published`, the frozen source stage checked monitor coverage before END response, physical 4 AR/256 R and 4 AW/256 W/4 B, 16384 written bytes, all 4096 LN F32 against the independent gold, its local NORM neighbor guard, and a successful PUBLISH response. The absence of an earlier Fatal and the reached publication line support **that executed prefix**. The full log does not contain the source-stage final PASS marker, external Q accept/AR, Wi/G/Down work or `LNQ0_CHAIN_PASS`; those remain untested in this union run. The raw last line is a testbench stop, not a DUT deadlock or an elapsed-time/resource stop.

## Why the assertion fails

The [frozen TB](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT047_LNQ0_chain_06/frozen_new/lnq0_chain_tb_v1.sv:1718) waits for `ln_published`, then requires `ln_source.monitor_coverage_complete`, B count 4 and `published_owners>0` in a single assertion. The original [store monitor](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_store_monitor_v1.sv:232) defines `coverage_complete = scope_active && ...`. PUBLISH occurs only after END closes that monitor scope; the [portal physical-observation rule](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_axi_portal_v1.sv:160) itself requires `!monitor_scope_active` for PUBLISH. Thus a live `monitor_coverage_complete` check **after** successful publication is false by design. The source stage had already checked this live signal while it was valid, before sending END. This is a specific testbench observation-time error. The combined assertion does not print the other two operands, so it does not independently measure `published_owners` at that edge.

The testbench failure is not grounds to certify the unentered chain. A future separately contracted correction should latch pre-END coverage or use the completed END/PUBLISH response and persistent published-owner state at the appropriate edge, preserving the underlying physical counter/gold checks. This report does not change the frozen TB or reinterpret the run as PASS.

## Attempts, identities and tool cost

AT042 host-bound identity guard passed. AT043 froze the current W binding package; AT044 short directed xsim passed `no_early_grant`, seven-beat held response, debt-fenced complete-key release and wrong-W-base zero-cache-valid cases. These are limited directed checks; they do not replace this long union run. AT045 union static passed; AT046 static passed, its first pilot failed immediately because the runner omitted `FIXTURE`, and its corrected pilot reached a true LN prefix before the 120-second limit. AT047 was the last reasoned revision: it added passive generated-loop cursor observation and corrected runner fixture arguments. Relative to AT046 the frozen union TB and adapter/bridge/W RTL hashes are unchanged.

AT047's [source manifest](../attempts/AT047_LNQ0_chain_06/source_manifest.json) contains 286 references over 285 unique paths; A002 rechecked every recorded byte count and SHA-256 with zero mismatches. Static/pilot/full guards ran serially. Their actual policy samples were 31/4/4, all CPU0–3, nice19, idle-I/O compliant. Static: 110.253319 s, peak 2978640 KiB, child 0/no trigger. Pilot: 120.368007 s, peak 1033164 KiB, child −9/timeout. Full: 723.247161 s, peak 1033732 KiB, child 0/no trigger, but **semantic FAIL** because the log contains Fatal. Child 0 is the wrapper/xsim exit, not the test verdict. Original guards, logs and previous failed attempts remain untouched. The [AT047 receipt](../attempts/AT047_LNQ0_chain_06/receipt.json) records these boundaries and hashes.

## Scope of handoff

The LN four-row independent prefix, AT044 directed admission/binding checks, AT040 separate LN→Q/fullA and AT035 separate Q→Wi→G→Q→Down retain their original limited evidence. They cannot be concatenated into a same-runtime LNQ0 PASS. Real union Q/NORM readback, live W load, Wi/G/Down gold, final combined DDR protection, all terminal leases and full cold-chain cycles remain **NOT_REACHED/UNKNOWN**. Production identity/registration, recovery, joint resource/physical timing, complete request, M003 and M004 remain open. A001 needs a new bounded decision if this union connection is to be resumed; the current correction/full allowance is spent.
