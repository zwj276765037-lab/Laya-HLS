# M006：CPU–FPGA协同高性能推理实现

revision: 4 / 2026-10-17
architecture_decision: D-M006-QUANTIFIED-B-ARCHITECTURE-04
document_state: quantified_engineering_contract
review_state: statically_checked_requirements_not_measured
execution_state: paused
verdict: unassessed
performance_evidence: NOT_RUN
owner: A001主控；恢复后复用A002工程与A003研究角色
implementation_root: project/E002_Laya_HLS/experiment

[Goal v7](../../goal/goal.md)定义完整系统目标。本合同按用户“确切的模块性能要求、计算要求、带宽要求”固定建设参数、验收条件和周期上限；[机读要求表](performance_requirements.json)保存同一数值。[修订3原字节](contract_v3_before_quantified_requirements_20261017.md)保留。

**本轮只完成设计文档和整数静态计算。工程、CPU/GPU基准、模型、EDA、gold生成仍暂停；未唤醒A002/A003，未授予新的实验预算。以下工程要求不是实测或预测。未达到要求记性能FAIL/未通过，不能降低频率、吞吐或周期帽后宣称原要求完成。**

## 1. 固定架构、范围与总验收要求

当前建设方案固定为 **B：CPU输入与完整Attention/尾部，FPGA驻留hidden及主线LN、QKV/WO、residual、完整FFN、final LN/type add与gather**。C仅作为有条件的独立扩展，不因本合同改为全FPGA主线。

| 项目 | 固定算法量或工程要求 | 状态 |
| --- | --- | --- |
| 模型 | B1/S128；28 Encoder＋2 Decision；16 scorer槽；final18=16 masked logits＋2 ACT logits | 固定算法量 |
| Q8 | 主线120矩阵＋CPU尾部2矩阵；group32及原数值规则 | 固定算法量 |
| 主线矩阵工作 | 47,143,976,960 MAC；1,473,249,280个恢复group；量化输入22,249,472元素；输出39,518,208 F32元素 | 静态核算 |
| 核心时钟 | **300,000,000Hz**；单一算术/控制域，平台域经标准CDC | 要求，NOT_RUN |
| 整数阵列 | 两个Tm8/Tn16/Pk32 tile按M并联；合Tm16/Tn16/Pk32；**8192 MAC/cycle、II=1** | 要求，NOT_RUN |
| 120矩阵累计 | 完整服务周期和 **≤6,880,256cycle=22.934186667ms**，持续 **≥2.0TMAC/s**；各shape还须分别满足第4节上限 | 要求，NOT_RUN |
| B请求时延 | 热请求 **P50≤60ms、P95≤65ms**；一个请求上下文、无batch合并、完整输入到final18可读 | 要求，NOT_RUN |
| B持续吞吐 | 同一单请求上下文串行连续运行 **≥15QPS**，包含CPU/PCIe/设备/尾部 | 要求，NOT_RUN |
| 对标 | 本地**单张RTX A6000**；同模型、输入、数值口径，分别比较P50/P95/QPS | 未测；工程毫秒帽不表示胜GPU |
| CPU | Intel Xeon Gold 6248R，4个固定逻辑CPU（CPU0–3），记录实际SMT/NUMA映射；不得借用GPU计算生产Attention | 身份已只读核查；性能NOT_RUN |
| 物理平台 | 单U55C；综合前固定真实part/speed grade、官方shell/XRT/工具/XDC身份 | 无板卡，NOT_RUN |

本合同全部带宽使用十进制GB/s；MiB=2²⁰B。逻辑payload、AXI实际字节、片上银行带宽分别计量。U55C标称460GB/s、9024 DSP、约43MB片上RAM，以及A6000标称768GB/s均不是可直接代入的可达性能。

完整图按以下固定顺序执行：

1. CPU Embedding→带gamma的initial LN→设备H0。Encoder第0层直接用该结果，不额外执行pre-Attention LN。
2. 每个Encoder：其余层pre-LN→QKV→CPU RoPE/完整Attention→WO→与原hidden相加→pre-FFN LN→Wi→GEGLU→Q→Down→残差。layer%3==0采用full，其余原sliding；完整S128都计算。
3. 板内带gamma的final LN→原type embedding广播相加。
4. 两个Decision：pre-LN→带bias QKV→CPU完整Attention（无RoPE/sliding）→带bias WO→残差→LN→带bias FC1→ReLU→Q→带bias FC2→残差。
5. FPGA gather全部16槽原始hidden和独立raw hidden[0]，输出68KiB；CPU marker LN、scorer baked bias、独立scorer bias、GELU、全部候选统计和ACT，最后发布final18。ACT不能改用归一化CLS。

