# LayerNorm与完整行统计：详细设计

## 2026-10-13 LQ1R有限时序修复

AT017第一版实测HLS残余路径为F32减末级2.976ns→F32乘首级2.322ns，合计5.298ns，top估计slack−0.43ns。第二版AT018仅把局部F32减绑定请求从latency4加到5，保持乘法latency3与其余源码不变；实际绑定生效，残余同点路径仍为2.955+2.322=5.277ns、slack−0.41ns。两版时序均未达到原目标，已按合同停止这一修复方向，未启动受影响RTL；不能把局部绑定视为生产设计已采用。

按[D-M004-LNQ-TIMING-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/mission/ln_quant_timing_repair_stage_20261013.md)，本候选只针对LQ1最终1024元素归一化循环中的`delta=row[i]-m`及`norm=delta*inv`加入局部HLS `BIND_OP`：F32 subtract `fulldsp latency=4`、F32 multiply `maxdsp latency=3`。这两个值按原生成算子wrapper的stage4/3作第一版有据试探，不能预先视作native core `c_latency=2/1`或证明时序通过；生成后逐项核binding、IP真实延迟、调度II及top/子模块估计slack。若报告未消除原53.626ns组合路径，不投入16行full。

原150MHz/6.667ns目标与1.800ns uncertainty不变。原binary32操作、mean/variance相邻树、finite首错与early return、gamma能力、输出提交、外部store→Q重读与gold全部不变。候选源仅为[局部派生文件](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/layernorm_compute_lq1r.cpp)，原生产算子源码和AT015/AT016冻结输入不写回。预期是在保留部分LQ1正常周期收益时使最终F32减/乘跨寄存器边界；实际效果以新HLS和受条件准入的RTL为准。

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入F32[rows≤16,1024]及可选gamma[1024]，输出同形F32；两次1024元素行归约后归一化。

B1/S128共7824行、B2共15648行。已生成leaf主要循环体每行37874–41970cycles，另加sqrt/div、循环与数据搬运；不能用动态loop通用巨大max作当前行时延。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-layernorm_engine)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

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

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

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


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

本模块仅把实际使用的数值cache数组接入固定访问器；数组shape、元素类型、请求/任务上下文、数值leaf、算术顺序、有效范围和发布/读取边界保持。synthesis解析到对应唯一全零global，CPU保持每Runtime独立数组。共享存储组织、初始化/回收合同和唯一64bit存储打包由kernel_wrapper及hbm_loader_and_cache统一维护，不另复制数组或增加并行算术实例。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。LayerNorm数值叶子逐字不变；固定cache访问器保持gamma和工作数组的类型、容量、有效区与owner检查。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。

## T1 16行前端访问A/B实现映射（2026-10-10）

当前权威微基准合同为[联合设计§2](../../../../results/compute_throughput_optimization_20261010/source/design.md)，原生产数值与导入实现分别为[layernorm_compute.cpp](../../../../hls/operators/layernorm_compute.cpp)、[laya_cpu_embedding_io.cpp](../../../../hls/common/laya_cpu_embedding_io.cpp)、[laya_full_memory.cpp](../../../../hls/common/laya_full_memory.cpp)。本阶段只处理真实B1/S128的row0..15、D1024；局部CRC和OBSERVED不承担完整128行owner准入。

[front16.cpp](front16.cpp)提供`laya_front16_byte`和`laya_front16_wide`两个固定top。byte的STATE0/AUX/STATE1逐字节LE访问对应生产`full_read/full_write`的地址与byte语义；wide用显式512bit word以16个F32/beat打包，行内64个beat恰为4KiB。两者均依次完整扫描raw并检查finite、读取gamma、再次读取raw逐行调用同一个`layernorm_row_arithmetic(Op::LN_EMB)`、写norm和64个u32 OBSERVED。错误不继续进入LN，保持未写输出区域；详细数值错误在原`Check`中，微基准OBSERVED只编码合同规定的状态/row/col。四个BO角色分离，HLS配置均限定outstanding1；实际AXI位宽、burst和服务时间以后续生成RTL和物理握手为准。

