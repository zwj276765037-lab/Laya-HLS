# A004 executor 入口源码核查

2026-10-13；父 owner A002；M003/SM003/E003/R003。只读核查，未编译、HLS、RTL或OOC。唯一写入本文件；不修改合同或三摘要。适用决定 D-M003-FIRST-HARDWARE-BASELINE-01：首请求入口→生成→同 runtime LN→真实 Q；完整 rearm 后补但不能假退休、清流或开启第二请求。

路径以下均相对唯一实现根 `/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment`。核查 `config/executor_actor_sources.cmake:1–25` 全部23源及 actor/bootstrap/runtime 的可达调用；未发现当前可达路径必须调用本地算术 leaf 的事实。未做工具可综合性验证。

## 1. extern C 有界 top 包装的优先风险

1. **事实：23源清单本身不是完整 top 构建合同。** `executor_actor.cpp:3` 和 lifecycle port/FSM 由 `LAYA_CONTROLLER_TRANSACTION_HAS_HLS_STREAM` 保护；此宏由 `include/laya_controller_transaction_hls.h:5–8` 的 HLS 头存在检查产生。HLS包含路径必须真实满足，不能把预处理后的空 actor 当生成成功。`controller_transaction_codec.cpp:838–859` 在无 `LAYA_TRANSACTION_SEQUENCER_CODEC` 时调用三个外部 codec；这三源不在23源内。`compute_portal_client.cpp:117–124`、`generated_provenance_events.cpp:140–147` 也有同类分支。现有 actor host runner `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_actor_host.py:39–48` 额外加入6源，不能证明23源单独 closure 成功。已有 graph HLS runner `run_graph_program_hls.py:24–28` 使用三个宏（PARTITIONED_PRODUCTION_CALLER、CONTROLLER_TRANSACTION_SEQUENCER、TRANSACTION_SEQUENCER_CODEC）；executor HLS包装宜复用对应语义隔离并继续保留完整绑定校验，真实 adapter仍承担外部帧校验。
2. **事实：最大的算术缓存和函数指针已经排除 synthesis。** `include/laya_full_runtime.h:129–144` 的5373952字节Q8、167936 scale及各LN/Attention/ACT缓存均在 `#ifndef __SYNTHESIS__` 下；同文件150–154的外部指针持久副本、269–274回调、416–463 host适配也同样排除。不能按host sizeof推断硬件存储。若 top运行只做step，不能误用host无显式memory的适配入口。
3. **估计：最显著的静态展开/存储风险是仍可达的 owner/provenance批量清理。** `FullOwners`（runtime.h:91–125）包含34×128 `SourceWindowProvenance`、32条owner（每条2×64个覆盖word）、QKV/rope/head位图；`full_admit_request`（`laya_full_io.cpp:223–231`）可达 `full_recycle_request/full_soft_reset`，后者在 `laya_full_owner.cpp:1232–1260` 逐项清覆盖位图、QKV/rope/head数组并整条赋零source；`full_claim_owner:370–379`→`source_claim:170–174` 也整条清128-window记录。即使top禁止第二请求，当前runtime分支仍然属于静态可达代码；不能预设综合自动证明不可达。优先检查报告中的数组映射、reset/赋零展开及循环调度，必要时只做保持合同的串行初始化/局部拆分，不能删除持续下界或owner权威。
4. **估计：请求解析、规范包重编与比较是次优先风险。** `laya_full_io.cpp:111` 的 `FullInputs{}` 初始化、175–210的B/S动态循环，`executor_actor.cpp:64,76,97,104,143` 的整包encode/相等比较，`executor_handoff_protocol.cpp:62–82` 的664字节前缀拷贝+完整1024字节canonical比较，checkpoint/protocol的同类零化/复制，都可能产生大复用器或较长生成/调度时间；现有代码只在actor/port的64字节word/store中明确 `inline off`/`unroll off`（actor:7–23、port:6–24）。这些是风险估计，**没有证据把 std::array 或上述循环直接判为HLS不支持**。
5. **事实：一个C++ step调用不等于一个硬件时钟。** actor `step:191`、port `port_step:34`、FSM `step:225` 均 `pipeline off`，而word/store的64次循环显式不展开。top可有界运行若干step，但“16拍帧”表示16个真实512-bit握手，不代表16个clock；周期必须由实际生成/RTL测量确定。

## 2. 只有 IO/AUX AXI读取与完整13BO物理记录

- **可判事实：准入只解引用 IO/AUX。** `bootstrap::admit_new`（executor_bootstrap.cpp:67–80）调用begin→decode→admit；`full_decode_validate_request`（laya_full_io.cpp:97–220）直接读 `m.io`，212调用 `full_check_model_header`；该函数（laya_full_memory.cpp:219–239）只解引用 `m.aux[0..127]`。recycle/soft_reset处理本地元数据。
- **可判事实：当前actor的LN路径发送真实事务而不调用本地LN算术。** lifecycle FSM `PREPARE_WINDOW:263–300` 调用producer prepare/build，producer client `prepare_layernorm:66–89` 只校验/取source lease，`build_layernorm_request:92–157` 仅地址/容量/完整描述检查；FSM随后发送BEGIN→producer→END事务（303–378），END真实terminal后才退休。源/目标STATE0、gamma等真实读写由外部producer拥有。
- **可判事实：完整物理A与executor AXI端口数可以分开。** `admission_owner::PhysicalMap`（include/laya_admission_owner.h:11–25）有13个epoch/address/capacity；`capture`（admission_owner_protocol.cpp:61–74）捕获真实准入identity/model/map，并只比较每个已知role容量。`validate:20–25`要求已知role的地址非零、64字节对齐、epoch/容量有效，未知role必须全零；不能用STATE0默认回退（actor:230–235）宣称完整13BO已捕获。完整map应由真实锁定物理配置传入，known_roles应反映实际知悉范围。
- **工程可行性判断：** 内部executor的top仅配置IO/AUX实际AXI访问，其余11BO由真实物理配置提供容量和A记录，当前调用图支持这一分工。`full_bo_capacity`（laya_full_memory.cpp:70–98）只读容量；`full_span/present`（18–27、118–124）在synthesis按合法role+容量检查，不解引用其他BO。**限制：** host `present` 分支（29–42）仍检查指针非空，host验证应继续传有效FullMemory，不能借synthesis分支改变host标准；也不能把地址字段当dereference伪指针。当前top尚不存在，能否消除其他AXI接口、IO写通道及unused-array资源仍须生成报告验证。此结论仅覆盖现有LN actor，不代签以后Q接入的新调用闭包。

## 3. 真正16拍control consumer桥的相邻时序

- **完整消费后才ack：** LHC1固定1024字节/16beat（include/laya_executor_handoff_protocol.h:7）。actor `control:37–42`保存完整不可变request并置pending；WAIT_HELD（258–281）、WAIT_IMPORT_CONFIRMATION（315–328）、WAIT_ABORT（422–435）、WAIT_CLOSE（439–453）只在 `control_request_consumed` 后置sent，响应需sent和完整key。桥须保存一条完整旧request与发送ordinal，16个beat逐次真实握手，首拍/仅本地FIFO写完不能伪装对端完整消费；反压不能换包，pending重复观察不能重复送帧。完整返回校验后才给 `control_response_valid`+完整Message。源码允许完整消费ack与完整返回在同次step共存（先置sent再校验），并不允许提前ack。
- **HOLD→HELD→checkpoint：** WAIT_CHECKPOINT（248–256）先reserve sequence/HOLD；有效HELD分配H后，`prepare_held`（executor_checkpoint.cpp:143–151）先持久提升handoff高水位，再校验当前fence；已观察H即使后续撤销也不能再用。只能匹配HELD并通过真实held/quiescence/base检查后写checkpoint；checkpoint请求/响应均完整16beat后独立VALIDATE/IMPORT（actor:283–313）。
- **IMPORT_OK→GRANTED→command：** checkpoint本地commit只产生IMPORT_OK及WAIT_IMPORT_CONFIRMATION（305–313），无GRANTED时零command/action派发；完整匹配GRANTED与live fence后才WRITE_COMMAND（315–328）。持续撤销（197–202）跨整个请求锁存；IMPORT确认阶段撤销+已送控制先ABORT，不能让同拍GRANTED启动（319）。command首拍前撤销禁止开始，已起部分帧在旧key下发完（329–337）。
- **consumer末拍必须保留：** lifecycle completion writer在末拍当次锁存consumed并于WAIT处理（task_lifecycle_port.cpp:74–88）；request result同理（actor:386–405），managed模式必须由完整且匹配 `host_result`建立消费事实（100–105），无键bool不能替代。桥输出消费脉冲应与真正consumer末拍绑定，并处理末拍与phase转移同拍，不可清丢。当前host边界测试明确只测抽象接口，未测RTL FIFO时序（tests/executor_actor_test.cpp:690–693）。
- **物理债务与rearm：** action末拍消费只能在真实safe/drained且本地lease解除后释放machine（FSM:454–460）；producer response不能代替END真实terminal，退休在END_RESULT:349–378。actor managed CLOSE要求旧本地work及队列排空（395–408），注释明确shell还须独立保持物理owner；匹配CLOSED后只进WAIT_NEW_ADMISSION（439–458），现代码不会自动重开。首请求top必须保留这些旧状态/流，不得reset runtime、清FIFO或以budget到期生成safe完成。

## 核查身份与边界

主文件SHA256：source list `ebdfe6458a2ebcadd58931ea5f02e7d3cdde91e3e0ed0e53e30fbbf3a8e7e442`；actor `de53ee6b656920b4aaf420abdcffd603d8b65b2b2e4865c95064d5a68018d116`；bootstrap `021ec986a6912e9fa768f9472ce2273c20a5ee0f86cd38412fd4bffa2efa2087`；runtime header `3f2a61f41d1839a7d3b4b95518fa2f88d85a19877f509a27b4c28f931c19e0b0`。可判事实仅为上述源码身份的静态调用/协议行为；所有HLS展开、资源和实际周期是待生成验证的判断。本结果不关闭M003/M004或C009/C013。

## A004续查：FIRST HLS top（2026-10-13，源码正在由父owner迭代）

只读检查新 `include/laya_executor_hls.h`、`hls/control/executor_hls.cpp`、`config/executor_hls_sources.cmake`、stream桥及FIRST-only准入。未运行编译/重工具。以下区分已见修正和剩余必要项，不将旧文件SHA当本次身份。

### 首次正常生成的必须项

- **接口静态核对：** 当前header/top的extern C参数一致（新增末参数 `action_completion_receipt` 已同步）；actor source list已加入 `executor_stream.cpp`，HLS list再加 `executor_hls.cpp`，为25源。旧 `task_lifecycle_executor.cpp` 只定义namespace execute，当前源列表也未加入它，未见重复extern C定义。应固定 `LAYA_EXECUTOR_FIRST_REQUEST`、`LAYA_TRANSACTION_SEQUENCER_CODEC` 及既有PARTITIONED/SEQUENCER宏和生成model头包含路径；source list本身未保存这些宏，runner必须真实带入。
- **超宽类型已见修正：** `laya_executor_hls.h:2–4`现在在include前定义 `AP_INT_MAX_W=8192`，当前top TU的2496/8192位类型有前置配置。实际Vitis2025.2 `include/etc/ap_common.h:142–148,253–269`默认1024并按宏生成类型，`etc/ap_private.h:3276–3281`有超宽检查。建议runner统一 `-DAP_INT_MAX_W=8192`，避免测试或别的入口先include ap_int后再include本header使宏已固定为1024。无编译证据，不签工具支持。
- **FIRST调用闭包已收窄：** `executor_bootstrap.cpp:79–83`由FIRST宏选择 `full_admit_first_request`；`laya_full_io.cpp:223–232`检查无旧session/request，再仅保存已由真实decode校验的inputs。该分支不调用recycle/soft_reset，前次报告的大批recycle清理风险在这一分支已去除；仍需保证first有效不能由Host proof或错误后重置Entry再触发。top `EntryPhase`无回FIRST分支，stream `first_admitted`还二次禁准入，符合单请求边界。
- **IO/AUX地址已见修正：** configure（executor_hls.cpp:28–51）按Bo enum顺序解完整13×192bit配置、所有role容量存FullMemory；top新增162–164把实际io/aux指针地址与role1/5地址比较并锁存revoked，弥补最初只比较physical_config而可独立改AXI基址的缺口。**待生成检查：** `reinterpret_cast<uintptr_t>(m_axi指针)` 是否被HLS接受并确实表示offset=direct输入基址；如果工具拒绝，用真实wrapper锁定的64bit基址作为内部标量比较，并由同一寄存器同时驱动实际IO/AUX offset与physical_config，不能只比较两个可独立伪造的metadata标量。synthesis中其余11指针为空而仅容量/映射可达，仍支持两AXI master方案。

### 首次安全动态链的必须项（不要求完整rearm框架）

1. **完整A消费门当前具备必要源码边界，但必须接真实consumer。** top WRITE_OWNER→READ_OWNER_RECEIPT（196–218）发送并读回完整16beat；回执必须decode、与原LAD1逐字节相同、发送队列空才进RUN。当前 `admission_valid` 已改为RUN且admitted_owner_valid（138–140），`checkpoint_valid`同样只在RUN（178），部分A不能触发HOLD。动态装配要由唯一实际A consumer在校验并安装A后echo，若hub与LPV都需安装则协调两者实际接受；不能用producer自己echo或FIFO-empty制造receipt。cancel/config变化期间仍完成旧A发送和返回，不清流；被撤销的A即使回执正确也只能保持旧归属并关闭新启动。
2. **program K/LAP1仍是安全取消的必接项。** 本top/stream没有实际LAP1输入；`executor_actor.cpp:363–365`的专用cancel consumer只能由完整 `cancel_drain_record`打开，否则撤销发生在LAX首拍前，普通port的cancel+beat0会停止读取旧action，不能形成错误LAC/result。现有 `graph_program_hls.cpp:209–225` top给step传nullptr，`program_pending_snapshot:198–205`要求bound_command才发布LAP1，因此仅连接旧program top不足。具体接法：在真实command首拍前向唯一program提供锁存K=`{session,accepted_request,sequence,handoff}`；program在完整旧command及唯一allocated pending action下输出实际LAP1（已有snapshot helper）；executor桥逐16beat读/validate，并以旧K+完整command/ordinal核定后给actor cancel_drain_valid/record。先确定普通consumer还是cancel consumer，再读首拍；部分action沿原消费者完成。无LAP1时不临时用bool允许首拍，也不伪造已分配action。
3. **action完成消费已见完整回执修正，但下游必须真实提供。** stream `118–134`只接受完整codec、对应当前普通或取消WAIT_COMPLETION_CONSUMED、队列空且与原completion_packet完全一致的4beat receipt；它覆盖live bool并独占给actor发消费事实。接口移除旧bool，避免无键推进。实际program必须在完整LAC decode/接纳后echo原frame；最后一拍+WAIT转换相邻时序要用生成RTL确认，不能用actor写侧信号。完整program command K和程序结果消费绑定同属首次正常动态路径接线。
4. **已有正常旧control drain行为：** stream receipt/response是独立完整Frame，响应早于request receipt时保留到control_sent；有效HELD/GRANTED等经actor `control_responses_consumed`增量才产生accepted receipt。persistent cancel不会改送出的旧control_packet，actor保持部分checkpoint/command流及活动END/lease cleanup；这些边界静态成立，不能以取消停掉全部step。
5. **剩余局部缺口：malformed控制返回没有消费通知。** `executor_stream.cpp:96–99`目前仅设transport_error/cancel并release完整坏帧，未置 `response_receipt_valid`。若shell在保持response直到实际consumer receipt，这会留下未确认旧返回、使其control_ready持续关闭，后继ABORT无进展。建议同有效但拒绝的frame一样保存完整原packet并发布 `response_receipt_accepted=false, valid=true`；该通知只说明完整transport消费，shell仍保留旧锁/owner和错误路由，绝不能将它解释为GRANTED/CLOSED或物理排空。此修改只补旧返回路由，不引入rearm。
6. **待RTL证实的实际握手风险：** top `ap_none response_receipt_valid/accepted` 在1024-byte输出拷贝之前赋值（142–147），top和stream均pipeline off，循环也unroll off。一整个C++调用不是原子硬件拍；不能凭host调用模型证明8192bit输出在valid时已完整稳定，也不能假定一个单周期 `response_receipt_ready/cancel/first_valid`脉冲一定被采样。建议装配将ready及撤销事实保持至真实ack；更直接的代码方案是用完整16beat输出receipt流和完整consumer echo（含accepted语义）或输出持久封存的完整wide寄存器后再置valid。首次生成可先看调度/端口，首次动态链必须验证valid期间全包稳定、反压不重复确认及末拍同拍行为。

