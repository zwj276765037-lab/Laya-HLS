

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# E001 / R001 运行结果

[负责人维护的本批运行记录](run.md)

# R001 — E001 完整复制与核对

Execution state: completed
Verdict: supported
Applicability: baseline完整副本及内部链接映射的一致性。

- 原工程：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`；目标：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`。
- 起止：2026-10-11T06:11:44.758029+00:00 → 2026-10-11T06:17:48.123958+00:00。
- 命令/主机/工具/脚本SHA：[execution_identity.json](execution_identity.json)。
- 实际启动外层：`timeout --signal=TERM 1800 flock -n <原R>/control/heavy_tool.lock taskset -c 0-3 nice -n 19 ionice -c 3 python3 /tmp/laya_hls_import_20261011.py`；原R为上述原工程的`results/compute_throughput_optimization_20261010`。
- 完整复制日志：[copy.log](copy.log)；源entries：[source_inventory.json](source_inventory.json)。
- 普通文件：210038，目录：16647，links：6100，逻辑普通文件bytes：45917457197。
- 逐文件双侧SHA：[file_sha256.jsonl](file_sha256.jsonl)；links：[symlink_mapping.json](symlink_mapping.json)。
- 退出：复制命令与核对成功；[copy_receipt.json](copy_receipt.json) error列表为空。
- 原普通文件不改；副本普通文件字节一致，未与原文件共用inode；内部links指副本。
- 本运行不执行硬件验证，也不启动新代理，不能判定整网硬件PASS。

## 具体尝试与冻结结果

| 尝试 | 收据中的阶段状态 | 适用范围 | 原始结果 / 证据 |
| --- | --- | --- | --- |

## 本批问题与交付文件


## 本批原始收据与输入身份

- [copy_receipt.json](copy_receipt.json)
- [execution_identity.json](execution_identity.json)

历史目录保持原名和原位置；新具体尝试使用 attempts/ATxxx_名称。没有收据或范围声明的结果显示未登记。

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
