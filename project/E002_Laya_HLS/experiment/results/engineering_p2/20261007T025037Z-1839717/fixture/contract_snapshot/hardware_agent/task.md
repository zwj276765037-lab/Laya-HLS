# 任务记录：Laya / U55C规格统一与模块目录

日期：2026-10-05（Asia/Shanghai）。规格修订：统一规格v1.0。

## 1. 用户要求与工作边界

当前续任务按用户最新要求细化接口，并使用真实Laya量化微调模型推理数据；本次范围、角色和证据见第9节。source继续只保留design.md/results.md，原规格通过design.md中的路径与章节定位；此前复制记录属于第7节历史阶段。

将`Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source`内多版本Markdown按hardware-agent标准汇总为一套当前版本，保留总体与模块划分，以及关联模块的接口、性能和流水评估。

本次只整理规格、现状、缺口和验证计划；不包含RTL/HLS实现、工具安装、远端执行、GPU测试或U55C测试。最终部署目标沿用本会话已指定的Typed-Decisions Q8模型和U55C，具体方案状态见[总体规格](../vivado/design_source/00_overall_design.md)。

采用[hardware-agent技能](/home/zwj/.codex/skills/hardware-agent/SKILL.md)及[规格字段与证据规则](/home/zwj/.codex/skills/hardware-agent/references/specification.md)。已读根目录AGENTS.md；未调用Claude共享会话。本任务由主代理整理文档，按技能委派GPT-6 Astra负责规格解释与文档审核；仅规格整理，无需启动Sol硬件实现代理。

## 2. 输入、交付与维护位置

- 输入：原17份当前模块文档、archive中的16份旧稿和说明、source中的模型研究、两个Llama baseline源码、模型配置与既有软件报告。
- 当前唯一入口：[design_source/README.md](../vivado/design_source/README.md)。
- 规格结构：00总体、01–13模块、14验收、15共同接口、16源码对应。所有文件使用统一规格v1.0。
- 技能索引：[spec.md](spec.md)，只链接同一套正文。
- 历史备份：[归并前35份Markdown](../vivado/design_history/design_source_before_unification_20261005.tar.gz)及[逐文件SHA-256清单](../vivado/design_history/design_source_before_unification_20261005.manifest.json)。备份完整性逐文件验证后移出目录内旧archive；不丢弃原始资料。
- source/laya_baseline_design.md保留推导，增加来源说明，当前硬件方案和状态按统一文档维护。

## 3. 本次实际检查记录（S6）

以下为2026-10-05当前工作区的实际检查，不能替代硬件报告。

