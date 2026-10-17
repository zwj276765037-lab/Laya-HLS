# 07 LayerNorm：完整行统计怎样接上量化

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

baseline的 [rmsnorm](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:140) 可参考行缓存/归约的组织方法，但Laya必须实现LayerNorm，不能直接复用其公式。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 模型语义 | LayerNorm D1024/eps1e-5；第0层attention前跳过 | Typed结构与嵌入图研究可查 | 工程事实 | S1/S2/S3 |
| 数值参考方案 | 三遍centered variance、固定相邻树、逐步FP32 | 拟定Golden-C语义；尚无可执行本项目参考 | 推断 | S3§5.4；本文§2 |
| 接口/性能方案 | F32行入/出、8lane；16行6144cycles加scalar尾 | 算例依赖统计/输出端口与真实II | 推断 | 本文§3；08、15 |
| 实现前缺口 | sqrt/div库版本、逐算子容差、行buffer端口及复位 | 未冻结/未综合 | 待确认 | G1/G3/G4；02、14 |

## 1. 这个模块在链路中的位置

```text
embedding或上一层hidden → LayerNorm → 激活量化 → Q8 Linear
最终hidden             → final LayerNorm → type add
marker向量             → LayerNorm → scorer
```

所有行都是1024维。Encoder第0层attention前跳过LN；其余位置按实际GGUF图执行。只有embedding/final LN保留gamma，其他affine已折入后续权重，不能重复加回。

## 2. 需要三遍，而不是读一遍就输出

| 遍历 | 做什么 | 必须等到什么结果 |
| --- | --- | --- |
| 第一遍 | 接收并保存x，求均值mean | 整行1024值到齐 |
| 第二遍 | 求 `(x-mean)^2` 的均值variance | mean已完成 |
| 第三遍 | 输出 `(x-mean)/sqrt(variance+1e-5)`，需要时乘gamma | variance和倒数已完成 |

均值/方差使用固定的相邻二叉求和树、FP32逐步舍入；不把方差换成 `E[x²]-E[x]²`。8个输入可先组成8元素子树，再按同样的树合并，不能任意改变累加顺序。

至少准备两个4096-byte行buffer，加gamma、归约中间值及流水空间。双buffer能否收下一行，要由实际读写端口决定。

## 3. 与量化和矩阵引擎共同算性能

8-feature通路每遍128cycles，一行三遍384cycles；16行tile为6144cycles，另加归约/sqrt/div等暴露尾延迟。

量化可把LN输出作为它的第一遍输入，同时保存并计算每32值的最大绝对值。即使这样融合，量化仍需第二遍重放。对16×1024 tile，这条链至少要计LN的6144及量化第二遍2048cycles，不能写成“一次2048cycles传输”。

QKV dot理想为12288cycles/tile，采用不同缓存时有机会隐藏部分准备时间；scorer FC1 dot只有4096cycles，LN反而更慢。因此两者不能套用相同的矩阵利用率。

全网LN元素数为 `(61*B*S+B*16)*1024`；B2/S128是16,023,552个feature。scorer行数是B×16，不是B×S。

## 4. HLS实现与联合验收

冻结FP32树和函数顺序后，比较mean、variance、inv和输出。测试常数行、大偏置近常数行、正负抵消、极小数、gamma及NaN/Inf错误；不能只看最终答案碰巧相同。

让量化暂停接收，检查LN保留输出；让矩阵读取旧tile，同时准备新tile，检查两块buffer不混用。综合报告要列出行buffer端口、scalar latency、实际II和资源。后续消费者见[08](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md)，共享时序见[15](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。
