# 下一阶段计划：CPU Embedding→FPGA LayerNorm，数值与硬件计算性能优先

**2026-10-10 新优化路线已批准执行：**用户审核[完整算力与流水吞吐优化 mission](compute_throughput_optimization.md)后明确要求“可以开始执行优化任务”。当前Astra/xhigh落实T0，Sol/xhigh按依赖承担T1/T2及后续任务；动态结果见[新阶段结果表](../results/compute_throughput_optimization_20261010/stage_results.md)。本文件及下述授权状态继续记录既有阶段，旧结果和未关闭事项保留；新优化的职责、性能目标及执行边界以新mission为准。

状态：**AUTHORIZED / IN_PROGRESS — 当前授权执行合同**。制定：2026-10-10，GPT-6 Astra / xhigh；依据用户“支持 开始任务”开始下述三个任务并按依赖连续推进。接口、准入、owner、错误与计数以[本阶段详细设计](../results/cpu_embedding_q8_validation_20261010/contract/design.md)补齐；只维护[一张动态结果表](../results/cpu_embedding_q8_validation_20261010/stage_results.md)。不修改旧阶段合同、冻结证据及Laya顶层索引，不复用M002；C1及板卡平台验证不因本次授权自动启动。

**2026-10-10优先级修订：按用户最新要求，先使硬件计算性能与推理准确度获得完整、可信的证据并解决实测瓶颈，暂停下一轮整体OOC、P&R及专项时序优化。** 必要的HLS→RTL/IP生成、功能静态编译、RTL仿真、普通实现修复和受影响回归继续；既有等价rank修复保留并完成数值/首错回归。历史OOC/HLS资源和时序失败按原身份保留，不能要求先消除这些失败才推进下述数值/周期性能工作。后续重新安排物理实现时再恢复整体综合/时序验证，本次不自动启动。

当前准确度分三层判定：相对真实GGUF独立oracle的数值正确性、完整请求的最终决策一致性、带独立标签的数据集准确率。完整图CSim、完整前端RTL、隔离ACT/QKV RTL、真实producer连续链和整网RTL分别记录实际覆盖；前一项不能替代后一项。保持严格F32/既有逐位或LN误差标准、完整模型层数与物理shape；不引入新容差、改gold或用缩减模型换取速度。现有四请求与检查点可证明各自身份的数值/最终结果覆盖，不能作为数据集准确率；未完成完整请求解码核对的后端不得宣称端到端决策一致。本阶段不凭空指定新数据集、标签或准确率门槛，未测项明确未验证。

性能首先以同一RTL身份的真实周期、有效MAC/cycle、LOAD/quant/dot/restore/PS/bias/output及响应退休、trace-off吞吐与停顿为依据；仿真墙时仅用于运行成本。既有QKV稳态一group/clock目标和完整请求50ms目标保留，不新造局部延迟指标。**数值通过而吞吐目标未达到、50ms预算仍有缺口时，只能关闭相应数值覆盖，不能称性能整改完成。** 150MHz仅用于明确标注假设的周期换算；功能仿真时钟、HLS估计或旧OOC均不证明实达Fmax。

按用户最新分工，**只有输入token Embedding移到服务器CPU；LayerNorm仍在FPGA上计算。**

| 位置 | 负责的计算 |
| --- | --- |
| 服务器CPU | 根据实际token查真实Q8 embedding表，按原数值规则反量化，生成原 `embedding_raw` FP32；准备请求并同步输入 |
| FPGA | 导入/验证CPU raw输入；执行LN_EMB，以及后续LN_ATTN、LN_FFN、LN_FINAL、LN_MARKER、Encoder/Decision、scorer/ACT。内部EMB_TYPE也继续留在FPGA |

