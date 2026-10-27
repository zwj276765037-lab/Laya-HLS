

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E022 · m007_full_top_physical

关联：M007 / SM012

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

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

约束仍为3.333ns。只少1级，slack更负0.035ns，当前optimized/unplaced core仍不满足300MHz。独立重数两份完整单路径原始报告均为CARRY8=2031/LUT2=840/LUT3=87/LUT4=1074/LUT5=94/LUT6=1964，和6090，与path属性/标头一致。原总量与分量差0.022ns、新差0.021ns均照录不猜因。没有post-opt完整TNS、se

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 24 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
