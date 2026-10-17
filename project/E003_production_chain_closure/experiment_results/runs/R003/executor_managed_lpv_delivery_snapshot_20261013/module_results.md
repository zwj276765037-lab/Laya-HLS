# TM1/TN8/GS32、512-bit Q8联合原型结果

## 2026-10-11 当前身份完整CPU与生产blackbox连接状态

- `current_production_full_cpu_01`：build `23c62cd4778f54e3cc7508f5d05558de`，完整持久四请求（3正常、1 accepted gamma fault）141检查点/18094384值通过；guard child0、trigger null，338.28325485s、峰值630752KiB。原始receipt绑定实际27-source executable、模型/新输入、冻结编译依赖闭包及143个oracle文件。本项是g++软件全图，不是Vitis CSim或RTL。
- `current_production_full_vitis_csim_02`实际Vitis/clang16四请求141检查点/18094384值及故障恢复通过，工具0 errors、guard0/null，317.12567632s、峰值1789276KiB；47个实际clang依赖逐hash核冻结闭包，csim.mk严格F32 flags与标准libm.so6/无libhlsm已核，receipt SHA `79632084106bc17c4ab31f1dac482b7d75074dd8cf00fa8d2d720ff827b805b7`。作用域是生产full_execute_cpu_request dispatcher beneath13BO，不是物理13BO/RTL。后续working生产服务源码变化不能写回此旧build身份。
- ACT06受影响OOC：`t2_act_production_ooc_01/input_manifest.json`核原RTL06全部27冻结输入，实际综合在32.235355636s以工具`Synth 8-4556`失败：完整dual-W `qmem`变量85983232bit超过默认1000000bit elaboration限；guard child1/trigger null、峰值3667340KiB，未产生utilization/timing/DCP，不是物理资源结论或成本停止。失败receipt已保存。新`_02`仅调工具elaboration parser限为100000000bit，原27冻结RTL及24GiB/3600s/语义120s保护不变；实际`_02`在205.106653802s因semantic_stall120s保护停止（child−9、峰值9776424KiB），最后日志是多维qmem/smem/bmem的`Synth 8-11357` runtime警告，仍无utilization/timing/DCP。已保存stop receipt，不原样重跑；实际RAM/端口映射UNKNOWN，缓存bank架构修复由集中评判定义；whole accelerator OOC/P&R/timing仍暂停。
- 新quant/TM4完整owner生产调用、七shape/G128扩展及独立Wi/Down Group32 CSim TB已写入working source，原numeric quant30/linear57、七unique shape/十family末tile/rows16/晚scale错误恢复、独立quant114groups和TM4 Wi/Down31488calls/1007616lane groups的实际C调用均PASS（`t2_production_blackbox_cpu_01`，guard0/null，7.034398660s、峰值113200KiB）；实际Vitis生成实例/实际RTL握手仍待验证。`source/blackbox/` JSON的latency/II/资源值不计为实测。完整新生产build须包含新服务模型/JSON/RTL/IP依赖，不能沿用23c62cd4。


## 2026-10-11 当前生产 ACT 真实交接

[`t2_act_production_rtl_06`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_act_production_rtl_06/receipt.json) 在实际 XSim 中 PASS，guard exit0，69.003433581s，owned RSS 峰值2467044KiB，无保护触发。receipt SHA256 为 `607494ecf91cce3daa34db49e8fa83188432207b0c47af38f44cc8a973e1d39d`；27项RTL/IP Tcl输入已核对运行manifest并冻结于该attempt的 `work/rtl_freeze`，后续受影响OOC可读取同一闭包。

范围是独立真实检查点 F32 ACT row K256/N2 → quant16实际FP divider/multiplier → 完整A覆盖/READY/lease → 默认完整容量双W cache严格真实三口及AUX LOAD/lease → TM4合法row0 → 每组PS → 独立final bias FADD → 512bit物理writer最后B退休。4条正常命令逐位比较64个量化半组、64个有效lane group的dot/dotf/scale product/term/PS及8个最终F32，合计32B成功物理写；AW/W/B各4。正常命令接受到完整释放为379/379/378/378cycles，包含计算/写回/释放、未包含此前W LOAD，不是完整请求延迟或板端频率。

晚输入元素255的+Inf使目标A保持INVALID、成功物理输出与PS均不增加、已接受量化债务排空且暖W仍READY；下一A epoch合法恢复。运行中QUANT已实际接受首半组后reset清旧owner/预约与缓存状态，再以真实W重LOAD恢复。没有TB force READY或内部q/scale/PS供数。错误命令仍退休14个已完成半组，因此原始q握手总数78，正常比较数64；这些错误前缀不会发布可读A。

`_01`为Tcl选项解析失败，`_02`为真实语义停滞保护，`_03`/debug定位TB LOAD ARREADY竞态，`_04`首条正常row已通过但TB B延迟blocking竞态导致终态检查失败，`_05`消除该竞态后暴露错误排空前缀使累计q索引错位。最终TB按实际group/half比较，保持原数值和债务断言并补晚错误/活跃reset；各历史失败原样保留。

此结果仅为ACT片段，生产13-BO HLS调用、七种真实K/N通用控制、受影响ACT OOC与同runtime完整producer链仍是各自待完成项；完整图RTL受联合设计§9成本边界约束，整体OOC/P&R/时序与板端性能未由本局部PASS证明。

当前状态：实现与局部验证中。六级整数树、当前Q35/D4预留存储、独立observed trace32 writer、FP IP probe、短算术链、真实ACT算术与ACT桥接局部自检、joint DMA前端ACT/QKV CSim通过。当前Q35联合BO的ACT两次trace-off RUN、QKV一行两次trace-off RUN、四行trace-off及一行trace-on的全部有效lane中间数值与物理输出均通过；其余trace组合的旧Q32正例保留为历史身份。trace-off被动周期已测，但既定全RUN稳态一group/clock未达；完整RTL负例、跨请求流水和实际连续producer尚未通过。联合HLS和无黑盒整体OOC已生成；HLS估计及旧RTL整体综合后时序均未达到6.667ns目标，本次退休修复无新整体OOC/时序实测。所有阶段动态结论由指定负责人同步到[唯一阶段结果表](../../../../../results/cpu_embedding_q8_validation_20261010/stage_results.md)。本页记录本模块预算和原始测量来源；局部PASS不可拼成完整联合验收。

局部整数树：[受控尝试 task2_integer_tree_01](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_integer_tree_01/input_manifest.json) 的guard退出码0，XSim日志含 `TM1TN8_INTEGER_TREE_PASS checked_lanes=936`；源/TB/runner哈希、工具输出及guard结果同目录保存。此结果只覆盖有符号边界、精确dot与六级寄存对齐，不代表FP、Q32/D4、DSP映射或联合顶层通过。

局部observed trace32：[task2_trace_axi32_02](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_trace_axi32_02/input_manifest.json) guard退出0、9.38s，XSim含`TM1TN8_TRACE_AXI32_PASS aw=8 w=8 b=8`，检查逐word地址/数据、AW/W反压、第八B长hold及完整160bit owner tag ACK。`_01`因runner库名失配失败，原证据保留。此自检未覆盖错误BRESP及恢复、HLS observed另一master或联合顶层。

局部Q32/D4预留存储：[task2_reserved_store_04](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_reserved_store_04/input_manifest.json) guard退出0、9.63s，XSim含`TM1TN8_RESERVED_STORE_PASS Q=32 D=4 commits=32`，检查固定返回预留、有序commit、D4退休及反馈。`_01`为TB同delta采样错误，`_02`因此类TB问题达到120s帽，`_03`watchdog定位TB末尾非trace issue却使用trace return；失败与成本日志均保留，不改写为PASS。此局部结果不证明真实FP、PS或完整首错。

首次FP IP/算术短测[task2_arithmetic_pipeline_01](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_arithmetic_pipeline_01/input_manifest.json)真实XSim出现`Fatal: II1 issue stall at 1/2`，故为**FAIL**；Vivado batch虽返回0，不算PASS。guard 43.99s、未触帽。TB的同delta采样及runner PASS判据已修复；后续`_02`–`_09`失败原日志保留，不能单凭早期失败断言短延迟IP非法。定位到FP IP结果原接在被反向连续赋值的局部wire上，256bit结果总线没有驱动；现直接接总线切片，使用实际时钟、低有效复位，并按生成结果valid对齐元数据。独立[FP IP probe `_07`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_fp_ip_probe_07/input_manifest.json) guard退出0、37.10s，XSim通过固定转换-7、乘1、加3；本配置实际生成sitofp/fmul/fadd延迟为**6/6/11拍**，此probe仅覆盖独立IP已测配置。

[连续短算术 `_10`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_arithmetic_pipeline_10/input_manifest.json) guard退出0、45.91s，XSim含`TM1TN8_ARITHMETIC_PIPELINE_PASS issues=16 lanes=128`；16个不同tile连续II1 issue，检查整数dot、FP数值和trace退休，未触资源帽。[真实fixture `_11`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_11/input_manifest.json) guard退出0，独立从冻结GGUF、模型包及ACT `act_hidden`/QKV `embedding_norm`生成ACT、QKV一/四行参考，并交叉检查通过。[ACT向量 `_12`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_act_vectors_12/input_manifest.json) guard退出0，8组逐组向量通过。[真实ACT算术 `_16`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_arithmetic_act_real_16/input_manifest.json) guard退出0、44.91s，XSim含`TM1TN8_ARITHMETIC_REAL_PASS rows=1 G=8 T=1 issues=8 bubbles=252`；逐组核对有效lane的dot、dotf、scale product、term及实际PS commit，同tile反馈等待252拍。输入是独立fixture已量化的q/scale packet，尚未覆盖HLS实际BO加载与量化。

[ACT桥接 `_19`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_act_19/input_manifest.json) guard退出0、46.21s、owned RSS峰值2029464KiB、MemAvailable最低416921088KiB，真实XSim含`TM1TN8_JOINT_ACT_PASS groups=8 lanes=16 macs=512 traceB=64 outB=1`且无Fatal/ERROR；测试检查实际PS、bias、N2仅8B WSTRB、每个trace字的物理B、输出B及首次完成债务清零。`_17`因PS controller变量名使用SystemVerilog保留字`task`编译失败；`_18`在首次完成断言出现`Fatal: completion before physical B/commit debt`，首因为writer桥把`!completion_tvalid`误计入`all_writer_debt_zero`，使完成有效时零债务信号必为假；两次FAIL证据原样保留。`_13`–`_15`的observer/plusarg脚本失败也保留，后续runner改为读真实simulate.log且要求PASS、拒绝Fatal/ERROR。桥接TB从已量化packet驱动，不能证明HLS BO LOAD/quant、统一control、完整联合AXI或QKV形状。

[v2独立fixture `_20`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/input_manifest.json)在资源guard下退出0、3.75s，输出ACT及QKV一/四行完整来源文件身份、实际切片哈希、固定request3/generation1/B1/S128、source ref/spec/注册epoch1和模型包四tag；这是§6.0隔离fixture注册版本，不证明生产owner epoch。[描述符 `_21`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_descriptors_21/input_manifest.json)及[真实ACT AXI输入 `_22`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_inputs_22/input_manifest.json)也在guard下退出0，并比对模型BO切片与GGUF独立fixture。它们只证明生成与绑定脚本完成；实际ACT AXI与数值结果见下文RTL自检。

联合前端C++由[无告警构建 `_26`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_csim_build_26/input_manifest.json)生成，并在[ACT `_27`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_csim_act_27/input_manifest.json)和[QKV `_28`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_csim_qkv_28/input_manifest.json)受控CSim中退出0。ACT依次通过LOAD、14个来源/会话/四tag拒绝探针及合法RUN恢复；QKV依次通过LOAD、14个拒绝探针、完整K1024/N3072一行和四行的trace on/off，核对独立量化q/half、W与scale packet及header计数。旧构建`_23`虽通过ACT`_24`和QKV`_25`，GCC对Vitis `ap_int`动态`packed.range(j*32+31,j*32)`路径发出内部循环UB告警；源码改为`j<8`有界右移并截取32bit，`_26`构建不再有该告警，且受影响两例已重跑。CSim的writer completion是测试注入的ACK，只能证明前端生成及状态逻辑，不能代替RTL真实B退休。

[联合HLS `_30`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_hls_30/input_manifest.json)同一前端源码/配置受控exit0、68.88s、RSS峰值2906980KiB，Vitis 2025.2实际生成七个AXI master和stream，报告目标6.667ns、估计21.308ns，故**生成成功但前端QoR未达目标**；其单独估计为LUT58640、FF31897、BRAM18K117、DSP26、URAM128，不能当作全原型资源。[wrapper `_31`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_wrapper_31/input_manifest.json)从真实370端口顶层及控制寄存器模块解析七个64bit pointer低/高字偏移，核对q0/q1/scale/activation为实际512bit读口；这不代替整顶层OOC或物理AXI测试。

[完整ACT BO正例 `_36`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_pilot_36/input_manifest.json)在120s pilot帽内guard exit0、79.66s、峰值RSS2826176KiB，真实XSim含`TM1TN8_JOINT_DMA_ACT_PASS q0R=32 scaleR=2 inputR=16 traceB=64 outB=1 obsB=37`。该同制品实际LOAD q0/scale/aux→RUN读独立act_hidden→HLS量化→math/PS/bias→N2仅8B写使能、trace及输出的物理B，首次done所有端口债务为0；核对64个q word、4个half word、64个选中trace word及两个最终F32。[增强ACT完整BO `_51`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_full_51/input_manifest.json)在相同HLS30/wrapper31与原输入上guard exit0、76.57s、峰值RSS2562624KiB，XSim含`TM1TN8_JOINT_DMA_ACT_PASS q0R=32 scaleR=2 inputR=16 dot=8 term=8 commits=8 traceB=64 outB=1 obsB=37`；新增独立向量逐一比较8组、16有效lane的dot、dotf、scale product、term、PS commit，并复核物理输出/trace B与首次done债务。`_50`因运行命令少传wrapper参数在7s内停止，尚未进入设计编译；原失败保留。`_33`与`_35`的早期连接/展开失败也保留。旧QKV bridge-only一行[pilot `_39`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_qkv_row1_pilot_39/input_manifest.json)在120s帽触发timeout，未完成自检且不能替代完整DMA QKV。

[整体OOC `_42`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_ooc_42/input_manifest.json)使用同一HLS30/wrapper31、全部四个HLS FP XCI与完整math/writer RTL，guard exit0、970.55s，峰值owned RSS22597912KiB、MemAvailable最低398072112KiB；Vivado输出`TM1TN8_JOINT_OOC_PASS`且blackbox检查为空，[checkpoint](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_ooc_42/work/joint_ooc.dcp)已生成。[资源报告](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_ooc_42/work/utilization.rpt)为CLB LUT87794、FF171958、BRAM tile86（RAMB36 72、RAMB18 28）、URAM96、DSP458；日志的DSP模式表中`tm1tn8_integer_tree`有320项，其中128项`(A'*B')'`和128项`(PCIN+(A'*B')')'`对应256个乘法DSP，另外64项`(PCIN+A:B)'`用于树中加法，确认8×32 signed8乘法没有仅留在LUT。按原器件/6.667ns和0.035ns不确定度，[综合后时序报告](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_ooc_42/work/timing_summary.rpt)给WNS **-12.019ns**、TNS -3803.124ns、393个setup失败端点及20个hold失败端点；最差setup从`bridge/ps_controller/tile_tdata_reg[257]`到`bridge/bias_output/first_bad_element_reg[11]`，数据路径18.633ns（逻辑6.625ns、估计route12.008ns）、88级。`tm1tn8_bias_output.sv`的8-lane组合candidate rank/bad-element归约是该路径上的可能瓶颈；未调整架构或时钟合同。OOC/综合通过，**目标时序FAIL**；这不是P&R/Fmax实测。

[QKV完整DMA一行pilot `_52`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_pilot_52/input_manifest.json)按先行120s/8GiB保护运行，guard因计划timeout停止（120.40s，峰值RSS2830628KiB），XSim最后进度70,000 clocks，q0R=24576、q1R=24576，scale/quant/compute尚未完成，故**NOT_RUN_COST，不是QKV PASS**。此进度提供正式范围成本依据；完整一行须另次在原3600s/40M/8GiB帽内完成所有数值、trace、scatter输出与done检查。

[QKV一行正式运行 `_53`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_full_53/input_manifest.json)在原8GiB/3600s/40M帽内guard无资源触发但exit1、545.00s。LOAD在488555 clocks通过，真实q0R/q1R各24576、scaleR3072；RUN随后activationR64、traceB256，510000 clocks时commit12043。XSim于最后out1写beat95触发`Fatal: QKV physical out1 address/strb`，未达到完整PASS，故为**功能FAIL**，不是成本停止；该断言当时未拆出实际地址/字节使能/last，已在保持原判据的后续TB中补全诊断字段，不能先猜是DUT还是TB首因。[新首错RTL的ACT回归 `_57`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_rank_57/input_manifest.json)guard exit0、81.34s、峰值RSS2555308KiB，仍含`TM1TN8_JOINT_DMA_ACT_PASS ... dot=8 term=8 commits=8 traceB=64 outB=1 obsB=37`。首错宽组合路径依合同§6.2.1改为PS/bias共同23bit私有键及最低错误lane优先单次比较；修改前原字节在`_42/source_before/`并与OOC42 manifest哈希一致。该修改尚未得到新的QKV/负例/OOC结论。

[QKV末拍诊断 `_58`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_rank_diag_58/input_manifest.json)在原8GiB/3600s/40M帽内guard exit1、523.64s，未触资源保护。最后out1 beat95的实际/预期地址同为`0x00000003009c00c0`且`WLAST=1`，但实际`WSTRB=0x00000000ffffffff`、预期全64B；writer1的`n0=3056`、`word_idx=8`、useful=6112B、physical=6080B、AW/W/B=96/95/95，恰少最后32B tile `n0=3064`。独立scatter判据保持不变。首因是PS完成后 writer finish 可早于 bias 最后 pending tile 的 writer 握手，writer 进入 draining 后拒收该 tile，并冲刷半满 pack。现桥内增加 bias `drain_empty` 门控且 finish 仅按实际握手清除；此修复须以新身份回归，不能把 `_58` 当PASS。

[错误排序注入 `_59`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_rank_state_59/input_manifest.json)guard exit0、24.12s、峰值RSS1341052KiB，XSim含`TM1TN8_RANK_STATE_PASS ps=4 bias=3 sentinel=1 lower_rank=2 tie=3`，覆盖PS/bias最低错误lane、较早生产rank覆盖较晚完成、重复rank保持原状态、无错哨兵、joint PS并列优先。该测试以合成算术返回注入错误，只证明首错状态逻辑。[退休门控后真实ACT回归 `_60`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_drain_60/input_manifest.json)guard exit0、79.69s、峰值RSS2778752KiB，XSim含`TM1TN8_JOINT_DMA_ACT_PASS q0R=32 scaleR=2 inputR=16 dot=8 term=8 commits=8 traceB=64 outB=1 obsB=37`；保留有效lane全部中间数值、物理trace/output B及首次done零债务断言。此身份仅验证ACT，QKV仍需后续完整结果。

[退休门控后QKV一行 `_61`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_drain_61/input_manifest.json)guard exit1、500.20s、峰值RSS2741352KiB、无资源触发；原最后out1地址/`WSTRB`/数据断言已越过，但首次完成后触发TB汇总`QKV actual RUN coverage/status`，因此仍为**FAIL**。检查独立ABI发现该TB把observed header word63 `O_TRACE_GROUP_COUNT` 错期望为全部12288 issue，而选中单个QKV tile、32组的trace-on独立期望是32（trace-off为0）；ACT只有一个tile，所以8组与8 issue恰好相等，未暴露该TB错误。已保留原失败和全部逐字/债务判据，在新TB中修正word63并增加汇总失败时各实测计数；新完整回归未完成前不将 `_61` 当PASS。

第一次新TB运行[`_63`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_full_63/input_manifest.json)在112.04s由本任务主动终止（guard child exit -15、无保护触发），未进入完整自检。静态检查发现新加的性能计数在切换`run_mode`后可把LOAD残留单拍`command_done`误记为RUN首次完成；已改为只在对应命令AP accept发生后捕获首次done，重新生成一行trace-on/off及四行TB身份。`_63`保留为**NOT_RUN/主动停止**，不视作设计失败或PASS。

[计时监测失败 `_69`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_full_69/input_manifest.json)guard exit1、424.22s、峰值RSS2795768KiB、未触资源保护；到原LOAD末尾时新增TB计时断言报`QKV LOAD AP accept/first done missing`，尚未进入RUN，不能证明QKV数值或输出失败。该监测在`command_done`单拍断言后的下一negedge才切换模式，posedge轮询可漏掉首次done；故已从功能回归TB移除计时探针，以原`_54`逐字/债务自检主体、仅修word63独立期望并打印汇总失败各计数生成新身份。计时探针另存独立TB，须先用短ACT路径核实实际AP握手/首次done关联才可用于性能结论。`_69`保留为**TB监测FAIL**。

[QKV一行完整功能 `_73`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_func_73/input_manifest.json)guard exit0、501.89s、峰值RSS2773712KiB、MemAvailable最低405208620KiB、无保护触发，XSim含`TM1TN8_JOINT_DMA_QKV_PASS rows=1 q0R=24576 q1R=24576 inputR=64 dot=12288 term=12288 commits=12288 traceB=256 outB=192 obsB=49 cycles=515002`。LOAD于488555 clocks核对真实q0/q1各24576 R及scale3072 R；RUN逐group核对所有有效lane中间数值、12288次PS commit、完整scatter输出数据/地址及每拍全64B WSTRB、选中trace256个物理B、observed BO其余区域sentinel与首次done所有AXI/适配器债务为0。`O_TRACE_GROUP_COUNT`按单选中tile×32组的独立期望核对。该结果证明本身份QKV一行trace-on完整功能；四行和trace-off尚需独立验证。XSim的总515002 clocks含测试启动及LOAD/RUN，不能当作RUN单独周期或AP accept到首次done周期。

[QKV四行完整功能 `_75`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_rows4_full_75/input_manifest.json)guard exit0、764.77s、峰值RSS2743332KiB、MemAvailable最低387206196KiB、无保护触发，XSim含`TM1TN8_JOINT_DMA_QKV_PASS rows=4 q0R=24576 q1R=24576 inputR=256 dot=49152 term=49152 commits=49152 traceB=256 outB=768 obsB=100 cycles=583978`。同一冷进程只LOAD一次真实权重；随后四行全部有效lane中间值和PS、完整768个全宽scatter beat、选中trace256个物理B、observed BO sentinel与首次done零债务均按独立参考通过。额外独立pilot `_74` 在27.44s由本任务主动停止以免重复冷LOAD，原guard证据保留；正式 `_75` 首120s已作为同进程进度/成本观察。总时钟仍含启动与LOAD，不能充当独立RUN/AP周期。

