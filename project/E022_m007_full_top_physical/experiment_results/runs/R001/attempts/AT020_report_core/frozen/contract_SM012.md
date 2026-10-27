# SM012：父级集成、联合物理与完整请求验收

mission: M007
execution_state: running
verdict: unassessed

按第7–8、11节合入Host/CPU尾部，完整47检查点、120矩阵与30Attention，联合OOC/route/XO/xclbin和真实U55C，200热样本/60s吞吐及单A6000对照。旧软件基准身份可继承，新实际平台/设备与专段预算绑定后运行；没有设备保持board NOT_RUN。

这是已规划的后继范围，不使用SM008/SM009或旧Mission余额；当前没有启动本阶段重工具。普通工程拆分与后继预算由主控集中下达，无需用户逐项转发或确认。

## D-M007-SM012-SINGLE-PARENT-11：唯一资源的 QKV→Attention→WO

2026-10-21；A001集中接续；执行者A010，支持A007；E016/R001。用户已授权新Goal/M007与子智能体连续推进，本合同属于该目标内工程接续。A010在E012/R004新sharedFP受影响回归/一次完整WO的实际出口后直接实施；A007先完成当前prepared系数保护与已启动恢复范围，提供最终接口。三人原预算各自封存，不转入本段。登记不是运行或验收；普通修复、编译、测量按阶段连续执行。

### 写入人与冻结组合

A010新增独占E002/experiment/vivado/module_design/forward_controller内M007 parent/top/resource-router/context-quant-adapter的RTL/TB/runner和source/design.md/results.md增量，以及E016三摘要和原始证据；旧M004/M006父控制只读。A010保留原matrix/A/W所有权，A007仍唯一写Attention/sharedFP/DIV/SFU/bank/coeff，A008仍唯一写TANH/G。不是单人代码库，不撤销其他人的修改。本文更新早期接口准备中“A007接父级”的任务分配；架构和资源边界不变。

生产父必须使用一份laya_attention_resources_v1或其当前原名唯一资源壳、一份原coeff cache、一份纯layer、一份纯matrix facade（含唯一A/W/bias）、一份纯quant/A front。矩阵与layer各自带私有资源的兼容壳禁止进入生产父层次。sharedFP显式选择f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0，DIV选择8bbd14630885f50817e1055da0bec2449f055021b462fbc02bb531389ea05a79；其它最终生产源在首build manifest逐项绑定，待实际回归后才继承范围。A007的PREP系数owner修复是本父生产必要依赖，旧head数值证据按旧SHA引用，窄改动回归另列。

### 固定生产顺序与接口

以[source接口决定](../../../source/m007_single_resource_qkv_attention_wo_20261021.md)为详细映射依据。本段一次命令固定一层Encoder/Decision，M128/K1024/N3072 QKV与M128/K1024/N1024 WO，完整128bit model/numeric、原graph/layout/build和request/gen/source_epoch先验证；内部64bit W key仅是已验证身份映射。系数和Decision bias必须来自同一原模型/层，不能用截断匹配验证完整身份。

父锁存一次命令→真实layer.prepare→公开F32流经quant/A→真实冷W和QKV矩阵→12288个实际QKV32窄写→消费矩阵成功回执/真实释放→一次layer.start→生产RoPE及16head→消费成功layer DONE但保留context所有权→按query/head/half共4096个真实context响应交给同quant/A→全部量化/Aack/发布与layer输出所有权退休→同一matrix执行WO→131072个真实WO输出/完整回执退休。不得TB逐块发命令、跳过head、灌gold覆盖、强制phase/债/状态或reset换相位。QKV写映射及context group=2*head+half保持原决定；输入输出有限反压使用实际信用，仅允许一笔32F32必要保持，不新增整张context副本。

资源按束路由，不能一条全局owner选择屏蔽并行合法端口。QKV阶段matrix持FP/PS，layer在PREP仍接QKV窄写且保护coeff；context→量化阶段storage仍phase4、DIV是phase5。绑定/释放由实际调用者握手，旧owner真实事务未退，父不换路。layer.real_idle不代表context已消费；必须4096实际消费且layer回IDLE才切WO。闲置端口明确定义，未选owner不得看到伪ready/伪返回。

上游量化或矩阵失败：停止新工作，但保留PREP合法QKV输出接收直至上游实际排债和错误回执消费，再合法prepare_cancel并消费保持响应，父保留原上游错误/坐标。Attention活动错误走原abort/错误DONE，正常context弃用才用discard，不能对错误DONE错误调用discard。partial context量化失败时实际已接受读/quant/DIV/A均排清且取消未发布A；新gen重新真实输入/装载。原数值首错规则不改，当前不同模块status需显式适配并保留原错误tuple，不能按最早物理到达随意选全图首错。

### 性能与控制存储

原QKV≤57344、EncoderAttention≤188544/Decision≤186368、WO≤22528拍要求不变。命令/phase派发每个已满足所有真实前提且无外部阻塞的边界≤16拍，新增父纯调度合计≤128拍；真实供数、输出保持、context读/量化、回执/债尾不藏入“免费切换”。Encoder整块仍≤268416、Decision≤266240拍（QKV_ACCEPT到WO_RETIRE）；128拍父调度子帽不是加在原整块帽之外的额度，必须由原总预算内部满足。分别记录全部起止周期和外部停顿，尚无同runtime结果不得把独立周期相加标实测。

已实现layer20691bit和保守matrix963B合计3549.375B，按3550B暂占；父新增控制可用546B，必须逐寄存器/数组计账并合入总≤4096B。默认profile关闭；TB被动测实际反馈与周期。必要有界数据holding归属payload/算术holding必须明确，身份/counter/valid不能改名排除控制账。固定算术管线/credit/tag仍在总物理资源账保留一次；不靠声明相位互斥扣除真实实例。不在本段声称联合物理fit。

### 有界验证与成本门

1. 先真实展开唯一父层次，检查所列资源计数、实际连通/无未驱动输入、payload/控制声明账。生产源和实际fixture冻结后，再以原Encoder0真实F32输入做父QKV前三超块前缀：TB只观察正常自主FSM，不提前发布父成功；真实out→公开QKV32写、token/head/half和数值逐位核。再据此同版成本门运行完整QKV→一次layer.start及首完整head，分别标前缀/完整边界。
2. 真实主参考复用E010原模型的QKV/RoPE/score/prob/context与E015 AT007 Encoder0的全128 context/WO；不重算全模型gold、不用DUT结果作期望。完整16head及WO同runtime主例只有同组合/同observer的完整分段成本样本支持才启动。不能用独立head或旧matrix速度直接充当父链测量。每个阶段终点和完整终标分开，前缀不是任务done。
3. 父受影响短例优先实际量化失败（零QKV）和晚W故障（已有真实QKV写）→排债→PREP取消→无reset新gen重新输入恢复；真实最后QKV写held阻layer.start；held错误/成功回执不提前换路；完整128bit身份上半部错、有限背压和活跃共同reset。没有合法口能触发的情况标NOT_RUN，不force内部状态或恢复假成功。
4. 可抽独立生产context-quant-adapter，用合法公共源peer和同一实际quant/A/DIV验证4096组顺序/反压/末响应/partial取消；它必须是父实际复用的模块。此局部peer仅签consumer边界，不能为layer虚构16head、DONE、context_valid或父控制捷径。完整真实layer输出交接仍由主例签署。

E016/R001独立上限reference180s、static1800s、RTL3600s、OOC0s；240s RTL留受影响恢复。未知pilot≤120s，后续单次RTL≤1200s、static≤600s，且不超余额。完整成本按同版当前实际observer与真实阶段wall数据，安全系数≥1.35并加10s启动余量；主例估计+240s恢复须在剩余内，已完成同边界实际费用可作更保守下界。不能将旧timeout原样加帽，不继承旧1800s长例特例。全进程及后代持m007_heavy.lock；CPU0–3/nice19/idle、MemAvailable>192GiB，reference≤16GiB/static≤24GiB/RTL≤8GiB、RTL≤40Mcycle。独立真实语义停滞120s，不以日志mtime/任意打印当数值进度。

主控内部阶段门不要求用户逐项审批。若完整主例成本不成立，保持COST_STOP/NOT_RUN，交付实际组成、前缀、局部consumer与具体成本瓶颈，继续有用接口工作；不把未完成整链写成父完成。无新增板卡/GPU/安装、全阵列OOC/P&R、全30层gold或物理预算授权。完整FFN/30层/200热请求/资源/300MHz与U55C仍属于后继验收。


2026-10-22执行更新：用户明确“继续任务”，按M007现行合同恢复；此前八lane收尾暂停作为历史保留，已验范围和独立预算不重置。当前入口为mission/current.md及results/missions/M007_resume_20261022.md。


## D-M007-SM012-SIM-COST-13（2026-10-22，E016/R002）

R001原cost出口与逐SHA结论先冻结。AT013同组合首head测得完整16head的保守费用3494.951523668s（尚不含WO）超过1200s单次帽，阻断当前完整验证。实际R001编译为xelab O3/debug typical，故本段只测可复现的仿真观测开销，不改硬件时序/RTL/数值/形状，不延长长例帽。A010继续唯一拥有forward_controller中M007 runner/TB及E016证据；其余owner不变。

在同一当前parent SHA和同一TB/原fixture上，分别展开debug typical与debug off（支持性以本机工具实际结果为准），两个snapshot仍含所有原数值/协议断言和真实生产模块。只运行相同QKV3短前缀，记录全部input/quant/A/W/QKV握手、独立gold、真实phase cycle、实际墙钟和精确编译选项。不能删除TB内部断言/信号引用来提高速度，不用模拟算术替身/预填完成位，不减少checker频度。debug off若不提供Tcl完整层次，只签该snapshot实际数值/协议范围，不能借另一个snapshot伪造其hierarchy结果；保留same-source编译绑定与所有warning/error。

先比较同版两条实际短例；无改善或不兼容即如实出口，不反复换旗标盲试。即使有改善也不自动启动16head/WO，必须有各实际phase成本证据后另做判断。不能把仿真加速解释为FPGA吞吐提升。

独立预算reference0/static300/RTL300/OOC0秒，R001余量不转。每次static/RTL≤120s、真实语义停滞≤120s，原全项目锁/CPU0–3/nice19/idle/MemAvailable>192GiB，static≤24GiB/RTL≤8GiB/40Mcycle。无安装、其它模拟器、P&R/板卡/GPU/新gold。本段未知工具选项失败及费用保留，普通脚本修复连续执行，阶段末一次交付。


2026-10-22 SIM-COST-13阶段出口与接续：增量58限定接纳同源QKV3 typical48.806s/off54.404s、相同8364拍，单样本无提速；不继续配置扫参。实际派发A010只读核当前父完整16head→context4096→WO131072合法端点、原checker缺口、父done完整身份/held及同当前构建先首head后完整链的独立预算建议。旧3494.95s仅旧版估计，不直接放行。无生产修改/EDA，脚本单次≤20s/1GiB新增累计≤60s/CPU0–3/nice19/idle独立记账，不动封账R001/R002。完整运行合同由主控在端点和成本依据明确后集中确定。


## D-M007-SM012-FULL-PARENT-15（2026-10-22，E016/R003独立阶段）

接纳A010只读准备为真实测试环境缺口定位；当前e354父源码已写完整路径，未知动态行为不提前判PASS/FAIL。正式接续完整原Encoder0一次父命令→真实QKV48块→RoPE→16head→真实公共context4096组→同quant/A重新发布→唯一W/cache真实WO冷载→WO131072值→首次父成功。此处完整指这条Attention父链，不签完整FFN/Encoder/30层。

A010唯一拥有forward_controller内M007父级/TB/runner和E016/R003证据；共享FP/storage/DIV/layer与G只读直接实例化，冻结当前依赖以避免其他owner后继改变身份。不是独占代码库，不回退他人编辑。先完善测试环境，不预先改生产接口。实际暴露的合同内普通生产错误可修复并做受影响回归；实质接口/数值/容量变化报主控，不私加第二实例或仿真专用生产shortcut。

TB/peer/checker按planning/full_parent_successor_20261022/planning.md所列完整边界实施：各head独立计数与maximum128终断言、全部原score/prob/context逐位、RoPE2048commit、真实layer Check/身份；真实context4096响应→4096quant/Awrite/ACK并一次发布，layer/context/quant真实债和所有权退休；实际AR接受时锁定QKV/WO源，不能全局phase切换旧在途数据；WO16块连续issue、公共4096响应/131072值对原独立gold。正常链只发一次父cmd，不中途reset、逐行代驱动或预填context。全16head参考和原WO参考已有262144个布局位型对应检查，不生成新gold。

全链终点独立核父243bit回执的status/source_status/domain/tuple预期0与原request/gen/epoch；逐拍禁止在16head、4096context、真实A发布、4096WO输出与WO真实DONE/资源退休前发布父DONE。用原out_ready在中间和末WO输出各有限阻塞，核完整输出稳定/无提前成功；原done_ready保持5拍，既核独立期望又核稳定，最后真实消费仅一次。无合法外部口可指定末context保持的定向项仍NOT_RUN，不force内部ready。保留全部原8非法身份拒绝及原checker频率。

建立同一个完整TB/snapshot，STOP_AFTER_HEAD=2只在真实第二head退休后结束测量；full模式继续至父成功退休。两模式在初始化时都加载/冻结所有原fixture并启用全部checker，不能用轻TB估完整重TB。首先同snapshot合法QKV3短pilot≤120s，随后真实两head pilot≤1200s；该专用pilot建立在本项目已完成实际783s首head及同源QKV3的成本证据上，旧结果不冒充本次通过。

新独立预算reference0/static600/RTL6000/OOC0秒；不转R001/R002余额。static单次≤120s，RTL未知短pilot≤120s。完整父链首次专用单次≤3600s（不采纳5400s建议，保持项目3600s单次上限）；至少保留600s给短恢复/审计，不能耗完才留空。原40Mcycle、真实数值/实际响应语义停滞120s、CPU0–3/nice19/idle、MemAvailable>192GiB、static24GiB/RTL8GiB和全项目重工具锁覆盖全部后代保持。不用日志mtime或任意打印续期，不安装工具/板测/GPU/OOC。

