# 持久撤销下的LPV归属与cleanup合同

决定：**D-M003-EXECUTOR-MANAGED-LPV-OWNER-01**。回复`executor-managed-lpv-owner-question-20261013`；M003/SM003/E003/R003，A002单owner。补充D-M003-EXECUTOR-CLOSE-REARM-01及HOLD/IMPORT合同，不改变LPV1/LPA1、Host13BO wire或编号分配权。

## 1. 决定

采用唯一wrapper持久完整admission **A** 作为LPV请求/返回的归属根；存在HOLD时关联已保存的完整K/B。managed transport从真实首拍接收锁存旧A、route及该帧信息，保持至16拍请求和8拍返回被真实消费；取消、当前base/session变化、HOLD或派发路由变化均不得重绑、复位或丢弃它。

cleanup事实由**唯一hub原owner/active_begin状态精确核定**。优先在现service完整请求接收路径内增加managed归属检查，或等价的只读候选核定接口；不在transport复制CLAIM/BEGIN发布表，不增加第二退休权威。仅有accepted_begin_packet不足以支撑CLAIM成功但尚无BEGIN的INVALIDATE。

“允许暂存候选帧”“确认旧归属”“允许hub实际修改/终态”分别判定。首拍只有header，不能假装已经比较全帧。无需先取得一个长期cleanup许可才准许收集完整候选，以免互等。

## 2. 最小归属记录与来源

A沿既有CLOSE合同，必须在正常前序LPV启动之前，由唯一request ingress的真实LYRQ/LYMP准入成功建立。最小逻辑字段如下，采用内部固定宽度或稳定记录引用由工程冻结C/SV及oracle；不新增Host输入声明“可信”。

| 记录 | 必须保存的事实 |
| --- | --- |
| admission A | 非零hardware session、accepted-request实例、完整NumericIdentity（沿现84B规范）、完整416B L13M，以及实际已准入物理域的role、base epoch/address/capacity和映射有效范围。 |
| A生命周期 | 已准入、持久撤销、关闭/等待新准入状态；真实旧派发owner及待发/cleanup归属。当前输入只用于发现撤销，不覆盖已存A。 |
| 可选K关联 | `has_K`及唯一已接受HOLD的完整K/B，保留S/H归属。无HOLD的合法A不得伪造S/H；已有LPV帧不会因后来生成K而改绑定。 |
| 单LPV pending | 对完整A的稳定引用、实际选中route、首拍header/序号、收集的完整1024B请求、原请求阶段/已交hub事实、512B返回及8次consumer读计数。已有单pending寄存器可复用。 |

`bootstrap::AdmissionFence`两个bool不是A；shell的current_* live口也不是已准入记录。可复用唯一runtime真实准入后的`inputs.identity`、已核L13M与实际物理绑定构造A，再用明确内部安装握手交wrapper；不能把TB驱动的current_identity/current_request当真实准入证据。当前单STATE0诊断可只声明该域KNOWN/COMPLETE，未知role拒绝，不宣称全13BO映射已齐。

完整对象引用允许节省重复416B存储，但引用必须唯一指向不可变的完整记录，在任何旧帧/返回/owner/债务仍引用时不复用。禁止短hash、易复用slot索引或无tag长期bool充当归属。hub若只存session/accepted-request作为引用，也须和唯一稳定完整A一起核定，不能仅比较这两个数就认为model/base匹配。

hub现owner数组仅记录NumericIdentity/model/descriptor，不能自动证明hardware session/accepted-request归属。最小补充是给现owner槽的成功CLAIM及active_begin附上对A的归属引用；在hub实际成功事务中写入，不从caller声称的CLAIM成功、请求发出或返回FIFO empty推定。保留现owner数组为唯一事实表。若有限实现用单个全域A关联替代逐槽引用，必须证明所有活动owner/scope均由该A的唯一入口形成且切换A前无旧活动引用；有未见前序/遗留活动owner时拒绝，不能事后贴上新A。已停用owner的epoch等历史仍保留。

source/target可能由同A的前序创建并在交接后由executor使用，因此owner的A归属不随lane改变；哪个lane可以发起当前cleanup由wrapper真实旧派发/交接记录决定。pending帧的route则从首拍至响应消费固定。HOLD期间若旧LPV未排空，不得仅改变全局selected_cmd，把后半帧或返回交给另一lane。返回只有原consumer能推进其计数。

## 3. 撤销下的收帧与响应

managed模式单独启用，旧默认诊断行为保留。wrapper应把持久A撤销接入LPV：外部cancel、已观察的配置/归属变化及相关shell撤销共同禁止普通新工作。仅把live cancel接入或等待它恢复为0不满足合同。

