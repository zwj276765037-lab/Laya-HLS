# E015：当前状态

- execution_state: running
- verdict: unassessed
- applicability: 完整336262输入单TANH/42节点/153拍II1与真实协议通过；原leaf数值和小综合+opt；8lane/G/物理未验证
- 当前阶段：AT040完整单lane功能完成，AT041 disjoint add3_e候选编译排队；按AT031真实首段fraction→对阶关键路径继续3拍等价修复
- 时序边界：mul4/radix4div12 setup正；add3_o setup−0.161仍FAIL，全部hold未闭合，无P&R
- 保护：冻结v3独立120秒真实消费停滞、总墙钟/RSS/费用/后代回收；AT040真实86事件、最大gap8.377783s及零残留。AT034从未启动，旧v2成本门不追改
- 资源：reference900/static1800/RTL3000/OOC1800秒，逐AT receipt计；等待锁不计child，没有加帽或借旧余额
- 下一步：add3_e原191904与独立3888边界数值、同约束小OOC；然后继续授权8lane/G，保留单lane版本与全部物理限制


---
Published: 2026-10-21T09:17:34.824406+00:00
Publication: P6dfcc2b47efe4c2bacb408d48517fd27
Execution state: running
Research verdict: unassessed
Applicability: Complete336262-input single-lane42-node functional/protocol PASS,153-cycle actual consumption/II1; add setup and all leaf hold violations remain;8lane/G/combined physical NOT_RUN
Evidence:
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT018_original_tanh_native_node_reference/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT021_div12_radix4_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT029_add3_overflow_original_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT030_add3_overflow_directed_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT031_add3_overflow_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT032_single_tanh_16384_cost_pilot/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT036_semantic_stall_guard_unit/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT037_single_tanh_semantic_observer_build/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT038_single_tanh_semantic_16384_pilot/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/guard_identity_boundary.md
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/frozen_guard_v3_identity.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT039_single_tanh_semantic_full_cost_gate/work/cost_plan.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT040_single_tanh_complete_original_v3/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT040_single_tanh_complete_original_v3/receipt.json
