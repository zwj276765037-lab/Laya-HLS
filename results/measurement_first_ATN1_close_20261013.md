# ATN1限定保留，转GQD0真实算术连接

R-SM005-ATN1-CLOSE-20261013；2026-10-13；M004/SM005/E005/R001。回复`measurement-first-ATN1-final-handoff-20261013`，同时处理工程G→量化→Down接点与字节身份补证。

**集中核定：保留ATN1为已通过正常完整head及同DUT受影响协议验证的有限候选，本轮Attention调度阶段收束。下一阶段执行D-M004-GQD-INTEGRATION-01。** 不宣布生产采用或物理时序通过；没有第二Attention候选或新物理工具。

## ATN1核定结果

AT021原完整enc0/head0/B1/S128、128query/K128/D64及全部独立中间/最终逐位gold、M/A/D/EXP工作量保持。SM首次done287173→265084（−7.6919%）、实际consume287197→265108（−7.6912%）；正常QK+SM+AV首次done和604317→582228（−3.6552%），全TB1608896→1586807（−1.3729%）。各净少22089cycles，QK、AV、加载与done保持策略不变，四worker core-busy898680 slot-edges不变。ATN0条件空隙45855未被当成收益；新预备状态改变worker input_wait含义，按真实端点判断。

AT022 DUT与AT021同SHA `11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`，仅协议TB/runner改变。原log真实命中pending=1/ready=0和pending=0/ready=4，各对含11个新增字段的完整状态快照在CE低连续8拍保持，随后reset清空所有准备值/key/count/cursor/pending。原M/A/D/EXP活动覆盖和六首错bad_element/前行分数与原tile16_03一致，pending-Q CE/reset、错epoch/row、合法重载与chain检查保留。账本210966=210960+6；末尾同进程16行原数值、products131072/trees129024/AV131072/EXP2048通过。协议全TB1189951含额外负例与reset，不与normal full比较性能。

正常排空接受为有界源码不变量加动态佐证：一批预留后才能返回，真实A退休保存完整key，按空闲worker唯一分发，当前worker持有key到唯一EXP提交；接受lane总数不超过S，每次提交只增一次exp_written，第S项提交才能换行。该关系下正常行完成无剩余准备债务；源码没有把额外重复任务隐藏在完成条件外。独立全key数值及定向CE/reset支持本候选，**不是内部所有槽逐边沿形式证明或完整恢复证明**。新增179bit持久状态含数据，组合仲裁及物理FF/LUT/Fmax/联合资源UNKNOWN。

本轮继承已核AT021原始数值身份，只对新终态/协议及接点作定向核验。两份93冻结源、AT022 47项snapshot/实际静态副本、原log/收据一致；合并5段guard串行、63实际policy合规。AT022真实226.536195s、peak955724KiB、child0/trigger null；AT021 full482.110123s为工具成本。共435个当前文件引用核验，旧AT021 live后处理collector有一项已声明身份漂移：当时a7ee8c…已在进展审核实核，当前为协议增强f2ccd8…；它不在93份冻结DUT输入中，旧raw/numeric/measurement均未变。保留此历史live引用差异，不改旧收据、不要求重跑。

## 下一阶段决定

工程两份接点补证与主控定向核验一致：G桥04的独立q.mem/scale.mem与AT002 KB1对应期望逐字节同源，4行×82组匹配。下一任务选**GQD0四行真实G→GATE AXI写入/重读→量化→同一dualA→KB1 Down连续链**，详见[完整执行合同](../mission/g_quant_down_integration_stage_20261013.md)。

保留原Wi输出作为明确声明的外部输入，原权重/metadata照实加载；移除Down的TB预量化A注入。GATE/q/scale/PS/结果必须全部来自真实DUT，在同进程且链间不reset；诊断driver可以发既有命令，不能伪READY/数据/退休。G与Down原算术/容量/gold/接口债务及KB1 writer保持，必要有限接线和等价适配按既有授权连续实现。

先产出新接链基线和实际交接/末B/lease/完成计量，不将旧59975与43947cycles相加当结果；不再本轮追加局部算术候选。保留原末B反压/身份拒绝检查，未变叶子按身份复用；不因这条有限接线恢复完整生产控制。GQD0新结果NOT_RUN，若在原帽内不能成立，交具体阻塞及已到达边界，不缩小目标或加帽。

A002继续唯一实现/工具，普通static/pilot/full及有据受影响修复无需新审批。请直接沿新合同推进；阶段完成或实质阻塞再集中交付。A002此次交付虽state仍running，其字段明确本阶段normal/protocol已完成、runtime=null；这与“工程会话仍可继续”一致，不以终态审核强停会话。

KB1保留；KB2/CT0收束；LQ0/LQ1限定事实保持，LQ1不生产采用、LQ1R关闭。整体executor/FullRuntime、冷INIT、CLOSE/rearm/cleanup仍停排。原单工具/资源帽、G2338.224019s仅OOC余额、5172s不重启及无新HLS/OOC/P&R/上板保持；M003/M004、全模型/13BO/完整请求/恢复/联合资源仍未完成。

证据：[主控终态核验](measurement_first_ATN1_close_20261013/verification.json)、[ATN1工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md)、[AT022原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/receipt.json)、[前次normal审核](measurement_first_ATN1_progress_review_20261013.md)、[GQD0执行合同](../mission/g_quant_down_integration_stage_20261013.md)。
