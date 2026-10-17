

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C046 · 修订15：真实STATE0/AUX入口与固定128行生产调度

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-source-s128-revision15-implementation-dispatch-20261015

2026-10-15T07:03:02.305179+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：未登记

# 修订15：真实STATE0/AUX入口与固定128行生产调度

2026-10-15；D-M004-SOURCE-S128-01；M004/SM004/E004/R001。依据已批准Goal v4/M004修订3继续完整模型实现。A001确定本合同，A002独占E002实现、模块design/results与E004运行/三摘要，连续编译、验证和普通修复，无逐步审批；A003保留source研究所有权。各角色共同工作，不回退他人修改，不新建agent或活动实现副本。

## 起点、采纳范围与原证据

修订14按D-M004-REV14-CLOSEOUT-01收束，55笔guard与未用余额封存，不转移。当前wrapper SHA `0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c` 只有所测局部控制/传输及AT232真实core/IP展开；AT225的791.796564s真实两行长链只属旧wrapper b1315262…，不迁移。当前core `54fe628fac0d1a9dd4c61455c45e55eb3abe499034d7bb23157b9ac8d4b8bf78`、writer `ee1121c5fd0b6651d6f7ff3d859fb60b57ae871cbebb011ff2994af9e3372218`、RoPE adapter `a80564dee57a8e07bcb4af2ddd758efe6012f7af92c188e5135bd00a493582e0`及原full-Check叶子为起点。新增core预装接口会改变core身份，旧正常数值只能按原身份引用。

采纳研究的单一路线：为现单row wrapper增加真实STATE0和gamma预装，再由最薄固定请求FSM串行调度128行Embedding LN→Q→Encoder0 QKV→RAW scratch→full RoPE FINAL。继续复用一套计算core、一套512bit scratch reader、一套128bit AUX reader及一个writer；不增加整行或整tensor RAM、不复制LN/Q/matrix，不接Attention、Host驱动或HBM平台。本段正常请求固定B1/S128、K1024/N3072、原完整模型身份，不设可缩成两行成功的生产参数。

主控独立核研究81项文件/窗口身份、30项保存字节/整数条件及6个head0窗口比较，全部一致。证据见[机读审核](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)字段revision15_source_s128_static_review及[研究依据](../../source/fixed_graph_support_20261014/s128_final_attention_binding_20261015.json)。本次纯字节脚本完整外层计量0.22s、峰49080KiB、exit0；内部采样与落盘前峰另列，交互读取累计UNKNOWN，没有模型求值或EDA。

## 输入接口、bank复用与真实回放

在现row wrapper增加 `cmd_input_from_state0`、`cmd_state0_base[63:0]`、`cmd_state0_span[63:0]`、`cmd_state0_epoch[31:0]` 与独立STATE0 AXI512只读AR/R端口。新模式只接受QKV/Encoder0、source_hidden_bank=0；RAW-only或RoPE尾部均可复用预装，但本固定128行入口强制rope_enable=1。旧caller把新mode接0，保持原外部x/gamma流及FFN路径，不把新输入mode用于FFN。新模式外部x_ready/gamma_ready恒0，不能混入外部数据。

STATE0是原raw所在只读物理域，norm仍写STATE1/HIDDEN。source base须64B对齐、span至少原8MiB BO；有效raw仅前524288B。AUX复用现 `cmd_rope_aux_base/span` 作为完整模型BO描述符，base16B对齐、span≥1142528B；它不是W cache的128B header地址 `cmd_aux_base`。全部base+span和偏移加法用65bit检查溢出及包含关系。STATE0、QKV0、QKV1、STATE1和AUX是不同路由域，跨域相同数值base不构成别名；不能仅改地址数值而接错物理口。source_epoch必须等于本tensor来源e，和逐槽W epoch分开；begin锁存源描述符，所有后续行精确匹配。

外层cmd真正接受时，一次锁存全部将来core要用的字段：id/mode/row/cold、模型/数值/task、W和Down的描述符/epoch/header/bias、tensor和三目标、source/AUX/RoPE配置。之后caller可以变化；延迟到预装完成才送core，不能继续用外部实时cmd字段。已有release优先规则保留，固定请求活动时禁止外部命令或release插入行间空隙。

每行先STATE0 `base + row*4096` load4096B，再模型AUX `base+128` load4096B gamma；gamma每行重读。scratch reader新增长期保持的STATE0/QKV0/QKV1路由选择；AUX依次服务gamma、core W header、RoPE表，同一时刻仅一owner。route/base/epoch从真实load接受到load_done且FIFO/返回holding已退保持不变。读错不能看到out_last就提前完成，也不能忽略较晚load_error或用前一次sticky error拒绝新load。原reader的每burst容量/4KiB切分不改：scratch512bit FIFO4096B，AUX128bit FIFO1024B；gamma256个R通常多burst，不能假设一个AR。

在core真实IDLE、旧结果读取/响应/算术/lease和外部事务均退后，预约现 `final_bank[0:7][0:655]`：raw第c字写bank[c%8][c/8]，gamma第c字写bank[c%8][128+c/8]，c=0..1023，共占tile0..255的8192B。新增预装begin/ordered-word-write/commit/abort握手语义：begin绑定id、row和来源epoch并独占bank；word-write按raw后gamma严格顺序、只在valid&&ready写，分别核满1024字；commit仅在全部2048实际bank写入、两reader本次load_done成功、FIFO与holding债零后成立。用两个顺序计数器和有效token，无需新增整行覆盖RAM。缺字、乱序、重复、错epoch或id不能生成有效准备token。

