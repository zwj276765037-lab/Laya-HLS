# M004：固定完整图与最简共享算术架构核查

2026-10-14；A003；M004/SM004/E004/R001。依据 Goal v4、M004 修订3及 `m004-simplified-start-research-20261014`。本报告是接口选择与吞吐假设分析；未修改实现、运行前向或启动 EDA。旧 M005 v4 保持冻结。

**建议首版采用方案 A：固定顺序控制器连接六类共享算术服务，各类跨层复用；保留算术核内部的流水，不保留逐元素等待的旧残差封装。** 方案 B 把非矩阵 FP 运算进一步合入一套资源池，只有资源证据支持这一取舍时才值得优先采用。这里的“六类”是命令/实现边界，不是六个算术叶子，也不是已证明的最小资源数。新方案的完整延迟、完成间隔、资源和频率均为 UNKNOWN。

主控选择更新：A001 已通过 `m004-fixed-graph-architecture-controller-choice-20261014` 采纳方案 A 和下述外部 scratch 生命周期，并在 [SM004修订3](../project/missions/SM004.md) 登记；真实叶子 II、单lane有限credit残差及必要局部 OOC 由 A002 按合同执行，尚未预认 II=1 或端到端收益。本次独立架构分析已完成，后续依据工程实测更新。

## 1. 完整图及必须保留的顺序

复用[冻结工作量](feasibility_20261014/v4/budget.json)，不重建全图审计：B1/S128、28 Encoder、2 Decision、16 scorer 槽、2 个有效候选、每请求1行 ACT；72 个有效 token 不自动缩成72行计算。请求帧 SHA256 为 `87fc82b1d455ed27ad6bfced11322ed6ef2a6a6a5c61bc80946f7cbe6ff07cbe`。下表由[独立参考 full_reference.py][reference] 的完整调用图核对；Q 表示 group32 激活量化，所有 Q8 线性前均需要 Q。

| 区段 | 固定依赖与形状（矩阵记 M/K/N） |
| --- | --- |
| 输入 | CPU token embedding → FPGA embedding LN（含 gamma）。输入打包不代算后续网络。 |
| Encoder ×28 | 第0层直接取 hidden，其余先 LN → QKV `128/1024/3072` → Q/K RoPE（每3层 full，其余 slide）→ QK/softmax/AV → WO `128/1024/1024` → 与原 hidden 残差；再 LN → Wi `128/1024/5248` → GELU(前2624列)×后2624列 → Down `128/2624/1024` → 与本层 attention 残差结果相加。 |
| 中间连接 | final LN（gamma）→ type embedding 解码/加法。 |
| Decision ×2 | LN → 有 bias QKV → 无 RoPE、非 sliding Attention → 有 bias WO → 残差；LN → 有 bias FC1 `128/1024/4096` → ReLU → 有 bias FC2 `128/4096/1024` → 残差。 |
| Scorer | gather 全16槽 → marker LN → scorer_fc1 `16/1024/1024`（baked bias）→ **另一次** scorer bias 加法 → GELU → F32 scorer_fc2 → candidate mask → softmax → 四个统计量。两个有效候选不意味着只执行两行 scorer。 |
| ACT/输出 | 当前 Decision hidden[0] 拼四个统计量成1028 → F16 权重 FC1 `1/1028/256`（F32 运算）→ bias/GELU → Q8 FC2 `1/256/2`。最终18项是16个 **masked logits** 加2个 ACT logits，前16项不是概率。 |

沿用计数：122次 Q8、47,160,754,688 INT8 MAC、1,473,773,584 次 group32 FP 恢复；Q 为22,266,112元素。Attention QK/AV 各503,316,480 FP MAC，softmax 有61,440行/7,864,320个分数；LN 为7824×1024元素，GEGLU 为9,404,416输出，残差7,864,320加法。另有 RoPE 7,340,032旋转值、Decision ReLU 1,048,576元素、F32 scorer 16,384 MAC、F16 ACT 263,168 MAC，以及 type add、候选 mask/softmax/log/统计与两处尾部 GELU；这些不能省略。

| 数值约束 | 可以并行的范围与不可合并的步骤 |
| --- | --- |
| LN | 1024值相邻二叉加法树求均值；先减均值再平方，第二棵相同树求方差；加 eps `0x3727c5ac`、sqrt、倒数、归一化、可选 gamma。树的同层独立节点/不同 row 可流水；不能换成 `E[x²]-mean²`、RMSNorm 或任意重排归约。 |
| Q/Q8 | group32 amax/127 得 FP32 scale，量化逆数使用该 FP32 值，存储 scale 才转 FP16 RNE；q 保留 ties-away-from-zero 和零/微小值规则。每组精确 I32 dot 后，分别舍入 `sa*sw`、乘 dot，再按组顺序 F32 累加，最后 bias；不融合 FMA 或改组间树归约。 |
| Attention | QK 每个 score 的64项相邻树，再缩放/加原有限 mask；softmax max→原 expf→相邻 sum 树→逐项除法。AV 每个输出按 key 顺序累加，可交错不同输出/head/row。不能用 online softmax、换 exp 近似或直接跳过 masked key。 |
| G/尾部 | 保留 GELU/tanh 的原运算树及每步舍入；scorer 两次 bias 不能折叠。F32 scorer/F16 ACT 保留每输出 k 顺序；统计量保留 log、归约与 top1/top2 顺序。并行执行时还须维持原有限值检查及首错优先级，失败不得发布成功结果。 |

LN/Q8 的纯算术边界见 [layernorm_compute.cpp][ln] 的 `layernorm_row_arithmetic`（第60行）和 [q8_linear_compute.cpp][q8] 的 `q8_linear_window_arithmetic`（第101行）。其余规则见 [attention_full_compute.cpp][att_cpp]、[vector_full_compute.cpp][vec_cpp]、[decision_full_compute.cpp][dec_cpp] 与独立参考；这些 C++ 入口不等于已有可直接接入的流水 RTL。A002 的[接点答复][contacts]补充：已有 `laya_front16_wide`（512bit STATE0/AUX→STATE1、16×1024 LN）和 `laya_layernorm_quant_source_shell_v1` 可供提取；旧 LQ1 局部循环 II2、528307cycle 相对旧659334cycle，但估计 slack −48.76ns，不能沿用为可达时钟或全部 LN producer。

## 2. 两种共享服务组合与具体接点

| 选择 | 共享资源与顺序控制 | 必须补的工作/取舍 |
| --- | --- | --- |
| **A：优先，保留算术模块边界** | 一套 Q8 matrix（含 FP restore）、一套 Q、一个 LN 服务、一个 QK/SM/AV 服务、一个 canonical G 服务、一个简单 vector/tail 服务。最后一项覆盖 RoPE、残差、type add、ReLU、独立 GELU、F32/F16 尾部线性及候选统计；按子操作选择叶子，不能漏掉 sqrt/log/half 解码。固定 FSM 每次只发一个阶段命令，允许该阶段内部多项在途。 | 为 LN/尾部建立有明确吞吐的行缓冲/树调度和适配器，覆盖所有矩阵形状与 bias。复用已有算术优先，避免先重造统一 FP 调度。不同服务仍可能复制 FP 叶子，资源未知，需随集成取得真实资源证据。 |
| **B：合并非矩阵 FP 资源** | 保留 matrix 与 Q；LN、QK/SM/AV、RoPE、残差、尾部线性/统计共用一个带银行和 tag 的 FP 池。可从已有 M16/A16/D4 接点出发，sqrt 与精确 exp/tanh/log 作为显式辅助核；G 的外层 mul/add 也进入池，而非同时暗中保留独立 G 吞吐。 | 新增统一操作调度、银行映射、返回 tag/credit、归约树屏障与逐地址反馈。共享池中的 LN/Attention/G 不能并行占用同一单元。减少重复叶子的潜力是设计判断；面积和速度改善未实测，控制改动与回归范围明显大于 A。 |

两种选择都只需固定层/row/head/group 计数和地址表，不需要通用 portal/lease/owner 系统。每个服务的简单命令需明确 op、尺寸/偏移、bias/gamma 模式；有 start/ready、done/status，数据侧使用 valid/ready 或“发射前预留完整返回容量”。保留 outstanding 读写/算术计数、AXI 反压、写响应排空、在途复位和首错记录；阶段完成依据真实退休，不能用常数延迟假完成。单请求外层顺序不妨碍内层流水。

| 可复用接点 | 接口事实及需要替换的控制 |
| --- | --- |
| [tm4tn8_row_pipeline_v1.sv][matrix] | issue valid/ready → commit valid/ready；A 为256bit、W 为2048bit（8×32个 int8）、旧 PS 为256bit、A/W scale 为32/256bit，带 row/group/tile 标签。复用整数树和 FP restore，以及同目录同步 PS front/bank。上层 `tm4tn8_matrix_resident_v2` 耦合 owner/admission/A-W引用，不能直接把许可线拉高；需用固定银行调度及真实 commit/drain 替换。Wi/Down 共用此矩阵，不能并行计算。 |
| [quant16_stream_row.sv][quant] | 行命令与512bit输入（16 F32，两拍成 group32）；输出128bit Q half、16bit scale 及 group/half 标记。保留内部 slot/返回债务和行结束握手，可用固定计数替代任务元数据桥；复用 dual-A 行银行。 |
| [attention_tile_service_prefetch_v1.sv][att_rtl] | 实际 module 名为 `attention_tile_service_v1`；ap_start/done/continue 与32bit命令/索引/数据口；内部 M16/A16/D4、EXP4、同步银行和延迟 tag。可剥离55-word命令绑定/标量装载，保留精确归约和反馈。与非 prefetch 文件不能同时编译同名 module。旧 `attention_service.cpp` 的1M/1A/1D版本不是此实测实例。长度16的候选 softmax 和尾部命令需补支持或由尾部服务执行。 |
| [geglu_canonical_core.sv][g] | `in_valid,in_x,in_g` → `commit_valid,data,status,failed`；无 ready，valid 管线506级。发射前必须预留返回空间。Wi 两半分离存储，需按同 row/列对齐后送入，不能相邻列直接配对。单独 GELU 不默认等价于给此核 g=1，需核数值/错误语义。 |
| [laya_ffn_fadd_slot_v1.sv][add] 与 [残差 FSM][residual] | 当前 `in_ready=!leaf_busy&&!out_valid` 强制单项在途；FSM 按 SKIP读→DOWN读→逐标量 launch/collect→单 beat 写/B 排队。可复用已核数值叶子，需替换标量等待封装。Attention 的 CE streaming ADD 接点可供比选，但其数值身份、CE和实际 II 要先核，不能只按名称互换。 |

**存储采用明确生命周期，而非隐含无限复用。** 一个容易检查的 B1/S128 外部 scratch 方案是 H0/H1/N 各524,288B，S0=2,686,976B，S1=2,097,152B，合6,356,992B（6.0625MiB）；另计 mask、尾部、对齐及只读权重/辅助数据。它是工作区设计预算，既不是片上存储声明，也不是最小容量证明。

可按 `Hcur→LN N→Q→QKV S0→Attention S1→Q→WO N→residual Hnext`，再 `Hnext→LN N→Q→Wi S0→G S1→Q→Down N→residual Hcur` 调度。Decision 的 FC1/FC2 复用 S0/S1/N；尾部复用已释放 scratch，保留 hidden[0] 到 ACT 拼接结束。N 的上个消费者真正排空后才能重写；目标写响应全部返回后才能发布阶段完成。外部 ABI 映射由 A001/A002确定。

片上 A/PS/W 先复用已核容量接口：A 139,264B，PS 83,968B及5,248B metadata，dual-W 共11,461,632B（含 bias）；这些仍非实际资源。一次驻留矩阵跨32个四行窗口使用，能减少 W 重装，但须补固定调度下的驻留证明。完整模型392,448,128B一次 LOAD_W 声明不等于全部片上驻留；四行交替 Wi/Down 与全S128先Wi后Down会产生不同流量。LN→Q、G→Q可考虑按完整group32转发，保留原 F32 舍入和有限 FIFO；不能把原外存字节直接全删或默认无争用。W/A/PS/KV/score-prob 每个银行端口及外部仲裁必须在设计中列明。

## 3. 旧慢点中哪些可以改变

| 旧局部证据（不迁移为新设计速度） | 数学依赖 | 可证伪的实现改进 |
| --- | --- | --- |
| LN 边际行约40,535cycle，四行相位168,692cycle | 两次指定树、均值后才能构造方差、方差后才可归一化 | 同层独立树节点流水，行间交错；delta/square/normalize 多项在途。保持树边/舍入逐项一致，同时测 accept/return/bank stall，不能只减FSM拍数。 |
| 残差4096加法耗103,289个含端点采样周期；旧叶子延迟22cycle | 每个输出依赖两个输入；不同元素没有反馈依赖 | 去除逐元素等待，有限 credit 的连续发射/有序打包，读写突发与计算重叠；实测叶子 II 和实际端口供数能力决定收益。 |
| [ATN1][atn] 一 head QK/SM/AV consume 为250,912/265,108/66,280cycle；SM 的 EXP 相位248,436cycle | QK/softmax 的树及 AV 每输出按 key 累加；expf 本身也有真实服务成本 | 可改善银行预取、独立 score/输出交错；旧 ASUB 预取已省22,089cycle，但 EXP4 busy 共898,680 worker-slot 边沿，对该样本理想平衡下限仍224,670cycle。去壳不足以消除 EXP 成本，不能许诺全吞吐跃迁。 |
| G cfg→last B 为57,993cycle，含 Wi 读/G/写；103,979cycle还含后续Q/Down | GELU内部依赖及同位置gate乘法；元素之间独立 | 测成对操作数供给、算术在途与输出 credit；已有流式核不代表完整G服务已达到每拍一值。 |

另有 [AV反馈旧局部实验][att_results]（第241行）在16地址交错时连续256次接受 II=1、单地址反馈13cycle；真实4096项总5089cycle。它支持“交错独立输出”的机制，但不是任意 shape、当前完整 Attention 或残差叶子 II 的证明。旧 v4 的未知算子8cycle是假设，不是新方案必须承受的服务率；旧6.919–8.133s也不作为新架构预测。

**首版提出的首个问题：一条保持原数值的 F32 残差通路，能否在有限在途容量和合法输出反压下，按叶子的真实接收 II 连续接收独立加法，而不等待每项返回？** 先确认候选叶子的精确数值/accept/return 身份；若旧22cycle叶子本身非流水，仅改封装不能得到 II=1。该问题现获下述 AT093 样本的局部支持。

可在原4096值输入/独立 gold 上比较旧标量封装与候选信用计数封装：看逐位结果、接受间隔、银行/输出停顿、在途峰值、发射/返回守恒、错误优先级和最终写 B 排空；合法反压/在途复位仍须正确。若只增加缓存而接受间隔仍由 leaf_busy 固定，或实测被供数/端口堵住，则“封装串行是主要损失”假设被反驳或受限。此处是给 A001/A002 的实验选择建议，本研究任务没有启动该实验。

条件预算仅用于定量约束这个问题：p条 lane、每条接收 II=i 时，纯算术约 `ceil(4096/p)×i + drain`；两读一写至少49,152B。若只有一个共享512bit数据口、合计每拍最多一个 beat，至少768个数据拍，带宽上限约5.33值/拍，不能凭16条 add lane声称16值/拍。单lane II=1、**假定**150MHz需1.8GB/s有效聚合流量；地址/B/争用/反压会另降速。这不是板上带宽、物理频率或整模加速比。该小问题即使成功，也尚未解决 LN 和 EXP 主导成本。

## 下一段建议：单行1024维精确LN（2026-10-14）

交付状态：A001 已通过 `m004-ln-row-design-controller-accepted-20261014` 采纳下述方案，并在 [SM004修订5](../project/missions/SM004.md) 集中确定工程接口、首错、reset、夹具、成本与完整行出口，交A002实施。下述接点缺口与周期公式保留为2026-10-14的初始设计记录；2026-10-15取得的限定实测见本节末尾更新，不把初始公式改写成实测分段计量。后续研究仅按具体来源问题或新证据更新，旧v4保持冻结。

承接 `m004-ln-single-row-next-design-question-20261014`。**推荐一套共享ADD/SUB、一套MUL、一个标量DIV和一个SQRT，以单行固定FSM完成完整LN。** 顺序为装载→均值树→除1024→delta/square→方差树→除1024→加eps→sqrt→倒数→重新delta/normalize→可选gamma→整行发布。ADD通过对有限mean翻转符号做减法；两个delta都重算，保留[原算术][ln]逐步F32舍入和检查。mean/variance都用DIV的`a=sum,b=0x44800000`，倒数用`a=0x3f800000,b=root`；不直接减指数、不换乘常数/近似rsqrt，不合并乘加。gamma0不读gamma，gamma1/2各另乘一次。

| 最小存储/端口安排（payload共14KiB，未计短FIFO/标签） | 每拍实际访问和依赖 |
| --- | --- |
| X：1024×32bit（4KiB）；G：1024×32bit（4KiB） | 各一套同步1R1W。首版32bit流装载X并同时复制进T0；有gamma时再装载G。不是512bit输入每拍任意写16个标量bank。X保留至归一化结束，G保持整行。 |
| T0：偶/奇各512×32bit（4KiB）；T1：偶/奇各256×32bit（2KiB） | 每bank同步1R1W。width为1024时从T0偶[j]/奇[j]各读一次，发节点j；结果写T1的bank=`j&1`、地址=`j>>1`。下层交换T0/T1，width依次512…2；最大512个目标值使T1足够。不同组物理bank避免假设单BRAM两读一写。 |
| 复用与发布 | 每层最后节点真实写回且读响应/ADD标签归零后才交换bank。均值存寄存器后，square重填T0；方差存寄存器后，normalize结果复用T0，gamma再顺序读T0/G并用同一MUL原位写T0（每地址先读后写，1R1W）。所有检查成功才从T0输出整行；新行不可覆盖未消费结果。 |

实际接点：ADD沿AT093的CE ADD/32credit机制；MUL和DIV优先取AT021冻结的 [`attention_tile_ce_…stream_mul_node_14_s`][ln_mul] / [`…stream_div_node_0_s`][ln_div]，真实口为`ap_clk/ap_rst/ap_ce/laya_global_ce,a[31:0],b[31:0]→ap_return[31:0]`，无独立valid/ready。旧Attention使用14/12级标签只是该集成的配对依据，不是LN短测结论。SQRT可取已有front16的 [`laya_front16_wide_fsqrt_…_1`][ln_sqrt]：输入在`ce`采样到 **din1**（din0不用），`dout`返回；其[IP Tcl][ln_sqrt_ip]为FP7.1 Square_Root，c_latency=5/c_rate=1是配置，外壳另有输入寄存/延迟CE，不能将文件名“7”或配置“5”当已测接口延迟。该IP未接reset、无结果ready；需要外部valid/标签屏蔽旧返回，不能假定复位清了算术流水。

**数值/速率边界：** ADD已有52定向及4096残差样本支持，完整LN范围仍要复核；MUL/DIV有旧Attention整head逐位证据，SQRT有旧front16整行证据，但其独立LN域RNE/次正规、真实accept→return、CE暂停/复位与持续II尚未在本方案核定。先做三个叶子的有限短探针：实际采样/返回配对、暂停/恢复与旧数值边界；尤其MUL不能FTZ，DIV须覆盖除1024的下溢舍入。SQRT只在检查后的`variance+eps>0`上发射，保留原sqrtf数值，不能用旧HLS负slack预认时钟。A002已回复 `m004-ln-leaf-fixture-contacts-answer-20261014`，确认生成wrapper接口及这些独立叶子证据缺口；final gamma单行夹具亦未确认，维持UNKNOWN。

最少控制是row_busy、gamma_kind、phase/level/有效width、issue/commit计数、有限返回credit，以及随有效接受传递的目标index/子操作标签；不需要通用owner/lease。发射前预约返回容量，目标RAM提交才归还；只有当前width内元素可读，每次返回唯一写入。首版可让算术CE持续有效、由标签区分真实工作，外部背压通过credit吸收；变阶段前等存储读、算术和写回全部排空，reset清valid/credit并屏蔽旧返回。数值首错按原逻辑`阶段→元素→子步骤`取最早，失败行不发布；**gamma另扫仍与normalize共用原逻辑阶段，不能让后列norm错误抢在前列gamma错误前面**，预装gamma时也不提前报数值错。正常行完整输出握手结束后done/status保持到消费。

条件预算定义 `F(n,I,L)=1+(n−1)I+L+2`：同步读1拍、n次发射间隔、真实发射到结果延迟L、写回与层屏障各1拍。`L_AM/I_AM`包含ADD→检查/有限FIFO→MUL的整个链，`I_AM≥max(I_A,I_M)`；以下是无额外停顿的设计账本，实际供数、credit或输出阻塞另计，不填未知叶子II=1。

| 阶段 | 条件周期 |
| --- | --- |
| 每棵相邻树 | `Σ F(n,I_A,L_A)`，n=512,256,…,1，即`1013 I_A + 10(L_A+3)`；共两棵，2046次ADD。 |
| delta/square；delta/normalize | 各`F(1024,I_AM,L_AM)`；保持原元素索引与依赖，两个阶段分开。 |
| 三次DIV、eps ADD、SQRT | `3L_D + L_A + L_S + 10`，五个标量操作逐个结果确认。 |
| 可选gamma；装载/输出 | gamma为`g F(1024,I_M,L_M)`；32bit无阻塞输入/输出预算分别`1024(1+g)I_in+2`及`1024I_out+1`，g=0/1表示无/有gamma。全行周期为以上各项之和再加实际停顿。 |

工作项总数为4095 ADD/SUB、2048（有gamma为3072）MUL、3 DIV、1 SQRT；没有可签的MHz/整行实测cycle。两个树bank组共6KiB，X/G各4KiB，总14,336B；无gamma可少装4KiB但不等于物理省掉G RAM。层内连续发射必须由银行、叶子、credit三者共同支持，ADD局部II=1不自动赋给LN。

**首个整行区分检查：** 同层独立节点能否连续接受、最后写回后才切层，并让mean/variance/inverse和全部1024个y逐位匹配既有夹具。先用[历史P1夹具][ln_fixtures]的`cases/wi_ln_rows1`（gamma0）与`cases/qkv_ln_rows1`（真实embedding gamma）；两者保存input、`dut.ln_stats.bin`和`dut.ln.bin`，后者另有gamma。文件名如实保留：它们是历史DUT输出，经同目录`numeric_fixture_report.json`记录与独立oracle逐字节相等，并非新生成的独立gold文件。已核7个文件SHA，见[身份记录](fixed_graph_support_20261014/ln_fixture_identity.json)。再复用 [numeric_tb.cpp][ln_numeric_tb] 已固化的近常数/次正规oracle位模式；gamma2真实final的统计量gold未在这两个夹具中覆盖，保持UNKNOWN，不能以gamma1代签。不得用native ir_268替换相邻树gold，也不在本研究轮生成新gold。

本段仅静态读和小文件身份核查，未运行算术/模型/EDA；[核查脚本](fixed_graph_support_20261014/check_ln_fixture_identity.py)进程墙钟0.05s、峰RSS16,468KiB，CPU0–3/nice19/idle、MemAvailable447,864,992KiB，沿用原研究预算而非重置。交互浏览累计精确耗时/RSS仍UNKNOWN。

### LN单行实测校准（2026-10-15）

依据工程通信 `m004-sm004-ln-row-research-update-20261015`，已读取[完整限定报告][ln_row_stage]、[证据记录][ln_row_evidence]及AT104/107原日志、AT108资源/时序报告的对应条目。AT107与AT108使用相同 `laya_ln_row_v1.sv`，SHA256 `da8adccc54275c7232bf43d646cd49e5b9d9c8d7204a2b20e3031f0ddd01bb40`。

| 新证据 | 可用于当前局部预算的参数 | 适用范围 |
| --- | --- | --- |
| AT104叶子短探针 | MUL/DIV/SQRT各16组精确位模式通过，观测lag分别14/12/6，所测连续输入II=1。 | CE固定1；不覆盖任意数值域或CE暂停。lag是该探针接口的观察值，不能直接代替设计公式中的整个ADD→MUL链延迟、RAM提交或握手开销。 |
| AT107 gamma0正常行 | 命令接受至done消费8482cycle；1024输入、1024输出，无输出阻塞。 | mean/variance/inverse与全部y匹配历史P1独立核验夹具；两树各10层，ADD占用峰7、MUL发射未提交峰15。 |
| AT107真实embedding gamma1 | 同一周期口径11792cycle，含输入空拍及820cycle输出阻塞；统计量与1024个y逐位通过。 | 不以减去820后的值代称无阻塞gamma1，也不把相对gamma0的差值全归给gamma乘法。gamma2的10546cycle仅使用gamma1数据模拟模式，真实final gamma仍UNKNOWN。 |
| AT108完整行OOC | U55C、6.667ns约束：14279 LUT（8510 logic、5460 distributed RAM、309 SRL）、3375 FF、2 DSP、0 BRAM/URAM；内部WNS +1.967ns。 | 未P&R且缺外部I/O delay，不签物理Fmax。14,336B逻辑payload此次使用LUT memory；5460项是全模块distributed RAM LUT统计，不能全归给某一个buffer。完整图共享/fit仍UNKNOWN。 |

原先最有区分力的整行检查已得到上述真实夹具范围的支持：两棵树保持层屏障，同行独立工作可多项在途，完整统计量和输出一致。AT107日志中两棵树后九层完成间隔均为该层节点数加9cycle，与层内连续发射相符；未凭首层结束绝对时刻补造完整分段耗时。可将8482cycle作为当前gamma0本地流服务样本，将11792cycle作为指定压力下的embedding gamma1样本；这些替代相应局部UNKNOWN，不将初始分段公式宣称已逐段验证。

限定回归还覆盖所测首错、失败不输出、完成保持和MUL在途复位后新行；跨normalize/gamma首错优先级的后列异常由TB强制注入，只证明控制优先级，不能算自然算术溢出样本。AT106原语义FAIL保留，AT107修正的是reset用例gold映射。当前首版持续CE与有效标签的使用方式不要求据此声称通用CE暂停已证。

主控发现的[DELTA1/square首错反例][ln_first_error_review]已于2026-10-15限定关闭：依据[主控核查记录的at110_closeout][ln_first_error_closeout]及通信 `m004-ln-first-error-controller-research-update-20261015`，AT109动态报告E_NUMERICAL/bad1023，而独立原行参考为bad0，原语义FAIL保留；AT110取消DELTA1末提前DONE，保留delta候选到SQUARE排空后归并，正确报告bad0且零输出。A001接纳 `PASS_SCOPED_LN_FIRST_ERROR_FIX`，修复RTL SHA为 `a46d468e3e03e0feef55f36f4be8425d7a3468a13e7c68f16624b213b9ce5f72`；六条边界及原九例通过，gamma0/gamma1仍为8482/11792cycle。AT108资源/时序只属旧SHA，修复版独立OOC未运行，不迁移旧资源结论。真实final gamma、任意故障及完整硬件图仍未验证，gamma竞争force仍只签受控首错检查。本次仅依据主控已核证据更新，未重复工程仿真或215项身份审核。

本次只把既有实测纳入研究记录，没有新增运行或整模外推。AXI/HBM搬运、跨层调度、全模式正常行周期、完整图资源/频率均未由本样本给出；不与旧front16或M005 v4拼接为整请求实测。实现下一步及验收由A001/A002按现有合同负责，本更新不派生新实验。

### 下一连接：真实LN→16元素打包→Q（2026-10-15，定向静态依据）

回复 `m004-lnq-thin-connection-research-question-20261015`。**推荐一个512bit打包寄存器加1088B量化行暂存，Q整行成功且全部物理债务排空后发布。** 一次只处理一行，沿用真实LN输出与现有Q算术；不引入portal/lease/hub。以下保留最初定向静态依据；后续连接实测与同版联合OOC见本节后的AT121/AT116更新。

采纳状态：A001通过 `m004-lnq-row-connection-research-decision-20261015` 采纳本方案，接口、验证与连接预算已集中在[SM004修订6](../project/missions/SM004.md)“当前连接段：真实LN→Q→可复读量化行”，由A002实施。AT110限定修复回归已满足原“先修复并回归LN”的依赖，A002按现有合同连续推进连接验证及有限联合OOC，不等额外放行；新连接运行状态仍以真实回执为准。本次定向研究交付完成，方案采纳不代表局部RTL或完整硬件验收，后续仅按新连接实测边界更新。

**同输入的独立参考。** P1报告是历史 `abi_replay S128 B2`，本次选其中batch0/row0/rows1，不能称为新production-v2完整请求。`wi_ln_rows1`来源为`enc0_attention_residual`，gamma0；`qkv_ln_rows1`来源为`embedding_raw`，使用`emb_norm_w`。已核两个case共9个input/gamma/LN/stats/Q文件与原报告SHA一致，见[身份与布局记录][lnq_identity]；原输入与LN SHA亦见[前次记录](fixed_graph_support_20261014/ln_fixture_identity.json)。两份1088B `dut.q8.bin` 的SHA256：

| case | SHA256 |
| --- | --- |
| wi_ln_rows1 | `ee1f353cac94beaa91f8854593813c49d937a87008207a8c7937f6b142a9d5f6` |
| qkv_ln_rows1 | `8d0f44a4d19b9260a99fc8ba8aeee7f99a77c8610e82328e1de0c9321c5605f7` |

文件连续32组，每组34B：偏移`34*g`起2B是little-endian FP16 scale位型，随后32B是该组按列递增的signed int8；合1024B q与64B scale，**文件内不是先1024B q再64B scale**。最小解码为`scale_bits,*q = struct.unpack_from('<H32b', raw, 34*g)`，g=0..31；半组h的q来自`raw[34*g+2+16*h : 34*g+18+16*h]`。无需浮点重算来核这些参考字节。

来源闭环：[numeric_cli.cpp][lnq_cli]第202–248行把`lnoutput`同时保存为`dut.ln.bin`并送入`qinput`，之后输出scale低字节、高字节、32个q；[numeric_fixture_test.py][lnq_fixture_test]第338–358行独立执行`oracle.layernorm(source,gamma)`并逐字节核LN/stats，再以**oracle LN输出**调用`oracle.quantize`核整个1088B；[numeric_reference.py][lnq_reference]第68–102行规定FP32 amax/127、FP32倒数与乘积、ties-away取整、FP16存储scale，独立于DUT。三个来源文件当前SHA均与原P1 `source_hashes`完全一致。本轮只解码/核身份，未调用oracle、生成gold或运行前向；`dut.*`是已被历史独立参考核验的DUT保存输出，不改其来源名称。

**Q的真实接口与完成条件。** 以下静态结论对应[quant16_stream_row.sv][quant] SHA `23c18d6aca1bd61da1786d4b54cbbb80817c31c1bd0be13bcad6d19471502981`；不得用旧adapter01的141cycle直接预测新连接，该旧冻结Q SHA为`42021e9b9897448e9f1c566437ceac50cfc0942288a039ca543bab7ca7a7fab9`，与当前不同。

| 边界 | 当前RTL行为与薄连接职责 |
| --- | --- |
| start | `start_valid&&start_ready`采样；要求非零task_id/source_epoch，`cfg_groups=32`，固定row。Q只在非active、无未消费done且内部task_epoch未到`ffffffff`时ready。沿用其字段即可，薄连接将非零本地常量/当前行锁存并逐拍一致传递，不扩建身份层。新行还须等待上行释放与真实`physical_debt_zero`。 |
| 输入 | 恰好64次512bit握手，`group=b>>1, half=b&1, mask=ffff`；lane l的F32为`LN[16*b+l]`，置`in_lanes[32*l+:32]`。只在握手后推进，valid被阻塞时数据/标签不变。Q有32个物理group slot；每组half0填槽，half1使`accepted_groups`加一。 |
| 输出 | 按group递增、half0再half1；128bit的byte lane l对应`q[32*g+16*h+l]`。**half0的out_scale固定0，仅half1携带有效FP16 scale**；half1握手后covered加一/slot释放。`out_d_full/out_reciprocal`是诊断量，矩阵使用存储FP16 scale再精确解码，不以d_full替换。 |
| 正常退休 | Q等待capture/write均到目标、bank/amax/div/MUL在途计数及返回valid/读活动排空，才置done；done/status/first_bad保持到done_ready。连接须合取LN成功done已锁存、1024个LN值/64个Q输入half接受、64个Q输出half与32个scale实际写完、Q status0/accepted=covered=32、`physical_debt_zero`、打包器空，再发布行；不是最后输入或某一个输出就完成。 |
| 数值错 | status1。错误slot跳过输出，正常slot仍可输出，数值错不关闭in_ready；须继续喂完规定64half、持续接收/丢弃Q输出，等待真实退休。此前/后续可能已有部分正常group写入；暂存行一直无效，错误结果不得发布A8。首错使用Q的`first_bad_col`，不以外部到达先后替换。 |
| 协议错 | 非法start可立即status2；输入task/epoch/row/group/half/mask不符会消费该次错误握手、将当前slot标ERROR_SLOT，截短drain_groups并关闭后续输入，再排空已收前缀后status2。此前正常group仍可能输出，不能期待凑足64个输出。此路径的accepted可能含错误slot，不是成功覆盖。旧TB坏第二half只测了首组，不能推广为全故障恢复证明。 |

协议错误还包括内部tag/helper/多lane返回异常；并非每条内部故障路径都设置截短drain目标，不能凭status位推导所有内部损坏均有限拍退出。薄连接应保持输出排空并等待真实done/debt；没有真实完成就不能伪造成功或拉常数零债务。本次不扩展通用恢复机制。若Q提前协议结束而LN尚有输出，连接进入本地丢弃状态，把该LN行剩余输出消费至其done，清空打包寄存器，保留失败状态；否则被阻塞的LN也可能无法退休。LN本身失败时不得启动Q。

**最小连接与时序依赖。** 当前LN只有在整行normalize/gamma及检查完成后进入`OUTPUT_ROW`，首个`out_valid`可作为内部成功行已计算完的依据；但其`done_valid`要等1024输出消费完才出现。不能先等LN done再允许其输出进入Q，否则形成等待环。推荐在首个LN out_valid出现时保持LN out_ready为0，先完成Q start握手，然后逐个接受真实LN值；仍在最终发布时等待LN成功done。若合同要求观察显式“计算完成”信号才启动Q，可从同一已检查成功的OUTPUT_ROW边界导出一个ready，而不能借用现有done或重放夹具。此边界须由修复版LN保留并验证。

打包器采用`FILL(0..15)→SEND`，只有LN握手才写`pack[32*lane+:32]`并检查`out_index/out_last`；满16个后仅向Q保持一次valid，Q握手后清计数再装下一组。阻塞时停LN、不覆盖pack；不做无依据的同拍收发旁路。最保守无阻塞打包阶段为1024个标量接收拍加64个发送拍，共1088拍，另计启动/等待；这只是所选FSM的拍数预算，不能与8482或旧Q141直接相加成链实测。

| 外部交付选择 | 对后继矩阵的代价 |
| --- | --- |
| 直接输出现有128bit half＋scale/group/half | 连接本身省1088B，但后继仍需收集两个half成256bit，保留各group以供多个输出tile重读，并隔离Q部分失败结果；若提前计算则还需丢弃未提交PS等，超出本段最简职责。仅在后继已有可隐藏写入、成功后发布的A bank时合适。 |
| **推荐：固定1024B q＋64B scale行暂存后发布** | q0/q1各32×128bit、scale为32×16bit，总1088B；half0写q0，half1同拍写q1和独立scale bank，覆盖计数只认实际提交。行成功后以同步读group返回`{q1,q0}`与FP16 scale；[现有A行bank][lnq_bank]就是此端口形状，但原深度128，要明确固定32深度实现及实际RAM映射。后继[矩阵行流水][matrix]还需FP16→F32精确scale解码、A/W/PS供给与tile/row调度；这一行暂存不声称已覆盖四row或完整矩阵。 |

修订6确定生命周期：成功后置`row_valid`，开放同步group请求/响应（256bit q/16bit scale，最多一个未消费响应）；独立`row_release_valid/ready`释放，释放请求优先于新读，已有响应先实际消费，释放边沿不接新读。成功done在释放后报告并保持到消费，之后才接下一命令；错误行不发布。原“最终结果握手兼作释放”的备选不采用。Q数值错允许跳过错误group，不能仅因输出缺组先报协议错；完整覆盖在成功发布条件中检查。1088B只是新增暂存payload，512bit pack另64B；Q内部既有32slot/16bank/divider/16MUL资源仍在，不能把1152B当整个连接资源。原input/gamma驱动真实LN、同输入LN/Q比较、反压和失败排空等检查由A002按修订6执行，本研究未运行或派发新实验。

本轮[核查脚本](fixed_graph_support_20261014/check_lnq_fixture_layout.py)真实命令与[采样](fixed_graph_support_20261014/lnq_fixture_layout_time_20261015.txt)：`taskset -c 0-3 nice -n 19 ionice -c 3 timeout 10s prlimit --as=8589934592 -- /usr/bin/time -v -o source/fixed_graph_support_20261014/lnq_fixture_layout_time_20261015.txt python3 source/fixed_graph_support_20261014/check_lnq_fixture_layout.py`。进程墙钟0.05s、峰RSS16544KiB；此前未统一采样的交互读取累计仍UNKNOWN，沿原研究预算、不重置。未改E002/工程记录，未运行EDA、模型或新gold。

### LN→Q局部实测与同版时序边界（AT121/AT116，AT124补充，2026-10-15）

依据工程通信 `m004-lnq-row-AT121-AT116-research-data-20261015`，已读取[阶段报告][lnq_stage_result]与[机读证据][lnq_stage_evidence]，本次仅更新现有判断，未重跑工具或重复完整身份审核。AT121功能与AT116联合OOC使用同一顶层SHA `7c194fa31f715effd9d886a3cf925371e83e23bb060ca56ab05ebfa338caa592`，LN为AT110修复版`a46d468e…`、Q为`23c18d6a…`。

**工程交付的限定结论为局部真实数据/接口PASS、联合资源已测、150MHz综合内部时序FAIL；修订6算术在途共同reset缺口已由后续AT124限定关闭，AT121原reset声明仍未证明。** 两个P1真实input/gamma经LN、pack、Q和可复读行，由既有独立核验夹具检查LN统计量/1024个y及1024个q/32个scale；AT121五条正常行、四条错误路径按原限定范围保留。成功行的倒序/重复读、读响应保持与释放优先级有对应覆盖。LN错误不启动Q；晚Q数值错在已有62half暂存后仍无行发布；受控错误group标签覆盖一条实际可退休的协议错误路径。这些不代表任意内部故障或真实final gamma均已覆盖。

