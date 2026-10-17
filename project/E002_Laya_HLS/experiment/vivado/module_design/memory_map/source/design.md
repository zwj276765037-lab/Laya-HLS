# 地址生成、布局与边界：详细设计

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入BO/offset/shape/region，输出合法地址span或错误；外部F32数据经4个byte组装/拆分。

地址/边界/搬运服务，无独立矩阵算力。真实byte/beat与burst效率待测，不能把32-bit口当每拍4个有效源字节。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-memory_map)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/memory_map`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：13 BO真实寻址、界限与跨shape任务通过；AXI基址0误判已修复并由生成read helper RTL验证。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

统一输入紧凑帧、HBM固定stride、QKV分片和权重布局的地址含义。导出器是CPU软件，当前目录只定义硬件地址/范围检查职责。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| IO布局 | io32KiB；请求前16KiB，结果4KiB从16384开始；little-endian/64B起点对齐 | 推断 | 01§3、14§1 |
| 模型身份 | Typed GGUF SHA-256以04§2为准，权重位模式保持 | 工程事实 | 04§2 |
| marker转换 | 先拆b=idx//S、s=idx%S，再用S_MAX1024 | 推断 | 04§4；输入语义见01 |
| 范围检查 | token<50368、B1/2、S合法桶、qtype0/1/2、mask二值 | 推断 | 01/04、14错误要求 |

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
| 请求解析 | header和五个tensor目录 | 先校验offset/size/stride/shape，后读payload | 不合法的目录不能转成HBM访问 |
| 逻辑坐标转换 | b/s/d、head/plane、输出tile | 使用统一byte单位并保持固定工作区stride | 提供已校验地址和有效tail |
| 区域复用 | 控制器给出生命周期 | Encoder Wi与Decision FF共区，hidden ping/pong | 前一所有者最后读取完才允许新视图 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| Host帧 | IO→检查器 | I32[B,S]、U8[B,S]、I32[B,16]、U8[B,16]、I32[B] | payload紧凑S步长，五张量分别64B对齐 | 偏移加长度的溢出也需检查 |
| hidden地址 | gather/residual/LN→加载器 | byte=((b*1024+s)*1024+d)*4 | marker例B2/S128第二题位置7：idx135→物理行1031 | 检查属于本题；无效marker指本题CLS |
| QKV地址 | RoPE/attention→加载器 | shard=head%2；local_head=head//2 | byte=((((plane*2+b)*8+local_head)*1024+s)*64+d)*4 | plane0/1/2=Q/K/V，范围先于乘加 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 地址运算按byte或element明确区分；整数地址宽度在platform确认后冻结，不预设实际AXI位宽。
- 物理padding不参与数值/候选输出；act N2物理pad至8lane，其余lane无效。
- q与scale重排只改位置，不改位模式；scorer两次bias保持两个阶段。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| hidden类张量 | state0/1 | S_MAX固定stride；四份最大8MiB | 具体region offset见04§7，模型base待真实导出器生成 |
| QKV | qkv0/1 | 每片[3,2,8,1024,64]F32＝12MiB | 同一个head只属于一片 |
| Wi/gate/Decision FF | ff0/ff1 | Wi41MiB、gate20.5MiB、Decision FF32MiB | Decision在Encoder结束后复用Wi，不重复分配 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 02的参数号/bank、04的shape/stride、Host分配和算子地址必须由同一布局定义连接。
- 量化权重每8输出列为一个tile，偶数输出tile放q0、奇数放q1；scale按完整输出tile序另存。
- IO已定义容量与示例offset，不代表完整header结构已生成。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [laya_memory_map.h](../../../../include/laya_memory_map.h)、[laya_memory_map.cpp](../../../../hls/common/laya_memory_map.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_memory_map`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 坐标边界 | B2、S<1024、head15、plane2、最后合法s/d | 与独立地址参考逐项比较 |
| 非法范围 | 错误offset/size/marker所属batch/token尾界 | 不发越界访问，返回本请求错误 |
| 区域复用 | Wi→Decision视图切换和hidden角色交换 | 没有未完成读者，旧数据无效范围不泄漏 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/memory_map/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G2所有region实际offset、header字段、地址位宽与布局头；G1实际HBM容量/拓扑。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

地址函数采用04§7的固定buffer id/base和15§11的BufferRef；内部offset是u32字节数，范围和乘加使用u64临时量。Host请求offset先按01§6严格规范布局验证，不能把合法地址范围内的任意offset当成功。模型矩阵base仍待真实导出器输出；工作区base已在设计层确定。

| 地址函数 | 参数及结果 | 必须检查 |
| --- | --- | --- |
| token/hidden | b:u8、s:u16、d:u16→BO+base+4*((b*1024+s)*1024+d) | b<B、s<S、d<1024、ref epoch合法 |
| marker gather | idx:I32与b/S→s=idx-b*S | 有效idx必须本题，未检查不能除模后越界；无效idx=b*S |
| QKV | plane:u8、b、head:u8、s、d→shard/head地址 | plane<3/head<16/d<64；两shard独立ref及同一矩阵身份 |
| FF | WI stride5248、GATE2624、DEC_FF4096 | WI/DEC_FF共享物理锁，base相同不代表能并存 |
| HEAD_WORK | region:u8 0…7＋逻辑坐标 | 固定子区映射，ACT_INPUT1028、ACT_LOGITS2，绝不读padding |
| Q8 W | n/k→t/lane/g/j和q_shard | q/scale同matrix/g，尾N2只2真实列 |

每个搬移段用MemTransfer携带bo_index/offset/byte_count/cache_offset，不允许Host动态构造该内部对象。存储内容发布依赖写响应，不依赖地址算出即有效。真实S94原生记录与S128 ABI回放有不同marker展平坐标，测试必须使用各自manifest；S128第二题有效marker为147/163/174，固定工作区分别映射s19/35/46，不沿用113/129/140作为物理行。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_qkv` | `ir_237 / linear` | `native/forward_0/ir_237.bin` |
| `enc0_up` | `ir_270 / getitem_3` | `native/forward_0/ir_270.bin` |
| `enc0_gate` | `ir_271 / getitem_4` | `native/forward_0/ir_271.bin` |
| `marker_gather` | `ir_1458 / embedding_2` | `native/forward_0/ir_1458.bin` |
| `act_input1028` | `ir_1613 / cat_57` | `native/forward_0/ir_1613.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/04_model_package_and_memory_map.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

04§7固定BO/base/1024stride/QKV两shard/HEAD_WORK八region保持；u64检查所有加法再形成byte地址。真实导出按8输出tile奇偶分q0/q1，scale保存完整tile顺序；marker扁平索引先检查同batch再换物理row。单byte和f32读写必须实际访问并保持旁邻sentinel。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [export_gguf.py](../../../../tools/export_gguf.py)：本模块当前P2实现责任源。
- [laya_full_memory.cpp](../../../../hls/common/laya_full_memory.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。本模块关联的`laya_full_memory.cpp`保留BO权限、容量、u64溢出与AXI基址0合法性；新增必填引用索引入口用于已证明非空的生产调用，原可选指针入口和失败不写输出的语义保留。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