| 检查对象/方法 | 实际结果 | 证据范围 |
| --- | --- | --- |
| 目标工程定向文件检索 | 归并前只有source与design_source设计文档；没有Laya HLS/RTL/XDC/testbench或构建入口 | 本项目现状；不推断其他工程或远端 |
| 适用AGENTS.md检索 | 根目录共享Claude说明；目标路径未发现额外AGENTS.md | 本次文档编辑规则 |
| 7B：git rev-parse HEAD / status --short | `69d70e3d5906570a49d2d959c4b39be37f243c66`；clean | 只读源码身份 |
| Tiny：git rev-parse HEAD / status --short | `ee327e91cd69cb8ed6dc1fc735af4c3ee5931236`；clean | 只读源码身份 |
| 两分支逐文件字节比较 | host/llama2.cpp、src/forward.h、src/typedefs.h、src/u55C1.cfg、hardware_implement.sh全部相同 | 这5组源文件；不是执行结果 |
| Typed GGUF完整文件SHA-256 | `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；455179648bytes | 本次重新读取文件复核；未重新执行全图分析 |
| 当前shell PATH工具查询 | v++、vitis-run、vivado、xclbinutil、xbutil均未找到 | 不等于未安装；未检查其他环境入口/远端 |
| 既有Typed软件报告阅读 | 76.85%准确率、98.55% FP/Q8答案一致率，报告日期2026-09-27 | 历史软件数据；不是Laya FPGA结果 |
| 备份逐文件回读hash | 35份Markdown均与备份前源文件一致 | 仅备份完整性 |

## 4. 本次文档验收

检查范围：唯一当前版本、来源与状态、关键数值语义是否保留、相邻模块是否一致、局部文件链接、Markdown表格与代码围栏、已给出的帧容量/张量容量/周期算例。

验收状态：本次文档归并完成，静态检查通过，GPT-6 Astra完成稿审核结论为“本次文档归并可验收”。硬件C仿真、RTL仿真、综合、布局布线、时序和上板全部未执行。

| 本次文档检查 | 结果 |
| --- | --- |
| 当前文档集合 | 17份总体/模块规格＋1份README；目录内无旧archive |
| 本地引用 | 检查21份Markdown中178处本地引用，均可定位 |
| 格式与修订 | Markdown表格列数/代码围栏通过；17份规格均为统一规格v1.0 |
| 条件算例 | 请求帧1856/10816bytes、核心张量1448/10408bytes、workspace125.625MiB、BO预算、6类Linear周期及attention5248cycles均复算一致 |
| 历史备份 | 归并前35份Markdown逐文件SHA-256一致，压缩包hash一致 |
| Astra审核 | 关键语义、来源状态、F0/F1、接口/缓存/复位、验收范围完整；提出的Q8逻辑payload已明确为272bit |

以上“通过”仅指文档、备份及条件算例检查，不是硬件自检PASS或性能达标。

## 5. 主要缺口与下一实施关口

G1–G7统一登记在[00总体规格§10](../vivado/design_source/00_overall_design.md)：真实U55C平台/复位环境、共享ABI、Golden-C与真实输入、物理资源/带宽、错误恢复、正式验收阈值、同口径A6000对照。这些不阻碍本次文档归并。

下一实施关口是共享配置/IO、GGUF导出器、独立软件参考与真实请求帧；实现范围按后续任务推进。不要从旧版本恢复手写寄存器/CMD256，也不要把150MHz、13 master、TM16×TN8、资源比例或25ms研究场景当作已验收配置。

## 6. 续任务：建立RTL模块目录

2026-10-05用户授权在`vivado/rtl`定义各模块文件夹。本阶段仅建立目录和说明，不编写RTL/HLS或执行硬件测试。

已建立15个子目录，覆盖总体集成、公共定义、平台封装、调度、硬件地址、HBM/缓存、Embedding、LN、量化、Q8 Linear、RoPE/mask、attention/FP、向量/FFN、Decision/scorer/act、结果状态。当时入口现位于[module_design/README.md](../vivado/module_design/README.md)，每个目录有职责、上下游、共同约束和规格链接。

GPT-6 Astra已核对目录与v1.0规格的映射；主代理建立目录与README。目录划分保留共享引擎关系及既定HLS路线，CPU软件和测试台分别由软件目录与相邻testbench管理。本次无需启动RTL实现代理。目录、说明文件与本地引用已检查；当前仍无Laya RTL实现、仿真或上板结果。

## 7. 续任务：module_design按模块标准规范化

2026-10-05用户指定在`vivado/module_design`按新hardware-agent标准整理各模块。接到本次请求时该目录已有15个模块入口，原`vivado/rtl`及`vivado/testbench`已不存在。本次沿用最新指定目录，修正活跃文档的旧路径链接；此前第6节仅记录历史阶段的目录安排。

已完成：

- 每模块建立`source/`、`rtl/`、`tb/`，共45个标准子目录。
- 复制主要原规格和相关02/15等共同约束，合计73份原文副本，覆盖17份源规格；逐字节及SHA-256一致。当时原路径、版本、复制日期与hash记录在各design.md及`source_manifest.json`。这一复制安排已由第8节的新标准替代，副本及清单已移除。
- 15份`design.md`具体定义模块职责、来源状态、阶段、逻辑接口、数值、时钟复位、缓存生命周期、联合流水、实际代码位置及验证矩阵。
- 15份`results.md`记录平台/配置、资源归属、候选频率、可复算容量/周期/带宽及各阶段状态。实际LUT/FF/DSP/BRAM/URAM、时序和上板值未测时明确保留未知。
- RTL/TB目录目前只有用途说明；模块测试归各自tb，整网联测归top/tb。Host/HLS与自动生成RTL保留既定工程边界，没有建立第二套实现。

GPT-6 Astra完成稿审核通过：独立核验73份快照，核对15模块的数值、接口、共享资源和主要周期算例。审核建议已处理：明确移除的是可逻辑生成的slide_bias表，保留full/sliding RoPE四张表。

本次静态检查覆盖目录、原文hash、Markdown表格/围栏、本地引用及条件算例。复算包括Q8的272bit组、LN6008832cycles服务、RoPE196608cycles/层、attention1343488cycles/层、缓存大项14.4140625MiB、scorer1024×1024及act的8224cycles算量下界；全部按各自前提解释，不能作为实测性能。

本阶段交付完成，入口见[module_design/README.md](../vivado/module_design/README.md)。仅执行文档/目录与算式检查，未执行模块C/RTL仿真、综合、布局布线、时序或U55C测试。下一实施工作仍须依据同一套原规格、design.md与results.md推进。

## 8. 续任务：原规格改为位置引用

2026-10-05用户要求原规格直接在design.md中指定位置，不再复制到模块source。当前标准覆盖第7节当时采用的复制安排。

- 15个模块的design.md第2节改为权威文件路径、可跳转的章节位置和模块约束说明；保留第1节及第3–9节的技术设计。
- 删除前重新逐字节及SHA-256核对73份副本，均与17份原规格一致；移除重复副本及source_manifest.json，权威规格继续保存在design_source。
- 每个source只保留design.md/results.md；results、模块README、总体入口和技能索引的引用一并更新。资源/周期/带宽估算及rtl/tb用途说明保留。
- hardware-agent规范、模板与工程角色同步采用路径/章节引用；来源变动后核查引用和受影响的接口、数值、流水及测试。

完成稿检查：15个source目录均只有两份文档；与编辑前记录比较，详细设计正文、数值估算和RTL/TB说明保留。96份Markdown的988处本地链接、其中323处原规格章节行号均可定位，表格与代码围栏检查通过。hardware-agent技能校验通过；技能源、安装版和ZIP的25份文件逐字节一致，4份工程/模板角色TOML解析通过。GPT-6 Astra独立审核结论为ACCEPT，未发现需返工问题。

本阶段仅整理文档引用和目录，硬件仿真、综合、布局布线、时序及上板均未执行。


## 9. 续任务：详细接口合同与真实Typed Q8参考

2026-10-05用户要求“先进行更细致的接口定义，数值参考使用真实Laya量化微调模型推理数据”，并明确文档撰写／接口定义／审核采用GPT-6 Astra＋极高（xhigh）。本阶段由**GPT-6 Astra（reasoning_effort=xhigh）实际撰写接口并作第二遍设计复核**；GPT-6.1 Sol负责真实参考采集工具、固定GGML CPU构建与运行；根协调代理负责独立字节算式／文件来源／数据证据检查。额外独立Astra审核代理受并发名额限制未启动，不写成已获独立Astra代理验收。

本次授权包含文档与真实软件参考工程；没有编写Laya RTL/HLS，没有修改技能，也没有执行Vivado/XSim、综合、布局布线、时序或U55C测试。已有历史目录和验收记录保留为历史事实，不代表本次实现已经通过。

已落地到现有单套文件：

- 01§6：128B请求头、5×32B目录、精确字段/offset/类型/校验；保留1856B样例的320/1344/1600/1728/1792及最大10816B帧。
- 14§9：结果起点16384、128B头、candidate128／act256、状态码/诊断/计数与排空；定义384B有效结果格式，不新增轮询寄存器。
- 04§7：固定工作区base、HEAD_WORK八子区、buffer身份与模型WeightKey、Q8分片公式；13 BO顺序仍按02。
- 15§10–§16：TaskContext、各类算子参数、op枚举、BufferRef/bank/epoch与region所有权、358bit普通/配对F32及350bit Q8组、尾拍、done/错误/复位和F0联测。
- 15个模块source/design.md：精确绑定、输入输出数量、所有权／屏障、真实节点alias和当前验证边界；results.md只登记软件参考来源，保留硬件未执行。

F0一个算子任务在途，模块间阶段边界是完整READY数组；同一任务内的搬运/计算可以通过有消费者同时工作的有限stream连接，禁止生产者写满小FIFO后等待下一串行任务。F1融合/重叠未启用。HLS C++单forward核→Vitis/xclbin→XRT路线保留，文档接口并非已生成RTL端口；150MHz、阵列/64路FP/13master仍为候选。

### 9.1 实际软件数据与区别

真实模型455179648bytes，SHA-256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。固定GGML源码commit `dcc300def5c5bc8fa778223589244abb0555a5de`，CPU单线程，最终binary hash与插桩hash登记在[reference入口](../reference/README.md)和各manifest。

[original_native](../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)实测B2/S94，masks原生F32，无效marker全局idx0；[abi_replay](../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)实际再次运行B2/S128，valid marker按新S重映射、invalid改本题CLS，0/1 F32 masks另编码U8。各包1698tensor记录、42aliases、122真实Q8 activation scratch、32preCLAMP快照；非连续storage span按ne/nb读取。

1856B request_v1.bin与五输入解包逐字节一致，numeric/layout/build tag为零占位且production-ineligible。两profile有效candidate和act在本例逐位一致；部门无效candidate的最大差为0.2529296875，完整16列期望不能混用。最终capture与正常allocation的两个raw输出逐位一致，数据hash检查见各verification.json；这些不是硬件PASS。

实际CPU有122次Q8_0×Q8_0 converted llamafile GEMM和30个FLASH_ATTN_EXT（K/V/mask F16），与候选FP32显式attention／Q8-F算术分开。融合内部score/prob不可捕获；act原始p从preclamp_31读取，末尾softmax已被CLAMP覆盖。候选dot/term/PS、完整candidate全图和正式误差／质量门槛仍待验证。采集耗时含磁盘导出，不作性能对照；本批只覆盖noul/choice两题，score、B1、其他S及质量回归未执行。

### 9.2 Astra xhigh第二遍复核与开放项

第二遍逐项检查请求/结果字段覆盖、目录公式、13参数顺序、任务枚举/参数对应、bank与shard区分、F0数组/stream可执行性、原地old/new epoch、HEAD_WORK子区并存、TYPE_ROWS有效行、尾部数量、错误排空和真实数据checkpoint时间语义。复核修正：LoadTask移除无枚举的tile类型（tile搬运归所属任务MemTransfer）；原地RoPE/softmax明确src/dst epoch；HEAD_WORK按region独立所有权，避免生成act使candidate失效；原生F32 mask/全局invalid marker和F16融合attention事实与ABI／候选方案分开。

文档合同可用于下一步共享头、候选参考及模块TB实现；尚不能据此放行硬件正确性。G2仍需共享头/生成接口/Host联调，G3仍需硬件模型导出与candidate数值闭环，G1/G4/G5实际平台、IP延迟/物理bank/FIFO/恢复未知，G6/G7质量和配对GPU未完成。后续更新同一套文档，不另存多版本接口稿。

本次根代理独立机械检查已核对96份文档、1137处本地链接、368处章节行号（修正51处旧行号），表格／代码围栏和15个source仅两文件通过；另独立核验1856B帧完整头／目录／padding／五输入、122份scratch长度、preclamp概率、manifest二进制／补丁身份及capture-normal输出。后续最后小修仅补TaskDone输出计数单位和加载任务范围，相关行号再按正文刷新。Astra xhigh复核结论：**ACCEPT，范围仅为本次详细接口文档及真实软件参考交付**；不包含candidate全图数值一致、硬件实现／验证或性能达标。

最终追加机械核验：15模块中的62条实际alias／node id／数据路径全部与abi_replay manifest相符且文件存在；358bit F32Beat／WiPairBeat、350bit Q8Group位域总数一致。TaskDone已明确output_unit（F32标量／Q8组／bytes）和各任务公式，LOAD的参数／目标只读cache也已逐项绑定。

## 10. 续任务：P0模块工程基础搭建合同

2026-10-05用户询问“可以开始各个模块的硬件工程搭建了吗”，本轮按行动请求启动已具备规格依据的工程基础阶段。**开工判断：可以开始P0。** 当前01§6、04§7、14§9、15§10–§16足以实现共享ABI／类型／内存图、任务与缓存合同、15模块唯一源映射和真实fixture检查；这不意味着30层网络算术或U55C部署已经具备放行证据。

本轮角色按最新用户要求：GPT-6 Astra（`gpt-6-astra`，`xhigh`）定义本合同并审核产物；新工程代理GPT-6 Sol（`gpt-6-sol`，`max`）按合同实现、搭建及运行测试。第9节此前GPT-6.1 Sol采集事实保留为历史，不改写为本轮模型。根代理核查环境和证据，设计变更交回Astra。

### 10.1 本轮完成范围与明确未完成范围

| 领域 | 本轮必须完成的可执行内容 | 本轮不据此宣称完成的内容 |
| --- | --- | --- |
| 共享ABI | C++显式little-endian请求解析/编码、固定目录/边界校验、严格身份匹配、结果编解码 | XRT设备调用、实际生成控制寄存器 |
| 公共类型 | 所有分类型Task、op/状态/单位/BufferRef枚举、F32Beat/WiPairBeat/Q8Group显式pack/unpack与合法性检查 | 已生成358/350bit端口、实际FIFO时序 |
| 内存与所有权 | 13 BO索引、固定工作区/HEAD_WORK、地址验界、WI/DEC_FF别名、epoch/region/覆盖状态检查 | 实际HBM吞吐、物理bank/FIFO资源和AXI验证 |
| 15模块工程 | 唯一源文件映射、可编译契约接口、模块契约TB与总回归入口；未实现算术显式标注 | 15个数值算子已完成或15个独立Vivado IP |
| 真实数据链 | 只读abi_replay的1856B帧／原生输入／输出／Q8 scratch／preCLAMP，核对hash/stride/语义并做序列化回放 | 新一次模型推理、candidate全图数值一致或质量回归 |
| 工具工程 | 本机C++构建/CTest、环境清单、Vitis路线的配置/入口及缺项前置检查 | 无part/platform时的HLS综合、xo/xclbin、实现/上板 |

本轮基础函数要实际执行检查和转换；不以只写README或空函数返回true作为工程搭建完成。计算模块可交付**接口＋契约校验**，实现状态为`contract_only`；不得存在返回OK或复制capture logits的假compute/forward函数。完整forward目标默认不进入P0构建；若显式请求完整核构建而算子尚未完成，入口非0退出并列出缺失模块，不能产出能被误认作完整Laya核的文件。

### 10.2 唯一源位置、依赖与模块映射

仍是一个HLS C++ forward核→Vitis xo/xclbin→XRT。HLS源在项目`hls/`，共享头在`include/`，自动生成RTL留`build/`；既有15个模块目录保留source/design.md、results.md及rtl/tb。模块rtl在尚无自定义RTL时保留用途说明；不搬移/复制HLS源码到15份rtl，不生成15份独立Vivado IP工程。

以下是本轮实施路径合同；合理的内部辅助文件可由Sol增加，但不得形成另一套权威schema或模型参考。每模块design.md登记最终实际文件/编译目标及TB入口，路径以实际交付为准。

| 模块 | 唯一维护源／公共头（项目相对路径） | P0职责／依赖 |
| --- | --- | --- |
| common | include/laya_config.h、laya_types.h、laya_tasks.h；hls/common/laya_types.cpp、laya_tasks.cpp | 尺寸、枚举、逻辑bit字段、typed task/计数校验；不依赖Vitis头即可本机编译 |
| kernel_wrapper | include/laya_io.h；hls/common/laya_io.cpp；hls/platform/kernel_wrapper.cpp | 请求校验/身份策略、13 BO接口清单；共享io codec只有这一份 |
| memory_map | include/laya_memory_map.h；hls/common/laya_memory_map.cpp | BO/base/shape/stride、u64验界和Q8分片公式；模型导出base未给时不能编造 |
| forward_controller | hls/control/forward_controller.h/.cpp | 单任务在途、task_id/epoch、region/别名和coverage状态检查；不实现全图调度算法 |
| hbm_loader_and_cache | hls/memory/hbm_loader_and_cache.h/.cpp | LoadTask/MemTransfer校验、≤4KiB且不跨4KiB的分段描述；不执行真实AXI |
| embedding_engine | hls/operators/embedding_engine.h/.cpp | EmbeddingTask范围/位置/输出数量校验 |
| layernorm_engine | hls/operators/layernorm_engine.h/.cpp | LayerNormTask的stage/gamma/D/eps与引用校验 |
| activation_quantizer | hls/operators/activation_quantizer.h/.cpp | QuantTask K/rows/lane/region及Q8Group数量校验；native scratch只用于数据封装回放 |
| q8_linear_and_restore | hls/operators/q8_linear_and_restore.h/.cpp | LinearTask family/K/N/bias、尾N2、DotIssue/输出数量校验 |
| rope_and_mask | hls/operators/rope_and_mask.h/.cpp | RopeTask双shard/模式/stage/old-new epoch及计数校验；不宣称FP旋转实现 |
| attention_and_fp_engine | hls/operators/attention_and_fp_engine.h/.cpp | QK/softmax/AV/FPLinear的类型、长度、共享模式与尾部校验 |
| vector_and_ffn | hls/operators/vector_and_ffn.h/.cpp | op→长度/源目的、WiPair类型和pair_count、原地/残差引用校验 |
| decision_scorer_act | hls/operators/decision_scorer_act.h/.cpp | Gather/Stats/Concat的16列/4stats/1028/2输出合同校验 |
| result_status | hls/control/result_status.h/.cpp | 成功/错误帧字段组合和384B编码，调用共享io codec；不冒称实际AXI提交 |
| top | include/laya_modules.h；hls/laya_forward.h/.cpp | 15模块状态/依赖与单核接口契约注册；声明未来forward边界，P0不提供成功的神经网络执行入口 |

每模块TB唯一放`vivado/module_design/<module>/tb/contract_tb.cpp`（可共用`tests/`辅助库），总真实fixture检查放`vivado/module_design/top/tb/fixture_contract_test.py`或等价唯一入口。Python工具用于独立读取manifest／实际二进制和驱动C++检查程序，不能替代C++实现自身的编译测试。

根`CMakeLists.txt`配合`config/module_sources.cmake`（或同等单一构建源清单）列出15模块的编译目标和依赖；不得把构建输出目录的文件误加入源列表。可用一个基础静态库＋各模块契约目标共享代码，不能维护15份ABI实现。`host/laya_fixture_check.cpp`可作为纯离线检查可执行文件；真正XRT Host留给后续平台阶段，不引入假XRT库。

### 10.3 公共实现的精度与安全边界

- ABI完全按01§6/14§9的offset访问；逻辑C++结构体的sizeof不作为线上格式。u8/u16/u32/u64位宽静态断言，地址计算以u64验界后才窄化；保留原13参数顺序。
- 同一份共享头可在普通C++17构建中使用标准整数及raw F32/F16位模式，不要求安装ap_int/hls_stream。可提供受显式HLS构建宏控制的ap_uint适配，但无对应工具验证时标为未测，不伪装成已综合RTL。
- F32Beat/WiPairBeat逻辑358bit可在本机用45-byte packed数组承载，高2个存储padding bit必须为0；Q8Group逻辑350bit用44bytes，同样高2bit为0。HLS将来采用精确ap_uint位宽时不带这些存储padding。三种类型必须独立，WiPair valid_count计对数。
- 解析与生产身份校验分层：离线解包可读取现有零tag fixture；严格入口必须拒绝numeric/layout/build任一零tag，且逐字节匹配预期身份。测试专用非零身份只作为协议测试数据明确标记，不能发布为真实硬件build。不存在可由请求flags打开的身份绕过。
- TaskDone包含output_unit；F32计算按既定数量、QUANT按rows*K/32组、LOAD按byte_count、ROPE按rows*2*64 F32核对。P0契约函数不是算子TaskDone成功事件，不能因校验通过把未执行compute记为退休。
- HEAD_WORK以(id,bank,region)分别管理epoch，WI/DEC_FF共享物理占用锁；TYPE_ROWS按3个type有效位；QKV shard不能当ping/pong。要实际测试旧epoch、覆盖不齐、原地old/new转换与act写入时candidate仍有效。
- 正式kernel/AXI/FP延迟、FIFO深度、物理bank仍未冻结；P0的状态机与逻辑信用检查结果不可转换成周期、带宽或资源成绩。

### 10.4 构建、运行和证据入口

本机P0默认仅需C++17编译器、Python3和CMake/CTest。当前可复用`reference/cmake-3.31.8-linux-x86_64/bin/cmake`及相邻ctest；不要全局安装工具。应交付`scripts/preflight.sh`、`scripts/run_contract_tests.sh`、`scripts/run_hls.sh`（或同等命名）及根README，说明不同验证模式。

`run_contract_tests.sh`在独立`build/contract-*`或固定可复现build子目录配置/编译，执行CTest和真实fixture检查，任一失败返回非0；保存完整日志、命令、编译器/CMake版本、源码hash、测试统计及fixture/manifest/实际选用二进制hash到`results/engineering_p0/<run_id>/`。测试名使用`contract_*`、`abi_*`等明确范围；总结果为`ENGINEERING_CONTRACT_PASS`或等价严格标记，不能用数值/硬件全通过名称。

`preflight.sh`区分FOUND/MISSING/NOT_TESTED，独立记录g++/Python/CMake、Vivado、v++、vitis-run、platform/xpfm、XRT工具与设备。工具可执行不代表part/platform已知或许可可用。2025.2安装位置已由根代理发现，实际版本/路径/退出码由执行者写入运行记录，不把旧baseline2023.2组合当成本机事实。

`config/hls.cfg`／`config/u55c_link.cfg`继续表达一个kernel及13候选连接；器件／platform通过显式参数或环境提供，不填虚构值。`run_hls.sh`在缺必需工具/part/platform或模块实现未完成时明确非0停止；可提供`--check`/`--dry-run`输出计划，但不能用dry-run代替HLS C仿真或综合。P0允许完成软件合同阶段后把HLS/链接标MISSING_PREREQUISITE或NOT_RUN；不因缺xpfm放弃独立可做的本机测试。

当前没有冻结的part、platform/shell及XRT环境，**本轮不要求xo/xclbin或资源/时序报告**。后续HLS C仿真、综合、link和板上测试按实际先决条件及单核实现进度另行放行。仅Vivado已安装不能证明完整HLS/XRT路线可运行。

### 10.5 必须执行的P0验收矩阵

| 验收组 | 输入与独立依据 | 必須证明／失败行为 |
| --- | --- | --- |
| 全工程编译 | 所有15模块契约源及共享头；C++17，编译警告有处理记录 | 构建成功，无重复schema/源码；模块注册表完整，每个模块实现层级明确 |
| 请求原帧 | abi_replay/request_v1.bin，固定SHA-256 `2c5fb86724422dc82b47c0b3342d6d03bb308d28bfc81e4778dc9afd66e5e899` | 1856B头/目录/对齐精确；5输入对照实际manifest二进制；F32 mask仅恰0/1转U8；重编码byte-exact |
| 严格身份与坏帧 | 原帧及逐项修改副本（仅协议补充） | 零tag严格拒绝、tag不符、截短、offset溢出/重叠/错stride、未知枚举、非法token/mask/marker均返回规范错误；不得先越界读取 |
| 结果编解码 | 真实ir_1469及ir_1616，全16候选/2act F32原位 | 384B帧按14编码/解码保留位；错误清零logits/计数；B1未用行清零属格式测试，不声称新B1推理 |
| 位域/尾拍 | 真实F32输出／act_input1028、真实Q8 scratch组；辅助边界bit pattern | 358/350bit逐字段与独立位提取器一致，高padding为0；N2、N1、1028末4、WiPair 4对数量正确；非法count/last被拒绝 |
| 地址与shape | 规范独立算例＋真实B2/S128 markers | 135→b1/s7/row1031；真实147/163/174→s19/35/46；QKV最后合法offset12582908；hidden最后合法8388604；首个越界被拒绝 |
| Task与状态 | 每任务族合法实例/非法stage、family、K/N、ref、输出单位 | 所有typed任务契约可测试；单任务互斥、旧epoch、缺coverage、WI/DEC_FF别名、HEAD_WORK并存、in-place转换正确 |
| 搬移分段 | 实际embedding1088B、Q8权重跨度与跨4KiB区间 | 每段≤4096、不跨4KiB、长度守恒和边界无溢出；这里只验证分段描述，不声称AXI完成 |
| 真实数据完整性 | 两profile manifest与已有verification；默认读取选用文件并核hash | S94/S128不可混用；非连续ne/nb读取正确；act p使用preclamp_31，不能读取已覆盖末尾softmax冒充p |
| 未实现与工具缺项 | 计算模块状态及显式full-forward/HLS请求 | 未实现算术不得返回假OK；无part/platform时清晰失败；CTest中未执行项目不得记PASS |

真实Q8 scratch至少选Encoder0 QKV（`native_q8_activation_linear.bin`）、Encoder0 down（`native_q8_activation_linear_3.bin`）和act末层对应记录，按manifest读取实际consumer node/shape/hash；验证34B原生d+q到逻辑Q8Group的无损重排，不重新量化后与自身比较。可额外校验全部122份hash，但不必为本轮再次导出1.8GB图数据或重跑推理。

现有reference/runs为只读证据，本轮不要重跑会重写enriched manifest的make_fixture.py/capture.py来“准备测试”；新测试输出放results。协议修改／合成边界明确标supplemental，数值来源始终是真实Typed Q8；原生融合attention内部score/prob仍不可见，candidate算术未实现。

### 10.6 交付与审核边界

Sol提交实际变更文件、15模块映射、可重现命令、测试用例数与日志/退出码、工具环境、未实现模块清单，以及更新后的各模块design.md代码映射和results.md工程/软件合同状态。根代理做独立证据核验，Astra xhigh审核本合同、实际代码及原始结果后给ACCEPT/REWORK。

只有上述P0矩阵有实际证据，才可以报告“15模块工程框架和共享合同测试已建立”；不能写“15模块硬件完成”“全模型验证通过”或“已可上板”。下一阶段为真实LN→quant→Linear及QKV→attention／FFN链的候选算术、模块HLS C仿真与实现，不自动把当前P0通过扩展到它们。

### 10.7 P0基础范围的审核细化

2026-10-05根代理按用户“开始工程搭建”的本轮范围确认：P0验收限于本机C++基础工程、ABI/typed任务字段与来源目的约束、显式位域、地址/分段以及基础所有权状态模型。这里的coverage指调用者声明的覆盖范围；状态模型核对task互斥、epoch、region、content_kind、TYPE_ROWS逐type有效位及WI/DEC_FF别名，不据此宣称完整跨模块数据身份匹配或全层QKV屏障已验证。

以下完整缓存合同保留在15§11–§12，当前未实现/未验收，必须在后续计算链接入前补齐：A8的K/rows/batch/row0/row_space及源epoch绑定，W的WeightKey/K/N绑定，QKV的plane/head/B/S完整覆盖与请求/layer身份。P0中的独立参数检查和内容类型检查不能代替这些关联检查；全图调度、真实算术执行、在途AXI排空和硬件复位恢复同样不在本轮通过范围。该范围裁定只限定本轮交付，不删除后续设计约束。

本轮审核对既有任务绑定作三项明确化，已写回15§12：Decision与Encoder均允许ATT_OUT的K1024量化供Wo；LN按op限制HIDDEN/NORM/MARKER/HEAD_WORK来源目的并拒绝物理重叠；APPLY_CAND_MASK按BATCH、row0=0、rows=1处理本题16候选，输出16。数值运算、固定工作区和Host ABI保持既定定义。

### 10.8 P0正式审核结论（2026-10-05）

**ACCEPT，仅限§10.7界定的P0基础工程与已列合同检查。** 实现代理为GPT-6 Sol（`gpt-6-sol`，`max`），接口设计/审核为GPT-6 Astra（`gpt-6-astra`，`xhigh`）。15模块已建立唯一源码映射、可编译的主机端合同接口和模块TB；源码位于`hls/`但明确为host-only/`contract_only`，不是已完成的可综合HLS算子。根README、模块design/results及HLS入口均保留这一边界。

最终代码对应运行为[20261005T154135Z-3872886](../results/engineering_p0/20261005T154135Z-3872886/metadata.txt)，此前152752Z与153923Z运行仅保留历史，不作为当前代码验收依据。

| 已复核内容 | 最终证据与实际结果 |
| --- | --- |
| 全工程C++17 Release构建与正式回归 | [build.log](../results/engineering_p0/20261005T154135Z-3872886/build.log)、[ctest.log](../results/engineering_p0/20261005T154135Z-3872886/ctest.log)：configure/build/ctest退出码均0；20/20项通过，包含15模块TB及5项公共/ABI/fixture/HLS入口检查；无编译warning/error |
| ABI与真实数据格式回放 | 1856B S128请求byte-exact重编码、严格零tag拒绝与坏帧、384B结果格式；三份原生Q8 scratch、1028尾拍、非连续Q VIEW、S94/S128 manifest及preCLAMP来源检查通过；不重跑推理，不据此报告候选数值一致 |
| 类型、位域与基础状态 | typed stage/行空间/源目的/哨兵、计数及DotIssue边界；F32/WiPair/Q8独立字节oracle；WI/DEC_FF互斥与释放、HEAD_WORK并存、TYPE_ROWS逐type读锁、内容类型、覆盖/epoch/原地转换/复位检查通过 |
| 审核侧独立直接调用 | [core_probe.cpp](../results/engineering_p0/20261005T154135Z-3872886/review/core_probe.cpp)的26项及[reset_probe.cpp](../results/engineering_p0/20261005T154135Z-3872886/review/reset_probe.cpp)的12项均通过；真实编译/执行命令与退出码见[review.log](../results/engineering_p0/20261005T154135Z-3872886/review/review.log)，可用[run_review_probes.sh](../results/engineering_p0/20261005T154135Z-3872886/review/run_review_probes.sh)复现；[审核源码hash](../results/engineering_p0/20261005T154135Z-3872886/review/review_source_hashes.sha256)已记录 |
| 实际源码与数据身份 | 根代理独立复核[66项源码/构建输入hash](../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)及[21项fixture输入hash](../results/engineering_p0/20261005T154135Z-3872886/fixture_hashes.sha256)均匹配当前文件；7份原始reference身份保持不变；C++TB不依赖会被Release禁用的runtime assert |
| 未实现核的拒绝路径 | HLS入口准确列出15项未实现模块；显式完整forward/HLS请求非0退出，未产xo/xclbin；`--check`仅报告计划/缺项，不算HLS运行 |

审核发现的确定问题已在最终版本关闭：非法NONE/不匹配来源目的、Decision ATT_OUT量化遗漏、LN物理别名、candidate mask误计256输出、TYPE_ROWS通用访问与错误type解锁、缺少content_kind检查、编号/分段上限和DotIssue/独立位域测试，以及原地转换预留epoch在reset后复用。最终reset会消耗`max(epoch,next_epoch)`；独立12项检查证明旧epoch1和已预留epoch2在fresh epoch3发布后仍不可读，未以“立即reset后不可读”替代完整复活反例。

验收不包含A8/W完整缓存元数据关联、QKV plane/head/B/S及请求/layer完整覆盖、全层屏障、全图调度或任何算术执行。这些前置项已分别写入top、forward_controller、hbm_loader_and_cache、activation_quantizer、q8_linear_and_restore、rope_and_mask和attention_and_fp_engine的design§12及results审核边界。后续计算链接入必须补齐，不能沿用本轮PASS代替关联一致性验证。

实际硬件阶段状态：候选数值参考与HLS C仿真未执行；RTL/XSim或协同仿真未执行；HLS综合未执行；布局布线/时序未执行；U55C上板未执行；资源、Fmax、II、吞吐均未测。[环境记录](../results/engineering_p0/20261005T154135Z-3872886/preflight.log)证明Vivado/Vitis/v++/vitis-run 2025.2可查询版本，但part/platform未指定，XRT工具未发现，设备与许可未测试。当前可报告“15模块P0工程基础和合同测试已建立”，不得报告“15模块硬件完成”或“已可上板”。


## 11. 续任务：P1首批真实数值计算切片（2026-10-07）

用户再次询问能否开始各硬件模块搭建，本轮按行动请求实施 **LayerNorm → Group32量化 → Q8-F Linear**。合同由GPT-6 Astra（`gpt-6-astra`, `xhigh`）核定，代码／参考／TB／工具运行交GPT-6 Sol（`gpt-6-sol`, `max`），实现后由Astra审核。本文§10的P0历史与全forward门禁保留；本节是新增的可执行算术范围，不把20/20合同测试扩大为数值或硬件通过。

权威约束： [总体研究§5.1/§5.4/§12.1](../source/laya_baseline_design.md)、[07§2–4](../vivado/design_source/07_layernorm_engine.md)、[08§2–5](../vivado/design_source/08_activation_quantizer.md)、[09§2/§5](../vivado/design_source/09_q8_linear_and_restore.md)、[15§10–14](../vivado/design_source/15_integration_interfaces_and_pipeline.md)；2026-10-07实际读取并核查。本轮细化如下，取代“尚无候选算术”作为后续实施目标；未运行阶段仍不得改成PASS。

### 11.1 本轮边界与唯一源

- 实现固定容量、可用于HLS的阻塞数组计算：LN为D=1024、rows=1…16；Quant为K∈{256,1024,2624,4096}、rows=1…16；Linear为同一tile的完整K，输出窗口`n0…n0+cols-1`，cols=1…8，n0为8的倍数，`cols=min(8,N-n0)`，N由现有WeightKey确定。全矩阵N不能偷换成cols。BATCH行空间仍rows=1，不以act B2打包成一个两行task。
- 窗口是完整Linear的**内部算术子函数**，不是新op或缩小的LinearTask；只返回slice结果/状态，不能发送完整Linear TaskDone、发布整个QKV/WI/TMP、解除全层屏障。仅act N=2窗口恰含全部列，也不因本轮切片通过使全forward放行。
- 唯一维护源新增`hls/operators/layernorm_compute.cpp`、`activation_quantizer_compute.cpp`、`q8_linear_compute.cpp`；公共纯数值声明`include/laya_numeric.h`，固定元数据／切片声明`include/laya_numeric_tasks.h`，必要数值辅助放`hls/common/laya_numeric.cpp`。既有`*_engine.cpp`等P0合同源保留。相关头可直接复用现有POD Task/BufferRef/WeightKey/Status；不得另抄一套op/状态schema。
- 数值库单独源清单／编译目标，不链接host-only所有权容器进入综合；综合可达的数据结构只能是标量/POD/有编译上限的C数组，无vector/map/string、动态分配、文件IO、异常、虚调用、递归或数据相关无界循环。`std`容器仅可出现在主机参考/TB/P0，不得作为综合参数或可达存储。
- 本轮不实现完整forward、AXI/HBM加载器、QKV scatter及全层coverage、RoPE/attention/FFN/尾层全图、XRT，也不改TM16×TN8生产设计的吞吐声明。当前串行切片验证运算与存储边界；后续并行化保持同一数值合同。R1、融合、预取、双任务重叠均不启用。

### 11.2 函数、数组与切片身份合同

函数命名可作等价调整，实际映射须写回模块design.md。`layernorm_compute`接受LayerNormTask、请求/源/可选gamma元数据、`x[16][1024]`和`gamma[1024]`，输出`y[16][1024]`及每行mean/variance/inverse；`activation_quantizer_compute`接受QuantTask、请求/源元数据及`x[16][4096]`（物理行stride4096，有效列K），输出`q[16][128][32]`与`scale_bits[16][128]`及A8元数据；`q8_linear_compute`接受完整LinearTask、请求、预期量化来源、A8/W元数据和n0/cols，读取上述A8数组及`wq[8][128][32]`/`ws[8][128]`、`bias[8]`，输出`y[16][8]`及slice状态。无bias时不得额外执行加+0；真实act有且只加一次绑定bias。诊断trace可用独立测试辅助入口或编译期配置，不能把文件写入综合路径；至少能观察指定(row,col,group)的dot/term/partial。

共享请求身份为`request_id:u64,generation:u64,B/S:u16, model/numeric/layout/build_tag:各16个u8`，运行前锁存。本轮离线numeric/build身份由合同/参考/源版本生成并标为实验身份，不能伪称生产已认证；native请求帧的零tag只用于读取来源，不用作数值切片绕过检查。合法请求task_id严格递增由本轮测试调度器承担，运算调用期间无新任务/别名写入。

本批缓存绑定必须在任何数值读取前完成，不得只检查Content：

| 对象 | 发布时保存并在消费时逐项核验 | 覆盖与失效 |
| --- | --- | --- |
| F32源tile | 请求四tag/request/generation/B/S，BufferRef和region，row_space/batch/row0/rows，K，READY/content=F32 | 源身份来自生产者已发布记录；接受时验证完整rows×K覆盖、合法ref/shape；LN src/dst不重叠 |
| gamma | model_tag、gamma_kind=1/2、LN_GAMMA相应bank及epoch、D1024、READY | LN_EMB只能emb；LN_FINAL只能final；gamma0不读取gamma；不得凭指针接受任意affine |
| A8 | 请求全身份、a_dst ref、生产Quant task_id和stage/layer、K/rows/batch/row0/row_space、**src BufferRef/region/source epoch**及完整源身份 | 仅所有rows×K/32组成功写完发布READY；Linear匹配自己的a及ctx/K，并与独立传入的预期源身份比较，不能把A8自身字段拷回当expected |
| W窗口 | model/numeric/layout/build及request/generation，WEIGHT ref、WeightKey family/layer、完整K/N、n0/cols、bias_kind与绑定权重/偏置身份 | READY表示本窗口cols×K/32完整，绝不表示整张W已加载；窗口切换先失效/增epoch；父整矩阵缓存的复用策略保持15，不因测试窗口改变 |
| 输出/PS窗口 | request/task_id/dst ref/region、row身份、N/n0/cols、成功状态及精确输出数rows×cols | 所有group累加及bias完成后才置有效；调用返回前读写全部结束，output_beats=0；不是完整Linear TaskDone |

新计算边界须复用或等价落实P0的ctx/op/WeightKey/来源目的规则，但不能仅主机wrapper校验、综合入口裸读。元数据不符返回E_BUFFER或E_SHAPE，模型tag不符E_MODEL；非有限／溢出等返回E_NUMERICAL。每次调用先将目的valid清零，失败不发布，内部或输出数组可有部分暂存但消费者禁止读；成功时数量精确。reset/generation切换使所有slice valid失效，旧a/w/源epoch不许复活；epoch不回绕。拒绝busy/READ/FILL等非READY输入、不全coverage及读者持锁时覆写。阻塞调用与明确READY/FILL/INVALID状态足以表达本轮F0串行所有权，尚不证明AXI排空或物理复位。

#### 11.2.1 目的owner与失败不发布的精确解释（首轮审核澄清）

本段明确上述“拒绝读者持锁覆写／新epoch／失败不发布”，不改变算术范围。每个目的`(buffer_id,bank,region)`保留持久owner；LN/A8可复用返回元数据作为该owner，Linear窗口返回记录另含state并同时保留PS与dst引用。owner不得在每次调用前无条件重建为空记录，也不允许把另一bank/region的owner冒用为本目的。

- 领取前：先做参数、输入绑定和目的owner检查，只有FREE/INVALID可领取；READY必须经无reader的合法release，READ/FILL/EXCLUSIVE_RW/DRAIN或busy均拒绝。领取前拒绝必须保留旧owner的valid、ref、epoch及旧数组，不能因本次失败把旧消费者的有效数据清掉；返回Check表示本次未执行，不是发布一个新结果。
- epoch：初次未绑定owner领取epoch=1；此后目的ref必须同一bank/region且epoch=保留旧epoch+1，PS与dst分别检查；kMaxEpoch不能回绕。已有合法新epoch即使算术失败也已消耗，不得重试复用该epoch。
- 领取后：写入本次ref、请求身份及已领取epoch，状态FILL、valid=false；数值计算才能写数组。成功后READY/valid=true；数值失败INVALID/valid=false，保留已消耗的ref/epoch。此时部分数组可以作为无效暂存，不供消费者读取。
- release/reset：合法release只在无reader的READY执行，变FREE并清valid，但保留ref/epoch；READ持锁时不得release。reset/generation切换清valid和覆盖状态，保留最大已领取epoch（包括失败或FILL预留值），再按下一epoch发任务；输入侧仍匹配新generation，旧记录不能复活。初次使用另一目的需要它自己的owner记录。

直接TB须分别证明“READ目的拒写且旧valid/数组保留”、“release后旧epoch拒绝”、“新epoch成功”、“领取后数值错误保留消耗epoch”和“reset后旧epoch不能复活”。这只证明本轮阻塞切片owner，不代替物理复位/AXI排空。

### 11.3 数值版本：P1 Q8-F R0

所有基本运算是IEEE binary32 RNE（ties-to-even），保留次正规和signed zero；每个式子标出的FP32操作必须分别舍入。主机编译至少`-fno-fast-math -ffp-contract=off`，检查默认RNE及非FTZ/DAZ环境；不使用FMA或重结合。CPU `sqrtf` / 单精度除法实现与版本、编译器选项进入numeric记录；本批先使用IEEE sqrt/div，不批准近似rsqrt替代。HLS数学适配若改变数值，必须保留首次差异并交Astra裁定，不能放宽后伪报逐位通过。

- LN：相邻二叉树精确定义为1024输入，第一层`v[j]=FP32(x[2j]+x[2j+1])`，逐层至一值（512/256/…/1）；mean=FP32(sum/1024)。delta=FP32(x-mean)，square=FP32(delta*delta)，同树求sum，var=FP32(sum/1024)，t=FP32(var+bits(0x3727c5ac))，root=FP32(sqrt(t))，inv=FP32(1/root)，norm=FP32(delta*inv)，有gamma时y=FP32(norm*gamma)。不加beta，不能换成RMS/E[x²]-mean²。每一输入和中间结果有限、var非负；异常显式失败。
- Quant：对每32个有限值求abs最大；amax零为+0。d_full=FP32(amax/127)，inverse=(d_full!=0)?FP32(1/d_full):+0；q=roundf(FP32(x*inverse))，恰半整数远离0；d_saved=IEEE FP16 RNE(d_full)。q用d_full的inverse，不能用d_saved。d_full下溢到0时q和scale为+0；允许FP16次正规/舍入为零，禁止默认FTZ；inverse非有限、FP16 Inf/NaN、q超[-127,127]均失败。不得默默clamp。
- Linear：每32个S8乘积精确求和到I32（本模型q在[-127,127]，一般有符号8bit的保守界524288亦在I32内），scale由FP16位模式无损扩展F32，term=FP32(FP32(sa*sw)*FP32(dot))，acc从+0沿group0…K/32-1逐次`FP32(acc+term)`；最后只按绑定关系加一次FP32 Linear bias。权重scale须有限非负，负零按非负零处理并保留其位模式；native固定模型实际无负/零scale。禁止跨组整数累加后一次恢复。N2无效6列不访存不输出。
- 相同输入下CPU DUT对独立oracle：quant q/FP16、I32 dot、FP16转换、R0 term及group partial逐位；LN mean/var/inv/y也逐位。硬件CSim沿用相同测试。未来RTL若工具sqrt实现出现差异，本轮尚不批准换数值版本；现有总体中间误差线`1e-4+1e-4*abs(ref)`只作定位辅助，不覆盖本轮CPU精确合同。
- native LN/Q8 GEMM作为模型对照，记录bit差数、max_abs、max_rel（分母下限明确）、RMSE和首差索引，不要求与其逐位相等，不为native差异偷换候选规则。此项报告无本批新设质量PASS阈值；400例/全forward质量仍未执行。

### 11.4 静态存储、端口与调度

本轮一个请求、一个任务/子调用在途，无stream，无跨任务FIFO。所有接口数组在调用期间独占读/写，阵列数据先全部准备好才调用下级；函数返回后才发布。LN逐行处理，可用x行缓存＋tree工作区各1024×4B；相邻树原地压缩必须先读两个子结点再写父结点，不覆盖未读结点。Quant按row/group顺序用局部32F32组buffer，两遍组内计算；全局输入数组保留，但不强制额外复制256KiB输入缓存。Linear逐row/col/group/k安全串行，32次整数贡献后恢复并更新一个acc；acc退休后进入下一group，不通过错误依赖pragma强取II=1。

固定接口最大逻辑容量（不含测试trace/外部原始fixture）：Quant输入262144B；A8 q+scale=69632B；8列W窗口=34816B；LN输入/输出各65536B（接口）；Linear输出512B；LN两块工作区合计8192B，gamma4096B，Quant组工作区128B。接口数组不自动全变成片上缓存，不能把外部接口和本地缓存重复相加成BRAM结果。第一版只需每存储一到两次顺序访问；不要求16×8广播bank、全部展开或TM16吞吐。若用RAM绑定/PIPELINE pragma，记录实际端口与冲突，不能改变归约树。

候选HLS scalar clock可请求150MHz（周期约6.667ns）以沿用研究起点，不是已达频率。只对isolated top使用本机catalogue已有`xcu55c-fsvh2892-2L-e`作为**实验器件**；不声称冻结U55C实际shell/板part。平台reset/CDC、AXI时序、全层coverage和生产缓存容量不在本轮验证结论中。

### 11.5 已核对的真实数据与可复现切片

只读[abi_replay manifest](../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)，本轮实际重算SHA-256为`8588b69436e50c7500c22c677e174e77001e1e92e656bee2f46e1a88f4abb29a`；[GGUF inventory](../reference/runs/typed_q8_ref_20261005/gguf_inventory.json)为`40983ab871903db1281eb82901521fae5f5e1b862d8c2d4f22deba7cbe44c5c6`；455179648B模型完整重算为`6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。下面文件的完整hash已与manifest逐一核对；测试仍须每次读取并核hash，不仅信任本表。路径/sha字段从原manifest引用到新run manifest，禁止改写reference/runs或重跑capture/make_fixture覆盖数据。

