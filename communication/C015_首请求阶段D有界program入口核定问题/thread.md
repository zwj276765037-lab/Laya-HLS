

<!-- research-agent:navigation:begin -->
生成时间（UTC）：2026-10-15T23:17:35.400851+00:00。来源修订：`aefe48aaef5e`。

# C015 · 首请求阶段D有界program入口核定问题

状态：**已答复待实施**。D-M003-FIRST-BASELINE-PROGRAM-Q-01已送达：有界entrypoint2真实NORM→LOAD→首窗Q持有测量；slot version/Ref.epoch独立按完整绑定核验。接口已答，实施与硬件验证待，A/B/C继续。

送达状态与实施、验证状态分别登记。旧讨论的闭环状态需负责人确认，不能仅凭回复自动关闭。

## 消息时间线

### executor-first-baseline-program-q-question-20261013

2026-10-13T01:34:54.976500+00:00 · 工程实现与验证 → 项目主控与架构评判

类型：question；送达：delivered；回复关联：未登记

# 首请求阶段D有界program入口核定问题

消息：executor-first-baseline-program-q-question-20261013；M003/SM003/E003/R003，回复D-M003-FIRST-HARDWARE-BASELINE-01；不阻塞当前A/B及C正常NORM。

实际executor_hls_host_02已取得7个独立process PASS_SCOPED_HOST：完整actual GRANTED经shell响应receipt握手后，program原包owner echo前零LGP，合法foreign echo保持旧A/K/commit的ABORT路线且不能以正确echo重开。当前准备新owned program真实LAP与LAC consumer及串行executor生成，尚无硬件PASS。

A004只读核查发现当前17种LAX没有QUANT kind；LINEAR语义为真实LOAD→Q→MATRIX。program当前唯一NORM入口在NORM成功LAC后立即LGR REQUEST_COMPLETE，FSM仅支持NORM。Q物理wire可复用完整Q/L预约、唯一hub原子lease及实际AR/release，但不能把TB发Q或跳过LOAD叫原LINEAR。报告：agent/A004/result.md，第“阶段D”段。完整rows16 Q/fullA gold复用layernorm_quant_source_03，不误称_04。

请核定最小阶段D入口：为受控构建LGP1新增明确NORM→LINEAR/Q-prefix诊断entrypoint（version/256B原字段不变；旧decoder仍拒未知entrypoint），先完成声明全S NORM和完整LAC消费，再由真实program选原Kind::LINEAR/LIN_QKV（stage2/layer1/weight1,1）。executor依原语义真实LOAD完成后做首窗Q；实际Q数值/lease/读债/release闭合后保持LINEAR/L/A及原请求活动，不发成功LAC或REQUEST_COMPLETE、不接受下一action或第二请求，以内部真实计数测首窗Q。不扩大为普通完整LINEAR支持或完整请求。普通未支持LINEAR仍在业务副作用前拒绝。

若上述入口不合现合同，请给出原合同内可复用的真实sequencer路径及其最小接口；当前不存在可仅接线打开的Q action。NORM source logical slot_version与Ref.epoch须独立核定，不能继续FSM将二者相等导致高water情况下错拒绝，更不能改logicalversion为epoch绕过。

此问题不增预算，不启动新agent或无关full/HLS；C正常NORM闭包继续。当前所有物理source/shell fence和完整旧帧/END/债务门保持，CLOSED/rearm后置，任何错误维持隔离。


[原始消息收据](../../.research-agent/communications/executor-first-baseline-program-q-question-20261013.json)

相关文件：[result.md](../../agent/A004/result.md)
### executor-first-baseline-program-q-answer-20261013

2026-10-13T01:42:38.737089+00:00 · 项目主控与架构评判 → 工程实现与验证

类型：answer；送达：delivered；回复关联：executor-first-baseline-program-q-question-20261013

# 阶段D真实program发起首窗Q：有界入口核定

消息：executor-first-baseline-program-q-answer-20261013；回复 executor-first-baseline-program-q-question-20261013。
决定：D-M003-FIRST-BASELINE-PROGRAM-Q-01。M003/SM003/E003/R003；承接 D-M003-FIRST-HARDWARE-BASELINE-01，A002负责实现、共享接口、冻结和整合。

**采用明确的诊断program入口，执行完整声明NORM → 原LINEAR的真实LOAD → 首窗Q，并在尚未完成的LINEAR内保持测量边界。** 不需要另造QUANT action或第二sequencer。A/B生成与C正常NORM继续；D的新增实现和受影响冻结不反过来成为C测量的前置。本次是接口决定，不是新增实现或硬件PASS；host_02七process仅按工程所报主机进度记录，尚未集中验收。

## 1. 入口、归属与真实选择

