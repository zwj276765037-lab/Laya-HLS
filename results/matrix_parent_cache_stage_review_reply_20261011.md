# R-SM003-MATRIX-PARENT-CACHE-20261011：真实缓存父matrix范围审核

主控已完成`matrix-parent-cache-milestone-20261011`审核；权威结论在`results/reviews/SM003.md`的R-SM003-MATRIX-PARENT-CACHE-20261011，核查快照`results/matrix_parent_cache_stage_review_20261011/verification.json`。94/94条文件引用匹配，消息提供的两个attempt manifest/receipt四项SHA一致。

接纳matrix_parent_cache_03的限定同runtime PASS：实际quant_dual_a_v1/t4_dual_w_cache_v1直接接v2父matrix，rows16父四view/g100..103绑定一致；167936 PS/16384最终F32 gold、独立AW/W/B各2048、末B/债务退休、中间pin保持与最终释放、父覆盖ffff/一次parent complete及部分tensor不提前READY有冻结断言和日志支持。A仍是四条原Down预量化行重复，owner/source publication及LOAD由TB驱动，不能拼接此前split_04代签实际G/Q→matrix。B2/S128仅是本测试的256行tensor边界身份，不变更生产模型目标。

范围表述请保持：本TB的parent_taskdone计数来自ledger_parent_complete，未执行generated Controller typed TaskDone；real_A_acquire_release=1/real_W_lease_release=1是常量PASS标签，直接核验的是跨view pin/状态和末view释放。下一受影响集成TB补独立物理acquire/release握手计量即可，不要求为此重跑本历史full。

static/pilot/full 62.534447/92.153086/1725.782300s及RSS均未超原帽，当前pilot只含首view部分PS工作，末输出/B明确NOT_RUN；full前2730s估算引用两次冻结single-view中较慢454.920886s×4×1.5。估算/仿真墙钟不签完整请求性能。已比对_01→_02仅TB op61→20；_02→_03为row0/地址原点修正，并把错误的整tensor publication=1期望改为0/FILL。RTL和fixture记录不变，失败保留。

split新格式work保护修复接纳其有界范围：1000次不变work不推进、两次增加推进，TB按实际工作量发日志，guard主循环仅advanced才刷新。仍需补一个常规边界：production_guard.py的semantic_progress_advances在split_progress_work返回None时直接True，所以已识别FULL_CURRENT_GATE_QUANT_SPLIT_PROGRESS前缀但缺work/格式不合法的行，仍会落入通用FULL_CURRENT匹配刷新计时。请区分split进度解析失败与其他合法阶段日志，前者不刷新；扩展有界检查覆盖旧cycles/state-only行和缺字段行即可，无需Vivado/历史full重跑。现新格式结果保留，独立集成继续，无新增用户审批。

下一出口沿现合同：同runtime实际GEGLU/QUANT输出接入同一物理fullA与父matrix，再补至少两个父L的同tensor覆盖、后父失败sticky与不提前发布、原首错规则、实际末R/B与lease清理及同session恢复。随后补其余Q/L、LOAD调度、唯一持久hub/generated caller、L2/L3和当前完整CPU/实际CSim。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；M004仍为完整Laya加速器并尽量高性能，不设固定门槛。原数值/模型/shape/13BO、单owner/单重工具、全部资源帽及G OOC余2338.224019s不变，无新增OOC/P&R/上板。主控本轮只读审核与文档更新，未改实现、未运行工程实验。
