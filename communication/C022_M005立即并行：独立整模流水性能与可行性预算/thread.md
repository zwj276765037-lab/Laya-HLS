

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C022 · M005立即并行：独立整模流水性能与可行性预算

状态：**已关闭**。A003最终独立分析已交付并纳入主控结论，v4冻结；条件模型不是实测加速比，本轮无新研究运行。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m005-feasibility-research-dispatch-20261014

2026-10-14T01:39:57.655410+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：handoff；送达：delivered；回复关联：未登记

# M005立即并行：独立整模流水性能与可行性预算

A001→A003研究探索；2026-10-14；M005/SM006/E006/R001。用户当前直接要求建立完整mission并执行，回答完整通路能否算对、资源/频率、整个模型流水推理是否有吸引力以及项目是否可行。现唤醒既有研究会话，不创建新agent。

项目根`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`。读research-agent技能及研究角色要求、适用AGENTS、当前新合同`mission/M005_代表通路与整模性能可行性评估/contract.md`，重点阶段C/D及所有权/预算。当前排程已改M005；旧SM002或旧goal的普通Q/L优先不能推翻最新指令。A002独占实现与重工具，AT063 FFN4 full正在运行；不要启动EDA/GPU/参考全图或另建子agent。

你的任务现在开始，独占写`source/feasibility_20261014/`下脚本、CSV/JSON和报告，其它代码/attempt/三摘要只读。不要撤销他人改动。既有124个weight descriptor中122个Q8的维度/字节字段已与旧工作量表对齐；主控初核资料在`results/feasibility_mission_20261014/initial_budget.py`及生成JSON。B1_from_b0_S128旧profile是47,160,754,688 INT8 MAC、一次LOAD_W声明392,448,128B。必须重新核当前请求图/候选数/任务形状，不能直接继承旧串行Q8分钟数或把这两个总量当实测性能/总流量。

立即做可复算的完整模型工作量、实际/假设流量和共享资源调度：Q8各类形状、Attention QK/softmax/AV、所有LN/quant/G/residual及Decision/scorer/ACT；冷/暖权重上传与缓存加载、row窗口复用、真实spill/scale/PS、端口竞争和合法重叠。分别报告单请求延迟与稳态完成间隔；不能假设串行共享matrix的Wi/Down并行，也不能把每级max或四行周期乘层数当端到端答案。

按100/150/200MHz和有效带宽区间先给条件敏感性；A002新资源/布线时序到达后以实际证据替换。向engineering直接询问容量/绑定/复用或计数缺口，消息按原项目授权收发。先利用现有证据写第一版，不等待工程full结束，也不因此阻塞A002。找同口径CPU/GPU基线时只读已有资料，不新启动GPU；旧A6000 50ms口径不同不能直接算speedup。

host每作业≤120s/8GiB，累计执行≤600s；CPU0–3/nice19/idle，MemAvailable>192GiB，不影响工程重工具；保留输入身份/真实命令/耗时，缺失采样UNKNOWN。给最敏感三假设、可能反驳乐观收益的瓶颈，以及继续当前路线/改架构/停止大投入的独立建议，区分“当前架构不划算”和“项目理论上不可行”。没有匹配对照不得宣称已优于GPU。

更新A003真实state，第一份实质交付直接回复本消息，路径/简要结果/局限即可。A001维护mission/全局结论，A002维护E006工程摘要；不要覆盖他们的记录。


[原始消息收据](../../.research-agent/communications/m005-feasibility-research-dispatch-20261014.json)

相关文件：[contract.md](../../mission/M005_%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E4%B8%8E%E6%95%B4%E6%A8%A1%E6%80%A7%E8%83%BD%E5%8F%AF%E8%A1%8C%E6%80%A7%E8%AF%84%E4%BC%B0/contract.md) · [feasibility_20261014](../../source/feasibility_20261014) · [initial_budget.py](../../results/feasibility_mission_20261014/initial_budget.py)
### m005-feasibility-research-first-delivery-20261014

2026-10-14T01:58:58.037441+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m005-feasibility-research-dispatch-20261014

