# 向量运算、FFN与残差：详细设计

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

F32 GEGLU[5248]→[2624]、ReLU[4096]→[4096]、两份残差[1024]→[1024]；bias-GELU长度1024或256。

B1/S128有9,404,416个GEGLU输出、1,048,576个ReLU元素和7,864,320个residual加法；矩阵工作量归Q8，避免重复计。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-vector_and_ffn)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

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

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

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


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。`full_tasks_vector.cpp`的load_bias必填索引调用改为引用入口，使用原局部索引变量；向量/FFN算术叶子、shape和任务错误规则不变。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。

## T5 单实例原tanh服务探针映射（2026-10-10）

联合合同为[算力优化§8.4.1–8.4.5](../../../../results/compute_throughput_optimization_20261010/source/design.md)。[tanh服务源码闭包](../rtl/tanh_service_01/source_manifest.json)明确选用历史生成的原`generic_tanh_float_s`叶子及其全部18份Verilog、3份ROM、7份FP IP仿真VHDL/XCI/Tcl；首次编译发现带attribute的sparsemux实例遗漏后修正闭包脚本，历史叶子本身未改。该叶子并非当前v4新kernel身份。[单实例wrapper](../rtl/tanh_service_wrapper.sv)把叶子包装为一份带32bit本地tag的ready/valid服务，输入接受前预约单份不可反压返回，只有活动`ap_ready`退休；原叶子空闲`ap_done=1`不计完成。[TB](../tb/tanh_service_tb.sv)按序对真实`z`与独立`libm.tanhf`做四态逐位比较，首个差异即终止；全数值通过后才会输出三条分支服务统计。本次在ordinal23首错停止，原叶子同数值流水化暂停，实际证据见[results.md](results.md)。

[只读Wi捕获](../rtl/vector_service_prepare_01/generated/source_manifest.json)在当前v4/request3 CPU控制器的Encoder0 Wi完成、GEGLU读取之前观察真实`WI` row0 5248 F32；不改生产源码，原47检查点继续运行。[独立参考生成器](../tb/vector_gelu_reference.py)已使用实际捕获和日志，按原F32 `a*x→u*x→1+v`及`c*x→t*w→libm.tanhf→1+h→0.5*x→gelu→gate`逐步冻结2624项位型。T2已有`ln_ffn_source`是Wi输入、`geglu_source`是Down输入，不能代用。当前实测首错为原tanh数值FAIL；不通过改gold、放宽逐位或替换tanh消除。

## 第1轮：单实例glibc逐步F32正确基线（2026-10-11）

依据mission最新顶部长任务授权，由GPT-6.1 Sol/xhigh在本轮连续定义实现、验证与受影响模块OOC；Astra仅在取得实际综合结果后集中评判。历史原leaf数值FAIL保留。本候选独立于生产完整top，未替换冻结gold、未接入GEGLU完整producer。

候选源为[tanh_libm_bits.cpp](tanh_libm_bits.cpp)，适配冻结glibc2.39 `s_tanhf.c/s_expm1f.c`普通有限图。来源原文及hash保存在本轮attempt `tanh_libm_round1_01/vendor`；独立gold仍为原manifest绑定的`libm.so.6`（SHA256 `1b87a1a50b496cfead2b0ad134c2ff536705c82608db240c7e8aa48d6c0e4217`）。声明支持全部有限binary32输入，舍入为RNE、保留subnormal和有符号零；不包含主机浮点异常旗标/errno语义。非有限输入作为本地numerical错误接受并按同一tag返回status1、result0；有限成功status0。

分支位界为`abs(x)==0`返回原零；`abs(x)<0x24000000`执行独立`x*(1+x)`；`0x24000000<=abs(x)<0x3f800000`执行`expm1f(-2*abs(x))`然后`-t/(t+2)`；`0x3f800000<=abs(x)<0x41b00000`执行`expm1f(2*abs(x))`然后`1-2/(t+2)`；其余有限值执行`1-tiny`再恢复输入符号。expm1内部可达域为`-2<x<44`，按`0x3eb17218`和`0x3f851592`分支做ln2范围缩减，k=0/±1/小于23/23至56/大于56分别按原顺序重建；`abs(x)<0x33000000`返回x。未独立暴露通用expm1，域外分支不能调用。被原libm仅用于异常旗标的force-eval表达式不产生数值输出，硬件不模拟该旗标。