[首次QKV一行trace-off `_77`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_traceoff_perf_77/input_manifest.json)保留为**TB期望FAIL**：guard exit1、515.27s，真实LOAD及RUN执行后，TB在observed word256报sentinel与量化q期望不符。HLS源码仅在`d.flags`开启时把q/half写入observed BO；关闭trace时该word保持sentinel是正确行为。后续TB保留独立量化检查，改为在每个实际group握手比较q和F32 activation scale，并要求q/half与物理trace区保持sentinel；不把`_77`改判通过。

[QKV一行trace-off `_79`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_traceoff_perf_79/input_manifest.json)基于新生成TB `_78`、同HLS30/wrapper31及原真实输入，guard exit0、506.21s、峰值owned RSS2734924KiB、MemAvailable最低379921288KiB、无保护触发。XSim `PASS rows=1`：LOAD q0/q1各24576读、scale3072读；RUN input64读，逐group独立q/scale与所有有效lane dot/term/PS各12288次，out0/out1合计192个满64B scatter beat及真实B、observed B32、trace AW/W/B均0、header words58–63均0，q/half和trace观察区保持sentinel，首次done全部债务为0。被动TB段测量：LOAD **488555** clocks，RUN **24585** clocks；首issue在RUN起点后4457，12288次issue跨18410 clocks、间隙6122 clocks，观察到的间隙均为result-credit stall，source-empty/tile-busy/trace-credit/output-W stall均0；末commit与末output B分别在RUN后23357/23412 clocks。有效3145728 MAC除以RUN段为**127.953 MAC/clock**，除以issue跨度为**170.871 MAC/clock**。

[ACT trace-off `_81`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_traceoff_perf_81/input_manifest.json)基于新生成TB `_80`及原真实ACT输入，guard exit0、78.74s、峰值owned RSS2811924KiB、MemAvailable最低378687588KiB。XSim `PASS`：q0读32、scale读2、input读16、8次独立q/scale及全部有效lane数值/PS检查、8B输出及真实B1、observed B32、trace AW/W/B均0、header words58–63均0、q/half和trace区sentinel、首次done零债务。被动TB段LOAD **3303**、RUN **3477** clocks；8次issue跨260 clocks、间隙252 clocks（tile-busy 245、pipeline 7，result-credit/trace-credit/output-W均0），末commit与末output B在RUN后2275/2304 clocks；512有效MAC除以RUN/issue跨度分别为**0.147/1.969 MAC/clock**。短ACT形状只有一个tile和8次issue，不能外推稳态矩阵吞吐。

[QKV四行trace-off `_84`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_rows4_traceoff_f_84/input_manifest.json)基于新生成TB `_83`、同HLS30/wrapper31及原四行输入，guard exit0、756.12s、峰值owned RSS2784164KiB、MemAvailable最低377454744KiB、无保护触发。XSim `PASS rows=4`：同一冷LOAD q0/q1各24576读、scale3072读；RUN input256读，逐group独立q/scale及全部有效lane dot/term/PS各49152次、768个满64B scatter beat及真实B、observed B32、trace AW/W/B均0、header words58–63均0、q/half和trace区sentinel、首次done零债务。被动TB段LOAD **488555**、RUN **88079** clocks；首issue在RUN起点后11273，49152次issue跨75089 clocks、间隙25937 clocks，观察到的间隙均为result-credit stall，source-empty/tile-busy/trace-credit/output-W stall均0；末commit与末output B分别在RUN后86852/86907 clocks。有效12582912 MAC除以RUN段为**142.859 MAC/clock**，除以issue跨度为**167.573 MAC/clock**。同一TB逐tag记录issue→PS commit，49152项全部配对，最小34、最大491、均值48.037 clocks；区间`<64 / [64,128) / [128,256) / [256,512)`分别47546/31/61/1514项。该分布尚未按group位置分类，不能仅以最大值或stall总数确定result-credit生命周期首因。

本轮§6.6–§6.8原型短测：Q35/D4的[credit `_88`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_q35_credit_88/work/xsim.log)在guard exit0、9.84s、RSS峰值859688KiB下报`TM1TN8_RESERVED_STORE_PASS Q=35 D=4 commits=105`；覆盖35槽全满、第36个反压、D4满/完整tag ACK、两次34→0回绕、slot31/32/34/0、同拍issue/return/commit及非法35/63、错tag、重复返回，终态守恒。并行pack/TX的[writer `_87`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_writer_q35_87/work/xsim.log)guard exit0、9.77s、RSS峰值859808KiB，`PASS cases=9 error_drain=1`；自检覆盖ACT8B尾写、QKV相邻tile满beat、head/plane跳变、4B偏移跨beat/4KiB、AW/W两种握手先后、B长hold时第二pack填充与第三beat反压、错误B后债务清零。两者是局部自检，不证明整顶层数值或目标II。

首次新writer桥短测[`_89`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_bridge_q35_89/guard/guard_result.json)被120s guard时间帽终止，XSim未出现PASS/FATAL，状态为**NOT_RUN_TIMEOUT**。带全局watchdog的诊断[`_90`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_bridge_diag_90/work/xsim.log)在第二次配置后定位`configured=1、draining=0、tile_ready=0、writer无债务/故障`；首因是writer首次`flush_done`后旧`flush_req`保持高一拍时重新置位`flushing`，且`flush_reported`尚为1，导致下一命令ready永久为0。按原接口把同次flush报告状态保持到请求下降，受影响两命令[bridge `_91`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_bridge_fix_91/work/xsim.log)guard exit0、9.84s、RSS峰值859876KiB，`TM1TN8_WRITER_BRIDGE_PASS commands=2 B0=2 B1=1`；旧成本与诊断原日志保留。

当前物理writer源码与原九例TB重新绑定的[短测 `_109`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_writer_q35_current_109/input_manifest.json) guard exit0、10.93s、峰值RSS793544KiB、无保护触发，XSim再次给出`TM1TN8_AXI512_WRITER_PASS cases=9 error_drain=1`且无Fatal/ERROR。manifest逐项绑定当前writer RTL、原TB、运行脚本和guard源码/原始日志。该短测补齐先前`_87`未记录当前source hash的证据边界；九例局部通过仍以完整DMA `_103/_104/_107/_108`各自检查物理B和最终数据作整链支撑。

同权连续ACT trace-off[完整BO `_93`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_cont_93/work/vivado/tm1tn8_joint_dma_act.sim/sim_1/behav/xsim/simulate.log)使用同一HLS30/wrapper31、真实ACT BO与独立向量，guard exit0、77.49s、RSS峰值2746536KiB、无保护触发。一次冷LOAD后合法RUN1(task2/3, PS/dst epoch1)与RUN2(task4/5, PS/dst epoch2)，原输入和权重固定；各RUN分别检查8个真实group的q/scale、dot/term/PS、8B有效输出/WSTRB和B、observed header任务/epoch/W loads/reuses、保护区sentinel及首次done全部债务清零，未发生第二次权重读取。LOAD TB段3303 clocks；RUN1/2各3473 clocks，issue均8次跨260 clocks，result-credit stall均0，单tile反馈间隙252。此计时仍是TB段；精确AP接受/首次done间隔将在受影响短ACT监测中补齐。旧Q32 `_81` 数值身份不替代本次Q35新制品。

新增ACT命令监测首次尝试[`_100`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_timing_100/guard/driver.log)在数值/物理输出通过后，仅因posedge轮询漏记一次单拍wrapper完成事件而触发TB计时断言，guard exit1；原日志保留为**监测FAIL**。把采样移入实际驱动`launch()`和`wait(command_done)`，同时在首次done同点复核全部物理/适配器债务后，新身份[ACT `_103`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_act_timing_103/input_manifest.json) guard exit0、77.68s、峰值RSS2791444KiB、无保护触发。一次LOAD后两次trace-off合法RUN各自独立数值与物理输出PASS；wrapper接受到首次done各**3471 clocks**，RUN2相邻done间隔3473、控制空档2。该wrapper间隔包含AXI-Lite配置、HLS启动/轮询及排空，不是HLS内部ap_start→ap_done。

新Q35/并行pack/TX的一行QKV同权连续trace-off[完整BO `_104`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_cont_104/input_manifest.json) guard exit0、579.30s、峰值RSS2627540KiB、无资源触发。真实LOAD读取q0/q1各24576宽beat、scale3072宽beat；随后两次合法RUN分别按独立gold核对12288组q/scale、dot/term/PS及3072个scatter F32、各192个物理输出B、header/未用区sentinel、trace AW/W/B全零及首次done零债务；两次RUN间W未重读。每RUN的TB段为18935 clocks，wrapper接受至首次done为**18933 clocks**；RUN2相邻done间隔18935、控制空档2。每RUN的12288次group issue跨13148 clocks，860个间隙均观察为result-credit stall；11904个非末组issue平均间隔1.000 clocks，Q35最大占用35。issue→commit反馈12288项全可配对，最小34、最大134、均值36.581 clocks；两输出口96个B各自首末平均间隔13.937 clocks。与旧Q32 `_79` 的18410-cycle issue跨度相比，容量与pack修复显著缩短跨度，但一group/clock的完整RUN稳态目标仍未达到，不能将非末组局部II1当成全路径II1。先前[`_96`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_cont_96/guard/driver.log)只通过RUN1数值/物理输出，随后新服务事件监测断言失败；不把其RUN1打印的PASS字样当成连续RUN通过。

受影响四行trace-off[完整BO `_107`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_rows4_reg_107/input_manifest.json) guard exit0、731.46s、峰值RSS2778352KiB、无资源触发。一次LOAD后四行共49152组的独立q/scale、dot/term/PS和12288个最终F32、双口合计768个物理输出B、header/sentinel、trace AW/W/B全零和首次done零债务均通过。LOAD TB段488555 clocks；RUN段65465、wrapper接受至首次done**65463** clocks。49152次issue跨52862 clocks，3710间隙全部result-credit stall，Q35占用峰值35；旧Q32 `_84` 同shape/固定反压的issue跨度75089 clocks是历史基线。row0/1/2末输出B到下一行首issue各重叠159 clocks。汇总`nonlast_issue_interval=1.084`与跨四行的每口B首末均值107.149都跨行、跨group边界，不能作为局部纯writer服务II。该固定memory slave每次最后W后持B `B_HOLD=9`；全RUN末组的信用反压与物理B服务相关，但该一项观测不足以量化板上AXI服务率或宣称整体II1。

同一当前RTL的QKV一行trace-on[完整BO `_108`](../../../../../results/cpu_embedding_q8_validation_20261010/attempts/task2_joint_dma_qkv_row1_on_108/input_manifest.json) guard exit0、487.29s、峰值RSS2796924KiB、无资源触发；一次LOAD后独立q/scale、12288组dot/term/PS、全部3072 F32 scatter、选中trace的256个真实B、双输出192个B、observed49个B、未用区sentinel及首次done零债务均通过。LOAD TB段488555，RUN段20799，wrapper接受至首次done**20797** clocks；比同身份trace-off `_104` 的18933 clocks多1864，首issue相对RUN起点由4457移到6320，issue跨度同为13148且credit缺口同为860。该差额是固定trace启用配置下的实测，不外推板上吞吐；旧Q32 trace-on `_73`仍为历史数值身份。

上文旧Q32 `_81/_79/_84` 的周期均从TB在对应命令`launch()`前记录的分段起点计算；包含该段的启动、控制及AXI等待，**不是wrapper接受→首次done**。其ACT/QKV1/QKV4的issue跨度实际服务率分别为**0.03077/0.66746/0.65458 group/clock**，是历史单RUN基线身份。新Q35 `_103/_104/_107` 另有可靠wrapper命令接受/首次done测量，口径见上；它们仍只覆盖隔离fixture、固定B_HOLD9反压，没有实际生产owner链、跨请求完整矩阵完成间隔/req/s或板上Fmax证据。一group/clock的既定全RUN稳态目标在新QKV1/4仍未达到，数值PASS不能写为吞吐或50ms目标PASS。

| 项目 | 目标或可复算工作量 | 本原型实测 |
| --- | --- | --- |
| 形状 | ACT K256/N2/rows1；Encoder layer0 QKV K1024/N3072/rows1或4 | 当前Q35：ACT两次trace-off RUN `_103`、QKV一行两次trace-off RUN `_104`、四行trace-off `_107`、一行trace-on `_108`完整DMA独立数值与物理输出PASS；其它trace组合仅有旧Q32历史身份，跨请求流水待测 |
| 整数运算 | TM1/TN8/GS32，256个signed8乘法/issue；一乘法一DSP为映射意图 | 局部整数树936 lane自检PASS；整体OOC的整数树DSP模式表有256个乘法项、另64个加法项，整体458 DSP |
| ACT有效工作 | LOAD q0 2048B=32×64B、scale128B=2×64B；RUN input1024B=16×64B、8 group issue、16有效lane group、512有效MAC、output8B | 当前Q35同权连续`_103`一次LOAD后两RUN各TB段3473、wrapper接受→首次done3471 clocks；8 issue跨260 clocks。旧Q32 `_81` 为历史单RUN基线 |
| QKV每行有效工作 | LOAD q0/q1各1572864B=24576×64B、scale196608B=3072×64B；RUN input4096B=64×64B、12288 group issue、98304有效lane group、3145728有效MAC、output12288B=192满宽beat；rows4只LOAD一次W | 当前Q35一行trace-off连续`_104`两RUN各wrapper接受→首次done18933 clocks、issue跨度13148；一行trace-on `_108`为20797/13148；四行trace-off `_107`为65463/52862。旧Q32 trace-on `_73/_75`、trace-off `_79/_84` 是历史数值/周期基线；两shape全RUN II1仍未达 |
| 外部接口 | q0/q1/scale、activation、out0/out1实际AXI data为512bit；observed trace独立32bit AXI，单一BO/base/span；单口一笔outstanding、≤16beats且不跨4KiB，按实际WSTRB/B退休 | HLS30/wrapper31真实端口已核；ACT `_51`测得trace 64个物理B、输出1个B及done零债务；随机反压/边界/长hold仍未测 |
| 时钟/成本 | 沿用当前合法工程器件与6.667ns目标、0.035ns要求；Task2 RTL初始保护8GiB/3600s/40M，正式运行需≤120s pilot支持 | HLS估计21.308ns；整体OOC 970.55s、峰值22.60×10⁶KiB，综合后WNS -12.019ns，目标FAIL；ACT RTL `_51` 76.57s |
| 物理平台 | 无板卡 | P&R/Fmax、XRT/HBM/PCIe及50ms均未测 |

上述字节与工作量取自[执行合同§6.3](../../../../../results/cpu_embedding_q8_validation_20261010/contract/design.md)；未列为实测的性能项仍是预期覆盖。随机AXI反压、最后R/B长hold、4KiB拆分、4B非64B输出基址与完整负例保持NOT_RUN，现有固定memory-slave hold不能替代这些覆盖；实际连续producer、跨请求流水服务率及完整模型准确率也未测。旧RTL整体时序已明确FAIL，本次修复未再测整体OOC/时序或P&R，故当前制品尚非通过验收的联合原型。

## T2 signed packing、独立候选树短验证（2026-10-10）

[CPU穷举 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_pack_exhaustive_01/work/result.json)对全部16,777,216个signed8 `(a,w0,w1)`组合比较packed解码与独立int64 `a*w0/a*w1`，结果`PASS_MATHEMATICAL_ONLY`、checked-record SHA256 `43a9bfe7b8e1cb3cf8d55ac4e1fbd727c20247da9a1a7fe0c8d131a29cb30d1b`。X范围`[-16777344,16646271]`，P范围`[-2130722688,2147500032]`，p0/p1范围均`[-16256,16384]`；P正端超过signed32上界，RTL保留45bit。[guard](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_pack_exhaustive_01/guard/guard_result.json) child exit0、0.823s、owned RSS峰值40464KiB、无触发。此PASS不证明RTL或DSP推断。

[整数候选 `_03`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_integer_candidates_03/input_manifest.json)在同一XSim中核对旧基线、LUT树、packed树与独立signed dot，guard child exit0、10.222s、owned RSS峰值859996KiB、无触发，原始[日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_integer_candidates_03/work/xsim.log)为`TM1TN8_INTEGER_CANDIDATES_PASS accepted=924 returned=919 flushed=5 checked_lanes=22056 checked_pairs=1040`。首256个时钟连续接受，后续含随机bubble、两拍同步reset及恢复；五个reset时在途合法接受被清空，因此924=919+5，返回919×3模块×8lane=22056。pair短例覆盖所有256个A与四种signed极值W组合及额外零/负1权重，核tag/oldPS全宽变化和每lane不同W。`_01`初跑在reset解除同一delta检查`req_ready`，TB cycle0报`unexpected backpressure`；修正采样后`_02`已通过，`_03`仅增加reset flush计数与守恒断言，旧FAIL日志保留，不归因RTL。

[真实已量化group重放 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_real_replay_01/input_manifest.json)由当前独立ACT/QKV fixture向量选ACT全部8组和QKV一行首/末各64组，共136个连续issue；向量选择guard exit0。候选RTL guard child exit0、9.822s、owned RSS峰值859880KiB、无触发，[XSim日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_real_replay_01/work/xsim.log)为`TM1TN8_INTEGER_REAL_REPLAY_PASS act=8 qkv=128 issues=136 checked_lanes=3264`。每组所有八lane按独立signed乘法求dot，ACT/QKV有效lane还核独立fixture dot；三个树均lockstep并核tag/oldPS。此项不含HLS LOAD/量化、FP恢复/PS、全12288组QKV或Wi/Down，不能作为完整RUN PASS。

候选A/B目前仅**精确整数功能与六级接口PASS_SCOPED**。旧OOC42的320树DSP为基线事实；新候选未做综合/OOC、资源报告或物理时序，故新DSP/LUT/FF/布线、是否单DSP pair和6.667ns均`NOT_RUN`。当前joint DMA的6bit group/9bit tile及K/N硬限不容纳Wi/Down全形状，须使用TM4的7bit group/10bit tile接口。

候选A的[ACT真实R0 `_02`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_r0_lut_act_02/input_manifest.json)和候选B的[ACT真实R0 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_r0_packed_act_01/input_manifest.json)均guard child exit0、无保护触发，耗时分别43.713s/44.260s、owned RSS峰值1976488/1990484KiB；各自XSim为`TM1TN8_ARITHMETIC_REAL_{LUT,PACKED}_PASS rows=1 G=8 T=1 issues=8 bubbles=252`，按当前ACT已量化fixture独立核8组有效lane的dot、dotf、scale product、term、每次PS commit、trace及Q35/D4最终债务。LUT `_01`首次仿真虽8项算术/返回全核，但复制TB末尾沿旧Q32检查`result_free`，故guard exit1；仅把候选TB的末态free期望修正为当前RTL的Q35并在`_02`重跑通过。此真实短例不是HBM LOAD/FPGA动态量化、QKV完整矩阵或TM4四行PASS。

[TM4标签 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_tag_01/input_manifest.json)guard child exit0、9.235s、owned RSS峰值859984KiB，XSim `TM4TN8_TAG_V1_PASS cases=64`，覆盖完整group63/64/81/127及tile511/512/655/1023编码边界。按联合合同补入逐stripe 96bit身份、版本1及27bit序列核验；非法tile在访问PS/progress/poison数组前先拒绝。

[TM4 LUT短pilot `_03`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_pilot_03/input_manifest.json)guard child exit0、62.428s、owned RSS峰值2357108KiB、MemAvailable最低423833308KiB、无保护触发；原始[XSim日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_pilot_03/work/vivado/tm4tn8_pilot_v1.sim/sim_1/behav/xsim/simulate.log)为`TM4TN8_MICROBENCH_PILOT_PASS qkv_four_row_stripes=256 act_four_row_groups=8 rejects=5 blocked_row=1 trace_ack_block=1 inflight_reset=1 commits=1080`。合法QKV配置K1024/N3072/G32/T384下仅连续接受首256个group0四行stripe、1024个row计算/commit，随后reset；这是**局部流的II1和32lane服务**，不是完整QKV任务成功。另以合成scale=1的四行ACT N2跑完8组并核反馈/尾mask：32个row计算完成；五个各自新配置分别以高位身份翻转、错误版本、重复/跳序列、tile700拒绝stripe，先前已接受的20个row计算排空，无新算术发出、旧债务归零后失败终态并可重新配置。单row commit阻塞时其它三row先退休且blocked payload稳定；所选trace占D4直到ack，reset清其债务；另一个四行stripe在FP返回前reset，4个在途row预约清空且50拍无旧返回。总计271个stripe接受、5个拒绝、1084个row请求接受=1080个PS commit+4个reset-flushed在途row，请注意QKV和短故障任务的reset/失败终态并非成功完成。每拍每row检查Q35守恒、有效lane按独立signed dot和精确scale=1 F32预期核PS/phase/tag，累计8304个有效lane的最终PS比较；未逐阶段观测TM4 dotf/product/term的真实模型值。

首次TM4 `_01`编译因草案内部变量`sequence`撞SystemVerilog关键字失败，改为`next_sequence`后`_02`基础pilot通过；`_03`增加one-row commit阻塞、trace ack阻塞及中途reset而再次通过，失败与较窄PASS原始attempt均保留。该短合成pilot与下述ACT/QKV完整真实矩阵均为LUT候选局部PASS；packed TM4、Wi/Down高索引仍`NOT_RUN`。无新综合/OOC/DSP资源/物理时序或HBM LOAD/FPGA量化/bias/writer结论。

当前PS是逻辑32bank、671744bit=83968B容量账，RTL异步读/同步写；group0靠progress有效性从+0起，PS/poison数据不做整片reset。另有progress 18368bit、pending 2624bit、poison 20992bit，四行reserved store各自的busy、result/trace owner/tag表，以及FP恢复的67200bit meta_tag/mask/phase/trace和768bit slot FIFO；这些与Q35/D4返回payload都不含在PS容量内。实际BRAM/URAM/LUTRAM/FF及读mux映射、复制/多端口和总资源均`UNKNOWN`，不能把功能pilot的容量或服务等同已实现片上RAM和物理端口。reserved store的`just_valid/prior_valid`使同tile在commit c后的c+1/c+2继续阻塞，最早c+3才可能接受；这只是RTL边界，不是ACT实测服务率。仅有短功能证据，未做新综合/OOC。