| 算术场景 | 真实输入／参考与布局 | 权重／窗口 |
| --- | --- | --- |
| 主链LN→quant→Wi | `ir_267` residual→候选LN；native LN参考`ir_268`；ne=[1024,128,2,1]，nb=[4,4096,524288,1048576]。候选LN产生量化输入，再用Wi；native Wi `ir_269` ne=[5248,128,2,1]、nb=[4,20992,2686976,5373952] | `mlp_wi.0.weight` Q8_0 ne=[1024,5248,1,1]，absolute offset181644640；n0=0,2616,2624,5240，各8列，覆盖U尾/G首 |
| 带gamma LN及QKV | `ir_216` embedding_raw→候选LN/gamma；与`ir_217` embedding_norm比较；另单独以native `ir_217`量化，以隔离上游误差；QKV参考`ir_237` ne=[3072,128,2,1]、nb=[4,12288,1572864,3145728] | `emb_norm_w` F32[1024] offset2055520；`qkv.0.weight` Q8_0 [1024,3072] offset56864096；n0=0,1024,2048,3064 |
| K2624量化→down | `ir_273` gate ne=[2624,128,2,1]、nb=[4,10496,1343488,2686976]；输出native `ir_274` ne=[1024,128,2,1]、nb同1024行 | `mlp_wo.0.weight` Q8_0 [2624,1024] offset341519712；n0=0,1016 |
| K256/N2量化→act | `ir_1615` ne=[256,2,1,1]、nb=[4,1024,2048,2048]；pre-bias原生`node_1808`与含bias `ir_1616`均ne=[2,2,1,1]、nb=[4,8,16,16] | `act_fc2.weight` Q8_0[256,2] offset449922624；F32 bias[2] offset449923168；n0=0/cols2，两题分别rows1 |

