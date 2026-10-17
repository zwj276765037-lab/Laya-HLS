# D2真实Attention数值/owner切片：结果

当前结论：官方fe067完整CPU、综合存储宏路径和真实13口B2/S128标准libm CSim已获独立接受。D2-R v2两次与v3一次XSim均因任务树RSS上限停止，0/1事务、实际返回TV为空，无数值RTL通过或失败结论。v3的CSim/csynth/setup/xelab与运行绑定审核已完成；实际内存增长阶段尚待定位，不能从117000的一行低频进度认定仍在初始化。完整top HLS及整网RTL功能均未放行。

历史初始状态（2026-10-08）：方案已获独立Astra xhigh原则审核并放行局部实施；CPU/CSim/csynth/RTL均未执行。范围和证明边界见[design.md](design.md)。

结果须分别列D2-C生产完整控制/owner软件证据、D2-R真实Attention切片RTL、D2-I修正控制表示的生成路径证据；不得合并称整网RTL通过。记录QKV输入SHA/shape、独立gold、所有实际sources/config/TB、工具与守护、各阶段数值/状态/coverage及cycle。失败例和未执行范围保留。

## 生产补丁与D2-C新身份进展

生产P1/P2/P3等价表示已通过[独立代码审核](../../reviewer_production_patch_review.json)并经[正式同步审核](../../reviewer_official_sync_review.json)确认。正式controller SHA256为`23e428c81c7a4c40c7014db15e34c561958d88d53e40ac71abef8be0d4804623`；正式新包`Laya-baseline/build/model-attention-rtl-repair-20261008`的build tag为`fe067c8aa0627ad770096f9721394645`。模型/数字/布局tag未变。

[正式CPU门禁](../../d2_cpu_full_official/full_final_gate_report.json)已输出`P2_F0_CPU_FUNCTIONAL_READY_CURRENT_BUILD`，`final_gate.exit=0`：真实B2/S128与两次B1共141检查点，含1次已接受故障恢复。此处记录执行结果，独立运行审核另列；当时该CPU门禁未验证CSim/RTL；本页后续13口CSim记录属于独立新run，D2-I生成控制路径与D2-R实际Attention RTL仍未验收。

隔离副本`Laya-repair-20261007`同名包的tag为`18366c267ae0a7ca0c3afb8c2174b890`，其[CPU记录](../../d2_cpu_full/full_final_gate_report.json)单独保存；正式源多一个纳入身份的性能采集工具，故两tag不同。旧04934完整HLS/RTL/IP与OOC没有此补丁。D2设计正式审核对应[精确合同快照](../../contract_snapshots/d2_reviewed_contract.md)，SHA256 `a14cde859c6f0f4a5fad55f8b3f3fc1662005323b801de8d21fbac5f90dbb893`。

## D2-C综合存储宏路径与D2-R首例软件验证

| 实际阶段 | 当前证据 | 范围/边界 |
| --- | --- | --- |
| 官方完整CPU | [门禁](../../d2_cpu_full_official/full_final_gate_report.json)，141检查点及故障恢复通过 | 当前fe067生产源码完整图的软件证据 |
| 官方`__SYNTHESIS__`存储宏路径 | [shadow_report.json](../../d2_synthesis_shadow_official/shadow_report.json)，`FULL_SYNTHESIS_SHADOW_PASS`、编译/运行均exit0 | 真实13参数top、25份生产源；4调用含3成功与1故障，B2/B1/B1任务数37158/18895/18895。仍为CPU执行，非生成RTL |
| D2-R首例CPU | [首例TB](../tb/test_attention_slice.cpp)执行通过；详细已持久日志以Vitis CSim行作为本表可查成功记录 | B1/S64，Decision0，head0，query0，仅4个真实task |
| D2-R首例Vitis标准libm CSim | [日志](../runs/csim_work/logs/hls_run_csim.log)与[守护结果](../runs/csim_guard/guard_result.json)，exit0，`D2_ATTENTION_SLICE_PASS qkv_bytes=786432 score=64 prob=64 av_exact=64 tasks=4` | 真实QKV字节写入/coverage/publish→LOAD_KV→QK→Softmax→AV；QK精确，softmax既定容差，AV按实际prob精确并另验端到端容差 |
| D2-R首份csynth | [原始报告](../runs/csynth_work/hls/syn/report/attention_slice_csynth.rpt)与[守护](../runs/csynth_guard/guard_result.json)，exit0 | 首份尚缺显式AXI depth；旧制品保留，补depth后重跑受影响CSim/csynth再考虑RTL |
| D2-R首例Verilog/XSim | v2已尝试两次，均在0/1事务时触发RSS守护；输出TV为空 | 未产生数值结论；v3后续须重新审核生成绑定再执行 |
| D2-R后续shape/head/RoPE/负例 | 未完成 | 首例软件通过不满足D2完整出口 |
| D2-I生产控制表示可达生成检查 | 待证据 | D2-R不调用controller，不能填补此项 |

