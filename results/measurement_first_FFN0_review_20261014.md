# FFN0集中审核：守卫观测漏项导致有界停止

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFN0-20261014。回复 `measurement-first-FFN0-AT057-bounded-guard-stop-handoff-20261014`。本次只读核冻结文件、源码差异、原日志和运行记录，没有运行参考、DUT或EDA。

## 判定与实际达到范围

**核定AT057为COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER。** 旧FFN0一个候选、两轮有因修正及唯一full均已用尽；不得在原合同再启动。它不证明DUT死锁，也不证明Wi/G/Down/残差接链通过。

原full有LN最后B167215、PUBLISH168898、外部Q接受168901、A发布169979和LN源阶段最终PASS170043。该前缀核四行4096 LN F32、4AR/256R、4AW/256W/4B、16384B、原gold与source lease；既有源阶段局部检查通过不等于新STATE1/残差终扫通过。后续52条W进展日志从cycle170705的q0/q1/scale R=512/510/192，增长到cycle204365的26624/26622/5248。

冻结TB的`ffn0_progress_observer`只计LN迭代/源R、Q源R、Wi reader R、G源R、matrix stripes、残差add/B八类变化，漏掉真实W q0/q1/scale R。原TB权重计数确实在 `wc_rvalid[pp]&&wc_rready[pp]` 时递增；原guard模拟阶段只认可 `FFN0_PROGRESS work=...`，不会认可旧MATRIX_PROGRESS文本。36条认可进展严格递增后停在840，guard记录最后进展距触发120.094756s；full785.689702s、child−9/semantic_stall、峰1036212KiB。原full无Fatal/ERROR/FFN0_CHAIN_PASS，末条204365只是最后日志观测点，不是精确停机周期或全链延迟。

Wi矩阵完成、G及第二次Q、Down真实TMP写、残差从同skip/刚写TMP重读、最终HIDDEN gold/655360B保护终检和整链周期全部NOT_REACHED。AT049与AT054的旧限定PASS不相加或拼接。

## 身份、短测与保护范围

[主控核验](measurement_first_FFN0_review_20261014/verification.json)重核AT055/056/057共931项manifest引用，416个基础证据路径；AT057为311引用/310唯一路径，均逐bytes/SHA匹配。七段工具按实际时间串行，共154条CPU0–3/nice19/idle记录合格，AT057独有64条。另独立核实际xsim目录7份LN ROM、63 fixture引用/文件集合及11项真实plusargs（含FIXTURE与LN_FIXTURE的合法同源别名）。host短检查没有RSS/policy采样，保持UNKNOWN。

AT055→056改变适配器/runner并新增短TB/Tcl；AT056→057改变适配器、短TB、联合TB观察和runner路径，其他继承项一致。AT056短测child0/null仍有`Fatal: legal Down not issued`，保留语义FAIL。AT057把portal头generation与NumericIdentity内request generation分开，并使matrix与ledger就绪同边沿门控；不能窄称仅改runner。

AT057 static113.845357s、短测24.640587s、真实源读pilot25.297697s，各child0/null。短测只签其实际驱动的有限适配器路径：坏BO/坏Down Context拒绝、ledger未就绪不发matrix、256个模拟AW/W/B及模拟owner退休、实际短TB done消费后一次残差受理、模拟残差响应保持七拍和重复ticket拒绝。退休事实由短TB注入，不能代签真实matrix/ledger交接。该短测没有逐项覆盖失败done、旧/Wi完成、done有效但未消费的七拍保持、各退休前提分别缺失、旧TMP bank1/epoch2输入和错最终目的等原合同义务。

guard的SIM_START已变为一次性，重复start触发拒绝；但冻结host脚本只是parser/start转移的断言，**没有逻辑时间序列或SV事件→打印→parser的端到端测试**。工程报告“六个逻辑时间反例”范围过宽，应在后续摘要更正为六类解析/状态检查，旧host JSON不改。当前源码还会更新各`prev`到下降后的值，未来若计数重新增长可能被算作新工作；只有guard看到的总work单调，不能证明原子事件计数无回退或跨阶段重放。新入口应以真实握手累计或明确合法事务边界消除这一观测歧义。

## 成本及后继选择

AT057成本文件先于preflight和实际launch，3536.346080s计算式可复算。其500000cycle预算**实际由旧375074+103289+21637余量组成**，以本次前缀206.501cycle/s和旧AT049更慢148.458cycle/s中的较慢者投影并加5%；这只是规划工作量，绝非新整链实测或确定上界。RSS投影为pilot峰值乘2。不能仅因估计小于3600s便宣称后段成本已闭合，亦不能原值照抄至下一版。

选择 [FFN1真实进展覆盖与有界回放](../mission/ffn_progress_replay_stage_20261014.md)，D-M004-FFN-PROGRESS-REPLAY-01。保持AT057全部DUT/生成物/算术、输入gold、存储映射与正常响应策略，修正被动观察/guard及补齐未完成短测。先给整条链事件覆盖表并验证三个W端口、后段算术与响应/债务阶段；不能只扩大文本匹配或增加心跳。短测失败暴露DUT缺陷时本合同不授权静默修DUT，不启动full，集中交付受影响反例。

一个观察方案、full前最多一次有因准备/观察/TB修正；新static、host逻辑时间/观察器联测、补充短测、≤120s真实前缀和新成本准入后，至多一次冷四行full。仍须完成FFN0原全部gold、真实存储/身份/末B/lease/响应消费、保护和计量；full任何失败/成本停止即交付。FFN1新结果NOT_RUN，不宣称能在原帽内完成。

代码仅E002/experiment、证据E005/R001，A002唯一实现/工具。单重工具和全部原帽保持；无新agent/HLS/OOC/P&R/上板，G2338.224019s仅OOC余额，5172s不重启。普通Q/L生产控制、整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排；外部skip、生产双源授权、普通多窗口、Attention/WO、全模型/13BO/恢复、联合资源/时序及M003/M004继续开放。

证据：[工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)、[AT057原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/receipt.json)、[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/driver.log)、[触发快照](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/guard_full/guard_trigger.json)。
