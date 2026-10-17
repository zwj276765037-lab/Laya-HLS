# E005当前状态

execution_state: running；verdict: inconclusive，适用于SM005/E005与M003/M004整体。QAR0 AT035 static/pilot/full及冻结/资源核验已完成，限定四行正常同runtime量化→Wi→G→量化→Down数值/DDR/事务PASS，双valid G优先和两方向活动/响应等待及拒绝后释放定向RTL通过。当前无本项目重工具运行。AT034顺序样本及AT033原FAIL保留；新结果不代签一般公平性、取消/恢复、生产opcode权限、LN_FFN producer、FFN residual、全模型/完整请求、联合资源或物理时序。M003/M004仍开放；下一算术/真实连接入口由主控集中选择。原单工具/资源帽、G仅OOC余额及无新HLS/OOC/P&R/上板保持；整体executor/冷INIT/CLOSE-rearm/cleanup停排。


---
Published: 2026-10-13T17:12:15.493560+00:00
Publication: Pa801615063c14ecf807024ad7341c6d3
Execution state: running
Research verdict: inconclusive
Applicability: QAR0 AT035 B1/S128四行normal共享量化入口定向竞争及完整Wi→G→Down RTL数值/DDR/事务有限PASS；M003/M004整体未完成
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/QAR0_shared_quant_admission_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/raw_full.log
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT035_QAR0_shared_admission_01/verification.json
