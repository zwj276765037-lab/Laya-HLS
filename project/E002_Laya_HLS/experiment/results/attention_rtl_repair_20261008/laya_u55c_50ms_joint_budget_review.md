# Laya U55C：B1/B2、S128、50 ms 联合必要条件审查

GPT-6 Astra / xhigh，`/root/q8_pipeline_analysis_astra_xhigh`，2026-10-09。**离线、只读推导；只新增本文件与同名 JSON。没有修改设计/实现、运行 EDA 或放行实现。** 50 ms 保持为完整一次请求的目标，B1 与 B2 分列，不把 B2 时间除以 2，也不把其他模型/精度场景的 GPU 约 25 ms 当作同口径证明。

结论：现有结构与同几何 C1 都不能据现有证据支持 50 ms。除了整数算力，R0 浮点恢复、量化、Attention、输出和每请求 Host 传输各有不可忽略的预算。扩大数组之前，必须同时解决这些服务与所有权条件。本报告给出特定映射/频率/调度下的必要条件，**不作 U55C 在一切可能实现下都不可能达标的判断，也不放宽 R0。**

## 1. 证据身份与计算口径

本轮重新读取 [fe067 manifest](../../build/model-attention-rtl-repair-20261008/manifest.json) 的全部 124 weights，筛出 dtype=8 的 122 张；按[当前 Controller](../../hls/control/full_forward_controller.cpp) 的实际 row space、B/row16、layer/head 循环复算，而非沿用旧表数字。

| 来源 | 本次使用范围 |
| --- | --- |
| [42 来源只读分析](q8_pipeline_analysis_astra_xhigh.json) / [分析说明](q8_pipeline_analysis_astra_xhigh.md) | 当前 Q8 v3 的绑定、8W/4A/32PS bank、数值语义和既有结构事实 |
| [C1 详细草案](q8_c1_arithmetic_pipeline_design_draft.md) / [独立接受记录](reviewer_q8_c1_detailed_arithmetic_pipeline_design_review.json) | 候选合同已接受；实现/执行仍等待 Scorer 观察及具体源/预算审核 |
| [原性能报告](../../vivado/project/source/performance_and_interfaces.md) | §5–7 的工作量和来源线索；其旧 04934 调度/OOC 不移植为 fe067 新性能 |
| [修复合同](repair_contract.md) | §1.1、§2、§4、§7.15：计时边界、R0、共同预算、完整覆盖及所有权 |
| [Attention 原规格](../../vivado/design_source/11_attention_and_fp_engine.md) | 64 路共享 FP 是候选；QK+AV 相加，softmax/反馈/输出另计 |
| [LN](../../vivado/design_source/07_layernorm_engine.md)、[Quant](../../vivado/design_source/08_activation_quantizer.md)、[FFN](../../vivado/design_source/12_vector_and_ffn.md) | 三遍 LN、两遍 Quant、4 路 GEGLU、8 路 residual 等候选服务率，均非已测吞吐 |
| [加载/缓存](../../vivado/design_source/05_hbm_loader_and_cache.md)、[平台](../../vivado/design_source/02_kernel_wrapper_and_platform.md) | RAM 生命周期、512-bit/150 MHz、65% 效率仅条件；参考 Gen3x16 平台不是实际链路确认 |
| [Host 冻结合同](reviewer_host_session_offline_v1_design_cpu_preparation_release.json) | 每 session 模型上传一次；每请求 workspace/IO 清理和 H2D 不删除 |
| [Attention cold 正式验收](reviewer_attention_v5_cold_static_v2_full_functional_acceptance.json) | 现已接受 B1/S64、Decision0、head0/query0 四命令数值/协议；不等于全 Attention、全网、II/Fmax 或 OOC |

JSON 保存新计算的 122 张逐矩阵记录、源/报告哈希、公式和条件。旧逐任务重建 JSON 绑定的是旧 Controller SHA `7e73939e…`；本轮当前 Controller 为 `23e428c8…`。数学形状经当前源复核可用，旧周期/资源不因此升级。当前 fe067 build tag 为 `fe067c8aa0627ad770096f9721394645`。

所有时间表默认**条件频率 150 MHz**、1 ms=150000 clocks，GB/s 十进制，KiB/MiB 二进制。当前 v3 HLS 估计 21.308 ns，不证明 150 MHz 已达成；本文未把估计周期倒数当板级 Fmax。

## 2. 从完整图重新计 Q8、量化与输出

