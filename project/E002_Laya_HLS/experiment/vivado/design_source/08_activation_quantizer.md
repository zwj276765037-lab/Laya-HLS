# 08 激活量化：把FP32输入整理成阵列可读的A8 tile

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline quantize](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:73) 的分组处理结构。Laya的Group32、FP16 scale和舍入规则必须按GGUF参考实现，不能直接沿用baseline的Group64、FP32 scale、1e-9阈值及clip逻辑。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 量化参考方案 | Group32；q用d_full，roundf远离0；保存scale用FP16 RNE | 沿用GGML参考思路，不宣称与全部GPU路径逐位相同 | 推断 | S3§5.1；本文§2 |
| 接口 | F32 tile→A8及FP16 scale→09；完整tile交接 | 16行和多bank读取为候选结构 | 推断 | 本文§1、§3；15 |
| 性能/缓存 | 两遍8lane；K4096最大256KiB输入＋68KiB量化tile | 由形状和配置复算，非实测资源 | 推断 | 本文§3、§4 |
| 实现前缺口 | reciprocal II、FP16次正规处理、错误分支与尾延迟 | 尚无算子或联合数值测试 | 待确认 | G3/G4；09、14 |

## 1. 输入输出是什么

上游可能是LN、attention结果、GELU/gate或ReLU。输入一块最多16行的FP32数据，K为1024、2624、4096或256；这些Q8层的K均整除32。

输出每32个值对应32个S8及一个FP16 scale。数据先存进A8 tile cache，矩阵引擎才能同时读取16行，向多个输出列广播。

本节算术是硬件候选数值合同，真实Typed GGML CPU执行路径与捕获数据见14§10.3。原生Q8 activation scratch已直接捕获；候选q/scale、INT dot/恢复/PS仍须用真实输入逐项对比，类型相同不保证路径逐位相同。

## 2. 每组怎样量化

```text
amax = max(abs(x[0..31]))
d_full = FP32(amax/127)
inverse = d_full不为0时的FP32(1/d_full)，否则为0
q[i] = roundf(FP32(x[i]*inverse))
d_saved = FP16_RNE(d_full)
```

roundf的半整数远离0；保存scale用FP16最近偶数舍入。q由未舍入的d_full计算，后续Linear恢复用d_saved；两者不能混用。全零组输出零，FP16次正规与舍入成零的scale按同一参考保留。非有限值、scale溢出或q超出[-127,127]报错，不静默改成另一种量化算法。

## 3. 为什么要保存再重放

第一遍每周期接8个FP32值，同时保存并求每组amax。每4拍产生一个组统计，scalar流水计算scale和inverse。第二遍从同一输入缓存重放，乘inverse并roundf，每4拍形成一个完整量化组。

最大输入16×4096×4=256KiB；A8+scale为68KiB。两组双缓存分别512KiB和136KiB；inverse/scale表每bank最多另需12KiB和有效标记。

只有完整A8 tile准备好，首版Linear才开始读取。输出FIFO很深，也不能替代阵列需要的16路片上读口。

## 4. 与上下游的速率怎样匹配

| 16行输入K | 两遍、8-lane的理想周期 | 后续dot周期示例 |
| --- | ---: | ---: |
| 1024 | 4096 | QKV12288；Wo4096 |
| 2624 | 10496 | Encoder down10496 |
| 4096 | 16384 | Decision FC2 16384 |

第二、三行中量化已经与dot同速，不能随意减半量化通路而仍沿用矩阵峰值。scalar链平均至少每4cycles接一个组统计；若倒数IP不能流水，额外等待必须逐组计入。

GELU/gate只有4个结果/clk。在线直接接它时，量化第一遍也只能按4-lane接收，之后第二遍才可8-lane；不能套用上表的双8-lane周期。LN直连则省去第一遍外存读，但LN自己的三遍统计仍存在。

## 5. 验证重点

与[09 Linear](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md)一起比较原FP32、amax、d_full、inverse、d_saved、q和首个dot。覆盖舍入边界、零、次正规、K2624最后一组、act K256、小batch和反压。

记录两遍周期、scalar II/尾延迟、A8就绪时间、cache写读冲突。一次量化得到的tile应供所有输出列复用，不按输出tile重复量化。
