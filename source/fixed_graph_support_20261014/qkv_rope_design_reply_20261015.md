# 真实QKV scratch→full RoPE：隐藏逐行接法与独立参考缺口

2026-10-15；A003→A001；M004/SM004/E004/R001。回复`m004-qkv-rope-minimal-next-design-20261015`。已追加[原架构文档“QKV scratch → Encoder0 full RoPE”](../fixed_graph_architecture_20261014.md)，[身份/字节/整数依据](qkv_rope_binding_20261015.json)、[脚本](check_qkv_rope_binding_20261015.py)及两份time收据齐备。**一套静态方案可交实施评判，但现有保存参考不足以签当前row1整行full RoPE逐位PASS。** 无新EDA/前向/gold/代理，未改E002/E004，未使用工程RTL余额。

**唯一复用路径。** 原单core/单writer包装层后接P2 `rope_probe/solution1/syn/verilog/rope_head.v`及其6份Verilog/2份FP Tcl，top SHA `17917421…`，生产C++ SHA `17b57824…`与原P2源清单相同。该叶子保存完整Check，x/cos/sin三路ap_memory同步读、双y写、ap_start/done、ap_return128（code[15:0]/detail[63:32]/bad[127:64]）。不选只保留code的`full_rope_cosim_top`，也不拉入旧full-owner/外部共享FP大top。原probe有CSim/综合；三例RTL cosim属于只返回code的兄弟wrapper，不能代签此完整Check顶层接入。完整Check ABI、精确首错和新适配器必须短测。

Encoder0按`layer%3==0`读full表；每token独立、Q/K共32head、每head `(i,i+32)`配对，四次乘和减/加各自F32舍入、逐步finite，V不变。预检d顺序及每pair低半先于高半的Check位置保持，不FMA、不重新计算三角函数。表源为当前model AUX offsets617728/880128，各262400B、SHA `fe68cb1c…/e2c58174…`；每token各取256B，共512B复用32head。row1使用s=1，不是0或task_id；已核全部64位型、half布局及s127末边界。当前包两半相同不允许删掉对i+32表值的独立读取。

**真实读写/容量。** 用现`t4_w_reader_port_v1` SCALE_MODE0按每head load256B真实读QKV0/1（SHA `478aeddd…`）；用`t4_aux_bias_reader_v1`两次256B读表（`58f36989…`），与core AUX端口只在core真实债零后分时，目的保持到load_done。原reader各带4096/1024B FIFO，容量必须实报，不宣称仅768B总缓冲。新增head256B和cos/sin512B；head x/y可原地复用，叶子内saved256B保留，不加整tensorRAM。叶子无输出ready，必须预备本地RAM吸收双y写；成功ap_done＋64输出覆盖完整才交writer。

复用现160B writer，线性mode、每head目的base=原QKV地址/跨度256、8个32B tile→4次单beat AW/W/B→flush撤下且债零再换head/口。地址仍`shard=h&1; off=((((p*2+b)*8+h/2)*1024+s)*64+d)*4`，B1的b0、p仅0/1，V和norm无RoPE写。每行Q/K读写各8192B、128个512R＋128个单beat写事务，另32个AUX128R；32head/1024pair/4096mul/2048add-sub/256writer tiles/32flush。64B基址下读按4KiB分段需32–64个scratch AR；不能默认256B对齐。每行两表2–4个AUX AR。全128行16384个Q/K beat域内唯一、合法且与V不交叉已整数枚举；BO仍QKV各12MiB/norm8MiB，布局证明不是动态生产覆盖。

**必要合同变化建议。** tensor_begin锁存`rope_enable`，旧caller0维持rev13 RAW-only。启用时同FSM顺序：真实RAW末B成功→core行真实release/consume done→row_written来源位→读表/QK→leaf→原地写→所有B退休→row_final位→outer done。core保持原接口；wrapper必须扩FSM、读口、AUX/单writer mux及内容/epoch输出，建议4bit phase13=ROPE。冻结result_mode/row/id贯穿尾部。不并行接下一行或FFN，不复制matrix/LN/Q；RoPE producer只能是真实scratch，保存中间值只作checker。

RAW-only保留原全128位/债零/最后outer done消费后发布。RoPE模式从begin就禁止对外RAW发布，row_written仅表示“RAW曾成功写完”，新增128bit row_final；全128 RAW＋FINAL位、无failed、全部债及最后outer done退休后才发布FINAL。两行只置两位，不能填其余126。建议begin预留RAW e/FINAL e+1两QKV epoch、禁止回绕；后续行producer仍以e校验，norm保持e，最终两个QKV描述符为e+1。release或failed discard均消耗预留e+1，下一begin e+2；RAW-only旧单epoch规则不变。**这改变rev13接口语义，必须由A001集中采用后才实施，本研究未改变合同。** 完整FINAL后消费者release、partial/failed真债零后显式discard，FFN运行不得清failed或冒充发布。

