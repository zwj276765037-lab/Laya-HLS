# Q8 metadata_reset_v3：流水、DSP、banking 与 R0 恢复的只读结构分析

作者：GPT-6 Astra / xhigh，`/root/q8_pipeline_analysis_astra_xhigh`。日期：2026-10-09。状态：**有来源的后继设计建议，尚非实现放行或性能验收**。

本次只读检查当前 fe067 数据身份对应的 `metadata_reset_v3` HLS 源、配置、日志、调度、绑定、资源 XML 与生成 Verilog；只新增本文和同名 JSON 证据索引，未修改生产源、TB、既有设计/结果/mission，未运行 EDA，未访问 Claude bridge。使用 hardware-agent 技能及其 specification/module_workspace 规则。当前 ACT K256/N2/rows1 的 36 条 RTL 数值/协议/恢复命令接受状态直接引用既有独立验收；本文没有新增 RTL 周期、利用率、OOC 或板上结果。

## 1. 结论与来源边界

当前高资源而低吞吐的主要原因已经在生成结构中找到，不能用“TM4/TN8 共 1024 个乘法器”推导每拍 1024 个有效 MAC：

1. **乘法真的复制了 1024 份，但 HLS 给每份选择零周期 auto 乘法，DSP=0、LUT=40。** 合计 40,960 个估算 LUT。其生成 RTL 只有组合 `$signed(din0) * $signed(din1)`，没有 DSP 绑定或内部流水寄存器。这里是 HLS 绑定/估算事实；尚无 OOC，不能改称物理 LUT/DSP 映射已验收。
2. **dot32 没有生成静态五级树。** 变步长 `stride` 内的 `k += 2*stride` 不能展开，工具明确报 variable trip count。它生成 32 份三状态、动态索引的归约子模块，各 1,594 FF / 887 LUT，合计 51,008 FF / 28,384 LUT。归约主数据加法器被循环复用；不是 31 个树加法器同时工作。
3. **32 个输出的恢复操作共享一个 FMUL、一个 FADD、一个 I32→F32、一个 half→F32 服务。** 绑定表将 32 个 `sa*sw` 和 32 个 `dot_float*product` 全映射到同一 FMUL。top 的 g/tile 循环没有 PIPELINE，配置也关闭自动 loop pipeline。32 路点积子模块在不同 FSM 状态逐路启动，无法形成持续向量发射。
4. **21.308 ns 的最长 HLS 路径确切属于量化 amax 串比较。** 第二遍量化另有数组双口争用、仅两个共享 FMUL、round/错误选择/packed 回写链，实际 II=7。没有证据把 21.308 ns 归因于 URAM、PS 反馈或 DSP 数不足。
5. **装载、量化、计算、排出、report 串行且多处仍是标量循环。** W 校验每个 padded n/g 调用动态 half 服务；lane_bad 初始化逐 bank；输出是 32-bit 逐元素写。即使修复 dot，仍须用全 K/N 的分阶段系数决定下一项优化。

