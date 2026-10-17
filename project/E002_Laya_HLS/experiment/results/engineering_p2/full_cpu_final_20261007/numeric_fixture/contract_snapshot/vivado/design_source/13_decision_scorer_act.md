# 13 Decision、scorer和act：把hidden变成选择判断

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

Llama的 [final_norm_classifier](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:282) 输出32000词表logits；Laya这里是不同的网络，需要按Typed GGUF实现，只沿用结果写回方法。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 完整模型边界 | Decision2层→16候选scorer→act；CPU做业务解码 | 用户要求完整Typed Q8部署 | 明确要求 | U2；01、14 |
| 模型例外 | scorer末层F32；act首层F16 256×1028；末层Q8 2×256 | GGUF/图研究记录可查 | 工程事实 | S1/S3 |
| 候选/act语义 | 两次bias；raw softmax；近似top2先除后乘；温度在CPU | Typed图与现有研究支持，硬件未实现 | 工程事实 | S3§3；本文§2–§4 |
| 实现方案 | 复用07/09/11/12；保留CLS到act结束 | 小矩阵、统计与切换延迟尚无实测 | 推断 | 03；本文§5 |
| 验收缺口 | 真实token/marker帧、raw中间值、质量线和同模型GPU对照 | 尚无Laya FPGA结果 | 待确认 | G3/G6/G7；14 |

## 1. 先明确计算边界

```text
28层Encoder → final LN/type add
 → 两层Decision（仍处理整个S）
 → 按16个marker取向量 → scorer → candidate logits
 → 原始候选softmax/统计 + CLS向量 → act → act logits
 → CPU应用温度和业务解码
```

Decision不是只处理16个marker。两层均为LN→QKV→full attention→Wo/residual→LN→FC1/ReLU/FC2/residual，无主干RoPE。矩阵、LN、attention和向量单元都复用03定义的硬件。

## 2. 固定16列怎样进入scorer

按 `marker_pos=b*S+s` 找到本题位置，再用04的固定工作区stride读取1024维。本ABI规范化后，无效候选也gather本题CLS并执行scorer，之后加有限mask；原生前端的全局idx0填充与此不同，须使用01§7的abi_replay期望，不能复用原始profile的无效列。

```text
marker向量
 → 无affine LN
 → Q8 fc1：累加结束后加baked bias
 → 另加scorer_fc1.bias，再GELU
 → F32 fc2及其bias
 → 加 (1-marker_mask)*(-10000)
 → 返回16列candidate logits
```

不能把两个bias预先相加，也不能把无效列直接覆盖成-10000。B1/B2分别有16/32个scorer输入行，其LN和小输出浮点层利用率与主网络不同。

## 3. act为什么不能只在CPU算一个top-k

act是模型的一部分，输入由CLS的1024维向量和4个候选统计值构成，共1028维。候选统计使用**未施加问题温度**的16列分布。

先求原始softmax的p，令k=max(有效候选数,2)，得到：

- top1；
- top1与近似top2的差；
- 归一化熵 `-sum(p*log(max(p,1e-9)))/log(k)`；
- `k/255`。

图中最大值按 `m=ReLU(m-a[i])+a[i]` 的顺序链实现。近似top2不是排序后的第二大值，而是先计算：

```text
delta[i] = FP32(top1-p[i])
denom[i] = FP32(delta[i]+FP32(1e-6))
ratio[i] = FP32(delta[i]/denom[i])
r[i] = FP32(p[i]*ratio[i])
top2_approx = 对r执行同一ReLU最大值链
```

先除后乘的顺序保留。并列最大值、单个有效候选和低margin都要覆盖，不能换成SDK的hard top-k后仍当作同一模型。

## 4. act的混合类型计算

拼接CLS与4个统计值后，执行F16 `[256,1028]` Linear；权重精确转F32计算，另加bias、做GELU；再量化256维结果，执行Q8 `[2,256]` Linear及bias，输出两个act logits。

1028维不能为方便分组而改量化或截断。最后N=2的小Q8层也不能套用大矩阵满利用率。F16/F32尾层共用11的浮点引擎，GELU共用12的向量单元。

候选softmax复用attention的softmax模块；熵/log/div和ReLU链需要小型标量统计数据通路及缓存，明确计入资源和延迟，不因为只有16列就当作零成本。

## 5. 生命周期、带宽和CPU边界

最终Decision hidden保持到act读取CLS完成。marker区最大128KiB；scorer+act权重共1,645,088bytes，装载时间及模式切换不能仅凭少量MAC忽略。

CPU读取的是masked candidate logits与act logits，再按Typed温度、option bucket和业务规则给出choice/score/noul/action。温度不回灌到硬件act特征。五题分2+2+1提交后，CPU按原问题顺序合并。

## 6. 怎样证明完整模型已经上板

保存并比对最终H、marker、scorer的两次bias、raw/masked logits、p、entropy、top1/top2、1028维输入和act输出。测试1/2/3/16候选、ties、noul阈值、B2索引和末批B1。

只有这些阶段都在FPGA完成并通过质量验证，才能称为完整Laya上板推理。一个Linear核或单层测试只是实施中的检查点，整网验收见[14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)。
