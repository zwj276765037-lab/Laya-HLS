# 完整图算力与吞吐优化阶段结果

## 2026-10-11 当前阶段终态与独立工程交接

**STAGE_CLOSED / HANDOFF_READY / COMPLETE_ACCELERATOR_UNVERIFIED。** 按用户最新要求，已着手的有界模块工作已结束，所有实现owner及Astra集中结果登记均已写入结束；后继工程将完整复制到 `Workspace/Laya/Laya-HLS`，按research-agent原生结构管理，供新对话继续。原工程保留。本阶段不再启动LN、更宽Q8、13BO生产壳、整图或G新物理闭合路线。

| 范围 | 实际终态 | 关键覆盖与限制 |
| --- | --- | --- |
| 旧稳定build23c62cd4完整CPU/实际Vitis CSim | PASS_SCOPED，复用原身份 | 四持久请求、141独立点/18,094,384 F32及gamma故障后恢复；当前working源已改变，不能代签新整图硬件 |
| Attention v10真实完整head128 | PASS_SCOPED | 正常QK250888＋SM287173＋AV66256＝604317cycles，旧基线6816248，模块计算改善11.279259倍；TB总1608896cycles；仅冻结enc0/head0/B1/S128 |
| Attention v10首错/CE/reset | PASS_SCOPED | 同manifest的tile16_03完成六竞争首错、M/A/D/EXP活动CE/reset、pending Q与ledger；head128本身PROTOCOL=0，不混写覆盖 |
| Attention当前OOC | COST_STOP / NOT_COMPLETE | semantic_stall，244.410645s/RSS11295456KiB，child−9；无final资源/DCP/blackbox/时序，不是数值FAIL，未加帽重跑或发布ready JSON |
| 新G三bank→物理GATE→quant→fullA | PASS_SCOPED | 四distinct真实Wi checkpoint行，20992 Wi/10496 GATE、656真实写/读beat、4整row命令/328groups；59975cycles；不含上游Wi Q8或同runtime Down |
| resident真实完整Down局部链 | PASS_SCOPED | 10496stripes、41984 rowPS、335872有效lane-group PS、4096最终F32逐位，512真实AW/W/B和末B/lease释放/localREADY；48862cycles，421.880748s/RSS1424044KiB |
| resident剩余边界 | NOT_RUN | A为预量化fixture，kind0 bias旁路；非零bias FADD、活动reset/CE、晚错与恢复、16row多view/twoA/twoW、其他shape与生产13BO未验证；输出32768B中有效16384B，非全宽吞吐 |
| G三bank父OOC | COST_STOP / NOT_CLOSED | 功能及exact51算术导出通过，新RAM物理映射/父DCP/完整资源/时序未取得；§8.4.11是未运行交接路线，剩余累计2338.224019s不重置 |
| 全局与上板 | UNVERIFIED | 同runtime完整13BO整图RTL、完整新build CPU/CSim、资源fit/P&R/Fmax、U55C/XRT/HBM/板端性能和数据集准确率未验收 |

150MHz仅条件预算，604317cycles的4.028780ms/head及约11.279倍改善不能当整网耗时、物理Fmax或GPU加速比。G桥与resident Down是独立边界测试，禁止拼成已经通过同runtime整链。历史数值FAIL、覆盖FAIL及TB/工具失败保持原身份。

本次终态证据：[production封存](attempts/t2_production_stage_close_01/receipt.json)（SHA `06e05ea8cf39bcaba14b3a34f4457d3bcefd5cb880ecdca9c1e7b7a6d4471395`）、[Attention封存](attempts/t5_attention_tile_v1_01/handoff/final_summary.json)（SHA `adafe243279657da99e057cbc10d4e962e42ef03b839ac3b875d4430f227c706`）、[Astra集中终态](source/results.md)。root核两主终态共24份直接引用SHA一致、工具/锁退出；G桥RTL04与resident完整Down原始引用也已核一致。当前阶段终态不是完整mission完成。

## 以下保留阶段演进与历史范围

以下RUNNING/PENDING/已准备等词属于各原记载时点；当前状态以上述终态和实际收据为准，不作为新任务启动或新身份验收。


**当前阶段的复制交接范围（2026-10-11最新用户指令）：**等已着手的production与Attention有界验证终态后，封存当前结果，将整个工程复制到`Workspace/Laya/Laya-HLS`并按research-agent原生结构建立独立项目，供新对话继续；原工程保留。本轮不再启动新LN、更宽Q8、整图生产壳或G新物理闭合路线。完整加速器仍未完成，普通修复授权和服务器保护保持有效。

**新三bank GEGLU桥RTL04范围通过：**[实际收据](attempts/t2_geglu_gate_quant_bridge_rtl_04/receipt.json) SHA256 `f4b7e2729f3f74bf69629f5f8c77fb4a0d0782bee5587cb37bbbfe8d89e751cb`，root核6份引用SHA及原仿真marker匹配。四个不同的原enc0真实Wi行经过新G同步bank、不变算术、真实GATE写/末B发布和真实读、整row动态量化、物理dualA，20992 Wi/10496 GATE、656写beat/656读beat、4row命令/328group与328同步A读独立gold通过。59975cycles（量化窗口2714），guard0/null、94.855s/RSS1328936KiB。只含初始reset；上游Wi Q8、下游驻留Down、桥活动reset/晚source/数值/AXI错误及13BO不在本收据覆盖，不能将RTL03重复fixture范围误称本次不同激活验证。

**连续长任务：RUNNING / NO_USER_ROUND_GATE。** 用户已取消逐轮人工审核，要求最终完整加速器结果。第1轮已获Astra综合后限定验收：PASS_SCOPED / MODULE_OOC_COMPLETE / PERFORMANCE_NOT_IMPROVED；第2轮GPT-6.1 Sol/xhigh已完成单实例F32 add优化、受影响CPU/RTL及实际OOC，Astra已确认同配置局部功能、服务及资源改善成立；Sol继续真实GEGLU连接及完整推理。Astra仅在实际综合结果后评判，技术出口后继续推进。最终完整加速器尚未实现验证完成。

**最新可核实出口（2026-10-11）：** canonical GEGLU完整51 FP单元与row存储/control OOC通过，实际 **176828 LUT / 299253 FF / 48 DSP / RAM0 / blackbox0 / IOpad0**。算术子树95754 LUT/42834 FF；row存储/metadata/control81074 LUT/256419 FF，31488B逻辑row数据展开成寄存器，尚未完成存储优化。内部综合WNS+0.538ns/TNS0@6.667ns，2416输入/1538输出缺delay，不能确认物理频率。guard exit0/null、923.575s、owned RSS23007172KiB；root核[终态收据](attempts/geglu_canonical_row_01/receipt_ooc_01.json) SHA256 `e7281e13670ceadcd619be41cb858c5a1ca21764e903c7954180fd8a7c942d71` 的38份引用全匹配，原日志无ERROR/FATAL。六整行RTL功能证据仍有效，真实HBM writer/quant/Down不在本例覆盖内。Astra依据该综合和PS成本中止结果内部修订存储/服务合同；production真实GEGLU→GATE→quant/fullA一整行RTL已通过：实际Wi5248→canonical gate2624→164次真实AW/W/B→完整发布/lease→164次真实R→一个整row量化命令/82group→完整双A/82次同步读独立gold；无GATE/q/scale/PS预置。实测20980cycles（含Wi标量输入、装载、AXI停顿）、quant954cycles；guard exit0/null、39.908s/RSS1325344KiB。root核[收据](attempts/t2_geglu_gate_quant_bridge_rtl_01/receipt.json) SHA256 `d38ebd70eedd36171c61e23ff7456f284eac6ede7a88738f86b5bda84e29ab79` 的5份引用匹配及实际仿真PASS。此范围不含上游Wi矩阵计算、下游Down、四row完整链或活动reset/晚错；受影响恢复覆盖继续。完整加速器与整体性能仍未验证。

当前实现分工：

| 实际代理 | 工作 / 唯一实现责任 | 状态 |
| --- | --- | --- |
| `laya_round1_sol61_xhigh`，GPT-6.1 Sol/xhigh | 单实例加法服务优化；vector/GEGLU及生产`vector_full_compute`接入同gold新leaf | 第2轮及真实GEGLU CPU/RTL/OOC已限定验收；旧stream02实际RTL gap1/L375通过，OOC成本中止；canonical3-helper新parent L384合同已冻结，原owner已完成新图CPU/实际helper及主RTL，完整canonical OOC及G51 OOC已通过；G row存储实际为FF/mux；RUNNING，Astra综合后已定义§8.4.10；三bank/六row功能通过，新父OOC成本中止；该owner已结束释放槽，G路线当前余2338.224019s |
| `laya_production_sol61_xhigh`，GPT-6.1 Sol/xhigh | quant/Q8/真实ACT生产连接；Host/全图验证入口与当前build身份 | RUNNING，ACT真实交接RTL06已通过；build23c62cd4完整生产CPU及实际Vitis CSim四请求通过；真实blackbox接入/32bank装配OOC及七shape输出继续 |
| `laya_attention_sol61_xhigh`，GPT-6.1 Sol/xhigh | Attention真实QK→mask/softmax→AV、tile服务；`full_tasks_attention.cpp`与相关C model/header/JSON/generated caller及其claim/lease/13BO内部接入（唯一owner） | RUNNING，完整head软件通过；同clock CE修复后实际query0–7全K128/D64链及协议/reset通过，完整128query及OOC通过；新精确M16/A16/D4+4exp实阵列合同已冻结，原owner恢复实施及回归 |
| `laya_post_stream_astra_xhigh`，GPT-6 Astra/xhigh | canonical流水/通用GEGLU桥/调用粒度合同及综合后集中评判 | RUNNING，已有§3.8/§8.4.10交工程实施；据新G OOC成本中止集中闭合实际C/JSON/AXI生产绑定、Attention首错及有界综合方法，无用户审核门 |

