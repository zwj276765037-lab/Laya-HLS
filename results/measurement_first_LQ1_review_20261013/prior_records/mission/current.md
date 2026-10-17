# 当前工作：M004继续算术测量与优化

当前执行[D-M004-LNQ-MEASUREMENT-01](ln_quant_measurement_stage_20261013.md)。[LQ0集中审核](../results/measurement_first_LQ0_review_20261013.md)已接纳AT014原冻结16行LN→真实store→Q/fullA数值与周期基线：全TB659334，LN run读算写包围区间649380，Q接受→实际消费3267。全部原独立gold、实际存储/lease/末B/零债务保持。

LQ1唯一候选继续同口径RTL比较。AT015已生成，源仅最终normalize循环增加II1 pragma；实际报告II2、循环估计2049cycles，top时序估计slack -48.76ns。主机C++对照/生成成功不证明RTL收益或时序可实现；工程交付实际数值/完成周期及资源、II和时序代价后集中取舍，不为普通修复新增审批。

## 已完成的有限判断

- Down KB1保留：完整PS/4096F32通过，cfg→actual consume减少23.30%，全冷减少10.06%；KB2重复成本停止退出本轮，无完整样本，根因未知。
- CT0原32项owner薄表host/HLS/generated RTL有限PASS，本轮保存收束；不扩CT1，不作LN/Q前提。
- LQ0覆盖checkpoint前16×1024，不是完整S64请求。649380包含读算写，valid&&!ready小计不能当作全部等待或可消除成本。

下一可见出口是LQ1同fixture/gold/AXI响应与实际完成边界的数值、cycles和代价对照。原[测量优先重排](hardware_measurement_replan_20261013.md)保持。A002唯一实现/工具owner，现有helper复用，不新增agent。代码E002/experiment、证据E005/R001；原单重工具/全部帽/G仅OOC余额/5172s不重启，无新OOC/P&R/上板/预算。

M003整体executor/冷INIT、CLOSE/rearm/cleanup继续停排，旧证据和未完成义务保留。M003仅约束最终生产集成验收；M003/M004、完整请求、恢复与联合资源尚未完成。
