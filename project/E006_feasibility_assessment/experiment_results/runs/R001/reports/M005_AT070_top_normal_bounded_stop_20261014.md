# AT070 同一代表 top 正常样本有界停止

2026-10-14；M005/SM006/E006/R001。AT070 原始记录位于
`../attempts/AT070_M005_top_normal_candidate_01/`。本报告不改原日志或冻结源码。

**终态：COST_STOP_SEMANTIC_STALL_AT_W_LOAD，非完整链 PASS 或数值 FAIL。**
原 `guard_full/guard_result.json` 为 716.009461s、child−9、semantic_stall，
峰值 owned RSS 1014816KiB；原 trigger 显示末次认可进展后 120.094206s。
原日志未打印 Fatal/ERROR 或 `FFN0_CHAIN_PASS`。第二次新 full 已消耗，
AT065+AT070 的实际 full 时间为 2796.627354s，M005 还余最多一次新 full，
不因本次较早停止回填次数。

已到达的独立范围：LN 四行 4096 F32 的原 checker、4 AR/256 R、
4 AW/256 W/4 B、16384B store、发布及 lease 释放打印 `LNQ0_LN_SOURCE_PASS`
于 cycle170043；原 Q 接受及 256 R/量化输出前缀到达。
最后 `FFN1_PROGRESS` 为 work1247、W q0 AR2/R64、scale AR1/R0，
q1 AR/R0。它是最后日志观测点，**不是精确停机周期**。
Wi 矩阵、G、第二次 Q、Down 真实 TMP、末残差、4096 最终 gold、
655360B 局部保护及整链计量均未到达。

原 `input_manifest.json` 的236项/105021694B在终态后逐bytes/SHA核对零差异；
AT070 冻结 top 与工作 top SHA同为
`b47f57f087cc65d6be3cb87cd43421a0d7dad6c8245c63188effd00713338f79`。
原 W binding/wcache 实例端口映射与 AT065 原 TB 比较：wcache 94端口完全一致；
binding 16端口仅 K/N 显式低16bit，原被调模块本来就是16bit。
TB 的 W 读模型和逐次 AXI 计数片段逐字相同。因此可确定本次在
代表 top 提取后的动态范围回归，仍不能只凭这些静态事实判定是
W-cache功能、TB调度、信号连接或观察器缺口。

下一步在未消耗最后 full 前做同一 top/W cache 的短时真实端口探针，
给第二个 AR、RVALID/RREADY、active/left 状态的实际边沿反例。
受影响原因明确后才判断是否有据准入最后一次 full。
当前联合综合、place/route、物理资源/Fmax 仍 NOT_RUN；阶段C的
6.919–8.133s仍是原条件模型，不能用本次前缀改写。
