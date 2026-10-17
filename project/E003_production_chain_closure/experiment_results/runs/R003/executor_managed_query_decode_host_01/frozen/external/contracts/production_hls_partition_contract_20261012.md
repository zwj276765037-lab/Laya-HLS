# 生产HLS分层生成与最终连接合同

决定：**D-M003-PRODUCTION-HLS-PARTITION-01**，2026-10-12。答复`production-source-switch-hls-blocker-20261012`，适用M003/SM003/E003/R003与M004。工程仍是E002/experiment唯一实现owner。

后续内部拆分决定：**D-M003-CONTROLLER-INTERNAL-SPLIT-01**，见§7。Controller是职责域，允许其graph sequencer与command/provenance adapter独立生成；18根FIFO连接信号由adapter持有。§7对物理端口归属及内部事务粒度的明确规定优先于此前“caller直接生成FIFO”的措辞。

最新内部职责细分：**D-M003-GRAPH-LIFECYCLE-SPLIT-01**，见§8。原graph sequencer职责域可由program sequencer与task lifecycle executor分担；§8的唯一状态归属优先于§2/§7中将这些职责统称为caller/sequencer的表述。adapter事务粒度、外部接口和物理hub权威保持。

## 1. 决定与依据

**允许并采用Controller caller/shell与既有service模块分层、独立生成，最后在唯一production RTL top连接。无须继续单一HLS编译单元容纳整个执行图。** 这改变编译和内部模块边界，不改变原13BO外部ABI、四条compute/provenance私有FIFO、compute wire v2、LPV1/LPA1、typed任务及数值合同。按本合同连续实施与受影响验证，无逐次审批。

当前单体`generated_production_controller_hls_05`的115组源码与当前身份一致；_05/_06/_07均停在Compile/Link 13,223,459 instructions、Unroll/Inline pending，约375.507/380.544/375.533s触发原120s进度保护，无候选RTL。两种inline/noinline变体未产生可区分改进且已撤回。这个结果足以停止当前profile；它证明原保护条件下未完成生成，不证明编译器永久死锁，也不证明单体架构在任意预算下绝不可能。13.2M是编译IR规模，不是硬件资源或请求性能。

本决定补充联合design §3.9、M003 L1及[D-M003-GENERATED-PROVENANCE-CHANNEL-01](generated_provenance_channel_contract_20261012.md) §9：其中“实际generated controller/top”可以是当前身份下实际生成、完整连接的分层实现；不再要求全部13路master及每个算术函数由同一次HLS生成。最终top的ABI、原物理生命周期和同runtime验收要求全部保留。

## 2. 固定职责边界

| 层 | 职责与唯一权威 |
| --- | --- |
| Controller caller | 原任务图、shape/layer/batch循环、任务/Ref分配及预约、command/event高水位、BEGIN/END/owner事件、逻辑错误路径及唯一typed退休。保留完整请求，不缩层数或只生成demo调度。 |
| 非门户producer engines | 从原实现提取的实际算术/读写任务体，复用现LN、内部embedding、Attention/RoPE、向量/残差、Decision/ACT等家族边界及数值实现。返回逻辑结果与真实提交计量，不自行发布owner或最终退休typed任务。 |
| 既有compute services | LOAD、QUANT、MATRIX、GEGLU继续走原四service和wire v2，保持唯一共享fullA/fullW/PS/GATE与持久服务实例；不再在production caller内另编一条软件算术fallback。 |
| 最终RTL shell/hub | 原13BO/control接口、L13M和base生命周期、owner仲裁、真实AXI/宽度转换债务、共享provenance ledger、source lease与取消/fence，仍是物理成功/发布的唯一权威。 |

同一engine可被多个layer/task重复调用，不按28层或每条task复制算术硬件/全量缓存。调用方可保留原逻辑metadata和状态机，但不能与物理hub各自生成可矛盾的READY。禁止把整份可变FullRuntime、C指针或完整tensor搬过新控制接口；engine只获得此任务必需的冻结参数和有界局部状态。实际tensor仍使用原BO/已有缓存与布局。

