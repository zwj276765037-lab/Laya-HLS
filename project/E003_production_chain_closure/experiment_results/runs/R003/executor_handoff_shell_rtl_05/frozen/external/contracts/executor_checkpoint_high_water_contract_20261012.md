# Executor诊断检查点高水位补充合同

决定：**D-M003-EXECUTOR-CHECKPOINT-HIGH-WATER-01**  
回复：`executor-checkpoint-high-water-question-20261012`  
范围：M003/SM003/E003/R003；补充D-M003-GRAPH-LIFECYCLE-SPLIT-01及D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01。原13BO/control、Host ABI、LTX1/LTC1、LPV/LPA、LPE/LPC、数值与预算不变。

## 1. 采用受限只读下界交接，不引入事务重放入口

采用问题中的**方案1，但读取权威是唯一shell汇总的hub与实际transport状态，不能把所有下界都声称来自hub**。本阶段不新增方案2的通用历史导入/重放接口，不向hub重发已经完成的BEGIN/END，不为旧task补造TaskDone或再次退休。

本入口仅用于首个有限`NORM_LAYER1_ATTN`硬件诊断：同一真实已准入请求，正常受控encoder_00_out前序，经真实写监测、END/PUBLISH形成完整source；由串行、排空的前序入口交给唯一executor。它不是完整graph正常路径，也不是任意旧请求、软复位后丢失runtime、异常/部分提交或跨session恢复接口。完整graph继续由同一持久executor保留全部预约/高水位及退休状态；正常checkpoint不重新导入或清状态。

后续新诊断的推荐且本合同采用的时序为：唯一executor先按原LYRQ/LYMP路径准入一次→保留该请求绑定并等待→受控前序在同绑定下正常执行→前序入口实际排空并交出派发权→只读检查点下界快照→executor构造LGP1并开始真实action。同request checkpoint不再调用full_begin_request/full_admit_request。不要把运行过前序、但executor丢失准入状态的系统作为本入口的隐含恢复模式；既有冻结实验无需为调顺序而重跑。

## 2. 下界的权威、覆盖范围与未知处理

| 域 | 本次可用真源 | 交接语义 |
|---|---|---|
| 当前NumericIdentity的最后安全终态task号 | hub的`typed_valid/typed_identity/typed_last_task`，对应真实END终态 | 它是最后终态编号，不是已退休数量，也不覆盖hub未见的CPU/compute任务或未发送预约。 |
| LPV event序号 | **`laya_generated_provenance_v1.last_event_seq`**，由唯一axi portal/shell连接 | 它属于transport，包含可信头在真实response末拍消费/既有取消路径留下的高水位；不能用hub `accepted_events`计数替代，也不能取源owner最近一次event来忽略更大的已耗序号。 |
| source及本action目标Ref epoch下界 | hub原`owner_max_epoch`及owner物理域表，结合保留的executor Ref预约 | 按实际分配域/物理等价类取保守最大值，含已释放、失效或旧请求的历史下界；不得仅镜像source当前epoch。 |
| producer request_seq、compute generation及尚未外发的预约号 | 原持续executor/对应唯一transport的现状态 | hub没有这些事实；不由新快照伪造。首诊断未经过LPE1，producer从真实保留的未使用状态开始，不按前序task或LPV数量换算。 |
| action ordinal | **program的持久`action_high_water`**；executor保留其接收/完成校验下界 | 沿原program唯一分配权，不能转交hub分配或由executor重新置零。 |
| snapshot序号和base/session生命周期 | 唯一shell/bootstrap持久状态 | 与其他域分开，软取消不回退；完整绑定采样时的硬件实例/配置epoch。 |

每个读出域都有显式KNOWN/COMPLETE语义与所属identity/session/base配置。缺失typed表项、只看一个source owner、未观察过的transport或“零值”都不能自动表示下界为零。零只能来自该权威域自真实初始化以来确实未使用的完整状态；这不是TB传入的“未使用”布尔。

**本有限导入只接受没有未知耗号/预约的安全前序。** 前序只使用本shell观察到的单个provenance生产路径；没有隐藏的compute/CPU task、未发送预留task、半帧、旧返回、活动scope/lease、未关闭writer或其他调用者。已分配未发送的号仍由其原分配权威保留；如果下界与最后安全终态不一致或存在未知空洞，拒绝本诊断导入，继续原持久runtime清理，不按编号差构造退休事实。对于四窗口正常前序可动态得到task下界4、LPV下界10；这两个值只是该fixture的预期，绝不能作为实现常量。

## 3. 固定版本、原子快照与派发权交接

新增**LBS2/LBR2、version2、固定1024B/16个512bit字**的内部查询/应答，继续原单inflight/depth2/完整帧验证与真实consumer语义；不挪用LBS1/LBR1的保留位静默改变v1含义。v1的768B源码/冻结证据保持；v1只证明source事实，不能使能v2诊断下界导入。受影响新top/shell/guard使用匹配v2 schema，未知版本/包长明确拒绝。无需新增Host端口。

保留完整NumericIdentity、416B L13M、source descriptor、锁存base及snapshot事务键。扩展区明确携带：诊断模式和交接epoch、**一个目标分配域键**（Buffer/bank/region/role及其锁定base/offset等原物理映射必需信息）、对应已知状态/占用状态/epoch下界、hub终态task下界、LPV transport高水位及各域有效性。首入口只支持一source/一target；不做全owner表导出或无界列表。若任意域不能以此有界格式完整表达，则拒绝该模式，不能截断。C/SV逐字节布局、flags、保留位、长度与独立oracle由工程冻结登记，无需再逐字段请批。

