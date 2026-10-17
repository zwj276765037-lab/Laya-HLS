# Group32激活量化：平台、资源与性能记录

当前状态（2026-10-07，P2 F0功能验证通过）：Group32完整K量化及A8来源/epoch检查接入全网络，当前完整CPU/CSim逐位通过。 最终模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| 当前阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整Quant任务](../../../../hls/operators/full_tasks.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| 当前完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 逐组Q8字节与独立fixture核对；完整B2实际Quant1924次 | [十矩阵任务](../../../../results/engineering_p2/full_cpu_final_20261007/matrix_dut/full_matrix_dut_report.json) |
| 当前完整top HLS CSim | 实际13参数top，标准libm、严格浮点O2，真实B2 47点/9,047,192个F32/37158任务PASS | [最终CSim日志](../../../../results/engineering_p2/csim_full_final_20261007/csim.log)；默认HLS数学模型及RTL非线性误差仍未验收 |
| 代表性RTL | 整网RTL未运行；isolated证据仅对实际用例有效 | [阶段边界](../../../../hardware_agent/task.md) |
| 完整top实验综合 | 已执行当前源码完整top综合；后续工具进程内存约244GiB、可用内存降至约179GiB后保护终止，exit1；无完整资源/接口/RTL报告 | [最终尝试机械复核](../../../../results/p2_environment_20261007/final_synthesis_attempt_mechanical_check.json)；[本次日志](../../../../results/engineering_p2/csynth_array_f0_final_20261007/csynth.log)。工具主机内存限制不等于FPGA资源超限结论 |
| 平台与性能 | XRT实际编译、platform link、xclbin、布局布线/时序、上板质量/稳定性与性能均未验收 | [真实Host依赖诊断](../../../../results/engineering_p2/xrt_host_dependency_probe_20261007/configure.log)；当前串行F0不沿用旧并行阵列/25–50ms目标 |

当前编译身份见[模型与源码机械复核](../../../../results/p2_environment_20261007/final_model_identity_mechanical_check.json)。CPU门禁报告只判CPU，CSim由独立HLS运行证明；静态模块登记的pending字段不是动态验收状态。S64/256/512/1024仅完成任务/边界补充，完整网络运行仅S128。§1–§6与2026-10-05记录是P0历史候选预算，后续P1/实施中记录按其原始run阅读，不能覆盖页首当前阶段结论。

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
