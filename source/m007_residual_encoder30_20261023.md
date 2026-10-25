# M007 残差、LN 与完整 28 Encoder＋2 Decision 后继接口

日期：2026-10-23。角色：A011，Astra/xhigh 架构只读任务。实现根仍是 `project/E002_Laya_HLS/experiment`。本文是拟实施的固定接口，不是新 RTL/全图 PASS。A007/A010 的生产文件、旧证据和主控索引均未改。按当前 SM012「并行残差/LN与30层架构核定」授权维护本文件及同前缀 JSON。

## 1. 固定路线与立即可实施的 A007 切口

采用**单份新增 512KiB hidden/skip 银行＋已经退休的 soleQKV Q plane 作为 scratch**。hidden 保留当前残差基值并就地更新；不实现第二份完整 hidden，不复制整 hidden，不把 requirements 的 H0/H1/norm 预算当成已有实例。此处的双缓冲是 hidden 与 Q scratch 两种角色交替，不是两份新增 hidden ping-pong。

每层固定顺序：可选 attention 前 LN → QKV → 原 Attention → context 量化 → WO 实际输出写 Q scratch → 矩阵及共享资源退休 → `hidden + Qscratch → hidden` → 无 gamma LN 写 Q scratch → 完整量化/A 发布 → Wi→GEGLU→Down（或 Decision FC1→ReLU→FC2）→ 最终投影写 Q scratch → 矩阵退休 → `hidden + Qscratch → hidden`。原 residual 的左操作数始终为 hidden；不改变加法次序或逐步 F32 舍入。

**A007 可先实施的最小模块边界：** `attention_and_fp_engine/rtl` 内一个纯 `hidden32` 银行、一个 `resident_vector32` 读/残差 provider；soleQKV 只增公开的 scratch 路由准入，不添加 Q payload。A010 后续在唯一父 FSM 接入。provider 只导出公共共享 add 请求，不实例化私有 add/FP/DIV，不含兼容 validation_shell。

### 1.1 物理地址、容量及 payload 端口

| 角色 | 物理实体 | 地址/容量 | 状态 |
|---|---|---|---|
| hidden/skip | 新增32 bank×4096 F32 | `bank=channel%32`; `addr={row[6:0],chunk[4:0]}=row*32+channel/32`; 524288B | 待实现，唯一新增整张量 |
| projection/norm scratch | 现 `laya_attention_qkv_bank_v2.plane_store[0]` | `head=chunk[4:1]`, `token=row`, `half=chunk[0]`; bank=`channel%64`, addr=`(channel/64)*128+row`; 524288B | 现 Q payload；新角色准入待实现 |
| QKV | 现三 plane、每 plane64×2048 F32 | 1572864B；Q/K/V 完整 Attention 期间均不可借 | 已实现 |
| context | 现 `laya_attention_storage_v1.context_store` | 64×2048 F32，524288B | 原 Attention→WO 消费，保持现接口 |

hidden 银行固定全32lane、无逐lane mask。`wr_valid/ready, wr_addr[11:0], wr_data[31:0][31:0]`；`wr_commit` 精确等于 `wr_valid&&wr_ready`，在该上升沿真实同步写。该 commit 是真实 ACK，不虚构下一拍完成；若接入器选择保持型 ACK，必须将新增寄存器和实际消费债另计。

读接口为 `rd_valid/ready,rd_addr[11:0]` → 下一拍 `rd_rsp_valid/ready,rd_rsp_addr[11:0],rd_rsp_data[31:0][31:0]`。恰一份保持返回 credit：`rd_ready=rst_n&&enabled&&(!rd_rsp_valid||rd_rsp_ready)`；backpressure 下全部 response 字段稳定。接受读与同址写冲突时**读优先、写不接受**，非同址可同沿1R1W；读返回寄存器仅新增13bit控制＋128B数值数据。payload 不 reset 清零；reset 只失效响应/资格。`bank_idle=!rd_rsp_valid`，正常换 owner 还要求该拍没有新读/写接受。

Q scratch 32F32 写直接映射现 `wr_plane=0,wr_head,wr_token,wr_half,wr_data`；commit 同样为真实 `wr_fire`。读走现 plane0 同步64F32响应，使用返回 tag 的 half 选32lane；不新增另一个64F32副本。可以连续对同一个 head/token 读取两次分别选 half，合计4096个32F32向量，仍允许每拍一个向量；不依赖异步 RAM。

公开 scratch wrapper 采用 `owner_valid + owner_request[63:0]/generation[31:0]/epoch[31:0]` 资格线（从唯一父持有的身份直接导出，不另锁一套128bit）。每个访问携相同操作身份，错身份报告 reject、不握手。物理 Q bank 无自身完整身份，不能把 raw `wr_ready` 暴露为绕过资格的入口。scratch 资格需 layer 真 `L_IDLE`、RoPE owner 无效、全部 QKV read response 已消费、旧 matrix/quant 消费完成；关闭普通 layer prepare/QKV/RoPE 入口。下次 QKV prepare 前 scratch 读/写真债清，撤销 scratch 资格，再走原完整 QKV coverage；scratch 写不更新 QKV coverage。

### 1.2 残差 provider 与共享 FP 的握手

provider 接受 `start_valid/ready, op=RESIDUAL, request64,generation32,epoch32`；身份由父命令持有，provider 的每个访问/返回与之匹配。坐标按 row0..127、chunk0..31 有序推进；发出4096对 hidden/Q 读取。为避免单边接受，两侧请求组成一个原子 join：仅在两边均有返回槽时给出同一接受事件；两份同步返回必须同坐标，二者仅在共享 ADD 实际接受时同时消费。禁止用两个独立计数器猜配对。

共享 FP 先真实 lease `phase=7,head=0`，在 lease ACK 后 issue。仅 group0 ADD 使用 lane0..31：`a=hidden`, `b=Qscratch`，其余 lane 给有限零；mul/其他 ADD groups 不发请求。`add_req_valid/ready` 与真实 tag/身份返回串联，F32 次序不交换；返回 lane0..31 写 hidden 原地址。`add_rsp_ready` 只在 hidden 写可以接受或明确错误排空时拉高。每个写 commit 退休对应向量；非有限 lane 按原 residual 的 row/chunk/lane 次序登记首错，停止成功发布并真实排空。

**WO/Down 活跃时仅写 scratch，不能同时借 phase7 ADD。** 必须先消费 matrix success DONE，输出写完，matrix 的 A/W/PS/FP leases 和 return credit 真清，再取得 phase7。全部4096次 hidden commit、所有读/ADD 返回及 held response 清、FP release ACK 后，才发可保持 `done_valid/status`。done held 禁止重配；错误只取消本 owner，禁止 reset 其它服务。

无背压的目标：首结果≤32拍，4096向量每拍1次，整个残差含fill/drain/真实release≤4160拍；实际周期只由未来 RTL 证明。固定两级同步 read+共享ADD≤8拍并不自行证明总帽。验证必须从 start 接受到成功 DONE 退休计数，额外外部 held 周期另列。

### 1.3 立即后继验证（不由 A011 执行）

先银行32lane全地址映射、同址读优先/异址并行、held响应、旧identity、无reset新epoch；再用原 Encoder0 独立 `hidden_skip` 和 `wo.bin` 做全131072元素 residual 与真实phase7共享ADD逐位核对。随后接原矩阵输出到 Q scratch 的真实握手，检验末WO/末Down held、矩阵 DONE 已到但资源债未清时残差不能启动。全过程不灌入 gold 充当生产者、不 force 内部状态/债/owner。

原独立局部来源为 E015/R001/AT007 的原 Encoder0 reference；具体文件与原独立 CPU 规则见后续来源表。A007 的当期终点取消验证先合法结束；实现需由主控发新的明确 owner/预算，不转旧余额。

## 2. LN provider、第三 owner 和控制的精确差额

### 2.1 固定接线与生命周期

复用现 `laya_m007_layernorm32_v1` 算法和两标量叶；新增显式 production-canonical 配置及 `control_q/control_next/control_enable` 外置状态接口。默认兼容配置保留任意96-bit opaque input tag 逐位回传，不改变原 E014 公共行为。生产配置才使用下面规范 tag，只有父明确选择该配置并通过身份/格式预检时省去标签存储。

LN 命令固定 `rows=128`；入口以 row/chunk 顺序从 hidden 同步读口供给。`in_valid/ready` 真握手才前进；输出 row/chunk 按现回传字段写 Q scratch，`out_ready` 直接依赖真实 scratch commit 能力。LN 期间 hidden 只读，scratch 只写，不能同时开始量化或 QKV。全131072输出已 commit、LN DONE已消费、内部 per-ctx add/mul/read/write/scalar债全零及 holding清后，真实释放 phase6 FP/DIV。随后独立 phase7 quant 读取 scratch，所有4096组实际 A 写 ACK、发布成功和 quant/DIV退休后，才允许下一矩阵覆盖 scratch。不要把 LN DONE可见或末输入已收当作该交接。

LN 使用同一 sharedFP256 的 phase6/group0、同一 DIV8 lane0、同一 LN-exp 32768B；不需要 EXP/TANH。phase6 ADD 本身整256lane服务，LN 的真实树/平方/归一化 lane 分配保持，不能为 residual 另取空 lane 并发。LN-exp 映射仍为 `bank=(ctx*2+raw_or_delta)*32+element%32, addr=element/32`；只有真实 write ACK 增 coverage。由旧 softmax 的实债清和 bank idle 交给 LN，再按相同条件归还；phase切换不清 payload，不复制 LN行缓存。

### 2.2 规范 tag 和不降低返回信用的压缩

生产 tag 固定为 `{16'h4c4e, op_epoch[31:0], op_generation[31:0], row[6:0], chunk[4:0], 4'b0}`，共96bit。request64仍由公共 lease/操作身份检查；tag不替代完整身份。输入接受前核等式；输出从当前ctx真实row和返回chunk重建。原 `input_tags[4][32]` 12288bit和 `out_tag` 96bit只在此显式配置下通过 generate **不存在**。默认旧配置保留原数组和任意合法 tag 行为。

保留 add/mul各64项 metadata 和原 outstanding/credit 上限；E014 AT033 已测 mul pending54，不能为了省空间武断改成32项。

原 ADD entry 有22个8-bit item。前20个是两棵相邻树各10级，后2个是delta/eps。每个item仍保留valid与ctx2；每棵树的输入节点范围如下。返回读取 compact item 时补零还原现8-bit item；invalid item只读valid，不使用其它位。

| 树 stage index | node/chunk 合法范围 | index bit | item总bit |
|---|---:|---:|---:|
| 0..4 | 0..31（同一个原32元素chunk） | 5 | 各8 |
| 5 | 0..15 | 4 | 7 |
| 6 | 0..7 | 3 | 6 |
| 7 | 0..3 | 2 | 5 |
| 8 | 0..1 | 1 | 4 |
| 9 | 0 | 0，重建为0 | 3 |
| delta item20、eps item21 | 保守保持原0..31 | 5 | 各8 |

每棵树65bit，两棵130bit＋delta/eps16bit＝146bit；原176bit每项省30bit，64项省1920bit，hold meta另省30bit。stage5..9的生成仍是原 `node>>1`，ctx/valid不变；应断言高位确为零，不能截断非法节点后继续成功。

标量scale的局部tag只需 `{variance_flag,ctx2}`（3bit），sqrt work/rsp各只需ctx2（2bit）。它们均在当前 LN owner lease 内，不跨操作；DIV完整96bit请求tag仍由公共op身份和ctx重建。两标量叶默认TAG_WIDTH=96不变；生产实例显式参数3/2。由现3份96-bit局部寄存器共省281bit。

### 2.3 逐字段账与真实共享约束

现 E014 AT031逐寄存器账：gamma32768bit（4096B），其余44761bit。其中 **26706bit为管理/身份/tag/coverage/debt控制，18055bit为F32 holding/数值标量及sqrt数值状态**。18055bit（2256.875B）全部保留在实际FF/资源总账，不能以共享控制为由删除。此拆分是对原逐字段账的透明分类，不把数值holding改名后隐藏；旧原44761bit仍可复算。

控制压缩：`26706 -12288 -96 -1920 -30 -281 =12091bit`。其中gamma持久状态132bit必须放arena外：`gamma_loading1 + gamma_loaded1 + gamma_coverage32 + gamma_done_valid1 + gamma_done_error1 + held_model64 + held_key32`。剩 **11959bit** 是第三 owner LN view，可落入现唯一12288bit物理FF arena，余329bit。完整63个字段、位宽、lsb/msb及实际来源SHA在[同前缀JSON](m007_residual_encoder30_20261023.json)的 `ln_arena_fields_proposed`。里面保留LN request/gen/epoch128bit，不假定会自动与父合并。

现 LN 全局 `aborting` 的错误顺序缺口见§5；固定后继将其换为4ctx失败mask，净加3bit，LN view变11962bit，余326bit。该数值仅静态布局，未实现/未验证。gamma存储、F32 operands、数值标量和原FP/DIV流水tag仍是真实物理实例，各自单计，不能只报告4KiB就宣称总FF/DSP通过。

workspace owner由现1bit A/G改为2bit：`ATTENTION / G / LN / VECTOR`；rearm原1bit保留，新增owner净1bit。VECTOR使用同一arena小视图，装residual/type/gather必要计数，不与LN并发。真正状态q只有一份；各客户端导出next并受owner-enable门控，不保留影子数组。LN active/debt/error都在union内，非LN时不得让其组合垃圾参与ready/idle；必须由已成功执行的退场屏障证明其已退休，然后关闭全部LN写入/请求。不能用“未选中所以debt=0”绕过仍活跃的LN。

切换前提是**原owner真实退场**：Attention已有context完整消费/合法discard且layer/head/RoPE idle；G全部输出/held DONE/needs_discard/FP/SFU/storage债退休；LN内部work_debt_clear、active0、done0且FP/DIV实际release完成；VECTOR读响应/ADD/写commit/held DONE清。切入先统一清 scratch控制view并rearm一拍，再允许新cmd。gamma132bit独立保留；装gamma只能在LN owner下且实际idle，load不与LN命令重叠。所有错误/最后一次响应/新generation均走该真实屏障。

### 2.4 父联合4KiB边界

当前基线4036.375B＝32291bit；不是 LN 已纳入后的值。未经共享，直接加入现 LN 全44761bit会成为9631.5B，不能宣称合规。

固定后继的**管理控制设计预留**为：R005 FFN20bit、gamma持久132bit、owner扩展1bit、hidden读credit13bit、父FSM由5到7bit净2bit、marker行16×7＋mask16＋qtype2共130bit、两份descriptor有效2bit、hidden/scratch角色资格4bit、错误domain扩展1bit，共305bit；`32291+305=32596bit=4074.5B`，余172bit。VECTOR暂态计数/握手及LN view放同arena；现父 `inputs_accepted` 在互斥阶段复用作输入/写入计数，不新增第三套完整身份。该账是可实施的分配上限，**尚非最终源码fit**；尤其新增系数vault装载/有效覆盖、scratch拒绝/恢复和最终ABI其它字段必须全部纳入剩余172bit或先真实合并既有状态，不允许默认免费。

不得在A010尚在实现R005时覆盖其实际20bit结果；最终以R005同版完整声明重新加总。若上述字段最终变宽或需要独立hold/第二payload，应原数计入，超过4096B即为工程缺口；没有改变控制帽或默认追加预算。

## 3. 全30层唯一调度、epoch 与descriptor

### 3.1 原图事件表

以原 `full_reference.py/full_forward_graph` 为数学依据（见§7）：

| 范围 | 固定次序 | 次数 |
|---|---|---:|
| Encoder0 | H0直接QKV；full RoPE/full Attention；WO；残差；LN0；Wi5248→GEGLU2624→Down1024；残差 | 前LN0、后LN1 |
| Encoder1..27 | 前LN0；QKV；family按layer%3；Attention；WO；残差；后LN0；Wi/G/Down；残差 | 前LN27、后LN27 |
| Encoder27之后 | `final_norm_w` gamma LN；`type_emb[qtype]`逐元素F32加 | gamma LN1、type add1 |
| Decision0、1 | 前LN0；有bias QKV；无RoPE/full Attention；有bias WO；残差；后LN0；有bias FC1(4096)→ReLU→有bias FC2；残差 | LN4 |
| 输出 | 顺marker槽0..15 gather原hidden；再独立raw CLS row0 | 17×1024F32 |

合计设备LN=`27+28+1+4=60`，残差60，Attention30（Encoder full10/sliding18，Decision full2），大Q8=`28×4+2×4=120`。Encoder0不能重复加前LN；final gamma不能省；Decision FFN是ReLU，不是GEGLU。ReLU严格 `x>0?x:+0`，包括−0变+0；bias放在矩阵有序恢复之后，不能挪入LN或激活之后。

final gamma LN输出先写 Q scratch；type add读Q及对应immutable type向量，经共享phase7 ADD写hidden。type只选0..2，保持原qtype合法域。无需先把final_norm整张量复制到hidden。最终gather直接读hidden；无效marker映射CLS且mask0，重复marker保留原槽顺序。544个32F32输出向量共69632B，实际D2H写完成和TAIL_READY退休前hidden不能覆盖。原CPU marker LN/scorer/ACT继续执行，未以gather帧代替18logits。

### 3.2 阶段descriptor与epoch

保留父现两份 `tensor32 + base[4]64 + span[4]64`，不用一次BEGIN再锁四份造成额外1024bit base/span。模型setup把120项固定descriptor表置于只读模型元数据/HBM，完整model/graph/numeric/layout/build已验证后按graph stage供给。

新增流接口：`desc_valid/ready, request64,generation32,source_epoch32, global_layer5, pair_kind1, slot1, tensor32, base[4][63:0], span[4][63:0]`。pair_kind=Attention(QKV/WO)或FFN(Wi/Down、FC1/FC2)。ready只在被覆写slot无active消费者、W请求/返回已排、旧matrix DONE已消费时成立。slot0/1沿用原base/span寄存器，每次实握手重验tensor、K/N、4KiB对齐、span及64bit加法溢出。当前对两个descriptor同cmd锁存的入口后继转为固定图内补给；不能只加valid却仍保留第三/第四副本。

Attention开始前取得QKV/WO两描述符；WO退休后覆盖为Wi/Down或FC1/FC2两描述符；FFN退休后覆盖下一层QKV/WO。bias descriptor引用模型vault偏移，不能沿用上次tensor的系数身份。descriptor等待时间进入真实父cycle/请求延迟，不把Host逐阶段发命令假装最终一次BEGIN；最终由设备固定图reader自动供给，bring-up外部流单独标界。

固定epoch命名空间：保留原source_epoch寄存器不动，下游操作epoch组合计算 `source_epoch + 16*global_layer + op_code`，global_layer0..29，op_code按唯一阶段编码（preLN、QKV、Attention、contextQ、WO、residualA、postLN、WiQ、Wi/G/Down、residualF）；final gamma/type/gather占480/481/482。BEGIN预检 `source_epoch<=0xfffffe00`，预留512个epoch避免wrap。每个复合island内部沿用已经验证的同epoch规则（尤其Wi/G/Down的phase1资源束），不在在途时改epoch；下游新的op_epoch只在旧操作全部真实退休后出现。完成对外回显原source_epoch，错误附当前stage定位。阶段编号是拟实现固定表，不能误称现R003已逐stage加epoch。

hidden内容的跨stage持续有效由父已完成事件和角色资格决定，不把每次epoched lease当成新装载；只有新请求入口完整真实写H0后设置hidden_complete。下一层的Q scratch覆盖前必须满足：上一LN→quant的4096组全部实际写ACK/发布/取消退休，或上一projection残差已完整消费。任何abort失效该请求后继资格并保留最早原错误。

## 4. 系数、Decision流与物理总量

当前 matrix_facade 实有 `coeff_words[0:63]`、每项64F32，只是16384B工作窗口（源码§7 R05），不能证明全部73728B Decision bias初始化后已常驻。固定后继将**同一**系数bank扩大为18432F32/73728B vault，保留一份物理数组，按阶段base-offset读取；不另保留16KiB拷贝窗口。净增57344B。八组bias为两层各QKV3072/WO1024/FC1 4096/FC2 1024，合计18432F32；必须从原GGUF绑定并校验全量，不重命名复用另一层。

LN唯一gamma_mem4096B在完整父中只例化一次，载入原final_norm_w。type模型初始化保留原3个Q8行（每行1088B）的来源身份，按原embedding_row逐步F32解码为一份3×1024F32只读区12288B；初始化解码逐位核对，不在每请求额外CPU计算主干。type读取可32lane广播，每次type add共4096拍。RoPE四表131072B原实例保留，不假设复用后可以免除下一请求重新初始化成本。

相对当前父的主要新增payload：hidden524288＋bias扩展57344＋gamma4096＋type12288＝**598016B（584KiB）**；另LN数值holding2256.875B、hidden read holding128B、后继小路由holding及所有控制按真实声明补入。Q scratch新增payload0；LN-exp/PS/G/context/QKV/两A槽/双W槽均各原一份。G量化结果沿现R005填A对应槽，不能又把356864B G量化缓存重复实例化。

