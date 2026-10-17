# LNQI0：LN 与 QAR0 共同包、权重和接口预检

2026-10-14；D-M004-LN-QAR-IDENTITY-01；SM005/E005/R001；A002。结论 **PASS_HOST_ONLY**：当前 production-v2 canonical 包的 Wi/Down 数学载荷与 AT035 冻结载荷逐字节兼容，可以为下一有限连接建立可复算的身份适配；**LN→QAR0 同 runtime RTL NOT_RUN**。本轮未修改 DUT、LN 生成物、gold、原收据或生产控制，也未启动 RTL/HLS/OOC/P&R。

## 原始运行与输入

[AT041 收据](../attempts/AT041_LNQI0_identity_preflight_01/receipt.json)、[输入身份](../attempts/AT041_LNQI0_identity_preflight_01/input_manifest.json)、[机读结果](../attempts/AT041_LNQI0_identity_preflight_01/result/report.json)、[冻结脚本](../attempts/AT041_LNQI0_identity_preflight_01/frozen/ln_qar_identity_preflight.py)包含复算路径、bytes/SHA 和输出。原第一次 guard 指向 `model-cpu-embedding-ln-v4`，其 manifest 没有 Q8S2 `candidate_schema`，child1/0.229s；这是封装选包错误，未比较载荷。保留原失败和日志；将参数纠正为 AT035 真正使用的 `model-q8-session-v2-actual-r2-20261010` 后，同一冻结脚本完成，child0/trigger null，4.965s、peak 45100KiB，CPU0–3/nice19/idle 一条实际 policy 合规，最小 MemAvailable 448494580KiB。28 个当前输入文件引用及 11 个生成 fixture 的 bytes/SHA 重新核对；主机执行帽 8GiB/120s 未触及。

源 GGUF 455179648B/SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`，两 manifest 的 GGUF/模型与数值 tag 相同。canonical 包共有 153 tensor/124 weight 描述；五 BO 的原文件 bytes/SHA 已逐个读取，embedding/q0/q1/scale 四个完整 BO 与 Q8S2 包逐字节相同。AUX 容量 1671872B，128B 后全体相同；128B 头仅 layout/build 的 32B 改变。不能把 AUX 的不同头误判为权重数值不同，也不能跳过其真实读回检查。

## 416B 身份与消费者

| 字节位置 | LN canonical `L13M` | AT035 strict W 的 Q8S2 binding | 差异性质 / 消费 |
| --- | --- | --- | --- |
| 0–31 | model/numeric tag | 同值 | 同一 GGUF 与数值口径；不能单凭此前缀通过整包。 |
| 32–63 | layout `f9278816…` / build `23c62cd4…` | layout `2d848b5f…` / build `7209eb09…` | schema/build 差异；AUX 头对应 32B 同样不同。 |
| 64–127 | `L13M` magic、version1、416B、源摘要及 BO 计数/粒度 | strict profile@64 为 0、generation@72 非零、验证/manifest 摘要等 | 两种编码；原 `L13M` 的 @64 非零，会被 `t4_dual_w_cache_v1.command_ok` 拒绝。 |
| 128–207 | 五项 16B role/flags/BO size | 构建摘要、GGUF SHA、binding 元信息的一部分 | 编码不同，不能挪用偏移。 |
| 208–255 | 保留 0 | GGUF 摘要尾、5 项 32B binding 的 count/stride 等 | 编码不同。 |
| 256–415 | 保留 0 | 五项 role/flags/base/size/cookie，各 32B | W 需要真实 BO 地址、容量及非零 cookie；AT035 的旧 base/cookie 仅诊断值。 |

两种原 416B 有 **233** 个字节不同；原 SHA 和新诊断 W-wire SHA 见机读结果。LN hub 的 `l13m_structure_ok`、`l13m_canonical_ok` 要求 canonical **全 416B**，且与 NumericIdentity tag 交叉核对；source query 与所保存 owner model 做完整 416B 相等。W cache 只在 `command_ok` 静态检查 profile@64=0、generation@72≠0，并把输入完整 416B 保存、按完整值比较 lease/read/return；它并未实现把 L13M 解码为 Q8S2。AXI aux header 在严格三口加载中仍须真实读取、与指定 canonical 128B 比较。AT041 产生的 Q8S2 诊断编码保留 canonical 四 tag、填入已核包/源摘要，但沿用 AT035 的 BO base/cookie；其 host 验证摘要不是硬件的 Q8S2 注册/认证，**不能直接充当 live BO binding**。下一 RTL 接点应同时保留 hub 的 L13M 原值和经过明确、逐字段核对的 W 方言值，不得把任一全局替换为另一种。

## Wi/Down 实际字节

从 canonical manifest/header 的 enc0 原描述符提取，GGUF tensor 原区间/SHA 也在读取后与 manifest 相等。原物理布局为 `tile=n//8, lane=n%8, shard=tile%2, local_tile=tile//2, q_offset=((local_tile*G+g)*8+lane)*32, scale_offset=((tile*G+g)*8+lane)*2`，`G=K/32,T=ceil(N/8)`；两矩阵 `bias_kind=0`、`bias_span=aux_span=0`，AT035 严格 W config 的全部范围/组数/偏置字段与 canonical 描述符相等。

