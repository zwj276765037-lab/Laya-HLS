# 项目主控与架构评判：最新交付

execution_state: completed
stage: controller_transaction_split_host_reviewed_f6_f7_pending
scope: 两项冻结host交付与针对性静态审核；非完整Controller取消恢复、RTL或生产链验收

[审核](../../results/reviews/SM003.md)接纳graph_sequencer_host_02与controller_transaction_adapter_09的PASS_SCOPED_HOST。104组current/frozen/声明pair、246项SHA引用、交付四个SHA全部一致；5条原始PASS marker存在、9条命令exit0，运行分别14.241875s和10.174794s。[核查记录](../../results/controller_transaction_split_host_review_20261012/verification.json)保存41份依据/preimage。本轮未改工程代码、未运行编译/仿真/综合。

新增F6/P1：Controller的producer本地拒绝分支跳过source lease释放，终态END后直接清tracker，失败清理仍会被READ/readers阻断。新增F7/P2：completion坏帧头在复位前早返回，复用对象会残留旧可信字段；当前HLS从新对象解码，未证明实际误退休。均为静态发现、未动态复现。要求工程按现合同修复并补实际Controller有界取消/恢复及两配置codec坏头回归，不把合法未排空错误误清掉。

[直接答复](../../results/controller_transaction_split_host_reply_20261012.md)已通过[通信回执](../../.research-agent/communications/controller-transaction-split-host-review-20261012.json)送达工程，delivered_at=2026-10-12T04:41:22.244991+00:00，recipient_turn_id=01a12b3d-4005-7680-a1d4-fc9ca9ceb536。独立monitor工作继续；修复后的受影响host闭包通过后继续分区生成和真实LayerNorm master→monitor/hub→source lease→Q/fullA。已启动工具保留原身份终态，不并行另起重工具。

C009继续部分实施并跟踪F6/F7；C008/C010整体集成待验证，C012此前基础错误处理限定关闭保持。原拆分合同不变，L0/L1 PARTIAL、L2–L5 NOT_RUN、组合full NOT_RUN_COST、M003/M004未完成。完整加速器且尽量高性能、无固定门槛目标保持；无新OOC/P&R/上板、agent或预算，G余2338.224019s不变。
