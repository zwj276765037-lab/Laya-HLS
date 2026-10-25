# SM007 共享 FP 数据流接口细化与 AT007–014 架构审阅

日期：2026-10-17。决定：`D-M006-SM007-FP-DATAFLOW-01`。适用：M006 修订 5、SM007；A001 主控裁定参考，A002 实现。审阅角色沿用原启动配置；当前运行工具未回显实际 model/effort，不作实时身份确认。

## 1. 决定与证据边界

批准在**同一物理 256 个 F32 multiplier 和 256 个 F32 adder**中拆分乘法、加法的发射、返回、tag 和 credit；QK 的六个树级及最终 score 加法具有各自有效位和流控组。这是落实原固定数据流的接口细化，不增加算术阵列，不改变数值、时钟、资源、周期或 SM007 预算。生产实现仍只在 E002 根内维护，父图与诊断使用同一模块。

AT009 的同次 issue、整向量乘加配对回执只证明原接口局部功能；其单一 tag/valid 不能直接表达 QK 同拍不同树级处理不同 score token，也不能要求 AV 的当前乘法与较早乘积加法具有同一事务身份。仅拆成两个整向量 tag 仍不足，QK 各加法组必须能携带不同 token。新接口需以新冻结版本重新验收，旧 PASS 不自动继承。

**已发现必须修复的叶子延迟差异：** AT009 冻结 `tm1tn8_fmul_ip.vhd` 第 245 行配置 `C_LATENCY => 6`，`tm1tn8_fadd_ip.vhd` 第 249 行配置 `C_LATENCY => 11`，两者 `C_RATE => 1`。合同 §10.1 的 mul/add 各 ≤8 cycle 保持，add=11 不能作为新接口合格参数；需修复生产配置/实现并核实际 valid 延迟及严格数值。当前简单值测试也不能证明 subnormal、±0、舍入边界及非有限检查语义。

## 2. 物理单元、事务身份与最小接口

保持唯一 phase lease。lease 上下文含 request_id、generation/epoch、phase、head、合法工作范围及所用 bank 归属。每个在途 token 至少可无歧义恢复上述身份、query_group、key、操作/树级、节点/有效 lane；重复的 lease 常量允许存于有生命周期保护的公共上下文，不要求每个数值字复制全部字段。有限 tag 位宽必须有可证明的不绕回窗口。

- `mul_req` / `mul_rsp` 独立握手；QK、AV 为 256-lane 向量，返回不等待同拍 add 返回。
- `add_req[group]` / `add_rsp[group]` 独立握手；QK 使用下表七组，AV/restore 使用一个 256-lane 组。组划分由已持有的 phase 决定，空 lane 不发射。
- 一组内所有 lane 同拍接受、同拍返回；检查该组实际 valid 一致。不能继续要求 QK 所有 256 个 adder 的 valid 恒等，因为不同树级可能有不同空拍。
- 叶子延迟来自冻结配置并由实际返回 valid 验证。tag 流水可按确定延迟实现，但计数退休必须响应真实 valid 和实际 sink 握手，不能只按定时器猜完成。
- 每个叶子两输入在同一 fire 下有效；mul 和 add 可以在同拍使用完全不同的 token。输入及返回在 valid 且未 ready 时保持 data/tag/phase/epoch。

物理映射及复用关系必须在层次/OOC中可核查。QK 的七组不是新增七套阵列；其他 phase 通过同一实体重连。非反压 FP IP 不靠停钟消化阻塞。

## 3. QK：固定六级树与 score sink

一个 QK token 为 `(head, query_group, key)`，含四个相邻 query 的完整 64-channel 点积。mul lane `64*q+c` 计算原 `F32(Q[q,c]*K[key,c])`。两套 Q 保持组各 4×64 F32；每次装载四行，下一组装载隐藏在本组 128-key 发射期间。K 每拍只从 64 个 bank 读一次，广播至四行。

