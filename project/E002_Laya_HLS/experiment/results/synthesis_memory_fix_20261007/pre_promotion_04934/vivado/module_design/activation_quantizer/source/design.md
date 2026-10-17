# Group32激活量化：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/activation_quantizer`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：Group32完整K量化及A8来源/epoch检查接入全网络，当前完整CPU/CSim逐位通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

将FP32输入按32个元素一组量化为S8及FP16 scale，并组织最多16行的A8 tile供阵列多bank读取。输入来自LN、attention、gate或ReLU。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| Q8输入宽度 | K1024/2624/4096/256，均整除32 | 工程事实 | 08§1/图中Q8层 |
| 参考舍入 | q基于d_full；roundf半整数远离0；d_saved为FP16 RNE | 推断 | 08§2/Golden-C |
| 组织 | 两遍，完整A8 tile就绪后Linear读取 | 推断 | 08§3 |
| 特殊上游 | gate最多4lane/clk，普通通路8lane | 推断 | 08§4、12 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [08_activation_quantizer.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:46)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:58) | Group32量化语义、A8缓存重放、4/8-lane供需及边界用例 |
| [09_q8_linear_and_restore.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:50) | A8/scale消费方式、跨输出tile复用与阵列供需 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | LN→量化→Linear供需、tile所有权与背压/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| CAPTURE/AMAX | FP32 tile | 保存原值；每32值计算amax，生成d_full和inverse | 组统计/scale有效后可重放对应组，首版按完整tile交接 |
| REPLAY/ROUND | 原FP32与未舍入inverse | q=roundf(FP32(x×inverse))，保存FP16_RNE(d_full) | A8及scale完成并经过有限/范围检查 |
| READY/REUSE | 完整tile | Linear对所有输出tile重复读同一A8 | 矩阵全部输出完成后才释放A8 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| 输入 | LN/attention/gate/ReLU→quant | F32[M,K]，M≤16，最多8lane | 行/group次序；gate拍有效数4 | 不得跨行；保存至重放读取结束 |
| 组参数 | amax/scalar→replay | FP32 d_full/inverse；FP16 d_saved | q用d_full对应inverse，恢复用d_saved | scalar吞吐必须支撑组生成 |
| 输出 | A8 cache→Q8 Linear | 每组32S8＋16bit scale | 阵列需同时读16行，非普通串流直接供给 | 完整tile可读，所有输出列复用 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- amax=max(abs(x[0..31]))；d_full=FP32(amax/127)；inverse=d_full非0时FP32(1/d_full)，否则0。
- 全零组q=0、scale=0；FP16次正规和舍入成0按参考处理，不能flush-to-zero。
- 非有限input/reciprocal、scale溢出或q超[-127,127]报数值错误，不静默clip或切换算法。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| FP32输入 | 最大16×4096×4=256KiB/bank | 捕获→重放完成 | 双缓存512KiB |
| A8与scale | 最大16×4096×34/32=68KiB/bank | 写完→全部输出列读取→释放 | 双缓存136KiB，bank端口另核算 |
| inverse/scale表 | 每bank最大12KiB另有效位 | 组参数与输入同生命周期 | 不可用舍入后的scale反求q |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 同一输入tile只量化一次，不按输出tile重复。
- 8lane输入平均4cycles产生一个group统计；scalar不能流水则等待逐组计入。
- gate直连第一遍只有4lane，第二遍才8lane；LN融合仅合并捕获阶段。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [activation_quantizer.h](../../../../hls/operators/activation_quantizer.h)、[activation_quantizer.cpp](../../../../hls/operators/activation_quantizer.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_activation_quantizer`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 舍入和域 | 零、半整数边界、次正规、d_saved成0、非法非有限 | 比amax/d_full/inverse/q/d_saved完整链 |
| 尺寸和tail | K2624末group、K256小层、M1/2/16 | 数量、组顺序、无跨行污染 |
| 供需 | 4lane gate、scalar延迟、Linear读旧tile | 正确背压和A8复用 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/activation_quantizer/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3可执行量化参考和FP16转换；G4 reciprocal II、banking、实际tile就绪周期。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

接受QuantTask(TaskContext,src,a_dst,K,src_region,input_lanes)。K仅256/1024/2624/4096，rows1…16；A8对象记录row_space/b/row0/rows/K及所绑定源epoch，Linear必须逐项匹配。F0从完整READY数组读取且input_lanes=8；4lane模式是明确的流适配测试／F1候选，不把4lane gate按8lane输入估时。

| 阶段 | 合同 | 对外数量 |
| --- | --- | --- |
| CAPTURE | rows×K个真实F32，按行/32元素group求amax并保存 | 只有接受才推进；每组需完整32值 |
| SCALE/REPLAY | d_full=FP32(amax/127)，q基于未舍入d_full对应inverse；d_saved=F16 RNE | 每行K/32组，完整32q与同组scale原子写A8 |
| PUBLISH | A8目标epoch所有rows×K/32组齐全 | input/replay/scalar流水全部退休后TaskDone |
| REUSE | Linear所有N输出重复读取当前A8 | 不能按输出tile再次量化，最后一次矩阵读退休后释放 |

全零组q/scale=0；非有限、q超[-127,127]、scale溢出按E_NUMERICAL，禁止悄悄clip。Q8Group的350bit仅串行导出/TB；真正A8读口为16行各32q+scale。A8 bank的row_local0…rows-1对应row0+row_local，不能直接当全局token。

实际数值输入来自abi_replay捕获的LN/attention/gate/act hidden及同模型上下文。本次已直接捕获122次原生backend activation Q8_0 scratch；其路径和布局见reference manifest。软件candidate派生q/scale仍独立命名，不能替代原生scratch。下一步独立candidate回放需保存原输入hash、q/scale原位、amax/d_full/inverse并与原生Linear浮点结果分开比较。TB停顿在第31/32值、最后group和tile发布前，检查组界与epoch不串。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `embedding_norm` | `ir_217 / layer_norm` | `native/forward_0/ir_217.bin` |
| `enc0_mlp_norm` | `ir_268 / layer_norm_1` | `native/forward_0/ir_268.bin` |
| `enc0_gated_product` | `ir_273 / mul_7` | `native/forward_0/ir_273.bin` |
| `act_gelu` | `ir_1615 / gelu_29` | `native/forward_0/ir_1615.bin` |

量化的直接backend参考另见manifest的`native_quantized_activation_scratch`：122次实际MUL_MAT输入scratch，34B/组（FP16 d＋32 S8），每项记录consumer node、shape、bytes和hash；例如`audited_outputs/native_q8_activation_linear.bin`对应Encoder0 QKV。硬件candidate dot/term/PS内部值尚未导出/实现，不能据此宣称这些值已逐位验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对QuantTask的stage/行空间/来源region/K/lane和Q8Group数量；真实Q8 scratch检查是已有原生34B组的无损格式回放。尚未实现候选量化算术，也未在A8状态中保存并核验K/rows/batch/row0/row_space及源epoch，后续必须将这些元数据绑定到Linear消费者，不能以Q8_TILE内容标签代替。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。

## 13. P1真实Group32计算与A8身份绑定（2026-10-07，Astra xhigh）

本轮实施和验收以[task.md §11](../../../../hardware_agent/task.md)为共同合同；实际重读[08§2–5](../../../design_source/08_activation_quantizer.md)、[总体§5.1](../../../../source/laya_baseline_design.md)和[15§10–14](../../../design_source/15_integration_interfaces_and_pipeline.md)。原P0检查保留；本节补齐在**数值切片边界**的完整A8关联，生产全图缓存状态机仍不据此宣称完成。

唯一新维护源`hls/operators/activation_quantizer_compute.cpp`，公共数值／元数据接口`include/laya_numeric.h`及`laya_numeric_tasks.h`；模块`tb/numeric_tb.cpp`与`tests/numeric_reference.py`分别执行DUT和独立期望。输入物理`x[16][4096]`，有效rows≤16、K=256/1024/2624/4096；输出`q[16][128][32]`、`scale_bits[16][128]`。有效组数rows×K/32，尾部完全不访问。每次调用输入完整READY，不使用跨任务有限FIFO。

按row/group顺序，将32F32保存于128B组buffer，先abs-max统计，再d_full=FP32(amax/127)、inverse=FP32(1/d_full)（零分支+0），回放乘inverse并roundf（半整数远离0）。FP16保存scale用RNE而不是q的舍入方法；不使用已舍入FP16 scale求q。保留FP16次正规/零和IEEE FP32逐步舍入。d_full下溢0时q/scale为0；非有限输入/reciprocal/乘积、scale溢出或q超范围均E_NUMERICAL，不clamp。CPU q/scale与独立oracle逐位比较，d_full/inverse/amax用于定位。

A8只有全部有效组写完才发布READY。元数据必须保存并核验请求四tag/request/generation/B/S、a_dst BufferRef、Quant task_id及stage/layer、K/rows/batch/row0/row_space、src BufferRef/region和源epoch/完整来源身份。消费者Linear必须与自身Task和独立预期来源逐项匹配；不能用Q8_TILE标签或相同K取代来源证明。失败/复位/新generation先失效；旧epoch不能复用复活。切片接口拒绝缺coverage、非READY源及非法任务绑定，实际检查必须位于综合可达数值入口前半段。

真实验证native ir_217→QKV；ir_268→Wi（孤立量化差异）及候选LN输出→Wi（真实联链）；ir_273→down；ir_1615→act N2。scratch分别linear、linear_2、linear_3、node_1808，读取原34B数据按manifest hash核验，仅用于native差异报告，不冒充候选expected。K4096最大容量以固定seed补充用例验证并标明范围；零、舍入ties、half次正规/溢出、reciprocal溢出及元数据反例见task§11.6。

本轮串行组切片不要求8lane或与LN融合、不复制完整256KiB输入作为第二份内部缓存。输入/A8接口容量与实际片上资源分开记录在[results.md](results.md)。只有独立工具运行后才能报告HLS CSim或isolated综合，CPU通过不证明物理cache端口、II/频率或全forward完成。

## 14. P1实际代码映射与接口边界（2026-10-07）

- [activation_quantizer_compute.cpp](../../../../hls/operators/activation_quantizer_compute.cpp)为独立阻塞数值入口；[laya_numeric.cpp](../../../../hls/common/laya_numeric.cpp)执行请求/源/目的owner验证、release/reset及IEEE FP16位转换。P0 [activation_quantizer.cpp](../../../../hls/operators/activation_quantizer.cpp)仍用于主机合同检查，不参与isolated数值库。
- 数值入口先验证task和完整F32来源，再领取A8 epoch并进入FILL。每组32值两遍处理，成功后将原F32来源记录、生产task身份、覆盖位及A8形状一并发布READY；数值错误保留消耗的epoch并使记录INVALID。领取前错误保持已有READY/READ记录与数组；reset清覆盖与valid但保留ref/epoch。
- [numeric_tb.cpp](../tb/numeric_tb.cpp)直接检查±0、half ties/次正规/零/溢出、half整数ties远离0、reciprocal异常、首末有效输入、来源身份、READY/READ拒写及release/失败/FILL/reset连续epoch反例。[numeric_fixture_test.py](../../top/tb/numeric_fixture_test.py)复用LN实际发布元数据，覆盖真实K256/1024/2624和固定seed K4096，所有q与FP16 scale对独立[reference](../../../../tests/numeric_reference.py)逐位比较。
- [numeric_hls_quant.cfg](../../../../config/numeric_hls_quant.cfg)用于isolated CSim；[numeric_hls_quant.tcl](../../../../config/numeric_hls_quant.tcl)用于实验器件上单模块综合。工具实际推导的x/q/scale为`ap_memory`接口，尚未绑定生产AXI/HBM和片上缓存bank；资源、循环II与频率的实际阶段解释见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/08_activation_quantizer.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

完整QuantTask验证真实F32 producer/lease与row/shape来源，读全K并调用同源P1组算术；一份A8 tile供完整N全部输出复用。A8独立epoch每row tile一次，保留源request/layer/epoch，不能把window计为量化任务。SCORER_ACT原地转换只可通过合法lease读取尚未覆盖旧行。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [activation_quantizer_compute.cpp](../../../../hls/operators/activation_quantizer_compute.cpp)：本模块当前P2实现责任源。
- [full_tasks.cpp](../../../../hls/operators/full_tasks.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