同版成本门固定：P2为本snapshot从启动至真实第二head退休的实际wall，Hmax为两个真实head begin→end的较大wall，Q为启动至末QKV实际提交的wall（含加载/预备/量化）。计划E=1.10*(P2+14*Hmax+Q)+10。Q再次作为尚未测得context+WO段的保守工程占位：与QKV同K1024、WO N1024较QKV N3072小，且与QKV同原输入数量/唯一矩阵与checker结构；这是一项明确可证伪的成本假设，不是WO实测，也不是硬件性能结论。runner须记录该依据和原E012独立WO203.558494425s作为背景，不把分段拼成已测串联。若实际peer/TB增量使上述单调界失效，不能静默放行，应具体报主控。

仅当前两head真实数值/身份/债与strict进度通过，且E≤3600、剩余额度≥E+600时，自动启动一次完整例，timeout取ceil(E)或不超过3600的固定上界并绑定源码/build/fixture/TB/guard/命令。若成本门不满足，交付真实成本出口，不能暗改系数、提高单次帽或重放旧前缀。完整例发生新功能错误后，保留失败；先合法局部复现/修复，是否再跑整条由主控依据剩余和新证据集中确定，不原样延时重试。

cycle分别记录父cmd接受、QKV matrixcmd接受/末提交、layer start/每head起末/公共context退休、WO matrixcmd/末输出/真实DONE、父完成消费；原模块QKV57344/layer188544/WO22528与调度要求保持，源合同的总边界必须有对应实际事件。原Encoder Attention子段268416目标只按合同对应事件比较，不称完整Encoder已通过。外部held停顿独立列出，同时保留原始总周期，不偷偷扣除无效工作。成功即给主控全链阶段交付；失败、数值通过但周期超帽、COST_STOP、NOT_RUN分开。完整context故障→新gen、Decision/bias、完整首错、FFN/30层和物理/上板均保留后继。


## D-M007-SM012-CONTROL-ARENA-16（2026-10-22，E018/R001）

增量60/61已接纳当前G1707.625B及原Encoder0完整Attention父链。下一确定的结构是将layer的12288bit QKV/context覆盖控制与G math的11343bit控制映射到**同一份12288bit物理FF状态**。两者真实生命周期不重叠时更换视图；不使用附加head/RoPE私有统计、不覆盖持久Check/系数cache/matrix/front。当前保守联合投影3746+1707.625−11343/8=4035.75B，余60.25B给新增owner/rearm和实际胶合控制。投影不是实现；所有新增FF/取整须实记，超过4096B则如实不合规。

A007接E018_m007_control_workspace_joint/R001，唯一拥有新增workspace组件/状态布局/TB及attention_and_fp_engine中所需layer覆盖接口。经A008完成交接，暂时新增独占vector_and_ffn的laya_m007_g_math_v1.sv和laya_m007_g_engine_v1.sv中共享控制接口及相关受影响TB/runner；A008此阶段不写这两个文件。G算术、pairs/pool/TANH/数值叶保持原合同；A010的forward_controller仍由A010独占，当前完整父构建冻结，不因新共享源码回写PASS。工程非独占，保留其他人编辑。

固定接口方案：layer增加可选external-control模式，外部只提供qkv_coverage的12288bit q与接受其同周期next；原低4096作为实际context消费覆盖的生命周期保持，不新增镜像。G math增加可选external-control模式，将AT133按原声明排序的11343bit控制（tag_hi、资格/错误mask、live/available/sent/received、expected/对齐tag与valid、指针、上下文/顺序、各真实债、covered/evaluated及首错）组成固定有版本布局的q/next；数值payload25600B、固定数值对齐736B、pre_credit内部状态、G pairs/pool及engine私有状态仍独立，不偷换容量类别。G engine只透传外部控制端口及使能。默认独立模式保留现公开接口行为；共享模式由实际展开选择，不同时存在私有控制reg和影子workspace。

workspace仅有一份state_q[12287:0]，A视图全12288bit，G视图低11343bit，G时高945bit无消费者。不能增加1R1W RAM替代，因为G同拍多向量错误/标签更新有并行写需求；采用packed FF next-state/owner选择。消费者q/d抽取须严格保持原非阻塞赋值的旧值RHS与同位写优先级，尤其满环consume+accept、u/t同拍OR、FP/SFU/输出同拍债变化；不串行化、不加数据拍延迟、不改任何算术。默认本地模式与external模式使用同一next逻辑，防止两套算法漂移。

固定phase协议：初始A owner。只有不同目标的owner_req_valid/ready真实握手才切换；same-owner请求不清状态。当前owner实际安全退休才ready：A为layer L_IDLE&&real_idle，且head/RoPE确已idle、无held done/响应；G为engine_idle、无held output/done/needs_discard、两槽及实际FP/SFU/bank/precredit债全0。不得以单pending0或layer DONE代替。目标私有外层controller必须idle；inactive视图内随机位不能被拿来判目标已退休。owner交接进入一拍REARM，两个消费者均不准入，统一state清零；然后新owner使能。最多以原owner/target/rearm少量状态实现，禁止复制64/128bit请求身份；真正parent集成时由现父绑定限定phase，组件不是独立Host命令入口。

inactive消费者不得发布req/result/done，控制next即使组合计算也不得写workspace；G pool_reset_n资格需含共享模式enable，inactive时不能让另一owner的状态位触发叶子。所有时钟仍原时钟，不门控时钟。layer返回A后必须在新prepare前获得已清覆盖；持久Check、系数cache、公共身份/快照和free-running clock仍在原物理状态，不被workspace覆盖。所有权切换时不得清其他owner真实在途任务；实际安全条件必须在组合实例中由真实状态连线，不以TB常量safe代替生产安全逻辑。

本段有界实现/验证范围：先精确布局和单workspace公共接口测试，核并行写、保持、非法提前切换与一拍rearm；再真实layer PREP写入覆盖、重复/边界地址、held cancel回执→真实取消/idle后A→G，真实G三块/held/满环/坏返回真实债保护及同版中样→完整原335872正常结果/原周期→实际done消费和资源退休后G→A新prepare/覆盖重装。完整数学正常仅使用原独立fixture；不得以保存norm/context替代真实待签生产计算。layer此局部不启动Attention算术，不能据PREP/cancel签完整16head正常交接；未来父联合需另外补同runtime真实context释放→G路径。可按工具成本先完成生产消费者有界组合，未覆盖项明确保留，不伪造资源回复来签正常完整图。

真实协议错误可做原匹配status故障/显式discard后的安全切换；旧generation/同低8不同seq反例保持。新schema或next-state抽取发现普通实现错误连续修复，独立期望与全部原断言不减。未变数值叶全域测试复用原身份。层次核共享模式确实只一份workspace、无私有控制影子；逐字段声明账含新增owner/rearm/胶合逻辑。此阶段不签联合物理fit/896DSP/300MHz，仅签所测组件行为与可核的当前声明容量。

新独立预算reference0/static600/RTL1800/OOC0秒，无E015/E016余额转入。未知pilot单次≤120s；static单次≤120s；有当前同build/fixture实际pilot支持后RTL单次≤600s、总额留120s短回归/归档。全项目单重工具锁、CPU0–3/nice19/idle、MemAvailable>192GiB、static24GiB/RTL8GiB、真实语义停滞120s/40Mcycle保持。不启动全父长链/模型/新gold/OOC/P&R/板卡/GPU。阶段完成交主控集中验收，不逐编译请示。

### 并行FFN接口准备（A010，无EDA）

A010在R003冻结后只读核现Wi→双槽G→量化/A→Down的唯一资源后继：从原保存产品确认Wi5248列与G两半2624列的精确对应；列出既有matrix/W服务按64列block的实际调度/预取/输出顺序，核配对顺序是否需要0/41、1/42等成对排列（必须据源码与原gold验证，不把此候选当定论）。明确两槽G消费与Wi写入重叠的背压、原独立首错排序、Down准入和全G成功/错误边界，以及residual/LN的真实输入出处。只给一条可执行后继与所有权接口，不改RTL/运行EDA/生成新gold，不复活旧M004。更新现forward_controller source设计准备段和独立planning目录；轻脚本单次≤20s/1GiB新增累计≤60s，CPU0–3/nice19/idle独立记账。主控据精确映射集中下达FFN合同。


## 2026-10-23 集中接纳：CONTROL-ARENA-16 / FFN映射

增量62核1561项，增量63核34项。接纳E018/R001同版唯一12288bit workspace、2 owner/rearm FF、声明联合4036B/余60B和原335872 G正常结果/42171拍；实际PREP/cancel→G→真实退休→A重装及所测坏返回/peer恢复保持。AT133布局措辞明确为已冻结census entries的低到高顺序，schema v1逐字段偏移为接口权威，不要求按源码物理行号排序；无需为这个文档澄清重跑。新共享layer不继承旧e354完整父链PASS。4036B不含后继尚未实现的FFN/LN额外控制，不是物理fit。

接纳A010 native Wi映射0..81，每块原Wi两半各32列；禁止0/41重排。原Wi/G全量字节核对和原权重布局有效，旧E012混合诊断Down输入与本链G不同，不能当本链gold。当前下一步只补两项确定前置：G生产者取消/真实排空，以及原同输入Q8(G)/Down局部独立参考。整FFN接线在这两项交付后接续，不启动完整父长例或整模gold。

## D-M007-SM012-G-CANCEL-17（2026-10-23，E018/R002）

A007继续唯一拥有G engine共享控制接口及本段TB/runner和必要实际组合透传；G math、pairs/pool/TANH数值及固定layout不变，若纯透传需要修改组合壳属于本段。A010不写这些文件，A008暂不恢复并行G编辑。不是代码库唯一使用者，保留他人工作。

固定新增接口为producer_cancel_valid/ready、producer_cancel_request_id[63:0]/generation[31:0]/epoch[31:0]及组合reject_valid；身份对比现rsp上下文，不另存128bit身份。仅control_enabled且active、尚未取消、无held DONE时接受匹配请求；不接受错身份/重复/未活动请求，不修改现有工作或真实债。取消与正常终结同拍时，合法取消优先并明确终态cancelled，不出现两份DONE。同拍已被实际接受的fill/read/FP/SFU/写ACK都计入现债；所有已发布valid/held输出和bank事务必须遵守原稳定/ready协议，不能为了取消撤销已承诺请求。停止后继fill和新bank读；已接受bank响应仍经现math路径排完，已发算术继续，真实输出由调用者消费后才退休，禁止reset/清债代替。

DONE新增done_cancelled独立资格并保持至DONE消费，原done_status保留真实peer故障8或已经观测的数值状态6/0；当cancelled=1时这些数字不构成全域成功/全域最早数值结论，父必须保留原Wi错误而非以取消覆盖。取消终结需math_idle、实际FP/SFU/precredit债0、写回应退完、bank issued=returned、无held out；无需虚构全覆盖或82块完成。正常done_cancelled=0保持原规则。取消后needs_discard=1，消费DONE后仍必须实际合法pair discard，未完成槽/覆盖才可清，之后无reset新gen；禁止提前control_retired/owner切换。新增控制逐bit计账，复用原上下文/回执，联合声明仍≤4096B；发现不能满足时报告实际差额，不改类别或额度。缺失真实返回按原故障/复位边界处理，不能凭计数强清恢复。

独立验证：错身份/无活动零影响；未完整half/块时取消；已有bank/FP/SFU在途与输出held17时取消；取消和真实填充/返回同拍；取消DONE held17→消费→真实discard→新gen原3块12288结果；取消阻owner换相位；正常同版3块/held、必要中样→原完整335872正常及42171拍不变。旧数值叶与不受影响tag测试保留旧身份，不重跑全库；所有原失败保留，测试不能force内部债/状态。

E018/R002独立预算reference0/static300/RTL600/OOC0秒，无旧余量转入。static和未知pilot每次≤120s；完整正常仅在同build中样支持时，保守1.35比例外推加10s≤300s且剩余额度≥估计+120s才启动。否则保留未测范围。CPU0–3/nice19/idle、全项目重工具锁覆盖后代、MemAvailable>192GiB、static24GiB/RTL8GiB/40Mcycle/真实语义停滞120s保持。普通修复连续进行，末尾集中交付，无新逐次审批。

## D-M007-SM012-FFN-REFERENCE-18（2026-10-23，E016/R004）

A010唯一拥有forward_controller中新增局部参考/fixture准备及原source文档增量、E016/R004；本段不改生产RTL、不运行EDA。以E015 AT007已冻结原Encoder0 norm_ff/wi/G及原模型权重为唯一输入来源，复用原独立CPU参考算法、逐次舍入和归约顺序，生成本输入的Q8(G) codes/scales与Down完整128×1024期望。必要norm_ff的quant/A期望也用同一原参考。不得用DUT输出、旧混合诊断行、Python宿主浮点简化或重算整模型替代。

先核原reference源码/编译选项/运行库与原权重身份，核已有交集以证明调用适配无误，原G只作为参考程序输入，不预填后继RTL。局部one-row真实pilot后按1.35×128倍+10s估计全128成本；估计≤120s且余额保留20s才运行全例，否则交付实际可完成范围和成本，不加时原样重跑。当前字段/模型/归约若缺少权威来源，具体指出缺口并继续字节/地址准备，不能自行换参考规则。记录代码、工具、输入/输出SHA、逐阶段事件/费用和独立参考来源；终点是后继测试可使用的精确fixture，不是RTL PASS。

同时完成唯一FFN接口的具体连线表：native Wi→双槽G→单1024bit拼接→同quant/A另一槽→成功屏障→Down；PS/G按束路由，原G pool和TANH8各一次，storage/FP/DIV/cache各一次；列出现父所需新增控制精确预算和真实residual/LN未接边界，不把本输入边界称完整Encoder。G cancel按17合同只读引用，未交付前不依赖虚构响应。

独立预算reference180/static60/RTL0/OOC0秒；static仅局部CPU参考编译，单次≤60s；未知reference pilot≤20s/完整≤120s，reference16GiB、CPU0–3/nice19/idle、MemAvailable>192GiB及全项目锁保持。不转R003费用，不安装、不做GPU/板卡/P&R/全模gold。原60s只读准备账已经封存，本段新费用单列。


## 2026-10-23 用户明确连续完成范围

用户要求继续完成Wi→GEGLU→Down同一次运行、残差/LN接线、完整Encoder和30层模型验证。此指令持续有效，阶段交付后主控立即核对并接续，无需用户逐段催促。旧失败/预算不覆盖；当前硬件/平台物理限制不变。30层指原28Encoder+2Decision，不能用重复Encoder0或诊断输入替代。

