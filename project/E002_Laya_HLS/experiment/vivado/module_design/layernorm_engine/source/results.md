# LayerNorm与完整行统计：平台、资源与性能记录

## 2026-10-13 LN→真实store→Q 的LQ0/LQ1有限测量

LQ1R两版AT017/AT018的g++/HLS类型模型与单LN生成均PASS，**RTL均NOT_RUN，方向按两版上界no-go**。原LQ1最终循环F32减/乘native core `c_latency=0/0`，同一调度State3形成53.626ns组合路径；AT017局部`BIND_OP`请求4/3后，实际减/乘wrapper5/4级、core `c_latency=3/2`，最终II9，路径降到5.298ns，但top HLS估计slack仍为−0.43ns。AT018只调整减法请求4→5，实际wrapper6/4级、core `c_latency=4/2`，II10，路径5.277ns、slack−0.41ns；跨减末级→乘首级仍未达到4.867ns有效预算。AT017/AT018单top估计BRAM18均29、DSP均18、FF20136/20111、LUT48112/48107，均非物理资源。依合同不为两版启动static/pilot/full或F9错误回放，不补第三版。原始证据与受影响边界见[E005 LQ1对照](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)及[LQ1R停止报告](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md)。

E005/R001原冻结16行入口的LQ0数值PASS；仅最终归一化循环显式流水的LQ1也在同fixture、gold、AXI响应与完整Q/fullA生命周期下PASS。全TB至零债务659334→528307cycles（减少131027，19.8726%）；生成LN run含读算写649380→518354cycles。HLS循环实际II2，单top估计DSP13→18、LUT47775→48104；估计slack0.00→−48.76ns，关键路径为同一调度状态中的F32减法接F32乘法。此周期候选尚无目标时钟物理时序/联合资源验证，不作为生产请求或可实现150MHz收益。数值、接口、详细事件、工具和原始证据见[E005 LQ1对照](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md)。

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入F32[rows≤16,1024]及可选gamma[1024]，输出同形F32；两次1024元素行归约后归一化。

