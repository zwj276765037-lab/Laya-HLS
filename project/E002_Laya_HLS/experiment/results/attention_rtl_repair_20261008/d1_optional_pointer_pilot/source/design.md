# D1 nullable metadata pointer最小对照：设计

本目录是临时诊断小top，设计由GPT-6 Astra xhigh负责，实现由GPT-6 Sol max负责。权威合同为[repair_contract.md §6](../../repair_contract.md)，原型仅隔离controller的指针存在性/metadata选择；不构成新生产计算模块。

输入：真实FullOwnerSpec/BufferRef类型的动态字段、op、presence/选择模式以及可控load成功状态。输出：Check status/detail、pair两个描述符写回、vector发出src1字段与bind观测、选中attention source。A保持原nullable pointer表达式，B按§6.1使用显式bool+reference/值选择，其余算法/数据/期望一致。

success/absence、pair两路差异、binary src1扰动、unary NONE和layer选择均须自检；禁止仅测常量输入。可用明确标注的probe-only load/bind/issue stub作为观测器，此处不验证真实数值/owner链。A未重现失败也要保留，不伪造基线失败。最小A/B通过后仍必须验证生产typed-task联合链。

工具使用现有Vitis/Vivado2025.2、目标xcu55c-fsvh2892-2L-e、6.667ns；保留与当前F0一致的pipeline/partition设置。每次实际top、sources/config/TB及hash必须记录。16GiB任务树RSS、192GiB MemAvailable底线、4CPU、nice19/idleIO、30分钟/局部试验；不启动全网HLS。
