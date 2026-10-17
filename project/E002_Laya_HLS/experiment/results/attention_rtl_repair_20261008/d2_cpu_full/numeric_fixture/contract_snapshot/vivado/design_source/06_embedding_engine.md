# 06 Embedding：从token ID得到第一份hidden

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline查表核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:12)。baseline由CPU先把embedding全部反量化；Laya首版把原始Q8表放HBM，在FPGA读取所需行时反量化。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 表形状与数值 | token50368/type3行；D1024；每行1088bytes Q8_0 | 模型payload和研究记录可查 | 工程事实 | S1/S3 |
| 上下游接口 | 接01的ID和05的行数据；送07 LN或12 type add | 方向/顺序见本文，尚无HLS端口 | 推断 | 本文§1；15 |
| 候选微架构 | 8feature/clk，两个原始行buffer；PAD照常查表 | 行服务周期是无停顿算例 | 推断 | 本文§2、§3；S3 |
| 精度及缺口 | FP16→F32、次正规保留；非法ID先拦截 | 解包/FP转换实现、资源和尾延迟未验证 | 待确认 | G3/G4；14 |

## 1. 它接收什么，交给谁

```text
input_ids → HBM中的Q8 embedding行 → FP32向量 → embedding LayerNorm
qtype     → HBM中的type embedding行 → FP32向量 → final LN之后的type add
```

token词表50368行、type表3行，每行1024维。每行32个Q8_0组，每组34bytes，因此读入1088bytes，产生4096bytes FP32。PAD也按正常token查表，不能直接把它的hidden清零。

## 2. 硬件怎样实现

先检查ID范围，再按 `表起点+ID*1088` 定位。加载器把跨AXI拍的34-byte组正确拼好，计算 `float(q)*float(FP16 scale)`，按特征顺序输出。保持FP16次正规scale，不采用默认清零。

计划反量化通路每周期8个feature；一个1024维行需要128个有效输出周期。准备两个1088-byte原始行buffer，读下一行时可排出当前行；后级不接收时保留当前数据。type三行很小，可在初始化或首次使用时缓存。

## 3. 与LayerNorm怎样配合

LayerNorm必须收到完整一行，先算均值和方差，再输出。Embedding能够逐拍输出，不代表LN也能马上逐拍产生归一化结果。

首版先保存embedding结果再做LN；优化时可把反量化输出直接送入LN第一遍，省一次外存写/读。LN行缓存未空闲时，embedding暂停，不能覆盖尚未完成统计的行。

| 一行的阶段 | 理想数据服务周期 | 还需计入 |
| --- | ---: | --- |
| 读Q8行 | 17个512bit AXI拍（表首64B对齐） | 随机访问、burst拆分和等待 |
| 反量化输出 | 128 | 浮点流水尾和下游停顿 |
| LN三遍 | 384 | 归约、sqrt/div及行切换 |

反量化可与LN第一遍重叠，但后两遍仍存在。性能以完整查表→LN链路计时。

## 4. 验证重点

先比对GGUF反量化行，再比对LN输出；测试词表首尾、CLS/PAD/MASK、重复ID、非法ID、跨4KiB访问和下游暂停。B2/qtype不同的两题要验证type只加到对应问题，并且发生在final LN之后。

交付每行输入/输出数量、缓存占用、随机读延迟和联合周期报告。布局见[04](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md)，归一化见[07](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md)。
