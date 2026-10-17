# LayerNorm与完整行统计：平台、资源与性能记录

当前状态（2026-10-07，P2 F0功能验证通过）：完整行LayerNorm与gamma绑定接入全网络，当前CPU整图和真实top CSim逐位通过。 最终模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| 当前阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整LN任务](../../../../hls/operators/full_tasks_front.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| 当前完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 真实embedding norm；其余LN形态另由完整28+2层与尾链检查点约束 | [front直接任务](../../../../results/engineering_p2/full_cpu_final_20261007/front_dut/full_front_dut_report.json) |
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

本模块具体推导依据[07](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/07_layernorm_engine.md)、[08](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### LN与量化链路服务

- 每遍1024/8=128cycles；一行三遍384cycles；16行tile为6144cycles＝40.96μs@150MHz。
- F1a直送量化第一遍后，量化重放仍需16×1024/8=2048cycles。首A8 tile至少计6144+2048及归约/倒数/切换尾；不能缩成一遍2048cycles。
- 全网LN元素数为`(61×B×S+B×16)×1024`；B2/S128为16023552个feature。理想数据服务3×16023552/8=6008832cycles，约40.06ms@150MHz；该值不含scalar和停顿。
- QKV dot理想12288cycles/tile，scorer FC1仅4096cycles/tile；不同任务的LN隐藏程度不同。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

行buffer至少2×4096=8192bytes；gamma、树归约中间值和FP流水另计，物理RAM/FP资源未知。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_layernorm_engine` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G3 sqrt/div函数与Golden-C版本/容差；G4 scalar II/尾和RAM端口；G1复位。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P1数值切片预算与验证待办（2026-10-07，Astra xhigh）

依据[task.md §11](../../../../hardware_agent/task.md)和本模块design新增细化。本节只登记新设计预算；Sol执行后追加准确配置、源/数据hash、命令、日志、统计及分阶段结论，保留P0历史。

输入和输出各16×1024×4=65536B（接口）；本地单行缓存和tree工作区合计2×1024×4=8192B；gamma1024×4=4096B。只按本轮实际声明区分外部数组与局部RAM，不重复加总。串行树每次归约1023次FP32加法，每行mean/variance两树，不按原8lane/双行候选估计本切片cycles。

候选isolated HLS器件为本机catalogue的`xcu55c-fsvh2892-2L-e`，请求150MHz/约6.667ns只作实验配置；实际U55C part/platform/shell仍未冻结。Vivado/Vitis 2025.2可用，器件查询见[环境证据](../../../../results/p1_environment_20261007/query_parts.log)。本节写入时CPU数值/独立参考联测、HLS CSim、isolated综合均未执行；RTL cosim、布局布线/时序、xo/xclbin、U55C上板均未执行。LUT/FF/DSP/BRAM/URAM、Fmax、II和延迟未测，禁止用上述容量算式当作资源结果。

## P1实际运行与阶段结论（2026-10-07）

最终版输入/源码身份见[CPU源哈希](../../../../results/engineering_p1/20261007T021236Z-1800667/source_hashes.sha256)、[HLS源哈希](../../../../results/engineering_p1/20261007T021255Z-1801905/source_hashes.sha256)和[逐项fixture报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)。命令、版本、完整日志、退出码保存在各run目录。

| 阶段 | 实际结果 | 证据与边界 |
| --- | --- | --- |
| CPU Release直接TB | `numeric_layernorm_engine` 29例通过；configure/build/CTest退出码均0 | [CTest日志](../../../../results/engineering_p1/20261007T021236Z-1800667/ctest.log)；含大偏置近常数和次正规行的独立oracle位模式、连续owner反例 |
| 真实模型离线数值 | 跨三模块30真实切片＋1个K4096固定seed补充切片及132128个trace group逐位通过；LN输出与mean/var/inverse逐位比较 | [fixture日志](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture.log)、[逐项报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)；本模块包含ir_267→候选LN和ir_216＋emb gamma→候选LN，native LN仅记录差异 |
| Vitis HLS 2025.2 isolated CSim | LayerNorm直接TB 29例通过；CSim退出码0 | [csim_layernorm.log](../../../../results/engineering_p1/20261007T021255Z-1801905/csim_layernorm.log)；clang-16、实验器件`xcu55c-fsvh2892-2L-e`和150MHz配置 |
| 本模块isolated HLS综合 | 未执行 | 本轮仅Group32量化入口完成最小综合；LN资源/频率/II无实测报告 |
| RTL cosim、布局布线/时序、xo/xclbin、U55C上板 | 未执行 | 无生产AXI/HBM接口、完整forward或冻结platform证据 |

P0独立回归在[20261007T021407Z-1804638](../../../../results/engineering_p0/20261007T021407Z-1804638/ctest.log)维持20/20。当前LN仅为阻塞串行数值切片；旧§2的8lane、双行和全网周期仍是候选预算。LN_FINAL真实全链、其他S/B配置与400例质量集未执行。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

单行x/tree各4096B，gamma各bank4096B；复用公共tile暂存不重复计，完整HIDDEN/NORM外部HBM。实际资源/周期须新综合；旧P1 CSim不自动证明P2任务存储。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2真实front任务初步证据（2026-10-07）

[完整front初步报告](../../../../build/p2b-front-dut-prelim/full_front_dut_report.json)比较真实B2/S128的embedding raw、1024维LN_EMB及3个type行，共527360个F32逐位一致；来源直接取固定GGUF和真实请求，独立[fixture报告](../../../../build/p2b-front-oracle-prelim/full_front_fixture_report.json)登记身份。错producer stage、缺独立来源绑定与重复type写入均拒绝。该轮使用prelim2模型包，只证明front typed任务；完整网络和稳定源码最终包仍待验证。
