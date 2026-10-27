# Laya 首版可部署工程：按推理顺序的 CPU / FPGA 分工

日期：2026-10-27（北京时间）。状态：用户已指定算子分工，更新为每层两个设备计算段；具体实现、资源与时序尚未验证。本文件没有启动实现、综合或上板，也不把旧 M007 功能结果当作新分工的通过证据。

用户已明确：第一版优先能上板验证，不先追求高推理速度；采用 CPU＋FPGA 协同；目前没有可用 U55C，先完成可部署工程。本轮要求按实际推理流程逐算子分工。模型、完整形状、层数、参考与数值语义保持。

最新直接指令：Encoder 的 3–10、13–16 放 FPGA；Decision 的 2–7、9–11 放 FPGA；输出尾部全部 CPU。编号对应下表，取代此前将 RoPE/Softmax/GEGLU/ReLU 及段内量化放 CPU 的讨论建议。此变更确定执行位置，不恢复旧全主干自治、宽并行或高吞吐指标。

后续用户要求充分利用 U55C 高带宽。按 §9 增加多通道 HBM、片上复用与计算/供数匹配设计；先前口头建议的 256 INT8 乘法并行仅作为调通规模候选，不作为最终架构规模。资源可容纳、严格数值、用户指定的 CPU/FPGA 分界保持。

## 1. 分工总则与图来源

- CPU 持有每层的权威 hidden 和残差输入，执行请求处理、Embedding、所有 LN、两段入口量化、残差、type add、全部尾部和层间调度。
- FPGA 连续执行 Attention 段（QKV→Encoder RoPE→QK→scale/mask→Softmax→AV→量化→Wo）和 FFN 段（Wi/FC1→GEGLU/ReLU→量化→Down/FC2）。段内中间结果留设备。
- FPGA 包含全部 120 个主干 Q8 线性矩阵和 30 个完整 Attention 的数值计算。一套资源跨阶段、head、层与请求复用，不复制 30 层硬件。
- FPGA 的 Q8 线性模式包含整数点积、scale 恢复、按 group 有序累加、适用 bias 以及完整 FP32 输出；不把每组部分和回传 CPU。
- CPU 与 FPGA 都保留严格数值检查；CPU 普通 BLAS、fast-math、FMA 或不同归约顺序不能自动替代原参考。
- 形状记法省略 B=1。S=128、D=1024、16 heads、每 head 64 维。

本次核对来源：

1. [实际独立参考](../../project/E002_Laya_HLS/experiment/tests/full_reference.py)：`full_forward_graph`、`qk_row`、`softmax_row`、`av_row`、`quantize_rows`、`q8_linear_full`。
2. [PRO 计划](../../PRO_plan/Laya_Full_Model_U55C_Deployment_Plan.md) §9.1–9.4：真实输入、完整数学顺序、Attention 与业务输出。该文后续“全部主干在 FPGA”的旧执行位置不作为本次新分工。
3. [原 M007 合同](../../mission/M007_完整Attention高性能主干与部署闭合/contract.md) §3：原模型、数值与完整形状身份；旧吞吐、全设备执行与一次 BEGIN 要求不移植到本讨论方案。

## 2. 初始化和请求前端

初始化由 CPU 核验模型/图/构建身份，加载 tokenizer、recipe、参数与辅助表；把主干矩阵权重、适用 bias 和原 RoPE 表上传设备，建立持久会话。Embedding、gamma、type 表和尾部权重供 CPU 使用。正常连续请求复用权重；重新加载 xclbin、重置设备或换模型后重新登记，不能使用失效地址。

| 顺序 | 计算 | 执行方 | 输出/交接 |
|---|---|---|---|
| 1 | 为每题构造完整 state＋question＋候选序列，tokenize、长度及 marker 校验 | CPU | token_ids[128]、mask、marker、qtype |
| 2 | token Embedding 查表并按原格式恢复 | CPU | FP32 E[128,1024] |
| 3 | 初始带 gamma 的 LayerNorm：原均值/方差/epsilon/归一化后乘 emb_gamma | CPU | H[128,1024]；保留作 Encoder0 残差输入 |

