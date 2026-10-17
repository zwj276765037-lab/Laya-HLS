# Attention与共享浮点引擎：平台、资源与性能记录

当前状态（2026-10-07，P2 F0功能验证通过）：全部16head的QK/softmax/AV及尾层FP计算接入整图，当前CPU与标准libm CSim逐位通过。 最终模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| 当前阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整attention任务](../../../../hls/operators/full_tasks_attention.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| 当前完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | full/slide各1622016比较；完整全部head覆盖由当前整图另证 | [attention直接任务](../../../../results/engineering_p2/full_cpu_final_20261007/attention_dut/full_attention_dut_report.json) |
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
