# R001 — E017 SFU最小测量

Execution state: completed
Verdict: inconclusive

实际范围：原32×32→50/64 helper独立RTL及完整IO OOC；原F64mul六文件finite-native RTL；底向上AT011/分阶段parent-only AT012成本出口。当前无EDA/排锁任务，AT013未创建。

复现入口：E002/experiment/vivado/module_design/attention_and_fp_engine/tb/m007_sfu_measure_run.py与m007_sfu_f64_run.py。每实际AT有frozen/source_manifest/command/guard/receipt。AT007单独prelaunch_failure，无伪造guard。

平台：Vivado2025.2，xcu55c-fsvh2892-2L-e，完整IO nominal300MHz/实际300.030MHz，OOC synth+opt，无P&R。独立整数Python与原AT005同域native binary64 RNE；拒绝FTZ/DAZ。

起止与完整命令/退出见每AT guard与command，资源费用见budget_ledger.json。结论/版本边界/未验证范围见final_delivery.md/.json；终态检查见final_evidence_audit.json。无生产修改。
