# 前向调度与所有权：平台、资源与性能记录

## 2026-10-08续诊断：metadata presence表示修复

已从既有IR确认：QKV linear的非空pair在reflow/LTO后丢失存在性，load成功后固定E_INTERNAL；binary vector的src1也变NONE并丢失第二绑定。QK/AV固定错误不是孤立算术leaf问题。根因边界、精确等价修复和分层验收见[新修复合同§6](../../../../results/attention_rtl_repair_20261008/repair_contract.md)。[D1独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_d1_review.json)已确认原版生成RTL的6/15事务失配，并确认修正版120项断言/15条事务通过；生产P1/P2/P3已获独立代码审核并同步正式源码，正在分层回归。补丁采用明确bool+reference/descriptor值选择，保留原检查、错误时点、owner与算术；D1含公开stub，不代表真实数值/owner链通过，全网重综合仍须后续技术放行。

正式controller当前SHA256为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`，见[正式同步审核](../../../../results/attention_rtl_repair_20261008/reviewer_official_sync_review.json)。正式新包为[build/model-attention-rtl-repair-20261008](../../../../build/model-attention-rtl-repair-20261008/manifest.json)，tag `fe067c8aa0627ad770096f9721394645`；[本次CPU门禁](../../../../results/attention_rtl_repair_20261008/d2_cpu_full_official/full_final_gate_report.json)已通过141检查点及故障恢复。该身份的真实13口B2/S128标准libm CSim现已另run执行通过（47检查点、9047192 F32、37158任务），见[日志](../../../../results/attention_rtl_repair_20261008/d2_full_top_csim_official_v1/csim.log)，独立运行审核另列；生成数值/owner链与完整RTL尚未验收。隔离副本tag `18366c267ae0a7ca0c3afb8c2174b890`不替代正式身份；旧04934包和硬件制品保留，不与新源码混配。

本节是新任务进展，以下performance_review及旧CPU/CSim/OOC记录只对应其原始源/制品；不改写旧证据，不将新补丁预记为已验收。

本页下方历史硬件制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

接收请求和owner状态，输出typed task并检查done；issue/full_run_task同步返回后才发下一任务。

B1/S128退休18,895任务，B2/S128为37,158；没有跨任务并行重叠证据。任务次数是CPU observed计数，不是RTL时钟数。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-forward_controller)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：完整F0调度、owner屏障与持久故障恢复通过当前CPU整图及真实top CSim验证。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整调度器](../../../../hls/control/full_forward_controller.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 实际op、层、W/KV/量化事件逐项核对 | [最终功能机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
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

本模块具体推导依据[03](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/03_forward_controller.md)、[14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### 统一排程计算方法

对阶段i使用`start_i=max(全部依赖就绪时间,共享引擎可用时间,所需缓存/端口可用时间)`，`end_i=start_i+实际服务cycles+暴露尾延迟`。只对物理资源独立的阶段取重叠，不能把所有模块各自最佳值直接相加或取max。

- QK与AV：同一个FP引擎，示例2048+2048cycles。
- Wi与down：同一个Q8引擎，16行示例20992+10496=31488cycles，尚未含量化、gate、读出与切换。
- F0 QKV tile的LN/量化/dot/读出串行服务为6144+4096+12288+6144=28672cycles，约191.15μs@150MHz；完整tile还须加入外存、scalar和FP尾。
- F1a的首A8 tile仍要考虑LN6144＋量化重放2048cycles；后续是否可重叠以独立缓存/算力/端口证明。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

控制上下文/有效位/仲裁寄存器未定量；大缓存由hbm_loader_and_cache统一计，不能再作为控制器资源重复计入。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_forward_controller` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G2控制字段/错误码；G4函数实际实例数、延迟和调度trace；G5恢复与排空行为。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前状态模型核对单任务互斥、epoch/region、调用者声明的覆盖范围、content_kind、TYPE_ROWS逐type有效位/读锁及WI/DEC_FF别名；reset消耗已预留的下一epoch，拒绝旧引用复活。尚未保存或核验A8的K/rows/batch/row0/row_space与源epoch、W的WeightKey/K/N、QKV的plane/head/B/S及请求/layer身份；上述元数据关联、全层QKV屏障和全图调度必须在计算链接入前补齐。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。


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

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。`Controller::fresh`与`invalidate_incomplete`分别以0…31整数索引遍历owner记录，仍保留首匹配、最大epoch、READ/readers提前拒绝与原失效顺序。scorer/act两个必填bias调用使用引用索引查找，不改变返回状态和发布顺序。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |
## 2026-10-12 production caller 分区状态

单体 production HLS `_05/_06/_07` 均在 13,223,459 条 Compile/Link instructions 后触发原 120s 真实产物停滞保护，未生成候选 RTL；该 profile 已停止无区分重试。当前进入 caller/producer 独立生成阶段。分区合同已冻结，实际 caller engine 通道、算术闭包切断、独立 producer RTL 和最终 shell 尚未取得新运行证据，因此保持 **IN_PROGRESS / NOT_RUN**，不能继承单体或 FIFO probe 的 PASS。

## M007 E016 SINGLE-PARENT-11 current bounded implementation (2026-10-22)

execution_state: completed
verdict: inconclusive
applicability: 原Encoder0、有界父前缀/首head/故障恢复与独立生产context consumer；精确版本见R001/current_version_evidence.json。

