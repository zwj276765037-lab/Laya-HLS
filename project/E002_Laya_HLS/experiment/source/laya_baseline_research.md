# Laya-baseline 搭建规划：参考两个 Llama HLS baseline，在 U55C 部署 Laya

日期：2026-10-05。目标板卡：**U55C，用户已确认**。本文是实现规划；已完成架构与接口设计、源码核查，以及容量、计算量、访存流量和性能的理论估算，尚未创建或运行 Laya HLS 加速器。第 11.3 节的 FPGA 性能数字来自明确的实现假设，不是综合报告或上板测量；GPU 对照为实测。

GPU 对照现已补测：用户的两题中文请求在 RTX A6000、普通 SDK BF16 AMP、预热后完整调用 P50 为 **25.05 ms**，单独部门选择为 **24.20 ms**。因此这次部署加速以**完整两题请求约 25 ms** 为对照。第 11.3.10 节反推所需算力、端口、缓存和资源，当前功能方案尚无快于该 GPU 对照的证据。详见 [GPU 实测报告][gpu-benchmark]；本文的 FPGA 条件估算与该实测区分记录。

前置研究：[两个 Llama baseline 的源码研究][llama-research]。本规划使用其中的三核组织、Vitis HLS 构建、AXI 接口、XRT 控制和 HBM 部署方式，并按 Laya 的实际模型重新定义计算核。

## 1. 推荐方案与首版范围

首版采用 **Python 输入/输出前端 + C++ XRT runtime + 三个 HLS 核**：

```text
CPU：验证 state/questions，复用 Laya tokenizer 与序列构造
  → FPGA 核 1：整段 token embedding + embedding LayerNorm
  → FPGA 核 2：28 层 ModernBERT + final LayerNorm
  → FPGA 核 3：类型 embedding + 2 层决策 Transformer
               + marker scorer + act head
  → CPU：问题温度、概率、choice/score/noul、confidence、JSON
```

一次硬件执行处理一组完整问题序列，启动三核后统一等待。首版 microbatch 为一行问题，含多个问题的请求由 host 分行执行并合并答案；未来再增加硬件 batch。模型权重在初始化时上传并驻留 HBM，后续请求复用设备会话和 buffer。

数值实现采用两步：先建立 **FP32 C++ 功能参考**，核对完整计算图；首个目标硬件版本使用 **Group32 W8A8 线性计算 + FP32 层间状态及非线性**。量化优先对齐本地现有 `all_w8a8` 参考：对称 S8 权重、非对称 U8 activation、FP32 group scale，含 zero-point 校正。[已有量化实现][quant-reference]

首版完成的定义是：同一个合法请求能通过完整 FPGA 网络返回候选 logits 和 act logits，经 CPU 得到 SDK 对应的结构化结果；数值、质量和性能分别有可复查的报告。FPGA 完整功能通过后，才依据测量选择加速优化。

### 1.1 首版配置提案

以下上限是工程配置，不能混同为模型原生能力；统一写入 manifest，并由同一个描述生成两端常量。

| 项目 | 首版设定 | 后续扩展方式 |
| --- | --- | --- |
| 模型 | 本地英文 Laya 检查点 | 其他变体使用新的模型 ID、权重与回归结果 |
| 平台 | `xilinx_u55c_gen3x16_xdma_3_202210_1`，作为参考平台 ID | 在部署机核查实际 U55C shell/platform，并生成匹配配置 |
| 工具链 | 以参考工程 Vitis/Vivado 2023.2 + 匹配 XRT 为起点 | 记录实际版本，验证兼容后冻结 |
| 主干 | D=1024，28 层，16 heads，head_dim=64 | 架构变化需要重建硬件 |
| 主干 FFN | intermediate=2624；Wi 输出 5248 | 由实际权重 shape 校验 |
| 决策网络 | 2 层标准 Transformer，FFN=4096，scorer、act head | 原有网络完整保留 |
| `S_MAX` | 512 | 支持更长输入时重新评估容量、循环上限与性能 |
| `B_MAX` | 1 个问题行 | 调度更多 microbatch；后续评估 B=2/4 的硬件版本 |
| `K_MAX` | 32 个候选槽位 | 更大的候选上限需要更新构建契约；不静默丢弃选项 |
| group size | 32 | GS64 可以作为独立对照，但不能沿用 Group32 精度结论 |
| 层间 activation | FP32 | FP16/BF16 或定点状态作为后续数值变体 |
| 线性层 | W8 / A8 / INT32 组内累加 / FP32 缩放与 bias | 以真实吞吐和误差决定优化 |
| 初始 HLS 请求频率 | 150 MHz 的保守构建起点 | 综合和实现后再评估更高频率；不是已达到的时钟 |

`head_max_len=192` 是 SDK 的序列构造预算。决策 Transformer 仍处理完整 `[B,S,1024]`，不能将其硬件长度直接设为 192。

### 1.2 继承哪些 Llama 设计

| Llama 设计 | Laya-baseline 的对应实现 |
| --- | --- |
| embedding → 全部层 → classifier 三核 | embedding/norm → encoder → decision network 三核 |
| 核间 AXI Stream | 传输完整序列的隐藏向量，包含帧边界；层内大矩阵使用 HBM workspace |
| HBM 权重与状态 | 紧凑、分区域、单份驻留的权重；activation/QKV/FFN 临时区 |
| XRT device/kernel/BO/run | 常驻会话、预分配 BO、每 microbatch 一次启动链路 |
| 分组 int8 点积与浮点恢复 | Group32 整数核心；增加 Laya A8 的 zero-point 校正和 bias |
| C 仿真 → 综合 → 仿真 → 实现 → 上板 | 各阶段增加独立数值参考、接口验证和验收记录 |

Laya 需要另外实现 LayerNorm、双向 full/sliding attention、实际 RoPE 布局、GEGLU、标准决策层及 marker 输出。Llama 的 decoder、跨 token KV cache、词表分类和采样循环不进入本方案。

## 2. 模型身份、计算图与语义约束

### 2.1 冻结研究对象

| 项目 | 本次核查值 |
| --- | --- |
| 检查点目录 | `/home/user/EDA-202/zhuowenjun/Laya/model/english` |
| `model.safetensors` 大小 | 842,609,210 字节 |
| 权重 SHA-256 | `891102d372688fc2a094dac56a384bc537b87c63f21f9f3dac0be2b7cbc8d86c` |
| 张量目录 | 206 个张量，421,293,830 个元素，包含 buffer |
| 当前 SDK | Laya 0.3.20 |
| 当前框架 | Transformers 5.17.0，PyTorch 2.9.1+cu128 |
| encoder config SHA-256 | `bf3ab80598fdccf414855a2ce80f22859e4492d06ca8a62ddd1cfb63972f8979` |
| Agent config SHA-256 | `ae287b56bbcf5f8c4f4541ae9dfd00c914c4c48b940b8398c3058af37ba92bbd` |

上述 hash 在本轮重新读取本地文件计算。实现阶段还需固定 tokenizer 的全部文件、SDK/框架源码及构建脚本 hash。[模型配置][encoder-config]、[Agent 配置][agent-config]

同结构换权重可以使用同一硬件布局，但要重新导出并验证；英文版与 typed-decisions 版的准确率不能混为一个 baseline 的结果。

### 2.2 编码器每层的功能合同

```text
E = token_embedding(input_ids)
X = LayerNorm_embedding(E)

for layer in 0..27:
    A = X                         # 第 0 层 attention 前为 Identity
        或 LayerNorm_attn(X)     # 其他层
    Q, K, V = split(Wqkv(A))
    Q, K = RoPE(Q, K, 本层类型对应的 theta)
    Z = Attention(Q, K, V, padding mask, full/sliding mask)
    X = X + Wo(Z)
    N = LayerNorm_mlp(X)
    U, G = split(Wi(N))           # 各 2624 维
    X = X + Wmlp_out(GELU(U) * G)

H = LayerNorm_final(X)
```

- 全注意力层为 0、3、6、…、27，共 10 层；其余 18 层为局部双向注意力。
- 当前 SDPA 路径的局部 mask 使用 `abs(query_pos-key_pos) <= 64`，并屏蔽 padding key。中间位置最多有 **129 个**候选 key；配置字段 `local_attention=128` 不能直接写成“只看过去 128 个 token”。边界行为要以当前 mask 源码与黄金矩阵为准。[窗口定义][mask-definition]、[半窗口配置][window-config]
- full/sliding 的 RoPE theta 分别为 160000 / 10000；64 维 head 按 half-split `(0,32)、(1,33)…` 配对。[RoPE][rope-source]
- attention scaling 为 `1/sqrt(64)=1/8`。
- 推理使用 eval 模式，dropout 关闭；padding 位置的隐藏向量不应被假定始终为零。
- 保留主干 embedding norm、第 0 层 Identity、每层独立参数和 final norm。

### 2.3 决策网络的功能合同

```text
H = H + type_embedding(qtype)
H = decision_transformer_0(H, padding mask)
H = decision_transformer_1(H, padding mask)
M = gather(H, marker_pos)
raw_logits = scorer(M)
invalid marker logits = -10000

p_raw = softmax(raw_logits)        # 供 act head 使用，尚未应用问题温度
features = [top1, top1-top2, normalized_entropy, clamp(K_valid,min=2)/255]
act_logits = act_head(concat(H[:,0,:], features))
```

两层决策 Transformer 是 pre-norm、普通 ReLU FFN、带实际 bias 的标准层，不加主干 RoPE。scorer 为 LayerNorm → Linear → GELU → Linear，act head 为 Linear → GELU → Linear。[DecisionModel][decision-source]

act head 的统计量必须来自**未经过问题温度缩放的原始分布**。CPU 对最终候选概率施加温度，不能把这一步移动到 act features 之前。

`K_valid` 是有效候选数，但 act 的 softmax 必须按 SDK 当前 batch 的实际候选张量列数 `K_pad` 执行；无效列保留 `-10000` 的语义。硬件静态容量 `K_MAX` 后的额外填充列不参与这个 softmax。单候选时第二个 top 值使用 0；这与 SDK 的特殊分支一致。

### 2.4 CPU 最终结果语义

CPU 沿用 SDK 的温度桶和 clamp 规则，对有效候选计算 `softmax(raw_logits/T)`；act 输出按 SDK 做独立 softmax。

| 类型 | 主答案 | 需要保留的其他字段 |
| --- | --- | --- |
| choice | 最大概率的原始候选名称 | 各候选概率、confidence、answer_confidence、action |
| score | `sum(level_index * probability)` | 原始等级说明与概率；不能改为单纯 argmax |
| noul | 第二个候选即 `P(true)`，顺序为 false/true | confidence 为 max(P(true),P(false)) |

`answer_confidence=max(p)`；choice/score 的 `confidence` 是分布熵的函数，两者不能互换。四位小数只在最终 API 输出时处理；验收保存未舍入 logits/probabilities。[SDK 后处理][decode-source]

## 3. CPU 软件架构与请求执行

### 3.1 软件分工

| 模块 | 职责 | 主要产物/接口 |
| --- | --- | --- |
| Python frontend | 问题验证、序列化、tokenizer、build_sequence、padding、marker/qtype、后处理 | 请求张量与结构化答案 |
| offline exporter | 原始 safetensors → 量化/浮点权重区与 manifest | 可验证的模型包 |
| C++ XRT runtime | 加载唯一 xclbin、核句柄、BO 分配、权重同步、启动等待、输出读取 | `open_session / infer / close_session` |
| replay CLI | 接收已有请求张量，执行同一 runtime | 脱离 tokenizer 的系统功能回放 |
| validation/benchmark | 黄金结果比较、质量评估、延迟/吞吐/资源记录 | `results/<run_id>/` |

在线 Python frontend 只需 tokenizer、配置和后处理，不要求为准备输入再加载整个 PyTorch 模型。黄金参考程序单独加载原模型。

首版可通过 Python/C++ 的内存接口封装 XRT runtime；文件回放用于测试。性能测量使用常驻进程和内存传参，避免把每个请求的磁盘落盘、进程创建或权重重载当成推理过程。

### 3.2 请求接口合同

