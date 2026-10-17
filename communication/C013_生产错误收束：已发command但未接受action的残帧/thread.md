

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C013 · 生产错误收束：已发command但未接受action的残帧

状态：**已答复待实施**。阶段D首窗Q保留活动请求/锁及真实预约，不以测量代签CLOSED/rearm；关闭与新准入实现义务保留，首次测量优先。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### executor-revoke-unaccepted-action-question-20261013

2026-10-12T21:56:49.985955+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# 生产错误收束：已发command但未接受action的残帧

范围M003/SM003/E003/R003，沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01，F17 host范围已关闭。真实wrapper与绑定关闭/rearm实施继续，无需逐项审批。

具体缺口：当前actor发完LGP1进入RUN_ACTION后，F17锁存撤销并在port READ_ACTION/beat0禁止读取新LAX1首拍。这是已核的正确启动门。但program可能已经将完整8拍LAX1置入FIFO、等待LAC1；结果安全消费和rearm必须实际收束这个残帧，不能清FIFO/reset/谎称没有产生action。原45例故意留下8拍，其PASS不签请求错误收束。

提出受限取消收束路径：在同K撤销已确认、command确实已送到program且唯一旧action尚未正常准入时，另走显式cancel-drain consumer，收齐并完整解码原LAX1，核当前identity/PC/source/目标与原program command归属；只产生匹配安全错误LOCAL_REJECT LAC1（retired_tasks/first/last=0），不调用lifecycle start/CLAIM/producer、无task/Ref/LPV预约，不清旧物理债务。program正常消费后形成错误LGR1，Host真实消费且物理/各半帧排空后，再绑定CLOSE/rearm。若program尚未产生action且返回本地LGR1，则按真实未启动分支，不虚构LAC1消费。部分已读LAX1及已有active任务沿旧port/FSM清理，不走此新分支。

需要主控明确两点：该取消drain是否作为合法原action终态路径接纳；可信取消帧的ordinal是否仅推进接收校验下界（保持program分配权），而不计业务准入或退休。工程建议记录可信消耗ordinal，以隔离随后同ordinal重放；不更改program高水位分配或typed统计。

本问题不影响已提交但尚未外发LGP1时的本地错误结果、现有活动任务cleanup或独立wrapper/关闭/rearm实现。等待该窄边界答复时继续独立工作，不扩大F17关闭或完整请求PASS，无新预算/agent/HLS/OOC/P&R/上板。


[原始消息收据](../../.research-agent/communications/executor-revoke-unaccepted-action-question-20261013.json)
### executor-revoke-unaccepted-action-answer-20261013

2026-10-12T21:59:30.110457+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：executor-revoke-unaccepted-action-question-20261013

# 未准入action取消收束补充合同

决定：**D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01**  
回复：`executor-revoke-unaccepted-action-question-20261013`；M003/SM003/E003/R003。补充D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01，A002仍为唯一实现owner，原预算与授权不变。

**接纳显式cancel-drain作为已发旧action的一条合法错误终态路径；可信完整消费的ordinal推进接收防重放下界，不构成业务启动、typed预约或退休，也不改变program的分配权。** 这是接口决定，尚未实现验收；F17的原45例仅证明阻止新启动，仍不代签请求收束。

## 入口与归属

只允许在同一已准入请求/K持续撤销、原LGP1确实属于该program事务、唯一旧action尚未被正常port接收首拍且无该action活动tracker/预约时进入独立取消consumer。正常READ_ACTION/beat0的撤销门继续关闭。两个consumer对同一FIFO必须互斥且有明确owner，不可同拍双读；首拍已由普通port接收则部分帧/已有任务沿原port/FSM清理，新分支不得接管或重建tracker。

LGP1写入FIFO不等于program已经完整接收。wrapper须区分完整command已消费/部分command/尚未开始；所有实际已发半帧仍按原归属完成消费，不能因取消在另一端禁止首拍而形成新的互等。本决定只给旧action收束权，不授权新command或新action启动。

cancel-drain可在旧program输出尚未齐8拍时等待并逐拍收集，使用固定有界缓冲；从首拍到全帧保持旧K/command和撤销记录。必须按现完整LAX1 codec核版本/长度/保留位/字段合法性，并核原command及program当前唯一pending的全部预期语义：identity、PC、kind/op/stage/layer、source slot/version/Ref/epoch/geometry、目标slot/version/Buffer域、gamma/weight及ordinal。身份依据为锁存的旧请求，不能用已变化的新base/session字段替换旧键。

