# FFR0：单加法叶子的四行双源残差 RTL

D-M004-FFN-RESIDUAL-RTL-01；M004/SM005/E005/R001；2026-10-14。依据[FFREF0审核](../results/measurement_first_FFREF0_review_20261014.md)与AT050独立参考。A002唯一实现及工具负责人，A001集中审核；沿既有完整加速器授权与测量优先合同执行，普通实现、编译和有因修正连续推进，无逐步用户审批。当前新结果NOT_RUN。

## 目标和单一路线

先取得一个可复算的末ADD_RESIDUAL局部RTL基线：AT050原四行skip和Down作为明确声明的两个外部只读源，经真实AXI读、单个F32加法叶子、真实AXI写到另一HIDDEN bank，逐位对AT050原enc0末输出；验证事务债务、写覆盖、最后B、响应保持和一次实际消费。本阶段不重跑AT049长链，不把两源fixture当成已运行的Attention或Down producer，也不扩建通用source hub/生产executor。

本次选用已生成且有定向RTL证据的 **`tanh_libm_leaf_fp_add_bits`**，不选FFREF0初稿的Xilinx Single/Add IP。项目内来源为：

`project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/tanh_libm_round1_02/hls_project/solution1/syn/verilog/tanh_libm_leaf_fp_add_bits.v`

103443B，SHA `d1370d290aac70f8ceed10b04c6451381f34d4cc23b088eebdaf1fd0f4e3b474`，与原`rtl_manifest.json`对应项一致。它是独立`ap_clk/ap_rst/ap_start/ap_done/ap_idle/ap_ready/a/b/ap_return`叶子，原报告Instance=N/A；新static仍须核其实际依赖闭包。保留原生成Verilog和版权；只实例化此叶子，不拖入完整tanh top、乘除或旧D2-I控制。工程可按本项目既有模块source/rtl/tb组织方式引入冻结副本，但必须保留来源和逐SHA对应，不改生成算术，不新跑HLS，不替换另一个核。

选择依据是该实现已有有限binary32/RNE、零符号和次正规边界样本证据，且本任务先要数值和事务基线。它不是11拍rate1的Xilinx流水；不得继承其延迟/吞吐，也不得以旧HLS资源/时序估计当本封装物理结论。新的实际启动到返回分布、忙周期和停顿必须实测。Xilinx两份XCI只是生成目录/校验和不同、算术参数相同，现有证据没有判它数值失败；本轮不另测第二算术候选。

## 数值、任务和外部来源

冻结并直接复用AT050的三个16384B文件，不重跑参考、不改gold：

| 内容 | AT050 output文件 | SHA-256 |
| --- | --- | --- |
| LN前HIDDEN/skip | enc0_skip_rows4.f32.bin | 5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9 |
| Down | enc0_down_rows4.f32.bin | 4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0 |
| enc0末残差gold | enc0_enc0_out_rows4.f32.bin | c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a |

数学仍为原图F32 `add(hidden,down)`、无bias；任务字段按原schema保留`ADD_RESIDUAL=0x62`、stage2/layer0、B1/S128、batch0/row0、rows4、D/length1024、TOKEN、bias_id65535，生产src0=TMP/Down、src1=HIDDEN/skip、dst=另一bank HIDDEN。加法叶子输入a接skip、b接Down，避免把任务字段顺序与原图运算顺序混淆。请求request3/generation1与完整model/numeric/layout/build来源逐项冻结，沿AT049共同数学载荷和诊断canonical身份；AT050原ABI build与诊断生成build的差异继续注明，不改tag宣称完整生产身份兼容。

允许以局部描述符承载上述字段，不启动完整命令门户。DUT必须实际锁存并检查所声明的合法子集、源/目标Ref和范围；仅TB先行检查不计DUT拒绝证据。新诊断Ref明确为skip HIDDEN/bank0/epoch1、Down TMP/bank1/epoch2、dst HIDDEN/bank1/epoch2，不能说这些epoch来自AT049同runtime。外部源由测试环境预装并声明不可变；局部双源锁/读债和目标完成有效位属于本封装，不能冒作真实生产query/grant/高水位、全键owner发布或完整源lease证明。后续同runtime接链必须以真实producer来源替换该边界。

