# SM004修订9工程阶段交付：AT148–155

A002→A001；M004/SM004/E004/R001。真实LN→Q→完整Wi单行同版顶层SHA `55e18053…`、front SHA `62e10452…`。当前唯一阶段报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md`；各原guard、source_manifest和命令在AT目录。模块design/results及E004三摘要、A002状态已同步。

AT148真实前LN row0→LNQ→冷W AXI LOAD→全部20992 PS/167936 lane-group→5248 final，独立同输入gold逐位PASS；无reset暖命令相同全N逐位PASS且W/AUX零新增AR。冷LOAD_DONE 43303、Q行可用51901、结果发布115019、done118957；暖Q行可用127557、发布190675、done194613（均TB绝对cycle）。AT148 child0/null、699.209128s、峰903872KiB。真实W三口R 41984/41984/5248 beat、AR656/656/82、AUX AR1。

AT150真实W返回标签错在issue16/预留11触发front abort，错误状态7、行未发布、W与Q35债零且lease释放；随后无reset暖命令真实LN/Q及前256个独立PS逐位通过，无新W/AUX AR。AT151真实冷q0 RRESP错，reader排空后状态7，LN/矩阵未启动。AT152同版front abort在同拍issue、队首launch和最后完成沿均优先，Q35归零；AT155 abort=0原前端数值、拒绝、阻塞及局部在途reset回归通过。AT153原独立单行参考全1024 y与保存LN gold逐位相同，AT154同输入DUT mean/variance/inverse分别`3c319f4e/3e196272/40255b98`逐bit一致。

AT149原故障断言已到但旧guard不识别`LNQ_WI_PROGRESS`，123.541269s semantic_stall，暖恢复未完成；此COST_STOP原样保留。修正guard语义匹配后AT150–155正常退出。修订9已测static693.750471s/1800s、RTL含pilot1781.479534s/1800s（余18.520466s）、host守卫0.824163s下界，未启动新OOC/P&R。预算不足以再跑错误后完整暖行或顶层共同在途reset；这两项、任意内部tag故障、G/Down、外部HBM、联合资源/布线和完整推理仍未验证。AT138旧较小LNQ网表150MHz内部WNS−1.408ns FAIL不迁移成新Wi顶层结果。

请按上述限定范围集中审核，并在同SM004决定后继连接/补测的具体边界。没有新mission、gold或数值规则变更；当前工程段工具队列空闲。
