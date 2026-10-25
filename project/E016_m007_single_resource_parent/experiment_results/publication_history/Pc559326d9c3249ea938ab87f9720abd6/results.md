# E016/R005 actual partial results

execution_state: running
verdict: unassessed
applicability: original128-row CPU reference PASS; first3 native Wi/G blocks functional PASS on9544eff1. Current dc3e3969 build pending; fullFFN/Encoder/30layers NOT_RUN.

AT001–008 reference+AT009 merge PASS:128 unique rows,10496 G quant groups,335872 codes/131072 Down outputs; row0 and scalar/batch overlap PASS. Total reference8.056908318s, no arithmetic recomputed by merge.

AT018 normal prefix PASS80.520057882s/9063cycles:Wi24576 values, G12288 values,122880 FP/TANH nodes;A1 writes/ACK362, no premature A1 publication/parent success. AT016 snapshot revalidated by AT0170.307740991s exact source/log/snapshot binding; source/hierarchy control4038.875B.

Failures preserved:AT010–013 generator/compile-order errors;AT015 initial owner-switch blocked because parent masked real layer idle,COST_STOP120.349110275s/no numerical progress;AT016 compiled/elaborated successfully but final frozen audit ROOT failed,51.098572857s. Real safe-state route and audit path corrected without changing shared safety gates. No oldR003/R004 receipt or balance modified. Evidence: runs/R005/attempts/AT018_safe_workspace_three_block_pilot/receipt_rtl.json and guard_rtl/driver.log; runs/R005/attempts/AT017_corrected_audit_exact_AT016_snapshot/source_control_hierarchy_audit.json.

R003 original Attention PASS256947cycles remains frozen e354; R004 full128 COST_STOP remains its original boundary. No physical synthesis/P&R/board acceptance.

Current62cf04f5 AT021 same-build3block PASS79.973468s; each completeG eligible→release697cycles/firstoutput185. AT023 actual Wi RRESP failure/cancel/failedclose/discard/newgen PASS97.424434s: first G8192 values; exactly1 RRESP/cancel/failedclose/discard, held parent5; newrequest78/gen9/epoch10 reloadedA0=4096 and checkedWi8192/G4096/nodes40960/A1prefix106 without reset. AT0191.924760s lexical buildFAIL retained then AT020 fixed.

AT025 legacyQKV3 PASS57.139377s/8364cycles with8 identity rejects,24576QKV values,4096 input/Awrite/Aack,issueACK31/PSfeedback13. AT026 current same-build16block PASS331.471060s/22830cycles:Wi131072/G65536/nodes655360/A1write=ACK2026,no early publication/success. Full original launch bound3489.934307s with explicit Down cold/terminal allowances is within3600/reserve300; full NOT_RUN while the agreed A008 LN short-test window is prepared.


---
Published: 2026-10-23T02:22:38.908852+00:00
Publication: P264ec1c3a0dc46fe9e3b74f730d46f0a
