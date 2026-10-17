# 向量运算、FFN与残差：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/vector_and_ffn`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：真实GEGLU、ReLU、残差、type和bias/GELU接入28+2层与尾链，当前完整CPU/CSim逐位通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

负责Wi的U/G配对、GELU/gate、Decision ReLU、type add和residual，以及heads的bias/GELU。矩阵投影始终复用Q8 Linear，不在此重复实例化Wi/down阵列。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| Encoder FFN | Wi1024→5248，拆U/G各2624；GELU(U)×G→down2624→1024 | 工程事实 | 12§1 |
| Decision FFN | FC1宽4096→ReLU→FC2 | 工程事实 | 12§5 |
| 候选并行 | gate4lane，ReLU/residual/type8lane | 推断 | 12§2/§4/§5 |
| 共享与残差 | Wi/down串行复用；旧hidden保留至最后一次残差读取 | 推断 | 12§3/§4 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [08_activation_quantizer.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:46) | gate/ReLU到量化的格式、捕获与4/8-lane速率 |
| [09_q8_linear_and_restore.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:50) | Wi/down输出、部分和与向量消费者吞吐 |
| [12_vector_and_ffn.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:31)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:39)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:51)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:57)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md:63) | Wi/gate/down调度、残差双输入与共享向量单元 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:92)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | FFN联合流水、U/G配对、共享资源和背压 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| PAIR/GELU | Wi U/G两半 | 相同token/intermediate位置配对；GELU只作用U | 同拍4U＋4G需要真实双读口 |
| GATE/QUANT | 4lane gate | F0写HBM；F1a可省Wi往返，gate仍存；送量化 | 量化第一遍最多接受4lane gate |
| DOWN/RESIDUAL | Q8 down结果与旧hidden | FP32残差相加写新hidden | 旧值最后读完、结果写可见后换角色 |
| OTHER_VECTOR | Decision/type/heads模式 | ReLU、type广播、两次bias分开及GELU | 前一模式在途数据排空 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| U/G | Linear PS/cache→vector | 同token的4U＋4G F32/拍 | 两半相隔2624feature，位置配对 | 同bank双读需求需证明 |
| gate/ReLU | vector→quant或FF缓存 | gate最多4F32/拍；ReLU最多8 | 有效lane明确，不跨行 | 不可停止的非线性在途输出需预留空间 |
| residual | PS/缓存＋旧hidden→vector→新hidden | 每拍8新＋8旧→8输出F32 | 读/写分配符合memory_map | 旧hidden不得提前覆盖 |
| type/head模式 | embedding/heads→vector | type1024广播；bias/GELU向量 | 按题b或marker身份执行 | 不同模式分时，不增加隐含并行 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- GELU沿用tanh近似0.5*x*(1+tanh(c*x*(1+0.044715*x*x)))；常量FP32 c=0.7978845608028654，求值顺序按参考。
- 不改为erf GELU或SwiGLU；scorer baked bias与原bias不合并。
- residual/type add保留FP32逐步舍入及原图顺序。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| Wi/U/G | 16行Wi335872bytes | 配对读完才释放对应PS/存储 | U/G相同列余数可能同bank |
| gate | 16×2624×4=167936bytes/tile | 量化重放/后续down前保持 | F1b片上保留需Wi/down权重共驻 |
| 旧hidden | 每token1024F32 | residual最后读取后可回收 | 若另做快照copy须计流量 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- F0顺序Wi→HBM→gate→HBM→down；F1a省Wi写读；F1b按tile切换投影且省gate往返，但两权重共驻约5.445+2.723MiB。
- gate4lane直连量化不能按双8lane算；首遍与gate输出重叠只计一次。
- 一个512bit master不能凭峰值提供残差每拍全部读写，新结果可来自PS并另分旧hidden读/目标写。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [vector_and_ffn.h](../../../../hls/operators/vector_and_ffn.h)、[vector_and_ffn.cpp](../../../../hls/operators/vector_and_ffn.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_vector_and_ffn`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 配对数值 | U/G错行检测、最后索引2623、GELU极值 | 逐级比Wi、GELU、gate、quant、down和residual |
| 速率 | 4→8转换、随机下游停顿 | 无丢lane，FIFO能接住非线性在途输出 |
| 存活/模式 | 旧hidden、Wi→Decision空间复用、type b切换 | 不早覆盖、不串题、不同时占同共享单元 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/vector_and_ffn/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3 tanh近似与函数顺序；G4U/G端口、4/8转接、尾延迟与F1权重驻留；G6质量线。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

VectorTask含src0/src1/dst BufferRef、length:u16、三个HEAD_WORK region:u8及bias_id:u16，另有TaskContext；op决定唯一的计算和合法宽度。未用src1=NONE、bias_id=65535。长度固定为GEGLU2624、ReLU4096、residual/type1024、scorer1024、act256或candidate16。

| op | 输入／输出 | 显式配对与所有权 |
| --- | --- | --- |
| GEGLU60 | WI U[0:2624]、G[2624:5248]→GATE | WiPairBeat的valid_count表示pair数；4U+4G→4输出，col推进4 |
| RELU61 | DEC_FF→DEC_FF | 独占in-place old/new epoch，整矩阵完成后才供quant |
| ADD_RESIDUAL62 | TMP＋旧H→另一bank新H | 两src先校验同b/s/d，最后读前不覆盖旧H |
| ADD_TYPE63 | final norm H＋TYPE_ROWS[qtype]→新H | type1024按题广播，每token都加；qtype必须与请求一致 |
| BIAS_GELU64/65 | scorer或act FP输入＋绑定post bias | 不预先合并scorer baked bias；按原图顺序再GELU |
| APPLY_CAND_MASK66 | CAND_RAW＋marker_mask→CAND_MASKED | stage5的BATCH单行（row0=0、rows=1），length=16，输出16个F32；`raw+(1-mask)*(-10000)`，所有16列参与 |

F0 GEGLU从完整WI数组取U/G；因同PS lane bank冲突，若无已证明的双读口就分拍读入配对寄存器，再发4对，不用理想4lane掩盖存储限制。结果写GATE完整矩阵后再quant/down；Wi/down共用整数引擎不并发。所有F32Beat稳定、配对标签匹配才消耗；VectorTask的目的epoch统一标在两输入适配流上，源epoch由各自ref验证。

真实检查点是同一abi_replay的Wi两VIEW、gate、down、residual；VIEW可能noncontiguous，必须依据GGML stride。TB把U/G最后一对、输出4lane到存储8lane聚合、残差最后一次旧H读分别停顿；聚合器只合并同一行连续4+4，不能跨行或掩掉短拍。候选GELU函数版本仍需独立回放/误差测试，不把原生tanh输出称为已冻结硬件IP。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_up` | `ir_270 / getitem_3` | `native/forward_0/ir_270.bin` |
| `enc0_gate` | `ir_271 / getitem_4` | `native/forward_0/ir_271.bin` |
| `enc0_gelu_up` | `ir_272 / gelu` | `native/forward_0/ir_272.bin` |
| `enc0_gated_product` | `ir_273 / mul_7` | `native/forward_0/ir_273.bin` |
| `enc0_attention_residual` | `ir_267 / add_4` | `native/forward_0/ir_267.bin` |
| `scorer_gelu` | `ir_1462 / gelu_28` | `native/forward_0/ir_1462.bin` |
| `act_gelu` | `ir_1615 / gelu_29` | `native/forward_0/ir_1615.bin` |

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 A批：GEGLU/ReLU/bias/residual真实计算（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§1–6](../../../design_source/12_vector_and_ffn.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/vector_full_compute.cpp`，提供gelu_scalar、geglu_row、relu_row、add_row、bias_gelu_row。GELU严格按task§12.2中a*x再*x及c*x再乘的F32序列；scorer两次bias保持两次操作。GEGLU完整5248输入分为2624U/G并产生2624gate，Decision完整4096ReLU，add完整1024。CPU libm tanhf和HLS近似分别留证；边界覆盖有限溢出、NaN/Inf、-0、极小数及末元素。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/12_vector_and_ffn.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

完整VectorTask读写真实workspace，GEGLU完整WI两半→GATE、ReLU4096原地lease、TMP+旧H→另一H、final LN后按batch type add。scorer/act post bias精确绑定，不能合并原baked bias。旧hidden所有残差row最后读取并写新H完成后才交换；WI与DEC_FF共物理锁，不能同时有效。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[vector_full_compute.cpp](../../../../hls/operators/vector_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`geglu_row / relu_row / add_row / bias_gelu_row`。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_vector.cpp](../../../../hls/operators/full_tasks_vector.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