常量位型固定：1=`3f800000`、2=`40000000`、0.5=`3f000000`、tiny=`0da24260`、ln2_hi=`3f317180`、ln2_lo=`3717f7d1`、invln2=`3fb8aa3b`、Q1=`bd088889`、Q2=`3ad00d01`、Q3=`b8a670cd`、Q4=`36867e54`、Q5=`b457edbb`、3=`40400000`、6=`40c00000`。每add/sub/mul/div使用独立位级RNE helper，无FMA、重结合、近似倒数或FTZ。24位有效数乘积用精确48位整数；加法保留guard/round/sticky；除法生成27位商加精确余数sticky并独立RNE。范围缩减的F32转小整数为朝零，整数转F32独立RNE；指数重建为原位操作。

一个`ap_ctrl_hs` leaf与一个本地ready/valid wrapper；输入32bit F32位型＋32bit tag，输出相同tag、32bit result和32bit status。声明最多一项未消费债务，在accept时预约返回slot；leaf不可反压返回先进入该slot，下游停顿时payload/tag/status保持，slot消费后才能接受下一项。同步高有效reset取消本地在途及待消费返回并复位leaf；reset后旧tag不得出现。此leaf没有AXI，不将本地债务称HBM/写响应验证。HLS约束对add/mul/div各limit1，实际共享以生成实例/综合层级为准。

性能目标为先建立正确且资源可核的单实例基线；不要求II1，不复制四份。函数HLS24GiB/3600s，CPU16GiB/1800s，RTL8GiB/3600s/40Mcycles、pilot120s，模块Vivado OOC24GiB/3600s；CPU0–3/nice19/idle I/O、单重工具锁和MemAvailable>192GiB。完整2624冻结z/gold、分支邻点/有限域极值、非有限错误、连续/反压、在途及待返回reset均为本轮验收；CPU额外随机只作为有限样本证据，不声称穷举全F32域。完整GEGLU/Encoder/整网、P&R、上板保持未测。

