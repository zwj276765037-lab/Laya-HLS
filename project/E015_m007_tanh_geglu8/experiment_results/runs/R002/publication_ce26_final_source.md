# E015/R002：TANH-IDLE-CE-26 来源摘要

采用SM011合同与架构§13。A008只新增core_v2/tanh8_v2及必要TB/runner/source/E015 R002，旧v1、G、共同资源与父均未改。core13df84ea…dd10、wrapper8c37896c…f248的精确身份/接口/6个生产依赖见[manifest](../experiment_results/runs/R002/ce26_production_manifest_v1.json)。

CE覆盖原2447 core时序块和42 leaf aclken，reset优先；完整152bit token_empty逐核归零/8核AND。统一CE为reset、活动lease、本拍lease/request接受、真实pending/inflight、任一token非空或protocol_fault之OR。wrapper握手/credit/tag/result/故障与实际clk持续运行；无新FF、无时钟门控、数学DAG/舍入可逆恢复原字节。FORCE_CORE_CE为编译参数，默认0自动/1验证控制。

原R001 AT007 vectors/AT018 nodes/AT052 schedule独立参考复用，无新gold。三版本同runtime检查全部公开控制事件和有效data/status/tag/mask；4096主样本含原384 corners及3712真实值，加原fullcredit/reset/status阶段和新generation64标量，共6726有效消费。core152拍与公开153拍分别测量。

独立实验只支持有界数值/协议等价、完整静态CE/reset覆盖及idle冻结。内部alignment/credit corruption无合法公开注入口，动态反例NOT_RUN，fault高必开CE静态核通过。A007唯一后继joint集成并测force1/auto0实际成本；本结果不含joint加速/物理时序/完整Encoder。独立预算已封存不转移。