| 字段 | 逻辑形状 / 类型 | 规则 |
| --- | --- | --- |
| `input_ids` | `[B,S]` / int32 | tokenizer ID 原样保留，检查合法词表范围 |
| `attention_mask` | `[B,S]` / uint8 | 1=真实 token，0=padding；禁止无有效 token 的问题行 |
| `marker_pos` | `[B,K_pad]` / int32 | 有效位置必须 `<S`，与对应 `[MASK]` 的位置一致 |
| `marker_mask` | `[B,K_pad]` / uint8 | 候选有效性，不与 token padding mask 混用 |
| `qtype` | `[B]` / uint8 | choice=0、score=1、noul=2 |
| request metadata | 版本、request ID、B、S、K_pad、stride | 与运行时和 bitstream 的契约版本一致 |
| 输出 candidate logits | `[B,K_pad]` / FP32 | 保留有效/无效候选槽位 |
| 输出 act logits | `[B,2]` / FP32 | 与当前两个动作输出匹配 |
| 输出 status | 版本、request ID、完成状态、错误码 | 非成功状态不得返回正常答案 |

FPGA 上没有逐 token `pos` 参数或生成长度；序列位置由 `0..S-1` 生成，用于 RoPE 和窗口 mask。

### 3.3 首版多问题调度

frontend 先按 SDK 相同规则形成完整请求的 batch，记录原始问题顺序、`S` 和 `K_pad`；再拆成 `B_MAX=1` 的 microbatch。首版保留原 batch 的 padding 尺寸和候选列语义，避免改变 act features 的输入。返回后按原 question ID 合并。

- 空问题集在 CPU 直接返回，无需启动 FPGA。
- 字符串/对象 state 与对话列表使用 SDK 各自的截断方向。
- 超过硬件上限的张量显式报“当前构建不支持”，不在硬件适配层额外截断或删候选。
- 软件回退如后续需要，应显式标注 backend，并在性能/质量报告中单独统计。

未来长度分桶、batch 或候选列压缩均作为调度变更，重新核对有效输出及 act 分支，不能仅凭 padding 理论忽略数值差异。

### 3.4 XRT 运行顺序

初始化：检查 platform 与模型/ABI → 只加载一次 xclbin → 校验三个核及端口 → 分配各区 BO → 直接将对应 payload 写入 BO → 上传权重 → 保留 device、kernels、runs、buffers。

每次执行：校验完整请求 → 写入并同步小输入 → 更新三个核的参数 → 启动下游、中游、上游，**在三核都启动前不 wait** → 带超时等待全部核 → 读取 status → 同步小输出 → CPU 后处理。

首版设备会话串行执行 microbatch，workspace 同一时间只属于一个执行实例。并发请求由队列调度；扩展多实例时必须独立 workspace、状态与 stream，不能共享可写 buffer。

host 使用 RAII 管理 BO 与容器；logits、输入和 workspace 复用。参数编号由统一接口描述生成并与 xclbin 元数据校验，避免 Tiny 的两端配置不一致和手写端口编号漂移。

## 4. 三个 HLS 核的具体规划

### 4.1 核 1：`laya_embed_norm`

输入：请求 ID/形状、token IDs、token embedding 的 W8/scale、embedding norm 的 FP32 参数。

按 token 读取一行量化 embedding，恢复为 FP32，执行 embedding LayerNorm，然后按固定顺序输出 `[B,S,1024]`。局部缓存只需一行或几个 token tile；整张词表留在 HBM。

### 4.2 核 2：`laya_encoder`

输入：embedding 流、encoder attention/FFN 权重区、norm/位置常量、mask 和 workspace。

先接收完整序列并分块写入外部 activation workspace，然后以层循环复用硬件引擎，完成第 2 节的 28 层主干及 final norm。输出最终隐藏矩阵流。每层权重不同，但硬件引擎复用；不会为 28 层各建立一整套计算阵列。

内部模块：

- 分块量化 GEMM：QKV、attention output、MLP Wi/Wo 共用可配置线性引擎。
- FP32 attention：读取当前层完整序列 K/V；full 和 sliding 使用相同数学接口、不同合法 key 范围。
- LayerNorm、GEGLU、残差、RoPE：共享基础算子并保持实际顺序。
- 外部 workspace：activation ping/pong、norm/residual、QKV、FFN 中间区。

这里的 K/V 是**当前层、当前请求的中间张量**，算完可复用内存，不是跨请求或跨生成步的 decoder cache。

### 4.3 核 3：`laya_decision`

输入：encoder 输出流、qtype、marker/mask、决策网络权重与 workspace。

接收序列 → 加 type embedding → 运行两层完整决策 Transformer → gather marker → scorer → 生成 raw logits → 计算 act 所需统计量 → act MLP → 写小输出和状态。

scorer 只处理候选向量，但两层决策 Transformer 仍处理整条序列。仅把 encoder 输出中的 marker 提前摘出交给决策 Transformer，会改变模型。

### 4.4 stream 协议与容量

建议以 512-bit beat 打包 16 个 FP32 元素，tile 内按 `batch → token → feature` 顺序传输。定义 `keep/last` 或等价的明确帧长、ABI 版本和 request ID；以 `B*S*D` 校验元素总数。

FIFO 深度先作为可配置的小缓冲，取 32/64 beats 做仿真起点；实际深度由 producer/consumer 行为及拥塞结果决定。大序列矩阵落 HBM，不将整个 `[B,S,D]` 当作片内 FIFO。

首版不承诺三段计算充分重叠：encoder 和 decision 的 attention 都需要当前层的完整序列。采用三核是为了清晰的模块边界和系统复用；时序/吞吐收益必须测量。

错误/中止要有全链路完成协议：上游异常不能让下游永久等待正常帧。先由 host 拒绝非法请求，device 侧再传播错误状态/错误帧；超时恢复后重新建立有效会话，不继续读取旧 logits。

## 5. 量化与计算算子的实现合同

### 5.1 为什么首版选 Group32

Llama baseline 提供的是 GS64、S8 activation 和 FP32 scale 的实现。Laya 本地已有 Group32 W8A8、完整 Linear/Embedding 的 QDQ 对照，以及整数 ScaleCode 实验；选 Group32 可以复用真实模块映射、padding 和数值检查。[现有完整量化范围][quant-scope]、[整数实验][integer-evidence]

本次推荐的硬件 baseline 对齐 `all_w8a8` 的普通浮点 scale 规则；整数 ScaleCode 是后续独立变体。已有 ScaleCode 的精度结果不是本硬件实现的签核，已有 QDQ 程序耗时也不是 FPGA 性能。

首版量化覆盖 124 个 Linear 和 2 个 Embedding。LayerNorm affine/bias、其余一维参数、QK/AV、RoPE、非线性、残差及最终概率保留 FP32；Embedding 只有 W8 查表恢复，没有 A8 点积。

### 5.2 W8 / A8 的编码规则

沿每个输出行的输入维度，连续 32 个元素为一组。原始 F16 检查点转换为 FP32 后生成量化码，不从 GGUF 反量化后再次量化，也不在首版 exporter 中混入 LayerNorm folding。

```text
权重组：
    s_w = max(abs(w)) / 127
    q_w = clip(RNE(w / s_w), -127, 127)       # s_w=0 时 q_w=0
    sum_w = sum(q_w)                         # 导出为 int16

activation 组：
    low  = min(min(x), 0)
    high = max(max(x), 0)
    s_a = (high-low) / 255
    zp = clip(RNE(-low / s_a), 0, 255)
    q_a = clip(RNE(x / s_a + zp), 0, 255)     # s_a=0 的全零组规范为零
```

RNE 是 round-to-nearest / ties-to-even。不能直接使用 C/C++ `roundf` 的半值远离零规则替代；编码器要有独立边界用例。NaN/Inf、非法 metadata、非零组 scale 下溢及地址越界要计数并拒绝，不能静默产生成功结果。

### 5.3 线性引擎的整数核心

```text
a_s8 = int(q_a) - 128                          # 范围 [-128,127]
dot = Σ a_s8 * q_w                             # INT32
corr = dot + (128-zp) * sum_w                  # INT32 zero-point 校正
contribution = FP32(corr) * s_a * s_w
output[row] = Σgroup contribution + FP32 bias
```

`corr` 精确对应 `Σ(q_a-zp)*q_w`。不能将 `q_a-zp` 直接截为 int8，因为合法范围为 `[-255,255]`。Group32 的校正点积绝对界为 `32*255*127=1,036,320`，INT32 有充分余量；`sum_w` 的绝对界为 4064，可用 int16 存储。

FP32 跨组累加仍有顺序/FMA 差异；独立整数参考明确分组顺序和恢复过程，用于判断 HLS 是否正确执行本合同，再与 QDQ 和原模型比较。

### 5.4 非整除维度与 tile 尾部

act 首层原始输入为 1028，补零到 **1056**（33 组）。输入和权重同步补零，仅影响该 Linear 的物理计算宽度；保留原始输出 shape，不将额外通道引入 LayerNorm 或统计特征。

GEMM 的 token/output tile 尾部也需要有效 lane mask。scorer 最后一层只有 1 个输出、act 最后一层只有 2 个输出，不能用“不足一个 tile”作为漏算或输出额外类别的理由。

### 5.5 算子逐项实现策略

| 算子 | 首版实现 | 必须核查的细节 |
| --- | --- | --- |
| LayerNorm | FP32 求均值、方差、逆平方根与 affine | epsilon、bias 开关、归约误差、第 0 层 Identity |
| GELU / GEGLU | 对齐当前 exact GELU，再 gate 乘法 | HLS 的 erf 支持/代价；采用近似时作为单独数值变更验证 |
| 决策 FFN | FP32 ReLU + 量化 Linear | 不混用主干 GEGLU；保留 bias |
| RoPE | 离线生成两套 FP32 sin/cos 常量表 | half-split、theta、位置长度、表 hash；decision 不加 RoPE |
| Softmax | FP32 稳定 max-subtract、exp、sum、归一化 | 全部参与的 mask、无有效 key、K_pad 与 K_valid 区别 |
| Residual/type add | FP32 同形状逐元素相加 | 不做拼接、不丢原 residual、不错误广播 |
| marker gather | 严格按有效位置取向量 | 原候选顺序、无效槽位、单候选 |
| act features | 与第 2.3 节完全一致 | 未温度缩放的 p、top2、entropy、clamped K |

LayerNorm 明确采用总体方差：`mu=sum(x)/D`、`var=sum((x-mu)^2)/D`、`y=(x-mu)/sqrt(var+eps)*gamma+beta`；不使用 D-1 校正。D 为该算子的原始特征宽度，是否存在 beta 由实际参数决定。GELU 的 exact/approximate 模式、norm epsilon 和 affine 设置进入 manifest。

### 5.6 现有 `Laya/model/quantized` 的 Q8_0 能否作为部署对象

**可以作为 U55C 部署的权重来源；完整模型部署与追上 A6000 的约 25 ms 是两个验收目标。** 16 GB HBM 能容纳本地约 0.45 GB 的 Q8_0 文件，计算可使用共享引擎逐层执行，不需要为 28 个主干层各实例化一套阵列。较小阵列可以作为功能原型，代价是更长延迟；第 11.3.10 节约两万个 int8 MAC lanes 是特定 25 ms 预算下的必要吞吐规模。

本地实际下载的是两份 Q8_0，尚无 Q4：

| 模型 | GGUF 文件字节数 | 现有 typed-decisions 测试，400 案例 / 2,000 决策 |
| --- | ---: | --- |
| 通用英文 Laya | 451,505,440（约 430.59 MiB） | Q8_0 35.65%，同源浮点 36.15% |
| Laya Typed-Decisions 微调版 | 455,179,648（约 434.09 MiB） | Q8_0 76.85%，同源浮点 76.60%；答案一致率 98.55% |

文件清单见 [英文 inventory][gguf-general-inventory]、[微调版 inventory][gguf-typed-inventory]，质量与计时边界见 [既有 FP/GGUF 评测][gguf-accuracy]。这支持 Q8_0 在该测试集上保留来源模型的质量；微调版是另一个 checkpoint/config，不自动继承当前英文模型的中文两题结果或约 25 ms GPU 对照。其适用性按部署任务重新验证。

两份 GGUF 都有 124 个 Q8_0 张量、28 个 F32 张量和 1 个 F16 张量。Q8_0 每 32 个权重为 **32 字节整数 + 2 字节 FP16 scale**。其中 124 个 Q8_0 张量包含两个 Embedding；124 个 Linear 中实际为 122 个 Q8_0，scorer 最后一个 Linear 保持 F32，1028 维输入的 act 首层保持 F16。主要中间激活在图中声明为 F32，不能由权重格式推出全网络 INT8。[已有格式研究][gguf-research]

