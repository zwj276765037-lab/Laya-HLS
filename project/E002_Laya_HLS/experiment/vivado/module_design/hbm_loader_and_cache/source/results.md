# HBM加载与缓存供给：平台、资源与性能记录

本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

从q0/q1/scale/aux加载当前整张矩阵到片内；另装当前head的K/V、RoPE表与LN gamma，输出cache READY/owner状态。

每请求122 LOAD_W声明392,448,128B，B1/B2相同；480 LOAD_KV声明B1 31,457,280B、B2 62,914,560B。当前加载与计算串行。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-hbm_loader_and_cache)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：真实模型、权重、LN/RoPE/KV加载及完整owner/lease接入整图，当前CPU/CSim与实际事件计数通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整加载器](../../../../hls/memory/full_loader.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 真实加载、owner、epoch/恢复检查；整图每请求W122、KV480、RoPE表28 | [当前CTest](../../../../results/engineering_p2/full_cpu_final_20261007/ctest.log) |
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

本模块具体推导依据[05](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md)、[04](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md)、[09](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md)、[11](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### Wi加载、片上供给与容量

```text
Wi q = 5248×1024 = 5,373,952 bytes
每q端口 = 2,686,976 bytes；scale = 5248×(1024/32)×2 = 335,872 bytes
每master假设6.24GB/s：q约0.431ms，scale约0.054ms
q0/q1/scale独立并发时主要服务约0.431ms，另加启动/重排/停顿。
```

B2/S128的16个token tile共用一次Wi加载；理想dot为16×20992=335872cycles，约2.239ms@150MHz。是否隐藏加载依赖前一任务和空bank。

单issue片上A8读512bytes、W8读256bytes、双方scale48bytes、PS读/写各512bytes；在150MHz对应76.8、38.4、7.2、76.8/76.8GB/s。此处是片上银行化/广播需求，不是向单个HBM master逐拍索取。

W双缓存10.890625MiB＋量化输入0.5MiB＋A8/scale0.1328125MiB＋双PS0.640625MiB＋双KV2MiB＋双score0.25MiB＝约14.414MiB。还需LN/RoPE、scalar表、重排和FIFO等；16–20MiB及28MiB旧建议都不能替代实际BRAM/URAM统计。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

大项约14.41MiB，按真实物理实例统一记账；量化、矩阵和attention文档重复列容量用于供需解释，不再加一次。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_hbm_loader_and_cache` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G4物理bank/读口、RAM绑定、FIFO/outstanding、访存效率和互连时序；G1平台。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前实现核对LoadTask的stage/来源类别/固定长度，以及MemTransfer的范围、连续段号和不跨4KiB的分段描述。尚未把加载后的W绑定到WeightKey/K/N，或把A8与QKV缓存绑定到完整shape、请求/layer及plane/head/B/S覆盖；这些元数据关联须在真实计算链前补齐。分段描述通过不证明AXI事务、信用、返回顺序或排空已实现。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

单W5709824B、A8 69632B、quant输入262144B、PS335872B、KV1048576B、score131072B、Q/AV合16384B、LN局部8192B、当前mode RoPE524800B、gamma8192B、F16尾层526336B，以上大项8641024B；另计bias/owner/请求/小缓存，按真实复用避免重复。W用扁平静态数组尝试URAM，实际容量/碎片/端口报告未测。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2当前声明缓存复算（实施中，2026-10-07）

[当前FullCache声明复算](../../../../results/p2_environment_20261007/fullcache_declared_capacity_preliminary.json)记录13组数值数组合计8641536B，即8.2412109375MiB，包含单W q/scale/bias、A8 q/scale、量化输入、完整PS、两gamma、当前mode cos/sin、B2 KV/score、AV暂存及F16 act权重。该数值由所列header哈希对应的C声明逐项乘积相加得到，不含owner/来源元数据、请求输入、局部任务数组、编译器bank/padding及平台保留资源；后续声明变更须更新。

这是逻辑字节容量，不是URAM/BRAM数量或成功综合结论。HLS生成实例、RAM端口和物理碎片尚待完整top报告确认；局部数组若未共享也须计入真实资源，不能把原生产双bank容量或本表直接当作板卡利用率。


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

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。`laya_full_memory.cpp`提供必填`uint16_t&`索引查找核心；旧可选指针API仍由包装器转发，失败时不写result/index，成功时先写descriptor再写index。13个全零synthesis数值数组与CPU私有cache的尺寸及metadata规则保持。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |

## T4 三口reader轻量进度（2026-10-10）

[真实v4 manifest地址模型](../../../../results/compute_throughput_optimization_20261010/attempts/t4_reader_address_01/report.json)逐122张Q8目录核q0/q1、scale地址与每个INCR burst≤64beat、不跨4KiB；串行payload=7,214,120cycles，三口加bias端口理想下界=2,885,664cycles，与现行合同一致。Wi首/末及tile511/512/655、Down group63/64/81的映射均在报告内；本模型不执行AXI或存储写入。

[三口短例02](../../../../results/compute_throughput_optimization_20261010/attempts/t4_reader_short_02/receipt.json)使用真实v4 Wi/Down q0/q1/scale四个首尾/边界窗口，三口每次各交付8192B、两笔4KiB burst；TB逐字节核R及输出、epoch、offset、last、实际AR分段和退休字节。四例各782cycles通过；scale RRESP注入例481cycles，目标口仅一burst后停止且全局`load_error`置位，其它口完整退休。受控guard exit0、31.189s、峰值owned RSS860048KiB，无保护触发。短例01因TB将SV关键字`config`当变量名而编译失败，原日志保留。此证据只覆盖有界读流、回压及错误传播；AUX/bias、完整Wi/Down搬运、双W槽READY/lease/epoch、实际片内RAM映射、综合/时序仍`NOT_RUN`，旧完整top结果不复用于此候选。

## T4 STRICT 双W真实完整供数局部结果（2026-10-11）

[冻结r2 fixture manifest](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_fixture_01/work/fixture_manifest.json)核原模型manifest SHA256 `46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c`与原AUX 128B header，提取完整Wi 5,709,824B、Down 2,854,912B、ACT 2,184B、scorer_fc1 1,118,208B；仅生成仿真hex，不改源模型。正式[有界pilot `_07`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_pilot_07/guard/guard_result.json) guard exit0、17.192s、峰值860164KiB、MemAvailable最低386193828KiB：Wi完整LOAD 54,128cycles发布READY，Down FILLING期间逐位读回Wi前4096个双TN8返回，总58,917cycles，Down q0覆盖237,376B；pilot按局部进度结案，不称完整Down通过。其速率足以准入同一3600s/8GiB/192GiB帽的正式例。

[完整回归 `_05`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_full_05/guard/guard_result.json)在仿真启动前逐SHA核pilot编译源、fixture和21个复制的snapshot文件，再在新work复用XSim编译身份；运行后snapshot中的`xsimkernel.log`与`xsim_script.tcl`被XSim改写，不能称26项输入运行后全无变化，其余编译/source身份匹配。guard exit0、6.818s、峰值852652KiB、MemAvailable最低386113416KiB，[原日志](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_full_05/work/simulate.log)最终`T4_DUAL_W_FULL_PASS loads=6 overlap=10496`且无Fatal/ERROR。Wi slot0 epoch1完整LOAD 54,128cycles；其lease期间Down slot1 epoch1完整LOAD于81,200cycles完成。被动bank checker逐256bit q、16bit scale、32bit bias及mask核Wi 10,496个、Down 5,248个相邻双TN8返回，Wi 10,496次ret均与Down填充重叠。独立端点核每笔AR基址、长度、64beat/4KiB边界及R顺序；四口片内提交有有限反压。wrong首LOAD epoch零DMA、IN_USE覆写、wrong read/release epoch、wrong模型身份lease和失败slot旧lease均拒绝。

slot1 ACT q0 RRESP注入后INVALID，已在读的Wi slot0保持IN_USE；下一epoch scorer_fc1的首个AUX bias F32注入+Inf后首错element0、完整32,768个padded scale检查，仍仅slot1 INVALID。scorer epoch4恢复，完整4096B bias经AUX 4KiB拆分并逐位读回2048个双TN8返回。释放两lease后，在ACT新LOAD真实AXI响应在途时整域reset，两个slot身份清空；随后ACT slot0 epoch1重新LOAD，8个group、尾列mask/无效bias归零及合法释放通过。reset前完成至110,908cycles，最终日志`cycles=63`是复位后的计数，不是完整回归耗时。双槽逻辑RAM与FIFO容量详见[设计](design.md)，该结果为供数/owner局部`PASS_SCOPED`，不代表生产MAC、资源fit、Fmax、完整layer0、XRT/Host或板端吞吐。

保留失败证据：[pilot `_01`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_pilot_01/guard/guard_result.json)为TB AXI `arburst`位宽接线；[`_02`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_pilot_02/guard/guard_result.json)为TB组合ready在同negedge立即采样；[full `_02`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_full_02/guard/guard_result.json)实际揭出RTL ACT padded bias泄露旧/未写bank值，已修成无效列返回0并通过`_05`；[full `_04`](../../../../results/compute_throughput_optimization_20261010/attempts/t4_dual_w_full_04/guard/guard_result.json)为TB将scorer scale检查期望误写8192，真实应为32,768。所有修复保留原fixture与逐位gold。

## 2026-10-11 同容量32独立bank修复（working source，待受影响验证）

按联合设计§7.2.1，`t4_dual_w_cache_v1.sv`的q/s/b payload从顶层多维对象拆为32个`slot×parity×lane`真实`t4_w_cache_bank_v1`实例；每实例q10496×256、scale10496×16、bias328×32，总91693056bit=11461632B不变。每bank独立q/s/b写口及同步读保持，无payload reset、不加外部read stage；父层完整offset/epoch/范围合法后才缩窄u14/u9地址，bias零选择按同次返回锁存。原reader/lease/epoch/覆盖/发布/reset接口保留。原dual-W full05与ACT06只在冻结身份保留PASS，新身份功能/OOC尚未运行；单bank全址TB及真实OOC脚本已准备，后续一份bank DCP回填32cell→全容量cache DCP→ACT封装按累计3600s/24GiB/120s原锁原帽。


## M007-W576-v1 / E011 R001 evidence (2026-10-21)

Final exact source/fixture/receipt boundary: [E011 current_version_evidence.json](../../../../../../../project/E011_m007_weight_supply/experiment_results/runs/R001/current_version_evidence.json). Final summaries: [E011 results](../../../../../../../project/E011_m007_weight_supply/experiment_results/summary.md). Unique source source-byte inverse/old-BO validation596224B in1096 records; complete model/tensor SHA inherited, selected source/output newly hashed.

AT015→AT016 final functional/service PASS, same RTL as AT006/AT007. Peer eligibility40+2*(7−ID)cycles,512bit/2cycles/port. Complete QKV/Wi-last/Down/FC2 LOAD-to-readable cycles735/735/1633/2456 against1024/1024/2224/3328; per-port AR18/18/47/72, R288/288/738/1152 by case. Every port actual peak8 outstanding. Finite-stall K1024=896/1024. Reordered completions280 and interleaved R21898; missing final real R leaves287/288 plus live debt and no completion after1000cycles.

Public reads1248=1096 unique+16 isolation+128 reset-generation+8 rate rereads. First1240 full544B/tag responses hold8windows;1024 overlap prefetch windows. Requested8-record rate test measures4cycle accept interval and1cycle response-valid latency; return/release debt is real. Numeric/padding/transport/protocol, descriptor bounds/overflow/zero-AR, wrong identity/lease/return, response hold, failure isolation and common reset/new generation retain their explicit assertions. Common peer reset assumption is part of current coverage, not platform old-response isolation proof.

Small bank OOC substage AT013:0blackboxes,4URAM+1BRAM18,0LUT/FF, real512×272bit bank. Overall AT013 remains COST_STOP during later reader timing report. Reader capacity AT014:PASS,0blackboxes,311LUT/280FF/7BRAM36+1BRAM18,128×512payload RAM. Full-module AT008 and AT012 time out at120s; no final full utilization/300MHz/route acceptance. These actual leaf resources are not a joint array-fit claim. No P&R/board/HBM/CDC/whole matrix/full model run.

Original failed AT003(counter phase width3→4bit) and AT009(TB block syntax) are retained. Earlier AT005/AT007 PASS belongs to each frozen TB variant; final1248response evidence is AT016 only. Charged ref/static/RTL/OOC seconds0.263572/35.451427/27.545064/425.758240, within600/1800/1800/600 independent budgets.

## 2026-10-23 D32/R007证据边界

新canonical v3/服务源码已准备，32项source-only结构核对不构成编译、RTL、census或physical PASS。实际源版本与下一步以E016/R007和E016三摘要为准；旧记录仍只适用原版本。完整setup/层/30层、DMA与时序均NOT_RUN。