ordinal须来自program已分配pending或可证明完整连续的唯一program输出历史；只见一个大于下界的任意编号不等于归属正确。若现有接口不能核定这一点，增加有界内部pending/归属握手，冻结字段及oracle；不能用无tag布尔、短hash或从错帧部分解码值合成可信完成。

## 完成与编号

全帧语法、语义、归属及新鲜性都通过后，原子记录“本K的这个ordinal已可信消费，待错误完成”，并保留至真实完成消费/关闭。可复用语义明确的接收high-water或独立记录；普通接收和取消接收共享同一防重放判定，重试/rearm不回退。program独占原action分配high-water，取消consumer不分配新号、不补齐假历史、不改变task/Ref/LPV/producer/compute及业务统计。坏帧/错键不提高任何可信下界；重复旧ordinal不再次返回安全完成。已消费但完成被反压时，不重新接收同帧。

只产生一份原action键的合法非OK LAC1：FRAME_COMPLETE、BINDING_OK、SAFE_TERMINAL、REMOTE_DRAINED、LOCAL_REJECT；retired_tasks/first_task_id/last_task_id均0，无TYPED_RETIRED、无SLOT_UPDATE_VALID，slot_delta保持codec要求的空值。错误沿现有cancel/首错优先规则，不用OK或虚构成功代替。不得调用lifecycle start、CLAIM、producer或任何TaskReservation/retire操作。SAFE/REMOTE仅陈述该action从未产生远端工作，不能据此清除其他旧物理债务、释放来源锁或直接rearm。

4拍LAC1由同一真实program consumer消费并校验后形成原action归属的错误LGR1，PC/slot不推进，ordinal保留；这是action曾存在的错误分支，不能改写成“未产生action”的program LOCAL_REJECT（其现有wire语义要求ordinal0）。actor结果绑定需支持该零退休错误action记录，不能依赖新调用lifecycle start伪造machine completion。

若program实际上尚未分配/发出action并走合法本地LGR1，使用真实未启动分支，不伪造LAC1或ordinal消费。此分支与cancel-drain互斥，必须以program的真实绑定状态/结果及排空事实确认；不能按短暂FIFO empty、结果先到或超时推导没有残帧。无法核定/畸形帧继续隔离，明确不支持自动恢复。

## 关闭与有界验证

LAC1写完不等于消费，LGR1写完也不等于Host消费。真实末拍及原归属通知必须保存到对应等待状态，反压期间数据稳定。旧action/command/result/control半帧、F10、读写/lease/fence等全部真实排空，Host结果真实消费且绑定CLOSE/安全条件满足后，才允许rearm。撤销输入恢复和旧GRANT不能重开新派发；来源保护及已导入baseline/所有高水位保持。

受影响验证至少覆盖：真实program已发完整action后撤销；depth2中只发出部分action而普通port未读首拍；首拍读与撤销同拍的唯一consumer选择；8/4拍末2/末1反压及结果延迟消费；语法合法错ordinal/源/目标/PC、坏保留位和重放保持隔离且无可信完成；正常port部分帧及活动task继续旧清理；program真实未产生action分支；旧结果未消费不得CLOSE/rearm；同持续runtime下一真实请求保持全部下界并能正常运行。核实际stream/握手计数、零新task/Ref/LPV预约、零退休、零producer/AR/AW，不能靠清FIFO/reset/撤valid达成。

主控静态核对了现graph_program_hls的WRITE_ACTION→READ_COMPLETION→错误LGR1路径、sequencer的ordinal分配与completion绑定，以及port READ_ACTION/beat0撤销门；没有运行DUT。先完成有限host/真实consumer证据再按原顺序集成，无新增逐项审批。C009部分实施，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。G余2338.224019s、原单重工具/资源帽保持，无新agent/OOC/P&R/上板/预算，5172s组合不重启。


[原始消息收据](../../.research-agent/communications/executor-revoke-unaccepted-action-answer-20261013.json)

## 相关决定和审核

- [executor_revoke_unaccepted_action_contract_20261013](../../results/executor_revoke_unaccepted_action_contract_20261013.md)
- [executor_revoke_unaccepted_action_reply_20261013](../../results/executor_revoke_unaccepted_action_reply_20261013.md)

### 状态确认 2026-10-12T22:03:18.760673+00:00

项目主控与架构评判：D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01已直接送达；允许可信旧action取消drain及接收下界，真实消费/关闭/rearm待实现验证 → 已答复待实施

[executor_revoke_unaccepted_action_contract_20261013.md](../../results/executor_revoke_unaccepted_action_contract_20261013.md)

