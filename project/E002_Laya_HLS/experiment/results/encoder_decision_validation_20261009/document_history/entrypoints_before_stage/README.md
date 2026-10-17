# Laya U55C / Typed Decisions Q8_0

当前没有板卡，先完成离线验证；整个离线工程仍未完成。唯一活动入口是 [mission/task.md](mission/task.md)。本轮规定的 Head15、Ws 有效容量、Scorer 三有效行和 Type 两个完整冷请求均已集中验收通过，限定阶段范围完成；C1 暂停。尚无完整新核数值 RTL、板上频率、50 ms 达标或与 A6000 同口径加速比结论。

当前状态（2026-10-09）：

| 路径 | 状态与已验证范围 | 下一步 |
| --- | --- | --- |
| 联合 Q8 原型 | **ACT 36 条、Scorer 单行及有效不同三行三命令数值 RTL、R0 有限域 adapter 已验收；Ws 实际 DCP 的 335872 B 有效容量通过**；原型 OOC 资源与 WNS −1.762 ns 保留，原 FP 119 例仍有 33 例不符 | 其他矩阵/完整链与平台另验；C1 v3 仅源码，本轮暂停 |
| 共享静态 AXI 环境 | **单位验证完成**：32/512 位共 1,024 组读写、全内存与排空、3 拍响应反压、两项协议拒绝通过 | 绑定真实 Q8 RTL/IP 和有限物理页；单位场景不代表完整 DUT 或 HBM 性能 |
| 外部预置 Attention | **B1/S64 head0/query0 与本轮 head15/query63 的四命令数值/协议均已通过**；v7 HLS 复位静态结构已接受，旧 monitor 失败保留 | 动态 pin reset、其他 shape 与生产 QKV/Encoder 连接待验 |
| D2-I Linear/Vector | **unary Mode3 局部数值 RTL 及 Type qtype2/qtype1 两个完整冷请求均已验收**；Type 每例 65536 F32、206 映射页、状态/owner、末端 R/B hold 与首次 done debt 通过 | Type 仅 cold，10 metadata 无 ordinary reset；Encoder/更多 shape/暖恢复与完整生产链待验 |
| Host 会话策略 | **离线 CPU 完成**：真实共享 codec 与冻结请求/结果，304 项检查通过 | 保留真实 XRT、设备终态和部署集成待办；此结果使用确定性测试后端 |
| 新完整核 fe067 | **软件完成、硬件待验证**：完整 CPU 门禁及真实 13 口 B2 CSim 通过 | 同一身份的完整数值 RTL、资源和平台集成 |

本轮权威入口：[阶段结果表](results/offline_validation_20261009/stage_results.md)、[Type 续跑集中验收](results/offline_validation_20261009/type_resumption_final_acceptance.md)。先前三项复用[原集中验收](results/offline_validation_20261009/final_acceptance.md)，其当时的 Type 成本阻塞与历史失败原样保留。下文历史“待审/未运行”按当时状态理解，当前结果以上表和续跑验收为准；[本次文档精确前像](results/offline_validation_20261009/document_history/status_before_type_resumption_acceptance_20261009/manifest.json)可追溯。本轮未验证完整 Encoder/Decision、FC1→ACT→FC2、P&R/Fmax、上板或 50 ms。

独立证据：[Q8 复位结构](results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)、[Scorer 单行 RTL 正式验收](results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_full_functional_acceptance.json)、[AXI 四模式验收](results/attention_rtl_repair_20261008/reviewer_axi_bounded_static_v1_final_unit_review.json)、[Host CPU 验收](results/attention_rtl_repair_20261008/reviewer_host_session_tb_setup_v2_cpu_acceptance.json)、[Attention v5 独立审核](results/attention_rtl_repair_20261008/reviewer_attention_v5_software_synthesis_structure_review.json)、[Attention cold V2 四命令验收](results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)及 [D2-I unary Mode3 正式验收](results/attention_rtl_repair_20261008/reviewer_d2_i_mode3_unary16_final_functional_acceptance.json)。各轮原始日志、绑定与失败均保留；[本次更新前的四份文档全文](results/attention_rtl_repair_20261008/document_history/mode3_unary16_r0_ooc_status_before_20261009/manifest.json)供追溯。

[FP 七封装 119 例实际边界表征验收](results/attention_rtl_repair_20261008/reviewer_q8_actual_fp_boundary_119_characterization_acceptance.json)确认 119/119 均有连续三个稳定、有效样本：86 例与独立 R0 位型相同，33 例不同（fdiv 5、fmul2 4、fmul3 4、fadd 4、fcmp1 8、fcmp2 8；sitofp 0）。首例 `037e0000 / 42fe0000` 期望 `00400000`、实际 `00000000`。这是**完整失败表征，不是通用 R0 数值通过**；原 119 例源码、金值和日志冻结不改。[R0 有限域 adapter 实际数值验收](results/attention_rtl_repair_20261008/reviewer_q8_r0_finite_adapter_actual_numerical_acceptance.json)已完成独立金值复核、实际静态快照及一次 24.236 s 有限 XSim：65 组、14 个标量、18 个恢复用例，另有一个 smoke 用例中的 7 个封装输出；3067/3067 字段通过，其中 2721 项对独立表金值、346 项检查动态稳定关系。该组合每例保持 32 clocks、取 3 个相等样本，valid 只在末样本检查；`group_committed/status/bad` 由测试台建模。此结论限于已测有限域 adapter，原 119 例失败仍保留，生产 C1 的原子写入、credit/hazard、退休及集成尚未闭合。

[D2-I unary Mode3 正式验收](results/attention_rtl_repair_20261008/reviewer_d2_i_mode3_unary16_final_functional_acceptance.json)确认一次冷启动请求的数值、协议与身份：AP 接受至首次完成 23,064 周期，测试台 PASS 时总计 23,272 周期，首次完成时 14 个双侧物理端口摘要和 35 个 adapter 通道无欠账；16 个 masked F32 位型与整页原始输出独立核对。先前 [0 ps plusarg 入口失败](results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_alias_v2/runs/runtime_first_failure_evidence_v1.json)及[准备路径失败](results/attention_rtl_repair_20261008/d2_controller_reachable/rtl_static_mode3_alias_v2/runs/plusarg_entry_overlay_v2/preparation_failure_evidence_v1.json)均保留，不计为数值通过。binary `src1` 和真实生产连接仍未关闭。

Q8 同源 OOC 工程准备的[第一次首错](vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/project_prepare_v1_control/stage2_first_failure_evidence.json)是 Vivado `set_property` 不接受 `-mode out_of_context`；[local import a1 首错](vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/runs/project_prepare_local_import_v2_a1_control/stage2_first_failure_evidence.json)先见 Python 环境变量污染，清理环境后检查器又发现 7 份 XCI 的 `OUTPUTDIR` 差异超出当时白名单。两次均在 `generate_target` 前停止，作为历史首错保留。[后继实际同源原型顶层综合](results/attention_rtl_repair_20261008/reviewer_q8_actual_top_ooc_synthesis_and_partial_characterization_acceptance.json)已由一次启动完成：243 个编译文件、108 个 DAT、7 个 IP，0 blackbox，最终 5 warnings、0 critical、0 errors，并保存 DCP。随后报告因不支持 `report_timing -unconstrained` 停止；未重综合。[仅打开该 DCP 的报告恢复](results/attention_rtl_repair_20261008/reviewer_q8_dcp_report_timeout_and_partial_timing_characterization_acceptance.json)在 1800.441 s 超时，owned RSS 峰值 4,880,492 KiB，未触发内存门；完成第一遍 Ws 清单及综合后时序诊断，第二遍全 primitive 提取未完成。该次部分报告的 WNS −1.762 ns、TNS −453.591 ns、928 个 setup 失败端点，最差路径位于量化相关逻辑。DCP 的 6.667 ns 时钟与 0.035 ns 派生 uncertainty 不同于 HLS 的 1.80 ns uncertainty，不能据此声称 Fmax 改善；尚无布局布线或 150 MHz 达标结论。[紧凑 Ws 提取的实际部分证据](results/attention_rtl_repair_20261008/reviewer_q8_ws_v3_timeout_and_partial_graph_characterization_acceptance.json)已独立审核：900.322 s 达限、峰值 RSS 3945996 KiB，留下 139 cell/135 primitive、14266 pin、96804 属性行；最终 nets/boundaries 均为零，结构检查因不完整图失败。不能据此声称映射 PASS、DUT 错误或内存泄漏。[v4 语义属性分组查询](results/attention_rtl_repair_20261008/reviewer_q8_ws_v4_semantic_property_batch_source_preparation_release.json)仅放行新 sibling 的源码准备，全 8×20992×16 位物理映射另验。