本次读到的过渡身份：header `7a14e6d81e51a462f2b33aea1cd6276f03e5a96832bacc4a823c312bdfe2c00f`，top `c59c96512e0846f42b44652af27036c0cc9f69bb20a3f59e431b5e1de02ca3f8`，HLS list `bedfa4130ebba7c25de008458ce2a2051c2a23efd13b21c05446ac133536eba0`。父owner仍修改源码，最终冻结须重新取身份；以上是静态审核与具体建议，首次生成与动态链均NOT_RUN。

## A004续查：阶段D真实Q发起的最小接法（2026-10-13）

依据 `results/executor_minimum_hardware_chain_reply_20261013.md` 的 D-M003-FIRST-HARDWARE-BASELINE-01 和 `results/production_hls_partition_contract_20261012.md` §8.2–8.5。本次只读盘点，未编译、HLS、RTL或OOC；仅追加本文件。下列E内路径沿用前文唯一实现根；M=`vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512`，Q=`vivado/module_design/activation_quantizer/rtl`。父owner A002继续拥有实现、共享schema、冻结与全部重工具，A005的控制transport准备不在本次编辑范围。

### 1. 当前真实控制出口仍只有NORM

- `include/laya_graph_action_protocol.h:20–38` 已冻结17种action，`LINEAR=4`，没有独立QUANT kind；请求已有weight/K/N/QKV字段。`graph_action_protocol.cpp:103–124` 只有NORM专门校验，其他kind目前仅通过通用语法检查，不能把它当LINEAR已支持。
- `include/laya_graph_program_protocol.h:20–22` 和 `graph_program_protocol.cpp:51–53` 只允许 `NORM_LAYER1_ATTN`；`graph_program_sequencer.cpp:35–68` 只有 `prepare_norm`，`accept_completion:84–109` 成功条件固定为全S、width1024/F32、B×ceil(S/16)条退休。`graph_program_hls.cpp:105–126,154–179` 发出一次NORM后直接产生REQUEST_COMPLETE。不存在可直接开启的Q程序分支。
- `task_lifecycle_fsm.cpp:164–176` 在业务副作用前拒绝所有非NORM；`include/laya_task_lifecycle_fsm.h:14–40` 只保存LayerNormTask。需要有界增加LOAD/Q步骤和完整P/Q/L快照；不能把旧 `execute_graph_action/linear_impl` 同步树重新纳入生成闭包。
- **后继action的具体句柄缺口：** `prepare_norm:57–58` 的新逻辑slot version为1，而 `task_lifecycle_fsm.cpp:156` 强制source.version==Ref.epoch。checkpoint导入的Ref下界可以使真实NORM输出epoch不等于1，故后继真实LINEAR会被错拒绝。应分别核已确认slot/version及完整owner Ref；不能把逻辑version改成epoch来绕过，也不能在program新建READY权威。

### 2. 最短可实现候选及不能删掉的前序

工程候选是新增一个明确冻结范围的有界诊断program入口：完整NORM完成及其LAC实际末拍消费后，由program选择原下一步 `LINEAR/LIN_QKV,stage2,layer1,weight={1,1}`，executor执行原LINEAR截至首窗Q的部分。原图映射见 `full_forward_controller.cpp:1979–1990`；不是TB构包或外部直接驱动service command。当前没有此入口/schema或Q FSM，本盘点不把候选写成已接通。

**若沿用原LINEAR语义，真实LOAD是前序。** `full_forward_controller.cpp:1203–1280` 的原顺序是 `load_weight`→claim未来dst→逐窗完整构造Q/L→查询真实P→Q→MATRIX。`load_weight:1073–1094` 用真实descriptor构造LOAD_W及W Ref。不能为缩短Q样本静默跳过LOAD、把W预约写成READY、虚构已退休LOAD/L，或改任务顺序。物理Q端点只验证自己的ordinary source与A；其包内W/PS/future-dst为关联预约，不等于Q硬件依赖W READY。这个物理事实不足以把无LOAD的Q改名为原LINEAR路径。

首窗Q数值、物理读债和source release真实闭合后可以停在**仍活动的LINEAR**，保留已退休Q、尚未退休L、真实A READY和全部预约/高水位，不接受下一action或第二请求。诊断支持范围必须显式声明；普通完整LINEAR的未实现分支仍须在业务预约/AXI/owner副作用前拒绝。没有MATRIX消费及父任务收束，不能返回成功LINEAR LAC、提交目标slot或产生LGR REQUEST_COMPLETE。现 `action::validate(Completion):144–149` 对成功强制SAFE_TERMINAL/REMOTE_DRAINED；最小Q测量出口宜使用真实内部计数/观察点并保持action，不借用成功LAC。若以后增加非终态状态帧，其实际消费也不得释放活动action或重派整段前缀。

当前NORM action覆盖全 `identity.S`，`full_source_query` 又要求整tensor所有窗口closed并published。因此B1/S64示例必须先完成4个真实LN rows16窗口及完整发布，再量化声明的batch0/row0/rows16；不能只复用旧rows16 diagnostic owner就称当前全S64 NORM完成。停止第一Q只证明这一窗fullA，不证明全S Q或完整请求。成功测量后保留旧request/锁符合D决定；取消或错误仍须继续已接受半帧、真实读写债和lease收束。

### 3. 可直接复用的C++语义助手

| 部分 | 已有实现与接入要点 |
| --- | --- |
| typed/Ref及portal预约 | `include/laya_task_reservation.h:43–78` 的can/context/ref，`:88–108` 的PortalReservation/reserve_views；沿现FSM使用rt内唯一allocator。Q/L在Q发出前完整构造，P不能由task_id差值推算；view generation也提前预约但不claim、不READY、不退休。 |
| LOAD前序 | `hls/common/laya_full_memory.cpp:243–252` 的full_lookup_weight；`compute_portal_client.cpp:284–336` 的build_load_command；`compute_portal_commit.cpp:84–112` 的commit_load。真实已绑定且排空response后才提交W和退休LOAD。 |
| 真实P及源绑定 | `hls/common/laya_full_owner.cpp:1101–1136` 的full_source_query查整tensor发布、准确窗口close Context和owner coverage；`:1187–1194` 的full_bind_quant_source只保存预期源。P取这条窗口凭据，不能取全tensor最后LN任务。 |
| 完整Q包 | `compute_portal_client.cpp:68–114,338–362` 的binding_ok/fill_binding/build_quant_command，携带真实P/Q/L、source/A/W/PS/future-dst、model和generation；source stride=K×4，TOKEN batch stride=1024×K×4，不能用运行时S缩小。 |
| 有界事务发送/接收 | 复用现FSM的send与TX_WRITE/TX_READ/TX_VALIDATE（`:415–450`），以 `transaction::make_request(compute_command)` 走唯一LTX1/LTC1。`controller_transaction_dispatch.cpp:28–49,130–144` 提供TaskDone映射参考，但同步exchange/dispatch_quant不宜直接拉入有限step FSM。 |
| Q提交及唯一退休 | `compute_portal_commit.cpp:114–157` 的commit_quant只改shadow owner/coverage/A8 metadata，不访问算术payload；内部finish（`:10–32`）已增加last_task/tasks_retired/op_calls，不能再调用full_retire_prepared_task。必须先核完整FRAME_COMPLETE/BINDING、真实REMOTE_DRAINED及匹配响应；helper在本地错误时可把done.drained改true，不能用它来证明未知物理终态。 |
| A8的P/Q凭据 | `full_forward_controller.cpp:95–106` 的record_source_completion(QuantTask)在核完整dispatch binding后保存 `activation_meta.source_context/quant_context`；commit_quant本身不保存这两Context。有限FSM必须保留同等检查和记录，不能把只调用commit_quant当完整provenance接入。 |

Q走原compute portal自己的read lease/fullA终态，不能套用LN的PRODUCER store END伪造一次Q END。LN源仍必须先由真实END与整tensor发布闭合。复用commit源时将 `hls/platform/compute_portal_commit.cpp` 加入有限executor清单；现 `config/executor_actor_sources.cmake` 已含compute_portal_client、owner、descriptor原语，尚无commit源。

### 4. 可复用RTL与唯一hub接线

实际链应为：program的LAX→executor完整预约/构包→LTX→生成adapter/F10→真实compute FIFO→compute hub service2/index1→quant binding→**同一**provenance hub原子source lease→真实AR/R→量化/fullA→真实release→compute response→LTC实际executor消费→Q唯一提交。LOAD前序走相同compute hub的service1/index0。

| RTL部分 | 已有模块与必须保留的接口 |
| --- | --- |
| adapter计算FIFO | `hls/platform/controller_transaction_adapter.cpp:455–459,476–490` 已把COMPUTE_TRANSACTION发到16×512bit外帧并完整收8beat response。F10必须接真实executor LTC末拍consumer；FIFO空或adapter写完不能代签消费。 |
| 唯一compute传输 | `M/rtl/laya_compute_portal_hub_v1.sv:6–32,45–55` 的compute_cmd/rsp FIFO接生成adapter；service2选index1。service_physical_debt_zero/persistent_active接端点真实状态；`:91–93` 的domain_drained包括A pin，Q response不等于全domain排空。 |
| 真实LOAD | `M/rtl/laya_load_portal_binding_v1.sv:5–88,129–162,204` 包含latched13BO、W_Q0/W_Q1/W_SCALE三路512bit AXI及AUX128bit读，实例 `vivado/module_design/hbm_loader_and_cache/rtl/t4_dual_w_cache_v1.sv`。必须接真实accepted AR/R debt，不能用常量physical_debt_zero。Q-only边界可保留真实W READY，不报告MATRIX已消费。 |
| Q完整命令/lease | `M/rtl/laya_gate_quant_portal_binding_v1.sv:152–175` 解真实latched13BO，只在same-hub query_ready/granted原子通过后接纳ordinary Q；`:193–210,274–286` 保留不可变source lease command，真实读债清零且完成被实际消费时release。source_query/release均接已有LN producer portal转发端口（`laya_layernorm_producer_portal_shell_v1.sv:546–548`）。 |
| provenance最终权威 | `M/rtl/laya_generated_provenance_axi_portal_v1.sv:338–359` 内已有唯一hub，query还受managed checkpoint实际route约束；保留当前A/LPV owner安装与route，不另实例第二hub。`laya_generated_provenance_hub_v1.sv:695–714,719–760,999–1055` 校全P窗口/Ref/model/地址/generation，原子捕获lease，只在精确旧Q binding及真实drain下释放。 |
| 真实算术/全A | `Q/geglu_gate_quant_split_v2.sv:200–218,307–368` 的ordinary source分支跳过G acquire后进入真实Q；`Q/quant_task_to_dual_a_v1.sv:155–185` 实例quant_f32_two_row_feeder_v1真实AXI reader、quant16_stream_row以及quant_dual_a_v1全A存储。无需改算术leaf。 |
| 实际读债观察 | `M/rtl/laya_layernorm_quant_source_shell_v1.sv:153–175` 现有AR/R计数及lease-before-AR检查可复用：ARSIZE=6/BURST=1，校RRESP/RLAST，zero outstanding且无ARVALID/RVALID才external_drained；这是局部接线参考，旧shell的service_command仍由TB输入，直接沿用旧caller不能满足D。 |

### 5. 最小编辑面与责任边界

1. **A002的program/schema面：** `include/laya_graph_program_protocol.h`、`hls/control/graph_program_protocol.cpp` 冻结限定入口；`include/laya_graph_program_sequencer.h`、`hls/control/graph_program_sequencer.cpp` 增加真实后继LINEAR选择并按kind核完成；`hls/control/graph_program_hls.cpp` 增加下一PC阶段并保持Q边界pending。若selector需新字段/flag，同步共享byte oracle/registry与相应SV；优先复用已有17类及现请求字段，不增加Host/service端口。
2. **A002的有限executor面：** `hls/control/graph_action_protocol.cpp` 增加限定LINEAR语法/绑定校验；`include/laya_task_lifecycle_fsm.h`、`hls/control/task_lifecycle_fsm.cpp` 增加有界descriptor/LOAD/Q/L快照、真实LOAD/Q结果处理及held状态，修正slot version与Ref epoch混用；`config/executor_actor_sources.cmake` 纳入compute_portal_commit源。当前actor/port仍按完整action结果工作；若只内部观察Q并持有action，其正常成功结果路径无须为Q伪造增量；若引入非终态帧则必须同步改actor/port消费语义，不能在FINISH释放活动action。
3. **A002的整链RTL面：** 在当前C阶段唯一production集成wrapper接compute hub、LOAD index0、Q index1、同hub source_query/release以及真实Q AXI/外部debt；沿现physical_config安装13BO。上表既有leaf优先原样复用，实际wrapper文件由父owner的当前C装配确定，本盘点不创建第二装配入口。A005仍只负责其已分配控制transport准备；共享wrapper/schema若有交点由A002整合。
4. **A002的冻结/验证面：** program与executor源/生成runner（`M/tb/run_graph_program_hls.py`、`run_executor_hls.py`）、当前C/D整链TB与冻结manifest加入新有限闭包、LOAD/Q模块、明确shape/窗口及独立gold。可复用 `M/tb/make_layernorm_quant_gold.py` 和旧TB的AXI模型/数值核查；不能复用其 `send_q:319–321,547` 作为caller。新增范围需受影响host/byte oracle与实际连接验证；本A004不代跑。

### 6. 可复用gold身份及验收观察点

可信旧rows16 Q/fullA证据是 `project/E003_production_chain_closure/experiment_results/runs/R003/layernorm_quant_source_03/receipt.json` 的full PASS：753.504079s，16384 F32 LN、16384 INT8与512 FP16 scale gold；Q AR16/R1024、source lease实际grant/release各一次。它明确**没有generated sequencer/adapter，也没有全S64 tensor**；cycles659334不能直接作为新整链周期。`_04` 仅兼容pilot，不是rows16 full PASS来源。

