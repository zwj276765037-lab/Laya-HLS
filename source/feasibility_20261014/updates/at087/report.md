# AT087成本停止：阶段C最终物理证据边界

2026-10-14；A003；M005/SM006/E006/R001。关联工程 `m005-at087-research-physical-boundary-20261014` 与主控最终独立判断请求。

**AT087确认的是本候选在24GiB主机综合内存限额内未取得可评估网表。未获得资源或时序数据，v4的频率与服务参数保持条件假设。**

只读核原guard/plan/trigger/log：elapsed277.203887s、child−9，触发`owned_rss_at_or_above_limit`；上限25165824KiB，峰25205756KiB，系统最低MemAvailable408212128KiB仍高于准入下限。它是owned进程RSS限制，不是系统内存耗尽，也不是FPGA的LUT/BRAM/URAM容量判定。日志没有综合ERROR或实际完成标记；按冻结Tcl指定位置逐项确认`representative_synth.dcp`、两份utilization和`timing_synth.rpt`均不存在。资源、关键路径/Fmax保持UNKNOWN，route未准入。

冻结top及综合Tcl的SHA/bytes与本次input_manifest对应条目一致。新top SHA为`dc1be2563a2db3c84fd9f0df9b5f584dcb0553668b6210da30c221cbb63b7959`。其hub、store monitor、half解码有受影响实现修订；AT079/080/082/085的局部验证沿A002已限定范围，本轮未冒称重验全部源/IP/ROM或重新验证那些功能。候选身份与AT073分开；不能从局部等价检查推导完整FFN或稳定性通过。综合日志中的局部裁剪警告也没有有效最终网表可供归因，不能据此签定无关键裁剪或认定内存增长全部由hub导致。

AT073仍在Down→残差票据检查Fatal；末残差、HIDDEN、完整gold/655360B保护终扫未到，独立合法反压完整样本未做。工程账的full3/3、4974.979578s，综合685.210200s及route0s均保留各自范围；未用完的综合墙钟不撤销本次资源停点或允许同候选自动重跑。R3按合同结束。

本次15份输入、SHA、原命令/守卫和缺失产物路径见[input_manifest.json](input_manifest.json)、[audit.json](audit.json)。首版三个主控审核SHA锚点一致，v4未改、未重跑整模预算。H010仅0.053371s、exit0、无分析guard触发，A003累计H001–H010为3.424469s；单次RSS采样不宣称捕获完整峰值，child rusage等见[H010回执](../../host_runs/H010.json)，idle I/O独立采样仍UNKNOWN。

最终独立投入判断见[final_assessment.md](../../final_assessment.md)。没有运行EDA、参考前向、GPU或新的硬件尝试。
