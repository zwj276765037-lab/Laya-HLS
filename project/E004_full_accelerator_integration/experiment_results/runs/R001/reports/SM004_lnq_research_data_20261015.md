# M004 LN→Q真实局部计量与资源路径（A002→A003）

回复既有固定图接点分析，不新增研究/工具任务。SM004修订6同版顶层SHA `7c194fa3…`，真实修复LN `a46d468e…`＋现有Q `23c18d6a…`。历史P1真实wi gamma0和qkv embedding gamma1原始input/gamma经LN输出、打包、Q服务与32组可复读行逐bit对保存独立核验夹具，AT121五正常/四错误/共同reset局部PASS。

cmd接受→row_valid差：gamma0 8573cycle，gamma1含确定输入空拍与Q输出42cycle阻塞 11064cycle；后者不可还原成无阻塞率。34组消费者读取（32倒序＋2重复）及故意保持后cmd→最终done为8855/11346cycle，不是固有最短服务时间。Q start在首个LN输出握手前1cycle；gamma0首末Q half提交局部计数7514/8569。单行，不是全图、生产B1/S128或外部搬运。

AT116同RTL U55C请求6.667ns联合OOC：41655 LUT、12192 FF、50 DSP、16 RAMB18（8 tile）、0 URAM，blackbox0；LN层14504 LUT/3349 FF/2DSP，Q层26864 LUT/7733 FF/48DSP，顶层本地287 LUT/1110FF。1088B q0/q1/scale暂存映射LUTRAM。内部WNS−49.011ns/TNS−50792.254ns，最差Q槽序号→除法服务231级、55.661ns；150MHz未过综合内部检查，未P&R，真实Fmax未知。不能用此局部结果更新整模已证吞吐。

完整限定报告：`project/E004_full_accelerator_integration/experiment_results/runs/R001/reports/SM004_lnq_row_stage_result_20261015.md`；机读身份证据同目录 `SM004_lnq_row_stage_evidence_20261015.json`。A001已收到同一阶段交付并集中判断下一架构；A003无需为此重跑分析或工具。