[该 Q8 原型的实际 OOC 资源](results/attention_rtl_repair_20261008/reviewer_q8_actual_top_ooc_synthesis_and_partial_characterization_acceptance.json)为 LUT 156148、FF 108098、DSP 41、RAMB36E2 219＋RAMB18E2 41（239.5 BRAM tiles）、URAM 192。独立层级复核发现 1024 个 signed INT8×INT8 乘法器，每个 61 LUT、0 DSP，共 62464 LUT；41 个 DSP 的完整归属仍待紧凑清单确认，不能把条件性的 DSP packing 预算当作此原型实测映射。资源仅属该联合原型，不能外推为完整模型或带平台 shell 的适配结论。

ACT [36 条命令整体独立验收](results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_full_functional_acceptance.json)完成：合法 9、错误 LOAD 恢复 3、身份与暖复位 24；865 个绑定文件、346 个静态快照文件及三组输入/原始日志复核通过。完整输出、A8/scale、选定组 trace、双侧 AXI 与恢复均通过。暖复位动态保留 W/A8/FP 输入各一个真实写入的原始位型非零单元；FP 输入为负零 `0x80000000`，PS 未动态抽查。50 个 payload RAM 无批量清空另有静态结构证据。命令最大 6295 个测试台时钟包含控制、总线等待和检查，不是纯计算延迟或频率结论。

Q8 当前 HLS 估计为 21.308 ns，未满足 6.667 ns 请求；量化相关循环实际 II 为 4/7。TM4/TN8 即使理想满发射，B1 纯 Q8 仍约 307 ms，已说明该结构不足以实现 50 ms。旧 64 路 FP Attention 候选的 B1 QK+AV 理想值也约 104.86 ms，需与 Q8 的严格浮点恢复共同核算。ACT 小矩阵功能已通过；后继用真实全 K/N、多 tile/尾行的发射间隔、存储停顿及资源系数修订结构；端到端预算继续包含每请求 184 MiB workspace、32 KiB IO 上传与 384 B 回读，再评估长仿真和整网集成。算量、假设和完整预算见[接口与性能报告](vivado/project/source/performance_and_interfaces.md)与 [mission 阶段 4](mission/task.md)。

[Q8 流水结构独立审核](results/attention_rtl_repair_20261008/reviewer_q8_pipeline_c1_independent_design_review.json)已核实共享恢复 FMUL 的结构服务上界仅 16 MAC/cycle；B1 的量化输入为 22,266,112 个、695,816 组，8 lane 两遍理想串行扫描也需 37.11 ms。若全部 Q8 输出仍按当前 out0/out1 角色落外存，B1 的 out0 为 134,545,416 B，32 位、150 MHz 条件下该口至少需要 224.242 ms；聚合两口的 131.78 ms 只是较弱下界。后继 C1 固定整数树、32 条 R0 恢复通道和量化供给改进由真实 Scorer 观测先行；这些是条件预算，尚无新增吞吐或物理映射结论。

[整网 50 ms 联合必要条件报告](results/attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md)已通过[独立审核](results/attention_rtl_repair_20261008/reviewer_laya_u55c_50ms_joint_budget_independent_review.json)：122 张真实矩阵、Q8 恢复、Attention/KV 复用、量化、LN/GEGLU、加载、输出和 Host 放入同一预算。B2 在 150 MHz、假设每 DSP 两个 INT8 乘积及当前 FMUL3/FADD2 系数下，即使全部 9024 DSP 供 Q8，其工作量下界仍为 52.261 ms；该条件结论不等于所有 U55C 架构都不可能达标。Ws 的 8×20992×16 bit 逻辑容量为 335872 B；历史 HLS 64 BRAM18 估计仅为 147456 B，generated RTL 的数组尺寸完整。实际 DCP 第一遍清单已见 8 个 bank、每 bank 12 个 RAMB36E2，按 x9×6、x4×3、x2×2、x1×1 配置；这只提供配置容量上界。仍须依据 LUT INIT、parity、cascade、CE/WE 和读选择控制证明每 bank 全部 20992×16 逻辑单元写入无别名、读出同一存储，包含 16384–20991 高地址区间；未观察到截断故障，也尚未接受有效容量或 shell 后资源预算。

Scorer FC1 K1024/N1024、B2/S128 选 batch1/row15 的 [V6 三命令数值 RTL 正式验收](results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v6_full_functional_acceptance.json)已完成：同一 DUT 的 LOAD、trace 开 RUN 和同输入 trace 关 RUN，完整输出、A8/scale、选定列全部 32 组 trace、报告与哨兵逐字节通过；两个 RUN 各 4096 次真实 issue/retire，且没有再次读取权重、scale 或 AUX。实际 `ap_start` 接受至首个 `ap_done` 为 1,496,042／1,815,172／1,811,360 clocks；trace 关闭 RUN 的最大实测 issue 间隔为 437 clocks。150 MHz 换算仅为 9.974／12.101／12.076 ms 的条件值，不是板上频率或整网 50 ms 结论。实际 R 通道和 observed 写通道发生停顿，但 terminal hold 控制为 0，不能据此声称末响应停顿已覆盖。原始 `sub_done` 计数含命令起点已高的 idle 样本，不代表子调用次数。[V4 CPU 验收](results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v4_cpu_acceptance_static_prepare_release.json)及[静态首错](results/attention_rtl_repair_20261008/reviewer_q8_full_scorer_v4_static_launch_failure_bash_release.json)仍按原阶段保留；后继 3/4/5/15/16 行、QKV 分片及最大 K/N 按[全维合同](results/attention_rtl_repair_20261008/reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json)另行验收。

后续输入复核确认上述 row15 为 padding（mask=0、索引 128），旧三行 rows13–15 的激活也相同；既有数值验收仍对其冻结字节有效，但不能充当有效不同三行的隔离证据。[有效不同三行后继源码及材料化门](results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_actual_source_and_materialization_release.json)选 batch1/rows0–2，三个 mask/attention 均为 1，输入和输出各自互异。其检查点保留历史 `4f12ecfe940ecf2a8998a8626fc1ed1c` 来源，新描述符绑定当前 `fe067c8aa0627ad770096f9721394645`；不宣称已运行当前身份的完整模型。[实际 fixture 已独立验收](results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_actual_fixture_independent_check.json)：30 个文件、341 页、3072 个 F32 gold 与 32 条 trace/256 字段通过独立复核；后继三命令 DUT CPU 已独立接受，RTL 尚未验收，详见下文。

Attention [cold V2 四命令验收](results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)覆盖 B1/S64 Decision layer0、head0/query0。557 个源、322 个最终快照文件及全部原始输出核验通过；QK 64 字逐位一致、概率符合原容差、AV 64 字与实际概率驱动的顺序 binary32 计算逐位一致。实际 ATT_OUT 为 256 AW/W/B、1024 B 总线写入、256 B 有效输出，读取为 64 AR/R、256 B；剩余 261888 B 哨兵和完整 replay 保留通过。静态构建 190.94 s / 2480596 KiB，运行 103.96 s / 846944 KiB，两者保护均未触发。四命令 26633/1017/500651/3778 个测试台时钟包含 Lite/control，不能当作纯 DUT 延迟或频率。

[V1 首次运行失败](results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v1_first_runtime_failure_review.json)及其缺失 RUN dump/replay 的事实保持冻结；V2 只修正测试台物理写计数及诊断，未改生产 RTL 或金值。Attention v5 的 5.390 ns 仍是 HLS 估计，超过 6.667−1.80=4.867 ns 有效预算；普通硬件复位未清 pending/session。最初的 [head15/扰动输入](results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_changed_finite_source_preparation_release.json)和 [metadata reset](results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_source_preparation_release.json)源码门作为历史依据保留；当前 head15/v7 进展见下文，真实 Q8/RoPE 生产链、物理时序和 50 ms 仍待闭合。

