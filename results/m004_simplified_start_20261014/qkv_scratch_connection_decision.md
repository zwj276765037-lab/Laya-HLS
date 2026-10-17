# QKV＋norm真实scratch写回与跨模式重入

决定：D-M004-QKV-SCRATCH-ROW-01；2026-10-15；M004/SM004修订13/E004/R001。A001→A002，回复`m004-rev12-at179-at195-engineering-closeout-20261015`，依据研究答复`m004-qkv-norm-scratch-minimal-next-answer-20261015`。本段接续用户已批准Goal v4/M004修订3，直接连续实现、编译、验证及普通修复，无逐次审批。

修订12已经成本收束，static800.903263994s、RTL3568.453182073s和31.546817927s封存余额不转移；AT193整体FAIL、两行QKV限定接纳、AT195跨mode Down前缀及其timeout保持。完整FFN跨模式尚未通过，本段将其与新增真实写回边界合并验证，不仅加帽重演AT195。

A002独占既有E002模块RTL/TB/design/results与E004原始attempt、阶段报告和三摘要；A001合同/审核，A003研究。不撤销他人改动，不另建实现树/agent。实现仍在`q8_linear_and_restore/tm1tn8_gs32_512`，用现有构建入口维护同一份模块设计和结果。

## 单计算top、单writer与接口边界

在当前`laya_lnq_wi_gqdown_row_v1`外加固定scratch包装层，内部只实例化一次原计算top。QKV模式包装层独占core的rd/rsp/release；外部行读口row_valid/rsp_valid/rd_ready/release_ready均屏蔽。FFN模式原行读/响应/释放透传，所有scratch写VALID为0。模式只在命令接受时切换，旧read/writer/core/outer done全部退休才允许下条命令。新增包装层不能复制LN/Q/matrix/front/W/G/ADD。

复用一个`tm1tn8_axi512_writer`，固定linear模式、tile_lanes=8、row_local/row0/batch=0。只有一个同步row-read预约，rsp阻塞由core原32B响应寄存器保持，包装层不加数据FIFO/整行RAM。writer原held32B＋pack64B＋不可变TX64B共160B payload保持；描述符/计数/覆盖另计，不把160B当综合资源实测。

writer新增`rearm_valid/rearm_ready`：ready仅当rst_n、debt_zero、!tile_valid、!flush_req；真实握手同步清fault、flushing/flush_reported和各命令计数。reset最高优先，rearm不能清任何真实在途。包装层仅在上一outer done已消费、core空闲、无row-read债时发rearm，每个新QKV行一次；段间flush不清行计数。所有当前旧caller显式接rearm_valid=0、unused ready，含ACT production、writer bridge两实例及现TB；搜索补齐其他直接caller，冻结历史不改。新身份必须做受影响短回归，109旧PASS不能代签新rearm。

三个AXI写口均512bit，顺序固定0=QKV0 BO、1=QKV1 BO、2=STATE1 HIDDEN。复用原AW64/len8/size3/burst2、W512/strb64/last、Bresp2 valid/ready；无AXI ID、全局最多一个TX。目的路由从段开始锁存至held/pack/TX债零且flush已撤；未选口AW/W VALID及BREADY=0，不将多个口B OR起来。已经展示的AW/W所有字段保持至各自握手，不能因错误、切段或FFN命令撤回。

保留原命令全部身份和W描述符。包装层新增QKV命令字段：`cmd_tensor_begin`、`cmd_tensor_epoch[31:0]`、`cmd_dst_epoch[2:0][31:0]`、`cmd_dst_base[2:0][63:0]`、`cmd_dst_span[2:0][63:0]`、`cmd_source_hidden_bank`。这些只在QKV有效，FFN忽略且不更改tensor状态。该段固定raw所属STATE0，因此source_hidden_bank必须0；norm写STATE1 HIDDEN offset0。三个目的属于不同物理BO域，数值相同base合法，禁止用全局数值地址比较误判跨域重叠。此字段是本地接口契约；raw/gamma仍真实外部流，不声称已实现设备源reader或Host绑定。