前三个TOKEN场景至少处理b0,row0=0,rows16和b1,row0=112,rows16，覆盖首/末tile及PAD。另由真实输入切出rows1与rows15检查尾部。LN_FINAL gamma模式可用相同已核模型final_norm_w参数做单元校验，未覆盖真实final全链需如实记录。K4096在本轮用明确标supplemental的固定seed输入覆盖最大存储边界；不把该项写成真实Decision全链。

native scratch对应`linear`(QKV)、`linear_2`(Wi)、`linear_3`(down)、`node_1808`(act)。前两项shape1024×128×2、278528B，down2624×128×2、713728B，act256×2、544B；块序是row优先、每组34B=`FP16 little-endian +32 S8`。本轮已核各sha，act scratch为`3abe87cf12fdeda361e44f49f4566c1d9b167079e20ba9161ea5d8bfe3657e52`。量化比较必须给DUT和oracle同一F32输入；另将候选LN输出作为下一步输入独立oracle，不能悄悄替回native norm。native scratch只用于差异报告，不能当DUT输出或代替候选quant。

GGUF Q8每行G=K/32组；选取block offset=`tensor.absolute_file_offset+(global_n*G+g)*34`，无损解包q/scale，逆拼原34B逐字节检查，记录选中张量及窗口hash。gamma/bias从inventory明确dtype/shape/offset读取。测试读取`ne/nb`必须通用按stride寻址，nb是字节单位；act的batch在ne[1]，不能误按TOKEN的ne[2]。窗口n0不得加到K维。真实输出native仅作对照，不进入独立期望值生成。

