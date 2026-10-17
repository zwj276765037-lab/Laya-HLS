# 04 模型和中间结果放在哪里

统一规格 v1.0 · 2026-10-05。当前为文档设计，Laya HLS/RTL、综合与上板均未完成。

对应 baseline 的 `ModelWeights_t`、Host BO和HBM布局。参考 [权重结构](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/src/typedefs.h:74) 与 [Host分配/上传](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Tiny-llama-baseline/host/llama2.cpp:409)。Laya采用单份模型分片，避免原Host把整个权重结构复制三次。

## 规格状态与来源

正文保留设计细节；下表区分模型/源码事实与拟实施方案。来源编号S、用户要求U及缺口G见[00 总体规格与来源](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/00_overall_design.md)。时钟/复位见[02 平台与时钟复位](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/02_kernel_wrapper_and_platform.md)，流与缓存交接统一见[15 共同接口与流水](/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline/vivado/design_source/15_integration_interfaces_and_pipeline.md)。

| 项目 | 目标要求 | 工程现状（如相关） | 状态 | 来源 |
| --- | --- | --- | --- | --- |
| 模型身份 | Typed Q8_0，455179648bytes，SHA-256见本文§2 | 本次重新计算文件hash，与记录一致 | 工程事实 | S1/S6 |
| 实际模型类型 | Group32/FP16 scale；保留F16/F32例外和bias顺序 | GGUF及既有解析记录可查 | 工程事实 | S1/S3 |
| 存储方案 | 模型512MiB、workspace192MiB；布局与BO见本文 | 是预算和地址规划，尚未分配实际BO | 推断 | S3；02 |
| 地址语义 | 输入b*S+s转换到S_MAX步长；QKV按head奇偶分片 | 前者是请求语义衔接；后者是新增物理布局 | 推断 | 本文§4；01、10、13 |
| 导出/布局缺口 | §7定义工作区offset／寻址，模型offset须真实导出与逆重排校验 | 原生参考已采集；硬件模型导出器／布局头未实现 | 待确认 | G2/G3；本文§2、§7 |

## 1. 先区分三种存储

| 存储 | 内容 | 谁管理 |
| --- | --- | --- |
| 主机内存/磁盘 | GGUF、tokenizer、请求、模型包及参考输出 | CPU |
| U55C HBM | 全部模型权重和大部分中间结果 | CPU初始化，FPGA执行时读取/更新 |
| FPGA片上BRAM/URAM | 当前矩阵权重、输入tile、部分和、当前head的KV等 | HLS计算模块与加载器 |

GGUF有效模型payload去掉可由逻辑生成的slide_bias表后为448,921,352bytes。按512MiB预算分配模型BO，另给工作区192MiB；这只是容量规划，实际每个bank仍需核查。

## 2. 模型怎样从GGUF变成硬件可读数据

离线导出器读取冻结的Typed Q8文件，保留q/FP16 scale/F16/F32权重、bias、RoPE和常量的原位模式。它同时生成：

- 分片数据文件，供Host上传；
- manifest，记录hash、shape、类型、字节数和布局版本；
- `laya_model_layout.h`，记录各矩阵在各BO中的offset及bias阶段，供Host/HLS共用。

首版不让FPGA解析GGUF或通用动态tensor描述表。网络结构固定，尺寸与地址由同一导出结果生成，硬件只按已校验的表访问。

源模型SHA-256为 `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`。重排后要能逆变换回全部逻辑q/scale字节；不能从FP模型重新量化后仍使用这个模型身份。

## 3. HBM中的分区

具体master和bank见02；以下是每个BO的容量起点，不是每次请求都要传输的大小。

| BO | 预算 | 放什么 |
| --- | ---: | --- |
| embedding | 64MiB | token/type embedding，实际54,803,648bytes |
| w_q0 / w_q1 | 各192MiB | Linear的q分片，逻辑合计369,361,408bytes |
| w_scale | 32MiB | Linear scales，逻辑23,085,088bytes |
| aux | 8MiB | 浮点尾层、bias、RoPE、模型头等 |
| io | 32KiB | 请求16KiB、结果4KiB和预留 |
| state0 / state1 | 各32MiB | hidden ping/pong、norm、residual、markers |
| qkv0 / qkv1 | 各16MiB | QKV两个head分片，每片最大12MiB |
| ff0 / ff1 | 48 / 24MiB | Wi 41MiB / gate 20.5MiB；Decision FF复用Wi区 |
| att_out | 16MiB | 最大8MiB的attention输出 |