增加core的prepared-source选择。只有匹配id/row/source epoch的已commit token可被一次真实core命令消费；普通命令在预装占有bank时不得进入，唯独该匹配prepared命令可转入计算。缺失/不匹配token产生协议失败，不能等待不存在的额外数据或读陈旧bank。abort只在预装读事务/holding实际排空后作废token，不能用于清除已启动core。所有接受点使用valid&&ready，不能仍以单独cmd_valid触发状态。

core启动后先按原顺序用同步bank读回raw、再gamma，以32bit真实LN valid/ready回放；停顿时保持数据/索引直到消费，一个读预约只对应一个返回，不能重复或跳字。无需额外数值预检，原LN finite/首错和算术规则保持。raw/gamma全被LN消费后才释放tile0..255用途；LN的norm保存仍在tile384..511，matrix结果随后写tile0..383，两者生命周期不得重叠冲突。冷W加载可以发生在预装后，但不得覆盖bank。既有G/Down/ADD与结果读端口继续互斥，不引入未实现的RAM多端口假设。

新增payload上限为一个共享64B读返回holding加至多两个32bit同步回放保持（≤72B），其余是计数/配置/有效位；优先复用已存在保持寄存器。现core bank20992B、已有reader FIFO5120B、RoPE head/table/leaf saved及writer160B仍须完整计入，不能把72B宣称为总缓冲或综合资源。若实际端口约束迫使新增整行RAM，属于合同变化，交A001处理，不私自扩容。

## 固定请求调度、完成与失败

在既有模块树增加薄固定128行sequencer，可独立module包住同一个row wrapper，无第二计算top。请求使用valid/ready并锁存上述元数据，独立request-done valid/ready保持状态、出错row/id、原phase/bad和RoPE Check诊断。复用现numeric identity中的request/generation，不建立第二套矛盾身份；字段命名由A002按现有风格映射进design.md。请求以base_cmd_id非0开始，`base_cmd_id+127`用33bit核不溢出；row s的cmd_id=base_cmd_id+s。task_context[95:88]=1、[87:72]=s、[71:64]=128、[63:32]=01000001，[31:0]保持请求指定非0task id；模式QKV，key0001、原完整load shape/bias0。

只有row0带tensor_begin并cold加载slot0；W epoch由请求给出并符合原逐槽旧epoch+1，不能固定所有请求为epoch1。row1..127同W identity/epoch warm，slot1不参与。不在下一个row前重装W或假命中，gamma与RoPE表仍每行读。row调度计数必须能表示已退休0..128，不能用7bit把128绕为0。每行必须预装成功→core真实接受→完整QKV/RAW→原RoPE→所有B、core release及outer done真实消费；之后才递增和启动下一行，不并行预取下一行占用bank。

保持修订14隐藏RAW/FINAL、e/e+1/e+2规则。source e，QKV FINAL e+1、norm e；正常release用e+1，partial/failed显式discard用e，均消耗预留上界e+1。只有真实全部128 RAW/FINAL位、最后row outer done已消费、全部债零且tensor_final_valid实际成立，才给本sequencer请求成功done；done保持至消费。两行前缀只能置两位，不能给request done或tensor发布。成功请求done消费不自动释放FINAL/norm；后继Attention只消费QKV仍不能整体release norm，需留到真实WO残差skip消费者结束。下一请求必须等旧请求done及真实消费者release/失败discard；固定请求busy和done保持时不得让legacy FFN/row caller抢占。

输入descriptor/预装协议/读错新增status7、4bit phase14=INPUT、bad全1，result_row/id对应失败行；范围非法必须在实际AR/core命令前拒绝。已准入tensor内的输入错置sticky tensor_failed，不置该行RAW/FINAL；从未成功begin的非法命令不能破坏旧tensor。输入错误发生在core命令前，不能伪造core release或core done；wrapper在reader真实排空后自行给一次行错误，sequencer消费后给一次请求错误。预装失败前不得有core/W/matrix服务；已显示AR保持至握手，已接受burst等RLAST、FIFO丢弃/消费及load_done，取消只停止尚未展示的新burst，不能清债。错误后停止所有后续行，partial字节无回滚；显式discard后新epoch才可重建。

原core数值6/phase/bad、RAW phase12、RoPE phase13及完整Check继续透传。当前阶段只承诺逐行服务的局部失败次序：row0完整链先于row1，行内head0 Q/K再head1 Q/K、原leaf预检/pair次序不变。**不采用研究建议将此直接定义为旧整模异常等价。** 原全QKV先于RoPE、head→16row窗口→row→Q/K的全请求首次遇错顺序与本调度不同，仍为UNRESOLVED/NOT_ACCEPTED；取已观察min key不能补偿未执行的候选。正常数值不变，此缺口不能用正常链PASS关闭；在完整模型错误接口集成前集中解决，本段不改Goal/整模异常合同。

共同reset只签DUT控制、core/reader/writer/adapter和受控AXI peer共同取消的明确边界。预装有效token/holding/覆盖清除，沿既有510拍隔离禁止旧R/结果写入新epoch；不签独立AXI reset。回放中reset属于core已启动，不能把它当预装abort；分别证明所测隔离。原严格MUL IP已接受未返回窗口NOT_RUN不因此关闭。

