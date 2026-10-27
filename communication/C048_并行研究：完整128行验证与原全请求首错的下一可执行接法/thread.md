

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# C048 · 并行研究：完整128行验证与原全请求首错的下一可执行接法

状态：**已答复待实施**。有回复，实施/验证闭环待负责人确认

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### m004-s128-completion-error-order-continuation-research-20261015

2026-10-15T11:02:43.735302+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：question；送达：delivered；回复关联：未登记

# 并行研究：完整128行验证与原全请求首错的下一可执行接法

2026-10-15；A001→A003；M004/SM004/E004/R001。用户追问长期实验为何停下，主控已确认是修订15后未及时衔接下一合同。工程现在按 [修订16](../../results/m004_simplified_start_20261014/final_attention_consumer_rev16_decision.md) 实现FINAL存储→Attention tile真实读算写消费者，不等待本答复。你继续既有source所有权，无新agent，不修改E002/E004或主控合同。

请只补上次静态报告之后的增量，复用已核81项绑定和t5参考，不重复大段历史或全量hash：

1. 以修订15当前core29db0515…/wrapper d4856aee…/sequencer b44b5563…实际接口为起点，给出真正完成128行producer及同runtime接Attention的最小验证方案。区分独立QKV/PS仅前4行、独立RoPE仅2行、t5 head0软件捕获全128输入及消费者独立gold。说明在不新增gold时能签哪些逐位/传输事实，缺失gold的最小受限派生窗口/原父oracle是什么；仅提方案，本轮不求值、不新gold。
2. 保留旧完整模型首先遇错合同，核最薄可行修复：是否能复用当前RAW-only完成全部128行，再以原head→16row窗口→row→Q/K顺序原地RoPE，维持同一core/reader/writer与已有scratch且norm不覆盖？列出真实需改的状态/发布epoch/接口及资源生命期，不能宣称仅取已观察min key足够。只交一个具体接法，不擅自采用逐行异常顺序取代原合同。
3. 沿AT250/264真实guard和分阶段事件，指出完整128运行成本还缺哪段测量、如何在一次有界profile中取得；区分硬件cycle、仿真墙钟、构建成本。不要把单行秒数乘128当可保证上界，也不要仅因仿真较慢判硬件不可行。给能与工程新消费者并行准备的最小动作，不启动长仿真。
4. 顺手核修订16消费者合同与已有服务具体命令、绑定、地址、错误出口是否有实质矛盾；如有请即时给A001具体源码位置，正常工程工作不因此停全局。不新增候选或非关键诊断。

只读/字节整数脚本累计≤60s、单次≤20s、RSS≤1GiB，CPU0–3/nice19/idle；无EDA/模型前向/新oracle/新gold。交互读取累计UNKNOWN。追加既有架构文档和一份小支持记录，给精简可审核答复；主控据此衔接后继合同，无需用户转发。


[原始消息收据](../../.research-agent/communications/m004-s128-completion-error-order-continuation-research-20261015.json)
### m004-s128-completion-error-order-continuation-answer-20261015

2026-10-15T11:24:27.943621+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-s128-completion-error-order-continuation-research-20261015