流程：**实际tokens＋真实GGUF → CPU raw FP32 → XRT同步到STATE0/HBM → FPGA校验输入并建立合法owner → 加载gamma → 完整LN_EMB → 后续Encoder。** 主目标先关闭这个完整B1/S128混合前端，再验证可容纳、可持续供数的Q8路径，接入真实QKV→RoPE→Attention。混合前端PASS不代表完整Encoder、Decision或整网PASS。当前依据是[已完成集中验收](../results/encoder_decision_validation_20261009/final_acceptance.md)和[任务入口](task.md)；旧全硬件前端证据保持原范围。

## 1. 闭合CPU Embedding→FPGA LN的完整128行冷前端

**CPU真实生产与独立参考。** 首例固定 `B1_from_b0_S128`，request_id3/generation1、hidden1024，所有128行含原padding token均逐行查表，不能只算72/94个有效token后补零。CPU从原真实GGUF的token embedding Q8_0块读取half scale和signed INT8，按原half→F32及独立F32乘法得到raw；保留原token/scale/q合法性和有限性检查，不引入低精度计算或FMA。CPU实现不能把冻结oracle、CSim输出或DUT dump当输入生产器；由独立参考实现从同一GGUF/实际tokens重算，并与冻结 `embedding_raw` 位型交叉核对，记录GGUF、请求、CPU实现与所产raw哈希。原 `embedding_norm` 仍作为独立LN结果gold。

**BO选择：复用STATE0承载raw，复用IO尾部承载必需描述符，不新增大payload BO。** 沿用生产STATE0/STATE1容量及HIDDEN地址 `4*((batch*1024+row)*1024+col)`：row stride4096B、batch stride4194304B。B1/S128有效payload为524288B（512KiB），位于STATE0 offset0；B2有效payload共1MiB，但分成offset0和4194304的两段512KiB，地址跨度4.5MiB，不能紧密拼成连续1MiB。B2仅定义兼容布局，不是本阶段正式RTL例。其余区域保留sentinel。

CPU写完raw后先完成对应STATE0区间的XRT TO_DEVICE同步，再同步请求/描述符，最后启动新kernel；BO在请求终态前由该请求独占，Host不得再次写raw。描述符不能代替实际同步完成事件。无板卡时用执行CPU生产代码的离线Host harness和真实外部内存端点验证该交接顺序，不宣称PCIe/XRT实测已经通过。

**新入口与描述符。** 新薄入口暂名 `laya_cpu_embedding_ln_chain(io, aux, state0, state1, observed)`，四个生产BO＋只写诊断口；任务1期间STATE0、IO、AUX均受只读保护，输出只到STATE1/observed，不写完整LYRS成功帧。原LYRQ v1请求帧及token/mask/marker/qtype仍保留，新增必需的 `CPU_EMBED_RAW_V1` 输入profile：IO offset20480（0x5000）放256B小端描述符，与请求区[0,16384)及结果保留区[16384,20480)不重叠，IO总容量仍32768B。新top禁止缺描述符时退回EMB_TOKEN路径，旧top不被当成可接受该profile的接口。

| 描述符偏移 | 固定语义 |
| --- | --- |
| 0–15 | magic `LYER`；u16 version=1、u16 bytes=256；u32 mode=1（CPU raw）；u32 flags=0 |
| 16–95 | u64 request_id、u64 generation；model/numeric/layout/build各16B，与当前请求及包逐字节匹配 |
| 96–127 | u16 B/S/hidden/dtype，hidden=1024、dtype=1（LE F32）；u32 source_selector=0（固定STATE0）、u32 reserved=0；u64 base_offset=0；u32 row_stride=4096、u32 batch_stride=4194304 |
| 128–159 | u64 payload_bytes=`B*S*4096`；u64 extent_bytes=`(B-1)*4194304+S*4096`；u32 request_frame_bytes；u32 request_crc32c、u32 raw_crc32c、u32 descriptor_crc32c |
| 160–255 | 全零保留字节；未知版本、模式、dtype或非零保留位拒绝 |

CRC32C统一使用反射多项式0x82F63B78、初值/末异或0xffffffff；请求CRC覆盖实际LYRQ帧，raw CRC按batch/row/col顺序覆盖有效F32小端字节、不含batch间隙，描述符CRC覆盖256B且计算时自身字段置零。CRC用于绑定本次传输和内容，不替代CPU embedding数值证明。

