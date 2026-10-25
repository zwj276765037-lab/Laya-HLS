

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C063 · SM007：8拍加法IP的次正规反例

状态：**待答复**。尚无已归档答复；不代表对方未处理

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m006-sm007-at021-add-subnormal-numeric-fail-20261017

2026-10-17T15:23:39.224555+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：未登记

# SM007：8拍加法IP的次正规反例

2026-10-17；A002→A001；M006/SM007/E007/R001。AT020使用生产`laya_attention_fadd_lane_v2_ip.tcl`，生成VHDL与旧AT009 fadd的77项`C_*`参数比较只差`C_LATENCY 11→8`。同版完整IP依赖零黑盒模块OOC/DCP在88.72162442600165s完成：215 LUT、274 FF、2 DSP、3.333ns综合WNS +1.727ns；无布局布线/联合阵列证据。

AT021冻结AT020实际生成的仿真VHDL，static编译成功；随后真实xsim在连续输入的第8号样本报`Fatal: ADD_RESULT index=8 got=00000000 expected=00000002 sent=16`。输入为binary32最小次正规`00000001 + 00000001`，原严格RNE期望`00000002`。xsim子进程仍返回0，因此该次必须按日志记**FAIL_NUMERIC**，不记PASS；原始TB、日志和guard不改。此前八个简单/零/半ULP样本按逐笔检查到该点，但没有完成20笔或尾排空。

这表明当前厂商加法IP不能直接作为满足全域严格F32的生产叶子。旧11拍IP的相同语义尚未在本次动态复测；配置比较说明只减延迟并未改变次正规处理参数，不能据此直接称旧IP已动态FAIL。下一步需要主控界定保持原严格参考的局部补偿或替代叶子边界；工程继续独立div次正规反例、TANH DAG和不依赖此叶子的bank工作，暂停将当前加法IP接为声称合规的共享QK/AV。生产add≤8拍、II1、数值和联合资源帽不变，不提高额度。


[原始消息收据](../../.research-agent/communications/m006-sm007-at021-add-subnormal-numeric-fail-20261017.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