| 范围 | 实际结果 | 版本/边界 |
| --- | --- | --- |
| 唯一资源与控制账 | AT022 build PASS45.051571955s；91947实际展开scope；所需13个服务/模块路径均恰好一份；452输入源；3746B保守控制账 | 当前parent；旧AT00391923scope仅为历史TB展开 |
| 原始身份拒绝与QKV3 | AT006、AT012及当前AT023：六个完整128bit source tag高半部错误、两个跨层tensor key错误均零实际工作；243bit错误响应保持5拍；实际4096输入/量化/A写/ack，768QKV32/24576值 | 持稳已测；各回显字段与完整原graph Check期望值不是本轮全覆盖 |
| 完整QKV→首完整head | AT013 PASS782.969087822s；48块/12288QKV32/393216值，2048RoPE提交，head0 score16384/prob16384/context8192，2048softmax-bank ack；head11038拍≤11648；命令→layer.start56026拍；命令→head末69139拍 | 旧parent；一次真实layer.start；不是16head或parent DONE |
| 量化NaN取消恢复 | AT015 PASS60.229704667s；4096真实输入，0QKV/AR，1PREPcancel+1Acancel，status/raw/domain=1/2/3，显式期望tuple000001000000000011000000；无reset新gen完整输入→QKV3 | 旧parent |
| 晚W故障取消恢复 | AT016 PASS76.090052532s；1真实RRESP错前已256QKV32写，1PREPcancel、0Acancel，status/raw/domain=2/3/4；无reset新genQKV3 | 旧parent；tuple000007000000000000000000为观测值，缺独立精确tuple断言 |
| 同沿producer失败 | AT017 PASS58.860724688s；真实producer_fail_fire与q_done同沿；1实际A取消+1PREPcancel，0QKV/AR，status/raw/domain=3/3/2；tuple123456789abcdef0fedcba98显式核对；无reset新genQKV3 | 旧parent；三类错误响应完整243bit保持5拍 |
| 生产context consumer | AT021 PASS6.426384921s：117组时带真实DIV/quant债取消，118读/响应、45A写/ack、无发布；坏tag18读/17消费、坏响应仅排一次且同沿无续读；无reset后4096读/响应/量化/A写/ack、1发布；末响应保持12拍无早完成 | 实际生产adapter/front/A/DIV+合法public源peer；不能替代实际layer16/父交接 |
| 当前parent共同reset | AT023 PASS53.261602898s：4096真实输入后在FPmul9、FPadd pending及31算术债/PS忙时共同reset3拍；随后40干净周期，系数覆盖失效并真实重写512组；新gen9/epoch10完整输入→QKV3，8364拍、31/13拍被动反馈 | 当前parent；functional peer共同reset。继承generic marker的kind=quant/no_reset=1不解释为整例无reset；HBM物理reset未测 |

AT013使用原独立QKV/RoPE/score/prob/context参考。其首head终点核真实h_done握手与上述数据/周期断言；固定unfinished_parent打印不证明该长例逐拍禁止parent成功，max_checked不是独立终点断言。其wall started_at误写在接近退出处，原文件保留，仅使用单调event差值；后续driver已修正UTC起止字段。

全16head/WO成本门：1.35×(782.969087822+15×119.898432351)+10=3494.951523668s，尚未计context量化/WO，已超过单次1200s与当时扣240s恢复后的2425.271683606s。COST_STOP/NOT_RUN，未创建全16/WO子进程或attempt；不是数值FAIL。不得把独立E012/R004原context文件WO131072值/22129拍拼作真实父整链证据。

严格数值进度guard SHA76aa32642e1bffb4c0ef6eab111999d633d9261649adbd8b977d85ac3aa13c3b，RTL停滞120s，仅接收实际比较后全局递增的M007_PARENT_CHECKED；任意日志/文件增长不续命。AT008缩短2s反例验证沉默和重复计数停止、真实递增通过；AT013 checked highwater827392无trigger。AT024审计PASS6.307549500s：3032文件/3764检查；20项xsim_script.tcl/xsimkernel.log运行变化明确登记为可变文件，其余受核冻结项通过。审计数值语义仍以各TB原断言为准。

保留费用：AT001/007编排错误NOT_RUN0s，AT009声明顺序FAIL1.969928092s，AT010依赖NOT_RUN0s，AT019空闲粘滞fault测试观察器FAIL5.424140056s。AT020仅在idle排除合法粘滞fault；活跃意外fault仍断言，未改DUT/gold。最终独立累计reference0/static319.040353202/RTL1195.020926156/OOC0s；AT024已计费，AT008内部synthetic工作只计外层static一次。

证据：[最终交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/final_delivery.md)、[版本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/current_version_evidence.json)、[预算核对](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/ledger_reconciliation.json)、[审计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R001/attempts/AT024_final_version_aware_evidence_audit/work/evidence_audit.json)。

## M007 E016 R002 simulator-cost comparison (2026-10-22)

execution_state: completed
verdict: inconclusive
applicability: 仅同当前parent/同TB/原fixture的单次有序QKV3比较；不外推全部phase或FPGA性能。

| 指标 | O3/debug typical | O3/debug off |
| --- | --- | --- |
| 实际build | AT001 PASS，46.737763029s | AT003 PASS，52.533158917s |
| 实际QKV3 RTL | AT002 PASS，48.806138473s | AT004 PASS，54.403592327s |
| 命令→QKV3周期 | 8364 | 8364 |
| input / quant-return / Awrite / Aack | 各4096 | 各4096 |
| W_AR / W_R | 320 / 5024 | 320 / 5024 |
| public QKV32 / 逐位F32值 | 768 / 24576 | 768 / 24576 |
| 实际issue→ack / PS反馈 | 31 / 13拍 | 31 / 13拍 |
| 身份/跨层tensor零工作拒绝 | 8项 | 8项 |
| strict checked highwater | 155648 @ cycle8955 | 155648 @ cycle8955 |
| 自己的Tcl scope数 | 91940 | 90486 |
| 自己的所需13模块/服务路径 | 均恰1份 | 均恰1份 |

两例每块1024连续issue/commit，所有原实际W/A映射、prebias、公共QKV与Attention独立gold比较和原协议断言通过。终点parent phase5，真实父仍未完成。debug off完整保留当前TB内部引用且本机Tcl query成功；91940/90486是调试展开可见性差异，不是硬件资源减少。

本次off比typical慢5.597453854s，即11.468750%。每组仅1次、固定typical→off顺序，不提供方差、置信区间或普遍速度劣势结论；现有样本未支持成本改善，依合同结束本路径，不继续盲试旗标。普通生产runner仍保持原O3/debug typical。

实际已flush阶段wall差值（只签相同QKV3边界）：量化/A phase3→4为2.836810378/2.767173767s，均4187周期；matrix phase5→QKV3为39.544960920/45.218092302s，均4173周期。更多block差值见[phase_comparison.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/phase_comparison.json)。这些是主机观测时间，不是新硬件时序；没有本组合完整head/16head/context/WO成本样本，不能代入完整链作放行。

