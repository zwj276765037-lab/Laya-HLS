# E005当前结果

本轮AT001 KB0、AT002 KB1实际full PASS：四distinct K2624/N1024预量化A/bias0/冷reset，全部335872 PS lane-group及4096F32原独立gold，末B/局部publication/一次consume保持。512TN8 packet不变，实际AW/W/B512→256；有效字节16384不变、物理字节32768→16384。

cfg→first done21100→16183（减少23.3033%），cfg→实际consume21107→16190（23.2956%），全冷TB48864→43947（10.0626%）。A/W加载666/27064不变、原7cycle反压保持。互斥state只和为各自命令区间，接口stall重叠单列；同beat响应策略，减少事务自然减少按事务B等待，仅适用于本profile。

26源仅writer改变，12fixture/3native IP/TB/runner/guard一致。KB1额外1923bits字段，物理资源/时序UNKNOWN；两个继承错误窗口未测，不签恢复或生产请求。保留KB1候选。冷W加载27064cycles占KB1全冷61.58%，但同TB供数profile下q0/q1各20992拍至少需26239cycles，单改读取器调度的乐观余量最多约825cycles（全冷1.88%）；这不是可实现收益承诺。KB2两个64tile块候选已按本轮成本/进展规则退出，不能据其有限pilot判数值或收益。

输出写回同profile下界：16384B恰占满256个512-bit拍，TB逐笔待B；首AW→末B4927cycles内固定B延迟decrement为4608次。首AW不变时只压其他输出间隙的理想余量最多319cycles，PS/writer stall互相重叠不能直接当整命令收益。

P3有界交付已获设计排序接纳：薄HLS固定RAM/有限微步骤优先，RTL同schema备选，下一原容量关键表全键校验/候选/commit目标及schema仍未冻结；控制器生成未执行。

## AT003 KB2终态与CT0边界

AT003：measurement_01静态接口漂移失败；measurement_02/03 static与pilot有限PASS，full均COST_STOP；delta_01同snapshot有限诊断COST_STOP。三个停止的末条真实marker同为`cycle=33397 stripes=5151 ps0=5120 outputs=0`，33397仅是末次观测周期，5120仅直接表示ps0。没有完整数值、末B、done消费或性能结果，根因UNKNOWN。KB1保持已核范围。详见KB2原报告与主控停止审核。

CT0当前仅完成5009bit×32 schema/reference设计；host、HLS生成、有限RTL和控制cycles均NOT_RUN。CT0不接生产owner、发布或退休。


---
Published: 2026-10-13T07:19:32.933057+00:00
Publication: P9405f0263fcf4534af8bbbb0dd85146a
