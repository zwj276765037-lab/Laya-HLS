# HBM加载与缓存供给：详细设计

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

从q0/q1/scale/aux加载当前整张矩阵到片内；另装当前head的K/V、RoPE表与LN gamma，输出cache READY/owner状态。

每请求122 LOAD_W声明392,448,128B，B1/B2相同；480 LOAD_KV声明B1 31,457,280B、B2 62,914,560B。当前加载与计算串行。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-hbm_loader_and_cache)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/hbm_loader_and_cache`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：真实模型、权重、LN/RoPE/KV加载及完整owner/lease接入整图，当前CPU/CSim与实际事件计数通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

把HBM数据搬入计算所需的片上组织，并统一跟踪权重、输入tile、PS、KV及score缓存的所有权。数据缓存由各使用单元实现时，仍按本处总表核对物理端口和容量，避免重复计资源。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| HBM候选能力 | 512bit、150MHz；65%有效率仅分析情景 | 推断 | 05§1 |
| 权重复用 | 当前矩阵权重跨全部token tile复用 | 推断 | 05§2/§4 |
| 访存边界 | 4KiB边界拆分、对齐及返回空间信用 | 推断 | 05§5 |
| 缓存就绪 | 写可见/最后读取/在途排空分别判定 | 推断 | 05§5、15§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [04_model_package_and_memory_map.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:29)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:61)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:84)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:92) | 模型布局、HBM分区、地址/stride、权重复用及缓存所有权 |
| [05_hbm_loader_and_cache.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:25)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:46)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:54)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:62) | 缓存容量与读口、外存/片上带宽、加载和计算交接 |
| [09_q8_linear_and_restore.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:50) | 权重/scale供给、部分和端口和阵列读写速率 |
| [11_attention_and_fp_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:35)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:53) | QKV/score缓存所有权、端口与服务周期 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| 接受需求 | 控制器给出已校验区域和矩阵/head | 确认目标bank空闲及可容纳返回数据 | 无空间则停止发请求 |
| 读取与重排 | HBM响应按q/scale或head坐标进入RAM | 跨拍拼组、按算子读口分bank，保持身份 | 完整矩阵/tile/head就绪后发布可读 |
| 计算/预取/排出 | 当前计算读bank，下一对象可预取空bank | 与PS排出核对RAM读写口及master争用 | 最后读/写响应完成才释放/复用 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| AXI事务 | wrapper↔loader | 候选64bytes/拍；burst/ID细节待定 | 不跨4KiB；响应写入指定区域 | outstanding≤返回buffer可用信用 |
| 权重窗口 | W cache→Q8 Linear | 每issue8×32个S8及对应scales | q/scale属于同一矩阵/group/输出tile | 当前矩阵所有token tile复用完才换 |
| 激活/部分和 | 量化/Linear/向量↔cache | 16行A8组读；128路PS更新；8feature排出 | 分bank映射须与lane/列编号一致 | 旧PS未排出不允许覆盖 |
| KV/score | cache↔attention | 64个F32专用窗口；完整score/prob行 | 单head来自单shard；softmax原地修改 | KV全query与prob最后AV读完才释放 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- 加载不修改q、scale或浮点位模式；数据拼接/布局变化不能变更数值。
- U/G相差2624列，可能映射同一列bank；需要双读口或明确分拍，不能假定双缓存解决单bank端口。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| W0/W1 | 每bank最大5.445MiB | 加载→全部token tile读取→释放 | F1b Wi/down共驻减少预取空间 |
| 量化FP32/A8 | 输入双512KiB；A8/scale双136KiB | 输入重放前不覆盖；A8供全部输出tile | 16行并读需真实bank布局 |
| PS0/PS1 | 合计671744bytes | 最后group退休→bias/窄口排出→释放 | 128更新/issue与8feature输出不匹配靠整tile缓存吸收 |
| KV/score | 双KV2MiB、双score/prob256KiB | 跨query复用；softmax/AV阶段交接 | 写者与读者不得同bank冲突 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 预取隐藏时间比较前一任务剩余可重叠时间，不能拿待加载矩阵自身计算时间证明首次加载免费。
- 权重重读次数是必须测量的参数；若每tile重读，B2/S128可能放大16倍。
- 8读/4写outstanding只是旧候选；真实深度、优先级和错误退休依生成接口确认。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [hbm_loader_and_cache.h](../../../../hls/memory/hbm_loader_and_cache.h)、[hbm_loader_and_cache.cpp](../../../../hls/memory/hbm_loader_and_cache.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_hbm_loader_and_cache`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| HBM供给 | 顺序权重、随机embedding、QKV散写、并发读写 | 统计有效bytes、cycles、stall和每矩阵加载次数 |
| bank压力 | 预取＋dot＋旧PS排出及U/G双读 | 没有RAM端口冲突或错误bank覆盖 |
| 事务边界 | 4KiB拆分、最后响应延迟、返回拥塞 | 请求信用不透支，写可见屏障正确 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/hbm_loader_and_cache/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G4物理bank/读口、RAM绑定、FIFO/outstanding、访存效率和互连时序；G1平台。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

