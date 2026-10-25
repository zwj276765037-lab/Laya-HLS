

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# C008 · 普通 QUANT/MATRIX 源 tensor 的 producer Context 定义请求

状态：**待验证**。F5由generated_source_lease_04的精确标准窗口行数及受影响回归在当前单全宽范围关闭；普通source完整多role/row-space/QKV与production generated来源仍待验证，不能以两项受控query grant切换代签。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### ordinary-linear-provenance-question-20261012

2026-10-11T16:17:25.975541+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# 普通 QUANT/MATRIX 源 tensor 的 producer Context 定义请求

工程已完成当前 G/Down Controller 门户入口的同 runtime 有界集成：B1/S64 的四个真实 GEGLU typed producer、一次 LOAD、四个 QUANT 父任务与每父四个 MATRIX view 均由现有 `reserve_g_down` 提前预约，并在 `portal_controller_04` 中逐拍核对 25 条门户命令、13 个 typed TaskDone 和最终 owner/lease 状态。该路径的 P 是每个 G 窗口自己的真实 GEGLU Context，因此没有歧义。

继续接普通 Linear 时出现合同层缺口。`full_forward_controller.cpp::linear_impl` 的 QUANT 源可能是由多个 typed task 共同完成并在循环后才发布的完整 tensor，例如 Attention 输出由 16 heads × B × rows 窗口共同覆盖；当前没有一条显式 typed task 表示“该完整 tensor 已发布”。v2 合同禁止用 `task_id+1`/`task_id-1`猜身份，也不能静默取循环中最后一条 task。当前实现因此保留 `dispatch_binding.valid=false`，普通 Q/L 仍走原 direct 路径，没有发送带伪 P 的门户命令。

请主控明确普通 Q/L 的 P 应采用哪一种真实、稳定记录，并补入权威合同字段/生命周期：

1. 新增一个显式 tensor publication typed Context/TaskDone，作为多 producer 的聚合完成记录；
2. 扩展门户绑定为有界 producer 集合/ledger，而不是单个 P；
3. 指定现有某条真实 typed completion 可代表完整 tensor，并给出选择规则及为什么不会把局部完成误当完整发布。

还请覆盖 QKV 双 owner、Attention 16-head聚合、残差/向量多窗口、跨 batch 和失败后恢复。工程在答复前可继续独立的 hub/base-binding/构建工作，但不会让普通 Q/L 门户以猜测 P 上线。

证据：`project/E003_production_chain_closure/experiment_results/runs/R003/portal_controller_04/receipt.json`；当前实现位置：`project/E002_Laya_HLS/experiment/hls/control/full_forward_controller.cpp` 的 `linear_impl`。


[原始消息收据](../../.research-agent/communications/ordinary-linear-provenance-question-20261012.json)

相关文件：[receipt.json](../../project/E003_production_chain_closure/experiment_results/runs/R003/portal_controller_04/receipt.json) · [full_forward_controller.cpp](../../project/E002_Laya_HLS/experiment/hls/control/full_forward_controller.cpp)
### ordinary-linear-provenance-answer-20261012

2026-10-11T16:27:01.248970+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：ordinary-linear-provenance-question-20261012

# 普通Q/L producer Context：主控正式答复

回复`ordinary-linear-provenance-question-20261012`。决定 **D-M003-ORDINARY-SOURCE-PROVENANCE-01**，全文 `results/ordinary_linear_provenance_contract_20261012.md`；v2权威合同已补引用并明确原§2.2。

**采用第3项的逐窗口形式：P是使这个source窗口全部必需输出覆盖首次完整的真实成功typed task原Context。P本身不代表整tensor发布。** 每窗口保留P、完整贡献覆盖/真实退休证明，另由原full_publish/commit检查全部batch/window后发布整个owner。不能用全tensor循环最后task代表所有窗口，也不新增publication typed op/TaskDone、producer集合wire或第五service；任务计数不因本决定增加。

具体规则：

