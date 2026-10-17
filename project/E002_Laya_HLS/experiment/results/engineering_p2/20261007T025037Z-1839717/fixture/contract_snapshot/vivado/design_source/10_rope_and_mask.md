# 10 RoPE和mask：把QKV准备成attention真正需要的数据

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline的RoPE与attention前处理](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:158)。Laya的配对方式、位置表和mask均不同，不能直接改dim后复用原代码。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 模型语义 | half-split；full/slide两套RoPE；Decision旁路 | 图与配置/旧研究支持 | 工程事实 | S1/S2/S3 |
| mask语义 | finite -10000/-20000，先合并再加score | 不可替换为-inf或跳过key | 工程事实 | S3§3、§5.4；本文§4 |
| 接口/布局方案 | 接09 raw QKV→head重排→11；位置使用题内s | HBM布局与04共用地址函数，尚无代码 | 推断 | 本文§1、§3；04 |
| 吞吐与缺口 | 候选4 pair/clk；完整QKV可见后进入attention | 表读口、重排buffer、实际FP延迟未确定 | 待确认 | G4；05、11、15 |

## 1. 这条链路连接哪里

```text
QKV Linear按token排出 → Q/K旋转、V保持 → 按head存入HBM
                                        → 全部就绪 → attention读取
输入mask与query/key位置 → 合并bias ───────────────→ QK分数
```

Linear每行输出Q1024、K1024、V1024，各自有16个64维head。RoPE的位置使用本题行内s；B2第二题不能把batch偏移一起当作位置。

## 2. half-split旋转需要完整head

baseline按相邻维度旋转；Laya配对 `(0,32)…(31,63)`。对i=0…31，按实际F32表计算：

```text
y[i]    = FP32(FP32(x[i]*cos[s,i]) - FP32(x[i+32]*sin[s,i]))
y[i+32] = FP32(FP32(x[i+32]*cos[s,i+32]) + FP32(x[i]*sin[s,i+32]))
```

Encoder full层用theta160000的表，sliding层用theta10000的表；Decision无RoPE。四张表各1025×64个F32，直接导出，不在硬件重算三角函数。

一个head64维，要先保存完整head再配对。计划每clk处理4对、输出8个feature；这要求x、cos、sin的读口与16次乘法/8次加减配平。配对结果先写结果buffer，再按连续特征顺序排出，不能忽略重排成本。

## 3. QKV什么时候可以给attention

首版把raw QKV写到04定义的head布局，再完整读取每个Q/K head、旋转并覆写。V已经就绪。当前层所有题、所有位置的最终Q/K/V写完后，attention才开始。

优化版可以在PS排出时直接旋转再散写，省raw Q/K读写；此时09、加载器和RoPE必须一起验证端口、顺序和回压。full/sliding层都需要这个就绪屏障，有限mask不允许提前假定未来K/V无用。

一个Q/K head的串行数据服务至少包括8拍捕获、8拍旋转、8拍排出，另计浮点尾。能隐藏哪些阶段，要看双buffer和真实端口。

## 4. mask怎样加到分数上

```text
padding_bias = (attention_mask[b,k]-1)*10000
local_bias = abs(q-k)<=64 ? 0 : -10000
combined_bias = full层使用padding_bias
                sliding层先做FP32(local_bias+padding_bias)
score = FP32(FP32(qk*0.125)+combined_bias)
```

先合并mask，再加score一次。局部窗口外且为padding的key会得到-20000。mask是有限值，不能换成负无穷、删掉某些key，或把padding query强制归零。

尤其局部层可能有query的窗口内没有真实key，仍要对全部有限分数做softmax。mask生成由当前QK的b/head/q/k上下文驱动，与同一个score一起交付；不能错一个位置或错一个周期。

## 5. 联合验证

从09的raw QKV开始，逐级比较旋转后数据、HBM地址、QK、combined bias及最终score。覆盖head0/15、s0/1023、B2、±64/±65窗口边界、padding query与Decision旁路。

延迟最后一笔QKV写响应，确认attention不会先读；暂停score消费，确认mask和坐标一起保留。完成条件是整条QKV→attention链正确，不能只验证旋转公式。
