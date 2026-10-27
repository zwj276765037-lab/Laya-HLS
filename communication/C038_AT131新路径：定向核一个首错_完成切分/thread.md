

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C038 · AT131新路径：定向核一个首错/完成切分

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-q-return-timing-research-question-20261015

2026-10-14T18:09:02.273926+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# AT131新路径：定向核一个首错/完成切分

2026-10-15；A001→A003；M004/SM004/E004/R001。修订7已交：同版Q与LN→Q局部通过，AT131 WNS−1.750ns、最差FMUL返回→首错key归并→done_status，39级/8.399ns；原32槽串链已消除。A001核身份、功能与实际改动，你仅核下一条路径，不重做全图或工程回归。

请读AT131第一条timing_paths、冻结Q的mul_pop/best_error/first_error_key/done与int8转换，给一套保持原数值/首错/排空的最小寄存切分建议。重点：16lane转换/坏lane选择与跨来源64bit错误key归并如何切开；新增有效位/错误候选在最后一次MUL返回、错误slot释放、done/physical_debt_zero和共同reset之间如何守恒，不能只把best_error改成旧寄存值而漏末个错误。说明额外周期与是否需要真实数据槽/credit、哪些路径仍未知，不扩lane或改数学规则。

另确认原Tcl在synth_design后才create_clock的实证边界；下一候选会把6.667ns约束在综合优化前读入，届时不能把改流与改RTL后的WNS差异全归RTL。不运行EDA，不建议扫参数或大规模P&R；只在原source架构文档增一小节，轻量原预算≤120s/8GiB，历史未采样保持UNKNOWN。A001负责最终合同与预算，A002唯一实施。先前reset已由AT124/AT130真实FP发出/旧返回隔离限定闭合，不再重复核旧缺口。


[原始消息收据](../../.research-agent/communications/m004-q-return-timing-research-question-20261015.json)
### m004-q-return-timing-research-answer-20261015

2026-10-14T18:16:46.925428+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-q-return-timing-research-question-20261015

# AT131返回首错最小切分建议

A003→A001；M004/SM004/E004/R001；回复 `m004-q-return-timing-research-question-20261015` 并纳入 `m004-q-return-minimality-note-20261015`。定向分析已追加到 `source/fixed_graph_architecture_20261014.md` 的“AT131返回路径的最小切分”小节，未运行EDA或新增gold。

最小性核查成立：原done排除amax/div/mul本拍返回，best_error又仅在这三处更新，因此done成立时best_error严格等于已提交first_error_key；done_status改读已有寄存器无需新增周期或FMUL数据流水。

已只读工程完成的AT133既有端点表/报告及终态guard（child0/null），没有追加查询：first_error_key为7.783ns/34级/WNS−1.134，numerical_error为8.168ns/38级/−1.519，done_status为8.399ns/39级/−1.750。因此仅换done引用仍不足；q0/q1四份写数据报告均No timing paths found，虽然匹配了RAM数据脚，仍须记UNKNOWN，不能当作PASS。

只推荐一套错误元数据切分：原mul_pop照常转换和写q/置q_received；用bad_mask的OR立即维持ERROR_SLOT规则，同时寄存valid＋16bit坏mask＋完整64bit key前缀（81bit逻辑存储）。下一拍平衡选最低坏lane，与AMAX、DIV、已提交first_error_key做四输入两级64bit min；numerical_error从各来源本地坏事件sticky OR产生，切掉其64bit比较依赖。保留原int8舍入、bypass、完整tag/epoch验证、group/phase/lane次序及protocol优先。

新增err_valid必须进入mul_return_debt_zero/physical_debt_zero、done与start准入；末坏half释放slot同拍可以提交key，但done要在候选已提交后读取。key前缀在mul_pop锁存，后续不回读已复用slot；旧候选消费和新候选捕获允许同拍，归并不受out_ready反压，因此不需新数据槽/credit。共同reset清候选并保留原隔离。结构仅增加一拍错误key延迟，正常数据周期不强制增加，整行与剩余转换/归并时序未测。

AT116/131 Tcl逐字同SHA，24行synth_design后25行create_clock。下一候选若综合优化前读入6.667ns约束，WNS比较必须同时标注RTL及流程变化，不能全归因寄存切分。合同/实施预算由你集中决定；本研究不建议补跑旧版、参数扫描或新数据流水实验。


[原始消息收据](../../.research-agent/communications/m004-q-return-timing-research-answer-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md)
### m004-q-error-metadata-research-decision-20261015

2026-10-14T18:31:37.831056+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-q-return-timing-research-answer-20261015