- Attention：每batch/rows16窗口有独立16-head覆盖。使此窗口16head全部实际成功退休的AV Context成为P；当前顺序通常是head15，但必须核前15head实际覆盖，不能仅看head号。B1/S64应记录4个不同窗口的真实AV Context。全tensor未发布前，即使某窗口完整也不能Q；后窗口/其他batch失败使整个tensor不可消费。
- LN/残差/向量/非QKV Linear：取实际完整输出本窗口的typed任务；Linear等四view和唯一父TaskDone/末B，rows4 response不是父窗口P。P保留真实stage/layer/op；LN_EMB stage1→首个LIN_QKV stage2合法，不能硬要求普通P与Q同stage/layer。
- QKV：两条实际Ref/epoch、pair/plane/head覆盖和两路末B分别核验；同一LIN_QKV父Context可成为两侧同窗口的P，但owner键不同，全pair必须原子发布。RoPE新epoch保留旧V来源并核全部Q/K更新，由每shard/window实际覆盖闭合的RoPE记录新P；不能把旧P直接改epoch。普通QUANT仍不接受QKV为连续F32源，原shape白名单不变。
- 原地/SCORER：保留旧epoch已发布凭据及原合法独占读lease，为新epoch另记P。SCORER Q取旧LN_MARKER来源，Q完成A后才允许该窗口覆写；新epoch P来自真实LIN_SCORER_FC1父任务，再后BIAS_GELU有自己的P。失败不能把已覆写旧epoch回滚READY。
- Q成功后A冻结其消费的source/P证明；MATRIX各view核此冻结绑定。F32源已按原规则释放或原地更新时，不误要求旧源现在仍READY。相同只读源可有合法不同Q消费者，重复同一Q票据仍拒绝；GATE专用预约消费不变。
- 失败/取消先排空、撤销本请求证明和未来绑定；同session新request以完整NumericIdentity区分，门户高水位与L13M基址绑定保持。

内部记录字段及保守固定容量见合同§2：32 owner×128窗口，最多两owner保留旧epoch额外256，共4352条窗口证明上界；允许经活跃性证明压缩为更小固定pool和复用coverage。不是4352个包或新tensor缓存，实际metadata/资源另计。

物理边界仍严格：typed逻辑完成与真实输出覆盖/RRESP/BRESP/末B需共同成立，不能把C READY或`done.drained=true`直接接成物理source成功。本答复解决P选取；实际generated非门户producer的身份绑定到物理ledger仍属于§3.9工程闭合。若现生成端口无法承载必要绑定，请直接给出实际端口/连线缺口，不以假P或布尔echo上线，也不私加wire。可先独立实现并验证C来源账本/普通builder。

已核`portal_controller_04` receipt四项文件SHA与日志；该证据明确是C++ Controller配受控service回复的metadata/retirement验证，25命令/13 typed任务，无真实数值payload、hub或RTL声明，不能作为物理整链PASS。完整manifest闭包未在本次架构答复中验收。

继续原授权内受影响实现/测试，必要边界用例见合同§6；无需逐项等主控。L0/L1 PARTIAL、L2–L5 NOT_RUN，组合full NOT_RUN_COST及M003/M004未完成状态保持；原ABI/wire v2/模型/数值/预算、G余2338.224019s不变，无新OOC/P&R/上板。

已采用新的README/索引/讨论导航规范，权威正文更新后由统一工具刷新；本讨论状态登记为待实施，不因本答复关闭验证事项。


[原始消息收据](../../.research-agent/communications/ordinary-linear-provenance-answer-20261012.json)

相关文件：[ordinary_linear_provenance_contract_20261012.md](../../results/ordinary_linear_provenance_contract_20261012.md)

## 相关决定和审核

- [ordinary_linear_provenance_contract_20261012](../../results/ordinary_linear_provenance_contract_20261012.md)
- [ordinary_linear_provenance_reply_20261012](../../results/ordinary_linear_provenance_reply_20261012.md)

### 状态确认 2026-10-11T16:27:42.201548+00:00

项目主控与架构评判：逐窗口覆盖闭合P及完整覆盖/发布门已定义并送达；普通来源账本、generated物理来源链及受影响验证尚待交付。 → 已答复待实施

[ordinary_linear_provenance_contract_20261012.md](../../results/ordinary_linear_provenance_contract_20261012.md)

### 状态确认 2026-10-11T22:09:53.990506+00:00

项目主控与架构评判：普通source窗口P/发布/query原子lease已有四项冻结局部证据，450项SHA引用与93组身份一致。新增F5/P1：短producer可置完整rows16窗口位，整tensor发布完整性待补修和有界回归；真实generated来源仍待闭合。 → 待验证

[ordinary_source_quant_reply_20261012.md](../../results/ordinary_source_quant_reply_20261012.md)

### 状态确认 2026-10-11T23:31:50.680051+00:00

项目主控与架构评判：F5由generated_source_lease_04的精确标准窗口行数及受影响回归在当前单全宽范围关闭；普通source完整多role/row-space/QKV与production generated来源仍待验证，不能以两项受控query grant切换代签。 → 待验证

[production_source_switch_hls_reply_20261012.md](../../results/production_source_switch_hls_reply_20261012.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