### 状态确认 2026-10-12T22:23:03.859500+00:00

项目主控与架构评判：实际program/actor取消consumer有限host接纳；真实LAP1/控制consumer、物理CLOSE与无复位rearm待实现，合同整体不关闭 → 已答复待实施

[executor_cancel_f18_reply_20261013.md](../../results/executor_cancel_f18_reply_20261013.md)

### 状态确认 2026-10-12T22:32:12.446021+00:00

项目主控与架构评判：取消consumer有限host已接纳；补充关闭/未启动/Host结果和带旧新归属准入合同已送达，完整CLOSE/rearm待验 → 已答复待实施

[executor_close_rearm_contract_20261013.md](../../results/executor_close_rearm_contract_20261013.md)

### 状态确认 2026-10-12T23:00:31.178624+00:00

项目主控与架构评判：R-SM003-EXECUTOR-MANAGED-QUERY-20261013已限定接纳五例实际wrapper查询收束与三捕获host拒绝导入；活动LPV半帧/旧返回清理、CLOSE/CLOSED及真实Host消费和带归属rearm仍待，完整source/整链未关闭。401冻结配对、30交付SHA、12guard/194policy已核，资源短段观测缺口保留。原授权与预算不变。 → 已答复待实施

[executor_managed_query_reply_20261013.md](../../results/executor_managed_query_reply_20261013.md)

### 状态确认 2026-10-12T23:31:39.399012+00:00

项目主控与架构评判：R-SM003-EXECUTOR-REQUEST-CLOSE-20261013接纳所测端点/主机准备及真实捕获证据；F19末拍legacy bool绕过完整Host记录、F20同拍control抑制终态封存为新静态待修，工程补受影响回归。295冻结配对/29SHA、10guard/109policy已核；真实wrapper关闭/LPV旧帧/rearm及完整生产链未关闭。原授权预算不变。 → 已答复待实施

[executor_request_close_reply_20261013.md](../../results/executor_request_close_reply_20261013.md)

### 状态确认 2026-10-13T00:00:35.192940+00:00

项目主控与架构评判：R-SM003-EXECUTOR-CLOSE-F19-F20-20261013关闭host_06六边界F19与shell_04有限22例F20；原兼容保持、295冻结组一致，live后续actor变更不代签。D-M003-EXECUTOR-MANAGED-LPV-OWNER-01已送：唯一A持久16/8归属、唯一hub精确cleanup，managed旧帧/返回/owner保留。真实wrapper、活动LPV、no-LGP/committed ABORT、绑定关闭/新准入持续下界及生产整链仍待，原帽/G2338.224019s不变。 → 已答复待实施

[executor_close_f19_f20_reply_20261013.md](../../results/executor_close_f19_f20_reply_20261013.md)

### 状态确认 2026-10-13T00:36:04.851366+00:00

项目主控与架构评判：R-SM003-EXECUTOR-MANAGED-LPV-20261013接纳完整A主机捕获和七有限RTL旧帧清理；355冻结/33交付匹配，生产wrapper仍default0/tie0，同硬件runtime/关闭/rearm/完整链待验。按用户进度关切已发最小真实硬件链优先级及估时请求，必需安全门保持，区分首次运行依赖与可后补恢复；原帽/G2338.224019s不变。 → 已答复待实施

[executor_managed_lpv_reply_20261013.md](../../results/executor_managed_lpv_reply_20261013.md)

### 状态确认 2026-10-13T00:47:09.069484+00:00

项目主控与架构评判：D-M003-FIRST-HARDWARE-BASELINE-01接受A入口/B生成/C真实LN周期/D实际Q基线顺序，完整错误结果矩阵/CLOSED/rearm后置；必需准入/授权/实际consumer/source保护与旧帧债务保持。粗估executor3–7、LN累计5–11、含Q7–15工程小时，非日期/成功保证。G余2338.224019s仅G OOC余额，全部原帽不变。 → 已答复待实施

[executor_minimum_hardware_chain_reply_20261013.md](../../results/executor_minimum_hardware_chain_reply_20261013.md)

### 状态确认 2026-10-13T01:43:29.024586+00:00

项目主控与架构评判：阶段D首窗Q保留活动请求/锁及真实预约，不以测量代签CLOSED/rearm；关闭与新准入实现义务保留，首次测量优先。 → 已答复待实施

[executor_first_baseline_program_q_reply_20261013.md](../../results/executor_first_baseline_program_q_reply_20261013.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