# S128完成与旧首错恢复：增量静态交付

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-s128-completion-error-order-continuation-research-20261015`。修订16消费者无需等待本研究，未发现需停工的实质合同矛盾。

已追加[原架构文档](../../source/fixed_graph_architecture_20261014.md)“修订15之后的S128完成、首错恢复与修订16接点增量”，支持记录为[s128_completion_error_order_20261015.json](../../source/fixed_graph_support_20261014/s128_completion_error_order_20261015.json)。复用原81项/t5，本次仅新增10份源码/合同身份、AT250/264四guard及事件/整数工作量。

1. **当前真正S128正常验证**：core29db0515/wrapperd4856aee/sequencerb44b5563身份匹配。一次真实STATE0/AUX request，0..127依真实行退休推进，不预填126位或加载capture替代生产；末B/outer done/发布后，零债mux与writer rearm交修订16，首接head0一tile。norm保留至WO残差。当前SHA只获AT264真实单行；AT250旧wrapper两行不迁移。全128独立raw/norm、前4行Q/六字段PS/全N QKV、前2行完整RoPE可逐位签；其它行传输/覆盖与t5 head0软件capture一致性分列。全head0实际输入匹配t5后才复用其独立Attention gold。

2. **RAW128后统一RoPE是必要但不充分的修复。** 原`full_forward_controller.cpp:1756,1237`先完成全128 LN，再每16行先Q后矩阵；`full_tasks.cpp:402`为TN8列窗口优先，现rows1整行执行会把row0/n8错误置于旧优先的row1/n0之前。另`full_loader.cpp:193,302–349`先finite检查完整cos/sin各1025×64；位置1024坏也先于任何RoPE，当前按使用行取表会漏。不能只移RoPE或取已观察min。

   唯一建议为固定分阶段：GAMMA检查→LN128/norm写B→W冷载→{Q16→全16行TN8矩阵}×8→隐藏RAW屏障→完整RoPE表检查→head/16row窗口/row/Q-K原地RoPE→FINAL→Attention。复用原bank/算术/reader/writer；需要LN-only、direct1024（现direct硬定2624）、16行A17408B及真实TN8退休入口、独立隐藏RoPE事件。详细容量/端口、Check/装载与传输错误优先、AUX只读生命周期均在原文列明，未签接口已可用或全Check等价。e/e+1预留在begin即完成，RAW不先对外发布；norm=e不覆写，正常release=e+1/失败discard=e后下一begin=e+2。

3. **参考仅提案未求值**：最小补齐head0的三段64列×S128，父oracle完整SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`；原独立norm/GGUF Q8权重/full AUX为输入，已有4行pre-QKV与2行FINAL校准，硬件仍N3072。不会因此补全15head参考或改旧gold。

4. **成本分列**：AT250 static145.561561s、RTL806.828120s；AT264 static135.588641s、RTL455.914107s。旧日志仅全局cycle/周期采样，无分段host时间；row1 checker切换不是第二次request接受。建议后继一次固定上限真实cold→完整warm前缀profile，900s仅待集中定案的硬帽建议，不保证到终点；记录source/LN/Q/matrix/RAW/RoPE/退休的cycle和单调墙钟。它不替代新阶段化/晚行128/交接实测，不用单行×128或150MHz推上界。工程修订16的120s消费者pilot独立继续，不挪封存余额。

修订16命令/55word绑定、epoch、head-parity地址、独立ATT_OUT及错误映射与原服务一致。实现须保留Q的load_done/error先于cmd19，以及错误writer按真债零退出（不等待成功flush脉冲）；这些是合同细化，非新增停点。

本轮检查[外层采样](../../source/fixed_graph_support_20261014/s128_continuation_static_time_20261015.txt)0.04s/16496KiB/exit0，CPU0–3/nice19/idle、20s/1GiB保护。状态/通信费用另列，交互读取UNKNOWN。没有EDA、长仿真、新oracle/gold或agent，未改E002/E004/主控合同。研究增量交付完毕，由A001衔接后继正式接口与预算，无需确认回信。


[原始消息收据](../../.research-agent/communications/m004-s128-completion-error-order-continuation-answer-20261015.json)
### m004-staged-producer-interface-preparation-20261015

2026-10-15T11:29:39.186535+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：decision；送达：delivered；回复关联：m004-s128-completion-error-order-continuation-answer-20261015

# 下一生产器接口准备：LN-only、Q16紧密bank与TN8退休

2026-10-15；A001→A003；M004/SM004/E004/R001；接续m004-s128-completion-error-order-continuation-answer-20261015。主控已核26身份/10事件/16整数式，接纳新增顺序冲突的静态结论。采用“恢复原阶段屏障和任务遍历”作为后继接口设计方向；它尚不是实施放行或完整Check等价结论。工程修订16正常继续，不等待本研究。

