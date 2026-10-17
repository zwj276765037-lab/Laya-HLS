# A005 executor stream host 测试交付

状态：实现候选交付；Python AST及尾随空白轻量检查PASS；编译、host执行、CSim/HLS、RTL与物理层均NOT_RUN。
日期：2026-10-13。父A002为唯一实现整合owner；本任务无后代、无重工具执行。

## 独占文件与身份

- `project/E002_Laya_HLS/experiment/tests/executor_stream_test.cpp`：531行，SHA256 `90601317db46d2644aaeaacc2ac0c0e1857f6eab38253dfd23c4edf845a8f0d7`。
- `project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_stream_host.py`：300行，SHA256 `53101444a1beae7e458f02aadebf8bdf34306718be351d7e52b8b0b5ac901a83`。
- 本报告。未写共享源码、header、config、catalog或索引；未回退他人改动。

## 测试覆盖意图（尚未执行）

真实LYRQ payload及选定模型LYMP头走bootstrap/actor准入，完整LAD1 A与独立literal比对；FIRST仅准入一次。HOLD、IMPORT、CLOSE均由真实16拍下游consumer逐拍读、完整codec校验，再以原包16拍echo建立消费事实。控制request读尾2/尾1、echo尾2/尾1、response收集尾2/尾1均各等待12步。响应先到、请求receipt先到分别覆盖；独立通道反压时不靠FIFO write或抽象bool授权。

完整LBS2请求真实消费并与literal比对；完整LBR2独立literal经实际actor codec/helper导入，尾2/尾1各等待12步。IMPORT/GRANT前零command/action/事务/业务统计；完整匹配GRANT及actor校验计数才形成正常accepted响应事实。错误/旧/错完整K GRANT、重复GRANT、过早/外来/重复control receipt均拒绝。

两种持续撤销GRANT交错：旧完整GRANT先到再IMPORT receipt；IMPORT实际receipt先到、actor已经WAIT_ABORT，旧GRANT后到。后一分支严格匹配已保存实际IMPORT；错K与重复旧GRANT为false，正确旧GRANT仅计一次`revoked_grant_receipts`、零启动。CLOSED没有此fallback。坏响应头、未知kind、保留字节及GRANTED错commit产生原始全包、稳定`accepted=false`通知并保持sticky撤销；不释放锁、不声明自动恢复。

一个真实C++ program/port/FSM/transaction adapter成功路径完成四个诊断NORM窗口。producer/provenance终态由受控软件peer提供。program实际ACCEPT_COMPLETION及完整LAC1 codec接受后生成原始四拍echo；尾2/尾1各等待12步，live legacy completion bool不能提前释放port。一个旧LGP1实际首拍外发后撤销的分支继续真实完整command消费，由program产生绑定LOCAL_REJECT错误结果，零任务退休/producer事务。

成功与错误结果各由真实Host四拍consumer完整读/codec后echo，Host读尾2/尾1及echo尾2/尾1各等待12步。未读尾拍、仅抽象bool、过早/外来/重复Host receipt均不给CLOSE资格。成功与错误CLOSE完整消费后，各测试11个早到/完整K/commit/终态/kind错CLOSED，全部`accepted=false`且零释放。正确CLOSED在持续cancel及live输入变化下完整接受，whole receipt字节和accepted保持至实际完整consumer握手；仅释放一次，重复CLOSED拒绝，第二实际LYRQ候选仍不能重新准入。旧runtime及下界保持。

## runner 与冻结证据

默认使用现24 production源，加6个实际program/adapter integration源；严格拒绝混入共享全控制器和adapter源。可用`--first-only`添加`LAYA_EXECUTOR_FIRST_REQUEST`，同一有限FIRST测试覆盖父新增的初始runtime分支；默认模式保持旧actor source兼容。

31个`-MM`单元在独立production_guard中串行提取闭包，保存逐单元原始dependency/stdout、stderr、命令及退出码。随后冻结完整项目内依赖、source list、选定模型header/manifest/aux、独立fixture脚本、schema/layout、8份原权威合同、runner、guard及helper。每项保留original/frozen SHA/字节数，复制期间身份变化拒绝。oracle/build/run各自串行guard，保存所有guard原始文件、manifest、逐阶段receipt和fixture身份；每次attempt要求新目录，禁止覆盖历史。

启动入口自行核CPU0–3、nice19、idle I/O及MemAvailable严格大于192GiB。dependency/oracle/build/run均24GiB/1800s/120s真实进展guard；本子任务未启动任何入口。建议父在R003新attempt中运行runner `--first-only`，受影响失败仍保留原attempt并在新attempt重试。

## 已做检查与限制

轻量`ast.parse`检查runner通过；两个交付文件无尾随空白。未运行编译、链接、fixture生成、host binary、CSim、HLS或RTL，不据静态实现写功能PASS。工作区无Git仓库，因此未将Git diff检查记为通过。

这些测试使用unbounded host `hls::stream`，shell回复/保护fence/session/base及producer/provenance终态仍受控。未验证物理depth2、真实shell/source保护、同硬件runtime hub/monitor/AXI收束、LN数值、生成executor、完整模型/graph、完整错误矩阵、无LGP本地错误出口、实际安全CLOSE、硬件rearm/第二请求、资源/时序或板端。若测试停在有意保留旧隔离/查询/ABORT队列的用例，不把它写成全流排空或完整错误请求恢复。首请求基线的适用范围遵循D-M003-FIRST-HARDWARE-BASELINE-01，完整M003/M004未由本交付完成。

## 2026-10-13追加：实际shell有限RTL control transport候选交付

状态：已修正accepted-lane真实握手语义，四文件候选可冻结。仅Python AST、Tcl `info complete`、SV词法token/定界符平衡、46个transport端口名存在及尾随空白检查PASS；本子任务未执行编译、oracle、RTL仿真、HLS或任何重工具。功能结果仍为NOT_RUN，由父A002串行guard执行并维护共享实验摘要。先前host文件已归父所有，本次未再改动。

新增文件均在`project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/`：

| 文件 | 行数 | SHA256 |
| --- | ---: | --- |
| `rtl/laya_executor_control_transport_v1.sv` | 179 | `a76ada88e673d249335021bf8ef94a73bf6c45c09ca1839fc59c7ff71c5c51af` |
| `tb/laya_executor_control_transport_tb_v1.sv` | 336 | `5e3ffb52e1d4f4265a64dd07e598987e3bc5fdaa5a6f0a07f8e6be3e817929f9` |
| `tb/run_executor_control_transport.tcl` | 22 | `5874e34670940ce778eb7783ab151a4132f9103b3cdd2f21795542e9156165c3` |
| `tb/run_executor_control_transport_rtl.py` | 175 | `64ab39ca26a53917541448a35b71757d0ffd0ce3b4887b694e62667439acb2bf` |

transport连接标准executor `ap_fifo`控制端口与原真实`laya_executor_handoff_shell_v1`。复用原`laya_private_fifo2_v1`形成request入口、request原包echo、response三个实际depth2 FIFO。request只有实际收齐16拍才发布8192位shell control，只有shell完整consumer握手后才产生原16拍echo，并等echo全部实际读完/空队列后开放下一request。cancel仅形成sticky诊断，不清除或门控旧半帧、ABORT/CLOSE清理通路。

response保存原8192位packet，16次FIFO write与16次实际read分开计数；原shell response需持续present且全包稳定，FIFO完全读空后，完整accepted packet才能匹配。HLS把accepted-lane `write_nb`成功当作实际shell acknowledgement，因此`control_response_receipt_full_n = rst_n && accepted_response_match`，shell pop等于实际accepted fire。过早、错完整K、错commit与重复accepted尝试都必须`full_n=0`、无fire、所有receipt/pop计数不变；保留`invalid_accepted_receipts`作为恒零不变量。仅独立rejection lane无条件bounded消费通知并计数，绝不pop或释放。完整匹配CLOSED fire同时提供原managed shell的原完整closed-consumer record。source中途撤回/改包保留旧字节及transport状态，置sticky错误并阻止错误shell pop。

TB保持三种reset隔开的有限诊断；旧cancel清理内不reset：

1. HOLD前14拍、尾2/尾1各等待12步，持续cancel下完成实际16拍shell拒绝consume及原16拍echo；零伪成功response/锁。
2. 实际HOLD→HELD，受控predecessor/drain/physical facts；受控query完整16拍实际pop后实际IMPORT→GRANT。response未读、只读14/15拍、错K、matching rejection、重复accepted均检查；只有完整匹配accepted实际fire授权一次。
3. F18原GRANT pending时完整committed ABORT待shell消费。持续cancel下原GRANT字节不变，完整旧response drain/accepted fire后ABORT进ISOLATED，零新增authority/grants；受控terminal/work/Host事实后实际CLOSE→CLOSED。错commit、matching rejection和live session/request/base变化不能pop；原完整accepted CLOSED仅释放一次，重复receipt/replay HOLD不重开旧shell。

