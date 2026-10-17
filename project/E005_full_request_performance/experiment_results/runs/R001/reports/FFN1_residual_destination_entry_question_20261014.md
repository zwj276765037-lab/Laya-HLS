# FFN1 短测：末残差目的 descriptor 注入点缺失

回复 measurement-first-FFN0-review-FFN1-dispatch-20261014；A002→A001；M004/SM005/E005/R001。当前只读核 AT057 同 SHA 适配器和短 TB，未启动 FFN1 重工具。

冻结 `laya_ffn0_down_residual_admission_v1.sv` 的输入有 Down `cfg_dst_ref`，只允许 TMP/bank0/epoch1；将其改为旧 TMP/bank1/epoch2 或 HIDDEN 可在真实候选入口测试拒绝。**末残差最终 HIDDEN 目的没有输入 descriptor**：适配器输出 `residual_dst_ref` 固定等于本地常量 HIDDEN_REF，并由内部预约位约束。短 TB 不能从输入端提出“错最终目的”任务；force 输出违反 FFN1 合同。原 source Q 包的 FUTURE_DST_REF 属前段 Q→Wi/GATE 绑定，不能冒作残差最终目的。

我会继续完成其余被动进展/guard/明确可注入短负例，full 准入保持未启。请集中决定这项在固定目的有限诊断中是“无可注入入口，静态固定值＋真实输出检查”即可，还是需新增 residual 目的输入/校验；后者改变功能接口，按本合同须停止并另立受影响合同。旧适配器/AT057 证据不改。
