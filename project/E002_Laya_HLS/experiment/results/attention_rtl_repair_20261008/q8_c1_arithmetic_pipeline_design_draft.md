# C1：TM4/TN8 内部算术流水设计草案

编写：GPT-6 Astra / xhigh，`/root/q8_pipeline_analysis_astra_xhigh`。日期：2026-10-09。状态：**候选设计，等待主 Astra 审核及既定真实全维观察；不构成源码实现、CPU/CSim、RTL、综合或 OOC 执行放行。** 本轮只新增本文件及同名 JSON，不改现有设计、实现、测试、任务或既有证据。

## 1. 依据、现状与本草案的边界

| 依据 | 已核查位置与用途 |
| --- | --- |
| [当前模块设计](../../vivado/module_design/q8_linear_and_restore/source/design.md) | “C1 流水修订的正式设计要求（实现与执行待门）”，本草案细化其已选择结构；实际九路 AXI、双 Lite 及 36 命令验收见同文件开头 |
| [主设计独立选择记录](reviewer_q8_pipeline_c1_independent_design_review.json) | C1_selected_requirements、数值边界、工作量及未放行事项 |
| [已接受只读分析](q8_pipeline_analysis_astra_xhigh.md) / [42 项证据](q8_pipeline_analysis_astra_xhigh.json) | 当前 metadata_reset_v3 的绑定、调度、端口和资源；本草案不改变其历史哈希 |
| [修复合同](repair_contract.md) | §4.4–4.7、§7.15：真实完整 K/N、微块、R0、信用、输出响应、首错及部分已写输出 |
| [R0 原规格](../../vivado/design_source/09_q8_linear_and_restore.md) | §2–3：独立 FP32 舍入、group 升序、反馈与 PS 生命周期；旧 TM16 候选不覆盖当前 TM4 选择 |
| [量化原规格](../../vivado/design_source/08_activation_quantizer.md) | §2–3：d_full、reciprocal、half RNE、roundf、完整 tile 发布 |
| [共同接口原规格](../../vivado/design_source/15_integration_interfaces_and_pipeline.md) | §11、§13.2、§14：epoch、有效位、反馈、完成与复位；当前隔离原型的实际微块输出次序以源和 §7.15 为准 |
| [当前源](../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/source/q8_joint_tm4tn8.cpp) | 68–86 half 解码；215–232 dot；580–694 输入/量化/trace；701–760 group；762–803 bias/输出；805–821 最终状态/report |
| [当前 ABI](../../vivado/module_design/q8_linear_and_restore/metadata_reset_v3/source/q8_joint_abi.h) | 128-word descriptor、256-word 状态头、九口字节计数和 trace 布局 |
| [精度边界准备](reviewer_q8_full_dimensions_observer_numeric_boundary_preparation_addendum.json) | 实际 FP32 次正规除法、倒数溢出和 bias 精度待测，非执行许可 |

伴随 JSON 记录这些文件当前字节数/哈希；历史分析中旧 mission/task.md 的精确字节已另存 `document_history/current_mission_task.md_before_attention_failure_c1_20261009.md`，不拿当前 mission 冒充原分析输入。

工程事实：当前真实身份为 fe067 + metadata_reset_v3。ACT K256/N2/rows1 的 36 命令已独立接受，不原样重跑。先行观察仍为真实 Scorer FC1 K1024/N1024 的 LOAD、rows1 trace-on、同输入 trace-off 三命令（341 实体页），然后按真实成本扩展既定 14 窗口。Scorer rows1 应有 4096 向量、32768 有效 dot 和 1048576 MAC，只使用四行阵列中的一行。

当前 HLS 估计为 21.308 ns、341 BRAM18、40 DSP、117625 FF、156176 LUT、256 URAM，尚无 OOC；1024 个 INT8 乘法实际为组合 LUT 映射，动态树未完全展开，恢复共享一路 FMUL/一路 FADD。这里的 II=1、DSP 绑定、固定时延和资源数均为新候选要求/条件，不能引用旧报告宣称达成。

首个 C1 保持 TM4/TN8/GS32、九 AXI/双 Lite、descriptor/status/trace 字节合同、单 W cache、单完整 A8 tile、单微块 PS、LOAD 与 compute 分阶段、一个命令在途。生产 13 口、Host、Controller、模型 BO、量化/错误优先级均不在本轮改动范围。小 A 预取寄存器和结果/trace 队列不是第二份 W/A8/PS cache。

## 2. 模块划分与执行顺序

