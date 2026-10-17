# Q8 Linear、恢复与部分和：详细设计

## 2026-10-09：metadata_reset_v3 ACT 实际 RTL 接口与静态页联测

本节登记实际生成接口，覆盖下文原型合同中仍属候选的端口数量、outstanding 与控制寄存器描述。设计前像保留于 [history](history/design_before_act_dual_lite_mapping_20261009.md)。当前已接受 v3 源码、综合及无批量 payload reset 的结构证据；[41 页 fixture 的独立逐字节复核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_materialized_bytes_review.json)已完成。[ACT 36 命令整体数值、协议、恢复与暖复位独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_full_functional_acceptance.json)已完成；[实际源码独立审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_actual_source_review.json)和[原一次性执行门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_static_runtime_release.json)均已闭合，已通过命令不重跑。现有[设计准备门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_act_static_v1_dual_lite_design_preparation_release.json)自身不授权 EDA。

实际 DUT 来自 `metadata_reset_v3/runs/csynth_local_v1/work/hls/syn/verilog/`，230 个 Verilog 文件、108 个初始化 `.dat`，以及原综合生成的 7 个浮点仿真 VHDL wrapper；使用已安装的 `floating_point_v7_1_21` 及依赖库，不重新生成 IP。联合 TB 位于 [rtl_act_static_v1/tb](../metadata_reset_v3/rtl_act_static_v1/tb/)，只实例化真实 DUT、已接受的静态 AXI endpoint、有限容量停顿适配器及被动监视器。

### 双 AXI-Lite 与九路 AXI

`control` 地址宽 4 位、`AP_CTRL=0x00`，仅处理启动/完成/空闲/中断；`control_r` 地址宽 7 位，承载全部指针。两组都用 32 位数据、真实 AXI-Lite 事务驱动。冷复位和同一实例的暖复位后，先读回 18 个指针半字为零，再逐个写入并读回高低半字。物理地址保留高 32 位，不能按低 32 位或取模映射。

| AXI 口 | 数据位宽 | `control_r` 低/高偏移 | 指针物理基址 | 静态 4 KiB 页数 | 允许的逻辑字节范围 |
| --- | ---: | --- | --- | ---: | --- |
| descriptor | 32 | 0x10 / 0x14 | 0x10_00000000 | 1 | 0…511，只读 |
| w_q0 | 512 | 0x1c / 0x20 | 0x11_00000000 | 1 | 0x0b020000 起 2048 B，只读 |
| w_q1 | 512 | 0x28 / 0x2c | 0x12_00000000 | 1 | 哨兵页；本 ACT 用例无事务 |
| w_scale | 512 | 0x34 / 0x38 | 0x13_00000000 | 1 | 0x01604000 起 128 B，只读 |
| aux | 32 | 0x40 / 0x44 | 0x14_00000000 | 2 | 头部 0…127，bias 0x00096cc0 起 8 B，只读 |
| activation | 512 | 0x4c / 0x50 | 0x15_00000000 | 1 | 0…1023，只读 |
| out0 | 32 | 0x58 / 0x5c | 0x16_00000000 | 1 | 0…7，写入两项 F32 |
| out1 | 32 | 0x64 / 0x68 | 0x17_00000000 | 1 | 哨兵页；本 ACT 用例无事务 |
| observed | 32 | 0x70 / 0x74 | 0x18_00000000 | 32 | 头部 0…1023，A8 trace 1024…1279，scale trace 66560…66575，group trace 70656…70911 |

合计 41 页、167936 B 外部 backing bytes。`aux` 第二页位于逻辑 0x96000，bias 在页内偏移 3264；observed 全部 131072 B 都有实体页并全字节比较。页面存在不授权整页 AXI 访问：双侧 monitor 另按上表的实际允许范围检查每个 burst 与 WSTRB。输入页每条命令在下一次覆盖前全页比较；out0/out1 全页及 observed 全区均保留并核对未写哨兵。所有九口实际地址宽 64、ID 宽 1；每口完整连接 45 个 AXI 信号，两组 Lite 各 17 个，共 439 个总线引脚，另有时钟、复位和中断，顶层共 442 引脚。

监视器按实际握手分别记 AW/W/AR/B/R、总线字节和有效 WSTRB 字节，并容许 W 先于 AW。实际 generated AXI 通道配置与 endpoint 排队共同决定在途深度，不能沿用下文候选“每口 1 outstanding”当作实测。endpoint 固定四个 AW/AR/B 描述符、64 个 W 条目及一个 R 输出槽；新适配器每通道另持有一个条目，以固定种子延迟 0…3 周期并保持已暴露 VALID 与 payload。两侧计数、响应 ID/LAST、完整范围和排空条件独立检查。

首个合法 RUN 另对 activation 最后 R 拍及 out0 最后 B 响应各增加 16 周期等待。首次实际 `ap_done` 以时钟沿采样，随后检查同一时钟沿所有债务已退休，禁止靠等到更晚排空掩盖过早 done；CSR 同时验证 done/idle。新命令、外部页变更和复位均须先排空。除了只读探针，不写入 DUT 内部状态，不跳过量化或计算。

### 三组连续命令与暖复位边界

冻结输入为真实 ACT K=256、N=2、rows=1。使用两个真实 batch 的 activation、模型原始 q/half-scale/bias 字节、固定独立数值 oracle；所有组都从外部 LOAD 开始，同组命令共享同一 DUT。既有 manifest 固定 234 个输出文件、36 条命令；期望值不随运行结果修改。

| 单独运行组 | 命令数 | 核心检查 |
| --- | ---: | --- |
| legal | 9 | LOAD；原始高位枚举/tag 拒绝；batch0/1 分别覆盖 n0/n1 的八组 trace；重放拒绝；trace 关闭仍同数值；双 NaN 按 bad_element=2 先错；仅量化退休后合法恢复 |
| fault_load | 3 | n0/g1 与 n1/g0 两处坏 scale 加坏 bias，先报 scale 首错；合法 LOAD 恢复 W；随后真实 RUN |
| identity_reset | 24 | 描述符和 AUX 四个 tag 的首/末字节错误、ABI/tag/shape 优先级；八次 AUX 拒绝消耗 task/W epoch 后恢复；改变身份先拒绝；同实例暖复位后未 LOAD 的 RUN 拒绝；新身份 LOAD/RUN 成功 |

每条命令比较完整 256-word 状态头、完整 observed/out0/out1 图像与九口流量。数值检查涵盖完整最终 F32、A8、half scale，以及 batch0/n0 与 batch1/n1 的选定八组 dot/product/term/顺序 FP32 PS/bias（不代表每批每列全部中间量）；状态头包含任务/身份/tag/epoch、缓存状态和已退休工作项。软件 `O_INFLIGHT` 字段不替代真实总线在途监视。

暖复位至少保持低电平四个完整时钟，不重新实例化 DUT。动态检查从真实写端口记录非零写入地址，复位前读取 W、A8、FP 输入缓存 payload 各一个当前原始位型非零单元并在原位复查；实际 FP 输入为负零 `0x80000000`，区别于清为正零，其数值幅度不为非零，另保留少量外部 observed 字节。该动态采样仅证明所选单元保留，未动态抽查 PS 部分和 RAM；[v3 结构审查](../../../../results/attention_rtl_repair_20261008/reviewer_q8_metadata_reset_v3_synthesis_reset_structure_review.json)另提供全部 50 个 payload RAM 没有 reset 清空逻辑的静态证据。暖复位后的第一条 RUN 必须报告 claims/loads/reuses 全零、四类状态 INVALID=6；保留的 payload 不能替代新 LOAD。

