# E004：限定结果

既有AT091完整B1/S128软件基线对独立gold通过；AT101向量、AT110 LN首错、AT124算术在途复位与AT134 LN→Q局部数值/协议各保留原范围。修订8 AT138 U55C LNQ综合网表为37569 LUT/12543 FF/50 DSP/16 RAMB18，6.667ns内部WNS−1.408ns仍FAIL，未P&R。

修订9 AT148同版真实LN→Q→完整Wi冷/暖两命令各20992个PS/167936 lane-group及5248列final逐bit匹配独立同输入gold；LN 1024、Q 32group和真实W返回亦逐bit检查。冷/暖结果发布绝对cycle115019/190675，done118957/194613；W/AUX AR为656/656/82/1，暖零新增。AT150真实W返回标签错在issue16/预留11触发front abort，错误状态7、无发布、W/Q35债务零；无reset暖恢复前256个PS逐bit通过。AT151真实冷RRESP错使LOAD失败、三路reader债务排空且LN/矩阵未启动。AT152 front abort与issue/launch/最终完成同拍优先，AT155 abort=0原数值/拒绝/阻塞/局部在途reset回归通过。AT153原行参考与AT154硬件统计及1024个LN输出逐bit一致，mean=3c319f4e、variance=3e196272、inverse=40255b98。AT149旧guard未识别真实LNQ_WI进展而123.541269s语义停止，错误局部断言保留但整次COST_STOP。修订9守卫实耗static693.750471s、RTL含pilot1781.479534s/1800s、host已测0.824163s下界。详见同一阶段报告和原guard。

修订10 AT166同版真实LN→Q→完整Wi→canonical G→直接Q82组→Down连续cold/warm两命令各逐位匹配原独立同输入gold：每命令Wi 20992 PS、G 2624、Down 10496 PS、最终1024 F32；每命令真实W读/返、issue/PS均31488。两命令累计Wi AR656/656/82、Down AR328/328/41、AUX2，warm不增加W/AUX AR。消费者done绝对cycle178317/291678，命令握手相对延迟未单独记录。AT166 RTL1261.580029s/child0。AT168真实Wi行流水入口接受2/提交0/预留2及AT169真实G发射2/返回0/credit2分别在共同reset后观察510拍无ghost，限定隔离PASS；AT168原日志FP=2只是row_issue握手计数，未采真实浮点IP输入/返回，不能签FP已发未返；耗时203.568609s与521.349162s。AT167守卫误把复位计数归零判回退，202.464809s/child−9的COST_STOP保留。修订10截至AT169正确累计static1113.567624s/1800s、RTL含pilot3459.293175s/3600s，余RTL140.706825s；AT156–158四笔仿真44.618770s分类已纠正，host未全采样仍UNKNOWN。修复版bad/poison错误映射、错误后完整warm、复位后完整cold及主动内部反压/读释放竞争未实测；新顶层联合物理未知。详见[原阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)及AT166–169 guard/manifest。

修订11 AT173局部1024残差及finite/计数错误短例PASS；其完整运行最终FAIL_TB_AUX_STALL_COVERAGE_ZERO，但主控限定接纳真实FP发1返0、G发2返0各共同reset/510拍隔离后，cmd61完整cold到1024残差、cmd62实际W标签错排空、无reset cmd63完整warm到1024残差的Fatal前分项。AT174真实AUX AR两拍停顿并完成1AR/8R与slot0 LOAD PASS。AT175 W首AR已接受、R0/64时共同reset并隔离510拍，随后slot0真实cold重载W三口AR656/656/82、R41984/41984/5248与AUX1/8 PASS；未签该reset后完整FFN。AT176外部scale+Inf被加载器拒绝，AT177分段返回force在注入前触发TB bank不匹配，均FAIL且不能判断前端数值映射。AT178在450.400088s真实墙钟停止于Wi group21/约13779 PS，末组注入未到，COST_STOP。五次static/RTL费用连同AT170–173实账累计1142.969832/4724.407606s，余RTL75.592394s，不再重跑长前缀；host完整累计UNKNOWN。Wi/Down bad/poison状态6与协议7区分、内部主动反压、部分R后reset及本顶层联合物理仍未验证。见[原阶段报告](runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)和AT170–178原guard/manifest。


---
Published: 2026-10-15T00:25:03.288957+00:00
Publication: Pc11edb83b7af43f6abf04294491830fa
