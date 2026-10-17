# LNREF0独立源闭合接纳，转四行LNF0硬件回放

R-SM005-LNREF0-20261014；M004/SM005/E005/R001。回复`measurement-first-LNREF0-result-handoff-20261014`，合并AT035 fixture字节补核。主控没有运行新reference/DUT工具。

**限定接纳AT038原request3/generation1/B1/S128的独立enc0 LN_FFN输入/输出来源闭合。真实LN producer及LN→Q连接仍NOT_RUN。下一[D-M004-LN-FFN-RTL-01](../mission/ln_ffn_four_row_rtl_stage_20261014.md)选择原LQ0 baseline生成核的四行LN_FFN→真实store→Q/fullA回放，核新身份、物理发布/lease和数值；本轮不重跑Wi/G/Down长链，不新HLS。工程按原授权直接执行，无需用户转发。**

## 独立性和字节身份

冻结runner导入原full_reference，SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`保持。在原完整S128前向图第二次layernorm_many前复制输入，调用原数学函数后保存输出并退出；第一次是embedding LN。源只来自五ABI输入及GGUF，旧capture在前向完成后才读取比较；没有反求LN输入或从DUT中间观测构造参考。

新完整residual524288B SHA `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8`，前四行16384B SHA `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`；完整和前四行LN输出分别与旧源BO观测、AT035冻结外部源逐字节一致，131072/4096个F32零差异，finite和前缀关系再核通过。旧capture仍是对照观测，其SHA `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`不变；新的独立计算补足来源依据，不回写旧实验为LN硬件证据。

主控直接按AT035冻结q.mem/scale.mem每行32B/2B小端解码，4096B/256B SHA与AT038独立quantize_many报告相符。ABI帧B1/S128/request3/generation1、四个16B package tag及五payload逐字节复核；GGUF完整文件455179648B及八个实际权重段的offset/bytes/SHA另行复核。模型文件读的是原共享模型路径，仅只读，不写历史工程。

## 失败、成本与复用范围

AT037首launch因相对路径失效，child2/0.161049s且无实际policy样本、RSS未捕获，不能补写为策略实测；第二launch修绝对路径后因16B package tags被当GGUF SHA而child1/1.424908s，前缀数学未运行。AT038唯一runner源码修正改按原identity manifest核四tag，child0/trigger null、3.225190s/106568KiB。三guard串行，后两次各一条实际CPU0–3/nice19/idle policy样本合规；首launch采样UNKNOWN，原失败保持。没有提高8GiB/120s入口帽。

主控共核169条文件引用/146路径、八个权重段，冻结83项LN生成物一致；这些只是来源与复用身份。LQ0 top静态支持rows1–16/LN_FFN，并不代表rows4已经动态通过。其外层仍写死LN_ATTN/layer1/B1S64、64MiB诊断span及`target_rows==16`才执行Q，下一阶段必须同时修正request/provenance/owner/query完整字段、合法真实BO容量和四行Q计数/读回分支。不能仅换源文件继承旧16行PASS。

## 下一步集中选择

LNF0复用原LN生成物和现成存储monitor/hub/source lease，不扩全局控制。四行外部residual→LN真实读算写，实际最后B及END后唯一发布，Q重读刚写字节并校核全部4096INT8/128scale/fullA。新的P=LN_FFN0x12/stage2/layer0，Q=0x20，request3/generation1/B1S128；source HIDDEN offset0、destination NORM offset8MiB、原STATE0容量16920576B，稀疏存储允许但地址/写集合/保护义务不缩减。

一个适配候选、最多两轮有因修正，static→有限rows1 pilot→有成本依据的rows4 full，原工具帽保持；生成物不能复用就给出具体原因，不自动新HLS。包含一次有限最后B反压和原Q响应保持以核发布时间及lease释放，不扩F9/取消恢复矩阵。完整LN→QAR0长链留后继单独选择；LQ0与AT035旧工具耗时不能相加作新准入。

当前QAR0/KB1/ATN1限定结果保留；LN真实producer、FFN residual、完整28+2层/122矩阵、13BO请求/恢复、联合资源/物理时序与上板仍未验。M003/M004不关闭。原单owner/单重工具/资源帽、G仅OOC余额、5172s不重启及整体executor/冷INIT停排保持。

证据：[主控核验](measurement_first_LNREF0_review_20261014/verification.json)、[工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_independent_source_20261014.md)、[AT038原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT038_LNREF0_reference_prefix_02/receipt.json)、[AT037原失败](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT037_LNREF0_reference_prefix_01/receipt.json)、[原fixture补核](../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNREF0_AT035_fixture_byte_crosscheck_20261014.json)。
