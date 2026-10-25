# M006/SM007 共享 FP 阵列当前映射（2026-10-17）

直接F32除法单lane的生产配置位于 `rtl/laya_attention_fdiv_lane_v1_ip.tcl`，保留原IP的单精度直接Divide、No_Usage DSP、NonBlocking/无结果ready及数值配置，latency定为8。AT018按此生成真实IP并作模块OOC，AT019用同版生成VHDL定向验证；实现现阶段尚未接成8lane或softmax生产链。其[局部结果](../../../../../../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT015_AT019_direct_divider_engineering_milestone_20261017.md)不代签联合时序。共享FP下一生产接口依[FP数据流裁定](../../../../../../../results/reviews/SM007_fp_dataflow_interface.md)拆分mul/add事务与QK七组；原AT009配对接口仅为历史局部验证，原add=11拍不符合当前≤8拍合同。

生产 `rtl/laya_shared_fp256_v1.sv`（SHA256 `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`）按 [M006 修订5 §10.1](../../../../../../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md) 实例化唯一参数默认 256 路的原 `tm1tn8_fmul_ip` 和 `tm1tn8_fadd_ip`。乘法与加法输入分别接受、分别舍入；物理返回用有效位和五拍乘法数据对齐。64 槽保存每次返回的数据及 phase/epoch/tag；phase lease 只在所有已接受响应退休后释放，错误 phase/epoch 不获 issue ready。生产 RTL 无 TB 算术替身。AT007–009 已验证四路和默认全宽局部接口，证据与边界见 [E007 结果](../../../../../../../project/E007_m006_full_fpga_attention/experiment_results/summary.md)。

固定QKV存储由生产 `rtl/laya_attention_qkv_bank_v1.sv`实现：3 plane×64个独立同步1R1W bank，每bank深2048个F32，地址 `{head[3:0],token[6:0]}`；矩阵每拍写一个plane的连续32列半幅，Attention可同拍分别从Q/K/V三个plane读64列。单plane响应提供一槽保持，读写同地址时读优先、写端拒绝。存储位不随reset清零，调用者仍须以lease/epoch管理数据身份。AT013核三plane、最高地址和响应阻塞/碰撞；AT014核同生产模块在目标part的BRAM映射。该bank目前是独立生产模块，尚未接矩阵退休或Attention父级调度。

共享FP阵列尚未接入QKV/PS/G/LN物理银行或父级QK/AV调度；phase数值在局部TB中作为诊断标签，不代表全部生产mode已接通。AT009的64个连续QK向量/一个AV向量是固定数据的阵列与队列试验，不能代签原QK邻接树、AV按key反馈、完整head周期或256路综合资源。下一步按同一合同连接固定bank与真正的QK/AV数据依赖。

# M006/SM007 当前增量：strict expf 单 lane 调度（2026-10-17）

权威规格为 [M006 修订5](../../../../../../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md) §10.1、§10.4。当前唯一生产 `attention_exp_bits.cpp` 保留 glibc 2.39 位算法与独立 libm oracle，仅将 `attention_exp_leaf` 标成目标 II=1 流水并移除两个 f64 加/乘实例数限制。该改动是调度/面积取舍，不更改浮点运算顺序。生成 RTL 可用于后继 8-lane 严格 EXP 服务，但目前仍未接入共享 256-lane FP/银行或完整 Attention 主干。HLS II=1 不等于实际 300MHz 或 8-lane 可行，首个 Vivado OOC 仍无网表。具体源码 SHA、局部 RTL 和成本见 [E007/R001 结果](../../../../../../../project/E007_m006_full_fpga_attention/experiment_results/summary.md)。原 M004 和更早候选以下均保留历史适用身份。

---

# Attention与共享浮点引擎：详细设计

当前新增候选为 [联合合同 §8.3.1](../../../../results/compute_throughput_optimization_20261010/source/design.md) 的 `attention_tile_service_v1`：一个 head/tile、完整 S1024 容量、M16/A16/D4 与四个原非流水 EXP，16 dot 槽、八个 SM scratch、M/A 各 Q32 和每 D 的 Q32。新 18/19/20/21 命令承担完整 tile Q 捕获和三个阶段；旧 service 及其完整 head/OOC 证据保留。模块当前验证状态见 results.md 的新候选记录。

首错映射现按[联合合同 §8.3.2](../../../../results/compute_throughput_optimization_20261010/source/design.md)实现：cmd18 完整捕获原 Q 位型，非有限 Q 仅记录首个待决 row/d，加载正常退休。cmd19 先执行首坏 Q 所在 row 之前的真实 QK，并等待全部已接受队列/写回债务退休；若没有更早运算错误，再返回首坏 Q 的局部 d。坏 Q 所在 row 及其后不发 QK。Q 检查 rank 为 row×2^21+d，同 row 算术 rank 统一加1024，外部 product/tree/scale 等原局部索引不变。C 模型依原逐 row 先检查64个 Q，再计算该 row；不能统一对数值 result 取模64。六种竞争/末维/多坏 Q 与 CE/reset 的实际结果按 results.md 登记。

按 root 当前阶段收口要求，新增 tile 服务只交独立模块出口，生产 scalar caller 保持原入口。已实现但未编译/运行的 tile caller 接入保存在[UNVERIFIED patch](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/handoff/unverified_production/tile_production_UNVERIFIED.patch)，实际完整13BO/generated caller、唯一共享实例、B2 fallback 与外层 owner/末 B 的新 tile 验证均 NOT_RUN，留待复制后的工程接续。

本次tile稳定身份为[source_manifest_v10.json](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/source_manifest_v10.json)，SHA256 `34145bda45ba482150a8be37876288771e01b3952bbb5de6ba892340d5f8b0b2`。同源16row数值/首错/真实CE-reset与连续head128已通过，S1024物理bank容量诊断已通过；完整模块OOC因既定120s进度保护终止，状态NOT_COMPLETE，没有当前tile物理资源/DCP/时序或可发布blackbox证据。阶段结果、原日志与明确未测项见[results.md](results.md)及[机器交接](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/handoff/final_summary.json)。本模块不继续扩生产路线或重跑OOC。

以下历史整核制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

C++合同：Q[64]、K/V[S,64]、mask[S]→score/prob[S]和AV[64]；FP尾部1024→1与1028→256。

