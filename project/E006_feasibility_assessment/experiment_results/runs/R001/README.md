

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# E006 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — E006

Recorded: 2026-10-14T01:32:29.626774+00:00

Execution state: planned
Verdict: unassessed

- Exact command and working directory:
- Host, tool and platform versions:
- Code identity (commit/hash), external constraints and IP identity:
- Input/data identity and reproducibility inputs:
- Start/end times:
- Exit status and infrastructure errors:
- Independent oracle, expected values and acceptance criteria:
- Evidence paths and qualified scope:
- Observations and limitations:

A run record alone does not establish PASS or a method verdict.

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT064_M005_down_entry_short_01](attempts/AT064_M005_down_entry_short_01) | 未登记；查看原记录 | Frozen AT063 admission + AT035 ledger with real source identity, controlled prior Wi claim/retirement, tied-idle matrix ready; does not reproduce full-chain W boundary or prove DUT numeric result | [执行收据](attempts/AT064_M005_down_entry_short_01/result.json) |
| [AT065_M005_down_boundary_observe_01](attempts/AT065_M005_down_boundary_observe_01) | 未登记；查看原记录 | 未登记 |  |
| [AT066_M005_quant_axi_debt_short_01](attempts/AT066_M005_quant_axi_debt_short_01) | 未登记；查看原记录 | 未登记 |  |
| [AT067_M005_top_static_01](attempts/AT067_M005_top_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT068_M005_top_tb_static_01](attempts/AT068_M005_top_tb_static_01) | 未登记；查看原记录 | 未登记 |  |
| [AT069_M005_top_tb_static_02](attempts/AT069_M005_top_tb_static_02) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT069_M005_top_tb_static_02/input_manifest.json) |
| [AT070_M005_top_normal_candidate_01](attempts/AT070_M005_top_normal_candidate_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT070_M005_top_normal_candidate_01/input_manifest.json) |
| [AT071_M005_top_w_probe_01](attempts/AT071_M005_top_w_probe_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT071_M005_top_w_probe_01/input_manifest.json) |
| [AT072_M005_top_w_phase_fix_01](attempts/AT072_M005_top_w_phase_fix_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT072_M005_top_w_phase_fix_01/input_manifest.json) |
| [AT073_M005_top_normal_phase_fix_01](attempts/AT073_M005_top_normal_phase_fix_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT073_M005_top_normal_phase_fix_01/input_manifest.json) |
| [AT074_M005_joint_physical_01](attempts/AT074_M005_joint_physical_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT074_M005_joint_physical_01/input_manifest.json) |
| [AT075_M005_joint_physical_ports_02](attempts/AT075_M005_joint_physical_ports_02) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT075_M005_joint_physical_ports_02/input_manifest.json) |
| [AT076_M005_hub_geometry_short_01](attempts/AT076_M005_hub_geometry_short_01) | PASS | LPV1/LPA1 16/8-beat transport plus persistent transaction-ledger RTL: fresh event high-water, owner lifecycle, END scope retention and store-accounting input, an undrained END held through a later physical fence, per-identity typ… | [执行收据](attempts/AT076_M005_hub_geometry_short_01/receipt.json) · [input_manifest.json](attempts/AT076_M005_hub_geometry_short_01/input_manifest.json) |
| [AT077_M005_joint_physical_bounded_hub_03](attempts/AT077_M005_joint_physical_bounded_hub_03) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT077_M005_joint_physical_bounded_hub_03/input_manifest.json) |
| [AT078_M005_hub_disjoint_differential_01](attempts/AT078_M005_hub_disjoint_differential_01) | 未登记；查看原记录 | 未登记 |  |
| [AT079_M005_hub_disjoint_differential_02](attempts/AT079_M005_hub_disjoint_differential_02) | 未登记；查看原记录 | 未登记 |  |
| [AT080_M005_hub_disjoint_portal_01](attempts/AT080_M005_hub_disjoint_portal_01) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT080_M005_hub_disjoint_portal_01/input_manifest.json) |
| [AT081_M005_joint_physical_bounded_disjoint_04](attempts/AT081_M005_joint_physical_bounded_disjoint_04) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT081_M005_joint_physical_bounded_disjoint_04/input_manifest.json) |
| [AT082_M005_store_monitor_bounded_short_01](attempts/AT082_M005_store_monitor_bounded_short_01) | PASS | persistent LPV1 hub connected to one protected generated AXI512 role-6 write port for a contiguous rows16 owner: 16 real 64-beat INCR bursts, W-before-AW containment, per-beat unique WSTRB coverage, final-B and explicit adapter-f… | [执行收据](attempts/AT082_M005_store_monitor_bounded_short_01/receipt.json) · [input_manifest.json](attempts/AT082_M005_store_monitor_bounded_short_01/input_manifest.json) |
| [AT083_M005_joint_physical_bounded_store_05](attempts/AT083_M005_joint_physical_bounded_store_05) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT083_M005_joint_physical_bounded_store_05/input_manifest.json) |
| [AT084_M005_half_decode_differential_01](attempts/AT084_M005_half_decode_differential_01) | 未登记；查看原记录 | 未登记 |  |
| [AT085_M005_half_decode_differential_02](attempts/AT085_M005_half_decode_differential_02) | 未登记；查看原记录 | 未登记 |  |
| [AT086_M005_joint_physical_bounded_half_06](attempts/AT086_M005_joint_physical_bounded_half_06) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT086_M005_joint_physical_bounded_half_06/input_manifest.json) |
| [AT087_M005_joint_physical_synth_guard_07](attempts/AT087_M005_joint_physical_synth_guard_07) | 未登记；查看原记录 | 未登记 | [input_manifest.json](attempts/AT087_M005_joint_physical_synth_guard_07/input_manifest.json) |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
