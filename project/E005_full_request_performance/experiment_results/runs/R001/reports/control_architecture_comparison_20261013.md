# P3：控制实现表示的三项比较

2026-10-13，工程A002提案，A001集中选择；仅只读，不启动控制器工具。容量、生命周期及唯一权威的依据见control_state_inventory_20261013.md。当前P1/P2继续独立算术测量，不等待本提案。

| 方案 | 状态/存储表示与唯一写入 | 生成及控制成本证据 | 验证工作与具体取舍 | 当前建议 |
| --- | --- | --- | --- | --- |
| FullRuntime整体HLS/冷INIT | 已有reference对象与完整helper调用图；保留现全部容量/authority。冷INIT源码为有界15810次调用候选，无RTL周期证据 | executor01–04均COST_STOP，无top。五宽FIFO单独生成成功、Inputs副本已去掉仍停止；冷INIT未生成。没有pass根因定论 | reference覆盖最直接，但大对象构造/调用图/内部聚合映射使编译与硬件表示难分辨。恢复须有具体pass/对象干预证据，不能凭ABI尺寸或host PASS | 暂停新生成，保留软件reference和历史证据 |
| 显式寄存器/有界RAM/微步骤的薄HLS | 单一controller状态写口；A/K/route/下界/active action用命名寄存器；owners/source/window/覆盖图用固定容量RAM，完整字段独立schema；codec与校验逐步读候选，完整验证后一次可见提交 | 尚未生成，LUT/BRAM/控制cycles UNKNOWN。可避免把host FullCache/observer/整对象图纳入top；参考存储账不是综合面积 | 保留独立软件reference；须对每个微步骤标定只读、候选写、最终commit。跨周期校验和单写仲裁可能增加控制周期，但生成目标与失败区间更可辨别。复杂校验仍有HLS调度/对象传值风险，应使用实际scalar/固定RAM接口 | 优先设计；先一个有界目标，未达出口不扩全部恢复 |
| 同schema的小型手写RTL控制器 | 使用相同寄存器、RAM容量/全键/高水位及唯一写口，不复制hub/allocator/retirement；显式FSM驱动现有kernel | 尚未实现，资源/控制cycles UNKNOWN；绕开C++/HLS对象转换，但不能由此声称硬件更快 | 控制时序与VALID保持容易直接观察；完整codec/数值Check/错序/半帧逻辑需手写，证明对reference等价的工作更多。可先选择最薄序列段，复杂验证逐步加入而非删语义 | 保留为同范围备选，若薄HLS目标重复同位置成本停止可集中切换 |

建议的最小可证伪目标是一个现分区内的控制片段：冻结完整旧A/K/route和一活动action；完整命令校验后一次提交下界；真实24拍LTX发出及16拍LTC实际消费；按原键/Check规则收结果，持久半帧/撤销保持。采用已有FIFO wire/codec和固定容量candidate/owner引用，不新定义跨分区裸指针。它仅证明这一控制片段生成与有限行为，不能代签完整actor、首cleanup、hub物理终态或请求唯一退休。先由主控明确该目标最终选取的源码/存储schema与验收边界，再恢复其实现。

硬件状态账显示现本地FullOwners语义字段约179.21KiB，另有hub close_context单项48KiB，以及G/Down plans与transport；并非要求把所有表复制到新控制器，也不是LUT/BRAM预算。逻辑/物理表语义不同，未证等价不得合并或删去。RAM端口/分bank、初始化、同cycle读写与仲裁需要显式定义，保持原32owner/34source×128window等容量与全键规则。

选择建议：停止以整体软件对象图为默认硬件表示；先薄HLS，保留RTL同schema备选。恢复条件仍是P1形成可用路径、主控集中选定schema/authority和最小生成目标。当前只读提案不构成新DUT PASS或恢复工具授权。

## 主控集中评判：measurement-first-P3-design-review-20261013

P3有界盘点已满足本轮交付，薄HLS优先、同schema RTL备选、整体FullRuntime/冷INIT停排。候选排序没有生成/资源/控制cycles验证含义。host大cache/observer本已不在综合闭包中，删除它们不能算相对executor04的实质干预；需要改变真实可达状态访问、构造/校验/提交和调用图。179.21KiB为工程字段账，未签BRAM/LUT。

本页所提仅24LTX/16LTC目标**未冻结**。后续最小目标应为原容量source/window或owner关键持久表的一条真实读字段→全键/条件校验→私有候选更新→一次提交/拒绝路径，明确初始化、同址读写、仲裁和可见点；不以传输生成重复代签状态表示。待P1可用再由主控选schema/目标。本轮不追加控制清单/实现/工具，P3收束，继续P1/P2。
