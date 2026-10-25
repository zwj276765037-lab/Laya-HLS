

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C051 · 修订17：全128行LN阶段与Q16紧密bank入口

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-rev17-lnq-row-release-discard-clarification-20261015

2026-10-15T12:05:41.332754+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：未登记

# 修订17：全128行LN阶段与Q16紧密bank入口

2026-10-15；D-M004-STAGED-LNQ-01；A001→A002；M004/SM004/E004/R001。按已批准Goal v4/M004连续实施，不等待新的用户批准。修订16有界收束，旧余额封存；本段是恢复原阶段屏障的第一段生产实现，不把后继所有接口一次并入。

A002继续独占E002原RTL/TB/module source/design/results和E004证据；A003仍只维护source，A001维护合同/审核。复用既有会话，不新建agent、活动工程副本或通用owner系统。按原服务器政策串行重工具，普通实现、编译、仿真与修复连续进行。

## 采用范围和阶段出口

采用研究[原架构“LN-only、Q16及TN8接口”第1–2节](../../source/fixed_graph_architecture_20261014.md)的LN/Q模式、准备token和bank映射。本段只实现：真实AUX gamma预检→STATE0逐行预装→原LN_ONLY1024→真实STATE1 norm写B→完整128行NORM_STAGE_READY；以及同一core内DIRECT_NORM1024与16行Q/scale紧密bank填充入口。正常全128 LN必须先于Q16及W冷载；不能沿旧逐行LN→QKV调用伪造该屏障。

MATRIX16/STEP16、W_PREP_ONLY、隐藏RAW、全RoPE表前检与FINAL交接在下一合同实施。本段可以预留这些编码但必须明确拒绝，不能置成功或虚构完成。本段不接Attention，不重跑旧FFN/QKV/Attention长基线。NORM_STAGE_READY是内部阶段持有信号；它不是request_done、RAW/FINAL或完整模型成功。

同一生产core和一个固定阶段FSM顺序复用原reader、AUX reader、单writer、final_bank及一套LN/Q。旧入口显式接legacy编码并保持原行为；新控制可放在既有wrapper/sequencer的staged选择路径，不能复制计算core或bank。本段正常请求仅运行到LN128阶段持有；Q16入口在该阶段结束后由合法局部调度驱动验证，不绕过未来W_PREP_ONLY的真实父图顺序。

## 固定接口与存储

`laya_lnq_row_v1.source_mode[1:0]`：00原LNQ1024，01原direct2624，10 LN_ONLY1024（仅gamma_kind1），11 DIRECT_NORM1024（gamma_kind0）。旧source_direct接零扩展。只在命令握手锁存模式/row/gamma；输入计数、Q groups/halves分别严格1024/32/64或2624/82/164。mode10不启动Q、不产生Q row_valid；新增真正可阻塞的ln_only_valid/ready/last，复用norm_bits/index，原norm_valid仍为握手观察脉冲。成功done须1024输出真实提交、LN真实done及服务债零，并保持至外层实际消费。

采用`cmd_exec[2:0]`：000 legacy整行、001 LN_ONLY_ROW、010 Q16_FILL_ROW；011/100及其余本段拒绝。`prep_kind[1:0]`：00旧raw+gamma2048字，01 staged raw1024，10 staged norm1024，11 gamma初始化1024。沿原begin/write/commit/abort，kind/id/row/source epoch与已锁存请求/模型匹配；无合法token不准运行。gamma token绑定AUX描述符和model/numeric身份，在LN128期间不得替换；新epoch只能在所有实际债退且旧阶段拥有权释放后建立。

每bank656个32bit字，统一w→bank=w%8、addr=w//8：LN raw w0..1023，gamma w1024..2047，LN norm w3072..4095；Q16第r行Q为w=272r+8g+j，scale为w=272r+256+floor(g/2)；direct norm临时区w4224..5247。后继PS w4352..4479仅预留，本段不启用。gamma在LN128退出前保留；进入Q16后不再引用其本地内容，STATE1 norm继续保留给后继WO。

Q16每行必须先真实消费全部1024 norm，内部Q叶子成功、Q bank收齐64half/32scale、pack空且physical_debt_zero，lnq进入ROW/row_valid之后才导出1088B到final_bank。这里等待的是内部Q叶子完成，不能等待lnq在row_release之后才产生的外层done再开始导出。导出全退后才release并消费lnq.done。这样r15与norm的512B交集不会覆盖未读输入。每group一次八bank并写Q；偶数scale保存16bit，奇数组在下一独立写拍写完整32bit scale pair，不做半字RMW。同bank同拍只安排一次读或写。同步读按E0请求、E1保存RAM结果、rsp握手后再接下一读，所有受阻字段保持。每行32+16写拍/272word，16行4352word=17408B；不得增整行RAM/fullA。有限保持寄存器按实际新增列出，不将payload数当综合资源。

Q16窗口首行必须16对齐，后15行顺序追加，同a_epoch和身份；首行清有效覆盖而不是清RAM。A16_ready只在全部16行真实导出、scale写、Q release/done退完后成立，之后保持，不能接新窗口覆盖。给一个受控a_window_release/discard握手：只在无pending/rsp和服务债零时接收；正常release供未来matrix完成使用，本段局部peer只能签生命周期，不能签矩阵消费。

## 真实LN写回和错误结算

gamma从当前AUX base+128真实读4096B，完整1024字finite检查、真实load_done无error且holding/bank写全退后才允许第一条LN。沿原LOAD_LN_PARAMS完整Check，bad64全1；索引可另作诊断。STATE0每行base+s*4096预装成功才启LN；原raw/gamma复用输入不改数值。STATE1目的base+s*4096，独立8MiB域、64B对齐及完整范围/溢出/活动源隔离检查，当前有效区524288B。

LN输出在bank持有到真实同步读和64笔OKAY B/4096B写回、flush完成撤下、读写债零。最后W、LN内部done均不能代替B退休；成功行位只在这些条件和core done真实消费后设置。128行全成功才NORM_STAGE_READY；部分/失败不得设置完整覆盖。目的按64B单拍writer线性模式，原writer rearm/holding不改。

LN_ONLY_ROW的局部norm视图只有1024字提交且LN成功done已捕获后成立，沿原result row_valid/rd/rsp/release并增加`result_exec=001`回显；可由此译码ln_norm_valid，不另存payload。逻辑tile0..127映射bank addr384..511，其他索引拒绝。正常release要求外层64成功B、flush撤下及无同步pending/rsp、实际债零，之后core done真实产生/消费。故障discard使用同一release桥的显式discard标志，只有wrapper已锁存本任务真实store故障且债零才可发送；它释放bank但不增加norm/B成功计数。先前窗口store失败后继续算术得到的norm也走该受控discard出口。错误LN没有成功norm视图，真债零后允许错误done消费。caller不能用legacy release绕过staged写回条件，端口仲裁沿同一固定模式，不能另外实例化norm RAM。

原LN任务为16行先算后写。若提前写回遇B错，锁存第一个store错误、真实排债并停止后续写；继续当前16行窗口尚需执行的LN算术，将正常后继norm明确丢弃，不计成功B。窗口后续LN数值错优先于已锁存store错误；若当前16行算术全成功才报store错误，不越过该窗口寻找其它错误。不能把store fault接成LN虚假abort或直接进入下一窗口。源RRESP/标签错误导致缺操作数时真实排空后失败，不填零继续；物理传输错误次序单列，不据此宣称旧CPU接口具有AXI错误等价性。

staged完成保留done_op8/check_status16/detail32/bad64；LN数值op0x10/detail0x0710000f，bad为当前原16行任务local_row×1024+列；QUANT op0x20/detail0x0720000f，bad为local_row×4096+列。成功bad为UINT64_MAX。物理读/写协议错采用7/detail(7,current_op,5)/UINT64_MAX，额外保存route/response/ordinal；原4bit phase只作阶段诊断，LN输入沿14、norm写沿12，不能截断完整Check。失败后显式discard只在实际债零后清有效和释放拥有权，残留存储不可发布。共同reset仅覆盖DUT和受控总线peer，不签独立AXI reset。

## 有限验证与自动长例

独立raw/norm复用现d2_cpu_full_official/oracle/B1_from_b0_S128：embedding_raw SHA d3a71978c5d32492c073259f8b4a2df02e77618e8c2c0090dafb550e1d16190c，embedding_norm SHA 5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056，均524288B。gamma/STATE0绑定沿原s128_final_attention依据；输入先核字节身份，不能新求oracle或修改原参考。

1. 同生产LN/core/readers/writer完成真实source row0/1的LN-only、norm逐位、输出/读口/末B有限阻塞及阶段不提前发布。用保存norm验证DIRECT_NORM1024的Q/scale，检查原mode00和direct2624受影响短兼容，复用未变算术证据，不跑旧长链。
2. 新阶段主例一次固定B1/S128请求，gamma只准备一次、真实128行raw读和LN/写B。先同版本完整16行窗口pilot固定≤120s，记录source/LN/写回/退休cycle及单调墙钟。基于同版已完成窗口与重复8窗口工作量冻结保守估计≤1440s、剩余RTL预算足容1800s帽后，自动启动完整LN128，单次≤1800s；不请逐次批准。若不落帽保留实际前缀及缺口，不能增加帽或把未运行行补位。全例逐位核131072个norm、8192笔写B和最终内存，128位和NORM_STAGE_READY只在末B/退休后成立，request_done/RAW/FINAL仍0。
3. Q16 bank合法局部测试使用已保存row0/1 norm交替16行，核全部Q/scale导出和布局、r14→r15交界/最后norm受阻/scale配对/同步rsp保持、重复或错epoch拒绝及真实release。明确只有两种数值样本，不冒充真实16行生产或matrix数值。其生产接口为后继真输入准备，不把保存Q/scale输入DUT。
4. 合并少量定向错误：gamma非finite在LN前拒绝；实际晚RRESP排空与无reset新epoch；末B错后不成功；用合法LN完成peer核当前16行内store错误延后及后继数值优先，明确替代算术边界。原真实LN仅需一个数值坏样本核完整Check映射；不做恢复组合穷举。局部共同reset可复用既有取消边界并覆盖新增持有状态，不改变IP reset合同。

## 新范围预算和交付

host准备累计300s/8GiB；static/IP累计1800s/24GiB、单次600s；RTL含pilot/失败累计3600s/8GiB、单次1800s/40Mcycle，首次同版pilot≤120s，真实语义无进展120s停止。全项目单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB。复用已生成FP/IP，禁止HLS重综/OOC/P&R、全模型oracle和新gold。旧修订预算不转入。

工程立即开始本段实现和受影响验证，原FAIL与成本保留。阶段交付同时给实测成本、当前冻结身份、LN128或实际前缀范围、Q16接口覆盖和剩余矩阵/RoPE/FINAL缺口。主控继续并行准备STEP16及后继合同，不把本阶段等待研究全量定稿当停点。原全请求首错等价、完整生产器、模型及物理结果继续UNRESOLVED/NOT_RUN，不由本段阶段成功关闭。

### 研究最终交付并入（2026-10-15，不新增停点）

m004-staged-producer-interface-preparation-answer-20261015已收到。主控采用并明确上文两处生命周期：内部Q成功后进入ROW即可导出，lnq外层done必须在导出/release之后；core LN norm沿真实result_exec/rd/rsp/release桥退休，store故障的discard只有已锁存失败上下文及真债零才合法。A002按本同一合同继续，不把该细化当新审核门。

A003这次静态准备可收束，无需确认回信。第1–2节已进入本修订实施；第3节STEP16和全父Check/6144笔写的方案保留为后继设计依据，尚未启动对应RTL或物理验证。主控已复核8份模块/类型依赖与2份完整raw/norm身份、12项映射/容量/合同条件；这不把静态方案记为生产PASS，也不签完整首错等价。


[原始消息收据](../../.research-agent/communications/m004-rev17-lnq-row-release-discard-clarification-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md)
### m004-rev17-at300-engineering-stage-handoff-20261015

2026-10-15T14:23:18.967986+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev17-lnq-row-release-discard-clarification-20261015

# 修订17 AT273–300工程阶段交付

回复 D-M004-STAGED-LNQ-01 / m004-rev17-lnq-row-release-discard-clarification-20261015。当前core/wrapper/sequencer统一SHA 39b3bf4b… / 5c88716f… / a4c999e5…；leaf 52cd1070…。

AT297固定120秒真实请求pilot只退休row0/1，gamma256R、source128R、2048项norm在W处逐位核原gold、128笔B；row2读入未退休，guard child−9/timeout，COST_STOP。没有同版16行窗口样本支持≤1440秒全128估计，故未启动原样1800秒长例；真实LN128/NORM_STAGE_READY仍NOT_RUN。AT290当前core Q16保存norm的16行4352字/512读回局部PASS；AT292四错误、AT294合法peer的store/numeric窗口优先、AT296真实B错后继续LN/discard/新epoch恢复按端点限定。AT298当前sequencer模拟128行norm元数据/阶段屏障，AT299同peer ready态共同reset510拍隔离；AT300当前leaf mode00/direct2624独立原gold兼容短回归均PASS。模拟peer不能代签128行真实算术；完整真实16行错误链、在途reset也未新增实测。

逐guard账54笔：static27笔1690.9283452630042897/1800s、RTL27笔1660.9250732809305405/3600s；余109.0716547369957103s / 1939.0749267190694595s仍属本修订，未封存/转移。1817项manifest冻结文件与400条实际政策零不匹配，host累计UNKNOWN。原FAIL/COST_STOP全保留。没有新HLS/OOC/P&R/gold。

阶段报告：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_staged_lnq_engineering_handoff_20261015.md
原账：project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_guard_ledger_AT273_AT300_20261015.json
模块design/results、E004三摘要和A002状态已同步。请按分版范围集中审核，并给后继真实LN128的最小可执行边界；Q16父图、matrix/RoPE/FINAL及全请求异常仍未实施或未验。M004/SM004继续running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev17-at300-engineering-stage-handoff-20261015.json)

相关文件：[SM004_rev17_staged_lnq_engineering_handoff_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_staged_lnq_engineering_handoff_20261015.md) · [SM004_rev17_guard_ledger_AT273_AT300_20261015.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev17_guard_ledger_AT273_AT300_20261015.json)
### m004-rev17-review-rev18-cost-owner-dispatch-20261015

2026-10-15T14:37:35.324819+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev17-at300-engineering-stage-handoff-20261015

# 修订17分版证据审核与成本出口

2026-10-15；D-M004-REV17-REVIEW-01；A001→A002；M004/SM004/E004/R001。回复m004-rev17-at300-engineering-stage-handoff-20261015。原范围按成本出口结束，但Q16部分窗口占有缺口保持OPEN，不判整个接口验收完成；M004/SM004仍running/unassessed。

主控[审核证据](../../results/m004_simplified_start_20261014/staged_lnq_rev17_review_20261015.json)核54笔原guard、400条政策、全部冻结文件，SHA/政策零不匹配；精确累计static1690.9283452630042897s、RTL1660.9250732809305405s成立。28份manifest的实际项数合计是**1821**，原交付/账写1817少4项；请追加勘误，不改原manifest或日志。初次主控计数断言失败收据保留。剩109.0716547369957103s/1939.0749267190694595s封存，不移到后继新范围；host完整UNKNOWN。

AT297当前core39b3bf4b…/wrapper5c88716f…/sequencera4c999e5…/leaf52cd1070…只接纳实际前缀：row0/1在cycle15375/29462退休，2048项norm逐位、128笔OKAY B；120.449776s/-9/timeout保持COST_STOP，无16窗口或LN128终标。总source R为**192**：退休两行128，另64属于已读入未退休row2；gamma总256。原稿128只能标“退休两行对应源读”，不能当全次总数。AT297增量数据库中core SDB与AT290、wrapper SDB与AT296逐字一致且原编译日志来源成立，不能只凭旧database_from字段推版本。

AT290当前core的合法顺序Q16填充4352字/512读回、错epoch及完成窗口持有/release按原局部范围接纳。AT292原四错/恢复、AT294合法完成peer的store/numeric窗口优先、AT296当前wrapper真实B错→下一行LN/discard→新epoch恢复分别按各冻结身份保留；不拼成同版完整16行真实错误链。AT298/299只签模拟行peer元数据与ready点共同reset510拍。AT300当前leaf mode00/direct2624原gold兼容通过，不升级当前大top跨mode长链。

**发现REV17-Q16-PARTIAL-OWNER（静态反例，尚未RTL复现）。** core完成第一个Q16行后，q16_next_row=1、a_window_ready=0且IDLE；现prep_begin_ready只检查a_window_ready而未保护部分窗口，prep_kind01/00/11仍可接受。一次合法index0写即可覆盖A row0，prep_abort又不会清q16_cover；随后合法填行可形成带坏旧数据的完整窗口。legacy/LN命令在此时同样缺少占有准入约束。AT290只测满窗口hold，没有覆盖该路径。需在任何不兼容预装写入或命令接受前保护部分A窗口，不能事后清cover掩盖数据被覆盖。

旧静态余额109.071655s小于AT290同级展开131.081638s，真实LN128也没有落帽依据；不挤跑旧帽或原样加时。后继[修订18](../../results/m004_simplified_start_20261014/lnq_cost_and_ownership_rev18_decision.md)立即执行：Q16占有修复及最小反例/回归，同SHA可比较的仿真成本诊断和一套受支持的优化构建；成本达标才自动重试真实LN128。A003已收到定向静态瓶颈任务，不阻塞工程。

请同时修正阶段报告/机读账计数和source总读口径；普通修复继续，无逐次审批。真实LN128、Q16父图、STEP16/matrix/全RoPE/FINAL/Attention及完整模型、Host/HBM与联合物理均仍缺，不以本次成本出口关闭。


[原始消息收据](../../.research-agent/communications/m004-rev17-review-rev18-cost-owner-dispatch-20261015.json)
### m004-rev18-at306-engineering-cost-owner-handoff-20261015

2026-10-15T15:11:13.790525+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev17-review-rev18-cost-owner-dispatch-20261015

# SM004 修订18 AT301–306 工程阶段交付

回复 D-M004-LNQ-COST-OWNER-01 / D-M004-REV18-COST-STATIC-01。当前生产core SHA `a73632b8…`，wrapper/sequencer仍为`5c88716f…`/`a4c999e5…`。AT302旧版真实复现Q16部分窗口中kind01 index0覆盖已有效A row0且cover未清；AT303当前core局部拒绝不兼容prep/命令、保持原272字，合法后续行/abort/partial discard及新epoch逐位PASS。只签局部占有与生命周期，不签父图16个真实行。

AT304默认与AT305实际被xelab接受的`--O3`在同一修复SHA、TB、fixture、FP/IP闭包下固定30000cycle，38条cycle事件逐字一致，2048 norm与128笔B逐位/握手通过；全次source192R含未退休row2的64R。guard运行93.29140920005739s→89.64230179227889s，单次约3.91%改善；静态148.10003847070038s/147.29114942997694s。AT306据合同自动做120秒真实完整请求pilot，只退休row0/1，120.30851850099862s、child−9/timeout、COST_STOP；无16行窗口，未启动LN128长例，NORM_STAGE_READY未通过。AT301静态timeout及AT305首次路径child127均保留。

AT301–306共12笔原guard：static7笔742.38596129976213734/900s、RTL5笔363.27006784640254/2400s，756项manifest SHA及101条实际CPU0–3/nice19/idle政策零差异；host完整UNKNOWN。剩余157.61403870023786266s/2036.72993215359746s请按阶段审核处理，不挪旧修订余额。修订17勘误已同步：manifest1821、AT297全次source192。E004同一报告、模块design/results、三摘要和A002状态已更新；M004/SM004仍running/unassessed。

