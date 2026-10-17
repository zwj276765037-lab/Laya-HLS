# 向量运算、FFN与残差：平台、资源与性能记录

## 当前修复身份与本模块已验收范围（2026-10-09）

当前正式生产包为 build tag `fe067c8aa0627ad770096f9721394645`，以[当前 manifest](../../../../build/model-attention-rtl-repair-20261008/manifest.json)、[项目状态](../../../../README.md)及[活动任务](../../../../mission/task.md)为入口。当前完整 CPU/真实 13 口 B2 CSim 证据与以下局部 RTL 证据分阶段记录；完整新核数值 RTL、同源完整物理资源、平台及板上性能尚未验收。

[D2-I v3 CPU](../../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_cpu_review.json)、[两切片标准 libm CSim](../../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_csim_review.json)及[生产生成路径结构审核](../../../../results/attention_rtl_repair_20261008/reviewer_d2_i_v3_synthesis_ir_review.json)已接受各自范围。与本模块对应的 I-V 保留真实生产 Controller 的 residual、ADD_TYPE 与 unary 分支，真实第二来源 bind/acquire/read、逐元素 F32 加法、物理写出及 owner cover/publish/完成路径；结构审核不替代数值 RTL。

I-V 实际生成 226 Verilog +226 VHDL 文件；局部 HLS 290.86 s、峰值 RSS 3894068 KiB、保护 exit0 无触发。60 BRAM18、65 DSP、41066 FF、131019 LUT、3 URAM 仅为该切片 HLS 估计；5.178 ns 对有效 4.867 ns 预算有约−0.31 ns slack，top latency 未知，不代表完整 vector/FFN 的物理映射或已达 150 MHz。

[D2-I-V mode3 最小完整合法窗口准备合同](../../../../results/attention_rtl_repair_20261008/reviewer_d2_i_vector_mode3_static_source_preparation_release.json)使用完整 B1/S64 请求的16个候选值、实际 produce_f32→Controller.vector→owner/publication 路径和14个静态页，目前仅放行源码准备；尚未进行对应数值 RTL。该 unary 用例以后通过，也不能关闭 residual/ADD_TYPE 的真实第二输入、完整64×1024处理和其他 FFN覆盖。执行优先级按活动任务，先取得真实全 K/N Scorer pilot。

[Attention cold V2](../../../../results/attention_rtl_repair_20261008/reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json)属于另一消费者切片已接受结果，不扩大本模块动态覆盖。下面的04934整核 OOC/缺陷与早期软件/候选预算均保留为历史，不能与 fe067 或局部生成结构拼接成完整新核硬件验收。

## 历史 04934 整核制品与缺陷（2026-10-08）

以下历史整核制品对应 build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 历史 04934 接口与性能核查（2026-10-08）

F32 GEGLU[5248]→[2624]、ReLU[4096]→[4096]、两份残差[1024]→[1024]；bias-GELU长度1024或256。