接受命令锁存全部字段，活动期间外部变化无效。numeric_identity的原request/generation/B/S保持，B=1、S=128；model/numeric全宽比较。task布局沿原cache：rows=1、row0=cmd_row、row_space=128、batch字段=1、layer/stage=0、op=1、task_id非0；task_id和cmd_id可逐行变化，必须真实传core及标签，不绑常量。上下文跨行比较task的固定字段，排除row0/task_id。cmd_id非0，FFN仍仅row0。新增完成回显`done_id[31:0]`并保留result_mode/result_row；outer done所有字段稳定到done_ready。FFN完成与旧core一致。

## 稀疏地址、段边界和真实写债

每行按plane0..2、head0..15顺序消费QKV tile0..383，共48段；每段8个32B响应，local n0=0,8,…56，segment_span=256B。最后norm段消费tile384..511，local n0=0,8,…1016，span4096B。三口的物理地址=锁存BO base＋下列byte offset，b固定0、s为cmd_row：

- QKV目的head&1，offset=`((((plane*2+b)*8+head/2)*1024+s)*64+d)*4`。
- norm目的2，offset=`(b*1024+s)*4096+i*4`。

每个段最后rsp真实交给writer后发flush；成功flush_done且debt_zero后撤flush，确认恢复可接受状态才换base/路由。writer的base/span未随held数据锁存，故必须整个段保持不变，不仅等AW/W握手。flush_done是脉冲，要锁存或在该沿推进，不能丢后死等。局部错误用下述错误出口。

每行两QKV口各6144B/96事务，norm4096B/64事务：合计16384B、512读响应、256次AW/W/B、49个flush屏障。每笔AWLEN=0、AWSIZE=6、INCR、WSTRB全1、WLAST=1。64B对齐单拍不跨4KiB；地址计算用至少65bit，检查加法溢出和完整beat包含，不用截断后的地址作保护。

目的描述符必须覆盖固定分配：QKV0/1各12MiB，STATE1 HIDDEN前8MiB；span不得小于该区域，base+span及所需区域不能溢出64bit。只写上述实际稀疏位置。全128行各QKV有效786432B，但最大exclusive offset为10256384B；norm有效524288B。不能只给每行6144B的连续空间。首次命令即检查全tensor范围；每段/每beat仍核实际包含。相邻行/空洞/STATE0保持哨兵，域映射接线为测试项；不把描述符校验当实际生产BO隔离已验。

正常出口必须合取512个顺序匹配rsp、256个真实OKAY B、各目的96/96/64个B、49个成功flush、read及writer债零；再握手core row_release，消费core成功done，最后产生一次outer done(status0/phase7/bad全1)。不能直接把core row_valid或提前core status0接成写回成功。末B受阻时行保持、禁止release/成功位/outer成功。

## 错误、reset与整请求生命周期

新增phase12=SCRATCH，done_phase仍4bit；wrapper地址、身份、读标签/计数、writer及BRESP错误为status7/phase12，bad_element=0xffffffff（传输失败不冒充数值首错）。保留core数值6及原phase/bad；core早期失败没有本地行时直接消费其真实done，不能等待不存在的row_valid。wrapper若也有协议/传输错误则7/12优先，core成功不能盖掉写错。日志另列目的/真实事务ordinal/响应码。

错误立刻停止新rd发射；已经握手的同步读必须返回并消费/作废，不能清预约冒充排空。BRESP错误沿原writer取消未发held/pack，已经展示的TX继续完成真实AW/W/B；可能同拍接受的tile明确计入取消，不算成功。标签等wrapper错误需flush此前已交writer的payload并排空；不把坏rsp送入writer。错误出口等read债零和debt_zero，不等仅成功才有的flush_done，也不强求512/256完整计数。之后实际release本地行、消费core done，一次outer错误；已写字节保持隐藏，绝不声称回滚。缺B只能保持在途/成本停止，不伪造响应。