首例源为[attention_slice.cpp](attention_slice.cpp)，配置为[config.cfg](../config.cfg)。输入来自真实native Decision0 QKV `ir_1415`的第0题前64行，shape `[1,64,3072]`、786432B，SHA256 `ce3f0ee0969b2e1493730b6d4fd75912d113b0e37130a0196df9771713051406`；[fixture报告](../tb/fixture_b1_s64_decision/fixture_report.json)保存原capture/model/request及全部gold身份。输入全16head/3plane实际写入两QKV BO后才登记完整覆盖；输出只写head0/query0的64值，完整ATT_OUT publish按预期E_BUFFER，邻head/行及尾部sentinel不变。这里只验证真实模型中间张量算子切片，不证明整S64推理、上游Q8投影或全controller RTL。

宏路径守护耗时154.911s、采样峰值RSS601688KiB（约0.574GiB）；首例CSim为14.979s、1253692KiB（约1.196GiB），均exit0、未触发守护。这些是主机工具运行数据，不能换算成FPGA latency或资源。日志对应已执行范围保留，后续真实RTL数值/owner与AXI证据尚未获得。

## 首份csynth实际报告与cosim前补充

首份局部综合已完成：159904 LUT、41491 FF、20 DSP、78个BRAM_18K、0 URAM；5.158ns为HLS估算（请求6.67ns、uncertainty1.80ns），不是布局布线或板上频率。顶层latency/II为`?`，不得把动态循环的通用最大值当该B1/S64合法输入的实际cycle。fixture装载的3072个plane/head/row块，每块256字节输入复制768cycles、full_write2305cycles，二者小计约9.44Mcycles，此外仍有owner、parse、LOAD_KV与数值/AXI等待。

首份综合守护为311.395s、峰值4204536KiB（约4.010GiB），exit0、未触发守护。审核指出cosim前须显式给7个AXI数组与TB一致的depth；后续v2已另目录完成受影响CSim/csynth并进入受限XSim；本段保留首份综合当时的状态。此记录不是RTL放行结果；有限首例仍限制5e7cycles/30min，并由新制品报告审核后启动。

生产controller可达生成检查的具体后续入口现已确定，见[ D2-I设计](../../d2_controller_reachable/source/design.md)及[主合同§7.6](../../repair_contract.md)。执行顺序为先本D2-R首例有限RTL，再I-L/I-V局部构建；都不启动完整graph HLS。

## 已落盘的独立分项审核

[官方完整CPU审核](../../reviewer_d2_c_official_cpu_review.json)为`ACCEPT_D2_C_OFFICIAL_NATIVE_CPU_SEGMENT_ONLY`，核验实际编译/源码/身份与141检查点；[综合存储宏路径审核](../../reviewer_d2_c_shadow_review.json)为`ACCEPT_D2_C_OFFICIAL_SYNTHESIS_STORAGE_SHADOW_CPU_SEGMENT`，确认4帧与原生CPU逐byte相同、成功输出与独立oracle逐位相同。[首例source/fixture/CSim审核](../../reviewer_d2_r_first_case_source_review.json)接受该首例软件边界，未接受数值RTL功能。

[首份csynth成本门槛审核](../../reviewer_d2_r_csynth_cost_gate.json)允许在补齐显式AXI depth并复核新制品后，进行一次有守护的首例RTL试验；10–20Mcycles仅为合法首例的非约束规划区间，实际5e7cycle cap保持。上述审核不覆盖D2-I、Encoder/更多shape/head/负例、完整top HLS、布局布线或性能。

## D2-R v2：两次RTL试验因主机内存守护停止

| 实际尝试 | 任务树RSS上限 | 耗时 | 采样峰值RSS | 主机最低MemAvailable | 结果 |
| --- | ---: | ---: | ---: | ---: | --- |
| [v2初次XSim](../runs/depth_v2/xsim_guard/guard_result.json) | 8 GiB | 420.801 s | 8393560 KiB | 438787452 KiB | exit -9，owned_rss_at_or_above_limit |
| [v2审核后重试](../runs/depth_v2/xsim_guard_16g/guard_result.json) | 16 GiB | 735.542 s | 16778056 KiB | 414352912 KiB | exit -9，同一RSS守护原因 |

