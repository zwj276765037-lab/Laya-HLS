# M004下一算子：LN单行精确流水的有限准备

A001→A003；接续 `m004-fixed-graph-architecture-controller-choice-20261014`。不新建mission，沿M004/SM004/E004与现有 `source/fixed_graph_architecture_20261014.md` 更新一个下一段设计小节即可。

向量实验已测CE ADD在52定向和真实4096残差样本连续每拍接受、32credit流4103cycle，单laneOOC1283LUT/614FF，内部WNS+3.057ns@6.667ns，无P&R/Fmax。主控已核原log与源码。搬运服务有16KiB单突发跨4KiB及缺finite检查两项缺口，已令A002原预算普通修复；原6928/7185cycle不当作合规服务速率。报告在E004/R001/reports/SM004_vector_stage_result_20261014.md，预计工程会补范围说明，不用你重复审整个向量段。

请只准备下一项LN的可实现方案：完整1024维精确相邻两棵树＋delta/square＋sqrt/reciprocal＋normalize/可选gamma，优先一个共享ADD和一个MUL、现有精确sqrt/div接点，单行缓冲与固定阶段FSM。给出实际可复用源码/接口、数值兼容性已证与未知、每级树的读写bank与端口安排（不能假设单BRAM每拍任意两读一写）、依赖排空、有效条目/标签所需最小职责、正常及gamma模式原独立fixture接点。说明均值/方差除1024等操作如何保留原逐步F32语义；不换归约树或近似sqrt，不用旧HLS错误时序预认频率。

给一份可复算的分段cycle/存储条件预算，并指出首个最有区分力的整行检查：能否让相同树层内独立节点连续发射、按层屏障排空，真实mean/variance/inverse/y全部匹配原gold。若现有非ADD算术身份或吞吐缺证，明确具体叶子和必要短测，不直接设II=1。目标是完整LN行服务，避免再发展通用调度。以约一页新增分析为主，不全图重审或派新agent。

仅静态读和必要小算式，原研究host累计≤120s/8GiB不重置，CPU0–3/nice19/idle；无EDA/GPU/模型前向/新gold生成。A002改vector，你不写其RTL/TB/设计结果；可直接问A002一个有范围的实际接点问题。完成后直接给A001推荐一个方案及实质接口缺口，供同mission下一实现段集中确定。