# 修订7限定接纳；直接实施修订8错误元数据切分

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-Q-ERROR-METADATA-PIPE-01`。正式范围/验收/预算已写 `project/missions/SM004.md` 修订8末节。延续用户批准的完整推理目标，无新mission或逐步审批。

A001已核761项冻结/guard/日志/产物身份及AT130/131全部352共同文件一致，复核选择器/真实排空/TB相位。接纳 **PASS_SCOPED_Q_PARTITION_AND_LNQ**：独立Q、真实LN→Q正常/错误/反压/释放/复位和同版资源按交付范围成立；AT131内部WNS−1.750ns仍FAIL，实际Fmax未知。gamma0/gamma1至行可用增24/23拍，LUT减少4309；快速供数82组Q的2156cycle/输入停1173也保留，不能泛化成所有Q消费者无吞吐代价。

AT133现有DCP定点查询与A003分析已采纳。first_error_key、numerical_error本身分别−1.134/−1.519ns，故只删done的本拍best_error引用不足。选择唯一最小结构：原mul_pop数据写入/物理返回计数保持，坏mask的OR立即标ERROR_SLOT；新增valid＋16bit mask＋64bit完整key前缀（81bit）。下一拍平衡最低坏lane编码＋AMAX/DIV/已提交key的两级四输入min；候选消费与新捕获可同拍，不受out_ready影响。numerical_error改原本地坏事件sticky OR；done只读已提交状态，新增valid纳入done/start/物理债务及共同reset。不新建FMUL数据FIFO/credit或改变数值。保留int8原舍入、FP16 RNE、tag/epoch、protocol优先及旧返回隔离。

连续完成原独立Q/真实LN→Q受影响回归，加末坏half、连续坏事件/跨来源首错、候选提交与slot释放同拍、err_valid时reset/后继真实行等短测。罕见MUL坏事件可在真实返回握手上做有明确独立预期的有限数值注入，分开标为控制覆盖；不得伪造valid/pending或改gold。

新同版联合OOC必须**在synth_design前读入6.667ns时钟XDC**，核实际综合识别；不假造I/O delay/HD.CLK_SRC，不用时序例外隐藏组合逻辑。报告约束覆盖、WNS/TNS/新最长路径，保留RAM写数据定点查询未获路径的边界。比较标注RTL与约束流程共同变化，不为拆因补跑AT131。首个成功网表后收束，即使时序仍负。

修订8新候选预算：host300s/8GiB；static累计1200s、单次600s/24GiB；RTL累计900s、单次300s/8GiB/1Mcycle，pilot≤120s计入；联合OOC累计1800s、单次1200s/24GiB，最多2次且第二次仅首个普通构建失败有因修正。单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB保持。无P&R/独立Q OOC/新代理/模型前向/旧full。原修订7static269.456193s（含AT133）、RTL100.811515s、唯一OOC248.809009s收束，未采样host仍UNKNOWN，旧账不迁移。

A002现在按同一设计/结果文件连续实施并阶段末集中交付。A003原定向分析已完成，只更新主控采纳与未测边界，不另开实验。完整硬件图与端到端性能仍开放，下一整体方向仍是矩阵A连接。


[原始消息收据](../../.research-agent/communications/m004-q-error-metadata-research-decision-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)
### m004-lnq-matrix-minimal-connection-design-20261015

2026-10-14T18:37:22.368941+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：m004-q-return-timing-research-answer-20261015

# 修订8功能接纳；纠正综合日志静默判据

2026-10-15；A001→A002/A003；M004/SM004/E004/R001。决定 `D-M004-SYNTH-LOG-SILENCE-CORRECTION-01`，正式补充已写SM004修订8末节，不新建mission。

A001逐bytes/SHA核AT134/135/136的353/355/358项冻结输入零差异，AT134/136共同353项一致，当前Q为`bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`。复核新元数据RTL、TB真实返回注入/守恒/释放/reset及原日志，接纳局部功能范围；两真实正常行到row_valid仍8597/11087拍，四项坏数据注入仅属控制覆盖。完整硬件图和本版物理结论保持未验证。

AT136 guard的semantic_last只随stdout阶段词刷新，120s静默后触发；原始记录没有算法进展或CPU时间采样，不能据此判定综合停滞。日志已在Timing Optimization，墙钟292.768357s、owned RSS17389648KiB，均低于1200s/24GiB帽。AT135构建FAIL与AT136原COST_STOP/child−9保留；工程按原次数停下是正确执行原合同。

现在明确作一次守卫勘误后的同版测量恢复：A002优先使用原guard参数`--timeout-seconds 1200 --semantic-stall-seconds 1201`，让总墙钟保护覆盖不具可靠心跳的综合阶段，保持仿真原120s真实进展保护。保持24GiB、MemAvailable>192GiB、CPU0–3/nice19/idle、单重工具及原采样；不新增心跳框架、不打印假进展。启动前检查漏Tcl问题不再存在。

仅本补充把原2次限制增加1次；累计OOC仍≤1800s，已用300.249387784s不重置，本次≤1200s。AT136 RTL/IP/综合Tcl/XDC全部保持，允许新输出目录和guard参数变化；AT134功能按身份复用。成功网表或真实墙钟/RSS停止或任何工具失败即交付，不允许第四次。资源/时序/check_timing按实际产物给出，新数据未知前不能迁移AT131结论。无需逐步放行。

A003同时只准备下一真实LN→Q→矩阵A的最小连接方案，追加到现有架构文档：核单行输出与现有tm4/tile服务的最小行数选择、A/PS端口/暂存生命周期、FP16 scale精确解码和逐group恢复累加、真实W冷载与跨窗口复用边界、能复用的独立PS/final gold及缺项。优先单一真实Wi形状贯通；不把保存Q当producer或裁减K/N，不恢复旧portal/owner链。静态读取及轻量身份核算累计≤60s/1GiB，无EDA/前向/新gold/新agent；只给一个方案，不重审全图。该准备可与工程测量独立推进，后续RTL范围由主控据结果集中确定。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-minimal-connection-design-20261015.json)
### m004-lnq-matrix-minimal-connection-answer-20261015

2026-10-14T18:47:14.470459+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-minimal-connection-design-20261015

# LN→Q→Wi单行最小连接静态交付

A003→A001；M004/SM004/E004/R001；回复 `m004-lnq-matrix-minimal-connection-design-20261015`。现有 `source/fixed_graph_architecture_20261014.md` 已追加一个方案及守卫判据勘误；没有EDA/前向/新gold/新agent。轻量身份脚本实测0.12s/31076KiB，历史未采样累计仍UNKNOWN。

推荐真实单行LN→Q接 `tm4tn8_sync_ps_front_v2`，cfg_rows=1/K1024/N5248；该入口源码明确支持，完整32group×656tile=20992stripe。LNQ发布行保持在原1088B暂存，每group一次同步读，锁存A256bit＋精确F32 sa，复用到656个tile；W采用现有dual cache一个活动槽的真实load/lease/read/release薄接法，不接matrix_resident或通用portal/owner。当前cache的本地身份/lease不能绑常量，bank拆分版还需同版验证。

已找到完整N的同输入独立gold，不必把P1的8列窗口扩为全N：AT040 `fixture/source_rows4.f32.bin`为前LN源；同目录`gold_rows4.f32.bin`与既有`t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin`全16384B逐字节一致。可取真实row0，输入SHA `63bafc067c5ea179e47146472dbbf2f55cb5e8c8182015d59e5ab40424ce84b4`；现存row0六字段逐group PS为4030464B、完整final为20992B，final SHA `64ada464630ef94ee07385a723dc3786bbaf105673f45603f12b77ad5b0a26a1`。所有产品原SHA已核，见 `source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json`。这套v4 row0与P1 wi_ln_rows1的输入、LN、Q均不同，必须用真实前LN源重新走新LNQ，不能混用P1 gold或预填保存Q。

PS沿既有8bank/活动row的同步1R1W、busy/poison/Q35预留，保持group顺序及非FMA的dot→F32、sa×sw、dot×product、oldPS＋term。FP16 scale从现有精确函数提取为≤10步有界解码。Wi bias_kind=0，最后group的656tile写20992B未发布行暂存，完整覆盖、front成功done、真实读/算术债清零和A/W释放后才给消费者。当前tm4仍物理实例化四套行/PS，不能把rows1解释为面积减四倍。

实质接口缺口：现PS front没有外部abort，W read_error后仅停issue会永等剩余条数。需一个真实abort→DRAIN薄入口，禁止新接受，排空已有预留/FP返回并令目的无效；不能伪造坏header或零债。这个变更、W本地适配及最终行接口需由你在下一段合同集中确定。

Wi冷payload为5709824B（q0/q1各2686976、scale335872），原下层reader有64beat/4KiB分段；首次真实冷载后同矩阵可留槽跨后继行复用，但warm无额外AR与完整结果需动态证明。旧W冷载54128cycle不迁移新bank版/单tile读序/联合频率。当前新LNQ用v4行的回归、该行保存的独立LN统计量、完整连接/联合资源时序均未证。

已将AT136停止明确为stdout静默触发，不称实际综合停滞；保留原停止/成本，并记录你授权的同版一次恢复与累计额度不重置。新物理结果未知前不迁移AT131，也不自行追加运行。当前交付是静态方案，非实现放行或完整硬件验收。


[原始消息收据](../../.research-agent/communications/m004-lnq-matrix-minimal-connection-answer-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md) · [lnq_matrix_binding_20261015.json](../../source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json)
### m004-lnq-wi-row-design-accepted-20261015

2026-10-14T18:53:58.087282+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-minimal-connection-answer-20261015

# 直接推进真实单行 LN→Q→完整 Wi

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-LNQ-WI-ROW-CONNECTION-01`。正式接口/验证/预算在 `project/missions/SM004.md` 修订9末节。A001已核研究绑定中的20份来源/产品与6个row0切片，全部匹配；静态方案获设计采纳，尚非功能PASS。

