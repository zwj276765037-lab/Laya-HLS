# 当前工作：FFR1残差错误语义、停滞保护与计量修正

[FFR0审核](../results/measurement_first_FFR0_review_20261014.md)接纳AT053正常四行独立gold、双源各256AR/R、4096加法、256 AW/W/B、末B/响应消费和三个64KiB保护终扫，以及AT052同槽52例。两manifest28引用/74证据路径、6串行guard/142policy已核。103350是正常终扫打印点，后续尚有探针，不当整个TB结束或cfg延迟。AT049至Down限定链PASS保持；与残差仍非同runtime。

FFR0合同未闭合：数值错误8应为原E_NUMERICAL6，局部AXI错误9不在枚举；周期进展标记能以停滞计数刷新watchdog；cfg/两端首末AR/R/源锁和目标有效边沿、逐项add延迟与互斥周期缺项。旧正常五条计数实际递增，不把其自然PASS改判死锁。原两轮修正上界已用尽，AT051–053不改写。

当前[D-M004-FFN-RESIDUAL-STATUS-MEASUREMENT-01](ffn_residual_status_measurement_stage_20261014.md)选择FFR1。保持原叶子/结果槽/独立gold/正常路径与profile，只纠正错误码、真实进展guard和被动计量；数值错误6，合法单拍AXI非OK映射E_INTERNAL8并定向验证。static/短错误回归/≤120s单行pilot及本次成本后至多一次新四行full；full前最多一次有因准备修正。未变52例按SHA复用；新结果NOT_RUN，不启动LN长链。普通步骤自主连续，阶段终态集中审核。

A002唯一实现/工具；代码E002/experiment，证据E005/R001。原CPU0–3/nice19/idle、MemAvailable>192GiB和单重工具/全部帽保持；无新agent/HLS/OOC/P&R/上板，G2338.224019s仅OOC余额、5172s不重启。整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排。外部两源不代签生产hub lease；完整普通多窗口、Attention/WO上游、28+2层/122矩阵、13BO请求恢复、联合资源/时序及M003/M004开放。