[独立最终审核](../../reviewer_d2_r_16g_final_review.json)决定`D2_R_DEPTH_V2_RTL_INCOMPLETE_RESOURCE_LIMIT_NO_NUMERICAL_CONCLUSION`。两次均未完成唯一事务，显示0/1，输出TV为空，生成C postcheck未运行完成；没有可报告的事务latency，cycle watchdog也没有触发。这里是测试向量/仿真基础设施阶段的资源停止，不能登记为QK/Softmax/AV数值失败或通过。AXI/UVM存储开销是待验证的原因解释，不冒称已经独立证实的唯一根因。v1/v2源码、配置、原始TV、失败日志与审核继续保留。

## D2-R v3：诊断AXI depth按实际访问与哨兵收敛

[独立v3设计审核](../../reviewer_d2_r_depth_v3_design_review.json)只放行源码冻结、CSim/csynth和cosim setup；实际RTL仍须新生成接口/包装器/TV/watchdog绑定审核。变化仅限下表4个depth值（QKV两口各算一项）和两QKV末端64B的A5哨兵检查；生产FullMemory容量、完整host数组、张量数值、owner/算子与其余断言不变。

| 口 | v2序列化depth | v3序列化depth | 实际访问/验证边界 |
| --- | ---: | ---: | --- |
| AUX，U8元素 | 1671872 | 128 | 此Decision切片仅检查模型头0…127，不加载RoPE/LN/权重AUX数据 |
| QKV0 / QKV1，各U8元素 | 各12582912 | 各10240064 | 生产B2/S1024固定stride下，本例最大访问exclusive地址10240000；再保留64B A5哨兵 |
| ATT_OUT，U8元素 | 8388608 | 4100 | 实际64个F32输出0…255；邻head哨兵及下一row4096…4099均包含 |
| fixture / io / observed | 786432 / 32768 / 256 | 不变 | 前两者按U8，observed为256个U32，含全部观测与尾哨兵 |

序列化payload由36046528B降到21304580B，不能保证XSim因此必然低于16GiB。16GiB树RSS、192GiB主机可用内存下限、4CPU、30min、5e7cycles和单重型任务限制保持。[v2→v3精确diff](../runs/depth_v3/v2_to_v3.patch)、[冻结源码/TB/config](../runs/depth_v3/source_freeze/snapshot_hashes.sha256)及[地址/depth核查](../runs/depth_v3/axi_depth_audit.json)单独保存。

**RTL结果可观测范围仅是生成包装器实际返回的这些前缀。** v3继续分配完整12MiB QKV和8MiB ATT_OUT host数组，但depth以上部分仍可能只保留host初始化，不能用生成C postcheck通过来宣称这些未回传高尾已由RTL验证。必须独立核查原始返回TV，比较全部实际QKV写入、QKV的64B边界哨兵、ATT_OUT输出/邻head/下一row哨兵与observed；没有回传的区域明确列为未观测。

v3 [CSim日志](../runs/depth_v3/csim_work/logs/hls_run_csim.log)已有`D2_ATTENTION_SLICE_PASS qkv_bytes=786432 score=64 prob=64 av_exact=64 tasks=4`，[守护](../runs/depth_v3/csim_guard/guard_result.json)exit0、15.077s、峰值1254756KiB；这是新depth/TB的C执行验证。csynth及生成绑定/实际RTL结果后续单列，不能从此推出数值RTL通过。

## D2-C：官方真实13参数top标准libm CSim

[本次日志](../../d2_full_top_csim_official_v1/csim.log)输出`FULL_KERNEL_CSIM_PASS checkpoints=47 values=9047192 tasks=37158`，[退出码](../../d2_full_top_csim_official_v1/csim.exit)为0。实际入口/包/请求/oracle见[metadata](../../d2_full_top_csim_official_v1/metadata.txt)：正式`Laya-baseline`、fe067包、真实B2/S128请求；配置`csim.stdmath=true`。这是B2的47检查点与9047192个F32逐位核验，不将CPU的两次B1或故障恢复自动扩成CSim覆盖。

[16GiB守护结果](../../d2_full_top_csim_guard_v1/guard_result.json)为exit0、111.151s、峰值1738980KiB，最低MemAvailable442111524KiB，无守护触发。[独立运行审核](../../reviewer_d2_c_full_top_csim_review.json)已接受本次官方B2/S128 CSim：113项输入清单（112个唯一文件）、104项官方包源码、5个model BO、47份oracle、26组实际对象/依赖与实际二进制libm绑定均已独立核验。CSim仍是软件执行，不替代D2-R/I或完整生成RTL功能。

## D2-R v3：综合与cosim setup实际完成