### D-M007-SM012-CANCEL-END-19 / E018 R003

A007复用R002纠正后的AT021 TB及当前未改的生产engine6b8b0114，完成原完整正常成功终结同拍取消→唯一cancelled DONE held17→真实消费/discard→owner回A重装的缺项。旧AT020 FINAL_REAL_DEBT仍FAIL，不从未打印原债推断正确性。首先核源码/TB差异及费用依据，不重新做未变一整套叶子/正常完整例。依据R002实际123.385/129.925s及176.570s保守界，本次纠正后的不同TB允许一次完整RTL≤200s；不是原样延时重跑。独立reference0/static120/RTL300/OOC0，保留60s短回归/归档；若新失败先诊断，不自动再次全量。原资源/锁/CPU/内存/真实语义停滞保护保持。A007继续只写G必要TB/透传；生产修复若确需则保留新SHA并重测受影响范围。完成后转给主控，不等待用户。

### D-M007-SM012-FFN-CHAIN-20 / E016 R005

A010接现parent kind3 Encoder0/layer0唯一FFN路径：一次公开norm_ff请求→同quant/A槽0→唯一Wi native82块→原双槽G→4×8拼32→同quant/A槽1→完整成功屏障→同matrix/cache的Down→公开131072输出与独立父成功回执退休。采用R004/reports/ffn_connections.md全部已核连线和首错/取消要求，不引入保存G代驱动或逐块TB命令。现kind0/1/2 Attention语义不变；新kind3为明确子图入口，不能称完整Encoder生产BEGIN已完成。

两份现有cmd_tensor/base/span在kind3绑定原manifest family3(layer0 Wi)和family4(layer0 Down)。tensor key仍按原manifest ordinal+1完整查表，扩展原catalog而非按shape猜测。完整model/numeric/table/graph源身份维持，当前RTL/build manifest单独绑定；不能把旧e354构建标签当本次新RTL证据。请求/代际/地址/spans/维度/无bias检查固定。亲自核对R004 proposed G/q原子接受不存在组合环；若ready依赖valid，采用保持的FSM握手并如实增计位数，不能为了20bit投影伪造ready。

在原唯一parent内接一份shared workspace、实际layer外部coverage和G外部控制；若mode无活动layer，也必须基于实际安全资格切换。复用唯一storage/FP/DIV/cache/quant，PS与G按束并行，同phase1身份，不以global owner屏蔽合法束。G原56mul/16add池和TANH8各一次；现EXP/TANH尚未物理共享，必须全部实记，不能虚签896DSP。禁止带私有resource的validation_shell进入生产父。Gengine由A007唯一写，A010只读6b8b0114当前接口；共享文件修改先交接，不并行覆盖。

复用原5bit父state及两份descriptor，默认计划新增20bit assembler/握手控制、唯一128B payload holding；逐字段最终重计，包括所有新增owner/tag/error/valid，当前4036.375B底账加20bit为4038.875B只是预算。若额外位需要，使用实际剩余额度，≤4096B保持；不得将LN或未来整Encoder控制漏算。A保留4096/10496组真实写ACK/coverage/发布；Wi/G重叠不合并W/PS/G三个生命周期。Down必须等待Wi/G真实成功、G未cancelled、全41984向量/10496组与成功producer_close后的quant/A发布/退休以及真实债清。按Wi→G(rank,row,col)→Q8(G)→Down图顺序保留首错；下游失败回执不能覆盖上游原错，G32bit状态显式映射，不截断。

参考前置采用原R004独立参考、相同原模型/输入/G，固定拆为8批各16个不同连续行[0,16)…[112,128)，总128行一次覆盖。行间量化/Down原数学独立，分批不改变每行group0..81逐次舍入；先每批保持原代码/库/权重身份，生成及校验各自codes/scales/Down，再按真实row拼接，不拼RTL通过。每批≤30s（R004实测整child单行0.679s给1.35×16×P+10=24.658s依据），全reference≤180s。比对row0与R004原产品逐位相同，并用scalar/batched quant和原诊断交集核独立参考；不延长旧127.265>120的全量单次计划，不重跑整个模型。所有原fixture仅用于公共输入norm_ff和checker，Wi/G/Down生产结果都从实际握手取得。

实现后首先同源完整构建/唯一实例与控制账，再原norm_ff真实量化→Wi前三块→实际G原12288结果/节点＋10496目标的真实前缀quant/A；不得提前A发布或父成功。短例合法输出held/第三槽回压/错误Wi→Gcancel→front失败close/真实discard→新gen，以及末输出/父DONE保持。旧Attention受影响最小QKV3编译/前缀回归，完整旧父结果仍冻结原身份。没有独立故障口者明确NOT_RUN，不能force内部状态。

同runtime完整主例必须从一次父命令真实跑Wi82块/G335872/A10496/Down16块131072，并对全量独立参考逐位；上下游成本由本完整checker同snapshot pilot测。先真实Wi至少3块短pilot≤120s；若短pilot不能完成，先定位开销/分段事件，不直接拉长原timeout。得到当前完整16块Wi/G交叠样本后，按1.35×已测固定初始化+每块保守最大费用外推剩余Wi与Down，加10s，明确未测Down成本依据并保持可证伪；满足单次≤3600s且总余额≥估计+300s才自动启动一次完整例。旧独立G/旧Attention速度只能作背景。不能删除断言、减shape、替换真实计算或降原周期帽以通过。

E016 R005独立reference180/static900/RTL6000/OOC0秒，未知pilot≤120s；static单次≤120s，实际已测段支持的16块pilot≤1200s，完整专用上限3600s；RTL保留300s短恢复/归档。旧R004/R003/E018余额不转。原CPU0–3/nice19/idle、全项目一重工具锁、MemAvailable>192GiB、reference16GiB/static24GiB/RTL8GiB/40Mcycle、真实语义停滞120s均保持。主控集中阶段核验，普通修复连续完成，不向用户逐次请示。

### 并行残差/LN与30层架构核定

A011（Astra xhigh）只读当前生产原始接口、原CPU47检查点/120矩阵和M007驻留银行，给一条固定的真实skip→Attention输出残差→无gamma LN→FFN→同residual回加→下一层路线；明确hidden/skip ping-pong物理位置/容量/同步端口/epoch和30层descriptor供给，不能额外复制整hidden或按假定互斥删实例。核LN控制复用计划和实际未计字节、FP/DIV/LN-bank阶段交接、原Decision无RoPE/特殊bias/FC1/FC2及type/gather尾部。不得改数值/性能/存储上限；不足必须给实际差额及最小可实施更改。当前只读，不运行EDA/新gold，不改A007/A010生产文件或主控索引。产物为source/m007_residual_encoder30_20261023.md，提出明确接口/生产者/独立期望及有界验证顺序；主控集中核定后由工程接续。

## D-M007-SM012-ENCODER0-PARENT-24（2026-10-23，E016/R006）

主控采用source/m007_residual_encoder30_20261023.md §11固定完整Encoder0父接口，继续用户四项目标。A010保持唯一forward_controller owner，可在R005冻结AT027运行期间先写独立single_parent_v2/生成器/TB/runner和source说明，不改任何v1冻结生产/原snapshot或R005收据；新EDA只在R005实际出口与owned清空、A008必要v3窗口及A007共同arena接口就绪后串行进行。A007拥有四owner/resource wrapper与H/Q/LN provider，A008拥有LN纯engine；直接协调公开束，不跨写资源。不是唯一作者，保留他人修改。

固定kind[2:0]=0..3原语义、4完整Encoder0、5..7拒绝；kind4完整4096组H实际写入/finite资格→真实H供quant/A→QKV/Attention/WO→WO实际写Q→H残差→H真实同步读送plain LN写Q→Q真实供Wi/G/Down→Down实际写Q→末H残差→4096组真实H输出→全资源退休/DONE。参考只checker，无中间gold注入/逐块TB命令。当前两descriptor在旧WO/loader/cache/FP/PS/A/层结果完全退休后，按公共descriptor流实际覆盖为tensor60/88；不增四份副本。source_epoch+16*layer+code0..6真实进入命令/租约/tag/ACK，复合岛同epoch，跨岛scratch先release/reacquire不清payload。具体端口、span、错误排债与最终保持以§11为准，改父state范围判定避免state>=20误归类。

默认旧0..3范围兼容；新完整0运行初始H来自原embedding_norm真实输入，最终encoder_00_out原独立checker已实际SHA核过，见results/reviews/m007_model_checkpoint_inventory_20261023.json。对实际public输出按坐标/身份记录位值并产生原始RTL产物和完整性标记，支持未来合法分段诊断；不把旧仅有比较PASS重建为实际RTL输出。记录四个矩阵4/32/60/88真实接受/完成、完整shape、每段源/结果及退休周期；异常停止后继、取消真实在途、无reset新请求恢复，旧数据不能有新资格。

独立reference0/static900/RTL7200/OOC0秒；旧R005余额不转。unknown/static每次≤120s，已测static必要构建≤300s且余额允许；RTL原单次≤3600s/8GiB/40Mcycle、120s真实语义停滞不变，保持500s末段恢复/归档空间。首先同build短正常/真实交接及成本pilot，以当前实际初始化、head、FFN块、residual/LN/输出分段测量建立保守全例界；必须E≤3600且余RTL≥E+500才启动一次完整kind4。旧Attention2828.97s与旧FFN墙钟只能作为背景，不能相加称新top实测，也不能把编译snapshot当runtime恢复。无法过门时只做已定义公共边界的真实数据分段诊断，明确SEGMENTED_RTL_DATA_CHAIN并保留完整kind4 NOT_RUN/COST_STOP；不延原timeout。

允许在当前独占TB中作数学上完全等价的packed比较/失败后逐lane诊断以降低仿真解释开销，全部原独立期望、节点/覆盖、错误断言和性能计数保持。只能经同版实际因果pilot证明提速，不能删除checker/改gold/降低精度或把未来预测改为实测。生产其他owner的CE优化仅只读建议，另由owner按固定数值/周期/债合同实现并做受影响验证，不跨写。

CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具锁覆盖后代、static≤24GiB保持；每个后代政策按owned pid/start_ticks实际检查，不以leader代签全部。源/运行/失败/完整费用冻结不改，无OOC/P&R/上板/安装。实际父4KiB census必须包含最新FFN20bit、A007实际provider和所有胶合/异常/refill，投影不是fit。阶段最终按normal/恢复/原入口/成本与全Encoder范围集中交付；30层catalog和Decision后继依此实际交付另定，不降低原完整30层目标。

ENCODER0-PARENT-24 ABI补充（主控增量76接纳A011§11.6）：旧kind0..3仅原BUILD_ID7209eb09c3f265363cfb274f7790a733，kind4仅ENCODER0_BUILD_ID d92a1f8e927c3051289016db36f20d27（固定ASCII契约SHA256首128bit，完整源码hash仍另记）；其它kind拒绝。新增H/resA/LN/resF共用原domain7，tuple高8bit精确stage8'h80/81/82/83及下述§11.6固定96bit envelope，原旧pack stage3和旧0..3错误映射保持。父numeric1/protocol2不变；H/VECTOR source6/8，LN source零扩真实done_kind1/2/3；已有主因不被清理cancel覆盖，未预锁live数值候选。完整位偏移、protocol原因/location与source映射以§11.6为唯一新增ABI，不把epoch或CPU Check编号混作stage，不扩状态位、不伪称已仿真。


## D-M007-MODEL-CATALOG-25-STATIC（2026-10-23，架构接续）

复用A011已指定Astra/xhigh，仅追加source/m007_residual_encoder30_20261023.md及同前缀机读依据；不写RTL、主控索引，不运行EDA或新gold。读取当前四owner组合和parent_v2，确定Encoder0以后原28+2图的设备两槽descriptor reader、73,728B bias/4KiB gamma/12KiB type初始化资格、sliding/final LN/type/Decision ReLU流的固定接点及精确管理位增量。当前已知投影含独立provider33bit为32491bit，父新28bit和未盘点胶合还须真实计入；不能借未实现复用签4KiB。给最小可执行后继及验证出口，实施预算另按实际交付确定。真实分段RTL数据链只作诊断，原一次BEGIN完整模型义务不变。研究只读脚本每次≤20s/1GiB、CPU0–3/nice19/idle，无新agent或重工具；已实际followup，不重新等待用户。

## D-M007-SM012-MODEL-CATALOG-28（2026-10-23，E020/R001，已实际派发）

用户完整30层目标下，采用source/m007_residual_encoder30_20261023.md §12.2/12.3/12.6固定接口。A008完成TANH-IDLE-CE-26并冻结交付后，由主控实际followup复用同一Sol/xhigh执行者；本段记录不表示已经运行。仅新增E002/experiment/vivado/module_design/model_catalog的reader RTL/TB/source及tools/m007_model_catalog.py、对应tests和E020证据。A010唯一写父/W口mux/transport_idle/两描述符槽/bias vault；A007唯一写type bank/VECTOR/共同wrapper；本段不跨写。保留他人修改，不恢复旧Host任务或预算。

模型metadata BO固定8192B、有效7936B，header256+120×64B records、尾256零；不是额外权重tensor，不占原输入/尾部BO。逐字节格式、五个完整SHA身份、records SHA/CRC64、120条固定图映射与4port跨度按§12.2；CRC64/ECMA-182按实际地址递增byte/MSB先/init0/xorout0。header或CRC不能冒充设备计算SHA。Host工具从原模型打包identity/WeightKey/shape绑定生成并独立复读检查；不任意发明缺少的完整SHA或实际HBM aperture。合法诊断基址可由TB给出并明确SIM地址，部署地址等待平台真实BO/aperture；每port65bit端点和catalog不重叠检查保持。

reader仅2bit IDLE/AR/RSP/DRAIN、标准AR/R、单64B事务，req_word0..123，ARID7/ARLEN0，无data或身份holding；父必须稳定base/req_word直到idle。AR一旦提出不撤销，RVALID/data真实透传背压，错RID/RRESP/RLAST给fault；非RLAST实际drain至末R，不能伪清。两槽仅在真实无fault返回接受时覆写；TB两槽为接口peer，不代签A010生产mux。旧W完整idle门/实际借port0和归还由后继集成测试，不用constant safe声称已完成。

