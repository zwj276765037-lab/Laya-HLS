# Laya-HLS 当前实验工程验收（2026-10-11）

本轮工程评估交付：**completed**。完整加速器验收：**NOT_ACCEPTED / 证据不足**。M002/SM002 的完整硬件目标尚未完成；本报告不修改 goal、mission、索引或全局审核结论。

工程对话：`01a129af-29ef-7102-b86a-a43995a36279`。本次实际完成轮次：`01a129d6-a5eb-71d3-b2fa-f01e8eaac6f8`；前一轮因权限切换中断，已产生的定向审计证据继续保留。期望模型为 GPT-6.1 Sol/xhigh；原生 read_thread 只证明对话和轮次身份，没有返回实际运行模型/强度，因此 actual_model/actual_effort 保留 null。本轮没有修改模型设置。权限开放不构成实验结论。

## 1. 当前基线与评估边界

评估依据当前 goal/M002/SM002：真实 Q8_0 模型、完整 B1/S128、28 Encoder＋2 Decision＋scorer/ACT、122 张 Q8 矩阵；CPU 负责 token Embedding/会话与控制，FPGA 承担后续全部 LN、动态量化、Q8、Attention、GEGLU、Decision 及响应退休。正确性、完整请求性能及部署资源分别验收；50ms 是远期参考。

唯一当前实现根为 [E002 工程副本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment)。原 baseline 保留，历史绝对路径只用于解释原运行身份；本次读历史引用时映射到副本同相对位置，未执行原 attempt 脚本、未写回原工程。

旧阶段的 [production 封存](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_production_stage_close_01/receipt.json) 为 CLOSED_SCOPED_PASS，[Attention 封存](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/handoff/final_summary.json) 为 CLOSED_WITH_OOC_NOT_COMPLETE。阶段结束成立，但不等于完整加速器完成。阶段文档后半部分 RUNNING/PENDING 是历史时点记录，当前状态以封存收据和本次核验为准。

本轮只做定向文件校验、原始日志与合同核对，不重新运行 CPU/CSim/RTL/OOC/P&R 或板卡。审计使用 CPU0–3、nice19、idle I/O；无新重工具。15:12:37、15:14:37（北京时间）两次进程快照未发现可归属 Laya-HLS 或原 baseline 的重工具。其它无归属或 cwd 不可读的进程单列保留，未管理任何其它项目进程；这不是服务器所有工具均已停止的声明。

## 2. 身份、输入与证据来源

| 对象 | 核验事实 | 适用范围 |
| --- | --- | --- |
| E001 复制 | 原已接受收据：210038 普通文件双侧 SHA 一致，6100 links 映射；原工程保留 | 继承复制验收，本轮未重复全树校验；不推出硬件正确性 |
| 真实 GGUF | 实际文件 455179648B，SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；本轮重算匹配 | 原模型未换；153 tensor |
| 旧完整软件包 | build `23c62cd4778f54e3cc7508f5d05558de`；numeric `aeb13e7937d29fe6a2c68c407249f294`；layout `f927881686d9d11c91b7f11ac59e2cc7` | 旧冻结 CPU/CSim 身份，不能给当前 working 源代签 |
| 冻结 BO/输入 | embedding/w_q0/w_q1/w_scale/aux 五 BO 共 448923648B 的 size/SHA 均匹配；四请求 source/target 共8项、raw-input 24项均匹配 | CPU 离线包和输入身份；不证明 PCIe/HBM 上传读回 |
| 权重目录 | 124 目录项，其中 Q8 矩阵122；其余目录不能重复计为 Q8 | 沿用原完整包/独立参考口径 |
| production 当前模块源 | 封存 working_source_manifest 的53项全部匹配 | resident/G/缓存等所列模块闭包，不是完整新 build 身份 |
| Attention v10 | final_summary 16个直接 SHA 引用全部匹配；source_manifest 185条引用中183匹配，两个历史文档引用不同；运行源/冻结源引用均匹配 | 当前 head128/tile16 原运行仍可按原身份复用；历史文档链接缺口见下文 |
| 当前生产 C 与旧 CSim | 对46个实际编译依赖映射到当前树比较，7个已变化；配置生成器另有变化 | 当前完整 CPU/CSim 必须在新身份稳定后重验；本轮未冒充已运行新 build |

