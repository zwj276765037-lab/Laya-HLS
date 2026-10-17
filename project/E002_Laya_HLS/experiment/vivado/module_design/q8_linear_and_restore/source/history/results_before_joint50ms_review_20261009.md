# Q8 Linear、恢复与部分和：平台、资源与性能记录

## 2026-10-09：`metadata_reset_v3`首批ACT静态RTL实测与独立验收

在[单一执行门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_static_runtime_release.json)下，冻结[源码包](../metadata_reset_v3/rtl_act_static_v1/source_binding_v1/source_packet.json)（SHA256 `75a0e9f1b5817b5110166a179f7c2ea5c8d263ff6c07bd3dc091c9a7eadcf7df`）执行一次XSim静态构建及legal、fault_load、identity_reset各自独立的准备/运行。七阶段guard、前后源/快照绑定、独立20个`.memh`预期表、原始日志及每模式四个XSim运行文件封存见[总执行证据](../metadata_reset_v3/rtl_act_static_v1/runs/execution_evidence_v1/execution_evidence.json)（SHA256 `688db8be7e769a496e58be85c798b2f1165d3821aff21dc258c30c5033b9eb8a`）；[Astra xhigh整体独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_full_functional_acceptance.json)（SHA256 `c8990f5a4827e7eae4f961dc902607ec96663704e37b440eea0ae2b9cbf9d768`）已接受ACT这36条命令的数值、协议、恢复和暖复位范围。最终[源及快照复核](../metadata_reset_v3/rtl_act_static_v1/source_binding_v1/final_source_and_snapshot_check.json)重hash全部865项源、350项当前快照；编译快照仅四个精确列名的XSim运行文件可变化且均逐模式留存。三组20文件尺寸/SHA、命令顺序和暖复位索引均与[Astra独立预期表](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_prepared_input_expected_hashes.json)逐项一致。

静态构建编译230个生成Verilog、7个现成FP VHDL封装及endpoint/TB共6个SV，`xelab`生成36,164,400B的`q8_act_static/xsimk`，108个原始`.dat`链接和346项编译快照已绑定。16GiB/300s guard退出0、无触发，实际204.701s、峰值owned RSS 4,177,016KiB；4 CPU、nice 19、idle I/O策略及0.2s RSS采样通过。此为可运行静态仿真快照，不是OOC、布局布线或物理时序结果。

| ACT模式 | 命令逐条PASS | 最长/合计测试台命令周期 | 运行guard耗时/峰值owned RSS | 原始日志 |
| --- | ---: | ---: | ---: | --- |
| legal | 9/9 | 6,295 / 37,988 | 14.377s / 859,464KiB | [xsim.log](../metadata_reset_v3/rtl_act_static_v1/runs/rtl_legal_v1/prepared/xsim.log) |
| fault_load | 3/3 | 6,290 / 15,649 | 9.474s / 859,524KiB | [xsim.log](../metadata_reset_v3/rtl_act_static_v1/runs/rtl_fault_load_v1/prepared/xsim.log) |
| identity_reset | 24/24 | 6,295 / 79,332 | 21.229s / 859,504KiB | [xsim.log](../metadata_reset_v3/rtl_act_static_v1/runs/rtl_identity_reset_v1/prepared/xsim.log) |

三模式guard均退出0、无触发，进程策略全匹配，20,000/250,000周期看门狗均未触发；这些是测试台有限失败界限，HLS顶层时延报告仍为未知。每条日志的`cycles`从`CASE_START`准备至完成CSR回读/`CASE_CHECK`，包括AXI-Lite、AXI适配器、端点等待和测试台检查，不能当作纯DUT/kernel吞吐。legal第3号RUN的最后activation R为第16次、保持20周期，最后out0 B为第2次、保持17周期。identity_reset在真实已写单元上抽查暖复位保留：WQ地址`0x0000`、A8地址`0x000`、FP输入缓存地址`0x0010`，原始位型见日志；FP输入样本`0x80000000`为原始位型非零的浮点负零，不能表述为数值非零；PS未做动态保留抽样。全部输入页、observed、out0/out1和九端口双侧AXI退休/字节数按命令检查。当前独立验收只覆盖ACT K256/N2/rows1这36条静态RTL用例；完整矩阵/整网、OOC、物理时序、U55C上板与50ms端到端性能均未验收。

