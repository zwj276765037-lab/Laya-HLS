# E006 关键结果摘要

AT073最后正常full在cycle375074完成LN/Q/Wi/G/Down前缀及Down 256 AW/W/B、TMP 64KiB总检查窗口（16KiB有效写入/gold、48KiB未写哨兵），随后Down→残差票据断言Fatal。原Down状态计数16185cycle是cfg接受358881→首次done375066端点差；至实际消费375073端点差16192cycle，两端采样都计入16193cycle。残差未受理、HIDDEN结果与655360B保护未测，独立合法反压完整样本未做；3/3 full累计4974.979578s。阶段C原v4使用16192，无数值重估。

AT074/075/077综合停在端口/几何动态循环，无网表。R3后的AT079冻结AT040旧函数与新函数：140个已知用例逐值一致，另无效count2例及未知role拒绝；AT080真实portal原回归与新增重叠BEGIN拒绝/响应保持PASS。AT081在store monitor动态循环处展开失败；AT082同监视器受影响短测PASS。AT083在矩阵half解码while处展开失败；AT085旧/新half解码全部65536输入逐bit一致。AT086联合综合已通过输入核验并运行中，尚无资源/时序结论。短/static保守预算和证据见M005_budget_ledger_R3_before_AT081_20261014.json；host历史精确执行时间仍UNKNOWN，不按零计。


---
Published: 2026-10-14T05:39:05.788571+00:00
Publication: P36943b40a0dc450dad9a0d583567ec99