旧 04934 制品虽完成无黑盒 OOC 综合，其生成 RTL 存在已定位的控制路径缺陷；旧资源不能作为新 fe067 功能与资源的联合验收。先前 VIP 的内存增长和等待异常保留为历史观测；新静态环境的有限 RSS 平稳结果没有证明旧异常根因。详细边界见 [AXI 结果](results/attention_rtl_repair_20261008/d2_axi_allocation_diagnostic/source/results.md)、[Attention 结果](results/attention_rtl_repair_20261008/d2_attention_preloaded/source/results.md)和[综合结果](vivado/project/source/results.md)。

已有 [A6000 测量](../../results/laya_gpu_inference_benchmark_20261005.md)约 24–25 ms，但模型、精度、序列和候选规模不同，不能直接换算本工程加速比。

[Attention v6 严格 CPU](results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_actual_strict_cpu_acceptance.json) 与 [实际 CSim](results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_actual_csim_acceptance.json) 已接受 3 个合法数值、17 个负例和 3 个暖恢复场景，范围仍是软件 reset hook。[v6 HLS 名字解析首错](results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_actual_hls_first_failure_acceptance.json) 冻结保留；v7 仅调整 using 作用域，继承未变执行体的数值依据，不称为新 CPU/CSim 执行。[v7 实际 HLS 静态结构验收](results/attention_rtl_repair_20261008/reviewer_attention_v7_actual_hls_structure_and_partial_characterization_acceptance.json) 已完成：229 个 Verilog module、7 个 AXI master、双 Lite；有效低同步 pin reset 复位 metadata_initialized 与控制 FSM，首次命令等待 metadata 初始化完成后才派发。已检查的 KV、score、av_partial 数值存储写路径无普通 reset，不能外推成全部源字段到优化后存储的完整映射证明。初始化器 6738 cycles 不是完整顶层有限延迟；实际 pin reset、打断初始化重启、复位后数值、暖会话和 CSR 重绑均未执行。HLS 估计 80 BRAM18、22 DSP、57403 FF、203311 LUT，5.390 ns 超过 4.87 ns 有效预算；尚无物理时序通过。

[真实 Type producer 的 qtype1 期望数据](results/attention_rtl_repair_20261008/reviewer_d2_type_producer_qtype1_actual_materialization_acceptance.json) 保留与 qtype2 不同的请求、Type 行及各 65536 个 F32 gold。[两个冷启动 CPU 用例](results/attention_rtl_repair_20261008/reviewer_d2_type_producer_md_v2_actual_two_cold_cpu_acceptance.json) 已独立验收：各运行真实 Controller 的 1 个 EMB_TYPE 和 4 个 binary ADD_TYPE，完整输出、TYPE_ROWS、STATE0/STATE1、IO 与哨兵由已核验二进制内比较；没有独立原始 dump 复算声明。[实际 Type HLS 静态结构与部分表征](results/attention_rtl_repair_20261008/reviewer_d2_type_producer_actual_hls_structure_and_partial_characterization_acceptance.json) 已接受：229 个 Verilog module、7 个 AXI master、双 Lite，10 个持久 runtime 标量没有普通硬件 reset。估计 28 BRAM18、25 DSP、33016 FF、122138 LUT，5.158 ns 超过 4.87 ns 有效预算，顶层 latency/interval 未定。[冷启动有限 RTL 源码门](results/attention_rtl_repair_20261008/reviewer_d2_type_producer_actual_hls_cold_finite_rtl_source_preparation_release.json) 只放行源码准备；qtype2 与 qtype1 将分别使用新冷进程，未放行静态编译或仿真，不声称暖复位通过。

[Head15/query63 monitor-v2 首错复核](results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_passive_monitor_v2_actual_first_failure_diagnosis.json) 保留 cmd2 首个选择性 R hold 的 `monitor=x endpoint=1 adapter=1` 失败；该次只有 cmd0/1 PASS，无 cmd2 数值输出、cmd3 或四命令 seal。[v3 显式 119-bit 记录端口源码与 source-seal 验收](results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_monitor_v3_actual_source_and_seal_acceptance.json) 已核全部七口连接与有界三层诊断，原 hold/debt/数值检查不变。[v3 实际静态编译验收](results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_monitor_v3_actual_static_acceptance.json) 已完成：622 项冻结前后绑定、614 项 source、12 个 prepared 文件及 318 个快照文件精确，193.870 s、2471176 KiB，43 条 xelab warning 保留，无 error/guard trigger。后继 [v3 一次运行实际失败包](results/attention_rtl_repair_20261008/d2_attention_preloaded/v5/rtl_static_finite_monitor_v3/runs/rtl_base_h15_r63_monitor_v3_v1/evidence/actual_execution_packet.json) 已封存：guard 6.263 s、844040 KiB、无资源触发，四阶段退出码 0/1/0/0。14 个底层 monitor 复位见证均为零，但 6666 ps 顶层 `ATT_R_RECORD_TOP_RESET port=0` 复合检查失败，早于任何命令；日志未打印顶层原始 record/count，未知值与非零分支、端口传播及表达式求值尚不能区分。没有本次数值输出或四命令 PASS；实际失败仍待独审，小型同连接诊断另立源码身份，原断言及失败证据保留。

[Scorer 有效不同三行 CPU 验收](results/attention_rtl_repair_20261008/reviewer_q8_scorer_md_v3_actual_three_command_cpu_acceptance.json) 保持一个冷进程 LOAD_W、trace 开 RUN、trace 关 RUN 的既有完整比较范围；[实际静态编译验收](results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_actual_static_acceptance.json) 新增 825 项前后绑定、108 个 DAT 目标和 346 个快照文件的精确核验，212.869 s、4186424 KiB，无 error/guard trigger，55 条 xelab warning 保留。[实际页序列化独立验收](results/attention_rtl_repair_20261008/reviewer_q8_scorer_distinct_valid_rows3_actual_serialization_acceptance.json) 已接受 13 个 memh：2011136 B 原始数据、6033408 B 文本逐字节等于冻结 fixture，341 个初始页、1201 项绑定及 349 个快照条目核对通过。三有效行的实际 FSM、子调用、有界响应与墙钟预算仍在推导，XSim 尚未放行；7M/16M watchdog 仅是失败上限，旧单行 1051.984 s 不能支持沿用 600 s 仿真门。

[C1 旧候选可行性拒绝](results/attention_rtl_repair_20261008/reviewer_q8_c1_write_response_actual_source_feasibility_review.json) 的完成结果延迟与额外 28008 个逻辑位问题保留。stage-v2 源码接手又报告 classify_actor 向深度一 FinalReturn FIFO 阻塞写，而 consumer II 未测，尚不能满足无 ready 的固定返回合同。[直接写预留槽的有界源码纠正门](results/attention_rtl_repair_20261008/reviewer_q8_c1_direct_reserved_return_rtl_shell_source_preparation_release.json) 要求先精确归档 stage-v2，再在独立 sibling 准备显式时钟 RTL Q64/D4 store/controller 与独立算术/AXI writer 服务接口；预约/READY/退休 metadata 单一归属，return 写不等 writer/B，g0/失活/失败 lane 不读未初始化 PS。dormant 探针、未绑定 wrapper、服务 latency/II、固定返回、物理资源与数值集成均须如实列明；只有源码工作许可，没有 C1 执行或流水 PASS。[stage-v2 的 45 文件精确前像](vivado/module_design/q8_linear_and_restore/c1_pipeline_stage_v3_direct_return/source/prior_stage_v2_manifest.json) 已保存，v2 随后冻结。v3 正在准备显式时钟 store/controller、writer 接口和探针源码；算术/writer 尚未绑定为已验证生产服务，未编译或仿真。

[Ws v5 源码独审拒绝](results/attention_rtl_repair_20261008/reviewer_q8_ws_v5_actual_export_source_acceptance_and_parser_holds.json) 封存非空失败状态 DCP 属性被忽略、变量初始化被误作连续 alias 的合成复现；旧 v5 源码包保持不变。[v6 实际源码验收](results/attention_rtl_repair_20261008/reviewer_q8_ws_v6_actual_source_acceptance.json) 已接受 15 份 v5 前像、修正后的状态拒绝/结构解析/预分配上限，19 组源级 synthetic 检查及 9 个独立对抗拒绝案例通过。[实际 DCP/export/graph 独立验收](results/attention_rtl_repair_20261008/reviewer_q8_ws_v6_actual_export_graph_acceptance.json) 已接受一次只读提取：89.017 s、3952328 KiB、无 guard trigger，8 份导出共 1858508 B、11 张完整图表、368 cells/37936 pins/1330 nets；768 个原始属性缺口单独保留。[后继实际 join 首错包](vivado/module_design/q8_linear_and_restore/metadata_reset_v3/ooc_v1/ws_dcp_connectivity_v6/runs/property_join_v1/evidence/evidence_packet.json) 记录一次 3.068 s/54064 KiB 运行因不支持实际导出的 `ifndef` 指令而停止，177 项前后输入一致，无资源触发、未重试。join 未完成；首错待独审，全 8×20992×16 地址/位映射、有效容量和物理时序均未接受。

