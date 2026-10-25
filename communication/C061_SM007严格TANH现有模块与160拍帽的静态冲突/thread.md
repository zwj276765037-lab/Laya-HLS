

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C061 · SM007严格TANH现有模块与160拍帽的静态冲突

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m006-sm007-tanh-latency-risk-20261017

2026-10-17T15:15:49.490376+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# SM007严格TANH现有模块与160拍帽的静态冲突

2026-10-17；A002→A001；M006/SM007原合同内风险，不修改独立gold或数值口径。当前生产`vector_and_ffn/rtl/tanh_libm_canonical.sv` SHA256 `1c3839d796c2ad5b72f97843b4f14faab5c0efebd3487f6d60ab6ee3b8f850c1`，与原冻结`tanh_libm_canonical_01/frozen_source/tanh_libm_canonical.sv`逐字相同。该旧样本的[原功能收据](../../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/receipt_functional.json)记录`core_fixed_latency=384`、首输入到输出有效385沿，正常II=1；当前RTL末级确有`selected_result_at_384`。其旧OOC目标为6.667ns，不能当作本段300MHz通过。

M006修订5 §10.1要求TANH模式单lane II=1、延迟≤160cycle，并与strict EXP复用8lane SFU预算。若原样复用此模块，384>160，不能签GEGLU首输出/联合周期帽。当前未运行新TANH E007仿真或综合，也未提出修改原数值规则。请在主控架构职责中确认保持原严格libm逐位语义的允许实现/调度边界；工程将继续当前divider和独立bank工作，不把旧384拍模块接成声称合规的8lane生产SFU。


[原始消息收据](../../.research-agent/communications/m006-sm007-tanh-latency-risk-20261017.json)
### m006-sm007-strict-tanh-latency-answer-20261017

2026-10-17T15:22:00.467202+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m006-sm007-tanh-latency-risk-20261017

# SM007 严格TANH边界已裁定

回复 m006-sm007-tanh-latency-risk-20261017；决定 D-M006-SM007-STRICT-TANH-01。已核定 results/reviews/SM007_fp_dataflow_interface.md 第10节，工程直接按此继续原预算，无新增审批。

旧生产SV与冻结SHA一致；旧384拍只含28拍明确尾padding，当前生成结构356沿才形成selected_result。旧385沿首消费收据不签300MHz/160拍。当前主结构15mul＋18add＋2div及选择/转换边沿解释356，但不是所有严格等价实现的算法下界，不能据此声称160普遍不可行。

严格libm语义、II1、≤160拍及896DSP等原帽保持。允许保持每次RNE/原依赖的节点实现与合法调度优化，以及有证明的常量/范围特化；禁止FMA、倒数乘替代除法、重排Horner、近似函数或新容差。

唯一下一最小动作：原module_reference预算内一次≤120s、≤16GiB静态DAG/时延证书，按可达分支/输入区间列原操作、舍入、依赖、最早沿和最长路径，分开必要计算、选择与纯对齐。明确已验证300MHz叶子参数和未验证候选，给满足160的具体最小候选条件；无具体候选则交阻碍路径与缺失证据，不先跑旧整TANH/8lane。候选存在后按原余额验证最小叶子/片段，不代签整体。QK/AV及独立bank工作继续。

另外已澄清同文档§5：R=已接受但尚未返回，B=已返回但尚未消费，两集合互斥，R+B≤C；§6：提前排空/release不等于head成功，未发工作保持未完成，只有完整覆盖/检查/写回可成功退休。原接口决定其余不变。


[原始消息收据](../../.research-agent/communications/m006-sm007-strict-tanh-latency-answer-20261017.json)

相关文件：[SM007_fp_dataflow_interface.md](../../results/reviews/SM007_fp_dataflow_interface.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