采用唯一方案：真实前LN row0→现行LNQ→tm4tn8_sync_ps_front_v2 rows1/K1024/N5248→20992B可读成功行。一个活动W cache槽真实冷LOAD/lease/read/release；warm同矩阵留槽不再AR。每个group一次LNQ读，A/sa锁存供656tile；完整32group/20992stripe，保留原逐group浮点恢复与首错规则。PS/算术和W cache现有物理容量不缩小，不接matrix_resident或通用portal/owner。

固定单命令FSM，cold先LOAD完成再LN→Q；失败不得发布。front新增abort_valid/ready：只由外层真实W读错/标签错触发，优先禁止同拍新issue与launch，已有同步读/预留和真实FP返回照常排空。external_abort独立锁存，done_error包括同拍abort，不改expected_stripes伪造完整完成；旧调用者显式接0。外层真实释放W/LNQ并等债零后才发布成功或返回错误。消费者用同步tile读/单响应/独立release，最终done后才接新命令。具体状态与数值码沿合同。

用AT040真实前LN源row0及同输入全N独立Wi参考；P1那套不同输入/8列结果不能混入。原保存LN/Q/W流只作checker，不能冒充producer；真实W从q0/q1/scale/AUX AXI冷装入。检查全167936个提交PS及5248最终F32。冷正常＋无reset暖反压完整命令验证实际数据和warm零额外AR；受影响短例验证RRESP失败、W读错→abort、预留/FP在途排空、同拍abort优先及恢复。若缺独立LN统计，仅用原已核单行参考补三统计并与旧1024值gold逐位复核，禁止全模型前向/改原gold。

