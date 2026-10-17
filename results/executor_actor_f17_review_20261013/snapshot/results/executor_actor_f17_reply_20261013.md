# Executor actor F17修复审核

回复：`executor-actor-f17-milestone-20261013`  
审核：**R-SM003-EXECUTOR-ACTOR-F17-20261013**；M003/SM003/E003/R003。

**接纳executor_actor_host_04为PASS_SCOPED_HOST_F17_REVOCATION，F17在本次冻结C++ actor及45个有限host用例范围关闭。** 未发现该范围新增阻塞项。关闭的是持续撤销采样与旧工作继续清理的主机缺口；RTL同拍门控、真实物理债务、完整错误结果及硬件rearm仍未验证，C009整体不关闭。旧actor_02 PASS与_03编译FAIL不回写。

## 修复与动态范围

已核冻结actor/header：真实软件准入时锁存admitted_base；从WAIT_CHECKPOINT到结果消费持续比较base epoch/address/capacity、session、accepted-request及cancel，恢复输入不清revoked。RUN_ACTION在READ_ACTION首拍/部分帧和VALIDATE_ACTION前另核启动fence；已进入活动执行后不要求physical_quiescent/source_held/target_held恒真。撤销继续传入原port/FSM，没有用提前return或清tracker替代旧completion/END/INVALIDATE路径。

33例由三个明确边界×11种变化组成：首拍未读、已读3拍、已收8拍待校验；变化含base三个字段、session、request实例、单次cancel及source/target/dispatch/handoff/quiescence启动fence。每例恢复输入并注入旧GRANT，revoked保持。首拍未接收时8拍action仍未读，task/event/producer/退休无新增；部分/完整旧帧按原键完成本地安全拒绝，0次退休；旧安全完成消费后，排队后继仍未读。

另外12例为活动BEGIN和已接受producer两个位置×六类不可变变化。实际actor/port/FSM及C++ LTC1 codec处理受控peer返回，尾2/尾1拍分别延迟12次调用，generated_store保持活动且不提前退休；完整匹配后继续旧END/INVALIDATE。BEGIN后撤销时未外发producer由受控peer产生合法本地拒绝，已接受producer分支返回成功；两个分支的软件task5各恰退休一次，producer外发分别0/1。该证据不含真实生成adapter或硬件monitor/hub，不能写成物理排空或硬件退休。

已核活动期主动将physical_quiescent/source_held/target_held置false而不触发撤销；随后不可变绑定变化才置revoked。原两个软件请求的实际program top/port/FSM/adapter与受控远端路径同次保留，每段4次退休、导入贡献0、producer/action/S/H持续编号不回退。新增45例使用program helper和直接LTC1 peer，不把它们写成完整program/adapter同runtime测试。

## 身份、保护与历史

独立核对83/83 frozen/声明pair、81/83 current、193/195递归manifest/receipt引用，两项live差异均为本轮catalog登记；五个交付SHA一致。_02→04共同83项六处变化为actor/header/TB/runner及两catalog；_03→04仅TB将异型auto合并声明拆成两条，DUT和断言未改。_03原始编译错误与FAIL保留，未执行DUT。20份fixture文件与_02逐项SHA相同，7168B literal和旧wire/helper/GRANT负例保持。

三段guard child0/trigger null、起止串行，28条实际policy符合CPU0–3/nice19/idle I/O及MemAvailable门、24GiB/1800s/120s帽。oracle/build/run为0.281851/20.242427/0.286247s，RSS峰值24480/254256/21384KiB，本轮三段均有实际采样；-MM仍仅timeout/RLIMIT_AS配置。

原始run.log有45条hls::stream leftover警告，对应45个负例故意保留的8拍未读action；冻结断言与此一致。软件stream最大深度24，未声称depth2。本轮可签阻止准入及旧事务收束，不能称所有流清空、负例请求已完成错误结果或恢复成功。不要求为去警告清掉未读队列或重跑。

[独立核查与冻结快照](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_actor_f17_review_20261013/verification.json)保存上述依据。主控只做静态/证据审核，没有编译、仿真或HLS。checkpoint_host_05仅复用原冻结兼容结论，本轮未重跑或重签当前全部源码兼容。

## 连续下一步

按原授权继续真实shell的DRAIN/HELD、实际helper确认到IMPORT/GRANT、绑定ABORT及带归属rearm；相关闭包满足原合同后串行生成独立executor，无新增逐项审批。真实LBR2末拍只进入待导入确认，旧portal直接handoff及Q query长期屏蔽仍须改接。source保护、成功活动fence移交与结果消费后的释放、8/4 action和F10 24/16真实consumer、LN/monitor/唯一hub→真实END/唯一软件退休→Q/fullA继续逐项取得实际证据。

F17仅本次host范围关闭，硬件启动/撤销/读债NOT_RUN；C009部分实施/awaiting_implementation，C008/C010整体待验。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。G余2338.224019s、原单重工具/所有资源帽保持，无新agent/HLS/OOC/P&R/上板/预算，5172s组合不重启。