**此前阵列估算已经使用 W8A8 Linear。** 当前规划载荷采用每组 38 bytes（W8 + FP32 scale + sum_w），GGUF Q8_0 为 34 bytes；从已有 inventory 求得全部 Linear 的实际权重载荷为 **392,976,928 bytes**，较规划的 438,938,912 bytes 低约 **10.47%**。一遍这些权重在 16 ms 内读取约需 **24.56 GB/s**。这是权重载荷的比较，未计额外 FPGA metadata；层数、隐藏维和主体矩阵 MAC 没有相应缩小，不能按文件压缩比例缩小所需 PE 数。

直接使用 GGUF 需要一条独立导出/数值路径：

1. 离线提取权重整数码、FP16 group scale、浮点例外、配置和图信息，重排为 HBM/tile 布局；GGUF 文件本身不是 FPGA 可执行程序，仍需 HLS 核与 XRT runtime。
2. 明确动态激活量化、分组恢复和跨组累加合同。若复现通用 Q8_0 点积，仍有浮点 group scale 恢复；若改成当前非对称 A8，需要另外生成/校验 sum_w 等 metadata，并重新评测数值。
3. 对齐 GGUF 编译时的 LayerNorm affine 合并及 bias，不能将已合并的权重套入未经适配的原始图，重复应用缩放/偏置。保留或独立验证 scorer/act 的浮点例外。
4. 建立对应 GGUF 路径的输入/logits golden，再签核 FPGA 输出；已有软件评测不能替代这份硬件合同。

建议先用 **64×64 或 64×128 的共享 INT8 阵列作为待综合的原型配置**，完成量化模型功能部署与实测，再决定加速规模。这些尺寸是每 PE 每周期一条 MAC 的等效并行配置，尚未证明总资源、II 或时序可行。原始浮点模型留在软件侧作为数值和质量参考。

如果要求低于 25 ms，还需优先评估整数 ScaleCode 恢复、低精度 attention/状态、B=2 权重复用、K/V 缓存与融合。已有 [整数 ScaleCode 实验][integer-evidence]提供质量和溢出验证起点，但其 S48/S56 乘法、移位和累加仍需资源评估；进一步 W4A8 则需要新的模型/量化质量证据，当前本地没有现成全 W4 模型。仅换成现有 Q8_0 文件，尚不足以证明能追上 A6000。

## 6. 计算引擎、访存与资源策略

### 6.1 GEMM 比逐 token GEMV 更适合 Laya

将线性输入视为 `[B*S, D_in]`，权重为 PyTorch 顺序 `[D_out,D_in]`；执行 `X * W^T`。一个权重块用于多行 token，复用其 q、scale 和 sum_w。

建议功能版先使用清楚的循环实现建立参考；目标硬件版本采用三个可独立配置的 tile 尺寸：`T_M`（token 行）、`T_N`（输出通道）、`T_K`（输入维度）。`T_K` 取 Group32 的整数倍，先以 `T_M=16、T_N=16、T_K=32` 作为仿真布局起点；**tile 大小不等于三个维度全部 unroll**。

分别设置 token 并行度、输出 PE 数和组内乘法 lanes，根据综合报告选择。采用权重/activation 双缓冲，连续 burst，局部数组 partition，有限 DATAFLOW；检查实际 II、读写端口冲突和 DSP/LUT 映射。禁止把源代码 pragma 的目标当成吞吐结果。

`T_M=16` 的直接 token 外循环实现可能在 S=512 时重复读取序列 Linear 权重 32 遍；M3 同时核查循环顺序与权重缓存，参见第 11.3.5 节，不能只根据 tile 尺寸计算乘法并行度。

### 6.2 Attention 的首版与优化版

首版对每个 head、每个 query 行计算合法 key 的 score，用最多 `S_MAX` 个 FP32 分数的行缓存完成稳定 Softmax，再累计 V；Q/K/V 保留 HBM。一个 score 行 512 个 float，仅 2 KiB，避免一次常驻 16 个 head 的完整 `512×512` 矩阵。

full 层遍历所有合法 key；sliding 层直接枚举相应窗口，并处理序列两端和 padding。QK/AV 的 FP32 归约顺序与独立参考记录对应，真实质量通过后再扩展 query/key tiles 或 online Softmax。

逐 query 方案用于建立功能参考；若 K/V 每个 query 都从 HBM 重读，S=512 的 30 层仅 K/V 就约 34.90 GB。M3 应同时评估单 head 的 K/V 缓存（该长度下 256 KiB）与 query tile 复用，避免将参考循环的访存方式直接作为最终加速实现，详见第 11.3.6 节。

online/tiled Softmax 优化需维护每行累计最大值、归一化和 value accumulator，跨块重新缩放；不能各块独立 softmax 再拼接。

### 6.3 片上缓存与 HBM workspace

片上只放 GEMM tile、单个/少量 query、score 行、本地 norm 向量和控制 FIFO。完整 activation、QKV、较大的 FFN 状态放 HBM，按层复用。

主干 ping/pong、norm、residual 和 FFN 区域要有明确的生命周期图。保存 residual 后再覆盖 norm/input，不允许因 inplace 写入提前毁掉残差。encoder 的输出与 decision 接收可能在时间上重叠，不能提前复用仍在读取的 workspace。

### 6.4 三核资源检查与可控回退

三核会在 encoder 和 decision 核里各综合出一套线性/attention 引擎，资源不是只计算一份。M3 先做代表算子和分核综合，再检查总 DSP/LUT/BRAM/URAM 与实现余量。

若完整三核超出资源或跨 SLR 时序无法收敛，采用**embedding 核 + 合并 model-forward 核**的两核构建，复用 encoder/decision 的计算引擎。其神经网络、输入输出和验收合同保持相同，kernel 集合与 build ID 更新；两种构建的性能单独记录。这个分支由实际综合结果触发，不改小模型层数来冒充原 Laya 部署。

## 7. U55C 内存布局与容量估算

### 7.1 单份模型驻留

exporter 按 token embedding、encoder attention、encoder FFN、decision、aux 常量划分 payload。每个实际张量只保存一次；各核读取所需区域。共享只读的小参数如需跨核访问，应在同一可达 bank group 使用同一 BO，而非复制整个模型。

数据布局采用 q/scale/sum_w 分离区域（SoA）。逻辑权重顺序固定为 `[D_out,D_in]`；硬件 payload 可按 output tile / input group 重排连续存储，由 manifest 记录逻辑与物理 shape、stride、offset 和有效 lane。q、FP32 scale、int16 sum_w 都按各自宽度打包，传输建议 64 字节对齐，区域起点建议 4 KiB 对齐。

### 7.2 模型载荷的可复核估算

本轮读取原始 safetensors 张量目录得到：Linear 元素 369,625,600；两个 Embedding 元素 51,579,904；其他向量/buffer 元素 88,326。act 输入补零增加 7,168 个 Linear 权重元素。

普通 Group32 Linear 每个原始元素约占 `1 + 4/32 + 2/32 = 1.1875` 字节（S8、FP32 scale、int16 sum_w）；Embedding 没有 sum_w，约占 1.125 字节。

| 区域 | 估算载荷 |
| --- | ---: |
| encoder attention 线性权重 | 139,460,608 字节，133.00 MiB |
| encoder FFN 线性权重 | 268,025,856 字节，255.61 MiB |
| decision 全部 Linear，含 act padding | 31,452,448 字节，30.00 MiB |
| token/type Embedding，含 FP32 group scales | 58,027,392 字节，55.34 MiB |
| 其他向量/buffer，按 FP32 保留 | 353,304 字节，0.34 MiB |
| **合计** | **497,319,608 字节，474.28 MiB（0.4632 GiB）** |

这是规划载荷，包含 sum_w 和 act 输入补零，但不包含 output tile 尾部填充、对齐、manifest、RoPE 表及运行时保留空间。最终由实际导出 inventory 汇总，不以估算值替代文件和 BO 大小检查。

不生成整张 FP32 embedding 副本；按需恢复 token 行。以上模型单份驻留，不能乘以三个 kernel 数。

### 7.3 B=1、S=512 的 workspace 量级

| 张量 | FP32 大小 |
| --- | ---: |
| 一份 `[S,1024]` activation | 2 MiB |
| activation ping + pong | 4 MiB |
| 融合 QKV `[S,3072]` | 6 MiB |
| norm / residual 各一份 | 各 2 MiB |
| Wi 完整暂存 `[S,5248]`，若功能版采用 | 10.25 MiB |
| 门控结果 `[S,2624]` | 5.125 MiB |
| 单个 score 行 `[S]` | 2 KiB，可放片上 |
| 两种 theta 的完整 64 维 sin/cos 表 | 合计约 0.5 MiB，可在导出时压缩重复半区 |

首版以 **64 MiB 总 workspace 预算**为布局起点，再按实际生命周期和核间重叠分配。它是预算，不是已测峰值；exporter/runtime 自动验证分区不重叠、地址不溢出。增加 B_MAX 时重新生成容量表，不在已有 BO 中直接放大 batch。

### 7.4 建议的 HBM 与 SLR 起始连接

下面作为首个 U55C build 配置的候选，必须以实际 shell 的 bank/group 信息和分核综合结果确认。

| 区域 / 端口 | 建议连接 | 原因 |
| --- | --- | --- |
| token embedding | HBM[0] | 查表单独访问；type embedding 归 decision/aux 小区 |
| input / request metadata | HBM[1] | 小输入与控制数据 |
| norm、bias、RoPE 等 aux | HBM[2] | 只读共享常量，校验各核可达性 |
| encoder attention 权重 | HBM[4:5] | 独立权重读 master |
| encoder FFN 权重 | HBM[6:7] | 与 attention 数据分区 |
| decision 权重 | HBM[8] | 独立读区 |
| activation ping / pong | HBM[12] / HBM[13] | 两个独立 AXI bundle 以支持读写重叠 |
| 当前层 QKV 工作区 | HBM[14:15] | 连续矩阵临时状态 |
| FFN 工作区 | HBM[16:17] | 局部矩阵与门控中间区 |
| decision workspace | HBM[20:21] | 避免与尚在输出的 encoder workspace 发生写冲突 |
| logits / act / status | HBM[24] | 小结果统一读取 |

SLR 可先参照 Llama：embedding 与 decision 在 SLR1，encoder 在 SLR0；实现时根据资源和流跨区时序调整。不能在资源报告之前将此放置视为最终最优解。

不同的 workspace/权重读写路径显式使用独立 AXI bundle；绑定多个 bank 并不自动使带宽相加。记录生成端口宽度、burst 长度、outstanding、实际 HBM 事务和吞吐，确保 BO 的 `group_id` 与连接一致。

## 8. 导出包、统一配置与拟建目录

### 8.1 模型包必须包含什么

`manifest.json` 至少包含：schema/ABI 版本、model ID、原始权重/config/tokenizer hash、模型尺寸、层类型、RoPE/norm/activation 设置、group size、舍入规则、码域、scale/bias 类型、全部张量目录、分区字节数与校验和。

每个张量记录原始/补零/物理 shape、逻辑方向、q/scale/sum_w/bias offset、byte length、stride、padding、恢复方式。输出 matrix padding、1028→1056、embedding 与线性层区别均由 manifest 明示。

构建包另存 `build_manifest.json`：工具/platform/shell、源码 hash、目标时钟、kernel/端口名、HBM/SLR 连接、tile/PE、B/S/K 上限、实际 xclbin hash。软件启动前核对模型包与构建包的兼容字段。

### 8.2 推荐目录

已有 `source/`、`results/`、`vivado/` 保留。其余为**待创建的实施结构**；本轮只写本文。

