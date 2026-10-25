# E015：当前状态

- execution_state: running
- verdict: unassessed
- applicability: 原leaf数值及小综合+opt；原128行局部参考；单lane16384输入/42节点与真实协议通过，完整输入/8lane/G未验证
- 当前阶段：新checked-consume observer/guard v3已冻结，新同版16384中样PASS，AT039完整成本门等待公共锁；AT034从未启动
- 时序边界：mul4/radix4div12 setup正；add3_o setup−0.161仍FAIL，全部hold未闭合，无P&R。三拍add3_e按实际首段路径准备，尚未验证
- 保护：独立120秒真实消费停滞与全局墙钟/RSS/费用/后代回收共同约束。旧AT032/033/035/v1/v2保留不追改
- 资源：reference900/static1800/RTL3000/OOC1800秒，逐AT receipt计；锁等待不计child，没有加帽或借旧余额
- 下一步：新成本门后自动完整336262输入；继而add3_e原/定向数值和同约束小OOC，再继续授权8lane/G


---
Published: 2026-10-21T09:12:27.320580+00:00
Publication: Pd197665a8c614275b8437dc7426fa3da
Execution state: running
Research verdict: unassessed
Applicability: Original fast leaf vectors and small synthesis+opt;16384-input42-node single-lane functional/protocol PASS under new v3 consumed-event observer; add setup/all hold FAIL; complete input/8lane/G/PnR NOT_RUN
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