## 2026-10-09：`metadata_reset_v3`局部综合与复位结构

Vitis HLS 2025.2对隔离`metadata_reset_v3`完成一次已放行局部综合，guard退出0、无触发，耗时277.474s，峰值owned RSS 3,995,644KiB，最低MemAvailable 446,867,460KiB。完整[综合证据](../metadata_reset_v3/runs/csynth_local_v1/synthesis_evidence.json)与[独立Astra xhigh审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)封存3,581个工作文件、1个实际预处理翻译单元与241项真实依赖。生成顶层Verilog/VHDL、IP和各230个`syn` Verilog/VHDL文件；实际AXI数据宽度为activation/q0/q1/scale各512bit，descriptor/aux/out0/out1/observed各32bit。

HLS报告估算LUT 156,176、FF 117,625、DSP 40、BRAM18K 341、URAM 256；目标6.67ns，估算21.308ns，顶层时延/吞吐未知。生成结构审核确认21个State标量寄存器具有同步`ap_rst_n`复位/默认值，一个源码只写`dst_epoch`被优化掉，tag有效位图复位清零且无效项回退零；payload RAM没有批量清零。该结论限局部综合与生成复位结构，尚无RTL数值、静态/运行时AXI、OOC、布局布线/时序闭合、完整核或上板验收。前版原文保留于[history](history/results_before_q8_v3_synthesis_20261009.md)；下方v1记录为其原阶段历史。

## 2026-10-08：活动隔离原型 q8_joint_tm4tn8_v1

[当前设计](design.md)已将修复合同§4.4–4.7/7.14映射为TM4/TN8/GS32联合原型：冻结模型BO真实装载、8lane量化、完整K/N、R0恢复/PS与输出退休。首批ACT真实fixture、冻结源码、严格CPU及标准libm CSim双例均由Astra xhigh独立验收。首次局部综合在源检查阶段失败，未产生调度、RTL或可用资源结果；隔离tag_direct_v2仅获源码准备门。当前没有本原型OOC、时序或板测结果；下文旧04934/P0/P1/F0数据保持其原身份，不能当作原型资源或性能。此前本页原文精确保留于[history](history/results_before_joint_prototype_mapping_20261008.md)。

| 项目 | 活动预算/要求 | 证据状态 |
| --- | --- | --- |
| 器件/时钟 | xcu55c-fsvh2892-2L-e，150MHz/6.667ns请求 | 未综合，非Fmax |
| 整数并行度 | 32 dot/issue、1024 S8乘法贡献/issue | 设计值；实际I/吞吐未知 |
| R0服务率 | 每理想issue 32 I32→F32、64 F32乘、32 F32加；严格非FMA | 映射/共享/DSP用量未知 |
| 片上供给 | W256B、A128B、scale24B/issue，PS各128B读/写；A可在g内复用 | 真实RAM端口/广播/反馈未验证 |
| 模型/激活端口 | q0/q1/scale/activation显式512bit；每口1 outstanding、burst≤16且不跨4KiB | 需要实际RTL接口审核 |
| 输出端口 | out0/out1首版U32、允许真实32bit写；aux/descriptor/observed按实际宽度报告 | 不能记为512bit；N2仅8B有效写 |
| 诊断观察 | 最大32768 U32外部缓冲；完整A8及一个选中输出全G trace | 不额外算成片上存储，实际实现若暂存须计资源 |

各逻辑缓存容量：W q5,373,952B、W scale335,872B、A q65,536B、A scale4,096B、FP输入262,144B、PS83,968B、bias20,992B，总6,146,560B（5.8618MiB），另加控制/tag/FIFO/管线。W最大每bank20992word，不能用最大N×最大G扩成83968。示例URAM按256bit用4宽×6深×8bank为192块；scale按18bit×2048 BRAM36为88块。这些只是可复算拼接示例，所有原语粒度/碎片、RAM读延迟、LUT/FF/mux、FP资源和Fmax须用同一实现的真实报告确定。未知shell余量保留未知；单原型OOC不能证明完整核放得下。

