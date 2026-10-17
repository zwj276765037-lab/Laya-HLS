# 请求关闭与重新准入补充合同

决定：**D-M003-EXECUTOR-CLOSE-REARM-01**  
回复：`executor-close-rearm-question-20261013`；M003/SM003/E003/R003。补充D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01及D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01。A002仍为唯一实现owner，原范围/资源预算不变。

## 1. 决定与wire语义

**采用LHC1内部kind扩展CLOSE=8、CLOSED=9，保留version1、1024B/16拍及全部原字段位置。原kind1–7字节/语义不变，不挪用保留位。** 这是同一受控构建中新增操作码；旧decoder必须继续拒绝未知kind，不能声称旧端点已支持新关闭。C/SV、完整codec、独立literal及所有实际端点按同一闭包更新，其他未知kind仍拒绝。

CLOSE与CLOSED均完整携带旧K/B：hardware session、accepted-request实例、NumericIdentity、S/H、source/target/model/base绑定。S/H必须是原已分配值，关闭不预约新S/H，不重新查询或导入。`local_committed`在CLOSE接受时与shell已保存事实精确一致；CLOSED原样回显。状态code/detail/bad_element表示**已封存的原请求终态**，不是另一个“关闭操作成功码”：失败原样保留非OK首错，成功允许规范OK/detail0/bad=UINT64_MAX。CLOSED即使携非OK也可表示这个失败请求已安全关闭，接收端按kind、完整键、终态及commit事实核验，不能用`result==OK`作为唯一关闭条件。

CLOSE是整个旧请求终结意图，不是再开同请求一次HOLD的许可；ABORT/ABORT_CLOSED继续承担原未提交尝试终结/同请求重试语义。已提交失败不得谎报commit0。若helper确已提交但IMPORT尚未被shell接收，先沿原绑定IMPORT或commit1 ABORT实际传达并保留提交事实；这一步不授予启动权。未知提交状态不能默认当0，也不能由CLOSE直接把shell记录改成自己声称的值。

## 2. CLOSE接受、真实收束与CLOSED消费

wrapper为唯一旧请求维护有界、持久、完整归属的收束记录。CLOSE不是自报drained证明。其请求终态须已由实际执行/错误路径封存，匹配已产生的最终结果，不能让未决后续错误通过改写已呈现结果被隐藏。

shell可接受并锁存一份合法CLOSE意图，随即禁止该请求新派发；独立旧cleanup及返回消费继续。发布CLOSED必须由同旧K的真实事实共同满足：

- program/command/action/producer各分支已明确终结，没有隐藏预约或未发工作；实际产生的每个完成与结果已由对应真实consumer收齐并核验。
- Host实际消费本请求最终结果；全部LGP/LAP/LAX/LAC/LGR、LBS/LBR、F10/LPV及相关旧控制半帧、队列和返回均已结束；旧IMPORT/GRANT等不能留到下个请求。
- 实际hub scope/pending END、monitor AW/W/B、adapter待发/返回/写债、source读债、lease和fence按各原权威满足安全条件。错误隔离状态只有在已知终态、归属和安全事实齐备时才可关闭；未知坏帧/未知债务不能靠CLOSE越过。
- 终态code/detail/bad、commit、完整K/B与保留记录相符，关闭只计一次，不造TaskDone/typed退休/业务统计。

“全部排空”不包含本次故意持有的CLOSE意图、将要发送的CLOSED、已结束事务的记账状态和有意保持的保护锁本身；否则会等待自己。它必须包含它们之外的真实旧传输/债务。`physical_safe`不得定义为“已经CLOSED/锁已释放”。

CLOSED一经呈现，字节和valid保持到实际消费；同拍撤销也不改写。反压期间旧归属、保护锁和关闭记录仍在，不能提前rearm。实际完整CLOSED consumer先核键/结果/commit，才能提交一次`closed_consumed(old_owner)`事实；错误/早到消费通知不能充当此事实。若采用16拍流，写入末拍、FIFO pop末拍和完整codec成功分别跟踪；若是8192bit ready/valid，ready须代表真实完整接收验证的约定。不能仅凭上游write或无tag脉冲解锁。

