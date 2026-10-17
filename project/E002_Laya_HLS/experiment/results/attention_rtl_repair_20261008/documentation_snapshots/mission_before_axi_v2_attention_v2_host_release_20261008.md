# Laya：从真实 RTL 功能闭环到 U55C 端到端性能对照

更新日期：2026-10-08。本文是本工程单一活动任务入口，定义后续阶段、依赖、交付和验收。最初落盘只完成计划；用户随后明确“开始执行”，并确认**暂时没有板卡，先完成离线验证**。当前执行范围为阶段 1–4 的诊断、功能、综合与性能评估，以及阶段 5 可离线完成的资料和工程准备。按既有技术门持续推进，无需重复用户许可；上板与端到端实测待板卡具备条件，不阻塞离线工作。历史预算和证据保护继续有效。

设计、性能预算与独立审核由 **GPT-6 Astra / xhigh** 承担；工程实现与已授权工具执行由 **GPT-6 Sol / max** 承担。本文由实际 Astra xhigh 设计代理撰写和自审。沿用现行合同的内部技术放行，不为计划增加逐步向用户重复确认的流程。

## 1. 目标、范围与依据

完成 Laya Typed-Decisions Q8_0 在 U55C 上的完整请求前向：28 层 Encoder、2 层 Decision、scorer/ACT，hidden 1024、16 个 head、每题 16 个候选槽。主机 CPU 负责请求准备、XRT 调用和结果解释；FPGA 执行完整前向，不是自回归逐 token 生成。主验证请求为 B1/B2、物理 S128；其他 S 和边界用例按覆盖清单分别验收。

保留 **50 ms** 的用户性能对照目标。最终同时报告板上 kernel 和常驻 Host 完整请求的延迟、吞吐与质量，冷启动单列；实际通过口径须在对照实验前冻结，不能在看到结果后挑选更有利的计时范围或百分位。当前没有 U55C 达到 50 ms、与 A6000 同口径比较或加速比的证据。

权威依据分工如下；规格文档的历史“尚未实现”描述以当前同身份的实际证据更新理解，不能反向抹去后续结果。

- [项目 README](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/README.md)：当前总体状态与证据入口。
- [硬件规格入口](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/hardware_agent/spec.md)和[总体规格](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)：模型、主机/板卡分工、接口和未覆盖范围。
- [修复及性能合同](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/repair_contract.md)：§2–§3 功能门槛，§4 联合 Q8 设计，§7 当前诊断、预置 QKV 与工具门禁。
- [接口与性能报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/project/source/performance_and_interfaces.md)：实际端口、工作量、条件估算及旧综合边界。

## 2. 当前起点：哪些已通过，哪些仍缺证据

正式修复包的 build tag 为 `fe067c8aa0627ad770096f9721394645`，下文简称 **fe067**；它包含针对优化后丢失 QKV pair 和二元向量 src1 路径的生产修复。旧 **04934** 是修复前生成制品的身份简称，其综合资源不得用于验收 fe067。冻结模型 SHA256 为 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，以[正式 manifest](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/build/model-attention-rtl-repair-20261008/manifest.json)为准。

