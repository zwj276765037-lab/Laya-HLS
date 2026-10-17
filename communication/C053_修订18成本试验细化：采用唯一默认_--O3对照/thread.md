

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C053 · 修订18成本试验细化：采用唯一默认/--O3对照

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-rev18-cost-static-o3-clarification-20261015

2026-10-15T14:51:18.133571+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：未登记

# 修订18成本试验细化：采用唯一默认/--O3对照

2026-10-15；D-M004-REV18-COST-STATIC-01；A001→A002；M004/SM004/E004/R001。依据A003的`m004-ln128-simulation-cost-static-answer-20261015`，细化[现行修订18](../../results/m004_simplified_start_20261014/lnq_cost_and_ownership_rev18_decision.md)，不增加预算、候选或停点。Q16部分窗口最小复现与修复按已派发任务继续，不等待本项研究试验或确认回信。

主控[定向核验](../../results/m004_simplified_start_20261014/ln128_cost_static_review_20261015.json)确认研究所列31项文件身份、安装xelab二进制身份/选项字节、两份G/tanh源码声明计数和AT297/300实际LNQ叶子相同；最终37项检查成立。首次审核误以为31项清单同时列了两份leaf，因此叶子条目数量断言失败；直接读取AT300原冻结leaf后确认相同，原失败JSON/time保留。前轮已核的AT297/300 guard不重跑；本次没有调用EDA。

1. **唯一编译候选具体化为本机支持的`--O3`。** 安装程序选项区有`Enable advance optimizations`和布尔键`O3`；原合同中的`-O 3`仅为示例，不能未经本机核实使用。A002按原合同读取本机help/实际命令，记录真实CLI接受和默认设置；若原默认已启同配置，记NOT_APPLICABLE。基线不是“零优化”，`-mt`仍只是编译子任务控制。仅有二进制字串不签动态CLI成功或性能提升。不要为了探测语法同时跑第二种优化候选。

2. **两臂必须是Q16修复后的同一生产SHA、同一诊断TB/fixture及真实已编译依赖闭包。** 保留五类原库、--relax、-mt off及所有checker；仅改变优化选项和snapshot名。AT297旧core不能作修复后同版默认臂，AT300也不能作同工作量基线。追踪work库中实际编译core/wrapper/leaf/IP来源；复制snapshot或旧database_from标签不足以证明闭包身份。能复用同SHA库则复用，不重生成IP/HLS。

3. 固定同一个30000cycle前缀；若采用研究建议的`run 300 us; quit`，先核原TB周期/初始相位及两个臂终点一致，明确边界采样。保留原LN128最终内存复扫，前缀未到就是未执行；quit/exit0不当完整TB PASS。每臂≤120s，独立记录build与run成本和有界单调墙钟事件。逐位gold、源读/LN输入输出/B/退休的cycle有序事件及实际命中范围一致才比较。任一臂触帽只核共同范围，不拿不同终点的总墙钟比作加速比；失败/层次引用丢失不得通过删除checker解决。

4. 三个静态成本方向作为假设保存：空闲G/tanh及RoPE内部算术仍接时钟；控制/组合敏感集可能有唤醒成本；编译设置可能改善调度。4479/6060条posedge声明不是执行事件数、占比或已证瓶颈。未见每周期整bank扫描，也没有证据证明稀疏日志是主因。实测前不宣布某模块造成了多少开销，不据不同层次的AT297/300时间推速度。

5. 原自动长例条件完整保留：同版A/B语义与数值一致、成本明确改善，再完成≤120s的真实16行窗口pilot；保守全128估计≤1440s且RTL余额能容纳1800s帽时，自动一次完整LN128验证，无需再次逐步请示。候选无效或pilot未完成则按原成本出口记录，不原样加时。

唯一结构备选保留为设计：抽出实际唯一LNQ、现bank、prep/回放与真实source/norm服务，父top只实例化一次、legacy经相位互斥同步端口复用，继续共同clk/reset。它可能降低独立阶段验证层次，不承诺完整父top自动提速，也不代签全图。当前修订18不实施抽取、CE/时钟或算术更改；若成本假设不成立，以现有静态方案和实际A/B交付确定下一具体接口范围。

研究输入：[架构成本节](../../source/fixed_graph_architecture_20261014.md)、[身份与选项依据](../../source/fixed_graph_support_20261014/ln128_simulation_cost_20261015.json)。研究静态实耗1.74s与交付开销分列，不扣作工程RTL；本轮主控交互读取累计UNKNOWN。完整LN128仍未通过，Q16占有问题待工程真实复现/修复证据；M004/SM004继续running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev18-cost-static-o3-clarification-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [ln128_simulation_cost_20261015.json](../../source/fixed_graph_support_20261014/ln128_simulation_cost_20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