### 11.6 独立验证、构建与证据

独立参考放`tests/numeric_reference.py`或等价唯一入口，允许NumPy FP32和Python整数/struct；不得调用/导入DUT helper生成期望、不得用被测结果倒推expected。固定相邻树、group升序、每步F32舍入由独立向量/整数路径表达；FP16 RNE oracle可用Python IEEE half打包，需独立边界常量验证。真实fixture驱动放`vivado/module_design/top/tb/numeric_fixture_test.py`；三个模块`tb/numeric_tb.cpp`直接编译/执行DUT，接口/元数据反例也必须直接到数值入口。

必须覆盖：真实链逐值对账；LN常数、大偏置近常数、抵消、gamma；Quant全零、±0、半整数远离0、FP16 RNE ties/次正规/零/溢出、d_full下溢和reciprocal溢出、K最后一组；dot极值/正负抵消、零scale负dot的signed-zero term、组升序导致的舍入反例、act bias及N2尾部；NaN/Inf出现在首/末有效输入、无效row/col不访问（guard/sentinel）；各缓存元数据单字段变异、错WeightKey/K/N/n0/cols、来源epoch、同shape跨request/generation、缺coverage/非READY、错误后不发布及重新运行恢复。trace至少在所有真实选定窗口逐group核dot/term/partial，或由专门trace入口完整回放这些同一输入。

P1使用独立CMake入口或默认OFF的显式选项，不能改变既有P0脚本20/20统计与HLS全15模块门禁测试含义。新增`scripts/run_numeric_tests.sh`、isolated HLS配置与`scripts/run_numeric_hls.sh`，构建/日志输出`build/numeric-*`、`results/engineering_p1/<run_id>/`，不得覆盖P0证据。保存命令、编译器/数学库/Python/NumPy版本、源码和所有实际fixture/hash、候选numeric合同身份、逐项数量、完整日志/退出码、native差异报告。P0 20项回归仍应通过；P1 PASS命名明确为`NUMERIC_SLICE_PASS`，不输出全网/上板通过。

2025.2工具可执行且本机器件查询证据在[query_parts.log](../results/p1_environment_20261007/query_parts.log)。本轮授权并要求尝试isolated HLS CSim；依本机vitis-run接口提供显式实验part和真实DUT/TB，不连接host-only P0库。条件允许时综合最小切片（先LN或Group32量化/R0窗口），保存report并核查实际源/端口/FP算子/存储/II；不能仅dry-run或g++通过就写HLS通过。若工具/许可/FP支持阻塞，保留失败退出码与日志，继续完成CPU数值验证。完整forward HLS入口继续非0拒绝，不能因三个切片实现而把15模块改成complete。