```text
Laya-baseline/
  source/
    llama_baseline_research.md
    laya_baseline_research.md
  config/
    model_contract.json          # 一份真实架构定义
    numeric_contract.json        # 编码、舍入、bias、fp32 规则
    u55c_build.json              # 时钟、tile、端口、bank、SLR
  tools/
    export_checkpoint.py
    prepare_request.py
    capture_golden.py
    validate_results.py
    benchmark.py
  host/
    xrt_runtime.cpp
    request_validator.cpp
    replay_main.cpp
    python_binding.cpp
  hardware/
    include/model_config.hpp    # 由 contract 自动生成
    include/weights_layout.hpp
    include/request_abi.hpp
    src/linear.cpp
    src/attention.cpp
    src/norm_activation.cpp
    src/laya_kernels.cpp        # C 仿真、综合、仿真共用
    tb/tb_laya.cpp
  tests/
    numeric/                    # 独立整数与浮点算子 golden
    requests/                   # 带 hash 的输入/黄金结果
  artifacts/
    weights/<model_id>/<format>/
    requests/<fixture_id>/
  vivado/
    <build_id>/                 # HLS 配置、XO、实现、xclbin、报告
  results/
    <run_id>/                   # manifest、逐样本结果、质量、性能
  scripts/
    env.sh  csim.sh  csynth.sh
    software_emulation.sh  hardware_emulation.sh
    hardware_implement.sh  run_inference.sh
```

生成配置与编译产物放在唯一 build ID 中；结果按唯一 run ID 保存，已有结果不覆盖。C 仿真、software emulation 和 synthesis 都使用同一套 HLS 函数，避免复制维护 `independent_kernal` 引起漂移。

## 9. 实施阶段与进入下一阶段的条件

| 阶段 | 实际工作 | 可检查的交付物 | 完成门槛 |
| --- | --- | --- | --- |
| M0 模型/平台冻结 | 核查 U55C shell、工具、文件；固定请求与精度规则 | contract、环境清单、checkpoint/tokenizer/source hash | 架构、ABI、工具和输入限制均明确 |
| M1 输入/黄金模型 | 复用 SDK 序列构造；建立 FP32、QDQ、整数恢复参考 | 带输入 hash 的 fixtures 与 logits；矩阵清单 | 输入逐字节一致；模块覆盖完整；参考数值无异常 |
| M2 HLS 功能实现 | 基础算子 → 单层 full/sliding → 28 层 + decision | 单元比较、单层/完整 C 仿真报告 | 浮点图与整数核心分别通过第 10 节门槛 |
| M3 资源可行性 | 分核综合、代表算子调度、总资源与频率检查 | `.xo`、csynth 报告、资源汇总 | 全部核可综合；容量正确；整体有实现余量；必要时转两核 |
| M4 系统仿真 | 编译 XRT runtime，检查 metadata/stream/BO，运行 sw_emu；代表用例 hw_emu | 仿真日志、ABI 比较、输出、超时/错误路径 | 全链路完成；无死锁/越界/旧结果；数值通过 |
| M5 U55C 上板 | Vitis link/实现、加载、同 fixtures 推理、稳定循环 | xclbin + build manifest、板上功能/质量报告 | 时序达标；板上输出与对应参考通过；无 runtime 异常 |
| M6 性能基线 | 固定请求、预热、分段和端到端测量 | CPU/GPU/FPGA 对照、p50/p95、吞吐、资源/带宽 | 数据可复跑；口径一致；明确是否实现加速 |
| M7 优化迭代 | 针对瓶颈改 tile、PE、宽访存、batch、attention 或 scale | 每个变体独立 build/run ID 与回归报告 | 数值/质量保持，再报告性能提升 |

不为本计划指定未经评估的工期。先完成前一阶段的进入条件，再启动昂贵的完整实现；HLS 目标频率、sw_emu 成功和 README 图片都不能替代 M5 的证据。

首次执行的推荐顺序：输入合同/黄金结果 → 导出与整数 GEMM 小样例 → LayerNorm/RoPE/GEGLU → 单层 full/sliding → 决策层/scorer/act → 完整 C 仿真 → 分核综合。

## 10. 数值、功能和质量验收

### 10.1 三层参考，分清误差来源

| 参考 | 定义 | 主要用途 |
| --- | --- | --- |
| Gold-A | 原始 checkpoint 在 FP32/eval、关闭 AMP/TF32 的完整 Laya | 软件/HLS 浮点图等价性，量化质量来源 |
| Gold-B | 同 checkpoint 的 `all_w8a8` QDQ 与完整相同输入 | 量化码和数学近似对模型质量的影响 |
| Gold-C | 导出包中实际 q/scales/sum_w + 独立整数点积、FP32 恢复及完整网络 | 验证硬件执行的数值合同 |

Gold-C 的整数 dot/校正 golden 使用独立高精度或大整数实现，不复用 HLS 的同一函数。Gold-B 用 FP32 矩阵乘，而 Gold-C 按组恢复，归约顺序不同；二者输出差异单独记录。硬件正确性主要对 Gold-C，量化质量相对 Gold-A，不把两种差异混在一个误差阈值里。

### 10.2 覆盖集

算子级：RNE 正负半值、零组/常数组、U8/S8 边界、校正点积最坏界、bias、1028 padding、tile 尾部、NaN/Inf、Softmax 稳定性、LayerNorm epsilon、GELU、RoPE 两种 theta/配对。

模型级：短输入、S=127/128/129/512、±64 窗口边界、左右端点、变长 padding、多问题、choice/score/noul、单候选、无效 marker、最大合法候选数。非法 marker/token/ABI/尺寸和空问题集测试进入 host/系统层。

小 S 用例捕获所有层的关键输出，定位首次偏差；大 S 用例捕获选定 full/sliding 层和最终网络输出，控制黄金张量体积。有效/无效张量位置分开比较，不用大量 padding 掩盖误差。

### 10.3 建议的工程门槛

以下为**暂定验收门槛**，在 M1 的开发集上检查可行性并冻结；冻结后不依据最终 test 结果追调阈值。

| 验收项 | 建议门槛 |
| --- | --- |
| 输入 IDs、mask、marker、qtype、模型字节契约 | 逐字节一致，shape/offset/长度全部合法 |
| 量化码、RNE、sum_w、整数 dot/校正 | 独立 golden 完全一致；溢出/非法值为 0 |
| FP32 单算子/单层 | 有效元素 `abs(err) <= 1e-4 + 1e-4*abs(ref)` 为起点；困难算子单独记录与冻结 |
| 浮点完整图、HLS/板上对 Gold-C 的 logits | `abs(err) <= 1e-3 + 1e-3*abs(ref)` 为起点；保留逐层及最大误差 |
| 最终未舍入 candidate/act 概率 | 对对应数值参考最大绝对偏差 ≤ 1e-3 |
| 系统功能 | 所有 fixture 通过；异常状态不产生答案；无死锁/地址越界/旧输出 |
| 量化对 Gold-A 的任务质量 | accuracy 下降 ≤ 1 个百分点作为初始目标，并分类型检查 |
| 量化概率质量 | Brier 增量 ≤ 0.01、ECE 增量 ≤ 0.02、NLL 增量 ≤ 0.05 作为初始目标 |
| score 输出质量 | 以等级跨度归一化的 MAE 增量 ≤ 0.02 作为初始目标 |

接近候选平局的 argmax 翻转要逐条分析并记录 margin，即使概率误差很小也不能隐藏。除汇总指标外保留原始 logits、概率、动作概率与全部候选顺序；公共 JSON 的四位小数不作为数值比较依据。

复用既有 400 案例/2,000 决策可作回归集，但它已被历史实验观察，不能宣称新的独立泛化评估。质量目标最终应依据实际部署任务确定，并准备与开发选择隔离的评估数据。

## 11. 构建、上板与性能评测的具体要求

### 11.1 构建流程

沿用两个 Llama baseline 的阶段，但统一路径与错误检查：

1. `env.sh` 检查实际工具路径/version 和 U55C 状态，使用项目绝对路径或脚本所在目录，不依赖启动时 `$PWD`。
2. exporter 检查模型包，生成两端头文件、HLS top 配置、linker connectivity 和 runtime ABI。
3. C 仿真显式指定 testbench/top；三个分核都用共享源文件生成 `.xo`。
4. sw_emu 编译及链接同一三核系统；host 按唯一 `--xclbin` 选择加载。
5. hw_emu 用代表性测试检查 stream/backpressure；仿真速度不进入性能比较。
6. `v++ -l -t hw` 进行 U55C 实现，保存 timing/resource/utilization 与工具日志。
7. runtime 校验 build/model/ABI，板上执行相同 fixtures 后才做 benchmark。

所有脚本遇错停止，目录可重复构建到新的 build ID。完整实现产物包括 xclbin、源码/config hash 和实际实现报告，不只提交一个缺少来源的 bitstream。

### 11.2 每个请求记录哪些时间

| 指标 | 计时边界 |
| --- | --- |
| cold_start_ms | runtime 初始化、xclbin 加载、权重读取/上传，单独报告 |
| cpu_prepare_ms | state/questions → 完整请求张量 |
| h2d_ms | 本次输入传输及同步 |
| device_chain_ms | 三核提交到全部完成；说明是否含 launch 开销 |
| d2h_ms | 小输出同步与读取 |
| cpu_postprocess_ms | 温度、概率、类型答案及 JSON |
| request_e2e_ms | 原始请求进入到完整答案可用，含全部 microbatch |

API 推理、回放和 kernel 的时间分别标记；C 仿真/HLS 估计延迟不进入板上端到端 speedup。预热后测量足够多重复请求（首版建议 10 次预热、至少 100 次测量），报告样本数、p50/p95/均值及输入有效 token、padding token、问题数和候选数。

CPU、GPU、FPGA 使用相同 checkpoint、请求和质量口径，明确各自 FP32/BF16/量化模式、设备和线程数。主指标为请求延迟与请求/s，同时报告决策/s和有效输入 token/s；这里没有生成 token/s。

### 11.3 计算量、带宽需求与性能估算

本节依据本地 checkpoint 的张量 shape 和第 2 节计算图复算。计算量可以由模型结构确定；实际 HBM 流量取决于循环顺序和缓存；性能还取决于资源映射、II、时钟、端口带宽及主机开销。因此分开给出**结构确定值、实现条件下的流量、算力假设下的时间**。

#### 11.3.1 计量口径与分析边界

| 符号 / 项目 | 本节口径 |
| --- | --- |
| `B` | 一个硬件 microbatch 的问题行数，首版为 1；一个 API 请求可以有多行 |
| `S` | 实际执行的序列长度，包含保留的 padding；首版最大 512 |
| `K` | scorer 实际计算的候选槽位数；主算例取 32，长度对照取 4 |
| `D / I / F / H` | 隐藏维 1024 / 主干 FFN 2624 / 决策 FFN 4096 / 16 个 heads |
| `r` | 局部注意力半径 64，内部窗口最多 129 个 key |
| `1 MAC` | 一次乘法与累加，`1 GMAC = 10^9 MAC` |
| 等价运算数 | 按 `1 MAC = 2 operations` 换算；W8A8 的整数操作不能写成 FP32 FLOPs |
| 字节单位 | `GB = 10^9 bytes`；`MiB = 2^20 bytes`；`GiB = 2^30 bytes` |
| 计算精度 | Linear 为 W8A8/INT32 dot + FP32 分组恢复；QK/AV 和非线性为 FP32 |
| 频率 | 使用 150 MHz 作敏感性分析；并非 U55C 固定频率或已实现频率 |
| 输入假设 | 主算例的 S 个 token 均有效，推理 dropout 关闭，不包含训练反向传播 |

矩阵 MAC 不包括 bias、LayerNorm、RoPE、GELU、ReLU、Softmax、量化/恢复、残差、访存、启动及 CPU 开销。这些工作在后文单独分析，不能用矩阵 MAC 总数代表全部运算。

#### 11.3.2 逐模块矩阵计算量

对矩阵乘 `[S,D_in] × [D_in,D_out]`，MAC 为 `S*D_in*D_out`。主干每层线性层为 `4*S*D^2 + 3*S*D*I`；决策每层为 `4*S*D^2 + 2*S*D*F`。

局部注意力合法位置对数为：

```text
P_local(S) = Σ_i [min(S-1,i+64) - max(0,i-64) + 1]
           = S²                         当 S <= 65
           = 129*S - 64*65               当 S > 65

MAC_QK_AV = 2*D * [12*S² + 18*P_local(S)]
```

`12*S²` 来自 10 个主干全注意力层和 2 个决策全注意力层；一个合法位置对在所有 heads 上的 QK 和 AV 合计为 `2*H*64 = 2*D` MAC，不能再重复乘 16。

以下为 **B=1、S=512、K=32**，局部位置对数为 **61,888 / 层**：