本段可以从原GGUF读取仅实际gamma1024F32、八组Decision bias共18432F32和三条type Q8_0，按原embedding_row数值算法一次setup展开type3072F32；输出为模型初始化系数而非运行gold。保存原tensor名/WeightKey/offset/原始字节SHA与展开产品SHA/操作依据，原输入不改。不得运行全模型、重造47checkpoint、为RTL结果生成新gold或预装中间激活。若原包缺完整必要identity先报准确缺口，独立reader短例继续。

必要独立验证：header和全部120record格式/CRC/映射/跨度，首尾record错、CRC错、非法数值/溢出/重叠拒绝；RTL合法读、AR held17/R held17、连续两槽、bad RID/RRESP/缺RLAST多拍排空，开始/结尾reset失效并新请求恢复，真实未完事务不报idle。独立参考以固定格式/标准CRC检查向量和原模型元数据，不能调用DUT计算同一CRC当gold。报告actual AR/R次数、真实fault/held/drain及所有控制位；只有reader与Host工具范围，不签设备全setup/model_committed、完整层/30层或实际DMA。

独立reference120/static300/RTL300/OOC0秒，未知/static/RTL单次≤120s，reference≤20s/16GiB，其他原内存/CPU0–3/nice19/idle/MemAvailable>192GiB/重工具锁/owned清理与120s真实停滞保护保持；留60s收尾。不转旧余额、不安装/OOC/P&R/GPU/上板。完整Encoder0数学及必要CE联合pilot优先重工具；ordinary实现修复连续，阶段交付主控集中核验后接父生产mux与全图正常推进。

2026-10-23 D28已实际followup A008并登记E020，工程正在独立reader/打包工具准备；准备身份不等于已运行EDA。

## D-M007-SM012-FULLMODEL-ABI-30-STATIC（2026-10-23，已实际派发）

复用A011既定Astra/xhigh，待实际followup后仅追加source/m007_residual_encoder30_20261023.md及同前缀机读依据，不写生产/主控索引，不运行EDA/模型/新gold。以已定§12为主，只集中补A010实查的四组实施缺口：新canonical父v3的build ABI字符串/tag、kind5/6/7及setup/invalidate/BEGIN精确字段；新catalog/setup/preLN/finalLN/type/ReLU/gather/tail错误domain/stage/source/96bit tuple及global_layer/实际失败op的无歧义定位；canonical编译分支对旧coef_cfg398bit的可删除字段与保留v2路径/单bank边界；模型catalog8KiB BO用途、四port aperture参数来源和本段外部tail_commit与未来真实DMA owner的职责边界。

建议新canonicalv3仅kind5/6/7独立ABI，旧v2 kind0..4保留原构建/语义；不得把未实现删除398bit预签资源。实际无板卡/aperture/DMA，定义显式参数与外部生产协议并将SIM peer验证、全模型RTL、真实部署分层，不能编物理地址或把stream_accept当D2H完成。正常链先行，原gamma半装载abort/全异常排列仍按已知OPEN；不新增普通实现逐步审批。新控制/错误身份若超过原32768bit，精确报差额和可验证复用，禁止改分类隐藏。产物须有一条可直接由A010实施的固定接口，不给多套可选方案。

只读源码/现已冻manifest及整数位/CRC/ABI hash检查，单次≤20s/1GiB、累计120s、CPU0–3/nice19/idle；不加入重工具队列，不启动新代理。工程Encoder0与D27/D28独立范围继续，实际派发后才登记运行。

2026-10-23 D30已实际followup复用A011；A007 D27封存后释放槽，TYPE-29待本次ABI集中核定后接续。


## D-M007-SM012-FULLMODEL-PARENT-32（2026-10-23，E016/R007）

采用A011 source/m007_residual_encoder30_20261023.md §12/§14正式唯一合同，用户继续完整Encoder与原28+2层授权内连续实施。复用A010 gpt-6.1-sol/xhigh，唯一写forward_controller新single_parent_v3及其router/TB/runner、q8_linear_and_restore新canonical facade/bias模式、hbm_loader_and_cache真实transport_idle/mux接口和E016/R007证据；旧parent_v2/R006、旧facade构建及冻结来源不改或显式保持兼容。A007唯一写新type/VECTOR/joint_v3，A008 catalog/TANH模块只读复用；不是唯一作者，保留他人改动，依赖通过实际消息冻结SHA后接入。D29先用重工具，D32先做源码；其后按真实锁串行，不等待用户再批准普通编译/修复。

固定v3 ABI tag cedb4c130303f16da9fa1c605b2cf985，五完整SHA、kind5单Encoder/kind6单Decision/kind7一次BEGIN全图、setup/invalidate统一heldDONE、模型装载704chunk和两RoPE族、catalog120record真CRC/两槽runtime refill、原10 full/18 sliding＋2全Attention无RoPE、final gamma/type、Decision FC1/ReLU/quant A1/FC2及最终544向量和真实SIM peer tail_commit，全部按§12/14落生产。旧中间gold只能是checker，不能替代生产计算；模型setup系数仅复用E020已核原来源。新尾部peer保存实际公开输出/身份/字节并真实完成写入，不能把checker成功或out_ready当commit。kind5/6只作公开完整层入口，不能被用于宣称kind7一次BEGIN已通过。

canonical互斥编译分支只一份73,728B bias bank，不再实例旧16KiB窗口；398bit旧coef控制逐字段实际删除后才扣。补真实W transport_idle（包括held AR/R债/队列/load/lease）、catalog原地址到真idle稳定、error cleanup保留active_epoch_offset9、完整字段错误封套不截断；控制总账含所有胶合/异常与新type/bias响应，超过4KiB必须报告而非更名payload。K4096原容量不加新cache，FC1实际16384组与最终row127/group127写ACK/producer_close及所有退休前不得启动FC2。原未实现gamma弃流abort/多错首因全排列保持明确OPEN，不为等待合法背压伪报错误。

必要短验证先完成实际v3构建/唯一资源与census、合法setup全header/120record CRC及704模型word/两RoPE族资格与held DONE；非法build/kind/层/未committed命令、三入口优先级、model_word跳号/错身份拒绝与合法后继、catalog末record或RID/RRESP/RLAST排空、原地址保持和两槽实际refill、canonical bias首尾读/保持。继续最小真实数学前缀、preLN/finalLN/type与Decision16384组及K4096的合法组件/公开层入口验证；来源/层次/参数/输入不同则各自范围标清，不用mock数学叶子或TB直改内部state跳过生产资格。完整层/全图仅在同版真实分段成本支持后启动；未过门继续有意义短例和合法公开数据链诊断，不原样加时。

独立reference0/static1200/RTL3600/OOC0秒，预留RTL400s恢复/归档，不转旧余额。unknown/static/RTL pilot单次≤120s；当前实测支持的static≤300s、组件或层验证≤1200s。完整单层/全图仍≤3600s/8GiB/40Mcycle，启动前同版E≤3600且剩余≥E+400，不用旧top墙钟相加或缺段记0。若完整30层成本不成立，保存真实静态/组件/前缀与缺口，完整kind7保持NOT_RUN；不能删层/改shape/降数值/重造gold。CPU0–3/nice19/idle、MemAvailable>192GiB、单重工具锁至后代清空、120s真实语义停滞、static24GiB均保持。禁止安装新工具、OOC/P&R/GPU/板测。R006余额保留，未来只用于该原范围且与R007费用清晰分账。

D31只签局部等价及1.057倍单样本仿真收益，本段不以它宣布完整成本门通过；新v3 joint初版复用D29已实测的TANH身份，避免无必要改动。后续替换须owner实际接入并核受影响结果。每阶段更新原模块design/results及三摘要，集中报告真实正常图/错误/成本与尚未覆盖项，不为每次修复另建审批。

D32只读输入绑定支持（A008）：在D31封存后可实际followup复用A008，仅独占source/m007_fullmodel_input_binding_20261023.json及短同名md；读取原五份捕获输入、原B1请求/Host metadata、47检查点和已有E009 tail来源，按§14给本次B1_from_b0的qtype/mask/marker/count/身份准确字节及类型转换依据，供A010唯一父TB使用。不得改Host/Catalog/父源码，不跑模型/EDA/生成新浮点参考或全权重打包；只允许整数/字节索引并核原SHA。先定位已有tail checker/CLS来源，若需组合仅记录原decision_01_out逐字节gather索引，不能将DUT输出回写gold。新独立只读成本≤30s、单次≤20s/1GiB/CPU0–3/nice19/idle，不借旧D28/D31余额；交付实际来源与未满足处即结束，避免阻塞工程重工具。

D32资源owner接入补充（主控增量92之后）：A007在已冻结E019/R004交付后，仅负责当前新joint_v3中唯一TANH8由已验v2替换D31已验v3、最小依赖清单及source-only等价diff证明；旧D29所有frozen/原bundle/v2 body保持。额外只读整数/源核≤20s，计入R007 static原1200额度，禁止动用D29关闭余额。A007仅新增R007/d32_joint_tanh3_source_integration.json作为源接入依据并维护自身模块source说明；不改父/TB/主控索引，不自行EDA。A010仍唯一写R007全部其它实验/父入口，收到实际源码SHA/依赖后立即按原合同统一编译新父以及同closure必要joint正常type或G/LN最小checker；数字/周期/资格/资源不变，新增组合须实际验证，局部空闲比值不当全图成本。该接入服务整模同版仿真，不扩新架构/预算。


### D32 正常路径成本边界接续（主控增量97，2026-10-23）

AT027原B1同版QKV3实际89.59957399003906s、稳态最慢块22.83981130796019s；原式1.35×(P3+45×最慢块)+10=1518.4779618451342735s。未发生QKV48超时，原组件1200s门不能覆盖真实下一数学边界。现一次性允许同AT026生产/完整checker snapshot、MODE8/STOP_QKV_BLOCKS0/STOP_AFTER_HEAD1的正常父QKV48→首真实head前缀；不扩大总预算，不改原全图单次3600s规则。

该单次总guard≤1650s：QKV退休前≤1519s；从真实QKV_RETIRED（m_done实际消费）到首HEAD_END成功含RoPE/启动/整个head为独立未知段≤120s，另留≤10s进程收尾。未知段不能从HEAD_BEGIN才计时而遗漏RoPE。外部时间戳driver须在进程内真实事件出现时计时，语义停滞保护120s保持；达到任一帽即COST_STOP，不能仅加时重跑。候选E=1519+120+10=1649s，当前余额3082.722844529955194s≥1649+400，启动后仍保留400s。若工具启动/清理按已有guard计费略越界，保留实际费用与原因，不修改原收据。

只允许runner/segment guard必要改动，无需重编已有snapshot；全部原B1 mask、原独立QKV/RoPE/score/maximum/prob/context、事件/身份/周期/未提前父DONE断言保留。输入从真实H→quant/A→全部QKV；不使用保存激活替代生产者、不force状态、不缩shape。首head终点仍是未完成父请求，不能签完整16head/WO/Encoder或kind7。完整Encoder预算仍UNKNOWN，取得新成本/结果后由主控集中决定下一正常边界，普通合法修复在本批余额内连续。A010保持唯一实现owner；旧预算/通过身份不转。


D32同版仿真成本只读支持：复用A011在原架构文件末节核当前生产/生成TB的一个明确事件开销候选，优先无效lane传播、每拍全数组扫描或调试开关；不重做已验TANHv3，不修改实现，不运行EDA/参考模型/新工具。提出保持全部数值、周期、资源实例、checker的等价条件和≤120s可证伪A/B测法；无依据则明确未发现。只读脚本独立总额60s、单次20s/1GiB、CPU0–3/nice19/idle；不转旧实验余额。A011仅写既有source架构md/json，父/TB仍A010独占，源核交付不代签性能改善。


D32增量98接续：AT031按post-QKV120s成本帽停止，保留整体COST_STOP；源字节不变debug typical/off候选按source架构§16在原R007余额执行，B静态≤120s、原B1 QKV1 A/B各≤60s/合计120s，400s保留。O3、源/输入/TB/checker和原终点均不改，局部样本结果不外推整模。完整kind5 checker的源码适配按原四矩阵/独立参考/实际catalog与尾部退休连续完成。

A011另接原kind7供数整数审核：只读A010 kind7_weight_supply_feasibility.json、原120记录、GGUF/TN8 BO及既有8tensor W576，对首尾/跨superblock/固定有界样本逐字节核整数地址、四port/Wi双半/scale原位，明确AR接受锁存身份；不浮点评值、不pack全120、不做EDA或改生产。仍只写原source架构md/json，独立只读60s、单次20s/1GiB、CPU0–3/nice19/idle，旧预算不转。其产物供A010实现按需peer，不代签30层运行或RSS。


## D-M007-SM012-COMPILED-RTL-CROSSCHECK-33（2026-10-23，E021/R001）

用户直接答复“允许隔离添加并验证（推荐）”，授权将Verilator5.020隔离加入用户工具目录，并先与XSim做同源码数值/协议/周期和速度对照。该授权仅覆盖本段新工具，覆盖D32禁止安装新工具中的对应限制；不授权改数值、生产模型、层数/shape、系统软件或旧原始证据。root负责下载/哈希/隔离解压，固定Ubuntu发行包verilator_5.020-1_amd64.deb，候选SHA256 bb74ca8c32c73eb903ee91da64c8b58cfbe095c229967a95782108afb67bb3ca。路径/home/user/EDA-202/zhuowenjun/.local-tools/verilator-5.020，不执行系统安装/maintainer脚本、不改全局PATH。工具下载/版本/失败单独记录，不冒充设计验证。

新A012（期望gpt-6.1-sol/xhigh，实际未核则UNKNOWN）唯一写E002/experiment/tools/m007_verilator下本段构建/验证脚本和E021三摘要/原始证据。全部生产RTL、既有TB与gold只读复用，A010继续唯一父/完整Encoder/按需W peer owner；A007共享资源owner不变。不得修改/替换数学叶子，不以C/DPI模型替代RTL，不删除断言。需要生产或原TB的兼容修复时提出具体等价变换并交原owner执行，普通runner/路径修复由A012连续完成。

先确认实际工具版本/语言与依赖，再原XSim已验严格FP定向边界（含次正规、RNE、零与异常）、真实共享FP租约/holding/epoch/reset及至少一份当前同版父QKV正常前缀。必要时先较小真实模块再父闭包，保持原源/fixture身份、独立期望与周期/握手计数，比较双方完整既有语义轨迹。Verilator为两态求值，XSim四态/未初始化检查结果仍保留；两态运行不能替代X传播证据，不能把随机初始化称完整四态等价。记所有warning/未支持构造及实际覆盖；不同后端局部通过不直接签整个Encoder/30层。