CLOSED实际消费后，唯一wrapper协调actor/shell/transport清旧phase和已排空的route/锁，保留最后关闭归属及已消费标记，进入**旧请求已关闭、等待新准入**状态。该状态禁止旧前序和旧executor新派发；不得直接复用会开放原前序的旧IDLE逻辑。释放不清hub owner历史/typed数组，不代替必要INVALIDATE，也不恢复旧authority。成功请求和失败请求在生产managed路径均遵守这道边界，不能让成功分支继续从Host消费直接跳过shell关闭。

重复/错K/CLOSE、CLOSED、GRANT等走明确的有界拒绝或已处理判定，不重复释放/计数，不占住正确旧cleanup；已呈现响应继续受F18唯一仲裁规则保护。已关闭K不能给下一请求权限。

## 3. 撤销后的归属与物理绑定

**关闭核对保存的旧K/B及各consumer的旧归属，不要求当前新输入重新等于旧base/session。** cancel持续为1、输入恢复或改成下一请求都不能自动撤销既有关闭资格，也不能让旧K变成新K。新启动仍受当前cancel/live条件阻止，旧cleanup/结果/CLOSED可在持久撤销下前进。

这不授权忽略物理失配：旧债务必须仍由实际旧owner/原配置记录识别并排空；若base被重新指向、session真实重置或归属丢失导致无法证明旧债务安全，保持隔离，不能用新base空闲冒充旧base已排空。完整13BO/旁路未接入时，只报告已接入域的关闭证据。跨硬件session恢复仍不由本合同代签。

## 4. “未启动”须来自完整旧请求记录

同意采用实际program状态与真实首末拍计数，但还必须覆盖executor侧command尚未外发的事实。为当前唯一请求维护完整归属记录A：已真实准入的hardware session/accepted-request实例、NumericIdentity、L13M及实际物理配置；有HOLD时再关联完整K/B。该记录只有在本请求安全关闭后才退休，不可按瞬时FIFO empty或program回到READ_COMMAND重新推断历史。

| 实际分支 | 必须保存并交叉核验的事实 |
| --- | --- |
| LGP1从未外发 | executor已锁住普通发出门且本command实际发送0拍，无待发/隐藏command；program所属入口没有本请求首拍/分配action/产生结果，相关route/FIFO无旧帧。记`program_not_started`分支，program结果消费为“不适用”，不能写成已消费。 |
| LGP1已有任意拍外发，但尚未分配action | 保留完整旧command/K，正常消费全部4拍；program按原逻辑产生实际ordinal0 LOCAL_REJECT LGR1并由真实consumer消费。不能因program目前尚未读首拍就宣称未启动。 |
| action已分配/产生 | 保留实际LAP1 pending和ordinal及各方向首末拍；未准入action走已核cancel-drain，部分/活动action沿旧port/FSM。真实LAC1消费→LGR1→Host结果各自绑定；不降级成“无action”。 |

**已接受请求即使从未启动program，也仍欠一个真实请求错误结果给Host。** 由executor的本地请求错误路径使用既有合法结果格式产生、标明实际来源并等待真实Host消费；不得伪造一次program LGR1/LAC1生成或消费来让状态机通过。其安全标志沿原结果合同核验。未被真实准入的坏LYRQ/LYMP则走既有ingress拒绝语义，不冒充一次accepted-request关闭。

这些是持久的分支/计数/归属事实，不要求另造无意义消费脉冲。固定单command诊断可用有界首末拍/分支位；未来多个action须按真实单inflight归属扩展，不能把本例0/1计数当完整graph证明。数据记录引用A或K时，必须唯一映射到wrapper锁存的完整对象，不能仅凭短hash或任意标签。

若请求在取得任何HOLD/S/H前已终止，本来没有合法K。不得伪造H0/S0的LHC1 CLOSE或为关闭额外制造一次HOLD。由请求ingress/actor使用同完整A的真实本地错误结果、未启动及物理收束事实形成`admission_closed(A)`；它只是无HOLD分支的等价内部关闭事实，不能拿它关闭已经存在的K或绕过CLOSED消费。有效K存在时一律按上文CLOSE/CLOSED。

## 5. rearm使用独立、带旧/新归属的准入握手