生产编译必须真实切断跨边界的算术实现闭包。可采用工具支持的RTL blackbox/函数替代或各模块独立top加薄RTL连接，要求相同的下述语义。仅添加inline pragma、保留动态fallback的原完整调用图、只有C声明而没有真实engine RTL，都不算完成拆分。CPU参考及现有独立gold保留；不能用空函数、恒定ACK或Host执行代替FPGA职责。

## 3. 内部任务调用与退休

四条原私有FIFO仍为512bit/depth2、原方向与包长；它们连接真实caller和持久hub，不增Host端口或第五compute service。独立engine允许新增**仅层级内部可见**的有限参数/启动/完成接口，这不是新增门户协议或typed op。

每个engine采用固定宽度的request valid/ready与completion valid/ready语义（可以等价映射到HLS控制接口）；最多一个活动非门户任务，最多一个待接收请求槽和一个完成槽。请求/完成在反压时内容保持。工程按各原typed任务类型在共享定义中冻结字段、宽度、端序与端口映射，并登记registry；不采用C结构体padding或裸指针布局。原任务中用到的字段必须无损传递，不凭task_id算式补字段。

请求必须绑定完整NumericIdentity、原Context、所需完整Refs/region/epoch及原task参数、shape/几何、已核L13M模型绑定；有受保护写入的任务还绑定BEGIN.origin及相同descriptor。L13M可通过有应答的持久配置绑定一次，然后逐请求核同一绑定，不允许engine静默持有旧model/base。只读或无外写任务仍沿原身份、owner和读债规则，不伪造BEGIN或省略读后错误。

一个任务对象同时产生BEGIN与engine请求；BEGIN成功应答且完整绑定后才允许真实producer启动。BEGIN反压或拒绝不能提前写。compute执行与非门户producer互斥维持原合同；本次不引入新跨任务并发或改变调度次序。

engine完成返回同一身份/任务绑定、真实逻辑Check/TaskDone字段及两个descriptor的实际`issued_store_bytes`（另保留原错误/排空所需信息）。它只表示逻辑计算/提交状态。caller构造原END；物理hub完成真实覆盖、提交量守恒、总线债务和adapter fence后返回终态，caller仍要求完整匹配且`DRAINED=1/SCOPE_ACTIVE=0`才清tracker并恰一次退休原typed任务。engine完成、END和service view不能各记一次TaskDone。

取消停止新启动，保留已经获准engine、参数、posted store、返回及当前BEGIN至安全END/fence收束。reset/CE、首错归并、失败部分提交量、迟到完成隔离和同session恢复沿原合同；不得用复位子模块、丢弃完成或假drained解决停滞。每个engine实例只承接被dispatcher选中的原任务，旧完成不能交给新请求。

## 4. BO路由与真实fence

最终外部仍是原13BO、控制寄存器偏移、位宽/AXI语义及锁存基址规则。拆分后单个engine可只带所用的m_axi端口；在shell内按固定role路由到原逻辑BO端点，caller/engine共享原generated owner通路。当前八个可写bundle的写能力及全部必要读能力须在组装后的映射表和真实端口中逐项核实，不能要求每个小模块都生成冗余13路master，也不能删掉最终必要端口来过检查。

caller与任何engine的端口切换/owner交接，都必须包含已接受、已提出未接受、返回反压、converter、有限队列及adapter内部待发债务。多个物理master汇入同一逻辑BO时，原地址/Ref绑定必须在写转发前已确定；保持W-before-AW、WSTRB、4KiB/宽度转换、真实R/B错误及本地拒绝事务的安全退休。共享monitor只在明确的权威边界计一次，子beat债务完整归并。

`issued_store_bytes`须由实际engine store提交路径累计，并成为其完成/END的数据和控制依赖；失败短路只报告真正提交量。不能让caller按期望shape预填，不能把engine ap_done直接当adapter空。工程依据实际生成适配器落实“END之后不再产生未被计量及fence覆盖的旧请求”，绑定真实状态/显式排空握手；CPU变量、TB输入、总线暂时静默或只有字节相等均不充分。读prefetch、W/地址分离、合并写和拒绝事务同属证明范围。

