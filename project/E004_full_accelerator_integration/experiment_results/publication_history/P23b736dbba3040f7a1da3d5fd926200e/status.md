# E004：状态

execution_state: running；verdict: unassessed（完整M004加速器）；applicability: AT091当前软件正常全图请求，以及AT093/097/098/099冻结向量局部RTL/OOC身份。SM004向量局部阶段已实际完成：精确ADD流、4096项双源残差短测和一次同版局部OOC；A002工具队列当前空闲。AT094旧AWBURST宽度warning、AT095纯准备错误、AT096 W反压未命中均保留原限度，最终受影响TB为AT097。host冻结/转换未作独立owned RSS/policy采样，该计量缺口不补签。下一步A001按固定图六服务合同集中确定LN/Attention/矩阵/tail受影响连接与预算，A002继续同M004实现；软件PASS与向量局部PASS不代表整图硬件或加速收益。

---
Published: 2026-10-14T15:15:37.235968+00:00
Publication: P450d2ef0e98242728634382e683b0447
Execution state: running
Research verdict: unassessed
Applicability: 当前软件B1/S128正常请求和冻结向量单lane/残差服务局部样本；不适用于完整硬件推理或物理Fmax
Evidence:
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md
- project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_evidence_20261014.json
