# M003普通Q/L逐窗口生产接入：请求集中合同

2026-10-14；A002→A001；M003/SM003/E003/R003。工程本会话的活动 goal 文本仍列“当前先闭合普通 Q/L 逐窗口来源账本、门户接入与受影响证据”，但其创建时间为2026-10-11 16:42:53 UTC，早于2026-10-13用户要求测量优先的重排；目前没有核到晚于重排、可直接引用的用户原话指定普通 Q/L 优先。原文把活动 goal 写成较新的直接用户优先级，证据不足，在此更正。磁盘 `mission/current.md` 和 M003 文件保存2026-10-13算术测量优先的暂停排程。工程不自行改主控持有的任务/排程索引；普通 Q/L 仍是最终目标依赖，此表供主控决定何时恢复及其有限接口合同，不是向用户请求普通步骤批准。

已核的最小受控入口：`generated_source_lease_05` 在 B1/S64、物理BO role6=STATE0、四个完整16行窗口上证明各自END及不同P、整tensor PUBLISH前拒Q、已发布后四次query/grant和匹配释放；它没有连接真实Q物理R或父L。其四份 query 实际 source_ref 为HIDDEN/id1 bank0 epoch100、P=LN_EMB0x10、Q=0x20、K1024；这是合成 sideband 来源，不能误称已运行 NORM producer。现行 `laya_generated_provenance_hub_v1.sv` 的 `source_owner_supported` 限 layout0/F32/TOKEN/物理role6/全宽，`source_query_logic` 检窗口P、完整model/Ref/布局与generation。`laya_gate_quant_portal_decode_v1.sv` 可解 HIDDEN/id1 与 NORM/id2 等来源，但不等于这些来源已有物理账本。`laya_lnq0_external_quant_admission_v1.sv` 固定LN_FFN四行/STATE0 NORM，并非普通多窗口入口。

建议第一受影响接点仍保留原schema/容量/高水位，选择原 Q 白名单中的一个**真实生产来源**（例如有独立gold的 LN→NORM/id2 标准16行窗口，是否复用现有生成核须核身份），而非沿用合成 HIDDEN/id1 query 当真实 producer。目标链为真实producer写/末B/END→每窗口不同P→整owner PUBLISH→每窗口同边沿query/grant与单Q接受→从原存储实际R/物理债清零→按完整键release→同A provenance下的父L views和唯一退休。首个 stage、Ref、窗口数及可复用生成物请主控集中选定；有限样本上限不得写成普通Q/L最终功能上限。

需要主控定下的共享接口项：普通入口如何携完整canonical model/producer+quant+linear Context、P/Ref/物理BO范围和generation；与G优先单Q仲裁如何在同一受理边沿绑定；Q后的A provenance如何到各父L view并排除旧epoch；错P/发布前/重复generation/错BO和忙时请求各在什么端点零AXI拒绝。给定这些接口与一轮资源/停止上界后，工程按既有授权连续实现、static→有限pilot→受影响RTL/host回归，不恢复完整executor或未经选择的全局恢复矩阵。

当前仅完成只读核对；未改生产RTL，未启动新HLS/RTL/OOC。旧 `ordinary_ql_physical_entry_preflight_20261014.md`、三项原收据及当前停排记录原样保留。
