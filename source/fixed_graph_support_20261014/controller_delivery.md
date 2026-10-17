# M004固定图独立架构核查交付

A003→A001；2026-10-14；M004/SM004/E004/R001；回复 `m004-simplified-start-research-20261014`。

交付：`source/fixed_graph_architecture_20261014.md`。已收到并纳入 A002 的 `m004-sm004-reuse-contacts-answer-20261014`，无全图重审或工程重复运行。

- 建议首版固定顺序FSM连接六类跨层共享服务：matrix、Q、LN、Attention、canonical G、vector/tail。保留算术内部流水，替换旧逐元素等待和通用控制耦合。第二选择才是合并LN/Attention/其余FP到一个资源池；后者要新写银行/返回tag/树屏障，面积与速率收益尚未知。
- 固定完整图已核：122 Q8/47.16G INT8 MAC及其余运算沿用已审工作量。LN/QK/softmax相邻树、AV与Q8恢复逐项累加、量化舍入、scorer两次bias均保留；16 scorer槽和2有效候选分开，最终输出是masked logits而非概率。具体低层源码/接口及旧owner耦合见报告表。
- 可落地的静态外部scratch为H0/H1/N+S0/S1合6,356,992B（6.0625MiB，另加尾部/对齐/只读数据），用真实读/算术/写B排空控制复用。W驻留跨32个四行窗口仍需验证，Wi/Down不可在同一matrix并行。
- 首个吞吐验证建议仅一个：精确F32残差能否在有限credit和合法反压下按真实leaf II连续接收独立元素。旧103289cycle/4096adds包含单项等待，22cycle延迟不等于II；若leaf本身不流水，封装修改不能达到II1。该小试可帮助选择vector/LN基础接口，但不能解决全部LN/EXP成本。ATN1 EXP4旧busy下限仍很高，不能把去控制壳当作全部收益。

原v4冻结，8cycle未知算子假设和6.919–8.133s旧预算都不作为新方案速率。轻量身份/算式核查墙钟0.04s、峰15,748KiB；采样和真实命令随报告，早前交互浏览累计未统一采样则记UNKNOWN。未执行EDA/GPU/reference前向或新agent，未启动上述候选实验；新架构物理资源、Fmax、整模延迟与吞吐尚UNKNOWN。A003本次限定分析完成，M004总体仍由主控/工程继续。
