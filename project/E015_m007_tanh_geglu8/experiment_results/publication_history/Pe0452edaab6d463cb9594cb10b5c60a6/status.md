# E015：当前状态

- execution_state: running
- verdict: unassessed
- applicability: add3_e/mul4/radix4div12三个小leaf综合setup正且独立数值通过；当前完整单lane336262输入/42节点/153拍II1与协议PASS；全部hold/P&R和8lane/G/联合物理未验
- 当前阶段：AT049完整新leaf单lane完成；AT051八lane首pilot因TB组合ready采样导致额外真实接受、最终计数FAIL，修正后AT052重编译排队；未删用例/放宽断言，旧原件保留
- 时序边界：AT044 add3_e setup+0.098/0失败，hold−0.043/78失败；mul/div小setup正而hold仍失败；无P&R或物理300MHz
- 保护：冻结v3独立120秒真实消费停滞、总墙钟/RSS/预算/后代回收；AT049真实86事件、最长gap8.075176s、零残留。旧v2/AT034未运行边界保持
- 容量：8lane准备代码只有一个vector credit；tag/mask3328B、位图32B及其他metadata/流水真实位数另列，未签父联合4KiB
- 下一步：八lane原输入/42节点、lease拒绝/信用/held/错误/外部排债/reset实证与同版成本门；随后纯G唯一银行及全域rank，不更改共享owner边界


---
Published: 2026-10-21T09:56:10.389908+00:00
Publication: P25b036d388484d7b9f6636a0917984dc
Execution state: running
Research verdict: unassessed
Applicability: Current add3_e/mul4/radix4div12 small synthesis+opt setup positive; full336262-input original42-node single-lane functional/protocol PASS153cycles/II1; all hold/PnR/eightlane/G/combined resource limits remain open
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
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT042_add3_exponent_align_original_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT043_add3_exponent_align_directed_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT044_add3_exponent_align_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT046_single_tanh_setup_positive_build/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT047_single_tanh_setup_positive_16384_pilot/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT049_single_tanh_setup_positive_complete/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/cost_scope_metadata_note.md
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT050_tanh8_setup_positive_build/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT051_tanh8_32768_original_pilot/receipt.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT051_tanh8_32768_original_pilot/stdout.log
