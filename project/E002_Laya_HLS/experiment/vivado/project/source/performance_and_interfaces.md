# 当前 F0：接口、成功执行工作量与条件性能估算

核查日期：2026-10-08。适用 build tag：`04934c15b3f83e842ec2e92ac2a81bf2`；顶层 `laya_typed_q8_forward`；器件 `xcu55c-fsvh2892-2L-e`。本文主体记录该旧制品的冻结模型、HLS RTL/调度报告、CPU任务计数与Vivado OOC；页首后续修复进展单独按新证据更新，旧表格不迁移到新身份。

## 后续修复进展：功能与性能均未验收

2026-10-08后续D0已将QK/AV固定错误追到上游：原链接IR含合法QKV pair写回及binary vector第二来源；gdce至lto/reflow后，QKV Linear的nullable pair存在性变成恒否，load成功后固定E_INTERNAL/detail0x07000004，Residual/Type的src1也变NONE并丢失第二bind。具体内部pass/base=0机制尚未证实；不能只把它称作QK算术leaf自身的问题。

[新修复合同与D1/D2门槛](../../../results/attention_rtl_repair_20261008/repair_contract.md)规定用显式presence与reference保留原guard/owner/数值语义，先做隔离A/B的真实生成RTL自检，再验证生产数值联合链；当前尚未完成修复验收。[独立D0证据](../../../results/attention_rtl_repair_20261008/reviewer_root_cause_d0.json)单独保存，不回写本报告所引用的旧performance/OOC证据。功能恢复和后续并行架构改造分开执行；50ms仍为用户A6000对照目标，目前没有U55C达标证据。

D1后续已完成：[独立审核](../../../results/attention_rtl_repair_20261008/reviewer_d1_review.json)确认原写法CPU/CSim120项通过，而RTL15条事务有6条控制语义错误；显式presence版本的Verilog/XSim120项通过，15条输出全部逐byte一致。P1/P2/P3已放行迁入生产。该小top使用公开的load/bind/issue probe stub，只证明控制表示修复；D2真实数值/owner与完整top仍需各自证据，性能架构没有因此变为并行或达标。

