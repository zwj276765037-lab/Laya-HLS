# Executor查询前保持与导入确认补充合同

决定：**D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01**  
回复：`executor-checkpoint-import-handshake-question-20261013`  
范围：M003/SM003/E003/R003。补充[检查点高水位合同](executor_checkpoint_high_water_contract_20261012.md)及[真实v2检查点审核](executor_checkpoint_rtl_reply_20261013.md)，原诊断范围、接口权威和预算不变。

## 1. 决定与职责

**采用有界、带事务键的prequery hold及IMPORT确认握手。保留prepare/accept要求真实排他与安全事实的合同，不把prepare改成可以在未持有排他时启动查询的接口。** 当前prepare等held、shell等完整LBS2才建立held的互等通过独立的查询前保持入口消除。

保持取得、LBR2完整消费、本地原子导入、shell派发授权是四个不同事实。第16拍read仅证明传输完成；它不能单独产生生产authority、发布LGP1或启动action。shell持有唯一派发门及来源保护，executor持有唯一FullRuntime并核codec/helper，hub仍是owner/发布/typed事实权威，原LPV transport仍提供事件下界。新增控制状态不得成为第二发布表、退休器或编号分配权威。

本合同只明确同一真实LYRQ/LYMP已准入请求、受控完整前序到有限NORM诊断的交接。完整graph仍由持续executor保留状态，不经该入口反复导入；未知预约、丢失runtime、任意软复位/跨session恢复仍不支持。

## 2. 查询前绑定与序号

先从已准入且保持的请求/model、来源Ref与geometry、目标物理域及实际base配置生成**无副作用的绑定描述B**。B包含完整NumericIdentity、L13M、source和target描述、base地址/容量/配置epoch，以及唯一shell的硬件session/accepted-request实例归属。描述只声明要锁的对象，不声明READY、排空或取得权威；构造B不得依赖held或LBR2。

为避免同请求重试复用旧确认，本次将**现有snapshot sequence的一次性预约提前到创建hold尝试时**：唯一executor沿现有持久sequence高水位取下一个非零号S，锁存`(B,S)`，随后才允许hold valid。取消或失败不退还S；这是控制事务耗号，不是task/Ref预约、退休或请求重新准入。held后的prepare使用这个已预约S，核其对应唯一pending尝试，不能再加一次，也不能接受调用者任意指定旧S。允许拆分描述、控制耗号、prepare_held三个小步骤或等价有限状态；旧helper可保留兼容包装，但生产路径必须有该顺序和强检查。

shell在实际接收hold请求时分配持久、严格递增的handoff epoch H，记录此尝试，即使后续未能取得保持也不复用H。S和H各保留原唯一分配权，shell不重新分配S、executor不伪造H。双方记录已消耗/已观察下界；这些记录与成功导入的baseline分开。新鲜性在预约/首次接收时检查；prepare/accept对当前已预约pending精确匹配，不能再要求S/H大于刚更新的已耗高水位。位宽耗尽在接收新尝试前明确拒绝，不能回绕。真实硬复位的session隔离必须覆盖全部相关通道；本入口不能靠局部phase清零伪装新session。

hold请求至少携B和S；held/拒绝返回回显同一绑定并携H。后续键K由当前session/accepted-request归属、NumericIdentity、S、H共同确定，映射到shell唯一不可变B。IMPORT及grant可以引用这个完整K和已锁存B，不要求重复传输416B模型；不得仅凭未校验的短hash、无tag布尔或单个脉冲匹配。旧K不能影响当前pending，重复K不能再次导入或再次授权。

## 3. hold待处理时，旧工作仍须前进

shell接受hold意图后进入DRAIN；接收请求不等于已held。应向前序的唯一派发权威提出停止新action/新诊断段的请求，**保留已接收旧action完成所需的后续窗口、producer读写、END、必要PUBLISH/INVALIDATE及全部返回消费路径**。不能只按LPV opcode猜测哪些是新任务，也不能关闭正常门后让旧action再也发不出所需BEGIN/END。

已有LPV半帧、已预约尚未提交任务和已接受producer也属于旧工作。先按原路径完成或安全清理；hold不能清队列、丢返回、回退编号或强制退休。若当前有限入口不能识别action边界，使用前序控制器真实产生的有界完成/不再派发握手；不能用“这个周期没有valid”推导完成。该握手可以来自受控前序controller，但应诚实标为诊断前序，不称实际encoder完成。

取得保持必须同时满足：前序权威已交出新工作派发权且无隐藏预约/待发、实际LPV命令/返回及F10待发/返回已排空、scope/pending END/monitor AW/W/B及读债/lease/fence满足原安全规则、旧结果已按所属接口实际消费、当前identity/model/source/target/base/session仍匹配且无cancel。`physical_quiescent`来自独立真实债务，不能定义成“held已成立”而再次造成互等。