新D样本须同时观察program真实ordinal/LAX、executor真实Q/L预约、adapter/F10实际LTC末拍、hub原子lease、首/末AR/R及zero-debt、实际release、全部声明的Q/A8数值与唯一Q退休。Q rows16/K1024的TaskDone应为512 Q8_GROUP；旧marker的fullA_groups=128是4-row读出分组，不能混作512逻辑量化group。B1/S64完整NORM source先独立核全部65536 F32输出/END/发布，首窗Q核16384 INT8+512 scale；如实际声明别的shape/窗口，随声明冻结全部对应gold。未完成L不增加退休、不推进slot/PC，A保持真实READY，不启动第二Q覆盖。原轻重工具帽、单重工具与未完成M003/M004状态不变。

本次静态身份：D决定 `ed365fb216dfe55f7d497e33aa830ec5fd1e1e3310baf9c0a9d99e59e1670cb7`；分区合同 `3f2765165ed8251820ee5dd2fbbf1f0e570ee7a7a92ce129082b7836c811bd44`；program sequencer `e3af02cbd8f3475aa3e21d297a6efc6bcfac90534ff59d5ec4da02569896c520`；FSM `7e0355765d0533c2c32eabd8bec0bd1c89827f7f4eed4c2b18e808ed68665563`；commit源 `fee505c62702d01cb7faa0b54537e6272e264018dbd45eaacafd178d806643cf`；Q binding RTL `5ceed688d9d7f408c0d7d039a6b90717e2fb789174dac18ea931a07d00b78167`。行号/哈希均为过渡读到的身份，最终冻结重新核定；阶段D实际program/Q接入及生成/动态验收均NOT_RUN。

## A004续任务：owned program host与生成runner准备（2026-10-13）

父owner A002授权的阶段A/B准备任务；M003/SM003/E003/R003；适用research-agent工程证据规范和D-M003-FIRST-HARDWARE-BASELINE-01。请求模型/强度沿用gpt-6.1-sol/xhigh，实际模型身份未核实；descendant=0。唯一写入新 `E/tests/graph_program_owned_test.cpp`、`E/M/tb/run_graph_program_owned.py` 与本文件（E、M展开沿前文）；父shared header/implementation/config只读，没有回退其他agent改动。父持有串行编译/HLS/RTL执行权，本任务不运行重工具。

- **交付测试：** `tests/graph_program_owned_test.cpp:331` 分9个独立进程用例：success、bad-owner-kind、bad-owner-reserved、cancel-before-command、cancel-command-prefix、cancel-allocated、wrong-command-identity、wrong-command-source、stale-completion。主输入及主要gold复用独立 `executor_handoff_fixture.py`→checkpoint/bootstrap/admission/program_pending生成树的literal字节，完整GRANTED/LAP/LAC/LGR逐字节比较；成功LAC/LGR用literal字段及原fixture identity构造，不用DUT encode或DUT输出构造期望。
- **具体边界：** 取消早于command首读或在2拍后仍接收完旧4拍，零pending/action、ordinal0的本地错误LGR；唯一pending实际分配后取消先完整LAP、再收8拍actual action，输入原flags79且零taskID/retired的安全错误LAC，核完整4拍receipt先于LGR、原ordinal1保持。成功用例核slot/PC真实程序提交。错GRANTED kind/reserved和语法有效但外来identity/source的LGP隔离；旧ordinal completion不给receipt/result，随后匹配帧仍可接纳。终态消费前后重放旧/新owner和第二command都保持未消费，不重装、不再派发。
- **延迟范围：** command与completion输入末2拍/末1拍各暂停12个软件call，action和result输出读侧末2拍/末1拍也各暂停12call；测试不将call当clock。软件hls::stream无depth限制，输出read暂停不能证明硬件FIFO full_n反压。wide owner/receipt/LAP一次软件word也不证明实际8192bit RTL消费；result_consumed为受控host通知，真实actor连接及depth2仍NOT_RUN。
- **交付runner：** `M/tb/run_graph_program_owned.py:59` 解析父owned/base嵌套清单，核实际7+5=12个源及唯一top，拒绝executor/adapter/同步full-family进入program闭包，不沿用25源限制。`:148` 逐TU用编译器-M取项目及外部header依赖，复制并记录全部实际文件字节/SHA；literal生成器、model header/aux/manifest、配置/registry、共享SV、guard及合同也冻结。编译器仍使用原安装的系统/Vitis头路径，runner保留其frozen副本并在build后、HLS前后拒绝身份漂移，不称独立toolchain可移植构建。
- **端口审计：** `M/tb/run_graph_program_owned.py:224` 核8个FIFO/24信号，3×8192(owner输入、原owner echo输出、actual LAP输出)+5×512(command/result/action/completion/receipt)，另cancel/result_consumed/isolated3标量及真实clock/reset；拒绝额外FIFO、AXI及ap_start/done/idle/ready。HLS报告只记录逐module资源估计，不合计联合物理资源。
- **运行流程：** `--prepare-only` 做冻结、依赖和工具身份；`--host-only` 再做独立fixture、单次host build与9个分进程case；默认host全通过后继续HLS。每个attempt独立目录，拒绝覆盖。沿原CPU0–3/nice19/idle I/O/MemAvailable>192GiB；依赖/build/HLS24GiB/1800s/120s进度保护，oracle/版本/host case8GiB/120s，单重工具由父调度。

仅运行无写外部文件的轻量Python语法/清单/端口审计自检：`source_count=12 host_cases=9 fifo_count=8 auditor_accepts_aliases=1 rejects_wrong_width=1 rejects_AXI=1`。合成端口样本仅验证runner逻辑，不是DUT RTL。C++编译/9case HOST/HLS/实际冻结attempt均NOT_RUN，尚无新host或生成PASS。可由父从项目根串行运行：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_01 --host-only
```

默认生成另选新attempt并省略 `--host-only`；当前runner没有复用既有host attempt的分支，默认会重新完成其本次冻结host验证。父决定实际attempt编号和重工具时点，本任务不启动任何命令。

交付SHA256：test `2eb5fedd3195cd06e897671216969a188ada2e4d52f107a473f671b5b2d87303`；runner `ae9cad24ac0e13c7fa5572adde8bd0edeb19a73f67c8092adeb76c02ddf3b4cf`。只读父过渡身份：owned header `e3d0dfd5ea67b73aa6536d1891fa113661ba5cb589d2fa6bc390c90977ee5f52`、implementation `f45da90e3c0ff43783f5ac96af1a96136f475326134f2b9277475566425f99b9`、owned清单 `7a435f5c3c260a4913335a7ee202bb2d1c2b215156d61a10968221da2b7a0a7d`。父继续修改时以runner实际冻结身份为准。原阶段D报告已完成停止，未重复探索；本准备交付不关闭M003/M004或C009/C013。

## A004修正：真实model-binding链接闭包补齐至14源（2026-10-13）

父实际运行 `project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_01`；本A004只读其receipt和 `guard_host_build/driver.log` 核原始证据。12个实现源+1个test TU全部compile后LINK FAIL：`bootstrap_snapshot_protocol.o` 缺 `portal::build_l13m_model_binding` 与 `portal::validate_l13m_model_binding`。receipt status=FAIL，host_build 8.872840s、peak268040KiB、guard无cost trigger；没有执行任何DUT case，HLS NOT_RUN。旧attempt原FAIL保留，不覆写或升级。

父先增真实 `hls/platform/compute_portal_client.cpp` 提供上述LYMP binding助手，A004只读发现该TU的build_*命令助手仍直接引用 `full::full_span`（client:58,308–313）和 `full::full_bo_capacity`（:60），定义在 `hls/common/laya_full_memory.cpp:97,118`。当前逐object直接链接，无函数section/GC，不能因program不调用build_*就忽略undefined引用。`LAYA_TRANSACTION_SEQUENCER_CODEC` 已去掉wire_valid的encode/decode和verify_response段，不需拉入外部codec，但不消除上述真实内存检查依赖。发现已立即报父；父补真实full_memory源，既不stub、不删除模型/范围校验，也不改test绕过。

**当前候选实际清单为14源。** A004仅更新runner的required集合和scope，解析父base+owned嵌套清单，按实际路径集合大小/唯一性核对，manifest继续从 `len(sources)` 记录source_count，未只硬改计数。无写外部文件的Python语法/清单核验输出 `OWNED_PROGRAM_14_SOURCE_PARSER_READY actual_sources=14 CXX_LINK=NOT_RUN HLS=NOT_RUN`；这是CLI/parser准备，不是14源链接成功。tests未改；没有自行编译、执行runner或使用重工具。

runner最新SHA `c88e3a9352d21798c4f31ba90c3df8162172dfc90d0f7256baff7f23fd7f22e3`；父14源清单SHA `1c70fc2e949c900d5d7ed0eb8bc4e19635366b71b590d0c63013a4b8045d0b38`；test仍为 `2eb5fedd3195cd06e897671216969a188ada2e4d52f107a473f671b5b2d87303`。前节12源和原runner哈希是历史准备身份，本节为新的冻结候选。已向父明确**停止runner写入**，父可在control transport RTL_01之后按其单重工具调度冻结新 `graph_program_owned_host_02`；未接触RTL_01已冻结来源。

父要求matching host复用HLS模式留后续任务，当前未添加reuse分支，不在父launcher冻结期间并写runner。14源HOST及生成仍待父真实运行；本准备修正不改变M003/M004未完成状态。

## A004续任务：已验证host复用、独立HLS入口（2026-10-13）

父完成 `project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_02` 后授权A004只改runner与本result，不改tests/任何frozen attempt，不跑重工具。已只读核原始receipt、manifest、guard/log：14源+test实际compile/link通过，host_build 9.034526s、peak267344KiB、无cost trigger；9个分进程DUT case均有唯一对应PASS marker，总status=PASS_SCOPED_HOST。软件streams无depth限制、controlled GRANTED/LAC和result_consumer输入等前述限定仍在；HLS原receipt仍NOT_RUN，host通过不代签actual连接。

新增 `M/tb/run_graph_program_owned.py:281` 的 `verified_host_attempt` 和`:417` 的 `reuse_host_inputs`，CLI为 `--reuse-host-attempt`：

- 严格核本runner实际schema/scope、14源清单及宏、9case、全部14个operation PASS/guard原始JSON/唯一9marker、host实际命令、15个compile TU和dependency spec/15条-M命令、host binary及全部fixture字节、原launcher、g++/Vitis路径与SHA和版本log。
- 核398个frozen文件original/frozen配对和当前身份，含48个项目-M依赖及326个系统/Vitis外部header；外部header列表须与manifest完全相同，每个有冻结副本，HLS前后再核原安装头身份。源/test/模型/合同/共享schema或配置源清单漂移均拒绝。仅catalog metadata和当前新HLS driver允许已记录的漂移，实际14源身份必须精确匹配；本次实际检查只有runner自身改变。
- 只在PASS及身份核验后复制原冻结树到新attempt，保留已证明的旧runner；另外封存当前HLS-only driver及其哈希。derived HLS config仅替换旧frozen路径为新frozen路径，核反向替换、part/freq/top与全部14条syn.file。新manifest/receipt链接原host证据，标明 `host_measured_in_this_attempt=false` / `REUSED_PASS_SCOPED_HOST`，不把旧HOST计为本次运行。
- reuse分支只启动`:459` 的HLS guard与生成端口/逐module资源审计，不重跑依赖提取、oracle、host build或9case；`--host-only`与reuse冲突会拒绝，`--prepare-only --reuse-host-attempt`可仅核验/复制。新attempt拒绝覆盖；原_01/_02均只读保留。

本次只执行无写attempt的轻量语法与完整read-only verifier：`OWNED_PROGRAM_REUSE_IDENTITY_REVIEW_PASS host_02=PASS_SCOPED_HOST cases=9 sources=14 frozen_files=398 external_headers=326 failed_host_01_rejected=1 writes_to_attempts=0 HLS=NOT_RUN`。实际_02正例通过，实际_01 FAIL反例被拒绝。未调用reuse复制或HLS guard，未运行编译/主机DUT，也没有新增生成PASS。

父可从项目根按原单重工具调度执行以下明确复用入口，不默认重复9个已通过host：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_01 --reuse-host-attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_02
```

本次生成候选仍是实际FIRST owned program consumer的 **3×8192 +5×512 FIFO**，保持单owner/单command、不加入阶段D新增codec闭包。它可提供这个真实top的生成、接口和资源观察，**不是5个wide port同口径微top，也不能单独证明该疑点根因**。实际生成后仍须按scope审核，不据host或独立top宣称LN/Q整链、depth2、rearm或M003/M004完成。

runner最新SHA `11a55985e79ddcba2ea24ddd85ad09be54f617bd94889077e6742c8deabc16bb`，已通知父完成并**停止runner写入**，可冻结 `graph_program_owned_hls_01`。test仍为 `2eb5fedd3195cd06e897671216969a188ada2e4d52f107a473f671b5b2d87303`；没有修改父实现、配置清单、任何已冻结attempt或其他agent工作。

## A004新准备任务：NORM专用构包独立gold及泛型等价验证（2026-10-13）

父A002明确授权的结构减法验证准备，M003/SM003/E003/R003；使用research-agent工程实验/hardware证据规范。唯一新写入 `E/tests/norm_provenance_specialization_test.cpp`、`E/M/tb/run_norm_provenance_specialization.py` 与本result；原owned runner/test、共享三源、配置及所有旧attempt只读。A005拥有新增NORM两个API及FSM调用面的共享三文件，已发稳定身份并停止修改。请求模型/强度继续gpt-6.1-sol/xhigh，actual身份未核；descendant=0。父仍独占单重工具执行；A004没有编译、依赖预处理、运行DUT/HLS或创建attempt。

### 独立覆盖依据

