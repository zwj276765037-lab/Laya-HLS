# E005当前状态

execution_state: running；verdict: inconclusive，适用于未闭合的SM005/E005总任务。KB0/KB1有限PASS、KB2无有效full且按规则停止、CT0有限host/HLS/generated RTL PASS均保留。LQ0 AT014 16行真实LN→store→Q/fullA数值与计量有限PASS；AT013首版观察口径不足保留，AT014修正后重跑。LQ1 AT015单LN CSim/HLS当前运行，生成/行为/收益均未核定。

下一步串行核LQ1生成是否真实形成流水与资源，再按同冻结输入/gold/AXI策略做有限RTL A/B判断。M003/M004完整请求、恢复及联合物理资源仍未完成。单重工具、CPU0–3/nice19/idle I/O/MemAvailable门及原分类帽保持；G2338.224019s仅OOC余额，5172s不重启，无新OOC/P&R/上板/预算。


---
Published: 2026-10-13T08:50:43.218383+00:00
Publication: Pf828a15184894f0fa0c9f9fb964d5f1b
Execution state: running
Research verdict: inconclusive
Applicability: KB0/KB1四行Down有限PASS；KB2无有效full；CT0原32项owner表诊断有限PASS；LQ0冻结16行LN→store→Q/fullA有限PASS；LQ1运行中，完整M003/M004未闭合
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/KB0_KB1_Down_comparison_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/KB2_two64_no_go_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/CT0_owner_table_scoped_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/CT0_owner_table_verification_20261013.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT006_CT0_owner_table_hls_03/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT012_CT0_owner_table_rtl_06/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ0_measurement_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT014_LQ0_measurement_02/receipt.json