`generated_store_monitor_07`只证明受控master/fence条件下，END早于首AW不会靠外部暂时idle提前终态；它不免除上述真实生成模块因果义务。

## 5. 连续实施与验收出口

先按当前调用图与设计尺寸报告确定最小可生成切分，记录每个原生产任务由哪个真实engine承担、哪个source/config生成、哪些状态持久。优先生成控制壳及一个实际普通producer，连接真实store helper→generated master→monitor/hub→普通Q，取得可区分的进展；其余模块沿同一模式补齐。registry/构建清单是唯一生产闭包，每个分区须有当前源码、工具/配置、生成RTL和最终连接的身份映射。不为常规模块实现再等待主控逐个批准。

必要出口：

1. 实际caller生成四FIFO共12信号并核方向/极性，最终连接保持depth2；整套top展开/连接检查核原13BO、所有控制offset和读写能力，无悬空实例或仅声明blackbox。
2. 实际非门户producer的BEGIN反压→真实数据写入→END早于首AW/末B/adapter待发门控→共享hub发布与原子Q lease→真实Q/fullA。使用原独立数值gold，覆盖成功、失败部分提交、取消、旧返回拒绝及同session恢复。受控模块测试只签各自范围。
3. 受影响调用/退休回归和当前完整CPU/实际CSim恢复到既定四持久请求、141点/18,094,384 F32及故障恢复口径；实际分层硬件连接另做同runtime验证，软件/CSim不代签。
4. 接其余Q/L/LOAD、真实matrix与全模型请求，继续M003 L2–L5与M004。新边界的启动/等待/存储开销纳入后续完整请求性能比较，联合资源中每个engine/缓存只计一次。分区分别生成不代表完整资源、时序或性能已过。

原单重工具、CPU0–3/nice19/idle I/O/MemAvailable门、static24GiB/1800s、pilot8GiB/120s、RTL8GiB/3600s及120s进度保护不变；HLS分区生成属于当前L1静态生成范围，不授权整体OOC/P&R/上板，也不增加G预算。以有限分区清单推进，不通过无界重试或改名绕过成本保护。需要full时按当前pilot速率和已冻结工作量先判断成本；原5172s组合profile保持NOT_RUN_COST。

HLS可观察进度可结合工具阶段与实际编译产物高水位；文件增长不等于算法语义进展，更不等于RTL成功。原始guard/log保留，不能将不断增长的日志/临时噪声当完成证明。拆分后仍不可在原帽内生成的分区，提交该分区的明确瓶颈与新可检验方案，继续不依赖它的工作。

## 6. 当前判定

F5在本轮单全宽窗口范围关闭；两个来源切换和早END monitor局部证据接纳。C008/C010完整集成仍待验证；C009的拆分方向已明确，实际production生成与fence因果仍未完成。此前F1/F1b/F2/F3/F4限定结论不扩大。

L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成。完整Laya加速器且尽量高性能、暂不设固定门槛的目标保持。定义与生成成功均不能代替完整工程验收。

## 7. Controller职责域内部再拆分

决定：**D-M003-CONTROLLER-INTERNAL-SPLIT-01**。答复`production-controller-internal-split-question-20261012`。允许且采用下述两个有限生成分区；不要求sequencer直接拥有三对FIFO，也不再要求“完整Controller职责域”对应一个HLS top。

### 7.1 物理端口归adapter，权威状态归sequencer

| 分区 | 保留职责 | 不迁入的职责 |
| --- | --- | --- |
| graph sequencer | 完整模型PC/layer/batch/shape及任务/view循环；NumericIdentity、全部Task/Ref预约及高水位；compute generation、provenance event/origin、producer request_seq分配；P/Q/L/owner/lease逻辑绑定与错误/取消恢复；决定何时CLAIM/BEGIN/END/PUBLISH/RELEASE/INVALIDATE；唯一typed退休与父view归并 | 帧逐byte打包/解包、外部FIFO beat驱动可移出；图与算术不可移到Host |
| command/provenance adapter | 一笔已明确指定的协议事务；固定字段构帧、包合法性和完整响应绑定核验；beat计数/反压、三对FIFO选择与传输；向sequencer返回真实响应内容及解析状态 | 不分配任务/Ref/任何业务seq，不推进模型PC，不选下一task/view，不保有READY/owner发布权威，不独立退休typed任务 |

