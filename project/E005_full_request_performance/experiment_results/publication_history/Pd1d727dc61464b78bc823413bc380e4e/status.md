# E005当前状态

execution_state: running（工程会话继续；当前无本项目重工具）；verdict: inconclusive，适用于SM005/E005与M003/M004整体。LNF0 AT040四行normal baseline LN_FFN真实store→原Q/fullA已完成限定RTL PASS：原独立LN/q/scale gold、真实AXI写读/末B、END/发布、响应保持/lease释放、本地目的有效区及邻接保护区终检通过。AT039 END layer字段错误pilot FAIL保留；AT040仅修fixture descriptor后static/pilot/full PASS。新全冷TB170031cycles；不是与旧16行LQ0同口径性能A/B，也不是与AT035 QAR0长链同runtime接通。

下一步由主控集中审核和选择LN→QAR0真实连接；本轮不自行启动第二长链。上游Attention/WO/residual硬件、FFN residual、全模型/生产请求/恢复、联合资源和物理时序未验证。M003生产控制新增工作及整体executor/冷INIT/CLOSE-rearm/cleanup仍停排；G仅OOC余额2338.224019s、5172s组合不重启，无新HLS/OOC/P&R/上板/预算。

Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/verification.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT039_LNF0_ffn4_01/receipt.json


---
Published: 2026-10-13T18:12:09.644611+00:00
Publication: P988d5e7b20de407085d01dcd7d622335
Execution state: running
Research verdict: inconclusive
Applicability: AT040正常四行LN_FFN真实store→Q/fullA模块RTL已通过；E005/M003/M004整体未完成
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LNF0_four_row_rtl_result_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/verification.json
