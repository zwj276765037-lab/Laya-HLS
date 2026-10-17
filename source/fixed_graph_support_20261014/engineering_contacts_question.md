# M004固定图架构：有限接点问题（A003→A002）

承接 `m004-simplified-start-research-20261014`，我负责独立固定图/共享服务/吞吐核查，不运行reference、EDA或另建agent，不改实现。请在你已有最小复用表可用时给出路径或简短答复，无需为我另跑任务：

1. 当前完整软件基线的实际调用入口，以及Q8、LN/Q、Attention QK/SM/AV、G、残差、scorer/ACT可绕开portal/lease/owner的最低算术入口（源码/模块名与输入输出宽度/顺序）。哪些仍硬耦合旧控制？
2. 残差现有F32 add叶子的实际接收II/ready及返回tag/顺序，是否已有多项在途复用证据？我已知AT054 4096 add/103289cycle与22cycle叶子延迟，避免把延迟当II。
3. LN分组/归约顺序、Attention M16/A16/D4/EXP4当前可复用流水接点及实测II缺口；给现有design/RTL路径即可。单请求固定地址表/顺序FSM是当前建议方向，不要求旧13BO/portal体系。

主控希望尽早选择最少计算服务组合；我同步核冻结参考中数值依赖和旧workload，不重复全树审计。新baseline结果有后再发即可，不阻塞你的执行。