| 组 | 同一物理 adder lane | 每个 score 的节点数 | 输入与顺序 |
| --- | --- | ---: | --- |
| T0 | 0–127 | 32 | 乘积相邻 `(0,1),(2,3)…` |
| T1 | 128–191 | 16 | T0 相邻配对 |
| T2 | 192–223 | 8 | T1 相邻配对 |
| T3 | 224–239 | 4 | T2 相邻配对 |
| T4 | 240–247 | 2 | T3 相邻配对 |
| T5 | 248–251 | 1 | T4 相邻配对 |
| S | 252–255 | 1 | 精确 ×0.125 结果与原 mask/local bias 相加 |

每级组内按四个 score 顺序拼接，独立保存四-score token 的 valid/tag。稳态同拍 T0…T5/S 处理不同 key/query_group；不能等上一 token 走完六级才发下一个。树形、每步 F32 舍入和每阶段 finite 检查与原参考一致，不重排/FMA。

T5 后使用合同已有的四路精确 F32 ×0.125 单元，延迟 ≤16 cycle；含 subnormal、舍入和符号规则。原有限 mask/sliding bias 经已证明的常量选择产生，S 组仍执行原最终 F32 加法。完整 128 key 都计算，masked 项不省略。缩放、mask 元数据和 tag 与同一 token 对齐。

S 返回的四个 score 通过真实 bank 写回，建议四路原子提交：只有四个目标 bank 均可接受且检查完成时才退役该 token。PS score 映射保持 `slot=key//64`、`bank=(query%16)*32+(key%32)`、`address=(query//16)*2+((key%64)//32)`。同拍四个 query 落不同 bank；blocked sink 时 data/tag 固定，不重复写、漏写或提前置 valid。

每行 max 只在其 score 按原 key 递增提交时更新，比较使用严格 `>`，相等保留较早 key 的位模式（含 ±0）。score/max/head 完成必须依据真实写回和最后 key 的检查完成；不能只看最后输入发出。首四 score ≤160 cycle、全 head QK ≤4352 cycle，仍从合同边界计量。

## 4. AV：乘后加、PS hazard 与真实退休

调度固定 `key0..127 → query_group0..31`。mul lane `64*q+c` 计算 `F32(probability[q,key]*V[key,c])`，随后同一输出的 add 执行 `F32(acc + product)`。同拍当前 token 的乘法与较早 token 的加法独立发射，禁止配成同一次 issue 或合成 FMA。

V 每个 key 读 64 F32 后在 32 个 query_group 间保持；probability 由 G 复用银行每拍读四个值。PS 使用一套 32KiB，`bank=(query%8)*64+channel`、`address=query//8`。首 key 的 accumulator 是原 +0，不要求整块清零。

乘积就绪后才安排相应 PS 读并与 add 输入对齐；若提前预读，必须额外证明没有读到前一 key 尚未提交的旧值。每个 query_group 保存前一 key 的实际写回状态；未提交时禁止该输出下一 key 的读/加。无注入停顿时，同一输出相邻 key 发射相隔 32 cycle，PS 读接受→加法→写回→对后继可读全过程 ≤24 cycle。此反馈帽包含接口/队列/存储延迟，不能只报 adder 延迟。

为 product→PS read→add→PS write 逐段预留返回容量，返回与原 key/query_group 地址绑定。阻塞时允许入口停止，但不得超越 key 顺序、借旧 accumulator 或覆盖尚未消费的乘积。完整返回尾段 ≤64 cycle；最终 key 的真实 PS 写回完成后，按 32 F32/cycle 退休至 context 的 64-bank 生产存储。context 写回/检查未完成不得释放该 PS slot。首 32 context ≤4288 cycle，完整 AV ≤4608 cycle。

## 5. Credit、存储和有限阻塞

各流的占用定义为 `已接受 − 已被下一消费者真实接受`，包含尚在 FP 内的返回债与已经返回的数据；不得只计 FIFO 中已出现的数据。每次发射前必须取得该不可反压返回的真实存储/消费预留。