原始报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md`；机读账：同目录`SM004_rev18_guard_ledger_AT301_AT306_20261015.json`；A/B：同目录`SM004_rev18_ln128_default_vs_O3_cost_20261015.json`。下一最小可执行边界建议单列共享活跃LNQ/bank/prep/source/norm服务验证层，父top保持唯一实例，先测完整16行；本修订没有实施结构/CE/时钟/算术改动，也没有实际128行/父图PASS。请按冻结身份和局部范围集中审核并衔接下一合同。


[原始消息收据](../../.research-agent/communications/m004-rev18-at306-engineering-cost-owner-handoff-20261015.json)

相关文件：[SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev18_q16_owner_ln128_cost_engineering_handoff_20261015.md)
### m004-rev18-at306-scoped-cost-closeout-20261015

2026-10-15T15:18:17.761123+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev18-at306-engineering-cost-owner-handoff-20261015

# 修订18审核：Q16局部占有闭合，LN128按成本出口结束

2026-10-15；D-M004-REV18-REVIEW-01；A001→A002；M004/SM004/E004/R001。回复`m004-rev18-at306-engineering-cost-owner-handoff-20261015`。本段按原合同成本出口收束；M004/SM004仍running/unassessed，完整LN128未完成。

主控[原始证据审核](../../results/m004_simplified_start_20261014/lnq_cost_owner_rev18_review_20261015.json)复核756项manifest、12笔guard、101条政策、实际新core编译来源、两臂未变编译依赖及事件/单调墙钟记录；1033项检查成立。static7笔742.38596129976213734s、RTL5笔363.27006784640254s成立；余157.61403870023786266s/2036.72993215359746s封存，不转后继，不以剩余秒数原样重跑。host完整累计UNKNOWN。AT301静态timeout、AT305首次路径child127保留；该child127没有policy采样文件，零样本不冒充已采样合规。主控首次脚本未处理该缺文件，以及后续计数断言失败均保留原time/JSON；没有工程证据失败被改写。

**REV17-Q16-PARTIAL-OWNER在所测局部范围闭合。** AT302旧core真实Q首行后kind01/index0覆盖A而cover保留的反例成立。AT303新core`a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`只增加部分窗口准入保护；kind00/01/11及legacy/LN均拒绝，272旧字、cover/next_row保持，合法row1、临时abort、显式discard与新epoch首行逐位通过。wrapper/sequencer/leaf/算术未变。此关闭具体覆盖漏洞，不升级为新core的完整16行producer或Q16父图通过；旧AT290满窗口/错epoch仍按原身份保存。

**A/B只接纳单次同终点成本观测。** AT304默认/AT305实际接受的--O3，修复后同生产SHA/同TB/fixture、30000cycle及38条有序事件一致，2048 norm/128 B，source192含row2在途64。两臂有同序单调墙钟事件，支持该前缀93.29140920005739s→89.64230179227889s、单次3.9115%改善；不作统计稳定提速、硬件Fmax或全128成本推断。AT306实际120.30851850099862s/-9/timeout仍两行，首个16行窗口没有完成，NORM_STAGE_READY未到；按合同未启动长例是正确成本出口，不能记全128数值失败。

**一个报告计数勘误需追加。** AT304/305 manifest共有112个同名条目全部SHA相同，其中107个frozen和5个fixture；报告/机读A/B的“110份共有frozen”不符实际。请更正摘要/机读对照的统计说明，保留原manifest/原日志。两种事件SHA不是矛盾：38行用换行连接且不附末换行为337b04e8…，附末换行为8b5138a2…；请在报告中注明序列化约定。AT304 manifest的purpose中旧“no optimization candidate supported”仅是冻结时历史文字，实际--O3成功以AT305原命令/日志为准，不回写冻结文件。修订17的1821/source192追加勘误已核到。

后继采用已研究的实际生产服务抽取方向：唯一LNQ/bank/prep和真实source/norm服务，原完整父top必须实例化同一服务，保持共同clk/reset与数值。A003正在按当前源码细化固定端口、bank访问与债零交接；A001会连续下达可实施接口及独立预算，不要求用户逐次批准。当前不扩大旧同配置试验，不把独立服务将来的PASS升级完整父top同runtime。全请求首错、Q16父图、STEP16/matrix/全RoPE/FINAL→Attention、整模/Host-HBM及联合物理仍开放。


[原始消息收据](../../.research-agent/communications/m004-rev18-at306-scoped-cost-closeout-20261015.json)
### m004-rev18-at306-count-erratum-completed-20261015

2026-10-15T15:20:47.925777+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev18-at306-scoped-cost-closeout-20261015

# 修订18审核计数勘误已同步

回复D-M004-REV18-REVIEW-01。AT304/305原manifest交集112项逐SHA一致，分为107 frozen+5 fixture；AT304目录中另外3个Python字节码缓存未入其manifest，原报告“110份共有frozen”已在阶段报告、模块results、E004同一报告/三摘要与机读A/B更正。38条事件LF连接不附末换行SHA为337b04e8…，附末换行为8b5138a2…，均已明确序列化约定。新增`SM004_rev18_at306_count_erratum_20261015.json`保存更正前A/B机读SHA；AT304/305原manifest、guard和日志未改。

三摘要已重新发布，A002状态改为修订18按成本出口收束、未用预算封存。Q16局部修复与LN128未完成范围遵守主控限定审核；等待A001后继具体接口合同，未续跑重工具。


[原始消息收据](../../.research-agent/communications/m004-rev18-at306-count-erratum-completed-20261015.json)
### m004-ln-shared-service-revision19-implementation-dispatch-20261015

2026-10-15T15:28:35.729583+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev18-at306-engineering-cost-owner-handoff-20261015

# 修订19：实际共享LN前端与source/norm服务抽取

2026-10-15；D-M004-LN-SHARED-SERVICE-01；A001→A002；M004/SM004/E004/R001。承接[修订18审核](../../results/m004_simplified_start_20261014/lnq_cost_owner_rev18_closeout_decision.md)。本段新增生产模块边界以取得真实LN128阶段证据，不对旧大top原样加时。M004/SM004继续running/unassessed。

正式采用[原架构“LN128实际生产服务抽取：固定切口与端口”](../../source/fixed_graph_architecture_20261014.md)的两层职责、逐种bank端口、reader/writer固定客户端和路由锁存表；[静态依据](../../source/fixed_graph_support_20261014/ln128_production_partition_20261015.json)的8项身份已由主控核到当前源码。以下为本段执行与验收边界；研究文中建议回归不另增实验预算或完成宣称。

## 生产边界与唯一资源

采用A003已给出的两层实际生产路线：一份共享LNQ/bank前端，一份source/norm I/O及固定LN128阶段调度服务。两层必须成为完整父top实际例化的模块；独立阶段TB连接这些同版生产模块及原AXI peer。不要另写功能相似的精简核、用参数/宏删原生产实例取得独立PASS，或让完整父top继续使用旧复制实现。外部原请求字段/Check语义保持；模块命名与机械端口拆分由A002在原模块design.md中落地。

共享前端拥有唯一`laya_lnq_row_v1`、原8×656×32bit final_bank（20992B）、prep/token/gamma身份、回放、LN norm保存、Q16填充/覆盖与占有生命周期。保留全部四种source_mode及现cmd_exec，不实现尚未授权的MATRIX16/STEP16/W_PREP_ONLY。W cache、matrix/PS front、G、ADD/skip和RoPE算术保持原本体与唯一实例；仅将其原共享bank与LNQ访问接回新边界，不新增整行/整tensor RAM或第二算术副本。原skip_bank、Q内部bank、reader FIFO容量如实计入，不因抽取从资源说明消失。

下层建议名`laya_lnq_bank_service_v1`，上层建议名`laya_source_norm_service_v1`。两层可经原core外壳透传连接，独立阶段直接接同一端口；exec001/010由下层完成，exec000由原重FSM通过原LNQ接口调用。legacy命令须两侧同时准入才发生一次真实接受。上层移动原staged 128行循环与16行错误屏障，原sequencer该分支只代理，禁止第二份循环/位图。下层保留固定bank_phase与ps_store、G x/gate同步读/无ready返回写、ADD同步读/无ready返回写、原结果rd/rsp；读保持在原采样沿更新，不能机械新增一拍通用总线而破坏父状态使用时刻。

source/norm服务移动现真实STATE0/AUX读取、预装/读债、norm同步读取/单writer写债、固定LN128推进所需控制及状态；旧source reader、AUX reader与writer整体各保留原有数量和本体，原RoPE/RAW/legacy通过固定相位端口继续复用。父top原tensor/epoch及legacy路径的状态归属须明确，任何状态只能有一个写入者；不建立通用owner/portal或动态任务框架。独立测试不例化非活动matrix/G/RoPE，但所测生产模块在完整父top中必须只有一份，并由实际请求调用。

## 必须保持的接口语义

1. 原cmd_exec/source_mode、id/row、model/numeric、source/destination/a_epoch，prep begin/write/commit/abort，norm result_exec与同步read/rsp/release-discard，A16_ready/window_release及完整Check均保留真实握手和身份锁存。完整状态/端口归属表写入既有design.md；父top输入变化不能改活动上下文。部分Q16占有保护必须采用当前a73632b8…修复行为，临时prep abort不得释放已有效A。
2. bank地址与读延迟保持：norm为tile384..511，Q16为4352word紧密布局，当前norm临时区4224..5247，最后Q16行有512B重叠，只在1024norm真实消费、Q完成/零债后导出。legacy矩阵final、G in-place、Down/QD及ADD的原标量/8lane读写映射原样搬移。保留G的8lane同步读与标量返回写同拍能力，不能把所有访问序列化成单事务口而丢返回；G/ADD及已发射矩阵返回的接收能力必须在发射前成立，不能事后拉ready停住没有反压的结果。原holding寄存器迁移，新增payload逐项实报；不改变FP/CE/tag或归约顺序。
3. AXI reader与writer路由在真实load/write握手后锁定，保持到全部RLAST/FIFO/holding/load_done或AW/W/B/flush债排净。source晚RRESP错仍须排净再abort，不能用已收满字数代替最终load_done/error。writer失败出口依据真实debt_zero，不能等待第二个成功flush脉冲或清计数假排空。受阻AW/W全字段稳定，B前不得释放/置成功覆盖。
4. 切相位须相关FIFO、holding、bank pending/rsp、LN/Q物理债、writer债真实为零，同时保留gamma/A16等仍有效的所有权；单纯IDLE不是释放许可。共同clk/reset保持，不门控时钟、不新造CE/reset行为。原共同reset隔离边界不升级为独立AXI reset。错误Check、逐行/16行窗口延后store错误和numeric优先规则不因拆模块改变；原全请求首错等价仍UNRESOLVED。

## 集中验证与成本门

先冻结同版新层次、父top和诊断TB，核原leaf/FP/IP/reader/writer/gold不变、唯一实例及真实编译依赖。只机械重绑定层次checker，保留全部原检查、Fatal、地址/覆盖与独立参考。以下四组在新预算内连续实施与修复，不逐步请示。

1. **真实阶段与成本。** 独立生产服务由一次固定B1/S128请求触发，真实STATE0与AUX gamma→预装→原LN→norm写B，不用保存norm代替producer。首次pilot≤120s，记录每行source/LN/B/退休cycle及单调墙钟。必须完整退休首16行并核16384个独立norm、1024源R/1024成功B、gamma256R；不能人工填余位。若同版完整16行的保守全128估计≤1440s，且RTL余额可容纳1800s，自动一次≤1800s/40Mcycle真实LN128，估计原则不小于所测16行总墙钟×8×2.5。全例核131072 norm、8192源R、8192成功B、128唯一行/末B/退休屏障、最终内存复扫，NORM_STAGE_READY真实成立但request_done/RAW/FINAL仍不得发布。没有完整16行或不落帽，保留COST_STOP，给实际阶段成本和下一最小边界；不重复同配置加时或拼接重启前缀。
2. **生产共享与兼容。** 完整父top真实展开并核新模块唯一调用；至少同版父top一行真实LN_ONLY的输入/输出/写回与独立阶段一致。抽取下层Q16以原row0/1 norm交替16行，核全部4352word/512响应及r15最后输入受阻的重叠边界，明确只有两种独立输入样本；合并部分窗口拒绝、合法继续、abort/discard及下一epoch。共享bank的原matrix final/G并行读回写/QD/ADD访问以合法同步客户逐事务核映射/保持/无覆盖，局部客户不得冒充完整matrix/FFN算术。父图已授权受影响短前缀中核真实W-AUX→source-AUX与RoPE读写客户端转交、无ready返回零丢失；未到的路径保留NOT_RUN，不伪造完成。原leaf算术和不受影响的旧测试按SHA复用；未跑完整父top legacy链明确留缺口，不为本段重跑旧长基线。
3. **读写错误与恢复。** 一条真实source晚RRESP或gamma load_done错误及一条真实norm末B错误；验证读债排净、错误完成保持、不置失败行覆盖、无reset显式discard及新epoch恢复。对norm B错后的LN继续/discard与numeric优先，沿原16行窗口规则，用明确原始错误位置和真实完成计数区分；端点局部覆盖不能升级未运行的完整窗口。
4. **相位边界与reset。** 实际有限AR/R/AW/W/B停顿、至少一个跨4KiB页界合法输入；在prep或LN/回放真实在途点共同reset，清覆盖/活动后510拍无旧可见写，再真实新行恢复。共享服务向legacy/下一阶段交接需实测pending/rsp或writer末B受阻时禁止提前切换；仅模拟客户的交接明确标签。不要重复AT301–306不受影响旧配置来充数。

## 新预算、交付与未覆盖

本段独立host准备累计300s/8GiB；static/IP累计1800s/24GiB，单次600s；RTL累计3600s/8GiB，单次1800s/40Mcycle，首pilot≤120s、真实语义停滞120s保护。完整父top有限回归也计本段，首次未知路径先≤120s pilot，失败和构建成本全部入账。CPU0–3/nice19/idle、MemAvailable>192GiB及全项目单重工具不变。旧修订18余额封存不转移；不启动HLS/OOC/P&R、gold/完整oracle、新agent或无关进程管理。

A002独占E002实现/TB/design/results与E004原始证据和三摘要；A003只补充静态源依据，A001负责合同与集中审核。普通代码/连接/构建/TB错误在帽内连续修复；数值、CE/时钟或额外存储变化属于实质边界，及时定向交主控，无关已授权工作继续。

交付需分别报告生产抽取与唯一资源、同版父top和独立服务覆盖、完整16行/128行是否真正完成、原guard费用与每项PASS/FAIL/NOT_RUN/COST_STOP。独立LN128通过不证明完整父top同runtime提速或全模型通过；Q16父图、STEP16/完整matrix、全RoPE/FINAL→Attention、旧首错等价、Host/HBM/物理BO及联合资源/Fmax仍按未测范围保留。


[原始消息收据](../../.research-agent/communications/m004-ln-shared-service-revision19-implementation-dispatch-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [ln128_production_partition_20261015.json](../../source/fixed_graph_support_20261014/ln128_production_partition_20261015.json)
### m004-rev19-at315-shared-q16-parent-row0-milestone-20261016

2026-10-15T16:15:41.649854+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-ln-shared-service-revision19-implementation-dispatch-20261015

# 修订19中途里程碑：下层Q16全窗口与当前父top row0

关联 D-M004-LN-SHARED-SERVICE-01；回复 m004-ln-shared-service-revision19-implementation-dispatch-20261015。工程继续running，尚未阶段交付。

AT313 下层生产服务独立TB首次运行 row0..14 逐位核后，row15最后norm字停顿激励未撤上一个write_valid，触TB Fatal；原guard child0/null但本次FAIL保留。只修TB停顿激励后，AT314 同一生产下层 `laya_lnq_bank_service_v1.sv`、保存的row0/1 norm交替16行：全16行4352个Q/scale bank字、512次同步响应、r15最后输入停顿、完整窗口持有/释放、错epoch拒绝通过。static/RTL guard均child0/null、32.499s/24.967s量级（精确值以各原guard为准）；本局部不签真实16行LN producer或父图Q16调用。

AT315 当前生产下层/上层/父core/wrapper/sequencer真实展开 static child0/null 133.11603546142578s；真实父top row0前缀 RTL child0/null 49.48341755196452s，gamma256R、source64R、norm1024及64笔B，cycle15375退休；该固定160us前缀无完整16行或128行终标。当前上层仍以reader/writer和路由封装为主，LN128循环及16行错误屏障仍在旧sequencer/wrapper，独立生产stage TB尚未可合法启动。下一步继续单一owner迁移这些状态和source/norm控制；不会把父top前缀当独立服务PASS。

AT307–312旧证据及AT313原失败仍保留。本次新增原始证据在R001/attempts/AT313、AT314、AT315各目录，包括冻结manifest/guard/log。旧累计static683.129087s、RTL297.818944s之后成本继续累加；待本阶段集中核对精确总账。无HLS/OOC/P&R/新gold。


[原始消息收据](../../.research-agent/communications/m004-rev19-at315-shared-q16-parent-row0-milestone-20261016.json)
### m004-rev19-at315-scoped-milestone-review-20261016

2026-10-15T16:25:40.948947+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev19-at315-shared-q16-parent-row0-milestone-20261016

# 修订19 AT313–315阶段内限定审核与继续实施

2026-10-16；D-M004-REV19-AT315-01；A001→A002；M004/SM004/E004/R001。回复`m004-rev19-at315-shared-q16-parent-row0-milestone-20261016`，沿D-M004-LN-SHARED-SERVICE-01继续，修订19未收束、预算不封存，不新增修订或逐步审批。

[主控原始证据核验](../../results/m004_simplified_start_20261014/ln_shared_service_rev19_at315_review_20261016.json)共818项检查成立：AT313/314/315分别120/120/117项冻结源码，共357项；另将实际使用的12份fixture直接绑定原AT225/AT304保存文件。新manifest的entries只覆盖frozen，fixture绑定单列。六笔guard的38条实际政策、日志和内存记录一致。AT307–312本次只复核原guard费用，不由此新增功能接纳。

1. **AT314局部接纳。** 下层生产服务d39a5479…在两份保存norm交替填充16槽的条件下，逐行即时核4352个Q/scale字、512同步响应、r15末输入停顿、完整窗口持有/释放及错epoch拒绝成立。AT313到AT314的冻结源码仅TB停顿激励变化，AT313原Fatal即使child0仍保留FAIL。错epoch为ready拒绝，不记为错误done。现TB没有填满后对全部4352字作最终复扫；请在后续受影响同版Q16回归中合并最终全窗复扫与原partial ownership/abort/discard检查，不为这一项单独重跑旧AT314。保存norm与TB提供的合法phase/owner输入仅签下层局部，不签真实LN16或父图Q16调用。

2. **AT315接纳真实父top row0观测前缀。** 冻结core9fc852c9…、wrapperb353e634…、上层726a24a0…、下层d39a5479…、sequencera4c999e5…的真实展开成立；日志在cycle15375观察row0退休，gamma256R、1024norm逐位W检查及64笔B。source64R是row0退休时的计数；仿真继续到固定160us退出，原记录没有最终全次source计数，因此该总数保留UNKNOWN，不把64写成整次运行总数，也无需重跑追补。没有完整16/128行终标，不记完整TB PASS。

3. **完成原合同单一控制归属后启动独立stage。** 除上层128行循环、16行错误屏障及source/norm控制，冻结AT315父core仍驱动LN_CMD/LN_WAIT、ln_only_ready/norm_store_valid、feed_start/active及LN_NORM_VIEW地址选择。原合同exec001/010由下层完成，故LN_ONLY命令→回放/保存→结果视图→真实release/done的本地生命周期也须迁移到下层；上层负责真实输入/输出及阶段循环。父core/wrapper/sequencer只代理相应固定入口，不能留下第二份控制。独立TB不得重造这些生产状态、成功覆盖或强制bank_idle/清债替代迁移。这是原合同落地细化，不是新架构或停点；普通连接/编译/回归在原帽内继续。原算术、存储数量、共同clk/reset、G同步1R+1W及无ready返回语义保持。

4. **费用与记载更正。** AT314 static实际31.224050499498844s；32.49943132698536s属于AT313 static。AT314 RTL24.967098630964756s；AT315 static133.11603546142578s、RTL49.48341755196452s。截至AT315共16笔guard（9static/7RTL），累计static879.9686042405664817/1800s、RTL395.898595323786132/3600s；该时点余920.0313957594335183s/3204.101404676213868s，后续已发生费用继续加入，host完整UNKNOWN。AT313首次独立服务RTL plan写240s，实际23.629135239869356s；原plan保留，后续首次未知路径pilot须严格按原≤120s配置，不用短实耗覆盖配置偏差。

工程按原合同继续迁移、唯一实例/依赖核查与受影响短回归。独立服务同版完整16行及成本条件满足后，自动执行既定LN128长例；本次两种保存输入的Q16窗口和父top单行均不能替代这一条件。完整16行估计原则、1800s单次/3600s累计及单重工具规则不变；不挪旧封存余额，不新增HLS/OOC/P&R/gold。真实LN128、父top完整同runtime、Q16父图/STEP16、全QKV/RoPE/FINAL→Attention、旧全请求首错等价、整模/Host-HBM/联合物理仍开放。M004/SM004保持running/unassessed，无需确认收信，下一次在实质里程碑或集中阶段交付时回传。


[原始消息收据](../../.research-agent/communications/m004-rev19-at315-scoped-milestone-review-20261016.json)
### m004-rev19-at325-engineering-stage-handoff-20261016

2026-10-15T17:10:47.914694+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev19-at315-scoped-milestone-review-20261016

# 修订19 AT325共享服务阶段交付：下层闭合、上层归属未完成

回复 m004-rev19-at315-scoped-milestone-review-20261016；M004/SM004/E004/R001。工程按D-M004-LN-SHARED-SERVICE-01继续至本段成本边界，修订19未自行封账，M004/SM004仍running/unassessed。

当前生产下层 SHA 63da9112d2a23583a652537f6ad45a84164eecce138abbb06345df567d08908e、父core 8c799f91e4b436a78090161303efcb9cd84e69cf3f1791c4e6ed3c362e3f4667、上层 c6ca8ca70322f4f0218bd3eec08b17c2d6e058071ccfc0e4d77f92551ef0acf6、wrapper 8294dc2f724b16f59937ecd0f885925eadd64295d2fc4db4eb9ec258009a1291、sequencer a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4。下层已接管staged LN_ONLY命令→回放→norm视图→同步读/release/done，本体唯一LNQ与8bank；父core staged入口只代理，legacy仍用原LN_CMD/LN_WAIT同一下层。AT322同版完整父top三快照编译，AT323固定160µs真实父top row0前缀在cycle15377退休、gamma256R、退休点source64R、1024norm逐位、64笔B；没有16行或终标。

AT324/325同版下层使用保存row0/1 norm交替16槽逐字核4352 Q/scale、512同步响应、r15末输入停顿、全窗最终复扫和部分占有/abort/discard/新epoch。AT324另以保存raw/gamma完成局部LN_ONLY1024 norm及非法tile128的7/phase12保持；AT325只改TB，增PS 16lane、G x/gate各8lane读与同拍不同地址标量写、QD单字、ADD读写的固定同步客户逐值PASS。AT322同版raw末RRESP错误真排空后新epoch64B恢复、末B错误后row1继续LN且B不增加、discard后epoch3正常row0恢复各child0/null。局部输入/客户不是实际128行producer或完整matrix/G算术。

逐guard总账为AT307–325的19份manifest、2139个frozen项零SHA失配；38笔guard（17 static/21 RTL）、288条实际CPU0–3/nice19/idle样本零政策失配。static 1706.08185053430498095/1800s、RTL 1473.825600214302521/3600s，余93.91814946569501905s/2126.174399785697479s，host累计UNKNOWN。AT313 Fatal、AT317语义守卫误停、AT319/320编译错误、AT325第一次脚本路径child127均保留原guard费用；AT314 static 31.224050499498844s，旧阶段消息所写32.49943132698536s属于AT313。

关键缺口：上层目前仍主要是reader/writer/路由及外部脉冲驱动的覆盖；128行循环、16行store错屏障仍在旧sequencer/wrapper。独立stage TB不能合法重造这些生产状态。剩余static 93.918s低于已实测AT315父top展开133.116s和AT322三快照310.638s；改变生产上层后无足够原帽签同版父图及普通修复。因此没有启动独立16行pilot，更不能按原成本门启动LN128；真实NORM_STAGE_READY和完整父top同runtime均NOT_RUN，而非数值FAIL。原修订19余额暂保留，未转旧修订或额外运行。

请主控按已研究切口衔接下一具体实施/预算：把sequencer 128行推进与16行错误归并、wrapper source/norm阶段控制迁入现上层，父top仅固定代理；随后同SHA父top与独立stage各真实展开，16行pilot落帽后再判LN128。共同reset、页界和相位pending/rsp/末B阻塞交接也需在迁移后同版核。后继Q16父图、STEP16/matrix、全RoPE/FINAL→Attention、全请求首错、Host/HBM及联合物理仍开放。

原始[阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md)与[逐guard账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev19_guard_ledger_AT307_AT325_20261016.json)已写；模块design/results、E004三摘要已发布，A002真实状态已report。无HLS重综/OOC/P&R/新gold。


[原始消息收据](../../.research-agent/communications/m004-rev19-at325-engineering-stage-handoff-20261016.json)

相关文件：[SM004_rev19_AT325_shared_service_engineering_stage_20261016.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev19_AT325_shared_service_engineering_stage_20261016.md) · [SM004_rev19_guard_ledger_AT307_AT325_20261016.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev19_guard_ledger_AT307_AT325_20261016.json)
### m004-rev19-review-rev20-source-norm-owner-dispatch-20261016

2026-10-15T17:19:06.138448+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev19-at325-engineering-stage-handoff-20261016

# 修订20：上层source/norm单一归属与真实LN128阶段

2026-10-16；D-M004-SOURCE-NORM-OWNER-01；A001→A002；M004/SM004/E004/R001。承接[修订19限定审核](../../results/m004_simplified_start_20261014/ln_shared_service_rev19_at325_stage_decision.md)及原[D-M004-LN-SHARED-SERVICE-01](../../results/m004_simplified_start_20261014/ln_shared_service_rev19_decision.md)。采用既有[两模块静态切口](../../source/fixed_graph_architecture_20261014.md)，不再研究新架构。本段完成上层控制迁移、同版父请求入口与独立生产stage验证；工程在下列独立预算内连续实施、修复、回归，无逐项审批。

## 固定实现边界

起点为AT322–325同SHA：下层63da9112…、core8c799f91…、上层c6ca8ca7…、wrapper8294dc2f…、sequencera4c999e5…。A002继续唯一拥有E002 RTL/TB/design/results及E004原始证据；A001拥有本合同与集中审核。保留一份LN/Q、一份8×656×32bit final_bank、原skip/Q bank、两reader与单writer及原FIFO/holding容量；原leaf/FP/IP、数值顺序、共同clk/reset、无ready返回和同步读周期不变。无HLS重综/OOC/P&R、gold/完整oracle、第二bank或新agent。

上层`laya_source_norm_service_v1`须实际拥有以下控制，旧层不得保留可同时运行的副本：

- 从sequencer移动staged请求描述符验证/锁存、base_id/retired_rows、S_SEND/S_ROW/S_STAGE_READY和16行`drain_store_window/store_error_*`完整Check保持。原sequencer staged分支只传递一次请求握手、持有/错误与discard；legacy QKV/RoPE循环仍归原分支。不能让测试台逐行发命令来代替128循环。
- 从wrapper移动IN_* source/gamma预装、input_hold及读完成/错排空，norm SEG_PREP/READ_REQ/RSP/FLUSH/UNFLUSH/RELEASE/Q_DONE等对应分支，以及行退休、成功覆盖和错误完成条件。`stage_clear/row_retire/store_fault/ready_commit`须成为上层内部事件，不能由外部TB或旧wrapper决定成功位。上层现有reader/writer/路由原位复用；legacy source与QKV/RoPE固定客户调用同一生产服务。
- 128行staged上下文、norm_written、阶段失败及完成保持只有一份owner。外部tensor/epoch状态与该上下文的代理关系写清，父层不得另建影子位图后用它发布。正常stage ready保持到真实消费者/明确discard，绝不等于完整request_done、RAW或FINAL发布。

独立stage直接连接这一上层与同一真实下层，只有AXI存储peer及未活动的legacy客户端空闲接线。下层继续拥有LN_ONLY生命周期；其现端口还依赖父侧准入、prep_consume、bank_idle和完整Check映射，迁移时一并把**原staged固定准入/身份/Check逻辑**接成生产路径。result/done的id/row/epoch与result_exec=001来自接受时上下文；原op=0x10/status16/detail32/bad64映射与原行内/16行索引保持，不能由独立TB补齐或只检查4bit status。可将原纯映射移入下层固定输出，并让父core代理同一输出；保留legacy接口。活动状态/物理债必须由模块真实状态导出，外部空闲客户端常量不许覆盖LN或reader/writer债。仅为端口落地作必要下层调整，不扩展Q16父图、STEP16或矩阵。

## 必须保持的退休和错误行为

gamma先kind11完成1024项finite检查、真实256次AUX R及prep提交，随后每行kind01读取STATE0+s×4096；gamma身份在128行间保持。真实128个同步norm响应、64笔OKAY B、flush捕获/撤下、读写及bank pending/rsp债零、下层release/done消费后才置该行成功位并递增。末行不得回绕；非法base_id/range零发射。读取失败必须排完已接受事务再abort，缺数据不填零。

store故障锁存原首个错误、真实排债、禁止新增写；仅继续原当前16行LN算术窗口，成功norm通过故障上下文授权的discard退休而不置位、不增加成功B。窗口中数值Check优先，窗口全算术成功才报保存的store错误；不得把这一规则扩展成已证明旧整模首错等价。明确正常退休、算术成功但store故障后的discard计数、写成功数三个口径。

AUX/core LOAD/source/RoPE切路须等真实load_done/out_valid/input_hold清空；writer须末B、flush撤下及debt_zero后rearm/换段。上层对下层的release须同时核同步read pending/rsp和叶子债，不能仅看IDLE。共同reset清有效状态及peer活动，仍不签独立AXI reset。旧e/e+1/e+2、失败sticky和显式discard规则保持，不自动释放后续WO残差需要的norm。

## 集中验证与构建顺序

先完成上述单一owner迁移和设计状态表，再以独立stage作快速编译/短测，稳定后构建同SHA真实S128请求父top。避免每搬一组寄存器便重建全部重父图。复用已核且未改的库闭包，重新编译全部受影响源；冻结实际源码/FP/IP/工具/TB和**实际运行所读fixture**。未变AT324/325局部证据按SHA复用，仅端口/占有或读时序受影响时重跑对应短例，不重跑旧长算术基线。

1. **真实独立阶段。** 用原完整B1/S128 STATE0 raw、gamma及131072字norm gold，由一次固定请求触发生产循环。首次pilot≤120s，逐行记录source/LN/末B/退休cycle及单调墙钟；只观察到前缀时如实记录。完整首16行须16384norm逐位、1024 sourceR、1024成功B、gamma256R及真实覆盖。pilot可以在16行退休后有明确前缀终标退出，不能缩小生产128形状。取得同版完整窗口后，保守全128估计至少为该16行总墙钟×8×2.5；估计≤1440s且RTL余量能容纳1800s时，自动一次≤1800s/40Mcycle真实LN128，不等新批准。全例核131072norm、8192 sourceR/8192成功B、128唯一退休、末B屏障、最终内存复扫和真实NORM_STAGE_READY，request_done/RAW/FINAL仍不得发布。没有完整16行或不落帽则交COST_STOP与实际瓶颈，不同配置不得拼接、同配置不自动加时。
2. **真实父请求入口。** 同版`laya_qkv_s128_request_v1`连完整父层实际例化两共享模块；至少一次请求接受后由生产控制自动完成真实row0，核1024norm/64B及退休事件，有限前缀禁止提前请求成功/阶段发布。与独立服务同输入行比逐位结果及握手/退休约束，允许明确固定代理带来的控制周期差，不宣称父重图仿真提速。TB须有自身前缀终标和终点计数，不只固定时间quit。AT323逐行命令TB可以作局部回归，不能代替本项。
3. **迁移受影响的错误与反压。** 真实source晚RRESP或gamma load_done错误真排空→显式discard→新epoch恢复；真实norm末B错误→原16行窗口延后检查/discard规则；有限AR/R/AW/W/B停顿与一例4KiB页界；prep或LN/回放真在途共同reset后510拍隔离及新行恢复。合并至同一新stage TB，用运行参数选择，保留全字段保持及真实B checker。16行store/numeric先后控制可用明确合法完成peer作局部区分，但至少保留真实store错后下一LN行及恢复端点，不能把peer结果写成16行真算术。
4. **持有与交接。** 同步pending/rsp受阻及末B受阻时，禁止release/覆盖/阶段ready/legacy换路；释放后真实债零才能推进。正常末行可合并在LN128中；若LN128未跑，只用标明模拟完成peer的128元数据短例覆盖末行屏障，不作为真实LN128。改动到下层接口时只补受影响Q16部分占有/同步读短回归。

## 独立预算和出口

修订20host准备累计300s/8GiB；static/IP累计1800s/24GiB、单次600s；RTL累计3600s/8GiB、单次1800s/40Mcycle。首次未知路径pilot≤120s，真实语义停滞120s；CPU0–3/nice19/idle、MemAvailable>192GiB、全项目单重工具。至少为最终同版父请求top编译与受影响修正保留400s static计划空间；它包含在1800s内，不是追加额度。仅改变TB可增量构建，生产层次改变必须实际重新展开。旧修订19余额封存，不挪用、不回填；所有失败/构建/局部/长例入同一账，host未知项如实保留。

本段交付重点是上层单一owner是否完成、独立stage及真正父请求top是否同版、完整16/128是否到终点及成本。实现/连接/TB/守卫普通错误在帽内连续修复，不为每次动作另建审核文档；阶段变化、实质阻塞或集中出口回传。预算不足时先交已完成映射和确切缺口，不把未测试端口声明为可用。完整Q16父图、matrix/全RoPE/FINAL→Attention、旧全请求首错、完整模型、Host/HBM/物理BO与联合资源/Fmax继续开放。


[原始消息收据](../../.research-agent/communications/m004-rev19-review-rev20-source-norm-owner-dispatch-20261016.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md)
### m004-rev20-at327-lower-check-parent-row0-partial-20261016

2026-10-15T17:34:17.758992+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-rev19-review-rev20-source-norm-owner-dispatch-20261016

# 修订20 AT326–327局部里程碑（2026-10-16）

修订20仍在实施；本记录仅对应已执行的下层完整Check回显与上层内部覆盖位移交后的父top row0前缀。未完成上层单一owner、独立生产stage或完整16/128行。

- AT326：下层接受LN_ONLY时锁存id/row/epoch，导出result_exec=001及op8/status16/detail32/bad64，父core核接收身份并代理。原局部Q16全部16槽4352字最终复扫、512同步响应、部分窗口abort/discard/新epoch和共享bank客户端仍通过；非法LN视图tile的完整Check断言通过。static 32.20409899018705s，RTL 30.382008612155914s，均child0/trigger null。
- AT327：在上层生产服务内部维护norm_written、stage_store_fault与norm_stage_ready，wrapper撤去原成功位/故障/ready决定脉冲。冻结124份源码/脚本及5份实际fixture；同版父top重新展开static 143.9772515669465s，RTL 49.26396718993783s，均child0/trigger null。`PREFIX_ROW0`自检实际gamma256R、source64R、1024项norm逐位、64笔OKAY B及row0退休；终标在153800ns，无提前stage ready。该source64R为终标时全次计数，运行在row0完成后立即结束；不推断后继行或128终点。

四笔guard当前累计static 176.18135055713355/1800s、RTL 79.64597580209374/3600s；截至AT327余static 1623.81864944286645s、RTL 3520.35402419790626s，static仍须为最终父top构建保留400s。host完整累计UNKNOWN。原guard、manifest、源码身份均在各自attempt目录，失败/旧结果不改。

当前`laya_qkv_s128_request_v1`仍驱动staged 128行S_SEND/S_ROW/S_STAGE_READY与16行store错误屏障；`laya_qkv_scratch_row_v1`仍驱动IN_*及norm SEG/READ/FLUSH/RELEASE/Q_DONE。因此AT327是父请求前缀功能回归，不能判D-M004-SOURCE-NORM-OWNER-01控制迁移完成。下一步按既有固定切口迁移上层唯一控制后，再建立无逐行TB代驱动的独立stage与16行成本pilot；完整LN128和父top同版联合验证未运行。


[原始消息收据](../../.research-agent/communications/m004-rev20-at327-lower-check-parent-row0-partial-20261016.json)
### m004-rev20-at327-scoped-review-local-reject-check-20261016

2026-10-15T17:37:52.251122+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at327-lower-check-parent-row0-partial-20261016

# 修订20阶段内进展与受影响问题

2026-10-16；A001→A002；M004/SM004/E004/R001。回复`m004-rev20-at327-lower-check-parent-row0-partial-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续，本条不新增修订、预算或放行停点，修订20仍实施中。

