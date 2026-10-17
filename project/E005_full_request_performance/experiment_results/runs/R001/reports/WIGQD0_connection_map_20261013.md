# WIGQD0 单引擎接线与身份表

合同：D-M004-WIGQD-INTEGRATION-01；工程实现根 E002/experiment，证据 E005/R001。AT029 静态 elaboration 因预填端口名称失败；AT030 静态/短 pilot 通过，full 因等待 Wi W 长区间的真实进度标记缺失而触发 120 秒 semantic-stall 保护。AT031 为第二次且最后一次受影响修复，冻结源补完整 Wi W fixture 数组容量、实际 R 握手进度和阶段边沿观察。AT031 static/pilot 通过，full 在真实 Wi 子段完成、G 命令接受后因 120 秒无新语义进度标记而 COST_STOP；末次标记 cycle=101339，不是已证最终停拍。完整结果见 [WIGQD0 阶段报告](WIGQD0_bounded_stop_20261013.md) 和 [AT031 原收据](../attempts/AT031_WIGQD0_chain_03/receipt.json)。

| 实体/阶段 | 当前连接 | 唯一状态与身份 |
| --- | --- | --- |
| Wi A 输入 | 外部原预量化 LN_FFN 四行，经桥上受控预填透传进入 `quant_task_to_dual_a_v1` 内唯一 `quant_dual_a_v1` | slot0 epoch1；预填 fill/commit/row_done/finish 使用原校验与提交协议；源类2，A类0x22，batch0/row0 |
| Wi W 与矩阵 | 一套严格 `t4_dual_w_cache_v1` 和一套 `tm4tn8_matrix_resident_v2` | W slot0 epoch1、key3；op0x32、K1024/N5248、bias0；任务 ID3，PS 类0x24 epoch1，dst Wi 类6 epoch1 |
| Wi AXI 写/读 | resident AW/W/WSTRB 写入同一按字节索引的 DDR 测试存储；在实际末 B、局部发布、lease/读债结束之后，`laya_wi_axi_reader_v1` 从该存储真实发 AR/R | Wi region `0x100001000`，4×20992B；reader 保持完整 numeric identity、source ref、row/index/row_done，按原 4KiB 边界和响应背压 |
| G/GATE/量化 | 原 `geglu_gate_quant_bridge_v1` 接受 reader 标量；GATE writer 写该 DDR，量化 feeder 真实重读；结果写回上述同一 A 存储 | 同 numeric identity B1/S128、batch0/row0；G任务ID4、量化ID5；GATE 类7 epoch1，A slot0 epoch2、A ref 类0x22 epoch2 |
| Down W 与矩阵 | 同一 W 缓存加载新 epoch，同一 resident 运行 KB1 writer | W slot0 epoch2、key4；op0x33、K2624/N1024、bias0；任务ID6，PS 类0x24 epoch2，dst 类3 epoch1 |
| 存储/保护 | 同一 DDR 字节数组承载 Wi/GATE/Down；实际 AW/W 配对后按 WSTRB 写，R 仅由已写字节返回 | 三段有效区分别为 `0x100001000..0x100015800`、`0x100020000..0x10002a400`、`0x100040000..0x100044000`；其余建模区初始哨兵 `0xa5`，最终需逐字节读回 |

新测试台只在起点提供四行预量化 A、原物理 W/metadata 和命令。Wi、GATE、量化 A、两段 PS 和最终 Down 均由 DUT 产生，原 fixture 仅作为逐项独立比较值。桥的预填选择仅在 Wi 阶段启用，Wi lease/返回债清零后关闭；旧无预填实例默认关闭此接口。测试台阶段计数可以分相位重置，DUT 不复位且不清累计 owner/epoch。

以上为实现映射。AT031 full 已验证 Wi 有效区 83968B 的字节读回、Wi 局部 gold/末 B/lease/消费及 101335cycle 冷至 Wi 完成边界；Wi reader 的完整 AR/R、GATE/量化/Down、最终全存储保护字节读回与整链周期未取得。物理资源、联合预算与完整生产请求不由此接线证明。
