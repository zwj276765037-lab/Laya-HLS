# B1/S128 完整图流水联合预算（2026-10-10 重新核算）

本次结论：**当前 TM1/TN8 单共享 Q8 引擎不能支撑 50 ms 首请求，也不能支撑示例性的 50 ms 完成间隔。跨请求重叠能改变完成间隔，但不会消除每请求在共享 Q8、LOAD、Attention 和向量引擎上的总服务量。** 150 MHz 始终是假设，不是实达 Fmax；20 B1/s 只是吞吐预算例子，未新增硬指标。以下只排除明确映射、时钟、资源及调度条件，不声称 U55C 在所有架构下都不可能。

本轮只读既有源码/报告并作有限复算，不修改 RTL，不新增 HLS/OOC/P&R 或长仿真。旧[联合预算](../attention_rtl_repair_20261008/laya_u55c_50ms_joint_budget_review.md)及其 JSON 冻结；本文件是唯一新增预算正文，机器结果见 [pipeline_budget.json](pipeline_budget.json)，生成器见 [recalculate_pipeline_budget.py](../../tools/recalculate_pipeline_budget.py)。阶段动态状态仍由[原结果表](stage_results.md)维护。

## 1. 固定对象、CPU/FPGA职责与证据等级

使用[当前 v4 manifest](../../build/model-cpu-embedding-ln-v4-20261010/manifest.json)：真实 GGUF SHA256 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，manifest SHA256 `093bd662096f8c539529072d09d33f3b5a7f666125e21adaaf7ece20348c5915`。model/numeric/layout/build tag 分别为 `6eb6ef58bc4f99bd9db40381604108af` / `aeb13e7937d29fe6a2c68c407249f294` / `f927881686d9d11c91b7f11ac59e2cc7` / `147c8e8554927239ed5981bdde25861c`。固定 B1/S128、28 Encoder、2 Decision、16 marker 槽及全部 122 张 Q8 矩阵，不改精度、图、shape、数据集或独立 gold。

| 位置 | 本次保留的工作 |
| --- | --- |
| CPU | 真实 token Embedding 查表/反量化，生成 128×1024 F32 raw；请求、同步、结果解码 |
| FPGA | raw 描述符/CRC/有限性校验；全部 LN（含 LN_EMB）；Q8/Attention/RoPE/GEGLU/残差；EMB_TYPE、Decision、scorer/ACT |

实测只指已有隔离 fixture 的 RTL 周期。公式结果分别标为数学工作量、既有调度外推或未来条件候选；它们不是完整图 RTL、实际板卡吞吐或数据集准确率。当前模块身份与旧整体资源身份不同，不能拼成同一完整核 PASS。