## AT326–327限定核验

[主控机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_progress_review_20261016.json)585项成立：247项冻结源码、14份实际fixture与原来源匹配，四笔原guard/33条政策一致。AT326下层418deefe…完整Check的非法tile样本，以及原两种保存norm的Q16最终4352字复扫/512响应、占有恢复与固定bank客户局部接纳；不签所有Check异常分支。

AT327 core8d78fa81…、wrappera5cec9ba…、上层589ff375…、原sequencera4c999e5…真实展开，TB实际实例化S128请求top并只接受一次请求。首行终标前检查1024norm实际写回及内存复扫、64B、source64R/gamma256R、仅一位norm覆盖，未提前request_done/RAW/FINAL/stage ready；明确`STAGED_LN_ROW0_PREFIX_PASS`后立即finish。因此这里source64可签**终点全次计数**，与旧固定时间quit的口径不同。该版本的128推进/16行store错屏障和IN_*/norm写回控制仍在旧父层，不能签上层独立归属或真实16/LN128完成。

截至AT327原guard精确十进制合计static176.18135055713355s、RTL79.645975802093744s；余1623.81864944286645s/3520.354024197906256s，后继费用继续加入。消息RTL末位差为浮点汇总取舍，阶段最终机读账请直接按各guard十进制字符串求和；不改原收据、不为此重跑。保留原400s最终父top静态计划空间，host完整UNKNOWN。

## REV20-LOCAL-REJECT-CHECK：静态风险，原合同内复现修复

冻结AT326/327 `laya_lnq_wi_gqdown_row_v1.sv` 的Check输出仅按`exec_mode==001`选择下层Check，再以id/row/epoch/exec判断回显身份。父core自身拒绝LN_ONLY命令时同样会锁存exec001并直接DONE，但没有新的下层命令。

具体静态见证：成功LN_ONLY行的done已消费后，重复相同id/row/epoch但缺prep token。父core仍可接受命令并由`!prepared_match`拒绝为status7/phase14；下层未接受本次命令，保留上次status0/detail0且身份恰好相等，故`staged_ln_identity_bad`为假，当前mux可输出check_status16=0/detail0，与父done_status7矛盾。此为源码推导，**尚未RTL复现**，不改写AT326非法tile或AT327正常前缀PASS。

请在本修订原帽内把“本次命令确实进入下层并退休”的来源归属纳入Check选择/锁存；父本地拒绝必须输出原op10/status7/detail07100005/bad64全1，并在阻塞到消费期间保持。不能仅靠mode或可能复用的身份判断来源，也不能清下层历史结果来伪造新命令完成。结合原准备令牌准入短回归复现旧行为、验证修复后的本地拒绝与后继合法行，保留零新下层接受/零W-AUX启动约束；无需冷W或重跑旧长链。若上层迁移直接吸收该准入分支，可在最终生产入口统一修复，但保留可执行父core路径的同样语义。

上层owner迁移独立继续，不等此局部问题另一次批准。完成128循环/16行错误归并与source/norm状态集中后，再建立真正独立stage和完整16行成本pilot；不要在每次寄存器移动后重复完整重父图。新的受影响证据按新SHA记录，原首行前缀不自动迁移。阶段内普通修复合并到既有design/results和最终交付，不需确认收信。


[原始消息收据](../../.research-agent/communications/m004-rev20-at327-scoped-review-local-reject-check-20261016.json)
### m004-rev20-at331-bank-extract-local-check-milestone-20261016

2026-10-15T17:55:52.117852+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-rev20-at327-scoped-review-local-reject-check-20261016

# 修订20 AT328–331阶段结果（2026-10-16）

修订20继续实施；本次闭合唯一bank物理实例外移的父请求row0前缀，以及`REV20-LOCAL-REJECT-CHECK`局部反例。上层128行调度和source/norm状态迁移、独立生产stage、完整16/128行均未完成。

AT328把`laya_lnq_bank_service_v1`唯一物理实例放在`laya_source_norm_service_v1`内。重core变为`laya_lnq_wi_gqdown_row_engine_v1`，以固定`laya_lnq_bank_link_v1`直接透传原151根bank端口；原名core模块只作为独立旧测试的兼容壳。完整父请求top例化的是engine与上层服务，不例化兼容壳，故层次中只有一份LNQ和8×656×32bit final_bank。没有新增payload/整行RAM、算术、CE、时钟或读写拍延迟。实际重新展开static136.91756376065314s/child0；父请求row0 RTL49.00890666805208s/child0，1024norm逐位、64个OKAY B、source64R/gamma256R和row0终标保持。该前缀仍由旧sequencer/wrapper staged FSM驱动。

AT329对主控静态见证执行真实旧版复现：一条本地LN_ONLY成功后，下层仅接受1次、prep token被消费；再以相同id/row/epoch发缺token命令，父core本地返回status7/phase14、零新下层接受/零AXI，但错误地回显旧Check的status16=0/detail32=0。TB显式要求该旧值，打印`LN_LOCAL_OLD_CHECK_BUG_REPRODUCED`，不是旧版正确性PASS。static129.32646005228162s、RTL44.61232251115143s，均child0/无guard触发。