运行`--timing`保留原clock/reset/有限delay调度，选项和C++编译选项冻结。未授权改原硬件时序或性能帽。全项目一重工具锁仍为.research-agent/m007_heavy.lock，A010当前按需peerXSim与A012翻译/C++编译/仿真串行；先实际协调队列，不并发。CPU0–3/nice19/idle、MemAvailable>192GiB，static≤24GiB、RTL≤8GiB/40Mcycles/单次≤3600s、真实语义停滞120s不变。新独立reference0/static1800/RTL1800/OOC0秒，RTL保留300s；旧R007预算不转。工具下载/解压另设120s有界引导费用，不计为硬件测试。未知翻译/单编译单元/RTL pilot≤120s；获得当前实际分段费用后，已测完整构建可≤300s且总额足够，不能原样延长已失败timeout。大型C++采用有界拆分并记录实际完成对象，不把杀进程后的文件当合法编译成功。

先完成兼容性与一组真正可比的前缀，给数值/周期/协议/成本边界。只有该后端同版实际成本支持时，才由主控接续完整层及原28+2正常链，不能拿旧XSim墙钟比值外推所有阶段。禁止OOC/P&R/GPU/板卡或其它工具安装；阶段普通修复连续，发生真实数值分歧立即保留并定位，不放宽gold。


D33同源码兼容接续（2026-10-23，增量102后）：AT007缺原capture helper与AT008/009工具语言限制保留FAIL。允许按工具文档使用unroll-count128；完整父TB四处二维slice的readmemh由A010唯一owner改为读同一8192元素一维临时数组并在零仿真延迟逐元素copy，原fixture/数值/周期/检查不变，保存独立1d successor与差异。原37e8 TB/AT036冻结不改，不同时混入新binary peer。A010在R007原余额先新XSim构建≤120s、原B1 QKV1≤60s（RTL保留400）生成必要新基线，A012随后使用该精确闭包/输入/参数对照。旧失败C++中间产物不作合法构建。父比较必须提取非空完整M007与终标事件，周期/计数/数值逐条相同；仅已登记的capture EXPORT绝对目录允许映射占位，raw和qualified两种一致性分别记，不隐藏其它差异。未发生的完整层/30层仍NOT_RUN。


D33首次父可执行构建实测预算接续（增量105）：AT011完整翻译已成功，三个实际所需对象pilot均PASS、共31/743生成对象及PCH/runtime完成；没有发生完整构建超时。compile_cost_plan_v2.json按9类大小/冷热实测每TU CPU最大值形成剩余820.264433 CPU秒，四CPU+21.858s失衡+runtime120+archive/link120，再1.35及60s命令核验得E691s。现仅对此尚未完成的首份父exe将原默认300s计划边界更新为剩余累计≤720s，不增加D33 static1800总额；分离实际未完成对象每guard/TU≤120s、末archive/link≤120s、真实停滞120s和24GiB/CPU0–3/单重工具保持。已成功对象按SHA复用、失败attempt中间物不混入。任何超时保留并定位，不原样加帽；真正完整link成功之前只记对象完成。此为依据新实测的首构建计划，不是硬件或父数值PASS。


D33增量108：首父exe实际完成260.2347390970099s；首次RTL揭示原残差checker的131072×32bit→4096×1024bit加载错误，由A010无损pack修复，gold/生产/覆盖不变。允许受影响闭包重新翻译后按已测构建×1.35+60上取420s完成新构建，分批/对象≤120s及原D33总额保持；复用任何对象必须验证全部传递头/PCH/flags，不能仅看cpp SHA。原首运行FAIL保留，不以修复提升原未触达残差/完整层结论。

D33当前父后继安排（增量108）：修复后同版QKV1原gold终标、无Fatal及AT043既发生86事件逐周期一致成立时，A012复用同exe自动启动一次完整kind5 checker未知路径pilot≤120s。仅取消诊断早停参数，原输入、完整shape及所有阶段检查保留；到帽只签实际发生前缀/COST_STOP，不能原样延长，不假设完整层成本。完整层终标若实际在帽内完成才验全层，并给分段周期/墙钟。D33余额/300s保留、单锁与两态局限保持。

D33增量109隔离工具普通修复：原版runtime在实际8×168连续#0初始化独立复现SIGSEGV。允许A012仅在自有runner目录保存verilated_timing.cpp的fixed-batch副本，将当前m_zeroDelayed换入局部批次后逐个恢复，保留原文件/头/生成设计身份；单独编译新runtime并链接新exe，明示5.020+local patch，不伪称stock通过。先原/修小例、非零clock同tick退休及XSim对照，再原FP/shared与父QKV；原D33预算/单锁/pilot120保持。原工具声明的一般#0 inactive调度缺口与两态范围继续保留，不能删生产#0或改硬件周期/gold。

D33 fixed-batch后续实测：AT017已消除SIGSEGV，但原168次连续#0超过默认100同tick active迭代而明确nonconverge。允许仅将--converge-limit设512，保留每批之间原组合求值；不采用runtime while一次排尽。先同源8×168＋XSim非零clock/reset对照、既有FP/shared，然后父重译与受影响对象重编。所有可复用对象必须cpp/传递header/PCH/实际编译flags完整一致；原总额不增，原FAIL保留。本参数为模拟器内部固定点保护，不是生产硬件拍数/时钟变化。

D33增量111并行仿真配置A/B：源文档确认5.020可timing+threads4。A=model1/context1，仅main显式threads1；B=model4/context4 fresh翻译/派生模型；同93生产/172d TB/gold/fixedbatch+512/CPU0–3。两者原STOP_AFTER_HEAD1、单次≤120s，完整语义/数值/周期对照并实测CPU和墙钟，原AT026未测CPU保持UNKNOWN。B未知翻译≤120s；生成规模≤原744cpp/276MB的1.15倍且无新增极端TU时，按原完整构建318.624s×1.15×1.1+10约413s给首build≤420s，批/TU≤120s及原D33总额/RTL300保留保持。超规模先核真实差额，失败不原样延帽；没有实际收益不把四线程当作加速结论。


### D33 单线程完整 Encoder 分段探索（2026-10-23，增量112后）

AT031/032四线程在相同原数据上进入softmax数值错误，保持FAIL并停用该配置推进；未证根因不改生产算术/TB/gold。回到AT028/029已验model1/context1、fixed-batch-v1/converge512的同172d TB与93生产依赖；不带入四线程诊断main，不重新构建生产模型。原AT027默认context的120s全局pilot保持COST_STOP，不改旧收据。

A012在原E021/R001预算内，直接实现同一进程的事件分段保护并运行一次kind5/packed0/allSTOP0正常Encoder探索。全局guard上限800s，所有连续阶段各≤120s，真实语义停滞120s/8GiB/40Mcycles/单重工具/CPU0–3/nice19/idle/MemAvailable>192GiB保持，开始前RTL余额必须≥1100s以保留300s。这是已测QKV与head服务后续的有界路径探索，不声称已知完整层成本或保证800s完成，不把120s旧失败原样延帽。

连续阶段从child启动→MATRIX_END phase0；phase0结束→HEAD_END0（含RoPE/交接）；各HEAD_END前一head→下一head；HEAD_END15→ATTENTION_END；ATTENTION_END→MATRIX_END phase1（含layer idle、context4096、quant/A发布、WO全部与交接）；phase1结束→VECTOR_END phase0；VECTOR_END0→LN_END；LN_END→MATRIX_BEGIN phase3（包含Wi/G/quant重叠和全部成功屏障，不漏中间等待）；MATRIX_BEGIN3→MATRIX_END3；MATRIX_END3→VECTOR_END1；VECTOR_END1→原COMPLETE_PASS/正常进程退出。按A010 encoder_stage_route_source_review.json映射精确日志；各BEGIN仅作细分观察，不重置已定义连续段或遗漏成本。事件缺失/乱序须明确失败，不能任意进展日志重置阶段计时器；尾部capture写完及进程清理计入总费用。

driver先以原A029/AT027事件流验证状态推进/乱序拒绝，再对实际stdout monotonic逐事件记cycle/wall。普通runner修复不需新审批；static≤20s、无fresh模型编译。任意段/总帽触发即保留COST_STOP及实际前缀，无公开跳转/恢复入口，不预装中间结果。原全部数值、最大值、握手、身份、周期、最终输出、held DONE/返回idle断言保留；完整终标与实际独立gold全部成立才签完整Encoder。该次通过也不能代签原kind7一次BEGIN 30层。预算不足或新数值失败即报告确切边界，普通修复继续现授权范围。


## D-M007-SM012-FULLGRAPH-COMPILED-34（2026-10-23，E021/R002）

用户持续完成原30层授权内，主控增量115接纳AT034同runtime完整Encoder0正常路径。D33/E021 R001限定阶段封存（原失败/余额/政策UNKNOWN保留）；本段复用A012工具runner与E021证据owner、A010生产父/TB/W owner，不新建代理、不转旧余额。正式目标为kind7一次BEGIN的原28 Encoder＋2 Decision、finalLN/type/544向量真实尾部提交及原独立checkpoint；kind6公开Decision只作必要局部定位/成本，不替代完整kind7。

固定后继top m007_fullgraph_binary_tb，TB8b556ca2b32f2a41f7ca1d259d5f7c714a8dd473d131e8949f6dcabd1a3ea570，prepared/fullgraph_retire_progress_v3/source_manifest.json及A010 fullgraph_progress_source_handoff.json为闭包/fixture入口。沿AT034同生产单资源、真实120矩阵按需W peer、原embedding_norm唯一初始H、原47checkpoint与尾部gold；后续激活必须真实RTL计算，不能预装中间值、缩层/shape、放宽位比较、变更数值或用CPU/DPI替代算术。原kind7 checker仅新增真实退休日志，inverse删除观察增量须逐字恢复677e5bc9。

正式后端固定已验Verilator5.020+local fixed-batch-v1+converge512、model1/context1，g++ fastO2/slowO1/runtimeOs原语义flags；四线程FAIL保持停用。两态与一般零延迟调度局限保留，不代签四态或物理实现。没有系统安装、新软件、GPU/OOC/P&R/上板授权。

新独立reference0/static1200/RTL7200/OOC0秒，RTL保留600s；CPU0–3/nice19/idle、MemAvailable>192GiB、static24GiB、RTL8GiB/40Mcycle、单次总RTL≤3600s、真实语义停滞120s、全项目一重工具锁保持。所有失败/编译/准备/清理成本保留，不把旧账清零后冒充同批。未知翻译/单对象/单批/RTL pilot≤120s；新全图生成规模≤已验744TU/276302770B的1.15倍且无新极端TU时，首完整构建可按已测318.624s×1.35+60给≤500s总计划，各批仍≤120s；超规模先实测有界对象并报告，不能盲目延时。新top不默认旧对象可复用；传递headers/PCH/flags/source身份全相同才允许复用。

使用两条分开的进展流：原M007_PARENT_CHECKED继续表示实际独立gold检查；新增精确M007_RTL_RETIRE_PROGRESS retired=N cycle=C只表示真实数学结果commit/写ACK，累计严格递增、跨层不清零，无真实退休不得刷新stall。两者不能混计成gold数或运算量，禁止clock/状态/裸AR/file读取心跳代替。driver先用有效/无增量/倒退/伪心跳/不前进cycle日志验证其分支，保留原完整数值与协议checker。模型装载与初始H之后若算术在途，应以实际retirement流观察，而非因无新gold端点误报停滞。

先完成确切闭包翻译/构建及一次kind7/all原完整参数的未知≤120s pilot，记录实际setup、BEGIN、层身份/所有发生的check与退休/周期、原checkpoint或真实首错误、CPU/wall/文件I/O成本；不把kind5墙钟直接乘30作为本版成本，不把短pilot当全模型PASS。若120s内完整原30层及尾部确实完成则按原终标审核，否则保留明确实际边界/COST_STOP，并给主控基于新同版测量的下一公开完整层/Decision/完整图成本计划，不自动延长同一失败目标。启动正式完整kind7需保守实测费用E≤3600s且当时RTL余额≥E+600；任何尚未测的关键环节保持UNKNOWN。成本门关闭时推进保持语义的有界仿真优化或报告具体不足，禁止以分层CPU注入冒充一次BEGIN。

普通runner/路径/TB采样/生产合同内实现修复由各owner连续完成并重验受影响项，不新增逐次审批。新架构/数值/资源目标不在本段更改。只读分析、构建准备可连续，真实重工具串行。完整正常链、全异常恢复、两态/四态、联合物理与真实部署分别报告；本段通过不自动把M007整体验收标完成。


### D34 首原始层端点成本样本（2026-10-23，增量116）

AT004原kind7未知pilot在119.134035s成本停止；实际global0 QKV与8head持续推进、无SV错误，原完整层/30层均未完成。kind7同阶段比kind5墙钟1.033–1.043，尚无全图E，不启动正式全30层长跑。

复用AT004同exe/model1/context1/全部源与输入，A012在R002原预算执行一次首原始层端点诊断：仍kind7一次BEGIN、原28+2层/120矩阵/全部checker/无STOP参数及中间注入，外部driver只在原LAYER_END global0成功和实际131072字H输出完整后计划停止。此为完整图请求的首层前缀，不是kind7成功DONE。总诊断帽600s，开始前RTL余额至少1200s以留600s；不是全图费用估计或延长原未知120s收据。

沿同版生产实际接受/成功回执定义连续段：启动→QKV成功；QKV→head0；各head→下一head；head15→Attention成功；Attention→WO成功；WO→residualA成功；residualA→LN成功；LN→Down实际启动（包含全Wi/G/quant/交接）；Down启动→Down成功；Down→residualB成功；residualB→原global0层端点及实际H输出。每连续段≤120s，语义停滞120s、8GiB/40Mcycle/单锁和CPU0–3/nice19/idle保持。driver先以已有事件回放和源码谓词核对合法推进/乱序/缺事件拒绝，BEGIN细分/retirement流不得重置阶段帽。未观察段如实UNKNOWN，不把任意状态变化当成功。

