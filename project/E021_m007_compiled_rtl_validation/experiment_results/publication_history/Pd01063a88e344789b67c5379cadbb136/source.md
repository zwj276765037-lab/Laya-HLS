# E021：D37 修复版原30层一次BEGIN验证

execution_state: running
verdict: unassessed
applicability: E021/R005当前修复父9d877217…/TB2bd73c51…参数0，正式完整运行尚未启动

A013接续工具与本段证据；父RTL/TB/gold只读。原28Encoder+2Decision、finalLN/type、544尾输出通过同一公开BEGIN连续计算，初始输入仅原embedding_norm/initial_H。后端Verilator5.020+fixed-batch-v1/converge512，model1/context1、原flags。参数0新展开，741模型TU全部fresh；只有按完整SHA核验的成功fixed runtime复用。新增main只读接口采集finalLN/type，次posedge核原计数与真实Q/hidden银行，不增eval或DUT写。

独立static1800/RTL15600（留600），唯一full≤15000s；层600/连续段120/stall120/40Mcycle、原CPU/内存/单锁不变。完整验收需全部30实际H/两端点/尾部值与原独立gold全同、原完整计数/FC1ACK/真实tail_commit/DONE消费/idle/rc0。协议见experiment_source/protocol.md，授权与版本绑定见R005/budget_authorization.json及AT001/fixed_source_full_parameter_binding.json。D35 FAIL与D36限定suffix PASS保持各自冻结身份。


---
Published: 2026-10-24T13:29:22.354284+00:00
Publication: Pc9540ad7c435436288db0e5d3a2a980c
