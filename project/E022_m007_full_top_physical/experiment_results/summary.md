# E022：一次优化后core资源及setup仍不通过

当前候选LUT2091399，为器件1303680的160.42%、完整核900000预算的2.323777倍。一次opt仅减少48116 LUT（2.248921%）；当前完整core仍超器件787719 LUT，资源门不通过，未进入完整父装配/place/route。不能据此签full-top fit或最终布线频率，也不声称所有未来映射都不可能。

| 同版core资源 | 综合态 | 一次opt后（独立复开复核） | 完整核预算 | 器件总量 |
| --- | ---: | ---: | ---: | ---: |
| CLB LUT（已含combining） | 2139515 | 2091399 | 900000 | 1303680 |
| FF | 1391977 | 1391977 | 1800000 | 2607360 |
| DSP | 4352 | 4352 | 7200 | 9024 |
| BRAM36eq | 0 | 0 | 1200 | 2016 |
| URAM | 0 | 0 | 640 | 960 |

优化后层级为本层1899196+dot_array137930+format54273=2091399，本层单独仍超器件；降低分别47571/32/513，合48116。直接raw LUT primitive2241625→2187052，直接FDRE1065764、MUXF7/8 402340/196736不变。共同导出的g_operand_slot组FDRE1048576和五个LUT组之和1058681均不变；mul_a/mul_b/trace_commit_data各raw LUT6 139264亦不变。只比较top256共同导出的名称/primitive组，未导出组不按0，raw计数不换算为combining后LUT或完整cone因果；不将全部本层LUT归为单一根因。

优化后全局最差与原固定setup路径均实际返回1条，同为n_reg[1]/C→error_col_reg[0]/CE，fixed launch/capture/CE各matches1。

| 同端点setup观察 | 综合态原最差 | 一次opt后global/fixed |
| --- | ---: | ---: |
| Slack / ns | -1289.339 | -1289.374 |
| 逻辑级 | 6091 | 6090 |
| Data path / ns | 1292.568 | 1292.603 |
| Logic / ns | 359.024 | 359.288 |
| 未布局net延迟估计 / ns | 933.522 | 933.294 |

约束仍为3.333ns。只少1级，slack更负0.035ns，当前optimized/unplaced core仍不满足300MHz。独立重数两份完整单路径原始报告均为CARRY8=2031/LUT2=840/LUT3=87/LUT4=1074/LUT5=94/LUT6=1964，和6090，与path属性/标头一致。原总量与分量差0.022ns、新差0.021ns均照录不猜因。没有post-opt完整TNS、setup端点统计、hold/PWS或placed/routed验收；原综合态TNS=-301158.188ns、setup失败132577/3273333及hold WHS0.065ns/THS0/失败0保持原阶段，未冒作新测。

实际限制保留：HD.CLK_SRC未设，OOC clock delay/skew估计受限，没有虚构平台时钟位置；report_timing -of_objects与-input_pins并用时格式选项被忽略（两次Warning），实际路径和metadata仍完整，原始6090级已重数。AT020原DRC有UTLZ-1 Error1，未抑制或降级；OOC有部分连接检查未运行。report/opt执行PASS均不代表资源或物理时序PASS。

| 本诊断实际guard费用 | 类别 | 执行结果 | elapsed / s |
| --- | --- | --- | ---: |
| AT021 pre-opt API | implementation | FAIL（未调用opt） | 434.210852844 |
| AT022 pre-opt API | implementation | FAIL（未调用opt） | 455.505928938 |
| AT023唯一opt及保存/边界 | implementation | PASS | 1992.074475108 |
| AT024候选资源与两条路径 | reports | PASS | 1024.074499061 |

合implementation2881.791256890s、reports1024.074499061s，总3905.865755951s，均与原ledger逐项一致。AT023峰16.459915GiB、AT024峰17.560764GiB；全部源码核验、原/候选SHA、policy/清理和锁核验通过。opt与checkpoint子时间已包含在AT023，不重复相加；AT019历史50108.013762s含实际恢复，AT02022565.379247s等全部旧费保留，不重置。

最终证据：project/E022_m007_full_top_physical/experiment_results/runs/R001/core_opt_diagnostic_final_engineering_receipt.json、core_opt_diagnostic_final_state.json；AT023/engineering_completion_audit.json；AT024/engineering_completion_audit.json、engineering_post_resource_finding.json、reports/optimized_worst_setup.rpt、reports/optimized_fixed_baseline_setup.rpt与两份_path_properties.tsv。候选及原DCP、全日志、失败尝试均保留。


---
Published: 2026-10-26T20:59:14.009870+00:00
Publication: P1da0aeb88e96456e9da255967d19a2cd
