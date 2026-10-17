# Encoder→Decision 阶段集中验收

验收日期：2026-10-10（Asia/Shanghai）。审核者：GPT-6 Astra / xhigh，实际委派配置 `gpt-6-astra` / `xhigh`。执行者：GPT-6 Sol / xhigh。依据为[阶段合同及完整前端薄封装补充](../../mission/encoder_decision_validation_workflow.md)，动态结果仍只在[阶段结果表](stage_results.md)维护。本文件是本轮一次集中验收结论，不是新阶段或逐次编译/运行审核门。

**结论：部分成果验收成立，完整连接 RTL 验证因成本停止而未完成。** 新 71532 源码身份的完整四请求持久 CSim、完整 B1/S128 前端 helper CSim、薄封装 HLS 生成和 XSim 静态展开通过；fe067 完整 HLS 生成保留原身份通过。完整冷前链 RTL 没有达到首次 `ap_done`，完整 raw/norm 独立比较、末态 owner/spec、末笔 hold 和首次 done 响应债务均未验证。不得将本结论写为完整 Encoder→Decision RTL PASS、完整前链 RTL PASS 或整个离线工程完成。

## 身份与可复用边界

| 证据范围 | 身份 | 集中结论 |
| --- | --- | --- |
| 旧完整 CPU、原 B2 CSim、`persistent_csim_01`、`full_hls_01` 及完整 top B2 pilot | build `fe067c8aa0627ad770096f9721394645`；原 manifest SHA256 `128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa` | 只按原身份和原范围复用；不是本次新 CPU 重跑 |
| 共享 `Controller::frontend` 抽取后的生产源码及新包 | build `71532a6b269495506766d83080762740`；新 manifest SHA256 `2b5cb3dae3b27fb80995fd582d105bf5dcad340dc8fa5e91e5c0a1ab1bd88d39` | 当前 model/numeric/layout 保持不变；生产源变化已重新绑定 build |
| 新身份完整持久 CSim、helper CSim、六口薄封装 HLS/XSim | 上述 71532 包，加各 attempt 的实际源码/config/测试台/生成与编译制品 manifest | 不把包 tag 当成全部工具制品的唯一身份；实际 closure 单独核验 |

[严格新包检查](attempts/front_model_check_01/full_model_package_report.json)为 `MODEL_PACKAGE_PASS`、104 个构建源无 stale 项；[逐项比较](attempts/front_model_check_01/identity_comparison.json)确认 model/numeric/layout 相同，四个非 AUX BO 哈希相同，AUX 仅 byte 80–95 的 build tag 改变，四份冻结请求副本仅 byte 88–103 改变，原始请求与 oracle 未改。本次验收重新核对 104 个包源哈希，均匹配。共享 helper 位于同一生产 Controller，完整 `graph` 实际调用它，前端入口不提交完整 LYRS 成功结果；算子、16 行任务切分、生产地址和 owner 路径仍由生产实现提供。

新完整持久 CSim 的[原始事后全清单检查](attempts/persistent_csim_front_identity_01/postrun_identity_check.json)曾报告独立薄 wrapper 漂移，不能隐藏为全清单从未变化。[实际编译 closure 复核](attempts/persistent_csim_front_identity_01/postrun_compiled_closure_check.json)确认 25 个生产 TU 和该测试台无漂移；变化的 `full_frontend_wrapper.cpp` 不在这次完整 top CSim 的编译配置中，因此不推翻该二进制结果。后续 helper/HLS attempt 各自绑定实际 wrapper。

