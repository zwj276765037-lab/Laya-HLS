# 硬件指标：层级和身份

LQ1R AT017进展：AT017第一版仅新增两项BIND_OP，31冻结源中仅normalize文件改变；主机对照/HLS生成通过，注册映射已生效，但实际II9、循环估计9224、slack−0.43ns。State7减末级2.976ns+乘首级2.322ns=5.298ns，超过4.867ns有效预算，RTL未运行。剩余第二版按原合同只把减法约束增加一级，乘法/数值/时钟保持；若仍违例即结束，不第三版。原LQ1的19.87%不能继承为新修复收益。 单topHLS估计BRAM18 29/DSP18/FF20136/LUT48112/URAM0；101.160436s为工具墙钟，无新RTL周期或物理时序结果。

[LQ1数值/周期审核](measurement_first_LQ1_review_20261013.md)：16行冷诊断全TB659334→528307（−19.8726%）、LN run649380→518354（−20.1771%，含读算写），Q实际消费区间3267→3266、fullA512不变。全部原16384 LN F32/16384 INT8/512 FP16 gold通过，三向DDR196608B保持。AT016 static/pilot/full墙钟76.130073/46.903216/622.945862s为工具成本。

HLS实际II2、slack−48.76ns；新增F32减/乘native IP C_Latency=0、无ACLKEN，调度同状态路径53.626ns。LQ1仅保留周期候选，原LQ0仍有效；下一LQ1R按原时钟目标恢复注册运算映射，结果NOT_RUN，不外推部署收益。单top估计BRAM18 29/DSP18/FF19804/LUT48104/URAM0；物理/联合资源UNKNOWN。

[LQ0验收](measurement_first_LQ0_review_20261013.md)：原16行全部独立gold通过，全TB659334，LN run649380（包含真实读算写）、Q接受→实际消费3267、fullA回读512；三向DDR196608B。实际外部反压小计不能代表全部等待。AT014 static/pilot/full墙钟76.867212/56.399040/735.843213s为工具成本，无新硬件加速结论。

LQ1 AT015源仅normalize循环II1 pragma；HLS实际II2、循环估计10249→2049。top估计BRAM29不变、DSP13→18、FF19765→19804、LUT47775→48104、URAM0；报告slack0.00→-48.76ns，不能由cycle估计推导可部署收益。AT016后续数值/周期已验，见本页最新条目；物理时序/联合资源仍NOT_RUN。

CT0有限出口：[原helper/生成/RTL审核](measurement_first_CT0_review_20261013.md)。normal131诊断事务/73429cycles，负例各9/5073；HLS154.488848s和RTL full8.299239s是工具墙钟。32×5009bit逻辑表，HLS估计8BRAM18/1DSP/49533FF/39937LUT/0URAM，物理映射/联合资源UNKNOWN。LQ0已由AT014实测，以下原659334与新基线同边界；均不可当纯计算延迟。

KB2更新：two-64候选full/诊断3次COST_STOP，未取得完整性能样本；不得将pilot周期或末条cycle33397当完成延迟。KB1已验收益保持；CT0后续有限出口见本页更新。[停止核定](measurement_first_KB2_stop_review_20261013.md)。

2026-10-13[KB0/KB1同口径实测](measurement_first_KB1_review_20261013.md)：四行Down/K2624/N1024、预量化A、bias0冷样本，全部335872 PS/4096F32通过。cfg→first done21100→16183；cfg→actual consume21107→16190（-23.2956%）；全冷TB48864→43947（-10.0626%）。A666/W27064保持，AW/W/B512→256，16KiB有效输出保持，物理写32→16KiB。6段guard串行/95实际policy核实，主控未运行DUT。1923bit额外pack字段不是物理资源，LUT/FF/RAM/时序UNKNOWN；旧错误窗口/生产整链未验。

当前profile的W服务最优下界26239cycles，reader独立优化理想余量最多825cycles；首AW固定时输出间隙乐观界319cycles。仅为有条件上界，不能报为实际收益。KB2已因重复成本停止退出本轮，无有效完整数值/周期样本。

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