CPU只返回context，设备保有唯一权威hidden/skip。Wi/G/Decision宽中间量不跨PCIe。主线120矩阵共享同一生产引擎，诊断TB和整图调用同一模块。

## 2. 计量合同与可剔除等待

所有硬件周期均为同一300MHz时钟的`end_cycle - accepted_cycle`，不混用inclusive计数。命令接受前的输入、地址、版本和输出范围必须合法且完整。下列边界固定：

- `MATRIX_ACCEPT`：合法完整S128矩阵命令握手，F32源在片上可读、模型HBM布局与驻留系数有效，但**本服务W片上cache冷**；开始计量。`MATRIX_RETIRE`：全部输出在约定片上sink被真实写入、bias与Check完成、算术返回和PS债清零。包含A量化、首W块加载、全部预取、整数/恢复、输出退休、内部仲裁与填排；不含前置LN、生产Attention或外部PCIe。
- `VECTOR_ACCEPT/RETIRE`、`FFN_ACCEPT/RETIRE`、`STAGE_ACCEPT/B_DONE`分别测完整向量、融合FFN和真实HBM staging。单个服务各有下表上限，不能只报告稳态lane数。
- 无注入停顿的性能例：片上源/sink满足第3–7节接口，HBM满足第5节服务曲线；所有内部ready下降、银行冲突、缓存未命中、信用不足、输出等待都计入上限。
- 人为注入的外部源饥饿、测试sink反压、平台HBM超出服务曲线分别记录`external_stall_cycles`，只用于模块功能/归一化分析；原始总周期仍保留。生产系统和实板性能**不得扣除**真实DMA、Host、CPU、HBM等待。HBM不达要求须判IO性能未通过，不能把所有停顿标external后宣称系统通过。
- 不重叠的互斥时间段组成请求关键路径；并发预取、矩阵/G和量化仅按实际事件计一次。CPU与设备的串行依赖相加，不能直接取最大值。

## 3. 阵列、恢复、PS与量化的固定微架构

### 3.1 每拍接口与反馈

| 模块/接口 | 固定要求 | 首结果/延迟、存储和credit |
| --- | --- | --- |
| A供数 | 每拍16行×32个INT8＝512B＋16个F16 scale；II=1；153.6GB/s整数读 | A0/A1各557056B；每slot 16个row-lane Q银行，每行组256bit，另16个16bit scale银行；每bank同步1R+1W |
| W供数 | 每拍16列×32个INT8＝512B＋16个F16 scale，两个tile广播；II=1 | W当前group保持8个M16窗口；读取与加载用不同slot；禁止每M16重读HBM |
| dot32 | 每拍256个精确I32 dot；8192 INT8 MAC/cycle；II=1 | dot pipeline≤16cycle；group32独立输出，不跨group做整数累加 |
| 恢复 | 每拍256次I32→F32、256次sa×sw、256次scale_product×dot、256次有序F32加法；II=1 | 从dot发射到PS提交（包括适用final bias）≤64cycle；不将独立F32舍入合为FMA |
| PS读/写 | 各256 F32/cycle＝各1024B/cycle＝各307.2GB/s；读写并行 | 4个N16交错；同输出复访32cycle；**PS读→加法→写回→可读总反馈≤24cycle** |
| 结果退休 | 持续32 F32/cycle＝128B/cycle＝38.4GB/s；II=1 | 每个4-Ntile块8192个输出≤256cycle排出；与下一块计算重叠 |
| Q输入/输出 | 每拍32 F32；**每拍完成1个group32**，输出32 INT8＋1 F16 scale＝34B；完整group II=1 | 首个完整group接收至对应Q写入≤128cycle；tensor总周期≤128K/32＋128＝4K＋128 |

固定调度为`4-Ntile超块 → group升序 → 四个Ntile → 每tile八个M16窗口`。每个超块计算周期恰为K，4个Ntile共64输出列；Wi超块按前半连续32列与对应后半32列组成，而不是原相邻64列。每输出group严格0..K/32−1。

PS采用**两套32KiB上下文**交替：每套覆盖128×64 F32；各有512个逻辑bank（16 row lane×2个Ntile parity×16 column lane），每bank深16、1R+1W。运算每拍访问其中256个bank；退休从上一套按同一row的32连续列读取，避免一个bank同拍读取两个Ntile。当前套算术写回与上一套32-lane退休无端口冲突。首group用+0，不依赖整块清零。

