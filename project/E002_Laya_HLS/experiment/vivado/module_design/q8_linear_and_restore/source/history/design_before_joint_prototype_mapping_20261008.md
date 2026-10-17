# Q8 Linear、恢复与部分和：详细设计

## 2026-10-08：性能原型待实施规格

当前生产F0仍为串行Q8 leaf；179–199cycles/group的旧调度只用于成功源码图的条件外推，完整旧RTL还存在控制语义缺陷。功能表示修复没有增加并行算术，不能据此声称50ms达标。

后续具体工程为[修复合同§4.4–4.7](../../../../results/attention_rtl_repair_20261008/repair_contract.md)的TM4/TN8联合Q8原型：完整K/N、冻结BO装载、8lane两遍量化、W/A/PS实物banking、R0恢复反馈与真实写响应退役一起实现和验证。当前已获[独立设计审核](../../../../results/attention_rtl_repair_20261008/reviewer_joint_q8_prototype_design_review.json)接受为后续设计；尚未放行实现，无原型CPU/CSim/RTL/OOC数据。首个原型不是原§16×8候选的已实现版本，也不修改本轮生产controller补丁。


本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入A8/scale、W8/scale和bias，窗口最多16×8，输出F32[rows,N]；按完整K/N循环，QKV按plane/head散写。

已生成compute_one每32项dot160cycles，含恢复/累加group179–199cycles；active leaf24.12–26.82MMAC/s@150MHz。实际两份leaf按同步图调用，不可把完整图预算除2。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-q8_linear_and_restore)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：真实完整K/N的Q8 Linear、bias恢复和QKV散写已实现，十种矩阵及完整CPU/CSim通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

