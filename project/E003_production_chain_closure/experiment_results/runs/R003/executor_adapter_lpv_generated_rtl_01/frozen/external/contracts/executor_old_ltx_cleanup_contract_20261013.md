# 撤销后旧cleanup首LTX的归属与负完成合同

消息：executor-first-transport-old-ltx-cleanup-answer-20261013；回复 executor-first-transport-old-ltx-cleanup-question-20261013。
决定：D-M003-EXECUTOR-OLD-LTX-CLEANUP-01。M003/SM003/E003/R003；补充D-M003-EXECUTOR-MANAGED-LPV-OWNER-01及分区合同§7.2–7.3。A002唯一整合，普通实现/受影响验证继续，不增加预算或逐项审批。

**采用旧A/route下有界候选收集；真实executor持久FSM提供完整待发事务，唯一hub最终核定END/INVALIDATE。普通已拥有但未外发事务由adapter本地拒绝路径产生原格式LTC1。** 收集旧帧、准许cleanup尝试和实际远端终态是三个不同事实，不能由同一个cleanup bool代签。该缺口属于首次运行必需的旧任务收束，不要求先实现完整CLOSED/rearm。

## 1. 现有owner及最小事实

完整事实来源分工如下：

| 事实 | 唯一来源与用途 |
| --- | --- |
| 请求旧A、已有K/B、原派发route与持久撤销 | 唯一request ingress/shell保存的不可变记录；live base/session变化只撤销启动，不改写旧A。无HOLD时用真实A，不伪造K/S/H。 |
| 原action与完整待发LTX | 实际executor actor内持续的FullRuntime、Port/Machine；优先复用Machine::transaction/request_packet、action、scope、task/logical_done及after_transaction。它们由真实send/状态迁移形成，不能由sidecar或TB反推。 |
| 旧BEGIN/CLAIM/任务清理意图 | executor原lifecycle_action/generated_store及实际已核完成；BEGIN成功、producer已实际完成或确实未派发的本地拒绝，决定可构造的真实END。CLAIM-only清理不依赖存在BEGIN。 |
| 物理owner/scope、许可与终态 | 唯一hub/monitor原A归属、owner/active_begin、lease、实际R/B/observed及物理fence。executor意图不代签hub已接受，sidecar无发布/退休权威。 |

最小内部pending记录是：稳定完整A引用及适用的K关联、实际旧route、原action完整键（identity/ordinal/PC/kind等）、完整规范LTX请求或指向它的不可变稳定对象引用、候选占用/已交adapter/对外已呈现与消费阶段。请求自身携带对应协议seq/generation、origin/Context/model/descriptor/geometry等，不能用类别/序号或短hash替代完整请求。引用不是跨分区裸C指针；必须在硬件边界可核定且旧帧/返回仍引用时不复用，必要时通过有界内部record握手传完整字段。

记录来自FSM真实待发状态，在首LTX pop之前或同次原子接纳时锁定。不能要求先pop后才能知道是否可pop；也不要求先收到hub cleanup许可才允许收集候选。Machine已将部分/全部24拍写入FIFO时仍保留原完整transaction，可从该旧持有状态供给记录；不得因TX_WRITE转TX_READ而丢失归属。若旧route仍属于前序，则由那个真实前序FSM提供等价的已接受工作/pending记录，不能拿executor的新记录替它授权。尚未形成/呈现任何真实待发LTX的取消分支由FSM本地处理，不凭空合成一笔LTC消费。

## 2. 单候选传输与真实首拍

撤销后的收集入口只对**已存在旧action的真实待发记录及旧A/route**开放。允许它收齐最多一份24拍LTX并作完整frame/保留位/字段/归属比较；这是为处理已有待发事务及必要cleanup，不授予普通新业务、下一action或新请求准入。未知A/route、无真实pending或无法匹配的帧隔离，不能贴上当前A作可信拒绝。

