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