最后group可能连续32拍返回256个F32/拍，先真实写入该PS上下文；不能接到仅32-lane的无缓冲口。最后返回完成后以32-lane退休。两套PS加独立tag阻止下一次复用覆盖未消费结果；每套在相隔2K拍前须释放。dot/restore在途≤64个256-lane向量token；返回缓冲/信用容量128个向量，发射前预留，禁止靠不可反压FP叶子停钟。每个token携带request/generation、PS slot、超块/Ntile/group/Mwindow及最后group标识；最终回执不靠固定延时猜测。

### 3.2 量化与格式特化

Q每拍接收同一row完整32元素，采用32-lane abs/max树、`amax/127`与`1/d_full`两个分别舍入的F32流水、32-lane乘法/round-away-from-zero和range检查。两个除法级各须II=1、延迟≤32cycle；其余归约、转换、写入包含在128cycle总延迟内。保留≥128个group在途状态，64B/group元数据与32元素数据按真实流水资源计入，输出1group/拍不得退化为逐组等待除法。

q使用**未舍入为F16的F32 d_full倒数**；缓存scale才转F16。零组、微小值、F16溢出、非有限值和[-127,127]检查按原参考。A cache最大K4096时为128×128×34=557056B；Encoder G为128×82×34=356864B。G流由8-lane输出收齐32元素后提交Q，不能提前用局部amax。

精确INT8共享W打包是本版资源要求的一部分：两个row乘积共享DSP操作数，阵列DSP≤4096。必须证明符号修正与每段溢出界；不能把两个18bit通道直接累加完整32项。接口仍输出I32 dot，最坏绝对值≤524288，转换F32精确。

恢复的第一个乘法采用有限F16格式特化：scale significand最多11bit，乘积最多22bit，非零范围[2^-48,2^32)，F32可精确表示。因此以11×11整数乘、指数/正规化/符号组装实现与原`F32(sa)*F32(sw)`逐位等价，保留subnormal、±0和非法域检查。后续乘dot及加PS仍为原F32舍入。以上优化须有独立整数证明、边界逐位测试及实际映射；未验证前不写PASS。

## 4. 完整矩阵服务的周期硬帽

下表全部M=128；QKV/WO各有28个无bias Encoder调用和2个带bias Decision调用。FC1/FC2均带bias；Wi/Down无bias。每行上限对每个完整调用成立；**2.0TMAC/s是120次累计要求，不强迫WO等小N形状单独达到2.0。**

| shape | K | N | 次数 | MAC/次 | dot cycle | Q cycle上限 | 首W超块cycle上限 | 完整服务cycle上限 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| QKV | 1024 | 3072 | 30 | 402653184 | 49152 | 4224 | 1024 | **57344** |
| WO | 1024 | 1024 | 30 | 134217728 | 16384 | 4224 | 1024 | **22528** |
| Wi | 1024 | 5248 | 28 | 687865856 | 83968 | 4224 | 1024 | **92160** |
| Down | 2624 | 1024 | 28 | 343932928 | 41984 | 10624 | 2224 | **56576** |
| FC1 | 1024 | 4096 | 2 | 536870912 | 65536 | 4224 | 1024 | **73728** |
| FC2 | 4096 | 1024 | 2 | 536870912 | 65536 | 16512 | 3328 | **86016** |

固定结构的静态调度上界核算为：

`C_structure = 128*K*N/8192 + (4K+128) + (3K/4+256) + 64 + 256 + 128`。

这里故意将完整Q与首W加载串行计入：64为最后算术返回，256为最后超块输出退休，128为命令检查/启动和最终Check/提交合计。中间超块的W预取和上一PS退休必须与下一超块真实重叠；否则不满足此结构。六类核算值依次为54848、22080、89664、55280、71232、85824cycle，全部低于对应硬帽；累计6,680,384cycle。硬帽的剩余容量吸收实际控制/银行过渡，但不能转成未定义的无限外部等待。

首32个F32输出的上限统一为`Q(K)+W0(K)+K+192`：K1024为6464cycle，K2624为15664cycle，K4096为24128cycle；起点同MATRIX_ACCEPT。不得只验证首输出而跳过完整N/S128退休。

120次周期帽之和为`28×(57344+22528+92160+56576)+2×(57344+22528+73728+86016)=6,880,256`，对应2.055620TMAC/s。2.0TMAC/s的独立累计限值为7,071,596cycle；本版同时执行更紧的逐shape及总和上限。此算式证明要求在所列接口条件下没有静态周期矛盾，不证明物理实现已达到。

