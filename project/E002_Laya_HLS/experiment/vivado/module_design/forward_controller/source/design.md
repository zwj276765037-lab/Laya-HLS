# 前向调度与所有权：详细设计

## 2026-10-08续诊断：metadata presence表示修复

已从既有IR确认：QKV linear的非空pair在reflow/LTO后丢失存在性，load成功后固定E_INTERNAL；binary vector的src1也变NONE并丢失第二绑定。QK/AV固定错误不是孤立算术leaf问题。根因边界、精确等价修复和分层验收见[新修复合同§6](../../../../results/attention_rtl_repair_20261008/repair_contract.md)。[D1独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_d1_review.json)已确认原版生成RTL的6/15事务失配，并确认修正版120项断言/15条事务通过；生产P1/P2/P3已获独立代码审核并同步正式源码，正在分层回归。补丁采用明确bool+reference/descriptor值选择，保留原检查、错误时点、owner与算术；D1含公开stub，不代表真实数值/owner链通过，全网重综合仍须后续技术放行。

正式controller当前SHA256为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，见[正式同步审核](../../../../results/attention_rtl_repair_20261008/reviewer_official_sync_review.json)。正式新包为[build/model-attention-rtl-repair-20261008](../../../../build/model-attention-rtl-repair-20261008/manifest.json)，tag `fe067c8aa0627ad770096f9721394645`；[本次CPU门禁](../../../../results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)已通过141检查点及故障恢复。该身份的真实13口B2/S128标准libm CSim现已另run执行通过（47检查点、9047192 F32、37158任务），见[日志](../../../../results/attention_rtl_repair_20261008/d2_full_top_csim_official_v1/csim.log)，独立运行审核另列；生成数值/owner链与完整RTL尚未验收。隔离副本tag `18366c267ae0a7ca0c3afb8c2174b890`不替代正式身份；旧04934包和硬件制品保留，不与新源码混配。

本节是新任务进展，以下performance_review及旧CPU/CSim/OOC记录只对应其原始源/制品；不改写旧证据，不将新补丁预记为已验收。

本页下方历史硬件制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

接收请求和owner状态，输出typed task并检查done；issue/full_run_task同步返回后才发下一任务。

B1/S128退休18,895任务，B2/S128为37,158；没有跨任务并行重叠证据。任务次数是CPU observed计数，不是RTL时钟数。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-forward_controller)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/forward_controller`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：完整F0调度、owner屏障与持久故障恢复通过当前CPU整图及真实top CSim验证。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

由FPGA控制全部层和共享算子执行。首版用HLS循环/函数生成控制，不引入CMD256；状态名称表示设计阶段，不是已编码FSM信号。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 图顺序 | embedding→28 Encoder→final LN/type→2 Decision→scorer/act→结果 | 工程事实 | 03§1/模型图记录 |
| 首版调度 | F0阶段串行，矩阵权重跨token tile复用 | 推断 | 03§4 |
| 共享引擎 | Q8独占；QK/AV/浮点尾层共用FP；向量分时 | 推断 | 03§3 |
| 完成定义 | 结果可读、在途运算/写入排空后释放 | 推断 | 03§2、15§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [03_forward_controller.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:32)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:48)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:59)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:69) | 层内依赖、共享资源互斥、F0/F1调度与联合流水 |
| [14_result_status_and_verification.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:29)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:120) | 结果退休、关联链路及异常终止 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| VALIDATE/EMBED | 合法请求与模型上下文 | 初始hidden和LN准备 | 进入层0 |
| ENCODER_LOOP | 层类型与矩阵offset | full层为每三层第一层，其余sliding；执行attention/FFN | 残差提交后更新hidden角色 |
| DECISION/HEADS | final LN/type完成 | 两层full且无RoPE，16列scorer和act | CLS/marker生命周期满足 |
| WRITE/RETIRE | 全部输出或可报告错误 | 通知result_status，等待可见性/排空 | 释放请求上下文；设备故障交runtime |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| 任务上下文 | top→controller→算子 | layer/op/b/tile/矩阵与有效范围 | 分类型任务参数，位宽见15§10–§14 | 发射前检查依赖及资源拥有者 |
| 就绪/退休 | 算子/加载器→controller | buffer ready、完成、错误 | 就绪不等于仅最后乘法发射 | 最后读取/写响应/排出分别跟踪 |
| 结果完成 | controller↔result_status | 当前请求身份及status | 全网成功与局部错误区分 | timeout由Host确认停止，不能擅自空闲 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 调度交错可以隐藏不同输出的延迟，不能改变同一输出的group/key累加顺序。
- 每个阶段携带同一模型/数值/布局标识；发生错误时本次logits无效。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| W0/W1 | 加载器填充、Q8读取 | 全矩阵所有token tile读完才释放 | Wi/down共驻时没有第三bank免费预取 |
| PS/A8/旧hidden | 算子与控制器联合管理 | 完整就绪→使用→排空→空闲 | F1消费流须同时运行，不能等生产者塞满后才启动 |
| KV/score | attention占用 | 所有query或AV读完后释放 | 共享FP尾层只在attention结束后复用缓存 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- F0 LN完成后才做量化；F1a可把LN输出接量化第一遍，但Linear仍等完整A8 tile。
- F1b按tile交替Wi/down仍是同一Q8引擎串行，不可画成并算。
- 首次填充、末次排空、切换和访存冲突都参与整体时间轴。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [forward_controller.h](../../../../hls/control/forward_controller.h)、[forward_controller.cpp](../../../../hls/control/forward_controller.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_forward_controller`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 资源冲突 | 随机延迟算子或HBM返回 | 同一引擎/写bank从未出现双拥有者 |
| 屏障 | 故意延迟最后QKV写、PS最后group和residual读 | 消费者不早读，旧hidden不早覆盖 |
| 恢复 | 错误输入、数值异常、复位后的新generation | 旧任务在途结果不能污染新请求 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/forward_controller/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G2控制字段/错误码已定义，待生成实现与联调；G4函数实际实例数、延迟和调度trace；G5恢复与排空行为。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

控制器拥有RequestContext、task_id分配、buffer状态/epoch/coverage表以及共享引擎互斥。F0一个算子任务在途；任务有效而未ready时全参数保持；收到drained=1的TaskDone后才允许下一个。类型/枚举完全采用15§10–§14，不再标为逻辑名字待定。

