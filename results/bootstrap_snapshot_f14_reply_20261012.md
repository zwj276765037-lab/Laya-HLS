# Bootstrap snapshot F14修复审核

回复：`bootstrap-snapshot-f14-milestone-20261012`  
审核：`R-SM003-BOOTSTRAP-SNAPSHOT-F14-20261012`  
范围：M003/SM003/E003/R003。

**F14在本次冻结hub、持续valid的有限LPV/旧END/INVALIDATE取消交错范围关闭。接纳bootstrap_snapshot_rtl_03的PASS_SCOPED_RTL_SNAPSHOT_ARBITRATION，以及generated_source_lease_05、generated_store_monitor_11的原fixture兼容范围。** 本轮无新增阻塞修复项，工程按原授权继续source保护及executor top/实际消费连接。

主控独立核51/51 current/frozen/声明pair、214/214 manifest/receipt SHA引用与十个交付SHA全部匹配。三guard均child0/trigger null，18+22+18条实际policy符合CPU0–3/nice19/idle I/O，MemAvailable、8GiB/120s/120s进度帽均通过；启动/结束时间无重叠。详见[核查记录](bootstrap_snapshot_f14_review_20261012/verification.json)。主控未运行编译、仿真或HLS。

修复从LPV request_ready中移除未接受snapshot_request_valid的排他条件，只保留已接受且未消费snapshot_response_valid；snapshot仍要求没有LPV request/旧scope/返回等。双方valid保持时现在有明确LPV优先方，旧任务清理不再等待未接受查询撤回。

实际TB覆盖成立：
- idle CLAIM与snapshot同时valid，CLAIM唯一接受；LPV返回保持12周期，查询持续等待，消费后仅一次查询并返回未发布E_BUFFER。
- 第四窗口snapshot从BEGIN后持续到旧END完成；末B未退休时END与查询等待12周期，真实B退休后END前进，终态返回再保持12周期。scope关闭、4次typed终态/9个事件成立，消费END返回后查询获得完整绑定的未发布拒绝。
- 已接受snapshot返回保持12周期时，INVALIDATE持续valid而不被接受；消费snapshot后INVALIDATE恰接受一次。旧cleanup response在cancel脉冲及后续12周期保持原绑定/状态，下一snapshot等待至返回消费和cancel收束，再诚实拒绝。
- snapshot与全零非法QUANT query竞争，snapshot先接受并持返回12周期，之后query恢复ready但无grant/lease。合法QUANT lease只在默认禁用snapshot的兼容fixture中验证，不能把两者拼成启用时合法lease竞争的动态证据。

该优先级证明有限旧任务/cleanup和恢复消费者后的进展，不证明连续高优先LPV流下的snapshot公平性。保持snapshot响应稳定也不意味着来源在整个读取期受保护，自动取消、旁路写、epoch/base切换等仍须由后续唯一source保护实现覆盖。

snapshot_03为8725cycles/29.377487s、peak1529052KiB；lease_05为1628cycles/26.707304s、peak1487288KiB；monitor_11为3097cycles/26.291409s、peak1571572KiB。三项均在pilot内完成，无full投影或性能结论。既有64 AW/4096 W/64 B、262144B四窗口地址pattern prelude及完整身份/未发布/反压检查保持，不签encoder或LN数值。

默认禁用的lease兼容结果保留四窗口完整发布、原子lease、owner release排斥、重复generation拒绝及更大generation重读；release_drained仍由受控TB驱动，不能称为生成消费者真实读债证明。monitor兼容保留原末B/adapter fence、部分失败、活动cancel/返回反压和同session恢复边界。

身份表述有一处需在后续摘要校正：**相对_02冻结闭包，共同文件实际有五项变化**，即hub/TB/runner三份加full_module_registry.json、production_hls_partitions.json两份此前登记更新。后两份是已披露metadata，不是额外DUT变化；codec/oracle/model/layout未变，当前三项闭包合计51组核验无漂移。无需重跑或改旧attempt。_04路径占用按runner入口拒绝处理，不登记成新的DUT失败，也不重标原目录。

继续按既定合同实现snapshot接受至实际source读、completion/fence/action末拍消费的完整来源保护；再连接独立executor、真实8/4 action和F10 24/16事务消费到生成LN master/monitor/唯一hub/Q。当前无executor HLS、action真实depth2或生产整链验收。C009部分实施/awaiting_implementation，C008/C010整体待验；F6–F13/C012及旧LN→Q结论不扩大。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成；G余2338.224019s及原帽/单重工具保持，5172s组合不重启，无新OOC/P&R/上板、agent或预算。

