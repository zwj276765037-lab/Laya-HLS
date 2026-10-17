# 16 从两个 Llama baseline 到 Laya：代码依据与改造范围

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

本文件回答“设计参考了哪里，以及怎样变成 U55C 上可运行的 Laya”。以下结论来自本地源码核查，不表示已经复现 baseline 的板上性能。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 源码身份 | 7B/Tiny commit及参考文件见本文§1 | 本次重新检查commit和5组文件一致性 | 工程事实 | S4/S6 |
| 可继承部分 | XRT、HLS、HBM连接与构建方法 | baseline源码存在；不代表Laya已通过 | 工程事实 | 本文§2、§3 |
| Laya新增部分 | 整序列、共享引擎、Group32及Typed算子/heads | 首版HLS方案，仍需本项目实现与验证 | 推断 | S3；本文§3、§6 |
| 实际部署环境 | 用真实U55C平台冻结工具、接口和时钟 | 当前PATH无构建/板卡工具；未探测远端 | 待确认 | G1；S6；02 |

## 1. 核查的是哪两个版本

| 项目 | llama2-7b-baseline | Tiny-llama-baseline |
| --- | --- | --- |
| commit | `69d70e3d5906570a49d2d959c4b39be37f243c66` | `ee327e91cd69cb8ed6dc1fc735af4c3ee5931236` |
| 硬件维度 / 层数 | 4096 / 32 | 768 / 12 |
| 硬件序列长度 | 128 | 128；Host 却定义为 2048，需修正 |
| 量化组 / scale | 64 / FP32 | 64 / FP32 |
| 分核综合请求频率 | 300 MHz | 300 MHz |
| 本地预编译 xclbin | 没有发现 | 有，49,231,321 bytes；未在本轮加载 |

[7B 配置](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/llama2-7b-baseline/src/config.h)、[Tiny 硬件配置](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/config.h)、[Tiny Host 配置](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/config.h)。Tiny 分支按源码中的 768 维、12 层理解，不能仅凭名称当作任意 TinyLlama 检查点。

本次重新比较确认：`host/llama2.cpp`、`src/forward.h`、`src/typedefs.h`、`src/u55C1.cfg`、`hardware_implement.sh` 在两个分支逐文件相同。因此可以以 Tiny 作为较小规模的部署代码阅读入口，再用 7B 检查容量问题。

## 2. 它们确实怎样部署

```text
CPU 读取权重与 tokenizer
  → 打开 U55C，加载 xclbin
  → 分配 HBM BO，上传权重
  → 对每个 token：
      启动 embedding 核
      启动 Transformer 核
      启动 final norm/classifier 核
      等待三核完成，读取 logits
      CPU 采样下一个 token
```

[Host 初始化与上传](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/llama2.cpp:391) 使用 `xrt::device`、`load_xclbin`、`xrt::kernel`、`xrt::bo`、`group_id()` 和 `sync()`。[启动代码](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/llama2.cpp:451) 先启动三个核，再等待完成；核间 stream 要生产者和消费者都运行，不能把“启动第一个核并等完”照搬为所有流式链路的控制方法。

硬件对应 [forward.cpp](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp)：embedding 查表输出一个向量，Transformer 核循环执行全部层，classifier 写回词表 logits。连接由 [u55C1.cfg](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/u55C1.cfg) 的 `nk`、`sp`、`stream_connect` 指定。

## 3. 逐模块继承与修改