```text
原 descriptor/身份/epoch 校验与 LOAD
                  |
完整 FP 输入读取 → 8-lane Quant → 完整 A8 READY → 量化 trace 排空
                  |
        m0=0/4/8/12（严格依次）
                  |
lane_bad 元数据清理；A group 双寄存槽预取
                  |
g 外层、tile 内层有序 scheduler
                  |
原子 issue：预留 result/trace 槽、置 tile busy、发 bank 读
                  |
固定延迟 bank 返回/有效 mask/广播
                  |
32×(32 DSP 乘积 → 五级树 → I32/F32 → term FMUL → PS FADD)
                 ^                  ^
                 |                  |
              Aq/Wq             sa×sw FMUL
                  |
32-lane 分类 → 预留 result 槽写回（不可反压）
                  |
有序 commit：PS、lane_bad、全任务最小错误、计数、trace 发布
                  |
当前微块全部 result/trace 排空
                  |
按 tile→rr→cc 做 bias/输出，等真实写响应
                  |
下一 m0；全部 m0 完成后才 report/TaskDone
```

所有内部模块采用当前 DUT 的同一时钟/复位域；不引入 CDC。目标频率沿有效合同为 150 MHz（请求周期 6.667 ns），实际时序未测。电气复位极性、生成 AXI/Lite 行为和平台恢复规则沿当前实际封装，不能从本草案推导新平台能力。

## 3. 内部接口与寄存标签

以下为内部事件/字段合同，可由 HLS 数组、明确子模块或 RTL 信号实现，不新增外部端口。实现者须交付逐项实际 RTL 绑定。

| 接口/事件 | 生产者 → 消费者 | 负载/顺序与容量 |
| --- | --- | --- |
| `a_prepare` / `a_ready` | A 预取 → issue | 一组四行 Aq 各 256 bit、sa 各 F32、m0/g、row mask；两寄存槽；完整返回后才 READY |
| `issue_valid/issue_ready` | scheduler → 固定流水 | 每次一向量；`issue=valid&&ready`；停顿时 m0/g/tile/tag 稳定 |
| bank read requests | issue → W/Ws/PS/lane_bad | 每 bank 最多一读/拍；使用 issue 同拍地址/tag；同步返回独立对齐 |
| semantic lane valid | lane_bad 返回 → 算术 | `shape_mask & ~bad_mask`；其后与数据同延迟；不使用 FP CE/tvalid 常高作为有效事件 |
| `result_return` | 固定流水 → result ring | 每拍最多一向量，写向在 issue 时预留的 slot；没有 `ready`，不得丢失或覆盖 |
| `commit` | result ring → PS/元数据 | 只提交最老已返回槽；每拍最多一向量，实际 bank 写沿、错误、计数、trace 状态作为一次提交 |
| trace reserve/publish/cancel | issue/commit → trace ring | 最多一条选中 lane 记录/向量；预留与可见分离；Dtrace=4 条候选 |
| trace writer | trace ring → observed | 严格预留顺序，8 words/成功组；直到该记录全部写响应返回才回收 |
| output retirement | bias/store → controller | 保留当前列散写；微块最后 PS/trace/output 及总线债务排空才释放微块 |

命令接受时锁存不可变上下文：request_id/generation 各 64 bit；task_id、quant_task_id、W/A8/PS/dst epoch 各完整 32 bit；四类 tag、shape、源/目的引用、物理基址/跨度。**该上下文在最后 report 写响应前不能覆盖。** 每条向量可用固定 context 引用关联这些完整值，无需把全部 64/32-bit 字段在每个 lane 重复。若实现允许上下文换代或多槽，须额外设计 token 世代及复用屏障；首版不允许。

向量共有标签（32 lane 共用一份）：

| 字段 | 提议位宽 | 定义 |
| --- | ---: | --- |
| seq | 17 | 命令内单调序号，0…ceil(rows/4)×G×T−1；成功 LOAD 保证 T×G≤20992，所以最大 83967；计数器保留 32 bit，不把序号宽度用于截断 ABI |
| m0 | 4 | 本任务局部起行 0/4/8/12，不是全局 row0 |
| g | 7 | 0…127；错误/bias rank 的 g 域另用 8 bit，容纳 G=128 |
| tile / PS address | 10 | 0…655，n=8×tile+cc |
| shape_mask | 32 | bank=rr×8+cc；r=m0+rr<rows 且 n<N |
| active_mask | 32 | shape_mask 且此前该 bank/tile 未失败；同步 lane_bad 返回后生成 |
| last_g | 1 | g=G−1，不能单独当完成条件 |
| result_slot | ceil(log2 Q) | issue 原子预留；直至 commit 后回收 |
| trace_reserved/slot | 1 + 2 | Dtrace=4 时；选择 lane 由 immutable trace row/column 和向量标签确定 |