TB新增monitor要求accepted `full_n`本身蕴含原响应active、未变异、持续present、全部8192位相等、16次write+16次实际read及空FIFO；counter只计真实fire。实际pop响应按独立literal逐字节比对，保存`actual_held_case1.hex`、`actual_held_case2.hex`、`actual_success_grant.hex`、`actual_revoked_grant.hex`、`actual_closed_error.hex`。5000 cycle cap；候选最终marker为`FULL_CURRENT_EXECUTOR_CONTROL_TRANSPORT_RTL_PASS`，但本子任务未产生该执行marker。

### 冻结入口与资源边界

runner要求新`--attempt`目录和verified prior `--helper-attempt`，核helper-only host PASS及helper marker，并核9份helper/独立gold fixture SHA与原receipt记录。此前只读核查确认R003中的`executor_handoff_shell_helper_host_01`及`executor_handoff_shell_helper_host_02`均满足9份fixture身份；父可使用`_02`。runner冻结helper原packet、helper manifest/receipt、新四文件、原shell/layout/FIFO2、原oracle、guard/helper、runner依赖、当前HLS/stream接口参考及四份合同，逐项保存原/冻结身份并拒绝复制中变化。

oracle与RTL分别走独立guard；CPU0–3、nice19、idle I/O、MemAvailable严格大于192GiB；每阶段8GiB RSS、120s wall、120s semantic stall，单重工具串行。保留所有原guard文件、manifest/receipt、Vivado log/journal和实际response capture身份。Tcl只建立行为仿真，四份RTL为原layout、FIFO2、shell及新transport，part为`xcu55c-fsvh2892-2L-e`，maxThreads=4。

父串行执行形状（此处仅文档，不曾运行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_control_transport_rtl.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_control_transport_rtl_01 \
  --helper-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_handoff_shell_helper_host_02
```

该候选范围是offline actual C++ helper控制stimuli、真实原shell、实际有限depth2 FIFO与TB full-byte oracle consumer；predecessor/safety/protection、query response/consumer pulses、terminal/work/Host事实仍受控。生成executor同runtime、真实hub/monitor/LPV/AXI与source保护、production request退休、实际physical closure/rearm/第二request、完整model/graph、算术、资源、时序和板端均NOT_RUN。未改原shell、共享actor/stream/header/config/catalog、原runner或合同。交付freeze-ready后停止写源，除非父另行分配修复。

## 2026-10-13追加：executor_hls_01 COST_STOP只读诊断

父A002复用A005进行只读定位；本次仅写本报告及`project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_01_cost_diagnosis_A005_20261013.md`，未改attempt冻结/日志/manifest或任何共享源。无后代，无HLS/compile/RTL重启，无预算调整，无LLVM工具执行。

guard原始事实：semantic stall120.081628秒，elapsed280.460530秒，peak1477768KiB，1401RSS实际样本，child-9。最后完成`.autopilot/db/a.g.ld.5.gdce.bc`，LTO tmp0字节；最后原始err日志01:41:00.711 UTC写入，末项是5个8192位stream端口disaggregate。Compile/Link=266124，Unroll/Inline=pending，无generatedtop。guard遍历包含hidden db，最终实际work仍543文件/74586132字节，mtime也无后续推进；可见产物停止属实，但内部pass未输出不能直接判死锁。

报告仅列前20大function/location累计值，不能相加：stream238192、actor210006、port130403、FSM123872；owner-event通用descriptor链含9次full_f32_address累计24732。1138条NeverInline remark及仅1条FullMemory构造函数明确inline，不支持直接归因自动inline爆炸。明确Inputs整副本含至少1280字节原packet，未发现FullRuntime整对象clone；copy存在不等于已证实stall主因。

有证据的候选减法是利用FSM已准入NORM/HIDDEN→NORM、region0、TOKEN、宽1024/fullS约束，对owner-event采用专用checked NORM descriptor，保持完整校验/sequence/失败码并去掉每个descriptor三次通用地址求值；应先做完整descriptor对照及现有host合法/拒绝/取消验证。接口阶段需要同5wide ap_fifo有限微top对照独立证伪；另可做top独占Inputs临时副本消除对照。所有建议均是新结构候选，不能原样restart、延长120秒、削弱whole accepted receipt真实shell ack，或以CPU/重复日志计进展。详细原始身份、产物时序、前20项及建议边界见新诊断文件。功能综合结果仍COST_STOP，生成RTL/同runtime/资源/时序/physical闭合均NOT_RUN。

## 2026-10-13追加：NORM provenance最小结构减法实现候选

父A002依据上述诊断授权实现；本次仅写下面三文件和本报告。已读research-agent工程/硬件证据规范及现minimum-hardware/production-partition合同。A004负责独立gold/泛型对比测试，父A002负责串行工具及整合；本子任务无后代，无编译/HLS/RTL执行，不改test、runner、历史attempt或安全协议/版本。

| 文件（相对E002 experiment） | 行数 | SHA256 |
| --- | ---: | --- |
| `hls/platform/generated_provenance_events.cpp` | 567 | `775936e115fae7782fa715a536f25fe2c2286b278fd93c3afa687169eca2f38e` |
| `include/laya_generated_provenance_events.h` | 68 | `aa62ad539cd8b88e1cc3f7601bcf7da48313594520d252bd4df193742e10b8c0` |
| `hls/control/task_lifecycle_fsm.cpp` | 464 | `ee19f74d6af8f69bfc14c92c5f2bc94af572eca94f48795c153eb59045473e51` |

新增导出`build_norm_owner_event(rt,memory,model,Action,const FullOwnerSpec&,Request&)`和`build_norm_generated_begin(rt,memory,model,const LayerNormTask&,elements,unit,Request&,bool&)`。FSM只有原已准入的HIDDEN→NORM、region0、TOKEN、宽1024、whole B/S action路径改用新函数；`start`完整family/身份/owner/预约拒绝规则未改，泛型接口保留且实现逐字未改，无新增inline pragma或泛型动态回退。

内部固定NORM layout为STATE0、base8MiB/span8MiB、row_stride4096、batch_stride4194304；whole owner extent仍`(B-1)*4194304+S*4096`。固定`norm_offset`取代通用多Buffer的`full_f32_address`→`f32_address`→`byte_address`→`span`分支树，不新增或放宽shape规则：仍按原顺序要求B1..2、S64..1024、batch<B、row<S、col<1024及32位/8MiB范围。保留原Ref完整epoch/bank/region检查、完整mapped容量和first `full_span`的真实host BO presence检查；`__SYNTHESIS__`现命名端口presence语义原样沿用。first失败原Check直接返回；last/next原uint16截断、错误归并到NORM reason8、offset次序及partial descriptor字段均保留。first验证通过后，last/next同固定span的物理检查由已核完整capacity/presence和offset边界证明冗余，不以容量替代第一次presence。

BEGIN继续原完整snapshot（FILL/EXCLUSIVE_RW及完整identity）、旧owner Ref与model绑定拷贝；unit/elements/snapshot失败不耗sequence，descriptor/实际batch-row0-rows geometry/wire失败按原顺序耗号。原`wire_check`在codec-bypass宏内ok、宏外完整decode(encode)不变；S1/S16仍在更早的f32形状前置拒绝，不产生成功wire。Geometry的first/next校验、零/非零row_step、row_count/总write bytes及原错误构包前缀不增删规则。完整model/Ref/sequence/lease/退休/撤销及atomic shell receipt协议未改。

仅轻量静态检查PASS：C++词法定界符/尾随空白；两API声明、定义与FSM各一次调用；FSM无泛型builder回退。将新增代码块与两处调用替换在内存中撤去后，三个完整文件均与`executor_hls_01/frozen`原文件逐字一致，证明未改原generic或其他既有实现，原HLS pragma序列身份不变。上述三源已向父和A004发送freeze-ready SHA并停止修改；之后仅写本报告。独立字节/拒绝对比、host回归、Compile/Link规模改善、生成RTL及性能结果均待父实际验证，不能据静态候选写功能PASS或预计已节省24732 instructions。

## 2026-10-13追加：FIRST admission transport候选交付

状态：三新文件freeze-ready，轻量Python AST、内嵌Tcl `info complete`、SV词法定界符/关键字配对、32个bridge端口完整连接、原managed AXI portal全部60个input显式连接及尾随空白检查PASS。编译、oracle生成、host执行、HLS和RTL仿真均未由本子任务启动；功能仍NOT_RUN。无后代；父A002串行调度重工具并维护共享实验摘要。此前control transport和NORM特化源未再修改。

新增文件均在`project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/`：

| 文件 | 行数 | SHA256 |
| --- | ---: | --- |
| `rtl/laya_executor_admission_transport_v1.sv` | 115 | `f394bff0eda2048407675f3d35626afda064e417de1713f706fb273d1d2ada30` |
| `tb/laya_executor_admission_transport_tb_v1.sv` | 311 | `f6cbd58e3ccb08fe65a7d8867a8d46a4793d80f05bb24febfd92df8f97924a63` |
| `tb/run_executor_admission_transport.py` | 277 | `106af844703aa18dd0632ebeed6e5a5264f0260bc73e76687fb7623bfefefd42` |

runner内24行Tcl SHA256为`276cab3c43d3177622aac143c9fd8b0cb969e6ac71cdad2ea262a6bd81599e37`。本任务未新增共享standalone Tcl；父启动时由runner写入新attempt的frozen并记录身份。

### FIRST入口及实际portal权威

最小接口为executor实际`admission_owner_din/write/full_n`和反向`admission_owner_receipt_dout/empty_n/read`，完整`lpv_admission_valid/record/ready/accepted`接原portal。内部一帧FIRST quota以exclusive actual A producer的首个实际FIFO write取得拥有事实；该producer只有真实LYRQ/LYMP准入之后才发A。wrapper必须接此唯一实际producer lane，不能用任意TB或外部caller代签真实准入。`first_started`仅为拥有旧帧事实，不表示A校验通过。未新增`first_admission_valid` bool，未引用receipt之后才变真的既有top `admission_valid`，不形成循环授权。

复用原`laya_private_fifo2_v1`形成真实depth2入口和receipt队列。只有16次实际入口write及16次实际collector pop后才呈现完整8192位A；完整A之后永不改写。原`laya_generated_provenance_axi_portal_v1`以`.MONITORED_ROLE(6),.MANAGED_LPV_OWNER(1)`执行原完整LAD1 validator及物理STATE0 epoch/address/capacity核定、owner安装；transport没有复制validator。只有实际`valid && ready && accepted`开始原16拍echo。`ready && !accepted`计一次完整portal handshake后保留A并隔离，零安装/echo，无retry或第二A。入口write/pop、portal handshake/accepted及receipt write/read六种实际计数分别保留。

首拍之前cancel只阻止新帧，不制造已撤销A；首拍之后cancel sticky但不门控旧剩余beats、不清FIFO或计数，收齐后隔离。完整record等待portal时cancel阻止accepted并隔离。实际accepted之后，即使cancel持续、live base epoch/address/capacity变化导致原portal owner持久revoked，原包receipt继续16次实际FIFO write/read后才DONE。DONE、rejection及preaccept-cancel均永久关闭FIRST入口；模块无CLOSED/REARM权威，reset只对应独立session初始化。

### 有限TB覆盖意图（尚未运行）

八种reset分隔诊断，旧取消帧与echo排空内无reset：

1. cancel时尝试新首拍被阻止；deassert后真实送16拍，入口14/15次write后各等12周期。实际portal以adapter_pending_zero=0阻塞12周期，完整A保持、零install/echo；放行后原portal安装一次。receipt先填满真实depth2并反压12周期，再持续cancel及live物理配置变化；原portal持久revoked但原echo按literal全字节继续，14/15次read后各等12周期，16次write/read全部排空后才DONE。第二A及cancel deassert不重开。
2. actual A的reserved byte888改变：原portal ready但不accepted，零install/echo，原坏包保留并隔离。
3. STATE0 mapping迁至AUX role5、known_roles改32并清STATE0：原portal核未知STATE0域，零install/echo；TB不复制或自行签LAD1合法性。
4. STATE0 epoch7→8：完整原portal物理核定拒绝。
5. STATE0 address+64：完整原portal物理核定拒绝。
6. STATE0 capacity+64：完整原portal物理核定拒绝。
7. 已写14拍时持续cancel和live物理变化，旧15/16拍仍实际write/pop并保留完整原A，收齐隔离，零portal handshake/accepted/echo；deassert不重试。
8. 已收齐A等待真实portal时cancel，禁止actual acceptance、保留隔离，deassert不重试。

每cycle将六个counter与独立实际握手monitor对照，occupancy≤2，所有beat计数≤16、portal handshake≤1；完整record前零portal呈现，echo只允许accepted之后。实际安装record和原receipt逐字节对独立literal，拒绝/取消的完整retained record对原mutant或actual A。零业务accepted_requests/events/terminal/owner/AXI事务断言贯穿所有诊断；5000cycle cap。候选marker为`FULL_CURRENT_EXECUTOR_ADMISSION_TRANSPORT_RTL_PASS`，明确offline actual C++ A、TB source peer及generated executor同runtime NOT_RUN。本子任务未产生该运行marker。

### 已核host输入与冻结运行器

只读复核`R003/executor_admission_owner_host_02`：receipt和run均PASS，恰一条`FULL_CURRENT_EXECUTOR_REQUEST_CLOSE_PASS`；`actual_admission_owner.bin`和独立`admission_owner.bin`均1024字节且完整相等，SHA256 `40df536794b2377bb4955c106ce1a3eef8ded0a4b5c92d57c7f4eac218c56d0f`，各有恰一条匹配原receipt fixture ledger。这是复用已冻结host输入证据，非本轮新host PASS。

runner要求新/nonexistent `--attempt`和verified `--admission-host`。冻结两份完整A、host manifest/receipt、三新文件、原真实portal的10个RTL闭包、launcher helper runner、production_guard/hls_guard_helpers、当前HLS入口/stream接口参考与minimum-hardware/production-partition/managed-LPV/bootstrap-source/FIRST-Q五份合同。逐项保留original/frozen SHA/bytes，并核已验证fixture及receipt未在读/复制间变化。仅以小量byte-preserving转换生成16行hex；无新oracle subprocess或本地validator。

Vivado行为pilot单阶段走guard：CPU0–3、nice19、idle I/O、MemAvailable严格>192GiB；8GiB RSS、120s wall及120s semantic stall。part为`xcu55c-fsvh2892-2L-e`，maxThreads4；单重工具由父调度。完整manifest、launcher、guard原始文件、Vivado log/journal与simulate.log保留，sim唯一PASS marker及outer唯一SCRIPT marker和无Fatal/ERROR才考虑PASS，九份actual capture还独立核完整期望字节及身份。guard触发单列COST_STOP；任何功能失败保留attempt，禁止覆盖历史。

父串行执行形状（仅文档，本子任务未执行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_admission_transport.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_admission_transport_rtl_01 \
  --admission-host /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_admission_owner_host_02
```