AT005审计PASS4.570399001s：R002634文件、3616检查；另重新核对R001冻结原artifact3032文件全部未变。两组源码/编译选项差/原TB保留/fixture/计数/周期/strict guard和预算一致性通过；4项xsim_script.tcl/xsimkernel.log运行可变差异单独保留。raw warning/error及自己的hierarchy query日志完整保留。

最终独立费用reference0/static103.841320947/RTL103.209730800/OOC0s，含审计；余额static196.158679053/RTL196.790269200s。无失败重跑或原预算转移。R001完整16head/WO成本门3494.951523668s>1200s继续COST_STOP/NOT_RUN；本段未创建长例。数值/物理/整图限制继续按R001版本边界保留。

证据：[成本对照](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/attempts/AT005_same_source_flag_comparison_audit/work/cost_comparison.json)、[审计](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/attempts/AT005_same_source_flag_comparison_audit/work/evidence_audit.json)、[预算](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/runs/R002/ledger_reconciliation.json)、[协议](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_source/r002_sim_cost_protocol.md)。

## M007 E016 完整父链后继准备（2026-10-22，只读规划）

本节是主控要求的有界准备，不是完整验证合同或运行放行。生产RTL/TB/runner未改，EDA未运行；R001/R002原attempt、最终交付和封账预算不变。当前parent SHA `e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8`。证据与单独只读账：[planning](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/planning/full_parent_successor_20261022/planning_ledger.json)、[冻结gold布局核对](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E016_m007_single_resource_parent/experiment_results/planning/full_parent_successor_20261022/frozen_gold_layout_consistency.json)。

### 当前实际入口与不能直接运行完整链的原因

生产parent在[控制段](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/rtl/laya_m007_single_parent_v1.sv:1142)已写出 `LRUN→CSUB→CRUN→CDRAIN→WMSUB→WMRUN→FINISH`：真实layer成功DONE后启动同一quant/A和context adapter，等待c_complete/c_idle及layer_idle，再发K1024/N1024的WO命令；WO真实matrix DONE被消费后才进入父FINISH。这是源码行为，未被当前完整链动态签署，未发现仅据源码即可认定必须先修改RTL的缺陷。

现[m007_single_parent_tb.sv](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_single_parent_tb.sv:211)没有full模式。PREFIX>0只结束QKV前缀；PREFIX=0在首个实际h_done握手就打印FIRST_HEAD并$finish。head计数是首head总数，max_checked只置一次，未按16head退休重置；仅去掉$finish会在head1统计断言失效。虽然score/prob/context/max数组已加载全16head参考，当前终点仍只核head0，且未要求max_checked成为终点条件。

当前W peer只装QKV p0..p3，AR地址仅允许cmd_base[0]/cmd_span[0]，Rdata也固定按QKV基址读。当前A/write和W/prebias/core trace checker同样固定QKV数据与48块计数；后续context A和WO从s0重起会误用旧gold/旧计数。out_ready恒1，尚无父WO数据/正常成功DONE检查。

现[runner](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/forward_controller/tb/m007_parent_run.py:34)也无full模式：prefix0要求QKV3 pilot，成本门只投影完整QKV+首head71168周期，成功marker固定FIRST_HEAD；没有完整父成功marker、全链fixture身份、完整阶段wall事件或独立后继账。因此不能直接调用旧runner加timeout获得完整链。R002 runner同样固定PREFIX=3，仅供已关闭的debug选项对照；普通runner保留O3/debug typical，不继续扫旗标。

### 新TB应新增的检查与合法驱动

| 边界 | 应新增或按相位扩展的实际检查 | 驱动限制 |
| --- | --- | --- |
| 一次父命令/QKV | 原8身份拒绝与所有原QKV检查保留；正常命令只接受一次；4096原输入→4096quant/Awrite/Aack，48块、12288QKV32/393216值；matrix QKV命令与layer.start各恰一次 | 通过原cmd/F32/coeff口，正常链不reset、不逐块发命令 |
| 16head | 每个head独立score16384/prob16384/context8192/prob ack2048、maximum128比较且终点必须已核maximum；每head真实h_done/status/identity/head index、唯一start/retire及周期帽；总head16、score/prob各262144、context131072、prob ack32768、maximum2048、RoPE2048commit；layer head_completed/context_valid在交接前应FFFF | 只被动观察实际内部握手；全局strict checked counter单调不重置，局部per-head计数可分组；保持全部原checker频度 |
| layer成功回执 | 核实际l_done_valid&&l_done_ready，status0、request/gen与原命令完全一致，16head已完成；按冻结layer Check合同核completed/unreachable/dominated/coverage/error，不用“全置1”替代合同 | 不TB伪造layer DONE/context_valid；layer成功DONE不代表context已释放 |
| 公共context4096组 | 对每个真实rd/rsp握手记录一笔实际credit，tag/代际/顺序及32F32逐位比较；读序i=32*query+2*head+half，参考lane=context[(head*128+query)*64+32*half+c]；4096实际响应→4096quant/Awrite/Aack、一次A发布，compare两套QKV/context A gold分相位 | 必须消费实际layer输出；原context文件仅作期望。公共响应保持依实际信用；禁止强制c_*或layer状态 |
| context所有权退休 | 核layer公开消费覆盖4096、public_read_owned=0、无未退storage响应、c_idle/c_complete/c_consumed=4096、quant/DIV/A debt已清并实际发布，最后才接受WO matrix命令 | layer[退休逻辑](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_layer_engine_v1.sv:1169)在响应真正握手时记覆盖，L_RELEASE等全部覆盖与real_idle才回IDLE；应观察实际条件，不能用TB换相位 |
| W重绑定/复用唯一cache | 用实际AR地址在已登记的QKV/WO基址范围选择原packed数据；每个已接受ID保存其所属源，R响应按接受时源返回；核QKV旧W/A/FP/PS lease和peer AR/R debt全退，WO实际K1024/N1024、tensor32、base[1]/span[1]、同request/gen/epoch，16块冷W装载及原W/prebias/A映射 | peer扩展为两套只读fixture，不复制生产W服务。不能用全局phase给旧在途ID改数据，不能预填W完成或force cache |
| WO131072原值 | 按actual out_valid&&out_ready计4096个32F32响应；输出s=i/256、row=(i%256)/2、col=64*s+32*(i%2)，每lane对原WO[row*1024+col+c]；16块每块1024连续issue/commit，记录反馈、W/A协议和最后输出/资源释放 | 原out_ready口有限反压可合法保持中间/末WO响应；held时valid/data/row/col稳定，不提前接受WO DONE/父成功 |
| 首次父成功/held DONE | 正常例逐拍禁止在“16head、4096实际context、A发布、4096WO响应及真实WO matrix DONE/债释放”前出现任何父DONE；首次成功须status/source_status/error_domain/error_tuple全0，done_request/gen/epoch精确等于接受命令；并核来源m_done身份。done_ready=0保持至少5拍，完整243bit字段既等于独立期望又稳定、cmd_ready=0、无新工作；真正ready后只退休一次，回IDLE可合法接下一命令 | 仅驱动原done_ready/out_ready；稳定性与期望值分别断言，不能只拍下DUT值再自比 |
| 事件与成本 | 在实际command、QKV accept/end、layer start、每head begin/end、layer done、context首/末响应/发布/释放、WO accept/首末输出/matrix done、父done/retire记cycle与主机monotonic wall；generic日志不续strict numerical progress | 原40Mcycle、资源策略、单独账不改；新full终标只有所有检查完成且实际父成功退休才发 |