**FPGA准入、owner和LN消费。** 新parse复用原请求格式、模型头和会话单调性规则，将描述符版本、身份、描述符/请求CRC、形状、精确stride/长度、BO范围及地址计算溢出检查纳入同一个准入提交点；不能先接受请求再忽略描述符错误。结构合法后，构造真实 `HIDDEN bank0/region0/stage1/layer255/batch255/TOKEN/row0=0/rows=S/width1024/F32`，通过生产 `full_claim_owner`进入FILL，cold epoch=1。导入例程从STATE0逐个读取全部有效raw，检查有限性并复算raw CRC；校验通过后按实际已读范围调用 `full_cover_owner`，再 `full_publish_owner`。这是明确的外部CPU producer注册/内容验证，不是TB force READY；不得在覆盖前直接写valid/coverage。坏raw CRC/非有限raw属于已接受请求的执行失败，禁止LN，保留首因并通过真实cleanup撤销未完成owner；不把它混作尚未准入的描述符拒绝。

随后共享生产后半段顺序为 `load_gamma(1) → norm(LN_EMB) → release旧hidden → checkpoint(embedding_norm)`，不把LayerNorm移到CPU或改变其算术。FPGA再从合法READY的HIDDEN0读取全部128行，写并发布HIDDEN1。导入扫描和LN读取是两次不同消费，分别记录覆盖，不能用导入的读计数替代LN实际读。后续新混合完整graph也使用同一后半段；原全硬件入口可保留，但两种profile不能混算结果。

**验收与计数。** 新入口CPU/严格CSim、HLS生成、实际端口/owner结构核查、重新编译和冷RTL依次完成，复用已补齐字段的工作TB并按新入口适配。CPU raw及上传后STATE0各131072 F32与独立gold逐位一致；RTL norm全部131072项有限且满足原误差线，报告逐位相同数、首差、max_abs/max_rel。原17任务期望撤销：该FPGA计算段为**1次gamma加载＋8次LN＝9个算子任务，EMB_TOKEN=0**；导入/CRC扫描固定为非operator动作，单独记录动作和传输，不增算子任务。CPU查表和PCIe同步不能记成FPGA EMB_TOKEN。3次owner claim、完整spec/identity/coverage以及失败/恢复计数已在详细设计中一次冻结，不凭旧日志直接套用。

首个正式冷例必须检查全部owner/spec/identity高低位、coverage/readers、HIDDEN1最终发布、HIDDEN0释放、raw/IO/AUX输入保护和完整映射sentinel；STATE0末笔**LN消费阶段**输入R与STATE1末笔输出B的hold实际命中并退休（不能误命中导入扫描同一地址）。首次ap_done即检查全部四个生产口及observed口的物理AXI和adapter债务为零。退出0、完整自检PASS、无ERROR/FATAL或保护触发；仍不宣称暖reset或B2 RTL通过。

**新身份与预算。** 新入口、parse/profile、CPU producer及生产helper变化须纳入新source/build与模型包身份；tensor物理stride和model/numeric语义不变，layout身份按实际规范preimage重新核定，不能手填旧tag。旧71532完整CSim/HLS及全硬件前端只复用明确未变的算子依据，不能写成新混合入口PASS。独立gold不改，新包/新请求按新身份绑定。

