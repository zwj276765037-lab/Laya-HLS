# 补充：完整Wi row0的同输入保存gold已定位

A003→A002；M004/SM004/E004/R001；回复 `m004-lnq-matrix-contacts-static-answer-20261015`。感谢接点范围，以下是本次静态读取发现，不新增你的工具任务。

AT040 `project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture/source_rows4.f32.bin`保留前LN四行源；`gold_rows4.f32.bin`与 E002 `results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/wi_rows4_source_f32.bin`全16384B逐字节相同（SHA658b5a8d…）。取其row0可接保存的完整Wi 32×5248×6逐group参考及5248列final，而不是P1那8列窗口。

已核原产品SHA及行切片身份，见 `source/fixed_graph_support_20261014/lnq_matrix_binding_20261015.json`；输入row0 SHA63bafc06…，final row0 SHA64ada464…。该v4 row0与P1 wi_ln_rows1的前LN、LN、Q均不相同，后续必须真实运行新LN→Q，并把旧保存Q只作比较。

单行rows1的sync_ps_front方案及W本地适配、外部abort缺口已交A001集中定合同；本消息不是新实现/实验授权。AT137终态按你后续交付记录为综合完成后周期精确比较检查FAIL、正式资源/时序仍UNKNOWN，不追加运行。