## 5. 权重布局、HBM实际带宽与流量

权重持久重排为`超块 → group → 四个N16记录`。每记录固定**576B=512B INT8＋32B F16 scales＋32B零padding**，64B对齐；所有矩阵N均为64的倍数，Wi按GEGLU两半配对重排，无假列。矩阵起点4KiB对齐；本组形状矩阵总长度本身是4KiB整数倍，不另加页padding。9个64B beat组成一个记录，记录跨4KiB时仅拆burst，不补空洞。重排保留原字节的可逆映射及模型/布局校验身份。

| 权重项目 | 硬要求/静态字节 |
| --- | ---: |
| 主线原Q8＋scale | 391331840B |
| 每请求真实W读取（含padding） | **414351360B**；不得仍报391MB |
| padding | 23019520B |
| bias | 73728B；初始化后驻留片上系数区，不在每请求W流量重复计 |
| 每4-Ntile超块HBM字节 | `4×K/32×576=72K` |
| 每W slot片上有效payload | 最大K4096：278528B；双slot合557056B，padding在reader中丢弃 |
| 平均供数最低算术需求 | 72B/cycle＝21.6GB/s（含padding）；无padding时68B/cycle＝20.4GB/s |
| **HBM权重子系统验收** | **4个独立512bit逻辑AXI读口，聚合≥96B/core-cycle＝28.8GB/s**，单方向 |

W reader固定每口最多8个在途burst、每burst最多16拍×64B；全局最多32个burst、32768B返回信用，另有记录拼装空间，总reader缓冲≤48KiB。AR始终遵守4KiB边界；对应RLAST/RRESP实收后退休信用。W cache按16列分银行，Q bank为256bit、scale bank为16bit，每slot最大深512；两个slot物理隔离读写。

带宽要求用整个已排队超块到**cache最后写入可读**的服务曲线验收：`C_W(B)≤256+ceil(B/96)`，B为真实576B记录字节；256拍包含请求/返回启动、拼装与末写，不再额外附加未计开销。每个K1024/2624/4096超块分别≤1024/2224/3328cycle，均≤下一超块计算的K周期；双缓冲因此足以连续供数。须逐超块及完整矩阵验证，不能用一次大连续读的平均GB/s代替。若平台做不到，IO性能未通过。

固定使用逻辑HBM端口0–3供W，另两个512bit端口分别供QKV/尾部staging与输入/context staging；映射到实际不同伪通道和平台端口，禁止将逻辑独立当作已证明物理隔离。staging两条方向各要求≥16GB/s有效payload；按`C_stage(B)≤256+ceil(3B/160)`验收，包含真实末B/最后读到片上写入。平台CDC、DMA争用和实际物理通道须在同版本联合测试中覆盖。

首W超块每个矩阵都按冷片上cache计入第4节；禁止用前一服务提前加载掩盖该独立服务指标。整图可以依法预取，但实际请求只计一次区间。初始化CPU重排、初次PCIe写HBM、热请求HBM→片上分开计量；初始化完成须读回/校验布局与coeff身份。热路径不允许新增HBM激活spill；确需spill时仍须满足原周期/流量帽，否则性能未通过并修订受影响设计，不能把spill成本隐去。

## 6. 融合FFN、非线性与向量模块

### 6.1 FFN与生产计时

Wi超块是128×32前半及128×32后半，共32KiB F32，采用两块配对缓冲共64KiB。PS以32 F32/拍按row/group写配对缓冲；GEGLU每拍读两半各8 F32，输出8 F32，保留原GELU/tanh每一步舍入。配对块在最后输入消费者退出后释放，不能等同于最后matrix写入即释放。

| 模块 | 完整工作与接口要求 | 首结果/完整任务硬帽 |
| --- | --- | --- |
| GEGLU | 全图9404416元素；8元素/cycle、II=1；两输入各32B/cycle、输出32B/cycle | 首个合法8元素输入至首输出≤256cycle；一个4096元素配对块≤768cycle；全S128/K2624独立流测试≤42240cycle（输入持续） |
| G→Q | 每4拍收齐一个32元素group，Q本体仍能1group/拍 | 完整G cache356864B；最后G输入后Q退休≤128cycle |
| ReLU | 每Decision 524288元素；32元素/cycle、II=1 | 首结果≤8cycle；完整S128×4096独立流≤16392cycle |
| Encoder完整FFN | FP32 LN结果→Q/Wi/G/Q/Down→全部F32输出 | **≤92160+1280+56576=150016cycle/层** |
| Decision完整FFN | FP32 LN结果→Q/FC1+bias/ReLU/Q/FC2+bias→输出 | **≤73728+512+86016=160256cycle/层** |