查询本身仍只读，不增加owner、lease、TaskDone或typed退休，不改变hub的Task/Ref/发布权威。shell可以锁存权威读数形成一次response，不另设可独立修改的高水位/发布表；LPV下界直接接真实transport，禁止新造一份event计数器冒充它。

快照要求同一个交接点的完整状态：先允许旧事务和返回正常排空，再锁住前序派发/新编号生成入口，采样hub/transport/目标域；响应反压期间读数稳定，直至executor消费并一次性接受。**不能在等旧END时先锁死其cleanup入口。** source保护保持原合同；目标域在快照至第一次CLAIM之间也不得被其他writer重新预约/发布，或必须在CLAIM前真实重绑定。snapshot前后base/session变化、cancel、未知债务或交接权不唯一都阻止LGP1/action准入。

部分帧、坏绑定/旧seq、缺有效位、非法状态或溢出均不能留下部分导入状态。先校验所有域、容量及全部增量，再一次提交executor下界/只读source镜像；已消费交接不得在同请求中重复应用。重复/较小读数不能回退本地现有高水位，也不能清错误或扩大准入。失败后仍由原活动runtime继续cleanup。

## 4. 预约、退休比较基线与统计必须分开

当前`full_retire_prepared_task`要求`task_id == rt.last_task_id + 1`。所以仅把TaskReservation提高到4而让比较基线为0，会使真实task5退休失败；不能只解决分配端。

允许在**上述限定、完整、无未知预约空洞的检查点导入**中，保存独立的`checkpoint_task_base`及其来源绑定，并把退休顺序比较的前驱游标初始化到这份真实hub最后终态task号（实现可由专用helper设置现`rt.last_task_id`，必须明确这是外部已见终态的检查点基线）。同时把TaskReservation提高到不小于所有真实已知预约下界。已有本地状态不能被较小快照覆盖；不兼容的基线/预约关系拒绝导入。

**这不是本地退休操作。** 导入不调用正常retire函数、不构造旧TaskDone、不增加`tasks_retired`/`op_calls`/owner_claims/完整层数或成功统计。全新诊断段的本地tasks_retired从0开始；若本地原本已经有真实退休，则保留其统计并按本段起点计增量，不清零重做。请求成功/完整图完成不能由这份基线推导。

之后task仍经原真实completion→匹配安全END→唯一retirement路径提交。当前四窗口诊断必须体现：导入base4后本段0次退休；实际task5–8各退休一次后本段为4，LAC1报告first5/last8/count4；hub前序四次与后段四次可各自核对，但executor不得把task8或编号差直接写为“本地共退休8次”。本段完成数量以真实退休增量为依据；连续first/last只作当前NORM的额外一致性检查，不能把跳号或失败耗号算作退休。

Ref下界只能导入预约cursor或明确无READY的epoch历史缓存，不创建目标owner。目标不存在且全域扫描证明未用过才可用0；已有inactive目标取历史最大epoch后递增；已存在活动目标、未知alias/旧base或不可安全复用状态拒绝，不能凭一个最大epoch覆写。`owner_max_epoch`、allocator Ref等价规则与实际CLAIM准入须对齐。task/Ref按kMaxEpoch、event/producer/action等按各自位宽做启动前溢出检查；失败不得回绕。

## 5. 首轮有界证据

先完成schema、host组合和受影响hub/shell证据，再按原帽串行生成有结构差异的executor。独立字节oracle比较v2完整帧；保留v1限定兼容，不修改旧attempt。

至少覆盖：

- 正常动态前序下界，导入不增加任何本地退休/发布统计；后续真实task从下一个合法号开始，完成量只来自真实退休。
- 前序任务号/event号不是4/10的合法受控变化，或已有更大LPV transport耗号；不得硬编码、用accepted_events替代、忽略本地更大保留值。
- 目标有旧inactive epoch、active目标、物理别名/未知base；正确递增或无副作用拒绝。前序没有producer请求时核其真实未使用状态；同持续executor已有更大producer/action编号时保持并严格递增。
- 错identity/model/source/target/base/交接epoch、旧/重复snapshot、缺KNOWN/COMPLETE、未知分配空洞、溢出与部分/错误帧；不发LGP1、不产生新预约/owner/退休副作用。
- 查询等待期间旧END/末B/返回能排空；响应持有时阻止新的前序派发与目标变化；真实末拍消费后仅一次交接。cancel/变base不能用旧proof启动。
- 原F15完成消费释放、F16实际codec返回语义及真实source AR/F9/physical fence边界继续按受影响范围验证。

只签诊断checkpoint、executor硬件入口与所测NORM范围。它不代签前段encoder算术、完整17类PC、完整Host请求/模型/性能、任意checkpoint恢复、联合资源或物理时序。

## 6. 执行与状态

这是架构决定，不是新实验PASS，也不审核来信简述的F16/LN_05结果；它们按独立交付身份验收。工程可直接实施以上v2/helper/有限握手与验证，独立脚手架和当前受影响兼容继续，不需逐项审批。

C009部分实施/awaiting_implementation，C008/C010整体待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST、M003/M004未完成。原CPU0–3/nice19/idle I/O、MemAvailable>192GiB、单重工具及各入口更严格帽保持；G OOC余2338.224019s，5172s组合不重启，无新agent、OOC/P&R/上板或预算。下一次受影响冻结闭包纳入本补充合同，旧合同及attempt不回写。
