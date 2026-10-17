# Attention与共享浮点引擎：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/attention_and_fp_engine`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

执行完整S范围内的QK、finite mask、softmax和AV，并在attention释放后复用FP资源执行scorer F32末层及act F16首层。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 模型attention | 16head、head64；双向full/sliding有限mask | 工程事实 | 11§1、10 |
| 共享算力 | 候选64路FP；QK/AV/浮点尾层分时 | 推断 | 11§1/§5 |
| 参考顺序 | QK相邻树；AV按key升序非FMA；完整行softmax | 推断 | 11§2 |
| 缓存策略 | 当前head KV跨全部query复用；query tile16 | 推断 | 11§1/§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [05_hbm_loader_and_cache.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:25)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:38)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:54)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:62) | FP引擎的缓存端口、供数与加载交接 |
| [10_rope_and_mask.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:28)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:49)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:63) | half-split RoPE、QKV就绪、有限mask及attention交接 |
| [11_attention_and_fp_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:35)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:53)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:70)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:76) | QK/softmax/AV依赖、缓存端口、周期和共享FP尾层 |
| [13_decision_scorer_act.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:31)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:47)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:70)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:78) | scorer/act共享FP资源、混合精度及生命周期 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:84)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | Attention联合流水、QKV交接及共享资源/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| LOAD_HEAD | 当前层QKV屏障已满足 | 加载当前head的K/V；准备Q tile | 必须确认对应shard/context |
| QK/MASK | 64维Q/K | 64项FP32乘积固定树，乘0.125再加已合并bias | 当前query全部S score到齐 |
| SOFTMAX | 完整score行 | max→exp/固定树sum→normalize | 完整prob可供AV读取 |
| AV/DRAIN | prob与V | 对每输出按key升序乘后加；交错query隐藏反馈 | 最后key退休，按8lane排出 |
| FP_TAIL | attention全部完成后 | 切换广播/归约模式供scorer/act | 前一缓存和引擎已释放 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| QKV | qkv/cache→FP | Q tile，K/V每head64F32窗口 | 一个head只从一个QKV shard读 | 下一head预取需要另一个空KV bank |
| score/prob | QK↔softmax↔AV | 每b/query有S个F32 | 固定完整行、key顺序；max/sum屏障 | QK填充→softmax改写→AV读→释放 |
| attention输出 | AV→att_out→Q8 Wo | F32[B,S,1024]，每head64结果 | 各head填回对应feature范围 | 最后累加退休后才读出 |
| 浮点尾层 | heads↔FP | F32[1,1024]或F16[256,1028]权重 | 按输入维升序，F16精确转F32 | 没有A8量化，模式切换单独计时 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- QK固定64项相邻二叉树；mask的先合并后加顺序由10保证。
- softmax对所有有限score减max、exp、固定树sum、除法；不直接换在线softmax。
- AV每输出按key递增独立FP32乘后加，无FMA；交错query不改变每输出顺序。
- 浮点尾层保持k升序、bias/GELU时点；1028维尾部不是补成Q8组。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| KV双bank | B2/S1024每head K+V1MiB，双2MiB | 当前head所有query读完才释放 | 另一shard预取不是同head带宽翻倍 |
| score/prob双bank | [2,16,1024]F32每bank128KiB | softmax原地改写，最后AV读取后空闲 | 双bank才可能重叠独立softmax |
| Q tile/AV partial | B2/TQ16时各8KiB | key累加结束前保留AV旧值 | 64路旧partial读/新值写端口必须成立 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- QK与AV共用引擎，时间相加；softmax虽可独立，但完整行和bank交接仍形成依赖。
- 专用窗口一次64F32=256bytes，不能用普通8lane的32bytes通路直接喂满。
- 若16个query交错仍不足覆盖FP加法反馈，实际II需降速并写入results。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [attention_and_fp_engine.h](../../../../hls/operators/attention_and_fp_engine.h)、[attention_and_fp_engine.cpp](../../../../hls/operators/attention_and_fp_engine.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_attention_and_fp_engine`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 整链数值 | QKV→score/bias→prob→AV；普通/极端/全finite mask | 每query有S个score/prob和64结果，逐阶段比参考 |
| 反馈与生命周期 | 不同S、随机暂停、head切换/预取 | 不乱key序、不早复用KV/score、无FP资源冲突 |
| 尾层 | scorer小输出、act1028输入及ties相关输出 | 模式和F16转换正确，与heads联合 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/attention_and_fp_engine/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3 exp/div函数/误差；G4FP反馈、64路窗口、RAM端口、实际II/资源；G1时钟。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

本模块接受QKTask、SoftmaxTask、AVTask、FPLinearTask四种具体类型；字段见15§12。QK/AV/两种FP Linear共享一个候选64路FP引擎，F0分任务互斥；softmax亦与它们串行调度。QKTask有head0…15、S、mask_mode和固定scale 0x3e000000；AV必须消费同一b/head/query范围的PROB/KV。

| 模式 | 读窗口／输出 | 顺序／发布 |
| --- | --- | --- |
| QK | Q_TILE rows×64，KV K[S,64]→SCORE rows×S | 每score64乘积固定树；query升序、key升序；全tile写入后READY |
| softmax attention | SCORE→PROB，length=S | 完整row max→exp/sum→normalize；原地时独占old/new epoch |
| AV | PROB[S]与KV V[S,64]→ATT_OUT rows×64片段 | 每输出key0…S-1非FMA；反馈未退不更新；末key不等于done |
| FP scorer FC2 | F32权重[1,1024]＋marker rows | k升序，输出每行1值、valid_count1，写CAND_RAW |
| FP act FC1 | F16权重[256,1028]＋ACT_INPUT | F16精确扩展F32，k1024…1027是stats，输出256值 |

Q/K/V和AV partial需要64独立逻辑feature窗口，普通8lane stream只用于加载/排出；不能用32B/clk端口假称供给256B/issue。SCORE_PROB为[2,16,1024]固定stride，当前task只处理一个b的rows；KV在整head全部query完成前不可覆盖。F0 softmax和AV均等前一个数组READY，禁止有限FIFO跨串行任务互相等待。

真实参考选择abi_replay QKV、融合attention输出及FP末层节点；原生FLASH_ATTN_EXT的K/V/mask经F16 CPY，内部score/prob不可导出，显式FP32 score/prob只能记candidate回放；按manifest的GGML ne/nb取值，不能把非连续VIEW直接reshape。对native／candidate不同归约逐阶段报告误差；直接捕获的原生quant scratch以manifest为准，内部dot/term未捕获不补造。联合测试延迟QKV最终响应、prob最后拍、AV反馈和act末4输入；task完成时确认所有64路在途结果已被保存。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_rope_q` | `ir_255 / add_2` | `native/forward_0/ir_255.bin` |
| `enc0_rope_k` | `ir_262 / add_3` | `native/forward_0/ir_262.bin` |
| `enc0_attention_fused` | `ir_264 / transpose_3` | `native/forward_0/ir_264.bin` |
| `scorer_fc2_with_bias` | `ir_1463 / linear_121` | `native/forward_0/ir_1463.bin` |
| `act_fc1` | `ir_1614 / linear_122` | `native/forward_0/ir_1614.bin` |

原生融合attention内部QK score／probability明确未捕获；native K/V/mask的F16转换和FLASH_ATTN_EXT与候选FP32显式链分开登记。此处不能把candidate生成的score/prob称为上述alias的native节点。

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对QK/Softmax/AV/FPLinear任务的模式、shape字段、来源目的region及输出数量，并在状态辅助函数中区分QKV_RAW/QKV_FINAL和SCORE/PROB。尚未关联QKV的plane/head/B/S与请求/layer完整覆盖，也未实现KV缓存完整身份、全层屏障或真实QK/softmax/AV数值链；同内容标签的对象仍须在后续接入前补齐数据身份校验。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。


## P2 A批：完整QK/softmax/AV与混合类型尾层（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§1–6](../../../design_source/11_attention_and_fp_engine.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/attention_full_compute.cpp`，提供task§12.3的qk_row、softmax_row、av_row、fp_scorer_row、fp_act_row。QK每score为64项相邻树，softmax对完整S固定树，AV按key升序非FMA；S桶64…1024全部支持，候选softmax长度16。scorer K1024/N1的bias在FP层末加；act F16 K1028/N256此时不加bias，后交向量GELU。native FLASH_ATTN_EXT的F16 K/V/mask及未暴露内部值仅作差异诊断，独立候选oracle生成score/prob；CPU/CSim逐位与RTL非线性工程线分开记录。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/11_attention_and_fp_engine.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

完整QKTask逐rows处理所有S，KV绑定同request/layer/head/B/S及QKV_FINAL来源；SCORE齐后Softmax独占转换到PROB，AV按key升序写当前head64维。ATT_OUT按head/batch/row覆盖，16head全部完成后整矩阵READY。FPLinearTask真实读取aux F32/F16及绑定bias，完整K/N计算；act FC1的post bias归向量任务。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[attention_full_compute.cpp](../../../../hls/operators/attention_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`qk_row / softmax_row / av_row / fp_scorer_row / fp_act_row`。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_attention.cpp](../../../../hls/operators/full_tasks_attention.cpp)：本模块当前P2实现责任源。
- [full_tasks_tail.cpp](../../../../hls/operators/full_tasks_tail.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