### 11.7 交付判据与后续边界

交付需实际算术源、独立oracle、真实数据/反例测试、可重现运行脚本、各模块design映射/results实测分阶段记录，并由Astra审核源码与原始日志。可以报告“首批三个模块的数值切片及已执行验证”；只有真正执行且通过才分别报告HLS CSim/isolated综合。器件实验综合不是实际platform链接，未执行的RTL cosim、布局布线/时序、xo/xclbin及U55C实测明确保留未执行。完整A8/W绑定仅限本节切片边界；生产全矩阵W常驻、完整Linear输出发布及QKV plane/head/B/S覆盖仍是后续集成前置项。最终路线保持单forward→Vitis→XRT。

### 11.8 P1正式审核结论（2026-10-07）

**ACCEPT，仅限§11.1–§11.7界定的LayerNorm、Group32量化及完整K/最多8列Q8-F Linear内部数值切片，以及下列实际执行的验证阶段。** 设计、合同澄清和最终审核由GPT-6 Astra（`gpt-6-astra`，`xhigh`）完成；算术、独立参考、测试台、工程入口及运行由GPT-6 Sol（`gpt-6-sol`，`max`）实现。三模块当前代码映射分别见[LayerNorm design§13](../vivado/module_design/layernorm_engine/source/design.md)、[Quant design§14](../vivado/module_design/activation_quantizer/source/design.md)和[Linear design§14](../vivado/module_design/q8_linear_and_restore/source/design.md)；这些固定数组入口不等于生产并行阵列或完整网络。

最终代码对应CPU运行`20261007T021236Z-1800667`、HLS运行`20261007T021255Z-1801905`及P0回归`20261007T021407Z-1804638`。较早运行仅保留历史，不替代以下最终证据。

| 已执行阶段 | 最终证据与实际结果 |
| --- | --- |
| CPU Release直接数值TB | [CTest日志](../results/engineering_p1/20261007T021236Z-1800667/ctest.log)：LN 29例、Quant 30例、Linear 57例，共116例通过；configure/build/CTest退出码均0 |
| 真实模型离线数值与独立oracle | [fixture报告](../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)、[运行摘要](../results/engineering_p1/20261007T021236Z-1800667/summary.json)：31场景＝30真实切片＋1个固定seed K4096量化补充场景；LN输出及mean/variance/inverse、量化q/FP16 scale、Linear窗口结果与独立oracle逐位一致；30真实场景的全部row/col/group共132128组dot/term/partial逐位一致 |
| 三模块isolated HLS CSim | Vitis HLS 2025.2的[LayerNorm日志](../results/engineering_p1/20261007T021255Z-1801905/csim_layernorm.log)、[Quant日志](../results/engineering_p1/20261007T021255Z-1801905/csim_quant.log)、[Linear日志](../results/engineering_p1/20261007T021255Z-1801905/csim_linear.log)：分别29、30、57例通过，退出码均0。CSim运行的是这116例直接TB，未运行上述31场景的Python真实fixture驱动 |
| 仅Quant isolated HLS综合 | [csynth日志](../results/engineering_p1/20261007T021255Z-1801905/synth_quant.log)、[顶层报告](../results/engineering_p1/20261007T021255Z-1801905/activation_quantizer_compute_csynth.rpt)、[组函数报告](../results/engineering_p1/20261007T021255Z-1801905/activation_quantizer_group_csynth.rpt)：`activation_quantizer_compute`的Tcl csynth退出0并生成RTL；实验catalogue part为`xcu55c-fsvh2892-2L-e`，请求150MHz/6.667ns。LN和Linear综合未执行 |
| P0及完整forward门禁回归 | [P0日志](../results/engineering_p0/20261007T021407Z-1804638/ctest.log)：20/20通过。默认OFF的独立数值构建保持P0合同入口含义；[完整forward注册表](../hls/laya_forward.cpp)15项仍为`contract_only`，完整forward HLS请求继续非0拒绝 |
| 当前源码及输出身份 | 审核重算[CPU 52项源码hash](../results/engineering_p1/20261007T021236Z-1800667/source_hashes.sha256)、[HLS 16项源码hash](../results/engineering_p1/20261007T021255Z-1801905/source_hashes.sha256)和[P0 84项源码hash](../results/engineering_p0/20261007T021407Z-1804638/source_hashes.sha256)均匹配；131个候选输出文件的大小/hash与15个原reference文件的大小/hash均匹配，计数及结果保存于[审核完整性记录](../results/engineering_p1/20261007T021236Z-1800667/review/integrity_check.json) |

审核读取了实际算术、公共身份/owner校验、三个直接TB、[独立参考](../tests/numeric_reference.py)及[真实fixture驱动](../vivado/module_design/top/tb/numeric_fixture_test.py)。oracle不调用或导入DUT helper；相邻FP32树、整数dot、逐步FP32恢复/累加和Python IEEE half转换独立表达。审核另按原文件偏移重构全部30个真实输入切片及30个GGUF权重窗口，核对`ne/nb`、act的batch轴、Q8原34B组逆拼和候选LN进入下一阶段的真实来源；没有用native中间值替换候选链。大偏置近常数与最小FP32次正规LN的固定期望位模式也经独立复算。

本轮发现的明确实现问题已关闭并进入最终直接TB：领取前参数/来源错误保持旧READY/READ owner和数组；领取后失败消耗epoch，release/reset保留最大已领取版本且拒绝回绕；Linear的PS/dst双引用须同时通过检查；错误detail保留实际op；LN实际发布元数据进入Quant，A8仍与独立预期来源比较；W核验完整K/N及WeightKey、完整权重/偏置字节跨度和offset溢出，无bias元数据严格为空。数值边界另覆盖±127 dot极值/抵消、零scale乘负dot的signed zero、2²⁴/1/−2²⁴组序反例及K4096第128组末项。trace与实际`compute_one`共享运算路径，未用单独正确实现遮蔽DUT。

Quant综合资源为HLS估算DSP 3、FF 30642、LUT 75650、BRAM18K 0、URAM 0；估算时钟4.767ns、Fmax约209.78MHz，均不是布线后或板上结果。组循环目标II 1而实际II 244，顶层未流水，日志明确“All loop constraints were NOT satisfied”。x/q/scale使用`ap_memory`外部端口，其外部数组存储不计入片上BRAM；报告最大127428158 cycles和XML平均68.759ms来自rows 0–255、groups 0–2047等类型范围推断，不能作为合法任务实测延迟或吞吐。首次裸`--mode hls`的[失败日志](../results/engineering_p1/20261007T020512Z-1792411/synth_quant.log)及退出码2保留，之后改用Tcl完成综合，没有将首次失败改写为成功。

native差异仅作报告：20个LN比较的最大max_abs为`4.76837158203125e-7`，30个Linear比较为`0.00048828125`；本轮未新增质量PASS阈值，未验证400例或整网质量。LN_FINAL真实全链、其他S/B配置、生产全矩阵缓存及输出发布、QKV plane/head/B/S完整覆盖、AXI/HBM、其余图算术和调度均未完成；RTL cosim/XSim、布局布线/时序、xo/xclbin、实际platform/shell/XRT部署及U55C上板均未执行。本次不得报告15模块硬件完成、完整forward完成或生产性能达标，后续路线仍为单forward→Vitis→XRT。

合同身份留证：原运行器将当时task.md从`"## 11. "`之后至EOF的全部文本加固定前缀后哈希；追加本审核节会改变当前全文。审核在追加前补存了与原报告完全匹配的[精确UTF-8前像](../results/engineering_p1/20261007T021236Z-1800667/review/numeric_contract_preimage.txt)，19294B，SHA-256为`41da96018781616d7f5fdf250ab814a6f262dbd7cc8a80e60738c78cb1aa93fb`。[来源与复算说明](../results/engineering_p1/20261007T021236Z-1800667/review/contract_provenance.md)明确其审核补存时间与定义。本节不改变数值合同，原报告/输出/源码不回写；复算本次历史身份须使用该前像，未来运行按当时文本产生独立实验身份。

## 12. 续任务：全部模块与完整F0前向工程（2026-10-07）

用户明确要求继续完成其余所有模块搭建。本轮范围覆盖全部15模块的实际算术、数据搬运、完整调度与单forward顶层，包括28层Encoder、2层Decision、scorer和act，不以contract-only骨架、固定返回值、原生runtime代算或任意缩小K/N/层数代替。GPT-6 Astra（`gpt-6-astra`，`xhigh`）负责本节及模块设计/最终审核；GPT-6 Sol（`gpt-6-sol`，`max`）分别负责唯一DUT/工程实现与独立参考/测试。§10、§11已验历史保留，P1算术规则复用。

### 12.1 实施范围、来源与分批发布

权威来源为[总体研究§2–5/§7/§12](../source/laya_baseline_design.md)、[04固定布局§7](../vivado/design_source/04_model_package_and_memory_map.md)、[06 Embedding](../vivado/design_source/06_embedding_engine.md)、[10 RoPE](../vivado/design_source/10_rope_and_mask.md)、[11 Attention/FP](../vivado/design_source/11_attention_and_fp_engine.md)、[12 Vector](../vivado/design_source/12_vector_and_ffn.md)、[13 Decision/head](../vivado/design_source/13_decision_scorer_act.md)、[15任务/生命周期§10–15](../vivado/design_source/15_integration_interfaces_and_pipeline.md)，2026-10-07实际读取。另直接解析固定GGUF的`ggmlc.graph_spec`：1364节点、153参数、5输入、2输出；该JSON原字符串UTF-8 SHA-256为`f33f7848434b73048f957dcd232e1bd4ff99e95b8cf41c98191b69fddad815f9`。模型及[abi_replay manifest](../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)身份沿§11.5，所有原始reference只读。

分批发布只控制实施依赖，不缩小最终交付：A为算术叶函数；B为模型包、完整矩阵/任务、数据与owner；C为控制器/单forward/Host及完整图验证。A/B/C全部完成后才允许本轮整体验收。板无关工程、CPU/CSim、实验part综合及可执行RTL联测继续；缺少本机XRT/platform/板卡只阻止依赖这些条件的编译/链接/上板阶段，不能把该缺口当作剩余模块无需实现的理由。首版F0单任务阻塞、固定数组，性能优化另列，不启用F1重叠。

### 12.2 P2 F0算术合同

版本名为`P2 F0 FP32 Q8-F R0`。所有显式基本运算单独IEEE binary32 RNE，禁止FMA、重结合、FTZ/DAZ；保持P1 LN、quant、Q8 R0及half转换不变。每个活跃输入、权重和中间算术结果均须有限，否则`E_NUMERICAL`；允许exp下溢为+0、合法次正规及signed zero。非法shape/mask/index在数组读写前拒绝。下列叶函数不发布共享存储有效位；领取前/后错误的owner语义由完整任务包装落实§11.2.1和15§11，不能把纯函数返回当作完整TaskDone。