上述断言属于TB/runner扩展，不应先改生产接口。完整同构建TB可设置observer-only的STOP_AFTER_HEAD=1：在真实head0完成后结束pilot；full设置0继续观察至父DONE。两者不改变DUT命令、参考、相位、驱动或检查频度，full phase checker也必须编入同一snapshot；不是以pilot签全链。两个mode同样在初始化时绑定WO原fixture，避免pilot漏计加载/observer开销。

末context响应在独立consumer中曾合法保持12拍，但当前生产parent没有run_enable/独立result_rsp_ready的外部控制口，out_ready仅影响WO。完整parent若自然发生context反压可被动核稳定；无法通过合法顶层口指定“第4095响应保持12拍”时应标该定向保持NOT_RUN，不能force内部ready或借独立peer结果冒充。正常WO out和父DONE保持均有现成合法顶层口，可随一次完整正常例完成。

### 独立参考已具备，仍未知的生产行为

只读布局核对本次已比较全部131072 context位型：E010 encoder0_context.mem按上述query/head/half重排后与E012/R004 AT005 input.hex完全一致。WO output.hex的4096组按上述s/row/half顺序与E015 AT007原wo.bin/expected_f32.bin的131072位型完全一致。原WO gold SHA `1527544ebbc58548cacd152ba0a98fe679332fc83d651f3c2ffed15b4eca19dc`，原WO weight SHA `6be3b4e35057b15055db95ef5ab1d572ce202ac89200abc51479a1bfdd31c288`，均来自已有fixture.json；未重算gold。新完整模式仍须把所有WO p0..p3、input/Awrite/output/prebias/源manifest身份纳入snapshot，期望文件不能被当成真实context输入。

目前“已证TB缺口”不等于“生产RTL有缺陷”。以下组合行为仍未知：全部16head及layer Check退休；真实layer result读与同storage phase4/DIV phase5并行路由；QKV A释放后同request/gen/epoch重新真实填槽是否正确失效旧内容并发布新context A；layer4096覆盖到real_idle与quant/A完成的联合排债；唯一W/A/cache/FP/PS由QKV→layer→WO的重绑定与迟到响应隔离；WO输出保持、最终成功状态/tuple/identity与held父DONE。当前源码有相应调用路径但未完整实测；必须由新正常链暴露问题，再在授权内定位修复，不预先宣称PASS或FAIL。

现e354的c_fault相位修复通过当前短QKV/reset scope，仍未动态覆盖“真实父context fault→无reset新generation”链；这是独立错误恢复后继，不应拿正常完整例当作该故障覆盖。Encoder0无bias完整链也不能签Decision/bias、全图原首错/Check、30层、HBM注册/CDC/物理时序/板卡。

正常成功tuple零有具体源码依据：facade[每次实际cmd清状态/坐标](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_facade_v1.sv:240)，parent在WMRUN消费实际m_done后映射成功状态/域并返回该坐标；新TB仍必须把预期0与原命令身份逐项核对，不能用来源稳定性代替独立期望。

### 建议集中制定的新预算与一次完整运行上限

建议新独立批次（名称由主控决定）reference0/static300/RTL7200/OOC0秒，不转R001/R002余额。static每次≤120秒；同一当前RTL/全检查TB构建后先真实完整QKV→首head pilot≤1200秒，再由主控基于该pilot决定一次full≤5400秒（90分钟）；其余600秒仅供有新诊断依据的短恢复/受影响回归，不自动再跑整条长前缀。全部真实语义停滞120秒、CPU0–3/nice19/idle、MemAvailable>192GiB、static≤24GiB/RTL≤8GiB、40Mcycle及项目锁不变。budget是建议而非本次已获执行额度。

旧3494.951523668秒只说明旧parent/旧首head observer下的attention-only费用，不能为e354或新全检查TB放行。旧E012/R004完整WO203.558494425秒来自独立context-file runtime；R001本地consumer6.426384921秒也不是当前完整父的phase样本。它们仅帮助给新5400秒一次性cap留工程容量，不能拼接成当前完整链实测。

新pilot必须给P=当前同snapshot命令至首head退出wall、H=该实际head0 begin→end wall，并保留阶段/数值证据。建议供主控决策的工程估计 `E=1.35*(P+15*H+C_allow+W_allow)+10`；第一次完整链尚无同runtime C/W样本，可在新集中合同中明确选择C_allow=60秒、W_allow=600秒作为收费/停止占位（不是测量、不是性能保证），而不要求先做完16head才能给第一个完整例放行。若E≤5400且当前pilot数值/所有权/strict进度通过，可由新合同明确授权一次完整例，在这次运行里直接测得所有head/context/WO真实成本与完整成功；若超cap或pilot失败，交主控集中调整scope/预算，不在runner自动加帽或反复重放。当前没有执行/放行任何pilot或full。