期望 g、mask、slot 和身份标签随有效位固定前进；气泡有 valid=0，结果可任意但不能改计数/内存。若任何实际 FP 通路变成可变 latency 或不能达到固定每拍输入能力，必须增加已审核的弹性重排/握手设计；不能只扩大 valid 移位寄存器掩盖不匹配。

## 4. 存储端口、地址和 A 预取

| 存储 | 既有几何 | C1 访问合同 |
| --- | --- | --- |
| Wq | 8×256×20992 | bank=cc，addr=tile×G+g；每向量每实际列 bank 至多读一次，广播四行；LOAD/compute 不重叠 |
| Ws | 8×16×20992 | 同 Wq 地址；固定 half 解码后广播四行，保留 16-bit 存储 |
| Aq | 4×256×512 | bank=rr；**addr=(m0/4)×128+g**，沿实际物理 stride，不能换成 `(m0/4)×G+g` |
| As | 4×16×512 | 同 Aq；每(m0,g)读一次并解码，跨 T 个 tile 保持 |
| PS | 32×32×656 | bank=rr×8+cc，addr=tile；一读一写/拍；g0 old=+0，不读未初始化 PS |
| lane_bad | 32×1×656 | 首版保留独立 bank；每微块使用前并行清 32 bank，一 tile/拍；不同时 compute |
| Bias | 8×32×656 | 原 bank=cc、addr=tile；仅在当前微块计算/trace 排空后用于输出 |

修复合同 §4.4 早期表格的 A 地址写作动态 G stride；实际 SRC:656–657、716–717 是固定 128 stride。本草案明确采用后者，防止 rows5/15/16 的跨微块串位。

lane_bad 为同步 RAM，issue 同沿不能假定已组合得到 active mask。首版在 issue 时对 shape-valid lane 发 lane_bad 读，对 g>0 的 shape-valid lane 发 PS 读；W/Ws 只按 shape-valid 列门控。lane_bad 返回后产生 active mask并筛掉失效 lane。此前已失败 lane 的额外内部读可被忽略，无 MAC/PS/trace/输出副作用；如果以后要按 active mask 抑制 W/PS 读，须增加有 tag 的元数据前级并把其 latency/信用纳入预算。shape 无效行不读 A/PS/lane_bad，尾列不读 W/Ws/PS，不做越界地址访问。

每次 issue 将所引用 A 槽的 Aq/sa **复制到流水寄存器**；只有最后 tile 的 issue 已复制后，才允许释放该 A 槽。不可在管线仍通过索引引用槽数据时提前改写。两个小寄存槽分别持当前/下一 g 的 4×(256+32)=1152 bit 数据，总 2304 bit 加 tag/valid；不复制全 68 KiB A8 cache。预取使用独立 Aq/As 读口，slot 必须先 FREE 后发读、全部返回才 READY；若预取不及时，issue 停等，不假设 T=1 一定隐藏读延迟。微块边界保守清 slot valid，旧请求必须已返回。

## 5. 算术结构与逐位语义

### 5.1 整数部分

每个有效 dot 明确提取 32 个 signed8 Aq/Wq；32 个 signed8×signed8→signed16 乘积。首个变体显式 DSP 绑定并寄存，实际 `L_imul` 由新报告确定。每 lane 的五级固定树节点数/位宽为 16×17、8×18、4×19、2×20、1×21；每级一拍，有编译期常量连线，无运行时 stride/k 循环。最终有符号扩展到 INT32。

极限 32×(−128)×(−128)=524288，20-bit signed 不能容纳，21-bit 足够。整数结合顺序可改变，因为逐层宽度不溢出；FP group 顺序不变。总计 1024 个乘积、992 个树加法节点，五层结果寄存量为 `32×(16×17+8×18+4×19+2×20+21)=17696 bit`，不含产品、valid/tag、广播、DSP 内部寄存。

### 5.2 精确固定时延 half 解码

8 路 Ws 解码器每拍各接一个 half；4 路 As 解码器位于 A 预取路径。使用有限宽 leading-one/shift 的位操作结构，所有 65536 种输入位型与 SRC:68–86 一致，不借用会改变 NaN payload 或 flush subnormal 的转换配置。

令 half mantissa=f、sign=s、exponent=e：正常 e=1…30 用 F32 指数 e+112、fraction=f<<13；e=31 保留 infinity/NaN fraction=f<<13 及符号；f=0,e=0 保留 ±0；f>0,e=0 令 p=floor(log2 f)，F32 biased exponent=p+103，fraction=`(f<<(23−p)) & 0x7fffff`，符号照搬。固定流水深度 `L_half` 由实现与报告冻结。非法负/非有限 scale 仍在原 phase0 判错，−0 合法。

### 5.3 每 lane 的完整恢复服务