允许A012只改runner/main观察与停止保护（static准备≤30s），不改TB/生产/数值。首层实际输出由真实接口捕获并逐字核原Encoder0独立checkpoint；若原capture需完整全图才flush，允许仅在main已有capture中补实际首层flush，不重建/填充数据。任何错误保持原FAIL并由对应owner按原合同修复。样本后据同版完整层、后续不同层结构及Decision缺口制定加速/进一步有界方案，仍不以首层乘30假称已测完整图。


### D34 受影响独立Decision正常路径（2026-10-23，增量117后）

AT005已在原kind7验证第一完整层实际H；AT007/008清590空调用的前缀数值/周期一致但没有速度收益，保持未改baseline。A010已修复原独立kind6测试入口误带kind7尾部metadata的问题：新86629840后继只将非kind7的qtype/markers/mask/count置0，kind7赋值序列原样；旧8b55/当前所有运行冻结不改。采用prepared/fullgraph_kind6_public_abi_v4同94源、真实120 W目录及原type_add输入/decision_00_out期望，不产生新gold。A012未知翻译≤120s，实际传递头/PCH/flags/生成源码相同对象方可复用，所有费用扣R002原static/RTL总额。

在新闭包合法完整展开/链接后，直接以kind6/local0做一次完整独立Decision的有界阶段探索，总诊断帽600s、开始时RTL余额≥1200s保留600s。已有Encoder共同路径和同版两种首head数值/周期证据作为前段依据；新增preLN、bias、FC1/ReLU/quant/K4096 FC2仍为本次实际待测，不声称已有全层费用或原30层通过。连续段依真实成功/接受事件划分：初始setup/H→preLN成功；preLN→QKV成功；QKV→head0及相邻head；head15→Attention成功；Attention→WO成功；WO→residualA成功；residualA→postLN成功；postLN→FC2真实启动（全FC1/ReLU/quant16384写/ACK、producer_close和资源交接包含在内）；FC2→FC2成功；FC2成功→residualB成功；residualB→4096组原H导出、成功DONE消费及真实idle。每段≤120s，BEGIN/计数/进展不得重置连续段帽；缺失/乱序/错误明确FAIL或COST_STOP。固定8GiB/40Mcycle、真实stall120s、单锁和CPU/优先级限制保持。

所有原checker与完整131072输出逐位保持，实际输出由接口捕获并核原decision_00_out字节；独立输入允许来自该公开接口原参考，仅证明局部完整Decision及成本，不进入kind7替代真实前驱。先复用当前正常单线程未改数学对象/标准编译flags；PC诊断所得候选需独立前缀等价/真实收益才采用。普通runner/TB协议修复连续推进，无逐次审批，无新总预算。


D34 增量118同路径接续：AT010原Decision0完整PASS331.587451345s。允许A012复用同exe进行kind6/local1/global29完整正常例，原decision_00_out公开输入、decision_01_out期望及全部checker不变；计划E=1.35×331.587451345+10=457.64305931575s，单次500s/每连续段120s，启动前RTL余额≥E+600，原D34总额不增。只改必要driver参数/预检（≤20s）、不重编数学模型，全部身份/4096输出/正常DONE与idle保持。此覆盖两种独立Decision的数据/权重路径，仍不替代原kind7一次BEGIN。


## D-M007-SM012-ORIGINAL30-BOUNDED-35（2026-10-23，E021/R003）

**任务和授权来源。** 用户明确要求继续完成原30层模型验证，且要求主控在子智能体交付后主动核对推进。增量119已直接核AT005原kind7首层实际H、AT010/011两种完整公开Decision的实际H与public输出逐字等于原独立参考；D34同版本试验的CPU/墙钟及语义分段现已足以制定首个完整整图运行计划。D34/R002限定组件/成本阶段封存，原失败、UNKNOWN及未用余额保留不转入。本段复用A012的工具/E021 owner、A010父/TB owner，不新建代理、不恢复旧M004/M006。普通实现/测试脚本修复仍连续执行。

**本阶段成本例外。** 当前每Encoder核心约329s、额外preLN约11.5s，两Decision完整实测约332/339s；原full/sliding均算128×128，不能按mask面积打折。相同工作量分项代理10196.799374s（约2.83h），加入35%规划裕量、三个未测交接各120s及60s清理得14186s；这是条件规划额度，尚未测的后续层/交接保持UNKNOWN，不称严格费用上界。590空调用A/B无收益、PC热点分散，不继续用小优化假定倍速。原D34的3600s单次门不能承载该明确授权的完整请求。主控据新实测将**本段唯一一次完整kind7运行**的单次墙钟上限定为15000s；本项目AGENTS中的通用3600s在这一次有明确任务/预算/阶段保护的整图尝试上由本段替代，其它任务不变。不是改写原120s COST_STOP或首层计划终止收据，原尝试原样保留；不无界加时、不自动重复完整长跑。

**独立预算。** reference0/static300/RTL15600/OOC0秒，RTL保留600s，单次完整RTL≤15000s。启动前必须具备≥15000+600s余额（预算内准备/脚本验证计static；不先消耗新RTL配额做无关试验）。CPU仍0–3且model1/context1实际单线程、nice19/idle I/O、MemAvailable>192GiB；static24GiB/未知单对象或批次≤120s，RTL8GiB/40Mcycle/真实语义停滞120s，全项目一个重工具锁不变。完整运行无新安装、GPU、HLS/OOC/P&R/板卡、CPU新gold或新模型。原R002全部收据与已知/未知成本独立封账。

**精确执行身份。** 复用AT010/011生产与86629840完整TB、f4d真实120张量W peer、原FP/IP/gold；Verilator5.020+local fixed-batch-v1+converge512，未采用590 no-op或SIGPROF后继，模型单线程，原fastO2/slowO1/runtimeOs。数学对象/四生成头/PCH/编译flags及完整输入身份按实际manifest核验；同版可复用，只为必要只读全层capture/main或外部driver重编。kind7一次公开BEGIN，初始H仅原embedding_norm4096组；后继所有层H由实际RTL产生，不能切层注入、预装中间gold、跳层、缩shape、改变算术/舍入/断言或用CPU/DPI代算。两种独立Decision仅作原身份组件依据，不拼接冒称整图。

**分段保护与范围。** 一次进程连续执行原28Encoder+2Decision，保留全部原checker。每层从真实入层到原层端点连续≤600s；每个连续计算/交接段≤120s，按已经验证的preLN（首层省略）、QKV、16个依序head、Attention成功、WO、residualA、postLN、完整Wi/G/quant→Down或完整FC1/ReLU/quant→FC2、Down/FC2成功、residualB及真实层端点建立严格状态机。各BEGIN、中途计数/retirement不得重置连续段帽；global变更/阶段事件须核层号/单调计数/前序真实完成。Encoder27→final gamma LN→type→Decision0前置LN的新增交接单独≤120s；最后Decision1→544个真实尾写/flush/延迟commit/成功DONE消费与正常idle亦≤120s。初始setup/H费用包含第一层；清理/产物写入计总墙钟。无新gold时严格递增真实retirement只续stall计时，不能续阶段/全局计时。任意数值/协议/身份/缺事件/乱序失败立即停止；资源、总额、逐层/逐段帽触发明确COST_STOP，不自动加时重试。

**真实验收。** 原30层H端点、final LN/type、初始输入/gather合计34个FPGA/输入端点依原独立字节参考检查；另13个CPU checkpoint仍仅身份绑定。必须实际一次BEGIN、120矩阵/目录、480head、60LN、60残差+1type、28GEGLU、两次FC1各16384真写/ACK/发布后才FC2、30个层端点，以及544×128=69632B真实尾写、flush、1次合法commit及全部资源退休/heldDONE/正常idle，完整原终标且无Fatal/Error才PASS。计数定义以原生产/TB实际事件为准，不能把retirement日志当gold值数。保持actualH0、每层真实H捕获、原public尾输出和元数据/唯一坐标/字节数/实际SHA，主控独立逐字核原参考；capture只读真实接受/提交接口，不重建gold。只读capture普通修复不改checker或DUT。

运行中按实际阶段/层端点报告进展并保存日志；初始新driver先以原AT005/010/011事件做回放/缺事件拒绝测试，少量synthetic次序案例与真实运行证据分开。完整正常链通过也不代签所有异常恢复、四态X传播、联合面积/布线时序、Host/DMA/板卡性能；M007整体验收状态据真实范围另判。


## 用户指定本轮停点（2026-10-24）

用户明确要求“完成验证后 暂时暂停项目”。继续当前 D35/E021 R003 AT001 唯一原30层运行，完成实际结果核对、额外交接监督合并、原始证据/摘要归档与owned进程清理后，M007及主控/执行者登记paused，等待用户明确恢复。不得自动接续新实现、实验、优化或物理/部署阶段；当前失败或成本停止须保留报告，不自动重跑。当前运行尚未完成，本指令不是立即中止。


2026-10-24暂停落实：D35实际28Encoder前缀PASS、final gamma LN原断言FAIL，完整30层未通过。按用户验后暂停要求收尾，不自动修复或重跑；最新事实见mission/current.md及results/missions/M007_summary.md。

## D-M007-SM012-FINAL-LN-SUFFIX-36（2026-10-24，E021/R004）

用户在获知可从保存H分段复测后明确“支持修复喝接着验证”，授权本段修复和验证；完成后仍暂停。不重跑前28Encoder、不自动恢复旧mission/物理/部署。D35原FAIL、frozen、日志和封存余额不改、不转入。

复用A010、A012（既定gpt-6.1-sol/xhigh）：A010唯一写forward_controller父v3、相关TB及模块source增量；A012唯一写tools/m007_verilator、E021/R004和三摘要。其他RTL owner保持暂停；双方共享工作区，不撤销他人改动，不创建新agent。主控唯一维护合同/总结果/验收。

最小生产修复是保证final LN的gamma选择在实际下层命令握手和执行期稳定；普通LN、数值叶、模型、gold、shape和正式kind5/6/7 ABI不变。先短例明确复现旧gamma命令/数据问题，诊断复合断言各项；同刺激验证修复，并补普通无gamma路径和有限命令延迟的保持检查。失败断言语义不削弱，独立参考不改。

分段输入固定为D35 AT001 `work/actual_fullgraph.layer27.f32.bin`，524288B/131072F32；使用前核采集身份和与原参考全字节一致，禁止用checker数据冒充实际输入。没有完整仿真状态快照，因此必须显式标记SEGMENTED_SUFFIX。采用默认关闭、仅验证使用的入口建立真实model setup、完整H装载与资源静止资格，再进入同一生产final LN→type→Decision0→Decision1→544输出/tail路径；具体最小入口在本节集中补充后实施。禁止TB强制done/债零/原28层完成计数、跳过实际后缀计算，或复制一套后缀FSM。原生产默认配置及旧完整检查保持；新增后缀checker只声称本段实际覆盖。

验收包括final LN全部131072值、type全部值、两Decision实际H和最终544向量对原独立gold逐字，真实tail写入/延后commit/heldDONE消费及真idle；记录后缀独立周期和墙钟，不与旧前缀拼成修复版完整一次BEGIN或端到端实测。前28层PASS保持原版本身份，受影响公共逻辑用必要短回归覆盖。

独立预算reference0/static1800/RTL3600/OOC0秒，RTL预留300s收尾。未知片段pilot≤120s；已有同环境真实两Decision331.6/339.3s仅作成本依据，final LN/type/tail及新构建开销另测，不记0。完整后缀单次≤1800s且启动前保守计划≤余额减300；每Decision≤600s、连续阶段/语义stall≤120s、40Mcycles。static默认未知≤120s，有同构建实测依据可≤600s，费用含失败/旧版复现/准备，不能原样延帽重跑。CPU0–3、单模型线程、nice19、idle I/O、MemAvailable>192GiB、static24GiB/RTL8GiB和全项目单重工具锁保持。无新工具安装/OOC/P&R/GPU/上板。普通修复和受影响测试按本段连续执行，集中交付后主控核原证据、清理owned、封账暂停。

D36固定测试入口：采用A010提出的`VERIFY_POST_ENCODER27_H`默认0参数。仅后缀验证配置为1；仍使用真实setup、kind7 BEGIN/TAIL_ARM和4096组公开H写入。在原`E_H_READY`的`h_load_success_valid && resident_retired`成立后，测试配置将layer_index置27、active_epoch_offset置448并进入同一`N_OWNER`；其它状态、FP/LN/source资格、lease/read/write及错误/退休均照生产路径真实发生。禁止在TB写入DUT内部态或模拟器完整状态。参数0逐分支保持原正式入口语义；这是模拟分段边界初始化，不能证明旧第27层实际退休到该入口的连续交接。

gamma修复固定为父端选择覆盖N_START及N_RUN，使provider延后的命令和保持期看到同一值；不改变provider/数学叶。旧版与修复版使用相同后缀测试入口、actual H、原gold和检查，仅此gamma逻辑不同。后缀checker应真实统计2层/8矩阵/32head/5LN/5VECTOR以及544输出/tail，保留原kind7默认checker，不填充原28层覆盖位。先旧版短例记录实际命令gamma与首次原数据/身份断言；修复版先验证finalLN/type及Decision0 preLN，再在已有同版片段成本支持下运行一次完整后缀。新失败据实际证据普通修复，既有失败不回写。

D36实际收尾（2026-10-24，主控增量127）：AT003旧版gamma0数值FAIL复现；AT005修复前缀PASS；AT006同一后缀710.202771s/900800cycle完整PASS。finalLN/type/两Decision各131072值及544组实际尾输出逐字同原参考，真实8矩阵/32head/5LN/5VECTOR/tail_commit/heldDONE/idle。未重跑原28层或修复版完整30层。46笔预算复算static710.513908/RTL754.460550，余额封存；4525个已知owned身份无存活/僵尸，2瞬态policy UNKNOWN。阶段完成后暂停，详见results/reviews/m007_final_ln_suffix_review_20261024.json。


## D-M007-SM012-FIXED-ORIGINAL30-37（2026-10-24，E021/R005）

用户明确要求“修复版完整30层一次运行，创建子代理进行，每隔一小时汇报一次就行”。仅恢复本段完整正常路径验证，完成核验/归档/清理后继续暂停；不恢复旧M004/M006、物理或部署。按用户要求新建专用工程子代理gpt-6.1-sol/xhigh，A013（实际spawn后登记）；A012保持暂停，tools/m007_verilator与E021本段运行/三摘要写权串行移交A013；A010生产RTL/TB保持只读，确有普通源修复需求时由主控协调原owner，不并行改写。主控负责总合同/证据审核，子代理不得另起agent。