本次验收先重新散列 `frontend_chain_csim_02` 的 47 个输入、`frontend_chain_hls_01` 的 41 个输入、`frontend_chain_compile_04` 的 329 个输入、`frontend_chain_run_03` 的 14 个输入，以及薄封装生成审计中的 264 个 RTL/DAT/IP 文件，在下述工作TB修复前均匹配所存 manifest。`compile_04` 的[编译封存](attempts/frontend_chain_compile_04/compile_seal.json)与 `run_03` 的[运行前 manifest](attempts/frontend_chain_run_03/input_manifest.json)一致：实际 `xsimk` SHA256 为 `b1fb628808ad394333dd847d1bd503293d4c36d095274361409b540c5a1e004b`，DPI 库为 `a786883a11c3166001f9fc92f93c69141e3d4bb6289c34cb9ffe7b42aa922fb8`。审核中Sol补齐工作TB断言后，活动 `frontend_chain_mem.c` 已有意改变；本次又核对两个 attempt 的 `mutable_source_snapshot.tar.gz`，所存旧TB均仍为 `b923f6e7cebafbef4691f3d36f31fe9a4131aea05da52b5a74f479b1eda78ef4`，与运行前封存一致。新TB不回填旧制品。这证明本次已记录制品的可追溯性，不另声称未封存的工具安装全量 binary seal。

**fe067 完整 HLS 与 71532 薄封装不是同一硬件制品，不能拼接。71532 新版完整 HLS 尚未生成；旧 04934 完整 RTL 的已知 QK/AV 缺陷也不能借本次新 CSim 或薄封装关闭。**

## 已成立的分层结果

| 项目 | 结论 | 原始证据与实际范围 |
| --- | --- | --- |
| 71532 完整真实 13 口持久 CSim | PASS | [CSim 原始日志](attempts/persistent_csim_front_identity_01/work/hls/csim/report/laya_typed_q8_forward_csim.log)：同一 static runtime/13 BO 的 B2 id1 → gamma 故障 id2 → 两份独立重基 B1 id3/id4；3 个正常请求共 141 点、18094384 F32，分别 37158/18895/18895 tasks，完整 28+2 层，独立 final18/commit 检查；故障 17 tasks、flags9、LOAD_LN_PARAMS 首因、零 logits、整 AUX 恢复后继续成功。exit0、197.096s、峰值1738684KiB，无 guard 触发 |
| 71532 B1_from_b0/S128 helper CSim | PASS | [CSim 原始日志](attempts/frontend_chain_csim_02/work/hls/csim/report/laya_frontend_chain_csim.log)和[测试台](tb/frontend_chain_csim_tb.cpp)：raw/norm 各131072 F32 对原冻结 oracle 逐位相同；8 EMB + 1 gamma + 8 LN，共17任务；3 claims、HIDDEN0 FREE/invalid、HIDDEN1 READY/valid/128行、gamma READY、readers0、spec/identity/coverage、IO不写及工作区尾部 sentinel 均检查。exit0、20.818s、峰值1260096KiB |
| 71532 薄封装 HLS 与静态展开 | HLS_GENERATION_PASS / PASS（静态范围） | [生成审计](attempts/frontend_chain_hls_01/static_audit.json)绑定190 Verilog、68 DAT、6 FP IP VHDL及生产任务调用链；[正式 HLS 报告](attempts/frontend_chain_hls_01/work/hls/syn/report/laya_frontend_chain_csynth.xml)与 exit0 一致。`compile_04` [展开日志](attempts/frontend_chain_compile_04/work/xelab.log)生成 `frontend_chain_static`，exit0、167.395s、峰值4647460KiB |
| fe067 完整 25 TU HLS | HLS_GENERATION_PASS，连接只到 PARTIAL_STATIC | [生成审计](attempts/full_hls_01/static_audit.json)及[正式报告](attempts/full_hls_01/work/hls/syn/report/laya_typed_q8_forward_csynth.xml)：exit0、1193.175s、峰值10435308KiB；13口、28+2控制图、QK/AV真实算术实例/start/数据与写路径、双residual输入、owner和commit结构。80项审计并不等于全图所有producer/owner/consumer在RTL上的地址、数值与响应债务验证 |

`owner_leases=0` 是生产“独占原位 lease”计数，不是没有读 acquire/release。16 次前端读 acquire/release 是源码任务路径期望；CSim 检查最终 readers0，不能把该字符串当成独立16次硬件事件计数。标准 libm CSim 通过也不能外推为所有生成 FP IP 数值等价，尤其不能关闭既有 FP 例外值域。