[v4 producer编译 `_02`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_capture_build_02/input_manifest.json)guard child exit0、7.972s、峰值150104KiB；`_01`因guard工作目录下使用相对脚本路径而立即exit127，失败证据保留。[持久CPU/CSim捕获 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_capture_run_01/input_manifest.json)guard child exit0、139.551s、峰值630240KiB、最低MemAvailable 399274916KiB，无保护触发；原47检查点×3=141、18094384个F32比较及gamma失败后恢复均通过。request3/generation1/B1/S128实际捕获Encoder layer0 head0 V plane2 128×64、LN_FFN 128×1024、GEGLU 128×2624，各自SHA256为`93626645cb11e9216196ee92de5305e300a2a560fac9f4e3fdaa4bbebfccd34e`、`6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863`、`f65d20eeab56c2768659145fe221a69986dbc9803fedf4b35ff2f6cdcbaeecd5`。[独立Wi/Down fixture `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json)guard child exit0、1.981s、峰值81080KiB；按实际GGUF/BO逐group核权重布局，并由`tests/full_reference.py`独立复算四行全部K/N：Wi K1024/N5248、671744 group records、21495808 MAC；Down K2624/N1024、335872 group records、10747904 MAC。此项仅证明生产者输入及独立gold已备，TM4 RTL、FPGA动态量化与AV算术仍未比较。历史B2捕获未被复用为本轮B1。

真实TM4输入流转换guard均exit0： [ACT `_02`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_stream_act_02/input_manifest.json)8 stripes、[QKV `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_stream_qkv_01/input_manifest.json)12288 stripes、[Wi `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_stream_wi_01/input_manifest.json)20992 stripes、[Down `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_stream_down_01/input_manifest.json)10496 stripes；`ACT _01`仅因转换器读错`w_scale`字段名而失败，修正后同独立fixture通过。各流记录原fixture SHA及十个实际mem SHA。[ACT LUT真实矩阵 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_act_lut_01/input_manifest.json)首次编译及XSim在120s pilot内guard exit0、58.759s、owned RSS峰值2361412KiB，原始`TM4TN8_REAL_MATRIX_PASS rows=1 K=256 N=2 stripes=8 group_records=16 stalls=252 candidate=0`。TB按独立流检查8组所有有效lane的dot/dotf/scale product/term与PS commit、完整tag、trace、Q35/D4债务和完成；7个commit→下一同tile issue间隔实测`min=max=3,sum=21`拍，符合`just_valid/prior_valid`的c+3边界。`stalls=252`为此串行ACT激励累计未就绪观察拍，不等同单次反馈间隔或真实完整DMA吞吐。

[QKV LUT 120s pilot `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_qkv_lut_pilot_01/input_manifest.json)完成编译并进入真实XSim，guard因预定timeout停于row0 commit2048/12288；这仅是成本样本，不算功能PASS。其已编译LUT快照经[复用入口](../tb/run_tm4_compiled_replay.sh)校验11项模块源/TB/Tcl身份和各流SHA后拷入新guard工作目录。[QKV四行完整矩阵 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_qkv_lut_full_01/input_manifest.json)仅仿真、无重编译，guard exit0、408.346s、owned RSS峰值911996KiB、无保护触发；原始XSim `TM4TN8_REAL_MATRIX_PASS rows=4 K=1024 N=3072 stripes=12288 group_records=393216 stalls=0 candidate=0`。四行逐stripe所有有效lane的dot/dotf/scale product/term、PS commit、完整身份/顺序、trace、Q35/D4债务和终态均与独立流相符。

[Wi LUT 120s pilot `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_wi_lut_pilot_01/input_manifest.json)与[Down LUT 120s pilot `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_down_lut_pilot_01/input_manifest.json)均按预定timeout停止，各停于row0 commit3584/20992和3584/10496；仅用于成本估算，不算功能PASS。使用同一受校验的已编译LUT快照，独立[Wi全矩阵 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_wi_lut_full_01/input_manifest.json)guard exit0、668.561s、峰值owned RSS920676KiB，XSim `TM4TN8_REAL_MATRIX_PASS rows=4 K=1024 N=5248 stripes=20992 group_records=671744 stalls=0 candidate=0`；[Down全矩阵 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_tm4_real_down_lut_full_01/input_manifest.json)guard exit0、320.065s、峰值owned RSS910176KiB，XSim `TM4TN8_REAL_MATRIX_PASS rows=4 K=2624 N=1024 stripes=10496 group_records=335872 stalls=0 candidate=0`。两者逐stripe核对四行全部有效lane的dot/dotf/scale product/term、PS commit、完整身份/顺序、trace、Q35/D4债务与完成，均无资源保护触发。ACT/QKV/Wi/Down四个真实流的LUT局部算术/PS范围至此PASS；回放不含HLS LOAD/FPGA动态量化、bias、物理writer或完整joint DMA，也无新综合/OOC/物理时序结论。

## T2 A+B 组合候选局部结果（2026-10-10）

[组合短整数 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_integer_combined_01/input_manifest.json)guard child exit0、19.018s、峰值owned RSS859844KiB。短XSim为`TM1TN8_INTEGER_COMBINED_PASS accepted=924 returned=919 flushed=5 checked_lanes=29408 checked_pairs=1040`，覆盖连续256次接受、bubble、在途reset及tag/oldPS；同时与旧基线、独立int64 dot逐lane比对。**同attempt的真实重放为FAIL_COVERAGE**：错误传入仅8条ACT向量而TB按136条执行，旧`qkv=128`为固定打印，不能采信；原日志/manifest保留。

[修复后的真实已量化group重放 `_02`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_integer_combined_real_02/input_manifest.json)预检对ACT8+QKV128来源manifest、四个hex SHA、各136条完整位宽与lane mask逐项通过；TB另对每条a/w/mask/dot未知位主动fatal，按实际接受和核对计数打印。guard child exit0、10.225s、峰值owned RSS859896KiB；XSim `TM1TN8_INTEGER_COMBINED_REAL_PASS act=8 qkv=128 issues=136 checked_lanes=4352`。ACT全部8组和QKV一行首末各64组均用独立signed dot核8lane，所有有效lane还比独立fixture dot；这是树级局部覆盖，不是QKV全矩阵。

集中核验另发现`_02`原runner的`rg -Eq`参数误用，异常词扫描没有执行；直接复查该attempt完整原始XSim日志无`Fatal:`/`ERROR:`且有最终PASS，数值结论保留。两组合runner已改为`rg -q`，在原日志为无匹配、注入`Fatal:`的短输入为匹配，并通过shell语法检查；不把这一脚本修正写成新的RTL仿真。

[组合真实ACT R0 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t2_r0_pack_lut_act_01/input_manifest.json)guard child exit0、44.050s、峰值owned RSS1990900KiB；XSim `TM1TN8_ARITHMETIC_REAL_PACK_LUT_PASS rows=1 G=8 T=1 issues=8 bubbles=252`。按当前ACT已量化fixture逐项核有效lane dot、dotf、scale product、term、每次PS commit、trace与Q35/D4终态；INT→F32、两独立FMUL及PS FADD仍走原R0配置。组合精确整数及此ACT R0范围`PASS_SCOPED`；DSP/LUT/FF实际映射、Fmax、完整矩阵服务、HBM LOAD、FPGA动态量化、bias和writer仍`NOT_RUN`，不得相加单A/单B的条件资源节省。

## T3 Q8S2 v2 实际 ACT RTL 局部结果（2026-10-11）

正式候选为冻结 [r2 模型包](../../../../../build/model-q8-session-v2-actual-r2-20261010/manifest.json)，build SHA256 `7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5`。[r2 CSim](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_csim_r2_03/guard/guard_result.json)及[HLS 生成](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_hls_r2_01/guard/guard_result.json)均 guard exit0；CSim 完成会话状态和 ACT 量化检查，但其完成回执是模拟注入。HLS 估计 Fmax 46.93MHz，未满足 150MHz 条件目标，不代表物理时序通过。

[最终 STRICT RTL](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_strict_05/guard/guard_result.json) guard child exit0、149.892s、峰值 owned RSS 2681288KiB；[最终 FAST trace-on RTL](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_fast_trace_02/guard/guard_result.json) guard child exit0、148.596s、峰值 2564852KiB。两者复用同一实际 HLS RTL/包装器与独立 ACT gold；[descriptor 差异收据](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_r2_02/descriptor_comparison.json)逐个命令只见 word64 profile 不同，q/scale/bias/activation/量化/output/trace/binding 输入字节相同。原始 XSim 自检分别见 [STRICT 日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_strict_05/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log)和[FAST 日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_fast_trace_02/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log)，两次均最终 `ACT_PASS`、无 Fatal/ERROR。

每profile均完成 REGISTER→LOAD1→RUN1→同session LOAD2→RUN2→REVOKE，外加14个短拒绝例。两次 LOAD 的 command_start→首次 done：STRICT 4447/4449 cycles、每次64次 scale 检查；FAST 4111/4113 cycles、每次0次，按相同边界各少336 cycles。两个profile各次 RUN 均5681 cycles。每RUN核缓存发射的2048B q、64个 F32 scale、2个 bias、8个量化 group、8个 dot/term/PS group、1笔物理8B输出和64个物理 trace 字；另核 ACT q/half observed、有效2个最终 F32、其余 observed sentinel。每命令计18次实际 binding 握手，末model R有限hold及末observed/output/trace B有限hold后才允许首次 done，所有适配器债务归零。负例包含 REVOKE后旧LOAD/RUN、reset后旧LOAD、ACTIVE重复REGISTER、旧magic/保留flags、错profile/generation/context/tag/build digest/BO size，以及真实wrapper BO base/cookie变化；拒绝例核状态非零、回执的done task与准入为零、无模型或activation读取、无输出或trace写并排空物理债务。REGISTER合法读AUX header 128B，未列为零模型读。该前轮TB尚未逐项核first-error owner、W epoch/高水位、拒绝后合法恢复；这些缺项由下述同一r2制品的合同增量回归补齐。


[STRICT合同增量 `_02`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_contract_strict_02/guard/guard_result.json) guard exit0、225.362s、owned RSS峰值2761320KiB；[FAST trace-on合同增量 `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_contract_fast_trace_01/guard/guard_result.json) guard exit0、206.097s、峰值2741504KiB，均无保护触发。[STRICT原日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_contract_strict_02/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log)最终`ACT_PASS profile=0 reject=23`；[FAST原日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_contract_fast_trace_01/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log)最终`ACT_PASS profile=1 reject=21`，完整日志无Fatal/ERROR。日志的register/loads/runs/revoke固定字段描述首条正常链，reject为全增量套件动态拒绝计数，含未单独打印marker的post-REVOKE LOAD。两次输入manifest保留同一冻结r2 HLS RTL/包装器身份和原输入/独立gold；本轮仅改TB，不新造包、不改DUT或gold。

增量逐项核拒绝的first-error owner、session reject/state、last task、W state/epoch/max/load次数、generation high-water和W绑定身份；8项descriptor-only错误恢复后均合法LOAD成功，真实BO base/cookie变化后恢复输入仍因INVALID slot拒绝。两profile坏AUX REGISTER只读128B header，INVALID且high-water1，同代REGISTER拒绝，更大generation2恢复。STRICT padded n2/g0 scale注入+Inf后首错element16、scale_checks17；坏bias首错element0，STRICT检查64个scale、FAST检查0个。两类坏LOAD均done task1、last task1、W max1保留而live W epoch0/W INVALID、session INVALID、active generation0/high-water1；同代REGISTER拒绝后generation2注册及W epoch1合法LOAD恢复。两profile坏activation先读完整16个64B拍，quant task2数值失败、A8 epoch1消耗，无group/输出/trace；ACTIVE与W READY/epoch1保留。修复activation后quant task3/run task4成功、A8 epoch2，并再次核8个独立quant/dot/term/PS group、2048B缓存q、64个scale、2个bias、物理8B输出和64字trace及observed sentinel。每命令继续核18拍实际binding和首次done全部物理债务零。FAST坏scale不属于静态包信任前提内的功能例，未运行。

[READY/reset闭合STRICT `_04`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_closure_strict_04/guard/guard_result.json) guard exit0、146.864s、owned RSS峰值2654276KiB；[FAST trace-on `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_closure_fast_trace_01/guard/guard_result.json)在仿真启动前复用逐SHA匹配的STRICT已编译snapshot，guard exit0、67.885s、峰值860344KiB；运行后其中`xsimkernel.log`由XSim改写，不能称全部输入运行后保持原hash。两份[STRICT原日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_closure_strict_04/work/vivado/tm1tn8_session_dma_act_v2.sim/sim_1/behav/xsim/simulate.log)与[FAST原日志](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_closure_fast_trace_01/work/simulate.log)均为`CLOSURE_PASS profile=0/1 reject=9 invalidated_ready=2 rebuild_runs=3`、无Fatal/ERROR。每profile两种已READY的真实base/cookie变化均撤销W/session，保留last task/W max/load计数与generation高水位，恢复输入后旧RUN/LOAD和同代REGISTER仍拒绝；随后各以generation2 REGISTER/LOAD/RUN重建。整域reset例先形成W READY，再拒绝旧LOAD（硬件高水位0）并generation2 REGISTER/LOAD/RUN重建。三次RUN各核2048B q、64 scale、2 bias、8组ACT数值、物理8B输出、64字trace和observed sentinel；冻结HLS/包装器、原payload/gold未修改。[短例失败`_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_closure_strict_01/guard/guard_result.json)为XSim字符串三元任务调用的native kernel异常；`_03`误用trace-off TB与实际trace-on输入不符，均保留原日志，不计硬件失败。

[合同增量STRICT `_01`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_contract_strict_01/guard/guard_result.json) guard exit1、102.101s、峰值2771996KiB，保留TB失败：reset后observed BO已清sentinel，新增比较任务错误地取它为先前设备状态。改为按无有效header识别reset空设备状态后上述`_02`通过；未修改DUT错误归属或缓存合同。此前正常ACT两次LOAD/RUN的周期在本次增量日志仍分别为4447/4449对4111/4113及相同5681 RUN cycles，profile收益口径未改变。

早期[STRICT `_03`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_strict_03/guard/guard_result.json)及[`_04`](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_strict_04/guard/guard_result.json)在错误 generation 负例因 TB 把 `O_BINDING_MATCH` 一律期望1而失败；该字段在实际绑定与 descriptor 不符时应为0。原日志已显示拒绝状态及无额外模型/activation读，修正 TB 期望后 `_05` 和 FAST 重跑通过。较早 [FAST trace-off](../../../../../results/compute_throughput_optimization_20261010/attempts/t3_q8s2_act_rtl_fast_01/guard/guard_result.json)虽然功能通过，但 RUN 4461 cycles 与 STRICT trace-on 的5681不具备 profile 可比性，未作收益结论。以上均为局部 RTL 仿真；未有真实 XRT/板端 ACTIVE、Host上传/完整读回计时、全图请求吞吐或150MHz物理达标证据。


### 2026-10-11 ACT 完整缓存 OOC 的 PS 存储阻塞与影响核查

`t2_act_full_cache_assembled_ooc_01` 在实际 ACT07 冻结源父层综合阶段被 semantic_stall 保护停止；guard elapsed 144.34642494097352s、owned RSS peak 5789944KiB、120s 无语义阶段进展，尚未到达已验证的 cache EDIF link。实际综合警告列出 `tm4tn8_microbench_v1` 的 `ps_reg` 671744 registers、`progress_reg` 18368 registers、`poison_reg` 20992 registers。失败 receipt SHA256 `b7efa8f87cf54a65cbf4433d560fff0ffd10d6598acfa83e2bc3e9dd374cc4f4`，资源仍 UNKNOWN，无完整父层 netlist/DCP；不以功能仿真通过推定资源可部署。缓存至 ACT 的累计 3600s 已消耗 649.8045405037701s，后续 guard 上限至多 2950s，禁止原样重跑。

联合 `design.md` §3.5 行199–215 已明确现行为是32个逻辑1异步读/1同步写 bank，并特别规定同步 RAM 候选必须先集中修订显式读返回、整stripe身份/容量预约、反馈及 II 合同。因此独立一维物理 bank 虽可消除3D数组展开，改为 BRAM 同步1拍读会改变当前 `old_ps` 采样边界，不能作为接口不变的普通修复直接接入。payload PS 不增加 reset/config 整表清零；group0仍固定+0，group>0读已实际commit的前一组。

候选影响需集中定义：32个独立lane PS bank仍为各656×32bit，共83968B；每bank同步1R1W以及实际读tag/有效返回；row/tile pending、progress、poison保持各自独立有效语义，progress/pending 当前复位/多写控制继续实付；Q35/D4各row容量与完整192bit tag不缩减。接入后重新测真实读预约→返回→算术issue→PS commit→下一同址issue，包含当前commit后两观察拍busy保护、同址读写边界、所有row信用守恒、非法tile/identity/version拒绝零issue、reset取消与不清payload恢复。旧异步读取的II1窗口和ACT反馈周期不能继承；驻留Down同tile全部G组也必须按实际反馈事件计量。同步bank合同尚未修订/接入，当前代码未作该结构变化。

### Synchronous PS v2 actual affected regressions (2026-10-11)

Pilot01 actual PASS: 32 PS +4 metadata banks full depth656 address/held-q/independent simultaneous different-address R/W; 2 complete stripe entries with E0 preclaims/E1 copy/E2 earliest launch, 256 four-row synthetic stripes, complete ACT8-group feedback, 5 zero-read/FP header rejects, independent row commit stall, trace ack debt and active reset. Native FP arithmetic remains original. Actual largeT acceptance gap1..3; ACT F_PS_min37, so sustained II1 is not proven. Receipt SHA256 `1207672e5d54d011fae433b93d747cd7cc46ab07d446e816d07c5e2f3a3397a2`.

Complete distinct-real-row Down RTL01 PASS: K2624/N1024/G82/T128, 10496 sync reads/copies/launches, 41984 row commits, all335872 lane-group original gold records (dot/dotF/scale product/term/PS and selected traces), no PS preload. Credit stall598, busy/front/launch/commit stalls0. A/W are external immutable prequantized stripes, so this is affected PS/arithmetic proof; resident physical cache, native bias/finalPS/writer and full13BO remain pending. Guard0/null377.579143s peak2333636KiB. Receipt SHA256 `05b13a554677833389de0559961b1f158a66b974b4145a3dde3317ac949bf6cb`.

### Resident physical-cache bounded pilot (2026-10-11)

PASS_SCOPED_PILOT `t2_tm4_matrix_resident_pilot_03/receipt.json`, SHA256 `8d173068071ef0eb56a4f2dc9ad99c5563ccf8e2f5ff497b03220f0bbe4e59ed`. Actual integrated TB/DUT/nativeFP full-cache static compile/elaboration in `_02` is PASS (57.002336 s, 2374560 KiB, guard0/null). `_01` retained TB reserved-block-name syntax failure; `_02` RTL entry retained Vivado property-option parse failure before simulation. `_03` reuses unchanged `_02` compiled DUT/TB/IP/gold, only fixes runtime Tcl property syntax.

Pilot guard0/null 85.63943343423307 s under hard120s, peak1422764 KiB. Physical dualA complete fill via ports:656 half commits/328 scale commits; strict full Down W LOAD real R44608 (20992/20992/2624) and83968 scale checks. Loaded cache hex is byte-identical to original immutable Down binary matrix. Cycle27755 W publication ->28073 finish;3 A group reads/288 actual real stripe returns,1024 exact original-gold rowPS packets /8192 lane-group. Pilot exits an active prefix: no final output/B/owner retirement/source release proof. A is explicitly supplied as prequantized original fixture; G/quant chain is independently covered in bridge04, not in this TB. No13BO/current full-package binding, frequency or board result. Conservative full estimate1200s based on pilot setup cost and existing actual full-sync Down377.579143s supports one full run under unchanged8GiB/3600s/40M/semantic120s limits; full result separately recorded.

### Stage-close full physical-cache resident Down/output/last-B (2026-10-11)

PASS_SCOPED `t2_tm4_matrix_resident_full_down_01/receipt.json`, SHA256 `f0d8d0682f97c28852143c8f4fb2c809cbc85f5778ae916f792bf40779cfe791`. Actual guard0/null 421.8807475399226s, peak 1424044KiB; cycles48862. Unchanged compiled source/TB/IP/gold from pilot02/03; full-mode simulation removes pilot flag. Four distinct original enc0 Down prequantized A fixture rows enter actual complete dualA ports (656half/328scale), actual strict full W LOAD (20992/20992/2624 R beats +83968scale checks), real full-identity leases/held returns, all82 A groups/all10496 W stripes, synchronousPS all41984 row packets/all335872 valid lane-group PS compared to original gold, finalPS adapter/bias_kind0 bypass, all4096 original F32 output words, actual AW/W/B512 each and final-B/debt-zero barrier, physical A/W source release and real local owner-ledger READY/publication. Held B9217cycles;512physical beats=32768B for16384B useful output, because four-row tile ordering emits8-word partial beats. No sustainedII1/full-width writer/Fmax claim.

Resident TB separately checks final PS/output, not each internal dot/dotf/product/term; unchanged arithmetic full intermediate proof remains separate sync_real_down_01. No G/quant in resident TB: bridge04 separately proves newG banks→quant→A but test boundaries are not seamless fullgraph evidence. Initial reset/normal backpressure/delayedB only; resident late error/recovery, CE/active reset, first-error competition/multi-view16row, dualA/twoW overlap NOT_RUN. Down kind0 bypass does not exercise native8FADD nonzero-bias numerical path or bias reset quarantine; those stay NOT_RUN. Current production C/FIFO/13BO shell binding, resident OOC/P&R/frequency/board remain NOT_RUN/NOT_MEASURED. No new full CPU/CSim package or Host/public config build signed. Stage is closed at these scoped results; no new scope started.


### E003/R003 current portal and resident cancellation regressions (2026-10-11)

Evidence root: copied-project `project/E003_production_chain_closure/experiment_results/runs/R003` (outside this implementation root). `codec_01` strict C compilation and independent1536-byte oracle PASS. `transport_05` actual Vivado2025.2 RTL PASS,432cycles accepted4/retired5/stale1; guard child0/trigger null,27.376194s, peak1397160KiB. Scope is transport control with a controlled service endpoint; no physical numerical/cache/13BO claim. Prior transport01/02 script failures and03/04 same-delta TB sampling failures are retained.