令R=rows、G=K/32、T=ceil(N/8)、I为实际issue II、F为PS读请求到写提交后安全重读的窗口。每次RUN的有效整数工作量为R×N×K MAC，发射槽数为ceil(R/4)×G×T；尾行/尾列浪费仍计真实周期。group步进下界为max(T×I,F)，必须另计首尾、bias/排出和反压；不能把槽数当实际cycles。量化两遍扫描理想2×R×K/8拍，另计输入装载、统计/倒数/half服务及尾延迟。首版阶段串行，LOAD含q0、q1、scale解包、bias和头检查各阶段相加；RUN含activation读取/两拍解包、量化、compute/反馈、输出与真实响应完成。各段均由真实工具/退休事件计时，工作计数不冒充硬件周期。

每个scale512bit返回32half，8单写口bank需至少4拍解包；activation宽拍需2拍；q宽拍只写2个256bit word。512bit@150MHz每口9.6GB/s、32bit每口0.6GB/s均为原始上限，不是有效带宽。普通矩阵首版写out0，每R×N个F32即使每拍1个也至少R×N拍，AXI请求/响应与非连续QKV散写另计。trace关闭时测性能，trace开关必须在同一制品内且不改变输出数值；全部真实执行成本要列出。

首批ACT K256/N2/R1：实际q0 2048B、q1 0B、scale128B、bias8B，另读真实模型头；activation1024B，最终输出8B。G8/T1，8个issue槽，每槽只有1行×2列有效，占TM4/TN8槽的6.25%；完整512 MAC必须全部执行。两次RUN复用同一W并分别trace n0/n1；记录W装载一次、activation两次，不用重复LOAD制造复用结论。完整A8和全部final逐位对照，ACT两次trace覆盖所有group中间值；后续大矩阵所选trace与全lane退休scoreboard范围分别报告。

TM4/TN8理想1024 MAC/拍即使无任何其他开销，B1/S128的47.160754688GMAC也需307.04ms，B2需614.07ms，不能达到50ms。该原型的目的为取得实际bank、恢复、反馈、带宽及资源系数，再决定后续架构；扩大阵列须重新核验所有通路。原型资源与新完整核/shell资源分别记录，不与旧04934结果拼接。

| 验证阶段 | 当前执行门与预算 | 接受条件 |
| --- | --- | --- |
| 源码/ABI/fixture | 冻结并经独立源审；生成/CPU执行每次8GiB/300s，CPU构建16GiB/600s | [源码/CPU包](../runs/cpu_act_v1/source_binding_packet.json)与[独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_source_cpu_csim_release.json)；仅首批ACT范围 |
| 首批CPU | ACT真实fullK256/N2/rows1及同W复用、trace、拒绝/恢复已通过；其余矩阵待扩展 | [legal原始日志](../runs/cpu_legal_v1/guard6/driver.log)、[fault_load原始日志](../runs/cpu_fault_load_v1/guard3/driver.log) |
| CSim | 标准libm、strict FP的legal与条件fault_load各一次均通过并经独立验收；每例16GiB/600s | [双例证据](../runs/csim_pair_v1/evidence_packet.json)、[独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_csim_pair_review.json)；仅首批ACT C模型范围 |
| 局部综合 | v1一次16GiB/1800s门内运行于源检查失败；tag_direct_v2仅源码准备，后续综合未放行 | [失败证据](../runs/csynth_local_v1/failure_evidence.json)、[独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_local_csynth_failure_review.json)；无调度/RTL/有效资源结果 |
| RTL/static/OOC | 未放行；保留50Mcycle watchdog但不自动运行 | 实际schedule/接口/页/内存和同环境进度确定wall/RSS预算 |
| 集成/平台 | 本批不产生验收 | 新身份完整请求RTL与同源资源，板卡条件具备后板测 |

所有重工具限本Laya工作流串行、4CPU、nice19、idleIO、0.2s RSS采样和MemAvailable≥192GiB；不触碰无关服务。当前Attention修正/诊断已排队工具优先，源码及只读准备可交错。每阶段保存实际全部输入SHA、命令、工具、日志、退出码、RSS/策略及失败原件；源码或接口变化重新绑定受影响证据。

### 首批ACT CPU实测与边界

