# 03 Forward 调度：共享硬件怎样执行整张网络

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline Transformer 核内的层循环](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:91)。本设计也由 FPGA 自己遍历层，CPU 只启动一次；首版用 HLS C++ 的循环和函数调用生成控制电路，不引入通用 CMD256 指令总线。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 调度对象 | 28 Encoder＋2 Decision＋scorer/act | 模型/图可查；无Laya控制器实现 | 工程事实 | S1/S3 |
| 硬件复用 | 一个Q8引擎、一个FP引擎及共享向量/LN单元 | 尚无综合层级证明实例数量 | 推断 | S3；本文§3 |
| 交接规则 | 数据写入可见、流水排空后再释放缓存 | F0分阶段；F1融合须单独证明依赖 | 推断 | 本文§2、§4；15 |
| 性能方法 | 共享资源任务串行相加；只重叠无争用任务 | 已有条件周期，无trace或板上计数 | 推断 | S3；15 |
| 控制缺口 | 状态/错误编码、取消恢复、性能监测 | 尚未确定生成接口与平台恢复API | 待确认 | G2/G5；02、14 |

## 1. 为什么需要调度

28 层 Encoder 不对应28套硬件。矩阵引擎、LayerNorm、量化、attention和向量单元被各层重复使用，因此控制器必须知道三件事：当前运行哪个算子、输入是否完整、它要使用的缓存是否还被别人占用。

```text
检查请求 → embedding/LN
 → Encoder层0…27
 → final LN/type add → Decision层0…1
 → gather/scorer → 候选统计/act → 写结果 → 完成
```

层权重 offset 和层类型由 GGUF 导出生成的只读表提供。Encoder每三层中的第一层为full，其余为sliding；Decision两层均full且无RoPE。

## 2. 一层里必须遵守的顺序

下表是F0按阶段串行时的屏障。F1a允许LN输出与量化第一遍重叠，但Linear仍等完整A8 tile；不能把F0的整阶段等待条件与F1的在线流混为一个接口。

| 算子结束时 | 才能开始什么 | 此时仍要保留什么 |
| --- | --- | --- |
| LN 的均值、方差和输出完成 | 对这份输出量化 | 原始行直到最后一次读取 |
| 一个输入tile全部量化完成 | Linear读取A8 tile | 当前矩阵权重，供其余token tile复用 |
| 当前层Q/K/V全部产生并写完 | 当前层attention | 当前head的K/V，直到全部query处理完 |
| output projection完成 | 与旧hidden做残差相加 | 旧hidden直到残差最后一次读 |
| Wi完成并产生配对U/G | GELU/gate | 未消费的U/G及gate |
| 全部gate可用（首版） | 同一矩阵引擎执行down | down结果与旧hidden，直到残差提交 |
| 最终Decision结果完成 | scorer/act | CLS向量直到act输入拼接完成 |

“完成”要指数据已经能被下一阶段读取，而不只是最后一个乘法发射。外存写完需要相应写事务完成；内部函数/流完成也要排空在途输出。

## 3. 哪些计算不能同时执行

| 共享资源 | 相互争用的任务 | 对性能的影响 |
| --- | --- | --- |
| Q8 Linear引擎 | QKV、Wo、Wi、down、Decision投影、scorer/act Q8层 | 同一时刻只能承担一个矩阵任务 |
| 浮点引擎 | QK、AV、scorer最后一层、act第一层 | QK和AV时间需要相加 |
| 向量单元 | GELU/gate、ReLU、residual、type add | 模式切换、输入供给和输出存储都要计时 |
| 权重双缓存 | 当前矩阵、下一矩阵预取 | 两张FFN权重同时驻留时，没有第三个空bank预取 |

HLS可能因为不同模板实例或函数内联而复制单元。应使用一个受控的矩阵函数入口、合适的实例约束，并检查综合层级报告，确认实际实例数量符合这张表。

## 4. 首版与优化版怎样区分

**首版 F0：先按阶段串行。** 中间结果按04存HBM，当前矩阵权重在片上跨token复用。QKV先以raw形式存储，再旋转Q/K，最终写完后进入attention。流程容易定位错误，算术和搬运时间必须按真实顺序相加。

**第一轮优化 F1a：只重叠已证明互不冲突的阶段。** 例如计算tile n时，用另一块PS缓存排出tile n-1；LN输出直接送量化第一遍；QKV读出直接接RoPE。每种融合都要说明省去哪些读写、增加哪些buffer/端口，并与F0做相同数值比较。

**后续 FFN 优化 F1b：一个tile完成Wi后立即做down。** 需要Wi/down两张权重同时在片上；二者计算仍串行，预取空间减少。这是待评判方案，不计作F1a已经取得的收益。

PS是矩阵的部分和缓存。只有最后一组累加退休后才能读取；读取还可能需要加bias，全部输出交付后才能覆盖。F1直连时消费者要提前准备接收，不能等生产者全部“完成”才读流，否则可能形成互相等待。

## 5. 怎样评估联合流水

对每个任务记录输入就绪时间、资源可用时间、开始/结束周期和buffer读写范围。开始时间取所有前置条件满足的最晚时刻。多个任务共用同一引擎时排成先后关系；只有硬件、缓存和访存端口都独立时才允许重叠。

先给 LN→量化→Linear、QKV→attention、FFN 三条链分别画时间轴，再合成全网。不能把各模块最乐观的吞吐相加成“整机性能”。具体tile算例见[15](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

验证时故意暂停下一阶段、延迟HBM返回、打断最后一次写入；检查不会读到半成品、提前覆盖旧hidden、同时占用同一矩阵单元或遗留上一请求的数据。
