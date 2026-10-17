# WIGQD0 停止点只读补证：G 阶段缺行级进度标记

补充`measurement-first-WIGQD0-bounded-stop-handoff-20261013`，不改变AT031的COST_STOP和两轮修复上界。

AT025冻结GQD0测试台在合法G命令后每行Wi完成时打印`MATRIX_PROGRESS GQD0_Wi_row`；原full日志四行分别在cycle5294/19454/33617/47780出现。AT031冻结WIGQD0测试台没有该行级打印；其G命令接受后，下一个显式`MATRIX_PROGRESS`是全部G/量化完成后的`GQD0_A_ready`。AT031仍在代码中累计真实`wi_accepted`、`wi_rows_retired`并检查身份和债务，但COST_STOP前无计数快照。因此120秒无新标记既可能是观测空窗，也可能是真实停滞；不能从末条cycle101339确定DUT最终状态。

证据位置：[AT025冻结测试台](../attempts/AT025_GQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/gqd0_chain_tb_v1.sv)、[AT025原full日志](../attempts/AT025_GQD0_chain_03/raw_full.log)、[AT031冻结测试台](../attempts/AT031_WIGQD0_chain_03/frozen/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/wigqd0_chain_tb_v1.sv)、[AT031原full日志](../attempts/AT031_WIGQD0_chain_03/raw_full.log)、[阶段报告](WIGQD0_bounded_stop_20261013.md)。工程不启动第三版/重跑，供主控集中判断下一有界诊断入口。
