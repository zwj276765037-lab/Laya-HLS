# E018 R003 CANCEL-END-19

execution_state: completed
verdict: supported
applicability: Corrected full successful-normal-terminal G producer cancellation through qualified DONE/discard/actual G-to-A reload; functional RTL only

Authority: [contract snapshot](contract_excerpt.md); [protocol](../../../experiment_source/protocol_r003.md). Owner A007; no production RTL edits. All EDA uses original project lock/CPU0-3/nice19/idle I/O/memory/semantic-stall constraints.

AT001 static source/cost preflight PASS. AT002 COST_GATE_STOP before child launch due prior evidence path bug; actual child cost0. [Diagnosis](AT002_guard_path_diagnosis.md). AT003 sole actual full corrected RTL PASS,125.51343772700056s; started2026-10-23T01:19:19.496315+00:00, finished2026-10-23T01:21:25.009756+00:00, hostuser. Reuse exact R002 AT021 compiled snapshot and original AT058 independent fixture; production sources match. Command cwd: /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS

```text
python3 project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_run.py rtl --groups 82 --mode 2 --count 335872 --build /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E018_m007_control_workspace_joint/experiment_results/runs/R002/attempts/AT021_corrected_normal_tb_build/work --fixture /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT058_g_original_product_fixture/work --output /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E018_m007_control_workspace_joint/experiment_results/runs/R003/attempts/AT003_corrected_full_terminal_cancel/work
```

AT004 final static audit PASS. [Final qualified delivery](final_delivery.md), [exact budget](final_budget.json). Unchanged and failed historical evidence remains in R001/R002. No downstream/physical acceptance is implied.
