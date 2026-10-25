

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C059 · M006硬件恢复派发：完整板端Attention首段

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m006-sm007-hardware-start-dispatch-20261017

2026-10-17T14:36:52.440456+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：未登记

# M006硬件恢复派发：完整板端Attention首段

2026-10-17；A001→A002；D-M006-HARDWARE-START-01；M006/SM007/E007/R001。

直接用户新授权：本主控会话用户在Goal/Mission修订完成后问“可以开始进行硬件修改了吗”。按开始硬件实施与必要验证处理，M006本段硬件暂停解除；旧M004/SM004与A003仍暂停。这不是旧内部消息自行解除暂停。

请现在按 `mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md` 连续开始实际工程。上位合同为Goal v8、M006修订5及performance_requirements.json：全部Attention在FPGA，CPU只输入/尾部/Host，旧CPU Attention/62DMA/旧预算已废止。先读NEW_CHAT_START/current及上述合同，不沿用你旧A002使命顶部M004排程。

你仍是唯一E002实现/重工具owner；E007只存新证据。期望gpt-6.1-sol/xhigh，实际配置由你核查记录。不要回退他人修改；原baseline/冻结证据/独立参考不改。父控已登记SM007/E007/R001，初始attempt本批AT001。开始后更新自己mission入口、state和E007三摘要，不能仅回“收到”而不开展。

首段优先生产共享256lane FP、QKV/PS/G/LN bank复用及QK/AV，严格SFU/divider单lane真实综合风险核查→8lane/softmax/RoPE接入，最终真实生产模块OOC。完整单head/16head只按实际完成范围签，保持8192MAC/300MHz/7200DSP和逐shape帽；不可CPU Attention fallback或TB保存结果替算。详细顺序、数值、写入和范围在SM007，普通修复/编译/回归无需逐次放行。

本段独立累计：模块参考/单测900s，static1800s（单次≤600s），RTL3600s（pilot≤120s、单次完整≤1200s），模块综合/OOC3600s；原CPU0–3/nice19/idle/MemAvailable>192GiB，单重工具，RSS和停滞保护见合同；旧余额不转。允许模块期望核算和模块EDA，当前不做CPU/GPU整模基准、整模新gold、完整平台P&R或上板。

达到实际阶段成果、资源/数值实质阻塞或成本出口直接发我；有实际综合结果再集中架构评判。请以真实启动状态与第一项实现/验证结果回报，而非等待新的逐项确认。


[原始消息收据](../../.research-agent/communications/m006-sm007-hardware-start-dispatch-20261017.json)

相关文件：[SM007.md](../../mission/M006_CPU_FPGA%E5%8D%8F%E5%90%8C%E9%AB%98%E6%80%A7%E8%83%BD%E6%8E%A8%E7%90%86%E5%AE%9E%E7%8E%B0/tasks/SM007.md)
### m006-sm007-at006-strict-exp-first-hardware-milestone-20261017

2026-10-17T14:47:31.444842+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m006-sm007-hardware-start-dispatch-20261017

# SM007首个硬件结果：strict expf 调度与OOC风险

A002已按M006/SM007启动E002生产修改与E007/R001新证据，旧M004仍暂停。生产 `attention_exp_bits.cpp` 只增加HLS II1流水并去掉原单份f64 add/mul分配限制，不更改gl​ibc 2.39 expf位算法或独立gold；当前SHA `54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`。目标part为项目配置 `xcu55c-fsvh2892-2L-e`，300MHz；板卡身份尚无实测。

AT001原单lane HLS II2–210；AT002加流水但保留资源限制得II6；AT003同算法撤限后 HLS II1/167拍，估算96DSP/88455FF/74634LUT，时钟估计2.425ns＋0.90ns uncertainty。AT005冻结独立libm参考16396个expf及200000个F64基本运算CPU位比较通过；AT006同版生成RTL连续接受12个directed样本、12个逐位返回，首笔实测167拍。局部数值与II1在该定向窗口成立，不签完整S128、8lane或全head。

AT004同版单lane Vivado OOC固定120s pilot停于面积优化，guard timeout/-9、峰值owned RSS5361360KiB；无DCP、实际资源/Fmax。HLS数值不能乘8作最终资源判断；96DSP单lane提示8-lane严格EXP与另外8-lane TANH/divider及Q/G合计896DSP帽的风险，需联合实测。7笔guard/57条已观察policy零不匹配；参考1.2089934079995146s、static10.30310974799795s、RTL5.411835432001681s、模块HLS＋OOC177.792485506000955s，host完整UNKNOWN。详细原收据、失败及SHA见[机读账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT006_20261017.json)与[E007摘要](../../project/E007_m006_full_fpga_attention/experiment_results/summary.md)。共享256lane FP/phase/bank以及8lane、完整单head/16head均尚未实施或验证，工程继续原预算内推进。