范围是offline实际C++ A、原完整portal validator/install与实际有限depth2 transport的候选连接；physical STATE0和adapter idle/no-work仍由TB控制。未连接生成executor同runtime、真实13BO/source保护/业务请求或物理安全收束，未实现CLOSED/REARM/第二request，完整model/graph、算术、资源/时序/板端均NOT_RUN。此次只写三新文件和本报告，未修改旧runner/TB、共享HLS/include、合同、catalog/索引或任何attempt。交付后停止修改，等待父明确后续分配。

## 2026-10-13追加：executor_hls_01→02只读IR结构诊断

交付`project/E003_production_chain_closure/experiment_results/runs/R003/executor_hls_02_cost_diagnosis_A005_20261013.md`。本轮只写该报告和本result；无后代、不改共享源/runner/header/合同/catalog或任何attempt，不编译、不重启HLS/RTL、不扩帽。父单独推进explicit-key和后续RTL候选，本诊断不替其结果。仅使用安装内llvm-dis/stdout及c++filt小工具，CPU0–3/nice19/idle I/O、30s单次读取上限；IR只在内存解析，未落`.ll`。llvm-dis真实版本7.0.0svn（安装路径clang-3.9-csynth），SHA `880acc2948de595512d36d9cd996b64e2e213e9ac3fb8e13db55d62c326ae4b6`。

确认两次25-source/defines/tool/实际driver相同，归一化整个reflow命令逐字相同，最后完成gdce再LTO；末err都是同五8192位stream disaggregate，02 diag明确`reflow-disaggr/DisaggrSucc`。该成功remark不能判该口自身卡死，也不能指认下个private pass。无完成lto、IO XML或generated top。02 guard COST_STOP/semantic120.071008s、elapsed285.493267s、peak1476484KiB、1426实际RSS samples、child-9；work543/74658264且最新mtime02:22:10.142046 UTC，无隐藏目录/同大小写漏观测的现存证据。

联合NORM专用+完整packet_equal使Compile/Link调用树累计266124→226981（-39143/-14.71%），但最后gdce的独立直接非debug指令41689→41517（-172/-0.41%）、函数466→459；累计、直接指令与性能口径严格区分，不全归NORM或宣称硬件收益。port/FSM仍有92254/85723累计子树，不能相加；直接actor2182、FSM1786、transaction decode1519及top806基本不变。NeverInline1138→1127、两次仅同一个FullMemory ctor明确inline；无自动inline爆炸证据。

全部99个named type定义两次逐字相同。唯一static Entry304640B、其中唯一FullRuntime275808B，FullOwners227120B/原34×128 source window/history、GDownPlan33936B/原128windows仍保留；是ABI对象尺寸，不是RAM/寄存器资源。没有FullRuntime整体aggregate load/store克隆。真正仍在stream的copy是2464B Inputs整体load+store，top已有其独占本调用临时对象；源byte包完整性不能删。报告建议下一最小尚未执行结构减法：top专用owned/in-place Inputs step，保留host const copy适配，只去掉此重复临时对象，真实consumer事实/完整cancel包/验证/旧owner/Runtime均保留；对停滞影响未知，父新身份原帽验证，不新增宽口微top必清单或无依据inline。

