# 修订14：真实QKV scratch→Encoder0 full RoPE

2026-10-15；D-M004-QKV-ROPE-ROW-01；M004/SM004/E004/R001。A001集中确定接口、参考、范围及预算，A002独占实现并连续执行编译、仿真和普通修复，无逐步放行。接续已批准完整模型目标，不新建mission。A003保留研究文档所有权；所有角色共同工作，不回退他人修改。

## 起点与范围

修订13已按D-M004-REV13-CLOSEOUT-01收束：AT204完整真实链仅属wrapper e5dde5cc…；当前wrapper `daae56115474afa20d04598964eca85869e86226ca9abcf3e5e8945660e06db0` 有AT213局部控制和AT214真实core/IP展开证据。core `54fe628fac0d1a9dd4c61455c45e55eb3abe499034d7bb23157b9ac8d4b8bf78`、writer `ee1121c5fd0b6651d6f7ff3d859fb60b57ae871cbebb011ff2994af9e3372218`不变。新连接不能继承旧wrapper完整数值PASS。

采纳隐藏状态下逐行RoPE：一套原LN/Q/matrix/W/FFN计算core、一套现writer；新增薄RoPE适配器、一个scratch reader及一个AUX table reader。RAW写完成并真实释放/消费core done后，从刚写出的scratch真实读Q/K，运行原完整Check叶子，原址写回、等待实际B。仅当前一行完成；下一QKV/FFN命令不得与尾部并行。旧RAW-only和FFN分支保留，不复制计算top、整行或整tensorRAM，不接Attention或生产Host。

## 叶子、读写和数值

唯一叶子为 `project/E002_Laya_HLS/experiment/build/full-hls-20261007T030653Z-1859617/rope_probe/solution1/syn/verilog/rope_head.v` 及原依赖/FP Tcl，按研究binding的完整SHA冻结；其生产C++ SHA `17b57824d2213d8bf83751936346af4225618d9e40c5b3fc49c570bb971163ec`。保留128bit Check的code[15:0]/detail[63:32]/bad[127:64]；不能替换成只返回code的兄弟cosim wrapper，也不重做HLS/另写数学近似。旧兄弟cosim不代签本叶子新接线。

Encoder0固定full表，逐head按(i,i+32)配对。四乘和减/加各自F32舍入、逐步finite，无FMA/FTZ/近似；即使当前两半表相同，仍独立读cos/sin的i与i+32。保留原预检d0..63以及每pair下半结果优先于上半的Check次序。每行按head0..15、每head Q再K处理；V/norm不改。

scratch使用 `t4_w_reader_port_v1` SCALE_MODE0，每head真实load256B；两QKV域新增AR/R512，选定shard和base直到load_done及FIFO消费完才切换。表使用原 `t4_aux_bias_reader_v1`，每行cos/sin各load256B，与core AUX128口只在真实债零后分时复用，保持路由直到整load_done，不能用W cache返回冒充scratch。reader只收到64项/out_last不算成功；必须完整offset/epoch/字节覆盖、load_done且无load_error。出错停止新load，已展示AR保持至握手、已接受burst收到真实RLAST、FIFO真实消费/丢弃后才结束。

新增 `cmd_rope_enable` 与 `cmd_rope_aux_base[63:0]`、`cmd_rope_aux_span[63:0]`，仅QKV模式解释。begin锁存并由后续行精确匹配；FFN忽略。AUX是原模型只读域，模型/数值身份沿原cmd绑定。aux_base须16B对齐，span≥1142528B，完整base+span及表/行地址用带溢出位计算；full cos/sin固定偏移617728/880128，各262400B，行s使用offset+s*256。table reader load_epoch使用本次tensor来源e作事务标签，不把它当W槽epoch。不能以task_id替代s或重新算三角函数。

