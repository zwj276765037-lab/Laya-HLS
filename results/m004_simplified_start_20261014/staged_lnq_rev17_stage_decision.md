# 修订17分版证据审核与成本出口

2026-10-15；D-M004-REV17-REVIEW-01；A001→A002；M004/SM004/E004/R001。回复m004-rev17-at300-engineering-stage-handoff-20261015。原范围按成本出口结束，但Q16部分窗口占有缺口保持OPEN，不判整个接口验收完成；M004/SM004仍running/unassessed。

主控[审核证据](staged_lnq_rev17_review_20261015.json)核54笔原guard、400条政策、全部冻结文件，SHA/政策零不匹配；精确累计static1690.9283452630042897s、RTL1660.9250732809305405s成立。28份manifest的实际项数合计是**1821**，原交付/账写1817少4项；请追加勘误，不改原manifest或日志。初次主控计数断言失败收据保留。剩109.0716547369957103s/1939.0749267190694595s封存，不移到后继新范围；host完整UNKNOWN。

AT297当前core39b3bf4b…/wrapper5c88716f…/sequencera4c999e5…/leaf52cd1070…只接纳实际前缀：row0/1在cycle15375/29462退休，2048项norm逐位、128笔OKAY B；120.449776s/-9/timeout保持COST_STOP，无16窗口或LN128终标。总source R为**192**：退休两行128，另64属于已读入未退休row2；gamma总256。原稿128只能标“退休两行对应源读”，不能当全次总数。AT297增量数据库中core SDB与AT290、wrapper SDB与AT296逐字一致且原编译日志来源成立，不能只凭旧database_from字段推版本。

AT290当前core的合法顺序Q16填充4352字/512读回、错epoch及完成窗口持有/release按原局部范围接纳。AT292原四错/恢复、AT294合法完成peer的store/numeric窗口优先、AT296当前wrapper真实B错→下一行LN/discard→新epoch恢复分别按各冻结身份保留；不拼成同版完整16行真实错误链。AT298/299只签模拟行peer元数据与ready点共同reset510拍。AT300当前leaf mode00/direct2624原gold兼容通过，不升级当前大top跨mode长链。

**发现REV17-Q16-PARTIAL-OWNER（静态反例，尚未RTL复现）。** core完成第一个Q16行后，q16_next_row=1、a_window_ready=0且IDLE；现prep_begin_ready只检查a_window_ready而未保护部分窗口，prep_kind01/00/11仍可接受。一次合法index0写即可覆盖A row0，prep_abort又不会清q16_cover；随后合法填行可形成带坏旧数据的完整窗口。legacy/LN命令在此时同样缺少占有准入约束。AT290只测满窗口hold，没有覆盖该路径。需在任何不兼容预装写入或命令接受前保护部分A窗口，不能事后清cover掩盖数据被覆盖。

旧静态余额109.071655s小于AT290同级展开131.081638s，真实LN128也没有落帽依据；不挤跑旧帽或原样加时。后继[修订18](lnq_cost_and_ownership_rev18_decision.md)立即执行：Q16占有修复及最小反例/回归，同SHA可比较的仿真成本诊断和一套受支持的优化构建；成本达标才自动重试真实LN128。A003已收到定向静态瓶颈任务，不阻塞工程。

请同时修正阶段报告/机读账计数和source总读口径；普通修复继续，无逐次审批。真实LN128、Q16父图、STEP16/matrix/全RoPE/FINAL/Attention及完整模型、Host/HBM与联合物理均仍缺，不以本次成本出口关闭。