读错必须等真实RLAST、FIFO消费/丢弃和load_done；收到64项或out_last不能忽略迟到的load_error。写错保持已展示AW/W直到真实握手/B，等debt_zero而非成功flush；部分外存无回滚，tensor sticky failed，停止新head，完成仅一次。数值错保留原head-local Check，当前head部分y不写；跨row改为行调度后，旧full-controller head优先的全请求首先遇错顺序**尚不等价**，不能宣称保留了该全局时序错误次序。FFN/QKV既有协议优先仍保持，正式外部位置映射由主控定。

共同reset只覆盖DUT控制和受控AXI peer。所选FP IP Tcl `has_aresetn=false`，原封装reset未接IP，不能宣称全部算术位清零；新adapter须清活动/覆盖，拒绝旧done/y成为可见写，并在实际MUL发射后共同reset及新head恢复短测。AR后、AW-only/W-only/待B共同reset只签所测隔离，不扩成总线独立reset或全128恢复。

**参考绑定结论。** 同request3/gen1/B1S128的task2_real_fixture_20保存完整pre-QKV row0/row1（SHA `d4d1b006…/18079bd9…`）、norm（`f166773b…/cf4dd5c6…`）、scatter均成立；steps_u32x6是matrix步骤，非RoPE。原attention_fixture的B2 full_final_qkv确为独立计算，但输入是native enc0_qkv。当前与旧输入row0 Q/K/V位型差820/836/842，row1差818/813/824；两行无完整Q/K head同输入，因此其FINAL不能当这次整行gold。原四个full leaf参考仅s0h0和s127h15的Q/K。已列证据目录无当前输入的full RoPE步骤/FINAL；未新算补空白，P1不混入。

能严格复用的非退化子集为row1 **39对、78个FINAL元素**：每pair两个输入都逐bit等于旧RAW，full表完全相同，独立旧FINAL的两个字节偏移已列于`rows[1].matching_QK_pairs`。这是保存字节的可定位子集，不是新gold，不能签余1970个Q/K输出。row0表全1/正0且2048个当前Q/K全为normal非零，可按原公式以保存pre字节核恒等；只签位置0退化情况。V/norm仍可全量核不变。

**有限主场景。** 同runtime真实row0 cold→RAW写成功→RoPE完整真实读写，随后row1 warm同链正常；保留原LN/Q/PS/final checker，完整核scratch来源地址/字节、s1表与pair、全部返回/写事务、row0恒等、row1上述78项、V/norm及邻行哨兵。最后head末B有限阻塞时FINAL位/outer done不得先行，两行结束不发布tensor。原AT204的row1末norm错误B不能照搬，否则根本没有合法row1 RoPE输入。该主场景只签真实两行连接/传输及明确数值子集，不能签整行full RoPE gold覆盖。

局部同adapter/leaf/reader/writer用旧s127h15 Q/K保存输入/表/expected、非对称表/Inf验叶子与最后pair，不冒充真实row127；一条实际RRESP错误和一条末head AW/W后错误B验排空/失败/一次完成/discard，有限AR/R/AW/W/B停顿必须命中。全128位图peer仅签元数据，不代签128生产。Attention仍缺真实128行K/V、命令/mask和FINAL/skip消费；token独立不消除全Attention依赖。

**成本和身份边界。** AT204 guard1404.050676294s、982160KiB、child0/null；global77639/127513/321332不是命令latency。AT193714.517070s/FAIL、AT1951100.280453s/timeout保留，不据字节比或150MHz推新墙钟。新两行尾部新增64次leaf、256scratch R＋256AW/W/B＋64AUX R，IP/model展开和背压尾部需实测pilot；probe的9–1027cycle是HLS估算，三例兄弟cosim42s非新顶层成本。完整资源/Fmax未知。当前core/writer与AT204相同，wrapper已由e5dde5cc变9c55ae10；旧PASS不升级新控制身份。

本次39项成立检查、82项身份；初次1.17s/28920KiB、补核匹配pair后0.13s/29008KiB，脚本累计1.30s，各20s/1GiB帽、CPU0–3/nice19/idle、exit0，原初次JSON/time保留；交互读取UNKNOWN。完整方案及源链接在原文，本轮研究准备收束，正式接口/参考缺口处置/预算由A001决定，A002独占实现。