独立输入解析、完整文件hash、gamma manifest offset及前16行切片hash由[front16_fixture.py](../tb/front16_fixture.py)执行；[front16_csim.cpp](../tb/front16_csim.cpp)对真实raw逐位及独立norm按原判据检查，并测试raw/gamma非有限。两top的HLS配置由[front16_hls_config.py](../tb/front16_hls_config.py)独立产生，禁止用此16行结果替代生产完整前端验收。
## 2026-10-12 首个 production producer 分区

LayerNorm 被选为首个普通 producer engine 候选。首个实现范围优先闭合 gamma=0 的 `LN_ATTN/LN_FFN` rows≤16 路径：接收完整 NumericIdentity、原 TaskContext、src/dst Ref 与物理 role/offset/geometry，在 caller 的 BEGIN 成功应答后启动；读取真实 source master，执行现有 1024 维固定树 LayerNorm，使用真实 destination master 提交输出，并在 completion 中报告原绑定、逻辑错误和实际提交字节。caller/hub 继续拥有 owner/source READY、覆盖、发布和 typed retirement 权威。

engine 不缓存可与 hub 冲突的 owner 状态，不按 layer 复制实例。gamma=1/2、MARKER 和其它 producer family 在相应实现与证据完成前保持待接。最终 shell 负责 role 到原 BO 的固定路由以及 monitor/adapter fence；engine `ap_done` 不代表物理写已排空。

## 2026-10-13 LQ0/LQ1 有限测量与候选

本轮依据 [D-M004-LNQ-MEASUREMENT-01](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/mission/ln_quant_measurement_stage_20261013.md)，以 `layernorm_quant_source_03` 原冻结完整闭包为LQ0，保留原B1/S128前16×1024 F32 checkpoint、LN逐位gold、Q INT8/scale gold、真实65536B写回和Q从store重读。AT013首次观察运行得到全TB659334cycles、原所有数值/协议断言通过，外部source首AR5035、末B653813、Q首AR655502；它们是不同协议事件，不能把AR→B全部认作纯算术。AT014补记录END/发布/fullA与排除复位空闲`ap_done`，当前完整结果待核。

LQ1只有一个可证伪假设：在原`layernorm_row_arithmetic`的最终1024元素归一化循环加显式`PIPELINE II=1`，提高相互独立输出元素的生成速率，不改两次相邻二叉树归约、每元素浮点表达式/检查顺序、gamma处理、模型输入、输出或任何真实存储/lease规则。原HLS报告给此循环10249cycles静态估计，属于生成估计而非实测收益；LQ0行读到写的长包围区间与很少的外部valid/ready阻塞支持优先检查核内循环。候选源位于`vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/layernorm_compute_lq1.cpp`，相对原冻结源仅一行pragma；原生产`layernorm_compute.cpp`保持不变。

验收按LQ0同冻结gold/rows16/响应策略：先CSim和单受影响LN HLS生成、核pragma是否形成实际流水及资源，再同有限RTL完整16384 F32、16384 INT8、512 scale与真实AXI/完成/零债务，比较同口径全TB和LN/Q事件。若工具忽略该pragma或无可复核周期收益，按本轮一个候选及最多两次有据修复规则停止此假设；HLS资源不是物理时序/联合fit。

## 2026-10-15 M004 固定图单行服务实际映射

当前新增的 [laya_ln_row_v1.sv](../rtl/laya_ln_row_v1.sv) 仅实现[SM004 完整 LN 单行段](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/missions/SM004.md)规定的计算服务；原 `layernorm_row_arithmetic`、模型、gamma 及独立数值依据未修改。外部接口为单时钟低有效复位、一次一行 `cmd_valid/ready` 与 `gamma_kind[1:0]`、依次装载 1024 个 X 和可选 1024 个 gamma 的 F32 流、1024 个带顺序/last 的输出，以及保持到接受的 done/status/bad index/mean/variance/inverse。kind3 返回 E_SHAPE；数值首错返回 E_NUMERICAL。此模块无 DDR/AXI、owner/lease 或层号，后续固定图薄搬运与全图调度仍需另接。

