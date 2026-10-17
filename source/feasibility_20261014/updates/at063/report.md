# AT063 后续证据核查：前缀一致，全链计量仍缺失

2026-10-14；A003；M005/SM006/E006/R001。关联工程消息 `m005-at063-stage-c-update-20261014`。这是首版后的证据补充，首版 `report.md`、`v4/`、`v4_replay/` 保持冻结；没有重新运行整模预算。

**结论：AT063 为 `COST_STOP_SEMANTIC_STALL_AFTER_DOWN_W_LOAD`。可补强真实前缀的事务/周期观察，不能替代完整代表链测量；v4 数值参数不变。** 原 `result_full.json` 是 FAIL；guard 在 2080.298887s 后以 semantic_stall 终止 child（−9），距最后认可进展 120.092913s，峰 RSS 1036164KiB。终止本身不证明数值错误或 DUT 死锁。

独立核查原始 driver、guard、trigger、result 和工程报告，共冻结10份有界输入（含比较日志、通信、审核和脚本），见 [输入身份](input_manifest.json) 与 [机读核查](audit.json)。原路径由 manifest 保留，日志行号随选定证据保存。

| 本次可确认观察 | 数值与边界 |
| --- | --- |
| Wi cfg→首次 done / 消费 | 224172→271082 / 271089，即46910 / 46917cycle；完成记录271090 |
| Wi reader | 四个 row-edge 各328个R、5248个scalar，合1312 R / 20992 scalar |
| G issue/return/emit | 各10496；是算术计数，不能再当额外串行耗时 |
| GATE写与第二次Q读 | AW/W/B各656，Q读656 R、328 scale组 |
| 第二次 A | 发布事件331802；ready观察331815，相差13cycle，是不同观测口径 |
| Down W | q0/q1/scale物理R为20992/20992/2624；358880发布 |
| 终态缺口 | Down cfg/实写、末残差、完整gold和保护终扫未到；全链cycle UNKNOWN |

Wi完整边界记录、第二次A发布事件、A-ready观察和Down W发布这四条日志，与AT049相应观察逐字一致。这只说明所列前缀观察一致，不证明两个runtime或源码完全等价，也不允许拼接AT049 Down、AT054残差补全AT063。第二次Q依然保留事件与观察的边界区别；不把331815回填成331802的发布事件。

`FFN1_PROGRESS` 是组合语义进度：例如wiread=1336不是1312个物理R、wicons=20996不是20992个scalar、gwr=1968不是1968次GATE写，不能将这些组合值逐项加到流量中。最后日志cycle358880不是精确停止周期、全链耗时或可推广的设备性能。稀疏进度日志也没有给出新的精确GATE最后B时间，故不从该样本改写原G服务参数。

对可行性判断的影响：代表链稳定完成这一前提仍缺证，联合top/综合/route按工程消息仍NOT_RUN。首版150MHz/10GBps等假设下6.919–8.133s的条件模型没有获得完整链或物理背书；本次也没有新增足以推翻该条件核算的服务率。维持“先完成原授权代表核正确性和物理评估、暂不扩大当前串行路线投入”的建议。故障定位与受影响修正仍由A002在现M005合同内负责。

新增主机作业仅H007，实际0.053426s，exit0、无guard trigger；累计H001–H007为3.213630s，CPU0–3/nice19有采样，idle I/O独立采样仍UNKNOWN。单个极短采样的RSS不能视为捕获了全程峰值，另保留child rusage。见 [H007原始回执](../../host_runs/H007.json)。没有执行EDA、参考前向、GPU或新硬件尝试。首版报告/budget/input_manifest三个主控已审核SHA锚点核对不变；这是证据核查通过，非硬件通过。
