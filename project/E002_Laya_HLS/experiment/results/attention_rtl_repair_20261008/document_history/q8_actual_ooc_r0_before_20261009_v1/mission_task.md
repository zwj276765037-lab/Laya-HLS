# Laya：从真实 RTL 功能闭环到 U55C 端到端性能对照

更新日期：2026-10-09。本文是本工程单一活动任务入口，定义后续阶段、依赖、交付和验收。最初落盘只完成计划；用户随后明确“开始执行”，并确认**暂时没有板卡，先完成离线验证**。当前执行范围为阶段 1–4 的诊断、功能、综合与性能评估，以及阶段 5 可离线完成的资料和工程准备。按既有技术门持续推进，无需重复用户许可；上板与端到端实测待板卡具备条件，不阻塞离线工作。历史预算和证据保护继续有效。

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

| 路径 | 当前事实 | 下一步 |
| --- | --- | --- |
| Q8 联合原型 | ACT 36 条数值 RTL、Scorer K1024/N1024 单行三命令数值 RTL 独立通过；FP 边界 119 例已完整表征，通用 R0 位型 33 例不符 | 按首例实测分门推进三行/尾行、FP 有界修复、同源 OOC 与结构修订；已验收命令不重跑 |
| 静态 AXI 环境 | 32/512 位共 1,024 对读回、全 32 KiB、排空、响应反压和两个预期拒绝均独立通过 | 作为真实 Q8/Attention 的验证端点；FIFO 饱和、并发碰撞及完整 DUT 仍在后续范围 |
| 预置 Attention | v5 软件/RTL 生成及 cold V2 四命令数值/协议独立通过，B1/S64 layer0 head0/query0 | 保留 V1 首错；head15/扰动输入、metadata reset 源准备；真实生产链、时序及暖复位待验 |
| Host 会话核心 | 冻结真实请求/结果与共享 codec 的 304 项 CPU 检查通过 | XRT adapter、设备所有权/终态及平台部署仍未验证 |
| 新完整核 fe067 / D2-I | 完整 CPU/B2 CSim 通过；D2-I CPU/CSim 与既有局部综合/真实路径结构证据保留；冷启动 unary Mode3 B1/S64、16 候选、14 页数值 RTL 正式验收 | binary `src1`、真实 Encoder/producer 连接、其余数值窗口、同源完整资源及平台集成 |
| 平台与性能 | 无板卡；旧缺陷制品的 OOC 结果只属旧身份 | 持续完成离线工作；板上完整功能、频率与 50 ms 另验 |

证据入口：[Q8 v3](../results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)、[Scorer 单行 RTL 正式验收](../results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_full_functional_acceptance.json)、[AXI 四模式](../results/attention_rtl_repair_20261008/reviewer_axi_bounded_static_v1_final_unit_review.json)、[Host CPU](../results/attention_rtl_repair_20261008/reviewer_host_session_tb_setup_v2_cpu_acceptance.json)、[Attention v5](../results/attention_rtl_repair_20261008/reviewer_attention_v5_software_synthesis_structure_review.json)、[cold V2 四命令验收](../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)与 [D2-I unary Mode3 正式验收](../results/attention_rtl_repair_20261008/reviewer_d2_i_mode3_unary16_final_functional_acceptance.json)。精确输入、制品、原始日志和历史失败由各证据包绑定；[本次更新前四份文档全文](../results/attention_rtl_repair_20261008/document_history/mode3_unary16_r0_ooc_status_before_20261009/manifest.json)保留追溯。

[FP 七封装 119 例实际边界表征](../results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_119_characterization_acceptance.json)已由 Astra xhigh 接受完整证据，但结论是**通用 R0 primitive 位型不通过**：119/119 连续三样本稳定有效，86 相同、33 不同（fdiv 5、fmul2 4、fmul3 4、fadd 4、fcmp1/2 各 8，sitofp 0）；首差 `037e0000 / 42fe0000` 期望 `00400000`、实际 `00000000`。原封装、119 例金值和运行制品冻结；[R0 有限域 adapter 门](../results/attention_rtl_repair_20261008/reviewer_q8_finite_domain_r0_adapter_design_source_release.json)仅选定数学设计并放行隔离源码准备，尚无 helper/参考/探针 CPU、RTL 或 OOC 执行验收，不放行 C1 集成。[D2-I unary Mode3 正式验收](../results/attention_rtl_repair_20261008/reviewer_d2_i_mode3_unary16_final_functional_acceptance.json)只关闭 B1/S64 一次冷启动 `APPLY_CAND_MASK`：16 候选、1 个本地输入 producer、14 页；AP 接受至首次完成 23,064 周期，测试台 PASS 时总计 23,272 周期，首次完成时物理与 adapter 欠账清零，16 个 masked F32 位型和整页数据独立核对。[0 ps plusarg 首错](../results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_alias_v2/runs/runtime_first_failure_evidence_v1.json)及[准备路径首错](../results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_alias_v2/runs/plusarg_entry_overlay_v2/preparation_failure_evidence_v1.json)均完整保留；binary `src1` 和真实 producer/Encoder 连接未验收。