# M005阶段C第一份实质研究交付

回复 `m005-feasibility-research-dispatch-20261014`。A003已完成第一版可复算分析并收到A002容量答复；未等待AT063结束，未运行EDA/GPU/参考前向或新代理。

主报告：`source/feasibility_20261014/report.md`；正式数据：`source/feasibility_20261014/v4/`（budget.json、matrices.csv、operations.csv、traffic.csv、scenarios.csv、serial_timeline…csv、input_manifest.json）；脚本和实际host回执在同目录。

1. 当前production-v2 B1/S128帧SHA `87fc82b1…`及四tags已核，五payload与AT038独立输入相同：72有效token、16 scorer槽但仅2有效候选。122次Q8完整源图为47,160,754,688 MAC；Attention QK/AV各503,316,480 FP MAC、LN 8,011,776元素、残差7,864,320元素等已分别列入。未将源图调用数写成RTL实测。
2. 150MHz/10GBps/未测速率显式假设的串行服务预算：跨128行W复用约6.919s，仅四行复用约8.133s；100MHz为10.359–11.573s，200MHz为5.199–6.413s。不是实际整模性能或有保证区间，host/完整控制与布线频率仍UNKNOWN；单request slot下条件II=L，未把最大单级耗时当当前流水吞吐。
3. 主要风险是LN约2.20s、Attention1.86s、残差1.32s（150MHz），matrix仅0.638s；只把matrix快10倍的整模条件收益约1.09×。一次Q8权重392.45MB之外还有约651.61MB建模外部流量；丢失跨窗口复用时Q8＋bias加载可达12.53GB/请求。
4. 修正了一个易重计的边界：AT049“G cfg→最终consume”103979cycle含Q/Down LOAD/Down；真正G→最后GATE B为57993。细分区间严格还原同runtime375074cycle；AT054残差仍单列，未拼成新链PASS。
5. 独立建议：完成已授权代表核A/B物理证据，但不扩大当前串行路线的大规模投入；先评估LN/残差吞吐结构。旧LQ1/LQ1R时序问题已纳入，不能把低cycle候选直接按150MHz使用。无匹配CPU/GPU对照，不宣称优于GPU；当前架构吸引力不足证据≠项目理论不可行。

40份输入快照SHA核验及独立重放一致，962个Q窗口/3845个matrix view容量/顺序检查通过。受控分析H001–H006累计3.1602s，峰采样RSS47100KiB；I/O实际采样缺失如实记UNKNOWN。完整报告保留所有参数、限制及下一步证据需求。后续A002新计量/资源/route到达后可直接替换参数，本报告不关闭M005/M004。


[原始消息收据](../../.research-agent/communications/m005-feasibility-research-first-delivery-20261014.json)

相关文件：[report.md](../../source/feasibility_20261014/report.md) · [v4](../../source/feasibility_20261014/v4)
### m005-stage-c-controller-review-research-20261014

2026-10-14T02:02:30.373832+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m005-feasibility-research-first-delivery-20261014

# M005阶段C首版审核与下一步

A001→A003/A002；M005/SM006/E006/R001。阶段C首份交付已完成主控核对，见 `results/reviews/SM006.md`、`results/feasibility_mission_20261014/research_delivery_audit.json`，汇总结论在 `results/missions/M005_summary.md`。

40输入snapshot及当前来源SHA、v4/v4_replay逐文件身份、Q8总量与独立LN/Attention/残差公式、5147服务事件/962 Q/3845 view和AT049 375074cycle分解相符。接纳为可复算条件分析，不签整模RTL/物理性能。150MHz/10GBps/未知算子8cycle单位下6.919–8.133s，LN/Attention/残差主导；matrix10倍仅约1.09倍整模收益。此结果支持暂不扩大当前串行路线投入，尚不能判全部FPGA方案无效。

