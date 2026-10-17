# G门户物理绑定与普通QUANT共享实例里程碑

消息ID：`gate-ordinary-portal-milestone-20261012`

当前源码取得两项限定PASS，并已写入E003三摘要。

1. `gate_quant_binding_pilot_06`：static/pilot PASS，52.922042/21.735452s，峰值2153908/834184KiB。一个真实v2 GEGLU命令执行一行；WI AR/R=6/328，GATE AW/W/B各164，最后B反压12cycles后才返回；没有Q命令时quant不启动，tensor仍未READY，总12108cycles。manifest `aa5801b363b93c0117b7a4304e187833cd63f137d8ff73fd26fa2f55fb4a8929`，receipt `f9e9c5da35f31ca62b6e03f5e55f22130171fcaf2acab50f7fd8f617cf4fc2b4`。

2. `gate_quant_ordinary_portal_02`：static/pilot PASS，52.389593/6.370841s，峰值2138808/856820KiB。先拒绝未发布来源，再让一条stage6/K256普通Q命令使用与GATE Q相同的唯一`quant_task_to_dual_a_v1`和dual-A实例。实际source AR/R=1/16，8个quant group、16 half commit、8 scale commit及8组独立冻结gold通过；未使用GATE lease，总191cycles。manifest `2152619dbb09bd77bb9010251dd30592da9235f3022eb28c9cfb567f7df3479d`，receipt `aa3577895e9d40e05cec584e9915b1f31d278b15a2cf9b82cf878222514a8c0c`。

实现修正：G物理debt-zero不再包含`writer_busy`；后者包含待`g_done_ready`消费的逻辑完成，把它作为债务会形成真实完成死锁。普通/GATE Q现共享唯一物理quant/full-A实例，按冻结stage/source/row-space映射选择K与stride；普通来源不领取GATE lease。

保留失败：`gate_quant_binding_pilot_01..04`分别为TB RVALID/BVALID竞态及默认WDB开销超时、暴露writer_busy完成死锁、TB错误预期WI AR=3、在response握手前检查ledger覆盖；`_05`是普通Q修改前PASS，`_06`为当前入口。`gate_quant_ordinary_portal_01`保留共享普通source AR被旧断言误判为GATE AR的FAIL。没有删除DUT工作量或gold。

范围：G结果只签一行物理WI/GATE/返回，不签Q payload或完整tensor。普通Q只签受控stage6/K256；`q_ordinary_source_published`仍是受控布尔边界，生产须由唯一持久hub按完整NumericIdentity、P/Q/L、Ref/region/epoch与source证明驱动。现`gate_axi_ar*`是共享QUANT source读口，生产须按source role路由实际BO。两结果都不签真实generated provenance cmd/rsp双FIFO、LOAD、matrix、完整请求、L2/L3或当前CPU/CSim。

下一步按原合同先重跑被共享Q状态机影响的`gate_split`当前源码，保留120s pilot和显式full成本路径；再实现D-M003-GENERATED-PROVENANCE-CHANNEL-01的Host不可见双向FIFO及posted-write计量/fence，接唯一持久hub/generated caller、LOAD/其余Q/L和matrix。组合G/Q→matrix完整full仍`NOT_RUN_COST`，不重启未改善的5172s profile。

状态保持L0/L1 PARTIAL、L2–L5 NOT_RUN，M003/M004未完成；无OOC/P&R/上板，G OOC余额不变。
