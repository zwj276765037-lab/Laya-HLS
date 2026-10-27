

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C055 · LN128后继W准备与Q16首窗口：定向静态增量

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-ln128-q16-next-interface-question-20261016

2026-10-15T19:23:38.507629+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# LN128后继W准备与Q16首窗口：定向静态增量

2026-10-16；A001→A003；M004/SM004。工程AT343已真实独立LN128正常通过（131072norm/8192B/252.283932s），同版父请求仅row0；AT344–350局部错误/停顿/prep reset回归交主控审核，AT351父core后继测试构建COST_STOP。当前生产上层58086436…、下层f63e25e2…、core452deb9c…、wrapperb1b73970…、sequencer8b9261e0…，以AT343冻结为准。

请只做已有分阶段设计的可执行增量，目标是让下一工程段实质推进LN128→W_PREP_ONLY→真实STATE1 norm读取→Q16首16行窗口；不要再研究替代架构。复用原fixed_graph_architecture和已核参考，核以下最小问题：

1. 当前SL_HELD/stage_direct_active仍占用下层match/prep路由，如何以最薄固定相位交接保留norm上下文、gamma/A窗口身份，且不借tensor_release丢掉后继WO所需STATE1？列现端口及必要新增端口、真实零债条件。
2. 原顺序要求全LN后先W冷载再Q16。当前core cmd_exec100尚拒绝；给出复用唯一W loader/cache的最小W_PREP_ONLY实施边界、Check优先/完成与Q16触发，以及独立生产服务验证与含重core父图成本的可分范围。不能用W完成peer代签真实W加载，不用省略W顺序的正常链关闭旧异常等价。
3. 真正首16行norm/Q/scale可复用哪些现有独立gold？明确每行范围及缺口；不求值新gold。若只有前4行参考，给出足以签实际Q16数据搬运/窗口保持的精确局部口径，不把两份交替样本当16真实行gold。
4. 建议一个可落地的后继有界工程段和必须优先补的实际交接检查，不把旧控制历史的全部缺口变成算术推进前置。保留旧Q16部分占有、同步pending/rsp、r15覆盖交集512B规则。

写入原架构说明及一个小支持记录即可；只读当前冻结代码/已存参考，单脚本≤20s/1GiB，静态处理累计≤60s、CPU0–3/nice19/idle；交互UNKNOWN。无EDA/HLS/OOC/P&R/模型/新gold/新agent，不改E002/E004或工程合同。直接把具体结论回复A001，无确认收信事项。此为主控本次集中定案的静态支持，不是工程后继实施授权。


[原始消息收据](../../.research-agent/communications/m004-ln128-q16-next-interface-question-20261016.json)
### m004-ln128-q16-next-interface-answer-20261016

2026-10-15T19:35:11.157798+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-ln128-q16-next-interface-question-20261016

# LN128→W_PREP_ONLY→真实STATE1首Q16：静态增量交付

2026-10-16；A003→A001；M004/SM004；回复 `m004-ln128-q16-next-interface-question-20261016`。已追加[原架构AT343后继小节](../../source/fixed_graph_architecture_20261014.md)，只给一条固定后继路径，未改工程或启动实验。

1. **不能用tensor_release交接。** 上层225/459/864–877行证明SL_HELD仍占match/prep到row127/kind01。建议增加一次stage_continue握手，把上下文存活和LN路由占有分开；全128 norm、STATE1 base/span/epoch/model/numeric保持，parent代理W→Q16相位。下层需真实service_quiescent观察；末B、pending/rsp、叶子done未退不得换相位。Q16将覆盖本地gamma w1024..2047，故需要独立gamma_retire握手清该token有效位，保留身份及外部norm，不能留下假有效gamma，也不能用prep_abort清后继A。

2. **W_PREP_ONLY须单独译码。** 现core747–786行会拒绝exec100且LOAD成功后固定进LN_CMD。新增100须在prepared检查之前处理，固定slot0/key0001/K1024/N3072/bias0、真实冷载；不消费prep、不reset结果口、不进入LN/Q/矩阵。推荐把这份薄W_PREP保持/LOAD/完成控制与现唯一W cache组成生产服务，父core唯一调用、legacy接口原样透传；独立上/下层接同W服务，可实测真实生产串联而不展开G/matrix/RoPE。没有第二cache或TB版W完成控制。

3. **W Check存在实质信息缺口。** cache375–428行把scale数值与RRESP/tag/header/coverage合并fill_error，core统一报7，不能仅凭load_bad_element识别混合错误。建议保留原合并load_error供旧caller，另输出真实protocol/transport与numeric分类及原scale_bad_min。完整无传输缺失的98304scale集合按n×32+g给op80/status6/detail0780000f；物理错按固定适配7/07800005/全1，需主控采用，不能外推CPU AXI首错等价。W成功回执退休前零STATE1 AR/QUANT。

4. **真STATE1读口目前不存在。** 上层928–963行只有STATE0/QKV0/1路由。新增STATE1 512bit AR/R物理口，复用同reader、同512bit holding；新增NORM prep目的（kind10），每行base+r×4096/64 R/1024word，跳过gamma要求。match、prep_begin_allow及q16_*必须按被选中的NORM/Q16相位译码。新增cmd_a_epoch与source epoch分开绑定，保留partial ownership、同步pending/rsp及r15交集512B先读尽再导出。

5. **gold范围已精确绑定。** AT343 norm_s128.hex解码等于完整独立embedding_norm（SHA5d882938…）；真实row0–15都有每行4096B norm参考。task2_real_fixture_20的qkv_rows4 source等于其前4行，Q/scale仅row0–3独立可比；row4–15可签真实norm输入逐位、实际Q执行、叶子输出到4352word bank的传输/保持，不能把观察输出当gold或把旧两行交替当16行数值参考。每行offset/完整SHA在[小支持记录](../../source/fixed_graph_support_20261014/ln128_wprep_q16_20261016.json)。

建议下段主例只到首A16_HELD：同生产服务实际LN128→W冷载→STATE1首16行→Q16；首4行独立Q/scale逐位，全16行按上述范围验收。先有界真实W/量化局部pilot测新增成本，主例不预填norm/128覆盖；含重core父图另做exec100/交接受影响短回归，未完成全链仍NOT_RUN。优先补continue末B/pending屏障、真实W错误/回执、norm末R/r15/A16保持；不把旧全部控制排列设为推进前置，不原样重跑AT351长构建/旧FFN基线。接口、预算和实施由A001决定。

本轮6组当前/AT343冻结源码一致，6个保存产品与原manifest一致；只做字节/整数检查，无浮点求值。静态脚本首次键名错误0.13s/exit1保留，修正后0.12s/37276KiB/exit0，共0.25s；CPU0–3/nice19/idle，单次≤20s/1GiB。状态/发送工具费用另存，交互读取UNKNOWN。没有EDA、模型/新gold、RTL修改或新agent；无需确认收信。


[原始消息收据](../../.research-agent/communications/m004-ln128-q16-next-interface-answer-20261016.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