离线验证仍未完成。数值通过只覆盖各自冻结身份和已测场景；HLS/OOC 资源表征与条件预算分别保留，时序、完整核资源、生产连接及端到端 50 ms 尚未闭合。

本次状态补记采用 [Astra 核定事实措辞](results/attention_rtl_repair_20261008/document_history/scorer_static_ws_v6_head15_v3_before_20261009_v1/astra_approved_factual_wording.json) 和后继实际包；[README/mission 本轮精确前像](results/attention_rtl_repair_20261008/document_history/scorer_static_ws_v6_head15_v3_before_20261009_v1/manifest.json) 保存更新前全文。既有历史文档引用的四个 mission 旧哈希均有精确归档；当前活动门和源码包不直接绑定这两份可变总览。冻结源码、数值输入和首错证据保持不变。

## CPU、FPGA 和 HBM 的分工

部署结构是外部服务器 CPU 通过 PCIe 驱动 U55C。U55C 是 FPGA 加速卡，没有负责本项目应用流程的片上 CPU；XRT Host 在服务器 CPU 上运行。

| 部分 | 本工程中的职责 | 当前状态 |
| --- | --- | --- |
| CPU 应用与 [XRT Host](host/laya_host.cpp) | Host 读取预编码请求、校验模型包与 xclbin 身份、上传五个模型 BO、分配工作区、启动一次完整 forward、回读/校验/保存结果；分词、请求编码和业务解码由 CPU 应用层负责 | Host 源码已实现，应用层尚未完整接入；真实 XRT 构建、设备运行未验证 |
| PCIe / XRT / 平台 shell | 连接 Host 与 FPGA，完成数据传输、kernel 启动和设备管理 | 实际 `.xpfm` 平台尚未提供，未完成链接 |
| FPGA kernel `laya_typed_q8_forward` | C++实现/部署合同：请求与模型身份检查、整图调度、全部数值运算、缓存状态管理、错误恢复和结果提交 | fe067完整CPU/B2 CSim通过；旧04934的HLS RTL/IP/OOC有QK/AV固定E_SHAPE缺陷。fe067完整数值RTL与同源资源尚未验收 |
| HBM 与片内缓存 | HBM 保存模型权重和主要中间张量；片内缓存保存当前权重、激活 tile、部分和及控制元数据 | 裸 OOC 存储映射已取得；平台 HBM 连接与布局布线尚未验证 |

CPU 上运行的独立 oracle 和 DUT 验证程序用于检查功能。部署接口只提交一次完整 kernel 调用，28/2 层循环由 FPGA 内部 controller 执行。Host 目前是处理预编码 ABI 请求的工程入口，尚未集成完整分词、服务和业务解码流程。代码见 [Host](host/laya_host.cpp)、[完整顶层](hls/platform/full_kernel_wrapper.cpp)和[整图 controller](hls/control/full_forward_controller.cpp)。

## 一次推理的完整流程：CPU 与 FPGA 各做什么

以下是**C++/CPU/CSim已验证的完整执行图与预期部署合同**。旧04934生成RTL因上述控制缺陷不能成功完成这条流程；修复后fe067的完整请求RTL尚未验收，尚无上板实测。合同规定一次kernel处理整段输入，输出每题候选分数和ACT分数，没有逐token自回归生成循环；CPU功能仿真代执行算术不等于这些步骤已在FPGA成功运行。

```text
离线 CPU：冻结 GGUF → 导出五个模型文件、manifest 和编译用描述表
                              ↓
CPU 应用：文本/业务输入 → 分词、候选位置等 → 预编码请求文件（应用层待接入）
                              ↓
CPU Host：校验文件 → 加载 xclbin → 分配 13 个 BO
          → 经 PCIe 上传模型、初始化工作区和 io 请求 → 启动一次 kernel
                              ↓
FPGA：读请求 → Embedding → 28 层 Encoder → Type Embedding
       → 2 层 Decision → 候选 Scorer → ACT → 把结果帧写回 io
         ↕ 各阶段由 FPGA 自行读写 HBM，按需使用片内缓存
                              ↓
CPU Host：等待完成 → 经 PCIe 回读 384 B 结果 → 保存并校验结果帧
                              ↓
CPU 应用：把候选/ACT 分数转换成业务答案或动作（应用层待接入）
```

### 从模型文件到启动 FPGA

| 顺序 | 谁执行 | 具体工作与数据去向 |
| --- | --- | --- |
| 1. 离线模型准备 | CPU 上的[模型导出器](tools/export_gguf.py) | 读取冻结 GGUF，整理 Q8 权重、scale、Embedding 和辅助参数，生成 `embedding.bin`、`w_q0.bin`、`w_q1.bin`、`w_scale.bin`、`aux.bin`，以及 manifest 和编译用描述表。构建时 FPGA 使用固定描述表，运行时不解析 GGUF/JSON；这一步不在每次 kernel 内执行 |
| 2. 准备本次输入 | CPU 应用层；当前 Host 读取准备好的文件 | 应用层应完成分词、padding、候选位置/有效性和题型编码，形成带 model/numeric/layout/build 四个 tag、request_id、generation 和 B/S 的 ABI 请求。**现有 Host 不执行分词，也不自动从文本打包请求**；它读取 `--request` 指定的预编码二进制文件并校验 |
| 3. 初始化设备和内存 | CPU 上的 [Host](host/laya_host.cpp) 调用 XRT | 校验 xclbin SHA、模型 manifest 和请求身份，打开设备、加载 xclbin，按 `kernel.group_id(0…12)` 分配 13 个 BO（设备内存缓冲区）。`group_id` 表示 kernel 参数的连接组；实际 HBM bank 连接仍需平台链接确认 |
| 4. 上传与启动 | CPU Host / XRT，经 PCIe 传输 | 校验并上传五个模型 BO；将七个工作区清零并整区上传；清零 32 KiB 的 `io`、放入请求，再同步整个 `io`。随后用 13 个 BO 参数启动一次 `laya_typed_q8_forward`，Host 等待完成 |

当前 Host 是一次进程运行、一次 kernel 调用的入口。**每次启动 Host 都会重新分配 BO、上传模型和初始化工作区**，尚未实现“模型上传一次、Host 服务连续处理多个请求”的部署模式。已有同一 Runtime 连续请求/故障恢复证据属于功能验证范围。

无板卡阶段已[放行Host协议核心的离线准备](results/attention_rtl_repair_20261008/reviewer_host_session_offline_v1_design_cpu_preparation_release.json)，设计包含身份顺序、单个在途请求、精确384B结果与超时后所有权；保留每请求184MiB workspace和32KiB IO同步。测试backend的分配/上传事件只验证协议逻辑，真实XRT适配、常驻服务和设备性能尚未验收。

本次请求实际包含以下五组输入，见[请求解析](hls/common/laya_full_io.cpp)和[输入结构](include/laya_full_runtime.h)：

| 输入 | CPU 提供的数据 | FPGA 用途 |
| --- | --- | --- |
| `token_ids[B,S]` | INT32 token 编号 | 查 Token Embedding 表 |
| `attention_mask[B,S]` | U8 有效 token 标记 | Attention 屏蔽 padding 等无效位置 |
| `marker_positions[B,16]` | INT32 候选位置，采用 ABI 规定的展平索引 | 从最终 hidden 中提取每个候选对应的向量 |
| `marker_mask[B,16]` | U8 有效候选标记 | 候选分数屏蔽和有效候选统计 |
| `qtype[B]` | 每题一个类型值 0…2；请求中为 INT32，解析后保存为 U8 | 在 Encoder 结束后选择该题的 Type Embedding；不是每个 token 一份 type_id |

### FPGA 启动后，整网计算都在卡内完成

以下步骤由 [FPGA controller](hls/control/full_forward_controller.cpp)顺序发起。**CPU 不逐层调用算子，也不逐层取回中间张量。** 28 个 Encoder 和 2 个 Decision 是 controller 内部的层循环；层数不表示复制了相同数量的完整并行电路。