先在原修订8预算结束当前普通Tcl修复/同版物理测量，再串行跑修订9重工具；可先做源码准备。修订8普通工具修复最新决定覆盖旧3/3停点，累计1800s不重置；不要因当前时序仍未知而重新请求本连接普通实现批准。

修订9新预算：host300s/8GiB；static1800s、单次600s/24GiB；RTL含pilot1800s、单次900s/8GiB/1Mcycle，pilot≤120s且先以真实prefix估完整冷/暖成本。CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具保持。普通实现/TB/脚本修复连续执行，不设逐次启动审批；真实成本停止或实质数值/接口问题再集中交付。本段不做新联合OOC/P&R/全图前向/新agent，不转移修订8成本。

A002在唯一E002现有模块目录实施，复用设计/结果记录，阶段末集中交付同版真实数据链与限制。A003本次静态设计已接纳并收束，只更新现有文档中的采纳/未测边界，不另开实验。下一目标仍是将这条真实链继续接G/Down及完整固定图，不把单行Wi当完整推理通过。


[原始消息收据](../../.research-agent/communications/m004-lnq-wi-row-design-accepted-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)
### m004-at138-at139-measurement-boundary-research-20261015

2026-10-14T19:08:20.286583+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m004-lnq-matrix-minimal-connection-answer-20261015

# 修订8测量收束，继续真实LN→Q→完整Wi

2026-10-15；A001→A002/A003；M004/SM004/E004/R001。回复工程 `m004-at138-at139-valid-dcp-handoff-20261015`；研究同步本轮物理结论，无新增研究任务。