本轮实现/有限验证与模块OOC已结束，实际数值、single-instance层级、服务和资源见[results.md第1轮](results.md#第1轮单实例glibc位级基线实测2026-10-11sol-61xhigh)。实综leaf＋wrapper为10054LUT/7090FF/2DSP，BRAM/URAM0；普通真实tanh accept→首次valid462..689cycles，属于正确但服务慢的基线。完整生产top未切换到该leaf，旧生成leaf FAIL仍保留。Astra在这份真实综合结果之后评判，下一轮待用户审核；本轮语义停滞停止规则存在明确COMPLIANCE_GAP，详见results。

### 第1轮后置审核发现与同轮修复

Astra在实际`round1_01`综合之后发现RNE精确抵消零符号错误：`fp_add_bits(bf800000,3f800000)`返回`80000000`，独立原生F32/RNE应为`00000000`。原2624/补例和随机通过保留其有限范围，不能证明此边界正确。此问题按同轮普通实现错误修复，不启动性能候选2，不更改gold。

现源码在非零操作数异号、对齐有效数完全相等时显式返回+0；输入零的原分支继续保持`-0+-0=-0`，其余零组合为+0。新增52例独立原生binary32/RNE定向，包括±0的全部四组合、12种有限等幅抵消的两顺序及相邻非零和，gold由volatile原生F32运算生成并核`FE_TONEAREST`。同次HLS生成的真实`fp_add_bits`子模块由本模块TB直接运行这些例，不用tanh最终输出代替新分支覆盖。真实3270×2及恢复范围完整回归。

新机器attempt为`round1_02`，原`round1_01`源码/RTL/DCP/receipt不改。新guard按工具真实阶段/算术进度行自动执行120s无语义进展停止，并每60s记录进度/RSS；不会因纯时间、CPU/RSS或人为heartbeat延后。1s短自检验证静默owned子进程确实由semantic_stall终止。新OOC为减小不透明综合优化成本使用`RuntimeOptimized/resource_sharing off`，与01配置不同；最终资源差异不能只归因于零符号修复，也不是公平性能优化A/B。单实例数和实际资源以新综合层级为准。

修正身份实际CPU、52例真实helper RTL及3270×2服务回归通过；新OOC已完成10410LUT/7132FF/2DSP、BRAM/URAM0、blackboxes0，内部setup WNS+2.486ns，仍为未布局布线/无外部delay的估计。普通真实tanh first-valid517..795cycles，构成功能基线并保留服务慢的局限。当前交付以round1_02最终receipt/manifest为准，原01只作历史已测范围及后置发现来源；待同Astra复核和用户本轮审核，不自动下一轮。


## 第2轮有界add优化与生产GEGLU接入（2026-10-11）

按实际第1轮综合后的建议，唯一改动是add专用5级leading-zero计数/移位、32位GRS对齐与RNE打包；mul/div原通用unpack/pack及glibc运算顺序保持一致。单add/mul/div实例分配、wrapper接口、gold与模块OOC配置均保持第1轮02的版本。本轮停止继续局部add搜索，后续推进完整GEGLU producer和经授权的空间流水候选。

生产`hls/operators/vector_full_compute.cpp`实际调用本模块`gelu_libm_bits.cpp`和`tanh_libm_bits.cpp`；编译桥为`hls/operators/vector_libm_bits.cpp`。GELU常量为binary32 `3d372713/3f4c422a`，顺序为a*x、u*x、1+v、c*x、t*w、精确tanh、1+h、0.5*x、s*r，GEGLU最后乘G。residual和bias加法复用同一精确add。生产任务仍经`full_tasks_vector.cpp`读取完整Wi5248、计算全部gate2624，再写回和处理owner；当前模块RTL是完整一行的checkpoint replay，不能据此宣称连续整图RTL完成。

`geglu_row_wrapper.sv`按有序ready/valid装载完整5248F32，冻结一行tag，逐个配对U/G。每个结果在一份本地return slot稳定等待消费，十步trace来自实际HLS存储写口，不由TB替代计算。同步高reset撤销partial load、inflight leaf和pending return；输入index/tag错误status2，nonfinite算术status1终止该行。与完整运行时的owner/cache/AXI接口分别留证。


## 单流同图空间流水候选（合同§8.4.7）

独立候选`tanh_libm_stream_bits.cpp`把原图以24个add/sub、17个mul、2个精确div位置空间展开，包含原有限分支、范围缩减、逐步Horner、c修正和k重建。通过谓词操作数/结果选择共享互斥重建位置，原整数26步division只在候选中完全展开，RNE/GRS/余数sticky规则保留。`tanh_libm_stream_wrapper.sv`在接受输入时预约512个总slot中的一个，涵盖在途和已返回未消费，tag/status实际预留、result实际算术返回依序填入；同步reset取消所有有效债务。未测持续II前不宣称II1。候选不使用公共vector32M/16A或softmax/quant/LN divider免费容量；图节点、FIFO及寄存均纳入实际OOC账。


## 三类精确canonical新父图与完整GEGLU行适配器（合同§8.4.9/§7.3.3/§7.3.4，2026-10-11）

当前联合权威合同见[设计§8.4.9](../../../../results/compute_throughput_optimization_20261010/source/design.md#849-逐节点成本实测后的三类canonical流水子核与新父图)及§7.3.3/§7.3.4。用户本阶段授权按hardware-agent连续实现、编译、仿真、修复和受影响OOC；历史逐次审核/下一轮等待文字只保留历史记录，不构成此阶段普通修复门。Sol6.1/xhigh维护本模块实现与实际证据，Astra维护联合合同/集中验收，production owner维护真实GATE写入/量化/双A/Down桥。

旧stream02原3270逐位服务证据保留；42个专用算术子模块经规范化源和递归依赖比较仍各不相同，不能用三类DCP代签旧图。bottom-up旧路线因实际pilot成本中止，已花220.97339908406138s；剩余3379.0266009159386s属于同一累计OOC3600s帽。当前重新编写[tanh_libm_canonical.sv](../rtl/tanh_libm_canonical.sv)，显式实例化原stream02完整输入精确add0×23、mul14×17、div0×2；原add0 DCP原样复用，新mul/div各综合一次后按42个实际cell回填新父图。复制节点是真实硬件资源，不作为共享免费容量。父图的不同数据/谓词按静态边沿寄存对齐，各helper保持ap_ce=1，空泡操作数为0+0、0×1、0/1。

[图生成器](../tb/tanh_libm_canonical_generate.py)将值在C可读和E_C消费区分，launch→consumer分别add6/mul14/div12cycle；Dexp发起E233/消费E245，DtanhE337/E349，结果选择C356后显式填充至commitE384、最早消费E385。wrapper总512credit涵盖在途与已返回未消费，实际FIFO存data/tag/status，reset撤销有效债务。新父图需要新的节点operand/result、完整3270双profile、512credit、reset实际RTL；旧L375回归不覆盖新控制。[独立预检](../tb/tanh_libm_canonical_cpu.cpp)只把冻结原图三类模板运算替换为volatile原生binary32/FE_TONEAREST，每个节点独立记录A/B/result，再检查原最终gold；不以新RTL结果制作gold。

[GEGLU核心](../rtl/geglu_canonical_core.sv)围绕一份新tanh core执行原7次独立乘法与2次加法，保留原十步骤顺序、G先于U有限检查和失败步骤。静态计划为u/v/w/t/z消费C16/31/38/53/68，tanh在E69接受并于C453消费，r/s/y/gate于C460/475/490/505，最后data/status/failed在E506提交。这是计划，实际服务和资源以新RTL/OOC为准；连续在途不超过512。

[完整行适配器](../rtl/geglu_canonical_row_adapter.sv)冻结NumericIdentity672、三份TaskContext96、source/A/W/GATE dst refs64及region/batch/K/row0/rows/A slot/epoch。接收完整WI5248后，还需源row_done且真实读债务为0才启动2624列实际算术；payload RAM不在reset全清，覆盖/债务/epoch状态独立撤销。U/G同步读取，所有返回有序写入本地gate RAM和2624bitcoverage；只有整行算术正确、coverage全且债务0才发布row_success及2624标量v流。晚错误停止新准入并排空已接受工作，G失败bad_element=2624+col，其余算术错误为col。身份/ref/row/index错误先验证后索引RAM，等待完整源退休。

适配器的cmd_dst_ref是GATE id7；其local done不是GATE owner READY。真实writer在生产模块消费全部v并执行物理HBM写、B响应和task owner publication；返回带task_id/dst_epoch/row/status/bad_element/debt_zero的row_write_done之后适配器才进入下一行/本地完成。下游Down目标由真实LinearTask另行持有。模块row TB中的write ack明确只是诊断，不能代称生产物理写/ledger/quant/full dual A/Down。后者由production owner实施联合回归，每完整row一次quant命令、每完整G tile一次Q8命令；Group32同步函数不继承独立流水服务费用。

当前验证入口分别为`attempts/tanh_libm_canonical_01`与`attempts/geglu_canonical_row_01`。CPU/static/RTL/OOC仍沿原服务器规则：单重工具flock、CPU0–3/nice19/idle I/O、MemAvailable>192GiB、0.2sowned RSS，CPU16GiB/1800s、static24GiB/1800s、RTL8GiB/3600s/40Mcycle、pilot120s、OOC24GiB且上述累计3600s；每重工具自动120s无真实语义进展停止。未做整网OOC/P&R/上板，不新增服务器或节点credit帽。


完整新GEGLU row adapter的受影响模块OOC按root既有每模块3600s帽单独累计：只读复用已成功同身份的三helperDCP/EDIF，父层真实51个FP边界（25A/24M/2D）包括额外7M/2A，实际U/G/gate31488B及驻留owner/coverage/control全部纳入。先完成canonical tanh原累计闭合，不把其失败/未完步骤移至G名下加帽。GEGLU独立父层采用相同OOC structural link/out_of_context/无IO pad检查，范围不含production物理GATE writer/quant/Down。两模块仍共用唯一重工具锁。


### canonical成功核心子树用于GEGLU父层的同身份结构复用

从已完成且42个FP边界逐一核对的assembled DCP导出`core`子树，重新打开导出DCP后核对100个接口端口、42个实际FP模块和blackboxes0；实际通过，不重新综合或改变算术/计划。GEGLU父层使用该exact subtree的结构EDIF及同身份三类helper，父层仍独立综合额外7M/2A、完整31488B行payload、coverage和resident控制。canonical导出费用63.608440s计入原累计3600s预算，累计777.888915s，余2822.111085s。

可选128项综合网表检查仅曾等待唯一工具锁，按root对物理生产链路和PS/LN合同的优先级要求在重工具启动之前取消owned waiter；没有新guard launch或工具子进程，实际工具费用0。状态明确NOT_RUN，不能据已保存funcsim文件声称门级回归通过。原成功OOC收据及原失败证据保持不可变。


### GEGLU完整51FP父层实际映射终态

新GEGLU实际OOC已闭合51个FP边界（25A/24M/2D）、blackboxes0、IO pads0，并保存完整DCP/funcsim/resource/timing/check_timing。实现源码与已通过六整行/441角例的冻结功能身份逐字节相同。完整父层实际176828LUT/299253FF/48DSP，RAMB36/18/URAM和distributed RAM均0；31488B逻辑payload当前实际展开为寄存器及读写选择逻辑，不能从逻辑bytes推BRAM容量。层级row metadata/storage/control为81074LUT/256419FF，arithmetic为95754LUT/42834FF/48DSP。

本阶段只登记现行合同的真实资源和标量边界：每行先接收5248个Wi、完成2624列算术后再发送2624个gate；后者等待真实writer结束债务/owner publication。normal实测first_issue至last_output相差5753cycle，尚不含Wi装载或真实physical B/发布。任何同步bank/显式read-return/512bit捕获及输出吞吐合同修订由Astra集中定义，本owner没有在这次OOC后改架构/源/额度或启动新优化。


### §8.4.10 三个同步行bank实际实现与接口交接

原G51 RAM0冻结源码/receipt/DCP保留。当前`geglu_row_bank_v1.sv`将U/G/gate各2624×32置于独立无reset的同步1R1W过程，写仅wr_en、读仅rd_en、停读q保持；payload和q不复位。adapter所有地址先验证完整Wi identity/ref/index或已预约core顺序返回/唯一coverage。PREP边沿同步预读U/G[0]，后一拍RUN首发射；每次实际core接受才读下一合法col，显式operand_valid/index/generation保存一对预读slot，core506和tanh384/385源码不变。

最后合法gate commit同时写2623与读0（不同地址），全部coverage/credit无债务且无错误后才使下一拍成功v有效；v握手读下一col，背压不读不改q/col/tag，末col不越界。同步reset撤销valid/state/generation、下一command/row推进generation，旧q无有效语义。真实row_write_done仍严格核task/dst epoch/row/status/写债务0，并额外要求operand/output slot均退休；外部端口列表未变。

新冻结身份位于`geglu_canonical_row_01/row_bank_v1`，功能已核三bank全地址/非同址并发/同步边沿/停读保持，以及原六整row/完整独立gold/错误/复位；增加17cycle局部准入暂停仅作为预读slot保持诊断，随后在途reset，未改变core/gold或正式六row通过标准。生产owner须加入新增bank模块并对实际G→GATE→quant/fullA桥做受影响回归。OOC从旧成功G完整arithmetic子树导出51FP结构复用，只重新映射bank和父控制，全部export/新parent费用仍计G原3600s累计，原923.575406s不消失。物理RAM类型/碎片/资源须等待新实际OOC。


### §8.4.10 三bank新父 OOC 封存终态（2026-10-11）

本次冻结RTL/TB及独立gold保持六整行实际PASS身份，不再修改实现或启动修复/诊断/LN。原成功G完整DCP中的`arithmetic`子树实际导出并重新打开通过：164个端口、51个精确FP hierarchy/helper边界、blackboxes0；导出后的算术资源仍为95754LUT/42834FF/48DSP、RAMB36/18/URAM0。Vivado保存后定义名追加`_HDI_N`，前两次严格名称检查实际失败并保留日志/成本；最终只剥离尾部`(_HDI_[0-9]+)+$`序列，原成功DCP SHA、全部具体层级与helper类别仍逐一强制核对，actual/base映射留档。这不是新算术实现。

新bank/parent综合在`Start Cross Boundary and Area Optimization`后120.090394s无真实语义进展，由原120s guard停止；实际164.187886s、child exit -9、peakownedRSS3793524KiB，非RSS或累计walltime用尽。RTL展开只报告3个2624×32 RAM，尚无最终primitive映射；父层只留下`.Xil`临时文件，没有完成parent DCP/完整assembly/最终bank资源/时序。本身份终态为`COST_STOP_SEMANTIC_STALL`，不得将旧RAM0父图或成功算术子树资源代签新bank父图。

G原同一3600s预算累计为1261.7759811766446s、剩2338.2240188233554s，包含原成功OOC、两次失败export、成功export及当前停止parent，未重置预算。当前[终态receipt](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json)和[最终evidence manifest](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/evidence_manifest.json)保留v02功能清单及后续准备脚本更替：仅3个OOC/export脚本被替换，实际执行功能的RTL/TB/build/gold未变；v05/ooc_source_manifest绑定实际OOC脚本。原G历史清单含当时M工作区路径，adapter后来按§8.4.10变更，因此只以原冻结源/不可变receipt证明原身份，不声称历史工作区路径仍全部匹配。production受影响真实G→GATE→quant/fullA/Down桥仍由production owner留证，独立SV服务不证明真实matrix_run/13BO AXI生产top已完成。

### M004固定图vector服务：精确F32单lane与薄AXI搬运（2026-10-14）

依据SM004修订3，`laya_vector_add_stream_v1.sv`只例化一份现存Attention CE ADD，以测得的固定流水延迟在内部移位valid及顺序号；接受到实际消费共预约32项，返回位型进入有序结果slot，输出反压保持数据。CE算术每拍前进，未接受拍喂无效零操作数，返回valid消除这些空拍。同步低有效复位撤销**本地**信用、标签和输出；不能用于尚有AXI事务的跨请求恢复。旧`laya_ffn_fadd_slot_v1`和生成FSM FADD保留历史身份，本段不改其算术或FFR0证据。

`laya_vector_residual_axi_v1.sv`为固定图薄服务：锁存两源/目的64bit基址与32bit元素数，受理64B对齐、n∈[16,4096]且16倍数、三块不重叠、无64bit回绕；每段共同按三路当前地址的4KiB页尾及剩余beat取最小chunk（最多64beat），两源各一路512bit INCR读取、目标一路同长写入；每段B退休后推进地址。每次双源各缓冲一个beat，16个F32依次发给单lane，按序打包W；W/R/B均实际ready/valid。末W后等真实B，所有16项ADD返回消费完成后才可能进入W；成功done/status保持直到消费，非OK响应转局部错误状态。服务外围检查两个输入和ADD结果的F32 finite，以最早逻辑元素索引产生E_NUMERICAL6与done_bad_element；出错后以WSTRB屏蔽坏元素及后续元素，排空已发AW/W/B，目的整块判无效。此接口没有通用portal、owner/lease或动态Ref，但固定图外部顺序FSM仍必须提供有效地址和安全总线生命周期。首段没有实现全128行、整图scratch、错误恢复或完整请求。

同版流封装与CE ADD已做一次U55C局部OOC；输入输出delay和CLK_SRC未设、无P&R。数值、真实AXI短测、资源及限制见[本段唯一结果报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md)。
### FFR1 残差局部错误语义和观察（2026-10-14）

FFR1 沿 [受影响合同](../../../../../../../mission/ffn_residual_status_measurement_stage_20261014.md)只把本地8bit状态与原`include/laya_types.h`对齐：非有限输入或有限相加溢出返回E_NUMERICAL6，当前合法单拍R/B的非OK AXI返回E_INTERNAL8；正常计算、单加法叶子、结果槽、地址和容量均未更改。双源/目标状态仍是局部诊断，不提供生产16bit错误包或真实双source lease。`laya_ffn_residual_four_row_ffr1_tb.sv`在实际RRESP/BRESP注入三个定向错误，B失败可留一个已写64B；正常读写输出及gold保持原规则。新`ffr1_guard.py`在模拟阶段只以真实握手/叶子接受、返回与消费的12个单调累计计数续120s语义时间；被动计量在posedge NBA前记录边沿、4096次加法延迟直方图及11个互斥状态周期。host逻辑时间反例、实际数值与计量见[FFR1报告](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md)。生成叶子本体及完整FFN生产接线仍属前版设计边界。

### FFR0 四行末残差局部 producer（2026-10-14）

FFR0 使用原 `tanh_libm_round1_02` 生成的独立 `tanh_libm_leaf_fp_add_bits`，经 `laya_ffn_fadd_slot_v1.sv` 一次只允许一项在途，并在叶子 `ap_done` 后保留一项返回直到实际消费。`laya_ffn_residual_four_row_v1.sv` 以 AT050 四行 skip、Down 两个外部只读 BO 为源，通过两个独立 AXI512 单拍读端口取得数据，在一个 64B 输出拍完成 16 次 F32 加法后由 AXI512 写到另一 HIDDEN bank。每次只留一个读拍和一个写事务在途；新增存储为两个 512bit 源拍、一个 512bit 结果拍、两个 32bit 叶子操作数与一个 32bit 返回槽，没有第二矩阵或量化器。地址固定 STATE0+0、STATE1+8MiB、STATE1+0，完整 BO 容量与身份字段在本地描述符中核定。最后真实 B 后才置本地目标有效位；末个 Down R 退休后释放本地源锁。这是诊断局部状态，不是生产 hub 的真实双源授权/lease。当前无 P&R 或综合资源数据；动态数值及事务范围见 [FFR0 报告](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)。
### FFN0 有限同 runtime 接链实现状态（2026-10-14）

按 [FFN0 合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/mission/ffn_single_runtime_stage_20261014.md)在唯一 E002 实现树接入：LN 与末残差 skip 共用只初始化一次的 64KiB 外部只读 HIDDEN 数组；Down writer 目标配置为 STATE1+8MiB 的 TMP（逻辑 bank0/epoch1）；末残差拟从该真实存储重读并写 STATE1+0 的新 HIDDEN。有限适配器将门户包头 generation900 与模型 identity generation1 分开，在真实 Down cfg/ledger 接受时保存连接键，以成功退休和 done 实际消费约束残差受理。AT057 的静态构建及定向短适配器回归通过；短测试注入退休事实，不能代签完整链真实交接。

AT057 唯一四行 full 到达 LN 发布、Q 接受和 Wi 权重读取，尚未动态到达 Down TMP 写入或末残差。冻结联合进展观察器遗漏 Wi W q0/q1/scale 的真实 R 握手，导致 120s 守卫在权重仍有进展时停止。此为运行观察覆盖缺口；本合同 full 额度已用尽，需主控另立受影响合同才可回放。[有界停止报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)记录当前冻结身份、边界与未验项。外部 skip 不代表已运行 Attention producer；局部连接不代签生产双 lease 或普通 Q/L。
