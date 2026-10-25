# E021：执行状态

execution_state: paused
verdict: PASS
applicability: D36/E021/R004 SEGMENTED_SUFFIX修复验证通过；原D35/R003一次BEGIN全30层仍保留FAIL，不拼接为修复版端到端验收

本小阶段已完成并按用户要求暂停。A010仅将final gamma选择N_START改为N_START||N_RUN并保留默认关闭的测试入口；A012只改工具/采集/保护，生产RTL/TB/gold单owner不变。使用保存的actual Encoder27 H：524288B/131072F32，SHA964be7a3b198234aa78643f9dda0d538af70f04a31b2a71b8b652f17710f9f38；4096唯一trace重建、原gold逐位和实际整数pack/公开H提交往返均通过。没有完整仿真状态快照，未重跑原前28层。

AT003旧DUT实际接受final LN gamma0/c6926，原Fatal c7249/addr0/lane0/data_bad1，kind_bad/duplicate/offset_bad均0，parent/provider gamma均0。外层复现检查PASS只表示EXPECTED_FAIL_REPRODUCED，旧DUT数值FAIL；guard8.316856172s、无timeout、raw模型−9为Fatal后清理。原R003未打印的精确首错字段仍UNKNOWN，不回填。AT001源排序staticFAIL0.461008003s亦保留。

AT005 fixed短前缀PASS35.940922555s：actual finalLN/type全部131072值分别与原gold相同，并达到Decision0 preLN真实4096issued/written成功后计划停止。实际gamma1和普通gamma0命令均已观测，自然start→CMD延迟2拍中gamma/epoch稳定，未施加人为反压；该prefix不是成功DONE。

AT006同一后缀runtime完整PASS：guard710.2027710779803s、inner710.0231702890014s、正常模型rc0/driver0、outer trigger=null，精确SEGMENTED_SUFFIX终标一次。实际2层/8矩阵/32head/5LN/5VECTOR/0G，finalLN/type各4096唯一组，两个Decision各4096唯一组/524288B及独立accepted trace全部原gold逐位同。finalLN SHA6501eb1e…、type9f1eb1d4…、Decision0 44ea5ccbea5e2cbcee8c5a4cc79ecadf31482798b5d71b5f301c393faeb90546、Decision1 2403ecaadd4ff375be7b2904b5da6659ef3b4b50faaf79beafd8cff46de7f26a。真实544尾写/69632B全原tail544逐字，SHAa8698e55921b0300643a01f63bb38abc52e026af7251b526f02bddfbd6d9536f；flush/延迟1次commit/heldDONE真实消费/真idle/正常退出均通过原checker和receipt。结束cycle900777，两层实际H端点c463932/c900198。

55个连续成功段、最大59.677330977051s；Decision实际段343.047796896077/343.418064445956s。CPU710.317828s（user709.848576/sys0.469252），71次实际线程样本均1，aggregate RSS峰56836KiB、MemAvailable最低448049240KiB。5条实际LN命令gamma序列1/0/0/0/0；5次自然延迟均2拍、valid未接受总等待0拍，gamma/epoch保持全部通过。rows128为已生成常量、ready为精确源码alias，request/generation未额外采样，原identity checker保留；不签未施加反压覆盖或单独观察开销收益。

最终静态审计全量重核1654个唯一执行源码/输入/生成依赖身份一致。4525个已知guard及实际CXX wrapper/compiler PID/start无live/无zombie；实际政策样本0不匹配，2个已知瞬态未实采为UNKNOWN，start身份缺失0；未guard准备/作者/静态审计政策范围仍UNKNOWN。old/fixed fresh741TU均约271s，root头变化使对象复用门拒绝，只有历史成功fixed runtime按SHA复用；没有复用失败/未完成对象。

D36独立账本封存：实测static710.513908039895s、RTL754.460549805081s；余额static1089.486091960105s、RTL2845.539450194919s，扣300保留后2545.539450194919s。失败、旧DUT复现、prefix/main、A010已测准备0.748571869s及已测dispatch额外31.984008902s均计入；未测编写/旧main派生/分析/编排/报告成本UNKNOWN不填0；旧余额不转，剩余封存不接续。

