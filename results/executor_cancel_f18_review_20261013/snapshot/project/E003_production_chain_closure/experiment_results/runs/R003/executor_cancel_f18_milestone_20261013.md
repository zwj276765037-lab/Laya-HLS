# F18有限仲裁修复与未准入action取消consumer主机准备

M003/SM003/E003/R003；A002唯一实现owner。沿D-M003-EXECUTOR-CHECKPOINT-IMPORT-HANDSHAKE-01及D-M003-EXECUTOR-REVOKE-UNACCEPTED-ACTION-01。交付供主控集中审核，未改变原权限/预算/数值或覆盖旧attempt。

F18修复：DRAIN当拍控制接收抑制自主HELD发布；已发生的真实query握手优先于同拍等待ABORT，QUERY期间控制ready保持0，16次实际返回读取完成后持续ABORT才被接受。响应呈现后保持到消费。shell_04在原16例上增加DRAIN/ABORT同拍、HELD无query接受/ABORT、实际query接受与持续ABORT三例；19例/2008cycles、21.575894s、peak1433856KiB通过。零授权、一次关闭、锁及S/H保持；持续返回反压和尾2/尾1各12周期有断言。F18由工程标为已实施/有限验证，最终限定关闭归主控。

portal_04使用同冻结shell及原真实hub/monitor/transport fixture兼容通过。受控正常前序7终态、112AW/7168W/112B、458752B；真实16/16 depth2、末2/末1停读、实际helper离线回放及GRANT真实消费后CLAIM180/epoch9保持。当前装配仍在TB，query许可尚未移入生产wrapper。该兼容不是新增source保护、任意控制/query交错或硬件rearm结论。actual capture与原独立literal的S/H均为1/1，1024B直接逐字相等，不改任何字节；raw SHA05fd66a4d50e3bcca0d086a3cb2503202f595ed10a6d1e287cc817a34e1a64a6。

## 取消consumer的实际主机证据

cancel_drain_host_02为PASS_SCOPED_HOST_CANCEL_DRAIN_PREPARATION。新增LAP1 1024B/16拍v1内部归属记录，session/request/S/H引用shell保留完整B；完整command256B和program已分配pending action512B被原样记录。显式program_hls::State/step复用原program逻辑；旧extern C入口及默认行为保留。实际消费command首拍锁存旧K，旧半command在撤销后继续收齐；未分配action时真实program形成ordinal0本地错误结果。

LAP1完整decode/encode匹配独立literal1024B，14项wire拒绝清输出；C/SV仅布局常量静态一致，尚无LAP1 SV执行。actor只在普通port未接收首拍、持续revoked且无活动tracker/源租约时，依据实际program完整pending记录选择唯一取消consumer。正常port部分帧和活动任务仍保留原consumer；本轮actor_06重跑原45项F17及两软件请求、8次真实退休，均保持原有限fixture结论。

三项成功取消分别为program完整action、仅发2拍action、普通首拍读取与撤销同step的选择边界。完整8拍按原LAX1 codec及全部pending语义逐字核验后，仅提高普通/取消共享的接收action high-water；不调用start/预约/retire。生成原键flags79非OK LAC1，retired/first/last为0、空slot；原program真实completion consumer消费4拍并校验后形成原ordinal1的非LOCAL_REJECT错误LGR1，PC0、目标slot未更新。LAC1及LGR1各256B逐字匹配独立gold。三个FullRuntime从导入后至取消结果消费逐字节不变，零新task/Ref/LPV/producer/compute号及业务统计、零事务/退休。没有source AR/AW硬件实例，不能据零软件事务称硬件AR/AW实测零。

8项语法合法错ordinal/source/version/epoch/target/PC/slot/layer或坏保留位，以及4项错session/request/S/H，保持隔离、无可信完成和接收高水位推进。重放排队原action不再次产生完成。两项真实未产生action分支覆盖旧command尚未开始及实际已读两拍，仍正常消费旧command并由原program产生本地LGR1；无伪造LAC1/ordinal。软件action尾2/尾1、completion尾2/尾1及Host result尾2/尾1各延迟12次调用，状态/归属保持。软件stream不限制深度，不能代签真实depth2或RTL同拍行为。

撤销结果实际Host末拍消费事实现在锁存，但在绑定CLOSE/真实安全释放未接线时保持WAIT_RESULT_CONSUMED；输入恢复不清撤销、不重装新请求。该证据签保留与禁止rearm，不签绑定关闭或恢复成功。真实控制consumer、生产LAP1 owner握手、全部物理债务、CLOSE/transport无复位rearm仍待。

## 身份、历史与资源观测

五项最终attempt为shell_04、portal_04、cancel_host_02、actor_06及graph_program_top_host_04。完整口径273/273 frozen/声明pair，登记后265/273 current、711/719 manifest/receipt SHA引用；八处live差异全为两catalog各四次登记引用，无DUT/TB/oracle漂移。10段guard child0/trigger null且起止串行，84条实际policy符合CPU0–3/nice19/idle I/O；配置帽、退出/墙钟及MemAvailable门已核。

资源观测保持分层：shell oracle、cancel_02 run和actor_06 run没有owned-child RSS/policy样本；actor_06 run的wrapper elapsed为1.224335s，但仅1次RSS sample、0次child capture，不能因超过sample period推定采到了子进程。峰值保留null，只签配置/功能及实际MemAvailable。初版行政audit因严格要求该段child观测而返回false，原文件保留；02另将无观测明确列为未知，不修改任何运行物、不补造policy。graph_program_top_host_03先按既有runner执行，只有launcher/timeout/RLIMIT_AS；04同源功能在真实outer owned-tree guard内重跑，03原PASS保持且不追认观测。

shell_03原18例PASS、portal_03原fixture PASS、cancel_01原PASS和actor_05原PASS均保留。03→04 shell改仲裁及TB增加已接受query/持续ABORT；cancel_01→02及actor_05→06只有actor结果消费禁止缺CLOSE的rearm与TB末拍消费等待改变。graph_program_top_03→04共同冻结源逐项相等，只增加外层owned-tree执行。具体差异见history JSON。

## 连续下一步和总体状态

先将TB门装配搬到唯一生产wrapper，区分查询首拍/旧半帧与撤销清理，避免transport在持久cancel下阻止已发帧完成；接实际codec/helper控制consumer及LAP1归属握手。然后绑定ABORT错误结果、CLOSE/真实Host消费/全部半帧物理排空、带归属transport rearm，保留S/H、hub task/Ref、LPV及producer/compute/program全部下界。补真实depth2 action8/4、F10 24/16和source全部入口/合法交接后QUANT lease。相关闭包满足后再按原帽串行生成独立executor，接LN/monitor/hub→实际END/唯一软件退休→Q/fullA。

F17等旧限定关闭不扩大。C009部分实施/awaiting_implementation，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。当前无重工具运行。原单重工具/资源帽/G2338.224019s保持；5172s组合不重启，无新agent/HLS/OOC/P&R/上板或预算。
