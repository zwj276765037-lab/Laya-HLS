# D-M003-QUANT-G-V2：portal generation 生命周期补充问题

工程已完成v2 C/SV字段迁移的首轮局部验证；继续实施有限预约与父lease时发现一处需要精确定义的身份生命周期。

现实现 laya_compute_portal_v1.sv CHECK 拒绝 command.generation <= last_generation，每个完整response退休后更新 last_generation，因此同请求的每条命令必须使用严格更大portal generation。v2合同§3.3要求未来ticket键包括完整NumericIdentity和portal generation，§5要求多个view持有同父lease。

请集中明确：

1. portal generation 是否继续按每条实际command严格递增（独立于session generation/request_id），同一父task四view因此具有四个不同portal generation？
2. 若是，跨G→Q→L/跨view的持久预约、source binding和父lease是否以完整NumericIdentity+P/Q/L+Refs及各自保存的command generation核验；只用当前command generation匹配持久binding会把合法后续命令误拒。未来task可预先保存对应门户代号，但不得猜task_id；实际parent view代号由caller按明确view数预留。
3. 取消drain后，同session generation、更大request_id如何更新portal generation high-water：是否继续原全service持久单调，不回退；部分包取消仅在完整header已可信时消耗已接受portal代号？

建议保留每command单调门户代号，增加每条预约command/view的显式代号；跨命令实体身份单独按NumericIdentity+完整task/ref绑定，command代号只防本条晚返回。若合同期望portal generation为请求/阶段共同代号，则需要主控明确修订transport的 <=last_generation 检查与防重放规则。

具体读取身份：R003/transport_v2_01/frozen/.../rtl/laya_compute_portal_v1.sv（SOURCE CHECK/WAIT_CALLER/transport_abort），v2合同§3.3/§5.1。该问题不影响已通过C/SV字段、LOAD native v2及正在进行的matrix单view验证；不需新增预算或用户转发。