tensor只维护一个活动request/generation、完整model/numeric、固定task字段、三目的描述符和128bit row_written＋sticky tensor_failed。`cmd_tensor_begin=1`只在无活动tensor时建立新上下文，三个dst_epoch必须等于非0 tensor_epoch；首次epoch=1，随后必须上一已释放epoch+1，不允许32bit回绕。begin可与任意未写row同一条QKV命令；非begin须精确匹配活动上下文/目的描述符且未失败，禁止已写row重新计算/写入。非法begin、短span、epoch/身份不匹配或重复row在启动core/总线前返回7/12，旧上下文保持，不清覆盖。没有活动tensor的普通QKV行同样拒绝。

只有已接纳到活动tensor的一行在完整写回/release/core成功done后才置该row位；已接纳行的core/写回失败置sticky failed，后续QKV行拒绝。所有128位齐、无failed、全部债零且末行outer done已消费后才拉高`tensor_raw_valid`；保持身份/epoch/descriptors至释放。两行主场景不能填剩余位。RAW是pre-RoPE Q/K/V，尚非Attention可用FINAL；norm保留供未来skip。FFN在tensor未完整或failed时可以运行，只要writer/core/outer完成已退；FFN不能清failed/覆盖或发布该tensor。

新增`tensor_release_valid/ready`、`tensor_release_discard`、`tensor_release_epoch[31:0]`及request/generation各64bit。仅在身份匹配、无活动row/read/write/core/outer done时ready：discard=0须tensor_raw_valid，表示未来消费者已释放；discard=1仅允许尚未发布的partial/failed tensor显式作废。已发布tensor不接受discard替代消费者释放。握手后清有效/覆盖/failed并保存最后epoch，新begin才可复用目的。非法释放保持ready0且不改变状态；与row cmd同时请求时释放优先，cmd不握手。暴露row_written/tensor_failed及tensor身份供集成/检查；它们是元数据，不是保存payload。

共同同步reset覆盖wrapper/core/writer和受控AXI peer，清新增valid/预约/计数/覆盖/epoch；旧RAM/外存残留字节无效。局部短例分别触发读已接受未返、AW先接受W未接受、W先接受AW未接受、AW/W均接受待B。不能只reset DUT遗弃总线真实债，不签独立总线reset、旧B自动匹配或复位后完整模型恢复。

## 同输入证据与有限验证

A001独立复核研究52条文件/窗口身份及20项byte/整数布局条件，7份current RTL匹配AT192/194；writer原SHA16069207…匹配109原manifest、9例PASS日志与child0/null守卫。已核row0/1保存scatter全部6144词与norm，且枚举全128行32768个域内beat无重叠、边界正确。这是静态依据，新增包装层/rearm/发布均NOT_RUN；见[机读依据](lnq_review_evidence_20261015.json)字段revision13_qkv_scratch_static_review及[研究绑定](../../source/fixed_graph_support_20261014/qkv_norm_scratch_binding_20261015.json)。