接受15§12的LoadTask和内部MemTransfer，管理只读权重/当前head KV及搬移信用；缓存的数值拥有者仍是相应算子。W0/1、A8、PS、KV、score的BufferRef/cache id与内部lane bank见15§11，不能把双缓存当成单bank双读口。

| 事务 | 源／目标 | 数量与退休 |
| --- | --- | --- |
| embedding行 | embedding中ID*1088→原行buffer | 精确1088bytes=17个64B拍（对齐时），32个34B组；拆4KiB边界 |
| Q8权重 | w_q0/1＋w_scale→WEIGHT | 按04逆重排绑定N/K；三路全到齐才发布，q与scale不能分开READY |
| 当前head KV | 一个QKV shard→KV bank | 两plane、B*S*64 F32；只读有效S，固定1024stride不意味着传全padding |
| 激活tile | 工作区→QUANT_INPUT/Q_TILE等 | rows×K或rows×64精确计数；cache tag继承任务身份 |
| 存储输出 | 流/数组→相应BO | byte_enable仅目标有效bytes；所有响应后登记coverage |

发请求前reserve完整返回空间；outstanding以各master已接受/已退休计数核算，容量与C_RD/C_WR配置一致。F0按当前任务所需装载，不启动另一个矩阵的投机预取。完成TaskDone必须归并所有segment，而不是q0返回即认为W全到。TB对真实GGUF块插入乱序允许范围内的返回延迟、末响应长停顿、4KiB分裂、错误epoch，检查未修改任何q/scale位且未提前发布。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `embedding_raw` | `ir_216 / embedding` | `native/forward_0/ir_216.bin` |
| `enc0_qkv` | `ir_237 / linear` | `native/forward_0/ir_237.bin` |
| `enc0_rope_k` | `ir_262 / add_3` | `native/forward_0/ir_262.bin` |

量化的直接backend参考另见manifest的`native_quantized_activation_scratch`：122次实际MUL_MAT输入scratch，34B/组（FP16 d＋32 S8），每项记录consumer node、shape、bytes和hash；例如`audited_outputs/native_q8_activation_linear.bin`对应Encoder0 QKV。硬件candidate dot/term/PS内部值尚未导出/实现，不能据此宣称这些值已逐位验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对LoadTask的stage/来源类别/固定长度，以及MemTransfer的范围、连续段号和不跨4KiB的分段描述。尚未把加载后的W绑定到WeightKey/K/N，或把A8与QKV缓存绑定到完整shape、请求/layer及plane/head/B/S覆盖；这些元数据关联须在真实计算链前补齐。分段描述通过不证明AXI事务、信用、返回顺序或排空已实现。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/05_hbm_loader_and_cache.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