### 执行与性能解释

已完成一次静态编译/链接（204.701 s，峰值 owned RSS 4177016 KiB）及 legal → fault_load → identity_reset 三组。原静态 16 GiB/300 s、各运行 8 GiB/180 s、每命令 20000/每组 250000 时钟门均未触发；这些时钟上限是先验 watchdog，不是已证明 latency。三组分别 38302/15951/79971 个完整测试台时钟，最大单命令 6295 clocks。所有阶段四核、nice 19、idle I/O、0.2 s RSS，MemAvailable 严格大于 192 GiB，并已核对重工具顺序不重叠。完整原始证据和各组可变快照日志已冻结。

这些检查属于 ACT 功能闭环；每命令仿真周期不直接等于全矩阵吞吐。v3 HLS 估计周期 21.308 ns、关键 II 4/7，top 总 latency 未确定，ACT 切片数值通过，尚无真实大矩阵吞吐、OOC 或板级性能结论。理想 B1 TM4/TN8 纯 Q8 约 307 ms、64 FP Attention 的 QK+AV 理想工作量约 104.86 ms，都已超过 50 ms。后继继续真实全 K/N 的少行窗口、多 tile、尾行与跨列首错扩展；阶段/issue/反馈/AXI 观察器只读真实 RTL，并分别记录 accepted start→done 与测试台开销，以及单独冻结的 R0 顺序恢复/反馈/访存性能改版。联合预算必须同时包含 Q8 浮点恢复和 Attention 资源，端到端时间保留 Stage5 的 184 MiB workspace、32 KiB IO H2D 与 384 B D2H，并在实验前固定 kernel 和端到端计时边界。

### 后继全 K/N、尾行与性能观察准备

[具体源准备合同](../../../../results/attention_rtl_repair_20261008/reviewer_q8_full_dimensions_tail_performance_source_preparation_release.json)保持 v3 实际 HLS/RTL/IP 不变。首例 `scorer_fc1` 为 K1024/N1024、G32/T128；使用冻结 `marker_norm` 输入和 `scorer_fc1_baked` 输出，偏置明确为 `linear_120_baked_bias`。341 个静态 4 KiB 页覆盖两路各 128 权重页、16 scale 页、3 AUX 页、16 activation 页、16 out0 页、1 out1 哨兵页、1 descriptor 页及32 observed 页。首批只准备 LOAD、单行 trace 开及同输入 trace 关三命令；tail/fault 后继以实际数值、阶段周期、RSS和模拟推进率为条件。

14 个预备窗口覆盖 1/3/4/5/15/16 行、QKV 双分片三 plane/16 head、N5248、K2624/G82 与 K4096/G128，始终使用真实全维。缺失 R0 输入仅从冻结 `embedding_norm` 或 `type_add` 局部派生 Encoder0/Decision0，并与对应层输出检查点核对，不重跑完整网络。新只读观察器必须绑定真实握手、issue/retire、PS 读写/反馈、浮点操作及 AXI 停顿；accepted start→done、trace/报告、测试台检查时间分开，跨阶段重叠不重复计入。源准备门自身不启动材料化、CPU 编译或 EDA。

## 2026-10-08：隔离 TM4/TN8 联合原型实施合同

本节由 Astra xhigh 细化，[修复合同 §4.4–§4.7、§7.14](../../../../results/attention_rtl_repair_20261008/repair_contract.md)为共同依据。采用 A 隔离实施、B 切片表征、C 生产集成三门；A 门不等待旧 F0 完整 RTL，B 门不宣称整核/shell 适配，C 门仍要求最终加速核完整请求 RTL。生产 fe067 与既有测试保持不变。此前本页原文精确保留于 [history](history/design_before_joint_prototype_mapping_20261008.md)。下方 P0/P1/F0 内容按原身份阅读。

### 原型边界与文件映射

新诊断身份 `q8_joint_tm4tn8_v1`，HLS top `q8_joint_tm4tn8`。在本模块新增 `source/q8_joint_abi.h`、`source/q8_joint_tm4tn8.cpp`、必要的无指针数值/状态记录头，`tb/generate_joint_fixture.py`、`tb/test_q8_joint.cpp` 及受控入口；生成 RTL 和每次工具证据存本模块独立 `runs/`，`rtl/`只登记实际生成绑定。只有 Sol max 修改该原型实现，禁止覆盖生产 `hls/` 或现有 numeric_tb/contract_tb。

复用已冻结模型布局生成头、`full_lookup_weight` 的实际 WeightKey/尺寸/偏置描述以及生产数值检查/转换语义；不调用完整 Controller 或完整 graph，不把已填寄存器的 dot 当联合原型。新 HLS top 的外部指针仅作为独立端口使用，不把它们装进会跨函数逃逸的引用聚合。独立 Python oracle 从冻结 GGUF 逆重排权重和完整 CPU 节点构造输入，分别计算量化、dot、scale product、term、每组 PS、bias、最终 F32。

### 命令、端口与状态

一次 `ap_ctrl_hs` 调用处理一个命令，命令间保留当前 W 缓存及其绑定。`LOAD_W=0` 实际装入一张完整权重，`RUN_TILE=1` 实际装入/量化完整输入 tile 并计算完整 K/N；两者都必须真实完成事务后返回。复用同一 W 的后续 tile 不再读权重，换 WeightKey 必须先完成新的 LOAD_W。没有并行 kernel 调用、双 W/A/PS 或跨请求推测复用。复位后缓存 INVALID；错误使未完成对象 INVALID，不发布输出，下一合法 LOAD_W/RUN_TILE 按状态合同恢复。

| 端口 | 逻辑内容与首版物理要求 |
| --- | --- |
| `descriptor`，128×U32 | 独立 m_axi，以下固定小端描述符；实际字段读入无指针记录，保留全部非法检查 |
| `w_q0/w_q1/w_scale/aux` | 独立只读模型 BO，使用冻结包原字节布局/原偏移；q0/q1/scale 为显式 `ap_uint<512>` 接口，aux 可按 U32 读头/偏置并按实际生成宽度报告 |
| `activation` | 显式 `ap_uint<512>`，装入冻结真实节点的 rows×K F32；每 beat 的 16 个 F32 分两拍写 8-bank FP 输入，不假定单 bank 同拍双写 |
| `out0/out1` | 逻辑 U32 F32 写接口；普通矩阵写 out0，QKV 按生产 shard/plane/head/row 公式散写两口。首版允许实际 32-bit 写口，须明确记入输出瓶颈，不能按 512-bit 峰值计算；后续宽写是独立接口变体，必须验证 N2/行尾 WSTRB |
| `observed`，32768×U32 | 状态、工作计数及受限数值 trace；不是第二条计算路径，任何 trace 输入不得影响数值结果 |

所有外部地址以字节解释，范围检查使用足够宽的无符号加法，先检查溢出再访问；q/scale原 BO 字节、矩阵物理 N pad 和 aux header/bias 不重新打包成寄存器输入。首版保守限制每口 1 个 outstanding、最长 16 个 beat，burst 不跨 4 KiB；实际 RTL 的位宽、burst、WSTRB、响应与 useful bytes 必须审核。q0→q1→scale→bias 可分阶段装载；首版明确不依赖双口同时写同 bank，若实现并发则先提供 per-bank 仲裁/容量设计。这里新定义的原型接口不代表生产 13 口已经拓宽。