32 个 lane 各独立具备 I32→F32、FMUL_scale、FMUL_term、FADD_ps，均目标 II=1；不允许 HLS 再共享为一路标量资源。具体结构使用可核查的独立非内联/模板专用实例或等效 RTL 层级；仅加 UNROLL/BIND pragma 名称不足以证明实例数。

```text
dot_f   = RN_F32(signed_INT32_dot)
product = RN_F32(sa * sw)
term    = RN_F32(dot_f * product)
next    = RN_F32(old + term)       // g0 old 必须是 +0，仍调用 FADD
```

每步都是独立 F32 舍入，不做 FMA、乘法融合、跨 g 加树、分裂累加器或用 term 直接代替 g0 的加法。即使 dot 本身可精确表示，也保留独立转换服务。异常 lane 的分类需要真实 sa/sw/product/term/next；inactive lane 可喂 +0 假操作，语义有效 mask 必须让其不产生任何有效工作与副作用。固定流水可以全时钟运行，FP CE 常高不等于有效利用率。

### 5.4 时延表与对齐

所有 L 定义为“对应请求接受沿 → 对应结果采样沿”的整数拍数，计入实际 bank、寄存、IP wrapper 和布线流水；不把旧 IP 文件名中的数字当新配置，也不手造 FP 精度/latency 参数。

| 符号 | 含义 |
| --- | --- |
| L_wq / L_ws / L_ps / L_bad | issue 请求到 Wq/Ws/PS/lane_bad 可用，包括必要前级寄存 |
| L_half | Ws half 精确解码；As 已在 issue 前就绪 |
| L_imul | signed8×8 产品寄存延迟 |
| L_cv / L_ms / L_mt / L_add | I32→F32、scale FMUL、term FMUL、PS FADD 的实际固定 latency |
| L_class / L_store | next 后分类/错误归约/记录对齐，以及写入 reserved result 槽的真实延迟 |

按采用 lane_bad 先筛选有效输入的保守连线：

```text
t_dot     = max(L_wq, L_bad) + L_imul + 5
t_dot_f   = t_dot + L_cv
t_product = max(L_ws + L_half, L_bad) + L_ms
t_term    = max(t_dot_f, t_product) + L_mt
t_next    = max(t_term, L_ps) + L_add
L_return  = t_next + L_class + L_store
```

各支路补齐延迟，PS old从 issue 请求一路携带到同一向量 FADD；不能从当前 scheduler g/tile 重新取值。sa/sw、phase0/1/2 标记及选中 lane 的 trace 中间值同样对齐。只要新实现额外增加一级 mask/寄存/输出 RAM 读级，上式对应 L 必须实增。实际 32 lane 必须同时返回；差异用等长寄存补齐且覆盖 masked lane。该时延和 II 的实测表是实现验收必填项，当前均未测。

## 6. Result ring：在 issue 前为不可暂停的流水预留空间

首版采用 Q 个槽的顺序 ring。状态为 FREE、RESERVED_UNRETURNED、RETURNED_UNRETIRED；一写端接固定流水返回，一读端/寄存输出服务顺序 commit。可用寄存阵列或充分端口的分 bank RAM实现；若同步 RAM 读增加 commit latency，必须计入容量推导。返回只写其已持有 slot，不因 trace/AXI/commit ready 而停止。

每次 issue 原子完成：确认 tail 槽 FREE，置 RESERVED，写 slot/tag 预留，扣 result credit；如选中 trace 的 shape lane 在本向量内，同时预留 trace slot；置 busy[tile]；发所有 bank 请求；scheduler 前进。任一条件不满足则都不发生，valid/tag 保持。

核心守恒式：

`free_result + reserved_unreturned + returned_unretired = Q`

每个未退休 issue 恰有一个唯一非 FREE 槽；每个 return 恰好匹配一个 RESERVED；每个 commit 恰好释放最老 RETURNED。全masked、数值失败或trace取消也必须让原result槽唯一返回并唯一退休，不能把槽提前释放当作取消已发算术。初态/reset 都只有 FREE，禁止在 return 当拍绕过 reserved 检查或在一个 slot 被回收前重用。

**边沿语义：** issue、return、commit 都使用沿前状态判定；return 沿写 returned_valid，最早下一沿才能 commit；commit 沿写实际 PS/元数据并释放槽，其信用最早下一沿用于新 issue。同沿可独立 return、commit、issue，但不能用“将要释放”作零延迟满队列旁路。

若 issue 在 e，固定 return 在 e+L_return，最早 commit 在 e+L_return+1，释放信用最早用于 e+L_return+2。因此在 bank/commit II=1、无其他停顿时，候选：

`Q = next_power_of_two(max(2, L_return + 2))`

