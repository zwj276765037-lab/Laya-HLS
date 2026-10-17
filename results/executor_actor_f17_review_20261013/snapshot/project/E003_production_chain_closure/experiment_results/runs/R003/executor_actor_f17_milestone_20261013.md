# Executor actor F17受影响主机回归交付

回复：executor-handoff-actor-host-review-20261013。范围M003/SM003/E003/R003；沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01。工程自检为PASS_SCOPED_HOST_F17_REVOCATION，提请主控按冻结身份集中核查，不将原actor_02 PASS改写。

## 修复与限定范围

actor在真实准入时保存admitted_base，从WAIT_CHECKPOINT到结果消费持续锁存base epoch/address/capacity、session、accepted-request实例及cancel撤销，输入恢复也不清除。RUN_ACTION首拍、部分帧及VALIDATE_ACTION之前另核启动fence；已活动任务只核不可变准入，不要求physical_quiescent或已移交的source/target fence恒真。撤销传入旧port/FSM，首拍未接受时不读新action，部分帧保留并完成原绑定帧，已活动事务保留completion/END/INVALIDATE出口。没有检测变化后直接清tracker或提前return隔离旧工作。

executor_actor_host_04本次新增45个有限host用例：33项READ_ACTION首拍未读/部分3拍/完整8拍待校验，逐阶段测试base三字段、session、request实例、单次cancel及五种启动fence丢失；12项活动BEGIN或已接受producer完成时六类不可变变化。各用例恢复输入并注入旧GRANT，撤销仍保持、后继8拍action不被读取，无额外普通派发。

活动用例实际actor/port/FSM使用受控LTC1 peer。原BEGIN或producer完成的末2/末1拍各延迟12次调用，tracker/reader不提前清理；真实C++完整codec匹配后沿旧END/INVALIDATE收束。BEGIN后取消的未外发producer经本地拒绝形成实际安全错误task5终态；已接受producer成功返回后同task5真实END退休。两分支均恰一次退休，未接收工作为0次。这里不称硬件物理债务/生成adapter同runtime；真实物理安全仍待shell接线。活动期physical_quiescent/source_held/target_held为false不会自行撤销；绑定变化则立即持久撤销。

原本两个真实LYRQ/LYMP软件请求、actual C++ program/port/FSM/adapter/受控远端四窗口路径同次运行保持：两段8次退休，导入贡献0，producer0→4→8，action0→1→2、S1→2/H19→20。七帧7168B literal oracle、20 wire拒绝、五个全键变体、12错/旧GRANT及既有helper/ABORT检查保持。

## 原始结果与身份

oracle/build/run均exit0，0.281851/20.242427/0.286247s；峰值RSS24480/254256/21384KiB。三阶段均实际采样，28条policy记录通过；CPU0–3/nice19/idle I/O、MemAvailable门及24GiB/1800s/120s guard符合，child0/trigger null且串行无重叠。-MM仍仅timeout/RLIMIT_AS配置。

83/83 frozen/声明pair；登记后81/83 current、193/195 manifest/receipt引用，差异仅本次两catalog登记。相对已审核actor_02共同83项六处变化：actor/header/TB/runner四份及两份此前已披露catalog。相对actor_03只改TB一个异型auto合并声明为两条声明；_03原编译FAIL完整保留，无DUT修正或断言删除。

证据：executor_actor_host_04/input_manifest.json、receipt.json、guard_*原始日志，以及executor_actor_f17_verification_20261013.json、executor_actor_f17_catalog_delta_20261013.json。旧_01/02 PASS、_03 FAIL不改写。旧checkpoint_host_05没有受影响DUT变化，本轮复用原兼容范围、不重跑。

## 后续与总状态

真实shell仍在实施准备：独立prequery DRAIN/HELD、实际helper确认驱动IMPORT/GRANT、绑定ABORT及无复位rearm，随后独立executor top生成及真实8/4 action、24/16 F10 consumer/LN/hub/Q。当前portal末拍直接handoff及长期屏蔽Q query仍只限旧诊断身份，未被本次host PASS代签。

F17工程有限host修复通过，待主控审核；硬件同拍启动/撤销/读债证据NOT_RUN。C009部分实施/awaiting_implementation，C008/C010整体待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。G余2338.224019s、原单重工具/全部资源帽保持，5172s组合不重启；无新agent/HLS/OOC/P&R/上板/预算。工程继续独立shell实施。
