# LNREF0：enc0 LN_FFN 独立输入闭合与只读接点

2026-10-14；M004/SM005/E005/R001；A002。执行 [D-M004-LN-FFN-SOURCE-01](../../../../../../mission/ln_ffn_reference_source_stage_20261014.md)。本轮是主机独立参考前缀，**没有运行 LN DUT、HLS、RTL 或整体控制器**。新参考只读取原 ABI 五输入及 GGUF 权重；旧 DUT capture 和 AT035 冻结源只在前向结束后用于比较。

## 限定结论

AT038 得到原 request3/generation1、B1/S128、enc0、batch0 的 attention residual 及随后 LN_FFN。保留完整 128-token Attention 依赖，在原 `full_reference.py` 不变的 `full_forward_graph` 中，仅观察第 2 次 `layernorm_many` 调用（第 1 次为 embedding LN），先按原函数算出输出，再有意结束前缀。原参考 SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`；不复制或重写数学图。

| 新冻结数组 | 字节数 | SHA-256 |
| --- | ---: | --- |
| enc0 LN_FFN 前 residual，完整 128×1024 F32 | 524288 | `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8` |
| 同一 residual 前四行 | 16384 | `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9` |
| 独立 LN_FFN 输出，完整 128×1024 F32 | 524288 | `6761099e9ea790f701458c8817c8f01f5de8339f4371beceab3870d8c17e5863` |
| 同一 LN 输出前四行 | 16384 | `658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883` |

四份均为 little-endian F32、形状和 finite 检查通过；四行文件是对应完整文件的前 16384B。独立 LN 输出与旧完整 DUT 源 BO 观察的 131072 个 F32 **逐位差 0**，与 AT035 冻结外部源前四行 4096 个 F32 **逐位差 0**，首差均为 null。独立 `quantize_many` 对新四行所得 q4096B SHA `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`、scale256B SHA `4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`，均与原独立期望一致。旧完整 capture 的角色始终是待比较观察，不是参考输入。

原 B1 ABI 帧 1152B、SHA `fe82a8ef6c73e1202eae912a8b49414633d6ec9d8c20d0e8967c8a8568cb1db7`；从包头核 B1/S128、request_id3/generation1，并核四个 16B 模型/数值/布局/构建 tag 与原 identity manifest 一致。五输入从原独立 Evidence B2 捕获及 `single_request(inputs,0)` 获得，与 B1 帧五 payload 逐字节一致；SHA/字节数见 [AT038 原报告](../attempts/AT038_LNREF0_reference_prefix_02/output/ln_ffn_reference_report.json)。GGUF 实际 455179648B，SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；本前缀实际读取 tok_emb、emb_norm、四个 RoPE 表和 enc0 qkv/wo 八个权重段，段 offset、尺寸及 SHA 在同报告。冻结 libm C 源按原参数编译并对 expf/tanhf/logf 做 batch/标量逐位自检。参考初次真实前缀 2.964s；guard 3.225s、peak owned RSS 106568KiB、child0/trigger null；1 条实际 policy 为 CPU0–3/nice19/idle，MemAvailable 最低 448408064KiB。它是主机工具成本，不是 RTL 周期或新接链成本。

AT037 先因 guard 切换工作目录使相对 runner 路径无法启动；用绝对路径后的原封装把 ABI 的 16B package tags 错当完整 GGUF SHA，1.425s 后 `FAIL_WRAPPER`，参考计算尚未开始。AT038 唯一有因封装修正改为按原请求 identity manifest 分别核四个 tag，原数学、五输入及模型不变；[差异](../attempts/AT038_LNREF0_reference_prefix_02/runner.diff)与 AT037 两个原失败 guard/日志/收据均保留。

## source → LN → QAR0 只读映射

| 接点 | 已核事实 | 下一实际连接缺口 |
| --- | --- | --- |
| LN 输入 | 新独立 residual 前四行 16384B；原生产逻辑应在 enc0 WO 加 hidden 后持有 `HIDDEN` 的 batch0/row0–3，F32 4096B/行。 | 新参考只是独立 gold；硬件必须从真实前级算术/存储读取，不能把本文件当作生产前级输出。有限 LN 回放可暂以此文件作明确声明的外部源。 |
| 原 LN 核身份 | E003 冻结 `layernorm_producer_engine.cpp` SHA `b2943beba13e831a17fd181c96e00315659975f60596a7f72f715ecd5de23706`，支持 LN_FFN 与 stage2、gamma0、HIDDEN→NORM；codec 允许 rows1–16、D1024、eps bits `0x3727c5ac`、4096B 行步长。LQ0 冻结原 baseline 核 71 `.v`、7 `.dat`、5 Tcl 共83项逐SHA/bytes一致；top `.v` SHA `b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798`。 | LQ0 外层 fixture 固定 LN_ATTN `0x11`、stage2/layer1、16行的生成身份；必须派生 LN_FFN `0x12`、stage2/layer0、batch0/row0、rows4、gamma0及完整 request/model/context 绑定。内核可复用的静态支持不等于该四行 RTL 已测，也不预签无需重新 HLS 生成。 |
| 真实 LN 地址/债务 | 原核 source `HIDDEN` 为 STATE0 或 STATE1，逻辑 offset `(batch×1024+row0)×4096`；`NORM` 固定 STATE0 offset `8MiB+同一行偏移`。本四行对应 source offset0–16383、destination 8388608–8404991，均在原 STATE0 16920576B 容量内。每行真实 64×512bit R/64×512bit W，HLS `issued_store_bytes` 只是提交，不代表物理 B。 | 用实际 AXI AR/R、AW/W/B 与源租约/读债闭合；最终 B 后经原唯一存储权威发布，再将完成包与 source release 绑定。不可因诊断只用四行而缩小 BO 容量或伪造 publish。 |
| QAR0 入口 | AT035 的 external-Q 为 QUANT `0x20`、K1024、rows4、4096B 行距；外部 F32 当前在 DDR `0x100050000` 的 16384B，只读源 region 和独立 393216B 诊断 DDR。其 TB 目前把 `ext_quant_source_published` 常量置1，并由 TB 提供 owner admission。 | 将 LN 的 `STATE0/NORM +8MiB` 真实地址映射到 Q 读取区域，或经等价合法别名适配；保持原 BO 声明和不冲突的稀疏 DDR 地址。把发布/owner 信号改接真实 LN store/末B/lease 权威，不以现有 TB 常量代替。Q 仍必须实际 AR/R 重读，保持 G 优先共享入口、响应/epoch/读债及后续 Wi→G→Down 同一硬件。 |

生成清单及接口文件的逐SHA结果在 [verification.json](../attempts/AT038_LNREF0_reference_prefix_02/verification.json)。AT038 原 [receipt.json](../attempts/AT038_LNREF0_reference_prefix_02/receipt.json)、[命令](../attempts/AT038_LNREF0_reference_prefix_02/command.json)、[guard](../attempts/AT038_LNREF0_reference_prefix_02/guard/guard_result.json) 和 [独立输出](../attempts/AT038_LNREF0_reference_prefix_02/output/enc0_residual_full128.f32.bin) 已冻结。原 LQ0 RTL 735.843s、AT035 全链 RTL 1782.006s是不同入口，不能相加预测 LN→Q 接链；新 static/pilot/full、联合资源和物理时序仍 UNKNOWN。LNREF0 仅闭合独立数值源，真实 LN producer、FFN residual、全请求/恢复、M003/M004仍未完成。
