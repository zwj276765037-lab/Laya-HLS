# 11 Attention：QK、softmax、AV怎样共享硬件

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline的multihead_attention](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:181) 和 [softmax](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:178)。原代码只处理到pos的历史key；Laya处理完整S，保留双向full/sliding有限mask。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 计算图 | 全S的QK/finite mask/softmax/AV；Dhead64 | 模型图/研究可查 | 工程事实 | S1/S3 |
| 数值参考 | QK固定树；AV按key升序非FMA；完整行softmax | 属于拟定Golden-C操作序列 | 推断 | S3§5.4；本文§2 |
| 共享资源 | 64路FP；QK/AV/浮点尾层分时复用 | 不可将QK、AV时间取max | 推断 | 本文§1、§4、§5；03 |
| 接口/缓存 | 10 QKV→05 KV缓存→score/prob→att_out；尾层供13 | 候选双KV/score缓存，非综合容量 | 推断 | 本文§3；04、15 |
| 实现前缺口 | exp/div实现、归约延迟、64路窗口与反馈II | 尚无联合trace和资源报告 | 待确认 | G3/G4；14 |

## 1. 按head和query tile执行

当前层全部QKV就绪后，装入一个head的K/V，处理它的所有query，再切换head。一个query tile计划16行，每个head64维。

```text
Q tile + K cache → QK → 合并mask → score buffer
                                      ↓
                               完整行softmax
                                      ↓
                V cache + probability → AV → attention输出
```

64路浮点乘加是待综合的分析配置。QK一次用64个乘法贡献生成一个score；AV一次用一个prob更新64个输出feature。二者使用同一浮点引擎，因此计算不能同时运行。

本节算术是硬件候选数值合同，真实Typed GGML CPU执行路径与捕获数据见14§10.3。原生30个FLASH_ATTN_EXT的K/V/mask经过F16转换，融合内部score/prob未捕获；此处FP32显式分解不可冒称原生逐位行为。

## 2. 三个阶段分别依赖什么

| 阶段 | 运算/顺序 | 可以交给下游的时点 |
| --- | --- | --- |
| QK | 64项F32乘积，固定相邻二叉树求和，乘0.125并加合并bias | 当前query的S个score完整 |
| softmax | row max；exp(score-max)及固定树求和；除以sum | 当前行prob全部生成 |
| AV | 每个输出按key升序，先F32乘法、再F32相加 | 所有key都已累加并退休 |

AV不使用FMA，也不把key拆成多个partial最后随意相加。可交错不同query来隐藏FP加法反馈，但不能改变同一输出的key顺序。如果16个query仍不足以覆盖反馈延迟，就要插入等待并计入性能。

## 3. 缓存和端口为什么重要

B2/S1024一个head的K+V为1MiB；双缓存最多2MiB。score/prob按 `[B,16,S]` 每bank最大128KiB，双bank256KiB。Q tile和AV partial各最大8KiB。

浮点引擎一次需要64个F32的专用cache窗口，即256bytes；不能用每拍仅32bytes的普通8-feature通路直接喂满。AV partial还需要64个旧值读和64个新值写。05必须给出对应bank方案。

QKV按head奇偶分两个BO，一个head只使用其中一个master。另一master预取下一head，需要另一块空KV cache。score bank按“QK填充→softmax→prob可读→AV读取→空闲”交接。

## 4. S128的一个可复算例子

取一个题、一个head、16个query，不含装载、FP尾与停顿：

| 阶段 | 理想周期 |
| --- | ---: |
| QK，一score/clk | 16×128=2048 |
| softmax max，8-lane | 256 |
| exp/sum，4-lane | 512 |
| normalize，8-lane | 256 |
| AV，64个feature/issue | 2048 |
| 输出按8个feature/clk排出 | 128 |

首版串行为5248cycles，再加KV/Q加载、函数/模式切换和尾延迟。B2/S128一层有256个这样的query tile，但每head的KV只加载一次，跨其所有query tile复用。

优化时softmax可以在另一score bank上与下一QK重叠；共享浮点引擎的QK+AV仍需4096cycles。不能把QK和AV取max后宣称省一半时间。

## 5. 浮点尾层也使用同一引擎

scorer最后一层是F32 `[1,1024]`，act第一层是F16 `[256,1028]`。前者可按多marker行并行、广播一个权重；后者按输出列并行、广播一个输入值。两种cache读取与广播不同，需要明确模式切换。

每个输出仍按k升序乘加。scorer只有B×16个输出，act输入1028也有物理尾部，不能只用MAC数除64当真实周期。F16精确转F32，不经A8量化。小层权重可复用已经释放的KV存储，但必须由03证明生命周期不重叠。

## 6. 验收时同时接哪些模块

先接10的QKV/mask和05的KV/score缓存，再测完整QK→softmax→AV；之后接13的两种浮点尾层。检查每query有S个score/prob和64个结果，覆盖全有限mask、无窗口内真实key、极端score、B2、长S和输出暂停。

报告QK/softmax/AV各周期、共享引擎时间轴、FP反馈、score峰值占用和实际HBM bytes。低精度attention、在线softmax、分块AV归约均需新的数值/质量验证，首版不默认采用。
