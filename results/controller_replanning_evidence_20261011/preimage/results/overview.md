# Laya-HLS 当前概览

**复制搭建完成；完整加速器尚未验收。** 本项目按research-agent原生结构管理，原baseline完整保留。工程副本在[project/E002_Laya_HLS/experiment](../project/E002_Laya_HLS/experiment/)，新对话入口[NEW_CHAT_START](../NEW_CHAT_START.md)。

| 范围 | 当前结论 | 证据/限制 |
| --- | --- | --- |
| E001完整工程复制 | PASS_COPY_VERIFIED | 210038个普通文件双侧SHA一致，6100个links映射副本，源未删改；[收据](../project/E001_baseline_import/experiment_results/runs/R001/copy_receipt.json) |
| 旧稳定身份完整CPU/CSim | PASS_SCOPED | build23c62cd4，四持久请求、141点/18,094,384 F32与故障恢复；非新working源整图硬件 |
| 模块RTL/局部连接/OOC | 多项范围PASS，失败与成本中止保留 | [当前阶段终态](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/stage_results.md)；不直接相加外推整图 |
| 当前13BO生产接入、同runtime全图RTL | 未验收/未验证 | 接口§3.9已定义，E002新项目未运行 |
| 全局资源fit、P&R/Fmax、U55C/XRT/HBM/板端性能 | 未验证 | 尚无板卡，150MHz仅条件预算 |

目标是正确完整推理、可核实吞吐改善及部署资源预算，50ms不是唯一硬门槛。CPU token Embedding与固定权重一次校验；FPGA后续全部LN/动态量化/Q8/Attention/向量/Decision。模块数值、完整最终决策、数据集准确率分别判断。

M001/SM001完成，M002/SM002计划待新对话恢复。A001–A003仅登记未启动，实际模型/线程为空，无新硬件工具运行。用户已取消逐轮人工审核，当前无需用户新增决策。下一步是按SM002优先接实际生产闭包和稳定身份回归，不无限扩展非关键诊断。
