# LayerNorm与完整行统计：详细设计

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/layernorm_engine`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：完整行LayerNorm与gamma绑定接入全网络，当前CPU整图和真实top CSim逐位通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

实现1024维LayerNorm，保留固定centered variance与浮点求值顺序。供embedding、Encoder/Decision、final LN和scorer复用，不能直接使用Llama RMSNorm公式。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 维度/eps | D1024，eps1e-5 | 工程事实 | 07§1/§2、模型配置 |
| 图中位置 | 第0层attention前跳过；仅embedding/final保留gamma | 工程事实 | 07§1 |
| 求值顺序 | mean→centered variance→归一化三遍、相邻二叉树 | 推断 | 07§2；拟定Golden-C |
| 候选接口 | 8feature/clk；双4096B行buffer | 推断 | 07§2/§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [07_layernorm_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:28)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:40)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md:50) | 完整行三遍统计、量化衔接、供需及联合验收 |
| [08_activation_quantizer.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:46) | LN输出捕获、量化统计/重放与速率匹配 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | LN→量化→Linear供需、tile所有权与背压/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| PASS1 | 完整F32行 | 保存x并按固定树求mean | 1024值到齐且归约退休 |
| PASS2 | x与mean | delta=FP32(x-mean)，square并固定树求var | 完整方差和scalar倒数完成 |
| PASS3 | x/mean/inv及可选gamma | norm=FP32(delta×inv)，按图乘gamma | 全部输出被下游接受才释放行 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| 输入 | embedding/hidden/marker→LN | F32[1024]，最多8lane | 完整行与b/s或marker上下文 | buffer满时背压 |
| 模式/参数 | controller/aux→LN | LN位置、gamma可用性、eps | 不把已fold affine重复加回 | 模式变更只在前一行退休后 |
| 输出 | LN→quantizer或type add | F32[1024]，最多8lane | F0整阶段；F1输出同时作quant第一遍输入 | 量化暂停时保留输出 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- mean/var使用固定相邻二叉树与FP32逐步舍入；不能换E[x²]-E[x]²。
- inv=FP32(1/sqrt(FP32(var+eps)))，norm=FP32(FP32(x-mean)×inv)；函数版本/近似待G3。
- 禁止擅自FMA/reassociation；非有限值按一致输入域/错误规则检查。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| 双行buffer | 至少8192bytes | 每行三遍全部读完并输出交付后释放 | 双bank并不保证同bank任意读写 |
| gamma/归约中间值 | 实际实现待确定 | 模式/行有效期间保持 | 固定树节点不能被新行覆盖 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 与quant合并第一遍只省一次传输；quant仍需对保存输入重放。
- scorer FC1 dot比主QKV短，LN可能成为瓶颈，不能套主矩阵利用率。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [layernorm_engine.h](../../../../hls/operators/layernorm_engine.h)、[layernorm_engine.cpp](../../../../hls/operators/layernorm_engine.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_layernorm_engine`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 数值 | 常数、大偏置近常数、正负抵消、极小值和gamma | 逐项比mean/var/inv/输出，不只看答案 |
| 图位置 | 层0跳过及embedding/final gamma | 不重复执行folded affine |
| 背压/复用 | quant暂停、准备下一行与读旧行 | 无早覆盖且固定树顺序不变 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；当前没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/layernorm_engine/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3 sqrt/div函数与Golden-C版本/容差；G4 scalar II/尾和RAM端口；G1复位。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

LayerNormTask包含src/dst BufferRef、gamma枚举u8、D:u16=1024、eps_bits:u32=0x3727c5ac以及TaskContext。LN_EMB只用emb gamma、LN_FINAL只用final gamma，其他gamma=0（无affine）；Encoder0前不接受LN_ATTN。任务src/dst不能物理重叠，行cache生命周期覆盖三遍。

输入/输出均rows×1024F32，普通8lane每行128拍；row身份不能因暂停变化。第一遍完整1024值后求mean，第二遍centered variance后求inverse，第三遍归一化及可选gamma。只有第三遍最后输出被存储适配器接收且写可见才登记行完成。不能用最后一项mean进入加法流水来代替LN done。

F0按op绑定目的：LN_EMB为HIDDEN→NORM或另一HIDDEN bank；LN_ATTN/LN_FFN为HIDDEN→NORM；LN_FINAL为HIDDEN→NORM或另一HIDDEN bank；LN_MARKER为MARKER→HEAD_WORK.SCORER_ACT（region0）。controller等相应矩阵全部READY后才QUANT或ADD_TYPE。未允许跨任务直连有限FIFO。量化任务不占用LN_ROW；如以后融合，须定义复合任务同时启动消费者并更新F1数值／周期证据。

原生backend NORM可能使用不同归约／精度路径；真实capture的norm结果用于模型误差基准，候选固定相邻树、FP32每步舍入用于独立实现检查，二者不混为逐位黄金。TB检查真实低方差行、gamma所在位置、B2最后行、第三遍末拍停顿、行cache重用和错误epoch；合成常量／非有限极值明确补充测试。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `embedding_norm` | `ir_217 / layer_norm` | `native/forward_0/ir_217.bin` |
| `enc0_mlp_norm` | `ir_268 / layer_norm_1` | `native/forward_0/ir_268.bin` |
| `encoder_final_norm` | `ir_1410 / layer_norm_56` | `native/forward_0/ir_1410.bin` |
| `scorer_norm` | `ir_1460 / layer_norm_61` | `native/forward_0/ir_1460.bin` |

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P1真实数值切片细化（2026-10-07，Astra xhigh）