可核对来源（均相对于工程根 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline`；JSON 记录绝对路径与 SHA256）：

| 代号 | 文件 / 定位 |
|---|---|
| SRC | `vivado/module_design/q8_linear_and_restore/metadata_reset_v3/source/q8_joint_tm4tn8.cpp`：dot 214–231，bank 322–342，LOAD 521–570，quant 598–658，compute 701–760，output 762–803 |
| CFG | 同版本 `runs/csynth_config_v1/q8_joint_csynth.cfg`：`syn.compile.pipeline_loops=0`，throughput-driven partition off，`-fno-fast-math -ffp-contract=off` |
| LOG | 同版本 `runs/csynth_local_v1/work/logs/hls_compile.log`：152（不能 unroll），474–493（amax 最长链），589–597（group 端口与 II=7），1026–1063（URAM 一般警告与 top 子调用） |
| TOPXML | 同一 `work/hls/syn/report/q8_joint_tm4tn8_csynth.xml`：PerformanceEstimates / AreaEstimates |
| PROFILE | 同一 `work/hls/.autopilot/db/q8_joint_tm4tn8.verbose.rpt.xml`：Utilization Estimates / Instance、Memory、DSP |
| BIND | 同一 `.autopilot/db/design.bindinfo.xml`：source:223、640、724、725、727 与唯一 RTLNAME 统计 |
| SCHED | 同一 `.autopilot/db/q8_joint_tm4tn8.verbose.sched.rpt`：ST_312 的 tile 入口，ST_317–330 的第 0 lane，ST_358–371 的第 1 lane等 |
| RTL | 同一 `work/hls/syn/verilog/q8_joint_tm4tn8.v`：实例 15877、16116、18522/18537/18566；tile 入口 54057；tile 提交 36135 / 59736 |
| CONTRACT | `results/attention_rtl_repair_20261008/repair_contract.md` §4.1–4.7，特别是 group R0 次序、真实反馈与首错规则 |

活动合同为 `mission/task.md`；后继首先是已准备的 scorer FC1 K1024/N1024：LOAD→单行 trace-on→同输入 trace-off，之后才按实际系数扩展 14 个窗口。本文不能替代其独立源审、仿真预算或执行门。旧 04934 的资源没有计入本文。

## 2. 已生成结构的具体归属

### 2.1 INT8 与动态归约

BIND 在 SRC:223 有 **1024 个操作、1024 个不同实例**，全部 `IMPL=auto, LATENCY=0, DSP=0`，RTLNAME 为 `mul_8s_8s_16_1_1_U1478` 起的一族。PROFILE 对其每份估算 40 LUT。乘法 wrapper `q8_joint_tm4tn8_mul_8s_8s_16_1_1.v` 没有时钟端口、流水或 `use_dsp` 约束；为什么工具内部代价模型偏好这种映射，现有日志不提供更深理由，不能声称 DSP 不支持 INT8。

SRC:225 的外层 stride=1/2/4/8/16 保留，SRC:226 的内循环有 UNROLL 但未兑现。LOG:152 原文为 `Cannot unroll loop 'VITIS_LOOP_226_3' ... as it has a variable trip count`。`q8_joint_tm4tn8_Outline_VITIS_LOOP_225_2_csynth.rpt` 报外层 trip=5、内层未知、均非流水；主数据加法 `level_1529_fu_2018_p2` 加上动态 sparsemux（33/65 输入）及寄存器阵列。其生成文件实际名带双前缀：`q8_joint_tm4tn8_q8_joint_tm4tn8_Outline_VITIS_LOOP_225_2.v`。不同编号的 32 份均为相同 1,594 FF / 887 LUT 估算。

1024 个乘法器的 40,960 LUT 与 32 份归约的 28,384 LUT 已占 top 估算 LUT 的约 44.4%；归约的 51,008 FF 约占 top FF 的 43.4%。这只是子资源加总归属，不是通过替换后必然节省的净量：新流水树也需要加法器、寄存器、valid/tag 及广播布线。

### 2.2 FP 服务不足与串行调用

BIND 的唯一路径映射如下：

| 语义操作 | 静态操作数 | 物理 HLS 实例 | 估算 DSP/实例 |
|---|---:|---|---:|
| SRC:724 `sa*sw` | 32 | `fmul_32ns_32ns_32_3_max_dsp_1_U1449` | 3 |
| SRC:725 `float(dot)*product` | 32 | 同一个 `U1449` | 3（不能重复计数） |
| SRC:725 I32→F32 | 32 | `sitofp_32ns_32_2_no_dsp_1_U1451` | 0 |
| SRC:727 `old+term` | 32 | `fadd_32ns_32ns_32_4_full_dsp_1_U1448` | 2 |
| SRC:640 quant 乘法 | 8 | `..._2_max_dsp_1_U235/U236`，每份绑定 4 操作 | 各 3 |

恢复 FP 总共占 5 DSP，量化乘法 6 DSP；当前 40 DSP 的其余 29 来自地址/索引等其他运算，不是 INT8 阵列。half_to_f32 仅一个子实例，独立报告 latency/interval 为 1–11 cycles、77 FF/223 LUT，正常与次正规 half 的软件式归一化循环服务不同。

SCHED 给出第 0 lane：ST_317 开始 sw 转换/归约调用、ST_319 开始 product、ST_320 开始 sitofp、ST_322 开始 term、ST_325 开始 FADD、ST_330 写 PS；第 1 lane 对应 ST_358/360/361/363/366/371。这些是调度状态编号，**不是实际连续 elapsed cycles**：子函数 done 等待和 trace AXI 反压会延长等待，条件也会跳过状态。RTL:62898 的 `ap_block_state318_on_subcall_done` 同时等待 lane0 归约与共享 half 转换；其他 lane 同形。

仅用现有一个 II=1 FMUL，每个有效 GS32 dot 需要两次乘法，因此恢复服务的理论上限已是 **0.5 dot-group/cycle = 16 MAC/cycle**，还没有扣除归约、控制、检查、转换和加法。这里是结构服务上界，不是本版本测得吞吐。满 TM4/TN8 一次逻辑向量至少需要 64 个 FMUL 服务拍，不能称为 II=1 向量阵列。

### 2.3 存储和关键路径必须分别解释

当前 TOPXML 为 BRAM18=341、DSP=40、FF=117625、LUT=156176、URAM=256，top latency/interval 未定。PROFILE 的 payload 分解如下，都是 HLS 估算：

| 存储族 | 真实生成 bank / 字宽 / 深度 | BRAM18 | URAM |
|---|---|---:|---:|
| Wq | 8 × 256 × 20992 | 0 | 256（每 bank 32） |
| Ws | 8 × 16 × 20992 | 64 | 0 |
| FP input | 8 × 32 × 8192 | 128 | 0 |
| Aq / As | 4 × 256 × 512 / 4 × 16 × 512 | 32 / 4 | 0 |
| PS / bias | 32 × 32 × 656 / 8 × 32 × 656 | 64 / 16 | 0 |
| lane_bad | 32 × 1 × 656 | 32 | 0 |

这些存储占 340 BRAM18，另有实例内部 1 BRAM18。Wq 每份估算有 1040 LUT、6 FF 的存储附带逻辑，8 份为 8320 LUT；生成 wrapper 是 `hls_ultra, cascade_height=1`、一读一写、读寄存器。到底怎样拼接 URAM、选择深度片、跨 SLR 放置以及 mux 延迟，要由同源 OOC/实现报告确认。理想 72×4096 原语拼接为每 bank 4宽×6深=24 URAM（总192），与 HLS每bank32不同；这提示物理粒度/估算需核，不证明可以直接省掉64 URAM。W逻辑数据共5,373,952 B。

LOG:483–492 对 21.308 ns 明确列了 amax 路径上的 3 个 6.870 ns 浮点比较及中间选择，模块是 `Pipeline_VITIS_LOOP_602_27`。URAM read-first 的日志只是通用警告，当前 LOAD 与 compute 分阶段，不能因此认定已有 W 同地址读写冲突。PS 是 BRAM，也不能把此最长路径写成 PS/URAM 反馈链。

局部 `group[32]` 没有 partition；实际 `group_RAM_AUTO_1R1W.v` 名称虽然含 1R1W，**端口0、1事实上都可读写**，每拍最多两项，不是8项。8写/读一 block 的供给下界为4拍。amax最终II4，第二遍最终II7；第二遍还有2个共享FMUL（8项至少4拍）及退出/packed依赖。因此只加 `group` 分 bank 仍不保证 II1。

### 2.4 其余串行成本

SRC:521 外层按 shard 0 后 shard 1 加载，宽 512-bit 两口不是并发使用。scale 每512-bit beat拆4组×8 lanes、每组1拍，当前scale unpack本身II1但每beat至少4拍；其后逐 padded n/g 校验调用 half 转换。TOPXML 的 LOAD校验 inner iteration 报43–53拍，量化 group 循环报38–71拍，都是静态估算而非全维实际系数。

SRC:705–706 lane_bad 初始化按 tile 再逐32bank，没有 UNROLL；报告每bank iteration2拍、每tile66拍。32个实物 bank 不代表32bit同时清理。SRC:762–803 的bias/output也是串行循环，输出实际是两个32-bit AXI口；普通矩阵只用out0。SRC:670/679的q/scale trace写入发生在线性之前，SRC:745每选中group有8word trace，report子模块静态1134拍。trace-on/off必须分开计，尤其小ACT不能据此推出纯compute性能。

## 3. 建议先做的同几何结构修订 C1

本节是供主 Astra 正式设计选择的具体候选，不是让实现者绕过后继全维观测或自行改变数值合同。

### C1-A：固定五级整数树 + 明确 DSP 绑定

每个dot显式生成32个signed8×signed8→signed16乘积；后续数组级数固定为16/8/4/2/1，对应signed17/18/19/20/21，再符号扩展到INT32。每一级索引与trip count编译期常数，级间置寄存器和valid/tag；禁止保留运行时 stride、k循环及巨型选择器。21bit覆盖最坏32×128×128=524288；即便有效激活限定-127..127，也不借此冒险缩成20bit通用dot。

首个映射变体对INT8乘积显式DSP绑定并给足寄存级，以真实OOC检查；保留一个LUT乘法映射变体只作资源/频率比较。整数加树可以改变结合，因为21/32bit都无溢出，最终INT32精确；FP group累加顺序保持原样。不能通过FMA或跨group的PS分片累加消除反馈。

C1的整数资源条件值是1024 DSP（若一个乘法一个DSP），不是当前已经实现的DSP数。新的5层树算术节点为32×31=992个；在每级寄存全部节点时，纯树结果寄存位数为32×(16×17+8×18+4×19+2×20+21)=17696bit，另加valid/tag、对齐与DSP内部寄存。该计数用于审核结构规模，不是FF报告预测。

### C1-B：32条完整 R0 恢复通道，绑定实际供给

每通道配置1个I32→F32、2个独立FMUL、1个FADD，均每拍能接收一组新输入；FMUL1计算`F32(sa*sw)`，FMUL2计算`F32(F32(dot)*product)`，最后FADD执行`F32(old+term)`。不得把group0直接写term，必须保留从+0的加法；bias按原冻结条件最后加一次。可以采用32份明确RTL/HLS子实例，必须从生成绑定表证明没有再次共享到标量资源。

以本次已报告的每FMUL3DSP、FADD2DSP系数，恢复服务为64×3+32×2=256DSP；加整数1024共1280DSP。若量化也恢复8FMUL则24DSP，沿用当前其他29DSP仅作临时算术项，总计**约1333DSP**，还未纳入新地址、FIFO、hazard、异常和时序改写；不是已测资源或最终平台预算。相对当前恢复5DSP，恢复部分增加251DSP。I32→F32、scale解码、选择/标签的LUT和寄存成本必须另测。

存储保持8W/4A/32PS bank：每issue读8个Wq和8个Ws并寄存，向4行广播；每group读/转换4个Aq/As，在整个N tile扫完前保留，向8列广播。half转换改为固定时延的位操作解码（10bit leading-zero计数和定宽移位），保留所有65536种half位型；compute稳态只需8列scale解码/拍，A的4个解码/group可独立准备。不要为“并行”复制整个W缓存4份，也不要在每行重复从W bank取同一word。若选择在LOAD预解码后存F32 Ws，逻辑Ws容量翻倍，当前64BRAM18系数的简单近似会增加约64；优先试固定时延解码以保留16bit存储。

内部每条issue携带 `(task, epochs, m0, g, tile, row/col mask, last_g, PS address)`，随payload同停顿。32lane的PS是一读一写端口，按tile轮转；F定义为真实读请求到写提交且下次读安全的窗口，必须满足相同PS地址复访间隔≥F。N2、窄N或T<F时显式hazard scoreboard等待，或经逐位证明的旁路；不使用假DEPENDENCE pragma。能跨独立tile交错，不能改变同输出g升序。

建议先维持单任务、单A/PS、LOAD与compute分阶段，保持外部九AXI/双Lite/descriptor原样。在这个边界内证明vector issue II、实际PS读写与R0正确后再增双缓存。不可停FP pipeline必须在issue前预留所有在途结果容量，FIFO深度由真实总latency及最大拥塞确定；仅把 `ready` 接到输入不足以处理已经发出的结果。

错误处理改为每lane独立检测后对原rank作树形最小值选择，保留SRC:736/775的原rank定义及phase顺序。汇总不能按“最先返回”提交，必须等待所有更早原索引工作完成；失败lane的后续操作不计作合同内有用MAC、不写PS、不发布输出。仍在整个microblock的计算结果已判定后才按原输出顺序排出，方便保持原side effect和counters。lane_bad可打包为32bit×T并在vector退休时更新；这是从32个1bit窄BRAM压为少数BRAM的候选，须解决并发读改写与已判失败lane过滤，不可直接换类型即宣称端口够用。

### C1-C：8lane量化的最大值和局部服务一起修

`fabs`后非负有限F32的31bit绝对值编码与大小次序相同。先并行取有限位/abs位型，用每lane或平衡树作unsigned比较，再作组内max；NaN/Inf单独收集原索引最小值，不让错误优先级穿过8条浮点数据路径。初值+0、fabs(-0)=+0、相等时最大值相同，故对合法有限组的amax可以逐位保留，包括F32次正规输入。这个等价依据不能延伸到有NaN的无条件浮点max替换。

`group`明确为8bank×4word（或1024bit寄存组）；每拍同时保存/重放8lane，数据路径采用8个FMUL和8个round/convert，不能由当前两个共享FMUL支撑8值/拍。packed改为8个byte lane写入各自块寄存，最后定址拼256bit，去掉串行宽packed选择链。first_bad由8bit错误向量+平衡优先编码器产生，保留block升序及组内最小i。

先保持`d_full=F32(amax/127)`、`inv=F32(1/d_full)`、F16 RNE、`roundf`半整数远离零，不能用乘预存倒数或保存half倒数替代。divider/reciprocal/half服务使用带tag的队列跨独立group推进，可把其latency隐藏在多组在途内；仍在完整rows量化成功后才claim/启动linear。全tile前置输入读取与NaN首错的退休行为按当前合同保留。

目标是两遍各8值/拍的供给与每group至少4拍服务间隔，再以独立divider容量决定量化实际group II；不是声称新量化必然4拍/group。double group缓冲只需2×32×32=2048bit原始样本，但流水中所有未取回组及错误退休还需额外token存储。

### C1-D：全图量化工作量证明8lane仍有独立瓶颈

本表重新读取 **fe067** 的 `build/model-attention-rtl-repair-20261008/manifest.json` 中124个权重描述符，过滤dtype=8得到122张；行数绑定当前 `hls/control/full_forward_controller.cpp:210–269` 的B/row16量化循环，以及graph的28 Encoder/2 Decision层、scorer16候选行、ACT单行。它与既有接口报告§5/§6.1的任务数和MAC总量吻合，但没有使用旧04934的cycle/资源。每次QUANT只遍历完整N一次的输入，不可把量化成本误乘N。

| family | 张数 | K→N | B1各矩阵有效行数 | B1量化输入总数 | B1量化GS32组数 |
|---|---:|---|---:|---:|---:|
| Encoder QKV | 28 | 1024→3072 | 128 | 3,670,016 | 114,688 |
| Encoder Wo | 28 | 1024→1024 | 128 | 3,670,016 | 114,688 |
| Encoder Wi | 28 | 1024→5248 | 128 | 3,670,016 | 114,688 |
| Encoder Down | 28 | 2624→1024 | 128 | 9,404,416 | 293,888 |
| Decision QKV | 2 | 1024→3072 | 128 | 262,144 | 8,192 |
| Decision Wo | 2 | 1024→1024 | 128 | 262,144 | 8,192 |
| Decision FC1 | 2 | 1024→4096 | 128 | 262,144 | 8,192 |
| Decision FC2 | 2 | 4096→1024 | 128 | 1,048,576 | 32,768 |
| Scorer FC1 | 1 | 1024→1024 | 16 | 16,384 | 512 |
| ACT FC2 | 1 | 256→2 | 1 | 256 | 8 |
| 合计 | 122 | — | — | **22,266,112** | **695,816** |

B1/S128为962次QUANT、962次Q8 Linear；B2/S128为1924次，各输入/组/MAC工作量乘2，W加载仍122次。当前量化数据量本身为89,064,448 B输入，A8/half有效输出约23,657,744 B（22,266,112+2×695,816）。

条件预算必须区分不同结构：

* 8lane、两遍串行、每遍理想II1：仅扫描就需`2×22,266,112/8 = 5,566,528` cycles，即**37.110 ms**；div/reciprocal、half、输入装载、fill/drain与控制另加。与TM16/TN16理想纯Q8的38.38ms串行相加已约75.49ms，不能再宣称还有11.62ms给全体其他模块。
* 若给max和replay各自独立8lane，并经跨group缓冲证明两遍可重叠，steady服务条件下界为`22,266,112/8 = 2,783,264` cycles，即**18.555 ms**，仍不是整体quant latency。两次FDiv若仅一个II1服务，最多0.5group/拍；8lane所需0.25group/拍有容量，但必须允许多组在途，当前逐group等待两次div没有这种调度。
* 当前首遍II4/次遍II7，按每组4block的稳态服务量粗算`695816×(4×4+4×7) = 30,615,904` cycles，即204.106ms。它是依据已生成II的服务量估算，未包含每次有限loop的填排，不是实际全图时间。子报告合法完整4block路径的loop latency上界18/29 cycles，SCHED又在ST_187–194和ST_197–204对同一FDiv作两个串行8状态调用；后继须实测每组完整阶段，不能把上述估算冒充运行结果。
* 若未来只给quant 5ms，150MHz仅750k cycles：两遍串行扫描至少需60个值/拍，可选64lane作为几何候选；若两遍独立重叠，每遍至少30个值/拍，可选32lane。32lane每拍一完整group，需要2个II1 FDiv服务（d_full和inv各一路）及1group/拍的half转换、32个scale FMUL/round/convert。2group/拍还要相应翻倍；当前一个FDiv和两个quant FMUL不能支持。所有速率是预算条件，具体资源特别是divider LUT/频率尚待报告，不能把IP黑盒式零估算当免费。

因此C1先让8lane真实兑现以测系数；接近50ms的正式方案须再选择更宽quant或经owner验证的跨tile重叠，不能只把dot和FP恢复扩大8倍。

## 4. 后续 C2：装载、缓存、排出与可重叠范围

当前首版全链串行是有效基线。C1完成后，按测得占比考虑以下明确结构：

* **并发q0/q1装载**：两独立burst队列、每bank返回FIFO和单写仲裁。一拍两512bit返回会给4个256bit bank word，8bank有足够总写容量，但两shard相同pair可碰撞；必须真实缓存/反压，不能只错开固定周期假定返回延迟一致。冻结t/shard/原BO字节布局不变。
* **scale/错误校验**：每收到一组8scale即并行检查half指数/符号，维护原`n*G+g`最小错误rank，等全scale读取后才判断bias错误；-0合法、负有限值非法、NaN/Inf非法。无需先顺序调用half_to_f32才能判断这些条件。始终保持原全span加载字节和scale-before-bias首错；若预取/并行读bias，不能让其异常提前退休。
* **FP输入存储瘦身**：FP输入当前占128BRAM18，仅为量化暂存。后续可用流式两组或多组缓冲，保留全A8任务cache跨N重用；若中途quant失败仍按现行原行为完成规定输入读取/排空，不能擅自减少读字节。该变体与C1分开，避免同时改变输入/错误生命周期。
* **lane_bad清理**：先直接32bank同时写、每tile一拍，降低当前逐bank循环；再审核32bit mask packing，避免一个bit占一个BRAM18。epoch/tag办法只有在复位、wrap和错误路径设计齐全后才采用。
* **输出**：内部bias服务与输出FIFO独立，按连续地址合并burst。先保留32bit外口测其天花板；另版本若改512bit out0/out1，必须更新隔离top ABI/端点打包/WSTRB/4KiB切分与QKV散写，在16维连续小段内聚合，不改BO布局或少写尾部。
* **双buffer选择**：先考虑小A/PS缓冲，只有LOAD实测成为主瓶颈才复制W。按当前HLS系数双Wq即512URAM，960总量尚需留其他核/shell；不能用“还有704URAM”当平台可用余量。TN增宽可重分列bank并减深度，不必把相同权重容量按TN成倍复制，但原语粒度及SLR布线仍需实测。

任何重叠只在独立存储端口、owner和真实有效/完成信用证明后写进预算。当前数据不能用各段max代替相加。

具体owner边界如下：当前controller `linear_impl` 先LOAD_W一次，再对每个B/row16同步完成QUANT→LINEAR，最后才publish整个目标；当前隔离top同样直到report结束才允许下一命令。**仅给RAM加第二份指针不会让现有ABI支持命令重叠。** 同一个QUANT内部的两遍跨group流水可以作为C1私有实现，仍全rows成功才发布A8，不改变外部owner顺序。

下一任务的quant与当前compute重叠则需正式新增内部双context队列：保留输入源owner直到其全部rows已读；两个私有A槽各有task/epoch、FILL/READY/IN_USE状态，当前linear最后一次A读取并逻辑退休前不能回收该槽；下一quant可以填另一槽，但只有其整tile成功才READY，且不得抢先提交可见Done顺序。PS槽也只能在最后group提交、输出全部B响应收到后释放，不能按最后issue释放。出错需停接新工作、排空所有已接事务、作废对应未发布epoch后恢复。当前scorer原位lease必须保持源读取结束前不覆盖源区（controller:731–738），QKV仍需所有rows/plane/head完成后publish（:263）。这些更改应在生产集成合同和TB中单独设计，本文没有授权把现有状态位提前置READY。

W装载与计算跨矩阵重叠还要两个独立W槽及“当前WeightKey只读占用”和“下一WeightKey装载/校验”context。先由controller可证明地确定下一矩阵描述符/来源/错误优先级，只有inactive槽可FILL；当前槽所有B/row消费者用完才释放。新的预取必须由集成controller或新版明确命令队列承载，当前LOAD/RUN独立命令串行接口不提供这样的重叠。故这是C2后继，不计入C1的已可用收益。

## 5. 50ms 目标的联合资源必要条件

以150MHz、B1/S128 Q8工作量47,160,754,688 MAC、GS32且把完整50ms都让给Q8为例：

`Q8 dot-groups = 1,473,773,584`；所需`196.5031445 group/cycle`，即6288.100626 MAC/cycle。对应持续服务至少196.50个I32→F32、393.01个FMUL、196.50个FADD每拍；如果全部复制整数个II1服务，可取197转换/394FMUL/197FADD。当前一个FMUL无法通过提高整数lane数补齐这一缺口。

以下全部是**条件算术**，使用“每INT8乘法1DSP、本次FMUL3DSP、FADD2DSP”的简单映射，不是最优实现下界；INT8打包、LUT混合或FP实现改变会改变资源但均须证明数值及映射。

| 几何 / 条件 | Q8整数MAC/拍 | dot/拍 | INT DSP | 恢复DSP | 两者合计 |
|---|---:|---:|---:|---:|---:|
| TM4/TN8，每拍完整issue | 1024 | 32 | 1024 | 256 | 1280 |
| TM16/TN8，每拍完整issue | 4096 | 128 | 4096 | 1024 | 5120 |
| TM16/TN16，每拍完整issue | 8192 | 256 | 8192 | 2048 | **10240** |
| B1 Q8占满50ms的连续速率条件 | 6288.10 | 196.50 | ≥6289离散通道 | ≥1576按197通道 | 约7865 |

U55C裸器件有9024DSP/960URAM（TOPXML AvailableResources），TM16/TN16上述直接DSP实现光Q8整数+恢复就超过9024，尚无量化、Attention、向量、地址、shell。若对8192 INT乘法用“一DSP两INT8”则整数条件值4096DSP+恢复2048=6144，但有符号打包/交叉项隔离/纠正/时序尚未设计证明，不能把6144当可用实现；采用一部分LUT乘法同样要给实际LUT/布线成本。扩大TM/TN之前应先证明C1每group服务系数及可选映射。

TM16/TN16的B1理想Q8时间38.38ms，剩余约11.62ms只有约1.743M cycles。合同的QK+AV合计1,006,632,960次FP乘法贡献，即使把这全部剩余时间都分给它们，也需约577.6贡献/拍及相应规定顺序的加法；还没有softmax/LN/GEGLU/Host/IO。这揭示现有150MHz/50ms端到端目标很紧，不能把各段各自50ms相加。B2 Q8工作量翻倍，TM16/TN16纯Q8下界76.76ms，已超整次请求50ms。

正式预算应写为`C_request = C_Q8_dot_restore + C_quant + C_Attention + C_vectors + C_control + C_IO_nonoverlap`，只减去已证实的重叠；Host还应按冻结计时范围另纳入。令Q8点积恢复实得预算为Cq且有效率u，要求物理恢复通道数`P >= ceil(Q8_MAC/(32*Cq*u))`，整数吞吐与FP/PS/bank供给均要达到P。当前不填写未知u或其他核可用余量。新fe067完整核和真实shell资源未闭合，旧04934不能用于扣减。

外部有效带宽同样是必要条件。fe067 manifest的122次Q8加载复算为q0+q1=369,362,944 B、scale=23,085,184 B，合计392,448,128 B，B1/B2相同；50ms若全部用于装载，两口各约3.694GB/s、scale约0.462GB/s。当前串行shard、scale校验和其他流量会增加时间。所有Q8输出共158,138,376 B（B1）/316,276,752 B（B2），50ms内B1输出平均要求约3.163GB/s；两个32bit口在150MHz同时满载也仅1.2GB/s原始总量，实际普通矩阵只走out0，故保留当前外部落地输出方式就有超过131.78ms的全局聚合传输下界。该下界假定所有这些输出都按当前隔离原型方式送外存；若生产集成让部分结果直接片上消费，应按实际减少的字节重算，不能无证扣减。

Host常驻策略不能删除：mission§5要求模型BO在初始化上传、请求复用BO和模型；`reviewer_host_session_offline_v1_design_cpu_preparation_release.json` 的 `frozen_contract` 明确每请求清零/H2D七个workspace合计192,937,984 B（184MiB），另有IO32,768 B、结果D2H384 B。不与上述每请求约184.68MB/口的Q8权重读取混为一件事。冷启动五模型BO总448,923,648 B与常驻请求计时分别报告；本次没有测量Host耗时或证明这些清理/同步可省略。50ms完整Host请求要包含输入准备、同步、kernel、回读和后处理。

## 6. 次正规与逐位数值边界

### 6.1 half 次正规与恢复 FP32 次正规要区分

合法非零half scale范围为[2^-24,65504]，转F32后都为正规数。两个half scale乘积的最小正值2^-48，最大小于2^32；half有效位≤11，两者乘积≤22有效位，可在F32中精确表示。每个dot是整数（最坏绝对值≤524288），F32转换精确；term非零最小≥2^-48。所有half都是2^-24的整数倍，所以scale product及其后正确F32舍入的term、逐group PS均是2^-48的整数倍；bias前的非零PS不可能落入F32次正规区。合法G≤128也远未接近F32溢出范围。此为值域推导，不是已新增测试。

因此half解码必须保留F16次正规，但不能据此泛称Q8恢复两个FMUL/FADD必须处理任意F32次正规。仍需负dot、零dot、±0scale、组间抵消与RNE ties的实际逐位验证；偏置另有更广值域。

### 6.2 确实可能影响功能的 F32 边界

* 正常F32输入组最大值设为`amax=127×2^-127`，精确R0得到`d_full=2^-127`（F32次正规）、`inv=2^127`（有限）、保存half为0；最大输入的q仍应127。如果div输出/下一算子的输入把d_full清零，可能得到q=0或其他不符结果。这个例子不依赖输入本身为次正规。
* `amax=2^-126`时，除以127得到非零次正规d_full，倒数溢出，R0应在该group报E_NUMERICAL；若d_full被FTZ成0并走零组路径，会错误接受。相反极小`amax=2^-149`除以127正确舍入为0，此时R0的零scale/零q本来允许，不能统一拒绝所有小输入。
* 混合正常amax与极小输入时，`group[i]*inv`可以是F32次正规；其绝对值远小于0.5，最终roundf得到整数0，FTZ在该单项上可能不改变q，但这不放行前述scale/倒数差异。amax比较若基于位型 unsigned max，可保留小值次序并单独判finite。
* 若bias前PS恰为0而合法F32 bias是次正规，`old+bias`应保留该bias；若生成FADD采用FTZ则可能输出0。PS非零时最小量级2^-48，与可抵消的F32 bias的分辨率至少在2^-72附近，不会靠这类抵消产生F32次正规；直接零PS加次正规bias仍是必要边界。

本次检查的FP XCI采用Rate1、NonBlocking、各自指定latency，`C_HAS_FMA=0`。**`C_HAS_UNDERFLOW=0`仅说明没有下溢报告端口，不能从该字段判断是否支持次正规。** 未找到这些XCI显式给出的通用denormal保留保证；既有独立review也保留“recipes不能证明every finite input的R0/no-FTZ”边界。应在独立受控fixture中跑上述divider/reciprocal、half转换、bias用例；不改原oracle、误差线或first-error含义。若真实wrapper失败，由主设计角色选择兼容路径或精确修补后另发新身份。

## 7. 全维数值运行需要的只读观察器

观察器只读真实RTL信号，不force/deposit、不驱动内部RAM、不改FSM。所有状态名绑定当前top SHA，换生成版本必须重核。原report里的counters只作最终语义交叉核对，不能直接视为每拍事件。

| 观测对象 | 当前可绑定的真实位置 / 条件 | 产出与注意事项 |
|---|---|---|
| accepted start→done | `dut.ap_CS_fsm_state1 && dut.ap_start` 到第一次 `dut.ap_done` | 该top的ap_idle在start=1时为0，不能用`ap_start&&ap_idle`定义接受；done由state1675的report done产生（RTL45743） |
| quant统计/重放 | `grp_q8_joint_tm4tn8_Pipeline_VITIS_LOOP_602_27_fu_11845` / `...634_29_fu_11874` | 记录子函数真正开始、ready/完成、block取数/组写；不能把静态ap_done在idle时高电平当结果 |
| 激活LOAD、W LOAD、scale LOAD | Pipeline583...fu11812，Outline521...fu11720，Pipeline535...fu11751 | 配合外口真实R握手、ARLEN/字节记录阶段，split全部read数据与等待，不用端口512bit乘cycle当有效字节 |
| 每个逻辑vector issue | `dut.ap_CS_fsm_state312 && !dut.icmp_ln708_fu_23172_p2` | 这里一拍进入有效tile；读`tile_2_reg_6981`及已审核g/m0寄存器，统计相邻issue间隔和尾mask |
| vector完成 | `dut.ap_CS_fsm_state1623 && !dut.ap_block_state1623` | 此拍tile加1并返回state312（RTL36135/59736）；可能包含被选trace的响应等待，不等于FP最后加法延迟 |
| 每lane dot归约 | lane0 `grp_q8_joint_tm4tn8_Outline_VITIS_LOOP_225_2_fu_11890`；lane1 `...225_22_fu_11927`，按实例表枚举32个 | 以子模块state1&&start记launch，结果`level_*_out_ap_vld`/真正ready记完成；统计各lane有效次数、并发峰值与服务周期 |
| half服务 | `grp_p_anonymous_namespace_half_to_f32_fu_11775` | 分h的exp=0/mant!=0计次正规服务分布；用真实开始/ready，不以ap_done静态电平累加 |
| 有用FP发射 | BIND+SCHED的semantic launch state；或PS成功写计数反查 | U1448/U1449/U1451的CE全部接1，wrapper的a_tvalid也常1，不能把CE/valid当有用操作利用率 |
| PS读写与反馈 | 32个PS RAM实例的`ce0/address0`及`ce1&&we1/address1` | lane0为`ps_U`，其余`ps_35_U...`及`p_ZZ15...ps_10_U...ps_31_U`；记录同address读→写→再读间隔、mask、last_g，核与R0 trace一致 |
| W/A bank供给 | W8、A4、scale对应真实RAM口 | 同vector的W重复读取量、广播复用是否兑现；bank不是ready/valid协议，空闲ce=0不能一概归为bank stall |
| trace / output / report | observed/out0/out1的AW/W/B真实握手及地址范围 | trace on/off差值、WSTRB有效字节、每burst长度、写响应排空，报告串行wall和有用传输拍 |
| stall原因 | FSM/子调用done等待、AR/R/AW/W/B背压、PS地址hazard、FIFO信用 | 定义互斥主因优先级，再保留原始重叠位图，不能重复加总多个同时成立的stall占比 |

**特别陷阱：** `c_issued_2_fu_1918` / `c_retired_2_fu_1922` 被HLS优化为按T批量更新。RTL33122–33126、33190–33194及63923/63927表明它们不能作为每issue strobe，直接计“寄存器发生变化次数”会少计。同样，FP wrapper每拍valid高只表示自由运行物理IP，不能声称100%有效利用率。

合法shape的语义交叉核对期望：`issued=ceil(rows/4)*G*T`，无数值错误时有效dot数=`rows*N*G`、MAC=`rows*N*K`、PS有效group写同dot数，output=`rows*N`。错误用例必须按被冻结原顺序的lane_bad/quant成功前缀另核，不能套合法式。Scorer r1 K1024/N1024应有4096次逻辑vector、32768个有效dot、1048576个有效MAC；每vector只有1行有效，即使C1也受TM尾部利用率限制。r1结果不能直接冒充r4/r16利用率。

输出建议使用有界计数器/直方图和少数首尾事件，保留每命令 accepted起止、各stage周期、issued/retired间隔min/max/sum、每lane服务计数、RAM/AXI字节、stall分类及inflight峰值。无需导出巨型逐周期波形；首例实测后由主Astra决定进一步窗口与运行预算。

## 8. 决策次序及未闭合项

1. 完成既已放行准备的全 K/N scorer三命令及只读观察，得到可信LOAD/quant/compute/output/trace分解，保留ACT36原接受结果。
2. 主设计据本文和实际系数冻结C1：常数树、明确乘法映射、32完整R0通道、8W/4A/32PS供给、half广播/固定解码、hazard与首错退休。量化的bank/max/乘法/round应联合修改，不能只放一条UNROLL。
3. 同几何新身份完成逐位CPU/CSim、真实RTL的完整K/N/尾行/N2反馈/背压/half及F32受控边界，再做同源OOC确认DSP/URAM和时序。没有OOC前，本文资源仍是HLS值与条件预算。
4. 再决定C2重叠/存储/端口变体和TM/TN扩展；与Attention及其他核放入同一资源、延迟、外部带宽预算。新fe067完整核/shell余量未知时不声称可集成或达到50ms。

本分析没有观察到新的实测II、MAC/cycle、Fmax或利用率；没有重跑已接受ACT命令，没有将静态调度状态编号当周期测量。对应JSON保留所有关键原始文件哈希、机械统计、schedule定位和明确的未验证项。