身份固定D36修复父9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6与rev2共同TB2bd73c51255634e190b0b1c288ccd7150852f555c229218a755d7989fa734f2a及未变94源闭包；以实际新manifest确认，不能修改冻结包。正式full请求kind7/local0，`VERIFY_POST_ENCODER27_H=0`必须显式核实际展开与配置，不带POST_ENCODER27_H、STOP、层跳转、预填中间结果或TB改DUT状态。输入只能是原embedding_norm/initial_H，全模型原28Encoder+2Decision、finalLN/type、所有后继H实际RTL计算；原gold/shape/严格数值/正式ABI不变。恢复原完整checker，全部30层H、finalLN/type、544组输出/真实tail_commit、heldDONE消费及idle无Fatal/Error正常rc0，才签修复版一次BEGIN正常全图PASS。完整计数120矩阵/480head/60LN/61VECTOR/28GEGLU；两FC1各16384组真实写/ACK/发布后才FC2。保存每层实际H与唯一trace、公开初始输入/输出/身份，并核完整30层原参考；不能把D35前缀+D36后缀拼为本次结果。

工具沿同已验Verilator5.020+fixed-batch-v1/converge512、model1/context1单线程、原编译flags。翻译/构建新参数0闭包，只有生成头/PCH/flags/传递源及成功对象身份真实相同才复用；旧suffix参数1二进制不能当full。读写观察只捕获真实接口，不增加eval或驱动。生产源码不变，不需新gold/工具安装/OOC/P&R/板测。

本段独立reference0/static1800/RTL15600/OOC0秒，RTL留600；唯一一次完整请求上限15000s，启动前余额≥15600，不转旧余额。D35实际28层前缀9085.828054s与D36修复后缀710.202771s提供保守分项代理，规划1.35×(9085.828054+710.202771)+180=13404.641614s<15000；含重复setup仍不扣除，属于成本计划而非新整图实测。static未知单次≤120s，已测同规模fresh构建约271.7s可计划≤600且分批≤120；规模超过原741TU/268284937B的1.15倍则先有界静态核明。正式同请求每层≤600s、连续阶段/真实语义stall≤120s、40Mcycles，Encoder27→finalLN→type→Decision0 preLN整交接≤120s、最后Decision1→实际tail/DONE/idle≤120s。BEGIN/裸状态/文件读/非退休心跳不能重置连续帽。

CPU0–3、nice19、idle I/O、MemAvailable>192GiB、static24GiB/RTL8GiB、全项目单重工具锁、仅管理owned进程保持。原D35 FAIL/D36 PASS及原成本不回写。数值/协议失败或资源保护保留实际边界；不自动延帽或重复整轮长跑，先核具体原因。普通构建/脚本修复连续，不向用户逐次确认。完成后核所有执行/输入身份、逐层实际值、原日志、成本及owned清理，封账并暂停。

报告频率按用户最新指令：常规用户进度每小时一次，给实际完成层数/当前阶段/是否出现错误；首次真实启动、最终结果和需要处理的阻塞及时报告。工程内部里程碑写文件并发主控，主控不逐层刷屏。此频率只适用于本段；不默认创建无期限定时任务或宣称没有真实能力的后台提醒。


D37实际收尾（2026-10-25北京时间，主控增量128）：E021/R005 AT002正式参数0、原initial_H、一次BEGIN完整28+2正常路径PASS，10101.230974940s/13036119cycle。120矩阵/480head/60LN/61VECTOR/28G、两FC1各16384真写ACK发布、全30H/finalLN/type及544输出逐字同原参考，实际tail_commit/heldDONE/idle成立。主控独立重核3200身份、所有实际trace、22份费用及2262已知PID/start；无live/zombie/政策失配，2瞬态policy UNKNOWN、2次失败准备费用UNKNOWN并保守预留240s。static372.653188777/1800、RTL10101.230974940/15600封账不转，完成后暂停。保留D35原FAIL/D36后缀PASS，不外推故障全覆盖、四态、联合物理或上板性能；详见results/reviews/m007_fixed30_final_review_20261024.json。


## D-M007-SM012-FULL-TOP-PHYSICAL-38（2026-10-25，E022/R001）

用户最新明确要求“对当前修复版完整顶层做综合，取得资源分项报告，再检查布局布线和时序”。仅恢复本物理阶段；D37正常功能PASS、原失败及封存预算保持，旧队列不恢复。A010既有gpt-6.1-sol/xhigh工程代理实际followup继续，唯一写forward_controller物理入口/Tcl/XDC/runner及E022三摘要/原运行；主控维护合同、索引和集中审核。其它源码owner暂停，共享文件不并行编辑。阶段普通脚本/依赖修复连续执行，无逐次审批。

目标为当前生产`laya_m007_single_parent_v3`（SHA256 `9d87721737ceea74e47f565321ed83a625abae89931287d8a002d4f8e1534db6`）的完整裸计算核，正式`VERIFY_POST_ENCODER27_H=0`。除验证开关外，完整绑定D37实际实例的平台generic：`ADDRESS_PROFILE=1`、`HBM_PORT_BASE=0`、四个`HBM_PORT_SPAN=64'h100000000`、`PLATFORM_MANIFEST_SHA256=256'hf0df35cc7013643161e135ae0949473a9b5c0f13d5a4e3aea3675c2cf607db18`；其余MODEL/GRAPH/NUMERIC/LAYOUT/BUILD/TABLE_KEY使用D37同源默认身份。这是原仿真已配置的有效裸核地址profile，不是实际板卡平台认证；默认零profile会拒绝setup，不可用其优化后网表签完整功能。D37 R005 AT001 config的有序源和D36 rev2 fixed_source_manifest绑定已验闭包，实际综合排除TB/AXI peer、保留所有真实计算/动态输入/存储；不得用常量输入、假IP或中间参考值删去硬件。保留模型/全30层shape/数值/ABI，不为物理结果改变默认功能。源/ROM/IP/参数/工具/约束全身份冻结；不能仅编译某个叶子然后声称完整top。

目标器件`xcu55c-fsvh2892-2L-e`，单时钟周期`3.333333333ns`。采用out-of-context避免把内部宽接口错误占用封装引脚；不含真实PCIe/HBM shell、外部CDC及板级约束。不得虚构IO预算、将所有端点false_path或压低频率冒称300MHz。明确记录实际clock uncertainty、自动/显式时钟缓冲、IO delay与reset约束；未知平台边界单独列为未约束接口，内部reg-to-reg必须完整计时，不能把内部未约束端点当平台缺口。允许最小标准OOC时钟缓冲/约束适配，不能改变算术或增加数据通路延迟。

执行顺序为工具/许可/part/依赖预检，完整综合，层次资源和黑盒/latch/存储推断/约束报告，保存可恢复DCP；从同一DCP继续opt/place/phys_opt/route并按阶段保存checkpoint与原日志。取得DSP、LUT逻辑/存储、FF、BRAM18/36及等价、URAM，按矩阵/FP/EXP-TANH/各银行/控制层次拆分；核有无功能因未连接而消失。报告route状态、setup WNS/TNS、hold WHS/THS、违例数、关键路径及拥塞/DRC，所有内部路径合规才签内部时序PASS。用户核预算DSP7200/LUT900000/FF1800000/BRAM36eq1200/URAM640保持；超预算不隐藏，超器件实际容量等不可布局条件应保存工具报告及必要定位，不绕过合法性检查冒充route成功。无DCP时P&R为NOT_RUN并写真实原因。裸核通过也不代签带shell装载或上板/实测性能。

本段首次完整top专用独立费用：预检/脚本600s；综合总9000s、单次最多7200s；implementation总18000s、单个place/route阶段最多7200s，opt/phys_opt各最多3600s；只读报告/归档1200s。24GiB owned进程树RSS、MemAvailable>192GiB、CPU0–3/max4threads、nice19/idle I/O、全项目`.research-agent/m007_heavy.lock`独占不变。以上完整物理阶段成本替代旧120s叶子pilot/static1800/module3600单次帽，不转旧余额。Vivado重计算时日志静默不等于停滞：结合owned CPU时间、工具阶段及checkpoint进展；连续300s三者均无进展即停止。内存/墙钟/真正停滞触发保留COST_STOP，不原样延帽重跑，不管理其它项目进程。每阶段原收据/峰值RSS/进程身份/CPU政策和总账必须留存，未观测值UNKNOWN。

源未变不重跑完整30层。普通可综合性修复先区分脚本和生产语义，生产变化保存diff及影响，必须完成对应等价/受影响回归才能把D37数值证据绑定到新物理版；禁止只靠综合通过断言功能保持。完成或实质阻塞时集中核验实际报告、确认owned清理，写清已完成/未完成及下一具体条件，本段归档后暂停，不自动启动架构重设计/部署或扩大预算。


D38实际综合后流程细化（AT003之后，2026-10-25）：正确全部generic/单worker仍在709.993409556s、峰25,479,056KiB触发24GiB保护，未获DCP。隐藏worker日志实际指出matrix_engine的op0/op1为各524288 registers的unsupported 3D RAM；完整父IR约13.54GiB与matrix worker约9.81GiB同时驻留。按A014（实际gpt-6-astra/xhigh启动接受、独立runtime身份UNKNOWN）只读结果审核采用标准串行分层综合，以降低不相干层次同时驻留：先原matrix_engine_v1 PROFILE_ENABLE=0及dot/format子树，再含真实core DCP的matrix_facade_v2、resident_joint_v3，最后完整parent实际链接。全部91源码/ROM/11generic不改、同24GiB及原综合9000s余额；这不是加帽或以单叶子代替全top。机械header黑盒只用于中间占位，必须保存parameter/port/width/实例路径映射与原模块一致证据，最终read_checkpoint-cell/link后所有占位都必须被真实同版DCP替换、零黑盒；不累加模块估算冒称联合资源。分区可采用flatten_hierarchy none；最终清子OOC重复局部时钟、重建原完整top clk约束，核全部内部时序覆盖并保存联合DCP后才进入P&R。多读多写operand池改成BRAM涉及实际端口/周期，非本轮无源变更流程；若单矩阵仍超限则按真实阻塞交付，不私改存储结构再绑定D37功能PASS。


D38同语义可综合性修复接续（AT005之后）：原matrix_engine独立OOC也在868.242573546s/25,380,228KiB触帽，且主Vivado自身约23.69GiB、无大型映射worker并存；原结果COST_STOP，不证明器件超容，不再同源换壳盲跑。A014明确可实行最小表示修复；依据本段已授权的普通可综合性修复条款，A010可仅修改E002生产matrix_engine_v1的op0/op1表示/静态写入展开。保留64槽×256lane×32bit、原全部异步读、同拍全部不同槽写并发；同槽op0优先级add_rsp>mul_rsp>format，op1优先级PS_rsp>首组置零>format；保留外层状态/取消/握手guard、原reset不清数据、无写时保持和已定义地址域行为。不得换同步BRAM、加延迟、降并发/深度、改数值/控制/正式接口；仅改巨大多维动态左值为静态槽/lane或1D unpacked等价表达。原91源码包/AT005/D37不覆盖，新源新manifest和diff绑定。

必须先完成局部逐周期原/新对照，使用实际冻结原源码与实际新源码的相应存储块或可机械证明对应的抽取，覆盖64槽/256lane/全部数据位、各写事件组合、同/异地址碰撞和优先级、reset/无写保持与原异步读取。抽取与原生产的guard/assignment对应须可复核，不能测试一份无关手写RAM后声明整core等价；对未知/无效域不外推。原完整30层正常功能仍按D37原SHA保留，局部等价作为新表示版本的受影响桥接，不将未做的新全30标成重跑PASS。相应模块正常/取消或其他控制相关回归仅在diff实际影响时补；任何需改仲裁/周期的发现停止本表示修复，交集中架构判断。通过后同版新core OOC→自然分区→完整链接与实现继续原步骤。

该接续不增加D38总额28800s：从尚未启动的implementation18000s中明确划出修复static600s和局部RTL600s，implementation改为16800s；preparation600/synthesis9000/reports1200保持原帽和已耗成本，旧任务余额不转入。修复static单次≤300s/24GiB，局部RTL单次≤300s/8GiB、≤100000cycle；全项目锁/CPU0–3/nice19/idle/MemAvailable>192GiB保持。预算变更保留原计划和当前修订记录，不改旧guard收据。普通编译/TB边界错误按已授权规则有因修复，不逐步审批。若等价无法成立或新表示仍到资源帽，停止无新依据的重复尝试并明确源/物理未完成边界。

D38 AT011实际展开后的进一步表示修复：新e279968c在约1607s仍持续CPU、ownedRSS约16GiB、无DCP，实际日志仍指向op0/op1的3D-RAM潜在运行成本；源仍为64个unpacked槽×packed[255:0][31:0]。A014按实际结果建议主控有因停止该次以保留后继完整装配预算，主控已派发A010安全结束。此为主动重规划，不是stall/RSS保护触发、数值FAIL或工具失败，最终耗时/峰值/清理以真实收据为准。采用本节原允许的1D等价表示：每槽[8191:0]、64槽及原静态写不变，仅对应lane访问用原位序的32bit part-select替代；全字读/guard/冲突优先级/reset/周期不变。必须重新建立原2147d041到最新源的机械关系及同一6721cycle四态局部对照，再绑定新manifest继续同一物理流程；旧AT010和AT011证据不回写。不能承诺这将成功综合或推导BRAM/最终资源。D38现有总额、分类余额及保护均不变，不另起预算或重跑全30层。

### D38 AT014后唯一有界PS组合表示诊断（2026-10-25）

AT014最新f8491D版仍在1278.032619354s、owned峰25454276KiB触24GiB保护；op0/op1警告消失但无DCP，主进程主导且无能归因到PS对象的pass剖析。主控/A014已核真实日志/身份/清理，综合累计4719.634760798s、余4280.365239202s；完整资源未知、P&R/时序未运行。现只授权A010在同一owner和现有预算内执行一个可证伪PS纯组合表示诊断，细节和成本门采用[集中审核末节](../../../results/reviews/m007_d38_physical_review_20261025.md)；不直接批准又一轮整core。

