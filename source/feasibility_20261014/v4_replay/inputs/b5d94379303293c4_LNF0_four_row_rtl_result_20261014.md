# LNF0：四行 LN_FFN 真实 store→Q/fullA 有限 RTL 结果

2026-10-14；M004/SM005/E005/R001；A002。按 [D-M004-LN-FFN-RTL-01](../../../../../../mission/ln_ffn_four_row_rtl_stage_20261014.md)执行。结论为 **PASS_SCOPED**：AT040 在同一 RTL runtime、仅初始 reset 下，将 AT038 独立 enc0 attention residual 前四行交给原 LQ0 baseline 生成核，真实写入 NORM 存储，再由原 Q/fullA 读取并比对独立结果。本轮没有连接 QAR0 的 Wi→G→Down 长链，也没有新 HLS、OOC、P&R 或上板。

## 输入与冻结身份

- P 使用 request_id3/generation1、B1/S128、LN_FFN `0x12`、stage2/layer0、batch0/row0/rows4、D1024、gamma0、epsilon bits `0x3727c5ac`；Q 为 QUANT `0x20`。包序号41、任务号11/12、provenance 序号300–304和模型 request_id3 保持独立。所用 canonical L13M 与原生成核模型 header 逐字节一致；原 ABI 捕获中的 build tag 与该生成配置不同，因此这只是合法诊断身份，不是完整原 ABI 生产请求回放。
- 原独立 residual 和 LN gold 各 16384B，SHA 分别 `5ad0bec6bff8c90ac12a34193a4371b675305c136e36e79a95c2f281e3cdcfa9`、`658b5a8dc595098aba930ca3b9782668bac783b1f7e2916bb45fa0a955c5e883`。AT035 原 q/scale 经每条 mem 小端还原的 4096B/256B SHA 分别 `839f4cb8cdb85f5fc1ad8449b9e55ba649915cac7a02aa9d7575d8afd8c49f34`、`4cca5faa8d74766136eb72e6950b422150be37899e808d15623dc548deee9d6f`。gold 仅用于比较。
- STATE0 逻辑容量 16920576B，HIDDEN offset0，NORM offset8388608；本四行 NORM 写范围8388608–8404991。源从只读 fixture 应答；目的仅由真实 AW/W/WSTRB 接受修改。Q 只从该目的数组中已写位置生成实际 AXI R。原 83 项生成物（71 `.v`、7 `.dat`、5 Tcl）按原身份复用，未编辑算术 RTL。
- [AT040 输入清单](../attempts/AT040_LNF0_ffn4_02/input_manifest.json)记录151行/151个不同冻结文件路径，[定向核验](../attempts/AT040_LNF0_ffn4_02/verification.json)逐项确认 frozen SHA/bytes 与当前原始副本一致。AT039→AT040冻结源码仅 fixture 生成器一项改变；旧收据不回写。

## 实际边界与数值

| AT040 四行完整回放 | 实际观察 |
| --- | ---: |
| 全冷 TB / LN 主运行 phase3 | 170031 / 168692 cycles |
| 源 AR / R | 4 burst / 256 beat，首末 AR 5035/126680、R 5037/126871 |
| 目的 AW / W / B | 4 / 256 / 4，16384B，末 W 167202、末 B 167215 |
| 生成完成 / END 消费 / 发布消费 | 168789 / 168843 / 168898 |
| Q 接受 / 首次响应 / 实际消费 | 168900 / 169841 / 169846 |
| Q AR / R | 4 burst / 256 beat，首末 AR 168903/169483、R 168905/169674 |
| source lease 开/关 | 168901 / 169847 |
| fullA acquire / 最末组检查 / release | 169847 / 169975 / 169976 |

四行 4096 个 LN F32 对 AT038 独立 gold 逐位通过，实际写入计数16384B且 completion、END 的4096元素/16384B字段闭合。Q 实际从这些写入字节读256 beat，128组量化计数闭合，4096 INT8与128 FP16 scale经 fullA 32组返回逐项对独立 q/scale 通过；slot0 row mask 为 `0x000f`。Q 原响应保持5拍后真实消费，source lease 随消费释放，fullA 实际 acquire/read/release 后读债及 ledger 归零。目的末 B 比末 W 晚13拍；END/发布及 Q 接受均在末 B 后，测试台持续禁止末 B 前发布/Q准入。

真实 WSTRB 每 beat 为全64字节，重复写检查与本地 65536B 目的数组终扫通过：目标16384B的每个32bit字均标记已写且逐位等于 gold，邻接49152B保持 `0xA5` 且未写。每个实际 AXI 地址和 burst 被限定在合法四行窗口及 STATE0 容量内；**没有逐字节扫描未分配的整个16920576B BO**。源数组没有写入口，独立源文件 hash 在冻结清单中；本次未做另一个物理 source DDR 最终读回。

互斥 phase0–5 为25+54+72+168692+1133+55=170031cycles；接口 wait 计数可能与主阶段重叠，不另加成时延。四行新输入与原 LQ0 十六行不是同口径 A/B，不计算性能改善；周期只限此模块 RTL 仿真，不按150MHz转换部署延迟。

## 失败、成本与边界

AT039 static PASS，但单行 pilot 在真实 LN 写入及末 B 后，因派生 owner descriptor 遗留 layer1 而在 END 被原 provenance hub 以 E_PROTOCOL=7 拒绝，故 pilot FAIL、full NOT_RUN。AT040只将该 descriptor 改为 layer0，使其与 P/Q Context 一致；没有修改 DUT、独立 gold、容量、算术或自检。AT040 static/pilot/full 均 PASS，原始 [收据](../attempts/AT040_LNF0_ffn4_02/receipt.json)、[full log](../attempts/AT040_LNF0_ffn4_02/guard_full/driver.log)、[旧失败](../attempts/AT039_LNF0_ffn4_01/receipt.json)保存。未使用第二轮修正。

AT040 static/pilot/full guard 实际 83.827585/56.206804/195.556890s，peak owned RSS 2370544/863288/863192KiB，child0/trigger null；三段分别31/4/4条实际 CPU0–3、nice19、idle I/O policy 样本全匹配，串行运行。单行 pilot 47308cycles/56.206804s；准入按四行 producer 放大、另给128组 Q 每组512cycles预算并乘1.5，估455s<3600s，真实 full 195.556890s。以上秒数仅为工具成本。

本次仅签四行 LN_FFN baseline 生成核→真实 store→原 Q/fullA 的正常路径。AT035 QAR0 及 Wi/G/Down 未在本 runtime 接入；上游 Attention/WO/residual 硬件、FFN residual、不同背压/错误恢复、完整28+2层/122矩阵、生产13BO请求、联合资源/物理时序均未验证。M003/M004保持开放。下一阶段需主控选择真实 LN→QAR0 接链及成本；本轮不自行启动第二条长链。
