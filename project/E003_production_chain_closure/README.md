

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# E003 · production_chain_closure

关联：M003 / SM003

## 原始管理记录

- [实验协议](experiment_source/protocol.md)
- [来源摘要](experiment_source/summary.md)
- [结果摘要](experiment_results/summary.md)
- [状态摘要](experiment_status/summary.md)

## 当前结果摘录

2026-10-14 D-M005-FINAL-ASSESSMENT-01：M005有界评估已收束，当前串行实施线停排；M003普通Q/L继续paused。旧M003逐窗口P/generated通道合同只作未来技术约束，旧预算不恢复、不重置。本次仅一次已有接口/证据静态收尾，无新RTL/TB/gold或工具运行。下文2026-10-13阶段文字均是保留历史，不表示现在可继续运行。

静态接点盘点见 `project/E003_production_chain_closure/experiment_status/ordinary_ql_static_interface_inventory_20261014.md`：当前caller partitioned generated BEGIN/END仅LayerNorm；hub逐窗口P/owner发布、普通Q原子query/lease及读债、父L接口均有可定位接点，范围仍不足以覆盖普通多来源/多窗口生产链。LN_ATTN单rows16真实NORM→Q与HIDDEN四窗口受控sideband身份不同，不拼为PASS；M003 L0/L1 PARTIAL、L2–L5 NOT_RUN，M004未完成。

用户2026-10-13工作重排已落实（D-M004-MEASUREMENT-FIRST-01）：M003生产控制新增实现与生成暂停，现转SM005/E005/R001独立算术KB0/KB1。executor HLS05未创建/启动；冷INIT、LTP exporter/collector、managed adapter与CLOSE/rearm保存退出队列。collector已启动有限RTL按原guard完成，当前无本项目运行中的重工具。下文是保留的原阶段历史，旧running/下一步不再指示当前排程。

# E003当前结果

已集中接纳的host08与actual adapter四case/11笔有限连接保持原范围：64B错误END与首LTX已接受后撤销，不签正常完整LN或撤销后新cleanup。

新graph_program_owned_hls_06 PASS_SCOPED_GENERATION：实际8FIFO/24信号，411.028507s、peak5360976KiB；nested purpose/content及416B copy静态位置正确。owned_bootstrap_validator_rtl_01实际generated nested双512RAM正负15process PASS_SCOPED_RTL：purpose0/2/0x0101、content0/2/255、坏region及七model块首。只遮原独立ABI未知padding49B，语义719B与model416B完整比较；不签owner安装、外1024实际执行或padding invariance。

executor_hls_host_06七process PASS；executor_hls_03 COST_STOP，285.634333s、peak1474268KiB，120s真实停滞保护，Compile/Link227441、0top。已证gdce无普通libc/indirect/memcmp调用，Inputs2464B a

（摘录截断；完整记录见链接。）

## 每个运行批次

| 批次 | 详情 | 具体尝试数量 |
| --- | --- | --- |
| R001 | [本批结果与证据](experiment_results/runs/R001/README.md) | 0 |
| R002 | [本批结果与证据](experiment_results/runs/R002/README.md) | 1 |
| R003 | [本批结果与证据](experiment_results/runs/R003/README.md) | 473 |

## 原工程历史结果


本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