Q8 同源 OOC 工程准备的[首次首错](../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/project_prepare_v1_control/stage2_first_failure_evidence.json)是 Vivado `set_property` 的 `-mode out_of_context` 选项不受支持；[local import a1 首错](../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/project_prepare_local_import_v2_a1_control/stage2_first_failure_evidence.json)先由 `PYTHONHOME/PYTHONPATH` 污染阻断检查器，清理环境后发现 7 份 XCI 的 `OUTPUTDIR` 路径差异超出当时白名单。两次均未进入 `generate_target`，未做顶层综合；当前同源 OOC 资源、时序和物理结论仍空缺。

正式修复包身份以 [fe067 manifest](../build/model-attention-rtl-repair-20261008/manifest.json)为准。目标器件为 `xcu55c-fsvh2892-2L-e`，150 MHz 是请求值。实际平台、shell 余量、HBM 连接、XRT 编译链接与板上频率仍未验证；旧 04934 资源不能与新功能证据拼接。

## 3. 阶段与依赖

| 阶段 | 要解决的问题 | 依赖与主要交付 | 放行出口 |
| --- | --- | --- | --- |
| 1. 有界仿真环境 | 静态 AXI 四模式已通过；旧 VIP 根因仍未证明 | 冻结接受的端点，绑定真实 DUT、物理页和预算 | 单位范围已关闭；实际 DUT 另有数值与资源验收 |
| 2. 真实 Attention 与 Controller | 外部预置数值链和生产上游路径尚未形成完整 RTL 证据 | 预置 BEGIN→RUN；D2-I 数值 RTL；Encoder/RoPE 与必要 shape/错误恢复扩展 | 按 D2 合同闭合实际数据、owner、数值、拒绝及恢复，不以切片替代整链 |
| 3. 完整 top 重建 | 新功能身份缺完整生成、资源和 RTL 验收 | 复用已接受 CPU 证据、补齐 CSim；新完整 RTL/IP/OOC；全请求验证 | 同一身份的功能与资源证据闭合，满足后续架构集成基线 |
| 4A. 隔离联合 Q8 表征 | 当前串行算术/存储不能接近目标 | 可与 2/3 交错；TM4/TN8 独立原型、真实全 K/N 与局部 RTL/OOC | 接受切片数值/背压/II/资源系数，尚不宣称整核适配 |
| 4B. 性能架构集成 | 单个切片无法证明整网功能/性能 | 4A 与必要 D2 连接证据；新集成身份和完整回归/生成资源 | 最终加速核完整请求 RTL 与同源资源通过；预算能解释全部瓶颈 |
| 5. U55C 平台与公平对照 | 平台、常驻 Host、质量和端到端延迟缺实测 | XRT/PCIe/HBM 链接；板上功能/恢复；对齐 A6000 的测量 | 同模型/请求/数值质量/计时边界下报告结果；达标与否如实判定 |

阶段 1 与阶段 2 的源码、CPU和只读审核可以交错，预置 CPU/CSim按现行合同优先，重工具始终串行。阶段 2 的数值 RTL 必须使用已审核的新调度、真实页绑定及预算，不必等待对整个模拟器作无法证明的“完全无泄漏”结论。阶段 3 的完整 HLS 仍须满足原 D3 门槛。性能设计和平台资料核查可提前，性能实现与完整核/平台集成按各自门槛推进。

按合同 §7.14，联合 Q8 分 **A 隔离实施、B 切片表征、C 生产集成/最终验收** 三门。已接受的 fe067 软件数值、D1 修复 RTL、D2-I 生成路径和独立 R0 oracle 可支撑隔离原型；不要求先跑完旧 F0 完整 RTL。完整修复核/shell 余量用于集成适配结论，缺失时可先报告独立原型资源但必须保留未知余量。最终加速核的完整请求 RTL、AXI/owner/恢复验收仍必须完成，未执行的旧 F0 RTL 不得冒充通过。

