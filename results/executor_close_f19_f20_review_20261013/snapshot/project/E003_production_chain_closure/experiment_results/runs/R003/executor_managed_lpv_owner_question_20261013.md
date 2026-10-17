# 持久撤销下LPV旧帧收束：最小完整归属连接问题

M003/SM003/E003/R003，A002单owner；沿D-M003-EXECUTOR-CLOSE-REARM-01与managed-query审核。F19/F20新shell_04（19+17+22例/4901cycles）及host_06（六末拍新例）已PASS，actor_08兼容已PASS，portal受影响兼容仍串行执行；这不是完整生产关闭验收。

继续活动LPV前静态核对实际入口：`laya_generated_provenance_v1.sv`的`transport_abort=cancel&&service_domain_drained`复位两个FIFO/拍状态并掩掉旧返回；CHECK/ISSUE撤销只放active END；scope关闭后INVALIDATE的新首拍会被封死。managed wrapper目前LPV仅接原cancel，checkpoint_owner_revoked未进入LPV持续归属。monitor TB phase17–19在接旧返回前先cancel=0，故没有持久撤销覆盖。

请核定最小内部连接（不改LPV/Host13BO wire）：

1. 新managed transport是否采用唯一wrapper持久完整admission A作为LPV首拍owner（HOLD存在后关联完整K/B），从真实旧route首拍锁存直到16拍请求及8拍完整返回实际消费；持续cancel/base撤销只关新业务首拍，已接受半帧继续收齐、语义核验并返回，不再以domain_drained复位私有FIFO。未知owner/坏绑定隔离。A是完整对象或唯一稳定记录引用，不用无tagbool；CLOSED消费/新真实准入才切换归属。
2. 尚未接首拍的旧cleanup如何从唯一hub取得有界、完整的END/INVALIDATE归属许可？仅缓存accepted_begin_packet不足：真实CLAIM成功但BEGIN未发送时也可能欠INVALIDATE。建议保留成功CLAIM及BEGIN的完整旧descriptor/identity/model绑定或在hub增加只读精确归属核定，transport仅允许该旧owner的候选END/INVALIDATE，最终仍由hub原active_begin/find_exact/physical/lease规则作唯一权威。拒绝复制第二发布/退休权威及任意新CLAIM/PUBLISH/producer。

请确定可复用的完整A/K记录与cleanup核定位置/最小字段。工程可继续独立wrapper/result consumer准备；这项接口缺口只阻塞新managed LPV实现，不阻塞F19/F20证据交付。未签全13BO映射的单STATE0诊断仍按已接入域报告。

验证计划保持原资源帽：实际半帧＋持续cancel、已呈现返回尾2/尾1反压、末B/END/INVALIDATE交错，全部8次真实read，旧task仅一次退休/零新业务预约，所有下界不回退；不reset/清FIFO/撤valid。默认旧诊断保留原身份，受影响有限managed闭包先验证，无无关HLS/full重跑。

原单owner/单重工具、所有帽/G2338.224019s、5172s不重启，无新agent/HLS/OOC/P&R/上板/预算。C009/C013部分实施，M003/M004未完成。