完整验证同时记录原QKV≤57344、Encoder layer≤188544、WO≤22528、每满足前提dispatch≤16且父调度合计≤128，以及Encoder整块≤268416拍；新合同应精确定义原QKV_ACCEPT/WO_RETIRE事件，并同时记录父cmd accept与QKV matrix cmd accept，避免把不同边界混写。外部held停顿单列，不能自行从原总帽扣除或把独立周期相加写成实测。FPGA吞吐/300MHz/物理fit仍不属于仿真wall预算结论。

## M007 E016 R003 FULL-PARENT-15 actual delivery (2026-10-22)

# E016/R003：完整原Encoder0 Attention父链 PASS

execution_state: completed
verdict: supported
applicability: 仅原Encoder0一次命令QKV→Attention16head→实际context→WO→成功回执；不签完整Encoder/FFN/30层、物理或部署。

| 实际边界 | 结果 |
| --- | --- |
| QKV | 48块、12288公共QKV32、393216 F32原值 |
| RoPE | 2048真实Q/K提交、原postQKV逐位核 |
| 16head | score/prob各262144、context131072、maximum2048、prob bank ack32768；每head独立数值/身份/周期终断言 |
| 实际公共context | 4096读/响应，query/head/half/tag/gen与32F32逐位核；4096真实quant/Awrite/Aack、一次发布，layer与量化/DIV/A真实债/所有权退休后才WO |
| WO | 唯一matrix/cache真实WO冷载16块，每块1024连续issue/commit；4096公共32F32输出/131072值原gold |
| 首次父成功 | status/source/domain/tuple独立预期0，request77/gen8/epoch9，243bit保持5拍后真实消费一次并回IDLE |
| 有限WO反压 | 中间至少8拍、末输出至少12拍，实际held计数8/12，完整输出与身份稳定、无早DONE |

AT007唯一full实际wall 2828.967579680s，PASS，数值及周期合同均通过。完整实际周期字段：{"parent_cmd": 591, "QKV_cmd": 4781, "QKV_last": 56610, "layer_start": 56617, "layer_done": 235394, "context_start": 235395, "context_last": 239492, "WO_cmd": 239584, "WO_last": 257538, "WO_done": 257544, "dispatch_total": 7, "raw_parent_cmd_to_WO_last": 256947, "raw_QKV_cmd_to_WO_last": 252757, "cycle_pass": 1}。保留原始总周期和外部held，不偷偷扣停顿；模块QKV57344/layer188544/WO22528、dispatch16/合计128与Attention父段268416帽仍按实际事件检查。

同AT004完整snapshot：AT005 QKV3 PASS48.746615243s/8364拍；AT006真实两head pilot PASS877.589479115s。固定实测门P2=877.232754763s、Hmax=114.465794125s、Q=628.900676903s，E=1.10*(P2+14*Hmax+Q)+10=3429.520004357s≤3600，余额≥E+600，故仅自动一次full、timeout3430。Q明确是context+WO的可证伪占位而非实测；本次完整runtime实际CSUB入口→WO DONE为267.514431983s，未超过该Q，区间包含context派发，不能冒充硬件频率。逐head实际wall与周期见actual_complete_chain_metrics.json。旧R0013494.95秒仍为旧版本/旧observer估计；R003使用新合同、新预算和同snapshot实际数据，无旧attempt延帽。

失败保留：AT001生成器end拼接语法FAIL1.914082291s；AT002 build PASS后AT003首批quant/A处xsim内核exception FAIL6.614362462s。等价显式TB字符串/数组分支后AT004 build PASS43.694276949s、AT005/006/007在此组合执行；没有把异常解释为方法数值失败，也未隔离单一构造因果。AT003旧fatal分类未识别FATAL_ERROR文字，但缺终标仍FAIL；原receipt不改，后继分类已扩展。

最终审计1035文件、1670检查PASS；xsim运行可变配置/日志差异单独登记。独立费用reference0/static94.410942169/RTL3761.918036500/OOC0s，含失败与最终审计；余额static505.589057831/RTL2238.081963500s，R001/R002未转余额。
## M007 FFN-REFERENCE-18 R004 local reference exit (2026-10-23)

A010：原G row0独立Q8(2624 codes/82 half scales)、norm_ff32组及Down1024 F32参考生成并审计PASS；完整128行成本式127.26535248011352s>120s，严格COST_STOP/NOT_RUN，无RTL/EDA/整模gold。原参考/运行库/完整输出SHA与真实收据见[局部参考交付](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/final_delivery.md)。[逐束连线表](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R004/reports/ffn_connections.md)固定norm_ff→Wi native0..81→双槽G→1024bit拼接→同quant/A槽1→完整成功屏障→Down；新父计划20bit，复用2套descriptor和原5bit state。A007取消实际声明3bit但最终正常回归待交，联合设计投影4038.875B/向上4039B，非实现fit。若另存两套Wi/Down descriptor将增1024bit超帽。完整Encoder真实skip/residual/LN和本输入128行Down参考仍未就绪；不继承旧e354 PASS。

## M007 E016/R005 initial FFN reference and real prefix (2026-10-23)

Independent original128-row reference PASS via8 distinct16-row batches plus serialization-only merge,8.056908318s total:10496 G groups/335872 codes/131072 Down F32 values. Source/oracle/runtime/weights and full products are bound in `project/E016_m007_single_resource_parent/experiment_results/runs/R005/fixtures/manifest.json`.

AT018 on9544eff1 parent PASS80.520057882s/9063cycles:one norm_ff command, actualWi24576/G12288 values and122880 FP/TANH nodes, A1 writes/ACK362, unfinished parent with no A1 publication. AT017 binds the already compiled AT016 snapshot after correcting only frozen audit root handling; actual hierarchy and declaration audit4038.875B/ceil4039. AT015 owner-switch timeout120.349110275s/no numeric progress and earlier build failures are retained. Current explicit-G-status parent62cf04f5 is separately building and does not inherit AT018 as its own full proof. Complete FFN, error/newgen, affected QKV3, Encoder/30layer and physical stages are pending. Authoritative current evidence/costs: E016 experiment three summaries and R005 budget_ledger.json.

## M007 E016/R005 complete original FFN actual delivery (2026-10-23)

