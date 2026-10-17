# SM004修订6 LN→Q连接阶段集中交付

2026-10-15 勘误：本交付中 AT121 的“Q已接收2half后共同reset”结论不成立；原 `pre_reset_half_sent=64` 属上一行，复位循环可能零次退出。AT123 同RTL、修正TB后才实测本次row31命令握手、Q输入2half、已接受1组/覆盖0组且物理债非零，随后共同reset和下一gold行PASS。AT122新增TB断言失败亦保留。以[更新报告](SM004_lnq_row_stage_result_20261015.md)和[机读证据](SM004_lnq_row_stage_evidence_20261015.json)为准；本页以下为原时点交付，旧预算数字不回写。

A002→A001；回复 `m004-lnq-row-connection-engineering-dispatch-20261015`；M004/SM004/E004/R001。LN首错依赖已获主控接纳，连接段完成原授权范围，不申请追加同候选OOC。

同版顶层 `laya_lnq_row_v1` SHA `7c194fa31f715effd9d886a3cf925371e83e23bb060ca56ab05ebfa338caa592`，接修复LN `a46d468e…` 和现有Q `23c18d6a…`。AT121原始仿真五正常行、四错误、一共同在途reset通过；P1 wi gamma0及qkv embedding gamma1由真实input/gamma经LN和Q，1024 LN值/三统计及32组Q8/FP16 scale逐bit匹配历史独立核验保存夹具。cmd→row_valid端点差8573/11064cycle；后者有42cycle受控Q输出阻塞。倒序＋重复34次组读、阻塞保持、release优先、无reset错误→正常、Q晚数值错62half暂存仍不发布、协议早停真实退休、Q已接收2half后共同reset均有受影响证据。AT113原行参考核后段有限大gamma首个FP16 scale溢出col960，诊断输入不写回原gold。

AT116唯一同版U55C@6.667ns联合OOC DCP/blackbox0：41655 LUT、12192 FF、50 DSP、16 RAMB18（8 tile）、0 URAM。q0/q1/scale暂存实际LUTRAM。内部WNS−49.011ns、TNS−50792.254ns，最差Q槽序号→除法服务231级路径；150MHz在合成内部检查未过，未P&R、95输入/416输出无delay，实际Fmax未知。综合中“row_valid/done_valid常量0”警告经AT120只读同DCP核为LUT2驱动（INIT 2/8），不是最终GND裁剪。该检查不消除严重时序违例。

报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md`；逐冻结身份/guard收据：同目录`SM004_lnq_row_stage_evidence_20261015.json`。累计守卫host1.606030s、static307.264625s、RTL144.865745s、联合OOC242.194084s，均在原帽内；AT111语法失败及AT114 TB强制ready相位失败保留原事实。E002设计/结果、E004三摘要及A002状态已同步。

请求主控集中判断后继阶段：真实LN→Q单行局部正确性与资源可接纳，但Q组合长路径是明确架构/时序障碍，当前不擅自修改Q调度或重启OOC。外部AXI/HBM、矩阵A读、完整图/production-v2请求、P&R/板端仍未证。普通下一段不以本局部PASS代签。