这是实际可行性要求：旧 F0 B1 仅 Q8 为 2.638–2.933×10¹¹ cycles，当前 I-L 单个合法 64 行 QKV 也需约 1.126–1.252×10⁹ cycles。即使假设每秒仿真一百万 cycle，仍分别需 73.28–81.47 小时和 18.77–20.87 分钟，其他成本另加；假设速率不是实测。启动长数值 RTL 前必须核实际 schedule、同环境进度/RSS 与具体预算，不能让不可结束的仿真阻止独立原型表征，不能截断或用 stub 伪装原验收范围。

### 阶段 1：接受有界环境，保留旧诊断边界

[静态 AXI 端点四模式](../results/attention_rtl_repair_20261008/reviewer_axi_bounded_static_v1_final_unit_review.json)已独立验收。32/512 位各 512 对真实写/读回，合计 AW/B/AR 各 1,024、W/R 各 6,466；全 32 KiB、空闲与暖复位后排空、3 拍 B/R 反压均通过。跨 4 KiB 和错误 WLAST 两个独立模式分别在预期首个 fatal 停止；普通退出码不替代语义判断。静态保护脚本参数错误在仿真启动前发生并保留，改用已有 4 GiB 脚本后四模式各只运行一次。

同快照 10k→100k 时钟的自身 RSS 在 idle 为 76,776 KiB、traffic 为 76,964 KiB，两个窗口采样均不增长；traffic 在 50k 前已结束。有限单位环境没有覆盖 FIFO 饱和、同时读写碰撞、输入通道反压或在途复位，也不能给完整 DUT 内存上界、HBM 带宽或硬件吞吐。实际 Q8 绑定必须使用真实生成端口、双 AXI-Lite、完整 64 位地址及有限页，保留独立数值期望与全缓冲区检查。

旧 VIP 的[等待/控制失败](../results/attention_rtl_repair_20261008/reviewer_d2_axi_guard_trace_v5_runtime_failure_review.json)、[idle 内存增长](../results/attention_rtl_repair_20261008/reviewer_d2_axi_sampled_wait_v4_runtime_review.json)和[最小时钟平坦观察](../results/attention_rtl_repair_20261008/reviewer_d2_clock_wait_v2_four_mode_review.json)各自冻结，不再原样重跑或改写 wait 猜测。新端点提供可继续数值验证的环境，其通过不证明旧模拟器异常的根因。

### 阶段 2：完成外部预置 Attention，并闭合生产路径

[v5 独立审核](../results/attention_rtl_repair_20261008/reviewer_attention_v5_software_synthesis_structure_review.json)已接受严格 CPU、标准 libm CSim 与真实 RTL 生成。报告函数仅由可空指针改为存在标记和固定 pending.pair；3 合法/17 负例保持，实际 LOAD_KV、QK、Softmax、AV、owner 和报告路径可达。全部历史失败保存在[结果记录](../results/attention_rtl_repair_20261008/d2_attention_preloaded/source/results.md)及其历史链接，不原样重跑。

当前边界分别记录：v5 生成通过，cold V2 首个四命令数值与协议通过；5.390 ns 对有效 4.867 ns 调度预算仍有 XML 时序违例；普通硬件复位仍未清 pending/session。不能用软件清理或重载初始化文件代替暖复位证明。

[cold V2 独立验收](../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)已复核 557 个源文件、322 个最终快照、11 个准备文件、全部四页 observed 与四份 262144 B 输出。BEGIN、重复 BEGIN 拒绝、RUN、replay 拒绝全部通过；QK 64 字精确、概率原容差、AV 从实际概率按顺序 binary32 运算精确且符合原端到端容差。全部双侧端口与 adapter 计数一致，完成检查无债务，输入扫描、剩余 261888 B 哨兵及整块 replay 保留通过。RUN 实测 256 AW/W/B、1024 B 总线/256 B 有效写，末 B 索引 256、对齐地址 +252；输出读仍 64 AR/R、256 B，qkv0 8256 次读、33024 B，qkv1 静默。特定 R/B 实测停顿 18/17 拍。

V2 单次静态构建 190.94 s、2480596 KiB，运行 103.96 s、846944 KiB，保护均无触发。四命令测试台计时 26633/1017/500651/3778 拍，RUN 首次采样 ap_done 为 500645；起点是 Lite 启动写发起，不能冒充 DUT 接受→完成、II 或物理频率。对应单次构建/运行门已消耗，不原样重跑。

[V1 首次运行失败](../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v1_first_runtime_failure_review.json)继续冻结：两前置命令及 RUN 30 状态字通过后，错误的 64 次写预期导致末 B 断言失败，缺 RUN dump/replay，原尝试不补写为通过。V2 保留原硬件、金值与数值检查，只修正独立 TB 计数、物理诊断和断言前转储。7 个真实 32 位 AXI 口、双 Lite、267 页、216 Verilog/35 DAT/6 FP wrapper 闭包均未缩减；完整 host 图像/原 prefix 与映射页已核验，未宣称仿真扫描未映射的全部 shard。