模型实物、BO 与请求的逐项 SHA 在 [input_checks.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/input_checks.json)；模块源与收据在 [identity_audit.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/identity_audit.json)；当前 C 差异在 [supplemental_identity_audit.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/supplemental_identity_audit.json)。

7个变化的编译依赖是：`hls/common/laya_numeric.cpp`、`hls/operators/activation_quantizer_compute.cpp`、`full_tasks.cpp`、`full_tasks_attention.cpp`、`q8_linear_compute.cpp`、`include/laya_numeric.h`、`tests/current_production_full_csim_tb.cpp`。其中6项是实现/头文件，1项是TB；完整 SHA 在补充审计中。旧 CSim 冻结依赖和可执行文件本身均匹配，变化的是当前树，不能把该差异写成旧运行失败。

两份主封存共有24条直接引用全部匹配；resident receipt 8/8、G bridge receipt 6/6、旧 CSim receipt 81/81、旧 CPU receipt 153/153 均匹配。首批审计573个唯一文件、补充审计381个唯一文件有交集，不相加冒称总数。原始日志的精确通过/失败标记和行号保存在 [core_checks.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/core_checks.json)。

Attention 的 source_manifest_v10 仍引用旧联合 design SHA `11506f2e…`，当前为 `8e3b3456…`；另 v03 preservation_manifest 的旧引用 SHA 与当前文件不一致。本轮未完整复原这两个历史文档版本，尝试仅移除 §8.4.11 不能复原旧 design SHA，因此不能将漂移原因简化为只追加这一节。此项记录为**历史文档可追溯性证据不足**，不追认“所有185项零漂移”，也不把它改写成当前数值 FAIL。G 终态中3条旧准备脚本引用已明确 superseded，其 archived_original 与 current_OOC_record 均核一致；不能按旧路径误判功能源改变。

## 3. 核心验收矩阵

PASS 均表示列明身份和范围通过；FAIL 保留原失败身份；NOT_RUN 表示该层级未执行或没有当前版本验证；COST_STOP 表示成本保护结束，不能当数值失败。

