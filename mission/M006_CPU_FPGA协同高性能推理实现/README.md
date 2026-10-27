

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-26T21:48:53.978174+00:00。来源修订：`f4a5039e6a52`。

# M006 · CPU_FPGA协同高性能推理实现

[任务合同](contract.md) · [任务总结](../../results/missions/M006_summary.md)

## 执行子任务与主控审核

| 子任务 | 定义 | 完整审核历史 |
| --- | --- | --- |
| SM007 · 完整板端Attention与共享计算首段实现 | [定义](tasks/SM007.md) | [审核](../../results/reviews/SM007.md) |

## 关联实验

- [E007 · m006_full_fpga_attention](../../project/E007_m006_full_fpga_attention/README.md) — 未登记

## 任务总结原文摘录

# M006：完整板端Attention与高性能主干实现状态

updated: 2026-10-17
execution_state: paused
verdict: unassessed
review_state: paused_AT023_engineering_report_received_not_new_audit

用户要求“等等等我通知再继续这个工程”。A002在[AT023暂停回报](../../.research-agent/communications/m006-sm007-at023-pause-implemented-20261017.json)确认已暂停、无本项目在途实验；主控架构审阅已停止。M006/SM007不再启动实现、审核、TANH DAG或实验，只等待用户明确恢复。旧M004/SM004及A003保持暂停。

架构仍按[Goal v8](../../goal/goal.md)、[M006修订5](contract.md)及[SM007](tasks/SM007.md)：FPGA执行全部30层Attention和驻留主干，CPU仅输入/尾部/Host。数值、周期和资源要求未降低。

暂停点处于底层算子与存储验证阶段：[已有限定审核](../../results/reviews/SM007.md)覆盖strict EXP单lane局部RTL（II1、167拍）、共享256路FP简单值接口、QKV银行局部RTL及零黑盒模块综合（384 BRAM36）、F64 add和直接divider的限定模块证据。以上不能签完整QK/AV、softmax、完整head、8lane SFU或联合物理结果。

工程AT020–023新增报告保留原身份：8拍add单模块OOC完成；AT021新8拍add、AT023旧11拍add均在00000001+00000001时返回0而非00000002；AT022新8拍divider在00800000/40000000时返回0而非00400000，均为FAIL_NUMERIC。AT023为工程暂停回报，本次只登记状态，未追加技术审核。旧TANH384拍与≤160拍要求有冲突；严格替代叶子及DAG决定尚未完成，暂停期间不实施。

工程暂停点账报告33guard/246条已观测policy：参考1.2089934079995146/900s，static186.702932331001643/1800s，RTL56.612746981005330/3600s，HLS＋OOC918.667736757997775/3600s。余额保留、不转预算；host完整UNKNOWN。本次不据接收报告提升为独立审核完成，原失败/超时/黑盒/中止全部保留。

完整单head QK→softmax→AV、新矩阵主线整图、16head/完整模型、A6000比较、联合资源/布线300MHz及实板均未验。P50≤50ms/P95≤55ms/≥18QPS仍为合同要求，没有整机实测。

## 相关决定、变更与讨论