- 首拍已实际接受的帧由原A/route收齐剩余拍并做完整wire、identity、L13M、descriptor和归属校验。已到hub的请求继续原实际结果/末B/END处理；不得再次执行、改写其已呈现成功返回或把它降成“未接受”。
- 撤销后普通CLAIM/BEGIN/PUBLISH/RELEASE等不得产生新的业务副作用或预约。已经部分接收但尚未提交hub的普通帧收齐后按原格式给出绑定负响应，保留原计数/错误规则；不能因属于旧A就继续新业务。END/INVALIDATE只有通过下节核定才可提交cleanup。
- 未接首拍的cleanup可从唯一旧A、仍被允许完成旧工作的route进入**单个有界候选缓冲**。首拍可用合法header的END/INVALIDATE作粗筛，但这不是许可；收齐后才由hub精确核定。候选不要求scope_active为1，因此CLAIM-only的INVALIDATE可收集。
- 若上游adapter已经拥有尚未发出LPV首拍的旧业务帧，不能用full_n永久为0让旧事务等待自己。由该adapter沿原本地拒绝路径真实收束，或在完整旧A/待发归属已知时有界收齐并返回负响应，零hub业务副作用。此出口只用于已有待发事务，不开放任意新业务尝试。
- 无法确定A/route的首拍不接受；全帧身份/模型/归属损坏按原隔离规则处理，不包装成当前owner的可信完成。已知归属的合法但不允许操作按完整绑定负返回拒绝；scope/drained/status保持原codec规则，不能以拒绝操作虚报旧scope已经关闭。

managed下禁用`cancel && service_domain_drained`导致的transport FIFO reset、拍状态清空和response掩蔽。局部framing只在本次完整返回实际第8次读取后正常结束；完整返回绑定/语义校验及adapter终态仍由真实下游负责，8次read本身不造软件退休/CLOSE。若随后消费者报告不匹配，保留隔离及未完成事实，不把“已读出”当可信终态。

返回一经呈现，其valid/data和原归属在尾2/尾1及任意反压期间稳定，即使scope已结束、domain_drained变1、cancel持续或当前base改变。保留原可信header耗号/last_event_seq规则和单pending串行性；错误/撤销不退号，不能在查询许可或只读核定中额外耗LPV/task/Ref。当前实现于完整返回消费更新可信序号的行为可保留，不以错误路径清phase跳过耗号。

HOLD的DRAIN且尚未撤销，与持久撤销必须分开。未撤销的旧action仍可按原合同完成必要后续BEGIN/END/PUBLISH等，不能套用“仅END/INVALIDATE”的撤销规则把正常前序锁死。它们仍须属于真实已经接收的旧action，禁止开始下一action。

## 4. hub精确cleanup核定

最小接口可复用完整`service_request`，附单pending的A引用/冻结归属和cleanup候选模式，核定在hub内与原服务提交相同的稳定时点进行。若实现独立只读ready/valid检查，请求须带A、实际帧序号/类型及完整待提交候选；返回绑定同A及同一不可变pending对象，不能只是悬空allow bool。检查不修改owner/typed、统计、physical observation或lease，不用physical_drained作为“收齐候选”的前提。多拍检查后真正提交时重核，或持有现唯一仲裁排他直到提交，避免查询后状态改变。

**END：** 核A/route属于原已接收工作；存在同A的scope/active_begin，完整identity、L13M、task/Context、origin BEGIN event、descriptor count、两个完整descriptor、expected unit/elements及两组geometry与原`end_binding_ok`规则一致。END自身event序号按transport规则新鲜，状态/首错/issued bytes必须来自原实际完成路径并满足原语义，不能为了“匹配BEGIN”改写真实错误或部分提交。物理观察、末B、adapter fence、实际issued/observed比较继续由唯一monitor/hub处理；pending END可在未物理排空时登记并等待，不能先要求全部排空才允许END进来。仅`finish_end`沿原规则生成一次typed终态，transport/归属检查不退休。

**INVALIDATE：** 对一个或两个完整descriptor分别在现owner数组核`valid/active`、完整A归属、NumericIdentity、L13M以及完整descriptor相等，使用/扩展现`find_exact`；显式补model/A比较，不能认为当前find_exact已比较model。target/old Ref及epoch、role、offset/span/geometry等以原128B descriptor规范整体比较。owner必须来自实际成功CLAIM；允许没有任何BEGIN，也允许错误END后仍active/invalid的owner。两descriptor原配对/原子规则保留，不能只匹配一个就部分放行。没有scope/BEGIN不代表没有owner。