| 证据层级 | 截至本文的事实 | 本任务仍须完成 |
| --- | --- | --- |
| D1：最小控制路径复现与等价修复 | 原 nullable 写法的 RTL 出错；修复后 15 个事务、120 项检查通过 | 保持已证明的 guard、状态和数值语义；这不是完整 Attention 数值验证 |
| D2：真实 typed-task、owner 与数值联合链 | fe067 完整 CPU 门禁 141 检查点、4 次持续调用及故障恢复通过；真实 13 口 B2/S128 标准 libm CSim 47 点通过 | 生成 RTL 数值、实际 AXI 数据、发布/退休，以及未覆盖 B1/恢复 CSim 范围 |
| D2-I：生产 Controller 路径取证 | 线性 I-L、二元向量 I-V 的严格 CPU/CSim 和 stage4 优化 IR/生成结构审核通过 | I-L/I-V 数值 RTL；Encoder stage2 与上下游连接覆盖。IR 可达不等于数值 RTL 通过 |
| 完整 Attention 仿真诊断 | 历次完整环境均未获得完成输出；七口独立 idle 在零交易、构造计数不变时仍随时钟增长内存；traffic 首响应观察不一致而失效 | 统一采样后的有效对照、时钟/事件机制鉴别及可执行的新数值窗口；尚未定位具体泄漏或分配根因 |
| 外部 QKV 预置切片 | Sol 已完成实现；[最终 CPU 绑定包](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/source/final_cpu_binding_packet.json)及后续标准 libm CSim 的 3 合法、17 负例均已获 Astra 独立接受 | 局部综合在指针结构源码检查失败，未有调度/RTL；正按实际 IR 定位隔离 wrapper，后续静态绑定与数值 RTL 待修正及新审核 |
| 完整核资源/平台 | 旧 04934 OOC 综合无黑盒，345,505 LUT、437 DSP、690 BRAM tile、179 URAM；只有综合内部时序 | fe067 完整重建、数值 RTL、同源资源与平台布局布线；旧结果不能与新功能证据拼成整体验收 |

当前工具目标为 `xcu55c-fsvh2892-2L-e`、150 MHz（6.667 ns 请求）；这不是已达到的板上频率。实际 `.xpfm`、shell 可用资源、HBM 连接、XRT 编译链接和板卡运行尚未验证。

## 3. 阶段与依赖

| 阶段 | 要解决的问题 | 依赖与主要交付 | 放行出口 |
| --- | --- | --- | --- |
| 1. 仿真观察与内存机制 | traffic 响应采样不一致、零交易时内存随时钟增长 | 稳定采样 v2；最小时钟等待四模式；原始日志、绑定及独立判读 | 观察有效、机制或适用边界有证据；下一运行有具体预算 |
| 2. 真实 Attention 与 Controller | 外部预置数值链和生产上游路径尚未形成完整 RTL 证据 | 预置 BEGIN→RUN；D2-I 数值 RTL；Encoder/RoPE 与必要 shape/错误恢复扩展 | 按 D2 合同闭合实际数据、owner、数值、拒绝及恢复，不以切片替代整链 |
| 3. 完整 top 重建 | 新功能身份缺完整生成、资源和 RTL 验收 | 复用已接受 CPU 证据、补齐 CSim；新完整 RTL/IP/OOC；全请求验证 | 同一身份的功能与资源证据闭合，满足后续架构集成基线 |
| 4A. 隔离联合 Q8 表征 | 当前串行算术/存储不能接近目标 | 可与 2/3 交错；TM4/TN8 独立原型、真实全 K/N 与局部 RTL/OOC | 接受切片数值/背压/II/资源系数，尚不宣称整核适配 |
| 4B. 性能架构集成 | 单个切片无法证明整网功能/性能 | 4A 与必要 D2 连接证据；新集成身份和完整回归/生成资源 | 最终加速核完整请求 RTL 与同源资源通过；预算能解释全部瓶颈 |
| 5. U55C 平台与公平对照 | 平台、常驻 Host、质量和端到端延迟缺实测 | XRT/PCIe/HBM 链接；板上功能/恢复；对齐 A6000 的测量 | 同模型/请求/数值质量/计时边界下报告结果；达标与否如实判定 |

阶段 1 与阶段 2 的源码、CPU和只读审核可以交错，预置 CPU/CSim按现行合同优先，重工具始终串行。阶段 2 的数值 RTL 必须使用已审核的新调度、真实页绑定及预算，不必等待对整个模拟器作无法证明的“完全无泄漏”结论。阶段 3 的完整 HLS 仍须满足原 D3 门槛。性能设计和平台资料核查可提前，性能实现与完整核/平台集成按各自门槛推进。

