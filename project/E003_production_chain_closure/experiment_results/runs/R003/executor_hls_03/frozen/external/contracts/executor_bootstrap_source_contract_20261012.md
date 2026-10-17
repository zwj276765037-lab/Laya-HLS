# Executor bootstrap来源证明补充合同

决定：**D-M003-EXECUTOR-BOOTSTRAP-SOURCE-01**  
回复：`executor-bootstrap-source-question-20261012`  
范围：M003/SM003/E003/R003；补充D-M003-GRAPH-LIFECYCLE-SPLIT-01 §8，不修改Host ABI、LTX1/LTC1、LPV1/LPA1、typed任务、数值或预算。

## 1. 决定与唯一权威

允许在唯一持久hub上增加**只读source snapshot内部握手**。复用现有owner_identity、owner_model_identity、owner_descriptor、published/invalid和完整性状态的查询/比较助手；不复用QUANT帧伪造一种QUANT任务。现source_query_command包含QUANT Context、generation及原子lease副作用，不能把它直接当通用只读bootstrap接口。

snapshot只证明指定时点存在完全匹配的已发布owner，不创建/CLAIM/PUBLISH owner，不置窗口完成位，不分配或退休typed任务，不消耗QUANT generation，不替代来源保护或新Host请求准入。唯一FullRuntime仍归executor；program只接收executor已核的不可变LGP1。物理发布与读写排空仍只由hub/monitor/真实adapter状态证明。

## 2. 接口形式与匹配

使用内部有限request/response valid/ready握手，一次一个未消费完成请求；响应保持到实际consumer握手，不以组合脉冲或FIFO有空代替消费。可在HLS边界用512bit/depth2 FIFO及单帧槽转接，完整帧校验后再触发hub查询。不得跨界复制FullRuntime或tensor。

采用独立版本化小端schema（建议LBS1/LBR1；与已有schema冲突时选新的唯一magic）。工程在C/SV共享定义、byte oracle和registry中冻结精确包长/位偏移、保留位零规则；上下行每帧上限1024B，固定包长，不开无界列表。不要求一周期比较完成。查询键至少含：
- snapshot事务seq与用途/entrypoint；seq跨软取消不回退，不借用typed/portal/provenance编号。
- 已核完整NumericIdentity，包括request_id/generation/B/S及四tag；完整416B L13M。
- 完整来源BufferRef/epoch/region、stage/layer/batch/row-space/row0/rows/width/content/role；BO与本次锁存base/容量、offset/span/row_stride/batch_stride及原descriptor有关字段。
- 若物理地址由base表派生，必须绑定同一次已接受base配置及其生命周期，不能只比offset。

成功响应必须携同一事务键、完整绑定、实际Check、匹配的hub owner快照及显式SOURCE_MATCH/PUBLISHED/COMPLETE/QUIESCENT状态；不能用一个无身份READY布尔。错误响应不给可信source资格，decoder在任何头/语义/binding拒绝前清旧输出。未知/旧seq、错identity/model/epoch/role/geometry/base均不能建立逻辑镜像或发LGP1。seq有限溢出须明确拒绝，不能回绕重放。

当前NORM_LAYER1_ATTN只准入HIDDEN的encoder_00_out，目标源必须完整覆盖当前B×S/D1024/F32、batch255/row0=0及原映射角色；rows16诊断owner不能冒充S64全tensor。当前hub对普通source的支持有role等白名单；新增HIDDEN查询须明确完整descriptor/覆盖规则，不能把role改成QUANT兼容值来绕过检查。不同来源类型按原合同的对应完整性证据判断，未支持类型明确拒绝。

## 3. 排空条件与snapshot到实际使用的间隙

QUIESCENT指相关旧scope、pending END、尚未消费返回、读写债务、adapter待发/held状态及冲突lease已安全收束。信号必须来自真实状态；暂时总线idle、固定静默周期、C READY不充分。不能直接要求现hub的domain_drained为1作为snapshot成功门，因为该表达式还要求active_owners==0，会与查询一个已发布且活动的source矛盾。允许当前请求所需的已发布owner仍存在，排除的是冲突活动和未完成物理事务。

**只读snapshot不授予读lease，也不保证稍后仍可读取。** 来源失效/换epoch/换base或cancel可发生在snapshot响应后；LGP1 SOURCE_READY_PROOF仅记录这次已核事实，不能成为永久启动许可。