02实际top可达memcmp链已核：std::array1024比较在executor_hls.cpp216/237，另std::array256比较在executor_actor.cpp105 observe_host_result；均通过std::equal/__equal_aux/__equal<true>到唯一直接memcmp call。三个业务上层不能因直接call只有一处而记为一次业务调用。已实际消息通知父，父确认补齐第三Host result完整比较；保留02冻结身份，不将该可解释库修复自动写为停滞根因。

真正切断lifecycle同步闭包若需分区，FIRST准入、helper原子import及action/allocator/owner退休必须继续同一唯一Runtime owner，需完整A/K及LBR2的有界提交/返回和现LAP1/LAC1消费接口；不能两top各clone Runtime、传整可变Runtime/指针/短hash或重新创建验证权威。报告列必要语义边界，未实施新接口。HLS保持COST_STOP；generated/同runtime业务与物理安全closure、资源/时序/板端NOT_RUN。报告交付后停止此诊断，不继续枚举。

父最后转达主控R-SM003-EXECUTOR-SECOND-STOP-PROGRAM-GENERATION方向后，报告将最优先下一候选改为单个可选、原帽内的同五×8192准确方向+真实nb读写微top：三输出control accepted/rejection/program_owner、两输入owner receipt/pending，原完整record稳定/反压保留，去actor/FSM/Runtime、无memcmp。生成则五口单独不足停止，仍需区分actor复杂度与剩余unsupported；同pass COST_STOP则wide lowering得到独立支持，均不代签executor/原子shell ack。不是必跑清单，未写微top或启动工具。2464B owned Inputs是有IR依据的更小完整候选减法，但单独根因区分力较弱，不再作为默认下一轮削指令。静态候选/诊断结论仍不升级实际功能结果。

## 2026-10-13追加：同五路8192bit FIFO微top候选交付

状态：四个新文件freeze-ready，停止修改；仅Python AST、C++接口/pragma/实际nb调用/完整字节循环存在性及尾随空白轻量检查PASS。依赖预处理、fixture生成、host编译/执行、HLS、RTL及物理验证全部NOT_RUN。没有创建attempt，没有启动任何工具或后代。父A002继续唯一整合/执行owner；本次未写共享接口、catalog、旧runner、旧诊断或任何历史attempt。

| 新文件（相对E002/experiment） | 行数 | 字节 | SHA256 |
| --- | ---: | ---: | --- |
| `include/laya_executor_wide_fifo_diagnostic.h` | 63 | 2225 | `4bb01b36511f4442eb7b5dd8bd987230b6733effc7ebcff96abf0fdc33ecd802` |
| `hls/control/executor_wide_fifo_diagnostic.cpp` | 77 | 2964 | `df86a13c59dc7fa4ce138bcabcb1bdf4ea59e8e0c694c9b659b27ebc60dfb687` |
| `tests/executor_wide_fifo_diagnostic_test.cpp` | 165 | 8496 | `2e63252cb0410ad1af25ad5d352f3a5bcb8f8093ad676969485c28bc65d1a2af` |
| `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_wide_fifo_diagnostic.py` | 498 | 28941 | `b36e6787735b644b50ee2d1829f16b8795bf9817941cf1499c6b1b9d33ee7825` |

### 诊断行为与实际验证边界

顶层`laya_executor_wide_fifo_diagnostic`只有同executor五个`hls::stream<ap_uint<8192>>`：三个输出`control_response_receipt`、`control_response_rejection`、`program_owner`；两个输入`program_owner_receipt`、`program_pending`。实际`read_nb`各消费完整输入到1024B数组，三个`write_nb`分别输出owner原字节、pending原字节及逐字节XOR。第三输出依赖两份实际消费输入的全部字节。原数组、独立sent flags和完整旧包在反压下保留；三个原输出都实际写成功前，不读排队的下一输入。不存在actor、FSM、Runtime、codec、memcmp或dummy接口，也没有准入、accepted shell ack、helper提交及退休权威。

安装的host `hls::stream`无容量、`full()`恒false且`write_nb`恒成功，无法用它签反压。header中显式测试宏`LAYA_WIDE_FIFO_DIAGNOSTIC_HOST_FIFO`启用真实depth2 bounded peer；定义同时遇`__SYNTHESIS__`会报错，HLS配置完全不包含此宏，继续使用真实安装Vitis stream。peer对实际失败write保存整8192bit并比较每次失败载荷，test用逐字节独立gold核三份阻塞载荷和最终六份capture。此覆盖属于同C++源码的有界软件peer，**不是generated RTL backpressure PASS**。

host意图覆盖两个实际input consumers、先到单个input不得输出、三输出都blocked、按receipt→owner→rejection顺序独立解除反压、已成功lane不得重复写、最后旧输出成功前保持后继两输入未读、第二完整输入pair实际消费、每份输出全1024B检查且最终有限队列空。原blocked段内不reset。成功marker候选是`FULL_CURRENT_EXECUTOR_WIDE_FIFO_DIAGNOSTIC_HOST_PASS`；本交付未产生执行marker。

### 独立runner与冻结计划

新runner默认在新`--attempt`内顺序运行host→HLS；可选`--host-only`。生产编译闭包严格为一个新.cpp和一个新项目header；host另加新test。实际父运行时使用四个受guard的GCC `-M`变体：host source/test带bounded peer宏，生产默认source和`__SYNTHESIS__` source不带此宏。保存每条实际命令/退出码/原始stdout/stderr与include SHA；拒绝混入额外项目依赖，冻结完整项目和外部header，保留原/冻结字节及SHA并拒绝copy期间变化。此口径明确为GCC预处理闭包，不声称GCC与HLS内部STL完全相同；真实HLS内部产物完整保留。

runner同时冻结新四文件、production_guard、hls_guard_helpers、executor接口参考header及四份当前合同，记录GCC/Python、Vitis wrapper/loader/unwrapped HLS/clang/opt实际路径和SHA及实际版本log。它自含独立literal byte fixture公式，不调用DUT或项目codec，运行时产生owner/pending/mixed两帧共六份1024B。全部实际字节输入和派生配置在host编译/执行及HLS前写入manifest并保存冻结副本；真实六份capture再由Python独立全字节核对且保存身份。

资源preflight严格CPU0–3/nice19/idle I/O/MemAvailable>192GiB；各操作串行使用24GiB RSS、1800s wall、120s真实进度guard。父负责全项目唯一重工具调度，本runner不另开并行。HLS实际v++命令使用U55C/150MHz（6.666667ns）、Vivado flow、pipeline_loops=0、throughput-driven array partition off/complete threshold=0，一个真实source且只加AP_INT_MAX_W=8192/c++17/include配置。

终态保存guard全部原始文件、work日志/产物SHA、design_size原文、最后reflow log/named Pass/Name、最新bitcode及模块resource XML。generated候选必须实际存在，checker要求准确15根FIFO信号：三输出din8192/output、full_n1/input、write1/output；两输入dout8192/input、empty_n1/input、read1/output。接受已验证的`_V`命名位置，但只允许准确15根加input clock/reset，总17端口；禁止AXI、ap_start/done/idle/ready或任何额外lane。host PASS与generated PASS分别记录。

