# Decision、scorer与act：详细设计

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

C++合同：最终hidden、16个marker位置/mask与CLS→16候选logits及2ACT logits；内部stats[4]拼成ACT input[1028]。

Decision/Scorer/ACT复用Q8/FP/LN/vector；每题Scorer FC1为16×1024² MAC，ACT FC2为512 MAC；FP ACT FC1为263,168乘加。当前完整RTL成功路径受Attention异常阻断。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-decision_scorer_act)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/decision_scorer_act`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：两层Decision、16候选scorer及本题CLS驱动的act完整执行，当前B2/B1整图与真实top CSim通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

在Encoder之后组织两层Decision全序列处理，按16个marker取向量做scorer，并利用原始候选分布和CLS生成act logits。这里定义功能连接，具体计算复用已有LN/Q8/FP/向量单元。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| Decision | 2层，完整S，full attention，无主干RoPE，FF4096/ReLU | 工程事实 | 13§1 |
| 候选 | 16列固定；无效marker也gather本题CLS后计算再加有限mask | 工程事实 | 13§2 |
| 混合类型 | scorer末层F32[1,1024]；act首层F16[256,1028]；末层Q8[2,256] | 工程事实 | 13§4/模型数据 |
| Host边界 | FPGA完成act统计；CPU对输出施加Typed温度/业务规则 | 推断 | 01§5、13§3/§5 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [01_host_runtime_and_abi.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:36)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:52)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/01_host_runtime_and_abi.md:68) | 候选/marker输入、result布局与CPU解码边界 |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [03_forward_controller.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:32)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:48)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md:59) | Decision阶段依赖及Q8/FP/向量资源复用 |
| [13_decision_scorer_act.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:31)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:47)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:70)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:78)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:84) | Decision/scorer/act边界、16列、混合精度及结果生命周期 |
| [14_result_status_and_verification.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:29)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:59)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:73)、[§7](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:102)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:120) | 结果提交、联合验证、数值/性能口径、错误及证据状态 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | 共同计数、接口、缓存所有权、握手/复位及联动修改 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| DECISION | final LN/type add后的hidden | 两层LN/QKV/full attention/Wo残差/FFN残差 | 保留最终hidden和CLS |
| GATHER/SCORER | marker_pos与marker_mask | 紧凑idx转工作区地址；LN→Q8 fc1→两次bias→GELU→F32 fc2 | 全部16个raw/masked logits就绪 |
| STATS | 未应用问题温度的16列masked logits | softmax p→top1/近似top2/熵/k归一化 | 四项统计与对应CLS准备好 |
| ACT | CLS1024＋统计4 | F16 fc1→bias/GELU→量化→Q8 fc2/bias | F32[B,2]与候选一起交结果模块 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| hidden/marker | Decision输出/请求→gather | F32[B,S,1024]、I32[B,16]、U8[B,16] | idx=b*S+s先恢复b/s再固定1024stride | 最终hidden到act读取CLS完才释放 |
| scorer数据 | LN/Q8/向量/FP↔heads | B×16行×1024；最后F32[B,16] | baked bias与原bias两次操作；mask为相加 | 共享单元按controller授予使用 |
| 统计/act | softmax/scalar→FP/Q8 | F32[B,1028]及F32[B,2] | 输入前1024为CLS，后4为统计；字段序按原图 | 统计未齐不得启动act |
| 输出 | heads→result_status | candidate F32[B,16]，act F32[B,2] | 按batch和列顺序保持raw数值 | 成功结果才由CPU解码 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- masked candidate=raw+(1-marker_mask)×(-10000)，不是直接覆盖-10000。
- k=max(有效候选数,2)；统计依次为top1、top1-top2_approx、-sum(p*log(max(p,1e-9)))/log(k)、k/255；p来自未施加问题温度的分布。
- 最大值按m=ReLU(m-a[i])+a[i]顺序链；delta=FP32(top1-p)，denom=FP32(delta+FP32(1e-6))，ratio=FP32(delta/denom)，r=FP32(p×ratio)，再对r同链求近似top2。
- act1028输入保持F16权重转F32路径；最后N2不可假定主矩阵满载。FP32与非线性顺序按task§12.2冻结；CPU/CSim使用系统单精度libm，RTL误差仍待独立验证。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| marker区 | B2×16×1024×4=128KiB | gather→LN/scorer消费 | 无效列同样处理 |
| 最终hidden/CLS | 既有state | Decision结束至act拼接完 | 不复制另一份全网state |
| 统计与heads缓存 | 16列概率/四统计、两浮点尾层权重 | 当前题/模式生命周期 | FP尾层可复用已释放KV，需controller证明 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- scorer LN和N1浮点输出、act N2小矩阵利用率不同于主干，逐阶段计时。
- GELU复用vector，softmax/FP复用attention，不再新增整套相同硬件。
- 五题由Host分2+2+1重新计算marker偏移，整请求延迟包含三次kernel及合并。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [decision_scorer_act.h](../../../../hls/operators/decision_scorer_act.h)、[decision_scorer_act.cpp](../../../../hls/operators/decision_scorer_act.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_decision_scorer_act`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 候选与索引 | 1/2/3/16候选、B2/末批B1、无效marker | 16列输出与参考一致，固定stride转换正确 |
| 特殊语义 | ties、近似top2、两次bias、noul临界值、1028输入 | 保存raw logits/p/统计/act输入和输出定位差异 |
| 完整业务 | 同质量集和Typed真实两题 | 区分候选/act正确性与Host温度后解码 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/decision_scorer_act/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3已有真实请求/中间值捕获，候选函数与独立回放未冻结；G4小矩阵与统计延迟；G6质量阈值；G7配对GPU。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本模块在F0中组织已定义的GatherTask、LN_MARKER、LIN_SCORER_FC1、BIAS_GELU_SCORER、FP_SCORER_FC2、APPLY_CAND_MASK、SOFTMAX_CAND、StatsTask、ConcatActTask、FP_ACT_FC1、BIAS_GELU_ACT、QUANT、LIN_ACT_FC2；不私建另一套Linear/LN/FP引擎。两层Decision由controller stage4执行完整S的主干。