hidden按32bank、深4096、宽32的常规RAMB36映射估计128个BRAM36，单纯bit容量下界114；这是映射估计，不是综合结果。现QKV/缓存/FP/SFU等加总后能否满足联合1200 BRAM36、640URAM、7200DSP、LUT/FF帽未知，必须同版综合计数；不能以598016B小于某个逻辑budget签资源PASS。EXP和TANH当前尚未物理合一，仍计实际两实例；SFU/div/vector896DSP帽不降低。

Decision FC1输出每32F32经原ReLU32后进入同quant/A服务，按row/group真实写ACK形成K4096输入；不存整2MiB FC1输出。FC1读取A旧槽时向另一A槽填ReLU结果，需独立束路由，不能global owner屏蔽合法写。全部16384组发布、FC1/producer关闭、quant和DIV债清后启动FC2；与Encoder G的10496组计数分开。bias FC1/FC2列数与K不同，不能复用旧QKV结束条件。Decision仍待完整数值/周期/故障证据。

## 5. 原始首错语义与仍开放的事实

来源事实：E014接口注释和handoff明确局部 `stage/level/row/node` 不等于全模型首错；`layernorm_rows` 先检查一个16-row tile输入finite，再逐row执行树/统计/归一化。现LN任一四ctx首先在墙钟发现异常便全局aborting，不能证明总是返回原逐row第一个失败。因此当前plain/gamma正常PASS可复用其原身份，不能顺带签原图异常顺序。

固定生产修正：hidden入口及每个残差/type生产者完成前已完整finite检查，只有成功后才能进入LN，因此生产LN输入tile-finite有上游真实证据，无需额外4096拍扫描。此限定必须由生产准入断言证明；诊断注入非finite hidden仍在其合法装载处按原tile/row/element顺序报错。LN中保留当前最小原顺序错误候选，4ctx失败mask隔离坏ctx及更晚row，**较早row继续实际运算/检查到可判定终态**，不能因稍晚row先报错就截断更早row。原stage、tree level/node、row的排名从原CPU检查语句逐项映射，不仅按墙钟或stage编号猜序；已接受的badctx真实请求仍排尽。只有更早rank已闭合才发布失败；scratch可能已写的后续值永不被量化发布。失败mask净+3bit只解决状态容纳，正确性需专门回归。

重点反例：row1先出现较早pipeline阶段错误，而row0仍有未检查tree2/输出；后到的较小row错误必须胜出。对照同时包含row1唯一错误、row0唯一错误、两个错误相反到达顺序；固定相同输入、FP延迟、背压seed，观测原CPU异常位置、候选收集、ctx真实排债与最终tuple。独立FP端口不支持的故障不force，登记NOT_RUN；自然合法finite极值能触发的平方/树溢出优先。

当前验证结论仅为：原Encoder0 Attention父链E016/R003 PASS（256947拍，真正父终态另有末WO到DONE数拍）；独立plain/gamma LN E014 PASS（16618/16626拍）；独立完整G E018/R002原范围PASS（42171拍）。E018/R003终点取消、E016/R005 FFN由各owner当期证据判定，本文不抢先改变其结论。完整Encoder、Decision FFN、60次LN、120矩阵全图、最终一次BEGIN、联合4KiB/物理时序、U55C与端到端目标均未由这些局部结果证明。

## 6. 有界、可区分的验证顺序

A011不运行EDA、不生成新gold。以下由主控按阶段另定预算和owner；沿现一重工具锁、CPU0–3/nice19/idle、MemAvailable>192GiB及各类别RSS/40Mcycle/真实语义停滞120s约束，未变证据按原身份复用。

| 顺序/适用范围 | 对照和固定变量 | 真正观测与成功标准 | 反例/停止条件/资源 |
|---|---|---|---|
| 1. hidden/Q scratch＋residual | 同原Encoder0 skip、WO、同FP版本，分别正常和有限held | 131072个F32逐位；4096次读/写commit；真实FP phase7；≤4160拍 | 同址冲突、末返回held、错epoch、新gen；先≤120s pilot，未有成本不直接长跑 |
| 2. LN compact独立受影响 | 原E014 4ctx/128row plain及gamma，default任意tag vs canonical模式 | 所有中间树/stat/输出逐位；64项信用不降；16618/16626旧值作背景，正式仍≤16704；单arena真实声明 | stage5..9越界/有效项重建、mul pending54、gamma/held DONE/owner切换；先短例，再同版成本许可全128 |
| 3. 原图首错 | 原CPU16-row检查次序与同输入，改变返回/背压到达顺序 | 更早row候选不丢；不发布scratch给quant；原错不被取消覆盖；真债零新gen | 两ctx不同失败先后；无可达触发不伪造覆盖 |
| 4. Encoder0 LN→FFN→末残差 | 原E015 norm_ff及R005固定8×16行CPU参考只作checker；生产来自真实前段残差/LN | Wi/G/Down必须同runtime真实算；full128/335872G/10496Q组/131072Down；最终等原encoder_00_out | 上游失败→Gcancel→quant部分fill取消；记录每阶段真实成功事件；≤3600s完整许可只在当期同版pilot证实后 |
| 5. Encoder1 sliding、Encoder27边界、Decision0/1 | 使用同一生产实现，改变合法layer descriptor/原输入；不改gold/算法 | full/sliding在abs(q−k)=64/65处原finite mask；Decision无RoPE、有全部bias/FC1-ReLU-FC2；final gamma/type正确 | 临界token、−0 ReLU、错bias层、descriptor切换、epochwrap拒绝；逐独立阶段按测量成本门 |
| 6. 30层数据接续与47点 | 一个原B1样本；每段输入必须来自前一段真实RTL输出文件，checker只读取原gold | 28Encoder+2Decision、120大Q8、60LN、60residual、type1、gather544向量；各层输出/后段数据SHA连续 | 禁止用每层gold作为下一层驱动；错误早停、完整数据/工具/源身份归档 |
| 7. 生产一次BEGIN与系统 | 完整同版生产顶层＋CPU尾部；固定请求边界 | 完整无诊断spill的一次BEGIN、真实H2D/D2H及独立尾部/18logits；之后联合物理/板卡性能 | 当前NOT_RUN，不能由分段相加或周期换算签通过 |

**墙钟可执行性：** E016/R003 `actual_complete_chain_metrics.json` 记录单个Encoder0 Attention父链真实2828.967579679971s，已接近3600s单次专用帽。它不包含完整FFN/残差/LN；不能因理论总cycle少就默认完整Encoder能在该帽内跑完，更不能乘周期签30层。当前FFN完整测量尚依R005；未知pilot≤120s，使用同snapshot实际事件估计固定初始化、每块/每head最高费用及余量。若不满足单次及批次余额，停止该长例，不能仅提高timeout。

因此30层功能验证采用明确的**诊断分段真实数据接续**：在已公开且全部债清的服务边界，导出实际RTL hidden及必要scratch/context；给文件记录来源run/source hash、request/gen/source_epoch、layer/stage、shape、字节数、数据SHA、真实终点事件和独立checker结果。下一段通过合法公开装载口写回这些**实际输出**，重新建立合法资格后计算；不恢复任意内部FSM/信用位、不把gold灌作生产输出。只在边界需要时保存真实skip＋projection；不要导出未退休队列。Diagnostic spill不进入生产路径/性能计时，也不冒充生产驻留。

相邻段不得各用原gold作为输入再声称连起来通过；一旦上段输出有差异或错误，失败原样保留，后续不得换gold继续报告正常链。30层完整接续以原47个独立输出checkpoint为主要数值checker；120矩阵要求逐项记录真实接受/完成、shape和原权重身份覆盖。只有必要局部验证/首次差异定位才补相应中间独立参考，不把120个全量矩阵gold设为正常推进前置。原CPU全图报告确有47检查点，同目录matrix_fixture/matrix_dut报告 `case_count=10`，其范围如实保留；120来自原图28×4＋2×4，不能把10个case外推为120个逐矩阵数值通过。

现本地 `m007_full_parent_run.py` 保存的 `xsim.dir` snapshot 是编译/elaboration产物身份；源码中未找到运行态 checkpoint/restore 驱动。只读检索本机Vivado2025.2 `doc`/`data/xsim` 没取得可证明内存、在途事务、checker状态完整保存/恢复的手册与可重现用例。**合法运行态checkpoint/restore能力未知**，本方案不依赖它；工具搜索未找到不等于方法不可用。真实分段通过应报告 `SEGMENTED_RTL_DATA_CHAIN_PASS`，不能报告同runtime完整Encoder或单BEGIN30层PASS。用户明确要求的Wi→G→Down同runtime仍由R005完整例单独满足，分段路线不降低该项。

## 7. 核查来源、版本和可复算记录

本轮未访问论文全文；所需事实来自项目真实源码、原CPU参考、有效合同及冻结原始报告。源码SHA见[架构证据JSON](m007_residual_encoder30_20261023.json)。以下路径均相对本项目根；`E002`简称 `project/E002_Laya_HLS/experiment`。核查日期2026-10-23。