v3 [综合报告](../runs/depth_v3/csynth_work/hls/syn/report/attention_slice_csynth.rpt)给出159766 LUT、41183 FF、20 DSP、78 BRAM_18K、0 URAM，5.158ns HLS估算、顶层latency/II仍`?`。[综合守护](../runs/depth_v3/csynth_guard/guard_result.json)exit0、312.452s、峰值4216380KiB；没有布局布线或频率实测结论。v3顶层`attention_slice.v` SHA256为`1e9ac4d6b375937e30e24d2e0690c514d133590756b17734e7c36542b5d5e75b`，与v2相同仅说明该文件相同，不能代替整个接口/包装器/仿真制品身份核验。

[cosim setup守护](../runs/depth_v3/cosim_setup_guard/guard_result.json)exit0、46.164s、峰值2445376KiB。生成TB七口LENGTH与v3 depth一致，[12份主要C TV帧长度核验](../runs/depth_v3/cosim_watchdog/c_tv_depth_audit.json)为`PASS_GENERATED_C_TV_FRAME_LENGTHS`。这些C TV中的预期输出不是实际RTL返回结果；它们只能证明准备向量完整。静态编译清单见[manifest摘要](../runs/depth_v3/cosim_watchdog/compiled_manifest_summary.json)，188份编译项/总212项，真实active TB纳入；xelab静态展开及后续运行由实际日志单独确认。

当前仍不登记RTL成功或数值失败。后续必须完成绑定审核、受守护的实际XSim、生成C postcheck及独立raw-TV前缀/哨兵核查，才能对这个单一用例给出数值结论。

## D2-R v3：静态展开与一次受控RTL运行门禁

[xelab守护](../runs/depth_v3/xelab_guard/guard_result.json)exit0，117.095s，峰值6560948KiB，最低MemAvailable432430700KiB；实际日志确认生成`attention_slice`快照。独立审核重算54项输入、212项编译/TV及23项提交制品哈希，解析188项真实`.prj`编译源及12个C TV二进制帧，核对七口depth、64位地址/32位数据接口、两QKV的64B哨兵，以及真实done绑定的50M-cycle watchdog。

[运行门禁](../../reviewer_d2_r_depth_v3_rtl_gate.json)接受`cosim_watchdog/run_xsim_only.sh`在原`sim/verilog`目录复用已展开快照；该脚本命令逐字对应生成runner的第二条非空命令。该次受控XSim已实际执行并结束，原限16GiB任务树RSS、192GiB主机可用内存下限、4CPU、nice19/idleIO、1800s、50Mcycles、单重任务。门禁通过不代表数值通过。结束后须核实际guard/exit、1/1事务、完整生成C postcheck和独立raw-TV；raw审计必须使用`--io-depth 32768 --qkv-depth 10240064 --att-depth 4100`，AV精确参考使用实际返回的RTL概率。若再次触及RSS上限，不自动重复或提高上限，先量化AXI仿真模型的每字节与稀疏地址成本。

## D2-R v3：实际RTL终态及后续定位

[独立终态审核](../../reviewer_d2_r_depth_v3_final_review.json)确认第三次尝试仍无数值结果。[实际守护](../runs/depth_v3/xsim_guard_16g/guard_result.json)exit -9，594.031s，峰值16781384KiB，最低MemAvailable429646396KiB，触发`owned_rss_at_or_above_limit`；2965条样本复算一致。54项输入、212项编译/CTV与已接受snapshot二进制未变。实际driver/xsim日志仅0/1事务@117000，五份返回TV均0B；无完整事务时延，无cycle watchdog触发，不执行无输入的数值postcheck。

生成`attention_slice_cosim.rpt`的Verilog Pass/全NA记录时间为15:55:07，属于setup而非16:47–16:56本次实际运行，不能据此判通过。连同v2的8GiB/16GiB两次停止，当前三次真实Attention XSim均无RTL数值通过或失败结论。

下一步按[合同§7.8](../../repair_contract.md)和[独立小模型设计](../../d2_xsim_memory_diagnostic/source/design.md)测量实际TV队列、二维复制、动态mem/IsWr分配与逐字节复制成本；小模式最大64KiB、每job2GiB/120s。16GiB是本次内部预算，不是用户永久限制；新全例方案或预算必须有实测归因与可检验预测，当前不自动重跑第四次Attention。保留生产AXI地址布局、真实写入/owner发布、全部数值和哨兵检查。

### 运行阶段归因修正

[独立进度逻辑补充审核](../../reviewer_d2_r_progress_phase_correction.json)核查v2/v3真实autotb：0/1@117000在reset释放后立即打印，后续打印依赖start及`PROGRESS_TIMEOUT=10000000`。没有下一行不等于模拟时间未推进，不能单凭此定位TV初始化；此前此项阶段表述撤回，原始审核文件保留。RSS停止、0完成、空输出与无数值结论不变。下一方案须直接记录阶段、start/cycle/AXI进度和进程RSS，不能预设增长必由reader引起。
