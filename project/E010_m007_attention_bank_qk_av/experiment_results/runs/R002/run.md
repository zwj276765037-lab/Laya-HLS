# R002 — E010 strict softmax/head continuation

Execution state: running; Verdict: local components supported, integrated softmax/head NOT_RUN. Authority SM011 D-M007-SM011-SOFTMAX-02. A007 owns attention_and_fp_engine andE010; A010 onlyreads sharedFP/storage interfaces.

Actual runs use m011_softmax_run.py under CPU0–3/nice19/idle and m007_heavy.lock; each fresh AT preserves source_manifest, command, guard_result/driver.log and receipt. Actual cost caps and all success/failure receipts: budget_ledger.json.

Independent reference: AT005 frozen full_reference.py/libm/original real fixture. Generated strict EXP dependency reuse: E002 module rtl/strict_exp_ii1_167/ORIGIN.json andoriginal E007 AT003/006 manifests. New target xcu55c-fsvh2892-2L-e/3.333333333ns. No new OOC/P&R/timing or board result.

AT001 measured63cycle sum dependency FAIL; AT002 actual phase3 return bypass56PASS. AT004 held/mixed/reset/phase1-9cycle PASS. AT006 all32847EXP1lane167/II1 PASS. AT007 firstEXP8 handshakeFAIL preserved; AT008 fix8lane168/II1 allwords+hold/invalid/reset PASS. Softmax/head/Decision/TANH remain incomplete.