最终顶层[`q8_joint_tm4tn8.cpp`](q8_joint_tm4tn8.cpp) SHA256 `2f0f42da242f697eb3009fe56db174763fa29c2599a508182bb29bf2a3237531`，严格TB[`test_q8_joint.cpp`](../tb/test_q8_joint.cpp)与完整模型/描述符/独立oracle均由[冻结绑定包](../runs/cpu_act_v1/source_binding_packet.json)逐项给出；该包SHA256 `37289d4ee9eb6d59349f8353816705ef8f50001c40f3bf8bfff78f87bf06b327`。当前源码将W q/scale、FP、A8 q/scale、PS及bias分bank，并为PS每bank/tile保留32×656的`lane_bad`控制图；HLS指令仅为请求，尚无真实bank原语、II、DSP、AXI位宽或cycle报告。

最终严格CPU构建、legal及fault_load guard均退出0、无触发且采样进程策略匹配。legal日志报告`Q8_JOINT_ACT_STRICT_CPU_PASS legal=4 trace=2 rejects=3 quant_fault=1 recovery=1`；fault_load独立进程报告`Q8_JOINT_ACT_FAULT_LOAD_RECOVERY_PASS`。[独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_source_cpu_csim_release.json)接受两个batch的全部256个A8字节、8个half scale、两个最终F32逐位对照，以及batch0的n0和batch1的n1各8组dot/sa/sw/product/term/PS trace、bias、同W复用、trace关闭恒等和哨兵。前置身份/任务拒绝不消耗claim；量化i2/i7双NaN选择i2且只退休quant，下一合法命令恢复；复合LOAD在scale n0/g1、n1/g0及bias n0并发故障中按规范选n0/g1并成功恢复。构建采样峰值217660KiB/3.361s，legal3932KiB/0.418s，fault_load3992KiB/0.425s；TB特意停留300ms供RSS采样，这些不是纯计算时间或硬件时延。

### 首批ACT标准libm CSim实测与边界

[legal验证](../runs/csim_legal_v1/validation.json)与[fault_load验证](../runs/csim_fault_load_v1/validation.json)在Vitis HLS 2025.2/clang-16执行，生成Makefile证实`csim.stdmath=true`、链接`-lm`，源码和TB均使用`-fno-fast-math -ffp-contract=off`。两次guard均退出0、无触发、实际进程策略匹配且CSim错误数0；legal输出`Q8_JOINT_ACT_STRICT_CPU_PASS legal=4 trace=2 rejects=3 quant_fault=1 recovery=1`，fault_load输出`Q8_JOINT_ACT_FAULT_LOAD_RECOVERY_PASS`。legal耗时15.184s、峰值owned RSS 1,308,292KiB；fault_load耗时15.097s、峰值1,302,144KiB。[双例证据包](../runs/csim_pair_v1/evidence_packet.json)重新校验每例37项冻结输入、全部原始文件及相同的30文件生成依赖闭包；[独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_csim_pair_review.json)接受首批ACT范围。CSim没有产生实际RAM原语、调度II、接口/AXI、DSP映射或RTL数值证据；这些留待分别验收。

### 首次局部综合的实际失败

v1经[配置门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_csynth_config_release.json)仅运行一次；[失败包](../runs/csynth_local_v1/failure_evidence.json)保留完整76个工作文件、9个部分IR与241个实际预处理依赖。Vitis HLS 2025.2在`tag_matches`及LOAD模型头检查处报两个`HLS 214-134`：局部`const uint8_t* expected[4]`动态取`expected[t][j]`不支持。guard退出1、无触发、35.096s、峰值owned RSS 1,696,392KiB。部分`csynth_design_size`不能作为综合资源；本次没有可用调度II、时延、实际RAM/DSP/AXI端口或生成RTL结论。`tag_direct_v2`按[独立源码准备门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_tag_direct_v2_source_preparation_release.json)只允许隔离两处直接tag数组索引；新CPU、CSim和综合均需各自审核与放行。

本次只验ACT K256/N2/rows1及选中列的逐组trace；QKV、K2624/K4096/N5248、多行尾、全部lane逐组中间值、一般线性错误排序、物理AXI突发/响应退休、资源与50ms目标均未验收。此前q0/q1 BO-size索引反转造成的preflight失败日志原样保留于绑定包，不被最终PASS覆盖。

## 2026-10-08：此前性能原型待实施规格

当前生产F0仍为串行Q8 leaf；179–199cycles/group的旧调度只用于成功源码图的条件外推，完整旧RTL还存在控制语义缺陷。功能表示修复没有增加并行算术，不能据此声称50ms达标。