当前 FSM 以 `LOAD_X → [LOAD_G] → TREE_MEAN → DIV_MEAN → DELTA1 → SQUARE → TREE_VAR → DIV_VAR → ADD_EPS → SQRT → DIV_INV → DELTA2 → NORMALIZE → [GAMMA] → OUTPUT_ROW → DONE` 顺序运行。两个树阶段各 10 层，层内按相邻配对发射，发射数/返回数与同步读有效均排空后才换层、换 bank；其余扫描阶段串行复用同一算术实例。ADD/SUB 用现有精确 CE ADD 流，SUB 为有限 mean 符号反转后的独立 F32 加法；MUL、DIV 各复用 Attention CE 叶子，SQRT 复用 front16 现有 IP 并接 `din1`。DIV 仍计算 `/1024`，epsilon 位型保持 `0x3727c5ac`；不更改原相邻树、舍入或算术顺序。叶子 CE 固定推进，MUL 有效/标签流水与阶段排空屏蔽 bubble 和复位后的旧返回。

局部 `x_mem/g_mem` 各 1024×32bit；树 `t0_even/t0_odd` 各 512×32bit、`t1_even/t1_odd` 各 256×32bit，逻辑 payload 共 14336B。Gamma 在 LOAD_G 预装并记录首个非有限索引；NORMALIZE 后才结合对应元素 gamma 错与算术错选逻辑最早索引。错误行不输出 y，正常输出/末 done 经 valid/ready 保持；reset 清行状态与有效标签而不清整个 payload。复位在途的边界由 [AT107 局部结果](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)核定，不能从本接口推断未连接的外部存储事务已排空。

2026-10-15 的受影响首错修复保持 DELTA1→SQUARE 两遍流水：DELTA1 只保留最早 delta 错候选，不能在该扫描末提前完成；SQUARE 完整检查可能更早列的乘积溢出后，按逻辑列号择首错并停止后续无效数值行。原算术、树、接口及正常行周期不变。旧版反例与修复版六例/原九例见[阶段报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)；旧版 OOC 身份不可迁移到修复版。

按 [SM004 修订6](../../../../../../missions/SM004.md)，下一局部候选为 `laya_lnq_row_v1`：直接接本修复版 LN 输出，经唯一 512bit/16 F32 打包寄存器喂现有 `quant16_stream_row`；32 组 Q8/FP16 scale 写入 1088B 不可见行暂存，LN/Q 成功、全覆盖及真实零债务后才发布同步可复读行。当前这段是已定接口；连接实现及其同版验证单独记入 E004，不把静态接点盘点当已通过的 RTL。

## M004 修订6：实际 LN→Q 行连接（2026-10-15）

[laya_lnq_row_v1.sv](../rtl/laya_lnq_row_v1.sv) 已按上述接口实现：一行命令锁存 row/kind；LN 首个输出出现后先接受 Q start；16次真实 LN 输出握手填满唯一 512bit pack，按组/half标签给 Q；Q 输出按真实 group/half 写 q0/q1/scale 32深度独立暂存，并以覆盖位和提交计数防重复/缺项。错误行不发布；Q 协议早停时丢弃LN余输出并等待两个服务真实排空。成功行仅在 LN/Q done、全输入输出计数、Q `physical_debt_zero`、空 pack 同时成立时发布。读响应由时钟边沿从双Q bank与scale bank取数，单响应保持；release先于同拍新read，响应排空后成功done保持到消费。

真实源码身份与五正常行/错误/复位回归见[E004连接阶段报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。本连接仍无外部AXI、矩阵A读取或全图调度；受控TB force仅用于Q边界合法反压及单个协议错误注入，不能视作新增控制体系。

### SM004修订7连接身份

本次仅修改下游`quant16_stream_row`选槽控制；[laya_lnq_row_v1.sv](../rtl/laya_lnq_row_v1.sv)的LN首元素启动Q、512bit pack、隐藏q/scale暂存、row_valid/读释放/最终done合同与修订6同版。LN行算术和P1独立夹具未改，受影响功能和联合资源见[连接结果](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。