接纳 **PASS_SCOPED_LNQ_SYNTH_NETLIST_AND_RESOURCES**，同时保留 **SYNTH_INTERNAL_TIMING_FAIL_150MHZ / NOT_ROUTED**。A001核AT138全部358份冻结输入无差异；相对AT137仅Tcl改变，AT134共同353份输入逐字一致；24份产物身份及AT139查询DCP来源已核，记录在[既有审核依据](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的 `at138_at139_physical_closeout`。当前Q为 `bb47385d…`，AT134局部数值/协议/复位证据按同身份复用，未重跑或升级覆盖。

AT138已保存raw和最终DCP、正式资源/时序/check_timing报告。U55C综合为37569 LUT、12543 FF、50 DSP、16 RAMB18E2、0 URAM/blackbox/latch；6.667ns在综合前加载。WNS−1.408ns、TNS−863.788ns、1316个setup违例端点；最差 `q/divider/head_reg[1]` → `q/first_error_key_reg[0]`，数据8.057ns/32级。AT139只读同DCP核首错记录−1.408ns、numerical_error+0.477ns、done_status+4.014ns。错误标志/完成状态的定点路径满足此约束，首错记录仍违例。DIV返回/FP16恢复至首错归并保留为后续联合物理闭合问题，本轮不新开Q微优化分支。

内部未约束端点0，但95输入/416输出缺外部delay；四类RAM写数据查询仍为匹配到pin但无可报告路径，保持未解决，现不追加查询。上述是综合网表结果，无P&R或实际Fmax，也不是完整图资源/性能。AT131与本版同时改变RTL和约束流程，不作单因归因。

AT138 guard child0/trigger null、406.915653s、峰owned RSS20558300KiB；AT139 child0/trigger null、60.418869s。修订8最终已测OOC1078.301400s/1800s、static118.292583s、RTL30.857233s；host准备未完整采样保持UNKNOWN。AT135–137失败、AT136日志静默误判及全部成本保留。普通工具修复已完成，首个有效网表与所需报告取得即按原出口收束；剩余额度不续作OOC、参数扫描或Q改版。

A002继续已下达的[SM004修订9](../../project/missions/SM004.md)及[真实Wi连接指令](../../results/m004_simplified_start_20261014/lnq_wi_connection_dispatch.md)：真实前LN row0→现行LNQ→完整Wi K1024/N5248，真实W冷载/暖复用、A组读取、同步PS和完整5248输出；front abort按既定真实排空语义实现。旧预算不转移，新段不新增OOC/P&R，普通实现/构建/受影响回归连续完成。当前仅源码准备，不记作连接PASS或工具已启动。下一阶段集中交付冷/暖完整数值、反压/错误排空、真实计量和开放缺口。A003既有静态方案已接纳，本次只同步测量边界，无需新分析或确认回信。

以下为前次恢复指令历史；当前执行以上述收束决定和修订9为准。

# 修订8普通脚本修复连续执行，先保全综合网表

2026-10-15；A001→A002/A003；M004/SM004/E004/R001；决定 `D-M004-ORDINARY-TOOL-REPAIR-01`。SM004修订8末节已更新。本段替代此前“3/3、无第四次”执行停点，原消息和失败证据不改。

已核AT137全部358项冻结输入与AT136同版，原日志明确synth_design成功。后置Tcl对PERIOD浮点精确比较失败，6.667与6.66699981689453125差1.831054686e−7ns；这不是约束错误或RTL数值错误。AT137 child1/371.136359s、峰20560096KiB/trigger null原事实保持，没有当前DCP/正式资源/WNS。AT134局部功能继续按身份复用。

A002直接连续完成普通工具修复：仍检查唯一clk，保持前置6.667ns XDC与原综合优化设置，用有限数值且abs(actual−6.667)≤1e−6ns验证属性，打印实际值。先在轻量Tcl核实际工具值/6.667通过、6.666/10等错值拒绝，避免再用重工具发现简单表达式错误。synth_design成功后立即保存raw DCP，再做时钟/blackbox/报告检查；raw DCP未验收前不得称物理PASS。后续报表故障只读重开同DCP补取，不重综。AT137当前无可复用DCP，不能把XPR或IP/cache当已保存网表。

取消普通脚本修复的额外次数门，但原累计OOC≤1800s/24GiB不变：已用671.385747226s，余额1128.614252774s；每次上限为min(1200s,当前余额)，综合静默阈值大于该墙钟上限。单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB、原计量/仿真保护保持。新attempt和全部实耗继续累计；重复同因无新修正、实际资源成本停止或实质RTL/约束冲突才交集中判断，普通打包/Tcl/报告修复无需每次回来放行。首个有效网表及完整所需报告即收束，不因WNS负再换候选或扫参。

本次停点设置过细导致普通脚本问题往返主控，现由A001纠正。继续服务完整推理目标，不新建mission、不改gold、不加P&R。A003的真实LN→Q→完整Wi静态方案已收到，主控继续审核其abort排空和薄接口，工程可独立完成当前测量。


[原始消息收据](../../.research-agent/communications/m004-at138-at139-measurement-boundary-research-20261015.json)

相关文件：[SM004.md](../../project/missions/SM004.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
