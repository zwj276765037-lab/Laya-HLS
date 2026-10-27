# A010 当前交付：D38同DCP一次优化诊断完成

execution_state: completed

候选仍不通过资源和所测setup：LUT2139515→2091399（仅降2.248921%，器件160.42%）；global/fixed同为n_reg[1]/C→error_col_reg[0]/CE，6091→6090级，slack -1289.339→-1289.374ns。完整190017位port名字/方向与全部RTL声明完全匹配，before/after/复开port-clock-XDC字节相等，原/候选DCP SHA不变。唯一opt实际仅1次；原DCP、候选493065634B及全部失败/费用原件保留。

AT023/024执行PASS、源码与清理核验通过。两个pre-opt身份API脚本FAIL未调用opt，费用889.716781782s保留；本诊断总guard3905.865755951s，不双计子命令/历史恢复。所有owned工具/guard/serial已退出，锁释放，无自动facade/全父/place/route。完整top物理任务因core容量门阻塞，300MHz最终P&R/完整timing/板卡未验收；交主控集中架构/映射判断后再定义后继。计时器未由A010改动。

主结果：project/E022_m007_full_top_physical/experiment_results/summary.md。最终机读证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_engineering_receipt.json 与 core_opt_diagnostic_final_state.json。原始候选路径报告在AT024/reports；实际警告HD.CLK_SRC未设、-of_objects忽略-input_pins已保留，未重跑无关功能/综合。

---

以下为历史交付与阶段记录，旧running/待执行描述不代表当前状态。

# A010 当前阶段交付

E012/R004保持冻结：原context文件WO131072值/22129拍，AT025审核1981文件；见[冻结交付](../../project/E012_m007_matrix_compute/experiment_results/runs/R004/final_delivery.md)。

E016/R001有界阶段已完成；完整parent仍未验收。旧parent AT013完整QKV/RoPE→首head通过；AT015–17三类真实故障/PREPcancel/无reset新gen QKV3通过。当前parent一行context-fault相位修复后，AT022/23真实编译/活跃共同reset/系数重装/新gen全输入QKV3通过。AT021独立实际consumer4096组通过，不替代实际layer16→parent→WO。

AT024证据审计3032文件/3764检查通过；完整16head/WO成本3494.951524s>1200s cap，COST_STOP/NOT_RUN。新增控制1561bit/196B，总保守3746B。费用与旧/新版精确边界见[最终交付](../../project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)和[版本证据](../../project/E016_m007_single_resource_parent/experiment_results/runs/R001/current_version_evidence.json)。

无owned实验进程；交主控集中审核。期望gpt-6.1-sol/xhigh，实际UNKNOWN；无物理/整链/30layer/板上通过结论。

E016/R002也已完成：仅debug typical/off选项差的同源原QKV3均通过，计数/8364拍相同；实际wall48.806138473/54.403592327s，off本次慢11.468750%，无改善，按合同结束。审计634文件/3616检查，另R001原artifact3032文件全部未变；新预算费用static103.841320947/RTL103.209730800s，无旧余额转移。见[R002最终交付](../../project/E016_m007_single_resource_parent/experiment_results/runs/R002/final_delivery.md)。无owned子进程，无其它旗标/16head放行。

E016/R003：原Encoder0完整Attention父链AT007 PASS，wall2828.967579680s；QKV393216、16head、真实context4096→同quant/A、WO131072，独立243bit成功保持/退休均实测。独立费用static94.410942169/RTL3761.918036500s，原预算不转。见[最终交付](../../project/E016_m007_single_resource_parent/experiment_results/runs/R003/final_delivery.md)。不是完整Encoder/30层或物理部署。


E016/R005 complete FFN and679check audit are frozen; see [final delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R005/final_delivery.json). Current E016/R006 parent-v2 builds/control32519bits, publicH/error prefix and QKV3/24576values pass only their bounded scope. Old capture binary invalid, current observer source fixed and independent synthetic AT009/AT011 seven-case validation PASS; parent rebuild pending; no active/queued A010 guard. See [R006 evidence](../../project/E016_m007_single_resource_parent/experiment_results/runs/R006/current_version_evidence.json) and current experiment summaries.


E016/R006 AT012/AT013 same-AT006 kind3 PACKED1/0 each hit the original120s cap. Only actual common Wi3/G2 math milestones/cycles and their wall costs are compared; no FFN3 PASS or packed speedup. Both guards5/5 policy, actual owned cleanup empty; tool window explicitly handed to A007 D27. Next current parent source closure will combine verified CE and fixed observer after actual owner delivery.


Current E016/R006 AT014/015 new D27-auto0 parent build and243check actual32519bit census PASS. AT016/QKV1 and AT017/WiG1 exact original math prefixes PASS46.544751830/68.562290498s. Fixed real input serialization4096groups passed; actual final output0/complete=false. Whole-kind4 E not established; no long test queued. All owned cleanup empty; window explicitly handed to A008 D31. [Current cost/evidence](../../project/E016_m007_single_resource_parent/experiment_results/runs/R006/new_CE_minimum_pilot_costs.json).


E016/R007 §17 standalone120tensor binary peer delivered: AT038 build12.064388511s /AT039 RTL6.023939148s PASS,2897AR/23049beats/1475136B against originalGGUF, finite holds/multiple IDs/different tensor overlap. [Actual evidence](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/binary_peer_actual_evidence.json). No A010 heavy tool; A012 window first. Controller continuation is source integration into complete checker and bounded current W-reader/cache actual retirement; whole Encoder/kind7 remains NOT_RUN.


E016/R007 current staged delivery AT038–044: all120 original-binary peer and current production W reader/cache parser-retirement unit PASS; pure1D compatibility full build PASS but60s QKV1 COST_STOP, no completeQKV block. Truekind6/7 checker and all47 original SHA/byte binding frozen source-only, not compiled/run. [Stage delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/AT038_044_staged_delivery.json). No A010 active/queued heavy tool; precise source/window handed to A012. Overall Encoder/kind7 goal remains unachieved and costUNKNOWN.


Fullgraph public-boundary source revision2 delivered: source677e5bc9, fixed original out_row mapping and accepted tail identity checks/latches only; old prepared sources/metadata and production/gold unchanged. [Source-only diff](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/fullgraph_public_boundary_v2_delivery.json). No EDA.


Residual loader fix delivered: same-top current1D172d3019 and binary-kind5246c2d6a pack all131072 original scalar lanes correctly; independent AT045524288B equals original attention_residual.bin, no gold/production/assertion/delay edits. [Exact sources/diffs/proof](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/residual_loader_repair_delivery.json). A012 owns actual EDA validation; no A010 tool queued.