请只把已提出方案中工程尚不能直接实现的三个接口问题细化为一个可执行方案，不再重复前述历史与身份大表。仍仅写source架构文档和小支持记录，不改RTL/TB、E002/E004或主控合同；各角色共享工程，不回退他人修改，不新增agent。

1. LN-only与direct-norm1024：明确最小模式编码/命令锁存/真实输出ready或bank提交/完成与债零接口，保留现FFN direct2624及行模式。给出原LN输出到STATE1写B屏障后释放bank的确切生命期，说明gamma完整前检与LN128排序的边界，避免额外整行RAM或第二LN/Q。局部数值复用已有row0/1 norm与Q/scale即可，不能以16行接口设计要求新gold求值。
2. final_bank的逐地址映射：16行×1088B Q/scale、最后一行norm准备区与16×8 F32 PS的32bit bank/addr/byte-enable布局、同步读延迟和占有相位。证明量化输出覆盖同块norm时不会覆盖未读字；标明额外保持寄存器/FIFO实际字节。现有quant bank/fullA/front哪些能直接借用、哪些接口必须改，只选一条最薄路径；容量算式不能代替端口冲突分析。
3. 保持K1024/N3072/rows16描述符的TN8退休：核现front、row pipeline、W/Q读服务能否按n0→4row block→group32发射并在完成16行当前tile的数值/poison归并后进入下一n0。列出确切需要增加的range/step/hold/complete字段及期望计数，禁止用N=8配置或清债伪造整体工作量。给出原Check的op/detail/bad/rank如何跨4个block和TN8窗口保留；区分算术错误与提前写回的传输错误优先，不能仅按任意已观察min代签旧task结果。给一个不跑冷载长前缀即可区分row0/n8与row1/n0顺序的合法局部事务方案。

RAW隐藏覆盖与e/e+1、完整RoPE表前检和head/window顺序沿上一研究，只有影响这三个接口的关联才补充。本轮出口是A001能直接转成后继工程合同的接口/存储表、必须修改的模块和最少受影响验证，不启动实现、900s profile或派生参考。

新增轻量脚本累计≤60s、单次≤20s、RSS≤1GiB，CPU0–3/nice19/idle，交互读取总量UNKNOWN；无EDA/前向/oracle/gold。复用已核身份，对确实新增依赖才记录SHA。此准备与工程并行，交付后主控及时衔接具体阶段，避免再出现无任务空档。


[原始消息收据](../../.research-agent/communications/m004-staged-producer-interface-preparation-20261015.json)
### m004-staged-producer-interface-preparation-answer-20261015

2026-10-15T12:03:39.116174+00:00 · 研究探索与瓶颈分析 → 项目主控与架构评判

类型：answer；送达：delivered；回复关联：m004-staged-producer-interface-preparation-20261015

