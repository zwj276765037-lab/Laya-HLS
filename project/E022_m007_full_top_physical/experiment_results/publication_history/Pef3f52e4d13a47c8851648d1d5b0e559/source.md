# E022 D38 same-source core synthesis strategy v7

Production matrix remains f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd/source_manifest_v3,with original dot/format subtree andall91production sources/ROM. Parent9d877217.../11D37generics/XDC/part remain unchanged. The earlier flat8192 operand representation retains its actual original/latest local4stateproof;D37 originalfull30normalpath proof is unchanged and not rerun.

AT015 reached its original6hwallcap in synthTimingOptimization with noDCP. Newv7 changes only core_synth command by adding documented-no_timing_driven;facade/resident/parent/link specs and all stubs are byte-identical to v6. Source+strategy-bound config43b7e787... and flowacd38160... plus strategy_v7_relation.json preserve the boundary. NewTcl logs the complete actual synth_designargv and freezes generatorcode. NoRTL/capacity/cycle/interface/numeric edit or PSapplication.

Local installedVivado2025.2 manual L328-330 and actualAT018 synth_design-help output confirm the option. Frozenmanual/sourcehash and helpusage/receipt are input/no_timing_driven_support.json. AT016/017 were lightweightquery-script failures(redirectunavailable/help-topicmissing),not unsupported-option or synthesis runs;their costs and receipts remain.

Same xcu55c-fsvh2892-2L-e/OOC/PROFILE_ENABLE0/flattennone/singleworker,original300MHzXDCrequested3.333333333ns resolves3.333ns. Skipping synth internal timing-drivenoptimization may change mappingquality;it does not sign routedtiming. Complete realDCP assembly,zeroBB/onerootclock/fullinternalcrosspartition STA andfinal300MHzplace/route acceptance remain unchanged. No realboard/shell/externalIOtiming proof.

按用户授权，主控仅删除已结束 AT002/AT003/AT015 的 153 个可重建 .rtd/.tim 二进制缓存，释放 4,447,686,656 allocated bytes（4.14223 GiB）；其余 358 份旧文件前后 SHA 未变。当前 AT019、共享输入、ROM、冻结源码、日志、收据、DCP 和局部等价 xsim 快照保留。证据由主控维护于 results/reviews/m007_d38_cache_cleanup_20261026.json。

用户最新明确要求取消物理阶段时间上限并每两小时汇报。synthesis/implementation/reports 的单次和累计墙钟均以 null/disabled 表达，不使用极大数字；preparation/repair 原帽保持。历史 command、冻结代码、费用和原收据不回写。物理 owned RSS 256 GiB、MemAvailable>192 GiB、CPU0–3、nice19、idle IO、综合单 worker、单重工具锁和 300 s 实际 CPU/日志/checkpoint 停滞保护不变。

当前 AT019 已于 2026-10-25T23:44:46.737830+00:00 通过外部监督实际接管。仅原 Python guard 单 PID 暂停并保留父进程/锁，Vivado 原 PID/start 未变。冻结的 monitor/watchdog/observer 使用显式无 deadline 分支；未来 canonical runner 对三类物理阶段禁用单次/累计墙钟。实现和测试证据均属于基础设施，不改变功能或硬件时序结论。

为连续执行既定物理流程，轻量串行 continuation 已实际启动：PID3603650/start66216629、session84409，当前仅等待同 AT019，attempt 数仍19。它核真实有效 core PASS、原收据 SHA、DCP/identity、owned/监督清理和锁释放后按原13阶段各执行一次；不启动或重跑 core。每阶段实际 launch/receipt 写入 serial_continuation/events.jsonl/state.json 并发布摘要；遇真实失败停止。该等待器不占等待期重工具锁，不改变两小时汇报配置，工具执行完成仍需工程核资源与时序后才验收。

---
Published: 2026-10-25T23:57:14.690510+00:00
Publication: Pdd4c4d553b4e419c806921a6df265902