本地head256B和cos/sin512B，head输入与y原位复用，叶子本身saved256B保留；scratch reader原FIFO4096B、AUX reader原FIFO1024B也必须计入。新增有效payload约6144B，另有既存writer160B与元数据/端口开销；不是BRAM/LUT实测。三路ap_memory同步读、双y写按原接口接好，无ready返回必须全接收。只有成功ap_done和完整唯一64项y覆盖后才能交writer；坏head的部分y不写外存。重复/非法写地址或缺覆盖属协议7。

复用单writer linear模式：head base依原布局，n0=0,8,…,56，8个32B tile→4个64B单beat AW/W/B→flush；成功flush撤下且债零才换head/目的。RAW→RoPE前一次债零rearm合法；不能在失败行内rearm清错续跑。QKV地址严格为 `shard=h&1; off=((((p*2+b)*8+h/2)*1024+s)*64+d)*4`，B1 b0，RoPE仅p0/1。三BO容量仍QKV各12MiB、norm8MiB，数值相同base在不同物理域合法；全部64bit范围/稀疏跨度检查保持。

每行新增32head、1024pair、4096乘/2048加减；Q/K读写各8192B，128个512bit R和128笔单beat AW/W/B，256 writer tile/32 flush，表32个128bit R。scratch基址只64B对齐时head读须4KiB切分，32–64 AR；AUX仅16B对齐时2–4 AR。不得承诺固定AR数、速率或物理频率。RAW+RoPE合计每行384笔写，三目的160/160/64；两行768笔写。

## 隐藏覆盖、epoch与完成接口

采用明确预留的双epoch，保留RAW-only兼容：`cmd_rope_enable=0`完全沿修订13单epoch/release规则。启用时begin输入e非0且e≤0xfffffffe，同时预留QKV FINAL e+1；首次begin仍e=1，随后e必须为上一已释放的最高预留epoch+1，禁止回绕。所有生产行输入cmd_tensor_epoch及三个cmd_dst_epoch仍为e，W两槽epoch继续独立逐槽管理。

现tensor_epoch、tensor_dst_epoch保持来源e，描述原入站上下文；新增 `tensor_rope_enable`、`row_final[127:0]`、`tensor_final_valid`、`tensor_final_dst_epoch[2:0][31:0]`。启用时final_dst_epoch为QKV0/1=e+1、norm=e，基址/跨度沿现输出；它们与源描述符在begin锁存，只有相应valid赋予可消费意义。norm保持e且不能因QKV原位变换而改身份。

真实RAW行512响应/256个OKAY B、core release/done全部退休后才置row_written来源位。RoPE完成32head、128个OKAY B、覆盖完整且所有读/leaf/写/flush债零后才置row_final位、给一次outer done。row_written只说明“曾完整生产RAW”，不表示该内存仍可作为RAW读。RoPE模式自begin起tensor_raw_valid恒0；全部128个row_written与row_final齐、无failed、真实债零且最后outer done被消费后，才置tensor_final_valid并保持至消费者释放。两行样本只置两位；不能预填其余126位或用peer代签实际生产。

已发布FINAL正常release要求request/generation匹配及tensor_release_epoch=e+1；未发布partial/failed的显式discard要求epoch=e。两者均须所有事务及outer done已退，握手都消耗预留上界e+1，下一begin为e+2。RAW-only正常release/discard仍使用e并消耗e。已发布结果不能用discard替代消费者release；非法释放ready0、旧状态不动，合法release与cmd同拍仍release优先。FFN在无活动行/债时可运行，但不清tensor_failed/覆盖/预留epoch、不发布tensor。失败后只允许显式discard重建，禁止在已改写的行上重试。

保留4bit状态/phase和成功phase7；新增phase13=ROPE，phase12仍RAW scratch。原core数值6/phase/bad透传。RoPE传输、标签、计数或覆盖错误为7/13、bad全1；叶子数值错为6/13，`done_bad_element=plane*1024+head*64+leaf_bad`，result_row给token位置。新增 `done_rope_check_valid`、`done_rope_check[127:0]`、`done_rope_head[3:0]`、`done_rope_plane`，保存原Check的完整定义字段及调用位置到done握手；只在确实消费本次leaf done时Check有效，协议优先可仍保留该诊断，不伪造Check。未知非0叶子code按协议7处理并原样保留Check，不截断为6。

