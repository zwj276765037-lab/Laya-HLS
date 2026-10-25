# M006：完整板端Attention与高性能主干实现状态

updated: 2026-10-17
execution_state: paused
verdict: unassessed
review_state: paused_AT023_engineering_report_received_not_new_audit

用户要求“等等等我通知再继续这个工程”。A002在[AT023暂停回报](../../.research-agent/communications/m006-sm007-at023-pause-implemented-20261017.json)确认已暂停、无本项目在途实验；主控架构审阅已停止。M006/SM007不再启动实现、审核、TANH DAG或实验，只等待用户明确恢复。旧M004/SM004及A003保持暂停。

架构仍按[Goal v8](../../goal/goal.md)、[M006修订5](../../mission/M006_CPU_FPGA协同高性能推理实现/contract.md)及[SM007](../../mission/M006_CPU_FPGA协同高性能推理实现/tasks/SM007.md)：FPGA执行全部30层Attention和驻留主干，CPU仅输入/尾部/Host。数值、周期和资源要求未降低。

暂停点处于底层算子与存储验证阶段：[已有限定审核](../reviews/SM007.md)覆盖strict EXP单lane局部RTL（II1、167拍）、共享256路FP简单值接口、QKV银行局部RTL及零黑盒模块综合（384 BRAM36）、F64 add和直接divider的限定模块证据。以上不能签完整QK/AV、softmax、完整head、8lane SFU或联合物理结果。

工程AT020–023新增报告保留原身份：8拍add单模块OOC完成；AT021新8拍add、AT023旧11拍add均在00000001+00000001时返回0而非00000002；AT022新8拍divider在00800000/40000000时返回0而非00400000，均为FAIL_NUMERIC。AT023为工程暂停回报，本次只登记状态，未追加技术审核。旧TANH384拍与≤160拍要求有冲突；严格替代叶子及DAG决定尚未完成，暂停期间不实施。

工程暂停点账报告33guard/246条已观测policy：参考1.2089934079995146/900s，static186.702932331001643/1800s，RTL56.612746981005330/3600s，HLS＋OOC918.667736757997775/3600s。余额保留、不转预算；host完整UNKNOWN。本次不据接收报告提升为独立审核完成，原失败/超时/黑盒/中止全部保留。

完整单head QK→softmax→AV、新矩阵主线整图、16head/完整模型、A6000比较、联合资源/布线300MHz及实板均未验。P50≤50ms/P95≤55ms/≥18QPS仍为合同要求，没有整机实测。