Controller `linear_impl` 每矩阵先 LOAD_W 一次，再对全部 B 和源行以 ≤16 行 task 同步 QUANT→LINEAR。Encoder/Decision 源有 S=128 行，Scorer 有 16 行，ACT 有 1 行。每个 QUANT 供完整 N 复用，不按列 tile 再量化。

| Q8 family | 张数 | K→N | B1 MAC | B1 Quant GS32 组 | B1 F32 输出 bytes |
| --- | ---: | --- | ---: | ---: | ---: |
| Encoder QKV | 28 | 1024→3072 | 11274289152 | 114688 | 44040192 |
| Encoder Wo | 28 | 1024→1024 | 3758096384 | 114688 | 14680064 |
| Encoder Wi | 28 | 1024→5248 | 19260243968 | 114688 | 75235328 |
| Encoder Down | 28 | 2624→1024 | 9630121984 | 293888 | 14680064 |
| Decision QKV | 2 | 1024→3072 | 805306368 | 8192 | 3145728 |
| Decision Wo | 2 | 1024→1024 | 268435456 | 8192 | 1048576 |
| Decision FC1 | 2 | 1024→4096 | 1073741824 | 8192 | 4194304 |
| Decision FC2 | 2 | 4096→1024 | 1073741824 | 32768 | 1048576 |
| Scorer FC1 | 1 | 1024→1024 | 16777216 | 512 | 65536 |
| ACT FC2 | 1 | 256→2 | 512 | 8 | 8 |
| **合计** | **122** | | **47160754688** | **695816** | **158138376** |

| 整次请求 | B1/S128 | B2/S128 |
| --- | ---: | ---: |
| Q8 MAC | 47160754688 | 94321509376 |
| R0 dot-group 数（MAC/32） | 1473773584 | 2947547168 |
| I32→F32 / PS FADD（各） | 1473773584 | 2947547168 |
| 恢复 FMUL（每 group 两次） | 2947547168 | 5895094336 |
| Quant 输入 F32 元素 | 22266112 | 44532224 |
| Quant GS32 组 | 695816 | 1391632 |
| QUANT / LINEAR task（各） | 962 | 1924 |
| Q8 F32 输出元素 | 39534594 | 79069188 |
| Q8 输出 bytes | 158138376 | 316276752 |
| 有 linear bias 的输出元素 | 2375682 | 4751364 |

`Q8_MAC(B,S)=B×[S×368312320+16×1024²+256×2]`。B2 数学工作量翻倍；122 次权重装载和固定 Host workspace 不翻倍。量化组数 695816 与恢复 dot-group 1473773584 是不同计数，不能相互替代。

## 3. 当前结构、C1 与扩大数组分别能说明什么

现有 v3 是 ACT 功能闭环结构，不是持续 1024 MAC/clk 电路：1024 个组合 INT8 LUT 乘法、32 份动态非流水归约，32 lane 的 64 次恢复乘法共享一路 FMUL，FADD/转换也共享。仅共享 FMUL 的服务上界已是 0.5 dot-group/clk=16 MAC/clk，尚未扣其它开销。21.308 ns 最长估计链在 quant amax。旧完整 top 04934 的分钟级条件估算与旧 437 DSP/OOC 也不能充当当前 fe067 成功整网资源。

C1 候选改为固定五级整数树、32 条完整恢复通道、真实 bank/credit/hazard、8 路 quant，保持单 W/A/PS 和 LOAD/compute 分阶段。已接受 ACT36 与新 Attention cold 四命令仅证明各自功能范围；尚无 C1 实现、全维 Scorer 性能、完整 fe067 OOC 或板级性能。无板卡阶段继续离线。

以下按每向量 issue II=1、不停顿，仅计 Q8 几何服务；逐矩阵用 `ceil(R/TM)×ceil(N/TN)×G`，已计 ACT 尾行/尾列及 TN24 列尾，尚未计 PS 反馈/填排/量化/输出/LOAD。

| 几何 | dot-group/clk | B1 理想 ms | B2 理想 ms | INT 1乘积/DSP＋恢复 DSP | 假设 INT 2乘积/DSP＋恢复 DSP |
| --- | ---: | ---: | ---: | ---: | ---: |
| TM4/TN8（C1） | 32 | 307.036 | 614.072 | 1280 | 768 |
| TM16/TN8 | 128 | 76.759 | 153.518 | 5120 | 3072 |
| TM16/TN16 | 256 | 38.380 | 76.759 | 10240 | 6144 |
| TM16/TN24 | 384 | 25.666 | 51.332 | 15360 | 9216 |
| TM16/TN32 | 512 | 19.190 | 38.380 | 20480 | 12288 |