描述符 ABI：word0=`0x51384a50`、word1=1、word2=命令、word3 bit0=trace enable（其余0）；4–5 request_id、6–7 generation；8=该命令 task_id，9=生产 op，10 stage、11 layer、12 B、13 S、14 batch、15 row0、16 rows、17 K、18 N、19 WeightKey.family、20 WeightKey.layer；21 src.id、22 src.bank、23 src.epoch、24 src.region；25 dst.id、26 dst.bank、27 dst.epoch、28 dst.region；29 W epoch、30 PS epoch、31 quant task_id。32–35/36–39/40–43/44–47 分别是模型/数值/布局/生产包 build tag，每4个连续字节以小端U32表示。48–49 activation base、50–51 out0 base、52–53 out1 base；54–55 activation span、56–57 out0 span、58–59 out1 span，均64位字节数。60=trace row-local、61=trace column、62=observed words（固定32768）、63=0；64–127保留0。必须有独立固定字节序向量与生成器，禁止用 C++ struct 原始内存作为 ABI。

身份/tag 必须与冻结包一致，K/N 由 WeightKey 查表核对而非信任调用者；B/S/batch/row0/rows 必须合法且 rows=1…16，rows 不满 TM 仍执行完整 K/N。LOAD_W 校验真实 aux 模型头、描述符和完整 q/scale/bias span，全部数据校验/入 bank 后才 W_READY；读取次数和完成响应明确记录。RUN_TILE 要求 request/generation/WeightKey/W epoch 与当前 W 绑定相符，quant task_id 与 linear task_id 遵守合法先后顺序，真实读满 rows×K 后经两遍量化覆盖全部 rows/group 才 A_READY。PS 以合法新 epoch 领取，最后组提交与实际输出响应完成才退休。局部 tile 输出不发布整层 QKV FINAL_READY；集成时由生产 Controller 汇总真实完整覆盖。

所有U32枚举/窄字段先检查原始高位及范围再转换，不能把0x100+合法u8误接受。RUN的row_space由stage2/4→TOKEN、stage5→MARKER、stage6→BATCH确定，bias_kind由实际权重描述符确定。ACT stage6/layer255必须row0=0、rows=1；rows3/5/15/16尾部用于合法TOKEN/MARKER矩阵。activation base必须64字节对齐，out0/out1 base必须4字节对齐，span必须覆盖完整实际访问区间；未用out1字段在普通矩阵为0。生产包build tag与原型源码/配置/tool身份分列。

原型会话从硬件reset开始：身份尚未绑定、last_task_id及W/A8/PS claim账本为0、缓存有效位清零，RAM payload不整体初始化。首个合法LOAD_W绑定完整request/generation/四tag及B/S；该会话后续命令必须同身份，切换会话须reset。LOAD_W的op为LOAD_W、控制context为batch0/row0=0/rows1、src为NONE、dst为WEIGHT bank0且dst.epoch=word29；word30/31及activation/output/trace选择字段为0。LOAD task_id必须last+1。RUN的word31必须last+1、word8必须last+2；quant成功退休后才接受linear，quant失败只退休实际开始的quant，不能伪造linear退休。错误报告列出实际出错task与last_task_id，重放不得再次消费任务。满足顺序并进入对应任务后，其成功或失败均消耗该task_id；前置ABI/身份/序号拒绝不消耗任务。

W/PS epoch采用各自max_claimed+1且禁止溢出；A8 epoch由独立内部max_claimed+1生成，不能借用src/PS epoch。已发生的claim即使失败也消耗epoch，reset才归零；前置拒绝不发生claim。RUN在量化开始claim A8，量化成功后linear才claim PS及局部目的；LOAD只有完整装载/校验后发布W。src/dst以生产check_ref和op/region形状验证并绑定本tile，局部原型不宣称完成外部生产者owner验证；src由冻结fixture证明、生产整层目的owner由C门集成证明。实现包须列明每条前置检查与claim/退休时点及复合非法优先级，Astra源审后才接受CPU结果。

普通输出保留生产列序，以 out0 base 为本 tile 存储起点，偏移 `4*(r_local*N+n)`；这是隔离 tile 容器，集成适配与全局 row0 分开记录。QKV 使用生产固定物理布局，out0/out1 base 对应两个 shard 的起点，地址由 plane、head、batch、row0+r、d 推导。全部非写区保持哨兵，N2只计算/写2列；不能全宽覆盖无效列后仅比较其值未变。

### 算术、bank 与流水落实

固定 TM4/TN8/GS32。存储严格采用合同 §4.4：W q 8×256-bit bank、每 bank 最深20992，W scale 8×16-bit 同地址；A q/scale 4 bank、保留全部16行；FP输入8×32-bit bank；PS 32×32-bit bank、每 bank 最深656；bias8 bank。所有尺寸取实际最大K/N组合，不以maxN×maxG生成4倍W深度。明确分 bank/存储绑定可用，禁止依赖未审核自动 partition 把大数组展开为寄存器。

以矩阵内512-bit q beat编号b、端口shard=s计，u=floor(b/4)、pair=b%4、t=2*floor(u/G)+s、g=u%G；两个256-bit word分别写bank=2*pair及2*pair+1，addr=t*G+g。scale beat b含32个half，按j=0…3、lane=0…7写bank=lane、addr=4*b+j；单写口每bank至少四拍解包，G82跨tile仍使用同一线性addr。FP输入宽拍需两拍解包。q0→q1→scale→bias的串行成本必须相加，不按三口峰值相除伪造并发load时间。

发射顺序 `m0=0,4,8,12 → g升序 → n0=0,8,…`。整数 group 的32乘与相邻加法树可显式并行；有符号扩展保证精确INT32，不假定DSP打包。每个有效 (r,n,g) 独立执行 `float(dot)`、`F32(sa*sw)`、`F32(dot_f*product)`、`F32(old_ps+term)`，group0的 old_ps 为 +0 且仍执行加法；最后组后按原顺序加入bias。禁止FMA、FTZ/DAZ、重结合、跨group树化或近似half/倒数替换。

量化严格使用 `d_full=F32(amax/127)`，先按未舍入d_full求 `inv=F32(1/d_full)`，q为F32乘法后roundf远离零，保存scale为F16 RNE；零组inv=0。8 lane两遍扫描，half次正规保留，非有限/scale溢出/q越界仍拒绝。量化统计、倒数、scale保存、重放写A8与 dot/restore 的服务率分别报告。

dot/restore 携带 task/epoch/m0/g/n0/valid lanes/PS地址/末组标签。PS读到写回安全窗口F、实际issue II为I、列tile数T=ceil(N/8)，同地址下一group起点必须满足 `max(T*I,F)`；N2 T=1显式等待安全写提交，首版不引入未审核旁路。每个不可停FP管线在发射前预留最坏在途结果容量；FIFO/信用由实际延迟和端口条件推导，未握手不推进标签/计数，末组发出不等于完成。首版单PS使排出与下一微块串行，不宣称DATAFLOW重叠。

并行错误按生产原遍历顺序确定first error，不能按发现时刻挑选。已发现高索引错误时，尚未完成的低索引工作仍须被判定；所有更早工作完成后才能提交first error。失败排空已接受事务，禁止发布未完成输出，错误/恢复与物理未写区单独检查。