后继 [head15/query63 与 changed QKV 有限四命令](../results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_changed_finite_source_preparation_release.json)和 [v6 metadata reset](../results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_source_preparation_release.json)仍处源码准备门；[D2-I-V mode3 最小窗口](../results/attention_rtl_repair_20261008/reviewer_d2_i_vector_mode3_static_source_preparation_release.json)已按后续独立门完成上述 unary 数值 RTL 验收。当前已验收 Attention cold V2、Scorer 单行三命令及 D2-I unary Mode3；binary/生产连接与 Q8 多行/FP/OOC 分门推进。复位修订须仅重置元数据并保留实际 payload；跨 reset 后若新 BEGIN 重建相同身份，不能声称旧 receipt 自动防 ABA，Host 必须失效旧会话并绑定新 generation。

该切片的验收必须同时满足：

1. BEGIN 使用真实 parse/fresh/双 shard claim，返回 FILL 与 ticket/epoch；Host 随后实际装载 QKV。RUN 通过真实 coverage/publish，执行 LOAD_KV→QK→SCORE/PROB lease→Softmax→AV→ATT_OUT；禁止直接写 READY 或填造覆盖状态。
2. 正常生产者顺序为先 BEGIN、后 RUN，同一 DUT/runtime 中间无 reset；负例调用按合同插入并检查不破坏 pending 状态。逐项核对实际页推进、地址偏移和描述符；RUN 前独立检查两 shard 各 10,240,064 B 原 prefix（含空洞/尾哨兵），再验证实际映射页与已检查图像一致；receipt 只是外部生产者绑定，不能替代数据核验或声称硬件认证任意输入。
3. 合法输出与独立期望比较；扰动 QKV 后对应输出变化；缺 plane/row、过期身份、重放及故障后恢复遵守原拒绝规则。QK/AV 的基本算术顺序保持精确要求，softmax 单独适用既有非线性误差线；实际 AXI 读写、未写区域和任务退休均须检查。

首个数值 RTL 边界仅为 B1/S64 Decision stage4/layer0、head0/query0。CPU 的 head15/query63 通过不自动扩展 RTL 覆盖。此结果证明“外部输入→真实发布→Attention”，不证明 Q8 生产器或 Encoder RoPE。

后续按原 D2 覆盖表补齐 B1/B2、S128、head0/15、首末 row、full/slide/全 padding mask，以及 S64/S1024 针对性边界。D2-I 的真实 Controller 线性/向量链须取得数值 RTL，并闭合 Encoder stage2 的 RAW QKV→RoPE→FINAL 与 Decision 无 RoPE 路径。必须说明这些证据如何连接生产者与消费者；仅有各个孤立 PASS 不放行完整 top。

### 阶段 3：以修复身份重建完整核

严格沿用合同 D3：局部数值、owner 和生产链独立接受后才放行完整 HLS。已接受且输入身份未变的 CPU 证据直接复用；补齐 B2/S128 与两次重基 B1、持续会话/故障恢复的真实 13 口 CSim，核对三次正常完整请求各 47 个检查点（47×3）、任务数与结果帧；故障请求按错误帧及恢复合同验收。补充 shape 测试不冒充相应 shape 的整网运行。

完整 top 生成后机械核对 QK、AV、RoPE 和其他合法任务不再固定报错/零元素，检查状态写读及数值 RAM 端口；生产源若改变，生成新的 build/package 身份。随后对同一制品完成合法全请求 RTL 数值、错误/恢复和 AXI 检查，并重新取得无黑盒 OOC 资源、存储原语映射及约束报告。长仿真先有资源可行性与技术预算，不用软件通过补齐硬件空白。

交付同一身份的源码/包/配置/输入清单、功能审核、实际资源和时序报告，并更新现有模块 `source/design.md`、`source/results.md`。分别标记 CPU、CSim、局部 RTL、完整 RTL、综合、布局布线和板测状态。04934 的 +0.894 ns 综合 WNS 不能证明新核达到 150 MHz，也不能证明平台 shell 能容纳新核。

### 阶段 4：联合 Q8 原型到可复算的整网架构