资源列使用已观察 FP 系数 `d_mul=3 DSP、d_add=2 DSP`：每 R0 通道需 `2d_mul+d_add=8 DSP`，整数需 `32/p DSP`，所以 `D_Q8=P×(32/p+8)`。**p=2 未经有符号 packing、交叉项隔离、精度和时序证明，只是条件列。** DSP/LUT 混合、其它精确 FP 实现或共享服务会改变系数，须另证，不把表当硬件方案。

裸器件报告上限为 9024 DSP；kernel 实际可用量应扣 shell、其它核、时序/布线余量，当前未知。TM16/TN16 直接映射已超裸上限；TM16/TN24 即便假设 p=2 仍超裸上限。TM32 不能直接用当前 rows≤16 task 得到满利用率，跨 task 合并要另立 owner/context 合同。

## 4. 50 ms 是共同预算，恢复服务必须一起缩放

现行同步 Controller 没有跨 task DATAFLOW。对当前/首版串行 owner 边界：

```text
T_request = T_host_prepare/clear + T_H2D + T_kernel + T_D2H + T_decode
T_kernel  = T_LOAD + T_quant + T_Q8 + T_QK+AV + T_softmax
          + T_LN/GEGLU/vector/RoPE/tail + T_control + T_nonoverlapped_IO
```

只有证明同一真实时间轴上可重叠的部分才减去交集；同一物理服务或同一缓存 owner 不能取 max。内核 start→done、常驻 Host 请求、冷初始化分别报告，50 ms 不同时送给每一行预算。

令 Q8 算术可得 tq 毫秒、有效利用率 u≤1：`P≥ceil(B×1473773584/(150000×tq×u))`，并供给 32P INT8 乘积、P 转换、2P FMUL、P FADD、P PS 读/写每拍。下表取 u=1，是最乐观必要通道数，不是推荐几何。

| tq | B1 P / 直接 DSP / p=2 DSP | B2 P / 直接 DSP / p=2 DSP |
| ---: | --- | --- |
| 50 ms（其它全部为零） | 197 / 7880 / 4728 | 394 / 15760 / 9456 |
| 40 ms | 246 / 9840 / 5904 | 492 / 19680 / 11808 |
| 30 ms | 328 / 13120 / 7872 | 656 / 26240 / 15744 |
| 25 ms | 394 / 15760 / 9456 | 787 / 31480 / 18888 |
| 20 ms | 492 / 19680 / 11808 | 983 / 39320 / 23592 |

### 4.1 不依赖具体矩形几何的 DSP 工作量条件

把所有裸 9024 DSP 都假定能连续服务且无 shell/其它成本，可得到更宽松的必要条件：

`W_DSP_Q8 = MAC/p + 8×(MAC/32)`；`T_Q8 ≥ W_DSP_Q8/(9024×150 MHz)`。

| 映射假设 | B1 Q8 最少 ms | B2 Q8 最少 ms |
| --- | ---: | ---: |
| p=1，恢复 FMUL3/FADD2 | 43.551 | 87.102 |
| **p=2，恢复 FMUL3/FADD2** | **26.131** | **52.261** |

所以 **B2/S128、150 MHz、上述 R0 浮点系数及 p=2 条件下，单 Q8 就超 50 ms**，甚至尚未给 Attention、量化、Host 或 shell 留资源。实际可用 DSP 更少只会收紧此条件。它不排除其它精确资源映射、更高实得频率或新的经验证共享/packing；这些均未实现，不能提前计收益。

## 5. QK、AV、softmax 与 KV 复用

当前 [attention 算术源](../../hls/operators/attention_full_compute.cpp) 和 Controller 的 30 层×16 heads×B×S query、每 query 全 S keys 保持如下工作量；finite mask、局部窗口和无效 token 不跳算。

| 项目 | B1/S128 | B2/S128 |
| --- | ---: | ---: |
| QK 64维乘法 | 503316480 | 1006632960 |
| QK 固定树 FADD | 495452160 | 990904320 |
| AV 乘法 / key升序 FADD（各） | 503316480 | 1006632960 |
| QK score / attention softmax元素 | 7864320 | 15728640 |
| softmax完整行 | 61440 | 122880 |
| QK / softmax / AV task（各） | 3840 | 7680 |
| AV最终F32输出元素 | 3932160 | 7864320 |
| LOAD_KV任务 | 480 | 480 |
| KV外部有效读取 bytes | 31457280 | 62914560 |

