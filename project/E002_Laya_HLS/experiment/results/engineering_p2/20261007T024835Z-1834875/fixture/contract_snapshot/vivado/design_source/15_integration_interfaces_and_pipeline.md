# 15 模块接口和流水：沿着数据流一起评估

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

本文件是各模块共同使用的设计入口。先回答“谁生产、谁消费、何时可读”，再评估并行度。对应baseline的HLS函数/数组/stream组织，但这里的多token tile和双缓存是Laya新增设计。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 共同设计要求 | 关联模块一起定义接口、性能、流水和验收 | 当前用户明确要求且前文持续要求 | 明确要求 | U1/U2 |
| 内部接口方案 | HLS函数、缓存、固定类型stream；不用CMD256 | 尚无类型头/有限FIFO实现 | 推断 | S3；02、本文§2 |
| 性能口径 | 服务周期、首填/排空、共享资源与访存争用分别计 | 现有数据均为候选配置下的算例 | 推断 | 本文§4–§6；05、09、11 |
| 接口细化／物理缺口 | §10–§16确定逻辑字段、标签、buffer与完成协议；生成端口、FIFO深度、IP latency及物理bank仍待实测 | 文档合同已细化，无HLS/RTL生成报告 | 推断／待确认 | G1/G2/G4；本文§10–§16 |

## 1. 先统一计数单位

一个feature是一个向量元素；一个token有1024个hidden feature；一个量化group有32个输入值；一个token tile最多16行。Linear写成 `X[M,K]×W[N,K]转置`，M是token/marker行数，K是输入宽度，N是输出宽度。

统一分析配置：TM=16行、TN=8列、group=32；普通向量8feature/clk；GELU/gate和exp各4-lane；浮点引擎64路；时钟请求150MHz。这些是待实现配置，不是baseline已有性能。

B2/S128共有256个token，即16个token tile。先分清“一个tile”“一张矩阵”“一层”和“整个请求”，否则会把权重装载重复算16次，或把层间开销漏掉。

## 2. 首版接口采用什么形式

HLS顶层只对Host暴露02的BO参数；内部由函数调用和固定长度数组/`hls::stream`连接。共享C++头文件定义数据类型、有效行数、tile坐标和版本。首版不采用通用CMD256，也不让各模块自己解释一套动态view ID。

| 生产者 → 消费者 | 数据与顺序 | 必须共同遵守的交接条件 |
| --- | --- | --- |
| 加载器/embedding → LN | 每题、每token、每行1024个F32；普通通路每拍最多8值 | 完整行统计后LN才输出；暂停时不丢拍 |
| LN/向量 → 量化 | 行优先FP32，K和有效行数随任务固定 | 每32值一组；保存至第二遍读取完 |
| 量化 → A8 cache → Linear | 每组32个S8和一个FP16 scale；写入按行/组 | 完整tile就绪；阵列通过多bank并行读16行 |
| 权重cache → Linear | 同组的8个输出列q及scales | q/scale标签及offset一致，跨所有token tile复用 |
| dot → 恢复/PS | 一次最多128个INT32 group结果 | 保留group顺序；后级有空间才发射 |
| PS → 普通消费者 | 加Linear bias后，按行/列排出F32，最多8值/clk | 全部group退休后可排出，排出完前不可覆盖 |
| Wi PS/存储 → GELU/gate | 同一token的4个U与4个G | 索引配对；证明双读口；输出每拍只有4值 |
| QKV/RoPE → attention | 按04的head布局存Q/K/V | 整层最终写入完成；携带相同b/head/位置上下文 |
| QK → softmax → AV | 一query对应S个score/prob | 行max/sum结束后prob才可读，AV保留key升序 |
| FPGA → Host | candidate `[B,16]`、act `[B,2]`及状态 | 等kernel完成和BO同步，校验身份后解码 |

8-lane通路在150MHz满拍是4.8GB/s，512bit AXI满拍是9.6GB/s。打包/拆包不能凭空消除这个差异。部分拍只有4个有效值时明确valid_count=4并前移4列；一拍不跨行。数量、顺序和有效lane在软件参考与RTL中都做断言。

## 3. 缓存交接的规则

每块缓存依次经过：空闲 → 正在填充 → 完整可读 → 正在计算/读取 → 排出完成 → 空闲。记录当前tile/矩阵及有效范围，复用前清除旧有效状态。

| 缓存 | 生产者认为“完成”不够的地方 |
| --- | --- |
| LN行buffer | 统计完成后还要第三遍输出，不能马上接入覆盖 |
| A8 tile | 写完后仍由当前矩阵的所有输出tile读取 |
| W0/W1 | 当前矩阵全部token tile结束才可装另一张权重 |
| PS0/PS1 | 最后group算完后仍要bias和窄口排出 |
| KV | 当前head全部query完成后才能换下一head |
| score/prob | softmax原地改写后，AV最后读完才可复用 |
| 旧hidden | residual最后读完才可覆盖 |

短FIFO只能吸收有界停顿。深度必须覆盖已发射但尚未输出的数据以及回压传播延迟。HLS C仿真的stream行为不足以证明有限FIFO不会死锁，需要RTL/平台联测。

## 4. LN→量化→Linear的一次tile评估

以QKV、16行、K1024/N3072为例：

| 阶段 | 理想服务cycles | 依赖 |
| --- | ---: | --- |
| LN三遍 | 6144 | 完整行统计、scalar尾另计 |
| 量化两遍 | 4096 | 完整group统计后重放 |
| dot/group累加 | 12288 | A8和当前权重就绪、反馈间距足够 |
| 最终结果读出 | 6144 | PS全部group完成 |