1. **读取和检查请求。** FPGA 从 `io` 读取五组输入及请求头，检查形状、索引、mask、四个 tag 和请求序号，再读取 `aux` 中的模型头核对身份；完成请求状态回收/初始化后才进入数值计算。

2. **把 token 编号变成向量。** FPGA 根据 `token_ids` 从 HBM 的 `embedding` 中读取 Q8_0 行，每个 token 的 1,088 B 数据反量化为 1,024 维 FP32 向量；然后执行 Embedding LayerNorm，把 hidden 写入 HBM 工作区。Embedding 查表、反量化和 LayerNorm 都由 FPGA 做。

3. **循环完成 28 层 Encoder。** 第一层直接使用前一步归一化的 hidden，后续层先做 Attention LayerNorm。每层依次计算 QKV，写入 QKV 工作区；对 Q/K 做 RoPE 后，按 head 装入 K/V，执行 `QK → mask → Softmax → AV`。Encoder 每三层有一层全局 attention，其余使用滑动范围 mask。Attention 结果经 `Wo` 投影，与旧 hidden 相加；再执行 `LayerNorm → Wi → GEGLU → Down → 残差相加`。新的 hidden 留在 HBM，供下一层继续使用。

4. **加入题型信息，再完成 2 层 Decision。** FPGA 先做 Final LayerNorm，根据每题 `qtype` 查 Type Embedding 表，并把该向量加到这题各 token 的 hidden 上。随后循环两层 `LayerNorm → QKV → QK/mask/Softmax/AV → Wo → 残差`，以及 `LayerNorm → FC1 → ReLU → FC2 → 残差`。**Decision 阶段不执行 RoPE**，使用全局 attention 的 mask 路径。结果仍保留在 HBM hidden 工作区。

5. **为 16 个候选位置计算分数。** FPGA 按 `marker_positions` 从最终 hidden 提取候选向量，做 LayerNorm、Scorer FC1、bias/GELU 和 Scorer FC2，得到每题 16 个原始候选 logits；再按 `marker_mask` 屏蔽无效候选。接着在 FPGA 内对这些分数做 Softmax，并计算最大概率、最大概率与近似次大概率之差、归一化熵、归一化有效候选数量这四项统计，供 ACT 使用。

6. **计算 ACT 分数。** FPGA 读取本题的 CLS 向量（本题第 0 个 token 的最终 hidden），与上一步四项统计拼成 1,028 维输入，执行 ACT FC1、bias/GELU、ACT FC2，得到每题 2 个 act logits。候选概率和四项统计是这一步的内部输入，不作为最终结果单独传给 Host。

7. **提交结果。** [结果模块](hls/control/full_result.cpp)从工作区读取每题 **16 个已应用候选 mask 的 logits 和 2 个 act logits**，连同身份、状态和诊断计数封装为固定 **384 B 的整个请求结果帧**，写到 `io` 的偏移 16,384 B；有效输出数随 B 为 18 或 36 个 F32。先写 payload/诊断，再写作为提交标记的头部，随后 kernel 返回。

### 算子之间的数据放在哪里

Host 分配的 13 个 BO 分成五个模型区、一个请求/结果区和七个工作区；FPGA 通过对应 AXI 端口访问。主要张量存放如下，具体偏移由[内存映射](hls/common/laya_full_memory.cpp)确定：

| 位置 | 保存什么 | 谁在推理期间读写 |
| --- | --- | --- |
| `embedding / w_q0 / w_q1 / w_scale / aux`，共五个模型 BO | Embedding、Q8 矩阵的两个分片、scale、bias、RoPE/LN 参数和其他辅助权重 | Host 启动前上传，FPGA 按当前算子读取 |
| `io` | 请求头和五组输入；完成后的 384 B 结果帧 | Host 写请求，FPGA 读请求/写结果，Host 回读结果 |
| `state0 / state1` | hidden、归一化/临时数据，以及 marker、type、head 等固定子区域 | FPGA 在各阶段间自行读写 |
| `qkv0 / qkv1` | Q/K/V 张量分片 | FPGA 的 QKV、RoPE、attention 路径读写 |
| `ff0 / ff1` | FFN 宽向量和 GEGLU 等中间值；部分区域按阶段复用 | FPGA 的 FFN 路径读写 |
| `att_out` | 各 attention head 合并后的输出 | FPGA 写入，随后由 Wo 路径读取 |
| FPGA 片内缓存 | 当前权重、激活块、部分和、当前 head 的 K/V、score/prob 等 | FPGA 内部加载器和算子使用，不经 PCIe 逐步回传 |

对一个 Q8 Linear，[加载器](hls/memory/full_loader.cpp)先从 HBM 装入**当前整张 Q8 权重矩阵**（含物理尾部、group scale 和所需 bias）到片内缓存，再处理各激活块；它不是把整个模型同时装入片内，也不是只缓存一个权重 tile。激活每次最多 16 行，输出按最多 8 列窗口计算；部分和在片内积累后写入对应 HBM 张量，完整任务达到 READY 后才交给下一任务。这是当前 F0 的分块、串行执行方式，未实现全流式跨层运算或双缓冲重叠。

Q8 Linear 的输入原本是 FP32，[量化器](hls/operators/activation_quantizer_compute.cpp)会动态计算每 32 个元素的激活 scale 并转成 INT8。[乘加路径](hls/operators/q8_linear_compute.cpp)先做 INT8×INT8、INT32 组内点积，再把保存为 F16 的激活/权重 scale 转成 FP32，缩放并跨组累加，输出 FP32。LayerNorm、RoPE、QK/AV、Softmax、非线性和残差等仍用 FP32；Scorer FC2 是浮点路径，ACT FC1 使用 F16 权重转 FP32 运算。因此权重量化不等于整个推理过程都用 INT8。

### CPU 怎样拿到最终答案

Host 等待 kernel 完成后，通过 XRT 将 `io` 中 **384 B 结果帧**同步回 CPU，写入 `--result` 指定的二进制文件，并检查 ABI/tag、request_id/generation、B/S、成功状态及输出是否为有限数。Host 返回的是这份分数与状态记录，不会回读全部 hidden、QKV、attention 概率或 FFN 中间张量。

根据候选 logits 选取业务候选、解释 ACT 分数、应用业务阈值并组织用户可读答案，属于 CPU 应用层后续接入；当前 Host 没有实现这些业务规则。因而当前完整边界是：**CPU 提供预编码输入并启动，FPGA 完成整段输入的全部前向数值计算，CPU 取回候选/ACT 分数；文本输入与业务答案两端的应用集成仍待完成。**

形状备注：B=1 或 2，S=64/128/256/512/1024，hidden=1024，16 个 attention head、每头 64。完整网络已测 S128，其他四档为任务/地址补充验证；早期并行阵列、64 路 FP 和 25–50 ms 性能目标尚未实现或验收。

## 工程位置、模型身份与工具

**正式工程为本目录 `Laya-baseline`；当前修复源码回归须显式使用 [build/model-attention-rtl-repair-20261008](build/model-attention-rtl-repair-20261008/manifest.json)。** 脚本尚保留的默认`build/model-repair`对应旧04934，不能与新源码/新请求混用。P1/P2/P3只改变controller的metadata表示，正式与隔离源码SHA均为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，见[生产代码审核](results/attention_rtl_repair_20261008/reviewer_production_patch_review.json)及[正式同步审核](results/attention_rtl_repair_20261008/reviewer_official_sync_review.json)。

| 制品/路径 | build tag | 当前证明范围 |
| --- | --- | --- |
| 正式`Laya-baseline/build/model-attention-rtl-repair-20261008` | `fe067c8aa0627ad770096f9721394645` | 当前正式源码；完整CPU门禁141检查点及恢复通过；新B2 top CSim执行通过，RTL待验证 |
| 隔离`Laya-repair-20261007/build/model-attention-rtl-repair-20261008` | `18366c267ae0a7ca0c3afb8c2174b890` | 已执行该身份CPU回归；不是正式工程身份 |
| 历史`Laya-baseline/build/model-repair` | `04934c15b3f83e842ec2e92ac2a81bf2` | 以下既有CSim、HLS RTL/IP和Vivado OOC的缺陷制品 |

两个新包的model/numeric/layout tag不变。正式源码多出纳入身份生成的`tools/collect_performance_facts.py`，故正式build tag不同于隔离副本；未修改冻结前像政策来合并tag。正式新manifest SHA256为`128768a4a42ffa9d5f5dfd2bb9808e0f7a12a7509638f4d5650cb9fd9fb56caa`。新包没有对应已验收的完整RTL/IP或xclbin，不能与旧04934硬件制品配套。

