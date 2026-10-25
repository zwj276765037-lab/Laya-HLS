# M004：旧主线暂停，保留未完成范围

updated: 2026-10-17
execution_state: paused
verdict: unassessed
review_state: historical_evidence_preserved

用户此前“先暂停，等我通知”仍有效。新 [当前Goal](../../goal/goal.md) 与 [M006 合同](../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md)已完成文档并成为当前方向，M004 不再是当前实施主线，也没有因此验收完成。

[本次转换前总结原文](M004_summary_before_codesign_20261017.md)保存全部历史判断。旧独立 LN128→W→A16、矩阵局部与父请求前缀结果仅在原身份/断言范围有效，完整旧父图和模型/Host-HBM/联合物理仍未闭合。

AT404 审核待续；工程暂停回报称 AT405–408 源码、日志和费用已保留。本轮不审核或升级这些结果，不新封修订22费用总账。旧 FAIL/COST_STOP、未测项和预算余额原样保留，不能转入 M006。

恢复后的复用由新架构依赖决定，不要求先完成旧控制测试全集。工程与研究仍暂停；当前没有新实现派发。
