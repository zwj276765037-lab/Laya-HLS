# E005当前结果

本轮AT001 KB0、AT002 KB1实际full PASS：四distinct K2624/N1024预量化A/bias0/冷reset，全部335872 PS lane-group及4096F32原独立gold，末B/局部publication/一次consume保持。512TN8 packet不变，实际AW/W/B512→256；有效字节16384不变、物理字节32768→16384。

cfg→first done21100→16183（减少23.3033%），cfg→实际consume21107→16190（23.2956%），全冷TB48864→43947（10.0626%）。A/W加载666/27064不变、原7cycle反压保持。互斥state只和为各自命令区间，接口stall重叠单列；同beat响应策略，减少事务自然减少按事务B等待，仅适用于本profile。

26源仅writer改变，12fixture/3native IP/TB/runner/guard一致。KB1额外1923bits字段，物理资源/时序UNKNOWN；两个继承错误窗口未测，不签恢复或生产请求。保留候选，本轮不追加KB2。下一候选成本是27064cycle冷W加载（KB1全冷61.58%），三路R-not-ready0及TB gap说明尚未证明具体DUT改法。

P3有界交付已获设计排序接纳：薄HLS固定RAM/有限微步骤优先，RTL同schema备选，下一原容量关键表全键校验/候选/commit目标及schema仍未冻结；控制器生成未执行。


---
Published: 2026-10-13T06:15:40.214696+00:00
Publication: P07fd264f349c43a1948305410f819144