1. 先在同一生产writer/行消费者上做短例：旧9例受影响回归；正常连续行、真实B错排空后rearm、带债时rearm不能握手；49段切换/页尾/对齐/span溢出、rsp保持/错误标签/既有待读排空；三口AW/W两种顺序、B有限hold；上述共同reset。生产消费者可独立模块化以接合法同步row peer，不复制生产判断，不force FSM/valid/债/done。保存数据只作为注明的局部入口，不能记全链producer。tensor完整128位发布及末行/重复row/旧epoch/显式discard与release可用该局部peer短事务验证元数据，不冒充128行真实QKV数值通过。
2. 主要场景同一runtime：真实原embedding row0 cold、完整LN/Q/QKV及norm→全部scratch成功B→release/core done/outer done；接同请求row1 warm、完整真实producer→全部scratch，但在最后norm TX实际AW与W均接受后hold B若干拍，最后给真实非OKAY BRESP。逐bit核两行原norm1024、Q/scale32组、12288个8lane PS的六字段及3072 final，独立原scatter/norm检查实际写地址/数据/strb。共512次真实AW/W/B、32768B发送；错误事务的写入效果不作可靠发布承诺。row0位=1、row1位=0、failed=1、tensor_raw_valid=0；错误排空/释放后仅一次错误done。
3. 三目的分别保证真实AW和W阻塞、AW先/W先接受、末B延迟命中并打印计数，不能仅周期门控假定覆盖。正常末B前无release/成功；错误末B后无tensor成功。保留W/AUX warm增量0和独立邻行/空洞/STATE0哨兵；FFN期间scratch写事务增量0。
4. row1写错后无reset进入原FFN cold，实际Wi slot0 epoch2、初次Down slot1 epoch1，两个LOAD都核load_error=0及READY/完整身份。真实前LN row0→Wi20992 PS→G2624→Down10496 PS→ADD1024末残差→完整128tile消费者/release/done，沿原独立checker逐bit核全链。此时才可签本runtime所测写错排空后的跨mode完整FFN。AT193错FFN warm拒绝按未变core身份复用，不再重演冗余长前缀；不得把AT195前缀拼接成本次完成。

主场景各子终态及最终marker分开；退出0、无Fatal/Error、guard正常且所有末端覆盖检查通过才是整次PASS。工具exit0但fatal仍FAIL。记录真实cmd接受/本地行可读/首末read、AW/W/B、release/core done/outer done与全局单调cycle，真实scratch计数独立命名，不能复用旧FFR1_PROGRESS的aw/w/b别名当总线证据。旧Wi/Down bad/poison、内部主动反压和部分R后reset不扩成长前缀补测，本段未覆盖就保持NOT_RUN。

## 独立预算、连续执行及出口

修订13预算：host准备累计≤300s/8GiB；static/IP/展开累计≤1800s/24GiB、单次≤600s；RTL含pilot/局部peer累计≤4800s/8GiB、单次≤2400s且全局≤1Mcycle。必要pilot≤120s计入同一累计；可用同一次预先有2400s硬帽主运行的前120s为profile检查点，记录并更新预估，避免为采样必然杀停重放。这不允许动态提高硬帽。主运行前先取得新writer/adapter短例实际计量，结合未变core已测阶段成本；cold LOAD采样不能单独预测matrix/FFN阶段。

预算依据为AT193两QKV行及后续失败前缀714.517s、AT195一QKV＋近完整FFN1100.280s，二者相加约1814.797s包含重复前缀，可用于保守规划，但不是新场景完成上界。新增writer停顿/接口成本须profile，单次2400s及累计4800s为有限新连接/受影响修复额度，不保证达到全部覆盖。预计不能落帽则保留缺口或采用有证据的局部分解；不得缩K/N/S、改gold、预填cache/compute bank或仅延长旧例。全部失败、pilot、被杀、普通修复按实际工具命令归类，原收据不覆盖。

全项目单重工具，CPU0–3/nice19/idle I/O、MemAvailable>192GiB，采样实际owned进程/RSS。RTL120s无真实握手/阶段语义进展停止；新writer进展包括真实AW/W/B及row-read，计数仅在有证据的reset/命令epoch切换归零。总墙钟独立保护。host未采样部分保持UNKNOWN，不填0。无OOC/P&R、模型前向、新gold、参数扫描或新agent；普通RTL/TB/脚本修复在帽内连续完成，不新建逐步审核门。实质接口/数值冲突、同因重复且无新依据或成本出口时集中回报。

阶段交付仍写现有SM004阶段报告、E002 design/results及E004三摘要，给最终冻结身份、逐项PASS/FAIL/COST_STOP/NOT_RUN和准确账。修订13下达仅代表实施授权；新的scratch写回、rearm、tensor发布、跨mode完整FFN当前均NOT_RUN。实际全128行生产、RoPE RAW→FINAL及写债、Attention加载/mask、完整Encoder/模型、生产Host/HBM和联合资源/Fmax继续开放。