| 矩阵 | K/N | q0、q1 BO offset/bytes | scale BO offset/bytes | 与 AT035 冻结 hex |
| --- | --- | --- | --- | --- |
| enc0 Wi | 1024/5248 | 各 58720256 / 2686976 | 7340032 / 335872 | 三段均逐字节相同 |
| enc0 Down | 2624/1024 | 各 133955584 / 1343488 | 16744448 / 167936 | 三段均逐字节相同 |

六段的各自 SHA、GGUF offset/bytes/SHA、生成 fixture SHA 和所有 BO 容量在[机读结果](../attempts/AT041_LNQI0_identity_preflight_01/result/report.json)。新 `fixtures/` 是从当前 canonical BO 提取，不从 DUT 结果倒造；它们与 AT035 hex 逐字节一致，因此无权重重排需求，也不改原 PS/输出 gold。旧 payload 可复用的前提是下一链仍作真实 W 三口 AXI 供数和 lease 验证。

## 唯一量化器的有限接点表

| 值 / 事件 | 真实来源和需保存的关系 | 下一 RTL 必须验证 |
| --- | --- | --- |
| P / model / 窗口 | AT040 LN producer 的 request3/generation1、B1/S128、batch0/row0/rows4，canonical L13M，STATE0 `0x300000000` 的 HIDDEN→NORM offset `0x800000`，LN 最后 B、END、PUBLISH；hub 保存 P、完整 model、Ref、窗口与原 producer Context。 | 保留 AT040 producer/monitor/hub，不能保留其独立 Q/fullA；AT035 的单 `quant_task`/dualA 接真正 NORM 存储。原 STATE0 容量 16920576B，不把 `0x300800000` 偷换成 AT035 预装源 `0x100050000`。 |
| Q 接受 / grant | 适配器从同一待接 external Q 命令构造完整 portal packet，显式提供 L13M、P/Q/L、所有 Ref、source role/offset/span/stride、rows/K、独立单调 portal generation；Q 上 P=LN_FFN `0x12`、Q=QUANT `0x20`，Wi L=`0x32`。 | G 优先双 valid 时 external 不得提前 query/占 lease；被选中的 external Q 在同一受理边沿同时获得 `source_query_ready && granted` 与后段 `quant_task.cfg_ready`。若做有界暂存，必须定义接受点及唯一拒绝/释放；不能接常量 published/owner/grant。AT035 ext 口缺 L13M 与 portal generation，需真实保存并传递。 |
| 拒绝 / 活动 / 释放 | hub 在首次 grant 保存完整 lease key 与 generation 高水位；桥维持 external ownership 至真实拒绝或响应消费。 | 无 grant 或 command 不合法只拒绝一次、零 AXI；活动中另一入口等待且响应不串。Q 响应消费且真实 R 债退休后，按保存的完整原 key 作 drained release；fullA 另按其自身读债和 release 合同排空。不能用 reset 清理正常债务或降低高水位。 |
| W 与后续链 | canonical BO 数据与 AT035 完全同字节，但 strict W 要 Q8S2 方言及真实 BO base/cookie；原 Wi/GATE/Down 的 `0x100000000` 诊断 DDR 区需与 STATE0 独立、不重叠。 | 单矩阵引擎/dualW/dualA，Wi 先使用 epoch1；真实 Wi 存储读回→G/GATE 量化→Down 使用 epoch2，仅在前一租约与读债排空后切换。两次 Q 共用一个量化器。 |

新组合需先冻结适配字段与各 BO live 映射，static 核编译/结构和双 valid；≤120s pilot 以真实 LN 最后 B→发布→external Q grant/首 AR/R 与第一个 Wi W 前缀为界；有据估计可在 3600s 内才跑一次四行 full，检查 LN/Q/Wi/G/Down 全原独立 gold、最终 DDR 有效区/保护字节、两段末 B/lease/消费和拒绝竞争。AT040 full 195.557s 与 AT035 full 1782.006s 是不同运行的工具耗时，**不能相加作为新准入保证**；新共址存储、适配和 guard 速率未知，full 成本仍 UNKNOWN，须据实测 pilot 估计。此处只是后继验收清单，非本轮已通过项目。

未闭合：Q8S2 真实 BO binding/cookie 的具体适配 RTL、同边沿 query/grant、单套后段与新共享存储、AT035 G 优先竞争在新链的定向回放。上游 Attention/WO/residual、FFN residual、普通逐窗口 P/Q/L 全类、生产 13BO、完整请求/恢复、联合资源及物理时序均未验，M003/M004 继续开放。