**adapter直接持有compute_cmd/rsp、provenance_cmd/rsp、producer_request/completion三对FIFO，共18根生成接口信号。** 其中原compute/provenance四FIFO共12信号，新增的producer二FIFO共6信号是既有§3允许的内部engine连接；三对都是最终shell层级内接口，不能把“18根对外信号”理解为新增Host ABI。宽度512bit、depth2及当前每协议包长/版本保持；不增加第五compute service。sequencer与adapter以本节固定宽度valid/ready接口连接，不再绕行一份重复的FIFO驱动器。

adapter生成结果负责18信号检查；sequencer生成结果负责内部请求/完成/取消状态接口检查；最终唯一RTL shell负责原13BO/control与完整连通性检查。producer engine的反向6信号仍按其真实生成结果核验。实际FIFO深度、极性、时钟/复位/CE及所有持久状态按原合同，不因分区重建而隐式清空。

### 7.2 一笔adapter action是协议事务，不是复合图操作

内部action_kind限于三类：COMPUTE_TRANSACTION、PROVENANCE_TRANSACTION、PRODUCER_TRANSACTION，另带该协议已有op/action/family字段。每次只发出一份完整请求帧并处理其对应的一份完整应答。既有`GraphActionKind::LINEAR/GEGLU_DOWN/ATTENTION`等可能包含多任务、多窗口、多view和owner事件，**不能作为让adapter自行执行整段流程的单个action**。这些循环与预约仍由sequencer调度。

例如一个protected producer由sequencer依次发BEGIN事务、收到合法成功应答后发PRODUCER事务、取得真实逻辑结果及提交量后发END事务，再依据合法物理终态退休。adapter不隐式连发这三个事务。G/Down的128窗口计划、逐Q/L及matrix view同理。这样既保留单一权威，也避免把`execute_graph_action`整棵调用图搬入另一个仍同规模的HLS top。

内部请求为一个固定宽度、显式字段的tagged descriptor：包含action_kind、所选协议op/action/family、完整NumericIdentity、已预约的该协议seq/generation、所需完整Context/P/Q/L/Refs/model/geometry与原typed任务参数、期望响应绑定及原producer/owner字段。只携带该协议生成所需的有界数据；不跨边界传C指针、函数指针或可变FullRuntime。model常量可按既有已应答的持久配置复用，逐事务仍须核同一绑定。工程在共享C/SV定义中冻结字段宽度/端序/有效位及零保留位，并登记registry；容量采用三种现有请求字段的有限并集，不新增tensor缓存或无界队列。

事务键使用`完整NumericIdentity + action_kind + 已预约的对应协议seq/generation`，并包含对应Context/origin/view及完整绑定核验所需字段。这些seq全部由sequencer分配，不由adapter按task差值或当前packet猜测；原高水位、失败耗号、跨request/软取消规则保持。adapter可以保存当前不可变请求快照和beat进度，但不另建独立业务分配器。

单inflight：最多一个请求槽/活动事务快照与一个完成槽；请求接收后直至完成被sequencer消费或按原协议安全收束之前，不接收下一笔事务。slot不是预取第二个task的许可。valid受反压时descriptor/completion保持不变，完成只握手一次；不通过HLS无限stream或软件大队列掩盖depth2硬件进展。

### 7.3 响应、非终态与取消

adapter返回完整原事务键、响应中实际的绑定字段、Check/status/detail/bad_element、输出单位/元素数以及协议适用的drained、scope_active、parent/view状态、observed/issued/consumed等计量；另区分“完整帧已收取/解析绑定成功”和“远端任务安全终态”。各标志必须由实际帧和adapter状态产生，不能用常量echo替代物理证明。合法的非OK响应可以未排空；帧已收完不等于typed任务可退休。

sequencer核返回事务键及实际语义后更新逻辑状态。F1/F1b的规则不变：匹配END且`drained && !scope_active`之前，不清producer tracker、issued量或相关任务状态；matrix中间view/单次协议应答不触发父task重复退休。BEGIN成功应答之前不允许engine请求；owner发布仍须真实hub接受其完整证明。