tools/export_gguf.py导出全部固定模型payload，唯一可删除slide_bias经穷举证明。新增full_loader.cpp执行真实W/KV/gamma/RoPE加载和搬运，模型表绑定完整WeightKey/K/N/shape/bias/hash。W完整单bank一次装入供所有token tile复用；切换矩阵才释放；KV每head一次装入供该head全部query。byte搬运≤4KiB且不跨4KiB，outstanding1的实际生成AXI单独验证。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [full_loader.cpp](../../../../hls/memory/full_loader.cpp)：本模块当前P2实现责任源。
- [laya_full_owner.cpp](../../../../hls/common/laya_full_owner.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

13个数值RAM的类型、尺寸和总逻辑容量8,641,536B保持；由synthesis独立global承载，F32/A8 metadata仍在Runtime。loader仅将固定数组访问改为访问器，字节切片、加载顺序和发布屏障不变。owner私有查找返回0…31索引或32哨兵，所有索引先验证；QKV双槽选定及全部拒绝检查先于写入，第二首空槽排除第一槽。回收仍先拒绝busy/readers，再同步A8两个高水位，保留epoch、lease、请求和失败恢复语义。原default字段不清零替代；全零RAM拆分不等于metadata清零。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。`laya_full_memory.cpp`提供必填`uint16_t&`索引查找核心；旧可选指针API仍由包装器转发，失败时不写result/index，成功时先写descriptor再写index。13个全零synthesis数值数组与CPU私有cache的尺寸及metadata规则保持。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。

## T4 独立三口W reader候选（2026-10-10）

依据[吞吐合同§7.2–7.4](../../../../results/compute_throughput_optimization_20261010/source/design.md)，[地址/字节模型](../tb/three_port_reader_model.py)从真实v4 manifest逐122张Q8矩阵核tile奇偶shard、GS32列地址、half scale地址、每口4KiB/64beat边界和理想服务收费；只读源包，不改生产LOAD。[单口burst RTL](../rtl/t4_w_reader_port_v1.sv)在每次AR前预留最多64个512bit返回槽，保持一个未完成AR/R burst，每拍接受有界R返回；q口向sink交付64B/拍，scale口按原序分四次交付16B。三个独立实例由[三口入口](../rtl/t4_three_port_reader_v1.sv)原子启动并分别计实际提交字节、错误与全部完成。[真实短窗口生成器](../tb/make_three_port_reader_short.py)从v4 Wi/Down三BO截取两页窗口，[自检TB](../tb/t4_three_port_reader_short_tb.sv)以独立字节内容和AR规则核三口并发、反压及故障；运行结果见[results.md](results.md)。首轮接口只负责q0/q1/scale字节，AUX bias、W双槽身份/覆盖、lease/epoch发布和profile准入仍须接入独立owner；本入口的`load_done`不能直接变为W READY。真实完整搬运、RAM映射与时序不作结论。

## T4 STRICT 双W本地供数/lease候选（2026-10-11）

[双槽RTL](../rtl/t4_dual_w_cache_v1.sv)复用上述三口reader，增加独立[128bit AUX reader](../rtl/t4_aux_bias_reader_v1.sv)、两槽奇偶tile×8列bank、完整模型身份/数值身份/任务上下文与单读lease。每槽q为2×8×10496×256bit、scale为2×8×10496×16bit、bias为2×8×328×32bit，逻辑容量5,730,816B，两槽11,461,632B；FIFO、metadata和物理打包另计。q0/q1各64B、scale16B、AUX header/bias16B（末8B窄拍）在各自提交口进入bank；实际AXI 4KiB/64beat分段，全部目标覆盖、R/FIFO退休、完整padded scale finite且nonnegative与有效bias finite检查成功后才READY；有限负bias合法。只接受STRICT profile；错误目标置INVALID，另一槽的IN_USE/lease不撤销。每槽完整3328bit模型身份、672bit数值身份、96bit task上下文与K/N/key/epoch在lease/read/release处逐位比对；同步RAM读以ready/valid返回单TN8或偶起相邻双TN8，尾列mask和无效bias归零。释放须等最后实际ret握手，slot epoch仅在被接受的合法LOAD时消费；整域reset清有效身份。

[冻结r2 fixture生成器](../tb/make_dual_w_fixture_v1.py)从原包实际Wi/Down/ACT/scorer的q0/q1/scale/bias和AUX header提取完整字节，不修改payload；[自检TB](../tb/t4_dual_w_cache_tb_v1.sv)按独立地址公式和源hex逐256bit q/16bit scale/32bit bias被动核全部bank读回，也核AXI AR/R、4KiB、覆盖、反压、epoch/身份拒绝、预取失败隔离和在途reset。[受控编译pilot入口](../tb/run_dual_w_cache_v1.sh)及[逐SHA snapshot复用入口](../tb/run_dual_w_cache_replay_v1.sh)对应结果见[results.md](results.md)。该模块仅供数与lease：没有连接生产MAC、量化器或完整Host会话，未作综合、物理RAM映射、资源fit、Fmax或150MHz结论。前述短三口reader段的“未接AUX/双W”是历史首轮范围，当前以本节和结果为准。

## 2026-10-11 同容量32独立bank修复（working source，待受影响验证）

按联合设计§7.2.1，`t4_dual_w_cache_v1.sv`的q/s/b payload从顶层多维对象拆为32个`slot×parity×lane`真实`t4_w_cache_bank_v1`实例；每实例q10496×256、scale10496×16、bias328×32，总91693056bit=11461632B不变。每bank独立q/s/b写口及同步读保持，无payload reset、不加外部read stage；父层完整offset/epoch/范围合法后才缩窄u14/u9地址，bias零选择按同次返回锁存。原reader/lease/epoch/覆盖/发布/reset接口保留。原dual-W full05与ACT06只在冻结身份保留PASS，新身份功能/OOC尚未运行；单bank全址TB及真实OOC脚本已准备，后续一份bank DCP回填32cell→全容量cache DCP→ACT封装按累计3600s/24GiB/120s原锁原帽。