F0按真实串行阶段累计。F1a若把LN输出送入量化第一遍，量化第二遍仍需2048cycles。因此首个A8 tile至少要考虑6144+2048及尾延迟，不能缩成一遍2048cycles。

使用双A/双PS后，可研究下面的重叠：

```text
准备A                 → dot A                 → 排出A
                         准备B               → dot B            → 排出B
                                                 准备C          → dot C
```

只有准备、dot、排出使用独立计算资源和不同缓存，才可能用最慢阶段决定稳态间隔。首次填充、末次排空、共享master争用和scalar/FP反馈仍要加上。不能仅写一个DATAFLOW pragma便声称取得该重叠。

## 5. Attention链的共同评估

QKV先完成旋转和head重排，随后读当前head的K/V。QK与AV共用浮点引擎，时间相加；softmax独立，但需要完整行和score/prob存储。

一个题、一个head、16query/S128：QK2048cycles，softmax三阶段1024cycles，AV2048cycles，结果读出128cycles，串行理想共5248cycles。加载、FP尾、反馈与模式切换另外计算。

双score bank可以让另一tile的softmax与QK/AV重叠；不能让同一个浮点引擎同时算QK和AV。一个head只从一个QKV shard读，两个HBM端口总带宽不能直接算给它。

## 6. FFN链的共同评估

Wi的16行dot20992cycles，U/G配对与4-lane GELU/gate各需10496cycles。down的8-lane输入量化10496cycles、dot10496cycles，读出2048cycles。

Wi与down共用整数引擎，所以这些矩阵计算不能并行。F1a保持矩阵顺序，省Wi外存往返；F1b单tile切换Wi/down则需要两张权重常驻，减少下一矩阵预取机会。

如果直接用4-lane gate供给量化，第一遍捕获需要10496cycles，第二遍8-lane重放需5248cycles；第一遍可与GELU重叠，但不能同时按8-lane算两遍。残差另需旧hidden读口，最终结果写完才能换hidden角色。

## 7. 各模块必须一起提交哪些证据

| 共同设计任务 | 同时提交的产物 |
| --- | --- |
| Host/平台/IO | 参数表、BO/bank表、共享头文件、真实请求与回放结果 |
| LN/量化/Linear | 中间数值、每拍数量、缓存读写口、反馈延迟、首tile和稳态时间 |
| QKV/attention | 地址转换、完整就绪屏障、KV/score生命周期、共享浮点引擎时间轴 |
| FFN/residual | U/G配对、4/8-lane转换、两权重驻留代价、旧hidden存活图 |
| 完整决策 | 16列、1028维、raw logits/act特征、Host温度和整请求计时 |

实现顺序与放行标准见[14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)。改变tile、位宽、归约、banking或并行关系时，同时更新生产者、消费者、参考程序、资源/流量和联合测试。模块本身正确之后，还要证明连接后的系统正确且供需匹配。


## 8. 共同的握手、背压、错误和复位规则

下面是本版拟采用的接口行为（状态：推断）。实际HLS信号、FIFO深度和CDC实例待G1/G2/G4补齐；这里不创建另一套手写信号总线。

| 接口种类 | 一次交接何时成立 | 停顿/错误时应怎样处理 | 完成条件 |
| --- | --- | --- | --- |
| Host→kernel控制 | XRT按生成参数表提交一个run | 单session忙时不覆盖IO/工作区；合法性错误关联本次身份 | 对外完成还需输出/状态写回结束 |
| HLS函数/数组 | 函数返回且数据已写入相应buffer | 明确唯一写者；消费者不读尚未有效的元素 | 所有有效元素可读，尾部不泄漏旧值 |
| 内部hls::stream | 写入/读出成功才计数；若转换为ready/valid则两者同拍有效 | 阻塞时数据/位置/有效lane稳定；数据与元信息一起推进 | 已发射的全部输出被接收，数量与shape匹配 |
| AXI m_axi | 按生成接口的地址/数据/响应握手 | 4KiB边界、byte对齐、outstanding与返回空间一致 | 写入及依赖的响应/排空条件满足后再发布buffer可读 |
| 模式/请求切换 | 前一任务占用的引擎与缓存已经释放 | 出错后使对应结果无效；不能按正常成功路径提交 | 在途运算和返回不再引用旧上下文 |

普通F32数据通路计划每拍最多8值（256bit有效payload），gate最多4值；Q8组是32个S8＋16bit scale的逻辑对象，有效payload为`32×8+16=272bit`，片上阵列另按16行/8列分bank读取。本次逻辑stream位域及任务字段见§10–§14；它们是HLS类型/适配器合同，不是已经生成的外部AXI流。任务参数与逐拍数据元信息分开，公共数值和布局标识锁存在请求上下文，不恢复旧CMD256。

尾拍不跨逻辑行；无效lane不参与求和、访存或输出计数。有限FIFO需要同时满足稳态速率和在途输出容量。对无法立即停止的FP流水，须保留能接住已发射结果的空间；简单降低ready不能取消在途结果。

复位方案统一跟随02§8：控制器、算子和缓存有效状态按同一请求边界恢复；不在模块内部各自猜测复位极性。必须设计空闲复位、运行中恢复、下游长期暂停、最后写响应延迟及恢复后第一请求的联合用例。可预测的输入/数值错误由kernel返回；无法捕获的设备/AXI故障由Host/runtime处理，不能强求故障kernel仍一定写出状态帧。

## 9. 联动修改表

