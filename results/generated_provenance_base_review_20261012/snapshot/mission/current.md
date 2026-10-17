# 当前 mission

最新用户决定：完成完整Laya加速器搭建，并尽量实现高性能；暂不设置具体延迟/吞吐/提升百分比门槛。当前总任务为M004，不能在生产链接入后结束。

最新阶段审核：[R-SM003-GATE-SPLIT-CURRENT-20261012](../results/reviews/SM003.md)接纳当前共享实例的四窗口G→独立Q0→fullA回归；上一审核的当前GATE split子项已完成。工程继续来源切换、其余shape/跨batch和真实provenance/hub/caller，下一次full前修复成本入口使用当前pilot速率。C010剩余集成项、C008/C009及M003/M004未闭合，组合成本缺口与原预算保持。

最新生产接口：[D-M003-GENERATED-PROVENANCE-CHANNEL-01](../results/generated_provenance_channel_contract_20261012.md)依据实际端口缺口增加内部provenance请求/应答FIFO，定义非门户producer的写前Context绑定、物理END与owner事件。内部由两FIFO改四FIFO，原13BO外部ABI及compute v2保持；工程连续实施/验证，M003/M004状态与全部预算不变。

2026-10-12补充：[普通Q/L source provenance](../results/ordinary_linear_provenance_contract_20261012.md)确定逐窗口真实覆盖闭合Context、完整覆盖及独立tensor发布门，涵盖Attention/QKV/向量/原地更新与恢复。P定义已明确；物理来源链仍须实际generated连接与AXI退休证据，工程继续原授权实施，M003/M004状态不变。

最新生产接口决定：[D-M003-MODEL-IDENTITY-13BO-01](../results/model_identity_13bo_contract_20261011.md)已定义原13BO的416B L13M v1身份及五模型BO固定生命周期绑定；不使用Q8S2注册编码，保持原wire v2/包长/STRICT。工程按原授权接入caller/hub并验证受影响边界，定义明确不代表实现通过；M003/M004及组合full成本缺口保持。

| ID | 状态/定位 | 当前入口 |
| --- | --- | --- |
| M001 | completed / supported，复制接入 | 保留已验收结论和原baseline |
| M002 | planned / inconclusive，历史完整目标 | 原合同保留；重叠实现由M004统筹，不重复派发SM002 |
| M003 | running / unassessed，L0/L1 PARTIAL，M004前置 | [当前身份与真实生产链](M003_当前身份生产链接入与回归.md)，SM003/E003/R003；通过只解除前置依赖 |
| M004 | 当前总mission / unassessed，前置进行中 | [完整Laya加速器搭建与性能优化](M004_完整Laya加速器搭建与性能优化.md) |

执行关系：M003身份/真实链/安全退休→SM004/E004全模型集成和完整请求验证→SM005/E005完整请求性能优化及资源闭合→最终集成回归与主控总验收。依据实际依赖迭代；普通修复和里程碑不新增逐轮用户审批。唯一实现根E002/experiment，A002单owner，新E仅存证据。

[goal v3](../goal/goal.md)与[范围修订](../results/mission_scope_revision_20261011.md)优先于旧主控报告中“仅有界连接为下一总任务”的表述。完整模型、数值/独立gold、原baseline与全部工具预算保持不变。20%/5%建议未采纳，50ms不是硬门槛。

工程验收仍为完整加速器NOT_ACCEPTED；旧软件/局部硬件范围PASS、两项OOC COST_STOP及历史文档SHA缺口保持原结论。工程交付result/handoff→主控核验真实完成轮次与SHA→阶段判断/目标更新的合作顺序不变。

此前范围合同修订completed/未启动实验是该修订轮次的历史状态。工程现已执行E003/R003，L0/L1尚未完成；最新quant/G接口问题由主控确定为[门户v2补充合同](../results/quant_g_portal_contract_v2_20261011.md)：显式三Context/future-dst、有限未来任务预约、G与quant分期、rows16父任务跨view租约。定义已明确不等于实现PASS；工程继续受影响实施/验证，SM004/SM005和M004总验收尚未完成。

工程请求GPT-6.1 Sol/xhigh，集中评判GPT-6 Astra/xhigh，actual无证据保持null。全项目单重工具，G余2338.224019s不重置。主控此次仅定义补充接口，未启动工程工具；工程按M004完整目标继续，不把局部阶段完成写成整体完成。

