# 当前工作：M004继续算术测量与优化

当前执行[D-M004-LNQ-MEASUREMENT-01](ln_quant_measurement_stage_20261013.md)：复用原冻结16行LN→真实store→Q/fullA，先取得LQ0周期分解，再依据实测选择最多一个同口径LQ1候选。新结果NOT_RUN，工程已收到合同，实际启动由工程报告。

## 已完成的有限判断

- Down KB1保留：完整PS/4096F32通过，cfg→actual consume减少23.30%，全冷减少10.06%；KB2重复成本停止退出本轮，无完整样本，根因未知。
- CT0本轮已接纳：原32项owner/5009bit表的helper对照、薄HLS与generated RTL有限PASS；正常131事务及两个9事务负例，原较窄释放规则保持。生成/模拟可行性得到局部支持，生产控制延迟、物理资源及整链未验。
- CT0保存退出新增队列，不扩CT1/完整控制链，不成为LN/Q测量的前提。[集中审核](../results/measurement_first_CT0_review_20261013.md)。

## 下一可见出口

LQ0保持16×1024真实输入、16384 LN F32、16384 INT8与512 FP16独立gold，Q实际重读LN写回；报告配置/LN/END与lease/Q/fullA实际事件和互斥阶段、重叠等待。原659334仅历史全TB周期，不当纯算术时间。LQ1仅在实测和服务下界支持时开展，不减TB等待或跳过存储制造收益。

原[测量优先重排](hardware_measurement_replan_20261013.md)持续有效。A002唯一实现/工具owner，现有helper可复用，不新增agent。代码E002/experiment、证据E005/R001；原单重工具/全部帽/G仅OOC余额/5172s不重启保持，无新OOC/P&R/上板/预算。

M003整体executor/冷INIT、CLOSE/rearm/cleanup继续停排；旧证据和未完成义务保留。M003仅约束最终生产集成验收；M003/M004、完整请求、恢复与联合资源尚未完成。