- **gold独立性：** C++测试使用固定独立NORM物理常量STATE0/base8388608/映射末16777216/row4096/batch4194304；期望descriptor extent由批数、owner行数与宽度的直接代数计算，geometry由输入context直接计算。literal_packet使用LPV1固定字节位置逐字段生成所有1024字节，不调用DUT地址/descriptor/geometry/portal序列化/encode/decode，不从generic输出取得gold。DUT的encode只用作待比对实际结果；另一个独立literal state序列化同时核inactive descriptor/geometry默认字段与拒绝留下的构包前缀。
- **完整比较：** 对专用与泛型两条真实函数分别核完整Check.code/detail/bad_element、persistent high-water、protected_task、完整Request字段及1024字节wire；两条均须符合独立gold，而非仅相互相等。固定last_task/tasks_retired及ownermetadata/两组64word coverage必须不变，不用构包通过代签owner发布或任务退休。
- **shape/窗口矩阵：** B1/2 × S1/16/64/1024 × epoch7/41/0xfffffffe；每组合CLAIM/PUBLISH/INVALIDATE。合法S64/1024核每批每个rows16窗口的BEGIN及最后row的rows1补充子窗，descriptor始终完整whole-owner，geometry保持实际batch/row0/rows。每模式矩阵计划72 owner事件、648 BEGIN，含合法612个rows16窗口、18个rows1补充子窗及18个短shape拒绝BEGIN。
- **保持旧shape边界：** S1/S16由泛型f32_address先拒绝E_BUFFER/detail(4,NORM,5)，descriptor已耗event sequence且只留下metadata前缀；专用必须完全相同，不新增短shape接受。S65是已有地址range与严格task合法shape不同的边界：owner元数据仍接受；BEGIN tail1只在sequencer codec旁路模式接受，真实wire的check_context拒绝E_ABI/detail(4,0,22),bad_element16。该兼容边界独立记录，不改gold以迎合实际DUT。
- **拒绝与前缀：** unknown Ref、epoch0/0xffffffff、NORM bank1、region1、unknown RowSpace、width0/1025、rows0、首行/末行溢出、batch/B/S越界、错误action、wrong unit/zero elements、stale/foreign snapshot、READY/READ状态、wrong ctx batch/row0/rows/taskID/op/stage/layer/row-layout。在真实wire模式核严格拒绝，在codec旁路模式保留旧上游校验依赖，不新增构包层严格规则；几何first/next先后、最后row未在旁路构包层检查等旧行为须如实保持。
- **capacity/presence：** 0、16MiB-1、16MiB、16MiB+1、UINT32_MAX、UINT64_MAX及空STATE0指针配完整capacity；容量不足为NORM reason8、空physical presence为STATE0 BO reason9，均核耗号及具体partial Request。测试只检查地址presence/range，使用不被解引用的one-byte sentinel，没有fake payload数值验证。
- **完整identity/model/old Ref：** 对owner NumericIdentity四tag的每个byte及request/generation最高bit、B/S逐项改动共68个拒绝；对opaque MODEL_IDENTITY的416个byte分别改变并核完整传播（模型准入仍由上游负责），覆盖末byte。EXCLUSIVE_RW保留真实lease_old_ref，合法/NONE/未知旧Ref在两宏下分别核旧wire行为；src/D/gamma/eps非构包字段和不等于geometry的非零elements仍按generic传播，不声称算术或task准入通过。
- **seq耗尽：** UINT64_MAX-1合法最后分配、UINT64_MAX禁止再分配；owner/BEGIN reset与early unit/snapshot失败的不同Request保留顺序均独立核。没有仅比较返回status而忽略副作用。

总计每模式计划1269组专用/generic独立对照（99 owner、1170 BEGIN），两模式2538组；这些为测试源码计数推导，**尚非实测通过数**。6个case（matrix、owner-rejections、capacity、begin-rejections、sequence、old-owner-model）在sequencer/wire两套独立build下分12个host process执行。

### runner冻结与可执行入口

新runner实际显式7源闭包：laya_numeric、laya_tasks、laya_memory_map、laya_full_memory、laya_full_owner、generated_provenance_codec、generated_provenance_events。加test为8TU；分别以有/无LAYA_TRANSACTION_SEQUENCER_CODEC编译，真实generic和encode/decode均保留，不使用stub/删校验/函数GC绕过链接。源list只用于本host verifier，不修改父HLS清单，也不复用旧owned runner作为live import。

默认及--host-only仅执行HOST，不提供HLS命令。--prepare-only只冻结两模式真实-M依赖及compiler身份，不build/test。复制源/test/runner/model-generated-header及manifest/guard/helper/相关现合同/config，实际-M对每模式8TU求union，记录/冻结每个项目与外部系统/Vitis头的bytes/SHA。build仍使用原安装include路径；build前后逐项拒绝外部header及冻结文件漂移，不声称可搬迁独立toolchain。记录compiler可执行文件SHA/真实version log、全部dependency/build/host命令、launcher、guard JSON/log、binary身份与唯一case marker。

CPU0–3/nice19/idle I/O/MemAvailable>192GiB继续；依赖/build guard24GiB/1800s/120s真实进度保护，version/每个hostcase guard8GiB/120s。不同attempt拒绝覆盖，guard失败保留FAIL/COST_STOP，不升级未执行case。父持有单重工具调度，runner不会自动探测或管理其他项目进程。

父可在当前owned HLS出口后，从项目根串行执行：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_norm_provenance_specialization.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/norm_provenance_specialization_host_01 --host-only
```

只做轻量无attempt写入Python AST/常量/文件路径核验，输出 `NORM_PROVENANCE_PREP_STATIC_PASS modes=2 cases=12 sources=7 compiler=NOT_RUN DUT=NOT_RUN HLS=NOT_RUN attempt_writes=0`。尚未证明实际7源链接或2538组对照通过。HLS/RTL/FIFO depth2/AXI debt/数值payload/cycles/完整图/rearm全部NOT_RUN；此次准备不关闭M003/M004。

test SHA `8471d42c8d2003c7c494d1c0be988df0bea71a93adae6bf9086c5a454f0b1b09`；runner SHA `bcd1145f1aaf16ed7aa8c964fcdd2a6c6460a8d91d18b2373e62fb535c5009f7`。只读A005稳定身份：events CPP `775936e115fae7782fa715a536f25fe2c2286b278fd93c3afa687169eca2f38e`、events header `aa62ad539cd8b88e1cc3f7601bcf7da48313594520d252bd4df193742e10b8c0`、FSM `ee19f74d6af8f69bfc14c92c5f2bc94af572eca94f48795c153eb59045473e51`。已经实际向父发运行命令及SHA，并明确停止test/runner写入；本文件补齐后等待新任务，保留其他agent改动。

## A004有界只读诊断：owned HLS_03真实LAP输出裁剪（2026-10-13）

父A002的新明确任务，唯一写入新 [诊断报告](../../project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_03_port_diagnosis_A004_20261013.md) 和本result；不改共享源码、runner/checker或任何attempt，不运行编译/HLS/RTL，父持有唯一重工具NORM host_01。请求gpt-6.1-sol/xhigh，actual未核；无子agent，沿research-agent工程/hardware证据规范。

实际 `graph_program_owned_hls_03` HLS child0、345.905041s、peak4832216KiB、无guard trigger，生成实际top但receipt保持**FAIL_PORTS**。LAP program_pending实际8192位dout/empty_n/read，RTL assign read=0；driver2939–2945明确no fanin/fanout，原要求din/full_n/write未满足。其他7FIFO的21信号通过，不改变checker或把生成升级成硬件PASS。

**直接IR失活证据已定位：** 用安装自带llvm-dis仅解析既有bc到进程内存（无生成文件/重编译）。`a.g.ld.5.gdce.bc`阶段已删除legacy externC，唯一真实owned step调用仍传local `%key`，完整四字段验证及bound_command的icmp-ne-null写入、State.key拷贝和const observer均存在。到 `a.g.0.bc`，program_hls::step的key参数、bound_command/State.key、pending_sent均消失；READ_COMMAND只剩cancel&&beat0早返，即采用null-key旧语义。owned phase3/WRITE_ACTION直接store isolated=true，无observer/无LAP write。因此是实际可达控制失活，并非接口别名或满FIFO；已定位gdce→a.g.0转换区间，但缺逐passIR，未认定具体AMD pass/通用工具bug。

`observe_pending(const State&)`源码读同一持久状态，裁剪前IR正确；仅const不足以定因。同TUlegacy源码确有nullptr调用，但legacy在gdce已DCE且唯一剩余调用非null，不能把legacy/null调用或名字碰撞写成已证原因。原完整command/action/Key validate与实际ordinal保持。

父已接收实际collaboration诊断并选择待测修复：保留旧pointer overload兼容，新增内部explicit bool has_issued_key + const完整Key& overload；owned与legacy actual top直接true/key与false/空Key，综合可达路径不依nullable pointer地址判断。四个64位S/request/sequence/H、首拍实际接受后锁存、取消旧command清理与完整LAP验证/成功write才sent的顺序不改。**此为待测试修复假设，未签HOST/新HLS/RTL结果。** 父维护共享header/两源，A004没有代改。

报告含原冻结行号、可复现llvm-dis输出行号、实际read=0及IR摘录和8项bytes/SHA。gdcebc `542cca8ee6702926f0198850ea5b3981e9db37dbd81c1c4661290ee50e966648`；裁剪后a.g.0 `c354e7be9f8af97701d3cce2447f0e55ac5cdc2ef3db2b4916fae3d94f757039`；RTL `bf3d49b6c7f630a0057ab82ba836702b36be720cf008a659d3bdae3b63e9ed49`。后续先受影响完整HOST，再新独立生成严格port audit，随后真实消费/反压；报告不改旧FAIL_PORTS或M003/M004未完成，不改预算。

## A004 owned program有限RTL准备交付（2026-10-13）

父A002授权只准备新TB/runner及本result，父持有唯一重工具；未改共享HLS/header/checker、旧attempt或其他agent文件，无下级agent。使用已读research-agent工程/hardware证据规范。父恢复通知：owned_host_05九项PASS、explicit bool + 完整Key修复的新owned_hls_04已启动；该通知不作为A004的新RTL测量。A004本次**HDL编译/HLS/RTL/新attempt均NOT_RUN**。

新文件交付后停止修改：

- [laya_graph_program_owned_tb_v1.sv](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_graph_program_owned_tb_v1.sv)：14010 bytes，SHA `0364c8b9b418925ece5d1a8c4b7997b0f89c98f21bb3c3ba8e730c6f97aff5fe`。
- [run_graph_program_owned_rtl.py](../../project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned_rtl.py)：29309 bytes，SHA `022d6880410882b35e59f23a4d5b97a377aca80850a954b11d3ac7edf98736d3`。

仅接受`--program-hls-attempt`指向未来严格**PASS_SCOPED_GENERATION** owned freeze，核验十四源完整project/model/external-header冻结、HLS真实guard PASS、生成top身份及全部实际`.v`子模块/`.dat`收据。独立解析全部29端口，必须8FIFO/24信号、3×8192+5×512，LAP严格OUTPUT8192的din/full_n/write，无AXI/ap_start/done/idle/ready或额外端口。允许经过严格方向/宽度核验的Vitis `_V`名称别名；派生端口宏及Tcl只在新attempt内部生成。旧`graph_program_owned_hls_03` **FAIL_PORTS明确拒绝**，没有放宽checker或升级旧状态。

独立gold只来自固定`graph_program_owned_host_04`完整PASS_SCOPED_HOST；固定receipt SHA `22921398fd0686e005c0e24b32cfeadabf24aa38280660025a6c52d9d47fe98e`及manifest SHA `4ede53846c14a488a2c0d17c9aaa37e1d060ec6536b46059d25731024a4d8e50`。核验399项实际冻结文件、所有37项fixture及九case/独立oracle/host build的真实guard/log/marker。完整GRANTED1024、LAP1024、LGP256、LAX512、cancel LAC256和LGR256均从独立literal fixture复制；success LAC/LGR、本地取消ordinal0 LGR、旧ordinal2 LAC和新owner按该独立host测试的固定字节规则生成，未调用DUT encoder或采样DUT输出。运行会冻结host/generation的源和模型闭包、raw evidence、runner/TB/FIFO/guard/工具身份、全部11 gold的bin/hex及派生输入；旧host证据明确`measured_in_this_attempt=false`。

四个独立sim进程只在case开始复位：success、cancel-command-prefix（实际前两命令拍读完后持久cancel）、cancel-allocated（实际LAP输出握手后cancel）、stale-completion（旧完整LAC丢弃后输入正确cancel LAC）。每case内不复位、不清FIFO、不伪造终结；8条通道均为真实depth2 FIFO。完整echo/LAP/LAX/LAC receipt/LGR逐字比较并计数实际写入和消费；命令/完成帧在2拍/3拍后空输入12周期；allocated场景LAX、completion receipt、LGR尾2/尾1各保持12真实周期；本地取消只产生LGR，不能分配LAP/LAX/receipt。LAC receipt最后**写入**后允许LGR先于最后receipt消费，不引入DUT不存在的消费者释放门。

LGR尾部期间真实FIFO保留两条owner重放（含新owner完整字节）及下一LGP的前两拍；最终第四个真实LGR消费后才提供持久`result_consumed`，再观察20000周期保持FIRST，没有第二owner/command消费和额外LAP/action/receipt/result。该scalar仍为**受控抽象通知**，并非owned executor receipt或unique software retirement；受控LN task LAC peer不是实际END/executor/LN/hub/数值服务。不能宣称admission/source READY ownership、同runtime完整生产链、13BO完整图、CLOSE/rearm、联合资源、OOC、物理时序或上板通过，不关闭M003/M004。

成本：CPU0–3/nice19/idle I/O/MemAvailable>192GiB。static24GiB/1800s/120s停滞保护；success pilot8GiB/120s、每case最多1Mcycles。只有pilot真实周期/耗时允许`pilot_cycles*2+25000`投影同时≤1Mcycles和≤120s时，才按该有限cycle cap串行运行余下三case，各8GiB/120s；否则保留COST_STOP。父负责唯一重工具调度，runner不管理其他进程。最终全四case实际通过才写`PASS_SCOPED_RTL_OWNED_PROGRAM_FIRST`。

父可在owned_hls_04结束且实际严格生成PASS后，从本项目根执行（如该generation失败则不得当仿真输入）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned_rtl.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_01 --program-hls-attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_04
```

本轮仅轻量无attempt写入核验：Python AST，host_04固定身份/399项冻结和11完整gold字节顺序roundtrip，严格synthetic29端口/24FIFO信号、`_V`别名、错误LAP方向和额外ap_start拒绝，TB全部宏存在及begin/end/task/endtask计数。实际旧HLS_03端口复核为21信号、LAP输入三信号，strict audit失败且generation状态 gate拒绝。输出 `OWNED_PROGRAM_RTL_PREP_STATIC_PASS Python_AST=1 gold_host_04_freeze=1 gold_packets=11 macros_complete=1 strict_24_ports=1 wrong_LAP_direction_rejected=1 FAIL_PORTS_rejected=1 HDL_compile=NOT_RUN RTL=NOT_RUN attempt_writes=0`。这些检查不证明SV能编译或任何真实RTLcase已通过。路径/身份/范围已实际通过collaboration回传父，TB和runner停止写入。

父补充HLS04实际复用host05后，A004只读核验：host05 receipt为PASS_SCOPED_HOST，host04与host05的全部37项fixture bytes/SHA完全一致，独立`tests/graph_program_owned_test.cpp`冻结字节一致。runner的host04身份仅用于独立gold；`--program-hls-attempt`实际冻结闭包单独核验，并未要求其HLS源码或host_reference等于host04，兼容host05的显式Key内部修复，不放宽任何身份或FAIL_PORTS gate。此核验无新增attempt/编译/仿真，TB/runner SHA仍为以上交付值。已实际回传父执行命令并结束准备任务。

## A004 owned RTL runner普通预检修复（2026-10-13）

父通知真实owned_hls_04已PASS_SCOPED_GENERATION（guard442.930003s、peak5421624KiB），并授权仅修复A004新runner的普通准备错误。原比较将实际`work/hls/syn/verilog/laya_graph_program_owned_sequencer.v`完整rec直接与`port_evidence.generated`相等比较；该收据实际记录attempt根的端口审核副本，两文件路径不同、bytes/SHA相同，因此误拒绝。两份真实文件均9122 bytes、SHA `e9bc2882d48b411d5c5243c96622006385ef8c8b40793e876888020702aada92`。

