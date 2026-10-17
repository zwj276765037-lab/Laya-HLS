# E005当前状态

execution_state: running；verdict: inconclusive，适用于仍未闭合的SM005/E005与M003/M004。WIGQD0本轮已按合同上界有界收束：AT029静态FAIL，AT030/031 static/pilot PASS但full均COST_STOP；AT031已证同runtime Wi输出、实际Wi有效区字节读回、最后B/lease/done消费，G命令接受后120s无新标记被保护器停止。Wi reader→G→量化→Down完整出口、最终哨兵/整链周期未取得；不判DUT死锁，也不拼接独立WI0/GQD0 PASS。当前无本项目重工具运行，第三版停排，下一步向主控提交实质阻塞与已到达边界作集中判断。KB1、ATN1、GQD0、WI0原限定事实保留，整体executor/冷INIT/CLOSE-rearm和恢复扩展仍停排。原单工具/全部帽及无新HLS/OOC/P&R/上板不变。


---
Published: 2026-10-13T13:57:32.516260+00:00
Publication: P48b1c4428ba543d9a6702abbbe9862a2
Execution state: running
Research verdict: inconclusive
Applicability: WIGQD0 AT031同runtime Wi子段正常数值/DDR有效区读回有限通过；G→量化→Down完整链COST_STOP，整链结论未取得
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_bounded_stop_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_connection_map_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/WIGQD0_identity_audit_20261013.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT029_WIGQD0_chain_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT030_WIGQD0_chain_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT031_WIGQD0_chain_03/raw_full.log