首个串行NORM实现可采用唯一shell的明确排他门控：从hub接受snapshot查询起到其对应action安全完成及完成末拍消费止，阻止同一source的覆盖、release/recycle、epoch/base切换及任何旁路写；目标NORM的合法CLAIM/BEGIN/END不能被该门误阻塞。producer真正获准之前重新核当前source绑定与cancel，hub确认的排他有效状态覆盖全部source AR/R、adapter读预取、未消费producer完成与所需fence。cancel在启动前撤销新启动，在启动后保留旧source保护直到真实排空；不得提前回收source。此门仅控制已有仲裁入口，不复制owner发布表。

若无法从唯一shell封住所有source变更入口，则必须在同一hub原子核验并持有通用source lease，再启动producer；允许按原source-lease职责扩展消费者类型，但须作为显式lease操作登记，不能暗中让“只读snapshot”产生lease副作用。QUANT旧lease协议和释放条件保持。两种实现只需选一种并给出完整因果证据；没有保护证据时只能签snapshot查询，不能签生产source读取。

## 4. 请求准入、检查点与高水位

executor/shell先确认旧request/action/tracker/lease/物理事务及未消费结果满足原安全条件，再进入新请求初始化。full_begin_request会清本地预约/统计，不能用于正在执行的action、未排空失败或检查点续行。使用full_decode_validate_request核真实LYRQ完整帧及AUX LYMP，之后才调用full_admit_request；拒绝时不能留下新的有效请求/模型状态。保持原request单调性与高水位，不复制整个runtime作另一准入权威。

对同一已接受request中的encoder_00_out检查点进入有限NORM，只执行来源核验/镜像和program入口，不再次begin/admit同一request。真实前序producer已用的Task/Ref/epoch、event/portal/producer seq高水位必须延续；snapshot不得清零或凭空重建这些值。若诊断prelude由TB驱动，要显式交付其真实事件历史与一致的初始高水位，区分“已发生的编号/预约下界”和本段tasks_retired统计；不可凭task最大值虚增退休数。新request的初始化与同request检查点续行须各自有明确状态入口。

source镜像是对hub事实的只读缓存，不调用能伪造物理发布的路径。相同位置已存在不同活动本地owner时先报错/隔离，不覆盖。snapshot无法恢复任意丢失的executor状态，不能把它当通用掉电/坏返回恢复协议。

## 5. 首个诊断出口和有界验证

允许冻结encoder_00_out作为数值fixture，用受控前序producer初始化当前hub；必须明确其来源和限制。用于证明bootstrap的owner须通过真实hub正常CLAIM、实际监测写入/合法原生生产证据、END/PUBLISH建立，不用层级写hub数组或直接TB READY冒充物理证明。该prelude是受控先前producer，不等于完整encoder_00真实计算；RAW import不能重标为encoder_00_out。没有匹配已发布source时正确拒绝，不能为让有限NORM启动而补造owner。

先做有界host/schema与hub RTL验证：正确全绑定准入；错request/generation/tag/L13M/Ref epoch/role/geometry/base拒绝；未发布或缺窗口拒绝；旧scope/债务/未消费返回或冲突lease阻止准入；响应反压稳定/旧响应隔离；snapshot后source失效、cancel、base/epoch切换尝试不导致非法source AR；消费后安全释放及单调后继。保留真实LYRQ/model负例和旧active action在bootstrap等待时继续cleanup的路径，避免等待自身清理的死锁。

工程可并行准备8/4 action收发、真实consumer保持和独立top；受影响host组合及源身份/保护实现通过后，按原预算串行生成有实质结构变化的executor。有限诊断证据分别标注snapshot、来源保护、executor top与真实LN/hub链，不合并成完整Host请求成功。

## 6. 状态与预算

本决定是架构合同，不是实现或验证PASS。C009继续awaiting_implementation，C008/C010整体awaiting_verification；L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。原单重工具、所有CPU/内存/时间/进度/周期帽保持；不重启5172s组合profile，不新增OOC/P&R/上板、agent或预算，G余2338.224019s不变。下一次受影响冻结闭包纳入本补充合同，旧attempt与原合同身份不改。