按合同 §7.14，联合 Q8 分 **A 隔离实施、B 切片表征、C 生产集成/最终验收** 三门。已接受的 fe067 软件数值、D1 修复 RTL、D2-I 生成路径和独立 R0 oracle 可支撑隔离原型；不要求先跑完旧 F0 完整 RTL。完整修复核/shell 余量用于集成适配结论，缺失时可先报告独立原型资源但必须保留未知余量。最终加速核的完整请求 RTL、AXI/owner/恢复验收仍必须完成，未执行的旧 F0 RTL 不得冒充通过。

这是实际可行性要求：旧 F0 B1 仅 Q8 为 2.638–2.933×10¹¹ cycles，当前 I-L 单个合法 64 行 QKV 也需约 1.126–1.252×10⁹ cycles。即使假设每秒仿真一百万 cycle，仍分别需 73.28–81.47 小时和 18.77–20.87 分钟，其他成本另加；假设速率不是实测。启动长数值 RTL 前必须核实际 schedule、同环境进度/RSS 与具体预算，不能让不可结束的仿真阻止独立原型表征，不能截断或用 stub 伪装原验收范围。

### 阶段 1：把仿真观察做正确，再界定内存机制

沿用合同 §7.13 和两份现行设计，不另起竞争方案：

- [AXI 分配诊断设计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/source/design.md)：稳定采样 v2 使用统一 clocking `input #1step` 样本，同时记录握手、响应 ID/RESP/data；保留原 VIP、响应时延和全部断言。重新建立同 snapshot、同 seed 的 idle/traffic 配对，完成 1024 对实际写/读回、排空、100000 时钟和完整 backing-memory 检查。
- [最小时钟等待诊断设计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_xsim_clock_wait_diagnostic/source/design.md)：32 个固定 worker，比较 module、static-class、virtual-class、带原延迟的 virtual-class 四模式，每例 20000 时钟；不引入交易、每拍对象分配或不断扩容的记录。

验收要求：源与 snapshot 绑定闭合；同一时刻的计数与 payload 一致；时钟、RSS、队列、构造数及完整内存检查齐全；退出码为 0 但含 fatal 仍判失败。当前观测约 16.1876 KiB/clock 只描述既有 idle 区间，不能当完整 DUT 内存上界，也不能解释成 FPGA 存储消耗。

当前clock v2四模式各20000周期已获[独立运行接受](../results/attention_rtl_repair_20261008/reviewer_d2_clock_wait_v2_four_mode_review.json)：时钟1到20000的采样RSS均平坦，为76372–76484KiB（74.58–74.69MiB）。该最小module-scope、无UVM/无traffic环境没有重现先前VIP增长，不排除其他组合或更长区间，也不构成完整DUT上界。AXI稳定采样v2已通过[静态快照门](../results/attention_rtl_repair_20261008/reviewer_d2_axi_stable_sampling_v2_snapshot_runtime_gate.json)，放行fresh idle→traffic各4GiB/90s/100000周期，当前等待实际结果。已消耗的旧idle/traffic窗口不复用；没有新证据时不自动重试、加预算或重跑旧完整Attention。

### 阶段 2：完成外部预置 Attention，并闭合生产路径

已独立审核交付的源码、85 项 CPU 输入及 14 项 fixture 绑定，核对最终日志和 3 合法/17 负例；129 条文件引用、114 个唯一路径重哈希与大小核查均无差异。[源码与 CPU 独立审核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_source_cpu_review.json)已接受并放行标准 libm CSim，不重复运行未改变的 CPU 测试。

按[预置设计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/source/design.md)和[结果记录](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/d2_attention_preloaded/source/results.md)，先审核 CPU，再顺序门控标准 libm CSim（16 GiB/600 s）、局部综合（16 GiB/1800 s）；真实 IR/RTL 审核通过后才做多事务准备和静态展开（各 16 GiB/300 s）。数值 RTL 运行预算另据新 schedule、页初始化和阶段 1 证据核定，本文不放行。

v1实际局部综合因指针聚合源码检查失败后，已基于linked IR对照放行[隔离v2直接cleanup修正](../results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_v2_direct_cleanup_design_release.json)：只移除Controller引用逃逸至fail helper，保留原错误/成功报告顺序、3合法17负例及所有生产源。当前仅实施/严格CPU准备放行，v2 CSim/综合仍按新源码与配置依次审核；v1既有成功结果不自动迁移。