模型BO预算合计488MiB，剩余留在512MiB总预算内。工作区BO（不含模型）合计184MiB加io，留在192MiB预算内。

主要张量逻辑容量是125.625MiB：四份8MiB hidden类张量、24MiB QKV、8MiB attention输出、41MiB Wi、20.5MiB gate、0.125MiB markers。Decision FF的32MiB在Encoder结束后复用Wi空间，不重复相加。

## 4. 两个最容易读错的地址

**hidden：输入是紧凑S步长，工作区采用固定S_MAX=1024步长。**

```text
Host marker: idx = b*S+s
先恢复 b=idx//S、s=idx%S
hidden byte offset = ((b*1024+s)*1024+d)*4
```

例如第二题CLS在B2/S128输入中的idx是128，工作区物理行却是1024。这一转换必须由gather和参考程序共用。

**QKV：Linear按token输出，attention按head读取。** 为便于连续读K/V，将head奇偶分给两个BO：

```text
shard = head % 2
local_head = head // 2
plane = 0(Q)、1(K)、2(V)
offset = ((((plane*2+b)*8+local_head)*1024+s)*64+d)*4
```

每片形状为 `[3,2,8,1024,64]` F32。一个head只从其中一片读取，不能把两片端口带宽相加给同一个head。RoPE散写与attention读取必须用同一地址函数。

## 5. Q8权重怎样分片和复用

一个输入组为32个S8加一个FP16 scale。Linear逻辑权重为 `[N,K]`；每8个输出组成一个输出tile，偶数tile放q0，奇数tile放q1。scale按完整输出tile顺序单独保存。片上加载后可按group外层访问，位置可以变，q/scale值不能变。

embedding保留原始34-byte组格式，每1024维行1088bytes。act第二层只有2个输出，物理pad到8列，其余lane无效；act第一层是F16 `[256,1028]`，不能补成另一维度后改量化。

bias要区分Linear结束后加的bias和GELU前另加的bias。scorer的baked bias与原bias是两次浮点加法，导出表不能合并。

## 6. 谁可以覆盖一块缓存

旧hidden在residual读取完前不可覆盖；QKV在本层attention结束前不可作为下一层的输出；Wi区在最后一层Encoder不再读取后才能改成Decision FF布局。每块片上缓存也必须经历“空闲→填充→可读→计算/排出→空闲”。

地址生成器要先检查范围再访问，单位明确为bytes或elements。联合测试覆盖最后一个head/plane、B2、S<1024、N2尾部和Wi/Decision复用；导出器、CPU参考和HLS使用同一套布局测试向量。

## 7. F0固定工作区、BufferRef和模型绑定

本节细化地址合同（推断／拟实施）；不改变02的13参数顺序或BO预算。所有逻辑byte offset使用u32，地址加法／范围检查在u64临时量上完成；实际AXI地址宽度仍由生成接口决定。BufferRef仅引用以下枚举和合法bank，不接纳Host传入的任意地址或通用view。epoch/所有权见15§11。

| buffer_id | 名称／合法bank | BO与固定base（bytes） | 规范形状／布局 |
| ---: | --- | --- | --- |
| 0 | NONE／0 | 无地址 | 仅表示未使用参数 |
| 1 | HIDDEN／0、1 | bank0=state0+0；bank1=state1+0 | F32[2,1024,1024]，每bank8MiB |
| 2 | NORM／0 | state0+8388608 | F32[2,1024,1024]，8MiB |
| 3 | TMP／0 | state1+8388608 | F32[2,1024,1024]，8MiB，投影/residual临时值 |
| 4 | MARKER／0 | state0+16777216 | F32[2,16,1024]，131072bytes |
| 5 | QKV／0、1 | qkv0/1+0，bank是head shard | §4的F32[3,2,8,1024,64]，每片12MiB |
| 6 | WI／0 | ff0+0 | F32[2,1024,5248]，41MiB |
| 7 | GATE／0 | ff1+0 | F32[2,1024,2624]，20.5MiB |
| 8 | ATT_OUT／0 | att_out+0 | F32[2,1024,1024]，8MiB，d=head*64+feature |
| 9 | DEC_FF／0 | ff0+0，别名WI | F32[2,1024,4096]，32MiB；Encoder WI已释放才可使用 |
| 10 | HEAD_WORK／0 | state1+16777216 | 262144bytes，以下固定子区 |
| 11 | TYPE_ROWS／0 | state0+16908288 | F32[3,1024]，12288bytes；只用于当前模型type行 |