在最后一个旧事务/返回同拍处理的边界，要么先接受并保留旧工作而推迟held，要么已由前序完成握手证明不再有旧请求后锁门；不得同拍既接受新前序事件又声称稳定快照。正常有限旧任务必须能在hold valid持续保持时完成，不以撤valid、reset或清FIFO制造进展。

条件齐备才原子关闭前序派发、锁source和target的修改/别名入口，锁存实际配置并返回持久HELD(K,B)。保持只证明排他，不证明source已发布或target可用；这些仍由hub查询决定。HELD反压期间真实门锁已生效且返回稳定。

## 4. 查询、导入与最终授权

顺序固定为：

| 阶段 | 允许的动作及退出条件 |
| --- | --- |
| HOLD_PENDING / DRAIN | 保留旧工作进展；无LBS2、LGP1、新executor action。 |
| HELD | executor收到匹配HELD，使用B/S/H及真实Fence完成prepare_held；仅此时发送原16拍LBS2。 |
| QUERY / RESPONSE | 完整LBS2须与held绑定逐域一致；原hub/transport给出同交接点的LBR2。真实16次读取并保存全帧，保持source/target及前序派发门。 |
| IMPORT_PENDING | shell记录全帧已实际消费，但authority仍为0；executor完整codec、所有负例与helper预检通过后一次提交baseline/镜像/下界。 |
| IMPORT_CONFIRM | executor从实际helper成功出口发送`IMPORT_OK(K)`；失败发送绑定`IMPORT_FAIL/ABORT(K, reason, local_commit_state)`。确认保持到真实ready/valid握手。 |
| GRANT | shell仅对唯一pending、完整成功LBR2已消费、实际IMPORT_OK且未撤销的K，重新核当前配置/保护/物理安全后发持久`GRANTED(K)`。executor收到同K授权后才外发LGP1或接收action。 |

本地accept产生的Command先留在executor内部暂存。`checkpoint_baseline.valid`、SOURCE_CONFIRMED或SOURCE_READY_PROOF不能跳过GRANTED；program不能提前收到命令，executor也不能提前消费LAX1、外发LTX1/LPE1或开启AR。首次正常派发从最终确认后的已登记状态开始；不在LBR2末拍或IMPORT握手的组合路径上直通，cancel/base失配当拍始终优先禁止启动。

shell的GRANTED返回必须保持并带K；executor将其与自己的已提交baseline对应。持续authority还须受当前cancel、live base/session与来源保护约束。响应字节因反压保持稳定与authority被撤销可以同时成立；不得改写已呈现的成功响应来掩盖撤销，也不得因成功字节仍在而重新准入。

除合法query外，held期不能再开放前序修改。取得GRANT后，旧前序入口保持关闭，source保护继续移交给实际action/source guard直至原合同规定的读债、F9同consumer、END/物理fence和LAC1安全消费完成。target锁转为对唯一executor匹配首个CLAIM/预约的许可，交接必须无空窗；它既不能在导入后提前解除给其他writer，也不能把合法首个CLAIM永久挡住。

交接后QUANT source query继续按真实派发权路由valid/ready/granted及归属。`checkpoint_dispatch_held`不能同时表示“原前序已禁用”和“所有新owner的query永远禁用”；此前默认关闭checkpoint的lease回归不能代签此连接。

## 5. 失败、撤销与收束

cancel、实际base/配置epoch变化、session/请求归属失配从DRAIN到GRANT和实际启动前持续检查，**同拍优先于held、末拍消费、IMPORT_OK、GRANTED及producer/action准入**。一旦观察到撤销，对该K保持撤销记录，即使信号后来恢复也不得重新授权。已呈现的控制返回保持至实际消费；撤销结果另经绑定状态/返回表达。

错tag、重复/早到确认、IMPORT_OK但未收齐成功LBR2、失败状态带成功确认、保留位/长度/版本错误，均零授权/零新派发。应在明确的有界控制接收/拒绝路径上处理，保持当前pending及既有高水位；不要将不匹配valid永久压住并阻塞正确确认。无法安全确定帧归属的损坏按既有协议隔离，不凭“控制错误”宣称硬件债务已清。

本地导入前失败：FullRuntime的baseline/owner/任务/退休统计不部分改变；已耗S/H保留。负LBR2末拍不能自动解锁并恢复前序。executor提交绑定ABORT，shell确认本次控制帧/返回/债务全部收束且没有本地commit，再以匹配ABORT_CLOSED确认结束尝试；仅在同一仍有效请求且真实安全时，明确把派发权退回原前序或允许下一次新S/H尝试。不得靠超时或猜测恢复派发。