Encoder额外1280cycle定义为Wi MATRIX_RETIRE至完整G/Q cache valid的实际尾段；Decision额外512cycle同理。生产Down/FC2接收完整Q cache后启动，bypass重复输入量化，仍受对应独立矩阵上限约束。量化由生产者计时一次；不能再给Down/FC2增加一笔同数据Q时间。第4节独立F32矩阵测试仍必须运行完整Q，不能用prequant例代签该要求。

矩阵/G在Wi期间重叠；整图预算只加入28×1280＋2×512=36864cycle的FFN尾段，不再额外加9404416/8。局部G独立流周期只验该模块，不与已重叠Wi重复相加。配对双缓冲、G8-lane独立算术资源及Q输出credit必须同时存在，不能同时声称复用矩阵FP单元并与其并行。

### 6.2 LN、residual、type add与gather

板端主线LN固定60次S128（Encoder 55＋final 1＋Decision 4），共7680行/7864320元素；CPU initial LN和marker LN另计。

LN采用32-F32向量接口、**4个行上下文**。每上下文1024 F32 raw与1024 F32 delta，共8KiB；合32KiB。raw在第一遍捕获，后续从本地重读；不同上下文有独立bank，不能让下一行读hidden与上一行读delta抢同一端口。原1024邻接树可按连续32项子树再组合32个子树，配对关系逐层一致；不改成顺序和、Welford或E[x²]−E[x]²。

| LN阶段 | 固定操作/数据遍历 | 延迟硬帽 |
| --- | --- | ---: |
| P1 | 32拍读完整row并缓存；原mean树；F32除1024 | ≤128cycle/row |
| P2 | 32拍本地重读；F32 delta/square、原variance树、除1024、eps、sqrt、1/root；缓存delta | ≤256cycle/row；流水接收间隔≤128cycle |
| P3 | 32拍读delta；F32乘inverse及适用gamma，真实写回 | ≤64cycle/row |
| 完整LN | 首row完成≤448cycle；连续row启动II≤128cycle | **S128≤448+127×128=16704cycle** |

mean/variance的除1024使用保留subnormal舍入的F32常数除法，延迟各≤16cycle；每棵1024项邻接树在最后32-lane输入之后的剩余归约延迟≤80cycle。sqrt和reciprocal分别保留F32舍入，单运算延迟各≤32cycle，发射II≤1；不能将两个步骤合成不同数值rsqrt。4行上下文只隐藏延迟，仍完成三遍和整行统计屏障。LN阶段可使用闲置matrix restore中的固定FP lanes，但不能与该请求矩阵同时计吞吐。60次LN累计≤1002240cycle。

| 模块 | 工作量/接口 | 首输出与完整任务硬帽 |
| --- | --- | --- |
| residual | 60次，每次128×1024；两源各32 F32/拍、目的32 F32/拍；独立F32加 | 首输出≤32cycle；每次≤4160cycle；累计≤249600cycle |
| type add | 1次128×1024；原type向量广播，32 F32/拍 | 首输出≤32cycle；≤4160cycle |
| marker/CLS gather | 17×1024=17408 F32；全部16槽＋独立CLS | 首32元素≤32cycle；片上紧凑出口≤608cycle；后续HBM staging独立计 |

残差读取原Hcur，向Hnext写；全部提交前不释放skip。第4节矩阵sink使用norm/vector工作区或QKV/FFN缓冲；LN/Q完成后该工作区才可复用，不需要完整Wi F32常驻。

## 7. 片上容量、HBM staging与物理资源上限

基础版固定**1个请求上下文**，不依靠双请求重叠达成第1节要求。两个请求只作为后续独立优化，须另列容量、时序和性能要求，不能扩大当前资源上限。

| 存储 | 逻辑payload与bank要求 |
| --- | --- |
| H0/H1 | 各524288B；各32个32bit bank、1R+1W，保存残差来源 |
| norm/vector | 524288B；32-lane读写，供LN/Q和矩阵输出阶段复用 |
| QKV | 1572864B；32-lane退休写入，staging独立读口/阶段 |
| context | 524288B；staging写入后交Q；不跨层复用未完成数据 |
| A0/A1 | 各557056B；读输入A与写FFN中间A分slot；bank见第3节 |
| W双slot | 合557056B有效payload；reader另≤48KiB |
| PS | 2×32768B；512逻辑bank/context；返回队列与tag另计 |
| GEGLU | 2×32768B配对缓冲；与Q/G在途数据独立 |
| LN | 4×8192B raw/delta行上下文，标量统计另计 |
| coeff | ≤128KiB，包括全部bias、final gamma及精确解码type向量，初始化按model generation校验 |
| 私有尾部 | 69632B；gather完成后交staging，CPU读完成前持有 |

