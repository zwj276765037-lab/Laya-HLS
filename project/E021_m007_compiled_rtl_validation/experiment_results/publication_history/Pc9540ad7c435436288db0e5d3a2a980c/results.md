# E021：阶段结果

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

下列为R001/R002及R003运行中里程碑的历史记录；当前终态以上述封存为准，原局部通过和原失败保持各自身份。

当前D34/R002：原kind7第一完整层PREFIX_PASS；原独立Decision0/Decision1分别完整PASS331.587451345/339.304330790s。全部原数值/输出/成功DONE/真实idle保持；完整30层及tail尚未验，正式E仍UNKNOWN。

AT034 完整 Encoder0 原 gold 检查 PASS 并正常退出，KIND5/PACKED0、全部 STOP0，guard323.414508077s；完整图和30层未验。

原严格 ADD/MUL/DIV 全 fixture PASS：191904/217304/191792 向量，checked192077/217477/191965，8/8/32拍、II1、CE/reset 通过；有限域含次正规、RNE、正负零、溢出和渐进下溢，不签 NaN/Infinity 输入或完整除零域。当前 canonical shared4：4424 scalar/1106物理8拍返回，lease/holding/epoch/debt/reset/CE 全 PASS。local runtime 修复后 AT022..025 重跑上述完整原 fixture，原 XSim 语义逐字一致。

AT026 原 gold QKV1 PASS16.559499569s，8192值/10343周期；92事件前86与原 XSim 实际前缀同。XSim AT043 本身仍为60s COST_STOP，无独立完整 QKV1 终点。AT028 仅明确 context.threads(1)，实测1线程，QKV1相同92事件，guard15.875772194s、child CPU15.751574s。AT029 同 exe 原首头终点 PASS80.731986104s，312事件、head0=11038周期。

AT030 model4/context4 新翻译61.370062966s，793cpp；全 fresh dispatcher319.042622438s。AT031 原首头 FAIL39.644363088s，前302语义同A，score完成后无prob；AT032只读observer仍同原Fatal，首sm error phase9/rank4009000000000000，protocol_bad始终0。SHIFT负有限检查/EXP非有限两原分支未区分，无多线程等价或加速结论，此线关闭。

AT033 model1/context1 全STOP0分段探索 FAIL200.518451504s，18连续阶段退休、16HEAD全过、ATTENTION_END heads16/c241720/layer178777。随后原TB341因先检查新读而仍持旧credit错误判失败；生产适配器合法同拍消费旧响应并接受新读。原失败与原TB不变。

AT034 505e同top后继先原响应检查后原读检查，翻译PASS48.465578970s、构建PASS24.992994920s，744归档成员逐一核验，733对象复用/11TU重编，4头全同、857传递依赖绑定。预备兼容性证明实测19.423138976s；replay watchdog PASS0.186808801s。新exe SHA a89f22ad7d2881d258517307729bd8372aaa4ae8dfb32e153ed42477cda62d7c。实际16HEAD与ATTENTION_END c241720@180.534398s，WO开始c245911@183.168814s，已越过旧context失败点；LN_END c284603@210.860668s，完整FFN/Down/残差F/final输出原检查全部通过，25/25连续阶段，最慢72.772360049s；末段含正常退出2.648246989s。COMPLETE_PASS与精确hardware terminal各一次，rc0、无Fatal；最终131072输出值、last cycle430122。child wall323.264521583s/CPU323.265926s，实际1线程，aggregate RSS峰96204KiB。AT033全部493语义行逐字为新运行前缀；原AT027354前缀亦全同。

当前完成receipt计 raw static1364.284120206s/RTL937.993390574s；已知开销含新实测prep后保守static1462.366688450s，剩337.633311550s。RTL剩862.006609426s，留300后562.006609426s；未用余额封存，不转移到后继完整图实验。其余未测准备/包装开销UNKNOWN，不能填0。详见R001/budget_current.json。

清理AT013..027已知2495身份、AT028..033另2455身份均无存活/僵尸。实际政策采样无不匹配；旧AT0122、AT013/154、AT0301和AT034短replay1个已观察瞬态policy UNKNOWN保留；不声称全瞬态100%采样。无OOC/P&R/板卡/部署结论。

实际公开输出 actual_public.f32.bin 524288B，SHA9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b；capture.complete=true，4096组唯一、无坐标/重复错误、1成功parent receipt、all_resources_retired。4096条实际accepted payload独立重建与bin全同；输入亦同样核验。见AT034/actual_output_integrity.json。AT034另43已知PID/start清理无存活/僵尸；真实运行/翻译/构建policy匹配，0.1868s replay未知1个实采缺口不冒充通过。