| 谁修改什么 | 必须同步修改的相邻设计 | 同时重新评估 |
| --- | --- | --- |
| 01/02改IO、参数或master | 04地址/BO，14结果，Host/HLS同源头 | 请求回放、越界、bank容量、平台连接 |
| 05/09改TM/TN/缓存bank | 08 A8供给，10 QKV排出，12 U/G配对 | SRAM端口、PS读写、FP反馈、真实II和资源 |
| 07/08/12改lane或数值顺序 | 09矩阵输入和13尾层 | 首tile/稳态/排空时间、后续q变化、质量 |
| 10/11改QKV布局或attention调度 | 03屏障、04地址、05 KV/score生命周期 | head带宽、QK＋AV共享时序、mask/RoPE正确性 |
| 13改候选或act路径 | 01解码、07/09/11/12共享单元、14结果 | 16列语义、1028尾部、温度和完整请求耗时 |
| 02改时钟/平台/复位 | 所有模块与Host恢复流程 | cycles换算、CDC、约束、时序和复位后首请求 |

所有模块共用同一model/numeric/layout/build标识。当前文件是这些标识的规格输入；实际版本号与内容hash由未来构建产物记录，不能把文档修订号当成可运行硬件版本。


## 10. F0执行合同和公共类型

本节至§16为2026-10-05由GPT-6 Astra（xhigh）补充的**拟实施合同**，用来生成下一步的HLS类型、参考回放和TB。不会把文档字段冒充已生成RTL端口。顶层保持单HLS C++ forward核→Vitis xo/xclbin→XRT；细化的ready/valid语义可用于HLS stream和后续RTL适配。150MHz、TM16/TN8/GS32、64路FP及13个master仍是候选配置，实际延迟、banking、FIFO深度由综合/平台证据冻结。

### 10.1 一个算子任务在途

F0控制器同一时间最多接受一个算子任务；任务完成应答被接收后才能发下一任务。计算任务一次处理同一题的最多16行，不能跨batch；模型/整head加载及IO校验/结果提交是控制范围例外，其数量由固定descriptor决定，TaskContext取batch=0、row_space=BATCH、row0=0、rows=1作为诊断上下文；Linear一次处理该tile全部N列，QK/softmax/AV分成三个串行任务。加载当前权重、计算、排出亦由任务或任务内部阶段明确串行；F0不启用下一矩阵预取、下一tile并发或LN→quant融合。W仍跨当前矩阵所有token tile驻留，避免重复HBM加载。

请求上下文`RequestContext`只在一次run开始锁存：`request_id:u64, generation:u64, B:u16, S:u16, model_tag/numeric_tag/layout_tag/build_tag:各128bit`及五个已验证的固定输入view。Host ABI masks为U8；原生Typed图masks为F32，回放只把恰好0.0/1.0转成U8，算术时精确恢复0.0/1.0（01§2、14§10）。此上下文不重复塞入每拍payload。

`TaskContext`为每类任务的共同参数前缀，C++结构体不规定总线序列化padding；字段所列位宽是逻辑值域，HLS可用`ap_uint`或经断言的标准整数承载。

| 字段 | 位宽／合法范围 | 语义 |
| --- | --- | --- |
| task_id | u32；1…0xfffffffe | 当前请求内严格递增，0保留；禁止回绕 |
| op | u8；§10.2枚举 | 当前算子，拒绝未知值 |
| stage | u8；0…7 | 0校验、1embedding、2encoder、3final/type、4decision、5scorer、6act、7result |
| layer | u8 | encoder0…27，decision0…1；其他stage=255 |
| batch | u8；0…B-1 | 当前题 |
| row_space | u8；0/1/2 | TOKEN／MARKER／BATCH，见04§7 |
| row0 | u16 | TOKEN为0…S-1，MARKER为0…15，BATCH必须0 |
| rows | u8；1…16 | TOKEN row0+rows≤S；MARKER≤16；BATCH必须1 |

不存在通用payload union／通用CMD256：LN、quant、Linear、attention等各自有下表中的类型和合法组合，op只用于检查／trace，不用于解释任意位串。任务的所有参数在接受时锁存并保持至done；默认未用字段为明确哨兵（layer/head=255、NONE引用），不接受“忽略垃圾值”。

### 10.2 算子枚举与合法范围

以下使用十六进制编码；任务参数中的算子名称对应唯一值。若功能辅助步骤没有独立调度任务（如mask融合在QK），可在trace记同一task的子阶段，不另发伪done。

| 值 | 名称 | 合法stage／主要尺寸 |
| --- | --- | --- |
| 01／02 | EMB_TOKEN／EMB_TYPE | 1／3；token D1024，type3×1024 |
| 10／11／12／13／14 | LN_EMB／LN_ATTN／LN_FFN／LN_FINAL／LN_MARKER | 1／2或4／2或4／3／5；D1024；Encoder0禁止LN_ATTN |
| 20 | QUANT | 2、4、5、6；K=256/1024/2624/4096 |
| 30／31／32／33 | LIN_QKV／LIN_WO／LIN_WI／LIN_DOWN | Encoder；K,N分别(1024,3072)/(1024,1024)/(1024,5248)/(2624,1024) |
| 34／35 | LIN_DEC_FC1／LIN_DEC_FC2 | Decision；(1024,4096)/(4096,1024)；Decision QKV/Wo复用30/31 |
| 36／37 | LIN_SCORER_FC1／LIN_ACT_FC2 | 5／6；(1024,1024)/(256,2) |
| 40 | ROPE | 2；head0…15，Q/K，full或slide；Decision禁止 |
| 50／51／52 | QK／SOFTMAX_ATT／AV | 2或4；head0…15，M≤16，S个key，DH64 |
| 53／54／55 | FP_SCORER_FC2／FP_ACT_FC1／SOFTMAX_CAND | 5／6／6；(1024,1)/(1028,256)/16列 |
| 60／61／62／63 | GEGLU／RELU／ADD_RESIDUAL／ADD_TYPE | 2／4／2或4／3；2624／4096／1024／1024 |
| 64／65／66 | BIAS_GELU_SCORER／BIAS_GELU_ACT／APPLY_CAND_MASK | 5／6／5；1024／256／16 |
| 70／71／72 | GATHER_MARKER／CAND_STATS／CONCAT_ACT | 5／6／6；16×1024／16→4／1024+4 |
| 80／81／82／83 | LOAD_W／LOAD_KV／LOAD_LN_PARAMS／LOAD_ROPE | 依绑定模型／stage；不得在使用者持锁时覆写 |
| 84／85 | IO_VALIDATE／RESULT_COMMIT | 0／7；顶层伪算子用于trace，非另一个kernel |

