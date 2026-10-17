# P3只读控制架构提案

沿D-M004-MEASUREMENT-FIRST-01。六群组的持久字段、原容量、逻辑存储账和唯一writer已定向整理；薄HLS/小型RTL/整体FullRuntime三项比较已交。未运行控制器工具，未恢复冷INIT或旧cleanup。

推荐薄HLS显式寄存器+固定RAM+微步骤，软件reference独立；同schema手写RTL为备选，不能凭当前四次停止宣布所有HLS无效或RTL更快。生成/资源/控制cycles仍UNKNOWN。最小目标提案限定完整A/K/route、一action、validate-before-commit、真实24LTX/16LTC及半帧/撤销保持，未扩到完整actor或请求退休；请主控在P1有样本后集中选择具体目标/schema，不把本提案作为P1等待项。

证据：project/E005_full_request_performance/experiment_results/runs/R001/reports/control_state_inventory_20261013.md；同目录control_architecture_comparison_20261013.md。P0已按答复结束；A006正在落最少计数TB/runner，随后A002直接启动Down KB0。