## 参考和有限验证

沿用已冻结真实production请求、模型和fixture，只做无损复制/格式转换，不生成新gold。完整128行raw/norm各524288B来自独立D2 `oracle/B1_from_b0_S128/embedding_raw.f32.bin` / `embedding_norm.f32.bin`；STATE0有效前缀与raw全字节一致，gamma为当前模型AUX+128/4096B、SHA dfb0f4aa…。task2_real_fixture_20仅前四行Q/scale/PS/pre-QKV/scatter可用；本主场景取row0/1，完整FINAL用已冻结两行RoPE manifest SHA `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2`。row0 FINAL d4d1b006…、row1 f4fa2f82…；V/norm保留原参考。

1. 有界主场景为**真实固定128行调度器的row0 cold、row1 warm前缀**。TB从实际STATE0/AUX总线存储供数，core仅经本次预装bank回放；保留两行各1024norm、32组Q/scale、12288组×8lane PS六字段、3072 pre-QKV和2048 RoPE Q/K FINAL逐bit检查，V/norm实际内存不变。实际RAW/RoPE来源和写B仍受原checker约束，每行512同步结果响应、256 RAW B+128 RoPE B；新增每行raw64个512R、gamma256个128R及2048次bank写。核reader成功done/全部bank写早于core cmd，记录cmd接受与每阶段进展，非全局周期替代latency。
2. TB在row1成功outer done退休且全部已发事务退后，核仅row0/1位、request done和tensor FINAL均未发布，即可结束前缀测试，使用明确`PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX`标记。生产sequencer仍有row2..127待执行；不加两行完成开关、不注入126行数据、不伪造discard或整请求完成。未到row1则只交prefix/COST_STOP，不降低验收范围取得PASS。
3. 同生产预装/回放接口的局部peer核合法页尾分段、row127最后字/源域地址、raw/gamma真实AR阻塞和有限R空拍、AR全字段/VALID持稳。核caller在接受后改变全部cmd字段不影响当前请求；bank所有权、raw/gamma各1024顺序、同步回放停顿和缺失/不匹配准备token。两个读路径各做晚RRESP错，至少一个在最后R时发生，证明core/W/matrix从未接受、排空一次错误、discard后新epoch可恢复。peer只替代注明的局部端点，不force状态/valid/债/完成。
4. 固定128行sequencer可用合法row-wrapper完成peer核128条唯一row/地址、首cold后warm、上下文/epoch/id、最终发布屏障、busy释放屏障及第127行错误。该项只签调度/元数据，不签128行LN/QKV/RoPE。非法范围/溢出必须零AR；读/回放中共同reset和510拍隔离按真实触发点单列。至少在逻辑内存模型核STATE0/AUX只读、目的V/norm与邻行/有效区外哨兵；不称真实物理BO/HBM隔离。
5. 受影响legacy外部流/FFN透传、直接错误done和RAW-only/release的局部回归；现real core/IP展开及新路径两行数值是core变化的必要验证。不重跑未变AT204完整FFN或AT021 Attention基线。warm零新增AR只指W及其header，gamma/RoPE表按新分类计数，不能对共享AUX整体断言零新增。

Attention暂不实施。t5_attention_fixture_01的head0全128query/keys独立Attention gold可保留为未来消费者局部checker；其Q/K/V是软件producer捕获，只有当前两行head0共384个F32已与冻结FINAL字节相同。其余126行实际producer输入尚未对齐，不能以捕获值补齐发布；余124行独立QKV/PS、126行RoPE及15head完整Attention参考仍缺。旧B2窗口不用作替身；旧v4/当前request只有所核mask等窗口相同，整包身份不同。后续Attention仍需55word绑定、完整K/V/mask和16row Q、真实ATT_OUT写B、norm保留与联合成本合同。

## 新阶段预算和停止条件

独立host准备累计≤300s/8GiB；static/IP展开累计≤1800s/24GiB、单次≤600s；RTL含pilot/局部peer累计≤4800s/8GiB、单次≤2400s且≤1Mcycle。修订14static1001.90892168506979732s、RTL1247.0794125087559535s及剩余额度原封不动。A001本次静态审核计量另列，不扣工程RTL。

先做一次固定≤120s的本版真实入口prefix pilot，计入RTL新账，记录source读、gamma读、预装、core cmd、LN/矩阵/写回实际进展；未到warm则如实停在prefix，不动态加帽。主场景硬帽在启动前按已知本版进展和保守估计确定，不按行数/字节比或150MHz推新墙钟，不把AT225旧791.797s当本版上界。新有因实现修复的受影响测试在同帽内连续执行；资源停止不能仅加时间原样重跑，预计不落帽则局部取证并保留完整前缀缺口。无真实语义进展120s停止，失败、timeout、编译、pilot及修复全部计账。

全项目一个重工具、CPU0–3/nice19/idle I/O、MemAvailable>192GiB，记录owned RSS和实际政策。无新HLS综合、OOC/P&R、整模型前向/new gold、参数扫描或新agent。只管理本项目owned进程。A002在同一模块design/results、E004阶段报告/三摘要记录接口映射、所有原终态、版本及未测范围，阶段完成集中交付；送达不代表已实现或验收。


[原始消息收据](../../.research-agent/communications/m004-source-s128-revision15-implementation-dispatch-20261015.json)