| 模块 | MAC 公式 | GMAC |
| --- | --- | ---: |
| 主干 28 层 QKV + attention output Linear | `28*S*4*D²` | 60.129542 |
| 主干 28 层 GEGLU 的 Wi + Wo Linear | `28*S*3*D*I` | 115.561464 |
| 决策 2 层 QKV + attention output Linear | `2*S*4*D²` | 4.294967 |
| 决策 2 层 FFN Linear | `2*S*2*D*F` | 8.589935 |
| scorer 两个 Linear | `K*(D²+D)` | 0.033587 |
| act 两个 Linear，含 1028→1056 补零 | `1056*256 + 256*2` | 0.000271 |
| 主干 10 层 full QK + AV | `10*2*D*S²` | 5.368709 |
| 主干 18 层 sliding QK + AV | `18*2*D*P_local(S)` | 2.281439 |
| 决策 2 层 full QK + AV | `2*2*D*S²` | 1.073742 |
| **全部 Linear** | 上述 6 项 Linear 合计 | **188.609766** |
| **全部 FP32 QK + AV** | 上述 3 项 attention 合计 | **8.723890** |
| **矩阵运算总计** | `197,333,656,064 MAC` | **197.333656** |

等价矩阵运算数为 **394.667312 GOP**。主干 FFN 占总 MAC 的 **58.56%**，全部 Linear 占 **95.58%**，QK/AV 占 **4.42%**。这只是工作量比例；FP32 attention 与 int8 Linear 的有效吞吐不同，耗时比例不等于 MAC 比例。

如果 sliding 层仍执行完整 `S×S` 的 QK/AV、最后才应用 mask，则 QK/AV 增至 **16.106127 GMAC**，矩阵总量增至 **204.715893 GMAC**。实现第 6.2 节的合法窗口枚举，才能采用 8.723890 GMAC 的 attention 数字；软件 SDPA 对照的实际执行量须另行分析。

#### 11.3.3 长度、候选和多问题请求的影响

固定 **B=1、K=4**，所有 token 有效：

| S | Linear GMAC | QK/AV GMAC | 总 GMAC |
| ---: | ---: | ---: | ---: |
| 64 | 23.576458 | 0.251658 | 23.828116 |
| 94 | 34.625827 | 0.510812 | 35.136639 |
| 128 | 47.148446 | 0.857997 | 48.006444 |
| 256 | 94.292423 | 2.674655 | 96.967078 |
| 512 | 188.580377 | 8.723890 | 197.304267 |

Linear 随 S 近似线性增加；full attention 随 S² 增加；超过窗口长度后的 sliding attention 近似线性增加。S=64 时，局部窗口已覆盖整个序列，所以没有位置对数量的节省。

每增加一个 scorer 候选，仅增加 **1,049,600 MAC**。S=512 时从 K=3 增至 K=32，矩阵总量由 197.303218 增至 197.333656 GMAC，只增加约 **0.0154%**。但候选文本也会占用序列长度、改变 state 可用预算，实际请求不能只改变 K 而忽略 S 和输入内容。

首版对同一请求中的多道题逐行执行，工作量按各行求和。即使共享 state 文本，每行的问题/候选前缀不同，双向编码结果也不同，不能直接复用一个 state 的 encoder 输出。

已有 [张量 trace][laya-shapes] 的两道题执行形状为 `[2,94,1024]`、`K_pad=3`。按每行 94 个有效 token 和 3 个 scorer 槽位计，矩阵工作量上界约 **70.27 GMAC / 请求**；其中一行实际只有 72 个有效 token，跳过 padding key 时 attention 工作量更少。首版保留 S=94 的 padding，Linear 仍按每行 94 个位置计算。

对于真实 padding mask，应把 `S²` 替换为 `Σ_q Σ_k mask[k]`，把 `P_local` 替换为 `Σ_q Σ_k mask[k]*1(|q-k|<=64)`；这里仍计算全部 query 位置。若以后跳过 padding query 或按问题重新裁剪，需要重新验证输入和输出语义。

#### 11.3.4 Group32 恢复和非线性不能忽略

以下仍以 B=1、S=512、K=32 计：

| 工作 | 数量 | 性能含义 |
| --- | ---: | --- |
| Linear 输出的 Group32 dot / 校正 / 恢复 | **5,894,055,184 组** | 等于 Linear MAC / 32；每组均需整数校正和 FP32 scale 恢复 |
| A8 量化输入元素 | 89,064,736 | 计各 Linear 输入，不计跨输出通道重复量化；应缓存复用 |
| LayerNorm 处理元素 | 32,014,336 | `61*S*D + K*D`；主干 57 个 norm、决策 4 个 norm、scorer norm |
| GELU 元素 | 37,650,688 | `28*S*I + K*D + 256`，首版需 exact GELU |
| 决策 ReLU 元素 | 4,194,304 | `2*S*F` |
| RoPE 处理的 Q/K 特征 | 29,360,128 | `2*28*S*D`，不含决策层 |
| attention Softmax 的合法 score 元素 | 68,155,392 | `H*(12*S²+18*P_local)`，涉及 max、exp、sum、归一化 |

按第 5.3 节公式，一组恢复通常有两次 FP32 乘法和一次 FP32 累加，约 **17.68 G 次浮点基本运算**，另有整数 zero-point 校正。实际可经流水线/FMA 调整实现，但不能将这些恢复直接视为零成本。

若一条恢复流水线每周期能完成一组，150 MHz、65% 有效利用率下，单流水线处理 58.94 亿组需约 **60.45 s**；16 条需 **3.78 s**；64 条需 **0.945 s**。必须使 Group32 恢复的吞吐与整数 dot 阵列匹配，且解决 FP32 跨组累加的反馈依赖。

同样，若 exp 或 GELU 单元能做到 II=1，在 150 MHz、65% 利用率下，单单元处理上述 exp/GELU 分别约 **0.699 s / 0.386 s**，8 个并行单元分别约 **87.4 ms / 48.3 ms**。这些只是元素处理能力的示例，未包括其他归约；exact GELU 的 erf 和 exp 是否达到 II=1，必须由 HLS 报告确认。

#### 11.3.5 单次推理的权重流量

第 7.2 节的 **497.32 MB** 是整份驻留载荷，不是每次推理必定读取的字节数。完整 token embedding 表驻留 HBM，但每次只查所需的行。

Group32 Linear 每组 32 个 int8 权重、4 字节 scale、2 字节 sum_w，共 **38 bytes / 组**，即 **1.1875 bytes / 权重元素**。本轮从 124 个 Linear 的物理 shape 复算：

| 只读数据 | 字节数 |
| --- | ---: |
| 28 个 encoder 层 + 2 个 decision 层的全部 Linear（`W_seq`） | 437,370,880 |
| scorer 两个 Linear（`W_scorer`） | 1,246,400 |
| act 两个 Linear，含补零（`W_act`） | 321,632 |
| **全部 Linear** | **438,938,912** |

如果每个 Linear 权重在一行问题中只读取一遍，S=512 的 token embedding 无行缓存查表还需 `512*1024*1.125 = 589,824 bytes`，type embedding 查一行需 1,152 bytes；按全部 aux 参数读取一次计 353,304 bytes。总只读流量约为 **439,883,192 bytes = 0.439883 GB**。

但第 6.1 节的 token tile 不一定实现全序列权重复用。若采用“token tile 外循环，每个 tile 重读整个 Linear 权重”的直接实现：

```text
r_seq = ceil(S / T_M)
r_scorer = ceil(K / T_M)
D_weight = r_seq*W_seq + r_scorer*W_scorer + W_act
           + 1152*S + 1152 + 353304
```

S=512、K=32 时，`T_M=16` 对应 **13.999627 GB** 权重/常量流量；`T_M=64` 对应 **3.501479 GB**。权重只读一遍的 0.439883 GB 是强复用条件下的结果。

将权重块跨全部 token 复用，或缓存一个完整 Linear，可以降低读放大；代价可能是 activation 重读、部分和落 HBM 或更多片上缓存。最大的主干 Wi 量化权重含元数据约 **6.086 MiB**，可作为缓存可行性分析的尺度；整张板的 43 MB SRAM 分布在不同资源与物理区域，不能直接当作任意 kernel 都可使用的一块连续缓存。

只考虑权重，序列 Linear 的算术强度约为 `T_reuse/1.1875 MAC/byte`：复用 16 行约 **13.47 MAC/byte**，复用 512 行约 **431.16 MAC/byte**。增加复用有利于减轻带宽压力，收益须扣除额外 activation/部分和流量。

#### 11.3.6 Attention 与 FP32 workspace 流量

第 6.2 节逐 query 行计算时，如果 K/V 每次从 HBM 重新读取，一对合法 query/key 在所有 heads 上需读取 `K + V = 2*D*4 bytes`。因此：

```text
D_KV_row = 8*D * [12*S² + 18*P_local(S)]
```

S=512 时，**仅 K/V 重读就是 34.895561 GB**，不含 Q、attention 输出和其他 workspace 读写。这解释了为什么“模型载荷不到 0.5 GB”不能推导单次推理只有不到 0.5 GB 的访存。

如果 `T_Q` 个 query 共用一次 K/V 装载，对于一个局部 query tile `[a,b]`，要装载的 key 集合是 `[max(0,a-64), min(S-1,b+64)]`。令这些 key 并集长度在所有 query tiles 上的和为 `U_local(S,T_Q)`，则：

```text
D_KV_tile = 8*D * [12*S*ceil(S/T_Q) + 18*U_local(S,T_Q)]
```

S=512、T_Q=16 时 `U_local=4288`，K/V 流量约 **2.242904 GB**。如果完整缓存一个 head 的 K/V，并供本层所有 query 复用，则 30 层的 K/V 装载总量约 **0.125829 GB**。S=512 时单 head 的 FP32 K+V 缓存仅 **256 KiB**，这是值得优先验证的方案；并行 heads、读端口和 layout 转换仍会增加资源或流量。

为使 workspace 估算可复算，再定义一种**未融合的 FP32 访存调度**：每个子层的输入矩阵读一次、输出写一次，token 输入 tile 可跨输出通道复用；norm 向量与 score 行缓存在片上，A8 编码不落 HBM；RoPE、GEGLU/ReLU、残差各做独立 pass。令 `A=4*S*D`、`G=4*S*I`、`F_b=4*S*F`，均为字节数。

| 非 K/V 重读的 workspace 部分 | 流量表达式 | S=512 |
| --- | --- | ---: |
| 28 个 encoder 层 | 第 0 层 `22*A+6*G`，其余每层 `24*A+6*G`，合计 `670*A+168*G` | 2,201 MiB |
| 2 个 decision 层 | 每层 `20*A+4*F_b`，合计 `40*A+8*F_b` | 144 MiB |
| embedding 接收、final norm 读取、decision 接收、type add | `5*A` | 10 MiB |
| **合计 `D_pass`** | **`715*A+168*G+8*F_b`** | **2,355 MiB = 2.469396 GB** |

例如一个带 attention norm 的 encoder 层，其 A 项来自 norm 2A、QKV 4A、RoPE 4A、attention 的 Q 读/输出写 2A、Wo 2A、两次 residual 共 6A、MLP norm 2A，以及 Wi/Wo 的输入/输出各 A；G 项来自 Wi 写 2G、GEGLU 读写 3G、MLP Wo 读 G。K/V 已单列，不能再次加入这一表。

上述 **64 MiB workspace 容量预算**和这里的 **2,355 MiB 读写流量**可以同时成立：同一块 workspace 会被不同层反复读写。本表不包含 scorer 小矩阵流量、访存对齐浪费、输入重复读取、部分和溢出到 HBM 或未缓存参数的重复读取；算子融合可降低流量，实际调度也可能放大流量。

#### 11.3.7 HBM 带宽需求与接口限制

将前述假设组合，B=1、S=512、K=32 时得到四种分析场景；各场景均保留上表 **2.469396 GB** 的 FP32 passes，完整 K/V 缓存场景也保留 QKV 的 HBM 写入：

| 场景 | 权重/常量 GB | K/V GB | 总 HBM 流量 GB | 若要求 100 ms，所需总带宽 GB/s |
| --- | ---: | ---: | ---: | ---: |
| A：T_M=16；逐 query 重读 K/V | 13.999627 | 34.895561 | **51.364584** | **513.646** |
| B：T_M=16；T_Q=16 复用 K/V | 13.999627 | 2.242904 | **18.711927** | **187.119** |
| C：T_M=64；T_Q=16 复用 K/V | 3.501479 | 2.242904 | **8.213780** | **82.138** |
| D：权重读一遍；单 head 完整 K/V 缓存 | 0.439883 | 0.125829 | **3.035109** | **30.351** |

