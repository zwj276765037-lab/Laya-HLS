# C1 首个隔离实现交接合同草案

状态：供主 Astra 审核的设计准备；**不放行实施、材料化、CPU/CSim、HLS、RTL 或 OOC**。唯一实现/EDA 负责人为 Sol max。当前真实 Scorer 三命令及被动观察优先；CPU 已接受不等于三命令 RTL 系数已取得。以下是对 [已接受详细合同](q8_c1_arithmetic_pipeline_design_draft.md)及[独立审核](reviewer_q8_c1_detailed_arithmetic_pipeline_design_review.json)的实施交接摘要，不能替换或放宽它们。证据精确哈希见同名 JSON；当前 [模块设计](../../vivado/module_design/q8_linear_and_restore/source/design.md)只读。

## 1. 最小候选文件范围

候选新根为 `vivado/module_design/q8_linear_and_restore/c1_pipeline_v1/`，本次未创建该目录。待独立实施门确认后，只在该根落地以下文件；若需要额外生产源或改变接口/数值合同，先提交具体差异审核。

| 文件 | 职责与边界 |
| --- | --- |
| `source/q8_joint_tm4tn8.cpp` | 从已绑定 v3 派生新的 top；保留原入口及 LOAD/预检/报告/标量输出合同，替换内部量化及计算/退休调度 |
| `source/q8_joint_tm4tn8.h`、`source/q8_joint_abi.h` | 原声明与 ABI 逐字节复制并绑定；不得重定义字偏移、字段宽度或外部函数签名 |
| `source/c1_arithmetic.h` | 具名独立 lane、固定整数树、精确 half 解码、R0 恢复、8-lane 量化；允许模板，但交付真实实例映射 |
| `source/c1_flow.h` | 内部标签、A 槽、result/trace ring、busy/guard、rank 与元数据复位；明确有限容量和读写事件 |
| `tb/test_c1_contract.cpp`、`tb/c1_cases.json` | 独立参考/断言入口与用例和已有冻结输入/期望的绑定；禁止由 C1 输出重建 gold |
| `config/c1_candidate.json`、`tb/prepare_c1_cpu.sh` | 明确候选存储容量、操作绑定/期望时延、构建输入和严格 FP 参数；脚本只作为待审核源码，本门不执行 |

原 v3 源/ABI/制品/ACT36/Scorer 包、生产 fe067、模型 BO、Controller、Host、13 口核和现有正式配置不改。首批不引入第二份 W/A8/PS、外部 ABI 扩展或双缓存重叠。设计/结果记录先写新候选目录；主审核接受后再更新既有模块的当前文档并保留前像。新 HLS/OOC 运行器不混入首个源码交接包。

## 2. 首个实现必须一次保留的结构

- **固定整数树与 32 个 R0 lane。** 每 lane 为 32 个 signed8×signed8→signed16 乘积、16/8/4/2/1 节点的五级寄存树，位宽 17/18/19/20/21，最终符号扩展 INT32。首变体明确 DSP 绑定。每 lane 独立 I32→F32、scale FMUL、term FMUL、PS FADD，分别实现 `F32(sa*sw)`、`F32(float(dot)*product)`、`F32(old+term)`；g0 的 old 为 +0，仍真实执行 FADD。不做 FMA、跨 g 重排或分裂累加器。源码展开与 pragma 不能代替生成实例数。
- **真实 bank 和广播。** 8 Wq/Ws bank 每向量至多各读一次并广播四行；4 Aq/As bank 用 `(m0/4)*128+g`，保持两个小 A 预取槽，每槽 1152 数据位及标签/valid，跨所有 T 列保留。32 PS 与 32 lane_bad bank，按 shape 门控地址；同步 lane_bad 返回后才形成 active mask。所有 65536 half 位型（含 ±0、subnormal、Inf、NaN 符号/payload）固定时延精确解码。Ws 20992 深度及实际原语映射冲突保持待测。
- **8-lane 量化也在 C1 范围内。** 先读完整 FP 输入，再按 r→g 串行处理组；组内 8×4 存储、有限 abs 位型平衡 max，非有限错误按最小原输入索引独立选择。保留实际 `/127`、用 d_full 的倒数、half RNE、8 路 FMUL/round/convert、roundf 半整数远离零与范围检查；四个 64-bit 块定址拼 256-bit。整组成功才发布 Aq/As、计 +1 组/+32 输入；全 tile 成功才允许 linear。没有跨组 divider 重叠的性能信用。

## 3. 必须写成可检查事件的控制合同

`issue` 必须原子预留 result、必要 trace 槽，置 tile busy，读取 bank、复制 A 数据并推进 scheduler；任一条件不满足均不发生。上下文从命令接受锁定到最终 report 的 B 响应退休。每个已 issue 向量（包括全屏蔽、错误及 trace 取消）恰好 return/commit 一次；固定算术 return 不受 AXI、trace 或 commit 阻塞，写入已经持有的槽。result 顺序 commit，只提交最老 RETURNED 项。

result 三态为 FREE/RESERVED_UNRETURNED/RETURNED_UNRETIRED。候选有限 Q、每槽精确字段/位宽、实际存储端口必须在源码包列出；已接受的 `Q=pow2ceil(max(2,L_return+2))` 只适用于原边沿前状态、最早 return 后下一拍 commit、再下一拍重用 credit、commit II1 的假设。生成前的配置时延只能标为预期值；不得冒充测量。信用预留独立保证不溢出，满速是否足够要等实测；若增加 RAM 读/提交/信用延迟，重新推导并冻结新配置，不保留虚假的 Q 或 II1 结论。

