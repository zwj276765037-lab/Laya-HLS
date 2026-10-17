

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# M005 · 代表通路与整模性能可行性评估

[任务合同](contract.md) · [任务总结](../../results/missions/M005_summary.md)

## 执行子任务与主控审核

| 子任务 | 定义 | 完整审核历史 |
| --- | --- | --- |
| SM006 · 正确性资源时序与整模性能决策 | [定义](tasks/SM006.md) | [审核](../../results/reviews/SM006.md) |

## 关联实验

- [E006 · feasibility_assessment](../../project/E006_feasibility_assessment/README.md) — 未登记

## 任务总结原文摘录

# M005：代表通路与整模性能可行性评估——最终判断

execution_state: completed
verdict: inconclusive
investment_decision: stop_current_serial_implementation_branch
controller_decision: D-M005-FINAL-ASSESSMENT-01
updated: 2026-10-14

**本轮有界可行性评估已完成。当前串行实现不支持扩大工程投入；停止本轮实现与物理诊断分支。硬件可行性仍证据不足，完整加速器未验收。** 这项判断综合了真实功能失败、综合成本停止和全图条件模型；没有把评估完成写成硬件通过，也没有判定所有FPGA方案不可行。

| 用户问题 | 最终回答 | 证据及限制 |
| --- | --- | --- |
| 一条有代表性的完整通路能否稳定算对？ | **尚未证明。** LN→Q→Wi→G→Q→Down前缀及对应独立gold已到达，末残差未启动。 | AT073在cycle375074的Down→残差票据合取断言Fatal；3/3次full已用尽，无完整正常或独立合法反压样本通过。 |
| 综合资源是多少，关键路径能达到什么频率？ | **当前无法给出。** 没有有效联合网表、资源或时序报告，route未准入。 | AT087联合综合277.203887s达到任务24GiB owned RSS帽，峰25,205,756KiB。这不是器件fit失败；LUT/FF/DSP/BRAM/URAM/Fmax均UNKNOWN。 |
| 整模推理性能是否可观，值得继续投入吗？ | **当前条件预测吸引力不足，不支持扩大此串行路线投入。** | 假设150MHz、有效10GB/s及未测算子8cycle/单位，整模6.919–8.133s/请求；没有实测整模延迟、持续吞吐或同口径CPU/GPU加速比。 |

执行依据：[M005完整合同](contract.md)及其A1/R2/R3修订。主控已核最终工程原guard/日志、预算与A003[最终独立判断](../../source/feasibility_20261014/final_assessment.md)；[机读最终决定](../../results/feasibility_mission_20261014/final_decision.json)。以下结论是A001技术与排程决定，不是新的人类批准。

## 性能为什么不足以支持扩大投入

真实production-v2 B1/S128请求有72个有效token但物理计算128行，scorer16槽中2个有效候选但计算16槽；122次Q8共47,160,754,688 INT8 MAC。Attention QK/AV各503,316,480 FP MAC、LN 8,011,776元素、残差7,864,320次加法也计入预算，未用FFN乘层数替代全图。

下表来自冻结[v4预算](../../source/feasibility_20261014/v4/budget.json)与[研究报告](../../source/feasibility_20261014/report.md)。两列仅改变权重在128行/4行之间的复用；频率、10GB/s有效带宽及未测算子速率都是假设，**不是实测或有保证上下界**。原单request slot下模型完成间隔II＝延迟L，没有已实现的多请求流水吞吐。

| 假设频率 | 跨128行保留W：L/II | 仅跨4行保留W：L/II | 条件吞吐 |
| --- | ---: | ---: | ---: |
| 100MHz | 

（摘录截断；完整记录见链接。）

## 相关决定、变更与讨论