A002继续原M005 A/B：AT063原帽终态、同一可综合top正常/反压、联合资源/route；不因本预算新增算术优化或提高帽。新计量/物理身份到达后直接给A003，分开当前实测与局部速率迁移。A003后续以这些新证据校准v4条件模型；先保持第一版冻结，不需重复同样的分析运行。候选LN/残差结构改进留到物理证据后的集中选择，本消息没有新增实现授权。M005仍running，M003/M004开放。


[原始消息收据](../../.research-agent/communications/m005-stage-c-controller-review-research-20261014.json)

相关文件：[SM006.md](../../results/reviews/SM006.md) · [research_delivery_audit.json](../../results/feasibility_mission_20261014/research_delivery_audit.json) · [M005_summary.md](../../results/missions/M005_summary.md)
### m005-at063-research-evidence-update-20261014

2026-10-14T02:09:44.255886+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m005-stage-c-controller-review-research-20261014

# M005阶段C：AT063证据补充，首版预算保持冻结

A003已独立核查A002消息 `m005-at063-stage-c-update-20261014` 的原日志/guard/result，补充报告在 `source/feasibility_20261014/updates/at063/report.md`，身份、行号与检查结果在同目录 `input_manifest.json`、`audit.json`。

AT063为semantic_stall有界停止，2080.298887s、最后认可进展后120.092913s，Down cfg/末残差/全链gold未到。cycle358880仅是Down W发布的最后日志边沿；全链cycle仍UNKNOWN，不用于替换v4。

新增独立比较：Wi完整边界、第二次A publish331802、A-ready观察331815、Down W发布358880四条记录与AT049逐字一致；这支持所列前缀观察一致，不代表源码/全链等价。Wi reader真实1312 R/20992 scalar，G issue/return/emit各10496，GATE AW/W/B及第二次Q R各656；组合语义计数不当作物理流量累加。

v4无参数变更、未重跑预算；主控审核的三个SHA锚点保持一致。H007只做10份有界输入的核查，0.053426s，A003累计3.213630s。维持原投入建议及完整链/物理证据缺口；A002按原M005继续，本补充不新增实现或重试要求，不推断DUT死锁或数值失败。


[原始消息收据](../../.research-agent/communications/m005-at063-research-evidence-update-20261014.json)

相关文件：[report.md](../../source/feasibility_20261014/updates/at063/report.md)
### m005-at065-research-evidence-update-20261014

2026-10-14T03:09:07.021066+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m005-stage-c-controller-review-research-20261014

# M005阶段C：AT065补充核查，无预算参数变更

A003已核查A002 `m005-at065-research-measurement-update-20261014` 的原日志、guard/result及冻结TB。报告：`source/feasibility_20261014/updates/at065/report.md`；同目录audit.json/input_manifest.json保留10份输入身份和日志行号。

确认cycle358880完成Down W发布后，Down准入采样`static_ok=x matrix_valid=x`，3588801ns出现Fatal。guard child0/null与runner FAIL并存，退出码不能当PASS。冻结TB唯一`g_cfg_K`连接引用及对应SHA已核，支持未驱动K来源候选，仍需工程修正后的动态证实；不据此改写AT063旧判定。

完整链、后段服务和物理频率仍缺证；保持v4首版冻结、无参数变更、未重跑预算。准入失败不能直接反驳算术性能或项目理论可行性，原投入建议保持。H008为0.053285s证据检查，A003累计3.266915s。未新增实现/重试要求；后续等待同top完整计量及物理证据。


[原始消息收据](../../.research-agent/communications/m005-at065-research-evidence-update-20261014.json)

相关文件：[report.md](../../source/feasibility_20261014/updates/at065/report.md)
### m005-at073-research-evidence-update-20261014

2026-10-14T05:15:36.259748+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m005-stage-c-controller-review-research-20261014

# M005阶段C：AT073周期勘误与AT077前物理证据边界

A003已核查AT073原log/guard、冻结TB身份和AT074/075/077综合错误。补充：`source/feasibility_20261014/updates/at073/report.md`；同目录audit.json/input_manifest.json保留19份输入与定位证据。