实现优先在唯一事务准入边界使用上述完整pending引用；若物理连接需要完整LTX collector，则它只是一笔候选缓存。collector的首pop、adapter/F10的首pop是不同握手，不能复用同一无键脉冲混算。F10实际24拍adapter接收计数及16拍LTC真实caller消费规则保持；候选/sidecar归属从各自真实首拍占用开始，直到同笔真实完成消费，不因LPV第16拍写、LPA第8拍读或adapter暂时idle提前释放。

sidecar的持久txn_revoked/owner_revoked/cancel继续禁止普通业务，但不能无条件封死匹配旧pending的候选入口。不清撤销位来放行cleanup，不因旧txn_done而重开普通入口；协议损坏、未知旧owner或未知物理安全也不能被cleanup模式绕过。完整收集后的原帧/返回在任何反压、持续撤销和live字段恢复/变化下保持旧绑定。

正常HOLD DRAIN且未撤销时，原已接受action的合法后续事务仍按原合同完成；不能把该状态误套成“仅END/INVALIDATE”。新action仍关闭。

## 3. 撤销下精确候选白名单

能够进入实际adapter→managed portal→唯一hub尝试旧业务修改的候选，只限：

- `Kind::PROVENANCE_TRANSACTION + CANCEL_CLEANUP + Action::END`：与原已拥有scope的完整BEGIN/origin/Context、全部descriptor/model/expected/geometry匹配，状态/issued/首错来自原真实producer完成，或已证明该producer完全未外发的真实本地拒绝路径。物理末B/fence可尚未排空，允许END进入并等待；不能为接收END先要求整个adapter/F10空闲。最终只有原hub核定的终态经完整绑定LTC消费后，由executor原路径唯一退休。
- `Kind::PROVENANCE_TRANSACTION + CANCEL_CLEANUP + Action::INVALIDATE`：同旧action保存的完整目标owner/Ref/model/descriptor，覆盖CLAIM成功但无BEGIN，以及原错误END后仍需清理的owner。caller提供候选而非“必然CLAIM成功”的声明；hub仍以真实成功CLAIM建立的A/owner和现find_exact/physical/lease规则最终判断，双descriptor按原原子规则。尚有不明旧scope/lease时不能通过本候选清空它们。

CANCEL_CLEANUP只是原协议字段，不是许可。当前managed白名单**不含LPV RELEASE、CLAIM、BEGIN、PUBLISH，也不含新的COMPUTE/PRODUCER**。原source lease释放继续独立旧归属路径，不伪装成LPV RELEASE。不得通过重写原LTX flags/kind/seq使普通帧貌似cleanup。

注意现adapter::cleanup_allowed还包含RELEASE；不能让该legacy范围扩大managed权限。managed全帧接纳必须先收窄到本节精确类型/真实记录，保留旧默认诊断语义。对于真实已持有但不能放行的合法帧，按下一节明确拒绝；不靠full_n永久为0等待它自行消失。

## 4. 普通未外发LTX的负完成

**唯一事务负完成来源采用实际adapter的pre-dispatch本地拒绝分支，复用reject_internal → transaction::make_local_reject/encode及原16拍LTC1。** wrapper/sidecar负责事实和路由，不另写一个返回成功或退休的完成权威。必要的managed准入判定在这一adapter边界落实；若确需改生成adapter，纳入受影响新冻结/验证，不能把旧生成物声明为已有新行为。现NORM普通flags0事务若能直接走旧adapter完整拒绝路径则可复用，不为无关默认路径重生成。

本地拒绝必须有可核的同一pending原帧，且该事务没有任何对外呈现/接受的beat、没有可疑待发VALID或远端副作用。收集完整合法LTX并精确绑定后，用实际撤销/拒绝Check产生非OK响应，保留原字段和首错语义。原codec要求：
`FRAME_COMPLETE | LOCAL_REJECT`，**不置BINDING_OK或任何REMOTE_DRAINED/SCOPE_ACTIVE/TERMINAL/PUBLISHED**；本地绑定由decode(expected)/local_reject_binding_ok核定，不能把BINDING_OK当作本地拒绝可信性的替代。该完成仅证明这笔事务未外发，不证明旧BEGIN、其他任务、lease或请求已安全排空。