该容量是按上述事件边沿确保满速所需的保守值；安全性来自每次 issue 预留，即使更小 Q 也只能降低吞吐、不能丢结果。无限 AXI 停顿不需要无限 Q：耗尽信用后停止新 issue，所有已发结果都拥有槽。Q 不能替代 trace 信用、bank 端口或 PS hazard 证明。真实实现若 result RAM 的读出、PS commit 或信用回传有额外拍，重算 Q；JSON 保留符号参数，不填想象的 FP latency。

result payload 至少保存 32×32-bit next、success/new_bad mask、active 数量、向量标签和最小错误候选；trace payload另存独立预留 trace 槽。若保留全 active mask用于观察也应显式计位。每槽逻辑量 `S_result = 1024 + S_masks + S_tag + S_error + S_bookkeeping`，总 Q×S_result；实现必须列出精确字段/容量/端口及报告，不能把这部分 LUT/FF/BRAM 当零。

## 7. PS scoreboard、lane_bad 与反馈窗口

用当前微块 T 个 `busy[tile]` 位及安全重读 guard，最大各 656 bit。issue 置 busy；**仅在该向量的分类、成功 PS 写、失败 lane_bad 写和相关元数据原子 commit 后才清 busy**，不能在乘法/FADD 输入或结果刚返回时清。这样同一地址不会在上一组失败尚未知时错误发出下一组，保留未来组 MAC 跳过与副作用。

提议 `issue_ready` 条件全部同时成立：命令/context有效；A槽匹配 m0/g且READY；目标 tile 未busy且guard已过；result信用足；若该向量包含选中 shape lane则trace信用足；所有 bank 请求路径可接受；微块处于 compute。读到的 active mask可为空，但该向量仍按原循环 issue/return/commit，保持 `ceil(rows/4)×G×T` 向量计数；其MAC、PS写、成功trace为零。

PS bank 一读一写允许同拍处理不同 tile。首版无旁路，commit 沿 c 真实写 PS 后，c+1 整拍禁止该 tile 新读，最早 c+2 issue。若采用普通 no-stall latency，最短安全反馈间距：

`F_nominal = L_return + 3`（e issue，e+L_return return，+1 commit，+2 后重新 issue）。

停顿会推迟真实 commit，scoreboard 以事件而非固定倒数决定放行。若报告显示 memory 实际写沿晚于 commit pulse，应移动 commit定义或延长guard，不能按 C语句调度推断已可读。不依赖 BRAM 同址 read/write 模式，不加虚假 DEPENDENCE。

g 外层、tile 内层严格顺序，允许不同 tile 的向量同时在途，但同一 tile 最多一个。对输入服务实际 II=I，无额外阻塞的 group 起点间距至少 `max(T×I,F)`；N2/T=1 必然等待上一组分类/写入，不用多累加器改变 R0。若 hold 住最前 scheduler 项，后续 tile不越过它。这是首版确定性选择，性能必须包含 head-of-line 等待。

## 8. 错误、计数和微块输出

### 8.1 Lane 数值分类

active lane 每组均完成 dot，`macs += 32`，即使本组最终数值错误。分类优先级严格为原 SRC:729–733：

| phase | 条件 | 行为 |
| ---: | --- | --- |
| 0 | sa/sw 非有限，或 sa<0，或 sw<0 | 记录失败；−0 不属于负数 |
| 1 | product 非有限 | 仅在 phase0 未发生时选择 |
| 2 | term 非有限 | 仅在前两级未发生时选择 |
| 3 | next 非有限 | 仅在前三项未发生时选择 |
| success | 以上全无 | 写 PS；如选中 trace 则发布真实中间值 |

失败 lane 当前组不写 PS/trace，并置 lane_bad；其后所有 g 该 lane 的有效 MAC/PS/trace均为零。其他 lane和后续微块仍继续。所有 lane同延迟只意味着电路可能执行dummy，不把它算入有效MAC。

原首错秩为：

`rank = (((tile×16+r)×8+cc)×(G+1)+g)×5+phase`

bias 错误使用 g=G、phase=0。对于固定 G 和合法范围，按 `(tile,r,cc,g,phase)` 作字典序最小与原64-bit rank完全等价；可编码为28-bit比较key `{tile:u10,r:u4,cc:u3,g_or_G:u8,phase:u3}` 并另有 valid，避免32份动态宽乘法。向量内tile/g相同，可先优先选择最小失败 lane，保留该 lane 的最低phase，再与全任务最小值比较。bad_element仍原样编码 `r×5248×128+n×128+g_or_G`，不得拿bad_element大小替代rank。