当前 [Q35/pack/TX 集中接受](contract/design.md#69-q35packtx与连续run本轮集中限定验收)的范围保留：QKV1 trace-off 每 RUN 外层命令接受→首次 done 为 18,933 cycles，两个合法同权 RUN 的完成间隔 18,935 cycles；QKV4 为 65,463 cycles；QKV1 trace-on 为 20,797 cycles；冷 QKV LOAD 的同口径 TB 段为 488,555 cycles。它们包含控制配置/轮询及真实响应退休，不是内部 HLS AP 周期。QKV1 非末组 11,904 次 issue 的间隔为 1.000 cycle；全窗口仍有 860 个 credit 间隙，QKV4 为 3,710 个，固定 slave `B_HOLD=9` 是该压力条件的一部分。局部算术 II=1 不代表完整请求吞吐。

已有[冷前端观测](attempts/cpu_front_rtl_03/phase_observations.json)为 reset 释放后 31,158,417 cycles，即条件 207.723 ms；含导入、LN、控制和 TB 反压，不是板上不可改善下限。其 origin 不同于 QKV RUN，不能直接相加冒充新端到端实测。历史 HLS 21.308 ns、OOC42 WNS −12.019 ns 仍未通过；本轮不据功能仿真宣称 150 MHz 已达。

## 2. 延迟、完成间隔及共享资源的计算规则

令完整请求接受/完成时刻为 `a_i/d_i`：首请求延迟 `L_first=d_1−a_1`；有限平均完成间隔 `I=(d_N−d_1)/(N−1)`，`N≥2`；达到稳态后吞吐 `R=1/I`。矩阵 RUN/s、group/cycle 和 B1 请求/s 分别报告，不能互换。

当前 controller 同步逐任务 issue/完成，单 request owner、单 current_weight、单 A8/PS；完整请求中多次往返 Q8→向量→Attention。当前串行阶段必须相加。对资源 r，必要条件是 `I ≥ 每请求在 r 上的总工作 / r 的有效服务率`，不是对 30 层逐层取最大值。Q8 的 122 张矩阵全部累加；在一条 shared DSP 池上执行的工作也全部累加。

只有增加独立引擎、上下文、真实 buffer 端口、任务调度和错误隔离后，跨请求的候选间隔才可写成各独立资源总服务量的 `max`。这仍只是下界：重入依赖、权重换入、端口争用、首尾空泡及阶段负载不平衡可能使它不可达。首请求仍沿依赖路径经过各阶段并经历填充/排空，不能用间隔代替延迟。有限N请求的总完成时间只有在稳定调度成立后才近似 `L_first+(N−1)I`；第一张权重、第一份输入、最后输出B/错误排空与Host结束动作不能从首尾预算删除。

当前单 W bank 被 RUN 使用时不能覆盖下一矩阵，故 LOAD 与该 Q8 引擎的计算服务相加。HBM 常驻模型只删除重复 Host 模型上传，不删除 HBM→片内 LOAD。跨请求把同一矩阵集中处理以摊薄 LOAD，需要明确的请求波次、每请求 owner/epoch、激活存活期及更长延迟；本预算不默认这种重排已实现。

## 3. 全部 Q8 工作、几何利用率与 R0/DSP

当前 manifest 与 controller 的全量工作如下；GS=32，`R0组数=MAC/32`。每个有效输出 group 需一次 INT→F32、两次独立 FMUL、一次按 group 顺序的 PS FADD，禁止 FMA/重结合。

| 家族 | 矩阵数 | R / K / N | MAC / B1 |
| --- | ---: | --- | ---: |
| Encoder QKV | 28 | 128 / 1024 / 3072 | 11,274,289,152 |
| Encoder Wo | 28 | 128 / 1024 / 1024 | 3,758,096,384 |
| Encoder Wi | 28 | 128 / 1024 / 5248 | 19,260,243,968 |
| Encoder Down | 28 | 128 / 2624 / 1024 | 9,630,121,984 |
| Decision QKV | 2 | 128 / 1024 / 3072 | 805,306,368 |
| Decision Wo | 2 | 128 / 1024 / 1024 | 268,435,456 |
| Decision FC1 | 2 | 128 / 1024 / 4096 | 1,073,741,824 |
| Decision FC2 | 2 | 128 / 4096 / 1024 | 1,073,741,824 |
| Scorer FC1 | 1 | 16 / 1024 / 1024 | 16,777,216 |
| ACT FC2 | 1 | 1 / 256 / 2 | 512 |
| 合计 | 122 | 全部 Q8 | **47,160,754,688** |

总 R0 组数 1,473,773,584；输入量化组 695,816，输入 22,266,112 个 F32；Q8 输出 39,534,594 个 F32。controller 每任务至多 16 行，共 962 个 QUANT 和 962 个 LINEAR。几何周期按每个任务分别求 `ceil(rows/TM) × ceil(N/TN) × K/32` 后全图求和，不能把 TM>16 的空行算作有效算力。

| TM/TN | 并行输出 group 通道 P | 理想 issue cycles | 条件 Q8 ms @150 MHz | 当前树+R0 DSP 直扩 |
| --- | ---: | ---: | ---: | ---: |
| 1/8 | 8 | 184,221,704 | 1228.145 | 384 |
| 4/8 | 32 | 46,055,432 | 307.036 | 1,536 |
| 16/8 | 128 | 11,513,864 | 76.759 | 6,144 |
| 16/16 | 256 | 5,756,936 | 38.380 | 12,288 |
| 16/24 | 384 | 3,849,896 | 25.666 | 18,432 |
| 16/32 | 512 | 2,878,472 | 19.190 | 24,576 |
| 32/16 | 512 | 5,756,936 | 38.380 | 24,576 |

TM32/TN16 在当前任务边界只有约 50% 利用率；TM16/TN24 因 N 尾部为约 99.6898%；其它大矩阵大致整除但 ACT 仅一行/N2，不能声称所有 issue 100% 有效。当前 TM1/TN8 几何比简单 `MAC/256=184,221,698` 多 6 cycles；ACT 实际另有同一 PS tile 反馈等待，理想几何不包含它。

**修正旧预算的 DSP 口径。** [OOC42 来源](../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/results.md)中整数树为 320 DSP / 8 通道：32 个乘法 DSP + 8 个树加法/PCIN DSP 每通道。若继续采用 FMUL=3 DSP、FADD=2 DSP，R0 的两乘一加再需 8，因此直扩为 **48 DSP/P**，不是旧表的 40。旧 whole-top 458 DSP 是旧身份实测资源；384 算术之外的 74 不能当作任意宽度都固定不变的完整额外开销。

| 每通道条件 | DSP/P | 仅 Q8 把裸 9024 DSP 全用尽的工作量下界 ms | Q8+QK/AV 共用裸 9024 DSP 的下界 ms |
| --- | ---: | ---: | ---: |
| 当前整数树、单乘法/DSP、原 R0 | 48 | 52.261 | **55.968** |
| 树加法改 LUT，尚未证明 | 40 | 43.551 | 47.258 |
| 两个 signed INT8 乘法/DSP，保留当前树，packing 未证明 | 32 | 34.841 | 38.548 |
| packing2 与 LUT 树同时成立，均未证明 | 24 | 26.131 | 29.837 |

这些是松弛的 DSP 工作量条件，允许完美利用/分时且不给 shell、quant、LN、非线性、buffer 控制留 DSP；不能作可实施方案。以当前 48 映射和 150 MHz，20 B1/s 的 Q8+QK/AV 已需平均 **10,101.14 DSP**，大于裸 9024，尚未算其它块。换时钟、树映射或 packing 会改变结论；packing2 需要 signed 乘法隔离、串扰修正、溢出与精确性验证，不是默认可用能力。

## 4. LOAD、量化、Attention 和向量服务必须完整计入

### 4.1 真实权重 LOAD 与 scale 校验

122 张矩阵的 q0/q1/scale 为 184,682,496 / 184,680,448 / 23,085,184 B，合计 392,448,128 B；bias 另 77,832 B。源码[LOAD 路径](../../vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/source/q8_tm1tn8_joint_dma.cpp)先 q0，再 q1，再 scale unpack 与 bias 读取，之后按 padded n→g 做全部 scale 有限性/非负校验，最后校验 bias。

当前布局逐矩阵满足 `scale_span=ceil(N/8)×8×G×2`。因此校验数准确为 11,542,592，真实 N 的数目 11,542,544，多出的 48 全来自 ACT 的 N2→N8 填充。不能跳过 padding，也不能按有效 MAC/R 行数错误重复校验。HLS30 的 [scale 内循环报告](attempts/task2_joint_dma_hls_30/work/hls/syn/report/q8_tm1tn8_joint_dma_Outline_VITIS_LOOP_576_18_csynth.rpt)为非流水 4 cycles/项；QKV 的 98,304 项即约 393,216 cycles，与冷 LOAD 主因一致。

| 当前成功路径服务外推 | cycles / B1 | ms @150 MHz |
| --- | ---: | ---: |
| q0→q1，合计 64 B/clk 理想 payload | 5,771,296 | 38.475 |
| scale unpack，16 B/clk | 1,442,824 | 9.619 |
| 11,542,592 scale × 4 cycles | 46,170,368 | 307.802 |
| 串行已知主体合计 | **53,384,488** | **355.897** |

这不是整网实测；遗漏 bias、首尾循环、实际 AXI/控制等只会增加当前成功路径成本。若仅将 checker 改成一项/拍而仍保留单 W 和当前 LOAD 次序，主体也为 **125.045 ms**；若希望 50 ms 完成间隔，仅 checker 的平均需求已为 1.539 项/拍（20 B1/s），一个一项/拍扫描器仍不够。future 双 q 并行+scale 并行的 payload 乐观 19.238 ms 不包含 checker；必须另给 checker、bank 端口及预取 buffer 资源。

### 4.2 量化与除法

全部 Q8 输入 89,064,448 B。当前完整输入先读后量化时，一条 512-bit 150 MHz 口仅 payload 需 9.278 ms，不能随量化 lane 扩大而消失。两遍扫描 22,266,112 个元素，8/16/32/64 lane 的理想扫描时间分别为 37.110/18.555/9.278/4.639 ms；这是串行两遍。独立两遍且跨 group 流水才可减半，但新增存储、发布、divider 流水与错误处理尚未实现。

每 group 保留真实 F32 `amax/127`；非零组另做一次倒数，最坏 1,391,632 次除法。若两个独立扫描阶段均为 L lane，组速率 L/32，divider 服务能力至少 `2L/32` 次/拍；32/64 lane 分别需两/四个除法每拍。half RNE、roundf ties-away、subnormal 与独立 FMUL/转换不可替换成近似倒数。F32 输入/重放、量化输出 q/scale 和后续 A bank 的端口也必须匹配。

### 4.3 Attention：QK、softmax、AV 和反馈

30 层×16 heads×128 queries×128 keys×64 维：QK 503,316,480 次乘法、495,452,160 次相邻树加法；AV 503,316,480 次乘法和同数按 key 升序 FADD。softmax 共 7,864,320 个 score、61,440 行；QK/softmax/AV 各 3,840 个 task。按 FMUL3/FADD2，QK+AV 为 5,017,436,160 DSP-clocks，不含 softmax/scale/mask。

| QK/AV 贡献 lane F（全部真实 II1 的条件） | 64 | 128 | 256 | 512 |
| --- | ---: | ---: | ---: | ---: |
| QK+AV 数学 ms @150 MHz | 104.858 | 52.429 | 26.214 | 13.107 |
| 近似配套 FP DSP（5F） | 320 | 640 | 1,280 | 2,560 |

softmax 的 max / exp-sum / normalize 采用 8/4/8 元素每拍的候选扫描，另需 26.214 ms；精确 exp、sum 归约、div/normalize、mask、尾部和端口未计，不能免费并入 QK 或仅按比较器计。8 F32/clk 的 AV 输出若串行另需 3.277 ms。

当前一个 AV task 只有 16×64=1024 个独立累加地址。若安全反馈间隔为 F_AV，实际贡献率不超过 `1024/F_AV`。以 11 拍 FADD 类比条件为例，上限 93.09 贡献/拍；F256 引擎的 QK 13.107 ms、AV 至少 36.045 ms，再加上述 softmax 26.214 ms，Attention 服务至少 **75.366 ms**，还没计输出/装载。11 拍在此为候选反馈参数，不把另一模块延迟当作现有 Attention 已测值。更多 query/task 上下文或旁路要另立 owner/PS 端口；不能复制乘法器后忽略递推顺序。

controller 每 head 先 LOAD_KV 一次再处理全部 query tile，故为 480 次、31,457,280 B；B1 每 head K+V=65,536 B。算术侧本地 KV 操作数约 4.027 GB/B1，应由 bank/广播提供，不重复计作 HBM 读。扩大跨 query 广播可省 W/KV 读端口，但需要更多 A/Q/prob/partial 读写端口和合法存活上下文。

### 4.4 全部 LN、GEGLU、RoPE 与其余向量工作

| 工作 | 全 B1 数学量 | 条件服务，150 MHz |
| --- | --- | --- |
| LN | 7824×1024=8,011,776 元素 | 三遍 8 lane 扫描 20.029 ms；树/sqrt/div/反馈另计 |
| GEGLU | 9,404,416 输出，每项 7 FMUL+2 FADD+tanh | 4 真结果/拍需 15.674 ms，精确 tanh 实例与端口另计 |
| Residual | 7,864,320 FADD，2 读 1 写 | 8 lane 为 6.554 ms |
| Decision ReLU | 1,048,576 元素 | 8 lane 为 0.874 ms |
| Type add | 131,072 FADD | 8 lane 为 0.109 ms，EMB_TYPE 另计 |
| RoPE | 114,688×64 维；14,680,064 FMUL+7,340,032 add/sub | 保留两项乘法和独立加减；表读取/装载另计 |
| Scorer/ACT bias-GELU | 16,384 / 256 元素 | 保留独立 bias 与 GELU，不与 baked bias 合并 |
| 非 Q8 FC | Scorer FC2 16,384、ACT FC1 263,168 乘加贡献 | F32/F16 原路径与顺序累加/尾部另计 |

LN 的 61×128+16 行由 embedding1、Encoder attention27、Encoder FFN28、final1、Decision4 和 marker16 构成。每行两棵 1023 加法树、两遍 delta、square/normalize、sqrt/div；gamma 只用于 embedding/final。CPU token Embedding 不删除任何这些 FPGA LN。[LN 实现](../../hls/operators/layernorm_compute.cpp)、[向量实现](../../hls/operators/vector_full_compute.cpp)的独立 F32 规则保持。

一个共享 vector 引擎的所有这些工作必须相加，不能分别取 max；就 8-lane quant 两扫 + 8-lane LN 三扫 + 4-lane GEGLU 已达 72.813 ms，尚未计其它服务。若使用独立子流水并发，需逐一分配实际 FP/非线性实例和 buffer 端口。Wi 两半 U/G 相隔 2624，配对双读及 Wi→GEGLU→Down 的权重依赖仍存在；融合只能作为新设计，不能先扣掉流量。

## 5. 三类调度/结构放在同一张资源账上

裸 U55C 上限为 **9024 DSP、960 URAM、4032 BRAM18（2016 BRAM36）**，LUT 1,303,680、FF 2,607,360；shell 后可用量未知。下表中的分配是明确的候选配额，不是新综合资源。任何 reserve 块未映射成功前，都不能宣称候选可放入器件。

| 类别 | 联合资源与上下文 | 请求服务必要条件 @150 MHz | 判断 |
| --- | --- | --- | --- |
| A 当前同步单请求、共享 TM1/TN8 | 一个 Q8/W/A/PS；原 controller 同步；无第二 request context | Q8 几何 1228.145 + 当前 LOAD 主体 355.897 = **1584.041 ms**，quant/其它另加 | 算术单项≤0.814 B1/s；含上述 LOAD 外推≤0.631 B1/s。不是完整板上测值 |
| B 一套独立 Q8 / Attention / vector 引擎，跨请求重叠 | 仍只有一个 TM1/TN8 Q8；给 Attention/vector 独立实例与请求 buffer | 理想 `I≥max(Sq8+load,Satt,Svec,Sport,Shost)`；Q8 仍≥1584.041 ms | 独立下游不能让同一 Q8 引擎同时处理两个请求；重叠本身不能产生 20 B1/s |
| C1 一套加宽 Q8，并独立 Attention/vector | TM16/TN8：6144 DSP；F256 QK/AV：1280；quant/vector/LN/非线性配额512；控制/转换/bias配额256；合计 **8192**，裸余832 | 单 W 下 Q8+LOAD≥**432.656 ms**。checker仅改II1后仍≥201.804 ms；即完全隐藏LOAD，Q8数学仍76.759 ms | 50 ms间隔未达；512/256配额是否容纳实际精确算子未知，shell余量亦未知 |
| C2 两套 TM8/TN8 Q8，按权重/层合理分工 | 两套各3072 DSP，合计6144；Attention/vector同C1，总8192；另需两份W与独立任务状态、权重读仲裁 | 合计计算工作与C1相同；若LOAD/计算/权重分工完美均衡且两引擎真能并行，单引擎服务最大值至少 **254.707 ms**（两引擎服务总量的一半） | 这是负载均衡下界，不能保证层依赖/端口下可达；复制W、读口和调度有实际代价，仍未达示例间隔 |

C1 的 Attention 不得独占另一个 9024 DSP：它只有 1280 DSP 的算术配额。若只用一个共享 vector 执行§4.4的保守候选，72.813 ms 的三项主体已需累计服务；不能在宣称 vector≤50 ms 的同时仍沿用该速率。512 DSP 的预留不是精确 tanh/div/sqrt 资源实测，更不是一次承诺所有向量子引擎都独立并行。C2 对全量任务按TM8/TN8求ceil的计算服务总量为23,027,720cycles（ACT尾部保留），均衡下界为 `(23,027,720+53,384,488)/2/150,000=254.707360 ms`；额外 shared HBM 带宽约束、分层不均衡与 owner 切换只会增加它。

若完全舍弃 LOAD/向量/端口开销，单靠 Q8+Attention 独立固定面积引擎且单请求串行，48DSP/P 映射的连续最优分配下界为 `(sqrt(Wq)+sqrt(Wa))²/(9024f)=83.805 ms`；跨请求理想均衡下界才降到 `(Wq+Wa)/(9024f)=55.968 ms`。这清楚展示了“首请求串行路径”与“稳态资源占用”不同，同时两者仍不给其它阶段留资源。它不是 U55C 的通用架构不可能性证明。

## 6. RAM、bank、端口和权重复用的真实代价

裸 BRAM+URAM 合计 44,679,168 B，远小于 392,448,128 B 的 Q8 q+scale，不能把整个 Q8 模型全塞片内后删除 LOAD。[生产缓存](../../include/laya_full_cache_storage.h)的主要逻辑容量：Wq 5,373,952 B、Ws 335,872 B、bias 20,992 B、Aq 65,536 B、As 4,096 B、输入 tile 262,144 B、16行PS 335,872 B、gamma 8,192 B、RoPE 524,800 B、KV 1,048,576 B、score 131,072 B、AV partial 4,096 B、FP_ACT 权重 526,336 B。这里保留生产数组合法最大尺寸，不能因本次 S128 擅自把其它支持形状的存储从资源账删掉。

| 结构 | 单份估算 / 扩展影响 |
| --- | --- |
| Wq/TN8 | 自然 URAM 映射约192；旧完整 HLS曾为256，不能把192写成已实现节省；QKV原型容量不代表完整Wi |
| Wq双槽或两Q8引擎 | 按192自然估计为384 URAM，按旧256系数为512；还要Ws/bias复制、写仲裁及返回credit |
| Ws/TN8 | 容量下界146 BRAM18，8bank至少152；自然深度约168 BRAM18/88 BRAM36。旧64 BRAM18估计容量不自洽，未关闭 |
| TM16/TN8 PS | 自然256 BRAM18；128个F32每拍读+写，各512 B/clk。双端口/冲突与FADD返回次序必须真实支持 |
| 两TM8/TN8 PS | 自然各128 BRAM18、合计256，但独立上下文/仲裁增加；两份输入/Aq/As须显式分配 |
| 行广播 | TM增加时W可向多行广播，因此W不必乘TM；A、PS、scale和return端口仍随TM增长 |

完整 C1/C2 都还需上表其它缓存、Attention 的 Q/KV/prob/partial 端口、量化重放与非线性缓冲。仅容量够并不证明 bank 服务够。原 runtime 的 KV 两轴/bank、双shard或两个 PS 生命周期不是免费第二请求 context。双 W 预取还必须保留 WeightKey/epoch、最后读者释放及下一 LOAD 失败隔离；首张装载和排空不可隐藏。

当前 pack/TX 两输出口为512bit单beat、单笔未B事务，AW/W独立；新增逻辑存储约1.28kbit与Q35约2.8kbit，不是全流水缓存。对20 B1/s，out0/out1分别需2.691/0.472 GB/s（合计3.163 GB/s）；512bit150MHz理想9.6 GB/s每口并不证明事务服务能达到它。QKV固定压力下每口相邻B约13.937拍，不能用“宽口”忽略B服务，也不能把这一TB反压固定值外推成板上HBM带宽。

## 7. Host、外存流量及184 MiB workspace生存期

旧[Host](../../host/laya_host.cpp)每会话上传五个模型BO共448,923,648 B；每请求清零并同步七个workspace共192,937,984 B（184 MiB），另IO 32,768 B，合计H2D **192,970,752 B**，D2H结果384 B。该源码仍是旧入口的Host路径，未见它把新CPU raw及descriptor接入XRT的实现，不能把它记为新profile的板端验证通过。

[CPU producer](../../host/cpu_embedding_raw.cpp)已经按真实GGUF产出B1有效raw524,288 B、STATE0布局和IO描述符；CPU生产时间、文件读取/CRC、实际XRT同步均未板测。计划可以先把raw填进既有STATE0再随整BO同步，使上述H2D总字节不额外增加；若先清零同步再补raw，则再加524,288 B。两种实现必须明确，不能删除现有184 MiB同步，也不能把raw无条件重复计两次。原模型embedding BO暂保留在现有13口/五模型BO账中；CPU负责查表不自动证明可移除此BO。

只按条件Gen3×16编码后线速15.753846 GB/s计算，上述H2D payload下界12.249 ms；它不是当前平台确认配置或PCIe实测。20 B1/s对应H2D平均3.859 GB/s。首请求完整延迟还需CPU处理、输入同步、kernel、D2H/解码；若评估冷会话，另加首次模型上传，不能与常驻推理混比。

外存逻辑流量沿原F0已确认子集至少1,057,268,872 B/B1，包括Q8权重392.448 MB、量化输入89.064 MB、Q8输出158.138 MB、KV31.457 MB、Q输入/AV输出各15.729 MB、RoPE Q/K读写58.720 MB和表14.694 MB、LN读写64.094 MB/gamma8192 B、GEGLU112.853 MB、残差94.372 MB、ReLU8.389 MB、typeadd1.573 MB。CPU raw导入扫描另有524,288 B读；描述符/诊断/owner/embedding-type/tail等尚未全计，所以它是子集，不是完整总量。20 B1/s仅该子集已约21.145 GB/s；必须按实际共享端口与HBM bank分配，不能除以13个名义端口总峰值。

多请求流水必须在完成/abort全部债务退休之前保护每份workspace。未经生存期分析和地址重分配，k个并发请求需k×184 MiB：2/4/8/16/32份分别368/736/1472/2944/5888 MiB，另加IO、上下文/epoch/owner、模型与片内stage缓存。Little定律给在途数必要条件 `k≥ceil(L/I)`；例如若改造后延迟200ms而目标例间隔50ms，至少4份即736MiB，但这不是调度已经可行的证明。当前单in-flight不允许Host清零或复用活跃workspace，也不支持另一request接管共享缓存。

## 8. 频率与吞吐敏感性

| 条件频率 | TM1/TN8 Q8理想ms | 当前LOAD主体ms | 当前48映射Q8+QK/AV占裸全部DSP的工作量下界ms |
| ---: | ---: | ---: | ---: |
| 100 MHz | 1842.217 | 533.845 | 83.952 |
| 150 MHz | 1228.145 | 355.897 | 55.968 |
| 200 MHz | 921.109 | 266.922 | 41.976 |

200MHz列不等于设计能达到该频率，41.976ms也没有给其它算子/shell/Host建立可实现预算。当前历史时序失败继续保留。

| 吞吐预算例 | 完成间隔 | Q8 GMAC/s | 有效Q8 MAC/clk @150MHz | Q8权重HBM→片内GB/s | 旧Host H2D GB/s |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 10 B1/s | 100 ms | 471.608 | 3144.050 | 3.924 | 1.930 |
| 20 B1/s | 50 ms | 943.215 | 6288.101 | 7.849 | 3.859 |
| 40 B1/s | 25 ms | 1886.430 | 12576.201 | 15.698 | 7.719 |

这些平均需求不代表可随意burst供数。比平均值更苛刻的tile端口、R0返回、PS反馈、exp/div流水、最后B及重入调度必须同时满足。50ms首延迟目标保持独立；本表未把20 B1/s升级为硬门槛。

## 9. 只选择一个下一最小设计/验证候选

**候选：保持TM1/TN8、单W、原LOAD顺序及外部接口，把现有scale合法性扫描改为一项/拍；本轮只确定候选，不实施。** 它针对已经由源码、HLS调度和真实QKV LOAD共同定位的串行成本，不引入新算术阵列或借用未证明packing。全部122张矩阵的必要checker工作从46,170,368降到11,542,592 cycles时，条件收益为230.852ms；QKV单次checker可少294,912cycles（150MHz条件1.966ms）。保留payload和控制后整个LOAD不会等于这个checker数字。

具体下一范围应在原合同集中确定：允许用严格等价half位分类实现 `finite(half_to_f32(h)) && !(scale<0)`，或流水化既有实现；必须接受±0、正subnormal及正有限数，拒绝所有Inf/NaN与负非零，保持padded n→g首坏索引、scale先于bias的首因、失败不发布W、合法恢复/epoch及真实物理债务规则。验证应以独立half语义穷举65536位型和首错序列为短例，随后用原完整K/N的ACT、QKV真实LOAD/原gold与受影响RUN覆盖；不得以缩小矩阵替代。

下一次执行成本仍先用≤120s功能pilot和既有4GiB准备、Task2 8GiB/3600s/40M帽定范围；需要的新功能RTL生成沿原24GiB/3600s帽，整体OOC/P&R继续暂停。未开始这些运行。本候选通过后也只能关闭checker这一个瓶颈：单W LOAD主体仍约125.045ms，TM1/TN8 Q8仍1.228s，距50ms首延迟或示例完成间隔仍远。后续加宽/双缓冲/跨请求调度须另据本预算明确资源和owner边界，不能因这一候选PASS自动启动全图长跑。

## 10. 本轮集中结论与复算检查

本轮检查固定模型/任务几何、scale填充、整数树DSP归属与当前RAW职责；接受的是**有限离线预算更新**。数值/协议的既有限定接受保持，完整请求RTL、producer连续链、数据集准确率、实际Fmax与50ms仍未关闭。三类结构的主要约束已经分开：当前单引擎缺总服务能力；独立阶段跨请求流水缺合法上下文且仍受共享Q8服务约束；加宽/多引擎还需联合DSP、LOAD、非线性、bank/端口与Host资源，不能给每块各算一张U55C。

已独立读取Sol最终脚本/JSON并以另一段只读算术核对当前manifest全部122项、task≤16/ceil几何、量化/输出/LOAD字节、padding scale、48/40/32/24 DSP条件、Attention、联合配额、10/20/40吞吐与100/150/200MHz结果；连同证据SHA及本文件/PLAN/CONTRACT本地链接，261项断言通过。独立复核无文件写入、无EDA工具，CPU0–3/nice19/idle I/O、4GiB/120s限制内退出0。并直接检查controller依赖/行数、LOAD源码及HLS30四拍内循环、生产cache/Host/CPU raw来源，避免仅重读JSON自证。C2的独立补充算式列于§5。

最终生成器SHA256：`bfe55a99d0b21a79f12fb9cfbd6f3c32409e61ecf6ace37a7d0fa60113a6f00b`；JSON SHA256：`9bc3c789ef1b75752ce9f546c8ae4e0eaead645a6811886be0528133c31da073`。Sol的[短复算日志](pipeline_budget_calculation.log)记录PASS，最后受控运行exit0、约0.06s、峰值18,064KiB；这是计算器运行成本，不是RTL或推理性能。集中结论为**离线预算及其证据口径PASS_SCOPED，50ms/示例20 B1/s均未证明，下一仅保留scale扫描候选，不实施**。