| 引用 | 已实际读取的位置/版本 | 本文使用事实 |
|---|---|---|
| R01 | `goal/goal.md` revision9；`mission/M007_完整Attention高性能主干与部署闭合/contract.md` §§2–8；`tasks/SM012.md`最新「并行残差/LN与30层架构核定」 | 当前CPU/FPGA边界、30层、指标/权限、不改数值和帽 |
| R02 | `E002/tests/full_reference.py`，SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`；`layernorm_rows`314、`layernorm_many`524、`quantize_many`535、`attention_many`636、`full_forward_graph`685，主干761、final gamma/type780、Decision794、gather812 | 原数学顺序、每步F32、60LN、120矩阵、CPU尾部；冻结副本在`source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py` |
| R03 | `E002/vivado/module_design/attention_and_fp_engine/rtl/laya_attention_qkv_bank_v2.sv`：模块端口、`plane_store/channel_bank/words`、read-priority collision；`laya_attention_storage_v1.sv`：native_bankset与ps/g/context实例；`laya_ln_exp_storage_v1.sv`全部 | 实际银行/深度/同步读写、现身份和真实held/idle；Q别名尚非现生产接口 |
| R04 | `E002/vivado/module_design/layernorm_engine/rtl/laya_m007_layernorm32_v1.sv`54–74声明、337之后时序；SHA `2799427bb0fe36ddb45da21357868ff04a415fbda62c7dca11a4912d0266c263`；`laya_m007_ln_scalars_v1.sv`两叶SHA `7fffa46ff225bc6a4739ac9360ce9931ccc143dfd54d1fd9d3cb9873faab84be` | 128个opaque标签、64项metadata、gamma、共享服务/错误排债、所提位宽压缩切口 |
| R05 | `E002/vivado/module_design/q8_linear_and_restore/rtl/laya_m007_matrix_facade_v1.sv`188–189、224–244、278–283；`laya_m007_a_bank_v1.sv`和`laya_m007_a_cache_v1.sv`slots/banks | 当前16KiB系数窗口、唯一A/W实例和两A槽物理声明，非完整bias vault |
| R06 | `E002/vivado/module_design/forward_controller/rtl/laya_m007_single_parent_v1.sv`1064–1210；R003冻结SHA `e35424a62457ca08f1b5e707ad7b8a1556b1f578e8ced9e16adbe076592b4cb8`，绑定`E016.../runs/R003/final_delivery_manifest.json` | 两份descriptor、父身份/epoch、QKV/context/WO现状态；R005正在owner侧实现，不宣称新代码仍同SHA |
| R07 | `project/E014_m007_layernorm32/experiment_results/runs/R001/attempts/AT031_ln_compliant_storage_ledger/work/report.json`完整逐字段账；`ln05_handoff.md`；AT042/043 report；final AT046由handoff绑定 | 44761bit原账、plain/gamma16618/16626、mul pending54、局部首错边界。AT031 engine是a0975679版本；最终仅idle系数准入两处变化，位宽无变化 |
| R08 | `project/E018_m007_control_workspace_joint/experiment_results/runs/R002/final_delivery.json`及摘要；`E002/.../attention_and_fp_engine/rtl/laya_m007_control_workspace_v1.sv`；`E018.../experiment_source/g_control_layout_v1.json` | 12288bit真实唯一arena、11343bit G view、4036.375B当前管理账；当前第三/第四owner未实现 |
| R09 | `project/E015_m007_tanh_geglu8/experiment_results/runs/R001/attempts/AT007_encoder0_real_local_reference/work/report.json`，products=`wo_input_context.bin,wo.bin,attention_residual.bin,norm_ff.bin,wi.bin,geglu.bin` | 原Encoder0局部独立参考，skip原来源是原B1 `embedding_norm.f32.bin`；没有虚构`hidden_skip.bin`文件 |
| R10 | `project/E016_m007_single_resource_parent/experiment_results/runs/R003/actual_complete_chain_metrics.json`，SHA `8bff41ed80cb8015261fed9b613302794ce67bf58cc9a21a652d62069563c687`；`m007_full_parent_run.py` full_gate及snapshot段 | 256947拍、2828.967579679971s与真实检查计数；compiled snapshot不能代作运行态restore |
| R11 | `E002/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/full_forward_oracle_report.json`，SHA `0deb1f1f370ddbbc702c3c62ffc18cdf991d4993340d564d2faa4ade119a42d6`，runs的B1_from_b0/B1_from_b1/B2各47项；同目录matrix_fixture/matrix_dut各10cases | 独立全图参考实际存在；不把10局部矩阵case冒充120矩阵全量gold；本轮只读报告元数据未重新计算全图 |
| R12 | `E002/tests/full_model_package_test.py`109 `expected_bindings`；`full_fixture_test.py`Evidence；`performance_requirements.json`矩阵/量化/diagnostic_F32_buffers/LN/存储字段 | 112 Encoder＋8 Decision矩阵、bias绑定与原模型SHA；H0/H1/norm只是声明预算而非现M007物理实例 |

只读脚本独立记账：AT-A011-1宽度/哈希复算0.05s、峰RSS15792KiB；AT-A011-2逐字段布局/原报告元数据0.06s、峰RSS16536KiB；累计0.11/120s，均exit0、单次≤20s/1GiB、CPU0–3/nice19/idle。无EDA、无新gold、无权重大范围扫描。工具默认sandbox因bwrap失败，所有读取使用同授权只读命令；写入仅本md与同前缀JSON。

建议主控在其唯一维护的`source/method.md`短索引增加链接：**M007 resident residual/LN/30-layer successor：单hidden＋Q生命周期复用，canonical LN元数据压缩＋单arena四owner；静态可实施方案，动态/联合容量/物理待验证；关联SM012/E016/E018。** A011按限定owner未修改共享索引。

## 8. LN-COMPACT-22 接口细化（2026-10-23 接续增量，优先于§2/§5的粗粒度首错描述）

### 8.1 CPU真正的检查顺序与96-bit报告tuple

原CPU只抛出异常名称，未返回stage/row/node tuple。以下tuple是对其**检查语句顺序的确定性诊断细化**；同一 `_finite(array)` 内选row-major最小坏元素，不伪称原Python返回过该下标。外层 `layernorm_many`（R02:524）逐16行tile调用 `layernorm_rows`（R02:314）。同一次LN固定按下表字典序比较，不能用物理到达先后替代。

`rank=(op_ordinal, tile, class, row_in_tile, check, sub, element)`。op_ordinal来自父固定图的9-bit阶段序号；同一次LN相同。tile=`row>>4`（0..7）。class=0 source全tile有限性、1 gamma有限性、2逐row正文；class0中row/element用于坏输入最小坐标，class1中row=0/element为gamma下标。正文row=`row&15`。

| class/check | 原CPU实际语句 | sub/element；现engine来源 |
|---|---|---|
| 0/0 | R02:319 `_finite(x,"LayerNorm source")` | 最小坏row、element0..1023；整个当前16-row tile优先于其全部row算术 |
| 1/0 | R02:320 `_array(gamma,... "LayerNorm gamma")` | gamma0..1023；仅gamma模式；在source检查之后 |
| 2/0 | R02:324 `adjacent_sum(x[row])`，函数66–73逐级`_finite(tree)` | sub=1..10，element=0..(1024>>sub)-1；现stage1，level/node |
| 2/1 | R02:327 `_finite(delta)` | sub=0、element0..1023；现stage3 |
| 2/2 | 同行随后 `_finite(squared)` | sub=0、element0..1023；现stage4；square虽已计算，检查仍后于全delta |
| 2/3 | R02:328 `adjacent_sum(squared)`逐级finite | sub=1..10、该级node；现stage5 |
| 2/4 | R02:329 `variance<0` | sub=element=0；现stage6的**负方差**，不是所有scalar错误通吃 |
| 2/5 | R02:334 `_finite([mean,variance,shifted,root,inverse])` | sub依数组顺序0..4、element=0；现stage2/6非finite/7/8/9分别映射0/1/2/3/4 |
| 2/6 | R02:338 `_finite(y[row])` | sub=0、element0..1023；plain对应现stage10，gamma对应现stage11 |

`adjacent_sum`进函数前的输入finite检查分别被已完成source/square检查支配；不再增一个早于这些语句的“树输入”错误。gamma模式的norm乘法（现stage10）不是原CPU独立检查点；其非finite只能导致同元素final-output检查失败，不能抢在gamma最终检查前另报一个原图stage。非法scalar硬件状态/身份协议故障另用PROTOCOL域，不能硬映射成variance<0。对能证明不可达的状态，先保存证明适用条件，再允许压缩覆盖。

建议96-bit编码：`[95:87]op_ordinal9,[86:84]tile3,[83:82]class2,[81:78]row_in_tile4,[77:74]check4,[73:70]sub4,[69:60]element10,[59:0]=0`；unsigned数值比较等于上面的字典序。父现96bit error_tuple可保存该编码，不新增另一个完整tuple寄存器。pure LN仍输出局部字段，由父组合加入op_ordinal；默认兼容模式保留E014原stage接口值，canonical模式新增明确 `error_class/check`视图或组合转换口，不能静默改变旧stage含义。

### 8.2 finite提前检查的资格和限制

**可直接签正常生产域的路径：** H0成功入口、上一residual/type完整成功后，hidden是全tensor已真实finite检查的生产结果；任何非finite已经属于**上游原图算子**失败，不会启动LN。此时“全部LN源finite”是上游真实成功的逻辑后果，对所有tile为真，提前获得这一真命题不会改变LN内部错误排序。命令必须显式携 `source_finite_qualified`，由父真实producer完成条件产生，不能由TB常量代替生产证明。该证明不覆盖任意外部损坏的resident memory或诊断恶意输入。

**未经该资格的任意输入：** 全输入预扫描可以提前 *计算* 最小坏位置，但不能提前 *发布* LN source错误。保留`source_bad_valid1 + source_bad_row7 + source_bad_element10`共18bit；该候选归属于坏row的tile。较早tile的所有正文检查仍按上述rank完成；同tile source故障在任何该tile算术候选之前。例：row0 square溢出＋row20 Inf，原CPU先在tile0 row0失败；提前发现row20不能覆盖row0。例：row0 square溢出＋row15 Inf，原CPUtile0 source检查先失败，应报告row15 source。一个最小坏坐标足够表示所有未来source候选，因为更早坏tile必先终止。

生产无需新增正常路径整张量扫描。若要接受未资格的resident诊断输入，后继provider必须通过真实同步读扫描产生18bit摘要，并在该扫描完成后才能启动相应tile算术；扫描周期与读债实记，不把额外4096拍从请求时间删除。pure LN的摘要接口unit测试只能证明该合同的候选仲裁，不能代签真实扫描生产者。旧stream任意tag模式仍维持原E014局部错误范围，不能冒充任意非finite全128输入的原CPU检查顺序。

同理，当前gamma loader将非finite系数判模型装载错误并禁止LN；它是请求前的配置资格检查，**不等于**把一个任意坏gamma传给原Python函数的异常优先级。正常生产模型的gamma已finite合格，class1必成功。完整“坏source＋坏gamma”CPU函数异常等价须另加真实延迟发布的gamma坏下标；本段不通过改gold或改配置分类假称已覆盖。

### 8.3 首错需要检查闭合，4ctx mask本身不够

§2.3的11962bit仅是基础压缩＋4ctx失败mask的候选，**不能代表完整首错控制已齐**。同一row也可能较早chunk先返回高树级错误、较晚chunk后返回低树级错误。发现一个错误后不能立即取消整个坏ctx；必须继续原rank更早或同检查范围的真实运算，直至该候选之前的检查全部闭合。

固定闭合实现增加80bit `tree_checked[2][4][10]`。现group0共享ADD按接受顺序FIFO返回，每ctx固定stage的index也单调无空洞；因此在对应stage最后index的**实际返回检查**上置bit：stage0..4末index31，stage5/6/7/8/9末index15/7/3/1/0。每一item的全部实际lane同时检查后才能置bit。此优化须证明“index单调、未漏发、未漏收、无重复、正确ctx”来自生产生成逻辑及真实服务；单独TB断言不足以容忍已出现的非法metadata。发生协议fault后不能再凭这些bit签数值检查闭合。

保留现input_chunk/input_row、raw/delta coverage、read/output计数和真实债，作为source/写入/最终输出闭合依据。数值候选截止rank只阻止**更晚依赖**的新运算；同row较早树级/完整delta检查和所有较早row继续。已经对外valid保持或已接受的请求/返回不得撤回，按原字段真实排空；晚rank结果只标dominated。ctx复用必须在其被要求的检查已完成、数值候选归档、全部实际债清之后，不能仅看输出32块或aborting。整体失败可在较早rank全部闭合后确定，但done仍须全物理债清。

正常输入下所有tree位按原流程置齐，不增加额外pass/降低原row II。该80bit方案是待实施可证伪假设；如果FIFO/生成次序的实际实现不能证明最后index意味着完整检查，必须补足真实coverage状态并重新计算arena，不签原首错。

### 8.4 canonical标签/compact越界的生产协议Check

新增显式参数 `CANONICAL_TAGS=0, EXTERNAL_CONTROL=0`；默认保持旧任意tag及内部状态模式。`EXTERNAL_CONTROL=1`只允许`CANONICAL_TAGS=1`。canonical tag公式沿§2.2；该模式是在父限定接口上的新资格，不撤销旧接口对任意96-bit tag的支持。

未接受请求：错request/gen/epoch、错row/chunk或错canonical tag不得握手；有可保持的`reject_valid/reject_ready/reject_code`确认（复用现错误字段做该模式view，新增valid/ready语义须明确兼容generate）。拒绝本身不修改已有效的当前上下文。父看到本次producer非法输入后经显式`cancel_valid/ready`结束该操作；pure LN必须能接受该cancel，真实排尽已接受工作后出cancelled DONE。不能把ready永久拉低当作完成。若输入身份属于当前操作且当前producer提交了明确非法格式，也可在同一**独立error接受通道**受理错误并进入排债，绝不同时当正常数据消费。

已接受操作内部：compact item编码前检查valid item的ctx合法、stage index高位零、节点范围、固定lane区域；返回前检查实际tag中环槽范围/保留位、仍属本operation及对应pending项。任一异常置sticky `protocol_fault`，保存首个`protocol_code4/location8`；禁止成功及新数值issue，保持此前已提出的有效请求，真实消耗每条FP/DIV/存储返回及write ACK。不能拿损坏item的ctx/index更新某个别的ctx或错误coverage。

故障排空采用服务真实pending及请求/响应credit作为事实，同时冻结已损坏的逐ctx解释；若本地逐ctx计数不能再可信，不能靠它永远阻DONE，也不能把它清零当退债。需要“停止新issue→所有hold请求真实受理→全部外部pending/银行response/标量busy实际清→错误DONE”故障路径；只在真实外部债清后清本地损坏计数/coverage。缺返回导致pending永不清时保持失败待排空并由现watchdog报告停滞，不伪造恢复。PROTOCOL域优先说明数值完整性已失效，不能继续声称原CPU数值首错等价。

新增长期状态按保守 `protocol_fault1 + protocol_code4 + protocol_location8=13bit`计入。不只写`assert`：正常/数值/协议/取消DONE分类和排债是可综合RTL。无法通过公开真实端口触发的内部bit翻转仍标NOT_RUN，不能force位图造PASS；可在纯compact编码/解码公开验证wrapper用合法输入域检验编码规则，但仅属局部协议验证。

### 8.5 外部q/next接口及修订位账

pure LN导出/接收：`control_enable`, `control_clear`, `control_q[12287:0]`, `control_next[12287:0]`；`control_retired`仅在enable且真实work_debt_clear、active0、done0、reject0/cancel_rsp0时有效。请求的op身份及原FP/DIV/LN-bank口不变。`control_clear`仅在调用者已经验证上述真实retired时使用；它清本操作控制view，不能清gamma/payload或强制清在途服务。

EXTERNAL_CONTROL=1时，原63项状态只从q读、集中组合next，**没有各自always_ff影子副本**。`control_enable=0`时所有LN生产valid关闭，next保持q；不得把被其它owner写成的union位解释为LN.active/idle。模型gamma132bit及数值18055bit仍是pure LN private状态，gamma操作限LN owner且真实idle。owner FSM保留实际退场证据后才能离开LN；inactive-retired的推断来自唯一owner状态机历史，不是把真实pending常量0。

基础view11959bit；4ctx mask净+3；tree_checked80；协议13；未资格source摘要18；source资格1，合计 **12074bit**，arena余214bit。若实际新增reject/cancel保持或故障终态控制不能复用现active/done/error等字段，必须逐项占用这214bit并交付最终布局。该布局修订替代“仅11962bit已覆盖完整异常”的潜在误读；正常compact基础仍按原11959bit独立可核。没有共同arena实际例化与验证前，只能报告pure external-state接口通过，不能报告父4KiB合规。

## 9. 可直接派发的 LN-COMPACT-22 限定合同建议

**建议ID：D-M007-SM012-LN-COMPACT-22；E014/R002；执行A008（复用host_tail_engineering，用户指定GPT-6.1-Sol/xhigh）。** 主控实际发送本合同后才开始，记录不等于已启动。A007并行完成E019 hidden/residual，唯一拥有attention_and_fp_engine内真实workspace/owner/sharedFP；A010继续唯一父controller/FFN；你不是唯一作者，不撤销或跨写他人修改。

A008所有权仅 `E002/vivado/module_design/layernorm_engine` 内M007 LN engine、必要标量tag参数实例、TB/runner、source增量及E014/R002原始证据。默认旧接口与冻结R001证据保留；共享FP/DIV/LN bank/真实arena只读。A008实现canonical模式、compact metadata、q/next及可综合协议排债，提供纯接口交付。完整原首错按§8分正常域、有限输入数值异常域、任意坏source/gamma域分别报告；未闭合完整异常不得阻断已授权正常接线，也不得合并称全部首错PASS。

A007后继单独负责四owner真实workspace路由与唯一q寄存器，不让A008在layernorm_engine内偷偷复制第二arena。先可用独立owned TB寄存器验证纯接口，但标`PURE_EXTERNAL_CONTROL_UNIT_PASS`。共同arena阶段必须在一个真实生产composition中重复A→LN→G→VECTOR→A（按合法业务阶段并可先最小正常case），包括held DONE、实际在途FP/DIV/bank响应、gamma跨owner保留、取消和无reset新generation。对应owner/状态真实切换和物理声明齐全后才评联合4KiB；不同runtime独立通过不能代签联合。

**参考/覆盖：** 复用R001 AT001冻结plain encoder00和encoder27＋final_norm_w原gold、AT042/043完整中间checker、AT033四ctx held；默认任意96bit tag回传先最小受影响回归，canonical重建逐位一致；all64-slot credit配置保留。正常plain/gamma全128逐位检查所有树节点/统计/最终值，原16704周期/rowII128/first448及每pass帽不改。补canonical错tag拒绝→真实cancel→恢复、compact范围错误的真实协议出口、首错同row跨tree-level/跨row/跨tile候选反序；只做必要局部独立参考，不生成新完整模型gold。完整外部非finite源/坏gamma生产资格尚未实现的范围单列NOT_RUN。

**独立预算建议：reference60/static600/RTL1200/OOC0秒；旧R001/E019余额不转。** reference每次≤20s/16GiB；static单次≤120s/24GiB；未知RTL pilot≤120s/8GiB。先同build16row真实plain/gamma/4ctx成本pilot。完整128估计 `E=1.35×8×max(适用16row实墙钟)+10s`，必须E≤120s且剩余RTL≥E+120s，才依次各跑一次plain/gamma；若初始化占比高导致此保守门不通过，可有证据拆固定初始化/每row费用后集中重算，不能原样加timeout。每次失败/修复/短回归全部计费，保留120s末段恢复/归档。全项目锁覆盖全部后代；CPU0–3/nice19/idle、MemAvailable>192GiB、40Mcycle和语义停滞120s保持。

原成本只作背景：AT04223.40869s、AT04323.07276s、AT0338.92302s，不能继承为新snapshot实测；共同arena更重时另用自己的同版pilot，不挤入pure LN旧预算。无OOC/P&R/板卡授权。普通实现/脚本/TB修复连续完成，不逐次审批；实质数值/接口/原gold变化回主控。交付先发精确q布局/模式资格/端口与短正常结果，随后预算内完整plain/gamma；全部区分source静态、pure外部状态、真实同arena、异常语义四层证据。

### 本轮接续出口

§8–9已交主控用于A008并行接续。模型descriptor实际reader、coeff vault初始化的完整元数据/credit/有效性及§2.4所余172bit的最终闭合仍 **OPEN**，本轮未实现或签合规，下一架构接续继续。§8的12074bit是扩展设计算式；同前缀JSON仍保留先前11959bit基础view逐字段账，新增检查/握手字段的最终布局由LN22真实源码审计补齐。完整Encoder、生产一次BEGIN和同runtime整模继续为未完成目标，诊断分段不替换最终验收。

## 10. JOINT-ARENA-23 四owner可实施合同（2026-10-23）

**主控接纳ID：D-M007-SM011-JOINT-ARENA-23；E019/R002，关联SM012；执行A007。** 本节是确定的后继接口/验收设计，不是已实现或联合PASS。A007拥有attention_and_fp_engine中的新workspace/production composition、VECTOR v2及联合TB/runner；A008仍唯一拥有LN pure engine/E014，A010仍唯一拥有forward_controller/E016。你不是唯一作者，不撤销他人修改。A010正在运行的v1父接口、旧workspace/joint源与build身份不改；新建v2生产composition，最终v2只例化一份真实FP/DIV/银行、一份Attention/G/LN/VECTOR及一份12288-bit q，禁止把含workspace的joint_v1再包进v2。

### 10.1 唯一q、端口和安全换主

`laya_m007_control_workspace_v2`固定：输入`owner_req_valid, owner_req[1:0]`，输出`owner_req_ready, owner[1:0], rearm`；输入四个`*_retired`、四个`*_private_idle`和`admission_quiet[3:0]`；输入`a_next[12287:0], g_next[11342:0], ln_next[12287:0], vector_next[47:0]`；输出唯一`state_q[12287:0]`及四个enable。owner编码A=0/G=1/LN=2/VECTOR=3。只有`state_q`为arena存储；owner2+rearm1在外，较v1净增1bit。

| owner | 有效view | q更新 |
|---|---:|---|
| A | 12288bit | `a_next` |
| G | 11343bit | `{945'b0,g_next}` |
| LN | 冻结v2 12120bit；168bit reserved | `ln_next`，reserved必须0；不得借reserved存父状态 |
| VECTOR | 48bit | `{12240'b0,vector_next}` |

`enable[i]=rst_n && !rearm && owner==i`。同owner请求只确认，不清q、不触发rearm；异owner ready须同时满足`rst_n && !rearm && current_retired && target_private_idle && admission_quiet[current]`及真实共享资源退休条件。`admission_quiet`只检查当前owner的新操作入口：A prepare、G cmd/bind、LN cmd/gamma_begin、VECTOR start，以及能创建新债的idle配置入口；它不是所有请求valid的总反相。来源有效请求尚在等待时不得换主；父不得同时请求换主和提交新操作。该规则消除“旧状态看似idle却同边沿接受新操作”的竞态，不用清零credit补救。

换主握手边沿：以**边沿前**全部退休条件判定，写`state_q=0, owner=requested, rearm=1`；下一个周期四enable全0；下一边沿保持q=0并清rearm，此后新owner才能接收操作。复位同样清q/owner/rearm，默认A。换主请求本身不屏蔽/撤回已提出的FP、DIV、银行、输出、DONE或取消响应；源仍获完整路由直到真正退休。若需要停止后续工作，先通过其合法cancel/abort并真实排债，再请求换主。不可用预计最后返回、局部state或改写next后的计数代替旧值退休。

### 10.2 inactive资格、真实资源和gamma生命期

`*_private_idle`必须与inactive共享q无关。现A接口满足此条件：其私有layer/head/RoPE/结果读owner（`laya_attention_layer_engine_v1.sv:735–736`）独立于q覆盖图。G同理用私有active/done/discard/slot/write及真实bank已发/已返条件（`vector_and_ffn/rtl/laya_m007_g_engine_v1.sv:69–70`）；其math退休仅在active G view检查。不得把inactive LN `control_retired=0`当target ready，也不得解码他人view猜LN.active。

LN无新增private-idle端口时采用可综合的**生命周期不变量＋真实资源探针**：private gamma/scalar的复位必须不受enable屏蔽；所有LN cmd/gamma/FP/DIV/native-bank入口与响应握手均由owner资格关闭；离开LN的唯一路径必须观察其enabled `control_retired=1`，并观察实际FP/DIV lease释放、pending=0、native-bank idle、外层H/Q读响应为空、输出写提交完成。因此inactive LN期间gamma_loading/result与私有service债不能从0重新产生，target `ln_private_idle`可由这些真实外层服务/银行idle组合生成，无需增加gamma影子或per-owner退休FF。该不变量须在源码/断言和同runtime测试中核验；不能把服务pending常量绑0来凑资格。若实现存在任何旁路gamma入口或独立标量活动，本方案不成立，须A008导出真正q无关private-idle并重新记账后接线。

LN持久gamma132bit及gamma_mem4096B不随q清除；加载只能在LN owner、其真实idle时开始，完整32chunk真实握手及held gamma_done消费后才可离开。跨A/G/VECTOR与新操作保留model/key、loaded/coverage及系数，直到合法gamma_begin重装或真实全局reset。数值18055bit也保留物理声明；其无效内容不必在换主擦零，但valid/busy必须由已退休控制保证失效。正常切换不能用reset重启FP/DIV/银行。cancelled终态与done同一记录，只消费一次。

**布局修订已由主控接受：** 早先LN v1文档标12116，实际新增4个ctx DIV expected标志占`q[12119:12116]`，现按A008 `ln_control_layout_v2.json`固定 **12120bit/168bit reserved**，不丢弃必要状态。主控消息确认A008已把gamma/private reset置于enable之前，并为inactive DIV rsp_ready加enable门；这是源码修复状态，尚非EDA验证。工程先以新布局/版本hash绑定编译，联合复位及inactive接口测试仍必须实际执行。上述修订不增加12288-bit物理arena或额外private控制；旧§8–9及v1文档位数仅保留历史推导。

**交付时主控最新增量73：** normal c612已审核full128 pure external通过，可按v2正常接口集成；此结论来自主控实际消息，A011未另读该完整run。为cancel保持已对外valid而未接受的scalar/DIV请求，主控接受后继v3在reserved追加8bit offer资格/tag，拟12128bit/160bit reserved，前12120偏移不变。v3异常握手修订尚待实施/验证，不阻断A007正常v2集成；联合取消测试必须绑定达到该保持合同的版本，不能将v2 normal PASS扩展成cancel PASS。新8bit仍在同一12288q内，物理arena/§10.5控制投影不增加；A007绑定版本时核对最终v3 JSON，不按本文推测新增字段偏移细节。

### 10.3 VECTOR48外部化与NBA语义

新增独立`laya_m007_resident_vector32_v2 #(EXTERNAL_CONTROL=0)`，保留v1以免改A010/D21依赖。新增`external_control_enable, external_control_q[47:0], external_control_next[47:0], control_private_idle, control_retired`；local模式准确48FF，external模式零control shadow，使用同一组合next函数。字段按E019提案冻结：state[2:0]@0、issued13@3、retired13@16、first_error1@29、protocol_error1@30、error_addr12@31、error_lane5@43；IDLE0/LEASE1/RUN2/RELEASE3/DONE4。

转换时next默认q，每一旧`always_ff`条件、RHS均读旧q/旧握手，按原语句顺序覆盖next。特别是RUN→RELEASE读旧issued/retired/error，不能拿本边沿return后的next.retired提前完成；DONE→IDLE只能在真实held DONE消费后。原H/Q原子成对同步读、ADD group0 phase7/tag、有限性检查与H写提交条件不变。禁用时next=q、所有对外valid/ready关闭；inactive idle/retired不得由他人q解码。`control_private_idle`用实际FP无lease、H/Q无response及无外层held写；active retired额外要求IDLE、held DONE已消费、无同边沿start/lease/read/ADD/写接受。

hidden读响应valid/address13bit和scratch owner_active1bit仍在arena外；无新128-bit身份副本、无provider payload FF。parent request/generation/epoch在整段租用中稳定。scratch lease可以跨VECTOR→LN，但每次换主H/Q response与写提交必须清；epoch变更需旧scratch release后重新acquire。VECTOR返回成功并且实际4096组接受/4096真实有限ADD返回/4096H写提交全闭合，才可由真实父生成该次H `source_finite_qualified`。D21独立TB输入ready并非父的全图资格证据；未完成joint真实producer见证前仍标父资格NOT_RUN。

### 10.4 最小区分实验和停止条件

固定量化/数值叶和原参考身份，优先复用`embedding_norm.f32.bin`、原`wo.bin`、checker `attention_residual.bin/norm_ff.bin`。gold只能进入checker。必须一个v2 production composition、同runtime且无reset完成以下两组，实际物理实例/源码hash/owner切换事件随报告保存：

1. **四owner交接：** A合法prepare并实际写入至少一个QKV chunk，然后公开prepare-cancel与响应消费/真实释放；转G，真实pair输入驱动至少一次ADD/MUL/TANH/银行操作，再合法cancel或完成、实际discard/全部债清；转VECTOR完成一次真实residual；转LN，合法gamma加载及plain LN正常操作，gamma模式短操作验证跨owner后同model/key仍可用；最后回A并接受新generation操作。A/G最小部分不要求再跑完整Attention/FFN，不冒充完整图。至少一次LN→其它owner→LN的gamma实际复用，不能只读loaded位；此独立gamma操作用原E014已存在的gamma输入/输出fixture，不替换下项残差数据链的任何producer。
2. **残差→LN数据链：** 公开加载原skip→H、原WO→Q，VECTOR真实phase7 ADD写H全部4096组，检查131072个residual；同一runtime退休/换LN，真实同步H读送canonical LN、LN phase6真实FP/DIV/native-bank计算、Q写入至少16row×32chunk，逐值检查原norm_ff前16row，禁止把residual/norm gold装入producer。正常source资格由本次VECTOR真实成功产生。全128 LN只在本build16rowpilot成本门通过后执行；未跑则明确`JOINT_RESIDUAL_LN_16_PASS`而非全128/完整Encoder PASS。

保持DONE17周期、末H写17周期、实际FP返回17周期、实际DIV或LN-bank返回17周期分别测试：old owner不提前切换，新owner无生产握手，rearm准确一整周期。检查同owner请求不清q、源新cmd/start与switch同边沿冲突不接收、LN gamma_done未消费阻换主、取消/数值错误后真实排债无reset新generation、inactive每个owner端口为0。错误用实际公开输入/返回控制，不force内部state/credit。默认local VECTOR对原D21正常/NaN/held语义受影响回归与external逐事件等价；因外部化产生时序差异即FAIL，不以改checker消除。可能反例是last-return同边沿假退休、inactive随机q产生valid、gamma跨owner失效、Q64半字冲突、source资格在漏H写时仍置真；各有对应assert/事件计数。

**独立预算建议：reference0/static600/RTL1200/OOC0秒，旧余额不转。** 不生成新gold；已有checker文件足够上述范围。static单次≤120s/24GiB，RTL先≤120s/8GiB pilot，CPU0–3/nice19/idle、MemAvailable>192GiB、项目唯一重工具锁、40Mcycle/语义停滞120s保持。完整128门：同build16row测固定前段/每row费用；可分离时`E=t_fixed+1.35*8*t_LN16+10`，否则`E=1.35*8*t_total16+10`；E≤120s且剩余RTL≥E+120s才运行一次。全部失败/修复/短回归实记，保留120s恢复/归档；不延长timeout。联合门未过只停相应全例，保留已完成有限结论。无整体OOC/P&R/板卡。

### 10.5 物理账与交付边界

E019 D21真实新增62bit=hidden13+scratch1+VECTOR48，投影4044.125B；当前不能先扣48。实现external后仅可将该48扣除，新增owner1、LN private gamma132以及所有真实router/provider/父状态逐项加入。暂只算已知增量：`32291 + 62 - 48 + 1 + 132 = 32438bit = 4054.75B`，余330bit；**它不含尚待实现的LN resident流provider、父新FSM/qualification/refill/model元数据等，也不是联合4KiB通过。** LN数值18055bit/系数32768bit另完整计物理payload账。单arena168bit reserved与总控制预算330bit是两个不同概念，不可相加或重复花用；旧§2.4的172bit粗投影已被本式取代，仍无最终fit结论。

先交接口/布局/实际声明账及最短真实交接，再预算内扩展。最终分别报告VECTOR default兼容、pure外部state、四owner同runtime、残差→LN16/128、异常/恢复、联合control census；全Encoder与单BEGIN30层仍NOT_RUN。主控维护`source/method.md`索引时可链接本节：方法是假设“互斥生命周期可overlay控制”，支持证据为旧A/G真实arena及D21真实residual，四方联合验证与完整父容量仍待工程。

## 11. 完整Encoder0父v2接续合同

本节供A010在当前FFN v1交付后实施；不改变其运行中源码/build，不授权现在重编旧例。新`laya_m007_single_parent_v2`直接例化§10 v2 production composition，保留原两份descriptor及同一A/W/矩阵/quant服务。一次完整命令按真实生产路径完成 `H0→QKV→Attention→WO→H残差→plain LN→Wi→G→Down→H残差→最终H输出→DONE`；Encoder0无前LN，不使用TB或gold作为中间producer。

### 11.1 命令和H入口

v2 `cmd_kind[2:0]`固定0=旧Encoder full Attention、1=旧Encoder sliding Attention、2=旧Decision Attention、3=旧Encoder0 FFN、4=完整Encoder0，5/6/7拒绝。0..3的既有语义/shape不改；4只允许`cmd_layer=0`，全部model/numeric/table/graph/layout/build身份与full-Attention系数资格通过，`cmd_tensor={WO0=32,QKV0=4}`，四通道对齐/span检查沿原Attention值。旧二位helper不能直接截断kind4；显式映射其Attention部分为kind0、FFN部分为kind3。`parent_state`扩为6位；新增状态需显式谓词，不能继承`state>=20`判断所有后续状态都是FFN。新build身份区别v1。

kind4仍复用原`in_valid/ready,data[32][32],request64,generation32,epoch32,row8,group8`输入口，但仅在H_LOAD接收。身份是原BEGIN的source_epoch；严格row-major共4096组，row0..127/group0..31，无上位有效位、重复、跳号或旧身份。每个实际握手用地址`{row[6:0],group[4:0]}`写唯一H；`in_ready`与真实H写可用同步，成功消费必须有同边沿`h_wr_commit`。对每组32个F32实际判finite，首个非finite以合法错误事件终止/记录row/最小lane，不发布H资格；非法身份/序号不当正常输入接受。上游合法producer_fail仍可在H_LOAD报告并排债，不通过永远拉低ready悬挂故障。

4096次真实写提交且全部finite后进入H_READY；资格由FSM完成事实表达，无需另添4096bit coverage或新128bit身份。原`inputs_accepted`可在H_LOAD复用，但后续复用前必须已退出完整装载阶段。H_READY之后外部in不再作为本次内部producer；用真实同步H读送同一个quant/A入口，保持原quant关闭/真实A写ACK/发布协议。H物理内容保持作Attention残差skip，QKV/WO/G都不覆写H；只有两个真实残差阶段各完整写一次。reset只清资格，不把旧H内容视为新输入。

### 11.2 同两份descriptor在Attention与FFN之间补给

初始cmd只持有QKV/WO两份`tensor32+base[4]64+span[4]64`；新增§3.2 descriptor流，端口精确为`desc_valid, desc_ready, desc_request64, desc_generation32, desc_source_epoch32, desc_global_layer5, desc_pair_kind1, desc_slot1, desc_tensor32, desc_base[4][63:0], desc_span[4][63:0]`，加组合`desc_reject_valid/code4`。完整Encoder0补给固定pair_kind=1、global_layer=0，先slot0 Wi/tensor60，再slot1 Down/tensor88；只原地覆盖当前两槽，禁止保留QKV/WO副本。独立kind0..3不接受该流。

允许覆盖窗口为WO矩阵真实DONE已消费、W loader/cache outstanding实际清、全部矩阵FP/PS lease释放、旧A结果消费者退休、layer/context/QKV实际释放之后。父进入REFILL0/REFILL1即可表示两份接受进度，无额外valid bitmap；等待补给期间不启动FFN、不改H/Q的有效数据。身份/槽顺序错误不接受，组合reject；当前身份但tensor/span非法的记录可走独立受理错误分支，保存父配置失败并终止，绝不写为有效descriptor。每槽重复原4KiB对齐、65bit端点无溢出及最小span检查：Wi K1024/N5248、每通道span≥1511424B；Down K2624/N1024、每通道span≥755712B。保留实际W供数全descriptor预检，不能只检查tensor数值。

建议WO退出后先两槽refill，再residualA/LN/FFN，保证后续入口有确定元数据。refill等待计入本次elapsed_cycles；外部流是完整Encoder0 bring-up服务，不是30层设备自动catalog已实现。完整model catalog reader、模型初始化valid/credit与全部bias/type系数元数据控制账仍OPEN，后续有界独立合同接入，不增四份descriptor逃避这一问题。

### 11.3 物理数据路由与固定epoch表

以下表**替代§3.2尚未冻结的细分op_code枚举**。source_epoch继续唯一保存在父原寄存器，对外DONE回显它；实际下游epoch组合为`source_epoch + 16*global_layer + code`，Encoder0 global_layer=0。BEGIN要求source_epoch≤0xfffffe00，预留512命名空间。依赖同一A身份的quant/matrix及既有FFN复合束保持一个epoch；不为表面逐算子编号在活跃A/FP束中改身份。

| code | Encoder0真实阶段 | FP/DIV与存储条件 |
|---:|---|---|
| 0 | H0外部装载 | 无计算lease，H访问用source_epoch |
| 1 | H→quant/A→QKV→Attention→context→quant/A→WO | 沿v1已验证复合岛；各实际lease/phase退休后轮转，WO phase1输出改写Q scratch |
| 2 | Attention residual：H+Q→H | VECTOR owner，shared ADD phase7/head0；4096读/返回/H提交，真实release |
| 3 | post-Attention plain LN：H→LN→Q | LN owner，phase6 FP/DIV＋唯一LN native bank；完整4096输出写Q及真实退休 |
| 4 | Q→quant/A→Wi→G→quant/A→Down | 沿kind3复合束的同epoch规则；norm A0完整4096组发布，G量化A1完整10496组，Down phase1输出写Q |
| 5 | FFN residual：H+Q→H | VECTOR phase7，全部4096实际有限写完成并释放 |
| 6 | 最终H公开输出 | 同步H读4096组；无新FP/DIV lease |

各阶段产生的request/generation相同，epoch由上表实际接入cmd、tag、bank access、lease/release、ACK校验；不能只在trace打印新epoch而模块仍收source_epoch。复合岛中的layer/matrix/quant等既有完整身份同code，不改变当前v1本身的行为。新epoch仅在旧岛全部实际债/held终态消费后启用；持久model/gamma身份不随operation epoch变化。

Qscratch在WO启动**前**，用当时已退休的QKV matrix/layer/context/quant状态取得code1租约；不是要求活动WO同时声明matrix_retired。取得后仅其合法projection写口可用。WO输出`m_out_ready=q_wr_ready`、`q_wr_valid=m_out_valid`并由真实身份/row/col检查限定；地址`{m_out_row,m_out_col[9:5]}`，col必须32对齐且<1024。按所有实际4096组写提交和matrix DONE判完整，不能仅用最后col。

每次epoch变更先真实release scratch，再以新epoch reacquire；该公开lease动作不清payload，故WO结果可供code2、残差后norm仍可用。这样不用把owner_epoch在active scratch租约中偷偷改值。LN code3输入来自H实际同步响应，canonical tag由响应地址和本次身份组合；它的stream out以实际Q写commit消费。全部LN输出、内部native-bank/FP/DIV响应、held DONE及lease清后，才可进入code4 Q→quant；这会严格隔开phase6与quant phase7。code4完整norm读/量化ACK/发布后可保持同scratch身份供后来的Down写入，但必须等全部norm Q读债清，且没有任何正常QKV/RoPE消费者。Down完成后code5 release/reacquire同理。

code4内的Wi/G/Down沿A010同runtime生产路径：Wi N5248真实输出供G paired输入，G输出335872个F32经原pack/quant得到10496组A1 ACK，Down只读该真实A1。现kind3直接out流在完整kind4被Qscratch接走；kind4对外out在最终code6之前均关闭。H一直保存code2后的skip，直至code5改写。LN输入finite资格只在本次code2真实成功后产生，不能使用命令常量；LN失败的部分Q永不发布给quant。

### 11.4 最终DONE、错误和最小验证

code5成功要求全部131072最终值有限、4096个H实际提交、VECTOR DONE消费、FP真实release、所有读响应清及scratch release。随后code6通过原out接口输出最终H：`out_row=addr[11:5]`、`out_col={addr[4:0],5'b0}`，同步响应held直到out_ready。4096个真实out握手、H bank_idle以及所有matrix/quant/A-fill/W/G/LN/VECTOR/FP/DIV/storage终态与租约全部退休后，父才生成成功DONE。DONE可任意背压，期间request/generation/source_epoch/status/error稳定；消费DONE后才允许新generation。计算完成、最后H提交、最后out及父DONE四个时刻分别记，不能用一个理论cycle代替。

错误保留第一次原图合法诊断并阻止后继阶段：H输入/descriptor失败不启动计算；数值/协议失败停止新issue，已提出请求保持；真实matrix/quant fill取消、G取消/discard、LN cancel/DONE、VECTOR真实排债分别按已启动资源完成。失败时final out关闭，Q/H部分数据无后继资格；不以reset或强制清pending恢复。错误DONE后可用公开新cmd重新完整加载H并无reset恢复。其它epoch输入、上次未消费响应或错误descriptor不得污染新请求。

先验证kind4命令接受/拒绝、H末写与finite资格、两槽refill旧请求未清时拒绝、错epoch、WO/Down真实Q提交背压、LN phase6→quant phase7屏障和最终out/DONE held；旧0..3受影响范围最小回归。完整正常例使用原Encoder0输入及原最终`encoder_00_out` checker，中间原residual/norm/Wi/G等只按必要定位读取，不生产新全图gold。要求四个真实矩阵tensor4/32/60/88接受与完成、所有完整shape、每段实际来源SHA，不能用四个局部独立PASS拼成同runtime完整Encoder。

本节不为运行中A010增加工具预算。后继EDA由主控独立派发并沿现单次帽；先同build短pilot测初始化、每Attention head/FFN block、residual/LN/输出费用，明确总估计与余额。原Attention实测2828.96758s已占大部分3600s；未证明余下路径可在3600s内完成则完整同runtime标COST_STOP，不直接启动超帽长例。可继续§6真实数据分段诊断，标签仍是SEGMENTED_RTL_DATA_CHAIN，不降低一次完整Encoder最终目标，也不把XSim编译snapshot当运行态恢复。

### 11.5 可实现控制账建议与开放项

在§10.5已知32438bit基础上，新kind2→3净+1、父state5→6净+1。建议共用两个13bit resident计数器`resident_issue/resident_sink`：H_LOAD只用sink记实际提交；H/Q feeder只用issue记读接受，并用已有单响应bank idle收尾；LN运行同时issue记H读、sink记Q写；WO/Down/residual/最终输出顺序阶段可复用相应计数，不能在尚有旧债时清复用。H/Q现held响应已带地址，不再复制1024bit数据或额外identity；额外payload若实际需要仍逐项记账。finite资格、refill进度与阶段epoch均由合法FSM路径/现身份组合，不再添影子状态。

若这两个计数器完全新建，则建议账为`32438+1+1+26=32466bit=4058.25B`，剩 **302bit**；如原父已有可安全复用字段，须用实际寄存器声明/独立生命周期证明扣减。该数仍是**设计投影**，不含尚未实现/盘点的router held控制、异常新增状态、模型catalog/初始化与全模型系数有效性。A010当前FFN真实新增pack/控制须先确认已包含在32291基线内；若未包含，必须全量补入，不能把旧Attention账代作当前FFN账。最终只有同版组合顶层逐实例状态census才能签4KiB，无未关闭项前不给实际fit结论。本轮不继续扩大catalog探索，相关元数据/系数预算OPEN并交主控接续。

§10–11增量核查：实际读取A008 `ln_control_layout_v2.json`全部字段，连续覆盖0..12119、无重叠/空洞；实际读取更新后compact_v2.sv:786的`if(!rst_n||enabled)`。13份有界源码/交付哈希与精确位置存同名JSON的`successor_v2_contract.source_versions/citations`；未把主控转述的LN短例PASS自行外推联合结果。AT-A011-3仅哈希/JSON/整数复算，0.05s、峰RSS16532KiB、exit0；累计0.16/120s，仍无EDA、新gold或模型计算。主控已实际消息接纳§10为E019/R002合同；§11是后继父实现契约，完整Encoder0验证尚未运行。


主控2026-10-23增量74基数更正：增量70已实际核当前62cf父4038.875B=32311bit，较旧A/G32291bit确增20bit。因此§10/11旧投影统一应为32311+62−48+1+132=32458bit=4057.25B（余310bit）；再加父kind/state2bit和resident26bit为32486bit=4060.75B（余282bit）。这是以当前FFN为基数的已知增量投影，仍未含未盘点provider/router/catalog/系数初始化，不签最终fit。128B FFN数值holding另计payload。前文旧基数/投影留作推导历史，不再作为实施余额。

### 11.6 ENCODER0-PARENT-24 身份与错误ABI补充（A011集中接口裁定）

适用主控已派发的SM012/E016 R006，仅修改v2；原v1及kind0..3身份/错误码保持。以下是可编码接口合同，未运行EDA。来源核查为当前`laya_m007_single_parent_v1.sv`的BUILD_ID:8、identity_ok:1213、status map:1201–1206、错误分支:1244–1310，以及compact LN的error_order_code/字段转换:253–273、protocol检测:325–333、done_kind设置:788–795；A008未测v3准备版本不改变本处public字段语义。

**build选择。** 保留现`BUILD_ID=128'h7209eb09c3f265363cfb274f7790a733`用于kind0..3，新增`localparam logic[127:0] ENCODER0_BUILD_ID=128'hd92a1f8e927c3051289016db36f20d27`用于kind4；不得全局替换BUILD_ID。组合条件精确为`build_ok=(cmd_kind<=3 && cmd_build_id==BUILD_ID) || (cmd_kind==4 && cmd_build_id==ENCODER0_BUILD_ID)`，其它model/numeric/table/graph/layout校验沿原字段独立成立。kind4传旧tag或旧kind传新tag均按原身份失败`done_status=4,error_domain=1,source_status=0`；kind5..7仍不合法。原BUILD_ID参数保留接口/默认值，不为kind4强制改它。

新tag可复算来源：以下**ASCII字节、不含引号、不含尾换行/BOM**：

`Laya-HLS|M007|D-M007-SM012-ENCODER0-PARENT-24|laya_m007_single_parent_v2|cmd_kind=4|abi=1`

SHA256=`d92a1f8e927c3051289016db36f20d276bce40b977b7143df86be8c934cd8772`，取digest首16byte，按显示hex的大端顺序作为128-bit常量。它区分本固定完整Encoder0接口契约；每次实际RTL源码/工具build的完整SHA仍另存manifest，不能以该常量代替实际编译证据。普通修复不改变此ABI常量，实质契约变化另行升级abi版本并重新算tag。

**domain与tuple。** `error_domain[2:0]`不扩宽：0成功/1配置/2producer/3quant/4matrix/5layer/6G/7glue。kind0..3及kind4中沿用的quant/matrix/layer/G原错误字段与映射完全照原分支，特别是旧domain7/stage8'd3的pack故障不改。只对kind4新增H/LN/VECTOR来源使用下表高stage；stage是父错误来源编号，既非CPU Check编号，也非epoch code。

| `error_tuple[95:88]` | 固定来源 |
|---:|---|
| `8'h80` | H_LOAD接受的非finite输入，或该装载过程真实写提交协议故障 |
| `8'h81` | Attention residual VECTOR终态 |
| `8'h82` | post-Attention LN终态/其已受理错误 |
| `8'h83` | FFN residual VECTOR终态 |

新来源的96bit envelope固定为`{stage8,tile3,error_class2,row_in_tile4,error_check4,sub4,element10,protocol_code4,protocol_location8,49'b0}`；即`[95:88]stage,[87:85]tile,[84:83]class,[82:79]row_in_tile,[78:75]check,[74:71]sub,[70:61]element,[60:57]protocol_code,[56:49]protocol_location,[48:0]=0`。完整row从`{tile,row_in_tile}`无损重建；原先没有的细分字段填0，不根据猜测虚构原因码。该envelope可直接组合拼接并锁存父既有96-bit error_tuple，不新增保存副本。

LN numeric (`done_kind==1`)：`tile=error_row[6:4]`、`row_in_tile=error_row[3:0]`、class=`error_class`、check=`error_check`、sub=`error_level`、element=`error_node`，protocol字段0。其真实CPU含义逐项沿§8.1：class0/check0=源finite；class1/check0=gamma finite（现正常model资格域并不声称坏gamma原图优先级已验证）；class2/check0=第一树、1=delta、2=square、3=第二树、4=负variance、5=stats finite、6=最终输出finite。树sub是原level1..10；stats sub0..4=mean/variance/shift/root/inverse；其它sub0。父直接采用pure LN提供的class/check字段，**不能用legacy error_stage替代check、不能把FP返回先后当排序**。同LN操作按`(tile,class,row_in_tile,check,sub,element)`比较，与§8原CPU排序一致；example row20/class2/check3/sub2/element7编码`96'h82321900e000000000000000`。

§8的`op_ordinal9`形式保留为抽象全图诊断rank建议；本kind4 wire ABI以本节envelope为准，唯一LN由stage82标识，不再把那份96bit rank原样透传或增加一个rank寄存器。CPU顺序按§8语义组合映射，父的不同真实阶段用图依赖顺序确定首因；不把不同domain布局的96bit值直接做全局数值比较。§11.3 LN事务epoch是`source_epoch+3`，其中3与stage82、CPU class/check/row均无数值联系。

H finite：stage80，row取本次实际接受的in_row，element=`{in_group[4:0],first_nonfinite_lane[4:0]}`，tile/row_in_tile按上述拆分；class/check/sub/protocol字段全0，**这些0是无字段的填充，不能解释为LN Source Check**。两处VECTOR numeric：stage81/83，row/element精确取`done_error_row/done_error_column`，class/check/sub/protocol均0；仅表达该生产算子的真实有限性失败，不创造新的原CPU Check编号。

protocol统一置class=3作为**父ABI的非数值判别值**，check/sub/tile/row/element=0；class3不属于原CPU LN检查集合。LN `done_kind==2`的protocol_code/location原样复制。VECTOR只有原status8/布尔protocol_error，没有细分原因/位置输出，因此两protocol字段为0，不能拿错误候选row/lane或自造code冒充协议故障位置。H真实commit协议故障亦用code/location0。正常输入的组合`input_reject_valid/code`仍是未接受输入的反馈，不自动伪装成一个已经完成的数值错误。

**父status与原始source_status。** 不在source_status塞stage，不扩位或截掉原可用终态。精确映射如下：

| 新来源真实事件 | parent done_status | source_status[7:0] | tuple |
|---|---:|---:|---|
| H accepted nonfinite | 1（原numeric） | 6（沿G/VECTOR既有numeric状态） | stage80真实row/element |
| H真实commit协议故障 | 2（原protocol） | 8（既有protocol） | stage80/class3 |
| VECTOR done_status32=6 | 1 | 6 | stage81/83真实row/column |
| VECTOR done_status32=8 | 2 | 8 | stage81/83/class3，无虚构子码 |
| LN done_kind2=1，done_error=1 | 1 | `8'd1`（完整零扩原done_kind） | stage82原CPU字段 |
| LN done_kind2=2 | 2 | `8'd2`（完整零扩原done_kind） | stage82/class3，原protocol code/location |
| LN done_kind2=3且父已有主因 | 保留父原值 | 保留父原值 | 仅消费取消终态/排债，不覆盖主因 |
| LN done_kind2=3且父无主因 | 2 | `8'd3`（完整零扩原cancelled） | stage82/class3，其余0 |

LN没有VECTOR式32-bit status口，故不能假称其原始source_status是6/8；通过stage82与保留的原done_kind可无损解释。若父因已握手的LN held reject主动cancel，先记`done_status=2,source_status=8,domain7,stage82,class3,protocol_code=reject_code,protocol_location=0`：8是父入口协议分类，真实reject_code完整另存tuple，随后cancelled不覆盖它。此处不是新增CPU Check码。其它先发生的producer/matrix/quant等已锁定根因沿原domain/status保存。

只在真实DONE/错误受理时锁定对外结果，不把LN live numeric候选或VECTOR first_error提前当父终态；其后真实协议故障可能令同一模块最终done_kind/status升级为protocol，该最终源分类必须如实接收，不能仍声称CPU数值首错有效。已经锁定的独立上游主因不被清理取消覆盖。成功叶终态只允许继续路径，不能清掉父已有错误；最终成功DONE才是domain0/status0/source0。

本次只增组合选择/打包，无新增状态位；继续采用主控已纠正的32311bit FFN基数及4057.25B/4060.75B投影，联合fit仍OPEN。新增只读hash/编码复算AT-A011-4为0.03s、RSS13400KiB、exit0，累计0.19/120s；无EDA/newgold/大范围扫描。上述常量/映射已通过实际消息交A010与主控，主控确认后作为合同补充执行。

## 12. MODEL-CATALOG-25-STATIC：设备catalog与完整图的最小后继

本节为主控派发D-M007-MODEL-CATALOG-25-STATIC的静态交付。当前状态按主控audit77：E016/R005 AT027同runtime完整FFN已核验，但没有公开二进制导出；A007在编译E019/R002联合composition；A010 parent_v2已写未编译。以下不重签这些工程结果，也不修改其源码。先实施**独立单条catalog reader＋元数据打包/检查**，由A010随后接父两槽；其余正常全图接点固定如下，异常范围有缺口时明确保留。

### 12.1 当前真实接点与基数

已读取当前`laya_m007_single_parent_v2.sv`：两槽descriptor仍是原tensor/base/span，desc只接受Encoder0 FFN 60/88；state6bit已占0..59；resident_issue/sink各13bit；layer_index5bit；pack_seq16bit；gamma输入全tie0（1540–1546）。当前`laya_m007_resident_joint_v2.sv:1442–1443`只把真实VECTOR成功接到LN source_witness，公开H写会失效该资格；`laya_m007_resident_ln32_v1.sv`在LN DONE消费时清witness。矩阵facade188–208仍为64×64F32系数窗口，按当前request/gen/epoch临时绑定，尚无全bias vault。

**当前实际已知管理基数用32519bit=4064.875B**：FFN32311＋联合净增含provider33后32491＋父kind/state各1及两个13bit计数器28。provider33已经存在，本节不再扣它。余249bit是未完成census前的算术差，不是可保证的最终余量。

### 12.2 首出口：新增模型元数据区与单条catalog reader

新增只读模型元数据BO，**不是原权重tensor的一部分**。模型配置提供`catalog_base64`，要求4KiB对齐，分配span固定8192B；`base+8192`用65bit检验不溢出，必须在平台真实port0 HBM aperture内。有效区7936B=256B header＋120×64B records，尾256B为0。主控应在模型存储合同中明确这8KiB元数据用途；不能悄悄占入口/尾部BO。各权重port的base/span仍检查其真实HBM aperture，port0权重范围不能与catalog BO重叠；后续实际H0/tail DMA地址也不得覆盖已封存模型区。平台aperture由真实平台常量/既有BO分配合同确定，本节不虚构物理地址。

header均little-endian，精确布局：0..7=`LAYAC25\0`；8:u16 version1；10:u16 header_bytes256；12:u16 record_count120；14:u16 record_bytes64；16/48/80/112/144各32B分别完整model/graph/numeric/layout/model-package-build SHA256；176..207为**records全部7680字节**SHA256；208..215为records CRC64；216..223:u64有效区字节数7936；224..255全0。完整SHA来自已冻结原模型打包/Host identity，不从现128-bit leaf tag臆造高位。运行编译manifest的源码SHA另外保存。

记录索引固定`index=4*global_layer+2*pair_kind+slot`，global_layer0..27为Encoder、28/29为Decision0/1；pair0=QKV/WO、pair1=Wi/Down或FC1/FC2；slot0/1。每条512bit中`[128*p+:64]=base[p]`，`[128*p+64+:64]=span[p]`，p0..3。tensor/K/N/bias flag由固定图函数组合生成，record中不再存可互相矛盾的shape/tag副本。全部120条结构检查使用实际matrix公式`needed=576*(K>>5)*(N==5248?82:N>>6)`，验证4KiB对齐、span≥needed、65bit端点、aperture及catalog不重叠。

| global/family | tensor固定映射 | K/N | 每port最小span |
|---|---|---|---:|
| Encoder l QKV/WO | 4+l / 32+l | 1024/3072；1024/1024 | 884736；294912B |
| Encoder l Wi/Down | 60+l / 88+l | 1024/5248；2624/1024 | 1511424；755712B |
| Decision d QKV/WO | 117+2d / 121+2d | 同QKV/WO，有各自bias | 同上 |
| Decision d FC1/FC2 | 125+2d / 129+2d | 1024/4096；4096/1024，有各自bias | 两者1179648B |

前两族及Decision QKV/WO映射已有父源码；FC1/FC2是本后继固定扩展，打包器必须逐项核对原`expected_bindings()`的WeightKey、名称、shape、原GGUF字节身份后输出，不能仅以inventory数组下标当身份。原inventory中final_norm_w是F32[1024]、type_emb是Q8_0[1024,3]，八组Decision bias为F32；本轮只读这些元数据，没有读权重payload或生成参考。

**可独立派A008的reader接口：** 新`model_catalog/rtl/laya_m007_catalog_reader_v1.sv`，`req_valid/ready, req_word[6:0], catalog_base64`；`rsp_valid/ready,data512,fault,rid3,rresp2,rlast`；`idle`；单个标准AR/R接口，ARADDR=`catalog_base+64*req_word`、ARID=7、ARLEN=0。req_word0..3取header，4..123取record。只有2-bit FSM：IDLE0/AR1/RSP2/DRAIN3；无512-bit holding、无请求身份副本、无第二个8在途reader。base和req_word由唯一父保持到idle重新成立；该保持义务由真实父状态/计数器实现，不是外部常量假设。ARVALID一旦提出即保持地址至接受；RSP把真实RVALID/data直接反压给父，父闲两槽在同一实际握手边沿更新。

错RID/RRESP/缺RLAST产生fault，父在真实受理边沿锁定错误且不写有效descriptor；若RLAST=0，reader进入DRAIN，实际消耗至RLAST才回IDLE，不提前给其它客户端。cancel/上游失败不能撤掉已提出AR；仍把已接受事务真实读完，父丢弃其data。无响应/无RLAST走已有语义停滞保护，不能伪造idle恢复。

**A010集成仲裁：** catalog只在旧matrix DONE消费、core/quant/A-fill/W slot均真实退休后借port0；其它三个W AR保持0。W服务增加只读`transport_idle`输出，组合自真实每port pending/response queue/held AR及已接受R债、load_pending、wl_rsp_valid和slot lease；不能仅用m_cmd_ready代替。切到catalog前该输出与父退休均真；catalog AR/R期间W入口关闭，原W8在途硬件保留原实例；只有reader IDLE且旧R真实清后归还。A008纯reader TB不能签这个生产mux已验证。

首次BEGIN前和每次换pair，父进入明确CAT_ATTN_SLOT0/1或CAT_FFN_SLOT0/1等待状态，直接覆写原两槽；层/阶段保持直至两条真实接受。初始cmd不再要求Host塞四份descriptor；生产whole-model入口仅由catalog供给。旧kind0..4/v2构建保持原接口，不能未经回归把新记录读口塞入正在运行的v2。runtime每次仍重验结构；record/tensor接受事件记入120项覆盖，gold不是descriptor来源。

### 12.3 模型初始化资格与系数bank

新增固定模型setup事务：输入五个完整SHA256身份、catalog_base/span、expected_records_SHA256、expected_CRC64以及setup request/generation；全部在父/所有服务真实idle且无tail未完成时接受。匹配原模型/图/数值/布局/模型包常量；不支持活动推理中替换。父原request/generation寄存器在setup期间复用；expected_records_SHA256存原`base[0][0..3]`，expected_CRC64存原`span[0][0]`，仅setup时占用；原`tensor_id[1:0]`64bit复用为CRC累加器。此时没有有效推理descriptor，结束后两槽必须从catalog重新读取，不能保留旧资格。

一次setup顺序固定：清model_committed→读header4拍→扫描120record→装bias576个32F32→取得LN owner并gamma_begin/32个gamma chunk/消费gamma_done→装type96个32F32→检查RoPE full+sliding两族真实完整且model/numeric/table身份一致→SETUP_DONE保持→消费后才model_committed=1。counter复用父resident_issue13/sink13，严格顺序输入，拒绝重复/跳号；不新增120/576/96项coverage bitmap。所有系数chunk做实际finite检查，gamma另沿原loader合法规则。model_committed是1bit真实持久资格，所有系数入口在其为1或推理active时关闭；重装先在全债清时显式invalidate，旧RAM内容可保留但无资格。

全表身份分层记录：Host打包器核原GGUF/WeightKey及全部records SHA256；设备比较header完整身份、header SHA字段与本次setup已锁expected SHA，并对**真实收到的全部120record字节**计算CRC-64/ECMA-182（poly42F0E1EBA9EA3693，init0，non-reflected，xorout0；按内存地址递增byte，每byte最高bit先）与expected/header CRC比较。CRC寄存器复用上述tensor64，不增新64bit；CRC是传输完整性检查，不声称设备计算了SHA256或提供密码学认证。若验收要求设备独立重算完整SHA，需另派SHA实现/状态/成本，不得把当前方案冒充该项。model_committed期间Host不得写catalog/权重/系数BO；更新必须先invalidate再全量检查。单纯header相同不够给全表PASS。

model系数流固定`model_word_valid/ready, setup_request64,generation32, kind2, index10, data32xF32`；kind0=bias、1=gamma、2=type，3拒绝，index必须等当前phase计数。bias在同一原coeff bank扩大为288×64F32=73728B（净增57344B），不另外保留16KiB窗口；32lane写地址用index[9:1]、half=index[0]。每Decision的bias32chunk偏移为QKV0、WO96、FC1128、FC2256；Decision1再加288。对应64F32行base如下：

| tensor | bias row base | 长度F32 |
|---:|---:|---:|
| 117 / 121 / 125 / 129 | 0 / 48 / 64 / 128 | 3072 / 1024 / 4096 / 1024 |
| 119 / 123 / 127 / 131 | 144 / 192 / 208 / 272 | 3072 / 1024 / 4096 / 1024 |

canonical模型模式的matrix bias资格为真实model_committed＋当前cmd_model/固定tensor/K/N/bias绑定；request/gen/epoch仍约束实际matrix事务，但不为每次请求重装immutable bias。新增同步bias读holding：`bias_rsp_valid1`＋64F32数据256B；地址由已保持的matrix tensor与issue_next组合，issue_next仅在core cmd接受后推进，无额外地址/身份FF。rsp未消费或真实丢弃前不能启动新matrix或宣称retired。默认旧coef_cfg路径/旧v2 build保留；新canonical模式是否综合删除旧398bit左右临时coef控制必须由真实逐字段census确认，本节**不预扣任何旧coef状态**。

gamma仍唯一4KiB gamma_mem/现132bit私有控制，加载原final_norm_w，固定`gamma_model=MODEL_ID[63:0]`、`gamma_key=32'h464e4f52`（FNOR，仅本新模型契约的key，不假称GGUF tensor编号）；全32chunk成功及held gamma_done消费后才能model commit。A010需解除当前parent_v2全部gamma tie0并在模型setup状态接真实wrapper端口；A007只接owner路由，A008只负责pure gamma接口保持。部分gamma装载无公开abort是现接口限制：不能假清gamma_loading。正常全量加载、非finite被loader终止的失败可先验证；中途上游无后续数据的abort/恢复需另加A008合法gamma-cancel或保持待排空，当前不签无条件恢复。

type新增一份96×32F32=12288B只读bank；装载前由模型打包流程按原`full_reference.py:87–102 embedding_row`执行一次Q8_0→F32展开，保留三条原Q8行及展开文件SHA。它是模型setup，不是每次请求CPU主干运算；本轮没有执行展开。同步读增加rsp_valid1+原请求vector_addr12=13bit控制及1024bit holding128B；memory addr=`{qtype[1:0],chunk[4:0]}`，只允许qtype0..2。原始请求vector_addr用于与Q响应真实地址join，不能只有同chunk便误配不同row。

### 12.4 Encoder后继、final gamma/type和Decision接线

固定生产调度保留layer_index5bit表示global0..29，局部Attention参数组合：Encoder `prepare_kind=(l%3==0?0:1),prepare_layer=l`；Decision `prepare_kind=2,prepare_layer=l-28`，不走RoPE。Encoder1及其后先H→plain LN→Q，Q→同quant/A→QKV；H原skip保持。其余沿完整Encoder0后段，前LN不复制hidden。Encoder27在真实FFN residual退休后进入final gamma；final gamma H→唯一LN→Q，仍保持H直至type ADD回写。

**finite资格接口补齐：** wrapper新增内部生产输入`h_load_success_valid`，唯一驱动来自父H_LOAD4096实际commit、每组finite通过及真实bank idle的完成事件；其request/generation/source_epoch必须为本次已接受请求且在产生事件前保持。它与原vsource OR后设置现有source_witness，不加第二资格FF。每次新BEGIN、public H写、VECTOR新操作开始均使旧资格失效，H_LOAD仅最后成功事件重新发布；不得把qualified作为Host可写常量。连续上一FFN residual→下一preLN直接沿真实vsource；LN DONE会清witness，后继residual/type实际完成才重新产生。gamma只读H后type改写H，因此类型ADD完成是Decision0前LN的资格来源。非法诊断损坏H不享用上游正常域证明。

type使用同VECTOR48新增start_op1：Q+type→H，shared ADD group0/phase7/head0；start_op0原H+Q residual不变。state3bit利用尚空编码5=TYPE_LEASE、6=TYPE_RUN、7=TYPE_RELEASE，DONE仍4；不增加op FF，也不把type状态硬塞到LN view。Q/type两真实同步响应原子join、完整vector_addr一致、返回tag和4096有限H提交按原VECTOR规则；真实type响应加入private_idle/retired屏障。原H读仅op0使用，不能在type时额外读/复制final_norm。此为新实现假设，旧VECTOR48位宽不变不等于数值/握手已验证。

Decision FC1→ReLU→quant使用原matrix N4096/K1024输出，通过**组合**`positive=(sign==0 && magnitude!=0)`的finite F32判定，输出positive?原bits:+0；先保留matrix原finite失败，不能让ReLU把NaN改0掩盖错误。−0明确变+0。`q_in_row=m_out_row,q_in_group=m_out_col>>5`，现quant_group32允许合法坐标而非强制row-major；m_out与q_in为同一个真实握手，背压由quant返回，不新增整FC1/G tensor。FC1读A0、quant填A1，两槽仍唯一；不启G/TANH或G银行。现pack_seq16在Decision路径复用为FC1实际输出组计数（16384），旧G pack在该模式inactive；13bit resident_sink不能计16384，禁止截断。完整16384组真实A写ACK/producer_close、FC1 DONE、quant/DIV/所有旧输出退休后才FC2 K4096/N1024；FC2 phase1输出写Q，再真实residual写H。bias在每个矩阵有序恢复后按原位置相加，不挪到ReLU或量化之后。

量化与矩阵的复合岛仍同epoch，合法并发时不能用单全局owner关掉另一A槽fill；矩阵FP phase1与quant DIV phase7沿既有真实独立service租约。G分支用原Wi/G/Down；Decision分支绕过G但producer_close、部分fill取消、错误主因保持均用同套协议。数值错误不得发布不完整A1，cleanup先停止新issue、保持已提出valid、实际完成/取消旧矩阵与quant后释放；不能仅计输入16384就开始FC2。

**全图epoch最终固定表，替代旧§3.2 final480/481/482粗方案：** Encoder l用base=16*l；phase0=preLN（Encoder0无preLN，入口装载不取得运算lease）、1=Attention复合岛、2=residualA、3=postLN、4=FFN复合岛、5=residualF、6=独立诊断导出。final gamma offset448、type449；Decision d用base=464+16*d并沿phase0..5；最终gather496。op_epoch=source_epoch+offset，source_epoch≤fffffe00，最大496无wrap。这样真实执行顺序递增且不复用final与Decision epoch；同岛内部原A/矩阵/G身份规则保持。global_layer用于catalog/图定位，和epoch offset、CPU error rank是三种不同编码。

**失败时的epoch保持不能只依赖运行state。** 新增`active_epoch_offset[8:0]`，复位/新BEGIN置0；仅在旧岛真实全部退休后、发起新岛任何lease/请求之前锁定上表offset。所有下游操作统一用`source_epoch+active_epoch_offset`；进入ABORT/cleanup/held DONE不再修改offset，不从错误domain或已切换state反推。catalog/setup失败不创建新的计算epoch。该9bit是明确新增控制，避免完整图新增preLN/final/type后旧Encoder0错误推导失效；不借仍可能用于排债的resident计数器保存身份。

whole-model BEGIN新增已校验qtype2、marker_row[16][6:0]112、marker_mask16；保留现attention mask128，不重复存。输入metadata的完整32bit有符号marker先按现Host契约验证再压缩，inactive marker必须CLS0，active row必须在0..127且attention mask为1；holes/duplicates保留。最后Decision1 residual后仅读H，按16marker槽再CLS共544个32F32向量，复用resident_issue/sink计数；输出slot由sink而非H响应row决定，支持重复marker。69,632B数据保持原顺序和CPU tail边界。新增实际下游`tail_commit_valid/ready,request64,generation32,source_epoch32,bytes32,status8`，只有匹配真实D2H写完成、bytes69632及全部计算资源退休才TAIL_READY/成功DONE；stream out_ready只表示被下游接受，不能冒充DDR写完成。具体DMA/register/XRT映射与其控制census仍OPEN。

新全模型build使用独立ABI：在保留v2旧kind0..4构建的后继入口定义kind5=单个完整Encoder(l0..27)、6=单个完整Decision(local0..1)、7=一次BEGIN全模型。5/6正常输入均是实际完整H公开加载/finite资格；7在开始后仅内部层推进，不接受Host逐阶段desc或下一层gold。新build tag应在该正式实现合同冻结后按§11.6同方法另定abi字符串，当前不改kind4 tag。最小catalog模块交付不等待这个新父整体完成。

### 12.5 新控制逐项账，仍不签4KiB

| 后继状态 | 新增bit | 复用/边界 |
|---|---:|---|
| catalog_base | 64 | 模型commit后跨请求保持，不能放会覆写的两槽内 |
| model_committed | 1 | 实际全setup完成事件；非Host强制位 |
| parent state6→7 | 1 | 现0..59；新增setup/catalog/preLN/final/type/Decision/gather状态统一编码，≤128；不另建stage shadow |
| active_epoch_offset | 9 | 新岛开始前锁定，ABORT/cleanup/DONE期间保持；保留真实失败操作身份 |
| catalog reader FSM | 2 | IDLE/AR/RSP/DRAIN，零data/identity holding |
| qtype＋marker rows/mask | 130 | 新BEGIN必需，原attention mask不重复 |
| type读响应valid/address | 13 | 数据128B另算；实际响应不能省 |
| bias同步读rsp_valid | 1 | 数据256B另算；旧matrix tensor/issue_next在接受前保持 |
| 合计新增 | **221** | 所有扣减须实际实现后才认可 |

既有字段复用精确限定：setup期间resident_issue/sink用于header/record/coeff顺序，无推理活动；tensor_id64用于CRC；base[0]256用于expected SHA、span[0][0]64用于expected CRC；setup完成后这些字段在最初两record实际接受前没有descriptor资格。运行时catalog索引由固定global_layer/pair/slot等待状态组合，req_word在reader busy期间不变，不新增index FF。Decision用pack_seq16计16384，G pack状态互斥；layer_index5已足够30层；epoch加法组合但offset保留上述9bit；全图阶段发生的新同值资格不另存128-bit身份。已有provider33与gamma132保留原计数。

算术上`32519+221=32740bit=4092.5B`，距32768只剩 **28bit**。这是明确实现方案的**非最终投影**，尚缺实际router新增holding、全图错误/取消、mode恢复及DMA/前端实际状态核查；没有足够证据签4KiB。原coef状态可删除的候选必须在canonical生成分支和实际census中逐项证明，本节不预减；如parent状态超过128或需新held选择位，立即加账而不是藏到payload。所有descriptor/base/span/model资格均按控制计，放RAM也不自动从控制账消失。

相对已含H/LN的当前composition，payload新增：bias扩展57344B＋type12288B＋bias读holding256B＋type读holding128B=70016B；gamma4096B已存在，不能再加一份。catalog外部模型metadata有效7936B、BO8192B另记。前述存储不是物理BRAM/URAM综合fit证明。

### 12.6 执行分工、可先验证出口与未完成义务

**最小立即可派边界：A008独占新model_catalog目录的reader RTL/TB及独立catalog打包/检查工具（新文件，不写A010 loader/facade/parent）。** 先只交2bit reader、256B header/120record二进制格式与结构/CRC/来源manifest检查、模型系数原字节/一次type展开的准备接口；预算及允许生成哪些初始化产物由主控正式派发，不在本静态任务运行。A010唯一写父原两槽/真实W口mux/transport_idle聚合和matrix bias vault；A007唯一写type bank、VECTOR op1及wrapper资格/owner路由；A008继续唯一写pure LN/gamma必要接口。每个模块只一位作者，不并行改当前联合build源。

第一出口只需短reader测试：真实AR/R held、连续两槽覆写、bad RID/RRESP/RLAST后真实drain、旧W未idle时不得取得port0（后者由A010生产mux验证）；初始化正常扫描120条，首/尾record错误、CRC错、model身份错、重复/跳号系数不commit，gamma/type载入及跨请求保留。metric为实际AR/R计数、120结构接受、576/32/96系数commit、0第三descriptor/holding、每一owner退场真实债。无新完整矩阵gold。

现在已有公开合法参数可先做Encoder1 `kind1,layer1` Attention、Encoder27 `kind0,layer27` Attention、Decision0/1 `kind2,layer0/1` Attention；这只验证相应Attention子图，需各自原descriptor/系数，**不能**冒称完整层。gamma public loader/现LN use_gamma可在wrapper层正常验证；父目前tie0必须先接线。现完整FFN的kind3只支持Encoder0，不能只改层号声称后续权重已经可用。新增catalog/一般FFN映射/preLN/type/Decision ReLU路径分别实现后才能验证对应完整层。

有界真实接续顺序：先完整Encoder0实际final H通过公开out逐握手导出并附source/run/data SHA；再合法H_LOAD导入这份实际输出做Encoder1，前LN资格由真实装载事件产生；Encoder27→final gamma/type→Decision0→Decision1同理。AT027虽完整FFN通过但没有公开二进制导出，不能拿其计数或gold当后继producer；必须补公开导出或同runtime直接接线。每段使用前一真实DUT输出，原47checkpoint与原GGUF/WeightKey是checker/身份来源，必要首差定位才补局部参考，不要求120个全量中间gold。相邻未验证段不能跳接原gold伪装连续。

分段出口只报告`SEGMENTED_RTL_DATA_CHAIN`及具体已完成阶段；单BEGIN/无Host逐层补给/真实内部H驻留、120矩阵事件、60LN/60residual、final type/gather、真实tail commit和CPU tail完整义务保持。完整图所有异常排列、模型gamma半装载abort、设备独立SHA、全模型reader/coeff/router精确最终census及真实DMA仍OPEN；正常接线不等这些未测异常才启动，也不把OPEN项默认通过。工具预算由主控决定，本节不追加/借用任何旧余额或提高单次帽。

### 12.7 来源与静态判断边界

本节读到的源码版本由同名JSON `model_catalog25_static.source_versions`绑定。路径前缀为`project/E002_Laya_HLS/experiment/`：`forward_controller`父v2的gamma端口1540–1546、计数/epoch1433–1446；`attention_and_fp_engine` joint_v2的H接口1388–1414、source_witness1442–1443及shared_resources_idle2049；resident_ln32_v1的完整短模块；`q8_linear_and_restore` facade_v1:188–237的旧系数窗口及issue_next；`activation_quantizer` quant_group32_v1:88–96坐标约束；`hbm_loader_and_cache` w_supply_v1:63–78、87、126及w_reader_v1真实active/busy/out_valid结束条件。W reader的inflight仅统计busy且未complete的slot，不能把inflight=0当transport_idle；complete但未消费slot仍必须排清。

原模型语义来源为`tests/full_reference.py:87–102,750–820`、`tests/full_model_package_test.py:109–125 expected_bindings()`及`reference/runs/typed_q8_ref_20261005/gguf_inventory.json`选定的final_norm_w/type_emb/Decision记录；仅核查元数据，未读取权重payload或运行模型。Host输出约束来自`host/m007_deploy/schema.json`的marker/qtype/tail项。来源事实与拟实施契约分开：尚无catalog设备初始化、type bank、Decision完整FFN或全图状态census PASS。AT-A011-5选定metadata/整数复算0.04s、RSS11764KiB、exit0；此前四次0.19s，累计0.23/120s。

## 13. TANH-IDLE-CE-26：空闲数值流水线CE的静态裁定

**主控实际消息已采用此边界，拟以E015/R002、D-M007-TANH-IDLE-CE-26复用A008优先验证；本文没有启动实现、EDA或预填PASS。** 痛点是当前联合LN16测得22.157s计算段＋65.759s固定段，主控给出的完整128估计315.056s超过单次120s门；这些数字来自主控消息，不是A011独立复跑。候选假设是无租约时冻结大量无效TANH数值寄存器可降低联合仿真事件开销；幅度、固定初始化费用及完整Encoder成本均待测。

### 13.1 已核查来源与实现边界

`vector_and_ffn/rtl/laya_m007_tanh8_v1.sv:24–64`有8核、152周期的唯一vector credit、活动lease/排债/身份和alignment_fault；其credit及握手一直时钟运行。`laya_m007_tanh_lane_v1.sv:7–11`有完整152bit valid_pipe，末位只给commit_valid；2455–2485、2625–2670及5135–5148显示数值/branch/alignment寄存器每拍更新、leaf的aclken恒1。实际读到的leaf优先级：add3_e_v1:42–44、div12_r4_v1:38–40、fast_leaves_v1中mul4:115–117均先reset，再aclken；divide展开stage:70也受aresetn/aclken约束。这里只核查指定区域和相关匹配，不声称逐行读取整份约5千行generated core。各源SHA在JSON `tanh_idle_ce.source_versions`。

保留原core_v1、tanh8_v1和standalone lane_v1；新增`laya_m007_tanh_core_v2`与`laya_m007_tanh8_v2`，由生产composition显式选一个版本，不并列例化两套TANH。core_v2增加输入`core_ce`和组合输出`token_empty=~|valid_pipe[151:0]`。8核的token_empty做AND，禁止只看commit_valid、pending或单核末位判断。wrapper共用零FF组合式：

```systemverilog
lease_fire = lease_valid && lease_ready;
all_token_empty = &core_token_empty;
core_ce = !rst_n || lease_active || lease_fire || req_fire ||
          (pending_vectors != 0) || (in_flight_vectors != 0) ||
          !all_token_empty || protocol_fault;
```

全部core数值寄存器、branch/operand/alignment延迟寄存器及valid_pipe使用同一个CE；每个算术leaf的aclken连它。valid_pipe仍`if(reset) ... else if(core_ce) ...`，原有leaf reset语义保持，任何reset均不能被CE屏蔽。原本无reset的无效data寄存器仅在CE低时保持，不添加无关初始化、不改数学DAG/舍入/latency/状态判定。不能只门控valid而让data前进，或只门控data而让valid前进；实施后需列出全部sequential/leaf覆盖清单并核验无漏项。

**lease/credit/tag/result队列、请求/返回握手、release/drain及故障寄存器不加CE；实际clk不门控。** 活动lease时CE恒1，包括无请求气泡、返回背压和release等待；每个已接受token保持原152个真实时钟周期、原II和返回顺序。lease_fire当拍立即唤醒，不能以未来lease状态才开CE。无lease但有任意credit债、pipeline token或protocol_fault时继续运行；sticky fault不应被冻结隐藏。只有无lease、无同边沿新lease/请求、无债、全token空且无fault才冻结；这是适用条件，不推广到活动lease的稀疏输入优化。零FF busy/empty与CE不增加控制账，实际实现新增的选择参数/探针如为寄存器必须另计。

### 13.2 最小区分验证与判据

先在A008独立TANH TB对照同源v1、v2强制CE=1、v2正常空闲CE：沿用已有原corner输入/每lane mask/status/tag检查，不计算新模型gold。三者在有效返回时data/status/tag/mask逐位一致、每请求仅一返回、152周期及原II一致；invalid data不作为功能比较对象。测试空闲→lease→首token、连续II流、token位于首/中/末级时禁止冻结、最后返回held17拍、pending已非零但pipeline空、release前后背压、释放后立即新lease、冻结期间reset及无reset新generation。故障路径保持CE1和原错误响应，不能靠force清credit/token制造正常恢复。

再由资源owner在一个真实joint build选v2，重复同版16row正常LN/residual pilot并检查实际输出、真实owner/credit/lease退休；记录同一机/CPU限制/工具版本/source hash/输入和cycle下的计算段与固定段墙钟，附v1控制组。功能一致是必须条件；只有实测墙钟下降才支持加速假设，不能用CE为0的周期数代替速度。全图其他负载占主导、编译器已消去无效更新或CE分支开销较大，都可能使速度不变甚至变慢；这不推翻数值正确性，也不给完整128自动加预算。具体reference/static/RTL预算由主控派发，本静态任务额度不转移。

**交付判断：静态安全边界成立于完整覆盖、reset优先及原lease/credit不变这些条件；RTL等价、联合加速、完整Encoder通过均NOT_RUN。** catalog设计已保存，优先次序依主控改为先TANH-CE小切口；不因本节延后未完成的一次BEGIN生产义务。

本轮最终只读/记录脚本：AT-A011-6为指定源码SHA、投影整数断言及owned JSON写入/重读，0.05s、峰RSS15768KiB、exit0；AT-A011-7补唯一Host schema路径SHA，计时精度显示0.00s、峰RSS3176KiB、exit0。七次脚本累计报告0.28/120s，均CPU0–3/nice19/idle、单次20s门内；无EDA、新gold或模型计算。§12控制投影修订为新增221bit、32740bit/4092.5B/余28bit，与JSON一致；TANH新增状态为0仅指本CE契约，实施审计仍需确认。

## 14. FULLMODEL-ABI-30-STATIC：唯一canonical v3实施合同

主控实际派发`D-M007-SM012-FULLMODEL-ABI-30-STATIC`，只追加本源页/同名JSON，不写生产或主控索引。当前工程结论采用主控增量86及后续实际消息：完整FFN已通过；D23真实residual128→LN16成立；D27 CE逐周期功能等价但总墙钟仅62.693→60.396s，LN16未改善，LN128估计226.787s超过120s门未运行；A010新CE父AT014 build/AT015 census32519bit已通过，最小QKV1/FFN1通过，完整Encoder仍NOT_RUN。上述是主控审核状态，A011没有复跑，不能把§13候选加速外推为已经解决全链成本。

本节只给一套canonical v3接口。§12的8192B catalog/原两descriptor槽、SHA/CRC复用、73,728B bias/4KiB gamma/12KiB type、active_epoch_offset9与正常图保持；本节补齐公开ABI、错误、可删除旧状态及外部地址/完成责任。旧parent_v2 kind0..4、原build和冻结结果全部保留。

### 14.1 独立build与事务端口

新生产模块名固定`laya_m007_single_parent_v3`，仅接受kind5/6/7。其`V3_BUILD_ID=128'hcedb4c130303f16da9fa1c605b2cf985`。可复现ASCII（无换行、无NUL、大小写及逗号照录）为：

```text
Laya-HLS|M007|D-M007-SM012-FULLMODEL-ABI-30|laya_m007_single_parent_v3|cmd_kind=5,6,7|abi=1
```

完整SHA256为`cedb4c130303f16da9fa1c605b2cf9850fa7ee8593b0391a3e92bc3103ce037c`，取digest前16byte按通常大端十六进制显示作为128bit端口值。它是**接口合同身份**；完整源码/build manifest SHA另记。catalog header的model-package-build SHA指原模型包，与此RTL ABI tag不是同一对象，不能互相替换。

编译参数固定为五个完整256bit SHA：`MODEL_SHA256,GRAPH_SHA256,NUMERIC_SHA256,LAYOUT_SHA256,PACKAGE_BUILD_SHA256`，另有原`TABLE_KEY[127:0]`和§14.5平台常量。SHA端口/参数采用digest首byte在`[255:248]`，依次向低位；header按地址递增保存同一digest byte序列，比较时显式重排，不把LE整数规则错误套到SHA字节串。原叶级128bit身份为对应SHA的`[255:128]`；内部matrix/gamma model64为这个128bit MODEL_ID的`[63:0]`，即完整SHA`[191:128]`，不静默改成完整SHA低64。尚缺完整原identity时由打包owner报告，不补零伪造。

以下均为同步valid/ready；字段从提出valid至接受保持，rst_n低时所有准入关闭。唯一父同一时刻仅一个事务，统一终态复用原`done_valid/ready,done_request64,done_generation32,done_epoch32,done_status8,error_domain3,source_status8,error_tuple96`；新增组合`done_op[1:0]`：0=SETUP、1=INVALIDATE、2=BEGIN，3保留。held DONE期间所有终态字段稳定，没有第二套身份/错误holding。

| 入口 | 精确字段及语义 |
|---|---|
| `setup_valid/ready` | `setup_request64,setup_generation32,setup_build_id128,setup_table_key128`；`setup_model_sha256,setup_graph_sha256,setup_numeric_sha256,setup_layout_sha256,setup_package_build_sha256`各256bit；`setup_catalog_base64,setup_catalog_span64,setup_records_sha256,setup_records_crc64`。span必须8192。五SHA/table/build在接受边沿全位核验，之后与编译常量比较header，不再锁五份identity。records SHA/CRC复用§12原槽。 |
| `invalidate_valid/ready` | `invalidate_request64,invalidate_generation32,invalidate_build_id128`；全债清后允许幂等invalidate。合法接受即清model_committed并关闭所有旧模型资格；不清仍有效payload或gamma数据来伪造债退休。错误build不invalidate，返回错误DONE。 |
| `cmd_valid/ready`（BEGIN） | 原`cmd_request64,cmd_generation32,cmd_epoch32,cmd_model_id128,cmd_numeric_id128,cmd_table_key128,cmd_graph_id128,cmd_layout_id128,cmd_build_id128,cmd_kind3,cmd_layer5,cmd_mask128`；新增`cmd_qtype2,cmd_marker_rows[16][31:0]`（有符号原marker值）、`cmd_marker_mask16,cmd_candidate_count5`。删除该新模块的Host `cmd_tensor/base/span`与desc流，运行descriptor仅来自设备catalog。 |
| `model_word_valid/ready` | `model_word_request64,model_word_generation32,model_word_kind2,model_word_index10,model_word_data[32][31:0]`，kind0=bias/1=gamma/2=type；合法顺序分别0..575/0..31/0..95，父身份/phase/真实bank ready同时满足才接受。 |
| H输入 | 保留v2的`in_valid/ready,in_data[32][31:0],in_request64,in_generation32,in_epoch32,in_row8,in_group8`，仅H_LOAD接收严格4096组；不暴露Host可写finite-qualified位。 |
| 上游输入失败 | v3为`producer_fail_valid/ready,producer_fail_request64,producer_fail_generation32,producer_fail_epoch32,producer_fail_code8,producer_fail_detail80`；只在匹配当前H_LOAD时接受，形成domain2/format7，原v2的opaque96接口不改。 |

v3保留原RoPE `coeff_bind_* / coeff_wr_* / coeff_family_complete`端口的位宽，但只允许未committed、无BEGIN且真实相关owner idle的模型准备操作；SETUP最后核两family和原model/numeric/table绑定。旧临时bias `coef_cfg_* / coef_wr_* / coef_rsp_*`不属于v3顶层，不能和model_word形成第二写入口。gamma/type/bias全量完成、gamma_done消费、两RoPE族完整、SETUP_DONE成功被消费后才置model_committed；此边沿之前cmd不取得模型资格。

ready均受真实global_idle（含外部tail_owner_idle、无held DONE、无gamma加载/服务债）约束。SETUP还要求`!model_committed`；模型替换必须先invalidate。三个控制入口同拍固定优先级INVALIDATE→SETUP→BEGIN，各ready据此前面valid屏蔽，最多接受一个。BEGIN在idle时可接受格式错误/未committed命令，随后返回错误DONE而不启动任何计算；不能把非法配置永远ready=0。内部复用现kind3寄存器：SETUP用0，INVALIDATE用1；BEGIN有效值5..7，非法kind归一为5仅用于done_op判别，实际错误kind存CHECK.observed。setup/invalidate复用父request/generation，epoch锁0；done_epoch为0。BEGIN保留原source_epoch，所有DONE均回显它。

kind5：`cmd_layer=0..27`，输入为该Encoder完整H；layer0输入原embedding_norm且省preLN，layer>0执行preLN；结束公开导出4096组完整H。kind6：cmd_layer为**局部**0/1，父实际layer_index置28/29，输入为该Decision的完整H，执行其preLN/Attention/残差/postLN/FC1→ReLU→FC2/残差，然后导出4096组H；单Decision不偷偷加final gamma/type。kind7：cmd_layer必须0，内部从global0推进至29，final gamma/type在Encoder27之后，仅发最终544组tail。kind5/6要求qtype、markers、marker_mask、candidate_count全0；kind7核qtype0..2、candidate_count等于mask popcount且1..16（qtype2恰2）、active marker原有符号值0..127且cmd_mask对应位1、inactive marker为0；保留holes/duplicates。Host原512B metadata解析器负责原u8 mask必须0/1及32bit qtype/count的压缩前验证，不能把非法高位截掉后声称core已拒绝。父只保留qtype2/rows112/mask16=130bit，count由mask组合导出，不增加计数身份。

### 14.2 H见证与零新增身份状态的复用边界

`h_load_success_valid`是**父内部**生产事件：本次接受的4096组都发生真实H写commit、每组32F32 finite检查通过，最后写及H响应已退休，request/generation/source_epoch仍为当前命令。父复用resident_sink13与现H_LOAD状态产生一次事件；不得以4096次in_valid、Host结束标志或输入ready推测写完。wrapper可检查现owner身份/状态并复用现source_witness，但不另建4096计数器/完整身份副本，也不声称wrapper本身能识别任意提前伪造的内部success脉冲。TYPE-29独立TB只能在合法完整H装载后驱动该事件；A010父集成后再动态核提前发布屏障。新BEGIN、普通H写或新VECTOR操作失效旧witness的规则保持。

原state6→7的净1bit仍足够本合同；建议固定分配（为实现清单，不是现有RTL已具备）：0..59保留当前父对应操作状态；60..73为SETUP_CHECK/HEADER_AR/HEADER_R/RECORD_AR/RECORD_R/BIAS/GAMMA_OWNER/GAMMA_BEGIN/GAMMA_DATA/GAMMA_DONE/TYPE_LOAD/ROPE_CHECK/SETUP_FINISH/INVALIDATE_FINISH；74..81为CAT_ATTN或CAT_FFN各slot0/1的AR/R；82..86为preLN五步，87..91为finalLN五步，92..96为type五步，97=LAYER_NEXT；98..103为Decision FC1/FC2各START/RUN/DRAIN；104..106为GATHER_START/RUN/DRAIN；107=TAIL_ARM、108=TAIL_WAIT、109=TAIL_ABORT、110=ERROR_CLEAN、111=SETUP_ERROR；112..115是四种运行catalog origin的故障DRAIN，116/117为setup header/record故障DRAIN。pre/final/type的五步为OWNER→SCRATCH→START→RUN→RETIRE；未用118..127保留，不能把备用编码当额外寄存器。

catalog缺RLAST的DRAIN必须保持原base、req_word和caller计数至reader真idle；112..117明确保留原pair/slot或setup phase，不能一跳通用ABORT就改变req_word。源offset9只在旧运算岛全部退休之后改变，cleanup/DONE保持；错误op由实际source和发生阶段编码，独立于offset/global_layer。无额外事务class、error_layer、error_op、tail_ack_seen或descriptor_index FF；若实际实现确需它们，逐项加账。

### 14.3 v3唯一96bit错误ABI

v3独立错误封套为`{op[7:0],global_layer[4:0],format[2:0],detail[79:0]}`：op在[95:88]，global在[87:83]，format在[82:80]。global0..27=Encoder、28/29=Decision；30=finalLN/type/gather/tail等跨层操作；31=setup/header/CRC/控制配置等无层操作。setup扫描record的结构/传输错误可给实际record对应global，bias装载可给28/29；未知或不合法索引用31。该global已锁在原error_tuple内，进入ABORT不由现layer重建。成功时domain/source/tuple均0。

domain保留3bit分类：0成功、1命令/模型/descriptor配置、2公开H producer失败、3quant、4matrix、5Attention、6G、7父胶合/模型传输/LN/VECTOR/tail。`done_status`固定0成功、1数值、2协议/传输/实际D2H失败、3producer失败、4命令格式或身份非法、5模型/descriptor未就绪或结构非法、6无先前主因的取消；不把清理cancel覆盖原主因。source_status8在matrix/quant/Attention为原实际源status零扩，G为原status低8且其完整32bit放format5；LN为真实done_kind零扩；VECTOR为真实6/8；tail非零完成status保留原8bit。其余父本地来源按下表代码。gamma_done_error为真实布尔1时保留source1；若父已经在实际gamma写接受边沿定位非finite，则保留该先前source6及lane，不用后来的笼统1覆盖。

| op十六进制 | 实际操作 | 默认domain / source |
|---|---|---|
| 01 / 02 / 03 | SETUP_CMD / INVALIDATE_CMD / BEGIN_CMD | 1 / 本地原因码 |
| 04 / 05 / 06 | CATALOG_HEADER / CATALOG_RECORD_INIT / CATALOG_CRC | 结构/CRC为1；AR/R错误为7 / 本地原因码 |
| 07 / 08 / 09 / 0a | BIAS_LOAD / GAMMA_LOAD / TYPE_LOAD / ROPE_QUALIFY | 非finite或实际bank/loader协议为7；模型未就绪/身份为1 |
| 0b / 0c / 0d | CATALOG_ATTN / CATALOG_FFN / MODEL_WORD_OFFER | 合法record结构为1、传输为7；未接受offer走reject |
| 20 / 21 | H_LOAD / PRE_LN | 7 / H本地原因或LN done_kind；producer_fail另为2 |
| 22 / 23 / 24 / 25 / 26 | QKV_QUANT / QKV_MATRIX / ATTENTION / CONTEXT_QUANT / WO_MATRIX | 3 / 4 / 5 / 3 / 4，source保留对应源 |
| 27 / 28 / 29 | RESIDUAL_A / POST_LN / FFN_INPUT_QUANT | 7 / 7 / 3 |
| 2a / 2b / 2c / 2d / 2e | WI_MATRIX / G / G_QUANT / DOWN_MATRIX / RESIDUAL_F | 4 / 6 / 3 / 4 / 7 |
| 2f / 30 | FINAL_LN / TYPE_ADD | 7 / LN或VECTOR实际源 |
| 31 / 32 / 33 / 34 | FC1_MATRIX / RELU / FC1_QUANT / FC2_MATRIX | 4 / 7 / 3 / 4 |
| 35 / 36 / 37 / 38 | DIAG_H_EXPORT / GATHER / TAIL_COMMIT / ROUTER_RETIRE | 7 / 本地原因或真实tail status |

本地原因码固定：1 FORMAT、2 IDENTITY、3 RANGE/OVERFLOW/OVERLAP、4 ORDER/COUNT、5 CRC、6 NONFINITE、7 RID、8 RRESP、9 RLAST、10 REAL_COMMIT_MISMATCH、11 APERTURE_UNBOUND、12 MODEL_NOT_COMMITTED、13 OWNER_OR_RETIRE_PROTOCOL、14 TAIL_BYTES、15 TAIL_STATUS、16 RESERVED_NONZERO、17 SOURCE_TUPLE_RANGE。header SHA字段不等expected属IDENTITY2，不能叫设备SHA计算失败。AR/R多错同拍固定RID→RRESP→RLAST，先报告实际传输错误，再做内容结构检查。数值source6对应done_status1；配置检查用status4或5，实际协议用2。正常backpressure/尚未退休不是错误，不因等待几拍生成13。

| format | detail[79:0]精确布局（左项在高位） |
|---|---|
| 0 CHECK | `{code8,index16,field8,port3,lane5,observed32,zero8}`。port0..3真实W口、7=无口；无lane/observed时置0。catalog传输index=req_word0..123；结构record index0..119；模型word index为本phase chunk；gather index为向量slot×32+chunk。observed是诊断低32bit，实际身份/地址检查仍完整位宽。 |
| 1 LN | `{error_class2,error_row7,error_check4,error_level4,error_node10,protocol_code4,protocol_location8,error_stage5,zero36}`。协议场景数值字段0；数值场景协议字段0；使用真实源字段，不把epoch或op号混入CPU Check。 |
| 2 MATRIX | `{zero_extend(source_error_stage)16,zero_extend(row)16,column16,zero_extend(group)16,zero16}`。 |
| 3 QUANT | `{phase16,row16,group16,element16,zero16}`，由现父公开quant字段零扩。 |
| 4 ATTENTION | `{original_stage8,a8,b8,c8,d8,e8,f8,zero24}`。原tuple为`{stage8,a16,b16,c16,d16,e16,f8}`；现所有合法来源范围≤127（head≤15、node/channel≤63），故五个16bit字段的高8bit必须0，合法信息无损。若实际源高8bit非0，报domain7/source17/format0并给首个字段及原16bit值，禁止静默截断。协议状态没有合法数值tuple时用format0，不虚构CPU坐标。 |
| 5 G | `{rank16,row16,column16,raw_status32}`。 |
| 6 VECTOR/RELU/H | `{row16,column16,lane8,raw_status32,zero8}`；column是原真实元素列，lane=column低5位。有限输入H/finite结果失败由真实最小lane定位。 |
| 7 PRODUCER | 原v3 `producer_fail_detail80`，domain2/source=producer_fail_code，op20/global为本次H目标层。 |

CHECK.field固定：0=GENERAL、1=MAGIC、2=VERSION、3=HEADER_BYTES、4=RECORD_COUNT、5=RECORD_BYTES、6=MODEL_SHA、7=GRAPH_SHA、8=NUMERIC_SHA、9=LAYOUT_SHA、10=PACKAGE_BUILD_SHA、11=RECORDS_SHA、12=CRC64、13=EFFECTIVE_BYTES、14=RESERVED、15=BASE、16=SPAN、17=APERTURE、18=RTL_BUILD、19=KIND、20=LAYER、21=QTYPE、22=MARKER、23=MASK、24=CANDIDATE_COUNT、25=BYTE_COUNT、26=TRANSACTION_IDENTITY、27=SLOT、28=INDEX、29=NUMERIC_VALUE、30=TRANSPORT_IDLE。未定义值拒绝，不在实现中重新编号。

错身份或错坐标/序号的未接受H/model_word/tail offer不污染活动事务：组合输出`reject_valid,reject_port3,reject_code8,reject_tuple96`，无reject holding；reject_port1=H、2=model_word、3=producer_fail、4=tail_commit。offer方持有至接受或观察reject后撤回/纠正，reject当拍ready=0；可同时出现时按2→1→3→4选择唯一可见reject，其余保持等待。kind/index错误的model_word不交给gamma loader，允许纠正后继续，不能宣称触发了完整setup abort。已合法接受的非finite gamma必须实际送loader，由当前`gamma_finite`失败终止、消费gamma_done；若gamma仅加载部分后producer弃流，现无public abort，继续OPEN且不得提前给全资源已退休的DONE。

RELU先看原FC1 finite失败，不能把NaN/Inf改0；父在已宣称finite的FC1输出发现非finite时以op32/source6/format6报告（普通matrix自身错误仍op31/domain4）。type/gather必须用实际响应地址/身份检查；held out不稳定或实际commit缺失走op35/36的protocol，而正常out_ready=0仅等待。tail规则见§14.5。已锁的上游主因不被清理取消覆盖；模块自己的原错误排序继续由模块终态负责。并发岛内后到的、更早原算子终态可替换尚未发布的下游候选，原error_tuple可复用，不另存每域副本；不能把首个墙钟故障直接当原CPU全图首错。尚未验证的任意多错/取消下完整原Check顺序仍OPEN，本ABI编码不代签这些测试。

### 14.4 canonical coef编译删除与精确位账

固定实现选择：新增facade后继的编译参数`CANONICAL_MODEL=1`，canonical与legacy为互斥generate分支；parent_v3只选择canonical，旧parent_v2继续旧facade/build。canonical只声明一份288×64F32 bias bank；合法model_word bias写直接进入该bank，父负责严格576序/finite/model_committed；旧64×64F32窗口、旧coef_cfg状态和其响应全部不存在。旧接口如因模块签名保留，canonical分支ready/valid/status/error_col均组合常量，不得保留影子FF。运行bias资格由已commit模型＋固定tensor/K/N/bias映射给出；新增同步bias_rsp_valid1及256B holding已在§12计入。issue_next只在真实core命令接受时推进，held响应未消费/丢弃前不换事务；不再添地址/身份FF。

| canonical确实消失后才可扣的旧字段 | bit |
|---|---:|
| coeff_busy / coeff_valid / coeff_bad | 3 |
| coeff_coverage | 128 |
| coeff_count | 8 |
| coeff_model / coeff_request | 128 |
| coeff_tensor / coeff_generation / coeff_epoch | 96 |
| coeff_n | 16 |
| coef_rsp_valid / coef_status / coef_error_col | 1+2+16=19 |
| 总计 | **398** |

对应源码facade_v1:188–189声明、198–202资格、214–237 reset/加载/回执。原coeff_words是payload，不混入398控制位；删除旧16KiB窗口与扩大同bank的payload关系仍按§12净+57344B，不把同一窗口扣两次。`coef_cycle_bad/coef_cycle_col`是当前时钟过程的组合临时计算，本表不自行追加扣减，其真实综合/声明分类由A010核。

本节ABI/错误封套/平台常量/新输出均利用已列状态或纯组合，**较§12新增控制0bit**；D32容量核也新增0bit。未实现删除前仍`32519+221=32740bit=4092.5B`，余28bit。仅实际单bank与字段不存在的逐字段展开/census成立后，条件投影为`32740−398=32342bit=4042.75B`，余426bit（53.25B）。这是父内已列范围，真实router/异常持有、地址前端和DMA控制仍需完整计入；最终超过32768时报告精确差额，不改名payload隐藏。A010交付至少列两个build分支、canonical层次唯一bank容量、398字段零物理实例、保留的同步bias valid/payload、实际总账；静态建议不是已释放398bit。

### 14.5 catalog正式模型区、平台边界与真实tail owner

catalog是正式模型只读元数据区：独立8192B BO（header/records有效7936B，尾256B零），4KiB对齐、生命周期覆盖所有committed请求；不能占原W tensor、H0或tail空间。模型manifest必须列`catalog:{bytes:8192,effective_bytes:7936,alignment:4096,port:0,records_sha256,crc64}`及实际分配引用。所有W record的base/span仍由原WeightKey绑定，不因增加catalog而改变原Q8数据布局。

v3编译平台参数精确为`ADDRESS_PROFILE[1:0]`（0=UNBOUND、1=SIM、2=DEPLOY）、`HBM_PORT_BASE[4][63:0]`、`HBM_PORT_SPAN[4][63:0]`、`PLATFORM_MANIFEST_SHA256[255:0]`，都是编译常量，不新增512bit可写aperture寄存器。每port span>0、65bit base+span不溢出，合法访问半开区间必须被本port范围包含；catalog在port0完整8192B范围内，所有port0 W区间不得覆盖它。UNBOUND接受SETUP后返回domain1/op01/source11，无AR。SIM的数值由该次TB manifest显式给出，标模拟地址；DEPLOY必须从实际平台链接/内存连接manifest和真实BO分配导出并保留SHA，当前没有这些来源，不能编U55C物理地址或把SIM参数当部署证据。实际H0/tail地址仍由外部Host/DMA前端保存并检查完整65bit溢出、相互不重叠、与封存模型不重叠；该前端不在本父内凭空消失，后续总控制账另纳入。

输出沿原`out_valid/ready,out_data[32][31:0],out_row7,out_col16`，另有组合`out_slot5`：kind7为marker槽0..15再CLS槽16，out_row是实际H源row，out_col为chunk×32；kind5/6 out_slot=0且4096组完整H。输出payload和坐标在held时稳定。kind7父增加以下真实外部协议（均复用当前父身份，无地址或身份shadow）：

| 端口 | 固定握手义务 |
|---|---|
| `tail_begin_valid/ready,tail_request64,tail_generation32,tail_source_epoch32,tail_expected_bytes32` | BEGIN已合法且model committed后，TAIL_ARM发一次，expected_bytes=69632；外部owner只有准备好本请求唯一目标缓冲区才ready。该握手后才进入H_LOAD。 |
| `tail_commit_valid/ready,tail_commit_request64,tail_commit_generation32,tail_commit_source_epoch32,tail_commit_bytes32,tail_commit_status8` | 仅完成544次实际out握手、计算/H读债退休后TAIL_WAIT给ready。身份匹配才可接受；bytes必须69632、status必须0，否则实际接受错误并按op37/format0报status2。错身份不接受并reject，不覆盖当前请求。peer提前valid必须保持，不能靠parent接受输出即自宣commit。 |
| `tail_abort_valid/ready`及同一tail身份输出 | 已arm后发生错误时进入TAIL_ABORT；valid保持。外部owner仅在真实停止新写、已接受写/响应完成或真实取消且放弃该请求可见资格后给ready。父等待此接受和真实tail_owner_idle后才错误DONE；没有强清外部债。 |
| `tail_owner_idle` | 来自外部实际写入/响应/终态状态，用于global_idle。未arm时不因纯数值失败伪造tail事务；kind5/6不走tail协议。 |

不新增tail_armed FF：正常kind7只有TAIL_ARM接受后才进入H_LOAD/计算/gather，前/后状态路径即资格；合法错误进入tail_abort的依据由这些已达状态决定，未接受arm的命令失败直接FINISH。当前阶段外部owner是A010自有TB中的**SIM D2H peer**：接收真实公开流，按out_slot/chunk写其目标内存/文件，核实际写入计数/字节/身份，并在最后真实peer写完成后提供commit；checker逐位核对独立进行，不能只有gold匹配才假造写完成。SIM peer可以测尾写背压、末写延迟、错身份/bytes/status、真实取消，所签范围仅仿真外部协议。生产中owner必须是实际D2H DMA/主机可见写完成前端，只有真实写响应及可见性完成后才能发commit；未来部署工程由主控另派实际Host/DMA owner，不假称已有DMA、XRT寄存器绑定或板卡验证。现Host schema明确`register_mapping=NOT_BOUND_TO_XRT`，stream out_ready绝不是D2H写完成。

### 14.6 D32补充：Decision FC2的实际容量核对

本项是指定源码静态核对，不是K4096 RTL已通过。唯一A cache实例在facade_v1:278，`a_cache_v1:31–39,58–71,97–117`实际有两槽、每槽16个a_bank；a_bank_v1:3–8为1024条×(256+16)bit。每槽`16×1024×272/8=557056B`，恰有128row×128group=16384组，双槽1114112B既存。bank=row低4bit，地址`{row[6:4],group[6:0]}`10bit，最大1023。fill_count/target_count15bit可表示16384，coverage16384bit覆盖全部坐标，groups/slot_groups8bit可保存128，cfg_k明确允许4096。最后row127/group127真实ACK消费后才发布完整A1。

quant_group32_v1:8,48–56,88–101用lease_k13、组坐标8bit、accepted/retired及三个调度计数32bit，明确允许4096；128 reservation是流式在途容量，不是全tensor深度。quant_a_fill_v1:47–52,69–90,101–121的total_groups、quant_accepted/retired、a_writes/acks均32bit，K4096合法、target为16384；坐标队列仅128在途且顺序校验返回，不能当另一个全FC1缓存。

facade_v1:195–200与matrix_engine_v1:122–131,165–168都支持K1024/N4096和K4096/N1024；engine按单64列超块推进，其a_next/issue/commit13bit可到K4096，不能拿该局部计数误当整个16384组输入计数。W supply_v1:32–47,53–61,69–83,99–105,116–131用groups8保存128、group_index8到末128、coverage512/covered10保存512，commit地址9bit=`{group[6:0],port[1:0]}`。w_bank_v1:3–9每bank512×272bit，两槽各16bank，单槽278528B=128groups×64columns×34B；K4096正好填满512记录，计数/地址足够。每port单超块128×576=73728B；16个FC2超块每port1179648B，与catalog公式一致。

因此已读模块的K4096容量/宽度无需增加控制或payload；新增位为0。仍要求最小实际验证FC1→quant/A1共16384输入/输出/写/ACK、末row127/group127保持、真实A1发布，FC2实际K4096和16个W超块，A0读与A1写合法并发、全返回退休后复用；普通只检查pack_seq16不构成该证明。本静态任务未运行这些用例。

### 14.7 最小验证出口、来源和判断

A010先实施独立v3入口/错误打包/compile-time coef分支和实际platform profile；A008 catalog工具/reader按D28不变；A007 TYPE-29按真实完整H输入及内部事件合同独立推进，不等待本节未测全异常。最小ABI检查覆盖同拍三入口优先级、非法kind/layer/build/未committed、held SETUP/INVALIDATE/BEGIN DONE、model_word重复/跳号拒绝、header/R fault原slot drain与错误tuple、kind6局部layer→global28/29、marker重复/holes和尾写commit保持；同一已授权短例检查源错误字段不截断。完成canonical逐字段实际删除证明后才更新最终census。代码实现与仿真预算由主控实际派发，本页不预填PASS/实施预算。

来源均位于`project/E002_Laya_HLS/experiment/`，本节实际快照SHA见JSON `fullmodel_abi30_static.source_versions`：parent_v2公共口1–99、status map1571–1576及错误分支1608–1735；matrix_facade_v1系数188–237；Attention check_order_v1:2–5/tuples及layer_engine_v1:743,1115–1148的全部tuple构造范围；compact_v2（当前文件名仍v2）:6–22,55–61、gamma343/823–826；§14.6所列A/quant/matrix/W源；Host schema字段/rules和NOT_BOUND_TO_XRT。新ABI hash/398位和A/W字节算术AT-A011-8：0.04s、RSS14180KiB、exit0，累计只读脚本报告0.32s。源码事实、架构契约、主控转述验证三者分列；完整v3、设备全setup、K4096接线、整30层一次BEGIN和真实DMA均NOT_RUN。

实现细则：matrix/quant的实际source status沿现映射`0→done0,1→done5,2→done1,其余→done2`；Attention沿`0→0,1→1,2→6,其余→2`。LN kind1→数值1、kind2→协议2、kind3无先前主因→取消6；有先前主因则不覆盖。catalog最后record CRC比较用包含该实际握手512bit数据的`crc_next`，不能比较旧CRC寄存器遗漏末条。TAIL_COMMIT已匹配接受且外部owner实际idle时，其失败可直接形成错误DONE；尚有已arm外部债才走TAIL_ABORT排空，commit/abort两者不重复宣告同一成功。上述均复用既有状态/错误寄存器，不引入新FF。

AT-A011-9仅15份指定来源SHA、8种detail宽度/编码示例整数检查及owned JSON写入后解析：0.05s、RSS17308KiB、exit0。每种detail恰80bit，连op8/global5/format3恰96bit；示例见JSON。ABI-30本轮脚本合计0.09s，连旧任务累计报告0.37s，仍在120s内；无EDA/新gold/模型运行。最终机器记录键为`fullmodel_abi30_static`。

## 15. D32实际源码有界核对（A011，2026-10-23）

主控在D32首次构建接入期间实际派发本次核对，仅检查新parent_v3、canonical facade/W v2的图顺序、epoch/两槽catalog、Decision容量接线、tail退休及398bit编译分支；不重做全审核、不改生产/索引、不运行EDA/模型/新gold。A010编译独立继续。以下源码读取时存在并行普通修复，故区分初次观察与最终有界快照，不把早期行号硬套到新版本。

### 15.1 已实际报告的三个实现偏差

1. **A fill cancel身份。** 初读parent_v3:1893在ACANCEL/ACWAIT选原`epoch`，但该A配置和quant cmd使用`operation_epoch=epoch+active_epoch_offset`；Encoder0 QKV岛offset也是1。因此该取消请求与实际A slot身份不符，不能完成匹配取消握手。已直接通知A010/主控；最终快照`2341d9b5…`的1895行已改为`operation_epoch`。这是已见源码修复，真实部分A在途取消/新generation恢复仍待A010短例，不能以连线改正代签恢复PASS。
2. **catalog传输domain。** 最终快照parent_v3:1598、1603、1666在header、setup record、runtime record的`cat_fault`仍传domain1；§14.3要求实际RID/RRESP/RLAST故障domain7，结构/CRC保持domain1。可复现输入为真实catalog R返回RID≠7或RRESP≠0或缺RLAST；无需修改数值参考。A010实际消息确认已接普通修复，本文未再次读取其后版本。
3. **tail实际失败status。** 最终快照parent_v3:1794将匹配非零`tail_commit_status`映为source15；§14要求保留raw8，只有CHECK.code为15。例如bytes69632/status`8'h5a`应domain7/source5a/detail.code15，当前为source0f。bytes错误仍优先source14/code14。A010实际消息确认接纳修复；本文未代签修复后源码或动态结果。

上述三项均已通过实际消息送达A010和主控，主控确认属既定D30接口的连续实现修复，不是新的审批门；无需新增状态位。

### 15.2 本次已核的正常源码边界

父最终快照的1828–1829使用`layer_index%3==0`选Encoder full，其余sliding，得到full层`0,3,6,9,12,15,18,21,24,27`共10层、其余18层sliding；Decision global28/29映射prepare kind2与local0/1。1641–1788所读正常FSM在Encoder0省preLN，后继Encoder有preLN；Encoder27之后offset448 final gamma LN→449 type→global28/offset464 preLN→Decision0/1，最后global29→gather496。独立kind5/6在相应完整层后导出H，kind7才连续推进。此为图源码核对，不是实际120矩阵/60LN/60residual事件覆盖。

1308–1320的offset函数为Encoder16*l+p、Decision464+16*(l−28)+p；active_epoch_offset9与parent state7位匹配§14，命令wrap检查1526存在。tensor/base/span仍1003行所示**两份**；1462的word计算为4+4*global+2*pair+slot，最大123，7bit足够。1535–1539计数复用与1596–1613、1665–1674 catalog状态保持实读，缺RLAST走原origin DRAIN并保留索引；CRC末record比较实际`crc_next`。catalog只在真实matrix transport_idle及quant退休条件下提出请求，期间m_arready/m_rvalid关闭，出口只port0；正常进入catalog状态的前序含实际退休。W reader_v2:26、65–77的idle包含active/busy/complete/registered output/AR，complete在最后真实parser消费时清；W supply_v2:34再合load/read/borrow/lease和四reader，facade_v2:195再合实际matrix/A债。未运行故障drain/旧W未退休的生产mux测试。

Decision实际接线：父1875–1880选择FC1 K1024/N4096/A0、FC2 K4096/N1024/A1并启bias；1950–1964在D1SUB给quant K4096/slot1，D1DRAIN的matrix输出经finite检查/组合ReLU直送quant，group=`m_out_col>>5`，无全FC1新buffer。pack_seq16在2454的实际`m_out_valid&&m_out_ready`递增，close门要求16384或真实matrix错误；F_QDRAIN→F_RELEASE等待quant终态和实际matrix/FP/DIV/storage退休后才D2SUB。q/A底层既有K4096容量仍见§14.6；本次没有重新重复该底层容量审核。resident_issue/sink各13bit只计4096或544，没有代计16384。真实完整16384组/末127,127/ACK/FC2仍NOT_RUN。

tail在1438仅544次实际H读issue和544次公开out接受、resident/scratch真退休且identity匹配后可接受commit；1789–1797的GATHER_DRAIN→TAIL_WAIT→ERROR_CLEAN还等待tail_owner_idle才DONE。out_ready只是流接受，未直接变成完成；slots由resident_sink[9:5]给0..16，marker重复顺序仍由实际sink计。完整SIM peer、真实D2H DMA和错误恢复未在本核对运行。

canonical选择在父2153附近实际为`CANONICAL_MODEL(1)`。facade_v2:196–228只有`words[0:287]`（288×64F32）、response_valid1及response_data256B；旧coeff_busy/valid/bad、coverage128、count8、model/request128、tensor/gen/epoch96、n16和响应19bit处在互斥`else:legacy`，canonical区内无这些旧reg名，旧输出为组合0。读取/消费使用同一稳定issue_next，响应在core实际命令接受或真实abort时清；本次支持**源码generate选择可删除398bit**，不替代真实展开/声明census或物理fit。新增bias response1及payload已按§12计，未重复扣旧窗口。

### 15.3 精确快照、费用与未核范围

快照由唯一计时程序`D32-A011-READ1`从以下四个指定文件读字节并计算SHA256，同时复算10/18、16384与398；没有改写源码。路径前缀`project/E002_Laya_HLS/experiment/vivado/module_design/`：

| 文件 | 最终有界快照SHA256 |
|---|---|
| forward_controller/rtl/laya_m007_single_parent_v3.sv | `2341d9b58fbece9124fcc57a07770ee2d42f92de4fc5ab06f641ba95745669b0` |
| q8_linear_and_restore/rtl/laya_m007_matrix_facade_v2.sv | `a4473f280d9879eee061c54b95391210372a06505623c09793679c072bdcff25` |
| hbm_loader_and_cache/rtl/laya_m007_w_supply_v2.sv | `9452d56a9652fe1685b71659b26f1a5777b9a2e7828ca897238ddba26c30171d` |
| hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv | `4de8a1401ed31a5ba04288ebe36ae697e0304cbc44f05780a0a8cde93fb438f4` |

实际程序墙钟**0.05s**、峰RSS16528KiB、exit0；timeout20s、内存1GiB、CPU0–3/nice19/idle，当前有界程序预算只用了0.05/20s。该实际费用交A010仅计入E016/R007 static一次，不增加原1200s帽，不向旧A011任务重复记账；普通源码读取不虚记EDA费用。未做全面逐寄存器census、未展开层次、未核A007 TANH v3接入后的全联合资源、未跑RTL/原模型。完整model、动态层间/取消/tail闭合和最终资源合规继续NOT_RUN/OPEN。

## 16. D32事件仿真成本：单变量debug候选（A011，2026-10-23）

本轮由主控单独派发，与AT031正常QKV48→首head前缀并行，只读当前AT026生成TB/runner及其实际production closure；只追加本节与同前缀JSON，不改RTL/TB/runner，不运行EDA、模型、新gold或新agent，不重复TANH v3验证。研究问题是完整Encoder/原28+2的验证成本，当前无完整模型性能结论。本轮源码阅读已经结束。

### 16.1 实际源码事实与收敛理由

基线为`project/E016_m007_single_resource_parent/experiment_results/runs/R007/attempts/AT026_parent_normal_cost_checker_build/`（下称AT026），manifest SHA256=`60e479d1e8555beda0fc4e3e4bac470af2c6cbf55791cb5e7249e94e4ec7ad20`。`actual_orchestrator.py:107–110`及实际`work/build.sh:4`明确使用Vivado 2025.2：

```text
xelab work.m007_fullmodel_parent_tb --relax -debug typical -mt 4 --O3 -s m007_fullmodel_sim
```

**唯一候选：只把`-debug typical`改为`-debug off`。** 其余编译选项、全部HDL/TB/fixture字节、顶层、源次序、运行plusargs和嵌入checker保持一致。该项是减少仿真调试支持成本的假设，不是已证实的热点，更不是已测提速；本轮未调用xelab/help，`off`的当前安装CLI接受性尚未实际检验，没有观察到不支持的证据。不得从flag文本推定编译器实际删除了多少过程/对象。

共享FP核对解释了为何本轮不提出更大的生产修改：`laya_shared_fp256_v2.sv:55–60,98–100`已经用fire/inflight/pending/leaf-valid条件实现transaction-empty CE；`86–90,120–124`仍是256个mul与256个add真实叶子。`laya_fmul_rne_v1.sv:54–104`和`laya_fadd_rne_v1.sv:73–139`各有逐拍过程，CE有效时八级数据流水继续推进，气泡数据也可能传播。512个HDL时钟过程是源码事实，不等于XSim生成代码仍有512次独立调度。合并这些过程会改变叶子实例组织；逐级valid门控则需要证明四态/reset/CE停顿/held-credit与有效结果时序，而且在密集QKV时未必省事。本轮不据此实施或宣称收益。返回credit只在真实`result_valid`保存payload（`laya_fp_return_credit_v1.sv:29–44`），不能用跳过结果/credit处理来换速度。

实际生成`m007_fullmodel_parent_tb.sv:230–253`的W peer只在可更新响应时扫描每port的8个在途项，四port最多32次候选检查；`294–298`仅在真实matrix输出握手时比对1024bit向量及32lane原Attention映射。`291,299–301`保留A写/ACK/发布/债屏障及前缀终点断言。未发现每拍扫描整个QKV/gold tensor。`laya_m007_matrix_engine_v1.sv:164–235`确有较宽组合cone，部分256lane循环按有效math/bias/write条件执行；未有profiling证据可将成本归因于其中某个循环。A/W银行分别在`a_bank:8–10`、`w_bank:10–12`只按we/re读写；`laya_attention_storage_v1.sv:29–55,124–135`保留1024/256/64独立银行、碰撞检查与同步返回，不能以行为大数组替代其协议或资源。runner已启用O3，不能把“开启O3”当作新改进。

### 16.2 等价条件和最小可证伪A/B

主控实际消息接受此单变量方向并限定：**AT031结束后**才由A010按原R007余额实施；本次只交方案，不排队启动。A用AT026原snapshot，B从同一冻结编译源生成新snapshot，只改debug选项。B静态构建独立≤120s；RTL A/B各≤60s、两次合计≤120s。保持全项目唯一重工具锁、CPU0–3/nice19/idle、原static/RTL内存保护及400s恢复预留；费用按实计原R007，不增帽、不挪旧预算。构建未完成或依赖失败就是COST_STOP/基础设施未定，不能当作方法无效。

两次均为原B1、`MODE=8 / STOP_QKV_BLOCKS=1 / STOP_AFTER_HEAD=0`，相同DATA/ROPE/H/MATRIX内容和所有其它运行参数；复用现有独立gold，不能换成常数或简化模型。禁用debug必须保留所有被HDL静态层次引用的checker，不能移除断言、改gold、force状态、用DPI/行为算术替换叶子、减少FP lane或银行。正常运行使用原`-runall`及wall driver（runner:140–154）。构建时既有`get_scopes`诊断和后继`get_objects`审核若因off不可用，须如实记录诊断能力下降；不能伪造“与原展开对象census相同”。生产HDL及资源声明实例不变可由源身份确定，新的物理资源/布线结论仍未产生。

判定顺序：

1. 比对全部生产HDL、生成TB、fixture及checker SHA，唯一允许差分为构建参数debug；B合法构建且A/B均在60s内到达原`HARDWARE_AGENT_SIM_PASS M007_FULLMODEL_NORMAL_PREFIX`。任何缺marker、fatal、部分前缀或超时均不构成性能胜出。
2. 保留仿真cycle，去除绝对路径/墙钟等环境字段后比较全部既有语义日志；BEGIN、MATRIX_BEGIN、每次CHECKED、block0以及最终command_cycles均应完全相同。首block实际256个32F32输出=8192逐位值、坐标/身份及原Attention映射均由原checker核对。
3. 原checker覆盖的计数/终态必须相同：H4096、A写4096/ACK4096及真实发布/零债门、matrix命令1、runtime catalog2、QKV输出256、layer_starts0、done_valid0、`unfinished=1`。终点是首block输出接受，并非全部QKV退休；不能要求其伪装资源idle或父DONE。当前TB没有输出所有内部寄存器终值，原断言之外的内部状态逐位一致不得写成实测事实。
4. 从现有wall-events比较总runtime、BEGIN→block0、MATRIX_BEGIN→block0三段墙钟及`command_cycles/phase_wall_s`；主要比较MATRIX_BEGIN→block0，固定fixture/setup成本单列。只有数字/周期/已覆盖状态一致后，B墙钟较小才支持这**一对样本**的局部成本改善。相等/更慢反驳“本样本获得提速”，不改数值正确性判断。

可能反例：O3已消去相关debug成本；数学计算/宽组合cone支配时间；主机调度/缓存噪声使单对结果颠倒；off影响层次诊断或引发工具缺陷。即使一对结果有改善，也不外推16head、完整Encoder或30层总时长，不自动提高完整路径成本门。当前主控给出的QKV稳态1059拍约22.84s仅是主控转述的先验成本，本轮未重读原日志或复测；不得据此填新实验结果。

### 16.3 源身份、费用与状态

以下SHA为AT026冻结字节；共享FP、两种叶子、credit、storage和生成parent TB同时核对其manifest指向的当前生产文件，字节相同。matrix来自runner选定的冻结R006叶子闭包，不将它误写成新改版。

| AT026相对文件 | SHA256 |
|---|---|
| actual_orchestrator.py | `16b8d6ad26de827b969ff016ed2bdeebda219d0a6c0f6eba2cb2ee08fc38569c` |
| work/build.sh | `a01e8a225c56d8d6a4523135a4a454d449db76de7b323918afa593cccaceca67` |
| frozen/m007_fullmodel_parent_tb.sv | `070cca64e7ef06200697ee41ee1d19a2d63d5b20b388704d705869b0ef46716c` |
| frozen/laya_shared_fp256_v2.sv | `f4508add0e4fccd60314359a2a5fc0a8fa29530d209b92901e9bef5d413232d0` |
| frozen/laya_fmul_rne_v1.sv | `505a51a05cfecc8af3ce1fc913b330fb0a9b788b543ffb056d64b676d3c2fa52` |
| frozen/laya_fadd_rne_v1.sv | `e9f5e46bb8609816a97788942c897dc68c8759f2d748b0e2ce79d97d3f69c4a7` |
| frozen/laya_fp_return_credit_v1.sv | `0159ebe523441a1cbb4b34ea8cd3fbc2d9844bf11546d2af3e6dd00af16fc7bb` |
| frozen/laya_attention_storage_v1.sv | `c36d0089cebaa6dd90cb8dbe11a4c33d65224ee69fdc24f454dcfd08d464ad0b` |
| frozen/laya_m007_matrix_engine_v1.sv | `2147d041620a158cf7f2cddfd172b538e54ba78c5d340507a8c5ce08cfff069f` |
| frozen/laya_m007_a_bank_v1.sv | `9e0e0a24ea48c53c94a8f23bf34527d5aae6681bfec25c653ecf8d9bdb845354` |
| frozen/laya_m007_w_bank_v1.sv | `32df184b7221b64023039fc44de77629fe858b9f2f05c1dd48a03afe0ed43a86` |
| frozen/m007_fullmodel_wall_driver.py | `dcf83cd880280799467d17d564ab295c7bb7876aab2d3dfadefaadcff4a61dab` |

只读脚本`D32-A011-PERF-READ1..7`实际wall依次0.04、0.52、0.40、0.05、0.71、0.05、0.06s，累计**1.83/60s**，每次<20s、峰RSS87884KiB<1GiB，全部exit0；均CPU0–3/nice19/idle。此账独立于§15的0.05s和旧架构任务，不回填/挪用旧预算。只有源码/参数/整数边界得到核查，debug成本假设为**PROPOSED / A/B NOT_RUN**，实际提速UNKNOWN；完整Encoder/30层仍NOT_RUN。

写后仅解析owned JSON并检查本节唯一性/预算整数的`D32-A011-PERF-RECORDCHECK`实际0.04s、RSS12552KiB、exit0；含该记录检查，本轮程序总费用**1.87/60s**。JSON解析通过，无源码复读或新运行。

## 17. 原28+2按需W576供数：整数地址规格与有界原字节核查（A011，2026-10-23）

主控依据A010的 `R007/kind7_weight_supply_feasibility.json` 派发本次独立核查。只读既有三BO、原GGUF和8tensor fixture，追加本节及同前缀JSON；不写A010父/TB/R007证据、不做浮点运算、新gold、模型运行、EDA或全120打包。结果是**整数地址及有界字节样本通过；按需peer未由本任务实现/运行**。

### 17.1 当前来源与120项绑定

A010 feasibility SHA256为 `7d88bb0790bfba8b1c43a7344382361b00db95e59a82bb1fd0bd26077cd7f043`。原package为 `project/E002_Laya_HLS/experiment/build/model-q8-session-v2-actual-r2-20261010/`，manifest SHA为 `46bbd5abeeadc2d4305419d3129fd871aaeb04e962821ac4c6a6da957698018c`。实际读取的catalog binary SHA为 `bf187e0b2987b0fbc5e1951dee35b6b3219631dfabb9158c0b77f2b92b81dfe3`，records SHA为 `36455736a0e39bf63b37a63ceb46c95b2c60678cc50d23671cc1b676c36cd87c`；当前R007 `data/catalog.hex` 的128行按64B反序解码与该binary完全相同，hex SHA为 `4c685ba571f83ec6a9337e97adbedb41ac05f2f4a120d9e31e54b87be83f7971`。本轮核header字段、records SHA及尾部padding，没有新增CRC算法验证结论。

catalog第i项位于byte `256+64*i`，按little-endian `<8Q` 解为四port交错的base/span。名字由 `i=4*global_layer+role` 唯一绑定：global0..27依次qkv/wo/mlp_wi/mlp_wo，global28..29依次head_qkv/head_wo/head_fc1/head_fc2且local=global−28。已逐项核对120个名字、原Q8_0 type8、GGUF形状/字节数、三BO范围、同port不重叠地址和实际catalog字节，不依赖运行时“当前tensor”猜来源。六类形状数量为1024×3072:30、1024×1024:30、1024×5248:28、2624×1024:28、1024×4096:2、4096×1024:2。

### 17.2 唯一输出排列与AR身份冻结规格

令G=K/32，S在N5248时为82，其余为N/64；当前G精确为32、82、128。每tensor每port有效W576 span=`576*G*S`；descriptor之间的对齐gap不是payload。此规格以原TN8三BO的纯字节读取为生产TB路径，GGUF只作为独立地址交叉核对，不引入另一种数值定义。

**AR接受：** 仅在 `arvalid&&arready` 时，以物理port p和整个半开区间 `[ARADDR,ARADDR+64*(ARLEN+1))` 搜索恰好一个catalog descriptor。检查64B对齐、1..16beat、不跨4KiB、64bit加法无溢出、范围与文件长度、同(port,ID)无未完成旧请求。锁定该tensor的不可变descriptor索引/名字、K/N/G/S、q_base[2]/scale_base、port、local_offset=ARADDR−base[p]、beats=ARLEN+1、ID和beat索引b=0。若整个元数据表不可变，可保存索引并只读该固定项。绝不在R生成时重新读取父controller当前tensor/base，不能就近匹配gap或用layer0数据填其它层。

每个R beat完全由锁定身份计算：

```text
u = latched_local_offset + 64*b
r = u // 576
word = (u % 576) // 64             # 0..8
s = r // G
g = r % G
col(c) = 32*s + 16*(p%2) + c + (2624 if p>=2 else 0)   if N==5248
         64*s + 16*p + c                              otherwise
tile = col // 8
lane = col % 8
shard = tile % 2
qaddr = q_base[shard] + ((tile//2)*G+g)*256 + lane*32
saddr = scale_base + ((tile*G+g)*8+lane)*2
```

c=0..15。记录byte `32*c..32*c+31` 为w_q[shard]从qaddr读取的原32个Q字节；byte `512+2*c..513+2*c` 为w_scale从saddr读取的原2个F16 little-endian字节；byte544..575固定0。word0..7各载c=2*word与2*word+1的Q字节，word8低32B为16个scale、高32B为0。**`RDATA[8*j+:8]=record[64*word+j]`，j=0..63**。既有hex行恰为这64个文件字节反序后转hex；`$fread`直接读packed vector的装载次序不能假定与此相同，应读unsigned byte数组再显式切片。Q按8bit原位保存，不符号扩展；F16只复制16bit，不abs、不转real/shortreal、不重新量化。seek/read组合须不可被其它port改共享文件指针打断，或使用独立句柄；短读是明确错误，不能补零假装合法权重。

Wi的p0/p1对应前2624列中的当前32列，p2/p3对应后2624列中的当前32列；s81的四port覆盖前半2592..2623和后半5216..5247。普通64列连续公式不能用于Wi。K2624的G必须是82，不能右移6或按power-of-two group截断。

**R生命周期：** b仅随实际 `rvalid&&rready` 递增，rlast仅为 `b+1==beats`；valid被反压时rid/data/resp/last全保持。不同port/ID可交错，但每个接受请求都保留自己的来源直到最后R握手。当前W reader的busy/complete还持续到最后registered parser word实际消费（reader_v2:66–78）；peer发送完末R不等于生产reader已退休，不得强清其payload/transport_idle。前述是后继实施约束，本任务没有运行该协议。

### 17.3 已执行的有界交叉验证

fixture根为 `project/E012_m007_matrix_compute/experiment_results/runs/R002/attempts/AT002_full_local_prebias_fixtures/work/fixture/`。每tensor每port选完整record集合：`{0,1,G−1,G,G+1,(S//2)*G−1,(S//2)*G,(S−1)*G−1,(S−1)*G,R−2,R−1}`，R=G*S；再加入16次固定SHA256取样，种子 `D32-A011-WMAP-v1-20261023`，精确record列表存JSON。覆盖首/尾、首/中/末superblock边界和固定随机样本；每record检查16列、9word、scale位置及32B零padding。

| tensor | K/N | G/S | 每port字节 | 四port实际record样本 |
|---|---:|---:|---:|---:|
| head_fc1.0.weight | 1024/4096 | 32/64 | 1179648 | 108 |
| head_fc2.0.weight | 4096/1024 | 128/16 | 1179648 | 105 |
| head_qkv.0.weight | 1024/3072 | 32/48 | 884736 | 108 |
| head_wo.0.weight | 1024/1024 | 32/16 | 294912 | 105 |
| mlp_wi.0.weight | 1024/5248 | 32/82 | 1511424 | 107 |
| mlp_wo.0.weight | 2624/1024 | 82/16 | 755712 | 107 |
| qkv.0.weight | 1024/3072 | 32/48 | 884736 | 105 |
| wo.0.weight | 1024/1024 | 32/16 | 294912 | 105 |

共850条W576记录、489600B逐字节匹配；每条另对照TN8的32Q+2scale、原GGUF的34B及fixture `original_weight_q8.bin`，每个原来源实际核462400B。另核7650个既有hex word字节序。32个p*.bin完整SHA重新计算并与原fixture.json一致；这只是既有权重fixture身份检查，没有读取或生成浮点参考。

另从每tensor/port的首地址、两个superblock边界、尾部及4个固定随机位置，选不跨4KiB的至多4beat片段：256次地址区间唯一匹配、合计60608B，以**独立逐字节原GGUF坐标解码**比对既有W576，全部一致。跨superblock片段用于核寻址公式，不声称生产reader实际发出了这种跨block AR。采样转录SHA为 `000cbd4674f6136159690cf2e74ca4de60a7438ff78bab916395fdc8ca7d00c4`；可复跑的原整数脚本、精确样本及原工具输出完整保存在owned JSON `weight_supply32_integer`。

Q sign0/sign1字节分别219928/215272，含3688个零，负Q位已实际覆盖。**13600个F16 scale样本均sign0，实际负scale样本缺口保留**；公式直接复制两个原字节且无符号分支，但这不是sign1原数据动态覆盖。仅8tensor（Encoder0四种、Decision0四种）有fixture抽核；其它112项只核metadata/地址，不宣称其全部payload已逐字节验证。三BO与整GGUF的全文件SHA沿原manifest继承，本次未重新遍历其全文。

### 17.4 来源行号、后继反证和费用

整数排列来源 `project/E002_Laya_HLS/experiment/tools/m007_weight_pack.py:7–11,13–23,25–44,62,72–75`，SHA `c772ea0edbefcbbb2a9d391c586b70a8feae792068878e7d5cdeecc45c4976b8`；该原工具只声明四superblock，未把它误称为120tensor包。catalog编码/绑定来源 `tools/m007_model_catalog.py:92–116,168–211,221–239`，SHA `de0f253672b433ac8f85b4a6b39985b5f1790d368a1c22c1fed3b2d31be15be8`；未调用其浮点type展开函数。W reader来源 `vivado/module_design/hbm_loader_and_cache/rtl/laya_m007_w_reader_v2.sv:18–36,51–78`，SHA `4de8a1401ed31a5ba04288ebe36ae697e0304cbc44f05780a0a8cde93fb438f4`。三者路径均相对E002/experiment，详细来源身份/fixture SHA见JSON。

A010后继最小反证应固定既有原checker，换成按需读取后复验同8tensor；保持AR/R并交错四port/ID，在旧AR仍活跃时改变父当前descriptor，证实R仍读锁定来源；覆盖word7→scale word8→下record word0和G32/82/128边界、非法地址/gap/短读，以及真实reader末parser消费后退休。任一实际字节/身份/保持/退休不符即反驳相应实现；性能与RSS必须另实测。本次只给规格和已发生的整数证据，不授权或预填新RTL运行成本，更不签完整层/30层PASS。

本轮程序READ1..4与CHECK1..2实测wall分别0.05、0.49、0.06、0.05、2.08、0.18s，合计**2.91/60s**；每次≤20s/1GiB，CPU0–3/nice19/idle，峰RSS17972KiB，全部exit0。独立于§15/§16及其它旧预算，不重复计费或转余额。

owned记录写入及JSON解析检查 `D32-A011-WMAP-RECORD` 实测0.06s、RSS14084KiB、exit0；本轮含记录操作总费用**2.97/60s**。只改上述两份owned记录，未写A010证据或实现。
