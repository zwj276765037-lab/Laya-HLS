

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# E006 · feasibility_assessment

关联：M005 / SM006

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

# E006 关键结果摘要

AT073最后正常full在cycle375074完成LN/Q/Wi/G/Down前缀、Down 256 AW/W/B及TMP 64KiB总检查窗口（16KiB有效写入/gold、48KiB未写哨兵），随后Down→残差票据断言Fatal；残差、HIDDEN和655360B终扫未达。cfg358881→首次done375066端点差16185cycle；至实际消费375073端点差16192cycle，两端采样计入16193cycle。3/3 full累计4974.979578s，独立合法反压完整样本未做。阶段C v4原用16192，无数值重估。

R3受影响有限验证：AT079冻结旧/新几何函数140个已知输入一致、无效count/未知role不成功；AT080真实portal原回归与重叠BEGIN拒绝PASS；AT082 store monitor短测3097cycle PASS；AT085旧/新half解码全部65536输入逐bit一致。AT081/083仍遇下一处展开错误；AT086被综合静默误作120s语义停滞停止。AT087同版RTL/IP/ROM/XDC修正综合守卫后，277.203887s达到24GiB owned RSS上限（峰25,205,756KiB）、child−9，无有效DCP、联合资源/时序报告。综合累计685.210200s/3600s；route 0s，因无有效网表未准入。短测上界283.855331s/600s、static上界1335.673109s/5400s；host历史执行时间UNKNOWN。详见M005_R3_bounded_physical_stop_20261014.md和M005_budget_ledger_after_AT087_20261014.json。

当前组合候选未在给定24GiB综合内存帽内取得可评估网表；不能据此判U55C或其它架构整体不可行，也没有真实LUT/FF/DSP/BRAM/URAM/Fmax、完整链时延、对照加速比或板端性能。A003的150MHz/10GBps下6.919–8.133s仍是条件模型，不是本项目完成服务实测。

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 24 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
