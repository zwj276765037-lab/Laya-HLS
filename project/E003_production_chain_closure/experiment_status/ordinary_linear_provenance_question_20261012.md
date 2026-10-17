# 普通 QUANT/MATRIX 源 tensor 的 producer Context 定义请求

工程已完成当前 G/Down Controller 门户入口的同 runtime 有界集成：B1/S64 的四个真实 GEGLU typed producer、一次 LOAD、四个 QUANT 父任务与每父四个 MATRIX view 均由现有 `reserve_g_down` 提前预约，并在 `portal_controller_04` 中逐拍核对 25 条门户命令、13 个 typed TaskDone 和最终 owner/lease 状态。该路径的 P 是每个 G 窗口自己的真实 GEGLU Context，因此没有歧义。

继续接普通 Linear 时出现合同层缺口。`full_forward_controller.cpp::linear_impl` 的 QUANT 源可能是由多个 typed task 共同完成并在循环后才发布的完整 tensor，例如 Attention 输出由 16 heads × B × rows 窗口共同覆盖；当前没有一条显式 typed task 表示“该完整 tensor 已发布”。v2 合同禁止用 `task_id+1`/`task_id-1`猜身份，也不能静默取循环中最后一条 task。当前实现因此保留 `dispatch_binding.valid=false`，普通 Q/L 仍走原 direct 路径，没有发送带伪 P 的门户命令。

请主控明确普通 Q/L 的 P 应采用哪一种真实、稳定记录，并补入权威合同字段/生命周期：

1. 新增一个显式 tensor publication typed Context/TaskDone，作为多 producer 的聚合完成记录；
2. 扩展门户绑定为有界 producer 集合/ledger，而不是单个 P；
3. 指定现有某条真实 typed completion 可代表完整 tensor，并给出选择规则及为什么不会把局部完成误当完整发布。

还请覆盖 QKV 双 owner、Attention 16-head聚合、残差/向量多窗口、跨 batch 和失败后恢复。工程在答复前可继续独立的 hub/base-binding/构建工作，但不会让普通 Q/L 门户以猜测 P 上线。

证据：`project/E003_production_chain_closure/experiment_results/runs/R003/portal_controller_04/receipt.json`；当前实现位置：`project/E002_Laya_HLS/experiment/hls/control/full_forward_controller.cpp` 的 `linear_impl`。