E016/R007 AT047/048 read-only compatibility stage completed:15 exact one-dimensional readmemh targets and inspected byte FREAD/FWRITE runtime mapping; exactly3 SIDEEFFECT+2 MODDUP generated/source audit found no concrete result-changing risk in that scope. Two unused service bodies differ; bank bodies match. Other513warnings unassessed. [Compatibility delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/readonly_compatibility_delivery.json).

AT050 source-only crash review completed:1D172d3019 has no fork/disable/named event/#0; original EXP leaf168sequential#0 maps to1344 actual generated calls over8lanes, with synchronous-reset same-value coverage. AT049 lexer diagnostic-string false positive remains preserved. A012 reported a same-source small runtime crash reproduction and owns runtime repair; A010 did not execute it or modify production/TB. [Exact source delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/zero_delay_source_delivery.json). No A010 active/queued EDA; whole Encoder/kind7 remains unverified.


Current context-credit repair is handed off:1D505e0b93/binary8a4a3956, exact inverse observer-order swap restores prior172d/246c; original predicates/data/gold/production preserved. AT051 static protocol trace4096/4096,2633legal replacements,10negative cases rejected; no A010 EDA. [Repair](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/context_credit_observer_repair_delivery.json). Fullgraph source677e5bc9 unchanged; initialH→firstfinalH checked-progress gap and minimal observation-only proposal/source handoff delivered [here](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/fullgraph_progress_source_handoff.json). Actual corrected Encoder runtime belongs to A012.


Fullgraph same-top retirement observer8b556ca2 delivered source-only:7real result/ACK domains, global monotonic event counter, exact newmarker every128new events, no event/no increment/print; original checked/checker/stimulus unchanged and inverse delta reconstructs677e5bc9. AT052 static audit onlyPASS;505e/8a4a/peer/production unchanged. [Delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/fullgraph_retire_progress_delivery.json). No A010 EDA; A012 future fullgraph guard/build/run remains separate.


Latest cross-experiment validation: A012 E021/R001/AT034_context_credit_v3 completed original Encoder0 kind5 packed0 allSTOP0 using frozen1D505e0b93, normal exit0,427305cycles,4matrices/16heads/2residuals/LN/G/final131072. Actual accepted524288B output equals original encoder_00_out SHA9d1c8d61…e55b. This validates the current1D observer/residual-loader repairs; binary8a4a and fullgraph8b55/kind7/30layers remain separate. [Exact provenance](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/encoder0_E021_AT034_cross_validation.json). No new A010 experiment or R007 charge. Parent/W/TB ownership retained; only exact A012 compatibility or ordinary-fix requests within D32 remaining scope, no active/queued heavy tool.


D32 peer compatibility successorf4d1c00d delivered for A012 D34 actual BLKLOOPINIT: only main posedge loop0/1/2/3 expanded in same process,8NBA/port and all statement/counter/AR/R order preserved; inverse restores4d92. AT053 static proofPASS0.064990415s; no A010HDL/RTL. Frozen94source manifest replaces onlypeer,8b55/production/gold/ROM unchanged. [Source stage](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/binary_peer_posedge_unroll_stage_evidence.json). Old2897request/23049word short byte regression preparedNOT_RUN awaiting A012 explicit40swindow, no lock queue.


AT054 actual newf4d original120tensor/4port byte regressionPASS: build5.418817962s/RTL5.610245347s,2897requests/23049words/1475136B/7048cycles; all361semantic lines equalAT039. Original fixture unchanged/no gold generation. Policy7/7+4/4, allownedidentities/groups empty;11.179084337s explicitA012window completed/lock handed back. [Actual evidence](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/binary_peer_posedge_unroll_actual_evidence.json). No A010kind7/30layer result.


Standalonefixture review1996B completed; old8b55kind6BEGIN violated reservedfields ABI. New86629840successor conditionally retains exact kind7fields and zeroeskind6qtype/allrows/mask/count only. AT055boundedstaticPASS0.242143059s,inverseexact8b55;94closure onlytopchanged/93others+ROM/peerf4dunchanged;currentAT005snapshot untouched. [Delivery](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/fullgraph_kind6_public_abi_v4_delivery.json). No A010EDA/RTL/lockrequest;actualkind6notrun.


D36 source rev2 delivered to root/A012: parent gamma hold across N_START/N_RUN, default0 saved-actual-H verification entry, exact original gold checks and actual final-LN/type captures. Rev1 retained; rev2 fixes missing diagnostic end separator and packed lane selection. [Current manifest](../../project/E016_m007_single_resource_parent/experiment_results/runs/R007/d36_final_gamma_suffix_source/rev2/fixed_source_manifest.json). A010 source-only checks PASS; no A010 HDL/RTL or shared heavy lock use. A012 actual D36 validation is complete: old AT003 gamma0 data FAIL reproduced (8.316856 s), fixed AT005 prefix PASS (35.940923 s), and AT006 complete same-runtime SEGMENTED_SUFFIX PASS (710.202771 s/900800 cycles), 2 Decision/8 matrices/32 heads/5 LN/5 VECTOR/544 groups and real tail/DONE/idle. All four full-size endpoints match 131072 original F32 words each. [Actual receipt](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R004/attempts/AT006_fixed_complete_suffix/receipt_rtl.json). No repaired whole once-BEGIN30 or end-to-end performance claim. D36 complete; subsequent work paused, no follow-on task or A010 tool. Desired gpt-6.1-sol/xhigh, actual UNKNOWN.


D37 documentation-only closeout: unchanged parent9d877217/TB2bd73c51 passed A012 E021/R005 AT002 complete original30 once-BEGIN normal path (parameter0/original initial_H),10101.230974940 s/13036119 cycles,30 layers/120 matrices/480 heads/60 LN/61 VECTOR/28 GEGLU/544 outputs,real tail_commit/heldDONE/idle/rc0. Root independently checked all30 H/traces and finalLN/type. [Actual receipt](../../project/E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/receipt_rtl.json). D35 FAIL/D36 suffix identities preserved; no physical/board/exhaustive abnormal-path claim. A010 changed only existing documentation/summary/status records and is paused, with no further implementation or experiment task.