Current parent `62cf04f53be966ac3b214dc955fda236efba2dc0cc20b90c539352c96312b86f`: one public kind3 norm_ff command completed actual quant/A0 → Wi 82 blocks → original dual-slot G → Q8/A1 → Down 16 blocks → held and retired independent parent success. AT027 PASS in 2841.234702409 s; 137302 TB cycles through held/retired finish. Full independent checker covered Wi 671744 values, G 335872 values and 3358720 node checks, 10496 A1 groups, and Down 131072 values. Down middle/last held 8/17 cycles; parent success held 5 cycles and consumed once.

Actual G eligibility-to-first-output maximum 185 cycles and eligibility-to-release 697 cycles; norm quant acceptance to Wi last output 92023 cycles; prequantized Down command to last output 44466 cycles. Actual Down wall 794.847238288 s is inside original uninflated work/cold/terminal allowance 904.573330836 s; original launch gate 3489.934307356 s and timeout 3490 s were unchanged. AT028 final identity/hierarchy/resource/budget audit PASS with 679 checks. Actual control remains 4038.875 B (ceil 4039), including 20 new FFN control bits; 128 B numerical holding is separate payload.

AT023 real Wi RRESP → G cancel → failed quant close → discard → no-reset newgeneration and AT025 affected legacy QKV3 passed. Exact injected Wi error coordinates and unknown G status dynamic coverage remain unproven; error hold/retirement and static unknown-status preservation are qualified separately. Integrated directed G output hold/third-slot control is NOT_RUN because no public parent control exists. All earlier failures and R003/R004 evidence remain frozen. This is a complete public norm_ff FFN island, not complete Encoder/30 layers or physical timing/fit.

Authoritative delivery: [R005 final delivery](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R005/final_delivery.md), [version](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R005/current_version_evidence.json), and [exact independent budgets](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R005/final_budget.json). Exact used reference/static/RTL/OOC seconds: 8.05690831801621269 / 274.34311171306763206 / 3608.11220994516039 / 0, including failures and final audit; no old balance transfer.


## E016/R006 current parent-v2 evidence (2026-10-23)

Parentb6bf3d81 compiled with full original mathematical TB (AT006), actual control32519bits/4064.875B (AT004), actual publicH/error/newgen prefix PASS (AT007), and actual kind4 QKV3 prefix24576 original values/12454cycles/106.014646108s (AT008). Full Encoder0 remains NOT_RUN. Capture observer outer-packed-array byte indexing was wrong; old binary SHA5073ade2 remains ineligible and unchanged, mathematical prefix scope unaffected. Current capture source uses[lane][8*octet+:8]; independent synthetic AT009 build4.367924981s and AT011 seven-case RTL41.548044566s passed. All32lanes/4octets and shuffled input/output coordinates checked; normal completeness true and six negative completions false. AT010 pre-guard copy failure is preserved. Actual7/7 and30/30 process policy identities checked, both owned groups empty afterward. Parent frozen AT006 still contains the old observer and awaits future CE integration/rebuild. Current E016/R006 summaries/version/status retain exact immutable evidence and independent budget; prior R005 complete FFN remains frozen. No physical fit or complete graph claim.


AT012/PACKED1 and AT013/PACKED0 reused AT006 and original kind3 fixtures,120s caps unchanged; both COST_STOP (120.284573508/120.220978636s). Real common Wi3/G2 counts and cycles matched, G8192values/81920nodes atcycle8003. BEGIN→G1 wall97.127847643/94.663319763s; no packed speedup established by this single pair. Parent/FFN3 complete result remains unverified, no kind4 gate. Both five-of-five observed policies checked and owned cleanup empty. Current R006 comparison/receipts preserve the exact source/version boundary; no cap extension or old binary reuse.


Current D27/default-auto0 AT014 parent build PASS58.332288880s and AT015 actual243check census PASS0.959546240s;32519bits/4064.875B, one v2TANH8/eight cores, exact reversible zero-FF replacement proof. AT016 kind4QKV1 PASS46.544751830s/8192original values/10336command cycles; AT017 same-buildkind3WiG1 PASS68.562290498s/Wi8192,G4096,40960nodes/6938cycles. Actual input serialization now passes real4096 handshakes in both; output0/complete=false. Current complete-kind4 gate UNKNOWN due missing steady/head/WO/LN128/Down/export/retirement costs; do not sum old/different-top measurements. All new owned groups/identities actually empty; window released to separate D31 experiment. See E016/R006/new_CE_minimum_pilot_costs.json and current_version_evidence.json.

## 2026-10-23 D32/R007证据边界

新canonical v3/服务源码已准备，32项source-only结构核对不构成编译、RTL、census或physical PASS。实际源版本与下一步以E016/R007和E016三摘要为准；旧记录仍只适用原版本。完整setup/层/30层、DMA与时序均NOT_RUN。

## D32/R007 actual version update 2026-10-23

Canonical production parent7b0d0c6d is compiled with current owner joint/TANHv3 in AT012 and successor affected snapshots. Actual setup124catalog words/704model chunks/twoRoPE families, public ABI/recovery, catalog lateRLAST drain and32342bit logical census passed; this supersedes the earlier source-only status, which remains historical. Actual parentQKV1 checks8192original values after real4096H/quant/A; it is unfinished. Current B1 normal-chain cost checker compiles in AT026, runtime cost work continues.

AT025 same-production joint G/twofullresidual/LN128 component passed183.031842316s,8192residual+4096LN vectors/394760F32 checks and15440G nodes. Observer-only residual_total increment separates AT024 from AT022; AT023 raw0 reporting defect remains immutable. Final A is Attention owner return, not actual LN→quant/A chain. Exact sources/receipts/limits in E016/R007/actual_joint_LN128_evidence.json and current three summaries. Full Encoder/30layer, canonical bias readback, actual Decision16384FC1/K4096→FC2, physical timing/fit/DMA remain unverified.

AT027 originalB1 QKV3 actual PASS89.599573990s,24576F32/16461commandcycles. Current completeQKV estimate1518.477961845s exceeds1200componentcap; completeEncoder costUNKNOWN, latermathsegments remain unmeasured. AT029 realquant/DIV/A maximumK4096 A1 16384write+ACK and realpartialcancel/newgeneration passed; this does not sign actualFC1producer/FC2 or parentACANCEL. AT030 finalrecord CRC passed. No in-flight EDA at staged handoff; authoritative versions/cleanup/cost/budget in E016/R007/staged_delivery.json and three summaries.

