# Attention与共享浮点引擎：平台、资源与性能记录

## 2026-10-11 精确 tile 候选的连续验证

唯一候选按联合合同 §8.3.1 实现完整 S1024 的 M16/A16/D4/EXP4，证据根为 [t5_attention_tile_v1_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01)。v03、v06、v07 的真实 enc0/head0 前四 query 全中间/最终位型均 PASS；v07 guard 29.454260s、930872KiB、exit0/null。严格正常 QK/SM/AV 为 7841/8973/2090，共18904cycles；早期 raw 18905 包含一个故意拒绝 QK 的1cycle，日志保留，receipt已校正。EXP 每 worker 实测 launch→done 启用边沿间隔为1、78或97，不能视为II1。

v07 tile16/协议实际 FAIL：四类 M/A/D/EXP 活动复位、CE低时reset抢占及旧epoch拒绝/合法重载均完成；随后第一次M活动暂停的完整状态快照发现 canonical helper 的 `ap_ce_reg` 仍在低 CE 时更新并允许尾拍推进。guard95.493970s、947976KiB、exit1/null，数值gold及暂停断言不改。v08/v09仅在 Attention 本地 helper 依赖追加既有同clock CE闭包，覆盖11个可达module/25个原posedge块；v09使用 `attention_tile_ce_` 名称隔离原 canonical/GEGLU。v09正常4query实际PASS：29.452186s、931016KiB、exit0/null；[tile16_02](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/tile16_02/numeric_result.json)完整16row逐位与四类CE/reset/chain/ledger实际PASS：141.070850s、953992KiB、exit0/null，正常QK31361/SM35896/AV8282共75539cycles。93项冻结源码全部保存在 `source_versions/v09_pass/preservation_manifest.json`，不冒用原 DCP 计新候选资源。

[新 C 模型 cpu_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/cpu_01/numeric_result.json)独立通过同 head128 的八个16row tile：191104次命令、49720项独立位型比较，guard0.989090s、87944KiB、exit0/null。普通映射修复把 QK 树错误 `i` 修为原 `key*64+i` 后，[cpu_02](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/cpu_02/numeric_result.json)正常全head及 key5/parent3 的独立树溢出 bad_element323 实际PASS，207740次调用/49721检查。CPU通过不代签RTL或生产。

[helpers_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/helpers_01/numeric_result.json)实际PASS：四个真实D各405定向向量、共1620结果，含在途CE；四个原EXP各12定向、共48结果。guard5.970200s、885152KiB、exit0/null，完整原gold保持。该运行身份是v09，14项物理helper/ROM输入hash与v10未变，可复用局部定向覆盖，不改写为v10新运行。

当前v10冻结联合§8.3.2的延迟Q首错实现，实际闭包23module/22RTL/IP0/EXP ROM dat1，状态快照11750成员。[cpu_03](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/cpu_03/numeric_result.json)正常完整head和七个独立首错检查实际PASS：259306调用、49727独立比较，guard1.349269s、85916KiB、exit0/null。[tile16_03](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/tile16_03/numeric_result.json)实际PASS：182.683258s、954704KiB、exit0/null；六类原Q/math竞争首错为323/63/63/7/63/4095，此前完整row score数64/0/0/0/960/64，错误后无成功SCORE/SM，待决Q的CE/reset及四类真实在途CE/reset/合法重载/chain/ledger全部通过，正常计算75539cycles。

[head128_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/head128_01/numeric_result.json)在同一v10 snapshot、单一连续进程中完成全部128query/八个16row tile，全部原中间及最终位型实际PASS。guard471.004332s、1108700KiB、exit0/null，总TB1608896cycles；正常QK250888、SM287173、AV66256，共604317cycles。语义M2129920/A2146176/D16384、QK products1048576/trees1032192、AV每key提交1048576、EXP16384；实际调用accepted=retired191088、cancelled0。完整head的协议/首错复用同hash tile16_03，未拼接reset进程。

相较原标量同head的正常6816248cycles，当前模块计算账改善约11.279倍；请求150MHz仅条件换算为4.028780ms/head，未实达频率、生产搬运/调用/物理writer末B及完整请求吞吐均不在此数值结果内。

[feedback_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/feedback_01/numeric_result.json)完整单query逐位PASS；自然M Q32填满，Mpeak32、Mcredit580、AV同址busy635，Apeak8。该例未证明A/D Q32满队列，不能把局部覆盖扩大为全部队列满。[capacity_01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/capacity_01/capacity_result.json)synthetic S1024/highrow1008/16rows实际PASS：完整K65536/V65536/Q1024/MASK1024命令装载与各bank全深度共184304字物理1R1W端口读回；guard86.632102s、885496KiB、exit0/null。该诊断不是新shape/B2数值证据。

v10 head128的启用阶段账如下。正常命令周期包括每个tile的接受launch边沿；启用阶段profile不含launch边沿，所以每阶段相差八个边沿。M/A的wait是未发射边沿，包含该算术模式闲置，不能全部归为credit停顿。

| 阶段 | 正常命令cycles | 启用profile边沿 | M/A/D实际lane贡献 | M/A发射边沿 | M/A credit停顿 |
| --- | ---: | ---: | --- | --- | --- |
| QK | 250888 | 250880 | 1081344/1064960/0 | 98304/147456 | 0/0 |
| SM | 287173 | 287165 | 0/32640/16384 | 0/17408 | 0/0 |
| AV | 66256 | 66248 | 1048576/1048576/0 | 65536/65536 | 0/0 |