`所需带宽 = D_HBM / 目标时间`。例如 A 场景即便忽略计算，100 ms 也需要超过 U55C 标称 460 GB/s 的总带宽；换成 500 ms 所需带宽为 102.73 GB/s。D 场景在 100 ms 下的 30.35 GB/s 只是访存必要条件，并不代表计算能在 100 ms 完成。

假设所有 HBM 流量可均匀使用给定的**有效总带宽**，得到如下访存时间下界：

| 场景 | 150 GB/s 下界 ms | 300 GB/s 下界 ms | 460 GB/s 下界 ms |
| --- | ---: | ---: | ---: |
| A | 342.43 | 171.22 | 111.66 |
| B | 124.75 | 62.37 | 40.68 |
| C | 54.76 | 27.38 | 17.86 |
| D | 20.23 | 10.12 | 6.60 |

150/300 GB/s 是敏感性分析输入，尚无测量依据；460 GB/s 是 [AMD 标称的整卡 HBM 总带宽][u55c-spec]。**这些下界没有证明当前端口设计能够达到相应总带宽。**

对每条实际访问路径还需检查：

```text
B_port_peak = (AXI_width_bits/8) * f_AXI
B_path_eff <= min(活动端口能力、目标 HBM 区域能力、互连能力) * 实际效率
T_memory_phase >= max_p(该阶段端口 p 的字节数 / B_p_eff)
```

例如，一个 512-bit master 若运行在 150 MHz，原始峰值仅 **9.6 GB/s**；300 MHz 时为 19.2 GB/s。若各 Linear 按顺序执行，且每阶段的全部 q/scale/sum_w 通过这样一个 150 MHz master 装载，T_M=16 的权重流量本身至少约 **1.458 s**；T_M=64 约 **0.365 s**；读一遍约 **45.8 ms**，尚未扣除效率损失。若 SoA 拆成多个端口，应按各端口实际字节数重新计算。

`HBM[4:5]` 等 bank group 分配不会自动把一个 master 的吞吐翻倍；FPGA 计算频率、AXI master 频率和平台侧时钟也应分别核实。当前第 7.4 节只是起始连接提案，需要以每阶段的真实端口需求调整。

PCIe 和核间 stream 单独计量：

- 稳态输入约为 `5*S+5*K+1` bytes，S=512、K=32 时为 **2,721 bytes**，输出 logits 为 `4*(K+2)=136 bytes`，另加 ABI metadata/status/对齐。其带宽需求很小，启动与同步开销需要实测。
- 初始化上传整份 497,319,608-byte 模型包；以 8/12 GB/s 的假设有效 PCIe 带宽计，仅上传约 **62.2/41.4 ms**。Gen3×16 的约 15.75 GB/s 理论单向值对应约 31.6 ms；均未计磁盘读取、BO 创建和 xclbin 加载。
- 两条 FP32 核间 stream 各传 `4*S*D`，S=512 时每条 **2 MiB**。若 512-bit、150 MHz、每周期一个 beat，单条原始传输时间约 **0.218 ms**，实际受 backpressure 限制；stream 流量不再加入 HBM 流量。

#### 11.3.8 有效算力与设备延迟的条件估算

定义 `N_int` 为 int8 乘加 lanes 数，`N_fp` 为 FP32 attention MAC lanes 数，lane 表示一条计算通路；`R_restore` 为每秒可完成的 Group32 恢复数。`II` 表示一条流水线每隔多少周期可接收一次新任务，`η` 表示扣除调度、tile 尾部等影响后的利用率，均按综合与测量结果填写：

```text
P_int_dot = N_int * f / II_int * η_int             # MAC/s
P_linear <= min(P_int_dot, 32*R_restore)
P_attention = N_fp * f / II_fp * η_fp              # FP32 MAC/s

T_MAC_service = MAC_linear/P_linear + MAC_QK_AV/P_attention
```

首版按层复用引擎，Linear 与 attention 子层依次执行。上式用于估算没有跨子层重叠时的矩阵计算服务时间；并未包含 Softmax、GELU、norm、A8 编码、传输和主机开销。不能用一个混合精度的总 TOPS 直接除 197.33 GMAC。

在 **150 MHz、dot/attention II=1、恢复吞吐已配平** 的假设下，B=1、S=512、K=32：

| 算力假设 | int8 lanes | FP32 MAC lanes | 每周期 Group32 恢复能力 | η | Linear / attention GMAC/s | Linear ms | QK/AV ms | MAC 服务时间合计 ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 示例 1 | 512 | 16 | 16 组 | 50% | 38.40 / 1.20 | 4,911.7 | 7,269.9 | **12,181.6** |
| 示例 2 | 2,048 | 64 | 64 组 | 65% | 199.68 / 6.24 | 944.6 | 1,398.1 | **2,342.6** |
| 示例 3 | 4,096 | 128 | 128 组 | 80% | 491.52 / 15.36 | 383.7 | 568.0 | **951.7** |

这三行是**资源/调度敏感性示例，不是当前三核已经能容纳的配置或预计交付性能**。FP32 MAC、恢复流水线、exact GELU/exp 都有额外 DSP/LUT/存储代价，且 encoder/decision 三核方案会产生两套引擎；必须先进行 M3 分核综合和总资源检查。整卡 9,024 个 DSP 不能直接换算成 9,024 个 FP32 MAC，也不能把 tile 的 `16×16×32` 直接当成全部乘法同时展开。

示例 2 中，attention 虽然仅占 4.42% MAC，却占约 **59.7% 的矩阵服务时间**；若 Group32 恢复仅有 16 条而非 64 条，Linear 服务时间又会受恢复限制增至约 3.78 s。优先优化哪个模块必须看各自有效吞吐。

在示例 2 下，K=4 的 S=64/128/256/512 对应矩阵服务时间约 **158/374/901/2,342 ms**。已有两题 S=94、K_pad=3 的例子，按两行均无 padding 的上界计，合计约 **511 ms**，还需加其他计算和端到端开销。以上为 FPGA 条件估算；RTX A6000 的实际 SDK 延迟另见 [GPU 报告][gpu-benchmark]。

一个 100 ms 的 S=512 行，至少需要 Linear 平均约 **1.886 TMAC/s**、attention 约 **87.24 GMAC/s**、恢复约 **58.94 G 组/s** 才能分别在整个 100 ms 内完成各自工作；实际必须给这些顺序阶段分配更短预算，所以这些还只是必要条件。第 11.3.7 节场景 D 的 6.60 ms 标称带宽下界不能用作 6.60 ms 推理预测。

更细的估算应逐阶段使用：

```text
T_device ≈ Σphase max(矩阵工作量/该精度有效算力,
                      max_p(端口 p 的字节数/端口 p 的有效带宽),
                      分组数/恢复吞吐,
                      非线性元素数/对应流水线吞吐)
           + 无法重叠的操作与等待
```

只有确实在 DATAFLOW 中重叠的任务才能取 max；依赖造成的串行 pass 应分成不同 phase 求和。对整个模型直接取 `max(全部计算时间, 全部访存时间)` 只能提供粗略下界，容易隐藏同一层内部的串行访问。

#### 11.3.9 端到端、吞吐与上板前需补的证据

首版常驻会话的完整请求时间为：

```text
T_request = T_cpu_prepare
            + Σ问题行(T_h2d + T_launch/device_chain + T_d2h)
            + T_cpu_postprocess + T_queue（若包含排队）
```

报告是否包含排队；cold start 另列。串行单会话吞吐约为 `1/平均请求服务时间`，决策/s 还取决于每请求的问题行数。三核连接并不自动形成三个请求同时执行的流水线；首版共享 workspace 并串行执行，吞吐按实际调度测量。功耗如需比较，记录稳态板卡与主机的测量边界，再计算 `能量/请求 = 平均功率*服务时间`，不以 115 W 典型功耗替代测量。

**输入 token/s 与推理吞吐的数值换算。** Laya 对完整输入序列编码并输出候选/动作 logits，这里的 token/s 是输入处理吞吐。对一个串行、单问题行的执行：

```text
槽位 token/s = S / 单行服务时间
有效输入 token/s = S_valid / 单行服务时间
问题行/s = 1 / 单行服务时间

多问题请求的有效输入 token/s = Σ行 S_valid / 请求服务时间
请求/s = 1 / 平均请求服务时间
```

三核串行共享 workspace 的首版不能用 latency 的倒数推导未来多实例/重叠调度的吞吐。下面沿用当前串行调度，用第 11.3.8 节矩阵服务时间换算；**未计其他操作，表中吞吐是给定算力和调度下的乐观值，不是端到端测量**。

| 150 MHz 算力假设，S=512、K=32 | MAC 服务时间 s/行 | 输入 token/s，无 padding | 问题行/s |
| --- | ---: | ---: | ---: |
| 示例 1：512 int8 lanes、16 FP32 MAC lanes、η=50% | 12.182 | **42.0** | **0.082** |
| 示例 2：2048 int8 lanes、64 FP32 MAC lanes、η=65% | 2.343 | **218.6** | **0.427** |
| 示例 3：4096 int8 lanes、128 FP32 MAC lanes、η=80% | 0.952 | **538.0** | **1.051** |

各例均要求 Group32 恢复吞吐配平；其资源可行性和实际频率仍需 M3 确认。对示例 2，固定 K=4，长度对照如下：

| S，无 padding | MAC 服务时间 ms/行 | 输入 token/s | 问题行/s |
| ---: | ---: | ---: | ---: |
| 64 | 158.4 | 404.0 | 6.313 |
| 94 | 255.3 | 368.2 | 3.917 |
| 128 | 373.6 | 342.6 | 2.677 |
| 256 | 900.8 | 284.2 | 1.110 |
| 512 | 2342.5 | 218.6 | 0.427 |

较短输入的每题耗时更低，token/s 也随 full attention 的二次项变化。上述 token 是 tokenizer 输出的词元，不能按中文字数换算。

**带宽约束会降低上述吞吐。** 进一步假设示例 2 的内部算力不变，顺序执行的每个 Linear 使用一条权重读取路径，attention 使用一条 K/V 路径；每条路径均为 512-bit、150 MHz、65% 带宽效率，即 **6.24 GB/s**。以第 11.3.7 节流量作分阶段简化：

```text
T_core_memory_floor ≈ max(T_linear_MAC, D_weight/6.24e9)
                      + max(T_attention_MAC, D_KV/6.24e9)
```

| 缓存/复用假设，S=512、K=32 | 矩阵与只读流量服务下界 s/行 | 对应输入吞吐上限 token/s | 对应问题行/s 上限 |
| --- | ---: | ---: | ---: |
| A：T_M=16，逐 query 重读 K/V | **7.836** | **65.3** | **0.128** |
| B：T_M=16，T_Q=16 复用 K/V | **3.642** | **140.6** | **0.275** |
| C：T_M=64，T_Q=16 复用 K/V | **2.343** | **218.6** | **0.427** |

这张表不是三种已实现的配置：逐算子算力/流量比例与端口共享可能继续增加时间。公式未计 D_pass 中的额外访存、非线性和 CPU/XRT 开销；因此给出的 65/141/219 token/s 是这些明确条件下的乐观换算，完整请求吞吐还需下调。不能将它们当作 U55C 的通用性能区间。

已有两题 trace 的输入共 **166 个有效 token、188 个槽位**。示例 2 按两行均 94 个有效 token、K_pad=3 的 attention 工作量上界计算，矩阵服务时间约 **510.5 ms/请求**，对应约 **325.2 有效输入 token/s、368.2 槽位 token/s、1.959 请求/s、3.918 问题行/s**。这里分子使用真实有效 token 数，分母使用保守矩阵工作量；跳过 padding key 会减少该分母，而其他推理开销又会增加分母。它是 trace 形状上的条件估算，仍非实测吞吐。

M3/M6 必须用以下数据替换本节假设：

