# 09 Q8 Linear：整数阵列、scale恢复和输出必须一起设计

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

直接参考 [baseline matmul](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:209)。该函数实际执行矩阵乘单向量；本项目扩成多个token共同复用权重的tile运算。16×8×32是新增候选配置，不是baseline已有的综合结果。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 模型权重输入 | Q8_0原始q及FP16 scale；F32输出 | GGUF已有数据；没有Laya矩阵核 | 工程事实 | S1；S6 |
| 候选阵列 | TM16×TN8×GS32，128组结果/issue | 4096乘法贡献不是已实现DSP数量 | 推断 | S3；本文§1、§5 |
| 数值参考 | INT32组内dot；R0恢复；group升序非FMA累加 | R1仅为须与R0逐位比较的替代方案 | 推断 | S3§5；本文§2 |
| 接口/流水 | 08 A8＋05权重→PS→10/12/13，8feature排出 | 完整tile双PS/反馈间距尚未综合 | 推断 | 本文§3、§4；15 |
| 实现前缺口 | DSP/LUT代价、Lacc、RAM端口、实际II和Fmax | 无硬件报告；N2小层需单独测量 | 待确认 | G4；14 |

## 1. 一次算什么

逻辑运算为 `Y[M,N]=X[M,K]×W[N,K]转置`。输入X先由08量化成A8及scale，W使用GGUF原始q/scale；输出仍FP32。

一拍候选配置同时处理16个token、8个输出列、每组32个输入：共4096个INT8乘法贡献，形成128个组内整数dot。整网所有Q8 Linear共用该引擎，按层和矩阵切换权重。

本节算术是硬件候选数值合同，真实Typed GGML CPU执行路径与捕获数据见14§10.3。原生Q8 activation scratch已直接捕获；候选q/scale、INT dot/恢复/PS仍须用真实输入逐项对比，类型相同不保证路径逐位相同。

## 2. 从dot到最终输出经过什么

```text
A8 cache + W8 cache
  → 每32项做精确INT32 dot
  → 用两边FP16 scale恢复为一个FP32 term
  → 按group从小到大加入FP32部分和
  → 所有group完成
  → 按图加Linear bias，按8个feature/clk排出
```

R0参考为 `term=FP32(FP32(scale_a*scale_w)*FP32(dot))`，之后单独 `acc=FP32(acc+term)`，不合成FMA。R1候选把FP16 scale精确分解为整数mantissa和2的幂，生成相同term；只有逐位验证和资源比较后才采用。R1仍保留组间FP32累加。

权重scale中确实存在FP16次正规值，不能在转换时默认清零。scorer的post bias留给GELU前处理，不能与Linear bias合并。

## 3. 为什么要部分和缓存

每拍更新128个组结果，最终出口只有8个feature/clk。应先将结果保存在整tile部分和PS中，再有序读出；加深一个小FIFO不能长期吸收这种速率差。

最大PS为16×5248×4=335872bytes。双PS允许计算tile n时排出tile n-1，但两块存储必须有独立端口。最后一组累加写入后，PS才可读；排出和bias完成、消费者接收后，原PS才能复用。

同一输出的累加有反馈延迟Lacc。按“group外层、输出tile内层”轮转，同一地址更新间隔为ceil(N/8)；只有该间隔足够且RAM端口可用，才可能每clk发一次。act第二层N=2不满足大矩阵条件，应采用安全等待，不能假定满利用率。

## 4. 与量化、RoPE和GELU共同核算

以下是16行、无停顿的服务周期，尚未含加载、FP流水尾和控制开销。

| 矩阵K→N | 量化两遍 | dot | 8-lane读出 |
| --- | ---: | ---: | ---: |
| QKV 1024→3072 | 4096 | 12288 | 6144 |
| attention Wo 1024→1024 | 4096 | 4096 | 2048 |
| Wi 1024→5248 | 4096 | 20992 | 10496 |
| down 2624→1024 | 10496 | 10496 | 2048 |
| Decision FC1 1024→4096 | 4096 | 16384 | 8192 |
| Decision FC2 4096→1024 | 16384 | 16384 | 2048 |

QKV输出每行依次为Q1024/K1024/V1024，10负责旋转/重排。Wi可采用每拍4个U和4个G的配对读出交给12；U/G处在相同列bank时要双读口，否则需降速。projection排出接residual时，还要另读旧hidden。

## 5. HLS实施与上板验证

先做一个含量化、dot、R0/R1、FP反馈、PS和读出的组合切片，测真实II与资源。HLS不能把4096个乘法贡献自动视为4096个DSP；packing、加法树、恢复、缓存和布线一起决定资源。

主Linear使用同一个函数入口，控制实际实例数；综合不通过时降低TM/TN并统一重算，不能删层或删候选。板上先对真实GGUF的一张矩阵比对q、dot、term、每组partial和最终输出，再接QKV和FFN链。

数量守恒、随机暂停、最后一组延迟、N2尾部、bias顺序和PS提前覆盖都属于联合测试。只看整数dot的II=1不足以证明此模块可用。带宽与缓存见[05](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md)，时间轴见[15](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。
