# M001：工程复制与Research接入

execution_state: completed
verdict: supported
applicability: 本次baseline完整副本一致性与research-agent登记，不含新增硬件验证。

用户要求当前阶段性任务结束后将 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/LLAMA-HLS/Laya-baseline` 完整复制到 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS`，保留原工程，方便新对话专用实现。SM001/E001已完成原样普通文件复制、SHA256一致性、权限与entry集合检查、跨源hardlink检查、内部链接重映射。完整副本置于E002/experiment，不搬移原工程。真实精确结果见[收据](../project/E001_baseline_import/experiment_results/runs/R001/copy_receipt.json)。

一次低优先级复制与串行校验，无硬件工具/新agent启动。已建立目标、M/SM/E/A记录、三摘要、资源与模型政策、真实边界和交接入口。下一步转M002，不能据复制PASS宣布完整加速器PASS。