最终仍走hub原scope互斥、physical observation、lease/source guard和`finish_owner_event`规则。归属匹配仅意味着可尝试旧cleanup，不代表physical_safe、drained或允许清source。受guard保护的source直到真实读债/完成消费满足原释放条件后才可INVALIDATE；不能靠A匹配越过。精确不匹配、旧epoch/不同model/新A及已inactive对象不获得清理许可；重复INVALIDATE沿原拒绝语义处理，不重新激活、重复退休或重开请求。

当前撤销专用业务白名单为END/INVALIDATE，不增加新CLAIM/PUBLISH/BEGIN/producer准入。源lease的既有release握手应保持独立旧归属路径；不把它伪装成LPV RELEASE，亦不能关掉它而等待lease自己消失。正常非撤销动作保持原协议。

## 5. hub取消与物理所有权必须一起处理

当前hub约第931–943行的cancel循环，在无scope/无hub response时会批量改owner_active/published/invalid。仅去掉transport_abort仍不够：CLAIM-only或已END的owner可能在INVALIDATE精确查找前已被清掉。

managed模式将撤销记录与这种自动破坏性清理分开。保存旧CLAIM、owner/model/descriptor、active_begin、source保护/lease及pending END所需事实，直至各原权威的真实cleanup安全出口；通过持久撤销门禁止它们再给新工作授权。owner_active/published等不得在transport旧返回尚在时靠cancel批量清除来制造domain_drained。正常具体INVALIDATE/lease release/END按原规则更新实际状态，历史owner_max_epoch/typed/task/LPV下界不清。不是简单把hub cancel长期绑0：所有相关新业务和source准入仍须观察同一持久撤销。

真实物理债务来自原monitor/adapter/读peer及其冻结配置。当前base/session输入变更只禁止新启动，原已接受R/B/返回在旧owner能识别的范围内继续收束；若实际BO已重映射、原物理归属不可核实，则保留隔离，不能用新base的空闲状态签旧drained。cleanup核定不代签全部13BO/alias/旁路覆盖。

`physical_safe`、`old_channels_drained`应由独立实际债务/传输/归属事实形成，不得依赖先清A、先CLOSED或先把所有撤销标志归零。保留锁/撤销状态本身不是尚未排空的物理债务。反过来，CLOSED前必须确认所有应清旧owner/lease/半帧/返回均已按合同收束，不能靠transport空闲漏掉CLAIM-only对象。

## 6. 关闭、重新准入及验证出口

每个LPV返回第8次实际消费只结束该帧，不释放A、不清持久撤销、不切换请求。A沿原CLOSE/CLOSED或合法无HOLD的admission_closed(A)收束；实际关闭消费后等待新候选真实准入。新A只有在已核旧关闭和通道安全条件之后安装，旧route/旧CLOSED/旧返回不能激活它。K的尝试结束与A的请求结束继续分开，持续各权威下界保持。

原资源帽内先做受影响有限managed闭包，至少覆盖：

1. 首拍/部分16拍后持续cancel、base/归属撤销，旧帧收齐；普通未提交帧负返回、合法END按原末B/fence收束，全部8次真实读及尾2/尾1各反压，scope结束/domain_drained变化不丢返回。
2. 真实CLAIM成功、无BEGIN，取消时CLAIM返回仍在或尚未发INVALIDATE；返回正常消费后精确INVALIDATE可收齐并完成，零新task退休。错误END后INVALIDATE也能推进，旧task仅原hub终态一次。
3. 错A/session/accepted-request、identity/model、descriptor/Ref/epoch、origin/Context/geometry、旧序号及重复cleanup，不修改正确旧owner/typed，不把未知物理状态报drained；正确后继cleanup不被已知可拒绝候选永久占住。
4. HOLD/派发切换在半帧、尾部返回时保持原route；未撤销DRAIN仍完成合法旧action，持续撤销禁新业务；已接受source R/B/lease释放仍进展。单STATE0证据只签该域。
5. 默认旧诊断按未改身份保留；受影响回归覆盖真实关闭/下一准入时再签rearm，不把这些复位分隔有限case拼成完整恢复。无关HLS/full不重跑。

这是接口决定，尚无新实现PASS。F19/F20完整修复交付已收到，另行集中审核，不在此接口决定中关闭。C009/C013部分实施、C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。原单owner/单重工具/全部帽/G2338.224019s保持，5172s不重启，无新agent/HLS/OOC/P&R/上板/预算；工程按原授权继续，无逐项审批。
