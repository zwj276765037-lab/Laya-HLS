# E005当前状态

execution_state: running；verdict: inconclusive，适用于未闭合的SM005/E005及完整M004。KB1保留，KB2有据no-go，CT0有限出口收束。LQ0 AT014基线和LQ1 AT015/AT016原16行数值/周期限定PASS；LQ1全冷周期减少19.8726%，但HLS估计slack−48.76ns，物理时序/联合资源UNKNOWN。

LQ1R AT017/AT018是本阶段全部两版有据时序修复：均主机对照/HLS生成PASS，实际注册浮点IP已映射，但top估计slack−0.43/−0.41ns；按合同未启动RTL、F9回放或第三版，方向no-go。等待主控集中选择下一算术/集成入口；无本项目重工具运行。完整M003/M004、继承错误窗口、恢复与全模型仍未完成。单重工具及原资源帽/G仅OOC余额保持。

---
Published: 2026-10-13T09:43:33.575487+00:00
Publication: Pab9924a13d784a47a5f749fca9932c45
Execution state: running
Research verdict: inconclusive
Applicability: KB1四行Down有限PASS；KB2无有效full；CT0原32项owner表诊断有限PASS；LQ0/LQ1冻结16行LN→store→Q/fullA有限PASS；LQ1R两版HLS估计违例、RTL未运行；完整M003/M004未闭合
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1R_timing_no_go_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LQ1_pipeline_comparison_20261013.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT017_LQ1R_LN_hls_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT018_LQ1R_LN_hls_02/work/reports/hls_compile.rpt