相关文件：[s128_final_attention_binding_20261015.json](../../source/fixed_graph_support_20261014/s128_final_attention_binding_20261015.json)
### m004-rev15-at250-source-prefix-milestone-20261015

2026-10-15T07:56:03.241432+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-source-s128-revision15-implementation-dispatch-20261015

# SM004修订15 AT250真实固定请求两行前缀里程碑（阶段内，未收束）

A002→A001；M004/SM004/E004/R001。AT250 frozen core 29db0515cea2a8fa6044a1b34c8b3d386da42a48f455582e96fe77523a7dd441、wrapper d8e52ea33afcc546c882831a6eb0a76733abcd22a84f663123ddd6fe46f02e84、sequencer b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154；原始证据在 project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT250_SM004_rev15_s128_real_prefix_01/。

同runtime只接受一次固定S128请求，真实row0 cold、row1 warm由sequencer依次驱动；STATE0各行64个512bit R、AUX gamma各行256个128bit R经同生产reader和core bank回放。冻结两行LN/norm、Q/scale、PS六字段、pre-QKV及RoPE FINAL checker没有Fatal，RAW512 B、RoPE256 B、scratch256 R、表64 R全到；row0/1分别在global cycle116105/204445完成。仅两位RAW/FINAL覆盖，request_done与tensor_final_valid保持0，未造其余126行或discard。TB使用两行冻结逻辑内存与独立参考，未证明物理BO/邻区哨兵。唯一PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX，RTL guard child0/trigger null、806.8281200714409s、峰983416KiB；static展开145.5615608599037s。

AT246另有同生产core/wrapper的预装局部PASS：真实raw64 R/gamma256 R后bank两段各1024字逐位同冻结输入，core已接受prepared命令，RTL13.384500801563263s。AT245固定120s pilot按timeout/-9原终态保留，只到冷W/LN前缀，不能称PASS。AT249模拟row-wrapper peer的128唯一行、非法base id溢出零行命令、最后发布及release屏障局部PASS；不是128行真实算术。

输入晚RRESP错误/无reset恢复、共同reset510拍、caller字段变化及legacy局部回归仍在本修订原帽内串行执行；本条是阶段里程碑，不请求逐步放行，不关闭修订15或M004。


[原始消息收据](../../.research-agent/communications/m004-rev15-at250-source-prefix-milestone-20261015.json)

相关文件：[AT250_SM004_rev15_s128_real_prefix_01](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT250_SM004_rev15_s128_real_prefix_01)
### m004-rev15-at250-scoped-acceptance-input-fixes-20261015

2026-10-15T08:04:30.669956+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev15-at250-source-prefix-milestone-20261015

# 修订15 AT250正常前缀接纳与输入控制局部修正

2026-10-15；D-M004-REV15-AT250-01；A001→A002；M004/SM004/E004/R001。回复 `m004-rev15-at250-source-prefix-milestone-20261015`。本次为阶段内里程碑审核，修订15继续running，原合同、累计预算和A002单owner不变；普通修复与既定回归继续，无逐步批准。

## 限定接纳

接纳AT250 **PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX**，仅冻结core `29db0515cea2a8fa6044a1b34c8b3d386da42a48f455582e96fe77523a7dd441`、wrapper `d8e52ea33afcc546c882831a6eb0a76733abcd22a84f663123ddd6fe46f02e84`、sequencer `b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154`。源码/TB核实只接受一次固定请求，row1由生产sequencer推进；TB的第二次start_qkv仅更新checker行号并return，不发第二个request。

原日志正常结束，唯一该终标、child0/trigger null、无Fatal/ERROR。两行STATE0共128个512bit R、gamma共512个128bit R，经真实reader和原bank回放；外部x/gamma消费均0。两行各1024norm、32组Q/scale、12288组×8lane PS六字段、3072 pre-QKV均在真实接受/提交点核对；真实RAW写入后由RoPE读取、原址写回，全4096个Q/K FINAL逐位核，2048 V和2048norm实际逻辑内存字节保留。每行512同步结果响应，共1024；RAW512 B、RoPE256 B，共768 B；RoPE scratch256 R、table64 R。W总AR384/384/48、header1/8，第二行未新增W/header；gamma和RoPE表另计。

末两行row_written/row_final均为3，retired_rows=2、request_done/tensor_final_valid为0，没有discard或补齐126行。row0/1日志global116105/204445只记录完成观察点，不改称完整请求latency或II。所测有限阻塞与末B屏障按TB实际断言保留，不补签逐口所有AXI字段/物理BO哨兵。真实128行生产、整请求完成、全图首错、Attention/整模与物理结论仍未验。

主控核AT243–250共547条冻结SHA、60份guard原产物、135条实际政策样本，零不匹配；AT250的34份QKV和23份FFN夹具逐文件同AT225，14项夹具父窗口核SHA，另将两行raw、两行FINAL及gamma的hex解码与原保存二进制逐字节核对。AT246仅接纳预装两段各1024字和prepared core命令到LOAD_WAIT的局部事实；AT249是模拟row-wrapper peer的128行调度/最终屏障，不能签真实128行算术或源地址总线覆盖。

截至AT250已结束的12笔guard快照为static **731.453528914600612s/1800s**、RTL **946.227504860609739s/4800s**。这是历史时点快照，不遗漏后续AT成本、不重新计账；host完整UNKNOWN。AT245 timeout/child−9、AT243/248原失败均保留。AT250 static145.5615608599037s，RTL806.8281200714409s/983416KiB；旧修订14余额不转移。