D38 restored physical-stage work: complete91-source/ROM/11-parent-generic identity frozen in E022/R001; actual Vivado2025.2/U55C/license preflight succeeded. Full-top AT002 invalid-scope126.709650s and correctly configured AT003709.993410s both stopped at24GiB with no complete DCP; raw failures/costs retained,no hardware fit verdict. Source-identical serial natural-partition flow is active at AT005 matrix core PROFILE0/flatnone; full-kernel acceptance requires actual final DCP integration,strict interfaces/parameters,zero blackboxes and complete internal/cross-partition timing. [Current status](../../project/E022_m007_full_top_physical/experiment_status/summary.md). No RTL/TB/numerical change or D37 rerun; A010 running only this D38 scope.


D38 AT005 COST_STOP retained. Authorized minimal operand representation repair completed; actual-source XSim AT009/010 PASS(6721cycles/13442full-pool checks), new matrix SHAe279968c... and full source manifest_v2,90others/ROM/parent unchanged. Current AT011 core OOC running; complete top fit/timing still UNKNOWN/NOT_RUN. New D37 full30 rerun NOT_RUN. Desired gpt-6.1-sol/xhigh, actual UNKNOWN.


D38 latest operand representation proof: AT012 static9.696188813s and AT013 XSim4state RTL8.653027590s PASS,6721cycles/13442fullpool comparisons. Same original/latest actual extracted blocks; known64slot domain and exact source inverse, not exhaustive values or full-core waveform regression. Prior e279 AT011 was actively replanned at1736.656508570s/peak16777212KiB withCPU progressing,no swap,no guard cap; sourcechecktrue/ownedempty. Original raw COST_STOP/requested_stop and explicit CONTROLLED_REPLAN_STOP classification retained. AT014 f8493b... core OOC is currently running, with remaining synthesis5558.397858556s; final resources/DCP/implementation/timing remain UNKNOWN/NOT_RUN. Evidence E022/R001/repair_v2 and attempts/AT011–014; no new full30 rerun.


Latest AT014 outcome: actual24GiB RSS COST_STOP1278.032619354s,receipt peak25454276KiB,source_verify_after=true,ownedempty and independent7PID/start auditempty;1transient policyUNKNOWN. Initial mainRSS24909352KiB and stopped-snapshot24915024KiB are distinct actual samples;helper529332KiB. Op0/op1 3D warnings removed,aligned32768 warning remains. Actual log has engine-module-done marker but no completeRTL-elaboration/synth_design/DCP. Prior tail-only no-engine-done statement was too broad and is corrected. No final mapped resource or device-fit/numerical conclusion.

Latest f8493b original-source local equivalence PASS remains; new full30 NOT_RUN. Complete hierarchical linkage/resources/implementation/internal300MHz timing NOT_RUN. Synthesisspent4719.634760798s/rem4280.365239202s,all original budget retained,no reset/final sealing. Current stagewaiting_review,no heavy tool/automatic retry or new source change;central controller/A014 determines evidence-based bounded next scope. See E022/R001/physical_blocker_result.json and AT014 raw receipts/snapshots.


## Latest explicit user budget increase / AT015 same-source restart

User gave more budget after clarification that24GiB was a project guard,not host exhaustion. Latest SM012/AGENTS supersede prior physical caps and PS prerequisite: cumulative preparation1200/repair_static600/repair_rtl600/synthesis43200/implementation86400/reports3600s,total135600s,all old charges retained. Physical synthesis/link/implementation/reports RSS128GiB; repairstatic24/RTL8 unchanged. Synthesis/link single21600s,opt/phys_opt14400s,place/route43200s,all bounded by actual cumulative remainder. Same192GiB available/CPU0–3/nice19/idle/singleheavylock/synthesis1worker and300s noCPU AND noactual log/checkpoint stall. Old24GiB and old wall limits no longer stop new physical attempts.

PS candidate7c292 remains unexecuted/unapplied; no PS tool attempts were launched before user pause, source files retained. Productionf849/source_manifest_v3/bottom_up_v6/parent/ROM/11generics/XDC unchanged. Expanded-budget AST/imported actualguard/source check PASS. AT015 NEW actual core launchUTC11:41:33.922608 PID3088949/start61814704 with128GiB and21600s; prior cumulative synthesis4719.634760798s preserved,launch remainder38480.365239202s. No old DCP exists so this restarts,not resumes. Complete resource/implementation/timing remain pending; automatic source-bound real assembly and physical stages follow actual core success.


D38 AT015256GiB supervision active2026-10-25T14:06:12.169726UTC,without Vivado restart. Original128GiB guard remains single-PIDpaused holding parent/subreaper/lock;monitor3210585/watchdog3210588 enforce256GiB and original21600s deadline with192GiB host guard. Three real small-process supervisor testsPASS;not hardware evidence. See[E022256handoff](../../project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT015_core_synth/rss256_handoff/activation.json). Current samples moved to rss256_handoff/live_status.json;futurephysicalrunner256,repair24/8unchanged. Core DCP/full resources/timing still pending,samef849production source.


## D38 AT015 actual terminal outcome (2026-10-25UTC / 26Beijing)

Original21600s wallcap reached during synthesisTimingOptimization;effectiveCOST_STOP,actualelapsed21601.398908304s includingcleanup,combinedpeak116367224KiB(110.976433GiB),minimumMemAvailable360390140KiB(343.694820GiB),CPUadvancing. NoRSS/hostmemory/stall trigger and noDCP. OriginalreceiptFAIL/-9 remains literal;external and verifiedcombined receipts bind the deadlinecause,not a numerical/fit failure. Source_verify_after=true;11knownowned and all supervisorPIDs absent,lockreleased;10recordedpoliciesmatch,1transient3089334/start61816017UNKNOWN. Observerexited0via deadline-return branch withzeroactiveowned,no workloadterminated byobserver. Actualsynthesis spent26321.033669102s/rem16878.966330898s;all oldcharges and originalverdict preserved,RSS256revision appendedonlyafteroriginalfinalledgerwrite.

Currentf849/source_manifest_v3/bottom_up_v6/parent/ROM/11generics/XDC unchanged;PS candidatepaused/unapplied/unexecuted. Complete resources/devicefit/P&R/internal300MHz NOT_RUN/UNKNOWN. No automaticrepeat or newsourcechange;controller/A014集中审核后继范围. Evidence:E022/R001/physical_blocker_AT015.json,AT015/post_run_audit.json and AT015/rss256_handoff/effective_receipt_verified.json.


## Authorizedstrategy-v7/AT019 newcore (2026-10-25UTC/26Beijing)