只改新runner：要求receipt.generated_candidates与唯一实际生成候选精确一致；审核副本先按完整rec核验，并必须为attempt根的精确TOP.v路径；实际生成top与审核副本再比较bytes/SHA，两个不同路径身份均记录。实际生成220项.v/.dat继续逐项核验，完整八FIFO/24信号方向/宽度严格gate和FAIL_PORTS拒绝不变。TB、共享源码、生成树、所有attempt未改。轻量实际`verify_generation(HLS04)`及固定host_04 gold身份核验PASS；HLS03 FAIL_PORTS仍拒绝。输出 `OWNED_PROGRAM_RTL_PRECHECK_PASS generation=HLS04 status=PASS_SCOPED_GENERATION FIFOs=8 signals=24 generated_files=220 top_copy_and_actual_hash=equal gold_host_04=verified external_tools=NOT_RUN attempt_writes=0`。

修复后runner29810 bytes、SHA `a554895d67b4796847acdf1ae6f1344572a739123e9be2f88a66613166549444`，替代此前runner身份；TB身份不变。HDL编译/RTL未由A004启动，运行命令参数不变且父负责新immutable attempt命名与重工具序列。已实际回传父修复与轻量PASS，停止runner修改。

## A004 owned RTL02首次owner失败只读定位（2026-10-13）

父实际执行 `graph_program_owned_rtl_02`：static PASS，success于84555ns触发原TB隔离断言，dynamic FAIL；父另以原已编译快照在两个新有限诊断目录观测。A004仅读取真实fixture、冻结RTL、既有HLS04 bc及诊断日志，未改TB/runner/共享DUT/任何attempt，未启动HLS/编译/RTL。安装自带llvm-dis只把既有bc解析到进程内存，不写IR文件。以下只定位当前FAIL，不升级为任何功能PASS。

父诊断01/02在84540ns的语义链为：handoff control头检查全部通过；bootstrap decode_2成功；handoff validate_2失败；其中session/request非零通过，而嵌套bootstrap validate_3返回非零。packed m RAM实际kind4、source purpose1、sequence1、epoch7、address0x1200000000、capacity16920576及target/extent等语义字段正确。**canonical equality仍是NOT_MEASURED**：decode_1 state439遇validate失败直接跳state450，state440–449的encode/完整比较没有运行；`icmp_ln20_reg_13570=1`不能被记为canonical PASS。owner kind1/commit0/code0为decode失败的默认输出，不能据此反推输入kind。

**已证实的普通生成位选错误：** `graph_program_owned_rtl_02/frozen/external/program_rtl/laya_graph_program_owned_sequencer_validate_3.v` state1在3932–3933读m地址0；2618–2626在state2采样真实m_q0。10112把purpose取成m_q0[15:0]，9078与16'd1比较；正确source purpose是完整Message的ram0[207:192]。validate_2实例181/184直接传m_q0/q1，state4的323/343直接转发读地址；decode_1实例2911/2914也直接传真实m RAM，2626–2638为512bit×12真实同步RAM。没有字节/位偏移补偿。实际kind低字节4已足以使错误purpose比较明确失败，未把padding X认作错误原因。sequence/epoch/address/capacity依然使用[319:256]/[383:320]/[447:384]/[511:448]正确source位置，因此不能泛化成完整source指针偏移全部丢失。validate_3 6391–6394在purpose等首组条件不成立时跳state496，2532–2533写protocol code7。

**具体IR边界（行号为该安装llvm-dis `-o -` 输出）：** HLS04 `a.g.ld.5.gdce.bc` 9541–9542用Message field3 GEP取binding；10423–10424用checkpoint Request field0 GEP取source并调用bootstrap validate；10595–10597正确从bootstrap Request field0 load i16 purpose。到 `a.g.0.bc` 的specialized bootstrap validate，38570–38574变成load m[0]后直接trunc i512 to i16，缺少192位右移，而38577 sequence右移256等仍正确。`a.o.3.bc` validate.3 2020–2024同样m[0]→trunc16→eq1，继而RTL原样生成。首次可见坏映射区间为gdce→a.g.0，未据此认定某个具体AMD pass或通用工具问题；已排除把当前失败仅归因于末尾out=m/sret赋值的解释。

已向父交付最小语义保持建议：保持公开`Check validate(const Request&)`签名；原完整校验体移入内部`validate_fields(const Request&, Purpose purpose)`（HLS INLINE off），只将原r.purpose比较改为参数purpose；公开wrapper HLS INLINE并调用`validate_fields(r, r.purpose)`，将实际字段在原调用对象处取出并跨函数边界传标量。所有其他字段/模型canonical/实际codec/完整equality保持，不常量化purpose、不删除validate。新生成仍须核验nested actual purpose来自m[0][207:192]、内部scalar eq1，运行完整HOST及invalid-purpose拒绝，并通过严格八FIFO及真实RTL。父负责应用及重工具；本建议尚未测量为修复成功。备用完整独立source对象需要640B copy，整对象赋值可能再次折叠为derived pointer，因此不优先。

本次原始身份（均位于R003下；bytes/SHA）：

- HLS04 `work/hls/.autopilot/db/a.g.ld.5.gdce.bc`：347208 / `999a25488ba5c1b86c3e8c02251dadd1ccff69af8c030d9e9df90a8c0b82c7b9`。
- HLS04 `a.g.0.bc`：1055784 / `87f888df177d0191800425da4881fe5f934db79ddc918ea6993502ac419eabab`；`a.o.3.bc`：2401880 / `1f060c3eb9dc9590acad63c52291a53a025358bd7af93b6fbe36c1934b7f5d99`。
- RTL02 frozen `decode_1.v`：616122 / `5268d5c9b8b5c978e30c53cdd11c0ba93c361b04eaab4732f439868ac983d4e9`；`validate_2.v`：29439 / `9cb3ab0dc8f33e03939773daeb12bacca5c67def4cba37ad468c060e524de1f1`。
- RTL02 frozen `validate_3.v`：465490 / `b838d41ba6b88cc0391f1b093367922c97810db1c9e610cfa833210599a4c048`；`validate_18.v`：480017 / `d61335c45f3791f85a1e99f724bf0c292c9191c82933199b9581b1f78e74e816`；RTL文件名前缀均为`laya_graph_program_owned_sequencer_`。
- `graph_program_owned_decode_diagnostic_01/guard_rtl/driver.log`：7883 / `1de67b54a54a9781fdabcfe40468bf56e87cc588f5b987596ba26befeff93c08`；diagnostic02同路径：8323 / `3059447d4e951cb74225f24cf500b92142853dd221e60dae582734d082134712`。两者均是父执行OBSERVED诊断，不是功能PASS。

## A004 owned HLS05/RTL03只读后续字段定位（2026-10-13）

重新读取research-agent及engineering/hardware参考、适用AGENTS、M003/当前首请求合同。父单owner实施purpose scalar：公开validate inline调用完整validate_fields(Request,Purpose) inline off。本agent静态比较live完整校验体（去新增pragma并将参数purpose恢复r.purpose）与HLS04冻结原validate体逐字一致；header/same_binding/request及response decode体也未变。此时live源7768 bytes / SHA `606925b36174bea22469079e0c9f608936a708f71336b00634f81ebf4fef7990`。父后续通知host07十process PASS和HLS05八FIFO限定生成PASS，不作为A004新实测；原失败和identity保持。direct/nested invalid-purpose建议已回传，父已冻结第十process；不改其tests。HOLD(kind1)/真实purpose非法及0x0101是后续区分性覆盖建议，不新增启动前置。

父实际RTL03仍在84645ns phase1 isolation FAIL。父新诊断03于84620ns观测旧失败前链，本agent只读其原log并严格筛选startswith `OBS `：236条OBS、0条真正OBS_MISSING；Tcl echo内出现的字符串不计缺失。purpose实际0001、首predicate `icmp_ln71_reg_9267=1`，已证实原purpose位选修复；nested validate_fields返回7，validate_2返回失败，handoff decode_1失败。

**当前已执行的下一个失败是content：** nested模块 `laya_graph_program_owned_sequencer_p_anonymous_namespace_validate_fields.v` 的9124将 `icmp_ln79_4` 写成region_fu!=8'd1；10056的region_fu取m_q0[7:0]，state9在3931读ram9、state10使用它。该字节为source target_region=0，正确content为ram9[199:192]=1。width检查9130/10090取ram9[191:176]=1024正确。诊断实际 `or_ln79_reg_9486=1`，同state10其他已存条件通过；6457–6460据此直接跳state496。故state11几何组及模型copy/build/canonical/l13m调用均尚未执行；其X寄存器或子module初始return0不能被记为真实PASS。

HLS05原gdce IR10811–10813的content使用OwnerDescriptor field11 GEP/load i8，语义正确；a.g.0 IR38757–38759读取ram9后trunc低byte作region，38903–38908的width右移176正确，但content比较复用该region值（缺少192bit offset）。a.o.3 IR33952–33954定义m_load_17/region，34056–34060同样content比较复用region，RTL忠实生成。此错误不依赖padding X。

**当前未执行路径中的七项model copy静态错误：** 在HLS05 a.g.0 validate_fields函数38570–41379，对全部416个非constant数据store沿固定word load/lshr/trunc追溯，416项可定位、0unknown，其中409项正确取完整Message byte152+j；j={0,64,128,192,256,320,384}七项错误取ram2..8的byte0，正确应为同word byte24。例如IR40911的model[0] store源byte128，应152；40975的model[64]源192，应216；41295的model[384]源512，应536。不能仅修content后再用八分钟生成发现该已有静态缺陷。整数组赋值改完整416B动态循环（unroll off），与当前正确canonical equality的索引机制一致，是父可验证的语义保持联合候选；本agent没有改源码。

逐字核对诊断03 Message RAM的真实model byte152..567与RTL03独立owner.bin wire[160..575]，**416/416完全一致**，所以没有把局部copy错误归因于Message的sret/out或fixture。canonical equality本身IR41346–41354使用152+i、按word/byte动态选择并完整416循环，静态正确；动态尚未到达。handoff完整1024B equality仍在validate之后，当前继续NOT_MEASURED。

后续source字段静态对照：layout ram9[207:200]、role[215:208]、bo_span[319:256]、owner_base[383:320]、row_stride[447:384]、batch_stride[511:448]、extent ram10[63:0]、head_stride[127:64]、plane_stride[191:128]均对应真实结构位置；未把未执行分支写成动态PASS。l13m其他输入未见同类offset候选：IR41371调用validate_l13m_model_binding.16(m,id=64,model)，callee41868后用id+0/8/16/18取request_id/generation/B/S，id+20/36/52/68取四16B tag（实际Message offsets84/100/116/132），各load均按显式byte offset分word和bit；same_bytes.17同样保留显式offset。真实RTL m地址1/2与跨word tags静态相符。

父提出contentscalar+完整copyloop+已有purpose的联合候选与以上证据对应，尚未证明修复成功；后续收益/成功必须归于新联合冻结，不归功单项。新生成需看实际purpose来自ram0[207:192]、content来自ram9[199:192]、全部416B copy来自152+i，特别核七个块首；真实动态须观测state10通过、state11几何通过、copy结束、build/canonical/l13m实际start/done后才判返回0，并另核handoff完整1024B比较已执行。D-M003-OWNED-PURPOSE-COVERAGE-01的真实nested模块独立TB准备尚未由A004实施，等待父明确文件ownership任务。本次唯一写入本result；无重工具、无共享修改、无冻结物修改、无下级agent，停止继续树探索。

当前原始证据身份（R003）：diagnostic03/guard_rtl/driver.log 132197 bytes / `7bae65dcc20f8ca51e6e36a7c314766e2e631c1d00677f8cd779c81fd2d6ace2`；HLS05 a.g.0.bc 1056976 / `6106afb8b6473d1652e0e79494772e7e19eeb226c618c23188ef5982921af5a5`；a.o.3.bc 2397896 / `38457581ef29f094f04ac821cada7c04708b78406a2eedb8779c1281cc2a84e8`；RTL03冻结nested validate_fields.v 466077 / `468571b1614e2cef9add0cc8bc1a4fb3788e1c614fc74e979a1cdb7729040864`。

## A004 字段表、serialize闭包与独立validator准备（2026-10-13）

父授权仅新增M/tb内`laya_owned_bootstrap_validator_tb_v1.sv`、`run_owned_bootstrap_validator.py`及本result；其他人共享工作区，未改共享source/header/tests/既有runner/checker/旧attempt。D-M003-OWNED-PURPOSE-COVERAGE-01允许测试真实nested模块，不增加wire或安装owner接口。主控补充unknown mask只限独立ABI布局证明的内部padding；不能从失败反推扩大mask，不能mask语义/model/canonical/wire保留位。

字段均为完整Message的byte offset；ram每word64B。RAM值已经与独立LHC1逐字核，但“RAM值已观测”不等于对应validator分支已执行。

| 字段/类型 | 预期Message位置 | HLS05实际检查/复制位置 | RTL03动态状态 |
| --- | --- | --- | --- |
| purpose/u16 | 24，ram0[207:192] | 已传独立scalar，位置正确 | 1、predicate通过 |
| sequence/base epoch/address/capacity/u64 | 32/40/48/56 | ram0对应64B字段正确 | 首组通过 |
| NumericIdentity req/gen/u64、B/S/u16、4×16B tag | 64/72/80/82；tags84/100/116/132 | 同位置，完整tag循环 | numeric首组与tag差值通过 |
| target Ref id/bank/u8、epoch/u32；region/u8 | 568/569/572；576 | 同位置 | check_ref及前缀通过 |
| old Ref id/bank/u8、epoch/u32；region/u8 | 580/581/584；588 | 同位置 | state10检查通过 |
| stage/layer/batch/rowspace/u8；row0/rows/width/u16 | 589/590/591/592；594/596/598 | 同位置 | state10检查通过，width1024 |
| content/u8 | 600，ram9[199:192] | **错误复用576的target_region** | 0≠1、or_ln79=1，实际失败 |
| layout/u8 | 601，ram9[207:200] | 正确 | 同state10已存predicate通过 |
| role/u8；span/base offset/row stride/batch stride/u64 | 602；608/616/624/632 | 正确 | state11未执行 |
| extent/head/plane/u64 | 640/648/656 | ram10[63:0]/[127:64]/[191:128]正确 | state11未执行 |
| model_identity/416B | 152..567 | 409项正确；7块首错误128+j，应152+j | copy/build/canonical均未执行 |
| mode/u16；handoff/u64；target64B；Check16B；commit/bool | 664；672；680..743；744..759；760 | 外层输入位置与独立wire一致 | validate_2因nested失败，完整handoff canonical未执行 |

7个错误copy点的model下标为0/64/128/192/256/320/384，对应正确Message bytes152/216/280/344/408/472/536（ram2..8 byte24），错误读取bytes128/192/256/320/384/448/512（同word byte0）。Message内原完整416B与独立owner wire[160:576]完全一致，不能修fixture或仅用7个常量替代。

父额外要求检查handoff encode→checkpoint binding_packet→bootstrap binding_packet/put_owner实际序列化闭包。HLS05 a.g.0 IR36928–36941的model序列化循环正确取152+i、写160+i；41495–41498正确从ram9右移192取content、写wire602；36752–36757正确从ram0右移192取purpose16。checkpoint复制完整664B并按原target字段写出，外层完整1024B equality保持。该闭包静态没有所查同类错误，父联合候选不需再修改encoder；动态仍未进入。

