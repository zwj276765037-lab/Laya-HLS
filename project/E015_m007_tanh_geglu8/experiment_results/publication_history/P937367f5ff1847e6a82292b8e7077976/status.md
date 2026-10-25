# E015：当前状态

- execution_state: running
- verdict: unassessed
- applicability: strict fast leaf RTL and small synthesis/opt only; real local reference generated
- 当前阶段：mul4 setup正但hold未过；add3重分段改善0.605ns仍FAIL，div12串行商位FAIL；独立early-zero/radix4等价新叶排队。固定AT009源码的AT014数值也在公共锁等候
- 当前资源：A007完整16head正在持重工具锁；E015等待不冒充执行/费用。独立预算由receipt逐AT扣账，所有已完成cleanup无owned遗留
- 下一步：当前add数值→新变体原向量→同版小OOC→单TANH42节点/主例/信用/reset；阶段门前不展开8lane物理或声称300MHz
- 异常保留：AT001 FAIL、AT006/011/012时序FAIL；AT015等待取消有queue_cancellation.json。原数据/接口/gold与其他owner源未改


---
Published: 2026-10-21T07:51:39.027482+00:00
Publication: Pb80aa23e66a84452ab30869eddca3b58
Execution state: running
Research verdict: unassessed
Applicability: E015 strict leaf RTL vectors and small synthesis+opt timing; add/div timing FAIL retained, new variants queued, single-lane/G not yet verified
Evidence:
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT010_mul4_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT011_div12_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT012_add3_repartition_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT015_single_tanh_lane_build/queue_cancellation.json