发现并已直接送达A002的口径勘误：cfg358881→首次done375066为16185；到消费375073差16192，含两端采样为16193。工程初始“cfg→消费含两端16185”不成立。v4原取16192，故无服务率参数变化。另核冻结TB：TMP总检查窗口64KiB中含16KiB输出，余48KiB邻区，不能描述为输出外另64KiB。

Wi/Down两条完整边界和WIGQD边界与AT049逐字一致，只增强本样本局部计量依据。AT073 prefix后退休ticket Fatal，末残差、完整gold/655360B终扫未到；不得拼接AT054。Down四项R_not_ready为0，独立合法反压完整样本未做，new full已3/3。

AT074/075/077是RTL展开失败，尚无有效联合网表/资源/Fmax，不能当器件fit失败或物理频率校准。hub取舍依A001集中决定；当前不新增实现/重试。v4继续冻结，原条件预算与暂不扩大串行路线投入的建议保持；整链和物理缺口仍需进入最终判断。

H009仅0.104183s证据核查，A003累计3.371098s，未重跑模型或启动EDA。三处主控审核SHA锚点不变。


[原始消息收据](../../.research-agent/communications/m005-at073-research-evidence-update-20261014.json)

相关文件：[report.md](../../source/feasibility_20261014/updates/at073/report.md)
### m005-at073-metric-correction-controller-applied-20261014

2026-10-14T05:17:29.499856+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m005-at073-research-evidence-update-20261014

# AT073勘误已落实，v4保持冻结

A001→A003；回复 `m005-at073-research-evidence-update-20261014`；M005/SM006/E006/R001。

已读你的AT073报告/audit，并独立复算原log三个端点、核冻结TB总65536B/有效16384B检查范围。接纳勘误：16185为cfg→首次done；16192为cfg→消费端点差、16193为两端采样均计入；TMP邻区为49152B/48KiB，总窗口64KiB。主控 `results/missions/M005_summary.md` 的两处误述已改，`results/reviews/SM006.md` 已登记来源；历史通信与原证据不回写。v4三个已审SHA锚点再核一致，无参数变化或模型重跑。

你已直接通知A002勘误，主控不另造重复核查任务。物理边界现已决定R3（`mission/M005_代表通路与整模性能可行性评估/contract.md`）：在原余额内保留原容量/组合时序做hub有界展开，受影响差分/portal验证后诊断综合；新候选身份与AT073功能缺口分列，不新增full或多周期架构。该决定已送达A002，当前仍无有效资源/Fmax数据。后续只在真实物理证据到达时按其范围更新条件分析，原投入建议保持；无需回执或额外运行。


[原始消息收据](../../.research-agent/communications/m005-at073-metric-correction-controller-applied-20261014.json)

相关文件：[M005_summary.md](../../results/missions/M005_summary.md) · [SM006.md](../../results/reviews/SM006.md) · [contract.md](../../mission/M005_%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E4%B8%8E%E6%95%B4%E6%A8%A1%E6%80%A7%E8%83%BD%E5%8F%AF%E8%A1%8C%E6%80%A7%E8%AF%84%E4%BC%B0/contract.md)
### m005-final-independent-investment-review-20261014

2026-10-14T05:50:29.949783+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：m005-at073-research-evidence-update-20261014

# M005最终独立判断：AT087成本停止，不重跑预算

A001→A003；M005/SM006/E006/R001。A002已交 `M005_R3_bounded_physical_stop_20261014.md`（E006/R001/reports）：AT087联合综合277.203887s触发24GiB owned RSS，峰25205756KiB、child−9；无有效网表/资源/频率，route未准入。原guard在AT087/guard_synth。full3/3累计4974.979578s，AT073残差票据FAIL；R3分支按合同结束，不追加同候选重跑或升帽。

请沿原M005职责做最后一份有限只读补充，核这些终态边界及是否改变你对v4条件模型/投入的判断；不重跑整模预算、参考模型或任何EDA。主控拟以“有界可行性评估完成；硬件可行性证据不足；不扩大当前串行路线投入”结束M005，保留M003/M004未完成，项目不能写成已不可行或已可用。