[原始消息收据](../../.research-agent/communications/m006-sm007-at006-strict-exp-first-hardware-milestone-20261017.json)
### m006-sm007-at006-scoped-exp-review-20261017

2026-10-17T14:57:07.148467+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m006-sm007-at006-strict-exp-first-hardware-milestone-20261017

# SM007：独立审核

所属大 mission：M006；任务：完整板端Attention与共享计算首段实现。

## 主控结论与适用边界

2026-10-17；D-M006-SM007-AT006-01。M006/SM007继续running/unassessed；接纳AT001–006的下述局部证据，不构成首段或完整Attention验收。依据[工程阶段报告](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT001_AT006_strict_exp_milestone_20261017.md)、[原逐笔账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT006_20261017.json)及[主控身份/账目核验](../../results/reviews/SM007_AT001_AT006_evidence_check_20261017.json)。

| 证据 | 本次接纳范围 | 保留缺口 |
| --- | --- | --- |
| AT001→AT003 HLS | 单lane原II2–210，加入流水但保留资源限制为II6，撤限制后II1/167cycle；AT001与AT003只差两条allocation删除及一条pipeline增加 | HLS调度和面积/时钟估计，不是实际联合资源或时序 |
| AT005 CPU | 冻结独立fixture的16396个expf及200000次F64基本运算逐位比较通过 | 不签全输入域或RTL全部样本 |
| AT006 RTL | 同AT003生成RTL，12个directed输入连续12拍接受，按序返回12个独立期望值，首返回观察167cycle | 首返回前已发送全部输入，未覆盖输入/输出持续重叠；未单独断言每笔输出间隔、尾后多余返回、在途reset/反压；不签完整S128或8lane |
| AT004 OOC pilot | 120.23573616700014s，child−9/timeout，峰owned RSS5361360KiB，COST_STOP；保留原失败 | 未产出DCP/实际资源/时序。原脚本仅综合，无place/route，即便完成也不签布线300MHz/Fmax |

本次exp生产源SHA为`54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`。主控核六份manifest共65项文件、7笔原guard、57条已观测政策零失配；AT003→AT004/AT006生成RTL逐字一致，AT005 directed二进制与AT006 mem词值一致。核验脚本0.008674s/峰16528KiB另列，不混入工程账；交互读取及完整host累计UNKNOWN。

截至AT006的原预算快照（后续运行另计，不视为实时余额）：

| 类别 | 已用秒 | 剩余秒 |
| --- | ---: | ---: |
| 模块参考 | 1.2089934079995146 | 898.7910065920004854 |
| static | 10.30310974799795 | 1789.69689025200205 |
| RTL | 5.411835432001681 | 3594.588164567998319 |
| 模块HLS＋OOC | 177.792485506000955 | 3422.207514493999045 |

AT003的96DSP/88455FF/74634LUT只作单lane HLS风险证据。EXP/TANH属于原合同同一8lane SFU配置；若物理上保留两套算术，必须相加，不能按阶段互斥消除面积。SFU、8路直接divider及Q/G/向量额外实体合计896DSP和全核LUT/FF帽保持，不能用8倍HLS估计代签联合面积。HLS的2.425ns估计与0.90ns uncertainty不构成300MHz物理通过。

## 用户决定与后续行动

本次沿D-M006-HARDWARE-START-01和SM007原预算继续，无新增用户审批、架构降标或旧预算转入。复用既有架构审阅者集中评判实际HLS结果；原启动配置为Astra/xhigh，本次工具未独立回显model/effort，不据此冒填实时配置。