该切片的验收必须同时满足：

1. BEGIN 使用真实 parse/fresh/双 shard claim，返回 FILL 与 ticket/epoch；Host 随后实际装载 QKV。RUN 通过真实 coverage/publish，执行 LOAD_KV→QK→SCORE/PROB lease→Softmax→AV→ATT_OUT；禁止直接写 READY 或填造覆盖状态。
2. 实际生成环境只有先 BEGIN、后 RUN 两次调用，同一 DUT/runtime 中间无 reset；逐项核对实际页推进、地址偏移和描述符。RUN 前独立检查两 shard 各 10,240,064 B 的真实 backing prefix，包含空洞和尾哨兵；receipt 只是外部生产者绑定，不能替代数据核验或声称硬件认证任意输入。
3. 合法输出与独立期望比较；扰动 QKV 后对应输出变化；缺 plane/row、过期身份、重放及故障后恢复遵守原拒绝规则。QK/AV 的基本算术顺序保持精确要求，softmax 单独适用既有非线性误差线；实际 AXI 读写、未写区域和任务退休均须检查。

首个数值 RTL 边界仅为 B1/S64 Decision stage4/layer0、head0/query0。CPU 的 head15/query63 通过不自动扩展 RTL 覆盖。此结果证明“外部输入→真实发布→Attention”，不证明 Q8 生产器或 Encoder RoPE。

后续按原 D2 覆盖表补齐 B1/B2、S128、head0/15、首末 row、full/slide/全 padding mask，以及 S64/S1024 针对性边界。D2-I 的真实 Controller 线性/向量链须取得数值 RTL，并闭合 Encoder stage2 的 RAW QKV→RoPE→FINAL 与 Decision 无 RoPE 路径。必须说明这些证据如何连接生产者与消费者；仅有各个孤立 PASS 不放行完整 top。

### 阶段 3：以修复身份重建完整核

严格沿用合同 D3：局部数值、owner 和生产链独立接受后才放行完整 HLS。已接受且输入身份未变的 CPU 证据直接复用；补齐 B2/S128 与两次重基 B1、持续会话/故障恢复的真实 13 口 CSim，核对三次正常完整请求各 47 个检查点（47×3）、任务数与结果帧；故障请求按错误帧及恢复合同验收。补充 shape 测试不冒充相应 shape 的整网运行。

完整 top 生成后机械核对 QK、AV、RoPE 和其他合法任务不再固定报错/零元素，检查状态写读及数值 RAM 端口；生产源若改变，生成新的 build/package 身份。随后对同一制品完成合法全请求 RTL 数值、错误/恢复和 AXI 检查，并重新取得无黑盒 OOC 资源、存储原语映射及约束报告。长仿真先有资源可行性与技术预算，不用软件通过补齐硬件空白。

交付同一身份的源码/包/配置/输入清单、功能审核、实际资源和时序报告，并更新现有模块 `source/design.md`、`source/results.md`。分别标记 CPU、CSim、局部 RTL、完整 RTL、综合、布局布线和板测状态。04934 的 +0.894 ns 综合 WNS 不能证明新核达到 150 MHz，也不能证明平台 shell 能容纳新核。

### 阶段 4：联合 Q8 原型到可复算的整网架构

从合同 §4.4–§4.7/§7.15已映射的 **TM4/TN8/GS32** 原型开始；既有q8模块唯一当前design/results已落盘，A门放行隔离实现、真实ACT fullK/N fixture与严格CPU准备，后续CSim/RTL/OOC仍分别审核。首版512bit读、32bit输出按真实成本表征，不宣称生产接口已拓宽。原型用于量化实际代价，不能直接承诺50ms。