不同 question 是不同完整序列，不能只算一次 state 的 Encoder 后共用所有尾部。超长输入和非法候选遵原错误规则。

## 3. Encoder：以下顺序执行 28 次

| 顺序 | 算子与计算 | 执行方 | 张量与交接 |
|---|---|---|---|
| E1 | Attention 前 LN0；第 0 层跳过本次 LN，直接使用初始带 gamma LN 的 H | CPU | A[128,1024]，原 H 留作残差 |
| E2 | A 按每 32 个元素动态量化，产生 INT8 q 和 FP16 scale | CPU | Aq/As 上传 FPGA |
| E3 | QKV 线性：1024→3072，无 bias | FPGA | FP32 QKV[128,3072] 写 HBM |
| E4 | 按原布局拆 Q/K/V；对 Q、K 应用当前层的冻结 RoPE 表 | FPGA | Q/K/V 留设备 |
| E5 | 每 head 的 QKᵀ：每个 score 为 64 个 FP32 乘积的相邻二叉树归约 | FPGA | 原始 score 留设备 |
| E6 | score×0.125；按原顺序构造并相加 sliding/padding bias；加入 score | FPGA | masked score 留设备 |
| E7 | Softmax：逐行 max、减 max、严格 exp、固定树求和、逐项除法 | FPGA | P 留设备并直接供 AV |
| E8 | AV=P×V；每个输出按 key=0..127 依次独立乘、加 | FPGA | context[128,1024] 留设备，按原 head 布局拼接 |
| E9 | context 的 group32 动态量化 | FPGA | Aq/As 在设备内直接供 Wo |
| E10 | Wo 输出投影：1024→1024，无 bias | FPGA | projected[128,1024] 读回 CPU |
| E11 | 第一条残差 H1=H+projected | CPU | H1[128,1024]，保留作 FFN 残差输入 |
| E12 | FFN 前 LN0，然后 group32 动态量化 | CPU | 量化输入上传 FPGA |
| E13 | Wi 线性：1024→5248，无 bias | FPGA | Wi[128,5248] 留设备 |
| E14 | GEGLU：G=GELU(Wi[:,:2624])×Wi[:,2624:]，保持原严格 GELU | FPGA | G[128,2624] 留设备 |
| E15 | G 的 group32 动态量化 | FPGA | Aq/As 在设备内直接供 Down |
| E16 | Down 线性：2624→1024，无 bias | FPGA | down[128,1024] 读回 CPU |
| E17 | 第二条残差 H2=H1+down；保存本层检查点 | CPU | 下一层 H[128,1024] |

这里 LN0 表示原不显式乘 gamma 的 LayerNorm。layer=0,3,…,27 为 10 个全局层，其余 18 层为双向 |query−key|≤64 滑窗。仍计算全部 128 个 key，保留原有限负数 mask，不改成负无穷或跳过 mask 项。

这两次残差都是 CPU 计算。原 H 与 H1 的生命周期由 Host 保持到对应加法完成，FPGA 输出不能覆盖尚未消费的残差输入。

## 4. Encoder 与 Decision 之间

| 顺序 | 计算 | 执行方 | 输出 |
|---|---|---|---|
| B1 | 对 Encoder27 输出做带 final_gamma 的最终 LN | CPU | final_norm[128,1024] |
| B2 | 查 qtype 对应的 type embedding，按原格式恢复并广播相加 | CPU | Decision 输入 H[128,1024] |

最终 LN 的 gamma 不能遗漏；type add 在最终 LN 之后、Decision0 的 Attention 前 LN 之前。

## 5. Decision：以下顺序执行 2 次