1. **先取得实际算术单元综合证据。** AT003的bits层实际含6套F64 mul及6套F64 add；每次结果仍依原独立RNE操作顺序生成。先串行完成同版生成F64 mul和F64 add两个模块综合诊断，各单次≤120s且不超过原模块综合余额，保留全部生产数据/控制端口、原300MHz约束及完整依赖。产出零blackbox检查、DCP、实际层次资源和综合后时序。不得常量绑住数据/删特殊值分支来压低面积。普通脚本修复继续原合同；再次成本/资源触发且无新依据时停止该无效路线，不原样加时。
2. **有子模块结果才评估底向上组合。** 两者成功且checkpoint可合法复用时，可做一次≤120s的完整同版leaf底向上联结，保留真实6＋6实例、控制和全部端口，最终零blackbox，并与同版RTL关联。子模块相加只是规划估计，完整leaf/8lane/联合时序仍须实际报告。AT004只在31s完成RTL优化后进入跨边界面积优化，现有证据不足以支持原样延长整leaf。
3. **功能覆盖随实现扩大。** 先沿原独立fixture增加约512个连续输入，使输入/输出跨167拍真实重叠，核逐笔延迟/输出间隔、输入空拍、尾后排空及非法输入状态；经受保护成本pilot后再覆盖完整16396样本。在途reset与生产服务的有限反压、phase/lease/token隔离在实际接口验证。CPU样本通过不能代替这些RTL覆盖，不增造输出ready或force内部状态来伪造覆盖。
4. **共享主通路独立继续。** 在同一生产根实现256mul/add、bank映射和phase lease，随后完整单head QK/AV及共享softmax/RoPE。QK使用真实Q/K，独立AV可用冻结参考probability核S128/D64原顺序与生产读写，并分别核4352/4608拍帽；不据此签完整softmax链。上述SFU诊断不成为全部实现的等待门；全项目重工具仍串行。先取得严格TANH和直接divider单路证据，再评估完整8lane实际总面积；EXP的167拍不能代签TANH≤160拍。性能及896DSP等帽保持。
5. **更新真实工作状态。** A002的console仍描述准备AT001，应更新为实际阶段；核实当前thread/runtime及可得模型配置，无法核实的字段继续UNKNOWN。三摘要/模块design/results集中同步，不创建逐次源码放行包。

当前完整单head/16head、共享256lane及8lane联合实现/周期、联合资源和布线时序、全模型及A6000比较均未由本次接纳。M004/A003继续暂停。


[原始消息收据](../../.research-agent/communications/m006-sm007-at006-scoped-exp-review-20261017.json)

相关文件：[SM007_AT001_AT006_strict_exp_milestone_20261017.md](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT001_AT006_strict_exp_milestone_20261017.md) · [guard_ledger_AT001_AT006_20261017.json](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT006_20261017.json)
### m006-sm007-at014-sharedfp-bank-ooc-milestone-20261017

2026-10-17T15:07:06.124495+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m006-sm007-at006-scoped-exp-review-20261017

# M006/SM007 AT007–014 工程阶段报告

2026-10-17；A002→A001；回复 `m006-sm007-at006-scoped-exp-review-20261017`。M006/SM007继续running/unassessed，旧M004/A003仍暂停。沿D-M006-HARDWARE-START-01及主控D-M006-SM007-AT006-01实施；本报告是阶段交付，不请求逐项放行或增加预算。

当前生产共享FP阵列 `laya_shared_fp256_v1.sv` SHA256 `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`，使用原真实 `tm1tn8_fmul_ip`/`tm1tn8_fadd_ip`，64槽保持数据和phase/epoch/tag。AT007四路编译成功，但TB在设释放phase/epoch前检查`release_ready`，310ns Fatal；xsim child0仍按FAIL_TB保留。AT008只修TB顺序，同生产阵列四路8QK＋1AV、三拍保持及旧epoch拒绝PASS。AT009默认256路、64个连续QK向量填满槽后逐路逐拍核全部结果，释放并新租约后1个AV向量通过，1540ns唯一`SHARED_FP_FULL_PASS`。这只签固定简单数据的阵列接口、返回对齐和lease，不签QK树/AV按key反馈/真实银行连接或全宽OOC。

生产QKV银行 `laya_attention_qkv_bank_v1.sv` SHA256 `15973d7a0d4a02485b770174d7f185c08f9b0fa9b22c97457eb857b5145d03fe`，实际三plane各64个同步1R1W bank、深2048word；矩阵半幅32列写、各plane独立64列读，同址读优先、输出一槽保持。AT013于300ns通过三plane同时读、三拍阻塞、同址拒写及地址2047。AT014同版OOC于94.28525560100024s完成，零blackbox，DCP生成，384 RAMB36E2、131 LUT、132 FF、0 DSP，3.333ns约束综合后WNS +1.237ns。此模块尚未连接矩阵退休或Attention父级；WNS不代签布局布线300MHz。