本轮实施和验收以[task.md §11](../../../../hardware_agent/task.md)为共同合同；来源已重新读取[07§2–4](../../../design_source/07_layernorm_engine.md)、[总体§5.4](../../../../source/laya_baseline_design.md)及[15§10–14](../../../design_source/15_integration_interfaces_and_pipeline.md)。先实施阻塞数组D1024、rows≤16数值核，保持P0 validator和完整forward门禁。

唯一新维护源为`hls/operators/layernorm_compute.cpp`，公共接口`include/laya_numeric.h`及`laya_numeric_tasks.h`；本模块`tb/numeric_tb.cpp`直接测试，独立oracle在`tests/numeric_reference.py`。以下实际映射与运行记录见§13及[results.md](results.md)；综合可达路径仅POD与定长C数组，host-only容器不进入数值库。

输入`x[16][1024]`、gamma[1024]和LayerNormTask／请求／源／gamma元数据，输出`y[16][1024]`以及mean/variance/inverse[16]，返回状态和有效数量。只处理有效rows；完整src READY、shape/row/batch/epoch/request/generation/四tag匹配、src/dst非物理别名后才访存。gamma_kind=1/2必须绑定模型emb_norm_w/final_norm_w及LN_GAMMA bank0/1，gamma0完全不读取gamma。领取前错误保留旧owner；领取后数值错误将本次valid清零，不发布部分结果，按§13和任务§11.2.1处理；F0调用结束才交接，数组方式output_beats=0。

1024值均值和centered variance都采用明确相邻二叉树（512→256→…→1），每节点单独IEEE FP32 RNE；mean/var各除1024，eps固定0x3727c5ac，sqrt后单独除法得到inverse，norm先减mean再乘inverse，仅图指定gamma另乘一次。禁止beta、RMS、E[x²]-mean²、FMA/reassociation/FTZ和近似rsqrt。输入及所有中间有限、var非负；错误E_NUMERICAL。CPU与独立oracle的mean/var/inverse/y逐位验收；native NORM仅记录差异，不等同候选黄金。

本轮采用一行x缓存＋一行tree工作区（各4096B）顺序处理；树压缩先读两个子节点再写父节点。此单任务串行切片不启用原§6的双行重叠、不宣称8feature/clk；后续并行实现仍保持树节点配对。无stream/背压端口，本轮不能报告有限FIFO或物理reset验证。容量/条件预算见[results.md](results.md)新增P1记录。

必须真实验证两条数据：ir_267→候选LN→候选quant→Wi窗口，native ir_268只对照；以及ir_216＋真实emb_norm_w→候选LN，native ir_217对照。TOKEN选b0首16行及b1末16行，再做rows1/15尾部。gamma最终模式可作独立单元，未做真实final全链明确标出。常数/近常数/大偏置/抵消/极小值/NaN/Inf/源epoch和gamma身份变异见task§11.6。HLS CSim和isolated综合按真实工具结果登记。

## 13. P1实际代码映射与所有权（2026-10-07）

- [layernorm_compute.cpp](../../../../hls/operators/layernorm_compute.cpp)为独立数值入口；[laya_numeric.cpp](../../../../hls/common/laya_numeric.cpp)负责请求、来源、gamma与持久目的owner检查、release/reset和FP16辅助。P0 [layernorm_engine.cpp](../../../../hls/operators/layernorm_engine.cpp)仍只提供主机合同验证，未接入完整forward。
- 入口按“任务与来源/gamma验证→领取目的epoch并进入FILL→逐行相邻二叉树、centered variance、sqrt/div和可选gamma→完整覆盖后READY”的顺序执行。领取前错误保持已有READY或READ owner和旧数组；领取后数值错误保留已消耗epoch、置INVALID，下一次必须使用新epoch。reset清valid/coverage但不回退epoch。
- [numeric_tb.cpp](../tb/numeric_tb.cpp)直接覆盖常数、抵消、gamma、大偏置近常数、次正规、非有限和连续owner生命周期；大偏置与次正规统计/输出使用独立NumPy oracle固化位模式。[numeric_fixture_test.py](../../top/tb/numeric_fixture_test.py)以真实ir_267和ir_216及GGUF gamma切片逐值比较，native LN仅记录差异。
- [numeric_hls_layernorm.cfg](../../../../config/numeric_hls_layernorm.cfg)对该入口执行isolated CSim；接口数组仍是阻塞调用的逻辑端口，尚未实现生产AXI、物理reset、背压或完整forward。具体运行次数、日志和未执行阶段以[results.md](results.md)最新P1节为准。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/07_layernorm_engine.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

P2完整typed LN从已发布矩阵owner的实际rows×1024读取，gamma按stage/model绑定；允许把P1私有行算术机械提取为同源纯辅助，P1接口保持、回归重跑。每tile完整行写回后登记矩阵覆盖，所有batch/row齐才全对象READY；禁止原地。Encoder0 LN_ATTN仍拒绝，最终gamma仅LN_FINAL。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [layernorm_compute.cpp](../../../../hls/operators/layernorm_compute.cpp)：本模块当前P2实现责任源。
- [full_tasks_front.cpp](../../../../hls/operators/full_tasks_front.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。