最新生命周期补充：[D-M003-PORTAL-GENERATION-01](../results/portal_generation_lifecycle_20261011.md)。每command门户代号严格递增，跨G/Q/L和view的实体/父lease身份独立保持；高水位跨请求/软取消保留，可信首拍与取消/失败响应耗号规则已明确。原quant/G §3.3歧义已修正，工程补受影响验证，不把已有transport局部PASS代签新边界。

最新阶段审核：[R-SM003-V2-PARENT-20261011](../results/reviews/SM003.md)接纳v2 codec/transport、诊断native LOAD、旧单view matrix、有限预约与独立真实fullA父lease六项局部证据。L0/L1 PARTIAL、L2–L5 NOT_RUN保持；工程连续推进真实matrix多view/W pin/首错/父TaskDone、tensor覆盖、GATE/source provenance及caller/单持久hub，不新增逐步审批。

后续GATE/matrix父路径里程碑：[R-SM003-GATE-PARENT-20261011](../results/reviews/SM003.md)接纳同epoch tensor metadata与诊断matrix四view父控制/末B/受控rank归并的局部功能PASS；真实cache/payload及生产caller/hub仍待集成。工程已确认matrix_parent_views_07以600s pilot执行382.907547s且无先行成功短pilot/full估算，成本为DEVIATION；历史不改名追认或补跑。后续入口已在源中恢复120s pilot、分离3600s full并加估算停止，尚未核验实际运行；成本拒绝的receipt一致性需常规修复。现合同内独立工作继续，M003/M004状态不变。

最新物理链审核：[R-SM003-GATE-SPLIT-20261011](../results/reviews/SM003.md)接纳四G窗口64行→独立Q0的16行→真实fullA局部运行，复用原四行fixture；194/194身份及12/12fixture引用匹配。matrix成本拒绝记录修复已核定；新发现无条件周期日志可能刷新停滞保护，工程须在下一相关full前常规修复并有界检查。继续实际fullW父matrix、其余Q/L和LOAD调度及持久hub/caller；L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成，全部预算不变。

最新真实缓存审核：[R-SM003-MATRIX-PARENT-CACHE-20261011](../results/reviews/SM003.md)接纳预量化fullA→实际fullW→父matrix四view同runtime局部PASS，94/94身份引用匹配，独立PS/最终gold及末B/父退休通过，tensor前16/256行未提前READY。新格式work保护已补有界证据，旧格式/缺字段解析仍需常规修复。继续实际G/Q直接接matrix、多父tensor及失败、其余调度/hub/caller；M003/M004和L0–L5状态不变。

最新组合成本审核：[R-SM003-GQM-COST-20261011](../results/reviews/SM003.md)接纳实际G/Q→父matrix组合TB static与一行G pilot，166/166身份引用匹配；5172s成本投影超原3600s，_03 full未启动/COST_STOP，同runtime完整运行仍NOT_RUN_COST。_01已启动后主动终止的原FAIL/sigterm保留。guard旧格式/缺字段修复已核定；工程继续独立集成及预算内仿真成本改进，保留完整链验收缺口，不加帽或拼接PASS。M003/M004未完成。

<!-- research-agent:identity-index:begin -->
## Registered identities

This index records identity and links only. Execution, conclusions and user decisions remain in the linked records.

| Mission | Title | Contract | Summary |
|---|---|---|---|
| M001 | 工程复制与Research接入 | [contract](../mission/M001_%E5%B7%A5%E7%A8%8B%E5%A4%8D%E5%88%B6%E4%B8%8EResearch%E6%8E%A5%E5%85%A5.md) | [summary](../results/missions/M001_summary.md) |
| M002 | 完整Laya加速器实现 | [contract](../mission/M002_%E5%AE%8C%E6%95%B4Laya%E5%8A%A0%E9%80%9F%E5%99%A8%E5%AE%9E%E7%8E%B0.md) | [summary](../results/missions/M002_summary.md) |
| M003 | 当前身份生产链接入与回归 | [contract](../mission/M003_%E5%BD%93%E5%89%8D%E8%BA%AB%E4%BB%BD%E7%94%9F%E4%BA%A7%E9%93%BE%E6%8E%A5%E5%85%A5%E4%B8%8E%E5%9B%9E%E5%BD%92.md) | [summary](../results/missions/M003_summary.md) |
| M004 | 完整Laya加速器搭建与性能优化 | [contract](../mission/M004_%E5%AE%8C%E6%95%B4Laya%E5%8A%A0%E9%80%9F%E5%99%A8%E6%90%AD%E5%BB%BA%E4%B8%8E%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96.md) | [summary](../results/missions/M004_summary.md) |
<!-- research-agent:identity-index:end -->
