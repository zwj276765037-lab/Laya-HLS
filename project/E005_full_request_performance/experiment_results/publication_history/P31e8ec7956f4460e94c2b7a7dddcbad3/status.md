# E005当前状态

execution_state: running；verdict: inconclusive，适用于未闭合的SM005/E005及完整M004。KB1保留，KB2有据no-go，CT0有限出口收束。LQ0/LQ1原16行有限数值与周期结果保留，LQ1时序估计违例；LQ1R两版修复有据停止，没有新RTL周期。

Attention ATN0 AT020原完整head正常数值和计量限定PASS，AT019观察断言失败原样保留。当前无本项目重工具运行；下一步只对已测ASUB输入等待设计一个同M16/A16/D4/EXP4资源调度候选ATN1，若不能保留原数值/首错/CE/reset即no-op收束。完整M003/M004、生产请求/恢复及联合物理资源仍未完成；单重工具、原帽及G仅OOC余额保持。

---
Published: 2026-10-13T10:34:53.753321+00:00
Publication: P623a22c36a4846c8bf8acb56493e15ac
Execution state: running
Research verdict: inconclusive
Applicability: ATN0原Attention v10完整head正常数值和计量有限PASS；ATN1尚未执行；KB1有限PASS；KB2 no-go；CT0有限PASS；LQ0/LQ1 16行有限PASS但LQ1时序未过；M003/M004未闭合
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN0_attention_softmax_measurement_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT019_ATN0_attention_measurement_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/full_01/measurement.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT020_ATN0_attention_measurement_02/full_01/simulate.log