- [overview](../../results/overview.md)
- [review_queue](../../results/review_queue.md)
- [C019 · M003普通Q/L逐窗口生产接入：请求集中合同](../../communication/C019_M003%E6%99%AE%E9%80%9AQ_L%E9%80%90%E7%AA%97%E5%8F%A3%E7%94%9F%E4%BA%A7%E6%8E%A5%E5%85%A5%EF%BC%9A%E8%AF%B7%E6%B1%82%E9%9B%86%E4%B8%AD%E5%90%88%E5%90%8C/thread.md)
- [C021 · M005现在执行：完整代表通路、资源时序与整模可行性](../../communication/C021_M005%E7%8E%B0%E5%9C%A8%E6%89%A7%E8%A1%8C%EF%BC%9A%E5%AE%8C%E6%95%B4%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E3%80%81%E8%B5%84%E6%BA%90%E6%97%B6%E5%BA%8F%E4%B8%8E%E6%95%B4%E6%A8%A1%E5%8F%AF%E8%A1%8C%E6%80%A7/thread.md)
- [C022 · M005立即并行：独立整模流水性能与可行性预算](../../communication/C022_M005%E7%AB%8B%E5%8D%B3%E5%B9%B6%E8%A1%8C%EF%BC%9A%E7%8B%AC%E7%AB%8B%E6%95%B4%E6%A8%A1%E6%B5%81%E6%B0%B4%E6%80%A7%E8%83%BD%E4%B8%8E%E5%8F%AF%E8%A1%8C%E6%80%A7%E9%A2%84%E7%AE%97/thread.md)
- [C023 · M005整模预算：容量、复用与计量缺口](../../communication/C023_M005%E6%95%B4%E6%A8%A1%E9%A2%84%E7%AE%97%EF%BC%9A%E5%AE%B9%E9%87%8F%E3%80%81%E5%A4%8D%E7%94%A8%E4%B8%8E%E8%AE%A1%E9%87%8F%E7%BC%BA%E5%8F%A3/thread.md)
- [C024 · M005代表top：LN→Q物理读债接线决策](../../communication/C024_M005%E4%BB%A3%E8%A1%A8top%EF%BC%9ALN%E2%86%92Q%E7%89%A9%E7%90%86%E8%AF%BB%E5%80%BA%E6%8E%A5%E7%BA%BF%E5%86%B3%E7%AD%96/thread.md)
- [C025 · M005静态发现：G接收的K是未声明单点信号](../../communication/C025_M005%E9%9D%99%E6%80%81%E5%8F%91%E7%8E%B0%EF%BC%9AG%E6%8E%A5%E6%94%B6%E7%9A%84K%E6%98%AF%E6%9C%AA%E5%A3%B0%E6%98%8E%E5%8D%95%E7%82%B9%E4%BF%A1%E5%8F%B7/thread.md)
- [C026 · M005 AT065：Down受理前四态未知，诊断full失败](../../communication/C026_M005%20AT065%EF%BC%9ADown%E5%8F%97%E7%90%86%E5%89%8D%E5%9B%9B%E6%80%81%E6%9C%AA%E7%9F%A5%EF%BC%8C%E8%AF%8A%E6%96%ADfull%E5%A4%B1%E8%B4%A5/thread.md)
- [C059 · M006硬件恢复派发：完整板端Attention首段](../../communication/C059_M006%E7%A1%AC%E4%BB%B6%E6%81%A2%E5%A4%8D%E6%B4%BE%E5%8F%91%EF%BC%9A%E5%AE%8C%E6%95%B4%E6%9D%BF%E7%AB%AFAttention%E9%A6%96%E6%AE%B5/thread.md)
- [C060 · SM007共享FP对QK/AV数据依赖的接口问题](../../communication/C060_SM007%E5%85%B1%E4%BA%ABFP%E5%AF%B9QK_AV%E6%95%B0%E6%8D%AE%E4%BE%9D%E8%B5%96%E7%9A%84%E6%8E%A5%E5%8F%A3%E9%97%AE%E9%A2%98/thread.md)
- [C061 · SM007严格TANH现有模块与160拍帽的静态冲突](../../communication/C061_SM007%E4%B8%A5%E6%A0%BCTANH%E7%8E%B0%E6%9C%89%E6%A8%A1%E5%9D%97%E4%B8%8E160%E6%8B%8D%E5%B8%BD%E7%9A%84%E9%9D%99%E6%80%81%E5%86%B2%E7%AA%81/thread.md)
- [C062 · SM007 AT015–019：直接 F32 除法单 lane 证据](../../communication/C062_SM007%20AT015%E2%80%93019%EF%BC%9A%E7%9B%B4%E6%8E%A5%20F32%20%E9%99%A4%E6%B3%95%E5%8D%95%20lane%20%E8%AF%81%E6%8D%AE/thread.md)
- [C063 · SM007：8拍加法IP的次正规反例](../../communication/C063_SM007%EF%BC%9A8%E6%8B%8D%E5%8A%A0%E6%B3%95IP%E7%9A%84%E6%AC%A1%E6%AD%A3%E8%A7%84%E5%8F%8D%E4%BE%8B/thread.md)
- [C064 · 用户暂停M006工程](../../communication/C064_%E7%94%A8%E6%88%B7%E6%9A%82%E5%81%9CM006%E5%B7%A5%E7%A8%8B/thread.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