独立F32矩阵性能入口在无活动请求时复用H0/H1、norm、QKV、context的3.5MiB F32工作区，划分不重叠源/目的；最大Wi源＋目的为3211264B=3.0625MiB，FC2完整F32源为2MiB。必须走生产32-lane bank路由，不以TB逐tile即时注入绕过源带宽，也不新增未计容量；生产FFN仍用配对缓冲和Q cache。

上述容量不能代替端口证明；pipeline寄存器、返回向量、bank碎片、CDC、ECC及shell都须在资源报告中列出。不得拿43MB总容量直接判定设计可实现。

B每请求的HBM staging固定为：30次QKV写出、30次context读入、1次初始hidden读入、1次紧凑尾部写出。使用第5节16GB/s服务曲线：QKV每次≤29748cycle，context/initial每次≤10087cycle，tail≤1562cycle；总计**1206699cycle**。这段计量从staging命令接受至真实内存完成；PCIe DMA随后/此前另计。设备HBM staging和DMA对同一payload的不同物理访问不能漏记，但同一次访问的两个观测区间不能再相加。

| 联合用户核资源 | 硬上限 | 规划分配/验收 |
| --- | ---: | --- |
| DSP | **7200** | INT8≤4096；scale/转换≤384；恢复及PS加法≤1536；独立Q/G/向量额外≤896；控制/搬运额外≤288。共享单元只计一次 |
| LUT | **900000** | 含完整Q、FP、bank mux/控制/CDC，不只矩阵 |
| FF | **1800000** | 包括全流水、FIFO、PS寄存器及复位逻辑 |
| BRAM36等价 | **1200** | 按真实RAMB18/36折算，碎片照计 |
| URAM288 | **640** | 含真实端口复制和ECC |
| 实现时序 | **300MHz；WNS≥0、TNS=0** | 所有实际同步/跨域约束闭合，无相关未约束路径 |

同时要求用户核＋真实shell不超过真实器件各类资源，完整平台route成功；上表不能替代shell余量检查。禁止通过放宽关键路径false-path、降低频率或省去strict FP模块满足资源表。一tile、单IP/OOC或HLS估算不代签联合要求。

## 8. B的CPU、Host与PCIe硬预算

固定4核、模型与pinned buffer预热驻留；CPU使用优化编译、SIMD、固定线程和无重复分配/转置的QKV视图，但必须保持原数值。下列是**实施验收要求，全部NOT_RUN**，不是对当前CPU可达时间的推测。

| CPU/Host项目 | 固定工作 | 热请求上限 |
| --- | --- | ---: |
| 输入 | 从统一已就绪token/元数据到完整Embedding＋initial LN FP32 buffer可DMA | **0.75ms/请求** |
| Encoder Attention | 每层完整RoPE、QK64项树、finite mask、softmax128原树、AV key顺序；128token/16head | **0.5ms/层** |
| Decision Attention | 同shape完整Attention，无RoPE/sliding | **0.5ms/层** |
| 全部Attention | 30层；QK+AV=1006632960 FP MAC；7864320个softmax分数，61440行；Encoder RoPE全量 | **15ms/请求**，单层帽也须通过 |
| CPU尾部 | 16槽marker LN/完整scorer、2次bias、统计、raw CLS ACT、final18 | **2.25ms/请求** |
| Host非DMA/非上述计算 | BEGIN＋30次CONTINUE、元数据/版本/同步/布局管理及final发布 | **1ms/请求**；不得把这些时间挪进“未知” |
| PCIe数据 | H2D 31笔、D2H 31笔；每方向payload速率均≥8GB/s | 每笔`≤payload/8GB/s+20µs`；**62笔合≤9.17856ms** |

B总payload为63508480B=60.56640625MiB：30×(1.5MiB QKV＋0.5MiB context)＋0.5MiB initial＋68KiB tail。62笔DMA的20µs上限包含该笔提交至首数据及末数据至完成的额外时间，不能再把同一驱动区间算入Host 1ms；Host剩余区间由时间线互斥标记。HBM staging与PCIe各自有真实事件，不用单纯payload除峰值代替测量。