## 两项合同内控制修正

1. **预装abort必须晚于真实读债排空。** AT250 wrapper第559行把 `prep_abort_valid` 直接绑 `state==IN_ERR`；但第990–992行只有source/table load与out_valid均退、且core_prep_abort_ready仍为1才退出。core第一次abort握手就清prep_active/token/fault，随后abort_ready降0。因此若在reader尚有债时进入IN_ERR，准备状态先清，待读排空后会等不到第二次abort_ready。这是有具体状态条件的静态控制风险，尚不是本次实测失败；通常到load_done才发现的晚RRESP错误不一定触发，不能由其PASS推断此入口也闭合。

   按原合同修正为：停止新发射并真实排完已展示AR、已接burst、FIFO和holding，再对core给一次abort，只有该次valid&&ready后报告外层错误；不要先清token再等待第二个ready，不清真实事务计数。可用同生产wrapper/readers与注明的局部prepared-core peer，在load仍活动时经已定义fault输出报错，保持真实R/RLAST/FIFO消费，证明abort不早于排空、只一次done，随后显式discard和新epoch恢复。也可采用等价可核验接点；不force FSM/valid/债/完成，不把该局部peer写成真实producer错误恢复。若已有同义修复，交对应冻结差异和短例即可。

2. **预装RAW-only续行也必须绑定gamma AUX描述符。** AT250 continue_ok只在cmd_rope_enable为1时比较 `cmd_rope_aux_base/span`。原合同允许input_from_state0=1、rope_enable=0的row服务，此时gamma仍从tensor锁存的完整AUX地址读取；若caller在续行改变gamma base/span，现检查会接受新描述符而实际继续读旧地址。请在source模式或RoPE任一启用时都维持完整AUX描述符一致性，原外部流RAW-only不因此增加无用要求。用source=1/rope=0的合法局部上下文，在下一行只改变base或span，检查立即协议拒绝且零新AR/core/行位；旧合法描述符后继能按既有规则工作。此项不影响AT250固定rope_enable=1的正常两行证据。

两项属于现合同已定义的债务出口/身份规则实现修正，不新增接口、数值规则或预算。保留AT250正常证据在原SHA；新wrapper身份只签相应局部回归和真实core/IP展开，未运行的新身份完整长链明确NOT_RUN，不为此重跑806秒基线。继续既定晚RRESP、共同reset510拍、字段锁存、页界/row127、prepared token及legacy受影响短测，原预算内集中交付。

## 记录与下一出口

请在下一阶段同步同一E004报告/三摘要和模块design/results；它们当前仍停留修订14“修订15尚未授权”的历史文字，不适合作为当前状态。更新时区分AT250正常前缀、AT246预装、AT249调度peer、上述普通修正及尚未运行项。无需逐条确认回信，阶段结果或实质阻塞再交付。

主控原始核查在 [机读证据](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json) 的 revision15_at250_prefix_milestone_review。完整模型目标继续running/unassessed；整模异常次序不因正常两行通过而关闭。


[原始消息收据](../../.research-agent/communications/m004-rev15-at250-scoped-acceptance-input-fixes-20261015.json)
### m004-rev15-at264-engineering-stage-handoff-20261015

2026-10-15T09:13:35.674396+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev15-at250-scoped-acceptance-input-fixes-20261015

# SM004修订15 AT243–264工程阶段交付

回复`m004-rev15-at250-scoped-acceptance-input-fixes-20261015`；M004/SM004/E004/R001。修订15两项控制修复、既定输入/复位/调度/legacy短回归和真实入口前缀已在原独立预算内连续完成，本段重工具停止，提交A001按冻结身份审核；不声称修订15或M004整体完成。

AT250旧wrapper `d8e52ea3…`原主场景已由主控限定接纳：一次固定S128请求自动row0 cold→row1 warm，真实STATE0/gamma预装、LN/Q/PS/pre-QKV及两行4096个Q/K FINAL逐位，合计RAW512 B＋RoPE256 B；仅两行覆盖、无request done/FINAL发布。当前wrapper `d4856aee1f59c07e3af7b9427e50d0cd4d177f859cee4ee905637128f0c60209`的AT264新同版仅签真实row0完整RAW256＋RoPE128 B、原逐位checker、输入2048字不变和未生产row1 QKV192块/norm64块逻辑哨兵；没有当前SHA同runtime两行或真实128行成功。AT264 static135.58864064514637s、RTL455.91410728543997s，child0/null，唯一`SOURCE_LOGICAL_SENTINEL_PASS`且无Fatal/Error。

AT259用生产wrapper/readers＋合法prepared-core peer在raw第7个R时报告早期fault，已接受64R真实排净后才一次abort、一次7/phase14；discard后epoch3 raw64R/gamma256R及2048字预装、core接受。AT256真实core的source RAW-only row0完整512响应/256 B后，下一行只改AUX base或span各即时拒绝、零新AR/core，恢复原描述符可再次准入。AT251旧wrapper晚STATE0/gamma RRESP错与部分R共同reset、AT255旧wrapper回放共同reset510拍隔离及gamma错/discard后epoch3完整RAW256＋RoPE128 B恢复分别保留身份；AT251/254旧guard对真实共同reset计数归零误停，AT255守卫仅按实际复位标记重开epoch，原child−9不回写。

