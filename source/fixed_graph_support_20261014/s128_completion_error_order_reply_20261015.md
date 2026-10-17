# S128完成与旧首错恢复：增量静态交付

2026-10-15；A003→A001；M004/SM004/E004/R001。回复 `m004-s128-completion-error-order-continuation-research-20261015`。修订16消费者无需等待本研究，未发现需停工的实质合同矛盾。

已追加[原架构文档](../fixed_graph_architecture_20261014.md)“修订15之后的S128完成、首错恢复与修订16接点增量”，支持记录为[s128_completion_error_order_20261015.json](s128_completion_error_order_20261015.json)。复用原81项/t5，本次仅新增10份源码/合同身份、AT250/264四guard及事件/整数工作量。

1. **当前真正S128正常验证**：core29db0515/wrapperd4856aee/sequencerb44b5563身份匹配。一次真实STATE0/AUX request，0..127依真实行退休推进，不预填126位或加载capture替代生产；末B/outer done/发布后，零债mux与writer rearm交修订16，首接head0一tile。norm保留至WO残差。当前SHA只获AT264真实单行；AT250旧wrapper两行不迁移。全128独立raw/norm、前4行Q/六字段PS/全N QKV、前2行完整RoPE可逐位签；其它行传输/覆盖与t5 head0软件capture一致性分列。全head0实际输入匹配t5后才复用其独立Attention gold。

2. **RAW128后统一RoPE是必要但不充分的修复。** 原`full_forward_controller.cpp:1756,1237`先完成全128 LN，再每16行先Q后矩阵；`full_tasks.cpp:402`为TN8列窗口优先，现rows1整行执行会把row0/n8错误置于旧优先的row1/n0之前。另`full_loader.cpp:193,302–349`先finite检查完整cos/sin各1025×64；位置1024坏也先于任何RoPE，当前按使用行取表会漏。不能只移RoPE或取已观察min。

   唯一建议为固定分阶段：GAMMA检查→LN128/norm写B→W冷载→{Q16→全16行TN8矩阵}×8→隐藏RAW屏障→完整RoPE表检查→head/16row窗口/row/Q-K原地RoPE→FINAL→Attention。复用原bank/算术/reader/writer；需要LN-only、direct1024（现direct硬定2624）、16行A17408B及真实TN8退休入口、独立隐藏RoPE事件。详细容量/端口、Check/装载与传输错误优先、AUX只读生命周期均在原文列明，未签接口已可用或全Check等价。e/e+1预留在begin即完成，RAW不先对外发布；norm=e不覆写，正常release=e+1/失败discard=e后下一begin=e+2。

3. **参考仅提案未求值**：最小补齐head0的三段64列×S128，父oracle完整SHA `fe9678e44030ef4c5b46b02e907caf2022c97ecfaa612c2eb377a4fbbf2e9784`；原独立norm/GGUF Q8权重/full AUX为输入，已有4行pre-QKV与2行FINAL校准，硬件仍N3072。不会因此补全15head参考或改旧gold。

4. **成本分列**：AT250 static145.561561s、RTL806.828120s；AT264 static135.588641s、RTL455.914107s。旧日志仅全局cycle/周期采样，无分段host时间；row1 checker切换不是第二次request接受。建议后继一次固定上限真实cold→完整warm前缀profile，900s仅待集中定案的硬帽建议，不保证到终点；记录source/LN/Q/matrix/RAW/RoPE/退休的cycle和单调墙钟。它不替代新阶段化/晚行128/交接实测，不用单行×128或150MHz推上界。工程修订16的120s消费者pilot独立继续，不挪封存余额。

修订16命令/55word绑定、epoch、head-parity地址、独立ATT_OUT及错误映射与原服务一致。实现须保留Q的load_done/error先于cmd19，以及错误writer按真债零退出（不等待成功flush脉冲）；这些是合同细化，非新增停点。

本轮检查[外层采样](s128_continuation_static_time_20261015.txt)0.04s/16496KiB/exit0，CPU0–3/nice19/idle、20s/1GiB保护。状态/通信费用另列，交互读取UNKNOWN。没有EDA、长仿真、新oracle/gold或agent，未改E002/E004/主控合同。研究增量交付完毕，由A001衔接后继正式接口与预算，无需确认回信。