op=30/31的WeightKey由stage区分Encoder family1/2与Decision family5/6，禁止仅按op忽略stage/layer。其他WeightKey固定见04§7.1。gamma、bias、RoPE表用绑定manifest的常量索引，禁止Host任意指针。

## 11. BufferRef、物理bank与发布条件

`BufferRef={buffer_id:u8, bank:u8, epoch:u32}`。HEAD_WORK额外由任务中明确的region限定所有权键`(buffer_id,bank,region)`；其8个不重叠子区各有独立epoch/state/coverage，读写函数必须同时接收ref和region，禁止只拿id10访问整个容器。其他buffer的region恒0，按整个buffer实例管理。NONE={0,0,0}；其他epoch为1…0xfffffffe。bank是一个完整逻辑存储实例（或QKV的head shard），不是RAM内部lane bank。04§7规定HBM buffer id 1…11；以下规定片上cache id。每个引用还受当前RequestContext/generation绑定，跨请求缓存有效标记全部重建；只读模型可保留但须重验标签。

| id（hex） | cache／合法bank | 逻辑形状 | 内部读写映射合同 |
| --- | --- | --- | --- |
| 20 | LN_ROW／0、1 | F32[1024] | lane=d%8，addr=d/8；三遍结束才释放 |
| 21 | QUANT_INPUT／0、1 | F32[16,4096]最大 | 每行完整保存；用K而非最大宽度界定有效元素 |
| 22 | A8／0、1 | S8[16,128,32]＋F16[16,128] | row为16个独立逻辑bank，每bank一次读32q＋1scale |
| 23 | WEIGHT／0、1 | 每bank5709824bytes最大Q8容量，按当前N,K解释 | output lane=n%8为8逻辑bank；addr=(n//8)*G+g，读32q＋scale |
| 24 | PS／0、1 | F32[16,5248]最大 | 128逻辑bank：row*8+n%8；addr=n//8；每个bank同地址反馈不得抢读写 |
| 25 | KV／0、1 | F32[2,2,1024,64] | 第一轴K/V；d为64逻辑bank；addr=b*1024+s；跨该head全部query复用 |
| 26 | SCORE_PROB／0、1 | F32[2,16,1024] | row固定1024stride；QK→score、softmax独占原地改写→prob、AV最后读完释放 |
| 27 | Q_TILE／0、1 | F32[2,16,64] | d为64逻辑bank；只开放当前batch与rows |
| 28 | AV_PARTIAL／0、1 | F32[2,16,64] | 64路partial；key严格升序，同输出反馈退休后再更新 |
| 29 | ROPE_HEAD／0、1 | F32[64] | 必须完整保存0…63才能做前后32配对 |
| 2a | LN_GAMMA／0、1 | F32[1024]每bank | bank0 emb gamma、bank1 final gamma；model tag绑定只读 |
| 2b | ROPE_TABLE／0、1 | F32[2,1025,64]每bank | bank0 full、bank1 slide；首轴Q/K表，模型位模式只读 |

以上内部bank是**端口供给要求**，不是已证实BRAM/URAM能够实现的映射；HLS综合要核查实际RAM拆分、复制和读写时序。W/PS总双缓存容量预算保持05；F0只使用满足依赖的bank，另一bank存在不构成并发许可。U/G相差2624=328*8，因此落同一PS lane bank；F0从HBM WI分两次读并暂存4U/4G配对，或证明cache具有所需双读口，不能凭表宣称一拍可读。

状态编码`FREE=0,FILL=1,READY=2,READ=3,EXCLUSIVE_RW=4,DRAIN=5,INVALID=6`（u8）。控制器先从FREE/INVALID领取bank并递增epoch，创建FILL；写者只接受该epoch。逐tile完成登记覆盖范围；只有目标逻辑矩阵/行的全部期望元素已写、所有相关响应退休才发布READY。一次tile done不代表整层QKV就绪。reader持同一epoch从READY进入READ，最后一个预定使用者完成后释放。F0可复用READY的A8/W，但禁止在reader仍可能引用时开始下一epoch。

矩阵整体填充按行覆盖，任务内部核对每行准确元素数量；controller记录每个已完成tile的row范围并拒绝重叠/遗漏。QKV额外记录plane/head/B/S覆盖；RoPE原地操作进入EXCLUSIVE_RW，此时外部读者禁止访问，全部Q/K写回后以新epoch发布FINAL_READY语义。raw/final由buffer元数据`content_kind:u8`区分：0未定义、1普通F32、2QKV_RAW、3QKV_FINAL、4Q8_TILE、5Q8_WEIGHT、6SCORE、7PROB。content_kind与op不匹配立即E_BUFFER。

原地算子的src/dst为同buffer_id/bank/region而不同epoch：src引用已发布旧版本，dst是controller预留的下一版本；取得EXCLUSIVE_RW后，仅当前转换阶段内的任务可读旧epoch并写新epoch，其他reader禁止。多tile转换沿用这一对epoch，所有tile覆盖和响应退休后才发布新版本，失败则旧/新版本均作废。TYPE_ROWS在请求开始领取一次epoch，按3个type_id分别记录有效位；EMB_TYPE只填本请求所需行，任意已发布type行允许读取，未装载行禁止读取。补填另一type行保持同一请求epoch且需无并发reader（F0满足）；不把未装载行标READY，模型/请求切换时重建有效位。

同一逻辑buffer的物理别名共用占用锁（WI/DEC_FF）；HIDDEN新bank部分填充期间旧bank仍可读，全部residual任务及写回完成后才交换旧/新角色。epoch/task_id都禁止回绕；达到上限须在完全idle时结束session、更换generation并重建状态。epoch不是断电持久身份，复位后靠Host恢复和新generation拒绝旧结果。

HEAD_WORK各region独立epoch允许最终candidate在后续act阶段持续有效；产生STATS或ACT_HIDDEN不能使CAND_MASKED失效。src/dst同id10但不同region属于不同对象，不作原地冲突；同region转换按EXCLUSIVE_RW规则。该限定同样适用于模块design.md中的所有HEAD_WORK引用。

## 12. 分类型任务参数与数组访问

下列类型均先含TaskContext。`ref`表示完整BufferRef，`WeightKey`包含family:u8/layer:u8，NONE={family=0,layer=255}；K/N/D/length用u16，byte offset/length用u32并在u64上验界。bool为1bit。参数在任务接受时验证，不能到读cache时才发现越界。HBM、片上数组访问不携带逐拍stream头；访问上下文从任务和BufferRef得到，由owner执行明确的read/write函数。

| 类型／使用者 | 额外字段（位宽） | 输入／输出与合法组合 |
| --- | --- | --- |
| EmbeddingTask | table:u8(0 token/1 type), dst:ref, type_id:u8(0…2或255) | token任务从已验证input_ids[b,row0+i]取I32 ID，输出rows×1024；type任务rows=1、BATCH，type_id=qtype[b]，dst=TYPE_ROWS对应行；不得将mask为0的token省略 |
| LayerNormTask | src,dst:ref；gamma:u8(0无/1emb/2final)；D:u16=1024；eps_bits:u32=0x3727c5ac | LN_EMB只用gamma1，LN_FINAL只用gamma2，其他gamma0；LN_ATTN/FFN为HIDDEN→NORM；LN_EMB/FINAL为HIDDEN→NORM或另一HIDDEN bank；LN_MARKER为MARKER→HEAD_WORK.SCORER_ACT(region0)；三遍centered variance，src/dst不能物理重叠 |
| QuantTask | src,a_dst:ref；K:u16；src_region:u8；input_lanes:u8(4或8) | F0从已就绪F32数组读、input_lanes=8；HEAD_WORK时src_region明确指ACT_HIDDEN等；K合法集合见op20；完整tile后发布A8 |
| LinearTask | a,w,ps,dst:ref；weight:WeightKey；K,N:u16；dst_region:u8；bias_kind:u8(0无/1绑定Linear bias) | rows≤16，A8的K/rows和W的K/N必须匹配；PS覆盖rows×N；N2只2lane；QKV输出按column plane/head scatter；普通目标行优先；scorer这里只加baked bias |
| RopeTask | src_qkv_ref[2],dst_qkv_ref[2]；head:u8；mode:u8(0full/1slide)；table_set:u8(同mode) | 仅Q/K两plane，row0位置不含batch偏移；读取原head完整64后覆写；V不变；必须有全层RAW屏障 |
| QKTask | qkv_ref[2],kv,score:ref；head:u8；mask_mode:u8(0full/1slide)；S:u16；scale_bits:u32=0x3e000000 | q tile rows×64，K为S×64；产生rows×S score；mask在同一任务内按b/query/key生成，无独立异步mask流 |
| SoftmaxTask | src,dst:ref；length:u16；mode:u8(0attention/1candidate)；src_region,dst_region:u8 | attention length=S且SCORE→PROB；candidate length=16且HEAD_WORK CAND_MASKED→CAND_PROB分子区；每行完整max/exp/sum/normalize |
| AVTask | prob,kv,partial,dst:ref；head:u8；S:u16 | 消费rows×S概率和S×64 V，写ATT_OUT的d=head*64+lane；key0…S-1升序 |
| FPLinearTask | src,dst:ref；weight:WeightKey；K,N:u16；src_region,dst_region:u8 | scorer family10 F32，K1024/N1，MARKER；act family11 F16转F32，K1028/N256，BATCH；两者逐k非FMA，无activation量化 |
| VectorTask | src0,src1,dst:ref；length:u16；src0_region,src1_region,dst_region:u8；bias_id:u16 | op60读WI U[0:2624]、G[2624:5248]，输出GATE；op61 DEC_FF原地独占；62 TMP+旧H→新H；63 H+对应type→另一H；64/65绑定post bias后GELU；66按BATCH单行将16个raw logits结合marker mask写CAND_MASKED |
| GatherTask | hidden,markers:ref；columns:u8=16 | 每题16列且按输入marker_pos转换，写MARKER；无效列也取CLS，不提前丢弃 |
| StatsTask | probs,stats:ref；valid_options:u8(1…16)；prob_region:u8=6；stats_region:u8=5 | 输入已由SOFTMAX_CAND完成的16概率；k=max(valid_options,2)；输出4项顺序见13 |
| ConcatActTask | hidden,stats,dst:ref；stats_region:u8=5；dst_region:u8=1(ACT_INPUT) | 读取最终Decision本题s0 CLS的1024值，再追加4stats；length=1028，不量化 |
| LoadTask | kind:u8(0W/1KV/2LN/3RoPE)；dst:ref；weight:WeightKey或NONE；head:u8；planes:u8；byte_count:u32 | 目标cache独占FILL；kind对应op80/81/82/83，决定固定源descriptor/shape；不传任意地址。普通tile搬运是所属算子内部MemTransfer，无独立LoadTask/op。W跨所有token tile使用，KV跨head所有query使用；未用head=255、planes=0 |

2026-10-05 P0审核中的接口细化（Astra xhigh）：LN_EMB/FINAL/ATTN/FFN使用TOKEN行空间，LN_MARKER使用MARKER行空间；LN_MARKER归一化结果写入HEAD_WORK的SCORER_ACT供stage5量化，不能将该来源与任意同宽buffer互换。Encoder和Decision的AV均写ATT_OUT，因此stage2及stage4的K1024量化都允许ATT_OUT→A8以供Wo。APPLY_CAND_MASK虽属于stage5，但对象是本题全部16候选组成的一行向量，TaskContext必须为BATCH、row0=0、rows=1，length=16，输出恰16个F32；不能把16个marker各解释成一行16列并计成256输出。上述为既有图和尺寸的任务绑定细化，不改变算术、工作区布局或顶层ABI。

多个物理shard的引用用固定数组`qkv_ref[2]`表达；每项含其合法bank/epoch，**不是把一个BufferRef的bank=0理解为整份QKV**。上表Rope的src/dst和QK的qkv_ref均是此固定二元素数组；KV和score是单ref。rows/token/head等仍从任务上下文获得，逐task必须检查两个shard属于同request/layer/content_kind。

`src_region/dst_region`仅HEAD_WORK使用04枚举；其他buffer固定0。LOAD_W仅用于Q8 WeightKey family1…9或12、head=255、planes=0，byte_count=ceil(N/8)*8*(K/32)*34（含q/scales和N尾物理pad）；LOAD_KV使用WeightKey NONE、head0…15、planes=3（bit0 K、bit1 V），byte_count=2*B*S*64*4。F32/F16 family10/11权重由FPLinearTask内部MemTransfer从aux读取，不能发Q8 LOAD_W。LOAD_LN_PARAMS仅LN_EMB/LN_FINAL前发起，按stage1/3分别绑定gamma及LN_GAMMA bank0/1，WeightKey NONE/head255/planes0，byte_count=4096；不为无gamma LN发此任务。LOAD_ROPE按当前Encoder layer%3选择full/slide的Q/K两表并写ROPE_TABLE对应bank0/1，WeightKey NONE/head255/planes0，byte_count=2*1025*64*4。LN任务gamma枚举和Rope任务table_set隐式索引相应只读cache，接受任务前检查已加载model tag/有效位；同模型同请求可复用，不每tile重装。普通tile搬运只在相应任务内部形成MemTransfer。`bias_id`为只读manifest常量索引u16，NONE=65535；op64必须指scorer独立post bias，op65指act FC1 bias，其他需要bias的模式按图绑定，禁止从Host更改。Linear和FPLinear的bias结合表由导出器从真实图产生：FP scorer FC2包含其bias；FP act FC1不提前合并GELU任务的bias；未知或缺失绑定在构建阶段报错。

F0的外部模块交接优先用READY数组。stream适配器必须在**同一任务**中同时启动生产/消费或先写有限大小中间数组；禁止“生产者把完整矩阵写入小FIFO后返回，消费者等返回才启动”。任务级串行并不允许死等一个永远不会启动的消费者。

### 12.1 加载器与512bit适配器

内部`MemTransfer={task_id:u32, segment:u16, write:1, bo_index:u8, offset:u32, byte_count:u32, cache:BufferRef, cache_offset:u32, last_segment:1}`，bo_index严格用02的0…12顺序；不是Host可提交的动态内存命令。控制器／地址函数从已验证任务生成，`byte_count>0`且源／目标范围均合法；segment从0连续增长，last只在本任务最后一段。输入输出数字内容不变，读写搬移不进行量化。

适配器将其拆成不跨4KiB、且≤4096bytes的AXI burst；512bit是候选物理宽度。34B Q8组跨拍重组；尾部只读写合法bytes，若为宽口补读，只允许已分配并初始化的同一BO padding，不能越BO边界。写byte enable只允许目标bytes，不能破坏相邻tensor。AXI ID、AW/AR/LEN具体宽度由生成接口核查，不硬造信号。

每个master信用分别记录`accepted_reads-returned_reads`和`accepted_writes-responded_writes`；发出前必须为全部返回数据预留cache/FIFO容量。C_RD/C_WR是编译配置，取值和对应RAM/FIFO报告未冻结；05中的8/4是候选评估，不能当已测有效。所有segment以及其burst响应退休后MemTransfer才done。跨master的“读完／写完”由共同任务归并，不能只等最快一路。

## 13. 数据拍的精确逻辑位域

以下位域供HLS显式pack/unpack或RTL适配，只有声明为stream的链路才使用。普通数组仍通过有界索引访问，不把巨大A/W/PS数组强行序列化为每拍宽总线。bit0为最低位；payload中的F32位模式原样传递。

### 13.1 F32Beat：358bit

| 位域 | 字段 | 值与推进规则 |
| --- | --- | --- |
| 255:0 | data[8] | lane i在[32*i+31:32*i]，无效lane置+0但不得读取/累计 |
| 287:256 | task_id:u32 | 当前被接受的任务 |
| 319:288 | epoch:u32 | 当前stream目的BufferRef的预留epoch；源已在任务中锁定 |
| 335:320 | row:u16 | 当前任务row_space内的row0+局部行；batch由任务确定 |
| 351:336 | col:u16 | 当前拍第0lane的逻辑feature/key/输出列 |
| 355:352 | valid_count:u4 | 1…8；有效lane连续从0开始，禁止0 |
| 356 | row_last:1 | 当且仅当col+valid_count=本流row_width |
| 357 | task_last:1 | 当且仅当最后一行的row_last |

下游只有`valid && ready`时才接受并计数；阻塞时全部358bit和valid保持，禁止偷偷前移地址／统计。启动col=0，之后`col+=valid_count`；一拍不跨行，row结束才递增。普通端口每拍`min(8,remaining)`，gate每拍`min(4,remaining)`，其余短拍非法；lane模式为任务参数／绑定端口常量。N=2尾层每行一拍valid_count=2；act输入1028最后一拍col1024、valid_count=4；这4个值为stats，不能当padding。任务中每条stream均独立产生自己的task_last，不能共用另一条stream的last。

对于双输入向量操作，lhs/rhs是两个明确端口，其接受标签必须相同(task_id,epoch,row,col,valid_count,last)，仅当配对暂存有空间时接收；可独立接收后缓冲，但不能把lhs第n拍和rhs第n+1拍配对。两个端口的epoch统一取同一dst预留epoch，源epoch各自在任务引用验证。WiPairBeat使用下文专门类型，避免把U/G混成8个连续feature。

### 13.2 Q8Group、WiPair及阵列窗口

`Q8Group`仅用于导出／加载适配／独立TB串行检查，**A8→Linear实际为cache数组并读**。逻辑宽350bit：data_q[255:0]（32×S8）、scale[271:256]（FP16）、task_id[303:272]、epoch[335:304]、row_local[339:336]（u4）、group[347:340]（u8）、row_last[348]、tile_last[349]。group=0…K/32-1，row_local=0…rows-1；先行后组，scale和32q是不可拆的一个对象。row_last仅最后group，tile_last仅最后行最后group，完整tile发布需要所有对象写入。

`WiPairBeat`逻辑358bit沿用F32Beat元信息：data lane0…3放U，4…7放G，col为0…2623中的U起点；valid_count为**pair_count**，范围1…4，表示有这么多U/G对，永远不解释为总F32个数。另有独立端口类型名字，禁止把此拍接到普通F32Beat而漏算G。task_id/epoch/row/last同上；gate输出F32Beat有效值数=pair_count。该模型2624可整除4，正常每拍4对，row_last在col2620。

整数阵列输入是一次`DotIssue`事件：`task_id:u32, a_epoch/w_epoch/ps_epoch:u32各, group:u8, n0:u16, valid_rows:u5, valid_cols:u4`，附带同一时刻读取的A[16,32]S8/sa[16]F16、W[8,32]S8/sw[8]F16。逻辑lane `(m,n)`固定映射`m*8+n`。PS按rows×N缓存，group每输出升序；同一PS地址的上次FP加法退休前不能再次issue。可交错输出tile隐藏反馈，但不能交换同一输出的group次序。

dot输出是128个I32的寄存器／数组窗口和原DotIssue标签，scales按相同issue保留到恢复完成；不经过8lane输出口。恢复后128路PS更新必须被实际bank/信用接住。无效m/n不访存、不累加、不产生输出；INT32 dot为32个S8乘积之和，FP恢复R0顺序见09。完整Linear输出最终按row升序、col升序F32Beat排出（QKV目的地址scatter在store适配器），不能按阵列退休乱序直接外发。

### 13.3 各链路的拍数与行宽

| 链路 | 逻辑数量／顺序 | 接收断言 |
| --- | --- | --- |
| embedding/LN/hidden | rows×1024 F32；row优先 | 8lane时每行128拍，完整行后发布 |
| quant输入 | rows×K F32 | 普通8lane每行K/8拍；gate4lane每行K/4拍；禁止跨32元素组错误计amax |
| A8串行检查 | rows×(K/32) Q8Group | 每group32q＋1scale，A8多bank读不重复量化 |
| Linear输出 | rows×N F32 | 每行ceil(N/8)拍；N2为1拍/行 |
| Wi配对/gate | rows×2624 pair/F32 | 每行656个WiPairBeat及656个4有效gate拍 |
| QK/softmax | rows×S F32 | score和prob行内key从0…S-1，S/8个8lane拍 |
| AV/head输出 | rows×64 F32 | 每行8拍；store到ATT_OUT head片段，整层完成后才Wo |
| scorer FC2 | rows×1 F32 | 一行一拍valid_count=1；写CAND_RAW[b,c] |
| act1028／act hidden | 1028／256 F32 per b | 分别129拍（最后4）／32拍；act输出2值1拍 |

## 14. task/done握手、错误排空与复位

对可握手实现，任务端为`task_valid/task_ready`（各1bit）加对应类型参数；done端为`done_valid/done_ready`（各1bit）加下表。HLS普通阻塞函数可用调用／返回表达同样的接受／退休事件，**不要求额外导出所有这些RTL端口**。任务一旦接受且未退休，task_ready保持0（F0全局互斥）；done遇停顿保持valid和所有字段稳定。不能用task_valid脉冲假定对方一定接收。

`TaskDone={task_id:u32,status:u16,error_detail:u32,bad_element:u64,output_elements:u32,output_beats:u32,output_unit:u8,drained:1}`。output_unit：0=无数据、1=F32标量、2=Q8Group、3=bytes；每种任务的单位固定，接收方不得猜测。成功status=0，bad_element=UINT64_MAX，output_elements等于该任务逻辑输出：普通计算unit1，数量为rows×行宽（ROPE为rows×2×64、Stats为4、Concat为1028、Gather为16×1024）；QUANT unit2且数量rows×K/32；LOAD unit3且数量byte_count。output_beats仅计其实际主输出stream被接收拍数（数组直接写时为0）；drained必须1。失败status沿14§9，输出数量仅作诊断、不发布目标有效数据；drained=1后才允许控制器接收失败done并进入结果错误提交。不存在`drained=0`而“先done后后台继续写”的许可。

完成必须同时满足：输入数量正确、所有发射运算退休、每条输出流全部被接收、数组写可见、AXI读返回／写响应排空、无该任务持有的临时引用。`last`只是元素边界，不是完成确认。任务完成后reader可能继续拥有W/A8等可复用只读缓存，其寿命由controller矩阵屏障单独管理；这里“无临时引用”不等于强制释放所有输入cache。

F32、Q8、WiPair的流种类编号分别1、2、3（error_detail domain6的object）。首个协议错误锁存task_id及原因，停止发新工作，但不可撤回流水的结果必须有丢弃sink；已接受HBM事务等待正常返回后才能结束。少拍／永不响应无法凭内部错误凭空排空，触发Host超时恢复；TB必须设观察上限报告挂起，不能伪造剩余拍让错误PASS。

在途FP信用按`free_slots >= newly_issued_results + 已承诺未返回结果所需空间`核算，只有真实pipeline支持时才允许用ready停止流水。若流水不能停，结果FIFO深度至少覆盖最大在途结果数和反压传播，数值须由实际IP latency／II／握手测得；未冻结这一点前不能声称无死锁或满速。HLS C的无界stream不作有限FIFO证明。

复位的电气极性、同步释放及CDC由02§8的实际平台决定。逻辑恢复原子地作废任务、FIFO有效位、buffer epoch/coverage与发布状态；不依赖清零全部HBM。运行中复位前后必须通过平台确认旧总线事务不会再写入新session，Host才可换generation重新用BO。恢复后首请求重新校验模型/构建身份，并从embedding开始；是否重装权重取决于真实平台是否保留HBM/xclbin。

## 15. 控制器的完整F0屏障与联合测试

| 屏障／任务链 | 保持有效的输入 | 满足后才可继续 | 指定故障／背压用例 |
| --- | --- | --- | --- |
| IO_VALIDATE→embedding→LN_EMB | 五输入及模型身份 | 每题S个token都反量化，LN全矩阵完成 | 非法最后ID不得发HBM；真实PAD行不能被省略 |
| LN（首层跳过）→LOAD_W→逐tile QUANT→Linear QKV | 旧H或NORM、当前W | 全B/S/Q/K/V raw覆盖＋最后响应；再做所有ROPE | 最后raw写响应延迟；半层不能启动RoPE/attention |
| ROPE→每head LOAD_KV→每tile QK→softmax→AV | QKV_FINAL、mask、当前head KV | 所有head/B/S写ATT_OUT完成 | 延迟最后RoPE响应、score最后拍、AV反馈；检查head不串 |
| ATT_OUT→quant/Linear Wo→ADD_RESIDUAL | 旧H、投影TMP | 新H整矩阵可见后交换角色 | 旧H最后行未读不得覆盖；NORM与TMP地址不同 |
| LN_FFN→Wi→GEGLU→quant/down→ADD_RESIDUAL | 旧H、W按矩阵驻留、WI/GATE | 每阶段整矩阵完成，最终H交换 | U/G同位置、4/8lane、Wi/down引擎互斥；WI可释放后才Decision复用 |
| Encoder28→LN_FINAL→EMB_TYPE/ADD_TYPE→Decision2 | 全hidden与qtype | type对应题；两Decision层均全S且无RoPE | 混合qtype、B2、S64/1024；禁止marker-only Decision |
| GATHER→LN_MARKER→scorer FC1→post bias/GELU→FP FC2→mask | 最终H与16marker | CAND_MASKED共16*B项 | N1每行1lane、scorer两次bias、无效CLS列仍执行 |
| CAND softmax→STATS→CONCAT_ACT→FP FC1→bias/GELU→quant/act FC2 | 最终CLS、16概率及4stats | ACT_INPUT1028齐全、act2*B齐全 | 最后4stats尾拍暂停；N2无效6lane不能写出 |
| 全部done→RESULT_COMMIT→XRT wait/sync | 请求身份与最终logits | 全部写响应及结果头排空 | status写响应延迟、旧generation、运行中/排空中复位 |

每条链用14§10的真实Typed capture作为数值输入。协议补充覆盖每个尾拍停顿1拍/多拍、长时间ready=0、随机有限返回延迟、相邻任务换bank/epoch、相同shape连续两请求、B2接B1、最大K/N/S和失败后恢复。计数守恒必须精确，浮点容差按native／candidate分开；未做仿真时只列为待执行。

## 16. 尚未冻结的实现条件

本次已经给出请求/结果字节、任务字段、op枚举、buffer身份与地址、stream逻辑位域、尾部/完成/错误和联合用例；这解决的是G2的文档合同部分。待实际实现／证据冻结的仍包括：同源C++头与静态断言、真实模型导出base/hash、native/candidate数值差异与函数版本、生成的HLS端口和控制寄存器、物理RAM bank/端口、FP IP latency/II/FIFO信用、AXI outstanding/ID/时钟域、器件/平台/恢复API和正式误差门槛。F1所有融合和重叠是后续优化，必须修改同一合同并对真实capture重验，不能把F1时延计入本版F0结果。

