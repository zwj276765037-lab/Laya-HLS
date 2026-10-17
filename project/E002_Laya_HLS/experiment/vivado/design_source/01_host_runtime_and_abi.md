# 01 CPU Host：把一次业务请求交给 FPGA

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

Host 是服务器 CPU 上的程序。这里参考 [Tiny Host 的 XRT 初始化与上传](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/llama2.cpp:391)；7B 的对应代码相同。Laya 的主要改动是从“逐 token 生成”变为“一次提交完整问题序列”。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 功能边界 | CPU分词、组帧、XRT调用与业务解码；FPGA执行完整网络 | Llama已有XRT调用样例；Laya Host尚未实现 | 明确要求 | U1/U2；S4 |
| 输入/输出语义 | 原生I32 token/marker/qtype、F32 masks；ABI将二值masks编码U8；16列候选和2列act logits | 本次真实CPU捕获已核对dtype，U8是硬件接口设计 | 工程事实＋ABI设计 | S1/S3；本文§2、§7；14§10 |
| 首版Host方案 | B≤2串行session，13 BO、32KiB IO；wait后sync | 是本项目接口草案，尚无共享头文件 | 推断 | S3；02、14 |
| 具体ABI | 本文§6精确规定字节偏移、枚举和校验 | 文档合同已细化，尚未生成laya_io.h或执行Host/HLS回放 | 推断（本次实施合同） | G2；本文§6 |
| 性能口径 | 常驻请求与冷启动分开；同Typed请求对比A6000 | 历史GPU报告口径不同 | 推断 | U3；S5；14 |

## 1. 一次初始化，重复推理

服务启动时完成：选择设备 → 加载一个匹配的 xclbin → 取得 `laya_typed_q8_forward` → 按02的参数分配 BO → 上传模型一次 → 准备可复用工作区。

每次请求只做：

```text
文本/问题 → Typed tokenizer → token、mask、marker、qtype
       → 写请求 BO 并同步到设备
       → 设置 BO 参数、启动一次完整 forward、等待
       → 同步结果回 CPU、检查身份/状态、解码答案
```

BO 是 XRT 管理的设备缓冲区。CPU 不能把普通内存指针当作 FPGA 地址；分配时用 `kernel.group_id(参数编号)` 与 xclbin 中的 HBM 连接对应。

模型分片分别上传，不复制 baseline 中的三个完整 `weights` 结构。初始化和权重上传不混入常驻请求延迟。

## 2. 输入必须保留哪些信息

下表是Host/FPGA ABI的类型。真实Typed图的attention_mask和marker_mask输入为F32；捕获保留原F32，组帧仅把恰为0.0/1.0的元素无损转成U8，硬件mask算术再精确恢复F32的0.0/1.0。其余值拒绝，不做阈值化。

| 输入 | ABI类型与形状 | 含义 |
| --- | --- | --- |
| input_ids | I32 `[B,S]` | 已分词、拼接和 padding 的 token |
| attention_mask | U8 `[B,S]` | 真实 token 为1，padding为0 |
| marker_pos | I32 `[B,16]` | 每个选项的 MASK 位置，使用 `b*S+s` 扁平索引 |
| marker_mask | U8 `[B,16]` | 有效候选为1；每题至少1个 |
| qtype | I32 `[B]` | choice=0、score=1、noul=2 |

所有16列都传入。**本ABI规范化**的无效marker指向本题CLS，即行内位置0，硬件仍计算该列再加有限mask。本次实测原生前端会把无效列填全局idx0，包括第二题；这是输入适配差异，按§7单独回放，不能把本题CLS规则写成原生事实。五题按2+2+1提交，每批重新计算 marker 的 batch 偏移，保持问题顺序。

例如 B2/S128：第二题位置7的 marker 是135。硬件不能把135直接当作固定 S_MAX=1024 工作区的物理行号，转换规则见04。

## 3. 请求与结果在 BO 中怎样摆放