后续具体工程为[修复合同§4.4–4.7](../../../../results/attention_rtl_repair_20261008/repair_contract.md)的TM4/TN8联合Q8原型：完整K/N、冻结BO装载、8lane两遍量化、W/A/PS实物banking、R0恢复反馈与真实写响应退役一起实现和验证。当前已获[独立设计审核](../../../../results/attention_rtl_repair_20261008/reviewer_joint_q8_prototype_design_review.json)接受为后续设计；尚未放行实现，无原型CPU/CSim/RTL/OOC数据。首个原型不是原§16×8候选的已实现版本，也不修改本轮生产controller补丁。


本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入A8/scale、W8/scale和bias，窗口最多16×8，输出F32[rows,N]；按完整K/N循环，QKV按plane/head散写。

已生成compute_one每32项dot160cycles，含恢复/累加group179–199cycles；active leaf24.12–26.82MMAC/s@150MHz。实际两份leaf按同步图调用，不可把完整图预算除2。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-q8_linear_and_restore)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

P2早期状态（2026-10-07，当时F0功能验证通过）：真实完整K/N的Q8 Linear、bias恢复和QKV散写已实现，十种矩阵及完整CPU/CSim通过。 当时模型包build tag为`4f12ecfe940ecf2a8998a8626fc1ed1c`。完整top物理综合、平台与性能阶段单独判定。

| P2早期阶段 | 结果与范围 | 直接证据 |
| --- | --- | --- |
| P2实际实现 | 已有完整责任源 | [完整Linear任务](../../../../hls/operators/full_tasks.cpp)；[本模块设计与源映射](design.md)；[完整编译源](../../../../config/full_sources.cmake) |
| P2早期完整CPU | 真实B2/S128与两题重基B1各47点，共18,094,384个F32逐位一致；同Runtime成功→已接受故障→两次恢复 | [正式门禁](../../../../results/engineering_p2/full_cpu_final_20261007/full_final_gate_report.json)；[逐文件/事件/错误帧机械复核](../../../../results/p2_environment_20261007/final_functional_mechanical_check.json) |
| 实际调度计数 | B2/B1/B1退休37158/18895/18895；各28 Encoder＋2 Decision；B2 Quant/Linear各1924，W122、KV480、RoPE表28 | [持久运行元数据](../../../../results/engineering_p2/full_cpu_final_20261007/dut/full_forward_dut_run_report.json)；预期与actual分列，故障17任务另计 |
| 本模块补充 | 10种完整K/N、329730个F32；scorer b1采用合法全B lease且禁止未完整commit | [十矩阵任务](../../../../results/engineering_p2/full_cpu_final_20261007/matrix_dut/full_matrix_dut_report.json) |
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

本模块具体推导依据[09](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md)、[05](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md)、[08](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md)与02/15。除特别注明外，服务cycles取无停顿、满足端口/反馈条件的理想发射率1；150MHz时每cycle约6.667ns。GB/s使用十进制，KiB/MiB使用1024进制。0.65若用于HBM带宽或算术效率必须分别注明，不能当成同一个实测参数。

## 2. P0历史：条件性能、带宽与容量估算

### 候选服务周期与片上带宽

M16、TM16/TN8/GS32、无停顿且每group/output-tile可每拍issue：

| 矩阵K→N | 量化2遍 | dot/group累加 | 8lane读出 |
| --- | --- | --- | --- |
| QKV1024→3072 | 4096 | 12288 | 6144 |
| Wo1024→1024 | 4096 | 4096 | 2048 |
| Wi1024→5248 | 4096 | 20992 | 10496 |
| down2624→1024 | 10496 | 10496 | 2048 |
| Decision FC1 1024→4096 | 4096 | 16384 | 8192 |
| Decision FC2 4096→1024 | 16384 | 16384 | 2048 |

公式：量化`2×M×K/8`；主矩阵dot`(K/32)×ceil(N/8)`；读出`M×N/8`。不足TM、N2反馈、浮点尾、装载与停顿另计。4096×150MHz=614.4GMAC/s仅整数贡献峰值，恢复和PS必须同步供给；4096不等于4096 DSP。

片上每issue读A512B、W256B、scale48B；PS读/写各512B。150MHz分别要求76.8/38.4/7.2/76.8/76.8GB/s。PS双bank671744bytes＝0.640625MiB；资源估计需同时考虑宽度分bank、加法树、恢复、FP累加和广播布线。