QK 还要每 score 的×0.125、pad/local bias；softmax 还有 max、subtract、exp、固定树 sum 和逐元素 division。AV保留乘后独立加、key升序及+0起点，不用FMA、分裂累加器、mask跳算或在线softmax替换现数值合同。

共享 QK/AV 引擎的算术贡献总数为 B1 1006632960；若每拍 F 个独立乘法及匹配加法服务：

| F | QK+AV B1 理想 ms | B2 理想 ms | 条件 FMUL/FADD 引擎 DSP（约5F） |
| ---: | ---: | ---: | ---: |
| 64 | 104.858 | 209.715 | 320 |
| 128 | 52.429 | 104.858 | 640 |
| 256 | 26.214 | 52.429 | 1280 |
| 512 | 13.107 | 26.214 | 2560 |
| 1024 | 6.554 | 13.107 | 5120 |

这是计算贡献下界，未含softmax、QK树填排、mask、反馈、KV/Q装载及输出。64 路方案已独立超 50 ms。原规格的8路max、4路exp/sum、8路normalize三阶段，B1理想扫描还需26.214 ms，B2 52.429 ms；要达成这些值，也须exp/div真有相应吞吐及片内端口，不能把非线性当零成本。AV按8 F32/clk排出还需B1 3.277 ms，是否与其它阶段重叠未证。

**AV反馈限制：** 一个当前task只有16 query×64=1024个独立累加地址。若同一地址安全复访窗口为F_AV拍、没有已证明旁路，则总有效AV贡献率还受 `≤1024/F_AV` 限制。512贡献/clk要求F_AV≤2或更多合法在途query/context；不能只复制512个乘法器就得到该行时间。交错其它query可隐藏等待，但同一输出的key顺序必须保持，现行task/owner边界不自动提供更大跨task池。

**KV重用核查：** Controller在每head前加载该head完整K/V、涵盖全部B/S，然后处理所有B及8个query row tile。故LOAD_KV仍480次，B2每次bytes翻倍；不是每16query重读一次。head只位于QKV奇偶shard之一，[真实 loader](../../hls/memory/full_loader.cpp)按plane→B→row→dimension读取。当前一个KV槽先完成本head才换下一个；另一QKV口空闲不等于已在预取下一head。

每head K+V：B1/S128=65536 B，B2/S128=131072 B；为全部合法S保留的源数组最大B2/S1024=1048576 B。K/V各对S个query复用，B1逻辑外读31.457 MB，对应算术侧K/V操作数读取约4.027 GB，后者由本地bank/广播供给，不能再算成外存重读。64贡献/clk需要一条256 B K或V窗口/clk、38.4 GB/s片内读服务；AV另有partial读/写。更宽方案可向多query广播一个K/V窗口，代价转为更多Q寄存、prob和partial端口及反馈，并非免费乘带宽。

若未来是单个活跃512-bit QKV口，KV纯payload下界B1 3.277/B2 6.554 ms；若仍32-bit则52.429/104.858 ms，都是满有效数据条件。双KV槽可支持另一口下一head预取，但需独立owner、credit、最后读者释放和真实时间轴；外存带宽、两bank资源和未能隐藏的首/尾装载仍要计。

### 5.1 Q8 与 Attention 的资源/时间不能各自拿满器件

例如 TM16/TN16 的假设 p=2 Q8占6144 DSP；独立512路Attention再占2560，共8704，裸器件仅余320，尚无quant、非线性、控制或shell。即使全部II1且无任何开销，两段B1时间仍为38.380+13.107=**51.487 ms**；B2约102.974 ms。把Attention加到1024路可缩算术时间，但Q8+Attention已需11264 DSP。

若采用彼此独立、固定面积的Q8与Attention引擎，并沿当前串行阶段调度，令Dq/Da为各自DSP，rq=32/p+8、ra≈5，忽略离散几何/一切其它成本时：

`min(Tq+Ta) = (sqrt(rq×Gq)+sqrt(5×MAC_attention))² / (D_available×f)`。

把D_available乐观置为裸9024，B1约p=1：72.721 ms；p=2：49.563 ms；B2均翻倍。此式是**该独立引擎服务模型**的乐观连续分配下界，不是通用架构定理；共享FP单元/真正跨阶段重叠会改变模型，也需要重新设计。即便p=2连续最优已把近50 ms用光，仍没有quant、Host或其它算子预算。

另一条更宽松、容许资源任意分时的DSP工作量条件，QK+AV只计真实乘法和树/递推加法，增加5017436160 DSP-clocks/B1。与Q8合计：p=1为47.258 ms/B1、94.516 ms/B2；p=2为29.837/59.675 ms。它忽略所有其它工作、未计实际共享改造且假定全部DSP可用，只用于筛除不够的预算。