当前 **TM4/TN8/GS32** 原型已通过真实 ACT K256/N2/rows1 的严格 CPU、双标准 libm CSim，以及 [metadata_reset_v3 综合与复位结构审核](../results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)。普通复位已覆盖控制标量及标签有效标记，payload RAM 没有整体清零；[ACT 数值 RTL、协议、恢复与暖复位 36 命令](../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_full_functional_acceptance.json)已完成独立验收。当前 HLS 估计 21.308 ns，量化相关 II 为 4/7，均不能当作目标频率或满发射吞吐。全部前代失败与原始制品留在 [Q8 当前结果](../vivado/module_design/q8_linear_and_restore/source/results.md)及对应审核链接。

[ACT 实际源码审查](../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_actual_source_review.json)及[整体执行验收](../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_full_functional_acceptance.json)已完成 865 文件、346 静态快照文件、九 AXI/双 Lite/41 页、输入和原始日志核验。一次静态构建及 legal9→fault_load3→identity_reset24 均通过，原先单次门已用完，不重跑已通过命令。测试台命令最大 6295 clocks，包含启动准备、Lite、总线等待和 CSR 检查；不是纯 DUT 延迟或发射间隔。暖复位动态抽查 W/A8/FP 输入各一个真实写入且原始位型非零单元；FP 输入是负零 `0x80000000`，未动态抽查 PS 或全部地址。50 个 payload RAM 无批量 reset 清空另有静态证据。

后继保留真实全 K/N，从少行窗口扩到多 tile、尾行和跨列块首错，并使用只读观察器测实际 accepted start→done、LOAD/量化/点积恢复/输出/trace 阶段、issued-group 间隔、反馈及端口停顿。旧 full_matrix_fixture 的部分输入源自 native capture，不直接重标为已接受 R0 整网节点；缺失输入由最近冻结 CPU 检查点局部推导并绑定来源。具体数值运行预算以实际生成调度、已测 XSim 推进率与有限工作量为依据；不直接启动旧 F0 B1/S128 整网长仿真。之后据这些系数设计发射、归约、FP 恢复与 banking 的结构修订，保持 R0 数值合同。[C1 结构选择与独立审核](../results/attention_rtl_repair_20261008/reviewer_q8_pipeline_c1_independent_design_review.json)已冻结固定五级整数树、32 条完整 R0 恢复通道、8W/4A 广播及真实 PS hazard/首错退休要求；量化同时改银行、amax 比较和乘法/round 服务。42 个分析绑定文件已重新哈希，全图计数由 fe067 manifest 独立复算：695,816 量化组、962 次量化任务、47,160,754,688 MAC。8 lane 两遍理想扫描 37.11 ms；全部 Q8 输出若仍经双 32 位口落外存，下界 131.78 ms。TM16/TN16 按单 INT 乘法每 DSP 加当前 FP 系数需 10,240 DSP，超过器件 9,024，尚未计 Attention/shell；不能只扩大 MAC 阵列或声称 50 ms 可行。C1 尚未实现/执行放行，先取得 Scorer 三命令实测。

[全 K/N、尾行和性能观察合同](../results/attention_rtl_repair_20261008/reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json)的首例已由 [Scorer V6 数值 RTL 正式独立验收](../results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_full_functional_acceptance.json)闭合：K1024/N1024、B2/S128 选 batch1/row15，LOAD→trace 开→同输入 trace 关，同一 DUT 保留权重；341 页的完整输出、报告、哨兵和原始证据均已复核。两个 RUN 各 4096 次有序 issue/retire，零重复 Q/scale/AUX 事务；接受至完成为 1,496,042／1,815,172／1,811,360 clocks，trace 关闭的最大 issue 间隔 437 clocks。150 MHz 仅是 9.974／12.101／12.076 ms 的条件换算，非 Fmax、板测或整网时间。原始 `sub_done` 含命令起点 idle 高电平，不能按子调用次数解释；terminal hold 为 0，未证明末写响应背压。此前[入口权限失败](../results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v4_static_launch_failure_bash_release.json)与 TB 保留字编译首错仍按历史身份封存。后继多行、跨 tile、FP 边界和 OOC 均须各自源码审核及有限运行门；不重跑已通过 CPU/ACT/Attention。

TM4/TN8 即使理想满发射，B1 纯 Q8 也约 307 ms；当前结构已不能实现 50 ms。ACT 功能门的意义是建立可信修订基线；后续工作必须同时推进瓶颈表征和结构改进，不能把接口通过扩大成性能通过或只累积长仿真日志。

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