| 核心项目 | 结论 | 实际证据与覆盖 | 决定性缺口 |
| --- | --- | --- | --- |
| 完整模型旧 CPU | PASS_SCOPED（继承并复核） | P1：g++ 四持久请求、3正常、141独立检查点/18094384 F32逐位及 gamma 故障后恢复；guard0/338.283s | 软件/离线执行，非当前 working 身份整图硬件 |
| 完整模型旧真实 Vitis CSim | PASS_SCOPED（继承并复核） | P2：同冻结身份，原日志 CSim done with 0 errors；guard0/317.126s | 入口是13BO wrapper下的生产 dispatcher C模型，不是13BO AXI连接 |
| 当前完整数值与最终输出/决策 | NOT_RUN / 证据不足 | 旧软件最终 candidate/ACT 等检查点保留；当前编译依赖7项变化已确认 | 新完整包/依赖身份未冻结并执行完整 CPU/CSim；实际硬件最终决策未验证 |
| 标签数据集准确率 | NOT_RUN | 当前证据是少数请求与独立参考一致 | 需冻结带标签集及同模型对照；不能由逐位请求一致推出数据集准确率 |
| 真实生产 C门户与13BO外层 | NOT_RUN | P9 §3.9已定义cmd16/rsp8、两private FIFO、单持久服务；实际top仍13指针 | 当前源码没有这条服务连接的生成/RTL证据；ABI寄存器/BO基址/角色/offset及真实债务仲裁待验 |
| 上游真实 Wi→G→quant→resident Down | NOT_RUN | P3/P4分别通过，不在同runtime | G桥以冻结Wi checkpoint输入；resident以预量化A输入，二者不能拼成生产整链 |
| resident完整Down局部链 | PASS_SCOPED | P3：四distinct行 K2624/N1024；10496stripe、41984 rowPS、335872 lane-group PS、4096最终F32；512实际AW/W/B及末B/lease/localREADY；48862cycles | 仅kind0 bias旁路、初始reset、预量化A；非零bias、活动CE/reset、晚错恢复、16row多view、twoA/twoW及其它shape未测 |
| 新G三bank→物理GATE→quant→fullA | PASS_SCOPED | P4：20992 Wi/10496 GATE、656写/656读beat、4完整row/328group；59975cycles | 无上游Wi Q8、同runtime Down；桥活动reset、晚错及twoA重叠未测 |
| G三bank本地功能/恢复 | PASS_SCOPED | P5：三同步bank全深度，6完整row、15744输出、157440独立step比较及原恢复覆盖 | 本地writer ack为诊断；生产链恢复不能由本地证据代替 |
| Attention v10完整head | PASS_SCOPED | P6：enc0/head0/B1/S128，128query/K128/D64；正常QK250888+SM287173+AV66256=604317cycles | 不是全部head/层/shape或整模型；生产调用仍原标量服务 |
| Attention首错/CE/reset | PASS_SCOPED | P6同manifest tile16_03：6竞争首错、M/A/D/EXP活动CE/reset、pending Q、ledger/旧epoch恢复 | head128自身PROTOCOL=0；覆盖来自同身份tile16，不能说完整head本身跑过这些负例 |
| 模块计算性能比较 | PASS_SCOPED | Attention旧同fixture标量正常计算6816248cycles，新604317，改善11.279259倍 | 只比较模块正常计算；不是完整请求延迟/吞吐、物理频率或GPU加速比 |
| 完整请求冷暖延迟/完成间隔/填充排空 | NOT_RUN | G/resident/Attention各有独立局部计数 | 不同边界/外部fixture/缓存状态不得相加为端到端；150MHz仅条件预算 |
| 旧canonical G51 OOC | PASS_SCOPED | P7：176828 LUT/299253 FF/48 DSP/RAM0；blackbox0/IO0 | 是旧row存储实现；WNS+0.538ns@6.667ns仅内部综合且I/O缺delay，非物理Fmax |
| 当前G三bank父OOC | COST_STOP | P5：semantic_stall，164.188s/3793524KiB，child−9 | 无新父最终DCP/primitive RAM映射/完整装配/最终资源；3×2624×32 elaboration不是物理RAM证明 |
| 当前Attention OOC | COST_STOP | P8：semantic_stall，244.411s/11295456KiB，child−9 | 无final资源、DCP、blackbox/时序结果；不发布ready blackbox |
| 当前resident OOC及联合资源fit | NOT_RUN / 证据不足 | 当前resident功能有效；已有旧模块OOC按身份保留 | 当前完整联合装配和无重复计费资源账未完成；旧G子树不能再加到旧父总数 |
| 整体OOC/P&R/时序/Fmax | NOT_RUN | 未取得当前整图物理结果 | 目标器件、XDC/IP/端口约束与当前源需成套绑定；仿真时钟不代表达成频率 |
| U55C/XRT/PCIe/HBM/上板 | NOT_RUN | 合同无可用板卡；本轮未启动部署工具 | CPU内存端点上传/读回、离线ACTIVE不等于真实设备REGISTER/板端吞吐 |
| 历史数值失败 | FAIL（原身份保留） | P10：旧tanh ordinal23相差2ULP；旧quant real03 tiny被错误READY | successor canonical/精确适配有各自限定PASS；不追认旧失败，也不扩大为当前全部方案失败 |

## 4. 已完成、未完成及阻塞