AT330修复父core Check来源：仅在本次命令同时被父core和下层真实接受时锁存`staged_ln_delegated=1`；本地拒绝使用op0x10/status16=7/detail32=0x07100005/bad64全1，不能复用下层历史done。相同刺激的首条真实LN_ONLY成功、第二条status7/phase14及完整协议Check、保持3拍、零新下层接受/零AXI成立。static129.4566306155175s、RTL44.30953416787088s，均child0/无guard触发。AT331再以修复后同SHA重编完整父top（static142.03380057401955s/child0），真实row0前缀仍逐位1024norm、64B、source64R/gamma256R并正常退休（RTL49.713256319984794s/child0）。此仅签同版正常row0，不签完整16/128行或其它Check分支。

当前冻结生产SHA：下层`f63e25e243ccd1bc264971fcbe5a1cd17b13eff472773722d001b503c287e043`、父core`452deb9cea5630bec1cb922365a4f6615a9635d93e86dce26f24b298ecc1a94a`、上层`5b6c78342e76a4f17cbb8fa949fbde666e50300cbb5da6c34a388ee2d5a6c530`、wrapper`a4a9a93753806e77261a04583a1cc33fea89a497985bbfcfb9cfb122b8e63a19`、sequencer`a4c999e5e7e5ea63c95dd7abf9d70d0eb4362b06b36e080b2670807c9500bca4`。AT326–331六份manifest的773项冻结/fixture文件与100条实际政策样本逐项核过零不匹配；12笔guard精确合计static713.91580555960536/1800s、RTL267.289995469152928/3600s，剩1086.08419444039464s/3332.710004530847072s。其中400s static仍为后续最终父top构建计划空间，旧修订余额不转入；host完整累计UNKNOWN。[机读逐guard账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_guard_ledger_AT326_AT331_20261016.json)保留每次原收据位置及费用。

下一步仍是既定控制迁移：上层一次请求锁存描述符并独占128行循环/16行store错误屏障、source/gamma预装和norm同步读写/退休；旧sequencer/wrapper只代理，独立stage连接同版上层和唯一下层，不能以逐行TB命令或强制债零代替。当前无完整16行成本样本，不具备自动启动真实LN128的门槛。完整Q16父图、STEP16/matrix、全RoPE/FINAL→Attention、整模与物理结果保持未验。


[原始消息收据](../../.research-agent/communications/m004-rev20-at331-bank-extract-local-check-milestone-20261016.json)
### m004-rev20-at331-scoped-bank-check-review-20261016

2026-10-15T17:59:48.464628+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at331-bank-extract-local-check-milestone-20261016

# 修订20阶段内进展与受影响问题

## 当前AT328–331：固定bank移位与Check来源局部修复

2026-10-16；A001→A002；回复`m004-rev20-at331-bank-extract-local-check-milestone-20261016`。修订20仍按D-M004-SOURCE-NORM-OWNER-01实施；本次限定接纳，不封账、不增预算或新修订。

[新增机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at331_review_20261016.json)1878项成立：AT326–331累计749项frozen＋24项fixture＝773项、12笔原guard/100条实际政策一致。static713.91580555960536s、RTL267.289995469152928s；截至AT331余1086.08419444039464s/3332.710004530847072s，后续费用继续加入，host完整UNKNOWN。

物理抽取按原合同的固定接线落地接纳：下层f63e25e2…相对AT327仅前置151信号声明的interface，`laya_lnq_bank_service_v1`模块本体逐字节相同；151项原端口方向/宽度、原core表达式→engine连续赋值、上层→bank连接全部核对一致。interface无always/assign/initial/仲裁或存储。当前父wrapper实际例化engine和上层，展开日志包含engine而无旧名兼容壳；上层只例化一份物理bank服务。因此签所测层次的唯一LNQ/bank和固定接线，不将其升级为全部legacy算术或物理综合结果。新bank link只是固定端口集合，后续不得加通用队列/仲裁/额外读拍来迁移控制。

`REV20-LOCAL-REJECT-CHECK`更新为**CLOSED_SCOPED_REPRO_AND_CHECK_FIX**：AT329旧AT327结构下，真实零raw/单位gamma的LN成功消费后，同身份缺token拒绝确实得到status7但旧Check=0，原终标只表示bug复现；AT330采用兼容壳＋修复engine，`staged_ln_delegated`仅在本次真实上下层同时接受时锁存，本地拒绝返回op10/status7/detail07100005/bad64全1，零新增下层接受、全程零W/AUX ARVALID。三拍保持实际检查done_valid、check_status及detail；其余定义字段在诊断点检查。两次不是相同整个DUT身份的纯单变量A/B；源差异、机械接线与各自真实结果分别保留。AT331与AT330同修复engine在真实父S128请求入口的正常row0终标、1024norm/64B/source64R/gamma256R接纳，不能代签其它Check分支。

覆盖待补：AT330在错误done保持后直接finish，未消费该错误done并运行第三条合法命令；AT331是另一次仿真，不能替代同runtime无reset继续。将“错误done真实消费→重新准备→合法下一命令”的检查合并到迁移后受影响的恢复短例，不为此单独重建/重跑AT329/330旧快照，也不阻塞上层迁移。原正常数据、原错误反例和费用不回写。

下一关键路径不变：一次请求描述符锁存、128循环、16行store错误归并、IN_*和norm同步读写/退休控制迁入现上层；固定请求父top只代理。原sequencer/wrapper仍驱动这些状态，因此独立stage/真实16行/LN128仍NOT_RUN。优先完成控制归属与快速独立stage构建，不在每次内部移动后重复重父top；保留400s最终父top静态计划空间。只有同版完整16行与原成本门成立后才自动LN128，无新审批或确认收信事项。

## 历史AT326–327审核与当时静态问题

2026-10-16；A001→A002；M004/SM004/E004/R001。回复`m004-rev20-at327-lower-check-parent-row0-partial-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续，本条不新增修订、预算或放行停点，修订20仍实施中。

## AT326–327限定核验

[主控机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_progress_review_20261016.json)585项成立：247项冻结源码、14份实际fixture与原来源匹配，四笔原guard/33条政策一致。AT326下层418deefe…完整Check的非法tile样本，以及原两种保存norm的Q16最终4352字复扫/512响应、占有恢复与固定bank客户局部接纳；不签所有Check异常分支。

AT327 core8d78fa81…、wrappera5cec9ba…、上层589ff375…、原sequencera4c999e5…真实展开，TB实际实例化S128请求top并只接受一次请求。首行终标前检查1024norm实际写回及内存复扫、64B、source64R/gamma256R、仅一位norm覆盖，未提前request_done/RAW/FINAL/stage ready；明确`STAGED_LN_ROW0_PREFIX_PASS`后立即finish。因此这里source64可签**终点全次计数**，与旧固定时间quit的口径不同。该版本的128推进/16行store错屏障和IN_*/norm写回控制仍在旧父层，不能签上层独立归属或真实16/LN128完成。

截至AT327原guard精确十进制合计static176.18135055713355s、RTL79.645975802093744s；余1623.81864944286645s/3520.354024197906256s，后继费用继续加入。消息RTL末位差为浮点汇总取舍，阶段最终机读账请直接按各guard十进制字符串求和；不改原收据、不为此重跑。保留原400s最终父top静态计划空间，host完整UNKNOWN。

## REV20-LOCAL-REJECT-CHECK：静态风险，原合同内复现修复

冻结AT326/327 `laya_lnq_wi_gqdown_row_v1.sv` 的Check输出仅按`exec_mode==001`选择下层Check，再以id/row/epoch/exec判断回显身份。父core自身拒绝LN_ONLY命令时同样会锁存exec001并直接DONE，但没有新的下层命令。

具体静态见证：成功LN_ONLY行的done已消费后，重复相同id/row/epoch但缺prep token。父core仍可接受命令并由`!prepared_match`拒绝为status7/phase14；下层未接受本次命令，保留上次status0/detail0且身份恰好相等，故`staged_ln_identity_bad`为假，当前mux可输出check_status16=0/detail0，与父done_status7矛盾。此为源码推导，**尚未RTL复现**，不改写AT326非法tile或AT327正常前缀PASS。

请在本修订原帽内把“本次命令确实进入下层并退休”的来源归属纳入Check选择/锁存；父本地拒绝必须输出原op10/status7/detail07100005/bad64全1，并在阻塞到消费期间保持。不能仅靠mode或可能复用的身份判断来源，也不能清下层历史结果来伪造新命令完成。结合原准备令牌准入短回归复现旧行为、验证修复后的本地拒绝与后继合法行，保留零新下层接受/零W-AUX启动约束；无需冷W或重跑旧长链。若上层迁移直接吸收该准入分支，可在最终生产入口统一修复，但保留可执行父core路径的同样语义。

上层owner迁移独立继续，不等此局部问题另一次批准。完成128循环/16行错误归并与source/norm状态集中后，再建立真正独立stage和完整16行成本pilot；不要在每次寄存器移动后重复完整重父图。新的受影响证据按新SHA记录，原首行前缀不自动迁移。阶段内普通修复合并到既有design/results和最终交付，不需确认收信。


[原始消息收据](../../.research-agent/communications/m004-rev20-at331-scoped-bank-check-review-20261016.json)
### m004-rev20-at339-source-norm-io-owner-milestone-20261016

2026-10-15T18:29:04.354956+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-rev20-at331-scoped-bank-check-review-20261016

# 修订20 AT332–339：source/norm I/O 控制迁移中间里程碑

2026-10-16；M004/SM004/E004/R001；A002。沿 D-M004-SOURCE-NORM-OWNER-01 继续实施，不申请新范围或额度。

- AT332对新增上层source/gamma预装端口和FSM作语法检查通过。AT333用空work库展开失败，缺原FP/IP/reader/writer已编译闭包；child1，原失败及3.5612088181078434s保留，不是RTL功能判据。AT334从全部冻结依赖重新编译，生产上层独占gamma/STATE0实际load、1024字有限预检、holding、prep提交和最终load_done排空；wrapper源预装IN_*、原512bit holding与重复写入状态已移除。原真实S128请求row0短例通过1024norm逐位、64笔OKAY B、source64R、gamma256R，153810ns行退休；static163.33853422291577s、RTL50.50575716793537s。
- AT335新norm存储FSM语法通过。AT336同版生产上层直接调度norm同步读128组、writer 64笔B/flush/release；初次遗漏了writer实例的flush_done端口，停在服务SS_FLUSH，120.43694551475346s/-9/timeout为FAIL/COST_STOP，不迁移AT334通过结论。AT337/338用AT336冻结snapshot只读160µs，确认writer本体flush_reported=1、债零、64个OKAY B，而服务侧flush_done为X；两次探针分别51.132399540394545s及49.65121842734516s。
- AT339仅补服务writer.flush_done显式端口，在AT336已编译完整闭包上重编改动源并重新展开。原父请求row0短例再次通过1024norm、64B、source64R/gamma256R、153810ns行退休；static155.48307084850967s、RTL50.92607934400439s。AT336失败和探针不回写。
- 截至AT339，AT326–339精确guard累计static **1183.5299725364893745/1800s**、RTL **589.942395463585853/3600s**；余static616.4700274635106255s（其中原合同400s最终父top计划空间保留）、RTL3010.057604536414147s；host完整累计UNKNOWN。守卫无内存/政策触发，AT336仅120s仿真帽。

当前只签所测生产共享实例的row0源预装和norm写回控制。128行调度/16行store窗口仍在旧sequencer，源描述符由旧父层发起；因此独立stage、完整16行pilot、真实LN128、NORM_STAGE_READY、父图Q16及完整请求均未完成。下步将一次请求锁存、128循环和错误屏障移入同一上层，再建独立stage及同版父入口；按原成本门自动判断LN128，不以本次row0替代。


[原始消息收据](../../.research-agent/communications/m004-rev20-at339-source-norm-io-owner-milestone-20261016.json)
### m004-rev20-at339-scoped-io-owner-review-20261016

2026-10-15T18:33:36.085659+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at339-source-norm-io-owner-milestone-20261016

# 修订20阶段内进展与受影响问题

## 当前AT332–339：source/norm I/O迁移局部接纳，剩余控制集中完成

2026-10-16；A001→A002；回复`m004-rev20-at339-source-norm-io-owner-milestone-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续；本次不是修订20收束或新合同，不增预算、不封存余额，无确认收信或用户逐项审批事项。

[新增机读审核](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at339_review_20261016.json)986项成立：新增397项frozen、15项fixture、2份只读探针Tcl的SHA及11笔原guard/90条实际政策匹配；复用AT331已核773项和12guard/100政策。累计23guard/190政策。static1183.5299725364893745/1800s、RTL589.942395463585853/3600s；余616.4700274635106255s/3010.057604536414147s，host完整UNKNOWN。

限定接纳AT334上层source/gamma预装及AT339上层source+norm写回的真实S128请求row0。AT339实际身份是AT336冻结完整闭包加新上层6721c8e4…；wrapper391dd3c1…、core452deb9c…、下层f63e25e2…、sequencera4c999e5…，实际fixture来自AT336/fixture并与AT331逐字相同。AT339只补`.flush_done(writer_flush_done)`，改动源重编及父请求top重新展开成立；原writer/reader/叶子和下层/core未改。两次正常终标均在153810ns，1024norm在真实W握手及最终内存逐位、64个OKAY B、source64R/gamma256R和单行覆盖成立，不签后继行或错误分支。

AT333为空work缺依赖的编译失败；AT336原120.43694551475346s timeout/-9保留FAIL/COST_STOP，不能记为数值FAIL或PASS。AT337/338是在旧AT336 snapshot运行到160us后的只读诊断，writer已64B、债零且flush_reported=1，服务flush_done为X；不是两个成功功能测试。AT339修复限定闭合这一本地连接缺口，不迁移AT334或其它版本的未测结论。

剩余归属须按原合同一次完成：staged请求描述符验证/锁存、128循环/16行store错误归并，以及当前仍由父层驱动的准入、IN_CORE_CMD/Q_DONE、身份/完整Check、row_done/覆盖事件和release/discard代理。当前上层拥有预装和norm读写FSM，但仍接父层逐行start/done等控制；因此独立stage、真实16行/LN128及NORM_STAGE_READY仍NOT_RUN。不能只移动循环并让TB补命令、完整Check或债零。

执行顺序收紧到原合同要求：**先完成全部剩余控制迁移，再用同版独立生产stage快速构建/短测，最后统一构建真实父请求top。停止以每组内部迁移为单位重复完整重父图。** 400s最终父top静态计划仍保留，因此截至AT339其余构建可用216.4700274635106255s；每次启动按原guard重新扣账，计划成本不能替代实耗或自动动用预留。普通修复在帽内继续；若该空间不足，交确切实现/验证缺口，不借旧余额或自动开新修订。

原错误/反压/页界/在途共同reset及交接回归继续合并；AT330错误done真实消费→重新准备→无reset合法后继仍须纳入迁移后恢复短例。保留128同步norm响应、64笔成功B、flush撤下、pending/rsp与真实债零、下层release/done消费后才置位；writer错误路径按真债排空，不能等待成功flush脉冲。只有同版完整16行及原成本门成立才自动LN128，row0不能替代。请在集中交付时把AT332以后的增量构建闭包/探针引用、失败与精确费用并入原机读账，不回写旧证据。

## 历史AT328–331：固定bank移位与Check来源局部修复

2026-10-16；A001→A002；回复`m004-rev20-at331-bank-extract-local-check-milestone-20261016`。修订20仍按D-M004-SOURCE-NORM-OWNER-01实施；本次限定接纳，不封账、不增预算或新修订。

[新增机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at331_review_20261016.json)1878项成立：AT326–331累计749项frozen＋24项fixture＝773项、12笔原guard/100条实际政策一致。static713.91580555960536s、RTL267.289995469152928s；截至AT331余1086.08419444039464s/3332.710004530847072s，后续费用继续加入，host完整UNKNOWN。

物理抽取按原合同的固定接线落地接纳：下层f63e25e2…相对AT327仅前置151信号声明的interface，`laya_lnq_bank_service_v1`模块本体逐字节相同；151项原端口方向/宽度、原core表达式→engine连续赋值、上层→bank连接全部核对一致。interface无always/assign/initial/仲裁或存储。当前父wrapper实际例化engine和上层，展开日志包含engine而无旧名兼容壳；上层只例化一份物理bank服务。因此签所测层次的唯一LNQ/bank和固定接线，不将其升级为全部legacy算术或物理综合结果。新bank link只是固定端口集合，后续不得加通用队列/仲裁/额外读拍来迁移控制。

`REV20-LOCAL-REJECT-CHECK`更新为**CLOSED_SCOPED_REPRO_AND_CHECK_FIX**：AT329旧AT327结构下，真实零raw/单位gamma的LN成功消费后，同身份缺token拒绝确实得到status7但旧Check=0，原终标只表示bug复现；AT330采用兼容壳＋修复engine，`staged_ln_delegated`仅在本次真实上下层同时接受时锁存，本地拒绝返回op10/status7/detail07100005/bad64全1，零新增下层接受、全程零W/AUX ARVALID。三拍保持实际检查done_valid、check_status及detail；其余定义字段在诊断点检查。两次不是相同整个DUT身份的纯单变量A/B；源差异、机械接线与各自真实结果分别保留。AT331与AT330同修复engine在真实父S128请求入口的正常row0终标、1024norm/64B/source64R/gamma256R接纳，不能代签其它Check分支。

覆盖待补：AT330在错误done保持后直接finish，未消费该错误done并运行第三条合法命令；AT331是另一次仿真，不能替代同runtime无reset继续。将“错误done真实消费→重新准备→合法下一命令”的检查合并到迁移后受影响的恢复短例，不为此单独重建/重跑AT329/330旧快照，也不阻塞上层迁移。原正常数据、原错误反例和费用不回写。

下一关键路径不变：一次请求描述符锁存、128循环、16行store错误归并、IN_*和norm同步读写/退休控制迁入现上层；固定请求父top只代理。原sequencer/wrapper仍驱动这些状态，因此独立stage/真实16行/LN128仍NOT_RUN。优先完成控制归属与快速独立stage构建，不在每次内部移动后重复重父top；保留400s最终父top静态计划空间。只有同版完整16行与原成本门成立后才自动LN128，无新审批或确认收信事项。

## 历史AT326–327审核与当时静态问题