对每一组，实施参数表记录返回延迟 L、物理容量 C、R、B、消费数。R 专指已接受但尚未返回的数量，B 专指已返回但尚未被消费者接受的数量；两者互斥，`R+B=累计接受−累计消费`，不变量 `0≤R+B≤C`。发射增加 R，实际返回将一份 R 转为一份 B，实际消费减少 B；同拍事件按净变化更新，不能把已返回项同时留在 R 中双计。只有输入齐全、身份合法及返回容量足够时 fire。连续 II=1 所需容量须覆盖 L 个在途及接口寄存级；可用保守的 `C≥L+2` 起步，再据实际读写同拍规则证明。测试有限阻塞可超过 L：入口随 credit 耗尽停止，已发射结果全部安全落位，阻塞解除后前进。不能用无界 FIFO 假设维持吞吐。

建议采用组宽匹配的有界返回 FIFO：QK 乘积 256 F32，T0…T5 为 128/64/32/16/8/4 F32，scale/S 为四 F32；每级被消费后立即回收，仅保留仍需使用的中间量。AV 的乘积只保存至对应 add 接受，accumulator 的权威存储是 PS。无须为每个 score 保存额外完整行 RAM，亦不保留已消费的全宽乘加历史。

**原合同 128 个 256-lane 向量返回缓冲/信用要求不取消。** 恢复/AV 的共同返回容量须给出实际可独立预留的槽数及物理 bank/端口证明；允许按 phase 对同一物理存储重分区，并以各级较窄 payload 存放 QK 中间量。不能把原 64 个不可独立消费的配对事务直接称为 128 个独立事务容量；也不要求为每个树级另复制一个 128×256 阵列。具体容量复用表及双向端口是综合前的工程证据，不以总字节相等代替。

AT009 的 `slot_mul/slot_add` 裸 payload 是 `64×2×256×4=131072 B`，加 5 拍乘法对齐约 5120 B，尚不含 tag/控制。其异步读整向量数组不能在未综合前认定为免费 RAM；LUTRAM/FF/mux/路由及无用乘加结果存储均计入原联合帽。新接口取消强制配对及无用对齐，不增加同样大小的重复存储。

流控使用 registered credit/必要 skid，避免跨六级 ready 组合长链。到满容量时拒绝新输入；满队列同拍消费/补入是否允许由明确 next-state 规则决定，禁止依赖 TB 时序碰巧通过。无注入性能例不得因不必要全向量等待造成内部气泡；所有实际内部停顿计入原服务帽。

## 6. Lease、错误、复位与 QKV 生命周期

匹配 phase/epoch 的 release 请求先停止新的根工作发射，但必须允许已接受 token 的树级/AV add/银行写回继续排空。不能用 `release_valid` 一刀切阻止所有内部 add 发射而造成排债死锁。错误 phase/epoch 的 issue/release 不取得所有权；拒绝行为和协议错误记录明确、可测。

phase release 条件同时包含：mul/add 各组在途归零；所有 stage FIFO/tag/credit 已归还；scale/tree/AV feedback 无剩余；QKV/PS/G/LN 本 phase 读响应和写回均已握手；context/score/max sink 回执完成；本地检查/错误及覆盖记录完成移交。计数器不以 force-zero 或固定等待值替代真实回执。

排空与成功完成分别记账。停止根发射不把尚未发出的 query/key 工作标成完成；正常 head 成功还须完整工作量、全部目标写回及 Check 通过。提前 quiesce/abort 后允许的排空/lease 交还只能保持 aborted/incomplete/failed 状态，不发布 head/context 有效或成功 RETIRE；若没有取消该任务，仍须恢复并完成剩余合法工作。匹配的提前 release 被拒绝本身也不是成功完成事件。

“错误候选债清零”指本地尚未移交的债归零，不要求整层首错候选被清除。整层控制器继续保存候选、head bitmap、原参考检查阶段/元素顺序及更早逻辑范围；必要时切换后续 head 完成更早检查。否则 head0 错误会阻止换 head、形成死锁。ERROR 只有在所有更早逻辑范围已决后发布；失败 head 的无效依赖不伪造通过，且不能污染后续 head 的只读 QKV。