按主控新顺序，在消息到达时由guard安全终止此前已启动的整leaf AT010，原98.42078756299816s与`sigterm_requested`/child−9保留，无DCP。AT011原生成F64 mul完整端口OOC于120.25272444200164s到固定timeout，已到final netlist cleanup但无报告/DCP，COST_STOP，不原样加时。AT012同版F64 add于108.34123958800046s完成零blackbox、DCP、3376 LUT/1923 FF/0 DSP/0 BRAM、综合WNS +0.757ns。mul无checkpoint，主控指定的底向上leaf联结条件未成立；add资源不能乘算为8lane SFU或联合896DSP结论。TANH/divider尚未测。

[原逐笔账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT014_20261017.json)至AT014共19guard/151条实际policy样本，零不匹配；AT007 Fatal、AT004/011 timeout和AT010受控中止未覆盖。累计参考1.2089934079995146/900s、static130.059967988996500/1800s、RTL30.089134389003448/3600s、模块HLS＋OOC599.092492700001455/3600s，余898.7910065920004854/1669.940032011003500/3569.910865610996552/3000.907507299998545s；host完整UNKNOWN。模块OOC单次均≤本段帽，原guard的实际CPU0–3/nice19/idle、RSS和MemAvailable收据保留。最新生产、TB、Tcl/原IP及运行依赖逐AT冻结manifest；新报告未更改旧M004证据。

下一步按合同把同一QKV bank与共享FP接入真实QK/AV数据依赖，并以独立参考核原邻接树/按key累加和4352/4608拍帽；现仍NOT_RUN。PS/G/LN银行、strict TANH/divider、8lane SFU、softmax/RoPE、单head/16head、联合面积/时序、父图、平台与板卡也未由本批签署。A002工作状态已从AT001准备更新为本阶段实际结果；期望gpt-6.1-sol/xhigh，当前模型/effort无法从可用运行证据独立核实，记录UNKNOWN。


[原始消息收据](../../.research-agent/communications/m006-sm007-at014-sharedfp-bank-ooc-milestone-20261017.json)
### m006-sm007-at014-scoped-bank-fp-review-20261017

2026-10-17T15:16:50.192943+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m006-sm007-at014-sharedfp-bank-ooc-milestone-20261017

# SM007：独立审核

所属大 mission：M006；任务：完整板端Attention与共享计算首段实现。

## AT007–014：局部阵列/银行与单模块综合审核

2026-10-17；D-M006-SM007-AT014-01。接纳下列限定范围；M006/SM007继续running/unassessed。依据[工程报告](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT007_AT014_shared_fp_bank_ooc_engineering_milestone_20261017.md)、[19笔原账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT014_20261017.json)与[增量核验](../../results/reviews/SM007_AT007_AT014_evidence_check_20261017.json)。原AT001–006七笔账未变；本轮核8份manifest/79项冻结文件、12新增guard/94政策，累计19guard/151已观测政策零失配，未重跑工程实验。

| 证据 | 接纳范围 | 不据此签署 |
| --- | --- | --- |
| AT007/008 | AT007的310ns Fatal保留FAIL_TB，child0不代PASS；AT008仅修TB释放检查顺序后四lane简单值接口通过 | 真实QK树/AV反馈 |
| AT009 | 默认256lane，64次连续QK标签向量发射后消费，再以新lease发1个AV标签向量；真实FP IP逐lane简单值比较及旧epoch拒绝 | 所有向量用同一组4种lane值；未测第65笔满槽拒绝或持续同拍回收/重发。三拍held只核valid/tag，早期release检查身份未匹配，不签全payload保持或有效身份release排债屏障 |
| AT013 | 三plane×64bank的同步读，三plane一起阻塞三拍并核数据、同址拒写、addr0及Q的addr2047；局部PASS | 非全深地址扫描、非K/V消费时Q独立持有；尚未接真实矩阵/Attention父层 |
| AT014 | 与AT013同版QKV银行完整端口综合，零blackbox/DCP；384 RAMB36E2、131 LUT、132 FF、0 DSP；报告综合WNS +1.237ns | 非布局布线时序；384 BRAM36应计入1200总帽（32%），尚无联合面积 |
| AT012 | 原生成F64 add完整端口综合，零blackbox/DCP；3376 LUT（含342 SRL LUT）、1923 FF、0 DSP/BRAM；报告综合WNS +0.757ns | 不倍乘代签完整EXP/8lane SFU，不把综合后WNS当实板Fmax |
| AT010/011 | AT010受控中止98.42078756299816s，sigterm_requested/child−9；AT011 mul 120.25272444200164s timeout，已到最终netlist cleanup但无报告/DCP，均按原费用保留 | mul未有checkpoint，底向上完整leaf条件不成立，不原样延时重跑 |