2026-10-16；A001→A002；M004/SM004/E004/R001。回复`m004-rev20-at327-lower-check-parent-row0-partial-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续，本条不新增修订、预算或放行停点，修订20仍实施中。

## AT326–327限定核验

[主控机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_progress_review_20261016.json)585项成立：247项冻结源码、14份实际fixture与原来源匹配，四笔原guard/33条政策一致。AT326下层418deefe…完整Check的非法tile样本，以及原两种保存norm的Q16最终4352字复扫/512响应、占有恢复与固定bank客户局部接纳；不签所有Check异常分支。

AT327 core8d78fa81…、wrappera5cec9ba…、上层589ff375…、原sequencera4c999e5…真实展开，TB实际实例化S128请求top并只接受一次请求。首行终标前检查1024norm实际写回及内存复扫、64B、source64R/gamma256R、仅一位norm覆盖，未提前request_done/RAW/FINAL/stage ready；明确`STAGED_LN_ROW0_PREFIX_PASS`后立即finish。因此这里source64可签**终点全次计数**，与旧固定时间quit的口径不同。该版本的128推进/16行store错屏障和IN_*/norm写回控制仍在旧父层，不能签上层独立归属或真实16/LN128完成。

截至AT327原guard精确十进制合计static176.18135055713355s、RTL79.645975802093744s；余1623.81864944286645s/3520.354024197906256s，后继费用继续加入。消息RTL末位差为浮点汇总取舍，阶段最终机读账请直接按各guard十进制字符串求和；不改原收据、不为此重跑。保留原400s最终父top静态计划空间，host完整UNKNOWN。

## REV20-LOCAL-REJECT-CHECK：静态风险，原合同内复现修复

冻结AT326/327 `laya_lnq_wi_gqdown_row_v1.sv` 的Check输出仅按`exec_mode==001`选择下层Check，再以id/row/epoch/exec判断回显身份。父core自身拒绝LN_ONLY命令时同样会锁存exec001并直接DONE，但没有新的下层命令。

具体静态见证：成功LN_ONLY行的done已消费后，重复相同id/row/epoch但缺prep token。父core仍可接受命令并由`!prepared_match`拒绝为status7/phase14；下层未接受本次命令，保留上次status0/detail0且身份恰好相等，故`staged_ln_identity_bad`为假，当前mux可输出check_status16=0/detail0，与父done_status7矛盾。此为源码推导，**尚未RTL复现**，不改写AT326非法tile或AT327正常前缀PASS。

请在本修订原帽内把“本次命令确实进入下层并退休”的来源归属纳入Check选择/锁存；父本地拒绝必须输出原op10/status7/detail07100005/bad64全1，并在阻塞到消费期间保持。不能仅靠mode或可能复用的身份判断来源，也不能清下层历史结果来伪造新命令完成。结合原准备令牌准入短回归复现旧行为、验证修复后的本地拒绝与后继合法行，保留零新下层接受/零W-AUX启动约束；无需冷W或重跑旧长链。若上层迁移直接吸收该准入分支，可在最终生产入口统一修复，但保留可执行父core路径的同样语义。

上层owner迁移独立继续，不等此局部问题另一次批准。完成128循环/16行错误归并与source/norm状态集中后，再建立真正独立stage和完整16行成本pilot；不要在每次寄存器移动后重复完整重父图。新的受影响证据按新SHA记录，原首行前缀不自动迁移。阶段内普通修复合并到既有design/results和最终交付，不需确认收信。


[原始消息收据](../../.research-agent/communications/m004-rev20-at339-scoped-io-owner-review-20261016.json)
### m004-rev20-at343-true-ln128-parent-row0-milestone-20261016

2026-10-15T18:58:32.620944+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev20-at339-scoped-io-owner-review-20261016

# SM004 修订20 AT340–343：上层单一循环与真实 LN128 阶段里程碑

2026-10-16；A002；M004/SM004/E002/E004/R001。按 D-M004-SOURCE-NORM-OWNER-01 连续实施；本报告是阶段证据，M004/SM004 未验收收束。

生产上层 `laya_source_norm_service_v1` 现锁存一次 staged 请求的 id/epoch/model/numeric、STATE0/AUX/STATE1 base/span，验证范围与 source/destination 全域隔离，单一 FSM 顺序完成 gamma 预检、128 行 raw 预装、LN_ONLY、同步 norm 读、单 writer 64B 写回、flush/release/done 与 16 行 store 错误屏障。下层仍唯一拥有 LNQ/8×656×32bit bank、prep/token、回放和视图；父 wrapper 的 staged 分支只启动一次上层请求并代理 Check，父 sequencer 不再逐行命令或合并 store 错误。legacy 分支仍走原 core。没有新增 bank、LNQ、reader/writer 或算术叶子。

**最终冻结身份**：[AT343 manifest](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01/source_manifest.json) 为 130 个 frozen 文件及 5 个实际 fixture；上层 `58086436d06c285e1653ce10e06233f19557a318b7b9335f3006140e2b7ed919`、下层 `f63e25e243ccd1bc264971fcbe5a1cd17b13eff472773722d001b503c287e043`、core `452deb9cea5630bec1cb922365a4f6615a9635d93e86dce26f24b298ecc1a94a`、wrapper `b1b73970625200556514bd04d14a3b19411dbfe6921a81cf46ac01969699275a`、sequencer `8b9261e03f58b088c9ace10be4ac7206c009c02c62529a21c741415186d0a9f1`。编译库沿 AT336→AT340→AT341→AT342→AT343，AT343 重新编译全部受影响生产源和两 TB、实际分别展开独立 stage 与完整父请求 top；原 FP/IP、reader、writer、gold 字节未改。

- [AT343 static](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01/guard_static/guard_result.json) child0/null，191.1815157365054s；两份 snapshot 均成功展开。
- [AT343 独立16行 pilot](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01/guard_rtl_16/guard_result.json) child0/null，36.70097006671131s，16384 norm 逐位、1024 source R/1024 OKAY B、gamma256 R、16 唯一退休，前缀最终内存复扫通过。保守 LN128 估计 36.70097006671131×8×2.5＝734.0194013342262s，满足≤1440s及1800s单次/剩余总额条件。
- [AT343 独立真实 LN128](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01/guard_rtl_full128/guard_result.json) child0/null，252.2839319705963s；原TB终标 `STAGED_LN128_REAL_PASS`。8192 source R、8192 OKAY B、gamma256 R；128位覆盖、131072个 norm 在真实 W 和最终内存逐位，末笔 B 后实际退休与 `NORM_STAGE_READY` 成立。独立 TB 只实例化同版上层＋唯一下层及 AXI peer，未以保存 norm 替换生产计算。
- [AT343 同版真实父请求 row0](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT343_SM004_rev20_final_shared_stage_parent_build_01/guard_rtl_parent_row0/guard_result.json) child0/null，49.062415182590485s；一次 S128 请求由上层自动完成 row0，1024 norm 逐位、64 OKAY B、source64 R、gamma256 R，仅 row0 覆盖。前缀终标前 request_done/RAW/FINAL/stage ready 均未提前发布；这是完整父 top 的**单行前缀**，不签父 top 的完整128行同 runtime。

AT340 首次语法编译因 `stage_store_discard_q` 声明次序失败，1.8286761827766895s/child1；AT341 修正声明后语法通过，1.8709861636161804s。AT342 旧于最终地址隔离修复的独立16/128 PASS（36.19439060240984s/249.0825647599995s）按旧 SHA 保留，不迁移；AT343 同版重新完成。自 AT339 至本里程碑，修订20精确原guard账 static **1413.8123060390353384/1800s**、RTL **1213.266668045893288/3600s**，余额 386.1876939609646616s/2386.733331954106712s；host完整累计 UNKNOWN。费用含失败、旧版复验及构建，原guard不回写。

**仍待受影响验证：** 当前上层的 source晚RRESP/gamma load_done 错、末B错后原16行窗口继续/discard与无reset新epoch恢复；有限 AR/R/AW/W/B 停顿、4KiB页界、pending/rsp及末B持有切相位、在途共同reset后510拍隔离；AT330本地拒绝错误done消费→合法后继。独立 LN128 PASS 不证明父 top 完整128行、Q16父图、STEP16/matrix、全RoPE/FINAL→Attention、完整Encoder/模型、全请求首错等价或Host/HBM/联合资源/Fmax。下一最小可执行边界是同一生产stage的定向错误/复位短例及父层受影响恢复；普通修复继续原预算。


[原始消息收据](../../.research-agent/communications/m004-rev20-at343-true-ln128-parent-row0-milestone-20261016.json)
### m004-rev20-at343-scoped-ln128-acceptance-20261016

2026-10-15T19:04:17.003452+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at343-true-ln128-parent-row0-milestone-20261016

# 修订20阶段内进展与受影响问题

## 当前AT340–343：真实独立LN128正常链接纳，受影响回归继续

2026-10-16；A001→A002；回复`m004-rev20-at343-true-ln128-parent-row0-milestone-20261016`。本次确认正常路径的重要里程碑，修订20仍在原合同内实施，M004/SM004 running/unassessed；不收束、不另开修订或追加额度。

[主控增量核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at343_review_20261016.json)434项成立：AT340–342的14项源码SHA、AT343的130项frozen及两组10项实际fixture均匹配，新增9guard/55实际政策一致，累计32guard/245政策。AT343依赖闭包相对AT336有124项不变、4份改变源码和2份新增文件；改变的上层/wrapper/sequencer/父TB及新增独立TB均在最终构建中重编，两个snapshot实际展开。上层58086436…、下层f63e25e2…、core452deb9c…、wrapperb1b73970…、sequencer8b9261e0…为本次接纳身份；实际fixture与已核AT336字节一致。AT340声明次序失败及AT342旧SHA结果/成本保持原样。

正常路径单一owner落地接纳：上层锁存一次staged请求，内部驱动128行、预装、下层LN_ONLY/同步norm读写/退休、覆盖及store错误窗口状态；父sequencer staged分支不再逐行发射或归并store错，wrapper只代理请求与完整Check。独立TB只实例化同版上层（内含唯一下层）和真实AXI peer，raw/gamma从冻结输入喂入，norm_gold仅作W握手与最终内存checker；没有保存norm替代计算或TB逐行命令。外部legacy bank_idle常量仅声明闲置客户，下层实际staged/量化/token/pending/rsp门控仍在生产逻辑中，不代签交接/错误情形。

AT343同版16行pilot36.70097006671131s，16384norm、1024sourceR/1024OKAY B、gamma256R及前16位覆盖通过；保守估计734.0194013342262s满足原≤1440s门槛，启动前RTL余额足够1800s。随后真实独立LN128在252.2839319705963s完成，原唯一终标、128覆盖/退休计数、131072个真实W数据与最终内存逐位、8192sourceR/8192OKAY B、gamma256R及NORM_STAGE_READY接纳。日志逐行记录只有0..126，末行在negedge终标前的全量计数/覆盖/内存断言验证后立即finish，不虚称128条逐行日志。16行同理为15条逐行日志加最终第16行检查。

AT343同版真实父S128请求row0在49.062415182590485s通过，153820ns明确终标，1024norm/64B/source64R/gamma256R，仅row0覆盖并核真实request_done/RAW/FINAL/stage ready未提前发布。独立TB不存在这些完整请求发布口，其占位常量检查不能作为发布行为证据；独立LN128不代签父top全128同runtime、后继Q16/matrix/RoPE/FINAL→Attention或整模/物理性能。此次成本说明独立生产验证层可在帽内完成LN128，不是硬件吞吐或父重图仿真加速比。分段单调墙钟profile未提供，完整guard实耗和同版pilot足以支持本次成本门。

精确原账static1413.8123060390353384/1800s、RTL1213.266668045893288/3600s，余386.1876939609646616s/2386.733331954106712s，host完整UNKNOWN。原400s为最终同版父图构建/修正计划空间，AT343已使用其中的实际构建工作；现不再机械要求未用余额仍≥400s。剩余原预算用于受影响短回归及必要重编，所有失败与增量闭包继续并入同一机读账，不借旧余额、不自动延帽。

工程继续原定source晚RRESP/gamma load_done错的真排空、错误done保持/消费、显式discard与新epoch恢复；norm末B错后禁止新增写、按当前16行窗口继续真实LN并正确discard，保存store错与后续数值Check的优先；AR/R/AW/W/B有限停顿、页界、pending/rsp/末B阻塞交接、真在途共同reset510拍与恢复。新迁入的范围/id溢出/源目的重叠拒绝必须保持零新AR/零LN，并核完整Check；结合原准入回归即可，不另建长例。AT330本地拒绝错误done消费→重新准备→无reset合法后继仍按原要求补齐。

不重跑未改变的AT343正常长例。生产修复若改变SHA，旧完整LN128只属于本次冻结身份；工程按实际受影响范围补同版证据并在集中交付明确未覆盖项。正常路径接纳不关闭尚未实测的错误/复位/全请求异常优先级。无需确认收信，继续原帽内实施与集中交付。

## 历史AT332–339：source/norm I/O迁移局部接纳，剩余控制集中完成

2026-10-16；A001→A002；回复`m004-rev20-at339-source-norm-io-owner-milestone-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续；本次不是修订20收束或新合同，不增预算、不封存余额，无确认收信或用户逐项审批事项。

[新增机读审核](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at339_review_20261016.json)986项成立：新增397项frozen、15项fixture、2份只读探针Tcl的SHA及11笔原guard/90条实际政策匹配；复用AT331已核773项和12guard/100政策。累计23guard/190政策。static1183.5299725364893745/1800s、RTL589.942395463585853/3600s；余616.4700274635106255s/3010.057604536414147s，host完整UNKNOWN。

限定接纳AT334上层source/gamma预装及AT339上层source+norm写回的真实S128请求row0。AT339实际身份是AT336冻结完整闭包加新上层6721c8e4…；wrapper391dd3c1…、core452deb9c…、下层f63e25e2…、sequencera4c999e5…，实际fixture来自AT336/fixture并与AT331逐字相同。AT339只补`.flush_done(writer_flush_done)`，改动源重编及父请求top重新展开成立；原writer/reader/叶子和下层/core未改。两次正常终标均在153810ns，1024norm在真实W握手及最终内存逐位、64个OKAY B、source64R/gamma256R和单行覆盖成立，不签后继行或错误分支。

AT333为空work缺依赖的编译失败；AT336原120.43694551475346s timeout/-9保留FAIL/COST_STOP，不能记为数值FAIL或PASS。AT337/338是在旧AT336 snapshot运行到160us后的只读诊断，writer已64B、债零且flush_reported=1，服务flush_done为X；不是两个成功功能测试。AT339修复限定闭合这一本地连接缺口，不迁移AT334或其它版本的未测结论。

剩余归属须按原合同一次完成：staged请求描述符验证/锁存、128循环/16行store错误归并，以及当前仍由父层驱动的准入、IN_CORE_CMD/Q_DONE、身份/完整Check、row_done/覆盖事件和release/discard代理。当前上层拥有预装和norm读写FSM，但仍接父层逐行start/done等控制；因此独立stage、真实16行/LN128及NORM_STAGE_READY仍NOT_RUN。不能只移动循环并让TB补命令、完整Check或债零。

执行顺序收紧到原合同要求：**先完成全部剩余控制迁移，再用同版独立生产stage快速构建/短测，最后统一构建真实父请求top。停止以每组内部迁移为单位重复完整重父图。** 400s最终父top静态计划仍保留，因此截至AT339其余构建可用216.4700274635106255s；每次启动按原guard重新扣账，计划成本不能替代实耗或自动动用预留。普通修复在帽内继续；若该空间不足，交确切实现/验证缺口，不借旧余额或自动开新修订。

原错误/反压/页界/在途共同reset及交接回归继续合并；AT330错误done真实消费→重新准备→无reset合法后继仍须纳入迁移后恢复短例。保留128同步norm响应、64笔成功B、flush撤下、pending/rsp与真实债零、下层release/done消费后才置位；writer错误路径按真债排空，不能等待成功flush脉冲。只有同版完整16行及原成本门成立才自动LN128，row0不能替代。请在集中交付时把AT332以后的增量构建闭包/探针引用、失败与精确费用并入原机读账，不回写旧证据。

## 历史AT328–331：固定bank移位与Check来源局部修复

2026-10-16；A001→A002；回复`m004-rev20-at331-bank-extract-local-check-milestone-20261016`。修订20仍按D-M004-SOURCE-NORM-OWNER-01实施；本次限定接纳，不封账、不增预算或新修订。

[新增机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at331_review_20261016.json)1878项成立：AT326–331累计749项frozen＋24项fixture＝773项、12笔原guard/100条实际政策一致。static713.91580555960536s、RTL267.289995469152928s；截至AT331余1086.08419444039464s/3332.710004530847072s，后续费用继续加入，host完整UNKNOWN。

物理抽取按原合同的固定接线落地接纳：下层f63e25e2…相对AT327仅前置151信号声明的interface，`laya_lnq_bank_service_v1`模块本体逐字节相同；151项原端口方向/宽度、原core表达式→engine连续赋值、上层→bank连接全部核对一致。interface无always/assign/initial/仲裁或存储。当前父wrapper实际例化engine和上层，展开日志包含engine而无旧名兼容壳；上层只例化一份物理bank服务。因此签所测层次的唯一LNQ/bank和固定接线，不将其升级为全部legacy算术或物理综合结果。新bank link只是固定端口集合，后续不得加通用队列/仲裁/额外读拍来迁移控制。

`REV20-LOCAL-REJECT-CHECK`更新为**CLOSED_SCOPED_REPRO_AND_CHECK_FIX**：AT329旧AT327结构下，真实零raw/单位gamma的LN成功消费后，同身份缺token拒绝确实得到status7但旧Check=0，原终标只表示bug复现；AT330采用兼容壳＋修复engine，`staged_ln_delegated`仅在本次真实上下层同时接受时锁存，本地拒绝返回op10/status7/detail07100005/bad64全1，零新增下层接受、全程零W/AUX ARVALID。三拍保持实际检查done_valid、check_status及detail；其余定义字段在诊断点检查。两次不是相同整个DUT身份的纯单变量A/B；源差异、机械接线与各自真实结果分别保留。AT331与AT330同修复engine在真实父S128请求入口的正常row0终标、1024norm/64B/source64R/gamma256R接纳，不能代签其它Check分支。

覆盖待补：AT330在错误done保持后直接finish，未消费该错误done并运行第三条合法命令；AT331是另一次仿真，不能替代同runtime无reset继续。将“错误done真实消费→重新准备→合法下一命令”的检查合并到迁移后受影响的恢复短例，不为此单独重建/重跑AT329/330旧快照，也不阻塞上层迁移。原正常数据、原错误反例和费用不回写。

下一关键路径不变：一次请求描述符锁存、128循环、16行store错误归并、IN_*和norm同步读写/退休控制迁入现上层；固定请求父top只代理。原sequencer/wrapper仍驱动这些状态，因此独立stage/真实16行/LN128仍NOT_RUN。优先完成控制归属与快速独立stage构建，不在每次内部移动后重复重父top；保留400s最终父top静态计划空间。只有同版完整16行与原成本门成立后才自动LN128，无新审批或确认收信事项。

## 历史AT326–327审核与当时静态问题

2026-10-16；A001→A002；M004/SM004/E004/R001。回复`m004-rev20-at327-lower-check-parent-row0-partial-20261016`。沿D-M004-SOURCE-NORM-OWNER-01继续，本条不新增修订、预算或放行停点，修订20仍实施中。

## AT326–327限定核验

[主控机读核验](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_progress_review_20261016.json)585项成立：247项冻结源码、14份实际fixture与原来源匹配，四笔原guard/33条政策一致。AT326下层418deefe…完整Check的非法tile样本，以及原两种保存norm的Q16最终4352字复扫/512响应、占有恢复与固定bank客户局部接纳；不签所有Check异常分支。

AT327 core8d78fa81…、wrappera5cec9ba…、上层589ff375…、原sequencera4c999e5…真实展开，TB实际实例化S128请求top并只接受一次请求。首行终标前检查1024norm实际写回及内存复扫、64B、source64R/gamma256R、仅一位norm覆盖，未提前request_done/RAW/FINAL/stage ready；明确`STAGED_LN_ROW0_PREFIX_PASS`后立即finish。因此这里source64可签**终点全次计数**，与旧固定时间quit的口径不同。该版本的128推进/16行store错屏障和IN_*/norm写回控制仍在旧父层，不能签上层独立归属或真实16/LN128完成。

截至AT327原guard精确十进制合计static176.18135055713355s、RTL79.645975802093744s；余1623.81864944286645s/3520.354024197906256s，后继费用继续加入。消息RTL末位差为浮点汇总取舍，阶段最终机读账请直接按各guard十进制字符串求和；不改原收据、不为此重跑。保留原400s最终父top静态计划空间，host完整UNKNOWN。

## REV20-LOCAL-REJECT-CHECK：静态风险，原合同内复现修复

冻结AT326/327 `laya_lnq_wi_gqdown_row_v1.sv` 的Check输出仅按`exec_mode==001`选择下层Check，再以id/row/epoch/exec判断回显身份。父core自身拒绝LN_ONLY命令时同样会锁存exec001并直接DONE，但没有新的下层命令。

具体静态见证：成功LN_ONLY行的done已消费后，重复相同id/row/epoch但缺prep token。父core仍可接受命令并由`!prepared_match`拒绝为status7/phase14；下层未接受本次命令，保留上次status0/detail0且身份恰好相等，故`staged_ln_identity_bad`为假，当前mux可输出check_status16=0/detail0，与父done_status7矛盾。此为源码推导，**尚未RTL复现**，不改写AT326非法tile或AT327正常前缀PASS。

请在本修订原帽内把“本次命令确实进入下层并退休”的来源归属纳入Check选择/锁存；父本地拒绝必须输出原op10/status7/detail07100005/bad64全1，并在阻塞到消费期间保持。不能仅靠mode或可能复用的身份判断来源，也不能清下层历史结果来伪造新命令完成。结合原准备令牌准入短回归复现旧行为、验证修复后的本地拒绝与后继合法行，保留零新下层接受/零W-AUX启动约束；无需冷W或重跑旧长链。若上层迁移直接吸收该准入分支，可在最终生产入口统一修复，但保留可执行父core路径的同样语义。

上层owner迁移独立继续，不等此局部问题另一次批准。完成128循环/16行错误归并与source/norm状态集中后，再建立真正独立stage和完整16行成本pilot；不要在每次寄存器移动后重复完整重父图。新的受影响证据按新SHA记录，原首行前缀不自动迁移。阶段内普通修复合并到既有design/results和最终交付，不需确认收信。


[原始消息收据](../../.research-agent/communications/m004-rev20-at343-scoped-ln128-acceptance-20261016.json)
### m004-rev20-at351-engineering-stage-cost-handoff-20261016

2026-10-15T19:21:29.797890+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-rev20-at343-scoped-ln128-acceptance-20261016

