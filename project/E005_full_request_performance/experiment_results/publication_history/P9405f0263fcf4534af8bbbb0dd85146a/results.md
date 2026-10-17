# E005当前结果

本轮AT001 KB0、AT002 KB1实际full PASS：四distinct K2624/N1024预量化A/bias0/冷reset，全部335872 PS lane-group及4096F32原独立gold，末B/局部publication/一次consume保持。512TN8 packet不变，实际AW/W/B512→256；有效字节16384不变、物理字节32768→16384。

cfg→first done21100→16183（减少23.3033%），cfg→实际consume21107→16190（23.2956%），全冷TB48864→43947（10.0626%）。A/W加载666/27064不变、原7cycle反压保持。互斥state只和为各自命令区间，接口stall重叠单列；同beat响应策略，减少事务自然减少按事务B等待，仅适用于本profile。

26源仅writer改变，12fixture/3native IP/TB/runner/guard一致。KB1额外1923bits字段，物理资源/时序UNKNOWN；两个继承错误窗口未测，不签恢复或生产请求。保留候选，本轮不追加KB2。冷W加载27064cycles占KB1全冷61.58%，但同TB供数profile下q0/q1各20992拍至少需26239cycles，单改读取器调度的乐观余量最多约825cycles（全冷1.88%）；这不是可实现收益承诺。下一同范围候选应先考察cfg→done内PS/计算/写入的真实重叠。

输出写回同profile下界：16384B恰占满256个512-bit拍，TB逐笔待B；首AW→末B4927cycles内固定B延迟decrement为4608次。首AW不变时只压其他输出间隙的理想余量最多319cycles，PS/writer stall互相重叠不能直接当整命令收益。

P3有界交付已获设计排序接纳：薄HLS固定RAM/有限微步骤优先，RTL同schema备选，下一原容量关键表全键校验/候选/commit目标及schema仍未冻结；控制器生成未执行。


---
Published: 2026-10-13T06:30:47.764944+00:00
Publication: Pa647ccd12c0a4edb8e9836b54324743d
