# production Controller HLS后端阻塞与内部再拆分问题

回复关联：`production-source-switch-hls-review-20261012`。工程未改变13BO/control ABI、wire v2、LPV1/LPA1、typed任务、数值或预算，也未启动OOC/P&R/上板。

## 当前冻结证据

- `producer_engine_controller_09`、`producer_engine_controller_10`：两次当前闭包host事务回归均PASS；LayerNorm BEGIN→engine→END、来源租约与唯一退休语义保持。
- `partitioned_controller_hls_06`：局部显式FIFO参数修复后，HLS在`Controller::geglu_down`的LLVM Jump Threading内部崩溃；455.864899s、峰值6,929,096KiB、无RTL候选。
- `_07`：对`reserve_g_down`、G/Down service issue和owner生命周期保留HLS层级，已越过原崩溃并通过synthesizability（0 error/1 QoR warning），随后在Loop/function优化完成后的后端阶段触发120s `semantic_stall`；1301.695137s、峰值6,933,164KiB、无RTL候选。manifest `6f4abef65ca7d907e49679437b315fa54299c70c6d0015bcfcba849161a9e2cc`，config `89baf3a7998b667e58a2215945301a334afb89f1e44cbabc4833ae934a257ec1`。
- `_08`：进一步对graph/action家族及LayerNorm producer调用保留层级；host回归先PASS。HLS仍通过synthesizability，后端同一位置触发120s `semantic_stall`；1330.575007s、峰值7,150,492KiB、无RTL候选。manifest `04dc988ae245092ca97d6044b8651b7bcdec09c28482744f509847a36cd205de`，config `453c2af61872f1c92a6902bca61cf80499d1f898e877c5ba7ee641693c661145`。
- `_08` HW Transforms为944,244 instructions；`full_execute_request_partitioned`约999,690、`graph_partitioned`约955,387、`execute_graph_action`约955,031。相对`_07`的937,017/992,346/948,043/947,687没有降低，说明继续加inline-off只保留层级，不降低完整caller后端工作量。
- 已有`layernorm_producer_hls_01`为`PASS_SCOPED_GENERATION`，99.227242s、6根内部FIFO信号、source read和destination write AXI端口齐全；因此engine本身不是当前阻塞。

这些结果足以停止当前单caller HLS profile的无区分重试；`_07/_08`均保留为FAIL/semantic_stall，不追认RTL生成。

## 需要主控明确的内部边界

`D-M003-PRODUCTION-HLS-PARTITION-01`要求Controller caller保留完整任务图、身份/预约/高水位、BEGIN/END、owner事件和唯一typed退休，同时允许Controller caller/shell与service分层独立生成。当前单caller HLS top即使切断全部算术闭包，仍在原120s产物停滞保护下无法生成。

请明确是否允许在**同一Controller职责域内部**再拆为两个有限生成分区，最终由唯一RTL shell连接：

1. graph sequencer：保留完整模型PC/layer/shape循环、NumericIdentity、Task/Ref/portal/event预约、高水位、完整绑定状态、错误/取消与唯一typed退休；
2. command/provenance adapter：仅承接一条活动action/task的固定宽度描述，构造/核验compute wire v2与LPV1/LPA1帧并驱动原compute/provenance/producer三对FIFO；不拥有READY、owner发布、typed编号或任务图；完成返回完整绑定/Check/TaskDone字段。

对外仍只有原13BO/control和现18根FIFO信号，内部最多一条请求槽/完成槽、单活动task，BEGIN成功前不启动engine，全部高水位和退休权威仍在sequencer；这不是第五service，不缩任务图或层数，不用Host/空blackbox替代。

若允许，请同时确认adapter可拥有现18根外部FIFO信号、sequencer通过内部固定宽度valid/ready连接它；或者必须由sequencer直接拥有18根信号而adapter仅作为帧codec子模块。若不允许，请将当前caller在原profile下登记为明确后端阻塞，工程停止其重工具重试，只继续不依赖caller RTL的LayerNorm engine、shell静态路由/monitor接口准备和其他合同内实现，等待新的可检验架构决定。
