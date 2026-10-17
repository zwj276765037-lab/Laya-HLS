# generated provenance monitor审核：F1/F3接纳，F2与活动取消继续修复

回复`generated-provenance-monitor-milestone-20261012`，审核号R-SM003-GENERATED-PROVENANCE-MONITOR-20261012，正文results/reviews/SM003.md，核查results/generated_provenance_monitor_review_20261012/verification.json。

580项SHA引用与191组current/frozen身份独立核对全部匹配；四项冻结PASS及原FAIL/旧身份PASS保留。F1合法scope-active错误END不退休、F3本ledger连续33请求回收/迟到旧request拒绝可按对应范围关闭。首个role6/单descriptor/rows16 monitor的1024个peer AW/W/B、65536B覆盖、末B/受控adapter门控及两次本地拒绝接纳。两项RTL guard合帽；本轮未重跑工程工具或动态复现下列源码发现。

**F2仍未完全闭合，请继续原审核修复：**

1. `generated_provenance_portal_10`冻结hub make_response:237仍固定DRAINED=1。PUBLISH/RELEASE/INVALIDATE:491–516在valid观察但drained=0时reject仍带该位；错origin END:477也在排空判断前reject。CPU end:377–380错binding同样先走默认drained=true的fail。请将拒绝/非终态drain如实表达或挂起；补未排空owner事件、错origin END及后续真实fence，并核transport自生成拒绝包。不能仅因scope保留就允许虚假DRAINED。
2. hub pending_end期间physical_observation_ready持续为1，但:353只在drained=1处理后续观察。初始OK/drained0→中间已握手E_BUFFER/drained0→最终OK/drained1会丢中间首错。当前TB等待用例只有OK→OK。请逐接受观测保留首错或不接受未处理观测，覆盖首错初始/中途出现、最后status变化和反压；若生产依赖sticky摘要契约，应明确冻结并检查所有输入，不能以当前monitor的sticky实现代签通用hub边界。

**F4/P1：活动producer取消收束被阻断。** `generated_store_monitor_03`冻结transport的:39–40在cancel时封所有cmd入口，:57/124–137在cancel_pending时也拒绝关闭旧scope必需的匹配END。BEGIN已应答、scope活动且未发END时取消，持有cancel会挡END；单拍cancel也会使随后END被pending拒绝。hub又等无scope才清owner，当前没有闭合收尾路径。monitor:199–203在cancel且AW/W hold均空时两ready都为0，也挡住旧adapter尚未到pin的已入队写。按合同§8保留旧producer/adapter排空与绑定匹配END通路，同时阻止新任务，不得靠清scope/清队列/强置idle修复。

monitor TB:265–272只在claim4之后、没有BEGIN的空档cancel；portal TB同样是空档。请把现声明限定到空档恢复，补活动scope取消、BEGIN应答背压、posted-store待发、AW/W不同先后、末B及END应答背压，证明旧绑定/计量保持、取消失败安全封闭一次和同session新request恢复/拒旧返回。

以上是现合同错误路径修复，不改ABI/wire/数值/shape/预算，不需新审批。C012继续待验证，F1/F3子项关闭；C009部分实施，C008/C010保留。可继续独立production master/fence/source-query接线；普通source生产使能前闭合F2/F4与实际adapter因果、原子lease及全域准入。当前单owner布尔coverage不代签多窗口/多owner发布，F3本ledger回收不代签尚未接入的native/compute/lease全域排空。

L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST及M003/M004未完成保持，无新OOC/P&R/上板。下一次full前当前pilot成本入口修复仍待交付。请修复后集中回报受影响证据，无需空确认。
