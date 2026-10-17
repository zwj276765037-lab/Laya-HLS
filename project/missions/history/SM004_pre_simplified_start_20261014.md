# SM004：全模型集成与完整请求验证

mission: M004
experiment: E004
execution_state: planned
verdict: unassessed
owner: A002工程实现与验证

承接[M004](../../mission/M004_完整Laya加速器搭建与性能优化.md) G1/G2，依赖M003/SM003/E003的身份、真实链与退休/恢复前置证据；前置任务完成不作为总mission终点。

输入为E002唯一实现副本、原完整模型/请求/独立gold及已核验工程报告。将全部LN、动态量化、Q8、Attention、GEGLU/向量、28 Encoder＋2 Decision＋scorer/ACT、122矩阵、13BO和最终请求退休接成一个真实生产top。E004仅作新证据容器，不复制代码，不使用外部中间结果、黑盒占位、假completion或CPU替身。

输出：完整可构建工程与host接口、逐算子/层/矩阵/调度覆盖表、最终身份manifest、原4持久请求/141点/18,094,384 F32及故障恢复的当前CPU/真实CSim、受影响RTL及同runtime完整硬件请求证据。分段覆盖和全请求覆盖分开，缺口不能被软件PASS覆盖。

与SM005共享实现由A002串行管理；优化改变后回到受影响完整回归。资源、原数值规则、pilot与停止条件完整继承M004；全项目单重工具，RTL≤8GiB/3600s/40Mcycles，pilot≤120s，static≤24GiB/1800s。未取得整体证据或超预算保留未完成，不能缩小模型或降低gold标准。

本轮planned/NOT_RUN；工程模型请求GPT-6.1 Sol/xhigh，实际配置待证据。交付三摘要、result及SHA标记供主控核验。SM004通过只是M004功能里程碑，后续性能/资源仍必须完成。