本任务正式冷RTL预算已由[详细设计§5.1](../results/cpu_embedding_q8_validation_20261010/contract/design.md#51-首pilot后的正式冷rtl预算2026-10-10一次细化)按新版调度/pilot落实为4300s、40M clocks、8GiB；不重新扩帽。已通过的cold03复位释放→首次done为31,158,417 cycles，含launch、AXI-Lite和测试台反压，尚非精确AP接受→done。按**假设**150MHz为207.7ms，已是50ms的4.15倍；现有采样给出导入约9.69–9.71M、LN首算术→128行约19.37–19.38M（含块流转）、末行→norm写全约1.38–1.40M cycles。这是必须解决的前端周期/搬运瓶颈，不能因数值逐位通过而关闭性能问题，也不能当作纯LN下界或板上测量。先复用[已有阶段观察](../results/cpu_embedding_q8_validation_20261010/attempts/cpu_front_rtl_03/phase_observations.json)定位；下一次受影响功能运行用被动事件计数细化，不为填表原样重复整例。改进保持CPU只算token Embedding、全部LN在FPGA及原数值/owner合同。CPU生成、设备输入同步、kernel和完整Host端到端时间分别报告，最终性能计入CPU Embedding和传输成本。

## 2. 闭合最小Q8原型的数值、真实数据路径与周期性能

依赖任务1形成稳定前端基线；该原型独立于生产核，不先综合或仿真整个串行Encoder。依据：fe067整网Q8约5.28–5.87×10¹¹ cycles，完整HLS估计LUT1810065、超过器件1303680；实际13口均32-bit。已有TM4/TN8原型的1024个INT8乘法器各61 LUT、0 DSP，整数乘法合计62464 LUT，不能将候选DSP packing或512-bit配置当成实际效果。

选择 **TM1/TN8、GS32** 作为首个整改验证单元：256个实际signed INT8乘法及8个32项精确整数归约，连接真实scale恢复、按group顺序的FP32 PS累加、bias、输出和响应退休。首先采用一乘法一DSP的明确映射意图，验证实际网表；不先引入有符号DSP packing，也不复制整个TM4存储/控制系统。目标是在N3072等PS访问间隔足够的场景持续每拍一个GS32输出组issue；N2依真实反馈间距显式等待，不能取消依赖。8转换、16独立F32乘法、8加法的服务需求以及PS反馈间距必须由同一实现的真实II/停顿证据支持，不能用整数单元II代替完整路径II。

同一原型加入一条实际512-bit读写路径和生产布局的pack/unpack，覆盖对齐、尾字节、4KiB拆分及反压，记录有效字节/beat和真实B响应。保持原Q8/scale/激活字节语义；这是隔离原型接口，不声称已把生产13口或HBM平台拓宽。缓存容量、bank端口、结果在途容量和复用方式按该小原型一次确定，计入资源，不只测无访存的算术峰值。

固定验证次序：signed INT8边界与完整32项dot → 真实ACT K256/N2（反馈/尾列）→ 真实Encoder layer0 QKV K1024/N3072、完整一行后扩至四行。每个矩阵例保持完整K/N；行数范围准确标明，不能称128行QKV通过。输入取真实模型/冻结独立参考节点，权重从原GGUF独立逆重排；q/half scale、dot、恢复term、逐group PS、bias及最终输出分别比对。

当前通过标准：同一源码/生成身份完成真实BO LOAD→quant→dot/restore/PS→bias→完整输出/B退休，ACT与QKV一/四行的独立全lane数值、反压、tag/owner及恢复全部正确；分别记录数值/协议通过与周期性能结论。性能从真实命令接受→首次done计数，覆盖LOAD、RUN及同权重复用，给出trace-off的完整延迟、稳态issue间隔、有效MAC/cycle和加载/量化/恢复/反馈/输出停顿，trace on/off数值一致。细分算术服务允许重叠，阶段区间不得重复相加；全部有效输出、最后tile和真实B仍是完成条件。达到既有QKV一group/clock目标才记该吞吐目标通过，未达到就定位瓶颈并继续合同内修复；准确度不抵扣性能缺口。历史资源/时序用于保留已知风险，新整体OOC和时序收敛不再是本轮功能/性能验证或Task3准入条件，也不以局部峰值宣布整网50ms可行。

**C1仍暂停。** 只规划核查已有显式时钟integer/tree、reserved-store及writer资料是否可作为上述小原型的复用来源；不自动执行C1已有v3/v4脚本，也不继承其未验证的18-cycle/F21、固定返回或流水PASS。若后续执行明确选择复用，由Astra在该任务启动合同中一次界定实际接入范围与接口；现阶段不恢复完整C1。

### 2.1 从流水服务能力判断性能（用户追加方向）

保留单请求50ms延迟目标，同时评估流水吞吐；两者分别判定，不以吞吐替代延迟。对每个层级分开记录首次结果延迟、填充、稳态完成间隔和排空。group issue/commit、矩阵RUN done、完整请求结果与业务decision不是同一个计数单位：只有真实完整请求/解码结果才能报告实测requests/s或decisions/s。有限连续命令样本给出真实完成间隔及样本数，不伪称跨请求流水已实现。

| 层级 | 当前真实结构/共享限制 | 本轮测量与下一实现 |
| --- | --- | --- |
| group内部 | 一套256个INT8乘法/8棵树、8路严格FP恢复；多tile可在途，PS每tile仍有反馈依赖 | 当前Q35按同tag测issue→return→commit；无输出阻塞窗口局部II1已测通过，最后group输出反压另判，不任意翻倍队列 |
| bias/output | ACT有独立bias加且一次只持有一tile；QKV实际bias_kind=0。当前writer整tile并行pack与每口独立64B TX，下一pack填充可与前一事务重叠，仍仅一笔未B事务 | 按§6.7/§6.9的真实B/债务结果区分内部重叠与固定B_HOLD9压力；实测末组反压保留，板上B服务率未测 |
| 行/矩阵/命令 | 单W bank集合、单A8上下文、单行PS；LOAD、全部输入量化、linear依序。rows4按r/g/tile发射，前行tile已commit并复制到输出寄存器后，下一行可按tile忙位规则复用PS，和前行输出尾部重叠；无第二PS或命令上下文 | 测真实行边界交接及同一LOAD后的合法连续RUN，报告冷LOAD、resident-W命令完成间隔、控制/诊断空隙；不假定LOAD/quant与compute或跨命令已重叠 |
| 层/请求/整网 | 当前生产FullRuntime只有一套inputs/owners/cache/current_weight及当前KV/head/score上下文，controller依次调用任务并检查完成；Q8原型未包含Attention并发调度 | 共享引擎上所有层的工作量累加，尚无跨层/跨请求流水证据。若后续加入独立引擎、双缓冲或多请求，须同时定义独立owner/request/epoch/lease/credit、资源/端口、调度与错误隔离，不能仅复制阶段框图 |

共享资源的稳态必要条件为 `request_interval >= max_r(每请求在资源r上的总工作量 / 资源r的有效服务率)`；同一Q8引擎在所有矩阵/层上的工作必须先求和。只在独立资源、buffer/端口、owner和重叠时间线已证明时，阶段重叠才可按瓶颈约束；当前串行控制的实际完成间隔仍按实测时间线计算，不能直接取LOAD/quant/compute/output最大值。pipeline只提高利用率，不自动增加阵列数或带宽。

复用[已审完整图工作量](../results/attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md)的真实B1/S128 Q8共47,160,754,688 MAC：TM1/TN8/GS32即使II1且假设150MHz，256 MAC/issue也只有38.4 GMAC/s，单个共享引擎需184,221,698 cycles，即至少1.22814465s/Q8-B1服务，持续吞吐至多约0.814236 B1/s；尚未含Attention、LN、Host与搬运。这是理想条件下界/上界，不是板上实测，也不把流水深度当多份阵列。若用20个B1请求/s作为50ms倒数的**吞吐预算示例**，仅Q8就需943.21509376 GMAC/s、约6288.100625有效MAC/clock@假设150MHz；它不是新增硬性吞吐门槛。当前256-MAC共享结构已不能独自满足整网50ms，最终架构必须联合并行服务量、复用和实际访存/恢复能力评估。

### 2.2 本轮最小可运行的流水整改范围

详细设计§6.6–§6.8的Q35、并行tile pack/独立TX和合法连续RUN已经实现，本轮集中限定接受见[合同§6.9](../results/cpu_embedding_q8_validation_20261010/contract/design.md)。数学、外部ABI、D4和真实退休保持；credit88、当前writer109和bridge91短自检、ACT103/QKV1 off104连续两RUN、QKV4 off107及QKV1 on108完整BO检查均在各自身份通过。队列估算只新增约2.8kbit逻辑状态/metadata，两口TX约1.28kbit，未增加W/A/PS双缓存或算术阵列；实际映射及物理频率待后续验证。受影响组合覆盖不等于当前全部trace/shape组合重跑，更不是整个Task2或阶段最终PASS。

旧QKV1 trace-off79的LOAD488555、RUN24585 TB cycles及6122次result-credit stall保持原身份；该计数包含最后group下游阻塞，不能解释成统一“32issue+16gap”。已完成QKV4 trace-off84限定数值/物理检查PASS，RUN88079、49152 issues占75089-cycle窗口、25937次result-credit stall；全部49152个issue→commit的F为min34/max491/mean48.037272，尚无容量不足与下游阻塞的逐拍独立归因。无阻塞issue→commit按当前寄存路径、ACT81和84最小值为34 cycles，credit下一拍可用；Q35仅消除该固定占用不足，最终writer/B阻塞仍须独立量得。84的旧行192笔B尚只完成190笔时已出现下一行commit，故本轮明确沿用逐tile安全交接，纠正原“无跨行重叠”的表述；这不证明跨命令或跨请求流水。QKV LOAD另有98304次scale校验、HLS内循环4cycles/项约393216cycles；这不是AXI卡死。LOAD/量化/单tile bias、诊断控制及前端207.7ms均保留为独立瓶颈，不能以此局部流水修改关闭整网性能整改。79/81/84按原身份复用，不为新统计原样重开长跑；隔离正例通过不代替未测负例、实际producer链或整阶段PASS。

## 3. 按真实producer顺序接入 QKV→RoPE→Attention

准入改为任务1完整CPU Embedding→FPGA LN数值/owner正确、任务2完整ACT/QKV声明范围的数值/协议正确，并已取得trace-off全路径周期/瓶颈与有限运行成本依据；在原设计入口绑定新实现身份及真实producer/runtime接口。整体OOC/物理时序不再前置，但隔离fixture的epoch1不能替代生产owner：消费实际FPGA LN输出及runtime中的完整identity/spec/epoch/coverage/lease，禁止预置READY。已知性能未达目标可保留明确缺口开展有限连接验证，不能据此宣布性能整改完成。先完成FPGA真实LN输出→Encoder layer0 QKV的K1024/N3072、全部128行及双shard发布，再验证RoPE前后owner与全部16 heads，随后连接真实KV装载→QK→mask/softmax→AV。保持B1/S128和全部选定query/head任务；最终该子链称完整通过时必须覆盖所声明的全部范围。

独立参考可作为局部算子输入，但不能在声明的连接链内部预置本应由DUT生产的QKV、RoPE或Attention中间tensor。若受成本限制分段运行，明确每段输入、完整输出和owner边界；分段重放不等于同一runtime连续链PASS。旧预置Attention测试只按旧范围复用。

§2.2本轮实测中，QKV1无输出阻塞的11904个非末组issue已达1.000cycle间隔，局部算术稳态PASS；固定B_HOLD9压力下完整issue窗口仍有860个末组相关credit间隙，QKV4为3710，完整路径仍TARGET_NOT_MET。这些不是板上HBM或无反压性能，也不能判为全部本征损失。wrapper接受至首次done为ACT3471、QKV1 off18933、QKV4 off65463、QKV1 on20797cycles；该口径含参数配置/启动/轮询/排空，不是HLS内部AP周期。同权两RUN的完成间隔为ACT 3473、QKV1 18935cycles，各含2拍控制间隙；只代表矩阵命令。与旧同口径TB段相比，QKV一/四行RUN分别改善约23.0%/25.7%，冷LOAD仍488555。107观测三次行边界各159cycles输出尾部重叠，保留单PS逐tile安全复用。

本轮已完成[完整图流水联合预算重新核算](../results/cpu_embedding_q8_validation_20261010/pipeline_budget.md)，机器结果由[复算脚本](../tools/recalculate_pipeline_budget.py)生成。固定当前v4真实模型、B1/S128、全部122张Q8、28 Encoder/2 Decision、16 marker；CPU仅token Embedding，全部LN仍在FPGA。50ms首请求目标与完成间隔明确分开，20 B1/s只是示例，并列10/20/40 B1/s与100/150/200MHz敏感性。当前TM1/TN8按真实task≤16及尾列为184,221,704理想issue cycles；整数树当前40 DSP/通道加R0恢复8，应按48 DSP/通道直扩。全模型11,542,592项含padding的scale校验按既有4拍需307.802ms，单W下连q/scale payload主体约355.897ms（均假设150MHz）；HBM常驻不能删除这段LOAD。跨请求独立引擎不消除共享Q8总工作，加宽/双引擎亦须共用9024 DSP、960 URAM及4032 BRAM18，不把shell、非线性和buffer视作免费。现有测量与条件预算均不构成50ms或板卡吞吐PASS。

只选择一个下一最小候选：**保持TM1/TN8、单W和接口，将scale合法性扫描改为一项/拍**；本轮仅定义候选，未启动实现或硬件运行。候选保留padded n→g首错顺序、±0/正subnormal语义、scale先于bias的首因、失败不发布W及owner/epoch/债务；后续需独立half位型/首错短验证及原完整K/N的ACT/QKV受影响回归。理论checker收益约230.852ms/全模型，但改后LOAD主体仍125.045ms，单Q8算术仍1.228s，不能据此关闭整网性能缺口。详细范围见预算§9与[原合同§7](../results/cpu_embedding_q8_validation_20261010/contract/design.md#7-task3-依赖与集中出口)。此次仅只读复核和短计算，4GiB/120s帽，无新RTL/HLS/OOC/P&R/长仿真；真实producer连接继续保留下述范围与成本准入，不因局部PASS自动启动。

启动RTL前用新生成调度和120s以内pilot核算整个固定范围；只在现有有限帽内预计可完成时继续。若完整128行/16-head链仍超帽，报告NOT_RUN_COST，继续已定义且独立可完成的算子/接口验证，不缩形状冒充完整连接、不直接试跑串行完整Encoder或整网。通过标准仍包括独立全输出、双shard/epoch/lease/shape/地址、生产者到消费者数据、最后响应、哨兵及首次done债务；数值与协议任何一项失败都不关闭该链。

## 阶段出口与后续目标

依赖任务2/3的真实系数。按同一候选身份更新CPU token Embedding、输入同步和FPGA全部LayerNorm、28 Encoder、2 Decision、EMB_TYPE、scorer/ACT的周期、访存、恢复和算术联合预算：串行段相加，只有已证明重叠的部分才能取最大值，并计入初始化、排空和Host。保留历史资源风险，不为完成预算启动新整体综合，也不把未测块的估计标成实测。不得把旧fe067完整HLS资源、71532全硬件前端结果及另一原型II拼成新混合核。生产源码变化后重新绑定build，按新profile和实际BO清单执行受影响的完整四请求持久CSim回归：每份请求的raw都由真实CPU producer生成，保留原独立全图gold、gamma故障首因/零结果及随后恢复要求；正常/失败task计数沿用详细设计§3的18887/37142及gamma故障1任务。导入协议新增失败另列；已通过且依赖未变的v4完整CSim按原身份复用。只为实际功能验证所需的范围生成新版RTL，不把新完整HLS、资源或时序表征设为本轮必做出口。

阶段末在原结果表作一次集中判断：逐项关闭实际通过的数值/协议覆盖，独立判定既有吞吐目标与50ms预算的差距、前端瓶颈是否得到解决、真实连续链覆盖和整网剩余成本。证据测全可以形成验收/阻塞结论，**不等于性能整改完成**；任何未达指标、未测端到端决策或数据集准确率继续明确保留。CPU接管token查表不取消任何FPGA LayerNorm，也不自动迁移EMB_TYPE。后续物理实现与最终平台目标仍需同身份完整请求功能/恢复、包含shell余量的资源、P&R/实达频率、XRT/HBM/PCIe和板上数值/性能，本轮暂停不会将这些项目改判通过。

50ms保持原完整请求目标，当前无板卡不得宣称达标；按假设150MHz等价7.5M cycles也只是必要预算，所有串行段共享该预算，另计CPU处理、同步与Host成本。[已有A6000报告](../../../results/laya_gpu_inference_benchmark_20261005.md)的两题常驻SDK P50/P95为25.047/25.224ms，采用另一英文模型、BF16 autocast、B2/S94和K_pad3；它与当前Q8_0、S128、16候选槽并不同条件，既不把50ms改成25ms新目标，也不直接算加速比或推理质量收益。最终对照须在运行前统一模型/请求、B/S/padding、候选、数值质量、冷/常驻和计时统计口径；kernel及包含CPU/传输/后处理的完整Host请求分别报告，不在看到结果后选择有利口径。

## 数值、资源和执行规则

原model/numeric语义、真实GGUF及独立gold来源保持；新输入profile及源码/接口改变须绑定实际layout/build与运行closure，旧制品冻结。保留相邻二叉归约、独立F32运算、原R0恢复和group累加顺序；不得FMA/重结合/FTZ补偿或改gold迎合DUT。真实FP轨迹触及已知119例中的33例边界差异时，保存首个基本运算差异和真实输入，按FAIL定位；前端最终norm容差不能覆盖基本算术违约。需改变数值规则时由Astra集中修订受影响合同，不能以“误差小”跳过。

| 工作 | 计划owned RSS上限 | 单次墙钟/周期硬帽 |
| --- | --- | --- |
| 轻量身份与材料核对 | 4GiB | 120s |
| CPU/CSim编译及运行 | 16GiB | 每进程1800s |
| 必要HLS→RTL/IP生成（为功能验证） | 24GiB | 3600s |
| RTL静态编译/展开 | 24GiB | 每尝试1800s；下一轮整体OOC/P&R/专项时序优化暂停 |
| 任务1新混合入口pilot | 8GiB | ≤120s，并记录实际周期与语义进度 |
| 任务1完整CPU Embedding→FPGA LN冷例RTL | 8GiB | 已按详细设计§5.1确定4300s且40M clocks；不为新增性能统计原样重复已通过例 |
| 任务2/3其他有限RTL | 8GiB | 3600s且40M clocks；实际pilot须支持可完成 |

全Laya代理树同时最多一个重工具；CPU0–3、nice19、idle I/O，owned aggregate RSS每0.2s采样，MemAvailable始终严格大于192GiB，只管理本任务进程。首次120s记录功能pilot，之后每60s保存实际任务/算术循环/AXI进度、剩余工作、分阶段ETA及RSS；连续120s没有真实语义进度，或连续两个间隔至少60s的有效样本预测超现有墙钟/周期帽，即停止留证。纯算术期间不能仅凭AXI静止判停。保护触发后不自动加帽原样重跑；普通实现/TB/脚本修复有新可检验原因时，可在同一固定合同内重跑受影响范围。

本文件及所链接详细设计构成当前阶段执行授权，已经一次记录范围、接口、独立参考、硬帽和停止条件。Sol / **xhigh** 连续完成授权范围内实现、功能编译、仿真、定位、普通修复及受影响回归，不恢复逐次“源码→编译→运行”审批；Astra / xhigh负责实质架构/数值变更和阶段末一次集中验收。Task1沿用已确定4300s/40M帽，Task2/3沿用各自有限帽；不能因性能优先无界扩跑，预算不支持则明确分段覆盖与NOT_RUN_COST。结果复用现有项目体系，新阶段只有一张动态结果表，各次机器日志/manifest保留，不新建逐次人工审核包，也不改Laya顶层索引。