AT261同生产reader/core入口以冻结row0字节作row127页尾**局部路由**验证：STATE0 2AR/64R、gamma 5AR/256R及两段各1024字bank后core准入，不当row127数值gold。AT263真实core缺token、bank占有时普通命令、2048字commit后错id token分别核协议7/phase14和零W/AUX AR。AT262当前真实core旧外部raw/gamma各1024字及1024个LN输出逐位通过，止于LN。AT260当前wrapper FFN直接错误done/回显、flush同拍及RAW-only/release局部回归通过；AT252模拟row-wrapper peer的128唯一行/锁存字段/非法范围/发布屏障通过，仅调度元数据。AT243/248/257原静态失败、AT245 timeout和AT251/254守卫误停全保留费用/终态。

[同一阶段报告](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md)与[逐guard机读账](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT264_20261015.json)：42笔guard（20 static、22 RTL），static **1769.133914342150093/1800s**、RTL **2768.097435323521494/4800s**，402条实际政策样本零不匹配，1270项manifest SHA复核零差异，host完整累计UNKNOWN。三摘要已发布为`P4299bcec2cd244cc85b9f11b12ecc482`，E002 design/results与A002状态同步。余额30.866085657849907s/2031.902564676478506s仍属本修订，工程不自行转移或宣布封存。

真实128行producer、实际请求成功done/FINAL发布、全请求异常首错、Attention/Encoder/模型、生产Host/HBM及物理BO、联合资源/Fmax仍未验；原逐行首错与旧全请求head优先次序冲突继续UNRESOLVED。AT264逻辑哨兵只签紧凑内存，不签设备物理隔离。请按原冻结版本集中审核并决定修订15有界出口；无新增预算或后继实现申请。


[原始消息收据](../../.research-agent/communications/m004-rev15-at264-engineering-stage-handoff-20261015.json)

相关文件：[SM004_lnq_row_stage_result_20261015.md](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md) · [SM004_rev15_guard_ledger_AT243_AT264_20261015.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT264_20261015.json)
### m004-rev15-at264-scoped-review-last-row-error-completion-20261015

2026-10-15T09:23:17.166895+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev15-at264-engineering-stage-handoff-20261015

# 修订15 AT264阶段审核：两项修复接纳，末行错误屏障待补

2026-10-15；D-M004-REV15-AT264-01；A001→A002；M004/SM004/E004/R001。回复 `m004-rev15-at264-engineering-stage-handoff-20261015`。接纳下列实际范围；修订15暂不封账，仅补原合同明确的最后一项有界调度短例，不新增预算、接口或模型工作。

## 分版接纳

旧AT250 wrapper d8e52ea3…的同一固定S128请求两行完整数值前缀保持原接纳，不重复审核或迁移。当前wrapper `d4856aee1f59c07e3af7b9427e50d0cd4d177f859cee4ee905637128f0c60209` 与AT264冻结字节一致；相对AT250仅增加真实排空后的abort握手门控，以及source模式的完整AUX描述符匹配。core `29db0515…`、sequencer `b44b5563…`、writer `ee1121c5…`、RoPE adapter `a80564de…`和原算术不变。

- AT259：生产wrapper/readers＋prepared-core peer确实在raw R计数7、load仍活动时报告fault，全部64R和FIFO真实退后才一次abort；7/phase14保持到消费，未启动prepared core、未置行位。discard后epoch3重新raw64R/gamma256R并接受prepared命令。此局部证据闭合提前abort控制问题，不称真实LN/整行错误恢复。
- AT256：当前真实core的RAW-only row0完整结果消费后，续行只改gamma AUX base和只改span各被拒绝、无新STATE0/gamma AR且core IDLE，原row0覆盖不变；恢复描述符后重新准入。源码已在source或RoPE任一启用时精确比较AUX描述符，该项修复闭合。
- AT264：当前wrapper真实row0从STATE0/gamma→bank回放→LN/Q/QKV→RAW→full RoPE，保留原全量逐位checker、RAW256 B＋RoPE128 B。随后核2048个raw/gamma输入字不变，以及未生产row1的QKV192块、norm64块逻辑哨兵。只签这一行和紧凑逻辑存储，不签当前SHA两行连续、完整BO或设备隔离。AT264与AT261非TB RTL/IP依赖相同，四份已编译core/wrapper/reader数据库逐SHA相同；新增TB的实际增量编译及展开来源已核。
- AT261：冻结row0字节用于row127地址/页界局部样本，STATE0 2AR/64R、gamma 5AR/256R，bank各1024字及core准入成立，不是row127数值gold。AT263真实core的缺token、占有bank时普通cmd阻止、顺序2048字commit后错id token拒绝及零W/AUX AR成立；不是所有预装协议错误的穷尽验证。
- AT252：模拟row-wrapper peer的128个唯一行、所测锁存字段、非法id/STATE0/AUX描述符零行发射、正常最终发布与busy屏障成立。仅签调度元数据，不签128行真实算术。AT262旧外部流只到1024个LN输出；AT260 FFN直接done/回显、flush同拍及RAW-only/release均为当前wrapper局部peer范围，不签完整跨模式FFN。
- AT251/255晚STATE0/gamma RRESP错误、两种共同reset及恢复属于旧wrapper。部分R触发为R≥3且load活动；回放触发为LN_WAIT且raw_replay_count≥8且未到末字。510拍只签TB列明的控制/可见信号隔离，后继重预装到core接受；gamma末R错误/discard后的另一次完整单行恢复单列。不能合写为两种reset之后均完整算术恢复。AT255仅修守卫在真实共同reset标记处重建计数基线，AT251/254原child−9不回写。

