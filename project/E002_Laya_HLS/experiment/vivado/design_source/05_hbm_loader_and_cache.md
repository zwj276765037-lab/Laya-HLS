# 05 HBM加载与片上缓存：怎样持续喂给计算单元

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

参考 [baseline matmul 的输入/权重加载](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:213) 和 [m_axi定义](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:68)。baseline按输出行读权重；Laya计划缓存当前矩阵，跨多个token tile复用，这是新增设计，需要联合验证。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 访存与缓存方案 | 按矩阵/当前head缓存并复用；端口映射由02统一 | 无加载器或实际HBM测速 | 推断 | S3；04 |
| 带宽算例 | 512bit、150MHz、效率65%→6.24GB/s/master | 是假设有效率，未测量 | 推断 | 本文§1、§4；15 |
| 缓存规模 | 大项约14.41MiB；总量候选16–20MiB、建议上限28MiB | 逻辑容量未计物理碎片、复制和平台占用 | 推断 | 本文§2；S3 |
| 接口行为 | 跨4KiB拆burst；有返回空间才发请求；写可见后交接 | 由生成AXI逻辑及联合仿真验证 | 推断 | 本文§5；02、15 |
| 待定实现量 | 实际RAM banking、outstanding、FIFO深度、AXI ID宽度 | 未指定；8读/4写outstanding仅为候选 | 待确认 | G4；本文§5 |

## 1. 加载器的两项工作

第一项是把HBM数据按连续块搬进BRAM/URAM，并处理对齐、burst和跨4KiB边界。第二项是把缓存排成计算所需的多路读口。外部总线够宽，不代表内部缓存能在一个周期同时读出所需操作数。

初始总线为512bit，也就是每拍64bytes；150MHz理论9.6GB/s。若暂取65%有效率，则6.24GB/s，只是分析假设。要分别测顺序权重读、embedding随机行读、QKV散写和读写同时进行时的实际效率。

## 2. 各块缓存为什么需要这么大

| 缓存 | 最大逻辑大小 | 给谁用、为什么要保留 |
| --- | ---: | --- |
| 当前/下一权重 W0/W1 | 每块5.445MiB | 最大Wi矩阵；当前矩阵要供所有token tile使用 |
| 量化FP32输入 | 每块256KiB，双缓存512KiB | 最大16×4096输入需要保存后重放 |
| 量化A8及scale | 每块68KiB，双缓存136KiB | 阵列要同时读取16行输入 |
| 矩阵部分和PS | 每块335872bytes，双缓存671744bytes | 存16×5248输出；算完后按窄通路排出 |
| 当前/下一head的KV | 每块最大1MiB | 每head B2/S1024的K+V，供全部query复用 |
| attention score/prob | 每块128KiB，双缓存256KiB | 完整行softmax及后续AV |

这些大项约14.41MiB，再计LN/RoPE、scalar表、FP尾层临时区、重排和FIFO。总逻辑缓存先按16–20MiB规划，28MiB是历史建议上限（推断，最终预算见G6）；综合必须另外计算RAM读口复制、宽度碎片、平台占用和布线。

## 3. HBM带宽与片上带宽不是一回事

16×8×32阵列每次issue要读取：16行各32个A8，共512bytes；8列各32个W8，共256bytes；双方scales另48bytes。128个F32部分和还要各读/写512bytes。

这对应150MHz下A8 76.8GB/s、W8 38.4GB/s、部分和读写各76.8GB/s。靠SRAM分bank和广播实现，不能逐周期从一个HBM master直接供应。因此必须同时评估09的阵列和这里的端口。

PS按token/output lane分bank。Wi的U/G两半相隔2624，同样的列余数会落同bank，配对读出需要双读口或明确降速。双缓存只是两块存储，不会自动给单块存储增加读口。

## 4. 一张Wi权重的具体算例

Wi权重q为5,373,952bytes，两个q端口各读2,686,976bytes，scale为335,872bytes。以6.24GB/s/master计算：q约0.431ms、scale约0.054ms；三路并发时仍要约0.431ms再加启动与重排。

B2/S128有16个token tile。整张Wi装载一次供16个tile复用，理想dot共335872cycles，约2.239ms@150MHz。能否隐藏装载，要比较**前一任务剩余计算时间**与这次装载时间；不能因为Wi自己算得久，就认为它的初次装载免费。

如果实现退化成每tile重读一次，权重流量可能放大16倍，必须如实更新性能模型。

## 5. 加载、计算、排出怎样共存

首版先用完整缓存就绪作为边界。只有空bank能预取；当前bank最后一次读取完成才可覆盖。写回只有收到所需写响应才对消费者可见。

顺序大块访问以最多4KiB burst为起点，跨边界拆分。outstanding数量由返回buffer/目标cache的可用空间确定，初始可评估8个读burst和4个写burst，不能只增加数量而没有存储信用。

正常读写、当前计算等待的数据、下一矩阵预取要有明确优先级；错误或结束时先排空已接受事务。HLS生成接口也要用仿真确认这些行为，不能只依赖平均带宽。

## 6. 怎样联测

在板上先用小型访存核检查每个候选BO的读写和实际带宽，再接量化/Linear。记录每个master的有效bytes、cycles、stall、cache装载次数及每矩阵读放大。

随后同时开启下一权重预取、当前dot和上一PS排出，检查是否抢同一个RAM口；attention再测head切换和KV预取；FFN再测U/G配对。只有整条链达到供需要求，才能增加阵列并行度。HBM布局见[04](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md)，联合周期见[15](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。
