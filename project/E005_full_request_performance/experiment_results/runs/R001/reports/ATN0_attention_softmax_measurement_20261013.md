# ATN0：Attention v10 softmax 有限计量

2026-10-13；M004/SM005/E005/R001；执行合同 D-M004-ATTENTION-MEASUREMENT-01。AT020 在本项目复制树中核对原 v10 的 93 份冻结源、原 fixture 全部产品及中间 gold SHA，派生差异只有观察 TB 与要求计量终态的 runner。DUT、M16/A16/D4/EXP4 算子、输入、数值与 CE/命令策略未改。AT019 的固定 ASUB 事务数观察断言失败独立保留；其 16 行原数值 tile marker 曾通过，但不追认为 AT019 终态 PASS。

AT020 static、16 行 pilot 和单进程连续 128 行 normal full 全部通过。完整 enc0/head0 B1/S128、K128/D64、72 有效 mask，原 Q/K/V 与独立中间/最终逐位 gold 保持。完整 head 的 M/A/D 语义项为 2129920/2146176/16384，QK product/tree、AV each-key 与 EXP 检查分别为 1048576/1032192/1048576/16384；真实命令 accepted=retired=191088、cancelled=0。full guard child0、trigger null、499.307597s、peak owned RSS 1109036KiB；static42.483280s、pilot67.855530s，均低于原分类帽。

| 同一 normal 128 行边界 | ATN0 真实 cycles |
| --- | ---: |
| 全 TB（含配置/装载/读回） | 1608896 |
| 原配置与加载计数 | 140288 |
| QK cmd19 接受→首次 done / 实际 consume | 250888 / 250912 |
| softmax cmd20 接受→首次 done / 实际 consume | 287173 / 287197 |
| AV cmd21 接受→首次 done / 实际 consume | 66256 / 66280 |

每个 tile 的正常命令首次 done 到真实 consume 为 3 个 wall/enabled 边沿，表中三类命令各有 8 次。QK+SM+AV 首次 done 口径合计604317cycles，与同 v10 历史结果一致；工具墙钟不当作硬件收益。正常过程无故意 CE 暂停，所以本次 wall/enabled 命令区间相同。全 TB、加载、读回与计算口径分列，不相加生成伪加速比。

softmax 的 287173 个 enabled 边沿有互斥状态账：SM_MAX 2176、SM_EXP **270525**、SM_TREE 8576、SM_DIV 5888、接受/报告 8，精确和为287173。EXP 占 softmax 94.20%。实际 ASUB A 请求/退休各16000笔，TREE各1408笔，DIV请求4096笔/返回16384 lane；ASUB 不能按四 lane 固定推算。观察到 EXP 有空闲 worker 且仍有 key 时，A 信用阻塞与其它未发射边沿均为0；TREE A 信用和 DIV D 信用阻塞亦为0。这些只描述该 normal profile，不能把原跨模式 M/A wait 全算为可优化停顿。

四个 EXP worker 实际 launch/done/commit 分别为4102、4155、4041、4086次，均逐 worker 配平并合计16384。仅在本次 SM_EXP 状态内，每个 worker 的 input-wait/core-busy/commit-wait/idle 四类边沿之和都等于270525；四 worker 合计为147456/898680/17143/18821 slot-edges。由原四个 EXP core 的实际服务占用得到条件算术下界 ceil(898680/4)=224670 enabled edges；与当前 EXP 状态270525相差45855，**只是乐观可压缩空隙上界，不是可实现收益**。当前最长单 worker core-busy为225172；不同 worker 的等待可重叠，四类 slot-edges不能直接当 wall 周期相加。实际 launch→done histogram仍有1/78/89/97的原路径差异，不能把EXP视为II1。

下一唯一 ATN1 假设是将同一行 ASUB 输入准备与正在执行的 EXP worker 适度重叠，保持原 F32减法、EXP次数/延迟、数值顺序、bank/队列容量、首错/CE/reset及唯一提交。先核现有队列/寄存器是否能承载候选，不以“45855”预签收益；新增小量候选状态计入逻辑资源账。若不能在合同内保留全部原语义，给出 no-op 判断。本模块没有 AXI master、物理末B或完整13BO请求；OOC仍沿原 COST_STOP，不启动新的物理工具，M003/M004未完成。

原始证据：[AT020 receipt](../attempts/AT020_ATN0_attention_measurement_02/receipt.json)、[full计量JSON](../attempts/AT020_ATN0_attention_measurement_02/full_01/measurement.json)、[full原始日志](../attempts/AT020_ATN0_attention_measurement_02/full_01/simulate.log)、[冻结清单](../attempts/AT020_ATN0_attention_measurement_02/source_manifest.json)、[AT019失败](../attempts/AT019_ATN0_attention_measurement_01/receipt.json)。物理资源/时序及全请求为 UNKNOWN。