| 算术 | 本轮冻结的顺序与边界 |
| --- | --- |
| Embedding | 真实token/type表每行1024维、32个原34B Q8_0组；逐组FP16 scale精确转F32，每项`FP32(float(S8 q)*scale)`。scale须有限非负，q限[-127,127]；词表50368/type3；PAD正常查表。表ID和完整字节范围由任务层在任何HBM读前检查 |
| RoPE | 完整64维head先捕获再改写；对i=0…31，`a=FP32(x[i]*cos[i])`、`b=FP32(x[i+32]*sin[i])`、`y[i]=FP32(a-b)`；`c=FP32(x[i+32]*cos[i+32])`、`d=FP32(x[i]*sin[i+32])`、`y[i+32]=FP32(c+d)`。使用真实cos/sin F32位模式，不重算三角函数；Encoder layer%3==0用full，其余slide，位置为题内s；Decision旁路，V不变 |
| QK与mask | 64项分别FP32乘法，按相邻二叉树64→32→…→1求和；`scaled=FP32(dot*0.125)`。mask U8仅0/1，`pad=FP32(FP32(float(mask[k])-1)*10000)`；full的bias=pad，slide的local为abs(q-k)<=64时+0否则-10000，`bias=FP32(local+pad)`；最后`score=FP32(scaled+bias)`。所有S个key均计算，padding query不清零，不以-inf或跳key替换finite mask |
| softmax | length仅16或合法S桶64/128/256/512/1024，均为2的幂。max从x[0]开始按位置升序、仅`>`更新；每项`z=FP32(x-max)`、`e=expf(z)`；对完整length个e用相邻二叉树求和；sum须有限且>0；`p=FP32(e/sum)`。不先求sum倒数后乘，不在线分块，不删finite masked项；尾部不读写 |
| AV | 每个64维输出acc从+0开始，key k=0…S-1：`product=FP32(p[k]*V[k,d])`，`acc=FP32(acc+product)`；不改变key归约顺序。S个概率和V都须有效，输出恰64维 |
| 浮点尾层 | scorer FC2 F32 K1024/N1；act FC1 F16 K1028/N256，权重先精确扩F32；每输出acc=+0，k升序乘法后单独加法。scorer FC2最后加一次其原bias；act FC1此阶段不加bias，由后续BIAS_GELU_ACT单独加。1028全部参与，不padding到1056量化 |
| GELU | 常数c=`FP32(0.7978845608028654)`、a=`FP32(0.044715)`。按`u=FP32(a*x)`、`v=FP32(u*x)`、`w=FP32(1+v)`、`t=FP32(c*x)`、`z=FP32(t*w)`、`h=tanhf(z)`、`r=FP32(1+h)`、`s=FP32(0.5*x)`、`y=FP32(s*r)`执行。采用GGML tanh形式，不替换erf；每一步有限检查，负大值中间溢出也报错，不擅自饱和 |
| GEGLU/向量 | Wi前2624为U、后2624为G；先上述GELU(U)，再`FP32(gelu*G)`。ReLU为`x>0 ? x : +0`，NaN先拒绝。residual/type add逐项单独F32加，type只加本题且在final LN之后。scorer先由Q8 FC1加baked bias，再单独FP32加原scorer_fc1.bias并GELU；act FC1同样先输出dot再加act_fc1.bias/GELU，禁止提前合并bias |
| 候选mask | 全16列：`m=FP32(1-float(marker_mask[i]))`、`b=FP32(m*(-10000))`、`masked=FP32(raw[i]+b)`；无效列仍gather本题CLS并做完整scorer，不覆盖成常数、不跳列 |
| 候选统计 | 概率p输入16个有限[0,1]值；valid_options由实际marker mask计数绑定，k=max(valid_options,2)。`t[i]=FP32(p[i]*logf(max(p[i],FP32(1e-9))))`，相邻16项树求sum，`entropy=FP32((-sum)/logf(float(k)))`。top1从p[0]开始，i=1…15依次`m=FP32(ReLU(FP32(m-p[i]))+p[i])`；每项delta=`FP32(top1-p[i])`、denom=`FP32(delta+FP32(1e-6))`、ratio=`FP32(delta/denom)`、r=`FP32(p[i]*ratio)`，denom为0或中间非有限报错；top2对r执行同样链。输出顺序[top1,FP32(top1-top2),entropy,FP32(float(k)/255)]；无温度/排序/硬top-k |
| concat/gather | gather按ABI marker扁平索引检查同batch后读完整1024；固定16列含无效CLS填充。concat复制最终Decision本题s0的1024个CLS值，再复制4stats，恰1028个元素 |

CPU/CSim的expf/tanhf/logf固定为当前系统单精度libm函数，运行记录glibc/编译器/链接版本及FP环境；独立Python参考可直接通过libm标准ABI调用这些基础函数，不能调用DUT或其自定义helper，表达式/归约/布局仍独立实现，并以高精度值审计函数误差和输入范围。CPU/CSim同输入按该明确参考逐位比较。综合后HLS数学实现须单独记录；P1基本运算/量化/dot的精确判据不放宽。新增exp/tanh/log近似在RTL同算子输入下采用源研究§12.1的预设工程线`abs_err<=1e-4+1e-4*abs(ref)`，全图raw logits采用`1e-3+1e-3*abs(ref)`、最终概率abs<=1e-3，同时保存首差和后续quant变化。这是本轮冻结的实现检查线，不等于native逐位或400例质量通过；不得以该线掩盖运算顺序/地址/所有权错误。

### 12.3 A批接口、文件责任与验证——RELEASE_TO_IMPLEMENTATION

新增唯一共享头`include/laya_full_numeric.h`，命名空间`laya::full`。原P1声明/实现保留，A批可复用其half和位模式辅助，不依赖P0动态容器。下列均返回`Check`；数组维度为固定最大容量，实际有效数量由规定shape决定。结果数组允许在领取后数值失败时部分写入但无共享发布；输入shape/mask错误不得开始运算。`rope_head`、`softmax_row`、`relu_row`和`add_row`允许明确原地调用，先保留必要输入；其他部分重叠不允许，任务层负责拒绝。

```cpp
Check embedding_row(const uint8_t raw[1088], float y[1024]);
Check rope_head(const float x[64], const float cosine[64],
                const float sine[64], float y[64]);
Check qk_row(const float q[64], const float k[1024][64],
             const uint8_t mask[1024], uint16_t S, uint16_t query,
             bool sliding, float score[1024]);
Check softmax_row(const float x[1024], uint16_t length, float p[1024]);
Check av_row(const float p[1024], const float v[1024][64],
             uint16_t S, float y[64]);
Check fp_scorer_row(const float x[1024], const float w[1024],
                    float bias, float& y);
Check fp_act_row(const float x[1028], const uint16_t w[256][1028],
                 float y[256]);
Check gelu_scalar(float x, float& y);
Check geglu_row(const float wi[5248], float y[2624]);
Check relu_row(const float x[4096], float y[4096]);
Check add_row(const float a[1024], const float b[1024], float y[1024]);
Check bias_gelu_row(const float x[1024], const float bias[1024],
                    uint16_t length, float y[1024]); // length 256 or 1024
Check candidate_mask(const float logits[16], const uint8_t mask[16],
                      float y[16]);
Check candidate_stats(const float p[16], uint8_t valid_options,
                       float stats[4]);
Check concat_act_row(const float cls[1024], const float stats[4],
                      float y[1028]);
```

DUT负责人维护`hls/operators/embedding_full_compute.cpp`、`rope_full_compute.cpp`、`attention_full_compute.cpp`、`vector_full_compute.cpp`、`decision_full_compute.cpp`及上述共享头、独立构建源清单/runner；需要共享数学辅助时唯一维护于`hls/common/laya_full_math.cpp`。独立测试负责人仅新增`tests/full_reference.py`、`tests/full_*`及各模块`tb/full_*`，不能改DUT/include/config/CMake/主runner或P1 oracle。DUT负责人接入测试与运行；新架构、接口或数值变化先交Astra，不能由测试反向定义合同。

A批必须完成真实输入和边界：token首尾/CLS/PAD/重复/type3行及原34B精确反量化；真实ir_238/239经ne/nb取完整head与四张GGUF RoPE表；full/slide、q-k=±64/±65、S64/128/1024与无窗口内真实key的有限mask；完整QK→softmax→AV（native融合内部无score/prob，用候选oracle生成）；真实ir_269两半、ir_272/273作为native诊断，GEGLU尾2623；Decision ReLU4096；scorer两个bias分步、act F16 K1028最后4项/输出255、N1尾；16候选1/2/3/16有效、ties/近ties、均匀分布、熵log下限、top2先除后乘；NaN/Inf和有界shape错误/尾部sentinel。真实候选链使用同一候选上游值对DUT/oracle，不拿native替代；标准库与高精度误差审计独立列出。每个叶函数至少CPU与isolated CSim，适合的小入口尝试综合和RTL cosim；阶段未执行如实记录，A批通过不解锁完整forward。

### 12.4 B批：真实模型包、完整任务与存储——RELEASE_TO_IMPLEMENTATION

本批实际读取并采用[01§6请求](../vivado/design_source/01_host_runtime_and_abi.md)、[02§2–4端口](../vivado/design_source/02_kernel_wrapper_and_platform.md)、[03§2–4屏障](../vivado/design_source/03_forward_controller.md)、[04§7地址](../vivado/design_source/04_model_package_and_memory_map.md)、[05§2–5缓存](../vivado/design_source/05_hbm_loader_and_cache.md)、[14§9结果](../vivado/design_source/14_result_status_and_verification.md)及15§10–15，不另创Host指令或任意张量view。唯一DUT负责人新增`include/laya_full_runtime.h`、`hls/common/laya_full_io.cpp`、`hls/common/laya_full_memory.cpp`、`hls/memory/full_loader.cpp`、`hls/operators/full_tasks.cpp`及`tools/export_gguf.py`；可按模块拆分full_tasks的实现，但一项职责只有一个维护源。共享头采用固定POD，公开命名/字段映射写回各模块design后交测试负责人，不把动态容器或测试hook变成硬件参数。

#### 12.4.1 模型包与身份

导出器从唯一固定455179648B GGUF重新验完整SHA、153张量inventory和graph_spec，实际读取全部payload；124个Q8_0含122 Linear与2 Embedding，另28 F32、1 F16。原payload合计453123852B；允许仅移除4202500B的`slide_bias`，但须穷举证实所有1025²元素恰为规定0/-10000，保留源hash及移除原因；其余448921352B逻辑payload完整保留。导出目录为新的`build/model-p2/`或明确独立输出目录，不覆盖原GGUF/reference。

生成`embedding.bin,w_q0.bin,w_q1.bin,w_scale.bin,aux.bin,manifest.json,laya_model_layout_generated.h`。Embedding保持原34B组、token/type表各按64B对齐。122矩阵严格按04§7.1：t=n//8、shard=t%2、local_t=t//2；q地址`q_base[shard]+(((local_t*G+g)*8+lane)*32+j)`，scale地址`scale_base+((t*G+g)*8+lane)*2`，不能按列奇偶分片。N2物理补到8，仅padding q/scale为0，原有效列不重新量化。每张矩阵base独立64B对齐；F16/F32/bias/RoPE原位写入aux，逐张tensor保存源offset/type/shape/full SHA和目标base/span及逆还原结果。所有有效Q8原34B组逆重排必须逐字节等于GGUF；其余payload逐字节一致，alignment/padding全0。