D34/R002 AT004首次真实kind7 pilot COST_STOP119.134035030s，inner按119s帽主动终止(rc-15)，outer triggerNone、无SV Fatal。唯一BEGIN/原H4096组已完成且实际H0.bin与原embedding_norm逐字相同；global0 QKV成功m_done c62635@51.743702776s，headmask0..7完成至255/c153057@118.584199577s。最后actual retired121216/c153536，原checked最后151553/PUBLIC_H/c6822；无层checkpoint、WO/LN/FFN/Decision/tail终点。childCPU118.948071s、1线程、aggregateRSS52528KiB。不能把retired当独立gold通过。完整图E仍UNKNOWN，未开长跑门。

R002完整freshbuild742/742、13批dispatcher246.814782407s、最大guard批64.172115202s，patch+main-only overlay1.964807537s。rawstatic322.137245461s/RTL119.134035030s；已知dispatch额外16.066160809s+绑定prep1.201752902s后保守static剩860.594840828s，RTL剩7080.865964970s(留600后6480.865964970s)，其他未测开销UNKNOWN。2278已知PID/start清理无存活/僵尸；实际policy无不匹配，但新增15瞬态缺实采UNKNOWN，R001既有8缺口保留。


D34/R002 AT005原kind7第一完整层PREFIX_PASS，guard336.444740312s，25/25连续成功段，最大81.945932269s（LN到全Wi/G/quant后Down准入），原global0层端点c424292@336.277564210s。childCPU322.111295s、1线程、aggregateRSS52484KiB；原kind7请求仍未完成，rc−15为约定前缀停止。真实4096组H接口低沿捕获/次posedge原count和32bank验证，131072F32/524288B与原encoder_00_out逐位一致；accepted trace独立重建相同，SHA9d1c8d619b5e29565ed37845bef4168986b90d0480b1e8f96b16f1507272e55b。848601eval/424292逻辑cycle，约2eval/cycle；观察开销未单独测量，不将wall−CPU差单独归因。

AT006精确删除590个已证空body跨TU调用，两个caller之外不变、inverse恢复原字节，build3.377425872s。AT007原baseline/AT008删除版同QKV+head0终点c75749，803条非路径语义/周期逐字同；guard60.045392728/61.124764183s，CPU59.875146/60.928984s，B/A=1.017600592。未观察收益、未采用；单pair不证明稳定回退。只读预处理探针未被guard实采，政策范围UNKNOWN。

AT009对未改baseline稳态head1/部分head2做15CPU秒PC诊断，1455样本/0drop，窗口CPU14.998693s/wall15.000767s，guard76.581054751s；该诊断不作无扰动测速。99.04%落本exe，最大TU70仅4.33%、TU528为3.09%，热点分散；主函数act_comb1944为3.99%，VL_CONCAT_WWI helper3.71%未唯一归属TU，不能全归runtime或据此前3TU承诺大加速。原语义/周期前缀同AT005，PC只读固定数组采样，不写RTL。

AT010 kind6公开ABI后继翻译PASS53.662231884s，合法10单元增量buildPASS25.136556562s，732对象复用/所有生成头和PCH兼容。26段driver replayPASS0.178406874s，11拒绝例含FC2缺ACK/发布/实际接受、FC1BEGIN与计数不重置帽。原完整Decision0实际运行中，preLN c23541@18.916696693s、QKV c79294@62.056237448s；尚未签完整Decision或30层终点。

截至AT010实际RTL收据前，R002已完成guard rawstatic407.308841606s/RTL653.329987004s，另已知dispatcher16.066160809s和绑定prep1.201752902s，保守static剩775.423244683s；RTL剩6546.670012996s（留600后5946.670012996s）。AT010活动RTL尚待实扣，帽600s。其它未测准备/包装费用UNKNOWN含本次身份核对，不填0；无R001余额转移。2356个已完成guard的已知PID/start无存活/僵尸，0实采policy不匹配、16瞬态未实采UNKNOWN，旧R0018缺口保留；活动RTL不在清理声明内。


AT010现已完整Decision0 PASS：guard331.587451345s、childCPU331.422054s、实际1线程、rc0，26/26段，最大55.454296561s（postLN到全FC1/ReLU/quant16384write/ACK及成功发布后的FC2真实准入）。原global28/checkpoint30 c443185@328.774175704s，FC2成功326.043538335s；完整4096组公开输出、heldDONE消费、真实global/transport/W idle及精确原PASS后正常退出c447331。实际H0与原type_add逐位同SHA9f1eb1d4a057d36454a5c23a6a7c682798a857f3b3b589fad59a193f34f11f67；actual capture/public output与原decision_00_out逐位同524288B/131072F32，SHA44ea5ccbea5e2cbcee8c5a4cc79ecadf31482798b5d71b5f301c393faeb90546，4096唯一trace独立重建相同。见AT010/actual_decision0_integrity.json。

AT011同exe原kind6/local1完整Decision1实际运行中，参数/输入预检0.106118136s、派生0.001052279s、replayPASS0.184934068s，无构建，global29/checkpoint31/原输入期望绑定已核。总500s/连续120s，计划E457.643059316s；不代签kind7。

