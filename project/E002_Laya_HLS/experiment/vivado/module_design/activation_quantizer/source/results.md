# Group32激活量化：平台、资源与性能记录

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入F32[rows≤16,K≤4096]，每32项输出S8[32]+F16 scale；A8 tile供完整N复用。

每组扫描32次（3cycles/项），再量化32次（3–8cycles/项），另有scale/half和控制。input_lanes=8不是8并行RTL lane证明。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-activation_quantizer)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：Group32完整K量化及A8来源/epoch检查接入全网络，当前完整CPU/CSim逐位通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整Quant任务](../../../../hls/operators/full_tasks.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 逐组Q8字节与独立fixture核对；完整B2实际Quant1924次 | [十矩阵任务](../../../../results/engineering_p2/full_cpu_final_20261007/matrix_dut/full_matrix_dut_report.json) |
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

本模块具体推导依据[08](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md)、[09](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### 两遍周期与上游限制

8lane两遍数据服务为`2×M×K/8`，M16时：

| K | 两遍cycles | 150MHz时间 |
| --- | --- | --- |
| 1024 | 4096 | 27.307μs |
| 2624 | 10496 | 69.973μs |
| 4096 | 16384 | 109.227μs |
| 256 | 1024 | 6.827μs |

gate→quant直接连接的K2624首遍为16×2624/4=10496cycles，重放为16×2624/8=5248，合计15744cycles，其中首遍可与gate输出重叠，不能再重复相加。以上不含scalar/FP尾和消费者停顿。

最大FP32输入双512KiB＋A8/scale双136KiB，另参数表每bank最多12KiB。该容量同时列在统一缓存表，整核汇总只计一次。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

双FP32输入512KiB、双A8/scale136KiB，另双参数表最多24KiB及有效位/FIFO；物理端口复制尚未核定。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_activation_quantizer` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G3可执行量化参考和FP16转换；G4 reciprocal II、banking、实际tile就绪周期。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前实现核对QuantTask的stage/行空间/来源region/K/lane和Q8Group数量；真实Q8 scratch检查是已有原生34B组的无损格式回放。尚未实现候选量化算术，也未在A8状态中保存并核验K/rows/batch/row0/row_space及源epoch，后续必须将这些元数据绑定到Linear消费者，不能以Q8_TILE内容标签代替。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。

## P1数值切片预算与验证待办（2026-10-07，Astra xhigh）

依据[task.md §11](../../../../hardware_agent/task.md)和本模块design新增细化。本节只登记新设计预算；Sol执行后追加准确配置、源/数据hash、命令、日志、统计及分阶段结论，保留P0历史。

输入接口16×4096×4=262144B；A8接口16×128×(32+2)=69632B；局部32F32组缓存128B。有效K才参与运算，各group两遍32值；不强制另复制完整输入。scalar除法/倒数延迟未测，不承诺每4cycles一组。

候选isolated HLS器件为本机catalogue的`xcu55c-fsvh2892-2L-e`，请求150MHz/约6.667ns只作实验配置；实际U55C part/platform/shell仍未冻结。Vivado/Vitis 2025.2可用，器件查询见[环境证据](../../../../results/p1_environment_20261007/query_parts.log)。本节写入时CPU数值/独立参考联测、HLS CSim、isolated综合均未执行；RTL cosim、布局布线/时序、xo/xclbin、U55C上板均未执行。LUT/FF/DSP/BRAM/URAM、Fmax、II和延迟未测，禁止用上述容量算式当作资源结果。

## P1实际运行与阶段结论（2026-10-07）

最终版代码、配置、参考身份见[CPU源哈希](../../../../results/engineering_p1/20261007T021236Z-1800667/source_hashes.sha256)、[HLS源哈希](../../../../results/engineering_p1/20261007T021255Z-1801905/source_hashes.sha256)及[fixture逐项报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)。两个正式run保存各步命令、工具版本、完整日志与退出码。

| 阶段 | 实际结果 | 证据与边界 |
| --- | --- | --- |
| CPU Release直接TB | `numeric_activation_quantizer` 30例通过；configure/build/CTest退出码均0 | [CTest日志](../../../../results/engineering_p1/20261007T021236Z-1800667/ctest.log)；含half边界、非有限、来源身份、READY/READ/FILL/reset和失败后epoch |
| 真实模型离线数值 | 30个真实切片＋1个K4096固定seed补充切片的每个有效Q8字节和FP16 scale均与独立oracle一致 | [fixture日志](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture.log)、[逐项报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)；native scratch仅有差异指标，补充seed不代表Decision全链 |
| Vitis HLS 2025.2 isolated CSim | Group32直接TB 30例通过；CSim退出码0 | [csim_quant.log](../../../../results/engineering_p1/20261007T021255Z-1801905/csim_quant.log)；clang-16，真实DUT/TB，实验器件`xcu55c-fsvh2892-2L-e` |
| isolated HLS综合 | `activation_quantizer_compute`的Tcl csynth退出码0，产生RTL及[完整报告](../../../../results/engineering_p1/20261007T021255Z-1801905/activation_quantizer_compute_csynth.rpt) | [synth_quant.log](../../../../results/engineering_p1/20261007T021255Z-1801905/synth_quant.log)；150MHz请求、HLS估算时钟4.767ns、估算Fmax 209.78MHz；LUT75650、FF30642、DSP3、BRAM18K 0、URAM0。[组循环报告](../../../../results/engineering_p1/20261007T021255Z-1801905/activation_quantizer_group_csynth.rpt)给出目标II1、达成II244。x/q/scale为`ap_memory`端口，外部数组未折算为片上BRAM。顶层未流水；报告最大latency 127428158 cycles及XML平均68.759ms来自HLS对rows0–255、groups0–2047等字段类型上界的保守推断，不是合法任务的实测延迟或吞吐。日志明示“All loop constraints were NOT satisfied”，故不据此报告生产II达标或布线后150MHz。 |
| RTL cosim、布局布线/时序、xo/xclbin、U55C上板 | 未执行 | 器件是本机catalogue实验part，实际shell/platform、XRT和生产AXI/HBM尚未冻结 |

本轮首次裸`--mode hls`调用在CLI参数检查以退出码2失败，随后改用[csynth Tcl](../../../../config/numeric_hls_quant.tcl)成功；原始失败[日志/退出码](../../../../results/engineering_p1/20261007T020512Z-1792411/synth_quant.log)保留。P0独立回归在[20261007T021407Z-1804638](../../../../results/engineering_p0/20261007T021407Z-1804638/ctest.log)维持20/20。旧§2的8lane吞吐和资源预算不适用于当前串行切片。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

quant输入最大262144B、A8 69632B单bank；不因每8列输出重做量化。B2/S1024全部Q8层的A8 claim上界15364/请求，仅为设计计数。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


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

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。本模块使用固定cache访问器，量化算术文件保持逐字不变；身份和错误路径仍由共享Runtime/owner规则约束。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |

## T4 quant16独立候选当前证据（2026-10-10）

| 阶段 | 状态与范围 | 证据 |
| --- | --- | --- |
| 轻量CPU功能/调度 | **PASS，限独立候选**。真实LN_FFN→Wi的K1024一行与GEGLU→Down的K2624一行，全部q字节、half scale同独立T2 fixture一致；各组d_full/reciprocal核对。两次运行各可同时发布双A槽；32slot调度中峰值有3个已预约组，scalar issue/return分别为32/32和82/82。零、极小、roundf正负半整数、倒数溢出、来源coverage/完整身份、beat有效mask短例通过。 | [preflight_06原始日志](../rtl/quant16_preflight_06/run.log)及[源码/输入/编译制品哈希](../rtl/quant16_preflight_06/identity.json)；真实fixture源见[Wi/Down manifest](../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json)。preflight_03测试把build-tag不匹配期望为E_MODEL而共享规则给E_BUFFER，修正后_04及结构调度后的_06通过；历史日志保留。 |
| 冻结真实fixture与功能HLS入口的主机预检 | **PASS，限主机C++**。独立NumPy参考从T2真实Wi/Down各第0行重新生成q/half，逐byte与T2 fixture相同；每组另冻结amax/d_full/reciprocal位型。准备的`laya_quant16_functional`入口直接调用原32slot候选，主机运行对1024+2624个q、114个half及逐组d_full/reciprocal逐位比较，并拒绝坏16lane mask和未发布源。guard exit0、1.776s、峰值81440KiB、无保护触发。 | [fixture清单](../rtl/quant16_fixture_01/manifest.json)、[HLS配置与源码身份](../rtl/quant16_hls_preflight_01/source_manifest.json)、[主机原始日志/guard/制品身份](../rtl/quant16_hls_preflight_01/host_identity.json)。这不是Vitis CSim或HLS综合结果。 |
| HLS真实FP、RTL与性能 | 旧记录时间点为NOT_RUN；此后功能入口CSim/cosim及单divider RTL已执行，见紧接追加。CPU队列仍不是实际divider延迟；16lane并行、完整A及生产链接尚未验收。 | 联合合同[§7.3–7.4](../../../../results/compute_throughput_optimization_20261010/source/design.md)。 |

### T4 quant16功能入口与单divider服务追加（2026-10-10）

`laya_quant16_functional`的真实Wi K1024、Down K2624两行Vitis CSim与一次数值RTL cosim均PASS；RTL四事务计71571 clocks、guard exit0。`syn_03`实际为1 FMUL/1 fdiv、单8bit q写口且主循环未流水化，故记`IMPLEMENTATION_GAP`，不能当16M/16bank/4clk达成。原始报告分别在[CSim](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_hls_csim_01)、[syn03](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_hls_syn_03)和[cosim02](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_hls_cosim_02)。

独立[单divider服务](../rtl/quant16_divider_service.sv)直接使用`syn_03`原F32 divide IP的两路operand valid和result valid，32项tag FIFO；复位后保持时钟运行、12拍隔离无reset IP的旧返回。[真实Wi/Down短RTL记录](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_divider_real_01/receipt.json)PASS：Wi32组与Down82组共114个SCALE、114个RECIP逐位相等；各例首32个SCALE连续每拍接受、全局最小issue gap 1clk、实际pending峰值6；slot/epoch/tag和守恒通过；3笔旧在途后reset隔离12拍，仅1笔新返回。Vivado/XSim guard exit0、33.06s、峰值owned RSS 1768088KiB。此独立证据只证明该真实IP的单divider事务/数值/II与短复位隔离；bank、16FMUL和输出债务的后继接入结果另见下节，不能从独立divider推出完整A发布或生产链通过。

### T4 quant16完整局部流式服务：真实一行与短边界（2026-10-11）

[real03原始收据](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_real_03/receipt.json)和[模拟日志](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)保留原FP IP、16个FMUL实例、输入身份与全部测试。其总体状态为**NUMERIC_FAIL**，不是完整量化服务PASS。

| 范围 | 实际结果 |
| --- | --- |
| 真实Wi K1024一行、Down K2624一行 | **PASS，限局部一行服务**。各32/82组、1024/2624个q字节，全部half、d_full、reciprocal及divider输入amax逐位对冻结独立fixture；两扫bank读各2拍/组、16FMUL两个half/组、scale/recip issue-return、128bit输出握手与最终零债务READY均由TB检查。含每5拍一次输出反压，命令从start到done分别141/341 clocks，完整命令均摊4.406/4.159 clocks/group；该均摊含填充/尾部，非逐组issue gap或稳态4clk证明。 |
| 零、舍入、协议、错误与复位短例 | **PASS，限定已列用例**。零与正负0.5/1.5 roundf，坏第二half mask返回协议失败且无部分输出；1e10 half溢出、Inf输入、较晚组先返回错误但首错仍取较早组、两slot分别非有限的本地poison共4数值错误例；divider与FMUL各一次在途reset取消后合法两组任务恢复。 |
| tiny reciprocal | **FAIL**。原CPU边界F32 `1e-38`（bits `006ce3ee`）在实际服务里amax仍为`006ce3ee`，原divider返回d_full=`00000000`，因此RECIP发/返0，两个q half输出并给READY；合同要求非零subnormal d_full继而reciprocal非有限，目标INVALID。未改独立期望、容差或接受标准。该差异与既有FP119原fdiv首差的denormal/FTZ现象相符，但修正是否复用既有R0有限域adapter须由集中数值审核决定。 |
| 资源及未覆盖 | real03 guard子进程exit1来自上述数值fatal，无资源触发，40.062s，峰值owned RSS1904936KiB、最低MemAvailable392149024KiB；8GiB/3600s有限RTL帽内。逐组服务gap/首末issue时间、完整NumericIdentity/BufferRef、双A槽物理存储/lease、生产源→量化→Q8链、综合/P&R/板上均**NOT_RUN**。 |

[real01](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_real_01/guard/driver.log)首次真实IP编译/装载成功但TB在复位释放同delta采样start_ready而未发命令；修复采样时点后[real02](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_real_02/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)已出现相同真实两行PASS和tiny首差。real03只调整短例顺序及打印首差位型，以完成其它独立短例，末尾tiny仍按原断言失败；三个尝试日志保留。

### T4精确位适配集成实际RTL（2026-10-11）

按联合合同§7.3.2完成单一候选集成，[adapter01收据](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_adapter_01/receipt.json)为**PASS_SCOPED**，[原始模拟日志](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_adapter_01/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)保留全部检查。真实运行沿同一原F32数学图和独立gold，使用六级5bit tiny restoring流水、32项FP/helper双返回预约环、subnormal RECIP归一化/指数恢复及16lane乘法缩放/q0旁路；仍为1原F32 divider、16原FMUL、32group、16bank，没有扩大数量。257项[运行身份](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_adapter_01/input_manifest.json)在run后逐项复核0 stale。

| 范围 | 实际结果 |
| --- | --- |
| 真实Wi/Down一行 | 原冻结独立fixture全部1024/2624 q字节、32/82 half及逐组d_full/reciprocal通过；每组两扫各2读拍、两个16lane FMUL half与实际128bit输出commit、覆盖及done零债务通过。命令周期141/341；SCALE实际issue gap均为1至4clk，slot峰值24/32、divider环峰值7/7。各例SCALE与RECIP语义分别32/32或82/82，FP实际64/64或164/164，dummy/helper均0。命令总周期不是完整生产任务稳态4clk/group证明。 |
| 真实服务首末事件（命令后clock索引） | Wi SCALE issue12..109/return19..116、RECIP issue20..117/return27..124；Down SCALE issue12..309/return19..316、RECIP issue20..317/return27..324。输入/除法/输出stall分别0/3/14与68/3/34，全部计入上述命令窗口。 |
| 原tiny首差 | `006ce3ee→0000db7f→7f800000`逐位通过；SCALE/RECIP各1发1返、FP2发2返，其中dummy1/helper1发1返；按reciprocal错误返回INVALID、零输出。保留原real02/03 FTZ失败与匹配源码preimage，不改其失败结论。 |
| 27个受影响短边界 | [独立R0 fixture](../../../../results/compute_throughput_optimization_20261010/attempts/quant16_stream_adapter_01/fixture/manifest.json)经原exact-rational参考重新复核；17成功、10数值拒绝均通过，覆盖tiny零舍入、reciprocal溢出相邻值、tiny/normal接缝、正负subnormal半整数邻值、normal ties及half舍入/溢出。成功case的活动FP route逐位核真实product，全部route核q/half/d/recip/status；未重跑旧65group RTL suite。 |
| 混合路由/复位/旧边界 | 连续normal/tiny/zero六组及normal组signed minsub/±0，在原每5拍一次输出反压下PASS，48clocks、192 q字节；SCALE6/6、RECIP5/5、FP11/11、dummy4、helper4/4，slot峰值6、环峰值5。独立token scoreboard核语义退休顺序；helper、归一化RECIP、FMUL/q0旁路各一个实际在途整域reset并新任务恢复通过。原两类reset、坏第二half mask、half溢出/非finite/跨组首错/各slot poison仍通过。 |
| 资源与边界 | guard exit0、42.981s、owned RSS峰值1903516KiB、最低MemAvailable390882276KiB，无8GiB/3600s保护触发，TB有40M总clock硬上限。LUT/FF/BRAM/DSP实际综合与150MHz/P&R/总体fit仍NOT_RUN；完整NumericIdentity/BufferRef、物理双A/lease及实际LN或GEGLU→quant→TM4/Q8生产链仍未连接。 |

### 真实 GEGLU→物理 GATE→整行量化→完整双 A 半链（2026-10-11）

`t2_geglu_gate_quant_bridge_rtl_01/receipt.json` 为 **PASS_SCOPED**，SHA256 `d38ebd70eedd36171c61e23ff7456f284eac6ede7a88738f86b5bda84e29ab79`。冻结的原始完整 WI checkpoint 5248 个 F32 进入真实 canonical GEGLU，产生 2624 个逐位独立 gold 的 GATE 值；全部 164 次 AXI512 AW/W/B 真实完成后，writer/ledger 才发布任务并授予完整身份的 GATE 读 lease。实际 feeder 从 TB 仅由上述写事务填充的物理内存读取 164 beats，启动一次完整 K2624 行量化，全部 82 组的 q/d_full/reciprocal/scale 逐位通过，并写入完整双 A 缓存。消费者 acquire 后同步读取全部 82 组 q/scale/owner，检查 held return 后 release。没有预填 GATE/q/scale/PS。

实际静态编译/展开 guard 为 exit0/null，50.552165s、RSS峰值2200264KiB；独立 RTL pilot 为 exit0/null，39.908101s、RSS峰值1325344KiB。链路共20980 clocks（含外部标量 WI 装入、G 算术与标量输出、真实 AXI 写/读和反压）；完整量化任务窗口954 clocks，延迟 B 累计2951 clocks。检查了未授权外层 owner 零发射拒绝、完整 WI read-debt 屏障、真实最终 B 屏障、完整 A 发布、terminal/return 保持。这些是该有限任务的实际周期，不是物理频率或全网吞吐证明。

本测试的 WI 是不可变独立 checkpoint 外部输入，尚未接真实 Wi Q8 matrix producer；resident Down/bias/finalPS/AXI 输出尚未连接。仅覆盖初始 reset；真实链路 active reset、较晚 source/算术/B/R/quant 错误、完整四行和双 A 并行尚未在本次半链测试中覆盖。旧独立组件证据保留原范围。

### Four-row GATE→whole-row quant→physical dualA (2026-10-11)

Actual RTL03 PASS: 20992 WI F32 words, 10496 GATE words, 656 actual AXI write beats/B completions and 656 actual read beats, 4 whole-row quant commands, 328 row-groups, all 328 full-A row/group returns checked; 59975 cycles with final-B and source-read-debt barriers. The same immutable WI numeric fixture is repeated in all four rows, so this is four-row physical/protocol coverage, not four distinct real activation rows. No GATE/q/scale/PS preload; upstream Wi Q8 and resident Down remain absent; active reset/late-error/two-A overlap are pending. Receipt: `results/compute_throughput_optimization_20261010/attempts/t2_geglu_gate_quant_bridge_rtl_03/receipt.json`, SHA256 `60730c7a7363c40d8ea4f12f0ff85feb0af27a9446aa1d5afb9fe88075ebde0b`.

### Stage-close new three-bank G affected bridge — four distinct original rows (2026-10-11)

PASS_SCOPED: `t2_geglu_gate_quant_bridge_rtl_04/receipt.json`. Real 20992 Wi words, 10496 GATE words, 656 AXI writes and reads, 4 row quant commands, 328 quant groups / 328 resident-A row-group reads. Uses four distinct original enc0 Wi outputs and independent original GATE/q/scale; rational R0 d/reciprocal/q/half independently cross-check all groups. New `geglu_row_bank_v1` and adapter frozen from vector owner row_bank_v1; old native canonical arithmetic reused unchanged. Outer reject zero issue, complete WI read-debt barrier, delayed actual B and final-B publication retained. No upstream Wi Q8 or downstream Down in this bridge. Initial reset only; late errors, active-chain reset and twoA overlap remain pending. Guard exit 0/null, elapsed 94.8545487280935 s, peak 1328936 KiB. Receipt SHA256 `f4b7e2729f3f74bf69629f5f8c77fb4a0d0782bee5587cb37bbbfe8d89e751cb`. Frequency/board NOT_MEASURED.
## 2026-10-11 GATE tensor ledger局部验证

`R003/gate_tensor_04`为PASS_SCOPED：1234 cycles，最大128个rows16窗口、2048行、同一GATE Ref/epoch；全覆盖与最终写债清零后只发布一次。READY后8个窗口逐项真实metadata acquire/release，held read debt阻止释放；另覆盖plan拒绝、重叠/乱序/错epoch、跨窗口cancel、同session更大request恢复和失败窗口不发布。rejects=4、publishes=3，guard child exit0/null，20.816296s，峰值1290512KiB。input manifest SHA256=`9fe0fa24e0fdf212dd3803e255e1b89a80de1a8a4a2aee04278de32a4ab49a31`，receipt SHA256=`dbc8e0e12a61f8757162c835c20d4c4492d51e89c9f16f4dd7fbd753bdda1314`。

`gate_tensor_01`仅runner根路径错误、`_02`暴露失败retire状态未锁存、`_03`复现并定位该响应脉冲问题，均保留原始失败。`_04`修复为与其余done响应一致的一拍注册错误状态后通过。此结果只签GATE owner/provenance metadata与显式读写债；没有GEGLU数值、物理payload、实际portal hub或完整G→LOAD→Q/L链结论。

## 2026-10-11 物理 GATE store 与独立 QUANT 运行证据

`R003/gate_store_04`为PASS_SCOPED：202711 cycles，65个实际物理行，其中首个完整tensor为64行、四个rows16窗口且共用同一GATE epoch。完整tensor执行10496个实际AW/W/B；加取消恢复场景总计10660个。末B反压解除后才发布，producer responses=6；guard 21.641107s、峰值1323428KiB。input manifest SHA256=`3b277bcb27783335b8dfc1e6d2766c3f3303635e7b53bab2a118a0ef6b84b6be`，receipt SHA256=`7f4b0d945f0d46389bbbedcbba29c125c0752f53e07bdb1b467c6095fad5d982`。该用例的 GATE word 是受控输入，证明 writer+ledger，不证明真实 GEGLU 算术或 quant。

`R003/gate_split_static_01`为PASS_SCOPED_STATIC：当前唯一 canonical GEGLU、物理 GATE store、延迟 QUANT 和完整 dual-A 层级编译/展开通过；48.698790s、峰值2133148KiB。input manifest SHA256=`98c1eeaa0770cab88c301244e75abbe1c0822159e7d12a95c90509c8f3b9fe47`，receipt SHA256=`44fd5ef269465e2d321f70a272d37ace57aedb017b9854618f28bfdc33b88aa0`。该结果没有运行或数值声明。

`R003/gate_split_04`为PASS_SCOPED_RUNTIME。static 52.656369s/2211368KiB，120s内一行pilot 32.550573s/1323892KiB、11769 cycles。full 1054.961660s、峰值1326676KiB、758736 cycles：四个G命令共64行、335872个真实WI words、167936个真实GATE words、10496个AW/W/B；全部G结束前AR和quant均为0，最后窗口退休后tensor才READY。随后一个独立Q命令领取window0，发56个AR并接收2624个R beats，完成16行、2624个quant half；GATE、q、d_full、reciprocal、scale均按真实四行fixture循环的独立gold检查，fullA四个rows4 view共检查1312个row/group值，最后释放GATE window和A lease并取消清理tensor。input manifest SHA256=`bb7309b0e22f1de7940a144e8e93269367953851441705ade1cfba14ed4b9809`，receipt SHA256=`f8ad62afc4595dd7eb6d680b5cce1b4f5b6cb71d4381ea989ab6b47cb2ab9ad8`。

主控审核指出原split TB按固定cycle间隔打印进度可被重复时钟刷新semantic stall。当前TB已改为仅在`write_beats+read_beats+quant_halves+a_words`单调增加后打印，guard另对split进度的`work/writes/reads/qrows`维护高水位，重复状态行不刷新。`R003/gate_split_progress_guard_02`有界执行1000条相同work行均不推进、两次真实work增加均推进，PASS；manifest SHA256=`b3090800273e75c206f520f52f2e5172b5111be44406512985e5dc8b98d175fc`，receipt SHA256=`20857a4505379318c2ee0812c02d035324b7130c9df3ed227c8cd206bb68ebe4`。`_01`因冻结检查缺少guard helper而FAIL并保留。本修复未重跑或重标`gate_split_04`，其冻结功能PASS范围不变；未来相关full使用新保护。

失败证据保留：`gate_store_01..03`分别为TB保留字、末B hold时序及其诊断失败；`gate_split_01`和`_02`为TB配置/row-done组合ready同拍采样死锁，`_03`在static/pilot通过后因100000-cycle进度间隔触发120s semantic-stall。`_04`只修复TB握手采样及进度可见性，DUT、fixture、gold和full覆盖不缩减。上述运行仍只签实际canonical GEGLU多窗口同epoch→独立QUANT window0→fullA的局部链；其余Q/L、LOAD、fullW/matrix、hub/caller、L2/L3、完整CPU/CSim和M004均未完成。

## 2026-10-11 组合入口与停滞解析边界

`gate_quant_matrix_parent_03`把本模块真实GEGLU/GATE和独立QUANT fullA端口静态接到父matrix，static PASS；一行真实G pilot为11773 cycles/63.410458s。完整组合按同profile投影5172s>3600s，记录`COST_STOP/started:false`，未取得同runtime G/Q→matrix功能PASS。独立`gate_split_04`的既有局部PASS保持，不扩大范围。

`gate_split_progress_guard_03`补齐已识别split前缀但缺`work`、缺字段或非法字段时不得刷新semantic stall；1000条重复work、三类坏格式均不推进，两次真实work增长和一个其它合法阶段日志正确推进。该有界检查未启动Vivado。manifest SHA256=`63bf56dfcb9a003a6487fed5cd6ecb6a22f984672a6a85e5c743baac58e6004b`，receipt SHA256=`51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

### QWIGQD0 same-instance source and GATE quantization (2026-10-14)

[AT034](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json) static/pilot/full PASS in the bounded B1/S128 four-row normal chain. The unchanged `quant_task_to_dual_a_v1` instance first read 256 physical 512-bit R beats of original LN_FFN F32 and committed 256 q halves/128 scales matching the original Wi gold, publishing slot0/epoch1 at cycle1101. After the Wi resident task and GATE physical publication, that same instance read 656 GATE beats, committed 656 halves/328 scales and published slot0/epoch2 at cycle162862. Down later consumed the second A and the full chain ended cycle206133 with source read-only and all output/guard DDR bytes checked. This is simulation evidence, not a physical area or Fmax result. AT033 full FAIL was a TB expectation of cumulative counters; feeder and dualA counters actually reset per accepted task. AT034 changed only the TB/runner against AT033, preserving the DUT identity. Details and limits are in [the phase report](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md).

### QAR0 shared admission (2026-10-14)

[AT035](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json) static/pilot/full PASS. A real dual-valid edge selected G, produced one owner-rejected zero-work response, then accepted the held external Q next cycle. Directed checks held G during actual external Q activity and its seven-cycle response backpressure, then held an external Q during real G/GATE-Q activity and response backpressure; each waiting command was rejected only after the active response consumed. The same four-row independent gold, real AXI, full 393216B DDR readback and Down final B/lease/consume passed, ending cycle206136. Source Q used 4 AR bursts/256 requested and received beats; first/last AR were cycles27/712, first/last R cycles31/938. Static/pilot/full cost 83.022106/29.197961/1782.005508s, full peak1505004KiB, no guard trigger. All 106 frozen manifest rows and 45 policy samples matched. [Full scoped report](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md). This is no general fairness/recovery, production permission, area or Fmax result.

[AT036](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT036_QAR0_default_static_01/receipt.json) reuses that exact frozen bridge and compiles/elaborates it as the default `EXT_QUANT=0` top. The affected static check passed in 53.105357s with child0/null, 31 matching policy samples and no identity mismatch across 106 inherited manifest rows; no G-only dynamic replay was performed.

## SM004修订7 Q选槽与联合LN→Q结果（2026-10-15）

最终Q RTL SHA `a1fd5b036d45f94fe6121ddd3f8e6b9c5764b48e1bf11c2164205bbc9ed3764a`。[AT130局部Q和LN→Q原日志](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)记录114组/3648字节Q与27个adapter边界逐位通过、82组任务164次预约=164真实发射，银行/四槽选择逐拍对标量oracle及四个新增相位reset后原gold恢复。受控平局只证明比较语义；正常真实任务另证回绕和并存请求。真实P1 gamma0/gamma1到row_valid分别8597/11087cycle，较旧版+24/+23cycle。

[AT131同版联合OOC](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/utilization.rpt)在Vivado2025.2、U55C、6.667ns下生成DCP、blackbox0：37346 LUT、12518 FF、50 DSP、16 RAMB18E2、0 URAM；Q层22619 LUT。相对AT116同设置LUT−4309、FF+326，WNS从−49.011改善到[−1.750ns](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/timing_summary.rpt)，TNS−1225.669ns，1294端点违例。新最差为FMUL结果经首错归并至done_status寄存器39级；AT132最终DCP只读证row_valid/done_valid均为逻辑LUT2。150MHz综合内部时序仍FAIL；无布局布线、I/O delay或板端频率结论。首个成功网表后停止本候选OOC，完整模型硬件仍未验。冻结身份、原成本和范围见[机读证据](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json)。

## SM004修订8错误元数据切分结果（2026-10-15）

现行Q SHA256 `bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`。AT134原Q数值/协议回归及四项真实返回握手上的受控坏数据覆盖均child0/null；连续两half候选捕获2/归并2且重叠1，三来源竞逐首错按逻辑序号为group0第31列，候选在途reset后原Wi正常行恢复。受控数值注入仅签控制，原114组和27 adapter逐位独立gold仍通过。同版LN→Q原P1两行数值、反压/错误/释放/实际FP在途reset均通过，gamma0/gamma1至row_valid端点差8597/11087拍。原日志和作用范围在[同一连接报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。

AT135缺三份IP Tcl于综合前失败；AT136有因补齐并证XDC综合前加载，但时序优化阶段触发120s semantic_stall，292.768357s、峰owned RSS17389648KiB，未生成DCP或资源/时序报告。修订8 OOC启动2/2已用，**新候选物理结论为COST_STOP，WNS/Fmax/面积UNKNOWN**；AT131旧版数据不可迁移。没有P&R或完整图结果。

主控守卫勘误后AT137第三次、最终一次同版OOC用371.136359s、峰owned RSS20560096KiB；同一冻结RTL/IP/Tcl/XDC实际完成`synth_design`，证明AT136的120s stdout静默不能解释为算法停滞。Tcl随后把Vivado时钟属性`6.66699981689453125`与`6.667`作精确浮点比较而child1，报告/DCP未写。该工具错误与原AT135/136各自终态并列保留；合计671.385747s、启动3/3，按合同不再运行。本版正式资源/WNS/TNS、blackbox终检和150MHz仍UNKNOWN，旧AT131结论不迁移；详见[同一连接报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。

主控后续修订8普通脚本修复覆盖原“3/3”停点，累计1800s帽不变。AT138同版OOC以child0/null得到完整DCP/报告，406.915653s、峰owned RSS20558300KiB；37569 LUT、12543 FF、50 DSP、16 RAMB18、0 URAM/blackbox/latch，LN/Q层级LUT 14454/22829。综合前6.667ns约束下内部WNS−1.408ns、TNS−863.788ns、1316个setup违例，最差q divider head→first_error_key，32级/8.057ns数据路径。check_timing内部无未约束端点，但输入95/输出416口无I/O delay，且没有P&R，故150MHz内部检查FAIL而布线Fmax未知。AT139同DCP定点只读：first_error_key−1.408ns，numerical_error+0.477ns，done_status+4.014ns；q0/q1及顶层bank RAM写数据脚仍无可报告路径，不能判PASS。修订8OOC累计1078.301400s，已测static118.292583s；[同一连接报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)给出冻结身份与原始报告。AT134同身份功能局部PASS，不代表完整Wi或全图。