首版 `io` BO 32KiB：前16KiB是请求，接下来4KiB是结果，其余预留。little-endian，张量起点64bytes对齐。

请求沿用128-byte header、5个32-byte张量目录项、之后的payload。header保存版本、B/S、request_id、generation、model/numeric/layout标识、总字节数；目录保存类型、元素数、offset和stride。精确字节合同见§6；后续共享 `laya_io.h` 及导出工具据此同源生成，不依赖C++结构体的隐式padding。

B2/S128的五个payload offset依次为320、1344、1600、1728、1792，总请求1856bytes；其中真正的张量数据1448bytes。B2/S1024的核心数据10408bytes，完整帧10816bytes，均在16KiB内。

结果包含 `[B,16]` candidate logits、`[B,2]` act logits、请求身份、错误状态与计数。结果布局和验证顺序见[14](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/14_result_status_and_verification.md)。首版依赖 `run.wait()` 和 BO 同步后读取，HLS控制寄存器由工具生成。

## 4. CPU 与 FPGA 怎样保证用的是同一个模型

导出器保存 GGUF hash、维度、量化规则和布局版本；Host 在初始化时检查完整hash，xclbin/build manifest记录同一组参数。每次请求携带匹配标签，硬件先检查合法范围再计算。

CPU 预检 token 范围、mask值、候选数及 marker 所属行；FPGA 也做必要检查，不能把非法索引转换成任意 HBM 地址。结果必须匹配 request_id/generation，状态成功后才做业务解码。超时后先确认设备已停止或恢复，再复用 BO。

## 5. 输出处理与性能测试

FPGA 已完成 act 所需的原始候选 softmax/统计；CPU 按 Typed 配置对最终候选 logits 应用温度，恢复 choice/score/noul，处理 act 概率和 action。不能用 CPU 的另一套 hard top-k 重算硬件 act 特征。

分别记录分词、组帧、H2D、kernel、D2H、解码及完整请求耗时。H2D 指主机到设备，D2H 方向相反。Host 使用高分辨率单调时钟；baseline 的生成 tokens/s 计时不能直接用作 Laya 的选择判断延迟。

联合验收时，让同一请求文件先经过 CPU 参考，再经过 XRT/FPGA，比较未舍入 logits 和最终答案。重点测 B2 marker、2+2+1拆批、错误输入、重复请求和 timeout 后的缓冲区所有权。

## 6. F0请求字节合同（本次接口细化）

状态：**推断／拟实施合同，2026-10-05由GPT-6 Astra（xhigh）定义**。字节布局在文档层确定；同源头文件、编码器和硬件尚未实现。所有多字节整数是little-endian；F32/F16为IEEE-754原位模式；禁止直接`memcpy`未声明padding的C++结构体。Host写请求时将所有对齐空隙和reserved清零。首版不接受扩展目录、任意stride或未知flags，也不定义另一条控制命令总线。

### 6.1 128-byte请求头

偏移均相对`io` BO起点；`u16/u32/u64`分别为16/32/64bit无符号整数。

