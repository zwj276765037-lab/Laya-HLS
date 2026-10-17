# ATN1正常完整head进展审核

2026-10-13；M004/SM005/E005/R001；回复`measurement-first-ATN1-full-progress-20261013`，沿D-M004-ATTENTION-MEASUREMENT-01。**接纳AT021正常完整head的限定数值与周期进展；ATN1采用结论仍待协议回放收束。** AT022是同一DUT的受影响验证，不计第二优化候选，按原合同继续，无新审批或预算。

| 同口径边界 | ATN0 | ATN1 | 减少 |
| --- | ---: | ---: | ---: |
| SM接受→首次done | 287173 | 265084 | 22089 / 7.6919% |
| SM接受→实际consume | 287197 | 265108 | 22089 / 7.6912% |
| QK+SM+AV首次done之和 | 604317 | 582228 | 22089 / 3.6552% |
| 全TB | 1608896 | 1586807 | 22089 / 1.3729% |

原全部中间/最终逐位gold、M/A/D/EXP工作量、QK250888、AV66256、load140288及191088次受理/退休配平核对。SM互斥MAX2176+EXP248436+TREE8576+DIV5888+接受/报告8=265084；净差只在EXP区间。所有数字仍限模块仿真与原profile，不代表部署频率、物理资源或完整请求。

四worker总core-busy保持898680 slot-edges，launch/done/commit均16384；原算术服务量没有减少。ASUB请求16000→4096、lane16384不变，说明候选同时改变准备/分发与请求分组，不能把全部收益唯一归因某一项。

新的worker input_wait147456→16384已换了状态含义；commit_wait17143→27304、idle18821→51376。四worker非core总变化88356=4×22089，只是状态账闭合，不能把input_wait少131072直接当省下的硬件周期。此前45855是条件乐观空隙，实际只签22089；剩余23766亦不构成下一候选授权。新staged_pending/ready驻留尚未进入AT021计量，不据其缺失臆算细分等待，也不为完善归因单独重跑完整head。

主控核AT021/AT022各93冻结源、318唯一引用、AT021 full的47项编译snapshot与静态构建副本、原log与两个JSON一致。AT021相对ATN0仅DUT/state生成器/state快照/runner四项变化，观察TB相同；AT022相对AT021仅协议TB及runner终态检查变化，DUT SHA均`11b7dff21ea5bf882444eac44a68316fe12b472d7d7c486108a75174a6017c16`。3段AT021与AT022 static的4段已结束guard串行，58实际policy符合原约束；AT021 full482.110123s、peak1108904KiB为工具成本。尚无阶段最终receipt，不把进展写成已收束采用。

AT022实际命令含`--protocol 1`；TB和runner显式要求原六类首错、四类原活动管线，以及新增pending/ready的CE保持和reset清空。已核准备值/key/控制进入候选state身份；协议运行中的部分marker不是整轮PASS。继续原guard自然收束，冻结输入不回改。最终交付把协议原终态/首错/CE/reset/重载/chain/ledger与本正常完整head身份一并关联。

最终摘要还请给出新准备槽的行完成/换epoch债务守恒依据，区分真实动态观察与源码不变量；本次normal调用ledger不是所有内部槽位的逐边沿审计。若采用已有源码论证，明确一批接受→返回→按完整key分发→EXP唯一提交与换行前排空的关系，不把reset清空替代正常排空。原179bit新增持久状态包含数据，选择/仲裁与物理代价仍UNKNOWN。

终态时一次同步三摘要及A002真实运行状态；当前state仍指AT021 full active，而已完成原guard与本消息已推进到AT022，状态纠正不阻塞在跑验证。保持一个候选及原有据修复上界，不扩队列/算子，不新增HLS/OOC/P&R/上板；整体控制、冷INIT、恢复停排，G仅OOC余额2338.224019s、5172s组合不重启，M003/M004未完成。

证据：[主控进展核验](measurement_first_ATN1_progress_review_20261013/verification.json)、[AT021 full计量](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/measurement.json)、[AT021原数值收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT021_ATN1_attention_prefetch_01/full_01/numeric_result.json)、[AT022冻结身份](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT022_ATN1_prefetch_protocol_01/source_manifest.json)、[原ATN0审核](measurement_first_ATN0_review_20261013.md)。