| Laya 模块 | baseline 可参考的具体实现 | 沿用什么 | 必须改什么 |
| --- | --- | --- | --- |
| Host | [Tiny Host](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/llama2.cpp:391)、[7B Host](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/llama2-7b-baseline/host/llama2.cpp:391) | XRT 会话、BO、同步、kernel 调用 | 整请求推理、Typed tokenizer、候选/act 后处理、常驻会话 |
| HLS 顶层 | [接口和层循环](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:55) | `extern C` 顶层、`m_axi`、`s_axilite`、硬件层循环 | 一个 Laya forward 核；不由 CPU 逐 token 生成 |
| 内存连接 | [连接文件](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/u55C1.cfg) | 参数到 HBM 的显式映射 | 只保留一份模型数据；按 q/scale、hidden、QKV、FFN 分区 |
| Embedding | [查表核](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:12) | 按 ID 定位行、缓存行、输出向量 | 从实际 Q8_0 行反量化，加 embedding LN；处理 B×S 行 |
| 量化与 Linear | [quantize](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:73)、[matmul](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:209) | 分组量化、整数 dot、scale 恢复的分解方法 | Group32、FP16 scale、GGUF 位模式、严格舍入；GEMV 改为多 token tile 复用 |
| LayerNorm | [rmsnorm](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:140) | 行缓存和归约的实现组织可参考 | 增加均值及 centered variance，不能直接使用 RMSNorm 公式 |
| RoPE | [rotation1](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:158) | Q/K 旋转在 attention 之前 | 相邻 pair 改为 half-split，读取 Laya 的 full/slide 表 |
| Attention | [multihead_attention](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:181)、[softmax](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.h:178) | head 循环、QK/softmax/AV 的阶段组织 | 双向、full/sliding 有限 mask，完整序列 K/V；不保留跨请求生成 cache |
| FFN | [FFN 段](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:230) | 两次投影、中间激活、残差的组织 | SwiGLU 改为 GEGLU；Decision 使用 ReLU |
| 决策头 | [classifier](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/forward.cpp:282) 仅提供输出写回思路 | 从硬件结果写回 Host 的路径 | 两层 Decision、marker gather、scorer/act 全部按 Laya 图实现 |
| 构建与测试 | [csim](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/csim.sh)、[综合/链接](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/hardware_implement.sh)、[上板脚本](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/run_inference.sh) | 验证阶段和 Vitis/XRT 工具链 | 用本项目路径、统一源码、Laya 请求及数值比较，补足时序/稳定性/性能记录 |

对应的 7B 文件结构相同。详细旧研究保留在[llama_baseline_research.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/source/llama_baseline_research.md)，本轮文档以 Typed Q8 为部署对象。

## 4. 不能从 baseline 推出来的结论

**数组分区、循环展开和 `PIPELINE II=1` 是给 HLS 的要求，不是已经达到的性能报告。** baseline 的 `matmul()` 实际是矩阵乘单向量，先读某一输出行的权重，再做分组 dot。没有证据支持把它直接描述为持续满载的大型二维阵列。

同样，`sp=...:HBM[6:10]` 给一个参数指定内存范围，不等于自动生成五个独立 AXI master。源码里的 K/V 两个指针共用 `bundle=gmem_kvc`，即使连接到不同 bank，也要评估共享 master 的争用。

本项目的多 token 权重复用、16×8×32 阵列、双缓存、13 个 master、FP32 attention 并行度都属于新增设计，必须经过 HLS 综合、RTL 联调、平台链接和上板测量。不能借 baseline 的 README 截图为它们背书。

## 5. 原工程中需要避开的复现问题

| 已核对的问题 | 对 Laya 的处理 |
| --- | --- |
| Tiny Host 长度 2048，硬件长度 128 | Host/HLS 共用一份配置，启动时核对模型和 build |
| 三个权重 BO 都上传整个 `weights` 结构 | 模型只导出一份有效数据，再分片存储，不复制三个完整模型 |
| 7B 原分配方案约需 22.08 GiB，超过常见 U55C 16 GB HBM | 按实际 tensor、每个 BO 和 bank 容量复核；不能只看模型文件名 |
| Host 连续加载默认和参数指定的两个 xclbin | 只选定并加载一个经过检查的 xclbin |
| 构建脚本含原作者绝对路径；hw_emu 链接行有多余 `h` | 重写成本项目可配置脚本，并在真实工具版本下检查命令 |
| README 的“可直接运行”依赖外部权重和匹配环境 | 保存模型/平台/工具版本、xclbin 元数据和测试输入，才能复现 |

这些问题不否定其参考价值，但意味着必须有本项目自己的上板验收。

## 6. 当前路线与完成标准

首版采用 **HLS C++ + 一个 Laya forward kernel + XRT 常驻 Host + HBM 模型/工作区**。Vivado 用于 HLS 产生的 RTL 的实现及必要的自定义 IP；先不额外设计通用指令总线或手写 XRT 寄存器映射。

开发顺序是“真实输入和软件参考 → 计算链路 C 仿真 → 资源/II → XRT/平台 → 完整 xclbin → 板上正确性 → 性能”。完整流程见 [02](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，跨模块性能评估见 [15](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

本次文档归并重新检查：当前shell的PATH中未找到 `v++`、`vitis-run`、`vivado`、`xclbinutil`、`xbutil`。没有执行构建、仿真或上板，也没有探测远端；该结果不能证明工具未安装或实际U55C服务器不可用。检查记录见S6。