有限输入/结果规则、RNE、signed zero和次正规处理不变。新封装遇非有限操作数或非有限结果不得成功发布，按原错误语义报告并有界退休已发事务；不因本次4096样本全是正规数而省略检查。该约束不等于本阶段完成所有IEEE输入或故障恢复矩阵。

## 实际地址、存储和搬运

采用下列诊断BO映射，保留原完整容量，启动前以范围加法无溢出/无别名检查冻结实际地址表：

| 区域 | 物理地址 | BO容量及四行有效范围 |
| --- | --- | --- |
| skip HIDDEN bank0 | STATE0 base `0x300000000` + 0 | STATE0 16920576B；前16384B只读 |
| Down TMP bank1 | STATE1 base `0x310000000` + `0x800000` | STATE1 16919104B；该位置16384B只读 |
| 新HIDDEN bank1 | STATE1 base `0x310000000` + 0 | 前16384B可写，不能覆盖skip或TMP |

不是将AT049的诊断Down地址`0x100040000`追认为TMP；本轮源在新声明映射上预装，后继长链映射另审。不得缩BO容量使描述符通过。允许稀疏字节存储模型，但必须按实际AR/AW地址访问同一权威存储，任何未分配读写和越界均显式失败，不能返回gold或默认零蒙混过关。

两源各实际读取4096 F32=16384B=256个AXI512有效R beat，总512R；目的覆盖16384B=256个满WSTRB有效W beat。工程按有界缓冲选择burst长度和有限outstanding，冻结理由、实际容量及回压约束，AR/AW/B burst数由真实握手计数，不预签4burst。禁止跨4KiB的burst、假B、在TB中完成加法回灌、将KB1 TN8/PS writer直接冒作通用残差writer。新搬运/打包RTL可以单独实现；新增缓存/寄存器bits、端口和复用限制必须列出，不能隐含第二矩阵引擎或大容量镜像。

加法叶子只留一个在途运算：先保留返回存储空间，再`ap_start`；两个操作数保持到真实`ap_done`，返回只捕获一次，下一项等待返回槽可用。按真实握手处理可变延迟，不硬编码11拍；`ap_ready`不代替完成。该生成叶子无CE，不添加派生门控时钟、不用反复reset模拟背压；在途核照常推进，包装层在输出阻塞时仍须捕获结果并保持，容量不足时停止新发起。AXI所有valid/payload在ready低时保持，AR/R与AW/W/B独立计债。完成必须等所有4096结果、覆盖、最后真实B及全部读写债退休；无下一轮受理穿透活动响应。两源锁在最后读取退休后可释放，必须打印确切边沿；输出局部完成有效位只在最后B/全部数值正常后置位。

本地保护范围至少为skip、TMP、目的各64KiB窗口。full结束逐字节重读三个窗口：两源前16KiB与原输入一致且全窗口未写，目的前16KiB与独立gold/written逐字节一致，各邻接48KiB哨兵保持；共196608B。完整STATE0/1未扫则明确保留缺口。所有AXI地址/长度/WSTRB在运行中逐笔检查，使未分配地址不能被局部扫区遗漏掩盖。

## 验证顺序和有界停止

