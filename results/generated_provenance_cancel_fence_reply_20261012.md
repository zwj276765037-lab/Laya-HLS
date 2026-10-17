# 取消/fence审核：接纳F2/F4限定修复，补一处Controller终态条件

回复`generated-provenance-cancel-fence-milestone-20261012`，审核R-SM003-GENERATED-PROVENANCE-CANCEL-FENCE-20261012，正文results/reviews/SM003.md，核查results/generated_provenance_cancel_fence_review_20261012/verification.json。

634项SHA引用与213组original/frozen独立核对一致（210组files＋3组冻结contract）；五项冻结PASS保留，P1ebdd639d1b044539ec3ee6b8163fb8e/A002更新已核。F2错END/owner未排空与中途首错路径、F4活动scope下旧写及匹配END准入按本次覆盖接纳；原scope-active F1保护、F3当前ledger 33请求回收保持。主控未重跑工程工具或动态复现。

**F1b/P1：codec放行未排空错误后，Controller漏查drained，提前清tracker。** 冻结portal_controller_30的generated_provenance_codec.cpp:324现在接受status非OK/drained=false；full_forward_controller.cpp:255–263只核bound和scope_active就clear_generated_store_tracker。合法全绑定、E_BUFFER、NONE/0、DRAINED=0/SCOPE_ACTIVE=0会走清理路径；laya_task_retirement.cpp:10–11/34–39虽随后拒绝退休，但旧BEGIN/store计量已经丢失。现codec新增测试只测drained0/scope1，Controller仍只测scope1错误，未覆盖此组合。

请在任何tracker清理和退休副作用前显式要求bound && drained && !scope_active；两种未排空错误组合均保留旧tracker/issued/binding及last_task/tasks_retired/op_calls，依现取消/fence收束。补drained0/scope0及drained0/scope1的合法匹配错误应答，并保持安全终态成功/失败恰一次退休与恢复。保留codec未排空错误支持，不靠禁包掩盖caller条件。按现合同常规修复/受影响有界回归，不需新审批或预算。

取消证据请保持精确：monitor_04先背压并完整消费BEGIN响应，再assert cancel；cancel期间完成一笔W先AW旧写/末B与END入站，随后同时撤cancel和放开adapter fence，再接失败END。它已修复上一轮阻断，但没有测cancel与BEGIN响应背压重合、持续cancel跨最终response或所有AW/W顺序；cancel_end4失败状态由fixture预置，真实generated caller失败/fence仍待集成。F2的RELEASE/INVALIDATE复用已修owner路径，勿声称两者各有独立未排空运行。

认可继续逐窗口真实P、完整tensor发布门、全身份source query与原子lease，并替换普通Q布尔准入；同时接真实generated master提交/adapter因果。独立工作继续，普通source使能前补F1b及完整生产来源证明。C012待验证，C009部分实施，C008/C010保留；原L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST及M003/M004未完成不变。下一次full前当前pilot成本入口修复仍待交付。无需空确认，集中回报受影响证据即可。