## 6. 量化、输入带宽与除法服务

695816组的22266112个F32在每矩阵只量化一次，但共有89,064,448 B输入读取。完整输入先读入再quant的C1边界下，一条512-bit、150 MHz activation口即使满载，也先占**9.278 ms/B1、18.555 ms/B2**；实际量化扫描、div和等待另加。不能只扩大quant lane就消除这段串行输入装载。

| 每遍lane L | 两遍串行扫描 B1 ms | 独立两遍且跨组重叠的条件 B1 ms | 后者group/clk | 最坏全非零组所需II1 div服务数 |
| ---: | ---: | ---: | ---: | ---: |
| 8（C1） | 37.110 | 18.555 | 0.25 | 1 |
| 16 | 18.555 | 9.278 | 0.5 | 1 |
| 32 | 9.278 | 4.639 | 1 | 2 |
| 64 | 4.639 | 2.319 | 2 | 4 |

B2时间翻倍。C1组间保守串行，尚未采用右侧跨组div/扫描流水；实际还暴露除法/倒数、half和四block填排。每个group必做`F32(amax/127)`；非零d_full才执行倒数除法，因此全图实际div数介于Gquant与2Gquant，具体非零组数未重跑数值程序统计。吞吐设计要接得住合法全非零输入，不能按零组免费省服务。

若只给quant5 ms，B1两遍串行仅扫描就需至少60值/clk（通常评估64lane）；两遍独立重叠每遍至少30值/clk（可评估32lane）。**但单512-bit且输入完整先读的9.278 ms已超5 ms**。必须另外证明更宽/多口输入、片上消费者直接供给、或读取与第一遍重叠的新owner/错误排空合同；这些不在C1里。

32/64lane的F32局部吞吐分别为128/256 B每拍，即19.2/38.4 GB/s，需相应bank、FMUL/round/convert、保存重放和A8发布端口。不能从8-lane元数据或1个divider推出整组每拍。保留d_full实际除法、half RNE、roundf ties away、次正规边界，不用half倒数或1/127乘法擅自替代。

## 7. LN、GEGLU、残差与其余必需工作

下列数学工作量从当前 Controller 及 [LN源](../../hls/operators/layernorm_compute.cpp)、[向量源](../../hls/operators/vector_full_compute.cpp)、[RoPE源](../../hls/operators/rope_full_compute.cpp)复核。候选周期来自现有规格的吞吐假设，**不是新实现已达成值，也不是应在所有情形机械相加的独立外存时间**。

| 工作 | B1/S128数学量 | 候选服务条件 / B1最低扫描时间 | B2关系 |
| --- | --- | --- | --- |
| LN | 7824行×1024=8011776元素 | 三遍8lane：20.029 ms，加树/sqrt/div及尾部另加 | ×2 |
| GEGLU | 9404416输出；每项GELU+gate | 4输出/clk：15.674 ms；每项7FMUL、2FADD、1tanh | ×2 |
| Residual | 7864320 FADD | 8输出/clk：6.554 ms；2读1写=96 B/clk | ×2 |
| Decision ReLU | 1048576元素 | 8输出/clk：0.874 ms | ×2 |
| Type add | 131072 FADD | 8输出/clk：0.109 ms，另有type embedding | ×2 |
| RoPE Q/K | 114688个64维向量 | 14680064 FMUL、7340032 add/sub；表加载/读写另计 | ×2算术，表加载不变 |
| Scorer后bias-GELU / ACT后bias-GELU | 16384 / 256元素 | 原bias分步加，合计16640次GELU；不与Linear baked bias合并 | ×2 |
| F32 Scorer FC2 / F16 ACT FC1 | 16384 / 263168乘加贡献 | 与FP引擎共享时计入其占用，顺序累加、偏置、1028尾部另计 | ×2 |
| Token embedding | 128行×1088 B原始Q8_0行 | 解码/scale、F32输出及type行另计 | ×2 token，type由请求类型决定 |

LN共有61×S+16行：embedding1、Encoder attention27、Encoder FFN28、final1、Decision4，加marker16。每行两棵1023加法树、两遍delta、square/normalize及sqrt/reciprocal；只有embedding/final有gamma。顺序必须保持，不能把`(x−mean)^2`换成E[x²]−E[x]²。

