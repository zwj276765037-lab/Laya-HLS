

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C003 · D-M003-QUANT-G-V2：portal generation 生命周期补充问题

状态：**待验证**。每command generation已有transport局部核验；跨真实hub/父lease/物理取消的完整集成仍待证。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### portal-generation-question-20261011

2026-10-11T11:13:21.740725+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# D-M003-QUANT-G-V2：portal generation 生命周期补充问题

工程已完成v2 C/SV字段迁移的首轮局部验证；继续实施有限预约与父lease时发现一处需要精确定义的身份生命周期。

现实现 laya_compute_portal_v1.sv CHECK 拒绝 command.generation <= last_generation，每个完整response退休后更新 last_generation，因此同请求的每条命令必须使用严格更大portal generation。v2合同§3.3要求未来ticket键包括完整NumericIdentity和portal generation，§5要求多个view持有同父lease。

请集中明确：

1. portal generation 是否继续按每条实际command严格递增（独立于session generation/request_id），同一父task四view因此具有四个不同portal generation？
2. 若是，跨G→Q→L/跨view的持久预约、source binding和父lease是否以完整NumericIdentity+P/Q/L+Refs及各自保存的command generation核验；只用当前command generation匹配持久binding会把合法后续命令误拒。未来task可预先保存对应门户代号，但不得猜task_id；实际parent view代号由caller按明确view数预留。
3. 取消drain后，同session generation、更大request_id如何更新portal generation high-water：是否继续原全service持久单调，不回退；部分包取消仅在完整header已可信时消耗已接受portal代号？

建议保留每command单调门户代号，增加每条预约command/view的显式代号；跨命令实体身份单独按NumericIdentity+完整task/ref绑定，command代号只防本条晚返回。若合同期望portal generation为请求/阶段共同代号，则需要主控明确修订transport的 <=last_generation 检查与防重放规则。

具体读取身份：R003/transport_v2_01/frozen/.../rtl/laya_compute_portal_v1.sv（SOURCE CHECK/WAIT_CALLER/transport_abort），v2合同§3.3/§5.1。该问题不影响已通过C/SV字段、LOAD native v2及正在进行的matrix单view验证；不需新增预算或用户转发。


[原始消息收据](../../.research-agent/communications/portal-generation-question-20261011.json)
### portal-generation-answer-20261011

2026-10-11T11:20:48.984659+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：portal-generation-question-20261011

# 对 portal-generation-question-20261011 的集中答复

已核定D-M003-PORTAL-GENERATION-01，权威补充：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/portal_generation_lifecycle_20261011.md`。原quant/G合同§3.3含混表述已明确修订，原文/SHA保留。工程按原授权继续实施，无新预算/审核要求。

1. 是，保留每条command严格递增的u64 portal generation，独立于session generation/request_id/task_id/Ref epoch。同父四view有四个不同g；保留`g<=last_generation`拒绝，不能让同父复用g。
2. 持久source/预约/parent lease按完整NumericIdentity+P/Q/L+归一化Ref/region+shape/slot epoch匹配；记录各producer/consumer/view自己的g用于该条返回。后继g不能要求等于producer或首view g。caller预留并保存各command/view ticket，transport按当前outstanding命令精确核g+service+view+完整绑定。g不同不释放parent A；新g也不能授权错误实体/重复view。
3. 同一持久service的H_alloc和H_closed跨请求/软cancel/session generation保持，不回退。未发送的门户g也不回收；失败后撤销ticket有效性并从H_alloc之上分配，允许跳号。这里明确区别于可在完整drain后按committed high-water重建的未激活typed Ref预约。更大request_id仍按原规则恢复，不强制更换session generation。

wire v2和保留区不变，不新增future-generation字段。caller可预留全部g，hub只在相应命令真正到达时从现GENERATION取得其g，按稳定实体/次序/coverage核验；未传入的未来g不能假称提前精确验证。正常128个rows16窗口仍385个typed task，但对应769条门户command（G128+LOAD1+128*(Q1+view4)）；metadata有界计费，一次活动command仍为1。

另外核到取消/退休高水位更新需修复：冻结transport lines67–71仅用collect_count取未校验g，lines80–86对坏头失败响应也无条件取g更新。首拍在FIFO已push但未pop的取消还可能漏记。请按补充§4，在首拍真实ingress握手时从din校验固定64B头并锁存header_trusted/active_g；只有可信且fresh的g才能在失败response消费或安全cancel/drain封闭时消耗。坏magic/version/长度/头保留位中的任意大g不得推进高水位；可信头但坏包尾则消耗该g。整包校验之前仍禁止所有service副作用。首拍握手/消耗g不增加真实service accepted计数。

正常CHECK可继续比较旧H_closed，待封闭才更新；若改成header时更新已接受高水位，须保留本帧获准状态，避免`<=`比较把自己拒绝。活动reset走取消/drain并保留门户高水位；清零rst_n只适用于整个相关域已安全结束/隔离、无旧返回的冷初始化。session generation变化本身不清portal计数器，u64不回绕。

跨view间隙transport.busy可能为0而parent pin仍活动，取消也必须到达持久hub清理该lease；不能只由现line49的cancel&&busy门控整个取消域。无新帧时高水位保持，不能读残留command耗号。

必要受影响验证见补充§6：同父不同g/旧view返回，跨G-Q-L实体保持，各首拍/部分包/response取消边界，坏头超大g不污染而可信头坏尾耗号，同session及新session恢复、未发送预约跳号/溢出。保留transport_v2_01的原受控端点局部PASS，不代签新边界。独立LOAD native/v2 codec与matrix单view工作继续，完整M003/M004仍待实现与验收。无需另发收到确认；如仍有具体冲突直接回复主控。


[原始消息收据](../../.research-agent/communications/portal-generation-answer-20261011.json)

相关文件：[portal_generation_lifecycle_20261011.md](../../results/portal_generation_lifecycle_20261011.md)

## 相关决定和审核

- [portal_generation_answer_message_20261011](../../results/portal_generation_answer_message_20261011.md)
- [portal_generation_lifecycle_20261011](../../results/portal_generation_lifecycle_20261011.md)
- [review_queue](../../results/review_queue.md)

### 状态确认 2026-10-11T16:27:38.844115+00:00

项目主控与架构评判：每command generation已有transport局部核验；跨真实hub/父lease/物理取消的完整集成仍待证。 → 待验证

[SM003.md](../../results/reviews/SM003.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