范围仅本段真实后缀正常路径；原前28Encoder PASS保持原版本身份，R003完整请求FAIL保持；不声称修复版原kind7一次BEGIN30层、端到端性能、四态/全异常/OOC/P&R/上板或M007总验收。当前A012 paused，等待用户明确恢复，无新实验/修复/优化/物理工作。

终态证据：experiment_results/runs/R004/attempts/AT006_fixed_complete_suffix/final_suffix_receipt.json、actual_segmented_suffix_integrity.json、owned_cleanup_and_policy.json；账本experiment_results/runs/R004/budget_R004_sealed.json。原始guard/日志/实际输出和三类命令收据保留原路径。

以下为前阶段封存记录，执行状态以上述D36当前条目为准。

execution_state: paused
verdict: FAIL
applicability: D35/E021/R003 AT001原kind7连续Encoder0..27实际H通过；final gamma LN原断言失败，完整30层未通过

本轮唯一原kind7请求已结束，28层Encoder的实际H各4096唯一组，共14680064B/3670016F32，全部与原gold逐位一致，accepted trace独立重建亦相同；原H0与embedding_norm相同。事后只读审计及958项冻结执行身份核验通过。层27终点c12142238 @9084.95904364402s，448个真实head、727个连续成功阶段。final gamma LN已准入N_RUN90/c12142243，尚未达到N_RETIRE91。

原首Fatal：`[24285143000] %Fatal: m007_fullgraph_binary_tb.sv:257: Assertion failed in TOP.m007_fullgraph_binary_tb.unnamedblk2.unnamedblk8: original final gamma LN checkpoint`。该原断言包含kind、duplicate、epoch offset和写数据四类条件；精确失败地址、实际/期望数据及具体失败分支未打印，确切根因UNKNOWN。有限静态command-hold候选已单列于first_fatal_bounded_analysis.json，未作运行根因确认；未修改RTL/TB/gold或重跑。

双监督合并final_merged_receipt.json为FAIL：primary FAIL，额外Encoder27→finalLN→type→Decision0 preLN整段监督NOT_REACHED（起始锚已到、完成边界未到）；outer trigger=null，额外监督未触发超时且未终止leader。原Fatal在清理前发生；模型raw rc−9、driver/outer child rc1分别保留，不能改记为OOM或资源帽。guard实耗9085.828054456972s，inner9085.681099561043s，CPU9048.262627s（user9043.164454/sys5.098173），904次实际线程采样均1，aggregate RSS峰60860KiB、MemAvailable最低482667632KiB。最大已完成阶段80.20074991101865s，最大层338.4755484830239s。

本次type、Decision0/1及tail成功未到；最终.output.bin为0B，成功.receipt.txt不存在，无layer28/29捕获。R002的两个独立Decision PASS保持各自输入/版本/终点身份，不能拼接为本次kind7连续成功。

owned_cleanup_and_policy.json核对5个已知PID/start：live0、zombie0、policy mismatch0、已知身份缺实采0；未guard的准备/静态归档政策范围仍UNKNOWN，不声称全部瞬态覆盖。独立R003已实测static7.736686330987s、RTL9085.828054456972s；static余额292.263313669013s、RTL余额6514.171945543028s、扣600保留后5914.171945543028s。其它未测编写、分析、编排及报告成本UNKNOWN不填0；未转R001/R002余额。预算已封存，无OOC/P&R/上板/四态/全异常或M007整体验收结论。

按用户“完成验证后暂时暂停项目”要求，核验、双监督合并、清理、预算和证据归档已完成，A012登记paused；等待用户明确恢复，不接续修复、新实验、优化、物理验证或自动整图重跑。

证据位于`experiment_results/runs/R003/attempts/AT001_original30_kind7/`：final_merged_receipt.json、owned_cleanup_and_policy.json、actual28_encoder_prefix_integrity.json、first_fatal_bounded_analysis.json及receipt_*.json；封账为`experiment_results/runs/R003/budget_R003_sealed.json`。
