# E015：当前状态

- execution_state: running
- verdict: unassessed
- applicability: E015 R001 / A008 / strict fast leaf stage
- 当前阶段：三快速leaf原向量与协议逐位通过；add3小OOC setup/hold失败保留，三拍等价重分段修复。真实Encoder0全128参考已生成
- 阻塞/异常：无用户决定阻塞；下一轮图生成/build/OOC在公共重工具锁排队，不报为已执行。300MHz未达，不展开8lane综合
- 资源：独立900/1800/3000/1800s，实际费用由各AT receipt计；无旧预算转移，owned cleanup均记录
- 下一步：重分段add3数值与OOC、mul4/div12小OOC、单TANH原图数值/42节点trace/真实信用与reset；满足阶段门后再8lane/G


---
Published: 2026-10-21T07:34:13.853593+00:00
Publication: Pf97084e29e9d4bfebe56b52a990fd4bb
Execution state: running
Research verdict: unassessed
Applicability: E015 strict fast-leaf RTL vector/protocol evidence; add3 synthesis+opt timing FAIL; real local reference generated, single TANH/G not yet verified
Evidence:
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT003_add3_original_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT004_mul4_original_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT005_div12_original_vectors/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT006_add3_io_ooc/work/report.json
- project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/report.json