重要异常：生成QK full_run_task_33在context通过后固定E_SHAPE/elements0，不能以3–5cycles称成功QK吞吐；AV full_run_task_35也已确认同样固定E_SHAPE/elements0。源码B1/S128 QK/AV各503,316,480个乘法贡献，不能据此认定当前RTL已保留全部算术。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-attention_and_fp_engine)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/attention_and_fp_engine`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

执行完整S范围内的QK、finite mask、softmax和AV，并在attention释放后复用FP资源执行scorer F32末层及act F16首层。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 模型attention | 16head、head64；双向full/sliding有限mask | 工程事实 | 11§1、10 |
| 共享算力 | 候选64路FP；QK/AV/浮点尾层分时 | 推断 | 11§1/§5 |
| 参考顺序 | QK相邻树；AV按key升序非FMA；完整行softmax | 推断 | 11§2 |
| 缓存策略 | 当前head KV跨全部query复用；query tile16 | 推断 | 11§1/§3 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [05_hbm_loader_and_cache.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:25)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:38)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:54)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:62) | FP引擎的缓存端口、供数与加载交接 |
| [10_rope_and_mask.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:28)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:41)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:49)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md:63) | half-split RoPE、QKV就绪、有限mask及attention交接 |
| [11_attention_and_fp_engine.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:35)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:53)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:70)、[§6](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md:76) | QK/softmax/AV依赖、缓存端口、周期和共享FP尾层 |
| [13_decision_scorer_act.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:31)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:47)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:70)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md:78) | scorer/act共享FP资源、混合精度及生命周期 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:84)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | Attention联合流水、QKV交接及共享资源/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| LOAD_HEAD | 当前层QKV屏障已满足 | 加载当前head的K/V；准备Q tile | 必须确认对应shard/context |
| QK/MASK | 64维Q/K | 64项FP32乘积固定树，乘0.125再加已合并bias | 当前query全部S score到齐 |
| SOFTMAX | 完整score行 | max→exp/固定树sum→normalize | 完整prob可供AV读取 |
| AV/DRAIN | prob与V | 对每输出按key升序乘后加；交错query隐藏反馈 | 最后key退休，按8lane排出 |
| FP_TAIL | attention全部完成后 | 切换广播/归约模式供scorer/act | 前一缓存和引擎已释放 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| QKV | qkv/cache→FP | Q tile，K/V每head64F32窗口 | 一个head只从一个QKV shard读 | 下一head预取需要另一个空KV bank |
| score/prob | QK↔softmax↔AV | 每b/query有S个F32 | 固定完整行、key顺序；max/sum屏障 | QK填充→softmax改写→AV读→释放 |
| attention输出 | AV→att_out→Q8 Wo | F32[B,S,1024]，每head64结果 | 各head填回对应feature范围 | 最后累加退休后才读出 |
| 浮点尾层 | heads↔FP | F32[1,1024]或F16[256,1028]权重 | 按输入维升序，F16精确转F32 | 没有A8量化，模式切换单独计时 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- QK固定64项相邻二叉树；mask的先合并后加顺序由10保证。
- softmax对所有有限score减max、exp、固定树sum、除法；不直接换在线softmax。
- AV每输出按key递增独立FP32乘后加，无FMA；交错query不改变每输出顺序。
- 浮点尾层保持k升序、bias/GELU时点；1028维尾部不是补成Q8组。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| KV双bank | B2/S1024每head K+V1MiB，双2MiB | 当前head所有query读完才释放 | 另一shard预取不是同head带宽翻倍 |
| score/prob双bank | [2,16,1024]F32每bank128KiB | softmax原地改写，最后AV读取后空闲 | 双bank才可能重叠独立softmax |
| Q tile/AV partial | B2/TQ16时各8KiB | key累加结束前保留AV旧值 | 64路旧partial读/新值写端口必须成立 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- QK与AV共用引擎，时间相加；softmax虽可独立，但完整行和bank交接仍形成依赖。
- 专用窗口一次64F32=256bytes，不能用普通8lane的32bytes通路直接喂满。
- 若16个query交错仍不足覆盖FP加法反馈，实际II需降速并写入results。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [attention_and_fp_engine.h](../../../../hls/operators/attention_and_fp_engine.h)、[attention_and_fp_engine.cpp](../../../../hls/operators/attention_and_fp_engine.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_attention_and_fp_engine`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 整链数值 | QKV→score/bias→prob→AV；普通/极端/全finite mask | 每query有S个score/prob和64结果，逐阶段比参考 |
| 反馈与生命周期 | 不同S、随机暂停、head切换/预取 | 不乱key序、不早复用KV/score、无FP资源冲突 |
| 尾层 | scorer小输出、act1028输入及ties相关输出 | 模式和F16转换正确，与heads联合 |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/attention_and_fp_engine/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G3 exp/div函数/误差；G4FP反馈、64路窗口、RAM端口、实际II/资源；G1时钟。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

本模块接受QKTask、SoftmaxTask、AVTask、FPLinearTask四种具体类型；字段见15§12。QK/AV/两种FP Linear共享一个候选64路FP引擎，F0分任务互斥；softmax亦与它们串行调度。QKTask有head0…15、S、mask_mode和固定scale 0x3e000000；AV必须消费同一b/head/query范围的PROB/KV。

| 模式 | 读窗口／输出 | 顺序／发布 |
| --- | --- | --- |
| QK | Q_TILE rows×64，KV K[S,64]→SCORE rows×S | 每score64乘积固定树；query升序、key升序；全tile写入后READY |
| softmax attention | SCORE→PROB，length=S | 完整row max→exp/sum→normalize；原地时独占old/new epoch |
| AV | PROB[S]与KV V[S,64]→ATT_OUT rows×64片段 | 每输出key0…S-1非FMA；反馈未退不更新；末key不等于done |
| FP scorer FC2 | F32权重[1,1024]＋marker rows | k升序，输出每行1值、valid_count1，写CAND_RAW |
| FP act FC1 | F16权重[256,1028]＋ACT_INPUT | F16精确扩展F32，k1024…1027是stats，输出256值 |

Q/K/V和AV partial需要64独立逻辑feature窗口，普通8lane stream只用于加载/排出；不能用32B/clk端口假称供给256B/issue。SCORE_PROB为[2,16,1024]固定stride，当前task只处理一个b的rows；KV在整head全部query完成前不可覆盖。F0 softmax和AV均等前一个数组READY，禁止有限FIFO跨串行任务互相等待。

