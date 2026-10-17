# 普通QUANT/MATRIX的窗口producer凭据

决定：**D-M003-ORDINARY-SOURCE-PROVENANCE-01**；日期：2026-10-12（Asia/Shanghai）；答复 `ordinary-linear-provenance-question-20261012`。

本补充明确[D-M003-QUANT-G-V2](quant_g_portal_contract_v2_20261011.md) §2.2/§3.1的普通source provenance。原模型/shape/数值、13BO、wire v2字段与包长、四service、原任务op、预算及单owner分工不变。工程继续已有授权实施；本决定不是实现PASS。

## 1. 选择与含义

采用问题**第3项的逐窗口形式**：P取现有真实typed completion中，使**这个source窗口的全部所需输出覆盖首次完整**的那条任务的原始完整Context。P是该窗口覆盖完成事件的锚，**不代表整个tensor由一条任务生产，也不代表整个tensor已经发布**。

窗口凭据必须同时关联完整覆盖证明和独立的整tensor发布状态。准入条件是“正确窗口锚＋全部贡献覆盖＋该epoch完整tensor已发布（或其合法旧epoch独占读租约）”，不能只比P或只查READY。由此不需要新增虚拟publication typed task/TaskDone，也不把producer集合装进门户包。实际多producer覆盖ledger仍然必需，是对原合同完整覆盖要求的具体化。

`full_publish_owner/full_publish_att/full_publish_qkv_pair/full_commit_*`继续是owner状态转换，不分配task_id，不伪造TaskDone，不增加op_calls/tasks_retired。若此前某窗口已完成，后来的全tensor发布只使它可被消费，不能把该窗口P改写成全局最后一个task。

## 2. 权威记录与有界生命周期

每个普通source owner/epoch关联如下记录。表为**内部逻辑字段**，不是新增wire偏移；相同owner的共享字段可只存一份。

| 字段 | 含义/供给者 |
| --- | --- |
| identity / model_identity | 完整NumericIdentity及当前canonical L13M；从实际producer发射绑定保存，不从后来的QUANT补贴 |
| owner | 完整BufferRef（含bank/epoch）、region、真实FullOwnerSpec的stage/layer/row_space/范围/width/content，及实际BO布局 |
| extent | batch、row_space、row0、rows、逻辑feature范围；普通Q源必须完整覆盖K个F32 feature |
| contribution evidence | 已绑定真实typed任务的输出范围；Attention含head，QKV含pair/plane/head；实际成功输出覆盖、错误及债务状态 |
| close_context / close_valid | 覆盖首次完整的成功typed任务的原Context；记录后在此owner epoch内不可覆盖 |
| publication / invalid | 整tensor发布事实及sticky失败；与window_closed分开 |
| read/old-lease state | 当前读者、旧epoch独占读权限、已消费范围及相关真实读债务 |

普通线性源沿现Controller的标准窗口划分：每个batch内从owner起点按16行，尾部取剩余1..16行；TOKEN最大每batch64窗口，B≤2共128；MARKER最多每batch1窗口，BATCH每batch1窗口。当前普通Q与标准窗口一一对应，MATRIX的rows4/rows1 view不另分source窗口。不得在QUANT时临时拼几个不同P、缩改原Context或覆盖旧记录来支持未定义的窗口重分割。

保守容量按现32个owner槽、每槽最多128窗口计4096条；原EXCLUSIVE_RW/QKV RoPE需要保留旧epoch证明时，最多两个owner额外各128条，合计上界4352条窗口记录。普通原地操作与QKV pair沿原串行互斥，不增加同时活动的原地阶段。实现允许按已证明的活跃集合使用更小的固定pool、共享owner字段和复用既有coverage位图；容量不足在准入前拒绝，不能驱逐仍有读租约的证明或退回猜P。4352×12B=52224B仅是完整Context的保守载荷上界，其余键/位图/状态、串行化及实际资源须另列；不要求机械复制整个C结构4352次，不增加tensor数据缓存。现GDownPlan的128项容量和语义保持。