候选先保存在E022实验路径，生产f849保持。原/改两侧机械抽取实际PS完整组合fan-in：保留64×8192 op0异步选择、pool_state、原grant/room/priority和全部1024bank及相关valid/tag/ready，不能预选payload、常量化派生控制或缩模型。候选仅将原动态bank散写按b={C,A,H,J}静态反解；完整f849应用diff可逆且只五个输出表达变化。读侧三个独立if次序、全局bias写分支对math的抑制、所有无效周期默认输出和四态if行为保持。先同输入四态差分核所有bank/输出、所有已知选择域、并发与X/Z selector/control/data；不能以原operand测试替代新组合路径验证。static/RTL各单次≤180s并扣现repair余额，普通脚本问题据因修复但不扩桶。

两次顺序OOC各≤180s、合计≤360s，直接扣原综合余额；同原part/工具/OOC/flat none/单worker/全部动态端口和24GiB等保护。原侧与候选各只一次，不自动延时或补第三个物理对照。纯组合无内部时钟端点则如实说明，不签时序。候选必须实际mapped DCP/零黑盒。整core准入只接受：两侧均完成且旧峰≥4GiB、新≤旧一半并降≥2GiB；或旧实际触24GiB而新180s内完整完成且峰≤12GiB。语义、源码/配置/真实边界和输出保留也必须成立。只有时间改善、警告消失、两侧都小或旧仅时间超限不准入。该阈值是本次成本决定，非因果证明。

达到门才允许将同一候选应用生产、冻结新manifest，并只一次整core≤1800s且受实际综合余额限制；不改容量/延迟/调度/算法。成功后依原真实DCP分区装配和完整P&R流程继续；若诊断门不成立或新core再无DCP则本轮阻塞归档，不继续猜测改写/换壳或加帽。以上不增加任何分类或总预算，不转旧余额；无实际全top网表不得给完整资源/时序结论。

### D38 用户明确增加运行预算并恢复（2026-10-25，最新有效）

用户在获知24GiB为本项目自设保护、服务器仍有大量可用内存后明确要求“给多点预算”。本次授权覆盖前述24GiB、9000s综合、16800s实施及PS诊断先决门。直接恢复现已验局部等价的生产engine f8493b130354123a57115f85bc1d6cdeab776a64697234962063604594b9c1cd、source_manifest_v3/bottom_up_v6及同一父top/ROM/11generic/300MHz约束；不应用未验PS候选，不以新增RTL试改代替本次预算调整。PS诊断现状保留并暂停，不再作为此轮综合前置。

新的D38累计运行预算（包含全部既有费用，不清零、不转旧mission余额）：preparation1200s、repair_static600s、repair_rtl600s、synthesis43200s（12小时）、implementation86400s（24小时）、reports3600s，总计135600s。综合与实际DCP链接单次≤21600s（6小时）；place/route各单次≤43200s（12小时），opt/phys_opt各≤14400s（4小时）；每次仍不得超过本类别实际余额。repair两桶和单次上限不扩大，本次不启动新RTL修复。预算账追加旧/新帽、直接用户来源和时间，所有旧收据/原停止分类保持不变。

完整综合/链接/实现/物理报告的owned进程树RSS上限改为128GiB；repair_static仍24GiB、repair_rtl仍8GiB。全机MemAvailable必须保持>192GiB，CPU0–3、单重工具锁、nice19/idle I/O保持；综合继续单worker，其他物理步骤最多4线程。仅内存增长、超过旧24GiB或日志静默不得停止。300s无owned CPU与真实日志/checkpoint进展才判停滞；真实工具错误、新128GiB上限、全机余量或新墙钟上限仍有界保护。只管理本项目owned进程。

原AT014已被终止且无DCP，无法从中途续算，因此允许在同一冻结源码下以新配置重新启动core综合，再连续完成既定真实DCP分区装配、完整资源分项、合法place/route和setup/hold报告。A010复用原owner实施runner/ledger/运行及摘要，A014在实际结果形成后集中审核；普通脚本/依赖修复不再逐轮要求确认。旧D37正常功能证据及本轮局部等价边界保持，器件/频率/硬件资源验收预算不变，不把扩大服务器预算当作硬件通过。完成或实质阻塞据真实结果收尾。

### D38 用户再次明确翻倍内存上限（2026-10-25，覆盖上一节物理RSS帽）

用户明确要求“继续提高一倍的上限”。综合/链接/实现/物理报告的owned进程树RSS上限由128GiB提高至256GiB；全机MemAvailable>192GiB仍是独立约束。累计及单次墙钟预算、repair_static24GiB/repair_rtl8GiB、CPU0–3、nice19/idle I/O、综合单worker和全项目单重工具锁均不变。不改RTL、数值、硬件资源目标或历史运行收据。

AT015当前Vivado必须继续使用同一进程和冻结源码，不为改帽停止重跑。原运行Python守卫把rss_cap一次锁存在局部变量，单改磁盘runner/command不代表当前上限生效。A010负责实现有界且可核验的运行时守卫更新或监督交接，保持原开始时间、费用、PID/start身份、锁、峰值/政策采样、停滞/系统余量保护、退出清理和最终源码核验；原command/frozen证据保留，实际生效时点及机制追加独立记录。未经实际回读或监督接管确认，不把当前运行写成已使用256GiB。

实际生效：2026-10-25 14:06:12.169726 UTC，AT015/rss256_handoff/activation.json记录独立监控接管256GiB，原guard单PID暂停保留锁和父子关系、Vivado/leader原PID/start不变。主控核后续live_status的effective_maximum_owned_RSS_GiB=256、CPU持续推进和trigger=null。原128GiB启动/冻结文件保留；原guard最后负责wait/subreap/源码核验及原receipt，新增effective_receipt汇总交接后峰值/政策/进程身份并绑定原收据。当前实际采样入口为该handoff子目录，不用旧live_status误判停滞；时间截止仍原17:41:33.917700 UTC。

### D38 AT015成本出口与有因综合策略接续（北京时间2026-10-26）

AT015在01:41触单次21600s墙钟帽，实际21601.398908s，COST_STOP；峰owned110.976433GiB、最低系统可用343.694820GiB，未触256GiB或stall保护。工具3:29:03完成Cross Boundary/Area Optimization、3:31:29完成XDC应用，随后Timing Optimization持续CPU到6h而未结束；没有完成比例或“即将结束”的证据。无core DCP，全部owned/监督进程退出、锁已释放，最终依据原receipt、effective_receipt_verified与post_run_audit；原30层功能证据不变。

主控根据上述实际停留阶段及A014本机Vivado2025.2参数核查，授权同一A010仅对core_synth增加官方`synth_design -no_timing_driven`，跳过综合内部的时序驱动优化以优先取得映射网表和资源。先核本机选项支持/保留来源，再冻结新flow/config和实际argv；若参数不支持则报告具体阻塞，不扩大为其它未定义策略。保持同f849/91源/ROM、原完整子树、PROFILE_ENABLE=0、OOC/flatten none/单worker、原11项父generic及300MHz XDC。不得删除时钟、放宽周期、改RTL/数值/存储/并发，旧PS候选继续暂停。此为综合策略变化，不能把新资源网表当作300MHz时序PASS，后续完整真实链接、布局布线和setup/hold验收条件不变。

只进行一次有因新core尝试，上限为min(21600s,原综合实际余额)，当前余额16878.966330898s；不新增更低单次帽，不增加分类/总预算，不移用实施预算，不抹去旧费用。物理256GiB/全机MemAvailable>192GiB/CPU0–3/nice19/idle I/O/全项目单锁及300s真正停滞保护保持。AT015无checkpoint，本次必为重新综合，不能声称中途续算。成功后立即保存真实mapped DCP再报告资源，在实际剩余分类预算内连续原分区装配/完整资源/实现；余额不足或新次失败则据实出口，不同源反复盲跑，不保证现余额一定完成整个父top。生产RTL不变，无需重跑原30层功能仿真。主控已实际followup，启动以新launch/command为准。

## D38 用户取消物理墙钟上限并要求两小时汇报（2026-10-26）

直接用户指令：“延长上限到无限时间 每两小时汇报一次 请开始”。本指令覆盖D38此前synthesis/implementation/reports类别的累计和单次墙钟帽；这些类别以null/disabled明确表示无墙钟期限，继续累计实际耗时并保留历史帽、失败和费用。preparation、repair_static、repair_rtl旧边界不变。当前AT019不为改帽重启，后续按原core→分区综合/DCP链接→完整资源→opt/place/phys_opt/route/时序报告顺序连续推进。

物理owned RSS≤256GiB、系统MemAvailable>192GiB、CPU0–3/nice19/idle I/O、全项目单重工具、综合单worker及300s真正停滞保护保持。日志静默而CPU仍推进不能判停滞。300MHz最终布线时序、资源目标、源码/数值/shape/参考值不变；不恢复旧PS候选、旧任务或上板。保留已授权同源core-only -no_timing_driven策略。

A010负责运行中监督交接，保留原Vivado/leader PID与start、锁、原收据及身份核验。磁盘配置更新不等于当前生效；生效以AT019新activation及实时采样为准。A001负责本既有主控会话每7200秒的实际回报，报告阶段、已用时间、内存、真实进展和结果；同样未变也应按用户要求汇报，重大失败/完成及时通知。定时器只读状态并唤醒原会话，不启动第二份EDA。用户暂停/取消或本物理阶段最终收尾后停止定时器。调度文件不等于送达，须核服务/定时器和原会话接受回执。

实际生效核验（2026-10-26）：AT019/unlimited_wall_handoff/activation.json在UTC23:44:46生效，原Vivado PID/start保持；10/10基础设施小进程测试通过且新live显式wall_time_limit_disabled=true。主控两小时user timer已启用并实际投递到原会话，首次接受回执与配置在.research-agent/automations/d38_report，下一次北京时间09:45:41；用户暂停/物理最终收尾后停表。旧固定时间帽和旧live入口保留为历史，不作当前执行判断。

D38 AT019收尾等待诊断（2026-10-26）：原生综合零error但未越post-synth检查/scope/DCP出口；非主线程CPU增长不能单独证明有效进展。用户明确选择“安排管理员执行诊断”，仅允许针对当前Vivado3583093/start66052106一次短时只读线程栈（info threads / bt16），不执行inferior函数/Tcl/写内存，不dump巨大core、不改设计或内核ptrace策略，不attach/CONT缓存有限帽的旧guard。关闭gdb自动加载和debuginfod；核原身份、独立监督、可靠detach、结果/退出状态。当前普通账户缺CAP_SYS_PTRACE且sudo需密码，由管理员实际执行，不向用户索取密码；命令/同用户可读输出由A010准备，主控核结果后连续原恢复工作。僵尸子进程仅为线索，旧guard正常循环亦不reap，因果未知。原process/日志/预算保持；此诊断不是新综合/硬件PASS。

### AT019 收尾等待已确因与定点恢复准备（2026-10-26）

用户实际执行两次管理员只读诊断。第二次DG_OBJECT_20261026T104830Z_8a4d5837实读HARTS唯一worker为3633734/start66420454、结束flag=1；worker处于Z、PPID3582995、原始exit0。结合冻结ELF轮询机制，确认该未回收PID导致收尾等待；尚未实测恢复后DCP落盘。原生综合完成、core DCP、完整资源和布线时序仍分开验收。

主控复用A010准备精确单PID WNOHANG回收机制，A014审核，只先做隔离小进程演练。无代码写入的single-step候选在执行期间tracer死亡测试中放开guard为S，已拒绝用于生产，原失败保留。下一候选只允许研究有限、可逐字备份恢复的原生自停控制片段：一次wait4后自发SIGSTOP，意外CONT只重新自停；必须从真正T状态重新attach、不restart地恢复全部原寄存器和借用字节。禁止Vivado内存/寄存器/Tcl修改、旧Python正常运行、waitpid(-1)、杀父/丢锁、重复综合。任何临时guard字节修改必须在具体管理员恢复命令交付时明确说明，不能称为只读；当前未执行生产恢复或监督切换。

维护只能有限暂停主monitor，现watchdog/observer保持在线；独立短维护者承担原256GiB/192GiB/CPU/单锁保护，并在原heartbeat失效前完成或可靠恢复。需真实覆盖tracer执行中死亡、寄存器恢复前后等关键窗口，不能靠“调用很快”绕过联锁。若保护和上下文恢复无法满足，就报告该候选不可实施，不冒险操作生产。后续未启动阶段的原guard只在finally回收孤儿问题另列防复发依赖，必须保持leader的真实退出码及原收据；本次不改运行中冻结guard。

19:25准备验收：entry c3bedb...、maintenance5a52d2...、core89cd5c...经A014最终限定审核和root真实只读预检。9个核心故障小例/5个真实监督联锁小例通过已测安全恢复检查；统一维护意图与4秒截止在STOP前落盘，独立coordinator接管，故障操作失败与安全恢复通过分开。该截止不是任意内核/文件系统停顿的实时保证。当前仅准备接纳，尚未生产执行；具体管理员入口明确临时写旧guard RX尾48字节、随后还原全部字节/寄存器并交回监督。原Vivado/RTL/源码/时间与资源合同不变，恢复后按真实DCP/阶段receipt接续串行流程。新canonical runner定点回收补丁已通过孤儿exit11、leader7/managed13保持和非owned/错start/活子排除小例，原AT019冻结runner与最终verify_inputs身份不受影响。失败不自动重复wait4，不直接CONT旧guard。证据集中于R001/exact_child_recovery_ready_receipt.json及原物理审核报告末节。


2026-10-26 19:52实际恢复验收：管理员已于19:45执行已审入口，RC_EXACT_20261026T114520Z_9baee073实际wait4返回唯一3633734、原Z消失；冻结恢复代码回读确认全部寄存器/48字节还原，原guard T/TracerPid0、原monitor恢复，统一维护0.901117602s。A010/A014分别审核原件，原Vivado PID3583093/start66052106不变，日志已出现Synthesis Optimization Complete/Translating synthesized netlist，真实计算线程3583107恢复R/CPU增长，原等待线程消失。此次恢复成功，不是DCP或硬件完成；当前checkpoints空，原单重工具、无deadline/256GiB/192GiB余量及两小时回报保持。既有serial在真实core DCP/有效收据通过后连续原授权流程；不重复恢复、attach、直接CONT旧guard或重启EDA。后续新stage自动加载已验canonical定点回收补丁，当前冻结runner不变。实际证据见原物理审核报告实际恢复节及.research-agent/automations/d38_report/reports/20261026_1948_recovery_verified.json；上文未执行状态保留为历史。
