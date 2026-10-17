# 修订18审核：Q16局部占有闭合，LN128按成本出口结束

2026-10-15；D-M004-REV18-REVIEW-01；A001→A002；M004/SM004/E004/R001。回复`m004-rev18-at306-engineering-cost-owner-handoff-20261015`。本段按原合同成本出口收束；M004/SM004仍running/unassessed，完整LN128未完成。

主控[原始证据审核](lnq_cost_owner_rev18_review_20261015.json)复核756项manifest、12笔guard、101条政策、实际新core编译来源、两臂未变编译依赖及事件/单调墙钟记录；1033项检查成立。static7笔742.38596129976213734s、RTL5笔363.27006784640254s成立；余157.61403870023786266s/2036.72993215359746s封存，不转后继，不以剩余秒数原样重跑。host完整累计UNKNOWN。AT301静态timeout、AT305首次路径child127保留；该child127没有policy采样文件，零样本不冒充已采样合规。主控首次脚本未处理该缺文件，以及后续计数断言失败均保留原time/JSON；没有工程证据失败被改写。

**REV17-Q16-PARTIAL-OWNER在所测局部范围闭合。** AT302旧core真实Q首行后kind01/index0覆盖A而cover保留的反例成立。AT303新core`a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`只增加部分窗口准入保护；kind00/01/11及legacy/LN均拒绝，272旧字、cover/next_row保持，合法row1、临时abort、显式discard与新epoch首行逐位通过。wrapper/sequencer/leaf/算术未变。此关闭具体覆盖漏洞，不升级为新core的完整16行producer或Q16父图通过；旧AT290满窗口/错epoch仍按原身份保存。

**A/B只接纳单次同终点成本观测。** AT304默认/AT305实际接受的--O3，修复后同生产SHA/同TB/fixture、30000cycle及38条有序事件一致，2048 norm/128 B，source192含row2在途64。两臂有同序单调墙钟事件，支持该前缀93.29140920005739s→89.64230179227889s、单次3.9115%改善；不作统计稳定提速、硬件Fmax或全128成本推断。AT306实际120.30851850099862s/-9/timeout仍两行，首个16行窗口没有完成，NORM_STAGE_READY未到；按合同未启动长例是正确成本出口，不能记全128数值失败。

**一个报告计数勘误需追加。** AT304/305 manifest共有112个同名条目全部SHA相同，其中107个frozen和5个fixture；报告/机读A/B的“110份共有frozen”不符实际。请更正摘要/机读对照的统计说明，保留原manifest/原日志。两种事件SHA不是矛盾：38行用换行连接且不附末换行为337b04e8…，附末换行为8b5138a2…；请在报告中注明序列化约定。AT304 manifest的purpose中旧“no optimization candidate supported”仅是冻结时历史文字，实际--O3成功以AT305原命令/日志为准，不回写冻结文件。修订17的1821/source192追加勘误已核到。

后继采用已研究的实际生产服务抽取方向：唯一LNQ/bank/prep和真实source/norm服务，原完整父top必须实例化同一服务，保持共同clk/reset与数值。A003正在按当前源码细化固定端口、bank访问与债零交接；A001会连续下达可实施接口及独立预算，不要求用户逐次批准。当前不扩大旧同配置试验，不把独立服务将来的PASS升级完整父top同runtime。全请求首错、Q16父图、STEP16/matrix/全RoPE/FINAL→Attention、整模/Host-HBM及联合物理仍开放。