父原帽串行执行入口（本文只记录，不曾运行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_wide_fifo_diagnostic.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_wide_fifo_diagnostic_01
```

### 结果区分力

微top真实生成且接口检查通过，说明同五宽FIFO接口单独不足以解释完整executor停止；完整actor状态复杂度和残留unsupported操作仍未知。只有微top真实COST_STOP且原日志/最后artifact核实与executor_01/_02同一阶段，才支持wide lowering有独立贡献；不同阶段停止不具此区分力。均不能证明编译器内部死锁，不能替代生产executor、原完整K/accepted handshake、实际shell/helper/唯一Runtime/退休、完整model/graph/数值、安全physical closure/rearm、RTL反压、联合资源、时序或板端。M003/M004状态不由本候选升级。

## 2026-10-13追加：五宽口实际生成后的只读定位

父新任务由A005复用本agent执行，无后代。本次只写本记录及`project/E003_production_chain_closure/experiment_results/runs/R003/executor_wide_fifo_generation_diagnosis_A005_20261013.md`（99行/12054B，SHA256 `758e082b32fe3a6979740937dc07c37667a9d37ac389600347ad6104922c76be`）；未改四份已交付源码、共享实现、runner、旧attempt或原budget。

实际父运行`executor_wide_fifo_diagnostic_01`为PASS_SCOPED_GENERATION，host另为PASS_SCOPED_HOST。独立读取receipt/manifest/guard、实际top及工具pass：HLS child0/trigger null，elapsed38.071846470s、peak2372468KiB、189次RSS捕获，22条CPU0–3/nice19/idle I/O policy符合；实际top42256B/SHA `994f8cc0736202ca1539a67b7b2260db37a85618236aadd63532ed8b16a37ac2`。本次独立词法核准确三个8192输出、两个8192输入，共15FIFO信号＋clock/reset17端口；实际enable连接full_n/empty_n、data接collect/repack，非dummy。242个generated artifact＋7个HLS guard引用哈希、342个original/frozen配对均匹配；六份原实际capture全6144B再次对照独立fixture匹配，没有重跑binary。

微top经过同五个reflow-disaggr/DisaggrSucc成功事件，实际继续完成LTO（a.g.lto.bc24912B）及RTL；相同关键aggregate/array选项，而executor02仍只有0B LTO tmp。可签同五方向宽接口有可生成实例、组合单独不足必然造成该stop；不能据此定性actor复杂度根因或接纳production executor/RTL反压。微top资源只作该诊断HLS估计，不作为executor/联合资源或吞吐。

只读llvm-dis stdout解析02/微topgdce，CPU0–3/nice19/idle I/O，MemAvailable门及30s小工具timeout；不写.ll、不执行HLS/compile/RTL。按实际call opcode排除%call变量/globals误计后，02全部459defined可达、无间接call；唯一非LLVM普通external是memcmp。86个llvm.memset全部常量长度16–12288B，一处llvm.memcpy为8B owner_plan常量；无动态alloca、异常、原子或vararg。不能凭external清单排除defined函数内部unsupported操作。

当前两文件三个完整array比较已改packet_equal，不重复提新库修复。当前vs02另有bootstrap_snapshot_protocol.cpp的packed-parent purpose validator边界修复，因此完整候选不是memcmp-only A/B，须列三source差异。先读新完整候选实际IR证明memcmp是否消失和LTO是否完成；当前源码文本不能代签新IR。若仍无memcmp且同区间stop，下一最小特定候选是top独占2464B Inputs的owned/in-place传递，消除stream第二alloca和typed aggregate load/store，保留全成员/真实consumer facts/完整旧cancel包、同一唯一Runtime与状态/接口。观察该copy真实消失及LTO/生成出口，不以累计instructions减法判改善。此候选本次未实施。

聚合State/Runtime构造与跨phase别名仍是未证假设；没有FullRuntime整体clone，不能将Inputs复制推广成整个Runtime重复复制。后续不先缩历史/删错误phase/clone多Runtime或引入大拆分。报告已通知父；本次无新DUT执行、无重工具或新attempt，停止只读定位。生产executor/同runtime/实际shell接受/helper/唯一退休、model/graph/数值、physical closure/rearm、RTL反压、联合资源/时序/板端NOT_RUN及M003/M004未完成保持。

父最后明确下一完整executor候选只包含三处完整byte比较替换＋共享purpose标量边界修复，**本轮不加Inputs改动**；先新host再HLS03，原预期为核LTO完成、同五宽口实际lower及生成接口。父消息说明HLS03尚未启动、owned_hls05占用唯一重工具，本子agent未启动这些工具。若新候选仍同段COST_STOP，再单独考虑owned/in-place Inputs2464B复制消除，保留旧const API供reference tests。此方向已记录；不预言生成成功，不追认面积或性能收益。

## 2026-10-13追加：D-M003-EXECUTOR-OLD-LTX-CLEANUP-01的LTP1准备交付

状态：四个新文件freeze-ready，停止修改，父root继续唯一top/接口/collector整合owner。仅Python AST、C++词法定界符、宏分离/source范围及尾随空白轻量检查PASS；fixture生成、实际-M、编译/链接、host、HLS、RTL与新attempt全部NOT_RUN。本次无后代，未修改共享FSM/actor/top/既有接口/collector/adapter/sidecar、catalog、旧runner或原attempt。

| 新文件（相对E002/experiment） | 行数 | 字节 | SHA256 |
| --- | ---: | ---: | --- |
| `include/laya_executor_transaction_pending.h` | 52 | 2705 | `a43a2c05d7e9a31015ba22737ca3d9328a02c1cdc7ceaabb5664f6506522d852` |
| `hls/control/executor_transaction_pending.cpp` | 131 | 6122 | `5d6b04fee938855d6443ac3be45ce8b27f8cb0ebdc5d11e21fdc884665115669` |
| `tests/executor_transaction_pending_test.cpp` | 144 | 8749 | `fe64c1b9a0e782c7cf1fd7d86309a26b8e671415b66705c1c9fc49cadc16af90` |
| `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_transaction_pending.py` | 320 | 20630 | `f168008c0450ec37b8d380e07b8e12e453667e93acbb6e6ed8f86f3b04cc9cea` |

### 固定wire及API

private LTP1严格2112B/33×512bit：magic0x3150544c、version1、beats33；route byte8仅0/1；flags byte9仅HAS_HOLD bit0；10..15和48..63保留0；16/24/32/40分别session、accepted_request、source_sequence、handoff_epoch四64字段；64..575原完整512B LAX，576..2111原完整1536B LTX。HAS_HOLD要求四K字非零；无HOLD仍用真实A的非零session/request引用，sequence/H必须0。不移动、重建或改变LAX/LTX/Host/LPV/LTC wire，不建第二A owner表。三个static_assert固定各边界。

namespace为`laya::transaction_pending`。`Key`保留上述四字及has_hold；`Record`仅route/key/action_packet/transaction_packet，全部原packet字节；`Packet`为2112B。`same_key`和`validate_metadata(record, expectedK, expectedRoute)`做结构和caller持续K/route全字段比较；`encode(record)`仅显式组LTP1头并逐字节复制原LAX/LTX，绝不从scope重建事务。metadata校验没有body/A proof，不能代签完整记录接纳。

完整API是`validate(record,oldA,expectedK,expectedRoute)`、`capture(key,route,原LAX,原LTX,oldA,out)`、`decode(packet,oldA,expectedK,expectedRoute,out)`以及`decode(packet,oldA,actualExpectedRecord,out)`严格快照重载、`same_record`。capture/decode失败将out的metadata和两份全包清为0；先实际admission_owner::validate旧A，再实际action::decode及transaction::decode Request，并分别全字节重encode核canonical；action和选定LTX kind的完整NumericIdentity核原A，选定LTX的416B model与原A完整byte比较。strict重载另外核原完整action及transaction全包，拒绝语法合法但外来的action ordinal或LTX event_seq等，不以短hash/类别/seq代替原帧。

LAX本身没有model/K/route，LTX本身没有action ordinal/PC；未虚构跨wire字段关系。纯codec不能检测caller偷偷把唯一A槽替换为同session/request/identity/model但不同physical map的另一记录：旧A不可替换以及旧A/K/route引用生命期仍必须由唯一wrapper保持。此模块不复制owner表，接收提供的完整oldA作真实核验；实际FSM snapshot来源/collector全收/完整LTX byte match和后续adapter/hub校验继续由父整合。

`managed_cleanup_candidate(transaction::Request)`仅检查kind=PROVENANCE、flags恰CANCEL_CLEANUP、action=END或INVALIDATE。record重载先实际LTX decode/canonical，再检查上述类型；它没有A/scope/hub permission、publication、retirement或allocator意义。

### 真实编译闭包差异及父决定

现`controller_transaction_codec.cpp`的完整Request decode位于`#ifndef LAYA_TRANSACTION_SEQUENCER_CODEC`，当前FIRST25源定义该宏且没有三外部codec。已向父报告，父明确接纳分离：新cpp在相同宏下只定义metadata/encode；full validate/capture/decode/same_record/cleanup谓词均在full分支，头部声明保留但FIRST实际top不得调用不可用full API。未用stub或gc-sections绕过undefined，也不把decode弱化为局部检查。父尚未把新source加入25源或改共享config。

host runner明确不定义SEQ_CODEC，使用15实际source加新test：七common（numeric/tasks/task_retirement/memory_map/full_memory/full_owner/full_io）、compute_portal_client、controller_transaction_codec及真实compute_portal_codec/generated_provenance_codec/producer_engine_codec，再graph_action_protocol/admission_owner_protocol/新pending。host defines只有PARTITIONED_PRODUCTION_CALLER、CONTROLLER_TRANSACTION_SEQUENCER。没有actor/Runtime实例、hub或执行器top；metadata variant只是额外实际-M预处理身份，未在此执行。

### 独立测试与runner（均尚未执行）

runner自含独立Python literal字节构造，仅从冻结选定模型header读取四tag、source SHA和五model BO sizes，手工布局完整LAD1/LAX/LTX/LTP1，不调用DUT codec或读DUT输出作为gold。十种record为END/INVALIDATE各cleanup及普通flags0，RELEASE/CLAIM/BEGIN/PUBLISH、COMPUTE、PRODUCER；再一份route0/no-HOLD，共11份2112B。所有普通kind可做结构/完整A绑定核验，但cleanup谓词只允许精确两类，不意味着事务获得许可。