准备交付身份：

- `M/tb/laya_owned_bootstrap_validator_tb_v1.sv`：4843 bytes / SHA `4af52e18b629190009b2309149ae3a7b27966363aa8042e5e0994519cd5dcc38`。
- `M/tb/run_owned_bootstrap_validator.py`：23744 bytes / SHA `dab7e229df6555dec78aca117ea199ecc51a4ae8fb5fa4d9add4c7d0f5536213`。

runner只接受指定未来`graph_program_owned_hls_06`的严格PASS_SCOPED_GENERATION；复用原strict verifier核完整14-source/model/header freeze、8FIFO/24方向及全部220实际v/dat，并冻结原caller连接和整个实际生成依赖，不制造DUT wrapper语义。独立TB只有真实generated nested双同步512bit Message读口、purpose16/content8和原ap_ctrl_hs；read-first注册输出初始X，在真正读握手后更新，实际边沿采样start/done/return。没有owner安装端口、没有owner/endpoint/软件退休的结论。

固定diag03原log和RTL03独立owner SHA。受控Message768B中719语义bytes全与独立LHC1对照（source purpose在独立LHC1 kind之外按实际观察1登记）；416模型bytes逐字一致。原49内部padding bytes/392未知bits为1..7、26..31、148..151、570..571、577..579、582..583、593、603..607、666..671、684..687、746..747、761..767，完整覆盖来自类型的ABI padding且与原X集合精确相等。保存原12word X文本、逐bit mask及仅未知bits置0的baseline，已知bits改变0。任何语义X、额外X、known字段错字节或mask覆盖改变立即拒绝。未mask任何wire字节、purpose/content/region/model语义；该受控实验不证明任意X padding行为。

15独立reset初始化sim process按合法case先行：purpose1/content1真实OK；purpose0/2/0x0101；content0/2/255；content保持1而仅target_region byte576变1；七个model块首byte各异或1。每例输入bin/hex、scalar、明确fault、独立expected及来源均冻结SHA。负例有意修改的known semantic bit单独登记为fault，不是修baseline迎合DUT。合法失败立即停；全部15实际case通过才记PASS_SCOPED_RTL_OWNED_BOOTSTRAP_VALIDATOR。static24GiB/1800s/120s，eachRTL8GiB/120s/120s及1Mcycles，父持单重工具。

本agent仅轻量AST、全部输入/掩码/字段对照、case范围、TB结构和HLS05单scalar实际接口拒绝检查；没有HDL compile/RTL/attempt写入。一次只读预检中的临时Python缓存已移除，后续设置dont-write-bytecode。最终输出：`OWNED_BOOTSTRAP_VALIDATOR_PREP_STATIC_PASS Python_AST=1 semantic_bytes=719 model_bytes=416 padding_unknown_bits=392 known_bits_changed=0 cases=15 HLS05_rejected=1 HDL_compile=NOT_RUN RTL=NOT_RUN attempt_writes=0`。两个新文件停止修改；实际命令已回传父：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_owned_bootstrap_validator.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/owned_bootstrap_validator_rtl_01 --program-hls-attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_06
```

## A004 HLS06真实终态后的有界静态映射核验（2026-10-13）

父通知HLS06真实PASS_SCOPED_GENERATION、session32841退出0。A004沿原strict verifier实际只读核8FIFO/220v/dat完整身份，并在真实06上调用新runner nested_interface检查通过。nested模块239639 bytes / SHA `4ca90e5bd6efa119cd0c92bc2ad4dbc4f2ee13af3227efecb7c7e57b965c6929`；validate_2 caller30945 / SHA `54c7b48b8676f93d84d5a93efa8be493638d2428c9961de3e3a5a058c8cfc9bc`。本轮只解析既有IR/RTL，无实验工具或attempt；新动态仍NOT_RUN。

caller state1读ram0，state2捕purpose m_q0[207:192]；state2读ram9，state3捕content m_q0[199:192]；真实fu222实例将两个实际reg传16/8bit scalar，m_q0/q1直接保持两512bit同步RAM连接。callee RTL5142用purpose eq1、5190用content ne1，不再复用region。

HLS06 a.g.0 IR40095–40115完整copy i0..415，源152+i、word右移6、byte低6bits乘8，再store model[i]，七块首全部正确ram2..8 byte24；40127–40149的完整416B canonical equality也保留152+i。真实RTL4461 add152、5216计数416、5232对同步m_q1动态shift、3428 model_d0取byte，保留动态访问。serialize IR36937–36948从152+i写wire160+i，40286–40289正确content600→wire602。decode_1 RTL10612–10618只有validate成功才进入state440–449 encode/完整equality；state450仍须this_code5=0及comparison OK才提交，没有删除完整canonical gate。

所查静态映射无错误，已实际回传父允许按原串行计划先跑合法validator。不能据此声明真实copy/canonical、15case或端到端owner已通过，后续结果分别由父实际工具记录。

## A004 HLS06 owner安装实际执行见证TB补强准备（2026-10-13）

父报告独立validator01 static及合法case实际PASS、15case继续串行；该TB当时只有总start/done/read计数，不能据其return0声称具体子调用已动态观测。父另明确授权只补既有`laya_graph_program_owned_tb_v1.sv`的只读事件观察/加强断言，不改DUT、runner/checker、原四case/gold/刺激/断言，不新HLS、不扩恢复矩阵。已先实际回传真实信号/可执行方案，收到父直接实施通知后完成。

monitor直接内嵌原TB，避免新增include依赖漏冻；绑定当前真实HLS06层级：D=`dut.grp_step_fu_719.grp_decode_1_fu_2579`，V=`D.grp_validate_2_fu_10107.grp_p_anonymous_namespace_validate_fields_fu_222`。从真正OWNER FIFO读握手开启，每个flag只可由对应实际FSM/握手事件置位：

- V真实state1/ap_start核purpose1/content1；state11→state12实际分支见证后续几何成功。
- V state284及model_ce0/model_we0实际写握手，按model_address0连续0..415计数；每个model_d0与独立owner_gold wire[160+i]逐byte相等，末415。初始化model RAM的state11..282及build写入均排除。
- V内`grp_build_l13m_model_binding_fu_5884`真实state1/ap_start与实际done；未制造其不存在的返回port。
- V state287为实际416B canonical xor/accumulate；i_93在前一RAM读edge已加1，故真实index=i_93-1，连续0..415，逐byte核model_q1独立gold及实际xor0。末415作完成见证，不采initial difference0。
- V内`grp_validate_l13m_model_binding_16_fu_5903`真实state1/ap_start及done/实际return0；随后V真实done/return0也必须有前述子调用成功事件。
- D内`grp_p_anonymous_namespace_binding_packet_fu_10128`真实state1/start与done；D state449最后overlay终止条件才是整个handoff encode完成边界，不将checkpoint packet子调用完成单独冒充整个encode完成。
- D state451为实际1024B原packet对encoded packet的xor/accumulate；i_82在读edge已加1，真实index=i_82-1，连续0..1023，逐byte核p_q0独立owner_gold及实际xor0。末1023作完成见证；D实际done/return0还须全1024计数。
- 真正OWNER_ECHO FIFO写握手前必须全部实际start/done/末索引flags和416/416/1024计数齐备；任意索引/byte/event错配立即fatal。没有hierarchy write/force、没有新gold或输出采样延迟。

每个阶段仅一条`FULL_CURRENT_OWNED_OWNER_WITNESS`，含case/cycle/time/index/code和三个真实进度计数；原全四case继续正常测FIRST/depth2/反压/取消/旧completion/最终抽象通知。监控只增加证据与断言，不修改正常业务流程。

补强后TB **22652 bytes / SHA `0331821dd6c38cbd7ce58b76afaf93620f8c6317df9ccf705e255dddc57df4ac`**，替代live准备身份；旧attempt的原14010B TB及其失败不改。轻量检查剥去新增monitor后恢复原TB的SHA精确为`0364c8b9b418925ece5d1a8c4b7997b0f89c98f21bb3c3ba8e730c6f97aff5fe`，原case/刺激/gold/断言逐字未变；46处真实HLS06符号存在、宏配对及计数全覆盖。输出`OWNED_OWNER_EXECUTION_WITNESS_PREP_STATIC_PASS original_TB_restored_SHA=exact real_HLS06_symbol_references=46 expected_counts=416/416/1024 HDL_compile=NOT_RUN RTL=NOT_RUN attempt_writes=0`。符号/结构检查不证明SV可编译或事件已发生。

TB及runner停止修改，真实编译/RTL由父在唯一重工具空闲后执行；命令已实际送达：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned_rtl.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_04 --program-hls-attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_06
```

本agent没有启动工具/attempt；新owner monitor动态事件、完整top04、端到端owner canonical结论仍待父实际测量。父同期executor_hls03的已冻候选不含本TB改动。

## A004 owner monitor空闲done时序修复（2026-10-13）

父实际`graph_program_owned_rtl_04` static PASS，但success在145ns真实OWNER读同边沿触发新增monitor的decode-done断言；原log仅owner_read marker，尚未进入nested。这是A004监控的普通时序错误，04原FAIL及冻结不改，不能记为DUT canonical已失败/已执行。

只读核真实HLS06 `decode_1.v:5315–5319`：`ap_done = state454 || (state1 && ap_start==0)`，所以inactive/idle本来就done1。原monitor在owner读后立刻接受此值，缺少当前decoder调用的实际start见证；不能由idle done推断执行完成。

仅修live owned TB：新增`ow_decode_start`，只由真实D state1且ap_start1边沿置位并记录`owner_decode_start`；nested start要求此见证已经发生；decoder done同时要求当前start已见证及真实state454，空闲done不触发。OWNER_ECHO前显式要求decode_start。完整416copy/416canonical/1024canonical、所有其余子调用事件以及原四case/gold/刺激/断言没有删除或降覆盖；DUT、runner/checker、任何attempt未改。

