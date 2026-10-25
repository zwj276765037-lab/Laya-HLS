# E021：D37 当前实际结果

execution_state: running
verdict: unassessed
applicability: R005静态构建进行中；修复版完整30层尚未运行

AT001参数0翻译PASS48.089340662s。实际741TU/268154798B/max3099486B，满足原741TU/268284937B的1.15倍规模门；生成代码保留原once-BEGIN完整覆盖checker与FULLGRAPH终标，不含SEGMENTED_SUFFIX终标或入口展开。root/Syms头与旧参数1不同，模型对象全部fresh。完整driver原实际组件回放及合并Encoder27→finalLN→type→Decision0preLN整段保护验证PASS；synthetic只验证观察器，不是新RTL结果。

只读main派生成功61.398219224s；两次先行静态预检失败（生成优化别名、原printf格式断言）已保留，未测耗时UNKNOWN且不填0。当前fresh构建进行中，没有新RTL pilot或完整运行。证据：R005/attempts/AT001_fixed_original30_build/receipt_translate.json、generated_scale_gate.json、actual_full_parameter_expansion.json、fresh_model_build_policy.json；R005/driver_validation.json及bridge_validation.json。


---
Published: 2026-10-24T13:29:22.354284+00:00
Publication: Pc9540ad7c435436288db0e5d3a2a980c