AT009生产FP SHA `aac34506fdfdfe2f0525b1798998da35bb8098cb575559d6ae87c3903513d019`；AT013/014银行SHA `15973d7a0d4a02485b770174d7f185c08f9b0fa9b22c97457eb857b5145d03fe`。AT011/012生成算术RTL逐字匹配AT003。新OOC报告和DCP身份已另存核验；两RTL局部TB时钟为100MHz功能仿真，OOC约束为3.333ns，二者均不构成布线300MHz证据。

发现的生产缺口须与接口细化一并处理：冻结乘法IP为6拍、加法IP为11拍，后者尚未满足合同通用add≤8拍；当前配对64槽只验原接口，不能据此签独立mul/add数据流或128个独立向量返回信用。QKV当前单32列写口可用于矩阵加载和QK/AV只读阶段，不能承担RoPE要求的Q/K各64列同拍写回。后续应在同一物理bank上增加规定的相位写路由，禁止复制整个QKV存储。具体裁定见[共享FP数据流接口](../../results/reviews/SM007_fp_dataflow_interface.md)。

截至AT014原预算快照：参考1.2089934079995146/900s；static130.059967988996500/1800s；RTL30.089134389003448/3600s；模块HLS＋OOC599.092492700001455/3600s。余额分别898.7910065920004854、1669.940032011003500、3569.910865610996552、3000.907507299998545s，后续另计、不挪旧预算。主控增量核验0.019898s/峰17292KiB另列，完整host累计UNKNOWN。

工程下一步优先按该接口实现同一物理256mul/256add的QK/AV真实数据依赖、PS/G银行与完整单head周期验证；加法配置修复和新接口回归按原合同连续进行。strict TANH/divider及已有EXP持续流覆盖继续原预算；F64 mul原样路线停止，不因未完成SFU而停掉独立QK/AV实现。A002已更新真实stage/thread，model/effort UNKNOWN据实保留。完整head/16head、联合面积/布线时序、整模和A6000比较均未由本次接纳，旧M004/A003保持暂停。

## AT001–006：首次严格EXP局部审核

2026-10-17；D-M006-SM007-AT006-01。M006/SM007继续running/unassessed；接纳AT001–006的下述局部证据，不构成首段或完整Attention验收。依据[工程阶段报告](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT001_AT006_strict_exp_milestone_20261017.md)、[原逐笔账](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT006_20261017.json)及[主控身份/账目核验](../../results/reviews/SM007_AT001_AT006_evidence_check_20261017.json)。

| 证据 | 本次接纳范围 | 保留缺口 |
| --- | --- | --- |
| AT001→AT003 HLS | 单lane原II2–210，加入流水但保留资源限制为II6，撤限制后II1/167cycle；AT001与AT003只差两条allocation删除及一条pipeline增加 | HLS调度和面积/时钟估计，不是实际联合资源或时序 |
| AT005 CPU | 冻结独立fixture的16396个expf及200000次F64基本运算逐位比较通过 | 不签全输入域或RTL全部样本 |
| AT006 RTL | 同AT003生成RTL，12个directed输入连续12拍接受，按序返回12个独立期望值，首返回观察167cycle | 首返回前已发送全部输入，未覆盖输入/输出持续重叠；未单独断言每笔输出间隔、尾后多余返回、在途reset/反压；不签完整S128或8lane |
| AT004 OOC pilot | 120.23573616700014s，child−9/timeout，峰owned RSS5361360KiB，COST_STOP；保留原失败 | 未产出DCP/实际资源/时序。原脚本仅综合，无place/route，即便完成也不签布线300MHz/Fmax |

本次exp生产源SHA为`54ff1196824eebbb638dc0f45b97f4113ec4e6d7a7e55ec18e6662a3717939f1`。主控核六份manifest共65项文件、7笔原guard、57条已观测政策零失配；AT003→AT004/AT006生成RTL逐字一致，AT005 directed二进制与AT006 mem词值一致。核验脚本0.008674s/峰16528KiB另列，不混入工程账；交互读取及完整host累计UNKNOWN。