下表保留旧04934制品身份和当时工具配置，来源为[旧回写收据](results/synthesis_memory_fix_20261007/promotion_receipt_04934.json)；归档绝对路径按真实运行现场保留。

| 项目 | 旧04934身份或当时配置 |
| --- | --- |
| build tag | `04934c15b3f83e842ec2e92ac2a81bf2` |
| model tag | `6eb6ef58bc4f99bd9db40381604108af` |
| numeric tag | `aeb13e7937d29fe6a2c68c407249f294` |
| layout tag | `f927881686d9d11c91b7f11ac59e2cc7` |
| 模型包清单 SHA-256 | `26dfb25f876ea6bfbf2d41e4defb7090bbdbcc0ba5c1d17a3ff4e826982f889b` |
| 模型清点 | 153 条 tensor 记录、152 个保留 payload、122 个 Q8 矩阵、124 个 WeightKey |
| 模型大小 | 原 GGUF 455,179,648 B（约 434.1 MiB）；保留 payload 448,921,352 B。权重是外部存储数据，不是逐参数硬化的电路 |
| 构建身份 | 103 项源码/配置输入；实际完整 HLS 清单为 25 份生产 C++ 源 |
| 实测工具 | Vitis HLS 2025.2 / Build 6295257；GCC 13.3.0；CMake 3.31.8；Python 3.12.3、NumPy 1.26.4、glibc 2.39 |
| 实验器件与时钟请求 | `xcu55c-fsvh2892-2L-e`，150 MHz；尚未绑定实际 U55C `.xpfm` 平台 |

旧身份依据为[模型 manifest](build/model-repair/manifest.json)、[严格包验证](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/package_verify/full_model_package_report.json)及[回写后复核](results/synthesis_memory_fix_20261007/post_promotion_review_04934.json)。生产源码、配置或数值合同变化后，需要重新导出身份并验证受影响阶段；历史 `model-p2-final` 和旧 build tag 不代表当前包。

### 15 个模块与源码

手写硬件实现主要在 `hls/`，公共类型和接口在 `include/`；它们由 HLS 转换成 RTL。下表是功能责任划分，目录数不等于独立物理实例数。完整编译范围以[生产源清单](config/full_sources.cmake)为准，[模块登记](config/full_module_registry.json)只记录源码映射，其静态 `unverified` 字段不替代分阶段运行报告。

| 分组 | 模块与详细设计 | 主要源码 |
| --- | --- | --- |
| 集成与控制 | [top](vivado/module_design/top/source/design.md) | [laya_forward_full.cpp](hls/laya_forward_full.cpp) |
| 集成与控制 | [common](vivado/module_design/common/source/design.md) | [include/](include/)、[laya_numeric.cpp](hls/common/laya_numeric.cpp)、[laya_tasks.cpp](hls/common/laya_tasks.cpp) |
| 集成与控制 | [kernel_wrapper](vivado/module_design/kernel_wrapper/source/design.md) | [full_kernel_wrapper.cpp](hls/platform/full_kernel_wrapper.cpp)、[full_cache_storage.cpp](hls/platform/full_cache_storage.cpp)、[full_io](hls/common/laya_full_io.cpp) |
| 集成与控制 | [forward_controller](vivado/module_design/forward_controller/source/design.md) | [full_forward_controller.cpp](hls/control/full_forward_controller.cpp) |
| 存储 | [memory_map](vivado/module_design/memory_map/source/design.md) | [laya_memory_map.cpp](hls/common/laya_memory_map.cpp)、[laya_full_memory.cpp](hls/common/laya_full_memory.cpp) |
| 存储 | [hbm_loader_and_cache](vivado/module_design/hbm_loader_and_cache/source/design.md) | [full_loader.cpp](hls/memory/full_loader.cpp)、[laya_full_owner.cpp](hls/common/laya_full_owner.cpp) |
| 数值运算 | [embedding_engine](vivado/module_design/embedding_engine/source/design.md) | [embedding_full_compute.cpp](hls/operators/embedding_full_compute.cpp) |
| 数值运算 | [layernorm_engine](vivado/module_design/layernorm_engine/source/design.md) | [layernorm_compute.cpp](hls/operators/layernorm_compute.cpp) |
| 数值运算 | [activation_quantizer](vivado/module_design/activation_quantizer/source/design.md) | [activation_quantizer_compute.cpp](hls/operators/activation_quantizer_compute.cpp) |
| 数值运算 | [q8_linear_and_restore](vivado/module_design/q8_linear_and_restore/source/design.md) | [q8_linear_compute.cpp](hls/operators/q8_linear_compute.cpp) |
| 数值运算 | [rope_and_mask](vivado/module_design/rope_and_mask/source/design.md) | [rope_full_compute.cpp](hls/operators/rope_full_compute.cpp) |
| 数值运算 | [attention_and_fp_engine](vivado/module_design/attention_and_fp_engine/source/design.md) | [attention_full_compute.cpp](hls/operators/attention_full_compute.cpp) |
| 数值运算 | [vector_and_ffn](vivado/module_design/vector_and_ffn/source/design.md) | [vector_full_compute.cpp](hls/operators/vector_full_compute.cpp) |
| 决策与结果 | [decision_scorer_act](vivado/module_design/decision_scorer_act/source/design.md) | [decision_full_compute.cpp](hls/operators/decision_full_compute.cpp) |
| 决策与结果 | [result_status](vivado/module_design/result_status/source/design.md) | [full_result.cpp](hls/control/full_result.cpp) |

各算子通过 `hls/operators/full_tasks*.cpp` 接入真实 loader、owner、地址与结果检查。模块的 `source/design.md` / `source/results.md` 分别维护设计和证据；已验收冻结的 variant 保留原字节，后续状态另存新附录。`rtl/` 用于需手工维护的 RTL，`tb/` 存放测试入口。当前生成 RTL 已归档在[完整 HLS 工件目录](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/)，不是把各模块 `rtl/` 目录当成 HLS 输出目录。

[模块目录页](vivado/module_design/README.md)和[历史实施合同](hardware_agent/task.md)可用于导航、理解原约束与阶段演进；其中旧阶段摘要保留原时间范围。当前验收按身份区分：本页与[top结果](vivado/module_design/top/source/results.md)所链旧 `04934…` HLS/OOC保留历史制品事实；新 `fe067…` CPU/CSim及D1/D2以本页最新独立审核为准，不能互相拼接成完整RTL验收。

## 分阶段功能与工程验证

新官方CPU门禁见[本次结果](results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)：build `fe067c8aa0627ad770096f9721394645`，141检查点及故障恢复通过；该CPU报告生成时CSim/csynth/RTL/platform仍为未验证，后续独立13口CSim运行见[新日志](results/attention_rtl_repair_20261008/d2_full_top_csim_official_v1/csim.log)。运行审核与D2其余边界分别记录。

下列历史完整验证均对应 build tag `04934c15b3f83e842ec2e92ac2a81bf2`。**逐位比较的对象是读取冻结 GGUF、按当前硬件数值合同独立重算的 oracle，不是 GPU/native 全图逐位一致或业务质量验收。** 历史局部 RTL 证据单独列出。

