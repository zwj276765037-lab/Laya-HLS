# QWIGQD0四行真实量化供数结果交付

回复 `measurement-first-WIGQD1-review-QWIGQD0-dispatch-20261013`；M004/SM005/E005/R001，A002唯一实现/工具。沿既有D-M004-QWIGQD-INTEGRATION-01，无新增预算或审批。

**AT034有限正常RTL PASS，请主控集中审核；M003/M004不关闭。** 原enc0 LN_FFN前四行16384B F32作为只读DDR外部输入，经桥中**同一** quant_task 真实AXI读256个512bit beat，产生原独立金标4096 INT8/128 FP16 scale、256 half提交，dualA slot0/epoch1在cycle1101发布。随后同runtime无链间reset：Wi真实20992 F32/671744 PS及1312 AW/W/B、Wi DDR reader1312 R→G 10496 F32/656 AW/W/B→同量化器GATE读656R/328组及dualA epoch2→Down335872 PS/4096F32/256 AW/W/B。Wi/Down最后B、A/W lease/读债、7拍done保持及各一次真实消费闭合。全冷TB206133cycles；源Q接受23、Wi完成102154、G接受102158、第二A发布162862、Down消费206132。393216B DDR终扫先于CHAIN_PASS：只读源16384B、三段输出合142336B逐字节原gold/written、其余234496B哨兵未写。

AT033 static/pilot PASS、full FAIL：GATE A已真实发布于162862，之后TB错误要求两个任务的feeder/dualA计数累加，原模块实际每任务清零。AT034仅TB断言/诊断和runner与AT033不同，102条其它冻结路径含桥RTL一致。AT034原计数打印证实第二轮starts4/input656/half656/scale328/source_R656/debt1，随后Down完整通过；旧失败原收据不改。106 manifest引用/104不同冻结路径全核，49实际policy样本CPU0–3/nice19/idle，3guard串行无触发；static/pilot/full 82.810202/28.706722/1778.416778s，full峰1510892KiB。源F32=原完整LN_FFN capture前四行，q/scale binary/mem逐字节同源。AT032旧预量化边界205314，本次+819cycle仅是不同外部入口同profile全冷差，不能解释为单核部署成本或性能收益。源AR burst数与首末AR/R边沿未打印，只观察256 R、地址边界与发布/完成。

证据：[阶段报告](QWIGQD0_integration_result_20261014.md)、[连接表](QWIGQD0_connection_map_20261014.md)、[AT034原收据](../attempts/AT034_QWIGQD0_chain_02/receipt.json)、[原full日志](../attempts/AT034_QWIGQD0_chain_02/raw_full.log)、[独立核验](../attempts/AT034_QWIGQD0_chain_02/verification.json)、[源身份](../attempts/AT034_QWIGQD0_chain_02/source_identity_check.json)、[AT033失败收据](../attempts/AT033_QWIGQD0_chain_01/receipt.json)。E005三摘要及A002实际状态已同步，当前无本项目重工具。

本阶段仍缺LN_FFN producer、FFN residual、完整28+2层/122矩阵、生产13BO/完整请求/恢复、联合资源与物理时序/上板；LQ0是不同LN_ATTN源，不能拼接。桥新增外部量化路由的接纳/响应隔离在本normal顺序样本及源码边界内成立，未跑并发/错误矩阵。整体executor/冷INIT/恢复继续停排；原G仅OOC余额、5172s不重启及无新HLS/OOC/P&R/上板保持。请主控依据此次有限出口集中定后继；工程不自行扩大控制范围。
