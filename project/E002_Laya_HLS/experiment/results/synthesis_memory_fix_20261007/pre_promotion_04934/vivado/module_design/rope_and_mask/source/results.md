# RoPE、QKV重排与有限mask：平台、资源与性能记录

当前状态（2026-10-07，P2 F0功能验证通过）：真实表RoPE、双shard转换与有限mask接入完整attention；当前完整CPU/CSim及既有代表性RoPE RTL用例通过。 最终模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| 当前阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整RoPE任务](../../../../hls/operators/full_tasks_attention.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| 当前完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | full/slide各1622016比较；RAW/FINAL QKV全范围，QK/AV直接检查限选定head与tile | [attention直接任务](../../../../results/engineering_p2/full_cpu_final_20261007/attention_dut/full_attention_dut_report.json) |
| 当前完整top HLS CSim | 实际13参数top，标准libm、严格浮点O2，真实B2 47点/9,047,192个F32/37158任务PASS | [最终CSim日志](../../../../results/engineering_p2/csim_full_final_20261007/csim.log)；默认HLS数学模型及RTL非线性误差仍未验收 |
| 代表性RTL | 既有RoPE leaf Verilog/XSim三例PASS；不是完整attention/整网RTL | [RoPE cosim](../../../../results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log) |
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

本模块具体推导依据[10](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/10_rope_and_mask.md)、[11](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/11_attention_and_fp_engine.md)、[04](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### head服务与表/流量

一个Q或K head含64feature：8lane捕获8cycles，4pair旋转8cycles，8lane连续排出8cycles。F0串行数据服务至少24cycles/head＝0.16μs@150MHz，另计浮点尾、表/HBM等待。双buffer或并行Q/K收益需根据实际端口重新核算，不能直接声称8cycles完整结束。

对B2/S128，一层Q+K共2×2×128×16=8192个head对象；按上述串行服务为196608cycles≈1.311ms，未计外存。28个Encoder层均需按所属表旋转；Decision旁路。这里是细化的阶段服务模型，不能与旧研究只按旋转feature计的场景混用。

四张原始位置表1049600bytes属于模型aux；F0写raw Q/K再读取覆写的逻辑额外读写应计入总流量，F1需逐项证明省去的传输。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

单head输入与结果各256bytes起点；双缓冲、表缓存和散写buffer未定。表全量是模型数据，不默认全部占片上RAM。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_rope_and_mask` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G4表窗口/重排buffer/浮点尾和写回周期；G3固定浮点参考；G1物理接口。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前实现核对RopeTask的stage、head、full/slide模式、双shard引用、old/new epoch及逻辑输出数量；基础状态模型只检查调用者声明的覆盖与RAW→FINAL内容转换。尚未按plane/head/B/S与请求/layer核验完整QKV覆盖，因此当前PASS不证明全层RAW或FINAL屏障，也不证明RoPE数值运算、V保持或实际写回完成。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。


## P2 A批设计预算与待验阶段（2026-10-07，Astra xhigh）

依据[task.md §12](../../../../hardware_agent/task.md)和本模块design新增P2节。一个head输入/输出各256B，cos/sin合计512B；原地保护需完整64F32暂存。每head128次F32乘法和64次加减，串行调度；旧4pair/clk只是历史生产预算，本批不据此报吞吐。

实验工具沿用Vitis HLS 2025.2，isolated part `xcu55c-fsvh2892-2L-e`，150MHz为请求而非已达时钟。P2 CPU/CSim、isolated综合、RTL cosim此节写入时均未执行；布局布线/时序、xo/xclbin、XRT/板级亦未执行。实际platform/shell/XRT缺失不阻止板无关代码与实验part验证；资源、II、latency和误差须分阶段追加真实报告。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

当前mode cos/sin全表524800B由loader统一计；head局部暂存至少256B，完整QKV留外部。raw→final的额外读写如实计入F0，不宣称PS直出融合。

13个byte指针m_axi各自bundle，最大widen请求512bit、outstanding1；实际端口位宽/burst、LUT/FF/DSP/BRAM/URAM、II/latency及写响应排空尚未测。本节写入时P2 B批CPU/CSim/综合/RTL未执行；阶段证据后续追加，不能沿用P0合同或P1切片结果代替。


## P2完整F0与生产性能边界（2026-10-07，Astra xhigh）

本轮先实现完整尺寸的串行F0，按[task.md §12.4–12.5](../../../../hardware_agent/task.md)保存实际算术发射率/循环II、单bank缓存、13端口真实宽度、资源及完整任务计数。旧TM16×TN8×GS32、64FP lane、4/8lane向量、双buffer与25/50ms目标保留后续生产优化关口，不作为本轮源码或仿真的已达性能。算量只能结合实际II/共享实例/访存效率估算周期，不把CPU耗时或循环迭代当FPGA周期。

本节写入时完整P2 CPU/CSim/top综合/RTL联测尚待实施；实际已运行的A/B/C证据必须另以源码/model/tag匹配的run追加。缺本机platform/XRT/板卡只限制相应link/部署阶段，不阻止完整板无关工程；布局布线、时序、xo/xclbin、上板质量/稳定性/性能未执行时保持未验收。


## P2 A批实际运行证据（2026-10-07）

| 阶段 | 实际结果 | 原始证据与范围 |
| --- | --- | --- |
| CPU直接TB | 本模块4例PASS，五模块合计30例 | [CTest日志](../../../../results/engineering_p2/20261007T025037Z-1839717/ctest.log) |
| 独立真实fixture | 五模块合计75场景，51个参考文件 | [fixture报告](../../../../results/engineering_p2/20261007T025037Z-1839717/fixture/full_fixture_report.json)；仅本报告所列场景，后续参考扩展/修正需重跑受影响检查 |
| Vitis 2025.2 isolated CSim | 本模块4例PASS，退出码0 | [csim_rope.log](../../../../results/engineering_p2/20261007T030653Z-1859617/csim_rope.log)、[源码身份](../../../../results/engineering_p2/20261007T030653Z-1859617/source_hashes.sha256)；leaf入口、实验part与150MHz请求 |
| isolated HLS综合 | DSP5、LUT1449、FF714，时钟估算4.783ns | [csynth报告](../../../../results/engineering_p2/20261007T030653Z-1859617/rope_head_csynth.rpt)；不作完整top资源/时序或性能结论 |
| Verilog/XSim cosim | 3个补充用例PASS | [cosim日志](../../../../results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log)；quarter-turn、非对称cos/sin、非有限拒绝；最初namespaced stub失败另保留于[历史日志](../../../../results/engineering_p2/20261007T025529Z-1847589/cosim_rope.log) |

完整任务联合链、完整top、布局布线、xo/xclbin及U55C测试另行验收。上述CPU/CSim及isolated RTL均不能证明完整网络功能或AXI性能。


## P2真实RoPE/attention任务初步证据（2026-10-07）

[直接任务初步报告](../../../../build/p2b-attention-dut-prelim/full_attention_dut_report.json)在full与slide两种真实GGUF表模式各比较1622016个F32。完整RAW和FINAL QKV各覆盖3plane×16head×B2×S128×64＝786432值；QK/softmax/AV及ATT_OUT物理片段覆盖head0/1、两题、query row0=0/112的首末16行tile，key范围均为完整S128。完整16head×所有query的ATT_OUT尚未由该测试发布，须由完整DUT/整链验证完成。

本轮局部输入为只读native enc0_qkv，预期RoPE/score/prob/AV由独立候选参考结合真实表和请求mask重算；这种局部输入不允许注入后续完整网络执行。5个负例检查重复RoPE在重写前拒绝、重复shard QK拒绝、live SCORE期间KV替换拒绝且缓存/owner保留、Softmax KV来源账本不符及AV错误head拒绝。该证据使用prelim2包，最终仍需稳定源码与完整输入身份绑定。
