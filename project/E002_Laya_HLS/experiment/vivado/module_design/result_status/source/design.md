# 结果帧、错误与完成交接：详细设计

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入每题16候选+2ACT F32与identity/status/诊断；输出io偏移16384处固定384B请求帧，payload先于提交头。

B1有效18个、B2有效36个F32；主要为存储/控制，无矩阵MAC指标。提前错误帧与成功推理输出须区分。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-result_status)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/result_status`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：384B实际结果帧、首因和提交诊断、已接受故障后恢复通过当前CPU验证，成功帧final18由真实top CSim核对。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

将候选与act输出、请求身份和错误状态写入IO结果区，并与顶层/Host完成流程衔接。测试台放本模块tb，完整系统联测由top/tb组织，不在结果模块伪造通过标记。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 结果区域 | io内从16384开始4KiB；头128B，候选offset128，act offset256 | 推断 | 14§1/01§3 |
| 结果张量 | F32[B,16]与F32[B,2]，B1/2 | 工程事实 | 模型输出/14§1 |
| 完成路径 | 输出和状态写完→kernel完成→Host wait＋sync→校验 | 推断 | 14§1 |
| 错误状态 | ABI/model/shape/index/buffer/numerical及runtime故障分类 | 推断 | 14§8；数字编码见14§9，生成代码待G2 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [01_host_runtime_and_abi.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md) | [§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:52)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:62)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:68) | 结果帧、身份字段、Host回读及性能口径 |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [03_forward_controller.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:32)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:48) | 整请求退休、共享引擎完成与异常收束 |
| [14_result_status_and_verification.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:42)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:73)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:102)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:120) | 输出写入/完成顺序、错误码、数值判定及计时 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| COLLECT | heads输出或控制错误 | 持有本次request_id/generation和B/S/版本 | 只收对应请求和有效长度 |
| WRITE | logits/状态/有效计数 | 按结果区布局写入，未实现字段不填伪计数 | 输出/状态可见并满足写响应/排空 |
| COMPLETE | 成功或可报告失败 | 交还kernel控制；Host核对身份/status | 正常成功才做业务解码 |
| FAULT/RECOVERY | 设备/AXI故障或timeout | Host记录运行错误，等待确实静止/恢复 | 不能要求故障kernel必然写出完整状态 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| logits | heads→result_status | F32[B,16]＋F32[B,2] | 候选占用预留128B，act预留64B | 数量与B一致，不读旧尾数据 |
| 身份/错误/计数 | controller→result_status | 版本/请求/model/numeric/layout/build、B/S及status | 字段位宽/枚举由同源IO定义生成 | 错误身份与当前请求一致 |
| 写回/完成 | result_status→IO/wrapper→Host | 4KiB区域，header字节合同见14§9 | 先数据可见，再完成；Host sync后读取 | timeout不等于可重用BO |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 输出保留F32未舍入logits，CPU温度与业务解码不在此重算。
- 计数器必须说明是事件计数还是时钟计数；未实现监测就不得把循环次数写成cycles。
- 成功字段和logits有效性绑定；数值/索引错误时不得沿用上次结果。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| 结果BO区 | Host分配/设备写 | 本请求执行至Host完成回读 | 4KiB容量是外存区域 |
| 在途写/暂存 | 平台和实现逻辑 | 写响应/排空结束后释放 | buffer深度/事务数量待实现，不默认整个4KiB片上缓存 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 与Host/kernel共同回放序列化与版本，不能按未经检查的C++padding写ABI。
- 不引入旧commit轮询或手写LAST_RUN_CYCLES寄存器；控制元数据由HLS负责。
- 结果写前抓取的计数快照不含最终写排空，不得标成完整kernel周期。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [result_status.h](../../../../hls/control/result_status.h)、[result_status.cpp](../../../../hls/control/result_status.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_result_status`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 正常结果 | B1/B2、候选/act长度、身份正确 | Host只在wait/sync后读取并核对 |
| 错误与过期 | 非法帧、错误model、旧generation、timeout | 显式失败，不返回旧答案或早复用BO |
| 最后写/恢复 | 延迟写响应、运行中恢复、随后首请求 | 完成顺序、在途处理和缓存有效性正确 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/result_status/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G2完整header、枚举、计数字段已定义，待编码器／硬件联调；G5故障恢复；G4真实写回/排空时间和监测范围。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