- [hardware_progress](../../results/hardware_progress.md)
- [measurement_first_ATN0_review_20261013](../../results/measurement_first_ATN0_review_20261013.md)
- [measurement_first_ATN1_close_20261013](../../results/measurement_first_ATN1_close_20261013.md)
- [measurement_first_ATN1_progress_review_20261013](../../results/measurement_first_ATN1_progress_review_20261013.md)
- [measurement_first_CT0_review_20261013](../../results/measurement_first_CT0_review_20261013.md)
- [measurement_first_FFN0_review_20261014](../../results/measurement_first_FFN0_review_20261014.md)
- [measurement_first_FFN1_destination_clarification_20261014](../../results/measurement_first_FFN1_destination_clarification_20261014.md)
- [measurement_first_FFN1_review_20261014](../../results/measurement_first_FFN1_review_20261014.md)
- [measurement_first_FFN2_review_20261014](../../results/measurement_first_FFN2_review_20261014.md)
- [measurement_first_FFN3_review_20261014](../../results/measurement_first_FFN3_review_20261014.md)
- [measurement_first_FFR0_review_20261014](../../results/measurement_first_FFR0_review_20261014.md)
- [measurement_first_FFR0_review_query_20261014](../../results/measurement_first_FFR0_review_query_20261014.md)
- [measurement_first_FFR1_connection_query_20261014](../../results/measurement_first_FFR1_connection_query_20261014.md)
- [measurement_first_FFR1_review_20261014](../../results/measurement_first_FFR1_review_20261014.md)
- [measurement_first_FFREF0_fadd_query_20261014](../../results/measurement_first_FFREF0_fadd_query_20261014.md)
- [measurement_first_FFREF0_result_handoff_20261014](../../results/measurement_first_FFREF0_result_handoff_20261014.md)
- [measurement_first_FFREF0_review_20261014](../../results/measurement_first_FFREF0_review_20261014.md)
- [measurement_first_GQD0_review_20261013](../../results/measurement_first_GQD0_review_20261013.md)
- [measurement_first_KB0_review_20261013](../../results/measurement_first_KB0_review_20261013.md)
- [measurement_first_KB1_reply_20261013](../../results/measurement_first_KB1_reply_20261013.md)
- [measurement_first_KB1_review_20261013](../../results/measurement_first_KB1_review_20261013.md)
- [measurement_first_KB2_stop_review_20261013](../../results/measurement_first_KB2_stop_review_20261013.md)
- [measurement_first_LNF0_review_20261014](../../results/measurement_first_LNF0_review_20261014.md)
- [measurement_first_LNQ0_review_20261014](../../results/measurement_first_LNQ0_review_20261014.md)
- [measurement_first_LNQ1_review_20261014](../../results/measurement_first_LNQ1_review_20261014.md)
- [measurement_first_LNQ2_residual_query_20261014](../../results/measurement_first_LNQ2_residual_query_20261014.md)
- [measurement_first_LNQ2_review_20261014](../../results/measurement_first_LNQ2_review_20261014.md)
- [measurement_first_LNQI0_review_20261014](../../results/measurement_first_LNQI0_review_20261014.md)
- [measurement_first_LNREF0_review_20261014](../../results/measurement_first_LNREF0_review_20261014.md)
- [measurement_first_LQ0_review_20261013](../../results/measurement_first_LQ0_review_20261013.md)
- [measurement_first_LQ1R_close_20261013](../../results/measurement_first_LQ1R_close_20261013.md)
- [measurement_first_LQ1_review_20261013](../../results/measurement_first_LQ1_review_20261013.md)
- [measurement_first_M003_schedule_reply_20261014](../../results/measurement_first_M003_schedule_reply_20261014.md)
- [measurement_first_P0_review_20261013](../../results/measurement_first_P0_review_20261013.md)
- [measurement_first_P3_design_review_20261013](../../results/measurement_first_P3_design_review_20261013.md)
- [measurement_first_QAR0_review_20261014](../../results/measurement_first_QAR0_review_20261014.md)
- [measurement_first_QWIGQD0_review_20261014](../../results/measurement_first_QWIGQD0_review_20261014.md)
- [measurement_first_WI0_review_20261013](../../results/measurement_first_WI0_review_20261013.md)
- [measurement_first_WIGQD0_review_20261013](../../results/measurement_first_WIGQD0_review_20261013.md)
- [measurement_first_WIGQD1_review_20261013](../../results/measurement_first_WIGQD1_review_20261013.md)
- [method_verdicts](../../results/method_verdicts.md)
- [mission_scope_revision_20261011](../../results/mission_scope_revision_20261011.md)
- [overview](../../results/overview.md)
- [review_queue](../../results/review_queue.md)
- [C016 · 用户要求立即调转重心：先停止旧关键路径扩张](../../communication/C016_%E7%94%A8%E6%88%B7%E8%A6%81%E6%B1%82%E7%AB%8B%E5%8D%B3%E8%B0%83%E8%BD%AC%E9%87%8D%E5%BF%83%EF%BC%9A%E5%85%88%E5%81%9C%E6%AD%A2%E6%97%A7%E5%85%B3%E9%94%AE%E8%B7%AF%E5%BE%84%E6%89%A9%E5%BC%A0/thread.md)
- [C017 · GQD0 上游 Wi 接点只读核对](../../communication/C017_GQD0%20%E4%B8%8A%E6%B8%B8%20Wi%20%E6%8E%A5%E7%82%B9%E5%8F%AA%E8%AF%BB%E6%A0%B8%E5%AF%B9/thread.md)
- [C018 · LN ROM prelaunch guard prepared after AT048](../../communication/C018_LN%20ROM%20prelaunch%20guard%20prepared%20after%20AT048/thread.md)
- [C019 · M003普通Q/L逐窗口生产接入：请求集中合同](../../communication/C019_M003%E6%99%AE%E9%80%9AQ_L%E9%80%90%E7%AA%97%E5%8F%A3%E7%94%9F%E4%BA%A7%E6%8E%A5%E5%85%A5%EF%BC%9A%E8%AF%B7%E6%B1%82%E9%9B%86%E4%B8%AD%E5%90%88%E5%90%8C/thread.md)
- [C021 · M005现在执行：完整代表通路、资源时序与整模可行性](../../communication/C021_M005%E7%8E%B0%E5%9C%A8%E6%89%A7%E8%A1%8C%EF%BC%9A%E5%AE%8C%E6%95%B4%E4%BB%A3%E8%A1%A8%E9%80%9A%E8%B7%AF%E3%80%81%E8%B5%84%E6%BA%90%E6%97%B6%E5%BA%8F%E4%B8%8E%E6%95%B4%E6%A8%A1%E5%8F%AF%E8%A1%8C%E6%80%A7/thread.md)
- [C022 · M005立即并行：独立整模流水性能与可行性预算](../../communication/C022_M005%E7%AB%8B%E5%8D%B3%E5%B9%B6%E8%A1%8C%EF%BC%9A%E7%8B%AC%E7%AB%8B%E6%95%B4%E6%A8%A1%E6%B5%81%E6%B0%B4%E6%80%A7%E8%83%BD%E4%B8%8E%E5%8F%AF%E8%A1%8C%E6%80%A7%E9%A2%84%E7%AE%97/thread.md)
- [C023 · M005整模预算：容量、复用与计量缺口](../../communication/C023_M005%E6%95%B4%E6%A8%A1%E9%A2%84%E7%AE%97%EF%BC%9A%E5%AE%B9%E9%87%8F%E3%80%81%E5%A4%8D%E7%94%A8%E4%B8%8E%E8%AE%A1%E9%87%8F%E7%BC%BA%E5%8F%A3/thread.md)
- [C024 · M005代表top：LN→Q物理读债接线决策](../../communication/C024_M005%E4%BB%A3%E8%A1%A8top%EF%BC%9ALN%E2%86%92Q%E7%89%A9%E7%90%86%E8%AF%BB%E5%80%BA%E6%8E%A5%E7%BA%BF%E5%86%B3%E7%AD%96/thread.md)
- [C025 · M005静态发现：G接收的K是未声明单点信号](../../communication/C025_M005%E9%9D%99%E6%80%81%E5%8F%91%E7%8E%B0%EF%BC%9AG%E6%8E%A5%E6%94%B6%E7%9A%84K%E6%98%AF%E6%9C%AA%E5%A3%B0%E6%98%8E%E5%8D%95%E7%82%B9%E4%BF%A1%E5%8F%B7/thread.md)
- [C026 · M005 AT065：Down受理前四态未知，诊断full失败](../../communication/C026_M005%20AT065%EF%BC%9ADown%E5%8F%97%E7%90%86%E5%89%8D%E5%9B%9B%E6%80%81%E6%9C%AA%E7%9F%A5%EF%BC%8C%E8%AF%8A%E6%96%ADfull%E5%A4%B1%E8%B4%A5/thread.md)
- [C027 · M004用户已批准：立即开始完整软件基线与最简架构接点实验](../../communication/C027_M004%E7%94%A8%E6%88%B7%E5%B7%B2%E6%89%B9%E5%87%86%EF%BC%9A%E7%AB%8B%E5%8D%B3%E5%BC%80%E5%A7%8B%E5%AE%8C%E6%95%B4%E8%BD%AF%E4%BB%B6%E5%9F%BA%E7%BA%BF%E4%B8%8E%E6%9C%80%E7%AE%80%E6%9E%B6%E6%9E%84%E6%8E%A5%E7%82%B9%E5%AE%9E%E9%AA%8C/thread.md)
- [C028 · M004已批准启动：固定计算图与最简吞吐架构核查](../../communication/C028_M004%E5%B7%B2%E6%89%B9%E5%87%86%E5%90%AF%E5%8A%A8%EF%BC%9A%E5%9B%BA%E5%AE%9A%E8%AE%A1%E7%AE%97%E5%9B%BE%E4%B8%8E%E6%9C%80%E7%AE%80%E5%90%9E%E5%90%90%E6%9E%B6%E6%9E%84%E6%A0%B8%E6%9F%A5/thread.md)
- [C029 · M004固定图架构：有限接点问题（A003→A002）](../../communication/C029_M004%E5%9B%BA%E5%AE%9A%E5%9B%BE%E6%9E%B6%E6%9E%84%EF%BC%9A%E6%9C%89%E9%99%90%E6%8E%A5%E7%82%B9%E9%97%AE%E9%A2%98%EF%BC%88A003%E2%86%92A002%EF%BC%89/thread.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