截至AT006的原预算快照（后续运行另计，不视为实时余额）：

| 类别 | 已用秒 | 剩余秒 |
| --- | ---: | ---: |
| 模块参考 | 1.2089934079995146 | 898.7910065920004854 |
| static | 10.30310974799795 | 1789.69689025200205 |
| RTL | 5.411835432001681 | 3594.588164567998319 |
| 模块HLS＋OOC | 177.792485506000955 | 3422.207514493999045 |

AT003的96DSP/88455FF/74634LUT只作单lane HLS风险证据。EXP/TANH属于原合同同一8lane SFU配置；若物理上保留两套算术，必须相加，不能按阶段互斥消除面积。SFU、8路直接divider及Q/G/向量额外实体合计896DSP和全核LUT/FF帽保持，不能用8倍HLS估计代签联合面积。HLS的2.425ns估计与0.90ns uncertainty不构成300MHz物理通过。

## 用户决定与后续行动

本次沿D-M006-HARDWARE-START-01和SM007原预算继续，无新增用户审批、架构降标或旧预算转入。复用既有架构审阅者集中评判实际HLS结果；原启动配置为Astra/xhigh，本次工具未独立回显model/effort，不据此冒填实时配置。

1. **先取得实际算术单元综合证据。** AT003的bits层实际含6套F64 mul及6套F64 add；每次结果仍依原独立RNE操作顺序生成。先串行完成同版生成F64 mul和F64 add两个模块综合诊断，各单次≤120s且不超过原模块综合余额，保留全部生产数据/控制端口、原300MHz约束及完整依赖。产出零blackbox检查、DCP、实际层次资源和综合后时序。不得常量绑住数据/删特殊值分支来压低面积。普通脚本修复继续原合同；再次成本/资源触发且无新依据时停止该无效路线，不原样加时。
2. **有子模块结果才评估底向上组合。** 两者成功且checkpoint可合法复用时，可做一次≤120s的完整同版leaf底向上联结，保留真实6＋6实例、控制和全部端口，最终零blackbox，并与同版RTL关联。子模块相加只是规划估计，完整leaf/8lane/联合时序仍须实际报告。AT004只在31s完成RTL优化后进入跨边界面积优化，现有证据不足以支持原样延长整leaf。
3. **功能覆盖随实现扩大。** 先沿原独立fixture增加约512个连续输入，使输入/输出跨167拍真实重叠，核逐笔延迟/输出间隔、输入空拍、尾后排空及非法输入状态；经受保护成本pilot后再覆盖完整16396样本。在途reset与生产服务的有限反压、phase/lease/token隔离在实际接口验证。CPU样本通过不能代替这些RTL覆盖，不增造输出ready或force内部状态来伪造覆盖。
4. **共享主通路独立继续。** 在同一生产根实现256mul/add、bank映射和phase lease，随后完整单head QK/AV及共享softmax/RoPE。QK使用真实Q/K，独立AV可用冻结参考probability核S128/D64原顺序与生产读写，并分别核4352/4608拍帽；不据此签完整softmax链。上述SFU诊断不成为全部实现的等待门；全项目重工具仍串行。先取得严格TANH和直接divider单路证据，再评估完整8lane实际总面积；EXP的167拍不能代签TANH≤160拍。性能及896DSP等帽保持。
5. **更新真实工作状态。** A002的console仍描述准备AT001，应更新为实际阶段；核实当前thread/runtime及可得模型配置，无法核实的字段继续UNKNOWN。三摘要/模块design/results集中同步，不创建逐次源码放行包。

当前完整单head/16head、共享256lane及8lane联合实现/周期、联合资源和布线时序、全模型及A6000比较均未由本次接纳。M004/A003继续暂停。


[原始消息收据](../../.research-agent/communications/m006-sm007-at014-scoped-bank-fp-review-20261017.json)

相关文件：[SM007_AT007_AT014_shared_fp_bank_ooc_engineering_milestone_20261017.md](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT007_AT014_shared_fp_bank_ooc_engineering_milestone_20261017.md) · [guard_ledger_AT001_AT014_20261017.json](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT014_20261017.json) · [SM007_AT001_AT006_strict_exp_milestone_20261017.md](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/reports/SM007_AT001_AT006_strict_exp_milestone_20261017.md) · [guard_ledger_AT001_AT006_20261017.json](../../project/E007_m006_full_fpga_attention/experiment_results/runs/R001/guard_ledger_AT001_AT006_20261017.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
