# 总体集成：平台、资源与性能记录

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入为13个BO与B/S请求，输出为384 B结果帧；完整C++图包含28 Encoder、2 Decision及Scorer/ACT。

完整成功图保留现有Q8 leaf调度时，B1/S128仅Q8组体29.31–32.59min，B2为58.62–65.17min@150MHz；其他成本另加，现有RTL提前错误路径不适用该下界。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-top)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：28层Encoder、2层Decision及scorer/act已完整连接；当前包的CPU整图与真实13口HLS CSim通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整forward入口](../../../../hls/laya_forward_full.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 15模块/24生产源；141点与同Runtime恢复 | [完整CPU门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json) |
| P2早期完整top HLS CSim | 实际13参数top，标准libm、严格浮点O2，真实B2 47点/9,047,192个F32/37158任务PASS | [最终CSim日志](../../../../results/engineering_p2/csim_full_final_20261007/csim.log)；默认HLS数学模型及RTL非线性误差仍未验收 |
| 代表性RTL | 整网RTL未运行；isolated证据仅对实际用例有效 | [阶段边界](../../../../hardware_agent/task.md) |
| P2早期完整top实验综合 | 最新扩大内存重试仍未完成：已记录受控树/单clang峰值361.6/360.6GiB，可用内存降至62.4GiB后64GiB保护触发；Performance第4步有统计、HW Transforms仍pending；无完整资源/接口/RTL报告 | [最新单次运行记录](../../../../results/engineering_p2/csynth_expanded_memory_20261007T072000Z/summary.md)；[前次180GiB门槛机械复核](../../../../results/p2_environment_20261007/final_synthesis_attempt_mechanical_check.json)保留。主机内存保护不等于FPGA资源超限 |
| 编译器内存增长诊断 | 已定位`runtime`混合初值触发的全局宽整数拼接；W=2,653,009 bits、M=6,480,158个输入分片。唯一初值对照的15阶段统计相同，约3.57GiB峰值后进入函数指针转换并失败；HLSGen未通过，生产源未改 | [诊断报告与证据边界](../../../../results/synthesis_memory_diagnosis_20261007/report.md)；诊断清零不是生产修复或物理综合结果 |
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

本模块具体推导依据[00](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)、[16](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/16_llama_baseline_to_laya_u55c.md)、[03](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md)、[14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### 整请求算量与时间边界

主算例B2/S128、16候选，共256个token、16个TM16 tile。原研究记录约94.32 GMAC Q8 Linear及2.013 GMAC QK/AV。以候选4096整数乘法贡献/clk、64路FP、150MHz且理想发射率1估算，矩阵服务约为：

```text
Q8服务 ≈ 94.32e9 / (4096 × 150e6) = 153.5 ms
QK+AV ≈ 2.013e9 / (64 × 150e6) = 209.7 ms
两者约363.2 ms；若仅对这两项取算术效率0.65，约558.8 ms。
```

这些是取舍入算量的条件服务时间，未包括LN、量化、softmax、恢复瓶颈、读出、重排、访存、控制和Host等完整开销，不能直接当请求时延。效率0.65与HBM效率0.65是不同假设。

早期研究的约0.91–1.15秒/两题，以及300MHz/更大阵列约百毫秒，保留为历史条件场景；不能把它们当本版精确流水排程或已测P50/P95。完整预算需从各链路的实际trace合成；约50ms的A6000口述值不是同Typed两题配对结果。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

全网候选逻辑缓存16–20MiB，28MiB仅旧建议上限；大项约14.41MiB。资源汇总只统计真实实例一次；各模块引用同一缓存不能重复相加。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_top` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G1真实platform/复位；G2共享IO；G3导出器和Golden-C；G4整核资源/时序；G6/G7验收和GPU对照。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前集成只注册15模块状态、构建唯一合同源码并运行各模块及真实fixture格式测试；没有可调用的成功forward。基础状态模型只核对epoch/region、调用者声明的覆盖和content_kind，尚未完成A8的K/rows/batch/row0/row_space及源epoch、W的WeightKey/K/N、QKV的plane/head/B/S与请求/layer绑定。补齐这些关联后才可进入完整计算链和全层屏障验证，P0通过不等于跨模块数据一致性或全图数值通过。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。

## P1顶层离线驱动与完整forward状态（2026-10-07）

| 阶段 | 当前证据 | 顶层边界 |
| --- | --- | --- |
| P0合同回归 | [20261007T021407Z-1804638](../../../../results/engineering_p0/20261007T021407Z-1804638/ctest.log)：20/20，configure/build/CTest退出码0 | 仍是15模块的host-only合同 |
| P1真实数据离线驱动 | [CPU运行](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)：三个数值模块直接TB共116例、30真实＋1补充切片、132128个trace group逐位通过 | top/tb驱动只编排离线输入和独立期望值，不是硬件顶层调度器 |
| isolated HLS CSim／最小综合 | [HLS运行](../../../../results/engineering_p1/20261007T021255Z-1801905/metadata.txt)：三个数值入口CSim共116例；仅Quant入口csynth退出0并生成RTL | 实验part/150MHz配置下的子函数验证，不是单forward kernel、平台链接或板级时序 |
| 顶层HLS/RTL cosim、布局布线、时序、xo/xclbin、U55C实测 | 未执行 | 完整forward门禁仍非零拒绝；实际part/platform/XRT及全图模块连接未冻结 |

顶层没有可报告的资源、Fmax、II或完整forward数值结果；Group32的资源和HLS估算仅记在[量化模块results](../../activation_quantizer/source/results.md)。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2当前声明缓存复算（实施中，2026-10-07）

[当前FullCache声明复算](../../../../results/p2_environment_20261007/fullcache_declared_capacity_preliminary.json)记录13组数值数组合计8641536B，即8.2412109375MiB，包含单W q/scale/bias、A8 q/scale、量化输入、完整PS、两gamma、当前mode cos/sin、B2 KV/score、AV暂存及F16 act权重。该数值由所列header哈希对应的C声明逐项乘积相加得到，不含owner/来源元数据、请求输入、局部任务数组、编译器bank/padding及平台保留资源；后续声明变更须更新。

这是逻辑字节容量，不是URAM/BRAM数量或成功综合结论。HLS生成实例、RAM端口和物理碎片尚待完整top报告确认；局部数组若未共享也须计入真实资源，不能把原生产双bank容量或本表直接当作板卡利用率。


## 综合内存修复现行实测（04934，2026-10-07）

真实25源、13口顶层入口由 `full_kernel_wrapper.cpp` 与完整控制/任务链连接；本轮数值cache、owner索引和指针控制修复均不改变13个数据端口、请求身份、数值规则或图执行顺序。 当前包身份为 `04934c15b3f83e842ec2e92ac2a81bf2`；以下均为同一25生产源、13口顶层的实际运行，[中文总报告](../../../../results/synthesis_memory_fix_20261007/report.md)保留阶段边界。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与完整CPU | 103项身份输入仅五个获准生产文件相对历史f1a变化；27/27 CTest、75项数值正例和1项既有预期拒绝、141个逐位检查点、持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与真实CSim | 四次同进程shadow调用与72个F32值通过；真实Vitis CSim核对47点、9,047,192个F32值及37,158任务，0错误。 |
| 完整HLS综合/RTL | `SYNCHK`实际0错误、1警告；顶层Verilog/VHDL、IP及报告生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)、[工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源/时序与后续阶段 | **HLS估算**LUT 1,813,717，占U55C所列容量139%；顶层估算slack −0.07ns、估算Fmax 202.58MHz。当前资源预算未满足。完整RTL cosim、物理综合/P&R、平台链接、上板及性能测量未执行。 |