正式`Laya-baseline`已应用经审核的P1/P2/P3，controller SHA256为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`。[正式新包](../../../build/model-attention-rtl-repair-20261008/manifest.json)的build tag为`fe067c8aa0627ad770096f9721394645`，[新CPU门禁](../../../results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)已有141检查点及故障恢复通过；新B2/S128真实13口标准libm CSim已另run执行通过；D2-R/I及完整RTL仍待相应证据。隔离副本的新tag为`18366c267ae0a7ca0c3afb8c2174b890`，不能作为正式工程身份。本文下方旧04934 RTL/IP/OOC资源与调度没有包含新补丁。

[已有A6000实测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/results/laya_gpu_inference_benchmark_20261005.md)为常驻SDK/BF16 autocast，两题B2/S94、K_pad3的P50/P95为25.047/25.224ms，单题约23.676/24.200ms；不同于当前Typed-Decisions Q8_0/F32 R0、S128/16候选。50ms保留为用户对照目标，24–25ms是已有不同场景的背景，不是同模型同精度比较。完整SDK、驻留forward与FPGA kernel/Host边界必须分别对齐，详见[合同§1.1](../../../results/attention_rtl_repair_20261008/repair_contract.md)。

下一性能工程已具体化为[TM4/TN8联合Q8原型§4.4–4.7](../../../results/attention_rtl_repair_20261008/repair_contract.md)：真实BO装载、完整K/N、8lane量化、W/A/PS banking、R0恢复/反馈、背压与输出退役一起验证；已获[独立设计审核](../../../results/attention_rtl_repair_20261008/reviewer_joint_q8_prototype_design_review.json)，尚未放行实施。扩大整数lane同时增加FP恢复通道与缓存端口，不能由峰值MAC直接保证50ms。

[D2最新分项记录](../../../results/attention_rtl_repair_20261008/d2_attention_slice/source/results.md)已有官方完整CPU、综合存储宏路径、真实13口B2/S128标准libm CSim（47检查点/9047192 F32/37158任务）及首个B1/S64 Attention切片CSim通过记录。CPU/宏路径和[新top CSim](../../../results/attention_rtl_repair_20261008/reviewer_d2_c_full_top_csim_review.json)均已有独立接受记录；这些均不等于生成RTL成功。

最新[AXI分配诊断](../../../results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/source/results.md)已完成一次idle和一次traffic：idle在100000时钟、零AXI交易且transfer构造计数固定28时，自身RSS由146652增至1765660KiB；10000–100000时钟区间实测约16.1876KiB/clock，仅为该环境的观测斜率，不能当全DUT严格上界。traffic在首笔B的独立计数/字段观察不一致处触发fatal，虽工具exit0仍判INVALID，完整交易/排空比较未完成。根因尚未定，后续聚焦重复clock wait/delayed-loop机制；预置QKV源码/严格CPU准备优先推进，新的数值RTL仍需门控。见[独立终审](../../../results/attention_rtl_repair_20261008/reviewer_d2_axi_allocation_observation_review.json)。

D2-R v2两次XSim分别在420.801s、735.542s触发8GiB/16GiB任务树RSS守护，采样峰值8393560/16778056KiB；均为0/1事务、输出TV为空，内存增长的实际运行阶段尚未定位，既无数值失败结论也无通过结论。主机资源停止不能解释为FPGA片内容量不足或推理时延。v3仅调整该诊断用例AXI depth为AUX128B、每QKV10240064B、ATT_OUT4100B，保留全部实际访问和64B QKV尾哨兵；生产FullMemory容量与host完整数组不变。未回传高尾不能当RTL验证证据，实际返回前缀须独立raw-TV核查。v3 CSim/csynth/setup/xelab及[实际生成绑定门禁](../../../results/attention_rtl_repair_20261008/reviewer_d2_r_depth_v3_rtl_gate.json)已通过，第三次受控XSim在594.031s达到16GiB树RSS预算，峰值16781384KiB、0/1事务、五份输出TV为空，[独立终态](../../../results/attention_rtl_repair_20261008/reviewer_d2_r_depth_v3_final_review.json)仍为无数值结论；[小模型12项诊断](../../../results/attention_rtl_repair_20261008/reviewer_d2_xsim_small_memory_review.json)已独立接受，64KiB完整模型测试自身RSS由83908增至86312KiB，其范围不能外推为全DUT上界；唯一§7.9窗口已结束，完整环境阶段/AXI队列/RSS观测见本段后文。D2-I v2向量CPU末例的首差已定位为测试台误读ACT_LOGITS；v3仅修正CAND_MASKED物理读址，未改生产/gold/断言，[独立CPU审核](../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_cpu_review.json)接受I-L 589824及I-V 196624个F32比较，两路[standard-libm CSim](../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_csim_review.json)亦已独立通过，两路局部csynth及[生产IR/RTL可达路径审核](../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_synthesis_ir_review.json)已独立接受，确认pair与src1的真实数值/owner路径保留；这是生成结构证据，尚无这两路数值RTL执行。两路HLS均报告−0.31ns估算slack，150MHz未闭合；完整top HLS仍未放行。 [进度逻辑补充核查](../../../results/attention_rtl_repair_20261008/reviewer_d2_r_progress_phase_correction.json)明确：117000是reset后首打印，后续间隔1000万周期，实际内存增长阶段随后由[唯一§7.9阶段窗口](../../../results/attention_rtl_repair_20261008/reviewer_d2_phase_probe_v5_observation_review.json)定位：七口初始化已结束，真实kernel已start并至少运行220000个reset后时钟；RSS由reset时589772KiB升至4372956KiB，已有AXI传输持续完成，采样队列长度均≤1。窗口因180s时限停止，末次队列批次部分缺行，五份输出仍为空；具体分配/对象或事件保留根因尚待定向诊断。

## 1. 先看当前性能结论

**新增RTL异常：当前生成QK和AV任务在context检查通过后仍固定返回 `E_SHAPE`、输出elements=0；因此现有RTL完整成功推理路径不能成立。** 这一点由实现采集与独立审核共同核验，详见[§9](#rtl-anomaly)。完整OOC综合成功和CPU/CSim数值通过仍是各自范围内的事实，但不能据此宣称现有生成RTL可以完成整网推理。

**若按当前C++完整成功图执行，并保留现有串行Q8算术leaf调度，按150MHz换算，仅Q8 Linear的组内点积、scale恢复和跨组累加就需要B1/S128约29.31–32.59分钟，B2/S128约58.62–65.17分钟。** 这是有 HLS 循环调度依据的**算术分量区间**；整网还要加其他算子、片内复制、控制和外部存储等待，因此不能把区间右端当成整网最坏延迟。当前没有FPGA成功推理实测时间；现有RTL可能提前报错，不能把本表称为其实际请求延迟下界。

| 当前请求 | Q8 INT8 MAC 数 | 仅整数点积的周期下界 | 点积下界 @150 MHz | Q8 group 算术小计 @150 MHz |
| --- | ---: | ---: | ---: | ---: |
| B1/S128（任一道重基题） | 47,160,754,688 | 235,803,773,440 | 1,572.03 s = 26.20 min | 1,758.70–1,955.21 s = **29.31–32.59 min** |
| B2/S128（一次请求两题） | 94,321,509,376 | 471,607,546,880 | 3,144.05 s = 52.40 min | 3,517.41–3,910.41 s = **58.62–65.17 min** |

150 MHz 是当前 6.667 ns 综合时钟请求的近似换算值，不是上板确认的 Fmax。若实际频率为 `f MHz`，表中时间乘 `150/f`。该外推以合法数据成功执行完整源码图为前提，并假设修正完整路径不会改变Q8 leaf调度；错误提前退出不算成功推理性能，修复若改变调度则必须重算。

该成功执行预算较慢的直接原因是已生成 Q8 算术 leaf 每 32 项点积用 **160 cycles**，加 scale 与浮点累加后每 group **179–199 cycles**，循环没有 pipeline。`TM16/TN8/GS32` 是当前数组/窗口组织，不能读作 16×8×32 个乘法每拍并行。两个映射出来的 `compute_one` 实例被同步控制流调用，不能据此把时间除以二。旧文档中的 64 路 FP、4096 整数贡献/拍以及亚秒级候选预算属于早期未实现方案。

## 2. 证据身份与计算口径

| 证据 | 本文采用的内容 |
| --- | --- |
| [冻结模型 manifest](../../../build/model-repair/manifest.json) | 模型 SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，实际 K/N、dtype、物理 BO 大小、122 张 Q8 矩阵及另外两张浮点矩阵 |
| [模块登记](../../../config/full_module_registry.json)、[完整 controller](../../../hls/control/full_forward_controller.cpp) | 15 个功能模块的责任源、完整 28 Encoder＋2 Decision＋Scorer/ACT 调度；登记文件的历史 pending 字段不作当前验收状态 |
| [现行任务计数](../../../results/performance_estimate_20261008/trace_observed.json) | 当前身份真实 CPU B2 与两次 B1 的 observed op counts；它们不是硬件周期计数 |
| [重建逐任务表](../../../results/performance_estimate_20261008/task_schedule_reconstructed.csv)、[重建核对](../../../results/performance_estimate_20261008/task_schedule_reconstructed.json) | 从源码静态重建 layer/head/row/K/N；74,948 行覆盖 B2＋两次 B1，35 类 op 聚合逐项等于当前 observed counts。原 trace 没有逐任务时序，不能把重建表称为采样事件轨迹 |
| [HLS 循环事实](../../../results/performance_estimate_20261008/hls_reports.json)、[原 Q8 报告](../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/p_anonymous_namespace_compute_one_csynth.rpt) | 使用具体循环 iteration latency 和实际合法 trip count；不把通用动态循环的巨大 max 或错误路径的 min 当成 S128 推理时间 |
| [实际外部 RTL 端口](../../../results/performance_estimate_20261008/rtl_external_interfaces.json) | 当前完整顶层 13 个 32-bit AXI 数据口、64-bit 地址与两套 AXI-Lite 控制口；顶层 RTL SHA `64fbd56f27dedee31d99d71b5039164f780dd27d76126d78f6f5dbafd963364b` |
| [完整 OOC 结果](results.md)、[映射层级摘录](../../../results/performance_estimate_20261008/vivado_hierarchy_selected.json) | 当前映射资源与真实实例；父层级包含子层级，不能重复相加 |
| [可复算权重工作量](../../../results/performance_estimate_20261008/model_weights_q8_work.json)、[采集入口](../../../tools/collect_performance_facts.py)、[证据索引](../../../results/performance_estimate_20261008/evidence_index.json) | 逐矩阵工作量、源/报告哈希及只读采集过程 |

单位：1 MAC 表示一次乘法加一次累加，若换算算术操作数可记 2 ops；Q8 dot 的 INT8 MAC 与后续 FP32 恢复分别计，不把它们混成 DSP 数。GB/s、GMAC/s 用十进制；KiB/MiB 用 1024 进制。算力表中的每拍服务率是特定 leaf 在执行时的条件速率，不等于整核持续吞吐。

## 3. 顶层真实外部端口

<a id="external-ports"></a>

以下方向以 FPGA kernel 为参照。所有 `m_axi_<bundle>` **实际数据宽 32 bit、地址宽 64 bit**。C++ 的 `uint8_t*` 是软件寻址元素宽；`max_widen_bitwidth=512` 是允许工具采用的最大宽化值，当前 RTL 没有生成 512-bit 数据口。

| AXI bundle / Host 参数序号 | 逻辑输入/输出 | 保存内容及数据格式 | 主要使用方 |
| --- | --- | --- | --- |
| `embedding` / 0 | 读 | Token/Type Embedding 的 Q8_0：每组 32 个 S8＋1 个 F16 scale | Embedding |
| `io` / 1 | 读、写 | ABI 请求、I32 token/marker、U8 mask、题型；384 B 结果帧 | Wrapper、输入解析、结果提交 |
| `w_q0` / 2 | 读 | Q8 权重 S8 的偶数 8-column tile 分片 | 权重 loader |
| `w_q1` / 3 | 读 | Q8 权重 S8 的奇数 8-column tile 分片 | 权重 loader |
| `w_scale` / 4 | 读 | Q8 权重每 32 项一个 F16 scale | 权重 loader |
| `aux` / 5 | 读 | 模型头、LN gamma、RoPE 表、bias、F32 Scorer FC2、F16 ACT FC1 等 | loader、尾部浮点路径 |
| `state0` / 6 | 读、写 | F32 hidden、归一化/marker/type/head 等复用区域 | LN、Linear、残差、尾部 |
| `state1` / 7 | 读、写 | F32 hidden 与临时数据的另一工作区 | 同上 |
| `qkv0` / 8 | 读、写 | F32 Q/K/V 分片 | QKV Linear、RoPE、KV loader、Attention |
| `qkv1` / 9 | 读、写 | F32 Q/K/V 另一分片 | 同上 |
| `ff0` / 10 | 读、写 | F32 FFN 宽向量及阶段复用区 | Wi/FC1、GEGLU/ReLU、Down/FC2 |
| `ff1` / 11 | 读、写 | F32 FFN 另一工作区 | 同上 |
| `att_out` / 12 | 读、写 | F32 `[B,S,1024]`，每 head 写 64 个 feature | AV 写、Wo 读 |

“逻辑读”不表示生成文件没有 AW/W/B 引脚；工具生成的 AXI adapter 仍声明完整 AXI 通道，生产源码对五个模型 BO 只读。实际信号方向：`ARADDR/ARVALID` 由 kernel 输出，`RDATA/RVALID` 由外部输入，`RREADY` 由 kernel 输出；写通道的 `AWADDR/WDATA/WSTRB/WVALID` 由 kernel 输出，`BVALID/BRESP` 由外部返回。AXI 的 `VALID/READY` 可背压。

| 其余实际顶层接口 | 位宽与职责 |
| --- | --- |
| `ap_clk`、`ap_rst_n` | 1-bit 输入；时钟、低有效复位 |
| `s_axi_control_*` | 32-bit 数据、4-bit 地址；`ap_ctrl_hs` 的 start/done/idle/ready、auto_restart、中断控制寄存器 |
| `s_axi_control_r_*` | 32-bit 数据、8-bit 地址；13 个 64-bit BO 基地址，拆成低/高 32-bit 寄存器 |
| `interrupt` | 1-bit 输出，完成/就绪中断 |

控制寄存器原文见 [control RTL](../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward_control_s_axi.v) 与 [pointer control RTL](../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward_control_r_s_axi.v)。实际 `.xpfm` 平台连接、HBM bank 分配和板级复位/时钟尚未验收。

### 带宽上限与有效吞吐

150 MHz 下，每个 32-bit 口单向数据通道的原始峰值为 `4 B × 150M = 0.6 GB/s`。13 口同时传输的算术合计是 7.8 GB/s；当前同步代码、读写依赖、端口角色和平台互连没有证明能同时达到该合计。读写各有数据通道，也不能无条件把峰值再翻倍。

[full_read/full_write](../../../hls/common/laya_full_memory.cpp) 按 `uint8_t` 循环访问，F32 读写也先拆成 4 个字节；源码配置 `num_read_outstanding=1`，可写口 `num_write_outstanding=1`。目前没有 AXI beat/burst 波形统计，**不能假定每个 32-bit beat 都有效携带 4 个相邻源字节**。用 `BW_useful = 0.6 GB/s × η` 表示某口有效带宽，`η` 包括 byte packing、burst、空拍、响应与平台停顿，当前未实测；如果恰为每拍一个有效字节则只剩 0.15 GB/s，这仅是条件例子。

## 4. 15 个功能模块：逻辑输入、输出、算术职责

**本表描述C++实现与CPU/CSim成功合同，不等于每一项均在生成RTL中保留了成功数值路径。QK/AV生成特化边界必须结合§9异常记录阅读。**

这是功能划分，不是 15 个互相独立、各有 AXI 的硬核。`common`、`memory_map` 等会内联或分散到多个 helper；同一功能也可能生成多份专用实例。表中的 tile 最大 16 行，`S` 是请求物理长度，当前整图证据是 S128。

| 模块 / 当前设计 | 逻辑输入（格式/形状） | 逻辑输出 | 当前算术/服务行为 |
| --- | --- | --- | --- |
| <a id="module-top"></a>[top](../../module_design/top/source/design.md) | `FullRuntime`、13 BO，B∈{1,2}、S∈{64,128,256,512,1024} | 一次整网完成状态与结果 | 整合完整图；没有额外矩阵算力。当前整图只有 S128 功能运行证据 |
| <a id="module-common"></a>[common](../../module_design/common/source/design.md) | identity、typed task、BufferRef、数字格式/枚举 | 参数校验、任务上下文与转换结果 | 公共 helper；F16/F32 转换、边界检查等在调用处产生硬件，无独立 MAC/s 指标 |
| <a id="module-kernel_wrapper"></a>[kernel_wrapper](../../module_design/kernel_wrapper/source/design.md) | [13 AXI 口与两套 AXI-Lite](#external-ports)、时钟/复位 | AXI 写出、完成/中断 | 解析请求、绑定持久 runtime/cache；瓶颈可来自 byte 访问与事务延迟，未测请求 II |
| <a id="module-forward_controller"></a>[forward_controller](../../module_design/forward_controller/source/design.md) | 已核验请求、模型 descriptor、owner 状态 | typed task、task done/check、下一阶段 | `issue→full_run_task→check_done` 同步串行；B1 18,895 tasks，B2 37,158 tasks；无跨任务 DATAFLOW 重叠 |
| <a id="module-memory_map"></a>[memory_map](../../module_design/memory_map/source/design.md) | BO、byte offset、shape、region、BufferRef/epoch | 地址、合法 span、读写数据或错误 | 地址和边界/复制服务；没有独立算术阵列。F32 元素外部读写经 4-byte 组装 |
| <a id="module-hbm_loader_and_cache"></a>[hbm_loader_and_cache](../../module_design/hbm_loader_and_cache/source/design.md) | 当前 WeightKey、HBM Q8/scale/bias、QKV、LN/RoPE | 当前整张权重 cache、K/V cache、参数 cache 与 READY 状态 | 每请求 122 次 LOAD_W；一次装当前矩阵后遍历全部 B/row。当前最大 Q8 cache 5,373,952 B＋335,872 B scales；没有整模型常驻片内或双缓冲计算重叠 |
| <a id="module-embedding_engine"></a>[embedding_engine](../../module_design/embedding_engine/source/design.md) | I32 token/type ID；每 1024 维 Q8_0 行 1,088 B | F32 `[rows≤16,1024]` 写 hidden/type 区 | 每行 32 次 F16 scale 转换、1024 次缩放；内层 8 cycles/元素，无并行 1024-lane 查表 |
| <a id="module-layernorm_engine"></a>[layernorm_engine](../../module_design/layernorm_engine/source/design.md) | F32 `[rows≤16,1024]`；Embedding/Final 路径有 gamma[1024] | 同形 F32、统计检查/错误 | 完整 1024 行均值、方差、sqrt/reciprocal、归一化。每行两棵各 1023 加法的树按循环执行；不是每拍整行 |
| <a id="module-activation_quantizer"></a>[activation_quantizer](../../module_design/activation_quantizer/source/design.md) | F32 `[rows≤16,K]`，K≤4096 且32倍数 | S8 `[rows,K/32,32]`＋F16 scale `[rows,K/32]`，A8 READY | 每 group 32 次 abs/max 扫描，再32次缩放/舍入；报告扫描 3 cycles/元素，量化内循环 3–8 cycles/元素；`input_lanes=8` 元数据不表示生成8并行lane |
| <a id="module-q8_linear_and_restore"></a>[q8_linear_and_restore](../../module_design/q8_linear_and_restore/source/design.md) | A8/scale tile；当前矩阵 W8/scale；bias；K/N | F32 `[rows,N]`，QKV时按 plane/head 散写 | 实际窗口最多16×8；每输出 K/32 个 group串行，每group32 INT8 MAC＋FP32恢复/累加。160 cycles/dot；179–199 cycles/group；leaf有效24.12–26.82 MMAC/s@150MHz |
| <a id="module-rope_and_mask"></a>[rope_and_mask](../../module_design/rope_and_mask/source/design.md) | 每head Q/K F32[64]，cos/sin[64]，position；mask[S] | 原位置回写 Q/K；QK 评分时加 pad/local bias | 28 Encoder 做 Q和K RoPE；2 Decision 不做RoPE。RoPE每向量128乘法、64加/减；mask不会跳过QK/AV的key计算 |
| <a id="module-attention_and_fp_engine"></a>[attention_and_fp_engine](../../module_design/attention_and_fp_engine/source/design.md) | Q[64]、K/V[S,64]、mask[S]；尾部F32/F16权重 | score/prob[S]片内、AV[64]；Scorer标量、ACT[256] | QK每query计算S×64乘法与S×63树加法；AV每query为S×64 FP乘加；softmax处理全S。F32 Scorer FC2：1024→1；F16 ACT FC1：1028→256。当前无64-lane FP吞吐承诺 |
| <a id="module-vector_and_ffn"></a>[vector_and_ffn](../../module_design/vector_and_ffn/source/design.md) | GEGLU F32[5248]、ReLU[4096]、残差两组[1024]、bias-GELU[1024或256] | 分别F32[2624]、[4096]、[1024]、同长向量 | GEGLU每输出1次GELU＋1乘法，GELU含6乘法、2加法及tanh；ReLU比较/选择；残差逐元素FP加；矩阵计算归Q8模块，不重复计 |
| <a id="module-decision_scorer_act"></a>[decision_scorer_act](../../module_design/decision_scorer_act/source/design.md) | 2层Decision hidden、16 marker位置/mask、CLS[1024] | 候选logits[16]、ACT logits[2]；内部stats[4]与ACT input[1028] | 复用Q8、FP、LN与vector；自身负责gather、mask、概率统计、concat。每题执行16候选，即使部分mask无效也不会跳过前段Scorer计算 |
| <a id="module-result_status"></a>[result_status](../../module_design/result_status/source/design.md) | 每题16候选＋2 ACT F32、identity、状态/诊断 | io+16384的固定384 B请求结果帧 | B1有效18个、B2有效36个F32；先payload/诊断后提交头；主要为读写/控制，没有矩阵MAC算力 |

数值格式与函数形状可逐项核对 [laya_full_numeric.h](../../../include/laya_full_numeric.h)、[laya_full_runtime.h](../../../include/laya_full_runtime.h)、[实际模块源清单](../../../config/full_module_registry.json)。接口的任务成功/READY/owner状态还需要完整typed-task边界；算术leaf返回成功不单独发布缓冲区或退休任务。

### 4.1 实际生成内部RTL端口与存储接口

<a id="generated-ports"></a>

原始证据见[15模块实际RTL映射/端口JSON](../../../results/performance_estimate_20261008/logical_module_interfaces.json)，包含每份RTL路径、SHA和端口方向/位宽；以下为便于阅读的代表端口，不是完整pin列表。表中模块名省略公共前缀 `laya_typed_q8_forward_`；`in/out` 均相对于该RTL module。

普通非内联HLS函数采用`ap_clk/ap_rst/ap_start`输入、`ap_done/ap_idle/ap_ready`输出，均1bit；内部`ap_rst`为高有效，顶层`ap_rst_n`为低有效。RAM读口通常是**out address/ce、in q**；RAM写口是**out address/ce/we/d**。因此一个输入数组对应的地址信号也可能是out，不能把“地址out”误读为算子数据输出。它们是共享片内RAM/寄存器连接，不是每个模块新增一套外部AXI或AXI-Stream。部分返回字段还有`*_ap_vld`有效信号。

| 功能模块 | 实际代表RTL边界 | 已生成的代表输入/输出与宽度 | 物理解释/限制 |
| --- | --- | --- | --- |
| top | `laya_typed_q8_forward` | 外部AXI数据32、地址64；控制32/4及32/8；clk/reset/interrupt1 | 同一个集成top，详见§3 |
| common | 无单一独立边界 | 数值/任务helper字段内联或散布在调用者 | 不能为目录虚构一个总线或独立吞吐 |
| kernel_wrapper | 与top相同 | 与top同一组622个声明端口信号 | top与wrapper不是两套13口硬件 |
| forward_controller | `full_execute_request`、`p_anonymous_namespace_graph` | 内部`m_axi_io_0_ARADDR` out64、`m_axi_io_0_WDATA` out8；owner RAM地址out5、数据in/out8；任务握手1 | 内部byte通道进入顶层32-bit AXI adapter；存在控制状态RAM |
| memory_map | `full_read`、`full_write` | read：`m_axi_io_0_RDATA` in8→`dst_d0` out8；write：`src_q0` in8→`m_axi_io_0_WDATA` out8；总线地址out64 | 当前代表特化读dst地址2bit、写src地址9bit；不是全部调用共用固定4/512byte容量合同 |
| hbm_loader_and_cache | `full_load_weight`、`full_run_task_30` | `m_axi_w_q0_0_RDATA` in8、`ARADDR` out64；`t_kind_val` in2、`t_byte_count_read` in32；cache/owner RAM控制 | 实际内部读数据仍是byte；完整cache存储由共享global RAM提供，任务不是独立HBM口 |
| embedding_engine | `embedding_row` | `raw_address0` out11 / `raw_q0` in8；`y_address0` out10 / `y_we0` out1 / `y_d0` out32 | Q8_0字节RAM→F32行RAM，19个声明端口 |
| layernorm_engine | `layernorm_row_arithmetic` | `op` in5、`row_index` in4；`x_address0` out14 / `x_q0` in32；gamma地址out11/数据in32；y地址out14/数据out32 | 行leaf访问整个16行tile地址空间，不是14-bit F32数据 |
| activation_quantizer | `activation_quantizer_compute` | rows in5、K in13；input_tile地址out16/数据in32；activation_q地址out16/数据out8；scale地址out11/数据out16；写使能out1 | F32输入→S8与F16分开的RAM写口；上下文/identity另有大量端口，数量不等于并行数值lane |
| q8_linear_and_restore | `p_anonymous_namespace_compute_one` | groups in8；`wq_address0` out15/`wq_q0` in8；`ws_address0` out10/`ws_q0` in16；activation_q地址out16/数据in8；activation_scale地址out11/数据in16；`ap_return_3` out32 | 标量INT8读、F16 scale读、F32结果；32个声明端口。窗口内128个输出由循环逐个计算 |
| rope_and_mask | 仅映射到相关`p_anonymous_namespace_attention`控制 | owner/ref RAM与握手；未找到独立`rope_head`数值leaf | 不能把控制模块端口当作64维RoPE数据通路已经实现；此项成功数值路径仍待定位，不由QK/AV异常证据擅自扩大结论 |
| attention_and_fp_engine | QK=`full_run_task_33`、AV=`full_run_task_35`；另有`fp_act_row` | **QK/AV只余task/context/status/count控制端口，没有Q/K/V/score/prob或F32输出数据口**；FP ACT则有x地址out11/数据in32、weight地址out19/数据in16、y地址out8/数据out32 | **QK/AV合法context后E_SHAPE，不能计算成功attention吞吐。** FP ACT真实数据leaf存在，但完整图是否到达成功执行是另一项验证 |
| vector_and_ffn | `geglu_row`、`full_run_task_38` | `wi_address0` out13/`wi_q0` in32；`y_address0` out12/`y_we0` out1/`y_d0` out32 | 5248→2624 F32行RAM；31个leaf声明端口 |
| decision_scorer_act | `candidate_stats`及task_39/_41/_42 | `p_address0` out4/`p_q0` in32；`stats_address0` out2/`stats_d0` out32；另有marker/owner RAM | 16候选概率→4统计F32；其矩阵/激活端口通过共享算术模块实现 |
| result_status | `full_write_result` | `m_axi_io_0_AWADDR` out64、`m_axi_io_0_WDATA` out8；identity/model tag RAM地址out4、data in8 | 通过顶层io AXI adapter提交字节帧；错误/成功状态分别编码 |

### 4.2 联合链的供需与握手

| 联合链 | 存储/交接 | 当前供需关系 |
| --- | --- | --- |
| HBM→权重cache→Q8 | 每矩阵完整LOAD_W，owner READY后才能消费；每row tile又复制8-column局部窗口 | LOAD_W不与该矩阵计算重叠；局部窗口复制也是串行开销，cache宽化不自动变成多MAC并行 |
| LN→量化→Q8 | LN输出F32工作区；量化读取到tile、写S8/F16 RAM；task done后Q8才读 | 输入扫描/量化与Q8不流式重叠。每量化group给全部N输出复用，Q8对每个输出都要执行179–199cycles/group |
| Q8→向量/LN | F32结果写到完整张量或QKV平面；owner覆盖完整并发布后下一task消费 | 先完整输出再消费，不能用8-column几何假定每拍8个F32输出 |
| QKV→RoPE→KV load→QK→Softmax→AV→Wo | QKV/attention输出在HBM，当前head K/V及score/prob计划在片内 | 这是C++成功链；当前QK/AV RTL恒错误使该物理成功链断开，必须先修复再测流水/停顿 |
| Scorer→概率/统计→ACT→结果 | 16候选与4统计形成1028维ACT输入；结果payload后写提交头 | 图内严格数据依赖；结果valid只表示对应状态帧提交，错误帧不代表成功推理 |

## 5. 串行依赖与实际任务次数

```mermaid
flowchart LR
  A[请求检查] --> B[Embedding与LN]
  B --> C[28层Encoder]
  C --> D[Final LN与Type相加]
  D --> E[2层Decision]
  E --> F[16候选Scorer与统计]
  F --> G[CLS加stats到ACT]
  G --> H[写384 B结果]