`matrix_binding_03`: actual binding/resident/nativeFP static compile/elaboration PASS (52.622385s,peak2390920KiB); bounded RTL PASS (17.472260s,peak1369892KiB), guard0/null. Seven actual service commands/responses cover six cancels: before A acquire acceptance, after accepted A acquire before completion, accepted W lease before completion, accepted A read before return, accepted W read before return, and accepted AW/W before B. The final command is a normal real K256/N2 recovery; two writes across cancellation/recovery have actual AW/W/B2 each and four independently expected zero F32 words. A/W endpoints are explicitly controlled diagnostic lease/read endpoints, not actual caches or original model data. No fabricated service completion is used: actual resident/datapath/ledger produce it. Matrix binding01/02 retain cycle-cap failures at W release, resolved by accounting accepted W read debt before ret_valid. Original full-Down resident regression predates these source changes and cannot certify the current implementation.

`abi_original_01`: actual old generated13BO/control ABI extracted and hashed, roles13/register words26. This reference is historical generated identity, not current production generation PASS. Base mirror validation is in progress and final generated connection/width conversion remains NOT_RUN. L0 PARTIAL/L1 running/L2–L5 NOT_RUN; M004 full model, complete request performance and current resource closure remain unaccepted. No new OOC/P&R/board run.

### E003/R003 current resident normal path, BO mirror and ownership (2026-10-11)

`resident_regression_01` current-source static PASS58.004826s/2367140KiB; pilot PASS84.017539s/1423260KiB; full PASS454.920886s/1424576KiB, all guard0/null. Full48862cycles, four original distinct Down rows K2624/N1024,10496stripes/41984rowPS/335872lane-groups,4096 independent F32 outputs,512actual AW/W/B each,heldB9217cycles. All actual fullA/dualW/nativeFP/local-owner/finalB checks pass after the accepted-W-read debt repair. This certifies the affected normal resident implementation, using explicitly prequantized A fixtures; same-runtime Wi/G/quant and original13BO remain outside its scope.

`base_mirror_02` PASS595cycles,13roles/26initial words/all16WSTRB masks/61native writes/3atomic snapshots against the actual historical generated pointer controller. Guard0/null19.594342s,1294832KiB. Attempt01 retains a TB snapshot variable overwrite failure; only the helper local snapshot was repaired, DUT/criteria unchanged. Current generated request-accept binding is still pending.

`axi_owner_02` PASS134cycles,actual AR4/R8/AW3/W6/B3; held lastR,heldB,W-before-AW,offered AW under backpressure,concurrent read/write,clear_error without debt erasure and early-LAST fault/recovery. Attempt01 retains a TB handshake sampling cycle-cap failure; helpers now observe the actual pre-NBA handshake edge instead of rereading READY after retirement. Payload vectors including response/error/ID/sidebands are compared intact. This is one local BO arbiter with independent manual peers, not a current13BO/same-runtime numerical-chain proof. Longer-than-declared R bursts and malformed generated-master recovery remain unverified.

### E003/R003 actual converters, native BO wrapper and LOAD cancellation (2026-10-11)

Evidence root remains E003/experiment_results/runs/R003. `dwidth512_03` and `dwidth128_01` PASS with actual AMD axi_dwidth_converter2.1 (SI512/128→MI32, address64),2344/2408cycles,24.506518/24.925118s,peak1613640/1600148KiB,guard child0/trigger null. Each verifies2048B reads,8192B independent write/sentinel comparison with sparse WSTRB, high32-bit addresses, AR/AW2 split at4KiB, native R/W512 and B2, SLVERR/DECERR aggregation, held final R/B and upstream backpressure. Attempts512_01/02 retain a final-B same-edge TB accounting failure; the check was repaired to include the actual final MI B handshake in that edge, without weakening the standard. The full-width128 test does not independently certify narrow8B AUX; that is assigned to the integrated native LOAD test.

`axi_13bo_owner_01` PASS372cycles,13BO×2owners=26actual transactions,AR/R/AW/W/B26each,26heldR/B cases and all45 named native fields,23.452140s,peak1328940KiB,guard0/null. Reference is the historical generated ABI, not a current generated controller. `axi_owner_02` malformed overlong-R recovery remains unverified.

`load_portal_01` PASS758cycles,commands/replies7,3cancel cases,actual q AR6/R192 and AUX AR8/R50,23.222173s,peak1473660KiB,guard0/null. `load_portal_02` supersedes the binding implementation with pending-response cancellation and BO-span overflow checks: PASS1143cycles,commands/replies11,5cancel cases,2overflow rejects,1AUX RRESP error,2normal recoveries,external-debt barrier; actual q AR9/R288 and AUX AR14/R77. Guard0/null23.095349s,peak1468772KiB. Both instantiate one full-capacity physical dualW cache and independently compare q bytes, half1 scales and nonzero F32 bias(+1.5/-2.5) on actual stripe lease/read/release. Inputs are diagnostic and native wide peers are manual; no real-GGUF/current-generated/13BO-chain claim. Generic cache error mapping does not prove original AXI first-error precedence. Sideband cancellation of an already offered service response is tested as explicit cancellation, not ordinary uninterrupted stream payload stability.

Applicability correction: `resident_regression_01` remains PASS only for its frozen sources, before the subsequent reader/cache load_cancel changes. It cannot certify the latest dependencies. `resident_regression_02` is the affected current normal-path rerun: static PASS56.586667s/2407008KiB and pilot PASS87.111961s/1426128KiB,guard0/null; full PASS424.467004s/1422652KiB,guard0/null,48862cycles,4096independent F32 words and512actual AW/W/B each with final-B publication. The real-GGUF four-row Down gold and prequantized A fixtures are unchanged. `load_native_01` retained a FAIL from the TB assumption that FIFO_MODE0 could retire the last MI word while holding the final SI word. The generated actual IP downsizer assigns SI valid from MI valid and word_completed and gates MI ready with SI ready; its final word is cut-through. The repaired case now explicitly requires that real MI LAST remain held while SI is stalled, preserving both debt and no-early-ownership/completion standards. Actual SI/MI REGION ports are explicitly wired in the current adapter.


`load_native_02` PASS17275cycles,13commands/replies,6cancel cases,2range/BO overflow rejects,1actual AUX RRESP error,3normal recoveries,external-debt barrier and pending-cancel/READY race. One default full-capacity physical cache,3actual AMD512→32 converters and1actual128→32 converter,one full13BO native owner wrapper. Actual q AR23/R5633 (including the final controller owner0 probe),AUX AR18/R366. Independent cache stripe comparisons preserve diagnostic q bytes,all padded half1 scales andnonzero bias(+1.5/-2.5). The8B AUX tail is actually converted to32-bit memory transfers and checked through the physical cache. Held converted finalR retains real MI LAST,accepted SI debt and owner grant during cancel; no completion is allowed until both sides retire. After recovery a controller native read usesID1/USER1/LOCK2/REGION9/CACHE10/PROT6/QOS7 and independently checked bytes,held return and native debt. All normal/cancelled LOAD and controller-probe responses come from actual RTL/IP endpoints, with manual memory peers; current generated caller/real GGUF/same-runtime Wi→Down remains unverified. Guard child0/trigger null33.584732s,peak1831992KiB;26generated IP/source files are hashed. One vendor fifo_generator simulation out-of-bounds warning is retained in the raw log; no ERROR/FATAL occurs in the passing run. No OOC/resource/Fmax/board conclusion is drawn.

Current/frozen implementation identity check after the final runs matches all11LOAD-portal,26resident-regression and21native-LOAD manifest file pairs; receipt manifest hashes also match. Native converter and owner implementations are current for these scopes. Earlier attempts remain frozen and must not certify later source changes.


`load_native_03` supersedes the native adapter's current source with complete selected native offered/visible-channel admission barrier: PASS18863cycles,14commands/replies,controller AR offer held15cycles before real acceptance/R retirement/LOAD admission,6cancel cases,8B AUX tail and all previous scope. Actual q AR26/R6146 includes2controller probes, AUX AR20/R400; guard0/null34.301440s,peak1839268KiB. All21current/frozen file pairs match. Native02 remains PASS only for its earlier frozen adapter; resident02 remains applicable because its actual cache/reader/datapath/TB dependencies were not changed by this adapter-only repair. No complete generated caller, model numerical chain, resource or board claim.

## 2026-10-11 新冻结局部验证

- codec_v2_02 PASS：四service、406mutation，独立6144B逐字节oracle。codec_v2_01编译失败保留于codec_v2_guard_01/driver.log，旧runner未冻结失败preimage，不能补称其具有完整冻结。
- transport_v2_02 PASS836cycles；最新版transport_generation_02 PASS1786cycles，accepted9/retired23/stale2。9类坏头超大g、10first-push cancel、partial/bad-tail可信g耗号、末响应读/cancel竞争、同session/新session恢复及跳号覆盖；20.442486s、peak1580948KiB、guard0/null。仅受控service端点，不代签真实hub/parent联动。
- load_native_v2_01 PASS18863cycles：14commands/replies、6cancel、2overflow、1AUX错误、3恢复；q AR26/R6146、AUX AR20/R400；35.675456s、peak1819492KiB。默认完整cache、四真实AMD converter与13BO owner，仍诊断数据/manual peers。
- matrix_binding_v2_01 static/pilot PASS56.545527/18.367958s，旧7命令6取消与K256/N2单view恢复范围保持；控制A/W端点，不证明多view父租约。
- reservation_03 PASS：128窗口/385typed/769门户票据、rows1..16的尾view、未发g不回收、同generation下一request重建与u64溢出；Controller仅syntax通过。host sizeof TaskReservation260B/GDownWindow264B/GDownPlan33936B，非RTL资源。
- parent_a_01 PASS10309cycles：真实完整dualA，3fills/3acquire/3release、9local views、7实体/覆盖拒绝、94464独立q字节比较，held末A return阻止release，窗口间cancel等external debt，same-session下一request恢复。23.679215s、peak1397844KiB、guard0/null。预量化诊断fixture不代签G/quant算术、真实source provenance、matrix联动或模型链。

所有上述结果仅适用于各自冻结输入；L0/L1 PARTIAL、L2–L5 NOT_RUN，M004未完成。新parent、matrix多view/首错、GATE同epoch跨窗口/分期、唯一持久hub及caller继续实施。无新OOC/P&R/上板。
## 2026-10-11 当前tensor与真实四view父路径

`R003/matrix_tensor_02`为PASS_SCOPED：3529 cycles，最多128父任务/512 views/2048行，同一dst epoch多父覆盖；早父不提前发布tensor，后父失败保持全局失败，跨父取消与同session task-id恢复、七类拒绝及三次完整tensor publication通过。`matrix_parent_current_01`在接入该ledger后重新取得static/pilot局部PASS。

`R003/matrix_parent_views_07`当前static/pilot均PASS。static 58.001144s、峰值2413404KiB；pilot 382.907547s、峰值1389172KiB、128440 cycles。18条命令/响应包含旧单view取消/恢复和9条实际rows4父view；同父各view使用不同portal generation。成功rows16父、跨view空档取消父、同session更大request恢复后的失败rows16父各只物理取得/释放一次A/W，父TaskDone仅成功/失败各一次，取消空档不伪造TaskDone。真实路径累计AW/W/B各2563；成功父与取消前view的2,560个32B部分beat逐地址/WSTRB检查，末view第512个B反压后才释放。失败父四view继续必要FP/PS检查，受控合法u64 rank由2112000更新为较小5280并在后续响应保持；该注入只签父归并。正常输出为独立诊断零数值，不是模型数值证明。

本轮同时修复view成功位：owner retire后writer会清configured/coverage，旧组合读取使中间view响应`published=0`；现于真实retire握手锁存本view成功。input manifest SHA256=`d42efa43c511b8a5b95cbb88cc444b43a54fd382a1c02ee546b9d7dff0ad69fe`，receipt SHA256=`8782d874db30980652e9f9ef667205e138271e683bdc3b2f05daa6077da1366a`。`matrix_parent_views_01..06`的编译、形状/epoch、partial-beat期望及view-published失败均保留，不改写为PASS。该结果不代签物理fullA/fullW cache实现、13BO、统一hub、真实Q/G source、完整CPU/CSim或全模型链。

### Matrix full 成本拒绝记录分支（2026-10-11）

`R003/matrix_cost_stop_branch_01`以合成3601s估算对3600s上限执行当前runner的真实拒绝函数，得到结构化`COST_STOP`、`started:false`；最终manifest SHA256=`01a85a6aedf2cc10d99221bce2fe5fda778e042206e6e5c8dae4ead82ac5f96a`并由receipt精确绑定，且不存在`guard_full`、`full.log`或`full.jou`。verification SHA由该目录文件记录。该检查未启动Vivado，只验证超帽拒绝、最终manifest/receipt一致性和“full未启动”记录；它不是matrix功能、pilot或full PASS。历史`matrix_parent_views_07`的382.907547s功能PASS与600s pilot预算DEVIATION保持原结论。

### 真实 fullA/fullW 父门户集成（2026-10-11）

`R003/matrix_parent_cache_03`为**PASS_SCOPED_RUNTIME**。当前v2 matrix binding直接连接实际`quant_dual_a_v1`和`t4_dual_w_cache_v1`，同一个rows16父任务由四条rows4命令执行，portal generation分别为100–103；完整L、P/Q、A/W/PS/dst及NumericIdentity保持相同。A以原四条不同Down预量化行循环填满16行，物理提交2624个half和1312个scale；W仍由严格三口物理装载完成44608个R beat及83968个scale检查。

static/pilot/full分别为62.534447s、92.153086s、1725.782300s，峰值RSS分别2402668/1424544/1428584KiB，全部guard child0/trigger null。full为114182 cycles：四个view实际执行41984 stripes、167936项独立PS gold、16384个独立最终F32 gold；真实AW/W/B各2048次，最后B累计held 36865 cycles。中间三个view后A保持IN_USE、W reader保持1，末view后A实际release为EMPTY、W reader清0；四view覆盖`0xffff`，父TaskDone/parent publication恰一次。该单父只覆盖tensor前16/256行，tensor保持FILL且publication为0，未错误提前READY。

input manifest SHA256=`e87ba8097dad18e54078ef18e964c4c45ccabd62f60cd29a1db8a2498c55231d`，receipt SHA256=`2b51a19397dbade08bc8ab65c5ae69e35ec958ba6938e0434182fdf1bcbe1b3c`。运行前成本依据取两次冻结同矩阵/缓存单view实测的较慢454.920886s，四view×1.5保守估算2730s，小于3600s后才启动full。`matrix_parent_cache_01`保留旧QUANT op字段造成的frame拒绝，`_02`保留首父row0非零造成tensor ledger拒绝；二者均未进入目标matrix覆盖。

本结果首次闭合受控预量化fullA→实际fullW→真实父matrix的缓存与数值路径，但A尚未由同runtime实际GEGLU/QUANT生产；同tensor多父、后续父失败的全局状态、LOAD→Q/L调度、唯一hub/generated caller、L2/L3和当前完整CPU/实际CSim仍未完成。L0/L1保持PARTIAL，M003/M004未完成。

## 2026-10-11 same-runtime G/QUANT→父matrix组合与成本停止

新增`laya_gate_quant_matrix_parent_tb_v2.sv`，把`geglu_gate_quant_split_v2`内部真实fullA的acquire/read/release端口直接连接`laya_matrix_portal_binding_v1`；不再由TB写A。测试保留四G窗口、独立Q0、真实fullW、四matrix view、独立PS/F32 gold、实际AW/W/B，并新增A acquire/release与W lease/release握手计数。当前静态连接已在`gate_quant_matrix_parent_03`通过：84.239673s，峰值2741104KiB。