薄封装真实六口均为32-bit数据；旧完整 top 的13口也均为32-bit，512 widening 配置不是实际总线宽度。薄封装估计 LUT136486、FF39901、DSP23、BRAM81、4.867ns，完整 fe067 估计 LUT1810065（相对整器件1303680约138.84%）、FF466070、DSP456、BRAM537、URAM45、4.936ns；二者 top latency 均未知。资源和时钟仅为 HLS 估计，完整 fe067 的 LUT 估计已超过器件容量，不能据生成成功声称可放置或达到150MHz。

## RTL 实际覆盖与成本停止

`frontend_chain_run_03` 是真实 B1_from_b0/S128 冷启动薄封装，原始 token、embedding/AUX 输入，外部 STATE0/STATE1 为 sentinel，未向 runtime 强制 READY 或预装中间 tensor。静态审计显示 FSM/start 使用 pin reset，runtime 标量依赖冷初值、owner RAM 依赖 DAT；没有暖 reset 完整验证。

[原始 XSim 日志](attempts/frontend_chain_run_03/work/xsim.log)最后一条进度在18,882,560 clocks：

- raw 写覆盖524288/524288B；真实 AUX gamma 读覆盖1024 F32。
- LN 从 DUT 生产的 STATE0 读覆盖49152/131072 F32，即前三个完整输入 tile；在线检查禁止 raw 写未全覆盖时开始该读，并检查 STATE0 adapter 写债务先清零。
- 已接受 start→一次 ready/done 配对的只读探针记录34/128行 LN 算术完成；norm 仅写覆盖131072/524288B，即前两个 tile。行算术完成不是独立数值比较通过。
- observed 写覆盖0B，没有首次顶层 `ap_done`，没有 `FRONTEND_CHAIN_RTL_COMPARE_PASS` 或 `FRONTEND_CHAIN_RTL_PASS`。原始日志也未出现已启用在线断言的 ERROR/FATAL；这只适用于已走过的部分事务。

[guard](attempts/frontend_chain_run_03/guard/guard_result.json)记录1584.280753s主动终止、`sigterm_requested`/子进程-9、峰值896308KiB、最低 MemAvailable444111348KiB。CPU0–3、nice19、idle I/O、0.2s RSS采样与3600s/8GiB帽均保持；实际没有撞到40M周期、墙钟或内存硬帽。该退出码源于受控成本停止，不能记成功退出或数值 FAIL。

[cost_stop.json](attempts/frontend_chain_run_03/cost_stop.json)的3686.180518s可复算为：1548.139792s锚点 + 剩余96行×15.715946429s/行 + 后续5个写/下块读窗口×110.012397s + 最后65536B÷826.974768B/s。两组行区间各110s且各完成7行，写/下块读窗口分别约110s；按所选较快速率继续仍条件超3600s约86.181s。锚点是32行、18,792,448 clocks；最后日志的34行、18,882,560 clocks来自随后运行，二者并不冲突。

本次验收还从同一[原始采样](attempts/frontend_chain_run_03/phase_progress.jsonl)离线复算两个相隔110.012426s的有效样本：1163.095126s/16行与1273.107552s/22行。只使用当时已经观测的15.715946429s/行、110.012397s写/下块读窗口、819.981605B/s写速率，以剩余112/106行、6个后续窗口和最后65536B写估算，总时长分别为3663.279252s和3678.996000s，均超墙钟帽。此复算支持合同内保守成本停止；它是验收期重建，不回填成原进程当时已经保存的两次ETA决定。

上述均是条件估计，含采样粒度、未完成行与部分写读窗口的近似；它们不是严格延迟下界，更不证明完整链一定只能在3686秒完成。原 `cost_stop.json` 只保存了最终单个ETA与速率区间；后续有效尝试宜随进度直接保存每次分阶段ETA、剩余工作量及触发判定，以完整留存“连续两个有效样本超帽”的运行时证据。本次不为补记录重跑、扩大预算或缩减固定B1/S128用例。

