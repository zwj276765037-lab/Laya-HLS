# E021：同源码编译式 RTL 交叉验证

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
applicability: D35/E021/R003唯一原kind7请求已完成失败归档；28个实际Encoder层通过，final gamma LN原断言失败

当前D35以原连续输入、同一exe及冻结TB/gold运行，无新构建或中间注入；事后28层实际H/trace和958项冻结身份全部核验通过。final gamma LN的复合原断言失败，精确子条件UNKNOWN，完整30层、type、两Decision与tail未通过。本轮监督合并、owned清理和独立预算封存已完成，按用户要求暂停。证据见experiment_results/runs/R003/attempts/AT001_original30_kind7/final_merged_receipt.json与first_fatal_bounded_analysis.json。

下文保留历史方法和各批次原适用范围；历史阶段的“未验”不改变当前失败终态。
任务 M007/SM012 D33/D34，工程 A012。生产 RTL、原 gold、历史冻结测试程序只读。runner 仅在 E002/experiment/tools/m007_verilator；证据在 E021/R001（封存）和独立R002。R001后继为原 owner 冻结的 505e0b93…f9327 同 top TB，仅交换完整旧响应/新读请求 observer if 块，全部原谓词、数据检查、时钟、延迟和参考输入保留；原 172d…TB 和 AT033 原失败不覆盖。

R001使用93源闭包，Verilator 5.020 + local fixed-batch-v1 + converge512，model1/context1。stock 连续 #0 SIGSEGV 与 default100 nonconverge 原样保存；local runtime 仅对实际初始化/reset 范围经 XSim 同源混合时序 13 事件交叉核验，不泛称完整 SV 调度等价。原 residual scalar→group32 无损 pack 的 131072 scalar/524288 字节与原 bin 全同，原 gold 未重生成。

AT034 新翻译 744 C++ 单元、4 生成头全同，11 TU 实际变化；733 成功对象按源字节、完整归档成员、857 传递依赖、PCH、实际原 g++ 参数验证后复用。实际编译 fast -O2、slow -O1，runtime -Os；Verilator -O3 是翻译优化。原对象和旧归档不改。explicit context1 main 与 AT028 已验证 main 逐字相同。

完整 Encoder KIND5/PACKED0、所有 STOP0；全局 800s、25 个连续退休阶段各 ≤120s、真实 checked 停滞120s、RTL8GiB/40Mcycle，启动剩余 RTL≥1100s 且保留300s。必须完整数值终点、精确 hardware terminal 和正常退出同时满足才签完整层 PASS。只读辅助观测和协议静态审计不替代该终点。

单重工具锁，CPU0–3/nice19/idle、MemAvailable>192GiB；static24GiB，R001 static1800s/RTL1800s；reference0/OOC0。两态证据不替代 XSim 四态、X 传播或未初始化检查，无 OOC/P&R/板卡/30层结论。实际 model/effort UNKNOWN。

D34/R002独立接续原kind7 once-BEGIN28+2/真实120descriptor原BO peer。top8b55不变；A010 f4d仅同always内4port顺序展开以兼容数组NBA，inverse精确恢复旧4d。guard19例验证原checked与真实retired两严格高水位分开，OBS/PHASE不刷新stall。新top全fresh742对象；主入口context1并只读实际state/headmask/matrix_done、无额外eval/写信号。R001未用预算不转。


D34当前AT010采用A010冻结86629840 kind6公开ABI后继，仅非kind7的qtype/marker/mask/count归零，原kind7赋值序列和其余93源不变。新翻译742cpp、4生成头与2make片段全同，只有9模型TU与main不同；732个原成功对象按实际源、.d依赖、生成头、原PCH字节、同cwd及原g++ flags验证复用，10单元重编，fixed-batch runtime不改。见R002/attempts/AT010_kind6_public_abi/incremental_reuse_proof.json。系统头未另作历史追溯哈希，沿实际原PCH及当前原runtime头身份；未将仅cpp相同当作可复用充分条件。

按D34完整独立kind6/local0运行原type_add输入→preLN→QKV/16head/Attention/WO/resA/postLN→全FC1/ReLU/quant16384实际write/ACK/唯一覆盖/producer_close成功发布→FC2真实接受/成功→resB→原4096组输出/成功heldDONE消费/真实idle/正常退出。26连续段各120s、总600s，FC1BEGIN和计数不重置段帽，启动RTL余额≥1200以留600；所有原checker与131072值gold保留。main按global_layer通用捕获真实低沿接口并在次posedge核原count和32bank实写，唯一4096组记录成独立产物；无额外eval、无DUT写。捕获不能替代原TB，独立Decision输入不能注入kind7替代前驱。


AT011按主控后继授权复用AT010同exe，独立kind6/local1/global29/checkpoint31，输入原decision_00_out（decision1_input.hex实重建一致）、期望原decision_01_out；不重译/不构建。E=331.587451345×1.35+10=457.643059316s，总500s/每连续段120s，启动余额≥E+600，原独立R002总额不增。只派生global29独立driver与必要参数预检，原AT010 driver/产物不覆盖。

AT010最终归档进一步逐成员核验：742原成员对原成功对象hash全同，后继全部742成员精确为732复用+10新编译；fixed runtime对象对原overlay收据hash相同。未只凭独立对象文件存在就断言归档输入一致。


D35/E021 R003独立接续一次原kind7完整30层，reference0/static300/RTL15600（留600）/OOC0、单次15000s为主控明确任务特例；不转R002余额。精确复用AT010/011同exe及generic all-global capture，94源/数学对象/四头/PCH/原flags/输入按实际manifest重新验证，无模型或main重编。冻结driver用原真实组件事件回放，synthetic跨层例仅验保护逻辑，不能代签真实跨层；实际运行逐层验证。

逐层≤600s、连续真实成功阶段≤120s、整体≤15000s，outerguard只认独立checked/真实retired严格高水位续stall120s，不续阶段。首层省preLN，后续preLN后QKV；跨层新matrix_done读TB30项独立数组初值0，残留head mask仅在QKV前忽略，真实prepare后的QKV要求mask0再每head严格推进。Encoder27 final gamma N_RETIRE91/type T_RETIRE96/Decision0 preLN86显式识别；另挂独立整段120s原事件锚监督，原冻结driver不修改，最终双监督缺一不得PASS。Dec1后544原尾写/flush/延迟commit/DONE/idle/正常退出为合一120s段。