| 阶段 | 已得到的结果 | 证据与验证边界 |
| --- | --- | --- |
| CPU 总门禁与数值叶函数 | **PASS**：27/27 CTest；75 个数值正例逐位通过，另 1 个既有预期拒绝符合预期 | [CPU 门禁](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/full_final_gate_report.json)、[数值用例](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/numeric_fixture/full_fixture_report.json) |
| CPU 完整前向 | **PASS**：B2/S128 和两题各自重基后的 B1/S128，合计 141 个检查点、18,094,384 个 F32 逐位一致；每个成功请求完成 28+2 层 | [独立逐点比较](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/compare/full_forward_dut_compare_report.json) |
| 同一 Runtime 的故障恢复 | **PASS**：4 个连续请求，3 次成功、1 次已接受的预期故障；故障后恢复。成功退休任务数为 37,158 / 18,895 / 18,895 | [持久运行报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/dut/full_forward_dut_run_report.json)；故障在第 17 个任务发生，错误帧与零输出按合同检查 |
| 真实直接任务 | **PASS**：front 比较 527,360 个 F32；10 种矩阵任务比较 329,730 个 F32；attention full/slide 各 1,622,016 次比较 | [front](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/front_dut/full_front_dut_report.json)、[matrix](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/matrix_dut/full_matrix_dut_report.json)、[attention](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/attention_dut/full_attention_dut_report.json) |
| S64/256/512/1024 补充 | **PASS**：真实任务、末行末列、地址边界、覆盖发布与 guard 检查 | [shape 报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/cpu_full/shape_dut/full_shape_dut_report.json)；四档未执行完整网络，部分 attention 输入使用明确标记的 fixture |
| `__SYNTHESIS__` 分支 shadow | **PASS**：25 份生产源、真实 13 口顶层，同进程 4 次调用，3 次成功和 1 次预期故障；72 个有效结果 F32 与 oracle 一致 | [shadow 报告](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/shadow_r2/shadow_report.json)；这是综合分支的 CPU 执行，仅比较结果帧，不是 RTL 仿真或整图 141 点比较 |
| 完整顶层 Vitis HLS CSim | **PASS**：B2/S128，47 个检查点、9,047,192 个 F32、37,158 个任务，工具报告 0 errors | [CSim 日志](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csim_full/csim.log)；使用 `csim.stdmath=true`、`-O2 -fno-fast-math -ffp-contract=off` |
| 完整顶层 HLS 综合与 IP 导出 | **完成，退出 0**：25 份生产源完成调度/绑定与全部 RTL 模型生成，已导出顶层 Verilog、VHDL、报告和 Vivado IP | [完整综合结果](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)；生成成功不等于完整 RTL 功能或物理适配已验收 |
| 完整顶层 Vivado OOC 综合 | **完成，退出 0、blackboxes=0**：201 DAT 实际 PRE 核验，完整映射资源/综合时序/DCP 已生成；主要资源未超裸器件总量 | [OOC 结果与原报告](vivado/project/source/results.md)、[独立审核](vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)；综合 WNS +0.894 ns，不能替代 P&R/平台时序 |
| 历史局部 RTL | RoPE leaf 三例 cosim PASS；修后 read helper 在 base 0 / 0x100 两例 XSim PASS | [RoPE 日志](results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log)、[read helper 审核](results/p2_environment_20261007/axi_base_zero_source_review.json)；仅证明各自范围，后者不覆盖完整外部 AXI4 adapter |
| 完整 RTL / 物理实现 | **未执行**完整 RTL cosim、布局布线及布线后时序 | 当前 callback testbench 仅用于 CSim；`run_full_hls.sh --cosim` 在入口明确拒绝；OOC 综合不是功能 RTL 仿真 |
| XRT / 平台 / 上板 | **未执行**真实 XRT 编译链接、平台 compile/link、xo/xclbin 生成、上板质量/稳定性/性能验证 | [XRT 依赖检查](results/engineering_p2/xrt_host_dependency_probe_20261007/configure.log)显示缺头文件和库；[历史语法检查](results/p2_environment_20261007/host_syntax_only_evidence/report.json)使用旧包和本地声明替身，只是语法证据 |

每次成功前向的 46 个中间检查点来自实际已发布 BO 对象，`final18` 来自真正提交的 384 B ABI 帧。独立 oracle 不向 DUT 注入 native 中间值。原 native 第二题 ACT CLS 的旧 stride 偏差已有[独立核查](results/p2_environment_20261007/native_act_cls_stride_check.json)；当前 DUT 遵守“本题 CLS”合同。两题功能通过不能外推为 400 例业务质量或板上 action 一致性通过，A6000 对照与 FPGA 速度目标也尚未完成本轮实测。

标准 libm 的 CPU/CSim 逐位一致不证明 HLS 非线性算子生成的 RTL 与 libm 一致，完整 RTL 数值误差仍待验证。[功能链汇总](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)和 CPU 门禁只记录各自生成时的阶段状态；其后的同 tag 完整综合，以完整综合结果和回写审核为依据。

## 资源、接口与性能边界

完整顶层的当前 [Vivado 资源报告](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization.rpt)与先前 [HLS 估算](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/laya_typed_q8_forward_csynth.rpt)对照如下。百分比使用当前映射数/整颗器件容量，尚未扣除平台 shell 预留：

| 资源 | HLS 估算 | 当前 Vivado 映射 | 整颗器件容量 | 映射占比 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT 总量 | 1,813,717 | 345,505 | 1,303,680 | 26.50% |
| FF | 477,288 | 287,466 | 2,607,360 | 11.03% |
| DSP | 485 | 437 | 9,024 | 4.84% |
| BRAM，18K 等效 | 570 | 1,380 | 4,032 | 34.23% |
| URAM | 44 | 179 | 960 | 18.65% |

CLB LUT 为 339,874 logic＋5,631 memory；BRAM 为 530 RAMB36＋320 RAMB18，即 690 个 36K tiles，等效 1,380 个 18K。两种 BRAM 单位不可相加。HLS 的 `Utilization Estimates` 与 Vivado 对冻结 RTL 的优化/映射属于不同阶段：当前 LUT 比 HLS 估算低约 80.95%，而实际 BRAM/URAM 比 HLS 估算高。本轮未改变计算源码或架构，不能把差异解释为额外算法优化、全部算子自动共享或性能提升。当前资源总量未超裸器件容量，但放置、拥塞、平台预留与布线后时序仍未验证。

历史 [HLS 独立资源复核](results/synthesis_memory_fix_20261007/full_resource_review_04934.json)中的四个 `linear` 合计 618,806 LUT、`graph` mux 64,914 LUT 均是 HLS 阶段估算，当前映射分布应查 [Vivado 层次报告](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/utilization_hierarchical.rpt)。加载、量化、检查、调度与算术都属于计算子树；父模块总量包含子模块，不能重复相加。映射结果仍保留 Q8/FP 数值电路，不以资源下降代替完整 RTL 功能验证。

13 个持久数值数组的声明容量为 8,641,536 B（8.2412 MiB），不含控制元数据、局部数组和存储碎片。历史独立 RAM OOC 对两个 packed 权重缓存得到 **164+11=175 URAM**；完整 HLS 估算为 44，本次完整 Vivado 映射为 179。三者范围/阶段不同，不能相加或互相替代；实际放置仍待 P&R，详见 [OOC 资源口径](vivado/project/source/results.md)。

真实生成接口包含 **13 个 `m_axi` bundle**，以及 `s_axi_control`、`s_axi_control_r` 两组 AXI-Lite 控制接口。当前生成 master 默认数据宽度 32 bit、地址宽度 64 bit；[顶层 C++](hls/platform/full_kernel_wrapper.cpp)中的 512 bit 是最大 widen 请求，不是已实现吞吐；[候选 HBM 连接配置](config/u55c_link.cfg)尚未经实际平台链接验证。完整顶层 latency/interval 在 HLS 报告中未定义。当前 [综合时序](vivado/project/build/20261008T022231Z-2961016/reports/synth_20261008T025045Z_2986844/timing_summary.rpt)在 6.667 ns 请求下 WNS +0.894 ns、TNS 0、WHS +0.046 ns，但 550 输入/1,781 输出未设外部 delay，且缺少 `HD.CLK_SRC` 无法估计真实 clock delay/skew。约 150 MHz 仍是约束请求，综合结果与历史 HLS Fmax 都不是布线后或板上频率实测。

### 已解决的综合主机内存问题

旧完整 HLS 综合因工具主机内存增长终止。修复拆分了数值 cache 的全零静态存储与控制初值，保留元素类型、逻辑尺寸、owner/epoch 和数值语义；随后修复实际综合路径中的指针比较问题。最终 HLS 运行的受控进程树 RSS 采样峰值为 **9.068 GiB**，旧失败 HLS 运行采样值为 **361.572 GiB**，见[修复报告](results/synthesis_memory_fix_20261007/report.md)。本次完整 Vivado OOC 是另一工具流程，整个 synth phase 用时 **104.47 分钟**，任务树 RSS 采样峰值 **38.8910 GiB**、最低主机 MemAvailable **383.4557 GiB**，64 GiB/4 小时保护未触发。以上均为服务器观测，不是 FPGA 片内存储；采样值也不是生命周期绝对峰值，不同工具/统计范围不能混作同一次测量。

## 复现入口