HEAD_WORK内固定子区均以bytes为单位：SCORER_ACT=0（F32[2,16,1024]，131072B）、ACT_INPUT=131072（F32[2,1028]，8224B）、ACT_HIDDEN=139328（F32[2,256]，2048B）、CAND_MASKED=141376（F32[2,16]，128B）、ACT_LOGITS=141504（预留64B）、STATS=141568（F32[2,4]，预留64B）、CAND_PROB=141632（F32[2,16]，128B）、CAND_RAW=141760（F32[2,16]，128B）。子区用`head_region:u8`枚举0…7按此顺序选择，禁止字节偏移代替枚举。对应数据互不覆盖；其余HEAD_WORK为预留，不参与计算。

普通二维行访问由任务row_space确定：TOKEN=0时row=b*1024+s；MARKER=1时row=b*16+c；BATCH=2时row=b。不接受任意K/N，各任务尺寸在15表固定（act K=1028）。所有tensor实际合法区只覆盖B和S，S…1023物理padding绝不读取或参与求和。token输入的pad行s<S仍合法并执行。

### 7.1 Q8矩阵导出寻址

W逻辑[N,K]，K∈{256,1024,2624,4096}且G=K/32；`t=n//8, lane=n%8, g=k//32, j=k%32, shard=t%2, local_t=t//2`。每个矩阵在q0/q1/scale各有独立64B对齐base，由真实导出器生成并校验容量：

```text
q byte     = q_base[shard] + (((local_t*G+g)*8+lane)*32+j)
scale byte = scale_base    + ((t*G+g)*8+lane)*2
```

尾tile物理pad到8输出，q和scale填0；只计算n<N，act N=2不能加出6个输出。导出器保存每个tensor的源GGUF name、type、[N,K]、完整源payload hash和以上三个base/span；逐项逆重排比对真实q/scale，不重新量化。Q8_0源组是`FP16 d`随后32个S8；embedding原34B格式保持。模型只读表按`WeightKey{family:u8, layer:u8}`索引：family=1 Encoder QKV、2 Wo、3 Wi、4 down（layer0…27）；5 Decision QKV、6 Wo、7 FC1、8 FC2（layer0…1）；9 scorer FC1、10 scorer FC2、11 act FC1、12 act FC2（layer=255）。非Q8的family10/11禁止访问q/scale BO，走aux F32/F16原格式。

固定工作区base在本文确定；模型base必须由实际153张量的导出结果给出，不凭容量估算伪造。这不会引入动态Host描述表：导出结果生成编译时只读表，Host上传的数据与xclbin绑定同一layout_tag。每次实际读取验证已选descriptor的dtype/K/N/span与算子匹配，非法family/layer在HBM访问前拒绝。

### 7.2 别名与地址联合用例

HIDDEN bank以controller角色交换；NORM和TMP固定子区，不能交换BO名称来暗改base。WI与DEC_FF共享物理区及同一占用锁，即使buffer_id不同也禁止同时有效；QKV bank表示shard，不能当作两个可交替的完整QKV矩阵。RoPE原地更新Q/K时锁住相应整层QKV，raw→final状态转换后attention才能读取。

TB以真实请求和GGUF块验证B2/S128的marker135映射到b1/s7/物理row1031；再覆盖最后token/维度、QKV plane2/head15/b1/s1023/d63、WI末字节、act K1028/N2、所有base+span边界与地址溢出。随机返回延迟只改变时间，不改变期望地址或数值。