完整head四EXP的真实launch→done启用边沿间隔合计分布为1×7168、78×128、89×1、97×9087，共16384次；这是数据相关的原非流水EXP，不能用II1计费。正常head M/A peak为16/8、Mcredit0、AV同址busy0；feedback_01另以真实自然反馈覆盖M Q32满、Mcredit580和busy635，A/D Q32满仍未证明。

容量诊断184304个32bit物理字对应737216B纯RAM payload；包含K/V/Q/Y/SCORE/PROB/EXP/SM-tree/dot各level。这个字节账不含队列tag、绑定记录、FP流水及映射碎片，不能转换为实测BRAM数量。

[ooc_01终态receipt](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/ooc_01/ooc_result.json)为 **NOT_COMPLETE**：同一v10完整闭包、Vivado2025.2、xcu55c-fsvh2892-2L-e、请求6.666666667ns、无继承DCP，guard在244.410645s触发semantic_stall，child_exit_code=-9；实际peak_owned_rss11295456KiB、最低MemAvailable410445816KiB。RTL elaboration、属性处理、首轮优化及constraint validation已完成；末个配置进度里程碑为`Finished applying set_property XDC Constraints`，其后120.015934s无guard认可的新里程碑，原日志尾保留register trimming/RAM mapping信息。此保护触发不证明综合算法挂起，也不是FPGA资源超限结论。未生成最终utilization、层级资源、DCP或timing报告，blackbox计数/物理资源/时序均未形成结果；不继承旧scalar或未修CE DCP、不加帽原样重跑、不发布tile ready JSON。

本模块按当前阶段要求封存，机器交接见[final_summary.json](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_tile_v1_01/handoff/final_summary.json)。生产tile接入补丁为UNVERIFIED_NOT_APPLIED；live原scalar入口保留，完整13BO/generated controller、唯一实例/动态done、owner/物理writer末B和新tile B2边界均NOT_RUN。完整top fit、P&R、实达频率及上板性能也未证明。

## 当前修复身份与本模块已验收范围（2026-10-09）

当前正式生产包为 build tag `fe067c8aa0627ad770096f9721394645`，以[当前 manifest](../../../../build/model-attention-rtl-repair-20261008/manifest.json)、[项目状态](../../../../README.md)及[活动任务](../../../../mission/task.md)为入口。当前完整 CPU/真实 13 口 B2 CSim 证据与以下局部 RTL 证据分阶段记录；完整新核数值 RTL、同源完整物理资源、平台及板上性能尚未验收。

| 当前证据 | 已接受范围 | 保留边界 |
| --- | --- | --- |
| [Attention v5 软件/生成结构](../../../../results/attention_rtl_repair_20261008/reviewer_attention_v5_software_synthesis_structure_review.json) | 严格 CPU、标准 libm CSim，真实 request/owner/LOAD_KV/QK/Softmax/AV/report 生成可达 | 属于隔离预置 QKV 切片，不能当作完整新核资源或完整前向 RTL |
| [cold V2 四命令数值/协议](../../../../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json) | B1/S64 Decision layer0 head0/query0：BEGIN、重复 BEGIN 拒绝、RUN、replay 拒绝；QK64 精确、概率原容差、AV64 精确实际概率递推，完整输出/哨兵与响应排空 | 外部 QKV→真实发布→Attention；未覆盖真实 Q8/RoPE 生产者、其余 head/query/shape、暖复位或整个共享 FP 引擎 |
| [D2-I v3 生产 Controller 路径](../../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_synthesis_ir_review.json) | stage4 I-L QKV、I-V residual/type/unary 的 CPU/标准 libm CSim及生成结构另行接受 | 尚无对应数值 RTL；不能与消费者切片简单拼接成完整生产链通过 |

cold V2 的 RUN 500651 个测试台命令时钟包含 Lite/control；并非纯 DUT 接受→完成延迟、Fmax 或完整请求性能。v5 HLS 估计 5.390 ns 超过 6.667−1.80=4.867 ns 有效预算，普通硬件复位尚未清 pending/session；[head15/扰动输入](../../../../results/attention_rtl_repair_20261008/reviewer_attention_v5_head15_changed_finite_source_preparation_release.json)与 [metadata reset](../../../../results/attention_rtl_repair_20261008/reviewer_attention_v6_metadata_reset_source_preparation_release.json)仅为源码准备。详细运行、失败与限制见[Attention 当前结果](../../../../results/attention_rtl_repair_20261008/d2_attention_preloaded/source/results.md)。

旧 64 路 FP 候选的 B1 QK+AV 理想预算约 104.86 ms，本模块并未达到 50 ms；需与 Q8 严格恢复、KV/外部搬运、其他 FP 和 Host 联合核算。下面的 04934 OOC 只属于历史制品，不与 fe067 功能结果合并为资源/时序验收。

## 历史 04934 整核制品与缺陷（2026-10-08）

以下历史整核制品对应 build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 历史 04934 接口与性能核查（2026-10-08）

C++合同：Q[64]、K/V[S,64]、mask[S]→score/prob[S]和AV[64]；FP尾部1024→1与1028→256。

