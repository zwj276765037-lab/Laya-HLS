# FFREF0：enc0 FFN 末残差独立数据与有限 RTL 接点

2026-10-14；D-M004-FFN-RESIDUAL-SOURCE-01；SM005/E005/R001；A002。**AT050 PASS_SCOPED_HOST_REFERENCE**。本轮仅一次 4.220971s 的 guarded 主机前缀；没有运行 DUT、HLS、RTL、OOC、P&R 或长链，末残差硬件仍 NOT_RUN。

原 `full_reference.py` SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784` 未改。新冻结 [观察封装](../attempts/AT050_FFREF0_reference_01/frozen/tests/ffn_residual_reference_prefix.py) 只记录原图第 770/777 行两次 `add` 的输入/返回、第二次 LN 输出及原 `encoder_00_out` checkpoint，然后结束；[逐行差异](../attempts/AT050_FFREF0_reference_01/runner.diff)和原完整 S128 Attention、Wi/Down K/N、GEGLU/量化运算保持。输入仍为原 request3/generation1/B1/S128 五 ABI payload 与 GGUF；旧 AT038/AT049/独立 oracle 在计算后才读入比较。模型455179648B SHA `6eb6ef58bc4f99bd9db40381604108af782ffc314aa00da6641f429991ca1f18`；来源包四 tag/帧、19 个冻结与外部文件引用均核 bytes/SHA。

| 原图值；B1/S128 enc0 | 完整 128×1024 F32，524288B SHA-256 | batch0/row0–3，16384B SHA-256 | 直接比较 |
| --- | --- | --- | --- |
| skip = attention residual = LN_FFN 输入 = 末加左项 | `bac04c09e6356fda7deb27c1889aaaccd803dca33bce87c3c92a6203e43482d8` | `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9` | AT038 完整/四行各 0/131072、0/4096 个 F32 bit 差；同次末加左项与 LN 输入逐位相同。 |
| Down = `mlp_wo.0.weight` 的 Q8 输出 = 末加右项 | `5497116451dc5ae6d55be2f8fbe01f84db51cb6bd60e77f6ae5fcc351dadfba2` | `4071d238f75711bf809dc06aaba5de3f364692419a07a38f7157910456b592b0` | AT049 冻结 `a/output.mem` 按每词小端解码，以及原独立 Down binary，均 0/4096 bit 差。完整 Down 是本次新捕获，旧 oracle 未单独存它。 |
| `add(skip,Down)` 后 `encoder_00_out` | `9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b` | `c5b1310dbfb8c392974b033d9a229807df92745f22ae97470fa8eb4d84bc3a0a` | 原独立 `B1_from_b0_S128/encoder_00_out` 完整 0/131072 bit 差；四行与其真实前缀 0/4096 bit 差。 |

另外 LN_FFN 完整/四行 SHA 与 AT038 各逐位一致。六个主要数组均 finite；原 checkpoint 回调确认捕获的末加结果逐位相同。原图 `add` 用 `np.add(...,dtype=np.float32)`，Down Q8 调用无 bias，生产任务要求 `src0=TMP/Down`、`src1=HIDDEN/skip`、`dst=HIDDEN` **另一 bank**、op `0x62`、stage2、bias_id65535。AT049 对原独立 Down fixture 的数值、末B/消费与下游终扫已通过；本次补足它与原完整图 Down 中间值的直接四行逐位关系，不把主机输出冒充新增 RTL 结果。

## 下一有限双源 RTL 方案（仅设计）

加法核身份补证见 [FFREF0 FADD XCI 对照](FFREF0_fadd_identity_addendum_20261014.md)：下表旧 XCI 是方案来源，不是 AT049 同 runtime 的实际 XCI；后者 SHA 为 `244d6ab50960499221348b32698d57613d5934b9643188baf4b88e1c93e8f430`。两份参数相等但文件不相同；旧矩阵 `aclken=1` 不能代签新残差 lane 的 CE 保持。

| 接点 | 唯一选择与可证伪边界 |
| --- | --- |
| 两个实读源 | 保留 AT049 一套 LN/Q/矩阵/W 路径。外部 enc0 residual 四行作为**声明的输入边界**，在 LN 读取后仍由同一实际 HIDDEN/STATE0 bank0 offset0–16383 存储及读租约保护，供末加第二 AXI AR/R 重读；不能把现 `source_mem` 自动称为已发布的生产 HIDDEN。Down 的 TMP/role3 epoch1 目前真实写在诊断 DDR `0x100040000`、256 AW/W/B；末B、局部发布及完成消费后，第一 AXI AR/R 从这份实写字节重读。该诊断地址须经明确的 TMP→DDR 有界映射；生产目标是 `STATE1+8MiB` TMP，须另核真实 BO 表及 writer 绑定，不能仅换标签。各源四行各 256×512bit R，完整 Ref/model/request3/generation1/B1S128/row0–3 与读债匹配。 |
| 算术和流控 | 选择冻结 `tm1tn8_fadd_ip.xci`（SHA `de95586f7d41fb4832329bf22952bc8321743629543d7b353a2ae05fcc16f92c`）的 Single/Add、11 拍、rate1、`aclk/aclken/aresetn`、双 `tvalid`/32bit 输入和结果 `tvalid`；既有 `tm4tn8_fp_restore_v1.sv`（SHA `c24b5a801b860c4a7e3eb474b941970704b3c416025d9fa9527f958c67028858`）实例如第 109 行。一个新增受控 F32 add lane，按行列顺序把两源 64B beat 配对、16 个元素逐拍送入；预留 11 拍在途 credit，结果按原序装成 64B。背压用 IP `aclken` 联同索引/流水冻结，输出 FIFO 需容纳已受理结果，不丢 `tvalid`。算术原 C `fp_add_bits` 及本次独立 gold 是下一 RTL 逐位验收标准；旧矩阵 PS 中使用同 IP **不能代签残差单核数值**，当前还没有该新实例的资源或时序结果。 |
| 真实写回/owner | 选择一个有限残差 AXI512 writer/pack，不把 KB1 的 416bit TN8 packet/PS writer 当通用 F32 writer；可借其已验证的 AW/W/B 保持和 last-B 退休规则，但必须新接 64B pack、整拍 WSTRB 与 4×4096B 行。输出 HIDDEN bank1/STATE1 offset0–16383，保留原 STATE1 16919104B 容量；旧 HIDDEN bank0 不原地覆盖。目标 epoch 取原 owner 的合法 fresh 值，不能沿用矩阵 epoch2 冒充 HIDDEN 身份。至少核4 AW/256 W/4 B、两源各256 R、逐F32 gold、有效区 written 与邻接哨兵、末B 后发布、两源债务/lease 归零、响应保持及实际消费；全 BO 未扫部分另列 UNKNOWN。 |

既有 D2-I `vector_controller_slice` 虽有生成 RTL 和双输入/STATE AXI 端口，固定 B1/S64、64行、stage4 且预填两源；其 residual 数值仅 CPU/标准 libm CSim PASS，独立审核明确没有数值 RTL。它不能直接接本 stage2 四行或保证免 HLS。现有有限 hub 也未接收 HIDDEN/TMP 两个完整源的实际 query/grant/双 lease；下一 RTL 须沿原存储/owner 权威新增有限绑定及错身份/发布前拒绝，不能以 TB 常量或整体 executor 代替。一个 64B 双源暂存、在途 tag/输出 FIFO、64B 写 pack 与不可变 AXI tx 是拟新增状态；资源、延迟及联合时序 UNKNOWN。普通 Q/L 多窗口、上游 Attention/WO residual 硬件、13BO 请求/恢复、完整 28+2 层与 M003/M004 均未闭合。

[原收据](../attempts/AT050_FFREF0_reference_01/receipt.json)、[机读参考报告](../attempts/AT050_FFREF0_reference_01/output/ffn_residual_reference_report.json)、[冻结清单](../attempts/AT050_FFREF0_reference_01/source_manifest.json)、[guard](../attempts/AT050_FFREF0_reference_01/guard/guard_result.json)与[复核](../attempts/AT050_FFREF0_reference_01/verification.json)保留。首次准备仅因误取 E002/tools 路径复制失败，参考尚未启动；修正为 AT038 原冻结 guard 后，单次 host 运行 child0/trigger null，4.220971s、峰126976KiB、MemAvailable 最低448582076KiB，唯一实际 policy 为 CPU0–3/nice19/idle。没有提高8GiB/120s帽或启动第二次参考。