| 调度对象 | 参数绑定 | 屏障与释放 |
| --- | --- | --- |
| Encoder循环 | stage2、layer0…27；full当layer%3=0，否则slide | 层0不发LN_ATTN；每层QKV_RAW→RoPE→FINAL→attention |
| Decision循环 | stage4、layer0…1，full | 全S运行，不发RoPE；FF宽4096 |
| tile循环 | b外层，row0=0,16,…；rows=min(16,limit-row0) | 一个task不跨题；token limit=S，marker limit16 |
| head循环 | head0…15，QK→softmax→AV逐query tile | KV跨全部query，整head完才释放；ATT_OUT整层齐后Wo |
| 权重矩阵 | WeightKey family/layer绑定当前图 | LOAD_W一次后供全部token tile；W读者最后退休才释放 |
| HIDDEN交换 | bank0/1，NORM/TMP固定 | residual全部B/S完成且响应排空才交换；旧H保留到最后读取 |

对同一矩阵分多tile写入，epoch在整个FILL期间固定，记录覆盖而不因每个task done发布整矩阵READY。RoPE原地转换以old/new两epoch独占整个矩阵阶段，done只退休当前tile，最终屏障才发布新epoch。任何错误冻结首因、停止新任务、排空已接受事务后作废相关目的buffer；不可恢复挂起交Host超时恢复。

真实capture的层输出是数值检查点；TB另记录每个task的id/op/b/layer/row0/rows、输入引用、接受/首输出/末输出/done时刻。断言op共享引擎不重叠、stage依赖无缺口、task_id连续、旧epoch不可读。运行期间复位后的首请求必须重新从IO_VALIDATE和embedding开始。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_layer_out` | `ir_275 / add_5` | `native/forward_0/ir_275.bin` |
| `enc27_layer_out` | `ir_1409 / add_113` | `native/forward_0/ir_1409.bin` |
| `type_add` | `ir_1413 / add_114` | `native/forward_0/ir_1413.bin` |
| `decision0_layer_out` | `ir_1434 / add_116` | `native/forward_0/ir_1434.bin` |
| `decision1_layer_out` | `ir_1455 / add_118` | `native/forward_0/ir_1455.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前状态模型核对单任务互斥、epoch/region、调用者声明的覆盖范围、content_kind、TYPE_ROWS逐type有效位/读锁及WI/DEC_FF别名；reset消耗已预留的下一epoch，拒绝旧引用复活。尚未保存或核验A8的K/rows/batch/row0/row_space与源epoch、W的WeightKey/K/N、QKV的plane/head/B/S及请求/layer身份；上述元数据关联、全层QKV屏障和全图调度必须在计算链接入前补齐。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。


## P2 C批：全图F0屏障与持久会话（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/03_forward_controller.md)及[task.md §12.4–12.5](../../../../hardware_agent/task.md)，由Astra xhigh核定。

新增hls/control/full_forward_controller.cpp按task§12.5.1表执行；Encoder0跳LN_ATTN，其他Encoder与两层Decision遵守各自LN/bias/RoPE规则。每矩阵当前W完整驻留，逐tile完整K/N后登记全对象覆盖；raw→final→attention、残差hidden交换和Wi/DEC_FF别名严格屏障。SCORER_ACT跨B的原地量化/FC1及GELU使用旧/新epoch lease，不释放未消费旧行。持久runtime拒绝同generation旧request及较旧generation，软reset保留已领取epoch。

记录每完整typed任务及每W/A8/PS claim、层/shape/加载/发布计数；内部窗口不占TaskDone或epoch。B2/S1024 Q8 tile15364为设计上界，不是循环周期或稳定性实测。错误首因锁存、停止新任务、排空/作废再结果提交。


## P2实际实现映射（2026-10-07）

