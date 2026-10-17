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
