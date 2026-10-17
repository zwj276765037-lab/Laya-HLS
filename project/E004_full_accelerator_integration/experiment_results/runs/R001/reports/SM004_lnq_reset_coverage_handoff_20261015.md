# SM004 LN→Q 在途复位覆盖勘误与受影响收束

A002→A001；回复 `m004-lnq-review-reset-coverage-fix-20261015`；M004/SM004/E004/R001。按修订6原预算完成普通TB覆盖修复，不改DUT/数值/接口/原gold，不追加OOC。

AT121旧 `LNQ_RESET_PASS pre_reset_half_sent=64` 读到上一成功行遗留计数，原循环可能未接受新cmd，故该复位声明改为**未证明**；AT121其余正常/错误限定结果及AT116同RTL联合OOC保持原适用范围。AT122先修新cmd握手及RUN证明，但误要求Q `accepted_groups` 在top cmd时清零，原仿真显示本行row31/RUN/half0、旧Q组数32，故为新增TB断言失败，原收据保留。

AT123只改上述采样时点。原 `guard_sim_reset/driver.log`：先前正常行PASS；本次row31 cmd接受1次、state RUN/half0；随后Q start1次、Q输入接受2half，复位前 half_sent2、accepted_groups1、covered_groups0、Q active1、physical_debt_zero0、无row/done；共同reset后无ghost、Q债零，下一正常行的原P1 gold逐位PASS，最终 `LNQ_RESET_SCOPE_PASS`。`guard_static` 31.982667s、`guard_sim_reset` 11.363645s，child0/trigger null，冻结109文件逐项SHA匹配。AT122 static31.983836s、失败sim7.757469s，同样计入连接预算。累计host1.606030s、static371.231127s/1800s、RTL163.986859s/1200s、唯一联合OOC242.194084s/1800s。AT122/123与AT116/121的LN/Q/顶层RTL SHA相同，夹具不变。

完整解释及原证据：[阶段报告](SM004_lnq_row_stage_result_20261015.md)、[机读身份/预算](SM004_lnq_row_stage_evidence_20261015.json)、[AT122失败原日志](../attempts/AT122_SM004_lnq_reset_coverage_01/guard_sim_reset/driver.log)、[AT123通过原日志](../attempts/AT123_SM004_lnq_reset_coverage_02/guard_sim_reset/driver.log)。E002模块结果、E004三摘要及A002 console已更新。本次仅关闭一个真实Q在途共同reset覆盖缺口，不代签其他复位相位、后继矩阵、全图或布线频率。AT116的150MHz综合内部WNS−49.011ns障碍保持，由A001后续集中判断。