以下命令在正式工程根目录执行，显式使用新的fe067模型包；不要省略该环境变量回退到旧04934默认包。CPU 验证还需要冻结 GGUF、`reference/` 中的冻结请求、Python/NumPy 和编译工具；脚本默认使用随工程保存的 CMake 3.31.8，可通过 `CMAKE_BIN` / `CTEST_BIN` 指定实际安装。

```sh
export LAYA_FULL_MODEL_DIR="$PWD/build/model-attention-rtl-repair-20261008"
export LAYA_REPRO_ID="$(date -u +%Y%m%dT%H%M%SZ)"
export LAYA_FULL_BUILD_DIR="$PWD/build/full-local-$LAYA_REPRO_ID"
export LAYA_FULL_TEST_RESULTS="$PWD/results/local-full-$LAYA_REPRO_ID/cpu"
./scripts/run_full_tests.sh
```

[CPU 脚本](scripts/run_full_tests.sh)自动启用 `LAYA_ENABLE_FULL_NUMERIC` 和 `LAYA_ENABLE_FULL_FORWARD`，构建后执行 CTest、严格包校验、源闭合、独立 oracle、直接任务、四 shape、完整前向和最终门禁。`LAYA_FULL_BUILD_JOBS` 支持 1–4，默认 4；正常终点为 `FULL_FORWARD_CPU_PASS`。

同一终端继续使用本次 CPU 生成的当前 tag 请求和独立 oracle，执行真实顶层 CSim：

```sh
LAYA_FULL_REQUEST="$LAYA_FULL_TEST_RESULTS/dut/inputs/B2_S128.request.bin" \
LAYA_FULL_ORACLE="$LAYA_FULL_TEST_RESULTS/oracle/B2_S128" \
LAYA_FULL_HLS_BUILD="$PWD/build/full-local-csim-$LAYA_REPRO_ID" \
LAYA_FULL_HLS_RESULTS="$PWD/results/local-full-$LAYA_REPRO_ID/csim" \
  ./scripts/run_full_hls.sh --csim
```

[HLS 脚本](scripts/run_full_hls.sh)默认使用本机 Vitis 2025.2 路径，支持 `VITIS_RUN_BIN` / `VPP_BIN` 覆盖。其他模式如下；列出入口不表示这些阶段都已完成。当前新源码完整top HLS尚须D2证据通过后的内部技术放行；不能因入口存在就直接重跑完整综合。

| 模式 | 实际作用与前提 |
| --- | --- |
| `--check` | 打印模型、工具、part/platform 配置，仅检查 Vitis 可执行文件与生成头存在；不是严格模型包验证 |
| `--csynth` | 对 `LAYA_FULL_PART`（默认 U55C part）运行完整 HLS 综合，生成 RTL/IP；无需 `.xpfm`。可用 `LAYA_FULL_HLS_BUILD` / `LAYA_FULL_HLS_RESULTS` 指定独立输出目录 |
| `--cosim` | 当前入口明确失败，提示尚需可供 RTL 使用的结果帧 testbench |
| `--compile` | 需要真实 `LAYA_PLATFORM=/path/to/platform.xpfm`，以 Vitis flow 生成 `.xo` |
| `--link` | 需要真实 `LAYA_PLATFORM` 和 `LAYA_FULL_XO`，使用 `config/u55c_link.cfg` 链接 `.xclbin` |
| `--deploy` | 调用真实 XRT Host；需要已构建 Host、实际 xclbin、当前请求和设备环境 |

F0 综合配置禁用自动 loop pipeline、吞吐驱动 array partition 和自动 complete partition；两个权重缓存请求 URAM 绑定及存储字 reshape。这些配置不代表算术并行度或物理映射已达标。已归档的完整综合使用了额外资源守护；通用 `run_full_hls.sh` 入口本身不包含该次守护器。

如需在源码/配置变化后重新导出模型包，可使用[导出器](tools/export_gguf.py)的 `--gguf` 与 `--out`，例如导出到独立 `build/model-local`，再将 `LAYA_FULL_MODEL_DIR` 指向它。导出器默认输出仍是 `build/model-p2`，不同于测试/HLS 的默认 `build/model-repair`，因此应显式给出输出目录。新包、新请求与验证证据必须使用匹配的身份，不能直接复用旧 tag 请求。

`run_full_numeric_tests.sh` / `run_full_numeric_hls.sh` 保留数值叶函数入口。P0/P1 脚本用于各自历史回归；`run_hls.sh` 与 `hls/laya_forward.cpp` 的 `contract_only` 属于历史 P0 目标，完整当前目标应使用上述 `run_full_*` 入口。

旧04934完整 HLS RTL 的[独立 Vivado OOC 工程](vivado/project/README.md)已完成创建、配置验证和完整顶层综合，可从该页进入实际 `.xpr`、显式复现入口、本次日志、资源/时序报告及 DCP；该工程尚未执行 P&R 或平台链接。

## XRT Host 构建与运行

当前环境缺真实 XRT 头文件和库；以下是依赖齐备后的实际入口，不是已完成部署的记录。安装匹配的 XRT 与 OpenSSL Crypto 后，用 `XILINX_XRT` 或 `CMAKE_PREFIX_PATH` 指向 XRT 安装：

```sh
cmake -S . -B build/full-xrt-host \
  -DLAYA_ENABLE_XRT_HOST=ON \
  -DLAYA_FULL_MODEL_DIR="$PWD/build/model-attention-rtl-repair-20261008"
cmake --build build/full-xrt-host --target laya_host
```

Host CLI：

```text
laya_host --xclbin FILE --xclbin-sha256 HEX --package DIR \
          --request FRAME --result RESULT --timeout-ms N [--device INDEX]
```

Host 按 `kernel.group_id(0…12)` 分配 BO，核验并上传模型，启动一次 `laya_typed_q8_forward`，等待后读取并检查结果身份。`FRAME` 须匹配包内四个 tag。`run_full_hls.sh --deploy` 使用 `LAYA_XRT_HOST_BIN`、`LAYA_FULL_XCLBIN`、`LAYA_FULL_XCLBIN_SHA256`、`LAYA_FULL_REQUEST`、`LAYA_FULL_RESULT`、`LAYA_FULL_TIMEOUT_MS` 和可选 `LAYA_FULL_DEVICE_INDEX` 调用同一 Host；缺依赖时会明确失败。

## 当前证据导航

- [正式回写审核](results/synthesis_memory_fix_20261007/post_promotion_review_04934.json)：正式工程、当前模型包、103 项身份输入和 25 份 HLS 源与已验证现场的一致性。
- [修复与完整综合总报告](results/synthesis_memory_fix_20261007/report.md)：内存问题修复、数值语义、各阶段验证及未完成事项。
- [功能链汇总](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)：CPU、综合分支 shadow 与标准 libm CSim。
- [完整综合结果](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)、[原始日志](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/csynth.log)、[工件清单](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。
- [顶层 Verilog](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_verilog/laya_typed_q8_forward.v)、[顶层 VHDL](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/rtl_vhdl/laya_typed_q8_forward.vhd)、[顶层综合摘要](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/reports/csynth.rpt)、[Vivado IP 包](results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifacts/ip/xilinx_com_hls_laya_typed_q8_forward_1_0.zip)。
- [Vivado OOC 工程与本次日志](vivado/project/README.md)、[当前综合结果](vivado/project/source/results.md)、[独立综合审核](vivado/project/build/20261008T022231Z-2961016/synthesis_review.json)：实际 `.xpr`、完整顶层映射、资源/综合时序、DCP 与运行保护证据。
- [独立资源复核](results/synthesis_memory_fix_20261007/full_resource_review_04934.json)与[top 模块当前结果](vivado/module_design/top/source/results.md)：资源层级、存储估算差异、时序和后续验证边界。

后续尚需完成完整 RTL 数值/接口验证、平台适配与布局布线、真实 Host/设备运行，以及业务质量、稳定性和端到端速度测量。当前 README 仅汇总已完成的 CPU/CSim/HLS/OOC 综合证据，不把综合资源或约束内时序写成部署与性能达标。

## 2026-10-09 连续离线验证入口

本轮在[阶段合同](mission/offline_validation_workflow.md)内连续执行 Head15/query63、Ws、Scorer 有效三行和 Type 双冷 RTL；各项**当前** PASS/FAIL/NOT_RUN 及原始证据只以[阶段结果表](results/offline_validation_20261009/stage_results.md)为准。以上历史段落记录当时状态，不替代该表。无 U55C，本轮仍不构成完整模型硬件闭环、板上时序或端到端 50 ms 达标。