生产Linear数值首错rank为 `(floor(n/8),r,n%8,g,检查阶段)`，每个输出的bias检查排在其全部group之后；`bad_element=r*5248*128+n*128+g`只是报告编码，不是优先级。LOAD的首错先按全部padded n→g的scale校验，再按bias n；Quant按r→g，先完整32项finite扫描，再d/reciprocal/half，最后q逐i。独立oracle必须复现这些顺序，不能用全数组finite预扫或新发射序替代。已提交前微块的临时output payload不能回滚，因此失败“不发布”指目的对象不READY、TaskDone失败；不要求所有输出字节回到原哨兵。已真正写过的区域与无效/未写区分别核对，禁止把已写无效对象交给下游。

### 观察与验收用例

`observed[0:255]`为固定状态/计数头，实现时在ABI头逐word登记并与独立TB核对，至少包含原Status/detail、TaskDone、identity/refs/epochs、完整覆盖数、accepted_issue/inflight/retired_group/committed_write、各AXI口有效/总字节和装载复用次数。trace启用时，word256起16384words保存完整最大A8 q图像，word16640起1024words保存F16 scales；word17664起每group8words、最多128组保存选中输出的 dot/sa/sw/product/term/PS及g/valid。bias和最终F32另入头部明确槽位。未使用trace区保持哨兵。数值trace在真实计算后导出，不能重新跑另一套算术生成“匹配”trace。

qtrace按row/group/k紧密小端四S8/word存储，scale trace按row/group紧密两F16/word存储；只有实际rows/G范围写出。选中输出每group的8words固定为dot二补码、sa F32、sw F32、product F32、term F32、PS F32、g、valid=1；头部记录选中bias原bits/是否启用与最终F32。全部A8及全部final都必须比较；固定观察口只证明所选(r,n)的全G中间值。首批ACT用同一DUT两次RUN分别选n0/n1，覆盖其全部组trace并检验W复用。大矩阵注明代表trace范围，若要宣称所有lane每组覆盖，须提供实际计算事件observer或RTL被动退休scoreboard；不得对每列重跑整张矩阵来制造不可结束的验证。

trace关闭与开启必须输出相同数值；性能使用关闭trace的同一制品，并分别记录装载、量化、compute、输出、诊断导出的真实周期。C++循环计数只代表工作项，不冒充硬件cycle；cycle/AXI服务率来自生成调度、RTL被动计数和实际完成事件。最终kernel时间包含所有实际执行阶段，不把trace开启/关闭两个制品的II与资源拼接。

先建立真实ACT K256/N2/rows1的完整联合用例（LOAD_W→RUN_TILE），并对同W第二次RUN证明未重复装载；其后覆盖Encoder QKV/Wo/Wi/down、Decision QKV/FC1/FC2、Scorer FC1，所有实际K/N，QKV rows1/4、rows3/5/15/16微块尾、K2624末group、最大N5248和最大K4096。逐位比较q/half scale/dot/scale product/term/每group PS/bias/final，而不是只比较top1。独立受控扰动覆盖零激活、负dot、F16次正规、scale非法、输入非有限、错身份/epoch/shape、未LOAD/不完整W、重放、复合first-error与下一合法恢复。非法规模不得作为主模型合法尺寸，扰动fixture另留SHA。

首批ACT输入来自已接受完整CPU的act_hidden检查点；QKV与Scorer分别使用相应embedding_norm、marker_norm等真实节点，其他矩阵由已有检查点局部推导并绑定来源。旧native中间值只作为另一参考，不改称完整R0节点。实际ACT冻结地址为q0 base184680448/span2048、q1 span0、scale base23085056/span128、aux bias base617664/span8；LOAD矩阵payload为q0 32个宽beat、scale2个宽beat及bias2个U32（另计模型头），不读q1。RUN读16个activation宽beat，8个group issue中仅2个有效dot/恢复lane，写2个F32；这些是work/byte计数预期，不是硬件cycle实测。

RTL必须覆盖真实外部读写、随机AXI/内部反压、N2反馈、末组长停顿、尾列及邻区哨兵、最终写响应退休；各用例先有CPU/CSim。首个RTL仍是ACT完整K256/N2/rows1，不能用缩K/N的人工点积替代。

### 当前实施与运行门

### A门实际代码映射与CPU验收记录（2026-10-08）

隔离实现现固定为[`q8_joint_tm4tn8.cpp`](q8_joint_tm4tn8.cpp)、[`q8_joint_tm4tn8.h`](q8_joint_tm4tn8.h)和[`q8_joint_abi.h`](q8_joint_abi.h)；128词小端描述符由[`generate_joint_descriptors.py`](../tb/generate_joint_descriptors.py)按字段生成，严格CPU比较由[`test_q8_joint.cpp`](../tb/test_q8_joint.cpp)执行。九个外部指针各为独立`m_axi`端口，持久`State`和已解码`Descriptor`不保存外部指针。源码先完成原始字段、冻结身份、任务序号、ref、span和epoch检查，再按LOAD或RUN执行claim、算术和退休；各项实际位置及完整hash见[源码/CPU绑定包](../runs/cpu_act_v1/source_binding_packet.json)，独立范围验收见[审核件](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_source_cpu_csim_release.json)。

W q为8×20992×256-bit bank，scale为8×20992×16-bit bank；FP输入8×8192×32-bit，A8 q/scale分别4×512×256/16-bit，PS为32×656×F32，bias为8×656×U32。另有32×656的`lane_bad`控制位图，按四行微块清零并按PS bank/tile定位，避免跨tile错误别名。源文件中的`ARRAY_PARTITION`、`bind_storage`、`PIPELINE`和`UNROLL`是HLS指令请求；CPU验收不证明实际RAM原语、端口宽度、II、DSP或反馈窗口。W宽beat按`u=b/4, pair=b%4, tile=2*(u/G)+shard, addr=tile*G+u%G`装入两bank；scale的线性地址`4*b+j`保留G82跨tile边界。真实BO偏移、ACT q0=2048B/q1=0B/scale=128B/bias=8B均来自冻结fixture，未重排为伪寄存器输入。

首批实际CPU只验ACT完整K256/N2/rows1，两个真实batch各比较全部256个A8字节、8个half scale和两个最终F32；batch0选n0、batch1选n1，各比较8组真实算术事件trace及bias/final。还检查同W复用、trace关闭数值恒等、未写邻区、前置拒绝、量化双NaN首错/退休/恢复，以及独立进程内复合LOAD scale与bias错误的先后次序和下一合法恢复。TB读取冻结独立R0 oracle产品，不以DUT输出重算期望值。其它K/N、QKV散写、多行尾、一般线性首错、全部lane逐组trace、物理AXI协议和生产集成仍需各自用例；这批CPU不扩大原型验收范围。

A门原放行范围为隔离实现、fixture与严格CPU准备；实际ACT fullK/N rows1合法、同W复用、拒绝和恢复已由Astra xhigh按冻结源码/CPU包接受。原构建16GiB/600s、执行8GiB/300s、4CPU/nice19/idleIO/MemAvailable≥192GiB/0.2s采样的门限及原始记录仍在上述绑定包。其余真实矩阵CPU覆盖须后续逐项扩大，不从首批ACT推定。

标准libm、strict FP的legal CSim及其成功后一次fault_load CSim均已执行并经[Astra xhigh独立验收](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_act_csim_pair_review.json)；两次均为16GiB/600s门内退出0，分别验证首批ACT合法路径和复合LOAD故障恢复，原始运行、依赖闭包及生成工件见[CSim双例证据](../runs/csim_pair_v1/evidence_packet.json)。这只确认当前C模型路径，不能从CSim推定物理bank、接口宽度、II、资源或RTL数值。局部综合按[已审配置](../runs/csynth_config_v1/config_proposal_packet.json)执行一次，源检查失败，详见下段；后续新身份综合须重新审查和放行。原型有意增加明确pipeline/unroll/banking，不能沿用F0“禁止并行”的结果假设；每处指令及产生的II/FP映射须登记。RTL setup/static、数值运行及OOC尚未放行，需实际schedule、memory model、bitwidth、slice输入与guard包；RTL先保留50M-cycle硬停止上限，但必须证明具体用例在wall/RSS预算内可结束，不能直接跑满上限。