request abort 停止无关发射并排尽实际返回；hard reset 按真实 IP 复位要求执行、同步释放并隔离旧返回。新 generation 开始前重新建立银行有效范围，不能仅重置 pending 指针而接受旧流水输出。QKV RAM 不因局部 rst 自动清空，caller 必须用 generation/完整写入覆盖或等价 valid 账本证明读数据属于当前请求。

AT013/014 的地址 `{head,token}` 与三 plane×64 bank×2048 F32 映射正确，32列矩阵写入口和 Q/K/V 独立 64列读可用于当前 QK/AV 连接。父级必须追踪读响应与实际写接受；同址读优先意味着写 valid 可被拒绝，不能将一次提出写请求记为已退休。半幅写入两次完成之前不能把整行声明为完整。

后续原合同 RoPE 还需 Q、K 每拍各 64 F32 的同时读写。现有单一 `wr_plane + 32列 wr_data` 接口只有 32 F32/cycle 写能力，不能直接满足该要求。接 RoPE 前须在**同一 192 个物理 bank**上加入 Q/K 独立 64列写入口/使能和 phase 仲裁，矩阵 32列入口作适配，禁止复制 QKV 或以四拍串行写回代签 2176-cycle 帽。当前单head QK/AV 不等待这项后续模式实现，但接口职责不能误记为已完成。

## 7. 最小同版验收与下一生产边界

旧结果保留原范围：AT009 是 100MHz 功能 TB，64 个 QK 命名向量使用相同四种 lane 数据，三拍保持仅查 valid/tag/release_ready；没有 payload/phase/epoch 每拍保持、满槽第65次拒绝、匹配提前 release、同拍回收补入或在途复位覆盖。AT013 同为 100MHz 功能 TB，只覆盖三 plane 的地址0及 Q 的地址2047，三 plane 一同阻塞；不称全深扫或 K/V 独立持续消费。无需为即将替换的配对接口补长回归。

新接口先以同一生产源完成以下有界定向检查，再运行完整单head；不增加原 SM007 分类预算或单次帽：

1. 每个周期/lane/树级不同的独立期望值；mul 与 add 使用不同 tag，QK 七加法组同时处理不同 token。核每组 latency/II、全部返回身份/数据与有限边界，包括 ±0、subnormal、舍入和原 finite 检查；生产 add 必须满足 ≤8cycle。
2. 连续流至少覆盖全部流水填满、同时发射/返回/消费及环指针绕回；精确填满后尝试额外输入；按明确规则核同拍消费补入。阻塞期间逐拍核全部 data/tag/phase/epoch；恢复后无丢失/重复/乱序，尾后继续观察无多余返回。
3. 匹配 lease 的提前 release 必须被拒绝，排债可继续；错误 phase/epoch 拒绝；在途 abort、hard reset、新 generation 和后继成功请求。覆盖本地错误候选移交后可换 head、旧响应不能污染新 owner。
4. 用同一 QKV 生产 bank 建立完整单head S128/D64 QK：真实两 Q 保持组/K 广播、六级原树、scale/mask/max 和 PS score 回执。全部 128×128 score 与冻结独立参考逐位比对，核 full/sliding；无注入停顿首四 score/完整 4352-cycle 帽。
5. 真实 AV：从独立冻结 probability 输入 G 复用 bank，读真实 V/PS 并按完整 128key×32query组执行，逐位核全部 128×64 context；核32拍复访、≤24cycle反馈、实际 sink 与4608-cycle帽。该测试只签 AV，不把外部 probability fixture 当作生产 softmax 已完成。
6. 独立功能例给 QKV/score/probability/context sink 注入有限反压并核 credit/身份/后继恢复；原始总周期保留。PS/G/LN bank 先接本阶段真实需要的生产接口，其余原授权模式继续分项实现。最终共享/全宽 OOC 仍需实际层次和零blackbox，不以单lane倍乘验收。

