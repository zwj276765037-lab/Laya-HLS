# D38 complete production-kernel physical protocol

Authority: SM012 D-M007-SM012-FULL-TOP-PHYSICAL-38 and the latest user instruction. Owner A010; other owners share the workspace and their edits remain intact. Production laya_m007_single_parent_v3 SHA9d877217...db6, VERIFY_POST_ENCODER27_H=0; D37 complete original30 normal-path PASS is retained without rerunning RTL.

The91 production sources retain D37 AT001 order and match the D36 rev2 fixed manifest; three simulation-only TB/peer sources are excluded. All original/frozen source and ROM hashes and their D37 correspondence are in runs/R001/input/source_manifest.json. No constant tieoffs, numerical replacement, shape/gold edits, fake IP or shell is introduced. EXP relative readmemh is satisfied by the identical original .dat in every attempt working directory.

Tool: /home/user/EDA-202/vivado/vivado_2025.2/2025.2/Vivado/bin/vivado, actual version/part/license acquisition must be evidenced by tool output. Target xcu55c-fsvh2892-2L-e, full bare kernel OOC, core clock3.333333333ns. No external IO delays, invented uncertainty, reset false paths or broad timing exceptions. User uncertainty and shell IO timing remain unspecified; report clock properties/check_timing and separate external from internal unconstrained endpoints.

Canonical scripts: E002/experiment/vivado/module_design/forward_controller/physical_d38/{run_physical_d38.py,full_top_d38.tcl,full_top_d38.xdc}. Entry run_physical_d38.py --prepare freezes identity; --stage preflight reads the complete production source set and checks tool/part; synth saves synth.dcp; report_synth reports full/hierarchical utilization, RAM, clock, blackbox/latch and setup/hold/constraint reports. opt,place,phys_opt,route resume matching prior checkpoints; report_place/report_route gather congestion and routed timing/status. Each actual attempt freezes the exact scripts and command, log/journal, resource samples, owned PID/start identities, policy, cost and cleanup. DCP resume verifies source/ROM/parameter/XDC and checkpoint SHA; existing checkpoints are never overwritten.

Caps are independent: preparation600s; synthesis total9000s/single7200s; implementation total18000s with opt/phys_opt3600s each and place/route7200s each; reports/archive1200s. Failed/unfinished attempts retain charges, with incomplete entries conservatively reserving their full cap until finalized. No old balance transfers.24GiB owned RSS, MemAvailable>192GiB,CPU0-3/max4 Vivado threads,nice19,idleIO and m007_heavy.lock apply to all actual tools until owned cleanup. Stall requires300s without observed owned CPU ticks AND actual log/checkpoint progress; stdout silence alone does not stop active synthesis. Resource/budget/stall stops are COST_STOP; actual tool errors are FAIL, never method refutation.

Deliver DSP/LUT logic-memory/FF/BRAM18-36-equivalent/URAM by hierarchy and functional blocks, blackboxes/latches/storage/constraint coverage, DCPs, routed setup/hold WNS/TNS/WHS/THS and violation counts, congestion, key paths/DRC/route status. Preserve capacity illegality rather than disabling checks. No DCP means implementation NOT_RUN with the real blocker. Functional simulation, synthesis, routed timing and board evidence remain distinct. Finish evidence/owned cleanup then pause.


## Corrected execution configuration v2

AT002 only set VERIFY=0 while parent platform defaults forbid successful SETUP. Its source/command/receipt stay unchanged and are not a D37 complete-kernel result. Before the requested cancellation could be delivered, its actual four-process synthesis hit24GiB owned RSS at126.709649772s (25,418,316KiB peak). No DCP exists from that attempt. Independent later PID/start checks confirm all its known descendants are gone; the original last cleanup snapshot is preserved.

New input/physical_configuration_v2.json and physical_generics_v2.tcl bind all11 production parent parameters to the D37 instance: six default MODEL/GRAPH/NUMERIC/LAYOUT/PACKAGE_BUILD/TABLE_KEY constants plus explicit VERIFY0,ADDRESS_PROFILE1,base0,each-port4GiB span and platform SHA f0df35cc...607db18. JSON/Tcl/frozen parameter hashes are checked and part of checkpoint identity; the original v1 source manifest remains unchanged. These are the validated simulation peer aperture/layout parameters, not a real HBM shell integration. General.maxThreads1 for synthesis removes the observed four-process overhead; other phases may use up to4. Actual process count and CPU affinity, not an assumed setting, are recorded.

The runner now treats a false source recheck as FAIL_SOURCE_IDENTITY, checks actual frozen XDC/generic hashes and waits for all known owned processes to disappear/reap before lock release. Unobserved transient process policy remains UNKNOWN.


## Source-identical serial bottom-up flow v3/v4

AT003 correctly configured full top reached the24GiB guard at709.993409556s,peak25,479,056KiB,with no DCP and empty owned cleanup. Its hidden worker log identifies matrix_engine sequential_dfg_opt_pass1 and unsupported op0/op1 3D RAM patterns with524288 registers each; these are tool runtime-expansion diagnostics,not final FF utilization. The four-process AT002 and one-worker AT003 costs remain in the same9000s ledger.

