# generated provenance基础阶段审核：保留局部PASS，修复三个缺口

回复`generated-provenance-base-milestone-20261012`。审核号 **R-SM003-GENERATED-PROVENANCE-BASE-20261012**，正文`results/reviews/SM003.md`，依据`results/generated_provenance_base_review_20261012/verification.json`。

六项冻结运行的局部PASS与身份记录一致：主控独立核632项SHA引用全部匹配，284组current/frozen/pair一致；P99ab248afbc7430c8fca94955f1d8a39及A002新状态已确认。codec、CPU事务参考/builder/Controller、受控RTL hub及12信号probe按各自范围保留。基础实现暂不验收，源码发现以下三个未覆盖缺口；本轮未运行故障复现，不篡改原PASS/FAIL。

**F1/P1：合法的scope-active错误END被Controller当终态退休。** 冻结portal_controller_27的`generated_provenance_codec.cpp:316–350`允许非OK END保留scope，并返回该错误；`full_forward_controller.cpp:255–276`只核code/detail/bad相等，随后无条件clear tracker并retire，没检查scope_active；`laya_task_retirement.cpp:34–45`在drained=true时会推进typed计数。完全匹配identity/seq/origin/Refs、E_PROTOCOL、DRAINED=1/SCOPE_ACTIVE=1、NONE/0输出即可触发。现malformed_end测试仅改保留byte192，未覆盖此包。请新增该合法拒绝包用例：tracker/issued bytes保留、last_task/tasks_retired/op_calls不动；只有身份正确且DRAINED=1、SCOPE_ACTIVE=0的END终态才清理/退休一次。保留codec对合法scope-active错误的支持，按取消/fence收束，不把它粗暴禁掉冒充修复。

**F2/P1：hub/CPU reference在physical_drained=false时仍回DRAINED=1。** 冻结hub END分支:365拒绝未排空，但make_response:220总置bit0；CPU ledger response_base:189也固定true。TB一直输入physical_drained=1，没测此分支。请保持未排空事件挂起及旧scope/债务至真实fence，或如实表达非终态错误且caller不退休；不得用observation_valid作为drain证明。补valid观察但drained=0、随后真实末B/adapter排空、错误/应答反压及重复END用例，同步核其它owner事件和BEGIN准入。

**F3/P2：32个typed身份槽没有请求完成后的回收。** RTL typed_valid仅reset清零，CPU typed.occupied同样只置真；RELEASE/INVALIDATE/cancel不回收。不同NumericIdentity连续占满32槽后，即使owners都已释放，第33个请求也无法BEGIN。请在合法新request准入且旧全域scope/lease/native任务/队列/返回已排空处回收旧typed槽，保持event/compute高水位及旧request拒绝；补至少33次同session递增request及旧请求迟到测试，不能靠每请求冷复位或增加容量绕过。

以上按现合同§5/6/8连续修复和受影响回归，不改ABI/wire/数值/预算，无新逐步审批。C012待验证，C009仍部分实施。可并行于你自己的独立monitor工作推进；生产普通source使能前须闭合上述错误路径。

认可先接普通contiguous rows16真实store monitor/interposer→持久hub→普通Q source lease的顺序。C store提交计量、受控physical_observation及FIFO probe均不代签真实WSTRB唯一覆盖/posted-store fence/production top；Controller CPU日志stream最大深度400也不证明depth2硬件进展。按原合同补实际引脚/adapter因果、末B、部分失败/拒绝写债务，再扩普通/GATE切换和其余shape。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成保持；G余2338.224019s不变，无新OOC/P&R/上板。请保留原失败及本次冻结证据，修复后集中回报对应出口，无需空确认。
