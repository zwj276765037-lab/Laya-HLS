# Embedding查表与反量化：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/embedding_engine`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：token/type查表与完整反量化接入整图，当前独立直接任务及完整CPU/CSim通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

从token/type Q8_0表读取需要的行，解包34byte组并产生FP32。token向量进入embedding LN；type向量在最终LN之后由向量模块加到对应问题。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 表与行 | token50368行、type3行；D1024；每行1088bytes | 工程事实 | 06§1/04模型记录 |
| 数值 | S8 q×转F32的FP16 scale；保留次正规 | 推断 | 06§2/数值参考 |
| 候选并行 | 8feature/clk、双原始行buffer | 推断 | 06§2 |
| 特殊token | PAD也查表，不能直接hidden清零 | 工程事实 | 06§1/模型语义 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [04_model_package_and_memory_map.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md) | [§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:61)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:92) | Embedding地址、分区与hidden生命周期 |
| [06_embedding_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/06_embedding_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/06_embedding_engine.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/06_embedding_engine.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/06_embedding_engine.md:33)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/06_embedding_engine.md:47) | Embedding输入输出、反量化、与LayerNorm的交接和验证 |
| [07_layernorm_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:28)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:40) | hidden整行就绪及LN输入供给 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | LN→量化→Linear供需、tile所有权与背压/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| 检查定位 | input_id/qtype | 范围合法后使用base+ID×1088 | 非法索引不发HBM读 |
| 读取解包 | HBM的连续行 | 跨64B拍拼接32×34B组 | 行buffer与输出有可用空间 |
| 反量化/交接 | q与FP16 scale | 按特征次序输出F32，type带对应b | LN/向量接受后再推进；不覆盖仍被消费的buffer |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| ID | 请求/控制器→embedding | I32[B,S]或I32[B] | token行按b/s；qtype0/1/2 | 先检查范围 |
| 原始行 | loader→embedding | 1088bytes＝32组，每组2B scale＋32B q | little-endian，表首64B对齐 | 跨拍/4KiB拆分由loader正确处理 |
| 向量 | embedding→LN或type add | F32[1024]，最多8feature/拍 | 保持b/s/d；type不混到另一题 | 背压时q/scale位置与输出一起保持 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 反量化FP16精确转换到F32后乘q；与GGUF反量化参考比对。
- CLS/PAD/MASK、重复ID均按实际表读；type只在final LN后生效。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| 原始行双buffer | 2×1088=2176bytes | 加载下一行与排出当前行候选重叠 | 一个buffer只有当前读者结束才覆盖 |
| LN输入行 | 由LN管理，4096bytes/行 | F0可先存HBM；F1直送LN第一遍 | 不要在embedding重复统计LN缓冲资源 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- LN需要完整行统计；embedding可连续输出不代表LN可立即连续输出。
- F1可让反量化与LN第一遍重叠，LN第二/三遍仍有服务成本。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [embedding_engine.h](../../../../hls/operators/embedding_engine.h)、[embedding_engine.cpp](../../../../hls/operators/embedding_engine.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_embedding_engine`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 字节与数值 | 表首尾ID、次正规scale、组跨拍 | 解包字节与反量化行逐项正确 |
| 地址/次序 | B2不同qtype、PAD、重复ID、非法ID | type与问题一致，非法ID无读 |
| 流水 | LN暂停和行切换 | 输出保持、无丢项/重复/早覆盖 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/embedding_engine/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3独立反量化与LN参考；G4浮点IP/实际延迟、随机行读效率；G1复位。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

实现EmbeddingTask：TaskContext＋table:u8、dst:BufferRef、type_id:u8。EMB_TOKEN按b/row0/rows读已验证input_ids，0≤ID<50368；EMB_TYPE从qtype0…2选TYPE_ROWS。每token产生1024F32，输入Q8_0每组FP16 scale在前、32个S8在后。不得因attention_mask=0跳过PAD查表。

每行32组共1088原始bytes，反量化`FP32(float(q)*float(scale))`。原始行buffer在解包完成前不得覆盖；34B组跨AXI拍要按字节重组，不以32B误对齐。若用F32Beat，col从0每拍加8，共128拍/行，dst预留epoch贯穿整行，最后一拍col1016且row_last=1。

F0先把完整embedding矩阵写HIDDEN bank，再LN_EMB独立任务读取；不能把整矩阵塞入小FIFO后等待LN任务开始。输出存储适配器必须在本任务内持续接收，最后一行/写响应都完成才done。TYPE_ROWS可只生成已请求type行，但每次使用核对model tag与有效标记；type add发生在LN_FINAL之后且按题b匹配。

真实检查点优先取本次native图embedding／LN输出，与真实GGUF对应行反量化作独立交叉比对。覆盖实际CLS/PAD/MASK、重复token、词表最后行及非法下一行；下游末拍暂停必须保持全部F32Beat位稳定。统计和浮点误差按native/candidate分类，不称已完成硬件反量化验证。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `embedding_raw` | `ir_216 / embedding` | `native/forward_0/ir_216.bin` |
| `embedding_norm` | `ir_217 / layer_norm` | `native/forward_0/ir_217.bin` |
| `type_embedding` | `ir_1411 / embedding_1` | `native/forward_0/ir_1411.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 A批：真实Q8行反量化（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§1–4](../../../design_source/06_embedding_engine.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/embedding_full_compute.cpp`，入口`embedding_row(raw[1088],y[1024])`按原34B组读取S8和FP16，完整32组产生1024F32。scale有限非负、q限[-127,127]；PAD照常反量化。ID及表范围由后续任务/loader在HBM读前检查。真实模型词表首末、CLS/PAD/MASK、重复ID和三个type行用独立字节oracle核验；不能把叶函数通过写成已完成模型loader。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/06_embedding_engine.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

完整EmbeddingTask先绑定表/模型与请求ID并检查所有输入索引，再真实读取1088B行调用A批叶函数；写全1024后登记行覆盖。PAD行不省略，type按本请求实际qtype填充TYPE_ROWS对应行，有效位分别管理。lookup→LN_EMB必须验证完整tile/最终全B/S，而不是返回计划数量。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[embedding_full_compute.cpp](../../../../hls/operators/embedding_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`embedding_row`。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_front.cpp](../../../../hls/operators/full_tasks_front.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