CPU模块从所需输入可读到输出完整可消费计时，包括本模块线程同步；不扣除真实生产线程等待。性能样本记录实际CPU核数、频率、NUMA/PCIe拓扑、SMT和其他负载。当前CPU0–3/nice19/idle I/O约束不变，不占用额外核以满足指标。未达到15ms Attention要求即B对应性能FAIL，触发第10节条件扩展评估；不将15ms改大作为完成。

## 9. 串行请求总账与系统验收

| 不重复的预算项 | 周期/时间上限 |
| --- | ---: |
| 主线120矩阵完整服务 | 6880256cycle |
| 板内60次LN | 1002240cycle |
| 60次residual | 249600cycle |
| type add | 4160cycle |
| gather | 608cycle |
| FFN仅未隐藏尾段 | 36864cycle |
| HBM staging | 1206699cycle |
| **设备侧保守总账** | **9380427cycle=31.26809ms** |
| CPU入口＋尾部 | 3ms |
| CPU完整Attention | 15ms |
| PCIe 62笔 | 9.17856ms |
| Host剩余管理 | 1ms |
| **全部分项串行预算和** | **59.44665ms** |

120矩阵表对每个独立FP32服务包含Q；生产FFN使用已生成的Q时，归属只计一次，不能把同一Q重复加入实际总周期。上述总账直接采用独立服务帽作为保守上限，没有再加一笔生产者Q；实际时间线必须按互斥区间核对，不把上限和声称为实测。

系统还须独立通过P50≤60ms、P95≤65ms和串行≥15QPS。分项P95相加不能推导端到端P95；两类指标均实测。验收至少包含固定真实请求和具有原范围代表性的独立输入集，预热后≥200次完整请求；逐shape硬件周期、CPU逐层/累计与DMA单笔帽均检查该批全部合法样本，报告max及超帽样本，不只报告平均值。持续QPS采用同一输入分布、单上下文、连续≥60s，计入完整final18消费，不以设备kernel QPS替代。性能测试的CPU/墙钟预算须用户恢复后另登记，本合同不授权立即运行。

A6000另测严格同数值后端和实际常用工程后端，后者若FP16/TF32/FMA/归约不同必须列差别。禁止采用Python逐元素/未合理优化的严格GPU实现制造胜出。报告冷初始化、首请求、热请求、纯设备及端到端；只使用一张卡。达到本工程60/65ms要求仍须实测比较A6000，latency与throughput胜负分别记。若GPU实测更快，竞争目标保持未达成，不能把工程指标PASS改写成胜GPU。

## 10. C的条件扩展边界

C不在本修订B的必做模块内。触发条件为B完整Attention超过15ms、B未达到系统帽，或B虽过工程帽但实测不能满足Goal的A6000竞争目标；先定位原因，C只作为受影响切口的独立架构修订，不自动唤醒工程或扩预算。

C须将RoPE＋QK/mask/softmax＋AV完整移入设备，保留现有QKV/context逻辑接口、strict数值和完整S128。不能只搬QK或AV却使用0.56640625MiB流量口径。其独立合同须明确FP32 QK/AV工作1006632960 MAC、softmax7864320分数/61440行、FP归约和AV反馈、exp/div lane、score/probability银行，以及复用restore造成的矩阵占用时间。若复用FP阵列，Attention与矩阵时间相加。

C的进入生产门槛为：同数值板内Attention及新增控制时间严格小于被替代的CPU Attention＋该30次交接实际关键路径，且不破坏本合同300MHz、矩阵周期帽与联合资源上限；完整系统取得净收益。只有完整功能/物理/实板证据支持时才切换生产方案。当前C仍NOT_RUN，无未经验证的延迟预测或随意增加的并行候选。

## 11. ABI、数值首错、排债与复位

固定图描述符在模型初始化时建立；生产只发BEGIN和30次ATTENTION_CONTINUE，末尾TAIL_READY后CPU完成final18。ABI含64bit request_id、32bit generation、模型/数值/布局版本、固定shape/层/模式、64bit地址/span、mask/position/type/marker引用、私有slot。每请求可变元数据≤4KiB，通过控制BAR/MMIO传递并计入Host 1ms，不额外增加62笔payload DMA；固定图/权重描述符预建。数据小端、64B对齐，地址加法检查溢出、范围与不重叠；page/burst拆分和WSTRB真实实现。超shape拒绝，不静默切到标量慢路径。

QKV_READY、CONTEXT_ACCEPTED、TAIL_READY、ERROR是不同事件；Check含request/generation/layer/op、status16/detail32/bad64及有效范围。QKV/TAIL在数据及真实B完成后发布；CPU须等D2H真实完成才消费。CONTINUE仅接受当前层和request/generation，禁止覆盖未归还buffer。成功final18仍须完整CPU尾部通过。