整图条件规划按原10full/18sliding/2Decision固定工作量、setup/H只算一次，代理10189.162061382s=2.83h；规划9170.245855244–12856.452576728s=2.55–3.57h，上沿1.25×代理+120s未测tail，仅工程余量，正式E仍UNKNOWN。滑窗finite mask不裁QK/AV完整调度，不能按面积大减；未测sliding完整层/final gamma/type/tail/连续kind7交接保持缺口。需约2.83×中央或3.57×上沿实测提速才合3600s。具体最小完整计划见R002/fullgraph_cost_plan_after_Decision0.md：同exe一次原kind7，另需主控新13000单次/独立RTL13600含600保留成本合同，当前未启动。


AT011最终完整Decision1 PASS，guard339.304330790s、CPU339.117550s、实际1线程/rc0，26/26段、最大57.076149449s，原global29/checkpoint31 c443185，最终c447331。实际input H0与原decision_00_out逐字相同SHA44ea5c...；capture/public与原decision_01_out逐字同524288B/131072F32，SHA2403ecaadd4ff375be7b2904b5da6659ef3b4b50faaf79beafd8cff46de7f26a，4096唯一trace独立重建相同。见AT011/actual_decision1_integrity.json。D0/D1的26个实际成功cycle边界全部相同，CPU比1.023221；不推定其他层数据成本相同或kind7连续依赖通过。

最新两Decision实际加权代理10196.799374348s；条件规划9177.119436913–12865.999217935s，形式整图E仍UNKNOWN。R002完成guard rawstatic407.493775674s/RTL1324.221769139s；已知开销后static余额774.904982639s，RTL余额5875.778230861s（留600后5275.778230861s）。其他未测准备/包装仍UNKNOWN，不填0；只读成本报告曾一次语法错误，原失败记录保留、无重工具启动。全部2361已知PID/start清理无存活/僵尸，0实采policy不匹配，17瞬态缺实采UNKNOWN、旧R0018缺口和未guard准备范围保留。两Decision已正常退出，当前无A012重工具运行。

AT010增量归档成员事后只读复核PASS0.226243369s：原归档历史manifest SHA相同，原742成员逐个等于实际成功对象hash；后继742成员逐个为732原对象+10新成功对象，fixed runtime对象亦等于原overlay收据。见AT010/postbuild_archive_member_integrity.json；此已知分析费用纳入保守static。


D35 R003 AT001_original30_kind7实际启动，复用exe151e9ba1、原86629840 TB/f4d peer及原embedding_norm一次BEGIN，未构建新模型。guard replay PASS0.220941165s：原AT005、010、011实际事件到各层capture通过，30层782段synthetic与缺事件/乱序/帽触发拒绝分列。实际每10s采样1线程，当前首层FFN真实退休；不把初始通过或synthetic算作整图。

额外整段交接监督已在唯一运行进行中追加（原driver冻结不动），原layer27端点→finalLN91→type96→Decision0 preLN86合计120s，时间锚来自原wall_events且以kernel原PID启动下界保守约束，不由附加到达时间或中间成功重置。自测PASS四边界，实际CPU0–3/nice19/idle采样匹配。最终原guard/driver和该监督必须共同通过，任何缺失不得整图PASS。

D35当前已实际连续完成global0..4（5/30）原H，各4096唯一组/524288B、原gold逐字及trace独立重建通过；global4端点c2160284@1633.260509027s、本层326.745794537s。后继仍由实际RTL连续计算。所有保护未触发，完整整图终点仍待实际发生。

D35已实际连续完成global0..9（10/30）原H，各4096唯一组/524288B与原gold逐字及trace独立重建通过；global9端点c4330274@3286.143362020s、本层338.475548483s。后继原请求继续，无错误或保护触发。

D35实际连续完成global0..14（15/30）全部原H，240个head已通过；各层4096唯一组/524288B与原gold逐字及trace独立重建通过。global14端点c6500264@4939.466163020s，本层328.485945540s；当前global15继续，无错误/保护触发。用户要求本次验证和最终核验/清理/归档完成后暂时暂停项目，不接续新实验。

D35实际连续完成global0..19（20/30）全部原H，320个head已通过，各层4096唯一组/524288B与原gold逐字及trace独立重建通过。global19端点c8670254@6565.892137805s，本层315.559138071s；原请求继续，无错误/保护触发。完成本次最终核验与归档后按用户要求暂停。

D35实际连续完成global0..24（25/30）全部原H，400个head已通过；各层4096唯一组/524288B与原gold逐字及trace独立重建通过。global24端点c10840244@8141.317554924s，本层314.802984323s；global25连续推进，final gamma/type/两Decision及tail仍待实际发生。原保护无触发，完成后按用户要求暂停。