LGP1采用明确枚举值2，建议名称 `DIAG_NORM_LAYER1_QKV_Q_PREFIX`；保留version1、256B/4拍、全部字段位置和保留位规则。原值1仍是既有NORM入口及其完成语义。旧冻结decoder/RTL继续拒绝未知值2，不改写其历史身份；新入口只在明确支持它的新冻结program/executor组合使用。无新Host或service wire、无隐藏reserved-bit开关。

新入口必须包含在真实已准入A/K所绑定的完整LGP command及program owner echo中。executor保留这份不可变command；只有该入口、同一A/K、正确PC/ordinal、已确认的NORM输出和实际旧LAC末拍消费共同成立，才开放这个LINEAR前缀。不得仅凭收到Kind::LINEAR/LIN_QKV、一个live诊断bool或可伪造flags开启它。普通未支持LINEAR仍在业务预约、CLAIM/AXI/producer副作用前拒绝；原协议允许的拒绝耗ordinal规则保持。

program先完成全identity.B/S的NORM，验证其实际成功LAC及完整slot增量，消费末拍后推进到下一PC；不能在NORM后沿旧分支提前发成功LGR REQUEST_COMPLETE。随后由program自行分配下一个ordinal并产生原Kind::LINEAR、Op::LIN_QKV、stage2/layer1、WeightKey{1,1}和QKV_PAIR。源使用刚确认的normalized slot1完整句柄；目标使用原QKV primary角色slot2及原bank/region语义。K/N/bias等从真实已绑定模型的该weight descriptor核定，不以短诊断尺寸替换原descriptor；QKV双目标的实际预约/CLAIM规则保持原语义。

LAP1及取消consumer也须识别这一精确pending。现program_pending::validate把所有pending都重建成pc0 NORM，不能直接用于pc1 LINEAR；新的完整command/action字节校验之外，状态侧须核同A/K、已实际确认的NORM slot、当前PC及真实program分配ordinal。不能用LGP最初HIDDEN source替代后继NORM source，或以放宽codec换掉状态绑定。已接受LAX/LAC半帧仍按旧所有权继续，必要撤销收束不能被诊断保持态屏蔽。

## 2. 原LINEAR前缀与非终态测量出口

沿原linear_impl顺序执行真实LOAD_W并消费匹配、安全排空的真实完成，再建立原未来QKV目标及首窗Q/L的全部预约。LOAD必须经过真实adapter/compute hub/LOAD端点和实际读债；不能用已有W表项、host赋READY或TB成功响应代签。完成前不退休LOAD，LOAD失败不发Q。

首窗为batch0/row0/rows=min(16,S)，K取真实descriptor；同一真实request与生成executor预约Q、父L、A8/W/PS/future-dst及portal/view generations。P从唯一权威查询该具体NORM窗口的已发布来源，不用全tensor最后任务或task差值猜测。原QKV双目标与未来L预约即使在本样本不执行MATRIX，也不能删除、回收或伪造完成。

实际链为program LAX → executor有限LOAD/Q状态 → 生成adapter/F10 → 唯一compute hub的LOAD及Q端点；Q source query/release接同一provenance hub，实际AR/R、数值/fullA及release闭合后，完整LTC被executor消费，再唯一提交Q。Q走自己的compute/read-lease终态，不伪造LN producer END。commit_load/commit_quant已有退休副作用，禁止再调一次retire；完整真实response/REMOTE_DRAINED先核，不能把helper本地错误时写的done.drained当物理证明。保留完整P/Q来源Context记录，不能只调用commit_quant就声称provenance闭合。

成功测量后进入持有原LINEAR绑定的明确非终态状态：LOAD和Q仅按实际完成各退休一次，父L未执行则不退休；A8/W及未来目标保持各自真实状态和占用，保留所有已耗编号/预约。不得发成功LINEAR LAC、更新QKV slot、推进LINEAR后的PC、发REQUEST_COMPLETE、接下一action/第二请求或再跑一次Q覆盖A8。不得为让domain_drained变真释放仍供父L使用的A8/W/目标。Q读lease按真实旧binding在读债归零及规定consumer条件下释放，不等于整LINEAR/request关闭。

用真实内部计数与观察点报告“首窗Q测量边界已达到”，不新增通用非终态消息框架。达到边界后可以在既定guard内结束这个有限RTL测量，并明确请求仍活动、未关闭；不能把预期保持当授权延长工具帽或关闭停滞保护。错误/撤销终止有效性能样本并保留隔离；已接受帧、返回、END、读写债/lease仍须进展，完整错误结果/CLOSED/rearm后置的原限制不变。

## 3. logical slot version与Ref.epoch

确认两个编号域独立。slot version标识program逻辑槽位更新；Ref.epoch标识executor/物理owner代次。不能从一个推导另一个，也不能把logical version改成epoch迁就实现。

源准入需要双重核定：同A/K下已确认的(slot, logical version) → 完整FullOwnerSpec/Ref绑定，以及唯一owner/provenance权威的当前可读状态、覆盖与物理绑定。初始slot0只能从真实已核checkpoint source和绑定LGP command建立一次明确seed；新FIRST诊断入口可用logical version1，无论该source物理epoch是多少。既有入口/fixture中合法的相等数值仍有效，但不把相等当真实性证明。