逻辑状态为EMPTY→BUILDING→WINDOW_CLOSED→PUBLISHED/可读，失败或取消转INVALID；owner release并排空后才回收。WINDOW_CLOSED不产生tensor READY。新claim/新epoch必须新建证明，禁止继承旧ref的P或covered位。请求错误使相关owner的所有窗口不可消费，不能保留早窗口成功来继续同一失败请求。

## 3. P的唯一选择事件

1. producer实际issue时保存原typed task及其输出descriptor；TaskContext本身没有head/Ref/region信息，不能只存Context后再猜这些字段。一个任务的作用范围取实际合法输出映射，不取循环下标的期望值。
2. 完成必须通过原`check_done`身份/status/unit/elements检查，与实际执行结果一致；物理路径还须相关写覆盖、末B和不能取消的返回全部退休。`full_cover_*`的中间更新或C函数返回本身不等于此条件。
3. 对该任务实际贡献的每个标准窗口，核NumericIdentity、owner epoch、范围及分量一致，拒绝重复/重叠的非法贡献。只有成功且无物理错误的贡献才进入已确认覆盖。
4. 若本事件使窗口从“尚缺至少一个必需分量”变为“所有必需分量完整”，保存**这条实际任务的原Context**作为P。没有新增覆盖的重复completion不能成为新的P；任何失败completion不能成为P。这里选择的是覆盖状态转换的因果事件，不是数值最大的task_id或当前循环最后一条任务。
5. 现路径typed任务串行退休，故此事件唯一。未来若并行，必须先显式定义确定退休次序；不能依赖同拍last-writer-wins。原成功P的stage/layer/op/batch/row0/rows原样保存，不能改成消费者Context。
6. 整tensor发布再次检查全部所需batch/row/component覆盖、所有生产债务清零且没有sticky失败；发布只打开消费资格，不改各窗口P。

caller构造普通Q/L前，以完整source owner/epoch及Q窗口查询既存凭据。P.task_id须来自已执行任务并早于新Q/L，仍满足P<Q<L；不能据差值反推。Q和L仍提前完整预约。P可能属于不同于Q的stage/layer，例如stage1的LN_EMB→stage2/layer0的LIN_QKV；普通路径不强制P与Q同stage/layer/op，只按原合法数据流和source记录核验。GATE路径原来的G/Q/L同窗口、同stage/layer规则不变。

QUANT携带P、Q、L与source Ref/region，实际读lease和源数据检查成功后将**所消费的完整窗口凭据**无损绑定到A。MATRIX各view沿该A记录核P/Q/L/Refs；不在每个view重新选择P。Q结束且源读债清零后，原规则允许释放/改写F32 source；此后MATRIX核的是已形成A的冻结provenance，不能误要求原F32 owner仍为当前READY。请求取消仍撤销相应A/父绑定，旧A不能跨NumericIdentity复用。

普通只读source允许原任务图中多个合法消费者：不同Q/L须有各自预约/A epoch，不能用一个全局“已消费”bit阻止合法重读，也不能重复接受同一Q ticket。GATE的明确预约消费与原地旧epoch一次消费规则分别保留。

## 4. 各生产路径的具体规则

### 4.1 Attention 16-head聚合

对每个 `(ATT_OUT Ref/epoch,batch,row-window)`，必须覆盖16个head、窗口全部rows及每head64个feature。可复用现`att_head_rows[16][2][32]`或等价无损位图；不能只累计16次完成，因为重复某head不能补缺另一个head。

每次成功AV只贡献自己真实head对应的64列。使该窗口16-head覆盖第一次完整的AV Context成为该窗口P。现head外循环0..15、batch/row内循环意味着正常路径的闭合事件会出现在head15，但**不能仅判断head==15便宣布闭合**；必须检查此前15个head的完整成功位及本head实际退休。不同batch/row窗口分别保存自己的AV Context。