```

每个 Encoder 内部顺序为 `LN → QKV Linear → RoPE → 各head(QK→Softmax→AV) → Wo → residual → LN → Wi → GEGLU → Down → residual`；第一层前置 LN 已由 Embedding LN 提供。Decision使用 `FC1→ReLU→FC2` 且没有RoPE。每个 Q8 Linear 先 `LOAD_W` 一次，再对各 B/16-row tile 执行 `QUANT→LINEAR`。函数同步返回后才发下一任务；因此当前时间预算按串行相加，不能把各功能峰值简单相加或取最大值。

| observed 任务类别 | B1/S128 | B2/S128 | 如何解释 |
| --- | ---: | ---: | --- |
| 全部退休任务 | 18,895 | 37,158 | 包含装载/计算/尾部；不是时钟数 |
| LOAD_W | 122 | 122 | 当前矩阵一次装载供全部B使用 |
| QUANT / Q8 LINEAR（各自） | 962 | 1,924 | 一次任务遍历完整N，不是只计算8列 |
| LN（全部） | 489 | 978 | 每任务最多16行，S128路径实际共7,824/15,648行 |
| LOAD_KV | 480 | 480 | 30层×16head；每次内部装载全部B和S |
| QK / SOFTMAX_ATT / AV（各自） | 3,840 | 7,680 | 30层×16head×B×8个row tile |
| ROPE | 3,584 | 7,168 | 28层×16head×B×8；每task处理Q和K |
| GEGLU | 224 | 448 | 28层×B×8 |
| ReLU | 16 | 32 | 2层×B×8 |
| ADD_RESIDUAL | 480 | 960 | 30层×2处×B×8 |
| LOAD_ROPE / LOAD_LN_PARAMS | 28 / 2 | 28 / 2 | 参数装载不因B翻倍 |

实际 attention 遍历所有 `key<S`，先做64维点积/归约，再加padding和local bias；AV也遍历全部S。**有效token少于128、滑窗mask或无效候选都不能直接按有效长度扣减当前计算量。** 72/94等历史有效长度不是本轮硬件时延测量；这里统一按当前请求S128。

## 6. 可复算的算量、周期和 50 ms 差距

<a id="performance-estimate"></a>

### 6.1 Q8 矩阵算量

设 `R` 为行数，权重形状为 `[N,K]`，每输出有 `K/32` 个group：

```text
MAC(R,K,N) = R × K × N
G(R,K,N)   = R × N × K/32
C_dot     ≥ 160 × ΣG
C_group    = (179…199) × ΣG    （仅Q8 group-loop算术分量）
```

[compute_one源码](../../../hls/operators/q8_linear_compute.cpp)与HLS报告的 `VITIS_LOOP_67_2` 给出32次迭代×5cycles=160cycles、非pipeline；外层 `VITIS_LOOP_65_1` iteration latency为179–199。`C_group` 已含该group内的整数dot、scale解码/乘法、整数转FP32及跨group累加，**不要再把C_dot重复加进去**。尚未计入函数边界、bias、窗口清零/复制、输出搬运、quantizer和其他模块。

| Q8 family | 层数 | K→N | B1/S128 MAC | Q8 group小计秒 @150MHz |
| --- | ---: | --- | ---: | ---: |
| Encoder QKV | 28 | 1024→3072 | 11,274,289,152 | 420.44–467.41 |
| Encoder Wo | 28 | 1024→1024 | 3,758,096,384 | 140.15–155.80 |
| Encoder Wi | 28 | 1024→5248 | 19,260,243,968 | 718.25–798.50 |
| Encoder Down | 28 | 2624→1024 | 9,630,121,984 | 359.12–399.25 |
| Decision QKV | 2 | 1024→3072 | 805,306,368 | 30.03–33.39 |
| Decision Wo | 2 | 1024→1024 | 268,435,456 | 10.01–11.13 |
| Decision FC1 | 2 | 1024→4096 | 1,073,741,824 | 40.04–44.52 |
| Decision FC2 | 2 | 4096→1024 | 1,073,741,824 | 40.04–44.52 |
| Scorer FC1（16 marker rows） | 1 | 1024→1024 | 16,777,216 | 0.62565–0.69556 |
| ACT FC2（1 row） | 1 | 256→2 | 512 | 0.0000191–0.0000212 |
| **合计** | **122矩阵** |  | **47,160,754,688** | **1,758.70–1,955.21** |

可直接复算：每token的Encoder矩阵合计 `28×(1024×3072+1024²+1024×5248+2624×1024)=343,146,496 MAC`；Decision合计 `2×(1024×3072+1024²+1024×4096+4096×1024)=25,165,824 MAC`。所以：

```text
Q8_MAC(B,S) = B × [ S × 368,312,320 + 16 × 1024² + 256 × 2 ]
Q8_GROUP(B,S) = Q8_MAC(B,S) / 32
```

B2各family计算翻倍，但LOAD_W不翻倍。Encoder Wi＋Down占全网Q8 MAC约61.26%，是优化算术结构时最大的工作量来源。

### 6.2 其他算子并非零成本

下表列真实数学工作量或**有效路径循环体分量**，不冒充完整task周期。源中的finite检查、循环控制、helper调用、RAM复制和HBM等待还要另加。报告min若包含错误提前返回，不用于合法整行估计。

| 算子 | B1/S128工作量 | 当前调度事实或估算公式 |
| --- | --- | --- |
| Attention QK | `30×16×128²×64 = 503,316,480` FP乘法；树加法 `30×16×128²×63`，另有scale/mask | 全S dense计算；树通过循环执行，不能把数学树当作64乘法同时issue |
| Attention AV | `503,316,480` FP乘法＋同数累加 | 按输出d和key串行递推，无可用64路并行结论 |
| Attention Softmax | 61,440行×128元素=7,864,320次exp和除法 | 对每行做finite/max/exp/树sum/div，score和prob可留片内；不能省略mask位置 |
| LN | `61×128+16 = 7,824`行、每行1024维 | 循环体约 `1024×2 + 2×1023×7 + 1024×10 + 1024×(11…15) = 37,874…41,970 cycles/row`，另加scalar sqrt/div和循环/边界成本；合计这些循环体约1.98–2.19s |
| Embedding | Token128行；Type表加载由请求类型路径决定 | 1024输出/行，内层8cycles/元素；每行32个group另有F16解码和控制。完整leaf合法行报告上界8,910cycles，不含HBM读写 |
| Activation Quantizer | 对每个Q8任务的`R×K/32` group量化一次，复用给完整N | 每group至少32次输入扫描及32次量化；扫描3cycles/元素，第二遍3–8cycles/元素，另有amax/scale/half与控制；不能将报告通用max的rows255/groups2047用作实际16/K/32 |
| GEGLU | `28×128×2624 = 9,404,416`输出 | HLS每元素38–78cycle范围含数据相关路径；全长度按上端得约4.89s循环体，完整合法路径/输入相关成本需RTL确认 |
| ReLU / residual | 1,048,576 ReLU元素；7,864,320 residual加法 | 逐元素比较/FP加与读写，不是矩阵MAC；type-add、bias-GELU另计 |
| Scorer FC2 | 16×1024=16,384 FP乘加 | 每marker一个1024维点积＋bias |
| ACT FC1 | 256×1028=263,168 FP乘加，权重F16→FP32 | HLS内层11–21cycles/项；另有1028项输入检查、外层和接口。全部263,168项约0.0193–0.0368s的内循环分量 |
| Gather/mask/stats/concat/result | 16候选、4统计、1028 ACT输入、384B结果 | 搬运、比较、exp/log等小向量操作和协议检查；不以DSP数量换算MAC/s |

B2上述随题执行的计算均翻倍。Q8主要随`B×S`增长，Attention QK/AV主要随`B×S²`增长；对其他S的数学外推不代表那些形状已完成整网RTL/板级验证。

### 6.3 整网条件模型与吞吐边界

```text
T_kernel = (C_group + C_Q8_other + C_other_math
            + C_local_copy + C_control + C_AXI_service_and_stall) / f