联合审核应覆盖整条供需链：真实 BO 权重加载和跨行复用→8 lane 激活量化→W/A 分 bank→整数点积→R0 浮点恢复和按 group 顺序累加→PS bank/反馈→偏置/输出/退休。联测 full K/N、ACT N2 等窄尾、F16 次正规 scale、负 dot、零激活、非满行及随机背压；保持 R0 的独立乘加、组序和精度。扩大整数阵列时同步核算 FP 转换/乘法/加法吞吐、反馈距离、bank 冲突、读写端口和输出排空，不由 lane 名称推断持续吞吐。

每个候选交付真实 II、有效 MAC/cycle、各级停顿与利用率、片上读写/外部有效字节、映射 LUT/FF/DSP/BRAM/URAM 和时序。DSP 使用必须从实际综合映射验证，不能把 INT8 lane 数或总 DSP 数直接换算 MAC/s。资源余量按阶段 3 新完整核和真实 shell 核算；逻辑容量不能代替原语粒度、复制和布线成本。

50 ms@150 MHz 只有 7,500,000 cycles，必要条件分别为：

| 请求 | 仅 Q8 MAC 工作量 | 50 ms 所需理想吞吐 | 50 ms 所需理想 MAC/cycle |
| --- | --- | --- | --- |
| B1/S128 | 47.160754688 G | 0.9432 TMAC/s | 6,288.10 |
| B2/S128，一次含两题的请求 | 94.321509376 G | 1.8864 TMAC/s | 12,576.20 |

这些数值假设 100% 利用率，尚未包含恢复、Attention、非线性、搬运、控制和 Host；B2 不能除以二后声称整次请求达标。QK/AV、LN、GEGLU、残差等必须放入同一个 50 ms 预算，不能让各段独占 50 ms 再相加。

合同 §4.7 的阵列候选可用下表判断距离；假设每拍 issue 一个 GS32、150 MHz、满利用率且只计整数 Q8，均为理想条件值，不是实现结果：

| 候选阵列 | 理想 MAC/拍 | B1/S128 纯 Q8 时间 | B2/S128 纯 Q8 时间 |
| --- | --- | --- | --- |
| TM4/TN8 | 1,024 | 307.04 ms | 614.07 ms |
| TM16/TN8 | 4,096 | 76.76 ms | 153.52 ms |
| TM16/TN16 | 8,192 | 38.38 ms | 76.76 ms |

因此 TM16/TN16 也不能在这些条件下满足 B2 请求 50 ms；其每 issue 还需 256 次整数转浮点、512 次 FP32 乘法和 256 次 FP32 加法的理想服务量。若要求每拍 issue，恢复/反馈系统也须提供相应持续服务率，具体 R0、banking 和流水约束沿用合同 §4.4–§4.7。

Attention 也有独立下界：按合同 §4.1，旧 64 路共享 FP 候选即使满载，B1/S128 仅 QK+AV 就需理想 104.86 ms，B2 为 209.72 ms，尚不含 softmax、mask 和 IO；扩大 Q8 阵列不能代替 Attention 吞吐改造。

当前旧 leaf 的 32 项 dot 为 160 cycles，含恢复/累加的 group 为 179–199 cycles；若完整成功图仍保留该调度，Q8 分量条件估算为 B1 29.31–32.59 分钟、B2 58.62–65.17 分钟，其他成本另加。这不是成功 RTL 或板上测得时延，也不能用 XSim 的墙钟时间替代硬件周期。

HBM 侧同时解决当前 13 个 32-bit AXI 口的有效传输、bytewise 访问、burst/packing、并发与 bank 分配。每口 150 MHz 原始上限 0.6 GB/s，13 口之和不证明可持续并发。每请求 122 次 LOAD_W 声明 392,448,128 B，Q8 输出 B1/B2 分别 158,138,376/316,276,752 B，均不是全网总流量；必须实测 beat、有效字节、重读与复用。AXI 拓宽、双缓冲、融合和阶段重叠需有真实接口及停顿证据，不能只改峰值带宽假设。

