# 公共配置与接口定义：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/common`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：固定任务类型、数值公共实现及身份检查已接入全部15模块，并通过当前完整CPU/CSim验证。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

定义Host/HLS及模块之间共用的尺寸、数值类型、请求身份、地址单位和逻辑接口规则。这里是定义的维护责任，不是另一个与算子并行运行的计算核。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 模型常量 | D1024，heads16，DH64，GS32，候选16 | 工程事实 | 00/04模型记录 |
| 候选几何 | TM16、TN8，普通向量8lane，gate/exp4lane，FP64lane | 推断 | 15§1 |
| 公共IO | I32 token/marker/qtype；原生masks F32，ABI编码U8；F32 logits | 工程事实＋ABI设计 | 01§2／§6、14§10 |
| 外部ABI | 13参数顺序、请求/结果格式由同源定义生成 | 设计合同＋P0主机端实现 | 01/02；精确字节合同见01§6／14§9；实际HLS端口与XRT联调仍待G2 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [01_host_runtime_and_abi.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:36)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:52)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:62)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:68) | 请求/结果ABI、模型身份、Host交接与计时边界 |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [04_model_package_and_memory_map.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:29)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:61)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:84)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:92) | 模型布局、HBM分区、地址/stride、权重复用及缓存所有权 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| 配置来源 | 模型manifest和当前设计 | 区分模型维度与实现并行度；记录model/numeric/layout/build身份 | Host/HLS/测试生成或引用相同配置 |
| 公共类型 | 逻辑F32流、Q8组及任务上下文 | 规定有效lane、数量、顺序及字节/元素单位 | 逻辑字段已由15§10–§14定义；C++/RTL实现时逐项核对 |
| 一致性检查 | Host/kernel/布局/测试引用 | 检查维度、版本、对齐与有限范围 | 不匹配不能进入网络计算 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| F32数据 | 所有普通生产者→消费者 | 最多8×32bit有效payload/拍 | 行优先，不跨行；gate拍可只有4个有效值 | 停顿时payload与元信息一起保持 |
| Q8逻辑组 | 量化/权重缓存→Linear | 32×S8＋1×FP16＝272bit有效内容 | 逻辑对象不等于外部AXI stream打包宽度 | 完整tile就绪，多bank同时读 |
| 上下文/标识 | Host/控制器↔全部模块 | 请求/层/b/tile/有效行lane及版本 | 精确逻辑字段见15§10–§14，不恢复旧CMD256 | 与数据同进退；错误关联当前请求 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- I32/S8是有符号，mask为U8二值；F16/FP16/F32按共同数值参考解释。
- 量化group数、tensor stride、尾lane和地址单位必须显式；不得让模块各自猜测结构padding。
- F0与F1是调度模式，不能改变逐输出归约顺序。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| 共享配置/布局表 | 导出器/同源头文件 | 模型和build有效期内只读 | 具体表驻留于aux/HBM或片上由使用者实现 |
| 任务/有效标记 | 控制器及实际缓存拥有者 | 请求/任务生命周期 | common本身不重复占用所有模块寄存器 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 变更TM/TN/位宽时，同时更新量化、缓存、PS、输出排布及性能表。
- 变更IO/bank时，同时更新Host、wrapper、memory_map与result_status。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [laya_config.h](../../../../include/laya_config.h)、[laya_types.h](../../../../include/laya_types.h)、[laya_tasks.h](../../../../include/laya_tasks.h)、[laya_types.cpp](../../../../hls/common/laya_types.cpp)、[laya_tasks.cpp](../../../../hls/common/laya_tasks.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_common`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 序列化一致 | Host与kernel同一帧/同源定义 | 字节布局、size、对齐及标识一致 |
| 数量与尾部 | B1/B2、N2、4lane gate、最后一行 | 无跨行、无效lane不参与访存或累加 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/common/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G2字段／枚举／逻辑位宽文档合同已定义；同源C++头与位域回放已完成P0主机检查；实际生成RTL及硬件联调未完成，复位和物理时钟随G1。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

公共定义直接实现01§6、04§7、14§9及15§10–§14；本模块只拥有定义，不另建调度核。共享头需静态断言128B request/header、32B directory、128B result/header及每个offset，pack/unpack按显式little-endian操作；358bit F32Beat／WiPairBeat与350bit Q8Group使用不同类型，禁止依赖C++padding或隐式转换。

| 类型／边界 | 字段来源与不变量 | 下一实现的检查 |
| --- | --- | --- |
| RequestContext | 01五输入和四128bit tag、u64 ID/generation、u16 B/S | masks原生F32、ABI U8转换只允许恰0/1；fixture零tag仅离线允许 |
| TaskContext | task_id32、op/stage/layer/b/row_space各8、row0为16、rows8 | op/stage/shape组合封闭；task_id不回绕；无CMD256 |
| BufferRef | id8、bank8、epoch32 | NONE唯一编码0/0/0，shard与ping-pong不可混淆 |
| TaskDone | 15§14的8个字段（含output_unit） | drained=1才退休，计数是逻辑元素/拍而非cycles |
| stream类型 | 15§13精确位域 | valid_count连续低lane，last精确，stall全部位稳定 |

公共数值配置独立于实现并行度；native_backend与hardware_candidate分别登记身份。CPU真实capture可证明模型图与数值来源，不能证明358bit流已经由HLS生成。联合测试读取真实request_v1.bin做逐字段解包，再重新编码比对1856bytes；生产模式应拒绝其三个零占位tag，而离线fixture解析模式仅作格式验证并显式标注不可部署。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `candidate_raw_logits` | `ir_1469 / add_119` | `native/forward_0/ir_1469.bin` |
| `act_input1028` | `ir_1613 / cat_57` | `native/forward_0/ir_1613.bin` |

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P1数值公共边界与唯一源（2026-10-07）

[laya_numeric.h](../../../../include/laya_numeric.h)声明三个阻塞数值入口及只读Linear trace；[laya_numeric_tasks.h](../../../../include/laya_numeric_tasks.h)定义请求四tag、F32/A8/W窗口元数据及持久目的owner，直接复用既有[laya_tasks.h](../../../../include/laya_tasks.h)的Task/BufferRef/Status。唯一公共实现[laya_numeric.cpp](../../../../hls/common/laya_numeric.cpp)提供完整请求/来源/窗口检查、覆盖、epoch claim/release/reset及FP16位转换，不引入P0主机容器；[P1源清单](../../../../config/numeric_sources.cmake)只链接该公共源和[三个数值算子](../../../../hls/operators/)。

三模块的直接TB分别位于[LayerNorm](../../layernorm_engine/tb/numeric_tb.cpp)、[Group32量化](../../activation_quantizer/tb/numeric_tb.cpp)、[Q8 Linear](../../q8_linear_and_restore/tb/numeric_tb.cpp)；顶层[真实fixture驱动](../../top/tb/numeric_fixture_test.py)将已发布的LN元数据传入量化，再以独立预期来源核对A8/W及窗口输出。公共辅助随三个isolated HLS CSim编译；仅量化isolated综合包含该公共源，资源不能另给common算一份。P1未增加完整forward的共享硬件顶层、物理cache端口或生产reset。


## P2 A批：共享数值与身份边界（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

新增唯一头`include/laya_full_numeric.h`定义§12.3的固定数组叶函数；P1 half/位模式规则复用，所有基本运算单独FP32 RNE。CPU/CSim libm版本、非线性近似边界和独立oracle分工按task§12.2；无动态容器进入综合可达路径。叶函数只返回Check，不创建新的请求身份或发布共享owner；完整任务绑定与owner在后续B批落实。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/15_integration_interfaces_and_pipeline.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

新增固定FullMemory/请求/运行/owner上下文，复用原Status/Task/BufferRef枚举，CPU与HLS共用13端口和字节协议。P0 vector Request不进入综合。P2 pure numeric与完整typed任务分层，不能由叶函数发布共享READY。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 C批：完整运行身份与数值版本（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4–12.5](../../../../hardware_agent/task.md)，由Astra xhigh核定。

P2 numeric身份对task§12.2有界精确文本哈希并保存前像；layout/build定义排除自身tag防循环。唯一FullInputs/Runtime与既有Op/Task/BufferRef/Status字段配合，规范存储几何与Task行空间显式转换。P1纯算术机械提取后共用唯一维护源，所有受影响P1回归必须重跑，旧run仅作历史。

事件计数与实际clock分离；无真实cycles计数清flags。跨request/generation/tag/epoch绑定必须在实际读写前校验，不能把构造READY metadata当作证据。


## P2实际实现映射（2026-10-07）

- [laya_full_runtime.h](../../../../include/laya_full_runtime.h)：本模块当前P2实现责任源。
- [laya_full_numeric.h](../../../../include/laya_full_numeric.h)：本模块当前P2实现责任源。
- [laya_full_io.cpp](../../../../hls/common/laya_full_io.cpp)：本模块当前P2实现责任源。
- [laya_full_owner.cpp](../../../../hls/common/laya_full_owner.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