### 首次局部综合失败与隔离tag_direct_v2源码准备

首个经独立配置门放行的v1局部综合在源检查阶段失败：[原始证据](../runs/csynth_local_v1/failure_evidence.json)记录两处`HLS 214-134`，分别位于描述符和模型头tag检查的局部`const uint8_t* expected[4]`；guard退出1、无资源触发，未生成调度或RTL。[独立失败审核](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_first_local_csynth_failure_review.json)接受该窄结论。[源码准备门](../../../../results/attention_rtl_repair_20261008/reviewer_q8_joint_tag_direct_v2_source_preparation_release.json)准许建立隔离身份，尚未放行编译或仿真。

New isolated identity q8_joint_tm4tn8_tag_direct_v2 replaces only the two local const uint8_t* expected[4] tag-selection arrays with four sequential16-byte direct constant-array loops. At both sites the order remains model,numeric,layout,build and j0..15. Descriptor comparison still returns on first mismatch; LOAD accumulates header_ok across all64tag bytes and then performs the unchanged32-byte source-SHA check. tag_byte shift j%4 and word indices0..3 in each tag remain little endian. No source helper or pointer aggregate is introduced. Numeric operations, RAM/bank dimensions, all pragmas, ABI/ports, epochs/session/claims/error precedence and trace/counters are byte-identical outside these two hunks. Prior v1/source/config/CPU/CSim/failure remain frozen; root module design/results stay the single current document pair. Actual candidate source and all pointer-bearing automatic/global arrays and instantiated record declarations must be independently reviewed before new CPU. CPU and standard-libm CSim must be accepted for the new identity before any newly configured csynth; no RTL/OOC release.

### 结果预算的边界

资源、cycle、吞吐和50ms差距按[results.md活动预算](results.md)登记。首版允许窄输出是本次明确的接口选择，用于取得可结束、数值完整的联合链与真实排出成本；实际输出带宽不足时必须据证据设计宽写变体，不能忽略其耗时。未提供shell时只验独立OOC，生产整核适配留到C门。任何改变数值或最终完整RTL验收的提案均不在本次放行内。

## 2026-10-08：此前性能原型待实施记录

当前生产F0仍为串行Q8 leaf；179–199cycles/group的旧调度只用于成功源码图的条件外推，完整旧RTL还存在控制语义缺陷。功能表示修复没有增加并行算术，不能据此声称50ms达标。

后续具体工程为[修复合同§4.4–4.7](../../../../results/attention_rtl_repair_20261008/repair_contract.md)的TM4/TN8联合Q8原型：完整K/N、冻结BO装载、8lane两遍量化、W/A/PS实物banking、R0恢复反馈与真实写响应退役一起实现和验证。当前已获[独立设计审核](../../../../results/attention_rtl_repair_20261008/reviewer_joint_q8_prototype_design_review.json)接受为后续设计；尚未放行实现，无原型CPU/CSim/RTL/OOC数据。首个原型不是原§16×8候选的已实现版本，也不修改本轮生产controller补丁。


本页现行制品对应build tag `04934c15b3f83e842ec2e92ac2a81bf2`：完整CPU/真实CSim通过，HLS RTL/IP已生成，完整top Vivado OOC综合exit0、blackboxes0。实际映射345,505 LUT、287,466 FF、437 DSP、690 BRAM tiles、179 URAM；旧HLS LUT139%是历史估算。**2026-10-08新增RTL检查确认QK/AV特化在合法context路径固定E_SHAPE，完整生成RTL成功推理尚不成立；CPU/CSim通过与综合成功均不能替代该缺口。** 详见[OOC制品结果](../../../project/source/results.md)和[新增异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)。下方早期P0/P1/P2记录保留历史范围。

## 当前接口与性能核查（2026-10-08）

输入A8/scale、W8/scale和bias，窗口最多16×8，输出F32[rows,N]；按完整K/N循环，QKV按plane/head散写。

已生成compute_one每32项dot160cycles，含恢复/累加group179–199cycles；active leaf24.12–26.82MMAC/s@150MHz。实际两份leaf按同步图调用，不可把完整图预算除2。

本模块完整输入/输出形状、生成端口与共享边界见[集中报告本模块](../../../project/source/performance_and_interfaces.md#module-q8_linear_and_restore)；[实际内部RTL端口](../../../project/source/performance_and_interfaces.md#generated-ports)、[外部接口](../../../project/source/performance_and_interfaces.md#external-ports)、[整网条件预算](../../../project/source/performance_and_interfaces.md#performance-estimate)与[生成RTL异常](../../../project/source/performance_and_interfaces.md#rtl-anomaly)统一维护。150MHz为综合请求；现有RTL可能提前报错，Q8成功图外推不是当前RTL完整请求时延实测。

模块根：`/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/module_design/q8_linear_and_restore`。依据统一规格v1.0；细化日期：2026-10-05（Asia/Shanghai）。

当前实现与验证：真实完整K/N的Q8 Linear、bias恢复和QKV散写已实现，十种矩阵及完整CPU/CSim通过。 最新合同以[task.md §12](../../../../hardware_agent/task.md)为准，最终CPU/CSim与未完成硬件阶段分列于[results.md](results.md)。此前P0/P1章节保留其历史阶段和候选生产配置。

## 1. 目标与边界

执行Y[M,N]=X[M,K]×W[N,K]转置。输入经activation_quantizer产生A8，W保持GGUF q/scale。全网Q8投影共享本引擎，整数组内dot、scale恢复、FP部分和及输出共同评估。

| 项目 | 值/要求 | 状态 | 原规格依据 |
| --- | --- | --- | --- |
| 候选几何 | TM16×TN8×GS32＝4096整数乘法贡献/issue、128组dot | 推断 | 09§1 |
| 数值参考 | INT32组内精确；R0恢复；group升序非FMA FP32累加 | 推断 | 09§2 |
| 矩阵尾部 | act第二层N2仅2有效输出，物理8lane | 工程事实 | 04/09、13 |
| 输出 | F32、Linear bias按图完成后8feature/clk排出 | 推断 | 09§2/§4 |

01§6／14§9／15§10–§14定义字节、逻辑位宽与错误枚举；P0共享头、编码器和契约检查保留为历史回归。P2算术与完整图已通过当前源码/模型绑定的CPU及标准libm CSim，当前实现映射和阶段验收见页首及本文P2章节；实际生成端口、物理资源与平台系统仍需各自报告。

## 2. 原规格位置与引用

原规格统一维护在[design_source](../../../design_source/README.md)，本目录只保留`design.md`和`results.md`。采用统一规格v1.0，位置核查日期：2026-10-05（Asia/Shanghai）。点击章节编号可跳至原文对应标题。

| 原规格文件 | 对应章节 | 本模块采用的约束 |
| --- | --- | --- |
| [02_kernel_wrapper_and_platform.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:19)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:42)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md:123) | HLS/XRT部署路线、候选HBM端口及平台时钟/复位边界 |
| [05_hbm_loader_and_cache.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md) | [§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:25)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:46)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/05_hbm_loader_and_cache.md:54) | 权重/scale加载、缓存bank及F0/F1交接 |
| [08_activation_quantizer.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:38)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/08_activation_quantizer.md:46) | 量化输入格式、保存scale、A8重放与就绪条件 |
| [09_q8_linear_and_restore.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:19)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:27)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:42)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:50)、[§5](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/09_q8_linear_and_restore.md:65) | 整数dot、scale恢复、部分和、输出顺序及上下游速率 |
| [15_integration_interfaces_and_pipeline.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md) | [§1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:18)、[§2](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:26)、[§3](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:45)、[§4](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:61)、[§8](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:113)、[§9](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:131) | LN→量化→Linear供需、tile所有权与背压/复位 |