| 顺序 | 计算 | 执行方 | 输出/交接 |
|---|---|---|---|
| D1 | LN0(H)→group32 量化 | CPU | Aq/As 上传 |
| D2 | QKV 线性 1024→3072，含本层 QKV bias | FPGA | Q/K/V 留 HBM；Decision 没有 RoPE |
| D3 | 16 heads 的 QKᵀ，仍为每 score 64 项相邻树 | FPGA | 原始 score 留设备 |
| D4 | ×0.125＋padding bias→严格 Softmax；全局 Attention，无滑窗 | FPGA | P 留设备 |
| D5 | AV，按 key 升序独立乘加 | FPGA | context 留设备 |
| D6 | context 的 group32 量化 | FPGA | Aq/As 在设备内直接供 Wo |
| D7 | Wo 线性 1024→1024，含本层 bias | FPGA | projected 读回 |
| D8 | H1=H+projected→LN0(H1)→group32 量化 | CPU | 保留 H1，量化结果上传 |
| D9 | FC1 线性 1024→4096，含本层 bias | FPGA | FC1[128,4096] 留设备 |
| D10 | ReLU→group32 量化；保持原零/负数行为 | FPGA | Aq/As 在设备内直接供 FC2 |
| D11 | FC2 线性 4096→1024，含本层 bias | FPGA | FC2[128,1024] 读回 |
| D12 | H2=H1+FC2；保存本层检查点 | CPU | 下一层或尾部输入 H |

Decision 的四个大线性均带 bias；Encoder 的四个大线性均不带 bias。bias 在完整 group 累加之后于 FPGA 加一次。

## 6. 输出尾部：全部 CPU

| 顺序 | 算子 | 输出 |
|---|---|---|
| T1 | 按 marker gather 全部 16 槽；LN0 | [16,1024] |
| T2 | scorer FC1 的小 Q8 线性 1024→1024，含原 baked bias | [16,1024] |
| T3 | 再加显式 scorer_fc1.bias，再执行原 GELU；两次 bias 不合并/遗漏 | [16,1024] |
| T4 | scorer FC2 的有序 FP32 dot＋bias，1024→1 | 16 个 raw candidate logits |
| T5 | candidate mask→内部 Softmax→原四项统计 | 16 个概率及 stats[4] |
| T6 | 本题最终原始 CLS 向量 H[0] 拼接 stats | act_input[1028] |
| T7 | ACT FC1：FP16 权重、原 FP32 运算，1028→256；bias＋GELU | act_hidden[256] |
| T8 | ACT FC2 的小 Q8 线性，256→2，含 bias | 2 个 ACT logits |
| T9 | 原温度/recipe、choice/score/noul 与 ACT 概率解码 | 最终业务结果 |

用于 ACT 的 CLS 不取 marker LN 后数据；内部 candidate Softmax 不混入 Host 温度。四项统计的 top2_approx 保留原配方。尾部两个小 Q8 和两个浮点 linear 留 CPU，减少小算子的提交与传输；主干 120 个大 Q8 仍全部在 FPGA。

## 7. 两种 Host 调用与设备内部数值边界

| Host 调用 | 输入 | 设备内部连续执行 | 返回 CPU |
|---|---|---|---|
| ATTENTION_BLOCK | CPU 完成 LN/量化的 Aq/As，层身份、mask、权重目录及 RoPE 类型 | QKV→可选 RoPE→QK→scale/mask→Softmax→AV→量化→Wo | FP32 projected[128,1024]，尚未加残差 |
| FFN_BLOCK | CPU 完成残差/LN/量化的 Aq/As，层身份及权重目录 | Encoder：Wi→GEGLU→量化→Down；Decision：FC1→ReLU→量化→FC2 | FP32 down/fc2[128,1024]，尚未加残差 |

以上是拟定的逻辑命令名称，实际寄存器/BO ABI 尚未实现。每个段内由设备完成顺序切换、结果检查和写回，正常路径无 CPU 中间数值处理；诊断导出与正常路径分开计量。权重与大中间量可放 HBM，设备执行不等于整个段的张量都驻留片上。

设备内部复用以下计算服务，并增加 RoPE/scale/mask、严格 Softmax、GEGLU/ReLU 与 group32 量化控制：