仅为在 50 ms 内装入每请求 q0/q1 各约 184.68 MB 的权重，两口分别至少需要约 **3.694 GB/s 有效带宽**，scale 另需约 **0.462 GB/s**，激活、结果、bias 等其他流量另加。该必要条件适用于现有每请求加载方式；加载复用发生改变时须重核真实流量。512-bit@150 MHz 的 9.6 GB/s/口只是候选原始峰值，仍须证明平台连接及有效率。

整网预算只使用测得的切片系数：串行段相加，证明能重叠的部分才取最大值，并保留初始化、排空和 Host 成本。资源/带宽不足时交付证据支持的可达区间与结构取舍；保留 50 ms 目标，不能降低指标后宣称通过。改变精度、归约顺序或 Attention 算法须另立数值/质量合同。

### 阶段 5：平台集成和同口径 A6000 对照

先确认实际 U55C、平台 `.xpfm`、shell、工具/IP/许可与 XRT 环境，冻结 kernel 参数、13 个 BO、时钟/复位及 HBM bank 连接。完成真实 Host 编译、`.xo`/`.xclbin` 链接、布局布线与板级时序，检查无黑盒、无未约束关键路径且资源包含 shell 占用；只有这些证据才能声明目标频率达到。

当前 CLI 每次进程/请求分配 BO、上传模型并清理/同步 workspace。后续建立常驻服务：五个模型 BO 共 448,923,648 B 只在初始化上传，请求复用 BO 和模型，但仍保留 owner/epoch、超时、错误隔离与恢复。分词、输入组帧和业务解码尚未完整集成，纳入端到端交付；不能把已有 kernel 调用入口当完整服务。

先在板上验证冻结输入的数值、结果帧、跨请求隔离、故障后恢复和业务质量，再测量以下三个范围：冷启动（含加载）、常驻 kernel start/done、常驻 Host 完整请求（输入准备/分词、同步、kernel、回读和后处理）。报告预热、样本数、P50/P95、吞吐、B/S、候选数及错误率，B1/B2 分列，板上周期与主机时间分别留证。

已有 [A6000 报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/results/laya_gpu_inference_benchmark_20261005.md)中两题常驻 SDK/BF16 autocast、B2/S94、K_pad3 的 P50/P95 为 25.047/25.224 ms；这是不同模型、精度、shape 和候选规模，不能直接计算当前 FPGA 的加速比。真实请求有效长度 72/94 与硬件物理 S128 必须统一解释：当前硬件不因 padding/mask 自动减少算量。后续冻结同一模型/原始请求、B/S/padding、候选、数值/质量条件及计时范围再比较；如保留各自实现原生 shape，也须单独报告差异及实际工作量，不能包装成同条件结论。当前离线执行先使用已有 GPU 记录与工作量预算，板上同口径对照留待板卡条件具备。

## 4. 执行约束、证据和完成判定

“一次一个重工具”只约束**本 Laya 工作流及其全部代理树**，不要求服务器无关任务停下。沿用具体实验已批准的 CPU 数、nice19、idle I/O、任务树 RSS/wall-time、0.2 s 采样与 MemAvailable≥192 GiB 守护；启动前确认本树无其他重工具，只管理本任务拥有的进程。本文不扩大预算，不修改其他工程或旧运行证据。

模块继续使用现有 `source/design.md` 与 `source/results.md`，新运行保存独立目录、实际命令/工具版本、退出码、完整日志、输入/制品哈希与审核结论；失败保留。改变源或配置即重新绑定身份，按受影响范围验证，不为了更新状态重复已接受且未改变的测试。

长期任务分三个结论交付：**完整功能验收**需要同身份完整请求 RTL 与板上数值/恢复；**性能达标**需要真实架构系数、板上实测和冻结的 50 ms 判据；**平台完成**需要实际 U55C/XRT/PCIe/HBM 链接、布局布线和可重复运行。本次离线交付按阶段 1–4 的实际证据分别验收，附上平台可离线准备的成果和待板卡清单；不能因暂无板卡停止可完成的离线工作，也不能把离线完成写成上板或 50 ms 已达。软件 PASS、生成成功、OOC 无黑盒或单个切片 PASS 均不能代替其他层级。