同一no-wave batch profile的一行真实G pilot通过：11773 cycles/63.410458s、峰值975140KiB，164个物理GATE AW/B，Q和matrix明确NOT_RUN。用已通过完整组件的758736+114182 cycles作为冻结完整工作量上界，按当前185.663 cycles/s并加10%余量投影5172s，超过3600s；因此`gate_quant_matrix_parent_03`记录`COST_STOP/started:false`，未启动full。manifest SHA256=`f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`，receipt SHA256=`042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。

`gate_quant_matrix_parent_01`在旧runner仅采用两个分立full墙钟总和×1.25=3476s后启动full；组合pilot/live速率随后证明该依据不适用，工程在591.128178s主动SIGTERM安全停止，记录FAIL/无PASS marker。`_02`修正为按组合pilot速率停止，`_03`进一步关闭whole-hierarchy WDB观察后仍投影超帽。失败与成本停止均保留，不提高上限、不删减full覆盖冒充PASS。故实际QUANT fullA→父matrix的当前源码已静态闭合，但同runtime完整功能仍NOT_RUN_COST；多父、hub/caller和完整链继续未完成。

## 2026-10-12 generated provenance 基础阶段证据

本阶段六项当前冻结结果均为限定PASS，聚合核查的284组current/frozen文件身份全部匹配，无漂移：

- `generated_provenance_codec_04`：LPV1/LPA1固定字节codec、完整response绑定、8类保留字段突变和独立Python byte oracle通过；1.731568s，19/19文件对匹配。receipt SHA256=`89b446ec9679231bb3eec640d146134b7d8410cd18702314277ff07093c10a39`，manifest SHA256=`9d1549c47064f4358ebca060c41fcdba5965a789110d9370af5c3dee9b17dc8c`。
- `generated_provenance_ledger_05`：64项CPU事务语义检查通过，覆盖owner生命周期、replay/high-water、坏END scope保留、失败END一次封闭、same-session恢复与QKV pair原子转换；23.331393s，82/82文件对匹配。receipt=`d63ac8e397826b0424131fbcb15a9020c0d602eadf9d851b827a53af6a555410`，manifest=`0660ea931d54b828ed8aedefe954e680167d914541e90c094d95b6440374b117`。
- `generated_provenance_events_09`：CLAIM/PUBLISH、LN/AV/RoPE geometry、persistent event allocation、实际store accounting和deferred typed retirement的81项检查通过；最终event seq 7、partial store bytes 8、typed task只退休一次；22.001536s，82/82文件对匹配。receipt=`f46ced64ee4c2c9cf2957d56e5f7138603d0da42f23a6eaeca312f373bfcabc4`，manifest=`fbe8b83b884962b0e09d38b10d1a017e51b61070f671f55ffb00d1c4dd5481ae`。
- `portal_controller_27`：当前生产源码闭包下B1/S64的25条compute command/13个typed task控制路径通过，generated provenance event为2、store bytes为65536、deferred retirement一次，坏END保持scope；24.802532s，82/82文件对匹配。receipt=`779a7b312535cb9ba92d66e3fb0ae83d6c9998cde2546a2695b774225a27ce33`，manifest=`ef62dbb5b8f878c9a6d0d88ebecb58776ed338a674a6bdbbd9ce0708733016da`。
- `generated_provenance_portal_07`：从production registry取得RTL闭包，16/8拍transport与持久hub在受控物理观测下通过；accepted14、retired17、semantic rejection2、terminal task2，覆盖END scope保留、QKV原子性、坏头大seq不污染高水位和cancel cleanup；805cycles/21.683431s，11/11文件对匹配。receipt=`ed8e0745e62746e863fc5a4144e60d61331859b2491c87d0728bf097cd9a874d`，manifest=`fdbd7c0df8fb8274a3a68a931b172f722ead1c450f07512c1b918f6247420fe9`。
- `generated_provenance_fifo_probe_02`：工具生成四条512-bit depth2 ap_fifo的12根方向/极性信号全部匹配；23.163817s，8/8文件对匹配。receipt=`c886784eb38ba536964e1e963d5727b455de8be123b86b8286b44283bedd3381`，manifest=`821e95ea95cc8c579e932fa15a2933544348b3c963cf19c42ced710fd2d50656`。该结果包含生产wrapper签名/pragma，但production top本身未综合。

聚合核查见E003/R003的`generated_provenance_base_stage_20261012/verification.json`，SHA256=`dd5f64ab439050817d02a51be200d781c823f90911ea38d1a0a0636ab8e03487`。`generated_provenance_portal_01..05`、`ledger_01..02`和`events_01..03`的失败attempt全部保留。

上述结果不证明真实generated AXI/WSTRB覆盖、posted-store/adapter fence、production top四FIFO综合、普通QUANT来源lease、数值payload或完整图。L0/L1继续PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；本阶段没有OOC、P&R或上板运行。

## 2026-10-12 generated provenance审核修复与真实AXI monitor

主控审核提出的F1/F2/F3已在当前闭包取得受影响PASS：

- `portal_controller_29`验证合法且身份匹配的`scope_active=1`错误END不清tracker、不推进`last_task_id/tasks_retired/op_calls`，终态END仍只退休一次。23.144976s、260820KiB；receipt=`cbb35b67b82e219833e85da05afa3a2e501da73a6ab3a7e111cd694358bf0739`，manifest=`54639a160b885121c9497f71348b6d59ab3c5fd9c97d0a3dffe0be8759c5568c`。
- `generated_provenance_ledger_07`完成301项CPU reference检查：未排空END等待真实fence、33次同session递增request安全回收typed槽、迟到旧request拒绝，并保持QKV原子与恢复。22.229241s、260884KiB；receipt=`b8df6625fbf24b7a41a9501fefdce06778ccf16aadcd6fb329a32720d375701d`，manifest=`757b522a2f71427483b59dc25bea0ee43df25a9bb4c90e726102028d2fc2aa12`。
- `generated_provenance_portal_10`在当前9文件production registry闭包下验证同一未排空END/fence与33-request回收：7107cycles，accepted148、retired151、semantic rejects4、terminal35；22.966027s、1435972KiB，guard trigger null。receipt=`987f7ab09274392e51079978c7e79f875674db3e61446b7e84a09dcac687c5ec`，manifest=`c197e6da3c25062bba29f844fb5f817b4ccc3488b38636d639f71b3f1c1f7aaa`。物理观察仍是受控TB输入。

首个真实store monitor在`generated_store_monitor_03`为**PASS_SCOPED_RUNTIME**：一个role6/单descriptor/连续rows16 owner执行1024个真实AXI512单拍写，AW/W/B向peer各1024；monitor累计AW/W各1024、B退休1026（含两个本地拒绝），唯一覆盖65536B。覆盖W-before-AW、末B反压12拍、显式adapter fence延迟8拍、越界写转发前DECERR、非法两拍burst完整吸收两拍W后DECERR、不支持role的BEGIN写前拒绝和同session cancel恢复。5961cycles、23.567974s、1459396KiB，guard trigger null；receipt=`e46f6c8f60a82527e012764f09b1f1ed12f0621b9a70719a626af90fd6fe4c45`，manifest=`b6ee73cb068216e67c4e262068be4d3e0e0109180f53c5561147751aa6986a29`。

`generated_store_monitor_01`保留SystemVerilog保留字导致的编译FAIL；`_02`保留非法burst排空期间重复处理首拍事务的断言FAIL。`_03`只修复保留字和排空状态重入，不删除工作量、gold或断言。聚合核查191/191 current、191/191 frozen和580/580文件引用匹配，见`generated_provenance_monitor_stage_20261012/verification.json`，SHA256=`95d5aaf0a708a67f8bbf93b2310458b51af9de7dab18f12f8d9bcc4235735ab1`。

这些结果没有证明generated HLS adapter提交计量与真实`adapter_pending_zero`的因果、production top真实master、多role/QKV monitor或普通QUANT source lease。L0/L1保持PARTIAL、L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成；没有OOC、P&R或上板运行。
## 2026-10-12 generated provenance取消/fence受影响回归

`generated_provenance_codec_05`、`generated_provenance_ledger_08`、`generated_provenance_portal_11`、`generated_store_monitor_04`和`portal_controller_30`均PASS。portal为7161cycles、accepted148/retired152/terminal35，确认未排空拒绝、owner fence wait及中途首错sticky；monitor为6073cycles、AW/W各1025、B1027，确认活动cancel、BEGIN response背压、cancel后posted store、W-before-AW、held末B、adapter fence和匹配END ingress。CPU ledger保持301项检查、33-request回收与旧request拒绝；Controller当前闭包保持scope-active错误END不退休。

聚合核查213/213 current、213/213 frozen、213/213 pair和634/634文件引用匹配；`generated_provenance_cancel_fence_stage_20261012/verification.json` SHA256=`0b84d634a8eda46d1bd070edeeafa7ad17ce11d52e63e6a0c38c984dcdb96064`。完整receipt/manifest SHA及范围见E003/R003的`generated_provenance_cancel_fence_milestone_20261012.md`。

该PASS不包含HLS adapter内部待发事务到`adapter_pending_zero`的生产因果、production top真实master、普通QUANT source lease、多role/QKV或完整数值图。L0/L1保持PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST，M003/M004未完成；无OOC、P&R或上板。

## 2026-10-12 普通source账本、原子lease与真实QUANT

当前persistent hub与共享普通QUANT/fullA入口取得限定同runtime PASS。`generated_source_lease_01`以四个不同P Context闭合B1/S64的四个rows16窗口，前三个窗口不发布tensor，第四个窗口后才允许PUBLISH；完整身份、L13M、Ref、range与旧generation拒绝、未排空lease保持、活动lease阻止owner release及更大generation重读均通过，688cycles、26.483698s、1,487,968KiB。

`gate_quant_source_lease_03`的static/pilot均PASS。static为56.994760s/2,203,220KiB；pilot为4493cycles、12.619174s/856,736KiB。一个stage2/K1024、rows16普通Q实际发出16个AR并接收1024个R，执行512个quant group、1024个half commit和512个scale commit；16,384个F32/INT8元素及512个FP16 scale与冻结gold逐项匹配，fullA的128个四行group全部读回。数据由八个独立冻结group在每行内重复四个group block并跨16行使用，不代表16,384个唯一向量。未发布Q在AXI读前被拒；成功lease跨response背压保持，只在读债为零且response退休后释放。

受影响回归`generated_store_monitor_05` PASS6073cycles、26.074358s/1,536,064KiB，保持19 events、4 terminal、AW/W各1025、B1027、65536B唯一覆盖以及活动cancel/posted-store/W-before-AW/末B/fence路径。`generated_provenance_portal_14` PASS7161cycles、26.630436s/1,500,580KiB，保持accepted148/retired152/terminal35、33-request回收、QKV原子和取消/fence边界。四项当前attempt的93/93 current/frozen/pair与435/435 manifest引用全部匹配；verification SHA256=`3ba2edbcad017bdc3617ae4ed4167bdad3ed6ae673e40d7134664dad44a8faab`。

保留`generated_provenance_portal_12`编译FAIL、`gate_quant_source_lease_01` END geometry拒绝和`_02` stage2/K256白名单拒绝。当前producer物理观察仍由TB控制，未证明production generated-HLS master/adapter fence因果；普通/GATE切换、其它shape/跨batch/multi-role/QKV、LOAD、matrix、完整请求及当前CPU/实际CSim仍未闭合。L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成；无OOC、P&R或上板。

## 2026-10-12 F5、真实fence、来源切换与production HLS

F5受影响回归均通过。`generated_source_lease_04`拒绝4个非尾rows1关闭与稀疏发布，完整四个rows16仍发布；26.835888s、峰值1,495,776KiB、1628cycles。`gate_quant_source_lease_04` static/pilot为57.251185/12.554886s，pilot 4493cycles，保留16 AR/1024 R、512 group和128个fullA视图。`generated_store_monitor_07`为6081cycles，END-before-first-AW、adapter fence8拍、W-before-AW、活动取消、末B及同session恢复通过。`generated_provenance_portal_16`保持7161cycles、accepted148/retired152/terminal35；`portal_controller_31`为当前C++回归身份。

`gate_quant_source_switch_04` static/pilot PASS：53.445391/21.776526s，12270cycles。一行真实G的WI AR/R为6/328、GATE AW/W/B均164、末B反压12拍；随后无复位执行stage6、role6/ref10、K256普通Q，实际1 AR/16 R并核8个fullA group。GATE owner保持partial resident，普通Q未用GATE lease。

`gate_quant_source_switch_b2_03` static/pilot PASS：54.103059/27.772653s，15889cycles。同一G后执行B2/S64、batch1、row48、stage2、role6/ref1、K1024、rows16普通Q；物理首地址`0x300431000`，实际16 AR/1024 R，128个四行fullA view全部匹配冻结gold。`_01/_02`的role/BO准入错误保留。`gate_quant_source_switch_03`虽功能PASS，但两个derived fixture覆盖早先冻结记录造成两项manifest漂移，已由`_04`的零漂移结果替代。

production HLS `_01..07`全部保留。`_02/_03`分别暴露私有与跨目录头漏冻结；`_04`后所有源码完成分析并达到13,223,459条Compile/Link instructions。artifact进展修复后的`_05`产物增至约108MiB后真实停滞120s，375.506907s停止；`_06/_07`的inline/noinline实验分别380.544045/375.533350s停止且规模不变，临时源码已撤回。当前production源码与`_05`的115/115 source pair一致，因此完整HLS生成、12信号及真实generated master仍为BLOCKED/NOT_RUN，不再原样重跑。独立`hls_artifact_progress_guard_01`证明不变和缩小不刷新、增长与新文件才刷新语义进展。

阶段核查`production_source_switch_stage_20261012/verification.json` SHA256=`2178c37ce652b9b70b9efb34b1fd7a3a9b2e5e23e337be7d0ee0bbe8db3f82d8`。八项限定PASS的268/268 current/frozen/pair匹配；881项引用中877匹配，四项差异均为后续更新的同一live `production_guard.py`。HLS七项779/779 frozen与pair匹配，769/779 live匹配；十项差异是后续runner/guard修复和已撤回pragma。完整说明见`R003/production_source_switch_hls_blocker_milestone_20261012.md`。

边界：来源切换的query grant及generated store的物理写仍由TB控制，production generated master/store helper/adapter pending因果未闭合；row-space1、QKV、LOAD、其余Q/L、matrix、当前完整CPU/实际CSim和完整请求仍待。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST，M003/M004未完成；无OOC、P&R或上板。
## 2026-10-12 B2/S128 MARKER 来源切换

`E003/R003/gate_quant_source_switch_marker_01` 的 static/pilot 均为 **PASS_SCOPED**。static 用时 52.798120s、峰值 2,140,892KiB；pilot 用时 37.043571s、峰值 856,636KiB，共 15,889 cycles。真实 G 行后无复位执行 stage5、physical role7、`HEAD_WORK` ref10/region0、row-space1、batch1、K1024、rows16 的普通 QUANT：source AR/R 为 16/1024，128 个 full-A 四行视图全部通过，16,384 个 F32→INT8 与 512 个 FP16 scale 逐项匹配独立 gold。partial GATE owner 保持 resident，普通任务未借用 GATE lease。

production DUT 与独立 oracle 的完整 B2 `marker_norm` 输入逐位一致；完整 checkpoint SHA256=`969cf212034ccf7a5d6bb785e59ccbfce84cbd2fa9233591f506176076f7c10a`，batch1 source=`4fc1efc97344aed93b21011206e78b71f63ab084e9112b84351411ea9cb83b93`，Q=`85a6473765c2f77004527866ec9574d40cf52e6123e0da3d92cf39de6caa4e7a`，scale=`c59ddd727babc19c112456f20d32d9b94c27fe4ec994a9eb6645e2b80780600f`。manifest SHA256=`3334769dfa0f494fe574166f8770b3cdfd3473492724841cca3e8443b332ef0f`，receipt SHA256=`d9f75b734d3bf14c4b6ce2921ff7b17b593050e252b43d43b772a5e7dc706e18`；43/43 current、43/43 frozen、105/105 引用匹配。

此结果不签 persistent hub、production generated master/adapter fence、完整 GATE tensor、LOAD/MATRIX、完整请求、资源或性能。L0/L1 仍为 PARTIAL，L2-L5 NOT_RUN，M003/M004 未完成。

## 2026-10-12 Controller normalized transaction 与 graph sequencer 主机闭包

`E003/R003/graph_sequencer_host_02` 为 **PASS_SCOPED_HOST**。它在 CPU0–3、nice19、idle I/O、24GiB/1800s 子进程限制下冻结20个 graph sequencer 生产源及递归 include，共55项文件；current/frozen、文件内容和声明SHA全部匹配，禁止的三套外部协议 codec 与三套 HLS exchange 均未进入闭包。完整主机链接和运行用时14.241875s，覆盖成功compute、stale completion后flags归零、取消清理标志、未排空非终态provenance、producer本地拒绝及graph top存在；marker记录两条transaction FIFO/6根信号。manifest SHA256=`7821638bb603945bb122c0f0977721df3136397ef27092e7571ed784f5e183b7`，receipt SHA256=`783ba3f6d1a81d1e14d1be45169da293d219447eddc2dcb50efff38391d1b385`。`_01`是登记分区映射前的同功能PASS，保留原身份。

`controller_transaction_adapter_07` 保留为 **FAIL**：codec、独立Python oracle和sequencer-only codec均通过，但adapter测试仍要求被normalized decoder拒绝的错误外部响应保留raw key，与新增的整份completion清零安全规则冲突，进程在该断言终止（exit -6）。受影响测试改为检查FRAME/BINDING/TERMINAL及binding字段全部归零，不改变协议、工作量或成功路径期望。最终当前映射身份下的 `controller_transaction_adapter_09` 为 **PASS_SCOPED_HOST**：49项current/frozen文件全部匹配，7条命令总用时10.174794s；三类codec/oracle、18根外部协议信号、partial response cancel、cancel local reject、cleanup END及4类拒绝completion清零均通过。manifest SHA256=`17d5adf55c2e7e1f55efc6d47fb73743d0f59aa5a5cb6ef4cee17196ae06054d`，receipt SHA256=`6002a91c477960097a0462591f256eb8a0d979784e68db3bdb2593fec4c3cfc5`。`_08`是登记分区映射前的修复后PASS，保留原身份。

两项PASS只证明当前C++主机闭包、normalized transaction语义和外部codec静态隔离。尚未生成sequencer/adapter RTL，未验证实际depth2并发反压、production AXI/store helper、adapter pending/fence、完整请求、联合资源、时序或性能；L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成。

## 2026-10-12 Controller transaction F6/F7 受影响主机回归

F7 的 completion 入口清零和坏头分类在两个 codec 构建中通过。`controller_transaction_adapter_10` 为 **PASS_SCOPED_HOST**：49/49 current、frozen、pair 一致，7条命令均 exit0；预置可信成功或 `LOCAL_REJECT` completion 后，坏 magic、version、beat数、kind、status、unit、flags及保留字段均清除可信 flags/binding/seq/Context，同时合法未排空错误保持活动绑定。manifest SHA256=`fcf206a5d2a09a19b245a05c19803e7a5a092eb39c44375e1f6e7183accffc7c`，receipt SHA256=`bcf94858dab63762d2e6fde355e70b017e03260b15f4b447bdc8842ff512a5ca`。

F6 的真实 Controller 分支由 `controller_transaction_lifecycle_01` 取得 **PASS_SCOPED_HOST**：59/59 current、frozen、pair 一致，27条编译/链接/执行命令均 exit0。实际 Controller 与 `laya_command_provenance_adapter` 逐拍组合执行两次 BEGIN；第一次在 BEGIN 成功后因 cancel 得到完整绑定的 producer `LOCAL_REJECT`，外部 producer FIFO 为零 beat、issued bytes为0、source readers归零、destination保持 INVALID/未发布；首个 END 为未排空/scope-active，第二个同身份 END 才终态。typed恰退休一次，并在同一 `FullRuntime` 以 request_id 602/generation 32、epoch2 恢复。manifest SHA256=`72348971d0220d72fbc0471b714fd1e392638576518b04c90d27876c24015e03`，receipt SHA256=`e960e25a8029bb7647ca6ba69759a70bc2d8a057f16a22c459d7da7dc52d9e88`。

`graph_sequencer_host_03` 保持当前55/55闭包和 sequencer-only codec 回归 PASS，manifest/receipt SHA256分别为`ac4050ab5590a11fc08dea9b073e214006b2b6a0bb340def825c48f00ecb3e15`/`4f832597c642753ef8c69a9f3e657d1ee28e549e68b852b8cbbb3a53dbd6800b`。`producer_engine_controller_11` 的59/59当前闭包亦PASS，保留正常成功、部分失败和lease释放回归；manifest/receipt SHA256分别为`0eb95d7ee8c5ec3359f3a62865562b10a92760a00762d244fd7e94c4e6674d65`/`b236e6626d2fd577793ef150ab351cbc298835733b976aa7b6f779bd985569a9`。

聚合核查文件为`E003/R003/controller_transaction_f6_f7_verification_20261012.json`，SHA256=`25eba1c92d28d047b6f1c0283472110c77d6b89d062ddc6fd9a05c306f66e203`；222/222 current、222/222 frozen、222/222 pair 匹配，64条命令 exit0。四个 launcher 均记录 CPU0–3、nice19、idle I/O 和 MemAvailable 门通过。

既有 `controller_transaction_adapter_hls_01` 保持 **FAIL/semantic_stall**，receipt SHA256=`04a4ff30002a55d98746afa4551a6f43c0fa752fd5f074206f0563993d4969b8`；本轮未重启 HLS/Vivado。上述结果只关闭 F6/F7 的受影响主机范围，不签修复后 HLS RTL、真实 depth2 背压、production AXI/store helper、末B/adapter fence、完整请求、资源、时序或性能。L0/L1仍为PARTIAL，L2–L5 NOT_RUN，组合full仍NOT_RUN_COST，M003/M004未完成。

## 2026-10-12 Controller F8 与 adapter HLS 编译成本结果

F8 的四项当前主机结果均为 **PASS_SCOPED_HOST**。`controller_transaction_adapter_11`、`graph_sequencer_host_05`、`controller_transaction_lifecycle_04` 与 `producer_engine_controller_12` 合计222/222 current、222/222 frozen、222/222 pair一致，64条编译、链接或执行命令全部exit0；四个launcher均满足CPU0–3、nice19、idle I/O与MemAvailable门。生命周期marker新增 `end_bad_header_abort=1`、`end_wrong_binding_abort=1`、`no_third_end=2`、`tracker_preserved=2`，证明合法非终态 END 后的坏头和错绑定均在第二次返回处终止，保留tracker/scope且不退休typed任务。manifest/receipt依次为：

- adapter：`de9cdf7bed1cd6df68070633855a195810e13d713513d5f839ae6288a6aec815` / `aa4a23c03d6e5817abb7467cc7ff29c0b527e05d974743523a219c55a4d760ed`；
- sequencer：`e9f864ad6f9c555e082bf53ba34c36f041003f14081caab4bbeeac0b532ba495` / `76d15b21d390188bf3207ab9508ec5c90a61f15269a9dd4928e5843bb3a5f597`；
- lifecycle：`ca62a56abdb7ec75cd275fdf81efa343167a1c754933ce59dad1cf36735a6b2b` / `5a5e8ecbedcd9e48214bf87bc97d29d539ea39fc12095d48ec456388a6fb482e`；
- producer回归：`4f322bed32bc4c7ff79d6699dfe4a542107215386d56d0511d5678dc774ef8c5` / `c12539cde3cfc3a2c1c07ab3580513cbacdc2136fc6b96b8f5f6735abc183a5c`。

`controller_transaction_lifecycle_03` 保留为 **FAIL/-11**：25个编译步骤与链接均exit0，执行时因测试把多个大型 `FullRuntime` 放在栈上崩溃；manifest=`983d451e7793457040ce7bf2f7ad021499dc3724b05c2d0c80a0e013aa752514`，receipt=`05d38f322faa92fb81a7703f5b8d4878f1e63a5c05ef01be38c8692870b6c911`。`_04`仅将两个负例runtime改为静态存储并取得上述PASS，未覆盖或改写失败记录。

直接语义校验使 `controller_transaction_adapter_hls_02` 相对 `_01` 的Compile/Link从46,048降至34,864条指令（-24.29%），Unroll step1从257,068降至180,667（-29.72%），step4从117,368降至80,707（-31.24%），表达式平衡从4,753降至3,716（-21.82%），Loop/function optimization从192.44s降至81.96s（-57.41%）。这证明编译成本有实质改善；新attempt仍在后续硬件构建阶段连续120s没有可观察语义进展，guard于585.645036s停止子进程（child `-9`），峰值owned RSS 5,963,856KiB。32/32 current/frozen/pair一致，host build/run均exit0，manifest=`25818dfddab7bdc838f275378ecb60576401fbf34bf560937baa4b9b4dc66858`，receipt=`1ab76fe110a1385c3092b9aabb032cdd76beff78f3bdc53ffc442620d36351f2`。没有RTL candidate或端口证据，该profile不原样重试。

聚合核查为`E003/R003/controller_transaction_f8_adapter_hls_verification_20261012.json`，SHA256=`f816875f23294032a331adf887ef9445f506047f3e6e0cd00532ca64ce9597b6`。F8只在当前冻结C++主机组合范围闭合；adapter HLS仍为FAIL/semantic_stall，真实depth2并发、production AXI/store helper、末B/adapter fence、完整请求、联合资源、时序与性能均未验证。L0/L1保持PARTIAL，L2–L5 NOT_RUN，组合full保持NOT_RUN_COST，M003/M004未完成。



## 2026-10-12 真实 LayerNorm generated master→monitor/hub→source lease

`E003/R003/layernorm_producer_portal_06` 的 static、rows1 pilot、完整 rows16 三段均为 **PASS_SCOPED_RTL**。static 55.061775s/峰值 2077580KiB；pilot 20.786439s/47267cycles/峰值 856556KiB；完整16行 245.157115s/655511cycles/峰值 856796KiB。三段 child0、trigger null，真实launcher/policy均核CPU0–3、nice19、idle I/O和MemAvailable>192GiB。

实际生成 LayerNorm engine 与五个原浮点 IP 连接持久 AXI monitor/hub。BEGIN八拍响应完整消费后才允许producer请求；真实source AR/R=16/1024，destination AW/W/B=16/1024/16，唯一有效WSTRB总量65536B，八拍completion携实际helper提交量65536B及源消费量65536B。测试台逐位比较全部16384项独立Python binary32 LayerNorm gold；受控提前END至末B及完整completion/fence后才返回。诚实rows16诊断owner完成PUBLISH后，全身份source query及原子lease取得/释放通过，最后owner/lease/债务归零。

本次同层级no-wave pilot速率参与启动前成本判定：47267/20.786439=2273.934517 cycles/s；按16行参考工作量756272cycles和1.5系数，投影499s，低于3600s。该参考估计不是已证明的组合周期上界或硬件性能。full实际245.157115s。输入manifest SHA256=`83aa4a3446f0886dd72be6ea3b675b2346d853a96d06139f5c8a9e3a417b48d9`，receipt=`7b7347fc6f8f5e81b06ce8330430c938889318f5671d0de57672b138dd807ded`；核查文件SHA256=`f4baaafdd5ec9d0efd75e64b7b0056d6addce6718a28390a9e31e642d9eadca7`。382/382引用、112/112 current、frozen、pair及model header→canonical包一致。

旧attempt全部保留：_01 ROM DAT未在xsim运行目录落位，pilot120.364733s timeout；_02已无DAT警告，但无AXI读写即先completion触发断言，另静态确认SV包build tag与实际engine头不符（未捕获该完成帧的status）；_03统一身份后完成7行末B，120.337284s timeout；_04单行算术/END/gold后source query检查FAIL；_05完整16行算术/END/gold后同检查FAIL，241.276650s。_05→_06共同冻结闭包仅TB改变：下降沿驱动valid并稳定采样grant，完整工作量/gold/DUT未变。_04没有单独复验rows1 query；此前白名单归因证据不足，现按测试台采样问题记录，不宣称格式拒绝。

该入口的caller帧由TB控制，提前END携冻结成功提交量，并在终态核它与真实completion一致；尚未证明生产caller从completion构造END。source-query lease在本次未接真实QUANT消费者读流；仅producer真实算术和写口物理链已运行，未签QUANT/fullA数值或真实sequencer/adapter的depth2并发。owner仅16行，不等于完整S64/S128 tensor发布。多窗口/owner/role/QKV、软取消/失败恢复、普通/GATE切换、LOAD/MATRIX、最终13BO top、完整CPU/实际CSim、完整硬件请求及联合资源/性能仍待。partition registry仍是integration_under_test，表示生产整体尚待这些出口。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成保持；无新OOC/P&R/上板，G OOC余2338.224019s不变。现LayerNorm入口已用当前pilot成本判定，旧gate_split runner的当前pilot成本修复仍需单独落实，5172s组合profile不重启。


## 2026-10-12 实际LayerNorm→QUANT/fullA与F9出口

## 已执行与身份

`layernorm_quant_source_03`：static 77.547525s/2352352KiB；rows1 pilot 47308cycles/57.410899s；同runtime rows16 producer→持久monitor/hub→实际共享QUANT/fullA为659334cycles/753.504079s，full峰值856844KiB。六个拒绝入口也PASS，前四项约5.96–5.98s，两个真实单行producer completion注入55.037959s/55.523771s。九段guard child0/trigger null、原CPU0–3/nice19/idle I/O/MemAvailable/墙钟/RSS策略全部核过。

核查484/484引用与152/152 current、frozen、pair一致；实际所选生产头与engine生成时头逐字节一致，canonical包内存重生成相等，七份ROM DAT落位SHA一致。

- manifest SHA256：`5766e20da355a23c10c734613a0bf4c5233baa46d480d3a9def32d24b50dd66f`
- receipt SHA256：`ad6e5d6cf65c733ccfbd3dabf1e7e5403f7ee7abfe89a6fbd2c9667e2be86dd0`
- verification SHA256：`c775b3739a01b1692b8b3138932e42349ebcbe7cb3a68e59154b07f7e7ef313d`

## 真实数值与租约

实际LayerNorm source AR/R=16/1024、destination AW/W/B=16/1024/16，有效唯一WSTRB65536B。全部16384项独立F32 LN gold逐位一致；这些输入gold的16384个binary32 word均不同。Q直接读取TB实际接受的producer W存储数据，未用gold预置源；Q AR/R=16/1024。同一个持久hub取得完整身份source lease，覆盖实际读流、读债及五周期未消费completion反压，响应退休才释放。fullA取得128个四行group，核全部16384 INT8字节及512 FP16 scale，之后释放A和owner并核最终债务/lease/owner清理。

独立量化gold来自冻结LN oracle输出，Numpy1.26.4按binary32 amax/127、reciprocal、multiply，INT8 roundf ties-away，scale FP16 RNE计算；不使用旧八组重复fixture或DUT输出生成gold。END现在在真实completion八拍完整取得后，将其实际status/unit/elements/detail/bad/issued逐字段写入LPV1 END。此构帧仍由TB模拟caller，未生成production sequencer/adapter。

## F9受影响修复

只读成功BEGIN快照提供完整NumericIdentity/Context、416B L13M、origin、目标Ref/epoch/region、role、D/rows与写geometry交叉比较。整帧producer请求通过后才逐拍交实际engine；completion完整收齐并核原请求完整共同绑定、语法/终态/提交量后才交caller，未消费完成期间保持job/fence。新增BEGIN1024B＋请求1024B＋completion512B共2560B payload槽，其他metadata及联合资源另计，未综合。

四个负例相同origin下分别改task_id、request_id、generation、目标epoch（地址不变），均在source AR/destination AW/W前隔离，未覆盖/发布且原BEGIN保留。两个负例在实际生成单行producer完成边界分别注入旧request_seq、错origin；真实读写/末B已发生，但无任何caller completion，旧请求/物理scope与fence保留、不发布/退休。测试签拒绝与隔离，未证明坏帧后的完整硬件恢复；不会将保留scope称作已排空。BEGIN响应八拍及反压原回归保持。F9整体范围判断交主控，不自行关闭C009。

## 成本与历史

当前同profile pilot速率824.024724cycles/s参与启动前决定。16行参考756928cycles，加262144cycles的Q预算余量，再乘1.5得1856s，低于原3600s；实际full753.504079s。Q余量是512group×512cycles的保守预算参考，不是当前Q实测速率或证明的周期上界。原5Mcycles/8GiB/120s进展及完整工作量/gold保留。

_01 static PASS，pilot在新整帧校验前的旧job_active采样时点断言FAIL，6.082430s；_02修采样后static PASS，pilot120s保护终止。独立10us诊断确认TB索引16而shell只收15拍（capture_beat15、loaded0、grant1）；_03将TB发送索引改为非阻塞更新，末拍不再被同沿撤valid，取得当前PASS。两个原attempt/guard/日志及独立诊断保留，无重标。

旧gate_split runner已有current-rate计算，本轮补为显式有限/正值/120s测速准入，缺效证据COST_STOP/started:false，使用历史估计与当前同profile/reference-cycle估计的较保守值；同时冻结执行guard/helper/runner和成本receipt。`gate_split_cost_guard_01`十个纯决策用例PASS_SCOPED_RUNNER（参考3079s、慢测速4836s拒启等），未重跑旧full，不补改gate_split_06启动依据。此修复未执行下一真实full。

## 保留缺口与下一步

本owner只有16行，identity B1/S64；不等于完整64行tensor。producer命令、completion→END由TB驱动，不签真实sequencer/adapter的depth2整链。一般部分提交/失败、活动cancel/旧返回恢复、完整tensor多窗口/multi-role/QKV、普通/GATE双向切换、LOAD/MATRIX、完整CPU/实际CSim、最终13BO top与完整硬件请求/联合资源/性能仍待。下一步推进流式/逐拍adapter生成与真实caller连接，再扩多窗口/错误路径和完整模型。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成；5172s组合不重启，无新OOC/P&R/上板/agent或预算，G余2338.224019s不变。用户本会话新增偏好：持续卡住时允许选用5.6-sol；目前未切换实际模型，也未启动新agent。

## 2026-10-12 流式adapter首个真实生成/RTL

# 流式adapter真实生成与首个depth2 RTL出口：2026-10-12

M003/SM003/E003/R003，A002单owner，E002/experiment唯一实现根。沿D-M003-CONTROLLER-INTERNAL-SPLIT-01，不改LTX1/LTC1/外部三对FIFO或原Host ABI、数值、typed任务及预算。

实际改动：删除1024B external_request整帧副本及三套外部整帧encode，用三份不可变byte映射直接从已校验LTX1快照构造一个512bit字；PREPARE语义校验与NORMALIZE_RESPONSE分别有限调度，不再让top II1展开全部codec。请求先reset再解析，保留语法/完整绑定、LOCAL_REJECT、真实drained/scope及单inflight。语义decoder和completion encoder仍有整帧扫描，不能称全部codec已即时逐字校验或达到1字/cycle。三份int16映射源码表示6144B控制数据；删除payload不等于净资源节约。

## host与真实生成

`controller_transaction_adapter_12`四测试入口exit0/PASS_SCOPED_HOST，原codec/adapter/sequencer/oracle和错误/取消路径通过；新增56个patterned映射探针逐帧比对全部1024B既有semantic encoder（896字/57344B），不声称这些故意patterned帧语义准入合法。

`controller_transaction_adapter_hls_03`生成工具真实exit0、guard child0/trigger null，370.877336s、peak5987504KiB，得到实际top及248份Verilog/16份DAT。Compile/Link31014、Unroll step1 67274、step4 58159、HW Transforms50701；Loop/function优化18.34s。对应_02为34864/180667/80707/48973及81.96s；不能称所有编译指标或峰值RSS均下降，也不当作请求性能。

原runner receipt保持**FAIL**：扫描整个top文件误把内部有限helper的`.ap_start/.ap_done/.ap_idle/.ap_ready`实例连接当顶层端口。未改原receipt/manifest/生成RTL、未补跑HLS。修正未来runner只核top module header；独立只读`controller_adapter_hls_03_port_verification_20261012.json`为PASS_SCOPED_PORT_AUDIT：24/24 FIFO信号、其中18/18外部信号，ap_clk/ap_rst/cancel，顶层无ap_ctrl_hs。合法内部helper握手保留。

HLS csynth利用率表估算BRAM18K49/DSP29/FF53762/LUT190633/URAM0；不是OOC或联合资源验收，未做P&R/物理时序/上板。HLS clock估计不能当实际Fmax。

## 实际depth2首个RTL范围与成本停止

`controller_transaction_adapter_rtl_01`static109.622604s/4864160KiB，pilot16.579330s/856656KiB、51308cycles，均PASS。实际HLS RTL与8个真实depth2 FIFO连接，发送完整MATRIX诊断command并逐字核16拍外部帧，受控8拍回复有中途gap和持续cancel，逐字核16拍normalized完成；completion FIFO满时先放后继descriptor前2拍，当前反压期间不消费，原完成排完后收齐剩余descriptor并本地cancel拒绝，最后所有FIFO清空。此pilot执行compute及其后继compute LOCAL_REJECT；**未执行LayerNorm算术、物理hub或真正MATRIX计算，也不代签prov/producer runtime错误路径**。这些其余路径目前只属于host范围。

原计划八case组合在full前按当前3094.696799cycles/s及51308cycles×8×3复杂度余量×1.5投影597s/1847088cycles，超过此入口1Mcycle帽，结构化COST_STOP/started:false，无guard_full目录。保留1M帽和旧结果，不以墙钟尚有余量忽略周期准入，不宣称八case整体PASS。该1M为此协议入口固定保护，小于全项目40M上限；没有增加全项目预算。

## 身份及后续

核查三attempt：387/387 frozen及声明pair一致，386/387 current一致；唯一live差异是已披露HLS runner顶层分类修复。6739引用中6738匹配，一处也是该live脚本；生成DUT、fixture及运行产物不漂移。RTL_01的304pair/677引用全匹配；DAT16份由冻结副本落位并逐SHA确认。原HLS_01/_02语义停滞FAIL保持，HLS_03分类FAIL保持，RTL_01 full COST_STOP保持。

下一步继续按预算做受影响协议子集和真实sequencer/adapter/LN连接，将当前TB的producer及completion→END替换为生产职责域；完整tensor多窗口、部分提交/故障/活动取消与错旧返回安全收束、multi-role/QKV/来源切换、LOAD/MATRIX及完整CPU/实际CSim继续待完成。C008/C009/C010整体不关闭；既有F9和其他错误处理限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成，G OOC余2338.224019s不变。无新增OOC/P&R/上板或agent；用户允许持续卡住时采用5.6-sol，目前仍未实际切换。当前本项目没有重工具运行。

## 交付SHA

- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_12/input_manifest.json` SHA256=`7b43128bfd4e76cb599bb1638cdf43ca717210659a54604130460dce9e4ece31`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_12/receipt.json` SHA256=`730763ba65e4882360b7cd9c629ab264bf5b373c714f4c16aadfa8c5a0339be7`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_hls_03/input_manifest.json` SHA256=`b730243127cd828e099d1f8e2196e43f80b121f602063c99cadc2dd67350f2a6`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_hls_03/receipt.json` SHA256=`661589aded6a147e4f940f4d0532c86295fc37562c3e6bcb98e32da01070472b`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_rtl_01/input_manifest.json` SHA256=`530d94d615bdd53b3b6704206572303188760e33e545dc37be88ab5e32a7afd5`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_rtl_01/receipt.json` SHA256=`0fb9400ef49251987df38e79d318f0be815f66024802e338688223a7fda7c0a1`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_adapter_hls_03_port_verification_20261012.json` SHA256=`042dada160a8f11aa97b29994dd18a71eff8d6e426724755b73d7d16b97e37fd`
- `project/E003_production_chain_closure/experiment_results/runs/R003/controller_streaming_adapter_verification_20261012.json` SHA256=`57de57b2af3ddbeac6a3ea2a2730e304ea992ffdcb18b289c450a3c6f3c05707`