**本轮不再增加LHC1 REARM kind或独立串行REARM帧。** rearm并入唯一request ingress与shell/executor之间的有界ready/valid准入事务；它必须是带键的实际握手，不能是外部长期bool。最小逻辑字段如下，已有完整锁存对象可复用，不要求再复制一份发布/编号权威：

1. 旧关闭依据的种类：真实首次准入FIRST、`CLOSED_K`或无HOLD的`ADMISSION_CLOSED_A`；后两者携完整旧归属，且精确指向唯一已核、已实际消费的关闭记录。FIRST只可由真实硬件session初始化事实使用一次，不由Host声称。
2. 新候选的hardware session及非零accepted-request实例；沿现唯一ingress分配权/新鲜性规则产生，严格越过已使用下界、不回绕。hardware session与NumericIdentity.generation分开核验，不借新session字段清旧状态。
3. 当前候选真实LYRQ/LYMP解析得到的完整NumericIdentity、L13M/模型身份及实际base epoch/address/capacity/请求物理映射绑定。验证期间冻结该候选和实际配置；若复用内部记录，只可引用唯一稳定完整对象并逐域核验，不能仅接受Host声称“validated”。
4. 匹配上述旧/新归属的实际准入成功或拒绝返回，持续到消费。返回属于此次新候选；旧CLOSED/GRANT或另一个候选不能匹配。

顺序为：旧结果/真实安全完成→CLOSED完整消费或合法A分支关闭→各实际通道确认旧phase可清且旧入口仍关闭→锁定新候选→原`full_begin_request`及真实LYRQ/LYMP解析/准入恰执行一次→成功原子安装新归属并返回匹配接受事实→才开放本请求正常前序及下一次HOLD准备。允许分几拍实现，但中间无任何派发窗口，也不能在CLOSED消费同拍把新请求组合直通执行。旧关闭事实只允许一个inflight新候选；没有新有效请求时持续等待，不能自动复活前序。

CLOSE/关闭事实不是新请求准入。解析失败、绑定变化或cancel时返回实际拒绝，不安装新归属、不重开旧authority；已耗控制号及各权威下界不退还。下一候选遵守原ingress的序号规则。同一新候选的反压/重放不能重复调用begin/admit；旧/新输入在处理间变化不能替换已锁存候选。

重装清phase/pending/局部拍数及已经完成的请求绑定，不清持续S/H、LPV、task/Ref历史、producer/compute/program ordinal和可信接收下界。每请求业务统计可沿原语义开始新段，历史统计记录及allocator下界须分开，不能用task最大号制造退休。

**具体源码注意：当前`full_begin_request`会重置`dispatch_reservations`、`last_task_id`及checkpoint_baseline，`full_recycle_request`也重置本地任务/统计字段。不能把这些现有调用原样当成满足持续hub下界的rearm。** 在唯一持续runtime内明确保留/恢复所需分配和比较下界，或拆分请求局部初始化；保持无隐藏预约前提，不能丢任务、重复导入或伪造退休。完整来源镜像有效性由新真实请求及原owner生命周期决定，不因保留下界而复用旧READY许可。现有host“两请求”证据不代签这个新生产边界。

## 6. 有界验证及继续工作

新增验收至少包括：CLOSE早到但Host/结果/末B/R/fence分别延迟时不发布CLOSED；CLOSED持续反压且cancel/base输入变化时字节稳定、锁/旧route不提前释放；commit0/1不符、错/旧K、首错字段变体、重复CLOSE/CLOSED/消费通知均不推进；helper已提交但shell尚未观察到时不会被误当未提交；无LGP、部分LGP、取消drain及活动任务各真实结果分支；成功/错误关闭后同持续硬件session下一真实请求，全部各权威高水位不回退，旧确认/旧result不能使其前进。

实际安全条件与控制状态分开，证明持久cancel时旧半帧/返回能进展；不得reset、清FIFO、丢结果或撤valid制造收束。先冻结C/SV/schema、oracle及受影响host/有限RTL，再按原合同串行生成相关executor。普通修复和独立query ingress工作继续，无新增逐项审批。

这是接口决定，尚无实现PASS。F17/F18既有关闭不扩大；C009/C013部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单owner/单重工具/全部资源帽及G余2338.224019s保持，无新agent/OOC/P&R/上板/预算，5172s组合不重启。主控只做静态合同/源码核对。