C++ test逐字节对全部2112B independent gold，保存11份actual capture；实际full codecs、canonical、完整body快照binding、错A session/request/identity/model、四K及HAS_HOLD错、route错、header/所有保留字节、LAX/LTX头/尾及identity/model tag和尾字节、语法合法但外来的完整action/LTX、无HOLD伪sequence/H、有HOLD零sequence/H、伪flags3、END flags0均有拒绝/清输出检查。重复相同record允许新真实占槽重试，codec没有replay/退休ledger。测试不实例化Runtime、不计任务退休、不模仿collector/adapter首pop。候选marker为FULL_CURRENT_EXECUTOR_TRANSACTION_PENDING_HOST_PASS；本交付未产生实际marker。

runner要求新--attempt，不覆盖历史。父执行时串行guard做17个实际-M单元（15source+test full分支，另new source metadata宏变体），留逐条命令/退出码/原始stdout/stderr及完整项目/SDK include身份，冻结source/header/test/runner、guard/helper、真实模型header/manifest和三份合同，保存原/冻结SHA/字节并拒绝copy变化。GCC/Python实际tool SHA、版本及SDK-M闭包保留；全部23个输入fixture（A、LAX、10LTX、11LTP）在host compile/run前保存身份并冻结，再由runner全2112B独立复核11capture。

preflight严格CPU0–3/nice19/idle I/O/MemAvailable>192GiB；dependency/oracle/build/host各24GiB/1800s/120s语义进展保护，串行一操作；全项目重工具仍父统一调度。该入口不调用HLS/RTL，记录collector/adapter实际pop/occupancy、原A物理不可替换、hub许可/物理终态、allocator/唯一退休、executor生成/同runtime与物理验证NOT_RUN。

父可按原帽串行执行（本文仅记录，未运行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_transaction_pending.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_transaction_pending_host_01
```

### 父整合的已核最小导出窗口

FSM send（task_lifecycle_fsm.cpp45）完整保存transaction/request_packet/after_transaction后为TX_WRITE/beat0；24拍request write只转TX_READ，完整包在读16拍及TX_VALIDATE期间不改，直到结果分支下一send。LTP导出可在此串行进行，collector实际收全核原A/K/route及包后才开LTX；不得为导出冻结整个top而自堵。现Port保存的原512B LAX保持整个action；m.scope会在PRODUCER_RESULT变END，INVALIDATE则由owner_event局部event直接send，不能用scope代替原m.transaction/request_packet。

真实collector首pop和adapter首pop必须独立；sidecar txn_start继续是adapter后者，txn_done继续是真实第16LTC caller pop，同包END/INVALIDATE重试也每轮新占槽。不因第24LTX写、LPV尾写或LPA尾读释放旧A/route。撤销下只允许匹配真实旧pending候选被收集，普通合法未外发帧由实际adapter原LOCAL_REJECT出口完成，END/INVALIDATE仍由唯一hub核；未知归属隔离，不能凭类型bool通行。本轮未接这些硬件握手，未实现collector，不升级production/C闭合或M003/M004状态。

## 2026-10-13追加：LTP1实际host01及stream Inputs双模式回归准备

LTP1的`executor_transaction_pending_host_01`已由父真实执行，receipt为PASS_SCOPED_HOST；dependencies/oracle/build/compiler_version/host五操作PASS。当前读取host guard child0/trigger null、elapsed0.177852152s；进程过短，1个sample、0个RSS capture，peak=null，不能写成RSS峰值0。实际marker为11份2112B、ordinary kinds3、62个reject checks、同包下次占槽允许、owner_tables_created0、cleanup predicate非许可。本次只读复核11个actual/expected SHA/bytes及全23232B相等，未重跑binary；四份新文件冻结身份与此前交付hash相同。原receipt SHA `60d2d241cc5ccd1b0b293e7075cf82ded41e0b17e4385daa9a435a4146751e4a`，manifest SHA `6c87a54e5ba6f029c0195d704169d2578ec7150f6563b578263bf075e59444cd`，host guard SHA `f384d99181aad6f3fe05e71115a5731f7b2e4cb542a9e4d175cb02a7eb460337`。这只是纯codec host，不扩大到实际pending来源/collector/adapter首pop/occupancy、完整A物理不可替换、hub许可/终态、retirement或HLS/RTL。

父已唯一修改共享executor_stream header/cpp及FIRST top，使其局部Inputs走`step_in_place(Inputs&)`，旧const `step`保留复制wrapper。本轮A005仅拥有原stream test和对应runner。实际runner是`MODULE/tb/run_executor_stream_host.py`，不存在run_executor_stream.py；开工已报告父。重读research-agent/hardware-agent、工程参考、AGENTS及首请求合同，沿原M003/SM003及资源帽执行；无新agent，无compile/fixture/preprocess/host/HLS/RTL或attempt。

只读覆盖结论：executor_hls_top_test.cpp七case（success、bad-program-owner-echo、bad-owner-echo、io-address-mismatch、aux-address-mismatch、bad-request、bad-model）只通过Harness::call中的真实top入口；当前top因此经in_place，能覆盖FIRST/A/control/LBR2/GRANT/program-owner及拒绝，但没有直接const API及输入不可变断言，也没有原stream成功四NORM窗口/LAC/Host/CLOSE消费者的完整路径。因此没有修改run_executor_hls.py或七case，没有复制另一套test matrix；最小受影响回归直接复用原stream全部场景，增加同一Harness::call的两种API选择。

| 本次独占改动（相对E002/experiment） | 行数 | 字节 | SHA256 |
| --- | ---: | ---: | --- |
| `tests/executor_stream_test.cpp` | 617 | 35297 | `7780fce3c8c756e7dc576b5ff654b1bbd043006e3a68a1d687908f6db442045d` |
| `vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_stream_host.py` | 314 | 18084 | `7424510362c0d9162653b4b932abbfa391b9f2eda40176506e7df9a8fecf5be3` |

test保持原六组业务/拒绝/取消/CLOSE场景和literal_codecs，原断言/gold/末2末1各12步等待未删减。每个call先在有意设置action_consumed之后保存Input值，再逐语义字段、13个physical mapping三元组及canonical handoff/raw byte packets核持久caller Inputs全部未改；不读Inputs object image或padding。const mode直接调旧step，默认旧二参binary调用仍为const。in_place mode每次创建新的本调用scratch，核与持久Inputs及两份packet数组data地址不同，调step_in_place后核原configuration/session/request/base/source/map/fence不变、managed_close=true、result_consumed=false、request_valid按原FIRST门清除、原cancel/transport_error不被撤回。

in_place的control_request_consumed/control_response_valid/host_result_valid/action_completion_consumed分别严格等于本次实际control receipt/response frame/Host receipt/action receipt计数增量；总marker要求四类事实都有实际正覆盖。持久Inputs的legacy bool仍保持caller值，而scratch只使用真实完整consumer事实，原所有旧帧和错误隔离断言继续运行。此次只增加API/Inputs不变性检查，没有新增矩阵；原既有Runtime不变检查未重写，新Input检查无memcmp/padding比较。

runner默认`--input-mode both`，同一新attempt中一次原freeze/dependency/oracle/build，随后两个独立process `run_const`和`run_in_place`串行guard；可显式选择const或in_place。每个run marker绑定实际mode，manifest/receipt记input_modes及separate_processes，只有最后所选mode也PASS才写总PASS。原FIRST宏、源闭包、独立fixture和CPU0–3/nice19/idle I/O/MemAvailable>192GiB、24GiB/1800s/120s帽保持；没有改变共享实现或run_executor_hls.py。

仅Python AST、C++词法定界符、两API调用分支/原场景调用保留及空白检查PASS。双模式功能均NOT_RUN，不将LTP host01或旧const PASS挂到新Inputs实现。准备冻结后停止修改，父串行执行入口（仅记录，未运行）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_executor_stream_host.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/executor_stream_in_place_host_01 \
  --first-only --input-mode both
```

验收要求两个guard child0/null trigger、每mode唯一HOST_PASS、const persistent_inputs_unchanged_calls等于本mode总call且scratch0；in_place上述持久检查同样逐call通过、invocation_local_scratch_calls等于总call、实际control/response/Host/action四事实正覆盖，以及全部原完整消费者/port/FSM/program/adapter/CLOSE断言通过。软件stream仍unbounded，shell/fences/producer terminals仍受控；本任务不代签实际FIFO2、生成executor、同runtime C算术/周期/AXI、物理CLOSE/rearm或M003/M004完成。

## 2026-10-13追加：父实际stream_host03双模式PASS

父实际运行的是`R003/executor_stream_host_03 --first-only --input-mode both`，上述假定attempt命令仅属旧准备记录。本次独立读取实际receipt/manifest/五guard及两个完整mode marker，未重新运行binary。receipt总状态为PASS，dependencies/oracle/build/run_const/run_in_place全部PASS、child0、runner0、trigger null；102项原/冻结输入配对与35项原始guard文件共239个文件身份核一致。

const与in_place各完成5859次persistent Inputs语义不变检查；const invocation-local scratch为0，in_place为5859，实际control/response/Host/action消费事实分别20/48/2/1。完整原场景/独立fixture、FIRST及program/adapter/CLOSE限定断言全部通过；不比较Inputs padding。const elapsed0.230135718s/peak12664KiB，in_place0.231646562s/peak12696KiB，均1次实际RSS捕获；build23.090188997s/peak257708KiB。软件stream无界、受控shell/fence/producer与原HLS/RTL/physical范围限制继续保留。