## 2026-10-12 Controller adapter F10消费边界

`controller_transaction_adapter_rtl_02`在重工具启动前因外层launcher没有CPU0–3/nice19/idle I/O而预检拒绝，仅保留launcher记录。修正实际启动策略后的`controller_transaction_adapter_rtl_03`为 **PASS_SCOPED_RTL_INDEPENDENT_PROTOCOL_CASES**：static 112.119966s/峰值4,550,912KiB；compute、begin、producer、wait_end、wrong_end、bad_producer、cancel_producer、end八项独立复位case分别为51,338、52,102、55,242、62,469、62,183、54,499、44,862、62,475cycles，单项15.987420–17.779543s，峰值856,644–856,908KiB。九个guard均child0/trigger null，policy和原资源帽全部通过。

实际HLS_03生成RTL与八个真实depth2 FIFO外新增消费互锁shell。每项测试在后继descriptor已有两拍等待时，分别于旧completion消费14拍和15拍后停读12周期；`tx_reads`保持当前24拍、下一外部协议零拍、旧输出稳定。只有第16拍在consumer端真实握手后才读后继descriptor，随后原cancel cleanup/本地拒绝完成且八FIFO全部清空。F10在本shell及八个独立协议事务范围具备动态证据。

独立核查文件`controller_transaction_adapter_f10_verification_20261012.json`确认305/305 current/frozen/pair、43项引用和16份DAT落位全部匹配；verification SHA256=`05a22919e8f7e46fc695fcee36324f83cbd313df1ba609a8bc69ad00eeb2ab8d`。manifest SHA256=`1e0a3baa17545ddd86bcb999d6175a423540c57cea8a64a862eafafd62406d32`，receipt SHA256=`7a0281acdf386f8ec8ff499f64308c4a196cb53492c0a3bd8ef73b62712bc096`。

八项是独立复位的协议子集，不代签同runtime graph。真实sequencer、BEGIN→producer→completion→END、typed退休、LayerNorm master/monitor/hub/source lease、完整tensor/请求、联合资源、OOC/P&R/上板仍待；C009继续部分实施，C008/C010整体不关闭，L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。

F10运行后分区登记更新为`generated_top_verified_rtl_bounded_protocol_subsets`，registry SHA256=`69bbb69d8718214dc1132b95575a1d05e7faf9bec9a8e4be3ec483ac1b505fd6`；该metadata不在RTL_03冻结闭包内，登记后305/305 pair仍一致。目录核查SHA256=`968ee114332370d5dc499235ca6eb6100499f11d54a3af6ce08dfcd76b2bc34e`，不扩大上述运行范围。

## 2026-10-12 Graph lifecycle split 主机出口

`graph_lifecycle_split_host_02` 为 **PASS_SCOPED_HOST**。独立 Python oracle 生成完整512B LAX1 请求并与 C++ encoder 逐字比较；LAC1 roundtrip、坏 magic 后旧 completion 复位、program 错 ordinal 保留 pending、旧 source slot version 拒绝及16类未实现 action 的副作用前拒绝均通过。实际 host 组合在同一 `FullRuntime` 对 B1/S64 LayerNorm action 执行四个 rows16 窗口，得到4个producer request、10个provenance request、完整owner发布、4个source窗口关闭和4次唯一typed退休。

运行三条命令均exit0：Python oracle 0.066818s、C++ build 12.494814s、测试执行0.067266s。launcher记录CPU0–3、nice19、idle I/O、MemAvailable 420038212KiB，高于192GiB门。55/55 current、55/55 frozen、55/55声明pair一致；program/lifecycle闭包分别为3/14源且禁入项为空。独立核查见 [graph_lifecycle_split_host_verification_20261012.json](../../../../../../../E003_production_chain_closure/experiment_results/runs/R003/graph_lifecycle_split_host_verification_20261012.json)。

- receipt SHA256：`d3a4ca31e56691975c3e60d50a9aef8e9fdbb794c7ab2b70bcd0a0a7afeeb73e`
- manifest SHA256：`b580be22f4d29ca6aac48a3f3d0a9102a8be49a6154c593e4a3498d559f8830b`
- run.log SHA256：`7ee5f1e797b9a099bf3528e1db87cedbd537e25117c01dac8dafc81261b8349a`
- independent oracle SHA256：`6ccf07108e931dc5074b4195d84a1d175d32eb3477a813d9e6cd214a8cd914c0`
- verification SHA256：`f6ccf3e3270e82f20eb893ea4b010f00c193e2e62713be9698c0fa3100f589a9`

`source_provenance_06`是独立的软件ledger当前回归：PASS、2.184783s/83212KiB，14/14 current/frozen/pair一致，覆盖B1/B2 attention、ordinary、QKV atomic pair、RoPE inherited V及scorer LN→FC1→GELU epoch链。receipt=`64061933359de321e6ce7f7e94b2469e19bb5ba93490b3f3bb128f44ffaf63f2`，manifest=`a3ed779be3fd3df916e2dd3f3894a3cce0a265ffa202e256e171892c6b77f11b`，run.log=`5cd396763b1b94dc75f5ca230215b1e6232dcb7e4764e5cbe638f12c94232cd8`。该旧runner只记录24GiB子进程RLIMIT_AS与每命令120s timeout，没有保存外层CPU/nice/I/O/MemAvailable，故不据此扩大launcher结论。

本轮未生成 `laya_graph_program_sequencer` 或 `laya_task_lifecycle_executor` RTL，也未运行action层真实depth2背压、consumer末1/2拍门控、cancel、partial producer failure、非终态END后的真实硬件恢复、同runtime generated LayerNorm master→monitor/hub、完整17类graph或最终13BO请求。资源、时序、OOC、P&R与上板均未执行。C009仍为部分实施，C008/C010整体待验证；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。


## 2026-10-12 Graph lifecycle F11–F13 主机回归

`graph_lifecycle_split_host_03`为 **PASS_SCOPED_HOST**。原B1/S64四窗口LayerNorm成功路径继续通过；新增错误回归覆盖PUBLISH终态失败→INVALIDATE非OK/未排空→同action匹配终态INVALIDATE、BEGIN非终态错误、source release失败、LAC1非法Status与LOCAL_REJECT+OK、语义拒绝清旧输出、NORM错batch/row0/退休数，以及失败request后普通派发锁定和新request高水位恢复。其余16种action kind均动态执行副作用前拒绝。

五条命令exit0，launcher为CPU0–3/nice19/idle I/O/MemAvailable 420411544KiB。成功build/run 12.753270s/0.067232s，错误回归build/run 12.453885s/0.066087s；56/56 current/frozen/pair和128/128 SHA引用匹配。verification见 [graph_lifecycle_split_f11_f13_verification_20261012.json](../../../../../../../E003_production_chain_closure/experiment_results/runs/R003/graph_lifecycle_split_f11_f13_verification_20261012.json)。

- manifest SHA256：`914777b50062afa1711a8cabc9040017923a4f0f3bc6d6d69fca5129f32519e9`
- receipt SHA256：`dcb798795109e8fdbd97479f5458cb3bbe95e8c312358955ee7dac0fa5d9a72b`
- success run.log SHA256：`8a385909950b98d20ce3b3b5780effa7d3ef5392d318da2e9b7c3d5322a7ea76`
- error run.log SHA256：`c3cf55552cf4cf4f10f0c7420ed1093e844d2d058652a01b70e0e6f6f47337d0`
- verification SHA256：`ab446e35f693279694713c17c3785fe5ea2c5fed51fefd3fabc3829a52753c0c`

BEGIN非终态和source release失败两例只证明状态保留及不发安全completion，不代签之后的完整硬件恢复。本轮没有program/executor HLS/RTL、action FIFO末拍消费门控、same-runtime LayerNorm/hub链、完整graph、资源/时序或板端结论。runner没有owned-RSS采样或120s语义进展guard。

## 2026-10-12 Graph program top accepted-request 主机出口

`graph_program_top_host_01`为 **PASS_SCOPED_HOST**。独立Python oracle生成LGP1命令和LGR1结果共512B并与C++ encoder逐字比较；语义坏LGR1拒绝后旧输出复位。实际program HLS top依次执行三份合法accepted command和一份坏command：第一份B1/S64 `NORM_LAYER1_ATTN`产生ordinal1的8拍LAX1并在成功4拍LAC1后提交slot；第二份产生ordinal2并把安全`E_BUFFER`完成转为无slot更新的request失败；坏command返回可解码的零ordinal、无binding `LOCAL_REJECT`；其结果未消费时后继四拍command保持未读，消费信号到达后恢复并产生ordinal3。

三条冻结命令均exit0：oracle 0.066419s、build 3.723993s、run 0.005823s。launcher为CPU0–3、nice19、idle I/O、MemAvailable 430609528KiB；24GiB/1800s host限制保持。独立核查32/32 current、frozen、pair及75/75 manifest/receipt引用一致，见 [graph_program_top_host_verification_20261012.json](../../../../../../../E003_production_chain_closure/experiment_results/runs/R003/graph_program_top_host_verification_20261012.json)。

- manifest SHA256：`03cf285f7b024350a8224dac6ed51413f78ba31e2424881ea402fa875e7c281b`
- receipt SHA256：`a3f6ce5f2dc5b42b7eaf617ea691e3e77d42b416a5b6ea3c8802c718c3e324c0`
- run.log SHA256：`5c446e99d59ed77dc82b413136ac99ccfc94006a46933c554d90403db2e3ba5d`
- oracle SHA256：`9da3038eb38399d5a220745b8618b95f13837d03c7701bcfedd6a54b41f48aa0`
- verification SHA256：`4c8148463f8387f469b9ee2b76276add9ab43a0796794ed8f8c553dab5932b97`

TB直接注入“已接受”LGP1并驱动抽象`result_consumed`；没有真实executor/shell准入权威、depth2 RTL FIFO末拍握手、lifecycle/adapter/LayerNorm/hub、活动cancel/cleanup、完整program PC图或HLS生成。该PASS不能代签完整graph、13BO请求、资源、时序、OOC/P&R或上板；C009仍为部分实施，C008/C010整体待验证，L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。

## 2026-10-12 Program消费通知host补充

# Graph program结果消费通知保持：主机补充里程碑（2026-10-12）

范围：M003/SM003/E003/R003，D-M003-GRAPH-LIFECYCLE-SPLIT-01；回复graph-program-top-host-review-20261012。

`graph_program_top_host_02`为PASS_SCOPED_HOST。program在LGR1末拍成功写入时保留同次调用的result_consumed通知，WAIT状态消费并清除；更早的旧通知不开放后继command。此修复只核抽象主机通知，真实shell仍须从当前LGR1消费端4次实际握手产生持久、请求对应的通知，不能以FIFO空间或末拍入队证明消费。

新增动态断言覆盖末拍写入相邻通知保持、延迟结果消费时后继command保持未读、早到旧通知忽略。request901成功、request902安全E_BUFFER、坏magic本地拒绝及request904恢复均保持；本次904还完成成功LAC1、LGR1消费并核四条stream最终清空。因此是三个完整合法command加一次前置拒绝；非实际Host请求、真实depth2或生产链。

独立byte oracle仍为512B且与_01 SHA相同。32/32 current、32/32 frozen、32/32声明pair、75/75 manifest/receipt SHA引用一致。三条命令exit0；oracle/build/run分别为0.066637/3.924084/0.011004s。CPU0–3/nice19/idle I/O，24GiB RLIMIT_AS/1800s timeout保持；无owned-RSS采样或120s语义进度guard，不扩成HLS/RTL保护证据。


证据：/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_top_consumption_milestone_20261012.md；verification：/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_top_consumption_verification_20261012.json。

# Program真实生成/消费shell与executor共享FSM里程碑（2026-10-12）

范围M003/SM003/E003/R003；D-M003-GRAPH-LIFECYCLE-SPLIT-01。回复graph-program-consumption-host-review-20261012，继续原授权。

## 结论与真实覆盖