GEGLU仍需tanh规定路径，4lane是真正每拍4结果才可用15.674 ms；HLS源目前串行调用不是该速率。Wi两半U/G相差2624，相同column bank余数，配对需双读口或降速；gate只有4结果/clk时不能当作8lane quant的满速第一遍。即使Q8算术免费，8lane两遍quant37.110 + 三遍8laneLN20.029 + 4laneGEGLU15.674，按未融合串行边界已超过50 ms。

首版F0将这些张量写回后再读。LN→quant第一遍融合、PS→GEGLU、residual直连可减少重复读写/部分扫描，但必须保持完整行统计、U/G配对、第二输入owner和写响应。Wi与Down共享Q8引擎，不能同时算；按tile做Wi→gate→Down并保gate需同时驻两张权重，原规格F1a/F1b均为后续选择，不能计成已有收益。

## 8. 权重加载：宽口、串行shard与双缓存假设

manifest的122张Q8权重精确字节：q0=184682496、q1=184680448、scale=23085184，合计**392448128 B**；bias另77832 B。B1/B2相同，LOAD_W供全部B/row重复使用。模型常驻HBM与每请求的HBM→片内LOAD_W是两件事，不能因Host不重传模型就删除后者。

当前v3 SRC:521–548先完整q0，再q1，然后scale。q路径512-bit每beat拆两个256-bit bank word；scale每64 B beat拆4组，每组8个half，内层至少4拍，因此scale unpack服务只有16 B/clk，不是64 B/clk。

| 条件 | Q8权重payload/存储服务时间，B1/B2相同 |
| --- | ---: |
| 当前q0→q1顺序，512-bit每拍64 B | q合计38.475 ms |
| 当前scale unpack 16 B/clk | 9.619 ms，q结束后再做 |
| 两者串行最低服务量 | **48.094 ms**，仍未计scale验证、bias、burst间隙、控制 |
| 未来两q口真正并发且scale可并行 | max(q0/9.6GB/s,q1/9.6GB/s,scale服务)=**19.238 ms**，全有效条件 |
| 原规格65%外口效率条件 | q瓶颈约29.597 ms，非实测效率 |

首版单W/cache命令不允许LOAD与compute重叠，故48.094 ms不能从C1算术时间中扣除。下一权重预取须有两个W槽、key/epoch身份、bank写仲裁、真实返回信用及当前矩阵全部消费者最后读释放；下一LOAD异常不能抢先改变本任务状态。q0/q1返回可能争同bank，不能仅加DATAFLOW就假设两口一直满带宽。

双Wq若沿当前HLS的256URAM/槽系数，暂为512URAM；Ws/bias及其正确物理粒度另计。不能把剩余448URAM全部分给Attention，shell/其它模块未知；也不能因前一矩阵很大就把所有加载都视作隐藏，第一张和无法跨owner边界的装载仍暴露。

## 9. 输出和其它外存流量

### 9.1 当前 Q8 out0/out1 是决定性限制

两个32-bit口@150MHz总理想峰值1.2 GB/s，B1全部158138376 B输出至少131.782 ms。这只是聚合下界；按当前端口角色还能收紧：QKV输出47185920 B平均分两口，普通矩阵全部out0。因此：

| 请求 | out0 bytes | out1 bytes | out0 0.6GB/s必要时间 |
| --- | ---: | ---: | ---: |
| B1 | 134545416 | 23592960 | **224.242 ms** |
| B2 | 269090832 | 47185920 | **448.485 ms** |

即使两口完全重叠、算术免费，这个外部落地/端口合同仍远超50 ms；现有标量bias/store顺序实际更慢。此结论针对C1隔离输出方式推广到全图的条件，不声称生产13口已经替换成该两口。

把out0/out1改512-bit，在完全连续满载且角色不变时，out0仍有B1 14.015/B2 28.030 ms payload下界；尾拍、QKV scatter、WSTRB、4KiB切分和响应还要计。若只给输出5 ms，B1 out0所需26.909 GB/s；单512-bit@150MHz 9.6 GB/s不够。必须增加实际服务能力或减少经外存落地的字节，并证明片上消费者的完整owner/错误/排空合同。不能因为写宽口或FIFO加深就把输出时间记零。

### 9.2 F0已确认的逻辑流量子集

下表不含trace、状态、descriptor、全部embedding/type/FP尾层/bias及额外复制，只计已在task源中确认的正常成功读写。producer写与consumer读是两次真实传输，分别计；score/prob保持片内，不虚增HBM往返。