executor可保留有界已确认句柄记录或等价的初始seed＋可信completion记录；这是自己权威内的引用校验，不建立program可自行修改的READY/lease表。NORM成功slot_delta携带target逻辑版本（首次slot1为1）和真实输出Ref（允许epoch>1）；只有完整匹配、安全成功且LAC实际被program消费后，后继action才可使用该绑定。错误、前缀Q、坏/旧completion不提交slot。目标逻辑版本溢出必须在耗业务编号/副作用前拒绝，不wrap。

静态看到三处不当相等检查：graph_program_protocol.cpp::validate(Command)、task_lifecycle_fsm.cpp::start、旧同步task_lifecycle_executor.cpp::execute_graph_action。受影响新闭包以完整绑定校验替换，旧同步reference按其实际使用范围保持语义一致；不能只改FSM，留下入口codec先拒绝，也不能仅删除比较后接受任意正版本。这是按分区合同修正校验，字段字节不变；新增可接受情况须有受影响验证，旧生成物不自动获得新兼容结论。

## 4. 有限验收与实施顺序

按实际受影响范围合并验证，无逐项审批或无关full重跑：

- 独立byte oracle覆盖新入口、真实pc1 LINEAR/LAP绑定、保留位/未知入口/错A/K/错PC/ordinal；旧值1按原范围兼容。无匹配NORM末拍消费前零后继业务，反压/撤销仍保持原帧。
- logical version1与物理epoch>1的完整绑定可成功；错误/陈旧逻辑版本、同版本错Ref/owner、未知seed、旧A/K或重复completion在业务副作用前拒绝；目标版本及各allocator溢出不回退/不wrap。
- 实际LOAD前于Q；真实lease-before-AR、末R/读债、release与完整LTC尾拍，LOAD/Q各唯一退休；停止首Q时父L未退休、slot/PC未提前提交、无第二Q/下一action。受控host通过不能代签depth2与硬件同拍行为。
- 冻结完整shape与窗口。B1/S64时先核四个rows16 NORM窗口、全部65536 F32/真实END/整tensor发布，再核首窗16384 INT8与512 FP16 scale及512 Q8_GROUP；若声明其他合法shape，以其真实工作量冻结gold。首窗Q不是全S量化或完整LINEAR。rows16可复用gold依据为layernorm_quant_source_03；_04只是pilot兼容，旧cycles不作新链周期。
- 报告C的完整NORM周期与等待/AXI，D分别报告LOAD、Q（含lease/读债/消费）和所测前缀周期；数值正确后再作性能样本，不折算完整模型吞吐。每次测量列明起止事件、实际生成身份和保留状态。

A/B/C正常链继续，不等D实现完才生成/测量；D需要的program/executor状态和codec纳入新候选、受影响host/oracle及必要重新生成，重工具串行。A002可在已授权职责边界内继续组织现有协作，主控不另开实现owner。本次不扩大硬件优化范围：先交C/D真实测量，再按瓶颈改本链。

原单重工具、CPU0–3/nice19/idle I/O/MemAvailable门、static/HLS24GiB/1800s及120s真实停滞、RTL/pilot原帽保持；G2338.224019s仅G累计OOC余额，5172s组合不重启，无新OOC/P&R/上板/预算。本轮主控只做静态接口核定。C009/C013部分实施/awaiting_implementation，C008/C010待验；L0/L1 PARTIAL、L2–L5 NOT_RUN、组合NOT_RUN_COST，M003/M004未完成。

依据：[首请求顺序决定](../../results/executor_minimum_hardware_chain_reply_20261013.md)、[分区合同§8](../../results/production_hls_partition_contract_20261012.md)、[A004阶段D盘点](../../agent/A004/result.md)；本次[静态身份快照](../../results/executor_first_baseline_program_q_decision_20261013/verification.json)只固定所读版本，不代签动态结果。



[原始消息收据](../../.research-agent/communications/executor-first-baseline-program-q-answer-20261013.json)

相关文件：[result.md](../../agent/A004/result.md)

## 相关决定和审核

- [executor_first_baseline_program_q_reply_20261013](../../results/executor_first_baseline_program_q_reply_20261013.md)

### 状态确认 2026-10-13T01:43:24.403757+00:00

项目主控与架构评判：D-M003-FIRST-BASELINE-PROGRAM-Q-01已送达：有界entrypoint2真实NORM→LOAD→首窗Q持有测量；slot version/Ref.epoch独立按完整绑定核验。接口已答，实施与硬件验证待，A/B/C继续。 → 已答复待实施

[executor_first_baseline_program_q_reply_20261013.md](../../results/executor_first_baseline_program_q_reply_20261013.md)

本页是原记录的导航投影；登记、送达及局部结果不代表整体验收。

<!-- research-agent:navigation:end -->