1. 每个 Linear 的实际物理 shape、q/scale/sum_w 字节数，以及权重/activation 循环导致的读放大。
2. dot、FP32 恢复、attention、exp/GELU 的实际 II、并行度、频率、DSP/LUT/BRAM/URAM 和跨组累加停顿。
3. 各 AXI bundle 的宽度/时钟、burst/outstanding，代表性权重、activation、K/V 访问模式的有效带宽与拥塞。
4. 相同 S/K/padding 的单层时间、完整 device chain 时间、host 开销和端到端 p50/p95；以 profiler/计数器核对估算是否漏项。

功能 baseline 的目标是给出可信的 FPGA 测量。是否完成“部署加速”须在质量门槛通过后，明确相对哪条 CPU/GPU 对照，给出 `speedup = reference_e2e / fpga_e2e`。用户最初观察 GPU 约 **50 ms**，后续确认 RTX A6000、72/94 token 两题请求。已补测普通 SDK BF16 AMP：整请求预热 P50 **25.05 ms**、P95 **25.22 ms**，单独 choice P50 **24.20 ms**，计时包含分词、传输和后处理。对应的 FPGA 加速门槛应使用相同问题数与完整调用边界的实测值。

#### 11.3.10 基于 A6000 实测的 U55C 25 ms 决策延迟分析

**结论：当前 B=1、Group32 FP32 恢复、FP32 attention 的功能方案没有支持快于 A6000 的性能证据。** 针对这次短序列，可研究共享引擎、B=2 权重复用、缓存、融合与更低精度的速度变体；能否快于约 25 ms，要同时通过数值、资源、时序和完整请求测量。U55C 的 460 GB/s 标称 HBM 总带宽不能直接变成推理速度。

##### A. 比较对象与实际工作量

本次 GPU 使用普通 SDK、BF16 AMP、常驻模型，完整调用包括分词、输入准备、H2D、前向、D2H 和答案后处理，排除模型加载、文件 I/O 与排队。每场景预热后测量 3 轮、共 150 次：[实测报告][gpu-benchmark]、[原始样本][gpu-benchmark-data]。

| GPU 场景 | 均值 ms | P50 ms | P95 ms | FPGA 应比较的单位 |
| --- | ---: | ---: | ---: | --- |
| refund + department 两题一起 | **25.109** | **25.047** | **25.224** | 两题都返回的完整请求 |
| 单独 department 选择 | 24.347 | 24.200 | 24.645 | 相同单题的完整请求 |

两题分别调用的均值之和约 48.09 ms；两题组 batch 则约 25 ms。这使用户最初的约 50 ms 观察有一个可比较的拆题场景，但没有证明原观察的计时方式。25 ms 除以两题只能得到吞吐摊销成本，不能称为单题延迟。首版 FPGA 若执行两个 B=1 microbatch，必须将两次执行及主机开销求和再比较。

匹配输入固定为 **B=2、S=94、K_pad=3**：退款题有效长度 72，部门题 94，共 166 个有效 token、188 个槽位。保留全部 query、跳过 padding key 时，两个问题的 full 合法位置对为 6,768 / 8,836，local 为 6,305 / 7,966。

GPU 拆成单题后，退款 `P(true)` 为 0.6075，两题一起则为 0.5975，差异来源尚未定位。速度变体以原始 B=2 输入及对应黄金结果为参照；改变 batch/padding 时同时记录 logits、概率和任务质量，不能只凭最终标签相同判断数值等价。

```text
Linear MAC = 2*[28*94*(4*1024² + 3*1024*2624)
               + 2*94*(4*1024² + 2*1024*4096)
               + 3*(1024²+1024) + 1056*256 + 256*2]
           = 69,249,555,456 MAC
QK/AV MAC = 2*1024*[12*(6768+8836) + 18*(6305+7966)]
          =    909,570,048 MAC
合计      = 70,159,125,504 MAC = 70.159125504 GMAC
Group32 恢复次数 = Linear MAC/32 = 2,164,048,608 组
```

这些是拟建 HLS 计算图的工作量，含 act 的 1056 维补零；不是 GPU kernel 实际指令数。若把全部 deadline 都给矩阵运算，50/25/20 ms 分别要求平均 **1.403 / 2.806 / 3.508 TMAC/s**。该混合 MAC 值只反映工作量，不能直接与 INT8 TOPS 比较，也没有给其他操作留时间。

Laya 不生成新 token。这里“TTFT”若指提交请求后首次得到判断，应使用完整决策延迟；若指新进程首次调用，则还需比较双方的初始化和加载。本次 GPU 加载后首次两题调用为 503.70 ms，只测一次；不能用它替代常驻服务的约 25 ms 对照，也不能与已经加载权重的 FPGA 会话混比。

##### B. 25 ms 的反推预算：算力与 DSP 必须一起核查

先定义一个需要原型证明的 **25 ms 预算**，用于发现设计缺口：

| 部分 | 预算 ms | 要计入的工作 |
| --- | ---: | --- |
| CPU/XRT/小输入输出 | 2 | 输入准备、提交/同步、传输、结果后处理 |
| 全部 Linear | 16 | int8 dot、校正、Group32 恢复、bias，以及重叠后的权重/activation 访问 |
| Attention QK/AV | 4 | 矩阵计算及重叠后的 K/V 装载 |
| 向量算子 | 2 | norm、A8 编码、RoPE、GELU/gate、ReLU、Softmax、残差等 |
| 余量 | 1 | tile 尾部、层切换、未隐藏等待与波动 |
| **合计** | **25** | 完整两题请求 |

这是预算分配，**不是预报时间**。CPU 准备的独立 GPU 测试均值为 0.677 ms，仅作为输入准备规模的参考；FPGA 的 XRT 开销尚未测量。只有实际 DATAFLOW 能重叠的访存/计算才可共用预算，串行装载、量化或归约必须计入总时间。

以 **计算时钟 300 MHz、II=1、有效利用率 70%** 作反推，每条 lane 的有效能力为 210 M 次/s；初始功能版仍以 150 MHz 构建起步：

| 工作 | 分配时间 | 所需有效吞吐 | 所需并行能力的必要条件 |
| --- | ---: | ---: | --- |
| int8 dot | 16 ms | **4.328 TMAC/s** | 至少 **20,610 条 int8 MAC lanes** |
| Group32 校正/恢复 | 同一 16 ms | **135.253 G 组/s** | 至少 **645 组/周期**的 II=1 恢复能力 |
| FP32 QK/AV | 4 ms | **227.393 GMAC/s** | 至少 **1,083 条 FP32 MAC lanes** |

若阵列按每组 32 条 dot lanes 配置，应向上对齐为 **20,640 条**，与 645 组恢复配平。每组按两次 FP32 乘法和一次累加计，仅恢复就在 16 ms 内要求约 **405.759 G 次浮点基本运算/s**，还没有计整数校正和类型转换。跨组累加的反馈依赖、FMA 顺序及 tile 尾部会影响 II 和数值，不能只按乘法 lanes 数验收。

U55C 只有 **9,024 个 DSP**。若 dot 全由 DSP 承担，即使假设每个 DSP 每周期能持续提供两条 int8 dot lanes，20,640 条也需要 **10,320 个 DSP**，尚未给 FP32 attention、恢复及其他算子分配资源。在这一 DSP 分工下，预算先要求全卡平均至少约 **2.28 条 dot lanes/DSP/周期**，再容纳其他引擎。实现需要更强的合法 packing、LUT 算力、更高实际时钟/利用率或新的数值方案；packing 的符号处理、校正、累加和布线代价必须通过综合确认。不能把一个 DSP 当成一条 FP32 MAC。

作为对照，保持 FP32 attention、恢复配平、300 MHz/70%/II=1，实际两题的矩阵服务时间为：

| int8 / FP32 MAC lanes | 恢复组/周期 | Linear ms | QK/AV ms | 合计 ms |
| --- | ---: | ---: | ---: | ---: |
| 4,096 / 128 | 128 | 80.508 | 33.838 | **114.346** |
| 8,192 / 256 | 256 | 40.254 | 16.919 | **57.173** |
| 16,384 / 512 | 512 | 20.127 | 8.460 | **28.586** |

这些配置均未经资源/时序验证，表中未计非线性、额外访存和主机时间。最宽一行仅矩阵计算就超过 25 ms；因此“使用 int8 + 提高频率”本身不足以证明加速。复制 encoder/decision 两套大阵列还会进一步占用资源。

##### C. 权重读取：B=2 复用和同时工作的端口是必要设计项

以下以一条 **512-bit、300 MHz、70% 读取效率**的 master 作分析，其有效读取能力为 **13.44 GB/s**；AXI 时钟与计算时钟要分别确认。一遍全部 Linear 权重/scale/sum_w 为 **438,938,912 bytes**。

若只用一个这样的读 master，两题 B=1 各读一遍需 **65.32 ms**；B=2 复用为一遍仍需 **32.66 ms**。一遍权重在整个 25 ms 内读取至少需要两个并发且负载均衡的读 master；放入上述 16 ms Linear 预算则至少需要三个。

权重循环如果仍以 token tile 为外层，还会放大流量。对 B=2 将 Linear 的 token 行展平为 188 行，序列权重为 437,370,880 bytes，scorer/act 权重合计 1,568,032 bytes；下表假设小输出头各读取一次，不计 embedding/aux：

| 权重调度 | Linear 读取 GB | 16 ms 所需读取 GB/s | 13.44 GB/s 读 master 数量下界 |
| --- | ---: | ---: | ---: |
| B=1 两次，每题序列权重读一遍 | 0.877878 | **54.867** | **5** |
| B=2，同层权重跨全部 token 复用 | 0.438939 | **27.434** | **3** |
| B=2，T_M=64，每个 tile 重读；`ceil(188/64)=3` | 1.313681 | **82.105** | **7** |
| B=2，T_M=16，每个 tile 重读；`ceil(188/16)=12` | 5.250019 | **328.126** | **25** |

这是读取能力的必要条件，未证明端口/互连/目标 HBM 区域能承受这些吞吐。必须把**当前正在执行的同一个 Linear**的数据分布到多个同时活动的 master；给不同层分配不同 bank、或给一个 master 绑定多个 bank，都不会自动得到带宽相加。

SoA 的 q/scale/sum_w 字节数比例为 32:4:2，不能只平均分配端口数量。一遍 q 本身为 369,632,768 bytes，在 16 ms 内需 **23.102 GB/s**；因此至少应评估 q 沿输出通道分给两个读取 master，scale/sum_w 再按其实际负载连接。三个端口若分别只有一个 q、一个 scale、一个 sum_w，q 仍会成为瓶颈。

##### D. K/V 缓存与 workspace：容量小不等于流量小

按第 11.3.6 节相同的 FP32 pass 调度，对两行 S=94：

```text
D_pass = 2*[715*(4*94*1024) + 168*(4*94*2624) + 8*(4*94*4096)]
       = 906,731,520 bytes
逐 query 重读 K/V = 4*MAC_QK_AV = 3,638,280,192 bytes
每层有效 K/V 只装载一次 = 30*8*1024*(72+94) = 40,796,160 bytes
```

逐 query 的 K/V 若要放入 4 ms Attention 预算，仅读取就需 **909.570 GB/s**，超过整卡 460 GB/s 标称总带宽。每层缓存后则约 **10.199 GB/s**；一个上述读 master 的装载下界约 3.04 ms，仍需按 head/layer 使用双缓冲或流式衔接，证明与计算能重叠。否则装载时间必须另外相加。

S=94 时，两题一个 head 的 padded FP32 K+V 缓存共 **94 KiB**，16 heads 合计 **1.469 MiB**。两题一份 hidden 为 **0.734 MiB**；最大的 Wi 量化权重含元数据约 **6.086 MiB**，其两题 FP32 输出约 **3.764 MiB**。这些容量值得评估片上缓存，但还需考虑双缓冲、数组分区、并发读口、BRAM/URAM 碎片和 SLR 布局；43 MB 总 SRAM 不等于可任意组合的多端口缓存。

在一遍 Linear 权重、token/type embedding 查表、aux 读一次、上述 K/V 缓存和未融合 FP32 passes 的假设下，两题总 HBM 流量约 **1.387039 GB**，25 ms 对应平均 **55.482 GB/s**。其中 workspace 自身就有 **0.906732 GB**、平均 **36.269 GB/s** 的读写。总量看起来低于 460 GB/s，但顺序 phase 和单条路径仍可能超时；workspace 要分别核查 AXI RD/WR 的负载与是否能同时工作，不能将读写合计直接套用单向 13.44 GB/s。