这些数据的证据状态均为推断/条件计算；已知shape/字节数来源于模型与原规格。它们不包含尚未明确的IP延迟、实际II、首填/排空、互连及背压成本，除非公式明确单列。性能承诺需要后续实现与同配置实测。

## 3. P0历史：候选资源归属

双PS671744bytes；A/W存储见统一缓存表。DSP/LUT数量与R0/R1及packing相关，当前未估算到可验收的物理资源。

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
| P0主机端合同CTest | PASS：总回归20/20，含`contract_q8_linear_and_restore` | [ctest.log](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)；Release构建[日志](../../../../results/engineering_p0/20261005T154135Z-3872886/build.log) |
| 候选数值参考/HLS C仿真 | 未执行 | P0当时没有数值核及完整forward；已由页首P2状态取代 |
| RTL/XSim或协同仿真 | 未执行 | P0当时仅有C++契约TB；页首及P2实际运行记录为当前状态 |
| HLS/合并综合 | 未执行 | 无资源、真实II及端口报告 |
| 布局布线/时序 | 未执行 | 无xclbin或当前实现报告 |
| U55C功能/稳定性/性能 | 未执行 | 无本模块或整网板上数据 |

后续每次运行按“编号、源码/约束/IP/输入hash、平台/工具/clock、shape、命令、日志/报告、退出码、用例数/seed、结果及局限”登记。失败和未测项保留，不用其他工程的PASS、历史软件成绩或估算代替。

## 6. P0历史：当时的后续证据

- G4 DSP packing、恢复成本、Lacc、RAM绑定/真实II和Fmax；G3 R0/R1参考。

获得真实结果后按对应配置追加，保留估算与测量差异及原因；修改design.md中的接口/数值/调度后，原测量是否仍适用必须重新判断。


## 本次接口与真实软件参考更新（2026-10-05）

接口字段与联合约束已由GPT-6 Astra（xhigh）细化到[design.md](design.md)§10–§11。真实Typed Q8 CPU原生采集及ABI回放已建立，入口为[abi_replay manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)；这证明参考数据来源，不是本模块硬件通过结果。native与候选算术的对齐及全部硬件验证阶段仍未执行；P0主机端合同TB已按上表执行；既有150MHz/阵列/资源/周期数保留候选或条件估算状态。

## P0审核中的未验收关联（2026-10-05）

当前实现核对LinearTask的op/WeightKey/stage/行空间/K/N/目的region、输出数量、N2尾列和DotIssue字段；状态辅助检查只核对A8/W的epoch及Q8_TILE/Q8_WEIGHT内容类型。尚未把A8的K/rows/batch/row0/row_space及源epoch、W的WeightKey/K/N与当前任务逐项关联；该绑定、PS反馈退休和真实点积/恢复运算必须在后续计算链前补齐。

本机20/20合同测试通过仅适用于上述已实现检查。详细边界见[design.md](design.md)§12；最终审核及独立38项检查见[任务记录](../../../../hardware_agent/task.md)§10.8和[审核日志](../../../../results/engineering_p0/20261005T154135Z-3872886/review/review.log)。未完成项保留为后续计算链接入前置要求，不计入本次PASS。

## P1数值切片预算与验证待办（2026-10-07，Astra xhigh）

依据[task.md §11](../../../../hardware_agent/task.md)和本模块design新增细化。本节只登记新设计预算；Sol执行后追加准确配置、源/数据hash、命令、日志、统计及分阶段结论，保留P0历史。

A8共享接口69632B；W窗口8×128×34=34816B；slice输出16×8×4=512B；局部单个I32 dot/F32 acc及标量状态。操作贡献数rows×cols×K，恢复/acc次数rows×cols×K/32；这些是算量，不是周期或4096并发MAC成绩。

候选isolated HLS器件为本机catalogue的`xcu55c-fsvh2892-2L-e`，请求150MHz/约6.667ns只作实验配置；实际U55C part/platform/shell仍未冻结。Vivado/Vitis 2025.2可用，器件查询见[环境证据](../../../../results/p1_environment_20261007/query_parts.log)。本节写入时CPU数值/独立参考联测、HLS CSim、isolated综合均未执行；RTL cosim、布局布线/时序、xo/xclbin、U55C上板均未执行。LUT/FF/DSP/BRAM/URAM、Fmax、II和延迟未测，禁止用上述容量算式当作资源结果。