B1/S128有9,404,416个GEGLU输出、1,048,576个ReLU元素和7,864,320个residual加法；矩阵工作量归Q8，避免重复计。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-vector_and_ffn)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：真实GEGLU、ReLU、残差、type和bias/GELU接入28+2层与尾链，当前完整CPU/CSim逐位通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整vector任务](../../../../hls/operators/full_tasks_vector.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 75个场景覆盖五类叶函数；实际FFN/residual顺序由当前47点整图核对 | [独立数值fixtures](../../../../results/engineering_p2/full_cpu_final_20261007/numeric_fixture/full_fixture_report.json) |
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

本模块具体推导依据[12](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/12_vector_and_ffn.md)、[09](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md)、[08](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### FFN链与带宽

- M16：Wi dot20992cycles，配对/4lane gate输出10496cycles，down量化若从8lane存储读为10496cycles，down dot10496cycles，最终8lane读出2048cycles。共享Wi/down的dot相加，不能重叠。
- gate直送quant：捕获16×2624/4=10496cycles，重放16×2624/8=5248cycles；捕获与gate生成同一流时间，不重复累计。
- 省Wi写＋读：2×335872=671744bytes/tile；再省gate写＋读：2×167936=335872bytes/tile。实际burst/端口成本另计。
- residual8lane每拍读32B新值＋32B旧值＋写32B结果＝96B/clk，总端点需求14.4GB/s@150MHz；融合后新值走片上PS，外存路径需分别核算读旧/写新。
- Decision ReLU每16行4096feature/8lane＝8192cycles；type add每题S×1024/8cycles，需广播本题type，不能跨题复用错误向量。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

U/G可复用Linear PS，gate可落既有FF区；额外配对/非线性FIFO/转接buffer未定。不能再重复计Wi/down阵列资源。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_vector_and_ffn` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G3 tanh近似与函数顺序；G4U/G端口、4/8转接、尾延迟与F1权重驻留；G6质量线。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。


## P2 A批设计预算与待验阶段（2026-10-07，Astra xhigh）

依据[task.md §12](../../../../hardware_agent/task.md)和本模块design新增P2节。逐row接口：WI20992B、gate10496B、ReLU16384B；add每输入4096B/输出4096B。本批串行scalar/row实现，不承诺原4/8lane或双buffer重叠。每GEGLU行2624次GELU加2624次gate乘法，所有非线性/访存真实周期待报告。

实验工具沿用Vitis HLS 2025.2，isolated part `xcu55c-fsvh2892-2L-e`，150MHz为请求而非已达时钟。P2 CPU/CSim、isolated综合、RTL cosim此节写入时均未执行；布局布线/时序、xo/xclbin、XRT/板级亦未执行。实际platform/shell/XRT缺失不阻止板无关代码与实验part验证；资源、II、latency和误差须分阶段追加真实报告。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

WI/GATE/DEC_FF外部，逐row或tile暂存明确计入；串行单任务无4→8stream转换吞吐承诺。每次残差逻辑数据为两输入一输出12B/element，实际AXI宽度/读放大另报。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2 A批实际运行证据（2026-10-07）

| 阶段 | 实际结果 | 原始证据与范围 |
| --- | --- | --- |
| CPU直接TB | 本模块7例PASS，五模块合计30例 | [CTest日志](../../../../results/engineering_p2/20261007T025037Z-1839717/ctest.log) |
| 独立真实fixture | 五模块合计75场景，51个参考文件 | [fixture报告](../../../../results/engineering_p2/20261007T025037Z-1839717/fixture/full_fixture_report.json)；仅本报告所列场景，后续参考扩展/修正需重跑受影响检查 |
| Vitis 2025.2 isolated CSim | 本模块7例PASS，退出码0 | [csim_vector.log](../../../../results/engineering_p2/20261007T030653Z-1859617/csim_vector.log)、[源码身份](../../../../results/engineering_p2/20261007T030653Z-1859617/source_hashes.sha256)；leaf入口、实验part与150MHz请求 |
| 本模块RTL/综合 | 尚无本模块独立通过报告 | 其他模块的RoPE cosim/综合不替代本模块证据 |

完整任务联合链、完整top、布局布线、xo/xclbin及U55C测试另行验收。上述CPU/CSim及isolated RTL均不能证明完整网络功能或AXI性能。


## 综合内存修复现行实测（04934，2026-10-07）

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。`full_tasks_vector.cpp`的load_bias必填索引调用改为引用入口，使用原局部索引变量；向量/FFN算术叶子、shape和任务错误规则不变。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |

## T5 原tanh单实例与共享vector服务准备（2026-10-10）

| 项目 | 现状 | 证据与边界 |
| --- | --- | --- |
| 历史原tanh叶子源码闭包 | **PASS，限静态身份**。首轮静态elaboration发现原闭包脚本漏掉带Verilog attribute前缀的`sparsemux_9_3_64_1_1`；只修正解析并保留失败尝试，最终精确绑定18份Verilog、3份ROM、7份FP IP仿真VHDL/XCI/Tcl，第二轮静态编译PASS。该叶子的`ap_start`只在state1消费，活动`ap_ready`和`ap_done`只在state43，state43回state1；真正接受间隔至少3clk。 | [最终闭包清单](../rtl/tanh_service_01/source_manifest.json)、[首轮静态FAIL](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_static_01/guard/driver.log)、[第二轮静态PASS](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_static_02/guard/driver.log)。历史所选叶子不等于当前v4 kernel。四实例旧配置GEGLU服务硬下界7053312cycles，共享主体至少11604992cycles（77.366613ms@150MHz），已被联合预算排除。 |
| 实际Wi与逐步参考 | **PASS，限输入/参考准备**。当前v4/request3/generation1、B1/S128的Encoder0 Wi完成后只读捕获row0全部5248 F32；四请求、141检查点及故障恢复均PASS。独立参考生成2624个有序z、`libm.tanhf`、GELU和gate位型，z/gold `.mem`与二进制逐项一致且全部为已知32bit值。 | [捕获运行日志](../../../../results/compute_throughput_optimization_20261010/attempts/vector_wi_capture_run_01/guard/driver.log)、[参考manifest](../../../../results/compute_throughput_optimization_20261010/attempts/vector_wi_reference_01/reference/manifest.json)、[首错收据](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_real_01/receipt.json)。捕获与参考通过不代表RTL数值通过。 |
| 单实例真实RTL与有限资源模型 | **NUMERIC_FAIL，首错即停**。原叶子正常连续供数XSim在ordinal23（第24个）发现`z=bf6cd458`，RTL `bf3a7268`，独立`libm.tanhf` gold `bf3a726a`，差2 ULP；之前23个退休值相等。guard child exit1、5.888s、RSS859476KiB，无资源触发。TB按tag守序，只有活动`ap_ready`完成，使用四态`!==`逐位比较；本次首错两个值均为已知位。未继续压力配置或原叶子同数值流水化。 | [失败原始XSim日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_static_02/work/run_continuous/xsim.log)、[运行guard](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_real_01/guard/guard_result.json)、[冻结收据](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_service_real_01/receipt.json)。仅历史单叶子真实Wi row0前24项有实测比较；三分支间隔、完整2624项服务率、共享vector真实RTL与v4生产kernel均无PASS。 |

## 第1轮单实例glibc位级基线实测（2026-10-11，Sol 6.1/xhigh）

本轮身份/原始证据集中在[attempt](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/)。[源码manifest](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/source_manifest.json)、[RTL manifest](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/rtl_manifest.json)与[fixture manifest](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/fixture/manifest.json)绑定实际文件。原2624真实z/tanh逐项引用原冻结manifest，gold未改；640有限补例及6非有限错误输入单列。本版本是正确性基线，尚不能称高性能优化成功或生产整图数值阻塞已全部解除。

| 阶段 | 实际结果及范围 | 原始证据 |
| --- | --- | --- |
| CPU独立预检 | **PASS**：3270项全部逐位/status；另200000有限随机tanh和600000独立原生F32 add/mul/div比对，0差异。全有限支持域是算法声明，未穷举binary32。guard exit0，1.07s，RSS78952KiB。 | [CPU日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/guard_cpu_01/driver.log) |
| 功能HLS | **PASS，生成制品**：各一份add/mul/div实例，整数24×24mul估计2DSP；无厂商FP IP。leaf latency1..687、interval2..688，helper add17/mul13/div1..40cycles。HLS估计27334LUT/7418FF/2DSP，BRAM/URAM0，5.379ns、uncertainty1.8ns；非物理fit/Fmax证据。guard exit0，24.46s，RSS1127876KiB。 | [HLS报告](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/hls_project/solution1/syn/report/tanh_libm_leaf_csynth.rpt)、[guard](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/guard_hls_03/guard_result.json) |
| 静态RTL编译 | **PASS**，同生成整数RTL及单slot wrapper。guard exit0，18.98s，RSS301196KiB。首次SV literal/ternary词法错误原日志保留；只修空白，未改变断言/期望。 | [静态日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/guard_static_02/driver.log) |
| 128项RTL成本pilot | **PASS**，正常/反压各128项加两种reset恢复。153481cycles，8.42s，RSS860332KiB；预测完整≤4.5Mcycles/300s，未加帽。 | [pilot日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/rtl_pilot/xsim.log) |
| 正式RTL | **PASS**：正常/反压各3270项，包括原2624×2真实比较、640×2有限补例和6×2错误；另两次恢复成功返回、两项reset取消。四态逐位、tag、错误status、背压稳定、single-slot债务及无旧返回均通过。总3561257cycles，guard exit0、40.84s、RSS860368KiB，无资源保护触发。 | [完整XSim日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/rtl_run/xsim.log)、[guard](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/guard_rtl_01/guard_result.json) |
| Vivado模块OOC | **PASS，限综合制品**：Vivado2025.2/xcu55c-fsvh2892-2L-e，实际leaf＋wrapper为10054LUT/7090FF/2DSP、BRAM/URAM0，blackboxes0；各一份add2541LUT/1161FF、div2315/1031、mul1859/788/2DSP。综合请求6.666667ns舍入为6.667ns，内部setup WNS+2.918ns/TNS0。guard exit0，381.61s，RSS4564500KiB（4.353GiB），MemAvailable最低398239816KiB；RSS/墙时trigger无。不是完整top/P&R或最终物理Fmax。 | [OOC身份](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/ooc_manifest.json)、[实际资源](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/ooc/utilization.rpt)、[层级](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/ooc/utilization_hierarchical.rpt)、[时序](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/ooc/timing_summary.rpt)、[DCP](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/ooc/tanh_libm_wrapper_synth.dcp)、[guard终态](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/guard_ooc_01/guard_result.json) |

周期口径为本地输入accept至输出实际消费；每profile的3270项完整span包含首项填充及末项退休。正常`first_accept=606,last_retire=1775164,span=1774558`；反压`1775166→3557988,span=1782822`，新增8264cycles（0.466%）。正常接受间隔min4/max690、反压min4/max702；min4来自快速边界/错误分支，不能当普通真实tanh的持续II。真实2624项中2178项`|z|<1`、446项`1<=|z|<22`、饱和0项；两profile的accept→首次out_valid算术延迟相同，分别462..672（sum1246495）和671..689（sum299320）cycles。压力只改变消费/下一项准入，wrapper最多一债务。

150MHz条件换算下，3270项span正常11.8304ms、反压11.8855ms；这是模块混合测试范围，不是完整请求或纯2624行实测。旧leaf尚无同gold正确完成的相同范围基线，不能算端到端提速比；本轮未达到II1，也未证明整网高性能。无完整GEGLU基本运算/供数、Wi→GEGLU→Down producer、完整Encoder/整网RTL、P&R或板端证据。本leaf没有物理AXI，reset/债务只证明本地服务协议，不代表HBM排空。

所有实际工具经单重工具锁，CPU0–3/nice19/idle I/O、MemAvailable>192GiB、0.2s owned RSS采样；CPU/HLS/RTL分别沿原16/24/8GiB及墙时帽。启动选项与HLS相对源路径错误保留于guard_hls_01/02，按具体原因修正后guard_hls_03生成成功；没有修改gold或放宽数值判据。

**COMPLIANCE_GAP（语义停滞停止规则）**：本次OOC的Cross Boundary/Area Optimization阶段从约00:56:06至00:58:16 UTC没有可见新语义日志，约130s；间隔观察再次读取时阶段已经推进，未在120s阈值及时停下。原日志和0.2s RSS证据保留，不能将本轮称完全满足语义停滞保护。主控获报后允许完成已经继续产生真实进展的本次运行，后续仍按120s停止及原RSS/墙时帽；没有重跑或丢弃已通过数值范围，也没有提高任何额度。

OOC时序只在综合网表内部时钟约束下估计：67个输入/67个输出未设外部delay，`HD.CLK_SRC`未给定，clock skew无法估计，hold为NA。未做P&R/物理时序，不把WNS+2.918ns换算成实达Fmax。`check_timing`的no_clock/unconstrained_internal_endpoints/loops皆0。

Vivado原始WARNING共6行：unused `seen_result/seen_status`各1（仅TB观测标志，综合删除不改变数据服务）、时钟周期舍入2、空blackbox查询1、未指定HD.CLK_SRC 1；无ERROR/CRITICAL WARNING。工具synth总结的“0 warnings”不包含全部日志行，故本节保留实际警告。正常与压力RTL证明本轮有限输入/服务范围；综合DCP未另做门级仿真。

本轮最终机器收据见[receipt.json](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/receipt.json)，最终实际源/输入/配置/制品身份见[evidence_manifest.json](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_01/evidence_manifest.json)。旧准备manifest保留原记录；正式OOC使用在综合前读入XDC的冻结Tcl版本，以OOC和最终manifest所列实际文件为准。取得以上实际结果后交Astra集中评判，本实现负责人不启动下一轮。

## 第1轮后置发现的RNE零符号错误与同轮修复（round1_02）

**01身份的新增边界为FAIL_RNE_EDGE**：综合之后Astra发现`bf800000+3f800000`精确抵消错误返回−0，RNE应为+0；上述原始数值/综合通过仅保留其已测范围，旧工件和receipt不改。此处连续完成同轮普通修复，不是第2轮优化。现源仅修正异号非零等幅抵消的返回零符号。

| 新身份受影响回归 | 结果 |
| --- | --- |
| CPU定向及完整预检 | **PASS**：52例±0/等幅两顺序/相邻非零独立原生binary32 RNE，3270原冻结tanh/status、另200000有限tanh和600000基本算术。gold未改，fixture目录引用01原冻结文件。[CPU日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/guard_cpu_02/driver.log)。 |
| 自动停止保护自检 | **PASS**：短owned静默子进程在测试阈值1s触发semantic_stall、总1.236s被终止；生产阈值120s不变。[自检](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/guard_stop_selfcheck/selfcheck_result.json)。01的COMPLIANCE_GAP保留；新guard只由实际工具语义行更新计时，60s记录不构成进度。 |
| 新HLS及静态 | **PASS**：HLS23.77s/RSS1127744KiB，静态15.63s/RSS318256KiB。新leaf max793/interval794，add helper1..22cycles；HLS估计27415LUT/7349FF/2DSP，BRAM/URAM0。新增正确分支改变调度并使服务变慢，未做额外性能优化。[HLS报告](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/hls_project/solution1/syn/report/tanh_libm_leaf_csynth.rpt)。 |
| 受影响RTL | **PASS**：真实生成的add子模块52例定向逐位；3270×2正常/反压tanh及两reset恢复全部通过。total4037232cycles，guard40.51s/RSS859948KiB，无实际回归保护触发。真实2178项小分支first-valid517..770（sum1417206）、446项大分支772..795（sum344381）cycles；旧01更快但存在RNE边界错误，不作为有效优化A/B基线。[完整日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/rtl_run/xsim.log)、[RTL身份](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/rtl_manifest.json)。 |
| 新身份Vivado OOC | **PASS，限综合制品**：实际10410LUT/7132FF/2DSP、BRAM/URAM0、blackboxes0；add2720LUT/1203FF、div2184/1032、mul2067/788/2DSP均单实例。6.667ns内部setup WNS+2.486ns/TNS0。guard exit0、228.66s、RSS4335924KiB（4.135GiB）、MemAvailable最低432061292KiB、无自动语义/RSS/墙时trigger。原DCP不代签修正helper；本次RuntimeOptimized/resource_sharing off配置明确与01不同。[新OOC配置/身份](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/ooc_manifest.json)、[层级实际资源](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/ooc/utilization_hierarchical.rpt)、[时序](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/ooc/timing_summary.rpt)、[新DCP](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/ooc/tanh_libm_wrapper_synth.dcp)、[guard终态](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/guard_ooc_01/guard_result.json)。 |

新RTL的3270混合范围完整accept→末消费span：正常`1538→2012794=2011256cycles`，反压`2012796→4033669=2020873cycles`；正常接受间隔min4/max796、压力min4/max805。150MHz条件值分别13.4084ms/13.4725ms，含首项填充和末返回退休，不代表整网请求或纯2624行。新增零符号正确分支使HLS调度变慢，未宣称性能优化；min4仍来自快速边界/错误，不是普通tanh持续II。

新OOC时序仍限综合网表内部setup估计：67输入/67输出无delay、HD.CLK_SRC未指定、hold NA、无P&R或实达Fmax。实际WARNING6行（unused观测标志2、周期舍入2、空blackbox查询1、HD.CLK_SRC1），ERROR/CRITICAL WARNING0。RuntimeOptimized与旧01配置不同，资源差异不能单独归因于零符号修复，不作公平优化A/B。旧01的COMPLIANCE_GAP及其原始日志保留；02工具真实语义进展由自动120s保护监测，[60s记录](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/guard_ooc_01/semantic_timeline.jsonl)不充当heartbeat。

当前修正身份及最终证据见[round1_02 receipt](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/receipt.json)和[最终manifest](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/evidence_manifest.json)。已取得新真实综合终态，交同Astra集中复核；完整GEGLU/producer/Encoder/整网、门级仿真、P&R、上板仍未测。本实现负责人不开始第2轮优化。


## 第2轮：同配置有界add优化实际完成（2026-10-11）

attempt为`results/compute_throughput_optimization_20261010/attempts/tanh_libm_round2_01`；receipt SHA256 `6e2c6792c9ca7ac0f95e1a844d0f256bd9f96dc83b414d08c6bfeb8850954312`，evidence manifest SHA256 `4b996bd8ccc7411402fed8a0cf3e07275eda6701874935aecafe33cd94f9b512`；源码SHA256 `c470b4c566ec714388ef84c4b68057c1802be650973b876390dbb6deb066350a`。

CPU保留原52定向用例，扩为345独立native RNE add边界；全部3270fixture、200000随机有限tanh和600000随机basic-op比较PASS。实际HLS add子模块345用例逐位PASS（前52gold字节前缀与round1_02完全一致）；3270×2输出比较、两种reset/recovery和压力稳定性PASS。普通profile span1249315cycle（对照2011256，减少37.8838%），压力span1256248；min/max accept gap4/474及4/477。真实2624子集abs(z)<1的2178项首次valid latency348..466、sum883954；1<=abs(z)<22的446项466..473、sum207857；真实饱和分支0项。span@150MHz分别8.32877/8.37499ms，是模块混合负载，未实测整网请求时延。

HLS leaf latency1..478/interval2..479，add1..6、mul13、div1..40；估计21909LUT/6513FF/2DSP仅HLS估算。实际OOC top`tanh_libm_wrapper`、U55C、同`out_of_context/flatten_hierarchy none/RuntimeOptimized/resource_sharing off`、6.667ns：9073LUT/6510FF/2DSP、BRAM0/URAM0、blackboxes0，setup WNS+2.486ns/TNS0。仍是未布局布线的综合估计，未约束外部输入/输出delay、未取得实际Fmax。guard全部exit0且无触发；OOC179.395s、peak ownedRSS4343764KiB，最低MemAvailable418773580KiB。第1轮01保护缺口及原数值失败记录保留。

完整GEGLU生产源码连接已写入；`geglu_libm_producer_01`完整5248输入、2624生产CPU输出和26240独立step gold比较PASS，HLS/RTL/OOC仍在执行。本轮完成不替代新生产身份完整CPU/CSim和后续producer证据。Astra只在实际综合后集中评判，用户不参与每轮审核。


## 完整真实GEGLU正确producer的CPU、RTL及实际OOC（2026-10-11）

`geglu_libm_producer_01/receipt.json` SHA256 `7152332cb9f42ae9e51f973617f345fd628ba89422aba4627820a1f62bc68f90`。使用冻结v4/request3/generation1/enc0/Wi row0完整5248F32作为片段外部检查点，DUT自己产生九步GELU及最后gate，不以z或tanh gold供数。完整生产`geglu_row` CPU2624输出及26240独立十步骤PASS；真实HLS/RTL普通和压力profile共5248输出及52480步骤PASS，另有23项在reset前成功返回。完整input capture、partial-load/inflight/pending-return reset、旧epoch无返回、坏index status2及nonfinite status1终止行/恢复PASS。

normal从第一Wi接受到最后gate消费span1440799cycle（9.60533ms@150MHz），pressure1444455（9.62970ms）；包含完整5248装载。per-column leaf启动→输出消费普通475..600、sum1425057cycle，压力475..610、sum1428713；这是消费延迟，压力包含下游等待。HLS leaf1..606cycle/interval2..607、single add/mul/div实例；原独立gold均未变。

实际OOC `geglu_row_wrapper` 同U55C/6.667ns/RuntimeOptimized/resource_sharing off：9347LUT/6689FF/2DSP/8RAMB36（4各U/G plane）/RAMB18和URAM0，blackboxes0，setup WNS+2.486ns/TNS0。OOC197.246s，owned peakRSS4354560KiB、最低MemAvailable414921688KiB，所有guard无触发。时序仍只为综合估计，无接口delay/布局布线/实际Fmax；debug十步骤写口也计入本模块实际资源。

这是一整行真实算术与本地装载/返回协议的checkpoint replay，未宣称包含真实Wi Q8 producer、quant/Down接续或连续整图RTL。生产当前路径已实际使用同一bits图，7份依赖已冻结并交生产owner生成新build身份和完整持久四请求CPU/CSim；旧v4 CPU成绩不代签新实现。Astra在取得这份实际OOC后集中评判，下一单流空间流水候选不改动此正确生产基线。


空间流水首次单体HLS调度成本记录：`tanh_libm_stream_01`独立CPU345add边界/3270fixture/200000随机有限tanh/600000basic-op全部PASS，但全部内联图在pipeline scheduling连续120s无工具语义进展，被原guard自动`semantic_stall`终止（child−9，287.677s、peak ownedRSS5074020KiB）。未生成RTL/OOC，未宣称II1。原源与保护记录冻结不变。普通实现成本修复`stream_02`按相同24A/17M/2D图位置保留独立II1子模块，不增流数/credit/数值运算或服务器帽；下一次运行仍先独立CPU再HLS，等待其它owner共享工具窗口。


## canonical新父图与GEGLU完整行的当前实际证据（2026-10-11）

旧专用子核bottom-up路线已因实际成本停止；[收据](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_stream_bottomup_01/receipt.json)SHA256 `79d87dbc2972f52fc75243b64619cb3e0923aa346f3cdfc69eb7a3754855f221`。mul14pilot120.3434818s墙时停止，synth完成且blackboxes0、1901LUT/918FF/2DSP，但没有DCP/最终时序；add0pilot100.6299173s实际PASS、1436LUT/595FF/0DSP、blackboxes0、setup WNS+3.284ns，DCP SHA256 `94da0b741f7476e1935079b1f027581a82f09ac9ec0565afc65cdc23e3ebe719`可按完全相同源码/配置复用。累计OOC220.97339908406138s，完整42父图资源/时序/网表此旧路线NOT_RUN。旧stream02数值PASS及L375只保留旧身份。

新`tanh_libm_canonical_01` CPU实际**PASS**：[guard](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/guard_cpu_01/guard_result.json)exit0、0.783028s、peakRSS88088KiB，3270原独立gold、137340原生F32节点结果及1159helper全部通过。[CPU日志](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/guard_cpu_01/driver.log)。新父图首次static_01实际**FAIL**，3.681676s、peakRSS144488KiB：add16/17/18的operand寄存名与自动FP端口wire重名。普通实现修复改为operand_a/b，节点/数值/静态边沿/断言不变；前身份与manifest在`source_versions/pre_static_fix_01`完整保留，active源身份为source_manifest_v02，受影响static/RTL排队重跑，CPU独立源未变复用。此处不把排队或已生成RTL标为实际PASS。

GEGLU core生成器failed_step嵌套表达式在工具运行前发现缺一右括号，已按等价自内向外条件链生成并冻结source_manifest_v03，原身份归档保留；截至本节写入尚无GEGLU新身份CPU/static/RTL/OOC结果。G的本地row TB承诺两种完整1row加一次4row共6row31488Wi/15744gate/157440十步骤，441原scalar参考角例，协议拒绝/晚G晚U/G先于U/reset/credit覆盖；其中writer ack只为诊断。真实physical GATE/owner/quant/full dual A/Down联合结果由production owner另行留证。

新L384全工作量条件算术费用为`(9421056+3601*384)/150000=72.025600ms`；原71.809540ms属于旧L375。此值不是整模型实测，还需要外部GEGLU7M/2A、供数/写入/发布、LN7824row、Attention480head和实际Q8服务。OOC、门级网表、P&R/实达Fmax、板端及整网此新身份仍NOT_RUN。


### 新canonical父图实际功能完成

上述普通修复之后，static_04实际PASS38.343297s/RSS410060KiB；helper1159RTL PASS5.600665s/RSS860036KiB；128pilot PASS6.038811s/RSS860056KiB；完整3270×2＋640混排/信用/复位RTL PASS22.192897s/RSS859916KiB，总18255cycle。所有新运行guard exit0且trigger=null、MemAvailable高于192GiB。静态02的alignment register先用后声明、静态03的SV保留字edge及task输入类型错误保留对应日志，原断言/gold含义未变。active functional source_manifest_v04及functional_evidence_manifest绑定实际源、原gold、137340native node参考、测试台与日志。

实际3270profile：[{"mode": 0, "count": 3270, "first_accept": 6598, "first_valid": 6983, "last_retire": 10252, "span": 3654, "min_gap": 1, "max_gap": 1, "core_fixed_latency": 384, "peak_credit": 385, "credit_stops": 0}, {"mode": 1, "count": 3270, "first_accept": 10254, "first_valid": 10639, "last_retire": 16718, "span": 6464, "min_gap": 1, "max_gap": 16, "core_fixed_latency": 384, "peak_credit": 512, "credit_stops": 2245}]。全部42节点operand/result逐位核、Dexp/Dtanh守恒、E384commit通过；正常连续准入min/max gap1，压力max16来自credit回压，固定算术延迟384未变。640混排实际peak512/stops385，reset在途/待返回及输出稳定通过。

当前[receipt](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/receipt.json)状态`RTL_COMPLETE_OOC_PENDING`；实际资源/blackboxes/assembly/netlist/timing仍NOT_RUN，待同一原累计OOC预算完成后补记。


### 新GEGLU核心与完整行适配器实际功能完成

`geglu_canonical_row_01`新身份CPU/static/441角例/完整5248短pilot/6整行正式RTL实际全部**PASS**。CPU0.882132s/RSS70392KiB，实际2624gate和26240原独立步骤比较＋441原冻结scalar角例；static84.541494s/RSS540988KiB；角例RTL5.817279s/RSS860128KiB，2952适用步骤和4410谓词核对、固定506cycle提交；pilot7.380607s/RSS860024KiB，完整Wi5248后真实128返回。正式RTL91.538077s/RSS860096KiB，总134755cycle，6rows31488Wi/15744gate/157440独立十步骤比较全部通过。各guard exit0且trigger=null，最低MemAvailable仍高于192GiB。

profile实测：[{"mode": 0, "rows": 1, "inputs": 5248, "outputs": 2624, "step_checks": 26240, "first_issue": 62515, "last_commit": 65644, "first_output": 65645, "last_output": 68268, "peak_credit": 506}, {"mode": 1, "rows": 1, "inputs": 5248, "outputs": 2624, "step_checks": 26240, "first_issue": 73550, "last_commit": 76679, "first_output": 76680, "last_output": 81563, "peak_credit": 506}, {"mode": 1, "rows": 4, "inputs": 20992, "outputs": 10496, "step_checks": 104960, "first_issue": 86845, "last_commit": 129842, "first_output": 89975, "last_output": 134736, "peak_credit": 506}]。包括普通1row、压力1row和压力4row同命令；最大实际在途506（预约帽512），晚G/晚U及同colG先于U、错全identity/oldref/index、源读债务、partial-load/inflight/pending reset、完整行屏障与输出稳定全部通过。

[收据](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/receipt.json)状态`LOCAL_COMPLETE_ROW_RTL_PASS_PRODUCTION_BRIDGE_PENDING`，active源source_manifest_v05及functional_evidence_manifest绑定原Wi/gold及实际源/TB/logs。row_write_ack仍诊断，不能用这些结果宣称真实GATE物理写/末B/owner发布、generic feeder/quant/full dual A/Down通过；这些由production owner实际端点另证。新GEGLU/OOC资源、P&R/Fmax/板端及整网仍NOT_RUN。


### 三类canonical helper实际DCP完成

精确mul14/div0的child-only OOC实际**PASS**：guard187.008534s、owned peakRSS4381896KiB、minimumMemAvailable427480288KiB，exit0/trigger=null。mul14实际1901LUT/918FF/2DSP；div0实际3170LUT/1032FF/0DSP；两者RAMB36/18/URAM均0、blackboxes0，真实DCP先于resource报告保存。原add0同身份DCP只读复用1436LUT/595FF/0DSP。新child不反复运行timing，其实际性能尚不以旧叶子估计冒签；最后只运行完整assembly时序一次。

原路线220.973399s＋当前child187.008534s=累计407.981933s，余3192.018067s。42cell完整父图按已证明的exactDCP→结构EDIFlink流程排队，link模式out_of_context并显式拒绝IO pads；没有重置累计帽，不再重复已失败的read_checkpoint-cell项目reopen路径。此时完整父资源/blackboxes/时序/netlist仍待真实终态。


### 新canonical全42cell实际OOC闭合

exactDCP导出结构EDIF、basename与top匹配、nonproject link_design -mode out_of_context实际**PASS**，不用失败的read_checkpoint-cell reopen路线。原42个具体FP cell逐一REF_NAME核对、blackboxes0、IO pads0，完整DCP/funcsim netlist/资源/层级/时序/check_timing实际保存。实际wrapper＋core为**79319LUT/34230FF/34DSP、RAMB36/18/URAM0**。setup WNS+0.538ns/TNS0、period6.667ns，仅综合内部估计；67input/98output无delay、HD.CLK_SRC未设、hold NA、no_clock/internal_unconstrained/loops0，不称P&R或实达Fmax。

assembly guard306.298543s、peakownedRSS19034308KiB（18.15GiB）、minimumMemAvailable423715452KiB、exit0/trigger=null。原220.973399＋新children187.008534＋assembly306.298543=原累计714.280475s，余2885.719525s；未加帽。完整新父身份由receipt_ooc_01.json保留，当前receipt.json同步实际PASS。随后从成功assembled DCP导出同接口canonical_core子树用于G父层只读结构复用，导出实际时间仍计原tanh累计；G独立父层资源必须实际51FP＋row存储/控制，不能用此tanh数值代签G。


### canonical exact core导出实际完成与可选检查终态

[core_export_receipt.json](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/core_export_receipt.json)实际**PASS**：重新打开从成功assembled DCP导出的`core`子树，100个端口精确核对、42实际FP模块、blackboxes0；63.608440s、peakownedRSS3524696KiB，guard exit0/trigger=null。导出DCP SHA256 `5d96ac5cc2ad64a7174f9c031dbb28244ba22f9384ecbd05b8cf949a4bcfa305`，EDIF SHA256 `b8c1f534c2f7782982d65acc98fb2a0815b4ea844742b742b86edaabb9f074a6`。这是同硬件结构复用，不是新算术实现或独立功能测试。原累计220.973399＋children187.008534＋assembly306.298543＋export63.608440=**777.888915s**，余**2822.111085s**。

[netlist_status.json](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/netlist_status.json)为**NOT_RUN**：可选netlist128只排队、无guard launch/工具子进程，安全停止owned flock waiter后session exit143，实际工具0s。root要求优先物理生产桥与PS bank/sequence/LN实质合同，未发起该可选检查；RTL原PASS和综合网表保存事实保持原覆盖范围。

不可变首份OOC收据`receipt_ooc_01.json` SHA256 `bfe2ddbaca1290ee454bc04b171237d78627c908e2bf2835e12caa9f7ec02c23`保留；[最终evidence_manifest.json](../../../../results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/evidence_manifest.json)绑定当前receipt、原功能与OOC身份、实际制品/日志、exact core导出及NOT_RUN说明。核查发现原功能manifest广泛记录的两个尚未执行OOC脚本及可选网表TB随后准备修正；原manifest保持原历史SHA，新manifest逐项列出旧/现记录与适用范围，实际OOC源码由v03清单绑定，已执行功能DUT/TB/gold未变。其余引用逐文件SHA/bytes核对一致。没有运行P&R、板端或整网。


### GEGLU完整51FP＋行存储控制实际OOC完成

[不可变首份OOC收据](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/receipt_ooc_01.json)实际**PASS**：父层先实综10个stubs（canonical core＋7mul＋2add），再只读结构复用成功同身份核心/三helper。最终51FP具体cell逐一REF_NAME核对，25A/24M/2D、blackboxes0、IO pads0。完整资源**176828LUT/299253FF/48DSP**、RAMB36/18/URAM0、distributed RAM0、SRL9416；row storage/metadata/control层81074LUT/256419FF，arithmetic95754LUT/42834FF/48DSP。U/G/gate逻辑31488B目前实际是寄存器展开，不是已推断BRAM，完整资源不能用tanh79319/34230/34代替。

最后一次setup报告为**WNS+0.538ns/TNS0、period6.667ns**，no_clock/internal_unconstrained/loops0；2416输入及1538输出无external delay，HD.CLK_SRC未设、hold NA。此结果只为综合内部估计，没有P&R/实达Fmax或板端。DCP、funcsim、层级/utilization、timing、clock network、check_timing均已实际保存；funcsim保存不代表门级仿真通过，G netlist simulation NOT_RUN。

独立G guard923.575406s、peakownedRSS23007172KiB（21.94GiB）、minimumMemAvailable410590204KiB、exit0/trigger=null；独立原累计3600s剩**2676.424594s**，canonical仍累计777.888915s，未移动费用/加帽。实际WARNING37行：v_status成功标量端口32bit常零32、时钟period舍入3、大量primitive父层floorplanning提示1、HD.CLK_SRC1；ERROR/CRITICAL WARNING0。scalar v只在完整行成功后发布，错误仍从done/row状态返回，因此常零是当前协议实际行为。

正常profile首issue62515→last_commit65644相差3129cycle，first_output65645→last_output68268相差2623cycle，issue→末输出5753cycle；还需每行5248个scalar Wi传输、源读债务屏障及真实write/B/owner发布费用。六整行/441角例功能证据与实际OOC源一致，没有重跑未变功能用例。物理GATE writer/ledger/generic feeder/quant/full dual A/Down仍由production owner另留实际证据，本地diagnostic ack不代签。

[当前receipt](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/receipt.json)状态`LOCAL_ROW_RTL_AND_51_FP_OOC_PASS_PRODUCTION_BRIDGE_PENDING`；原`receipt_functional.json` SHA256 `4a10ab40d1c1c5a6ace7d807ed445b60fc7df4111e839f152fbd78b7cecfbfda`保持不变。[最终evidence_manifest.json](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/evidence_manifest.json)绑定既有原gold/功能运行、actual OOC源码、只读成功DCP/EDIF依赖、全部制品/guard/logs，并逐文件SHA/bytes核查。G存储与PS bank资源/sequence/LN合同由Astra随后集中定义；本实现owner在终态后释放槽，不开始额外tanh/存储候选。


### 三bank新父封装受影响RTL实际完成（§8.4.10）

[新功能receipt](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/receipt_functional.json)实际**PASS**，原G51寄存展开/OOC记录保持不变。static 47.334262s/RSS544640KiB；三bank独立全地址RTL 5.576071s/RSS860252KiB；完整5248 pilot 7.591690s；六整row正式 98.359854s/RSS846596KiB。所有guard exit0/trigger=null。三bank各2624全地址、23616独立read比较、15744写、7872非同址并发检查、停读q保持/同步边沿通过，payload/q无reset。

新正式实际6row31488Wi/15744gate/157440独立十步骤，总134759cycle；原identity/refs/源完成读债务、G-before-U/晚错、全行屏障、有序返回/稳定输出、loading/inflight/pending reset全部通过。新增真实P/C边沿核、operand_reads52740/gate_reads15745、11 PREP/7 complete（包括原pending-reset完整算术行）、17cycle局部准入暂停slot保持及generation-reset断言通过。固定core506/tanh384385源逐字节未变，原441角例/51FP数值身份明确复用，没有拿bank pattern代签GEGLU。

新profiles：`[{"mode":0,"rows":1,"inputs":5248,"outputs":2624,"step_checks":26240,"first_issue":62533,"last_commit":65662,"first_output":65663,"last_output":68286,"peak_credit":506},{"mode":1,"rows":1,"inputs":5248,"outputs":2624,"step_checks":26240,"first_issue":73568,"last_commit":76697,"first_output":76701,"last_output":81581,"peak_credit":506},{"mode":1,"rows":4,"inputs":20992,"outputs":10496,"step_checks":104960,"first_issue":86863,"last_commit":129859,"first_output":89993,"last_output":134740,"peak_credit":506}]`。这些仍为本地diagnostic writer ack；实际physical GATE/owner/quant/fullA/Down由production owner受影响桥回归另证。新bank/parent OOC当前排队，沿G原923.575406s＋余2676.424594s同一累计，不预测BRAM/fit或实达Fmax，不跑额外可选netlist。


### 三bank exact算术导出与新父成本停止终态封存

[exact core export receipt](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/core_export_receipt.json)实际PASS：164port、51个精确FP边界、blackboxes0、95754LUT/42834FF/48DSP及RAMB36/18/URAM0。原成功完整G assembled DCP SHA256 `44078634f32649436067784c3d319f16aa4489345a0664a7991c3cb54cf30620`仅导出arithmetic；新DCP SHA256 `23ed542ce9c26641e9cffbb1e4b4724c19da0de7c1c5805e0ac180d0252f6207`，EDIF SHA256 `4a46b022257eb3eb1d216a63c064ce5124b3afb3a9d7a012d550f88cf8156251`。前两次export实际FAIL分别95.102533s和36.908261s：重开后REF_NAME/ORIG_REF_NAME均有Vivado`_HDI_N`序列，第三次只规范该序列并强制原hash/51路径/helper/164port后PASS42.001896s。两次失败和actual/base映射全部保存，没有用任意等价模块替代。

新父[guard结果](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/guard_ooc_bank_parent_01/guard_result.json)实际`COST_STOP_SEMANTIC_STALL`：164.18788590840995s、exit -9、peakownedRSS3793524KiB、minimumMemAvailable404980300KiB；最后语义进展`Start Cross Boundary and Area Optimization`后120.090394s被原guard停止。RTL component statistics中的3个2624×32 RAM只说明展开意图，不证明BRAM类型/数量/碎片或最终资源。当前没有新parent最终DCP、assembly、mapped primitive/resource/timing；`.Xil`仅临时工具文件。功能PASS、exact arithmetic导出PASS与新父physical未闭合分别记账。

| 原G同一OOC账目 | 实际终态 | 秒 |
| --- | --- | ---: |
| 原完整51FP＋寄存展开父图 | PASS | 923.5754060968757 |
| export 01 | 名称检查FAIL | 95.10253257676959 |
| export 02 | 名称检查FAIL | 36.908260790631175 |
| export 03 | exact subtree PASS | 42.00189580395818 |
| 新bank/parent 01 | COST_STOP_SEMANTIC_STALL | 164.18788590840995 |

[新累计预算记录](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/ooc_budget_cumulative_row_bank_v1.json)绑定5份实际guard，累计**1261.7759811766446s**、原3600s帽剩**2338.2240188233554s**，失败/停止成本未清零或移名。canonical仍保持777.8889153879136s，可选netlist128仍NOT_RUN，无重启。

[不可变终态receipt](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json)及[最终证据清单](../../../../results/compute_throughput_optimization_20261010/attempts/geglu_canonical_row_01/row_bank_v1/evidence_manifest.json)区分三bank/六整行PASS、exact算术export PASS、新parent成本停止和production桥待证。原新功能receipt SHA256 `33d1b85a20d06334ab14f30ab63626fd4d698348afab421beea7b5e5ab07a2a5`及v02 SHA256 `bc1c91f3b035dc78e1635a566f46aff4ce872bba3d6207b5403f1e857cdf53ca`保持不变；v02广泛记录的3个准备OOC脚本在后续更替，旧内容按hash归档，实际功能RTL/TB/build/gold逐文件匹配，v05和OOC清单另绑定实际执行脚本。没有新增RTL修复、OOC重跑、可选诊断或LN工作；生产物理writer/owner/quant/fullA/Down及真实matrix_run C/JSON/原13BO AXI绑定由生产合同与实际生产证据验收，不能从本地writer诊断ACK推完工。
### FFR1 状态与真实进展计量（2026-10-14）

AT054 四行局部RTL限定PASS：原AT050 skip/Down与gold、原FADD叶子及结果槽SHA不变；正常4096项、各源256AR/R及目标256AW/W/B、三个64KiB终扫沿原数值全通过。新E_NUMERICAL6两例与E_INTERNAL8的首skip R、首Down R、首B非OK三例通过；B失败确实退休1 AW/W/B且没有成功发布。正常cfg受理cycle61、末B103340、发布/首次响应103341、消费103349；含边沿区间103289cycle，11项互斥状态和严格相同。4096项叶子接受→返回均22cycle，结果实际消费4096次。AT054 static/error/pilot/full为21.888815/25.840606/25.981984/26.254724s，full峰1383240KiB；104条实际策略样本合规、guard未触发。四组host逻辑时间检验重复/倒退/周期文本不续命，但host本身太短未捕获RSS/policy样本。16项冻结/外部身份逐bytes/SHA一致，full前按本次pilot成本准入唯一full；新HLS/OOC/P&R/物理时序均未运行。原AT053错误语义与guard缺口不回写，当前适用范围见[FFR1报告](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md)。

### FFR0 四行末残差局部 RTL（2026-10-14）

AT053 同 runtime 两外部源真实读、单个生成 FADD 叶子、另一 HIDDEN bank 真实写的四行有限样本 PASS：4096 F32 对 AT050 独立 enc0 末输出逐 bit 一致；两源各 256 AR/R，目标 256 AW/W/B；三个 64KiB 窗口共 196608B 终检通过。末 W/B 为 cycle103325/103340，成功响应首次有效103341、实际消费103349；正常检查打印点103350。AT052 同 SHA 加法槽 52 例 RNE 定向样本、保持与唯一消费 PASS。AT053 static/pilot/full 各 22.174020/26.307417/26.989242s，full 峰 owned RSS1376640KiB；guard 无触发，四个实际验证阶段合计95条 CPU0–3/nice19/idle 样本。只涵盖局部 AXI 仿真，不表示 AT049 长链已接末残差，也不表示生产双源 lease、完整 BO 保护、资源或物理时序闭合。[报告与原证据](../../../../../../E005_full_request_performance/experiment_results/runs/R001/reports/FFR0_four_row_residual_rtl_20261014.md)。

### M004向量单lane与残差搬运局部结果（2026-10-14）

AT092/098探针：旧FSM FADD对固定零值真实`ap_ready`相隔3cycle，不推广到所有数据；现存Attention CE ADD连续52个独立directed F32加法逐bitPASS，原始CE停3拍保持并按有效时钟恢复，复位后定向值通过。AT093新32项总credit单lane在AT050真实4096对skip/Down/gold上，normal连续每拍接受、4103cycle完成；输入空拍＋输出反压6444cycle、2340cycle输出被阻塞、峰在途32。局部16项在途reset取消且后续32项无旧返回；两个完整profile各4096 accept/return/consume守恒。

AT097旧薄AXI服务normal 6928cycle、反压7185cycle及2AR/1AW/1B属于跨4KiB的非合规单burst TB局部数值证据，不迁移为当前服务性能。AT100首个修正版TB标识编译错误保留。AT101受影响修正真实短测10条无reset顺序命令PASS：4096项对齐正常/反压6955/7206cycle，8AR/512R/4AW/256W/4B、49152B；三种不同页内偏移各16AR/8AW/8B，70beat短尾与混合偏移4AW/4B。独立4KiB/地址/长度及LAST/B checker、逐bitgold、64KiB目标窗口保护、W跨拍保持均通过；输入非有限索引7及先溢出索引2/后输入非法索引5保持首错，首RRESP/BRESP错E_INTERNAL8且排空、无成功。旧AT094–099原证据不回写。

AT099一次单lane wrapper＋同SHA CE ADD的U55C out-of-context综合PASS：1283LUT/614FF、DSP/BRAM/URAM0、blackbox0，综合内部WNS+3.057ns@6.667ns；67个输入/34个输出无external delay、CLK_SRC未设，不能当布线Fmax。静态/RTL/OOC受守卫累计44.381434/34.727431/78.220358s、trigger均null。完整报告和逐身份机读证据见[SM004结果](../../../../../../E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md)。完整硬件模型、LN/Attention/矩阵/tail连接与实际全图速度仍未完成。
### FFN0 四行联合链有界停止（2026-10-14）

AT057 static、定向短适配器、真实 LN 读前缀分别 PASS；原 full 唯一尝试为 COST_STOP_INVALID_SEMANTIC_PROGRESS_OBSERVER（child−9、semantic_stall、785.690s、峰 owned RSS1036212KiB）。full 中 LNQ0_LN_SOURCE_PASS 到达，Wi W q0/q1/scale R 在最后观测 cycle204365 为26624/26622/5248，冻结守卫所见 FFN0_PROGRESS work=840 未计这段真实读取。没有整链 marker、Down TMP 写、末残差真实读写或最终保护扫描；不从 AT049 与 AT054 两份局部通过拼出联合通过。AT057 冻结311引用/310路径逐 bytes/SHA一致，四段工具64条实际 policy 样本符合原 CPU0–3/nice19/idle 约束。原准入3536.346s是规划估计，不是完整链周期或性能实测。证据见 [R001停止报告](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/reports/FFN0_bounded_guard_stop_20261014.md)和[原收据](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT057_FFN0_single_runtime_03/receipt.json)。新联合资源、物理时序、P&R与上板均未测。
