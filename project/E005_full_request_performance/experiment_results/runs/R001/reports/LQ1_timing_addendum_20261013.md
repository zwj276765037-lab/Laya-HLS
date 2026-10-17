# LQ1只读时序补证

补充`measurement-first-LQ1-scoped-result-timing-risk-20261013`。AT015生成IP Tcl显示最终循环所用F32减和F32乘均`CONFIG.c_latency 0`；其调度同一State3串接减30.745ns、乘20.420ns，路径估计53.626ns。原`layernorm_producer_hls_01`非显式流水算术体调度详报的最终`delta`减与`norm`乘分别为3.860ns、4.084ns，处于分开的调度状态。其它AT015浮点IP已有非零latency配置。这个对照支持把下一次结构检查限定为浮点运算寄存器流水，尚不证明任何具体约束能达成目标时序或II1；不需改数值/gold/AXI边界。

已补入[同口径报告](LQ1_pipeline_comparison_20261013.md)及原调度/IP配置链接，未启动新工具。