各实现owner协调跨模块连接，全树共享单重工具锁。已取消用户逐轮审核；第2轮已取得局部实际结果、Astra已确认数值/服务/资源范围；ACT局部连接、完整head Attention及当前完整CPU/CSim结果各按下文范围登记；完整物理生产连接和整体性能尚未验证，不能与局部PASS混同。

同步PS v2原真实四个不同Down激活全维度回归通过：[收据](attempts/t2_tm4_sync_real_down_01/receipt.json) SHA256 `05b13a554677833389de0559961b1f158a66b974b4145a3dde3317ac949bf6cb`。root核两份引用/原日志/guard0/null（377.579s/RSS2333636KiB）；G82/T128完整10496stripe、41984四row commit、335872 lane-group的dot/dotF/scale product/term/PS及trace逐位通过。实际read/copy/launch各10496，busy/front/launch/commit停顿0、credit598；A/W仍为外部已量化真实fixture，不代表resident cache、writer或13BO生产连接通过。

G三bank新父OOC为成本中止：[终态收据](attempts/geglu_canonical_row_01/row_bank_v1/receipt_terminal_01.json) SHA256 `88529ff76bc4df5cbe1831aa82447ef3ec7311a8100bcc94de2d6915bfc3254e`。Cross Boundary Area连续120s无语义输出触发停止，guard child−9/164.188s/RSS3793524KiB；无新父最终DCP/映射资源/时序，不是数值失败或内存超帽。原G累计1261.775981s、余2338.224019s；精确51FP算术子树导出及三bank/六row功能仍通过。root核23引用：20现行引用匹配，另3条明确标记superseded的准备脚本在`source_versions/pre_export_mapping_fix_01`原SHA匹配，未把当前同名脚本冒签旧身份。vector已结束；原Astra已恢复集中处理真实matrix_run C/JSON/AXI绑定、Attention首错及不同有界G OOC闭合方法，无用户审核门，不原样延长运行。

同步PS v2局部功能pilot已通过：[收据](attempts/t2_tm4_sync_ps_pilot_01/receipt.json) SHA256 `1207672e5d54d011fae433b93d747cd7cc46ab07d446e816d07c5e2f3a3397a2`，root核两份原日志引用匹配/实际PASS/guard均0/null。32PS＋4metadata完整656地址、47232读检查、同步hold/G128进度、两entry边沿及预扣守恒、256四row synthetic stripe、ACT8group、5种header零RAM/零FP拒绝、独立commit/trace反压及活动reset通过。此数值使用独立signed dot/scales1诊断数据，未代签真实模型；实际`F_PS_min=37`，大tile连续接受gap1..3，新前端和Q35信用成本已进入服务账，未继承旧II1。原真实不同Wi/Down全矩阵gold受影响回归、resident完整matrix caller、物理PS资源及真实Down链继续实施。

G三bank修复当前功能已通过、物理映射待测：[新功能收据](attempts/geglu_canonical_row_01/row_bank_v1/receipt_functional.json) SHA256 `33d1b85a20d06334ab14f30ab63626fd4d698348afab421beea7b5e5ab07a2a5`，root核11份引用匹配及实际原日志无ERROR/FATAL。3×2624 bank全地址23616读/15744写/7872非同址并发、停读q保持；原六row31488 Wi/15744 gate/157440独立十步与原错误/reset协议均通过，新增同步边沿及generation/17cycle停发保持也通过。原算术hash/core506/tanh384385未变；正常issue→末输出5753cycle差未增加。新冻结模块已交production重跑真实物理桥；实际RAM/OOC/DCP资源与完整生产目标仍未完成，原RAM0基线保持。

真实GEGLU→物理GATE→整row量化→完整双A四row协议扩展已通过：[RTL03收据](attempts/t2_geglu_gate_quant_bridge_rtl_03/receipt.json) SHA256 `60730c7a7363c40d8ea4f12f0ff85feb0af27a9446aa1d5afb9fe88075ebde0b`，root核5份引用匹配/原日志PASS及guard0/null（99.038s/RSS1329968KiB）。实际20992 Wi输入/10496 gate、656 AW/W/B与656 R、4整row命令/328group及328同步A检查，59975cycles；四row重复同一不可变真实Wi fixture，只证明该数值payload的四row物理/协议，不能称四个不同激活或完整Wi/Down链通过。下一新Down/双A交叠覆盖将直接复用已有四个不同真实row与各自独立gold。新同步G存储身份仍需受影响桥回归。

待下一次实际综合后Astra集中解释的生产依赖：新Attention cmd18局部错误索引`row_local*64+d`与原production `bad_element=d`的适配，以及整tile Q捕获再QK相对旧逐row捕获/运算的晚Q错误优先级。正常真实有限输入模块验证继续；新生产故障语义未核定/未验证，不删除旧错误覆盖，也不提前登记通过。另需明确完整matrix_run的实际C/JSON存储/AXI绑定：旧Group32黑盒只scalar，真实矩阵cache AXI须由同生产入口/原BO接入，未绑定额外RTL口和独立SV TB都不能证明13BO生成kernel接通。production继续已定义同步PS/驻留物理服务，未用接口改名冒签生产。四槽当前全部由root及三个Sol使用，G新父OOC终态后vector释放槽，主控恢复原Astra集中收口这两项；无用户审核门。