LocalnativeAT018 synth_design-help PASS confirms-no_timing_driven;AT016/017 queryscript failuresremainchargedonlytopreparation. Newv7 config/flow adds only thatcoreoption;allf84991sources/ROM/stubs/part/PROFILE0/flatnone/oneworker/11parentgeneric/original300MHzXDCunchanged. NoPSapplicationorfunctionalrerun. ActualAT019 launch2026-10-25T23:27:54.983905+00:00,leader3583000/start66052093,guard3582995/start66052065,session13521,max16878.966330897878s/256GiB;conservativedeadline2026-10-26T04:09:13.948482+00:00. This is newfromscratch,nocheckpointresume. ActualTclargv savedbeforeexecution. SuccessrequiresrealDCP+report_core andcompleteactualhierarchylink/resources/P&R/STA;no_timing_drivensynthesisdoesnotprovefinal300MHz. No budgetincreaseorlowercap;oldcosts/AT015receiptsretained. Seeinput/strategy_v7_relation.json,no_timing_driven_support.json andAT019/strategy_launch_evidence.json.


### AT019 无墙钟监督实际生效（2026-10-26 北京时间）

用户最新明确要求取消物理阶段时间上限并每两小时汇报。synthesis/implementation/reports 的单次和累计墙钟均以 null/disabled 表达，不使用极大数字；preparation/repair 原帽保持。历史 command、冻结代码、费用和原收据不回写。物理 owned RSS 256 GiB、MemAvailable>192 GiB、CPU0–3、nice19、idle IO、综合单 worker、单重工具锁和 300 s 实际 CPU/日志/checkpoint 停滞保护不变。

实际 activation UTC 2026-10-25T23:44:46.737830：原 Vivado3583093/start66052106 未重启，原 guard3582995/start66052065 单 PID 暂停保留父/锁；外部 monitor3595603/start66153245、watchdog3595604/start66153251、observer3595805/start66154913 已核。当前 live 为 R001/attempts/AT019_core_synth/unlimited_wall_handoff/live_status.json；原 at/live_status 是历史，不误读为停滞。10/10真实小进程监督测试（AT019_unlimited_guard_tests_v2/test_result.json）PASS；仅证明基础设施。证据 activation_verified.json 确认源码/原command/冻结运行字节身份未变。最终原 receipt 与有效合并 receipt 分开保存并保留实际全部费用。旧缓存清理根证据通过 cache_cleanup_controller_reference.json 绑定，AT019不受影响。


为连续执行既定物理流程，轻量串行 continuation 已实际启动：PID3603650/start66216629、session84409，当前仅等待同 AT019，attempt 数仍19。它核真实有效 core PASS、原收据 SHA、DCP/identity、owned/监督清理和锁释放后按原13阶段各执行一次；不启动或重跑 core。每阶段实际 launch/receipt 写入 serial_continuation/events.jsonl/state.json 并发布摘要；遇真实失败停止。该等待器不占等待期重工具锁，不改变两小时汇报配置，工具执行完成仍需工程核资源与时序后才验收。


AT019实际阶段更新 2026-10-26T00:47:37.439047+00:00：RTL Elaboration工具00:33:32、Opt1 00:33:38、Opt2 01:17:00完成，原日志L281/L290/L327。仍无core DCP或最终资源/时序；无deadline监督与原Vivado3583093/start66052106保持。证据 R001/attempts/AT019_core_synth/stage_observation_rtl_phase2.json。


AT019 阶段观察 2026-10-26T01:34:21.040625+00:00：实际 vivado.log L443 出现 Start Cross Boundary and Area Optimization；此前 Elaboration/Opt1/Opt2 完成，当前仍无 core DCP/最终资源。原 Vivado 与无 deadline 监督保持，证据 R001/attempts/AT019_core_synth/stage_observation_cross_boundary_start.json。


## AT019 实际 Cross Boundary/Area 完成与初步映射报告（2026-10-26T02:41:07.521383+00:00）

工具日志 L2377：Cross Boundary and Area Optimization 完成，elapsed03:10:40；L3159：ROM/RAM/DSP/Shift Register/Retiming Reporting 完成。采样 2026-10-26T02:41:06.484852+00:00：elapsed 11591.502723 s，owned RSS 111.013592 GiB，MemAvailable 367.184937 GiB，CPU ticks 1637496，trigger None。综合仍运行且无 core DCP/最终收据；DSP表明确为 preliminary，不能据此给最终资源或完整fit/时序结论。身份、保护及已有串行continuation保持，未重试。证据：`project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_mapping_report.json`。


AT019 阶段观察 2026-10-26T02:45:07.178826+00:00：实际 vivado.log L3162 出现 Start Timing Optimization；实际argv含 -no_timing_driven。官方本机帮助禁用默认timing-driven算法，未承诺省略该标题；不据此判断内部步骤、参数失效或ETA。仍无core DCP/最终收据，继续同一Vivado及原保护。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_timing_optimization_start.json`。


AT019 阶段观察 2026-10-26T02:49:28.163766+00:00：原日志L3165 Finished Timing Optimization（工具elapsed03:19:51），L3168 Start Technology Mapping。采样 2026-10-26T02:49:27.109466+00:00：elapsed 12092.127328 s，owned RSS 111.176060 GiB，MemAvailable 337.534698 GiB，CPU ticks 1697366，trigger null。仍无core DCP/最终资源/最终收据；保留实际-no_timing_driven策略与原进程、保护及串行后续。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_technology_mapping_start.json`。


AT019 阶段观察 2026-10-26T03:52:31.539825+00:00：原日志L3171 Finished Technology Mapping（工具elapsed04:23:04），L3174 Start IO Insertion。采样 2026-10-26T03:52:31.285251+00:00：elapsed 15876.303116 s，owned RSS 172.027695 GiB，MemAvailable 297.704132 GiB，CPU ticks 2381155，trigger null。仍无core DCP/最终资源/最终收据；原进程、保护及已有串行后续保持。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_io_insertion_start.json`。


AT019 阶段观察 2026-10-26T03:53:32.075788+00:00：原日志L3177 Start Final Netlist Cleanup，继Technology Mapping04:23:04完成及IO Insertion后实际推进。尚无core DCP/最终收据。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_final_netlist_cleanup_start.json`。


