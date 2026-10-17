# FFR1集中审核：局部残差限定接纳

2026-10-14；A001→A002；M004/SM005/E005/R001；R-SM005-FFR1-20261014。回复`measurement-first-FFR1-AT054-scoped-result-20261014`。主控只读核文件、源码、原日志及计量，未运行参考、DUT或综合。

## 接纳范围

**AT054接纳为PASS_SCOPED_LOCAL_FOUR_ROWS。** FFR1针对原FFR0的错误码、实际计数停滞保护与缺失计量，在本冻结runtime/profile下已取得所需有限证据。外部AT050 skip/Down经单个原生成F32叶子，4096结果逐bit独立gold、两源各256 AR/R、目的256 AW/W/B及三个64KiB共196608B保护终扫保持；仍是两份声明外部源的局部RTL。

[主控核验](measurement_first_FFR1_review_20261014/verification.json)重核当前16项manifest及AT052/AT053继承项，共44条引用、69个不同证据路径；当前槽/叶子/52例TB与gold、skip/Down/末输出均与原SHA一致。DUT精确diff仅数值8→6、AXI常量改E_INTERNAL8及三个使用点，正常数据路径不变。原AT052 `FFR0_FADD_SLOT_PASS count=52`按未变完整闭包复用，无新52例运行；原round1_02的RNE marker与AT052槽marker属于不同历史层级，不混为本次日志。

原枚举E_NUMERICAL6的NaN/有限溢出两例、E_PROTOCOL7的五描述符，以及首skip R/Down R/B非OK映射E_INTERNAL8的三例均有实际有限回放。B非OK真实退休1 AW/W/B，第一64B写入gold，目标未成功发布；没有将其说成零写。响应至少七拍保持、一次消费及有限债务检查通过；不签畸形RLAST、所有首错组合、取消恢复或生产16bit完整错误包。当前cfg_context是416bit不透明回显，标量身份另查固定子集，不能当完整生产Context校验。

## 可复算的计量和guard

正常cfg接受61，末W103325/末B103340，局部目标有效及响应首次103341，实际消费103349；**含两端采样边沿为103289cycle，通常的端点差为103288**。11项互斥状态周期`1/305/1042/288/1484/4096/94208/283/281/1292/9`求和103289。4096项add接受→真实返回直方图仅22cycle、sum90112，另有4096次返回槽消费；不继承Xilinx11拍，也不当完整FFN延迟。

双源首末AR/R、局部源锁62→102939、末读退休102938和目标有效升边沿均按posedge预NBA口径实际打印并核对。103350是正常终扫打印点，后续错误探针仍执行；最终$finish1038820ns按10ns时钟可推算103882周期，但不是原日志直接打印的冷TB周期。绝对坐标受先行探针影响，不报性能收益或部署频率。

模拟阶段243条进展记录均有12项实际握手/返回/消费累计计数至少一项严格增长，未见倒退或重复通过。四个冻结host序列已独立复算：周期快照/重复计数不续命、实际计数推进更新、倒退被识别。实际Tcl仅一次SIM_START；当前guard仍有重复SIM_START可再次更新时间的分支，本次没有发生，不扩大为任意日志序列安全证明。后继复用guard时把此阶段转换改为一次性并补host反例，作为运行准备一并完成，不重跑本次旧样本。

host/static/error/pilot/full五段串行child0/null；四段工具104条实际CPU0–3/nice19/idle样本匹配。host约0.177s结束，没有policy文件或RSS捕获，实际host资源采样UNKNOWN；只认可其启动约束和逻辑测试结果。static/error/pilot/full为21.888815/25.840606/25.981984/26.254724s，full峰1383240KiB。成本207.855870s=本次单行25.981984s×8，250000cycle估计均低于原帽；成本文件原mtime先于full启动记录，JSON本身没有独立at字段，不补造时间戳。

按当前RTL声明位宽，残差producer数据1536bit/控制与context及计数594bit，槽数据96bit/控制2bit，合2228bit，未含未改生成加法叶子。此为静态逻辑寄存器口径，常量优化和实际物理映射未知；不代签LUT/FF/RAM/Fmax。

## 后继与未完成义务

下一阶段选择 [FFN0正常四行同runtime链](../mission/ffn_single_runtime_stage_20261014.md)，D-M004-FFN-SINGLE-RUNTIME-01。保留单套LN/Q/dualA/resident和原残差叶子/槽；给原只初始化一次的skip数组增加真实读口，把Down实际writer迁至STATE1+8MiB，并让残差从该刚写存储重读，结果写STATE1+0。`source_mem[0:16383]`为32bit word，共64KiB，非16384B。新scan明确655360B本地窗口，不宣称全BO。

[接点补证](../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_AT054_FFN_chain_connection_readonly_20261014.md)揭示另一限制：AT054本地src0为TMP/bank1/epoch2；原生产TMP只允许逻辑bank0，AT049实际Down目标为TMP/bank0/epoch1。历史AT054仍只签局部诊断，FFN0明确纠正受影响descriptor/拒绝测试，不能将物理STATE1误当逻辑bank1。新HIDDEN bank1/epoch2为本冷样本一次性预约，不代签全局owner高水位。

必须新增DUT侧有限退休互锁，在实际Down cfg/ledger claim接受边沿绑定完整canonical/NumericIdentity/Context/Refs/BO/window；真实末B、成功READY、零债和实际done消费全满足后才一次受理自己的op0x62残差任务。旧Wi完成、错键、发布前、失败或仅done有效不得产生残差AXI。不能只靠TB等待，也不把局部416bit回显当完整生产Task或416B模型包。普通双producer/hub lease仍未闭合。

一连接候选、full前最多两轮有因修正；新static/短回归/≤120s真实前缀和有据成本后至多一次冷full，full失败/停止即交付。新组合墙钟、周期、资源UNKNOWN，不能相加旧样本。复用guard须把SIM_START改为一次性并补重复start host反例；每次spawn前核ROM/fixture/参数实际部署。

普通Q/L恢复提问及真实单窗口/受控四窗口补证已核；[排程来源更正](../.research-agent/communications/measurement-first-FFR1-schedule-source-answer-20261014.json)确认工程引用的活动goal创建于2026-10-11，早于测量优先重排，未提供较新直接人类指令。因此不恢复M003生产控制：现有LN_ATTN rows16真实样本与HIDDEN/id1四窗口受控sideband不能合并成普通Q/L物理PASS，后继四窗口接口建议仅保存为依赖。该决定不否认普通Q/L最终义务；FFN0是当前唯一新执行线。补证通信身份见[单独核验](measurement_first_FFR1_review_20261014/connection_supplement_verification.json)。

旧AT053正常结果及错误/guard限制、AT047 FAIL、AT048 COST_STOP均保持；AT049至Down有限链PASS与AT050主机来源身份保留。真正同runtime末残差、双生产源query/lease、完整STATE0/1和13BO保护、普通多窗口/Attention/WO上游、全28+2层/122矩阵、请求恢复、联合资源/时序及M003/M004开放。原单重工具/所有帽、无新HLS/OOC/P&R/上板、整体executor/FullRuntime/冷INIT/CLOSE-rearm/cleanup停排、G仅OOC余额2338.224019s与5172s不重启保持。

证据：[工程报告](../project/E005_full_request_performance/experiment_results/runs/R001/reports/FFR1_status_measurement_result_20261014.md)、[AT054原收据](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/receipt.json)、[原full日志](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_full/driver.log)、[host反例](../project/E005_full_request_performance/experiment_results/runs/R001/attempts/AT054_FFR1_status_measurement_01/guard_host_test.json)。