## D32 current AT031–037 boundary

Canonical93productionfiles remain identical to AT026. AT031 realfullQKV48retirement/393216originalF32 and2048RoPE plus occurredQK/SM checks are accepted; postQKV120scap COST_STOP1403.258719394s, nofullhead/EncoderPASS. SameAT026typical/off QKV1 pair passes equal106events/8192values/14343cycles,49.153994803/40.763996112s; singlepair17.07%wallreduction only.

Newindependent m007_fullmodel_encoder_tb37e8c147 compilesAT036off and actualQKV3 passesAT03780.903062850s/24576F32/12461cycles, actual4096H inputbinary matchesoriginal47checkpoint. Fullfourmatrix/Attention/G/resLN/FFN/finalH/heldDONE originalchecks are retained in source but onlyQKV3hasrun. AT035unusedobservercompilefailure is immutable. NewQKV48E1390.687966983s exceedsordinary1200/component and remaining-minus400reserve; fullEncoder/30layerEUNKNOWN. AT036policy16/19,3transientcompileridentitiesUNKNOWN; allrecordedowned/groups empty. Authoritative evidence: E016/R007/AT031_037_staged_delivery.json and three summaries.


## §17 standalone peer AT038/039

XSim2025.2 peer build PASS12.064388511s and RTL PASS6.023939148s. Actual2897AR/23049beats/1475136B matched independent original-GGUF byte oracle; all120/fourport first/tail, threeK/sixshapes, Wi halves, record and superblock/page boundary samples included. Existing8 W576 sampled98560B matched. Peak live25/different-source overlaps522/heldAR4090/heldR3568/heldlast497, final7048cycles. Source Q sign1 covered; all46080scale sign bits0. Cache hits0 leaves hit branch untested. Policy8/8+4/4 and actual cleanup empty; peak ownedRSS173608/852976KiB. No production parser retirement/parent integration/fullEncoder/kind7 or physical result. Evidence E016/R007/binary_peer_actual_evidence.json and current summaries; A012 received heavy window.


## AT040–044 actual boundary

Production W reader_v2/supply_v2/bank_v1 plus on-demand peer build/RTL PASS7.623896713/5.633166350s:1608 cache records/874752B equal direct originalGGUF,908AR/14472R, all908 final parser reservation retirements;368 aggregate lastR-before-parser-idle cycles,32 peak live,786 overlap read cycles. Pure1D completekind5 build AT042 passed55.795852041s; AT043 original60s QKV1 cap COST_STOP60.319911834s after realH/quant/A and matrix BEGIN, zero completedQKV blocks. Its84 runtime+2fixture events match originalAT037 completed prefix; no full backend equivalence.

AT044 source-only rechecked47raw SHA and exact-byte serializations in0.378079660s. New actual30layer/kind6/7 checker87cca31b and binarykind5 successor719e63ca are frozen source-only; no compile/run or full-graph result. Source mapping and actual transport/compatibility evidence in E016/R007/AT038_044_staged_delivery.json and current three summaries. Production remains92RTL+1EXP ROM data, no edits/physical claims; all recorded owned attempts empty and A012 has next window.


Fullgraph checker public-boundary revision2 source677e5bc9 adds per-handshake original marker/CLS out_row checks, full tail_begin request/generation/source_epoch/69632B qualification, and independent SIM tail accepted-identity latches used/asserted during held commit. Prior87cca31b prepared source/metadata, gold and production are untouched; exact SVpart reversal reconstructs old top. New source-only snapshot and minimal patch: E016/R007/fullgraph_public_boundary_v2_delivery.json. No compile or RTL launch for this change.


Residual reference loading repair (source-only): pending1D TB172d3019 and binary-kind5 TB246c2d6a now read all131072 original32bit GOLD words and pack every4096x32lane vector without changing values, simulation delay or assertions. Prior packed-array direct load was invalid; original XSim QKV prefixes had not reached that checker. AT045 independently reconstructed524288B/131072lane against original attention_residual.bin bac04c09…482d8; other49 reference loads remain exact. Oldfrozen/failed versions preserved; fullgraph677e5bc9 and production/gold unchanged. No A010 EDA; same-top source/diff/evidence handed A012. See E016/R007/residual_loader_repair_delivery.json.


## AT047/048 read-only compatibility evidence

Fullgraph677e5bc9/peer4d9265c2/production parent7b0d0c6d are unchanged. AT046 wrong tool-runtime path failed before review and remains recorded; AT047 corrected bootstrap path source audit passed3.795146179s, including15 exact one-dimensional readmemh shapes and inspected unsigned byte FREAD/binary FWRITE/immutable source metadata semantics. No frontend/runtime PASS follows.

AT048 read-only audit1.241986789s found no concrete result-changing risk in exactly3 SIDEEFFECT+2 MODDUP warnings from E021 AT013. Pure input-only automatic tr/tv and3 generated blocks preserve8 sequential dfp increments each. Legacy tile_bank module bodies are identical; service_v1 bodies differ but neither has a current-top instance or generated cpp/h identity. Other513 warnings are unassessed, and the two unused service bodies must not be assumed interchangeable for a future active top. No production/TB edits, EDA or physical result. Evidence: E016/R007/readonly_compatibility_delivery.json and attempts/AT047_fullgraph_fileio_source_review_fixed_path/work/audit/source_review.json plus AT048_selected_verilator_warning_source_review/work/audit/warning_source_review.json.


Context single-credit observer correction: current1D505e0b93 and binary-kind58a4a3956 swap only the original response/read observer blocks to verify old data/tag/credit before installing a same-edge replacement read, matching unchanged production adapter. All identity/order/data/debt predicates and original gold remain. AT051 static exact-reversal/protocol-token audit passed; corrected runtime remains separate A012 work. Old172d/246c and AT033 failure preserved. See E016/R007/context_credit_observer_repair_delivery.json. Fullgraph677e5bc9 is unchanged and has a checked-progress gap before the first final-H endpoint; source/fixture handoff and proposed distinct retirement observer are in fullgraph_progress_source_handoff.json, not implemented.