当前未覆盖项包括：稳定采样v2运行接受及VIP内存机制、预置v2 CPU/CSim/综合/RTL、D2-I数值RTL与Encoder连接、全部D2边界、完整新top重建/RTL、已放行Q8原型的实际实现与验证、平台与业务服务集成、同口径质量/稳定性和性能对照。最小时钟四模式已完成并独立接受，仅关闭其有界诊断范围。各项依上文阶段关闭，执行状态见下表。

## 5. 实际执行记录

| 日期 | 实际进展与边界 | 下一步 |
| --- | --- | --- |
| 2026-10-08 | Astra xhigh 完成本文并由 controller 复核链接、模型身份、三档 Q8 理想时间及权重带宽；最初落盘未启动新运行。用户随后授权执行，并明确当前无板卡、先离线验证 | 按阶段 1–4 和阶段 5 离线准备持续推进；板卡实测单独保留待办 |
| 2026-10-08 | 预置 Attention 源码/严格 CPU 独立接受：3 合法、17 负例；生产 fe067 不变；完整图像、原错误 detail、ticket/epoch、字节序及哨兵检查通过 | Sol max 准备/执行已放行的标准 libm CSim（16 GiB/600 s）；通过后由 Astra 按现行门槛放行局部综合，不等待新的用户确认 |
| 2026-10-08 | 预置 Attention 标准 libm CSim 已[独立接受](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_csim_review.json)：实际 26 个 C++ 编译输入及严格 FP 配置，3 合法/17 负例，工具 0 errors；30.24 s、受控树峰 1,279,800 KiB、无守护触发。139 条引用/135 个唯一路径重哈希无差异 | Sol max 执行同源局部综合（16 GiB/1800 s）；Astra 随后审核真实 IR/RTL 与调度，再门控两事务准备。数值 RTL 尚未执行 |
| 2026-10-08 | 首次综合入口选项不支持，退出 2，已保留并改正；实际 v++ 综合随后完成前端/结构转换，但 50 条 pointer-to-pointer 源检查失败，171.50 s、峰 2,941,652 KiB、无守护触发。[独立失败审核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/results/attention_rtl_repair_20261008/reviewer_d2_attention_preloaded_csynth_failure_review.json)确认没有调度/资源/RTL 制品 | 对比已成功 D2-I，定位新 wrapper 中 Controller 引用聚合的实际 IR；只做有证据的等价修正，不原样重试或修改生产数值 |
| 2026-10-08 | Astra/controller 已确认阶段 4A 可与 2/3 交错，合同新增 §7.14 三门及长仿真可行性检查；最终加速核完整 RTL 门不降低 | 补齐现有 Q8 模块的隔离原型接口/设计/预算后按 A 门实施，各运行仍需真实配置和预算 |
| 2026-10-08 | controller 只读平台预查：显式 Vivado/Vitis 2025.2 可执行；PATH 未见 xrt-smi/xbutil，XRT/平台环境变量未设，标准路径未见 XRT 头/库，PCI sysfs 未发现 vendor 0x10ee；限定检索 LLAMA-HLS 与工具安装未找到 `.xpfm`，其中一个工具 lib 目录无读取权限，不能外推全盘不存在 | 保留离线工具验证；平台资料/Host 工程可先准备，驱动安装、工具修改及板上运行不在当前操作范围；不再因板卡信息等待离线工作 |
| 2026-10-08 | 最小时钟v2四模式各20000周期独立接受，采样自身RSS74.58–74.69MiB且clock1→20000无增长；AXI稳定采样v2静态快照通过并放fresh idle/traffic各4GiB/90s | 等待真实AXI对照结果；不把最小环境平坦外推成VIP或完整DUT无泄漏 |
| 2026-10-08 | Attention实际IR支持消除Controller→fail helper逃逸的隔离v2窄修复；Q8当前模块design/results及§7.15完成，A门实现/ACT CPU准备放行 | Sol按两份新身份实施，先源码/CPU再按实际包门控CSim/综合/RTL；生产fe067和原失败证据保持冻结 |