已完成：复制接入的既有验收可继承；真实模型/冻结输入可定位且实物SHA匹配；旧完整CPU/CSim、当前所列resident/G/Attention局部出口具备可复核原始证据；两类OOC成本中止及未取得制品边界已确认。本轮工程评估、证据整理与交付可完成。

未完成：当前身份完整软件回归、真实生产C门户/13BO仲裁、同runtime上游producer整链、生产错误/reset安全退休、当前联合资源与完整请求性能，以及全部后继物理/上板层级。工程评估完成不关闭这些缺口，也不把顶层M002/SM002改成completed。

当前最重要阻塞是**生产连接和有效整图身份缺失**，其次是**G/Attention当前物理资源未闭合**。存在的局部PASS足以支持有界连接工作，不足以给出完整可部署加速器验收。

风险与边界：

- 历史build标签还在，但当前源已变化；以旧标签运行历史脚本会错误引用旧路径/旧包。后续必须从副本重建配置并生成新源/输入/reference/tool/IP/XDC身份。
- 外部Wi checkpoint与预量化A会隐去真实生产缓存及owner/lease交接问题；local ledger和诊断ack不能替代全局13BO响应退休。
- resident当前输出32768B中有效16384B，仅8个F32/512bit beat的有效输出；不具全宽写吞吐声明。
- G原父176828 LUT包含95754 LUT算术子树；联合账重复叠加父/子会失真。新三bank资源仍UNKNOWN；Attention也没有可供部署的当前OOC终态。
- “无语义进展120s”只证明保护触发，不证明综合算法挂死。G累计已用1261.775981s、原3600s额度余2338.224019s；不得重置额度或原样加帽。
- 当前TM4固定几何完整单请求Q8理想约46.055Mcycles已超过40M RTL帽，是该配置的成本准入问题，不能推出所有方案不可验证；整层/整图长例应由实速pilot决定。
- 两处Attention历史文档SHA缺口保留。后续只需恢复或说明相关版本来源，不为补文档身份重跑未变数值RTL。

## 5. 按优先级的可执行建议与通过标准

以下是提交主控的工程建议，未建立新的goal/mission，也未执行下一阶段实现。

| 优先级 | 建议行动 | 后续任务通过标准 |
| --- | --- | --- |
| P0 | 冻结副本当前完整生产依赖/输入身份，重建路径配置 | 新build/preimage涵盖当前全部编译依赖与生成配置；共享GGUF只读；无旧路径写回；source/gold身份均可复现 |
| P1 | 按既有§3.9接显式cmd/rsp生产门户与原13BO真实外层 | cmd16×512bit/rsp8×512bit、private FIFO真实生成且连通；13BO/AXI-Lite ABI逐地址一致；BO基址锁存/WSTRB、role/offset/span/溢出核验；单物理实例；完整view只一命令 |
| P1 | 用同一生产caller完成有界Wi→G→quant→Down真实链 | 由真实Wi Q8生成A来源；不预置GATE/A/PS/结果；K2624/N1024完整输出对独立gold；实际RRESP/BRESP、最后B、lease/owner/覆盖账闭合；故意压FIFO/返回/末R/B不能提前退休 |
| P1 | 补受影响生产错误与恢复边界 | 非零bias、数值/源/AXI晚错与首错优先级、活动CE/reset/new epoch；已接受AXI债务安全排空，旧FP/R/B不进入新generation；多view父task不能早发布；只跑受影响用例 |
| P2 | 稳定接入身份后做完整CPU/实际Vitis CSim，再按pilot安排分段RTL | 原4持久请求、141点/18094384 F32及故障恢复在新身份通过；生成硬件分支无假completion/C软件服务；分段覆盖列出尚未验证的同runtime整图行为 |
| P2 | 用真实联合资源账决定有界物理闭合 | 若由主控纳入下一阶段，G可用§8.4.11单bank/四stub/link备选，但共享剩余2338.224019s；最终真实装配blackbox0/IO0、完整端口/51FP/三bank覆盖、原始资源/DCP才可判闭合；Attention当前资源另立真实证据，不借旧DCP代签 |
| P3 | 建立可比的完整请求性能基线 | 同模型/shape/反压/缓存条件和当前build测冷暖、fill/drain、完成间隔、有效服务/停顿；资源共享不重复计费。随后再依据瓶颈决定LN、更宽Q8或多请求调度 |
| 后继物理/部署 | P&R、时序与板卡分层推进 | 当前器件/约束下有原始WNS/TNS/端点与Fmax证据；板卡可用后实际XRT/PCIe/HBM/整请求性能。未执行层级继续NOT_RUN |

