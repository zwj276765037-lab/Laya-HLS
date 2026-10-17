# KB1同profile输出服务下界与结果提交反压

仅解释AT002既有冻结行为与计数；未启动新DUT或工具。

KB1输出16384B有效数据，实际W物理字节同为16384，256个512-bit W beat、AW/B各256。每拍64B已全用，固定512-bit端口下256笔是该样本必须写出的最少物理事务数。冻结TB `AWREADY=!aw_seen`、`WREADY=!w_seen`；只有真实B消费才清seen，故这个profile强制事务串行，不能用增加DUT待发队列直接让peer在上一B前接纳下一笔。B延迟固定17+(实际beat序号%3)，256笔总共4608次逐negedge decrement；原日志held_B也为4608。

实测first AW在cycle39004、last B在43931，输出服务跨度4927cycles。B延迟decrement占其中4608次，二者差319cycles。若首AW时刻及该peer策略不变，连全部其它输出间隙都理想消除，该跨度最多缩319cycles；这是乐观条件上界，不是可实现收益，也不是整个命令的无条件界限。更早启动首AW仍可能移动最后B，但须从真实最终输出/PS形成与发布约束证明。多未决B必须另建有明确规则的response profile和同profile KB0，不能与本轮直接比较。

真实ready依赖链：resident在最后一组PS把`commit_ready`交给adapter `final_ready`；adapter仅当对应row未存储且row序号满足时接收，并按row输出；bias输出的`ps_ready`在本地pending未消耗时依赖其`out_ready`；它由writer `packet_ready`驱动。KB1的PS_commit_not_ready4691、writer_packet_not_ready2819、writer_tx_valid4928与AW/W已送无B4352都可重叠，不可相加或直接当可节省周期。当前证据支持“结果提交到串行B返回”这一族原因，但未给出每个环节的互斥归因。

因此下一同profile算术候选应先定位可否更早形成/发出首个完整最终输出，或真实PS与写回重叠中哪一环节改变最后B/完成边界；不能只凭2819个writer packet stall扩写缓存。受控peer改变时单独测新基线。原始与源码逐项SHA见[推导JSON](KB1_output_service_bound_20261013.json)。