本次接口细化直接引用（2026-10-05核查）：

- [15_integration_interfaces_and_pipeline.md：§10–§16：TaskContext、类型任务、BufferRef/epoch、stream位域、done及联测](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md:145)。
- [14_result_status_and_verification.md：§10：真实Typed Q8采集合同、native/candidate边界及模块参考映射](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md:205)。
- [04_model_package_and_memory_map.md：§7：固定工作区base、HEAD_WORK子区、模型key与Q8寻址](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/04_model_package_and_memory_map.md:98)。

原规格更新后，按章节标题重新核对引用位置及受影响的接口、数值、流水和测试；当前细化与差异记录在本文，资源/性能记录在[results.md](results.md)。

## 3. 内部结构与执行阶段

| 阶段/子职责 | 输入就绪条件 | 主要动作 | 退休/交接条件 |
| --- | --- | --- | --- |
| READY | A8 tile与整张当前矩阵权重 | 检查cache/model/group上下文 | 输入和PS bank可用才发射 |
| DOT/RESTORE | 每行32A8与每列32W8 | 32项精确dot，恢复一个FP32 term | 后级PS有空间且反馈距离足够 |
| ACCUMULATE | 同输出按group升序 | acc=FP32(acc+term)，按输出tile轮转 | 最后group实际退休才可排出 |
| BIAS/DRAIN | 完整PS | 依图加Linear bias，有效feature按序送消费者 | 全部被消费后PS释放 |

各阶段名称用于解释设计，不规定实际FSM编码或强制独立实例。HLS是否共享或复制硬件须由后续综合层级报告确认。

## 4. 逻辑接口与协议

| 接口 | 方向/相邻模块 | 类型、位宽或shape | 顺序与布局 | 背压/完成条件 |
| --- | --- | --- | --- | --- |
| A8 | quant/cache→Linear | 16×32个S8/issue＋16scale | group及有效M一致，跨N复用 | cache要提供并行16行读口 |
| W8 | weight cache→Linear | 8×32个S8/issue＋8scale | 与A8同group、当前输出tile | 跨全部token tile复用 |
| 组结果/PS | dot/restore↔PS | 128 INT32→128 F32更新/issue | 每个输出的group顺序固定 | PS反馈Lacc限制真实II |
| F32输出 | PS→RoPE/向量/heads | 最多8feature/clk | QKV为Q/K/V顺序；Wi可4U＋4G配对 | 输出有效/尾部及bias阶段不能丢 |

通用交接原则：仅成功传输才推进计数；背压时未接受的数据及元信息保持一致；无效lane不参与访存/累加；尾拍不跨行。不能立即停止的浮点流水必须有空间接住在途输出，FIFO深度待真实延迟确定。

## 5. 数值、时钟与复位

- R0 term=FP32(FP32(scale_a×scale_w)×FP32(dot))；随后单独acc=FP32(acc+term)，不能FMA合并。
- R1仅在与R0 term逐位对账且资源有收益后采用；不改变组间FP32累加。
- FP16 scale次正规必须保留；scorer post bias不是Linear baked bias，分两步。

首版候选为一个用户计算域，150MHz仅分析请求；平台AXI/HBM时钟、实际端口、reset极性/同步方式及CDC位置尚待G1。复位/异常恢复要使控制、FIFO有效位、缓存所有权和旧请求身份失效；是否重装模型取决于实际平台是否保留xclbin/HBM，不提前假定。数值和物理接口改变时须同步上下游及参考模型。

## 6. 缓存、存储与数据所有权

| 对象 | 形状/容量或拥有者 | 生命周期/交接 | 限制与相邻约束 |
| --- | --- | --- | --- |
| PS双bank | 16×5248×4=335872bytes/bank | 全group更新→读出/bias→释放 | 读出8lane不足以直接接每拍128结果，整tile存储吸收 |
| A/W cache | 由05统一安排 | A8一tile跨全部输出；W一矩阵跨全部token | 输入窗口供给不能来自单个HBM逐拍直读 |

容量与端口估算详见results.md；这里说明数据何时归谁使用。模块局部引用的共享存储不得在整核资源汇总中重复相加。

## 7. 联合流水与变更传播

- 同一PS地址两次更新间距ceil(N/8)；需≥Lacc且RAM端口足够才可能每拍issue。N2只有一个输出tile，必须安全等待。
- Wi/down共享引擎；PS双bank可将dot当前tile与旧tile读出重叠，但需要真实独立端口。
- U/G相差2624列可能落同bank，配对输出需双读口或承认降速。

任何TM/TN、lane、归约顺序、缓存bank或接口版本变化，都需同时更新生产者、消费者、独立参考、流量/周期模型与联合用例。F0和F1分别计时，不能把一种方案的资源与另一种方案的延迟拼在一起。

## 8. P0历史：实现位置与验证安排

| 项目 | 路径/入口 | 当前状态 |
| --- | --- | --- |
| 维护的自定义/封装RTL | [../rtl/](../rtl/README.md) | 仅用途说明，尚无代码 |
| 本模块P0契约TB | [contract_tb.cpp](../tb/contract_tb.cpp) | 本机Release合同回归已执行；数值算子TB仍待建立 |
| P0 C++源（hls路径） | [q8_linear_and_restore.h](../../../../hls/operators/q8_linear_and_restore.h)、[q8_linear_and_restore.cpp](../../../../hls/operators/q8_linear_and_restore.cpp) | host-only合同实现；`contract_only`，不可据此综合 |
| 约束/IP/构建 | [CMakeLists.txt](../../../../CMakeLists.txt)、[module_sources.cmake](../../../../config/module_sources.cmake) | 本机C++构建已建立；平台约束/IP未冻结 |
| 集成联测 | [top/tb](../../top/tb/README.md)与相邻模块tb | P0合同总回归20/20；完整网络数值联测未执行 |

本模块P0历史注册状态为`contract_only`；当前P2映射见本文后节及页首results。正式主机端运行见[CTest原始日志](../../../../results/engineering_p0/20261005T154135Z-3872886/ctest.log)与[源码哈希](../../../../results/engineering_p0/20261005T154135Z-3872886/source_hashes.sha256)；20项包含`contract_q8_linear_and_restore`。`std::vector`/`std::map`等主机容器用于P0合同模型，尚未转换为可综合存储结构。

| 用例组 | 输入/干扰条件 | 应比较或断言的行为 |
| --- | --- | --- |
| 数值 | 实际GGUF矩阵与边界activation | q→dot→term→每group partial→最终bias输出逐级对账 |
| 反馈与尾部 | N2、M不足16、最后group延迟 | 无读后写冲突；无效lane不更新/输出 |
| 整链 | 量化→dot→恢复→PS排出并随机背压 | 真实资源/II包含全部阶段，不能只验dot |