旧完整 top B2 pilot 的 `COST_STOP` 保留原身份：235.82s、172032 clocks、7426聚合握手、LN输出0B。约33/s的EMB阶段聚合事务速率与>7800s估计只能条件外推，不是LN实测吞吐下界。薄封装 `run_01` 的无可观测进度停止也不是硬件死锁证明；`run_02` 的idle高电平误计行完成是诊断探针问题，`compile_04`/`run_03`已改为接受start与单次完成配对，旧日志保留。

## 尚未关闭的覆盖与修改项

| 未关闭项 | 状态与影响 |
| --- | --- |
| 完整冷 B1/S128 前链 RTL | COST_STOP；完整raw逐位比较和全部131072项norm有限性/误差比较均未执行。raw全写覆盖也不能写成raw数值PASS |
| 17任务退休、HIDDEN1最终publication、HIDDEN0最终release、完整owner/spec/identity/coverage与全映射sentinel | RTL末态 NOT_RUN；helper CSim的PASS不能代替RTL末态 |
| STATE0最后输入R、STATE1最后输出B的指定hold，以及首次ap_done所有生产/observed端口和adapter响应债务 | NOT_RUN；只读入前三块、只写出前两块，尚未触及末笔hold地址，也未到首次done |
| RTL测试台末态owner/spec检查完整性 | **运行制品存在覆盖缺口；工作源码已修复，RTL重编译/运行NOT_RUN。** 本次封存的 `thin_mem_check` 核对state/readers/epoch/coverage/tag，但遗漏owner `max_claimed_epoch`、region/stage/layer/batch/row_space/row0/rows/width/content、request/generation高32位，以及部分output spec字段。若旧TB将来完成，也不足以关闭合同的精确spec/identity要求。Sol已按原400-word schema和既定期望在[工作TB](tb/frontend_chain_mem.c)补齐这些字段及global高位/valid/detail、owner slot和output spec断言；新SHA256为 `bc5f4c4a12f09abb4c32868003ebc1c468d86dd5b8e024eca2995558c483f9f2`，`cc -std=c11 -Wall -Wextra -Werror -fsyntax-only`通过。本审核已读取修复，但没有新的XSim编译或RTL运行；下一次有依据的尝试仍须重编译受影响测试台。当前run未到末态，此修复不推翻已成立CSim/静态展开，也不给当前COST_STOP增加覆盖或PASS |
| 全图逐连接的BO/offset/shape/stride/layer/epoch/lease精确审计 | PARTIAL_STATIC；当前80项结构记录没有逐一关闭双QKV shard、RoPE前后、KV/score/probability、GEGLU/RELU、Type、scorer→ACT/result的全部动态所有权与地址语义 |
| 真实Encoder QKV生产→RoPE→Attention、完整层和完整整网RTL | 未完成。旧预置Attention输入只代表原局部范围；整网保持NOT_RUN_COST。fe067真实GS32调度179–199 cycles与B2工作量给出527610943072–586561886432 cycles条件成本，远超40M帽，不是整网实测latency或新71532完整硬件的生成结果 |
| 71532新版完整HLS、整网RTL、暖reset、P&R/Fmax、平台shell/XRT link、上板、50ms | 均未验证；本阶段认可不授权新架构、预算、下一阶段或上板 |

交接时应把阶段表及其JSON投影同步到本次“已集中验收、部分成果成立、RTL成本受阻”的实际状态，明确fe067/71532各自作用域；目前表头/JSON的 `ACTIVE` 以及JSON薄封装scope残留的“static/XSim pending”已不符合本次已完成工作。此为记录同步，不改变既有原始结果。后续执行只在原授权和成本约束内进行；本次未发现可据以把完整链判成数值FAIL的结果，也没有足够证据把完整链判成PASS。