## P1实际运行与阶段结论（2026-10-07）

最终版代码、配置和数据身份见[CPU源哈希](../../../../results/engineering_p1/20261007T021236Z-1800667/source_hashes.sha256)、[HLS源哈希](../../../../results/engineering_p1/20261007T021255Z-1801905/source_hashes.sha256)及[fixture逐项报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)。命令、版本、完整日志和退出码存于各run目录。

| 阶段 | 实际结果 | 证据与边界 |
| --- | --- | --- |
| CPU Release直接TB | `numeric_q8_linear_and_restore` 57例通过；configure/build/CTest退出码均0 | [CTest日志](../../../../results/engineering_p1/20261007T021236Z-1800667/ctest.log)；含±127极值、抵消、signed-zero、2²⁴/1/−2²⁴组序反例、K4096/128组末项、A8/W逐字段与双ref生命周期 |
| 真实模型离线数值 | 30个真实切片的全部row/col/group共132128组，dot、term、partial及最终窗口输出均与独立oracle逐位一致 | [fixture日志](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture.log)、[逐项报告](../../../../results/engineering_p1/20261007T021236Z-1800667/fixture/numeric_fixture_report.json)；覆盖QKV/Wi/down/act N2及真实bias，GGUF完整K/N范围和窗口均核验hash；另有直接TB的固定K4096补充用例，不是Decision真实链 |
| Vitis HLS 2025.2 isolated CSim | Linear窗口直接TB 57例通过；CSim退出码0 | [csim_linear.log](../../../../results/engineering_p1/20261007T021255Z-1801905/csim_linear.log)；clang-16，实验器件`xcu55c-fsvh2892-2L-e`，150MHz请求 |
| 本模块isolated HLS综合 | 未执行 | 本轮最小综合只覆盖Group32量化入口，Linear资源/时钟/II无本模块报告 |
| RTL cosim、布局布线/时序、xo/xclbin、U55C上板 | 未执行 | 完整矩阵输出发布、QKV scatter、生产PS反馈和实际平台接口仍待集成 |

P0独立回归在[20261007T021407Z-1804638](../../../../results/engineering_p0/20261007T021407Z-1804638/ctest.log)维持20/20。本轮仅完整K的8列内部算术窗口，不能把slice成功视为整张Linear TaskDone；旧§2的TM16×TN8吞吐预算并非当前串行切片测量。


## P2 B批存储与搬运预算（2026-10-07，Astra xhigh）

PS335872B最大，W按loader统一5709824B计一次，tile输出接口不另实例化整tensor。每tile算量rows×N×K，恢复次数rows×N×K/32；串行完整计算不是TM16×TN8性能承诺。

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

本模块按[完整综合结果](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/full_csynth_result_04934.json)及[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)定位到同一25源、13口顶层；模块责任源与接口仍见本模块[design.md](design.md)。Q8矩阵与恢复算术文件逐字不变；固定cache访问器和打包仅改变存储组织，不改变Q8位模式、缩放/偏置顺序或F0发射合同。

| 阶段 | 现行tag实际结果 |
| --- | --- |
| 身份与CPU | 103项当前源码身份仅五个获准控制文件相对f1a变化；9个算术文件、GGUF权重payload不变。27/27 CTest、75项数值正例+1项既有预期拒绝、141个逐位前向检查点及持久故障恢复通过。[功能汇总](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/functional_chain_summary.json)。 |
| synthesis分支与Vitis CSim | 定义`__SYNTHESIS__`的25源shadow四次同进程调用、72个F32值通过；真实13口CSim核对47点、9,047,192个F32值和37,158任务，0错误。 |
| 完整顶层HLS综合/RTL | 新tag实际`SYNCHK`为0错误、1警告，完整综合退出0；顶层Verilog/VHDL、IP和报告已生成。进程树RSS采样峰值9,508,924KiB（9.068GiB），保护未触发。[封存工件清单](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/csynth_full/artifact_manifest.json)。 |
| 资源与时序边界 | **HLS估算**LUT 1,813,717（U55C容量的139%），顶层估算slack −0.07ns；当前资源预算未满足，202.58MHz只为工具估算Fmax，不能声称物理适配或时序通过。完整RTL cosim、物理综合/P&R、平台链接、上板和性能测量均未执行。 |