无板卡阶段的 [Host 可移植会话核心已获 CPU 独立验收](../results/attention_rtl_repair_20261008/reviewer_host_session_tb_setup_v2_cpu_acceptance.json)：真实共享 codec 和冻结请求/结果，304 项检查覆盖身份准入、单 InFlight、13 BO/五模型/每请求同步、精确 384 B 结果、错误帧和未知终态所有权。首个测试设置失败及 TB 一行修正完整保留，政策源码未变。成功执行仅 0.180 s，没有正 RSS 或运行策略样本；未为取样重跑。确定性测试后端不代表真实 XRT、PCIe 或设备终态，阶段 5 仍未完成。

先在板上验证冻结输入的数值、结果帧、跨请求隔离、故障后恢复和业务质量，再测量以下三个范围：冷启动（含加载）、常驻 kernel start/done、常驻 Host 完整请求（输入准备/分词、同步、kernel、回读和后处理）。报告预热、样本数、P50/P95、吞吐、B/S、候选数及错误率，B1/B2 分列，板上周期与主机时间分别留证。

已有 [A6000 报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/results/laya_gpu_inference_benchmark_20261005.md)中两题常驻 SDK/BF16 autocast、B2/S94、K_pad3 的 P50/P95 为 25.047/25.224 ms；这是不同模型、精度、shape 和候选规模，不能直接计算当前 FPGA 的加速比。真实请求有效长度 72/94 与硬件物理 S128 必须统一解释：当前硬件不因 padding/mask 自动减少算量。后续冻结同一模型/原始请求、B/S/padding、候选、数值/质量条件及计时范围再比较；如保留各自实现原生 shape，也须单独报告差异及实际工作量，不能包装成同条件结论。当前离线执行先使用已有 GPU 记录与工作量预算，板上同口径对照留待板卡条件具备。

## 4. 执行约束、证据和完成判定

### 4.1 已接受的完整图联合必要条件（2026-10-09）

[联合报告](../results/attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md)及[主设计独立审核](../results/attention_rtl_repair_20261008/reviewer_laya_u55c_50ms_joint_budget_independent_review.json)已闭合 40 个来源哈希和 122 张 Q8 矩阵的逐项计数。B1/S128 为 47,160,754,688 MAC、695,816 量化组、158,138,376 B Q8 输出；B2 请求算术/结果翻倍，但 122 次 LOAD 和冻结 Host workspace 不翻倍。

当前隔离输出角色使 B1 out0 独占 134,545,416 B；32 位、150 MHz 满服务下界 224.242 ms，宽为 512 位仍需 14.015 ms payload。单 W 缓存的 q0→q1→scale 串行最低装载服务约 48.094 ms；8 lane 两遍量化扫描约 37.110 ms，还须保留完整输入装载。64 路 Attention 的 QK+AV 理想贡献约 104.858 ms；KV 按 head 跨全部 B/S 复用，每请求 480 次 LOAD，不按 query tile 重复计算。所有数值均有明确服务条件，未被用作实测吞吐。

B2 在 150 MHz、INT8 每 DSP 两乘积、FMUL3/FADD2 的条件下，即使全部裸器件 9024 DSP 给 Q8，工作量下界仍为 52.261 ms。packing、共享、宽量化/外写、片上消费者及双缓存均需另外证明精确数值、真实端口、owner/credit、资源和重叠时间轴；本结论不排除其它已验证映射，也不删除 50 ms 目标。每请求 184 MiB workspace＋32 KiB IO H2D 和 384 B D2H 保持冻结；参考 Gen3×16 的理想 H2D 12.249 ms 仅是链路条件，不是平台实测。

Ws 的 8×20992×16 bit 逻辑容量为 335872 B，HLS 64 BRAM18 估计仅能容纳 147456 B；当前 generated RTL 保留完整尺寸，没有已观察截断故障。同源 OOC 必须审查完整地址范围、RAM primitive 和 shell 后资源，不能把 HLS 总 341 BRAM18 当作已成立的物理预算。

[C1 详细算术合同](../results/attention_rtl_repair_20261008/q8_c1_arithmetic_pipeline_design_draft.md)已通过[独立审核](../results/attention_rtl_repair_20261008/reviewer_q8_c1_detailed_arithmetic_pipeline_design_review.json)，仍属候选设计；Scorer 三命令证据现已取得；实现与执行仍待实际源/预算分阶段审核。这次联合预算审核没有启动任何 CPU、EDA 或 C1 实现。


“一次一个重工具”只约束**本 Laya 工作流及其全部代理树**，不要求服务器无关任务停下。沿用具体实验已批准的 CPU 数、nice19、idle I/O、任务树 RSS/wall-time、0.2 s 采样与 MemAvailable≥192 GiB 守护；启动前确认本树无其他重工具，只管理本任务拥有的进程。本文不扩大预算，不修改其他工程或旧运行证据。