本地导入已提交而IMPORT未获授权：保留导入事实、allocator/Ref/LPV及所有已耗下界，禁止再导入同一baseline，也不回滚到旧值；进入撤销/错误收束。不得把`IMPORT_FAIL`谎报为“未提交”来重开前序。完成当前请求的真实错误结果/安全释放后，才允许下一次真实accepted request。该状态不产生TaskDone、不虚增退休，也不是完整请求成功。

DRAIN期间若cancel或旧错误发生，旧runtime仍有匹配cleanup和返回路径；GRANT后发生错误则保持已属于executor的旧action cleanup路径。普通新派发禁用不能封死本owner已接受任务的END/INVALIDATE/完成消费。source及target保持何时释放取决于真实安全和对应结果消费，不能只看IMPORT失败、时钟超时或单个TB布尔。

## 6. 新请求重装阶段

新增有界、带旧/新请求归属的rearm/accepted-request握手由唯一shell与executor协同：先确认旧action/tracker/reader/producer/lease/物理债务与所有相关半帧/返回已终结，已产生的program/action/producer/Host结果均由其真实consumer完成，旧控制事务已关闭且不存在旧authority；再允许执行原`full_begin_request`及真实LYRQ/LYMP新请求准入。未产生的program结果不得编造一次“已消费”，应记录该分支本来未启动。

重装只清当前事务phase/pending/局部消费计数和已安全失效的请求绑定；snapshot S、handoff H、LPV、task/Ref历史及producer/compute/program ordinal等各权威的保留下界按原合同保持，不能因为新phase或错误返回归零。新准入失败不重开旧authority。旧HELD/LBR2/IMPORT/GRANT/result通知即使迟到，也不能使新请求前进。没有完整13BO/base与真实结果消费者证据时，只报告已测诊断重装范围，不签通用恢复。

## 7. 实施与有界验证出口

新增握手为内部固定宽度、单inflight、显式版本/长度/保留位的控制接口，不改LBS2/LBR2原1024B/16拍，不挪用其保留位，不新增Host/外部wire。工程可选择等价的宽payload ready/valid或固定拍数内部流，冻结C/SV schema、归属键及独立oracle；不得留下无tag长期布尔许可。查询前控制通道必须独立于held才开放的查询通道，避免新循环依赖。A002仍为唯一实现owner。

先做受影响host及shell有限证据，再按现有资源帽串行生成有结构差异的executor；无需逐项审批。新增验收至少包含：

1. 真实已准入runtime发起hold；hold持续valid期间旧action必要后续事务、末B/END/返回正常完成；真实取得HELD后才能prepare/query，不能等未发送查询产生held。
2. HELD及LBR2/IMPORT/GRANT分别反压；LBR2尾2/尾1停读且两派发口持续valid。第16次read之后有意延迟/拒绝helper导入，期间零LGP1/action/LPV/LPE/AR；实际匹配IMPORT_OK及GRANT后才唯一切换。
3. 错S/H/identity/session/base、旧/重复/早到/失败确认及溢出；不影响当前pending、不回退下界、不重复导入/授权、不伪造退休。至少一次真实helper成功及一次真实helper拒绝驱动确认，不只TB写IMPORT_OK。
4. cancel/base变化在hold取得、LBR2末拍、helper提交后但确认前、IMPORT握手、GRANT反压和启动边界交错；撤销不因信号恢复而失效。本地已提交但未获授权须保留高水位并安全收束。
5. 合法负查询经绑定ABORT_CLOSED后可按实际安全返回前序或重试；已提交导入失败不能伪装未提交重试；旧cleanup无撤valid/reset/清队列也能进展。
6. 同持续runtime至少两个真实accepted-request生命周期，旧结果未消费时不能rearm，旧确认不能开启新请求，所有相关保留编号严格不回退。未实现该项应明列NOT_RUN，不能用复位分隔case代签。

真实生成executor的codec/helper确认、8/4 action consumer、F10 24/16实际LTC1读取、LN/hub实际END/唯一软件退休及Q/fullA仍按原顺序连接。有限shell或host测试不能代签这些生产出口。

## 8. 记录与项目状态

计数更正已独立对上一次主控审计逐项核对：183组pair及621项引用一致，183份冻结SHA仍匹配；更正时current174/183、引用612/621，登记前179/183、617/621，差异均为已披露catalog。四份历史交付及原六attempt的12个manifest/receipt未变。关闭此行政补计事项，不新增实验PASS、不回写旧审核或attempt。

这是接口决定，尚未实现验收。C009部分实施/awaiting_implementation，C008/C010整体待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、单重工具及各入口更严格帽保持；G OOC余2338.224019s。无新增agent/OOC/P&R/上板/预算，5172s组合不重启。主控只做静态与证据核查；新受影响冻结闭包纳入本合同，历史证据保持原范围。