The controller/A014 selected source-identical natural boundaries: actual core_synth(PROFILE_ENABLE0,original dot_array/format)→facade_synth(PROFILE0,CANONICAL1,MODEL_ID9db40381604108af)→actual core DCP insertion as facade_link; actual resident_synth(TANH_FORCE_CORE_CE0); original parent_synth with both real partitions inserted as full_link. Partition synthesis uses flatten none and one synthesis worker under the unchanged24GiB limit. Full-kernel resource/timing conclusions require the actual final zero-blackbox linked design and implementation; component numbers are never summed as its substitute.

Temporary stubs mechanically retain all original port/header text and module-body parameters. Flowv3 preceded detection of resident's body parameter; current AT005 core uses no stub and retains its frozen v3 identity. Future flowv4/stubs_v4 preserve TANH_FORCE_CORE_CE's original0 declaration and explicitly bind0 in resident OOC. Only this already-running core checkpoint may use a documented v3→v4 plan-metadata compatibility check: identical91-source/ROM/base identity,part,XDC,parent generic identity,core top/PROFILE0/stub-free spec,flatten none and thread1; original checkpoint/receipt metadata is never rewritten. Other checkpoint identities require exact equality.

Actual link uses strict read_checkpoint at core,matrix,resident. Pin names/count/directions are compared before/after real DCP insertion,including full trace interfaces. Child OOC clocks are removed and the same original top XDC recreated; exactly one root clock and zero remaining blackboxes are required. No DONT_TOUCH or arbitrary functional pruning is added. The latest reviewer scope is results/reviews/m007_d38_physical_review_20261025.md. AT004's original parameter-query receipt only proves Tcl/tool-help normal exit,not that a hidden parallel parameter was discovered; its raw unsupported-regexp message remains preserved.


## Authorized operand representation repair / new identity v2 (after AT005)

SM012 amendment permits only op0/op1 unpacked64slots/static-slot LHS, preserving64×256×32bits, all asynchronous reads, distinct-slot concurrent writes, source guards/reset and same-slot priority. repair_operand_storage_d38.py mechanically removes six original data assignments, inserts the generated write process, preserves every other production byte under exact inverse, and extracts actual original/fixed storage clauses and six read RHS with source mappings. Independent enable/slot/payload drives compare all bits in both pools and all actual storage-read expressions before/after every edge. The non-storage bias cone is identically empty in both extracts; unrelated control is covered by unchanged-byte proof, not a claimed full-core simulation. XSim2025.2 is the actual4state backend.

Run --stage repair_static (xvlog/xelab) then --stage repair_rtl (actual same compiled snapshot copied into an owned attempt). Freeze hashes for old/new sources/extracts/TB/driver; RTL requires terminal PASS, rc0, source afterchecks and empty owned cleanup. AT009/010 passed with6721cycles/13442checks; repair/equivalence_result.json provides exact finite coverage/limitations. Failed preparation/compile attempts remain charged.

Only after local PASS, input/source_manifest_v2.json freezes exactly one modified source;90others/ROM and parent SHA9d877217... remain. New bottom_up_configuration_v5.json/stubs_v5 preserve prior valid generic/body-parameter plans. active_source_version.json selects new files without overwriting v1/v2-v4 history. Each physical attempt freezes actual sources.tcl/manifest/partition flow; real stage logs bind the read source paths. Original D37 full30 proof is not a new full30 rerun.

Budget revision:600static+600RTL taken from unused18000implementation, leaving16800implementation; total28800 and9000synthesis/preparation600/reports1200 unchanged. Repair single300s,RTL8GiB/100000cycles,static24GiB; same lock/affinity/nice/IO/memory/owned cleanup. AT011 core synthesis uses repaired identity; success must continue to actual full top DCP assembly and physical reports.


## Latest flat8192 representation / sourcev3, partitionv6

AT011 e279 still has3D-RAM warnings and long continuous-CPU RTL elaboration. Controller/A014 explicitly directed active replan stop rather than waiting7200s:1736.656508570s,peak16777212KiB,no swap/no resource/stall/numeric trigger,owned cleanup empty. Preserved raw guard uses requested_stop/COST_STOP; result_classification.json explicitly records CONTROLLED_REPLAN_STOP and actual reason.

repair_flat_operand_storage_d38.py only flattens each packed[255:0][31:0] slot to[8191:0] and corresponding PS lane write/read to32bit indexed slices. Whole8192bit operations and all guards/control are unchanged. Exact inverse restores both e279 and original2147 bytes; actual original/latest storage extracts and source mappings are repair_v2. AT012/013 compile and rerun unchanged6721cycle XSim4state TB with same assertions and coverage, bothPASS. Original AT010 remains independent historical proof.

Latest source_manifest_v3/bottom_up_configuration_v6 replace only matrix engine identity;90other sources/ROM/top unchanged. AT014 core maximum5558.397858556s is all remaining synthesis budget; cumulative3441.602141444s charged, no reset/increase. All downstream real-DCP/full-kernel timing requirements and NOT_RUN board/shell scope remain.