实际 issue 是 m0→g→tile，而错误rank以tile→r→cc→g→phase优先；结果到达时间不能决定首错。保守首版完成全部合法安排的微块、组、输出后才提交错误状态，取全任务最小rank。后续微块小tile错误可以替代前一微块大tile错误；bias错误也参与同一最小值。不用“已经遇到错误”提前结束、取消后续原本有效的MAC或撤销已经合法写出的输出。

### 8.2 可见计数

| 字段 | C1 定义与等价要求 |
| --- | --- |
| O_ACCEPTED_ISSUES | 每 issue +1；包括全masked逻辑向量；最终等于原循环总数 |
| O_RETIRED_GROUPS | 每原子 vector commit +1；trace可排队，但最终报告之前全部响应排空 |
| O_DOT_MACS | 对active lane每组+32；本组后续失败也计，前组已坏则不计 |
| O_COMMITTED_WRITES | 仅最终F32输出元素写入，不是PS group写；最终与真实输出有效字节/4一致 |
| O_INFLIGHT | 内部维护 issue−commit；报告仍必须0，并另核查总线债务，不用软件0冒充已排空 |
| quant_groups/inputs | 仅完整成功量化组分别+1/+32；失败组不计 |
| trace_words/groups | 仅成功实际发出的记录计数；quant trace另按原公式；最终响应全部完成 |

当前 v3 c_issued/c_retired 可能被 HLS 合并更新；新版本应提供可只读绑定的语义 issue/return/commit/mask/PS-write事件。新内部退休时刻不直接套旧状态号，最终 ABI计数和值须逐字节一致。

### 8.3 微块生命周期与 bias/output

每个 m0先初始化其 lane_bad；g0 从 +0 建立新的 PS，无需清 payload。待最后 g/tile 的全部向量commit、result ring为空、固定流水无有效token、当前微块trace全部B响应完成，才进入原 tile→rr→cc bias/output 顺序。

每个有效且未坏 lane读当前PS和bias。`value = bias_kind ? F32(old+b) : old`；无bias路径不额外加+0，保留原 `!finite(b)||!finite(value)` 检查。bias错误置bad、参与g=G/phase0秩，不写输出。输出成功后才更新选中trace的bias/final字段。可在全算术管线排空后以模式互斥复用现有一个FADD用于标量bias；新增bias服务或吞吐优化须入预算，不默认免费新增。

普通输出地址保留 `(r×N+n)×4` 加原基址；QKV原 `plane/head/batch/row0` scatter与head奇偶选择out0/out1保持。首版沿原标量输出流程，真实AXI握手/WSTRB/响应纳入退休。

**只有这个四行微块的最后 PS、lane_bad、trace 和全部 output 响应均排空，才复用32个PS bank地址及lane_bad进入下一m0。** 不让下个微块覆盖前块正待bias/输出的数据；双PS重叠是独立新合同。全任务first_rank始终保留，不在微块边界清空。

错误最终使PS/dst INVALID，但此前成功lane/微块可能已把合法字节写到外存；保留原副作用、计数和未写哨兵，不增设全tile回滚。成功才允许READY和原done_elements/单位；失败沿当前源/report的任务、量化完成、error_phase、输出数量等字段，不能将诊断写数误填为成功输出数。

## 9. Trace、背压及完成

量化trace按现有顺序在linear启动前写完：q从word256开始，capacity16384 words；scale从word16640开始，capacity1024 words。selected group trace从word17664开始、每组8words、最多128组；observed总32768 words。record固定为 `[dot,sa,sw,product,term,next,g,1]`，全部取真实计算位型，不用独立替代计算。

issue在尚未知lane_bad前，若shape包含selected lane则保守预留一个trace槽。固定流水return时把该lane的真实中间值写入所预留trace槽，槽仍为RESERVED，writer不可见；这样result等待commit期间不会丢失已经离开FP流水的中间值。该lane后续证实inactive或本组phase失败，commit将其标CANCELED；成功则在PS写提交后标READY。trace payload存储须支持至多一条完整256-bit返回写及另一槽的writer读并行，不能只提供一条共享口后假定无冲突。Dtrace=4为候选有限容量，足够保持功能安全但不承诺trace-on速度。

trace ring保持issue/g顺序，槽状态FREE/RESERVED/READY/CANCELED/SENDING；head只有READY可发AXI、CANCELED可无事务回收。已取消非head槽仍按顺序回收，避免ring中间释放形成未定义洞。SENDING直到全部8words及对应B响应完成才能FREE；AW/W独立、VALID与payload在反压时稳定。可复用当前observed写适配，不把“一次C赋值完成”当B已到。