当前TB **23227 bytes / SHA `0747f15559b915604bddfa67f52d86576351dd7d7ea3bd336addfd0bb30413f1`**，替代上节22652B live准备身份。轻量检查剥monitor后再次精确恢复原TB SHA，49处HLS06实际符号存在、start/terminal-state gate及416/416/1024 echo计数保持；`OWNED_OWNER_MONITOR_START_GATE_STATIC_PASS original_TB_SHA=exact HLS06_symbols=49 coverage=416/416/1024 HDL_compile=NOT_RUN RTL=NOT_RUN attempt_writes=0`。本agent不启动工具，新05仍待父实测。原因、SHA和以下命令已经实际回传父，文件停止修改：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_graph_program_owned_rtl.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05 --program-hls-attempt project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_hls_06
```

## A004 owned program RTL05实际见证核验（2026-10-13）

父串行运行后的原始[receipt.json](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05/receipt.json)实际状态为`PASS_SCOPED_RTL_OWNED_PROGRAM_FIRST`；四个独立reset用例全部PASS，A004只读原log核每例17条`FULL_CURRENT_OWNED_OWNER_WITNESS`，没有改TB/DUT/runner/旧attempt或启动新工具。共同真实执行顺序：copy416末index415在cycle10183、build_l13m_done在11077、canonical416末415在11909、validate_l13m_done在13263、canonical1024末1023在18757、实际owner_echo_write在20816。echo之前实际计数为416/416/1024，nested validator与owner decoder均真实返回0。build module没有返回端口，其done marker的code是-1；这里只记录真实start/done，不将其写成观测到return0。

| 原始用例log | 终态cycles | 实际owner/echo/command/LAP/action/completion/receipt/result | bytes / SHA256 |
| --- | ---: | --- | --- |
| [success](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05/guard_success/driver.log) | 57141 | 1/1/4/1/8/4/4/4 | 4499 / `006b466e214e11e16f467343f446b89c899dcf1443d201e9b84680f182eca59e` |
| [cancel-command-prefix](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05/guard_cancel-command-prefix/driver.log) | 45060 | 1/1/4/0/0/0/0/4 | 4764 / `30797175f2020d875331c67f49c434221cfbefdc563db32646e4a4a7349957d0` |
| [cancel-allocated](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05/guard_cancel-allocated/driver.log) | 57140 | 1/1/4/1/8/4/4/4 | 4669 / `1a0faea33304874708e8f27b3a9aeda885f7b83d578b9b0bd70547d46bc11bb2` |
| [stale-completion](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_rtl_05/guard_stale-completion/driver.log) | 59096 | 1/1/4/1/8/8/4/4 | 4669 / `fba7dada5cbe114693cb73392de4fd9be3c7f02c870a42279e9b682370a6dc56` |

四例真实终态仍为tail2/tail1、waits12、8个depth2 FIFO、FIRST_only，两个replay owner word及两个下一command beat保持。`result_notification=CONTROLLED_ABSTRACT`，receipt明确`CONTROLLED_ABSTRACT_AFTER_ACTUAL_FINAL_FIFO_READ`；actual executor/LN/hub/END、唯一软件退休、完整graph/13BO、CLOSE/rearm、联合资源/物理时序/board未测。RTL04仍保存原monitor时序FAIL；RTL05证明本次scope的实际owner完整copy与canonical执行及FIRST流水，不关闭M003/M004。

## A004 旧LTX collector只读设计映射（2026-10-13）

父任务要求只读梳理D-M003-EXECUTOR-OLD-LTX-CLEANUP-01、LTP1及真实sidecar入口，并给出实现接口/计数/全旧归属检查；本节是设计映射，**未实施/编译/HLS/RTL**。唯一写入为本result，未改DUT/TB/runner/共享source/旧attempt，无下级agent。A002/主控负责共享top和集成，A005只负责指定stream测试/runner，A006只读诊断；后续实时共享代码改变不由本只读快照覆盖。

### 实际入口和现有实现边界

- 合同：[executor_old_ltx_cleanup_contract_20261013.md](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/results/executor_old_ltx_cleanup_contract_20261013.md)。collector收旧候选、允许cleanup尝试、hub真实终态是三个独立事实；有界收集不增加owner/allocator/退休权威。
- 当前真实generated-adapter接线在[laya_executor_adapter_lpv_generated_tb_v1.sv:134](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/laya_executor_adapter_lpv_generated_tb_v1.sv:134)：`ltx_pop=transaction_request_read && transaction_request_empty_n`；当前`txn_start=ltx_pop && ltx_pops%24==0`；`txn_done=ltc_valid && ltc_read && ltc_pops%16==15`。该TB的txn_route=0是该片段受控来源，不能用作实际executor的route1归属证明。
- [sidecar:49](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_executor_adapter_lpv_owner_v1.sv:49)的`txn_start_ready`现无条件要求`!txn_revoked && !cancel && !owner_revoked`。因此真实BEGIN返回后持续撤销时，即便FSM已形成旧END，下一LTX首pop仍被封死。不能靠清撤销、将collector首pop冒作txn_start或重贴live A修复。sidecar start条件需由主控接入**完整已核旧候选**的内部绑定事实；普通入口仍受持久撤销关闭，旧候选中可信普通未外发帧可进入实际adapter产生负完成，END/INVALIDATE才可在撤销下尝试远端。该内部候选事实不是hub许可。
- [F10 shell:49](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_controller_transaction_adapter_shell_v1.sv:49)按真实24次adapter request pop进入`awaiting_completion_consumption`，按真实16次caller completion pop解除；这些规则保留。其第24拍LTX/第16拍LTC是不同边界，不将LTC写进FIFO当作消费。
- 实际pending来源：[Machine::send](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/control/task_lifecycle_fsm.cpp:45)一次保存`m.transaction`、完整`m.request_packet=transaction::encode(request)`及`m.after_transaction`；TX_WRITE只推进beat，24拍写完进入TX_READ，TX_READ/TX_VALIDATE仍保留这些字段。原action完整wire在`actor.port.request_packet`，真实decoded键在`port.machine.action`；真实scope/task/logical_done继续由同一Machine/runtime保存。metadata必须从该原状态供给，即使FIFO已经写入部分/全部24拍，也不要求先pop才能获得记录。END来自真实PRODUCER_RESULT后`build_generated_end`，INVALIDATE来自原CLEANUP owner_event；不能由sidecar/TB反推其语义。
- 本只读快照时`executor_actor.h`、`executor_stream.h/.cpp`、`config/executor_actor_sources.cmake`及`executor_hls.h/.cpp`尚无LTP输出/executor_transaction_pending source注册。接口下述是**拟接线**，不是已存在的硬件端口。实际handoff_portal_shell的managed LPV A/pending输入仍绑0，现有sidecar实例位于上述有限TB，不能把它误报生产top已集成。

### 直接沿用LTP1的完整33拍

[LTP1 header](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/include/laya_executor_transaction_pending.h)确定2112B/16896bit、33×512bit；不是32拍，不可只取header或LTX头。

| LTP拍/字节 | 必须保存并核查的内容 |
| --- | --- |
| beat0 / bytes0..63 | magic0..3=`0x3150544c`、version4..5=1、beats6..7=33、route byte8=0或1、byte9仅HAS_HOLD bit0、10..15全0；session16..23、accepted_request24..31、source_sequence32..39、handoff_epoch40..47；48..63全0 |
| beats1..8 / bytes64..575 | 原完整512B LAX1，8拍全部来自真实Port已接受action，不用新编码的PC/ordinal几个字段替代 |
| beats9..32 / bytes576..2111 | 原完整1536B LTX1，24拍全部来自真实Machine::request_packet，不从scope/short hash重建 |

metadata shape：session/accepted_request非0；has_hold=1时source_sequence/handoff_epoch都非0，并与唯一shell保留的旧K对应；has_hold=0时这两个字段必须都0，并且只能用实际LAD1 A的session/accepted_request，不制造HOLD/S/H。route必须同时等于**实际物理输入来源**和该旧工作已保存的dispatch route；物理executor stream为1，predecessor为0，不能信任metadata自报route。若没有真实predecessor FSM pending接线，route0作为不可授权来源隔离，不能借executor记录替前序授权。

### 拟定RTL接口（沿用真实ap_fifo方向及F10/sidecar名称）

这组端口表示一份旧candidate的缓存与握手，不是新owner表。主控可采用以下命名；所有frame尺寸来自现有协议，输出只接现有F10/sidecar，未创建任何新wire协议。

| 方向 | 端口/位宽 | 真实来源或接点 |
| --- | --- | --- |
| in | `clk,rst_n,cancel,owner_revoked` / 各1 | 唯一旧请求域的持久撤销；live cancel恢复不清旧撤销 |
| in | `installed_owner_valid` / 1，`installed_owner` / 8192 | 现有唯一完整LAD1 slot；直接连接lpv_owner_installed/record，旧引用未消费前不复用 |
| in | `old_has_hold,old_hold_key_valid` / 各1，`old_hold_key` / 8192 | 若有HOLD，直接沿用shell.pending_key的完整K/B；没有HOLD不建立新K |
| in | `old_route,physical_route` / 各1 | 前者是旧dispatch保存事实，后者来自实际选中的物理stream；两个值在candidate存续中不得随live仲裁重选 |
| in/out | `transaction_pending_dout` / 512，`transaction_pending_empty_n` / 1（in），`transaction_pending_read` / 1（out） | 真实FSM新的LTP1输出通道；dout只在真实read&&empty_n edge计数，33拍完整捕获 |
| in/out | `source_transaction_request_dout` / 512，`source_transaction_request_empty_n` / 1（in），`source_transaction_request_read` / 1（out） | 原真实executor或前序24拍LTX FIFO，选源锁定于该candidate；不能接TB重建的请求来签实际executor链 |
| out/in | `transaction_request_dout` / 512，`transaction_request_empty_n` / 1（out），`transaction_request_read` / 1（in） | 原F10接口：只有完整metadata及全部24拍比较成功后提供immutable已收原帧 |
| in | `txn_start_ready` / 1 | sidecar对该完整旧candidate的start互锁；现ready规则需主控修改到合同要求，不能由collector绕过 |
| out | `txn_start,txn_done` / 各1 | 分别只由F10第1次request pop、原caller第16次LTC pop产生，保持现sidecar语义 |
| in | `transaction_completion_consumer_read,transaction_completion_consumer_empty_n` / 各1 | 原16拍LTC FIFO的真实caller握手；返回仍走同一通道，不在collector生成LTC |
| out | `candidate_owned,candidate_verified,candidate_revoked,candidate_route` / 各1，`candidate_owner` / 8192 | 只引用/回显已锁定原A/route；verified表示完整transport比较成功，不表示hub已许可或terminal |
| out | `candidate_remote_cleanup` / 1，`protocol_error` / 1 | 前者仅精确END/INVALIDATE类型分类；错误归属/坏帧隔离，不制作可信拒绝 |
| out | `metadata_captured` / 6，`ltx_captured` / 5，`adapter_request_consumed` / 5，`ltc_consumed` / 5 | 分别完整范围0..33、0..24、0..24、0..16，不共享beat变量 |

若顶层两个物理source共用mux，mux在首metadata pop前已选定old_route，并在candidate/adapter/LTC全生命周期保持；另一路ready/read全0。正常未撤销HOLD DRAIN仍准许该已接受action的合法后续事务，各kind照原合同；新action由旧shell/Port入口关闭。不能把HOLD DRAIN一律限制成END/INVALIDATE。

LTP的8192bit旧K输入是唯一shell已有记录的引用接口，不增加第二个K权威。可以在candidate中保存原bytes用于稳定性检查，也可以引用不会复用的唯一slot；只传4个key scalar时，上层仍须保留完整K/B及其原codec/full-key校验，不能将4-word相等宣称完整B/S/H相等。

### 单candidate状态与各自真实计数

推荐有限状态为`EMPTY → META_33 → CHECK_META → LTX_24 → CHECK_FULL → ADAPTER_24 → LTC_16 → EMPTY`，错误进入`ISOLATED`且保留旧诊断；这仅是实现映射，不新增协议。可保留一个2112B LTP snapshot和一个1536B实际收集LTX view，总计3648B，均属于**同一candidate**；或主控在全帧等价证明后复用同一storage。不同view不代表可并行拥有两笔事务。A/K引用和侧car原A/route不以暂时idle释放。

| 实际event | 前置/计数规则 | 禁止的替代事件 |
| --- | --- | --- |
| metadata首pop | 唯一旧A/K/物理route已知、无candidate、无残留旧返回、无protocol error；捕获完整旧引用并置candidate_owned，count0→1 | live valid/空闲/短cleanup bool |
| 第33次metadata pop | 原count32边沿采beat32后成为33；所有校验须包含该拍当前dout，不能检查旧RAM值遗漏尾拍 | 只收header、32拍或仅has_hold/route字段 |
| collector首LTX pop | 完整33拍metadata已核旧引用，真实pending snapshot存在；count0→1，**与adapter首pop分开** | sidecar.txn_start、F10 request counter |
| 第24次collector LTX pop | 原count23，逐512bit等于LTP beat9+index；sticky mismatch覆盖全部24×64B，包括保留位、seq/origin/descriptor/geometry/model；count→24 | 只看类型/序号/首拍或短hash |
| adapter首LTX pop | candidate_verified且sidecar.txn_start_ready；真实`transaction_request_read && transaction_request_empty_n && adapter_count==0`产生txn_start，同时侧car锁原A/route | collector已经读取了一拍/metadata完成 |
| 第24次adapter LTX pop | 原adapter_count23，同一immutable收集帧送完，F10原awaiting_completion_consumption成立 | collector计数24 |
| 外部首VALID呈现 | 记录实际adapter选中compute/provenance/producer写VALID，即使full_n=0也已呈现；accepted另计VALID&&full_n | accepted_beats=0、write_nb失败、portal未收到 |
| 第16次LTC caller pop | `consumer_read && consumer_empty_n && ltc_count==15`；txn_done一次，candidate与sidecar各按同笔真实边界结束；全A/K request域仍保留 | LTC write16、LPV write16、LPA read8、FIFO临时empty/adapter idle |

计数到完整上界后均停止该入口，下一帧/额外beat仍留在原FIFO，不丢弃、不reset/clear。持续取消/live key恢复或变化不能重选source、重贴A或重置counter。主控实际LTP producer应在Machine第一次LTX write前锁snapshot或同次原子锁定，随后即使TX_WRITE被depth2反压、已转TX_READ也能独立送完33拍；不能设置“先LTX pop才能形成metadata”的循环依赖。结束一笔只在真实16拍消费后释放candidate；同一原action的下一真实pending可再收集，但持久撤销仍关闭普通新工作。

### 旧A/K/route与全body必须实现的比较

1. A是唯一slot的完整1024B LAD1，不只identity。可复用现有`admission_record_ok`，其真实实现已经核magic/version/beats/known flags、13-role mask、非0 session/request、所有reserved、NumericIdentity完整84B、完整416B L13M结构/canonical/tags及13×24B物理mapping（known项epoch/address/capacity非0、64B对齐、加法不溢出；unknown项全0）。该函数位于[generated layout:239](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/rtl/laya_generated_provenance_layout_v1.sv:239)。完整A已锁；candidate_owner与installed_owner比较全部8192bit。live物理base改变只持久撤销，不改旧mapping；旧物理安全/lease/scope最终仍由hub/monitor核定。
2. LTP session16/accepted24与A同offset64bit完全相等；有HOLD时LTP source_sequence32与旧K的LHC1 sequence16、LTP handoff40与旧K handoff680相等，旧K session776/request784与旧A相等，完整K/B及其numeric/model/base均来自旧shell通过原full-key/codec保存事实。完整旧K/slot不复用的条件须贯穿LTC消费。没有HOLD则has_hold0、S/H0，使用实际A，不把全0 K描述成合法HOLD。
3. LTP route byte8≤1且等于physical_route/old_route。选择通过实际输入接线证明，不能自报。旧candidate记录和真实LTX来源为同一physical source；predecessor的工作需要自己的原FSM记录。
4. LTP action identity位于`(64+64)*8`的672bit，与旧A identity的672bit完全相等；LTP LTX identity位于`(576+64)*8`的672bit同样与旧A相等；LTP LTX model位于`(576+160)*8`的3328bit，与旧A全416B完全相等。header所有reserved/known enum/flags按原codec校验。不能拿模型tag代替全model，也不能只比较request_id/generation。
5. LAX必须是原完整8拍，原action的kind/PC/op/stage/layer/flags/ordinal/source/target/parameter及所有reserved都匹配真实Port已经接受的canonical action packet。真实来源只允许`Port::request_packet`/同一`Machine::action`的既有codec闭包；若跨分区引用实际pending用LTP全8拍保存。LAX本来没有K/route/model，LTX本来没有action ordinal/PC，不能添加不存在的跨wire关联。该两者的完整绑定由**同一真实Machine snapshot**建立，若输入LTP来源仍是受控测试，则不得升级为实际executor来源。
6. 每一collector LTX beat逐512bit与LTP中原pending beat9..32相等；最后一拍也参与sticky mismatch。这样seq/generation、origin、Context、全部descriptor/ref/model/expected/report/issued/geometry及所有reserved都与真实保存的待发请求一致。任何不同都隔离，不能用部分字段构造LOCAL_REJECT。仅元数据正确不能替代body的canonical/semantic validation。
7. 完整LTX合法性沿原codec：header bytes12..15、36..63全0，kind1..3，flags byte32..35无CANCEL_CLEANUP外位，protocol/seq/origin与kind-selected字段一致。compute reserved666..667、687、948..951、976..1535及6个Ref的padding；provenance reserved581..583、604..607、712..751、840..879、923..943、987..1007、1008..1535及两个descriptor Ref的padding；producer reserved598..599、602..603、664..1535及两个Ref padding均保持。full canonical还需`encode(decoded)==original`，例如unused descriptor/geometry槽不能仅因decode忽略就放行。每kind的实际command_fields_valid/request_fields_valid仍必须执行或沿同一真实可信canonical snapshot证明；已有metadata encode自身不证明这些语义。
8. 撤销下remote type恰为LTX kind16bit=2、flags32bit=1、protocol16bit=3(END)或6(INVALIDATE)，不会改原flags/kind/seq。这个predicate只分类尝试；END与原BEGIN/origin/Context、全model/descriptor/expected/geometry及真实producer完成或可信未外发local-reject匹配，INVALIDATE与原旧action target/Ref/model/descriptor匹配，最终许可/terminal由唯一hub执行。无RELEASE(5)/CLAIM(1)/BEGIN(2)/PUBLISH(4)/新COMPUTE/PRODUCER远端放行。正常未撤销旧action流程不套此白名单。

### SEQUENCER_CODEC的明确实现责任

`executor_transaction_pending.cpp:58..130`所有full APIs都受`#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC`保护：`validate/capture/decode/same_record/managed_cleanup_candidate`在FIRST codec构建中没有定义。`controller_transaction_codec.cpp:292..409`的完整body getters/validators、`:508..530`的RequestPacket decode亦不可用。能直接调用的仅LTP metadata shape/same_key/encode和既有transaction::encode；它们不解body、不证明canonical、不确认scope/origin/许可。

因此FIRST top不能在LTP输出准备中调用这些未定义full APIs，也不能将metadata-only检查标记成full validate PASS。落实方式有两个现有边界可选，由主控决定实际分区与冻结：

- 实际executor producer沿真实已保存action/request packet输出LTP，先在源侧锁住A/K/route/snapshot，不拉入被剔除的三外协议decoder；collector RTL完成完整header/reserved/A/K/route/identity/model/24-beat原snapshot比较。完整LAX原codec/canonical来源和完整LTX canonical形成必须在真实producer既有形成路径有依据；若要在collector独立核任意LTP body，则需要完整对应RTL比较/字段校验，不能只有白名单比较。
- 保留真实adapter分区的现有full `transaction::decode`，在任何外部呈现或可信LOCAL_REJECT之前执行完整原field validators及所需canonical equality；它与collector的全frame/旧owner/snapshot比较共同构成前述验证。不能让FIRST producer在SEQ_CODEC模式跨调用full decode，也不能让metadata-only的collector替代adapter的原parse。若canonical equality不在原decode内（当前原Request decode确无encode equality），明确在这个full decoder可用边界补足，或由被实际核验的原canonical snapshot闭包证明，不能默称已有。