| 模式 | 输入 | FPGA 输出与职责 |
|---|---|---|
| Q8_LINEAR | Aq/As、已登记 Wq/Ws、shape、可选 bias | INT32 group32 dot→FP32 scale 乘积→乘 dot→按 group 升序累加→适用 bias→FP32 Y |
| QK | FP32 Q/K | 64 项乘积及原相邻树，输出未 scale/mask 的 FP32 score |
| AV | FP32 P/V | key 升序 FP32 独立乘加，输出 FP32 context |

Q8 的精确表达式为 `s=F32(As*Ws)`、`term=F32(s*F32(dot))`、`PS=F32(PS+term)`，最后适用 bias；不能改为先恢复各元素再作另一次普通 GEMM。CPU 入口量化和 FPGA 段内量化都用原 FP32 d 及其倒数计算 q，随后保存 FP16 scale，不能先把 d 舍入到 FP16 再量化。QK/AV 不自动改成 Q8/FP16，不允许 FMA 或任意重排归约。

设备采用小规模共享 FP32 运算、严格 EXP/TANH/除法服务分拍处理；严格 Softmax 与 GEGLU 的函数资源必须纳入综合，不能再只统计矩阵 core。QK 的相邻树通过保存中间值并分级调度实现，不要求一次铺开整个树；AV 必须按 key 顺序保留每个累加链。SFU 可采用低吞吐、少 lane、时间复用的实现，数值语义保持。具体 lane 数、周期和频率待小核物理结果确定，不自动恢复旧 256 路 FP32 或 8 路 SFU 目标。

一题设备工作仍包含 28×4＋2×4=120 个大 Q8 线性、30 个 QK 块、30 个 AV 块，并包含 28 层 RoPE、30 层 Softmax、28 层 GEGLU、2 层 ReLU 和 60 次段内张量量化。每个 Attention 块处理 16 heads。Host 计划每层提交 Attention 与 FFN 两段，共 60 次计算段调用，模型初始化与控制消息另计；这是架构计数，不是已测 launch 数或性能结果。

## 8. 数据驻留、交接和验收

- 主权重常驻设备 HBM。QKV/V、score、P、context 与线性结果按生命周期复用 HBM 缓冲；片上 BRAM 只保存正在计算的小块。大数组不能靠异步多端口读写展开为寄存器池。
- CPU 持有 FP32 hidden 和残差；只在每个 Attention/FFN 段入口上传量化后的 Aq/As，在 Wo/Down/FC2 段终点回读 FP32 结果。
- Q/K/V、RoPE 后数据、score、P、context、Wi/G/FC1 与内部量化结果在设备中消费；正常路径不通过 CPU 往返这些中间结果。Decision 旁路 RoPE。
- 每段输入均为量化后的 [128,1024]：有效载荷 128×32×34=139264 B（136 KiB）；每段输出均为 FP32 [128,1024]：524288 B（512 KiB）。60 段总 H2D=8355840 B、D2H=31457280 B，合 39813120 B（37.96875 MiB）。仅是本分工的无额外 padding 张量载荷计算，不含初始化权重/表、mask、命令、对齐、调试和协议开销，不是实测总线流量或时延；也不是旧每题只往返一次的方案。
- Host 只有在设备输出已写完且同步完成后消费；设备也只有在上传完成后读取。失败不能发布正常 hidden 或伪造成功。每次交接保留 request/operator 身份与明确 shape/layout。
- 按 QKV、RoPE、raw/masked score、P、context、Wo、两次残差、Wi/G/Down、final LN/type、Decision 与尾部逐边界比较独立参考，再完成同次运行的真实 30 层协同路径。旧整图 RTL PASS 不直接覆盖新软硬件边界。
- 第一阶段先建立最小 XRT/AXI/HBM 工程并取得平台链接及布局布线证据，再逐模式增加计算；不等完整软件图验证完才检查物理容量。
- 没有 U55C 时交付 Host、可重现构建、真实平台链接的部署候选 xclbin 与板上验证脚本；上板状态仍为 NOT_RUN。缺少匹配平台包时明确列为部署阻塞，不能把 .xo/裸 RTL 当作完整 xclbin。