trace信用守恒为 `free+reserved+ready+canceled+sending=Dtrace`。trace槽满时只阻止需要trace预留的下一向量issue；严格scheduler不越过它。既有result仍无条件返回到各自预留槽，commit无需再申请trace容量。因此无循环等待；对最终会返回响应的有限AXI暂停，writer释放信用后能继续。外部永不响应不可能由内部FIFO保证完成，由既有Host超时/平台恢复处理。

最终完成分两步：先确认全部scheduler工作及微块输出结束、result/trace队列空、算术valid清空、PS/lane_bad写完成、所有AXI读/写响应退休；再形成最终256-word report并等待其写响应。此后才允许ap_done/TaskDone.drained和下一命令。O_INFLIGHT=0只是最终字段之一，真实总线债务必须在done采样沿为零，不能等下一拍再补齐。

## 10. 8-lane Quant 的具体首版

量化属于主设计已选择的C1内容。首版保留“完整FP输入先读取，所有量化成功后才linear”，不流式缩减外部读量，不使早期quant失败改变规定的activation读字节。

1. 每组32个F32存为8×4寄存bank（或完整可访问1024-bit寄存组），四拍每拍8项。每项保存原bits，有限判定位单独收集；fabs仅清sign。对有限输入，用非负F32的31-bit编码作无符号平衡max，含subnormal且−0归+0；NaN/Inf不入max，原组内最小输入索引单独编码。按r→g递增处理，发现错误时不开始后续组的可见工作。
2. amax确认无输入错误后，顺序执行真实 `d_full=F32(amax/127)`，`inv=d_full==0 ? +0 : F32(1/d_full)`，以及原half RNE保存转换。不用预存1/127乘法替代除法，也不用saved-half倒数替代d_full。
3. 检查d_full、inv有限及saved-half非Inf/NaN；出错bad_element仍为该组首项。八路独立FMUL/round/convert服务按block重放原32值，目标每拍8项；保留product非有限、rounded非有限和[-127,127]检查。d_full=0仍保持原product求值及检查，rounded指定+0；合法有限输入×0不凭空改作错误。roundf半整数远离零；合法整数最后转signed8。
4. 每个block先独立产生8bytes，再合成一个64-bit块，四块定址拼256-bit；失败组不发布Aq/As。全部32值和saved成功后才同时写同一组Aq/As并计quant_groups/inputs，随后才推进下一组。整个rows成功后A8 READY；失败使A8 INVALID，linear不启动。

首版组与组保守串行，当前组内部四block可以流水，输出按block索引收集；整个组错误索引取最小，后续block的内部运算不改变外部计数/写入。这样不需要新增跨组reciprocal/half任务队列。跨组div重叠是后续独立变体，必须带完整tag/credit/错误排序，不计入本草案首版吞吐。

数值边界必须在真实wrapper下逐位验证，不能从XCI `C_HAS_UNDERFLOW=0`（异常报告设置）推断FTZ：

| 输入/条件 | R0要求 |
| --- | --- |
| amax=127×2^-127，bits037e0000 | d_full=2^-127，bits00400000；inv=2^127，bits7f000000；savedhalf=0，但max项q=127，不能只比最终bias隐藏错误 |
| amax=2^-126，bits00800000 | d_full为正subnormal，reciprocal溢出；quant拒绝，linear不启动 |
| amax=2^-149，bits00000001 | d_full舍入为+0，inv=0、q=0允许；不能一概拒绝极小输入 |
| 全零PS加bias bits00000001 | 有bias路径必须保留F32最小正subnormal |

half最小非零2^-24解码后是正常F32，两个half的非零最小product为2^-48，也是正常F32；bias之前的合法term/PS基于该量级，不把所有restore乘法说成必然产生F32 subnormal。量化除法和任意F32 bias仍有独立精度边界。

## 11. Reset与元数据生命周期

沿现有metadata_reset边界，只重置context/任务/epoch状态、scheduler、busy/guard、A寄存槽valid、result/trace槽valid与信用、算术有效位。W/Aq/As/FP/PS/bias payload RAM不遍历清零；result/trace payload同样只清valid。lane_bad是每微块主动初始化的元数据，未初始化tile不可issue。

复位清空语义valid移位，旧FP数值即使继续冒出也不允许result/PS/trace提交。命令错误的正常排空不能清掉尚在途valid来伪造done。暖复位验收沿已接受的“先完全排空，再复位”边界；不声称本草案解决运行中AXI被reset后的旧响应/写入隔离。运行中复位需平台abort/drain及session恢复证据，是独立合同。

## 12. 资源与性能条件

此处只复算条件，不替代主模块results.md的将来同源报告。