新增723项冻结身份、164份原产物及267条政策样本均匹配，结合已核AT243–250共1270项身份/402条政策。新增342个实际fixture文件与其声明父attempt逐字相同；AT263只有token TB、没有本地fixture副本，引用字段不算实际使用gold。42笔原guard与机读账逐项一致：static20笔 **1769.133914342150093s/1800s**，RTL22笔 **2768.097435323521494s/4800s**；余 **30.866085657849907s / 2031.902564676478506s**，host完整累计UNKNOWN。AT253仅准备无guard，不记运行PASS。原静态失败、pilot timeout、守卫误停全部保留。

## 封账前仅补原合同“第127行错误”

[修订15合同](../../results/m004_simplified_start_20261014/source_s128_connection_decision.md)有限验证第4项明确包括“第127行错误”。AT252 peer的done_status固定成功，现有128行PASS未执行最后一行非零状态的请求出口；这是尚未验证，不是已有FAIL。该边界直接关系128位最终发布，且原AT252轻量编译约4.52s/RTL约5.43s，当前余额可容纳有界补测。

复用AT252同生产sequencer和合法row-wrapper peer，前127行正常，row127通过真实done握手返回7/phase14/bad全1；该peer不得置row127成功位/FINAL。核请求错误id=base+127、row127、原status/phase/bad，保持至少3拍到真实消费；不发下一行、不回绕row0，不出现成功request done或tensor_final_valid，前127成功位保持而第127位为0。用独立实际接受/退休计数核128次行命令、127次成功退休及一次失败完成；不得force状态、覆盖、valid或完成。只签这个调度出口，不冒充真实第127行输入读错。无需再扩新的数值/释放场景。

此补项static累计≤20s、RTL累计≤20s，均扣修订15原余额；单重工具、CPU0–3/nice19/idle、RSS与MemAvailable规则不变。只改该局部TB及必要runner，不重编真实FP/IP、不重跑AT250/264长例、不修改生产RTL或gold。普通TB有因修复在这两个小帽内连续处理；若帽触发或发现实质问题，保留原结果及未覆盖范围立即交付，不增加额度或原样续跑。完成后给原log/guard/manifest和追加账，主控集中给最终有界出口，无需逐步询问。

全128真实producer、当前SHA两行完整前缀、真正请求成功/FINAL发布、全请求首错等价、Attention/整模、生产Host/HBM与联合物理继续未验。正常链不关闭逐行与旧全请求head优先的异常顺序差异。本审核依据存于 [机读证据](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json) 的 revision15_at264_stage_closeout_review；“closeout”字段名指本次审核过程，当前状态是pending_last_row_error_probe，不代表已封账。


[原始消息收据](../../.research-agent/communications/m004-rev15-at264-scoped-review-last-row-error-completion-20261015.json)
### m004-rev15-at265-last-row-error-peer-handoff-20261015

2026-10-15T09:30:11.512770+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：handoff；送达：delivered；回复关联：m004-rev15-at264-scoped-review-last-row-error-completion-20261015

# SM004修订15 AT265末行错误短例集中交付

回复 `m004-rev15-at264-scoped-review-last-row-error-completion-20261015`。按D-M004-REV15-AT264-01，只在AT252同一生产sequencer及合法row-wrapper完成peer上补末行错误。生产sequencer SHA `b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154`未变，未改生产RTL、gold或原AT252证据；新冻结TB只令第127行的真实done握手返回7/phase14/bad全1且不置末行RAW/FINAL。manifest SHA `a74c147ce4c1cc5d4d0a0bd48c2e5966514ac4b79f6cae0f3fe8bf2ae00f7ee6`。

AT265唯一`S128_LAST_ROW_ERROR_PEER_PASS row_cmds=128 success_done=127 failed_done=1 error_id=208 error_row=127 status=7 phase=14`。独立实际握手计数证实128条行命令、127次成功行done及一次末行错误done；请求status/phase/bad/id/row保持至少3拍至消费。retired_rows=127，前127位RAW/FINAL全1、末位0，tensor_final_valid=0、failed=1；无第129次命令、row0回绕或成功request done。非法范围零发射原断言保留。

冻结源码和原证据：`project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT265_SM004_rev15_s128_last_row_error_peer_01/source_manifest.json`，同目录`guard_static/`、`guard_rtl/`的plan/result/policy/driver.log。static child0/null、4.572500266134739s/20s、峰181504KiB；RTL child0/null、5.470804534852505s/20s、峰863040KiB；11条CPU0–3/nice19/idle政策样本均匹配，最低MemAvailable高于192GiB，原日志无Fatal/Error。

追加账`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT265_20261015.json`保留AT243–264原42笔，现44笔（static21、RTL23）、static1773.706414608284832/1800s、RTL2773.568239858373999/4800s，剩26.293585391715168s/2026.431760141626001s；413条政策零差异，host完整UNKNOWN。阶段报告`SM004_lnq_row_stage_result_20261015.md`、E002模块results及E004三摘要已同步。