LTC必须经过唯一实际返回通道/F10的16次caller读取；不得在wrapper伪造末拍消费、在FSM置一个“已收负完成”bool，或与adapter可能输出的另一响应竞态双发。若用collector择路，负完成和正常adapter返回仍是同一pending的互斥出口。坏帧/错归属不能用部分字段制造可信LOCAL_REJECT。

现adapter只在首LTX pop保存cancel_at_accept。managed必须观察同A持久撤销，不能只接会恢复的live cancel；撤销发生于首pop之后、外部首呈现之前，也要有真实的拒绝判定。若已对外呈现或接受任何部分帧，继续原旧帧/真实返回，不能改成本地“未发出”。仅统计accepted_beats=0不够证明从未呈现；VALID反压中的旧数据不能撤回。对于下游已收到的普通旧候选，按原managed transport/服务绑定负返回收束，不伪造adapter LOCAL_REJECT或未知drained。

当前FSM的PRODUCER_RESULT有真实accept_layernorm_local_reject分支，可在完整本地拒绝后形成原scope的错误END，再由hub真实终态唯一退休；绝不在本地拒绝时直接退休。OWNER_RESULT/BEGIN_RESULT/END_RESULT等仍要求remote_bound，不能全局把LOCAL_REJECT当remote_terminal。若补普通CLAIM/BEGIN等“从未外发”的本地状态处理，必须依据真实未外发事实只收束相应本地预约/租用，保持所有耗号，不清其他旧scope/物理债务；未实现的错误结果路径可按首请求合同隔离保留，不能宣称请求已闭合。关键旧END/INVALIDATE通路不能借此后置。

## 5. 有限验收出口与当前进度

本次受影响有限接线集中覆盖：真实BEGIN完整LTC消费后持续撤销、END尚未首LTX pop仍可从真实FSM记录收齐并进入hub，末B/producer物理fence延迟下旧返回16拍消费且typed仅一次；真实CLAIM成功无BEGIN后INVALIDATE首拍可进入，零虚构任务退休；已有producer待发但未外发的真实adapter负完成→原错误END；错A/route/完整事务/旧记录、伪cleanup flag及RELEASE不得获得新业务许可；取消在collector/adapter首拍和外部首呈现边界、半帧、LPA/LTC尾2/尾1反压时无丢帧/双完成/下界回退。安全已知、可按原规则拒绝的候选完成后不得永久占槽；未知归属仍隔离。

producer物理fence和整个F10/旧通道排空继续分开，避免END等待自身返回。上述验证可先签实际adapter/sidecar/portal片段；若executor pending或上游producer还是受控来源，明确该边界，不能签同runtime C整链。普通实施/必要内部字段冻结由A002整合，无需为每个collector/record字段再请求批准；Host/LTX/LTC/LPV wire不变，无第二hub/allocator/退休权威。

本消息中的host/有限admission与sidecar PASS按工程所报范围记录，未在此接口核定中集中重审；owned_program动态FAIL和source_guard初版xsim异常均保留，program_04的生成/端口事实不扩大为行为PASS。executor五宽口区分实验、program定位、source guard和C正常准备独立继续。

原单重工具、分类资源与120s真实进展保护、CPU0–3/nice19/idle I/O/MemAvailable门及预算不变；G仅OOC余额，5172s组合不重启。D/Q、完整CLOSED/rearm后置，C/D周期NOT_RUN、C009/C013部分实施、M003/M004未完成。本次仅接口决定/静态核定，未运行DUT。

依据：[managed LPV合同](executor_managed_lpv_owner_contract_20261013.md)、[分区合同](production_hls_partition_contract_20261012.md)、[首请求顺序](executor_minimum_hardware_chain_reply_20261013.md)；[静态证据](executor_old_ltx_cleanup_decision_20261013/verification.json)保存当前source与决定身份。

