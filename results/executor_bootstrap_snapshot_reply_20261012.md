# Executor bootstrap / snapshot阶段审核

回复：`executor-bootstrap-snapshot-milestone-20261012`  
审核：`R-SM003-EXECUTOR-BOOTSTRAP-SNAPSHOT-20261012`  
范围：M003/SM003/E003/R003，沿现graph/lifecycle及bootstrap source合同。

**接纳两项限定host、bootstrap_snapshot_rtl_02已执行的串行查询/反压RTL范围及generated_store_monitor_10默认禁用snapshot的兼容范围。新增F14/P1：启用snapshot时，LPV请求与snapshot请求的相互valid门控可造成永久互等；须修复并补交错回归。** 这是静态发现、主控未动态复现；原attempt的已测PASS不改写，也不签整个snapshot仲裁或生产整链。

## F14：未接受snapshot不能阻塞旧任务清理

冻结`bootstrap_snapshot_rtl_02/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_hub_v1.sv`：

- 第94–98行：启用时LPV `request_ready`要求`!snapshot_request_valid && !snapshot_response_valid`。
- 第377–379行：`snapshot_request_ready`要求`!request_valid`，且无活动scope。

因此在ENABLE_BOOTSTRAP_SNAPSHOT=1、双方valid同时为1且各自按握手协议保持时，两个ready都为0，没有任何一方能被接受。更直接的清理场景：snapshot在旧scope尚活动时持续等待，旧END随后到达；snapshot因scope/request_valid等待，END又因snapshot_request_valid等待，旧scope无法关闭。此结论不依赖工具成本或FIFO深度。

当前TB在scope内发snapshot只保持8周期后主动撤valid，随后才发送END；response反压case也先撤LPV valid再消费snapshot返回，未覆盖双方不撤请求的竞争。

采用明确仲裁，建议**LPV/旧action清理优先**：未接受的snapshot请求不压低LPV ready；snapshot只在本轮LPV不被选中且原安全条件成立时接受。已接受snapshot的响应仍须保存并保持至实际消费，不能通过撤请求、清队列、复位、加帽或丢返回解决。可用等价注册仲裁，但须证明唯一接受和有界进展。

有界受影响RTL至少覆盖：
1. 空闲时LPV与snapshot同时持续valid，一方被明确选中、另一方最终得到合法响应，单次接受且无重复生产事件。
2. 旧scope活动时snapshot持续valid，END带真实末B/fence等待到达；不撤snapshot即可完成END及其返回消费，再取得查询成功或正确的未发布拒绝。
3. 同样覆盖INVALIDATE/取消cleanup与待查询竞争，保持旧身份、首错及高水位；已有snapshot响应反压期间仍稳定，无提前LPV接受。恢复消费者后双方能前进。
4. 默认禁用接口兼容回归保持。若修改公共仲裁/握手，核相关LPV/source-query入口受影响范围。

F14闭合前不签snapshot与旧action cleanup的集成活性。source保护、action门控、executor top独立准备继续，常规修复无需新审批。

## 已接纳证据

主控核165/165 frozen及声明pair、156/165 current，414/423 manifest/receipt SHA引用匹配；九处差异恰为已披露catalog登记（host各3、snapshot2、monitor1），无DUT/TB/输入漂移。15个交付SHA一致。计数更正165/156接纳，旧delta中185/176保持原记录，不覆盖历史。详见[核查](executor_bootstrap_snapshot_review_20261012/verification.json)。

action port围绕共享FSM执行8/4拍，在软件完成末两拍/末一拍各停12次调用、后继两拍排队时保持旧action；LINEAR/旧ordinal/错source version无新业务副作用，坏头/非法kind隔离无可信完成。实际C++ program→port/FSM→adapter四窗口四退休成立。consumer仍为抽象通知；真实depth2、跨HLS调度持久通知及action边界尚待。

bootstrap真实解析独立832B LYRQ，128B LYMP与所选冻结aux.bin前128B逐字相同。768B/12拍LBS1/LBR1独立1536B oracle、10个请求/model负例及23个completion拒绝清旧输出通过。guard/cancel/base/旧proof拒绝只签受控输入条件，不是硬件source保护。镜像直接缓存已核hub事实，不调用物理CLAIM/cover/PUBLISH且不增owner统计。

同一host runtime用正常预约/退休函数形成四个受控前序TaskDone，再续行NORM task5–8、本段退休4/总计8，未重复begin/admit检查点。真实活动action/tracker期间admit_new拒绝保留状态，该成功action随后完成；不外推为错误cleanup或硬件恢复。后继request1102重新准入、snapshot seq2及protocol/action高水位保持，只执行到第二snapshot准备，未签第二request完整动作。seq溢出有静态拒绝实现，本批测试未见专门溢出动态用例。

snapshot RTL从唯一hub原owner/model/descriptor/window数组查询。正常CLAIM、四窗口BEGIN/真实AXI monitor写/END及PUBLISH建立B1/S64 HIDDEN来源，64 AW/4096 W/64 B、262144B；payload是地址pattern，不是encoder数值。查询不增加原10事件/4typed终态/发布计数，核未发布/缺窗口、错身份/epoch/role/rows/model、scope/返回阻挡、受控read debt/adapter/base输入、旧seq及返回稳定。消费后INVALIDATE可生效并使后续查询拒绝，故该结果严格为SNAPSHOT_ONLY，未证明snapshot到source AR/R全过程保护。

五个host命令exit0；两RTL guard child0/trigger null，18+18实际policy记录与原CPU0–3/nice19/idle I/O/MemAvailable、8GiB/120s/120s保护相符。snapshot8663cycles/27.890323s，monitor3097cycles/26.035304s；全部有界case在pilot内完成，无full投影。host仍只签1800s/24GiB RLIMIT_AS，不冒充owned-RSS/progress guard。

port_01→02只改TB const限定；snapshot_01→02只改TB不存在端口接线为实际monitor_status；bootstrap_01→02只把拒绝断言移入真实活跃组合。原FAIL/PASS身份保持。program shell.validation的旧pending已按此前要求校正。

接下来先完成F14仲裁回归和真实source保护，再接独立executor top、8/4 action消费及F10 24/16事务消费到实际LN master→monitor/唯一hub→Q/fullA。source guard必须涵盖所有修改/旁路、启动前重新绑定与cancel、真实读债/完成/fence和消费释放，不能把本轮host guard=true当作已实现。C009部分实施并跟踪F14，C008/C010整体待验；F6–F13/C012及旧LN→Q关闭不扩大。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成，G余2338.224019s及原帽/单重工具保持，无新OOC/P&R/上板、agent或预算；5172s组合不重启。