请求描述非法且任何beat尚未发出时，可明确返回“未发出”的本地拒绝，无物理成功副作用。部分包已被接受、已提出VALID未握手、应答绑定失败或取消发生时，保留真实channel进度与原绑定，按原transport规则处理；不得借一个本地错误completion把事务当作drained。未知终态保持隔离，由sequencer执行既有清理/恢复流程，不让后继事务覆盖旧快照。

取消由sequencer/唯一shell控制，并显式到达adapter和实际服务。adapter停止新的任务准入，但已接受的旧事务、response背压与匹配END收束不能被清队列或复位破坏。跨BEGIN/engine/END的活动scope持久状态在sequencer/hub，即使adapter暂时无帧也不能视为无活动producer；sequencer可在cancel期间提交关闭旧scope必需的匹配END/清理事务，adapter按已有身份与取消规则转发。任何新任务仍禁止。仅在原合同允许的全域冷初始化时共同重置，软取消不回退高水位。

### 7.4 生成与验证出口

在现有registry分区登记中把controller_caller细化为sequencer和adapter，分别给出实际top、源闭包、内部接口schema及最终连接映射。sequencer的生成闭包不得再次静态拉入codec/三对FIFO exchange整套实现；adapter不得拉入graph/action家族、owner状态机和任务预约对象。保持原完整任务图与CPU参考路径，不能通过删去尚未实现的任务家族宣称整图通过。

先以现有LayerNorm路径验证真实两个分区和engine连接，再补完整生产出口。受影响验证须区分：请求/完成两侧背压、FIFO背压、BEGIN被拒/反压、合法非终态END、错键/旧响应、部分帧取消与安全匹配END、一次最终退休、同session后继request恢复；同时保留原数值gold及真实master/WSTRB/末B/adapter fence→hub→Q的证据义务。host受控事务通过只签控制语义；新内部握手必须在实际depth2连接下验证。

独立生成并记录各分区编译阶段/规模与实际RTL候选。`partitioned_controller_hls_07/_08`继续为原FAIL/semantic_stall；已通过synthesizability不等于RTL已生成，120s无可观察进度也不等于编译器永久死锁。当前单caller profile不再仅加inline-off无区分重跑。新拆分是否减小后端工作量由其实际记录判断，若仍失败，保留具体分区瓶颈，停止该无效profile并继续独立工作。

此为Controller内部实现边界决定，原预算、单重工具、完整CPU/实际CSim和最终硬件/资源/性能验收保持；无新OOC/P&R/上板，无额外审批。工程可直接按本节连续实施，M003/M004及L0–L5当前状态不因定义明确而升级。

## 8. Graph program与task lifecycle的有限分区

决定：**D-M003-GRAPH-LIFECYCLE-SPLIT-01**，2026-10-12。答复`graph-sequencer-hls-structural-blocker-20261012`。**允许并采用program sequencer与task lifecycle executor两个内部生成分区，由唯一RTL shell连接；executor必须采用共享通用步骤的有界状态机。** 这明确原graph sequencer职责域内的分工，不新增service或Host端口。工程可按本节直接实施、冻结共享schema并执行受影响验证，无需逐项再审批。

### 8.1 证据与结构要求

`graph_sequencer_hls_01`在当前原保护条件下为FAIL/semantic_stall：1336.192305s、7005432KiB，完成synthesizability和Loop/function优化后120s无新可观察进度，未生成RTL。Compile/Link总规模2,223,180；`graph_partitioned`为2,145,023，`execute_graph_action`为2,144,057，占前者99.95%。这是含下级调用的编译IR规模，不能相加当资源，也不是性能计量。

因此，**只把原`execute_graph_action`调用树搬到另一个top不足以构成下一次重工具的实质缩减方案。** executor以一个活动action快照、持久局部游标和共享有限步骤执行reserve/claim、构造事务、发送/等待、核实际绑定、记录实际提交、END/fence、退休、释放和局部循环推进。窗口、tile、view和family选择采用有界计数/分支或等价有限控制；公共生命周期/身份操作不按family、layer或task克隆。不要再从一个同步action入口静态拉入全部旧family方法树，也不复制多个FullRuntime作为各family独立权威。可以复用原语义助手，但生成闭包和调度结构须有可核查的实质变化；不要求所有步骤在一周期内完成。