模块继续使用现有 `source/design.md` 与 `source/results.md`，新运行保存独立目录、实际命令/工具版本、退出码、完整日志、输入/制品哈希与审核结论；失败保留。改变源或配置即重新绑定身份，按受影响范围验证，不为了更新状态重复已接受且未改变的测试。

长期任务分三个结论交付：**完整功能验收**需要同身份完整请求 RTL 与板上数值/恢复；**性能达标**需要真实架构系数、板上实测和冻结的 50 ms 判据；**平台完成**需要实际 U55C/XRT/PCIe/HBM 链接、布局布线和可重复运行。本次离线交付按阶段 1–4 的实际证据分别验收，附上平台可离线准备的成果和待板卡清单；不能因暂无板卡停止可完成的离线工作，也不能把离线完成写成上板或 50 ms 已达。软件 PASS、生成成功、OOC 无黑盒或单个切片 PASS 均不能代替其他层级。

当前未覆盖项包括：预置 Attention v5 其余 head/query/shape、真实生产链、时序及暖复位元数据、D2-I binary `src1` 数值 RTL 与真实 Encoder/producer 连接、其余 D2 边界、完整新 top 重建与 RTL、Q8 其余真实全 K/N 多行、多 tile/尾行与性能观测、性能结构修订、真实 XRT/平台与业务服务集成、板上质量/稳定性及同口径性能对照。D2-I unary Mode3、Attention cold V2 的 B1/S64 layer0 head0/query0 四命令、静态 AXI 四模式与 portable Host CPU 均仅关闭各自明确范围；旧 VIP 根因仍未知，但不阻止有界真实 DUT 验证。

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
| 2026-10-08 | AXIv2 idle观察接受、traffic首对无首B采样标记而失效；wait_trace_v3修正源码通过；queue_exists_v1静态快照通过 | 一次wait静态与一次queue idle按各自新身份/预算串行；原traffic不重跑，不提前断言物理总线X或根因 |
| 2026-10-08 | Attention v2严格CPU和标准libm CSim独立接受，85输入/26编译规则闭合；CSim3合法17负例与v1一致 | 一次v++局部综合16GiB/1800s已放行；审查实际IR/source checks/生成路径后再定RTL |
| 2026-10-08 | Stage5 Host可移植协议核心设计完成，纳入异常所有权、精确384B和身份耗尽，原13BO/五模型/每请求同步范围固定 | Sol低优先级准备source/API/TB与4GiB/120s CPU证据；未启动真实XRT/平台工作，不关闭阶段5 |
| 2026-10-08 | Q8首批真实ACT冻结源码/严格CPU独立接受，12项项目include闭包及7个生产头保持fe067；初审跨列块错误屏蔽已修正 | 先执行队列中AXIv4，再legal及条件fault_load标准libm CSim各16GiB/600s；综合/RTL/其他矩阵/性能不随CPU通过而接受 |
| 2026-10-08 | AXI sampled_wait_v4的五处等待改动和20文件静态快照独立接受；原始构建exit0、81.63s、峰847544KiB | 新idle完整通过后条件traffic各4GiB/90s，保留完整1024对事务/七页内存检查；任何失败停止，不自动加预算 |
| 2026-10-08 | AXIv4同快照idle100000时钟独立接受，ownRSS10k→100k仍16.1876KiB/clock；traffic首W sampled while同刻假谓词退出后fatal，0pairs | 失败原件/81文件绑定冻结，无重跑门；下一诊断保留exactautomatic/nestedfork/hiercounter上下文并先观测完整guard，Q8CSim继续 |
| 2026-10-08 | Q8首批ACT两种实际标准libm CSim独立接受，124个文件和30项非系统编译依赖闭合，legal/fault_load完整PASS；实际综合配置67个唯一绑定匹配 | Sol按exact新配置执行单次局部综合16GiB/1800s；随后审查实际IR、II、RAM/FP及复位/接口，RTL/OOC不随本门放行 |
| 2026-10-09 | Q8首次局部综合失败已独立接受，两个local tag pointer table触发214-134；无guard/OOM，无调度/RTL；原源审兼容性遗漏已明确记录 | tag_direct_v2仅两处直接tag数组访问的新身份源码准备；冻结v1，候选先源审再CPU/CSim/综合，通用数值与FP denormal另核 |
| 2026-10-09 | Attention v3源码/严格CPU独立接受，3合法17负例与v2逐行一致；前端首启动态库缺失exit127且无IR | 使用工具原有三目录库前缀作局部环境修正，一次8GiB/120s前端；不重CPU，实际IR后再门控CSim |
| 2026-10-09 | AXI guard_trace_v5实际源码独立接受，40文件对仅top/build改变，35本地SV闭包保持 | 单次16GiB/300s静态构建，snapshot先审再traffic；无新idle或匹配RSS结论 |
| 2026-10-09 | Attention v3环境修正后实际前端IR独立接受，315绑定与171依赖闭合，26字段有序初始化、top构造调用为0；原exit127保留 | 一次标准libm CSim16GiB/600s按真实v3配置，实际编译与3+17用例另审后再门控综合 |
| 2026-10-09 | Attention v3实际标准libm CSim独立通过，单次局部综合仍38项pointer-to-pointer失败，无guard/调度/RTL | 聚合初始化不足；封存551work/实际依赖和首失败，不原样重跑，以新IR/剩余逃逸证据决定下一门 |
| 2026-10-09 | Q8 tag_direct_v2严格CPU和实际双标准libm CSim独立通过，372绑定/每mode30非系统依赖保持 | 精确同源配置的一次16GiB/1800s局部综合优先执行，真实RTL/schedule及reset/FP/接口另审 |
| 2026-10-09 | AXI guard_trace_v5实际static及单traffic失败独立接受；fullguard1却无body-entry，同刻count0后Fatal | 无原样重跑/新idle/RSS配对，先设计exact上下文的分支/控制继续对照；Q8优先 |
| 2026-10-09 | Q8 v2局部综合生成独立接受，真实State普通复位遗漏；HLS21.308ns及II4/7不达目标 | 隔离v3只复位元数据，源审后继承未变CPU/CSim；新综合先核reset，再门控数值RTL，性能修正单独设计 |
| 2026-10-09 | Q8 reset v3 局部综合与生成复位结构通过；Attention v4 条件合同及固定数组 AXI 独立端口验证合同已放行 | Sol 自检通过后串行有界执行，首次意外失败停；实际 Q8 ACT/负例恢复/暖复位 DUT 绑定先准备，数值运行另门 |
| 2026-10-09 | Attention v4 CPU/CSim接受，综合在report pair大小/nullable select两处SYNCHK停止，无RTL | v5固定pending.pair+boolpresence精确条件链；保持四调用可见性与清理顺序，AXI端点主路径优先 |
| 2026-10-09 | 静态 AXI 四模式独立接受；Host 修正测试设置后完整 CPU 304 项通过，真实政策/fixture 未变 | 真实 Q8 ACT 双 AXI-Lite/页映射/RTL 验证优先；Attention v5 串行推进，Host 真实平台待办保留 |
| 2026-10-09 | Attention v5 严格 CPU/CSim、实际 RTL/IP 及计算路径结构独立接受；5.390 ns 未满足含 uncertainty 的时序预算，暖复位未清会话元数据 | 按冷启动合同准备有限数值 RTL；Q8 ACT 双 Lite/41 页/36 命令优先，联合性能和 Host 同步成本保留 |
| 2026-10-09 | Q8 ACT 实际源码包独立接受，865 文件/41页/36命令原数值gold绑定；完成同沿done、末拍停顿、输入全页及实际RAM样本检查 | 单次静态后按条件运行三组，首次异常停止；尚无数值RTL通过结论 |
| 2026-10-09 | Q8 ACT 一次静态及合法9/恢复3/身份暖复位24条真实RTL命令全部独立接受；原始位型采样范围和测试台时钟边界明确 | 已通过36条不重跑；继续真实全K/N少行、多tile/尾行/性能源准备与Attention冷启动准备，完整mission保持活动 |
| 2026-10-09 | 已冻结全 K/N、多 tile/尾行与被动性能观察源合同，首例 Scorer FC1 K1024/N1024；六对历史 R0/DUT 检查点重新核验相同 | 先 Attention 冷启动实际包；Q8 后继源准备自主继续，首例实测后分阶段扩展，不直接启动旧 F0 整网 |

| 2026-10-09 | Scorer 全维 V4 材料化与 LOAD/trace 开关三命令 CPU 独立通过；静态入口权限与 v3 TB 保留字两次首错均封存 | V5 只修命名块、bash 入口和显式快照绑定；CPU/fixture不重跑，随后继续有限 RTL；任务持续活动 |
| 2026-10-09 | Scorer V6 K1024/N1024 单行 LOAD、trace 开/关三命令数值 RTL 正式独立验收；同一 DUT 保留 W，4096 issue/retire 每 RUN，已量得真实时钟与停顿 | 保留单行范围及 150 MHz 条件口径；三行/FP/OOC 分别源码准备、审核和门控执行，完整核与 50 ms 目标仍活动 |
