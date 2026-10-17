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
