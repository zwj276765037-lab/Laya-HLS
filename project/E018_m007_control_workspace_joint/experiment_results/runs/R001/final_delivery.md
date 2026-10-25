# CONTROL-ARENA-16 / E018 R001 engineering delivery

execution_state: completed
verdict: supported for the bounded shared-control component and current full normal G

One actual packed12288-bit FF workspace now serves layer QKV/context-consumption coverage and G math's full11343-bit control view. New owner_g/rearm state is2 FF. The declared combined account is4036B, leaving60B; no extra glue FF or identity copy is introduced. This is a source declaration account and functional elaboration, not physical fit.

The version1 field offsets follow AT133 census entries flattened low-to-high; context/order entries remain at that census's tail. The current source declares context earlier, so this schema is explicitly not sorted by source line number. See [layout](../../../experiment_source/g_control_layout_v1.json) and [final source audit](attempts/AT032_final_source_and_private_ff_census/work/report.json). Default/local and external modes share the same next algorithm:102 control NBA old-RHS/assignment-order checks,12 numeric NBA checks, 91 layer private NBA checks and byte-identical G engine private FF algorithm.

AT024 actual combined runtime passes335872 original outputs/3358720 node checks in127.30650611896999 guarded seconds. Its full metrics exactly equal accepted original AT146: first185, full done42171, max block697, read/output gap1,20992 real native writes/ACKs,41984 reads,82 slot releases,81 independent releases while the other slot has real work. Original independent AT058 fixture is unchanged; no new gold. [Full report](attempts/AT024_current_full_normal_handoff/work/report.json).

Actual layer PREP commits9 native QKV writes/7 unique bits including boundaries0/4095/4096/12287 and duplicates, rejects new-PREP/switch races, holds cancel response17 cycles, then cancels/returns idle before A to G with one disabled REARM cycle. It launches no Attention arithmetic. After full G, actual done held17/consumed and actual resource retirement precede G to A, one rearm, a new prepare and two boundary coverage reloads.

External G ring AT014 passes1280 same-address full consume+accept replacements,51 held cycles and original255/256/511/512 boundaries. AT018-022 preserve all five old-generation/epoch/reserved/full-seq/extra-FP counterexamples and actual debt, held done17, discard and no-reset newgen12288-result recovery. AT031 matching status8 peer fault passes with actual partial debt drain/discard/newgen. AT029 default local mode passes the original7 input-domain/clear cases,6 rejects,7 vectors/56 outputs/560 nodes.

AT027 queries the actual compiled snapshot: one workspace/state_q object, two q aliases, no layer/math local_state branch or private state_q object. Pure-alias external_state scopes are optimized away; AT026's invalid scope-presence assumption is retained as a measurement-script failure. [Actual hierarchy](attempts/AT027_actual_hierarchy_q_objects/work/report.json).

AT034 release audit passes 33 prior terminal attempts/33 source archives, source/build/fixture/snapshot identities, exact baseline normal metrics, retained failures, actual policy observations and cleanup. Its own terminal receipt is included in the final ledger: 34 terminal receipts, statuses {'EXIT_ZERO': 26, 'FAIL': 7, 'INFRASTRUCTURE_FAILURE': 1}. [Audit](attempts/AT034_final_release_audit/work/report.json), [exact final budget](final_budget.json). Guarded seconds reference/static/RTL/OOC: 0 / 156.18457552196923682 / 295.3810289390967186 / 0, caps0/600/1800/0. All owned cleanup receipts are empty.

No normal16head context-release to G handoff, full FFN/Encoder/30layer, synthesis/physical fit/DSP896/300MHz/P&R/board claim. The frozen independent A010 Attention parent PASS keeps its old source identity. Current full numerical-error rank cases were not rerun; older E015 rank results remain version-specific. Desired model/effort gpt-6.1-sol/xhigh; actual unverified. A007 /root/m007_strict_fp_engineering is finished with no queued EDA.