编译时表按既有WeightKey绑定完整K/N、dtype、三个base/span、源payload hash及bias，不从请求接收动态descriptor。真实graph_spec核定绑定：Encoder四类各28层均无Linear bias；Decision四类各2层分别有`head_qkv/wo/fc1/fc2.<layer>.bias`；scorer Q8 FC1只加`linear_120_baked_bias`，另加`scorer_fc1.bias`属于后续GELU任务；scorer F32 FC2加`scorer_fc2.bias`；act F16 FC1此层无bias，后续加`act_fc1.bias`/GELU；act Q8 FC2加`act_fc2.bias`。缺失、shape/type错误、额外未知Linear绑定、源图/模型hash不符均构建失败，不用零权重/bias补位。

aux前128B为模型包头：0…3 ASCII `LYMP`，4/6为u16 major1/minor0，8为u32 header128，12为u32 BO数13，16为u32 descriptor_version1，20…31全0，32/48/64/80依次model/numeric/layout/build各16原始摘要字节，96…127为完整GGUF SHA-256。其余aux数据从128起64B对齐。顶层在首次权重访问前比较该头与编译常量和请求身份；Host加载时验证全部BO文件hash。运行期不宣称硬件重新SHA扫描整个模型。

numeric tag对§12.2从标题起至§12.3标题前的精确UTF-8文本哈希并每次保存前像，不把后续审核/结果文本纳入。layout tag对规范化的版本、BO尺寸和全部descriptor/base/span/source payload hash计算，排除tag自身及含tag的模型头。build tag对源/配置hash、model/numeric/layout和实际工具/数学库配置的规范化清单计算，排除生成tag头自身；最终BO文件hash另外登记，不参与循环定义。生成头与Host、kernel、manifest必须来自同次导出/构建，tag非零；原reference请求中的零tag仅允许离线转换生成新候选请求，硬件不得接受零tag。

#### 12.4.2 13端口、地址与真实搬运

单forward保持02规定的13参数次序和BO职责：embedding、io、w_q0、w_q1、w_scale、aux、state0、state1、qkv0、qkv1、ff0、ff1、att_out。首版用可移植具名byte指针及每个独立m_axi bundle，读模型端为const；HLS最大widen请求512bit、读写outstanding先取1，实际位宽/burst以报告核查。允许首版生成较窄端口，必须如实计带宽，不能把512请求当作已实现。Host/CPU/CSim使用同一13端口次序，不额外传入任意权重offset或改变固定workspace布局。

`FullMemory`（等价命名可）只保存13个具名指针和对应容量；真实kernel容量为编译表常量，CPU测试可提供较小实际容量用于拒绝反例。所有地址在u64检查base+relative+size、对齐、所属BO及合法B/S/row/head/col后才访问。已有04固定workspace base、1024物理stride、QKV双shard与HEAD_WORK八region保持不变；S…1023物理padding不读写，s<S的PAD照算。普通tile读写由类型任务生成，不能以任意Host地址作为命令。

实际byte/f32 load/store和copy必须搬运真实数据；逻辑MemTransfer按≤4096B且不跨4KiB分段，offset/segment/末段连续且数量精确；Q8 34B跨64B拍/4KiB正确重组，尾部仅写合法bytes且不破坏邻tensor。HLS生成适配器负责AR/AW/R/W/B握手；阻塞C完成只证明访问顺序，真实返回/写响应退休须生成RTL/cosim确认。无法完成的总线事务不伪造drained，留给Host timeout/恢复；没有异步读写信用或预取隐藏在F0函数后。

输入使用新增固定POD上下文：完整NumericIdentity、I32 token[2][1024]/marker[2][16]、U8 attention_mask[2][1024]/marker_mask[2][16]/qtype[2]及有效B/S；不能将P0的vector Request链接进综合。解析先读并校验固定头/身份/shape，再校验五个目录和全部界限，再读payload；顺序、padding/reserved、所有ID/mask/marker/qtype规则与01§6一致。最后一个非法ID或marker也必须在任何Embedding/模型读取前拒绝。I32负值不得经无符号截断变合法；B2 invalid marker只能本题CLS。

#### 12.4.3 完整缓存、owner与覆盖

F0只需单bank当前W、A8、PS、KV和score；不因保留逻辑bank编号就分配无用双缓存。当前Q8 W完整装入一次，在该矩阵所有B/S tile完成前保持READ/READY；下一矩阵才能release/claim。最大合法W扁平q容量5373952B、scale 167936×2=335872B，总5709824B；禁止把Nmax5248与Kmax4096做笛卡尔数组。采用静态数组并尝试明确URAM/RAM绑定，禁止大栈对象；实际物理bank/碎片/资源由综合记录，未经审核不得退化成每tile重读HBM。

其他单bank最大逻辑容量：A8 69632B；量化F32输入262144B；完整tile PS 16×5248×4=335872B；当前head K/V含B2为1048576B；SCORE_PROB为2×16×1024×4=131072B；Q/AV tile各8192B；LN原局部8192B；RoPE两mode原cos/sin全表共1049600B（可按需要只缓存当前mode524800B）；LN两gamma8192B；F16 act权重526336B。外部workspace仍留HBM，不把整个hidden/WI/QKV变成片上静态数组。资源合计按真实同时存活/共享关系计算，不重复计接口数组。

P2拥有独立的固定大小owner表，键是buffer/bank/HEAD_WORK region；WI/DEC_FF共用物理锁。每记录至少含完整请求身份、stage/layer、ref/region、shape/row_space、content、state/readers、最大已领取epoch、覆盖和有效位。参数/全部输入绑定/目的可领取性先验证，失败保留旧有效对象；领取后FILL，失败INVALID且消耗epoch；release只对无reader READY，清valid保留epoch。软reset或generation切换清valid/coverage/reader并保留最大已领取epoch，不能重建为epoch0规避；达到kMaxEpoch拒绝、不回绕。物理平台复位后状态是否保留另记录，Host必须换generation并确认旧AXI已终止。

**完整对象与内部窗口分层**：controller对一个完整矩阵目的只claim一次，保持FILL贯穿所有B/S tile；每个typed LinearTask处理同题rows≤16、完整K和完整N，只claim其PS tile一次。内部n0=0,8,…,N-1窗口既不claim共享dst的新epoch，也不发布整matrix READY/TaskDone；全部窗口输出数量准确并退休后，LinearTask才能返回rows×N，随后登记本tile的行覆盖。完整矩阵所有B/S行覆盖后才READY。W epoch每次实际换矩阵一次，A8/PS epoch每完整row tile一次；不得用P1微窗口owner重复发布全tensor。

普通完整矩阵可按[batch,row]位图登记，每tile完整N由内部窗口位图/计数证明；拒绝重复tile、遗漏、越界及不同request/layer的拼接。QKV额外逐plane/head/batch/token登记，两个shard共同达到全部3×16×B×S范围后RAW_READY。RoPE先原子领取两个shard的EXCLUSIVE_RW新epoch，允许只该转换读取旧RAW；逐Q/K head/row全64写回，V沿同一完整旧对象携带；两plane覆盖完整及全部写退休后两个shard一起FINAL_READY，任何失败使旧/新整体无效。Decision无RoPE，但QKV最终发布仍须完整三plane覆盖。AV向ATT_OUT按head/row完整64登记，16head全部齐才整矩阵READY。HEAD_WORK各region独立所有权，candidate在act期间保持可读；TYPE_ROWS按type_id独立有效位，同请求补行不能错误发布未加载type。

P1不能直接用每窗口claim接口当完整任务。允许把其私有LN行、quant组及Q8完整K单输出算术提取为**同一维护文件内的公共纯数值辅助**，P1接口与P2完整任务共同调用；保持每次FP32运算/错误语义，禁止维护第二份漂移算术。该机械重构须重跑P1全部直接TB与真实fixture、对应CSim，旧证据保留为历史。P2输入tile的绑定来自真实已发布完整owner及经过检查的物理读取，不能仅自行填一份READY字段绕过矩阵覆盖。

需要原地转换的对象显式使用controller持有的旧/新epoch lease：SCORE→PROB、DEC_FF ReLU、SCORER_ACT中的量化→scorer FC1回写及post bias/GELU。特别是B2的SCORER_ACT，不能在b0量化后release整对象而让b1继续读被作废的旧owner；整个B×16范围进入EXCLUSIVE_RW，每tile先读取/量化完整旧行，才允许覆盖该行，分别登记旧行已消费和新行已写。仅该lease下的指定任务可读未覆盖旧行；已消费旧行不得再次作为旧输入，外部reader均拒绝。所有batch新行齐全才READY，任何失败使旧/新都INVALID并消耗新epoch。A8保留来自该合法旧行读取的生产者快照及来源epoch，Linear的独立expected来自lease/生产者账本，不能取A8自身字段冒充。无原地定义的任务仍禁止重叠，LN始终不能原地；不同HEAD_WORK region不视作同对象原地。

完整B2/S1024的Q8 row-tile数量上界为120个主干矩阵×128＋2个scorer tile＋2个act tile＝15364；这是A8/PS每请求epoch增长的设计上界，不是实测任务数或1000请求稳定性证据。记录实际task/claim计数，软reset和连续B2→B1请求检查旧epoch不复活；task_id仅每个完整typed任务递增，内部窗口不占完整任务ID。

#### 12.4.4 完整任务与B批验收

实际任务接口复用15§12的EmbeddingTask、LayerNormTask、QuantTask、LinearTask、RopeTask、QKTask、SoftmaxTask、AVTask、FPLinearTask、VectorTask、GatherTask、StatsTask、ConcatActTask和LoadTask；新增运行上下文提供FullMemory、固定owner/cache及只读模型表。入口检查完整task/context/合法op、stage/layer、row_space、ref/region、source/content/coverage/epoch及所需模型descriptor，再调用唯一算术叶函数。每次成功TaskDone使用规定单位/精确数量、output_beats=0、drained=true；叶函数错误归属实际task，锁存首因而不发布部分共享输出。

Linear对完整K/N执行所有n0窗口，含完整Wi 5248、Decision FC1 4096、全部QKV 3072及N2尾；QKV按plane=n/1024、head=(n%1024)/64、d=n%64和既定head奇偶shard散写。矩阵W在所有tile间复用；A8只量化一次供该tile全部N。LN处理每tile全部1024、gamma严格stage绑定；Quant完整K；gather全16列；vector任务逐实际rows和完整length；QK/softmax/AV完整S和64feature，score原地转换期间独占；F32/F16尾层实际从aux载入并逐K计算，不能用native输出替代。

B批测试必须包含153 tensor导出/逆还原（含唯一允许移除项）、原bias两次顺序、真实全部12 WeightKey family及每个合法layer的descriptor，完整维度矩阵输出（至少各不同K/N一次真实全N）、全部QKV plane/head/B/S覆盖、完整raw→final→KV→attention链、Wi/gate/down/residual和scorer/act链。地址/owner补充覆盖最后byte/4KiB/BO界限、WI/DEC_FF别名、HEAD_WORK并存、READ拒写、失败后epoch、单双shard未完成、同shape错request/layer、B2接B1及软reset。CPU必须在真实数组上观察正确读写；HLS CSim必须使用实际loader/任务，不以只返回计划的P0模型代替。独立测试代理实现oracle/fixture/反例，DUT代理负责构建运行和报告；B批通过仍须C批完成整图。