# 修订20 AT351 阶段成本出口，请主控集中审核

回复 `m004-rev20-at343-scoped-ln128-acceptance-20261016`；A002→A001；M004/SM004/E004/R001。原合同内 AT343 的同版独立真实LN128（131072norm、8192 sourceR/B、128覆盖与NORM_STAGE_READY）及父请求row0前缀保持主控已限定接纳身份，生产RTL/FP/IP/reader/writer未改。

新增同版受影响短例：AT344真实晚source RRESP与末B故障排债、16行store窗口、显式release及新epoch row0恢复PASS；AT345跨4KiB页界与AR/R/AW/W/B有限停顿PASS；AT346 gamma非有限前检/内部abort/新epoch恢复PASS；AT349非法span、ID溢出、源目的重叠零AR/零LN拒绝完整Check及后继合法row0 PASS；AT350 gamma预装8R在途共同reset、510拍隔离和新行恢复PASS。AT345 gamma、AT347/348是保留的TB Fatal，不能拿exit0代替通过。

AT351父core本地拒绝错误done消费→重新prep→第三合法命令增强TB冻结，但旧core重图`xelab`80.31880732811987s/-9/timeout，无snapshot/RTL；故该覆盖COST_STOP。49笔原guard/356政策样本逐笔一致，static **1798.4354466479271734/1800s**，RTL **1323.850544061511735/3600s**；static余1.5645533520728266s不足新展开，旧修订余额不转，host完整UNKNOWN。修订20按原成本出口交付，M004/SM004仍running/unassessed。

[阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_AT351_engineering_stage_handoff_20261016.md)、[机读逐笔账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_guard_ledger_AT326_AT351_20261016.json)、[新增冻结身份](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev20_AT344_AT351_incremental_identity_20261016.json)及E002 design/results、E004三摘要已更新。尚未实测完整父top128行同runtime、gamma load_done错、store错后数值Check优先、bank pending/rsp或末B受阻到legacy换路、LN/回放在途reset；Q16父图/STEP16/matrix/全RoPE/FINAL→Attention、完整模型与Host/HBM/联合物理均开放。请按原角色集中审核并下达下一可实施的有界接口与独立预算；无需用户转发或逐项确认。


[原始消息收据](../../.research-agent/communications/m004-rev20-at351-engineering-stage-cost-handoff-20261016.json)
### m004-rev20-at351-scoped-cost-closeout-20261016

2026-10-15T19:27:41.218542+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at351-engineering-stage-cost-handoff-20261016

# 修订20 AT326–351分版审核与成本出口

2026-10-16；D-M004-REV20-CLOSEOUT-01；A001→A002；回复`m004-rev20-at351-engineering-stage-cost-handoff-20261016`，同时纳入`m004-rev20-at351-check-scope-correction-20261016`。修订20按已实现正常链和限定回归收束，未完成覆盖保留；M004/SM004继续running/unassessed。本决定不等于完整上层生命周期或整模通过。

[主控机读审核](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at351_review_20261016.json)701项成立：新增17份冻结TB/脚本和35份fixture逐SHA匹配、实际读取路径及AT343输入绑定成立；49笔原guard与356条实际CPU0–3/nice19/idle政策逐项匹配，累计费用与AT343 checkpoint一致。原Fatal、构建失败与timeout全部保留，exit0不覆盖Fatal。AT343生产RTL/FP/IP/reader/writer身份不变，后继成功短例复用其编译闭包，仅重编冻结TB。

## 接纳范围

- 保留AT343最终上层58086436…真实独立LN128正常PASS：131072norm在W握手及最终内存逐位、8192sourceR/8192OKAY B、gamma256R、128覆盖及NORM_STAGE_READY；同版父请求只签row0。独立LN128252.283932s是验证运行成本，非硬件加速结论。
- AT344晚source最后RRESP错，64R排完后零norm/B并一次报错；末B错误样本完成当前16行真实LN、16384个norm产生事件、1024sourceR、64个B（含最后一个错误响应，不能称64个OKAY B）、15行受控discard、零成功行覆盖。后续没有新增写，最终返回保存的store错误。此例未注入后续数值故障，不签store/numeric竞争优先。
- AT345 STATE0页尾分成2AR/64R，AR/AW/W持稳、R返回间隙与B延迟、末B前禁止norm位发布，最终row0真实1024norm/64B通过。只签所测路由与停顿，不签pending/rsp或末B到legacy切相位。
- AT346 gamma[0]非有限前检读满256AUX R、零source/norm/B、内部abort及后继正常row0接纳；不是gamma总线load_done/RRESP错误。AT345原gamma Fatal保留。
- AT349非法span、id溢出和源目的重叠零AR/零LN/W拒绝及合法后继row0接纳。按更正，只签done_id、op、status、phase、detail、bad64的明确断言；bad_element与回显row未断言。ready常1使完成被消费，三拍后再检查status/detail端点值，不签valid阻塞保持、逐拍全部字段稳定或完整Check。AT347/348原TB Fatal保留。
- AT350真实gamma预装8R、prep活动时共同reset，DUT/peer同步清事务，510拍隔离和后继正常row0接纳。未到LN/回放阶段，不签该在途窗口或独立AXI reset。

上述错误恢复是**独立stage局部协议**：TB合法驱动stage_release_fire与prep_abort_valid，之后epoch=2正常row0；未经过父wrapper/sequencer的tensor_release准入、e/e+1/e+2策略或后继完整请求。因此不以这些PASS填补父层生命周期证据。AT344/346的错误字段检查同样按实际断言范围保留，不泛称全部Check分支。

AT351增强父core TB已冻结，但80.31880732811987s静态timeout/-9，没有snapshot或RTL；本地拒绝错误done消费→重新准备→第三合法命令保持COST_STOP/未验证。原AT330局部拒绝Check修复结论不改。

## 成本出口与后继

精确累计static1798.4354466479271734/1800s、RTL1323.850544061511735/3600s；剩余static1.5645533520728266s、RTL2276.149455938488265s封存，不转入下一修订、不由RTL余量补静态额度。host完整UNKNOWN。工程不续跑修订20的重工具；这属于成本出口，不是目标完成或方法失败。

下一工程段按同一M004连续安排独立预算，优先把真实LN128后的固定相位交接和W准备/Q16数据链做成可执行边界；原研究会话正在核现端口、W先于Q顺序与可用独立参考。未测的gamma load_done错、store/numeric优先、bank/末B切相位、LN/回放在途reset及父core后继按受影响边界合并，不把所有历史缺口一概列作完整计算推进前置，也不暗记PASS。未改变的AT343长正常基线不重跑；必要生产修复保留各SHA的证据适用范围。

完整父图128同runtime、Q16父图、STEP16/matrix、全RoPE/FINAL→Attention、旧整模首错等价、Encoder/模型、Host/HBM/物理BO、联合资源/Fmax仍开放。此处不授权HLS/OOC/P&R、新gold或新agent。无需确认收信或用户逐项审批。


[原始消息收据](../../.research-agent/communications/m004-rev20-at351-scoped-cost-closeout-20261016.json)
### m004-rev20-closeout-rev21-ln128-wprep-q16-dispatch-20261016

2026-10-15T19:37:41.239614+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev20-at351-engineering-stage-cost-handoff-20261016

# 修订21：真实LN128→W准备→STATE1首Q16窗口

2026-10-16；D-M004-LN128-WPREP-Q16-01；A001→A002；M004/SM004/E004/R001。承接[修订20成本出口](../../results/m004_simplified_start_20261014/source_norm_owner_rev20_at351_closeout_decision.md)和A003的`m004-ln128-q16-next-interface-answer-20261016`。本段在现生产共享服务上连接下一段计算，出口为真实首A16窗口保持，不接矩阵或RoPE。工程按以下独立预算连续实施、修复与验证，无用户逐项审批。

## 起点、归属与采用的静态依据

起点为AT343最终上层58086436…、下层f63e25e2…、core452deb9c…、wrapperb1b73970…、sequencer8b9261e0…。修订20已按局部范围结束，旧余static1.5645533520728266s/RTL2276.149455938488265s封存，不转移。当前独立LN128 PASS和父row0只归原冻结身份，新生产变化不自动继承。

采用[架构增量](../../source/fixed_graph_architecture_20261014.md)的固定继续握手、唯一W服务、STATE1读路由和首Q16窗口方案。[主控静态核验](../../results/m004_simplified_start_20261014/ln128_wprep_q16_interface_review_20261016.json)104项成立：六组current/frozen、相关依赖/保存产品、全norm字节与前四行Q输入绑定、16行地址和整数工作量。它是实现依据，不是接口已实现、数值PASS或墙钟上界。研究首次脚本失败与修正计量保留。

A002继续唯一拥有E002生产RTL/TB/design/results及E004原始证据/三摘要；A001维护合同与审核，A003维护source研究。既有各角色还在工作，不回滚他人记录。保留一份LN/Q、一份8×656×32bit bank、原Q/skip存储、唯一现W cache及原reader/writer；可移动实例与固定控制，不能复制或用TB算术替代。原FP/IP、数值顺序、clk/reset/CE不变；无HLS/OOC/P&R、新oracle/gold或新agent。

## 固定实现

1. **保持norm的继续握手。** 在现上层增加一次`stage_continue_valid/ready`，成功SL_HELD→W_SEND/WAIT→NORM_PREP/Q16→A16_HELD。将norm上下文存活与当前LN路由占有分开，不能仅回SL_IDLE开放新请求。原LN-only caller不发continue时行为保持；完整父请求的后继由生产固定阶段代理发起，不由TB逐行驱动。

   continue锁存request/generation、norm_epoch、next_base_id、独立a_epoch和原W描述符；与保留的norm身份匹配，预检新id区间不回绕/不与LN退休区间冲突。全部128 norm覆盖、STATE1 base/span/epoch/model/numeric、tensor占有保持，norm留给后继WO残差。continue不调用tensor_release、prep_abort或清覆盖，也不发布request_done/RAW/FINAL。

   下层导出真实`service_quiescent`：staged/QF/Q16控制空闲，LNQ可收命令且物理债零，无prep活动/token、同步pending/rsp或未消费done；gamma token单独处理。上层还核两reader实际完成、FIFO/holding清空、SP/SS空闲、writer末B及debt_zero、tile/flush撤下、父core无旧done/lease。任一不满足就不接受continue/换路，不以core IDLE或TB常量代替债。

   接受继续时以专用gamma_retire握手清gamma_token_valid，保留诊断身份及外部norm；Q16覆盖w1024..2047后不能留下假有效gamma。该退休须与真实握手绑定、下层quiescent且无A/prep占有。后继需要gamma时重新真实读入。失败保持norm上下文和错误直到显式discard与清债，不把继续当请求释放；原e/e+1/e+2规则不改。

2. **唯一W服务及exec100。** 将原唯一`t4_dual_w_cache_v1`与固定W_PREP命令锁存/LOAD_REQ/WAIT/done保持封为薄生产服务；完整父core实际调用它，legacy LOAD/lease/read/release透传到同一cache。独立阶段也调用同一生产服务，省去无关重算术层次；不得创建第二cache、TB版W控制或模拟成功回执作为主链证据。原slot容量、读拍、无ready返回和legacy行为保持。

   core的`cmd_exec=100`在prepared检查之前单独译码，固定Encoder0 QKV、cold=1、slot0/key0001/K1024/N3072/bias0、空A/prep/读债；prepared_source=0。全LN准入由生产阶段控制保证；本命令不消费prep、不reset结果视图、不发LN/Q/matrix/G/ADD，LOAD成功直接返回W阶段done。011继续明确拒绝。slot0 load_epoch=旧epoch+1且不回绕，slot1不动，numeric绑定在回执保存；后继matrix仍须真正lease。

   锁存原load bundle、128B期望header、id/source/W epoch/key/model/numeric及地址/长度到完成消费。成功必须实际load_done、无错/拒绝、slot0 READY且epoch匹配/readers0、原三口和AUX排净、载荷覆盖完整及98304次scale检查。静态载荷为1572864+1572864+196608B，三口R64计数24576/24576/3072，AUX header为8个R16；实测须逐项核身份、有效字节/数据和覆盖，不能由AR数代签cache完成。W回执成功且被真实消费前，零STATE1 AR/QUANT。

   采用研究指出的错误分类修复：cache保留原合并load_error供legacy，同时分别锁存协议/传输错误和数值错误、原scale_bad_min；不能仅凭bad_element区分混合错误。全载荷取得且无物理/协议错时，scale数值错返回op80/status6/detail0780000f/bad64=n×32+g；物理/标签/header/覆盖错误采用本固定适配status7/detail07800005/bad64全1并保存路由诊断，有此类缺失时不按已观察min声称CPU首错。成功bad64全1。旧全请求异常等价和完整E_MODEL/E_BUFFER ABI继续开放。

3. **STATE1真实读和首16行量化。** 给上层及父层固定接线增加STATE1的512bit AR/R口，现scratch reader扩为STATE0/STATE1/QKV0/QKV1路由，仍只有一个reader/512bit holding。路由在load握手锁存，到load_done、FIFO/holding及真实债清空后才能变；不能借STATE0物理口冒称STATE1。

   复用上层SP_BEGIN/LOAD/WAIT/COMMIT，NORM目的用保留dest_base+r×4096，source epoch为norm epoch，4096B/64R/1024字，prep_kind10写w4224..5247。此阶段不再要求gamma；准入、match与prep_begin_allow按当前选中的NORM/Q16相位译码，禁止live caller改变地址/身份。最后R、offset/epoch/last/bytes、holding空及1024实际写入均成立后才提交token。

   上层固定循环r0..15调用同一下层q16_fill；Q16 source epoch与新增独立cmd_a_epoch分离，窗口绑定norm来源，后15行不换源/A epoch。原partial owner规则保持：只允许兼容kind10/exec010，prep_abort不释放A；Q16覆盖位仅在对应QF成功和真实done消费时一次退休。完整Check含本次id/row/exec/source及A epoch，op20/status6/detail0720000f/bad64按原task-local row×4096+col，协议错保持原协议映射；不得复用旧完成字段。

   保留QF真实消费1024norm、64half/32scale收齐并进入ROW后才EXPORT，再等待原叶子release/done的顺序。r15输入区与导出区交叠w4224..4351共512B，全部输入消费且物理债退完前不得覆盖。全16行成功并完成4352word落bank及Q done消费后进入A16_HELD；不清A、不假装matrix已消费。必要内部同步读视图复用原结果口，地址0..543、E0/E1及阻塞保持不变，不发布legacy结果。

## 验证与数值证据范围

先完成固定实现和接口表，在独立生产组合层稳定后集中重建最终父top，避免每搬一组状态就重建重图。复用未改FP/IP编译闭包，全部改动生产源/TB实际重编展开并冻结；源码、闭包、实际读取的fixture和guard归同账，旧失败保留。

主例实例化同版上/下层及唯一W服务，用真实raw/gamma和AXI存储peer，在同runtime完成LN128→continue→真实W冷载→真实STATE1首16行→A16_HELD。阶段TB可作为合法caller在实际阶段done后提出一次continue；不能预填norm、伪造128覆盖/ready/W完成、逐行发生产调度或force债零。父top应使用同一固定继续接口，而非另建一份循环。

- LN128核131072norm在真实W及最终内存逐位、8192sourceR/成功B、128覆盖与退休。链末复扫STATE1仍等于完整原norm，且W/Q阶段无norm写事务。
- 真W冷载核上述载荷/header/scale覆盖、真实cache及回执身份、先W后STATE1/Q；不拿保存W数据注入cache替代AXI读取。
- 首16行核1024次STATE1 R、16384实际Q输入逐位、1024个Q half/512个scale、768次导出写拍与4352word持有。r0..3全部Q/scale按原独立保存gold逐位；r4..15只有独立norm，核实际Q执行及叶子输出→导出→最终bank逐位传递/覆盖/保持，记录为观察值，不能称独立数值gold或全16行算术gold通过。旧两行交替样本仅保留原局部口径。
- 最终父请求top真实展开，验证exec100/Check/回执/路由及实际Q16委派的受影响短事务；局部可以合法上游上下文peer或保存norm触发，但须明示边界。主例绝不使用这些替身。完整重父top若未从LN128跑到A16仍NOT_RUN；独立主例不能代签它。

优先三组受影响短例：①末B、同步pending/rsp、done未消费时continue不准入，握手后norm上下文保持、gamma真实退休、legacy不抢占；②真实W末R/AUX有限停顿、至少一条实际响应错误、独立scale数值错误及混合错误分类，失败零STATE1 AR/Q，回执阻塞至少3拍逐拍全字段稳定到消费并核错epoch拒绝；③norm末R/最后输入受阻、r15交叠/最终A16复扫、部分窗口错kind/epoch拒绝及真实清债后显式discard。错误恢复必须经过实际生产相应接口，TB直连释放/abort仅签局部，不泛称父请求恢复。

AT351缺口并入本次改动core的局部拒绝done消费→合法后继事务；可使用真实W_PREP合法后继，明确这不自动补签原第三条LN命令。AT349遗漏的bad_element/row若本次测试涉及同完成接口须逐字段核；不只在三拍后抽样。旧gamma load_done、store/numeric、LN在途reset等未被本次实际覆盖的排列继续OPEN，不作为全部推进前置，不以正常主例关闭。受影响的common reset行为须保持，未测窗口明确列出。

## 独立预算、自动主例门槛和出口

修订21新host准备累计300s/8GiB；static/IP累计1800s/24GiB、单次600s；RTL累计3600s/8GiB、单次1800s/40Mcycle。CPU0–3/nice19/idle、MemAvailable>192GiB、全项目一个重工具、120s真实语义停滞保护。所有失败/构建/局部/主例计费，不挪旧封存余额，交互host累计未知如实UNKNOWN。总static内计划保留400s给最终同版父层构建/受影响修正；这是计划空间而非额外额度。

新未知执行路径先固定≤120s pilot，不动态加帽。取得同版实际生产组合层完整LN16前缀，以及真实W服务完整冷载与真实下层完整Q16局部成本样本后，按实耗形成启动依据；局部Q16可用现保存norm经合法接口供数，不能因此签主链。至少用2.5×(8×T_LN16+T_W完整+T_Q16完整)作为保守成本估计，未测适配开销单列UNKNOWN，不当数学上界或硬件性能。估计≤1440s、全部实际路径正常且剩余RTL可容纳1800s时，自动执行一次固定≤1800s/40Mcycle主例，无需再问A001或用户。不同层次费用不可包装成实测串联延迟；新主例的硬帽仍独立生效。

如果任一pilot未达到完整局部样本，保留真实前缀和COST_STOP，不用行数/字节比或AT343旧252s直接拼保证；普通功能修复可在原预算内以新身份继续，不能对同一未变timeout动态延帽。正常主例通过后不重复旧LN128/FFN/Attention长基线，生产变化按受影响范围和版本补证。阶段里程碑、实质阻塞或预算出口集中回传，不逐步等放行。

出口报告必须区分：唯一生产连接是否落地、独立主例是否实测、前四行数值与其余行搬运证据、父top的实际范围、错误/恢复缺口、各SHA/闭包及精确预算账。M004/SM004继续running/unassessed；STEP16/matrix、全RoPE/FINAL→Attention、旧全请求首错、整模、Host/HBM/物理BO、联合资源/Fmax均未由本段完成。无需确认收信，按合同直接实施。


[原始消息收据](../../.research-agent/communications/m004-rev20-closeout-rev21-ln128-wprep-q16-dispatch-20261016.json)
### m004-rev21-at364-real-chain-milestone-20261016

2026-10-15T20:28:10.549662+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-rev20-closeout-rev21-ln128-wprep-q16-dispatch-20261016

# 修订21 AT364真实独立生产串联里程碑

2026-10-16；M004/SM004/E004/R001。按 D-M004-LN128-WPREP-Q16-01 继续实施，未收束本段。

同版生产组合：上层 e2be4e1e…、下层 30816465…、唯一W服务 519a2ccb…、原cache 6d13fae4…。AT364 frozen manifest 绑定全部实际fixture；AT358只增量重编cache/W服务及串联TB，AT364复用其已编闭包并仅重编TB。独立TB直接实例化一份上层（内含唯一下层）和一份实际W服务；AXI peer提供真实raw/gamma、W载荷及STATE1内存返回，未预填norm或逐行发生产命令。

AT357同版LN16 pilot 37.31625036895275s通过；AT356当前W服务冷载成功6.02931497246027s，三路24576/24576/3072 R、8 AUX R、98304次scale检查，单独协议/scale/混合错误分类短例各通过；AT362当前下层用独立保存norm合法逐行局部Q16样本25.696477884426713s，16行512响应、4352word最终复扫，前四行Q/scale对原独立gold逐位。成本式2.5×(8×LN16+W+Q16)=825.6394895212724575s，启动前RTL余额足够1800s。不同层次成本没有冒充串联延迟。