Fullgraph retirement observation successor8b556ca2 (same top): adds only two64bit simulation counters and real-edge7domain result/ACK observations; each accepted interface event counts1 and every128new events prints M007_RTL_RETIRE_PROGRESS retired=N cycle=C. No clock/state/AR credit, no layer reset, no print without new events. It is separate from original checked-gold words and is not an operation count. Exact observer removal reconstructs677e5bc9;505e mainline/peer/production/gold unchanged. AT052 static source/counter audit passed, no HDL/RTL evidence. Frozen source/event list/source manifest in E016/R007/fullgraph_retire_progress_delivery.json; A012 alone adds future guard strict-marker support, current Encoder driver unchanged.


Peer same-module compatibility successorf4d1c00d: only mainposedge loop expanded0/1/2/3 in same process, exactinverse restores4d92. AT053staticPASS; AT054XSim2025.2 original120tensor bytechecker build5.418817962s/RTL5.610245347sPASS,2897AR/23049beats/1475136B/7048cycles,361semanticlines exactlysameAT039. Originalfixture/gold/production/top8b55 unchanged; cachehit0 remains untested. Source manifests and actual evidence: E016/R007/binary_peer_posedge_unroll_actual_evidence.json. A012 separateVerilator/fullgraph/kind7 evidence not implied.


Same-top fullgraphkind6publicABI successor86629840: only conditionally sets kind7originalmarker/qtype fields vs kind6allzero per existingproductionABI. AT055source-only inverse/fixtureSHA checkPASS0.242143059s; inverse restores8b55 exactly. Gold/assertions/clock/production/peerf4d and currentAT005 unchanged. Frozen94source closure/source-onlydiff: E016/R007/fullgraph_kind6_public_abi_v4_delivery.json. Actualkind6component/fullkind7 notrunbyA010; futureA012evidence separate.


## D36 gamma fix and validated segmented suffix (2026-10-24)

Current parent fixed SHA `9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6`; old-with-entry SHA `cbb821b7c37c1cf75a66ab643c49464e1c64aab0d5c797662c20e90fc54b19b9`. Their only difference is the gamma hold expression. Common rev2 TB SHA `2bd73c51255634e190b0b1c288ccd7150852f555c229218a755d7989fa734f2a`. [Frozen source/audit](../../../../../../E016_m007_single_resource_parent/experiment_results/runs/R007/d36_final_gamma_suffix_source/rev2/source_audit.json) records inverse reconstruction of the original sources, 94 source identities and integer actual-H roundtrip. Rev1 preservation is checked separately. These source checks remain source-only PASS; the actual runtime evidence below was produced by A012, not A010.

| A012 attempt | Actual result | Guard wall |
| --- | --- | --- |
| AT003 old gamma reproduction | Original data assertion FAIL with accepted gamma0; kind/duplicate/offset checks pass, first address0/lane0 | 8.316856 s |
| AT005 fixed finalLN/type/preLN | Final-LN/type each 131072 words match original gold; Decision0 preLN succeeds, planned prefix stop | 35.940923 s |
| AT006 fixed complete suffix | Complete same-runtime SEGMENTED_SUFFIX PASS, normal rc0 | 710.202771 s |

AT006 completed 900800 cycles, both Decision layers, 8 matrices, 32 heads, 5 LN commands (1 gamma plus 4 ordinary), 5 VECTOR operations, 544 output groups/69632 B and one real tail commit. The held DONE was consumed and the real idle check passed. Final-LN, type, Decision0 H and Decision1 H each contain 131072 actual F32 words equal word-for-word to the original gold; the complete tail matches its original mapping and bytes. Root independently reviewed 143 frozen identities, all outputs and both Decision traces. The ordinary LN commands accepted gamma0; natural start-to-command delay is 2 cycles, with no valid-wait cycles. Artificial command backpressure was not exercised.

Evidence: [AT006 RTL receipt](../../../../../../E021_m007_compiled_rtl_validation/experiment_results/runs/R004/attempts/AT006_fixed_complete_suffix/receipt_rtl.json), [root review](../../../../../../../results/reviews/m007_final_ln_suffix_review_20261024.json). The original R003 28-Encoder identities and composite final-gamma FAIL remain preserved; the precise subcondition in that old log is not retroactively observed. This validates the repaired segmented suffix from saved actual Encoder27 H. A repaired whole once-BEGIN30 run, composed end-to-end performance, synthesis/implementation timing and board results remain NOT_RUN. D36 is complete; subsequent work is paused per the user.


## D37 complete original30 once-BEGIN result (2026-10-25)

A012 E021/R005 AT002 passed `FIXED_ORIGINAL30_ONCE_BEGIN` using the unchanged fixed parent SHA `9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6` and TB SHA `2bd73c51255634e190b0b1c288ccd7150852f555c229218a755d7989fa734f2a`, default parameter0 and the original initial_H. The full graph ran in one runtime from one BEGIN, with guard wall **10101.230974940 s**, **13036119 cycles**, normal child rc0 and no guard trigger. Final counts are **30 layers /120 matrices /480 heads /60 LN /61 VECTOR /28 GEGLU /544 output groups**; actual tail_commit1, held DONE consumption and real idle all passed.

All30 actual H endpoints have4096 unique groups each, with actual accepted traces independently reconstructed; the controller checked them and final-LN/type against original gold. Each full-size endpoint contains131072 F32 words/524288 B. The complete544-group/69632 B tail is bit-exact to the original expected mapping, SHA `a8698e55921b0300643a01f63bb38abc52e026af7251b526f02bddfbd6d9536f`. [Actual RTL receipt](../../../../../../E021_m007_compiled_rtl_validation/experiment_results/runs/R005/attempts/AT002_fixed_original30_kind7/receipt_rtl.json) is the authoritative runtime evidence; A010 did not run this experiment or charge E016 runtime.

This D37 result supersedes the absence of a repaired whole-graph run recorded at the D36 boundary. D35/R003 FAIL and D36/R004 suffix evidence retain their original identities and scope. The time above is measured functional-simulation wall time; no physical/board performance, implementation fit/timing or exhaustive error/cancel/reset coverage follows. Documentation closeout is complete; no further A010 experiment or implementation is active/queued.
