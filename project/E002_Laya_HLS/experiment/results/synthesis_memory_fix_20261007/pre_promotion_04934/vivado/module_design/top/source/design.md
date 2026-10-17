# 总体集成：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/top`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：28层Encoder、2层Decision及scorer/act已完整连接；当前包的CPU整图与真实13口HLS CSim通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

集成一次完整Typed-Decisions Q8前向。服务器CPU负责分词/组帧、XRT和业务解码；U55C负责embedding、28层Encoder、2层Decision、scorer及act。顶层组合模块并传递上下文，平台适配由kernel_wrapper负责，执行顺序由forward_controller负责。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 最终功能 | 完整神经网络在U55C执行 | 明确要求 | 00§1/用户部署要求 |
| 模型维度 | D1024；16head×64；28+2层；16候选 | 工程事实 | 00§3/04模型身份 |
| 首版范围 | B1/2，S64/128/256/512/1024；一次forward调用 | 推断 | 00§3、02§2 |
| 实现组织 | 一个外部kernel；共享Q8、FP、向量/LN单元 | 推断 | 00§2、03§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [00_overall_design.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:7)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:53)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:70)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:104)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:119)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:158)、[§10](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md:199) | CPU/FPGA分工、完整前向边界、共享模块及实施缺口 |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:34)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:97)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | 完整前向kernel、HBM连接、构建验证与平台边界 |
| [03_forward_controller.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:32)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:48)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:59)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:69) | 层内依赖、共享资源互斥、F0/F1调度与联合流水 |
| [14_result_status_and_verification.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:29)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:59)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:73)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:102)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:120) | 结果提交、联合验证、数值/性能口径、错误及证据状态 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:84)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:92)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:100)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 整网接口、三条联合流水、交接证据及变更传播 |
| [16_llama_baseline_to_laya_u55c.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:33)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:51)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:69)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:77)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md:90) | 两个Llama baseline的版本、代码对应、迁移限制与上板路线 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| 入口检查 | kernel_wrapper交付请求/BO上下文 | 按common/memory_map检查版本、shape和索引，建立本次所有权 | 合法请求进入embedding；非法输入交result_status |
| 前端与Encoder | token→embedding/LN→28层 | 每层LN/quant/QKV/RoPE/attention/Wo/residual/FFN；第0层attention前LN跳过 | 旧hidden保留到残差最后一次读取 |
| Decision与heads | final LN/type add→2层Decision→marker/scorer/act | Decision仍处理全部S，复用相同引擎 | CLS保留至act输入形成 |
| 结果交接 | candidate/act logits与状态 | 写入IO结果区并排空 | kernel完成后Host wait＋sync核验身份 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| 请求/平台上下文 | kernel_wrapper→top | 13候选BO及请求B/S、身份 | 字段合同已定义，生成信号待G2；不手写寄存器偏移 | 上一请求释放前不复用IO/工作区 |
| 调度/数据 | top↔forward_controller及算子 | F32/A8/scale/控制上下文 | 数值数据与层、b、tile一致推进 | 共享引擎互斥；有空间才交接 |
| 结果 | decision_scorer_act→result_status | F32[B,16]＋F32[B,2] | 保持batch/候选顺序 | 写可见后成功完成 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 统一采用GGUF原始Q8权重与F16/F32例外；Q8不表示全模型INT8。
- 不在顶层改写算子数值顺序、mask或温度；具体语义由各模块及共同规格定义。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| HBM模型/工作区 | memory_map和加载器管理 | 模型只读；请求期间工作区归设备 | 顶层不复制一套模型或缓存 |
| 共享计算/状态 | 控制器授予所有权 | 在途运算排空后切换层/模式 | 实际实例数量须由综合报告确认 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 完整层的QKV全部写完才进入双向attention；F0阶段串行。
- F1只能重叠已经证明计算资源、RAM端口和外存路径无冲突的阶段。
- 测试按HBM→实际Q8 Linear→单Encoder→完整网络递进；中间核是验证工具，最终仍要求完整前向。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp)、[fixture_contract_test.py](../tb/fixture_contract_test.py) | 注册表与真实S128 fixture合同回放已执行；完整数值forward未运行 |
| P0 C++源（hls路径） | [laya_modules.h](../../../../include/laya_modules.h)、[laya_forward.h](../../../../hls/laya_forward.h)、[laya_forward.cpp](../../../../hls/laya_forward.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_top`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 正常链路 | B1/B2、每个S桶、完整28+2层 | 中间检查点及raw logits与独立参考比较 |
| 共享资源/复位 | 随机停顿、最后写响应延迟、故障恢复后新请求 | 无提前覆盖/旧结果；所有权和数量守恒 |
| 业务完整性 | 退款/部门两题与质量集 | 同Typed输入与CPU解码口径，GPU/FPGA使用同请求 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/top/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G1真实platform/复位；G2共享IO；G3导出器和Golden-C；G4整核资源/时序；G6/G7验收和GPU对照。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

整核顶层保持HLS单forward函数与02的13 BO顺序；并非15个并行外部kernel。common给共享字段，wrapper控制run，controller独占调度，memory_map/cache管理地址与生命周期，07–13算子提供分类型任务，result_status最终提交。类型、byte/bit宽和错误码由01§6、04§7、14§9、15§10–§14共用。

| 顶层边界 | 交付合同 | F0断言 |
| --- | --- | --- |
| Host→wrapper | 128B头＋5×32B目录＋64B对齐payload | 先全输入校验，后网络计算；占用期间Host不改BO |
| controller→算子 | TaskContext＋各自Task参数／TaskDone | 全局一个task在途，done drained=1才发下一个 |
| 算子间 | 已发布完整数组／cache | F0阶段边界不靠小FIFO存全矩阵；内部stream由同task持续排出 |
| QKV／FFN／heads | 固定BO布局与BufferRef epoch | 最后响应之前不发布；物理别名共享锁；CLS保持至act拼接完 |
| 结果→Host | 固定384B定义帧，16*B＋2*B有效F32 | 数据和头写回排空、XRT wait/sync、身份校验后解码 |

集成trace关联request_id/generation/task_id/op/stage/layer/b/row/head及各epoch；同一个模型tag并不意味native/candidate算术逐位等同。以本次abi_replay真实S128请求为首个完整功能基线，再覆盖B1/B2与所有S档。原生S94包作为原输入来源和规范化差异证据，不能当S128硬件每列输出期望。

尚未开始HLS/RTL全图实现。软件原生捕获／ABI解包回放仅证明参考和帧格式，不等于C仿真、RTL、综合、时序或上板成功。后续先做真实LN→quant→Linear、QKV→attention和Wi→gate→down/residual三链，再拼整网和XRT。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `candidate_raw_logits` | `ir_1469 / add_119` | `native/forward_0/ir_1469.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

原生融合attention内部QK score／probability明确未捕获；native K/V/mask的F16转换和FLASH_ATTN_EXT与候选FP32显式链分开登记。此处不能把candidate生成的score/prob称为上述alias的native节点。

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前集成只注册15模块状态、构建唯一合同源码并运行各模块及真实fixture格式测试；没有可调用的成功forward。基础状态模型只核对epoch/region、调用者声明的覆盖和content_kind，尚未完成A8的K/rows/batch/row0/row_space及源epoch、W的WeightKey/K/N、QKV的plane/head/B/S与请求/layer绑定。补齐这些关联后才可进入完整计算链和全层屏障验证，P0通过不等于跨模块数据一致性或全图数值通过。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。

## 13. P1独立数值切片入口与集成边界（2026-10-07）

[numeric_fixture_test.py](../tb/numeric_fixture_test.py)是本轮顶层**离线测试驱动**：按冻结manifest的GGML ne/nb与GGUF offset读取真实输入和完整K的W窗口，调用独立[oracle](../../../../tests/numeric_reference.py)与[CLI桥](../../../../tests/numeric_cli.cpp)逐值比较，并留存派生输入、逐窗口输出、哈希及native差异。[LayerNorm](../../layernorm_engine/source/design.md)、[Group32量化](../../activation_quantizer/source/design.md)、[Q8 Linear窗口](../../q8_linear_and_restore/source/design.md)各自维护唯一`*_compute.cpp`和直接`numeric_tb.cpp`；[P1独立源清单](../../../../config/numeric_sources.cmake)不链接P0主机所有权容器。

这三个阻塞数组函数只发布本轮tile或窗口的有效记录；Linear窗口不生成完整TaskDone，不发布整张QKV/WI/TMP，也不解除全层屏障。[完整forward注册表](../../../../hls/laya_forward.cpp)仍将15模块标为`contract_only`；生产A8/W缓存、整矩阵、QKV plane/head/B/S覆盖及attention/FFN等尚未接线。CPU真实切片和三个isolated CSim的实际证据见[results.md](results.md)，不能当作顶层RTL或全网通过。


## P2 C批：完整单forward功能入口（2026-10-07）

依据本次实际读取的[原规格](../../../design_source/00_overall_design.md)及[task.md §12.4–12.5](../../../../hardware_agent/task.md)，由Astra xhigh核定。

[laya_forward_full.cpp](../../../../hls/laya_forward_full.cpp)与[公开头](../../../../hls/laya_forward_full.h)已实现完整内部入口；[full_kernel_wrapper.cpp](../../../../hls/platform/full_kernel_wrapper.cpp)的外部`laya_typed_q8_forward`为13指针、一次调用完整28 Encoder＋2 Decision＋scorer/act。所有算术/搬运/层循环在核内，CPU只负责请求与业务后处理。独立P2 source/target/registry以真实源码与运行证据登记全部15模块；旧P0 kModules/forward_available只是历史合同target，不能用它挡住已实现P2或误报当前仍无算术。正式功能门禁绑定当前完整模型运行报告，验证模式可实际运行待验实现。

完整CPU主验收为真实B2/S128以及两题各自B1/S128全图，按候选oracle比较每层与head；至少一次完整HLS CSim。S64/256/512/1024先模块/任务全尺寸覆盖，未跑对应整网如实标记。实验full top综合、代表RTL联测与平台link/上板分开。


## P2实际实现映射与功能验证（2026-10-07）

| 实际责任 | 唯一源/验证入口 | 当前边界 |
| --- | --- | --- |
| 完整内部forward | [laya_forward_full.cpp](../../../../hls/laya_forward_full.cpp)、[laya_forward_full.h](../../../../hls/laya_forward_full.h) | 固定13 BO容量绑定后进入完整controller |
| 唯一层调度 | [full_forward_controller.cpp](../../../../hls/control/full_forward_controller.cpp) | 28 Encoder、2 Decision、scorer/act，46个非综合观察点 |
| 实际结果 | [full_result.cpp](../../../../hls/control/full_result.cpp) | 384B帧数据先写、头后写；final18从实际帧提取 |
| 外部核 | [full_kernel_wrapper.cpp](../../../../hls/platform/full_kernel_wrapper.cpp)、[full_kernel_wrapper.h](../../../../hls/platform/full_kernel_wrapper.h) | 13参数、持久Runtime；debug观察入口排除综合 |
| 完整CPU比较 | [runner](../../../../tests/full_forward_dut_runner.cpp)、[driver](../../../../tests/full_forward_dut_run.py)、[comparator](../../../../tests/full_forward_dut_compare.py) | 当前构建三次成功请求141点逐位通过，另有同Runtime已接受故障与恢复；内部controller边界 |
| HLS真实top CSim | [full_kernel_csim_tb.cpp](../../../../hls/platform/full_kernel_csim_tb.cpp) | 实际调用外部13口top，最终运行证据待取得 |

历史[初步机械复核](../../../../results/p2_environment_20261007/full_dut_preliminary_mechanical_check.json)记录真实B2/S128、两题各自B1/S128，共18,094,384个F32，47×3点均与独立候选oracle逐位一致；实际tasks_retired为37158/18895/18895。三次共用持久Runtime，A8最大epoch为1924→2886→3848。该run先于最终错误路径及事件记录收口，不作为最终源码/HLS验收。其他S桶只按任务与地址测试范围登记，不能扩为全图通过。