当前服务只承诺本次row内head→Q/K→原Check顺序；它不是旧全请求head优先调度的全局首错接口。此差别必须记入集成限制，后继完整请求控制在接入前另行解决，不能称已经保持原全请求首次遇错顺序。模型正常数值和叶子Check规则不变。

## 错误排空与共同reset

错误锁存后停止新head/read/leaf发射，不撤销已展示AR/AW/W或伪造R/B/done。reader等真实RLAST、FIFO清空及load_done；writer保持必要flush发送已接收pack，最终等真实debt_zero，不等成功专用flush_done。已发leaf完整消费done/其同步输出，再报错；未发operand可以明确作废，不能清算术债。此前部分外存写没有回滚，tensor sticky failed、行FINAL不置、完成一次；正常末B前不能row_final/outer success。无返回时由成本守卫停止，不编造成功。

共同reset包含wrapper/core/adapter/reader/writer、叶子HLS控制及受控AXI peer。所选FP Tcl has_aresetn=false，不声称算术位全清；新增adapter清活动/覆盖、以510拍隔离窗口禁止新leaf start并拒绝旧y/done进入可见写，随后才接下一合法局部head。不能在正常head/阶段之间reset消债。实际MUL已接受未返的观测遵循[D-M004-ROPE-MUL-OBS-01](qkv_rope_mul_observation_decision.md)：该IP无ready且valid常高，须由具体操作调度、原输入寄存和实际使能采样沿绑定本次head，分别记录IP输出与HLS结果采样。严格IP未返回窗口不能证明时保持NOT_RUN/UNKNOWN；可另签已接受但HLS尚未采样的控制隔离，不能替代前者，也不能用ap_start代替算术接受。AR后部分R、AW-only、W-only、AW/W待B边界同样只签所测DUT+peer共同reset，不签独立AXI reset或完整128行恢复。

## 冻结独立参考