重要异常：生成QK full_run_task_33在context通过后固定E_SHAPE/elements0，不能以3–5cycles称成功QK吞吐；AV full_run_task_35也已确认同样固定E_SHAPE/elements0。源码B1/S128 QK/AV各503,316,480个乘法贡献，不能据此认定当前RTL已保留全部算术。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-attention_and_fp_engine)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整attention任务](../../../../hls/operators/full_tasks_attention.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | full/slide各1622016比较；完整全部head覆盖由当前整图另证 | [attention直接任务](../../../../results/engineering_p2/full_cpu_final_20261007/attention_dut/full_attention_dut_report.json) |
| P2早期完整top HLS CSim | 实际13参数top，标准libm、严格浮点O2，真实B2 47点/9,047,192个F32/37158任务PASS | [最终CSim日志](../../../../results/engineering_p2/csim_full_final_20261007/csim.log)；默认HLS数学模型及RTL非线性误差仍未验收 |
| 代表性RTL | 整网RTL未运行；isolated证据仅对实际用例有效 | [阶段边界](../../../../hardware_agent/task.md) |
| P2早期完整top实验综合 | 已执行当时源码完整top综合；后续工具进程内存约244GiB、可用内存降至约179GiB后保护终止，exit1；无完整资源/接口/RTL报告 | [最终尝试机械复核](../../../../results/p2_environment_20261007/final_synthesis_attempt_mechanical_check.json)；[本次日志](../../../../results/engineering_p2/csynth_array_f0_final_20261007/csynth.log)。工具主机内存限制不等于FPGA资源超限结论 |
| 平台与性能 | XRT实际编译、platform link、xclbin、布局布线/时序、上板质量/稳定性与性能均未验收 | [真实Host依赖诊断](../../../../results/engineering_p2/xrt_host_dependency_probe_20261007/configure.log)；当前串行F0不沿用旧并行阵列/25–50ms目标 |

本节P2早期编译身份见[模型与源码机械复核](../../../../results/p2_environment_20261007/final_model_identity_mechanical_check.json)。CPU门禁报告只判CPU，CSim由独立HLS运行证明；静态模块登记的pending字段不是动态验收状态。S64/256/512/1024仅完成任务/边界补充，完整网络运行仅S128。§1–§6与2026-10-05记录是P0历史候选预算，后续P1/实施中记录按其原始run阅读，不能覆盖页首当前阶段结论。

## 1. P0历史：平台与候选配置

| P0历史项目 | 当时值/候选 | 历史证据状态与边界 |
| --- | --- | --- |
| 目标板卡 | U55C | 明确要求；实际设备/part/package/speed grade待G1 |
| 参考平台/工具 | xilinx_u55c_gen3x16_xdma_3_202210_1；Vitis/Vivado2023.2起点 | 来自Llama源码的工程事实；目标服务器组合未冻结 |
| Host/部署 | 服务器CPU＋XRT；HLS→xo→xclbin | 部署方案；目前只有本机P0合同程序，无xo/xclbin |
| 计算时钟 | 候选150MHz | 推断/分析值；实际频率与复位/CDC待G1 |
| 模型身份 | Typed-Decisions Q8_0；SHA-256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18` | 既有模型检查记录；不是本模块运行证据 |
| 统一短请求算例 | B2/S128、16候选、TM16/TN8/GS32 | 推断/分析范围；实际Typed token/marker帧待G3 |
| P0源码/输入hash | [source_hashes.sha256](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)、[fixture_hashes.sha256](../../../../results/engineering_p0/20261005T154135Z-3872886/fixture_hashes.sha256) | 本机合同运行输入已记录；硬件约束/IP未冻结 |

本模块具体推导依据[11](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md)、[10](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md)、[13](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/13_decision_scorer_act.md)、[05](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### 一个题、一个head、16query/S128

| 阶段 | 周期计算 | 理想cycles |
| --- | --- | --- |
| QK | 16×128，一score/clk | 2048 |
| softmax max | 16×128/8 | 256 |
| exp/sum | 16×128/4 | 512 |
| normalize | 16×128/8 | 256 |
| AV | 16×128，64feature/issue | 2048 |
| 输出 | 16×64/8 | 128 |

F0合计5248cycles≈34.987μs@150MHz。B2/S128一层有2×16head×(128/16)=256个这样的tile，服务合计1343488cycles≈8.957ms，另加KV/Q读、FP尾、反馈停顿和切换；不能每tile重复计整head KV装载。

64F32窗口256bytes/issue×150MHz=38.4GB/s片上读需求；AV partial读写同样需要匹配窗口。普通8lane通路只有4.8GB/s。

F1双score bank可重叠独立softmax与另一tile计算；共享引擎QK+AV仍为4096cycles/tile，再考虑读出/尾延迟。浮点尾层的广播形状不同，小矩阵不能直接用MAC/64推真实时延。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

双KV2MiB、双score/prob256KiB，Q tile与AV partial各最大8KiB；与05同一批实体。FP单元/IP数量与资源尚未综合。

| 资源项 | 当前预算/估算状态 | 综合结果 | 布局布线结果 |
| --- | --- | --- | --- |
| LUT | 未形成模块物理数量估算，需实际结构/IP/banking | 未执行 | 未执行 |
| FF | 未形成模块物理数量估算，需流水/标签/控制实现 | 未执行 | 未执行 |
| DSP | 未形成模块物理数量估算，不能把运算lane直接当DSP | 未执行 | 未执行 |
| BRAM | 逻辑容量如上；端口复制/宽度碎片及绑定待核查 | 未执行 | 未执行 |
| URAM | 逻辑容量如上；实际分配及平台可用区待核查 | 未执行 | 未执行 |

旧建议DSP80%、LUT70%、BRAM/URAM75%、总逻辑缓存28MiB针对整核且待G6确认，并非每模块可单独占用的配额。共享单元/缓存只记真实实例一次。

## 4. P0历史：频率与时序记录

| 项目 | 当前状态 | 后续需要的证据 |
| --- | --- | --- |
| 150MHz候选请求 | 推断/分析值 | 实际HLS/平台时钟约束 |
| 综合频率/实际II | 未执行 | 整链综合报告、函数实例、反馈与端口限制 |
| 布线后频率/WNS/TNS/hold | 未执行 | 当前源码及约束对应的实现报告 |
| 时钟域/复位/CDC | 细项待G1 | 生成连接、复位时序和CDC/约束覆盖检查 |

## 5. P0历史：验证与原始证据

| P0历史阶段 | 当时状态 | 当时证据/缺口 |
| --- | --- | --- |
| 模块规格/目录 | 本次整理 | 原规格链接与章节定位已核查；文档检查记录见项目task.md |
| P0主机端合同CTest | PASS：总回归20/20，含`contract_attention_and_fp_engine` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G3 exp/div函数/误差；G4FP反馈、64路窗口、RAM端口、实际II/资源；G1时钟。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前实现核对QK/Softmax/AV/FPLinear任务的模式、shape字段、来源目的region及输出数量，并在状态辅助函数中区分QKV_RAW/QKV_FINAL和SCORE/PROB。尚未关联QKV的plane/head/B/S与请求/layer完整覆盖，也未实现KV缓存完整身份、全层屏障或真实QK/softmax/AV数值链；同内容标签的对象仍须在后续接入前补齐数据身份校验。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。


## P2 A批设计预算与待验阶段（2026-10-07，Astra xhigh）

依据[task.md §12](../../../../hardware_agent/task.md)和本模块design新增P2节。每题每head的K、V接口各1024×64×4=262144B；q和输出各256B，单行score/prob各4096B，softmax工作数组可复用。act权重526336B、输入4112B、输出1024B；scorer权重4096B。QK/AV各每query S×64乘法贡献，QK每score63加法；AV每feature S加法。完整缓存是否片上及共享实例由B批和真实综合核查，不能把接口容量直接计为BRAM。

实验工具沿用Vitis HLS 2025.2，isolated part `xcu55c-fsvh2892-2L-e`，150MHz为请求而非已达时钟。P2 CPU/CSim、isolated综合、RTL cosim此节写入时均未执行；布局布线/时序、xo/xclbin、XRT/板级亦未执行。实际platform/shell/XRT缺失不阻止板无关代码与实验part验证；资源、II、latency和误差须分阶段追加真实报告。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

当前head KV最大1MiB、score/prob128KiB、Q/AV各8192B；FP act权重526336B，loader统计一次。所有阶段F0串行，不用QK/AV时间取max；共享实例和实际FP反馈II须综合核实。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2 A批实际运行证据（2026-10-07）

| 阶段 | 实际结果 | 原始证据与范围 |
| --- | --- | --- |
| CPU直接TB | 本模块9例PASS，五模块合计30例 | [CTest日志](../../../../results/engineering_p2/20261007T025037Z-1839717/ctest.log) |
| 独立真实fixture | 五模块合计75场景，51个参考文件 | [fixture报告](../../../../results/engineering_p2/20261007T025037Z-1839717/fixture/full_fixture_report.json)；仅本报告所列场景，后续参考扩展/修正需重跑受影响检查 |
| Vitis 2025.2 isolated CSim | 本模块9例PASS，退出码0 | [csim_attention.log](../../../../results/engineering_p2/20261007T030653Z-1859617/csim_attention.log)、[源码身份](../../../../results/engineering_p2/20261007T030653Z-1859617/source_hashes.sha256)；leaf入口、实验part与150MHz请求 |
| 本模块RTL/综合 | 尚无本模块独立通过报告 | 其他模块的RoPE cosim/综合不替代本模块证据 |

完整任务联合链、完整top、布局布线、xo/xclbin及U55C测试另行验收。上述CPU/CSim及isolated RTL均不能证明完整网络功能或AXI性能。


## P2真实RoPE/attention任务初步证据（2026-10-07）

[直接任务初步报告](../../../../build/p2b-attention-dut-prelim/full_attention_dut_report.json)在full与slide两种真实GGUF表模式各比较1622016个F32。完整RAW和FINAL QKV各覆盖3plane×16head×B2×S128×64＝786432值；QK/softmax/AV及ATT_OUT物理片段覆盖head0/1、两题、query row0=0/112的首末16行tile，key范围均为完整S128。完整16head×所有query的ATT_OUT尚未由该测试发布，须由完整DUT/整链验证完成。

本轮局部输入为只读native enc0_qkv，预期RoPE/score/prob/AV由独立候选参考结合真实表和请求mask重算；这种局部输入不允许注入后续完整网络执行。5个负例检查重复RoPE在重写前拒绝、重复shard QK拒绝、live SCORE期间KV替换拒绝且缓存/owner保留、Softmax KV来源账本不符及AV错误head拒绝。该证据使用prelim2包，最终仍需稳定源码与完整输入身份绑定。


## 综合内存修复历史 f1a 实测（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)约束数组分离、owner索引及打包。下表记录历史f1a包`f1a47e48f99d9f16e71dfcfdab18881c`的阶段证据；该包已原样归档，现行04934结果见下节。

| 阶段 | 历史 f1a 状态与证据 |
| --- | --- |
| 源结构/typed存储 | 已接入13个独立全零synthesis数组及固定访问器；CPU仍为每Runtime私有数组，逻辑容量8,641,536B。结构pilot的优化链接IR保留13对象；[准确源码差异和hash](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)。控制metadata、局部数组与物理碎片另计。 |
| RAM打包pilot | Q8 q/scale保持原元素类型，cyclic reshape因子8/4；独立Vivado OOC实测两单bank、单端口64bit RAM分别占164和11 URAM288，合计175；[层级报告](../../../../results/synthesis_memory_fix_20261007/packing_pilot_vitis/vivado_ooc_hierarchy.rpt)。这不是完整top资源fit结论。 |
| owner/恢复pilot | 0…31索引、32哨兵的26项持久pilot经host、CSim和HLS RTL生成；[综合保护记录](../../../../results/synthesis_memory_fix_20261007/owner_index_pilot_vitis/csynth_guard_r2/guard_result.json)峰值2,545,196KiB，退出0。 |
| f1a包与CPU | [严格包检验](../../../../results/synthesis_memory_fix_20261007/model_package_frozen/full_model_package_report.json)为103源、0 stale、153 tensor/152保留/122 Q8/124 weight；[完整CPU最终门禁](../../../../results/synthesis_memory_fix_20261007/cpu_full/full_final_gate_report.json)通过27/27 CTest、75项正例数值fixture逐位检查及1项既有预期拒绝用例、141位级整图点及同进程已接受故障恢复。 |
| f1a synthesis分支与真实CSim | [13口shadow](../../../../results/synthesis_memory_fix_20261007/shadow_reserved/shadow_report.json)在定义`__SYNTHESIS__`的25生产源上执行B2/故障/B1/B1，72有效F32位型及完整结果帧通过；[真实47点Vitis CSim](../../../../results/synthesis_memory_fix_20261007/csim_full/csim.log)比较9,047,192值、37,158任务，退出0。 |
| f1a完整top csynth/RTL | 已执行唯一一次受控完整top尝试：reflow与优化完成，综合性检查在未修改的算术源`attention_full_compute.cpp:24`因指针比较报`SYNCHK 200-42`，exit 1；峰值owned RSS 4,929,036 KiB、最低MemAvailable 435,199,944 KiB，未触发32GiB/192GiB保护；未生成完整资源、接口、时延或RTL报告。[运行结果](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)、[原始日志](../../../../results/synthesis_memory_fix_20261007/csynth_full/csynth.log)、[prechk IR取证](../../../../results/synthesis_memory_fix_20261007/csynth_full/ir_capture/capture_manifest.json)。后续综合须经Astra重新决定。 |
| 性能、布局布线、平台/板上 | F0仍串行；RMW/调度额外周期、II/Fmax及物理平台阶段尚未验收。 |

以上f1a记录只追溯历史阶段；现行tag与最终综合证据见下节。


## 综合内存修复现行实测（04934，2026-10-07）

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。`full_tasks_attention.cpp`的QK任务在已完成上下文检查和owner获取后，把本次有效的`S`字节mask按键序复制到1024 B自动局部数组，再把固定基址传入未改的`qk_row`。数值叶子`attention_full_compute.cpp`保持逐字不变。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |

## 2026-10-10 单bank AV反馈投影结果

[Q/K/V同点CPU捕获](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_qkv_capture_run_01/input_manifest.json)通过原141检查点、18,094,384个F32比较及故障恢复；运行guard exit0、138.279s、峰值RSS 630,380KiB。Q/K新捕获，V SHA与[v4 V捕获](../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_capture_run_01/input_manifest.json)相同。[独立gold](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_gold_01/work/gold/manifest.json)生成32×128 prob/product/partial；request3实际mask有72个有效元素。

[C3正式运行](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_c3_full_01/input_manifest.json)guard exit0、66.437s、峰值RSS 1,937,292KiB；真实FMUL/FADD短例得单地址本征反馈F=13，16地址连续256次接受II=1，credit反压、三类身份拒绝及两次在途reset恢复通过。真实gold的4096次贡献逐项通过；三批read跨度1663/1663/1659拍，stalls=793，总cycles=5089，product/commit峰值占用32/12。F=13否定C3满批无反馈泡的假设，C3功能本身通过。

[C4编译快照回放](../../../../results/compute_throughput_optimization_20261010/attempts/t2_av_feedback_c4_full_01/input_manifest.json)guard exit0、6.957s、峰值RSS 857,508KiB；两个2048贡献batch的read跨度均2048拍，4096次真实gold贡献通过，同址read接受间隔恒为16拍（本征最短F仍为13）、stalls=0、总cycles=4176，product/commit峰值占用7/13。C4在此单feature投影达到批内每拍一个read接受。早期C3 `pilot_01`、`pilot_02`因TB保留字编译失败保留原FAIL，`pilot_03`通过；正式C3/C4结果不依赖失败pilot。

上述为真实IP行为仿真，partial RAM物理类型、资源、Fmax、完整F256与跨模块调度仍`UNKNOWN`。旧生产top的E_SHAPE异常未由此修复；不从局部PASS声称20/s或50ms达标。

## 2026-10-11 真实Attention生产服务（当前实施，未冒称全Attention RTL通过）

独立[全head fixture](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture/manifest.json)完成：128query、全部128key/64feature，输入hash引用同点Q/K/V及request3/generation1，真实mask72个1。独立F32操作gold数为FMUL2,129,920、FADD2,146,176、DIV16,384。gold不作DUT score/prob输入。guard8.976s/峰值RSS53,792KiB/exit0。

[CPU02](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_02/guard/driver.log)对实际16384个exp shifted输入＋12个边界全部逐位通过；另200000个有限binary64基本运算通过。带55word完整读回及16row生产屏障的命令软件模型覆盖完整head128query，全部score/exp/sum/prob/out逐位通过；这是新软件服务证据，不是RTL或整图。随后同数学图的流水/metadata-reset实现整改正在连续回归，当前源身份以最新实际attempt为准，不能把CPU02代签之后变动的RTL。

[HLS01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_hls_01/guard/guard_result.json)生成真实RTL成功：23.641s、峰值RSS1,194,640KiB、无保护。HLS估算25DSP/20,843LUT/9,251FF/69BRAM18K，非物理结果；报告实际含2个F32 MUL（单共享意图未兑现）、1个F32 ADD、1个DIV及16DSP的exp bits leaf。exp leaf最大103cycles。HLS RAM位容量合计5,313,296bit而69BRAM18K估算不能证明物理容量，将以真实模块OOC核查；不得据此称资源fit。原F13单bank证据保留，未作为本服务的实测feedback。

[CPU03](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_03/guard/driver.log)对流水错误收集与metadata实际reset修改后的服务覆盖完整128query、16396个exp输入及200000个binary64基本运算，全部逐位PASS；guard1.464s、峰值RSS88,828KiB、exit0/null。[HLS02](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_hls_02/guard/guard_result.json)22.965s、峰值RSS1,196,660KiB、exit0/null，实际生成1个MUL/1个ADD/1个DIV；QK product/tree、SM tree/normalize与AV inner均II=1。HLS估算22DSP/21,270LUT/7,839FF/69BRAM18K，RAM位容量5,315,344bit；物理OOC仍未执行，估算BRAM不作为fit证明。

真实RTL pilot01只完成实际IP生成，在Tcl set_property参数写法错误处exit1，guard10.372s/1,194,232KiB/null；没有编译或数值PASS。修正的hs pilot02未启动，已被当前chain接入候选替代。HLS03的`config_rtl -clock_enable true`与HLS04的`config_interface -clock_enable true`分别因不存在选项/无参数flag多了true退出，原始失败保留；当前[HLS05](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_hls_05/guard/guard_result.json)使用安装工具实际支持的`config_interface -clock_enable`，23.181s、峰值RSS1,196,172KiB、exit0/null；native chain有实际ap_continue/ap_ce，实际1个MUL/ADD/DIV、主要循环II1，估算22DSP/21,504LUT/7,939FF/69BRAM18K，仍非物理结果。

生产owner已解冻Attention文件，`full_tasks_attention.cpp`接入B1真实controller服务调用候选，完整55word绑定及后续实际SM/AV参数校验已实现；下一生产build的完整CPU/CSim、官方blackbox导入、真实完整HLS层级唯一实例均未验证。当前chain真实短RTL/正式8row/完整head及模块OOC待运行；其他head/层、连续整层/全图RTL、P&R/实达Fmax及上板保持未测。

[CPU04](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_cpu_04/guard/guard_result.json)覆盖当前chain pragma及SM/AV scratch query标签、旧scratch读取拒绝，完整128query与16396 exp、200000个binary64运算逐位PASS；guard1.553109s、RSS88,620KiB、exit0/null。[adapter_compile01](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_adapter_compile_01/guard/guard_result.json)只证明生产适配器编译通过，0.612982s、RSS57,652KiB、exit0/null，不是运行或唯一RTL实例证据。

RTL pilot03在xsim plusarg参数写法、pilot04在重复--mt elaboration参数处失败，均保留原始日志。[pilot05](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_pilot_05/guard/guard_result.json)实际编译及首次仿真完成，12个exp边界逐位PASS；在cmd0测试台要求ap_vld与ap_done同周期处失败，guard63.330516s、RSS2,245,848KiB、exit1/null。生成ap_vld是更新脉冲，可能早于ap_done，且数据preg保持；新pilot06改为逐调用捕获全部valid并核最后valid数据在done保持，保留chain完成保持及真实流水CE暂停断言。数值QK/SM/AV与CE实际验证仍未通过。

生产适配器增加仅仿真的`AttentionServiceStats`读取/清零API：实际command_calls/successful_commands、数值/协议错误，以及B1/B2旧QK/SM/AV叶子调用。该计数由实际调用路径写入，供下一完整生产回归核新服务接入和B2退路，不从控制器意图或检查点反推调用；`__SYNTHESIS__`下不保留计数。

[pilot06](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_pilot_06/guard/guard_result.json)120s原pilot帽触发timeout，exit−9、峰值RSS2,143,768KiB。随后[既有snapshot诊断](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_chain_diag_01/guard/driver.log)在6.429154s/856,608KiB/exit0/null观察到已退休113调用、故意缺少KV的QK已ap_done=1；TB误等待拒绝调用的MUL活动。修复只限定成功QK触发暂停，拒绝用例和成本帽保留。

[pilot07](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_pilot_07/guard/guard_result.json)68.601397s/2,271,200KiB/exit1/null，实际完整KV_LOAD至100,579cycles。MUL被动monitor首差got=3eb9e90f正是独立gold第2项，expected=bd3b04c4为第1项；monitor在实际c_latency5后额外注册expected一拍，已修为启用边沿移位后末项直接比较，gold与DUT未变。

[pilot08](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_pilot_08/guard/guard_result.json)69.024309s/2,046,936KiB/exit1/null；实际填满MUL流水后ap_ce暂停断言FAIL。原生成helper ap_ce_reg和FP wrapper ce_r继续延迟更新，真实vendor aclken=ce_r允许暂停后仍推进1–2拍。此为native CE的实际硬件限制，保留FAIL，不删除或弱化暂停断言。

当前[same-clock CE closure](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_ce_rtl_01/ce_patch_manifest.json)是自动可重放的普通接口修复候选：原HLS05逐文件和补丁逐文件SHA、完整hier及实际IP配置latency保留；从top ap_ce|ap_rst分发独立global CE，38个module中的276个原posedge块在暂停时保持，3个有时钟vendor MUL/ADD/DIV的原aclken额外AND全局CE。FCMP/UITOFP实际IP是latency0组合核，输入adapter寄存器由同CE保护。时钟/同步reset域、所有原算术/数据表达式、RAM容量和FP实例不改。pilot09核731个FF/返回状态快照、全部hier CE低、真实FP及scalar hold并继续完整合法QK→SM→AV；本节写入时尚未完成，不能标数值RTL或资源PASS。

[pilot09](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_pilot_09/guard/guard_result.json)同clock CE closure实际PASS：query0完整K128/D64 QK→SM→AV、12exp边界、731FF/返回快照和全hier CE低/填满实际MUL流水暂停8clocks/恢复/chain保持；guard88.031770s、RSS2,282,660KiB、exit0/null。总157,389cycles，QK34,829（包含前置拒绝和8暂停）、SM10,089、AV8,284、LOAD32,962等待cycles。只有本合法行出口通过，不外推全图性能。

[formal01实际结果](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_formal_01/numeric_result.json)PASS：query0..7完整K128/D64，原allQK→allSM→allAV屏障；绑定错head/ref拒绝、55字全读回、实际MUL活动reset、实际ADD活动且ap_ce=0时reset抢占、旧epoch拒绝并重载、Q最后d63=Inf拒绝且无score发布、旧scratch拒绝、chain保持、真实流水CE均通过。状态快照额外包括小RAM绑定/row_phase/q/y；所有score/max/exp/sum/prob/out逐位。guard205.234928s、RSS2,083,400KiB、exit0/null；总856,061cycles、QK278,562/SM80,824/AV66,384/LOAD132,309等待cycles。实际vendor监视MUL141,378/ADD214,319/DIV1,114检查通过，含idle重复，不能当语义操作数。仿真136.920s约6252cycles/s；全128估8–9Mcycles、约1400–1800s，在预设3600s/40M帽内，模块OOC后继续。实际完整生产唯一服务实例与整体高性能仍未验收。

[OOC01实际结果](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_ooc_01/ooc_result.json)PASS：对同一冻结CE闭包在`xcu55c-fsvh2892-2L-e`实际综合，blackboxes=0并生成综合DCP。资源为LUT10,399、FF6,282、DSP22、RAMB36E2 145加RAMB18E2 7（148.5 BRAM tile，297 RAMB18等价）、URAM0。原69 BRAM18的HLS估算低估了实际容量；生产blackbox后续以实测297 RAMB18等价计费。6.667ns约150MHz的综合内部WNS+2.807ns、TNS0、WHS+0.041ns；无未约束内部endpoint，但132输入/39输出没有delay，且尚未布局布线，不能作为完整top时序或Fmax通过。guard247.965558s、RSS5,694,292KiB、exit0/null，最低MemAvailable422,309,760KiB。报告及DCP的SHA保存在同一receipt。

[head12801身份](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/input_manifest.json)冻结formal01编译snapshot及独立runtime副本，执行`ROWS=128/PROTOCOL=1`，完整query0..127、每行K128/D64及原16row阶段屏障；8GiB/3600s/40Mcycles和真实语义120s停滞保护保持。独立log/WDB不覆盖formal01；外层检查精确rows128数值PASS且无Fatal/ERROR。该尝试先在同树heavy-tool锁队列等待，实际启动后完成结果如下。

## 2026-10-11 完整head128 RTL与稳定CE blackbox交付

[head12801实际结果](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/numeric_result.json)PASS：B1/S128真实enc0/head0的全部128query、128key和64feature，八个16row批的QK→SM→AV屏障均通过。score16,384、maximum128、exp16,384、sum128、probability16,384、output8,192，共57,600阶段参考值逐位一致，另保留12个exp边界、55word完整绑定读回、错head/ref、两类活动FP复位、暂停时复位抢占、旧epoch/旧scratch拒绝、最后F32输入非法及chain/CE保持检查。930成员状态快照、完整phase行覆盖、96项冻结输入身份及fixture全部products hash由冻结收集器核查；CE补丁历史manifest保持原hash，由外部receipt登记PASS。

guard退出0、trigger=null，实际1721.066682s、owned RSS951,152KiB、最低MemAvailable413,508,736KiB；xsimkernel CPU1714.840s。总TB8,380,004cycles；累计QK命令4,456,856、SM1,295,224、AV1,064,192、LOAD370,501cycles。被动FP比较MUL2,261,051、ADD3,429,681、DIV17,914，包含idle重复，不能当独立语义操作数。

| query范围 | QK命令cycles | SM命令cycles | AV命令cycles | 正常计算命令cycles |
| --- | ---: | ---: | ---: | ---: |
| 0–15 | 557,114 | 161,904 | 133,024 | 852,032 |
| 16–31 | 557,106 | 161,904 | 133,024 | 852,032 |
| 32–47 | 557,106 | 161,904 | 133,024 | 852,032 |
| 48–63 | 557,106 | 161,896 | 133,024 | 852,024 |
| 64–79 | 557,106 | 161,904 | 133,024 | 852,032 |
| 80–95 | 557,106 | 161,904 | 133,024 | 852,032 |
| 96–111 | 557,106 | 161,904 | 133,024 | 852,032 |
| 112–127 | 557,106 | 161,904 | 133,024 | 852,032 |

每批QK命令计数含加载前拒绝的2cycles，首批另含故意CE暂停8cycles；正常计算合计6,816,248cycles，平均53,251.9375cycles/query。首批完成跨度1,311,266cycles含定向协议、复位和四次初始KV重载；后续七批完成间隔除48–63批为1,009,801外均1,009,809cycles，包含绑定、加载及TB读回/chain保持。上述总TB跨度不是生产请求时延。正常计算为不重叠cmd7/8/9接受到实际ap_done的服务成本，尚需另外计生产caller、存储搬运和请求退休。

按OOC请求150MHz条件换算，正常计算为45.441653ms/head；相同shape/mode的480个head任务计21.8119936s。这是当前实现必须支付的条件计算费用，未证明实际整图时间或高性能；原理想QK/AV投影仅保留其历史配置含义。下一阶段应依据实际QK/SM瓶颈、FP共享及KV端口/容量改善服务，方案由root/Astra集中评判后连续实施。

[官方blackbox JSON](blackbox/laya_attention_service.json)及[依赖闭包](blackbox/dependencies.json)现已重生成到实际CE闭包，引用完整head128和OOC匹配hash的外部receipt，资源元数据使用10,399LUT/6,282FF/22DSP/297 RAMB18等价/0URAM。36个Verilog、5个实际vendor IP Tcl、10个初始化数据及60项依赖hash已核对。[交付身份](../../../../results/compute_throughput_optimization_20261010/attempts/t5_attention_service_rtl_head128_01/blackbox_handoff.json)保存当前及冻结副本SHA；生成接口为`attention_make_blackbox.py HLS_OR_CE_CLOSURE --ooc-result MATCHING_OOC_RECEIPT --rtl-result MATCHING_RTL_RECEIPT`。`latency=1/II=1`仍只是scheduler导入元数据；生产接入必须以实际ap_done退休，并证明完整HLS/RTL中唯一共享服务实例、加载全部实际IP和初始化数据。新生产完整CPU/CSim及B1服务/B2退路由生产owner按自己的当前build另行验收。

本次闭合的是上述完整enc0/head0的模块数值/协议及独立OOC。其他head/层/shape、完整生产同runtime RTL、整图资源fit、P&R、实达Fmax和板端保持未验证。按root最新接续要求不追加旧leaf A/B或其它head重工具；旧baseline准备包保持未启动，未产生速度比。

## 2026-10-15 修订16真实FINAL消费者分版功能仿真

工程阶段证据为 project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev16_attention_consumer_engineering_handoff_20261015.md 和逐笔guard账 SM004_rev16_guard_ledger_AT266_AT272_20261015.json。旧AT268 adapter 5a44a3bc…在同runtime head0八tile通过：8200 AR/8704 R、512 OKAY B，score/prob各16384、ATT_OUT 8192 F32逐位；413.674108074978s。当前adapter 6d59c390…在AT270 Q页尾RRESP错与末B错后无reset完整正常tile、AT271页界和AR/R/AW/W/B有限停顿、AT272 Q最后R错误及K首R错误后无reset正常tile均局部PASS。AT272 static43.71585061773658s、RTL两例62.811791421845555s和55.007858550176024s，guard均child0/null；新SHA未跑完整八tile。AT266参数/Fatal、AT269错误恢复Fatal、AT270 AW停顿未命中Fatal原样FAIL，不因后续修复改写。

AT266–272原guard 7笔static308.28305006958544/1800s、14笔RTL1094.2193052433431273/3600s，231条政策零失配；host完整UNKNOWN。HLS综合、当前adapter模块OOC、P&R、实际Fmax及板端本段均NOT_RUN；旧service单模块OOC不能迁移为消费者联合资源。模拟发布peer与软件捕获QKV只验证消费者，真实128行FINAL发布、同runtime producer交接、其他15head及完整Encoder/模型尚未验。
