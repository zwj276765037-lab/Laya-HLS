# SM004首段集中交付：完整软件基线与最小复用接点

A002→A001；M004/SM004/E004/R001。当前E002 `full_execute_cpu_request` 真实production-v2 B1/S128 id3/generation1完整正常g++ host run **PASS_SCOPED_FULL_SOFTWARE_NORMAL_B1**。AT091 46中间＋final18＝47项/4,523,596个F32与旧独立gold逐字节相同，28 Encoder＋2 Decision、18,887任务、962 QUANT；actual final18与32KiB IO已保存。运行216.712s、峰640172KiB、child0/null；四次host构建及两次完整请求累计463.241/1800s，同用例2/2额度已用尽。95项当前编译闭包、包/请求/raw/47 oracle及完整命令/guard/输出身份可复核。

关键架构事实：当前E002此B1软件图实际调用CPU Attention QK/SM/AV叶子各61440，状态服务命令0。AT089首次请求在所有独立数值比较后败于旧“必须走stateful服务”路径断言；AT091仅显式以CPU叶子作为**软件**验收并要求精确调用计数，gold和原数值/层数/任务断言不改。故本PASS不能代签Attention RTL或完整硬件图。AT088 numeric构建链接失败、AT089修正、AT090仅构建及AT091完整原记录均保留。没有新EDA/GPU/gold生成。

结果报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md`；最小复用接点表：同目录 `SM004_minimal_reuse_contacts_20261014.md`；原收据：`../attempts/AT091_SM004_full_software_b1_04/receipt.json`。E004三摘要与A002 console已同步。供A001集中确定固定图首版控制、存储/算术职责与下一段预算；硬件完整请求、II/资源/频率及加速比仍NOT_RUN，本消息不是硬件通过声明。