AT019 阶段观察 2026-10-26T04:01:29.996114+00:00：L3180完成Final Netlist Cleanup，L3183完成IO Insertion（工具elapsed04:31:56），L3186开始Renaming Generated Instances。采样 2026-10-26T04:01:29.646343+00:00：elapsed 16414.664212s，owned RSS 171.965183GiB，MemAvailable 292.461010GiB，CPU ticks 2444698，trigger null。仍无core DCP/最终收据。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_generated_instance_renaming.json`。


AT019 阶段观察 2026-10-26T04:54:48.012160+00:00：L3189完成Renaming Generated Instances（工具elapsed05:25:09）。采样 2026-10-26T04:54:47.192404+00:00：elapsed 19612.210274s，owned RSS 165.403782GiB，MemAvailable 310.899769GiB，CPU ticks 2822328，trigger null。实际跨过历史16878.966331s启动期限，null/disabled监督继续；尚无core DCP/最终收据。证据 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_generated_instance_renaming_finished.json`。


AT019 原生报告观察 2026-10-26T05:00:10.484617+00:00：L7592完成Writing Synthesis Report（工具elapsed05:29:43），L7594报告0errors/0criticalwarnings/2749warnings。采样 2026-10-26T05:00:09.610060+00:00：elapsed 19934.627924s，owned RSS 95.562572GiB，MemAvailable 368.114944GiB，CPU ticks 2847400，trigger null。实际DCP及guard收据尚待身份/cleanup核验；原始Cell Usage保存在 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_native_synthesis_report.json`，不代签最终utilization/完整fit/时序。


AT019 报告后等待态观察 2026-10-26T05:36:00.181375+00:00：只读等待态观察 2026-10-26T05:35:08.514880+00:00：从2026-10-26T05:28:44.885457+00:00起383.629423s内，Vivado主线程3583093及累计CPU最高线程3583107均增加0ticks、futex等待；仅周期sleep线程3583368增加4170ticks。log固定884747B，全部写I/O计数不变；intermediate_scope.txt和canonical core DCP均未出现。现有守卫使用owned总CPU，仍trigger=null，不能把总CPU增加当作本次有效综合推进。尚未据此判工具hang、FAIL或保护触发，也未停进程/重跑/修改进展标准；已向主控发送原始证据，等待有范围诊断。证据：`project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_native_report_runtime_observation_20261026T0535.json`。


AT019 管理员诊断准备 2026-10-26T06:07:09.695067+00:00：post-synthesis wait unresolved。固定只读入口SHA6621497d6e4e815a2076ce565d9d820e7f5e8236c21b5149b17f0157c286e4b0，最终2/2小进程正常/超时detach测试PASS；未对生产attach或sudo。原guard循环不运行期reap，僵尸因果未证；直接CONT会复活旧finite期限，保持原进程/监督/锁。工程证据包 `project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/protocol.md`；等待真实DG文件并立即回报根。


AT019实际管理员诊断审计 2026-10-26T10:22:15.245291+00:00：DG_20261026T101440Z_108d446e固定原Vivado，exit0/无timeout/0.365388097s/detach通过，原guard/三监督不变。主/高CPU线程pthread_join及synth关联sleep已观察，不据此作因果或安全恢复结论；A014独占.so符号定位。当前无core DCP/最终收据。内部.rtd等仅保留，官方DCP/项目run恢复条件无已验证输入，未试恢复EDA或生产操作。证据`project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/admin_diagnostic_identity_audit.json`与`project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/recovery_artifact_boundaries.md`。


AT019 v2对象只读诊断入口于UTC2026-10-26 10:43:44完成最终plan-only预检和优化Python拒绝检查。driver SHA75f3ea56536e1786f98fce471242a379cd5dc6381d3e6a502a7443247530c9af，reader SHA389c4dcd41fc3c9deb84016684751decdadb31cd55f5dbca52d43e94c987492a；v1 SHA6621497d6e4e815a2076ce565d9d820e7f5e8236c21b5149b17f0157c286e4b0保持冻结。preflight核原guard精确T/TracerPid0、目标PID/LWP/start和两ELF全文件哈希/映射/偏移。最终修改只增加未优化Python和guard状态入口约束并同步reader哈希；不变decoder沿用此前四小fixture和无inferior显式source收据，旧收据各自保留原版本身份。

v2固定3634083 LWP/frame0/PC与返回地址链，从栈保存的caller RBX取得this；仅有界读取count/flag/vector和最多64个原始worker PID，最高317字节目标内存，不调用inferior函数、不改内存/寄存器、不恢复线程或reap。20s capture加最多7s仅新GDB进程组cleanup，要求可靠detach。管理员实际执行尚待发生，count/flag/worker PID当前未知，僵尸因果与恢复安全未证明；post-synthesis wait unresolved，原Vivado/监督/锁与串行等待器保持。证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/v2_final_checks_20261026T104343Z/test_result.json 与plan.stdout.json。


## AT019实际对象与回收候选反例（2026-10-26）

管理员实际v2于UTC2026-10-26 10:48:30完成，原DG_OBJECT_20261026T104830Z_8a4d5837收据与最终SHA匹配；gdb exit0、无timeout/cleanup信号、capture0.465525069s、detach通过，原Vivado/start及guard T/TracerPid0保持。实读worker_count=1、termination_flag=1、worker PID3633734/start66420454/stateZ/PPID3582995，与候选确实绑定。原exit0与其他原采样保留；这证明实际等待对象包含该Z，仍不把未执行的回收称为恢复成功。

最小原生单PID wait4候选已在隔离真实小进程中发现决定性异常反例并停止：在nanosleep中SIGSTOP的真实父进程，改完整寄存器后跳libc syscall指令执行SYS_wait4(精确子PID,NULL,WNOHANG,NULL)，正常路径可回收并恢复寄存器/最终T/锁保持。但STEP发出而停止事件尚未收集时SIGKILL tracer，guard4142907/start70182259变S、Z已消失、锁仍在，不能保证停态及原上下文。30ms采样Python标记未出现，不能据此断言Python确已执行；所需的安全保证已失败。该机制不发布生产--execute恢复入口。剩余故障点和维护联锁集成未执行，全部夹具父/子已清理。

生产现场没有attach/信号/回收/监督切换，原AT019等待、同Vivado/旧guard父关系/锁和原监督保持。最小维护拟仅暂停主monitor并保留watchdog/observer，<=4s硬窗口与独立资源保护、不写伪heartbeat；因原生前提反例，尚未实现或测试。当前工程候选存在实质安全阻塞，交主控/A014审核。后续serial新guard的定点收养子回收需单独修复并保留Popen leader返回码/receipt，禁止waitpid(-1)；当前冻结guard不改，不捆绑防复发变更。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/guard_single_syscall_probe_1793012176366141368/test_result.json。


## AT019原生自停回收准备交付（2026-10-26）

AT019实际v2确认count1/flag1/worker3633734/start66420454/Z/PPID3582995后，原无写单STEP候选因执行中tracer死亡使guard转S被拒绝并保留反例。经主控明确授权，下一原生自停候选已完成准备；工程仍未执行生产attach/信号/回收/监督切换。

最终管理员入口SHA c3bedb2648eb5b2724ccf999902434f66b5b6a14e5fe7afa5b798cb976afea9f，core89cd5cfa、maintenance5a52d2d3。固定借用guard私有libc RX页尾48B，44B stub恰一次精确wait4/WNOHANG后只循环自停；完整regs/48B恢复并核真正T后才恢复主monitor，watchdog/observer在线，原heartbeat不写。核心9例与最终维护5例真实小进程通过；后者统一4s预算实际0.139/0.306/0.847/0.486/0.182s，40记录身份全gone。plan-only和优化入口拒绝通过。任意内核/文件系统停顿不声称实时保证，超时明确failed-closed并保留原监督fallback；不重试wait4/CONT旧guard。

新canonical runner42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89已加active/finally定点known/start/Z/PPID回收，排除leader/managed并保留raw status。真实孤儿11回收、leader7/managed13返回码保持，nonowned/wrongstart/live跳过。AT019 frozen/loaded f8c1886a未改，实际verify_inputs兼容性通过；原serial逐stage启动新canonical并冻结源码，未signal/重启serial。

生产等待仍未解除，当前只交付可审查管理员入口与真实基础设施证据。DUT f849/91源ROM/父11generic/300MHz/PS暂停不变，无新EDA/30层重验；无core DCP、最终完整资源fit或P&R/setup/hold验收。交还监督后允许原Vivado/guard/serial自然完成推进，以真实收据另核，不把入口成功当硬件完成。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/exact_child_recovery_ready_receipt.json；协议project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/exact_child_reap_recovery_protocol.md。


## AT019管理员恢复实际执行与原进程继续（2026-10-26）

管理员已于UTC2026-10-26 11:45:20实际执行RC_EXACT_20261026T114520Z_9baee073，工程只读审计通过。冻结entry/dependencies/frozen身份匹配，精确wait4返回3633734、原3633734/start66420454僵尸消失，全部原寄存器与48B恢复并核T/TracerPid0后恢复主monitor。统一维护0.901117602s、无backup、原heartbeat未写；outer子过程1.248205594s为另一重叠口径，不与维护耗时相加。capture期间owned峰95.220428GiB、系统可用最低347.280399GiB，原锁及watchdog/observer保护保持，新helper已消失。

原Vivado3583093/start66052106未重启；恢复后原vivado.log L7595新增Optimization Runtime11:46:36、L7596新增Synthesis Optimization Complete12:17:05、L7597实际Translating synthesized netlist，已经越过此前等待点。UTC11:48工程审计仍无intermediate_scope.txt、canonical core DCP或最终有效收据；已有serial仍waiting_existing_AT019。不能将内部Optimization Complete当synth_design/Tcl/DCP出口或完整物理完成。

仅继续同一AT019和已有serial原13阶段，不再次恢复/重跑/启动第二份EDA。后续新guard canonical42164971755a1dcc57a01ddc0c9101cb6af19a2db5506924a2debd7007569f89的定点收养Z防复发已验证；当前冻结/已加载f8c1886a保持。下一步核真实DCP身份、原/有效收据、owned/监督清理与锁释放，再由已有serial推进report_core等，不复制continuation。全部实际AT019墙钟含恢复等待，单独基础设施cost仅归档、不双计或清零。

DUT f849/91源/ROM、父11generic、原300MHz和PS暂停保持；本次未改RTL/重验功能。D37完整30层正常路径及局部四态证据边界不变，完整资源fit/最终P&R setup/hold/平台shell/板卡仍未验收。物理墙钟null/disabled、256GiB/系统余量/CPU0–3/nice19/idle/单重工具保护保持；主控每两小时通知继续。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/post_synthesis_wait_diagnosis_engineering/actual_recovery_identity_audit.json；costproject/E022_m007_full_top_physical/experiment_results/runs/R001/actual_administrator_recovery_cost.json。


UTC2026-10-26 13:03工程只读阶段核验：原log L7598完成Netlist sorting（49CPU/50s），随后分析640904 Unisim并完成替换（49CPU seconds），当前INFO: [Project 1-570] Preparing netlist for logic optimization。原计算LWP3583107在11:52→13:03的4244.314s增加419565ticks、现R，辅助线程单列；已有638B实际日志新增。此为综合网表内部实际阶段推进，640904不是完整最终utilization/fit。scope/coreDCP/最终收据仍无，已有serial仍waiting_existing_AT019；保持同Vivado/全部原保护和未来guard补丁，不做第二次恢复/新EDA。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_netlist_logic_preparation.json。


UTC2026-10-26 13:11工程只读核到原synth_design已实际成功返回（L7616），工具CPU06:24:03/elapsed13:42:25；L7613 checksum b788eb19。Tcl下一句已生成intermediate_scope.txt：top=laya_m007_matrix_engine_v1、blackboxes为空、full_kernel_accepted=0。write_checkpoint尚待完成，当前无canonical core DCP/stage_complete/原有效receipt，不能提前升级core阶段PASS；仍由原Vivado/guard/监督/已有serial连续完成，不恢复或重跑。

本次完整synth_design最终summary为302Infos/213Warnings/2CriticalWarnings/0Errors；2项Critical确在原始L43/45覆盖attention_tile_bank和attention_tile_service_v1旧定义，已保留并交主控/A014审阅适用性。此前内部Synthesis Report的0critical仅原内部分阶段口径，不能替代本次最终完整命令summary。未据此给完整资源fit或300MHz/物理通过结论。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT019_core_synth/stage_observation_synth_design_returned.json。


## AT019真实core阶段PASS与原serial接续（2026-10-26）

AT019原/有效receipt PASS，child_exit0/source_verify_after true/owned清空；原五运行身份均已消失。core_synth.dcp520296664B，独立sha a92039524cb313526500315841ecbbdeff0c2f1a5fd971b1680a3ca9b3b23f90等于metadata与serial；top仅matrix_engine_v1，full_kernel_accepted=0。实际guard elapsed 50108.013761572074s，effective elapsed 50108.013761572074s，峰owned 172.06399154663086GiB；全部原费用/恢复重叠墙钟保留，不清零或重复计。已有serial自动启动AT020_report_core，冻结新guard421649...已核，墙钟null。E022三摘要/console从此交serial唯一发布，不手工覆盖；资源/fit/300MHz仍待真实报告/最终物理审核。证据project/E022_m007_full_top_physical/experiment_results/runs/R001/AT019_core_completion_engineering_audit.json。


AT020实际完成utilization/hierarchy/ram/clocks报告（整个report_core仍未结束）：Synthesized matrix_engine_v1 CLB LUT2139515，已计LUT combining；用户全核预算900000（2.377239倍），器件表列1303680（164.11%）。FF1391977/用户1800000，DSP4352/7200，BRAM36eq0/1200、URAM0/640，core clock3.333ns。当前core综合态LUT超用户预算及表列器件，已即时交root/A014集中判断；报告亦说明后续opt/physical可能降低LUT，不能直接称最终fit不可能/完整top或300MHz通过。原serial仍按批准流程运行，工程未自停/改RTL/另起工具。证据project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/resource_finding.json。


### 2026-10-26：真实core资源出口后的serial持留与诊断准备

UTC13:51:25仅向serial PID3603650/start66216629发pidfd SIGSTOP，实际S→T；AT020 guard109263/start71064760及wrapper109276/start71064911继续正常，canonical serial state保留历史快照。持留原因是实际综合态core LUT2139515/器件1303680=164.11%，且超过完整kernel900000预算；不是时间或内存帽。独立证据见`project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/hold_receipt.json`。

主控已追加SM012同SHA完整core DCP一次常规opt诊断。轻量fixture实测原stop handler的排队TERM再CONT路径，可回收exit0/7子进程并保持原退出码，不启动facade。生产退出只在AT020 PASS/工具全退/锁释放后；当前尚未执行退出或新EDA。独立core_opt/report_core_opt入口与Tcl已备，canonical guard421649...和当前冻结AT020不变，前后同口径资源、完整边界/约束及有界本层primitive归组；不改RTL/tieoff/cone，不自动place。协议见project/E022_m007_full_top_physical/experiment_source/core_opt_diagnostic_protocol.md。准备核验、fixture和--plan不是硬件优化结果。


### 2026-10-26：AT020综合态实际时序未满足


AT020已实际完成Synthesized timing_summary及setup/hold各50路径报告：WNS=-1289.339ns、TNS=-301158.188ns，setup失败132577/3273333；WHS=0.065ns、THS=0、hold失败0，core周期报告3.333ns。最差n_reg[1]/C→error_col_reg[0]/CE，6091逻辑级，DataPath1292.568ns，其中logic359.024ns、工具unplaced route估计933.522ns。当前core综合态300MHz约束不通过；没有placed/routed时序结果，不能冒称最终route失败或只差报告。no_clock/unconstrained_internal_endpoints/loops均0，60880输入和112483输出未加shell I/O delay。路径报告-nets弃用各报一条critical warning，保留原日志。当前继续drc，无deadline/trigger=null，serial仍T；后继仅既定同DCP一次opt资源诊断，RTL不改。

证据：`project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/timing_finding.json`；候选优化尚未启动。


## AT020真实完成、完整端口更正及AT021接续（UTC2026-10-26 19:44）

AT019完整matrix core综合执行PASS，DCP身份保持。AT020报告执行PASS/source_verify_after真/child0/owned清理/锁释放，耗时22565.379247191s、峰RSS23.070541GiB、最低系统可用398.584511GiB。该执行PASS不代表硬件DRC或时序通过。

| Synthesized core资源 | 实际 | 完整核预算 | 器件总量 |
| --- | ---: | ---: | ---: |
| CLB LUT（已含combining） | 2139515 | 900000 | 1303680 |
| FF | 1391977 | 1800000 | 2607360 |
| DSP | 4352 | 7200 | 9024 |
| BRAM36eq | 0 | 1200 | 2016 |
| URAM | 0 | 640 | 960 |

当前core LUT为器件164.11%、完整核预算2.377239倍；本层直接1946767+dot_array137962+format54786=2139515，不将全部本层逻辑归为单一根因。Synthesized setup WNS=-1289.339ns、TNS=-301158.188ns、失败132577/3273333；hold WHS=0.065ns、THS=0、失败0。原最差n_reg[1]/C→error_col_reg[0]/CE有6091级逻辑，DataPath1292.568ns、logic359.024ns、unplaced route估计933.522ns。原工具组件和总量相差0.022ns，照录不猜因。没有placed/routed结果。

DRC为UTLZ-1 Error1、DPIP-2 Warning8192、DPOP-3 Warning4096、DPOP-4 Warning4352、CHECK-2 Advisory48，未关闭或降级资源错误。methodology实际完成，工具elapsed04:19:42/cpu04:28:04；报告显示2000项（TIMING-16 Warning1000、TIMING-18 Warning1000），不是全部timing失败数或新的全局worst。OOC有部分连接检查未运行。最终零blackbox/零latch/1时钟，完整get_ports190017与RTL全部端口位宽相符；check_timing的60880输入/112483输出缺IO delay是子集计数，不能作总接口估计。

旧serial于UTC19:41安全退出：只向精确serial排队TERM/核pending16384/CONT，guard已回收，原工具session返回3（意图暂停），helper返回0；两身份均gone，无新facade。AT021已于UTC19:41:48.975887启动，guard454976/start73335043，Vivado455129/start73335502，原DCP只读打开；无优化结果。

主要证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/AT020_core_report_completion_engineering_audit.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT020_report_core/engineering_resource_snapshot/port_declaration_accounting.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/serial_continuation/resource_stage_hold/serial_exit_receipt.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT021_core_opt/engineering_launch_audit.json。原报告、baseline timing_finding、日志和全部费用保留原路径。完整top fit、最终setup/hold、平台shell及上板均未验收。


### UTC2026-10-26 19:52：AT021前置脚本检查修复，AT022实际接续

AT021在open_checkpoint完成后、任何opt调用前因将current_design.NAME误作RTL top而FAIL；434.210852844s/峰15.724281GiB的费用及冻结源保留，source_verify_after真且工具/guard已清理、锁释放。原DCP dcp.xml明确Top/Part正确。本机Vivado原生脚本使用current_fileset.TOP，已据此修正严格top断言并保存实际container NAME和fileset TOP；新Tcl SHA495573622bfaf2c7ecca61c7d05612e3dfd5da1589c41f015baf5b511428e289，guard4b6d3135...及canonical421649...不变。这是脚本API检查修复，不是硬件/方法失败，也未消耗唯一opt调用。

AT022启动于19:51:20.944996，guard461124/start73392244、Vivado461284/start73392698；目前open原DCP/opt调用仍0。证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_source/top_identity_fix.json 与 attempts/AT022_core_opt/engineering_launch_audit.json。


### UTC2026-10-26 20:02：checkpoint实际身份API修复及AT023

AT021/AT022均在任何opt调用前因顶层身份API检查FAIL：current_design.NAME实际为checkpoint_core_synth（容器名），checkpoint会话current_fileset.TOP实际为空。两次434.210852844s和455.505928938s费用/冻结源/源码核验/清理均保留，候选无、opt总调用0。这不是硬件或方法失败。当前改为从实际report_utilization标头严格解析并核Design=laya_m007_matrix_engine_v1及Device=完整器件，结合原DCP SHA/dcp.xml绑定；解析已用AT020原报告在Tcl中验证。before同口径utilization直接复用，after边界另存实际utilization，完整端口/时钟/约束与零BB检查保持。新Tcl bda4ee1ba816bc28758d46983fe5fc19bc9da78e30175d261a4a059adaa222d5，guard4b6d3135...与canonical421649...不变；无RTL/约束/数值修改。

AT023于20:01:06.360122真实启动；guard467064/start73450786、Vivado467207/start73451238。实际源/运行见project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_launch_audit.json。


### UTC2026-10-26 20:16：唯一opt实际开始与before资源/primitive部分结果

AT023已实际完成before全部身份/边界、资源与有界primitive报告，当前唯一一次opt_design已开始，正执行原生前置DRC。实际util资源逐项等于AT020；190017位端口名字/方向与全部RTL声明机械枚举完全匹配，missing/unexpected均0。直接primitive3910950，raw LUT2241625；g_operand_slot名称组FDRE1048576，raw LUT1058681（LUT3 491520+LUT5 475136+LUT4 49152+LUT2 32825+LUT6 10048）。mul_a/mul_b/trace_commit_data各有raw LUT6 139264。名称归组不是combining后本层LUT1946767或单一源码因果结论，原始有界样例/可用源属性保留。尚无优化后候选/资源结果，未关闭或降级UTLZ。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_before_resource_audit.json。


## UTC2026-10-26 20:37：唯一opt完成，候选仍超器件，AT024实际接续

同DCP唯一普通opt_design完成，LUT2139515→2091399，下降48116（2.248921%），仍为器件1303680的160.42%、完整核900000预算的2.323777倍。当前候选core资源明确不通过，不能进入place/route。完整top资源及最终物理时序仍未取得。

| 同口径资源 | 综合core | 一次opt后core | 完整核预算 | 器件总量 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT（已含combining） | 2139515 | 2091399 | 900000 | 1303680 |
| FF | 1391977 | 1391977 | 1800000 | 2607360 |
| DSP | 4352 | 4352 | 7200 | 9024 |
| BRAM36eq | 0 | 0 | 1200 | 2016 |
| URAM | 0 | 0 | 640 | 960 |

AT023执行PASS/child0/source_verify_after真/原DCP未变/工具和guard清理/锁释放；elapsed1992.074475108s、峰16.459915GiB、最低系统可用402.565830GiB。opt_design自身elapsed00:16:11/cpu00:15:04，候选checkpoint已实际保存493065634B、SHA97426945bdf39b3ad1b6e0056583fa5153df570018efb219a017e9a87ca942f3。190017位port与全部RTL声明名字/方向全等，before/after完整port/clock/XDC边界字节相同（SHA12cea865f889597ed55b7bff981f34ac1467ebc52045c093e25d0b10034a6a5a），零BB。该执行PASS不是资源或时序PASS。

before直接primitive3910950、raw LUT2241625；g_operand_slot名称组FDRE1048576，raw LUT1058681（LUT3 491520/LUT5 475136/LUT4 49152/LUT2 32825/LUT6 10048）；mul_a/mul_b/trace_commit_data各raw LUT6 139264。这是有界名称/primitive计数，不等同combining后的本层LUT1946767，也不作全部LUT单因归属。post-opt层级/primitive复开观察待AT024真实报告。

原综合态setup WNS=-1289.339ns、TNS=-301158.188ns、失败132577/3273333；最差n_reg[1]/C→error_col_reg[0]/CE有6091级逻辑，DataPath1292.568ns、logic359.024ns、unplaced route估计933.522ns；组件与总量差0.022ns照录不猜因。原hold WHS0.065ns/THS0/失败0。优化后全局及固定各1条setup观察尚在运行，不沿用原值冒充新测。

AT020报告执行PASS22565.379247s/峰23.070541GiB，DRC实际UTLZ-1 Error1、DPIP-2 Warning8192、DPOP-3 Warning4096、DPOP-4 Warning4352、CHECK-2 Advisory48；methodology TIMING-16/18各Warning1000（报告2000项，不是全部timing失败数）。OOC有部分连接检查未运行；未降级或关闭资源错误。pre-opt API两失败AT021434.210852844s、AT022455.505928938s均保留，不算已执行opt，不当作方法FAIL。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT023_core_opt/engineering_completion_audit.json、engineering_before_resource_audit.json、reports/after_utilization.rpt、boundary_preserved.txt；project/E022_m007_full_top_physical/experiment_results/runs/R001/checkpoints/core_opt.identity.json；project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_launch_audit.json。完整top、shell、最终setup/hold与上板性能未验收。


AT024于20:35:22.805725实际只读候选，guard493551/start73656443、Vivado493764/start73656883；无新opt或place。


### UTC2026-10-26 20:50：AT024资源复开已证，后路径观察运行

AT024候选已独立复开并完成实际资源/层级/primitive报告：LUT2091399/FF1391977/DSP4352/BRAM、URAM0与AT023 after完全一致；190017位port/clock/XDC完整边界也与AT023 after字节相等。层级本层1899196+dot_array137930+format54273=2091399；对应降低47571/32/513，合48116，本层单独仍超器件。raw直接LUT2241625→2187052（减54573），FDRE1065764、MUXF7/8 402340/196736不变。共同导出的g_operand_slot六个名称/primitive组计数均未变：FDRE1048576，五个导出LUT组之和1058681；导出前256组不是全部513/511组，未导出组不按0处理，也不换算为combining后LUT或完整cone因果。两条setup路径观察仍待最终核验。

证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/attempts/AT024_report_core_opt/engineering_post_resource_finding.json。