AT121历史reset审核收窄依据 `m004-lnq-reset-coverage-research-note-20261015`：主控发现冻结TB在新cmd接受前判断`q_started/half_sent`，可能沿用上一行的1/64而零次进入等待循环；原日志`pre_reset_half_sent=64`及reset标记不证明本次命令已接受且Q尚未退休。此为覆盖缺口，尚非DUT复位故障。后续补测见下段，原日志及这一历史判断保留；新时序方案不能沿用此标记签预约/待发阶段reset。

依据主控 `m004-lnq-at124-research-closeout-20261015` 及[审核记录](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的 `at124_reset_closeout`，接纳 **PASS_SCOPED_LNQ_FP_INFLIGHT_COMMON_RESET**：AT124本次row31已接受1个cmd、启动Q一次并接受2half，在route0真实FP已发1/返回0、`div_pending=fp_pending=1`时共同reset；随后16拍内观察到1次旧raw result_valid，但无FP/语义接纳、输出、行发布或protocol_fault，quarantine结束且债务归零，下一真实P1行逐位通过。这关闭修订6本次算术在途共同reset覆盖缺口；AT123仍只证明已收未处理组，AT122普通TB断言FAIL保留，AT121原声明不恢复。AT124沿用AT116同版RTL，原资源证据可按该范围引用，WNS−49.011ns时序FAIL不变。本次仅读取主控结论与记录更新分析，未重复身份审核或运行实验。修订6已收束，A002按 `D-M004-Q-TIMING-PARTITION-01` 连续实施修订7；新扫描/预约/待发阶段reset、任意错误复位、外部AXI及整图均不在AT124覆盖内，新增状态仍须纳入真实债务与共同reset验证。

| AT121条件 | cmd接受→row_valid边沿差 | cmd接受→最终done消费边沿差 |
| --- | ---: | ---: |
| gamma0正常 | 8573cycle | 8855cycle |
| 真实embedding gamma1，确定输入空拍＋Q输出阻塞42cycle | 11064cycle | 11346cycle |
| gamma0输入空拍 | 8743cycle | 9025cycle |

done列包含消费者34次读取（32组倒序＋2次重复）、响应故意阻塞与额外持有，不能作为固有最短服务时间或稳态II；gamma1也不能减去42cycle还原正常速率。gamma0的Q start局部计数7452、LN首输出握手7453、Q首末half提交7514/8569，支持所选先启动Q再放行真实LN输出的连接方式。旧LN的8482/11792与新连接的端点、输入/输出刺激不同，不能由二者相减声称Q的独立增量成本或加速比；原静态1088拍pack账本也不是全链实测分解。

AT116同版U55C `xcu55c-fsvh2892-2L-e`、6.667ns约束联合OOC：**41655 LUT、12192 FF、50 DSP、16 RAMB18（8 tile）、0 URAM、blackbox0**。分层LN为14504 LUT/3349 FF/2 DSP，Q为26864 LUT/7733 FF/48 DSP，顶层本地为287 LUT/1110 FF；这是联合合成映射，不与旧AT108简单相加。1088B暂存映射为LUTRAM，8个BRAM tile不能归给该暂存。

内部WNS **−49.011ns**、TNS −50792.254ns；最差路径从Q槽ordinal寄存器至除法服务内部寄存器，231级逻辑、55.661ns。该候选未通过150MHz综合内部检查，不能把RTL周期按150MHz换算为已证运行时间；也不将路径倒数称为物理Fmax。95个输入/416个输出无外部delay，未P&R。工程另以AT120查询同一DCP，确认row_valid/done_valid最终由LUT2驱动而非GND；这限定解释了综合中的常量驱动警告，不消除时序违例。

这些证据补齐了最简LN→Q连接的局部功能与面积数据，同时表明当前Q槽选择至除法服务的组合路径仍限制时钟；叶子连续接收证据不能代替完整服务时序。下一架构取舍由A001集中确定，本更新不提出新实现或工具任务。外部搬运/HBM、矩阵A接入、完整请求、P&R/板卡仍未验证；旧M005 v4保持冻结，不更新整模已证吞吐或项目可行性结论。

### Q长组合路径：一套有界选槽与操作数切分建议（2026-10-15）

本节保留AT131交付前的设计与条件预算，其中“未测/UNKNOWN”指当时证据状态；修订7后续实测及其适用边界见下一节，不将原13拍结构预算改写为实测全程II。

回复 `m004-lnq-critical-path-partition-question-20261015`。**将除法请求端的32槽线性argmin改为每拍4槽、共8拍的固定扫描，随后独立寄存原始payload、分类/最高位位置、最终除法操作数；仅保留一个待发描述符。** 此单一建议已由A001以 `D-M004-Q-TIMING-PARTITION-01` 采纳，执行合同见[SM004修订7最后一节](../project/missions/SM004.md)，A002唯一负责实现与工具，A003定向分析交付收束。不改FP IP/数量、tiny规则或行接口；采纳不等于新候选已实现/通过，不预认150MHz或整行收益。

主控同时纳入同型银行选择修正：AMAX/REPLAY的两个32槽argmin改为显式五级平衡二叉比较树（32→16→8→4→2→1），每级携带valid/完整ordinal/slot，比较相等时取较小slot，选择结果须与旧循环一致。它不新增扫描状态，保持`read_active`的两half读取节奏、`prefer_replay`、`mul_quarantine`及tag采样时刻；每级不得再用动态choice回查32槽。五级组合树的实际时序/资源未测，仍可能成为新最长段。修订7要求受影响短测与同版LN→Q回归后一次联合OOC，首个成功网表后即停止并交真实新最差路径，即使时序仍负；这些由工程按合同执行，本研究不启动新任务。

**长路径来自哪里。** 已读[AT116最差路径][q_timing_paths]，并核当前Q、divider、tiny与FP位型包四文件SHA均与AT116冻结副本相同；[静态分段记录][q_path_partition]保留身份和计数。最差路径含231级，其中31个CARRY8与大量LUT/MUX出现在逐槽选择链。Q第178–193行的循环更新`recip_choice`，再以`ordinal[recip_choice]`回读下一轮比较，形成32槽顺序依赖；`have_recip346_in…have_recip3133_in`正是报告中的连续网络。综合把这些节点命名在`q/divider/tiny/tag_pipe…`下，不能据层级前缀称它们是tiny除法迭代。

| 同一条报告路径的可见分段 | 级数/报告边沿差 | 源码解释与归因边界 |
| --- | --- | --- |
| 发起clock到`q/divider/u_div/have_recip1264_out` | 194级，49.778ns（累计arrival49.806ns，扣发起clock0.028ns） | 对应递归argmin选择链及综合形成的选择网络；是本次最主要级联。 |
| 上述网络到首个`<hidden>`IP网络 | 9级，2.410ns | 可见`u_div/U0_i_*`组合逻辑；源码连接为选中slot→amax/d_full/tag选择→route/操作数→divider输入，不能仅凭综合改名将这2.410ns精确拆给某个函数。 |
| 首个隐藏网络到捕获寄存器数据端 | 28级，3.473ns | IP隐藏区；不是整个除法事务延迟。三段合55.661ns，含综合估计路由38.792ns，未布线。 |

Q第168–177行还有真实前处理：SCALE的`amax<=03fe0000`选择tiny路由；RECIP的非零subnormal d经[位型包][q_fp_bits]第35–71行的最高位查找和移位形成精确`d×2^24`。返回时[divider service][q_div_service]第54–58行用9bit指数加24并在溢出时返回Inf。实际tiny使用[quant16_tiny_div127.sv][q_tiny]：`make_units`后六个寄存阶段，每级五步restoring，最后remainder≥64舍入；包内另有组合`tiny_div127_bits`定义，但此服务未调用它。最差报告路径没有穿越六级helper寄存器，不能将55.661ns归为“30步tiny组合除法”，也不能分配一个未经观察的subnormal专属延迟。

**固定控制步骤（边沿编号是新设计预算）。** 只在没有待选/待发请求时启动扫描；S0锁存SCALE_REQ/RECIP_REQ资格位图，按原`prefer_recip`规则选择本轮phase。资格中的slot处于REQ，正常情况下不会自行改写ordinal/payload；扫描期间新到的请求留给下一轮。使用完整32bit ordinal，不能假设slot编号等于ordinal（Q还支持槽回绕）。

| 边沿/阶段 | 操作与真实预约 |
| --- | --- |
| S0 | 锁存选定phase的32bit资格mask，清`best_valid`，不发FP请求。无资格时保持空闲，不空扫8拍。 |
| S1…S8 | 每拍读4个slot的ordinal，显式平衡两级比较选4者最小，再一级与寄存的best比较；以`valid,ordinal,slot,slot_epoch`保存赢家，task epoch沿S0锁存，同ordinal按较小slot打破平局。读选择最多8:1、比较链最多3级，禁止写成另一个可展开的32轮反馈链。 |
| S9 | 复核赢家仍属同task/slot epoch且处于对应REQ；预约该slot为SCALE_RESERVED或RECIP_RESERVED（现4bit状态尚有13/14可用），锁存amax/d_full和完整102bit tag/phase。32:1数据选择止于此寄存，不与后续归一化级联。只有这一个选择器操作REQ→RESERVED；资格变化异常记协议故障，不伪造有效请求。 |
| S10 | 从锁存payload产生tiny/subnormal/zero分类及subnormal最高位k；最高位函数改写为有界平衡优先选择，保持原位型结果，避免23次顺序覆盖再接移位。 |
| S11 | 使用已寄存k计算subnormal的指数k+2/尾数移位，锁存最终numerator、denominator、route、tiny_amax及同一个tag。normal直接复制；tiny仍是安全0/127的FP事务加精确helper，RECIP仍是1/(d×2^24)。 |
| S12或以后 | 置req_valid，全部payload/tag保持至`req_valid&&req_ready`；仅该握手将RESERVED→原WAIT、更新phase偏好/issue计数并移交给原32项divider ring。下一轮S0最早在握手后下一拍，不做同拍穿透重装。 |

相比原即时选槽，扫描采样后新变ready的请求可能延后一轮；这是有界调度变化，不改变每组SCALE→RECIP依赖、最终按group输出或首错数值顺序。不能再把现有`div_fire`状态更新/计数留接实时`div_slot`，必须改接锁存的slot/phase/tag。选槽预约与FP接受分开计数；原ring的pending只数已接受请求，不用它冒充尚未发出的本地描述符。

返回沿用实际valid和原ring顺序：每个语义请求仍有一个真实FP事务；tiny同时保留dummy FP与helper，两者都返回后才退休，不能为了降低延迟省掉dummy或helper债务。原tag/slot epoch检查、FP16 scale舍入、数值错误键`group→phase→lane`及错误slot跳过规则保持；早到错误不终止其它已接收组的首错归并。新增scan_busy、reserved/payload_valid必须同时纳入Q的done与`divider_helper_debt_zero/physical_debt_zero`；仅已发请求归原pending，移交边沿不能出现“前级清空、后级尚未计数”的假零债务。输入协议错后停止新输入，但已接受slot与已预约/已发请求照常排空，不丢弃物理返回。

reset同时清资格快照、best、phase计数、待发valid/预约状态；与原Q整域reset一致。原无reset FP IP继续运行，divider保留12拍quarantine，tiny清valid管线；不因新前处理拍数而缩短旧返回隔离。req_ready低时不能扫描改写正在等待的payload，也不能以状态RESERVED冒充真实FP接受。

**可复算的代价与剩余未知。** 按上述保守FSM，S0采样到最早请求握手为12个边沿差；服务ready持续有效且有积压时，两次FP请求接受间隔13拍，若FIRE等待W拍则增加W。新资格等待正在执行的扫描、SCALE→RECIP返回依赖、空闲或环满另计，所以这不是任意输入下的全程II上界。32组最多32 SCALE＋32 RECIP，即控制忙碌预算≤832拍（64×13，不含上述等待），每正常组两请求占26拍。当前单pack一half至少16接收＋1发送拍，一group至少34拍；26<34只说明无阻塞时控制容量有余量，不能证明首尾/依赖延迟全部被隐藏或行周期改善。实际请求间隔、语义返回延迟、整行周期与新增寄存资源均待测。

仅在除法前加一道寄存会留下原194级选槽路径，不能解决根因；上述8拍扫描针对这一点。切分后仍须检查每拍的3级ordinal比较及8:1读取、S9的32:1 payload选择、S10最高位选择、S11移位、helper首级make_units＋五步restoring、返回head选择＋指数恢复/half转换和IP首段。AT116旧版Q第106–129行的AMAX/REPLAY同型线性argmin现已纳入修订7五级比较树修改范围，但尚无新候选测量，不能登记为时序已解决。一次综合是否足以过目标、剩余哪段最长都为UNKNOWN，不以multicycle/false-path约束掩盖未实际分拍的逻辑。

最有区分力的后续证据应为：同输入的全部q/scale/d_full/reciprocal/首错不变；选择、预约、FP接受、FP/helper返回、slot释放逐项守恒；在每个新阶段reset、FIRE反压、SCALE/RECIP交错、tiny零/舍入/溢出与subnormal边界下无重复/漏发；新同版时序报告不再存在32槽串接链并明确列出新的最差段，再分别测row_valid/释放后done。它们是给A001/A002的验收建议，本研究未运行或授权新实验。旧AT116、AT121与M005 v4原样保留。

### Q切分后的局部实测：时序改善，150MHz仍未通过（AT130–132，2026-10-15）

依据工程通信 `m004-q-partition-at131-research-data-20261015`、[阶段报告][lnq_stage_result]修订7段及[机读证据](../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_q_partition_stage_evidence_20261015.json)，仅更新现有分析，未重复原日志/身份审计或运行实验。最终Q SHA为`a1fd5b036d45f94fe6121ddd3f8e6b9c5764b48e1bf11c2164205bbc9ed3764a`；LN仍为`a46d468e…`，顶层仍为`7c194fa3…`。工程记录AT130功能与AT131 OOC共同冻结文件逐SHA一致。A001后续在 `m004-q-error-metadata-research-decision-20261015` 接纳 **PASS_SCOPED_Q_PARTITION_AND_LNQ**，范围为所交独立Q、真实LN→Q功能/控制/复位及同版资源；AT131内部时序FAIL与实际Fmax未知不变。快速供数82组Q的2156cycle/输入停1173保留为该样本计量，不能由两真实LN行只增24/23拍推断所有消费者无吞吐代价。

| 同刺激或同设置比较 | 修订6 AT121/AT116 | 修订7 AT130/AT131 |
| --- | ---: | ---: |
| gamma0命令→row_valid | 8573cycle | 8597cycle（+24） |
| embedding gamma1命令→row_valid，含输入空拍及42拍Q输出阻塞 | 11064cycle | 11087cycle（+23） |
| 上述两行命令→最终done，含故意读/保持 | 8855 / 11346cycle | 8879 / 11369cycle |
| LUT / FF | 41655 / 12192 | 37346 / 12518（−4309 / +326） |
| DSP / RAMB18 / URAM | 50 / 16 / 0 | 50 / 16 / 0 |
| 内部WNS / TNS，6.667ns | −49.011 / −50792.254ns | −1.750 / −1225.669ns |
| 最差数据路径 | ordinal→divider，231级/55.661ns | FMUL返回→首错归并→Q done_status，39级/8.399ns |

AT130保留两真实P1行统计量、LN输出与Q/scale对原独立夹具逐位比较，五正常/四错误、反压、重复读/释放及无reset恢复局部通过。82组Down任务有164次scan/reserve/实际issue守恒；连同32组Wi及27个adapter边界，原独立Q比较保持。通信报告该样本控制请求接受间隔13–26cycle，是观测范围，不是任意流量上界或整图II。新连接行延迟略增，不能把时序改善表述为同周期整行提速，也不能从gamma1减去42拍还原无阻塞率。

新增控制状态已有定向reset证据：工程报告AT128覆盖扫描、预约、分类及FIRE合法受阻四相位，先证明本任务有效/非零债务，再共同reset、16拍无ghost，随后无第二次reset的原独立gold组恢复；FIRE阻塞为TB两端一致的受控探针。AT130同版完整LN→Q另在本行FP发1返0且`div_pending=fp_pending=1`时复位，隔离窗观察到旧raw valid一次但未接纳/发布，下一真实P1行通过。这更新修订7“尚无新增状态reset样本”的边界，不覆盖每一子状态、任意故障或外部AXI，也不恢复AT121历史声明。

AT131为同U55C候选唯一成功联合OOC，blackbox0/latch0，仍有1294个setup违例端点；q0/q1/scale仍映射LUTRAM。**结果支持有界选槽/寄存及银行平衡树显著缩短旧选择链对最差路径的影响，但150MHz内部时序检查仍FAIL。** AT116与AT131均在`synth_design`后才`create_clock`，比较是同设置综合网表内部计时，不是先按6.667ns约束优化或P&R结果；95输入/416输出缺外部delay。AT132对最终DCP确认row_valid/done_valid各由实际LUT2驱动，不能据综合中途常量告警认定输出被裁掉。当前瓶颈转至FMUL返回首错归并，具体后续处理由A001决定；本更新不增加实现或OOC任务。布线Fmax、外部搬运、矩阵连接、真实final gamma和完整图性能仍UNKNOWN/NOT_RUN，旧M005 v4保持冻结。

### AT131返回路径的最小切分：仅寄存错误元数据（2026-10-15）

**主控已采纳本方案。** 决定 `D-M004-Q-ERROR-METADATA-PIPE-01` 的执行依据为[SM004修订8末节](../project/missions/SM004.md)。A002唯一负责81bit错误元数据寄存级、受影响回归和同版联合OOC，A003本次定向分析收束；不新开研究实验。新候选须在`synth_design`前读入真实6.667ns时钟XDC，比较同时注明RTL与约束流程变化，首个成功网表后收束。该决定本身是设计采纳；后续AT134局部功能与AT136成本停止见下一节。RAM写数据路径计时缺口、布线Fmax和完整图性能仍开放，下一整体方向为矩阵A连接。下文保留原静态依据与结构预算，旧v4及历史测量不变。

回复 `m004-q-return-timing-research-question-20261015` 与主控最小性补充。已定向读取[AT131第一条路径][q131_path]、[冻结Q][q131_src]第303–328、412、485–510、575–611、622–684行及[原Tcl][q131_tcl]；Q SHA为上节`a1fd5b…`，路径报告SHA为`4a7c36f0d9170e2db48bd6609b4d86a10e5a720ed7ad2688ad43a8560fe9ebad`。首条路径穿过`whole342_in`、跨多个lane的`first_error_key`逻辑、64bit比较carry及done状态，39级/8.399ns中6.197ns是未布局路由估计；综合层级名不能当作各源码函数的精确耗时。源码确有“16lane转换→线性首坏lane选择→AMAX/DIV/MUL来源顺序min→状态比较”的同拍级联。

**先确定不必增加的数据流水。** 原done谓词排除`amax_ret_valid/div_resp_valid/mul_any_valid`，而`best_error`仅在这些返回分支改变，`mul_pop`蕴含`mul_any_valid`。因此在原done成立边沿，严格有`best_error==first_error_key`；直接用已提交`first_error_key/numerical_error`计算done_status，保留protocol优先与覆盖计数，数值语义等价且无需增加周期。slot全FREE及真实pending归零进一步保证此前返回已提交。该证明只适用于当前没有额外错误寄存级的实现；新增一级后还须显式等该级为空。

A002已完成的[AT133端点表][q133_endpoints]（guard child0/trigger null，60.813549s）及通信 `m004-at133-targeted-endpoint-table-research-answer-20261015` 进一步区分了范围；本研究仅读已有文件，没有启动DCP查询：

| AT131既有DCP的目标端点 | 数据路径 / 级数 / slack |
| --- | --- |
| first_error_key | 7.783ns / 34 / −1.134ns |
| numerical_error | 8.168ns / 38 / −1.519ns |
| done_status | 8.399ns / 39 / −1.750ns |
| q0/q1写数据及bank写数据 | 查询匹配实际RAM数据脚，但四份报告均为`No timing paths found.`；时序UNKNOWN，不能写PASS或认定路径不存在。 |

据此，仅换done引用不能消除已见的首错/数值状态违例；**推荐一套“错误掩码寄存＋来源平衡min＋已提交状态完成”的最小改动，不新增FMUL数据槽。** 保留16lane原`rounded_q8`及bypass：第322行`fraction>=halfway`的int8舍入规则不改，也不与FP16 RNE混为一谈。

| 边沿 | 数据、错误与债务职责 |
| --- | --- |
| E0：真实`mul_pop` | 原样写q0/q1、置该half的`q_received`、推进物理head/pending/returned；每lane保留转换后的bad位，`OR(bad_mask)`即决定ERROR_SLOT，不让错误half进入Q_DRAIN。新增单级`err_valid`、16bit bad_mask及64bit key_base；base在此边沿按原ordinal/phase4/half生成，low lane位清零。候选不在未来回读可能已释放/复用的slot。原完整tag/epoch检查及protocol优先保持。 |
| E1：消费错误元数据 | 用显式四级平衡优先编码取mask最低置位lane，与base按位或得到MUL key；AMAX、DIV依原互斥条件各形成至多一个完整64bit key，无候选填全1。`min(min(first_error_key,amax_key),min(div_key,mul_key))`两级比较后写回first_error_key，保持完整group→phase→lane次序。该拍可消费旧候选并接受下一`mul_pop`的新候选，不能写成互斥的`if/else`。 |
| 完成边沿 | 沿用原排空谓词，再要求`!err_valid`；done_status只读已提交first_error_key/numerical_error。E1前err_valid仍为1，禁止同拍以旧key完成；E2起才可使用刚提交的key，且仍需所有原债务/slot/覆盖条件满足。 |

`numerical_error`改为原寄存值与各来源**本地坏事件**的sticky OR（MUL用`mul_pop && |bad_mask`），不再从64bit `best_error!=first_error_key`比较产生；各事件必须使用原分支条件和bypass，不新增数值判据。原有限错误key都小于全1哨兵，首次坏事件必使key变小，此后sticky已为1，故该改写保持原数值状态。候选级只传错误元数据，正常q写入/接收间隔不变，新增逻辑存储上界为1+16+64=81bit，实际映射未知；不需要128bit/512bit数据FIFO或新的数据credit，成立条件是归并每拍无条件接收至多一个MUL候选，不能被下游out_ready阻塞。

末个坏half在E0置ERROR_SLOT及q_received，E1可沿原规则释放slot，同时候选归并；base已自含身份，不依赖被释放slot。`mul_return_debt_zero`和`physical_debt_zero`须包含`!err_valid`，内部done及start准入同样不得绕过；E0物理pending减1与err_valid置1、E1候选消费与key提交都是同边沿移交，不能产生假零债务。可核守恒为“已接收MUL坏事件数−已归并数=err_valid”（同task/reset域），连续两坏half及不同来源同时错误均应取全局最小key。共同reset清valid/mask/base，保留原MUL四拍与divider十二拍隔离，不重测或否定AT124/130旧覆盖；新增寄存级的reset样本仍须在后续受影响范围验证。新start只能在旧候选为空后重置key，避免跨行覆盖。

结构代价是MUL错误key晚一拍提交，数据路径不强制增加周期；done仅可能等待新增候选的一拍排空（其他条件相同且无新返回），原末slot释放可能已覆盖这一拍，整行增量不能预签。当前冻结LN→Q顶层在`q_done_fire`才采样`q_first_bad`（第204行），因此完成时首错不变；运行中first_bad_col暂态会晚一拍，不承诺与旧版逐拍一致。剩余未知包括转换→坏mask/原q写入、mask优先编码＋两级64bit min、AMAX/DIV key形成、覆盖计数与新布局扇出；不承诺此切分即过150MHz。区分检查聚焦最后一个返回才出现错误、两half连续坏且不同group/phase竞逐首错、slot释放同拍归并及新候选valid时reset；仍用原独立gold、首错与真实排空检查，不产生新gold或扩大调度。

AT116/AT131冻结Tcl的SHA同为`9a1a8fe16ea8dfcf02d19280ad443023acc50b07f2bc4b839c5693bc78d0f9bf`，第24行`synth_design`、第25行才`create_clock -period 6.667`，没有前置read_xdc。后续由A001确定的候选会在综合优化前读入时钟约束，因此比较必须标为“RTL与约束读入流程共同变化”，WNS差异不能全部归因本寄存切分；本研究不要求补跑旧版或扫参。以上仅静态建议，实施/预算归A001/A002；未运行EDA/模型/新gold，历史未采样host累计仍UNKNOWN，旧v4不变。

### 修订8测量历程：AT134局部功能、AT135–137失败与后续恢复（2026-10-15）

依据工程通信 `m004-q-error-metadata-at136-research-data-20261015`、[阶段报告][lnq_stage_result]修订8末节及已读AT135/136原guard，保留**当时工程交付的局部功能PASS、联合综合COST_STOP**，不代替A001阶段审核。以下UNKNOWN与恢复授权按当时范围记录；当前测量收束见后面的AT138/139小节。本研究未重复功能/冻结身份全量审计或启动工具实验。新Q SHA为`bb47385dde7c3bb65eea97d71a81d739eb3023f38213a67866ee9bd826afa5b6`；工程记录AT134/136的353项共同冻结文件逐SHA一致。

AT134保持原114组/3648B及27 adapter独立参考、两真实P1行LN统计/1024 F32/Q/FP16 scale逐位比较；正常/错误/反压/释放及真实算术在途reset局部通过。gamma0/gamma1命令→row_valid仍为8597/11087cycle，支持“错误元数据寄存未增加这两个同刺激正常行周期”，不外推全部消费者吞吐。新增四项在真实MUL返回握手上有限注入`+Inf`：末half第31列错误；连续两half第12/17列捕获2/归并2/同拍交接1、最终首错12；group0 MUL与group1 AMAX/group2 DIV竞争最终首错31；候选valid时共同reset后16拍无ghost、下一原Wi gold行通过。它们支持末错不丢、连续候选守恒和候选复位隔离的控制规则，不是自然模型算术异常证据。

[AT135原guard](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT135_SM004_lnq_error_metadata_ooc_01/guard_ooc/guard_result.json)为冻结包漏三份旧IP Tcl、综合前child1，7.481030s；[AT136原guard](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT136_SM004_lnq_error_metadata_ooc_02/guard_ooc/guard_result.json)记录补齐后的运行292.768357s、峰owned RSS17389648KiB、`semantic_stall`/child−9。工程[Vivado日志](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT136_SM004_lnq_error_metadata_ooc_02/work/vivado.log)记录综合前XDC `used_in_synthesis=1`及综合内应用6.667ns；时序优化阶段120s无日志语义进展后被守卫停止。**当前没有有效DCP、资源、check_timing、WNS/TNS或新最长路径；本版150MHz结论为UNKNOWN，不能记为已达或时序FAIL。** 原AT131资源和−1.750ns只适用于旧Q/旧约束流程，AT133 RAM写数据未获路径的缺口也没有被本轮补齐。

原合同两次OOC启动2/2已用，累计300.249388s；工程已测static57.873714s、RTL30.857233s，host准备未完整采样，不能记0。当前判断是错误元数据方案已有局部数值与控制支持，物理目标仍缺证；工具成本停止不能反驳该结构或整个FPGA方案的可行性。真实final gamma、外部AXI/HBM、矩阵A、完整硬件图、P&R/板端和整模性能仍未验证；旧v4保持冻结。

**守卫判据勘误与限定恢复。** A001后续决定 `D-M004-SYNTH-LOG-SILENCE-CORRECTION-01` 已纳入[SM004修订8末节](../project/missions/SM004.md)，接纳AT134局部功能。AT136的`semantic_last`只随stdout阶段词刷新，原记录没有算法进展或CPU时间采样；上述120s只能表述为日志静默触发，不能据此判定综合计算停滞。AT135构建FAIL、AT136原COST_STOP/child−9及原成本不回写。主控当时授权同版一次测量恢复，RTL/IP/Tcl/XDC不变，guard总墙钟1200s、semantic阈值1201s、24GiB，累计OOC≤1800s不重置；当时次数限制仅增加这一次，无第四次，后续普通工具修复决定见下段。仿真仍保持120s真实进展保护。新产物到达前，本版资源/时序仍UNKNOWN，不迁移AT131；本研究不启动该运行。

**AT137恢复运行终态（工程后续交付）。** 通信 `m004-at137-physical-scope-to-research-20261015` 报告AT137与AT136的358项冻结输入相同，[原日志](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT137_SM004_lnq_error_metadata_ooc_guard_corrected_03/work/vivado.log)已到`synth_design`完成。随后冻结Tcl将实际周期`6.66699981689453125`与`6.667`精确比较，检查失败导致child1；guard为371.136359s、峰owned RSS20560096KiB、trigger null。此为综合后脚本检查FAIL，不是150MHz时序FAIL；未写正式资源/时序报告或DCP，资源/WNS/TNS/最长路径仍UNKNOWN。三次累计OOC671.385747s，工程当时按3/3停点收束；AT134功能范围保持。该完成事实进一步否定“AT136 stdout静默即可证明算法停滞”的推断；本研究仅同步终态，不追加查询、运行或重算旧v4。

**普通工具修复授权（现已完成）。** [SM004修订8“普通工具脚本修复与结果保全”](../project/missions/SM004.md)的 `D-M004-ORDINARY-TOOL-REPAIR-01` 替代上述“3/3、无第四次”停点；主控在 `m004-lnq-wi-row-design-accepted-20261015` 再次明确此状态。A002获准在原累计OOC≤1800s内连续修复已定位脚本错误，已用671.385747226s不重置。周期采用1e−6ns工具属性容差、综合返回后先保存raw DCP再检查，RTL/IP/6.667ns前置XDC/优化选项保持原身份；这不改变数值gold或时钟目标。首个有效同版网表及所需报告完成后收束，即使WNS负。后续AT138/139已达到该出口，当前不再沿此授权续作OOC或Q改版；修订9与本段成本分开，本研究不启动工具或另设批准门。

### 修订8测量收束：综合网表与资源限定接纳，150MHz内部时序未过（AT138/139）

依据主控通信 `m004-at138-at139-measurement-boundary-research-20261015` 及[既有审核记录](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的 `at138_at139_physical_closeout`，记录 **PASS_SCOPED_LNQ_SYNTH_NETLIST_AND_RESOURCES**，同时保留 **SYNTH_INTERNAL_TIMING_FAIL_150MHZ / NOT_ROUTED**。A001已核AT138的358份冻结输入、24份产物及AT139查询DCP来源；相对AT137仅Tcl改变，与AT134共同353份输入一致。当前Q仍为`bb47385d…`，AT134局部数值/协议/复位证据按同身份复用，不扩大覆盖。本研究仅同步主控已核结论，未重复身份审计、时序查询或回归。

AT138已保存raw及最终DCP与正式资源/时序/check_timing报告。U55C联合LN→Q综合为**37569 LUT、12543 FF、50 DSP、16 RAMB18E2、0 URAM/blackbox/latch**；6.667ns时钟在综合前加载。内部WNS **−1.408ns**、TNS **−863.788ns**，1316个setup违例端点；最差`q/divider/head_reg[1]`→`q/first_error_key_reg[0]`，数据延迟8.057ns、32级逻辑。AT139只读同DCP，首错记录端点−1.408ns、`numerical_error`端点+0.477ns、`done_status`端点+4.014ns：错误标志/完成状态定点路径满足本次约束，首错记录仍违例。DIV返回/FP16恢复至首错归并留作后续联合物理闭合问题，本轮不开Q微优化分支；AT131与本版同时改变RTL和约束流程，不把差异全部归因RTL。

内部未约束端点为0，但95输入/416输出缺外部delay；四类RAM写数据查询仍匹配到pin但无可报告路径，不能据此签写路径达标。以上仅为综合网表结果，未P&R、实际Fmax未知，也不代表LN→Q→Wi或完整图的资源/性能。此前AT135–137失败与AT136日志静默误判原样保留，AT138新产物补齐的是当前LN→Q候选网表/资源及综合内部时序证据。

AT138 guard为child0/trigger null、406.915653s、峰owned RSS20558300KiB；AT139为child0/trigger null、60.418869s。修订8最终已测OOC1078.301400s/1800s、static118.292583s、RTL30.857233s，未完整采样的host准备仍UNKNOWN。首个有效网表及所需报告已取得，测量收束，余额不续作OOC/扫参/Q改版，也不转移修订9。A002继续已采纳的真实完整Wi连接；主控本次交付时该段仅源码准备，不记为工具已启动或连接PASS。A003维持已完成的静态方案，只同步本次测量边界。

### 下一连接：真实单行LN→Q→完整Wi，复用同步PS前端（2026-10-15）

回复 `m004-lnq-matrix-minimal-connection-design-20261015`。**只推荐一个方案：单请求固定FSM，真实LN→Q的一行直接供`tm4tn8_sync_ps_front_v2`的rows=1，完整Wi K1024/N5248，配现有W cache的一个活动槽和独立成功行暂存。** [前端源码][wi_front]第293–305行明确允许rows1/4及该形状；不复制一行充四行、不裁K/N，也不实例化旧matrix_resident/portal/owner链。保留现有160bit局部tag及issue/commit检查，由固定命令锁存身份和行号；这不是恢复动态Ref/owner调度。下述保留静态设计依据，实施合同已由A001在修订9确定。

**设计采纳及验收边界。** A001通过 `m004-lnq-wi-row-design-accepted-20261015`／`D-M004-LNQ-WI-ROW-CONNECTION-01` 采纳唯一方案，正式接口、验证及预算见[SM004修订9](../project/missions/SM004.md)。主控已核20份来源/产品及6个row0切片；这是设计采纳，尚非新连接功能PASS。固定cold先真实W LOAD完成再启动LNQ，warm保留同矩阵槽但仍真实匹配lease；每group一次LNQ读供656tile。front新增`abort_valid/ready`仅用于真实W读错/标签错，优先阻止同拍issue与launch；预留/同步读及已发FP真实排空，独立external_abort纳入done_error及同拍末完成，旧调用者显式接0，不修改expected_stripes。外层真实释放W/LNQ并确认债零后才发布20992B成功行或返回失败；结果同步tile读、单未消费响应、独立release及最终done按合同执行。

工程须核完整167936个提交PS及5248个final，并取得冷正常与无reset暖反压命令、warm零新增AR、有限错误/abort排空与恢复证据。保存LN/Q/W流仅作checker；若缺本行独立LN统计，修订9仅授权A002用原已核单行参考补三统计并逐位复核旧1024值，不授权本研究生成gold。A002唯一实现/工具owner，先结束修订8原预算测量再串行运行修订9；本连接阶段不做新联合OOC/P&R或全图前向。完整数据链功能、冷暖周期/资源、后继G/Down与完整固定图均待对应实证，现有四行算术/PS及双槽W物理容量不因rows1缩减。A003本次设计已收束，只据后续实测更新边界。

**同输入独立参考已定位。** [轻量身份记录][wi_binding]核既有[AT040夹具][wi_ln_fixture]的`gold_rows4.f32.bin`与[Wi四行夹具][wi_fixture]的`wi_rows4_source_f32.bin`全16384B逐字节相同，SHA `658b5a8d…`；其前LN源为AT040 `source_rows4.f32.bin`，完整SHA `5ad0bec6…`。推荐取batch0/row0的真实4096B前LN源，gamma0，经当前LN→Q硬件产生A；保存的LN/Q仅用于比较，不写入DUT作为producer。row0输入SHA `63bafc067c5ea179e47146472dbbf2f55cb5e8c8182015d59e5ab40424ce84b4`，LN输出SHA `8b4d49adf4ffc6287d3e47ca6d7e460b709886d5edab95e328b535f45acca8c7`。

既有Wi `steps_u32x6.bin`按`[row,group,column,6]`小端u32保存dot/sa/sw/scale乘积/term/提交PS，row0连续4030464B覆盖32×5248个lane-group；`output_f32.bin`的row0连续20992B覆盖完整5248列（SHA `64ada464630ef94ee07385a723dc3786bbaf105673f45603f12b77ad5b0a26a1`）。[原oracle/格式源码][wi_oracle]及`make_tm4_real_streams.py`说明这些来自独立参考，并由full_reference交叉比较；本次只校验现存字节/布局，没有运行oracle或生成gold。[旧AT049报告][wi_lnq2]亦保留同源四行LN→Q→Wi检查，但不代签新连接。P1 `wi_ln_rows1`只保存n0=0的8列linear/trace，且与所选v4 row0的前LN输入、LN和Q均不同；其32B final不能扩写为完整N gold。工程接点答复 `m004-lnq-matrix-contacts-static-answer-20261015` 的P1范围与此一致。

P1来源补充依据工程通信 `m004-lnq-matrix-gold-scope-clarification-20261015`：`dut.trace.bin`（3072B）和`dut.linear.bin`（32B）是历史`numeric_cli`软件输出；原报告的`oracle_exact`记录参考计算范围/字节统计与比较，case未另存`oracle.trace.bin`或`oracle.linear.bin`。它们独立于当前RTL，可作8列局部对照候选，但不称为另存的oracle二进制，文件存在也不证明新RTL逐group PS通过。该限定不改变上段另行核实的AT040→完整Wi同输入参考链；两套来源分别记录。

| 生命周期/端口 | 唯一所选连接及必须保留的条件 |
| --- | --- |
| LN→Q行与A暂存 | 复用`laya_lnq_row_v1`的1088B发布行。等待真实row_valid后对group0…31各做一次同步rd/rsp；rsp为256bit q＋16bit scale，最多一个未消费响应。锁存当前group的32B A与精确解码后4B sa，保持到该group的656个tile全部实际接受；不增加第二份整行A。保守地等matrix完成及所有A/W读债归零才发LNQ row_release，真实消费LNQ最终done后可复用其存储。 |
| 矩阵发射与PS | config K1024/N5248/rows1/row0=0；group外层0…31、tile内层0…655，sequence=g×656+t，lane_mask=ff，trace_mask=0。`issue_a8[255:0]`/`issue_sa[31:0]`承载真实row0，未启用三行填0；W为8×256bit、sw为8×32bit。只按issue_valid&&ready前进，受阻保持整包。现前端内部E0申请同步读/预留，E1复制，E2最早发射；每个活跃row有8个656×32bit PS bank及一个656×16bit metadata bank，均真实1R1W。group0逻辑取+0 PS，后续必须等同tile前group提交；保留busy/initialized/poison与Q35预留，禁止同bank同地址读写，不将BRAM视为任意多端口数组。 |
| 最终Wi行 | Wi manifest `bias_kind=0`，final为最后group已提交PS，无新增bias加法。`commit_valid[0]&&commit_ready[0]`按完整tag核row/group/tile/mask，g=31的656个有效tile写8bank×656×32bit＝20992B暂存；中间group也必须真实消费以更新PS。数值坏lane/poison/final_skip继续排空且禁止发布失败行。front done成功、完整最终覆盖、全部读/算术/响应债归零及A/W释放完成后才置Wi行可用；消费者按tile读取并释放后完成本行命令。该出口是本地完整Wi行，不声称AXI写回或G/整图已接通。 |
| 错误退出缺口 | 现front只有自身协议错误触发DRAIN，没有外部abort口；W read_error或外层取消不能只停issue等待永远到不了的20992条覆盖。须由工程加一个真实外部abort→DRAIN的薄接口，禁止同拍新接受，排空/丢弃其已预留队列并保留已发FP返回债，失败行不发布；不能伪造坏header、常量零债或靠局部reset清掉真实工作。W/A未消费响应仍要按协议退休，外部AXI在途reset须与总线共同安全复位或先排空。 |

所选front仍实例化四套行流水、32个PS bank和4个metadata bank；声明PS83968B、metadata5248B，不因rows1就声称物理面积缩为四分之一。单活动行逻辑PS20992B与新Wi成功行暂存20992B职责不同，不能重复占用同一PS端口。新结果暂存只需每bank每拍一次真实写，发布后才读；具体RAM映射、行服务II和联合资源均UNKNOWN。全Wi一行静态工作量为20992 stripes、167936次lane-group恢复/累加、5373952 MAC，不是实测cycle。

**精确恢复顺序。** A/W的FP16 scale按[现resident解码函数][wi_resident]保留±0、normal、subnormal及非有限位型；提取成至多10步的有界组合规范化并锁存解码结果，不用近似或把半精度尾数直接当F32。负非零/非有限scale仍走原数值错误规则。复用`tm4tn8_row_pipeline_v1`与[fp_restore][wi_restore]：signed GS32整数dot→F32(dot)，独立F32(sa×sw)，再F32(dot_f32×scale_product)，最后F32(oldPS＋term)，严格g升序、非FMA，不重排为dot×sa×sw或跨group树归约。原保存六字段逐group比较可区分这些错误；本次没有重新执行数值算法。

**W冷载与复用。** 采用[现有t4_dual_w_cache_v1][wi_cache]一个活动槽，固定FSM真实执行load→READY→本地lease→read→release，保留已有epoch/model/numeric/task及返回字段检查，不将lease成功绑常量；通用portal/owner不参与。cold LOAD读取既有Wi q0/q1各2686976B、scale335872B，合5709824B，512bit payload理论拍数41984/41984/5248，另计AUX header、AR/响应等待，不能把字节数当实测带宽。下层`t4_w_reader_port_v1`有64beat/4KiB分段；请求头/scale检查及实际提交覆盖完成才READY。计算按(g,t)请求`read_pair=0`、保持一个未消费W响应，与锁存A拼成issue；q的parity/地址为`(t&1, (t>>1)×32+g)`，scale按(t,g,lane)，不能拿保存w8 stream代替真实冷载。

首行冷载后，同一矩阵/同一模型的后继行可在release回READY后重新借用同槽，不重复LOAD；只有真实warm行无额外AR且完整结果一致才签跨窗口复用。当前dual cache仍声明两个槽及全部bank，不能把一个活动槽误写成物理只分配5709824B或整模常驻。工程指出旧`t4_dual_w_full_05`有Wi冷载54128cycle READY及10496双tile返回证据，但当前bank拆分版未同版验证；该旧速率不能迁移到本方案的单tile读序或新LNQ联合频率。

**必须补齐而未验证的工作：** 新v4前LN row0在当前LN→Q上的同输入回归；该行独立mean/variance/inverse保存物尚未确认；W cache当前bank版及本地lease薄适配、FP16有界解码、外部abort排空、最终行覆盖/发布、冷/暖命令与全部端点反压。上述受影响实现/验证已由修订9授权A002连续完成。已有完整PS/final gold可直接按row0切片核对，不需本准备生成新参考；同版联合资源/时序仍未知且不在修订9本连接段运行范围内。

[本次静态脚本](fixed_graph_support_20261014/check_lnq_matrix_binding_20261015.py)仅校验源码/既有产品SHA、行切片身份和整数容量式，CPU0–3/nice19/idle、timeout10s、AS≤1GiB；[采样](fixed_graph_support_20261014/lnq_matrix_binding_time_20261015.txt)墙钟0.12s、峰RSS31076KiB。交互阅读历史未统一采样，累计精确成本保持UNKNOWN；未运行EDA/模型/前向/新gold/新agent，沿本次≤60s/1GiB静态准备范围，不重审全图。

[wi_front]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_sync_ps_front_v2.sv
[wi_binding]: fixed_graph_support_20261014/lnq_matrix_binding_20261015.json
[wi_ln_fixture]: ../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT040_LNF0_ffn4_02/fixture/fixture.json
[wi_fixture]: ../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t2_widown_av_fixtures_01/work/fixtures/manifest.json
[wi_oracle]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/make_real_fixtures.py
[wi_lnq2]: ../project/E005_full_request_performance/experiment_results/runs/R001/reports/LNQ2_runtime_replay_result_20261014.md
[wi_resident]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_matrix_resident_v2.sv
[wi_restore]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_fp_restore_v1.sv
[wi_cache]: ../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv

[q131_path]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/work/timing_paths.rpt
[q131_src]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/frozen/quant16_stream_row.sv
[q131_tcl]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT131_SM004_lnq_partition_ooc_01/frozen/laya_lnq_row_v1_ooc.tcl
[q133_endpoints]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT133_SM004_lnq_dcp_target_timing_01/work/targeted_endpoints.tsv

本次[小脚本](fixed_graph_support_20261014/check_q_critical_path_partition.py)只解析第一条已有时序路径、计数231级并核4个源码与冻结副本；[采样记录](fixed_graph_support_20261014/q_critical_path_partition_time_20261015.txt)对应命令 `taskset -c 0-3 nice -n 19 ionice -c 3 timeout 10s prlimit --as=8589934592 -- /usr/bin/time -v -o source/fixed_graph_support_20261014/q_critical_path_partition_time_20261015.txt python3 source/fixed_graph_support_20261014/check_q_critical_path_partition.py`。内部耗时0.005715s、采样自身峰RSS16516KiB，沿原研究预算；未统一采样的历史读取累计仍UNKNOWN，无EDA/模型/gold或E002修改。

### 下一真实连接：Wi→canonical G→共享Q→共享Down（2026-10-15，修订10已采纳）

回复 `m004-wi-gqdown-next-connection-question-20261015`。**推荐在现固定行FSM内顺序增加G和Down：一套canonical G核心、一套原Q、一套原matrix/front、一套双槽W；复用20992B结果bank依次保存Wi、G和Down，Q行暂存由32组扩到82组。** 不把两个完整Wi/Down顶层并排实例化。工程[AT148–155交付](../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_wi_at148_at155_handoff_20261015.md)及当时静态范围保留，后续主控限定接纳如下。研究身份表捕获的工作树顶层SHA为`441fbe87…`，早于最新普通修复且不同于AT148交付`55e18053…`；该表保留原时点，不把工作树改动继承为AT148同版PASS，实现冻结由A002负责。

**采纳与当前执行范围。** 主控通过 `m004-wi-gqdown-design-accepted-20261015`／`D-M004-WI-GQDOWN-CONNECTION-01` 采纳本单一方案，执行真源为[SM004修订10](../project/missions/SM004.md)末节。A001已核研究56项文件/切片与关键字节关联，除已知Wi工作文件更新外其余匹配。新增payload约1764B仍是结构账，不是实测资源；成功终点为1024个Down F32，末残差及完整FFN/模型未包含。最终合同增加3bit `done_phase`区分LOAD_WI/LOAD_DOWN/LNQ_WI/WI/G/Q_DOWN/DOWN/RESULT，保留各阶段原错误位置，不拼造跨阶段全局序号。A002唯一实施，普通实现、编译、仿真及受影响修复在修订10预算连续执行；A003静态准备已接纳并收束，不追加研究或确认回信。

**修订9已接纳的准确边界。** 主控已核341项身份及6项fixture解码，接受AT148 `PASS_SCOPED_LNQ_WI_FULL_COLD_WARM`：冷暖各完整20992 PS/167936 lane-group及5248 final，含真实LN/Q、冷W及warm零新增W/AUX AR。AT148只测结果响应两拍保持、冷正序/暖倒序；链内主动反压、重复读/释放竞争、错误后完整暖行及顶层真实在途reset仍未证明。AT150只签W标签错排空及恢复前256 PS，AT151为冷RRESP排空，AT152/155为front局部，AT153/154为同输入LN统计。依据见[主控审核](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的`at148_at155_wi_stage_review`，本研究不重复审核或把局部覆盖升级。

**末组bad/poison修复仍待实证。** 主控确认原末组坏lane及合法poison导致的mask减少被local_fault错报协议7；工作修复SHA`33ec1486…`仅静态核对、尚NOT_RUN。合同要求坏tile记录真实commit覆盖但不写结果数据，`mask|bad`完整才能解释合法缺失lane，仍保持front数值6/原位置和真实协议优先；全部poison的final_skip按原数值失败处理，不能先用缺覆盖改报协议错。修复版不继承旧正常样本的错误PASS。half_to_f32与AT085原算法去空白一致，65536位型历史差分只按该算法身份复用。必要数值映射短测、Wi/G真实在途共同reset、错误后完整warm及有限反压已并入修订10新链验收，不先重跑整套旧Wi。

修订9原static693.750471s、RTL含pilot1781.479534s/1800s、host守卫0.824163s下界收束；AT149观察器缺口与成本保留。修订10新预算host300s/static1800s/RTL3600s，单次/RSS及其余约束以合同为准，旧账不转移；不增加OOC。AT138只属较小LNQ网表，WNS−1.408ns不能迁移为Wi或新整链的物理结论。

**实际复用与最少改口。** [本次身份/布局表](fixed_graph_support_20261014/wi_gqdown_binding_20261015.json)记录12份源码及保存参考SHA。`vector_and_ffn/rtl/geglu_canonical_core.sv`（`01f88f43…`）接口为`clk/reset/in_valid/in_x/in_g → commit_valid/data/status/failed`，无ready，固定506拍有效流水；其SHA等于既有row_bank功能包中的核心。`geglu_canonical_row_adapter.sv`的有序issued/returned、512credit、首错和整行屏障可复用，但不搬入其三份2624×32 U/G/gate bank、Context/Ref及外部writer ACK。本方案由Wi结果bank供operand，并直接捕获每个真实G返回；既有6整行/角例支持原核心，不证明新增bank切换已通过。

| 固定阶段 | 端口、存储与进入下一阶段的条件 |
| --- | --- |
| Wi→G | Wi的656个final tile全写完、front真实done/债零、W slot0释放、LNQ行release及最终done消费后，进入内部Wi成功屏障；中间Wi不对外发布。对`t=0..327`依次同步读tile`t`和`t+328`，各锁存256bit，再按lane0..7向G发`in_x=Wi[8t+l]`、`in_g=Wi[2624+8t+l]`；必须两个真实响应到齐才发。两寄存器共64B，当前pair发完才覆盖，无第二套U/G整行数组。 |
| G返回原位保存 | 顺序返回编号`i`写原结果bank的`bank=i%8,address=i/8`，只覆盖下半行；每bank至多1R1W，Wi阶段八bank同时写与G阶段单bank写互斥。覆盖安全依据是：该`i`的x和gate必须在发射前已读入pair寄存器，后续源读单调前进且上半行不改；须断言同bank同址读写不发生，不能假设BRAM具有任意端口。用原issued/returned/≤512credit及2624位有效覆盖计账，返回不可被Q反压；坏返回同拍停止新G发射，已发工作继续退休。全部2624返回成功、覆盖完整、源读及G债零后才将下半行视为有效G行。该端口改写与实际RAM映射尚未验证。 |
| G→Q | 将现`layernorm_engine/rtl/laya_lnq_row_v1.sv`扩为两个固定源模式：原LN1024模式，以及**已成功G行的2624标量直接量化模式**；后者不再做LN。共用其中SHA`bb47385d…`的`quant16_stream_row`及512bit pack，不添第二套Q。G bank同步读tile0..327，每tile顺序8词，复用pair寄存器作串行保持；按标量握手装16词再送一次half。Q设置`cfg_groups=82`，164half、half0/1、group0..81；原Q支持1..128组，32slot ring不扩容。 |
| Q成功A行 | Q暂存为q0/q1各82×128bit＋scale82×16bit，共2788B，较1088B新增1700B。读/响应group改7bit；标量计数至少12bit、half计数8bit、scale计数7bit，覆盖82组，禁止沿用`group[4:0]`或`half_sent[6:1]`截断。保留half1才写scale、Q错误跳组/排空与协议错提前done差异，数值错不得因缺组改报协议错。只有真实2624输入/164half/82scale、成功Q done、零pack/读/算术债及完整覆盖才发布内部A行。G存储读债排空且此A行成功后，原结果bank可交Down覆盖。 |
| Down→外部行 | 同一个`tm4tn8_sync_ps_front_v2`仅在旧阶段done及`config_ready/all_credits_free`时重配rows1/K2624/N1024，原PS有效位在真实config握手清除、首group取逻辑+0，payload不需reset。82组各读一次真实Q行并锁存A/sa供128tile，sequence=`g*128+t`，完整10496stripe/83968个lane-group；group必须保留7bit（含64..81）。最后g81的128tile覆盖原结果bank前4096B。`bias_kind=0`，保留GS32 dot→F32、sa×sw→dot×product→oldPS+term逐步F32/非FMA与FP16精确解码。全部成功、128tile完整覆盖、front/A/W/返回债零且真实释放Q行和W slot1后，才向外发布1024F32；tile读限0..127、单保持响应、release优先并等响应消费，最终done后才接下一命令。 |

上述复用只增加64B operand保持和1700B Q payload（另有计数、覆盖、模式及描述符），不新增G整行或Down结果整行。20992B原bank在各阶段依次改写，phase锁存且只有一个写入owner；G运算期间保留尚未消费的全部Wi源，不能提前开放Down写。canonical G算术本身仍是既有大流水，不因控制简单而声称资源小；四行matrix/PS和双槽W物理容量保持，联合fit/频率未知。实际改口集中于顶层两个W描述符/固定阶段、结果bank的内部读与G单lane写、LNQ的固定源模式/82组宽度；没有新资源池、portal或owner协议。

**W切换无并发抢占。** cold命令先按原真实AXI load路径串行装Wi到slot0、Down到slot1，再开始LN→Q→Wi；两份描述符各自锁定K/N、weight_key、AUX header、base/span及每槽epoch。现`t4_dual_w_cache_v1`有唯一loader/返回口，但两个槽各自保存shape/model/key/epoch；本方案任何时刻至多一份lease及一个W响应，故Wi释放并确认零读债后才借Down，不同时填/读同槽。Down q0/q1各1343488B、scale167936B，共2854912B（64B有效payload拍数20992/20992/2624，AUX另计）；两矩阵payload合8564736B，不代表实际物理分配或带宽。warm必须两个正确矩阵都READY并真实lease匹配，Wi与Down及AUX均无新增AR；slot1不能沿用slot0的epoch/shape/标签常量。失败/共同reset后无效槽不能冒充warm命中。所有bank/PS重配和Q模式切换都等旧命令真实退休，不用局部reset实现普通切换。

**数值与错误边界。** G保留原7次乘、2次加及canonical tanh：`a*x→(a*x)*x→1+…`，独立`c*x`再乘前项，tanh后`1+h`、`0.5*x`、两次乘得到G，十步均逐次F32；不换tanh或FMA。原`vector_full_compute.cpp::geglu_row`逐i先检查gate操作数，再GELU和最终乘；因此按有序返回锁存第一个失败i，`failed==10`映射2624+i，其余映射i，不能改为全Wi列号的全局min。G失败不启动Q；Q失败不配Down，部分Q/Down结果始终隐藏。W真实读错/返回标签错沿既有abort优先及真实FP/预留排空，错误状态只释放实际持有的lease/行；不扩大任意内部损坏可恢复的声明。

**同输入保存参考闭环。** 只读比较确认AT040前LN row0 `63bafc06…`→原LN/Wi参考链→Wi final `64ada464…`；后者与`vector_wi_reference_01`的真实捕获输入全20992B相等。该独立参考由原逐步binary32加乘及`libm.tanhf`生成，保存十步和G；其G全10496B又等于原Down source的row0，故以下不是混用P1或仅凭文件名关联。`t2_geglu_gate_quant_bridge_rtl_04/work/fixture`的wi/gate/q/scale文本解码与四行二进制全相等；q.mem每行256bit、byte0为组内lane0，scale.mem每行16bit。原manifest另记录exact-rational R0交叉比较，本次不执行该参考。

| row0参考（各从偏移0取） | 字节/布局 | SHA256 |
| --- | --- | --- |
| `vector_wi_reference_01/reference/gate_f32.bin` | 10496B；2624个little-endian F32 | `da67e093d00a1624307ae2718925d201b4795b47f53bd69a512fc9d1ebb39350` |
| 同目录`gelu_steps_u32x10.bin` | 104960B；[col,10] little-endian u32，最后字段为G | `858389ff96fc5d0b4bd45c75c1bbf199d4db7a2912e8b0bb76ee38803cc8770e` |
| `t2_widown_av_fixtures_01/work/fixtures/down_rows4_a8_q.bin` | 2624B；[82group,32] signed int8 | `22e338e45420ea9da712a47a56357417a6c769bb7bb71bd3e12f12c8b030edc5` |
| 同目录`down_rows4_a8_scale.bin` | 164B；82个little-endian FP16，与q分文件 | `0f4fa52af5c184f23fedb6b902b567971d4dda290af8a1244b1f7579c9d8abf8` |
| 同目录`down_rows4_steps_u32x6.bin` | 2015232B；[group82,col1024,6]，dot/sa/sw/product/term/PS | `62c85d32c1f6d615b5f40f01f0beeee7a47486c75e85fd31e00198a104df17b7` |
| 同目录`down_rows4_output_f32.bin` | 4096B；1024个F32，已核等于保存g81提交PS | `842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f` |

矩阵参考来自原`make_widown_v4_fixtures.py`的独立oracle及`full_reference`交叉比较，实际G source为同request3/generation1的v4捕获；保存参考不等于新RTL通过。以上完整路径、父文件SHA、来源manifest与行切片见[身份表](fixed_graph_support_20261014/wi_gqdown_binding_20261015.json)。可选未来残差也已只读绑定：AT050 `enc0_skip_rows4.f32.bin`全四行等于AT040前LN源，`enc0_down_rows4.f32.bin`等于此Down参考，独立末残差row0 SHA为`2166b4a0419649f2544f8bcb78fa8fe09d6abba492f46b1c7841e75856de94cb`。本方案出口只到Down，不接残差；以后接add必须保存/真实重读原skip（不能从已改写Wi/G bank恢复，也不能用夹具驱动）。

**关闭已有两项缺口的有限样本组（已纳入修订10，尚待实测）。** 保留原研究建议，具体执行按最终合同：用同一冻结新顶层依次执行①两个只到触发点的真实命令前缀，分别在Wi FP已发未返、G core已发未返时共同reset；触发必须绑定本次cmd接受和实际计数，不能沿用旧done/half标记。reset覆盖LN/Q/G/front/W及本地pack/bank有效位，AXI有债则模型共同reset或先真实排空；观察至少覆盖G的506拍和相关现有隔离窗口，无旧语义返回/发布/错误或假零债。②随后一次完整cold新命令作reset后的合法恢复，逐位核LN/Wi全部PS和final、2624 G/十步、82 Q/scale、Down全部83968提交PS及1024 final。③在已驻留两W的下一warm命令复现AT150型真实Wi W返回标签错，确认已有预留/算术债、abort排空/无发布/lease归还；**不reset**紧接一次带有限确定性反压的完整warm新命令，核所有阶段全量gold和两槽/AUX零新增AR，直到消费者release与最终done。最后这条完整恢复不能止于256个PS；它同时承担正常warm/跨Wi→Down切换/末端读取保持检查，避免另重跑同类完整行。新G/Q边界的首错、同拍模式切换或82组回绕若需定向刺激，只测受影响短例，不能以它们替代上述全链恢复；不扩展任意故障恢复。两个reset前缀和两条完整成功链都是待测范围，不从旧子模块reset或AT148正常warm推断已闭合。

本次[小脚本](fixed_graph_support_20261014/check_wi_gqdown_binding_20261015.py)仅读保存文件、SHA/字节/布局及整数容量；12项关联检查全成立，未import/执行oracle或浮点计算。初次及补充AT050原manifest校验两次[采样1](fixed_graph_support_20261014/wi_gqdown_binding_time_20261015.txt)/[采样2](fixed_graph_support_20261014/wi_gqdown_binding_time_20261015_02.txt)沿CPU0–3/nice19/idle、timeout20s/8GiB执行；历史未统一采样的交互读取仍UNKNOWN，不回填0。不改E002/工程记录，不运行EDA/前向/新gold，不新建agent；后续采纳更新仅读合同并维护本文，未重跑身份脚本或新增研究。

## Down＋原skip：完整FFN单行的最小静态连接（2026-10-15）

回复 `m004-down-residual-minimal-next-design-20261015`。**已采纳的唯一方案是在现有行FSM增加末端残差阶段：真实前LN输入握手保存4096B skip，Down成功退休后同步读skip/Down，送原32-credit精确ADD，按序覆盖原结果bank，全部成功才发布。** 不增加全FFN副本、AXI残差包装或算术候选。A001已限定接纳AT166真实冷暖LN→Q→Wi→G→Q→Down；AT168只支持Wi矩阵行流水入口接受2项/预留2项后的510拍共同reset隔离，真实FP IP发射未采样，不能称为Wi FP在途隔离。AT169支持G实际发2返0后的隔离，两者均不含完整cold恢复。此处按 `m004-residual-static-adoption-revision11-20261015` 更正，原日志、成本及已发送研究答复保留。

**修订11采纳与执行边界。** A001以 `D-M004-FFN-ROW-RESIDUAL-01` 采纳静态依据，[SM004修订11](../project/missions/SM004.md)和[实施决定](../results/m004_simplified_start_20261014/ffn_residual_connection_decision.md)已实际派发A002并连续实施；A003本轮研究收束，无新增实验或确认回信。主控[机读审核](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的`ffn_residual_connection_static_review.research_crosscheck`记录35项身份：33项一致，另两项为派发后改变的工作top/TB历史快照；AT166冻结输入、原ADD/参考及8项保存字节关联均成立。保留原时点快照，不刷新掩盖开发变化，不将AT166 PASS迁移给工作修改。64bit operand可复用已退休G保持寄存器，必须相位互斥；工程若已采用独立8B保持也在同一合同内，不需回退。4096B/8B及控制账不等于综合资源；原≤2060cycle估算对应两拍发射提案，不适用于AT173实际逐项退休调度。最新功能分项与运行终态见下段，完整图/联合物理/整模性能未验。

**AT173中间审核同步（2026-10-15）。** 按 `m004-at173-residual-schedule-scope-note-20261015` 和[集中审核](../results/m004_simplified_start_20261014/lnq_wi_stage_review.md)登记，机读来源为上述审核JSON的`revision11_at173_intermediate_scope_review`。A001已核AT170–173的379份冻结输入、44份原产物及10次guard政策/实际命令分类；AT173顶层SHA `92941815b70e58df6f6d27edb988e9d318abfe566dda5f588775480c00dcd463`，22份原夹具与AT166相同，新增残差解码等于AT050 row0 `2166b4a0…`。**整次运行仍为`FAIL_TB_AUX_STALL_COVERAGE_ZERO`，child1/trigger null/2131.186815s，缺最终`GQDOWN_COMBINED_PASS`；以下仅接纳Fatal前由有效断言覆盖的分项。** A003只同步主控审核，不重复冻结身份或工程回归。

- cmd51真实FP输入接受1、convert lane0返回0后共同reset，510拍所监测语义端点隔离；随后cmd52在G发2返0时reset并观察510拍。两个触发均无AXI在途；不外推全部FP lane/其他返回阶段。
- 两次reset序列后，cmd61完整cold从真实前LN输入经过LN/Wi/G/Q/Down与真实skip＋Down的1024残差，按原gold逐位核至消费者done。它证明该复位序列后的完整恢复，不是两个reset各自独立紧接完整cold。
- cmd62真实W返回标签错触发abort，真实排空/释放且无发布；随后无reset的cmd63完整warm到残差消费者done，全部原gold一致，两W及AUX零新增AR。这只签所测W-tag错误恢复，不代签数值bad/poison恢复。
- 成功行结果冷正序/暖倒序、重复tile0/127、两拍保持全部响应字段及release/read竞争均有实证。W AR阻塞和R空拍命中，但AUX AR受控停顿计数为0，仍未覆盖。

**实际调度及计量限制。** AT173采用`RES_READ→RES_SEND→RES_WAIT`，每项真实返回/消费后才开始下一项，最多1项在途；原ADD的32credit是叶子能力，不是该顶层测得并发度。没有cmd真实握手与残差尾部起止marker，`cycle=193469/324754`不作latency/II，不能给出已测尾部周期或沿用≤2060cycle上界。TB各口循环内对`ar_stalls/r_stalls`多次NBA同拍只加1，1163/33587是跨复位前缀/cold/warm的“至少一口条件成立”时钟总数，不是各口累加、单命令阻塞或带宽统计。不为这些指标重跑长前缀。

AUX AR保证命中的同DUT短探针由A002沿原合同执行，需分别报告入口、AR保持、实际接受、有限停顿计数及完成范围，不改AT173原FAIL。Wi/Down bad/poison、主动内部W返回/front issue/commit/ADD消费停顿、ADD在途reset及AXI在途reset仍按实际证据保留缺口；剩余短测按成本取舍，不新增预算。截止AT173实账static506.331534s/1800s、RTL3688.187977s/4800s，余1111.812023s，后续另扣；已包含AT170 pilot120.446267s、AT171 guard误停32.270439s、AT172旧SHA正常full1337.750995s。不重复完整正常基线，无新OOC/P&R；最终交付分列PASS/FAIL/NOT_RUN/COST_STOP，未获阶段全项验收。

**接口与存储生命周期。** 原静态核查时点的[身份表](fixed_graph_support_20261014/down_residual_binding_20261015.json)捕获[顶层](../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_lnq_wi_gqdown_row_v1.sv)SHA `3a749c8981e833b75a0645f92bb84546158551735758c35870847838010ddcf1`，当时与AT166冻结版相同；该记录不是开发后的当前SHA。该版没有skip保存口、残差调度或残差完成条件；`A_DONE`消费成功LNQ done后，Down分支直接进入`ROW`。修订11在此处分支进入残差，保留此前front真实done/完整末组覆盖、W release完成、Q行release及最终done的成功屏障；旧债必须真实归零。

| 连接点 | 原静态方案行为（AT173实际调度差异另列） |
| --- | --- |
| 入站skip | 新增`skip[0:1023]`、每词32bit。只在本命令`LN_WAIT && x_valid && x_ready`写下一元素，11bit计数表示0..1024；`x_ready=(state==LN_WAIT)&&ln_x_ready`，内部G→Q的`QD_SEND`不得写skip。保存原始F32位型，不能从LN/Wi/G结果重建。每命令清有效元数据，payload不需reset；失败行无效。 |
| 同步读与发射 | 原提案对i=0..1023，以`R_READ`同步读skip/Down、`R_SEND`保持至ADD握手后即读下一项，末项`R_DRAIN`。**AT173实际在SEND后进入WAIT，真实退休当前项后才读下一项，最多1项在途；不沿用提案两拍发射率。** 两份32bit保持可复用已退休G的`g_x_hold[31:0]`/`g_gate_hold[31:0]`，或按合同独立8B；4096B skip及控制账不等于资源测量。 |
| 原位写回 | ADD严格有序，按消费计数j写`final_bank[j%8][j/8]`，只使用现bank前128tile。每bank至多1R1W，matrix/G writer在此阶段禁止。写回只可能覆盖已读并接受的元素；读索引单调前进。需断言同bank同址读写不发生，不能假定任意RAM端口或未定义read-during-write行为。 |
| 发布/释放 | 原Down行隐藏。成功须skip完整、1024次ADD接受/消费/有效写回、全部索引覆盖、读请求/保持对为空、ADD未消费债零、无数值或协议错；再进入现`ROW`。保留128tile同步读、单响应保持、release优先新read/等旧响应消费、最终done后接新cmd。中途错误可留下不可见部分写回，下个命令完整重算。 |

**ADD lane实际合同及外层缺口。** [laya_vector_add_stream_v1](../project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_vector_add_stream_v1.sv) SHA `417c12d7b1c0717426419d7fe71056ef68f12f00039e0ee7c3234fa27698b494`、CE ADD叶子SHA `19ff024047daea86c0a10b27a464d3c27506e3dcb5990d3877fa68343a8422b7`仍匹配AT093原manifest。端口仅`in_valid/in_ready/a/b → out_valid/out_ready/bits`及clk/rst_n；内部32credit从接受保留至消费，6级valid/tag移位、32项结果RAM和ready_mask，输出阻塞保持。内部tag不向外暴露，也没有finite/error/debt端口，不能将内部存在tag写成外部校验已具备。AT093原4096真实AT050对/结果逐位通过、4103cycle正常/6444cycle受压、峰32及局部在途reset属于此lane，不是新整链验收。

外层用接受/消费两个11bit单调计数推导位置，不需第二份32项tag FIFO；`accepted-consumed`计入所有在流水和待消费结果，范围0..32，读待完成/持有未接受operand另记。相位互斥、无跨命令在途才能用此隐式tag；普通阶段切换不得reset消债。ADD返回可直接写bank，正常`out_ready=1`，若故意停顿则真实credit保留，不能按固定6拍猜已退休。

有限性与`vector_full_compute.cpp::add_row`一致：真实输入接受时检查a/b指数域是否255，真实结果消费时检查bits指数域；保持原F32舍入/次正规/有符号零规则。一次生成`next_first_bad=min(旧首错, 本拍输入坏index, 本拍结果坏index)`，不得用相互覆盖的两次NBA。较晚输入坏先被发现时仍排空此前已接受运算，以免遗漏较早输出溢出。发现坏后停止后续读/发射；同拍实际接受的工作仍入账，未接受保持对可取消，但已发同步读须完成并清本地valid，所有真实ADD结果继续消费。数值报6/原元素0..1023，真实计数/次序/覆盖协议故障仍优先报7；不发布部分行。共同reset清skip有效性、读/保持、计数/首错及ADD valid/ready/tag元数据，payload可不清；沿现整链reset及旧返回隔离，不把ADD局部reset证据外推为W/AXI或新整链恢复。

**同输入独立末残差已绑定。** 只读核AT050报告中四行产品SHA/字节，AT093原manifest也引用同一skip/Down/final三文件；AT166冻结source/LN/Wi/G/Down文本与既有二进制按8hex→little-endian32解码逐字节相等。AT050 skip四行等于AT040前LN source，Down四行等于既有独立矩阵Down参考；没有混入P1或运行新oracle。AT050 `ffn_residual_reference_report.json`的独立参考身份保留，本次只复核保存字节，不重新证明其算法。

| AT050保存文件的row0（父文件各16384B，偏移0取4096B） | row0 SHA256 |
| --- | --- |
| `enc0_skip_rows4.f32.bin`，1024 little-endian F32，等于AT166真实入站源 | `63bafc067c5ea179e47146472dbbf2f55cb5e8c8182015d59e5ab40424ce84b4` |
| `enc0_down_rows4.f32.bin`，同布局，等于AT166 Down checker | `842f711fb7b0f07d88b84b00c53f0a4804765ce95af54aa0badebfd2a0f5c94f` |
| `enc0_enc0_out_rows4.f32.bin`，同布局，独立末残差 | `2166b4a0419649f2544f8bcb78fa8fe09d6abba492f46b1c7841e75856de94cb` |

全路径、父文件SHA、AT166夹具及manifest、当时工作/冻结源码、原日志收据身份均在[最小依据表](fixed_graph_support_20261014/down_residual_binding_20261015.json)。新仿真中这些文件只能作checker；skip由真实入站握手产生，Down由真实计算bank产生。AT173已有上述完整数值/所测恢复分项，原静态依据表不回写成新运行证据；其余端口、故障与物理范围不据此扩大。

**phase最小扩展。** 将`done_phase[2:0]`改为`[3:0]`，原0..7语义不变，新增`4'd8=RESIDUAL`用于残差失败，完整成功仍`4'd7=RESULT`。静态核查时的[TB](../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_lnq_wi_gqdown_row_v1_tb.sv)有3bit声明、`dut(.*)`和`3'd7`检查，必须一并显式扩宽；新旧调用者的wire、比较常量、日志/序列化checker需逐个核，不允许8截为0而误报LOAD_WI。数值状态码及32bit bad_element无需扩展；未据此宣称生产Host ABI已改变。

**有限验证以修订11为准。** 下列保留合同范围，原已发送建议不回写；截至AT173完成与未测项以上述分项审核为准，不另跑重复的正常cold/warm：

1. 真实Wi FP窗口必须绑定本次cmd及实际`fp_restore.valid_a`驱动IP的接受边沿、发射/返回计数，至少一项已接受未返回后共同reset，不能以row_issue/reserved或AT168的旧“FP=2”标签代签。再测G实际已发未返reset，每次观察至少510拍隔离；如测AXI读在途，DUT与总线模型共同reset并限定合同。随后不再reset运行一条完整cold残差行，核原各阶段PS/final、skip握手保存及1024末残差，才签所测reset后的完整cold恢复。AT168仅行流水入口隔离、AT169仅G发2返0隔离的原范围保留。
2. 成功cold后保留两W槽，真实warm W-tag错误触发front abort，核实际预留/算术债、状态7/phase3、无发布和排空/lease释放；随后**无reset完整warm残差行到消费者done**，核全部独立值、两槽/AUX零新增AR。这条行同时承担正常warm与有限反压、重复/倒序读取及release/read竞争，不另跑无错warm基线。只在真实可反压接口停顿，不丢无ready的G/FP返回；各端点记录真实阻塞计数。
3. Wi/Down数值映射以有限受影响场景区分末组bad、较早poison导致合法mask<ff、全poison final_skip的数值6/原位置，与真实重复/非法tile或缺失lane无法由bad解释的协议7。保留valid/tag/debt，禁止强迫commit/done或清债；原gold不改，仅签所测控制覆盖。合同允许局部入口验证并按范围交付，不能据此声称完整数值错误恢复；完整warm恢复由上一项W-tag场景承担。
4. 新残差尾部的末元素错误、较晚坏输入与较早溢出竞争、32credit输出阻塞及ADD在途reset用小型尾部定向探针补；可引用原AT050/定向ADD样本作局部输入并明确局部控制范围，不把它冒充真实全链producer。全顶层ADD在途reset后完整cold不由该探针或上述FP/G窗口样本推得。

修订10已按static1113.567624s/RTL3459.293175s成本出口收束，余140.706825s不转移。修订11独立预算host300s/8GiB、static1800s/24GiB（单次600s）、RTL含pilot4800s/8GiB（单次2700s、全局1Mcycle、pilot120s计入），具体约束沿合同；A002连续完成普通实现/修复，不新增OOC/P&R/前向/gold/代理。本研究仅登记采纳与边界，不启动新工具实验。

**历史估算与成本边界。** 原两状态读/发提案在无阻塞、一拍同步读、原6-edge lane条件下，每2拍接受一对，1024对需2048拍，加流水尾/屏障曾估≤2060cycle。**该数仅为未采用调度的历史结构估算，不适用于AT173的READ→SEND→WAIT，也不是当前尾部上界或实测值。** 原AT166日志绝对`row_valid`区间为177546..178315和290907..291676，`CMD_PASS`为178317/291678，间差113361包含命令间隙；未锁存真实cmd接受周期，不能称请求延迟或II。AT166整次cold+warm守卫1261.580029s、AT168 Wi reset前缀203.568609s、AT169 G reset前缀521.349162s；旧完整cold+warm加G前缀约1782.929191s仅作原预算依据，不是新运行上界。修订10 static1113.567624s/RTL3459.293175s及余140.706825s已封账不转移，AT173新账单列于上。新顶层联合资源、RAM映射、Fmax/P&R均未知，AT138较小LNQ时序不迁移。

本次[身份脚本](fixed_graph_support_20261014/check_down_residual_binding_20261015.py)只核保存SHA/字节/整数布局和日志计数，8项关联成立；CPU0–3/nice19/idle、timeout20s、地址空间1GiB下[实际采样](fixed_graph_support_20261014/down_residual_binding_time_20261015.txt)墙钟0.06s、CPU0.06s、峰17204KiB、exit0。交互读取未统一采样仍UNKNOWN，不回填0。A002独占RTL/TB，本轮仅研究依据/状态更新；未运行EDA、oracle、模型前向或新gold，未新增代理。

## 真实入口Embedding LN→Q→Encoder0 QKV：单一复用方案（2026-10-15）

回复 `m004-embedding-qkv-minimal-next-design-20261015` 的静态交付已获A001采纳；当前执行依据为[修订12正式决定](../results/m004_simplified_start_20261014/embedding_qkv_connection_decision.md) `D-M004-EMBEDDING-QKV-ROW-01`及[SM004修订12](../project/missions/SM004.md)。**同一FSM新增Embedding-QKV行模式，复用一套LN/Q、matrix/front、双槽W和结果bank，保留FFN分支。** 从同一B1/S128请求的CPU原始embedding行及真实gamma流开始，FPGA计算LN→Q→完整K1024/N3072，交付真实QKV及对应embedding_norm。实施已送达A002（消息 `m004-embedding-qkv-row-revision12-dispatch-20261015`，recipient turn `01a13d07-c808-7030-bedc-21a1632b7610`）；截至该决定，新mode/norm接口及真实QKV连接均 **NOT_RUN**，送达不等于完成。A002独占RTL/TB，本研究静态准备已收束。

**采纳与旧阶段边界。** A001核78条文件/窗口身份、10对工作时点/AT173源码及17项字节/整数布局条件，详见[审核证据](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)的 `revision12_embedding_qkv_static_review`；本研究原16项检查、脚本、依据表及已发送答复保持原样。前4行scatter第四字段是row-local `r`，A001已更正其初始期望恒0的checker，原数据未改。修订11最终static约1142.970s、RTL约4724.408s，余75.592s封存、不转移；AT173整次FAIL及接纳的FFN分项保留，AT174/175只覆盖收发至LOAD_DONE，不能外推完整FFN恢复。Wi/Down bad/poison仍未闭合。

**真实图顺序。** [完整独立参考](../project/E002_Laya_HLS/experiment/tests/full_reference.py)的`full_forward_graph`先解码token embedding，保存`embedding_raw`；用`emb_norm_w`的1024个F32作gamma完成embedding LN；Encoder layer0直接使用这个hidden，只有layer>0才另做attention LN。`q8_linear("qkv.0.weight",source,3072)`无bias；不能接Decision的`head_qkv.0.bias`。当前[控制器](../project/E002_Laya_HLS/experiment/hls/control/full_forward_controller.cpp)的`frontend_cpu→frontend_from_hidden`及`PC_ENCODER_NORM_ATTN/PC_ENCODER_QKV`与之相符。CPU raw importer从STATE0按`batch*kBatchStride+row*kRowStride+col*4`取值，本次B1 row0..127的前524288B已与独立raw全字节匹配。CPU可继续负责token embedding和权重/输入准备，LN结果、Q或矩阵结果不能由CPU/保存夹具代算。

逻辑输出列`n=plane*1024+head*64+d`，plane0/1/2分别Q/K/V，head0..15、d0..63；不是Q0/K0/V0交错。Encoder0使用full RoPE表，Q/K每head前后32维配对旋转，V不变；随后full、非因果Attention对每query使用完整S128的K/V及真实mask。此处QKV是RoPE前的raw，不是`QKV_FINAL`。

**固定模式与实际RTL缺口。** 本次[身份表](fixed_graph_support_20261014/embedding_qkv_binding_20261015.json)记录核查时点的工作top、LNQ、LN、Q、front、row pipeline、FP restore、W cache、G、ADD共10份与AT173冻结文件相同（ADD在冻结包名`ln_add_stream.sv`）。这是历史快照，后续开发不回写；仅支持保留未改叶子的原证据，不能预签新增模式或修改后的top通过。

| 接点 | 修订12定案及待验证接点 |
| --- | --- |
| 命令/输入 | `laya_lnq_wi_gqdown_row_v1`新增`cmd_mode`1bit（0=FFN，1=EMB_QKV）及`cmd_row[6:0]`，命令握手锁存；`result_mode/result_row[6:0]`回显已接受命令并保持至最终done握手。旧caller显式接mode0/row0及新输出。本修订FFN非0行在启动服务前按协议7拒绝；QKV的task_context须已有rows=1、row0=cmd_row，不符则拒绝，不改写身份。QKV使用`source_direct=0,gamma_kind=1`，每行真实接收1024原始x与1024 gamma，LNQ cmd_row和front config_row0传真实行号。 |
| 阶段码 | 保留`done_phase[3:0]`与FFN0..8；新增9=QKV_LOAD、10=EMB_LNQ、11=QKV_MATRIX（含lease、算术、drain及释放失败）。成功及命令/结果协议阶段仍7=RESULT。数值状态6、协议/传输状态7及首错规则保持；不宣称生产Host ABI已接通。 |
| gamma来源 | 现/旧v4模型`aux.bin[128:4224]`为真实`emb_norm_w`，4096B；W cache的AUX header仅前128B，不会自动提供gamma。最小入口沿已有标量gamma流从该权重窗口供数，每行按真实ready握手；不假定现LN有跨命令gamma有效缓存。未来AXI gamma装载/Host→设备传输另取证，当前不称已接通该搬运。 |
| Q/矩阵 | 复用`laya_lnq_row_v1`的LN1024/32group模式，Q本体和已有82组容量不改；32组每组仅读一次真实Q行并保持A256bit/sa。现`tm4tn8_sync_ps_front_v2`明确支持rows1/K1024/N3072和row0+rows≤128，配置握手清旧PS有效元数据，group0的PS按原逻辑+0。每g遍历384tile，sequence=g*384+t；共12288stripe、98304个有效lane-group PS。仍按精确FP16解码、signed dot→F32、sa×sw→dot×product→oldPS+term非FMA顺序，无bias。现top的Wi/Down二选一shape、expected_stripes、last_tile/group、最后覆盖及读范围均须增加QKV固定分支。 |
| W双槽 | QKV模式只真实cold LOAD slot0，key按原编码`family \| (layer<<8)=16'h0001`，K1024/N3072/bias0；q0/q1各1572864B、scale196608B，总3342336B，64B payload拍数24576/24576/3072，AUX header另计。W cache原容量/合法shape允许该配置，仍核epoch、model/numeric/task、真实lease/read/release及标签。warm下一QKV行保留slot0 READY、再次真实lease、无新增W/AUX AR；slot1不加载，unused Down描述符/epoch无需非零。两槽不能同时常驻QKV+Wi+Down三矩阵。转回FFN时在无reader/返回债条件下按cold合同重载Wi/Down并使用合规新epoch，QKV READY不能冒充Wi warm命中。 |
| 前缀结束 | QKV成功时在原`A_DONE`前置屏障（matrix真实done、A/W响应和算术债零、W release、Q row_release/最终done）之后直接进入QKV结果行；不进入G/Down/残差。FFN分支和其原skip/ADD行为保留。错误先保留原数值/协议优先及位置，坏行不发布；不能因Q数值错缺组或poison合法缺lane改报协议错。 |

**保留正确的attention残差源而不加整行RAM。** `hidden=embedding_norm`还是后续`hidden+projected`的原skip，原始embedding不能替代。定案在`laya_lnq_row_v1`新增`norm_valid/norm_index[9:0]/norm_bits[31:0]`观察口，严格来自非direct模式真实`ln_out_valid&&ln_out_ready`消费事件；无norm_ready，不改变LN→Q反压，direct G→Q不发事件。错误drain仍可出现真实消费，不能把事件等同LN成功。父层检查阶段、顺序/地址和1024覆盖（计数至少11bit），共同reset清新增有效状态。QKV模式在同一LN→pack握手写`final_bank[index%8][384+index/8]`，占tile384..511的4096B；matrix只写tile0..383的12288B。合计16384B/512tile，装入原8×656×32bit（20992B）bank；这是payload容量关系，不是综合资源。写口与matrix阶段互斥，每bank最多1R1W，失败/drop时整行无效，数值失败先于覆盖不足判断。该接口及bank改写待实施验证。

QKV模式结果读沿现10bit tile/256bit同步响应：0..383为Q/K/V，每plane128tile；384..511为embedding_norm，原FFN仍只读0..127。一拍同步8bank读、最多一份未消费响应，标签/全部数据受阻保持，release优先新read并等待读/旧响应消费。发布条件为LN/Q成功、norm保存1024项完整、QKV最后g31的384tile/3072结果覆盖、各阶段真实退休；局部错误不发布任一部分。命令行号/mode需随结果保持，旧行释放及done消费前禁止新命令覆写。现top没有这512tile布局/完整norm计数；不能把旧128tile读测试代签新布局。

**外部scratch与S128依赖。** 此轮可开始实施的真实边界是`CPU raw/gamma输入 → FPGA LN输出同时保存与打包Q → 真实冷W/共享matrix → 同步QKV＋norm结果行读取/释放`。局部同步消费者可逐位检查这一边界；尚不是RoPE/Attention消费者。下一完整S128调度必须将每行真正写到设备scratch并在实际写响应完成后释放本地行，不能把CPU保存QKV或旧capture当硬件producer。推荐沿原生产head-parity布局：shard=`head&1`，local_head=`head>>1`，byte offset=`((((plane*2+b)*8+local_head)*1024+s)*64+d)*4`。已有`scatter_u32x4`记录逐项匹配该公式。它使用QKV0/QKV1各12MiB的既有容量/stride；B1/S128实际QKV payload为1572864B，embedding_norm另524288B留HIDDEN scratch，不能把有效payload说成BO分配量。

目前该新行顶层没有QKV/norm scratch AXI writer、写响应债或tensor级覆盖/发布，不能直接借旧writer名字宣称适配完成。未来薄writer须按上述地址真实写入，RoPE对Q/K原位或另区改写后分别记录RAW/FINAL覆盖；norm保留至attention投影残差消费。RoPE各行独立，但一个query的full Attention依赖全部128个K/V位置及mask，不能只算row0或缩S为1/4；现Attention服务为命令化`command/index/payload/epoch`接口、内部每head K/V全序列及query tile同步bank，不直接接受本256bit行响应。行scatter、RoPE及其cache装载适配/完整覆盖均为下一接点，不能据单行QKV闭合Attention或Encoder。

**同请求保存参考与身份。** 16项只读字节/布局检查成立，未运行参考。主样本使用AT091的B1_from_b0_S128、request3/generation1；其CPU `state0.bin`前524288B等于保存独立`embedding_raw`，QKV fixture的source父文件等于AT091所核`embedding_norm`。原`task2_real_fixture_20/work/fixtures`由`make_real_fixtures.py`用冻结GGUF/独立逐group算术产生，并与`full_reference.q8_linear_full`交叉比较；保存完整N3072的row0及前4行Q/scale、六字段和final。原generator/reference源码仍按manifest匹配，本轮只读，不重新执行。v4请求wire SHA `fe82a8ef…`与AT091现生产wire `87fc82b1…`不同，build/package身份分别保留；所取gamma和三份W窗口与保存独立fixture逐字节相同，不能把载荷相同写成全部ABI身份相同。

| 已保存row0数据/窗口 | 布局与字节 | SHA256 |
| --- | --- | --- |
| AT091同源原始embedding | 1024 little-endian F32，4096B | `222e2a570181926ee5c49d1cff452f81e07fd9e712174e7e57914a90e7134a66` |
| `emb_norm_w`（v4/现包aux偏移128） | 1024 little-endian F32，4096B | `dfb0f4aaaedeb189d0698f68603641bf325c60b9857ecb19a5f9fe4f9df0aa2d` |
| 独立embedding_norm/矩阵source | 1024 little-endian F32，4096B | `f166773b57757ff552823c69315b133ea715b9c49f141849cc925b62c37b6d12` |
| `qkv_row1_a8_q.bin` | [g32,lane32] signed int8，1024B | `05a0ae7456eebb855756bf5d9d0635dd32ed876528891cdf47419993bb85ad3a` |
| `qkv_row1_a8_scale.bin` | 32个little-endian FP16，64B | `5d64c61efdba3085ef150f58cf428f31db84f356342a5021fc2d353f5212f6ae` |
| QKV W q0/q1（模型偏移均0） | 每片1572864B；tile奇偶分片，每local_tile依[g32,lane8,k32] | `95280fe3a0ed17eb48cc85f1725f4d5be81ce6dd1147c34d065b66b5facdbe53` / `68d92d7f3ef12387fb81f2fe082ec4b6ceb065156676807c5120931addf74e99` |
| W scale（模型偏移0） | [tile384,g32,lane8] little-endian FP16，196608B | `ee8e6cfbccbc754fd5b1db56d67b6b449968150cefbba4ab07c5d7f6015660a8` |
| `qkv_row1_steps_u32x6.bin` | [g32,col3072,6] LE u32：dot/sa/sw/product/term/PS，2359296B | `0e029825fc0d04a023cc260371c37c75c25e5780f3210c2c7746aa328185076c` |
| `qkv_row1_output_f32.bin` | Q/K/V plane顺序3072个LE F32，12288B；等于保存g31 PS | `d4d1b006b7d46e84fc13c431cd781b930d871149382a68a37cd81377ad7aee1b` |

权重q0/q1/scale仅做整数重排恢复为[n3072,g32,scale2+q32]，其SHA `83723a85bf4b54a5399d4452c64eb446246f7d7af04d48bbc3e9d81314564dfe`与原qkv.0.weight声明一致；无浮点重算。全路径、父文件/窗口身份、row1切片、当前/冻结源码、request与P1对照见[依据表](fixed_graph_support_20261014/embedding_qkv_binding_20261015.json)。AT091大W BO仅复核本次窗口，整BO SHA作为其原preflight声明保留，未冒称本轮重新hash整包。

P1的`qkv_ln_rows1`不能按请求名直接并入v4，但本次实核其row0 input、gamma、LN与上述row0相同，32×34B Q8解码的q/scale也相同；因此其已独立核验LN三统计可作为**同位型row0的历史检查依据**。P1目录/原oracle比较身份仍保留，不能把其8列线性结果或其它行扩成新QKV全N。前4行完整QKV参考已足够支持两个不同token行的有限连接验证；AT091的47 checkpoint未单独保存QKV，本次未定位到该请求全部128行独立QKV逐group/final参考，不能称S128 QKV gold已闭合，更不新生成数据补空白。

**修订12验证范围与成本。** 先短测mode/row锁存与task一致、FFN非0行拒绝、QKV unused Down字段、norm真实消费/direct无事件、gamma停顿、4bit phase及读边界127/128/383/384/511/512。正式场景在同一个真实runtime依次完成：row0 QKV cold→完整512tile消费/释放/done→同请求row1 QKV warm→完整512tile消费/释放/done→QKV驻留时错误FFN warm身份拒绝→无reset、新epoch冷载Wi/Down并完成原FFN末残差/消费者done。错误身份须在matrix issue前拒绝、真实排空且零发布。这是**三条完整成功行和一条错误身份路径**；若成本需拆runtime，必须重建真实冷暖前置状态并保留跨mode覆盖缺口。

两条QKV行均保持K1024/N3072、group32及完整3072输出，各核98304 lane-group PS六字段；总24576stripe/196608 PS、6144 QKV final及2048 norm，warm核W/AUX零新增AR。`qkv_row1_*`表示一行case的token row0，实际token row1取`qkv_rows4_*`第二切片（原raw SHA `e5344461…`、final `18079bd9…`）。合并保证命中的W/AUX AR有限阻塞和字段保持、R空拍、输入/gamma及响应反压、重复/倒序读、release/read竞争，逐端点记录实际计数；真实cmd握手及阶段起止计量，所有断言完成后才给最终PASS。仅保存输入/权重作真实外部源，中间LN/Q/PS来自DUT；上述行样本不签全部S128或Attention。

现有可引用测量：AT130同位型P1 gamma1到LNQ row_valid 11087cycle（含42拍Q阻塞，旧LNQ包装）；原`t2_tm4_real_qkv_lut_full_01`四行预量化QKV流12288stripe/393216 PS、最后row0 commit绝对cycle12324、guard408.346306s。后者不含真实LN、冷W或当前外层调度，不能移作本段latency。AT173整次复位前缀/cold/错误/warm2131.186815s包含G/Down/逐项ADD及末端覆盖FAIL，也不能按QKV/Wi列比直接缩放。QKV每行stripe及W字节为Wi的3072/5248=24/41，只是工作量关系；新单行QKV首尾/冷暖周期和工具墙钟未知，需由同版有界pilot实际进展估算，冷LOAD样本不足以预测matrix阶段。全S128为1572864stripe/12582912 lane-group PS，尚无同口径整段测量。原ADD仍READ→SEND→WAIT最多1项，≤2060cycle不适用；QKV模式不走ADD，跨mode FFN回归仍包含此尾部。

修订12独立预算：host累计300s/8GiB；static累计1800s/24GiB、单次600s；RTL含pilot累计3600s/8GiB、单次1800s且全局1Mcycle，pilot≤120s计入。三条成功行及一条错误路径是计划工作量，3600s是成本帽，不是已证可完成时间。保持单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB；普通实现/修复在帽内连续执行，无逐步批准。无OOC/P&R、前向、新gold或新代理，旧预算不转移。

FFN数值bad/poison不作为本段启动前置，也不再靠冷LOAD等待末group：仅在预算内、无需改变生产数据路径的低成本真实局部事务入口补测，否则保留NOT_RUN。可用原row-pipeline/poison及顶层末commit判定接点、真实接受的有限tag/data与保存前组PS或明确局部初值，区分末坏、合法mask|bad、全poison final_skip及无bad解释的缺失lane/重复tile。必须由同一生产逻辑接受事务，不能另写TB判断替身；保留valid/ready、首错与返回债，不能force FSM/计数/valid/debt/done。未完成完整front期望stripe覆盖时只签所测局部映射，不报完整front done或FFN恢复PASS。原完整shape/gold不改；未变叶子仅按原身份复用，共享顶层/读口/mode必须受影响回归，主场景PASS后不得未经回归再改共享RTL。

本轮沿research-agent职责只写研究来源。[检查脚本](fixed_graph_support_20261014/check_embedding_qkv_binding_20261015.py)及[发现采样](fixed_graph_support_20261014/embedding_qkv_discovery_time_20261015.txt)、[身份采样1](fixed_graph_support_20261014/embedding_qkv_binding_time_20261015.txt)/[补充采样2](fixed_graph_support_20261014/embedding_qkv_binding_time_20261015_02.txt)记录CPU0–3/nice19/idle、timeout≤20s/1GiB，原实际墙钟0.04+0.31+0.29=0.64s、峰40560KiB；交互读取累计未采样仍UNKNOWN。本次采纳同步未重跑身份检查或实验，不改E002、原脚本、依据表或已发送答复。新mode/norm/QKV连接及跨mode回归仍NOT_RUN；S128 scratch writer/写响应债、RoPE/Attention、完整模型、生产Host/HBM和联合资源/Fmax均待实证。

## QKV＋norm行到设备scratch：共享单拍writer的最小连接（2026-10-15）

回复 `m004-qkv-norm-scratch-minimal-next-design-20261015` 的研究方案已获A001采纳，正式执行依据为[决定D-M004-QKV-SCRATCH-ROW-01](../results/m004_simplified_start_20261014/qkv_scratch_connection_decision.md)及[SM004修订13](../project/missions/SM004.md)。**单计算top外接固定薄消费者，独占QKV模式结果读口，复用一个`tm1tn8_axi512_writer`按48个head＋1个norm地址段写QKV0/QKV1/STATE1 HIDDEN；全部真实B退休后释放本地行，再消费原top done并返回写回终态。** FFN模式仍走原结果读/释放路径，共用同一个计算top，scratch写VALID为0；QKV模式外部行读/响应/释放口均屏蔽。原160B writer payload保持，不加整行RAM或第二计算链。A002独占实现并按合同连续推进；研究交付已收束，新writer/rearm/包装层/tensor动态结果及完整跨mode均 **NOT_RUN**，派发不是验证通过。

**主控采纳依据。** A001独立复核52条身份和20项byte/整数布局条件、7份工作时点/AT192/194源码及writer109来源，并核全128行32768个域内beat的边界/唯一性；见[主控证据](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)字段`revision13_qkv_scratch_static_review`。本研究原22项检查、52项文件/窗口、脚本/计量与已送答复保留原样；主控全128静态枚举不等于128行真实生产或tensor动态PASS。本次仅同步采纳，不重复hash、枚举或实验。

**修订12实证与身份。** AT193同runtime row0 cold/row1 warm各norm1024、Q/scale32组、12288条8lane提交及3072 final已限定接纳，warm零新增W/AUX AR；其后首次slot1错误epoch3使整次FAIL，不能改写为整体PASS。AT195以真实QKV row0建立前置，Wi slot0 epoch2/Down slot1 epoch1冷载成功，Wi/G全量及Down issue9542/commit9530后超时，完整Down/ADD/最终发布未到。新[静态依据表](fixed_graph_support_20261014/qkv_norm_scratch_binding_20261015.json)核当前top `54fe628fac0d1a9dd4c61455c45e55eb3abe499034d7bb23157b9ac8d4b8bf78`、LNQ `cd35f5a620c8720917ffbc2481e3581b819e13d699c4214a0505321cace0371e`及Q/front/row-pipeline/FP-restore/W-cache共7份，与AT192/194冻结逐字相同；AT193/195运行manifest确实指向这两个编译manifest。上述叶子/数值范围可按原身份复用，但薄适配器的消费时序、外部写响应、模式切换必须新验。上一小节的NOT_RUN是修订12派发时点，现以本段实证范围更新，不覆盖历史记录。

**真实可复用writer及必要小改。** [tm1tn8_axi512_writer](../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm1tn8_axi512_writer.sv)现SHA `1606920748ffbbdbd8f9197b24b8a783d890dedaf394e7d6401f4f8bb551a448`与原`task2_writer_q35_current_109/input_manifest.json`一致，原日志/guard身份亦匹配。原九例PASS仅覆盖该叶子的相邻tile组拍、head/plane跳变、4B偏移跨beat/页边界、AW/W先后、长B等待及错误B排债；不代签此次适配器。其`address_decode`、`transfer_pack`、`b_fire/b_error`及`writer_registers`已有真实AW/W独立接受位和不可变TX，`debt_zero=!held_valid&&!pack_valid&&!tx_valid`。`flush_done`只在成功且三者全空时脉冲，flush请求须降下后才能开始下一段；错误分支清未发held/pack而保留TX至真实B，fault保持到reset。

最小复用选择保留该叶子的held32B＋pack64B＋TX64B及原握手，共**160B payload**；现行top已有32B `rsp_bits`，适配器不再复制整行或另加response FIFO。两个256bit响应合成一个64B beat是完整WSTRB的最低数据保持需求，但本方案保留已验的pack/TX隔离，不把理论64B说成所选实现容量。新增控制包括单个读预约/期望tile、段号、路由/基址、完成计数和错误锁存；资源映射未知。定案新增`rearm_valid/rearm_ready`，ready仅当`rst_n && debt_zero && !tile_valid && !flush_req`；真实握手同步清上一命令fault、flush状态及计数，reset最高优先。包装层仅在上一outer done消费、core空闲且无读债后发出，每个新QKV行一次，段间flush不清行计数。不得通过rearm清未退休TX。旧调用者显式接rearm_valid=0及unused ready，含ACT production、writer bridge与原TB，冻结历史不改；补口后的叶子是新身份，需受影响短回归，不能沿旧109直接签新版PASS。

[tm4tn8_axi512_writer_v1](../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_axi512_writer_v1.sv)和[gate writer](../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/geglu_gate_window_writer_v2.sv)分别绑定完整owner packet/shape与GATE标量窗口，均不是现行256bit结果口的直接连接。本方案不引入它们的控制链。[现行向量AXI服务](../project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_vector_residual_axi_v1.sv)与AT101修正版冻结相同，其`next_chunk`按三个端口页尾取min、最多64beat，已不同于AT097越4KiB版本；但它绑定双源读/ADD，不作本段writer。本段固定`AWLEN=0/AWSIZE=6/INCR/WLAST=1`，以64B对齐逐拍写自然满足4KiB，不引用AT097速度或跨界代码。

**一个writer的地址段与路由。** writer固定`mode_qkv=0`，用其线性`output_base+tile_n0*4`路径；QKV scatter在薄适配器用整数索引给出。按plane0..2、head0..15顺序，每head读取原bank连续8个tile（64个F32），writer的`tile_n0=0,8,…,56`、`tile_lanes=8`、段span=256B；段末在第8个响应真实交付之后才flush。48个head段后，读tile384..511的norm，`tile_n0=0,8,…,1016`、span=4096B，末响应后flush。等待`flush_done`且债零、撤下flush并确认恢复ready后才改段基址/路由，保证尚未解码的held不能看到下一基址。

只保留一个TX engine。三写口固定0=QKV0、1=QKV1、2=STATE1 HIDDEN，外层以锁存dst_sel路由同一AW/W和B/ready；非选中口AWVALID/WVALID/BREADY为0，不能OR各口B。目的/段基址保持到held/pack/TX全空、成功flush及请求撤下，不能仅等AW/W握手；flush_done脉冲须在该沿记录或推进。全局最多一笔物理TX在途。三个目的属于不同物理BO域，数值相同base合法，不能误判跨域重叠。互连/地址域实际接线仍待验证，仿真memory slave不是板上HBM证据。

固定B1/S128，`b=0,s=cmd_row`，`p=plane,h=head,d=0..63`：

| 目的 | 行内地址（byte） | 每行有效数据 | 本方案正常每行AW/W/B |
| --- | --- | ---: | ---: |
| QKV[h&1] | `base[h&1]+((((p*2+b)*8+h/2)*1024+s)*64+d)*4` | 每shard24个head段×256B=6144B | 每shard96/96/96，单拍 |
| HIDDEN norm | `hidden_base+(b*1024+s)*4096+i*4`，i0..1023 | 4096B | 64/64/64，单拍 |
| 合计 | 48个QKV段＋1个norm段 | 16384B，512个256bit响应 | 256/256/256；49次flush屏障 |

此处QKV三plane仍为**pre-RoPE RAW**，V不旋转，Q/K尚待RoPE；norm是真实embedding_norm、后续attention skip。沿[生产memory map](../project/E002_Laya_HLS/experiment/hls/common/laya_memory_map.cpp)保留QKV0/QKV1各12MiB的BO布局，HIDDEN独立8MiB区域、row stride4096B/batch stride4MiB；原CPU raw位于STATE0时，按控制器`PC_NORM_EMB`的另一bank规则把norm写STATE1的HIDDEN区域（offset0），不能写成NORM区或覆盖仍在用的raw。B1/S128有效字节仅QKV每shard786432B、norm524288B，共2097152B；不是把BO缩成这些大小。QKV稀疏布局至s127最大exclusive offset为10256384B，仍小于12582912B；row0/1末exclusive offset分别10223872/10224128B，不能用6144B连写代替scatter。

命令预检按正式固定分配要求QKV两span各至少12MiB、STATE1 HIDDEN span至少8MiB，三个base均64B对齐，base+span/所需区域用至少65bit核无溢出；首次命令即核全tensor范围，逐段/逐beat仍核完整64B包含。raw源声明固定STATE0，新增`cmd_source_hidden_bank`必须0；同域才比较地址重叠，不能用纯数值地址拒绝不同BO域。QKV每head256B可跨页，但每个64B TX不跨4KiB，norm4096B段亦逐拍分开。短span、错域/旧目标未释放均拒绝；只核有效字节或旧writer的4B对齐/逐lane范围不足以代替完整BO检查。真实Host/设备域隔离仍待证。

**读保持、物理债与一次完成。** 包装层接受cmd时锁存mode/row/id及原request/generation、model/numeric/task与三目标身份；活动期间外部变化无效，校验core的result_mode/result_row。新增QKV字段为`cmd_tensor_begin`、`cmd_tensor_epoch[31:0]`、`cmd_dst_epoch[2:0][31:0]`、`cmd_dst_base/span[2:0][63:0]`和`cmd_source_hidden_bank`，FFN忽略且不改tensor状态。B=1/S=128、model/numeric全宽比较；task沿原布局核rows=1、row0=cmd_row、row_space=128、batch字段=1、layer/stage=0、op=1、task_id非0，跨行固定字段比较排除row0/task_id；task中的batch字段不直接替代地址公式b=0。cmd_id非0，新`done_id[31:0]`及mode/row与全部outer done字段保持至接受。QKV的core row_valid仅表示本地可读，不对外冒充scratch成功。正式阶段12=SCRATCH、状态7、bad_element全1用于wrapper/传输错；原core数值6及phase/bad保留，若二者并存则7/12优先。core早期错误无本地行时直接消费其真实done，不能等不存在的row_valid。

每次只允许一个`rd_valid&&rd_ready`预约，记期望tile；返回须核tile/mode/row，只有真实`rsp_valid&&rsp_ready`才清预约并把256bit交writer。writer堵塞时让原top保持`rsp_bits/rsp_tile`；下一读不得越过未消费响应。最后一次read发出或row_valid都不能触发flush/release。每段flush在末响应交付、无读预约后发出；整行成功还要求512响应、三个口96/96/64个OKAY B、49次成功flush和writer/读保持债零。然后真实release、消费core成功done，再生成一次outer done(status0/phase7/bad全1)。只有该完成被消费后才接下一命令；末B仍被阻塞时不release、不成功，最后一行outer done未消费也不允许tensor RAW发布。

AW/W债分别由实际握手计数，B只在TX两个接受位均置位后握手；债包括未发held/pack、已展示未接受AW/W和已发等待B，不能只用AW−B。AWVALID或WVALID已经展示后，即使包装层发现错误也须保持至握手并等B，不能撤销半个事务。`B_ERROR`同拍禁止把新pack推进TX，已交付但未发的held/pack可按原叶子错误分支取消；这些是取消的本地payload，不计写成功。

错误策略固定为：锁存第一条实际BRESP/地址/目的或本地标签错误，停止新read；若已有同步读响应预约，则真实接收并丢弃它以清读债。B错误按原writer清未发pack/held、让已发TX真实退休；单纯本地接口错则flush此前已接收的pack，完成可能已经展示的AW/W/B。错误路径等待`debt_zero`而不是永不产生的`flush_done`，不要求错误行凑齐512/256计数。所有读/写债零后真实release core行并消费core done，外层仅一次错误完成。RAM可能已在W时被改写，错误B不意味着回滚；整个目标epoch保持不可发布，不能把部分写或core status0转成成功。缺B只能保持在途/由成本保护终止，不能合成B或清债。

**有限tensor元数据与共同reset。** 定案维护单一活动request/generation、完整model/numeric、固定task字段、三目标描述符及128bit row_written/sticky tensor_failed。`tensor_begin=1`仅在无活动tensor时建立上下文，三目的epoch等于非0 tensor_epoch：初次1，随后严格为上一已释放epoch+1，不回绕；begin可随任意未写row。非begin须精确匹配且上下文未失败；非法begin/身份/epoch/重复row在core/总线启动前拒绝，旧上下文不变。只有已接纳行全部B成功、release/core done成功才置位；已接纳行的core或写回失败均置sticky failed，不限于已经开始写的行。后续QKV拒绝；FFN在全部行/写/完成债退休后可运行，但不清failed/覆盖、不发布QKV。

只有`&row_written && !tensor_failed`、全部债零且末行outer done已消费后才置`tensor_raw_valid`，保持身份/epoch/descriptors至释放；两行主场景不得填余126位。新增`tensor_release_valid/ready/discard/epoch`及request/generation各64bit：身份匹配、无活动row/read/write/core/outer done时才可接受；discard=0须RAW已发布，代表实际消费者释放，discard=1仅允许未发布partial/failed显式作废。已发布不能以discard替代消费者释放。接受后清有效/覆盖/failed并保存末epoch；非法释放ready0且不改状态，同拍释放优先cmd。norm/QKV保持至正确生命周期结束，不因FFN完成而复用。这些固定元数据和接口已定，动态发布/释放仍NOT_RUN。

共同同步reset覆盖wrapper/core/writer及受控AXI peer，取消同一未完成事务，清valid/预约/计数/覆盖/epoch；旧RAM/外存字节失效。reset后的首次tensor按epoch1重新建立，不继承旧有效性；普通无reset重用仍须显式释放并逐epoch递增。不签master/slave独立复位、旧B自动匹配或reset后完整模型。未来设备接线须确认此reset域，普通模式切换不得reset清债。全128 RAW之后仍缺Q/K真实RoPE及RAW→FINAL覆盖/写债、Attention的K/V加载/命令/mask；full Attention依赖128位置，保存gold范围和完整模型未因本次采纳扩大。

**可证伪的有限验证。** 同一新runtime先真实row0 cold生产并写scratch成功，再真实row1 warm生产，保留原完整LN/Q/PS/final checker，两行512个响应全部进入新writer。row0在三个目的口保证实际AW/W有限阻塞、AW先于W和W先于AW、B有限延后，并在最后norm B前断言release/成功/row_written均未提前；接收B后核原字节、精确地址、全WSTRB、计数与一次完成。row1将**最后norm TX的真实BRESP**设为错误，先令它完成AW/W并有限保持B；核全部预期数据/address、收到错误后债清、无成功位/无tensor发布、真实release和一次错误完成。两条memory scoreboard均核未写地址/页尾/邻行哨兵；B失败样本只签所测控制，不称自然设备故障分布或数据回滚。正常＋错误共512个真实单拍AW/W/B、32768B有效写工作量，非墙钟预算。

独立预期用保存`qkv_rows4_output_f32.bin/source_f32.bin/scatter_u32x4.bin`的row0/1切片，原scatter第四字段分别0/1；不重算浮点。row0 final/norm SHA `d4d1b006…/f166773b…`，row1 `18079bd9…/cf4dd5c6…`；完整SHA与切片偏移在新依据表。正常真实producer始终为现top；保存中间值只作checker。正式短测可用同一生产adapter合法同步peer验证rearm/页尾、全部128位及末行outer done发布、重复row/旧epoch/discard/release；这是局部事务/元数据验证，不是128行真实QKV生产。共同reset分别触发读已收未返、AW已收W未收、W已收AW未收、AW/W均收待B，DUT与peer共同复位；不外推完整生产链恢复，不force内部valid/FSM/debt/done或复制TB判断替身。

遗留完整跨mode只与**此新生产/写回接点**合并：上述row1错误正确排空/释放后，无reset让共享top以Wi slot0 epoch2、Down此前空slot1 epoch1 cold进入原FFN，逐位到1024末残差与消费者done。这样同一次真实QKV前缀同时验证scratch、传输错误后释放和模式重入；不再单跑只重演AT195的QKV冷前缀。原错FFN warm拒绝可按未变core身份保留，不为其重复一条长行。若新profile显示组合无法落入A001给定成本帽，应集中报告完整跨mode仍未闭合，不能仅抬旧1100s帽或删全N/末残差；分开runtime也不能拼成同runtime恢复。

**成本与未测量。** 只引用本次[AT193原日志](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT193_SM004_rev12_qkv_ffn_switch_full_fix_01/sim_stdout.log)和[AT195原日志](../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT195_SM004_rev12_qkv_ffn_focused_full_01/sim_stdout.log)：AT193 cmd接受7/78686至done78684/129595，差78677/50909cycle，含其旧消费者行为；整次714.517070s、child1/trigger null。AT195整次1100.280453s、child−9、原guard的trigger为`timeout`，截止前缀无Fatal；不能把报告中的“null”泛化为未触成本保护。原`FFR1_PROGRESS aw/w/b`是复用进展字段，含矩阵issue/commit/G返回，不能当新scratch AW/W/B计数。新writer读取/flush/B尾部、路由背压、组合仿真墙钟与联合物理全部UNKNOWN，不能按16384B或24/41直接缩放旧时间。需要新版本pilot记录真实cmd/row_visible/首AW/末W/末B/release/core_done/外层完成和每目的计数；仅cold LOAD阶段速率不足以估计matrix/G/Down/ADD。固定结构可证明每行512读、256单拍事务/49屏障、S128合计32768单拍事务，不能证明完成上界（外部ready/B延迟尚无上界）、II或Fmax。

**修订13独立预算。** host累计300s/8GiB；static/IP/展开累计1800s/24GiB、单次600s；RTL含pilot/局部peer累计4800s/8GiB、单次2400s且全局1Mcycle，必要pilot≤120s计入。合同允许预先2400s硬帽的同一次主运行以首120s作profile检查点，不能动态延帽；先取得新writer/adapter短例计量，再结合未变core已测阶段估算。AT193与195原墙钟相加约1814.797s含重复前缀，仅作保守规划依据，不是新场景上界。单重工具、CPU0–3/nice19/idle、MemAvailable>192GiB和RTL真实语义进展120s保护保持；ordinary修复在帽内连续执行，无逐步批准、OOC/P&R、前向、新gold/代理或参数扫描。

修订12 static800.903263994s、RTL3568.453182073s及余31.546817927s封存，不转移。本研究原[只读脚本](fixed_graph_support_20261014/check_qkv_norm_scratch_binding_20261015.py)52项文件/窗口、22项条件与[计量](fixed_graph_support_20261014/qkv_norm_scratch_binding_time_20261015.txt)0.06s/18864KiB/exit0保持；交互读取UNKNOWN。本次只更新主控采纳、正式接口/预算和未测边界，未重跑核查或实验，不改E002/E004及原答复/依据。新scratch连接/rearm/tensor动态发布、完整跨mode、128行真实生产、完整模型、联合资源/Fmax仍未验证。

## QKV scratch → Encoder0 full RoPE：单行隐藏调度的静态建议（2026-10-15）

以下保留研究建议交付时点；当前正式接口、参考接纳及预算见本节末“修订14采纳与研究收束”，以主控合同为准。

对应主控问题`m004-qkv-rope-minimal-next-design-20261015`，仅静态准备，**尚无修订14接口/实施预算或新硬件PASS**。本节采用一条路径：原单计算core/包装层/单writer后接**一份保留完整Check的既有RoPE HLS叶子**，按真实已写完的token行串行读Q/K、算术、原地写回，在请求内部保持隐藏，独立积累RAW来源覆盖与FINAL覆盖。数学上无需等其余127行；原地变换后不得把混合内容发布为RAW。本节的模式/epoch/发布变化待A001集中定案；现修订13发布合同仍有效，不以本建议直接改RTL。

静态[依据](fixed_graph_support_20261014/qkv_rope_binding_20261015.json)包含82项文件/窗口身份、39项成立条件、真实表及地址边界，并保留不匹配的观测。当前core `54fe628f…`、writer `ee1121c5…`与AT204冻结相同；工作wrapper `9c55ae10…`已不同于AT204 `e5dde5cc…`。AT204真实row0 cold写成功、row1 warm末norm错误B排空后无reset完整FFN残差done仅按冻结身份接纳；工作wrapper两项普通局部修复不因本次静态核对继承该PASS。新增RoPE包装层会改变控制与路由，未变core数值证据可复用来源身份，新增组合控制仍须受影响验证。

**实际数值源与选定叶子。** 当前[生产源](../project/E002_Laya_HLS/experiment/hls/operators/rope_full_compute.cpp)与P2 source_hashes一致（SHA `17b57824…`）。[完整参考](../project/E002_Laya_HLS/experiment/tests/full_reference.py)的`rope_qkv_many`及完整调用顺序确认Encoder0用`cos_full/sin_full`，位置直接为token `s`，每头64维，Q/K旋转、V逐位保留；没有token间递推、Attention mask或在线三角函数。预检按d=0..63核x/cos/sin有限，保存全部x后，按i=0..31执行 `a=x[i]*cos[i]`、`b=x[i+32]*sin[i]`、`lo=a-b`、`c=x[i+32]*cos[i+32]`、`d=x[i]*sin[i+32]`、`hi=c+d`，各步F32单独舍入/finite检查，禁止FMA。每pair低半失败先于高半，返回原Check及原位置，不用任意全局最小index替换这个控制顺序。

选用P2成功综合的[rope_probe/rope_head.v](../project/E002_Laya_HLS/experiment/build/full-hls-20261007T030653Z-1859617/rope_probe/solution1/syn/verilog/rope_head.v)，其同目录6份Verilog＋2份FP IP Tcl全部保留身份：`ap_clk/ap_rst`高有效控制reset，`ap_start/done/idle/ready`，x/cos/sin三路6bit地址同步`ap_memory`读，y两路6bit地址/32bit数据/ce/we写，`ap_return[127:0]`保留Check。按生成拼接解码code[15:0]、detail[63:32]、bad_element[127:64]，OK坏位置为全1；新的adapter须用定向样本核这项ABI。旧`full_rope_cosim_top`只返回16bit code，坏位置被综合消去，因此不选它作正式错误接点。其三例quarter-turn/非对称表/Inf的[cosim PASS](../project/E002_Laya_HLS/experiment/results/engineering_p2/20261007T030653Z-1859617/cosim_rope.log)仅是同C++算术的旁证，**不签所选完整Check顶层的RTL接入PASS**；所选probe已有CSim/综合，仍需直接短测。旧大top的外部共享FP/owner耦合不引入本方案。

所选FP Tcl为NonBlocking＋aclken，MUL IP latency1、ADD/SUB IP latency2，外层生成封装另有寄存。`has_aresetn=false`且封装reset未实际接入这些IP，不能把“拉高ap_rst”写成IP所有在途数值已清零。adapter只接受活动head的ap_done，reset清活动/新输出覆盖/命令有效，禁止旧输出写外存；共同reset后的真实发射隔离和新head恢复须用该叶子实测。叶子没有输出ready，必须先备齐本地RAM再start、无条件接住两路y写，不能让AXI背压直接停它。ap_done时锁存Check，有限结果检查及64元素写覆盖齐全后才允许writer读取；数值错误的部分y一律不写外存。

**真实表/内存接点及有界暂存。** 当前模型包[布局头](../project/E002_Laya_HLS/experiment/build/model-current-production-v2-20261011/laya_model_layout_generated.h)将full cos/sin放在AUX字节偏移617728/880128，各1025×64×4=262400B；本次完整窗口SHA分别`fe68cb1c…/e2c58174…`已核。每行读取`aux_base+offset+s*256`的256B，两表共512B，一次装载供本行32个head复用；不能把QKV用的AUX header地址当成模型AUX BO起点。新增冻结的AUX BO base/span及model/table身份，核65bit不溢出、域/包含、表族full、s<128；当前包偏移是模型身份的一部分，不接外部可变角度。row0表为全1/正0，row1全64字节位型明确不同于row0，所有值finite；即使当前表两半相同，叶子仍访问i及i+32各自表值，保留旧非对称表测试。

真实scratch读选现有[`t4_w_reader_port_v1`](../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv)，`SCALE_MODE=0`，每次`load(base,256,epoch)`读取一个head；其load_ready/done/error、out_data512/out_offset/out_epoch/out_bytes/out_last/valid-ready可直接包成head装载，整burst预约、64beat上限及4KiB切分沿原源码。复用[`t4_aux_bias_reader_v1`](../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_aux_bias_reader_v1.sv)按两次256B读表，输出128bit；与计算core的AUX端口做**相位互斥**路由，只有core load债退休后才切到RoPE，直至reader done/所有输出接收完才切回。scratch QKV0/1新增真实AR/R512接点，选中shard保持到整load_done；不接W cache lease口冒充QKV读、不触碰两W槽内容。完整读口新接线/RRESP传播尚未验证。所选reader原FIFO分别4096B及1024B，明确计入结构成本，不宣称只有768B总暂存，不在本段改深度或扩cache候选。

新增本地有效payload为一个head256B（可用2×32元素bank）和cos/sin512B；head输入与y复用，因为原叶子先保存全部x再写y，叶子内仍另有saved256B。装载/算术/输出三相互斥，512bit读返回入bank、三路同步读取、双y写与256bit writer取数的端口适配由薄adapter实现，payload容量不代表BRAM/LUT实测。每个成功head通过原writer的8个32B tile连续模式写回256B；`mode_qkv=0`、n0=0,8,…,56、lanes8，base直接设该head物理地址、span256，SHARD参数不参与该连续地址计算。复用当前160B writer held/pack/TX；每head4次AW/W/B、一次flush，flush成功并撤下且债零后才改目的/基址。一次rearm可从前一QKV行写阶段切入RoPE；错误sticky只能在整个活动事务真债零、无tile/flush后按新命令重置，不能在失败行内清错续算。

**地址与工作量。** 继续用 `shard=head&1`、`off=((((plane*2+b)*8+head/2)*1024+s)*64+d)*4`，固定B1的b=0。单行仅plane0/1、head0..15读/写，head顺序0..15、每head先Q后K；每head配对i与i+32。s=127/head15/K/pair31的最后位置63也在同一公式内，禁止缩S或将头尾跨行配对。V的plane2及STATE1 norm无RoPE AW/W，scoreboard逐字节核保持及相邻行/页尾哨兵。QKV各BO仍12MiB，norm分配8MiB不变，实际S128有效Q/K为每shard524288B、合计1048576B，稀疏地址不等于有效字节或BO分配量。

每行32head/1024pair/4096次乘/2048次加减；Q/K读8192B=128个512bit R、写8192B=128个单beat AW/W/B，writer256tile/32flush；另AUX读512B=32个128bit R。64B对齐scratch基址下每head读为1或2个合法burst（ARLEN≤3；跨页分开），合计32–64 AR；若进一步具256B对齐才固定32AR。AUX只需16B对齐时两表读为2–4 AR/32R；真实包及BO对齐需随实现核。单beat写AWLEN0/size6/INCR/WLAST1/全WSTRB，均不跨页。本次整数枚举全128行16384个Q/K beat，域内唯一、范围合法且与V不重叠；这是静态布局证明，不是128行生产或吞吐。AT097越4KiB路径/速度不作依据。

**隐藏行调度与发布建议。** 在tensor_begin锁存单一`rope_enable`（旧caller接0）；启用后固定Encoder0/full、request3/gen1或后续合法请求的完整身份、B1/S128、三BO与table描述符不变。建议当前QKV行真实末B成功→release本地core行/消费core done→置该行RAW来源位→读表和Q/K→每head真写回→所有RoPE B/flush退休→置该行FINAL位→outer done。core释放后的片上行不再是RoPE producer，唯一源为刚成功写入的设备scratch。整个期间不接受下一行/FFN命令，不需要新行队列或第二份matrix/LN/Q；可使现core保持原接口，wrapper须扩FSM、共享writer输入/目的路由、AUX mux、scratch读口与epoch/覆盖输出。原result_mode/row/id在新尾部同样稳定，非法回显保留协议优先；建议4bit phase13=ROPE，不占用新的宽度，12仍为原scratch阶段，正式编码由A001确认。

`row_written`保留为“RAW曾成功写完”的来源事实，新增128bit `row_final`，不能把被覆写行继续解释为RAW内容。每行只需当前head/plane计数、64bit y写覆盖与真实reader/writer债；仅全部32head成功才置FINAL位。建议在begin同时预留QKV RAW epoch=e及FINAL epoch=e+1（e非0且禁止回绕），后续producer行仍以e校验，不因row0已变换将row1误判旧epoch；FINAL描述符仅QKV两shard变e+1，norm独立仍e。为避免失败后旧写/引用复活，release或discard都消耗已预留的e+1，下一begin从e+2开始；RAW-only旧模式维持原单epoch规则。**这是待采纳的接口变化**，不能悄悄更改现rev13“三目的epoch相同/每次+1”的定义。

RAW-only模式严格保留原`&row_written && !failed && all_debt_zero && 最后outer_done已消费`发布条件。RoPE模式从begin起不对外发布`tensor_raw_valid`，也不先发布RAW后撤回；只在`&row_written && &row_final && !failed`、所有读/FP/写/完成债零且最后outer done消费后发布新增FINAL有效/内容/epoch描述符。已成功处理两行只能有两位，tensor FINAL仍false。partial或failed仅在真实债零后显式discard，成功发布后必须真实消费者release；FFN可在错误事务完成后运行而不清除tensor失败/覆盖。旧owner全tensor head优先遍历与新逐行调度的跨row错误先后不同：保持所测row内原head→Q/K→Check首错、任意失败污染整个tensor，**不签旧全请求首先遇错顺序等价**；若上层要求该全局顺序，须由主控解决合同，不能用新时序偶遇顺序冒称旧首错。

**债、错误及受控共同reset。** 每次head AR前要求该row RAW来源完成且未FINAL、身份/epoch/范围一致；必须等reader load_done且无load_error、收到精确offset/epoch/256B后才start叶子。reader可能先交出部分数据再报RRESP，故out_last或收到64项不能单独触发算术。读错锁存后cancel停止后续AR，但已经展示的AR稳定到接受，已接受burst实际收到RLAST，输出FIFO继续真实消费/丢弃，load_done后才算读债零。缺RLAST/B只等待成本保护，不能补响应；早/晚RLAST的错误能力按现reader实际实现做有限控制覆盖，不扩大任意损坏总线恢复保证。

数值错停止新head，保留Check及head/plane/row侧带位置，当前head输出不写；之前已成功写的head无回滚，整个tensor failed。BRESP错同样sticky failed，禁止新head/read/FP发射，已展示AW/W保持到握手、真实B退休，writer的held/pack取消与原错误分支一致，等debt_zero而非等待永不来的成功flush。AP输出覆盖/同步读响应及未消费done也属于债；只有全部退净才一次错误outer done。即使错误B对应W已落RAM，也不得置FINAL或发布部分tensor。传输/回显协议错与数值并发时保持协议优先，位置字段不能用协议全1覆盖已经被单独记录的数值Check，正式外部映射待主控定。

共同reset只覆盖本wrapper、compute core、reader、writer、RoPE控制及受控AXI peer，清命令/覆盖/有效性，旧外存字节失效；FP IP无aresetn的边界如上。reset后须新begin与新真实加载，不能继承旧RAW/FINAL位。局部测试在真实read AR后、实际MUL发射后、AW-only/W-only/待B分别共同reset，核无旧写/发布及一条新合法head；这不签master/slave独立reset、外部永久故障或reset后完整128行模型。in-place保守串行保证无同地址读写重叠；设备域/缓存一致性及B之后读可见的实际系统接线仍未测。

**保存参考的实质缺口与可用子集。** 当前request3/gen1的`task2_real_fixture_20`保存row0/1完整pre-RoPE 3072F32、norm1024F32及scatter；row0 QKV/norm SHA `d4d1b006…/f166773b…`，row1 `18079bd9…/cf4dd5c6…`，scatter第四字段分别0/1，均重新逐字节/整数核对。`qkv_rows4_steps_u32x6.bin`属于量化矩阵dot/sa/sw/product/term/PS，**不是RoPE乘加步骤**。这些来源不是P1样本；前述v4/current-production请求不同wire/package身份沿原[入口依据](fixed_graph_support_20261014/embedding_qkv_binding_20261015.json)保留，不混为同一个请求文件SHA。

发现的[旧完整full RoPE参考](../project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/attention_fixture/full_attention_fixture_report.json)有B2×S128×3072的RAW/FINAL及full表，generator明确以**native enc0_qkv**为局部输入；full FINAL是独立参考结果，但输入不等于当前精确QKV链。row0 Q/K/V分别820/836/842个F32位型不同，row1分别818/813/824不同；两行均没有任何完整Q/K head输入相同。不能把其row0/1 FINAL当当前整行gold，更不能将这些RAW文件注入新producer。旧四条full局部参考仅b0s0h0与b0s127h15的Q/K，输入/表/FINAL对应旧B2参考已核；不能补足当前row1。对已列目录未发现当前输入的完整RoPE步骤/FINAL或FINAL scatter，缺口明确保留，不执行新oracle。

有一个严格的有限子集可用：逐pair同时比较当前及旧RAW的两个32bit输入，且本行cos/sin保存表完全一致；row1恰有**39对/78个输出元素**满足，全部旧FINAL偏移列于依据的`rows[1].matching_QK_pairs`。RoPE每pair数学独立，这78个保存值可直接作非退化精确checker，不是重算或新gold，不外推其余1970个Q/K输出。row0表全1/正0且当前Q/K2048项均为normal非零F32，由原分步公式可用已保存pre字节验证恒等结果；这只是位置0退化检查，不能替代row1。V/norm始终可用原全量保存字节检查不变。

**单一有限主场景与局部短例。** 建议一个新runtime按真实producer row0 cold→成功RAW写→完整RoPE读/算/写→row1 warm同链正常完成；不要沿AT204让row1原始norm B失败，否则没有合法row1 RoPE producer。核两行原LN/Q/PS/final、全部scatter/norm写地址/数据，再核真正R读的是这些W写下的内存；逐head检查表s选择、Q/K配对、64输出覆盖/finite/状态、所有AW/W/B与读写范围、row0全量恒等、row1上述78项独立数值、V/norm全量不变。至少在最后head的最后B有限保持，确认FINAL位/outer done未提前，消费后只置本行位；两行结束RAW/FINAL对外均不得发布。有限AR/R/AW/W/B停顿须实际命中并记录每口握手/保持，正常流不能把零覆盖当PASS。**该场景最多签两行真实连接/传输及指定数值子集；当前资料不足以签row1 full RoPE逐位数值PASS。**

局部peer沿同一adapter/reader/leaf/writer入口重放已有s127h15 Q/K原输入/表/独立expected以及旧非对称表/Inf样本，覆盖pair31及位置127；这是叶子/布局局部事务，不是真实当前row127生产。再用一条真实RRESP错误（AR已接受后）和一条最后head真实错误B（AW/W均已接受且有限延后）核停止新读/发射、实际排空、一次错误完成、无FINAL发布、显式discard/新epoch恢复；不force FSM/valid/覆盖或预填126位。完整位图可由合法row完成peer作局部元数据测试，仍不代签128行真实算术。

仍缺全128行真实embedding→QKV生产、每行full RoPE独立数值参考与实际FINAL覆盖、Attention的全128 K/V装载/lease、QK/softmax/AV命令及请求mask。提前逐行RoPE不会消除Encoder0全Attention对128个K/V token的依赖；FINAL/skip生命周期要等后续真实消费者，不因两行通过释放整个tensor。AT204已完成的错误后FFN跨mode不为新RoPE凭空升级，也不默认再跑同一完整冷前缀；A001按新wrapper实际影响决定是否把RoPE失败后FFN接入后续受影响回归。

**成本及交付边界。** AT204原guard child0/trigger null，RTL1404.050676294s、峰982160KiB；global77639/127513/321332是阶段完成时间点，不是各命令latency/II。AT193整次714.517070s/FAIL及AT1951100.280453s/timeout原账保留，不能按8192B比16384B缩放新墙钟。所选probe旧csynth报告9–1027cycle/次head为HLS估算（非stall含总线实测）；三例兄弟wrapper cosim约42s不能当新顶层运行成本。新主场景在原两行producer之外增加64次leaf调用、256个scratch R/256个AW/W/B及64个AUX R；新仿真模型/IP展开、共享路由尾部和背压成本需pilot按真实阶段计量，不能承诺150MHz、Fmax、新联合资源或完成上界。本研究不借用修订13工程余额，不定义下一段预算。

本次[字节/整数脚本](fixed_graph_support_20261014/check_qkv_rope_binding_20261015.py)最终39项检查/82项身份；初次检查及收据另保留为`qkv_rope_binding_initial*`。两次均以`taskset -c 0-3 nice -n 19 ionice -c 3 timeout 20s prlimit --as=1073741824 -- /usr/bin/time -v ...`运行，[初次计量](fixed_graph_support_20261014/qkv_rope_binding_initial_time_20261015.txt)1.17s/28920KiB、[最终计量](fixed_graph_support_20261014/qkv_rope_binding_time_20261015.txt)0.13s/29008KiB，脚本累计1.30s、各exit0；交互读取仍UNKNOWN。未运行EDA/前向/新gold/新agent，未修改E002/E004。本节为静态方案与证据缺口，实施/验收/预算由A001集中确定、A002唯一执行。

### 两行full RoPE派生参考补齐（D-M004-ROPE-REFERENCE-01，2026-10-15）

本小节保留求值交付时点的“待主控核验”状态；后续正式接纳见下节，原manifest及产品不改写。

A001消息`m004-qkv-rope-bounded-reference-preparation-20261015`明确新增有界host参考求值授权，覆盖上一静态任务对新oracle求值的禁止；未授权修订14工程。本次只在研究支持目录生成[派生包manifest](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/manifest.json)，原参考/原工程fixture和上节静态缺口记录保持。**同request3/gen1/B1S128 row0/row1的完整FINAL参考现已补齐，待主控独立核验后冻结为checker；不再局限于row1的78项子集。** RTL连接、Check错误ABI、128行生产及发布仍未验证。

完整父oracle为`source/feasibility_20261014/v4/inputs/fe9678e44030ef4c_full_reference.py`，35233B、SHA256 **`fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`**，与当前E002 `tests/full_reference.py`逐字节相同，已原样冻结于派生包`inputs/full_reference.py`。调用脚本[prepare_reference.py](fixed_graph_support_20261014/rope_reference_rows01_20261015/prepare_reference.py)及run01内副本同为SHA `dee53cc921b610666455decfdd40ff39b184d536267118607919c4708176c39d`；父函数源码未改，运行时只调用`rope_head/rope_qkv_many`及原`mul/sub/add/_array/_finite`，调用审计已保存。未导入生产算术或DUT，未调用full_forward、矩阵/LN、Attention或三角函数。Python3.12.3、NumPy1.26.4、little endian，六项NumPy/BLAS线程环境均1，Python可执行文件身份及环境写入manifest。原model GGUF SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`按原P2出处/当前包头交叉绑定；本次未重哈希整GGUF，但重核完整两表SHA和所有实际读取窗口。

求值前四个既有s0h0/s127h15 Q/K叶子共256个F32与原expected逐位零差异，并核其P2原文件与D2保存文件相同；随后旧native row0/1的6144个FINAL F32与原full_final对应窗口零差异。这些校准全部先于当前输入求值，未改expected。当前输入仅取`task2_real_fixture_20/qkv_rows4_output_f32.bin`字节0:24576，两行pre-QKV；cos/sin取原AUX偏移617728/880128各512B，即s0/s1各64项，完整窗口/父文件SHA、offset/shape/endian均冻结。求值窗口shape为[1,2,3072]，是固定B1/S128中的两个token切片，未将模型S改为2；norm只复制原4096B/行。

| 新产物（run01/products） | 布局/大小 | SHA256 |
| --- | --- | --- |
| [row0_full_FINAL.f32.bin](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/products/row0_full_FINAL.f32.bin) | [Q,K,V][16head][64d]，12288B | `d4d1b006b7d46e84fc13c431cd781b930d871149382a68a37cd81377ad7aee1b` |
| [row1_full_FINAL.f32.bin](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/products/row1_full_FINAL.f32.bin) | 同上，12288B | `f4fa2f826ab8f9202f5f589ae531e84956700c5a154ef600320592e8cab09def` |
| [row0_steps_ab_lower_cd_upper.f32.bin](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/products/row0_steps_ab_lower_cd_upper.f32.bin) | [Q,K][head][pair][a,b,lower,c,d,upper]，24576B | `83f8d65e80b2d25b2bd2bd7e8ab70cd844ba405b8ef07e869fa034edb8e6a49a` |
| [row1_steps_ab_lower_cd_upper.f32.bin](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/products/row1_steps_ab_lower_cd_upper.f32.bin) | 同上，24576B | `b302ef836641eb1f9d433d31b156acf63a2579530d3e587fff2ff948a12c756e` |

所有产物little-endian F32/C顺序。两行各2048个Q/K FINAL来自原`rope_qkv_many`，各1024个V逐字节保留；两行完整结果与64次原`rope_head`逐位一致，**这是同一父oracle内部交叉核查，不是第二独立oracle**。row0完整3072项恒等、row1非退化、原39pair/78项保存FINAL全部吻合；所有FINAL及六字段步骤finite。诊断文件只用原helper按生产非FMA顺序a、b、lower、c、d、upper求值，lower/upper与FINAL的4096项对应完全一致，不能用于宣称软件异常先后或Check ABI等价。norm输出`row0_norm_unchanged.f32.bin`/`row1_norm_unchanged.f32.bin`各4096B，SHA仍`f166773b…/cf4dd5c6…`，无算术。

run01的363项身份/边界/数值条件全部成立，运行后重读全部原始源确认未变化。[落盘核验](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/artifact_verification.json)另核60项原文件/冻结窗口/产物身份和诊断布局，仅作字节/整数处理，manifest SHA `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2`。本轮[参考求值计量](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01_time.txt)0.35s/48376KiB、[落盘核验计量](fixed_graph_support_20261014/rope_reference_rows01_20261015/verify_time.txt)0.06s/22904KiB，host参考/核验合计0.41s，各exit0、20s/1GiB保护、CPU0–3/nice19/idle；独立于上一静态脚本1.30s，不挪工程预算，交互读取仍UNKNOWN。无EDA/HLS/RTL/OOC/P&R、完整模型前向或新agent；本次仅解决指定两行的独立数值参考缺口。

### 修订14采纳与研究收束（2026-10-15）

A001在`m004-qkv-rope-reference-adopted-revision14-notice-20261015`正式接纳两行派生参考，并下达[修订14实施合同](../results/m004_simplified_start_20261014/qkv_rope_connection_decision.md)（D-M004-QKV-ROPE-ROW-01；[SM004](../project/missions/SM004.md)）。工程派发消息`m004-qkv-rope-revision14-implementation-dispatch-20261015`已delivered，recipient turn `01a13dde-28e2-7b11-a66f-c08352db1fa1`；这是工程实施授权，**新连接仍NOT_RUN**，不等于功能完成。研究静态准备及参考补齐已收束，本次仅关联采用状态，不追加求值、EDA或Attention任务。

主控读取未改oracle和调用脚本，独立核61条原父/冻结窗口/产物/脚本身份、全部窗口、4096个步骤lower/upper到FINAL的字节对应、V/norm不变、row0恒等/row1非退化及旧78项，接纳manifest `979b10300a914d7f3071266914b742cc01f034a55738e4d62dd41ba045e9fbc2`的两个完整FINAL和诊断文件为后继checker。审核位置为[既有机读依据](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)字段`rope_rows01_independent_reference_review`。原研究363项检查、四叶子256项/旧两行6144项校准和0.41s求值/字节核验保持；主控没有重复浮点求值，本研究亦不重跑或改manifest。旧静态“仅78项可复用”是补参考前的真实边界，当前两行完整数值参考缺口已解决。

正式采用单core/单writer、原完整Check RoPE叶子、scratch与AUX两个reader；RAW全部写响应和core真实释放/done退休后，才从刚写好的scratch读取Q/K、原地变换并等真实B。保留旧RAW-only与FFN分支、V/norm不改，一行尾部未完成不并行接下一行。原静态82条身份中81条当前一致，wrapper后续修复另列：当前`daae56115474afa20d04598964eca85869e86226ca9abcf3e5e8945660e06db0`仅签AT213局部控制/AT214真实core展开；AT204完整链仍只属`e5dde5cc…`，研究捕获的`9c55ae10…`保留为中间开发快照，均不互相迁移PASS。core `54fe628f…`、writer `ee1121c5…`沿合同未变。

正式epoch接口细化为：启用RoPE时源`tensor_epoch/tensor_dst_epoch`始终保留e，新增`tensor_final_dst_epoch`为QKV0/1=e+1、norm=e；`tensor_rope_enable`、128bit `row_final`及`tensor_final_valid`显式输出。后续生产行仍用e，begin预留e/e+1且禁止回绕。FINAL正常消费者release须用e+1，未发布partial/failed显式discard须用e，二者均在真债零及完成退休后接受并消耗预留上界e+1，下一begin e+2；RAW-only保留单epoch旧规则。RoPE模式始终不发布RAW；只有128位RAW来源及FINAL覆盖齐、无failed、真债零、最后outer done消费后才发布FINAL。两行只置两位，失败不得原址重试或伪造剩余覆盖。

phase13正式用于RoPE；叶子数值错6/13，`done_bad_element=plane*1024+head*64+leaf_bad`，token由result_row标识。新增`done_rope_check_valid/check[127:0]/head/plane`保存真实消费的原Check及位置；协议错7/13优先，未知非0叶子code按协议处理并保留原诊断，具体字段按合同。仅承诺row内head→Q/K→原Check次序，不宣称旧全请求head优先首次遇错等价。无aresetn的FP边界保留，正式共同reset要求510拍隔离、禁止新leaf start并拒绝旧y/done可见写，局部触发必须采到真实MUL接受且未返回；没有以旧cosim或正常参考代签该动态验证。

warm零新增LOAD只指core原W及AUX header，RoPE cos/sin每行都经共享AUX真实读取，不能沿用“整个AUX零增”断言。正常主场景为真实row0 cold与row1 warm两行完整RAW→RoPE，使用已接纳的全部4096 Q/K FINAL及V/norm检查；两行共512 RAW写＋256 RoPE写、256 scratch R、64 table AUX R，局部错误/reset/元数据与真实生产分开验收。完整128行真实生产、全请求首错、Attention加载/mask及FINAL/skip消费、完整模型、生产Host/HBM和联合资源/Fmax仍开放。

修订13按分版收束：static累计615.5153379254043043s、RTL1498.1496843509375738s，余额封存。修订14工程独立host300s/8GiB、static1800s/24GiB（单次600s）、RTL含pilot4800s/8GiB（单次2400s/1Mcycle，pilot≤120s计入），单重工具/CPU0–3/nice19/idle及MemAvailable>192GiB沿合同；不增OOC/P&R、HLS重综或整模求值。研究原静态1.30s和参考/核验0.41s另列、交互读取UNKNOWN，当前仅维护文档/状态，不开新实验或要求确认回信。

## S128真实入口与FINAL→Attention：下一最小连接依据（2026-10-15）

以下保留静态建议交付时点；当前采用范围见本节末“修订15静态采纳与研究收束”。输入预装/固定调度获采纳，Attention本段不实施；研究关于全请求失败次序的建议没有被采用为整模合同变更。

对应`m004-s128-final-attention-minimal-next-design-20261015`。**建议先接真实STATE0/AUX输入reader和固定128行顺序调度，继续用现单core/单writer；以设备scratch的完整FINAL发布作为Attention消费者的前置条件。** 以下是一条分段贯通路线，当前只交静态依据，接口/预算仍由A001集中决定，没有启动后继实现或全128仿真。[支持记录](fixed_graph_support_20261014/s128_final_attention_binding_20261015.json)保存81条完整文件/窗口身份、25项字节/整数条件及6项同输入比较；[脚本](fixed_graph_support_20261014/check_s128_final_attention_binding_20261015.py)没有导入DUT或oracle、没有浮点求值。

### 当前身份及实际缺口

按[修订14审核](../results/m004_simplified_start_20261014/qkv_rope_stage_handoff_review.md)，AT225真实两行链仍只属旧wrapper；当前`laya_qkv_scratch_row_v1.sv`为`0d3e340e687d9720cdd2b1bed161adc7c4172a6c1310c08546011bc6c392e79c`，只沿已核局部错误/页界/元数据和真实core展开范围。core `54fe628f…`、writer `ee1121c5…`未变。AT240模拟core/快速叶子完成128位元数据，不是128行真实生产；四个Check短例及工程后续结果仍由主控按各自身份验收。

现wrapper的`x_valid/ready/bits`和`gamma_valid/ready/bits`是32bit外部流；STATE0没有AR/R口，`cmd_source_hidden_bank`只是身份声明，不能把TB喂数称为设备读取。现两reader确可复用：512bit [`t4_w_reader_port_v1`](../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_w_reader_port_v1.sv) SHA `478aeddd…`，128bit [`t4_aux_bias_reader_v1`](../project/E002_Laya_HLS/experiment/vivado/module_design/hbm_loader_and_cache/rtl/t4_aux_bias_reader_v1.sv) SHA `58f36989…`。它们均有load/base/bytes/epoch、顺序out offset/bytes/last、真实load_done/error及cancel，预留整burst FIFO并按4KiB分段；out_last不等于完整成功，load_done还依赖输出排空。当前wrapper只把前者接QKV0/1 RoPE读、后者接cos/sin并与core AUX相位互斥。

[`laya_ln_row_v1`](../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/laya_ln_row_v1.sv)严格先LOAD_X1024再LOAD_G1024，没有外部abort；core只有LN_WAIT才开放相应ready。若将新reader直接串成标量流，后段RRESP错会使core永久等待剩余x/gamma，不能以补零、伪造valid或共同reset冒充普通错误排空。因此本方案先完整接收、校验两段，再启动core，不新增LN异常算术入口。

### 单core的真实输入及128行调度

最小暂存建议复用[core](../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_lnq_wi_gqdown_row_v1.sv)既有`final_bank[0:7][0:655]`的前256tile、共8192B：raw占tile0..127，gamma占128..255；仅在core IDLE、旧行read/rsp/release/done全部退休、无残差/矩阵/G债时取得准备期独占。新增受限预装写口及同步读选择，将word c映射bank=`c&7`、raw地址=`c>>3`、gamma地址=`128+(c>>3)`。512bit/128bit reader返回先进入一个共用64B保持寄存器，再按32bit顺序写入；发射后1拍的bank读须有独立valid/保持，计数只随真实LN握手增加。这是复用存储的接口建议，现core尚无这些端口，也不是已实现的零成本路径。

gamma和raw在core启动前均完整落bank、各4096B、offset/epoch/last/byte_count正确且两个load_done成功，才锁存`source_prepared`并送原单row命令。core需一个显式预装源模式，在LN_WAIT从该bank回放x/gamma；旧外部流caller保留原路径。LOAD_W阶段不写final_bank；LN先消费完整raw/gamma，随后norm写tile384..511，matrix最终才覆盖tile0..383，因此上述生存期静态上不重叠。原数值树、gamma检查次序、Q及FP恢复保持；预装期不提前把非finite gamma升级到raw错误前面。新端口/仲裁改变core身份，旧数值结果仅是未改叶子和gold的复用依据，新连接仍需受影响实测。

固定请求锁存request/generation、B1/S128、model/numeric/layout/build身份、STATE0 HIDDEN源base/span/epoch、AUX BO base/span、两QKV和STATE1 norm目的描述符及原W描述符；所有范围在load展示前做65bit加法/包含/对齐检查。输入地址为`STATE0_base+s*4096`，每行4096B；gamma来自**模型AUX BO base+128**的4096B，不是W header基址。源HIDDEN与norm目的都是8MiB分配但分别在STATE0/STATE1域，B1/S128有效raw各524288B，不因数值base相同误判跨域重叠。CPU token embedding与Host上传/一致性仍是前提，本段仅从已声明可读的设备STATE0开始，不签实际XRT/HBM传输。

复用现scratch reader时增加STATE0固定AR/R路由；复用table reader时增加gamma准备相位，并在core AUX冷LOAD、gamma、RoPE之间仅于真债零切换。准备期失败只清预装有效、真实消费已接受R及reader done，core尚未获命令；停止后继行，tensor sticky failed、一次错误完成且无该行覆盖。即使最后beat数据已收，错误load_done也不能启动core。无需新增整tensor RAM、输入预读队列或第三套reader；reader既有FIFO容量保留。共同reset仍是双方受控复位并隔离旧可见返回，独立总线reset不在保证范围。

顺序计数`s=0..127`，首次begin e；row0 cold完整加载QKV key0001到原slot0，后127行warm保持相同W身份/epoch，slot1不参与。每行都重新真实读取gamma并由LN接收1024项，不假定LN内部g_mem跨命令有效；RoPE表亦每行真实读。row命令、id/row/mode回显、outer done消费及W lease/release沿现合同；上一行RoPE末B和outer done退休后才准备下一行。只由实际成功RAW写/core释放置row_written，由32head算术及末B退休置row_final；成功行计数之外仍保留128bit位图防重复/遗漏。第127行最后done消费后才可能FINAL有效，QKV FINAL=e+1/norm=e；失败discard e、正常FINAL release e+1、下一begin e+2，不能为调度方便把未运行位填1。

静态工作量为128×12288=1572864矩阵stripe、4096个RoPE head、RAW QKV24576＋norm8192笔64B写、RoPE16384笔64B写。raw读取8192个512bit beat；gamma每行256个128bit beat，全请求32768beat。它们是事务数量，不是墙钟或资源预测。4KiB对齐raw每行1AR，否则64B对齐下1–2AR；gamma AUX按原64beat/4KiB分段，不能把整个4096B视为128bit口一次合法256beat突发。

### FINAL到现Attention的唯一消费者接法

采用既有[`attention_tile_service_prefetch_v1.sv`](../project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv)，实际module为`attention_tile_service_v1`，本次SHA完整等于AT021的`11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`。保留M16/A16/D4/EXP4、同步bank、QK相邻树、softmax原max/exp/相邻sum树及AV按key0..127逐项非FMA累加。Encoder0 full mask_mode=0，但仍对每个key执行原`(mask-1)*10000`有限mask；不得跳过mask0的K/V或改为负无穷/裁短S。

[`full_tasks_attention.cpp`](../project/E002_Laya_HLS/experiment/hls/operators/full_tasks_attention.cpp)给出生产身份/LOAD_KV/QK/SM/AV及地址语义，但其`laya_attention_service`调用是标量3/7/8/9命令，**不能直接接成tile服务的RTL调用**。AT091完整软件运行曾走legacy CPU叶子而服务命令0，不能将该软件PASS转成新接口证据。新固定小FSM保留55word binding的实际字段和读回：NumericIdentity21、QK/SM/AV context各4、KV/score/prob/partial/ATT_OUT/QKV0/QKV1 ref各3、head|mask_mode；不恢复通用owner/portal。service的32bit命令epoch是本tile绑定epoch/task_id，与tensor源e、QKV FINAL e+1、norm e分开；七个ref的epoch必须非零，score→prob+1，QKV两ref绑定真正FINAL描述符，不能把绑定检查改成常量成功。

只在完整tensor_final_valid及身份/覆盖/债条件满足后，按head0..15、query tile0/16/…/112调用：0 RESET →1逐55word BIND及17读回 →2 CONFIG(index128,payload=query|head<<16，full模式高位0) →4 K/5 V（index=`key*64+d`，按原key/d顺序交替）→6 MASK(index0..127,payload原byte) →18 Q_TILE(index=`local_row*64+d`) →19 QK →20 SM →21 AV。每次真正ap_start接受后等待result/status有效及ap_done，再以ap_continue退休，CE暂停保持全状态。Q的非finite延后至相应row执行以保留原较早算术首错，不能改成reader装载即抢先报错；K/V和mask合法性沿原服务。

设备读仍用同512bit reader，Q/K/V地址沿既有head-parity公式。单head的某plane128行是32768B连续段，Q16行是4096B段；为保持生产K/V交替错误次序，可有界读K/V各64B到两条stripe保持区，按d交替发4/5；复用已退休head/bank空间，不存第二套KV。mask来自锁存的真实request128byte（本请求offset832），须新增明确的装载/身份入口，不能硬编码72个1。正常输入装载不改变算术顺序。reader读错不能伪造缺失命令；算术未发则停止装载并清合法服务上下文，已发算术按原done真实退休，所有R/写B排空后失败一次、不发布ATT。

**现服务每个tile均需重装K/V/mask。** 命令16/0清nq/nk/nv/nmask与phase；AV之后phase4不能LOAD，CONFIG只选诊断query，不重开下一个tile。故保留八个tile各16384个KV标量＋128个mask＋1024个Q装载，不能声称一次LOAD_KV即可无修改复用全部128query。完整K/V都必需，两个真实行不能运行正常full Attention。此处接受现有重复装载作为最薄可复用接口，不另开bank驻留优化。

AV成功后CONFIG选择本tile各query，12 OUTPUT(index d0..63)读出真实64个结果；按8值打包给现writer连续模式，每head/row256B，地址`ATT_OUT_base+s*4096+h*256`。新增明确ATT_OUT设备写域/端口或固定相位路由，不以改STATE1数值base假装换BO；writer rearm/route/base直到flush撤下及真债零保持。全部16row×64值及64笔B成功才置一个head/tile覆盖位（总16×8=128bit），全部位与最后完成退休后才发布524288B有效ATT_OUT（原BO分配8MiB）。命令16释放本tile前须确保其Y已真正读走；外存错误部分写保持隐藏。

STATE1 norm不进入QK/SM/AV，它是后续Q→WO→ADD的原attention skip。现wrapper正常tensor_release同时结束复合上下文；因此Attention结束仅记录QKV已消费，**不得立即用它释放norm或允许下一请求覆盖STATE1**。最小做法保留该上下文到WO/残差真正消费norm之后再统一release，不新建通用引用管理。后续WO/残差本轮没有接上，FINAL→Attention适配、写口及其生命周期也尚无RTL证据。

### 全请求首错的实质冲突

当前生产源码的RoPE真实执行次序是`head→16row窗口→row→Q/K→原leaf Check`（前面的plane循环只是覆盖预检），并且全部QKV矩阵生产先于RoPE。修订14是`row→head→Q/K`，且每行RoPE在下一行LN/QKV之前。例：row0/head1与row1/head0均坏，逐行版本先报row0/head1，旧全请求先报row1/head0；row0 RoPE坏与row1 LN/QKV坏竞争时，两图阶段优先也不同。不能靠重新编码bad_element或只取已观察最小key修复，因为当前失败即停止，旧优先错误可能根本未执行。

本最薄建议保留已采用的逐行停止/隐藏合同，并要求A001在后继固定图合同中**显式定义这种全请求失败次序，旧全图异常等价继续不签**；这是需要集中定案的异常ABI差异，不能由研究或工程静默变更。如果验收仍要求旧全请求首先遇错，当前逐行复用方案本身不足，须先改变阶段/异常收集合同，不能把正常S128验证冒充解决。Attention消费者自身仍按原head→tile→QK/SM/AV屏障与key顺序，不额外引入新的算术首错重排。

**后续决定：上述全请求失败次序建议未获采用。** A001在`m004-s128-source-static-adoption-rev15-20261015`明确修订15仅报告逐行阶段的局部错误次序；旧全QKV先于RoPE及head/window优先的全请求异常等价保持**UNRESOLVED/NOT_ACCEPTED**。原整模异常合同未改，正常链通过或已观察min key均不能关闭缺口；在完整模型错误接口集成前由主控集中解决。

### 同请求参考的可复用范围

| 保存依据 | 本次字节关联和限制 |
| --- | --- |
| [AT091同输入oracle目录](../project/E002_Laya_HLS/experiment/results/attention_rtl_repair_20261008/d2_cpu_full_official/oracle/B1_from_b0_S128/)的embedding_raw/norm | 各524288B；已核STATE0原0..524287字节全等独立raw，norm前四行全等task2_real_fixture_20 source。全128 raw/norm可逐行核；不能把encoder_00_out反推为保存了全部Attention中间值。 |
| AUX gamma及request | 当前aux offset128/4096B SHA `dfb0f4aa…`沿已冻结父身份；旧v4与当前request wire/build不同，但本次offset832的128个mask byte完全一致、72个1。实际绑定须用当前模型/请求身份，不能照抄旧55word的build标签。 |
| [task2_real_fixture_20](../project/E002_Laya_HLS/experiment/results/cpu_embedding_q8_validation_20261010/attempts/task2_real_fixture_20/work/fixtures/manifest.json) | 同request3/gen1，独立Q/scale、32group PS六字段、3072 pre-RoPE final/scatter只保存前四行；其余124行完整独立QKV/PS未在该夹具保存。 |
| [修订14两行派生FINAL](fixed_graph_support_20261014/rope_reference_rows01_20261015/run01/manifest.json) | row0/row1各全3072结果、Q/K步骤及原norm，manifest `979b1030…`。本轮只读字节，未重复求值。全128独立同输入RoPE FINAL仍缺。 |
| [t5_attention_fixture_01](../project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/t5_attention_fixture_01/work/fixture/manifest.json) | request3/gen1/B1S128/enc0/head0；q/k/v各32768B来自明确标为“actual producer BO observations only”的软件capture。其独立oracle score/shift/exp/prob各65536B、maximum/sum各512B、out32768B，覆盖128query×128key×D64；本次逐SHA核保存产品，没有运行generator。当前两行FINAL的head0 Q/K/V共384个F32与这些输入逐字节相同。 |
| 旧native B2 attention_fixture | raw/full_final各3145728B，但与当前独立pre-QKV不全同；score/prob/AV只覆盖batch0/1、head0/1、query0/112起各16行窗口。不能替代同请求全16head gold，旧P1也不混入。 |

t5的score/prob/out是**给定这些冻结捕获输入**的独立Attention参考，既非当前RTL结果，也非独立QKV producer参考。它足够做同输入head0消费者局部验证；将来同runtime真实生产全部128行时，必须先核其head0完整Q/K/V与该冻结输入一致，才可复用这些Attention gold。384项一致不能推全128一致；其余15head独立同输入完整Attention gold、所有128行独立QKV/PS/FINAL本轮未找到。全128软件capture可作来源/回放/观测对照，不能冒充独立gold或真实设备producer。

### 有限验收、成本与尚未完成的边界

下一段收益是把“外部TB直接stream”变为`真实STATE0/AUX AR/R→合法行准备→LN/Q/QKV→设备scratch/full RoPE→真实B/行完成`，并具备固定0..127行调度能力。优先用已有row0 cold/row1 warm全量checker验新路径及当前wrapper身份；短事务覆盖STATE0/AUX页界/有限AR-R停顿、后beat读错不启动core、不置位且可显式discard，以及row127输入地址/计数边界。边界peer只签地址控制，不签row127数值。两行完成仍无tensor发布；只有以后真正跑完128行才可签S128 producer。

只建议**一个预先封顶的真实入口pilot**：同一新编译快照运行真实cold→warm场景前缀，建议≤120s且设固定周期帽；先记录两reader的load/首末R/预装/真实core cmd，随后记录LN/Q/matrix/RAW/RoPE分段接受、退休和进度。未到warm或最终B就如实给prefix，不能动态加帽，也不从冷LOAD速率外推全部。现有工具展开依赖可复用同hash FP/leaf/IP闭包及参考，不为这段先重跑AT021全head、AT204 FFN或AT225旧wrapper基线；新core bank端口与wrapper控制仍需重新展开及受影响验证。

AT225原guard child0/null为791.796564s、peak981884KiB；日志两行成功全局点111837/195897及末195905，仅属旧wrapper、TB直接流输入，未给cmd握手不能称行latency/II。AT021同SHA Attention原16query pilot为66.621444s/949104KiB、198359 TBcycle；完整head为482.110123s/1108904KiB、1586807 TBcycle，QK/SM/AV首次done累计250888/265084/66256，LOAD140288cycle，均含其既定标量装载/诊断行为。Attention单head数据及接口证据可复用，但新的scratch装载/writer组合成本未知。禁止将791秒乘64、482秒乘16或按字节比作为新运行墙钟上界；也不以尚缺长仿真判硬件不可行。

消费者适配可先用t5全128 K/V的真实AXI存储peer做head0一个16query tile局部读→QK/SM/AV→写B验证，明确该内存是测试夹具而非新producer。最终同runtime串联必须等待真实128行全部成功FINAL，再读取实际写过的内存，不允许注入其余126行替代。第一段不接Attention命令口、不签完整Attention；全16head、norm后继消费、完整Encoder/模型、Host/HBM、联合资源及实际Fmax均开放。

本次[采样](fixed_graph_support_20261014/s128_final_attention_binding_time_20261015.txt)为0.11s/24928KiB/exit0，20s/1GiB保护、CPU0–3/nice19/idle；独立于工程预算，交互读取累计仍UNKNOWN。原静态/参考/失败记录不改，本次无EDA/HLS/OOC/P&R、模型求值、新gold、新代理或128行仿真。

### 修订15静态采纳与研究收束（2026-10-15）

A001已通过`m004-s128-source-static-adoption-rev15-20261015`在静态范围接纳本次交付，正式采用[真实入口合同](../results/m004_simplified_start_20261014/source_s128_connection_decision.md)（D-M004-SOURCE-S128-01；[SM004](../project/missions/SM004.md)）。主控独立核81项文件/窗口身份、30项保存字节/整数条件和6个head0窗口比较，全部一致；记录位于[既有机读审核](../results/m004_simplified_start_20261014/lnq_review_evidence_20261015.json)字段`revision15_source_s128_static_review`。其完整外层脚本0.22s/49080KiB/exit0，内部落盘前采样另列；研究原25项条件、0.11s/24928KiB及所有冻结依据保留，不将两方计量混记或重复求值。

正式接口采用`cmd_input_from_state0`及STATE0 base/span/epoch、独立STATE0 AXI512读口，源epoch等于tensor e；AUX沿完整BO描述符。接受外层cmd时一次锁存所有后续core字段，不能在预装期间继续引用caller实时字段。复用final_bank的8192B，以预装begin/严格顺序word-write/commit/abort和绑定id/row/epoch的单次token管理；commit须2048个实际bank写、两个本次load_done成功和全部holding债零。匹配prepared命令才消费token启动core，abort不得清已启动core的债。共享64B返回holding及至多两个32bit回放保持的新增payload上限为72B，控制另计；原bank/reader FIFO/leaf/writer容量均保留，非综合资源实测。新预装/回放和固定sequencer仍待工程验证，旧身份PASS不迁移。

固定请求仍为B1/S128/K1024/N3072，row0 cold、其后warm，首行begin、row id唯一且计数可表达退休128；固定入口强制RoPE，不增加两行成功模式。主场景明确为**固定128行生产器的row0 cold/row1 warm完整数值前缀**，只在两行outer done真实退休且全部已发债归零后结束TB，标记`PASS_SCOPED_REAL_SOURCE_ROWS01_PREFIX`；生产器仍有126行待执行，请求done/tensor FINAL不得提前发布或预填覆盖。输入descriptor/预装协议/读错使用status7、4bit phase14=INPUT、bad全1，原数值/RAW phase12/RoPE phase13及Check透传。非法初次begin不能破坏旧tensor，已准入输入错真排空、一次失败、sticky failed并停止后继行。共同reset仅沿受控双方和510拍隔离，独立总线reset及严格MUL已接受未返回窗口不借此升级。

本段**不实施Attention接线**。原55word协议、完整K/V/mask、ATT_OUT真实写B及norm保留继续作为后继依据。t5 head0参考及当前两行384F32关联获接纳，但软件捕获Q/K/V仍是消费者输入，不能代签126行实际producer或独立QKV gold；旧v4/current整包身份不同、124行独立QKV/PS、126行RoPE和15head完整Attention参考等缺项保持。没有新增参考求值委派；逐行错误仅属局部顺序，全请求异常等价仍UNRESOLVED/NOT_ACCEPTED。

A002独占实施，修订15新host300s/8GiB、static1800s/24GiB（单次600s）、RTL4800s/8GiB（单次2400s/1Mcycle，固定≤120s真实入口pilot计入），单重工具/CPU0–3/nice19/idle及MemAvailable>192GiB沿合同。修订14static1001.90892168506979732s、RTL1247.0794125087559535s与未用余额封存，不转移。不新增HLS/OOC/P&R、整模求值或agent。研究本轮静态准备已收束；本次仅同步采用/未采用边界，不重复hash、追加实验或发确认回信，待真实入口成本和工程结果再安排针对性研究。

## 修订15之后的S128完成、首错恢复与修订16接点增量（2026-10-15）

对应 `m004-s128-completion-error-order-continuation-research-20261015`。复用上节已核81项绑定及t5参考；新增[小支持记录](fixed_graph_support_20261014/s128_completion_error_order_20261015.json)只记录当前10份源码/合同身份、AT250/264四份guard及事件、整数工作量和反例，没有重算参考。当前core=`29db0515…`、wrapper=`d4856aee…`、sequencer=`b44b5563…`均与派发一致。以下是研究建议，未修改[修订16合同](../results/m004_simplified_start_20261014/final_attention_consumer_rev16_decision.md)，不构成新工程放行。

**正常S128生产可沿现固定sequencer继续；旧全请求首错不能只靠“RAW128后统一RoPE”恢复。** 当前wrapper没有独立RoPE入口，且更早的全LN、窗口量化/矩阵和完整RoPE表装载屏障也不同。最终只建议下述一条固定分阶段复用途径，保持原异常合同；当前正常链量测与修订16消费者工作可独立继续，不能据此签异常等价。

### 从当前接口完成真正128行及同runtime消费者

现sequencer已经固定0..127，首行cold、之后warm、每行接受真实done才前进；需要改变的是验证终点和后继资源交接，而非把模型改成两行。后继TB应从同请求STATE0原raw/AUX真实AR/R启动一次request，移除“前两行成功即结束”的checker出口，逐行保留准备token、W lease/read/release、core数值退休、RAW/FINAL真实B及outer done关联。QKV/norm目标内存从哨兵开始，绝不预装其余126行capture或预填位图。当前身份只有AT264单行正常证据；AT250连续两行属于旧wrapper `d8e52ea3…`，不能迁移为当前两行/128行通过。

在本版当前rows1调度下，可静态核算的整请求工作量是：128次实际行生产、每行12288 stripe，共1572864 stripe/12582912 lane-group提交；RAW QKV有效1572864B、norm524288B，32768笔64B写B；RoPE Q/K共131072 pair、1048576B写回、16384笔B。raw源524288B；当前每行重读gamma总524288B。这些是固定形状计数，不是周期或墙钟上界。检查每行覆盖只能由相应真实成功写响应和完成退休置位；RoPE行必须32个Q/K head段全部成功，V/norm从实际内存逐字节不变。

最后row127的真实B、行释放/core done、outer done和sequencer发布屏障均完成后，锁存真实FINAL描述符和request mask；生产器到消费者的reader/writer mux只在读FIFO/load、writer tile/flush/AW/W/B及算术债全零时换主，writer实际rearm后才能变路由。不得消费请求done就自动release复合tensor。随后用修订16的head0/query0..15真实消费实际写过的scratch；若其已测成本支持，再继续其余7个tile。读前逐字节核head0全128 Q/K/V与t5输入；不匹配即报告来源差异，不把t5数据覆盖回内存。通过时只能称“真实S128 producer→head0 Attention消费者限定串联”；16head、WO和norm残差尚未完成。norm epoch=e及STATE1内容一直保留至真正后继残差消费，不随Attention tile done释放。

无需新增gold时，验收必须分开如下事实：

| 范围 | 可签的事实及缺口 |
| --- | --- |
| 全128行raw/gamma/norm | 原独立raw/norm各524288B可逐位比较；gamma复用原AUX窗口。设备源握手和结果写回是实际链证据，不是板上HBM证明。 |
| QKV前4行 | 原`qkv_rows4_a8_q/scale/steps_u32x6/output_f32/scatter_u32x4`可核32组、全3072列及六字段PS；其余124行不能称独立QKV/PS PASS。 |
| RoPE前2行 | manifest `979b1030…`的完整FINAL/步骤可核，row1非退化；其余126行只可核真实读写守恒、地址、finite及覆盖，不能自动升为独立数值通过。 |
| 全128行head0与t5 | q/k/v各32768B为软件生产捕获，比较成立是来源一致性；给定这些输入，t5的score/prob等及out32768B是独立消费者gold。条件满足才复用，不能把它倒签为独立QKV gold。 |

为闭合同runtime **head0** 输入的独立性，建议的最小后续派生窗口固定为每行列`0..63、1024..1087、2048..2111`，覆盖真实S128；硬件仍计算N3072。父oracle保持未改SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`，调用已有`quantize_rows`/`q8_linear_full`及`rope_head`，按≤16行批次从已冻结独立embedding_norm、原Q8_0权重/scale和full AUX表求缺失窗口；Encoder0 QKV的bias_kind=0。先以保存前4行pre-QKV及前2行FINAL逐位校准，已有窗口不覆盖。需要PS诊断时只导出这192列的既有六字段，复用`make_real_fixtures.py:104`的独立算法与来源，不使用DUT输出。这只补head0来源，不补其余15head完整gold或全N错误ABI；**本轮未调用任何函数、未生成该派生参考**。

### 单一首错恢复路线：恢复原阶段屏障后原地RoPE

源码明确有四层顺序，不能只比较已经见到的错误：

1. `full_forward_controller.cpp:1756`先LOAD_GAMMA、完成全部embedding LN，再进入Encoder0 QKV。当前core每行LN→Q→矩阵，row0矩阵坏会抢在row1 LN坏之前。
2. 同文件`:1237–1280`每16行先完整QUANT，再LINEAR；`full_tasks.cpp:402`矩阵外层是n0按8递增，同一TN8内`q8_linear_owned_window_arithmetic`归并全部16行的row/column/group。row0 n8坏与row1 n0坏竞争，旧图选row1 n0，现逐行图选row0 n8。当前front的tile优先rank只作用于它实际收到的单行，不能补出未执行行。
3. `full_loader.cpp:193,302–349`的LOAD_ROPE先按cos→sin、position0..1024、d0..63读取并finite检查完整524800B，才发任何RoPE任务。未使用的position1024非finite也先于row0 RoPE算术报错；当前逐行仅读所用位置不能保持这一Check。LOAD_GAMMA的完整finite前检同理，不能拖到某行LN内部替代。
4. 全部QKV成功后，`full_forward_controller.cpp:1412–1444`和`full_tasks_attention.cpp:239–256`按head→16row窗口→row→Q/K调用原完整Check leaf，最后两shard一并转FINAL。原plane覆盖预检不是算术执行顺序。

因此推荐固定FSM为：`GAMMA_VALIDATE → LN_ALL128 → W_LOAD → {QUANT16 → MATRIX16/TN8}×8 → RAW_BARRIER → ROPE_TABLE_VALIDATE → {head→window→row→Q/K} → FINAL_BARRIER → ATTENTION`。仅一套原LN/Q/matrix/Check、两个既有reader和单writer，原scratch不增加整tensor片上副本。它是同一修复路线的必要阶段，不能只实现后半段便宣布原全请求首错恢复。

必要接口/生命周期改动如下，当前均未实现：

- **LN与Q解耦的窄入口。** `laya_lnq_row_v1`的`source_direct=1`目前硬定2624/82group，不能用它假装1024/32group。需增加固定LN-only及direct-norm1024入口，保留原FFN直接2624入口；LN-only输出用真实ready或已有bank提交约束流控。LN128结果写STATE1 HIDDEN并等真实B，norm随后只读直到WO残差。QKV W cold LOAD移到全LN屏障之后，保持原前置检查优先。
- **16行A窗口与真正TN8完成。** 复用20992B final_bank按相位保存16×1088B=17408B紧密Q/scale；量化阶段15行已存A加一行norm输入共20416B，矩阵阶段A加16×8 F32当前TN8结果共17920B，均在原容量内。此为字节容量论证；32bit同步bank的Q/16bit scale打包、端口仲裁和保持寄存器仍需实现，不能沿旧12288B整行结果占用方式同时存A16。front/core需窄的TN8/四行block微步骤与完整16行tile退休屏障，描述符仍K1024/N3072，四个block实际归并完本tile才进入下一n0；原group32非FMA恢复/poison保持。全矩阵完成计数不能通过config_n=8、清债或缩expected伪造。错误候选覆盖必须证明完整本tile16行已执行/合法poison退休；仅取任意已观察min仍不成立。旧完整窗口输出写入/传输错误的优先与本新微步骤需显式接回原task Check出口，不因提前部分写而提前返回或发布。
- **隐藏RAW到独立RoPE入口。** 现sequencer`:245`写死`cmd_rope_enable=1`；wrapper`:399`禁止已RAW发布的继续命令，且只从本行core成功进入RoPE。新增内部deferred-rope模式/启动事件、RAW全覆盖且债零的屏障；不能先外部发布RAW再撤回，不能release/rebegin以清位图绕过。begin时即保留e/e+1：RAW源及norm=e，FINAL QKV=e+1；失败discard=e、成功release=e+1均消耗e+1，下一begin=e+2，保留不回绕约束。外部只有完整FINAL发布，内部raw_ready不等于外部可读租约。
- **原完整表前检与有序变换。** 原AUX描述符/epoch在整个请求中只读锁存；先用原reader按cos→sin顺序真实扫描524800B并做原finite位检查，真实读完成后才进入RoPE。无需新三角函数或整表片上缓存；其后用当前小表保持重读相应row，AUX不可在此期间更换。head优先下若仍按每row小表重读，表有效读量为16×128×512=1048576B，另加前检，不能沿用旧逐行65536B计费。新增读错仍按真实总线排空处理，重读总线故障不能预签为原一次缓存装载的完整异常等价。
- **覆盖与资源归还。** 保留RAW row_written，RoPE增加确定的head/window/row/plane游标和唯一成功head计数；只有每row全部16head的Q/K真实末B完成才置row_final。严格顺序可用游标/每row计数，不必再造通用owner。Check leaf失败时停止后继逻辑任务，已发读/算术/AW/W/B真实排空后仅一次失败；V不写，norm不写。最后所有RAW/FINAL位及最后完成消费后才交Attention；切reader/writer前flush撤下、holding/FIFO/credit全零。外部返回必须保留原op/detail/bad语义，不能用phase13或重编码min key替代完整Check。

这一接法保留原数值次序的可实现结构；**当前不声称旧全请求Check已等价**。原owner/装载/输出传输错误的优先、重读AUX的总线错误与物理故障范围须在集中合同中逐项限定，再用有限双错事务验证。最少辨别样本就是上列LN-vs矩阵、同窗口Q-vs矩阵、row0/n8-vs-row1/n0、row0/head1-vs-row1/head0，以及position1024表finite-vs-row0算术；这些局部事务不需要再跑冷LOAD长前缀，且不能冒充整128正常链。

### 成本依据、一个有界profile及可并行准备

| 原attempt/身份范围 | static展开实耗 | RTL guard实耗 | 可用事件（均为TB全局点） |
| --- | ---: | ---: | --- |
| AT250，旧wrapper、固定sequencer两行真实前缀 | 145.561561s / 1889700KiB | 806.828120s / 983416KiB，exit0/null | row0接受1，W LOAD完成30153，row0通过116105；checker切row1为116107，row1通过204445 |
| AT264，当前wrapper、拒绝探针后真实row0 | 135.588641s / 1891980KiB | 455.914107s / 982864KiB，exit0/null | row0接受8，W LOAD完成30161，row0通过116116；输入2048word及邻域哨兵/384 B通过 |

AT250的`SOURCE_PREFIX_NEXT_ROW`是checker切换，不是第二个request接受；这些相减可描述日志事件间隔，不能称硬件II或纯LN/Q/RoPE latency。AT264 xsim另报CPU433.090s，与guard墙钟455.914107s分列。旧TB每500/5000cycle的采样只给状态范围，没有分阶段host时间，完整128、晚行地址/内存checker开销、当前SHA连续warm和新分阶段调度/表读成本均未测。原1Mcycle帽不能无声搬到完整128；固定工作量也不构成所需仿真cycle上界。

只建议**一次预先封顶的当前同版真实连续前缀profile**，交A001列入后继生产器预算：一个build、一次request，从row0运行到首个完整warm行退休或硬帽，以先到者停止；按AT250/264仅把900s作为待确定的profile硬帽建议，不保证两行能到。记录各真实握手的cycle及单调host时间：STATE0/AUX prepare、core cmd、LN/Q完成、矩阵首末issue/commit、RAW末B、RoPE表完成/首末leaf/末B、outer done和下一row接受；定期记录实际行数/债及同区间墙钟。若帽内不到warm完成，交付测得前缀和缺段，不动态延长、不按冷LOAD比例外推。它可取得当前正常路径冷/暖分段成本，**不能测出尚未实现的新阶段化路径、真实晚行128或消费者交接成本**；这些仍须新接口同版测量。工程修订16自己的≤120s消费者pilot独立继续，不挪本研究或修订15余额。

可立即并行准备的最小产物是上述分段事件表、窗口化checker开关/来源表、末行/FINAL屏障断言和共享mux的零债交接定义。复用同SHA的FP/IP及既有leaf编译闭包，只重展开变动的core/wrapper/sequencer/adapter；AT264即使复用依赖仍实耗135.588641s，不能把构建记零。完整128运行预算须由实际分段profile与工程成本出口确定；不把单行墙钟乘128、字节比或150MHz当保证，不据仿真慢否定硬件可行性。

### 修订16合同定向交叉核查

未发现需停止正常工程的实质矛盾。原服务SHA `11b7dff2…`的命令0/1/17/2/4/5/6/18/19/20/21、55word布局、S128/mask/full模式、CONFIG绑定tile内query、OUTPUT12的d索引与合同一致；`:41`的ap_ready确为REPORT退休。AV后必须RESET/rebind/reload，不存在无修改跨tileKV驻留；QKV ref为e+1、norm=e、service epoch独立，ATT_OUT确为独立域。保留两个实现约束：Q虽可随4096B流送18，最后reader的成功load_done/error屏障仍必须先于19；writer错误排空不能等待成功flush_done脉冲，只能依真实债退。服务错误1→6、协议/总线2→7及phase15仅是本消费者范围，合同也没有承诺旧全请求首错等价。

本轮字节/整数检查[完整外层采样](fixed_graph_support_20261014/s128_continuation_static_time_20261015.txt)为0.04s、16496KiB、exit0，20s/1GiB帽、CPU0–3/nice19/idle；交互读取累计仍UNKNOWN。链接核查0.06s、状态/导航2.70s、实际通信3.09s分列在小支持记录，四命令按外层采样精度合5.89s、峰36120KiB，均exit0，不挪工程额度。答复已delivered至A001，recipient turn=`01a13f4e-71cb-7c40-bfd3-32ef9870e68d`，导航无坏链接；送达不等于采纳或实现通过。无EDA、128行仿真、模型/新oracle求值、新gold或新agent；E002/E004及主控合同未修改。

## 分阶段生产器：三个接口的可执行静态细化（2026-10-15）

对应 `m004-staged-producer-interface-preparation-20261015`。A001已接纳上节顺序冲突的静态依据，本节只细化同一分阶段路线；尚非实施放行或完整Check等价。复用上节源码/参考身份，[小支持记录](fixed_graph_support_20261014/staged_producer_interfaces_20261015.json)新增7份依赖身份、复用1份row pipeline身份，16项地址/占有期/顺序整数检查全部成立。工程修订16独立继续。

### 1. LN-only、direct1024及原行模式的唯一编码

`laya_lnq_row_v1`把原一位`source_direct`改为两位`source_mode`；既有调用者接`{1'b0,原source_direct}`，未变数值叶子不复制。模式、row、gamma_kind只在`cmd_valid&&cmd_ready`锁存，busy期间caller改变无效。

| source_mode | 固定输入/动作 | 成功出口 |
| --- | --- | --- |
| 00 | 原LN→Q，1024字、32group，gamma_kind沿原0/1/2 | 原Q row_valid→同步group读→release→done |
| 01 | 原FFN direct2624，82group，gamma_kind必须0 | 原Q行接口不变 |
| 10 | LN_ONLY1024；本阶段只接受embedding gamma_kind=1；不启动Q、不装pack | 1024个norm真实bank提交及LN done后，保持done直到外层写B退休 |
| 11 | DIRECT_NORM1024，32group，gamma_kind必须0，不启动LN | 原Q行接口；读出并搬完1088B后release |

mode10新增`ln_only_valid/ln_only_ready/ln_only_last`，数据仍复用`norm_bits/norm_index`；valid独立于ready，阻塞时所有字段稳定。原`norm_valid`保留为实际LN输出握手的观察脉冲，不能拿它充当可阻塞valid。mode00忽略ln_only_ready，仍按原LN→Q打包条件ready；mode10的LN out_ready只来自真正可写bank的接收条件。直接模式的x_ready上限分别为2624/1024，groups/halves也按锁存模式分别为82/164、32/64，不能只改最后计数而仍让Q按82组运行。

增加`service_debt_zero`用于外层交接：必须没有LN待消费输出/已启动未完成操作，没有Q输入pack、真实Q read/slot/divider/mul/err元数据债，没有Q group同步读pending或rsp保持。Q侧直接使用现`physical_debt_zero`，不能以covered_groups代替。LN侧只有原状态机真实done被捕获、最后输出已握手才可算退休；cmd_ready还要求上一次done已消费。Q bank拥有权与算术债是两件事，mode01/11的row_valid不能因debt_zero就被覆盖。mode10不产生Q row_valid，不允许Q rd/release；只在ln_done成功、norm_count=1024、严格index/last匹配、债零后产生成功done，统计同原LN。错误保持原数值状态和位置，排空后done一次。

为使同一core可由外层固定FSM分阶段调用，建议增加窄的`cmd_exec[2:0]`：000=原FFN/QKV整行；001=LN_ONLY_ROW；010=Q16_FILL_ROW；011=MATRIX16；100=W_PREP_ONLY；其余拒绝。既有caller接000；新入口都要求原cmd_mode=QKV，K/N固定。W_PREP_ONLY只复用原LOAD_REQ/WAIT，不接LN/Q；它是把W LOAD放在全LN之后、Q16之前所必需的入口，不增加缓存或新加载器。新增`cmd_a_epoch[31:0]`只用于010/011：每个Q16窗口新epoch不回绕，在该16对齐窗口的**局部row0**初始化（全局row为0/16/…/112），后15行同epoch/同身份按序追加；MATRIX16消费完整匹配的窗口。`cmd_row`在001/010仍为全局行，在011为16对齐window_row0；bad的task-local行另算。A窗口在完成/失败真排空及该完成消费前不接受新epoch，也不接受会改写final_bank的legacy命令或其它prep_kind；W_PREP_ONLY只在A窗口尚未建立时准入。

准备端仍用原begin/write/commit/abort和11bit顺序index，增加固定`prep_kind[1:0]`，不开放任意bank写地址：00=原raw+gamma2048字；01=staged raw1024字；10=staged norm1024字；11=gamma初始化1024字。每种kind的物理映射见下表。token绑定kind/id/row/source epoch以及外层已锁存请求/模型；后续cmd_exec必须匹配。gamma初始化从原AUX真实读，按完整1024字finite检查，load_done成功、返回holding空和全部bank写才给gamma token；任何坏值都在第一条LN之前按LOAD_LN_PARAMS Check返回。原loader的bad为全1，gamma index只作额外诊断，不改原Check。gamma token及bank128..255跨128行保留，同一请求不可换AUX/model；每行只预装raw并回放原gamma，省去重复载入仍须正式实现验证。

**LN bank生命期**固定为：gamma前检→raw预装成功token→mode10接受→真实LN输出逐字写bank384..511→LN算术done保持→用现同步256bit结果读口读128tile→原单writer线性写STATE1 `base+row*4096`→64次OKAY B/4096有效字节、flush撤下及读/写债零→消费LN done、释放本地norm/raw区。不能在最后输出或最后W时释放，也不以LN done单独设置norm设备覆盖。B错则真实排空、保留失败和部分写隐藏；该行bank可在错误退休后复用，但绝不伪造成功B或覆盖。gamma只在全部LN阶段正常结束或请求错误排空后释放，Q16前不覆盖。

core的001结果视图直接复用原`row_valid/rd/rsp/row_release`，新增稳定`result_exec[2:0]`回显锁存的cmd_exec；此时仅允许rd_tile384..511（对应norm bank物理addr），wrapper将其译成STATE1行内tile0..127，不能把它当3072列QKV结果读。row_valid须在lnq.done_valid成功、1024次norm提交和service_debt_zero后置起，lnq.done_ready仍保持低；原row_release新增`discard`限定同第3小节故障上下文，真实release才消耗lnq done并产生core done。外层必须先满足64次成功B或真实故障丢弃条件才发release，core还核自己的同步读/rsp债零；不凭一个外部“已写”常量自行证明B。legacy模式的result_exec为000，旧caller的release_discard接0，原地址与成功条件不变。

旧LayerNormTask是16行先算后写（`full_tasks_front.cpp:130–205`），因此逐行提前写的错误也须按第4小节在**当前16行LN任务边界**结算；不能让row0的B错提前遮住同窗口row1的LN数值错，也不能越过失败窗口继续下一16行寻找其它错误。全部8个LN窗口真实成功后才给norm_all_ready并允许W_PREP_ONLY/Q16。

### 2. 20992B final_bank逐地址布局、同步端口和保持量

统一定义32bit word索引w，`bank=w&7`、`addr=w>>3`，八bank各656word。下列地址都是内部固定译码；绝不把旧Q8_0的34B group交错布局直接当本表的行布局。

| 相位/内容 | word地址与位布局 | bank/addr；有效期 |
| --- | --- | --- |
| LN raw，k=0..1023 | `w=k` | bank=k%8，addr=k/8；只占0..127 |
| LN gamma | `w=1024+k` | bank=k%8，addr=128+k/8；全部LN阶段只读保留 |
| LN norm结果 | `w=3072+k` | bank=k%8，addr=384+k/8；1024写及64真实B前不得复用 |
| Q16第r行Q字，g=0..31，j=0..7 | `w=272*r+8*g+j`；每word按小端装4个INT8 | bank=j，addr=34*r+g；r=0..15共4096word |
| 第r行scale，t=0..15 | `w=272*r+256+t`，低16=scale[2t]，高16=scale[2t+1] | bank=t%8，addr=34*r+32+t/8；共256word |
| 每次direct1024的norm准备区 | `w=4224+k`，字节[16896,20992) | bank=k%8，addr=528+k/8；只在Q16当前行准备/输入期间活跃 |
| 当前TN8的16×8 F32结果 | `w=4352+8*r+lane`，字节[17408,17920) | bank=lane，addr=544+r；Q16全完成后启用，每tile真实退休前保持 |

Q16总计4352word=17408B。前15行只到word4079，与norm准备区完全不交；最后行word4080..4351与norm交集恰为word4224..4351，共128word/512B。**所选实现不边量化边覆盖此交集**：每行先将1024个norm经真实握手全部送入mode11；原lnq内联82group Q bank收齐本次64half/32scale，**内部Q叶子**done已成功捕获且physical_debt_zero，pack空、lnq进入ROW后，才开始导出g0..31。这里不是等待外层lnq.done_valid：后者仍在row_release后才出现，等待它再读会死锁。此时1024个norm无一未读，现有Q bank仍真实持有完整1088B。导出后才release Q行。因而最后行覆盖交集无需依赖输出快慢或“读领先写”的推测。只有全部16行导出/scale pair写完和Q release/done真实退休，A16_ready才成立。

导出一个group时保留现Q rsp直到bank写完成：Q的8word同拍写八bank，BE均1111；偶数g的scale仅存到16bit `even_scale_hold`，奇数g在**下一独立写拍**把`{本次scale,even_scale_hold}`完整32bit写scale word，BE=1111。没有half-word RMW，也不依赖同地址read-first行为。每行32次Q并行写＋16次scale写＝48个bank写拍、272个实际word写；不能在奇数组Q写拍又写同一个scale bank。导出期间norm reader及标量回放停止，rsp_ready仅在本group最后写拍拉起；非法group/重复或缺失half/scale仍按协议错处理。

所有bank读采用统一保守协议：E0接受地址/owner并发同步读，E1把对应RAM q复制到保持寄存器并置rsp_valid，只有rsp握手后才接受下一读；地址/模式不能随caller改变。可以用现`tm4tn8_sync_bank_v2`的1R1W语义，但本首版每bank同拍只安排一次读或一次写，禁止同地址读写，也不靠综合器隐含多端口。Q输入复用原4B replay_hold逐标量读；A读依次对四行各取一次256bit Q，再取一个32bit scale-pair word，选half后用原精确half_to_f32，组成4×Q/sa保持。8次读都完成并匹配固定a_epoch/window/block/group后才允许一个matrix stripe；W到达先后不能覆盖它。

末group四个row pipeline可能同时返回，final_bank每bank不能同拍写四个addr。`commit_ready[3:0]`对需要写当前PS区的终组返回采用轮转one-hot仲裁，每拍最多退休一行的8lane；其它返回由原reserved_store保持，**不加四行payload FIFO**。前31组写原front各自PS bank，不争final_bank。每终组即使bad也登记该row_seen/坏mask；仅无bad的真实lane数据可写。全poison的final_skip只更新覆盖/坏mask，不能写假F32；多路skip/commit的覆盖更新先组合OR，避免多次NBA丢位。读取PS给writer只在四个block均已真实排空之后，与A读取/末group写互斥。

| 新增数据保持（本方案，非综合资源） | 净新增 |
| --- | ---: |
| 四行A Q保持由原a_q32B扩为128B | 96B |
| 四行F32 sa保持由原4B扩为16B | 12B |
| 偶数group FP16 scale保持 | 2B |
| 合计 | **110B** |

原64B source holding、4B replay_hold、32B bank rsp、34B lnq Q rsp、64B pack、2788B lnq Q bank、W保持和writer160B均继续复用，不另算成新增，也不抹去原容量。无新增payload FIFO/整行RAM；16×8 PS是在上述现bank内。控制另计：至少A行覆盖16bit、PS行覆盖16bit/坏mask128bit、a_epoch32bit、模式/准备token/计数、四block退休状态、持续的Check/rank及第4小节首个store错误记录；它们不能被110B当作“总新增寄存器”。

现`quant_a_row_bank_v1`是128group单行叶子；`quant_dual_a_v1`实例化2×16行、139264B且带owner/ref/acquire协议，不能把它无改动接到现lnq82group内联bank，也不能为了四行读口再实例化fullA。本方案只借用其“同步单pending、保持返回、读债零才release”的接口规则；真正A16数据来自现Q bank和final_bank。`matrix_resident`/portal/owner链不恢复。

### 3. full形状父任务与TN8四block步骤

现front只支持rows1/4，顺序为group→全部tile，`expected_stripes=G*T`；没有单tile返回或16行父身份。不能直接配置N=8。选择**扩展同一front的STEP16模式**，保留四套原row pipeline、原PS/metadata bank、Q35/trace容量和非FMA算术，不增算术实例。

| 接口/状态 | 固定定义与准入 |
| --- | --- |
| config | 新`config_step16`；config_rows扩为5bit。step16仅允许K1024/N3072/rows16、window_row0为0..112的16倍数；范围由N派生为tile[0,384)，不接受缩range的成功任务。旧模式仍只接受原rows1/4及原形状。 |
| step请求 | `step_valid/ready, step_tile[9:0], step_block[1:0]`，必须等于front保存的下一个(tile,block)。ready只在父配置有效、无未消费step响应及真实债零时成立。每step物理rowmask=1111，group固定0..31。 |
| issue | 既有tile/group/identity/version保持，sequence固定`((tile*4+block)*32+group)`，全父连续不回零；内部tag的2bit row仍为物理lane0..3，parent-local row=`4*block+row`。 |
| step响应/hold | `step_done_valid/ready`及锁存tile/block、accepted/row_retired/terminal_mask、numeric/protocol、first_rank/bad。ready未握手前不接新step，所有回显稳定。block3响应同时表示当前TN8归并完成；不另造“提前成功”脉冲。 |
| 父完成 | 新模式`task_done_valid/ready`保持原Check和真实累计；只有最后tile的PS退休/真实写B屏障后才能成功。旧模式原done/config重装行为保持，不因新ready让旧DRAIN漏掉done。 |

core固定循环`tile0..383 → block0..3 → group0..31`。每stripe从A16按block四行读q/scale；原W cache保持一次MATRIX16 lease，`read_tile=tile,read_group=g,read_pair=0`，K/N和task_context仍是完整parent。原W接口不限制group/tile遍历，实际held ret可直接复用；核slot/epoch/tile/group/model/numeric/context/mask后复制到原W保持，再发front。每stripe一次真实W read，重复四block读取，不添W预取缓存。每Linear16任务完成/错误后真release，槽留READY供下一窗口warm lease；不在block间release/reload。

step开始只在真实债零后将当前tile的lazy initialized/poison视图重新开始，g0读入PS=0、poison=0；不清RAM，不清正在使用的busy/credit来制造空闲。所有group仍由原dependency/busy和同步PS读保障；group g+1不能在所需前组PS提交前发射。block间复用四套物理PS位置，前block终组数据先进入final_bank的r=4b..4b+3四行区。相同tile不同block有不同全局sequence，快照/标签不复用成同一未退休请求。

| 正常计数 | stripe接受 | row-group真实commit＋合法skip | 终组覆盖/输出 |
| --- | ---: | ---: | ---: |
| 一step（4行×32group） | 32 | 128 | 4行 |
| 一个TN8（4step） | 128 | 512 | 16行×8 F32 |
| 一个16行N3072父任务 | 49152 | 196608 | 384tile，49152 F32 |

step_done条件同时要求32接受、128行级退休、终组mask=0xf，且entry_count/read_pending/preclaim/pretrace均0、所有实际result free=35/reserved=returned=0、trace free=4、无commit/trace保持、当前busy和snapshot已随真实返回清空。numeric不触发external_abort：即便block0已发现数值坏，仍执行本TN8剩余block并收齐其合法poison退休；block3后才决定原当前n0函数的返回。真正标签/读协议错立即禁新issue并沿原abort真实排空，错误完成可以有不足计数，但不得伪造normal full完成。

新增`ps_tile_valid/n0/window_row0/a_epoch`是当前16×8结果视图，不能复用旧3072/5248整行row_valid来混淆caller。复用原同步rd/rsp，staged PS读只准addr544+r（r0..15）；原整行读范围仍按旧模式。`ps_retire_valid/ready`回显parent/tile/epoch，只有无同步读pending/rsp且writer flush撤下/真债零才可接受；正常还须16个真实成功行段。它消费block3 step响应，才允许下一tile。数值失败的当前tile不发布结果视图，真实清债后直接形成task错误。

为避免第4小节store错误后卡在“16个成功B”的正常条件，`ps_retire`增加1bit `discard`：0仅在本tile全部16行段真实OKAY且写债零时退休；1仅在已锁存真实deferred_store、所有实际读写债零、当前tile算术成功及PS覆盖完整时退休。discard不增加B/written计数、不清deferred_store，仅释放PS区并推动下一tile算术；front/父完成一直保留store_failed，最终不可能成功。LN_ONLY也采用同一原则：外层将本行写入或有真实store失败后的丢弃退休记为不同事件，后者只允许释放bank并计算当前原16行任务内后续LN；不设置norm覆盖。非法discard或无匹配故障上下文按协议错排空。

本最薄写法每row一个32B TN8段：计算真正QKV shard/head/plane/row地址，原writer用固定路由的线性模式，output_base设该64B对齐beat、span64、tile_n0为0或8、lanes8；逐row flush，WSTRB仅该32B，B成功后换下一row。单tile有效512B、16笔单拍AW/W/B、物理1024B；全父6144笔B/196608有效字节/393216物理字节。这是明确的首版代价，不沿用旧整行连续打包的写数，也不是实测吞吐。A16在整个MATRIX16内只读，PS每tile复用；norm留在STATE1，不能再占本地Q16区域。

### 4. 原Check、提前写回故障和有限验证

原Check为status16/detail32/bad64（`include/laya_types.h`），op在TaskContext中。新staged完成带`done_op[7:0],done_check_status[15:0],done_detail[31:0],done_bad[63:0]`，原4bit phase仅作阶段诊断；不把32bit bad全1零扩展成原64bit全1。成功为0/0/UINT64_MAX。保留以下数值编码：

| 任务 | op / 数值detail | bad_element |
| --- | --- | --- |
| LN_EMB | 0x10 / 0x0710000f | 当前原16行LN任务的r×1024＋叶子列 |
| QUANT | 0x20 / 0x0720000f | 当前Q16的r×4096＋Q first_bad_col，不能改成r×1024 |
| LIN_QKV | 0x30 / 0x0730000f | `(4b+r_phys)*5248*128+(8t+lane)*128+g`；是task-local行，不加全局window_row0 |

矩阵归并key为`((((t*16+r_local)*8+lane)*33+g)*5+phase)`；它是遍历比较键，不是对外bad。原数值phase保留作诊断，同一位置多子步骤按原较早phase。每block先归并其全部合法返回，四个block累计候选只在当前TN8完整后定案；若numeric则返回该tile的原Check，不执行下一n0。完整本tile的候选空间是真正执行/合法poison闭合的，不是随便取观测子集min。原矩阵返回标签/phase/summary错误沿`7/detail(7,0x30,5)=0x07300005/bad全1`，不把它混为数值bad；协议真实排空的较少计数保留。

**提前store错误使用独立的deferred_store记录，绝不直接接front abort。** 首个实际AW/W/B/目的地址故障锁存{valid、phase、route、tile、row、response、实际ordinal}，保留已展示AW/W并排完B；写债全退后禁止后续写，但继续原当前算术任务必须执行的步骤。后续正常PS只能明确discard，不设置written/B成功计数。LINEAR16中先让原按TN8顺序的数值/算术协议Check定案：若某后续tile数值坏，原图在任何输出写之前会返回它，因此该Check优先；若384tile算术均成功，才返回deferred store错误。LN阶段同理，但只继续当前原16行LN任务，不能越过该任务边界。故障后不会发布RAW/norm成功，A窗口仅在计算/存储真实清债和错误完成消费后释放。

staged物理适配统一建议把最终store故障映射为status7、`detail(7,当前任务op,5)`、bad64全1，并另保留原scratch phase/route/response/ordinal。这是**待A001采用的物理错误映射**，不能声称CPU原实现具有BRESP oracle或任意总线故障已等价。若A/W源返回缺失或标签错，继续计算已无真实操作数，应按原真实abort排空并报计算协议错；不得用零填补以完成候选空间。身份/地址准入尽量在任务首部完成，旧owner/ref/前置Check仍按已有合同保留。

最少受影响验证可在无冷载长前缀的合法局部环境完成，工程另立预算后运行：

- **模式/端口**：既有row0/1 norm→mode11的Q/scale逐位比较；mode10用原gamma/raw核同norm，LN输出/同步读/末B分别有限反压，done不能早消费；mode00与01沿未变gold做短兼容。16行bank控制用这两行交替复用，明确只有两种数值输入，不声称16个新独立样本。gamma坏值前检要在任何LN/Q启动前失败。
- **bank安全**：r14到r15交接、g0/1及30/31 scale配对、norm末字受阻、Q done但group rsp未消费、四个终组同时valid、全poison skip。断言未消费norm不被写、同bank不双写、PS/A不交、ready低时全部返回字段稳定、release/read竞争不丢债。现整数证明只证明方案映射，不代替这些RTL测试。
- **可区分的首错事务**：真实STEP16 front＋原row pipeline/FP，A/W用合法同步held-response peer，完整K1024/N3072/rows16描述符。预置故障计划A[row1,g31].half_scale=0x7c00，W[tile1,g0,lane0].half_scale=0x7c00，其余取已有合法有限payload；全部身份/sequence/ready正常。这是受控数值坏数据，不是协议错或自然模型样本。期望tile0的四block全部真实退休，返回LIN_QKV数值6、bad=671775；不得发tile1，尽管其row0/n8的bad=1024数值更小。再移除A故障，必须实际退休tile0后读/执行tile1并返回bad1024。移A故障至g0可在同局部集覆盖后续poison与final_skip，不许伪造terminal。
- **算术/写错优先**：tile0真实末B错，tile1按上述W坏scale返回6/bad1024，B错误诊断仍保留、无RAW覆盖；仅B错而算术全正常的父级控制，可用清楚标为替代算术的合法step peer走完384×4×32握手验证最终7及计数，不能签完整矩阵数值。实际W返回标签错另作短abort，检查保留/返回全部真债。

必须修改的生产模块仅为：`laya_lnq_row_v1`模式/真实norm ready/debt出口；`laya_lnq_wi_gqdown_row_v1`固定cmd_exec、prep译码/A16/PS bank仲裁、父Check及store故障延后；`tm4tn8_sync_ps_front_v2` STEP16配置/步进/完成；原scratch wrapper及S128 sequencer的固定阶段驱动/PS写B及完成桥接。现caller显式接legacy模式，原冻文件不动。`quant16_stream_row`、LN算术叶子、row pipeline/FP/tag、W cache/reader、writer算术与存储本体无需为此改数值或容量；内部复用端口的仲裁接线仍属新实现，不能继承原top PASS。fullA、matrix_resident和通用owner均不接入。

本轮静态脚本[外层计量](fixed_graph_support_20261014/staged_producer_interfaces_static_time_20261015.txt)0.07s、22600KiB、exit0，20s/1GiB保护，CPU0–3/nice19/idle；历史及本轮交互读取累计UNKNOWN。未启动实现、EDA、900s profile、模型/oracle/gold求值或新agent；后继接口与工程预算仍由A001集中定案。

本增量已通过`m004-staged-producer-interface-preparation-answer-20261015`直接送达A001，回执为delivered、recipient turn `01a13f69-2d56-7e30-ad87-4d03ab3f094f`；表示消息已接受，不表示设计采纳或工程通过。四项已结束采样（静态整数、交付检查、状态/导航、发送/导航）合计5.64s，分别保存在同支持目录；末次登记计量另见[closeout receipt](fixed_graph_support_20261014/staged_producer_interfaces_closeout_time_20261015.txt)，未计入上述四项合计。交互读取仍UNKNOWN。

### 修订17部分采纳与本次研究收束（2026-10-15）

A001通过`m004-staged-producer-rev17-partial-adoption-20261015`接纳上节第1–2节的本阶段子集，正式依据为[D-M004-STAGED-LNQ-01](../results/m004_simplified_start_20261014/staged_lnq_frontend_rev17_decision.md)及[SM004修订17](../project/missions/SM004.md)。主控报告已核8份模块/类型依赖、2份完整raw/norm身份及12项映射/容量/合同条件；研究本次仅同步采纳状态，不重复hash或新增实验。A002继续独占工程实现，研究交付收束，无需确认回信。

本段生产实现限于真实gamma完整前检→STATE0逐行预装→LN_ONLY1024→STATE1真实写B→完整128行内部`NORM_STAGE_READY`，以及同core的DIRECT_NORM1024/Q16紧密bank入口。正常全LN128先于Q16及W冷载，局部Q16生命周期验证不代签父图W准备或矩阵消费。仅cmd_exec000/001/010可执行；011=MATRIX16、100=W_PREP_ONLY及其它编码明确拒绝，不能以预留编码置成功。STEP16、其四行A保持、6144笔父任务写回及矩阵全父Check仍为后继设计；原110B净payload估算中108B属于四行A保持，不能把整项当成本修订已新增或实测资源。

**正式接口覆盖上节建议中的一处索引表达：** 修订17的LN norm结果对外使用逻辑tile0..127，由core映射到物理bank addr384..511；上节提议直接暴露rd_tile384..511保留为历史方案，工程执行以本逻辑索引为准。result_exec=001、真实同步返回/保持、64次成功B和release/core done屏障不变。Q导出等待内部Q叶子完成且lnq进入ROW，外层lnq.done仍在导出/release之后；故障discard仅在匹配真实store错误上下文且全部实际债零时合法。A16_ready须全部16行导出/scale写/Q release及done退休；新增受控a_window_release/discard只签拥有权生命周期，不签未来矩阵消费。

修订17新预算与自动长例条件由正式合同管理：同版16行窗口pilot≤120s、满足保守估计及剩余预算条件后自动运行LN128；研究没有启动该pilot或长例。LN128若通过也仅签131072个norm及8192笔真实B对应的内部阶段；request_done、RAW/FINAL、Attention和完整模型仍未完成。全请求首错等价、完整生产器及联合物理继续UNRESOLVED/NOT_RUN，原静态检查与历史交付不升级为生产PASS。后继STEP16/完整RoPE表前检/FINAL交接由A001继续定案。

## LN128仿真成本的定向静态核查（2026-10-15）

对应`m004-ln128-simulation-cost-static-research-20261015`。本节结论是：**先对同一真实生产层次只切换xelab高级优化做有界A/B；源码最值得怀疑的是未接收事务但仍自由运行的G/tanh及RoPE内部FP，尚不能把它签成实测主因。** 不改变数值、AXI或检查，不由两次不同工作量的墙钟推128行上界。当前冻结core39b3bf4b…/wrapper5c88716f…/sequencera4c999e5…/LNQ52cd1070…已与派发和原manifest匹配，AT300与AT297的LNQ叶子逐字相同；[小身份/命令依据](fixed_graph_support_20261014/ln128_simulation_cost_20261015.json)记录31项定向文件/工具身份、5份原guard和选项出处，未重核全历史。

### 已测端点与三个可区分的成本来源

AT297展开139.830300s/1881732KiB，RTL guard120.449776s/950356KiB，timeout/child−9。日志row0/1退休点15375/29462；末计数gamma256R、source192R、norm2048、B128，source192包含row2已预装，只有128R属于两行已退休输入。AT300展开61.126108s/688276KiB包含两个leaf snapshot；mode00旧例21.640224s/863072KiB，五正常/四错/reset，终仿真时间798980ns；direct2624另为7.787498s/863300KiB、cycle3786，不能把它并入前者或说成同链加速比。AT297包括固定sequencer、真实reader/writer和外层bank回放；AT300直接给leaf输入、没有该AXI链。两者构建、实际仿真周期和host墙钟分开记录，均无硬件Fmax结论。

以下源码路径相对AT297的`frozen/`；行号和SHA在小记录对应文件可查。

| 来源 | 已证源码/命令事实 | 尚待同版测量的假设与辨别 |
| --- | --- | --- |
| 1. 非活动算术层次仍有时钟事件 | core`:755–794`的exec001在LN成功后走LN_NORM_VIEW，未走LEASE/FRONT；Q的start有`!ln_only_mode`，G issue只在G_SEND，RoPE start只在R_LEAF_START，所有这些实例仍接共同clk/rst。`geglu_canonical_core:4469–4514`及`tanh_libm_canonical:6075`附近把算术ap_ce固定1，valid只标记结果；源码分别4479/6060条posedge always、9/42处literal ap_ce=1。矩阵`:93–112`的FP valid受valid_a/c/add控制，ADD aclken=1，其元数据写多有valid保护。RoPE外层ap_start虽为0，`rope_head…LOOP_25_2.v:307,322`内部两FP仍ce=1，其wrapper将a/b_tvalid固定1并用延后一拍ce_r驱动aclken；外层未启动不等于内部IP时钟停止。 | H1：G/tanh及部分RoPE自由运行路径显著增加大层次每周期成本。上述是源结构和真实enable条件，**不是运行事件数或耗时占比**；xelab可以合并always，不能把10539条声明乘周期算CPU成本。矩阵valid为0也不能证明厂商模型无时钟进程，更不能把每个FP按相同代价计费。 |
| 2. bank端口、组合敏感集及控制唤醒 | final_bank读写受prep/feed/norm/read_pending/commit等条件控制，未见每周期扫5248word；PS bank只有rd_en/wr_en才访问，W bank受fill/read_accept控制。reserved_store的656 busy初始化在reset，front清位在reset/config，均非LN每周期整RAM清扫。Q32槽债扫描存在，但同Q也在AT300；组合always按敏感信号变化触发，不能等同每周期执行。真实LN128还有标量bank回放、gamma/raw准备和64笔写响应的必需周期。 | H2：大层次持续控制/宽组合及RAM敏感集的编译唤醒成本有贡献；不能仅凭bank容量归因。没有event/process profile，贡献UNKNOWN。实际AXI和回放占用的硬件周期必须保留，不能作为“仿真冗余”删除。 |
| 3. TB/输出与构建优化 | 两者均2025.2，`--relax -mt off`及相同五类库；原命令无显式高级优化或debug参数。AT297 build_pilot只重编sequencer/TB并对既有work库展开；xelab.log仍引用AT290 core/AT280未变依赖路径，因此复用必须绑定实际库闭包。pilot每5000cycle打印一次进度、每行一次退休；逐F32检查在真实W握手，最终131072word内存扫描只在阶段ready后，timeout前未执行。无显式log_wave/dump，work根未见已生成wdb，不能因kernel命令含-wdb便认定全层次波形记录。 | H3：高级编译优化可减少静态调度/过程开销，收益UNKNOWN。日志不是当前已证主因；构建多线程只影响编译子任务，不能把`-mt 4`当运行期并行。AT300五行更多事件但较短墙钟是调查线索，不是同输入/同层次性能对照。 |

### 唯一优先试验：同源码/同checker，仅xelab增加`--O3`

支持依据来自本机2025.2的**静态读取**：xelab原程序SHA`7246d8d7f7106391f75ebb894d05c59367d4ced037976ed4bc646fe7c8bdc50d`的帮助/选项区含`Enable advance optimizations`和布尔键`O3`（字节34421709），并明确单/双dash可用；因此建议写`--O3`，**不把未核语法`-O 3`当同义形式**。默认帮助还说明已有常用优化、unused removal和always组合默认开启，不能把基线说成“零优化”。高级开关具体启用的全部优化清单、动态CLI接受及收益仍NOT_RUN/UNKNOWN。本轮没有调用xelab帮助或任何EDA程序。安装脚本`xsim/register_options.tcl:55`明确mt为sub-compilation jobs；`sim.tcl:2734,2978–2980`支持-tclbatch及有限时间run。

工程获主控对应预算后，只做这**一组默认/O3对照**，不同时换工具、源码、TB、reset、IP模型、时钟或日志策略。采用AT297相同work库/IP闭包、同一冻结pilot TB和fixture；可复用身份确认的默认snapshot，新建不同名称的O3 snapshot。优先复用同SHA已编译VHDL/Verilog库，不重做HLS/IP生成；若库身份不可追溯，按原文件清单重编并把真实构建成本单列，不能把拷贝snapshot称新展开。

新增elaboration的完整核心参数为：

```text
xelab work.laya_staged_ln128_pilot_tb -L xil_defaultlib \
  -L floating_point_v7_1_21 -L unisims_ver -L xpm -L secureip \
  --relax -mt off --O3 -s staged_ln128_cost_o3
xsim <默认或O3的snapshot> -testplusarg FIXTURE=<AT297原fixture> \
  -tclbatch <同一个有限前缀脚本>
```

同一个脚本仅`run 300 us`后`quit`，每臂固定墙钟帽建议≤120s，由A001定预算，不能运行中延帽；300us按原10ns TB时钟覆盖已观察的第二行29462退休点，并非128行性能推演。保留全部原生产assert/finite/Check和原TB层次引用、W逐字gold/地址/债/不提前发布检查；不加SYNTHESIS宏、不关assert、不强制idle/valid、不删G/RoPE实例。这是仿真器代码生成优化，预期保留SV/VHDL可观察语义、FP逐项非FMA结果和时钟周期；本静态核查不代替对优化后事件/字节的实际比较。固定前缀停止不伪称TB完整PASS；128行后的最终内存检查仍在原TB，仅本前缀未到。若优化造成层次引用不可用或观测不一致，判该臂失败，不能删checker使其通过。

两臂记录独立build墙钟、固定前缀run墙钟/CPU/峰RSS及row0/1退休cycle、gamma/source/norm/B、checker实际命中；只在同模拟终点且上述事件/字节一致时报告仿真成本差。若任一臂触帽，只比较共同完成事件及明确缺段，不由不同前缀wall ratio算加速比。AT297原120s日志不能直接充当300us默认臂精确计时。即使O3在帽内更快，也只签该前缀和该编译设置，完整16行/128行的长例条件仍需真实窗口计量。若不能可靠建立选项/闭包身份，则本试验可执行性为UNKNOWN并交主控，不在研究侧试错启动工具。

### 必要时唯一结构备选：抽出实际共享的生产前端阶段服务

若上述编译设置不足，建议把**现有唯一LNQ、final_bank、prep/token/回放、原STATE0/AUX reader与norm writer阶段**抽成一个实际生产子模块，由完整父top实例化一次，固定LN128 sequencer调用它；矩阵/G/残差的bank访问经原相位互斥的窄端口接回。此为未来生产层次重构，当前不实施。子模块独立顶层仿真也必须经过真实source/AXI写B、完整原算术/checker；禁止fast leaf、保存norm/Q替代producer或为仿真删减内部检查。

端口必须保留cmd_exec/source_mode、id/row/model/numeric/source/destination/a_epoch、prepare begin/write/commit/abort、norm result_exec/同步读rsp/release-discard、A16_ready/window_release和完整Check；对legacy增加固定相位的同步bank读/写请求及返回，不开放通用owner/portal。物理bank与LN/Q均只有一份，矩阵/G/ADD在legacy相位仍读写这份bank，不复制payload或第二LN/Q。切相位需source FIFO/holding、LN/Q物理债、bank pending/rsp及writer tile/flush/AW/W/B全零，并正确保留gamma/A16等拥有权；idle不等于允许覆盖有效内容。

保持同一自由运行clk和共同reset，不新造组合门控时钟或在事务在途时停钟；这条备选通过合法生产子模块边界减少LN阶段验证展开的无关层次，**不承诺旧完整父top同runtime仿真也自动加速**。原legacy输入、同步读延迟、反压、释放/复位隔离、bank arbitration及跨mode重入均受影响，应有限回归；层次路径变动时只机械重绑定checker、不删检查。LN128子模块通过也不代签父top的完整串联/首错等价。是否采用及新预算仍由A001集中决定。

四项本次静态工具字节/整数脚本累计1.74s、峰121712KiB、exit0，均≤20s/1GiB且CPU0–3/nice19/idle；原计量在同支持目录，小记录列出路径。交付工具成本另列，交互读取仍UNKNOWN。本轮未更改E002/E004/生产RTL，也未启动EDA/HLS/RTL/OOC/P&R、模型求值、新gold或新agent。

本成本增量已直接送达A001：`m004-ln128-simulation-cost-static-answer-20261015`，回执delivered、recipient turn `01a14005-3f45-7c72-85ee-478223250932`。静态四项与交付/状态/发送已结束六项脚本累计7.48s；末次登记另留[原计量](fixed_graph_support_20261014/ln128_cost_closeout_time_20261015.txt)，不混记交互读取。送达不等于试验已授权、已运行或优化有效。

## LN128实际生产服务抽取：固定切口与端口（2026-10-15）

针对 `m004-ln128-production-partition-interface-question-20261015`。本节只有设计，未改RTL/时钟/数值，也未运行工具试验。起点为修订18 core `a73632b8a85fae646b36c0355065b19a5f91b4067440c5f96f14726726197e54`、wrapper `5c88716f…`、sequencer `a4c999e5…`。三者完整身份及另五项直接依据见[小记录](fixed_graph_support_20261014/ln128_production_partition_20261015.json)。AT304/305的93.291409s/89.642302s及AT306仅退休两行沿工程原报告引用，不重审成本、不外推128行。

### 唯一推荐切口：两个共享生产模块，保留重计算执行器

单独抽出LNQ不够：prep/final_bank在core，实际source/norm读写在wrapper，128行及16行错误屏障在sequencer。推荐**下层 `laya_lnq_bank_service_v1`（建议名）＋上层 `laya_source_norm_service_v1`（建议名）的固定组合**，两者都由原父top真实调用；不为独立测试另写调度/总线实现。上层通过下述端口调用下层，完整父图中这条连线可经原core外壳透传；独立LN阶段直接连接同两模块，毋须例化重执行器。具体职责只有一份：

|来源|移动到共享服务|保留在原父控制/重执行器|
|---|---|---|
|core|下层拥有唯一`lnq`实例、`final_bank[8][656]`；prep/token/gamma身份、FEED replay、`norm_count`、LN-only视图、Q16读/pack/export/release及`q16_next_row/cover/window_*`；同步结果pending/rsp；下面明确列出的G读保持与ADD bank操作数保持|W cache、front/matrix、G/ADD叶子、skip_bank、W lease及LOAD/issue/drain、matrix覆盖/poison/首错、G credit/cover/finite、ADD计数/finite、完整legacy结果发布判断。移走原bank/LNQ定义，不留第二份|
|wrapper|上层拥有现有两reader和单writer及其所有AXI路由；`IN_*` source/gamma FSM、512bit input_hold、raw/gamma计数与done_seen；norm的SEG_PREP/READ_REQ/RSP/FLUSH/UNFLUSH/错误排空/RELEASE/Q_DONE分支及成功B计数；staged norm位图、store fault与描述符锁存|FFN/QKV行交接、QKV 48head+norm分段控制、RoPE表/head/leaf调度和实际RoPE叶子、RAW/FINAL发布及原e/e+1合同。它们成为同一reader/writer的固定客户端，不能再例化reader/writer|
|sequencer|上层移动原`q_staged_ln`对应的S_SEND/S_ROW/S_STAGE_READY、`retired_rows/base_id`、16行`drain_store_window/store_error_*`和完整Check保持；staged请求原描述符检查一并移动|legacy QKV/RoPE请求调度及S_PUBLISH。staged分支只代理上层请求/结果，不保留第二个128循环或第二份norm覆盖|

原core外壳对`cmd_exec=001/010`直接交下层并返回其result/done；`000`仍走原重FSM，但LNQ和bank访问改为固定下层端口。legacy命令只有重FSM和下层同时准入才发生一次握手，不能先接一边。原wrapper/sequencer的staged外壳同理代理上层；需要改现例化接线和层次checker路径，不是旧端口零改动。仅旧模块名或空壳留着不能证明复用：工程须列完整父图与独立阶段的同模块/同源SHA，父图只能有一份LN、一份Q和一份20992B final_bank。

独立验证只把**未被staged模式使用的固定legacy/G/RoPE客户端置空闲**，并断言整个请求没有向它们发命令；不能补done、强清债或跳过服务状态。该边界是生产可调用的LN阶段，完整父top仍例化原重算术；抽取不会自动加速原完整父top仿真，独立LN128也不代签父top同runtime。

### 下层固定端口及每一种bank访问

保留现`prep_begin/write/commit/abort`整组宽度和身份：kind2/id32/row7/epoch32/model3328/numeric672/AUX base/span64；write index11/data32。保留`cmd_exec3/mode1/row7/source_epoch32/prepared`，并在实际握手锁存，不以live输入改路。下层只接受现000/001/010，后继MATRIX16编码继续拒绝。

`001`由下层完成原LN_CMD/LN_WAIT/FEED、LN_NORM_VIEW/A_DONE/DONE；`010`完成原QD_CMD/READ/SEND/WAIT、Q16_REQ/RSP/WRITE/SCALE/RELEASE/A_DONE/DONE。`000`锁住legacy事务后，父FSM以**原LNQ命令/stream/group-read/release/done端口**驱动一份LNQ：source_mode2、gamma_kind2、row16，x/gamma32，group7，q256/scale16，status4/bad32/三个统计32。prepared replay与direct2624 bank replay在下层完成；父侧原QD_READ/SEND不再另读bank。矩阵A_REQ/WAIT仍取得同一LNQ行，A_RELEASE/A_DONE仍真实退休后才能转G/ADD。无跨层异步读或额外量化副本。

legacy命令存活期间用父FSM译码的固定`bank_phase[2:0]`（NONE/MATRIX/G/DIRECT/ADD/RESULT）限定下面各端口，不建可编程owner表。阶段切换必须等原W/front/G/ADD债及本层pending/rsp退完；仅把phase换掉不构成排空。bank全部访问落在下层一个时钟过程/等价明确端口结构，保持现读写语义：

|访问与原core行号|固定端口/移动的保持|地址、接收边界与并发|
|---|---|---|
|prep写535、raw/gamma replay558/570|原prep握手；`replay_hold32`和FEED状态移入|raw w0..1023；gamma w1024..2047；norm prep w4224..5247；w→bank=w%8,addr=w/8。prep只在下层IDLE、token/窗口允许时写；replay读拍后保持至LN实际ready|
|LN norm598|LN真实`norm_valid/index10/bits32`在下层内部提交；LN-only ready沿现条件|norm w3072..4095/addr384..511。原norm_valid是实际输出握手观察脉冲，不另造ready。LN_ONLY必须1024提交、FEED_DONE及真实LN done才开视图|
|Q16写954–968|`q16_bits256/current_scale16/even_scale16`及pack状态移入；不新增payload|Q w272r+8g+j，scale w272r+256+g/2；每组八bank并写，奇数组另拍单bank写完整32bit scale pair。内部Q成功进入ROW、全部1024norm已消费后才导出；r15交集512B不会覆盖未读输入|
|matrix末group620|`ps_store_valid,tile10,data256`，无新增返回反压|父侧保留原last_commit、tag/范围/重复、`mask\|bad==ff`和覆盖计数；仅bad=0发送写脉冲。该脉冲在MATRIX相位同拍写八bank。现commit_ready=4'hf，不能在新边界随意拉低ready或吞掉脉冲|
|G读891/897、返回644|`g_x_rd_valid/ready,tile9`；`g_gate_rd_valid/ready,tile10`；`g_x_hold256/g_gate_hold256`改由下层寄存输出；`g_store_valid,index12,bits32`无ready|每次读八bank；返回一lane。x tile0..327，gate328..655，返回addr0..327。保持原G_R0对`g_commit && returned/8==g_tile`暂停及bad进入G_DRAIN；gate与返回地址不重叠。**G合法地可在同拍同bank不同地址1读+1写**，不能用“全程单端口互斥”代替，更不能阻塞无ready的G返回|
|G→Q direct915|下层QD_READ/SEND、`qd_word32/index12`|按index读w0..2623；只在2624 G结果/credits/cover真实全退后开始。Q16同一路replay改读w4224+index；不增加整行FIFO|
|ADD读993、写1025|`res_rd_valid,index10`→下层`res_b_hold32`；`res_store_valid,index10,bits32`无ready|RES_READ读windex；父侧保留skip读`res_a_hold32`和ordinal，下一RES_SEND实际接受ADD。仅父侧真实合法、finite ADD消费生成写脉冲。RES_WAIT与RES_READ互斥，保持最多1项在途，不新加32credit调度|
|外部同步读603/1044/1052|原rd/rsp：tile10、data256、valid/ready；`read_addr/logical/pending/rsp`移入|legacy RESULT逻辑tile同物理addr（QKV0..511、FFN0..127）；LN_ONLY tile0..127映射addr384+tile。E0接受索引，E1寄存八bank数据及logical tile；rsp阻塞时字段稳定，不再接读。release优先禁止新读，但要等pending/rsp为空|

G/ADD的专用读保持沿原时序：在G_R0/G_R1/RES_READ的采样沿直接读取bank并更新对应输出保持，下一状态使用；不是额外加一层“先收地址再返回”的通用总线。外部结果口则保留上表E0/E1的原两状态节拍。G的两组保持64B、ADD bank保持4B、replay4B、qd_word4B、Q16保持36B、结果rsp32B均从原寄存器**移动**，不是新增缓存。原LNQ内部pack/quant bank保持唯一。八bank必须容纳原G的同步1R+1W，不能为抽取悄悄复制RAM或改read-during-write规则；相同地址读写由原G_R0互锁避免。资源映射尚未综合，不把20992B当新综合结果。

`result_mode/exec/row`和完整Check在视图/done保持期间稳定。下层staged done保持status4/phase4/op8/check_status16/detail32/bad64及bad_element32；legacy仍由父FSM归并原首错。新增固定store端口不负责重新定义poison/finite优先级。下层提供`bank_io_idle`（无pending/rsp/导出写），LNQ复用其真实cmd_ready/row_release/done与内部physical_debt_zero条件；不以一个可写idle位替代叶子债。另需固定`legacy_end_valid/ready`：只在父DONE实际被消费者接受且下层LNQ/读写均已退休的同一次握手释放legacy锁，父DONE与该ready合并退休，不能在矩阵完成或结果读完时提早开放prep。FFN skip仍由父侧观察原x_valid与下层真实x_ready的握手保存，不新增skip副本。

### 上层实际I/O归属与阶段生命周期

上层移动现`t4_w_reader_port_v1(SCALE_MODE=0)`和`t4_aux_bias_reader_v1`两实例、原reader FIFO及单`tm1tn8_axi512_writer(SHARD=0)`原160B payload。STATE0、两QKV读路、AUX物理输出和三路QKV0/QKV1/STATE1 AW/W/B都只由此上层驱动，W0/W1/scale三路读仍归重core。保留现分段与4KiB处理、64B单拍writer，不能退回AT097跨页实现。

跨上层边界只需以下固定客户端，全部在请求握手锁存描述符，等待期间保持，且不得与staged LN占有同时获准：

|端口族|确定语义|
|---|---|
|staged请求/阶段持有|原request握手和原描述符整组（base_id、epoch/model/numeric、STATE0/AUX/STATE1及原校验所需字段），不削弱旧descriptor_ok；上层单独锁存并循环128行。输出norm_written128、norm_stage_ready，以及原失败done完整Check；正常stage ready不是request done|
|legacy source预装|固定`source_row_valid/ready`＋row/id/epoch/STATE0/AUX/身份；同一个IN_* FSM向下层prep。staged先kind11完整gamma，再每行kind01 raw；旧prepared QKV仍kind00 raw+gamma。`source_done`必须等reader真load_done/输出耗尽/input_hold清空/prep commit；旧raw流caller仍能走下层legacy x/gamma，不把它当真实STATE0证据|
|RoPE两reader调用|scratch load base64/bytes32/epoch32/route1，table load base64/bytes32/epoch32；各valid/ready、cancel、done/error/committed_bytes32；返回scratch512/bytes7、table128/bytes5和offset32/epoch32/last/valid/ready。移出原wrapper的同一reader直接供实际RoPE adapter，校验仍在原控制，不接保存中间值|
|legacy AUX穿透|原core AUX AR/R全组原宽度128；固定LOAD相位授予。上层锁AUX路由直到core真实load完成且该路径已接受AR的R债为零；不能见ARVALID暂低就切给gamma/RoPE。需要把原LOAD阶段/完成及真实债空观察显式穿透，不能由外部强制置位|
|QKV/RoPE共用writer|固定`segment_begin_valid/ready`＋route2/base64/span64；原tile256/n012及tile valid/ready，flush_req/done、rearm_valid/ready、fault/debt_zero/counters和B错误诊断。norm分支内部使用同接口。begin仅在无旧tile、flush已撤且真债零时锁路；直到flush成功撤下/错误真排债结束才能换段，不按“最后W已发”切路|

原reader只暴露load_done，没有独立可清的debt信号：上层须保存load_active/done_seen，并结合load_done、out_valid清空、持有字清空及reader可再接load的真实状态决定换路；cancel后仍排完已许诺/已接受burst。writer的`debt_zero=!held_valid&&!pack_valid&&!tx_valid`，`tx_valid`要到实际B退休才能清，flush_done需捕获一次并撤下flush。跨层不加AW/W/B代理确认。原input_hold64B移入上层，256bit结果直接以ready接原writer held32B，不增加512B/4096B中间行RAM。

gamma token只由下层持有，绑定source epoch/model/numeric/AUX描述符；上层只读有效状态，1024项finite前检及真实256次AUX R/4096B/prep提交结束才允许第一行LN。gamma在全部LN阶段保持，不能因每行正常done清除。norm行由下层实际视图保留，128个同步tile响应、64笔OKAY B、flush撤下和读写债零后才正常release，并消费下层done，再置该行norm_written；第128行退休才stage ready。原tensor RAW/FINAL仍由父图管理且staged不发布。

store错继续原16行窗口的算术检查：先锁首个store错误、排空并停止后续写；后续成功LN经明确discard释放视图但不置成功位；窗口内数值错误优先，算术全成功才回原store错误。discard许可由上层真实错误上下文产生，下层还要核无pending/rsp/实际LNQ债；不得由通用caller绕过B屏障。源RRESP缺操作数仍真实失败，不能填零继续。stage release沿当前显式失败/阶段discard，不能抽取时新增成功父阶段交接或清失败后发布。

Q16归下层：保留修订18部分窗口的`q16_next_row!=0 && !a_window_ready`保护，只接exec010/kind10；prep abort只清准备/gamma token，不清已有A覆盖。A16_ready仍在第16行导出、scale写、Q release和done消费后成立。正常满窗口release及显式partial discard都要无prep token/pending/rsp和真实债；暂不能让尚未实现的matrix消费端自行成功释放。上层的LN阶段持有与A16占有不可同时接纳相冲突命令。

全链使用原clk/rst_n和原IP reset，不加CE/clock gating。共同reset清控制/有效/覆盖与peer事务，RAM内容不必清；不签独立AXI reset。完整Check位置、原行内/16行优先级保持，原整模型首错等价仍未由本抽取解决。

### 至多四组受影响回归及执行出口

1. **真实服务及LN128端点**：同两生产模块、真实STATE0/AUX/STATE1 peer和原完整raw/norm checker。先同版16行有界pilot采source/LN/B/退休cycle与墙钟；正式帽由A001确定，完成并落帽才运行固定128。验131072个norm、8192 OKAY B、末B前stage ready为0、没有request成功/RAW/FINAL；不是TB直接喂LN。独立service的测量不能外推旧重父top加速或Fmax。
2. **Q16与访问占有**：复用原row0/1 norm交替16行、全部4352word、r15覆盖临界与最后输入受阻；复用AT303部分窗口五类拒绝/abort/partial discard反例，另核同步rsp保持/release竞争。两种输入样本不签真实16行producer。用合法端口事务核matrix八lane写、G不同addr同拍读写/同addr互锁、ADD读前写后；这种bank局部测试不替代算术或matrix poison验证。
3. **共享路径父图兼容**：真实父top必须实例化所测两服务；短测legacy source_mode00/01与新10/11，现row0/1 norm/Q/scale沿原gold。选已有真实core/wrapper受影响前缀覆盖一次W-AUX→source-AUX→RoPE-reader/writer转交及真实G/ADD访问；未完成的长FFN/QKV/RoPE端到端仍NOT_RUN。检查原无ready返回端口零丢失、完整result回显和旧caller接线，不能用局部bank写入冒充原算术生产。
4. **错误/持有/共同reset**：合并gamma非finite、末RRESP真排空、末B错与末B阻塞、prep/Q16/output-rsp持有下共同reset。保留一例真实LN数值坏样本核完整Check；16行store延后与后继数值优先可复用合法完成peer作控制范围短例，明确不代签16行真算术。无reset新epoch只在真实债退和显式discard后准入。

构建成本、16行/128行硬件cycle和仿真墙钟各自采样；新两服务抽取、速度收益及父图兼容均NOT_RUN。完整服务若仍不落帽，保留真实前缀，不能替换叶子、加第二bank或改128形状。新增静态脚本只核8项身份和整数地址条件，完整进程0.05s、峰16504KiB、exit0，CPU0–3/nice19/idle；原计量见[time记录](fixed_graph_support_20261014/ln128_partition_static_time_20261015.txt)，交付工具成本另列。交互读取累计UNKNOWN，工程预算未使用。

本节已直接送达A001，消息 `m004-ln128-production-partition-interface-answer-20261015`，recipient turn `01a1401e-0d9e-7f23-aaf7-799858c7f2c0`。本轮静态/状态/发送三次脚本完整计量合计5.86s、峰36592KiB，单次均≤20s且exit0；导航ok、broken_links为空。交互读取UNKNOWN；送达不等于后继实施或性能结论。

## AT343之后：LN128→W_PREP_ONLY→真实STATE1首Q16窗口（2026-10-16）

回复 `m004-ln128-q16-next-interface-question-20261016`，只补可执行接口增量。以AT343上层`58086436…`/下层`f63e25e2…`/core`452deb9c…`/wrapper`b1b73970…`/sequencer`8b9261e0…`冻结为起点；五项及W cache的current/frozen完整SHA一致，记录在[本节小依据](fixed_graph_support_20261014/ln128_wprep_q16_20261016.json)。AT343独立真实LN128的131072 norm/8192 OKAY B/252.283932s已获限定接纳；父请求同版只到row0。本节不重验这些记录，新增接口、串联与费用均NOT_RUN。

### 1. 保留norm上下文的固定继续握手

**现状不是“core空闲就能直接接Q16”。** 上层225行`stage_direct_active=(stage_loop_state!=SL_IDLE)`把SL_HELD也算LN直控；459–460行消费阶段done后永留SL_HELD。820/864–877行仍覆盖prep_begin_idle、prep_consume及match到最后LN的id/row127/epoch/kind01；core的match_kind10和Q16 prep因此不能直接生效。wrapper的STAGE_HOLD与sequencer的S_STAGE_READY也只接tensor_release；该路径清tensor/覆盖，并经prep_abort清gamma。正常后继不得借这个discard出口。

推荐沿同一上层FSM增加**一次固定`stage_continue_valid/ready`**，从成功SL_HELD推进W_SEND/W_WAIT→NORM_PREP/Q16→Q16_HELD；原LN-only caller不发continue，原行为保留。父wrapper/sequencer只增加此内部阶段请求与结果代理，不重建循环。continue携带`request/generation`各64、`norm_epoch32`、`next_base_id32`、`a_epoch32`及已锁存的原W描述符（w_epoch/key/model/numeric/header/base/bytes/AUX/bias）；必须匹配现norm上下文。W用next_base_id，Q16行r用next_base_id+1+r，预检非零、不回绕且不与已退休LN命令区间重叠；不把不同阶段的行命令编号伪称原CPU task计数完全相同。

|接口/状态最小变化|条件与保留对象|
|---|---|
|新增`norm_context_valid`，复用stage_epoch/model/numeric/dest_base/span及norm_written|全部128成功并消费SL_FINAL后保持；continue不清norm_written、stage_retired_rows、tensor_active/epoch或STATE1描述符。parent的S_STAGE_READY状态变化不能使norm上下文失效。STATE1 HIDDEN仍留作后继WO后的attention skip；本段不发布RAW/FINAL/request成功|
|新增下层只读`service_quiescent`|由ST_IDLE、QF_IDLE、Q16_IDLE、LNQ真实cmd_ready（含Q physical_debt_zero）、无prep_active/token、无result_pending/rsp、无LNQ rsp/done待消费共同产生；FEED_DONE可静止，不强改FEED状态。现`bank_link.bank_idle`仅来自core IDLE，不能代替这些真实条件|
|continue_ready|仅成功SL_HELD、norm_context_valid、128位全1、无store fault/失败、无partial/full A、上/下层均quiescent：SP_IDLE/SS_IDLE、load_active与input_hold空、reader已实际load_done且out FIFO空、writer debt_zero且tile/flush撤下、core无旧done/lease事务。任一未退则保持继续命令，不换路|
|LN控制与拥有权分开|把stage_direct_active拆成“上下文存活”与“当前LN路由占有”；W阶段不驱动LN/prep/结果口，Q16阶段按本行kind10/source epoch重新选择match/prep/consume/q16_*，legacy端此时禁止获准。不能只令SL_HELD→SL_IDLE而开放新的LN请求|
|新增`gamma_retire_valid/ready`|在全LN成功交接、下层quiescent且无prep/A占有时，仅清gamma_token_valid，保留其身份诊断与上层norm上下文；不调用prep_abort，不清A。原因是Q16的w0..4351会覆盖本地gamma w1024..2047，不能在覆盖后留下“有效gamma”token。后继需要新gamma时须重新真实预装|
|A身份|继续复用lower现q16_epoch/window_model/numeric/base/cover。新增独立`cmd_a_epoch32`，q16_epoch不再接cmd_source_epoch；source/prep仍为norm epoch e。增加窗口绑定的source_epoch32，检查后15行不换源；首窗口用本请求保留的非零新A epoch，存活期不改/不回绕。未来新窗口的分配/消费仍由后继矩阵合同确定|

`gamma_retire`可与continue在相同实际握手成立，不能仅由continue_valid触发；若W后来失败，norm内容保留且上下文sticky failed，只有显式请求discard和真实清债才回收。所有真实W/A/tensor epoch是不同拥有权字段，W冷载不自动推进tensor的e/e+1。Q16_HELD只持有A16，尚无matrix消费，不能用正常release清空它来伪造父任务完成。

### 2. 唯一W_PREP路径及Check边界

core747–756行当前把exec>2或无prepared token一律拒绝；775–786行成功LOAD后固定进LN_CMD。新增exec100必须**在LN/Q prepared检查之前单独译码**：只允许Encoder0 QKV、cmd_cold=1、slot0、key0001、K1024/N3072、bias_bytes0，要求完整norm阶段准入、空A窗口及无prep/同步读债。cmd_prepared_source=0，不能消费prep、result_reset或发LN/Q/matrix/G/ADD；LOAD结束直接返回W阶段done，不能落入LN_CMD。旧000/001/010行为保持，011仍拒绝。

为了这段真实串联能在已抽取的生产边界验证，推荐把**这一份固定W_PREP命令保持/LOAD_REQ/LOAD_WAIT/done保持控制，连同原唯一`t4_dual_w_cache_v1`，封为薄生产W服务**；原core唯一调用该服务并把legacy LOAD/lease/read/release原样透传到同一cache。独立阶段实例化同上/下层＋同W服务，不例化G/matrix/RoPE；完整父core的exec100也是调用此服务，不能写一份TB版LOAD控制或再放第二W cache。这只是现W入口的固定模块边界，无新算法、缓存或通用owner。W_PREP及legacy LOAD彼此排他；cache slot0/1和原读返回行为不改。

复用原load bundle宽度，锁存id/source epoch/w_epoch/key/model/numeric/task context、128B期望AUX header、三base/bytes和AUX地址，until完成被消费；done新增/透传id、exec100、W slot/epoch/key和完整Check。slot0冷载仍要求`load_epoch=slot_epoch[0]+1`且不回绕，slot1不动。当前cache load不建立numeric lease；W阶段的numeric绑定在准备回执中保留，后继matrix仍须真实lease，不能把W_READY视为已经读过W。

成功条件来自cache的实际load_done且无error/reject、slot0 READY/epoch正确/readers0，三路覆盖分别1572864/1572864/196608B、header128B、98304次scale检查；原三口reader和AUX reader均真实排空，不以AR数或最后R代替。静态工作量为W数据3342336B、三口R64分别24576/24576/3072，另8次AUX R16；不据此推仿真墙钟。W完成有效且消费者真实接收、准备回执身份匹配、cache可交接后，才准发第一条STATE1 AR和QUANT；期间norm写口保持无新事务。

**必须补的Check信息缺口：** `t4_dual_w_cache_v1:375–428`用同一fill_error合并RRESP/标签/header/覆盖和scale数值；core LOAD_WAIT现在所有load_error都报7。只看load_bad_element非全1不足以排除同时存在传输错误。薄W服务应取得cache分别锁存的`protocol_or_transport_fault`与`numeric_fault`（bad rank沿原scale_bad_min，不改算术），保持原合并load_error给旧caller。W数值Check为op80/status6/detail0780000f/bad64=`n*32+g`；量化为op20/status6/detail0720000f/bad64=`local_row*4096+col`；成功bad64为全1。物理/标签错误按本固定适配的status7/detail07800005/bad全1并附路由/响应诊断，需主控采用，不声称CPU有AXI错误oracle；原完整元数据E_MODEL/E_BUFFER ABI没有由这个固定入口自动补齐。

原`full_loader.cpp:101–130`按n→g检查scale（非finite或负值，负零合法）；cache185–197行相同位型规则并取rank最小。**仅当全W载荷真实取得、无物理/协议缺失时**，完整98304项集合上的min rank可对应该LOAD任务的首数值错；出现缺操作数的总线错误不能以观测min代签原Check。QKV无bias，免去bias后序分支。阶段顺序保持全LN→W成功→首Q16，W失败零norm-read/QUANT，不能通过“W成功peer＋正常量化”关闭此顺序或全请求异常等价。

### 3. 真STATE1读与Q16落bank

当前上层928–963行仅在STATE0与QKV0/1间选择512bit reader，没有STATE1物理读口；把STATE1数值地址塞入STATE0端口不构成真实接法。新增**STATE1 AR/R全组512bit口**，只扩现共享scratch reader固定路由为STATE0/STATE1/QKV0/QKV1；route在load握手锁定，直到真实load_done、FIFO/holding全退才换，沿原4KiB拆分与cancel排空。没有第二reader。

在原SP_BEGIN/LOAD/WAIT/COMMIT复用一个NORM目的模式：地址`stage_dest_base+r*4096`，source epoch=e，load_bytes4096，prep_kind10/index0..1023，payload进入唯一w4224..5247。它只核norm_context/覆盖/W回执，不再要求已退休gamma或切去读gamma；SP_COMMIT必须64次真实R、offset/epoch/last/bytes一致、holding空且1024写入才产生本行token。上层实际选择kind10时，`prep_begin_allow`也必须按**所选kind**计算，不能继续借core外部prep_kind默认00而把第二行卡住。

下层QF_CMD/READ/SEND/WAIT/EXPORT/LEAF_DONE沿原实现：真实消费1024 norm，内部Q收齐64half/32scale且进入ROW，才导出32次八bank Q写＋16次scale-pair写；不等Q外层done再开始导出。上层新增固定Q16_SEND/WAIT按r0..15驱动下层已有q16_fill_*、match_kind10、prep_consume、q16_window_begin/retire_success，所有身份从continue锁存，不能使用live cmd；`q16_retire_success`仅在QF完成成功、done真实消费的同一事务一次触发。lower `q16_fill_done`目前只给status4/bad32，完整id/row/source/a epoch/op20/Check由本固定调度器锁存生成并保持。

保留部分A占有的kind10/exec010准入、prep abort不释放A、真实pending/rsp屏障。r15准备区与Q16导出区交集w4224..4351/512B，全部1024输入先退休再写；不得边量化边覆盖。16行成功且64half/32scale各收齐、4352word写全/Q release/done全退后A16_ready，STATE1 norm不写不释放。若使用现result同步口作局部复扫，必须A16持有且QF/写口idle、地址0..543，E0/E1/阻塞保持不变；此为A窗口内部读视图，不发布为legacy FFN/QKV结果。

### 4. 保存gold的确切口径与一个有界工程出口

同request3/gen1/B1S128的完整独立`embedding_norm.f32.bin`为524288B，SHA `5d88293829ae60ee880f931cb863fcccfa82aa41dd8ed46f791ec2e484213056`；本次AT343冻结`norm_s128.hex`解码逐字等于它。`task2_real_fixture_20/work/fixtures/qkv_rows4_source_f32.bin`等于其前16384B，原Q/scale文件分别4096B/256B、SHA `1db568e2…`/`e9c9645f…`。逐行offset/完整SHA在小依据的first16_rows，不另产数据：

|真实行|norm checker|独立Q/scale checker|可签范围|
|---|---|---|---|
|r=0,1,2,3|norm `[4096r,4096(r+1))`，每行1024 F32|Q `[1024r,1024(r+1))`的1024 INT8；scale `[64r,64(r+1))`的32个LE FP16|真实STATE1→prep→Q全部输入；四行全部Q/scale逐位；bank映射和持有。原前四行PS/final参考保留，本段不执行matrix|
|r=4..15|同一完整norm文件的对应4096B，不交替复制r0/r1|未定位到这些行的独立Q/scale gold，不调用oracle补齐|每行64 R/1024实际输入逐位、32group/64half真实量化完成；把**观察的真实Q输出**逐位比到导出写与最终bank，签传输/布局/覆盖/保持，明确不是独立算术oracle|

首窗口整体静态计数：STATE1读65536B/1024 R64，16384个F32真实送Q，1024个half与512个scale，768次导出写拍、4352word/17408B持有。检查r4..15的输出到bank不得把该实际值改名expected/gold；不以旧两行交替16槽替代真实首16行。norm在末尾复扫与保存完整131072项一致，保留后继skip。

**建议下一有界工程段只到“首A16保持”，不接matrix/RoPE/Attention。** 主例用同实际生产上/下层＋上述唯一W服务，同runtime完成真实LN128→continue→slot0真实冷W/AUX→STATE1真实r0..15→A16_HELD；首4行签独立量化数值、全16行签上述搬运/生命周期。增加W服务会改变展开闭包，先以有界真实W-load/一个Q行局部pilot测新增路径成本，局部可用保存norm作输入但明确非主链；主例须从真实raw生产norm，不能注入norm_ready或补128覆盖。首次未知路径pilot建议沿≤120s惯例，主例帽/累计预算由A001冻结，不能把AT343的252.28s加字节比例当保证上界。

独立服务主例通过后可签其真实生产串联；完整含重core父图另做exec100命令/Check/回执与路由、Q16实际委派的受影响短回归及有界成本记录，复用未变FP/IP展开。父图没有同runtime完成LN128/W/Q16就仍记NOT_RUN，不以AT343父row0或独立实例替代。不要再次从重父图冷前缀原样等待来补AT351；把本地拒绝done消费后合法W_PREP的短事务纳入这次受影响接口测试。

优先交接检查限定三类：①continue在末B、result pending/rsp、done未消费时均不被接受；成功握手后norm上下文不变、gamma有序退休、旧LN/legacy口不再抢占；②真实W末R/AUX停顿与至少一条实际错误返回，W失败零STATE1 AR/Q，准备回执保持/错epoch拒绝，数字scale错与物理错区分；③真实norm末R/最后输入受阻、r15交集和A16最终复扫，部分窗口错kind/epoch拒绝及显式失败discard。旧所有reset/异常排列不作本次数值推进前置；新数据路径和握手直接受影响部分必须核，未测错误保持缺口。无需重复全FFN或Attention旧长基线，不改独立gold或clk/reset。

本轮只读/字节/整数核查；第一次脚本因manifest键名误用失败0.13s，修正为runtime_fixture后0.12s/37276KiB通过，两次合计0.25s，原失败与计量保留。均CPU0–3/nice19/idle，单次≤20s/1GiB。新增脚本及time位于同支持目录，状态/发送成本另列，交互累计UNKNOWN；本节是A001集中定案依据，不是工程放行。

本增量已直接送达A001：`m004-ln128-q16-next-interface-answer-20261016`，recipient turn `01a14103-2de9-72f1-8ea0-526a96014d4e`。本轮含失败静态核查、状态和发送四次脚本计量合计6.33s，峰37360KiB；每次≤20s/1GiB，导航ok且无broken links。直接送达不代表后继接口已采纳或已实施。

## AT368首A16之后：现生产接口上的MATRIX16增量（2026-10-16）

这是对原STEP16/TN8方案的端口落地细化，供A001制定后继合同，**尚未实施或运行**。依据[AT372工程报告](../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_rev21_AT372_observer_wprep_engineering_stage_20261016.md)、AT368上/下层及W服务冻结、AT367/372父engine冻结；[小支持记录](fixed_graph_support_20261014/a16_matrix16_interface_20261016.json)保存9项完整源码身份、实际路径和选定参考窗口。AT368证明真实LN128→冷W→真实STATE1首16行Q/A16保持；W READY不包含lease、matrix取W或PS。AT367父请求只到row0，AT372只签exec100局部委派。工程修订21继续，下面不把其余控制排列设为矩阵推进前置。

### 唯一生产切口及A/W拥有权

推荐将父`laya_lnq_wi_gqdown_row_engine_v1`已有的**唯一front及矩阵段FSM**抽成固定`laya_matrix_service_v1`：迁移LOAD/LEASE/FRONT_CFG/A_REQ/A_WAIT/W_REQ/W_WAIT/ISSUE/DRAIN/W_RELEASE、相应保持值、计数/Check；把legacy与STEP16置于同一执行器的固定模式。现`laya_w_prep_service_v1`作为它的同级唯一供给实例，原lease/read/ret/release端口直接相连，不另封装或复制cache。父engine保留LN/Q委派、G、Down阶段选择、ADD、最终视图；通过同一矩阵服务执行原Wi/QKV/Down。独立生产组合为现`source_norm_service`（包含唯一LNQ/bank/readers/writer）＋原W服务＋此矩阵服务，不展开G/RoPE；完整父engine必须实例化被测的同一组合。W_PREP原`wp_*`和矩阵服务的legacy LOAD均进入这一W服务的原仲裁，不能另接第二cache，也不在TB重写矩阵调度。局部错误peer因而可合法接在独立的A响应/W服务接口；正常串联必须接实际下层bank及W服务。

冻结父engine目前`cmd_ready`无条件排除`a_window_ready`（约328行），exec011仍拒绝；front配置只给rows1（631–656行），A只有256bit/scale32，issue顺序为group→tile（934行）。必须增加exec011=MATRIX16的单独准入分支：mode=QKV、cold=0、固定rows16/K1024/N3072/bias0，window_row0是16对齐的0..112；第一段仅用row0=0。原000/001/010/100语义保持。MATRIX16消费的是已经持有的A描述符，不是新的prep token，`cmd_prepared_source`不能被当作A16令牌。增加独立`cmd_a_epoch`，`cmd_source_epoch`继续指STATE1 norm epoch，不能把二者混写。

| 边界 | 最小新增/迁移语义 |
|---|---|
| 上层`SL_A_HELD`→矩阵 | 增加固定`stage_matrix_valid/ready`及held done，锁存id、window_row0、source epoch、a_epoch、W slot0/epoch/key0001、model3328/numeric672/task_context96、RAW目的QKV0/1 base/span/epoch。这些字段不能在处理中随外部cmd变化；目的地址仅送现writer控制，不进入算术。父exec011代理同一握手，独立组合也调用该握手。 |
| 下层A描述符/claim | 将已存在`q16_window_base/epoch/source_epoch/model/numeric`及cover只读导出；增加`a_claim_valid/ready/error`和1bit `a_matrix_owned`，逐字段匹配A16/本请求。cover必须ffff、next_row16、Q填充/导出/release/done已退、无prep、LN/Q命令/response/done、feed或bank pending/rsp。held A本身允许存在。不能复用当前`service_quiescent`，其389–394行明确排除A16。 |
| 实际W lease | consume W_PREP done后才请求一次lease：slot0、epoch、K1024/N3072/key0001/model/numeric、原父task_context（rows16/row0/非零task_id）。cache仅在READY且身份一致时置IN_USE/readers=1；读`pair=0,tile=t,group=g`，每返回核slot/epoch/tile/group/pair/model/numeric/task/mask。四block重复真实cache读，不添W预取RAM。 |
| 任务尾释放 | 全384 TN8成功写回，或已决定的算术/协议失败且真实排债后，才释放W并等待release_done且无error；随后受控释放/丢弃A16并消费一次矩阵done。读响应、front credit、PS视图、writer AW/W/B任一未退都不准释放。cache release只退lease，保留READY；A release只退A，不调用tensor_release，不清STATE1 norm持有上下文。 |

`t4_dual_w_cache_v1:301–324,462–481`是真实lease/read/release入口；`read_ready`自身不保证身份合法，必须检查read_error和ret。原WP_DONE未消费时服务仍关lease/read/release；不能用READY电平替代wp回执消费。A claim后lease失败走错误排空/受控A discard，不产生任何PS成功。

上层要增加一个固定`SL_MATRIX`相位，而非撤销`stage_direct_active`来释放全部状态。当前下层`result_rsp_ready`在stage_direct_active时被接到`stage_store_rsp_ready`（约1125行），writer `rearm_valid`也固定选择`SL_REARM`（1375行）；二者在MATRIX16必须切换到矩阵的同步读/写控制。prep、Q16 fill、legacy LN/G/ADD访问在该相位禁入，norm/source/model/epoch元数据继续锁存。W三口和W AUX仍由唯一W服务发出，AUX经原上层相位路由；唯一writer的QKV0/1目的路由仍在上层。原`segment_begin`保持到flush撤下/债零才换base/route；不新增AXI master或writer。

### 同步A读取、PS单口及确切容量增量

不改8×656×32bit final_bank，不添加fullA/quant bank。Q16完整区w0..4351=17408B保持不动，PS使用原预留w4352..4479=512B（bank addr544..559）。下层原PS口`ps_store_tile[9:0]/bits[255:0]`可直接写`544+r_local`，但不能沿父engine旧`commit_tile`写addr0..383，否则会覆盖A。

| 访问 | 地址/端口与时序 |
|---|---|
| A的Q8 | 当前block b、物理行p，r=4b+p；g=0..31。全8bank读取addr=`34r+g`，返回256bit，对应32个int8。 |
| A的half scale | 再读全8bank addr=`34r+32+floor(g/16)`；选择bank=`floor(g/2)%8`的32bit字，再按g奇偶取低/高16bit。沿现`half_to_f32`位规则转换，非有限保持给原算术Check。 |
| 共用同步响应 | 复用`result_accept/physical_addr/logical_tile/pending/rsp`，MATRIX16占有时与外部result/staged LN读互斥。logical_tile10可编码`{is_scale,r[3:0],g[4:0]}`；E0接请求，E1真实RAM结果进入原256bit rsp保持，握手后才接下一读。新矩阵请求ready只在owner正确、pending/rsp均空且该拍获读仲裁时成立；标签比对后按p装A保持。一次stripe四行各Q/scale共8请求，不一次异步组合扫四行。 |
| PS退休 | g<31的四路commit照原PS反馈退休；g31的四路commit按p0→3选一路给bank，未选的原pipeline输出必须保持。只有握手才能增加terminal/PS覆盖，不能沿旧`commit_ready=4'hf`同时写四个地址。无额外PS FIFO。 |
| bank仲裁 | 新相位只有矩阵A读或PS末组写；`result_pending`实际读拍先完成，否则末组写优先于新读请求。这样无需增加RAM端口，且不假定新同bank读写碰撞语义。原读/写onehot断言纳入矩阵选择；legacy G所需原1R/1W规则保持。PS外读只在整TN8持有时允许，算术发射暂停。 |

迁移并扩宽现`a_q`256→1024bit和`a_scale`32→128bit，**净数据保持增加108B**；原256bit同步rsp保持复用，不另添32B，Q16的even/current scale保持已经存在，不再计入“新增2B”。W保持、front两项stripe/snapshot和四套row pipeline原样复用；新增控制为block2、A物理行2、Q/scale选择1、A claim/phase、step计数、16bit terminal/PS覆盖、384位tile退休覆盖（可复用原656位final_cover的低384位）、held Check与store-fault诊断。已有tile10/group7/sequence27和父任务身份寄存器复用，控制新增位数由最终接口实现列账；108B是明确的payload差值，不是综合FF/BRAM资源。

r15的Q/scale与direct norm准备区交集仍为512B。AT368已实现“1024 norm全部消费、内部Q完成且ROW有效后导出、最后release/done”；本段只在A16_HELD之后读其数据，不能重新开放prep或用PS区域覆盖尚在读的norm。父层一般cmd/reset结果口不能在matrix_owned时清pending/rsp或cover。

### 固定父描述符的STEP16与隐藏写退休

沿原方案扩front `config_rows`至5bit并增`config_step16`，仅STEP16接受rows16/K1024/N3072；旧caller零扩展并接step16=0。config一次建立完整父描述符和49152 stripe期望。增加held `step_valid/ready(tile10,block2)`、`step_done_valid/ready(tile,block,accepted32,row_retired128,terminal4,Check/rank)`；由**服务FSM**严格产生t0..383→b0..3→g0..31，front验证next tile/block/group/sequence=`((t*4+b)*32+g)`。step门只划分工作，不能反复用N8/config rows4制造“父完成”。

一个step完整32stripe/128行组退休、4个terminal后才准换block：front entry_count/read_pending/preclaim/pretrace/busy/snapshot、raw_commit/trace hold均退，每row free35/reserved0/returned0/tracefree4；同时服务A pending/rsp、W pending/ret、末组bank写均空。g0沿现有逻辑取oldPS=0/poison=0，后续g严格递增，不清正在计算的credit，不reset四套算术。block锁存到最后响应，物理tag仍是p0..3；parent sequence和block的稳定期防止跨block混淆，step换位只在真债零后进行。row0绝对位置与r_local分开保存：A/scratch地址用window_row0+r_local，旧Check bad用任务内r_local。

一个TN8完成四block后，产生独立`ps_tile_valid(n0,window_row0,a_epoch,source_epoch,task_id)`及16行视图；成功视图须16行终结、16次有效PS写和无数值/协议错误。bad/poison时允许`mask|bad==ff`解释缺lane；全poison的final_skip也是terminal，不应转成缺覆盖协议7。只保留原数值失败，不能把无bad解释的缺lane当成功。原front的group优先next计数、expected_stripes、rowmask、row0 rank、done条件均需增加STEP16分支；仅增加上层循环不够。

每个成功TN8逐r同步读addr544+r，仍由原writer做16个32B有效写。令n0=8t、plane=floor(n0/1024)、head=floor((n0%1024)/64)、d=n0%64、s=window_row0+r；route=head&1，地址偏移为`((((plane*2)*8+head/2)*1024+s)*64+d)*4`。64B segment基址取该偏移向下对齐64，tile_n0=(n0%16)，8lane/strobe写对应半拍，norm/STATE1不写。保留既有QKV每域12MiB分配/稀疏范围/65bit溢出与请求epoch检查。每行一个真实AW/W/B，flush_done撤下、响应读退和writer债零后才`ps_retire_valid/ready(discard=0)`；该握手才允许t+1。复用writer payload，不存另一份整TN8。每TN8有效512B/物理1024B/16B响应，完整16×3072父任务6144B响应；这里B表示响应笔数，字节另列。

首TN8的可测出口为128stripe、512行组退休、128个final F32、16笔OKAY B和实际ps_retire；它只是完整父任务的第一窗口，**矩阵task_done、A release、W release、tensor RAW/FINAL和request_done均不得因此成功**。局部测试可在该事件结束观察，不增加“只算TN8成功”的生产模式。父任务只有全部384tile/49152stripe/196608行组退休、6144成功B及真实W/A释放后才done；第一16行完成也不能预填其它112行RAW。e/e+1和全RoPE屏障沿既定后继设计，norm上下文继续留给WO。

### 错误次序、真实事务与独立参考范围

完整Check保留op30、status16、detail0730000f/bad64；原core对所有非legacy数值bad统一套`token_row*4096`的分支（约366行）不能用于exec011，必须单独返回矩阵bad。当前TN8四block的数值错按原任务r_local→lane→g/phase归并：`bad=r_local*5248*128+(8t+lane)*128+g`；顺序key沿`((((t*16+r_local)*8+lane)*33+g)*5+phase)`，不能比较不同TN8的bad整数选最小。`q8_linear_compute.cpp:205–296`在一个TN8中真实执行四block、带poison归并；原任务遍历在该TN8失败即返回，不能先跳过未执行的优先窗口。STEP16必须完成当前TN8的四block及排债后决定；有数值错误不发下一tile。

提前scratch写遇B错，保存第一store错及route/response/ordinal，真实排AW/W/B并停止后续写，隐藏所有部分写；**继续本16行全N父任务尚余算术**，正常后继PS走受控discard（无B成功计数）。后续首次失败TN8的完整数值Check优先；仅384tile算术都成功才报store7/detail07300005/bad全1。不进入下个A16，不以store错伪造front abort，也不以当前已观察min跳过后续算术。A/W标签或缺操作数属于协议错误，真排空后失败，不能填零继续；此物理接口错误次序单列，不宣称旧CPU AXI错误等价。

最小正常事务是实际冷载完成并消费wp_done→claim真实A16→实际slot0 lease_done→每stripe8次同步A请求与1次真实W cache read/ret→四行真实FP/PS→四block terminal→16次真实写B→ps_retire。用有限A rsp/末组commit/W ret/末B阻塞核身份保持及禁止release；错误epoch/model/task的lease/read须得到真实协议回执、零错误算术发射。无新增冷W AR只说明驻留命中，仍必须观测128次首TN8 W read/ret，不能以READY代签。

首错局部反例仍采用原full descriptor，在**同一个matrix service/front的合法同步A/W响应peer边界**给A[row1,g31] half_scale=7c00，并安排W[tile1,g0,lane0] half_scale=7c00，其余用保存有限payload。完整执行tile0四block，应返回6/bad671775，不得发tile1（其row0/n8的bad1024反而更小）；去掉A故障，须真实经过tile0后在tile1报1024。移A故障到g0可核poison/final_skip。该故障peer只签矩阵错误排序，不签真实W加载或Q16算术；**不能将非finite W放进真实LOAD再期待matrix收它**，现W前检会先拒绝。主正常例仍必须使用真实bank/cache，无force内部done/credit。另以tile0末B错＋tile1数值错核store延后和算术优先；纯store最终完成仍需全N执行或明确标注局部控制peer的另证，首TN8不代签。

同request3/gen1的保存独立`qkv_rows4_*`父SHA复用[原入口依据](fixed_graph_support_20261014/embedding_qkv_binding_20261015.json)，不求值、不生成新文件。精确索引为：Q byte=`1024r+32g+k`，half scale byte=`64r+2g`，六字段byte=`(((r*32+g)*3072+n)*6+f)*4`，final byte=`(r*3072+n)*4`。f依次为signed int32 dot的u32位型、F32 sa、sw、product、term、committed PS；dot不是F32。r=0..3、g=0..31、n=8t..8t+7；完整N所有384tile均有这些四行参考。首TN8可比1024个lane-group的6144字段和32个final；其它12行有真实norm输入与AT368叶子输出→bank映射证据，可核bank→A响应→真实矩阵/PS提交→scratch字节传递/finite/覆盖，但无独立Q/scale/PS/final gold，不能把观察到的叶子值称oracle。小支持只新增t=0,1,127,128,255,256,383各四行窗口身份，28个末PS→final逐字节关系和224条scatter整数关系，未重新计算任何算术。

**建议后继工程段：**落地上述共同矩阵服务、STEP16及PS/writer退休；主例实际独立生产LN128→W→Q16→首TN8，保持原完整父描述符，明确first-TN8前缀出口。局部先核同服务的A16/W lease与同步A、四block/poison/Check、PS写B持有三类关键交接；父top只补同一实例的exec011/端口委派和legacy矩阵受影响短兼容，不要求先重跑全部旧长链。上层producer317.274436s是AT368现层次实测；父row0的93.832176s和core/W O3约88–95s是不同工作量，不作为新矩阵段成本。新front展开/四行FP工作、同步A端口和writer退休尚无同版成本；pilot以真实lease至first-TN8 PS/B事件分段记cycle/单调墙钟，构建另账，预算/启动门由A001定，不以128行比例或150MHz预测墙钟。本轮没有profile或工程实施。

新增[只读脚本](fixed_graph_support_20261014/check_a16_matrix16_20261016.py)及[外层计量](fixed_graph_support_20261014/a16_matrix16_static_time_20261016.txt)随小记录交付：实测0.05s、29588KiB、exit0；命令限定CPU0–3/nice19/idle、20s/1GiB，交互读取累计UNKNOWN。状态/通信脚本另存计量，不算数值实验。未变数值证据仍仅按原冻结版本/范围引用；服务抽取、STEP16、全父图同runtime、后7个A16窗口、RoPE/FINAL/整模与物理结果继续开放。

## 核查边界与交付

工程接点问题 `m004-fixed-graph-reuse-contacts-question-20261014` 已送达并收到 `m004-sm004-reuse-contacts-answer-20261014`；[工程接点表][contacts]确认残差单项在途、矩阵/LN/Attention的旧控制耦合及尾部独立工作。完整软件入口是 `tests/current_production_full_csim_tb.cpp` → `full_execute_cpu_request`，本轮选取 B1_from_b0_S128。首版交付时软件结果文件尚未生成；现按工程勘误 `m004-sm004-research-path-correction-result-20261014` 补充下列已完成证据，不回写历史通信。

**AT091软件证据补充（2026-10-14）：** 已读取[完整软件报告][software]、[原收据][software_receipt]并核[原日志][software_log]第47–50行与[guard结果][software_guard]。当前 E002 的 g++ host 正常 B1/S128 全图为 `PASS_SCOPED_FULL_SOFTWARE_NORMAL_B1`：46个中间 checkpoint 加 final18，共47项/4,523,596个F32与独立 gold 逐字节一致；最终72B SHA256 为 `b54436f6ec76ad541a001ae06ccd4a867584e90ac973cc0438a730a5959de2ad`。日志实证 QK/softmax/AV **CPU叶子各61,440次，状态Attention服务命令0次**，纠正工程首份接点通信中的相反描述。962次QUANT、695,816个量化group及1,473,773,584个matrix active lane-group也与冻结工作量相符，但不构成RTL执行证据。

该次 host 运行216.712004691s、峰640,172KiB，child exit0/无guard触发；这是带完整自检的软件运行成本，不用于推算Attention RTL II、硬件Fmax或CPU/FPGA加速比。此次通过增强当前软件数值图证据，不改变本报告的两种架构选择。旧残差slot无外部tag且单项在途，返回保持到 `out_valid&&out_ready`；截至 AT091 尚无新封装的多项在途证据，后续更新见下段。

**AT092–099向量证据补充（2026-10-14）：** 已核[工程报告][vector_stage]、AT093/097/098原日志和AT099资源/时序报告。所选CE ADD在52组定向样本连续每拍接受；32credit新封装在原4096对真实残差/独立gold上连续4096次接受，首接受0、首返回6、末消费4102（含首周期4103cycle），输入空拍/输出反压6444cycle、峰32，局部在途复位通过。它支持“独立元素不必逐项等返回”，但替换叶子与封装同时发生，不能将收益全部归给去封装；旧FSM叶子零刺激ready间隔3cycle也不能外推全域II。单lane流OOC为1283 LUT/614 FF（其中89 LUT作存储）、无DSP/BRAM/URAM，内部WNS+3.057ns@6.667ns，外部delay缺失且无P&R，不是整图频率或总线服务面积。

AT097的6928/7185cycle和49152B是该TB下局部搬运记录，**不签合法AXI4服务速率**：已核冻结RTL SHA `cbdf7d6740be8d57978be26973dfce053390214d12f54e62b97e425c6cb0cb59`，4096元素被发为256×64B的16KiB单burst，越过AXI4的4KiB边界；TB第68–78行反而固定期望AxLEN=255。研究已送达 `m004-vector-axi-4k-boundary-question-20261014`。A001随后在 `m004-ln-single-row-next-design-question-20261014` 确认跨界和缺finite检查均交A002原预算修正；保留原样本、等待受影响修正的证据，不扩大为新研究实验。单beat加载→16项发射/收回→写回还有调度开销，后续不得把纯流4103cycle直接当残差内存服务，更不能移作LN或Attention整体速率。

后续闭合更新：A002在 `m004-vector-axi-4k-fix-answer-20261014` 确认原端口直接为AXI4、无外层分段器，并交付[AT101收据][vector_at101]；已读其scope、guard和更新后的工程报告。当前SHA `13e98045e1ecb1d09e22a04ebe71848e42747d781d7015fba836e3c720092445`按三路页尾共同chunk拆分并检查输入/结果finite，10条连续无reset局部命令通过；4KiB对齐正常/反压为6955/7206cycle、8AR/512R/4AW/256W/4B，偏移/短尾及数值/响应错误有对应短测。此为工程受影响修正的限定证据，本研究未重复其全部审核；旧AT097数值不升级，ADD流/OOC身份不变，仍无真实HBM或全图结论。

本次只读源码/既有报告并做11文件身份与几项容量/带宽算式核算，[脚本及采样结果](fixed_graph_support_20261014/small_budget_evidence.json)保留输入 SHA。真实命令：

```sh
taskset -c 0-3 nice -n 19 ionice -c 3 timeout 10s prlimit --as=8589934592 -- /usr/bin/time -v -o source/fixed_graph_support_20261014/small_budget_time.txt python3 source/fixed_graph_support_20261014/check_small_budget.py
```

该次进程墙钟0.04s（内部核算0.00194s）、峰RSS15,748KiB，采样 MemAvailable 447,388,512KiB，affinity 0–3/nice19；完整进程数据见 time 文件。此前交互式源码浏览未统一采样，累计精确耗时/RSS为 UNKNOWN，不补造全程合规数值。未执行 EDA/GPU/reference前向或旧预算重跑，未启动新 agent；没有物理频率、整请求 RTL、连续请求或同口径 CPU/GPU 性能结论。

[reference]: ../project/E002_Laya_HLS/experiment/tests/full_reference.py
[ln]: ../project/E002_Laya_HLS/experiment/hls/operators/layernorm_compute.cpp
[q8]: ../project/E002_Laya_HLS/experiment/hls/operators/q8_linear_compute.cpp
[att_cpp]: ../project/E002_Laya_HLS/experiment/hls/operators/attention_full_compute.cpp
[vec_cpp]: ../project/E002_Laya_HLS/experiment/hls/operators/vector_full_compute.cpp
[dec_cpp]: ../project/E002_Laya_HLS/experiment/hls/operators/decision_full_compute.cpp
[matrix]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/tm4tn8_row_pipeline_v1.sv
[quant]: ../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/quant16_stream_row.sv
[att_rtl]: ../project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/rtl/attention_tile_service_prefetch_v1.sv
[g]: ../project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/geglu_canonical_core.sv
[add]: ../project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_ffn_fadd_slot_v1.sv
[residual]: ../project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/rtl/laya_ffn_residual_four_row_v1.sv
[atn]: ../project/E005_full_request_performance/experiment_results/runs/R001/reports/ATN1_attention_softmax_comparison_20261013.md
[att_results]: ../project/E002_Laya_HLS/experiment/vivado/module_design/attention_and_fp_engine/source/results.md
[start]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_host_start_20261014.md
[contacts]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_minimal_reuse_contacts_20261014.md
[software]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_software_baseline_result_20261014.md
[software_receipt]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT091_SM004_full_software_b1_04/receipt.json
[software_log]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT091_SM004_full_software_b1_04/run_guard/driver.log
[software_guard]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT091_SM004_full_software_b1_04/run_guard/guard_result.json
[vector_stage]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_vector_stage_result_20261014.md
[ln_mul]: ../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/rtl/attention_tile_ce_tanh_libm_stream_leaf_stream_mul_node_14_s.v
[ln_div]: ../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/rtl/attention_tile_ce_tanh_libm_stream_leaf_stream_div_node_0_s.v
[ln_sqrt]: ../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/front16_wide/hls/syn/verilog/laya_front16_wide_fsqrt_32ns_32ns_32_7_no_dsp_1.v
[ln_sqrt_ip]: ../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/rtl/front16_wide/hls/syn/verilog/laya_front16_wide_fsqrt_32ns_32ns_32_7_no_dsp_1_ip.tcl
[ln_fixtures]: ../project/E002_Laya_HLS/experiment/results/engineering_p1/20261007T021236Z-1800667/fixture
[ln_numeric_tb]: ../project/E002_Laya_HLS/experiment/vivado/module_design/layernorm_engine/tb/numeric_tb.cpp
[vector_at101]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT101_SM004_vector_axi_4k_finite_02/receipt.json
[ln_row_stage]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_result_20261015.md
[ln_row_evidence]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_ln_row_stage_evidence_20261015.json
[ln_first_error_review]: ../results/m004_simplified_start_20261014/ln_review_engineering_response.md
[ln_first_error_closeout]: ../results/m004_simplified_start_20261014/ln_row_review_evidence_20261015.json
[lnq_identity]: fixed_graph_support_20261014/lnq_fixture_layout_20261015.json
[lnq_cli]: ../project/E002_Laya_HLS/experiment/tests/numeric_cli.cpp
[lnq_fixture_test]: ../project/E002_Laya_HLS/experiment/vivado/module_design/top/tb/numeric_fixture_test.py
[lnq_reference]: ../project/E002_Laya_HLS/experiment/tests/numeric_reference.py
[lnq_bank]: ../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/quant_a_row_bank_v1.sv
[lnq_stage_result]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md
[lnq_stage_evidence]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_evidence_20261015.json
[q_timing_paths]: ../project/E004_full_accelerator_integration/experiment_results/runs/R001/attempts/AT116_SM004_lnq_row_ooc_01/work/timing_paths.rpt
[q_path_partition]: fixed_graph_support_20261014/q_critical_path_partition_20261015.json
[q_div_service]: ../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/quant16_divider_service.sv
[q_tiny]: ../project/E002_Laya_HLS/experiment/vivado/module_design/activation_quantizer/rtl/quant16_tiny_div127.sv
[q_fp_bits]: ../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/metadata_reset_v3/r0_numeric_adapter_v1/rtl/r0_fp_bits_pkg.sv