实际receipt SHA256 `17153c6340477dbeba7c5a43d1f20d273cebfe8f10465ab47a27988723a6b536`；manifest `4fd862de01e51e339beeb0ee6ee0270b0d7e1cd03753ff85a3516403316a7305`；const guard `37b2ee29f3536f903f9a1e26c2c564c1c58b0f4661666628eaa996404cb69517`；in_place guard `dcb3eebbe5ef7c52c7bf2a367d1182d95a3a1428ed0adfbd8d73e83a8ab805e7`。stream test/runner保持交付SHA，停止修改；本子agent仅证据核查和本记录补记，不代签executor生成或M003/M004完成。

## 2026-10-13追加：managed adapter独立HLS入口准备

父授权仅新增`E002/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_controller_transaction_adapter_managed_hls.py`。采用独立入口，原default runner/旧HLS03收据不改；普通default host marker不能作为managed闭包PASS。新文件657行/39114B，SHA256 `d61e423111b162898a6e80a284f4ae3a8ae3359df3c79c6cb074b6a67475c7c5`。本轮仅AST/词法端口/空白/逐文件hash和原证据读取；新fixture、预处理、编译、host、HLS、RTL、版本工具及attempt均NOT_RUN。

原managed_host01历史receipt为PASS_SCOPED_HOST_MANAGED_ADAPTER（SHA `170be8093bcc1583f51ef7f4748d920f10d4c8be1d14a57f4fabc60038436815`），manifest `8e13d94d18d442753237a9f9bb3788718aa68592a0a44a3520234c85d3b06941`，build_inputs `98b5bf472fefe604cfcf1c9daa9178ba0dedef0fbd1d6e3c0462509c64295b8f`。早先独立核其65项冻结、实际managed355依赖（20项目＋335系统/SDK）及工具，当时没有drift。随后父依据A004发现委派A006修managed !parsed隔离；本入口最终**不接受旧host01**，必须fresh host02或后续同等五phase真实PASS且完全匹配新源码。并未把历史host01挂到变更后候选。

父/A006当前共享文件仅只读核SHA：adapter24019B/`de8d64c760b638ea6b41c5cad98c099ac84b1fbf02d90eec68019d473d7d4ac0`；managed test18808B/`0f3175577bd548d9e794a0101f6650b244f77a14806a75b7b80ecea545aba831`；managed host runner25493B/`f5cfce2875c711eeec556cdacd360383a12c3c322bd296b56f1c608d3f338fea`。无top公共接口改变。实际fresh host02由父安排，当前本子agent未读取或声明其PASS。

### 新入口证据与拒绝条件

`--reuse-host-attempt`参数化最新host目录（另兼容`--managed-host-attempt`），要求准确managed receipt/input schema、宏值1、原build/default/managed及新增isolation_bad_magic/isolation_bad_tail五phase全部真实PASS。逐条核原launcher、原24GiB/1800s及8GiB/120s/120s guard、child/runner0/null trigger、实际命令、唯一variant marker、全部原始guard文件、GCC/Python/stream API、两真实default/managed compile命令与各八TU的实际-M命令、binary、所有冻结输入及全部系统/SDK/项目transitive dependencies；每项已编译项目依赖再核当前ROOT身份。完整88case顺序/60LOCAL_REJECT/28remote及88×完整16拍actual/gold重新字节核对。

两个新增坏帧phase须独立调用同一真实managed binary，固定mode参数和各自capture目录；manifest过程配置、完整五份capture hash及marker字段必须完全匹配。入口独立按固定字节重构COMPUTE bad magic xor与END CANCEL_CLEANUP@32/reserved-tail@1535坏帧、原完整next PRODUCER24拍，核两份LTC严格空文件及CSV24 READ＋1 PREPARE＋256 ISOLATED完整281行，实际next24拍和三个peer response各1保持、所有输出0。只签未知未绑定坏帧隔离，all_malformed_recovery仍NOT_RUN。旧host01缺这两个phase已在只读核查中实际被拒绝。

正式父调用后，新attempt只freeze当前准确七adapter source与literal project include闭包、实际host编译依赖、model header/manifest、原config/布局、guard/helper、三份合同和全被复用host原始证据；不复编或重跑host。串行guard额外记录七源managed host与__SYNTHESIS__两种共14条真实GCC-M，保存每条命令/退出码/raw stdout/stderr和完整project/system/SDK闭包，拒绝未冻结项目include。外部header逐项snapshot并明确实际HLS仍使用原vendor/tool headers，HLS前后核原身份，不声称快照header被工具使用。真实v++/unwrapped v++/vitis_hls、可用clang/opt/llvm-link、GCC/Python身份及guarded实际版本日志完整保留。

派生配置真实加入`-DLAYA_MANAGED_TRANSACTION_ADAPTER=1`，准确七syn.file；保留原U55C/150MHz/Vivado、pipeline_loops0、throughput_driven off、complete_threshold0及数值flags。所有操作CPU0–3/nice19/idle I/O/MemAvailable严格>192GiB，单重工具；dependency/version/HLS均24GiB/1800s/120s，HLS真实work artifact进展保护。完整source/tool/external依赖/config/host证明HLS前后再次核身份。真实guard trigger为COST_STOP，真实操作或身份失败FAIL，端口失败FAIL_PORTS；只有各guard PASS及实际端口全符才PASS_SCOPED_GENERATION。

端口核查只解析实际top module header与该module完整input/output/inout声明；精确27端口＝四512输出＋四512输入的24FIFO信号（18external）及三个input1 clock/reset/cancel，核每项方向/宽度，拒绝未声明、额外/重复、AXI和top ap_start/done/idle/ready。HLS03实际使用原plain名称，不虚构宽松_V匹配。实际HLS03 top2088112B/`42f9056ad25de017d756f333de407925ae9f555c87f68c4b74db75a01471b558`在新词法检查为PASS；数据宽度错误、额外ap_start及cancel宽度错误三个只读字符串变体均FAIL_PORTS。原HLS03 FAIL收据`661589aded6a147e4f940f4d0532c86295fc37562c3e6bcb98e32da01070472b`保留；单独corrected port audit仅引用，不追改旧状态。

父可按原帽串行调用（本文仅记录，未执行；fresh host02必须先全部真实PASS）：

```bash
taskset -c 0-3 nice -n 19 ionice -c 3 python3 \
  /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E002_Laya_HLS/experiment/vivado/module_design/q8_linear_and_restore/tm1tn8_gs32_512/tb/run_controller_transaction_adapter_managed_hls.py \
  --attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_managed_hls_01 \
  --reuse-host-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_managed_host_02 \
  --legacy-hls-attempt /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_transaction_adapter_hls_03 \
  --legacy-port-audit /home/user/EDA-202/zhuowenjun/Workspace/Laya/Laya-HLS/project/E003_production_chain_closure/experiment_results/runs/R003/controller_adapter_hls_03_port_verification_20261012.json
```

入口已prepare-ready，停止修改，父统一选择真实launch。本准备不证明bounded depth2/attempted-unaccepted-first-write、旧A/K/pending collector、实际第16LTC caller pop/F10、hub权限/物理终态/唯一退休、production完整链、联合资源/时序/上板或M003/M004完成。

## 2026-10-13追加：用户立即切换到Q/LN数值优先，冷INIT准备留存

父传递用户`user-work-focus-switch-immediate-20261013`后，立即停止cold test/runner追加与executor HLS05计划；coldINIT/collector/exporter/managed cleanup/CLOSE退出本子任务优先队列。此前自然保存的两个新文件保留：`tests/executor_cold_init_test.cpp`418行/27323B/SHA `5ef52f0f0f04c1c125c060145ad799ea0e1f8ab818e8410cb0fc0bb14de3f70a`；`M/tb/run_executor_cold_init_host.py`402行/25315B/SHA `5455951db03e9fc94de577314c004cabefb84fa8c70e0826cbbd7da1c2efc164`。只有Python AST轻量语法通过，完整声明inventory、C++词法/编译、host双profile和15810调用等均未验证，**不是freeze-ready/PASS**；无新attempt、编译、预处理、HLS、RTL或fixture执行。共享ColdTable/types/top/config仍父负责，本子agent没有修改。

只读表访问核查没发现raw数组decay、array-ref参数、.data或整表mem操作依赖；已有[]、typed ref、range-for和SourceProvenanceRecord完整copy assignment/snapshot必须兼容。原完整row位图6144+4096+1024＝11264字，typed cells32+34+4352+128，总15810步；scorer/type仍原DMI。准备测试以原stream_host03冻结声明默认值和独立literal全部叶字段为gold，host另外13cache数组/13port指针容量/observer，synth metadata单独字段集；private allocator通过44合法physical domain及小副本first-ticket观测，不比padding，不在完成前读cold table。此准备因用户优先级切换保持NOT_RUN，后续恢复前仍需审查和修复准备代码，不应直接启动。

