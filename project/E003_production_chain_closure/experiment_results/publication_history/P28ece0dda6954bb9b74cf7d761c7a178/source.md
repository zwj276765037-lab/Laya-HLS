# E003：snapshot F14旧清理优先

# Bootstrap snapshot F14仲裁修复与受影响兼容回归

范围M003/SM003/E003/R003；回复executor-bootstrap-snapshot-review-20261012；现合同、原预算及单重工具。

F14实现已修：启用snapshot时，LPV request_ready仅由已接受且未消费snapshot response排他门控，不再被未接受snapshot valid压低。snapshot仍在没有当前LPV request、scope/pending END/旧response/lease/cancel且安全条件满足时接受。因此双方持续valid时LPV/旧action清理优先；QUANT source query相对snapshot保持原明确优先级。只读snapshot未增加lease/发布/typed副作用。

bootstrap_snapshot_rtl_03为PASS_SCOPED_RTL_SNAPSHOT_ARBITRATION。保留原完整B1/S64受控prelude与串行查询/错绑定/未发布/反压断言；新动态负例不通过撤valid制造进展：
- idle CLAIM与snapshot同时持续valid，CLAIM先唯一接受；返回保持12周期期间snapshot仍pending，消费LPV返回后查询唯一接受并诚实E_BUFFER（未发布）。
- 第四窗口BEGIN后snapshot持续valid；实际最后B未消费时END也持续等待12周期，两者无错误准入。真实B退休后END完成、scope关闭，END返回另持12周期；消费后snapshot返回完整绑定的未发布拒绝。snapshot未撤请求，4 typed终态及事件高水位保持。
- 已接受snapshot返回持12周期时，INVALIDATE持续valid且零接受；消费snapshot后INVALIDATE唯一接受。其完整绑定成功response在cancel脉冲及后续12周期保持，第二snapshot持续等待；消费cleanup返回后cancel收束、查询诚实拒绝，无旧response清除或事件重复。
- snapshot与invalid QUANT query同时持续valid时，snapshot唯一接受并持返回12周期；消费后query恢复ready并按原语义拒绝，未产生lease。该项只签无lease非法query竞争；合法QUANT source lease另以默认禁用兼容回归保留。



---
Published: 2026-10-12T13:54:35.410224+00:00
Publication: P95b260fc56294a3da6185370d6df56a9
