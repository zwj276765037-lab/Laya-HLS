# E005当前状态

execution_state: running；verdict: inconclusive，适用于未闭合的SM005/E005与完整M004。KB1保留；KB2有据no-go；CT0有限出口；LQ1仅有时序风险的局部周期样本，LQ1R两版no-go。整体控制/恢复继续停排。

ATN0 AT020完整head正常基线限定PASS。ATN1唯一调度候选AT021正常128行gold与同口径周期限定PASS；AT022相同DUT的PROTOCOL=1 16行首错/CE/reset/新增pending-ready回放限定PASS。五段guard均child0无触发，63实际policy样本合规。工程阶段证据已交主控集中判断，当前无本项目重工具运行；后续方案待主控阶段取舍，不自动启动第二算术候选。物理资源/时序、生产请求/恢复与完整M003/M004仍未完成，原单工具/全部资源帽、G仅OOC余额保持。


---
Published: 2026-10-13T11:03:27.827852+00:00
Publication: P31e8ec7956f4460e94c2b7a7dddcbad3
Execution state: running
Research verdict: inconclusive
Applicability: ATN1 Attention单完整head正常数值/周期及同DUT 16行协议回放有限PASS；物理资源/生产请求/完整M003/M004未闭合
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_evidence_check_20261013.json