父另告知managed HLS真实运行结束后，原runner的post `unchanged()`因live `full_runtime/task_reservation`变化拒绝。本子agent保持managed runner交付SHA，未放宽/重跑；父保留真实attempt终态并以immutable generation证据另作限定audit。该边界不由本记录升级。

## 2026-10-13追加：可独立于FullRuntime/executor的Q/LN只读有界盘点

本轮只读`R003/layernorm_quant_source_03/04`及`layernorm_producer_hls_01`，未新增agent、工具运行或attempt。03的rows16数值链已有真实完整PASS；04仅受影响shell的rows1/F9兼容PASS，rows16明确`NOT_PLANNED_COMPATIBILITY_PILOT_ONLY`，不能将04或当前live整体写成rows16 PASS。

| 冻结实际运行 | 测量/状态 | 原资源帽与范围 |
| --- | --- | --- |
| layernorm_producer_hls_01 | PASS_SCOPED_GENERATION；99.227241566s/peak3117840KiB/496 RSS捕获，child0/null trigger | U55C/150MHz/Vivado；6实际C++源，无FullRuntime/executor；只gamma0/D1024生产者子范围 |
| layernorm_quant_source_03 static | PASS；77.547525117s/peak2352352KiB | 24GiB/1800s/120s stall |
| 03 rows1 pilot | PASS；47308cycles/57.410898756s/peak856868KiB | 8GiB/120s；LN实际1行1024词，不执行Q |
| 03 rows16 full | PASS；659334cycles/753.504079171s/peak856844KiB；3732 RSS捕获、child0/null trigger | 8GiB/3600s、5000000 cycles、120s stall；完整16384F32＋16384INT8＋512FP16 scale |
| 03 F9六拒绝 | 全PASS；四request约5.96–5.98s，两completion55.04/55.52s | 每个8GiB/120s，有真实数值返回的坏completion隔离 |
| 04 static＋rows1＋F9 | 全PASS；static75.113s，pilot55.006s；四request各约5.83–5.89s、两completion54.785/55.397s | 受影响shell/guard回归；full16未启动；全阶段约264s |

独立核03/04各303项已引用frozen project/generated RTL、fixture、upstream receipt/manifest、raw driver log、runtime DAT及native IP身份，无drift；上游engine另外40项source/fixture/guard身份匹配，原524288B B1/S128 `encoder_00_out` checkpoint哈希核真，source等于其前65536B rows0..15。原manifest original/frozen哈希配对一致；本次没有重新运行gold或DUT。

### 实际数值、端口与AXI量

诊断请求identity为request2100/generation73/B1/S64，真实LN_ATTN stage2/layer1/row0/rows16/D1024、gamma0；source是独立真实checkpoint前16行，不宣称完整S64 tensor。六源为`layernorm_producer_engine.cpp`、`layernorm_compute.cpp`、`producer_engine_codec.cpp`、`producer_engine_hls.cpp`、`laya_numeric.cpp`、`laya_tasks.cpp`。生成top有实际source512bit AXI read、destination512bit AXI write、request16×512/completion8×512 FIFO与base控制，不需要生成executor或C++ FullRuntime。

kernel真实对每1024维row作binary32相邻二叉tree mean、centered-square tree variance、eps0x3727c5ac、sqrt/reciprocal/normalize；gamma0不乘learned gamma，不能推广到gamma1/2。独立NumPy gold遵守相同逐步F32数值规则，非DUT输出gold。Q oracle从冻结LN gold分512×32组做F32 amax/127→F32 reciprocal→F32乘积→roundf ties away；FP16 scale RNE，另有独立tie sanity。LN gold含16384独特F32词。

03实际LN source AR16/1024个R beat＝65536B；destination AW16/W1024/B16、WSTRB全64字节、store65536B，每row4096B且恰64拍/4KiB边界。Q再经真实AXI从上述destination_mem读AR16/R1024＝65536B，禁止读未实际store的位置，source lease有read debt时保持。三个DDR方向合计196608B真实traffic。源64K＋LN输出64K，Q本地fullA逻辑payload为16384B INT8＋1024B half scale；TB的`fullA_groups=128`是4row一次的返回数，4row_blocks×32groups×4rows＝512完整row-group、16384INT8和512scale逐值case-equality，不是只检查128/512组。

TB在真实AR/AW/W/B、producer completion和Q/fullA返回施加周期性ready/full_n stall，核actual B退休后才交8拍completion、完成包全identity/Refs/geometry，END直接取实际completion status/unit/elements/issued store bytes，monitor真实WSTRB闭合；同次sim无中途reset，随后source query→QUANT/fullA→actual response retirement释放lease→fullA acquire/read/release→owner RELEASE。最终零AXI读债/协议错误、owner0/published0、terminal task1等断言通过。F9 request分别task_id、request_id、generation、dst epoch变化时AR/AW/W均0且scope retained；completion request_seq/origin变动保留真实producer1row traffic但caller completion0/scope/tracker retained。

### 固定身份及复用界限

| 证据 | SHA256 |
| --- | --- |
| 03 receipt / manifest | `ad6e5d6cf65c733ccfbd3dabf1e7e5403f7ee7abfe89a6fbd2c9667e2be86dd0` / `5766e20da355a23c10c734613a0bf4c5233baa46d480d3a9def32d24b50dd66f` |
| 04 receipt / manifest | `4115bbef5e4b974fce48acc33ce7b1996c7d6fa73e5b75c40a79a896be508e7b` / `f2e1f76435af9fc2e4f2f82a08ec94d3cc8193d92deed37fe90fee801779d5ba` |
| upstream HLS01 receipt / manifest | `2f960d401ad4ca698db6f1ea5b659a46f64830d01e93d1b7ed6238784e2cc55d` / `d4c551cd4991a3fd01ae514c0cd28d596e01f4f1d34c152c42874cdb8cbef80b` |
| generated LN top109897B | `b0971fb5569ca6601061d18e04262a4004b493918a48ac3d54db6a22d8610798` |
| engine6665B / arithmetic6114B | `b2943beba13e831a17fd181c96e00315659975f60596a7f72f715ecd5de23706` / `7d4983e8e47cb1e41d8fb79009afcc4f162e96d9accf9042ed8606c602c93237` |
| input64K / LN gold64K | `a3b19513fd392e4d0d912977ec2e163207f169ead7f9044f3b89f4694b2bcceb` / `418020d7e2cbde19d76796fbd3cf51d832480e06a338e560d006cfa18eb5464e` |
| Q16384B / scale1024B | `372333a960283e785f43efb6fe24b710fe342a2c0384e17e85033523b1c8ccaa` / `750fcc16c573de8eddf31efa57e2a56b9d3657b824118c1a85b0668bd253d7c7` |
| 04 fullA TB30780B / runner23457B | `bc2eacc161a253ea38cae3476b85752a7482f2e5757427d2ecb5fab0eee78e45` / `96dda71cb80b21deacad3c8fb13171ec07583cc798d989049f6a92fdacdbd50f` |

03→04相同83份生成engine .v/.dat/.tcl、算术Q RTL、gold/TB/量化source组合；不同的是hub、AXI portal、LN producer shell，新增bootstrap source guard及对应Tcl、runner/config/合同身份。当前live相对04另有6份`laya_generated_provenance_layout_v1.sv`、`laya_generated_provenance_v1.sv`、`laya_generated_provenance_hub_v1.sv`、`laya_generated_provenance_portal_v1.sv`、`laya_generated_provenance_axi_portal_v1.sv`、`laya_layernorm_producer_portal_shell_v1.sv`变化。故可复用旧算术及数值gold本身，不将当前整链签为旧rows16 PASS。

现成有限入口是`M/tb/run_layernorm_quant_source_shell_v1.py`，调用Vivado静态编译既有generated LN＋shared QUANT/fullA＋monitor/hub/source-lease RTL，再先rows1 pilot，按该pilot/1.5安全系数和262144个Q参考cycles判断是否开rows16，最后六个F9 negatives；可`--pilot-only`做受影响兼容，不涉及FullRuntime/executor。旧03投影1856s（只是成本参考，不是上界），实际单full753.504s；全入口实际约1023s/17分钟，重做generation另约99s但未变engine没有重新生成必要。本盘点未提交任何运行。原CPU0–3/nice19/idle I/O/MemAvailable严格>192GiB及单重工具合同保持。

HLS单engine估计BRAM29/DSP13/FF19765/LUT47775/URAM0，estimated clock4.867ns；ap_ctrl_none整体报告latency/II为undef。这些只是该冻结HLS估计，不合计sharedQ/hub联合物理资源或证明Fmax/吞吐改善。未覆盖当前6文件改变后的rows16联合回归、完整S64/其余B/S、gamma1/2/learned affine、Q其他K/零/异常角落、重复多job、一般cancel/reset/AXI错误恢复、矩阵C数值、production完整图、OOC/P&R/板端。M003/M004和先前各限定状态不升级。
