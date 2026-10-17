# LNQI0 主机预检交付：共同数学载荷可复用，联合RTL仍未运行

2026-10-14；D-M004-LN-QAR-IDENTITY-01；M003/M004、SM005/E005/R001；A002。回复 `measurement-first-LNF0-review-LNQI0-dispatch-20261014`。

AT041 **PASS_HOST_ONLY**。当前 production-v2 canonical 包和 AT035 真正使用的 Q8S2 actual-r2 包 GGUF、model/numeric tag相同；四完整非AUX BO逐字节相同。AUX 128B之后全同，头部仅layout/build 32B不同。Wi/Down六段原BO q0/q1/scale按原描述符抽取，与AT035冻结hex逐字节相等，原header/config K/N/offset/span、物理布局和bias0均核。原L13M与AT035 strict W身份差233/416B；L13M @64 magic非零，直接违反strict W profile=0。已从当前包派生诊断W方言fixture，但沿用AT035 BO base/cookie，仅供下一接线设计，不能视为live BO绑定或RTL PASS。

首guard因误指向cpu-embedding-ln-v4而child1/0.229s，保留原失败；同冻结脚本纠正为Q8S2 actual-r2后child0/trigger null，4.965s、peak45100KiB、CPU0–3/nice19/idle 1条policy合规。AT041收据核28输入文件引用、11输出fixture bytes/SHA；原GGUF455179648B SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。

接口判断：LN producer/monitor/hub的完整L13M和P/window/Ref必须保留；AT035后段仅保留唯一quant_task/dualA/resident/strict W。external Q受理应与完整source-query/grant绑定，G优先时不得先取lease；拒绝零AXI、活动响应隔离，response消费及实际R债退休后按原全键drained release，高水位保持。AT035 ext端目前缺L13M/portal generation，原published/owner是常量；需明确适配保存来源。STATE0 16920576B、NORM offset8MiB的真实LN目的必须由Q AR/R读取，不能继续从旧预装`0x100050000`读取；Wi/GATE/Down区域及live W BO地址需无冲突真实映射。建议下一有限static/pilot/full按报告的真实前缀和成本准入，不将AT040/AT035旧墙钟相加。LN→QAR0同runtime、完整普通Q/L及M003/M004仍NOT_RUN/未完成；本轮无RTL/HLS/OOC/P&R。

证据：[LNQI0报告](../reports/LNQI0_identity_preflight_20261014.md)、[AT041收据](../attempts/AT041_LNQI0_identity_preflight_01/receipt.json)、[机读报告](../attempts/AT041_LNQI0_identity_preflight_01/result/report.json)、[输入身份](../attempts/AT041_LNQI0_identity_preflight_01/input_manifest.json)。E005三摘要和A002真实状态已同步。请主控集中判定后继有限连接合同；工程不自行启动联合RTL。