主控已核研究82条静态身份中81条当前相同，wrapper后续修复单列，另核15项保存字节/整数布局。原静态缺口经D-M004-ROPE-REFERENCE-01有界补齐：仅调用原未改 `full_reference.py` SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784` 的RoPE函数，先通过旧四叶子256项及旧两行6144项校准，再计算当前task2_real_fixture_20同输入两行。原参考和工程gold未覆盖。

后继checker冻结 `source/fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/manifest.json` SHA `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2` 及其inputs/products。主控核61条身份、全部输入窗口和4096个步骤输出字段绑定；研究363项条件通过，求值/字节核验0.35+0.06s单列，非工程RTL账。row0 FINAL SHA `d4d1b006b7d46e84fc13c431cd781b930d871149382a68a37cd81377ad7aee1b`；row1 FINAL SHA `f4fa2f826ab8f9202f5f589ae531e84956700c5a154ef600320592e8cab09def`，每行12288B/[3,16,64]/little-endian F32。两行各2048 Q/K完整计算、1024 V及1024 norm原字节不变；不是只有row1的78项。六字段步骤供诊断，函数间一致性不是第二独立oracle。

工程只复制/无损格式化这些冻结输入和期望值；不得从DUT重建expected、不重新求整模gold。reference window两行不改变模型B1/S128。异常Check测试用原叶子语义和可解析有限位型，不能把Python正常域异常当完整Check oracle。

## 有限验证与验收范围

1. 先做同生产adapter/leaf/reader/writer局部短例。原s127h15 Q/K两个完整保存样本、非对称两半表、末pair和多个非finite位置核Check完整ABI/原预检及计算首错次序；通过合法同步内存接口，不force valid/FSM/债/完成。覆盖读页尾分段、实际部分R后的RRESP错、最后head AW/W后B错、上述共同reset及后继局部恢复。可用合法模拟core row peer先真实写RAW再由新链从内存读取；它只证明局部接点，不冒称真实embedding生产。
2. RAW-only原生产包装层/writer局部peer回归、FFN直接错误done/结果回显/flush同拍错误回归，及FFN读释放透传。完整128位RAW/FINAL发布、旧epoch/重复row/discard/释放规则可用合法完成peer专测元数据，必须标注没有128行真实算术，不force覆盖位。无需为未变FFN算术再跑AT204长例；新wrapper未测完整FFN保持明确。
3. 主场景同runtime：真实row0 cold LN/Q/QKV→RAW scratch全部OKAY→完整full RoPE→outer done；随后同tensor row1 warm完整同链正常。保留原两行norm/Q/scale/PS六字段/3072 pre-QKV checker，再逐位核全部4096个RoPE Q/K FINAL及V/norm不变。RoPE输入必须来自总线模型中真实RAW W提交后的内存；表从当前AUX真实AR/R返回，不能从TB直接喂leaf或预置QKV结果。row1不能沿用AT204末norm错误B，否则无合法RoPE输入。
4. 三域实际内存模型记录接受写，并按真实scratch AR返回，核每笔地址/数据/strb及实际读回、V/norm/邻行和合法范围外哨兵不变。两行1024 core响应、512 RAW写＋256 RoPE写，256 scratch R、64 table AUX R；各head输入/表位置/64输出覆盖核对。有限AR/R/AW/W/B阻塞在两个QKV域及共享AUX保证命中，AW/W两种接受次序和阻塞全字段稳定，末head最后B有界hold时禁止FINAL位及outer success。错误短例末B后禁止发布，真实排空一次done。
5. warm“零新增LOAD”只核core原W/其AUX header加载；新RoPE每行都真实读cos/sin，故共享AUX总计会增加，不能复用旧整体AUX零增断言。冷W槽实际成功状态/epoch、每行原矩阵读返/PS守恒、RAW/RoPE分阶段真实计数与cmd接受/outer done周期分别记录，不用全局时间点冒充latency/II。主场景结束仅row0/1两个RAW与FINAL位，无tensor发布；显式discard按新epoch合同验证。

主场景全部成功才能签所测两行真实连接/独立完整数值与传输。局部错误/reset/元数据逐项单列；全128行真实producer、完整请求首错、Attention加载/mask/FINAL与skip消费、Encoder/模型、生产Host/HBM、联合资源/Fmax仍未验。

## 独立预算与执行出口

本段新增host准备≤300s/8GiB；static/IP展开累计≤1800s/24GiB、单次≤600s；RTL含pilot和局部peer累计≤4800s/8GiB，单次≤2400s且≤1Mcycle，必要pilot≤120s且计入。研究0.41s参考准备另列；工程不追加模型求值。修订13累计static615.5153379254043043s、RTL1498.1496843509375738s及未用余额封存，不挪用/重置。

AT204旧1404.050676s包含两行及完整FFN，新段减少FFN而新增64次leaf、scratch读/写和共享AUX，不以比例推新墙钟。先用本版有限pilot/前120s进展检查更新估算，主运行硬帽启动前固定，不动态延时；不能落帽则有依据拆分或保留COST_STOP。无真实语义进展120s停止；新RAW/RoPE读/写/leaf计数单列，归零只绑定实际命令/阶段/reset epoch。全部失败、被杀、pilot、修复计入原分类账，shell exit0不能覆盖Fatal。

全项目一个重工具，CPU0–3/nice19/idle I/O、MemAvailable>192GiB，采样owned RSS/实际命令。无OOC/P&R、HLS再综合、整模型前向、新算法/参数扫描或新agent；普通接线/TB/守卫修复在帽内持续执行。实质数值/接口冲突、同因反复且无新依据、预算出口集中回报。A002维护同一E004阶段报告与三摘要、E002模块design/results；A001集中审核原始证据，不另造逐步审批链。