| 类别 | B1有效bytes | B2规则 |
| --- | ---: | --- |
| Q8 q+scale LOAD | 392448128 | 不变 |
| Quant F32 input | 89064448 | ×2 |
| Q8 F32 output | 158138376 | ×2 |
| KV加载 | 31457280 | ×2 |
| Attention Q读取 / AV输出（各） | 15728640 | ×2 |
| RoPE Q/K读+写 | 58720256 | ×2 |
| RoPE表加载 | 14694400 | 不变，28次完整1025行表 |
| LN读+写 | 64094208 | ×2 |
| LN gamma LOAD | 8192 | 不变 |
| GEGLU两输入+输出 | 112852992 | ×2 |
| Residual两输入+输出 | 94371840 | ×2 |
| ReLU读+写 | 8388608 | ×2 |
| Type-add两输入+输出 | 1572864 | ×2；当前逐row读取type，不假定额外缓存 |
| **子集合计** | **1057268872** | **1707387024 B** |

50 ms内仅此子集平均约21.145/34.148 GB/s跨所有对应读写通道，还没计Host清零/H2D。它是逻辑需求，不是HBM有效带宽实测；不能除以13路总峰值当延迟，因为端口分布、串行owner、byte packing、AXI响应及内核阶段决定实际并发。旧完整top的13×32-bit报告绑定旧身份；新生产完整端口效率尚未验收。

## 10. Host传输必须保留，实际PCIe未测

冻结Host合同：13 BO；成功Session初始化上传五模型BO共448923648 B一次；每请求清零/同步七workspace **192937984 B（184 MiB）**及IO **32768 B**，H2D合计**192970752 B**；D2H固定384 B。单InFlight，不能在kernel仍读写这些BO时用下一请求清理掩盖传输。

`T_H2D ≥ 192970752 / BW_H2D_effective`；CPU清理/准备、同步固定延迟、D2H和解码仍另加。B1/B2这一固定H2D相同。

| 分给H2D的时间 | 必需有效GB/s |
| ---: | ---: |
| 50 ms（kernel为零） | 3.859 |
| 20 ms | 9.649 |
| 15 ms | 12.865 |
| 10 ms | 19.297 |
| 5 ms | 38.594 |

平台规格仅列baseline参考 `xilinx_u55c_gen3x16_xdma_3_202210_1`，**未确认实际安装platform或协商链路**。仅在采用该Gen3×16条件时，用8 GT/s、128/130编码得到理论单向15.753846 GB/s（尚未扣协议/软件），本H2D自身至少**12.249 ms**；这不是当前Host测速或实际PCIe配置认定。若平台不同，应代入其已核实条件，本文不自行指定。

在该参考链路条件下，最乐观kernel余量≤37.751 ms。再结合§4/§5的**p=1、FMUL3/FADD2、150MHz、全部9024DSP可用**的Q8+QK/AV工作量下界47.258 ms，H2D+这两项已≥**59.507 ms/B1**，不含quant/其它阶段。p=2时对应42.087 ms/B1，仍仅剩约7.913 ms给一切其它工作，且packing、资源任意共享和带宽都未证明。B2仅Q8的p=2条件下界已超过50 ms，无需Host假设即可排除此映射条件。

这些是条件筛选，不是板级不可能定理。当前合同不授权删除workspace H2D或改Host清理语义；将来若以已验证生命周期取消该传输，应先明确新合同和错误恢复，再另算收益。不能把Host准备从“完整请求”计时里静默移出。

## 11. RAM、端口和物理映射的必要核查

裸器件在当前HLS报告中的上限：LUT1303680、FF2607360、DSP9024、BRAM18=4032、URAM960；shell后可用量未知。若只算容量，BRAM+URAM合计44679168 B，仍小于392448128 B的Q8 q+scale约8.78倍，不能把全部Q8模型保持在片内来删去每请求权重加载。

Wq容量由真实最大N×G确定，不随TM复制；TN重分bank影响深度/碎片，不把相同权重存储简单乘TN。若用每bank256-bit、URAM72×4096作自然宽/深拼接，候选如下；均非已映射结果。

| TM/TN | 每Wq bank最大深度 | Wq自然拼接URAM（单槽） | PS自然36×512 BRAM18（单微块） | PS每拍读/写bytes（各） |
| --- | ---: | ---: | ---: | ---: |
| 4/8 | 20992 | 192 | 64 | 128 |
| 16/8 | 20992 | 192 | 256 | 512 |
| 16/16 | 10496 | 192 | 256 | 1024 |
| 16/24 | 7008 | 192 | 384 | 1536 |
| 16/32 | 5248 | 256 | 512 | 2048 |

