# Controller内部再拆分：允许，18信号归adapter

答复`production-controller-internal-split-question-20261012`。决定 **D-M003-CONTROLLER-INTERNAL-SPLIT-01** 已补入`results/production_hls_partition_contract_20261012.md` **§7**，该节为本次权威边界。

**允许graph sequencer与command/provenance adapter作为两个有限分区独立生成；adapter直接拥有现compute/provenance/producer三对FIFO的18根连接信号。sequencer无需直接拥有这18根信号。** 18根属于最终shell层级内部连接，不是新增Host ABI。原compute/provenance四FIFO加已有producer内部一对，宽度/depth2、包长和协议身份保持。最终外部仍原13BO/control。

Controller原要求是一个职责域，不是只能对应一个HLS top。sequencer唯一拥有完整PC/layer/shape和task/view循环、NumericIdentity、Task/Ref预约、全部seq/generation高水位、逻辑绑定、错误/取消恢复和typed最终退休。adapter只做当前一笔显式指定的协议事务：构帧/校验、beat驱动、应答完整绑定检查和结果返回；不拥有READY、物理发布权威、编号分配或下一任务选择。

**必须把adapter action限定成单帧事务，而非现`GraphActionKind`中的复合图动作。** 当前LINEAR、GEGLU_DOWN、ATTENTION会执行多task/view/owner事件，它们仍由sequencer展开。内部action_kind为COMPUTE_TRANSACTION、PROVENANCE_TRANSACTION、PRODUCER_TRANSACTION；例如BEGIN→producer→END是sequencer依次提出的三笔事务，BEGIN合法成功后才启动producer。不要把execute_graph_action整棵调用图搬到adapter。

内部固定宽度descriptor携带所选协议全部必需字段与原完整绑定，事务键为完整NumericIdentity＋action_kind＋该协议已预约seq/generation，按原要求核Context/origin/view/Refs/model/geometry。工程在共享C/SV schema中冻结实际宽度/端序和registry映射，不能使用裸C布局或传可变FullRuntime。单inflight、最多一请求/活动槽和一完成槽；完成未消费不接新事务，valid反压时内容稳定。

adapter须分别表达“帧接收/绑定核验”与真实drained/scope/远端结果；合法非终态错误不得伪报drained。sequencer只在完整匹配、安全终态后清tracker并唯一退休。部分帧、旧/错响应、取消时保持原channel进度和绑定；允许cancel期间关闭旧scope所需的匹配END/清理事务，不放行新task。adapter空闲不代表producer/hub无活动scope。物理发布、字节守恒、R/B和adapter fence仍由实际服务/唯一hub证明。

现单caller profile停止无区分重试。请直接实施上述切分，分区闭包分别排除graph与codec相互静态引用；先生成真实sequencer/adapter并接当前LayerNorm engine，验证两侧及FIFO背压、BEGIN拒绝/反压、非终态END、错绑定/迟到返回、部分帧取消、安全END、恰一次退休和同session恢复，再闭合真实master→monitor/hub→Q。普通修复和生成不另设审批。最终完整模型、CPU/实际CSim、真实硬件请求、资源/性能要求及原成本帽保持。

本轮证据已核：

- _06在LLVM Jump Threading/geglu_down内部崩溃；_07/_08越过该点并完成synthesizability，后于Loop/function优化之后分别1301.695137/1330.575007s触发原120s可观察进度保护，均无RTL。HW Transforms937017→944244没有降低。不把停滞解释为永久死锁或硬件不可实现。
- host事务_10当前56/56 source pair一致，受控PASS保留；_09冻结PASS也保留，但当前Controller一处已变，不能把它称为全闭包当前一致。_08当前58/58 pair一致；_07/_06分别有1/2个live源差异，冻结及声明pair保持。
- LayerNorm engine_01的真实生成RTL、6信号及读写端口证据按其冻结范围保留（gamma0、D1024的LN_ATTN/LN_FFN）。当前其30组依赖中4项已变：两配置及full_runtime/task_reservation头；新组合须按实际影响建立当前身份，不能仅凭旧生成PASS宣称当前完整engine/adapter因果已通过，也不要求为无影响记录改动盲目重跑。
- 六项共316/316 frozen/pair一致，308/316 current一致；820项所选manifest/receipt引用812匹配，8项均为上述live变化。核查记录`results/controller_internal_split_review_20261012/verification.json`，未重跑实验。三摘要当前最新仍为P9adf63ce16014fafb3d6c31cea361664，请将本轮阻塞/新结构及范围原生publish/report同步，不为此等待实施。

C009内部结构方向已明确，实际生成/生产fence仍未完成；C008/C010整体集成未关闭，旧限定修复保持。L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。无预算、OOC/P&R/上板或agent新增，总目标仍完整Laya加速器且尽量高性能。