执行Y[M,N]=X[M,K]×W[N,K]转置。输入经activation_quantizer产生A8，W保持GGUF q/scale。全网Q8投影共享本引擎，整数组内dot、scale恢复、FP部分和及输出共同评估。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 候选几何 | TM16×TN8×GS32＝4096整数乘法贡献/issue、128组dot | 推断 | 09§1 |
| 数值参考 | INT32组内精确；R0恢复；group升序非FMA FP32累加 | 推断 | 09§2 |
| 矩阵尾部 | act第二层N2仅2有效输出，物理8lane | 工程事实 | 04/09、13 |
| 输出 | F32、Linear bias按图完成后8feature/clk排出 | 推断 | 09§2/§4 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [05_hbm_loader_and_cache.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:25)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:46)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:54) | 权重/scale加载、缓存bank及F0/F1交接 |
| [08_activation_quantizer.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:46) | 量化输入格式、保存scale、A8重放与就绪条件 |
| [09_q8_linear_and_restore.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:50)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:65) | 整数dot、scale恢复、部分和、输出顺序及上下游速率 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | LN→量化→Linear供需、tile所有权与背压/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| READY | A8 tile与整张当前矩阵权重 | 检查cache/model/group上下文 | 输入和PS bank可用才发射 |
| DOT/RESTORE | 每行32A8与每列32W8 | 32项精确dot，恢复一个FP32 term | 后级PS有空间且反馈距离足够 |
| ACCUMULATE | 同输出按group升序 | acc=FP32(acc+term)，按输出tile轮转 | 最后group实际退休才可排出 |
| BIAS/DRAIN | 完整PS | 依图加Linear bias，有效feature按序送消费者 | 全部被消费后PS释放 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| A8 | quant/cache→Linear | 16×32个S8/issue＋16scale | group及有效M一致，跨N复用 | cache要提供并行16行读口 |
| W8 | weight cache→Linear | 8×32个S8/issue＋8scale | 与A8同group、当前输出tile | 跨全部token tile复用 |
| 组结果/PS | dot/restore↔PS | 128 INT32→128 F32更新/issue | 每个输出的group顺序固定 | PS反馈Lacc限制真实II |
| F32输出 | PS→RoPE/向量/heads | 最多8feature/clk | QKV为Q/K/V顺序；Wi可4U＋4G配对 | 输出有效/尾部及bias阶段不能丢 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- R0 term=FP32(FP32(scale_a×scale_w)×FP32(dot))；随后单独acc=FP32(acc+term)，不能FMA合并。
- R1仅在与R0 term逐位对账且资源有收益后采用；不改变组间FP32累加。
- FP16 scale次正规必须保留；scorer post bias不是Linear baked bias，分两步。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| PS双bank | 16×5248×4=335872bytes/bank | 全group更新→读出/bias→释放 | 读出8lane不足以直接接每拍128结果，整tile存储吸收 |
| A/W cache | 由05统一安排 | A8一tile跨全部输出；W一矩阵跨全部token | 输入窗口供给不能来自单个HBM逐拍直读 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 同一PS地址两次更新间距ceil(N/8)；需≥Lacc且RAM端口足够才可能每拍issue。N2只有一个输出tile，必须安全等待。
- Wi/down共享引擎；PS双bank可将dot当前tile与旧tile读出重叠，但需要真实独立端口。
- U/G相差2624列可能落同bank，配对输出需双读口或承认降速。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [q8_linear_and_restore.h](../../../../hls/operators/q8_linear_and_restore.h)、[q8_linear_and_restore.cpp](../../../../hls/operators/q8_linear_and_restore.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_q8_linear_and_restore`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 数值 | 实际GGUF矩阵与边界activation | q→dot→term→每group partial→最终bias输出逐级对账 |
| 反馈与尾部 | N2、M不足16、最后group延迟 | 无读后写冲突；无效lane不更新/输出 |
| 整链 | 量化→dot→恢复→PS排出并随机背压 | 真实资源/II包含全部阶段，不能只验dot |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/q8_linear_and_restore/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G4 DSP packing、恢复成本、Lacc、RAM绑定/真实II和Fmax；G3 R0/R1参考。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

接受LinearTask(TaskContext,a,w,ps,dst,WeightKey,K,N,dst_region,bias_kind)。K/N和family由15§10.2固定；必须检查A8 rows/K/epoch、WEIGHT family/layer/K/N/model身份和空PS。一个任务计算当前rows×全部N，权重跨全矩阵token tile驻留；act K256/N2只开2列。

DotIssue按15§13.2包含task_id、a/w/ps epoch、group:u8、n0:u16、valid_rows:u5和valid_cols:u4。每次读取16×32 A8及8×32 W8，分别附16/8 scales；无效行列完全屏蔽。INT32组dot与原标签／scales一起保留至恢复，R0先FP32(sa*sw)再乘dot，再单独FP32加到PS。同一输出group严格升序；反馈未退休不能再次改写同一PS地址。

PS按row*8+n%8的128逻辑bank、addr=n//8组织。实际RAM端口和FP latency不足时插入停顿，不改归约顺序。最后group退休后按row/col升序加绑定Linear bias并排F32Beat；每行N8向上取整拍，N2有效数2。scorer baked bias与后续vector post bias保持两次操作。QKV column0…1023/1024…2047/2048…3071对应Q/K/V，由store scatter到04地址；Wi保持U整半/G整半，不能在通用输出流误标为连续4U+4G。

done在PS读出全部接受、目的写响应完成之后；PS和A8在此之前不可复用。真实矩阵权重必须源自固定GGUF逆重排，输入来自abi_replay对应节点。native Linear输出及直接捕获activation scratch是模型参考，候选q/dot/term/PS应另行独立生成；尚无candidate实现，不声称R0/R1或全网逐位通过。TB联接quant/cache/Linear/store，覆盖真实QKV、Wi、down、act N2及恢复流水末拍长停顿。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_qkv` | `ir_237 / linear` | `native/forward_0/ir_237.bin` |
| `enc0_attention_project` | `ir_266 / linear_1` | `native/forward_0/ir_266.bin` |
| `scorer_fc1_with_bias` | `ir_1461 / linear_120` | `native/forward_0/ir_1461.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

量化的直接backend参考另见manifest的`native_quantized_activation_scratch`：122次实际MUL_MAT输入scratch，34B/组（FP16 d＋32 S8），每项记录consumer node、shape、bytes和hash；例如`audited_outputs/native_q8_activation_linear.bin`对应Encoder0 QKV。硬件candidate dot/term/PS内部值尚未导出/实现，不能据此宣称这些值已逐位验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对LinearTask的op/WeightKey/stage/行空间/K/N/目的region、输出数量、N2尾列和DotIssue字段；状态辅助检查只核对A8/W的epoch及Q8_TILE/Q8_WEIGHT内容类型。尚未把A8的K/rows/batch/row0/row_space及源epoch、W的WeightKey/K/N与当前任务逐项关联；该绑定、PS反馈退休和真实点积/恢复运算必须在后续计算链前补齐。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。

## 13. P1完整K的Q8-F输出窗口（2026-10-07，Astra xhigh）

本轮实施和验收以[task.md §11](../../../../hardware_agent/task.md)为共同合同；重读[09§2/§3/§5](../../../design_source/09_q8_linear_and_restore.md)、[总体§5.1/§5.4](../../../../source/laya_baseline_design.md)及[15§10–14](../../../design_source/15_integration_interfaces_and_pipeline.md)。本节是全矩阵Linear内部切片合同，保持原§10全N任务及单forward路线；切片返回不发布整张QKV/WI/TMP，不生成全Linear TaskDone或满足全层coverage。

唯一新维护源`hls/operators/q8_linear_compute.cpp`；公共接口`include/laya_numeric.h`及`laya_numeric_tasks.h`；模块`tb/numeric_tb.cpp`、独立`tests/numeric_reference.py`和top真实fixture驱动。输入完整LinearTask的K/N/WeightKey仍按原规格，另给n0为8倍数及cols=min(8,N-n0)。rows≤16、完整K=256/1024/2624/4096，A8数组`q[16][128][32]`/scale[16][128]、W窗口`q[8][128][32]`/scale[8][128]、bias[8]，输出F32[16][8]及slice状态。有效cols以外不读写，act N2只访问2列。

任何计算前将A8的请求全身份、ref/epoch、K/rows/batch/row0/row_space、stage/layer和原F32 src/region/epoch与当前任务及**独立expected source**匹配；W必须匹配model/request/generation/数值/布局/构建身份、WEIGHT ref、family/layer、完整K/N、n0/cols和bias绑定。READY覆盖的是窗口cols×K/32，不能冒称整个W缓存已加载。切换窗口先失效并换epoch；READ/FILL/缺coverage、旧request/generation、错WeightKey或来源都必须拒绝。PS/结果初始invalid，所有group和bias完成才发布rows×cols；失败不发布，返回即切片全部访问结束。

每个输出的INT32 dot是32个S8乘积精确之和，sa/sw从原FP16位模式扩展；R0 term=FP32(FP32(sa×sw)×FP32(dot))；acc初始+0，group严格升序单独FP32相加，最终有绑定bias才加一次，不能无bias额外+0或把scorer post bias合并。保留half次正规及signed-zero term，所有恢复/累加中间必须有限。负有限scale非法，-0保留IEEE零语义。q/scale/dot/term/每group partial与独立oracle逐位验收，native GEMM只报告误差。R1和其他归约版本不在本批实现范围。

切片先逐row/col/group/k串行；单个acc完成后再做下一group，无错误DEPENDENCE pragma，无II=1保证，不展开TM16×TN8阵列。8列W最大34816B、输出最大512B是逻辑容量；实际RAM端口/资源/II以isolated综合报告为准，不能借用原候选阵列的吞吐估算。外部生产W整矩阵常驻、A8复用和完整PS设计仍保留待集成。

真实权重窗口：QKV n0=0/1024/2048/3064；Wi n0=0/2616/2624/5240；down n0=0/1016；act n0=0、cols2，两题分别BATCH rows1。每列完整K不抽减；q/half scale按GGUF offset逆拼34B逐字节核验。主联链ir_267→候选LN→候选quant→Wi，另外native quant输入隔离比较、K2624末group、K256/N2及真实act bias必须覆盖。trace逐group对账，定长输出guard确保无效列不写。状态差异、native差异和数值例外不能由最终答案一致掩盖。结果/工具/未执行硬件阶段独立记录在[results.md](results.md)。

## 14. P1实际代码映射与窗口所有权（2026-10-07）

- [q8_linear_compute.cpp](../../../../hls/operators/q8_linear_compute.cpp)为完整K的row/col/group/k串行计算入口及只读`q8_linear_trace`回放入口；[laya_numeric.cpp](../../../../hls/common/laya_numeric.cpp)完成A8来源、W窗口/完整权重与偏置字节范围、请求四tag、PS与目的ref的验证和owner生命周期。P0 [q8_linear_and_restore.cpp](../../../../hls/operators/q8_linear_and_restore.cpp)仍为主机合同模型。
- 每列先逐group计算32项精确I32 dot，再按FP16→F32、scale乘、dot乘和group升序FP32累加；只有bias_kind=1在所有group后额外加一次。入口先验证独立预期F32来源、A8和W元数据，PS/目的两个ref一起领取新epoch并置FILL；全部rows×cols成功后置READY并记录精确输出数，`output_beats=0`。失败保持已领取epoch且不发布部分数组，reset清输出计数但不倒退PS/dst版本。
- [numeric_tb.cpp](../tb/numeric_tb.cpp)覆盖±127乘积极值、组内抵消、±0 term、2²⁴/1/−2²⁴组顺序舍入反例、act bias与N2 guard、补充K4096/128组末项、A8和W逐字段变异及PS/dst双ref生命周期。[numeric_fixture_test.py](../../top/tb/numeric_fixture_test.py)逐有效row/col/group回放dot/term/partial，并按GGUF完整K/N字节范围及n0窗口读取真实权重；native输出和scratch仅做差异报告。
- [numeric_hls_linear.cfg](../../../../config/numeric_hls_linear.cfg)对实际计算入口执行isolated CSim。该切片不输出完整Linear TaskDone、不发布整矩阵覆盖，也不连接生产HBM/PS AXI或QKV scatter；本轮Linear综合/布局布线未执行，阶段性证据见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/09_q8_linear_and_restore.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

P2 LinearTask计算同题rows≤16的完整K/N，W已完整驻留；PS每tile领取一次，内部n0窗口既不递增共享dst epoch也不发完整done。可提取P1纯单输出算术共同维护，禁止复制漂移。完整tile所有N/bias/写回结束后done=rows×N并登记目的覆盖；QKV按plane/head/feature散写，两shard全覆盖才RAW_READY。scorer FC1同SCORER_ACT原地通过旧/新epoch lease逐行消费后覆盖。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [q8_linear_compute.cpp](../../../../hls/operators/q8_linear_compute.cpp)：本模块当前P2实现责任源。
- [full_tasks.cpp](../../../../hls/operators/full_tasks.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

本模块仅把实际使用的数值cache数组接入固定访问器；数组shape、元素类型、请求/任务上下文、数值leaf、算术顺序、有效范围和发布/读取边界保持。synthesis解析到对应唯一全零global，CPU保持每Runtime独立数组。共享存储组织、初始化/回收合同和唯一64bit存储打包由kernel_wrapper及hbm_loader_and_cache统一维护，不另复制数组或增加并行算术实例。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。Q8矩阵与恢复算术文件逐字不变；固定cache访问器和打包仅改变存储组织，不改变Q8位模式、缩放/偏置顺序或F0发射合同。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