- `graph_program_hls_01`为PASS_SCOPED_GENERATION：原guard child0/trigger null，109.026356s、peak3379604KiB。实际syn/verilog目录73份Verilog/11份DAT；top的12根FIFO信号、ap_clk/ap_rst、cancel/result_consumed齐全，top无ap_ctrl_hs。六源编译闭包排除executor/adapter/旧execute_graph_action；Compile/Link9261，Unroll step1 18013/step4 14117。HLS资源估计BRAM18K3/DSP1/FF16819/LUT60478/URAM0；不当作联合资源、物理Fmax或完整请求性能。
- `graph_program_rtl_01`为PASS_SCOPED_RTL_PROGRAM_CONSUMER：同SHA实际HLS top、11份ROM DAT及四个真实depth2 FIFO。shell在同一LGR1消费端实际4次握手后保存通知，跨HLS多周期保持，并在下一accepted command首拍真实读取时清除。末2拍与末1拍停读各12周期、后继2拍已排队时，当前command_reads保持4拍边界、后继action写零增量、输出稳定；末拍消费后下一周期才开放FIFO出端。原contract的消费通知真实接线义务在这个有限program/受控LAC1范围取得证据。
- full同runtime处理901成功、902安全E_BUFFER、903坏magic零ordinal本地拒绝及904成功恢复；三份合法command完整结束、一次前置拒绝，逐字核LGP1/LAX1/LAC1/LGR1，全部四FIFO清空。并非真实Host请求、算术成功或typed退休证明。独立Python固定布局生成受控fixture，使用冻结模型tag，gold未取DUT输出。
- `task_lifecycle_fsm_host_02`为PASS_SCOPED_HOST：executor新增持久action/window cursor、共享有限Phase、逐拍24/16事务收发与核验；生产FSM12源闭包不含旧同步execute/dispatch/stream exchange树、adapter或外部codec。主机组合另外链接真实C++ adapter与受控远端服务，六例覆盖四窗口成功/4次退休、PUBLISH首错→同action同清理event非终态/终态INVALIDATE、本地取消后producer零外发/issued0/source readers0→同END键非终态/终态、非终态END后坏头/错event隔离无第三次END/不退休、非终态BEGIN保留真实软件reader和tracker。action完成后在抽象consumer确认前拒绝再次start。坏返回隔离不等于硬件安全恢复。

当前FSM host请求/模型有效和source READY由TB初始化；尚未实现accepted-request bootstrap、独立executor HLS top/action consumer RTL门控或真实program→executor→adapter→LN/hub生产链。B1/S64只是本次动态shape；完整PC/其他family、13BO、完整CPU/实际CSim和物理恢复仍待。

## 运行与成本

program RTL static48.662357s，pilot6682cycles/5.766016s，full22415cycles/6.577758s；三段guard child0/trigger null，CPU0–3/nice19/idle I/O、MemAvailable门、RSS/墙钟/120s进度帽均核。full在启动前以本次pilot1158.859100cycles/s，6682×4×1.5=40092cycles、34.596095s投影，低于本入口1Mcycle/3600s；这是有限fixture估计，不是完整图性能上界。static峰值2514820KiB，pilot/full峰值856736/856792KiB。11份DAT冻结/落位SHA逐项相等。

FSM host build/run10.041669/0.117152s，均exit0，六case原始marker在日志内。其runner保持1800s/24GiB RLIMIT_AS，只签host限制，不扩成owned-RSS/120s进度guard。`task_lifecycle_fsm_host_01`原FAIL保留：测试detail与Vitis detail namespace歧义导致编译exit1，未执行DUT；_02仅限定test调用为laya::detail后新冻结重跑，DUT及断言语义未变。

## 身份

独立核查：generation35组/1874项引用、FSM host53组/115项、RTL123组/280项；登记前211/211 current/frozen/pair、2269/2269 manifest/receipt引用一致。随后唯一registry补记真实program生成/RTL及FSM source闭包，导致generation两项、FSM三项live JSON变化，RTL闭包无差异；五项均为config登记，不是DUT/TB/gold/工具产物漂移。具体前后SHA在聚合verification中明确保留，旧receipt不覆盖、不重标。

交付：

graph_program_hls_01:
- input_manifest.json: `dfa38ba45d1ce7ac0257c6c9e7004d49cead81c4d95e9863c943ba1503f5e7af`
- receipt.json: `58aa61732800140ef921f82f3e36c72e5a27bc929e21f2f47ccb36078f0efedc`
- verification: `6b13e8f4407f7a6c0cd192a9d9ddb23a114591c2217773038b9c554fab5f8be2`

graph_program_rtl_01:
- input_manifest.json: `87131cdcc82562463e70287130767d6e5dd8bdbe61699195c78f8d202f17a5e4`
- receipt.json: `30aee37ebefb20fbadc91b400c56b7daf286214965242e29f9f947924b93229e`
- verification: `d5bae6dc2969d50aa3f4c5a3da2a0eb120ccc2d92072cd32e873b2f1ff62293b`

task_lifecycle_fsm_host_02:
- input_manifest.json: `b7b7486f29884d282f5e86f41b3ae190e4e676aaff45278b56265c1015ff91e5`
- receipt.json: `a6883894f5c7a4bee8499735d2f91d4d50dcbdc5e8228bde05a998cbbc8d5dbb`
- verification: `4246fbfe394cdda49fb473549b5383c3ce3038524fcc55b3dd06a13bcbb01c5c`

聚合verification：`dac277f992a762ee91dab222d02a271b38aa93f4349e524aa66fe7792cc96457`。文件：project/E003_production_chain_closure/experiment_results/runs/R003/program_generation_lifecycle_fsm_verification_20261012.json。

三摘要/A002同步后继续accepted-request唯一准入、executor top和action层真实消费边界，再连接实际LN master/monitor/唯一hub，以实际completion构造END/唯一typed退休并接Q/fullA独立gold。C009部分实施，C008/C010整体待验证；F6–F13旧限定关闭保持，L0/L1 PARTIAL，L2–L5 NOT_RUN，组合full NOT_RUN_COST，M003/M004未完成。原帽、单重工具、G余2338.224019s保持；5172s组合不重启，无新增OOC/P&R/上板、agent或预算。当前无本项目重工具。


## Executor action port/准入/snapshot阶段（2026-10-12）

- task_lifecycle_port_host_02：PASS_SCOPED_HOST。build/run13.398746/0.067071s；实际C++ program→port/FSM→adapter及受控远端四窗口/四退休，后继两拍排队与末2/1拍抽象消费保持、旧ordinal/源version/LINEAR本地拒绝、坏头/semantic kind隔离。请求/模型/source在此项仍由TB初始化，software stream不签RTL depth2。
- executor_bootstrap_host_02：PASS_SCOPED_HOST。fixture/build/run0.066519/14.698542/0.116214s。真实832B LYRQ和选定模型AUX的128B LYMP，10个准入负例；独立1536B LBS1/LBR1 oracle、23个拒绝输出复位、合法错误保留。四个正常预约/退休函数处理的受控先前TaskDone保持至checkpoint后，当前NORM恰退休task5–8，完整action退休量4；旧实际active action期间bootstrap拒绝且它可继续结束。snapshot/guard/physical输入及远端服务仍为host fixture，未执行真实前序算术/物理保护。
- bootstrap_snapshot_rtl_02：PASS_SCOPED_RTL_SNAPSHOT_ONLY。8663cycles，整体guard27.890323s、peak1499992KiB，child0/trigger null；真实hub和store monitor在正常CLAIM→四个BEGIN/AXI512/END→PUBLISH下建立完整HIDDEN B1/S64 source，64 AW/4096 W/64 B、262144B；查询无生产event/typed/owner修改，响应反压稳定、正确/错绑定、未发布/缺窗口、scope/末B与未消费END返回、controlled shell读债/adapter/base、旧query和后续失效均有断言。数据由受控master按地址pattern写，不是encoder算术或数值gold。scope/末B/响应状态来自实际monitor/hub；read-debt/adapter/base来自受控shell输入。本项不签snapshot到实际source读取的保护或恢复。
- generated_store_monitor_10：PASS_SCOPED_RTL_COMPATIBILITY。受影响默认禁用snapshot的原monitor回归；3097cycles、26.035304s、peak1533580KiB，child0/trigger null，原取消/部分失败/末B/反压/恢复断言保持。

两项host只有每命令1800s/24GiB RLIMIT_AS；两项RTL沿8GiB/120s/120s进度保护、CPU0–3/nice19/idle I/O/MemAvailable>192GiB。本轮未运行新HLS/OOC/P&R/上板，没有联合资源/物理Fmax或完整请求性能结果。登记前165/165 current/frozen/声明pair及423/423递归SHA引用核对一致（59+68+20+18；原草稿加总185已更正，冻结核查不回写）；catalog后续更新差异单独记录，不回写冻结receipt。

历史保留：port_host_01编译FAIL（TB把非const empty()用于const stream），_02仅更正TB参数限定；snapshot_rtl_01静态elaboration FAIL（TB引用monitor不存在的protocol_error端口），_02仅改为读取实际monitor_status，DUT和断言未改。bootstrap_host_01原PASS保留，_02将旧action保护断言放入实际组合运行中的active action，去掉TB人为置active；不是回写旧终态。

executor top、真实8/4action与24/16事务消费连接、源保护、生成LN/hub生产caller、完整PC/family/13BO和当前完整CPU/CSim仍待。既有program/F6–F13/LN→Q限定结论不扩大；L0/L1 PARTIAL、L2–L5 NOT_RUN、C009部分实施、C008/C010待验证、M003/M004未完成；5172s组合不重启，G余2338.224019s及原预算不变。


## F14受影响限定RTL（2026-10-12）

# Bootstrap snapshot F14仲裁修复与受影响兼容回归

范围M003/SM003/E003/R003；回复executor-bootstrap-snapshot-review-20261012；现合同、原预算及单重工具。

F14实现已修：启用snapshot时，LPV request_ready仅由已接受且未消费snapshot response排他门控，不再被未接受snapshot valid压低。snapshot仍在没有当前LPV request、scope/pending END/旧response/lease/cancel且安全条件满足时接受。因此双方持续valid时LPV/旧action清理优先；QUANT source query相对snapshot保持原明确优先级。只读snapshot未增加lease/发布/typed副作用。

bootstrap_snapshot_rtl_03为PASS_SCOPED_RTL_SNAPSHOT_ARBITRATION。保留原完整B1/S64受控prelude与串行查询/错绑定/未发布/反压断言；新动态负例不通过撤valid制造进展：
- idle CLAIM与snapshot同时持续valid，CLAIM先唯一接受；返回保持12周期期间snapshot仍pending，消费LPV返回后查询唯一接受并诚实E_BUFFER（未发布）。
- 第四窗口BEGIN后snapshot持续valid；实际最后B未消费时END也持续等待12周期，两者无错误准入。真实B退休后END完成、scope关闭，END返回另持12周期；消费后snapshot返回完整绑定的未发布拒绝。snapshot未撤请求，4 typed终态及事件高水位保持。
- 已接受snapshot返回持12周期时，INVALIDATE持续valid且零接受；消费snapshot后INVALIDATE唯一接受。其完整绑定成功response在cancel脉冲及后续12周期保持，第二snapshot持续等待；消费cleanup返回后cancel收束、查询诚实拒绝，无旧response清除或事件重复。
- snapshot与invalid QUANT query同时持续valid时，snapshot唯一接受并持返回12周期；消费后query恢复ready并按原语义拒绝，未产生lease。该项只签无lease非法query竞争；合法QUANT source lease另以默认禁用兼容回归保留。

source保护、executor top、action真实depth2及program/LN/hub整链尚待，F14实现结果提交主控审核，不代签全部仲裁或公平性。连续LPV流可能使低优先snapshot等待；本次证明有限旧任务/cleanup能有界进展。

bootstrap_snapshot_rtl_03：原guard child0/trigger None，29.377487s、peak1529052KiB，policy 18条符合CPU0–3/nice19/idle I/O。原始marker：`FULL_CURRENT_BOOTSTRAP_SNAPSHOT_RTL_PASS cycles=8725 prelude_tasks=4 prelude_events=10 source_aw=64 source_w=4096 source_b=64 source_bytes=262144 readonly=1 full_owner=1 query_backpressure=1 scope_return_debt_base_negatives=1 stale=1 snapshot_only_no_source_read_guard=1 persistent_valid_idle=1 persistent_valid_END=1 persistent_valid_INVALIDATE_cancel=1 source_query_arbitration=1 single_accept=1`。

generated_source_lease_05：原guard child0/trigger None，26.707304s、peak1487288KiB，policy 22条符合CPU0–3/nice19/idle I/O。原始marker：`FULL_CURRENT_GENERATED_SOURCE_LEASE_PASS sparse_rows1_rejected=4 sparse_publish_rejected=4 windows=4 distinct_P=4 partial_publish_rejected=1 identity_model_ref_range_rejected=1 lease_atomic=1 read_debt_hold=1 owner_release_blocked=1 duplicate_generation_rejected=1 greater_generation_reread=1 query_grants=5 query_rejects=7 cycles=1628`。

generated_store_monitor_11：原guard child0/trigger None，26.291409s、peak1571572KiB，policy 18条符合CPU0–3/nice19/idle I/O。原始marker：`FULL_CURRENT_GENERATED_STORE_MONITOR_PASS events=19 terminal=4 aw=18 w=1027 b=19 rejected=2 bytes=65536 bursts64=16 zero_w=1 held_b=12 adapter_fence=8 w_before_aw=1 partial_failure_drained=1 real_b_merged=1 active_cancel_converged=1 begin_rsp_backpressure=1 end_before_first_aw=1 cancel_posted_store=1 cancel_end_ingress=1 unsupported_begin_rejected=1 recovery=1 cycles=3097`。

默认禁用的generated_source_lease_05保留正常四窗口发布、完整绑定、原子lease、真实受控drained释放、owner release排斥及重复/更大generation；generated_store_monitor_11保留末B/adapter fence、部分失败/活动cancel/反压及同session恢复。scope沿各原fixture，不签新生产身份或完整图。三项全部在原8GiB/120s pilot/120s进度保护内完成，无full投影，没有HLS/OOC/P&R/上板，当前无重工具。

身份核查：snapshot20组/79引用、lease13组/72引用、monitor18组/63引用，合计51/51 current/frozen/声明pair及214/214 SHA引用；三receipt、原始marker、guard/policy符合，未改历史attempt。_02→_03共同20项仅hub/TB/runner三份变化，codec/oracle/model/布局未变。本轮source_lease_04路径因既有目录由runner创建保护直接拒绝（未冻结、未启动重工具、无改历史目录），随后使用未占用_05；不把这一入口错误称为DUT失败。

交付（E003/R003）：

bootstrap_snapshot_rtl_03:
- input_manifest.json: `cb57f763fa948a1f98a3986e803195a71a2f6f03cc0fc1d2a688e2562d85bc39`
- receipt.json: `1dc73fe5d10b491e7b0f7ebc72d462684adc6c98a2c74e05ffdb8b52d97e50d5`
- verification: `955a3bd19286c342dbeb7097190e7926dbdf2d454b8194cd8f25946d05995b51`

generated_source_lease_05:
- input_manifest.json: `fc5775316a066891f38b323a456a3c8495d44c4a6a12fc09ac92677bd9aa8efd`
- receipt.json: `882ebcd3b68326a24ceff1b010e5dc2dbb777581ac67663e0dac7a0401934ea6`
- verification: `c07b9c272dc55d7a277222572fad2067d8d9a9a60600f59090383991cbbe4bce`

generated_store_monitor_11:
- input_manifest.json: `44a9969c27d4020fa2b8df3c2d7093ef0cc3aabfc94b4f4c4a396ed73129148b`
- receipt.json: `3d739adef062b243307fed8301f971cbb9c8f2914b3fb4d0f305a09a2e35dcb8`
- verification: `bea3305f04ed0380dbe64ce4925847ed7aba7cc594125353dc6c7a4f63863273`

聚合bootstrap_snapshot_f14_verification_20261012.json：`23bbb8c5e8e189c933d995b84a158c6ed71264b0bf0494e4f9d823552e681539`。

三摘要/A002同步后按原授权继续唯一source保护及独立executor top。C009部分实施，F14待主控对本修复范围审核；C008/C010整体待验；既有限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成；G余2338.224019s，原帽/单重工具保持，不重启5172s组合，无新agent/预算。


## F14主控审核及后续排他门准备（2026-10-12）

主控R-SM003-BOOTSTRAP-SNAPSHOT-F14-20261012在有限持续valid的LPV/END/INVALIDATE取消范围关闭F14。三项合计51组（20+13+18）/214引用；相对snapshot_02共同闭包实际变化五项：hub/TB/runner及此前登记的两catalog。lease释放drained由TB受控，不是实际消费者读债。原handoff/attempt不回写。

开始source guard原型：shell缓存完整LBS1键、唯一hub实时比较原owner数组，排斥冲突source修改/重叠alias/新identity。cancel保持被保护source，直至本action安全完成实际消费后才收束。读债由实际AR/R握手计，producer/action完成consumer来自各自depth2 FIFO；宽action/producer准入及完成内容当前仍受控fixture，尚未接生成executor/producer和唯一完整写仲裁，不签完整source保护或生产整链。


## Source guard有限原型阶段结果（2026-10-12）

# Source guard有限RTL原型与受影响兼容出口

范围M003/SM003/E003/R003；沿D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01，回复bootstrap-snapshot-f14-review-20261012。

## 当前结论与明确未闭合边界

bootstrap_source_guard_rtl_04为PASS_SCOPED_RTL_SOURCE_GUARD_PROTOTYPE；两项公共hub回归为各自原fixture限定PASS。F14既有主控限定关闭保持。本出口是source排他/读债/真实consumer原型，不申报完整生产source保护关闭，也没有executor HLS top、生成LN/完整caller/全部旁路/13BO准入或错误恢复的验收。

新laya_bootstrap_source_guard_v1仅缓存完整LBS1事务键，唯一hub仍使用原owner/identity/L13M/descriptor/window数组实时比较。hub增加默认禁用guard参数/键，排斥相同source的INVALIDATE、epoch/recycle和同role重叠alias，阻止新identity切换；合法非重叠NORM目标CLAIM及其INVALIDATE cleanup能正常通过。cancel时保留被保护source的published/valid/完整绑定，直到本action真实安全完成末拍消费后才允许hub原取消清理。snapshot仍为只读，没有暗取通用lease，也没有第二发布表或typed分配器。

shell在snapshot接受时保持键；成功响应全绑定并消费后建立proof。合法非quiescent负响应不建立保护/READY，也不锁死旧cleanup。action与producer启动前再次比较来源完整NumericIdentity、L13M、Ref/epoch、role、source geometry及live base/cancel；来源事实由同hub实时重核。当前有限入口固定NORM_LAYER1_ATTN；action宽帧及producer宽帧由TB提供，尚未从实际executor/F9完整槽连接。

source AR gate须在真实连接中同时用于memory侧VALID及producer侧READY，不能只屏蔽一边。原型的受控读peer按相同allowed/ready握手核1 AR、64 R和64拍实际债务；越界地址0 AR。R消耗前持12周期时保护不释放。没有比较source数值或执行LN算术，该4096B读取不等于完整rows16任务payload。

两个真实depth2 FIFO分别观察producer完成8次、action完成4次实际consumer握手。各自前6/2拍取走后，尾2拍与尾1拍分别停读12周期；producer_active/旧action/来源保护保持，输出头稳定。producer FIFO内容是0..7逐拍传输probe，不是合法LPC1，更没有上游F9校验运行证据；生产必须绑定F9已核LPC1的同一个consumer，坏完成零拍隔离仍依F9，不以8个任意pop当可信完成。action LAC1由独立字节fixture提供，宽action/producer keys和安全错误报告是受控对象，没有本action实际typed退休或物理BEGIN→END证明。

LAC1实际consumer收齐后核完整action键、Status/flags/保留区、LOCAL_REJECT+OK禁项；安全成功另核目标slot/geometry及完整任务退休数。动态错ordinal、合法非终态、坏保留位和LOCAL_REJECT+OK均保持旧保护/action；匹配SAFE_TERMINAL/REMOTE_DRAINED的受控错误报告最后一拍实际消费、读债归零及外部physical_safe条件同时成立后，保护才释放。该条件还需在生产接到真实monitor/hub/adapter全部待发/返回/写债/fence，不是TB布尔永久授权。

同runtime再次snapshot/action后，在producer启动前cancel：旧source保持发布和完整匹配，producer未获准且AR无增量；匹配安全错误LAC1消费后guard释放，hub原cancel完成，source失效，再query诚实拒绝。只签prestart取消，不签已提交部分store或坏完成后的硬件恢复。

source修改负例持续保持12周期时ready为0，随后由TB撤回以测试下一独立负例；这是准入排斥证据，不是任意冲突请求/cleanup竞争的活性证明。完整写仲裁、跨role/不同base的物理alias及全部旁路尚未封口，当前生产LN shell还未实例化本guard。SOURCE_READY_PROOF不得据本结果成为生产永久许可；真实source保护仍是下一实施项。

## 运行与历史

bootstrap_source_guard_rtl_04：29.612215s、peak1545404KiB，child0/trigger None；policy 18条符合原约束。marker：`FULL_CURRENT_BOOTSTRAP_SOURCE_GUARD_RTL_PASS cycles=9061 source_AR=1 source_R=64 read_debt=0 source_mutation_alias_epoch_blocked=1 live_base_recheck=1 producer_identity_epoch_rejected=1 action_key_nonterminal_retained=1 depth2_tail2_tail1=1 safe_error_consumed_release=1 prestart_cancel_retained=1 readonly_snapshot=1 controlled_keys_completion=1 no_generated_producer_executor=1`。

bootstrap_snapshot_rtl_04：29.240072s、peak1500784KiB，child0/trigger None；policy 21条符合原约束。marker：`FULL_CURRENT_BOOTSTRAP_SNAPSHOT_RTL_PASS cycles=8725 prelude_tasks=4 prelude_events=10 source_aw=64 source_w=4096 source_b=64 source_bytes=262144 readonly=1 full_owner=1 query_backpressure=1 scope_return_debt_base_negatives=1 stale=1 snapshot_only_no_source_read_guard=1 persistent_valid_idle=1 persistent_valid_END=1 persistent_valid_INVALIDATE_cancel=1 source_query_arbitration=1 single_accept=1`。

generated_store_monitor_12：25.881916s、peak1562800KiB，child0/trigger None；policy 18条符合原约束。marker：`FULL_CURRENT_GENERATED_STORE_MONITOR_PASS events=19 terminal=4 aw=18 w=1027 b=19 rejected=2 bytes=65536 bursts64=16 zero_w=1 held_b=12 adapter_fence=8 w_before_aw=1 partial_failure_drained=1 real_b_merged=1 active_cancel_converged=1 begin_rsp_backpressure=1 end_before_first_aw=1 cancel_posted_store=1 cancel_end_ingress=1 unsupported_begin_rejected=1 recovery=1 cycles=3097`。