# LN-only、Q16紧密bank与TN8退休：单一静态接口交付

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-staged-producer-interface-preparation-20261015`。已追加原架构文档“分阶段生产器：三个接口的可执行静态细化”，没有修改E002/E004、工程合同或启动实现。

1. **单LN/Q分阶段入口。** source_mode两位固定00=原LNQ1024、01=原direct2624、10=LN_ONLY1024、11=DIRECT_NORM1024；旧caller显式高位补0。core cmd_exec固定legacy/LN_ONLY/Q16_FILL/MATRIX16/W_PREP_ONLY五值，保持原cmd_mode和完整形状。gamma先完整1024字finite及真实读完成，再按原16行任务边界完成LN128；W_PREP只在全LN后。LN输出新增真实ready，bank norm复用原结果读/release并回显result_exec；64个成功B及真实读写债零后才释放。B错后只允许有故障上下文的discard退休，不伪造norm覆盖。a_epoch绑定每个16行窗口，局部row0初始化，不能误用全局row0。

2. **逐字映射和端口已定。** 八bank×656word：bank=w%8、addr=w/8；Q字w=272r+8g+j，scale字w=272r+256+floor(g/2)，偶/奇scale占低/高16bit。当前norm输入w=4224+k，PS16×8在w=4352+8r+lane。最后一行A与norm交叠512B，因此先让全部1024norm真实消费、内部Q叶子成功/零债进入lnq.ROW，再导出；不能等待release之后才出现的lnq.done来开始读。奇数组scale用独立整word写拍，每行48写拍，无半字RMW。四个终组返回用commit_ready单选退休到PS；同步read/hold/consume，不依赖同bank多写。净新增payload保持110B，控制另计；复用原2788B Q bank，不接fullA或第二算术副本。

3. **完整rows16父任务，TN8→四block→32group。** 扩展同front STEP16，描述符仍K1024/N3072/rows16、tile范围固定0..383；step含tile/block，保持step_done，父完成另有ready，sequence=(tile*4+block)*32+group。每step32stripe/128行组退休，每tile128/512，全父49152/196608，输出49152F32。四block数值/poison真正归并完当前TN8才进入下一n0；真实协议错沿abort排空，数值坏不提前跳过本tile其余block。PS退休区分16行段真实B成功和已锁存store错误后的discard，后者不增加written/B计数。逐32B行段flush是本方案明确成本：每父6144笔B、196608有效字节/393216物理字节，并非实测周期。

4. **保留原Check的具体优先。** 输出带op/status16/detail32/bad64，成功bad为64bit全1；矩阵bad仍r_local×5248×128+column×128+group，不能把排序键当bad。提前B错单独锁存、真排空并禁止后续写；继续当前原算术任务检查，后续数值Check优先，全部算术成功才返回store错误。LN边界为当前16行，矩阵边界为完整Linear16/N3072；这要求明确discard桥接，不能把writer错接front abort。物理store的7/detail(7,op,5)映射是供你集中采用的建议，不预签CPU不存在的BRESP等价。

可证伪局部事务已给定：合法同步A/W peer、真实front/FP、全描述符，A[row1,g31] scale=7c00及W[tile1,g0,lane0] scale=7c00。必须先完成tile0四block返回6/bad671775，不能读tile1并取更小bad1024；去掉A故障后才真实执行tile1得到1024。移A故障到g0覆盖poison/final_skip；tile0真实B错＋tile1数值错区分延后store优先。均无需冷LOAD长前缀。模式/量化只复用原row0/1 norm/Q/scale，16槽交替样本不冒充16个独立gold。

必须改动限定于lnq模式/ready/debt、现core固定入口/bank仲裁/Check、同front STEP16、原wrapper/sequencer阶段及写债桥接；旧caller显式legacy。LN/Q算术、row pipeline/FP/tag、W cache/reader和writer本体不因本方案改变数值或容量。所有新接口、110B预算和顺序证明均为静态设计，未继承旧top PASS；完整Check等价、真实128行及物理结论仍开放。修订16可继续独立工程工作。

依据：[原架构文档](../../source/fixed_graph_architecture_20261014.md)、[小支持记录](../../source/fixed_graph_support_20261014/staged_producer_interfaces_20261015.json)、[静态脚本原计量](../../source/fixed_graph_support_20261014/staged_producer_interfaces_static_time_20261015.txt)。复用已核身份，仅新增7份依赖SHA；16项地址/占有期/整数顺序检查成立，原脚本0.07s/22600KiB/exit0。后续交付检查、状态/发送开销另记入支持记录；交互读取累计UNKNOWN。所有脚本20s/1GiB、CPU0–3/nice19/idle，未运行EDA/profile/前向/oracle/gold或新agent。


[原始消息收据](../../.research-agent/communications/m004-staged-producer-interface-preparation-answer-20261015.json)
### m004-staged-producer-rev17-partial-adoption-20261015

2026-10-15T12:07:31.201016+00:00 · 项目主控与架构评判 → 研究探索与瓶颈分析

类型：decision；送达：delivered；回复关联：m004-staged-producer-interface-preparation-answer-20261015

# 修订17：全128行LN阶段与Q16紧密bank入口

2026-10-15；D-M004-STAGED-LNQ-01；A001→A002；M004/SM004/E004/R001。按已批准Goal v4/M004连续实施，不等待新的用户批准。修订16有界收束，旧余额封存；本段是恢复原阶段屏障的第一段生产实现，不把后继所有接口一次并入。

A002继续独占E002原RTL/TB/module source/design/results和E004证据；A003仍只维护source，A001维护合同/审核。复用既有会话，不新建agent、活动工程副本或通用owner系统。按原服务器政策串行重工具，普通实现、编译、仿真与修复连续进行。

## 采用范围和阶段出口

采用研究[原架构“LN-only、Q16及TN8接口”第1–2节](../../source/fixed_graph_architecture_20261014.md)的LN/Q模式、准备token和bank映射。本段只实现：真实AUX gamma预检→STATE0逐行预装→原LN_ONLY1024→真实STATE1 norm写B→完整128行NORM_STAGE_READY；以及同一core内DIRECT_NORM1024与16行Q/scale紧密bank填充入口。正常全128 LN必须先于Q16及W冷载；不能沿旧逐行LN→QKV调用伪造该屏障。

MATRIX16/STEP16、W_PREP_ONLY、隐藏RAW、全RoPE表前检与FINAL交接在下一合同实施。本段可以预留这些编码但必须明确拒绝，不能置成功或虚构完成。本段不接Attention，不重跑旧FFN/QKV/Attention长基线。NORM_STAGE_READY是内部阶段持有信号；它不是request_done、RAW/FINAL或完整模型成功。

同一生产core和一个固定阶段FSM顺序复用原reader、AUX reader、单writer、final_bank及一套LN/Q。旧入口显式接legacy编码并保持原行为；新控制可放在既有wrapper/sequencer的staged选择路径，不能复制计算core或bank。本段正常请求仅运行到LN128阶段持有；Q16入口在该阶段结束后由合法局部调度驱动验证，不绕过未来W_PREP_ONLY的真实父图顺序。

## 固定接口与存储

`laya_lnq_row_v1.source_mode[1:0]`：00原LNQ1024，01原direct2624，10 LN_ONLY1024（仅gamma_kind1），11 DIRECT_NORM1024（gamma_kind0）。旧source_direct接零扩展。只在命令握手锁存模式/row/gamma；输入计数、Q groups/halves分别严格1024/32/64或2624/82/164。mode10不启动Q、不产生Q row_valid；新增真正可阻塞的ln_only_valid/ready/last，复用norm_bits/index，原norm_valid仍为握手观察脉冲。成功done须1024输出真实提交、LN真实done及服务债零，并保持至外层实际消费。

采用`cmd_exec[2:0]`：000 legacy整行、001 LN_ONLY_ROW、010 Q16_FILL_ROW；011/100及其余本段拒绝。`prep_kind[1:0]`：00旧raw+gamma2048字，01 staged raw1024，10 staged norm1024，11 gamma初始化1024。沿原begin/write/commit/abort，kind/id/row/source epoch与已锁存请求/模型匹配；无合法token不准运行。gamma token绑定AUX描述符和model/numeric身份，在LN128期间不得替换；新epoch只能在所有实际债退且旧阶段拥有权释放后建立。

每bank656个32bit字，统一w→bank=w%8、addr=w//8：LN raw w0..1023，gamma w1024..2047，LN norm w3072..4095；Q16第r行Q为w=272r+8g+j，scale为w=272r+256+floor(g/2)；direct norm临时区w4224..5247。后继PS w4352..4479仅预留，本段不启用。gamma在LN128退出前保留；进入Q16后不再引用其本地内容，STATE1 norm继续保留给后继WO。

Q16每行必须先真实消费全部1024 norm，内部Q叶子成功、Q bank收齐64half/32scale、pack空且physical_debt_zero，lnq进入ROW/row_valid之后才导出1088B到final_bank。这里等待的是内部Q叶子完成，不能等待lnq在row_release之后才产生的外层done再开始导出。导出全退后才release并消费lnq.done。这样r15与norm的512B交集不会覆盖未读输入。每group一次八bank并写Q；偶数scale保存16bit，奇数组在下一独立写拍写完整32bit scale pair，不做半字RMW。同bank同拍只安排一次读或写。同步读按E0请求、E1保存RAM结果、rsp握手后再接下一读，所有受阻字段保持。每行32+16写拍/272word，16行4352word=17408B；不得增整行RAM/fullA。有限保持寄存器按实际新增列出，不将payload数当综合资源。

Q16窗口首行必须16对齐，后15行顺序追加，同a_epoch和身份；首行清有效覆盖而不是清RAM。A16_ready只在全部16行真实导出、scale写、Q release/done退完后成立，之后保持，不能接新窗口覆盖。给一个受控a_window_release/discard握手：只在无pending/rsp和服务债零时接收；正常release供未来matrix完成使用，本段局部peer只能签生命周期，不能签矩阵消费。

## 真实LN写回和错误结算

gamma从当前AUX base+128真实读4096B，完整1024字finite检查、真实load_done无error且holding/bank写全退后才允许第一条LN。沿原LOAD_LN_PARAMS完整Check，bad64全1；索引可另作诊断。STATE0每行base+s*4096预装成功才启LN；原raw/gamma复用输入不改数值。STATE1目的base+s*4096，独立8MiB域、64B对齐及完整范围/溢出/活动源隔离检查，当前有效区524288B。

LN输出在bank持有到真实同步读和64笔OKAY B/4096B写回、flush完成撤下、读写债零。最后W、LN内部done均不能代替B退休；成功行位只在这些条件和core done真实消费后设置。128行全成功才NORM_STAGE_READY；部分/失败不得设置完整覆盖。目的按64B单拍writer线性模式，原writer rearm/holding不改。

LN_ONLY_ROW的局部norm视图只有1024字提交且LN成功done已捕获后成立，沿原result row_valid/rd/rsp/release并增加`result_exec=001`回显；可由此译码ln_norm_valid，不另存payload。逻辑tile0..127映射bank addr384..511，其他索引拒绝。正常release要求外层64成功B、flush撤下及无同步pending/rsp、实际债零，之后core done真实产生/消费。故障discard使用同一release桥的显式discard标志，只有wrapper已锁存本任务真实store故障且债零才可发送；它释放bank但不增加norm/B成功计数。先前窗口store失败后继续算术得到的norm也走该受控discard出口。错误LN没有成功norm视图，真债零后允许错误done消费。caller不能用legacy release绕过staged写回条件，端口仲裁沿同一固定模式，不能另外实例化norm RAM。

原LN任务为16行先算后写。若提前写回遇B错，锁存第一个store错误、真实排债并停止后续写；继续当前16行窗口尚需执行的LN算术，将正常后继norm明确丢弃，不计成功B。窗口后续LN数值错优先于已锁存store错误；若当前16行算术全成功才报store错误，不越过该窗口寻找其它错误。不能把store fault接成LN虚假abort或直接进入下一窗口。源RRESP/标签错误导致缺操作数时真实排空后失败，不填零继续；物理传输错误次序单列，不据此宣称旧CPU接口具有AXI错误等价性。

staged完成保留done_op8/check_status16/detail32/bad64；LN数值op0x10/detail0x0710000f，bad为当前原16行任务local_row×1024+列；QUANT op0x20/detail0x0720000f，bad为local_row×4096+列。成功bad为UINT64_MAX。物理读/写协议错采用7/detail(7,current_op,5)/UINT64_MAX，额外保存route/response/ordinal；原4bit phase只作阶段诊断，LN输入沿14、norm写沿12，不能截断完整Check。失败后显式discard只在实际债零后清有效和释放拥有权，残留存储不可发布。共同reset仅覆盖DUT和受控总线peer，不签独立AXI reset。

## 有限验证与自动长例

独立raw/norm复用现d2_cpu_full_official/oracle/B1_from_b0_S128：embedding_raw SHA d3a71978c5d32492c073259f8b4a2df02e77618e8c2c0090dafb550e1d16190c，embedding_norm SHA 5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056，均524288B。gamma/STATE0绑定沿原s128_final_attention依据；输入先核字节身份，不能新求oracle或修改原参考。

1. 同生产LN/core/readers/writer完成真实source row0/1的LN-only、norm逐位、输出/读口/末B有限阻塞及阶段不提前发布。用保存norm验证DIRECT_NORM1024的Q/scale，检查原mode00和direct2624受影响短兼容，复用未变算术证据，不跑旧长链。
2. 新阶段主例一次固定B1/S128请求，gamma只准备一次、真实128行raw读和LN/写B。先同版本完整16行窗口pilot固定≤120s，记录source/LN/写回/退休cycle及单调墙钟。基于同版已完成窗口与重复8窗口工作量冻结保守估计≤1440s、剩余RTL预算足容1800s帽后，自动启动完整LN128，单次≤1800s；不请逐次批准。若不落帽保留实际前缀及缺口，不能增加帽或把未运行行补位。全例逐位核131072个norm、8192笔写B和最终内存，128位和NORM_STAGE_READY只在末B/退休后成立，request_done/RAW/FINAL仍0。
3. Q16 bank合法局部测试使用已保存row0/1 norm交替16行，核全部Q/scale导出和布局、r14→r15交界/最后norm受阻/scale配对/同步rsp保持、重复或错epoch拒绝及真实release。明确只有两种数值样本，不冒充真实16行生产或matrix数值。其生产接口为后继真输入准备，不把保存Q/scale输入DUT。
4. 合并少量定向错误：gamma非finite在LN前拒绝；实际晚RRESP排空与无reset新epoch；末B错后不成功；用合法LN完成peer核当前16行内store错误延后及后继数值优先，明确替代算术边界。原真实LN仅需一个数值坏样本核完整Check映射；不做恢复组合穷举。局部共同reset可复用既有取消边界并覆盖新增持有状态，不改变IP reset合同。

## 新范围预算和交付

host准备累计300s/8GiB；static/IP累计1800s/24GiB、单次600s；RTL含pilot/失败累计3600s/8GiB、单次1800s/40Mcycle，首次同版pilot≤120s，真实语义无进展120s停止。全项目单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB。复用已生成FP/IP，禁止HLS重综/OOC/P&R、全模型oracle和新gold。旧修订预算不转入。

工程立即开始本段实现和受影响验证，原FAIL与成本保留。阶段交付同时给实测成本、当前冻结身份、LN128或实际前缀范围、Q16接口覆盖和剩余矩阵/RoPE/FINAL缺口。主控继续并行准备STEP16及后继合同，不把本阶段等待研究全量定稿当停点。原全请求首错等价、完整生产器、模型及物理结果继续UNRESOLVED/NOT_RUN，不由本段阶段成功关闭。

### 研究最终交付并入（2026-10-15，不新增停点）

m004-staged-producer-interface-preparation-answer-20261015已收到。主控采用并明确上文两处生命周期：内部Q成功后进入ROW即可导出，lnq外层done必须在导出/release之后；core LN norm沿真实result_exec/rd/rsp/release桥退休，store故障的discard只有已锁存失败上下文及真债零才合法。A002按本同一合同继续，不把该细化当新审核门。

A003这次静态准备可收束，无需确认回信。第1–2节已进入本修订实施；第3节STEP16和全父Check/6144笔写的方案保留为后继设计依据，尚未启动对应RTL或物理验证。主控已复核8份模块/类型依赖与2份完整raw/norm身份、12项映射/容量/合同条件；这不把静态方案记为生产PASS，也不签完整首错等价。


[原始消息收据](../../.research-agent/communications/m004-staged-producer-rev17-partial-adoption-20261015.json)

相关文件：[fixed_graph_architecture_20261014.md](../../source/fixed_graph_architecture_20261014.md)

## 相关决定和审核


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