| offset | bytes | 字段／类型 | F0值与检查 |
| ---: | ---: | --- | --- |
| 0 | 4 | magic／字节数组 | ASCII `LYRQ`，字节`4c 59 52 51` |
| 4 | 2 | abi_major／u16 | 1；其他值拒绝 |
| 6 | 2 | abi_minor／u16 | 0；F0只接受精确版本 |
| 8 | 2 | header_bytes／u16 | 128 |
| 10 | 2 | entry_bytes／u16 | 32 |
| 12 | 2 | tensor_count／u16 | 5 |
| 14 | 2 | flags／u16 | 0 |
| 16 | 4 | frame_bytes／u32 | 由五张量计算的64B对齐帧长度，≤16384 |
| 20 | 2 | batch／u16 | 1或2 |
| 22 | 2 | seq_len／u16 | 64、128、256、512或1024 |
| 24 | 8 | request_id／u64 | Host在当前generation内单调递增且不复用；0保留 |
| 32 | 8 | generation／u64 | Host会话/恢复世代；非0，恢复后更换 |
| 40 | 16 | model_tag／16原始字节 | GGUF SHA-256前16字节，按摘要字节序，非整数翻转 |
| 56 | 16 | numeric_tag／16原始字节 | 冻结数值合同文件SHA-256前16字节 |
| 72 | 16 | layout_tag／16原始字节 | 冻结布局manifest文件SHA-256前16字节 |
| 88 | 16 | build_tag／16原始字节 | 构建输入清单文件SHA-256前16字节，不对含自身tag的文件求hash |
| 104 | 4 | directory_offset／u32 | 128 |
| 108 | 4 | payload_offset／u32 | 320；288–319为零padding |
| 112 | 4 | result_offset／u32 | 16384 |
| 116 | 4 | result_capacity／u32 | 4096 |
| 120 | 8 | reserved／u64 | 0 |

完整hash、原文件及其准确字节数留在Host/build manifest；16字节tag用于匹配，不能代替初始化完整hash检查。当前model_tag为`6e b6 ef 58 bc 4f 99 bd 9d b4 03 81 60 41 08 af`。其余tag在相应文件真实冻结后产生；没有凭文档虚构tag值，零tag禁止用于可发布构建。numeric_tag必须区分硬件候选Q8-F和原生GGML backend，不能只因GGUF相同就共用数值身份。JSON等清单必须固定序列化后对实际文件字节求hash，接收方读取同一份文件，禁止各自重排后猜测摘要。

### 6.2 五个32-byte张量目录项

第i项从`128+32*i`开始，i=0…4。目录字段的位置如下，offset/stride均以**bytes**为单位。

| 项内offset | bytes | 字段／类型 | 语义 |
| ---: | ---: | --- | --- |
| 0 | 2 | tensor_id／u16 | 依次1、2、3、4、5，不允许重复或调换 |
| 2 | 1 | dtype／u8 | I32=1、U8=2；F32=3/F16=4保留给模型/参考，请求中拒绝 |
| 3 | 1 | rank／u8 | 前四张量2，qtype为1 |
| 4 | 4 | offset／u32 | 相对io起点的payload字节偏移，64B对齐 |
| 8 | 4 | byte_length／u32 | 紧凑有效张量字节数，不包括padding |
| 12 | 2 | dim0／u16 | B |
| 14 | 2 | dim1／u16 | S、16或rank1时的1 |
| 16 | 4 | stride0／u32 | 每个batch行的bytes；rank1为元素bytes |
| 20 | 4 | stride1／u32 | I32为4、U8为1；rank1为0 |
| 24 | 4 | element_count／u32 | B*S、16*B或B |
| 28 | 4 | reserved／u32 | 0 |

| i／tensor_id | 张量 | dtype／rank | dim1 | byte_length | stride0／stride1 |
| --- | --- | --- | ---: | --- | --- |
| 0／1 | input_ids | 1／2 | S | 4*B*S | 4*S／4 |
| 1／2 | attention_mask | 2／2 | S | B*S | S／1 |
| 2／3 | marker_pos | 1／2 | 16 | 64*B | 64／4 |
| 3／4 | marker_mask | 2／2 | 16 | 16*B | 16／1 |
| 4／5 | qtype | 1／1 | 1 | 4*B | 4／0 |

令`align64(x)=(x+63)&~63`，先以至少64bit无符号临时量防溢出。`o0=320`，`o(i+1)=align64(oi+len_i)`，`frame_bytes=align64(o4+len4)`；目录的offset必须**等于**此规范值，不能仅仅“不重叠”。各`offset+byte_length`须≤frame_bytes≤16384，结果区域固定且不得与请求相交。通过所有目录验证后才允许读取张量。