三项串行、原8GiB/120s pilot/120s进度保护、CPU0–3/nice19/idle I/O及MemAvailable>192GiB均符合；全部有限case在pilot内完成，无full外推、HLS/OOC/P&R/上板，当前无重工具。

_guard_01、_02原FAIL保留：TB修改source请求/AR地址后未给组合逻辑settle时间即检查ready/allowed，分别在INVALIDATE和越界AR断言处停止。_01→_02共同23项只guard/TB改变：除TB settle，guard收窄当前NORM准入、补完整LAC1保留区/成功geometry/错误typed语义。_02→_03仅TB补AR settle/诊断，_03原限定PASS保留。_03→_04仅guard/TB改变：增加query_pending状态，将合法nonquiescent snapshot拒绝与协议错误分开，并动态核负响应不毒化旧source/后继成功proof。未删除或放松旧断言。

snapshot_03→_04共同20项仅公共hub变更；monitor_11→_12共同18项也仅hub变更。默认guard禁用时原F14持续valid交错和monitor部分失败/末B/活动cancel/反压/同session恢复保持；旧source lease_05仅按原冻结身份保留，不称为本轮真实生成消费者读债。

## 身份与登记

登记前61/61 current/frozen/声明pair及237/237 SHA引用匹配（guard23/95，snapshot20/79，monitor18/63）。随后full_module_registry和production_hls_partitions仅登记原型及F14当前兼容身份，产生5处live JSON差异：guard2、snapshot2、monitor1；current56/61、frozen/声明pair61/61、引用232/237。DUT/TB/fixture/运行物没有后续漂移，历史attempt不回写。

交付均在E003/R003：

bootstrap_source_guard_rtl_04:
- input_manifest.json: `28438580a99e3d7ac4f3427a608ebb11c4ac3d07c6230bd4b8819e9af323582e`
- receipt.json: `468186926b1f15180ad03d96aa30b064f206bbdf8b138616897caf97eadc8728`
- verification: `5ea8fb1da0b2fb07c8a99c9d8dac0140ec1115c24a3f4ca2257f20f4c4c72805`

bootstrap_snapshot_rtl_04:
- input_manifest.json: `53585cfb065185846d4607b34752816c6f4e8fef051986a058b38a5bbc692a99`
- receipt.json: `85d51f4aed96cd4a76ab752d3bf0d32c97bc74d3eaecd6639dbcc83b3f1a3068`
- verification: `313df3ff4c41e633a7445fe0e51d63046cb8b71d96cb6f3062b636c11bde1a41`

generated_store_monitor_12:
- input_manifest.json: `2288ea7bbc2287065a2840aafa4eb985e44384340169f1e7e467a88c45ef5fb9`
- receipt.json: `f509faa06b02aed3da1e0fde6d17ce99d4ac2bc6b0b7b005ae3d1b5ea2f8f94a`
- verification: `42429da8360c8b47f7b049591b7894228d2e96820dd99b97046325f68b2bf0cc`

bootstrap_source_guard_prototype_verification_20261012.json: `27e1c7078413e8827cb1ce2c3429f5a6d497f68d0a5a958a1542f541379ce35e`。

bootstrap_source_guard_prototype_catalog_delta_20261012.json: `05dc47df4a35a11c88792372b59600e6dcc00369d39e47c2f1887db2479cd511`。

按原授权继续把本guard接到唯一实际producer/完成consumer、source AR两侧、13BO/base生命周期及全部写/修改仲裁入口，再建立独立executor top/8-4 action consumer并把F10接到真实executor LTC1读取端。源保护全部入口证据闭合后串行生成相关executor，不原样重跑旧graph profile。实际LN/hub completion→END/唯一退休及Q/fullA仍待；C009部分实施，C008/C010待验，既有限定关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成；原单重工具、资源帽和G余2338.224019s保持，不重启5172s组合，无新agent/预算。


## 2026-10-12 F16与有限真实guarded LN阶段补充

# 当前有限出口与原始证据

- bootstrap_source_guard_rtl_08：9466cycles/30.397823s/1606656KiB，F15相同guard及修正hub原型。
- layernorm_guarded_source_05：static59.064432s/2166224KiB；pilot57201cycles/25.581878s/856924KiB。真实1AR/64R、1024 F32 gold，F9同consumer和完成→诚实错误END/旧scope隔离。
- bootstrap_source_conflict_adapter_host_01：build5.772075s/236624KiB；run0.165295s/child0。四份实际RTL响应及原F16负变体通过。run早于0.2s首个采样结束，没有owned-RSS/实际child-policy记录，仅launcher/wrapper配置证据，不写成完整观测guard。
- generated_store_monitor_13：26.383362s/1540208KiB；bootstrap_snapshot_rtl_05：28.247387s/1516180KiB。
- layernorm_producer_portal_08：static57.509201s，pilot20.286966s，单行兼容。
- layernorm_quant_source_04：static75.113422s，pilot55.006011s，六拒绝case5.832911–55.396979s；rows16 full=NOT_PLANNED_COMPATIBILITY_PILOT_ONLY，不能称本轮QUANT数值全范围通过。

七项517/517预登记current/frozen/声明pair，1595/1595引用；catalog更新后506/517 current、1584/1595引用，11处全部两catalog登记差异，冻结/声明pair仍517/517。17阶段均child0/trigger null，179条实际policy，选中阶段起止串行；短host run未采样范围已单独披露。真实RTL/static阶段符合原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、内存/墙钟/进度帽；7份生成DAT落位一致。聚合核验与各attempt的manifest/receipt/verification见下列证据。

历史不覆盖：guard_05 FAIL/TB切包未settle，_06 PASS后_07 F15 PASS，_08仅hub非END flags和TB期待修正；LN_01 FAIL为旧F16 codec隔离，_02 FAIL为最终统计把END终态错误误算准入拒绝。_03新增错END fixture没有合法错误报告字段，前置E_ABI；_04在真实completion/fence前提交错误END，TB等待返回而不消费producer触发100Kcycle帽。_05修fixture并在实际LPC1消费/读债/fence后、旧scope仍活动时测试错END；保留所有数值和终态断言。最终18事件/18返回、准入拒绝3（两个source冲突+错END）与hub typed终态5（前序4+本段错误task5），END终态失败不计入准入拒绝。

没有新HLS/OOC/P&R/上板、full或性能结论；M003/M004未完成。

- [guarded_layernorm_f16_verification_20261012.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/guarded_layernorm_f16_verification_20261012.json)
- [guarded_layernorm_f16_catalog_delta_20261012.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/guarded_layernorm_f16_catalog_delta_20261012.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_guard_rtl_08/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_guarded_source_05/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_source_conflict_adapter_host_01/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/generated_store_monitor_13/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/bootstrap_snapshot_rtl_05/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_producer_portal_08/receipt.json)
- [receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_quant_source_04/receipt.json)

## 2026-10-13：LBS2/LBR2诊断检查点主机出口

executor_checkpoint_host_04为PASS_SCOPED_HOST：独立2048B完整oracle、46个wire拒绝/输出复位检查、36个原子导入拒绝（全FullRuntime字节不变）和4个prepare拒绝通过。真实LYRQ/LYMP准入在前，checkpoint不再次begin/admit。三个独立host runtime分别采用task基线4/7/3，实际LPV起点23/97/119；最后一例保留更大的本地LPV119及target Ref历史31。producer/action的已有下界11/17保留，后续严格递增。

每例实际C++ program helper→port/shared FSM→transaction adapter与受控远端执行四窗口：完成task5–8、8–11、4–7各恰一次；每段LAC1 count4。导入贡献0次本地退休，不增owner/op统计；既有2次本地真实退休的case最终tasks_retired6，checkpoint不清零或虚增。source/目标snapshot及fence/远端由TB控制，未执行真实hub读出或LN算术，三个case不是同一硬件session恢复证明。

最终oracle/build/run为0.229052/15.590743/0.428066s，峰值23864/241184/360936KiB。三guard child0/trigger null，并有实际owned-RSS/policy采样；-MM依赖抽取单独为1800s timeout/24GiB RLIMIT_AS，不代签其owned-RSS/120s保护。

受影响兼容以最终FullRuntime身份重跑：executor_bootstrap_host_04三命令exit0（0.067102/14.544780/0.116895s），task_lifecycle_fsm_host_04两命令exit0（10.187591/0.117078s），graph_lifecycle_split_host_05五命令exit0（0.066156/14.295294/0.033908/14.195516/0.067110s），保留旧成功/清理/隔离及F11–F13范围。三个外层owned-tree guard分别16.039872/11.280454/30.104016s，峰值258484/256404/260792KiB；内层短run不另宣称逐命令RSS峰值。

四项合计256/256 pre-catalog current/frozen/pair、574/574引用；两catalog更新后248/256 current、566/574引用，8处全部登记变化。6段guard起止串行、child0/null，109条实际policy符合CPU0–3/nice19/idle I/O，MemAvailable与24GiB/1800s/120s原帽成立。SV常量与独立literal布局作静态配对，SV逻辑未编译或仿真。

历史保留：checkpoint_host_01在负例setup尝试从空owner直接CLAIM epoch2，触发原CLAIM断言而FAIL；未跑到新的action路径。静态核对同时补齐目标无READY历史缓存，_02将setup改为合法epoch1并通过。_03扩到36+4负例/统计溢出，_04扩完整checkpoint来源绑定；中间PASS和早期compat身份不覆盖。当前只签_04及最终三项兼容。无HLS/OOC/P&R/上板、深度2/实际交接或性能结论。

证据：[阶段核验](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_verification_20261013.json)、[登记差异](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_catalog_delta_20261013.json)。真实唯一hub/LPV transport采样、16拍消费/派发权交接、executor top/action/F10 consumer及完整LN→Q生产链仍待，M003/M004未完成。


## 2026-10-13：真实hub/LPV transport检查点有限交接

executor_checkpoint_rtl_06为PASS_SCOPED_RTL_CHECKPOINT_HANDOFF：原hub连续typed前序/历史域与真实transport.last_event_seq汇总；最终实际task7、LPV179、inactive target8，完整1024B oracle匹配。旧END/末B/返回先排空，真实depth2 16拍尾2/尾1各停12周期，末拍消费后仅一次派发权切换；后继同transport CLAIM180/epoch9通过，无新增typed终态。五个复位分隔诊断包括活动目标、重复键、错base/坏帧、跳号、cancel、snapshot epoch和真实监测base变化；并非五个accepted-request恢复。

每份正常前序112 AW/7168 W/112 B、458752B，七次真实hub终态。payload为地址pattern，无encoder/LN数值。RTL结束797850ns/10ns＝79785周期（由原始结束时间推导），pilot61.468907s/1653460KiB。C++ rtl_decode_02将真实捕获交给现codec/helper，任务基线7/LPV179/目标历史8导入贡献0次退休/claim/lease，下一task8/epoch9；build15.499440s/233828KiB，run0.198118s且无owned-RSS/child-policy观测。fence和跨捕获主机准入仍受控，不是同runtime生成executor。

snapshot_06、guard_09、lease_06保持旧fixture范围；默认禁用portal在真实base修正后以monitor_15通过。最终六项181/181 frozen/pair；初轮登记前177/181 current、617/621引用一致，四处是已披露旧catalog登记；最终更新后172/181 current、612/621引用，九处均catalog登记。7段guard串行/child0/null，114实际policy；原帽保持。历史entry FAIL/编译FAIL/PUBLISH期待FAIL及_04/_05 PASS全部保留，详见阶段交付。无executor HLS、真实source/action/F10整链、accepted-request恢复、全部13BO、full数值或资源/时序验收。

证据：[当前核验](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_rtl_current_verification_20261013.json)、[最终登记差异](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_rtl_catalog_final_delta_20261013.json)、[阶段交付](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_checkpoint_rtl_milestone_20261013.md)。M003/M004未完成，下一步仍为持续executor及真实消费连接。


## 2026-10-13：计数更正及持久executor actor主机阶段

前节真实v2 RTL聚合的181/172口径漏计lease_06两份冻结合同；补充更正为183/183 frozen/pair，登记前179/183、617/621引用，最终登记时174/183、612/621。该历史采样已获主控核验；补充记录位于R003/executor_checkpoint_rtl_count_correction_20261013.json/md，原聚合/delta/attempt不回写。本节之后的live实现变化另用新冻结身份记录。

executor_actor_host_02为PASS_SCOPED_HOST_HANDOFF_ACTOR_PREPARATION。七份LHC1帧共7168B逐字匹配独立literal oracle；20个保留位/头拒绝清输出，五个完整键变体不匹配，12个早到/错/旧GRANT不放行。HOLD无需HELD即可从真实已准入runtime建立，S只消耗一次；匹配但cancel的HELD保留H，恢复cancel后仍不能accept。

同一actor/runtime实际解析并准入LYRQ/LYMP request1101及1102，program实际C++ top→port/FSM→实际C++ adapter/受控远端各完成四窗口，总计两段实际8次退休。导入贡献0次退休/claim/lease；producer高水位0→4→8，action ordinal0→1→2，S1→2/H19→20。每段本地tasks_retired0→4；不是以task编号最大值代替退休量。LBR2末2/末1拍各延迟12次host调用，第16次read后仍暂存command直到实际helper和匹配GRANT。

实际helper对未知预约空洞拒绝并形成commit0 ABORT，受控匹配ABORT_CLOSED后保留已耗S/H；已提交后cancel/base/request归属变化的三例形成commit1 ABORT，signal恢复及旧GRANT不能发LGP1或回退导入事实。该部分没有生产错误结果/实际物理释放出口，不签完整恢复。

oracle/build/run为0.281302/20.441539/0.169802s，实际峰值24496/250440/未观测KiB。run在首次owned-RSS/child-policy采样前结束，仅签launcher/wrapper配置，不能填峰值0。executor_checkpoint_host_05保持原2048B oracle、46 wire/36整runtime拒绝/4 prepare拒绝及三受控runtime四窗口兼容；0.234116/15.885593/0.485404s，峰值24640/246424/345168KiB。六guard child0/null，55条实际policy，串行及原24GiB/1800s/120s帽保持；-MM只有timeout/RLIMIT_AS。

_01原PASS保留；_01→02仅TB增加早到/错GRANT、LAC1连续退休编号及撤销HELD不能复用检查，DUT未改变。两个最终attempt的冻结身份与metadata登记差异见executor_actor_verification_20261013.json。真实control shell、depth2 HOLD/IMPORT/GRANT、accepted-request硬件rearm、独立executor HLS、真实action/F10/LN/hub/Q及source全部入口均NOT_RUN。本阶段无RTL工具、HLS/OOC/P&R/上板，无资源或性能结论；M003/M004未完成。


## 2026-10-13：F17有限主机修复回归

executor_actor_host_04 PASS_SCOPED_HOST_F17_REVOCATION：33项首拍/部分帧/校验阶段、12项活动BEGIN/producer交错，输入恢复和旧GRANT不能重新启动。受控LTC1尾2/尾1各持12次调用，旧绑定completion/END/INVALIDATE继续；各已预约旧task恰一次可信终态退休，未启动0次。真实物理债务/硬件同拍不签。原同runtime两请求actual C++ program/port/FSM/adapter四窗口保持，两段实际8次退休。oracle/build/run0.281851/20.242427/0.286247s、RSS24480/254256/21384KiB，三guard通过、28policy串行。83/83 frozen/pair、登记后81/83 current及193/195引用，两catalog差异。_03编译FAIL保留，_03→04仅TB拆分异型auto声明；DUT相同。真实shell/top/HLS/生产链及M003/M004未完成。


## 2026-10-13：有限shell及真实portal诊断交接

shell_rtl_02 16例/1818cycles PASS_SCOPED_RTL_CONTROL_SHELL_PROTOTYPE；actual-helper success/import与空洞拒绝ABORT、持久反压、同拍撤销及旧ownership保留通过。portal_01取得真实task7/LPV179/target8 capture，helper_host_02实际codec/helper离线原子导入，portal_02回放同一1024B后匹配IMPORT/GRANTED才允许CLAIM180/epoch9。真实前序7终态、112AW/7168W/112B、458752B；双depth2尾拍/旧末B/END/返回与HOLD交错成立，未签encoder/LN数值或生成helper同runtime。capture原始SHA05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6。默认checkpoint_rtl_07保持五复位fixture。五闭包211/211 frozen/pair、200/211 current及707/718引用，8catalog+proof-only_01三处后续实现差异。8guard child0/trigger null、110policy串行；短helper/shell oracle无child样本限定保留。详细范围及工具数值见R003 executor_handoff_shell_milestone_20261013.md。生产top、全source保护、合法Q lease、错误结果及hardware rearm仍待，M003/M004未完成。


### 2026-10-13 F18 / cancel-drain有限证据

shell_rtl_04：19例/2008cycles、21.575894s、1433856KiB，F18三项竞争与响应持有通过。
portal_rtl_04：原7任务正常前序及实际16/16 depth2兼容；数据为地址pattern，helper确认离线回放。
cancel_drain_host_02：实际program/actor取消consumer三成功、8坏帧/4错键/14wire负例、两未产生action；LAC1/LGR1独立gold一致，FullRuntime逐字节不变、零业务事务/退休。软件队列无深度限制。
actor_host_06：原两受控软件请求、8退休及45项F17保持。graph_program_top_host_04：原外部program入口兼容，在owned-tree外层guard内执行。
冻结273/273，当前265/273及711/719引用，8差异仅catalog登记；10guard串行/84实际policy。未采到child的三段只签配置，actor_06 run elapsed1.224335s仍无child样本，峰值null。
LAP1为C++及静态SV布局准备；生产wrapper/LAP1真实握手/CLOSE/rearm/depth2/新executor HLS均NOT_RUN。
完整说明和原始证据见E003/R003/executor_cancel_f18_milestone_20261013.md及executor_cancel_f18_verification_02_20261013.json；历史attempt和初版行政核查保留。

## 2026-10-13 managed query wrapper 有限验证

五个实际wrapper路径（正常、2拍后持续cancel、2拍后base变化、成功返回尾拍cancel、完整foreign绑定）通过；正常前序112AW/7168W/112B、7终态，错误query零新业务终态。实际3个1024B捕获经当前C++ decoder/helper验证且3次拒绝不改变FullRuntime；19例F18/default checkpoint/F15-F16 guard/monitor兼容通过。401 frozen pairs一致，current378/401、引用1379/1402，差异由catalog17及后续TB/runner6组成。12个选中guard串行/194条policy；短oracle与host run无child观测，资源完整性false。原host_01 compile FAIL保留，仅TB初始化修正后_02 PASS。完整证据与限制见 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_managed_query_milestone_20261013.md；CLOSE/rearm、活动LPV持久cancel半帧和完整source/13BO链待实现，无新HLS/OOC/P&R/板端结论。

## 2026-10-13 CLOSE/CLOSED有限端点和主机准备

request_close_shell_rtl_03原19+新增17例/3230cycles，通过封存同拍禁止新启动、真实完整键/终态/commit保持、逐项安全输入等待、CLOSED消费唯一释放并等待新准入。physical/work/Host记录仍受控，8192bit整体consumer不是depth2 CLOSED流。request_close_host_05六个独立软件runtime的真实program/action/Host结果分支和四个实际RTL CLOSED离线codec通过；正常段4退休，五个取消/无action分支零业务事务/退休，关闭本身FullRuntime字节不变。actor_07原45 F17/两个软件请求兼容；portal_13/14原真实normal/partial-query-cancel范围兼容，生产request-close参数仍关闭。

295/295 frozen/声明pair、当前287/295、872/880引用；8项差异仅两catalog。10段guard串行/109实际policy；shell短oracle无child样本，资源完整性false。host_01/02编译FAIL、shell_01内核异常及中间PASS均保留。具体身份、每段墙钟/RSS、历史差异和限制见 /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_request_close_milestone_20261013.md。生产wrapper、no-LGP已准入错误结果、ABORT已提交错误收束、LPV旧半帧/返回、无复位下一真实请求和全source/13BO仍待；未新增HLS/OOC/P&R/上板结论。


## 2026-10-13 F19/F20受影响修复有限回归

request_close_shell_rtl_04原19+17及新增22同拍交错PASS，4901cycles/原6000帽，23.969124s/1643180KiB；终态独立接受与完整旧归属、实际IMPORT/ABORT提交见证、CLOSE同拍、已有GRANT稳定/旧query第16次消费成立。physical/work/Host及8192bit CLOSED消费者仍受控。request_close_host_06六新末拍用例及原六真实软件结果分支PASS，managed消费事实完全隔离legacy bool；0.340840/20.360828/0.285840s、24560/276036/20928KiB。co-present完整record是抽象接口刺激，软件无界stream不签depth2时钟。

actor_host_08保留45 F17与两软件请求8退休；portal_rtl_15/16分别正常与持续cancel query兼容。四CLOSED capture1024B/raw SHA与旧交付相同，现C++完整roundtrip。295/295冻结，登记后287/295 current及872/880引用，8差异仅两catalog；10guard串行/118policy，shell短oracle无child观测，resource_observation_complete=false。旧FAIL/PASS/交付不改。详细证据见R003/executor_close_f19_f20_milestone_20261013.md及verification/history/delta。

本修复候选待主控限定验收，真实wrapper关闭/持续高水位rearm、LPV活动半帧/END/末B/返回、完整source/Q/F10及M003/M004仍未完成；无新HLS/OOC/P&R/板端结论。

## Managed LPV有限准备与受影响兼容（2026-10-13）

executor_admission_owner_host_02完整A实际软件准入捕获、22 wire/7 capture拒绝PASS；executor_managed_lpv_rtl_04七复位分隔case/1441cycles PASS，实际depth2 16/8、完整独立返回gold、持续撤销CLAIM-only/半帧/一AW-W-B-END及精确INVALIDATE。whole-A安装与preowned记录受控，case内无reset，未签硬件rearm/合法lease/all13BO。actor_09/monitor_17/portal_17–18/checkpoint_09按各原fixture兼容PASS。355冻结配对一致，登记后12catalog差异；12guard/152policy串行，一个短oracle无child采样。完整证据及原FAIL保留于E003/R003/executor_managed_lpv_milestone_20261013.md与verification。F19/F20仅主控原冻结范围关闭；M003/M004及生产整链未完成，原所有帽/G2338.224019s不变，无HLS/OOC/P&R/上板。