## 8. AT012/014 实际综合归因与 SFU 下一步

AT012 F64 add 的已综合实体为 3376 LUT（3034 logic +342 shift-register LUT）、1923 FF、0 DSP/BRAM，并有零blackbox DCP。相对 HLS 的 6386 LUT/7845 FF，实际映射存在显著寄存器/移位结构优化；这只能更新该实体的资源证据，不能按同一折扣估算 F64 mul、整个 EXP 或8lane SFU。综合后 WNS +0.757ns 不是布线后300MHz验收。

AT011 mul 在约89s完成 Cross Boundary/Area Optimization、约98s完成 Technology Mapping，之后记录 Final Netlist Cleanup；120s成本出口前没有最终资源报告/DCP。它并非已有可信面积，也不证明算术不可实现；继续保留 COST_STOP，不因“接近结束”原样加时。缺少 mul DCP，原底向上 leaf 联结前提仍不成立。

若在现有余额内继续 EXP，下一项应改变可检验边界：对生成的 32×32 整数乘法子模块做一次 ≤120s、完整端口的较小 OOC，先核 DSP 映射/局部 DCP及耗时；或先给出 mantissa 范围证明，再以显式53bit/21bit边界做等价实现的有界对照。两条选一，失败不原样无限续跑；范围特化必须保留每步 binary64 RNE、边界和独立参考，不是近似 exp。独立直接 divider/严格 TANH 单lane仍优先补足资源缺口，不先复制8套 EXP。896 DSP 与全部联合帽不变。

AT014 QKV 为384 RAMB36E2、131 LUT、132 FF、0 DSP，恰为192 bank×每bank两块RAMB36；占用户核1200 BRAM36帽的32%，其余816尚需容纳其它实际实体。低 FF 并不表示读数据未保持，数据输出可映射至RAM资源。此证据只含该 QKV 模块，未包含父级有效性/lease、Q保持组、PS/G/LN/context、FP返回存储或RoPE新写端。综合后 WNS +1.237ns 同样不能代签布局布线。

## 9. 核查入口

- 固定要求：`mission/M006_CPU_FPGA协同高性能推理实现/contract.md` §3.1、§7、§10、§11；`tasks/SM007.md`。
- AT009：`project/E007_m006_full_fpga_attention/experiment_results/runs/R001/attempts/AT009_shared_fp256_fullwidth_pilot/frozen/` 下生产SV、full TB与两份实际IP VHDL。
- AT013：同 attempts 下 `AT013_qkv_physical_bank_local_pilot/frozen/` 的生产SV与TB。
- AT012：`AT012_strict_exp_f64_add_ooc_120s/work/utilization.rpt`、`timing_summary.rpt`、`f64_add_synth.dcp`及冻结 `ooc.tcl`。
- AT011：`AT011_strict_exp_f64_mul_ooc_120s/guard_ooc/driver.log` 第319–340行。
- AT014：`AT014_qkv_bank_ooc_120s_pilot/work/utilization.rpt`、`timing_summary.rpt`、`qkv_bank_synth.dcp`及冻结 `ooc.tcl`。

本审阅仅新增此说明，未修改工程源码、原合同、独立参考或冻结证据；未执行EDA/仿真/模型实验，未新增agent或恢复A003。Guard、manifest和费用由主控独立核查。

## 10. 严格 TANH 延迟风险的集中裁定

决定：`D-M006-SM007-STRICT-TANH-01`。状态为**旧实现不达标，新严格实现可行性未证**。TANH II=1/lane、输入接受至结果 ≤160 cycle、300MHz，以及8lane SFU/直接divider/Q/G等联合896 DSP和其余原帽全部保持；不以旧150MHz证据签新要求，不承诺160一定可达或一般性不可达。

本节源码位置均相对 `project/E002_Laya_HLS/experiment/vivado/module_design/vector_and_ffn/`：

