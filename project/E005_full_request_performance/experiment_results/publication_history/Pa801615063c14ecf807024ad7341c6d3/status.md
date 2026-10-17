# E005当前状态

execution_state: running；verdict: inconclusive，适用于SM005/E005与M003/M004整体。QWIGQD0 AT034已完成同runtime四行正常LN_FFN外部F32→真实Q→Wi→G→同Q→Down的static/pilot/full，限定RTL数值、DDR、末B/lease及完成PASS，待主控集中审核。AT033 full TB计数断言FAIL原样保留；AT034仅修受影响TB/runner。当前本项目无重工具运行。LN_FFN producer、FFN residual、完整请求/13BO/全模型122矩阵、错误恢复、联合资源/物理时序及上板仍未验。整体executor/冷INIT/CLOSE-rearm/cleanup停排；原单工具/资源帽、G仅OOC余额及无新HLS/OOC/P&R/上板保持。下一步由主控依据本结果选择后续算术/连接阶段；M003/M004不得关闭。

---
Published: 2026-10-13T16:18:11.984064+00:00
Publication: P66d2d8f535044cddb9dfca73f649cba6
Execution state: running
Research verdict: inconclusive
Applicability: QWIGQD0 AT034 B1/S128四行normal LN_FFN外部F32真实量化→Wi→G→同量化器→Down RTL数值/DDR/事务有限PASS；M003/M004完整目标未完成
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_integration_result_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/QWIGQD0_connection_map_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/raw_full.log
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/verification.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT034_QWIGQD0_chain_02/source_identity_check.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT033_QWIGQD0_chain_01/receipt.json
