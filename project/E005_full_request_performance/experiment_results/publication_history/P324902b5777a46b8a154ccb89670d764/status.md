# E005当前状态

execution_state: running（工程会话可继续；LNQ1本阶段一次full已停止，当前无重工具）；verdict: inconclusive，适用于SM005/E005整体。AT048两份被动TB观测源static PASS；唯一full在真实LN source AR前因7份冻结LN ROM `.dat`未放入新xsim工作目录，guard semantic_stall/child−9，COST_STOP_INVALID_RUNTIME_ROM_STAGING。没有新END/PUBLISH观察值、外部Q或Wi/G/Down结果；不能据此判断观测修复是否有效或DUT死锁。AT047发布后TB语义FAIL仍按旧证据保留。

本合同一次full额度已用尽，未补AT048运行目录、未启动第二次。已向主控集中交付，建议后继若另立有界合同，先做启动前ROM放置/逐SHA核验，再判断是否准入。AT040/AT035/AT044独立有限结果保留，不能拼接为联合PASS。无新HLS/OOC/P&R/上板；完整请求、普通Q/L多窗口、恢复、联合资源及物理时序和M003/M004仍未完成。

Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_bounded_runtime_setup_stop_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/missing_dat_audit.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/guard_full/driver.log


---
Published: 2026-10-13T20:08:59.361795+00:00
Publication: P93e615be4d7e498eba07cc4459ce30e5
Execution state: running
Research verdict: inconclusive
Applicability: AT048仅TB观察静态编译PASS；唯一full缺7份运行时ROM而COST_STOP，LNQ1新观察及LN→Q→Wi→G→Q→Down仍NOT_RUN；M003/M004开放
Evidence:
- project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ1_bounded_runtime_setup_stop_20261014.md
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/receipt.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/missing_dat_audit.json
- project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT048_LNQ1_observation_01/guard_full/driver.log