期望值应来自独立参考和真实模型/请求，不能仅镜像实现。数值/质量准入线以14中的建议及G6最终确认状态解释；在该P0阶段没有任何硬件验证通过结论。真实命令、数据/源码hash、日志、退出码、seed及统计写入results.md。

## 9. 当前细化、差异与缺口

- 相对原规格，本次补充模块职责、阶段条件、接口责任及联测矩阵；保持模型语义和既定HLS/XRT路线。
- 工作区按用户最新指定路径统一为`vivado/module_design/q8_linear_and_restore/source|rtl|tb`；原文中的历史目录叙述只用于追溯，当前实际路径以本文为准。
- G4 DSP packing、恢复成本、Lacc、RAM绑定/真实II和Fmax；G3 R0/R1参考。

- 原规格约束本身仍为统一v1.0；微架构并行度和物理字段未因目录建立而成为已验收指标。

## 10. 本模块精确接口绑定与实现约束

本节描述完整目标合同；本轮P0实际实现和未完成的缓存关联检查见§12。

接受LinearTask(TaskContext,a,w,ps,dst,WeightKey,K,N,dst_region,bias_kind)。K/N和family由15§10.2固定；必须检查A8 rows/K/epoch、WEIGHT family/layer/K/N/model身份和空PS。一个任务计算当前rows×全部N，权重跨全矩阵token tile驻留；act K256/N2只开2列。

DotIssue按15§13.2包含task_id、a/w/ps epoch、group:u8、n0:u16、valid_rows:u5和valid_cols:u4。每次读取16×32 A8及8×32 W8，分别附16/8 scales；无效行列完全屏蔽。INT32组dot与原标签／scales一起保留至恢复，R0先FP32(sa*sw)再乘dot，再单独FP32加到PS。同一输出group严格升序；反馈未退休不能再次改写同一PS地址。

PS按row*8+n%8的128逻辑bank、addr=n//8组织。实际RAM端口和FP latency不足时插入停顿，不改归约顺序。最后group退休后按row/col升序加绑定Linear bias并排F32Beat；每行N8向上取整拍，N2有效数2。scorer baked bias与后续vector post bias保持两次操作。QKV column0…1023/1024…2047/2048…3071对应Q/K/V，由store scatter到04地址；Wi保持U整半/G整半，不能在通用输出流误标为连续4U+4G。

done在PS读出全部接受、目的写响应完成之后；PS和A8在此之前不可复用。真实矩阵权重必须源自固定GGUF逆重排，输入来自abi_replay对应节点。native Linear输出及直接捕获activation scratch是模型参考，候选q/dot/term/PS应另行独立生成；尚无candidate实现，不声称R0/R1或全网逐位通过。TB联接quant/cache/Linear/store，覆盖真实QKV、Wi、down、act N2及恢复流水末拍长停顿。

## 11. 原生参考采集历史入口与验证状态

以[ABI兼容真实回放manifest](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json)为硬件候选模块TB的模型数据入口；原输入身份见[original_native manifest](../../../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json)，帧与规范化差异见[fixture_metadata](../../../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)。同一manifest内用semantic_aliases或真实节点id查文件，按GGML ne/nb读取非连续数据，保留hash；候选硬件派生中间值另命名，不覆盖native数据。

本次软件已实际运行固定Typed Q8、CPU单线程、原生S94与ABI兼容S128两种输入；软件捕获耗时含全节点导出，不能当GPU/FPGA性能。三个硬件tag为离线fixture零占位，不能提交生产kernel。尚未执行本模块HLS C仿真、RTL/XSim、综合、布局布线、时序或U55C测试；具体采集入口与缺口统一见14§10，平台/结果记录见[results.md](results.md)。

本模块已核查的`abi_replay/manifest.json`语义alias（均为实际捕获，完整shape/stride/hash从manifest读取）：

| alias | 原生节点 | 数据位置（相对abi_replay） |
| --- | --- | --- |
| `enc0_qkv` | `ir_237 / linear` | `native/forward_0/ir_237.bin` |
| `enc0_attention_project` | `ir_266 / linear_1` | `native/forward_0/ir_266.bin` |
| `scorer_fc1_with_bias` | `ir_1461 / linear_120` | `native/forward_0/ir_1461.bin` |
| `act_raw_logits` | `ir_1616 / linear_123` | `native/forward_0/ir_1616.bin` |

量化的直接backend参考另见manifest的`native_quantized_activation_scratch`：122次实际MUL_MAT输入scratch，34B/组（FP16 d＋32 S8），每项记录consumer node、shape、bytes和hash；例如`audited_outputs/native_q8_activation_linear.bin`对应Encoder0 QKV。硬件candidate dot/term/PS内部值尚未导出/实现，不能据此宣称这些值已逐位验证。

本批数据覆盖退款noul与部门choice两题；qtype1/score、B1、其他S档和质量集未在本批采集，保留待测。全节点齐全不代表全部输入范围或候选硬件数值已验收。

## 12. P0历史审核范围与当时的计算链接入前置项

2026-10-05由GPT-6 Astra（xhigh）按[任务记录](../../../../hardware_agent/task.md)§10.7核定。当前实现核对LinearTask的op/WeightKey/stage/行空间/K/N/目的region、输出数量、N2尾列和DotIssue字段；状态辅助检查只核对A8/W的epoch及Q8_TILE/Q8_WEIGHT内容类型。尚未把A8的K/rows/batch/row0/row_space及源epoch、W的WeightKey/K/N与当前任务逐项关联；该绑定、PS反馈退休和真实点积/恢复运算必须在后续计算链前补齐。

本轮只验收host-only C++基础合同；可综合数值实现、HLS C仿真、RTL/XSim、综合、布局布线、时序、xo/xclbin和上板均未执行或未完成，结果以[results.md](results.md)记录为准。

## 13. P1完整K的Q8-F输出窗口（2026-10-07，Astra xhigh）

本轮实施和验收以[task.md §11](../../../../hardware_agent/task.md)为共同合同；重读[09§2/§3/§5](../../../design_source/09_q8_linear_and_restore.md)、[总体§5.1/§5.4](../../../../source/laya_baseline_design.md)及[15§10–14](../../../design_source/15_integration_interfaces_and_pipeline.md)。本节是全矩阵Linear内部切片合同，保持原§10全N任务及单forward路线；切片返回不发布整张QKV/WI/TMP，不生成全Linear TaskDone或满足全层coverage。

唯一新维护源`hls/operators/q8_linear_compute.cpp`；公共接口`include/laya_numeric.h`及`laya_numeric_tasks.h`；模块`tb/numeric_tb.cpp`、独立`tests/numeric_reference.py`和top真实fixture驱动。输入完整LinearTask的K/N/WeightKey仍按原规格，另给n0为8倍数及cols=min(8,N-n0)。rows≤16、完整K=256/1024/2624/4096，A8数组`q[16][128][32]`/scale[16][128]、W窗口`q[8][128][32]`/scale[8][128]、bias[8]，输出F32[16][8]及slice状态。有效cols以外不读写，act N2只访问2列。

任何计算前将A8的请求全身份、ref/epoch、K/rows/batch/row0/row_space、stage/layer和原F32 src/region/epoch与当前任务及**独立expected source**匹配；W必须匹配model/request/generation/数值/布局/构建身份、WEIGHT ref、family/layer、完整K/N、n0/cols和bias绑定。READY覆盖的是窗口cols×K/32，不能冒称整个W缓存已加载。切换窗口先失效并换epoch；READ/FILL/缺coverage、旧request/generation、错WeightKey或来源都必须拒绝。PS/结果初始invalid，所有group和bias完成才发布rows×cols；失败不发布，返回即切片全部访问结束。

