# E016/R001：唯一资源父级集成

权威合同：[SM012](../../../mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md)，决定 D-M007-SM012-SINGLE-PARENT-11；详细接口：[source](../../../source/m007_single_resource_qkv_attention_wo_20261021.md)。

A010在E012/R004实际出口后接续，工程实现维护本protocol补实际运行映射；主控只下达范围不登记已运行。独立reference180/static1800/RTL3600/OOC0s，恢复保留240s，未知pilot120s/后续RTL1200s、真实停滞120s；原统一资源限制与独立数值参考全部保持。


## Actual E016 mapping and run guards (2026-10-22)

Production files are forward_controller/rtl/laya_m007_single_parent_v1.sv and laya_m007_context_quant_adapter_v1.sv. compose_parent.py owns their mechanical port composition; tensor_catalog.json derives compact tensor ordinal+1 from the exact original model manifest. Full original model/numeric/table/graph/layout/build source identities are compared before layer prepare; current W576/RTL build identity is recorded separately. Pure layer/resource sources stay A007-owned and are selected by explicit SHA.

The sole resources shell is484f9457… with9 real DIV export outputs. Matrix phase1 FP/PS routing never masks layer public QKV writes; context/public storage remains phase4 while pure quant/A uses DIV phase5. The pure facade/front and actual context consumer are shared across stages; no compatibility resource shell or full context copy enters the production hierarchy. New sequential control1561bits/196B plus conservative3550B prior account=3746B.452 leaf/interface input sources are audited (444 explicit assignment statements and8 direct cache response drivers), separately from actual xsim hierarchy inspection.

AT003 actual hierarchy has91923 scopes and exactly one of each required physical service. AT004 oldcatalog QKV3 is narrow historical evidence; AT005/006 bind actual catalog and check8 zero-work identity/tensor errors with actual243bit parent responses held5cycles, followed noreset QKV3.

AT008 verifies dedicated m007_parent_guard_v1.py SHA76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b using scaled2s synthetic stall, duplicate-check-count plus log/file growth, and real checked-count progress. Production RTL stall stays120s; RTL artifact progress is forbidden and generic log lines do not refresh progress. Static compile logs are explicitly not numerical progress. The production TB only emits M007_PARENT_CHECKED after successful actual accepted data comparison; its global checked counter never resets between requests. All long RTL uses this guard with artifact_progress_root=null.

AT011 source-audit/compile passes after preserved AT009 TB declaration-order failure; AT012 current same-build/observer strict-guard QKV3 passes with155648 actual checked words. AT013 is the one admitted completeQKV→first-complete-head boundary, not complete parent/16head/WO. Cost is max(current same-build pilot wall/cycles, prior complete-QKV checker floor, prior whole-head wall/headcycles floor)*71168*1.35+10=938.280031856s;1200s cap and240s reserve from3448.240771428s remaining. Those prior component costs are conservative budget inputs, not same-runtime parent functional proof; full16head/WO may only use actual current-combination full-stage samples afterward.


## Source-address trust and cost-exit limitations

The original catalog validates kind/layer→two compact tensor keys and bias identity. cmd_base/span remains an address descriptor supplied by the trusted fixture/future Host registration; the RTL checks alignment, complete spans and overflow, and cannot infer a GGUF tensor SHA by reading an arbitrary valid address. Current actual peers freeze each complete packed port file and source tensor SHA; passive W/prebias/final-QKV checks establish the selected original bytes for these runs. There is no implemented generic Host/HBM registration service or proof that arbitrary caller-provided BO addresses are the declared layer. That external trust boundary remains explicit.

AT013 actual head0 terminal evidence is h_done_valid&&h_done_ready and the asserted QKV/RoPE/score/prob/context/PS ack/cycle counts. Its fixed unfinished_parent print is not a separate dynamic no-early-success assertion; normal done_valid was not asserted zero every cycle in this long TB. max_checked is not required by the terminal assertion, so no independent maximum-comparison-count claim is made. The raw wall-event started_at field was written near exit and is misnamed; original file stays immutable, monotonic elapsed values/event differences remain the only stage cost source. Future runtime script records start/end UTC separately.

AT013 phase wall head0=119.898432351s. Even assigning zero to the additional WO/context cost,1.35*(782.969087822+15*119.898432351)+10=3494.951523668s exceeds the1200s cap and remaining-after240s reserve2425.271683606. The full16head/WO gate is COST_STOP/NOT_RUN, not a numerical refutation. No child/attempt was created for that closed gate. Continue same-DUT bounded fault/recovery and local production-consumer coverage.

## Final bounded boundary and exact version interpretation

AT015/16/17 retain old parent SHA c29e9376dcaa29c45738c4576886376686b6a0fda5259af4fe1171e2d5632a22. Current parent SHA e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8 differs only in q_producer_close_success context-fault gating (CRUN only). AT022 current source compile/control/hierarchy and AT023 actual active common-reset/new-generation full-input/QKV3 sign the new SHA in that limited scope. Actual previous layer-context fault→next-generation parent recovery is NOT_RUN; the source fix is not declared fully exercised merely because the short reset case passed.

AT021 actual production adapter/quant-A/physical-A/DIV consumer uses original full128 context fixture from E012/R004 AT005. It tests partial debt cancellation, malformed public response tag and4096-group no-reset recovery with the final actual peer response held12 clocks. The peer never fabricates layer16/DONE or parent success. AT019 failure is preserved; AT020 corrects only the observer that rejected legal idle sticky fault. Active unexpected faults remain fatal; all independent references are unchanged.

AT023 intentionally common-resets the production resource fabric and functional transport peer. A generic inherited M007_PARENT_RECOVERY_PASS line says kind=quant/no_reset=1; the actual case includes the documented3-cycle common reset. No-reset claims apply to AT015–17 and AT021, not to the whole AT023 scenario. Physical HBM reset/late external transactions remain NOT_RUN.

AT024 checks3032 files/3764 conditions, retaining20 runtime changes of xsim_script.tcl/xsimkernel.log separately from immutable compiled objects. Audit charge is closed by the outer receipt after the child completes, then independently reconciled in ledger_reconciliation.json. Final delivery_manifest seals audit artifacts, summaries and version boundaries; neither audit nor manifest is a new numerical simulation. Future work must preserve old/new parent boundaries and all FAIL/NOT_RUN charges.