保留完整模型PC、28层encoder与2层decision、所有合法shape/batch、17类GraphAction的语义与原任务顺序；内部串行化不能改变数值计算顺序、独立gold或任务/预约语义。首个LayerNorm子集可以独立生成、测试并登记限定范围；暂未实现family须在预约、AXI及owner副作用前明确拒绝，不能空操作成功，也不能以子集生成宣称全图通过。下一次HLS的规模下降与生成结果由实际证据决定，本决定不保证必然生成成功。

### 8.2 唯一权威分配

| 分区 | 唯一可变权威与职责 |
| --- | --- |
| graph program sequencer | 完整模型PC、layer/shape/batch控制循环、下一GraphAction选择、graph slot逻辑别名及action transport ordinal；接收完整绑定的安全完成后提交slot变更和推进PC；给出request级逻辑完成/错误意图。 |
| task lifecycle executor | 经原规则验证的请求/模型绑定、NumericIdentity及全部Task/Ref/epoch预约、高水位；compute generation、provenance event/origin、producer request_seq；逻辑owner/lease/native状态、生成tracker、真实issued量、首错、BEGIN/producer/END及错误/取消收束；唯一typed退休和父view归并。执行当前action所需的有限窗口/view循环，不选下一GraphAction。 |
| command/provenance adapter与F10 shell | 保留现有LTX1/LTC1及三类单笔协议事务，18根外部FIFO连接信号仍归adapter；真实完成消费门控仍归F10 shell。没有graph、owner发布或typed分配/退休权。 |
| 唯一production shell/持久hub | 原13BO/control、物理准入/覆盖/债务/adapter fence、owner发布及原子source lease的最终权威；协调原request准入、错误报告和物理安全条件。 |

program的graph slots只存逻辑索引/有版本的句柄与路由所需只读信息，不能另存可自行修改的READY或owner/lease表。executor核源句柄/版本与自身权威状态，返回有界slot增量；program仅在完整绑定且安全成功的action完成上提交正常输出slot变更。失败使program停止正常PC推进；任何旧slot都不能绕过executor重新准入。释放/失效导致的slot更新也须来自已确认的真实结果。

原请求解析、模型/基址绑定与结果写回各只有一条权威路径。shell冻结一次Host请求，executor完成原请求/模型核验并将已接受的不可变identity/model/shape配置握手给program；program可持只读副本，不独立再次分配身份或接受不同模型。model常量可以复用已应答的持久配置，逐action仍核绑定。现有完整结果路径可留在executor/shell，不能因分区遗漏原输入校验或错误结果。

`PC_DONE`只表示图的逻辑终点；成功Host结果及后继请求准入仍须等待executor确认相关任务退休、lease清理及原合同要求的真实物理债务/fence条件。未排空错误可按原状态规则报告失败/隔离，不能因此报告成功或放行覆盖旧状态。不得把program停止等同整个Controller安全空闲。

### 8.3 内部action协议与消费边界

两分区用固定宽度、版本化、小端的request/completion，经512bit/depth2内部FIFO连接；只在层级内部可见。工程在共享C/SV定义中冻结精确字段、位宽、包长、零保留位及版本，采用必要字段的有限并集并登记registry。不得跨界搬运FullRuntime、整份可变GraphState、C指针/函数指针、tensor或无界队列。

请求键包含完整NumericIdentity和单调action transport ordinal，并绑定PC/action_kind、layer/stage/batch/shape、源slot版本句柄、目标role/shape、weight/region/bank、K/N/length、qkv/inplace/bias等当前原action必需字段。ordinal仅由program分配，跨软取消/恢复防重放；它不是typed编号或portal/provenance/producer seq，后四类仍由executor独占分配。高水位、失败耗号和恢复规则须显式冻结，不能从task差值猜测或通过局部复位回退。