每个输出的INT32 dot是32个S8乘积精确之和，sa/sw从原FP16位模式扩展；R0 term=FP32(FP32(sa×sw)×FP32(dot))；acc初始+0，group严格升序单独FP32相加，最终有绑定bias才加一次，不能无bias额外+0或把scorer post bias合并。保留half次正规及signed-zero term，所有恢复/累加中间必须有限。负有限scale非法，-0保留IEEE零语义。q/scale/dot/term/每group partial与独立oracle逐位验收，native GEMM只报告误差。R1和其他归约版本不在本批实现范围。

切片先逐row/col/group/k串行；单个acc完成后再做下一group，无错误DEPENDENCE pragma，无II=1保证，不展开TM16×TN8阵列。8列W最大34816B、输出最大512B是逻辑容量；实际RAM端口/资源/II以isolated综合报告为准，不能借用原候选阵列的吞吐估算。外部生产W整矩阵常驻、A8复用和完整PS设计仍保留待集成。

真实权重窗口：QKV n0=0/1024/2048/3064；Wi n0=0/2616/2624/5240；down n0=0/1016；act n0=0、cols2，两题分别BATCH rows1。每列完整K不抽减；q/half scale按GGUF offset逆拼34B逐字节核验。主联链ir_267→候选LN→候选quant→Wi，另外native quant输入隔离比较、K2624末group、K256/N2及真实act bias必须覆盖。trace逐group对账，定长输出guard确保无效列不写。状态差异、native差异和数值例外不能由最终答案一致掩盖。结果/工具/未执行硬件阶段独立记录在[results.md](results.md)。

## 14. P1实际代码映射与窗口所有权（2026-10-07）

- [q8_linear_compute.cpp](../../../../hls/operators/q8_linear_compute.cpp)为完整K的row/col/group/k串行计算入口及只读`q8_linear_trace`回放入口；[laya_numeric.cpp](../../../../hls/common/laya_numeric.cpp)完成A8来源、W窗口/完整权重与偏置字节范围、请求四tag、PS与目的ref的验证和owner生命周期。P0 [q8_linear_and_restore.cpp](../../../../hls/operators/q8_linear_and_restore.cpp)仍为主机合同模型。
- 每列先逐group计算32项精确I32 dot，再按FP16→F32、scale乘、dot乘和group升序FP32累加；只有bias_kind=1在所有group后额外加一次。入口先验证独立预期F32来源、A8和W元数据，PS/目的两个ref一起领取新epoch并置FILL；全部rows×cols成功后置READY并记录精确输出数，`output_beats=0`。失败保持已领取epoch且不发布部分数组，reset清输出计数但不倒退PS/dst版本。
- [numeric_tb.cpp](../tb/numeric_tb.cpp)覆盖±127乘积极值、组内抵消、±0 term、2²⁴/1/−2²⁴组顺序舍入反例、act bias与N2 guard、补充K4096/128组末项、A8和W逐字段变异及PS/dst双ref生命周期。[numeric_fixture_test.py](../../top/tb/numeric_fixture_test.py)逐有效row/col/group回放dot/term/partial，并按GGUF完整K/N字节范围及n0窗口读取真实权重；native输出和scratch仅做差异报告。
- [numeric_hls_linear.cfg](../../../../config/numeric_hls_linear.cfg)对实际计算入口执行isolated CSim。该切片不输出完整Linear TaskDone、不发布整矩阵覆盖，也不连接生产HBM/PS AXI或QKV scatter；本轮Linear综合/布局布线未执行，阶段性证据见[results.md](results.md)。


## P2 B批完整任务与存储（2026-10-07，RELEASE_TO_IMPLEMENTATION）

依据本次实际读取的[原规格](../../../design_source/09_q8_linear_and_restore.md)、[15§10–15](../../../design_source/15_integration_interfaces_and_pipeline.md)及[task.md §12.4](../../../../hardware_agent/task.md)，由Astra xhigh核定。

P2 LinearTask计算同题rows≤16的完整K/N，W已完整驻留；PS每tile领取一次，内部n0窗口既不递增共享dst epoch也不发完整done。可提取P1纯单输出算术共同维护，禁止复制漂移。完整tile所有N/bias/写回结束后done=rows×N并登记目的覆盖；QKV按plane/head/feature散写，两shard全覆盖才RAW_READY。scorer FC1同SCORER_ACT原地通过旧/新epoch lease逐行消费后覆盖。

唯一实现/接口责任和测试边界以task§12.4为准；Sol max维护实际代码映射与运行证据，独立测试代理覆盖真实数据、完整尺寸、边界与owner反例。本节是已释放实施合同，不是已执行PASS；完整前向还需C批。


## P2实际实现映射（2026-10-07）

- [q8_linear_compute.cpp](../../../../hls/operators/q8_linear_compute.cpp)：本模块当前P2实现责任源。
- [full_tasks.cpp](../../../../hls/operators/full_tasks.cpp)：本模块当前P2实现责任源。

所有完整任务共用[固定POD运行上下文](../../../../include/laya_full_runtime.h)与[显式任务源绑定/读写辅助](../../../../hls/operators/full_task_common.h)，按独立生产者spec校验stage/layer/row/epoch，不从实际owner自抄期望。编译源以[full_sources.cmake](../../../../config/full_sources.cmake)为准；源码存在与分层测试不代表完整图/平台通过，当前运行范围以[results.md](results.md)为准。


## 综合内存修复历史 f1a 阶段（2026-10-07）

[综合内存修复合同 r1](../../../../results/synthesis_memory_fix_20261007/repair_plan.md)是本轮唯一修复合同；原规格仍由本页既有章节定位，当前F0数值/所有权约束优先按task.md §12.2/§12.4–12.5执行。

本模块仅把实际使用的数值cache数组接入固定访问器；数组shape、元素类型、请求/任务上下文、数值leaf、算术顺序、有效范围和发布/读取边界保持。synthesis解析到对应唯一全零global，CPU保持每Runtime独立数组。共享存储组织、初始化/回收合同和唯一64bit存储打包由kernel_wrapper及hbm_loader_and_cache统一维护，不另复制数组或增加并行算术实例。

历史f1a阶段在Laya-repair-20261007副本完成缓存/owner结构修复；[当时源码差异](../../../../results/synthesis_memory_fix_20261007/source_identity_diff.json)及[失败的完整顶层尝试](../../../../results/synthesis_memory_fix_20261007/csynth_full/full_csynth_result.json)保留：该次在`SYNCHK 200-42`停止，没有完整RTL。后续五文件指针控制修复与新tag最终结果见下节。


## 综合内存修复现行代码映射（04934，2026-10-07）

[总报告](../../../../results/synthesis_memory_fix_20261007/report.md)和[五文件当前源码差异](../../../../results/synthesis_memory_fix_20261007/followon_r1/new_identity_r1/pre_export_source_delta.json)绑定现行build tag `04934c15b3f83e842ec2e92ac2a81bf2`。Q8矩阵与恢复算术文件逐字不变；固定cache访问器和打包仅改变存储组织，不改变Q8位模式、缩放/偏置顺序或F0发射合同。 13口接口、数值/布局tag、九个算术文件、§12.2数值前像及owner/恢复合同不变。现行完整顶层已由真实25生产源生成RTL；HLS资源预算与未执行的物理阶段见本模块[results.md](results.md)。