速度变体应优先减少 RoPE、GEGLU、残差、norm/量化的中间落 HBM；只增大 workspace 容量并不能减少反复读写。B=2 复用的是权重，两题的注意力与隐藏状态仍独立；共享 state 文本不能直接复用双向编码后的 state 表示。

##### E. 2 ms 向量预算仍需验证，不能把非线性忽略

该请求的主要元素工作量如下。最后一列假设**某一类算子独占整个 2 ms**、300 MHz/70%/II=1，是各类独立的必要并行度下界：

| 工作 | 元素/事件数 | 独占 2 ms 时所需元素能力 |
| --- | ---: | --- |
| LayerNorm 特征 | 11,749,376 | 5.875 G 元素/s，至少 28 元素 lanes |
| GELU | 13,819,392 | 6.910 G 元素/s，至少 33 个 II=1 单元 |
| A8 编码输入 | 32,693,824 | 16.347 G 元素/s，至少 78 元素 lanes |
| RoPE Q/K 特征 | 10,780,672 | 5.390 G 元素/s，至少 26 元素 lanes |
| ReLU | 1,540,096 | 0.770 G 元素/s，至少 4 元素 lanes |
| Attention Softmax 合法 score | 7,106,016 | exp 至少 3.553 G 次/s、17 个 II=1 单元 |

这些行不能同时各用满 2 ms：串行时间会相加，还没有计 gate、残差、bias、归约及最终输出头的统计量。LayerNorm 涉及均值/方差/逆平方根，A8 涉及 Group32 min/max、除法和 RNE，Softmax 涉及 max/exp/sum/归一化；元素吞吐不等于完整算子吞吐。应以整层调度证明更高并行度或合法融合，exact GELU/exp 的 II 与资源必须由 HLS 给出。改用近似函数须重新签核数值和质量。

##### F. 功能版与速度变体：用原型判断加速可行性

1. **功能版**保留第 1 节的 B=1、三核起点、W8A8 + FP32 恢复/状态/attention、150 MHz 初始请求时钟，先建立完整参考、接口和 FPGA 测量。其价值是证明模型部署正确；当前没有给它设定低于 25 ms 的交付承诺。
2. **复用与融合变体**评估共享 encoder/decision 引擎、B_MAX≥2、同层权重跨两题和全部 token 复用、q 多读 master、K/V 缓存及向量融合。更新 ABI/build manifest，保持两题各自的 mask/marker/注意力语义。以上预算表显示，继续保留全部 FP32 恢复/attention 时资源压力很大。
3. **数值速度变体**再评估整数 ScaleCode 恢复与 FP16/BF16/定点 attention。已有 [整数 ScaleCode 验证][integer-evidence]提供 S48/F24 贡献、S56/F24 累加及质量回归依据，但其宽乘法、移位、RNE 和累加仍有硬件成本，没有 FPGA 吞吐证据。attention 降精度也需独立的动态范围、溢出、逐层/logits/概率及任务质量验证，不能直接套用 Linear 的精度结果。

M3 应先对本请求做代表原型，而不是依据 tile 的 unroll 数预测整机：

| 证据 | 用上述 25 ms 预算反推的检查点 |
| --- | --- |
| 完整 Wi Linear，输入 `[188,1024]`、输出 5248 | 每层 1.010303 GMAC，按 Linear 比例分配约 **0.233 ms**；同时验证恢复、真实权重读取、activation/部分和、尾部与资源 |
| encoder 全部 Linear 的一层调度 | 两题每层约 2.304 GMAC，对应约 **0.532 ms** 的 Linear 服务预算；须含本层实际等待 |
| full/local Attention 原型，长度与 mask 固定 | full 两题每层 31.956992 MMAC，其 QK/AV 比例预算约 **0.141 ms**；另核查 Softmax 和缓存装载的实际依赖 |
| 合并后资源与实现 | 全部 dot/恢复/attention/向量单元、缓存及控制能共同放入 U55C，并达到实际时钟；不能累加各自孤立综合的最高频率 |
| 完整请求与质量 | 常驻模型、相同两题与输入，逐样本记录均值/P50/P95，并通过第 10 节数值和任务质量门槛 |

若代表原型的吞吐、端口或总资源达不到预算，应调整速度架构并更新估算；功能部署仍可继续，但不能报告已完成 GPU 加速。最终 speedup 用同一种统计量计算，例如 `GPU_P50 / FPGA_P50`，并同时比较 P95；只测 kernel 时间不能替代完整请求时间。

建议把 **≤20 ms** 作为速度研究目标，为延迟波动和测量差异留出余量。若实测完整请求均值为 20 ms，则串行吞吐为 **50 请求/s、100 题/s、8,300 有效输入 token/s**；相对本次 GPU 均值约 **1.26×**，这是目标换算而非性能预测。更深流水线或多实例的吞吐另行测量，不能据此推导单次请求更快。

GPU 驻留输入 forward 的 CUDA event 均值为 23.929 ms，包含主机发射算子时的 GPU 等待区间；本轮未 profiling，不能认定它全是计算瓶颈。普通 SDK 对照未启用 fast/compile/CUDA Graph，也不是 A6000 的性能上限。FPGA 的潜在收益来自固定网络上的融合、复用和调度，但低于当前约 25 ms 的结论必须由实现证明；GPU 软件优化后的比较需要新的对照数据。

### 11.4 优化顺序

根据第 11.3 节，功能版 M3 应先核查 **Group32 恢复是否配平、FP32 attention 吞吐、K/V 缓存和权重读放大**。M6 再依据测量选择优化顺序。对于本次两题约 25 ms 的速度目标，优先验证第 11.3.10 节的共享引擎和 B=2 权重复用，再配平 q 活动读端口、K/V 缓存、恢复与矩阵资源；同时核查向量融合。ScaleCode、attention/状态降精度、online Softmax 等作为独立数值变体评估，顺序随实际瓶颈调整。

每次只改变可归因的一组因素，使用新的 build/run ID，重复适当的数值和质量门槛。尺度压缩、非线性近似、online Softmax 或状态降精度均属于数值变更，不能只跑时序报告。

## 12. 首批待执行工作与证据入口

建议实施时先完成以下有顺序的交付：

1. `model_contract + numeric_contract + request_abi`：冻结英文检查点、U55C、B/S/K、Group32 和三个核的接口。
2. 完整 SDK 输入 fixtures：使用本地示例、已有实际 shape trace 和窗口/候选边界用例，保存所有输入 hash。
3. exporter 与矩阵 inventory：确认 124 Linear/2 Embedding、Act padding、payload offsets、恢复规则和校验和。
4. 独立整数 GEMM golden 与第一个 HLS 原型：先验证 zero-point 校正、bias、RNE、tile 尾部，再进入单层模型。
5. 完整 C 仿真与分核资源检查：据此决定三核是否需要合并，并冻结首个上板 build。
6. 速度变体的代表原型与预算核对：使用 `[2,94]` 两题固定输入，验证第 11.3.10 节 Wi/attention、恢复、端口和合并资源；依据证据决定是否具备低于约 25 ms 的实现路径。

已完成的规划证据：核查模型及框架版本、checkpoint/config hash、实际量化公式和 padding、SDPA 窗口语义、SDK act/温度顺序；通过 safetensors 头部统计完成单份权重载荷和 workspace 估算。补充分析重新读取 124 个 Linear/2 个 Embedding 的 shape，核对 497,319,608-byte 载荷，并用逐位置窗口枚举交叉核对位置对公式，复算不同 S/K 的 MAC、量化恢复工作量、不同复用方式的访存及条件性能。现已在 RTX A6000 对两题请求及两个单题拆分各完成 3 轮、150 次预热后 SDK/驻留输入前向测量，数据见 [GPU 报告][gpu-benchmark]；据此复算两题的 25 ms 预算、资源必要条件、读端口负载、K/V 缓存和向量工作量。尚未完成新的量化质量评估、HLS 综合或 FPGA 实现。

### 参考与源码

| 入口 | 用途 |
| --- | --- |
| [Llama baseline 研究][llama-research] | 三核、XRT、HBM、构建流程及待避免的问题 |
| [Laya 推理流程][laya-flow] / [张量形状记录][laya-shapes] | 输入、主干、决策、输出与已有实际 trace |
| [encoder 配置][encoder-config] / [Agent 配置][agent-config] | 模型尺寸、RoPE、输入预算和温度 |
| [sequence/DecisionModel][decision-source] / [SDK 后处理][decode-source] | 模型语义、raw act features 和最终答案 |
| [ModernBERT][modernbert-source] / [RoPE][rope-source] / [窗口 mask][mask-definition] | 主干实际算子、配对和局部边界 |
| [Group32 实现][quant-reference] / [完整量化范围][quant-scope] / [整数验证][integer-evidence] | 量化规则、模块映射、尾部 padding、独立验证经验 |
| [GGUF Q8_0 研究][gguf-research] | 区分现有 GGUF 格式、FP16 scale 与本方案的原始导出契约 |
| [Q8_0 英文 inventory][gguf-general-inventory] / [微调版 inventory][gguf-typed-inventory] / [既有精度评测][gguf-accuracy] | 实际本地量化权重、浮点例外与软件质量证据；第 5.6 节的部署分析 |
| [AMD U55C 官方规格][u55c-spec] / [XRT 文档][xrt-doc] | 区分 16 GB HBM 容量、460 GB/s 总带宽、DSP/SRAM 资源、PCIe 与主机运行时 |
| [GPU 实测报告][gpu-benchmark] / [速度测试程序][gpu-benchmark-program] | RTX A6000 同请求的完整调用与前向延迟、原始样本、吞吐、计时口径及复现 |

[llama-research]: /home/user/EDA-202/zhuowenjun/Laya/LLAMA-HLS/Laya-baseline/source/llama_baseline_research.md
[laya-flow]: /home/user/EDA-202/zhuowenjun/Laya/source/laya_inference_flow.md
[laya-shapes]: /home/user/EDA-202/zhuowenjun/Laya/source/laya_tensor_shapes.md
[encoder-config]: /home/user/EDA-202/zhuowenjun/Laya/model/english/encoder/config.json
[agent-config]: /home/user/EDA-202/zhuowenjun/Laya/model/english/rl_agent_config.json
[decision-source]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/laya/common.py:74
[decode-source]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/laya/agent.py:653
[modernbert-source]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/transformers/models/modernbert/modeling_modernbert.py:304
[rope-source]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/transformers/models/modernbert/modeling_modernbert.py:188
[window-config]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/transformers/models/modernbert/configuration_modernbert.py:160
[mask-definition]: /home/user/EDA-202/zhuowenjun/Laya/model/.venv/lib/python3.12/site-packages/transformers/masking_utils.py:142
[quant-reference]: /home/user/EDA-202/zhuowenjun/Laya/idea/scalelaya/program/scripts/laya_scale_formats.py:118
[quant-scope]: /home/user/EDA-202/zhuowenjun/Laya/idea/scalelaya/source/06_new_format_accuracy_run.md
[integer-evidence]: /home/user/EDA-202/zhuowenjun/Laya/idea/scalelaya/source/07_integer_scalecode_accuracy.md
[gguf-research]: /home/user/EDA-202/zhuowenjun/Laya/model/quantized/gguf/source/q8_0_quantization.md
[gguf-general-inventory]: /home/user/EDA-202/zhuowenjun/Laya/model/quantized/gguf/source/q8_0_inventory.json
[gguf-typed-inventory]: /home/user/EDA-202/zhuowenjun/Laya/model/quantized/gguf/mys/laya-typed-decisions-GGUF/Q8_0/inventory.json
[gguf-accuracy]: /home/user/EDA-202/zhuowenjun/Laya/experiment/acc_FP_vs_gguf/results/summary.md
[u55c-spec]: https://www.amd.com/en/products/accelerators/alveo/u55c/a-u55c-p00g-pq-g.html
[xrt-doc]: https://xilinx.github.io/XRT/2023.2/html/index.html
[gpu-benchmark]: /home/user/EDA-202/zhuowenjun/Laya/results/laya_gpu_inference_benchmark_20261005.md
[gpu-benchmark-data]: /home/user/EDA-202/zhuowenjun/Laya/results/gpu_inference_20261005_run01/measurements.json
[gpu-benchmark-program]: /home/user/EDA-202/zhuowenjun/Laya/source/benchmark_inference.py