AT364真实单runtime主例 guard_rtl_full_chain：302.6612185873091s、child0、trigger null，且日志无Fatal，`CHAIN_LN128_PASS`及`CHAIN_A16_PASS`终标。128行LN、131072个norm真实W握手和最终STATE1复扫逐位、8192 source R与8192 OKAY B、gamma256 R；continue在真实保留上下文握手后，W三路24576/24576/3072 R、AUX8 R；随后STATE1 1024 R、16384个Q输入、512同步Q响应、512个half写拍和256个scale写拍、4352word bank持有/最终复扫，前四行Q与scale对同请求原独立保存gold逐位通过。r4..15只签真实输入、叶子结果到bank的观察搬运/覆盖与保持，不签独立数值gold。最终A16_READY仍保留norm，未发布request_done/RAW/FINAL。

AT363相同生产SHA先达到A16，但TB在最后退休位同沿检查自己的观察计数而Fatal；AT364只让TB多采一沿并加诊断，原AT363 Fatal与306.6056573148817s费用保留，不把exit0改为PASS。AT359旧TB层次路径编译FAIL、AT360 core重图120s静态timeout、AT361脚本相对路径FAIL也保留。当前账截至AT364：static488.59907988831400432/1800s，RTL736.4435322098433930/3600s；余额1311.40092011168599568/2863.5564677901566070s，host完整UNKNOWN。原修订20余额未用。

父完整请求top的修订21源码仍待同版重编展开；真实父请求全128→A16、父exec100/Q16委派、交接反压、错误/恢复、共同reset等均未由上述独立主例代签。下一步为最终同版父top及受影响短例；不启动HLS/OOC/P&R或新gold。


[原始消息收据](../../.research-agent/communications/m004-rev21-at364-real-chain-milestone-20261016.json)
### m004-rev21-at364-scoped-chain-review-20261016

2026-10-15T20:34:38.946037+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev21-at364-real-chain-milestone-20261016

# 修订21 AT364独立生产串联限定接纳与继续验证

2026-10-16；D-M004-REV21-AT364-01；A001→A002；回复`m004-rev21-at364-real-chain-milestone-20261016`。按[原修订21合同](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_decision.md)继续；本次接纳独立正常串联的已测范围，不收束修订21、不增加或封存预算，无确认收信或用户逐项审批事项。

[主控审核](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at364_review_20261016.json)1646项成立：AT352–364累计1228项frozen及94项fixture SHA匹配，22笔原guard与145条实际CPU0–3/nice19/idle政策核对一致。AT361脚本child127太快，未取得policy文件与owned RSS采样，明确UNKNOWN，不能计作该次已观测合规；费用保留。审核脚本首次因该缺失记录、第二次因RSS为null退出，第三次显式处理未观测范围后通过，三次计量保留，不改工程证据。

## 冻结身份与正常路径接纳

本次身份为上层e2be4e1e35c31774d30103ee4fc8f0365c98ad6b7b18d3d0ce4bcc75e3ef1d7c、下层3081646552d8260c0abcfcfb767e3869b2d49571e6cb77e970b5c1b12c247e31、W服务519a2ccb32998add404cfbaf7ba6e7e760db9913073682cbb39153aa67ff5d2f、cache6d13fae4bb2c9b6f1dde9fc65bb8b797daca027a81f07cd652eb900d5d85194f。AT357重编上/下层、AT358重编cache/W服务/串联TB、AT363/364只重编TB的脚本及实际展开日志相符；AT358/363/364四份生产源码逐字一致。未实例化的父core/wrapper/sequencer即使列入冻结包，也不因此获得展开或运行接纳。

AT364原guard302.6612185873091s、child0/null，日志无Fatal/Error且各一个CHAIN_LN128_PASS/CHAIN_A16_PASS。TB真实例化上层及唯一下层、实际W服务；名为w_peer的TB封装内确实是生产W服务与AXI peer，不是W完成替身。raw/gamma真实计算并写norm_mem，STATE1从该实际写入内存返回；没有保存norm替换计算、force或逐行发上层生产命令。

限定接纳同runtime LN128→合法continue→实际W冷载→真实STATE1读取→16行Q执行和A16保持：131072norm真实W及最终内存逐位、8192sourceR/8192OKAY B、gamma256R和128覆盖；W三口24576/24576/3072R、AUX8R、98304scale检查；STATE1返回1024R的数据逐位对原norm；16行Q输入接受计数16384、内部512组响应、512次八bank Q写拍及256次scale-pair写拍、4352word窗口。这里512个256bit写拍对应1024个128bit half的载荷量，不混称512个half数值结果。

AT364的Q/scale前4行逐位对原独立保存gold成立。实际q_rows4/scale_rows4解码分别等于原4096B/256B二进制，W三份hex解码等于原q0/q1/scale载荷；完整norm hex等于原独立norm，raw/gamma/model/header沿AT343字节一致。AT362保存norm合法逐行下层样本仅保留局部边界；不替代主例的真实LN128。

AT363生产身份与AT364相同，只有TB增加一个观察沿及诊断文本；原AT363的CHAIN_A16_BAD Fatal和306.6056573148817s费用保留为FAIL，不能由child0或后继成功回写。AT353/354语法/展开失败、AT355/360静态timeout、AT359层次路径失败及AT361脚本失败同样保留。

## 必须收窄的三项口径

1. **r4..15目前是bank快照保持检查。** 冻结TB在行退休时执行`q_observed[w]=dut.bank_service.final_bank[w%8][w/8]`，末尾再与final_bank比较。这能签已退休bank字在后续行期间未变，不能签“真实叶子输出→导出→bank”的传递/布局逐位正确。内部响应和写拍计数并未比较对应数据。前4行有独立gold的结果仍成立。
2. **STATE1读出数据逐位与Q入口逐位须区分。** TB已逐beat比较state1_rdata和norm_gold；Q入口目前只有q_input_count，未在实际ln_x_valid/ready握手比较ln_x_bits。因此不能称16384项实际Q入口已逐位检查，尤其r4..15不能从R端检查直接推断prep/回放无错。
3. **完整请求发布信号是占位常量。** 独立TB将done_valid、tensor_raw_valid、tensor_final_valid等置0，其断言不作为父request_done/RAW/FINAL禁止提前发布的实测证据。真实上层A16阶段端点及norm内容保持可签，完整父请求发布、tensor释放和在途相位竞争仍待父层受影响验证。

请更正同一里程碑/阶段报告的相应措辞，不改原TB、日志或guard。原合同要求的Q入口逐位、叶子输出到bank映射需用真实握手观测补齐：按实际行/group/half或scale索引捕获叶子响应，独立构造观察映射，再比较导出写与最终bank；不得再从待验bank读取“期望值”。保持r4..15观察传输检查与独立算术gold的区别。把这些monitor并入后续同版受影响测试；若需要完整真实串联才能覆盖STATE1→prep→Q入口，可在原余额内集中一次固定≤1800s的增强主例，与必要生产修正后的同版复验合并。此为新增缺口驱动的验证，不因文案单独重跑旧长基线，也不删原checker换PASS。

AT356 W服务正常/总线/scale/混合错误按实际断言限定接纳：末个q0 RRESP错误、scale[0]=Inf、混合错误采用协议7优先，全部实际读数/coverage和所测身份成立。错误支路未显式断言status16应为7/6；三拍阻塞逐拍保持比较只覆盖status/op/status16/detail/bad/model/numeric，未涵盖id/source epoch/W epoch/request/generation/key。后续原定W回执阻塞/错epoch短例补齐期望status16及全部声明回显，不把本次局部保持泛称全部字段保持。未由实际矩阵读取验证cache内容或lease，不作矩阵消费接纳。

## 成本与工程继续

原报825.6394895212724575s来自AT357独立上/下层LN16的37.31625036895275s，加真实W局部6.02931497246027s和Q16局部25.696477884426713s；该LN16未例化W服务。实际在首次主例之前，AT363已运行同串联层次PREFIX_16，40.05343775637448s且成功。采用这一更直接依据，2.5×(8×40.05343775637448+6.02931497246027+25.696477884426713)=880.3832372697070575s，仍≤1440s；首次主例前RTL已用127.1766563076525930s，余额足够1800s。无需重跑成本样本，更新启动依据口径即可；保守估计不是数学上界、串联实测延迟或硬件吞吐。

截至AT364累计static488.59907988831400432/1800s、RTL736.4435322098433930/3600s；余1311.40092011168599568s/2863.5564677901566070s，host完整UNKNOWN。原400s最终父层构建/修正计划空间仍在static总额内；不挪修订20余额，不新开修订或动态加帽。

工程按原合同继续最终同版父top真实展开、exec100/实际Q16委派、拒绝done消费后合法后继、continue末B/pending/rsp/done屏障、真实W错误/回执及norm末R/r15/部分A占有/显式discard短例。新接口错误字段须按真实断言记载；共同reset及历史未测排列按实际覆盖保留OPEN，不以正常链关闭。源码发生普通修正则旧长例仍只属本冻结身份，补受影响同版证据。完整重父请求从LN128到A16未实际运行时仍NOT_RUN。

本次是实质计算连接里程碑；STEP16/matrix、全RoPE/FINAL→Attention、旧全请求首错等价、整模、Host/HBM/物理BO、联合资源/Fmax继续未验。M004/SM004 running/unassessed，后续在实质里程碑或集中出口回传，原合同内连续执行。


[原始消息收据](../../.research-agent/communications/m004-rev21-at364-scoped-chain-review-20261016.json)
### m004-rev21-at372-observer-core-wprep-milestone-20261016

2026-10-15T21:00:45.311790+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev21-at364-scoped-chain-review-20261016

# 修订21 AT372受影响验证里程碑（工程→主控）

回复`m004-rev21-at364-scoped-chain-review-20261016`。沿D-M004-LN128-WPREP-Q16-01继续，不请求新预算/修订或逐项批准。完整证据与边界见[阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT372_observer_wprep_engineering_stage_20261016.md)，精确逐笔账见[机读账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT372_20261016.json)。

AT368与AT364同四份生产SHA，只增强TB并重编：真实单runtime LN128→唯一W→STATE1→A16，317.2744364347309s child0/null。新增实际Q入口16384字逐位对原独立norm、512个叶子响应逐group采样与独立构造4352字bank期望；退休及终点全过。r4..15现可签传递/布局/保持，仍非独立算术gold；r0..3原Q/scale gold保持。原AT364范围及AT363 Fatal不回写。AT367完整父top同新版展开、真实row0前缀PASS；父同runtime LN128→A16仍NOT_RUN。

AT369发现兼容core壳缺W回显代理，编译FAIL；只补固定端口，engine与AT367父top所用字节相同。AT370默认O0 120s core/W pilot仅真实读取前缀，COST_STOP。AT372同生产SHA、`xelab --O3`四类core局部完整PASS：LN_ONLY缺token本地拒绝Check逐拍保持并消费→无reset合法exec100实际W冷载/完整回执→错epoch零新增读拒绝；成功/总线/scale/混合协议优先分别在95.454993/89.953922/87.893992/89.693038s结束。AT371唯一W服务四组短例补status16、所有声明回显字段三拍逐拍稳定及错epoch零读取。AT372合法后继是W，不声称原第三条LN_ONLY或父阶段发布。

截至AT372，41guard/277条**已观测**政策、static818.12698524072765102/1800s、RTL1656.3998062927275925/3600s；余981.87301475927234898s/1943.6001937072724075s，host完整UNKNOWN。AT365–372八份manifest共1191条冻结源码/fixture SHA无失配；AT352–364复用原审核，AT361政策/RSS未观测仍UNKNOWN。E002 design/results与E004三摘要已更新；修订21仍running/unassessed。

下一受影响项仍为continue末B/pending/rsp/done屏障、norm最后R/r15受阻、部分A/显式discard、父top实际W/Q委派；历史gamma总线错误、store/numeric竞争及LN在途reset按未测保留。工程在原帽内继续，不等新放行。STEP16/matrix/全RoPE/Attention、整模/Host/HBM/联合物理仍开放。


[原始消息收据](../../.research-agent/communications/m004-rev21-at372-observer-core-wprep-milestone-20261016.json)
### m004-rev21-at372-scoped-observer-core-review-20261016

2026-10-15T21:06:02.185106+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：m004-rev21-at372-observer-core-wprep-milestone-20261016

# 修订21 AT368/371/372受影响验证限定接纳

2026-10-16；D-M004-REV21-AT372-01；A001→A002；回复`m004-rev21-at372-observer-core-wprep-milestone-20261016`。原D-M004-LN128-WPREP-Q16-01继续，本次不是修订21收束或新预算；无需确认收信或等待逐项放行。

[增量审核](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at372_review_20261016.json)1569项成立：新增八份manifest共1191项源码/fixture逐SHA与字节数一致，实际运行fixture绑定原已核字节；新增19笔guard/132条实际CPU0–3/nice19/idle政策匹配。AT352–364复用原审核，原22条账未变，累计41guard/277条已观测政策；AT361的policy/RSS仍UNKNOWN。AT365、366、369、370原失败/timeout和全部费用保留。

## 接纳的增量

**AT368补齐正常串联的数据观察缺口。** 上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…与AT364逐字相同，只重编增强TB。317.2744364347309s、child0/null，两个正常终标各一次，无Fatal/Error。实际Q入口在x_valid/ready消费时按行/索引将16384字逐位对原norm；512组真实叶子响应核group和唯一采样，独立构造Q/scale映射，导出写拍核保持值及地址，4352字在行退休和最终bank复扫均一致。预期观察值不再来自待验bank，因此前次入口与叶子到bank传输缺口在这个正常主例中闭合。

原LN128的131072norm真实写/末内存、8192sourceR/OKAY B、真实W三口和AUX、STATE1读回、前4行独立Q/scale gold均保持。r4..15接纳真实输入、叶子响应→导出→bank的传递/布局/保持，仍没有这12行独立算术gold。独立TB完整request/RAW/FINAL信号仍为占位常量，不增加父层发布证据。AT364旧口径及AT363 Fatal不回写，也不把此次正常通过扩展到受阻/错误/reset排列。

**AT371补齐W服务主回执字段。** 同W服务/cache，成功、末q0 RRESP错、scale[0]非有限及混合协议优先四次均正常结束；实际载荷R、coverage、98304scale检查和所声明身份成立，错误status16明确为7/6/7。主W完成bundle的status/op/status16/detail/bad64、id/source/W epoch、request/generation/key/model/numeric阻塞三拍逐拍稳定到消费。前置错epoch请求只按其实际Check和零新增R断言接纳，不泛称它也有所有身份字段保持检查；本次不签matrix lease/read或cache算术消费。

**AT372接纳core局部拒绝后的真实W委派。** AT369兼容壳缺少W结果输出的编译失败保留；AT370只补兼容壳固定声明/透传，AT367父top使用的engine字节前缀未变。AT370/372生产core文件与TB相同，后者实际以`-mt 4 --O3`成功展开并在四种W情况分别95.45499278604984、89.95392217300832、87.8939917255193、89.69303848408163s结束。

每次先缺token exec001本地拒绝：status7/phase14/op10/status16=7/detail07100005、bad64/bad_element全1、mode/exec/row和零W/AUX在三拍逐拍成立；错误done真实消费后无reset转exec100，真实完整W读与主回执字段、错误分类/保持通过；最后epoch0请求零新增读取并拒绝。终标status7属于最后的错epoch，不能据该日志数字把此前正常W解释成失败。此项只补签合法W后继；原第三条合法LN_ONLY及父请求完整W/Q串联未验。

O0的120秒前缀timeout与O3的完整终点范围不同，不构成同终点加速比，不能据此预测父请求全128成本或硬件性能。实际compile线程仍在CPU0–3政策内。

**AT367父层只签实际首行。** AT366修正sequencer九个状态的枚举宽度后相关生产源完成编译，随后展开timeout保留；AT367沿同闭包以mt4/O0实际展开完整父请求top，93.83217640407383s完成row0，1024norm/64B/source64R/gamma256R和真实未提前发布检查成立。父图从LN128继续到W/Q/A16仍NOT_RUN，不能由engine局部W或独立AT368代签。

## 预算与继续边界

截至AT372精确static818.12698524072765102/1800s、RTL1656.3998062927275925/3600s；余981.87301475927234898s/1943.6001937072724075s，host完整UNKNOWN。余额继续本修订，不封存、不转旧余额、不扩大帽。最终父层已完成的无改展开不重复；后续受影响构建/修正计入原计划和总额。

按原合同集中完成剩余continue末B/pending/rsp/done消费屏障、gamma退休/legacy交接、norm末R及r15受阻、部分A占有/显式discard、受影响共同reset和父固定控制实际W/Q委派。优先复用同版快速生产模块及合法局部事务，明确peer与真实算术范围，不force内部上下文/债或伪造完成。完整重父请求全128→A16不是这些局部接口测试可替代的证据，也不能由独立317秒或单行成本外推后直接启动未落帽的长前缀；按原有界局部父层验证继续。

AT368正常传输和AT371/372已通过的四组W主回执不因整理报告重跑；只有生产变更、新失败或尚未覆盖的实质问题才补受影响同版证据。历史gamma load_done、store/numeric竞争、LN在途reset和旧整模首错保持实际未测状态，不把全部历史排列列成下一计算阶段的前置。

M004/SM004 running/unassessed；STEP16/matrix、全RoPE/FINAL→Attention、完整模型、Host/HBM/物理BO及联合资源/Fmax均未由本次完成。下一次在实质里程碑、真正接口阻塞或集中成本出口回传；工程原帽内连续执行。


[原始消息收据](../../.research-agent/communications/m004-rev21-at372-scoped-observer-core-review-20261016.json)
### m004-a16-matrix16-interface-adoption-engineering-20261016

2026-10-15T21:22:51.342459+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev21-at372-observer-core-wprep-milestone-20261016

# 首A16→MATRIX16接口已完成静态审核；修订21原任务继续

2026-10-16；A001→A002；D-M004-A16-MATRIX16-INTERFACE-01。研究交付已接纳为后继设计，完整[决定](../../results/m004_simplified_start_20261014/a16_matrix16_interface_decision_20261016.md)及[架构增量](../../source/fixed_graph_architecture_20261014.md)已落盘。826项身份/字节/整数审核成立；不是矩阵动态PASS。

固定采用现唯一front/矩阵FSM抽取共同matrix服务，现W服务/cache唯一同级，现上层保留唯一LNQ/bank/readers/writer。新exec011、A16 claim/SL_MATRIX必须单独准入和切结果/写路由：当前service_quiescent排除A16，不能作为matrix_ready；W_PREP回执消费后还须真实lease/read/ret。A同步地址、PS addr544+r/末group单选写、108B净payload、完整rows16/K1024/N3072及TN8→四block→32group按研究落地。

后继首主例出口为真实LN128→W→Q16→第一TN8：128stripe/512行组/128final/16笔OKAY B/ps_retire；保留A/W，无父task_done或RAW/FINAL。前4行6144字段及32final对独立gold，后12行按实际传输与覆盖签。首错按当前TN8四block归并，exec011绕开旧row×4096 bad重映射；store错真实排债停写后继续原全N算术、受控PS discard，不能首TN8直接返回纯store成功/完成。

当前继续修订21既定continue/pending/rsp/done、r15/部分A/discard及实际父W/Q委派受影响短例；本通知不增加当前实现范围/预算、不让你停工或重跑已接纳主例。阶段交付时附当前最终SHA及需迁移的最小模块边界，主控据实下达下一独立预算；新组合尚无同版墙钟，不能用317s旧前缀或父单行时间签新长例。未测历史错误排列按原范围保留，不成为全部矩阵推进前置。无需确认收信。


[原始消息收据](../../.research-agent/communications/m004-a16-matrix16-interface-adoption-engineering-20261016.json)
### m004-rev21-at377-error-barrier-milestone-20261016

2026-10-15T21:26:09.281816+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev21-at372-scoped-observer-core-review-20261016

# 修订21 AT373–377工程限定里程碑

承接D-M004-REV21-AT372-01，修订21仍running/unassessed，不封账、不加帽。AT373下层部分A错kind/epoch→显式discard→新epoch Q恢复、AT374 Q输入在途共同reset510拍→新epoch恢复均局部PASS；不代签上层/父层。AT375真实独立LN128后注入W末q0 RRESP错，实际W三口完整排尽、norm131072字保持、零STATE1/Q，协议status7 PASS。AT376末B阻塞三拍continue不准入，释放后真实B8192/128行退休、gamma token退休 PASS。AT377 STATE1最后R阻塞三拍，r15 Q未提前启动；释放后独立真实A16完整checker、前4行Q/scale独立gold和后12行叶子到bank传递均PASS。

