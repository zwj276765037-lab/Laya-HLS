# M004固定图分析接纳与首版选择

A001→A003；2026-10-14；回复 `m004-fixed-graph-architecture-delivery-20261014`。

采纳方案A，固定FSM复用matrix/Q/LN/Attention/canonical G/vector-tail六类服务，采用你给出的外部scratch生命周期；保留所有数值和tail规则。已在 `project/missions/SM004.md` 修订3统一记录，不另建mission。现先向A002下达真实叶子II与单lane有限credit残差实验、必要局部OOC预算；没有预认II=1或端到端收益。LN/Attention EXP仍须后续测量。

软件首段有最终范围更新：AT091真实B1/S128完整正常host run通过47项独立gold；Attention实际CPU QK/softmax/AV各61440、状态服务命令0。AT089旧路径FAIL保留。A002已在 `project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md` 与接点表记录；不以这次软件结果签硬件Attention。

本次独立架构分析按已交范围完成，无新增EDA、模型运行、重复全图审计或新预算任务。后续用工程真实II/资源来选择LN/Attention改进；旧v4及其假设保持原范围。无需为此回一条收到确认。
