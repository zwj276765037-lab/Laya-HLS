

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-24T16:28:47.278122+00:00。来源修订：`7ff16673ba4d`。

# E011 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 / E011 / SM010 M007-W576-v1

execution_state: completed
verdict: supported for byte packing and local reader/cache functional/service simulation; qualified independent bank/reader capacity complete; full synthesis unestablished

Authority: SM010 D-M007-SM010-WSUPPLY-01. Sole implementation E002/experiment/vivado/module_design/hbm_loader_and_cache/new M007 files and E002/experiment/tools/m007_weight_pack.py. Exact sources, command argv/cwd/host/Python/tool path and start/end/resource records are frozen per AT. Vivado/XSim2025.2, target xcu55c-fsvh2892-2L-e; OOC clock3.333ns. No P&R/board/GPU/install/full gold.

Reproduce from project root (fresh AT identifiers required):

```
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py reference ATnnn_pack
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py build ATnnn_build
python3 project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/tb/m007_weight_supply_run.py rtl ATnnn_rtl --fixture project/E011_m007_weight_supply/experiment_results/runs/R001/attempts/AT001_four_superblock_pack/work/fixtures

（摘录截断；完整记录见链接。）

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |
| [AT001_four_superblock_pack](attempts/AT001_four_superblock_pack) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT001_four_superblock_pack/receipt.json) |
| [AT002_reader_cache_build](attempts/AT002_reader_cache_build) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT002_reader_cache_build/receipt.json) |
| [AT003_reader_cache_pilot](attempts/AT003_reader_cache_pilot) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT003_reader_cache_pilot/receipt.json) |
| [AT004_record_phase_width_fix](attempts/AT004_record_phase_width_fix) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT004_record_phase_width_fix/receipt.json) |
| [AT005_full_service_pilot](attempts/AT005_full_service_pilot) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT005_full_service_pilot/receipt.json) |
| [AT006_sync_buffer_lease_fix](attempts/AT006_sync_buffer_lease_fix) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT006_sync_buffer_lease_fix/receipt.json) |
| [AT007_sync_buffer_regression](attempts/AT007_sync_buffer_regression) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT007_sync_buffer_regression/receipt.json) |
| [AT008_dual_slot_reader_ooc](attempts/AT008_dual_slot_reader_ooc) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT008_dual_slot_reader_ooc/receipt.json) |
| [AT009_reorder_missing_debt_tb](attempts/AT009_reorder_missing_debt_tb) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT009_reorder_missing_debt_tb/receipt.json) |
| [AT010_reorder_tb_syntax_fix](attempts/AT010_reorder_tb_syntax_fix) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT010_reorder_tb_syntax_fix/receipt.json) |
| [AT011_reorder_missing_debt_rtl](attempts/AT011_reorder_missing_debt_rtl) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT011_reorder_missing_debt_rtl/receipt.json) |
| [AT012_capacity_ooc_no_timing](attempts/AT012_capacity_ooc_no_timing) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT012_capacity_ooc_no_timing/receipt.json) |
| [AT013_bank_reader_leaf_ooc](attempts/AT013_bank_reader_leaf_ooc) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT013_bank_reader_leaf_ooc/receipt.json) |
| [AT014_reader_capacity_only_ooc](attempts/AT014_reader_capacity_only_ooc) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT014_reader_capacity_only_ooc/receipt.json) |
| [AT015_public_read_rate_build](attempts/AT015_public_read_rate_build) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT015_public_read_rate_build/receipt.json) |
| [AT016_public_read_rate_rtl](attempts/AT016_public_read_rate_rtl) | 未登记；查看原记录 | 未登记 | [执行收据](attempts/AT016_public_read_rate_rtl/receipt.json) |

## 本批问题与交付文件


## 本批原始收据与输入身份


历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