当前实质存储/服务合同已由Astra综合后集中修订：[§3.8](source/design.md#38-实际ps展开失败后的同步bank与完整matrix驻留生产控制器)定义32同步PS bank、4metadata bank、两entry read/copy/launch、预扣Q35/D4、真实RMW反馈及唯一group-major `sequence=g*T+tile`；同一完整matrix/view真实驻留调用须包含全G/T和同生产入口generated caller/13BO内部接线。production已直接实施，原ACT/cache累计余2950.195459s。 [§8.4.10](source/design.md#8410-g51完整row实际ram0后的同容量三bank修复)定义U/G/gate同步bank，原vector owner恢复受影响六row/桥及bank映射验证；原G路线累计余2676.424594s。未验证新RAM资源或驻留Down成功，未宣称完整加速器完成。当前内部流程不等待用户审核。

当前依赖已收口：Astra在[联合设计§8.4.9](source/design.md#849-逐节点成本实测后的三类canonical流水子核与新父图)冻结三类完整operand helper复制的新parent、E384 commit及512总credit，停止42/候选36专用节点闭合路线；原累计220.973399s与剩3379.026601s保留。vector owner连续实现及重跑受影响RTL/OOC，新实现已取得独立L384实际RTL证据（见下），不继承旧L375实测。GEGLU生产桥按§7.3.3保留完整GATE任务真实写响应退休/发布屏障，由vector与production唯一owner协同接线；§7.3.4改为整row量化/全部G tile驻留服务，避免单Group wrapper同步调用吞吐退化。这些是已冻结待验证的新设计，不是新增硬件PASS。

第2轮实际结果（Astra关键证据复核已通过，无用户审核停点）：

| 项目 | 实测 / 原始证据 | 当前边界 |
| --- | --- | --- |
| 功能 | 345独立native F32/RNE加法定向RTL（原52项前缀未变）；3270项×正常/反压、两种reset恢复通过 | 原冻结真实输入/gold不变，非全F32穷举 |
| 同口径服务 | 正常span 2011256→1249315cycles，减少37.8838%；受压span1256248；真实首次valid348–473cycles | 仅独立tanh服务；不是整网时间或稳态请求吞吐 |
| 实际模块OOC | 9073LUT / 6510FF / 2DSP，BRAM/URAM0、黑盒0；同02配置 | 综合态WNS+2.486ns、无物理Fmax/P&R结论 |
| 成本 | OOC179.395s，owned RSS4343764KiB；全部guard exit0 / trigger null | 沿原成本帽、共享锁；未影响其它项目进程 |

原始证据：[第2轮收据](attempts/tanh_libm_round2_01/receipt.json)、[RTL日志](attempts/tanh_libm_round2_01/guard_rtl_01/driver.log)、[实际资源](attempts/tanh_libm_round2_01/ooc/utilization.rpt)。本轮为局部数值保持的服务改善，仍未接完整GEGLU/全图验证；下一项优先真实GEGLU producer与同图空间流水，而非继续无限微调add。

真实GEGLU连接出口（Astra已完成实际综合后限定验收）：冻结真实Wi5248输入→DUT完整逐步GELU→2624门控输出，CPU2624输出/26240独立步骤、RTL正常/反压合计5248输出/52480步骤全部通过，并核加载/运算/待返回3类reset及index/numerical拒绝恢复。普通服务475–600cycles/result；正常完整row span1440799cycles（含加载/填充排空），仍为串行正确基线。OOC **9347LUT / 6689FF / 2DSP / 8 RAMB36 / URAM0 / 黑盒0**，仅综合态WNS+2.486ns；OOC197.246s/owned RSS4354560KiB，全部guard exit0、无触发。[真实收据](attempts/geglu_libm_producer_01/receipt.json)。生产7源已冻结供新完整build使用。这是检查点重放的真实Wi→GEGLU边界，不是同runtime Wi矩阵producer→GEGLU→quant/Down整链或完整Encoder通过。

同图空间流水独立CPU已通过。HLS01内联全部节点时调度连续120s无语义输出，被保护停止（287.677s、owned RSS5074020KiB、child−9），属成本中止，不是数值FAIL；原日志保留。按同图独立算术子模块修复的HLS02已生成。实际helper02通过1159例（345add/409mul/405div，保留原52）；实际主RTL3270项×正常/反压及640项credit填满/排空、在途/待返回reset通过。正常span3645cycles、accept gap1、core固定375周期、peak credit376；原反压profile span6448、max gap16、peak512。每profile两个真实divider各3270接受/返回守恒。root已核[主RTL原日志](attempts/tanh_libm_stream_02/guard_rtl_01/driver.log)及[guard终态](attempts/tanh_libm_stream_02/guard_rtl_01/guard_result.json)：exit0/null、24.770s、owned RSS859924KiB。首次helper RTL有符号零首差源自采样提前一周期，修复TB后原native gold不变，旧fail保留。模块OOC01在Cross Boundary/Area Optimization连续120s无语义输出后被原guard停止：child−9/semantic_stall，220.479s、owned RSS11218356KiB；无资源、时序、DCP或综合后blackbox结论。[阶段收据](attempts/tanh_libm_stream_02/receipt.json) SHA256 `22ad69a6dbdf9d621932a4c7cd4102da594a559d3846d09f0e1296f4b37a3d32`，状态RTL_COMPLETE_OOC_COST_ABORTED。实际RTL功能与局部服务通过保留，Astra正集中评判保持同图的综合成本修复；同runtime GEGLU/完整生产接入与整图性能尚未验证。

[canonical新parent实际功能收据](attempts/tanh_libm_canonical_01/receipt.json)已取得，当前`RTL_COMPLETE_OOC_PENDING`：CPU3270项/137340独立native node result、1159helper通过；实际helper1159与3270双profile/640 credit满排空/在途及待返回reset通过，42个节点operand/result按同token对独立native trace核对。正常span3654cycles、持续accept gap1、E384提交/E385最早消费、peak385；反压span6464、peak512、2245次credit停顿。root核CPU/static/helper/pilot/full原日志hash与guard全部0/null，full22.193s/RSS859916KiB。首次收据SHA256 `017ff8cd1ac8a58e793d0cde1764f5a81e6231fe43d5d477c32c97595e1469dd`；后续OOC变化另绑定终态，原编译失败/旧身份保留。新L384下全部tanh主体＋3601逐row tail条件为72.025600ms@150MHz，仍不含GEGLU7M/2A、LN、Attention、Q8和真实供数/发布。当前无新parent资源/时序/DCP结论；完整GEGLU/物理桥尚未通过。

真实ACT生产连接RTL06已完成（模块OOC01解析失败、02成本中止；功能RTL按原身份保留）：真实F32→精确quant16→双A完整发布/lease→真实双W供数→TM4/PS→bias→AXI512 writer，4个正常row全部q/scale/PS/两个实际输出F32及哨兵通过，正常command378–379cycles。最终元素255的+Inf拒绝后A不可发布、W保留及恢复；活QUANT reset取消旧owner后实际重新LOAD恢复通过。实测2次LOAD、32 PS group commits、4次AW/W/B，输出各8B；guard exit0/69.003s/owned RSS2467044KiB、无trigger。[原始RTL日志](attempts/t2_act_production_rtl_06/guard/driver.log)、[guard终态](attempts/t2_act_production_rtl_06/guard/guard_result.json)。此scope仅ACT K256/N2及所测连接，不代表其它6种真实Q8shape、完整Decision/Encoder或生产HLS调用链已通过。前序Tcl/TB/保护中止失败保留；完整新build及RTL blackbox生产接入继续执行。

ACT06实际OOC已执行但未取得资源结果：01因85,983,232bit qmem超过工具变量解析上限而失败；仅修工具解析配置的02越过该错误，但实际3D RAM寄存器展开警告后连续120s无语义进展，保护停止。root核[02收据](attempts/t2_act_production_ooc_02/receipt.json) SHA256 `bc3d034dd345183d7a2bf8ba677a688825a5b9a1e30c1c51db9f86e0148dded6`及[guard](attempts/t2_act_production_ooc_02/guard/guard_result.json)：child−9/semantic_stall、205.107s、owned RSS9776424KiB。两次均无utilization/timing/DCP，不判物理fit失败，也不判原ACT RTL数值失败；Astra正依据32个实际bank的端口/时序定义有界同bits存储修复，不原样加帽重试。

存储成本修复已取得真实单bank出口：完整10496项q/scale与328项bias的同步读/写RTL通过；单完整bank实际OOC为12 URAM、7 BRAM tiles（6 RAMB36＋2 RAMB18，共8原语）、黑盒0。[OOC收据](attempts/t4_w_cache_bank_ooc_01/receipt.json) SHA256 `df7ff7093122903a677111f61c2fa1471b9d7ee942e7bb890b1e9283ed354109`；root核guard exit0/null、67.472s、owned RSS4199828KiB。这是单bank范围，32bank完整cache装配已取得下述05实际出口，资源不再仅靠32倍投影；整图/平台fit仍未验证。新bank七shape供数和ACT07数值连接结果见下。

新32bank缓存的[七shape真实RTL](attempts/t4_dual_w_seven_rtl_full_01/receipt.json)已通过：9次LOAD、完整七shape q/scale/bias逐位供数、G128末组127/非法128拒绝、lease/反压/错误/reset与返回保持；实际pair返回同拍opposite-slot LOAD commit共10417次。root核收据SHA256 `c70ff2b7420e34624c8ee09d69157ef145682a3929e8da7ada2f6a64ac0a6ba2`、原日志hash和guard0/null、26.857s/RSS845276KiB。计数坐标包含setup/reset，不作精确LOAD或端到端延迟。仅缓存范围，不代表七shape算术与物理输出整链。

[ACT07新bank连接回归](attempts/t2_act_production_rtl_07/receipt.json)保持ACT06其余算术/output/TB冻结源，仅替换32bank cache接线，4真实row、晚Inf拒绝后恢复、活动quant reset取消旧owner后重新LOAD均通过；command379/379/378/378cycles，32PS group、4AW/W/B和独立q/half/输出检查完整。root核收据SHA256 `1c92a3c7e2d4bddfb8c4ccb0fff78f5a62de995408a01b32dad399f020188a8b`、原日志及guard0/null、77.498s/RSS2467320KiB。新cache完整装配OOC01在首次DCP插入后因Project1-9工具流程失败：134.884s、RSS16168664KiB，无完整DCP/资源结论；保留[失败收据](attempts/t4_dual_w_cache_assembled_ooc_01/failure_receipt.json)。Sol修复in-memory装配流程并沿同一路线累计3600s帽继续，未加帽原样重跑。

[新GEGLU完整row功能收据](attempts/geglu_canonical_row_01/receipt.json)状态`LOCAL_COMPLETE_ROW_RTL_PASS_PRODUCTION_BRIDGE_PENDING`：新L506 core441corner/2952适用step/4410predicate；完整6row共31488 Wi输入、15744 gate输出及157440逐步参考比较通过，完整身份/旧ref/index、源读债务、晚G/U首错及3种活动reset、全row成功屏障均核。root核收据SHA256 `4a10ab40d1c1c5a6ace7d807ed445b60fc7df4111e839f152fbd78b7cecfbfda`、10项阶段日志/guard，full RTL91.538s/RSS860096KiB、guard0/null。正常row arithmetic-first62515→last-commit65644→first-output65645→last-output68268仅为本TB事件坐标；物理GATE writer ACK仍diagnostic，不能称真实GATE写响应/ledger→quant/Down生产桥通过。该真实adapter已直接交production集成；完整新GEGLU OOC须支付51个实际FP节点及31488B U/G/gate RAM，不沿tanh局部资源代签。

通用生产连接所需的新存储/供数/输出组件已有下列独立实际RTL出口。root核各receipt引用的input/driver/simulation hash及guard0/null；**该表仍是组件测试，不能代替真实量化→双A→MAC→bias→writer完整链。**

| 组件与原始收据 | 已通过范围 | 运行成本与未覆盖 |
| --- | --- | --- |
| [映射后完整W单bank](attempts/t4_w_cache_bank_mapped_rtl_pilot_03/receipt.json) | 实际URAM/BRAM网表，10496 q/scale＋328 bias、1edge同步读、31cycle保持及3写口；仅修TB200ns初始化等待 | 57.320s；32bank完整装配仍未通过 |
| [完整双A](attempts/t2_quant_dual_a_rtl_pilot_02/receipt.json) | 139264B、双slot各16row/G128，2118独立row-group返回、反压、opposite-fill、晚错禁止发布、完整identity/reset | 11.524s；synthetic store/lease，没有量化producer |
| [双row F32 feeder](attempts/t2_quant_f32_two_row_rtl_pilot_03/receipt.json) | 32768B、K256/1024/2624/4096、16row、完整物理读响应屏障、1166反压检查、IO/晚quant错/reset/范围 | 10.582s；真实quant消费者组合未测，原late done双释放失败保留 |
| [七shape物理writer](attempts/t2_tm4_writer_seven_rtl_pilot_03/receipt.json) | 7shape/8layout、QKV双shard/Wi列5247/G128/Scorer row15/ACT mask、8259beat，错tag不写及BRESP新epoch恢复 | 23.649s；synthetic packet source，未与真实MAC/bias连接 |
| [精确bias F32 helper](attempts/t2_tm4_bias_bits_rtl_pilot_02/receipt.json) | 4156独立有理数pair、208精确helper/3948 native-safe路由，maxexp≥25边界 | 9.085s；尚未与native bias/writer复合服务验证 |

官方quant generated02实际caller发现握手FAIL：leaf接受cycle42、cycle80返回，parent state145仍等待，ap_continue常1消耗提前done，512cycle自检超时。原[失败收据](attempts/t2_quant_generated_rtl_02/failure_receipt.json)保留；随后按最早等待下限1/1重生成、末RAM真实采样及tiny错误诊断修复，05实际回归通过（见下）。C函数通过不能覆盖此caller失败，新整row服务亦未因此通过。缓存装配02/03原Project1-9工具失败保留；05冻结DCP结构EDIF装配已取得完整cache资源/黑盒0（见下），累计成本不重置。

[quant实际generated caller RTL05](attempts/t2_quant_generated_rtl_05/receipt.json)已通过限定120call/114真实Wi+Down group：真实leaf issue/return各120、240输入half beat，全部23个scalar-valid字段及23个输出RAM word每call恰好一次并对独立gold；zero/Inf首末元素/tiny reciprocal overflow及恢复通过，caller CE暂停13cycle/返回保持8cycle。root核收据SHA256 `caefc0e264a8fc92426ec892444e5272292381883b074260d0ee5a95e9240518`及input/driver/simulation hash；guard0/null、38.046s/RSS1937020KiB。**当前只证明单Group32 wrapper真实绑定，性能尚未改善**：Wi32group2176cycles、Down82group5576cycles，actual issue interval44..72；不能继承完整row quant16的141/341cycles。完整inner-domain CE暂停尚未证明，真实整row/双A producer复合连接继续。原earlydone、末RAM采样和tiny诊断失败均保留，未改gold。

[完整32bank缓存实际装配OOC05](attempts/t4_dual_w_cache_assembled_ooc_05/receipt.json)已通过：冻结exact bank/parent DCP导出结构EDIF并链接，实际32bank、384 URAM288、192 RAMB36＋64 RAMB18（224 BRAM tiles/448 BRAM18等价）、22008 LUT、15469 FF、18 DSP、黑盒0；完整资源/DCP为实际装配结果，非单bank32倍投影。root核收据SHA256 `b31ab570ff642652c923cb44d00f54463244640d69c701c5153ae61e26397719`及8引用制品/日志hash；guard0/null、94.692s/RSS4425304KiB。本路线累计505.458116s/3600s，未因失败或更换工具装配名重置帽。普通link_design含IO pads，综合WNS−3.043ns/TNS−187.154ns @6.667ns、WHS−0.117ns仅诊断，**综合约束未达，P&R/Fmax未验证**；资源装配PASS不能宣称150MHz实达或整图/平台fit。原read_checkpoint工具失败与功能七shape/ACT07原身份分列保留。

Attention真实连接已通过query0–7×完整K128/D64的QK→mask/softmax→AV、全部既定协议/错误/身份/scratch/reset、chain保持及真实活动流水CE暂停/复位抢占。原native CE失败保留；新同clock生成RTL补丁使整个相关层级一致暂停，并自动绑定原/新身份。[实际formal01日志](attempts/t5_attention_service_rtl_formal_01/guard/driver.log)终态 `ATTENTION_SERVICE_RTL_PASS rows=8 keys128 D64`，856061cycles；root核[guard](attempts/t5_attention_service_rtl_formal_01/guard/guard_result.json) exit0/null、205.235s、owned RSS2083400KiB。当前scope是冻结enc0/head0检查点重放，完整128query实际PASS见下，其它head/层及真实生产调用链尚未通过；单MUL/ADD/DIV是正确功能基线，不宣称高吞吐。实际[Attention OOC01](attempts/t5_attention_service_ooc_01/ooc_result.json)已通过：10399 LUT、6282 FF、22 DSP、145 RAMB36＋7 RAMB18（148.5 BRAM tiles）、URAM0、黑盒0；综合态WNS+2.807ns/TNS0 @6.667ns，132输入/39输出无delay，不证明物理Fmax/P&R。root核结果SHA256 `71d81088ceadee7d321562309284974dc25943a6213c732a0edc0b01f8391801`及4实际artifact hash；guard0/null、247.966s/RSS5694292KiB。完整head新证据及服务成本见下，性能改进仍待集中实施。

Attention [完整head128真实RTL](attempts/t5_attention_service_rtl_head128_01/numeric_result.json)已通过：冻结B1/S128 enc0/head0，query0..127每行完整K128/D64；8个16row批严格QK→SM→AV，16384 score/exp/prob、128 max/sum、8192 output与独立gold逐位一致，原身份/错误/活动CE/reset抢占及重载检查均保留。root核实际`ATTENTION_SERVICE_RTL_PASS rows=128 keys128 D64`、原日志无ERROR/FATAL、三个phase覆盖恰好0..127和8批数值计数；结果SHA256 `428020bd5a97b8265e0ff98c73d5b659169ac6469c291d08f71fbebee568c52d`，引用guard/source/input/CE/log hash匹配。guard0/null、1721.067s/RSS951152KiB，未触及原帽。

**完整Attention基线性能偏低，功能PASS不等于性能PASS。** 本TB全窗口8380004cycles包含拒绝/reset/重LOAD/readback等。只累加合法且不重叠cmd7/8/9真实接受→done并扣已知拒绝/人为CE暂停，8批正常compute合计6816248cycles；每head条件45.441653ms@150MHz，同shape/mode机械计480head为21.8119936s，均未含生产caller、搬运/发布，亦不是完整模型实测或物理频率。QK/AV标量调用与SM开销已成为明确瓶颈，Astra将在实际OOC及该实测基线上集中设计共享FP/存储服务改进；不使用旧理想F256/C4投影作为当前实现速度。完整其它head/层、生产生成controller连接、整图RTL/连续多请求及板端仍未验证。

完整head实测及实际OOC后的集中方案已冻结：联合设计§8.1.2统一quant/TM4/Attention真实launch/done/字段valid/continue/末RAM写和CE规则，JSON1/1只作最早等待下限，必须由实际generated caller证明；失败只允许单cmd/response真实完成adapter，不用人工完成延迟。§8.3.1实施精确canonical M16/A16/D4与4份现正确非流水exp，保留maxS1024 KV/16row工作容量及有限上下文/credit，QK/AV/SM同图分时共享；Attention Sol已恢复实现，当前NOT_COMPILED/NOT_VERIFIED。16份完整旧服务复制超BRAM，因此不采用盲目整服务复制。后续按4query→16row→可落帽完整head实测服务及模块资源再集中评判，不把旧F256/C4理论服务作新实现成绩。

当前身份完整生产CPU C仿真已通过：build `23c62cd4778f54e3cc7508f5d05558de`、包 `model-current-production-v2-20261011`，实际生产C源码包含同bits GEGLU；持久4请求中3个正常请求覆盖完整28 Encoder＋2 Decision＋scorer/ACT，共141独立检查点、18,094,384个F32逐位一致，另1个gamma故障请求及随后恢复通过。root已直接核[终态原日志](attempts/current_production_full_cpu_01/guard/driver.log)及[guard](attempts/current_production_full_cpu_01/guard/guard_result.json)：child0、trigger null、338.283s、owned RSS630752KiB。这是g++执行生产C的完整数值回归，不是实际Vitis CSim、RTL生产连接、硬件吞吐或带标签数据集准确率通过；实际冻结Vitis CSim及blackbox接入继续执行。

同冻结身份的实际Vitis CSim02也已通过：四持久请求/3正常/141独立检查点/18,094,384个F32逐位比较及故障恢复，工具原日志 `CSim done with 0 errors`。[收据](attempts/current_production_full_vitis_csim_02/receipt.json) SHA256 `79632084106bc17c4ab31f1dac482b7d75074dd8cf00fa8d2d720ff827b805b7`；root已核[原日志](attempts/current_production_full_vitis_csim_02/guard/driver.log)及[guard](attempts/current_production_full_vitis_csim_02/guard/guard_result.json)：child0/null、317.126s、owned RSS1789276KiB。使用真实clang编译和冻结依赖，标准libm无libhlsm；入口为13BO top之下的`full_execute_cpu_request`，不是物理13BO或新blackbox生产RTL通过。后续服务接入改动将建立新身份并重跑受影响完整图，不能沿用本身份代签。

当前全shape物理输出接口缺口已定位：legacy bias/output与writer的group/tile/列号及bias缓存上限不足Wi5248和K4096。ACT06实际RTL范围不扩大；生产C/HLS的全shape普通写出路径也不能证明该旧SV物理链已全shape通过。Astra已在合同§3.7定义416bit全7shape packet、输出地址/owner/债务要求，Sol直接实施；实际Attention chain+ce候选按§8.1.1验证，stream02综合成本路线按§8.4.8实施，不等待用户审核。

| 第1轮修正身份02验收项 | 真实结果 | 证据与边界 |
| --- | --- | --- |
| CPU数值 | PASS_SCOPED：52定向＋3270 fixture；另200000有限tanh/600000基本op对照 | [CPU原日志](attempts/tanh_libm_round1_02/guard_cpu_02/driver.log)；冻结2624真实＋640有限边界随机＋6非有限错误；不是全部F32位型穷举 |
| 实际helper RTL | PASS_SCOPED：52例独立原生RNE gold | [正式RTL原日志](attempts/tanh_libm_round1_02/guard_rtl_01/driver.log)；同次生成fp_add_bits实际子模块，精确抵消/±0/相邻非零两顺序；-1+1正确返回+0 |
| tanh RTL/协议 | PASS_SCOPED：3270项×正常/反压profile，两类reset恢复 | [RTL guard](attempts/tanh_libm_round1_02/guard_rtl_01/guard_result.json)；原ordinal23现在bf3a726a同gold；总4037232cycles，未接完整GEGLU/Encoder |
| RTL服务 | 正确基线，PERFORMANCE_NOT_IMPROVED | 普通真实首次valid517–795clk；较首次候选更慢；不是请求完成间隔/整网时间，不能与旧错误leaf计算有效加速比 |
| Vivado OOC | PASS_SYNTHESIS_SCOPED：10410 LUT、7132 FF、2 DSP、BRAM/URAM0、blackbox0 | [资源](attempts/tanh_libm_round1_02/ooc/utilization.rpt)、[DCP](attempts/tanh_libm_round1_02/ooc/tanh_libm_wrapper_synth.dcp)；仅leaf＋wrapper，非整网/平台fit |
| 综合态时序 | 6.667ns约束，内部setup WNS+2.486ns、TNS0 | [时序](attempts/tanh_libm_round1_02/ooc/timing_summary.rpt)；67输入/67输出无delay、无HD.CLK_SRC/skew、hold NA；P&R/Fmax与上板未测 |
| 新综合配置 | RuntimeOptimized / resource_sharing off | 与01配置不同；资源/成本差异不作纯修复代码收益或公平A/B。add/div/mul均单实例，实际WARNING6行 |
| 服务器成本/保护 | OOC228.657s、峰值owned RSS4335924KiB≈4.135GiB；无guard trigger | [guard](attempts/tanh_libm_round1_02/guard_ooc_01/guard_result.json)；最小MemAvailable432061292KiB；自动语义120s保护与短静默自检生效，面积优化未超语义阈值 |

首次01原身份保留：[receipt](attempts/tanh_libm_round1_01/receipt.json)。其已测tanh范围/综合资源有效，但基础add精确抵消零符号错误，不能称通用helper RNE通过；原01约130s语义停滞未及时停止的COMPLIANCE_GAP保留，不因02 guard修复追认旧运行完全合规。旧01 DCP不代签02。独立gold与原失败日志未改。

02修正身份已获[Astra最终限定验收](source/results.md)，用户已取消轮次审核；第2轮同gold/单实例add/mul/div优化已经实际通过、完成OOC并获Astra限定验收，数值与性能见上表。下面T0–T7同时保留上一阶段身份及生产连接边界。

状态：CURRENT_INDEPENDENT_EXITS_CLOSED / MISSION_INCOMPLETE_PRODUCTION_CONNECTION_UNVERIFIED / CONTINUOUS_EXECUTION_AUTHORIZED。GPT-6 Astra/xhigh已完成T1–T5当前独立出口的集中限定验收；T3 READY失效/reset后重建和T4双W完整供数增量均已接受。此前T1–T5独立出口的重工具已结束；当前新生产连接/流水实现按共享锁继续运行，未重跑身份及验证语义未改变的已通过测试。完整加速器仍因生产连接未验证而未完成；旧tanh原数值FAIL保留，第1轮同gold替代leaf已获局部CPU/RTL及模块综合后验收，不自动继承到GEGLU/全图。T6/T7未运行。2026-10-11用户调整当前目标为先做出性能较高的Laya加速器，50ms/20完整请求每秒转为远期参考，不再作为当前唯一硬验收或淘汰依据。用户已批准执行；[mission](../../mission/compute_throughput_optimization.md)与[执行合同](source/design.md)继续保留目标及边界。本表是唯一动态阶段结果表，冻结历史证据仅按原身份复用。

| 任务 | 当前状态 | 实际结果与覆盖 | 下一依赖 |
|---|---|---|---|
| T0 联合接口/服务/资源基线 | EXECUTION_BASELINE_RELEASED / JOINT_BUDGET_OPEN | Astra/xhigh已发布合同§0–§9；TM4、CPU全scale预检/离线会话、T4三口LOAD/动态量化及T5单bank AV合同可执行。联合账明确存储/映射/真实服务及shell缺口；整体资源与完整请求服务预算尚未闭合；20请求/s为远期参考。此项为设计出口，不是硬件功能PASS | T1/T2/T3实际证据与T4/T5服务闭合 |
| T1 真实16行宽块前端A/B | ASTRA_ACCEPTED_16_ROW_SCOPED | 同一static_04：[normal含adapter探针](attempts/t1_formal_four_02/normal_adapter_receipt.json) byte/wide command2126573/1433020，[受压对照](attempts/t1_formal_four_02/pressure_receipt.json)2126578/1433025；起点均由冻结控制握手推得TB计数7，原raw计数分别再加7。四次guard0、16384 norm独立逐位一致/CRC d5c15b0f，四端口首次done物理及adapter全部债务/残留valid为0。宽版均少693553cycles（约32.6136%、1.484×）；压力各比同版normal增加5cycles、R/B hold各4。旧static_02 normal按原身份保留adapter NOT_OBSERVED及周期推导收据，不以新run追认旧日志；[端点short03](../../vivado/module_design/layernorm_engine/rtl/front16_axi_short_03/positive.log)独立AW/W、W-before-AW、AW停顿与endpoint reset恢复通过；错误WLAST/debt例实际fatal被runner按预期识别，guard0/15.093s。该短例不是活跃LN DUT整体reset覆盖；[真实RTL故障03](attempts/t1_fault_03/receipt.json) byte/wide各raw[0]/gamma[0] NaN早错及wide活动raw传输同域reset→早错重发5例guard0、完整observed/sentinel/首次done债务0、LN启动0及norm写0。gamma例实际完整65536B raw；该reset不证明算术在途或复位后16行成功推理。fault01闲时ap_done误计的TB失败保留。完整128行/全图未测。 | 集中验收已收口（source/results.md）；T4量化/供数 |
| T2 精确Q8映射/TM4 | SINGLE_A_FOUR_SHAPES_ASTRA_ACCEPTED_SCOPED / COMBINATION_ASTRA_ACCEPTED_SCOPED / REAL_GROUP_REPLAY_01_FAIL_COVERAGE_REPAIRED_02 | packing数学、整数RTL、真实ACT R0、192bit tag及TM4短例通过。新TM4真实ACT一行K256/N2全部8stripes通过；真实QKV四行K1024/N3072全部12288stripes/393216group records通过，guard0/408.346s。真实Wi四行K1024/N5248全部20992stripes/671744records亦通过，guard0/668.561s；高tile511→512→655覆盖。真实Down四行K2624/N1024全10496stripes/335872records通过，group63→64→81覆盖。A+B packing/LUT树组合短合成整数及独立真实ACT R0通过；真实group重放01被Astra发现fixture仅8条却声称136条，QKV覆盖不成立，记FAIL_COVERAGE；修复输入完整性和未知值断言后的真实02通过。动态quant/HBM/bias/writer、全部122矩阵与DSP物理映射无通过结论 | 单A范围已集中核验；组合范围已集中验收（source/results.md）；T4供数/动态量化 |
| T3 CPU静态校验/快速LOAD | ASTRA_ACCEPTED_V4_CPU_PACKAGE_LIFECYCLE / V2_R2_CPU_AND_RTL_AB_ASTRA_ACCEPTED_SCOPED / V2_REJECTION_COVERAGE_INCREMENT_ASTRA_ACCEPTED_SCOPED / V2_READY_INVALIDATION_RESET_CLOSURE_ASTRA_ACCEPTED_SCOPED | [真实整包报告](attempts/t3_real_session_02/work/report.json)及[guard](attempts/t3_real_session_02/guard/guard_result.json) exit0/29.493s/RSS1363504KiB；独立包检查、124目录中122张Q8矩阵、11542592 half/23085184B含48padding全扫通过。两次离线完整上传/读回一致，generation1→2失效重建；warm未重复scan（保持1），重建总scan2。首次冷prepare/upload/readback10.674/1.536/2.466s；这些是CPU/内存端点成本，不是PCIe/HBM时间。attempt01导入路径失败保留，修复后13单测工具输出OK但未持久保存原unit日志。Astra预读通过公开API复现verify_readback→activate间重传同长度内容后仍ACTIVE/authorize成功的窗口违约，原窗口违约记FAIL；owner已将成功完整readback与seal/event绑定，[受影响15单测](attempts/t3_lifecycle_regression_02/run.log)新身份通过，[修复后真实03](attempts/t3_real_session_03/receipt.json)15持久单测及两次v4真实完整scan/上传/读回、generation1→2恢复和warm scan保持1均通过，guard0/29.800s/RSS1402608KiB；02正常路径证据保留不追认。新Q8 v2入口已实现候选，实际包[01](attempts/t3_q8s2_package_01/validation_record.json)的153tensor/122Q8/11542592half独立校验通过，header含完整32B buildSHA；首次v2 HLS03发现不支持指针数组，等价switch修复后[actual-r2生命周期](attempts/t3_q8s2_package_r2_01/lifecycle/report.json)两次完整新包校验/5BO上传读回、ACT授权/暖复用/reset旧generation拒绝及重建均PASS，guard0/29.13s/RSS1.33GiB；CPU内存ACTIVE≠device REGISTER。Host encoder字段/18beat短CPU通过；[r2补强CSim03](attempts/t3_q8s2_csim_r2_03/guard/driver.log)生命周期、真实q/half及strict64/fast0检查次数通过（未独立比较F32输出）。[r2功能HLS](attempts/t3_q8s2_hls_r2_01/guard/guard_result.json) exit0/58.877s/peak RSS1639812KiB，实际Verilog生成；[HLS报告](attempts/t3_q8s2_hls_r2_01/work/hls/solution1/syn/report/q8_tm1tn8_session_dma_v2_csynth.rpt)请求6.67ns、估计21.308ns（约46.93MHz），150MHz性能目标未满足，未做物理实现。同trace-on的设备[STRICT05](attempts/t3_q8s2_act_rtl_strict_05/guard/driver.log)/[FAST02](attempts/t3_q8s2_act_rtl_fast_trace_02/guard/driver.log)强化RTL已通过：LOAD4447/4449对4111/4113，均少336cycles；RUN均5681，数值/实际绑定/14负例及零债务已获Astra限定验收；既定状态/恢复增量[STRICT02](attempts/t3_q8s2_act_rtl_contract_strict_02/guard/driver.log)/[FAST01](attempts/t3_q8s2_act_rtl_contract_fast_trace_01/guard/driver.log)通过23/21拒绝及合法恢复，已获增量限定验收；W_READY实际binding撤销及reset后gen2设备重建专用短增量两profile已通过并获Astra集中限定验收。旧v4记录不覆盖未来新kernel，13-BO完整图与板端仍未接入 | 集中验收已收口（source/results.md）；r2 CPU范围集中验收；v2实际ACT strict/fast |
| T4 供数/量化/W预取/阵列 | CPU_AND_VITIS_CSIM_PASS_SCOPED / FUNCTIONAL_HLS_AND_RTL_PASS_SCOPED / STREAM16_EXACT_ADAPTER_RTL_ASTRA_ACCEPTED_SCOPED / RAW_IP_TINY_FAIL_PRESERVED / DUAL_W_FULL_RTL_SUPPLY_LEASE_ASTRA_ACCEPTED_SCOPED | 32slot quant16独立真实Wi K1024/Down K2624各一行q/half与每组d_full/reciprocal预检通过；峰值3已预约slot、32/82 scalar issue-return，双A发布。冻结fixture及功能HLS入口主机预检guard0/1.776s/81440KiB。CPU队列延迟只是调度模型，不证明实际divider II、group/4clk或FP流水。真实Vitis CSim01另guard0/11.091s/RSS1251344KiB，完整Wi/Down各行及两个拒绝用例通过。功能HLS syn03 guard0/33.844s/RSS1194552KiB，生成估计52762LUT/19787FF/3DSP/2BRAM18，单FMUL/fdiv与单8bit输出口、非流水主循环；未实现规定16lane/16bank，性能不能通过。功能RTL cosim02 guard0/174.890s/RSS5923996KiB，真实两行及两个拒绝例、全部q/half/d_full/reciprocal比较通过；4事务71571cycles，max50177（串行功能top），不证明1group/4clk。cosim01声明深度/TB分配不符在RTL前失败保留，修复仅TB分配。syn01/02工具入口失败保留；新显式16lane/16bank/32slot流式[real02](attempts/quant16_stream_real_02/guard/driver.log)真实Wi32/Down82组全部q/half/d_full/recip通过，分别141/341cycles，零/round及坏mask局部通过。但tiny 1e-38短例实际d_full=0、无RECIP且成功发布，违背非零subnormal→reciprocal非有限→INVALID合同，整attempt guard1/41.117s/RSS1889940KiB记NUMERIC_FAIL；其余既定边界/reset随后real03限定通过，旧tiny失败保留；[精确位适配01](attempts/quant16_stream_adapter_01/receipt.json) guard0/42.981s/RSS1903516KiB，257输入0 stale，真实Wi/Down全数值141/341clocks、27边界（17成功/10拒绝）、mixed6组及三类在途reset恢复通过。原tiny正确得到d0000db7f→Inf并INVALID/零输出，仍16M/单F32 divider/32slot，已获Astra局部集中验收；三口reader短02已通过：4个真实Wi/Down窗口三口各2×4KiB、逐byte/epoch/末拍/债务核对，guard0/31.189s/RSS860048KiB；该短例无AUX/bias/双W/READY/lease；后续[双W full05](attempts/t4_dual_w_full_05/receipt.json)真实Wi→Down、Scorer及ACT全bank供数/lease、故障隔离/reset恢复通过，guard0/6.818s/852652KiB，已获Astra集中限定验收（不证明MAC/物理带宽） | 独立双W出口已收口；完整生产身份/双A/MAC连接未测 |
| T5 Attention/vector平衡 | AV_C3_C4_ASTRA_ACCEPTED_SCOPED / SELECTED_VECTOR_OLD_50MS_REFERENCE_GAP / OLD_TANH_REAL_NUMERIC_FAIL_PRESERVED / NEW_LIBM_LEAF_ROUND2_ASTRA_ACCEPTED_SCOPED / LOCAL_SERVICE_AND_RESOURCE_IMPROVED / SPATIAL_PIPELINE_IMPLEMENTING | 单FMUL/FADD+partial bank真实S128、32query×feature0投影4096贡献均逐项通过：C3 5089cycles/stalls793；C4 4176cycles/stalls0。本征反馈F=13，C4轮转观测16不是本征F。历史tanh叶子全路径接受间隔≥3经Astra静态核验；四实例GEGLU加其余原理想项≥11604992cycles，即77.366613ms@假设150MHz，不满足原50ms参考；新目标下这不是直接淘汰依据，也不是完整请求实测。旧单叶子第24项（ordinal23）差2ULP、NUMERIC_FAIL保留；第1轮新libm数值基线通过后，第2轮345加法定向/3270双profile及reset通过，普通真实348–473cycles，正常span1249315、同口径减少37.8838%；实际9073LUT/6510FF/2DSP已获Astra限定验收。真实GEGLU和单流空间流水继续实现，完整连接尚未验收。没有F256或完整Attention吞吐PASS | AV已集中验收；新leaf已限定验收，无用户轮次停点；R2局部改善成立，生产连接/空间流水继续 |
| T6 完整Encoder producer链 | INTEGRATION_RUNNING / FULL_LAYER_NOT_RUN_DEPENDENCY | 新正确leaf已接真实GEGLU检查点重放并取得CPU/RTL/OOC限定验收；同runtime Wi矩阵producer→GEGLU→quant→Down完整连接、lease和整层成本仍待验证。合同§9根据实测403s/12288stripes投影当前TM4完整layer0仅四Q8约13.96h，超3600s。是条件成本风险，尚非新整层实际中止 | T4/T5；有界替代覆盖/具体配置成本准入 |
| T7 完整图/Host/多请求 | CURRENT_BUILD_INTEGRATION_RUNNING / FULL_GRAPH_RTL_NOT_RUN_DEPENDENCY | 新正确leaf已进入当前build23c62cd4生产源码；完整四请求CPU C仿真已通过（141点/18,094,384值及故障恢复），同身份实际Vitis CSim也已通过；新服务接入身份及RTL生产连接尚未完成。当前TM4完整单请求Q8理想46.055Mcycles，条件TM16/TN16最少8请求仅Q8亦46.055M，超40M帽。仅适用指定单引擎/几何，不证明所有方案不可验证；50ms/20请求/s仍未达但仅作远期参考，当前应先建立完整正确的性能基线 | T6/成本准入；分段RTL＋当前身份全图CSim与有限调度模型 |

## T2 已取得的实际证据

- [packing穷举](attempts/t2_pack_exhaustive_01/work/result.json)：全部16,777,216个signed8三元组，对独立int64乘法一致。仅证明数学。
- [整数短RTL03](attempts/t2_integer_candidates_03/work/xsim.log)：924接受=919返回+5 reset清除，检查22,056 lanes/1,040 pairs；guard exit0、10.222s、RSS859,996KiB。01的TB采样失败保留。
- [真实整数重放](attempts/t2_real_replay_01/work/xsim.log)：ACT全部8 groups、QKV首/末各64 groups，136 issues/3,264 lanes；guard exit0、9.822s、RSS859,880KiB。不是完整QKV。
- [LUT ACT R0](attempts/t2_r0_lut_act_02/guard/guard_result.json)和[packed ACT R0](attempts/t2_r0_packed_act_01/guard/guard_result.json)：单行8 groups的独立dot/FP/PS检查通过，guard exit0、43.71/44.26s。LUT_01使用旧Q32断言失败，修复为合同Q35后重跑通过。
- [192bit tag](attempts/t2_tm4_tag_01/work/xsim.log)：64短例通过。
- [四行TM4 pilot03](attempts/t2_tm4_pilot_03/receipt.json)：LUT候选，guard exit0、62.428s、RSS2,357,108KiB，无保护触发。合法QKV G32/T384配置下，仅group0前256 stripes连续接受，核1024 row commits后reset；没有完整QKV成功终态。合成四行ACT G8/T1完成8 stripes，覆盖反馈/尾lane。五个坏身份/版本/重复或跳序号/越界tile拒绝并排空恢复；另含单row commit反压、D4 trace ack阻塞、在途reset。271接受+5拒绝；1084 row requests=1080 commits+4 reset清除。01保留reserved-keyword编译失败，03是最新完整短范围结果。

- [当前v4实际producer捕获](attempts/t2_widown_av_capture_run_01/guard/driver.log)：四请求CPU/CSim，三正常请求141独立检查点、一次故障后恢复通过；request3/generation1/B1/S128实际V head0、LN_FFN、GEGLU成功导出，guard exit0/139.551s/RSS630240KiB。[独立Wi/Down fixture](attempts/t2_widown_av_fixtures_01/guard/driver.log)使用完整K/N的四行，Wi671744、Down335872 group records；exit0/1.981s。这是旧v4 producer与新参考输入准备证据；其后Wi/Down新TM4四行完整矩阵RTL已在下方各自冻结身份通过。
- [真实ACT TM4](attempts/t2_tm4_real_act_lut_01/guard/guard_result.json)：LUT候选，一行K256/N2，全部8stripes/16有效group records，独立dot/dotf/scale-product/term/每group PS、trace/tag/debt通过；guard exit0/58.759s/RSS2361412KiB。7次commit→下一同tile issue间隔均3拍（sum21），总issue等待252；PS物理存储映射未测。
- [真实QKV四行完整TM4](attempts/t2_tm4_real_qkv_lut_full_01/work/sim/simulate.log)：LUT候选，K1024/N3072，全部12288stripes/393216group records，全部整数/FP/PS中间值、trace/tag及Q35/D4债务通过。[guard](attempts/t2_tm4_real_qkv_lut_full_01/guard/guard_result.json) exit0/408.346s/RSS911996KiB，无保护触发。复用已编译snapshot，仿真run段403s；前置pilot_01在120s成本帽到2048stripes正常停止，保留成本中止而非功能FAIL。本结果不是动态quant、生产供数或完整RUN通过。

- [真实Wi四行完整TM4](attempts/t2_tm4_real_wi_lut_full_01/work/sim/simulate.log)：LUT候选，K1024/N5248，全部20992stripes/671744group records，高tile511/512/655及全部独立中间值/PS、tag/trace/守恒通过，stalls0。[guard](attempts/t2_tm4_real_wi_lut_full_01/guard/guard_result.json) exit0/668.561s/RSS920676KiB，无保护触发，复用未改变编译snapshot。没有bias/生产writer输出。

- [真实Down四行完整TM4](attempts/t2_tm4_real_down_lut_full_01/work/sim/simulate.log)：LUT候选，K2624/N1024，全部10496stripes/335872group records，包括group63/64/81、全部独立中间值/PS、tag/trace/守恒，stalls0；[guard](attempts/t2_tm4_real_down_lut_full_01/guard/guard_result.json) exit0/320.065s/RSS910176KiB、无触发。Wi/Down两pilot各120s成本停止至3584stripes，仅成本样本，正式full两次均完整通过。它与前三shape构成本次完整维度四形状的限定范围，尚无全部122矩阵/FPGA动态量化/生产HBM供数/bias/writer、DSP实际推断或物理时序通过。历史33个FP边界不符仍保留。

## T2 A+B组合的实际证据

- [组合整数短例与真实group重放](attempts/t2_integer_combined_01/work/xsim_short.log)：guard exit0、19.018s、RSS859844KiB；924接受=919返回+5 reset清除，29408 lane/1040 pair通过。[真实group重放01](attempts/t2_integer_combined_01/work/xsim_real.log)原日志打印136 issues/4352 lane，但Astra核验发现runner错传仅8条ACT fixture、TB未拒绝后128条未知输入且硬打印QKV128，故此分支记**FAIL_COVERAGE**，QKV覆盖不成立；不能以进程exit0判PASS，随后[真实重放02](attempts/t2_integer_combined_real_02/work/xsim.log)使用完整ACT8＋QKV128真实fixture，runner核四hex/136条位宽mask，TB对输入/gold未知位主动fatal并动态计数；guard0/10.225s/RSS859896KiB，实际136issues/4352lane通过。原01不追认。组合保持六级整数树与数值/接口合同，没有实际DSP推断或资源fit结论。
- [组合真实ACT R0](attempts/t2_r0_pack_lut_act_01/work/vivado/tm1tn8_arithmetic_real.sim/sim_1/behav/xsim/simulate.log)：guard exit0、44.050s、RSS1990900KiB；真实一行K256/N2、8组独立dot/FP/PS通过，issues8、累计等待252。仅组合算术局部，不追认四shape单A为组合长矩阵通过。

## T3 Q8S2 v2 r2实际出口

- [真实包CPU生命周期](attempts/t3_q8s2_package_r2_01/lifecycle/report.json)：两次122矩阵/11542592half全扫、五BO上传读回、暖复用与generation失效重建通过。CPU内存ACTIVE与设备REGISTER分开，XRT/HBM未测。
- [STRICT05](attempts/t3_q8s2_act_rtl_strict_05/guard/driver.log) guard0/149.89s/2681288KiB；[FAST trace-on02](attempts/t3_q8s2_act_rtl_fast_trace_02/guard/driver.log) guard0/148.60s/2564852KiB。[descriptor对照](attempts/t3_q8s2_act_r2_02/descriptor_comparison.json)仅word64 profile不同；每模式REGISTER→两LOAD/RUN→REVOKE，各RUN独立核2048B缓存q、64scale、2bias、8组quant/dot/term/PS及物理output/trace，18拍实际BO绑定和首次done零债务通过。每模式14拒绝例包含实际wrapper base/cookie变化、旧generation/context、reset与撤销。
- 同配置LOAD：STRICT4447/4449cycles、FAST4111/4113，各少336cycles；每LOAD scale_checks64→0。RUN均5681cycles。此为带有限末R/B hold的真实ACT命令窗口，不是全图/板端性能；fast_01 trace-off曾RUN4461，保留功能证据，撤回其与STRICT的性能对照。
- HLS生成通过但估计21.308ns（约46.93MHz），150MHz目标未满足。strict_01路径错误、strict_03/04错误binding_match TB期望的失败保留，不改独立gold。上述实际出口已获Astra限定验收；14拒绝例当时未检查的完整状态/恢复不追认；[增量STRICT02](attempts/t3_q8s2_act_rtl_contract_strict_02/guard/driver.log) guard0/225.362s/2761320KiB、[增量FAST01](attempts/t3_q8s2_act_rtl_contract_fast_trace_01/guard/driver.log) guard0/206.097s/2741504KiB，分别23/21拒绝通过：每profile8次descriptor-only合法重试、实际绑定失效、坏AUX header和高水位恢复、坏bias及activation失败后恢复；STRICT另核padding scale首错bad_element16/checks17。模型LOAD失败保留last_task/Wmax/high-water但清liveW并撤会话；activation错误只消费quant/A8任务并保持W，随后合法RUN独立数值通过。每命令18beat/首次done债务均核，已获Astra增量限定验收。真实base/cookie变化当时在尚未LOAD的ACTIVE会话注入，不证明已READY的W被撤销；reset后也只证明旧LOAD拒绝，gen2 device完整重建当时未测。[专用闭合STRICT04](attempts/t3_q8s2_act_rtl_closure_strict_04/guard/driver.log) guard0/146.864s/2654276KiB、[FAST trace-on01](attempts/t3_q8s2_act_rtl_closure_fast_trace_01/guard/driver.log) guard0/67.885s/860344KiB，各实测9拒绝、2次READY W实际base/cookie改变后撤销及旧RUN/LOAD拒绝、3次generation2完整REGISTER/LOAD/RUN独立数值/trace64重建；FAST复用同编译snapshot并逐SHA核TB/输入。此闭合增量已获Astra集中限定验收；FAST运行后仅可变输出xsimkernel.log变化，357个不可变编译snapshot与STRICT相同，不宣称全部清单运行后零变化；native XSim字符串三元调用崩溃及STRICT误用trace-off的旧TOOL/TB失败保留，均未改DUT或gold。增量strict01的reset后sentinel TB快照失败保留。[r2 Host短测](attempts/t3_q8s2_package_r2_01/host_encoder_short_r2_receipt.json)仅真实header＋合成generation2字段序列化/短BO拒绝通过，不证明真实reset后记录自动桥接；生产13BO集成、全部122矩阵device快LOAD、多请求与50ms/20请求/s未验证。

## T4 当前验证边界

[quant16预检06](../../vivado/module_design/activation_quantizer/rtl/quant16_preflight_06/run.log)与[冻结真实fixture主机预检](../../vivado/module_design/activation_quantizer/rtl/quant16_hls_preflight_01/host_identity.json)仅证明CPU功能和调度模型。[真实Vitis CSim01](attempts/quant16_hls_csim_01/guard/driver.log)guard0/11.091s/RSS1251344KiB，核K1024/2624各一行q/half和标量中间值、坏mask及source coverage拒绝。它仍是软件C仿真；实际HLS divider接受/返回、数值FP流水及完整producer连接未验证。

[功能RTL cosim02](attempts/quant16_hls_cosim_02/guard/driver.log)guard0/174.890s/RSS5923996KiB，真实Wi/Down各一行与两个拒绝事务均完成，独立q/half/d_full/reciprocal逐位核对通过；四事务共71571cycles，报告最大事务50177cycles。仅当前串行功能top，生成映射未实现16lane/16bank，不能外推吞吐。cosim01在RTL运行前因TB只分配active beats、HLS wrapper按声明4096深度复制而失败；修复完整分配不改变gold。随后按合同§7.3.1继续实际bank/token/16lane服务整改，不再重复串行top回归。

[16路流式real02](attempts/quant16_stream_real_02/guard/driver.log)已实际实现两扫16bank、32slot、真实单divider及16FMUL服务，真实Wi32/Down82组分别141/341cycles，全3648B q及114个half/d_full/recip独立逐位通过；两组零/round边界和坏第二half mask通过。随后的tiny 1e-38数值例FAIL，DUT错误产生d_full=0并READY，而合同要求非零次正规d_full再在reciprocal阶段拒绝；guard1/41.117s/1889940KiB，无保护触发。此attempt不能整体验收PASS，也不能继承单divider短例为次正规数全域通过。[real03](attempts/quant16_stream_real_03/work/vivado/quant16_stream_real.sim/sim_1/behav/xsim/simulate.log)重新执行真实两行、零/round及坏mask，并补齐4个数值错误短例和divider/mul各一次在途reset后合法恢复；这些局部通过，但末尾tiny仍同因FAIL，guard1/40.062s/RSS1904936KiB，无资源触发。两真实行及4数值/2reset的局部范围已获Astra限定验收；独立有理数确认tiny期望d_full=0000db7f、reciprocal=Inf，失败保留。Astra已在[合同§7.3.2](source/design.md)发布既有精确位适配的单一有界集成，不改变gold或增FP单元；[精确适配实际RTL01](attempts/quant16_stream_adapter_01/receipt.json)已ASTRA_ACCEPTED_SCOPED：guard0/42.981s/RSS1903516KiB，257项输入运行后0 stale。Wi/Down全q/half/d_full/recip仍为141/341clocks，SCALE接受gap1..4、slot峰24/32、环峰7/7；SCALE/RECIP32/32及82/82，实际FP64/64及164/164，真实两行无dummy/helper。27独立边界17成功/10拒绝，原tiny正确d0000db7f→Inf失败零输出；mixed6组48clocks，SCALE6/RECIP5/FP11、dummy4/helper4、slot峰6/环峰5。helper/归一化RECIP/FMUL旁路各一次真实在途reset及恢复，活动FP product和所有route q/status、首次done零债务均通过。物理资源/150MHz、完整NumericIdentity、双A lease与LN/GEGLU→quant→TM4生产连接仍未测，不能称整个量化模块已全接口验收。

[三口reader短02](attempts/t4_reader_short_02/receipt.json)guard0/31.189s/RSS860048KiB，无保护触发。真实Wi boundary/tail、Down group64 boundary/tail四窗口，各三口8192B、两笔4KiB burst逐byte、epoch、末拍及债务核对通过，每例782cycles；scale RRESP故障例481cycles，目标口仅一burst并传播load_error。01测试台误用SV关键字config的编译失败保留。此范围没有AUX/bias、双W、READY/lease、实际物理RAM或时序，不能称完整LOAD或W预取通过；后续双W增量已在下方按自身身份接受，生产MAC连接仍未验证。

[量化单divider真实RTL01](attempts/quant16_divider_real_01/receipt.json)guard0/33.06s/峰值1.69GiB，无保护触发；真实Wi32＋Down82组的SCALE/RECIP各114项逐位一致，前32个SCALE每拍接受（局部II1），峰值6在途。reset中断旧3笔隔离12拍，仅新1笔合法返回。此为一条真实divider的数值、token及reset服务证据，不是16bank/16M/完整A发布或1group4clk已通过；完整流式服务实现仍进行中。

## T3 新入口准备的实际证据

[实际v2包01](attempts/t3_q8s2_package_01/validation_record.json)来自20项实际硬件源/工具配置以及完整31项build preimage；buildSHA为`fb3b5d2b05b5eb517f07b4ea177e25de5cd43331f59723e160d972c49a37a60f`，包manifest SHA为`e2df3e78dcb951a76c973137c292a847b51f24f58df9a2901fcaeb8a52c308ba`。独立153tensor/122Q8矩阵/11542592half验证通过，生成header含完整32B SHA；四个非AUX BO及AUX数值payload同v4。此包扫描不是内存端点ACTIVE或设备REGISTER，实际新包完整上传/读回生命周期尚待执行。Host encoder独立C++字段/18beat/范围拒绝短例及actual header编译比较通过；XRT/PCIe/HBM未验证。计算owner的三处后续修正仅在TB期望，不影响冻结20项硬件preimage；正式ACT strict/fast入口测试仍推进，旧v4CPU验收不自动升级。

[修后actual-r2完整CPU生命周期](attempts/t3_q8s2_package_r2_01/lifecycle/report.json)的包位于`build/model-q8-session-v2-actual-r2-20261010`；buildSHA `7209eb09c3f265363cfb274f7790a73336e1570f5081bc9bbb2538c1ba5a50d5`，manifestSHA `46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c`。新20项硬件源清单SHA `7b6ee83bf117f8a8dc99270134c211e7e4dcfc64ca3c56340f0dd25a2926978f`在包/实际HLS cfg逐字相同，preimage仍31源。两次153tensor/122Q8/11542592half完整校验、5BO全量上传读回、ACT K256/N2授权、暖复用/reset旧代际拒绝及重建通过，guard0/29.13s/RSS1.33GiB。第一record SHA `c16c428402d54b3ee4975baf4edf7c005b19022b0f57d8f679e8e2b43f84e012`，reportSHA `1f073292e2d9c4e21149657b10d11393b3aa79682d390db06f0936217814d480`。这是CPU内存端点范围，设备REGISTER仍NOT_RUN、XRT/HBM未测；新源只等价移除HLS不支持的指针数组。旧fb3b包/首次HLS源码限制失败及旧包诊断HLS04主动终止（非资源/功能结论）保留原身份。

## T4 双W完整供数/lease实际出口

- [最终收据](attempts/t4_dual_w_full_05/receipt.json)：pilot07 guard0/17.192s/860164KiB，full05逐SHA核snapshot后复用编译，guard0/6.818s/852652KiB。真实payload来自冻结r2包。Wi READY打印坐标54128、Down READY坐标81200均为TB复位后的累计计数，包含此前setup/拒绝等工作；没有单独观测LOAD接受→完成服务周期，不能拿这些坐标作精确LOAD延迟。
- Wi全10496个双TN8返回逐位核q/scale/bias，Down在Wi读取期间装载，overlap=10496；Down全5248返回、Scorer全2048返回（含4096B AUX bias/4KiB拆分）及reset后ACT8组返回通过。被动checker只证明缓存供数和身份/lease，不证明真实Q8计算或512B/clk持续生产吞吐。
- ACT q0 RRESP与Scorer首bias +Inf错误仅目标槽INVALID，已有Wi lease保留；错误LOAD/read/release epoch、错误model identity lease、IN_USE覆写拒绝、在途ACT整域reset后epoch1重建通过。ACT padding bias返回0的RTL修复已受影响回归。
- 整例reset前最后计数110908；内域reset后最终marker为63cycles，不能把63当整例成本/推理性能。`loads=6`只计do_load完成次数，另有在途ACT被reset取消，不算完成。所有本树重工具已结束；此范围已获Astra最终集中限定验收。启动前5源及21个snapshot文件SHA匹配，运行后xsimkernel.log与xsim_script.tcl是可变产物；19个不可变snapshot与pilot编译一致，脚本仅移除PILOT参数，不以可变运行产物冒称零stale。物理RAM/时序/板端HBM、快速profile注册桥和完整producer/MAC仍未验证。

## T5 AV和vector的实际证据

- [C3正式RTL](attempts/t2_av_feedback_c3_full_01/work/vivado/av_feedback_real.sim/sim_1/behav/xsim/simulate.log)：guard exit0、66.437s、RSS1937292KiB；4096个真实prob×V贡献及有序partial逐项通过。4064次同址反馈样本均13拍（sum52832）；三批完整初始化/发射/排空总5089cycles，stalls793，product/commit峰值32/12。真实IP短例另通过16地址256连续接受II1、commit credit反压、错epoch/row/key拒绝及乘/加在途reset恢复。
- [C4正式RTL](attempts/t2_av_feedback_c4_full_01/work/sim/simulate.log)：guard exit0、6.957s、RSS857508KiB，复用同一未变snapshot；4096贡献全部通过，4064次同址间隔16拍（轮转间隔），stalls0、总4176cycles、product/commit峰值7/13。两批read跨度均2048拍，证明这个单bank投影的批内每拍一次接受。
- 真实V来自当前v4/request3 producer，prob来自独立QK/Softmax oracle；范围为query0,4,…124与feature0，不是FPGA实际QK→Softmax→AV producer链。F=13否定C3满批无反馈泡估计，C3功能仍PASS。pilot01/02的TB保留字编译FAIL保留，修复后的pilot03及正式结果按新身份记录。F256资源、部分和物理bank、全Attention及完整请求吞吐未验证。
- [原tanh闭包](../../vivado/module_design/vector_and_ffn/rtl/tanh_service_01/source_manifest.json)全路径最短接受间隔≥3是所选历史叶子的结构下界；随后真实数值基线已在ordinal23首错停止，尚无全2624项通过；不扩展成当前v4新kernel或所有vector方案失败。历史合同按50ms预算淘汰四实例/shared-vector配置；2026-10-11新目标下仅保留该参考缺口，不再直接淘汰；数值基线FAIL后停止保持旧叶子位结果的流水化，不生成已知不合格的宽池。

- [真实tanh首错](attempts/tanh_service_real_01/guard/driver.log)：guard exit1、5.888s、RSS859476KiB，无保护触发。独立参考来自真实v4/request3 enc0 Wi row0的2624个z，RTL在ordinal23报告`z=bf6cd458 got=bf3a7268 gold=bf3a726a`（2ULP）。这是真实基线的NUMERIC_FAIL，不是服务器成本中止；仅前23项比较成功，不能宣称全2624项通过。Astra集中核输入/返回与全部独立gold确认真实数值差异，无可归因的采样错误；冻结libm的tanhf使用不同的expm1f/F32运算图，移植它超出保持旧leaf原图的两轮优化范围，记NUMERIC_ARCHITECTURE_BLOCKED。依§8.4.5停止对旧叶子做保持位结果的流水化；不改gold/容差。旧选定配置REJECTED_BUDGET仅保留为原50ms合同下的历史结论；新目标下77.37ms本身不阻止实现或验证，真实数值FAIL仍是功能阻塞，不能扩大为所有非线性架构失败。

## 执行组织

当前长任务：GPT-6.1 Sol/xhigh负责按mission连续实现、编译、仿真、修复及受影响模块综合；GPT-6 Astra/xhigh仅在实际综合结果之后集中评判并改进后续方案。用户已取消逐轮人工审核，技术评判后直接推进完整生产连接与验证。文件保持唯一owner。全树最多一个重工具；CPU0–3、nice19、idle I/O、MemAvailable严格高于192GiB，按mission硬帽运行，仅管理本任务进程。

新阶段源码、模型、输入、gold及工具身份由实际attempt自动记录；准备、编译、功能通过、服务改善、条件资源与物理验证分别登记。尚无U55C，真实XRT/HBM/PCIe/Fmax与板端性能未验证。