例如B1/S64产生4个source窗口：正常情况下保存4条各自真实的闭合AV Context，不能将最终row48窗口的AV Context填给row0/16/32。即使row0已闭合，其他窗口或B1尚未完成时，`full_publish_att`未成功，任何普通Q仍不得消费这个tensor。任一早head或后batch失败使全部窗口保持不可消费。

### 4.2 普通全宽任务、残差及向量多窗口

LayerNorm、非QKV Linear父任务、GEGLU、RELU、BIAS_GELU、ADD_RESIDUAL/ADD_TYPE等按实际输出descriptor覆盖各自窗口的全feature。这个窗口对应的真实成功任务通常就会触发闭合，直接保存其原Context。Linear必须等整个rows16父任务的全部matrix views、唯一父TaskDone和真实末B；一个rows4 response不产生完整source窗口P。

残差P是实际ADD_RESIDUAL输出任务，两个输入各自仍必须满足原读来源/lease要求；不得把任一输入P转抄为输出P。跨batch和多个窗口一直使用同一输出Ref/epoch，所有窗口成功之后才全tensor发布。下游QUANT取自己窗口的P，不取向量循环最后一条。

首个LIN_QKV的普通source为真实LN_EMB输出，因此P是对应LN_EMB Context；CPU token embedding导入凭据不冒充FPGA typed producer，也不跳过FPGA LN。ACT/scorer等HEAD_WORK不同region分别建记录，MARKER/BATCH坐标不得按TOKEN布局解释。

### 4.3 QKV双owner及RoPE

QKV保持原pair原子发布：保存**两条实际分配的Ref及各epoch**、pair绑定、三plane×16head×batch×row覆盖。head按现物理映射归shard；一侧最后B或部分plane完成不能发布任一侧为可读最终pair，不通过bank/epoch加减推另一个Ref。

一个LIN_QKV父任务产生同窗口的两侧完整输出；在该父任务所有views和两路写债都实际成功退休后，同一真实L Context可以同时作为这两侧对应窗口的闭合锚。二者有不同完整owner键及各自覆盖证据；相同P不表示两个owner等同。整个pair仍等待所有batch/window/plane/head，错误使pair无成功发布。

Encoder RoPE从RAW pair到新epoch FINAL pair，Q/K按实际head任务更新，V依原独占lease证明从旧pair保持不变。新的证明必须显式绑定旧/新pair与未改V的来源，并核所有Q/K更新及债务；不能把旧P直接当新epoch全量证明。在每个shard/window，实际完成所需最后一项Q/K更新且其余覆盖完整的RoPE Context是该shard新窗口闭合锚，pair commit再原子发布。当前顺序通常分别落在head14/15，仍由覆盖转换决定而非硬编码。Decision层原本直接产生FINAL pair则无需伪造RoPE。

普通QUANT当前shape白名单不允许将QKV平面/双shard当作普通连续F32 source。本补充不新增该用法；上述记录用于QKV→RoPE/KV/Attention实际消费及其完整来源链。ATT_OUT的P仍来自AV，不替换成QKV或RoPE的P。

### 4.4 原地更新与旧epoch读取

RELU、bias/GELU、SCORER_FC1等沿原`full_begin_inplace_owner`、`lease_old_ref`、old_consumed/new_written和commit规则。开始时保留旧epoch已发布的完整窗口凭据，为新epoch建立独立待写记录。旧source在EXCLUSIVE_RW下只向已经绑定的本次变换/量化窗口提供原合法读lease，不重新伪装为一般READY。

SCORER_FC1量化使用旧SCORER_ACT epoch对应的P；源窗口读完并真实排空后才可覆盖该窗口。新epoch的窗口P取成功的LIN_SCORER_FC1父任务，不能沿用旧LN_MARKER的P。随后的BIAS_GELU_SCORER再形成下一epoch自己的P。Q完成后A中的旧P保留到父matrix退休，这与F32同址改写并不矛盾。

只有所有旧范围已合法消费、新范围已成功写回且相关债务清零，commit才能发布新epoch。任一步失败不发布新epoch，不恢复已经被覆写的旧epoch为READY；清理并按原请求恢复规则处理。只重命名epoch、只改state或复制旧covered位均不成立。