用户选定的边界保留设备完整 Attention 和 FFN 数值计算，CPU 承担 LN/残差/入口量化及全图控制。资源缩减依靠降低并行度、分拍共享严格算术、同步 RAM 和 HBM 小块处理；不能仅凭把 LN/残差移至 CPU 推断面积已合格。其收益首先以完整功能、物理可容纳和可部署性验收；尚无实测速度或加速比。

## 9. 利用 U55C HBM：多通道供数与计算匹配

### 9.1 目标与物理边界

用户明确要求利用高带宽。设计目标是利用多通道并发和突发预取，降低真实算子 LOAD 与缺数停顿，在资源允许范围内匹配计算吞吐；验收同时检查有效工作、实际流量和等待原因，不把无效重读或纯流量占满当作性能提升。

AMD [DS978](https://docs.amd.com/r/en-US/ds978-u55c/Product-Details) 给出 U55C 16 GB HBM2、460 GB/s 板级规格；[UG1469 HBM Memory](https://docs.amd.com/r/en-US/ug1469-alveo-u55c/HBM-Memory) 给出两个 8 GB stack 和 32 个 AXI 接口。2026-10-27 核对。这是全卡标称总带宽，实际平台映射、跨交换网络争用、kernel 时钟和访问模式均影响可用带宽；HBM 带宽与 CPU↔FPGA PCIe 带宽分别计量。

当前仅确认本机 Vitis 安装目录存在 v++/platforminfo/xclbinutil；有界检查该目录未找到 .xpfm，不据此断言全机没有平台。目标平台暴露的 HBM bank 与连接尚待核定，以下端口为逻辑设计建议，不伪填实际 bank 编号或已实现带宽。

### 9.2 端口和布局

| 数据流 | 建议组织 | 目的 |
|---|---|---|
| 主干权重 | 4 个独立宽读通路为首个完整供数配置，结构支持扩至 8；按输出列块将权重及相应 scales 分片至不同 HBM bank | 同时读取不同列块；保持每路连续 burst，避免全权重挤在一个 bank |
| 激活/QKV/Wi/context 读取 | 独立于 W 的工作区读通路 | 计算权重加载与中间量访问可并行 |
| 结果及中间量写入 | 独立写通路、与主要读取避免 bank 冲突，按生命周期 ping-pong | 减少读写换向与端口争用 |
| bias/RoPE/控制描述 | 小型系数缓存和描述队列；数据通路的系数供数需匹配运算需求 | 避免每个元素都触发 HBM 小读取 |

512-bit 是逻辑接口候选宽度，必须以平台连接与宽度转换后的真实吞吐验证。仅配置一个 AXI master 可访问多个 bank，不等于获得多 master 的并发带宽。每路 q 与 scale 都需完整供给，不能扩大 q 后让 scale 变成串行瓶颈。

首个完整供数配置按每 W 读口至少 8 个在途、每 burst 不超过 1 KiB 且不跨 AXI 4 KiB 边界安排有限信用；4 路各 8 KiB 对应总 32 KiB 返回存储容量。数据必须有真实缓冲接收，不把 outstanding 配置代替容量证明。端口/平台限制更低时据实改接口与带宽预算，不静默降低承诺。

### 9.3 存储复用和加载重叠

- A 量化数据优先完整保留本次 M128 输入，按 K/列访问划分同步 BRAM/URAM bank；一个 W 页服务全部 128 行，目标是每次矩阵内每份权重有效载荷仅从 HBM 读取一次。缓存入口/出口和系数格式按实际生产语义验证。
- W 页采用两槽：计算当前页时预取下一页；页末有真实读/返回/引用退休后才复用。模型已在 HBM 不代表已进片上，首读和最后排空仍计时。
- 可综合的容量候选为 N32、全 K 的 W 页，按 group 顺序在 M128 上复用。最大 K4096 时，量化 A 为 544 KiB、W 单页 136 KiB/双页 272 KiB、M128×N32 的 FP32 PS 为 16 KiB；这里只计算有效载荷，bank/padding/双端口/元数据和管线返回另计。N32 表示缓存和调度块，不要求同拍计算 32 列。
- 每个输出保持原 group 升序累加；可以穿插不同 row/column 的独立输出隐藏 FP 反馈延迟，不能改变同一输出的舍入和结合顺序。同步 RAM 端口数量必须与实际每拍读写匹配，禁止用宽异步多读数组替代上述 RAM 容量。
- Attention 分 head/query 小块处理，score/exp/prob 尽量在局部 RAM 复用，QKV/context 与必要 spill 用 HBM。保留完整 max→exp→求和→除法顺序，不能为减少流量改为不同数值的在线 Softmax。
- Wi 的两半按 GEGLU 消费关系安排布局；优先让一个可配对小块完成激活/量化后生成 Down 输入。不能保存就明确写 HBM 一次、读一次并计费，不建立整个 Wi 的多端口寄存器池。

### 9.4 带宽与计算量必须一起核算

逻辑端口容量上界为 `端口数 × 字节/beat × 接口频率`，不含空拍、仲裁或宽度转换损失。例如 4×512-bit@100 MHz 为 25.6 GB/s；8×512-bit@200 MHz 为 102.4 GB/s。这些是算式示例，不是本版已确定的时钟、实测吞吐或保证值。实际设计要分别记录接口时钟与计算时钟及跨域成本。

原 120 个主干矩阵共有 47,143,976,960 MAC；Q8 权重有效载荷 391,331,840 B。在每权重只读一次的理想 M128 复用下，单计权重的计算强度约 120.47 MAC/B。持续消费 100 GB/s 的这种有效权重流就需要约 12.05 TMAC/s 的整数服务率，另外还需严格恢复/PS运算；全卡标称 460 GB/s 不能直接转成整模型速度。

每 group32/output 的严格恢复至少需要原 scale 乘积、乘 dot 和 PS 加法服务（可复用相同 scale 产品时需证明等价）。设有 C 个 INT8 MAC lane、运行频率 f，则理想 group-output 产生率为 C×f/32；必须将 scale/恢复/PS 的实际吞吐纳入有效计算率，不能只扩大 INT8 阵列。先前 256 lane@100 MHz 仅为 25.6 GMAC/s 的整数上界，最终算力规模不能用该调通值代表充分利用 U55C 的方案。

对每个真实 tile 分别计算并测量：`加载时间=实际字节/有效带宽`、计算/恢复时间、写回时间、首尾开销。具备双缓冲与独立端口并经事件证明的稳态关键路径才可近似取三者最大值。先减少重复流量和端口冲突，再按真实计算瓶颈扩展通路；不为提高带宽读数故意放弃有益复用。

### 9.5 验证项

1. 对真实权重打包、shape、bank 映射和逐字节解包做身份/布局验证；布局变化不改变模型权重或独立参考。
2. 在 RTL AXI peer 中验证并发在途、有限返回缓冲、延迟/反压、4 KiB 边界、双槽交接及连续请求；这只能证明协议和给定延迟模型下的能力。
3. 合成并链接包含真实平台互连、FIFO/RAM、整数与恢复/SFU 的设计，获取资源、布局布线和各时钟域时序。先做代表性整块，不凭裸端口/小乘法器报告外推全核。
4. 运行时按端口记录有效/总字节、事务数、LOAD/compute/drain 时间，分开记录缺数、输出阻塞、恢复/非线性等待及重叠。带宽测量必须包括真实 pack、bank 和混合读写模式。
5. 无板阶段将持续 HBM 带宽、PCIe 带宽、板上停顿率与整网延迟记为 NOT_RUN，交付可直接执行的测量程序。取得板卡后先测通路，再测相同 build 的完整两段和 30 层请求；不预报“已达 100/460 GB/s”。