- [full_forward_controller.cpp](../../../../hls/control/full_forward_controller.cpp)：本模块当前P2实现责任源。
- [laya_full_owner.cpp](../../../../hls/common/laya_full_owner.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

控制器和全部任务退休/依赖顺序保持，full_tasks.cpp只把13数值数组的访问点改成固定数组访问器，activation_meta/source_ledger保持原访问与所有权检查。不得改算术leaf、task参数、循环归约/发射顺序、错误首因、last_accepted_request_id或持久恢复。owner索引实现由hbm_loader_and_cache负责并遵守同一合同。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。`Controller::fresh`与`invalidate_incomplete`分别以0…31整数索引遍历owner记录，仍保留首匹配、最大epoch、READ/readers提前拒绝与原失效顺序。scorer/act两个必填bias调用使用引用索引查找，不改变返回状态和发布顺序。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
## 2026-10-12 production HLS 分区合同

现行 production 生成采用 [D-M003-PRODUCTION-HLS-PARTITION-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/production_hls_partition_contract_20261012.md)：Controller caller 保留完整模型任务图、身份/预约/高水位、BEGIN/END、owner 事件与唯一 typed 退休；非门户算术和 BO 读写由按家族复用的独立 producer engine 承担。最终只有一个 RTL shell 对外暴露原 13BO/control ABI，并连接原四条 512-bit/depth2 compute/provenance FIFO。

caller 与 engine 之间仅允许层级内部的固定宽度 request/completion 握手，最多一个活动非门户任务、一个请求槽和一个完成槽。请求必须无损携带完整 NumericIdentity、Context、Refs/region/epoch、任务参数、物理 role/offset/geometry 与已核模型绑定；BEGIN 成功应答后才可启动 engine。completion 回传原任务绑定、逻辑 Check/TaskDone 及由真实 store helper 累计的 `issued_store_bytes`，不能由 caller 按 shape 预填。caller 只有在 END 返回完整绑定且 `DRAINED=1/SCOPE_ACTIVE=0` 后才清 tracker 并退休一次。

production caller 的 HLS 编译闭包必须切断 `full_run_task` 的算术实现；CPU/reference 路径继续保留原直接调用。未实现的 engine family 必须明确拒绝或保持未接，不得用空函数、常量 ACK 或 Host fallback 伪装完成。

## M007 E016 SINGLE-PARENT-11 current bounded implementation (2026-10-22)

M007/SM012，D-M007-SM012-SINGLE-PARENT-11；工程负责人 A010。真实实现位于 forward_controller/rtl/laya_m007_single_parent_v1.sv 与 laya_m007_context_quant_adapter_v1.sv。父包含一份纯 layer、matrix facade、quant/A front、context adapter、原系数 cache 和 attention_resources；FP/PS/storage 与 DIV 分束路由。QKV 始终通过 layer 公开窄写口，context adapter 仅用实际公共响应保持，不复制整张 context。Profile=0。

完整128bit原始 source tags：model6eb6ef58bc4f99bd9db40381604108af、numeric aeb13e7937d29fe6a2c68c407249f294、table b1fdc9ca482c0210982c7245cc50c965、graph f33f7848434b73048f957dcd232e1bd4、layout2d848b5fb78236c795cb1d442f088393、build7209eb09c3f265363cfb274f7790a733。这些是原部署来源身份，当前布局 M007-W576-v1 与每次实际编译 manifest 分开；不是当前 bitstream 身份。tensor_catalog.json 从原 manifest ordinal+1 导出60项，按 kind/layer 选择 QKV/WO key；shape不能替代 tensor 身份。Bias配置检查完整 model/numeric 及 request/gen/epoch/tensor。

共享源只读：FP f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0；DIV8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79；纯 layer c3e80307f5a941c1d599eb579d8bc787021d428ea42453b81d7b80e037c7a9db；resource shell484f94579c1abe80b21e8080f32e52aefb30133b12502d42408556721c4c3a09（仅9个真实DIV输出引出）。完整依赖逐次冻结并由AT024核对。

当前 parent SHA `e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8`；AT013/15–17 parent SHA `c29e9376dcaa29c45738c4576886376686b6a0fda5259af4fe1171e2d5632a22`。唯一改变是 producer_close_success 仅在 CRUN 采用 c_fault，避免上一次 context fault 的空闲粘滞位污染新请求初始 QKV close；producer_failed仍全局有效，无新增寄存器。首head证据不改标当前版本；AT022/23仅补当前版编译及复位/QKV3。实际 context-fault→新generation父链仍未执行。

新增 parent+adapter控制1561bit、按模块取整196B；原保守3550B合计3746B，余350B。452个实际输入源=444显式赋值+8个cache直接驱动。固定算术metadata/共享队列在原物理账保留；这是声明/连接/展开证据，无物理fit结论。地址base/span由可信fixture/未来Host注册提供；RTL检查对齐、span与溢出，不能从任意合法BO地址推断tensor SHA。每次实际原W/输入及公共QKV数据独立逐位比对，但通用Host注册服务尚未实现。

方法与命令、资源限制、参考源见 [protocol.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/protocol.md)。实验原始证据在R001/attempts，最终版本边界见 [current_version_evidence.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/current_version_evidence.json)。

## M007 E016 R002 simulator-cost comparison (2026-10-22)

SM012 D-M007-SM012-SIM-COST-13；A010。R001原首head/故障/消费者/共同reset证据与成本出口冻结，见[原有界交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)。本段无生产RTL变更，parent SHA e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8，Profile0，原sharedFP/DIV/layer/resource依赖与原模型fixture保持。

两组逐文件冻结源码完全相同，xelab命令均为work.m007_single_parent_tb --relax -debug VALUE -mt4 --O3 -s m007_parent_sim；唯一选项差VALUE=typical/off。off直接复制typical冻结closure。两个snapshot保留实际生产模块、原独立数值gold、内部协议/排债/身份/连续issue/PS反馈断言及原checker频度。相同R002 TB统一仅增加一个被动quant-return计数、4096终点断言和既有input/quant/A/W/QKV握手打印；AT005去掉这些插入后逐字节恢复原TB SHA，确认未删改任何原checker/驱动。

原fixture复用R001 AT012记录的28个文件，全部逐SHA核对。每组相同原Encoder0 QKV3，不跳实际parent相位，不发布父成功，不跑16head/WO。全部实际tool子进程串行持m007_heavy.lock，CPU0–3/nice19/idle，MemAvailable>192GiB，static24GiB/RTL8GiB、120s单次帽、strict numerical progress120s与40Mcycle不变。新独立reference0/static300/RTL300/OOC0s，无R001余额转移。

协议：[r002_sim_cost_protocol.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/r002_sim_cost_protocol.md)。实际源码/命令/产品/fixture/日志/guard与receipt分别在R002/attempts。debug off的Tcl结果只用自己的query，不继承typical层次；观察到的scope可见性不作为物理实例/资源比较。

## M007 E016 完整父链后继准备（2026-10-22，只读规划）

本节是主控要求的有界准备，不是完整验证合同或运行放行。生产RTL/TB/runner未改，EDA未运行；R001/R002原attempt、最终交付和封账预算不变。当前parent SHA `e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8`。证据与单独只读账：[planning](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/planning/full_parent_successor_20261022/planning_ledger.json)、[冻结gold布局核对](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/planning/full_parent_successor_20261022/frozen_gold_layout_consistency.json)。

### 当前实际入口与不能直接运行完整链的原因

生产parent在[控制段](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/rtl/laya_m007_single_parent_v1.sv:1142)已写出 `LRUN→CSUB→CRUN→CDRAIN→WMSUB→WMRUN→FINISH`：真实layer成功DONE后启动同一quant/A和context adapter，等待c_complete/c_idle及layer_idle，再发K1024/N1024的WO命令；WO真实matrix DONE被消费后才进入父FINISH。这是源码行为，未被当前完整链动态签署，未发现仅据源码即可认定必须先修改RTL的缺陷。

现[m007_single_parent_tb.sv](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_single_parent_tb.sv:211)没有full模式。PREFIX>0只结束QKV前缀；PREFIX=0在首个实际h_done握手就打印FIRST_HEAD并$finish。head计数是首head总数，max_checked只置一次，未按16head退休重置；仅去掉$finish会在head1统计断言失效。虽然score/prob/context/max数组已加载全16head参考，当前终点仍只核head0，且未要求max_checked成为终点条件。

当前W peer只装QKV p0..p3，AR地址仅允许cmd_base[0]/cmd_span[0]，Rdata也固定按QKV基址读。当前A/write和W/prebias/core trace checker同样固定QKV数据与48块计数；后续context A和WO从s0重起会误用旧gold/旧计数。out_ready恒1，尚无父WO数据/正常成功DONE检查。

现[runner](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_parent_run.py:34)也无full模式：prefix0要求QKV3 pilot，成本门只投影完整QKV+首head71168周期，成功marker固定FIRST_HEAD；没有完整父成功marker、全链fixture身份、完整阶段wall事件或独立后继账。因此不能直接调用旧runner加timeout获得完整链。R002 runner同样固定PREFIX=3，仅供已关闭的debug选项对照；普通runner保留O3/debug typical，不继续扫旗标。

### 新TB应新增的检查与合法驱动

| 边界 | 应新增或按相位扩展的实际检查 | 驱动限制 |
| --- | --- | --- |
| 一次父命令/QKV | 原8身份拒绝与所有原QKV检查保留；正常命令只接受一次；4096原输入→4096quant/Awrite/Aack，48块、12288QKV32/393216值；matrix QKV命令与layer.start各恰一次 | 通过原cmd/F32/coeff口，正常链不reset、不逐块发命令 |
| 16head | 每个head独立score16384/prob16384/context8192/prob ack2048、maximum128比较且终点必须已核maximum；每head真实h_done/status/identity/head index、唯一start/retire及周期帽；总head16、score/prob各262144、context131072、prob ack32768、maximum2048、RoPE2048commit；layer head_completed/context_valid在交接前应FFFF | 只被动观察实际内部握手；全局strict checked counter单调不重置，局部per-head计数可分组；保持全部原checker频度 |
| layer成功回执 | 核实际l_done_valid&&l_done_ready，status0、request/gen与原命令完全一致，16head已完成；按冻结layer Check合同核completed/unreachable/dominated/coverage/error，不用“全置1”替代合同 | 不TB伪造layer DONE/context_valid；layer成功DONE不代表context已释放 |
| 公共context4096组 | 对每个真实rd/rsp握手记录一笔实际credit，tag/代际/顺序及32F32逐位比较；读序i=32*query+2*head+half，参考lane=context[(head*128+query)*64+32*half+c]；4096实际响应→4096quant/Awrite/Aack、一次A发布，compare两套QKV/context A gold分相位 | 必须消费实际layer输出；原context文件仅作期望。公共响应保持依实际信用；禁止强制c_*或layer状态 |
| context所有权退休 | 核layer公开消费覆盖4096、public_read_owned=0、无未退storage响应、c_idle/c_complete/c_consumed=4096、quant/DIV/A debt已清并实际发布，最后才接受WO matrix命令 | layer[退休逻辑](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv:1169)在响应真正握手时记覆盖，L_RELEASE等全部覆盖与real_idle才回IDLE；应观察实际条件，不能用TB换相位 |
| W重绑定/复用唯一cache | 用实际AR地址在已登记的QKV/WO基址范围选择原packed数据；每个已接受ID保存其所属源，R响应按接受时源返回；核QKV旧W/A/FP/PS lease和peer AR/R debt全退，WO实际K1024/N1024、tensor32、base[1]/span[1]、同request/gen/epoch，16块冷W装载及原W/prebias/A映射 | peer扩展为两套只读fixture，不复制生产W服务。不能用全局phase给旧在途ID改数据，不能预填W完成或force cache |
| WO131072原值 | 按actual out_valid&&out_ready计4096个32F32响应；输出s=i/256、row=(i%256)/2、col=64*s+32*(i%2)，每lane对原WO[row*1024+col+c]；16块每块1024连续issue/commit，记录反馈、W/A协议和最后输出/资源释放 | 原out_ready口有限反压可合法保持中间/末WO响应；held时valid/data/row/col稳定，不提前接受WO DONE/父成功 |
| 首次父成功/held DONE | 正常例逐拍禁止在“16head、4096实际context、A发布、4096WO响应及真实WO matrix DONE/债释放”前出现任何父DONE；首次成功须status/source_status/error_domain/error_tuple全0，done_request/gen/epoch精确等于接受命令；并核来源m_done身份。done_ready=0保持至少5拍，完整243bit字段既等于独立期望又稳定、cmd_ready=0、无新工作；真正ready后只退休一次，回IDLE可合法接下一命令 | 仅驱动原done_ready/out_ready；稳定性与期望值分别断言，不能只拍下DUT值再自比 |
| 事件与成本 | 在实际command、QKV accept/end、layer start、每head begin/end、layer done、context首/末响应/发布/释放、WO accept/首末输出/matrix done、父done/retire记cycle与主机monotonic wall；generic日志不续strict numerical progress | 原40Mcycle、资源策略、单独账不改；新full终标只有所有检查完成且实际父成功退休才发 |

上述断言属于TB/runner扩展，不应先改生产接口。完整同构建TB可设置observer-only的STOP_AFTER_HEAD=1：在真实head0完成后结束pilot；full设置0继续观察至父DONE。两者不改变DUT命令、参考、相位、驱动或检查频度，full phase checker也必须编入同一snapshot；不是以pilot签全链。两个mode同样在初始化时绑定WO原fixture，避免pilot漏计加载/observer开销。

末context响应在独立consumer中曾合法保持12拍，但当前生产parent没有run_enable/独立result_rsp_ready的外部控制口，out_ready仅影响WO。完整parent若自然发生context反压可被动核稳定；无法通过合法顶层口指定“第4095响应保持12拍”时应标该定向保持NOT_RUN，不能force内部ready或借独立peer结果冒充。正常WO out和父DONE保持均有现成合法顶层口，可随一次完整正常例完成。

### 独立参考已具备，仍未知的生产行为

只读布局核对本次已比较全部131072 context位型：E010 encoder0_context.mem按上述query/head/half重排后与E012/R004 AT005 input.hex完全一致。WO output.hex的4096组按上述s/row/half顺序与E015 AT007原wo.bin/expected_f32.bin的131072位型完全一致。原WO gold SHA `1527544ebbc58548cacd152ba0a98fe679332fc83d651f3c2ffed15b4eca19dc`，原WO weight SHA `6be3b4e35057b15055db95ef5ab1d572ce202ac89200abc51479a1bfdd31c288`，均来自已有fixture.json；未重算gold。新完整模式仍须把所有WO p0..p3、input/Awrite/output/prebias/源manifest身份纳入snapshot，期望文件不能被当成真实context输入。

目前“已证TB缺口”不等于“生产RTL有缺陷”。以下组合行为仍未知：全部16head及layer Check退休；真实layer result读与同storage phase4/DIV phase5并行路由；QKV A释放后同request/gen/epoch重新真实填槽是否正确失效旧内容并发布新context A；layer4096覆盖到real_idle与quant/A完成的联合排债；唯一W/A/cache/FP/PS由QKV→layer→WO的重绑定与迟到响应隔离；WO输出保持、最终成功状态/tuple/identity与held父DONE。当前源码有相应调用路径但未完整实测；必须由新正常链暴露问题，再在授权内定位修复，不预先宣称PASS或FAIL。

现e354的c_fault相位修复通过当前短QKV/reset scope，仍未动态覆盖“真实父context fault→无reset新generation”链；这是独立错误恢复后继，不应拿正常完整例当作该故障覆盖。Encoder0无bias完整链也不能签Decision/bias、全图原首错/Check、30层、HBM注册/CDC/物理时序/板卡。

正常成功tuple零有具体源码依据：facade[每次实际cmd清状态/坐标](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_facade_v1.sv:240)，parent在WMRUN消费实际m_done后映射成功状态/域并返回该坐标；新TB仍必须把预期0与原命令身份逐项核对，不能用来源稳定性代替独立期望。

### 建议集中制定的新预算与一次完整运行上限

建议新独立批次（名称由主控决定）reference0/static300/RTL7200/OOC0秒，不转R001/R002余额。static每次≤120秒；同一当前RTL/全检查TB构建后先真实完整QKV→首head pilot≤1200秒，再由主控基于该pilot决定一次full≤5400秒（90分钟）；其余600秒仅供有新诊断依据的短恢复/受影响回归，不自动再跑整条长前缀。全部真实语义停滞120秒、CPU0–3/nice19/idle、MemAvailable>192GiB、static≤24GiB/RTL≤8GiB、40Mcycle及项目锁不变。budget是建议而非本次已获执行额度。

旧3494.951523668秒只说明旧parent/旧首head observer下的attention-only费用，不能为e354或新全检查TB放行。旧E012/R004完整WO203.558494425秒来自独立context-file runtime；R001本地consumer6.426384921秒也不是当前完整父的phase样本。它们仅帮助给新5400秒一次性cap留工程容量，不能拼接成当前完整链实测。

新pilot必须给P=当前同snapshot命令至首head退出wall、H=该实际head0 begin→end wall，并保留阶段/数值证据。建议供主控决策的工程估计 `E=1.35*(P+15*H+C_allow+W_allow)+10`；第一次完整链尚无同runtime C/W样本，可在新集中合同中明确选择C_allow=60秒、W_allow=600秒作为收费/停止占位（不是测量、不是性能保证），而不要求先做完16head才能给第一个完整例放行。若E≤5400且当前pilot数值/所有权/strict进度通过，可由新合同明确授权一次完整例，在这次运行里直接测得所有head/context/WO真实成本与完整成功；若超cap或pilot失败，交主控集中调整scope/预算，不在runner自动加帽或反复重放。当前没有执行/放行任何pilot或full。

完整验证同时记录原QKV≤57344、Encoder layer≤188544、WO≤22528、每满足前提dispatch≤16且父调度合计≤128，以及Encoder整块≤268416拍；新合同应精确定义原QKV_ACCEPT/WO_RETIRE事件，并同时记录父cmd accept与QKV matrix cmd accept，避免把不同边界混写。外部held停顿单列，不能自行从原总帽扣除或把独立周期相加写成实测。FPGA吞吐/300MHz/物理fit仍不属于仿真wall预算结论。

## M007 E016 R003 FULL-PARENT-15 actual delivery (2026-10-22)

# E016/R003 完整Attention父链实现与实际输入

SM012 D-M007-SM012-FULL-PARENT-15。当前parent e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8及原FP/DIV/layer/resource closure冻结在AT004；生产RTL未改。实际完整TB保留全部原QKV/W/A/prebias/RoPE/score/prob/context/连续issue/PS反馈/8身份拒绝checker，并按head和两次matrix操作分开计数，新增每head128maximum终断言、真实公共context4096、同quant/A发布和WO131072原gold，以及首次正常父成功的独立243bit期望与保持/退休。

实际AR接受时按已注册QKV/WO地址锁存来源和base，每ID返回使用锁存字段。原out_ready合法中间/末WO反压，done_ready保持5拍；不强制内部state/ready，不用原context文件代驱动真实layer输出，不复制生产服务。所有模式使用同一完整snapshot并在初始化加载相同完整fixture。原model/numeric/table/graph/layout/build128bit source tags与kind/layer keys沿用e354校验；当前W576/RTL/compiled身份另外记录，不当作当前bitstream。

新增parent+adapter控制1561bit/196B，原保守3550B合计3746B；452实际输入源，实际唯一服务层次由最终审计核。声明和功能展开不签物理fit。原地址描述符仍来自可信fixture，未实现任意Host/HBM源注册。参考复用E010全16head与E012/R004 AT005原context/WO/packed W文件，复制冻结并逐SHA登记，未生成新gold。
## M007 CONTROL-ARENA-16 FFN interface preparation (2026-10-22, A010)

本段只读准备已完成，无生产RTL修改/EDA/新数值gold；R003完整Attention父链completed/frozen不变。独立设计与原始字节证据见 [FFN planning](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/planning.md)、[mapping_byte_checks.json](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/mapping_byte_checks.json) 与 [source_versions.json](../../../../../../E016_m007_single_resource_parent/experiment_results/planning/ffn_control_arena_20261022/source_versions.json)。

唯一后继为公开norm_ff F32输入的Encoder0 FFN island：同quant/A K1024→同matrix Wi K1024/N5248→native双槽G→4×8拼32→同quant/A另一槽K2624→全成功与真实债屏障→同matrix Down K2624/N1024→公开Down输出。它尚不签R003后的真实residual/LN或完整Encoder。Wi每物理块s已含原列32s..32s+31和2624+32s..2655+32s；原0..81调度已经配对，0/41重排不成立。W cache slot、PS context、G slot虽均s[0]，但分别按真实W release、matrix第256拍输出消费及G的512向量/真实债清释放，禁止合并退休。

独立字节核对PASS：原Wi→x/gate671744值、原AT058全12字段4030464字、G41984向量地址、E012 Wi20992拍/671744值、167936个原Q8权重record/5709824B。G输出s→row→chunk，4笔8lane拼一组32F32以(row,group=s)直接量化；front/A支持此group-major顺序，无整G重排RAM。只需一份128B数值holding；17bit seq/full及新增cancel/owner等控制须实计入当前余482bit，4035.75B仍是投影。

Wi使用shared256/PS，G原56mul/16add池与TANH8独立，quant使用原32mul及phase5 DIV8；不能把G固定3/4拍通道接到8拍shared256。storage PS/G独立bankset且同真实phase1身份允许分束同时服务，不能用全局owner屏蔽合法束。现资源壳只有EXP8专用tag接口，G原96bit TANH/pool接线尚未加入父；validation_shell自带storage不得进入父。EXP/TANH联合物理共享、896DSP/300MHz仍未签。

确定接口缺口是G上游取消：现discard要求!active/needs_discard，Wi中途失败将使G等待缺失输入。后继须由当前G单一owner增加身份匹配producer_cancel、仅排已接受实际工作、保持取消回执并经真实discard/release恢复；不虚构全覆盖。front已有producer_close失败与partial/published未leased A取消。父按Wi→G(rank,row,col)→Q8(G)→Down原图顺序选择源错误，保留G32bit 0/6/8与matrix/front状态的显式适配；Down仅在Wi/G成功、成功close后的quant/A完整发布与全部真实债/lease退休后准入。

原生产出处：Encoder0 skip=embedding_norm；attention_residual=skip+WO；norm_ff=无gamma LN(attention_residual)；Wi→G→Down后回加同一attention_residual。当前R003未接skip保存/真实残差/LN/Down残差生产者，不能将WO直接喂Wi。原E012 Wi source与AT007 norm_ff、E012 Down source与AT007 geglu逐行完全相同数均0/128，旧矩阵gold不能签当前全链；独立原Q8(G)/Down同输入期望尚缺，本准备未生成。A007 live external-control源只作静态依据，不继承E015 AT146旧SHA PASS。完整验收和独立预算由主控集中下达。

## M007 FFN-REFERENCE-18 R004 local reference exit (2026-10-23)

A010：原G row0独立Q8(2624 codes/82 half scales)、norm_ff32组及Down1024 F32参考生成并审计PASS；完整128行成本式127.26535248011352s>120s，严格COST_STOP/NOT_RUN，无RTL/EDA/整模gold。原参考/运行库/完整输出SHA与真实收据见[局部参考交付](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/final_delivery.md)。[逐束连线表](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/reports/ffn_connections.md)固定norm_ff→Wi native0..81→双槽G→1024bit拼接→同quant/A槽1→完整成功屏障→Down；新父计划20bit，复用2套descriptor和原5bit state。A007取消实际声明3bit但最终正常回归待交，联合设计投影4038.875B/向上4039B，非实现fit。若另存两套Wi/Down descriptor将增1024bit超帽。完整Encoder真实skip/residual/LN和本输入128行Down参考仍未就绪；不继承旧e354 PASS。

## M007 FFN-CHAIN-20 kind3 implementation (2026-10-23)

Current contract: `mission/M007_完整Attention高性能主干与部署闭合/tasks/SM012.md`, D-M007-SM012-FFN-CHAIN-20; original quantified limits in that mission's `performance_requirements.json` (Wi92160, Down56576, GEGLU eligible latency256/pair768, FFN150016, unhidden tail1280cycles). Public kind3/layer0 is an FFN service from original norm_ff; complete Encoder input/residual/LN is a subsequent integration boundary.

Two existing descriptors bind original manifest ordinal+1 Wi60 and Down88. One public4096-beat input fills A0; native Wi82 blocks supply actual dual G slots, four8-F32 outputs form one32-F32 quant input into A1. Held Wi/G success plus all41984 G vectors and10496 quant acceptances authorize successful producer_close. Real quant/A full publication, all leases/debts and G/TANH retirement precede Down. The original5bit state is reused with12 added encodings; assembler16bit sequence plus4 one-bit flags add20control bits, one1024bit numerical payload. Prior joint4036.375B plus20/8=4038.875B/ceil4039. This accounting excludes unimplemented later Encoder/LN controls and is not physical utilization evidence.

Pure `laya_m007_control_workspace_joint_v1` owns one external state store for layer coverage and G math. F_ARENA/F_RETURN route actual old-owner resource idle to the layer for safe owner switching; the remaining FFN states select matrix/quant resource bundles, with independent PS/G bundles. Actual Wi shared-FP ownership and original storage identity qualify G admission, alongside a real TANH8 lease. Original G pool and TANH8 are instantiated once; existing EXP remains separate. No validation shell/private resource or saved G production driver is used.

Wi/G errors close the quant producer as failed, cancel actual G accepted work, drain matrix/quant/bank/numeric debts, consume cancelled DONE then discard actual G slots before owner return. Parent first-error status/tuple storage is reused; unknown32bit G statuses are preserved in the96bit error tuple. Kind0/1/2 expressions retain their original branch. Exact code/build/fixture identities and run-specific PASS/FAIL/COST_STOP are in E016/R005; R003 e354 complete Attention evidence remains frozen.

## 2026-10-23 D32 canonical parent_v3（源码阶段）

权威合同为source/m007_residual_encoder30_20261023.md §12/14与SM012 D32，记录在E016/R007。独立v3 ABI cedb4c13…b985只接受kind5/6/7；旧v2/R006冻结不改。SETUP/INVALIDATE/BEGIN共用held DONE，模型commit只在成功SETUP_DONE实际消费后发布。两descriptor槽由120-record catalog真实读返回装入；CRC含最后实际word。source_epoch保留，新增active_epoch_offset9在旧岛退休后切换。preLN写Q后先完成Q量化并release scratch，才prepare正常Attention；中间图不导入gold。正常后段含postLN、原Wi/G/Down或Decision FC1/ReLU/quant A1/FC2、residual与层推进，final gamma/type及544向量gather。

公开tail owner在H_LOAD前arm，成功只接受真实外部写完成commit；abort接受后还等owner_idle。TB SIM peer将真实公开输出写自身target，再按字节/身份发commit，checker独立。生产DMA/Host地址前端仍未绑定。本阶段源码/TB/runner已写，实际编译、census、完整setup和正常数学图均NOT_RUN；详见E016三摘要及R007源身份。

## D32/R007 actual version update 2026-10-23

Canonical production parent7b0d0c6d is compiled with current owner joint/TANHv3 in AT012 and successor affected snapshots. Actual setup124catalog words/704model chunks/twoRoPE families, public ABI/recovery, catalog lateRLAST drain and32342bit logical census passed; this supersedes the earlier source-only status, which remains historical. Actual parentQKV1 checks8192original values after real4096H/quant/A; it is unfinished. Current B1 normal-chain cost checker compiles in AT026, runtime cost work continues.

AT025 same-production joint G/twofullresidual/LN128 component passed183.031842316s,8192residual+4096LN vectors/394760F32 checks and15440G nodes. Observer-only residual_total increment separates AT024 from AT022; AT023 raw0 reporting defect remains immutable. Final A is Attention owner return, not actual LN→quant/A chain. Exact sources/receipts/limits in E016/R007/actual_joint_LN128_evidence.json and current three summaries. Full Encoder/30layer, canonical bias readback, actual Decision16384FC1/K4096→FC2, physical timing/fit/DMA remain unverified.

AT027 originalB1 QKV3 actual PASS89.599573990s,24576F32/16461commandcycles. Current completeQKV estimate1518.477961845s exceeds1200componentcap; completeEncoder costUNKNOWN, latermathsegments remain unmeasured. AT029 realquant/DIV/A maximumK4096 A1 16384write+ACK and realpartialcancel/newgeneration passed; this does not sign actualFC1producer/FC2 or parentACANCEL. AT030 finalrecord CRC passed. No in-flight EDA at staged handoff; authoritative versions/cleanup/cost/budget in E016/R007/staged_delivery.json and three summaries.

## D32 current AT031–037 boundary

Canonical93productionfiles remain identical to AT026. AT031 realfullQKV48retirement/393216originalF32 and2048RoPE plus occurredQK/SM checks are accepted; postQKV120scap COST_STOP1403.258719394s, nofullhead/EncoderPASS. SameAT026typical/off QKV1 pair passes equal106events/8192values/14343cycles,49.153994803/40.763996112s; singlepair17.07%wallreduction only.

Newindependent m007_fullmodel_encoder_tb37e8c147 compilesAT036off and actualQKV3 passesAT03780.903062850s/24576F32/12461cycles, actual4096H inputbinary matchesoriginal47checkpoint. Fullfourmatrix/Attention/G/resLN/FFN/finalH/heldDONE originalchecks are retained in source but onlyQKV3hasrun. AT035unusedobservercompilefailure is immutable. NewQKV48E1390.687966983s exceedsordinary1200/component and remaining-minus400reserve; fullEncoder/30layerEUNKNOWN. AT036policy16/19,3transientcompileridentitiesUNKNOWN; allrecordedowned/groups empty. Authoritative evidence: E016/R007/AT031_037_staged_delivery.json and three summaries.


## §17 binary simulation weight peer

The owned TB peer m007_binary_weight_peer reads original TN8 Q0/Q1/scale binary files on demand using immutable120 metadata and per-(port,ID) AR-frozen descriptor/origin/length. Explicit byte slices preserve Q and F16 bit patterns. Independent per-port handles avoid seek interference; fixed source cache payload2048B and held R payload256B are simulation input storage, separate from 11040B metadata and test oracle arrays. No production resources or arithmetic change. Independent expected bytes come directly from original GGUF Q8_0 offsets. Binding and source hashes are in E016/R007/binary_peer_actual_evidence.json. Integration into complete checker and current production W-reader parser retirement is a subsequent test boundary.


## Source-only real kind6/7 original-checkpoint checker

New m007_fullgraph_binary_tb uses one public input/BEGIN and original all120 descriptor-addressed binary source. Global0..27 residual-final H commits map one-to-one to encoder00..27; global28/29 map Decision00/01. Unique4096 addresses plus actual state97 resident/scratch/resource retirement qualify layer handoff. State90/offset448 Q commits map final_norm, state95 H commits map type_add. Original marker_gather512 groups + Decision1 CLS32 groups supply tail544 expected bytes. Only actual public handshake bytes are written/flushed before delayed identity-bound commit and final heldDONE. The47 source inventory has34 FPGA/input/gather comparison points and13 identity-only CPU/etc points; intermediate score/QKV/G gold is not added. Kind6 uses a legal original public component input; kind7 only H0, no intermediate preload. Source-only frozen manifests and exact evidence are under E016/R007/prepared and fullgraph_checkpoint_mapping.json, not compilation/runtime proof.


Fullgraph checker public-boundary revision2 source677e5bc9 adds per-handshake original marker/CLS out_row checks, full tail_begin request/generation/source_epoch/69632B qualification, and independent SIM tail accepted-identity latches used/asserted during held commit. Prior87cca31b prepared source/metadata, gold and production are untouched; exact SVpart reversal reconstructs old top. New source-only snapshot and minimal patch: E016/R007/fullgraph_public_boundary_v2_delivery.json. No compile or RTL launch for this change.


Residual reference loading repair (source-only): pending1D TB172d3019 and binary-kind5 TB246c2d6a now read all131072 original32bit GOLD words and pack every4096x32lane vector without changing values, simulation delay or assertions. Prior packed-array direct load was invalid; original XSim QKV prefixes had not reached that checker. AT045 independently reconstructed524288B/131072lane against original attention_residual.bin bac04c09…482d8; other49 reference loads remain exact. Oldfrozen/failed versions preserved; fullgraph677e5bc9 and production/gold unchanged. No A010 EDA; same-top source/diff/evidence handed A012. See E016/R007/residual_loader_repair_delivery.json.


## AT047/048 read-only compatibility evidence

Fullgraph677e5bc9/peer4d9265c2/production parent7b0d0c6d are unchanged. AT046 wrong tool-runtime path failed before review and remains recorded; AT047 corrected bootstrap path source audit passed3.795146179s, including15 exact one-dimensional readmemh shapes and inspected unsigned byte FREAD/binary FWRITE/immutable source metadata semantics. No frontend/runtime PASS follows.

AT048 read-only audit1.241986789s found no concrete result-changing risk in exactly3 SIDEEFFECT+2 MODDUP warnings from E021 AT013. Pure input-only automatic tr/tv and3 generated blocks preserve8 sequential dfp increments each. Legacy tile_bank module bodies are identical; service_v1 bodies differ but neither has a current-top instance or generated cpp/h identity. Other513 warnings are unassessed, and the two unused service bodies must not be assumed interchangeable for a future active top. No production/TB edits, EDA or physical result. Evidence: E016/R007/readonly_compatibility_delivery.json and attempts/AT047_fullgraph_fileio_source_review_fixed_path/work/audit/source_review.json plus AT048_selected_verilator_warning_source_review/work/audit/warning_source_review.json.


Context single-credit observer correction: current1D505e0b93 and binary-kind58a4a3956 swap only the original response/read observer blocks to verify old data/tag/credit before installing a same-edge replacement read, matching unchanged production adapter. All identity/order/data/debt predicates and original gold remain. AT051 static exact-reversal/protocol-token audit passed; corrected runtime remains separate A012 work. Old172d/246c and AT033 failure preserved. See E016/R007/context_credit_observer_repair_delivery.json. Fullgraph677e5bc9 is unchanged and has a checked-progress gap before the first final-H endpoint; source/fixture handoff and proposed distinct retirement observer are in fullgraph_progress_source_handoff.json, not implemented.


Fullgraph retirement observation successor8b556ca2 (same top): adds only two64bit simulation counters and real-edge7domain result/ACK observations; each accepted interface event counts1 and every128new events prints M007_RTL_RETIRE_PROGRESS retired=N cycle=C. No clock/state/AR credit, no layer reset, no print without new events. It is separate from original checked-gold words and is not an operation count. Exact observer removal reconstructs677e5bc9;505e mainline/peer/production/gold unchanged. AT052 static source/counter audit passed, no HDL/RTL evidence. Frozen source/event list/source manifest in E016/R007/fullgraph_retire_progress_delivery.json; A012 alone adds future guard strict-marker support, current Encoder driver unchanged.


## D36 final gamma hold and saved actual suffix (2026-10-24)

SM012 D36 uses the frozen actual Encoder27 H, not a new reference. The parent now keeps `v2_resident_ln_use_gamma` asserted in both `N_START` and `N_RUN`; the real resident provider issues its lower LN command after the parent start handshake. Ordinary pre/post LN states keep gamma disabled. No numerical leaf, public kind5/6/7 ABI, shape, or independent gold is changed.

`VERIFY_POST_ENCODER27_H` defaults to zero in the parent and common TB. When enabled for kind7, real SETUP, BEGIN, TAIL_ARM and 4096 public H loads still run; only the existing `E_H_READY` success/retirement branch enters `N_OWNER` with layer27/offset448. The unchanged production suffix then runs final LN/type and both Decision layers. This verifies a segmented suffix and does not replay the original prefix handoff or establish a repaired whole once-BEGIN30 run.

The immutable rev2 source manifests and source-only audit are in `project/E016_m007_single_resource_parent/experiment_results/runs/R007/d36_final_gamma_suffix_source/rev2/`. Rev1 is preserved with its known TB separator/lane diagnostic errors. Rev2 fixes both, retains the exact original composite final-LN predicate, and captures actual committed final-LN/type vectors by address. A012 alone owns compilation, runtime evidence and D36 accounting. D36 validation is now complete: the old gamma0 data failure was reproduced, and A012 AT006 passed the complete same-runtime segmented suffix with gamma sequence 1/0/0/0/0, both Decision endpoints and real tail/DONE/idle. Each of the final-LN, type and two Decision endpoint captures contains 131072 actual F32 words equal to original gold. The original R003 failure and old 28-Encoder evidence remain unchanged; the repaired complete once-BEGIN30 run was not executed. See the D36 results below and the [root review](../../../../../../../results/reviews/m007_final_ln_suffix_review_20261024.json).


## D37 repaired original30 normal-path validation (2026-10-25)

The unchanged fixed parent `9d877217...` and common TB `2bd73c51...` have now passed the complete original kind7 graph in one runtime with `VERIFY_POST_ENCODER27_H=0`, original `initial_H`, and one public BEGIN. This exercises the production path from original input through all 28 Encoder layers, actual Encoder27 retirement-to-final-LN/type handoff, both Decision layers and real tail/DONE/idle; the D36 saved-H entry is disabled. No RTL, TB, numerical rule or ABI change accompanies this result.

[A012 E021/R005 AT002 actual receipt](../../../../../../E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/receipt_rtl.json) records 30 completed layers, 120 matrices, 480 heads, 60 LN, 61 VECTOR, 28 GEGLU and 544 output groups with one actual tail commit, held DONE consumed and normal idle/rc0. The controller independently checked all30 actual H captures and unique traces plus final-LN/type against original gold. D35's original FAIL and D36's segmented-suffix identities/results remain historical evidence. D37 establishes the tested complete normal-path functional case; physical timing/fit, board operation and exhaustive abnormal-path coverage are not established. A010 only updates documentation and returns to paused.


## D38 complete-kernel physical stage (2026-10-25)

Authority is SM012 D-M007-SM012-FULL-TOP-PHYSICAL-38. Full production parent9d877217.../VERIFY0 and all91 D37 production source bytes plus original EXP ROM are frozen; TB/peer sources are excluded. The complete parent generics include the D37 tested address profile/apertures/platform identity, not the invalid zero platform defaults. Physical entry is physical_d38/run_physical_d38.py and its stage Tcl/XDC. Target xcu55c-fsvh2892-2L-e,300MHz internal clock,OOC bare kernel; shell IO delays/uncertainty and board integration remain unspecified. No dynamic interface is tied off or numerical leaf replaced.

Each actual stage is budgeted/guarded with source-bound DCP resume, CPU0-3/nice19/idle,24GiB RSS/192GiB available and the single project lock. Read [E022 protocol](../../../../../../E022_m007_full_top_physical/experiment_source/protocol.md) for actual commands, configuration versions, failure retention and external/internal timing boundaries. No physical PASS exists yet.


D38 AT005 repair: matrix op0/op1 now64 unpacked packed-vector slots with64 static-LHS processes, same capacity/asynchronous reads/concurrent writes/reset/priority. Exact inverse and actual storage source equivalence are in E022/R001/repair. Canonical parent unchanged; new full source closure is input/source_manifest_v2.json; D37 original identity is bridged only for local storage representation, not rerun.


## D38 operand storage representation (2026-10-25)

Under SM012 same-semantics repair authority, matrix_engine op0/op1 now use64 unpacked slots each packed8192bits with static-slot always_ff writes. Whole8192bit format/mul/add/zero operations remain; lane j is exactly flat[32*j+:32]. PS scatter write and commit-read lane access use the equivalent32bit slices. Original asynchronous reads,64×256×32capacity per pool, distinct-slot concurrent writes, reset-no-clear behavior and op0 add>mul>format/op1 PS>zero>format priority are unchanged. No pipeline/arbitration/latency/interface/numerical change. Latest SHA f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd; exact inverse restores original2147 and prior e279 bytes.

E022/R001/repair_v2 stores actual original/latest source extracts, source mappings and inverse proof. AT012 compile and AT013 four-state6721cycle/13442full-pool comparison PASS, including all64slots/256lanes/32bits, finite event/collision/read/reset/X coverage. D37 full30 remains original source identity with this local bridge, not a new full30 rerun. Newsource_manifest_v3/bottom_up_v6 freeze90other sources/ROM/parent unchanged.