busy 只在真实 PS/lane_bad、分类和元数据 commit 后清；同 tile 在提交沿 c 后的 c+1 整拍不得新读，最早 c+2。g 外层/tile 内层，不越过阻塞项，不加虚假依赖 pragma。N2/T1 和 T<F 显式等待，保持同一 lane 原 g 顺序。

trace D=4 为有限候选：issue 按 selected shape 保守预留，return 捕获真实 8-word 中间值，成功 PS commit 才 READY；inactive/错误 commit 为 CANCELED。严格按 head 回收，SENDING 等全部实际 B 响应后 FREE。提供整条 256-bit return 写与另一槽 writer 读的并行端口；commit 不再申请 trace 信用。当前 m0 算术、result、trace 及 output 响应全部排空后才复用 PS/lane_bad；最终 report 写响应完全退休后才 done。

首错取全命令最小 `(tile,r,cc,g_or_G,phase)`，28-bit key 含 10/4/3/8/3 位及独立 valid；不能用到达顺序或 bad_element 大小代替。bias 为 g=G/phase0，跨 m0 保持 rank。当前失败但 active 的组仍计 32 MAC，此组不写 PS/trace，后续 g 跳过该 lane；其他 lane/微块继续，不回滚已合法写出的外存。不把 PS 写计为最终元素写。LOAD 失败、量化失败、linear 各 phase、输出/bias 失败的原 status/detail/bad_element、任务/epoch、INVALID/READY、计数、字节访问与未写哨兵均逐项对账。

只复位 context/epoch/scheduler、busy/guard、各槽状态/信用及语义 valid，payload 不整体清零；lane_bad 每微块使用前初始化。已排空后的暖复位是当前边界，运行中 AXI reset/旧响应隔离仍需独立平台合同。

## 4. 首批提交包与执行前审核点

首批交付应是完整可读的源码差异、输入清单和下列自检源码/用例定义；**本草案不执行这些测试，也不规定扩大工具预算**。

| 包 | 最小内容与通过标准 |
| --- | --- |
| 身份与结构 | 新 C1 根、父 v3 源/ABI 哈希、每个新文件 SHA、实际 include/编译清单；列 32 dot/32 convert/64 restore FMUL/32 PS FADD、8 quant FMUL/round、8W/4A/32PS 的源码归属与将来 RTL 映射栏；后者生成前保持未验证 |
| 独立算术 CPU | half 全 65536 位型对旧逐位解码参考；signed8 边界（含 32×−128×−128=524288）和独立宽整数 dot；每步严格 F32 R0、g0 ±0、负 dot、half 次正规、round tie、非有限/最小索引；记录实际编译/标准 libm、禁 fast-math/FMA，不能把主机通过扩大为 HLS FP 行为 |
| 队列与 rank CPU | 以独立事件账本检验信用守恒、同沿 issue/return/commit、wrap、全 masked、失败 return、trace cancel/长暂停、真实 commit 才清 busy 及 c+2 约束、跨 tile/m0/bias 的逆到达 rank；可用多组显式测试时延检验不变量，但不把测试时延称为目标 RTL 时延 |
| 实际 top 数值候选 | 复用冻结独立 R0 输入/期望定义：ACT 完整 K256/N2 的合法/同 W 复用/trace on-off/故障后恢复，以及 Scorer K1024/N1024 首三命令。对新 C1 执行时是新身份回归；不重跑未改变的旧 v3 ACT36。保持全 K/N、A8/half/selected 全 G trace、最终 F32、计数/副作用/全区哨兵逐项比较。立即执行哪些用例与预算由后续源码审核确定 |
| 精度与后续覆盖清单 | 明确 amax bits037e0000→d_full00400000/inv7f000000/savedhalf0/q127、00800000→reciprocal 溢出拒绝、00000001→允许 d=inv=q=0，以及 PS0+bias00000001 输出00000001；后续 rows1/3/4/5/15/16、G128、K2624/G82、N5248、QKV scatter、错身份/epoch、跨列块首错分别留门，不能以短 K/N 单元测试宣称全形状通过 |

独立参考不得包含 C1 的树、ring 或 rank 辅助函数作为 gold；复用稳定生产 R0 或单独宽整数/位操作参考并绑定来源。C1 source static checklist 可以发现缺项，不能证明注册级数、复制数量、实际端口或保持时序。

## 5. 生成后才能填写的结论与后继门

新 HLS/RTL 必须实测 Wq/Ws/PS/lane_bad/half/INT multiply/I32转换/两级 FMUL/FADD/classify/store 的所有 L、II，32 lane 对齐、实际 return→commit→credit 与 PS 读写沿；据此冻结 L_return、F、Q、result/trace 宽度/端口、有效与标签路径。若工具共享通道、可变延迟或调度不满足合同，保留失败证据并回到设计，不用状态号/pragma/CE/tvalid 名称推断满速。

实际 wrapper 的上述 F32 精度边界另测；`C_HAS_UNDERFLOW` 只是异常报告配置，不能证明 FTZ。新的被动观察器绑定真实 C1 accepted start/issue/return/commit/PS写/B响应，不能复制 v3 状态号或把当前 c_issued/c_retired 批量更新当事件。资源与频率要同源 OOC 测 LUT/FF/DSP/BRAM/URAM、Ws 地址/原语和约束；1280/1333 DSP 是条件估算，不是映射结果。C1 同几何理想 B1 Q8 已约307ms，不授予50ms或平台 shell 适配结论。

推进顺序：Scorer 实际三命令独立接受 → 主 Astra 审核此交接合同并另发隔离实施门 → Sol 提交新源码/配置/CPU包 → 独立源审及逐阶段执行门 → CSim/HLS生成结构 → 有界数值/协议/恢复RTL → 同源OOC。具体执行顺序可由主审核按已接受证据调整，但每次必须保留新身份和独立技术门；本草案本身不授权任何一步执行。
