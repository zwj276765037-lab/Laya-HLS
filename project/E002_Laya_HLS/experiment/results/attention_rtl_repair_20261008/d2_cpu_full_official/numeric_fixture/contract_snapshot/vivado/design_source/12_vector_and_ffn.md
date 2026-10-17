# 12 FFN与残差：Wi、GELU/gate、down怎样连起来

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline FFN及残差段](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:230)。Laya把SwiGLU改为GEGLU，并增加Decision的ReLU路径；两种FFN都复用同一个Q8 Linear引擎。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 模型语义 | Encoder GEGLU，Decision ReLU；residual/type add | Typed图/研究支持 | 工程事实 | S1/S3 |
| 数值参考 | tanh GELU及运算顺序、U/G相乘、bias分步保留 | Golden-C仍待形成可执行比较对象 | 推断 | S3§3、§5.4；本文§1、§5 |
| 接口与速率 | 09 U/G配对→4lane gate→08；残差另读旧hidden | Wi/down共享Q8引擎；F1方案不能并算 | 推断 | 本文§2–§4；15 |
| 带宽与缓存 | F0 HBM往返；F1a省Wi；F1b需Wi/down共驻 | 逻辑流量可算，物理端口未定 | 推断 | 本文§3、§4；05 |
| 实现前缺口 | GELU近似/尾延迟、U/G双读口、4→8转换、错误恢复 | 未实现/未综合 | 待确认 | G3/G4；14 |

## 1. Encoder FFN的数据流

```text
hidden → LN → 量化 → Wi(1024→5248)
                        ├─ U[2624] → GELU ─┐
                        └─ G[2624] ────────× → gate
                                                ↓
旧hidden ───────────────────────→ 加法 ← down(2624→1024) ← 量化
```

U先GELU，再与G相乘。GELU使用冻结的tanh近似：`0.5*x*(1+tanh(c*x*(1+0.044715*x*x)))`，c为FP32的0.7978845608028654。求值顺序与参考保持一致，不改成erf GELU或SwiGLU。

## 2. U/G怎么在同一拍到达

Wi通常先排出完整U，再排G，两者相隔2624个元素。普通顺序流不能直接相乘，需要缓存后按相同token、相同intermediate索引配对。

计划每拍读4个U和4个G，产4个gate值。16行需要10496cycles，与Wi的8-feature读出数量匹配。但U/G可能落同一个PS bank，需要双读口；没有双读口时必须承认读取降速。

非线性流水已经发出的结果不能因下游暂停而丢失，输出缓存必须覆盖在途数据。进入量化时每拍只有4个有效gate值，不能凭接口是8-lane就认为已提供8个。

## 3. 三种调度的成本放在一起比较

| 方案 | gate和权重放在哪里 | 真实收益与代价 |
| --- | --- | --- |
| F0 首版 | Wi写HBM，读取配对做gate，gate写HBM，再做down | 容易验证；中间读写和串行时间都存在 |
| F1a 第一轮融合 | Wi的PS直接配对送GELU；gate仍写HBM | 省Wi的写/读；需要双PS和配对读口；全部Wi后再做down |
| F1b 后续方案 | 单tile做完Wi/gate立即做down；gate保片上 | 需Wi5.445MiB和down2.723MiB同时驻留；下一权重预取受限 |

Wi和down始终共享整数引擎，不能同时计算。F1b省去gate流量，也可能暴露权重装载和切换开销，必须完整计时才能选择。

16行Wi为335872bytes，gate为167936bytes。省去Wi写/读可少671744bytes/tile；再省gate写/读可少335872bytes/tile。它们是逻辑流量，实际burst开销另计。

## 4. Residual还需要第二个输入带宽

每clk输出8个F32残差结果，需要读取8个新结果和8个旧hidden，再写8个结果，共96bytes/clk。一个512bit master不能在一个方向/拍独自提供这些读写。

融合时可让新结果从PS直接来，另一个端口读取旧hidden，目标写另一个hidden BO；非融合时按实际串行访存计时。旧hidden最后一次读完前不能原地覆盖。residual区如果用于快照，要把copy流量计入；直接保留旧X则无需重复copy。

## 5. Decision和head怎样复用向量单元

Decision FC1输出4096维，ReLU计划8feature/clk，16行需8192cycles；结果留存后，才由同一个矩阵引擎执行FC2。它使用Wi区的另一个4096-stride视图，Encoder结束后才可复用。

type add在final LN之后发生，把每题的1024维type向量广播到该题全部S个token。scorer/act的bias→GELU也用同一向量单元；scorer的Linear baked bias与GELU前原bias按两次操作保留。

## 6. 联合验收

从LN输出开始比较Wi两半、GELU、gate、量化、down和residual；同时观察权重、PS、gate和旧hidden的生命周期。重点测U/G错行、最后2623索引、4→8-lane转换、缓存覆盖和向量模式争用。

F0正确后再逐项启用F1a，记录少了哪些HBM读写、额外用了哪些RAM端口、实际省了多少周期。F1b单独评审，不作为已有性能收益。