严格host full `pending::decode(packet,owner,expectedRecord,out)`已经表达目标：先验证retained expected，验证完整packet，再`same_record`逐完整LAX512B+LTX1536B比较。它是测试/合同参照，不是当前FIRST硬件已执行的调用。

读到的共享adapter现已有主控managed宏候选：`LAYA_MANAGED_TRANSACTION_ADAPTER=1`排除legacy cleanup RELEASE并跨READ/PREPARE/SEND观察transaction_cancelled，`external_presented`在第一次write尝试前置位。该候选尚需对应新生成/实际接口行为见证；本只读报告不替主控签动态PASS。默认legacy仍允许RELEASE，不可用默认生成物宣称已收窄managed权限。

### 真实负完成与受影响验收映射

已完整绑定的普通旧候选，若确实尚未任何外部VALID呈现，collector应送原24拍给实际adapter并传该旧A的持久revocation；由`PREPARE`/首外部呈现前的原`reject_internal → make_local_reject/encode`产生唯一1024B/16拍LTC。flags恰`FRAME_COMPLETE | LOCAL_REJECT = 0x41`，非OK原首错，不置BINDING_OK/REMOTE_DRAINED/SCOPE_ACTIVE/TERMINAL/PUBLISHED。collector不生成第二份completion，也不把负完成当远端terminal/已排空。若任意beat已VALID呈现（即使accepted0）或接受，则保留旧帧及真实返回；不能撤VALID改LOCAL_REJECT。

同一caller真实16次读取后才结束该candidate；actor原PRODUCER_RESULT可由完整local-reject形成错误END并继续hub清理，只有其真实END终态经原路径才能typed退休。CLAIM/BEGIN/OWNER等未实现local收束路径可按合同隔离保留，不能泛化LOCAL_REJECT为remote_terminal。bad A/route/未知pending/body mismatch一律隔离且保持原bytes，无可信LTC。

主控/A005后续有限case应分别看到：真实BEGIN完整LTC后持续撤销，END在尚无LTX首pop时已真实记录并33+24+24+16完整握手；CLAIM-only真实INVALIDATE无虚构退休；producer待发未呈现→实际adapter0x41负完成→原错误END；错A/route/K/完整body及RELEASE/伪cleanup全部不获新业务许可；取消跨metadata/collector/adapter首pop及外部首VALID、半帧、LPV/LPA/LTC尾2/尾1反压都不丢帧、不提前释放、不双发。producer最后B/fence和F10通道排空继续分开，END不得等待自身返回所依赖的F10空闲。若LTP producer仍受控，明确签片段scope，不签同runtime C整链。

只读源身份（可能随后由主控合法改变）：LTP header2705B SHA `a43a2c05d7e9a31015ba22737ca3d9328a02c1cdc7ceaabb5664f6506522d852`；LTP implementation6122B SHA `5d6b04fee938855d6443ac3be45ce8b27f8cb0ebdc5d11e21fdc884665115669`；sidecar6219B SHA `8151a340a19cb40911880694455546095c47e6f3a6804390a2294f5f604e1eee`；真实generated-adapter TB31456B SHA `9e809e763f2b5e221a2761051650c23cbbfb6929420a7d761c1a27839d9418fe`；transaction codec40482B SHA `3bef111c7913e68ac0726e59caba40dc632f5247f007add9c8eaf07d23728de2`；managed adapter live候选23563B SHA `31ae50be63eb4ec2ffdb7945172f390010ac11d1344bf858ac8035ea0927b090`。本节仅静态映射，不增加预算/新attempt，不关闭M003/M004。

### 主控补充要求后的最小信任边界收紧

主控明确要求LTP来自唯一真实FSM出口、header/A/K/route与实际旧bound action匹配，不能把encode当FULL decoder。为使上述接口最小而来源可实施，优先在实际LTP producer内复用**现有真实program LAP consumer**，在形成/锁定LTP前做原512B action相等；不增加新owner/许可/退休表。

实际LAP consumer是[executor_hls.cpp:221](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/control/executor_hls.cpp:221)，现硬件边界为`hls::stream<ap_uint<8192>>& program_pending`，一次真实read_nb接收完整1024B LAP1，不把它误算成16次该宽口读取。它实际调用`program_pending::decode`、完整Key比较及`program_wire::encode(decoded.command)==actor.command_packet`，并要求重复packet全1024B不变，再存`Transport::program_pending`与valid。LAP原512B action位于bytes512..1023。

最小源侧形成规则：真实LAP consumer已核整packet的存储仍有效，`actor.port.request_packet`全512B逐字等于其中原LAX body，且既有真实Port已完成action decode/start，`action::encode(port.machine.action)`同原wire闭包；随后只从**同一Machine**的真实`transaction/request_packet/after_transaction`锁LTP，逐完整A/K/route与旧slot比较。该比较可以使用SEQ_CODEC仍可用的action codec及packet equality；对LTX则只复制原FSM packet，不假装调用不存在full pending::capture/decode。LTP在源侧锁住后通过33拍送出，collector逐完整header/A/K/route、全部LAX及24拍原LTX精确核对。正常旧action已开始后的每个后续pending都复用同一完整action，取消不分配另一ordinal。

若主控选择让collector在RTL独立核LAX，则在上面接口增加仅一对`expected_action_valid`/1与`expected_action_packet`/4096（in），必需由上述**实际LAP consumer通过完整验证后保存的LAX**导出，比较`LTP[64*8+:4096]==expected_action_packet`全部4096bit。当前wrapper只有完整8192bit `program_pending`输入，尚无这个已核action的export端口；需由主控实现实际consumer出口/稳定性接线。不能接live bool、常量NORM/PC0、TB重建gold、未验证LAP prefix或仅ordinal。若采用源侧完整等价检查，collector可省这两个额外宽口，但验收必须观测真实形成调用及full512B比较来源，不能把源侧假设写成已测。

完整LTX codec交实际managed adapter执行时，collector的`candidate_verified`仅表示旧绑定及transport字节相等，full syntax/semantic/canonical仍需在adapter实际parse boundary成功；这之前既不外发，也不产生可信负完成。这里还有一个明确现wrapper源码缺口：[adapter PREPARE:466](/home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/hls/platform/controller_transaction_adapter.cpp:466)仍将`!parsed`与“完整合法但撤销普通事务”合并调用`reject_internal(request,parsed)`。即使原legacy允许输出一个随后会被caller拒绝的frame，managed合同要求坏/不可信帧隔离保留，不能以部分或默认Request制作可信LOCAL_REJECT。因此主控须在managed模式分开两条出口：full parse/canonical失败→隔离，不发可信LTC；full parse成功且精确旧绑定、never-presented撤销普通事务→原reject_internal生成唯一0x41、实际16拍LTC消费。不能只因后续caller可能拒绝而将前者记成安全负完成PASS。

本补充只记录可实施最小源侧检查、可选exact expected_action宽口的真实来源和现source/端口缺口，未引入新的协议字段或新权威，未修改代码/测试/runner，未启动工具。


## A004 单候选transaction collector实施准备（2026-10-13）

收到父明确工程授权后，仅新增M/rtl内`laya_executor_transaction_collector_v1.sv`、M/tb内同名有限TB和`run_executor_transaction_collector.py`，并追加本result。知道其他agent同时修改共享代码，未回退/改动sidecar、F10、shared top/layout/codec、旧TB/runner/attempt；无下级agent，无HDL编译/HLS/RTL，无新attempt写入。主控负责真实FSM exporter/LAP expected_action export及后继shared集成，A006负责managed adapter坏帧隔离，A005负责managed HLS准备。

单candidate的输入为实际ap_fifo 33×512bit LTP；首次真实metadata pop锁完整8192bit旧A、已有8192bit旧K引用、4096bit实际expected_action、has_hold与物理route。initial A复用现有`admission_record_ok`全部LAD1/model/13-role映射检查；旧K为唯一shell已有完整验证记录，模块检查LHC1头、旧session/request/source sequence/handoff、全部84B identity/416B model和源BO对应physical epoch/address/capacity。**K内role wire offset是604=576+28**，已逐字核实际bootstrap serializer及GRANTED literal，未用602的content或Message ABI offset。其full codec/full-key valid来源仍要求实际旧shell；不能让live bool代签来源。

全部33拍后检查LTP magic/version/beats、route、HAS_HOLD精确字节、全部header reserved、完整A/K索引、完整512B action与expected_action逐字相等、LTX完整84B identity及416B model与旧A相等；无HOLD时S/H均0。此后真实24拍source LTX全部收齐，与LTP中的原1536B request逐512bit比较，包括seq/origin/context/descriptor/geometry/report/issued/所有字节与尾拍；任意不同隔离，无adapter输出/无LTC合成。仅比较通过才在原adapter ap_fifo接口稳定呈现**实际收集**的完整24拍原帧，实际adapter首pop与collector首source pop独立计数/脉冲；`txn_start`只等于adapter首pop，`txn_done`只等于原LTC caller真实第16次pop。candidate在这16次真实读取之前不释放；LPV/LPA写读、adapter idle、16个return写入FIFO均不替代消费。

输出FIFO的当前word在反压/撤销/live A/K/action/old_route变动及live恢复下不撤回/改字节；旧candidate A/route/action/K保持已锁版本。真正physical source route改变则隔离，不能混源。撤销从首candidate前cancel开始也不封死匹配旧pending的收集；内部持久candidate_revoked OR保存到后续同旧A匹配重试，txn_done不清它。EMPTY仅释放candidate传输占用，保留字节/计数/撤销用于诊断；reset仅各case初始化，不在活动case清FIFO。没有cleanup whitelist许可端口，普通compute/provenance/producer及RELEASE也可完整收集供实际adapter处理，collector不以类别授权远端业务。

`candidate_verified`只签transport全帧比较；全部LTX syntax/reserved/semantic/canonical decode仍留在实际managed adapter full parser，精确END/INVALIDATE准入及scope/physical/terminal留唯一hub。新RTL不调用SEQ_CODEC下不存在的full decoder，不创建LOCAL_REJECT、owner表、分配/发布/退休。主控集成必须将F10真实首次pop与sidecar旧candidate ready作原互锁，不能把collector首pop接成sidecar.txn_start；新模块本身没有以live start权限撤回已呈现FIFO valid。

有限TB：33个独立reset case，真实metadata/source/opaque LTC各一个depth2 FIFO，所有counter对独立实际read&&empty_n观察计数。11个完整case覆盖END/INVALIDATE的cleanup/ordinary、legacy RELEASE/CLAIM/BEGIN/PUBLISH、compute、producer、无HOLD route0；匹配普通帧通过仅证明收集，绝非其远端许可。END cleanup case在持续cancel下从真实metadata首pop开始完成33/24/24/16，再恢复live cancel且无reset/clear，以同旧A同原LTX的下一真实candidate重复全握手，要求started2/released2、persistent_revoked1。全部完整case在metadata尾33前2/1拍、source LTX尾24前2/1拍、adapter输出尾2/1、实际LTC FIFO占用2/1各保持12cycles，partial前缀无输出，adapter暂时idle或return写完不得提前结束；live恢复不清撤销。

22个隔离case覆盖坏A reserved/错A session、错K sequence/handoff/全model尾、错实际物理route、foreign完整action ordinal、LTP magic/version/beats/route/HAS_HOLD未知bit/全部header保留区代表字节、LAX保留位/尾、LTX identity尾/model尾，以及source完整帧的seq/payload/1535尾byte不等原snapshot、无HOLD伪造S。未知归属/坏frame保留隔离，无fake可信LTC、无自动恢复；负例不把有意fault当允许的mask。未额外添加实际hub/F10/adapter功能到本片段。

运行器严格依赖已完成原`executor_transaction_pending_host_01` PASS_SCOPED_HOST（receipt SHA `60d2d241cc5ccd1b0b293e7075cf82ded41e0b17e4385daa9a435a4146751e4a`），核11个actual-full-codec vs独立literal的完整2112B oracle及manifest/source身份，冻结全部原LTP/LTX/action/A、原literal generator和实际full codec test；另核`graph_program_owned_host_04`的原host_success/oracle/manifest，冻结完整GRANTED `control_4.bin`与完整LAP `pending.bin`，确保其中LAX全512B等于host01原action、K/A numeric/model/base和四word Key全一致。expected_action来源因此是**已有完整LAP的离线literal受控peer**，不是新常量NORM、prefix或live bool；生产实际LAP consumer export端口当前未接，本TB不签它已实际接通。

runner生成byte-preserving 512bit hex，保存原bytes的SHA及完整来源；实际RTL通过后另逐1536B比较11个actual adapter-pop capture与各原独立LTX literal。opaque controlled LTC words为确定的16×512bit peer，全部FIFO实际caller读取逐字核，但**无LTC格式/可信LOCAL_REJECT/真实adapter返回语义**结论。所有FSM/A/K/LAP/F10/sidecar/adapter peer均受控；route0是受控无HOLD前序源，未接真实predecessor pending；不签same-runtime C、hub cleanup成功/terminal、typed退休、CLOSED/rearm、资源/时序/board。按合同后续真实组合验证由主控执行。

准备文件身份：

| 新文件（M相对路径） | bytes | SHA256 |
| --- | ---: | --- |
| `rtl/laya_executor_transaction_collector_v1.sv` | 10494 | `dd56a5cb8995aae0a39d7c79a0fd45ad1a1a1093ec8d848e3390538fcca20619` |
| `tb/laya_executor_transaction_collector_tb_v1.sv` | 17896 | `4733b61e5d2fbe7b91d111c1bfe07eeb503cd3d3c431eeb29c32103ed947455e` |
| `tb/run_executor_transaction_collector.py` | 22614 | `6a51752e56563212548c0c19a79a983954bf770b7de34dfbb8d63528fea9074c` |

A004只做Python AST/无bytecode动态定义装入、完整11组literal/A/K/LAP逐字关联、hex roundtrip、原host01 receipt SHA、33case名单/真实FIFO/计数与持久retry静态结构检查；输出`COLLECTOR_PREP_STATIC_PASS Python_AST=1 literal_LTP_records=11 full_LAX_bytes=512 LTX_bytes=1536 old_K_bytes=1024 independent_hex_roundtrip=exact cases=33 controlled_matching_retry=1 original_host01_receipt_SHA=exact HDL_compile=NOT_RUN RTL=NOT_RUN HLS=NOT_RUN attempt_writes=0`。不能用这个静态结果宣称SV可编译/事件已发生。文件停止修改，单重工具父串行执行，原8GiB/120s/120s、CPU0–3/nice19/idle I/O/MemAvailable>192GiB、maxThreads4、40k global/1500case cycle cap不增预算。

完整建议命令（repo root，父在唯一工具空闲时执行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_transaction_collector.py --attempt project/E003_production_chain_closure/experiment_results/runs/R003/executor_transaction_collector_rtl_01 --pending-host project/E003_production_chain_closure/experiment_results/runs/R003/executor_transaction_pending_host_01 --program-host project/E003_production_chain_closure/experiment_results/runs/R003/graph_program_owned_host_04
```

也支持`--prepare-only`，但它会建立新PREPARED_NOT_RUN attempt，不能随后把同一已存在目录覆写为run；主控若先准备应使用不同全新attempt。A004没有调用该入口/建立attempt。M003/M004未完成。