Wq formula=`TN×ceil(256/72)×ceil(depth/4096)`；PS formula=`TM×TN×ceil(ceil(5248/TN)/512)`。当前TN8实际HLS却为256URAM而非自然192，已经说明级联、碎片/映射必须由同源OOC核查；不能提前记省64URAM。自然拼接只是具体可复算组织，不是最优容量下界。

扩大TM不必复制完整A8 cache：逻辑Aq65536 B+As4096 B仍存完整16行。可以用更宽bank或在T个列tile期间预取16行寄存窗口，但四bank要多拍供齐、地址和credit必须证明；不能把A广播宽度当成全cache每拍都读同样流量。PS需相应独立bank与one-read/one-write；当前C1还要result/trace保留槽、busy/guard和half/FP对齐寄存，成本不为零。

其它最大逻辑缓存至少核查：FP输入262144 B；C1四行PS83968 B（生产完整16行PS335872 B）；当前head KV最大1048576 B，若双槽再加一份；score/prob源数组131072 B；AVpartial4096 B；RoPE表524800 B；FP_ACT权重526336 B；gamma8192 B；bias20992 B。对本次S128可用字节比最大数组小，但不擅自缩掉合法S1024配置。容量和端口复制/双缓存应分列，不用旧整核资源扣新核余量。

### 11.1 新发现：Ws HLS资源估算与逻辑容量矛盾

当前 `q8_joint_tm4tn8.verbose.rpt.xml` 的 Memory表（行1400–1407）明确列8份Ws，每份20992 words×16 bit，却每份仅估8 BRAM18、合计64。实际generated top（13654起8实例）和[Ws wrapper](../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/runs/csynth_local_v1/work/hls/syn/verilog/q8_joint_tm4tn8_ws_RAM_2P_BRAM_1R1W.v)均保持DataWidth16、AddressRange20992、AddressWidth15。

完整Ws需335872 B；64×2304=147456 B，容量明显不足。在无压缩/共享证明的相同存储合同下，仅总容量就需ceil(335872/2304)=146个BRAM18；按8独立bank分别向上取整至少152个；自然18-bit×1024 BRAM18组织约168个，或18-bit×2048 BRAM36组织88个BRAM36=176个BRAM18。

**这说明HLS的64 Ws BRAM18及总341 BRAM18不能直接作为物理预算；不证明RTL已经截断或存在功能错误。** 源与wrapper保留完整尺寸，实际优化/映射尚无同源OOC。本报告只登记估算矛盾及后续物理容量/地址范围核查项，不修改旧分析或发起新综合。

## 12. 可审查的方案分歧与下一步证据

| 范围 | 现在能给的判断 | 必须补齐的证据 |
| --- | --- | --- |
| 当前v3 / 同几何C1 | C1用于校准真实32恢复通道与bank/反馈；其Q8理想307 ms，不能作为50 ms方案 | 既定Scorer三命令阶段周期、真实有效issue/MAC、全维尾部、C1同源数值与OOC |
| 扩大Q8，保留32-bit外写与8lane量化 | 算术更快仍被224 ms/B1 out0、37 ms扫描及输入/LOAD约束；不能达成该联合预算 | 输出宽化或片上消费者的精确owner/字节减少；量化宽度与div/输入服务 |
| 假设packing2 + TM16/TN16 + 512路Attention | 裸DSP8704，Q8+Attention算术已51.487 ms/B1；没有shell/其它余量 | packing精确性、FP实际映射、AV反馈、有效率及整核资源；不能只凭INT峰值 |
| 更多精确共享/packing、宽quant、片上消费、双缓存 | 有机会改变上述条件系数，但当前没有可承诺的50 ms实现 | 同一身份的R0数值、资源、真实端口、credit/epoch、异常/复位和端到端时间轴 |
| Host生命周期变化 | 若保留冻结192970752 B H2D，必须留足传输时间；不默认可省 | 新合同审查及真实XRT/平台行为；无板卡时不作测速结论 |

后续优先仍是完成已准备的Scorer观察，再由主Astra依据实测冻结C1源码/预算，Sol实施。该顺序不会妨碍本报告作为整网必要条件审查。验收必须给出：实际算术服务率与反馈、quant/div/exp/tanh吞吐、按port有效bytes和停顿、所有owner可重叠区间、无黑盒资源/时序、shell可用量，以及Host边界。每个实际未测量记未知，不能用另一身份的最好系数组装成一台没有实现过的机器。

本次只有源文件阅读、哈希与算术复算，没有新的数值程序、仿真、综合、布局布线或上板执行；没有降低50 ms目标，也没有据局部功能PASS宣称性能达成。