B1/S128共7824行、B2共15648行。已生成leaf主要循环体每行37874–41970cycles，另加sqrt/div、循环与数据搬运；不能用动态loop通用巨大max作当前行时延。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-layernorm_engine)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：完整行LayerNorm与gamma绑定接入全网络，当前CPU整图和真实top CSim逐位通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整LN任务](../../../../hls/operators/full_tasks_front.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 真实embedding norm；其余LN形态另由完整28+2层与尾链检查点约束 | [front直接任务](../../../../results/engineering_p2/full_cpu_final_20261007/front_dut/full_front_dut_report.json) |
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

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。LayerNorm数值叶子逐字不变；固定cache访问器保持gamma和工作数组的类型、容量、有效区与owner检查。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |

## T1 16行byte/wide前端A/B实际结果（2026-10-10）

本轮固定合同见[联合设计§2](../../../../results/compute_throughput_optimization_20261010/source/design.md)，输入及源码身份见[t1_csim_01收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_csim_01/receipt.json)。真实B1/S128 row0..15，raw与norm各16,384 F32/65,536B，gamma在AUX offset128。raw切片SHA256 `f6f6af0d7580cac57afa48a93559693819e04e7115d34aaa05619061346b947f`，独立norm切片SHA256 `ab9710b0dec2006ab0f7a596e26f9c3521c219a4bf42a35917276ef3bfd77362`；完整STATE0/IO/AUX/gold文件身份由fixture manifest逐项登记。

| 阶段 | 结果 | 证据/边界 |
| --- | --- | --- |
| CPU编译及真实16行CSim | **PASS**。byte/wide均16,384 raw F32逐位吻合独立生产值，norm各16,384 F32对独立gold最大绝对误差0；局部CRC、OBSERVED 64 words、输入只读、输出尾部sentinel均通过；raw/gamma非有限各top各一短负例通过。 | [run.log](../../../../results/compute_throughput_optimization_20261010/attempts/t1_csim_01/run.log)、[fixture manifest](../../../../results/compute_throughput_optimization_20261010/attempts/t1_csim_01/fixture_manifest.json)。这是host C++路径，未证明RTL总线行为。 |
| 资源保护/成本 | guard exit0，4.751s，owned RSS峰值210,840KiB，最低MemAvailable 441,743,532KiB；CPU0–3、nice19、idle I/O见原始策略记录。 | [guard_result.json](../../../../results/compute_throughput_optimization_20261010/attempts/t1_csim_01/guard_csim_01/guard_result.json)、[source SHA256](../../../../results/compute_throughput_optimization_20261010/attempts/t1_csim_01/source_sha256.txt)。 |
| 两top功能HLS与RTL normal A/B | **PASS**。HLS均生成可仿真RTL，byte AXI 32bit；wide STATE0/AUX/STATE1为512bit、OBSERVED 32bit。两种normal同一`static_02`及冻结fixture下原日志的TB reset-to-done分别为2,126,579与1,433,026 cycles；冻结AXI-Lite控制握手严格推得top启动在计数7，因此start-to-first-done分别为2,126,572与1,433,019 cycles，wide少693,553 cycles（32.6137%，1.484×）。每版16,384 norm F32与独立gold逐位相同，CRC32C `d5c15b0f`，首次done物理R/W/B债务零，guard与XSim退出码均0。 | [原正式normal收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_formal_four_02/normal_receipt.json)保留原日志口径；[周期推导收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_formal_four_02/normal_command_receipt.json)绑定冻结TB、control RTL、编译文件与起点推导，明确为离线推得而非直接采样。物理endpoint AR/AW单活动门控与握手数推得有事务口峰值1、无事务口0；TB文本中的`max_*_outstanding=1`是硬编码容量，未当实测。HLS adapter内部债务尚未独立探测。 |
| wide RTL pressure | **PASS**。`static_04`新增首次done同边沿的HLS用户请求/返回与外部pending探针；真实16行的norm数值逐位一致，CRC32C `d5c15b0f`，最终LN读R和最终norm写B各命中一次、各hold 4 cycles，首次done四端口物理和适配器债务均为零。原日志TB reset-to-done为1,433,032 cycles；同控制握手推得start-to-first-done为1,433,025 cycles。 | [wide-pressure收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_formal_four_02/wide_pressure_receipt.json)绑定guard exit0、XSim日志、fixture、runner、冻结TB/端点/DPI及参与编译的RTL/IP身份；周期为冻结握手推导。端点门控与实际握手数推得活动方向物理峰值1；HLS用户读请求未返回元素实测峰值STATE0=64、AUX=1，不能混称物理outstanding。 |
| 四配置`static_04`同版本收口 | **PASS**。补测byte/wide normal及byte-pressure均guard exit0、16,384个norm值逐位一致、CRC32C `d5c15b0f`，首次done物理和四口适配器债务零。normal的start-to-first-done由冻结AXI-Lite启动握手推得byte 2,126,573、wide 1,433,020 cycles；pressure为2,126,578、1,433,025 cycles。两组wide均少693,553 cycles（约32.614%、1.484×），pressure两版均比各自normal多5 cycles，R/B各hold一次、各4 cycles。旧`static_02` normal仅有物理债务，不能倒写适配器观测。 | [normal适配器补测收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_formal_four_02/normal_adapter_receipt.json)、[pressure两版收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_formal_four_02/pressure_receipt.json)保存各次guard、原日志及源码/fixture/IP哈希；start边沿为冻结控制握手离线推导而非旧日志直接采样。 |
| AXI端点短定向自检 | **PASS，限独立端点**。正例覆盖AW/W独立停顿、W先于AW、AW在首事务W/B未退休时阻塞及未完成写reset恢复；错误WLAST在端点的债务/LAST检查处触发预期fatal，未到达TB成功标记。 | [short03正例日志](../rtl/front16_axi_short_03/positive.log)、[short03负例日志](../rtl/front16_axi_short_03/negative.log)、[guard](../rtl/front16_axi_short_03/guard/guard_result.json)。XSim以`-onerror quit`运行时预期fatal进程仍返回0，包装器改用精确fatal文本与未到达成功标记判定；short01库名脚本错误及short02包装误判原记录保留。此测试不证明完整DUT reset恢复。 |
| 真实DUT RTL早错与活动复位 | **PASS，限16行局部前端**。同一`fault_static_03`的byte/wide各raw[0]、gamma[0]坏值四例及wide首命令活动中reset后重发raw坏值一例均通过。raw首错status1、useful 4B；gamma首错status2，合法raw先完整读取65536B、gamma useful 4B。五例LN start/done均0，norm写0，64个OBSERVED words与独立期望一致，首次done四口物理及HLS adapter债务均0。wide复位在首次活动命令已有64B物理raw读、端口债务未清时发生；同域复位、输出清除、raw坏值重发后无陈旧done。 | [早错/复位收据](../../../../results/compute_throughput_optimization_20261010/attempts/t1_fault_03/receipt.json)绑定冻结编译源码、全部生成RTL/IP、真实fixture、两份guard编译、五份独立运行guard和XSim原日志。`command_cycles`直接由新TB观察的top start→first done给出：byte raw/gamma为412/1016197，wide raw/gamma/reset重发为404/700810/404；它不是正常路径性能。旧`t1_fault_01`空闲`ap_done`误计失败及`t1_fault_02`诊断日志保持原状；`fault_static_03`只在已启动且未退休时计LN done。 |

本轮微基准只覆盖16行局部LN，不构成完整128行前端或生产owner成功验收。
## 2026-10-12 production producer 分区状态

既有 front16 wide/byte HLS 与 RTL 结果只证明固定 B1/S128 微基准，不能直接代签新的任务通道、身份绑定或 production BO 路由。首个 gamma=0 LayerNorm producer 分区已进入实现，当前尚无新 HLS/RTL 结果，状态为 **IN_PROGRESS / NOT_RUN**。

## 2026-10-15 M004 固定图完整单行服务结果

本节为新的 `laya_ln_row_v1.sv` 固定图计算服务；上文旧 production producer 记录是其原时点/不同接口身份，不据此提升旧 producer 为 PASS。AT107/AT108 同版 RTL SHA256 `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40`，逐文件冻结验证及累计守卫账见[机读证据](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_evidence_20261015.json)，完整限定解释见[阶段结果](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)。

| 阶段 | 本轮真实结果与边界 |
| --- | --- |
| MUL/DIV/SQRT 叶子探针 AT104 | 16 组连续输入逐位匹配独立 F32 位模式，观测固定 CE 返回 14/12/6 拍、所测 II=1；不签任意数值域或通用 CE 暂停。ADD 沿用未变 AT093 局部精确流证据。 |
| 完整单行 RTL AT107 | 九例局部自检 PASS；真实 gamma0 行 8482cycle，真实 embedding gamma1 行含反压 11792cycle、输出阻塞 820cycle；gamma2 复用 gamma1 数据 10546cycle。正常两行 mean、variance、inverse 和各 1024 个 y 对保存的独立核验夹具逐位相同；两树各十层、峰 ADD 占用 7、MUL 在途 15。错误首索引、完成保持、无 reset 连续命令与在途 MUL reset 后完整新行均受控验证。真实 final gamma 夹具、AXI/HBM 与整图未测。 |
| 语义失败历史 AT106 | 原日志 `Fatal: LN_GOLD id=8`，guard child0 不能解释为通过；为 reset 后 TB 错取 gamma1 gold。AT107 修正夹具映射并检查最终 PASS，保留旧失败。 |
| 单行 OOC AT108 | Vivado 2025.2、`xcu55c-fsvh2892-2L-e`、6.667ns 请求；DCP 生成且 blackbox0。综合 14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM、0 latch。14KiB 逻辑 payload 在本次未映射到 BRAM/URAM。内部 setup WNS +1.967ns，hold WHS +0.036ns；72 输入/179 输出无外部 delay、无 `HD.CLK_SRC`，不构成物理 Fmax。 |
| OOC 告警与成本 | `Synth 8-9873` 为同 SHA ADD 模块定义两次；冻结两个文件字节相同，当前综合采用后定义，清单去重留未来连接阶段。唯一 OOC 152.791918s、峰 owned RSS 4314552KiB、child0/trigger null。AT102–108 守卫累计 host 0.373702s（下界）、static 106.040047s、RTL 29.865697s、OOC 152.791918s；host 未守卫准备不补签。 |

本单行阶段 **局部功能 PASS、局部 OOC 已测**；无综合后优化/布局布线、联合资源与频率、完整 B1/S128 硬件请求、真实 final gamma 或板上结果。不能将 8482/11792cycle 直接外推成完整模型性能。

### AT109/110 首错修复受影响结果（2026-10-15）

旧 RTL `da8adccc…` 的独立原行反例期望 E_NUMERICAL/bad0，AT109 实测 bad1023、零输出，为语义 FAIL。修复版 `a46d468e…` 的 AT110 六条边界行及原九条完整行回归均 PASS；原反例与抵消溢出反例 bad0、零输出，四条正常边界行全部 1024 输出和统计值逐位同独立原行参考。真实 gamma0/gamma1 周期仍为 8482/11792；复位前 MUL 发射计数 8。详情与守卫身份见[同一阶段报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)及[机读收据](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_first_error_closeout_evidence_20261015.json)。本 LN 段累计受守卫计量 host 1.804670s（仅下界）、static 175.923183s、RTL 49.592227s、OOC 152.791918s。

AT108 的 14279 LUT/3375 FF/2 DSP、0 BRAM/URAM 和综合内部 WNS +1.967ns 是旧 RTL 身份的单行 OOC 参考。修复版独立单行 OOC **NOT_RUN**；联合 LN→Q 资源须由后续同版联合网表报告，不从旧版移签。真实 final gamma、外存、全图和物理 Fmax 仍未证。

### SM004 修订6 同版连接（2026-10-15）

[AT121 同版局部 RTL](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)五条正常行、四类错误按原范围 PASS；其原复位 marker 读到上一行 half_sent=64，本行 Q 在途覆盖未证明。AT123 修正 TB 后定向证明新 row31 cmd、Q输入2half、接受1组/覆盖0组后复位，但尚未到算术。AT124 再定向实测真实FP除法已发未返（pending1/returns0）时共同reset，16拍隔离内旧IP原始valid一次、未被本任务接纳、无ghost/协议错，下一正常行逐位gold PASS。历史 P1 两真实行的原X/gamma→LN全部输出和stats→Q8/FP16 scale可复读行逐位核原独立保存夹具；gamma0 cmd→行可用8573cycle，gamma1含输入空拍/Q输出42cycle合法阻塞为11064cycle。含测试消费者34次读及故意保持到最终done的端点差分别8855/11346cycle，不能当成最短服务时间或整模II。晚数值错和协议早停均不发布；无reset错误恢复与该算术在途复位后新行已局部验证。

[AT116 同RTL联合OOC](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT116_SM004_lnq_row_ooc_01/work/utilization.rpt)为41655 LUT、12192 FF、50 DSP48E2、16 RAMB18E2（8 tile）、0 URAM及0 blackbox；LN本体14504 LUT/Q本体26864 LUT，顶层本地逻辑287 LUT。q0/q1/scale 1088B 暂存映射为LUTRAM；8 tile BRAM来自别处。内部 WNS−49.011ns、TNS−50792.254ns@6.667ns，请求150MHz综合内部时序FAIL，最差Q槽序号→除法服务231级路径。最终DCP输出端口未被常量裁剪经只读审计，但95输入/416输出无delay且未P&R，实际可实现频率UNKNOWN。AT122–124受影响复位修正后，连接累计受守卫计量host1.606030s、static404.133281s、RTL175.407140s、一次联合OOC242.194084s，未触资源帽。全图、外存、矩阵和板端仍未验。

### SM004修订7同版LN→Q复核

LN RTL仍为AT110修复SHA `a46d468e…`，LN→Q顶层仍为`7c194fa3…`；Q切分版本`a1fd5b03…`的AT130重新核两真实P1行全部LN统计/1024输出及Q/scale原独立gold、反压/错误/读释放与实际FP在途共同reset，局部PASS。gamma0/gamma1命令接受→row_valid端点差为8597/11087cycle，相对原8573/11064分别+24/+23。AT131同版联合OOC为37346 LUT、12518 FF、50 DSP、16 RAMB18E2，内部WNS−1.750ns@6.667ns仍FAIL；LN层14441 LUT，资源属于完整LN→Q联合网表。细节和身份见[同一连接报告](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)。独立LN修复版没有重做OOC，真实final gamma、整图及布线时序仍未测。