仅请求对生产sequencer＋模拟完成peer的第127行错误出口作限定审核；不签真实row127输入读错、128行真实LN/QKV/RoPE、成功请求/FINAL发布或旧全请求首错等价。AT250旧wrapper两行真实前缀、当前wrapper AT264真实row0、历史FAIL/COST_STOP仍按AT264分版结论保留。修订15此次不再启动重工具，余额请由主控按合同处理；M004完整目标仍running/unassessed。


[原始消息收据](../../.research-agent/communications/m004-rev15-at265-last-row-error-peer-handoff-20261015.json)

相关文件：[source_manifest.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT265_SM004_rev15_s128_last_row_error_peer_01/source_manifest.json) · [SM004_rev15_guard_ledger_AT243_AT265_20261015.json](../../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev15_guard_ledger_AT243_AT265_20261015.json)
### m004-rev15-at265-scoped-closeout-20261015

2026-10-15T09:34:03.547391+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：decision；送达：delivered；回复关联：m004-rev15-at265-last-row-error-peer-handoff-20261015

# 修订15有界收束：真实入口分版证据与末行错误出口

2026-10-15；D-M004-REV15-CLOSEOUT-01；A001→A002；M004/SM004/E004/R001。回复 `m004-rev15-at265-last-row-error-peer-handoff-20261015`，接续 [AT264阶段审核](../../results/m004_simplified_start_20261014/source_s128_at264_stage_review.md)。修订15按以下范围收束，剩余额度封存；M004/SM004完整目标仍running/unassessed。

## AT265限定接纳

主控独立核5项冻结SHA、12份原manifest/guard/plan/policy/launch/log及追加账、11条实际CPU0–3/nice19/idle政策，全部匹配。生产sequencer `b44b5563b8d4f159917ef3772b69cc8f05066c80a7ecb1cdbb30b3181cc20154` 与AT252及当前源码逐字相同；当前core/wrapper/writer/RoPE adapter保持AT264身份。编译来源只含生产sequencer及合法row-wrapper peer，没有修改生产RTL、算术或gold。

AT265唯一 `S128_LAST_ROW_ERROR_PEER_PASS` 在全部自检后出现，static/RTL均child0、trigger null，无Fatal/ERROR。实际握手独立计数128条行命令、127次成功行done及1次错误done。末行返回status7/phase14/bad全1，生产sequencer保留请求id208（base81+127）与row127，完成至少3拍稳定至真实消费；retired_rows=127，前127位RAW/FINAL保持1、第127位0，tensor_failed=1、tensor_final_valid=0。所测完成/消费窗口没有第129条命令、回绕row0或成功请求完成。

接纳 `PASS_SCOPED_S128_LAST_ROW_ERROR_COMPLETION_PEER`。该证据闭合原合同末行错误调度出口补项；row-wrapper、覆盖位和故障源均为合法模拟peer，不证明真实row127输入RRESP错误、128行LN/QKV/RoPE生产、正常整请求成功或物理存储行为。原AT252正常元数据测试保持原身份与范围。

## 既有证据与预算出口

旧AT250 wrapper d8e52ea3…的同一固定S128请求row0冷→row1暖完整数值前缀保持原限定接纳。当前wrapper `d4856aee1f59c07e3af7b9427e50d0cd4d177f859cee4ee905637128f0c60209` 的AT264仅签真实row0完整输入→LN/Q/QKV→RAW→RoPE、384笔B、2048输入字不变和未生产row1的QKV192块/norm64块逻辑哨兵；两版不拼接为当前两行连续PASS。两项输入控制修复和其余错误/reset/页界/token/legacy证据按AT264审核逐项保留。旧reset后的重新预装到core接受与另一次完整行恢复继续分开记录。

AT265新增static **4.572500266134739s**、RTL **5.470804534852505s**，各在20s补测帽内，峰owned RSS181504/863040KiB；最低MemAvailable大于192GiB。AT243–264原42笔机读记录逐项不变。修订15现44笔guard（21 static、23 RTL）：static **1773.706414608284832/1800s**、RTL **2773.568239858373999/4800s**。累计1275项冻结身份、413条实际政策样本无不匹配，host完整总量仍UNKNOWN；所有历史FAIL、timeout和守卫误停保留。

剩余static **26.293585391715168s**、RTL **2026.431760141626001s** 自本决定起封存，不转移、不重置、不续跑本修订。无需重复AT250/264长例或追加物理工具。A002仅同步既有阶段报告、模块结果、三摘要和角色状态，注明D-M004-REV15-CLOSEOUT-01与分版范围，无需确认回信。

真实128行producer、当前SHA两行完整链、真实请求成功done/FINAL发布、完整请求异常首错等价、Attention/Encoder/模型、生产Host/HBM与物理BO、联合资源/Fmax仍未验。逐行执行与旧全请求head优先异常次序差异保持UNRESOLVED，不由正常前缀或局部错误PASS关闭。后继范围与预算须另列具体合同，本决定不启动修订16实施。

审核证据存于 [机读记录](../../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json) 的 `revision15_at265_last_row_error_closeout_review`；原 [AT264待补决定](../../results/m004_simplified_start_20261014/source_s128_at264_stage_review.md) 保留历史，待补项由本决定闭合。主控此次只做文件、字节与收据核验，无EDA或新oracle运行。


[原始消息收据](../../.research-agent/communications/m004-rev15-at265-scoped-closeout-20261015.json)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
