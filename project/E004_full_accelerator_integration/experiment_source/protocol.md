# E004：全模型集成与完整请求验证

当前操作协议以 `project/missions/SM004.md` 修订10末节为准：AT040真实前LN row0输入，原独立Wi/G/Q/Down逐项与最终1024个F32为gold；每次尝试冻结RTL、IP、TB、runner、fixture并附SHA清单，guard记录真实命令、CPU0–3/nice19/idle、MemAvailable>192GiB、owned RSS、单次墙钟和语义进展。正常cold/warm、受影响短测、成本停止分别保留原始终态，shell退出0须再核最终PASS且无Fatal/ERROR。修订10static累计1800s、RTL含pilot累计3600s，不借旧预算或重跑整模参考。当前没有新OOC/P&R/模型前向授权；主控AT166预算分类勘误以真实命令归类。

M004/SM004；本页以下首版准备说明保留原时点。当前实际阶段为 AT091 软件基线、AT101 向量服务与 AT107/108 LN 单行局部证据，见[现行 SM004 合同](../../missions/SM004.md)与[本批结果](../experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md)。完整合同见[M004](../../../mission/M004_完整Laya加速器搭建与性能优化.md)。

唯一实现根为/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment；本目录只保存新阶段方案、三摘要与新运行证据，experiment空目录不作为第二实现树。原E002工程验收交付不改。

原模型/shape/层数/独立gold/数值规则与资源保护不变。用户要求完整搭建、尽量高性能，不设具体速度或改善百分比门槛；需要完整请求级可比证据，局部或理论估算不能代签。首版写下时没有真实 run；现在每次原命令、冻结输入、guard、日志和结果保留在 `experiment_results/runs/R001/attempts/AT*`，解释与当前身份以各阶段结果和机读证据为准。
