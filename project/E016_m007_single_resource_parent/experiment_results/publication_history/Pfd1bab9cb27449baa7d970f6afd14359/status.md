# E016/R003 当前执行

execution_state: running
verdict: unassessed

AT005同完整snapshot QKV3 PASS；AT006真实第二head pilot正在实际运行，≤1200s，strict数字进度/共享重工具锁有效。head2 PASS之后才计算固定E=1.10*(P2+14*Hmax+Q)+10；E≤3600且剩余≥E+600才自动一次full。未到阶段不预填结果。

期望gpt-6.1-sol/xhigh、实际UNKNOWN；无旧预算转移。闭合费用（不含在途AT006）：{"reference": 0.0, "static": 91.70283803896746, "rtl": 55.360977704986, "ooc": 0.0}。

---
Published: 2026-10-22T12:24:22.768499+00:00
Publication: Pedc98174ef6342f199a07c48f5e25027
Execution state: running
Research verdict: unassessed
Applicability: AT004 exact full-checker build and AT005 actual same-snapshot QKV3; AT006 second-head pilot active, full NOT_RUN
Evidence:
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT001_full_checker_frozen_build/receipt_static.json
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT002_full_checker_syntax_fix_build/receipt_static.json
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT002_full_checker_syntax_fix_build/source_control_audit.json
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT003_same_snapshot_qkv3/receipt_rtl.json
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT004_explicit_TB_branches_build/receipt_static.json
- project/E016_m007_single_resource_parent/experiment_results/runs/R003/attempts/AT005_explicit_TB_branch_qkv3/receipt_rtl.json