Latest AT014 outcome: actual24GiB RSS COST_STOP1278.032619354s,receipt peak25454276KiB,source_verify_after=true,ownedempty and independent7PID/start auditempty;1transient policyUNKNOWN. Initial mainRSS24909352KiB and stopped-snapshot24915024KiB are distinct actual samples;helper529332KiB. Op0/op1 3D warnings removed,aligned32768 warning remains. Actual log has engine-module-done marker but no completeRTL-elaboration/synth_design/DCP. Prior tail-only no-engine-done statement was too broad and is corrected. No final mapped resource or device-fit/numerical conclusion.

Latest f8493b original-source local equivalence PASS remains; new full30 NOT_RUN. Complete hierarchical linkage/resources/implementation/internal300MHz timing NOT_RUN. Synthesisspent4719.634760798s/rem4280.365239202s,all original budget retained,no reset/final sealing. Current stagewaiting_review,no heavy tool/automatic retry or new source change;central controller/A014 determines evidence-based bounded next scope. See E022/R001/physical_blocker_result.json and AT014 raw receipts/snapshots.


## Latest explicit user budget increase / AT015 same-source restart

User gave more budget after clarification that24GiB was a project guard,not host exhaustion. Latest SM012/AGENTS supersede prior physical caps and PS prerequisite: cumulative preparation1200/repair_static600/repair_rtl600/synthesis43200/implementation86400/reports3600s,total135600s,all old charges retained. Physical synthesis/link/implementation/reports RSS128GiB; repairstatic24/RTL8 unchanged. Synthesis/link single21600s,opt/phys_opt14400s,place/route43200s,all bounded by actual cumulative remainder. Same192GiB available/CPU0–3/nice19/idle/singleheavylock/synthesis1worker and300s noCPU AND noactual log/checkpoint stall. Old24GiB and old wall limits no longer stop new physical attempts.

PS candidate7c292 remains unexecuted/unapplied; no PS tool attempts were launched before user pause, source files retained. Productionf849/source_manifest_v3/bottom_up_v6/parent/ROM/11generics/XDC unchanged. Expanded-budget AST/imported actualguard/source check PASS. AT015 NEW actual core launchUTC11:41:33.922608 PID3088949/start61814704 with128GiB and21600s; prior cumulative synthesis4719.634760798s preserved,launch remainder38480.365239202s. No old DCP exists so this restarts,not resumes. Complete resource/implementation/timing remain pending; automatic source-bound real assembly and physical stages follow actual core success.


## Actual256GiB runtime supervisory handoff (2026-10-25)

The user doubled only physical RSS128→256GiB,retaining original time/host-memory/CPU/lock policies and existing Vivado. Original CPython guard stores128in a fast local and cannot hot-reload; gdb attach was denied by existing ptrace policy,no global security change. New handoff_guard_d38.py was validated with real small processes for normal finish,RSS stop and monitorSIGKILL/fallback (R001/guard_handoff_validation). These tests are not Vivado/hardware results.

AT015 external monitor3210585/start62682850 became active14:06:12.169726UTC,watchdog3210588/start62682857. Originalguard3088940/start61814680 was SIGSTOPped only at hrtimer_nanosleep with RSSbelow128GiB; it retains original parent/subreaper/heavylock and all frame state. Vivado leader3088949/start61814704 and main3089047/start61814735 were never stopped/restarted/injected. External monitoring enforces256GiB,MemAvailable>192GiB and the conservative originalcommand.started_utc+21600deadline17:41:33.917700UTC. FirstCPU/file observations are baselines,actual progress age carries over. PID/start tracking includes descendants/reparent/changedPGID; originalguard is excluded from killableowned.

Watchdog is independently running; monitorheartbeat failure/disappearance restores original128GiB guard and requires new real original sampling or receipt before exiting. Healthy completion waits for all activeowned processes to finish,then CONTs original to reap/wait/source-verify/cleanup/ledger/receipt. External coststop kills only verifiedowned before restoring original. Original command/launch/frozenrunner/receipt are immutable; effective_receipt sidecar binds originalSHA and merges both periods,without double-counting elapsed time. Originalguard's staleledger must not be edited during pause; append policy accounting after its finalization. Current live evidence is AT015/rss256_handoff/live_status.json,not original frozen live_status. Future runner physicalRSS256directly;static24/RTL8unchanged.

Additional live protection: independentobserver3214011/start62701992 was ready14:09:23.412758UTC(session38131). It confirms oldguard real sampling/receipt on monitor/watchdogfailure or exceptionalhandoff_end;missing/unconfirmed oldguard causes verifiedownedcleanup. The current loaded95c75guard remains unchanged and is byte-frozen with itsSHA;futurecanonicalfinally was separately fixed and validated across5real small-process cases(including exceptionfinallyandoldguardloss). See frozen_source_binding.json and guard_handoff_exception_validation/test_result.json. Before next stage verify both original/effectivereceipts,observerexit,ownedempty and lockreleased.


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