真实参考选择abi_replay QKV、融合attention输出及FP末层节点；原生FLASH_ATTN_EXT的K/V/mask经F16 CPY，内部score/prob不可导出，显式FP32 score/prob只能记candidate回放；按manifest的GGML ne/nb取值，不能把非连续VIEW直接reshape。对native／candidate不同归约逐阶段报告误差；直接捕获的原生quant scratch以manifest为准，内部dot/term未捕获不补造。联合测试延迟QKV最终响应、prob最后拍、AV反馈和act末4输入；task完成时确认所有64路在途结果已被保存。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_rope_q` | `ir_255 / add_2` | `native/forward_0/ir_255.bin` |
| `enc0_rope_k` | `ir_262 / add_3` | `native/forward_0/ir_262.bin` |
| `enc0_attention_fused` | `ir_264 / transpose_3` | `native/forward_0/ir_264.bin` |
| `scorer_fc2_with_bias` | `ir_1463 / linear_121` | `native/forward_0/ir_1463.bin` |
| `act_fc1` | `ir_1614 / linear_122` | `native/forward_0/ir_1614.bin` |

原生融合attention内部QK score／probability明确未捕获；native K/V/mask的F16转换和FLASH_ATTN_EXT与候选FP32显式链分开登记。此处不能把candidate生成的score/prob称为上述alias的native节点。

CLAMP会原地覆盖30个attention mask、候选计数和act概率；读取期望值必须核对捕获时点。act原始概率使用`act_probability_vector → audited_outputs/preclamp_31.bin`，不使用执行结束时已被clamp_min改写的softmax文件。32个preCLAMP真实快照仅在manifest固定CPU单线程配置下有效。scorer_fc1_with_bias是图级可见输出；单独分开的两次bias中间值若未在manifest中列出，仍为待捕获项，不推定已经分别验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对QK/Softmax/AV/FPLinear任务的模式、shape字段、来源目的region及输出数量，并在状态辅助函数中区分QKV_RAW/QKV_FINAL和SCORE/PROB。尚未关联QKV的plane/head/B/S与请求/layer完整覆盖，也未实现KV缓存完整身份、全层屏障或真实QK/softmax/AV数值链；同内容标签的对象仍须在后续接入前补齐数据身份校验。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。


## P2 A批：完整QK/softmax/AV与混合类型尾层（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据已实际读取的[原规格§1–6](../../../design_source/11_attention_and_fp_engine.md)及[task.md §12.1–12.3](../../../../hardware_agent/task.md)，由GPT-6 Astra（xhigh）核定。用户授权扩展到全部模块/完整前向；本节只冻结先行叶函数依赖，后续B/C批仍须完成。

唯一DUT新增`hls/operators/attention_full_compute.cpp`，提供task§12.3的qk_row、softmax_row、av_row、fp_scorer_row、fp_act_row。QK每score为64项相邻树，softmax对完整S固定树，AV按key升序非FMA；S桶64…1024全部支持，候选softmax长度16。scorer K1024/N1的bias在FP层末加；act F16 K1028/N256此时不加bias，后交向量GELU。native FLASH_ATTN_EXT的F16 K/V/mask及未暴露内部值仅作差异诊断，独立候选oracle生成score/prob；CPU/CSim逐位与RTL非线性工程线分开记录。

CPU/CSim/RTL的验证范围和通过门槛以task§12.2–12.3为准；DUT由Sol max实现，独立tests/full_reference.py及tb/full_*由另一Sol max维护，不改原reference和P1 oracle。A批已实现并纳入当前完整CPU/CSim验证；实际映射见本文后节，当前分阶段结论见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/11_attention_and_fp_engine.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

完整QKTask逐rows处理所有S，KV绑定同request/layer/head/B/S及QKV_FINAL来源；SCORE齐后Softmax独占转换到PROB，AV按key升序写当前head64维。ATT_OUT按head/batch/row覆盖，16head全部完成后整矩阵READY。FPLinearTask真实读取aux F32/F16及绑定bias，完整K/N计算；act FC1的post bias归向量任务。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2 A批实际源码映射与审核（2026-10-07）

唯一算术源为[attention_full_compute.cpp](../../../../hls/operators/attention_full_compute.cpp)，公开接口见[laya_full_numeric.h](../../../../include/laya_full_numeric.h)，本模块主要函数为`qk_row / softmax_row / av_row / fp_scorer_row / fp_act_row`。直接TB为[full_numeric_tb.cpp](../tb/full_numeric_tb.cpp)，独立候选参考与真实fixture由[full_reference.py](../../../../tests/full_reference.py)及[full_fixture_test.py](../../../../tests/full_fixture_test.py)维护。A批叶函数已完成CPU及isolated HLS CSim，实际范围见[results.md](results.md)；B/C真实存储、owner和完整调度继续按task合同集成，叶函数通过不发布整图验收。


## P2实际实现映射（2026-10-07）

- [full_tasks_attention.cpp](../../../../hls/operators/full_tasks_attention.cpp)：本模块当前P2实现责任源。
- [full_tasks_tail.cpp](../../../../hls/operators/full_tasks_tail.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

本模块仅把实际使用的数值cache数组接入固定访问器；数组shape、元素类型、请求/任务上下文、数值leaf、算术顺序、有效范围和发布/读取边界保持。synthesis解析到对应唯一全零global，CPU保持每Runtime独立数组。共享存储组织、初始化/回收合同和唯一64bit存储打包由kernel_wrapper及hbm_loader_and_cache统一维护，不另复制数组或增加并行算术实例。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。`full_tasks_attention.cpp`的QK任务在已完成上下文检查和owner获取后，把本次有效的`S`字节mask按键序复制到1024 B自动局部数组，再把固定基址传入未改的`qk_row`。数值叶子`attention_full_compute.cpp`保持逐字不变。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。

## 2026-10-10 单bank AV反馈投影

当前新增实验以[吞吐合同§8.6](../../../../results/compute_throughput_optimization_20261010/source/design.md)为边界：一个真实FMUL、一个真实FADD、一个同步1R1W partial bank，固定feature0及`row_local%4=0`，真实B1/S128 Encoder layer0/head0。32个投影query各按key0..127升序，C3/C4仅改变同一head内独立16query context的批大小；F从partial读请求接受到同址写回后下一次合法读接受的实际握手测量，不能直接取11拍FADD配置。product/commit各Q32、完整身份与slot epoch、反压/复位债务及单地址/多地址短例按合同核查。本微基准与旧HLS生产top分开，真实IP和RAM物理映射须分开报告。

此前[v4真实producer捕获](../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_capture_run_01/input_manifest.json)只保存head0 V；[Q/K补捕获准备器](../tb/av_feedback_prepare_capture.py)在该已核查只读副本中同一RoPE提交点增加Q/K观察，仍保留原47点×3独立比较，且不改生产controller或Q8源码。[独立gold生成器](../tb/av_feedback_make_gold.py)从同一次Q/K/V、request3实际mask调用`tests/full_reference.py`的QK与softmax，生成32×128外部prob，再逐keyF32乘法和升序F32加法生成product/partial。[同次CPU捕获](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_qkv_capture_run_01/input_manifest.json)和[gold manifest](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_gold_01/work/gold/manifest.json)已落盘；真实IP与partial bank的C3/C4功能结果见[results.md](results.md)。本微基准只核feature0和选定32个query；不可外推为完整F256或整网吞吐。

## 2026-10-11 生产标量服务连接（当前连续实施）

按[最新mission授权](../../../../mission/compute_throughput_optimization.md)及[联合合同§0.2/§8.2–8.6/§9](../../../../results/compute_throughput_optimization_20261010/source/design.md)实施，不设置逐步审核门。模块实现owner独占新增`source/attention_service.*`、`attention_exp_bits.*`及相应TB；生产owner已冻结当前完整CPU/CSim依赖闭包并解冻Attention源码，当前`full_tasks_attention.cpp`已接入下一生产身份候选；旧冻结全图结果不代签本次变更。较慢正确服务作为连接基线，后续按实际服务瓶颈、原FP/缓存配额改进；不是原F256或完整请求高吞吐证据。

`laya_attention_service(command,index,payload,epoch,result,status)`为单实例blocking标量调用，CPU03/HLS02原生成`ap_ctrl_hs`；当前为官方Vitis RTL blackbox接入改用native `ap_ctrl_chain`和全局`ap_ce`（`config_interface -clock_enable`），C signature及算术图不变。新控制封装仍待实际HLS/RTL核查。外层FullRuntime保留合法BO、owner/lease、原先TaskDone以及输出物理返回退休。服务实际保存55个u32绑定字：完整672bit NumericIdentity、三份原TaskContext、KV/SCORE/PROB/PARTIAL/ATT_OUT/QKV0/QKV1七份完整BufferRef及head/mask_mode；完整读回命令避免未使用字段被综合删除。B1及原S64..1024桶，当前实测输入固定B1S128；未测bucket保持未测。CONFIG选择合法原16row以内query范围，K/V/mask顺序完整写入才允许QK；tile内全部SCORE有效才允许softmax，全部PROB有效才允许AV，禁止跳过覆盖或预置READY。不同tile/epoch间不复用K/V债务。16row SCORE/PROB缓存使此服务能沿原QK(allrows)→SM(allrows)→AV(allrows) controller顺序接入，不需要TB送入gold score/prob。

QK保持每key完整64个独立FMUL及6层相邻二叉树、0.125缩放和原有限mask规则。AV将64独立feature交错、每feature仍key升序非FMA；首错按原feature优先/key升序排序。树/扫描的数值错误收集以原索引顺序选择首错，在阶段屏障后返回，不以最快FP返回代替首错。标量MUL/ADD共享意图、实际生成实例数及feedback均以报告/RTL为准，不能直接移用旧单bank的F13。

`attention_exp_bits`复现glibc2.39 `e_expf.c/e_exp2f_data.c`的32项数学系数表、range reduction与三次多项式图；每次binary64 RNE操作由整数实现，最后binary32 RNE含渐进下溢。系数表是原libm数学实现，不依赖模型输入/模型输出；独立gold继续调用冻结host libm。声明域为有限且≤0的score−maximum，非法域拒绝；不改独立exp路径或原基本运算检查。生产接入后CPU也须实际调用同一bits实现，不能用宿主expf代签新RTL。

输入重放明确来自同一点真实enc0/head0 RoPE提交后的Q/K/V；新[fixture生成器](../tb/attention_production_fixture.py)验证既有producer/hash、真实request/mask及原参考，完整生成128query×S128×D64的score/maximum/shift/exp/sum/prob/out及每个F32基本运算独立gold。TB仅向DUT送Q/K/V/mask和绑定记录，所有score/prob由DUT生成。真实FP基本操作用被动core端口monitor比较独立操作数/结果；idle重复的匹配计数单列，不冒称语义贡献计数。先≤120s实际pilot，正式query0..7完整K/D；成本允许才扩完整head128query，均8GiB/3600s/40Mcycles及120s真实进度停滞保护。只模块OOC24GiB/3600s；整体OOC/P&R/时序专项与板端未恢复。

生产B1路径在真实ATT_OUT FILL owner存在时使用此服务；B2及没有生产ATT_OUT owner的原独立task诊断保留原leaf。QK时从实际owner记录的max_claimed_epoch预测未来AV_PARTIAL，ATT_OUT取本层已claim的真实ref；后续实际SM/AV Context与src/dst/partial refs逐字对55word绑定校验，不能以预测代替实际校验。原owner require/acquire/cover/publish、PROB inplace lease与ATT_OUT物理写流程保持。g++显式单独编译服务两cpp；Vitis通过blackbox JSON引入C模型，普通syn.file不重复加入模型body。新生产调用候选尚未完整CPU/CSim验证，也未证明完整HLS层级唯一共享实例。

原HLS05 native ap_ce经pilot08证明仅冻结部分controller，helper/FP包装中的延迟CE仍可在停顿后前进。当前补丁用[attention_freeze_ce.py](../tb/attention_freeze_ce.py)把独立ap_ce|ap_rst送至所有实际子module，给每个原posedge块增加保留条件并给有时钟vendor aclken增加AND；同一ap_clk/ap_rst和原reset优先语义保持，不用时钟门控。补丁有独立闭包/原件和逐节点身份，新的blackbox必须绑定完整补丁闭包。实际731个寄存器/返回快照及RAM返回、metadata/FSM/valid、vendor真实返回一起核暂停/恢复；内部RAM数组通过完整gate静态覆盖与恢复后的独立gold核查，不能只靠空载或冻结FSM声称满足CE合同。

formal01在731成员基础上纳入小RAM绑定、query、output和row_phase返回，总930成员，并核实际ADD活动时reset抢占ap_ce=0。同一闭包的实际模块OOC为145 RAMB36加7 RAMB18、22DSP、10,399LUT、6,282FF、0URAM；此为一个标量服务的完整物理存储和算术成本。blackbox生成器可接受匹配闭包hash的模块OOC/RTL外部receipt，将实际297 RAMB18等价资源写入scheduler元数据并保存receipt身份；`latency=1/II=1`仍只为变时长blocking调用的导入元数据，须由实际ap_done退休，不能据此推断整head服务率。完整top唯一共享实例、整图资源fit及后续并行方案仍需分别证明。

完整head12801现已在同一冻结RTL上完成全部128query的八个16row批，57,600阶段参考值逐位通过，并保留930成员CE/复位与全部协议检查。正常计算命令合计6,816,248cycles，条件150MHz为45.441653ms/head，480个相同shape/mode的head任务须计21.8119936s；生产搬运、caller及请求完成另外收费。详细逐批实际值见[results.md](results.md)。该结果建立当前正确服务基线，后续QK跨key/query、SM服务与共享FP池优化由root/Astra按实际OOC与完整head计费集中确定；本owner不在此交付中扩展架构或启动其它head运行。

稳定[blackbox JSON](blackbox/laya_attention_service.json)与[dependencies](blackbox/dependencies.json)现引用实际CE闭包及两个外部PASS receipt。生成入口`attention_make_blackbox.py HLS_OR_CE_CLOSURE --ooc-result MATCHING_OOC_RECEIPT --rtl-result MATCHING_RTL_RECEIPT`要求receipt状态、guard退出及闭包SHA一致，physical资源按RAMB18等价写入。60项依赖包含实际36 Verilog、5个IP Tcl、10个初始化数据、四个C模型源/头、冻结CE生成器、元数据生成器及receipt；生产owner可依据[handoff](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/blackbox_handoff.json)冻结自己的接入身份。生产B1/B2边界和实际ap_done/唯一共享实例证明要求保持。

## 2026-10-15 修订16 FINAL→Attention tile 消费者实现映射

合同为项目任务 D-M004-ATT-CONSUMER-01 及 D-M004-S128-CONTINUATION-REVIEW-01，正式规格仍引用本模块既有 Attention service 数值设计及完整模型 source 绑定。生产实现为 rtl/laya_attention_final_tile_adapter_v1.sv，当前SHA 6d59c3903c2f65f473f1816c0ae4548a9afc36210be1939b86320985e5840dec；独占一套原t4_w_reader_port_v1、attention_tile_service_v1与tm1tn8_axi512_writer。命令锁存id、request/generation、NumericIdentity/55word、head/16query起点、FINAL与ATT_OUT描述符/epoch及128byte mask，核发布覆盖、failed、无源写债和地址范围后才读。K/V按64B stripe交替经服务命令4/5；Q 4096B经原reader送命令18，必须等最终成功load_done及无读债才进命令19。服务的0/1/17/2/6/18/19/20/21/OUTPUT12按真实接受、done与continue退休。ATT_OUT每八F32组包成256bit tile，按query/head地址写真实AW/W/B，行末flush及债零后换base；最终成功仅为单tile完成，不发布完整ATT_OUT tensor或释放norm。

当前控制修复使Q页尾读错即使少于64个beat也进入真实读债排空，而不等待不存在的下一out_valid；写错在debt_zero和读/组包/服务债退后关闭flush请求，再真实rearm清sticky fault，不把成功flush_done当错误出口条件。原算术/FP叶子未改。新增局部stripe 128B、输出组包32B与命令寄存器；原reader FIFO、服务银行与writer缓冲仍计入资源。真实128行producer到本消费者的单资源mux及物理路由交接未实现，不能由模拟发布peer代替。


## M007 / SM008 strict add implementation (2026-10-21)

Authority is [M007 sections3/6/10](../../../../../../../mission/M007_完整Attention高性能主干与部署闭合/contract.md) and its SM008; legacy specifications above retain historical scope. New [laya_fadd_rne_v1.sv](../rtl/laya_fadd_rne_v1.sv) is the strict finite binary32 add candidate, eight enabled-edge stages: decode, magnitude order, 27-bit GRS alignment, extended add/subtract, leading-zero/exponent selection, normalization with gradual underflow, one RNE round, pack. Complete finite operands are accepted, including subnormals and signed zero; finite overflow returns infinity for existing caller Check classification. Common CE stalls all stages and reset clears valid regardless of CE. Both input valids on one enabled edge constitute one operation.

Independent [native reference](../tb/m007_fadd_reference.cpp) uses volatile F32 ADDSS under FE_TONEAREST, FTZ/DAZ disabled and no DUT helper. [RTL TB](../tb/m007_fadd_rne_tb.sv) checks queued expected bits, latency, continuous II1, CE hold, reset flush and paired-input behavior. [Runner](../tb/m007_strict_fp_run.py) holds the M007 project heavy lock throughout each real guarded process tree; frozen source/fixture identities and all failed attempts remain in E008/R001. Same-version single-lane OOC uses the actual U55C target and 3.333ns XDC. Existing vendor IP and paired shared_fp256_v1 evidence remain unchanged; candidate integration is separately versioned.


### M007 shared dataflow and direct divider implementation mapping

Current mapping follows M007/SM008 and D-M007-SM008-AT014-01. `laya_fmul_rne_v1.sv` replaces the old6-cycle vendor u_mul in the same `laya_shared_fp256_v2.sv` per-lane position; mul credit latency is now8. No public shared interface or array count changed. The8-stage path normalizes finite24-bit significands, forms full exact48-bit product, selects final normal/subnormal precision, shifts once with sticky and performs the sole RNE before pack/output. Zero sign, rounding carry, gradual underflow and overflow are explicit. Nonfinite/Check ownership remains upstream. The legal finite domain is not narrowed.

Shared v2 keeps independent mul/add requests/responses/tags/credits. Seven QK groups128/64/32/16/8/4/4 reuse the same256 adders; AV/restore join them through group0.64mul plus64 independently consumable full-width add reservations cover R+B; actual leaf-valid and consumer handshakes drive retirement. Full replacement waits the cycle after consume. Release stops root issue while dependent adds drain and waits external phase_debt_clear; no head success is inferred. Current v1 is a paired compatibility wrapper of the same source. AT019/020/021 validate the strict closure; earlier old-vendor closure PASS/FAIL remains frozen history.

Direct `laya_fdiv_rne_v1.sv`32-stage quotient/remainder source is unchanged and is not yet the final8-lane service. Add source also remains unchanged. Independent new mul expectations use native volatile F32/MXCSR RNE with FTZ/DAZ off; shared fixtures join independent primitive expected bits and preserve the original minsub×1 tuple exactly. No DUT numeric helper generates gold.

Real QK tree/PS feedback/bank/Check caller,full head and full shared physical mapping remain separate dependencies. Single-leaf synthesis evidence does not accept route300MHz or the full array. Current exact source/report versions and actual tests are maintained in results.md and E008 summaries.

## M007 SM011 / E010 R001 final implementation

Authority: SM011 D-M007-SM011-QKAV-01. Native PS2×512×16/G256×64/context64×2048 are unique logical RAMs; score/AV-PS/prob direct aliases, original QKV/shared256 reused. Autonomous prepare/load/start locks request/generation/epoch/head/mask. QK has two4×64 Q holding groups, actual64F32 K stream, 256 products, six adjacent shared adder levels, four strict constant0.125 lanes and bias lanes252..255; max strict > in key order. AV uses actual G/V reads, one elastic product join with PS response, key-ordered shared add and acknowledged PS feedback, then real32F32 context writes.

Reset clears validity/debts, not payload RAM. Abort drains all accepted dependent operations. Completion waits real leaf/return/commit/storage debts. Public score/context read responses accepted in DONE remain visible after DONE consumption in RELEASE; new reads are denied there and true response debt delays lease release. AT017 froze the old bug, AT018/019 andnormal AT020/021 verified this fix without interface changes. Full/sliding/finite-stall/check/reset evidence remains head local. Current fixed source identities and evidence are E010/R001/current_version_evidence.json. Physical parent sharing, Decision/RoPE/softmax/16head remain successors.


## M007 SM011 / E010 R002 softmax and autonomous head mapping

Authority is SM011 D-M007-SM011-SOFTMAX-02 and metadata/divider refinements. `laya_attention_softmax_engine_v1` contains control/row metadata only. It launches 8 scores per cycle, retains existing QK max, uses shared add lanes0..7 for shift and8..18 for seven adjacent tree levels, and packs all eight semantic classes into86 of the existing96 tag bits. Four unpaired upper-tree values per64 contexts preserve adjacent order. Root shift reservations include actual pending SFU plus FP shift debt, bounded below240 vectors, so finite return/storage holds cannot create a full credit ring. Each context waits its actual read/FP/SFU/LN-write/div/G-write debts and commits before reuse.

`laya_sfu_exp8_v1` reuses the exact original glibc2.39 graph/table generated167-cycle leaves. Its real vector credit can pass only an actual reserved head return; a held return is written to that same slot. Illegal mode/domain/context/identity is rejected; TANH is not implemented. The single `laya_shared_div8_v1` serves SM3/Q5/LN6 masks,32-cycle strict direct division and real retiring numeric errors; it has no reciprocal substitution. `laya_ln_exp_storage_v1` is the only new256bank×32F32 exp/LN RAM, with synchronous held read and write-commit tags. No exp matrix is stored in metadata.

`laya_attention_qk_av_engine_v1` extracts the R001 controller without resource instances. Normal AV continuation is an explicit idle/previous-success event preserving request/QKV ownership; it is not prepare or reset and does not inject probability. `laya_attention_head_v1` owns one QKV, shared FP256, PS/G/context, LNexp, EXP8 and DIV8, plus the original four constant-scale lanes. It accepts one production head start after public QKV loading, then releases/binds phases2→3→4 only after true response/commit/Check debts. The initial prepare bind uses the accepting input identity, not the previous locked register. Public context response remains visible in final release after DONE consumption. The old resource-containing QK/AV wrapper is not instantiated and remains unchanged for R001.

Declaration-level conservative new row/tag/control accounting is3865B including retained max512B and service tags/control, below8192B; source/bit breakdown is E010/R002/metadata_accounting.json. Existing sharedFP tags6144B are counted once separately. New payload is LNexp32768B, native read registers1024B, SFU return FIFO8192B, DIV return data/error FIFO1056B. These are distinct payload/control entities, not hidden exp matrices. idle_Q alias and future LN parent are not physically wired here. Logical RTL instance uniqueness and functional cycles do not establish synthesized fit or routed frequency.

Current sharedFP phase6 extension (LN-05) changes only the two internal mul/add bypass enables to phase3-or6, SHA80f91e30e26b7f23d84b6b1972335cce5c634b4a0e2fe20b7030e2b91d472230. AT018 head binds this source; E014 independently verifies phase6 and affected1/3 behavior. AT015 softmax and AT017 head old-source identities remain distinct.


## R003 HEAD16-06 current implementation and evidence

See [current protocol](m011_r003_protocol.md), [resource extraction map](m011_r003_resource_map.json) and E010/R003 immutable attempts. Atomic bank/legacy wrapper, original cache, full/sliding RoPE and actual RoPE abort/reset recovery have scoped RTL PASS. Complete128-bit model/numeric identities are restored in AT017 onward. AT019 Encoder preparation, AT020 Decision one-head and AT021 Encoder two-head PASS; each complete head is11038cycles. AT021 actual prep36.602760062s and conservative head120.959431576s imply2366.3443983334s under the required1.2 formula, so full16 is COST_STOP_NOT_LAUNCHED. AT011/014 are preserved cost stops. AT022 finite reverse-QK reference proves head0 tile15 precedes later heads tile0; actual layer fault RTL remains NOT_RUN.

AT023 current sharedDIV8 idle-only CE wrapper PASS: original32768 pairs, II1/physical32cycles,4064 full-slot reuses;114 added gapped vectors and4276 per-return physical-latency checks, held/error, active-lease gaps, release/idle/newphase and in-flight/idle reset. Only leaf CE changes; the numerical leaf, public signature and every-cycle metadata/credit remain unchanged. New wrapper SHA8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79; old evidence stays on its original identity. AT024 affected production static build PASS30.640597467s; AT025 actual Encoder preparation pilot is running. CE runtime benefit is not yet measured. Complete16 normal/fault/recovery, all4096 public context responses/final lifecycle and physical implementation remain NOT_RUN.

Current post-AT029 continuation: full16 attempt COST_STOP at semantic_stall1171.433359447s,11 actual complete heads/noFatal/no final marker, not a numerical failure. AT030 old-identity actual finite-QK one-head PASS48.799988306s. New sharedFP channel-empty CE SHA f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0 adds noDFF and preserves every-clock credit/metadata plus original leaves/8physical cycles; FP4/FP256/dependency1-3-6/held-credit-reset static AT031–034 PASS, RTL queued. New layer TB adds only actual retirement-based progress; prior independent numeric checks and120s true-stall limit stay. No new full16 gate is claimed and no cap/budget changed.


### R004 actual implementation, pending affected regressions

Pure production implementation is rtl/laya_attention_layer_engine_v1.sv with262 resource and25 coefficient signals; rtl/laya_attention_layer_v1.sv is sole-resource/cache compatibility shell. PREP matching cancel holds identity/status in L_CANCEL, suppresses same-edge new QKV/start, invalidates only layer coverage and returns after response; public narrow writes commit on their actual accept edge. layer_idle requires real IDLE and real resource/response idle. Same12288bit coverage low4096 becomes context response bitmap after valid full start, with a new complete flag. Resident-only head uses one actual accepted-resident bit; independent compatibility retains old arrays. Packed Check planes retain exact legal maps,32bit first-conflict, no final_ready on current/sticky conflict; layer fault branch requests actual abort and waits real debt before protocol DONE.

Declaration ledger20690bit=2586.25B; A001 increment33 verified A010 profile-off side963B, so joint3549.25B/ceil3550 before any parent additions. This is source accounting, no synthesis/physical fit. AT001 pre-current-fault-edge-guard Check peer static/RTL PASS; AT002 declaration compile FAIL preserved, AT003 revised shell compile is queued behind project lock. Normal completehead/context lifecycle and layer coverage_fault drain remain NOT_RUN pending actual evidence.


### R004 original numeric and actual recovery milestones

AT009 Decision0 complete1head PASS107.852036051s and AT013 Encoder0 complete1head PASS106.647546459s use identical AT008 compiled SV/TB:11038 cycles=QK4187+SM2333+AV4508+10,16384scores/16384prob/8192context and original intermediate gold. AT011 Encoder preparation PASS32.841030504s,12288 public QKV writes and2048 atomic RoPE commits. No complete16/output lifecycle claim. All-known complete-head conservative estimate1896.541045959s exceeds R004 ordinary1200s, so full16 is not launched.

AT006 public cancellation PASS14.417050504s,24595 actual writes and5 cancel generations; AT007 resident prepared abort PASS5.514809139s, real storage binds2/resident1/wrong identity4, held abort DONE, no FP lease/release; AT010 real other-owner FP lease and256mul held credit debt while PREP cancel PASS5.497680891s, actual peer response/release and newgen recovery. AT014 QK inflight abort11.175851013s, AT015 SM inflight reset42.803005922s, AT016/017 RoPE inflight abort/reset10.710341118/11.108343676s all PASS with true debt trigger, terminal debt0 and newgen partial-coverage isolation. Complete post-control one-head recovery remains queued.

Current narrow source is engine c3e80307f5a941c1d599eb579d8bc787021d428ea42453b81d7b80e037c7a9db: only cache_owner_valid changed tostate!=L_IDLE versus tested AT008/012805e3de9… . Restoring that expression gives exact prior source bytes; interface/arithmetic/state bits unchanged. It protects coefficients throughout PREP and held cancellation; AT019 staticPASS, public rebind/load guard RTL queued. Existing frozen fullhead/recovery runs retain prior identity; no current-guard fullhead claimed. Actual interface/sha metadata and exact boundary are in R004/pure_engine_interface_current.json and coefficient_PREP_owner_guard_change.json.


### SINGLE-PARENT-11 DIV真实输出直通（R004冻结后）

唯一resources壳新增9个res_div输出（release_ready/draining/完整owner回显/reject_code/rsp_lane_mask），直接连接唯一DIV实例原先悬空口。未加FF或数值/协议逻辑；删除新增声明并恢复9个空输出连接即逐字节等R004原资源壳。purelayer/public兼容口不改，当前owned所有资源实例均显式命名接线、未发现.*遗漏风险。新SHA及逐口表见m007_parent_resource_exports.json；A007未启动EDA/不向R004计费，A010在E016新导出使用中负责实际展开与回归。R004旧SHA/原始证据冻结不回写。


### 2026-10-22 SFU共享无EDA静态交付

现有EXP/TANH源和冻结AT055匹配，未改生产RTL/端口、未启动EDA或新预算。可审查切口在m007_sfu_unification_static_20261022.md/json：单一mode-aware lease/credit/return池的候选实物账为16384B payload、27228bit metadata；相对两现服务仅在真实实现后可省8192B payload和3401bit metadata，不扣除数值图/流水。EXP可消费167拍、TANH153拍；共池必须动态167/152返回年龄与EXP旁路/TANH缓冲，不能把TANH延到168拍。TANH高15bit历史尾在真实phase切换前须清理。

现有两算术图并置的名义DSP投影1040（EXP8的768来自HLS层级估算、TANH8的272来自17通用mul×2DSP小leaf投影）；常量特殊化与同版联合实综未测，绝不是联合FAIL。量化/G外侧另计。最小新测量建议是实际32×32 partial-product映射，再F64mul六文件闭包；现成F64add0DSP、TANHmul4为2DSP/add3_e和div12为0DSP的小leaf证据有版本/约束边界。没有完整EXP或联合8lane物理证据；G/E016不以新SFU物理方案为前置。审计脚本存tb/m007_sfu_static_audit_20261022.py，后继实现/EDA由A001另定合同。


## E017 helper测量边界（2026-10-22）

按SM011 SFU-RESOURCE-12只读测量rtl/strict_exp_ii1_167的两个整数helper及后续F64mul六文件闭包。实际F64实例宽度32×32/50或64；原helper的ID与NUM_STAGE只出现在参数声明，不影响行为；reset只在端口声明，CE1更新/CE0保持。新测量TB/runner在tb/m007_sfu_*，证据在E017，未接入生产资源。synth+opt完整IO约束与功能分开记录，不修改数值/接口/credit，也不实现公共SFU池。

## M007 CONTROL-ARENA-16 / E018 R001 (2026-10-22)

The pure layer and G math now accept optional EXTERNAL_CONTROL modes. Both local and external elaborations use one next-state algorithm. Layer exports its12288-bit QKV/context-consumption coverage next; G exports all11343 bits from AT133's control census with fixed version1 field offsets in project/E018_m007_control_workspace_joint/experiment_source/g_control_layout_v1.json. The low-to-high layout follows the AT133 census entry list, including each original array's ascending element indices; it does not sort by current source line numbers. Numeric payload25600B, fixed numeric alignment736B, pre_credit internals, pairs/pool and engine private state remain independent.

laya_m007_control_workspace_v1 owns the sole packed state_q[12287:0], owner_g and rearm. A uses the full view; G uses low11343 and clears unused high945. Same-owner requests do not clear. A different-owner handshake requires actual current retirement and the target's private controller idle, enters exactly one disabled REARM cycle, then enables the target. The production joint wrapper wires safety to actual layer/head/RoPE and G/pairs/math/precredit/bank state, never inactive q interpretation. Pending prepare/cmd excludes retirement to avoid simultaneous admission and switching. No identity is copied and clocks remain ungated.

The declared combined account is3746B +1707.625B -11343/8B +2/8B =4036B, leaving60B. This is source-declared functional architecture, not synthesized fit. No head/RoPE temporary state, persistent Check, cache or matrix state is borrowed. The frozen A010 Attention parent result is not relabeled for these changed dependencies.

Local integration tests perform real PREP/native QKV writes/cancel and G arithmetic only. They do not launch Attention arithmetic and cannot prove normal16head-context-release to G handoff. Full FFN/30layer integration and joint physical resources/timing remain separate. See E018's protocol, three summaries and R001 actual receipts.

## M007 G-CANCEL-17 / E018 R002 (2026-10-23)

G engine/joint pass-through now carries identity-matched producer_cancel and independent done_cancelled. Three new FF bits preserve accepted-cancel state and published stalled bank read/write requests. The caller holds committed fill payload until ready; uncommitted successor fills reject after cancellation. Every actual bank/FP/SFU/precredit/output debt must drain before qualified DONE; DONE consumption still requires explicit matching pair discard before new generation/owner retirement. Matching uses existing rsp context, without a128-bit identity copy. Status8/6/0 is preserved but cancelled never means full success or global numerical coverage. Parent Wi errors remain authoritative.

Math11343-bit layout/workspace12288-bit mapping and numeric resources are unchanged. Current declared control4036.375B/byte ceiling4037B/59B margin includes exactly3 additional FF on accepted R0014036B. No synthesized/physical resource result is inferred. Detailed protocol/current source identities: E018 experiment_source/protocol_r002.md and experiment_results/runs/R002/final_delivery.json. R001 generators and evidence remain historical, not a script to overwrite the current cancel interface.


## E018 R003 CANCEL-END-19 (2026-10-23)

R003 changes no production RTL or interface. Current AT021 TB permits needs_discard only for cancelled mode2 and retains all other real-debt/numerical checks; original full terminal candidate cancel wins over normal publication. Existing qualified DONE requires actual consume then explicit discard before owner retirement. Total3 cancel FF and joint4036.375B remain. Evidence: project/E018_m007_control_workspace_joint/experiment_results/runs/R003/final_delivery.json and attempts/AT004_final_release_audit/work/report.json.


## E019 R001 RESIDENT-RESIDUAL-21 (2026-10-23)

New resident components implement32x4096F32 hidden synchronous1R1W, one13-bit-control/128B held return, borrowed-parent identity wrapper, soleQKV plane0 public-port scratch lease/half adapter (1 owner bit), and fixed4096vector phase7 group0 sharedFP ADD provider (48 private control bits/no payload/identity copy). Atomic joined reads preserve H+Q operand order; actual H commits and service release qualify held DONE. Parent qualification inputs remain external and must be wired to real layer/matrix/quant retirements. Current total added control62bit/7.75B; no future VECTOR overlay deduction. See E019 experiment_source/interfaces.md/state_census.json/protocol.md. Evidence: project/E019_m007_residual_ln_residency/experiment_results/runs/R001/final_delivery.json.

## M007 JOINT-ARENA-23 resident production composition

Authority: `source/m007_residual_encoder30_20261023.md` §§10–11 and SM011 D23. New `laya_m007_resident_joint_v2` contains one pure four-consumer joint/12288-bit arena, one unchanged physical resources_v1, one coefficient cache/G pool/TANH, hidden32 and Q-plane scratch alias, and a33-bit residentLN provider. No wrapper sequential state or payload copy. Five external service selectors independently route FP, DIV, ST bind/op, PS and context so matrix PS can overlap G-bank traffic. The public header/port responsibility manifest lives in E019 experiment_source. H/Q expose real synchronous held responses and same-edge commit. Provider finite witness is produced only by consumed successful VECTOR DONE with4096 issued/retired and actual H idle; public H writes/new VECTOR start invalidate it and provider DONE consume retires it. Parent owns complete load/projection counters and stable identity/epoch lease sequencing.

LN binding is actual verified v3 core2a9760/layout12128 in the sole arena. A/G/V remain12288/11343/48 bits, reserved bits cleared. Current wrapper start valid and ready both require resident owner and scratch lease. A layer_idle is a q-independent private FSM plus actual service probes, valid when inactive after required enabled retirement. Full production behavior remains under guarded E019 R002 tests; functional validation does not establish implementation timing or4KiB physical fit.


## M007 CE-JOINT-COST-27 / E019 R003 production delta

The465-port header stays7c9181. Current resident_joint_v2 body6f7363b6 adds module-body compile parameter TANH_FORCE_CORE_CE=0 and forwards it to the sole laya_m007_tanh8_v2 FORCE_CORE_CE. Defaultauto0 or explicitforce1 are separate compile configurations; no runtime selector/FF. Accepted D26 core13df84ea and wrapper8c37896c use existing leaves/credit. Exact inverse of those two edits restores52ff; all other shared state/resource/provider wiring is unchanged. Current actual source/build/auto0 proof for parent consumption: E019/R003/production_bundle_checkpoint_v1.json. No new full128/parent/physical claim.


## M007 TYPE-RESIDENT-29 / E019 R004 production v3

New475-port joint_v3 body0f4318fc16afa6173bd28023eb5feba95c7d4aecc77bd31545d19865e5554f69/header9e835f48836920aede1b5b6acb6acdd546ddee8f05d4f809ce656e5cd8dcd625 instantiates one typebank96x32F32/13control+128Bholding and external48 VECTORv3 op1 Q+type→H using states5–7. Oldv2/body6f and all65 prior sources unchanged. One existing source_witness receives qualified H_LOAD valid through existing access owner identity, parent4096finite-commit guarantee and actual H idle. Wrapper has0newFF and cannot detect arbitrary early matching pseudo-events. Actual default remains TANHv2/FORCE_CORE_CE0. Source-bound parent handoff: E019/R004/production_bundle_checkpoint_v1.json.


## D32 source-only sole TANH8v3 integration (2026-10-23)

Current production joint_v3 changes exactly one instantiation name from laya_m007_tanh8_v2 to laya_m007_tanh8_v3; no other body byte changes. Body SHA ac9a92fc995f9b40b1bf0284fd2490679492bba65eba6065390703873b79e229, same475-port header SHA9e835f48836920aede1b5b6acb6acdd546ddee8f05d4f809ce656e5cd8dcd625, FORCE_CORE_CE default0. D31 core59f29c46 and wrappera09ad675 plus the four unchanged leaf/credit dependencies are source-verified; wrapper normalizes byte-for-byte to v2 after module/core version names. Exact inverse restores D29 body0f4318fc. The actual D29 TANHv2 source is preserved under its AT011 frozen tree, with all D29 archives/bundle/receipts and old65 files unchanged. New current source is SOURCE_ONLY_NOT_COMPILED_NOT_JOINT_TESTED; A010 owns R007 compilation, actual unique-resource census and affected joint normal type or G/LN checker. No new numeric/cycle/speed/fullmodel/physical claim. Authoritative source-only diff/dependencies/cost manifest: E016/R007/d32_joint_tanh3_source_integration.json. Source step process wall0.871820083s is billed once to R007 static; D29 closed budget untouched. No A007 EDA or heavy queue.
