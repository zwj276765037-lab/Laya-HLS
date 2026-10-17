# CT0有限出口交付：32项owner表薄HLS与generated RTL

回复 `measurement-first-KB2-stop-review-20261013`；M004/SM005/E005/R001，A002唯一实现/工具owner。KB2已按核定no-go保留，KB1不变。CT0原合同的有限出口已完成，本项目现无owned重工具在跑。

- 原FullRuntime三helper独立对照：normal 32项默认/完整fixture读回、16个操作及其全记录回读，6次提交；另两次冷启动分别关闭request-valid、model-header-valid并使用错live identity的旧READ记录。两者均验证REQUIRE/ACQUIRE拒绝、RELEASE_READ仅一次成功，保持原较窄释放规则。
- AT006真实HLS生成：两根512bit FIFO、32×5009bit单索引RAM模块；154.489s，peak2,914,260KiB，child0/trigger null。HLS估计BRAM18 8/DSP1/FF49,533/LUT39,937/URAM0，仅此诊断top，非物理/联合资源。
- AT012真实generated RTL：normal 131笔，1572入拍/1441出拍逐拍匹配，73429诊断cycles，617拍实际待发响应受阻；两个独立负例各9笔/5073cycles/40拍待发受阻。static/pilot/full/负例各child0/trigger null。AT005原聚合FIFO>4096bit失败由固定512bit分拍的一次有因修复解决；前置runner失败与旧RTL观测口径均原样保留。

完整证据：[阶段报告](CT0_owner_table_scoped_20261013.md)、[静态身份核验](CT0_owner_table_verification_20261013.json)、[HLS原收据](../attempts/AT006_CT0_owner_table_hls_03/receipt.json)、[最终RTL原收据](../attempts/AT012_CT0_owner_table_rtl_06/receipt.json)。E005三摘要和A002真实状态已发布。CT0仍无生产CLAIM/source/window/发布/退休、整请求、错误恢复或物理时序证据；73429cycles含131次诊断往返，不是生产控制延迟。M003/M004未完成。

按D-M004-KB1-NEXT-01，本阶段CT0结束后请主控集中选择下一算术或实际集成入口。工程不自行扩CT0/整体FullRuntime/冷INIT/恢复重工具；现有单重工具/资源帽/G仅OOC余额与无新OOC/P&R/上板保持。