T_host_invocation = T_read_and_validate_files + T_device_and_BO_init
                  + T_model_and_workspace_upload + T_kernel + T_result_readback
```

各项按互斥口径统计：`C_group`之外不再重复计group内部运算；AXI项只含尚未记入本地/算术计时的外部服务/等待。当前完整top HLS latency为未知，外部`READY/RVALID`可无限等待；在没有外部停顿约束时，整网不存在可证明的有限最坏时间上界。

为了给系统预算一个明确可用的条件数，可把所有非group核内成本记为 `Δ`：B1为 **29.31–32.59min＋Δ₁**，B2为 **58.62–65.17min＋Δ₂**。这是完整成功图、现有Q8调度不变时的条件估算表达式，`Δ≥0`；其内容包括上表非Q8算术而不只是HBM。目前没有证据为Δ指定固定百分比或有限上界。

在完整成功图且保持现有Q8调度的前提下，只算Q8 group就将串行处理能力限制到约 **0.0307–0.0341题/分钟**；加入其他成本只会更低。B2一次输出两题，但其主要算术也翻倍，当前不因批处理获得2倍每题吞吐；能摊薄的是部分权重/参数装载与固定控制成本。

### 6.4 与50ms目标的差距

50ms@150MHz只有7,500,000cycles。仅B1的47.160754688GMAC就要求 **0.9432 TMAC/s**，相当于 **6,288.10个理想INT8 MAC/cycle**；B2一次请求50ms要求 **1.8864 TMAC/s、12,576.20 MAC/cycle**。这些是100%利用率且不含恢复、FP、存储/控制的必要算术条件。

当前active Q8 leaf含group恢复时约 **0.1608–0.1788 MAC/cycle = 24.12–26.82 MMAC/s**，B1仅group时间是50ms的 **35,174–39,104倍**；更保守的纯整数点积下界也有31,441倍。437个映射DSP包含浮点加/乘等多类IP，不能解释成437个每拍MAC，更不能据此证明50ms。

要接近50ms必须改变并行算术、存储bank/端口、scale恢复/累加反馈、数据复用与调度，而不是只提高频率或放宽时序。流水、并行dot、双缓冲/数据流和更宽更有效的AXI是后续候选方向；本文没有实现这些改变，也没有承诺当前资源足以容纳满足目标的新架构。

## 7. 权重、激活与主机传输预算

| 已可确定的量 | B1/S128 | B2/S128 | 边界 |
| --- | ---: | ---: | --- |
| 五个模型BO文件总大小 | 448,923,648B | 相同 | Host每次当前CLI运行均上传；包含整张embedding与布局填充，不等于kernel本次实际HBM读取量 |
| 122次LOAD_W声明字节合计 | 392,448,128B | 相同 | 含Q8值、物理N填充及scale；不含另读的bias/descriptor/重读，也不等于AXI实际总线beat字节 |
| LOAD_KV声明字节 | 31,457,280B | 62,914,560B | 480次任务，每次包含全部B的当前head K/V |
| LOAD_ROPE声明字节 | 14,694,400B | 相同 | 当前28次表加载，不按有效S裁剪为128行 |
| LOAD_LN_PARAMS声明字节 | 8,192B | 相同 | 两套1024维F32 gamma |
| Token Embedding逻辑原始行读取 | 139,264B | 278,528B | 128/256行×1088B，不含Type表与输出写回 |
| 所有Q8 Linear的F32输出有效字节 | 158,138,376B | 316,276,752B | 39,534,594/79,069,188个F32；只计写出，不含后续消费者重读 |
| Host结果回读 | 384B | 384B | 固定整个请求结果帧 |

`LOAD_W`字节不是每个16-row tile再从HBM重读一次：weight cache跨B和row tile复用；但当前[Linear任务](../../../hls/operators/full_tasks.cpp)每个row tile都把当前8列权重从全矩阵片内cache复制到局部窗口，仍有片内读取、清零、scale/bias复制和输出拷贝成本。Q8输出字节不能代替全网HBM流量；LN、残差、RoPE、量化输入等还要多次读写张量，尚未从AXI波形统计。

例如仅392,448,128B的LOAD_W，若强行假定一个等效通道持续0.6GB/s需0.654s；若持续一个有效byte/cycle=0.15GB/s需2.616s；更低有效率会继续增大。该例只是字节/带宽换算，实际权重分布在q0/q1/scale/aux且代码交错串行访问，不能用它充当已测LOAD_W时间或全部HBM时间。

当前Host每进程重新分配BO、上传五模型BO、清零并同步七工作区和io，再发一次kernel。`448,923,648 / BW_PCIe_effective`只是模型上传的数据量项，还要加文件校验、设备初始化、工作区上传和同步延迟。未来常驻服务可把一次性初始化摊销，但不能把该未来模式记成当前Host行为。

## 8. 已映射资源与性能不能混为一谈

完整OOC综合run为 `20261008T022231Z-2961016`，结果345,505 CLB LUT、287,466 FF、437 DSP、690 BRAM tiles（530 RAMB36＋320 RAMB18）及179 URAM，blackboxes=0。6.667ns约束下WNS+0.894ns/TNS0，但缺平台I/O delay、真实时钟网络与布局布线，因此只能报告综合内部时序，不认定上板Fmax。

映射层级显示Q8 `compute_one`在`linear_15`与`linear_16`子树各有一份，每份6DSP；它们包含INT8 dot和浮点恢复单元。例：一个实际FP32乘法IP用3DSP、FP32加法IP用2DSP。这样的DSP总数不能直接乘150MHz得到有效GMAC/s。inclusive层级资源包含下级，父子表项不得重复相加，也不应强制把共享helper按15目录各分一份。

CPU141检查点和真实top CSim47检查点证明各自数值范围；完整OOC证明当前RTL能完成映射。**它们都没有测量完整FPGA推理时钟数。** 综合工具运行104.47分钟、主机峰值内存38.891GiB是构建成本，与本页每次推理延迟没有因果换算关系。

后续要把`Δ`变成可信整网数值，应在已授权的后续验证中取得完整合法请求的start/done周期、算子/阶段cycle counters、AXI byte/beat/burst/停顿统计，并完成平台时序。成功执行的Q8工作量与现有leaf调度给出分钟级条件预算，不能沿用历史并行候选的50ms或亚秒预算；当前RTL的提前错误路径需先修复，之后才能验收完整硬件推理并重核性能。

## 9. 新增生成RTL异常与当前验收边界

<a id="rtl-anomaly"></a>

直接证据见[异常记录JSON（两例RTL路径、哈希、精确行号与issue映射）](../../../results/performance_estimate_20261008/attention_synthesis_anomaly.json)，循环/特化边界见[loop_evidence.json](../../../results/performance_estimate_20261008/loop_evidence.json)。本轮为核对模块算力而沿HLS issue wrapper追踪生成任务时发现：`full_run_task_33`对应QK，生成RTL仅有context校验和finish控制，在context通过的路径固定写 `done_status=4'd3`（`E_SHAPE`）、`elements=0`，没有成功QK数值输出。独立Astra审核确认这不只是算术被内联后leaf名称消失。AV对应`full_run_task_35`也已确认同样在context通过后固定返回E_SHAPE、elements=0。两个任务均只有53个控制/状态/上下文端口，没有实现其逻辑合同需要的Q/K/V/score/prob/F32结果数据口。

这使当前报告的三个层次必须分开：

1. **已验证的C++/CPU/CSim合同**：完整28 Encoder＋2 Decision＋Scorer/ACT成功，任务计数和数值检查成立。
2. **已存在的RTL/OOC制品**：完整top与浮点IP导入、综合exit0、blackboxes0及资源/综合时序成立；综合不会验证QK必须有成功路径。
3. **尚不能成立的完整硬件推理能力**：当前已识别QK和AV失败特化，不能以错误提前退出的几拍报告推算Attention成功吞吐，也不能称当前RTL完整推理正确或当前映射资源已覆盖全部正确数值路径。

因此本文的Q8分钟数是**源码成功图算量乘以已生成Q8 leaf调度**的条件外推，既不是当前RTL成功推理实测，也不是其可能提前报错请求的时延下界。异常修复如果使更多算术真正进入RTL或改变调度，资源与性能必须重新估算/综合；旧综合审核保持为当时制品事实，不回写成新制品验收。当前文档任务仅记录和界定异常，没有修改RTL/HLS或启动新的硬件运行。