| B／S | input_ids | attention_mask | marker_pos | marker_mask | qtype | frame_bytes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2／128 | 320 | 1344 | 1600 | 1728 | 1792 | 1856 |
| 2／1024 | 320 | 8512 | 10560 | 10688 | 10752 | 10816 |

### 6.3 校验顺序与请求所有权

1. Host先核对xclbin/build/model完整身份、13 BO容量和group_id；本session只能有一个run占用这组IO/工作区。Host对初始化模型BO只读复用。
2. kernel仅从固定io前128bytes取头，按magic/version/固定尺寸/flags/reserved→tag→B/S→frame/固定区域→五目录项顺序校验。任何未验证offset都不得用于访问。身份合法性与结果回显规则见14§9。
3. 验证全部input_ids为`0…50367`；所有attention_mask/marker_mask只能为0或1；qtype只能为0/1/2。每题至少一个有效token和一个有效候选。padding token仍正常查表，不自动清零hidden。
4. 对题b的每个有效marker要求`b*S ≤ idx < (b+1)*S`且对应attention_mask=1；无效marker必须等于`b*S`（本题CLS），仍参与scorer再施加mask。不额外强制连续mask、marker排序或唯一性；重复有效marker依真实输入语义允许。
5. 全部请求输入通过检查后，锁存到请求上下文／专用小数组或保持原IO只读；从任务开始到结果同步结束Host不得改写请求、模型或工作区。所有非法索引在换算HBM地址前报错。
6. 无显式硬件取消通道。超时由XRT/Host记录；先确认run已终止或完成平台恢复，再释放BO、更换generation并重建缓存有效状态。重复request_id不得用于新请求，避免旧结果被接纳。

静态校验错误按上述扫描顺序报告第一个；张量内部按batch、行、列升序。错误码和细节格式统一见14§9。字节协议未添加CRC；文件/模型身份用hash，运行传输依赖平台，不能把这点解释为能自动检测所有位翻转。

## 7. 本次真实请求和ABI回放样例

2026-10-05已实际执行固定Typed Q8的原生GGML CPU参考，源码commit `dcc300def5c5bc8fa778223589244abb0555a5de`，单线程；运行对象、插桩、二进制hash和数据hash以各manifest为准。五个原生输入节点为ir_211…ir_215，顺序与本ABI五张量相同；masks为F32。两套输入和期望**分别保存**：

| profile | 真实输入／转换 | 使用的输出 |
| --- | --- | --- |
| [original_native](../../reference/runs/typed_q8_ref_20261005/original_native/manifest.json) | 原生tokenizer产生B2/S94，qtype[2,0]；第一题marker23/33，第二题113/129/140；无效marker为全局0 | 原生S94整图实际输出，不作为S128所有列期望 |
| [abi_replay](../../reference/runs/typed_q8_ref_20261005/abi_replay/manifest.json) | 同一业务输入补PAD50283和mask0到S128；第二题有效marker改147/163/174，无效列改128；masks仅0/1转U8用于帧 | 用适配后输入再次执行同一原生模型，保留完整16列candidate及2列act |

[request_v1.bin](../../reference/runs/typed_q8_ref_20261005/abi_replay/request_v1.bin)为1856bytes，五payload起点320/1344/1600/1728/1792；五输入解包与对应ABI数组逐字节一致。其numeric/layout/build tag为零占位，只是`reference-only; production-ineligible`格式fixture，**必须被生产kernel的身份校验拒绝**；没有xclbin或硬件冻结清单时不伪造可运行tag。

[fixture_metadata](../../reference/runs/typed_q8_ref_20261005/abi_replay/fixture_metadata.json)记录这次profile对比：有效candidate及act raw logits逐位相同；部门题无效candidate mask后最大差0.2529296875。因此不能宣称规范化前后全部输出相同，也不能在TB里只比较有效选项后跳过其余列。此结果只证明当前两题，其他请求仍需对应profile全图运行。
