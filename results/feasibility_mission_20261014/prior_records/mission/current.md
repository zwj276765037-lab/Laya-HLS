# 当前工作：FFN4分离Wi与Down存储描述符并验证

[FFN3审核](../results/measurement_first_FFN3_review_20261014.md)核定AT062 FAIL_SEMANTIC_WI_READER_CONFIG：冷前缀1AR/64R通过，唯一full达到LN/Q/Wi，cycle271096因Wi reader误取Down STATE1 BO拒绝。Wi真实done消费271089、完成标记271090。原full1696.153932s/峰1036100KiB，child0/null不覆盖Fatal；后续G/Down/残差及最终保护未到达。1549路径、336来源引用、262编译包文件及两运行副本冻结身份一致；两动态guard/8policy匹配。旧记录不回写。

当前[D-M004-FFN-WI-DESCRIPTOR-REPLAY-01／FFN4](ffn_wi_descriptor_replay_stage_20261014.md)只稳定分离Wi DDR与Down STATE1描述符，保留功能DUT/reader范围校验/观察器/guard/gold。新static和四行reader正反短测，一次真实冷前缀后按实际到Wi与分阶段剩余成本决定至多一次full；旧3536.346s不自动沿用。static/短测首次加至多两轮有因修正，纯host累计120s内连续准备，完整边界见合同。新阶段NOT_RUN。

AT049到Down与AT054独立残差PASS不能拼成联合PASS。真正同runtime TMP/残差/655360B终检及整链周期仍未测。A002唯一实现/工具，E002/experiment代码、E005/R001证据；单重工具和原CPU/nice/I/O/MemAvailable/工具帽保持，无新agent/参考/HLS/OOC/P&R/上板。普通Q/L/整体生产控制/恢复停排；外部Attention residual、生产双lease、完整BO/13BO、全模型/资源/物理和M003/M004开放。