| 边界 | 具体参数／数据 | 数量／存活条件 |
| --- | --- | --- |
| Gather | columns:u8=16，hidden/markers:ref | 每题16×1024；idx转s后按固定1024stride读取 |
| scorer | MARKER row_space，row0=0、rows16 | FC1 baked bias→独立post bias→GELU→FP FC2/bias；输出16列 |
| 概率／统计 | BATCH rows1，length16，valid_options:u8 | STATS顺序top1、top1-top2_approx、归一化entropy、k/255 |
| act拼接 | hidden、stats、ACT_INPUT refs | CLS1024先出，4stats追加；末拍col1024/count4 |
| act末层 | K256/N2，BATCH rows1 | N2输出1拍count2，6个padding lane不可参与/写回 |

最终hidden保留到ConcatAct读取CLS完成；scorer/gather不会释放它。HEAD_WORK各固定子区互不覆盖，所有16列raw/masked/prob都可独立定位。统计top2是原图ReLU max链与先除后乘，不能排序替换。温度只在Host业务解码；act统计使用温度前masked candidate概率。

本次实测原生S94无效marker对第二题仍指全局idx0；本ABI规范化为本题CLS，S128第二题为128，因此两种profile无效列数值会变。模块TB必须使用abi_replay整16列期望，不能只比有效选项后宣称整个输出逐位相同。已实际捕获candidate masked为ir_1469、mask前为ir_1464、act为ir_1616；更多alias以实际manifest为准。联合测试覆盖真实两题、B2索引、无效列CLS、scorer两bias、近似top2、1028尾和N2，合成ties另标补充。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `marker_gather` | `ir_1458 / embedding_2` | `native/forward_0/ir_1458.bin` |
| `scorer_norm` | `ir_1460 / layer_norm_61` | `native/forward_0/ir_1460.bin` |
| `scorer_fc1_with_bias` | `ir_1461 / linear_120` | `native/forward_0/ir_1461.bin` |
| `candidate_before_mask` | `ir_1464 / squeeze` | `native/forward_0/ir_1464.bin` |
| `candidate_raw_logits` | `ir_1469 / add_119` | `native/forward_0/ir_1469.bin` |
| `act_probability_vector` | `ir_1470 / softmax` | `audited_outputs/preclamp_31.bin` |
| `act_stats4` | `ir_1611 / cat_56` | `native/forward_0/ir_1611.bin` |
| `act_input1028` | `ir_1613 / cat_57` | `native/forward_0/ir_1613.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。


## P2 A批：16候选统计与1028维act接口（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§1–5](../../../design_source/13_decision_scorer_act.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/decision_full_compute.cpp`，提供candidate_mask、candidate_stats、concat_act_row。候选mask逐列加finite bias；stats按task§12.2的相邻16项熵树与ReLU max chain，top2保留delta/denom后再乘p；顺序[top1,margin,entropy,k/255]。concat复制最终Decision本题CLS1024及stats4；无温度，CPU后处理与硬件act分开。完整Decision两层、marker gather和task调度在后续B/C批实现，A批叶函数不可声明完整head已连通。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/13_decision_scorer_act.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

GatherTask全16marker包含invalid本题CLS，真实读最终Decision H。SCORER_ACT的LN结果→量化/FC1覆盖→post bias/GELU用合法lease，不因B0覆盖使B1旧输入失效。CAND_RAW/MASKED/PROB/STATS/ACT_INPUT/ACT_HIDDEN/ACT_LOGITS独立region，使candidate保留到结果提交；CLS保持到concat完成。统计valid_options从已验marker mask计数绑定。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[decision_full_compute.cpp](../../../../hls/operators/decision_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`candidate_mask / candidate_stats / concat_act_row`（marker搬运由完整GatherTask负责）。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_tail.cpp](../../../../hls/operators/full_tasks_tail.cpp)：本模块当前P2实现责任源。
- [full_tasks_vector.cpp](../../../../hls/operators/full_tasks_vector.cpp)：本模块当前P2实现责任源。
- [full_tasks.cpp](../../../../hls/operators/full_tasks.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

本模块仅把实际使用的数值cache数组接入固定访问器；数组shape、元素类型、请求/任务上下文、数值leaf、算术顺序、有效范围和发布/读取边界保持。synthesis解析到对应唯一全零global，CPU保持每Runtime独立数组。共享存储组织、初始化/回收合同和唯一64bit存储打包由kernel_wrapper及hbm_loader_and_cache统一维护，不另复制数组或增加并行算术实例。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。本模块继续复用原决策算术及数值布局；必填bias查找由Controller的引用索引入口承担，输出和错误次序保持原合同。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
