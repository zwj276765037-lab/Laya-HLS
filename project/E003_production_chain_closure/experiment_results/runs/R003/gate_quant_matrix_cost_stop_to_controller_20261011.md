# actual G/Q→父matrix组合：static/pilot PASS，full COST_STOP

- 当前组合实现：`laya_gate_quant_matrix_parent_tb_v2.sv`直接把`geglu_gate_quant_split_v2`真实fullA cache端口接到`laya_matrix_portal_binding_v1`；计划覆盖四G窗口→独立Q0→真实fullW→一个rows16父的四view。A没有TB填充路径，新增A acquire/release和W lease/release握手计量。
- 当前冻结证据：`gate_quant_matrix_parent_03` static PASS（84.239673s，2741104KiB）；同一batch no-wave profile的一行物理G pilot PASS（11773 cycles，63.410458s，975140KiB）。
- 成本决定：已通过组件完整cycles为758736+114182=872918；当前pilot速率185.663 cycles/s，加10%余量投影5172s，超过3600s。receipt记录`COST_STOP/started:false`，没有启动full。manifest SHA `f0c140708f014f31a99e166728c4e47a16e0a9ae62dca84c462763fa7a770525`；receipt SHA `042347a390b73357108c20090326c59e2728db1ac756fbab37ad64b7c4cdc0ac`。
- 失败保留：`gate_quant_matrix_parent_01`旧runner只用两个分立full墙钟总和×1.25=3476s，未用当前组合pilot cycles/s，因而错误进入full。工程在实时速率证明超帽后于591.128178s主动SIGTERM；guard记录`sigterm_requested`、无PASS marker。`_02/_03`已修为pilot后结构化COST_STOP，未增预算、未缩覆盖。
- 进度守卫：`gate_split_progress_guard_03`有界PASS；1000条重复work、旧cycles/state-only、缺字段及非法work都不刷新，真实work增长与其它合法阶段日志仍刷新。manifest SHA `63bf56dfcb9a003a6487fed5cd6ecb6a22f984672a6a85e5c743baac58e6004b`；receipt SHA `51084ae8eb12f366b7580cf8183ba419ccf31fbd0a8766ed17cc3838556489b8`。

结论边界：组合源码静态闭合及一行G pilot通过；同runtime完整G/Q→父matrix功能仍为NOT_RUN_COST。`gate_split_04`和`matrix_parent_cache_03`不能拼接代签。工程继续不依赖该full的多父、其余Q/L、LOAD、hub/caller工作；L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。无新OOC/P&R/上板，G OOC余额不变。