## 5. C控制证据与物理生产证据

本决定明确P的逻辑权威，但不把C侧`full_publish_*`或`TaskDone.drained=true`变成物理证据。普通非门户producer的实际生成实现仍须将发射时绑定的任务/owner/范围与真实输出覆盖、RRESP/BRESP及债务退休对应，物理source ledger据此得到窗口和tensor资格，再给QUANT提供`cfg_owner_admitted/cfg_source_published`等既有检查条件；单独接C READY、布尔成功或未经绑定的“总线当前空闲”不满足要求。

在实现层可以分开保存typed逻辑完成与真实总线退休，在二者身份一致且全部成功后确认闭合；物理B可能晚于C函数返回，此时不能过早置physical published。任何晚错误必须阻止该epoch消费/发布。该来源链的实际generated连接、端口owner交接和物理错误处理仍属原§3.9生产hub验收，须用真实生成产物证明；本次不声明已有连接，也不隐式新增第五service、publication命令或未定义sideband wire。若工程发现既定生成接口确实缺少携带该绑定的通路，直接给主控具体生成端口/连线缺口；P选择已可独立实施，缺失物理证据的路径继续不作生产使能或PASS声明。

`portal_controller_04`的receipt明确限定为**C++生产Controller路径＋受控service responses的metadata/retirement验证**，无数值payload、持久hub、完整图或RTL声明。其日志25条命令/13个typed任务/4G窗口与本问题一致，receipt引用的manifest/runner/log/executable四个SHA核对匹配；本轮未审核整个manifest依赖闭包或重跑测试。它不能证明本节物理source链，也不因“同runtime”一词扩大成真实G/Q/matrix硬件集成。

## 6. 失败、恢复与受影响核验

重复/错head、错batch/row、错region/Ref/epoch/model、非法task completion、数值或AXI错误不能增加有效覆盖或更新P。tensor一旦失败，已闭合窗口也不可被消费；先停止新工作，排空旧读写/FP/FIFO/response/lease，再撤销该请求的producer与未来Q/L绑定。

同session更大request_id恢复时以完整NumericIdentity新建记录；旧P即使task_id重复也不能命中新请求。portal H_alloc/H_closed及L13M物理base绑定沿既有合同跨软取消保持。owner release后可回收证明，但不能让仍被A/父任务引用的不可变provenance悬空；可复制必要字段或保留固定引用，引用有效期必须覆盖真实退休。

工程按原预算补受影响用例：

1. B1/S64 Attention四窗口各自P；B2跨batch、任一head缺失/重复/失败、末B延后、早窗口闭合而整tensor未发布拒绝；最后task不是其他窗口P。
2. 多窗口LN/残差/向量、普通P与Q不同stage/layer、rows4 view不能提前造父窗口P、同一源合法多个消费者及重复Q ticket拒绝。
3. QKV两侧/三plane覆盖、只完成一侧拒绝、RoPE旧V继承与新Q/K完整性；保持普通QUANT不接QKV的原shape白名单。
4. 原地old/new epoch并存、SCORER旧源Q→A→覆盖写、新P替换、已消费旧窗口不能重复读、失败后不能回滚旧READY；同session新request恢复和旧响应拒绝。
5. 分别给出软件metadata、真实generated物理source链、当前完整CPU/实际CSim的证据；受控回复probe不代签物理层。后续portal_controller诊断任务计数不因本决定新增publication TaskDone。

只重验受影响范围，保留旧冻结结果。普通Q/L的身份定义已明确；实现及物理验证仍待交付。L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；组合G/Q→父matrix完整运行的NOT_RUN_COST仍保留。原单重工具/内存/墙钟/周期帽与G OOC余2338.224019s不变，无新OOC/P&R/上板、无新增用户审批停点。

依据及合同preimage见[21份只读快照](ordinary_linear_provenance_decision_20261012/verification.json)。