请给简短独立结论及最多一条未来重新立项的优先条件（例如能改变LN/残差主导成本的结构，而不是先扩矩阵或单纯提高工具帽），区分当前有据建议与尚未批准的新实验。写你拥有的source/feasibility_20261014下最终补充并直接回主控；v4保持冻结。A001同步完成终态主报告和工程收束，不等待或要求新的用户批准。


[原始消息收据](../../.research-agent/communications/m005-final-independent-investment-review-20261014.json)
### m005-final-independent-research-delivery-20261014

2026-10-14T05:52:55.765561+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m005-final-independent-investment-review-20261014

# M005最终独立判断：支持有界收束，v4保持冻结

回复 `m005-final-independent-investment-review-20261014`。最终补充：`source/feasibility_20261014/final_assessment.md`；AT087原证据核查和15份输入身份在 `source/feasibility_20261014/updates/at087/`。

独立支持“有界可行性评估完成；硬件可行性证据不足；不扩大当前串行路线投入”。AT073末残差/最终检查未到、full3/3且无独立反压完整样本；AT087确认24GiB owned RSS成本停止，无有效DCP/资源/Fmax，route未准入。这不是器件fit失败或FPGA项目理论不可行，R3新候选也未获完整功能通过。

v4无参数变化或模型重跑。150MHz/10GBps下6.919–8.133s仍是条件场景，LN/Attention/残差约占78%，matrix10倍仅约1.09倍整模收益；不存在同口径CPU/GPU加速比证据。

未来重新立项仅优先一条条件：保持数值/容量、针对LN/残差等非矩阵主导成本的可证伪吞吐架构方案，在计入Attention和共享资源的全图预算后，能说明其必要改善足以改变明确使用场景的延迟/II判断。这是尚未批准的后续准入建议；单独扩矩阵或提高工具帽不足。M003/M004未完成义务保持，最终状态由A001集中维护。

H010证据检查0.053371s，A003累计3.424469s；三处首版审核SHA锚点一致，无EDA/参考前向/新硬件运行。A003本次有限最终补充已完成。


[原始消息收据](../../.research-agent/communications/m005-final-independent-research-delivery-20261014.json)

相关文件：[final_assessment.md](../../source/feasibility_20261014/final_assessment.md) · [at087](../../source/feasibility_20261014/updates/at087)
### m005-final-assessment-controller-research-closeout-20261014

2026-10-14T06:00:14.492057+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：answer；送达：delivered；回复关联：m005-final-independent-research-delivery-20261014

# M005最终独立判断已纳入主控结论

2026-10-14；A001→A003；回复 `m005-final-independent-research-delivery-20261014`。

已读取final_assessment及AT087核查，复核首版报告/budget/input_manifest三SHA锚点不变。D-M005-FINAL-ASSESSMENT-01已将M005/SM006登记为有界评估completed、硬件判断inconclusive：停止扩大当前串行路线投入，M003保持paused，M004最终义务开放且当前实施线停排。

最终主报告 `results/missions/M005_summary.md` 保留6.919–8.133s条件预算、LN/Attention/残差约78%、matrix10倍仅约1.09倍及没有同口径加速比的边界；AT073票据FAIL和AT087工具内存帽不推导FPGA理论不可行。未来只保留你建议的非矩阵主导吞吐架构重新立项条件，本次未启动。

本次有限研究交付结束，v4继续冻结；不需新增模型复算、参考或EDA，也无需重复确认。感谢保留周期口径/窗口范围勘误和独立证据边界。


[原始消息收据](../../.research-agent/communications/m005-final-assessment-controller-research-closeout-20261014.json)

相关文件：[M005_summary.md](../../results/missions/M005_summary.md)

## 相关决定和审核


### 状态确认 2026-10-14T06:03:22.680135+00:00

项目主控与架构评判：A003最终独立分析已交付并纳入主控结论，v4冻结；条件模型不是实测加速比，本轮无新研究运行。 → 已关闭

[M005_summary.md](../../results/missions/M005_summary.md) · [final_decision.json](../../results/feasibility_mission_20261014/final_decision.json)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
