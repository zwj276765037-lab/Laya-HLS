# 硬件指标：层级和身份

当前[测量优先阶段](../mission/hardware_measurement_replan_20261013.md)启用局部KB0/KB1标签；以下继承数值只作入口依据，不是本轮新测量，也不是完整请求B0。新周期/瓶颈/资源代价由E005/R001原始证据更新。

以下是继承的限定结果，不是新目录重跑或整网性能。当前最终模块数据以[阶段表](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md)和对应receipt为准。

| 指标 | 继承事实 | 限制 |
| --- | --- | --- |
| 旧32bank cache装配 | 384URAM / 224 BRAM tiles | 该装配身份，不能直接加到新全图或证明fit |
| 原G51整row OOC | 176828LUT / 299253FF / 48DSP / RAM0 | row/control 256419FF；新三bank已功能通过，父OOC成本中止，不能沿用旧账称改善 |
| G51不变算术子树 | 95754LUT / 42834FF / 48DSP，51 FP位置 | 精确导出算术子树，非新父完整映射；tanh已包含，不能重复计费 |
| quant16真实Wi/Down行 | 141 / 341cycles | 流式服务限定输入；不当完整请求耗时 |
| syncPS | F_PS_min37，接受gap1..3 | 不能取最小gap1声称持续II1；真实四row完整Down独立中间值通过 |
| 驻留Down完整局部链 | 48862cycles；10496stripe/335872lane-group PS、4096 F32输出/512真实AW/W/B通过 | A来自预量化fixture；strict W仍83968scale checks；bias_kind0旁路，无G/quant seamless或13BO证明；非完整请求 |
| 新Attention v10真实完整head128 | 正常QK250888＋SM287173＋AV66256＝604317cycles，旧基线6816248 | 约11.279倍模块计算改善，enc0/head0/B1/S128限定；协议另在tile16_03同身份验证，非完整加速器性能 |
| 频率/带宽/请求吞吐 | 未测 | 150MHz是条件；无U55C、无P&R/Fmax、无完整物理13BO请求计时 |

性能改进按同输入/缓存/反压/计时口径，分别记录冷暖首延迟、完成间隔、填充排空、供数/反馈/输出stall。综合WNS与条件cycles÷150MHz不可写为板端Fmax或实测延迟。

## 2026-10-11工程验收后的解释边界

[工程验收报告](../project/E002_Laya_HLS/experiment_results/engineering_acceptance_20261011.md)及[主控重规划](controller_replanning_20261011.md)确认：本轮无新性能/资源实验，以上数值仅按原身份保留。当前G父与Attention OOC均COST_STOP；G原累计已用1261.775981s、余2338.224019s不重置。resident当前OOC/联合fit未验证；旧G父176828 LUT已包含95754 LUT算术子树，不重复相加。

resident的48862cycles来自预量化A、kind0 bias和初始reset局部链，G桥59975cycles使用冻结Wi输入；不可相加为完整请求耗时。Attention head128正常PROTOCOL=0，首错/CE/reset来自同manifest tile16；11.279259倍仅同fixture模块计算改善。当前完整请求冷暖、完成间隔、填充排空、实测Fmax与板端吞吐均NOT_RUN。

新M003只建立真实连接、当前回归和服务/资源缺口账，不新增OOC或声明端到端加速比。