原数值合同保持：group32独立舍入/有序group累加、原量化舍入、LN中心化方差树、QK64树、softmax128树、AV key顺序、finite mask、原非线性和所有16槽。F32乘加不合FMA，不更换近似函数、裁剪、早停或精度。独立gold不按DUT输出改写。

物理Ntile/row交错不决定逻辑首错。错误排序键按原图调用顺序，再按该调用参考的检查阶段、row/element/group顺序映射；开始实现前以版本化映射表固定具体枚举。保留候选最早错误及尚未完成的更早逻辑范围，不能遇到首个物理错误就提前发布。协议缺失/AXI错误有独立优先级，不能谎称CPU数值参考定义了传输错误。

失败停止新增无关发射，排尽实际AR/R/AW/W/B、FP返回与消费者credit，私有未提交数据作废；不force债为零，不提前释放PS/W/A。允许有限只读预取，受32 burst和两W slot边界约束；未来权重错误不提前覆盖更早数值错误。复位采用统一同步释放/CDC握手，request级abort与平台hard reset分开；隔离期由实际在途上界证明，不能照抄旧510拍常数。恢复后的请求不得读到旧generation数据。

## 12. 阶段交付、证据与状态

| 阶段 | 实际交付 | 必须通过的出口 |
| --- | --- | --- |
| P0 | 固定平台/ABI/首错枚举、CPU和单A6000基线、整数/格式特化证明、计量事件 | 真实基线与数值差异、可核查分项；不改本版帽去适配慢结果 |
| P1 | 生产双tile、Q32、恢复/PS、真实四口reader、所有六shape服务 | 全S128/全部N与bias独立正确；每shape帽、120次累计、真实字节/credit；联合资源早期证据 |
| P2 | 驻留hidden、LN/residual/type add、完整FFN/G/Q与gather | 60 LN等完整工作量、FFN帽和bank生命周期；不是短流峰值 |
| P3 | 四核CPU完整Attention/尾部、真实Host/XRT与62笔DMA | CPU15ms及各模块帽、staging/PCIe帽、完整层与请求时间线 |
| P4 | 完整28＋2图、连续请求、同版本平台P&R及部署 | functional/physical/module_performance/system_latency/throughput/GPU_comparison/board分别判定 |

当前所有新模块、周期、资源、时序、CPU/GPU基准及实板证据均NOT_RUN。无U55C时可在恢复后完成离线与物理阶段，board保持未完成，不以仿真或CPU代算称为FPGA实测。模块接口性能例使用真实reader/writer和完整生产模块；必须同时有无注入停顿的性能例与有限反压/跨页/错描述符/失败/复位/后继请求安全功能例。不同版本局部PASS不能拼接成完整同版本通过。

A001唯一维护Goal/Mission/接口与集中验收；A002恢复后维护唯一E002实现、模块design/results和三摘要；A003维护独立来源/瓶颈依据。阶段内普通实现、编译、定位、修复、受影响回归连续完成，无逐次审批包。实质架构/数值/指标修改集中修订合同，保持未达成项，不用“降低指标”追认已完成。

服务器全项目单重工具、CPU0–3、nice19、idle I/O、MemAvailable>192GiB保持；RTL≤8GiB/3600s/40Mcycles、pilot≤120s，static≤24GiB/1800s、模块OOC≤24GiB/3600s及语义停滞保护不因本文加大。实际新阶段预算、长例分解和P&R范围须恢复后单独登记，不继承旧余额。超帽记COST_STOP，保留原始源码/输入/日志/退出码，不删checker或无限续帽。

M004/SM004保持暂停未完成，AT404待审与AT405–408本轮不补签；历史FAIL/COST_STOP及费用原样保存，不要求先完成旧全部控制债才实施M006。原Laya-baseline不修改。

来源：[完整独立参考](../../project/E002_Laya_HLS/experiment/tests/full_reference.py)、[矩阵清单](../../source/feasibility_20261014/v4/matrices.csv)、[用户架构原文](../../design_source/Laya_CPU_FPGA_Codesign_Architecture_20261017.md)、[AMD U55C规格](https://docs.amd.com/r/en-US/ds978-u55c/Product-Details)、[AMD INT8打包说明](https://docs.amd.com/v/u/en-US/wp487-int8-acceleration)。来源旧表中的测量迁移/利用率/延迟情景不作为本合同新要求的性能证据。
