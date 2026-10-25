

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E018 / R003 运行结果

[负责人维护的本批运行记录](run.md)

# E018 R003 CANCEL-END-19

execution_state: completed
verdict: supported
applicability: Corrected full successful-normal-terminal G producer cancellation through qualified DONE/discard/actual G-to-A reload; functional RTL only

Authority: [contract snapshot](contract_excerpt.md); [protocol](../../../experiment_source/protocol_r003.md). Owner A007; no production RTL edits. All EDA uses original project lock/CPU0-3/nice19/idle I/O/memory/semantic-stall constraints.

AT001 static source/cost preflight PASS. AT002 COST_GATE_STOP before child launch due prior evidence path bug; actual child cost0. [Diagnosis](AT002_guard_path_diagnosis.md). AT003 sole actual full corrected RTL PASS,125.51343772700056s; started2026-10-23T01:19:19.496315+00:00, finished2026-10-23T01:21:25.009756+00:00, hostuser. Reuse exact R002 AT021 compiled snapshot and original AT058 independent fixture; production sources match. Command cwd: /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS

```text
python3 project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/tb/m007_cancel17_normal_run.py rtl --groups 82 --mode 2 --count 335872 --build /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_corrected_source_cost_preflight](attempts/AT001_corrected_source_cost_preflight) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT001_corrected_source_cost_preflight/receipt.json) |
| [AT002_corrected_full_terminal_cancel](attempts/AT002_corrected_full_terminal_cancel) | COST_GATE_STOP | 未登记 | [执行收据](attempts/AT002_corrected_full_terminal_cancel/receipt.json) |
| [AT003_corrected_full_terminal_cancel](attempts/AT003_corrected_full_terminal_cancel) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT003_corrected_full_terminal_cancel/receipt.json) |
| [AT004_final_release_audit](attempts/AT004_final_release_audit) | EXIT_ZERO | 未登记 | [执行收据](attempts/AT004_final_release_audit/receipt.json) |

## 本批问题与交付文件

- [AT002_guard_path_diagnosis.md](AT002_guard_path_diagnosis.md)
- [contract_excerpt.md](contract_excerpt.md)
- [final_delivery.md](final_delivery.md)

## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