| 项目 | 条件值/公式 | 限制 |
| --- | --- | --- |
| integer DSP | 32×32=1024 | 若每signed8乘积使用1 DSP；需要实际映射 |
| restore DSP | 64 FMUL×3 +32 FADD×2=256 | 沿当前FP系数；新wrapper设置必须重核 |
| integer+restore | 1280 DSP | 不含quant、地址/控制、bias新增服务 |
| provisional sum | 1280+8 quant FMUL×3+旧其他29=1333 DSP | 旧29并非稳定新资源，不是最终报告 |
| dot树寄存 | 17696 bit | 不含产品/标签/广播/FP pipeline |
| A小预取 | 2×4×(256+32)=2304 bit+metadata | 不复制full A8 |
| result/trace | Q×S_result + Dtrace×256 bit+metadata | Q由实测L_return/commit读延迟确定；trace payload为4×256=1024 bit |
| busy/guard | 各最多656 bit | 保留原32 lane_bad bank，首版不打包瘦身 |
| W/A/PS RAM | 沿当前存储几何 | 不能把旧341BRAM/256URAM当新最终数；新增队列与布局另报 |

Q及所有latency保留符号值，待新实现真实测定后代入；不能在实现中随意选择旧wrapper文件名数字填表。

C1满有效向量理论1024 MAC/拍；真实利用率扣除尾行/尾列、A预取、feedback、credit、量化、微块清理/排空、bias/AXI、LOAD和report。Scorer rows1理论只有256有用MAC/向量，ACT rows1/N2只有64。对trace-on/off分别计时，冻结accepted start→done、量化/compute/trace/output/report的事件；重叠区间不重复相加，独立stall原因用互斥主因或明确多因位图，不能累加重叠百分比。

全图fe067 B1/S128：962量化任务、22266112输入、695816组、47160754688 MAC。8lane两遍理想串行扫描37.110 ms@150MHz；两个独立扫描引擎且跨组重叠被证明后条件下界18.555 ms，此首版未采用。TM4/TN8纯Q8理想约307.04 ms已超过50 ms；若158138376 B输出全外写，两32-bit口150MHz总峰值下界131.782 ms，且普通矩阵只用out0。不能用C1局部II=1宣称达到50 ms。

同系数TM16/TN16的INT+restore为10240DSP，大于U55C 9024DSP；器件960URAM不是shell后可用量。Attention/其他核/平台shell余量仍未知，不能记零。Host口径继续保留一次session模型448923648 B以及每请求184 MiB workspace+32 KiB IO H2D、384 B D2H；C1不修改该端到端计时合同。

## 13. 实现前闭合项和将来验收

本草案完成的是候选接口/时序设计，不是任何下列检查已执行的声明。

1. 主 Astra在既定Scorer三命令真实数值/阶段/推进率后确认本草案，选择最终新身份、预算、实现边界及工具门；只有Sol负责实现/EDA。不得覆写v3或冻结gold，不重跑已接受ACT36来凑覆盖。
2. 新源码静态审核：32独立dot、固定五层、32 conversion/64 restore FMUL/32 FADD、8 quant服务、8W/4A/32PS bank；无共享标量化、无隐式FP结合、固定A stride、完整metadata reset。half65536位型等价及phase/rank/边界由独立参考检查。
3. 同源HLS/RTL记录所有L/II、Q和Dtrace、result实际位宽/端口、busy/guard、actual PS读写沿；补齐32lane时延一致和tag延迟。用真实输出槽守恒而非无界stream证明容量。
4. 独立自检重点：连续满速独立tile；T<F/N2；g127/G128；rows1/3/4/5/15/16；K2624/G82；N5248；空mask；当前组失败后下一组不计MAC；多lane/跨tile/跨m0/bias的rank逆到达；负零、half subnormal/NaN payload、FP32 quant/bias边界。
5. 反压压力：result占满、trace槽满及取消、长AXI暂停、同沿return/commit/issue、指针回绕、selected trace失败、最后trace/output/report B延迟；停顿有限时最终推进，所有信用/数量守恒；先排空再暖复位、失败后合法恢复。新测试映射C1真实握手，不照抄v3状态号。
6. 所有最终F32及A8/half逐位比对独立R0；trace声明选中lane全G覆盖，未观察的中间量不冒称全部验证；副作用和未写哨兵逐字节对账。全K/N真实窗口不能退化成截短算术用例替代。
7. 同一源身份做无黑盒OOC资源/内部时序检查，6.667ns请求与实际WNS/TNS分开；实际physical DSP与URAM映射、拥塞/扇出、队列/LUT/FF均报告。完整核/shell集成和上板仍为后续独立验收。

待确认数值为所有新FP/存储latency及II、result最终容量/映射、新资源与时序、全维执行代价、精度边界真实wrapper行为；这些未知项均有明确观察/审核出口。本轮无实现、无仿真、无综合、无性能达成结论。