结果写入固定io+16384区域，128B头／候选offset128／act offset256／诊断offset320，固定已定义384B，详见14§9。status为u16枚举0…8，Host timeout/device/stale是独立Host事件0x1001…0x1003，不能要求故障kernel必然返回它们。

| 输入 | 校验／计数 | 输出行为 |
| --- | --- | --- |
| candidate | 16*B F32，来自CAND_MASKED，未加温度 | 按b/c写128+4*(16*b+c)，B1未用行清零 |
| act | 2*B F32 | 写256+4*(2*b+a)，剩余预留清零 |
| 首因／身份 | task_id、status/detail/bad_element、RequestContext | tag写本构建绑定值；不可信头ID按identity_valid规则置0 |
| 监测 | tasks_retired／输入输出元素／可选真实cycles | 逻辑计数和周期各有valid bit；无监测不填伪值 |

写回顺序为数据/诊断→头→所有响应排空→函数完成。Host只在wait成功及D2H同步后验身份/长度/status/flags/输出count，不轮询自制commit寄存器。错误时清128–319、logits_valid=0、两个header输出count=0；部分数值不得作为有效logits泄漏。

真实abi_replay两个输出和1856B请求可作为软件结果编码回放素材；当前尚无XRT/RTL结果写回证据。联合TB延迟最后数据响应和最后头响应，assert done均保持未发生；再测错误后紧接合法请求、B2→B1旧行清除、旧generation结果拒绝以及不能排空时Host恢复。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `candidate_raw_logits` | `ir_1469 / add_119` | `native/forward_0/ir_1469.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/14_result_status_and_verification.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

新增固定POD结果编码路径采用14§9同一384B字节合同。错误输出128…319全部清0，未用batch/lane/reserved清0；identity_valid时点、编译四tag、shape/数量与首错信息严格保持。成功只在所有任务及响应退休后提交，先数据/详情后头，函数返回排空由RTL证据核查。未有真实时钟计数则cycles_valid=0，不把task数当cycle。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 C批：完整结果提交与native边界（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/14_result_status_and_verification.md)及[task.md §12.4–12.5](../../../../hardware_agent/task.md)，由Astra xhigh核定。

每题masked candidate16＋act2完整成功后才写有效384B结果；所有未用lane/保留位清0，错误清logits_valid/输出数/128…319数据，编译四tag不回抄错误请求。数据/详情先写、头后写、全部响应退休后返回。Host wait/sync后同时验证身份/版本/shape/status/数量/flags，不能凭magic接受旧结果。

候选全图误差参照独立P2 oracle；native act第二题CLS已证实错stride，单列布局差异，不以其错误数据替换候选。本轮未做400例质量或板级性能时保留未执行；功能工程完整不等于生产部署达标。


## P2实际实现映射（2026-10-07）

- [full_result.cpp](../../../../hls/control/full_result.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复现行代码映射（04934，2026-10-07）

结果帧仍由 `full_result.cpp` 和控制器按原ABI提交；现行功能及综合范围由[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)绑定。 当前包身份为 `04934c15b3f83e842ec2e92ac2a81bf2`；真实完整顶层RTL已生成，HLS LUT估算超过U55C总量。13个 `m_axi` 数据端口外，HLS还生成 `s_axi_control` 与 `s_axi_control_r` 控制接口；完整RTL cosim、物理综合/P&R、平台链接及上板均未执行。详见本模块[results.md](results.md)与[中文总报告](../../../../results/synthesis_memory_fix_20261007/report.md)。
