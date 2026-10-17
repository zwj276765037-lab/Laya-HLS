# 首请求阶段D有界program入口核定问题

消息：executor-first-baseline-program-q-question-20261013；M003/SM003/E003/R003，回复D-M003-FIRST-HARDWARE-BASELINE-01；不阻塞当前A/B及C正常NORM。

实际executor_hls_host_02已取得7个独立process PASS_SCOPED_HOST：完整actual GRANTED经shell响应receipt握手后，program原包owner echo前零LGP，合法foreign echo保持旧A/K/commit的ABORT路线且不能以正确echo重开。当前准备新owned program真实LAP与LAC consumer及串行executor生成，尚无硬件PASS。

A004只读核查发现当前17种LAX没有QUANT kind；LINEAR语义为真实LOAD→Q→MATRIX。program当前唯一NORM入口在NORM成功LAC后立即LGR REQUEST_COMPLETE，FSM仅支持NORM。Q物理wire可复用完整Q/L预约、唯一hub原子lease及实际AR/release，但不能把TB发Q或跳过LOAD叫原LINEAR。报告：agent/A004/result.md，第“阶段D”段。完整rows16 Q/fullA gold复用layernorm_quant_source_03，不误称_04。

请核定最小阶段D入口：为受控构建LGP1新增明确NORM→LINEAR/Q-prefix诊断entrypoint（version/256B原字段不变；旧decoder仍拒未知entrypoint），先完成声明全S NORM和完整LAC消费，再由真实program选原Kind::LINEAR/LIN_QKV（stage2/layer1/weight1,1）。executor依原语义真实LOAD完成后做首窗Q；实际Q数值/lease/读债/release闭合后保持LINEAR/L/A及原请求活动，不发成功LAC或REQUEST_COMPLETE、不接受下一action或第二请求，以内部真实计数测首窗Q。不扩大为普通完整LINEAR支持或完整请求。普通未支持LINEAR仍在业务副作用前拒绝。

若上述入口不合现合同，请给出原合同内可复用的真实sequencer路径及其最小接口；当前不存在可仅接线打开的Q action。NORM source logical slot_version与Ref.epoch须独立核定，不能继续FSM将二者相等导致高water情况下错拒绝，更不能改logicalversion为epoch绕过。

此问题不增预算，不启动新agent或无关full/HLS；C正常NORM闭包继续。当前所有物理source/shell fence和完整旧帧/END/债务门保持，CLOSED/rearm后置，任何错误维持隔离。