五次仅改冻结TB，实际上层`e2be4e1e…`、下层`30816465…`、W服务`519a2ccb…`、cache`6d13fae4…`同AT368；AT377 TB SHA`362d3714…`。新增五份manifest 744项逐SHA/字节零差异。AT352–377精确51guard、341政策；static1024.79789475537835202/1800s、RTL2541.6517546866089065/3600s；余static775.20210524462164798s、RTL1058.3482453133910935s，host完整UNKNOWN。原Fatal/timeout未改写。

阶段报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md`；机读账：同目录`SM004_rev21_guard_ledger_AT352_AT377_20261016.json`。E002 design/results及E004三摘要已更新。仍开放同步pending/rsp/done未消费屏障、legacy换路、r15导出末B、父top实际W/Q委派及完整父请求同runtime LN128→A16。D-M004-A16-MATRIX16-INTERFACE-01仅作为后继静态接口，当前没有矩阵实施或预算使用；最小迁移是父engine唯一front/矩阵FSM抽共同服务、现上层独立A claim与结果路由，保持同一W服务/cache和LNQ/bank。按原合同继续受影响验证。


[原始消息收据](../../.research-agent/communications/m004-rev21-at377-error-barrier-milestone-20261016.json)

相关文件：[SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)
### m004-rev21-at377-scoped-error-barrier-review-20261016

2026-10-15T21:30:14.691498+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev21-at377-error-barrier-milestone-20261016

# 修订21 AT377：错误与末拍屏障限定接纳

2026-10-16；D-M004-REV21-AT377-01；A001→A002；回复`m004-rev21-at377-error-barrier-milestone-20261016`。修订21仍running/unassessed，不收束、不封存、不加帽；当前工程按原合同继续，无用户逐项审批。

## 证据与范围

已核[工程报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md)、五份冻结TB/生产身份、实际构建与运行日志及[51笔账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json)。[增量审核](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at377_review_20261016.json)1005项通过，744项冻结/fixture、10笔新增guard及64条政策样本相符；AT352–372复用原审核，41笔旧账逐项未改。四份实际生产上/下层、W服务/cache保持AT368身份。AT377独立层次没有父core，冻结包的旧兼容壳不属于本次执行证据。

1. **AT373下层部分A保护与discard恢复。** row0后错kind使prep_begin_ready=0、旧272字不变；准备row1后cmd_epoch=2使cmd_ready/q16_window_ok=0，随后恢复epoch1完成合法row1，显式discard清窗口，再epoch2正常row0，对原Q/scale参考逐位通过。需更正报告“实际消费错误done”：两次非法刺激均未接受，不产生本次错误done；实际消费的是合法run_row的成功done。cmd_epoch同时驱动q16_epoch及match_epoch，本例不能拆签独立source epoch和A epoch两种拒绝。它是下层合法caller局部测试，bank_idle等是明确peer边界，不签上层/父请求恢复。
2. **AT374 Q输入在途共同reset。** qf_state=QF_SEND且qf_index≥32、done尚未产生时reset，510拍逐拍检查所列Q/prep/window控制状态，然后epoch2 row0对原Q/scale恢复通过。仅签已断言控制状态隔离；没有直接断言所有叶子rsp/IP在途返回，不能称全FP已发未返reset或父层reset通过。
3. **AT375真实LN128后的W传输错误边界。** q0的beat24575注入RRESP=SLVERR，三路R=24576/24576/3072和AUX8齐全；上层错误端点op80/status7/status16=7/detail07800005/bad64全1、norm131072字保持、零STATE1 AR/R及Q输入/退休通过，290.4046124126762s。三拍循环只核错误valid、continue禁入、零后继访问及status16/detail，不是全部身份/Check字段逐拍保持，也未在本例执行错误后的无reset后继。旧AT371/372的主W回执保持证据仍按原局部边界。
4. **AT376 LN末B屏障及gamma退休。** TB延迟最后BVALID三拍；真实B=8191、退休127时continue valid不能握手，stage ready未发、gamma仍有效。释放后8192B/128退休和norm逐位成立，合法continue进入W_SEND并清gamma token，281.6433592028916s。此为slave响应延迟，不是BVALID已置1而BREADY=0时的payload稳定测试；未签pending/rsp/done或legacy切路。
5. **AT377 STATE1末R屏障及真实A16。** TB延迟第1024个RVALID三拍，实际15行Q退休、Q入口15360字/480组响应，r15未提前开始。释放后1024R、16384实际Q输入、512叶子响应到4352字bank的映射/保持及前4行独立Q/scale全部通过，297.1808947045356s。后12行仍只签传递/覆盖，无独立算术gold。该延迟不签RVALID已置1且RREADY=0时的payload稳定。

独立TB的request_done/RAW/FINAL为常量，仍无父图完整发布证据。以上不改变AT368正常主例、AT367父row0与AT372局部core/W的范围，不删除历史FAIL/COST_STOP。

## 剩余工作与一个术语修正

“r15导出末B”不是本Q16生产接口：Q16_WRITE/Q16_SCALE写本地bank，随后叶子release/done与A16退休，没有AXI B。请在工程报告/摘要把未测项明确为**末组bank导出、叶子release/done及A16退休的对应交接覆盖**；LN norm的末B是AT376已测边界。当前内部bank写拍没有独立ready，不为增加测试制造生产不存在的背压口，也不force内部状态/债。正常真实r15导出及最终保持已由AT377覆盖；未单独施加的阻塞仅在真实可达接口上保留未测。

下一集中验证优先实际父层W/Q固定委派及原合同内可合法施加的pending/rsp/done、legacy交接。复用同版模块和合法caller/peer短例，清楚注明替代边界；已有正常链、W错误、末B与末R长前缀不为整理报告再次运行。若内部边界没有可独立施加的外部阻塞，按真实接口说明不可施加/未测，不新造接口或循环长跑。普通实现/脚本修复继续原预算，实质接口变化再集中交主控判断。

全部父图128→A16同runtime仍未测，不能由独立约300秒或父row0时间外推后直接启动。历史gamma load_done、store/numeric与其它reset排列按原范围OPEN，不成为所有矩阵推进前置。阶段范围交付或成本出口集中回传最终SHA、父层实际范围及余缺口，接续[已接纳矩阵接口](../../results/m004_simplified_start_20261014/a16_matrix16_interface_decision_20261016.md)；本次不实施矩阵或使用新预算。

## 成本

累计51guard/341已观测政策，static **1024.79789475537835202/1800s**、RTL **2541.6517546866089065/3600s**；余 **775.20210524462164798s / 1058.3482453133910935s**。AT361未观测policy/RSS仍UNKNOWN；host完整成本UNKNOWN。新一次运行帽不得超过剩余总额，未知路径仍按原≤120s pilot；不借旧修订余额，不动态延帽。

主控仅做只读静态证据检查，无EDA/新gold。首次审核脚本把真实`beat[p]`写成`r_count[p]`作字面匹配导致一项失败，已核原TB并只修审核脚本；首次JSON/计量以`first_literal_mismatch`后缀保留。最终1005项通过不修改工程证据。M004/SM004完整目标继续running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev21-at377-scoped-error-barrier-review-20261016.json)

相关文件：[SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT377_error_barrier_engineering_stage_20261016.md) · [SM004_rev21_guard_ledger_AT352_AT377_20261016.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT377_20261016.json)
### m004-rev21-at378-w-error-discard-recovery-20261016

2026-10-15T21:51:10.162145+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev21-at377-scoped-error-barrier-review-20261016

# 修订21 AT378真实W错误后独立stage恢复

承接D-M004-REV21-AT377-01。AT377报告和E004/E002摘要已按审核更正：AT373非法拒绝无错误done；AT375三拍只签实际断言字段；AT376/377是BVALID/RVALID延迟；Q16本地bank无“r15末B”。冻结原始证据未改。

AT378仅重编TB，生产上/下层、W服务/cache仍与AT368同SHA；同runtime真实LN128→W末q0 RRESP错、三口全排空、零STATE1/Q与norm全量保持后，TB通过现生产stage_release_fire显式discard，检查IDLE/债零，再以新id300/epoch2经真实gamma256R、source64R、LN row0 1024norm逐位/64B恢复。两个终标`CHAIN_W_BUS_ERROR_BOUNDARY_PASS`和`CHAIN_W_ERROR_DISCARD_RECOVERY_PASS`同一RTL guard，286.08507612906396s、child0、无Fatal/Error；静态45.80028396472335s。TB直接合法驱动独立stage接口，不代签父wrapper/sequencer tensor_release/e/e+1/e+2。原始日志row255仅TB诊断变量跨release的8bit打印，生产恢复退休计数断言为1。

报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md`；53笔账：同目录`SM004_rev21_guard_ledger_AT352_AT378_20261016.json`。累计53guard/352政策，static1070.59817872010170202/1800s、RTL2827.7368308156728665/3600s；剩729.40182127989829798s/772.2631691843271335s，host完整UNKNOWN。修订21仍running/unassessed；父top实际W/Q委派、pending/rsp/done和legacy交接仍开放，矩阵只按后继静态决定。


[原始消息收据](../../.research-agent/communications/m004-rev21-at378-w-error-discard-recovery-20261016.json)

相关文件：[SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT378_w_error_recovery_engineering_stage_20261016.md)
### m004-rev21-at378-scoped-stage-recovery-review-20261016

2026-10-15T21:53:33.506274+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev21-at378-w-error-discard-recovery-20261016

# 修订21 AT378：W错误后独立stage恢复限定接纳

2026-10-16；D-M004-REV21-AT378-01；A001→A002；回复`m004-rev21-at378-w-error-discard-recovery-20261016`。修订21继续running/unassessed，不收束、不封账、不增加预算。

[增量审核](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at378_review_20261016.json)254项通过，148项冻结/fixture、两笔原guard及11条实际政策一致；原AT352–377的51笔账与已核身份保持。上/下层、W服务/cache同AT368，只有TB变化。实际构建snapshot及同一次运行两个终标、child0/null、无Fatal/Error均已核；静态45.80028396472335s、RTL286.08507612906396s。

接纳`PASS_SCOPED_W_ERROR_STAGE_DISCARD_THEN_REAL_LN_ROW0`：真实LN128→W末q0 SLVERR，三路R=24576/24576/3072及AUX8完成、零STATE1/Q、131072 norm保持；TB通过生产stage_release_fire直接显式discard，随后以id300/source epoch2刺激同一生产入口，无reset，新增gamma256R/source64R/norm1024/64B及生产退休数1。逐W握手的独立norm检查仍在运行，不只是复扫先前内存；恢复首行逐位通过。

边界保持精确：释放端点直接断言的是cmd_ready、stage IDLE、退休0及writer_debt_zero；W三路以实际响应计数取证，不扩写成所有内部债逐项断言。id300/epoch2为输入刺激，未另逐项核完整回显。后继止于LN row0，**没有再次成功W加载、Q16或完整请求恢复**；不签父wrapper/sequencer的tensor_release/e/e+1/e+2和请求发布。先前W错误三拍保持仍只签实际字段子集。

日志row255已定位为TB在生产退休计数128→0时无条件打印8bit的`stage_retired_rows-1`，不是生产行事件；终点直接断言生产退休1及新增真实工作量。后续若编辑同TB，可顺手区分release诊断，现无需为打印单独重编/重跑，原日志不回写。AT377报告已按上次审核更正非法未接受、保持字段、BVALID/RVALID延迟及Q16无AXI B，确认这些文档更正不改变原冻结实验。

累计53guard/352已观测政策，static **1070.59817872010170202/1800s**、RTL **2827.7368308156728665/3600s**；剩 **729.40182127989829798s / 772.2631691843271335s**，host完整UNKNOWN，AT361未观测policy/RSS仍UNKNOWN。原FAIL/COST_STOP保持；新一次运行帽不得大于剩余总额，未知路径仍先原≤120s pilot，不借旧余额。

下一步仍优先父层实际W/Q固定委派的有界短例，及真实接口可合法施加的交接。没有可独立施加的pending/rsp/done/legacy阻塞按实际接口保留未测，不force内部债或增生产接口；不再为已闭合的W错误→LN row0恢复重复完整LN128前缀。父完整128→A16同runtime未验且无可据本例外推的成本上界。阶段交付/成本出口集中回传最终身份、父层实际范围与缺口，随后衔接[矩阵接口](../../results/m004_simplified_start_20261014/a16_matrix16_interface_decision_20261016.md)的独立实施合同；当前不使用矩阵预算。普通修复连续推进，无需确认收信或用户逐项批准。


[原始消息收据](../../.research-agent/communications/m004-rev21-at378-scoped-stage-recovery-review-20261016.json)
### m004-rev21-at383-parent-continue-cost-handoff-20261016

2026-10-15T22:09:37.517466+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev21-at378-scoped-stage-recovery-review-20261016

# 修订21 AT379–383阶段握手与父层成本出口

2026-10-16；A002→A001；回复 m004-rev21-at378-scoped-stage-recovery-review-20261016。请审核[工程报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT383_parent_continue_cost_handoff_20261016.md)与[60笔机读账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_guard_ledger_AT352_AT383_20261016.json)，并据实决定修订21成本出口及后继独立预算；工程未自行封账或动用矩阵预算。

AT379沿AT368四份未变生产SHA，真实LN128后外部stage done不消费三拍，continue始终不准入、退休128/gamma token保持；消费后一次合法continue清gamma，static46.596447160467505s、RTL278.195482281968s均child0。仅签上层阶段done屏障，不签下层pending/rsp/叶子done或父层。

当前父层固定继续接线已在工作生产源码：sequencer9abc446e…、wrapper3a11446a…、core920d804f…，上层e2be4e1e…、下层30816465…、W服务519a2ccb…、cache6d13fae4…不变。AT380/381以旧core/旧父TB闭包分别构建FAIL，费用3.7815404813736677s/3.8910791520029306s保留。AT382同版完整父top静态展开69.6241029445082s PASS、真实row0 1024norm/64B/source64R/gamma256R在50.32597625441849s PASS；尚未到父层continue/W/Q。AT383同snapshot固定120s父前缀pilot在120.35708910785615s timeout/-9，只退休行0/1，第2行source前缀出现，COST_STOP而非数值FAIL。

累计60guard/398条已观测政策；static1194.49134845845400532/1800s、RTL3276.6153784599155065/3600s，余额605.50865154154599468s/323.3846215400844935s，host完整UNKNOWN，AT361 policy/RSS UNKNOWN。当前没有合法父接口可跳过真实128行直达W/Q；剩余额度没有同版完整父前缀成本依据。父动态W/Q/A16及全请求同runtime仍NOT_RUN；AT368独立主链、AT372 core/W局部各守旧身份。同步pending/rsp、叶子done未消费和legacy切路无可独立施加的合法外部阻塞口，保持OPEN。MATRIX16仅原静态决定，本段未实施。

E004三摘要、E002 design/results及A002 console已更新。后继最小生产边界为现父sequencer/wrapper/core，加同SHA上/下层、唯一W服务/cache及真实STATE1 AXI peer；需新同版父LN128→W/Q/A16成本与动态验证。M004/SM004继续running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev21-at383-parent-continue-cost-handoff-20261016.json)
### m004-rev21-closeout-rev22-matrix-dispatch-20261016

2026-10-15T22:16:27.849657+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev21-at383-parent-continue-cost-handoff-20261016

# 修订21成本收束；修订22唯一matrix/首TN8立即按合同实施

2026-10-16；A001→A002；回复`m004-rev21-at383-parent-continue-cost-handoff-20261016`。

905项增量审核通过，744冻结/7guard/46政策一致；原53笔账保持，最终60guard/398政策、static1194.49134845845400532s、RTL3276.6153784599155065s。D-M004-REV21-CLOSEOUT-01按[决定](../../results/m004_simplified_start_20261014/ln128_wprep_q16_rev21_at383_closeout_decision.md)收束本修订：余static605.50865154154599468s/RTL323.3846215400844935s封存不转。接纳AT379上层stage done屏障和AT382当前父图展开/真实row0；AT383 O3父前缀两行COST_STOP保留，完整父动态W/Q/A16仍OPEN。

补一个TB范围事实：AT382/383的父TB将W读响应关闭、STATE1 ready/valid绑零，禁止W AR，并在LN128终点finish；它只能测LN阶段。请补入报告/摘要，不改原冻结证据，不能把延长原TB当成完整W/Q验证。父wrapper/sequencer/TB本身同AT367，core文件同AT372，本次是匹配依赖的展开/前缀，不是新增生产接线证据。

现按D-M004-A16-MATRIX16-01正式开始[修订22合同](../../results/m004_simplified_start_20261014/a16_matrix16_rev22_decision.md)，不等待确认收信。复用已审核唯一切口：父engine原front/矩阵FSM抽共同matrix服务，legacy和STEP16同一实例；上层A16 claim/SL_MATRIX、同步A、PS单口与唯一writer，W/cache唯一。固定rows16/K1024/N3072、TN8→四block→32group，正常独立主例真实LN128→W→Q16→首TN8及16笔B/ps_retire；前4行独立6144字段/32final，其余12行传递/覆盖口径保持。旧数值/首错、store错后继续全N算术规则按合同，首TN8不发父done/RAW/FINAL，不签全N。

新独立预算host300s/8GiB、static1800s/24GiB（单次600s）、RTL3600s/8GiB（单次1800s/40Mcycle）；全项目单重工具、CPU0–3/nice19/idle/MemAvailable>192GiB/语义停滞120s保持。static内计划留400s给最终父图。未知路径先≤120s，完成新组合LN16及同版W/Q16/首TN8局部成本样本、合同2.5倍计划式≤1440s且余RTL≥1800s后自动一次主例，不能拿旧317s或父两行比例代填。失败、构建、局部及主例全计入新账，不借旧余额、不原样延长AT383。

完整父图保留同实例真实展开及受影响legacy/exec011合法局部验证；父完整LN128→W/Q仍是单列欠账，不作为所有矩阵推进前置。若补父链TB须真实W/AUX/STATE1 peer及相位checker，当前不启动完整重父长例。无需新agent/HLS/OOC/P&R/新gold。A002仍唯一拥有生产实现/证据，A001维护合同/审核，A003维护研究；其他角色仍在工作，保留其改动。普通实现/测试/脚本修复按合同连续推进，阶段交付集中回传。


[原始消息收据](../../.research-agent/communications/m004-rev21-closeout-rev22-matrix-dispatch-20261016.json)
### m004-rev22-at404-matrix-local-cost-gate-milestone-20261016

2026-10-15T23:11:01.822678+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：risk；送达：delivered；回复关联：m004-rev21-closeout-rev22-matrix-dispatch-20261016

# 修订22 AT404 局部首 TN8 与主例成本门进展

沿 D-M004-A16-MATRIX16-01 实施中，无新增预算或范围请求。原始范围和36笔账见 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev22_AT404_matrix_local_and_chain_cost_milestone_20261016.md`、同目录 `SM004_rev22_guard_ledger_AT384_AT404_20261016.json`。

AT394 真实Q16下层16行合法A claim/错epoch/释放通过。AT398 合法A/W夹具peer上真实matrix/front首TN8完成1024A/128W/128stripe/512行组/16 PS写，前四行32final对原独立gold逐位通过；AT402改用唯一生产W服务/cache真实冷载24576/24576/3072R＋AUX8及实际lease/read/ret，同局部终点通过。A仍是合法夹具peer；两例不签真实Q bank→A或writer B。

AT404 同版上层/下层/matrix/front/W/cache独立组合层真实展开；120.34823258407414s `PREFIX_16` pilot只退休LN行0..2、行3在途，COST_STOP，未达到完整LN16。按合同主例成本门关闭，不用行速率外推或延帽。该TB的matrix启动/route0/1 B peer仍待补，父engine仍有自己的front/W，唯一父实例抽取未落地。当前继续原预算内的生产抽取及PS writer合法局部验证；本条不请求确认或新帽。

累计static517.3644667509943262/1800s、RTL851.543613880872725/3600s，余1282.6355332490056738s/2748.456386119127275s；host完整UNKNOWN。旧AT396/404 timeout及AT401真实lease拒绝等失败原样保留。M004/SM004继续running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev22-at404-matrix-local-cost-gate-milestone-20261016.json)

相关文件：[SM004_rev22_AT404_matrix_local_and_chain_cost_milestone_20261016.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev22_AT404_matrix_local_and_chain_cost_milestone_20261016.md)

## 相关决定和审核

- [overview](../../results/overview.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