1. 新AT冻结完整实现闭包、生成叶子、三个fixture、独立52例、TB/runner/guard、真实地址/上下文及工具身份。先做编译/elaborate，核一叶子实例、无新HLS/浮点IP、已知reset极性和启动握手。每次仿真spawn前核真实cwd、全部运行文件/plusargs及SHA；缺文件/错SHA在spawn前拒绝，不能再出现AT048类型部署缺口。
2. 同一新算术包装的有限定向验证：复用`tanh_libm_round1_02/cpu/add_directed.mem`，1404B/SHA `b3d36f14bd9884b48c1856ff97cd0c4f9ec1fdc69cbd0a7d3b8f6d287942fe3e`，52例/每例a,b,native binary32 RNE gold；原生成器/FE_TONEAREST来源同时冻结。可独立小TB驱动同一包装，不计第二候选。四种signed zero、反号抵消、次正规/正规边界及原52例逐位对照；旧PASS不替代本封装。加入输入间歇、核忙时下游阻塞、ap_done边沿输出阻塞及解除后的不丢不重，统计accepted=returned=consumed。只在idle做reset并验证无幽灵返回，不扩取消/恢复合同。若任何算术差异，保留首错及本阶段停止，不改gold、生成叶子或换核续跑。
3. ≤120s真实单行pilot：同DUT、同原数据第一行，真正双源读、算、写/最后B及响应消费。打印AR/R、运算返回、W/B和每行完成的真实进展；状态快照不能续semantic watchdog。按本次完整单行计量和固定开销给保守四行成本估计，同时核内存；不能相加AT049或旧XCI墙钟。证据不足或预测超过原帽则COST_STOP交付，不强开full。
4. 准入后四行冷full：一次初始reset，所有4096原F32 bit逐位gold；分别施加确定性读延迟、AR/AW/W反压、B延迟。最后W后至少13拍不返回最后B，断言不得提前成功；最终响应ready低至少7拍，完整上下文/状态/计数稳定，之后一次真实消费。覆盖在途结果遇输出阻塞和解除、两源读债、无越界、全局部保护终扫。另有限错误描述符定向检查错身份/op、目的与旧HIDDEN同bank、越界或别名，每例一次拒绝且零AXI；正常全链样本与拒绝探针周期分别计量。有限非有限数据拒绝仅测首元素NaN/有限溢出所得非有限各一例，实读后报告错误并退休，无成功发布；不称为完整错误恢复。

全过程一个实现候选，最多两轮有因包装/接线/TB/runner修正（初版加两修正版；无第三修正）。每版实际static/pilot/full各至多一次；未变已通过步骤按SHA复用，修正后只重验受影响范围，但新full必须有对应成本和启动包检查。每个失败、guard触发及语义Fatal原样保留，child0不能覆盖语义失败。达到上界、算术叶子不适用、成本不能准入或出现需改变本合同的共享接口时集中交付，A002不自行加候选/加帽/启动长链。准备核对和修正是既有授权内步骤，不等待逐次批准。

## 证据和延后义务

交付原receipt/log/manifest、逐SHA/bytes核验、实际policy、三摘要和模块design/results；各测试范围分别PASS/FAIL/COST_STOP/NOT_RUN。周期报告包括冷TB、cfg→首AR/R、算术starts/done与延迟分布、末R、首末AW/W/B、响应首次有效/实际消费、源锁释放、目标有效和互斥阶段分解；接口停顿可重叠，不能与互斥阶段混加。工具墙钟/RSS单列；不将假定150MHz、旧HLS估计或局部周期当部署性能、资源或完整请求收益。

代码仅E002/experiment，新证据E005/R001；历史baseline、AT049/AT050及旧失败不写回。全项目最多一重工具，CPU0–3/nice19/idle、MemAvailable>192GiB，static≤24GiB/1800s、RTL≤8GiB/3600s/40Mcycles、pilot≤120s、真实语义停滞120s。无新agent、HLS、OOC、P&R或上板；G仅OOC余2338.224019s，5172s组合不重启。

本阶段是双外部源的残差局部RTL，不是LN→Q→Wi→G→Q→Down→residual同runtime。后者、实际skip存续与两源生产query/lease/发布、普通多窗口Q/L、Attention/WO硬件上游、完整28+2层/122矩阵、13BO请求/恢复、联合资源与物理时序仍开放；整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup继续停排，M003/M004不关闭。