完成携带实际action键和完整绑定、真实Check/status/detail/bad、显式可信/安全终态/排空状态、有限slot增量与该action的退休结果。只有实际检查结果能置可信标志；坏头或错绑定清除可被后续误用的旧完成内容。action完成不另增一个typed task；原TaskDone恰一次语义保留。

最多一个活动action、一个请求槽和一个完成槽。请求可逐拍接收，但完整语法/身份/源句柄通过前无业务副作用。当前action安全收束且其完成包被program**实际消费最后一拍**后，下一周期才能接收后继action首拍；入队末拍不是消费完成。两侧反压内容稳定，末1/2拍停读及后继两拍已排队时不得提前消费或产生新事务。若采用非终态状态上报，其消费不释放活动action；executor继续持有原绑定，不接受下一action或靠重新派发整段action重做副作用。

executor独占现有LTX1/LTC1调用端；program没有旁路到adapter。executor依次提交BEGIN、PRODUCER、END等原协议事务，BEGIN完整成功后才启动producer，从真实completion构造END，核真实hub终态后退休。adapter仍不自动展开这些复合操作。现有F10 shell应接到executor的真实LTC1 consumer握手；新action边界另实现同等消费语义，不能把两层计数混为一个。

### 8.4 非终态、错误与取消

合法且完整绑定的未排空END可由executor持原身份串行重试；每轮重新核FRAME_COMPLETE、BINDING_OK、非LOCAL_REJECT及实际response。坏头、错旧键或缺可信标志停止自动重试并保留tracker/scope，不能沿用上一轮响应；F6/F7/F8/F9已有规则保持。只有匹配END且`drained && !scope_active`等原安全条件成立，才清tracker并唯一退休。首错及部分提交按实际完成/物理计量保留。

cancel由唯一shell到达program、executor、adapter和相关服务。program停止发新action；executor阻止新任务启动，同时继续旧活动action所需的匹配END、lease释放和错误清理。已发半帧、posted store、返回反压、未消费完成及未知终态全部保留原身份。取消不清队列、不清owner/高水位、不局部复位；程序结束或内部完成FIFO空也不代替安全排空。未发出producer的本地拒绝仍须按F6释放真实source lease并关闭既有BEGIN。

旧/错completion隔离之后的恢复必须另有实际恢复路径和证据；仅保留scope可签隔离，不能写成已恢复或drained。同session更大request/task/各协议generation恢复仍须保持原单调性及唯一退休。

### 8.5 连续实施与验收

工程先登记17类action→有限步骤/真实service/engine的映射、状态权威及两分区source闭包；冻结schema与共享byte oracle。先做受影响host组合和真实Controller生命周期回归，再按原帽串行生成有实质结构变化的分区。program闭包不得静态拉入executor/旧全family实现；executor不得回调program选下一action或夹带外部codec/算术实现。独立生成清单不得变为无限family top或无界试跑。

第一个实际出口为program发出真实LayerNorm action→executor→现F10 shell/adapter→实际LN master→monitor/唯一hub，并从真实completion产生END、恰一次typed退休、返回实际action完成；然后保持既有独立gold接source lease→Q/fullA。覆盖depth2两层反压与末拍消费、BEGIN拒绝/反压、非终态END、错旧返回、部分提交、活动取消和同session恢复；未执行的路径明确待验证。诊断action通过不代签全S64 tensor或整个graph。

随后按映射补全部family、完整tensor多窗口/multi-role/QKV、LOAD/MATRIX、当前完整CPU/实际CSim和最终原13BO请求。完整图不能在未实现family上跳过或缩层；各分区资源与buffer、转接状态在最终联合资源中计一次，额外控制周期纳入性能分析。独立HLS、host或TB caller通过均不等于最终连接通过。

原单重工具、CPU0–3/nice19/idle I/O/MemAvailable>192GiB、HLS/static24GiB/1800s、pilot8GiB/120s、RTL8GiB/3600s、项目40Mcycles上限与更严格入口帽、120s进度保护保持。完整运行先依据当前同profile pilot与冻结工作量准入；不重启5172s组合profile，不增加OOC/P&R/上板、agent或预算。C009部分实施、C008/C010整体待验证，L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST和M003/M004未完成保持。