资源仍执行全项目单重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB；RTL≤8GiB/3600s/40Mcycles、pilot≤120s、static≤24GiB/1800s、模块OOC≤24GiB/3600s及120s真实语义保护。本轮建议不扩大为整网OOC/P&R/上板或大规模扫参授权。

## 6. 应复用而不应重跑的证据

1. 原冻结build23c62cd4 CPU/CSim：原日志、冻结编译依赖及可执行身份均一致，本轮无需重跑；新生产源验证必须另建身份，不能覆盖原记录。
2. 当前source一致的resident正常完整Down、G bridge04与G三bank六row功能、Attention v10 head128及同manifest tile16首错/CE/reset：只复用各自边界。生产连接改变时补边界与受影响回归，不重复未变叶子和独立gold全套。
3. 原G51不变算术子树导出与功能、原syncPS完整真实Down中间结果、已接受缓存/quant恢复：经对应身份核对后复用；父资源不能用子树相加替代，局部恢复不能替代resident/生产恢复。
4. 历史FAIL和COST_STOP：保留原日志、身份与保护原因；不为消除失败记录或权限变更重跑。G新物理闭合备选尚未执行，不原样重复父OOC。
5. E001全树复制SHA收据与本轮模型/输入SHA：不重复扫描副本或再次全量校验未变模型；后续新运行仍需记录实际输入绑定及受影响身份。

## 7. 证据入口

- P1：[旧完整CPU收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/current_production_full_cpu_01/receipt.json)；原日志终态位于driver.log:143。
- P2：[真实Vitis CSim收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/current_production_full_vitis_csim_02/receipt.json)；原日志driver.log:264–265。
- P3：[resident完整Down收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_tm4_matrix_resident_full_down_01/receipt.json)；原simulate.log:86。
- P4：[G三bank真实桥RTL04收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json)；原simulate.log:2。
- P5：[G三bank终态](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json)，含functional/OOC/archive/累计预算链接。
- P6：[Attention最终封存](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/handoff/final_summary.json)；head128原simulate.log:143；tile16原simulate.log:115。
- P7：[旧canonical G51 OOC](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/receipt_ooc_01.json)。
- P8：[当前Attention OOC终态](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/ooc_01/ooc_result.json)。
- P9：[联合生产合同§3.9及G备选§8.4.11](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/source/design.md)；当前源码定位另见补充审计current_production_markers。
- P10：[历史tanh数值FAIL](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/tanh_service_real_01/guard/driver.log:14)；[旧quant tiny FAIL](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log:15)。successor：[精确quant适配收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/quant16_stream_adapter_01/receipt.json)、P4/P5/P7 canonical结果。
- [原复制验收收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E001_baseline_import/experiment_results/runs/R001/copy_receipt.json)。
- [本轮身份审计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/identity_audit.json)、[补充身份/当前C闭包审计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/supplemental_identity_audit.json)、[原始marker摘录](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/core_checks.json)、[模型/输入SHA](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/input_checks.json)、[原生对话与实际轮次身份](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment_results/engineering_acceptance_evidence_20261011/thread_runtime_evidence.json)。

主控下一步读取本报告、E002三摘要与agent/A002/result.md，在核验交付标记后结合现有goal及历史mission定义下一阶段；本报告不提前替主控作该决定。