- `tb/tanh_libm_canonical_generate.py:58–62` 按所有依赖的最早边沿立即发射，既有叶子消费延迟为 add=6、mul=14、div=12。`rtl/tanh_libm_canonical.sv:6071–6344` 是对应42节点（23add、17mul、2div）的真实静态展开，不是384拍空等待。
- 生成器 `:206–209` 在356沿形成 `selected_result/status`，随后明确对齐到384。SV `:6341–6344`、`:11365–11392`、`:12366–12367` 对应结果选择、28级纯尾延迟和输出。因此**可以明确识别的纯末尾padding是28拍**；修改时还须同步 valid/tag/status、credit和检查器，未验证前不记新RTL PASS。旧 wrapper 的消费边沿再多1拍，旧收据的首返回385与core384并不矛盾。
- 主结构路径包含15个mul、18个add、2个div，既有算术延迟之和为 `15×14+18×6+2×12=342`，加14个转换/选择/输入寄存边沿得到356。Horner依赖 `mul6→add5→mul7→add6→mul8→add7→mul9→add8→mul10→add9` 见SV `:6142–6191`；中间除法 `div0` 见 `:6217–6221`，最终 `div1→add21` 见 `:6319–6328`。该计数解释当前生成结构，**不是所有libm等价实现的算法下界**；下一证书须进一步按可达分支核实，而不能拼接互斥分支。
- 较早完成的 abs/sign、mul5、tiny 分支等长移位链主要用于与较慢依赖对齐；删除寄存器不能使依赖数据提前产生。仅去掉28拍尾padding，旧结构仍为356沿结果，远超160。把时钟约束从6.667ns换成3.333ns也不会自动减少周期。

允许的优化边界：保留冻结 libm 的输入域、分支阈值、常量位模式、每次独立 binary32 RNE、除法方向、符号/±0/subnormal和错误语义；可以优化**单个相同算术节点**的逻辑/流水、对已有依赖做合法调度及寄存重排，或对已证明的常量/输入范围作逐位等价特化。分支特化必须证明谓词与可达输入域，并为混合输入流保持II1、身份/顺序/credit。不能改Horner为不同舍入的多项式树、合FMA、用reciprocal乘代除法、用另一exp公式替换tanhf/expm1f，或增加容差；采用通用IP也须先证明相同语义。

**唯一下一最小验证：一次有界静态 DAG/时延证书任务。** 计入原 module_reference 余额，单次≤120s、RSS≤16GiB；只解析被冻结源/生成器/既有节点trace身份，不运行整模型、整TANH HLS/OOC或8lane构建。交付每节点原A/B来源、舍入/操作类型、分支谓词和可达输入区间、最早接受/返回沿、最长路径；分开列必要算术、注册选择和纯对齐。以已验证的300MHz叶子参数或明确标为尚待验证的候选参数，给出每条可达路径到≤160所需的延迟约束和一个保持原语义的最小候选计划；不得把旧150MHz叶子参数冒充300MHz测量。对统一叶子延迟的当前结构，`15*Lmul + 18*Ladd + 2*Ldiv + C` 只是可复核起点，C含不能遗漏的选择/接口边沿，分支特化后必须重新求图。

若证书不能给出满足160的具体候选，交付阻碍路径和缺失叶子证据，TANH保持未通过；不先跑旧整图、复制8lane或原样加时。若存在候选，只能据此选择下一局部叶子/片段验证，候选数值与周期仍未验收，且后续动作服从原SM007余额/成本出口。共享QK/AV等独立授权工作继续，不等待把旧TANH包装成合格实现。

旧证据入口：`project/E002_Laya_HLS/experiment/results/compute_throughput_optimization_20261010/attempts/tanh_libm_canonical_01/receipt_functional.json` 的 `core_fixed_latency=384`、`first_consume_edge=385`；节点验证 `tb/tanh_libm_canonical_tb.sv:84–125`；叶子旧约束 `tb/tanh_libm_stream_helper_hls.tcl:8` 为6.666666667ns。本次仅静态审阅并追加此节，未重跑上述测试。
